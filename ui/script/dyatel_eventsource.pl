#!/usr/bin/perl -w
#
# (c) vir
#
# Last modified: 2014-01-30 23:06:24 +0400
#

use strict;
use warnings FATAL => 'uninitialized';
use IO::Select;
use IO::Socket;
use HTTP::Request;
use DBI;
use Getopt::Std;
use Dyatel::ExtConfig;

my %opts; getopts('hv', \%opts);
if(exists $opts{'h'}) { help(); exit 0; }

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
		$self->fh->print("Access-Control-Allow-Origin: ".$self->{req}->header('Origin')."\n") if $self->{req} && $self->{req}->header('Origin');
		$self->fh->print("Access-Control-Allow-Credentials: true\n");
		$self->fh->print("\n");
		$self->{LAST_EVENT} = time();
	}
	sub send_event
	{
		my $self = shift;
		my($data) = @_;
		IO::Select->new($self->fh)->can_write or return undef;
		$self->{LAST_EVENT} = time();
		print "Sending '$data' to ".$self->peer."\n" if $self->{verbose};
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
		if(($dbev eq 'linetracker' || $dbev eq 'blfs' || $dbev eq 'testevent') && $payload == $self->{uid}) {
			return { event => $dbev };
		} elsif(($dbev eq 'linetracker' || $dbev eq 'regs') && grep({ $payload == $_ } @{ $self->{blfusers} })) {
			return { event => 'blf_state', uid => $payload };
		}
		return { event => $dbev, payload => $payload };
	}
}

$dbh->do("LISTEN $_") foreach(qw( linetracker blfs regs testevent ));
my $pg = IO::Socket->new_from_fd($dbh->{pg_socket}, "r+") or die "Can't fdopen postgres's socket: $!";

my %sockparams = (
	LocalPort => $conf->{port} || 8080,
	Listen => 1,
	ReuseAddr => 1,
);
$sockparams{LocalAddr} = $conf->{host} if $conf->{host};

my $lsn = IO::Socket::INET->new(%sockparams) or die $!;
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
			print "Postgres's socket is ready\n" if $opts{v};
			while(my $notify = $dbh->func('pg_notifies')) {
				my($name, $pid, $payload) = @$notify;
				print "Got database notification $name from backend $pid, payload: $payload\n" if $opts{v};
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
				print "HTTP Request: $buf\n" if $opts{v};
				my $req = HTTP::Request->parse($buf) or die "Bad request";
				if(my $cl = check_request($fh, $req)) {
					$cl->initial_response();
					$clients{$fh->fileno} = $cl;
					print "New client ".$cl->peer."\n";
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
	my $cl = new EventSourceClient($fh, %$info, req => $req, blfusers => $blfusers, keepalive => $conf->{keepalive}, verbose => $opts{v});
	return $cl;
}

sub broadcast_keepalive
{
	my($data) = @_;
	print "Broadcasting keepalive to ".scalar(keys %clients)." clients\n" if $opts{v};
	foreach my $key(keys %clients) {
		my $c = $clients{$key};
		$c->send_keepalive() or disconnect_client($c->fh);
	}
}

sub disconnect_client
{
	my($fh) = @_;
	my $c;
	$c = delete $clients{$fh->fileno} if $clients{$fh->fileno};
	if($opts{v}) {
		if($c) {
			print "Disconnecting client ".$c->peer."\n";
		} else {
			print "Disconnecting client on fd ".$fh->fileno."\n";
		}
	}
	$dbh->do("DELETE FROM sessions WHERE token = ?", undef, $c->{token}) if $c;
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
		if($name eq 'testevent') {
			$c->send_event($name) or disconnect_client($c->fh);
			next;
		}
		my $obj = $c->format_event($name, $payload);
		if($obj) {
			$c->send_event($obj) or disconnect_client($c->fh);
		} else {
			$c->send_keepalive();
		}
	}
}

sub help
{
	print << "***";
Usage: $0 [opts]
	-h : this help
	-v : verbose output
***
}



