#!/usr/bin/perl -w
#
# (c) vir
#
# Last modified: 2016-02-06 01:07:12 +0300
#

use strict;
use warnings FATAL => 'uninitialized';
use lib 'lib';
use Yate::Async;
use AnyEvent;
use Time::HiRes qw/ time sleep /;

my(@res_sync, @res_async);
for(my $i = 0; $i < 200; ++$i) {
	my_sleep(rand);
	if($i % 2) {
		push @res_async, try(1);
	} else {
		push @res_sync, try(0);
	}
	show_stat(\@res_sync, 'Sync');
	show_stat(\@res_async, 'Async');
}

sub try
{
	my $time = time();
	my $y = Yate::Async->new({Connect => '127.0.0.1:4444', Role => 'global', Debug => 0});
	#my $y = Yate::Async->new({Debug => 0});
	my $t;
	if($_[0]) {
		$t = AnyEvent->timer(after => 4, cb => sub { warn "timeout"; $y->quit; undef  $t; });
	} else {
		my $cnt = 4;
		$y->install('engine.timer' => sub { warn 'engine.timer'; unless(--$cnt) { $y->quit } });
	}
	$y->listen;
	return time() - $time;
}

sub show_stat
{
	my($a, $label) = @_; local $_;
	return unless @$a;
	my $m = 0;
	$m += $_ foreach @$a;
	$m /= @$a;
	my $d = 0;
	$d += ($_ - $m)*($_ - $m) foreach @$a;
	$d /= @$a;
	my $s = sqrt($d);
	printf "%s: %.2f sigma: %.2f (cnt: %d)\n", $label, $m, $s, scalar(@$a);
}

sub my_sleep
{
	my($t) = @_;
	warn "my_sleep(@_)";
	my $x = AnyEvent->condvar;
	my $g = AnyEvent->timer(after => $t, cb => sub { $x->send; });
	$x->recv;
}


