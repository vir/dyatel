package Dyatel::Model::ConfDefs;
use Moose;
use namespace::autoclean;
use MooseX::Types::Moose qw/ArrayRef HashRef CodeRef Str ClassName/;
use YAML qw/LoadFile/;

extends 'Catalyst::Model';

has path => (is => 'rw', isa => Str);
has obj => (is => 'rw', isa => ArrayRef);

sub reload
{
	my $self = shift;
	my $x = LoadFile($self->path);
	$self->obj($x);
}

sub get
{
	my $self = shift;
	$self->reload unless $self->obj;
	return $self->obj;
}

sub section
{
	my $self = shift;
	my($section) = @_;
	my($x) = grep { $_->{section} eq $section } @{$self->get};
	return $x;
}


=head1 NAME

Dyatel::Model::ConfDefs - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.


=encoding utf8

=head1 AUTHOR

Vasily i. Redkin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
