package Dyatel::Controller::A::Morenums;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::A::Morenums - Catalyst Controller

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

sub create :Local :Args(0)
{
	my($self, $c) = @_;
	if($c->request->params->{save}) {
		my $o = $c->model('DB::Morenums')->create(get_item_params($c));
		my $id = $o->{id};
		$c->response->redirect($c->uri_for($self->action_for('list'), {status_msg => "Added"}));
		$c->stash(data => $o);
	}
}

sub list :Local
{
	my($self, $c) = @_;
	my $opts = {join => 'numkind', prefetch => 'numkind', order_by => 'sortkey, me.id'};
	my $where = { };
	$where->{uid} = $c->request->params->{uid} if $c->request->params->{uid};
	$c->stash(rows => [$c->model('DB::Morenums')->search($where, $opts)], template => 'morenums/list.tt');
}

sub item :Path Args(1)
{
	my($self, $c, $id) = @_;
	my $o = $c->model('DB::Morenums')->find($id);
	unless($o) {
		$c->response->body('Item not found');
		$c->response->status(404);
		return;
	}
	if($c->request->params->{save}) {
		$o->update(get_item_params($c));
		$c->response->status(303);
		return $c->response->redirect('/'.$c->request->path);
	} elsif($c->request->params->{delete}) {
		return $c->response->redirect($c->uri_for($self->action_for('delete'), { id => $o->id }));
	}
	$c->stash(data => $o);
}

sub get_item_params
{
	my($c) = @_;
	return {
		uid => $c->request->params->{uid},
		div_offline => $c->request->params->{div_offline},
		sortkey => $c->request->params->{sortkey},
		val => $c->request->params->{val},
		timeout => $c->request->params->{timeout},
		descr => $c->request->params->{descr},
		div_noans => $c->request->params->{div_noans},
		numkind => $c->request->params->{numkind},
	};
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
