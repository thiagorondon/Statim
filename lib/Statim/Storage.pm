
package Statim::Storage;

use strict;
use warnings;

use Scalar::Util qw(looks_like_number);
use List::Util qw(sum);
use List::MoreUtils qw(distinct);
use Statim::Schema;

use base qw(Statim::Step Statim::Ts);

# TODO: Split Storage // Schema checks // Storage::Engine.

our $conf;

sub new {
    my ( $class, $self ) = @_;
    $self = {} unless defined $self;
    bless $self, $class;

    my $schema = Statim::Schema->new;
    $conf = $schema->get;

    return $self;
}

sub _get_period {
    my ( $self, $collection ) = @_;
    return $conf->{$collection}->{period};
}

sub _get_counter {
    my ( $self, $collection ) = @_;
    return unless ref($conf->{$collection}->{fields}) eq 'HASH';
    foreach my $field ( keys %{$conf->{$collection}->{fields}} ) {
        my $type = $conf->{$collection}->{fields}->{$field};
        return $field if $type eq 'count';
    }
}

sub _check_collection {
    my ( $self, $collection ) = @_;
    return 0 unless $collection;
    return defined( $conf->{$collection}->{fields} ) ? 1 : 0;
}

sub _parse_args_to_add {
    my ( $self, $collection, @args ) = @_;

    my ( $counter, $incrby, %data );
    my $declare_args = 0;
    my @fields       = keys %{$conf->{$collection}->{fields}};

    foreach my $field (@fields) {
        my $type = $conf->{$collection}->{fields}->{$field};
        return '+wrong declare field type'
          unless $type eq 'enum'
              or $type eq 'count';    #schema error

        foreach my $arg (@args) {
            my ( $var, $value ) = split( /:/, $arg );
            next unless $var eq $field;
            $declare_args++;

            if ( $type eq 'enum' ) {
                $data{$field} = $value;
            }
            else {
                $counter = $field;
                $incrby  = $value;
            }

            # TODO: Add default -> schema error ?
        }
    }

    return '+missing args' unless $declare_args == scalar(@fields);
    return ( $counter, $incrby, %data );
}

sub _arrange_key_by_hash {
    my ( $self, %data ) = @_;
    my @args;
    foreach my $item ( sort keys %data ) {
        push( @args, $item, $data{$item} );
    }
    return @args;
}

# TODO: bug, we need to make sure if we dont have
# $counter . 'bla' field, for example.

sub _parse_args_to_get {
    my ( $self, @names ) = @_;
    my $collection  = shift(@names);
    my $count_field = $self->_get_counter($collection) || '';
    my ($count_to_parse) = $count_field ? grep { /^$count_field/ } @names : ('');
    my ( undef, $count_func ) =
      $count_to_parse =~ /:/
      ? split( ':', $count_to_parse )
      : ( $count_field, 'sum' );

    return ( $collection, $count_func,
        grep { !/^(ts:|$count_field|$count_field:)/ } @names );
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
    my $ts      = $self->_get_timestamp(@args);                                                                                                                                      
    return $ts unless looks_like_number($ts);

    my $period_key = $self->_get_period($collection);
    my $period     = $self->_calc_step( $period_key, $ts );

    my ( $counter, $incrby, %data ) =
      $self->_parse_args_to_add( $collection, @args );

    return $counter
      if $counter and $counter =~ /^\+/;    # errors about parse args.

    my @keys = $self->_arrange_key_by_hash(%data);
    my $key = $self->_make_key_name( $collection, $period, @keys );

    my $aggregate = $conf->{$collection}->{aggregate};
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
    my ( $self, $collection, $ts, @argr ) = @_;

    my @fields = keys %{$conf->{$collection}->{fields}};
    my @ns;

    foreach my $item ( sort @fields ) {
        my $type = $conf->{$collection}->{fields}->{$item};
        next if $type eq 'count';

        my ($has_item) = grep { /^$item:/ } @argr;

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
    return @ps;
}

sub _get_timestamp {
  my ($self, @args) = @_;

  my $has_ts = 0;
  my $has_step = 0;
  foreach my $arg (@args) {
    my ( $var, undef ) = split( /:/, $arg );
    $has_ts = 1 if $var eq 'ts';
    $has_step = 1 if $var eq 'step';
  }

  return '+You must define only step or ts' if $has_ts and $has_step;
  return $self->_get_step if $has_step;
  return $self->_get_ts;
}

sub get {
    my ( $self, @args ) = @_;
    my ( $collection, $count_func, @names ) = $self->_parse_args_to_get(@args);
    return "-no collection" unless $self->_check_collection($collection);

    my $ts      = $self->_get_timestamp(@args);
    return $ts unless looks_like_number($ts);
    my @ts_args = $self->_get_ts_range( $collection, $ts );
    my $count   = 0;

    my @accessor;    # TODO: we need another way to that  !!!

    foreach my $ts_item (@ts_args) {
        my $period_key = $self->_get_period($collection);
        my $period = $self->_calc_step( $period_key, $ts_item );

        my @ps = $self->_get_all_possible_keys( $collection, $period, @names );

        foreach my $item (@ps) {
            my $value = $self->_get_key_value($item);
            next unless $value;

            if ( $count_func eq 'sum' ) {
                $count += $self->_get_key_value($item);
            }
            elsif ( $count_func eq 'min' ) {
                $accessor[0] = 0 unless scalar(@accessor);
                $count = $value if $value < $accessor[0];
            }
            elsif ( $count_func eq 'max' ) {
                $accessor[0] = 0 unless scalar(@accessor);
                $count = $value if $value > $accessor[0];
            }
            elsif ( $count_func eq 'avg' or $count_func eq 'distinct') {
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
            $count = distinct (@accessor);
        }
    }

    return $count;
}

1;
