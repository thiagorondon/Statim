use warnings;
use strict;

use Test::More tests => 12;
use Test::TCP;

use lib 't/tlib';
use Test::Statim::Runner;
use Statim;

use Test::Statim::Config;
my $config = test_statim_gen_config(
'
{ 
    "collection" : {
        "period" : "84600",
        "aggregate" : "sum",
        "fields" : {
            "foo" : "count",
            "bar" : "enum",
        }
    }
}
');

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

        note "version";
        print {$sock} "version\n";
        my $res = <$sock>;
        is $res, 'OK ' . $Statim::VERSION . "\r\n";

        note "period";
        print {$sock} "period collection\n";
        $res = <$sock>;
        is $res, "OK 84600\r\n";

        note "simple add 1";
        print {$sock} 'add collection bar:jaz foo:1';
        $res = <$sock>;
        is $res, "OK 1\r\n";

        note "simple add 3";
        print {$sock} 'add collection bar:jaz foo:3';
        $res = <$sock>;
        is $res, "OK 4\r\n";

        note "simple add 0";
        print {$sock} 'add collection bar:jaz foo:0';
        $res = <$sock>;
        is $res, "OK 4\r\n";

        note "simple add 0";
        print {$sock} 'add collection bar:boo foo:1';
        $res = <$sock>;
        is $res, "OK 1\r\n";

        note "simple get";
        print {$sock} 'get collection bar:jaz foo';
        $res = <$sock>;
        is $res, "OK 4\r\n";

        note "simple get";
        print {$sock} 'get collection bar:boo foo';
        $res = <$sock>;
        is $res, "OK 1\r\n";

        note "simple get without args";
        print {$sock} 'get collection foo';
        $res = <$sock>;
        is $res, "OK 5\r\n";

        note "simple add -1";
        print {$sock} 'add collection bar:jaz foo:-1';
        $res = <$sock>;
        is $res, "OK 3\r\n";

        note "simple del";
        print {$sock} 'del collection bar:boo foo';
        $res = <$sock>;
        is $res, "OK 1\r\n";

        note "simple del (again)";
        print {$sock} 'del collection bar:boo foo';
        $res = <$sock>;
        is $res, "SERVER ERROR not exist\r\n";

        note "finalize";
        print {$sock} "quit\r\n";
    }
);

