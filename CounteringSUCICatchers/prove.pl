#!/usr/bin/env perl

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

use File::Basename;

use Tamarin;

my $SRC = dirname(__FILE__) . '/src';

my @LEMMAS = (
   # Existing sources and SQN lemmas
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'rand_autn_src',      args => "--heuristic=O --oraclename=$SRC/5G_AKA.oracle" },
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'sqn_ue_invariance',  args => "--heuristic=O --oraclename=$SRC/5G_AKA.oracle" },
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'sqn_hss_invariance', args => "--heuristic=O --oraclename=$SRC/5G_AKA.oracle" },
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'sqn_ue_src',         args => "--heuristic=O --oraclename=$SRC/5G_AKA.oracle" },
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'sqn_hss_src',        args => "--heuristic=O --oraclename=$SRC/5G_AKA.oracle" },
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'sqn_ue_nodecrease',  args => "--heuristic=O --oraclename=$SRC/5G_AKA_with_hsupi.pl" },
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'sqn_ue_unique',      args => "--heuristic=O --oraclename=$SRC/5G_AKA.oracle" },

   # Existing executability lemmas
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'executability_honest',         args => "--heuristic=O --oraclename=$SRC/5G_AKA_with_hsupi.pl" },
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'executability_keyConf_honest', args => "--heuristic=O --oraclename=$SRC/5G_AKA_with_hsupi.pl" },
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'executability_desync',         args => "--heuristic=O --oraclename=$SRC/5G_AKA_with_hsupi.pl" },
   # Takes longer than 1h; best to run seperately when needed
   # { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'executability_resync',         args => "--heuristic=O --oraclename=$SRC/5G_AKA_with_hsupi.pl", timeout => 60*60 },

   # Existing agreement lemmas
   #
   # (Other lemmas e.g. weak agreement are marked as failling in the original model.)
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'injectiveagreement_ue_seaf_kseaf_keyConf_noKeyRev_noChanRev', args => "--heuristic=O --oraclename=$SRC/5G_AKA.oracle", timeout => 60*60 },
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'injectiveagreement_seaf_ue_kseaf_noKeyRev_noChanRev',         args => "--heuristic=O --oraclename=$SRC/5G_AKA.oracle", timeout => 60*60 },
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'injectiveagreement_seaf_ue_kseaf_keyConf_noKeyRev_noChanRev', args => "--heuristic=O --oraclename=$SRC/5G_AKA.oracle", timeout => 60*60 },

   # hSUPI lemmas
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'ue_hsupi_unchanged', args => "--heuristic=O --oraclename=$SRC/5G_AKA_with_hsupi.pl" },
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'hn_hsupi_unchanged', args => "--heuristic=O --oraclename=$SRC/5G_AKA_with_hsupi.pl" },
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'ue_hsupi_update',    args => "--heuristic=O --oraclename=$SRC/5G_AKA_with_hsupi.pl" },
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'hn_hsupi_update',    args => "--heuristic=O --oraclename=$SRC/5G_AKA_with_hsupi.pl" },
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'hn_ue_suci_unique',  args => "--heuristic=O --oraclename=$SRC/5G_AKA_with_hsupi.pl" },
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'hn_hsupi_secret',    args => "--heuristic=O --oraclename=$SRC/5G_AKA_with_hsupi.pl" }
);

my $all_proven = 1;

foreach my $lemma (@LEMMAS) {
   print "Proving lemma ", $lemma->{lemma}, " in ", $lemma->{theory}, " ...\n";

   my ($status, $time, $steps) = Tamarin::prove(%$lemma);

   if ($status eq 'proven') {
      printf "   Proven   (%dm%ds, %d steps)\n", $time / 60, $time % 60, $steps;
   } elsif ($status eq 'failed') {
      $all_proven = 0;
      printf "   Failed   (%dm%ds)\n",           $time / 60, $time % 60;
   } elsif ($status eq 'timeout') {
      $all_proven = 0;
      printf "   Timeout  (%dm%ds)\n",           $time / 60, $time % 60;
   } else {
      die "Unknown status: $status";
   }
}

exit !$all_proven;
