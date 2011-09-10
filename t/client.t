use warnings;
use strict;

use Test::More tests => 6;
use Test::TCP;

use lib 't/tlib';
use Test::Statim::Runner;
use Test::Statim::Config;

use Statim;
use Statim::Client;

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

        my $client = Statim::Client->new(
            {   host => '127.0.0.1',
                port => $port
            }
        );

        note "version";
        my $res = $client->version;
        is $res, 'OK ' . $Statim::VERSION . "\r\n";

        note "simple add 1";
        $res = $client->add( 'collection', 'bar:foo', 'jaz:boo', 'foo:1' );
        is $res, "OK 1\r\n";

        note "simple add 3";
        $res = $client->add( 'collection', 'bar:foo', 'jaz:boo', 'foo:3' );
        is $res, "OK 4\r\n";

        note "simple add 0";
        $res = $client->add( 'collection', 'bar:foo', 'jaz:boo', 'foo:0' );
        is $res, "OK 4\r\n";

        note "simple get";
        $res = $client->get( 'collection', 'bar:foo', 'jaz:boo', 'foo' );
        is $res, "OK 4\r\n";

        note "finalize";
        $res = $client->quit;
        is $res, 1;
    }
);

