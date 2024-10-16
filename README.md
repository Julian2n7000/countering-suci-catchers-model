# Countering SUCI-Catchers in Cellular Communications

This repository contains the model accompanying the paper "Countering
SUCI-Catchers in Cellular Communications" by Julian Parkin and Mahesh
Tripunitara. The model is derived from that of Basin et al.[^1]

## Theory

The theory file can be found under `CounteringSUCICatchers/src/5G_AKA_with_hsupi.spthy`

## Running

Run `make` in the base directory to prove each lemma and write the results to
`CounteringSUCICatchers/results.txt`.

You can also open the theory file directly in Tamarin to explore it
interactively. There are two oracles provided:

```
CounteringSUCICatchers/src/5G_AKA.oracle
CounteringSUCICatchers/src/5G_AKA_with_hsupi.pl
```

`.oracle` is the unmodified oracle from Basin et al. and `with_hsupi.pl` is
the oracle for new lemmas or lemmas where oracle changes were required. You
can look at `CounteringSUCICatchers/src/prove.pl` to see which oracle is used
for each lemma.

## Licence

All files are released under the MIT Licence, except for

```
CounteringSUCICatchers/src/5G_AKA.oracle
CounteringSUCICatchers/src/5G_AKA_with_hsupi.spthy
```

which are adapted from the original model and were released under the GNU
General Public Licence v3.0 as part of Tamarin. For a copy of the licence,
see GPL_V3.txt in this repository.

[^1]: D. Basin, J. Dreier, L. Hirschi, S. Radomirovic, R. Sasse, and
V. Stettler, "A formal analysis of 5G authentication," in _Proceedings of
the 2018 ACM SIGSAC Conference on Computer and Communications Security_,
ser. CCS ’18. New York, NY, USA: Association for Computing Machinery, 2018,
p. 1383–1396. [Online]. Available: https://doi.org/10.1145/3243734.3243846
