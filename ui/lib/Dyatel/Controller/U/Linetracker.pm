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

sub devices :Local
{
	my($self, $c) = @_;
	my $opts = { order_by => 'ts DESC', columns => [qw( ts location expires device driver ip_transport ip_host ip_port audio )]};
	my $where = { userid => $c->stash->{uid} };
	$c->stash(rows => [$c->model('DB::Regs')->search($where, $opts)]);
}

sub status :Local :Args(1)
{
	my($self, $c, $num) = @_;
	my $data = $c->model('DB')->num_status($num);
	$c->stash(data => $data);
}



__PACKAGE__->meta->make_immutable;

1;



