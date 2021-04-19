TS=`pwd`/dabo.sh
TL=true example_pass self timeout
ATL=false $(TL)

.PHONY: all
all:
	@echo "Hint: make tests"

.PHONY: tests
tests: almost_all_tests

.PHONY: all_tests
all_tests:
	$(TS) $(ATL)

.PHONY: almost_all_tests
almost_all_tests:
	$(TS) -r nt $(TL)

.PHONY: x
x:
	bash -x $(TS) $(TL)

.PHONY: e
e:
	vim $(TS)

.PHONY: clean
clean:
	rm -f */*.html */*.log *.shar *.log *.tar.gz */failed.shar */passed.shar */*.tar.gz
	rm -fR self/custom_results_dir

.PHONY: true
true:
	$(TS) $@

.PHONY: false
false:
	$(TS) $@
