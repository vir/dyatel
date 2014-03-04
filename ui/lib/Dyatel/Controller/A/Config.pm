package Dyatel::Controller::A::Config;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::A::Config - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Dyatel::Controller::A::Config in A::Config.');
}

sub section :Local :Args(1)
{
	my($self, $c, $section) = @_;
	my $o = $c->model('DB::Config')->find({section => $section});
	if($c->request->method eq 'POST') {
		my $d = $c->model('ConfDefs')->section($section);
		my %h;
		foreach my $p(@{ $d->{params} }) {
			my $v = $c->request->params->{$p->{name}};
			next unless defined $v;
			$h{$p->{name}} = $v;
		}
		if($o) {
			$o->update({ uid => $c->stash->{uid}, ts => 'now()', params => \%h });
		} else {
			$o = $c->model('DB::Config')->create({ uid => $c->stash->{uid}, section => $section, params => \%h });
		}
		$c->response->redirect('/'.$c->request->path);
		$c->detach;
	}
	$c->stash(row => $o);
}

sub sections :Local :Args(0)
{
	my($self, $c) = @_;
	my $secs = [$c->model('DB::Config')->get_column('section')->all];
	$c->stash(sections => $secs);
}

sub defs :Local :Args(0)
{
	my($self, $c) = @_;
	my $defs = $c->model('ConfDefs')->get;
	$c->stash(defs => $defs);
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
