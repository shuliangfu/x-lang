#include <stdint.h>

/* 【Why 根源治理】net.o 的 net_stream_*_batch_c 引用 io_read_batch/io_write_batch/
 * io_read_batch_provided，定义在 std.io.sync（可选依赖）。用户程序若不 import io.sync，
 * DCE 剔除 sync.x 的定义，链接报 undefined。弱桩提供默认实现（返回 -1=不支持），
 * 让 net.o 自包含；用户 import io.sync 时，sync.x 的强符号（#[no_mangle]）覆盖弱桩。
 * 【Invariant】弱符号与强符号同名时，C 链接器优先选强符号；弱桩仅在无强符号时生效。
 * 【Asm/Perf】弱桩直接 return -1，无副作用；被覆盖时不进入最终可执行文件。 */
__attribute__((weak)) int32_t io_read_batch(int32_t fd, uint8_t *p0, uintptr_t l0, uint8_t *p1, uintptr_t l1, uint8_t *p2,
                                             uintptr_t l2, uint8_t *p3, uintptr_t l3, int32_t n, uint32_t timeout_ms) {
    (void)fd; (void)p0; (void)l0; (void)p1; (void)l1; (void)p2; (void)l2; (void)p3; (void)l3; (void)n; (void)timeout_ms;
    return -1;
}
__attribute__((weak)) int32_t io_write_batch(int32_t fd, uint8_t *p0, uintptr_t l0, uint8_t *p1, uintptr_t l1, uint8_t *p2,
                                              uintptr_t l2, uint8_t *p3, uintptr_t l3, int32_t n, uint32_t timeout_ms) {
    (void)fd; (void)p0; (void)l0; (void)p1; (void)l1; (void)p2; (void)l2; (void)p3; (void)l3; (void)n; (void)timeout_ms;
    return -1;
}
__attribute__((weak)) int32_t io_read_batch_provided(int32_t fd, int32_t n, uint32_t timeout_ms, uint32_t *out_bids,
                                                      uint32_t *out_lens) {
    (void)fd; (void)n; (void)timeout_ms; (void)out_bids; (void)out_lens;
    return -1;
}

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
