
package Statim::Ts;

use strict;
use warnings;

use DateTime;

sub _get_ts {
    my ( $self, @args ) = @_;
    foreach my $arg (@args) {
        my ( $var, $value ) = split( /:/, $arg );
        next unless $var eq 'ts';
        next unless $value =~ /^[0-9\-]*$/;

        if ( $value =~ /-/ ) {
            my ( $min, $max ) = split( '-', $value );
            return '+Your ts range is wrong, min > max' if $min > $max;
        }
        return $value;
    }

    my $dt = DateTime->now;
    return $dt->epoch;
}

sub _get_ts_range {
    my ( $self, $collection, $ts ) = @_;

    my $period = $self->_get_period( $collection, $ts );
    my @ts_args;
    if ( $ts =~ /-/ ) {
        my ( $ts_ini, $ts_fim ) = split( '-', $ts );
        push( @ts_args, $ts_ini );
        my $ts_tmp = 0;    # = $ts_ini ?
        while (1) {
            $ts_tmp += $period;
            last if $ts_tmp > $ts_fim;
            push( @ts_args, $ts_tmp ) if $ts_tmp > $ts_ini;
        }
    }
    else {
        push( @ts_args, $ts );
    }
    return @ts_args;
}

1;

