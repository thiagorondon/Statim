
use Test::More tests => 5;

use strict;
use warnings;

use_ok('Statim::Step');

is( Statim::Step::_calc_step( undef, 1, 2 ),  2 );
is( Statim::Step::_calc_step( undef, 9, 2 ),  0 );
is( Statim::Step::_calc_step( undef, 2, 9 ),  4 );
is( Statim::Step::_calc_step( undef, 2, 10 ), 5 );

1;

