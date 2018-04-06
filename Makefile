TS=./dabo.sh
TL=example_pass false self timeout true

.PHONY:
all:
	$(TS) $(TL)

.PHONY:
x:
	bash -x $(TS) $(TL)

.PHONY:
e:
	vim $(TS)

.PHONY:
clean:
	#rm -f *.log *.shar
	#rm -f *.html *.log *.shar
	rm -f */*.html */*.log *.shar *.log

.PHONY:
maint:
	DABO_TIMEOUT=120s $(TS) librsb_maint petsc_maint
