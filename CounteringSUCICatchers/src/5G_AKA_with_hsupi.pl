#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

my %ORACLES = (
   sqn_ue_nodecrease => [
      qr/\(last\(#j/,
      qr/Sqn_UE_Change\(/,
      qr/\(#vr < #i\)/,
      qr/Sqn_UE\(.*count\.1/,
      qr/Sqn_UE_Nochange\(/,
      qr/Sqn_UE\(.*count/
   ],

   executability_honest => [
      qr/!KU\( ~k/,
      qr/St_2_SEAF\(/,
      qr/St_3_SEAF\(/,
      qr/RcvS\(/,
      qr/Sqn_HSS\(/,
      qr/!KU\( f1\(~k/,
      qr/!KU\( \(f5\(~k/,
      qr/Sqn_UE\(/,
      qr/!KU\( f5_star\(/,
      qr/!KU\( f1\(/,
      qr/!KU\( f3\(/,
      qr/!KU\( f5\(~k/,
      qr/!KU\( ~sqn_root/,
      qr/!KU\( KDF\(/,
      qr/!KU\( f5\(/,
      qr/!KD\( f5\(/
   ],

   executability_keyConf_honest => [
      qr/!KU\( ~k/,
      qr/St_4_SEAF\(/,
      qr/RcvS\(/,
      qr/Sqn_HSS\(/,
      qr/!KU\( f1\(KDF\(KDF\(<f3/,
      qr/!KU\( f1\(~k/,
      qr/!KU\( KDF\(KDF\(<f3/,
      qr/!KU\( KDF\(<f3/,
      qr/!KU\( f3\(/,
      qr/Sqn_UE\(/,
      qr/!KU\( f5\(~k/,
      qr/!KU\( ~sqn_root/,
      qr/!KU\( \(f5\(~k/,
      qr/!KD\( f5\(/
   ],

   executability_desync => [
      qr/!KU\( ~k/,
      qr/!KU\( ~sqn_root/,
      qr/St_1_HSS\(/,
      qr/Sqn_HSS\(/,
      qr/Sqn_UE\(/,
      qr/RcvS\(/,
      qr/HSUPI_HSS\(/,
      qr/HSUPI_UE\(/,
      qr/!KU\( f1_star\(/,
      qr/!KU\( f1\(/,
      qr/!KU\( f5\(/
   ],

   executability_resync => [
      qr/!KU\( ~k \)/,
      qr/!KU\( ~sqn_root/,
      qr/\d =.*=/,
      qr/~~>/,
      qr/HSS_Resync_End\(/,
      qr/St_1_HSS\(/,
      qr/Sqn_HSS\(/,
      qr/Sqn_UE\(/,
      qr/RcvS\(/,
      qr/HSUPI_HSS\(/,
      qr/!KU\( KDF\(/,
      qr/!KU\( f1\(~k/,
      qr/!KU\( f3\(~k/,
      qr/!KU\( f1_star\(/,
      qr/!KU\( f1\(/,
      qr/!KU\( f5\(/,
      qr/!KU\( \(f5_star\(/,
      qr/!KD\( \(f5_star\(/,
      qr/!KU\( \(f5\(/,
      qr/!KD\( \(f5\(/,
      qr/!KU\( f3\(/
   ],

   ue_hsupi_unchanged => [
      qr/\(last\(#i/,
      qr/!Ltk_Sym\(/,
      qr/HSUPI_UE_Unchanged\(/,
      qr/HSUPI_UE\(.*#i$/,
      qr/HSUPI_UE\(.*#vr$/,
      qr/St_1_UE\( ~tid/,
      qr/#j < #vr\)/,
      qr/#j < #vr\.2\)/
   ],

   hn_hsupi_unchanged => [
      qr/\(last\(#i/,
      qr/HSUPI_HN_Unchanged\(/,
      qr/HSUPI_HSS\(.*#i$/,
      qr/!Ltk_Sym\(/,
      qr/#j < #vr\)/
   ],

   ue_hsupi_update => [
      qr/\(last\(#j/,
      qr/IsSN\( ~supi/,
      qr/IsSN\( ~idHN/,
      qr/!KU\( ~k/,
      qr/RcvS\( ~k/,
      qr/St_1_UE\(/,
      qr/!KU\( f1\(~k/,
      qr/RcvS\( ~cid.*<\'aia\'/,
      qr/HSUPI_HN_Update.*#j.1 < #j/,
      qr/HSUPI_HN_Update.*#j < #vr.6/
   ],

   hn_hsupi_update => [
      qr/\(last\(#i/,
      qr/!KU\( f2/,
      qr/IsSN\( ~supi/,
      qr/IsSN\( ~idHN/,
      qr/!KU\( ~k/,
      qr/RcvS\( ~k/,
      qr/\(last\(#j/,
      qr/RcvS\( ~cid.*<\'ac\'/,
      qr/St_1_HSS\(/,
      qr/!KU\( KDF\(/,
      qr/!KU\( f1\(~k/,
      qr/#j < #vr\.9/,
      qr/#j < #vr\.5/
   ],

   hn_ue_suci_unique => [
      qr/\(last\(#j/,
      qr/HSUPI_UE_Use/,
      qr/HSUPI_HN_Init\(.*#j < #i\)/,
      qr/HSUPI_UE_Init\( ~supi, ~idHN/,
      qr/St_1_HSS\(/,
      qr/HSUPI_UE\(/
   ],

   hn_hsupi_secret => [
      qr/\(last\(#j/,
      qr/^Rev\(/,
      qr/^Honest\(/,
      qr/\(~supi\.1 = ~supi/,
      qr/\(~idHN\.1 = ~supi/,
      qr/\(last\(#k\.1/,
      qr/!KU\( h\(hsupi/,
      qr/St_1_HSS\(/,
      qr/!KU\( ~hsupi_init/,
      qr/!KU\( ~sk_HN/,
      qr/RcvS\( ~hsupi_init/,
      qr/RcvS\( ~sk_HN/,
      qr/HSUPI_HN_Init\(/
   ],

   hn_suci_from_ue => [
      qr/^Rev\(/,
      qr/^Honest\(/,
      qr/\(~supi\.1 = ~supi/,
      qr/\(~idHN\.1 = ~supi/,
      qr/\(Rev\(.*<\'skHN\'/,
      qr/!KU\( ~hsupi_init/,
      qr/!KU\( ~sk_HN/,
      qr/RcvS\( ~hsupi_init/,
      qr/RcvS\( ~sk_HN/,
      qr/Commit\( /,
      qr/St_1_HSS\(/,
      qr/RcvS\( ~cid.*<\'air\'.*#vr$/,
      qr/!KU\( aenc\(/,
      qr/HSUPI_HSS\(.*#vr$/,
      qr/HSUPI_UE_Init\(.*~supi/,
      qr/HSUPI_HN_Init\(.*~supi/
   ]
);

sub rank {
   my $goal   = shift;
   my $oracle = shift;
   my $rank   = 1;

   foreach (@$oracle) {
      return $rank if ($goal =~ /$_/);

      $rank++;
   }

   return undef;
}

die "Expected a single argument (lemma name)\n"
   unless 1 == ( my ($lemma) = @ARGV );

my @goals;
my $oracle = $ORACLES{$lemma};

exit unless defined $oracle;

$oracle = $ORACLES{$oracle} if ref $oracle eq '';

while (<STDIN>) {
   chomp;

   die "Invalid format: $_\n"
      unless /(\d+): +(.+)/;

   my ($index, $goal) = ($1, $2);

   if (my $rank = rank($goal, $oracle)) {
      push @goals, [$index, $rank]
   }
}

say $_->[0] foreach (sort { $a->[1] <=> $b->[1] } @goals);
