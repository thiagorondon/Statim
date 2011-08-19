
package Statim::Server::AnyEvent;

use strict;
use warnings;

use Socket qw(IPPROTO_TCP TCP_NODELAY);
use Errno qw(EAGAIN EINTR);

use AnyEvent;
use AnyEvent::Util qw(WSAEWOULDBLOCK);
use AnyEvent::Socket;

use Statim::Server::Line;

use constant CTRL_D => 4;

sub new {
    my ( $class, $self ) = @_;
    bless $self, $class;
    return $self;
}

sub start_listen {
    my ( $self, $host, $port ) = @_;
    $self->{server} = tcp_server( $host, $port, $self->_accept_handler(), \&prepare_handler );
}

sub prepare_handler {
    my ( $fh, $host, $port ) = @_;
    warn "Listening on $host:$port\n";
}

sub _accept_handler {
    my $self = shift;

    return sub {
        my ( $sock, $peer_host, $peer_port ) = @_;

        warn "Accepted connection from $peer_host:$peer_port\n";
        return unless $sock;

        setsockopt( $sock, IPPROTO_TCP, TCP_NODELAY, 1 )
            or die "setsockopt(TCP_NODELAY) failed: $!";
        $sock->autoflush(1);

        $self->watch_socket($sock);
    };
}

sub watch_socket {
    my ( $self, $sock ) = @_;

    my $headers_io_watcher;

    my $cmd_line = Statim::Server::Line->new(
        {   redis_host => $self->{redis_host},
            redis_port   => $self->{redis_port}
        }
    );

    $headers_io_watcher = AE::io $sock, 0, sub {
        while ( defined( my $line = <$sock> ) ) {
            $line =~ s/\r?\n$//;
            print "Received: [$line] " . length($line) . ' ' . ord($line) . "\n";

            if ( length($line) == 1 and ord($line) == CTRL_D ) {
                print $sock "Received EOF.  Closing connection...\r\n";
                undef $headers_io_watcher;
            }
            else {

                #print $sock "You sent [$line]\r\n";
                my $ret = $cmd_line->do($line);
                if ($ret) {
                    print $sock "$ret\r\n";
                }
                else {    # quit
                    undef $headers_io_watcher;
                    die 'quit';
                }

            }
        }

        if ( $! and $! != EAGAIN && $! != EINTR && $! != WSAEWOULDBLOCK ) {
            undef $headers_io_watcher;
            die $!;
        }
        elsif ( !$! ) {
            undef $headers_io_watcher;
            die "client disconnected";
        }
    };
}

1;

