TS=./dabo.sh
TL=true example_pass self timeout
ATL=false $(TL)

.PHONY:
almost_all:
	$(TS) $(TL)

.PHONY:
all:
	$(TS) $(ATL)

.PHONY:
x:
	bash -x $(TS) $(TL)

.PHONY:
e:
	vim $(TS)

.PHONY:
clean:
	rm -f */*.html */*.log *.shar *.log *.tar.gz
