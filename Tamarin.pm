# Copyright (c) 2024 Julian Parkin and Mahesh Tripunitara
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
