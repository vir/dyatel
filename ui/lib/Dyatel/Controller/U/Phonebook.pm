package Dyatel::Controller::U::Phonebook;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::U::Phonebook - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Dyatel::Controller::U::Phonebook in U::Phonebook.');
}

sub search :Local
{
	my($self, $c) = @_;
	my %opts = (
		uid => $c->stash->{uid},
	);
	foreach my $k(qw( loc pvt com more )) {
		$opts{$k} = $c->request->params->{$k};
	}
	my $res = $c->model('DB')->xsearch($c->request->params->{q}, \%opts);
	$c->stash(result => $res);
}

sub info :Local Args(1)
{
	my($self, $c, $num) = @_;
	my $res = $c->model('DB')->xinfo($num, { uid => $c->stash->{uid} });
	unless(@$res) {
		$c->response->status(404);
		$c->response->body('Unknown number');
		$c->detach;
	}
	if($res->[0]->{uid}) {
		my $a = $c->model('FS::Avatars')->get($res->[0]->{uid});
		$res->[0]->{avatar} = $a if $a;
	}
	$c->stash(result => $res);
}

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
