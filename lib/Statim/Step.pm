
package Statim::Step;

use strict;
use warnings;

use POSIX qw(floor);

sub _calc_step {
    my ( $self, $period, $epoch ) = @_;
    return floor( $epoch / $period );
}


1;

