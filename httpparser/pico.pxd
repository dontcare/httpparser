# cython: language_level=3

cdef extern from "picohttpparser.h":

    struct phr_header:
        const char * name
        size_t name_len
        const char * value
        size_t value_len

    struct phr_chunked_decoder:
        size_t bytes_left_in_chunk
        char consume_trailer
        char _hex_count
        char _state

    int phr_parse_request(const char * buf,
                          size_t len,
                          const char ** method,
                          size_t * method_len,
                          const char ** path,
                          size_t * path_len,
                          int * minor_version,
                          phr_header * headers,
                          size_t * num_headers,
                          size_t last_len)

    int phr_parse_response(const char * buf,
                           size_t len,
                           int * minor_version,
                           int * status,
                           const char ** msg,
                           size_t * msg_len,
                           phr_header * headers,
                           size_t * num_headers,
                           size_t last_len)

    int phr_parse_headers(const char * buf,
                          size_t len,
                          phr_header * headers,
                          size_t * num_headers,
                          size_t last_len)

    ssize_t phr_decode_chunked(phr_chunked_decoder * decoder,
                               char * buf,
                               size_t * bufsz)

    int phr_decode_chunked_is_in_data(phr_chunked_decoder * decoder)
