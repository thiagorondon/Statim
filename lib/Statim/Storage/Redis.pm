
package Statim::Storage::Redis;

use strict;
use warnings;
use Switch;
use DateTime;
use POSIX qw(floor);

## This code is hardcoded a lot.
## Use the same redis connection per class ?

use Statim::Config;
use Redis;

my $config = Statim::Config->new;
my $conf   = $config->get('etc/config.json');

sub new {
    my ( $class, $self ) = @_;
    bless $self, $class;
    return $self;
}

sub redis_server {
    my $self = shift;
    return join( ':', $self->{redis_host}, $self->{redis_port} );
}

sub _find_period_key {
    my ( $self, $period, $epoch ) = @_;
    return floor( $epoch / $period );
}

sub _get_period_key {
    my ( $self, $collection ) = @_;
    return $conf->{$collection}->{period};
}

sub _check_collection {
    my ( $self, $collection ) = @_;
    return defined( $conf->{$collection} ) ? 1 : 0;
}

sub _redis_conn {
    my $self = shift;
    Redis->new( server => $self->redis_server );
}

sub _make_key_name {
    my $self = shift;
    my ( $collection, $ts, @ns ) = @_;
    return join( '_-', @_ ) if $ts;
    return join( '_-', $collection, @ns );
}

sub _parse_args_to_add {
    my ( $self, $collection, @args ) = @_;

    my ( $ns_count, $ns_count_n, %data );

    foreach my $field ( keys $conf->{$collection}->{fields} ) {
        my $type = $conf->{$collection}->{fields}->{$field};
        next unless $type eq 'enum' or $type eq 'count';

        foreach my $arg (@args) {
            my ( $var, $value ) = split( /:/, $arg );
            next unless $var eq $field;

            switch ($type) {
                case /enum/ { $data{$field} = $value }
                case /count/ { $ns_count = $field; $ns_count_n = $value }
            }
        }
    }
    return ( $ns_count, $ns_count_n, %data );
}

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

sub _save_data {
    my ( $self, $redis, $nkey, $ns_count, $ns_count_n, %data ) = @_;

    if ( $redis->exists($nkey) ) {
        $redis->hincrby( $nkey, $ns_count, $ns_count_n );
    }
    else {
        my @args = ();
        foreach my $key ( keys %data ) { push( @args, $key, $data{$key} ); }
        $redis->hmset( $nkey, @args, $ns_count, $ns_count_n );
    }
}

sub add {
    my ( $self, $collection, @args ) = @_;

    return "-no collection" unless $self->_check_collection($collection);

    my $redis = $self->_redis_conn;
    my $ts    = $self->_get_ts(@args);

    my $ekey =
      $self->_find_period_key( $self->_get_period_key($collection), $ts );
    my ( $ns_count, $ns_count_n, %data ) =
      $self->_parse_args_to_add( $collection, @args );
    my $nkey = $self->_make_key_name( $collection, $ekey, sort keys %data );

    $self->_save_data( $redis, $nkey, $ns_count, $ns_count_n, %data );
    return $self->get( $collection, ( sort keys %data ), "ts:$ts", $ns_count );
}

sub _parse_args_to_get {
    my ( $self, @names ) = @_;
    my $collection = shift(@names);
    my $ns_count   = pop(@names);
    return ( $collection, $ns_count, grep { !/ts:/ } @names );
}

sub _get_ts_range {
    my ( $self, $collection, $ts ) = @_;

    my $period = $self->_get_period_key($collection, $ts);
    my @ts_args;
    if ( $ts =~ /-/ ) {
        my ( $ts_ini, $ts_fim ) = split( '-', $ts );
        push( @ts_args, $ts_ini );
        my $ts_tmp = 0; # = $ts_ini ?
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

sub get {
    my ( $self, @args ) = @_;
    my ( $collection, $ns_count, @names ) = $self->_parse_args_to_get(@args);

    my $ts      = $self->_get_ts(@args);
    my @ts_args = $self->_get_ts_range( $collection, $ts );
    my $redis   = $self->_redis_conn;
    my $count   = 0;

    foreach my $ts_item (@ts_args) {
        my $ekey =
          $self->_find_period_key( $self->_get_period_key($collection),
            $ts_item );
        my $nkey = $self->_make_key_name( $collection, $ekey, sort @names );
        my $ret = $redis->hmget( $nkey, $ns_count );
        $count += $ret->[0] if $ret->[0];
    }
    return $count;
}

1;
