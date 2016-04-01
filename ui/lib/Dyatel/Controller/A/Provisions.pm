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
	$c->stash(rows => [$c->model('DB::Provision')->search($where, $opts)], params => $c->request->params, template => 'provisions/list.tt');
}

sub show :Path Args(1)
{
	my($self, $c, $id) = @_;
	my $o = $c->model('DB::Provision')->find($id);
	$c->stash(obj => $o);
	$c->stash(tpls => $c->model('FS::ProvisionTpls')->list);
	if($c->request->params->{save}) {
		$o->update({ hw => $c->request->params->{hw}, devtype => $c->request->params->{devtype} });
		return $c->response->redirect('/'.$c->request->path);
	} elsif($c->request->params->{delete}) {
		$o->delete;
		return $c->response->redirect($c->uri_for($self->action_for('list')));
	}
	$c->stash(template => 'provisions/show.tt');
}

sub create :Local :Args(0)
{
	my($self, $c) = @_;
	my $uid = $c->request->params->{uid};
	die unless $uid;
	my $u = $c->model('DB::Users')->find($uid);
	$c->stash(obj => { uid => $u });
	$c->stash(tpls => $c->model('FS::ProvisionTpls')->list);
	if($c->request->params->{save}) {
		my $o = $c->model('DB::Provision')->create( { uid => $uid, hw => $c->request->params->{hw}, devtype => $c->request->params->{devtype} } );
		return $c->response->redirect($c->uri_for($self->action_for('list', $o->id)));
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
