#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib/";

use Statim::Runner;
use Statim::Engine::AnyEvent;
use Statim::Storage::Redis;

my $host = undef;
my $port = 12345;

my $redis_host = '127.0.0.1';
my $redis_port = '6379';

my $storage = Statim::Storage::Redis->new({
    redis_host => $redis_host,
    redis_port => $redis_port
});

my $engine = Statim::Engine::AnyEvent->new(
    { host => $host,
      port => $port 
    }
);

my $app = Statim::Runner->new({ 
        storage => $storage,
        engine => $engine
    });

$app->run;

