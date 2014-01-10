use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::F;

ok( request('/f')->is_success, 'Request should succeed' );
done_testing();
