
.PHONY: all

all: CounteringSUCICatchers/results.txt

CounteringSUCICatchers/results.txt: CounteringSUCICatchers/src/*

%/results.txt: %/prove.pl
	perl -I. $< | tee $@
