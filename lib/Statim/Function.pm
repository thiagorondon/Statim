
package Statim::Function;

use strict;
use warnings;

use Scalar::Util qw(looks_like_number);
use List::Util;         # qw(sum);
use List::MoreUtils;    # qw(distinct);

sub new {
    my $class = shift;
    my $self = shift || {};
    bless $self, $class;
    return $self;
}

sub sum {
    my ( $self, $items ) = @_;
    my $n = 0;
    map { $n += $_ } @{$items};
    return $n;
}

sub min {
    my ( $self, $items ) = @_;
    my $n = defined( $items->[0] ) ? $items->[0] : 0;
    map { $n = $_ if $_ < $n } @{$items};
    return $n;
}

sub max {
    my ( $self, $items ) = @_;
    my $n = 0;
    map { $n = $_ if $_ > $n } @{$items};
    return $n;
}

sub avg {
    my ( $self, $items ) = @_;
    my $n = 0;
    if ( scalar( @{$items} ) ) {
        $n = List::Util::sum( @{$items} ) / scalar( @{$items} );
    }
    return $n;
}

sub distinct {
    my ( $self, $items ) = @_;
    my $n = 0;
    if ( scalar( @{$items} ) ) {
        $n = List::MoreUtils::distinct( @{$items} );
    }
    return $n;
}

sub anomaly {
    my ( $self, $items ) = @_;
    my $conf       = $self->{conf};
    my $collection = $self->{collection};
    my $param      = $conf->{$collection}->{anomaly} || 10;
    my $max        = $self->max($items);

    # check if we have just one 'max'
    return 0 if scalar( scalar( ( grep { /^$max$/ } @{$items} ) ) ) != 1;

    map { return 0 if $_ > ( $max - $param ); } grep { !/^$max$/ } @{$items};

    return 1;
}

sub exec {
    my $self    = shift;
    my $storage = $self->{storage};
    my $count   = 0;
    my @accessor;    # TODO: we need another way to that  !!!

    my $collection = $self->{collection};
    my $period     = $self->{period};
    my $function   = $self->{function};

    foreach my $ts_item ( @{ $self->{ts_args} } ) {
        my $period_key = $storage->_get_period($collection);
        my $period = $storage->_calc_step( $period_key, $ts_item );

        my $ps =
          $storage->_get_all_possible_keys( $collection, $period,
            $self->{names} );

        foreach my $item ( @{$ps} ) {
            my $value = $storage->_get_key_value($item);
            next unless defined($value);
            push( @accessor, $value );
        }
    }

    return $self->$function( \@accessor ) if $self->can($function);
    return '-unknow function';
}
1;

