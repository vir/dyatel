use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::A::Cdrs;

ok( request('/a/cdrs')->is_success, 'Request should succeed' );
done_testing();
