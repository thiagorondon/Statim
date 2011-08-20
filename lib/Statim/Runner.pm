
use strict;
use warnings;

package Statim::Runner;

sub new {
    my ( $class, $self ) = @_;
    bless $self, $class;
    return $self;
}

sub run {
    my $self = shift;

    $self->{engine}->{storage} = $self->{storage};

    $self->{engine}->init;
    $self->{engine}->start;
}

1;

