package Dyatel::Controller::F;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::F - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub auto :Private
{
	my ( $self, $c ) = @_;
	unless(grep { $_ eq 'finance' } @{ $c->stash->{badges} }) {
		$c->response->status(403);
		my $msg = 'User '.$c->user->username.' is not admin';
		$c->log->error($msg." (".$c->request->method." request for /".$c->request->path." from ".$c->request->address.")");
		$c->response->body($msg);
		return 0;
	}
	return 1;
}

sub index :Path Args(0) {
	my( $self, $c ) = @_;

	my $jsredir = << "***";
<html><head>
 <script type="text/javascript">
  document.location = "/f/spa";
 </script>
</head><body>
 <noscript>
  <h1>JavaScript not detected</h1>
	<p>Javascript support is required.</p>
 </noscript>
</body></html>
***
	$c->response->body( $jsredir );
}

sub spa :Local {
	my($self, $c) = @_;
	$c->stash(template => 'spa.tt', no_wrapper => 1, prefix => 'f-');
}

sub _typical_ctrlr
{
	my($c, $model, $searchopts, $actions) = @_;
	$searchopts ||= [] unless $searchopts;
	if($c->request->method eq 'POST') {
		my $params = $c->request->params;
		my $id = delete $params->{id};
		my $action = delete $params->{action};
		if($action eq 'save') {
			my $o;
			if($id =~ /^\d+$/) {
				$o = $c->model($model)->find($id);
				$o->update($params);
			} elsif($id eq 'new') {
				$o = $c->model($model)->create($params);
			}
			$c->stash(obj => $o);
		} elsif($action eq 'delete') {
			if($id =~ /^\d+$/) {
				$c->model($model)->find($id)->delete;
			}
		} elsif($actions && $actions->{$action}) {
			$actions->{$action}->($c, $id, $action, $params);
		} else {
			$c->response->body( 'Bad request (unknown action)' );
			$c->response->status(400);
		}
	} else {
		$c->stash(rows => [$c->model($model)->search(@$searchopts)]);
	}
}

sub prices :Local :Args(0)
{
	my($self, $c) = @_;
	_typical_ctrlr($c, 'DB::Prices', [{}, {order_by => 'pref'}]);
}

sub users :Local :Args(0)
{
	my($self, $c) = @_;
#	$c->stash(rows => [$c->model('DB::Users')->search(undef, { columns => ['id', 'num', 'descr', 'fingrp'], order_by => 'num' })]);
	my $cursor = $c->model('DB::Users')->search(undef, { columns => ['id', 'num', 'descr', 'fingrp'], order_by => 'num' })->cursor;
	my @rows;
	while(my @vals = $cursor->next) {
		push @rows, \@vals;
	}
	$c->stash(rows => \@rows);
}

sub groups :Local :Args(0)
{
	my($self, $c) = @_;
	_typical_ctrlr($c, 'DB::Fingroups', [{}, {order_by => 'sortkey, name'}], {
		setGroup => sub {
			my($c, $id, $action, $params) = @_;
			my $u = $c->model('DB::Users')->find($params->{uid});
			$u->update({fingrp => $params->{grp}||undef});
		},
	});
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
