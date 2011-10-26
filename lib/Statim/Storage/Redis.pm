
package Statim::Storage::Redis;

use strict;
use warnings;

use base "Statim::Storage::Interface::Redis";

## Use the same redis connection per class ?

use Redis;
my $rconn  = undef;

sub _redis_server {
    my $self = shift;
    return join( ':', $self->{redis_host}, $self->{redis_port} );
}

sub _redis_conn {
    my $self = shift;
    $rconn = Redis->new( server => $self->_redis_server ) unless $rconn;
    return $rconn;
}

sub _get_possible_keys {
    my ( $self, $key ) = @_;
    my $redis = $self->_redis_conn;
    return $redis->keys("$key");
}

sub _delete_key {
    my ( $self, $key ) = @_;
    my $redis = $self->_redis_conn;
    $redis->del( $key );
}

sub __sum_data {
    my ( $self, $key, $incrby ) = @_;
    my $redis = $self->_redis_conn;
    return $redis->incrby( $key, $incrby ) if $redis->exists($key);
    $redis->set( $key, $incrby );
    return $incrby;
}

sub __uniq_data {
    my ( $self, $key, $incrby ) = @_;
    my $redis = $self->_redis_conn;
    return '+this period already have a value' if $redis->exists($key);
    $redis->set( $key, $incrby );
    return $incrby;
}

sub _save_data {
    my ( $self, $key, $incrby, $aggregate ) = @_;
    
    return $self->__uniq_data( $key, $incrby ) if $aggregate eq 'uniq';

    return $self->__sum_data( $key, $incrby );
}

sub _get_data {
    my ( $self, $key ) = @_;
    my $redis = $self->_redis_conn;
    my $count = 0;
    map { $count += $redis->get($_) } $redis->keys($key);
    return $count;
}

1;
