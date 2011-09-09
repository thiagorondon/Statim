
package Statim::Config;

use Config::JSON;
use List::Util qw(first);

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub file {
    my $self = shift;

    my $filename = first { $_ and -f $_ } ($ENV{'STATIM_CONFIG'}, 'etc/config.json', '/etc/statim/config.json');
    die "error: we cant find config file" unless $filename;
    return $filename;
}


sub get {
    my ($self, $filename) = @_;
    my $config = Config::JSON->new($filename);
    $config->get();
}

1;

