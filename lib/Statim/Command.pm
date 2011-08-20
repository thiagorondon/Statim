
package Statim::Command;

use strict;
use warnings;

use Statim;

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
    return $self->{storage};
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