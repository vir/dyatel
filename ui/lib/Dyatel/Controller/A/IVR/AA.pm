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
		if($c->request->params->{delete}) {
			return $c->response->redirect($c->uri_for($self->action_for('delete'), { id => $o->id }));
		} else { # save
			$o->update(get_item_params($c));
			$c->response->redirect('/'.$c->request->path);
		}
	} else { # GET ?
		$c->stash(obj => $o);
	}
}

sub get_item_params
{
	my($c) = @_;
	my $x = {
		descr => $c->request->params->{descr},
		e0 => $c->request->params->{e0},
		e1 => $c->request->params->{e1},
		e2 => $c->request->params->{e2},
		e3 => $c->request->params->{e3},
		e4 => $c->request->params->{e4},
		e5 => $c->request->params->{e5},
		e6 => $c->request->params->{e6},
		e7 => $c->request->params->{e7},
		e8 => $c->request->params->{e8},
		e9 => $c->request->params->{e9},
		ehash => $c->request->params->{ehash},
		estar => $c->request->params->{estar},
		etimeout => $c->request->params->{etimeout},
#		id => $c->request->params->{id},
		num => $c->request->params->{num},
		prompt => $c->request->params->{prompt},
		timeout => $c->request->params->{timeout},
	};
	foreach my $k(keys %$x) {
		$x->{$k} = undef if $x->{$k} eq '';
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
