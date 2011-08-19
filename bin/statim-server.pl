#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib/";

use Statim::Server::AnyEvent;

my $host = undef;
my $port = 12345;

my $server = Statim::Server::AnyEvent->new();
$server->start_listen($host, $port);

AE::cv->recv();

