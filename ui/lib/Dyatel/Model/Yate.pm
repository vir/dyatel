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
