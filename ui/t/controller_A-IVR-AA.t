use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::A::IVR::AA;

ok( request('/a/ivr/aa')->is_success, 'Request should succeed' );
done_testing();
