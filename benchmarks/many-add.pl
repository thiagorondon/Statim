#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use Benchmark ':all';
use Data::Dumper;

use FindBin qw($Bin);
use lib "$Bin/tlib";
use lib "$Bin/../lib";
use Test::Statim::Runner;
use Test::TCP;

use List::MoreUtils qw{uniq};

use Statim;

use Chart::Clicker;
use Chart::Clicker::Context;
use Chart::Clicker::Data::DataSet;
use Chart::Clicker::Data::Marker;
use Chart::Clicker::Data::Series;
use Geometry::Primitive::Rectangle;
use Graphics::Color::RGB;
use Geometry::Primitive::Circle;

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
            my $step = int(rand(3)) + 1;
            print {$sock} "add collection bar:$val foo:$val_count step:$step";
            #warn "add collection bar:$val foo:$val_count";
            my $res = <$sock>;
            #warn $res;
        }
    );

    print "$count loops of other code took:", timestr($t), "\n";

    my @hours;
    my %bw;
    foreach my $item (@opts) {
        warn "$item";
      
        print {$sock} "get collection bar:$item foo:list step:0-30";
        my $res = <$sock>;
        
        $res =~ s/OK //;
        #warn "$res";
        my @results = split(' ', $res);
        
        my @bws;   
        foreach my $result (@results) {
          my ($epoch, $total) = split(':', $result);
          push(@hours, $epoch);
          push(@bws, $total);
        }
        $bw{$item} = \@bws;
        #print "\n";
    }

    my $cc = Chart::Clicker->new(width => 1000, height => 250, format => 'png');
    @hours = uniq(@hours);
    
    my @series;
    foreach my $item (keys %bw) {
      my $serie = Chart::Clicker::Data::Series->new(
          keys => \@hours,
          values => $bw{$item},
          name => $item
      );
      push(@series, $serie);
    }

    my $ds = Chart::Clicker::Data::DataSet->new(series => [ @series ]);

    $cc->title->text('benchmark/many-add.pl');
    $cc->title->padding->bottom(2);
    $cc->add_to_datasets($ds);

    my $defctx = $cc->get_context('default');

    $defctx->range_axis->label('counter');
    $defctx->domain_axis->label('epoch time');
    $defctx->renderer->brush->width(2);
    $cc->write_output('line.png');

    kill 9, $pid;
    wait;

}
else {
    my $app = test_statim_server($port);
    $app->run;

}

