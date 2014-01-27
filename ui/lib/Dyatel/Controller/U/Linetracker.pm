package Dyatel::Controller::U::Linetracker;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub list :Path
{
	my($self, $c) = @_;
	my $m = $c->model('DB::Linetracker')->search({uid => $c->stash->{uid}}, {columns => [qw/direction status chan caller called billid/]});
	$c->stash(rows => [$m->all]);
}

__PACKAGE__->meta->make_immutable;

1;



