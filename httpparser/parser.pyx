# cython: language_level=3

cimport cython
from . cimport pico
from libc.stdlib cimport calloc, free


class ParserError(Exception):
    pass


cdef class Parser:

    cdef:
        bytes buf
        bytes http_version
        int phr

        const char * pico_buf
        size_t pico_buf_len
        int pico_minor_version

    def __cinit__(self, bytes buf, int max_headers=50):
        self.buf = buf
        self.pico_buf = <char * >self.buf
        self.pico_buf_len = len(self.pico_buf)

    cpdef get_http_version(self):
        if not self.http_version:
            self.http_version = b"1.%d" % self.pico_minor_version
        return self.http_version


cdef class Headers(Parser):

    cdef:
        dict headers
        pico.phr_header * pico_headers
        size_t pico_num_headers

    def __cinit__(self, bytes buf, int max_headers=50):
        super().__init__(buf, max_headers)
        self.headers = dict()
        self.pico_headers = <pico.phr_header * >calloc(max_headers,
                                                       sizeof(pico.phr_header))
        self.pico_num_headers = sizeof(
            self.pico_headers) * sizeof(self.pico_headers[0])

    cpdef get_headers(self):
        if not self.headers:
            for i in range(0, self.pico_num_headers):
                name_len = self.pico_headers[i].name_len
                name = self.pico_headers[i].name[:name_len]
                value_len = self.pico_headers[i].value_len
                value = self.pico_headers[i].value[:value_len]
                self.headers[name] = value
        return self.headers

    def __dealloc__(self):
        free(< void * >self.pico_headers)


cdef class Request(Headers):

    cdef:
        bytes method
        bytes uri
        bytes body

        const char * pico_method
        size_t pico_method_len
        const char * pico_uri
        size_t pico_uri_len

    def __cinit__(self, bytes buf, int max_headers=50):
        super().__init__(buf, max_headers)
        self.phr = pico.phr_parse_request(
            self.pico_buf,
            self.pico_buf_len,
            < const char ** > & self.pico_method,
            & self.pico_method_len,
            < const char ** > & self.pico_uri,
            & self.pico_uri_len,
            & self.pico_minor_version,
            self.pico_headers,
            & self.pico_num_headers,
            0
        )
        if self.phr == -1:
            raise ParserError("Request parser error")

    cpdef get_method(self):
        if not self.method:
            self.method = <bytes > self.pico_method[:self.pico_method_len]
        return self.method

    cpdef get_uri(self):
        if not self.uri:
            self.uri = <bytes > self.pico_uri[:self.pico_uri_len]
        return self.uri

    cpdef get_body(self):
        if not self.body:
            self.body = self.buf[self.phr:]
        return self.body


cdef class Response(Headers):

    cdef:
        int pico_status
        const char * pico_msg
        size_t pico_msg_len

    def __cinit__(self, bytes buf, int max_headers=50):
        super().__init__(buf, max_headers)
        self.phr = pico.phr_parse_response(
            self.pico_buf,
            self.pico_buf_len,
            & self.pico_minor_version,
            & self.pico_status,
            < const char ** > & self.pico_msg,
            & self.pico_msg_len,
            self.pico_headers,
            & self.pico_num_headers,
            0
        )
        if self.phr == -1:
            raise ParserError("Response parser error")

    cpdef get_status_code(self):
        return self.pico_status

    cpdef get_status_name(self):
        return < bytes > self.pico_msg[:self.pico_msg_len]


cdef class Chunked:

    cdef:
        pico.phr_chunked_decoder * pico_decoder
        char * pico_buf
        size_t pico_buf_len

    def __cinit__(self, bytes buf):
        self.pico_decoder = <pico.phr_chunked_decoder * >calloc(1,
                                                       sizeof(pico.phr_chunked_decoder))
        self.pico_buf = <char * > < bytes > buf
        self.pico_buf_len = len(buf)
        phr = pico.phr_decode_chunked(self.pico_decoder,
                                      self.pico_buf,
                                      & self.pico_buf_len)
        if phr == -1:
            raise ParserError("Response parser error")

    cpdef is_in_data(self):
        return pico.phr_decode_chunked_is_in_data(self.pico_decoder)

    def __dealloc__(self):
        free(< void * >self.pico_decoder)
