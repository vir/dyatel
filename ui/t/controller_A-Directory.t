use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dyatel';
use Dyatel::Controller::A::Directory;

ok( request('/a/directory')->is_success, 'Request should succeed' );
done_testing();
