
use Test::More tests => 3;
use_ok('Statim::Command');
use Statim;

my $cmds = Statim::Command->new;
is( $cmds->version, $Statim::VERSION );
is( $cmds->quit,    0 );

