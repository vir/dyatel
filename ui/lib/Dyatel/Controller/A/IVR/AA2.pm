package Dyatel::Controller::A::IVR::AA2;
use Moose;
use namespace::autoclean;
use constant MODELCLASS => 'DB::IvrAa2';

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::A::IVR::AA2 - Catalyst Controller

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
		my $scope_guard = $c->model('DB')->txn_scope_guard;
		$o->delete;
		$o->num->delete;
		$scope_guard->commit;
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
	foreach my $k(qw( num assist etimeout numlen prompt )) { # scalars
		my $v = $c->request->params->{$k};
		$x->{$k} = (defined($v) && (length($v) || ref($v))) ? $v : undef;
	}
	foreach my $k(qw( numtypes timeout )) { # array
		my $v = $c->request->params->{$k.'[]'};
		$x->{$k} = $v if $v;
	}
	foreach my $k(qw( 1 2 3 4 5 6 7 8 9 * 0 # )) { # digits
		my $v = $c->request->params->{"shortnum[$k]"};
		$x->{shortnum}{$k} = $v if defined $v && length $v;
	}
	return $x;
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

