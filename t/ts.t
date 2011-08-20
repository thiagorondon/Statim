use warnings;
use strict;

use Test::More tests => 4;
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

        note "simple add 1";
        print {$sock} 'add collection1 bar:str jaz:ing ts:1313812776 foo:1';
        my $res = <$sock>;
        is $res, "OK 1\r\n";

        note "simple add 3";
        print {$sock} 'add collection1 jaz:ing bar:str ts:1313012776 foo:1';
        $res = <$sock>;
        is $res, "OK 1\r\n";

        note "simple add 0";
        print {$sock} 'add collection1 bar:str jaz:ing ts:1313812776 foo:1';
        $res = <$sock>;
        is $res, "OK 2\r\n";

        note "simple get";
        print {$sock} 'get collection1 bar jaz ts:1313812776 foo';
        $res = <$sock>;
        is $res, "OK 2\r\n";


        note "finalize";
        print {$sock} "quit\n";
    }
);

