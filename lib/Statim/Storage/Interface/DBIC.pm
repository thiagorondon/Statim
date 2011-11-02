
package Statim::Storage::Interface::DBIC;

use strict;
use warnings;

use Statim::Schema;

use base qw(Statim::Storage::Interface);

our $conf;

sub new {
  my ( $class, $self ) = @_;
  $self = {} unless defined $self;
  bless $self, $class;

  my $schema = Statim::Schema->new;
  $conf = $schema->get;
  $self->conf($conf);
  return $self;
}

1;
