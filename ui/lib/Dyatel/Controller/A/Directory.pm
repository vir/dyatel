package Dyatel::Controller::A::Directory;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::A::Directory - Catalyst Controller

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

sub list :Local Args(0)
{
	my($self, $c) = @_;
	my $cursor = $c->model('DB::Directory')->search(undef, { order_by => 'num' })->cursor;
	my @rows;
	while(my @vals = $cursor->next) {
		push @rows, \@vals;
	}
	$c->stash(rows => \@rows);
}

sub types :Local Args(0)
{
	my($self, $c) = @_;
	my $cursor = $c->model('DB::Numtypes')->search(undef, { order_by => 'numtype' })->cursor;
	my @rows;
	while(my @vals = $cursor->next) {
		push @rows, \@vals;
	}
	$c->stash(rows => \@rows);
}

sub conflicts :Local Args(1)
{
	my($self, $c, $num) = @_;
	my $list = $c->model('DB')->dir_conflict($num);
	$c->stash(conflicts => $list);
}

sub create :Private
{
	my($self, $c, $numtype) = @_;
	my $params = {
		num => $c->request->params->{num},
		descr => $c->request->params->{descr},
		numtype => $numtype || $c->request->params->{numtype},
	};
	eval { $c->model('DB::Directory')->create($params); };
	if($@) {
		$c->response->status(400);
		my $msg = 'Directory number insertion failed';
		if($@ =~ /ERROR:\s*([\w\d\s,:-]+)/s) {
			$msg .= ': ';
			$msg .= $1;
		} else {
			$msg .= ': ';
			$msg .= $@;
		}
		$c->response->body($msg);
		warn "$msg\n";
		$c->detach;
		return undef;
	}
	return '0 but true';
}

sub update :Private
{
	my($self, $c, $num, $numtype) = @_;
	my $d = $c->model('DB::Directory')->find($num);

	my $params = { };
	$params->{num} = $c->request->params->{num} unless $d->num eq $c->request->params->{num};
	$params->{descr} = $c->request->params->{descr} unless $d->descr eq $c->request->params->{descr};
	$params->{numtype} = $numtype || $c->request->params->{numtype} unless $d->numtype eq $numtype || $c->request->params->{numtype};

	eval { $d->update($params); };
	if($@) {
		$c->response->status(400);
		my $msg = 'Directory number update failed: '.$@;
		$c->response->body($msg);
		warn "$msg\n";
		$c->detach;
		return undef;
	}
	return '0 but true';
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
