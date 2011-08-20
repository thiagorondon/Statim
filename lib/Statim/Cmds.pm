
package Statim::Cmds;

use strict;
use warnings;

use Statim;
use Statim::Server::Storage;

sub new {
    my ( $class, $self ) = @_;
    $self = {} unless defined($self);
    bless $self, $class;
    return $self;
}

sub version {$Statim::VERSION}

sub quit {0}

sub _storage {
    my $self = shift;

    Statim::Server::Storage->new(
        {   redis_host => $self->{redis_host},
            redis_port => $self->{redis_port}
        }
    );
}

sub add {
    my $self = shift;
    return $self->_storage->add( @_ );
}

sub get {
    my $self = shift;
    return $self->_storage->get( @_ );
}

1;
