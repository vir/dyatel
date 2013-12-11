package Dyatel::Controller::A::Status;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::A::Status - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
		$c->response->redirect($c->uri_for($self->action_for('overview')));
}

sub overview : Local
{
	my($self, $c) = @_;
	my $x = $c->model('Yate')->status_overview;
	$c->stash(result => $x);
}

sub detail : Local Args(1)
{
	my($self, $c, $module) = @_;
	my $x = $c->model('Yate')->status_detail($module);
	$c->stash(result => $x);
}


=encoding utf8

=head1 AUTHOR

Vasily i. Redkin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
