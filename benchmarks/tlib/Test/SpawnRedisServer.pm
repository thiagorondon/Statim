package    # Hide from PAUSE
  Test::SpawnRedisServer;

use strict;
use warnings;
use File::Temp;
use POSIX ":sys_wait_h";
use base qw( Exporter );

our @EXPORT = qw( redis );

sub redis {
  my ($fh, $fn) = File::Temp::tempfile();
  my $port = 11011 + ($$ % 127);

  $fh->print("
    appendonly no
    vm-enabled no
    daemonize no
    port $port
    bind 127.0.0.1
    loglevel notice
    logfile redis-server.log
  ");
  $fh->flush;

  #Test::More::diag("Redis port $port, cfg $fn") if $ENV{REDIS_DEBUG};

  ## My local redis PATH
  $ENV{PATH} = "$ENV{PATH}:/usr/local/redis/sbin";

  my $c;
  eval { $c = spawn_server($ENV{REDIS_SERVER_PATH} || 'redis-server', $fn) };
  if (my $e = $@) {
    #Test::More::plan skip_all => "Could not start redis-server: $@";
    return;
  }

  return ($c, "127.0.0.1:$port");
}

sub spawn_server {
  my $pid = fork();
  if ($pid) {    ## Parent
    sleep(1);    ## FIXME: we should PING it until he is ready
    return sub {
      kill(15, $pid);

      my $try = 0;
      while ($try++ < 10) {
        my $ok = waitpid($pid, WNOHANG);
        $try = -1, last if $ok > 0;
        sleep(1);
      }
      unlink('redis-server.log');
      unlink('dump.rdb');
    };
  }
  elsif (defined $pid) {    ## Child
    exec(@_);
    die "Failed exec of '@_': $!, ";
  }

  die "Could not fork(): $!";
}


1;
