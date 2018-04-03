.PHONY:
all:
	./test.sh

.PHONY:
x:
	bash -x ./test.sh

.PHONY:
clean:
	#rm -f *.log *.shar
	#rm -f *.html *.log *.shar
	rm -f */*.html */*.log *.shar *.log

.PHONY:
maint:
	SCAMC_TIMEOUT=120s ./test.sh librsb_maint petsc_maint
