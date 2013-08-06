use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::Users;

ok( request('/users/list')->is_success, 'Request should succeed' );
done_testing();
