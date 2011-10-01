
package Statim::Client;

use strict;
use warnings;
use IO::Socket::INET;

sub new {
    my ( $class, $self ) = @_;
    $self = {} unless defined($self);
    bless $self, $class;
    $self->_connect;
    return $self;
}

sub _connect {
    my $self = shift;
    $self->{sock} = IO::Socket::INET->new(
        PeerPort => $self->{port},
        PeerAddr => $self->{host},
        Proto    => 'tcp'
    ) or die "Cannot open client socket: $!";
}

sub _send_command {
    my ( $self, @cmds ) = @_;
    my $sock = $self->{sock};
    my $cmd = join( ' ', @cmds );
    print $sock $cmd . "\r\n";
    my $res = <$sock>;
    return $res;
}

foreach my $name ( 'add', 'version', 'get', 'del', 'set' ) {
    no strict 'refs';
    *$name = sub {
        my $self = shift;
        return $self->_send_command( $name, @_);
    }
}

sub period {
    my ( $self, $collection ) = @_;
    return '+no collection' unless $collection;
    return $self->_send_command('period', $collection);
}

sub quit { 1 }

1;

