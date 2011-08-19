
use Test::More tests => 3;
use_ok('Statim::Cmds');
use Statim;

my $cmds = Statim::Cmds->new;

is( $cmds->version, $Statim::VERSION );
is( $cmds->quit, 0 );

