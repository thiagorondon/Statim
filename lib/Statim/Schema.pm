
package Statim::Schema;

use Statim::Config;

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    return $self;
}

sub get {
    my $config = Statim::Config->new;
    my $conf   = $config->get( $config->file );

    my @collections;

    foreach my $item ( keys $conf ) {

        die "You must define period in [$item]"
          unless defined( $conf->{$item}->{period} );
        die "You must define fields in [$item]"
          unless defined( $conf->{$item}->{fields} );

        foreach my $field ( keys $conf->{$item}->{fields} ) {
            die "The field [$field]  must be enum or count"
              unless $conf->{$item}->{fields}->{$field} =~ /^(enum|count)$/;
        }

    }

    return $conf;
}

1;

