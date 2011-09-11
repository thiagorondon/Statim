
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

    my $field_count = 0;
    my $field_enum  = 0;

    foreach my $item ( keys $conf ) {

        die "You must define fields in [$item]"
          unless defined( $conf->{$item}->{fields} );

        my $period = $conf->{$item}->{period};
        die "You must define period in [$item]"
          unless defined($period);
        die "Period must be positive integer"
          unless $period =~ /^\d+$/;

        foreach my $field ( keys $conf->{$item}->{fields} ) {
            my $type = $conf->{$item}->{fields}->{$field};

            die "The field [$field]  must be enum or count"
              unless $type =~ /^(enum|count)$/;

            $field_count++ if $type eq 'count';
            $field_enum++  if $type eq 'enum';

        }

    }

    die "You must defined one count field" unless $field_count == 1;

    return $conf;
}

1;

