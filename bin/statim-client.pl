#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib/";

use Statim;
use Statim::Client;
use Getopt::Long;

my $client_host = '127.0.0.1';
my $client_port = '12345';
my $action;

sub parse_options {
    Getopt::Long::GetOptions(
        'h|help' => sub { $action='help' },
        'host=s' => \$client_host,
        'port=i' => \$client_port
    );

}

sub help {
    print <<EOF;
Usage: $0 [options] ...

Options:
  -h,--help     show this help
  --host        set statim server host
  --port        set statim server port

Examples:
   
   statim-client.pl add collection foo:bar count:1

EOF
    exit(0);
}

sub do {
    if ($action) {
        &help;
    }

    my $client = Statim::Client->new(
        {
            host => $client_host,
            port => $client_port
        }
    );

    my $cmd = shift(@ARGV);
    my $res = $client->$cmd(@ARGV);
    print $res;

}

unless (caller) {
    &parse_options;
    &do;
}

