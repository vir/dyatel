#!/usr/bin/perl -w
#
# (c) vir
#
# Last modified: 2013-07-22 09:23:49 +0400
#

use strict;
use warnings FATAL => 'uninitialized';
use Template;
use Pg::hstore;
use Config::General;
use DBI;
use Getopt::Std;
#use Encode;
use FindBin;

my $conffile = "$FindBin::Bin/../ui/dyatel.conf";

my %opts; getopts('hdc:', \%opts);
if(exists $opts{'h'}) { help(); exit 0; }

eval "require Data::Dumper; import Data::Dumper;" if $opts{d};
$conffile = $opts{c} if defined $opts{c};

my $conf = { Config::General->new($conffile)->getall() };
my $myconf = $conf->{Provision};
my $dbconf = $conf->{Model}{DB}{connect_info};
my $dbh = DBI->connect($dbconf->{dsn}, $dbconf->{username}, $dbconf->{password}, { AutoCommit => 1 });

my $tt = new Template(
	INCLUDE_PATH => $myconf->{templates},  # or list ref
	OUTPUT_PATH  => $myconf->{output},
#	INTERPOLATE  => 1,               # expand "$var" in plain text
#	POST_CHOMP   => 1,               # cleanup whitespace
#	PRE_PROCESS  => 'header',        # prefix each template
#	EVAL_PERL    => 1,               # evaluate Perl code blocks
);

my $sth = $dbh->prepare('SELECT * FROM provision');
$sth->execute();
while(my $row = $sth->fetchrow_hashref())
{
	my $user = $dbh->selectrow_hashref("SELECT * FROM users WHERE id = ?", undef, $row->{uid});
	my %params = (
		%{ $myconf->{Params} },
		hw => $row->{hw},
		%{ Pg::hstore::decode($row->{params}) },
	);
	provision($row->{devtype}, {
		params => \%params,
		user => $user,
		conf => $myconf,
	});
}

sub provision
{
	my($tpl, $vars) = @_;
	print Dumper(\@_) if $opts{d};
	my $output = '';
	$tt->process($tpl.'.conf', $vars, \$output) || die $tt->error(), "\n";

#	$output =~ s#\s+$##s;
#	print "=== $tpl.conf ===\n$output\n=== === ===\n" if $opts{d};

	my $tc = { Config::General->new( -String => $output )->getall };
	print Dumper( $tc ) if $opts{d};

	$tt->process($tc->{template}, $vars, $tc->{output}) || die $tt->error(), "\n";
}

sub help
{
	print << "***";
Usage:
	$0 [opts]
		-h --- this help
		-d --- debug mode
		-c file.conf --- use alternative conf file
***
}

