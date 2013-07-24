use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::Provisions;

ok( request('/provisions')->is_success, 'Request should succeed' );
done_testing();
