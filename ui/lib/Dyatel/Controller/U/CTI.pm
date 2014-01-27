package Dyatel::Controller::U::CTI;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::U::CTI - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Dyatel::Controller::CTI in CTI.');
}

sub test : Local
{
	my($self, $c) = @_;
	my $x = $c->model('Yate')->testcall;
	$c->response->body($x);
}

sub call : Local
{
	my($self, $c) = @_;
	my $u = $c->model('DB::Users')->find($c->stash->{uid});
	my $x = $c->model('Yate')->sconnect($u->num->num, $c->request->params->{called}, $c->request->params->{linehint});
	$c->stash(result => $x);
}

sub blfs : Local
{
	my($self, $c) = @_;
	my $rows = $c->model('DB')->user_blfs($c->stash->{uid});
	$c->stash(rows => $rows);
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
