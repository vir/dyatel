package Dyatel::Controller::Users;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::Users - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Dyatel::Controller::Users in Users.');
}


=head1 AUTHOR

Vasily i. Redkin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

sub list :Local
{
	my($self, $c) = @_;
	$c->stash(users => [$c->model('DB::Users')->all], template => 'users/list.tt');
}

sub user :LocalRegex('^(\d+)$')
{
	my($self, $c) = @_;
	my $uid = $c->req->captures->[0];
warn "UID: $uid";
	$c->stash(user => $c->model('DB::Users')->find({id => $uid}), template => 'users/user.tt');
}

__PACKAGE__->meta->make_immutable;

1;
