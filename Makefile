TS=./dabo.sh
TL=false true example_pass self timeout

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
	rm -f */*.html */*.log *.shar *.log
