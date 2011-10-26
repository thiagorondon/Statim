use warnings;
use strict;

use Test::More tests => 6;
use Test::TCP;

use lib 't/tlib';
use Test::Statim::Runner;

use Statim;

use Test::Statim::Config;
my $config = test_statim_gen_config;
$ENV{'STATIM_CONFIG'} = $config;

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

        note "add without args";
        print {$sock} "add collection\n";
        $res = <$sock>;
        is $res, "CLIENT ERROR parser\r\n";

        note "get without args";
        print {$sock} "get collection\n";
        $res = <$sock>;
        is $res, "CLIENT ERROR parser\r\n";

        note "add without all vars";
        print {$sock} 'add collection bar:jaz foo:1';
        $res = <$sock>;
        is $res, "CLIENT ERROR missing args\r\n";

        note "add with ts and step";
        print {$sock} 'add collection bar:test2 jaz:boo foo:1 ts:123456790 step:10';
        $res = <$sock>;
        is $res, "CLIENT ERROR You must define only step or ts\r\n";
 
        note "get with wront ts range";
        print {$sock} 'get collection bar:test2 jaz:boo foo ts:123456790-12';
        $res = <$sock>;
        is $res, "CLIENT ERROR Your ts range is wrong, min > max\r\n";
 
        note "finalize";
        print {$sock} "quit\n";
    }
);

