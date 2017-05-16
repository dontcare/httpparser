.PHONY: compile release clean

compile:
	cython httpparser/parser.pyx
	python setup.py build_ext --inplace;

all: clean compile

release: compile
	python setup.py sdist upload -r https://pypi.python.org/pypi/httpparser;

clean:
	rm -rf build/;
	rm -f httparser/parser.c;
	rm -f httpparser/*.so;
