package Dyatel::Controller::A::IVR::MD;
use Moose;
use namespace::autoclean;
use constant MODELCLASS => 'DB::IvrMinidisa';

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::A::IVR::MD - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
	my ( $self, $c ) = @_;
	$c->response->redirect($c->uri_for($self->action_for('list')));
}

sub list :Local
{
	my($self, $c) = @_;
	my $opts = {
		prefetch => ['num', {num=>'numtype'}],
		order_by => 'num.num',
	};
	my $where = { };
	$c->stash(rows => [$c->model(MODELCLASS)->search($where, $opts)]);
}

sub create :Local :Args(0)
{
	my($self, $c) = @_;
	if($c->request->method eq 'POST') {
		my $scope_guard = $c->model('DB')->txn_scope_guard;
		return unless $c->forward('/a/directory/create', ['ivr']);
		my $o = $c->model(MODELCLASS)->create(get_item_params($c));
		$scope_guard->commit;
		$c->response->redirect($o->id);
		$c->detach;
	}
}

sub delete :Local :Args(0)
{
	my($self, $c) = @_;
	my $id = $c->request->params->{id};
	my $o = $c->model(MODELCLASS)->find({id => $id});
	if($c->request->method eq 'POST' && $id) {
		if($c->request->params->{cancel}) {
			return $c->response->redirect($id);
		}
		$o->delete;
		$c->response->redirect($c->uri_for($self->action_for('list'), { status_msg => "Deleted" }));
	}
	$c->stash(obj => $o);
}

sub item :Path Args(1)
{
	my($self, $c, $id) = @_;
	my $o = $c->model(MODELCLASS)->find($id);
	unless($o) {
		$c->response->body('Item not found');
		$c->response->status(404);
		return;
	}
	my $a = $c->request->params->{action} || '';
	if($a eq 'save') {
		my $scope_guard = $c->model('DB')->txn_scope_guard;
		return unless $c->forward('/a/directory/update', [$o->num->num, 'ivr']);
		$o->update(get_item_params($c));
		$scope_guard->commit;
		$c->response->redirect('/'.$c->request->path);
	} elsif($a eq 'delete') {
		$c->response->redirect($c->uri_for($self->action_for('delete'), { id => $o->id }));
	} else {
		$c->stash(obj => $o);
	}
}

sub get_item_params
{
	my($c) = @_;
	return {
		num => $c->request->params->{num},
#		descr => $c->request->params->{descr},
		firstdigit => $c->request->params->{firstdigit},
		numlen => $c->request->params->{numlen},
		prompt => $c->request->params->{prompt},
		timeout => $c->request->params->{timeout},
		etimeout => $c->request->params->{etimeout},
	};
}


=head1 AUTHOR

Vasily i. Redkin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
