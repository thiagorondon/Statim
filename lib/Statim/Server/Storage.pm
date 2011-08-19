
package Statim::Server::Storage;

use strict;
use warnings;

## TODO: Make ::Storage::Custom
## This code is hardcoded a lot.
## Use the same redis connection per class ?
## Just one enum ?

use Statim::Config;

my $config = Statim::Config->new;
my $conf   = $config->get('etc/config.json');

use Redis;

sub new {
    my ( $class, $self ) = @_;
    bless $self, $class;
    return $self;
}

sub redis_server {
    my $self = shift;
    return join( ':', $self->{redis_host}, $self->{redis_port} );
}

sub add {
    my ( $self, $name, @args ) = @_;

    my $redis = Redis->new( server => $self->redis_server );

    my ( %data, $sec_count, $sec_count_n, $sec_name, $sec_name_value );
    foreach my $key ( keys %{$conf} ) {
        next unless defined( $conf->{$key}->{fields} );

        foreach my $field ( keys $conf->{$key}->{fields} ) {
            my $type = $conf->{$key}->{fields}->{$field};
            next unless $type eq 'enum' or $type eq 'count';

            foreach my $arg (@args) {
                my ( $a_name, $a_value ) = split( /:/, $arg );

                if ( $a_name eq $field and $type eq 'enum' ) {
                    #$sec_name       = $field;
                    #$sec_name_value = $a_value;
                    $data{$field} = $a_value;
                }

                if ( $a_name eq $field and $type eq 'count' ) {
                    $sec_count   = $field;
                    $sec_count_n = $a_value;
                }

            }
        }
    }

    if ( $redis->exists($name) ) {
        $redis->hincrby( $name, $sec_count, $sec_count_n );
    }
    else {
        my @args = ();
        foreach my $key (keys %data) { push(@args, $key, $data{$key}); }
        $redis->hmset( $name, @args, $sec_count, $sec_count_n );
    }
    return $self->get( $name, $sec_count );
}

sub get {
    my ( $self, $name, $sec_count ) = @_;
    my $redis = Redis->new( server => $self->redis_server );
    my $ret = $redis->hmget( $name, $sec_count );
    return $ret->[0];
}

1;
