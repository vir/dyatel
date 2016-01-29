#!/usr/bin/perl -w
#
# (c) vir
#
# Last modified: 2016-01-28 23:56:49 +0300
#

use strict;
use warnings FATAL => 'uninitialized';
use FindBin;
use lib "$FindBin::Bin/..";
use Yate::Module;
use Test::More tests => 1;


my $yate = new Yate(Debug=>0);
$yate->connect('127.0.0.1:4444', 'global');
my $m = new_ok 'Yate::Module', [$yate];
$m->handle_command('hello here', sub { return 'i am here' });
$m->handle_command('hello there', sub { return 'i am there' });
$m->handle_command('hello here and there', sub { return 'i am averywhere' });
#$m->unhandle_command('hello there');
#$m->unhandle_command('hello here and there');
#$m->unhandle_command('hello here');

$m->handle_debug(sub { return "Got debug(@_)" });
$m->handle_status(sub { return 'XXX' });

$yate->listen();

#sub on_engine_status
#{
#	my $msg = shift;
#	my $name = $0;
#	$name =~ s#.*/##;
#	$name =~ s/\.pl$//;
#	my $mystatus = '';
#	if($name eq ($msg->param('module') || $name)) {
#		$mystatus = "name=$name,type=ext,format=caller|callerid|called|calledid;";
#		$mystatus .= "calls=$count_all,connected=$count_connected,active=".scalar(keys(%calls));
#		if(($msg->param('details')||'') ne 'false') {
#			$mystatus .= ",calls=".scalar(keys(%calls)). ",byid=".scalar(keys(%byid));
#			my $sep = ';';
#			foreach my $k(sort keys %calls) {
#				my $c = $calls{$k};
#				$mystatus .= "${sep}$k=$c->{caller}|".($c->{callerid}||'-')."|$c->{called}|".($c->{calledid}||'-');
#				$sep = ',';
#			}
#		}
#		$mystatus .= "\r\n";
#	}
#	return ['false', $msg->header('retvalue').$mystatus];
#}



