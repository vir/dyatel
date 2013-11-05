package Dyatel::Controller::A::Users;
use Moose;
use namespace::autoclean;
require Dyatel::Controller::A;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::Users - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

#sub a :Chained('/') :PathPart('a') :CaptureArgs(0)
#{
#	my($self, $c) = @_;
#	$c->stash(adm => 1);
## XXX authorize admin user here
#}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
		$c->response->redirect($c->uri_for($self->action_for('list')));
}


=head1 AUTHOR

Vasily i. Redkin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

sub list :Local Args(0)
{
	my($self, $c) = @_;
	$c->stash(users => [$c->model('DB::Users')->search({}, { order_by => 'num' })], template => 'users/list.tt');
}

sub create :Local :Args(0)
{
	my($self, $c) = @_;
	if($c->request->params->{save}) {
		my $user = $c->model('DB::Users')->create(get_user_params($c));
		my $uid = $user->{id};
		warn "ID: $uid";
		$c->response->redirect($c->uri_for($self->action_for('list'), {status_msg => "User added"}));
	}
	$c->stash(user => {}, template => 'users/user.tt');
}

sub delete :Local :Args(0)
{
	my($self, $c) = @_;
	my $uid = $c->request->params->{uid};
	my $user = $c->model('DB::Users')->find({id => $uid});
	if($c->request->params->{delete}) {
		$user->delete;
		$c->response->redirect($c->uri_for($self->action_for('list'), { status_msg => "User $uid deleted" }));
	} elsif($c->request->params->{cancel}) {
		$c->response->redirect($uid);
	}
	$c->stash(user => $user, template => 'users/delete.tt');
}

use Data::Dumper;
sub show :Path Args(1)
{
	my($self, $c, $id) = @_;
	my $o = $c->model('DB::Users')->find($id);
	if($c->request->params->{save}) {
		$o->update(get_user_params($c));
		$c->response->redirect('/'.$c->request->path);
	} elsif($c->request->params->{delete}) {
		$c->response->redirect($c->uri_for($self->action_for('delete'), { uid => $o->id }));
	}
	$c->stash(user => $o, provision => $o->provisions->all(), template => 'users/user.tt');
#	$c->stash(regs => $o->regs->all); # something wrong with regs XXX TODO sort that out
}

sub get_user_params
{
	my($c) = @_;
	return {
		num => $c->request->params->{num},
		descr => $c->request->params->{descr},
		alias => $c->request->params->{alias} || undef,
		domain => $c->request->params->{domain} // '',
		password => $c->request->params->{password},
		nat_support => $c->request->params->{nat_support} || '0',
		nat_port_support => $c->request->params->{nat_port_support} || '0',
	};
}


__PACKAGE__->meta->make_immutable;

1;
