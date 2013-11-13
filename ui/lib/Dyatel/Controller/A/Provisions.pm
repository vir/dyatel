package Dyatel::Controller::A::Provisions;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::Provisions - Catalyst Controller

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
	my $opts = {join => 'uid', prefetch => 'uid', order_by => 'hw'};
	my $where = { };
	$where->{uid} = $c->request->params->{uid} if $c->request->params->{uid};
	$c->stash(rows => [$c->model('DB::Provision')->search($where, $opts)], template => 'provisions/list.tt');
}

sub show :Path Args(1)
{
	my($self, $c, $id) = @_;
	my $o = $c->model('DB::Provision')->find($id);
	$c->stash(obj => $o);
	$c->stash(tpls => $c->model('FS::ProvisionTpls')->list);
	if($c->request->params->{save}) {
		my $o = $c->stash->{obj};
		$o->update({ hw => $c->request->params->{hw}, devtype => $c->request->params->{devtype} });
		$c->response->redirect('/'.$c->request->path);
	} elsif($c->request->params->{delete}) {
		$c->response->redirect($c->uri_for($self->action_for('delete'), { id => $o->id }));
	}
	$c->stash(template => 'provisions/show.tt');
}


=head1 AUTHOR

Vasily i. Redkin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
