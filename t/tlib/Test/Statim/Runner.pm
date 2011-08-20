use warnings;
use strict;

package Test::Statim::Runner;
use base qw( Exporter );
our @EXPORT = qw( test_statim_server );

use Statim::Runner;
use Statim::Engine::AnyEvent;
use Statim::Storage::Redis;

use Test::SpawnRedisServer;

my ( $c, $srv ) = redis();
END { $c->() if $c }

my ( $redis_host, $redis_port ) = split( ':', $srv );
my $host = undef;

sub test_statim_server {
    my $port = shift;

    my $storage = Statim::Storage::Redis->new(
        {   redis_host => $redis_host,
            redis_port => $redis_port
        }
    );

    my $engine = Statim::Engine::AnyEvent->new(
        {   host => $host,
            port => $port
        }
    );

    my $app = Statim::Runner->new(
        {   storage => $storage,
            engine  => $engine
        }
    );

    return $app;
}
1;

