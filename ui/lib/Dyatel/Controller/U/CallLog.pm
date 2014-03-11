package Dyatel::Controller::U::CallLog;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::U::CallLog - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :PathPrefix :Chained('/') :CaptureArgs(0) { }

sub call :Chained(index) :CaptureArgs(1)
{
	my($self, $c, $billid) = @_;
# TODO Check access!! XXX
	my $m = $c->model('DB::CallLog')->search({billid => $billid});
	$c->stash(billid => $billid, m => $m);
}

sub list :Chained(call) :Args(0)
{
	my($self, $c) = @_;
	$c->stash(rows => [$c->stash->{m}->search({ }, {columns => [qw/ id ts uid tag value /], order_by => [qw/ts/]})->all]);
}

sub record :Chained(call) :Args(1)
{
	my($self, $c, $id) = @_;
	my $o = ($id =~ /^\d+$/) ? $c->stash->{m}->find($id) : undef;
	if($c->request->method eq 'POST') {
		if($o && $o->uid != $c->stash->{uid}) {
			$c->response->status(403);
			$c->response->body('Not yours');
			return $c->detach;
		}
		my $value = $c->request->params->{text};
		if($o && ! length($value)) {
			$o->delete;
			$c->response->status(204);
			$c->response->body('removed');
			return $c->detach;
		}
		my %params = (
			ts => 'now()',
			uid => $c->stash->{uid},
			billid => $c->stash->{billid},
			tag => 'NOTE',
			value => $value,
			params => undef,
		);
		if($o) {
			$o->update(\%params);
		} else {
			$o = $c->model('DB::CallLog')->create(\%params);
		}
	} else {
		unless($o) {
			$c->response->status(404);
			$c->response->body('Record not found');
			return $c->detach;
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
