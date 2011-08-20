use warnings;
use strict;

use Test::More tests => 1;
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

        note "simple add 1";
        print {$sock} "\n";
        my $res = <$sock>;
        is $res, "CLIENT ERROR parser\r\n";

        note "finalize";
        print {$sock} "quit\n";
    }
);

