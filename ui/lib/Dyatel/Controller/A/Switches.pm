package Dyatel::Controller::A::Switches;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::A::Switches - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path Args(0) {
    my ( $self, $c ) = @_;
		$c->response->redirect($c->uri_for($self->action_for('list')));
}

sub list :Local Args(0)
{
	my($self, $c) = @_;
	$c->stash(rows => [$c->model('DB::Switches')->search({}, {order_by => 'num'})], template => 'switches/list.tt');
}

sub switch :Path Args(1)
{
	my($self, $c, $id) = @_;
	if($id =~ /^\d+$/) {
		my $s = $c->model('DB::Switches')->find($id);
		my $data = [$s->switch_cases->search({}, { columns => [qw/ value route comments /], order_by => 'id' })];
		$c->stash(switch => $s, cases => $data);
		$c->forward('show');
	} else {
		die "invalid switch id $id";
	}
}

sub show :Private
{
	my($self, $c) = @_;
	$c->stash(template => 'switches/show.tt');
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
