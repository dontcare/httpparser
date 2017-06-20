# cython: language_level=3

from . cimport pico

cdef class Parser:

    cdef:
        bytes http_version
        int pico_minor_version

        on_headers, on_header, on_complete

    cpdef get_http_version(self)
    cpdef should_keep_alive(self)


cdef class Headers:

    cdef:
        pico.phr_header * pico_headers
        size_t num_headers
        #dict _headers

    cdef parser(self, on_header, on_headers)


cdef class Request(Parser):

    cdef:
        bytes method
        bytes uri
        bytes body

        const char * pico_method
        size_t pico_method_len
        const char * pico_uri
        size_t pico_uri_len

        on_body, on_uri

    cpdef get_method(self)
    cpdef parse(self, bytes data)


cdef class Response(Parser):

    cdef:
        int status
        const char * pico_msg
        size_t pico_msg_len
        
        on_status, on_message

    cpdef get_status_code(self)
    cpdef parse(self, bytes data)
