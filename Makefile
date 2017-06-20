.PHONY: compile release clean

compile:
	gcc -c ./picohttpparser/picohttpparser.c -O3 -fpic -msse4.2
	gcc -shared -o libpicohttpparser.so picohttpparser.o;
	cython httpparser/parser.pyx
	python setup.py build_ext --inplace;

all: clean compile

release: compile
	python setup.py sdist upload -r https://pypi.python.org/pypi/httpparser;

clean:
	rm -rf build/;
	rm -rf ./*.so
	rm -f httparser/parser.c;
	rm -f httpparser/*.so;
