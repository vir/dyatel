package Dyatel::Controller::A::IVR::AA;
use Moose;
use namespace::autoclean;
use constant MODELCLASS => 'DB::IvrAa';

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::A::IVR::AA - Catalyst Controller

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
	if($c->request->method eq 'POST') {
		my $a = $c->request->params->{action} || '';
		if($a eq 'delete') {
			return $c->response->redirect($c->uri_for($self->action_for('delete'), { id => $o->id }));
		} else { # save
			my $scope_guard = $c->model('DB')->txn_scope_guard;
			return unless $c->forward('/a/directory/update', [$o->num->num, 'ivr']);
			$o->update(get_item_params($c));
			$scope_guard->commit;
			$c->response->redirect('/'.$c->request->path);
		}
	} else { # GET ?
		$c->stash(obj => $o);
	}
}

sub get_item_params
{
	my($c) = @_;
	my $x = { };
	foreach my $k(qw( e0  e2 e3 e4 e5 e6 e7 e8 e9 ehash estar etimeout num prompt timeout )) { # no 'id' and 'descr'
		my $v = $c->request->params->{$k};
		$x->{$k} = (defined($v) && length($v)) ? $v : undef;
	}
	return $x;
}


=head1 AUTHOR

Vasily i. Redkin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
