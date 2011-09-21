
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

sub del {
    my $self = shift;
    return '+parser' unless scalar(@_) > 1;
    return $self->_storage->del( @_ );
}

sub add {
    my $self = shift;
    return '+parser' unless scalar(@_) > 1;
    return $self->_storage->add( @_ );
}

sub get {
    my $self = shift;
    return '+parser' unless scalar(@_) > 1;
    return $self->_storage->get( @_ );
}

sub period {
    my ($self, $collection) = @_;
    return $self->_storage->_get_period($collection);
}

1;
