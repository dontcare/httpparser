.PHONY: compile release clean cibuildwheel

compile:
	gcc -c ./picohttpparser/picohttpparser.c -O3 -fpic
	cp -f ./picohttpparser.o httpparser/
	cython httpparser/parser.pyx
	python setup.py build_ext --inplace;
	cp -rf picohttpparser/picohttpparser.* httpparser/

all: clean compile

release: compile
	#twine upload dist/*.whl dist/*.tar.* -r https://pypi.python.org/pypi/httpparser
	python setup.py sdist upload

clean:
	rm -rf build/;
	rm -rf dist/;
	rm -rf ./*.so
	rm -f httparser/parser.c;
	rm -f httpparser/*.so;

cibuildwheel:
	export CIBW_SKIP="cp26-* cp33-* cp34-* cp35-* cp36-*";
	echo $CIBW_SKIP;
	export CIBW_BEFORE_BUILD="python -m pip install cython && make";#"./.ci/cibuild_before.sh";
	echo $CIBW_BEFORE_BUILD;
	#cibuildwheel --platform linux --output-dir wheelhouse ./;
	cibuildwheel --platform macos --output-dir wheelhouse ./;
