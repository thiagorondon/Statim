
package Statim::Config;

use Config::JSON;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub get {
    my ($self, $filename) = @_;
    my $config = Config::JSON->new($filename);
    $config->get();
}

1;

