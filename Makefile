PACKAGE := $(shell grep '^Package:' DESCRIPTION | sed -E 's/^Package:[[:space:]]+//')
RSCRIPT = Rscript --no-init-file

all:
	${RSCRIPT} -e 'library(methods); devtools::compile_dll()'

test:
	${RSCRIPT} -e 'library(methods); devtools::test()'

doc:
	@mkdir -p man
	${RSCRIPT} -e "library(methods); devtools::document()"

install: doc build
	R CMD INSTALL . && rm *.tar.gz

build:
	R CMD build .

check: build
	_R_CHECK_CRAN_INCOMING_=FALSE R CMD check --as-cran --no-manual `ls -1tr ${PACKAGE}*gz | tail -n1`
	@rm -f `ls -1tr ${PACKAGE}*gz | tail -n1`
	@rm -rf ${PACKAGE}.Rcheck

check_windows:
	${RSCRIPT} -e "devtools::check_win_devel(quiet=TRUE); devtools::check_win_release(quiet=TRUE)"

eg:
	${RSCRIPT} -e "devtools::run_examples()"

clean:
	rm -f src/*.o src/*.so

attributes:
	${RSCRIPT} -e 'library(methods); Rcpp::compileAttributes()'

readme: README.Rmd
	${RSCRIPT} -e "Sys.setenv(NOT_CRAN='true'); knitr::knit('README.Rmd')"

vign_intro:
		cd vignettes;\
		${RSCRIPT} -e "Sys.setenv(NOT_CRAN='true'); knitr::knit('parzer.Rmd.og', output = 'parzer.Rmd')";\
		cd ..

# No real targets!
.PHONY: all test doc install
