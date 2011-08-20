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

        my $sock = IO::Socket::INET->new(
            PeerPort => $port,
            PeerAddr => '127.0.0.1',
            Proto    => 'tcp'
        ) or die "Cannot open client socket: $!";

        note "simple add 1";
        print {$sock} "\n";
        my $res = <$sock>;
        is $res, "CLIENT ERROR parser\r\n";

        note "finalize";
        print {$sock} "quit\n";
    }
);

