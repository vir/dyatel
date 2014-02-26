use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::A::Config;

ok( request('/a/config')->is_success, 'Request should succeed' );
done_testing();
