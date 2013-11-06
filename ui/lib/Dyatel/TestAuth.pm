package Dyatel::TestAuth;
use Moose::Role;
require Catalyst;

around env => sub {
	my ($orig, $self, @args) = @_;
	my $e = $self->$orig(@args);
	$e->{REMOTE_USER} = $ENV{TEST_AUTH_USER};
	return $e;
};

1;



