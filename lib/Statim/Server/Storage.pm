
package Statim::Server::Storage;

use strict;
use warnings;

## TODO: Make ::Storage::Custom
## This code is hardcoded a lot.

use Statim::Config;

my $config = Statim::Config->new;
my $conf   = $config->get('etc/config.json');

use Redis;
my $redis = Redis->new;

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    return $self;
}

sub add {
    my ( $self, $name, @args ) = @_;

    #$n ||= 1;
    #return $redis->incrby( $name => $n );

    my ( $sec_name, $sec_name_value, $sec_count, $sec_count_n ) = @_;
    foreach my $key ( keys %{$conf} ) {
        next unless defined( $conf->{$key}->{fields} );

        #print "$key\n";

        foreach my $field ( keys $conf->{$key}->{fields} ) {
            my $type = $conf->{$key}->{fields}->{$field};
            next unless $type eq 'enum' or $type eq 'count';

            foreach my $arg (@args) {
                my ( $a_name, $a_value ) = split( /:/, $arg );

                #warn "args $a_name -> $a_value";
                
                if ( $a_name eq $field and $type eq 'enum' ) {
                    $sec_name = $field;
                    $sec_name_value = $a_value;
                }
                
                if ( $a_name eq $field and $type eq 'count' ) {
                    $sec_count   = $field;
                    $sec_count_n = $a_value;
                }

            }
        }
    }
    
    # TODO: Hash ?
    my $key = join('_', $name, $sec_name);
    
    if ($redis->exists($key)) {
        $redis->incrby( $key, $sec_count_n );
    } else {
        $redis->set( $key, $sec_count_n );
    }

    my $ret = $redis->get( $key );

    return $ret;

    #return
#"collection: $name sec_name: $sec_name sec_name_value: $sec_name_value sec_count: $sec_count sec_count_n: $sec_count_n";

}

sub get {
    my ( $self, $name ) = @_;
    return $redis->get($name);
}

1;
