
package Statim::Server::Storage;

use strict;
use warnings;
use Switch;

## TODO: Make ::Storage::Custom
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
    return int( $epoch / $period );
}

sub _get_period_by_collection {
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
    return join( '_-', $collection, @ns);
}

sub _parse_args {
    my ( $self, $collection, @args ) = @_;

    my ( $ns_count, $ns_count_n, %data );

    foreach my $field ( keys $conf->{$collection}->{fields} ) {
        my $type = $conf->{$collection}->{fields}->{$field};
        next unless $type eq 'enum' or $type eq 'count';

        foreach my $arg (@args) {
            my ( $var, $value ) = split( /:/, $arg );
            next unless $var eq $field;

            switch ($type) {
                case /enum/  { $data{$field} = $value }
                case /count/ { $ns_count = $field; $ns_count_n = $value }
            }
        }
    }
    return ( $ns_count, $ns_count_n, %data );
}

sub _get_ts {
    my ( $self, @args ) = @_;
    foreach my $arg (@args) {
        my ($var, $value ) = split( /:/, $arg);
        next unless $var eq 'ts';
        return $value;
    }
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
    my ( $ns_count, $ns_count_n, %data ) = $self->_parse_args( $collection, @args );
    my $ts = $self->_get_ts(@args);

    my $ekey =
      $self->_find_period_key( $self->_get_period_by_collection($collection), $ts );
    my $nkey = $self->_make_key_name( $collection, $ts, sort keys %data );

    $self->_save_data( $redis, $nkey, $ns_count, $ns_count_n, %data );
    return $self->get( $nkey, $ns_count );
}

sub get {
    my ( $self, @names ) = @_;

    my $collection = shift(@names);
    my $ns_count   = pop(@names);

    my $nkey = $self->_make_key_name( $collection, undef, sort @names );

    my $redis = $self->_redis_conn;
    my $ret = $redis->hmget( $nkey, $ns_count );
    return $ret->[0];
}

1;
