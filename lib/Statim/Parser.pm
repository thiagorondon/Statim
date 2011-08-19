
package Statim::Parser;

our @valid_cmds = ( 'add', 'get', 'version', 'quit' );

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    return $self;
}

sub do {
    my ( $self, $message ) = @_;

    # TODO: escape_char
    my @args = split( ' ', $message );

    my $cmd = shift(@args);
    return () unless grep { /$cmd/ } @valid_cmds;
    return ( $cmd, @args );
}

1;

