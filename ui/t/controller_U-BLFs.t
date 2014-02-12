use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::U::BLFs;

ok( request('/u/blfs')->is_success, 'Request should succeed' );
done_testing();
