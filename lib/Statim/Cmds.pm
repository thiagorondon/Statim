
package Statim::Cmds;

use strict;
use warnings;

use Statim;
use Statim::Server::Storage;

my $storage = Statim::Server::Storage->new;

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    return $self;
}

sub version { $Statim::VERSION }

sub quit { 0 }

sub add {
    my ( $self, $name, @args ) = @_;
    #warn "add: $name";
    #warn "args : " . join('::', @args);
    return 'OK ' . $storage->add( $name, @args );
}

sub get {
    my ( $self, $name ) = @_;
    return 'OK ' . $storage->get($name);
}

1;
