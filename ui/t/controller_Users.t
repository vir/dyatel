use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::Users;

ok( request('/users')->is_success, 'Request should succeed' );
done_testing();
