#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib/";

use Statim::Server::AnyEvent;

my $host = undef;
my $port = 12345;

my $redis_host = '127.0.0.1';
my $redis_port = '6379';

my $server = Statim::Server::AnyEvent->new(
    {   redis_host => $redis_host,
        redis_port => $redis_port

    }
);

$server->start_listen( $host, $port );

AE::cv->recv();

