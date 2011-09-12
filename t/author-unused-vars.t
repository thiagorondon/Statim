
use Test::More;

eval "use Test::Vars";
plan skip_all => "Test::Vars required for testing unused vars"
  if $@;
all_vars_ok( ignore_vars => [qw($fh)] );
