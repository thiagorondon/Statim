
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

sub _get_counter {
    my ( $self, $collection ) = @_;
    return unless ref( $self->conf->{$collection}->{fields} ) eq 'HASH';
    foreach my $field ( keys %{ $self->conf->{$collection}->{fields} } ) {
        my $type = $self->conf->{$collection}->{fields}->{$field};
        return $field if $type eq 'count';
    }
}

sub _check_collection {
    my ( $self, $collection ) = @_;
    return 0 unless $collection;
    return defined( $self->conf->{$collection}->{fields} ) ? 1 : 0;
}

sub _parse_args_to_add {
    my ( $self, $collection, @args ) = @_;

    my ( $counter, $incrby, %data );
    my $declare_args = 0;
    my @fields       = keys %{ $self->conf->{$collection}->{fields} };

    foreach my $field (@fields) {
        my $type = $self->conf->{$collection}->{fields}->{$field};
        return '+wrong declare field type'
          unless $type eq 'enum'
              or $type eq 'count';    #schema error

        foreach my $arg (@args) {
            my ( $var, $value ) = split( /:/, $arg );
            next unless $var eq $field;
            $declare_args++;

            if ( $type eq 'enum' ) {
                $data{$field} = $value;
            }
            else {
                $counter = $field;
                $incrby  = $value;
            }

            # TODO: Add default -> schema error ?
        }
    }

    return '+missing args' unless $declare_args == scalar(@fields);
    return ( $counter, $incrby, %data );
}

sub _arrange_key_by_hash {
    my ( $self, %data ) = @_;
    my @args;
    foreach my $item ( sort keys %data ) {
        push( @args, $item, $data{$item} );
    }
    return @args;
}

# TODO: bug, we need to make sure if we dont have
# # $counter . 'bla' field, for example.

sub _parse_args_to_get {
    my ( $self, @names ) = @_;
    my $collection = shift(@names);
    my $count_field = $self->_get_counter($collection) || '';
    my ($count_to_parse) =
      $count_field ? grep { /^$count_field/ } @names : ('');
    my ( undef, $count_func ) =
      $count_to_parse =~ /:/
      ? split( ':', $count_to_parse )
      : ( $count_field, 'sum' );

    return ( $collection, $count_func,
        grep { !/^(ts:|step:|$count_field|$count_field:)/ } @names );
}

sub _get_timestamp {
    my ( $self, $collection, @args ) = @_;

    my $has_ts   = 0;
    my $has_step = 0;
    foreach my $arg (@args) {
        my ( $var, undef ) = split( /:/, $arg );
        $has_ts   = 1 if $var eq 'ts';
        $has_step = 1 if $var eq 'step';
    }
    return '+You must define only step or ts' if $has_ts and $has_step;
    return $has_step ? $self->_get_step( $self->_get_period($collection), @args ) : $self->_get_ts(@args);
}

1;

