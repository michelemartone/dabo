TS=./dabo.sh

.PHONY:
all:
	$(TS)

.PHONY:
x:
	bash -x $(TS)

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
