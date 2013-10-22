use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::Groups;

ok( request('/groups/list')->is_success, 'Request should succeed' );
done_testing();
