package Dyatel::Model::FS::Avatars;
use Moose;
use namespace::autoclean;
use MooseX::Types::Moose qw/ArrayRef HashRef CodeRef Str ClassName/;
extends 'Catalyst::Model';

has directory => (is => 'rw', isa => Str, default => sub { Dyatel->config->{root}.'/avatars' });

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
	my $path = $self->directory . "/user_$uid.png";
warn "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX avatar: $path XXXXXXXXXXXXXXXXXXXXXXX\n";
	return undef unless -f $path;
	return "/avatars/user_$uid.png";
}

__PACKAGE__->meta->make_immutable;

1;
