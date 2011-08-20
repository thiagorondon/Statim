
package Statim::Command::Line;

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
        my $se = substr($ret, 0, 1);
        if ($se eq '-') {
            $ret = "SERVER ERROR " . substr($ret, 1);
        } else {
            $ret = "OK " . $ret;
        }
    }
    return $ret;
}

1;
