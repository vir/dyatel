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

sub index :Path Args(0) {
    my ( $self, $c ) = @_;
		$c->response->redirect($c->uri_for($self->action_for('list')));
}

sub list :Local Args(0)
{
	my($self, $c) = @_;
	$c->stash(list => [$c->model('DB::Schedules')->all]);
}

sub schedule :Path Args(1)
{
	my($self, $c, $id) = @_;
	my $s;
	if($id eq 'new' and $c->request->method eq 'POST') {
		$s = $c->model('DB::Schedules')->create($c->request->params);
	} else {
		$s = ($id =~ /^\d+$/) ? $c->model('DB::Schedules')->find($id) : $c->model('DB::Schedules')->find({name => $id});
		if($c->request->method eq 'POST') {
			$s->update($c->request->params);
		} elsif($c->request->method eq 'DELETE') {
			$s->delete;
			$c->response->redirect($c->uri_for(''));
			$c->response->status(303);
			$c->detach;
		}
	}
	my $opts = { order_by => 'prio DESC, mday DESC, tstart DESC' };
	my $where = { };
	$c->stash(item => $s, rows => [$s->schedtables->search($where, $opts)]);
}

sub row :Path Args(2)
{
	my($self, $c, $sid, $rid) = @_;
	die "Invalid schedule id" unless $sid =~ /^\d+$/;
	my $table = $c->model('DB::Schedules')->find($sid)->schedtables;
	my $update;
	if($c->request->method eq 'POST') {
		$update = $c->request->params;
		if(defined $update->{'dow[]'}) {
			my $dow = delete $update->{'dow[]'};
			$update->{dow} = ref($dow) ? $dow : [$dow];
		}
		$update->{mday} = undef unless $update->{mday};
	}
	my $o;
	if($rid eq 'new' && $update) {
		$o = $table->create($update);
	} else {
		die "Invalid id" unless $sid =~ /^\d+$/ && $rid =~ /^\d+$/;
		$o = $table->find($rid);
		if($c->request->method eq 'POST') {
			$o->update($update);
		} elsif($c->request->method eq 'DELETE') {
			$o->delete;
		} elsif($c->request->method ne 'GET' and $c->request->method ne 'HEAD') {
			die 'Invalid method in request';
		}
	}
	$c->stash(row => $o);
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
