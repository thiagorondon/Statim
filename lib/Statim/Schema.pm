
package Statim::Schema;

use strict;
use warnings;

use Statim::Config;
use base qw(Class::Data::Inheritable);

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    return $self;
}

__PACKAGE__->mk_classdata( '_data' => undef );

sub data {
    my $self = shift;

    $self->_data(@_) if @_;
    return $self->_data if $self->_data;
    
    my $config = Statim::Config->new;
    my $conf   = $config->get( $config->file );
    $self->_data($conf);
    return $self->_data;
}

sub get {
    my $self = shift;
    my $conf = $self->data;

    my @collections;

    foreach my $item ( keys $conf ) {

        die "You must define fields in [$item]"
          unless defined( $conf->{$item}->{fields} );

        my $period = $conf->{$item}->{period};
        die "You must define period in [$item]"
          unless defined($period);
        die "Period must be positive integer"
          unless $period =~ /^\d+$/;

        foreach my $field ( keys $conf->{$item}->{fields} ) {
            die "The field [$field]  must be enum or count"
              unless $conf->{$item}->{fields}->{$field} =~ /^(enum|count)$/;
        }

    }

    return $conf;
}

1;

