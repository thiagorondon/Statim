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
        my $port   = shift;
        my $app = test_statim_server($port);
        $app->run;
    },
    client => sub {
        my $port = shift;

        my $sock = IO::Socket::INET->new(
            PeerPort => $port,
            PeerAddr => '127.0.0.1',
            Proto    => 'tcp'
        ) or die "Cannot open client socket: $!";

        note "simple add enum:test1";
        print {$sock} 'add collection bar:test1 jaz:boo foo:1';
        my $res = <$sock>;
        is $res, "OK 1\r\n";

        note "simple add enum:test2";
        print {$sock} 'add collection bar:test2 jaz:boo foo:3';
        $res = <$sock>;
        is $res, "OK 3\r\n";

        note "simple get enum:test1";
        print {$sock} 'get collection bar:test1 jaz:boo foo';
        $res = <$sock>;
        is $res, "OK 1\r\n";

        note "simple get enum:test2";
        print {$sock} 'get collection bar:test2 jaz:boo foo';
        $res = <$sock>;
        is $res, "OK 3\r\n";

        note "simple get enum:*";
        print {$sock} 'get collection bar:* jaz:* foo';
        $res = <$sock>;
        is $res, "OK 4\r\n";

        note "simple get enum:test*";
        print {$sock} 'get collection bar:test* jaz:boo foo';
        $res = <$sock>;
        is $res, "OK 4\r\n";

        note "finalize";
        print {$sock} "quit\r\n";
    }
);

