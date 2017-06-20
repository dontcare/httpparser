# cython: language_level=3

import time
cimport cython
from . cimport pico
from libc.stdlib cimport calloc, free
from cpython cimport PyObject_GetBuffer, PyBuffer_Release, PyBUF_SIMPLE, \
    Py_buffer, PyBytes_AsString


cdef class Parser:

    def __cinit__(self, protocol):
        self.on_header = getattr(protocol, 'on_header', None)
        self.on_headers = getattr(protocol, 'on_headers', None)
        self.on_complete = getattr(protocol, 'on_complete', None)

    cpdef get_http_version(self):
        if not self.http_version:
            self.http_version = b"1.%d" % self.pico_minor_version
        return self.http_version

    cpdef should_keep_alive(self):
        return bool(self.pico_minor_version)


cdef class Headers:

    def __cinit__(self):
        #self._headers = {}
        self.pico_headers = <pico.phr_header * >calloc(100, sizeof(pico.phr_header))
        self.num_headers = sizeof(self.pico_headers) * sizeof(self.pico_headers[0])

    cdef parser(self, on_header, on_headers):
        cdef h = {}
        for i in range(0, self.num_headers):
            name_len = self.pico_headers[i].name_len
            name = self.pico_headers[i].name[:name_len]
            value_len = self.pico_headers[i].value_len
            value = self.pico_headers[i].value[:value_len]
            #if on_header:
            #    on_header(name, value)
            #self._headers[name] = value
        if on_headers:
            #on_headers(_headers)
            print("SET HEADERS")

    def __dealloc__(self):
        free(< void * >self.pico_headers)


cdef class Request(Parser):

    def __cinit__(self, protocol):
        super().__init__(protocol)
        self.on_body = getattr(protocol, 'on_body', None)
        self.on_uri = getattr(protocol, 'on_uri', None)

    cpdef get_method(self):
        return self.method

    cpdef parse(self, bytes data):

        cdef:
            const char * buf
            size_t buf_len
            Headers headers

        buf = <char * >data
        buf_len = len(buf)

        headers = Headers()

        phr = pico.phr_parse_request(
            buf,
            buf_len,
            < const char ** > & self.pico_method,
            & self.pico_method_len,
            < const char ** > & self.pico_uri,
            & self.pico_uri_len,
            & self.pico_minor_version,
            headers.pico_headers,
            & headers.num_headers,
            0
        )

        headers.parser(self.on_header, self.on_headers)

        if self.on_uri:
            self.on_uri(<bytes > self.pico_uri[:self.pico_uri_len])

        if self.on_body:
            self.on_body(buf[phr:])

        if self.on_complete:
            self.on_complete()


cdef class Response(Parser):

    def __cinit(self, protocol):
        super().__init__(protocol)
        self.on_message = getattr(protocol, 'on_message', None)

    cpdef get_status_code(self):
        return self.status

    cpdef parse(self, bytes data):
        cdef:
            const char * buf
            size_t buf_len
            Headers headers

        buf = <char * >data
        buf_len = len(buf)

        headers = Headers()

        phr = pico.phr_parse_response(
            self.pico_buf,
            self.pico_buf_len,
            & self.pico_minor_version,
            & self.status,
            < const char ** > & self.pico_msg,
            & self.pico_msg_len,
            headers.pico_headers,
            & headers.num_headers,
            0
        )

        headers.parser(self.on_header, self.on_headers)

        if self.on_message:
            self.on_message(< bytes > self.pico_msg[:self.pico_msg_len])

        self.on_complete()
