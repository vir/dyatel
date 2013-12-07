use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::U::Phonebook;

ok( request('/u/phonebook')->is_success, 'Request should succeed' );
done_testing();
