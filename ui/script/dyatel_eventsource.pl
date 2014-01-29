#!/usr/bin/perl -w
#
# (c) vir
#
# Last modified: 2014-01-29 15:33:50 +0400
#

use strict;
use warnings FATAL => 'uninitialized';
use IO::Select;
use IO::Socket;
use HTTP::Request;
use DBI;
use Getopt::Std;
use Dyatel::ExtConfig;

my %opts; getopts('hd', \%opts);
if(exists $opts{'h'}) { help(); exit 0; }
eval "require Data::Dumper; import Data::Dumper;" if $opts{d};

my $conf = Dyatel::ExtConfig::load();
my $myconf = $conf->{EventSource};
my $dbh = Dyatel::ExtConfig::dbh();

{
	package EventSourceClient;
	use Socket qw( AF_INET sockaddr_in inet_ntoa );
	use IO::Select;
	use JSON;

	sub new
	{
		my $class = shift;
		my $fh = shift;

		my($port, $iaddr) = sockaddr_in($fh->connected);
		my $name = gethostbyaddr($iaddr, AF_INET);
		my $peer = "$name [".inet_ntoa($iaddr)."] at port $port";

		return bless { FH => $fh, PEER => $peer, LAST_EVENT => time(), @_ }, $class;
	}

	sub fh { return shift->{FH}; }
	sub peer { my $self = shift; my $r = $self->{PEER}; $r .= " (user $self->{uid})" if $self->{uid}; return $r; }
	sub initial_response
	{
		my $self = shift;
		$self->fh->print("HTTP/1.1 200 OK\nContent-Type: text/event-stream\nCache-Control: no-cache\n");
		$self->fh->print("Access-Control-Allow-Origin: ".$self->{req}->header('Origin')) if $self->{req} && $self->{req}->header('Origin');
		$self->fh->print("\n");
		$self->{LAST_EVENT} = time();
	}
	sub send_event
	{
		my $self = shift;
		my($data) = @_;
		IO::Select->new($self->fh)->can_write or return undef;
		$self->{LAST_EVENT} = time();
		print "Sending '$data' to ".$self->peer."\n";
		return $self->fh->print("data: ".(ref($data) ? to_json($data) : $data)."\n\n");
	}
	sub send_keepalive
	{
		my $self = shift;
		my $now = time();
		return $self->send_event('keepalive') if $now - $self->{LAST_EVENT} > ($self->{keepalive} // 30);
		return '0E0';
	}
	sub format_event
	{
		my $self = shift;
		my($dbev, $payload) = @_;
		if(($dbev eq 'linetracker' || $dbev eq 'blfs') && $payload == $self->{uid}) {
			return { event => $dbev };
		} elsif(($dbev eq 'linetracker' || $dbev eq 'regs') && grep({ $payload == $_ } @{ $self->{blfusers} })) {
			return { event => 'blf_state', uid => $payload };
		}
		return { event => $dbev, payload => $payload };
	}
}

$dbh->do("LISTEN $_") foreach(qw( linetracker test ));
my $pg = IO::Socket->new_from_fd($dbh->{pg_socket}, "r+") or die "Can't fdopen postgres's socket: $!";

my $lsn = IO::Socket::INET->new(Listen => 1, LocalPort => 8080, ReuseAddr => 1);
my $sel = IO::Select->new( $lsn, $pg );
my $timeout = 5.0;
my %clients;

for(;;) {
	my @ready = $sel->can_read($timeout);
	unless(@ready) {
		broadcast_keepalive(); # XXX make sure it is actually called every N seconds!!!
		next;
	}
	foreach my $fh (@ready) {
		if($fh == $lsn) {
			my $new = $lsn->accept;
			$new->autoflush(1);
			$sel->add($new);
		} elsif($fh->fileno == $dbh->{pg_socket}) {
			print "Postgres's socket is ready\n";
			while(my $notify = $dbh->func('pg_notifies')) {
				my($name, $pid, $payload) = @$notify;
				print "Got database notification $name from backend $pid, payload: $payload\n";
				database_notification($name, $payload);
			}
		} else {
			if($clients{$fh->fileno}) {
				disconnect_client($fh);
				next;
			}
			eval {
				my $buf;
				sysread $fh, $buf, 8192 or die "Error reading request: $!\n";
				print "Request: $buf\n";
				my $req = HTTP::Request->parse($buf) or die "Bad request";
				if(my $cl = check_request($fh, $req)) {
					$cl->initial_response();
					$clients{$fh->fileno} = $cl;
					print "New client from ".$cl->peer."\n";
				} else {
					$fh->print("HTTP/1.0 400 Bad request\n\nSomething is terribly wrong.\n");
					disconnect_client($fh);
				}
			};
			if($@) {
				warn $@;
				disconnect_client($fh);
			}
		}
	}
}

sub check_request
{
	my($fh, $req) = @_;
	print "Got ".$req->method." request for ".$req->uri."\n";
	return undef unless $req->method eq 'GET' && $req->uri =~ /\/(\w+)/;
	my($info) = $dbh->selectrow_hashref("SELECT * FROM sessions WHERE token = ?", undef, $1) or return undef;
	my $blfusers = $dbh->selectcol_arrayref("SELECT users.id FROM blfs INNER JOIN users ON users.num = blfs.num WHERE blfs.uid = ?", undef, $info->{uid});
	my $cl = new EventSourceClient($fh, %$info, req => $req, blfusers => $blfusers, keepalive => $conf->{keepalive});
	return $cl;
}

sub broadcast_keepalive
{
	my($data) = @_;
	print "Broadcasting to ".scalar(keys %clients)." clients\n";
	foreach my $key(keys %clients) {
		my $c = $clients{$key};
		$c->send_keepalive() or disconnect_client($c->fh);
	}
}

sub disconnect_client
{
	my($fh) = @_;
	print "Disconnecting client\n";
	delete $clients{$fh->fileno} if $clients{$fh->fileno};
	$sel->remove($fh);
	$fh->shutdown(2);
	$fh->close;
}

sub database_notification
{
	my($name, $payload) = @_;
	print "Got database notification $name with payload $payload, checking ".scalar(keys %clients)." clients\n";
	foreach my $key(keys %clients) {
		my $c = $clients{$key};
		my $obj = $c->format_event($name, $payload);
		if($obj) {
			$c->send_event($obj) or disconnect_client($c->fh);
		} else {
			$c->send_keepalive();
		}
	}
}




