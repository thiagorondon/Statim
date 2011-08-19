
package Statim::Server::Line;

use Statim::Parser;
use Statim::Cmds;

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    return $self;
}

sub do {
    my ( $self, $line ) = @_;

    my $parser = Statim::Parser->new;
    my $cmds   = Statim::Cmds->new;

    my @args = $parser->do($line);
    my $ret;
    unless (@args) {
        $ret = "ERROR";
    }
    else {
        my $cmd = shift(@args);
        $ret = $cmds->$cmd(@args);
    }
    return $ret;
}

1;
