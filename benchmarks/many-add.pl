#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use Benchmark ':all';

use FindBin qw($Bin);
use lib "$Bin/tlib";
use lib "$Bin/../lib";
use Test::Statim::Runner;
use Test::TCP;

use Statim;

my $port = empty_port();

my $pid = fork();
my @opts = (qw/foo jaz buz toc/);

if ( $pid > 0 ) {
    sleep(2);
    print "start clients\n";
    my $sock = IO::Socket::INET->new(
        PeerPort => $port,
        PeerAddr => '127.0.0.1',
        Proto    => 'tcp'
    ) or die "Cannot open client socket: $!";

    my $count = 10000;
    my $t     = timeit(
        $count => sub {
            my $val = $opts[int(rand(scalar(@opts)))];
            my $val_count = int(rand(10));
            print {$sock} "add collection1 bar:$val foo:$val_count";
            my $res = <$sock>;
        }
    );

    print "$count loops of other code took:", timestr($t), "\n";

    foreach my $item (@opts) {
        print {$sock} "get collection1 bar:$item foo";
        my $res = <$sock>;
        warn "$res";
    }

    kill 9, $pid;
    wait;

}
else {
    my $app = test_statim_server($port);
    $app->run;

}

