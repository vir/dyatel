package Dyatel::Controller::U::Phonebook;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::U::Phonebook - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Dyatel::Controller::U::Phonebook in U::Phonebook.');
}

sub search :Local
{
	my($self, $c) = @_;
	my $res = $c->model('DB')->xsearch($c->request->params->{q});
	$c->stash(result => $res);
}

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
