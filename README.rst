HTTPPARSER
==========

.. image:: https://travis-ci.org/dontcare/httpparser.svg?branch=master
    :target: https://travis-ci.org/dontcare/httpparser

.. image:: https://img.shields.io/pypi/v/httpparser.svg
    :target: https://pypi.python.org/pypi/httpparser


httpparser is a Python binding for PicoHttpParser

Installation
------------

httpparser requires Python 2.7, 3.4+ and is available on PyPI.

Use pip to install it::

    ``pip install httpparser``
    
Using httpparser
----------------


.. code:: python

    import httpparser


		class Protocol:

		    def __init__(self):
				    self.parser = httpparser.Request(self)


				def on_header(self, name, value):
				    pass

				def on_headers(self, headers):
				    pass

				def on_uri(self, uri):
				    pass

				def on_body(self, body):
				    pass

				def on_complete(self):
				    pass

				def data_received(self, data):
            self.parser.parse(data)
