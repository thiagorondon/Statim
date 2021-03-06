use warnings;
use strict;

use Test::More tests => 3;
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
        "aggregate" : "uniq",
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

        note "simple add 1";
        print {$sock} 'add collection bar:jaz foo:1';
        my $res = <$sock>;
        is $res, "OK 1\r\n";

        note "simple add 3";
        print {$sock} 'add collection bar:jaz foo:3';
        $res = <$sock>;
        is $res, "CLIENT ERROR this period already have a value\r\n";

        note "simple get";
        print {$sock} 'get collection bar:jaz foo';
        $res = <$sock>;
        is $res, "OK 1\r\n";

    }
);

