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
	my $s;
	my %params = map { $_ => $c->request->params->{$_} } qw( num param arg defroute );
	if($id eq 'new' and $c->request->method eq 'POST') {
		my $scope_guard = $c->model('DB')->txn_scope_guard;
		return unless $c->forward('/a/directory/create', ['switch']);
		$s = $c->model('DB::Switches')->create(\%params);
		$scope_guard->commit;
		$c->response->redirect($s->id);
		return $c->detach;
	}
	die "invalid switch id $id" unless $id =~ /^\d+$/;
	delete $params{num}; # we do not update nums!
	$s = $c->model('DB::Switches')->find($id);
	if($c->request->method eq 'POST') {
		my $scope_guard = $c->model('DB')->txn_scope_guard;
		return unless $c->forward('/a/directory/update', [$s->num->num, 'switch']);
		$s->update(\%params);
		$scope_guard->commit;
	} elsif($c->request->method eq 'DELETE') {
		my $scope_guard = $c->model('DB')->txn_scope_guard;
		$s->delete;
		return unless $c->forward('/a/directory/delete', [$s->num->num, 'switch']);
		$c->response->redirect($c->uri_for(''));
		$c->response->status(303);
		$scope_guard->commit;
		return $c->detach;
	}
	my $data = [$s->switch_cases->search({}, { columns => [qw/ id value route comments /], order_by => 'id' })];
	$c->stash(switch => $s, cases => $data);
	$c->forward('show');
}

sub case :Path Args(2)
{
	my($self, $c, $switch, $case) = @_;
	my $sc = $c->model('DB::Switches')->find($switch)->switch_cases;
	my $s;
	if($case eq 'new' and $c->request->method eq 'POST') {
		$s = $sc->create($c->request->params);
	} else {
		$s = $sc->find($case);
		if($c->request->method eq 'POST') {
			$s->update($c->request->params);
		} elsif($c->request->method eq 'DELETE') {
			$s->delete;
			$c->response->redirect($c->uri_for(''));
			$c->response->status(303);
			$c->detach;
		}
	}
	$c->stash(row => $s);
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
