use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::A::Status;

ok( request('/a/status')->is_success, 'Request should succeed' );
done_testing();
