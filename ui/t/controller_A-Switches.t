use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::A::Switches;

ok( request('/a/switches')->is_success, 'Request should succeed' );
done_testing();
