use warnings;
use strict;

use Test::More tests => 5;
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
        print {$sock} 'get collection1 bar:str jaz:ing ts:1313812776 foo';
        $res = <$sock>;
        is $res, "OK 2\r\n";

        note "simple get";
        print {$sock} 'get collection1 bar:str jaz:ing ts:13136111-1313812776 foo';
        $res = <$sock>;
        is $res, "OK 3\r\n";

        note "finalize";
        print {$sock} "quit\n";
    }
);

