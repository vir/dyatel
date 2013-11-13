package Dyatel::Controller::A::Regs;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::A::Regs - Catalyst Controller

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
	my $opts = {order_by => 'userid, ts DESC'};
	my $where = { };
	$where->{userid} = $c->request->params->{uid} if $c->request->params->{uid};
	$c->stash(rows => [$c->model('DB::Regs')->search($where, $opts)], template => 'regs/list.tt');
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
