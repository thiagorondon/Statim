
package Statim::Command;

use strict;
use warnings;

use Statim;
use base qw(Statim::Step);

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

sub set {
    my $self = shift;
    return '+parser' unless scalar(@_) > 1;
    $self->_storage->del( @_ );
    return $self->_storage->add( @_ );
}

sub get {
    my $self = shift;
    return '+parser' unless scalar(@_) > 1;
    return $self->_storage->get( @_ );
}

sub period {
    my ($self, $collection) = @_;
    return '+no collection' unless $collection;
    my $ret = $self->_storage->_get_period($collection);
    return $ret ? $ret : '+no collection';
}

sub step {
  my ($self, $collection, $epoch) = @_;
  return '+no collection' unless $collection;
  return '+no epoch' unless $epoch;
  my $period = $self->_storage->_get_period($collection);
  return $self->_get_step($period, $epoch);
}

1;
