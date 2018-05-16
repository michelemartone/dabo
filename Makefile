TS=./dabo.sh
TL=true example_pass self timeout
ATL=false $(TL)

.PHONY: almost_all
almost_all:
	$(TS) $(TL)

.PHONY: all
all:
	$(TS) $(ATL)

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
