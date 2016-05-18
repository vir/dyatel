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

=head2 index

=cut

 
sub index :Path :Args(0)
{
    my ( $self, $c ) = @_;
		$c->response->redirect($c->uri_for($self->action_for('list')));
}

sub user :PathPrefix :Chained(/) :CaptureArgs(1)
{
	my($self, $c, $id) = @_;
	my $o = $c->model('DB::Users')->find($id);
	unless($o) {
		$c->response->body('User not found');
		$c->response->status(404);
		$c->detach;
		return;
	}
	$c->stash(user => $o);
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
	$c->stash(users => [$c->model('DB::Users')->search({}, {
			prefetch => ['num', {num=>'numtype'}, 'fingrp'],
			order_by => 'num.num',
			columns => [qw/id num alias domain dispname login lastreg badges/],
		})], template => 'users/list.tt');
}

sub create :Local :Args(0)
{
	my($self, $c) = @_;
	if($c->request->params->{save}) {
		my $scope_guard = $c->model('DB')->txn_scope_guard;
		return unless $c->forward('/a/directory/create', ['user']);
		my $user = $c->model('DB::Users')->create(get_user_params($c));
		$scope_guard->commit;
		my $uid = $user->id;
		warn "ID: $uid";
		$c->response->redirect($c->uri_for($uid, {status_msg => "User added"}));
	}
	$c->stash(user => {}, template => 'users/user.tt');
}

sub delete :Local :Args(0)
{
	my($self, $c) = @_;
	my $uid = $c->request->params->{uid};
	my $user = $c->model('DB::Users')->find({id => $uid});
	if($c->request->params->{delete}) {
		my $scope_guard = $c->model('DB')->txn_scope_guard;
		$user->delete;
		$user->num->delete;
		$scope_guard->commit;
		$c->response->redirect($c->uri_for($self->action_for('list'), { status_msg => "User $uid deleted" }));
		$c->detach;
	} elsif($c->request->params->{cancel}) {
		$c->response->redirect($uid);
		$c->detach;
	}
	$c->stash(user => $user, template => 'users/delete.tt');
}

sub show :Chained(user) :PathPart('') :Args(0)
{
	my($self, $c) = @_;
	my $o = $c->stash->{user};
	if($c->request->method eq 'POST') {
		if($c->request->params->{delete}) {
			warn "del";
			$c->response->redirect($c->uri_for($self->action_for('delete'), { uid => $o->id }));
			$c->detach;
		} else {
			warn "upd";
			my $scope_guard = $c->model('DB')->txn_scope_guard;
			return unless $c->forward('/a/directory/update', [$o->num->num, 'user']);
			$o->update(get_user_params($c));
			$scope_guard->commit;
			$c->response->redirect('/'.$c->request->path);
		}
	}
	my $avatar = $c->model('FS::Avatars')->get($o->id);
	my $nav = $c->model('DB::Nextprevusers')->search({id => $o->id}, { })->first;
	$c->stash(user => $o, provision => [$o->provisions->all()], navigation => $nav, avatar => $avatar, template => 'users/user.tt');
#	$c->stash(regs => $o->regs->all); # something wrong with regs XXX TODO sort that out
}

sub get_user_params
{
	my($c) = @_;
	my $badges = $c->request->params->{badges};
	$badges = [$badges] if $badges && !ref($badges);
	return {
		num => $c->request->params->{num},
		alias => $c->request->params->{alias} || undef,
		domain => $c->request->params->{domain} // '',
		password => $c->request->params->{password},
#		descr => $c->request->params->{descr},
		nat_support => $c->request->params->{nat_support} || '0',
		nat_port_support => $c->request->params->{nat_port_support} || '0',
		media_bypass => $c->request->params->{media_bypass} || undef,
		dispname => $c->request->params->{dispname} || undef,
		login => $c->request->params->{login} || undef,
		badges => $badges || [ ],
#		fingrp => $c->request->params->{fingrp} || undef,
		secure => $c->request->params->{secure} || 'ssl',
		cti => $c->request->params->{cti} || '0',
		linesnum => $c->request->params->{linesnum} || 1,
	};
}

sub avatar :Chained(user) :Args(0)
{
	my($self, $c) = @_;
	my $o = delete $c->stash->{user};
	if($c->request->method eq 'POST') {
		if($c->request->params->{replace}) {
			$c->model('FS::Avatars')->replace($o->id);
		} elsif($c->request->params->{delete}) {
			$c->model('FS::Avatars')->delete($o->id);
			return $c->stash(avatar => undef);
		} else {
			my $u = $c->request->upload('file');
			warn "Got upload ".$u->basename;
			$c->model('FS::Avatars')->set($o->id, $u->tempname) or die;
		}
	}
	my $avatar = $c->model('FS::Avatars')->get($o->id, 'extended, please');
	$c->stash(avatar => $avatar);
}

__PACKAGE__->meta->make_immutable;

1;
