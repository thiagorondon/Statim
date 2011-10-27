
package Statim::Function;

use strict;
use warnings;

use Scalar::Util qw(looks_like_number);
use List::Util qw(sum);
use List::MoreUtils qw(distinct);

sub new {
    my $class = shift;
    my $self = shift || {};
    bless $self, $class;
    return $self;
}

sub exec {
    my $self    = shift;
    my $storage = $self->{storage};
    my $count   = 0;
    my @accessor;    # TODO: we need another way to that  !!!

    my $collection = $self->{collection};
    my $period     = $self->{period};
    my $count_func = $self->{function};

    foreach my $ts_item ( @{ $self->{ts_args} } ) {
        my $period_key = $storage->_get_period($collection);
        my $period = $storage->_calc_step( $period_key, $ts_item );

        my $ps =
          $storage->_get_all_possible_keys( $collection, $period,
            $self->{names} );

        foreach my $item ( @{$ps} ) {
            my $value = $storage->_get_key_value($item);
            next unless defined($value);

            if ( $count_func eq 'sum' ) {
                $count += $storage->_get_key_value($item);

                #$count += $value;
            }
            elsif ( $count_func eq 'min' ) {
                $count = $accessor[0] = $value
                  if scalar(@accessor)
                      and $value < $accessor[0];
                $count = $accessor[0] = $value unless scalar(@accessor);
            }
            elsif ( $count_func eq 'max' ) {
                $accessor[0] = 0 unless scalar(@accessor);
                $count = $accessor[0] = $value if $value > $accessor[0];
            }
            elsif ( $count_func eq 'avg' or $count_func eq 'distinct' ) {
                push( @accessor, $value );
            }
        }
    }

    if ( $count_func eq 'avg' ) {
        if ( scalar(@accessor) ) {
            $count = sum(@accessor) / scalar(@accessor);
        }
    }

    if ( $count_func eq 'distinct' ) {
        if ( scalar(@accessor) ) {
            $count = distinct(@accessor);
        }
    }

    return $count;
}
1;

