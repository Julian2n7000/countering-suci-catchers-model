use strict;
use warnings;

package Tamarin;

our @EXPORT = qw( prove );

our $VERSION = '0.01';

sub wait_eof {
   my $tamarin = shift;

   eval {
      local $SIG{ALRM} = sub { die "alarm\n" };

      alarm 10;

      while (local $_ = <$tamarin>) {}

      alarm 0;
   };

   if ($@) {
      die unless $@ eq "alarm\n";

      return 0;
   }

   return 1;
}

sub prove {
   my %lemma = (
      args    => '',
      debug   => 0,
      timeout => 10*60,    # Default 10m timeout
      @_
   );

   my $command = sprintf( "tamarin-prover %s --prove=%s %s",
                          $lemma{args}, $lemma{lemma}, $lemma{theory} );

   $command .= " 2>/dev/null" unless $lemma{debug};

   my $pid = open(my $tamarin, '-|', $command)
      or die "Unable to start Tamarin: $!";

   my $status = 'failed';
   my $steps  = 0;
   my $start  = time;

   eval {
      local $SIG{ALRM} = sub { die "alarm\n" };

      alarm $lemma{timeout};

      while (local $_ = <$tamarin>) {
         if (/^ *$lemma{lemma} \([\w\-]+\): verified \((\d+) steps\)/) {
            $status = 'proven';
            $steps  = $1;
         }
      }

      alarm 0;
   };

   my $time = time - $start;

   if ($@) {
      die unless $@ eq "alarm\n";

      $status = 'timeout';

      kill 'SIGINT',  $pid;
      kill 'SIGTERM', $pid unless wait_eof($tamarin);
   }

   close $tamarin;

   return $status, $time, $steps;
}

1;
