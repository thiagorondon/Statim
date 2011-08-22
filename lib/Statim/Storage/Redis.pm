
package Statim::Storage::Redis;

use strict;
use warnings;
use Switch;
use DateTime;
use POSIX qw(floor);
use Scalar::Util qw(looks_like_number);

## This code is hardcoded a lot.
## Use the same redis connection per class ?

use Statim::Config;
use Redis;

my $config = Statim::Config->new;
my $conf   = $config->get('etc/config.json');
my $rconn  = undef;

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
    $rconn = Redis->new( server => $self->redis_server ) unless $rconn;
    return $rconn;
}

sub _make_key_name {
    my $self = shift;
    my ( $collection, $ts, @ns ) = @_;
    return join( '_-', grep {$_} @_ ) if $ts;
    return join( '_-', $collection, grep {$_} @ns );
}

sub _parse_args_to_add {
    my ( $self, $collection, @args ) = @_;

    my ( $counter, $counter_n, %data );

    foreach my $field ( keys $conf->{$collection}->{fields} ) {
        my $type = $conf->{$collection}->{fields}->{$field};
        next unless $type eq 'enum' or $type eq 'count';

        foreach my $arg (@args) {
            my ( $var, $value ) = split( /:/, $arg );
            next unless $var eq $field;

            switch ($type) {
                case /enum/ { $data{$field} = $value }
                case /count/ { $counter = $field; $counter_n = $value }
            }
        }
    }
    return ( $counter, $counter_n, %data );
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
    my ( $self, $redis, $key, $incrby ) = @_;
    return $redis->incrby( $key, $incrby ) if $redis->exists($key);
    $redis->set( $key, $incrby );
    return $incrby;
}

sub _arrange_key_by_hash {
    my ( $self, %data ) = @_;
    my @args;
    foreach my $item ( sort keys %data ) {
        push( @args, $item, $data{$item} );
    }
    return @args;
}

sub add {
    my ( $self, $collection, @args ) = @_;

    return "-no collection" unless $self->_check_collection($collection);

    my $redis      = $self->_redis_conn;
    my $ts         = $self->_get_ts(@args);
    my $period_key = $self->_get_period_key($collection);
    my $period     = $self->_find_period_key( $period_key, $ts );

    my ( $counter, $incrby, %data ) = $self->_parse_args_to_add( $collection, @args );

    my @keys = $self->_arrange_key_by_hash(%data);
    my $key = $self->_make_key_name( $collection, $period, @keys );

    return $self->_save_data( $redis, $key, $incrby );
}

sub _parse_args_to_get {
    my ( $self, @names ) = @_;
    my $collection = shift(@names);
    my $counter    = pop(@names);
    return ( $collection, $counter, grep { !/ts:/ } @names );
}

sub _arrange_key_by_array {
    my ( $self, $counter, @args ) = @_;
    my @ret;
    foreach my $item ( sort @args ) {
        my ( $name, $value ) = split( ':', $item );
        next if $name eq 'ts' or $name eq $counter;
        next unless $name;
        push( @ret, $name, $value );
    }
    return @ret;
}

sub _get_ts_range {
    my ( $self, $collection, $ts ) = @_;

    my $period = $self->_get_period_key( $collection, $ts );
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

sub get {
    my ( $self, @args ) = @_;
    my ( $collection, $counter, @names ) = $self->_parse_args_to_get(@args);

    return "-no collection" unless $self->_check_collection($collection);

    my $ts      = $self->_get_ts(@args);
    my @argr    = $self->_arrange_key_by_array( $counter, @names );
    my @ts_args = $self->_get_ts_range( $collection, $ts );
    my $redis   = $self->_redis_conn;
    my $count   = 0;

    foreach my $ts_item (@ts_args) {
        my $period_key = $self->_get_period_key($collection);
        my $period     = $self->_find_period_key( $period_key, $ts_item );
        my $nkey       = $self->_make_key_name( $collection, $period, @argr );
        my $ret        = $redis->get($nkey);
        $count += $ret if looks_like_number($ret);
    }
    return $count;
}

1;
