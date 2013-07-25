package Dyatel::Model::FS::ProvisionTpls;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

=head1 NAME

Dyatel::Model::FS::ProvisionTpls - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Vasily i. Redkin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->mk_accessors(qw|context|); # at the top
sub ACCEPT_CONTEXT {
	my ($self, $c, @args) = @_;
	$self->context($c);
	return $self;
}

sub list
{
	my $self = shift;
	my $c = $self->context;
	my $p = $c->config->{Provision}{templates};
	my @l = sort map { s#^.*/##; s#\.conf$##; $_ } glob("$p/*.conf");
	return \@l;
}

__PACKAGE__->meta->make_immutable;

1;
