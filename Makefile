.PHONY: compile release clean pico

compile:
	cython httpparser/parser.pyx
	python setup.py build_ext --inplace;

pico:
	gcc -c vendors/picohttpparser/picohttpparser.c -O3 -fpic -msse4.2

all: clean compile

release: compile
	python setup.py sdist upload

clean:
	rm -rf build/;
	rm -rf dist/;
	rm -f httpparser/parser.c;
	rm -f ./*.o;
