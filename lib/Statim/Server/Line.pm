
package Statim::Server::Line;

use Statim::Parser;
use Statim::Cmds;

sub new {
    my ($class, $self) = @_;
    bless $self, $class;
    return $self;
}

sub do {
    my ( $self, $line ) = @_;

    my $parser = Statim::Parser->new;
    my $cmds   = Statim::Cmds->new({
            redis_host => $self->{redis_host},
            redis_port => $self->{redis_port}
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
