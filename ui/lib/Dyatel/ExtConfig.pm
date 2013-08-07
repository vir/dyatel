package Dyatel::ExtConfig;
use Config::JFDI;

our $conf;

sub load
{
	unless($conf) {
		my $p = $INC{'Dyatel/ExtConfig.pm'};
		$p =~ s#/[^\/]*$##;
		$p.= '/../..' if -f "$p/../../Makefile.PL";;
		my $config = Config::JFDI->new(name => "dyatel", path => $p);
		$conf = $config->get;
	}
	return $conf;
}

sub dbh
{
	load() unless $conf;
	my $myconf = $conf->{Provision};
	my $dbconf = $conf->{Model}{DB}{connect_info};
	my $dbh = DBI->connect($dbconf->{dsn}, $dbconf->{username}, $dbconf->{password}, { AutoCommit => 1 });
}

1;



