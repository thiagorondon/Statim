
use Test::More tests => 13;

use_ok('Statim::Parser');

my $parser = Statim::Parser->new;

is_deeply( [ $parser->do('add collection foo:enum num:1') ], [ 'add', 'collection', 'foo:enum', 'num:1' ] );
is_deeply( [ $parser->do('get collection foo:enum num:1') ], [ 'get', 'collection', 'foo:enum', 'num:1' ] );
is_deeply( [ $parser->do('get collection foo:a* num') ],     [ 'get', 'collection', 'foo:a*',   'num' ] );
is_deeply( [ $parser->do('get collection num ts:1-2') ],     [ 'get', 'collection', 'num',      'ts:1-2' ] );
is_deeply( [ $parser->do('set collection num ts:1-2') ],     [ 'set', 'collection', 'num',      'ts:1-2' ] );

is_deeply( [ $parser->do('version') ], ['version'] );
is_deeply( [ $parser->do('quit') ],    ['quit'] );

is( $parser->do('get collection foo ts:1-'),    undef );
is( $parser->do('add collection foo:'),         undef );
is( $parser->do('add collection? foo:! num:1'), undef );
is( $parser->do('XPTO'),                        undef );
is( $parser->do('xpto 1'),                      undef );

