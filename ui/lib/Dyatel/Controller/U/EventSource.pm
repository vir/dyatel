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

# We have to do another dispatching here because catalyst 5.9.15 does not
# know about GET/POST attributes
sub dispatch :Path :Args(1)
{
	my($self, $c, $arg) = @_;
	if($c->request->method eq 'POST') {
		$c->forward('Fire', $arg);
	} else {
		$c->forward('Go', $arg);
	}
}

sub Go :Private # :Path :GET :Args(1)
{
	my($self, $c, $arg) = @_;
	eval {
		my $s = $c->model('DB::Sessions')->create({uid => $c->stash->{uid}, events => [ $arg ]});
# TODO: store lastEventId & r parameters
		my $u = $c->uri_for("/".$s->token);
		$u->scheme($c->config->{EventSource}{scheme}) if $c->config->{EventSource}{scheme};
		$u->host($c->config->{EventSource}{host}) if $c->config->{EventSource}{host};
		$u->port($c->config->{EventSource}{port} || 8080);
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

sub Fire :Private # :Path :POST :Args(1)
{
	my($self, $c, $arg) = @_;
	$c->model('DB')->notify('testevent', $c->stash->{uid});
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
