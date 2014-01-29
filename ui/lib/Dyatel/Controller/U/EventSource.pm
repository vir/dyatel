package Dyatel::Controller::U::EventSource;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::U::EventSource - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->response->body('Matched Dyatel::Controller::U::EventSource in U::EventSource.');
}

sub Go :Path :Args(1)
{
	my($self, $c) = @_;
	eval {
		my $s = $c->model('DB::Sessions')->create({uid => $c->stash->{uid}, events => [ 'linetracker' ]});
# TODO: store lastEventId & r parameters
		my $u = $c->uri_for("/".$s->token);
		$u->port(8080);
		warn "Ridrecting to $u ".ref($u);
		$c->response->redirect($u);
	};
	if($@) {
		$c->response->status(400);
		my $msg = 'Session creation error: '.$@;
		$c->response->body($msg);
		$c->detach;
		warn "$msg\n";
		return undef;
	}
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
