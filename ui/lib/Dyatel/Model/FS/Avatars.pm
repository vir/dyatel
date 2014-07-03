package Dyatel::Model::FS::Avatars;
use Moose;
use namespace::autoclean;
use MooseX::Types::Moose qw/ArrayRef HashRef CodeRef Str ClassName/;
extends 'Catalyst::Model';
use Data::Dumper;

# Support configuration loading even when used from external script
my $cfg;
eval { $cfg = Dyatel->config->{'Model::FS::Avatars'}; }; # this succeeds if running inside Catalyst
if ($@) # otherwise if called from outside Catalyst try manual load of model configuration
{
	if(eval "require Dyatel::ExtConfig") {
		$cfg = Dyatel::ExtConfig::load()->{Model}{'FS::Avatars'};
	} else { # fallback
		die;
	}
}
__PACKAGE__->config( $cfg ); # put model parameters into main configuration

has fsdir => (is => 'rw', isa => Str, default => sub { my $r = ''; $r = Dyatel->config->{root} if Dyatel->can('config') && Dyatel->config && Dyatel->config->{root}; return $r.'/avatars' });
has webdir => (is => 'rw', isa => Str, default => '/avatars');

=head1 NAME

Dyatel::Model::FS::Avatars - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Vasily i. Redkin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

sub get
{
	my $self = shift;
	my($uid) = @_;
	my $fn = "/user_$uid.png";
	my $path = $self->fsdir.$fn;
	return undef unless -f $path;
	return $self->webdir.$fn;
}

__PACKAGE__->meta->make_immutable;

1;
