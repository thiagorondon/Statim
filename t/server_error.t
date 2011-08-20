use warnings;
use strict;

use Test::More tests => 1;
use Test::TCP;

use lib 't/tlib';
use Test::SpawnRedisServer;

my ( $c, $srv ) = redis();
END { $c->() if $c }

use Statim;
use Statim::Server::AnyEvent;

my ( $redis_host, $redis_port ) = split( ':', $srv );
my $host = undef;

test_tcp(
    server => sub {
        my $port   = shift;
        my $server = Statim::Server::AnyEvent->new(
            {   redis_host => $redis_host,
                redis_port   => $redis_port
            }

        );
        $server->start_listen( $host, $port );

        AE::cv->recv();
    },
    client => sub {
        my $port = shift;

        my $sock = IO::Socket::INET->new(
            PeerPort => $port,
            PeerAddr => '127.0.0.1',
            Proto    => 'tcp'
        ) or die "Cannot open client socket: $!";

        note "simple add collection with no config in the server";
        print {$sock} 'add baz bar:foo foo:1';
        my $res = <$sock>;
        is $res, "SERVER ERROR no collection\r\n";

        note "finalize";
        print {$sock} "quit\n";
    }
);

