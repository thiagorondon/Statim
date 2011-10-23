
package Statim::Step;

use strict;
use warnings;

use POSIX qw(floor);

sub _calc_step {
    my ( $self, $period, $epoch ) = @_;
    return floor( $epoch / $period );
}

sub _get_step {
    my ( $self, $period, @args ) = @_;
    foreach my $arg (@args) {
        my ( $var, $value ) = split( /:/, $arg );
        next unless $var eq 'step';
        next unless $value =~ /^[0-9\-]*$/;
        return $value;
    }

    my $dt = DateTime->now;
    return $self->_calc_step( $period, $dt->epoch );
}

1;

