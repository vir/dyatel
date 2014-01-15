use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::F::Prices;

ok( request('/f/prices')->is_success, 'Request should succeed' );
done_testing();
