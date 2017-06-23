.PHONY: compile release clean cibuildwheel

compile:
	gcc -c picohttpparser/picohttpparser.c -O3 -fpic -msse4.2
	mv picohttpparser.o httpparser/
	cp -r picohttpparser/picohttpparser.c httpparser/
	cp -r picohttpparser/picohttpparser.h httpparser/
	cython httpparser/parser.pyx
	python setup.py build_ext --inplace;

all: clean compile

release: compile
	python setup.py sdist upload

clean:
	rm -rf build/;
	rm -rf dist/;
	rm -f httpparser/parser.c;
	rm -f httpparser/picohttpparser.c;
	rm -f httpparser/picohttpparser.h;
	rm -f httpparser/*.o;
	rm -f httpparser/*.so;
