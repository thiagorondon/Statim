
use Test::More tests => 9;

# TODO: More, More.

use_ok('Statim::Storage');

my $storage = Statim::Storage->new();

is ($storage->_find_period_key(1, 1), 1);
is ($storage->_find_period_key(8, 999), 124);

is ($storage->_get_period_key('collection1'), 84600);
is ($storage->_get_period_key('collection2'), undef);

is ($storage->_check_collection('collection1'), 1);
is ($storage->_check_collection('collection2'), 0);

is ($storage->_get_ts('foo:num','ts:10'), 10);
ok ($storage->_get_ts('foo:num'));




