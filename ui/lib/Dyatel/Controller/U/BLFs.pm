package Dyatel::Controller::U::BLFs;
use Moose;
use namespace::autoclean;
use constant MODELCLASS => 'DB::Blfs';

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::U::BLFs - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Dyatel::Controller::U::BLFs in U::BLFs.');
}

sub list :Local Args(0)
{
	my($self, $c) = @_;
		ts => { '>', '2013-11-18' },
	$c->stash(rows => [$c->model(MODELCLASS)->search({uid => { '=', $c->stash->{uid}}}, { columns=>[qw/ id key num label /], order_by => ['key'] })]);
}

sub create :Local :Args(0)
{
	my($self, $c) = @_;
	if($c->request->method eq 'POST') {
		my $o = $c->model(MODELCLASS)->create(get_item_params($c));
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
		uid => $c->stash->{uid},
		key => $c->request->params->{key},
		num => $c->request->params->{num},
		label => $c->request->params->{label} || undef,
	};
	foreach my $k(keys %$x) {
		$x->{$k} = undef if $x->{$k} eq '';
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
