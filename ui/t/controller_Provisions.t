use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::Provisions;

ok( request('/provisions/list')->is_success, 'Request should succeed' );
done_testing();
