/**
 * bootstrap_seed_io_stubs.c — bootstrap-driver-seed 专用 io 底层桩
 *
 * lsp_gen.c 内嵌 std_io_* 实现，但 extern 引用 io_* / shux_io_* 底层符号；
 * 真 partial 链不再携带 phase1 弱桩 partial 时，由本 TU 补齐（不与 lsp_sx.o 重复 std_io_*）。
 */
#include <stddef.h>
#include <stdint.h>
#if defined(__unix__) || defined(__APPLE__)
#include <unistd.h>
#endif

/** sx_seed_bridge.o 已提供 io_read/io_write；本 TU 仅声明。 */
extern ptrdiff_t io_read(int32_t fd, uint8_t *buf, size_t count, unsigned timeout_ms);
extern ptrdiff_t io_write(int32_t fd, uint8_t *buf, size_t count, unsigned timeout_ms);

/** stdin 指针读桩：无缓冲时返回 NULL。 */
uint8_t *io_read_ptr(unsigned handle, unsigned timeout_ms) {
  (void)handle;
  (void)timeout_ms;
  return NULL;
}

/** 与 io_read_ptr 配套的可用长度桩。 */
int32_t io_read_ptr_len(void) {
  return 0;
}

/** lsp_gen / driver 缓冲 ABI：与 runtime.c shu_buffer_abi_t 布局一致。 */
typedef struct {
  uint8_t *ptr;
  size_t len;
  size_t handle;
} shu_buffer_abi_t;

/** std.io.core 注册单缓冲桩。 */
int32_t io_register_buffer(uint8_t *ptr, size_t len) {
  (void)ptr;
  (void)len;
  return 0;
}

/** 四缓冲注册桩。 */
int32_t io_register_buffers_4(uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2,
                              uint8_t *p3, size_t l3, uint32_t nr) {
  (void)p0;
  (void)l0;
  (void)p1;
  (void)l1;
  (void)p2;
  (void)l2;
  (void)p3;
  (void)l3;
  (void)nr;
  return 0;
}

/** 撤销已注册缓冲（桩 no-op）。 */
void io_unregister_buffers(void) {
}

/** 固定缓冲读桩。 */
ptrdiff_t io_read_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, unsigned timeout_ms) {
  (void)buf_index;
  (void)offset;
  return io_read(fd, NULL, len, timeout_ms);
}

/** 固定缓冲写桩。 */
ptrdiff_t io_write_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, unsigned timeout_ms) {
  (void)buf_index;
  (void)offset;
  return io_write(fd, NULL, len, timeout_ms);
}

/** poll/select 可读桩：bootstrap 冷路径返回 0。 */
int32_t io_wait_readable(int32_t *fds, int32_t n, unsigned timeout_ms) {
  (void)fds;
  (void)n;
  (void)timeout_ms;
  return 0;
}

/** 批量读桩：退化为单次 io_read。 */
ptrdiff_t io_read_batch(int32_t fd, uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2,
                        uint8_t *p3, size_t l3, int32_t n, unsigned timeout_ms) {
  (void)p1;
  (void)l1;
  (void)p2;
  (void)l2;
  (void)p3;
  (void)l3;
  (void)n;
  return io_read(fd, p0, l0, timeout_ms);
}

/** 批量写桩：退化为单次 io_write。 */
ptrdiff_t io_write_batch(int32_t fd, uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2,
                         uint8_t *p3, size_t l3, int32_t n, unsigned timeout_ms) {
  (void)p1;
  (void)l1;
  (void)p2;
  (void)l2;
  (void)p3;
  (void)l3;
  (void)n;
  return io_write(fd, p0, l0, timeout_ms);
}

/** driver.Buffer 批注册桩。 */
int32_t io_register_buffers_buf(void *bufs, int32_t nr) {
  (void)bufs;
  (void)nr;
  return 0;
}

/** codegen 生成的 i32 入口名。 */
int32_t io_register_buffers_buf_i32(intptr_t bufs, int nr) {
  return io_register_buffers_buf((void *)(uintptr_t)bufs, nr);
}

/** std.io.core 三参注册。 */
int32_t shux_io_register(uint8_t *ptr, size_t len, size_t handle) {
  (void)handle;
  return io_register_buffer(ptr, len);
}

/** driver 侧 Buffer 描述符注册。 */
int32_t shux_io_register_buf(intptr_t buf) {
  const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf;
  if (!b)
    return -1;
  return shux_io_register(b->ptr, b->len, b->handle);
}

/** 异步读提交桩。 */
int32_t shux_io_submit_read(uint8_t *ptr, size_t len, size_t handle, unsigned timeout_ms) {
  int32_t fd = (int32_t)handle;
  ptrdiff_t r = io_read(fd, ptr, len, timeout_ms);
  if (r < 0)
    return -1;
  return (int32_t)r;
}

int32_t shux_io_submit_read_buf(intptr_t buf, int32_t timeout_ms) {
  const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf;
  if (!b)
    return -1;
  return shux_io_submit_read(b->ptr, b->len, b->handle, (unsigned)timeout_ms);
}

/** 异步写提交桩。 */
int32_t shux_io_submit_write(uint8_t *ptr, size_t len, size_t handle, unsigned timeout_ms) {
  int32_t fd = (int32_t)handle;
  ptrdiff_t r = io_write(fd, ptr, len, timeout_ms);
  if (r < 0)
    return -1;
  return (int32_t)r;
}

int32_t shux_io_submit_write_buf(intptr_t buf, int32_t timeout_ms) {
  const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf;
  if (!b)
    return -1;
  return shux_io_submit_write(b->ptr, b->len, b->handle, (unsigned)timeout_ms);
}

/** lsp_gen 引用 driver_read_ptr*；真 partial 无 phase1 弱桩时兜底。 */
__attribute__((weak)) uint8_t *std_io_driver_driver_read_ptr(size_t handle, unsigned timeout_ms) {
  (void)handle;
  (void)timeout_ms;
  return NULL;
}

__attribute__((weak)) int32_t std_io_driver_driver_read_ptr_len(void) {
  return 0;
}
