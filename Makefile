SC=./dabo.sh

.PHONY:
all:
	$(SC)

.PHONY:
x:
	bash -x $(SC)

.PHONY:
clean:
	#rm -f *.log *.shar
	#rm -f *.html *.log *.shar
	rm -f */*.html */*.log *.shar *.log

.PHONY:
maint:
	DABO_TIMEOUT=120s $(SC) librsb_maint petsc_maint
