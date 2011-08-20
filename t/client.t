use warnings;
use strict;

use Test::More tests => 6;
use Test::TCP;

use lib 't/tlib';
use Test::SpawnRedisServer;

my ( $c, $srv ) = redis();
END { $c->() if $c }

use Statim;
use Statim::Server::AnyEvent;
use Statim::Client;

my ( $redis_host, $redis_port ) = split( ':', $srv );
my $host = undef;

test_tcp(
    server => sub {
        my $port   = shift;
        my $server = Statim::Server::AnyEvent->new(
            {
                redis_host => $redis_host,
                redis_port => $redis_port
            }

        );
        $server->start_listen( $host, $port );

        AE::cv->recv();
    },
    client => sub {
        my $port = shift;

        my $client = Statim::Client->new({
            host => '127.0.0.1',
            port => $port
        });

        note "version";
        my $res = $client->version;
        is $res, 'OK ' . $Statim::VERSION . "\r\n";

        note "simple add 1";
        $res = $client->add('collection1', 'bar:foo' , 'foo:1');
        is $res, "OK 1\r\n";

        note "simple add 3";
        $res = $client->add('collection1', 'bar:foo', 'foo:3');
        is $res, "OK 4\r\n";

        note "simple add 0";
        $res = $client->add('collection1', 'bar:foo', 'foo:0');
        is $res, "OK 4\r\n";

        note "simple get";
        $res = $client->get('collection1', 'bar', 'foo');
        is $res, "OK 4\r\n";

        note "finalize";
        $res = $client->quit;
        is $res, 1;
    }
);

