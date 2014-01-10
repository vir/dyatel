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

sub prices :Local :Args(0)
{
	my($self, $c) = @_;
	if($c->request->method eq 'POST') {
		my $params = $c->request->params;
		my $id = delete $params->{id};
		my $action = delete $params->{action};
		if($action eq 'save') {
			my $o;
			if($id =~ /^\d+$/) {
				$o = $c->model('DB::Prices')->find($id);
				$o->update($params);
			} elsif($id eq 'new') {
				$o = $c->model('DB::Prices')->create($params);
			}
			$c->stash(obj => $o);
		} elsif($action eq 'delete') {
			if($id =~ /^\d+$/) {
				$c->model('DB::Prices')->find($id)->delete;
			}
		}
	} else {
		$c->stash(rows => [$c->model('DB::Prices')->search({}, {order_by => 'pref'})]);
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
