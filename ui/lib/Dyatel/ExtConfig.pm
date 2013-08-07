package Dyatel::ExtConfig;
use Config::JFDI;

sub load
{
	my $p = $INC{'Dyatel/ExtConfig.pm'};
	$p =~ s#/[^\/]*$##;
	$p.= '/../..' if -f "$p/../../Makefile.PL";;
	my $config = Config::JFDI->new(name => "dyatel", path => $p);
	return $config->get;
}

1;



