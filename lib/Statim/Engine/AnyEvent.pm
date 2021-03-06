
package Statim::Engine::AnyEvent;

use strict;
use warnings;

use Socket qw(IPPROTO_TCP TCP_NODELAY);
use Errno qw(EAGAIN EINTR);

use AnyEvent;
use AnyEvent::Util qw(WSAEWOULDBLOCK);
use AnyEvent::Socket;

use Statim::Command::Line;

use constant CTRL_D => 4;

sub new {
    my ( $class, $self ) = @_;
    bless $self, $class;
    return $self;
}

sub init {
    my ($self) = @_;
    my $host   = $self->{host};
    my $port   = $self->{port};
    $self->{server} = tcp_server( $host, $port, $self->_accept_handler(), \&prepare_handler );
}

sub start {
    AE::cv->recv();
}

sub prepare_handler {
    my ( $fh, $host, $port ) = @_;
    warn "Listening on $host:$port\n";
}

sub _accept_handler {
    my $self = shift;

    return sub {
        my $sock = shift;
        #my ( $sock, $peer_host, $peer_port ) = @_;

        #warn "Accepted connection from $peer_host:$peer_port\n";
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

    my $cmd_line = Statim::Command::Line->new( { storage => $self->{storage} } );

    $headers_io_watcher = AE::io $sock, 0, sub {
        while ( defined( my $line = <$sock> ) ) {
            $line =~ s/\r?\n$//;

            #print "Received: [$line] " . length($line) . ' ' . ord($line) . "\n";

            if ( length($line) == 1 and ord($line) == CTRL_D ) {
                print $sock "Received EOF.  Closing connection...\r\n";
                undef $headers_io_watcher;
            }
            else {

                #print $sock "You sent [$line]\r\n";
                my $ret = $cmd_line->do($line);
                if ($ret and $line ne 'quit') {
                    print $sock "$ret\r\n";
                }
                else {    # quit
                    print $sock "Bye...\r\n";
                    undef $headers_io_watcher;
                }

            }
        }

        if ( $! and $! != EAGAIN && $! != EINTR && $! != WSAEWOULDBLOCK ) {
            undef $headers_io_watcher;
            die $!;
        }
        elsif ( !$! ) {
            undef $headers_io_watcher;
            #die "client disconnected";
        }
    };
}

1;

