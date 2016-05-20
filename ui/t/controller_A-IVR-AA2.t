use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::A::IVR::AA2;

ok( request('/a/ivr/aa2')->is_success, 'Request should succeed' );
done_testing();
