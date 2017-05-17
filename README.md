[![PyPI](https://img.shields.io/pypi/v/httpparser.svg)](https://pypi.python.org/pypi/httpparser)
[![PyPI](https://img.shields.io/pypi/pyversions/httpparser.svg)](https://pypi.python.org/pypi/httpparser)
[![Travis branch](https://img.shields.io/travis/dontcare/httpparser/master.svg)](https://travis-ci.org/dontcare/httpparser)

httpparser is a Python binding for PicoHttpParser

Installation
------------

httpparser requires Python 3.5+ and is available on PyPI.

Use pip to install it::

    $ pip install httpparser
    
Using httpparser
----------------


```python

import httpparser
data = (
    b"POST / HTTP/1.1\r\nHost: www.test.com\r\nContent-Length: 4\r\nConnection: close\r\n\r\ntest"
)
p = httpparser.Request(data)
print(p.get_headers())
print(p.get_method())
print(p.get_uri())
print(p.get_http_version())
print(p.get_body())

data = (
    b"HTTP/1.1 200 OK\r\nSet-Cookie: csrftoken=Pj3xRLe3GI7nYQerSgV2xdp1gBEyTzBH; expires=Tue, 15-May-2018 12:49:05 GMT; Max- Age=31449600; Path=/\r\nContent-Length: 5\r\nConnection: close\r\n\r\nhallo"
)
p = httpparser.Response(data)
print(p.get_headers())
print(p.get_http_version())
print(p.get_status_code())
print(p.get_status_name())
```
