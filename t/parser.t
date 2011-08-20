
use Test::More tests => 7;

use_ok('Statim::Parser');

my $parser = Statim::Parser->new;

is_deeply( [ $parser->do('add foo 1') ], [ 'add', 'foo', '1' ] );
is_deeply( [ $parser->do('get foo 1') ], [ 'get', 'foo', '1' ] );
is_deeply( [ $parser->do('version') ],   ['version'] );
is_deeply( [ $parser->do('quit') ],      ['quit'] );

is( $parser->do('XPTO'),   undef );
is( $parser->do('xpto 1'), undef );

