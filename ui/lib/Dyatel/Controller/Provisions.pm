package Dyatel::Controller::Provisions;
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
#    $c->response->body('Matched Dyatel::Controller::Provisions in Provisions.');
		$c->response->redirect($c->uri_for($self->action_for('list')));
}

sub list :Local
{
	my($self, $c) = @_;
	$c->stash(rows => [$c->model('DB::Provision')->search({}, {join => 'uid', prefetch => 'uid', order_by => 'hw'})], template => 'provisions/list.tt');
}

sub provisions :Chained('/') :PathPart('provisions') :CaptureArgs(1)
{
	my($self, $c, $id) = @_;
	warn "Dyatel::Controller::Provisions::base($self, $c, $id)\n";
	$c->log->debug("Dyatel::Controller::Provisions::base($self, $c, $id)");
	$c->stash(obj => $c->model('DB::Provision')->find($id), tpls => $c->model('FS::ProvisionTpls')->list);
}

use Data::Dumper;

sub show :Chained('provisions') PathPart('') Args(0)
{
	my($self, $c) = @_;
	if($c->request->params->{save}) {
		my $o = $c->stash->{obj};
		$o->update({ hw => $c->request->params->{hw}, devtype => $c->request->params->{devtype} });
		$c->response->redirect('/'.$c->request->path);
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
