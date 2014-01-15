package Dyatel::Controller::A::Schedule;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::A::Schedule - Catalyst Controller

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
	my $opts = { order_by => 'prio DESC, mday DESC, tstart DESC' };
	my $where = { };
	$c->stash(rows => [$c->model('DB::Schedule')->search($where, $opts)]);
}

sub one :Path Args(1)
{
	my($self, $c, $id) = @_;
	die "Invalid id $id" unless $id =~ /^\d+$/;
	my $o = $c->model('DB::Schedule')->find($id);
	if($c->request->method eq 'POST') {
		$o->update($c->request->params);
	}
	$c->stash(obj => $o);
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
