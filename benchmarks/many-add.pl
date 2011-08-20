#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use Benchmark ':all';

use FindBin qw($Bin);
use lib "$Bin/tlib";
use lib "$Bin/../lib";
use Test::SpawnRedisServer;
use Test::TCP;

my ( $c, $srv ) = redis();
END { $c->() if $c }

use Statim;
use Statim::Server::AnyEvent;

my ( $redis_host, $redis_port ) = split( ':', $srv );
my $host = undef;
my $port = empty_port();

my $pid = fork();

if ( $pid > 0 ) {
    sleep(2);
    my $sock = IO::Socket::INET->new(
        PeerPort => $port,
        PeerAddr => '127.0.0.1',
        Proto    => 'tcp'
    ) or die "Cannot open client socket: $!";

    my $count = 1000;
    my $t = timeit(
        $count => sub {
            print {$sock} 'add collection1 bar:foo foo:1';
            my $res = <$sock>;
        }
    );

    print "$count loops of other code took:",timestr($t),"\n";

    print {$sock} 'get collection1 bar foo';
    my $res = <$sock>;
    warn "$res";

    kill 9, $pid;
    wait;

}
else {
    my $server = Statim::Server::AnyEvent->new(
        {
            redis_host => $redis_host,
            redis_port => $redis_port
        }
    );
    $server->start_listen( $host, $port );
    AE::cv->recv();
}

