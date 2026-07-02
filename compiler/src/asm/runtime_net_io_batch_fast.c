#include <stdint.h>

extern int32_t io_read_batch(int32_t fd, uint8_t *p0, uintptr_t l0, uint8_t *p1, uintptr_t l1, uint8_t *p2,
                             uintptr_t l2, uint8_t *p3, uintptr_t l3, int32_t n, uint32_t timeout_ms);
extern int32_t io_write_batch(int32_t fd, uint8_t *p0, uintptr_t l0, uint8_t *p1, uintptr_t l1, uint8_t *p2,
                              uintptr_t l2, uint8_t *p3, uintptr_t l3, int32_t n, uint32_t timeout_ms);
extern int32_t io_read_batch_provided(int32_t fd, int32_t n, uint32_t timeout_ms, uint32_t *out_bids,
                                      uint32_t *out_lens);

int32_t net_stream_write_batch_c(int32_t stream_fd, uint8_t *p0, uintptr_t l0, uint8_t *p1, uintptr_t l1, uint8_t *p2,
                                 uintptr_t l2, uint8_t *p3, uintptr_t l3, int32_t n, uint32_t timeout_ms) {
    return io_write_batch(stream_fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
}

int32_t net_stream_read_batch_c(int32_t stream_fd, uint8_t *p0, uintptr_t l0, uint8_t *p1, uintptr_t l1, uint8_t *p2,
                                uintptr_t l2, uint8_t *p3, uintptr_t l3, int32_t n, uint32_t timeout_ms) {
    return io_read_batch(stream_fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
}

int32_t net_stream_read_batch_provided_c(int32_t stream_fd, int32_t n, uint32_t timeout_ms, uint32_t *out_bids,
                                         uint32_t *out_lens) {
    return io_read_batch_provided(stream_fd, n, timeout_ms, out_bids, out_lens);
}
