
package Statim::Command::Line;

use strict;
use warnings;

use Statim::Parser;
use Statim::Command;

sub new {
    my ($class, $self) = @_;
    bless $self, $class;
    return $self;
}

sub do {
    my ( $self, $line ) = @_;

    my $parser = Statim::Parser->new;
    my $cmds   = Statim::Command->new({
            storage => $self->{storage}
        });

    my @args = $parser->do($line);
    my $ret;
    unless (@args) {
        $ret = "CLIENT ERROR parser";
    }
    else {
        my $cmd = shift(@args);
        $ret = $cmds->$cmd(@args);
        my $se = defined($ret) ? substr($ret, 0, 1) : '';
        if ($se eq '-') {
            $ret = "SERVER ERROR " . substr($ret, 1);
        } elsif ($se eq '+') {
            $ret = "CLIENT ERROR " . substr($ret, 1);  
        } else {
            # TODO: Bug here, with no data we return just 'OK' in get.
            $ret = defined($ret) ? "OK $ret" : 'OK 0';
        }
    }
    return $ret;
}

1;
