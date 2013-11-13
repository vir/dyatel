use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::A::Morenums;

ok( request('/a/morenums')->is_success, 'Request should succeed' );
done_testing();
