
use Test::More tests => 7;

# TODO: More, More.
use lib 't/tlib';
use Test::Statim::Config;
my $config = test_statim_gen_config;
$ENV{'STATIM_CONFIG'} = $config;

use_ok('Statim::Storage');

my $storage = Statim::Storage->new();

is ($storage->_get_period('collection'), 84600);
is ($storage->_get_period('collection2'), undef);

is ($storage->_check_collection('collection'), 1);
is ($storage->_check_collection('collection2'), 0);

is ($storage->_get_ts('foo:num','ts:10'), 10);
ok ($storage->_get_ts('foo:num'));





