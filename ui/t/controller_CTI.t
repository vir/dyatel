use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::CTI;

ok( request('/cti')->is_success, 'Request should succeed' );
done_testing();
