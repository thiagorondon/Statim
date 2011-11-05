
package Statim::Storage::Interface::Key;

use strict;
use warnings;

use Scalar::Util qw(looks_like_number);
use List::Util qw(sum);
use List::MoreUtils qw(distinct);
use Statim::Schema;
use Statim::Function;

use base qw(Statim::Storage::Interface);

# TODO: Split Storage // Schema checks // Storage::Engine.

sub new {
    my ( $class, $self ) = @_;
    $self = {} unless defined $self;
    bless $self, $class;

    my $schema = Statim::Schema->new;
    my $conf = $schema->get;
    $self->conf($conf);
    return $self;
}

sub _make_key_name {
    my $self = shift;
    my ( $collection, $ts, @ns ) = @_;
    return join( '_-', grep { $_ } @_ ) if $ts;
    return join( '_-', $collection, grep { $_ } @ns );
}

sub add {
    my ( $self, $collection, @args ) = @_;

    return "-no collection" unless $self->_check_collection($collection);

    #    my $ts         = $self->_get_ts(@args);
    my $ts = $self->_get_timestamp( $collection, @args );
    return $ts unless looks_like_number($ts);

    my $period_key = $self->_get_period($collection);
    my $period = $self->_calc_step( $period_key, $ts );

    my ( $counter, $incrby, %data ) =
      $self->_parse_args_to_add( $collection, @args );

    return $counter
      if $counter and $counter =~ /^\+/;    # errors about parse args.

    my @keys = $self->_arrange_key_by_hash(%data);
    my $key = $self->_make_key_name( $collection, $period, @keys );

    my $aggregate = $self->conf->{$collection}->{aggregate};
    return $self->_save_data( $key, $incrby, $aggregate );
}

sub del {
    my ( $self, $collection, @args ) = @_;

    return "-no collection" unless $self->_check_collection($collection);

    my $ts         = $self->_get_ts(@args);
    my $period_key = $self->_get_period($collection);
    my $period     = $self->_calc_step( $period_key, $ts );

    my ( $counter, $incrby, %data ) =
      $self->_parse_args_to_add( $collection, @args );

    if ($incrby) { }
    ;    # unsed var ?

    return $counter
      if $counter and $counter =~ /^\+/;    # errors about parse args.

    my @keys = $self->_arrange_key_by_hash(%data);
    my $key = $self->_make_key_name( $collection, $period, @keys );

    return $self->_delete_key($key) || '-not exist';
}

sub _get_key_value {
    my ( $self, $key ) = @_;
    my $ret = $self->_get_data($key);
    return looks_like_number($ret) ? $ret : 0;
}

sub _get_all_possible_keys {
    my ( $self, $collection, $ts, $argr ) = @_;

    my @fields = keys %{ $self->conf->{$collection}->{fields} };
    my @ns;

    foreach my $item ( sort @fields ) {
        my $type = $self->conf->{$collection}->{fields}->{$item};
        next if $type eq 'count';

        my ($has_item) = grep { /^$item:/ } @{$argr};

        my $item_key;
        if ($has_item) {
            my ( $argr_name, $argr_value );
            ( $argr_name, $argr_value ) = split( ':', $has_item );

            $item_key = join( '_-', $argr_name, $argr_value );
        }
        else {
            $item_key = join( '_-', $item, '*' );
        }

        push( @ns, $item_key );
    }

    my $key = join( '_-', $collection, $ts, sort @ns );
    my @ps = $self->_get_possible_keys($key);
    return [@ps];
}

sub get {
    my ( $self, @args ) = @_;
    my ( $collection, $count_func, @names ) = $self->_parse_args_to_get(@args);
    return "-no collection" unless $self->_check_collection($collection);

    my $ts = $self->_get_timestamp( $collection, @args );
    return $ts if $ts and substr( $ts, 0, 1 ) eq '+';
    my @ts_args = $self->_get_ts_range( $collection, $ts );

    my $func = Statim::Function->new(
        {
            collection => $collection,
            function   => $count_func,
            ts_args    => [@ts_args],
            names      => [@names],
            storage    => $self,
            conf       => $self->conf
        }
    );

    return $func->exec;
}

1;
