use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::A::IVR::MD;

ok( request('/a/ivr/md')->is_success, 'Request should succeed' );
done_testing();
