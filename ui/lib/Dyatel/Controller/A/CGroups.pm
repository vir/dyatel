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
	$c->stash(list => [$c->model('DB::Callgroups')->search({}, {order_by => 'num'})], template => 'groups/clist.tt');
}

sub distributions :Local Args(0)
{
	my($self, $c) = @_;
	$c->stash(ist => $c->model('DB')->list_enum('CALLDISTRIBUTION'), template => 'groups/distrs.tt');
}

sub grp :Path Args(1)
{
	my($self, $c, $id) = @_;
	if($id eq 'new' && $c->request->method eq 'POST') {
		my $scope_guard = $c->model('DB')->txn_scope_guard;
		return unless $c->forward('/a/directory/create', ['callgrp']);
		my %params = %{ $c->request->params };
		delete $params{descr};
		my $g = $c->model('DB::Callgroups')->create(\%params);
		$scope_guard->commit;
		$c->stash(item => $g);
		$c->forward('show');
	} elsif($id =~ /^\d+$/) {
		my $g = $c->model('DB::Callgroups')->find($id);
		if($c->request->method eq 'DELETE') {
			my $scope_guard = $c->model('DB')->txn_scope_guard;
			$g->delete;
			$g->num->delete;
			$scope_guard->commit;
			$c->response->redirect($c->uri_for($self->action_for('list'), { status_msg => "group $id deleted" }));
			return $c->detach;
		}
#		my $m = [$g->callgrpmembers->all];
		my $m = [$g->callgrpmembers->search({}, { columns => [qw/ id num ord enabled maxcall keepring /], order_by => 'ord' })];
		$c->stash(item => $g, rows => $m);
		$c->forward('show');
	} else {
		die "Invalid group id $id";
	}
}

sub member :Path Args(2)
{
	my($self, $c, $gid, $mid) = @_;
	my $members = $c->model('DB::Callgroups')->find($gid)->callgrpmembers;
	my $s;
	if($mid eq 'new' and $c->request->method eq 'POST') {
		$s = $members->create($c->request->params);
	} else {
		$s = $members->find($mid);
		if($c->request->method eq 'POST') {
			$s->update($c->request->params);
		} elsif($c->request->method eq 'DELETE') {
			$s->delete;
			$c->response->redirect($c->uri_for(''));
			$c->response->status(303);
			$c->detach;
		}
	}
	$c->stash(row => $s);
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

