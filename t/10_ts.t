
use Test::More tests => 4;

use strict;
use warnings;

use_ok('Statim::Ts');

is( Statim::Ts::_get_ts( undef, 'ts:123' ),     123 );
is( Statim::Ts::_get_ts( undef, 'ts:123-456' ), '123-456' );
isnt( Statim::Ts::_get_ts( undef, 'ts:aa' ), 'aa' );

1;

