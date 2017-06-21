.PHONY: compile release clean wheel

compile:
	gcc -c ./picohttpparser/picohttpparser.c -O3 -fpic
	cython httpparser/parser.pyx
	python setup.py build_ext --inplace;

all: clean compile

wheel:
	cibuildwheel --output-dir dist/ --platform linux ./

release: compile
	python setup.py sdist upload -r https://pypi.python.org/pypi/httpparser;

clean:
	rm -rf build/;
	rm -rf dist/;
	rm -rf ./*.so
	rm -f httparser/parser.c;
	rm -f httpparser/*.so;
