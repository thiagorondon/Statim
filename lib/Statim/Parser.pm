
package Statim::Parser;

use strict;
use warnings;

our @valid_cmds = ( 'add', 'get', 'set', 'del', 'version', 'quit', 'period' );

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    return $self;
}

sub do {
    my ( $self, $message ) = @_;
    return () unless $message;

    # TODO: escape_char
    my @args = split( ' ', $message );

    my $cmd = shift(@args);

    foreach my $item (@args) {
        return () unless $item =~ /^[A-Za-z0-9\_\:\*\-]*$/;
        return () if $item =~ /:$/;
        return () if $item =~ /-$/;
    }

    return () unless grep {/$cmd/} @valid_cmds;
    return ( $cmd, @args );

}

1;

