use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::U::CDR;

ok( request('/u/cdr')->is_success, 'Request should succeed' );
done_testing();
