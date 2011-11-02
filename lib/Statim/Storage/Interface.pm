
package Statim::Storage::Interface;

use base qw(Class::Data::Inheritable Statim::Step Statim::Ts);

__PACKAGE__->mk_classdata( '_conf' => undef );

sub conf {
    my $self = shift;
    $self->_conf(@_) if @_;
    return $self->_conf or undef;
}

sub _get_period {
    my ( $self, $collection ) = @_;
    return $self->conf->{$collection}->{period};
}

1;

