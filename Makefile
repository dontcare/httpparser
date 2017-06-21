.PHONY: compile release clean

compile:
	gcc -c ./picohttpparser/picohttpparser.c -O3 -fpic
	cython httpparser/parser.pyx
	python setup.py build_ext --inplace;

all: clean compile

release: compile
	python setup.py sdist
	python -m twine upload dist/*.whl dist/*.tar.* -r https://pypi.python.org/pypi/httpparser
	#python setup.py bdist_wheel upload -r https://pypi.python.org/pypi/httpparser;

clean:
	rm -rf build/;
	rm -rf dist/;
	rm -rf ./*.so
	rm -f httparser/parser.c;
	rm -f httpparser/*.so;
