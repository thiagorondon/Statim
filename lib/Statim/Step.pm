
package Statim::Step;

use strict;
use warnings;

use POSIX qw(floor);

sub _calc_step {
  my ( $self, $period, $epoch ) = @_;
  return floor( $epoch / $period );
}

sub _step_to_epoch {
  my ( $self, $period, $step ) = @_;
  return $step * $period;
}

sub _get_step {
    my ( $self, $period, @args ) = @_;
    foreach my $arg (@args) {
        my ( $var, $value ) = split( /:/, $arg );
        next unless $var eq 'step';
        next unless $value =~ /^[0-9\-]*$/;

        if ($value =~ /-/) {
          my ($min, $max) = split('-', $value);
          return '+Your step range is wrong, min > max' if $min > $max;

          $value = join('-', 
            $self->_step_to_epoch($period, $min), 
            $self->_step_to_epoch($period, $max));
        } else {
          $value = $self->_step_to_epoch($period, $value);
        }
        return $value;
    }

    my $dt = DateTime->now;
    return $dt->epoch;
#    return $self->_calc_step( $period, $dt->epoch );
}

1;

