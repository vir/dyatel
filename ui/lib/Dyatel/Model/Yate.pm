package Dyatel::Model::Yate;
use Moose;
use namespace::autoclean;
use MooseX::Types -declare => [qw/ ExtModConnectInfo /];
use MooseX::Types::Moose qw/ArrayRef HashRef CodeRef Str ClassName/;
use Log::Any qw($log);
use Yate;

extends 'Catalyst::Model';


subtype ExtModConnectInfo,
    as HashRef,
    where { exists $_->{address} && exists $_->{port} },
    message { 'Does not look like a valid external module connect info' };

has extmodule => (is => 'rw', isa => ExtModConnectInfo);

has YateInstance => (
	is => 'rw',
	isa => 'Yate',
);

sub yate
{
	my $self = shift;
	my $y = $self->YateInstance;
	if($y) { # test for disconnection
		my $bits = '';
		vec($bits, fileno($y->{socket}), 1) = 1;
		undef $y unless 0 == select($bits, undef, undef, 0);
	}
	unless($y) {
    $log->debug("Opening new Yate connection");
		$y = new Yate(Debug => 0);
		my $cs = join(':', $self->extmodule->{address}, $self->extmodule->{port});
		$y->connect($cs, 'global', $self->extmodule->{scriptname} || ref($self));
		$self->YateInstance($y);
	}
	return $y;
}

sub send_message_wait_response
{
	my $self = shift;
	my $msgname = $_[0];
	my $y = $self->yate;
	my($result, $params, $processed);
	my $lambda = sub {
		my $y = shift;
		$result = $y->header('retvalue');
		$params = $y->params();
		$processed = $y->header('processed');
		die "ok\n";
	};
	$y->install_incoming($msgname, $lambda);
	$y->message(@_);
	eval {
		$y->listen;
	};
	$y->uninstall_incoming($msgname, $lambda);
	die $@ unless $@ eq "ok\n";
	if(wantarray) {
		return($result, $params, $processed);
	} else {
		return $result;
	}
}

use Data::Dumper;
sub testcall
{
	my $self = shift;
	my $y = $self->yate;
	my $r = [ $self->send_message_wait_response('test.test', undef, undef, param1 => 'val1', param2 => 'val2' ) ];
	return "I am alive!\n".Dumper($r);
}

# === status query ===

sub _parse_params
{
	my($text) = @_;
	return { map { split('=', $_, 2) } split(',', $text) };
}

sub _parse_status
{
	my($line, $details) = @_;
	my($mod, $par, $det) = split(';', $line, 3);
# Module name, type and format
	my $h = _parse_params($mod);
# Channel's params: routed, routing, total, chans
	$h->{params} = _parse_params($par) if defined $par;
# Details
	if($det && $details) {
		if($h->{format}) {
			my @format = split(/\|/, $h->{format});
			my @rows = split(',', $det);
			foreach(@rows) {
				$_ = [ split(/[=|]/, $_) ];
			}
			foreach(@rows) {
				my %h = ( row_id => shift @$_ );
				for(my $i = 0; $i < @$_; ++$i) {
					$h{ $format[$i] } = $_->[$i];
				}
				$_ = \%h;
			}
			$h->{format} = \@format;
			$h->{rows} = \@rows;
		} else {
			$h->{details} = _parse_params($det);
		}
	}
	return $h;
}

sub status_overview
{
	my $self = shift;
	my($filter) = @_;
	my $text = $self->send_message_wait_response('engine.status', undef, undef, details => 'false');
	my $r = [ ];
	foreach my $line(split(/[\r\n]+/, $text)) {
		push @$r, _parse_status($line, 0) if(! defined($filter) || $line =~ /\Q$filter\E/i);
	}
	return $r;
}

sub status_detail
{
	my $self = shift;
	my($module) = @_;
	my $text = $self->send_message_wait_response('engine.status', undef, undef, module => $module);
	my $r = [ ];
	foreach my $line(split(/[\r\n]+/, $text)) {
		push @$r, _parse_status($line, 1);
	}
	return $r;
}

# === sconnect ===

sub sconnect
{
	my $self = shift;
	my($caller, $called, $linehint) = @_;
	my %params = (
		from => $caller,
		to => $called,
	);
	$params{linehint} = $linehint if defined $linehint;
	my $retval = $self->send_message_wait_response('call.sconnect', undef, undef, %params);
	return $retval;
}

sub transfer
{
	my $self = shift;
	my($chan, $num, $caller, $billid) = @_;
	$log->debug("Switching $chan to $num");
if(0) {
	$self->yate->message('chan.masquerade', undef, undef,
		id => $chan,
		message => 'call.execute',
		callto => 'lateroute/'.$num,
		called => $num,
		billid => $billid,
	);
} else {
	$self->yate->message('chan.masquerade', undef, undef,
		id => $chan,
		message => 'call.execute',
		callto => 'fork',
		'callto.1' => 'tone/ring',
		'callto.1.fork.calltype' => 'persistent',
		'callto.1.fork.autoring' => 'true',
		'callto.1.fork.automessage' => 'call.progress',
		'callto.2' => 'lateroute/'.$num,
		called => $num,
		billid => $billid,
	);
}
}

=head1 NAME

Dyatel::Model::Yate - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Vasily i. Redkin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
