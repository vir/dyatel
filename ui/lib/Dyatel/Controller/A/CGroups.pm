package Dyatel::Controller::A::CGroups;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::Groups - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub index :Path Args(0) {
    my ( $self, $c ) = @_;
		$c->response->redirect($c->uri_for($self->action_for('list')));
}

sub list :Local Args(0)
{
	my($self, $c) = @_;
	$c->stash(rows => [$c->model('DB::Callgroups')->search({}, {order_by => 'num'})], template => 'groups/clist.tt');
}

sub grp :Path Args(1)
{
	my($self, $c, $id) = @_;
	if($id =~ /^\d+$/) {
		$c->stash(obj => $c->model('DB::Callgroups')->find($id));
		$c->forward('show');
	} else {
		die "Invalid group id $id";
	}
}

sub show :Private
{
	my($self, $c) = @_;
	$c->stash(template => 'groups/cshow.tt');
}


=head1 AUTHOR

Vasily i. Redkin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

