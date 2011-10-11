
package Statim::Ts;

use strict;
use warnings;

use DateTime;

sub _get_ts {
    my ( $self, @args ) = @_;
    foreach my $arg (@args) {
        my ( $var, $value ) = split( /:/, $arg );
        next unless $var eq 'ts';
        return $value;
    }

    my $dt = DateTime->now;
    return $dt->epoch;
}

1;

