use warnings;
use strict;

use Test::More tests => 2;
use Test::TCP;

use lib 't/tlib';
use Test::Statim::Runner;

use Statim;

test_tcp(
    server => sub {
        my $port = shift;
        my $app  = test_statim_server($port);
        $app->run;

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

        note "simple get collection with no config in the server";
        print {$sock} 'get baz bar foo';
        $res = <$sock>;
        is $res, "SERVER ERROR no collection\r\n";

        note "finalize";
        print {$sock} "quit\n";
    }
);

