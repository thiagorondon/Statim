use warnings;
use strict;

use Test::More tests => 15;
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

        my $period = '84600';
        my $ts1 = $period;
        my $ts2 = $period * 4;
        my $ts3 = $period * 10;
        my $ts4 = $period * 15;

        note "simple add bar:jaz foo:1";
        print {$sock} "add collection bar:jaz foo:1 ts:$ts1";
        my $res = <$sock>;
        is $res, "OK 1\r\n";

        note "simple add bar:jaz foo:3";
        print {$sock} "add collection bar:jaz foo:3 ts:$ts2";
        $res = <$sock>;
        is $res, "OK 3\r\n";

        note "simple add bar:jaz foo:2";
        print {$sock} "add collection bar:jaz foo:2 ts:$ts3";
        $res = <$sock>;
        is $res, "OK 2\r\n";

        note "simple add bar:ula foo:10";
        print {$sock} "add collection bar:ula foo:10 ts:$ts2";
        $res = <$sock>;
        is $res, "OK 10\r\n";
        
        note "simple get bar:jaz foo:max";
        print {$sock} "get collection bar:jaz ts:$ts1-$ts3 foo:max";
        $res = <$sock>;
        is $res, "OK 3\r\n";

        note "simple get bar:ula foo:max";
        print {$sock} "get collection bar:ula ts:$ts1-$ts3 foo:max";
        $res = <$sock>;
        is $res, "OK 10\r\n";

        note "simple get bar:* foo:max";
        print {$sock} "get collection bar:* ts:$ts1-$ts3 foo:max";
        $res = <$sock>;
        is $res, "OK 10\r\n";

        note "simple get bar:jaz foo:min";
        print {$sock} "get collection bar:jaz ts:$ts1-$ts3 foo:min";
        $res = <$sock>;
        is $res, "OK 1\r\n";

        note "simple add bar:ula foo:0";
        print {$sock} "add collection bar:ula foo:0 ts:$ts4";
        $res = <$sock>;
        is $res, "OK 0\r\n";

        note "simple get bar:ula foo:min";
        print {$sock} "get collection bar:ula ts:$ts1-$ts4 foo:min";
        $res = <$sock>;
        is $res, "OK 0\r\n";

        note "simple get foo:min";
        print {$sock} "get collection ts:$ts1-$ts3 foo:min";
        $res = <$sock>;
        is $res, "OK 1\r\n";

        note "simple get bar:jaz foo:sum";
        print {$sock} "get collection bar:jaz ts:$ts1-$ts3 foo:sum";
        $res = <$sock>;
        is $res, "OK 6\r\n";

        note "simple get foo:sum";
        print {$sock} "get collection ts:$ts1-$ts3 foo:sum";
        $res = <$sock>;
        is $res, "OK 16\r\n";

        note "simple get foo:avg";
        print {$sock} "get collection ts:$ts1-$ts3 foo:avg";
        $res = <$sock>;
        is $res, "OK 4\r\n";

        note "simple get foo:distinct";
        print {$sock} "get collection ts:$ts1-$ts3 foo:distinct";
        $res = <$sock>;
        is $res, "OK 4\r\n";

    }
);

