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
	my $opts = {order_by => 'id'};
	my $where = { };
	$where->{uid} = $c->request->params->{uid} if $c->request->params->{uid};
	$c->stash(rows => [$c->model(MODELCLASS)->search($where, $opts)]);
}

sub create :Local :Args(0)
{
	my($self, $c) = @_;
	if($c->request->params->{save}) {
		my $o = $c->model(MODELCLASS)->create(get_item_params($c));
		my $uid = $o->{id};
		$c->response->redirect($c->uri_for($self->action_for('list'), {status_msg => "Added"}));
	}
}

sub delete :Local :Args(0)
{
	my($self, $c) = @_;
	my $id = $c->request->params->{uid};
	my $o = $c->model(MODELCLASS)->find({id => $id});
	if($c->request->params->{delete}) {
		$o->delete;
		$c->response->redirect($c->uri_for($self->action_for('list'), { status_msg => "Deleted" }));
	} elsif($c->request->params->{cancel}) {
		$c->response->redirect($id);
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
	if($c->request->params->{save}) {
		$o->update(get_item_params($c));
		$c->response->redirect('/'.$c->request->path);
	} elsif($c->request->params->{delete}) {
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
		descr => $c->request->params->{descr},
		alias => $c->request->params->{alias} || undef,
		domain => $c->request->params->{domain} // '',
		password => $c->request->params->{password},
		nat_support => $c->request->params->{nat_support} || '0',
		nat_port_support => $c->request->params->{nat_port_support} || '0',
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
