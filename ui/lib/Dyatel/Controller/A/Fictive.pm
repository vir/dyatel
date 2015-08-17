package Dyatel::Controller::A::Fictive;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::A::Fictive - Catalyst Controller

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
	my @rows = $c->model('DB::Directory')->search({ numtype => 'fictive' }, { order_by => 'num', columns => [qw/num is_prefix descr/] });
	$c->stash(rows => \@rows);
}

sub create :Local Args(0)
{
	my($self, $c) = @_;
	eval {
		$c->model('DB::Directory')->create({
			num => $c->request->params->{num},
			descr => $c->request->params->{descr},
			is_prefix => $c->request->params->{is_prefix},
			numtype => 'fictive',
		});
	};
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

sub num :Path :Args(1) {
	my($self, $c, $num) = @_;
	my $o = $c->model('DB::Directory')->find($num);
	unless($o) {
		$c->response->body('Item not found');
		$c->response->status(404);
		return;
	}
	if($c->request->method eq 'POST') {
		my $action = $c->request->params->{action} || '';
		if($action eq 'delete') {
			$o->delete;
			return $c->response->redirect($c->uri_for('list'));
		} else { # save
#			my $scope_guard = $c->model('DB')->txn_scope_guard;
			return unless $c->forward('/a/directory/update', [$o->num, 'fictive']);
			$o->update({
				num => $c->request->params->{num},
				descr => $c->request->params->{descr},
				is_prefix => $c->request->params->{is_prefix},
			});
#			$scope_guard->commit;
			$c->response->redirect('/'.$c->request->path);
		}
	} else { # GET ?
		$c->stash(obj => $o);
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
