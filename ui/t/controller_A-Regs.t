use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::A::Regs;

ok( request('/a/regs')->is_success, 'Request should succeed' );
done_testing();
