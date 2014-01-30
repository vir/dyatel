use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::U::EventSource;

ok( request('/u/eventsource')->is_success, 'Request should succeed' );
done_testing();
