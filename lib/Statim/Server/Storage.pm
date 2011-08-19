
package Statim::Server::Storage;

use strict;
use warnings;

## TODO: Make ::Storage::Custom
## This code is hardcoded a lot.

use Statim::Config;

my $config = Statim::Config->new;
my $conf   = $config->get('etc/config.json');

use Redis;

sub new {
    my ($class, $self) = @_;
    bless $self, $class;
    return $self;
}

sub redis_server {
    my $self = shift;
    return join(':', $self->{redis_host}, $self->{redis_port});
}

sub add {
    my ( $self, $name, @args ) = @_;

    my $redis = Redis->new( server => $self->redis_server );

    my ( $sec_name, $sec_name_value, $sec_count, $sec_count_n ) = @_;
    foreach my $key ( keys %{$conf} ) {
        next unless defined( $conf->{$key}->{fields} );

        foreach my $field ( keys $conf->{$key}->{fields} ) {
            my $type = $conf->{$key}->{fields}->{$field};
            next unless $type eq 'enum' or $type eq 'count';

            foreach my $arg (@args) {
                my ( $a_name, $a_value ) = split( /:/, $arg );

                if ( $a_name eq $field and $type eq 'enum' ) {
                    $sec_name       = $field;
                    $sec_name_value = $a_value;
                }

                if ( $a_name eq $field and $type eq 'count' ) {
                    $sec_count   = $field;
                    $sec_count_n = $a_value;
                }

            }
        }
    }

    if ( $redis->exists($name) ) {
         $redis->hincrby( $name, $sec_count, $sec_count_n);
    }
    else {
        $redis->hmset( $name, $sec_name, $sec_name_value, $sec_count,
            $sec_count_n);
    }

    my $ret = $redis->hmget($name, $sec_count);

    return $ret->[0];

#return
#"collection: $name sec_name: $sec_name sec_name_value: $sec_name_value sec_count: $sec_count sec_count_n: $sec_count_n";

}

sub get {
    my ( $self, $name ) = @_;
    return "OK";
    #return $redis->get($name);
}

1;
