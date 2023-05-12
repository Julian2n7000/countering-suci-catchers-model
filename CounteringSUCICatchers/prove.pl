#!/usr/bin/env perl

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
   # { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'executability_keyConf_honest', args => "--heuristic=i",                                       timeout => 20*60 }, # No oracle provided by the original implementation
   { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'executability_desync',         args => "--heuristic=O --oraclename=$SRC/5G_AKA.oracle",       timeout => 20*60 },
   # { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'executability_resync',         args => "--heuristic=O --oraclename=$SRC/5G_AKA.oracle",       timeout => 20*60 },

   # Existing agreement lemmas
   # { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'injectiveagreement_ue_seaf_kseaf_keyConf_noKeyRev_noChanRev', args => "--heuristic=O --oraclename=$SRC/5G_AKA.oracle", timeout => 20*60 },
   # { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'injectiveagreement_seaf_ue_kseaf_noKeyRev_noChanRev',         args => "--heuristic=O --oraclename=$SRC/5G_AKA.oracle", timeout => 20*60 },
   # { theory => "$SRC/5G_AKA_with_hsupi.spthy", lemma => 'injectiveagreement_seaf_ue_kseaf_keyConf_noKeyRev_noChanRev', args => "--heuristic=O --oraclename=$SRC/5G_AKA.oracle", timeout => 20*60 },

   # Existing hSUPI lemmas
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
