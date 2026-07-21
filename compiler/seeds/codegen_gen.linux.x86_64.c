#include <stdint.h>
#if !defined(__STDC_VERSION__) || __STDC_VERSION__ < 201112L
#error "Generated code needs C11. Compile with -std=gnu11 or -std=c11."
#endif
#include <stddef.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/uio.h>
#include <poll.h>
static inline ssize_t shux_sys_read(int32_t fd, uint8_t *buf, size_t count) {
  return read((int)fd, (void *)buf, count);
}
static inline ssize_t shux_sys_write(int32_t fd, uint8_t *buf, size_t count) {
  return write((int)fd, (const void *)buf, count);
}
static inline ssize_t shux_sys_readv(int32_t fd, uint8_t *iov, int32_t iovcnt) {
  return readv((int)fd, (const struct iovec *)(const void *)iov, (int)iovcnt);
}
static inline ssize_t shux_sys_writev(int32_t fd, uint8_t *iov, int32_t iovcnt) {
  return writev((int)fd, (const struct iovec *)(const void *)iov, (int)iovcnt);
}
static inline int32_t shux_sys_poll(uint8_t *fds, int32_t nfds, int32_t timeout) {
  return (int32_t)poll((struct pollfd *)(void *)fds, (nfds_t)nfds, (int)timeout);
}
static inline ssize_t shux_sys_pread(int32_t fd, uint8_t *buf, size_t count, int64_t offset) {
  return pread((int)fd, (void *)buf, count, (off_t)offset);
}
static inline ssize_t shux_sys_pwrite(int32_t fd, uint8_t *buf, size_t count, int64_t offset) {
  return pwrite((int)fd, (const void *)buf, count, (off_t)offset);
}
static inline int32_t shux_fs_unlink(uint8_t *path) {
  return (int32_t)unlink((const char *)path);
}
static inline int32_t shux_fs_rmdir(uint8_t *path) {
  return (int32_t)rmdir((const char *)path);
}
struct shux_slice_uint8_t { uint8_t *data; size_t length; };
struct shux_slice_int32_t { int32_t *data; size_t length; };
struct shux_slice_uint64_t { uint64_t *data; size_t length; };
struct shux_slice_size_t { size_t *data; size_t length; };
#if defined(__GNUC__) || defined(__clang__)
typedef int32_t i32x4_t __attribute__((vector_size(16)));
typedef int32_t i32x8_t __attribute__((vector_size(32)));
typedef int32_t i32x16_t __attribute__((vector_size(64)));
typedef uint32_t u32x4_t __attribute__((vector_size(16)));
typedef uint32_t u32x8_t __attribute__((vector_size(32)));
typedef uint32_t u32x16_t __attribute__((vector_size(64)));
#else
typedef struct { int32_t e[4]; } i32x4_t;
typedef struct { int32_t e[8]; } i32x8_t;
typedef struct { int32_t e[16]; } i32x16_t;
typedef struct { uint32_t e[4]; } u32x4_t;
typedef struct { uint32_t e[8]; } u32x8_t;
typedef struct { uint32_t e[16]; } u32x16_t;
#endif
typedef struct { uint8_t *ptr; size_t len; size_t handle; } shu_batch_buf_t;
extern int io_register_buffer(uint8_t *ptr, size_t len);
extern int io_register_buffers_4(uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2, uint8_t *p3, size_t l3, unsigned nr);
__attribute__((weak)) int io_register_buffers_buf_c(const shu_batch_buf_t *bufs, int nr) { (void)bufs; (void)nr; return -1; }
static inline int io_register_buffers_buf_i32(intptr_t bufs, int nr) { return io_register_buffers_buf_c((const shu_batch_buf_t *)(uintptr_t)bufs, nr); }
#define io_register_buffers_buf(bufs, nr) io_register_buffers_buf_i32((intptr_t)(void *)(bufs), (nr))
extern void io_unregister_buffers(void);
extern ptrdiff_t io_read(int fd, uint8_t *buf, size_t count, unsigned timeout_ms);
extern ptrdiff_t io_write(int fd, uint8_t *buf, size_t count, unsigned timeout_ms);
extern ptrdiff_t io_read_batch(int fd, uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2, uint8_t *p3, size_t l3, int n, unsigned timeout_ms);
extern ptrdiff_t io_write_batch(int fd, uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2, uint8_t *p3, size_t l3, int n, unsigned timeout_ms);
extern ptrdiff_t io_read_fixed(int fd, unsigned buf_index, size_t offset, size_t len, unsigned timeout_ms);
extern ptrdiff_t io_write_fixed(int fd, unsigned buf_index, size_t offset, size_t len, unsigned timeout_ms);
extern int io_wait_readable(int32_t *fds, int n, unsigned timeout_ms);
extern uint8_t *io_read_ptr(size_t handle, unsigned timeout_ms);
extern int io_read_ptr_len(void);
extern int32_t shux_io_register(uint8_t *ptr, size_t len, size_t handle);
extern int32_t shux_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);
extern int32_t shux_io_submit_write(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);
extern int32_t shux_io_read_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_m);
extern int32_t shux_io_write_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_m);
extern uint8_t *shux_io_read_ptr(size_t handle, unsigned timeout_ms);
extern int32_t shux_io_read_ptr_len(void);
typedef struct { void *ptr; size_t len; size_t handle; } shu_buffer_abi_t;
static inline int32_t shux_io_register_buf(intptr_t buf) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_register((uint8_t *)b->ptr, b->len, b->handle); }
static inline int32_t shux_io_submit_read_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return (shux_io_submit_read)((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }
static inline int32_t shux_io_submit_write_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return (shux_io_submit_write)((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }
static inline int32_t std_io_driver_submit_read_via_ptr(ptrdiff_t buf, uint32_t timeout_ms) { return shux_io_submit_read_buf((intptr_t)buf, (int32_t)timeout_ms); }
static inline int32_t std_io_driver_submit_write_via_ptr(ptrdiff_t buf, uint32_t timeout_ms) { return shux_io_submit_write_buf((intptr_t)buf, (int32_t)timeout_ms); }
#define shux_io_register(buf) shux_io_register_buf(buf)
#define shux_io_submit_read(buf, timeout_m) shux_io_submit_read_buf(buf, timeout_m)
#define shux_io_submit_write(buf, timeout_m) shux_io_submit_write_buf(buf, timeout_m)
/* 撤销宏：X codegen 会生成同名函数定义(shux_io_register/submit_read/submit_write)，宏与多参签名冲突，在函数体前必须 undef。 */
#undef shux_io_register
#undef shux_io_submit_read
#undef shux_io_submit_write
struct std_io_driver_Buffer { void *ptr; size_t len; size_t handle; };
typedef struct std_io_driver_Buffer std_io_Buffer;
#define std_io_Buffer std_io_driver_Buffer
extern ptrdiff_t io_read_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms);
extern ptrdiff_t io_write_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms);
extern int32_t std_io_driver_submit_register_fixed_buffers_buf(struct std_io_driver_Buffer * bufs, uint32_t nr);
#define std_io_driver_driver_read_ptr_len shux_io_read_ptr_len
#define std_io_driver_driver_read_ptr shux_io_read_ptr
#define driver_read_ptr_len std_io_driver_driver_read_ptr_len
#define driver_read_ptr std_io_driver_driver_read_ptr
#define submit_register_fixed_buffers_buf std_io_driver_submit_register_fixed_buffers_buf
/* 短名 submit_read/write → via_ptr；全名 std_io_driver_submit_* 由 co-emit 定义。 */
#define submit_read(buf, timeout_ms) std_io_driver_submit_read_via_ptr((ptrdiff_t)(uintptr_t)&(buf), (timeout_ms))
#define submit_write(buf, timeout_ms) std_io_driver_submit_write_via_ptr((ptrdiff_t)(uintptr_t)&(buf), (timeout_ms))
#define std_io_driver_read_ptr driver_read_ptr
#define std_io_driver_read_ptr_len driver_read_ptr_len
extern size_t std_io_handle_stdin(void);
extern size_t std_io_handle_stdout(void);
extern size_t std_io_handle_stderr(void);
extern size_t std_io_handle_from_fd(int32_t fd, int32_t unused);
extern size_t std_io_driver_handle_from_fd(int32_t fd, int32_t unused);
extern int32_t std_io_write_stdout(uint8_t *ptr, size_t len);
#define std_io_driver_handle_stdin std_io_handle_stdin
#define std_io_driver_handle_stdout std_io_handle_stdout
#define std_io_driver_handle_stderr std_io_handle_stderr
#define std_io_driver_write_stdout std_io_write_stdout
/* std.io.core 体内调 extern io_*；codegen 前缀为 std_io_core_io_*，映射到 preamble 已声明的 io_*。 */
#define std_io_core_io_read io_read
#define std_io_core_io_write io_write
#define std_io_core_io_read_batch io_read_batch
#define std_io_core_io_write_batch io_write_batch
#define std_io_core_io_read_fixed io_read_fixed
#define std_io_core_io_write_fixed io_write_fixed
#define std_io_core_shux_io_register shux_io_register
#define std_io_core_shux_io_register_buffers shux_io_register_buffers
#define std_io_core_shux_io_unregister_buffers shux_io_unregister_buffers
#define std_io_core_shux_io_submit_read shux_io_submit_read
#define std_io_core_shux_io_read_ptr shux_io_read_ptr
#define std_io_core_shux_io_read_ptr_len shux_io_read_ptr_len
#define std_io_core_shux_io_submit_write shux_io_submit_write
#define std_io_core_shux_io_submit_read_batch shux_io_submit_read_batch
#define std_io_core_shux_io_submit_write_batch shux_io_submit_write_batch
#define std_io_core_shux_io_read_fixed shux_io_read_fixed
#define std_io_core_shux_io_write_fixed shux_io_write_fixed
#define std_io_core_shux_io_register_buffers_buf io_register_buffers_buf
#define std_io_core_shux_io_read_ptr_gen shux_io_read_ptr_gen
#define std_io_core_shux_io_read_ptr_gen_valid shux_io_read_ptr_gen_valid
#define std_io_core_shux_io_read_ptr_backend shux_io_read_ptr_backend
#define std_io_core_shux_io_read_ptr_slice shux_io_read_ptr_slice
#define std_io_core_shux_io_read_batch_buf(fd, bufs, n, t) io_read_batch_buf((fd), (const struct std_io_driver_Buffer *)(const void *)(bufs), (n), (t))
#define std_io_core_shux_io_write_batch_buf(fd, bufs, n, t) io_write_batch_buf((fd), (const struct std_io_driver_Buffer *)(const void *)(bufs), (n), (t))
#define std_io_core_shux_io_register_provided_buffers shux_io_register_provided_buffers
#define std_io_core_shux_io_unregister_provided_buffers shux_io_unregister_provided_buffers
#define std_io_core_shux_io_provided_buffer_ptr shux_io_provided_buffer_ptr
#define std_io_core_shux_io_provided_buffer_size shux_io_provided_buffer_size
#define std_io_core_shux_io_read_provided shux_io_read_provided
#define std_io_core_shux_io_read_batch_provided shux_io_read_batch_provided
#define std_io_core_shux_io_submit_read_async shux_io_submit_read_async
#define std_io_core_shux_io_complete_read_async shux_io_complete_read_async
#define std_io_core_shux_io_complete_read_async_slot shux_io_complete_read_async_slot
#define std_io_core_shux_io_submit_write_async shux_io_submit_write_async
#define std_io_core_shux_io_complete_write_async shux_io_complete_write_async
#define std_io_core_shux_io_complete_write_async_slot shux_io_complete_write_async_slot
#define std_io_core_shux_io_poll_async_completions shux_io_poll_async_completions
#define std_io_core_shux_io_uring_is_available_c shux_io_uring_is_available_c
extern int32_t shux_io_read_ptr_gen_valid(uint64_t saved);
extern int32_t shux_io_read_ptr_backend(void);
extern uint64_t shux_io_read_ptr_gen(void);
extern struct shux_slice_uint8_t shux_io_read_ptr_slice(size_t handle, uint32_t timeout_ms);
extern int32_t shux_io_register_provided_buffers(uint32_t nr, uint32_t bufsz);
extern void shux_io_unregister_provided_buffers(void);
extern uint8_t *shux_io_provided_buffer_ptr(uint32_t bid);
extern uint32_t shux_io_provided_buffer_size(void);
extern int32_t shux_io_read_provided(size_t handle, uint32_t timeout_ms, uint32_t *out_bid, uint32_t *out_len);
extern int32_t shux_io_read_batch_provided(size_t handle, int32_t n, uint32_t timeout_ms, uint32_t *out_bids, uint32_t *out_lens);
extern int32_t shux_io_submit_read_async(uint8_t *ptr, size_t len, size_t handle);
extern int32_t shux_io_complete_read_async(void);
extern int32_t shux_io_complete_read_async_slot(int32_t slot);
extern int32_t shux_io_submit_write_async(uint8_t *ptr, size_t len, size_t handle);
extern int32_t shux_io_complete_write_async(void);
extern int32_t shux_io_complete_write_async_slot(int32_t slot);
extern uint32_t shux_io_poll_async_completions(uint32_t timeout_ms);
extern int32_t shux_io_uring_is_available_c(void);
#define std_io_driver_io_register_buffers_buf(bufs, nr) io_register_buffers_buf((intptr_t)(void *)(bufs), (int)(nr))
extern int32_t std_io_driver_submit_read_batch_buf(size_t handle, struct std_io_driver_Buffer * bufs, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_driver_submit_write_batch_buf(size_t handle, struct std_io_driver_Buffer * bufs, int32_t n, uint32_t timeout_ms);
#define std_io_submit_read_batch_buf std_io_driver_submit_read_batch_buf
#define std_io_submit_write_batch_buf std_io_driver_submit_write_batch_buf
extern int32_t std_io_read_fixed_fd_impl(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t std_io_write_fixed_fd_impl(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
/* X 生成代码可能调用 std_io_* / std_net_* 带前缀名且首参为 stream/listener 结构体；以下宏统一转为 .fd 再调 _impl。C 路径下 std.io 仍定义 std_io_read_fixed_fd，故仅 X 需宏。 */
struct std_net_TcpStream { int32_t fd; };
struct std_net_TcpListener { int32_t fd; };
struct std_net_UdpSocket { int32_t fd; };
#if defined(__clang__)
#define shux_io_net_fd(x) _Generic((x), struct std_net_TcpStream: (x).fd, struct std_net_TcpListener: (x).fd, struct std_net_UdpSocket: (x).fd, default: (int32_t)(x))
#elif defined(__GNUC__)
/* 仅用 *(int32_t*)&(x)：int32_t 与仅含 .fd 的 struct 首字节相同，且避免 __builtin_types_compatible_p 在部分环境报错、三元分支被全量类型检查。调用方须传 lvalue。 */
#define shux_io_net_fd(x) (*(int32_t*)(void*)&(x))
#else
#define shux_io_net_fd(x) _Generic((x), struct std_net_TcpStream: (x).fd, struct std_net_TcpListener: (x).fd, struct std_net_UdpSocket: (x).fd, default: (int32_t)(x))
#endif
#define std_io_read_fixed_fd(x, a, b, c, d) std_io_read_fixed_fd_impl(shux_io_net_fd(x), a, b, c, d)
#define std_io_write_fixed_fd(x, a, b, c, d) std_io_write_fixed_fd_impl(shux_io_net_fd(x), a, b, c, d)
/* X 内联 std.io 会生成函数定义；撤销与定义/extern 冲突的宏，并补齐 batch 注册符号映射。 */
#undef std_io_driver_io_register_buffers_buf
#undef std_io_read_fixed_fd
#undef std_io_write_fixed_fd
#undef std_io_core_shux_io_register_buffers
#undef std_io_core_shux_io_unregister_buffers
#undef std_io_core_shux_io_read_fixed
#undef std_io_core_shux_io_write_fixed
#undef std_io_core_shux_io_wait_readable
#define std_io_core_shux_io_register_buffers io_register_buffers_4
#define std_io_core_shux_io_unregister_buffers io_unregister_buffers
#define std_io_core_shux_io_read_fixed shux_io_read_fixed
#define std_io_core_shux_io_write_fixed shux_io_write_fixed
#define std_io_core_shux_io_wait_readable io_wait_readable
/* codegen 体内调 std_io_driver_io_*；#undef 后重绑到 preamble/io.o 的 io_*。 */
#define std_io_driver_io_read_batch_buf io_read_batch_buf
#define std_io_driver_io_write_batch_buf io_write_batch_buf
#define std_io_driver_io_register_buffers_buf(bufs, nr) io_register_buffers_buf((intptr_t)(void *)(bufs), (int)(nr))
#include <stdio.h>
#include <stdlib.h>
#ifndef __cplusplus
/* 仅补 co-emit 未定义的符号；勿桩 shux_io_submit_write / submit_read_batch_buf（同 TU 强定义）。 */
__attribute__((weak)) int32_t shux_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m) {
  size_t r; (void)timeout_m; if (!ptr) return 0; if (handle != 0) return -1;
  r = fread(ptr, 1, len, stdin); if (r == 0 && ferror(stdin)) return -1; return (int32_t)r;
}
__attribute__((weak)) int32_t shux_io_submit_read_async(uint8_t *ptr, size_t len, size_t handle) {
  (void)ptr; (void)len; (void)handle; return -1;
}
__attribute__((weak)) int32_t shux_io_read_fixed(size_t h, uint32_t bi, size_t o, size_t l, uint32_t t) {
  (void)h;(void)bi;(void)o;(void)l;(void)t; return -1;
}
__attribute__((weak)) int32_t shux_io_write_fixed(size_t h, uint32_t bi, size_t o, size_t l, uint32_t t) {
  (void)h;(void)bi;(void)o;(void)l;(void)t; return -1;
}
__attribute__((weak)) int32_t shux_io_read_ptr_backend(void) { return 0; }
__attribute__((weak)) int io_register_buffers_4(uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2, uint8_t *p3, size_t l3, unsigned nr) {
  (void)p0;(void)l0;(void)p1;(void)l1;(void)p2;(void)l2;(void)p3;(void)l3;(void)nr; return -1;
}
__attribute__((weak)) int io_wait_readable(int32_t *fds, int n, unsigned timeout_ms) {
  (void)fds;(void)n;(void)timeout_ms; return -1;
}
__attribute__((weak)) ptrdiff_t io_read_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms) {
  (void)fd;(void)bufs;(void)n;(void)timeout_ms; return (ptrdiff_t)-1;
}
__attribute__((weak)) ptrdiff_t io_write_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms) {
  (void)fd;(void)bufs;(void)n;(void)timeout_ms; return (ptrdiff_t)-1;
}
extern int32_t process_shux_argc_get(void);
extern uint8_t *process_shux_argv_get(int32_t i);
__attribute__((weak)) int32_t process_args_count_c(void) { return process_shux_argc_get(); }
__attribute__((weak)) uint8_t *process_arg_c(int32_t i) { return process_shux_argv_get(i); }
__attribute__((weak)) int32_t args_iter_count_c(void) { return process_args_count_c(); }
__attribute__((weak)) uint8_t *args_iter_at_c(int32_t i) { return process_arg_c(i); }
__attribute__((weak)) uint64_t std_io_driver_driver_read_ptr_gen(void) { return 0; }
__attribute__((weak)) int64_t ctx_background_c(void) { return 0; }
__attribute__((weak)) void ctx_cancel_c(int64_t c) { (void)c; }
__attribute__((weak)) int64_t ctx_deadline_ns_c(int64_t c) { (void)c; return 0; }
__attribute__((weak)) void ctx_free_c(int64_t c) { (void)c; }
__attribute__((weak)) int32_t ctx_get_value_c(int64_t h, uint8_t *key, int64_t *out) {
  (void)h;(void)key; if (out) *out = 0; return 0;
}
__attribute__((weak)) int32_t ctx_is_cancelled_c(int64_t c) { (void)c; return 0; }
__attribute__((weak)) int64_t ctx_remaining_ns_c(int64_t c) { (void)c; return 0; }
__attribute__((weak)) int32_t ctx_set_value_c(int64_t h, uint8_t *key, int64_t value) {
  (void)h;(void)key;(void)value; return 0;
}
__attribute__((weak)) int64_t ctx_with_cancel_c(int64_t p) { (void)p; return 0; }
__attribute__((weak)) int64_t ctx_with_deadline_c(int64_t p, int64_t ns) { (void)p;(void)ns; return 0; }
__attribute__((weak)) int64_t ctx_with_timeout_c(int64_t p, int64_t ns) { (void)p;(void)ns; return 0; }
#endif
struct std_net_Ipv4Addr { uint8_t a; uint8_t b; uint8_t c; uint8_t d; };
struct std_net_Ipv6Addr { uint8_t b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15; };
#define handle_from_fd std_io_handle_from_fd
#define submit_read_batch_buf std_io_submit_read_batch_buf
#define submit_write_batch_buf std_io_submit_write_batch_buf
#define read_fixed_fd(x, a, b, c, d) std_io_read_fixed_fd_impl(shux_io_net_fd(x), a, b, c, d)
#define write_fixed_fd(x, a, b, c, d) std_io_write_fixed_fd_impl(shux_io_net_fd(x), a, b, c, d)
/* 实际符号用 _real；仅定义 std_net_net_* 宏。
 * 【Why 勿 #define net_close_socket_c / net_run_accept_workers_c】
 * link_only 路径会 emit `extern int32_t net_close_socket_c(...)`；
 * 若宏同名，extern 声明被展开 → expected parameter declarator。 */
extern int32_t net_close_socket_c_real(int32_t fd);
extern int32_t net_run_accept_workers_c_real(int32_t listener_fd, int32_t n_workers, uint32_t timeout_ms);
extern int32_t net_close_socket_c(int32_t fd);
extern int32_t net_run_accept_workers_c(int32_t listener_fd, int32_t n_workers, uint32_t timeout_ms);
#define std_net_net_close_socket_c(x) net_close_socket_c_real(shux_io_net_fd(x))
#define std_net_net_run_accept_workers_c(x, n, t) net_run_accept_workers_c_real(shux_io_net_fd(x), n, t)
#define STD_FS_FS_IOVEC_BUF_DEFINED
struct std_fs_FsIovecBuf { void *ptr; size_t len; size_t handle; };
#define std_fs_posix_FsIovecBuf std_fs_FsIovecBuf
struct std_io_sync_Iovec { uint8_t *base; size_t len; };
#define std_fs_posix_Iovec std_io_sync_Iovec
struct std_map_Map_i32_i32;
typedef struct std_io_driver_Buffer std_net_Buffer;
struct std_error_Error { int32_t code; };
struct std_error_ErrorChain { int32_t depth; int32_t c0; int32_t c1; int32_t c2; int32_t c3; };
struct std_string_String { uint8_t data[256]; int32_t len; };
typedef struct std_string_String String;
struct std_string_StrView { uint8_t *ptr; int32_t len; };
struct std_heap_Arena64 { uint8_t *chunk; size_t cap; size_t off; };
struct std_heap_Allocator { int32_t kind; struct std_heap_Arena64 *arena; };
struct std_vec_Vec_i32;
struct core_option_Option_i32 { int is_some; int32_t value; };
struct core_option_Option_u8 { int is_some; uint8_t value; uint8_t _pad0; uint8_t _pad1; uint8_t _pad2; };
struct core_option_Option_u64 { int is_some; int32_t _pad; uint64_t value; };
struct core_option_Option_ptr_u8 { int is_some; int32_t _pad; uint8_t *value; };
struct core_result_Result_i32 { int32_t value; int32_t _pad1; int32_t err; int32_t _pad2; };
struct core_result_Result_u8 { uint8_t value; uint8_t _pad1; uint8_t _pad2; uint8_t _pad3; int32_t err; int32_t _pad4; };
extern void shux_panic_(int, int);
extern int32_t core_types_placeholder(void);
extern int32_t std_heap_alloc_size_zero(void);
extern int32_t std_runtime_runtime_ready(void);
#ifndef __cplusplus
__attribute__((weak)) int32_t std_vec_vec_len_empty(void) { return 0; }
__attribute__((weak)) int32_t std_vec_len_empty(void) { return 0; }
#else
extern int32_t std_vec_vec_len_empty(void);
extern int32_t std_vec_len_empty(void);
#endif
#define vec_len_empty std_vec_vec_len_empty
#define alloc_size_zero std_heap_alloc_size_zero
#define runtime_ready std_runtime_runtime_ready
#ifndef __cplusplus
__attribute__((weak)) int32_t std_string_placeholder(void) { return 0; }
#else
extern int32_t std_string_placeholder(void);
#endif
extern int32_t fmt_i32(int32_t);
extern struct std_string_String std_string_string_new(void);
typedef struct std_fs_FsIovecBuf fs_iovec_buf_t;
extern int32_t fs_open_read_c(uint8_t *path);
extern uint64_t fs_direct_align_c(void);
extern int32_t fs_fadvise_sequential_c(int32_t fd);
extern int32_t fs_fadvise_willneed_c(int32_t fd, int64_t offset, size_t len);
extern int64_t fs_copy_file_range_c(int32_t fd_in, int32_t fd_out, size_t len);
extern int64_t fs_sendfile_c(int32_t out_fd, int32_t in_fd, size_t count);
extern int64_t fs_pipe_splice_c(int32_t fd_in, int32_t fd_out, size_t len);
extern int32_t fs_sync_range_c(int32_t fd, int64_t offset, size_t len);
extern int32_t fs_sync_c(int32_t fd);
extern int32_t fs_fallocate_c(int32_t fd, int64_t offset, int64_t len);
extern int32_t fs_last_error_c(void);
extern int64_t fs_readv_buf_c(int32_t fd, const fs_iovec_buf_t *bufs, int n);
extern int64_t fs_writev_buf_c(int32_t fd, const fs_iovec_buf_t *bufs, int n);
extern int32_t std_path_empty_len(void);
#define empty_len() std_path_empty_len()
extern int32_t map_i32_i32_find_c(const int32_t *keys, const uint8_t *occupied, int32_t cap, int32_t key);
extern int32_t std_map_empty_size(void);
#define empty_size(_a, _b) std_map_empty_size()
extern int32_t std_error_error_ok(void);
#define error_ok(_a, _b) std_error_error_ok()
#include <stddef.h>
#include <sys/types.h>
enum ast_TypeKind { ast_TypeKind_TYPE_I32, ast_TypeKind_TYPE_BOOL, ast_TypeKind_TYPE_U8, ast_TypeKind_TYPE_U32, ast_TypeKind_TYPE_U64, ast_TypeKind_TYPE_I64, ast_TypeKind_TYPE_USIZE, ast_TypeKind_TYPE_ISIZE, ast_TypeKind_TYPE_NAMED, ast_TypeKind_TYPE_PTR, ast_TypeKind_TYPE_ARRAY, ast_TypeKind_TYPE_SLICE, ast_TypeKind_TYPE_LINEAR, ast_TypeKind_TYPE_VECTOR, ast_TypeKind_TYPE_F32, ast_TypeKind_TYPE_F64, ast_TypeKind_TYPE_VOID };
enum ast_ExprKind { ast_ExprKind_EXPR_LIT, ast_ExprKind_EXPR_FLOAT_LIT, ast_ExprKind_EXPR_BOOL_LIT, ast_ExprKind_EXPR_VAR, ast_ExprKind_EXPR_ADD, ast_ExprKind_EXPR_SUB, ast_ExprKind_EXPR_MUL, ast_ExprKind_EXPR_DIV, ast_ExprKind_EXPR_MOD, ast_ExprKind_EXPR_SHL, ast_ExprKind_EXPR_SHR, ast_ExprKind_EXPR_BITAND, ast_ExprKind_EXPR_BITOR, ast_ExprKind_EXPR_BITXOR, ast_ExprKind_EXPR_EQ, ast_ExprKind_EXPR_NE, ast_ExprKind_EXPR_LT, ast_ExprKind_EXPR_LE, ast_ExprKind_EXPR_GT, ast_ExprKind_EXPR_GE, ast_ExprKind_EXPR_LOGAND, ast_ExprKind_EXPR_LOGOR, ast_ExprKind_EXPR_NEG, ast_ExprKind_EXPR_BITNOT, ast_ExprKind_EXPR_LOGNOT, ast_ExprKind_EXPR_IF, ast_ExprKind_EXPR_BLOCK, ast_ExprKind_EXPR_TERNARY, ast_ExprKind_EXPR_ASSIGN, ast_ExprKind_EXPR_ADD_ASSIGN, ast_ExprKind_EXPR_SUB_ASSIGN, ast_ExprKind_EXPR_MUL_ASSIGN, ast_ExprKind_EXPR_DIV_ASSIGN, ast_ExprKind_EXPR_MOD_ASSIGN, ast_ExprKind_EXPR_BITAND_ASSIGN, ast_ExprKind_EXPR_BITOR_ASSIGN, ast_ExprKind_EXPR_BITXOR_ASSIGN, ast_ExprKind_EXPR_SHL_ASSIGN, ast_ExprKind_EXPR_SHR_ASSIGN, ast_ExprKind_EXPR_BREAK, ast_ExprKind_EXPR_CONTINUE, ast_ExprKind_EXPR_RETURN, ast_ExprKind_EXPR_PANIC, ast_ExprKind_EXPR_MATCH, ast_ExprKind_EXPR_FIELD_ACCESS, ast_ExprKind_EXPR_STRUCT_LIT, ast_ExprKind_EXPR_ARRAY_LIT, ast_ExprKind_EXPR_INDEX, ast_ExprKind_EXPR_CALL, ast_ExprKind_EXPR_METHOD_CALL, ast_ExprKind_EXPR_ENUM_VARIANT, ast_ExprKind_EXPR_ADDR_OF, ast_ExprKind_EXPR_DEREF, ast_ExprKind_EXPR_BINOP, ast_ExprKind_EXPR_AS, ast_ExprKind_EXPR_AWAIT, ast_ExprKind_EXPR_RUN, ast_ExprKind_EXPR_SPAWN, ast_ExprKind_EXPR_TRY_PROPAGATE, ast_ExprKind_EXPR_STRING_LIT };
enum ast_ImportKind { ast_ImportKind_IMPORT_WHOLE, ast_ImportKind_IMPORT_BINDING, ast_ImportKind_IMPORT_SELECT };
struct ast_Type {
  int32_t kind;
  uint8_t name[64];
  int32_t name_len;
  int32_t elem_type_ref;
  int32_t array_size;
  uint8_t region_label[64];
  int32_t region_label_len;
};

struct ast_Expr {
  int32_t kind;
  int32_t resolved_type_ref;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t var_name[64];
  int32_t var_name_len;
  int32_t binop_left_ref;
  int32_t binop_right_ref;
  int32_t unary_operand_ref;
  int32_t if_cond_ref;
  int32_t if_then_ref;
  int32_t if_else_ref;
  int32_t block_ref;
  int32_t match_matched_ref;
  int32_t match_arm_base;
  int32_t match_num_arms;
  int32_t field_access_base_ref;
  uint8_t field_access_field_name[64];
  int32_t field_access_field_len;
  int32_t field_access_is_enum_variant;
  int32_t field_access_offset;
  int32_t field_access_soa_stride;
  int32_t index_base_ref;
  int32_t index_index_ref;
  int32_t index_base_is_slice;
  int32_t call_callee_ref;
  int32_t call_arg_base;
  int32_t call_num_args;
  int32_t call_num_type_args;
  int32_t method_call_base_ref;
  uint8_t method_call_name[64];
  int32_t method_call_name_len;
  int32_t method_call_arg_base;
  int32_t method_call_num_args;
  int32_t const_folded_val;
  int32_t const_folded_valid;
  int32_t index_proven_in_bounds;
  uint8_t struct_lit_struct_name[64];
  int32_t struct_lit_struct_name_len;
  int32_t struct_lit_field_base;
  int32_t struct_lit_num_fields;
  int32_t array_lit_elem_base;
  int32_t array_lit_num_elems;
  int32_t float_bits_lo;
  int32_t float_bits_hi;
  int32_t enum_variant_tag;
  int32_t as_operand_ref;
  int32_t as_target_type_ref;
  int32_t call_resolved_func_index;
  int32_t call_resolved_dep_index;
};

struct ast_ConstDecl {
  uint8_t name[64];
  int32_t name_len;
  int32_t type_ref;
  int32_t init_ref;
};

struct ast_LetDecl {
  uint8_t name[64];
  int32_t name_len;
  int32_t type_ref;
  int32_t init_ref;
};

struct ast_WhileLoop {
  int32_t cond_ref;
  int32_t body_ref;
};

struct ast_ForLoop {
  int32_t init_ref;
  int32_t cond_ref;
  int32_t step_ref;
  int32_t body_ref;
};

struct ast_IfStmt {
  int32_t cond_ref;
  int32_t then_body_ref;
  int32_t else_body_ref;
};

struct ast_StmtOrderItem {
  uint8_t kind;
  int32_t idx;
};

struct ast_LabeledStmt {
  uint8_t label[32];
  int32_t label_len;
  int32_t is_goto;
  uint8_t goto_target[32];
  int32_t goto_target_len;
  int32_t return_expr_ref;
};

struct ast_Block {
  int32_t const_base;
  int32_t num_consts;
  int32_t let_base;
  int32_t num_lets;
  int32_t num_early_lets;
  int32_t loop_base;
  int32_t num_loops;
  int32_t for_loop_base;
  int32_t num_for_loops;
  int32_t if_base;
  int32_t num_if_stmts;
  int32_t region_base;
  int32_t num_regions;
  int32_t defer_base;
  int32_t num_defers;
  int32_t labeled_base;
  int32_t num_labeled_stmts;
  int32_t expr_stmt_base;
  int32_t num_expr_stmts;
  int32_t final_expr_ref;
  int32_t stmt_order_base;
  int32_t num_stmt_order;
  int32_t parent_block_ref;
};

struct ast_Param {
  uint8_t name[32];
  int32_t name_len;
  int32_t type_ref;
};

struct ast_Func {
  uint8_t name[64];
  int32_t name_len;
  int32_t param_base;
  int32_t num_params;
  int32_t num_generic_params;
  int32_t return_type_ref;
  int32_t body_ref;
  int32_t body_expr_ref;
  int32_t is_extern;
  int32_t is_async;
  int32_t is_used;
  int32_t is_naked;
  int32_t is_entry;
  int32_t is_no_mangle;
  int32_t is_interrupt;
  int32_t abi_kind;
  int32_t is_variadic;
  int32_t is_export;
};

struct ast_StructLayout {
  uint8_t name[64];
  int32_t name_len;
  int32_t field_base;
  int32_t num_fields;
  int32_t allow_padding;
  int32_t soa;
  int32_t packed;
  int32_t repr_compatible;
  int32_t is_export;
};

struct ast_Module {
  int32_t num_funcs;
  int32_t main_func_index;
  int32_t num_imports;
  int32_t num_top_level_lets;
  int32_t num_struct_layouts;
  int32_t pending_allow_padding;
  int32_t pending_soa_struct;
  int32_t pending_cfg_skip;
  int32_t pending_repr_c_struct;
  int32_t pending_repr_compatible_struct;
  int32_t pending_used;
  int32_t pending_naked;
  int32_t pending_entry;
  int32_t pending_no_mangle;
  int32_t pending_interrupt;
  int32_t pending_export;
  int32_t num_module_enums;
};

struct ast_ASTArena {
  int32_t num_types;
  int32_t num_exprs;
  int32_t num_blocks;
  int32_t num_funcs;
};

/* pipeline call aliases (ast_pipeline_* extern, pipeline_* call) */
#define ast_arena_init ast_ast_arena_init
#define ast_arena_type_alloc ast_ast_arena_type_alloc
#define ast_arena_expr_alloc ast_ast_arena_expr_alloc
#define ast_arena_block_alloc ast_ast_arena_block_alloc
#define ast_arena_type_get ast_ast_arena_type_get
#define ast_arena_type_set ast_ast_arena_type_set
#define ast_arena_expr_get ast_ast_arena_expr_get
#define ast_arena_expr_set ast_ast_arena_expr_set
#define ast_arena_block_get ast_ast_arena_block_get
#define ast_arena_patch_block_parent_links ast_ast_arena_patch_block_parent_links
#define ast_arena_block_set ast_ast_arena_block_set
#define ast_arena_func_alloc ast_ast_arena_func_alloc
#define ast_arena_func_get ast_ast_arena_func_get
#define ast_arena_func_set ast_ast_arena_func_set
#define codegen_codegen_path_is_std_io_driver_bytes codegen_path_is_std_io_driver_bytes
#define codegen_codegen_path_is_std_io_core_bytes codegen_path_is_std_io_core_bytes
#define codegen_codegen_dep_import_path_len_at codegen_dep_import_path_len_at
#define codegen_codegen_ctx_dep_path_for_current_codegen_module_into codegen_ctx_dep_path_for_current_codegen_module_into
#define codegen_codegen_module_import_path_len_at codegen_module_import_path_len_at
#define codegen_codegen_find_dep_index_by_path codegen_find_dep_index_by_path
#define codegen_codegen_find_seeded_global_dep_slot_by_path codegen_find_seeded_global_dep_slot_by_path
#define codegen_codegen_module_num_imports codegen_module_num_imports
#define codegen_codegen_emit_prefix_len_from_ctx codegen_emit_prefix_len_from_ctx
#define codegen_codegen_emit_async_run_seed_push_name codegen_emit_async_run_seed_push_name
#define codegen_codegen_emit_async_sched_call codegen_emit_async_sched_call
#define codegen_codegen_emit_async_sched_call_by_name codegen_emit_async_sched_call_by_name
#define codegen_codegen_emit_async_task_submit_call codegen_emit_async_task_submit_call
#define codegen_codegen_emit_async_task_submit_call_by_symbol codegen_emit_async_task_submit_call_by_symbol
#define codegen_codegen_emit_async_binding_import_call codegen_emit_async_binding_import_call
#define codegen_codegen_emit_async_method_call_run codegen_emit_async_method_call_run
#define codegen_codegen_find_module_func_index_by_name codegen_find_module_func_index_by_name
#define codegen_codegen_resolve_binding_import_dep_index codegen_resolve_binding_import_dep_index
#define codegen_codegen_resolve_call_target_func_index codegen_resolve_call_target_func_index
#define codegen_codegen_expr_var_matches_func_param_index codegen_expr_var_matches_func_param_index
#define codegen_codegen_symbuf_bytes_eq codegen_symbuf_bytes_eq
#define codegen_codegen_call_num_args_override codegen_call_num_args_override
#define codegen_codegen_name_bytes_prefix_eq codegen_name_bytes_prefix_eq
#define codegen_codegen_is_std_io_driver_bridge_name codegen_is_std_io_driver_bridge_name
#define codegen_codegen_should_skip_emit_std_io_core_io_dup codegen_should_skip_emit_std_io_core_io_dup
#define codegen_codegen_should_skip_emit_std_io_trivial_handle codegen_should_skip_emit_std_io_trivial_handle
#define codegen_codegen_should_skip_emit_func codegen_should_skip_emit_func
#define codegen_codegen_force_param_std_io_driver_prefix_ok codegen_force_param_std_io_driver_prefix_ok
#define codegen_codegen_force_param_size_t codegen_force_param_size_t
#define codegen_codegen_force_param_size_t_std_io_print_str_second codegen_force_param_size_t_std_io_print_str_second
#define codegen_codegen_force_param_ptrdiff_t codegen_force_param_ptrdiff_t
#define codegen_codegen_force_param_uint32_t codegen_force_param_uint32_t
#define codegen_codegen_use_buf_wrapper codegen_use_buf_wrapper
#define codegen_codegen_emit_io_driver_buf_call_name codegen_emit_io_driver_buf_call_name
#define codegen_codegen_try_emit_std_io_driver_buf_body codegen_try_emit_std_io_driver_buf_body
#define codegen_codegen_field_access_base_is_pointer_ref codegen_field_access_base_is_pointer_ref
#define codegen_codegen_field_access_base_type_resolved codegen_field_access_base_type_resolved
#define codegen_codegen_field_access_base_is_pointer_param codegen_field_access_base_is_pointer_param
#define codegen_codegen_field_access_base_is_pointer_local codegen_field_access_base_is_pointer_local
#define codegen_codegen_emit_call_arg_slice_abi codegen_emit_call_arg_slice_abi
#define codegen_codegen_field_access_base_param_type_known codegen_field_access_base_param_type_known
#define codegen_codegen_field_access_base_is_slice_param_name codegen_field_access_base_is_slice_param_name
#define codegen_codegen_block_stmt_order_has_let codegen_block_stmt_order_has_let
#define codegen_codegen_c_prefix_redundant_with_name codegen_c_prefix_redundant_with_name
#define codegen_codegen_append_byte codegen_append_byte
#define codegen_codegen_append_byte_u8 codegen_append_byte_u8
#define codegen_codegen_emit_bytes_from_ptr codegen_emit_bytes_from_ptr
#define codegen_codegen_emit_bytes_64 codegen_emit_bytes_64
#define codegen_codegen_emit_bytes_32 codegen_emit_bytes_32
#define codegen_codegen_emit_bytes_22 codegen_emit_bytes_22
#define codegen_codegen_emit_bytes_9 codegen_emit_bytes_9
#define codegen_codegen_emit_bytes_8 codegen_emit_bytes_8
#define codegen_codegen_emit_bytes_7 codegen_emit_bytes_7
#define codegen_codegen_emit_bytes_6 codegen_emit_bytes_6
#define codegen_codegen_emit_bytes_5 codegen_emit_bytes_5
#define codegen_codegen_emit_bytes_4 codegen_emit_bytes_4
#define codegen_codegen_emit_bytes_3 codegen_emit_bytes_3
#define codegen_codegen_emit_bytes_2 codegen_emit_bytes_2
#define codegen_codegen_format_uint codegen_format_uint
#define codegen_codegen_format_uint64 codegen_format_uint64
#define codegen_codegen_format_int codegen_format_int
#define codegen_codegen_emit_indent codegen_emit_indent
#define codegen_codegen_emit_break_stmt codegen_emit_break_stmt
#define codegen_codegen_emit_continue_stmt codegen_emit_continue_stmt
#define codegen_codegen_emit_type_kind_ord codegen_emit_type_kind_ord
#define codegen_codegen_emit_type_kind codegen_emit_type_kind
#define codegen_codegen_type_kind_append_to_scratch codegen_type_kind_append_to_scratch
#define codegen_codegen_emit_vector_c_type_out codegen_emit_vector_c_type_out
#define codegen_codegen_type_kind_append_to_scratch_ord codegen_type_kind_append_to_scratch_ord
#define codegen_codegen_type_to_c_repr codegen_type_to_c_repr
#define codegen_codegen_emit_type codegen_emit_type
#define codegen_codegen_type_dep_struct_owner_index codegen_type_dep_struct_owner_index
#define codegen_codegen_type_dep_struct_prefix_into codegen_type_dep_struct_prefix_into
#define codegen_codegen_type_array_elem_is_u8 codegen_type_array_elem_is_u8
#define codegen_codegen_emit_local_fixed_array_elem_type codegen_emit_local_fixed_array_elem_type
#define codegen_codegen_emit_local_fixed_array_suffix codegen_emit_local_fixed_array_suffix
#define codegen_codegen_try_emit_slice_init_from_array_var codegen_try_emit_slice_init_from_array_var
#define codegen_codegen_emit_braced_array_lit_init codegen_emit_braced_array_lit_init
#define codegen_codegen_emit_struct_field_type_via_pipeline codegen_emit_struct_field_type_via_pipeline
#define codegen_codegen_should_skip_emit_struct_layout_for_abi_dup codegen_should_skip_emit_struct_layout_for_abi_dup
#define codegen_codegen_type_is_module_user_struct codegen_type_is_module_user_struct
#define codegen_codegen_type_is_module_user_enum codegen_type_is_module_user_enum
#define codegen_codegen_type_dep_enum_prefix_into codegen_type_dep_enum_prefix_into
#define codegen_codegen_emit_struct_field_decl_x codegen_emit_struct_field_decl_x
#define codegen_codegen_emit_module_struct_definitions codegen_emit_module_struct_definitions
#define codegen_codegen_emit_module_struct_forward_declarations codegen_emit_module_struct_forward_declarations
#define codegen_codegen_emit_module_struct_forward_declarations_ctx codegen_emit_module_struct_forward_declarations_ctx
#define codegen_codegen_emit_module_enum_definitions codegen_emit_module_enum_definitions
#define codegen_codegen_emit_skipped_dep_type_definitions codegen_emit_skipped_dep_type_definitions
#define codegen_codegen_emit_dep_struct_forward_declarations codegen_emit_dep_struct_forward_declarations
#define codegen_codegen_resolve_binding_import_path_for_field_access codegen_resolve_binding_import_path_for_field_access
#define codegen_codegen_resolve_binding_import_path_for_method_call codegen_resolve_binding_import_path_for_method_call
#define codegen_codegen_emit_import_module_field_symbol codegen_emit_import_module_field_symbol
#define codegen_codegen_emit_import_module_const_field codegen_emit_import_module_const_field
#define codegen_codegen_emit_expr codegen_emit_expr
#define codegen_codegen_callee_var_is_string_new codegen_callee_var_is_string_new
#define codegen_codegen_emit_run_defers codegen_emit_run_defers
#define codegen_codegen_current_func_returns_void codegen_current_func_returns_void
#define codegen_codegen_emit_return_stmt_with_context codegen_emit_return_stmt_with_context
#define codegen_codegen_emit_block_final_expr codegen_emit_block_final_expr
#define codegen_codegen_emit_block codegen_emit_block
#define codegen_codegen_emit_suffix_bytes codegen_emit_suffix_bytes
#define codegen_codegen_type_ref_to_suffix codegen_type_ref_to_suffix
#define codegen_codegen_module_func_overload_count codegen_module_func_overload_count
#define codegen_codegen_func_param_sig_equal codegen_func_param_sig_equal
#define codegen_codegen_module_overload_param_sig_count codegen_module_overload_param_sig_count
#define codegen_codegen_func_c_symbol_prefix_len codegen_func_c_symbol_prefix_len
#define codegen_codegen_emit_func_link_name codegen_emit_func_link_name
#define codegen_codegen_emit_call_func_name codegen_emit_call_func_name
#define codegen_codegen_emit_func codegen_emit_func
#define codegen_codegen_is_libc_conflicting_extern_name codegen_is_libc_conflicting_extern_name
#define codegen_codegen_find_mono_type_for_generic_func codegen_find_mono_type_for_generic_func
#define codegen_codegen_try_emit_generic_identity_mono codegen_try_emit_generic_identity_mono
#define codegen_codegen_emit_func_extern_declaration codegen_emit_func_extern_declaration
#define codegen_codegen_emit_import_dep_function_declarations codegen_emit_import_dep_function_declarations
#define codegen_codegen_x_ast_emit_header codegen_x_ast_emit_header
#define codegen_codegen_x_ast codegen_x_ast
#define codegen_codegen_should_skip_emit_func_by_name codegen_should_skip_emit_func_by_name
#define codegen_codegen_is_submit_batch_buf_call codegen_is_submit_batch_buf_call
#define codegen_codegen_force_param_i32 codegen_force_param_i32
#define codegen_codegen_should_skip_emit_func_core_read_ptr codegen_should_skip_emit_func_core_read_ptr
#define codegen_codegen_std_io_fixed_fd_emit_impl codegen_std_io_fixed_fd_emit_impl
#define ast_expr_apply_call_resolve ast_ast_expr_apply_call_resolve
#define ast_block_final_expr_ref ast_ast_block_final_expr_ref
#define ast_expr_disallows_implicit_tail ast_ast_expr_disallows_implicit_tail
#define ast_block_num_consts ast_ast_block_num_consts
#define ast_block_num_lets ast_ast_block_num_lets
#define ast_block_num_loops ast_ast_block_num_loops
#define ast_block_num_for_loops ast_ast_block_num_for_loops
#define ast_block_num_if_stmts ast_ast_block_num_if_stmts
#define ast_block_num_regions ast_ast_block_num_regions
#define ast_block_region_body_ref ast_ast_block_region_body_ref
#define ast_block_num_expr_stmts ast_ast_block_num_expr_stmts
#define ast_block_num_stmt_order ast_ast_block_num_stmt_order
#define ast_block_stmt_order_kind ast_ast_block_stmt_order_kind
#define ast_block_stmt_order_idx ast_ast_block_stmt_order_idx
#define ast_block_const_init_ref ast_ast_block_const_init_ref
#define ast_block_const_type_ref ast_ast_block_const_type_ref
#define ast_block_let_init_ref ast_ast_block_let_init_ref
#define ast_block_let_type_ref ast_ast_block_let_type_ref
#define ast_block_expr_stmt_ref ast_ast_block_expr_stmt_ref
#define ast_block_while_cond_ref ast_ast_block_while_cond_ref
#define ast_block_while_body_ref ast_ast_block_while_body_ref
#define ast_block_for_init_ref ast_ast_block_for_init_ref
#define ast_block_for_cond_ref ast_ast_block_for_cond_ref
#define ast_block_for_step_ref ast_ast_block_for_step_ref
#define ast_block_for_body_ref ast_ast_block_for_body_ref
#define ast_block_if_cond_ref ast_ast_block_if_cond_ref
#define ast_block_if_then_body_ref ast_ast_block_if_then_body_ref
#define ast_block_if_else_body_ref ast_ast_block_if_else_body_ref
#define ast_block_resolve_var_to_type_ref ast_ast_block_resolve_var_to_type_ref
#define ast_expr_layout_prime_call_resolved ast_ast_expr_layout_prime_call_resolved
#define ast_arena_expr_set ast_ast_arena_expr_set
#define ast_arena_block_set ast_ast_arena_block_set
#define ast_arena_type_set ast_ast_arena_type_set
#define ast_arena_func_set ast_ast_arena_func_set

/* pipeline reverse aliases (call ast_pipeline_* → pipeline_* extern) */
#define ast_pipeline_module_import_set_select_name pipeline_module_import_set_select_name
#define ast_pipeline_module_struct_layout_set_soa pipeline_module_struct_layout_set_soa
#define ast_pipeline_module_struct_layout_set_packed pipeline_module_struct_layout_set_packed
#define ast_pipeline_module_struct_layout_packed_at pipeline_module_struct_layout_packed_at
#define ast_pipeline_module_struct_layout_soa_at pipeline_module_struct_layout_soa_at
#define ast_pipeline_module_struct_layout_set_field_offset pipeline_module_struct_layout_set_field_offset
#define ast_pipeline_onefunc_append_const_name pipeline_onefunc_append_const_name
#define ast_pipeline_onefunc_const_name_byte_at pipeline_onefunc_const_name_byte_at
#define ast_pipeline_onefunc_let_name_byte_at pipeline_onefunc_let_name_byte_at
#define ast_pipeline_block_region_body_ref pipeline_block_region_body_ref
#define ast_pipeline_block_while_cond_ref pipeline_block_while_cond_ref
#define ast_pipeline_block_while_body_ref pipeline_block_while_body_ref
#define ast_pipeline_block_for_init_ref pipeline_block_for_init_ref
#define ast_pipeline_block_for_cond_ref pipeline_block_for_cond_ref
#define ast_pipeline_block_for_step_ref pipeline_block_for_step_ref
#define ast_pipeline_block_for_body_ref pipeline_block_for_body_ref
#define ast_pipeline_onefunc_while_cond_ref pipeline_onefunc_while_cond_ref
#define ast_pipeline_onefunc_while_body_ref pipeline_onefunc_while_body_ref
#define ast_pipeline_onefunc_for_init_ref pipeline_onefunc_for_init_ref
#define ast_pipeline_onefunc_for_cond_ref pipeline_onefunc_for_cond_ref
#define ast_pipeline_onefunc_for_step_ref pipeline_onefunc_for_step_ref
#define ast_pipeline_onefunc_for_body_ref pipeline_onefunc_for_body_ref
#define ast_pipeline_dep_ctx_module_at pipeline_dep_ctx_module_at
#define ast_pipeline_dep_ctx_arena_at pipeline_dep_ctx_arena_at
#define ast_pipeline_dep_ctx_import_path_byte_at pipeline_dep_ctx_import_path_byte_at
#define ast_pipeline_module_func_set_is_variadic pipeline_module_func_set_is_variadic
#define ast_pipeline_module_func_is_variadic_at pipeline_module_func_is_variadic_at
#define ast_pipeline_module_func_set_num_generic_params pipeline_module_func_set_num_generic_params
#define ast_pipeline_expr_call_num_type_args_at pipeline_expr_call_num_type_args_at
#define ast_pipeline_type_named_name_into pipeline_type_named_name_into
#define ast_pipeline_type_kind_ord_at pipeline_type_kind_ord_at
#define ast_pipeline_type_elem_ref_at pipeline_type_elem_ref_at
#define ast_pipeline_type_array_size_at pipeline_type_array_size_at
#define ast_pipeline_codegen_type_to_c_repr pipeline_codegen_type_to_c_repr
#define ast_pipeline_codegen_c_file_prologue_done_get pipeline_codegen_c_file_prologue_done_get
#define ast_pipeline_codegen_c_file_prologue_done_set pipeline_codegen_c_file_prologue_done_set
#define ast_pipeline_codegen_c_file_prologue_done_reset pipeline_codegen_c_file_prologue_done_reset
#define ast_pipeline_codegen_struct_tag_try_claim pipeline_codegen_struct_tag_try_claim
#define ast_pipeline_codegen_emit_struct_field_type pipeline_codegen_emit_struct_field_type
#define ast_pipeline_codegen_emit_struct_field_decl pipeline_codegen_emit_struct_field_decl
#define ast_pipeline_codegen_emit_seed_mega_enabled pipeline_codegen_emit_seed_mega_enabled
#define ast_pipeline_codegen_emit_float_lit_c pipeline_codegen_emit_float_lit_c
#define ast_pipeline_module_struct_layout_is_export_at pipeline_module_struct_layout_is_export_at
#define ast_pipeline_expr_kind_ord_at pipeline_expr_kind_ord_at
#define ast_pipeline_expr_resolved_type_ref pipeline_expr_resolved_type_ref
#define ast_pipeline_expr_as_target_type_ref_at pipeline_expr_as_target_type_ref_at
#define ast_pipeline_expr_call_resolved_dep_index_at pipeline_expr_call_resolved_dep_index_at
#define ast_pipeline_expr_call_resolved_func_index_at pipeline_expr_call_resolved_func_index_at
#define ast_pipeline_expr_struct_lit_field_name_len pipeline_expr_struct_lit_field_name_len
#define ast_pipeline_expr_struct_lit_field_name_into pipeline_expr_struct_lit_field_name_into
#define ast_pipeline_expr_struct_lit_init_ref pipeline_expr_struct_lit_init_ref
#define ast_pipeline_expr_struct_lit_num_fields pipeline_expr_struct_lit_num_fields
#define ast_pipeline_module_enum_num_variants pipeline_module_enum_num_variants
#define ast_pipeline_module_enum_variant_name_len pipeline_module_enum_variant_name_len
#define ast_pipeline_module_enum_variant_name_byte_at pipeline_module_enum_variant_name_byte_at
#define ast_pipeline_codegen_try_mark_enum_field_access pipeline_codegen_try_mark_enum_field_access
#define ast_pipeline_codegen_dep_skip_x_bootstrap_partial pipeline_codegen_dep_skip_x_bootstrap_partial
#define ast_pipeline_module_func_name_copy64 pipeline_module_func_name_copy64
#define ast_pipeline_module_func_param_name_copy32 pipeline_module_func_param_name_copy32
#define ast_pipeline_module_func_num_params_at pipeline_module_func_num_params_at
#define ast_pipeline_module_func_param_name_len_at pipeline_module_func_param_name_len_at
#define ast_pipeline_module_func_name_len_at pipeline_module_func_name_len_at
#define ast_pipeline_module_func_body_ref_at pipeline_module_func_body_ref_at
#define ast_pipeline_dep_ctx_empty_param_reset pipeline_dep_ctx_empty_param_reset
#define ast_pipeline_dep_ctx_empty_param_append pipeline_dep_ctx_empty_param_append
#define ast_pipeline_dep_ctx_empty_param_at pipeline_dep_ctx_empty_param_at
#define ast_pipeline_dep_ctx_empty_param_backup pipeline_dep_ctx_empty_param_backup
#define ast_pipeline_dep_ctx_empty_param_restore pipeline_dep_ctx_empty_param_restore
#define ast_pipeline_module_func_is_extern_at pipeline_module_func_is_extern_at
#define ast_pipeline_module_func_is_used_at pipeline_module_func_is_used_at
#define ast_pipeline_module_func_is_naked_at pipeline_module_func_is_naked_at
#define ast_pipeline_module_func_is_entry_at pipeline_module_func_is_entry_at
#define ast_pipeline_module_func_is_no_mangle_at pipeline_module_func_is_no_mangle_at
#define ast_pipeline_module_func_is_interrupt_at pipeline_module_func_is_interrupt_at
#define ast_pipeline_module_func_param_type_ref_at pipeline_module_func_param_type_ref_at
#define ast_pipeline_block_defer_body_ref pipeline_block_defer_body_ref
#define ast_pipeline_asm_resolve_whole_import_qualified_symbol_c pipeline_asm_resolve_whole_import_qualified_symbol_c
#define ast_pipeline_codegen_std_dep_link_only pipeline_codegen_std_dep_link_only

/* slim arena grow pool glue (linked from pipeline/runtime) */
extern struct ast_Expr pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Block pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Type pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Func pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);
extern void ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b);
extern void ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t);
extern void ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f);


struct ast_PipelineDepCtx {
  int32_t ndep;
  uint8_t entry_dir_buf[512];
  int32_t entry_dir_len;
  int32_t num_lib_roots;
  uint8_t path_buf[512];
  uint8_t loaded_buf[4194304];
  ssize_t loaded_len;
  uint8_t preprocess_buf[4194304];
  int32_t preprocess_len;
  int32_t use_asm_backend;
  int32_t target_arch;
  int32_t target_cpu_features;
  int32_t use_macho_o;
  int32_t use_coff_o;
  int32_t current_block_ref;
  int32_t typeck_loop_depth;
  int32_t current_func_index;
  int32_t skip_codegen_dep_0;
  int32_t entry_already_parsed;
  int32_t current_func_single_empty_param_index;
  int32_t current_func_empty_param_count;
  int32_t current_emit_empty_var_next_index;
  int32_t emit_expr_as_callee;
  struct ast_Module * current_codegen_module;
  struct ast_ASTArena * current_codegen_arena;
  int32_t current_codegen_dep_index;
  uint8_t current_codegen_prefix_mirror[64];
  int32_t current_codegen_prefix_len;
  int32_t asm_entry_module_only;
  uint8_t entry_module_import_path_mirror[64];
  int32_t entry_module_import_path_len;
  int32_t typeck_scope_region_len;
  uint8_t typeck_scope_region_label[64];
};

/* pipeline glue usage aliases */
extern int32_t ast_pipeline_arena_block_alloc(struct ast_ASTArena *a);
extern int32_t ast_pipeline_arena_block_cap(void);
extern struct ast_Block ast_pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void ast_pipeline_arena_block_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Block b);
extern int32_t ast_pipeline_arena_expr_alloc(struct ast_ASTArena *a);
extern int32_t ast_pipeline_arena_expr_cap(void);
extern struct ast_Expr ast_pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void ast_pipeline_arena_expr_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);
extern int32_t ast_pipeline_arena_func_alloc(struct ast_ASTArena *a);
extern int32_t ast_pipeline_arena_func_cap(void);
extern struct ast_Func ast_pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void ast_pipeline_arena_func_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Func f);
extern int32_t ast_pipeline_arena_type_alloc(struct ast_ASTArena *a);
extern int32_t ast_pipeline_arena_type_cap(void);
extern struct ast_Type ast_pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void ast_pipeline_arena_type_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Type t);
extern int32_t ast_pipeline_block_append_const(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                        int32_t type_ref, int32_t init_ref);
extern int32_t ast_pipeline_block_append_expr_stmt(struct ast_ASTArena *a, int32_t br, int32_t expr_ref);
extern int32_t ast_pipeline_block_append_for(struct ast_ASTArena *a, int32_t br, int32_t init_ref, int32_t cond_ref,
                                      int32_t step_ref, int32_t body_ref);
extern int32_t ast_pipeline_block_append_if(struct ast_ASTArena *a, int32_t br, int32_t cond_ref, int32_t then_ref,
                                     int32_t else_ref);
extern int32_t ast_pipeline_block_append_labeled(struct ast_ASTArena *a, int32_t br, int32_t label_len, int32_t is_goto,
                                           int32_t goto_target_len, int32_t return_expr_ref);
extern int32_t ast_pipeline_block_append_let(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                      int32_t type_ref, int32_t init_ref);
extern int32_t ast_pipeline_block_append_region(struct ast_ASTArena *a, int32_t br, uint8_t *label, int32_t label_len,
                                         int32_t body_ref);
extern int32_t ast_pipeline_block_append_stmt_order(struct ast_ASTArena *a, int32_t br, uint8_t kind, int32_t idx);
extern int32_t ast_pipeline_block_append_unsafe(struct ast_ASTArena *a, int32_t br, int32_t body_ref);
extern int32_t ast_pipeline_block_append_while(struct ast_ASTArena *a, int32_t br, int32_t cond_ref, int32_t body_ref);
extern int32_t ast_pipeline_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
extern void ast_pipeline_block_const_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t ci, uint8_t *dst);
extern int32_t ast_pipeline_block_const_name_len(struct ast_ASTArena *a, int32_t br, int32_t ci);
extern int32_t ast_pipeline_block_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
extern int32_t ast_pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);
extern void ast_pipeline_block_fill_expr_stmts_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern void ast_pipeline_block_fill_fors_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern void ast_pipeline_block_fill_ifs_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern void ast_pipeline_block_fill_stmt_order_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern void ast_pipeline_block_fill_whiles_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern int32_t ast_pipeline_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
extern int32_t ast_pipeline_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
extern int32_t ast_pipeline_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
extern int32_t ast_pipeline_block_labeled_return_expr_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern int32_t ast_pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern void ast_pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
extern int32_t ast_pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li);
extern int32_t ast_pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern int32_t ast_pipeline_block_resolve_var_type_ref(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname,
                                                 int32_t vlen);
extern int32_t ast_pipeline_block_stmt_order_idx(struct ast_ASTArena *a, int32_t br, int32_t si);
extern uint8_t ast_pipeline_block_stmt_order_kind(struct ast_ASTArena *a, int32_t br, int32_t si);
extern int32_t ast_pipeline_ctx_append_lib_root(struct ast_PipelineDepCtx *ctx, uint8_t *path, int32_t len);
extern void ast_pipeline_ctx_lib_root_copy(struct ast_PipelineDepCtx *ctx, int32_t i, uint8_t *dst, int32_t cap);
extern int32_t ast_pipeline_ctx_lib_root_count(struct ast_PipelineDepCtx *ctx);
extern int32_t ast_pipeline_ctx_lib_root_len(struct ast_PipelineDepCtx *ctx, int32_t i);
extern void ast_pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst);
extern int32_t ast_pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t ast_pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern void ast_pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_ASTArena *a);
extern void ast_pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *bytes, int32_t len);
extern void ast_pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_Module *m);
extern void ast_pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx *ctx, int32_t n);
extern int32_t ast_pipeline_expr_append_array_lit_elem(struct ast_ASTArena *a, int32_t expr_ref, int32_t elem_ref);
extern int32_t ast_pipeline_expr_append_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref);
extern int32_t ast_pipeline_expr_append_match_arm(struct ast_ASTArena *a, int32_t expr_ref, int32_t result_ref,
                                           int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant,
                                           int32_t variant_index);
extern int32_t ast_pipeline_expr_append_method_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref);
extern int32_t ast_pipeline_expr_append_struct_lit_field(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *name_bytes,
                                                  int32_t name_len, int32_t init_ref);
extern void ast_pipeline_expr_apply_call_resolve(struct ast_ASTArena *a, int32_t expr_ref, int32_t dep_ix,
                                         int32_t func_ix);
extern int32_t ast_pipeline_expr_array_lit_elem_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
extern int32_t ast_pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
extern int32_t ast_pipeline_expr_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref);
extern void ast_pipeline_expr_init_call_resolve_at_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern int32_t ast_pipeline_expr_match_arm_is_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern int32_t ast_pipeline_expr_match_arm_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern int32_t ast_pipeline_expr_match_arm_result_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern void ast_pipeline_expr_match_arm_set_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i,
                                                  int32_t is_var, int32_t variant_index);
extern void ast_pipeline_expr_match_arm_set_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v);
extern void ast_pipeline_expr_match_arm_set_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v);
extern int32_t ast_pipeline_expr_match_arm_variant_index(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern int32_t ast_pipeline_expr_match_num_arms_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_method_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
extern int32_t ast_pipeline_module_enum_alloc(struct ast_Module *m);
extern uint8_t ast_pipeline_module_enum_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t ast_pipeline_module_enum_name_len(struct ast_Module *m, int32_t idx);
extern void ast_pipeline_module_enum_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
extern int32_t ast_pipeline_module_func_alloc_slot(struct ast_Module *m);
extern int32_t ast_pipeline_module_func_body_expr_ref_at(struct ast_Module *m, int32_t fi);
extern uint8_t ast_pipeline_module_func_name_byte_at(struct ast_Module *m, int32_t fi, int32_t i);
extern int32_t ast_pipeline_module_func_name_equal_at(struct ast_Module *m, int32_t fi, uint8_t *name, int32_t name_len);
extern int32_t ast_pipeline_module_func_num_generic_params_at(struct ast_Module *m, int32_t fi);
extern int32_t ast_pipeline_module_func_ref_at(struct ast_Module *m, int32_t func_index);
extern void ast_pipeline_module_func_ref_set(struct ast_Module *m, int32_t fi, int32_t func_ref);
extern int32_t ast_pipeline_module_func_return_type_at(struct ast_Module *m, int32_t fi);
extern void ast_pipeline_module_func_set_body_expr_ref(struct ast_Module *m, int32_t fi, int32_t body_expr_ref);
extern void ast_pipeline_module_func_set_body_ref(struct ast_Module *m, int32_t fi, int32_t body_ref);
extern void ast_pipeline_module_func_set_is_extern(struct ast_Module *m, int32_t fi, int32_t is_extern);
extern void ast_pipeline_module_func_set_num_params(struct ast_Module *m, int32_t fi, int32_t n);
extern void ast_pipeline_module_func_set_return_type(struct ast_Module *m, int32_t fi, int32_t type_ref);
extern int32_t ast_pipeline_module_import_alloc(struct ast_Module *m);
extern int32_t ast_pipeline_module_import_append_select_name(struct ast_Module *m, int32_t idx, uint8_t *bytes,
                                                      int32_t len);
extern uint8_t ast_pipeline_module_import_binding_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t ast_pipeline_module_import_binding_name_len(struct ast_Module *m, int32_t idx);
extern int32_t ast_pipeline_module_import_kind_at(struct ast_Module *m, int32_t idx);
extern uint8_t ast_pipeline_module_import_path_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern void ast_pipeline_module_import_path_copy(struct ast_Module *m, int32_t idx, uint8_t *dst, int32_t dst_cap);
extern int32_t ast_pipeline_module_import_path_len(struct ast_Module *m, int32_t idx);
extern int32_t ast_pipeline_module_import_select_count_at(struct ast_Module *m, int32_t idx);
extern uint8_t ast_pipeline_module_import_select_name_byte_at(struct ast_Module *m, int32_t idx, int32_t sel, int32_t off);
extern int32_t ast_pipeline_module_import_select_name_len(struct ast_Module *m, int32_t idx, int32_t sel);
extern void ast_pipeline_module_import_set_binding_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
extern void ast_pipeline_module_import_set_kind(struct ast_Module *m, int32_t idx, int32_t kind);
extern void ast_pipeline_module_import_set_path(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
extern void ast_pipeline_module_import_set_select_count(struct ast_Module *m, int32_t idx, int32_t n);
extern int32_t ast_pipeline_module_struct_layout_alloc(struct ast_Module *m);
extern int32_t ast_pipeline_module_struct_layout_allow_padding_at(struct ast_Module *m, int32_t idx);
extern void ast_pipeline_module_struct_layout_field_name_into(struct ast_Module *m, int32_t li, int32_t j, uint8_t *out64);
extern int32_t ast_pipeline_module_struct_layout_field_name_len(struct ast_Module *m, int32_t li, int32_t j);
extern int32_t ast_pipeline_module_struct_layout_field_offset_at(struct ast_Module *m, int32_t li, int32_t j);
extern int32_t ast_pipeline_module_struct_layout_field_type_ref(struct ast_Module *m, int32_t li, int32_t j);
extern uint8_t ast_pipeline_module_struct_layout_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern void ast_pipeline_module_struct_layout_name_into(struct ast_Module *m, int32_t idx, uint8_t *out64);
extern int32_t ast_pipeline_module_struct_layout_name_len(struct ast_Module *m, int32_t idx);
extern int32_t ast_pipeline_module_struct_layout_num_fields(struct ast_Module *m, int32_t idx);
extern void ast_pipeline_module_struct_layout_reset_slot(struct ast_Module *m, int32_t idx);
extern void ast_pipeline_module_struct_layout_set_allow_padding(struct ast_Module *m, int32_t idx, int32_t v);
extern void ast_pipeline_module_struct_layout_set_field(struct ast_Module *m, int32_t li, int32_t j, uint8_t *fname_bytes,
                                                 int32_t fname_len, int32_t ftype_ref, int32_t foff);
extern void ast_pipeline_module_struct_layout_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
extern void ast_pipeline_module_struct_layout_set_num_fields(struct ast_Module *m, int32_t idx, int32_t nf);
extern int32_t ast_pipeline_module_top_level_let_alloc(struct ast_Module *m);
extern int32_t ast_pipeline_module_top_level_let_init_ref(struct ast_Module *m, int32_t idx);
extern int32_t ast_pipeline_module_top_level_let_is_const(struct ast_Module *m, int32_t idx);
extern uint8_t ast_pipeline_module_top_level_let_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t ast_pipeline_module_top_level_let_name_len(struct ast_Module *m, int32_t idx);
extern void ast_pipeline_module_top_level_let_set(struct ast_Module *m, int32_t idx, uint8_t *name, int32_t name_len,
                                            int32_t type_ref, int32_t init_ref, int32_t is_const);
extern int32_t ast_pipeline_module_top_level_let_type_ref(struct ast_Module *m, int32_t idx);
extern int32_t ast_pipeline_onefunc_append_for(uint8_t *out, int32_t init_ref, int32_t cond_ref, int32_t step_ref,
                                        int32_t body_ref);
extern int32_t ast_pipeline_onefunc_append_let(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val, int32_t init_ref,
                                        int32_t type_ref);
extern int32_t ast_pipeline_onefunc_append_while(uint8_t *out, int32_t cond_ref, int32_t body_ref);
extern int32_t ast_pipeline_onefunc_const_init_val(uint8_t *out, int32_t i);
extern void ast_pipeline_onefunc_const_name_copy64(uint8_t *out, int32_t i, uint8_t *dst);
extern int32_t ast_pipeline_onefunc_const_name_len(uint8_t *out, int32_t i);
extern void ast_pipeline_onefunc_copy_sidecar(uint8_t *dst, uint8_t *src);
extern int32_t ast_pipeline_onefunc_let_init_ref(uint8_t *out, int32_t i);
extern int32_t ast_pipeline_onefunc_let_init_val(uint8_t *out, int32_t i);
extern void ast_pipeline_onefunc_let_name_copy64(uint8_t *out, int32_t i, uint8_t *dst);
extern int32_t ast_pipeline_onefunc_let_name_len(uint8_t *out, int32_t i);
extern int32_t ast_pipeline_onefunc_let_type_ref(uint8_t *out, int32_t i);
extern int32_t ast_pipeline_onefunc_num_consts(uint8_t *out);
extern int32_t ast_pipeline_onefunc_num_fors(uint8_t *out);
extern int32_t ast_pipeline_onefunc_num_lets(uint8_t *out);
extern int32_t ast_pipeline_onefunc_num_whiles(uint8_t *out);
#define pipeline_arena_block_alloc ast_pipeline_arena_block_alloc
#define pipeline_arena_block_cap ast_pipeline_arena_block_cap
#define pipeline_arena_block_get_copy ast_pipeline_arena_block_get_copy
#define pipeline_arena_block_set_copy ast_pipeline_arena_block_set_copy
#define pipeline_arena_expr_alloc ast_pipeline_arena_expr_alloc
#define pipeline_arena_expr_cap ast_pipeline_arena_expr_cap
#define pipeline_arena_expr_get_copy ast_pipeline_arena_expr_get_copy
#define pipeline_arena_expr_set_copy ast_pipeline_arena_expr_set_copy
#define pipeline_arena_func_alloc ast_pipeline_arena_func_alloc
#define pipeline_arena_func_cap ast_pipeline_arena_func_cap
#define pipeline_arena_func_get_copy ast_pipeline_arena_func_get_copy
#define pipeline_arena_func_set_copy ast_pipeline_arena_func_set_copy
#define pipeline_arena_type_alloc ast_pipeline_arena_type_alloc
#define pipeline_arena_type_cap ast_pipeline_arena_type_cap
#define pipeline_arena_type_get_copy ast_pipeline_arena_type_get_copy
#define pipeline_arena_type_set_copy ast_pipeline_arena_type_set_copy
#define pipeline_block_append_const ast_pipeline_block_append_const
#define pipeline_block_append_expr_stmt ast_pipeline_block_append_expr_stmt
#define pipeline_block_append_for ast_pipeline_block_append_for
#define pipeline_block_append_if ast_pipeline_block_append_if
#define pipeline_block_append_labeled ast_pipeline_block_append_labeled
#define pipeline_block_append_let ast_pipeline_block_append_let
#define pipeline_block_append_region ast_pipeline_block_append_region
#define pipeline_block_append_stmt_order ast_pipeline_block_append_stmt_order
#define pipeline_block_append_unsafe ast_pipeline_block_append_unsafe
#define pipeline_block_append_while ast_pipeline_block_append_while
#define pipeline_block_const_init_ref ast_pipeline_block_const_init_ref
#define pipeline_block_const_name_copy64 ast_pipeline_block_const_name_copy64
#define pipeline_block_const_name_len ast_pipeline_block_const_name_len
#define pipeline_block_const_type_ref ast_pipeline_block_const_type_ref
#define pipeline_block_expr_stmt_ref ast_pipeline_block_expr_stmt_ref
#define pipeline_block_fill_expr_stmts_from_onefunc ast_pipeline_block_fill_expr_stmts_from_onefunc
#define pipeline_block_fill_fors_from_onefunc ast_pipeline_block_fill_fors_from_onefunc
#define pipeline_block_fill_ifs_from_onefunc ast_pipeline_block_fill_ifs_from_onefunc
#define pipeline_block_fill_stmt_order_from_onefunc ast_pipeline_block_fill_stmt_order_from_onefunc
#define pipeline_block_fill_whiles_from_onefunc ast_pipeline_block_fill_whiles_from_onefunc
#define pipeline_block_if_cond_ref ast_pipeline_block_if_cond_ref
#define pipeline_block_if_else_body_ref ast_pipeline_block_if_else_body_ref
#define pipeline_block_if_then_body_ref ast_pipeline_block_if_then_body_ref
#define pipeline_block_labeled_return_expr_ref ast_pipeline_block_labeled_return_expr_ref
#define pipeline_block_let_init_ref ast_pipeline_block_let_init_ref
#define pipeline_block_let_name_copy64 ast_pipeline_block_let_name_copy64
#define pipeline_block_let_name_len ast_pipeline_block_let_name_len
#define pipeline_block_let_type_ref ast_pipeline_block_let_type_ref
#define pipeline_block_resolve_var_type_ref ast_pipeline_block_resolve_var_type_ref
#define pipeline_block_stmt_order_idx ast_pipeline_block_stmt_order_idx
#define pipeline_block_stmt_order_kind ast_pipeline_block_stmt_order_kind
#define pipeline_ctx_append_lib_root ast_pipeline_ctx_append_lib_root
#define pipeline_ctx_lib_root_copy ast_pipeline_ctx_lib_root_copy
#define pipeline_ctx_lib_root_count ast_pipeline_ctx_lib_root_count
#define pipeline_ctx_lib_root_len ast_pipeline_ctx_lib_root_len
#define pipeline_dep_ctx_import_path_copy64 ast_pipeline_dep_ctx_import_path_copy64
#define pipeline_dep_ctx_import_path_len ast_pipeline_dep_ctx_import_path_len
#define pipeline_dep_ctx_ndep ast_pipeline_dep_ctx_ndep
#define pipeline_dep_ctx_set_arena ast_pipeline_dep_ctx_set_arena
#define pipeline_dep_ctx_set_import_path ast_pipeline_dep_ctx_set_import_path
#define pipeline_dep_ctx_set_module ast_pipeline_dep_ctx_set_module
#define pipeline_dep_ctx_set_ndep ast_pipeline_dep_ctx_set_ndep
#define pipeline_expr_append_array_lit_elem ast_pipeline_expr_append_array_lit_elem
#define pipeline_expr_append_call_arg ast_pipeline_expr_append_call_arg
#define pipeline_expr_append_match_arm ast_pipeline_expr_append_match_arm
#define pipeline_expr_append_method_call_arg ast_pipeline_expr_append_method_call_arg
#define pipeline_expr_append_struct_lit_field ast_pipeline_expr_append_struct_lit_field
#define pipeline_expr_apply_call_resolve ast_pipeline_expr_apply_call_resolve
#define pipeline_expr_array_lit_elem_ref ast_pipeline_expr_array_lit_elem_ref
#define pipeline_expr_array_lit_num_elems_at ast_pipeline_expr_array_lit_num_elems_at
#define pipeline_expr_call_arg_ref ast_pipeline_expr_call_arg_ref
#define pipeline_expr_call_num_args_at ast_pipeline_expr_call_num_args_at
#define pipeline_expr_init_call_resolve_at_ref ast_pipeline_expr_init_call_resolve_at_ref
#define pipeline_expr_match_arm_is_enum_variant ast_pipeline_expr_match_arm_is_enum_variant
#define pipeline_expr_match_arm_is_wildcard ast_pipeline_expr_match_arm_is_wildcard
#define pipeline_expr_match_arm_lit_val ast_pipeline_expr_match_arm_lit_val
#define pipeline_expr_match_arm_result_ref ast_pipeline_expr_match_arm_result_ref
#define pipeline_expr_match_arm_set_enum_variant ast_pipeline_expr_match_arm_set_enum_variant
#define pipeline_expr_match_arm_set_lit_val ast_pipeline_expr_match_arm_set_lit_val
#define pipeline_expr_match_arm_set_wildcard ast_pipeline_expr_match_arm_set_wildcard
#define pipeline_expr_match_arm_variant_index ast_pipeline_expr_match_arm_variant_index
#define pipeline_expr_match_num_arms_at ast_pipeline_expr_match_num_arms_at
#define pipeline_expr_method_call_arg_ref ast_pipeline_expr_method_call_arg_ref
#define pipeline_module_enum_alloc ast_pipeline_module_enum_alloc
#define pipeline_module_enum_name_byte_at ast_pipeline_module_enum_name_byte_at
#define pipeline_module_enum_name_len ast_pipeline_module_enum_name_len
#define pipeline_module_enum_set_name ast_pipeline_module_enum_set_name
#define pipeline_module_func_alloc_slot ast_pipeline_module_func_alloc_slot
#define pipeline_module_func_body_expr_ref_at ast_pipeline_module_func_body_expr_ref_at
#define pipeline_module_func_name_byte_at ast_pipeline_module_func_name_byte_at
#define pipeline_module_func_name_equal_at ast_pipeline_module_func_name_equal_at
#define pipeline_module_func_num_generic_params_at ast_pipeline_module_func_num_generic_params_at
#define pipeline_module_func_ref_at ast_pipeline_module_func_ref_at
#define pipeline_module_func_ref_set ast_pipeline_module_func_ref_set
#define pipeline_module_func_return_type_at ast_pipeline_module_func_return_type_at
#define pipeline_module_func_set_body_expr_ref ast_pipeline_module_func_set_body_expr_ref
#define pipeline_module_func_set_body_ref ast_pipeline_module_func_set_body_ref
#define pipeline_module_func_set_is_extern ast_pipeline_module_func_set_is_extern
#define pipeline_module_func_set_num_params ast_pipeline_module_func_set_num_params
#define pipeline_module_func_set_return_type ast_pipeline_module_func_set_return_type
#define pipeline_module_import_alloc ast_pipeline_module_import_alloc
#define pipeline_module_import_append_select_name ast_pipeline_module_import_append_select_name
#define pipeline_module_import_binding_name_byte_at ast_pipeline_module_import_binding_name_byte_at
#define pipeline_module_import_binding_name_len ast_pipeline_module_import_binding_name_len
#define pipeline_module_import_kind_at ast_pipeline_module_import_kind_at
#define pipeline_module_import_path_byte_at ast_pipeline_module_import_path_byte_at
#define pipeline_module_import_path_copy ast_pipeline_module_import_path_copy
#define pipeline_module_import_path_len ast_pipeline_module_import_path_len
#define pipeline_module_import_select_count_at ast_pipeline_module_import_select_count_at
#define pipeline_module_import_select_name_byte_at ast_pipeline_module_import_select_name_byte_at
#define pipeline_module_import_select_name_len ast_pipeline_module_import_select_name_len
#define pipeline_module_import_set_binding_name ast_pipeline_module_import_set_binding_name
#define pipeline_module_import_set_kind ast_pipeline_module_import_set_kind
#define pipeline_module_import_set_path ast_pipeline_module_import_set_path
#define pipeline_module_import_set_select_count ast_pipeline_module_import_set_select_count
#define pipeline_module_struct_layout_alloc ast_pipeline_module_struct_layout_alloc
#define pipeline_module_struct_layout_allow_padding_at ast_pipeline_module_struct_layout_allow_padding_at
#define pipeline_module_struct_layout_field_name_into ast_pipeline_module_struct_layout_field_name_into
#define pipeline_module_struct_layout_field_name_len ast_pipeline_module_struct_layout_field_name_len
#define pipeline_module_struct_layout_field_offset_at ast_pipeline_module_struct_layout_field_offset_at
#define pipeline_module_struct_layout_field_type_ref ast_pipeline_module_struct_layout_field_type_ref
#define pipeline_module_struct_layout_name_byte_at ast_pipeline_module_struct_layout_name_byte_at
#define pipeline_module_struct_layout_name_into ast_pipeline_module_struct_layout_name_into
#define pipeline_module_struct_layout_name_len ast_pipeline_module_struct_layout_name_len
#define pipeline_module_struct_layout_num_fields ast_pipeline_module_struct_layout_num_fields
#define pipeline_module_struct_layout_reset_slot ast_pipeline_module_struct_layout_reset_slot
#define pipeline_module_struct_layout_set_allow_padding ast_pipeline_module_struct_layout_set_allow_padding
#define pipeline_module_struct_layout_set_field ast_pipeline_module_struct_layout_set_field
#define pipeline_module_struct_layout_set_name ast_pipeline_module_struct_layout_set_name
#define pipeline_module_struct_layout_set_num_fields ast_pipeline_module_struct_layout_set_num_fields
#define pipeline_module_top_level_let_alloc ast_pipeline_module_top_level_let_alloc
#define pipeline_module_top_level_let_init_ref ast_pipeline_module_top_level_let_init_ref
#define pipeline_module_top_level_let_is_const ast_pipeline_module_top_level_let_is_const
#define pipeline_module_top_level_let_name_byte_at ast_pipeline_module_top_level_let_name_byte_at
#define pipeline_module_top_level_let_name_len ast_pipeline_module_top_level_let_name_len
#define pipeline_module_top_level_let_set ast_pipeline_module_top_level_let_set
#define pipeline_module_top_level_let_type_ref ast_pipeline_module_top_level_let_type_ref
#define pipeline_onefunc_append_for ast_pipeline_onefunc_append_for
#define pipeline_onefunc_append_let ast_pipeline_onefunc_append_let
#define pipeline_onefunc_append_while ast_pipeline_onefunc_append_while
#define pipeline_onefunc_const_init_val ast_pipeline_onefunc_const_init_val
#define pipeline_onefunc_const_name_copy64 ast_pipeline_onefunc_const_name_copy64
#define pipeline_onefunc_const_name_len ast_pipeline_onefunc_const_name_len
#define pipeline_onefunc_copy_sidecar ast_pipeline_onefunc_copy_sidecar
#define pipeline_onefunc_let_init_ref ast_pipeline_onefunc_let_init_ref
#define pipeline_onefunc_let_init_val ast_pipeline_onefunc_let_init_val
#define pipeline_onefunc_let_name_copy64 ast_pipeline_onefunc_let_name_copy64
#define pipeline_onefunc_let_name_len ast_pipeline_onefunc_let_name_len
#define pipeline_onefunc_let_type_ref ast_pipeline_onefunc_let_type_ref
#define pipeline_onefunc_num_consts ast_pipeline_onefunc_num_consts
#define pipeline_onefunc_num_fors ast_pipeline_onefunc_num_fors
#define pipeline_onefunc_num_lets ast_pipeline_onefunc_num_lets
#define pipeline_onefunc_num_whiles ast_pipeline_onefunc_num_whiles

struct ast_Type;
struct ast_Expr;
struct ast_ConstDecl;
struct ast_LetDecl;
struct ast_WhileLoop;
struct ast_ForLoop;
struct ast_IfStmt;
struct ast_StmtOrderItem;
struct ast_LabeledStmt;
struct ast_Block;
struct ast_Param;
struct ast_Func;
struct ast_StructLayout;
struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;
extern void ast_ast_pool_block_on_alloc(struct ast_ASTArena * arena, int32_t block_ref);
extern int32_t pipeline_arena_type_alloc(struct ast_ASTArena * arena);
extern int32_t pipeline_arena_expr_alloc(struct ast_ASTArena * arena);
extern int32_t pipeline_arena_block_alloc(struct ast_ASTArena * arena);
extern int32_t pipeline_arena_func_alloc(struct ast_ASTArena * arena);
extern struct ast_Type pipeline_arena_type_get_copy(struct ast_ASTArena * arena, int32_t ref);
extern void pipeline_arena_type_set_copy(struct ast_ASTArena * arena, int32_t ref, struct ast_Type t);
extern struct ast_Expr pipeline_arena_expr_get_copy(struct ast_ASTArena * arena, int32_t ref);
extern void pipeline_arena_expr_set_copy(struct ast_ASTArena * arena, int32_t ref, struct ast_Expr e);
extern struct ast_Block pipeline_arena_block_get_copy(struct ast_ASTArena * arena, int32_t ref);
extern void pipeline_arena_block_set_copy(struct ast_ASTArena * arena, int32_t ref, struct ast_Block b);
extern struct ast_Func pipeline_arena_func_get_copy(struct ast_ASTArena * arena, int32_t ref);
extern void pipeline_arena_func_set_copy(struct ast_ASTArena * arena, int32_t ref, struct ast_Func f);
extern int32_t pipeline_arena_type_cap(void);
extern int32_t pipeline_arena_expr_cap(void);
extern int32_t pipeline_arena_block_cap(void);
extern int32_t pipeline_arena_func_cap(void);
extern int32_t pipeline_module_import_alloc(struct ast_Module * module);
extern void pipeline_module_import_set_path(struct ast_Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern int32_t pipeline_module_import_path_len(struct ast_Module * module, int32_t idx);
extern void pipeline_module_import_path_copy(struct ast_Module * module, int32_t idx, uint8_t * dst, int32_t dst_cap);
extern uint8_t pipeline_module_import_path_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern void pipeline_module_import_set_kind(struct ast_Module * module, int32_t idx, int32_t kind);
extern int32_t pipeline_module_import_kind_at(struct ast_Module * module, int32_t idx);
extern void pipeline_module_import_set_binding_name(struct ast_Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern int32_t pipeline_module_import_binding_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t pipeline_module_import_binding_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern void pipeline_module_import_set_select_count(struct ast_Module * module, int32_t idx, int32_t n);
extern int32_t pipeline_module_import_append_select_name(struct ast_Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern int32_t pipeline_module_import_select_count_at(struct ast_Module * module, int32_t idx);
extern void pipeline_module_import_set_select_name(struct ast_Module * module, int32_t idx, int32_t sel, uint8_t * bytes, int32_t len);
extern int32_t pipeline_module_import_select_name_len(struct ast_Module * module, int32_t idx, int32_t sel);
extern uint8_t pipeline_module_import_select_name_byte_at(struct ast_Module * module, int32_t idx, int32_t sel, int32_t off);
extern int32_t pipeline_module_struct_layout_alloc(struct ast_Module * module);
extern void pipeline_module_struct_layout_reset_slot(struct ast_Module * module, int32_t idx);
extern void pipeline_module_struct_layout_set_name(struct ast_Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern void pipeline_module_struct_layout_set_field(struct ast_Module * module, int32_t li, int32_t j, uint8_t * fname_bytes, int32_t fname_len, int32_t ftype_ref, int32_t foff);
extern int32_t pipeline_module_struct_layout_name_len(struct ast_Module * module, int32_t idx);
extern void pipeline_module_struct_layout_name_into(struct ast_Module * module, int32_t idx, uint8_t * out64);
extern void pipeline_module_struct_layout_field_name_into(struct ast_Module * module, int32_t li, int32_t j, uint8_t * out64);
extern int32_t pipeline_module_struct_layout_num_fields(struct ast_Module * module, int32_t idx);
extern void pipeline_module_struct_layout_set_num_fields(struct ast_Module * module, int32_t idx, int32_t nf);
extern int32_t pipeline_module_struct_layout_field_type_ref(struct ast_Module * module, int32_t li, int32_t j);
extern int32_t pipeline_module_struct_layout_field_name_len(struct ast_Module * module, int32_t li, int32_t j);
extern int32_t pipeline_module_top_level_let_alloc(struct ast_Module * module);
extern void pipeline_module_top_level_let_set(struct ast_Module * module, int32_t idx, uint8_t * name, int32_t name_len, int32_t type_ref, int32_t init_ref, int32_t is_const);
extern int32_t pipeline_module_top_level_let_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t pipeline_module_top_level_let_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t pipeline_module_top_level_let_type_ref(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_top_level_let_init_ref(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_top_level_let_is_const(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_enum_alloc(struct ast_Module * module);
extern void pipeline_module_enum_set_name(struct ast_Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern int32_t pipeline_module_enum_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t pipeline_module_enum_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern uint8_t pipeline_module_struct_layout_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern void pipeline_module_struct_layout_set_allow_padding(struct ast_Module * module, int32_t idx, int32_t v);
extern int32_t pipeline_module_struct_layout_allow_padding_at(struct ast_Module * module, int32_t idx);
extern void pipeline_module_struct_layout_set_soa(struct ast_Module * module, int32_t idx, int32_t v);
extern void pipeline_module_struct_layout_set_packed(struct ast_Module * module, int32_t idx, int32_t v);
extern int32_t pipeline_module_struct_layout_packed_at(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_struct_layout_soa_at(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_struct_layout_field_offset_at(struct ast_Module * module, int32_t li, int32_t j);
extern void pipeline_module_struct_layout_set_field_offset(struct ast_Module * module, int32_t li, int32_t j, int32_t foff);
extern int32_t pipeline_onefunc_append_const_name(uint8_t * out, uint8_t * name, int32_t name_len, int32_t init_val);
extern int32_t pipeline_onefunc_const_name_len(uint8_t * out, int32_t i);
extern uint8_t pipeline_onefunc_const_name_byte_at(uint8_t * out, int32_t i, int32_t off);
extern int32_t pipeline_onefunc_const_init_val(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_num_consts(uint8_t * out);
extern int32_t pipeline_onefunc_append_let(uint8_t * out, uint8_t * name, int32_t name_len, int32_t init_val, int32_t init_ref, int32_t type_ref);
extern int32_t pipeline_onefunc_let_name_len(uint8_t * out, int32_t i);
extern uint8_t pipeline_onefunc_let_name_byte_at(uint8_t * out, int32_t i, int32_t off);
extern int32_t pipeline_onefunc_let_init_val(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_let_init_ref(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_let_type_ref(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_num_lets(uint8_t * out);
extern void pipeline_onefunc_const_name_copy64(uint8_t * out, int32_t i, uint8_t * dst);
extern void pipeline_onefunc_let_name_copy64(uint8_t * out, int32_t i, uint8_t * dst);
extern void pipeline_onefunc_copy_sidecar(uint8_t * dst, uint8_t * src);
extern void ast_ast_pool_onefunc_reset(uint8_t * out);
extern int32_t pipeline_block_append_const(struct ast_ASTArena * arena, int32_t br, uint8_t * name, int32_t name_len, int32_t type_ref, int32_t init_ref);
extern int32_t pipeline_block_append_let(struct ast_ASTArena * arena, int32_t br, uint8_t * name, int32_t name_len, int32_t type_ref, int32_t init_ref);
extern int32_t pipeline_block_append_if(struct ast_ASTArena * arena, int32_t br, int32_t cond_ref, int32_t then_ref, int32_t else_ref);
extern int32_t pipeline_block_append_region(struct ast_ASTArena * arena, int32_t br, uint8_t * label, int32_t label_len, int32_t body_ref);
extern int32_t pipeline_block_append_unsafe(struct ast_ASTArena * arena, int32_t br, int32_t body_ref);
extern int32_t pipeline_block_region_body_ref(struct ast_ASTArena * arena, int32_t br, int32_t ri);
extern int32_t pipeline_block_append_expr_stmt(struct ast_ASTArena * arena, int32_t br, int32_t expr_ref);
extern int32_t pipeline_block_append_stmt_order(struct ast_ASTArena * arena, int32_t br, uint8_t kind, int32_t idx);
extern int32_t pipeline_block_const_init_ref(struct ast_ASTArena * arena, int32_t br, int32_t ci);
extern int32_t pipeline_block_const_type_ref(struct ast_ASTArena * arena, int32_t br, int32_t ci);
extern int32_t pipeline_block_const_name_len(struct ast_ASTArena * arena, int32_t br, int32_t ci);
extern void pipeline_block_const_name_copy64(struct ast_ASTArena * arena, int32_t br, int32_t ci, uint8_t * dst);
extern int32_t pipeline_block_let_init_ref(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern int32_t pipeline_block_let_type_ref(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern int32_t pipeline_block_let_name_len(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern void pipeline_block_let_name_copy64(struct ast_ASTArena * arena, int32_t br, int32_t li, uint8_t * dst);
extern int32_t pipeline_block_expr_stmt_ref(struct ast_ASTArena * arena, int32_t br, int32_t ei);
extern uint8_t pipeline_block_stmt_order_kind(struct ast_ASTArena * arena, int32_t br, int32_t si);
extern int32_t pipeline_block_stmt_order_idx(struct ast_ASTArena * arena, int32_t br, int32_t si);
extern int32_t pipeline_block_if_cond_ref(struct ast_ASTArena * arena, int32_t br, int32_t ii);
extern int32_t pipeline_block_if_then_body_ref(struct ast_ASTArena * arena, int32_t br, int32_t ii);
extern int32_t pipeline_block_if_else_body_ref(struct ast_ASTArena * arena, int32_t br, int32_t ii);
extern int32_t pipeline_block_resolve_var_type_ref(struct ast_ASTArena * arena, int32_t block_ref, uint8_t * vname, int32_t vlen);
extern void pipeline_block_fill_ifs_from_onefunc(struct ast_ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern void pipeline_block_fill_stmt_order_from_onefunc(struct ast_ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern void pipeline_block_fill_expr_stmts_from_onefunc(struct ast_ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern int32_t pipeline_block_append_while(struct ast_ASTArena * arena, int32_t br, int32_t cond_ref, int32_t body_ref);
extern int32_t pipeline_block_append_for(struct ast_ASTArena * arena, int32_t br, int32_t init_ref, int32_t cond_ref, int32_t step_ref, int32_t body_ref);
extern int32_t pipeline_block_while_cond_ref(struct ast_ASTArena * arena, int32_t br, int32_t wi);
extern int32_t pipeline_block_while_body_ref(struct ast_ASTArena * arena, int32_t br, int32_t wi);
extern int32_t pipeline_block_for_init_ref(struct ast_ASTArena * arena, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_cond_ref(struct ast_ASTArena * arena, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_step_ref(struct ast_ASTArena * arena, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_body_ref(struct ast_ASTArena * arena, int32_t br, int32_t fi);
extern void pipeline_block_fill_whiles_from_onefunc(struct ast_ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern void pipeline_block_fill_fors_from_onefunc(struct ast_ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern int32_t pipeline_block_append_labeled(struct ast_ASTArena * arena, int32_t br, int32_t label_len, int32_t is_goto, int32_t goto_target_len, int32_t return_expr_ref);
extern int32_t pipeline_block_labeled_return_expr_ref(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern int32_t pipeline_onefunc_append_while(uint8_t * out, int32_t cond_ref, int32_t body_ref);
extern int32_t pipeline_onefunc_while_cond_ref(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_while_body_ref(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_num_whiles(uint8_t * out);
extern int32_t pipeline_onefunc_append_for(uint8_t * out, int32_t init_ref, int32_t cond_ref, int32_t step_ref, int32_t body_ref);
extern int32_t pipeline_onefunc_for_init_ref(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_for_cond_ref(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_for_step_ref(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_for_body_ref(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_num_fors(uint8_t * out);
extern void pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx * ctx, int32_t idx, struct ast_Module * m);
extern void pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx * ctx, int32_t idx, struct ast_ASTArena * a);
extern struct ast_Module * pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern struct ast_ASTArena * pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern void pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * bytes, int32_t len);
extern int32_t pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern uint8_t pipeline_dep_ctx_import_path_byte_at(struct ast_PipelineDepCtx * ctx, int32_t idx, int32_t off);
extern void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * dst);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx * ctx);
extern void pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx * ctx, int32_t n);
extern int32_t pipeline_ctx_append_lib_root(struct ast_PipelineDepCtx * ctx, uint8_t * path, int32_t len);
extern int32_t pipeline_ctx_lib_root_count(struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_ctx_lib_root_len(struct ast_PipelineDepCtx * ctx, int32_t i);
extern void pipeline_ctx_lib_root_copy(struct ast_PipelineDepCtx * ctx, int32_t i, uint8_t * dst, int32_t cap);
extern int32_t pipeline_module_func_alloc_slot(struct ast_Module * module);
extern int32_t pipeline_module_func_ref_at(struct ast_Module * module, int32_t func_index);
extern void pipeline_module_func_ref_set(struct ast_Module * module, int32_t func_index, int32_t func_ref);
extern void pipeline_module_func_set_return_type(struct ast_Module * module, int32_t fi, int32_t type_ref);
extern void pipeline_module_func_set_body_ref(struct ast_Module * module, int32_t fi, int32_t body_ref);
extern void pipeline_module_func_set_body_expr_ref(struct ast_Module * module, int32_t fi, int32_t body_expr_ref);
extern void pipeline_module_func_set_is_extern(struct ast_Module * module, int32_t fi, int32_t is_extern);
extern void pipeline_module_func_set_is_variadic(struct ast_Module * module, int32_t fi, int32_t is_variadic);
extern int32_t pipeline_module_func_is_variadic_at(struct ast_Module * module, int32_t fi);
extern void pipeline_module_func_set_num_params(struct ast_Module * module, int32_t fi, int32_t n);
extern void pipeline_module_func_set_num_generic_params(struct ast_Module * module, int32_t fi, int32_t n);
extern int32_t pipeline_module_func_return_type_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_num_generic_params_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_name_equal_at(struct ast_Module * module, int32_t fi, uint8_t * name, int32_t name_len);
extern uint8_t pipeline_module_func_name_byte_at(struct ast_Module * module, int32_t fi, int32_t i);
extern int32_t pipeline_module_func_body_expr_ref_at(struct ast_Module * module, int32_t fi);
extern int ast_ref_is_null(int32_t ref);
extern int32_t ast_ast_placeholder(void);
extern void ast_expr_layout_prime_call_resolved(void);
extern void ast_func_layout_prime_generic_params(void);
extern void ast_ast_arena_init(struct ast_ASTArena * arena);
extern int32_t ast_ast_arena_type_alloc(struct ast_ASTArena * arena);
extern int32_t ast_ast_arena_expr_alloc(struct ast_ASTArena * arena);
extern int32_t ast_ast_arena_block_alloc(struct ast_ASTArena * arena);
extern struct ast_Type ast_ast_arena_type_get(struct ast_ASTArena * arena, int32_t ref);
extern void ast_ast_arena_type_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Type t);
extern void ast_expr_init_match_enum(struct ast_Expr * e);
extern int32_t pipeline_expr_append_call_arg(struct ast_ASTArena * arena, int32_t expr_ref, int32_t arg_ref);
extern int32_t pipeline_expr_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_call_num_args_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_num_type_args_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_append_method_call_arg(struct ast_ASTArena * arena, int32_t expr_ref, int32_t arg_ref);
extern int32_t pipeline_expr_method_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_append_match_arm(struct ast_ASTArena * arena, int32_t expr_ref, int32_t result_ref, int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant, int32_t variant_index);
extern int32_t pipeline_expr_match_num_arms_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_match_arm_result_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_is_wildcard(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_lit_val(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_variant_index(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern void pipeline_expr_match_arm_set_wildcard(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i, int32_t v);
extern void pipeline_expr_match_arm_set_lit_val(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i, int32_t v);
extern void pipeline_expr_match_arm_set_enum_variant(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i, int32_t is_var, int32_t variant_index);
extern int32_t pipeline_expr_append_struct_lit_field(struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * name_bytes, int32_t name_len, int32_t init_ref);
extern int32_t pipeline_expr_append_array_lit_elem(struct ast_ASTArena * arena, int32_t expr_ref, int32_t elem_ref);
extern int32_t pipeline_expr_array_lit_elem_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern void pipeline_expr_init_call_resolve_at_ref(struct ast_ASTArena * arena, int32_t expr_ref);
extern void pipeline_expr_apply_call_resolve(struct ast_ASTArena * arena, int32_t call_expr_ref, int32_t dep_ix, int32_t func_ix);
extern void ast_expr_init_call_resolve(struct ast_ASTArena * arena, int32_t expr_ref);
extern void ast_ast_expr_apply_call_resolve(struct ast_ASTArena * arena, int32_t call_expr_ref, int32_t dep_ix, int32_t func_ix);
extern struct ast_Expr ast_ast_arena_expr_get(struct ast_ASTArena * arena, int32_t ref);
extern void ast_ast_arena_expr_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Expr e);
extern struct ast_Block ast_ast_arena_block_get(struct ast_ASTArena * arena, int32_t ref);
extern int ast_ast_name_bytes_equal(uint8_t * a_nm, int32_t a_len, uint8_t * b_nm, int32_t b_len);
extern int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena * a, int32_t body_ref);
extern int implicit_tail_expr_disallowed_by_glue(struct ast_ASTArena * a, int32_t expr_ref);
extern int ast_ast_expr_disallows_implicit_tail(struct ast_ASTArena * a, int32_t expr_ref);
extern int32_t ast_ast_block_num_consts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_lets(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_loops(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_for_loops(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_regions(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_region_body_ref(struct ast_ASTArena * a, int32_t br, int32_t ri);
extern int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena * a, int32_t br);
extern uint8_t ast_ast_block_stmt_order_kind(struct ast_ASTArena * a, int32_t br, int32_t si);
extern int32_t ast_ast_block_stmt_order_idx(struct ast_ASTArena * a, int32_t br, int32_t si);
extern int32_t ast_ast_block_const_init_ref(struct ast_ASTArena * a, int32_t br, int32_t ci);
extern int32_t ast_ast_block_const_type_ref(struct ast_ASTArena * a, int32_t br, int32_t ci);
extern int32_t ast_ast_block_let_init_ref(struct ast_ASTArena * a, int32_t br, int32_t li);
extern int32_t ast_ast_block_let_type_ref(struct ast_ASTArena * a, int32_t br, int32_t li);
extern int32_t ast_ast_block_expr_stmt_ref(struct ast_ASTArena * a, int32_t br, int32_t ei);
extern int32_t ast_ast_block_while_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t wi);
extern int32_t ast_ast_block_while_body_ref(struct ast_ASTArena * a, int32_t br, int32_t wi);
extern int32_t ast_ast_block_for_init_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_ast_block_for_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_ast_block_for_step_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_ast_block_for_body_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_ast_block_if_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t ii);
extern int32_t ast_ast_block_if_then_body_ref(struct ast_ASTArena * a, int32_t br, int32_t ii);
extern int32_t ast_ast_block_if_else_body_ref(struct ast_ASTArena * a, int32_t br, int32_t ii);
extern int32_t ast_ast_block_resolve_var_to_type_ref(struct ast_ASTArena * a, int32_t block_ref, uint8_t * vname, int32_t vlen);
extern void ast_ast_arena_patch_block_parent_links(struct ast_ASTArena * arena, int32_t block_ref, int32_t parent_ref);
extern void ast_ast_arena_block_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Block b);
extern int32_t ast_ast_arena_func_alloc(struct ast_ASTArena * arena);
extern struct ast_Func ast_ast_arena_func_get(struct ast_ASTArena * arena, int32_t ref);
extern void ast_ast_arena_func_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Func f);
struct codegen_CodegenOutBuf {
  uint8_t data[9437184];
  int32_t len;
};

extern int32_t codegen_path_is_std_io_driver_bytes(uint8_t * path);
extern int32_t codegen_path_is_std_io_core_bytes(uint8_t * path);
extern void codegen_import_path_to_c_prefix_into(uint8_t * path, uint8_t * buf, int32_t buf_cap);
extern int32_t codegen_dep_import_path_len_at(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * dst);
extern int32_t codegen_ctx_dep_path_for_current_codegen_module_into(struct ast_PipelineDepCtx * ctx, uint8_t * dst);
extern int32_t codegen_module_import_path_len_at(struct ast_Module * module, int32_t import_idx, uint8_t * dst);
extern int32_t codegen_find_dep_index_by_path(struct ast_PipelineDepCtx * ctx, uint8_t * path, int32_t path_len);
extern int32_t codegen_find_seeded_global_dep_slot_by_path(uint8_t * path, int32_t path_len);
extern int32_t codegen_module_num_imports(struct ast_Module * module);
extern int32_t codegen_emit_prefix_len_from_ctx(struct ast_PipelineDepCtx * ctx, uint8_t * buf, int32_t buf_cap);
extern int32_t codegen_emit_async_run_seed_push_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, int32_t type_ref);
extern int32_t codegen_emit_async_sched_call(struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t func_index);
extern int32_t codegen_emit_async_sched_call_by_name(struct codegen_CodegenOutBuf * out, uint8_t * fn_name, int32_t fn_len);
extern int32_t codegen_emit_async_task_submit_call(struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t func_index);
extern int32_t codegen_emit_async_task_submit_call_by_symbol(struct codegen_CodegenOutBuf * out, uint8_t * prefix, int32_t prefix_len, uint8_t * fn_name, int32_t fn_len);
extern int32_t codegen_emit_async_binding_import_call(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t call_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t is_spawn);
extern int32_t codegen_emit_async_method_call_run(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t method_expr_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_find_module_func_index_by_name(struct ast_Module * module, uint8_t * nm, int32_t nm_len);
extern int32_t codegen_resolve_binding_import_dep_index(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t callee_expr_ref);
extern int32_t codegen_resolve_call_target_func_index(struct ast_ASTArena * arena, struct ast_Module * module, int32_t call_expr_ref);
extern int32_t codegen_expr_var_matches_func_param_index(struct ast_ASTArena * arena, int32_t var_ref, struct ast_Module * mod, int32_t func_index, int32_t param_idx, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_symbuf_bytes_eq(uint8_t * buf, int32_t buf_len, uint8_t * lit, int32_t lit_len);
extern int32_t codegen_call_num_args_override(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t num_args);
extern int32_t codegen_name_bytes_prefix_eq(uint8_t * name, int32_t name_len, uint8_t * expect, int32_t exp_len);
extern int32_t codegen_is_std_io_driver_bridge_name(uint8_t * name, int32_t name_len);
extern int32_t codegen_should_skip_emit_std_io_core_io_dup(uint8_t * dep_path, uint8_t * name, int32_t name_len);
extern int32_t codegen_should_skip_emit_std_io_trivial_handle(uint8_t * dep_path, uint8_t * name, int32_t name_len);
extern int32_t codegen_should_skip_emit_func(uint8_t * dep_path, uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len);
extern int32_t codegen_force_param_std_io_driver_prefix_ok(uint8_t * prefix, int32_t prefix_len);
extern int32_t codegen_force_param_size_t(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index);
extern int32_t codegen_force_param_size_t_std_io_print_str_second(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index);
extern int32_t codegen_force_param_ptrdiff_t(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index);
extern int32_t codegen_force_param_uint32_t(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index);
extern int32_t codegen_use_buf_wrapper(uint8_t * name, int32_t name_len, int32_t num_args);
extern int32_t codegen_emit_io_driver_buf_call_name(struct codegen_CodegenOutBuf * out, uint8_t * name, int32_t name_len, int32_t num_args);
extern int32_t codegen_try_emit_std_io_driver_buf_body(struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len);
extern int32_t codegen_field_access_base_is_pointer_ref(struct ast_ASTArena * arena, int32_t base_ref);
extern int32_t codegen_field_access_base_type_resolved(struct ast_ASTArena * arena, int32_t base_ref);
extern int32_t codegen_field_access_base_is_pointer_param(struct ast_ASTArena * arena, int32_t base_ref, struct ast_Module * mod, int32_t func_index);
extern int32_t codegen_emit_call_arg_slice_abi(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t arg_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_field_access_base_is_pointer_local(struct ast_ASTArena * arena, int32_t base_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_field_access_base_param_type_known(struct ast_ASTArena * arena, int32_t base_ref, struct ast_Module * mod, int32_t func_index);
extern int32_t codegen_field_access_base_is_slice_param_name(struct ast_ASTArena * arena, int32_t base_ref);
extern int32_t codegen_block_stmt_order_has_let(struct ast_ASTArena * arena, int32_t block_ref, int32_t let_idx);
extern int32_t codegen_c_prefix_redundant_with_name(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len);
extern int32_t codegen_append_byte(struct codegen_CodegenOutBuf * out, int32_t b);
extern int32_t codegen_append_byte_u8(struct codegen_CodegenOutBuf * out, uint8_t b);
extern int32_t codegen_emit_bytes_from_ptr(struct codegen_CodegenOutBuf * out, uint8_t * ptr, int32_t len);
extern int32_t codegen_emit_bytes_64(struct codegen_CodegenOutBuf * out, uint8_t * ptr, int32_t len);
extern int32_t codegen_emit_bytes_32(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_emit_bytes_22(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_emit_bytes_9(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_emit_bytes_8(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_emit_bytes_7(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_emit_bytes_6(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_emit_bytes_5(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_emit_bytes_4(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_emit_bytes_3(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_emit_bytes_2(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_format_uint(struct codegen_CodegenOutBuf * out, int32_t val);
extern int32_t codegen_format_uint64(struct codegen_CodegenOutBuf * out, uint64_t val);
extern int32_t codegen_format_int(struct codegen_CodegenOutBuf * out, int64_t val);
extern int32_t codegen_emit_indent(struct codegen_CodegenOutBuf * out, int32_t indent);
extern int32_t codegen_emit_break_stmt(struct codegen_CodegenOutBuf * out, int32_t indent);
extern int32_t codegen_emit_continue_stmt(struct codegen_CodegenOutBuf * out, int32_t indent);
extern int32_t codegen_emit_type_kind_ord(struct codegen_CodegenOutBuf * out, int32_t tk);
extern int32_t codegen_emit_type_kind(struct codegen_CodegenOutBuf * out, int32_t kind_ord);
extern int32_t codegen_type_kind_append_to_scratch(uint8_t * scratch, int32_t cap, int32_t w, int32_t kind_ord);
extern int32_t codegen_emit_vector_c_type_out(struct codegen_CodegenOutBuf * out, int32_t elem_kind_ord, int32_t lanes);
extern int32_t codegen_type_kind_append_to_scratch_ord(uint8_t * scratch, int32_t cap, int32_t w, int32_t tk);
extern int32_t codegen_type_to_c_repr(struct ast_ASTArena * arena, uint8_t * scratch, int32_t cap, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len);
extern int32_t codegen_emit_type(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_type_dep_struct_owner_index(struct ast_PipelineDepCtx * ctx, uint8_t * bare_nm, int32_t bare_len);
extern int32_t codegen_type_dep_struct_prefix_into(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t type_ref, uint8_t * dst, int32_t dst_cap);
extern int32_t codegen_type_array_elem_is_u8(struct ast_ASTArena * arena, int32_t type_ref);
extern int32_t codegen_emit_local_fixed_array_elem_type(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_local_fixed_array_suffix(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref);
extern int32_t codegen_try_emit_slice_init_from_array_var(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t let_idx, int32_t let_type_ref, int32_t linit_ref);
extern int32_t codegen_emit_braced_array_lit_init(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t init_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_struct_field_type_via_pipeline(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len);
extern int32_t codegen_should_skip_emit_struct_layout_for_abi_dup(uint8_t * name, int32_t name_len);
extern int32_t codegen_type_is_module_user_struct(struct ast_Module * module, struct ast_ASTArena * arena, int32_t type_ref);
extern int32_t codegen_type_is_module_user_enum(struct ast_Module * module, struct ast_ASTArena * arena, int32_t type_ref);
extern int32_t codegen_type_dep_enum_prefix_into(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t type_ref, uint8_t * dst, int32_t dst_cap);
extern int32_t codegen_emit_struct_field_decl_x(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * field_name, int32_t field_name_len, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_module_struct_definitions(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_module_struct_forward_declarations(struct ast_Module * module, struct codegen_CodegenOutBuf * out, uint8_t * struct_prefix, int32_t struct_prefix_len);
extern int32_t codegen_emit_module_struct_forward_declarations_ctx(struct ast_Module * module, struct codegen_CodegenOutBuf * out, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_module_enum_definitions(struct ast_Module * module, struct codegen_CodegenOutBuf * out, uint8_t * enum_prefix, int32_t enum_prefix_len);
extern int32_t codegen_emit_skipped_dep_type_definitions(struct ast_PipelineDepCtx * ctx, struct codegen_CodegenOutBuf * out);
extern int32_t codegen_emit_dep_struct_forward_declarations(struct ast_PipelineDepCtx * ctx, struct codegen_CodegenOutBuf * out);
extern int32_t codegen_resolve_binding_import_path_for_field_access(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * dst);
extern int32_t codegen_resolve_binding_import_path_for_method_call(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * dst);
extern int32_t codegen_emit_import_module_field_symbol(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_import_module_const_field(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_expr(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_callee_var_is_string_new(struct ast_Expr e);
extern int32_t codegen_emit_run_defers(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t indent, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_current_func_returns_void(struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_return_stmt_with_context(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t indent, int32_t operand_ref, struct ast_PipelineDepCtx * ctx, int32_t fn_ret_void);
extern int32_t codegen_emit_block_final_expr(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t final_ref, int32_t indent, struct ast_PipelineDepCtx * ctx, int32_t fn_ret_void);
extern int32_t codegen_emit_block(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t indent, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_suffix_bytes(uint8_t * dst, uint8_t * src, int32_t len);
extern int32_t codegen_type_ref_to_suffix(struct ast_ASTArena * arena, int32_t type_ref, uint8_t * buf, int32_t buf_cap);
extern int32_t codegen_module_func_overload_count(struct ast_Module * module, uint8_t * name_ptr, int32_t name_len);
extern int32_t codegen_func_param_sig_equal(struct ast_ASTArena * arena, struct ast_Module * mod_a, int32_t fi_a, struct ast_Module * mod_b, int32_t fi_b);
extern int32_t codegen_module_overload_param_sig_count(struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi);
extern int32_t codegen_func_c_symbol_prefix_len(struct ast_Module * module, int32_t fi, int32_t prefix_len);
extern int32_t codegen_emit_func_link_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi);
extern struct ast_ASTArena * codegen_arena_for_module(struct ast_PipelineDepCtx * ctx, struct ast_Module * module, struct ast_ASTArena * fallback);
extern int32_t codegen_emit_call_func_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, int32_t expr_ref, struct ast_Module * current_module, uint8_t * fallback_name, int32_t fallback_len);
extern void codegen_copy_func_name64_from_module(struct ast_Module * module, int32_t fi, uint8_t * dst);
extern void codegen_copy_param_name32_from_module(struct ast_Module * module, int32_t fi, int32_t pi, uint8_t * dst);
extern int32_t codegen_block_contains_return(struct ast_ASTArena * arena, int32_t block_ref);
extern int32_t codegen_emit_func(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, int is_entry, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx, int32_t call_init_globals);
extern int32_t codegen_is_libc_conflicting_extern_name(uint8_t * name, int32_t name_len);
extern int32_t codegen_find_mono_type_for_generic_func(struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi);
extern int32_t codegen_try_emit_generic_identity_mono(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_func_extern_declaration(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_import_dep_function_declarations(struct ast_Module * module, struct codegen_CodegenOutBuf * out, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_x_ast_emit_header(struct codegen_CodegenOutBuf * out);
extern int32_t codegen_x_ast(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_PipelineDepCtx * ctx, int32_t dep_index);
extern int32_t codegen_should_skip_emit_func_by_name(uint8_t * name, int32_t name_len);
extern int32_t codegen_is_submit_batch_buf_call(uint8_t * name, int32_t name_len);
extern int32_t codegen_force_param_i32(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index);
extern int32_t codegen_should_skip_emit_func_core_read_ptr(uint8_t * name, int32_t name_len);
extern int32_t codegen_std_io_fixed_fd_emit_impl(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len);
extern int32_t pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * dst);
extern struct ast_Module * pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern struct ast_ASTArena * pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_type_named_name_into(struct ast_ASTArena * arena, int32_t ref, uint8_t * out64);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena * arena, int32_t ref);
extern int32_t pipeline_type_elem_ref_at(struct ast_ASTArena * arena, int32_t ref);
extern int32_t pipeline_type_array_size_at(struct ast_ASTArena * arena, int32_t ref);
extern int32_t pipeline_codegen_type_to_c_repr(struct ast_ASTArena * arena, uint8_t * scratch, int32_t cap, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len);
extern int32_t pipeline_codegen_c_file_prologue_done_get(void);
extern void pipeline_codegen_c_file_prologue_done_set(int32_t v);
extern void pipeline_codegen_c_file_prologue_done_reset(void);
extern int32_t pipeline_codegen_struct_tag_try_claim(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len);
extern int32_t pipeline_codegen_emit_struct_field_type(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len);
extern int32_t pipeline_codegen_emit_struct_field_decl(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * field_name, int32_t field_name_len, uint8_t * struct_prefix, int32_t struct_prefix_len);
extern int32_t pipeline_codegen_emit_seed_mega_enabled(void);
extern int32_t pipeline_codegen_emit_float_lit_c(struct codegen_CodegenOutBuf * out, double float_val, int32_t bits_lo, int32_t bits_hi);
extern void driver_diagnostic_codegen_emit_func_fail(struct ast_Module * module, int32_t func_index);
extern int32_t pipeline_module_struct_layout_name_len(struct ast_Module * module, int32_t idx);
extern void pipeline_module_struct_layout_name_into(struct ast_Module * module, int32_t idx, uint8_t * out64);
extern int32_t pipeline_module_struct_layout_num_fields(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_struct_layout_field_type_ref(struct ast_Module * module, int32_t layout_idx, int32_t field_idx);
extern int32_t pipeline_module_struct_layout_field_name_len(struct ast_Module * module, int32_t layout_idx, int32_t field_idx);
extern void pipeline_module_struct_layout_field_name_into(struct ast_Module * module, int32_t layout_idx, int32_t field_idx, uint8_t * out64);
extern int32_t pipeline_module_struct_layout_is_export_at(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_import_kind_at(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_import_binding_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t pipeline_module_import_binding_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t pipeline_module_import_select_count_at(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_import_select_name_len(struct ast_Module * module, int32_t idx, int32_t sel);
extern uint8_t pipeline_module_import_select_name_byte_at(struct ast_Module * module, int32_t idx, int32_t sel, int32_t off);
extern int32_t pipeline_module_import_path_len(struct ast_Module * module, int32_t idx);
extern void pipeline_module_import_path_copy(struct ast_Module * module, int32_t idx, uint8_t * dst, int32_t dst_cap);
extern int32_t parser_get_module_num_imports(struct ast_Module * module);
extern uint8_t * driver_dep_arena_buf(int32_t i);
extern uint8_t * driver_dep_module_buf(int32_t i);
extern int32_t driver_dep_seeded_get(int32_t i);
extern int32_t driver_dep_slot_for_path(uint8_t * path);
extern uint8_t * driver_get_current_dep_path_for_codegen(void);
extern int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_is_c_static_const_init(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_as_target_type_ref_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_call_resolved_dep_index_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_resolved_func_index_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_match_arm_result_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_array_lit_elem_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_struct_lit_field_name_len(struct ast_ASTArena * arena, int32_t expr_ref, int32_t j);
extern void pipeline_expr_struct_lit_field_name_into(struct ast_ASTArena * arena, int32_t expr_ref, int32_t j, uint8_t * out);
extern int32_t pipeline_expr_struct_lit_init_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t j);
extern int32_t pipeline_expr_struct_lit_num_fields(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_module_enum_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t pipeline_module_enum_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t pipeline_module_enum_num_variants(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_enum_variant_name_len(struct ast_Module * module, int32_t idx, int32_t variant_idx);
extern uint8_t pipeline_module_enum_variant_name_byte_at(struct ast_Module * module, int32_t idx, int32_t variant_idx, int32_t off);
extern void pipeline_codegen_try_mark_enum_field_access(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, struct ast_PipelineDepCtx * dep_ctx);
extern int32_t pipeline_module_top_level_let_is_const(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_top_level_let_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t pipeline_module_top_level_let_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t pipeline_module_top_level_let_type_ref(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_top_level_let_init_ref(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_codegen_dep_skip_x_bootstrap_partial(uint8_t * path);
extern void pipeline_module_func_name_copy64(struct ast_Module * module, int32_t fi, uint8_t * dst);
extern void pipeline_module_func_param_name_copy32(struct ast_Module * module, int32_t fi, int32_t pi, uint8_t * dst);
extern int32_t pipeline_module_func_num_params_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_param_name_len_at(struct ast_Module * module, int32_t fi, int32_t pi);
extern int32_t pipeline_module_func_name_len_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_num_generic_params_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_return_type_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_body_ref_at(struct ast_Module * module, int32_t fi);
extern void pipeline_dep_ctx_empty_param_reset(struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_dep_ctx_empty_param_append(struct ast_PipelineDepCtx * ctx, int32_t pi);
extern int32_t pipeline_dep_ctx_empty_param_at(struct ast_PipelineDepCtx * ctx, int32_t i);
extern void pipeline_dep_ctx_empty_param_backup(struct ast_PipelineDepCtx * ctx);
extern void pipeline_dep_ctx_empty_param_restore(struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_module_func_body_expr_ref_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_is_extern_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_is_used_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_is_naked_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_is_entry_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_is_no_mangle_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_is_interrupt_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_is_variadic_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_param_type_ref_at(struct ast_Module * module, int32_t fi, int32_t pi);
extern void pipeline_block_const_name_copy64(struct ast_ASTArena * arena, int32_t br, int32_t ci, uint8_t * dst);
extern int32_t pipeline_block_const_name_len(struct ast_ASTArena * arena, int32_t br, int32_t ci);
extern int32_t pipeline_block_const_type_ref(struct ast_ASTArena * arena, int32_t br, int32_t ci);
extern int32_t pipeline_block_const_init_ref(struct ast_ASTArena * arena, int32_t br, int32_t ci);
extern void pipeline_block_let_name_copy64(struct ast_ASTArena * arena, int32_t br, int32_t li, uint8_t * dst);
extern int32_t pipeline_block_let_name_len(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern int32_t pipeline_block_let_type_ref(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern int32_t pipeline_block_let_init_ref(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern int32_t pipeline_block_if_cond_ref(struct ast_ASTArena * arena, int32_t br, int32_t ii);
extern int32_t pipeline_block_if_then_body_ref(struct ast_ASTArena * arena, int32_t br, int32_t ii);
extern int32_t pipeline_block_if_else_body_ref(struct ast_ASTArena * arena, int32_t br, int32_t ii);
extern int32_t pipeline_block_defer_body_ref(struct ast_ASTArena * arena, int32_t br, int32_t di);
extern int32_t pipeline_module_func_ref_at(struct ast_Module * module, int32_t func_index);
extern int32_t pipeline_asm_resolve_whole_import_qualified_symbol_c(struct ast_ASTArena * arena, struct ast_Module * cur_mod, int32_t callee_expr_ref, uint8_t * sym_flat, int32_t * out_match_imp_j);
extern uint8_t pipeline_block_stmt_order_kind(struct ast_ASTArena * arena, int32_t br, int32_t si);
extern int32_t pipeline_block_stmt_order_idx(struct ast_ASTArena * arena, int32_t br, int32_t si);
int32_t codegen_path_is_std_io_driver_bytes(uint8_t * path) {
  uint8_t expect[14] = {115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0};
  int32_t i = 0;
  if ((path ==((uint8_t *)(0)))) {
    return 0;
  }
  while ((i < 14)) {
    if (((path)[i] !=(expect)[i])) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
int32_t codegen_path_is_std_io_core_bytes(uint8_t * path) {
  uint8_t expect[12] = {115, 116, 100, 46, 105, 111, 46, 99, 111, 114, 101, 0};
  int32_t i = 0;
  int32_t pi = 0;
  int32_t ei = 0;
  if ((path ==((uint8_t *)(0)))) {
    return 0;
  }
  while ((i < 12)) {
    (void)((pi = ((int32_t)((path)[i]))));
    (void)((ei = ((int32_t)((expect)[i]))));
    if ((pi !=ei)) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
void codegen_import_path_to_c_prefix_into(uint8_t * path, uint8_t * buf, int32_t buf_cap) {
  if (((buf ==((uint8_t *)(0))) || (buf_cap <=0))) {
    return;
  }
  int32_t off = 0;
  int32_t pi = 0;
  while ((path !=((uint8_t *)(0)))) {
    uint8_t ch = (path)[pi];
    if ((ch ==((uint8_t)(0)))) {
      break;
    }
    if (((off + 2) >=buf_cap)) {
      break;
    }
    if ((ch ==((uint8_t)(46)))) {
      (void)(((buf)[off] = ((uint8_t)(95))));
    } else {
      (void)(((buf)[off] = ch));
    }
    (void)((off = (off + 1)));
    (void)((pi = (pi + 1)));
  }
  if (((off + 1) < buf_cap)) {
    (void)(((buf)[off] = ((uint8_t)(95))));
    (void)((off = (off + 1)));
  }
  (void)(((buf)[off] = ((uint8_t)(0))));
}
int32_t codegen_dep_import_path_len_at(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * dst) {
  {
    int32_t plen = pipeline_dep_ctx_import_path_len(ctx, idx);
    if ((plen <=0)) {
      return 0;
    }
    (void)(pipeline_dep_ctx_import_path_copy64(ctx, idx, dst));
    return plen;
  }
  return 0;
}
int32_t codegen_ctx_dep_path_for_current_codegen_module_into(struct ast_PipelineDepCtx * ctx, uint8_t * dst) {
  {
    int32_t nd = pipeline_dep_ctx_ndep(ctx);
    int32_t j = 0;
    if ((ctx ==((struct ast_PipelineDepCtx *)(0)))) {
      return 0;
    }
    while ((j < nd)) {
      if ((pipeline_dep_ctx_module_at(ctx, j) ==(ctx->current_codegen_module))) {
        return codegen_dep_import_path_len_at(ctx, j, dst);
      }
      (void)((j = (j + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t codegen_module_import_path_len_at(struct ast_Module * module, int32_t import_idx, uint8_t * dst) {
  {
    int32_t plen = pipeline_module_import_path_len(module, import_idx);
    if ((((module ==((struct ast_Module *)(0))) || (dst ==((uint8_t *)(0)))) || (import_idx < 0))) {
      return 0;
    }
    if ((plen <=0)) {
      return 0;
    }
    (void)(pipeline_module_import_path_copy(module, import_idx, dst, 64));
    return plen;
  }
  return 0;
}
int32_t codegen_find_dep_index_by_path(struct ast_PipelineDepCtx * ctx, uint8_t * path, int32_t path_len) {
  {
    int32_t di = 0;
    int32_t nd = pipeline_dep_ctx_ndep(ctx);
    if ((((ctx ==((struct ast_PipelineDepCtx *)(0))) || (path ==((uint8_t *)(0)))) || (path_len <=0))) {
      return -(1);
    }
    if (getenv("SHUX_DEBUG_DEP_LIST")) {
      fprintf(stderr, "shux: [DBG_DEP_LIST] find_dep_index_by_path lookup='%.*s' len=%d nd=%d\n",
              (int)path_len, (char*)path, (int)path_len, (int)nd);
      for (di = 0; di < nd; di++) {
        uint8_t dp[64] = {};
        int32_t dl = codegen_dep_import_path_len_at(ctx, di, &dp[0]);
        struct ast_Module * dm = pipeline_dep_ctx_module_at(ctx, di);
        fprintf(stderr, "shux: [DBG_DEP_LIST]   [%d] path='%.*s' len=%d mod=%p funcs=%d\n",
                (int)di, (int)dl, (char*)dp, (int)dl, (void*)dm, dm ? (int)dm->num_funcs : -1);
      }
      di = 0;
    }
    while ((di < nd)) {
      uint8_t dep_path[64] = {};
      int32_t dep_len = codegen_dep_import_path_len_at(ctx, di, &((dep_path)[0]));
      if ((dep_len ==path_len)) {
        int eq = 1;
        int32_t k = 0;
        while (((k < path_len) && (k < 64))) {
          if (((dep_path)[k] !=(path)[k])) {
            (void)((eq = 0));
            break;
          }
          (void)((k = (k + 1)));
        }
        if (eq) {
          return di;
        }
      }
      (void)((di = (di + 1)));
    }
    return -(1);
  }
  return 0;
}
int32_t codegen_find_seeded_global_dep_slot_by_path(uint8_t * path, int32_t path_len) {
  {
    uint8_t path_buf[64] = {};
    int32_t i = 0;
    int32_t gs = driver_dep_slot_for_path(&((path_buf)[0]));
    if ((((path ==((uint8_t *)(0))) || (path_len <=0)) || (path_len > 63))) {
      return -(1);
    }
    while (((i < path_len) && (i < 63))) {
      (void)(((path_buf)[i] = (path)[i]));
      (void)((i = (i + 1)));
    }
    (void)(((path_buf)[i] = ((uint8_t)(0))));
    if (((gs >=0) && (driver_dep_seeded_get(gs) !=0))) {
      return gs;
    }
    return -(1);
  }
  return 0;
}
int32_t codegen_module_num_imports(struct ast_Module * module) {
  {
    int32_t n_imp = parser_get_module_num_imports(module);
    if ((module ==((struct ast_Module *)(0)))) {
      return 0;
    }
    if ((n_imp > 0)) {
      return n_imp;
    }
    return (module->num_imports);
  }
  return 0;
}
int32_t codegen_emit_prefix_len_from_ctx(struct ast_PipelineDepCtx * ctx, uint8_t * buf, int32_t buf_cap) {
  if ((((buf ==((uint8_t *)(0))) || (buf_cap <=0)) || (ctx ==((struct ast_PipelineDepCtx *)(0))))) {
    return 0;
  }
  (void)(((buf)[0] = ((uint8_t)(0))));
  if ((((ctx->current_codegen_dep_index) < 0) && ((ctx->entry_module_import_path_len) > 0))) {
    int32_t pi = 0;
    while (((pi < (ctx->entry_module_import_path_len)) && (pi < (buf_cap - 1)))) {
      (void)(((buf)[pi] = ((ctx->entry_module_import_path_mirror))[pi]));
      (void)((pi = (pi + 1)));
    }
    (void)(((buf)[pi] = ((uint8_t)(0))));
    return pi;
  }
  if (((ctx->current_codegen_prefix_len) > 0)) {
    int32_t pi = 0;
    while (((pi < (ctx->current_codegen_prefix_len)) && (pi < (buf_cap - 1)))) {
      (void)(((buf)[pi] = ((ctx->current_codegen_prefix_mirror))[pi]));
      (void)((pi = (pi + 1)));
    }
    (void)(((buf)[pi] = ((uint8_t)(0))));
    return pi;
  }
  uint8_t path_buf[64] = {};
  int32_t path_len = 0;
  if (((ctx->current_codegen_dep_index) >=0)) {
    (void)((path_len = codegen_dep_import_path_len_at(ctx, (ctx->current_codegen_dep_index), &((path_buf)[0]))));
  }
  if ((path_len ==0)) {
    (void)((path_len = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, &((path_buf)[0]))));
  }
  if ((path_len ==0)) {
    return 0;
  }
  if ((codegen_path_is_std_io_core_bytes(&((path_buf)[0])) !=0)) {
    return 0;
  }
  (void)(codegen_import_path_to_c_prefix_into(&((path_buf)[0]), buf, buf_cap));
  int32_t i = 0;
  while (((i < buf_cap) && ((buf)[i] !=((uint8_t)(0))))) {
    (void)((i = (i + 1)));
  }
  return i;
}
int32_t codegen_emit_async_run_seed_push_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, int32_t type_ref) {
  {
    uint8_t push_i32[28] = {115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 105, 51, 50};
    uint8_t push_u32[28] = {115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 117, 51, 50};
    uint8_t push_i64[28] = {115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 105, 54, 52};
    uint8_t push_usize[30] = {115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 117, 115, 105, 122, 101};
    int32_t kind_ord = ((int32_t)(0));
    if (((arena !=((struct ast_ASTArena *)(0))) && !(ast_ref_is_null(type_ref)))) {
      (void)((kind_ord = pipeline_type_kind_ord_at(arena, type_ref)));
    }
    if ((kind_ord ==((int32_t)(3)))) {
      return codegen_emit_bytes_from_ptr(out, &((push_u32)[0]), 28);
    }
    if ((kind_ord ==((int32_t)(5)))) {
      return codegen_emit_bytes_from_ptr(out, &((push_i64)[0]), 28);
    }
    if ((kind_ord ==((int32_t)(6)))) {
      return codegen_emit_bytes_from_ptr(out, &((push_usize)[0]), 30);
    }
    return codegen_emit_bytes_from_ptr(out, &((push_i32)[0]), 28);
  }
  return 0;
}
int32_t codegen_emit_async_sched_call(struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t func_index) {
  {
    uint8_t sched_prefix[17] = {115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 115, 99, 104, 101, 100, 95};
    uint8_t fn_name[64] = {};
    int32_t fn_len = 0;
    if ((((module ==((struct ast_Module *)(0))) || (func_index < 0)) || (func_index >=(module->num_funcs)))) {
      return -(1);
    }
    (void)((fn_len = pipeline_module_func_name_len_at(module, func_index)));
    if ((fn_len <=0)) {
      return -(1);
    }
    (void)(pipeline_module_func_name_copy64(module, func_index, &((fn_name)[0])));
    if ((codegen_emit_bytes_from_ptr(out, &((sched_prefix)[0]), 17) !=0)) {
      return -(1);
    }
    if ((codegen_emit_bytes_from_ptr(out, &((fn_name)[0]), fn_len) !=0)) {
      return -(1);
    }
    if ((codegen_append_byte(out, 40) !=0)) {
      return -(1);
    }
    return codegen_append_byte(out, 41);
  }
  return 0;
}
int32_t codegen_emit_async_sched_call_by_name(struct codegen_CodegenOutBuf * out, uint8_t * fn_name, int32_t fn_len) {
  uint8_t sched_prefix[17] = {115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 115, 99, 104, 101, 100, 95};
  if ((((out ==((struct codegen_CodegenOutBuf *)(0))) || (fn_name ==((uint8_t *)(0)))) || (fn_len <=0))) {
    return -(1);
  }
  if ((codegen_emit_bytes_from_ptr(out, &((sched_prefix)[0]), 17) !=0)) {
    return -(1);
  }
  if ((codegen_emit_bytes_from_ptr(out, fn_name, fn_len) !=0)) {
    return -(1);
  }
  if ((codegen_append_byte(out, 40) !=0)) {
    return -(1);
  }
  return codegen_append_byte(out, 41);
}
int32_t codegen_emit_async_task_submit_call(struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t func_index) {
  {
    uint8_t submit_name[22] = {115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 116, 97, 115, 107, 95, 115, 117, 98, 109, 105, 116};
    uint8_t cast_prefix[19] = {40, 105, 110, 116, 51, 50, 95, 116, 32, 40, 42, 41, 40, 118, 111, 105, 100, 41, 41};
    uint8_t fn_name[64] = {};
    int32_t fn_len = 0;
    if ((((module ==((struct ast_Module *)(0))) || (func_index < 0)) || (func_index >=(module->num_funcs)))) {
      return -(1);
    }
    (void)((fn_len = pipeline_module_func_name_len_at(module, func_index)));
    if ((fn_len <=0)) {
      return -(1);
    }
    (void)(pipeline_module_func_name_copy64(module, func_index, &((fn_name)[0])));
    if ((codegen_emit_bytes_from_ptr(out, &((submit_name)[0]), 22) !=0)) {
      return -(1);
    }
    if ((codegen_append_byte(out, 40) !=0)) {
      return -(1);
    }
    if ((codegen_emit_bytes_from_ptr(out, &((cast_prefix)[0]), 19) !=0)) {
      return -(1);
    }
    if ((codegen_emit_bytes_from_ptr(out, &((fn_name)[0]), fn_len) !=0)) {
      return -(1);
    }
    if ((codegen_append_byte(out, 41) !=0)) {
      return -(1);
    }
    return 0;
  }
  return 0;
}
int32_t codegen_emit_async_task_submit_call_by_symbol(struct codegen_CodegenOutBuf * out, uint8_t * prefix, int32_t prefix_len, uint8_t * fn_name, int32_t fn_len) {
  uint8_t submit_name[22] = {115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 116, 97, 115, 107, 95, 115, 117, 98, 109, 105, 116};
  uint8_t cast_prefix[19] = {40, 105, 110, 116, 51, 50, 95, 116, 32, 40, 42, 41, 40, 118, 111, 105, 100, 41, 41};
  if ((((out ==((struct codegen_CodegenOutBuf *)(0))) || (fn_name ==((uint8_t *)(0)))) || (fn_len <=0))) {
    return -(1);
  }
  if ((codegen_emit_bytes_from_ptr(out, &((submit_name)[0]), 22) !=0)) {
    return -(1);
  }
  if ((codegen_append_byte(out, 40) !=0)) {
    return -(1);
  }
  if ((codegen_emit_bytes_from_ptr(out, &((cast_prefix)[0]), 19) !=0)) {
    return -(1);
  }
  if (((((prefix !=((uint8_t *)(0))) && (prefix_len > 0)) && (codegen_c_prefix_redundant_with_name(prefix, prefix_len, fn_name, fn_len) ==0)) && (codegen_emit_bytes_from_ptr(out, prefix, prefix_len) !=0))) {
    return -(1);
  }
  if ((codegen_emit_bytes_from_ptr(out, fn_name, fn_len) !=0)) {
    return -(1);
  }
  if ((codegen_append_byte(out, 41) !=0)) {
    return -(1);
  }
  return 0;
}
int32_t codegen_emit_async_binding_import_call(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t call_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t is_spawn) {
  {
    uint8_t reset_name[25] = {115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 114, 101, 115, 101, 116};
    uint8_t comma[3] = {44, 32, 0};
    uint8_t dep_path[64] = {};
    uint8_t prefix_buf[128] = {};
    int32_t dep_ix = -(1);
    int32_t n_args = 0;
    int32_t ai = 0;
    int32_t prefix_len = 0;
    if ((((arena ==((struct ast_ASTArena *)(0))) || (out ==((struct codegen_CodegenOutBuf *)(0)))) || (ctx ==((struct ast_PipelineDepCtx *)(0))))) {
      return -(1);
    }
    if (((ast_ref_is_null(call_expr_ref) || (call_expr_ref <=0)) || (call_expr_ref > (arena->num_exprs)))) {
      return -(1);
    }
    struct ast_Expr call_e = ast_ast_arena_expr_get(arena, call_expr_ref);
    if ((((((call_e.kind) !=48) || ast_ref_is_null((call_e.call_callee_ref))) || ((call_e.call_callee_ref) <=0)) || ((call_e.call_callee_ref) > (arena->num_exprs)))) {
      return -(1);
    }
    struct ast_Expr callee_e = ast_ast_arena_expr_get(arena, (call_e.call_callee_ref));
    if ((((callee_e.kind) !=44) || ((callee_e.field_access_field_len) <=0))) {
      return -(1);
    }
    (void)((n_args = (call_e.call_num_args)));
    if ((n_args < 0)) {
      return -(1);
    }
    if ((is_spawn ==0)) {
      if ((n_args > 0)) {
        if ((codegen_append_byte(out, 40) !=0)) {
          return -(1);
        }
        if ((codegen_emit_bytes_from_ptr(out, &((reset_name)[0]), 25) !=0)) {
          return -(1);
        }
        if ((codegen_append_byte(out, 40) !=0)) {
          return -(1);
        }
        if ((codegen_append_byte(out, 41) !=0)) {
          return -(1);
        }
        (void)((ai = 0));
        while ((ai < n_args)) {
          int32_t arg_ref = pipeline_expr_call_arg_ref(arena, call_expr_ref, ai);
          int32_t arg_type_ref = 0;
          if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
            return -(1);
          }
          if (!(ast_ref_is_null(arg_ref))) {
            (void)((arg_type_ref = pipeline_expr_resolved_type_ref(arena, arg_ref)));
          }
          if ((codegen_emit_async_run_seed_push_name(out, arena, arg_type_ref) !=0)) {
            return -(1);
          }
          if ((codegen_append_byte(out, 40) !=0)) {
            return -(1);
          }
          if ((!(ast_ref_is_null(arg_ref)) && (codegen_emit_expr(arena, out, arg_ref, ctx) !=0))) {
            return -(1);
          }
          if ((codegen_append_byte(out, 41) !=0)) {
            return -(1);
          }
          (void)((ai = (ai + 1)));
        }
        if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
          return -(1);
        }
        if ((codegen_emit_async_sched_call_by_name(out, &(((callee_e.field_access_field_name))[0]), (callee_e.field_access_field_len)) !=0)) {
          return -(1);
        }
        return codegen_append_byte(out, 41);
      }
      return codegen_emit_async_sched_call_by_name(out, &(((callee_e.field_access_field_name))[0]), (callee_e.field_access_field_len));
    }
    (void)((dep_ix = codegen_resolve_binding_import_dep_index(ctx, arena, (call_e.call_callee_ref))));
    if (((dep_ix < 0) || (dep_ix >=pipeline_dep_ctx_ndep(ctx)))) {
      return -(1);
    }
    (void)(pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, &((dep_path)[0])));
    (void)(codegen_import_path_to_c_prefix_into(&((dep_path)[0]), &((prefix_buf)[0]), 128));
    while (((prefix_len < 128) && ((prefix_buf)[prefix_len] !=0))) {
      (void)((prefix_len = (prefix_len + 1)));
    }
    if ((n_args > 0)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      (void)((ai = 0));
      while ((ai < n_args)) {
        int32_t arg_ref2 = pipeline_expr_call_arg_ref(arena, call_expr_ref, ai);
        int32_t arg_type_ref2 = 0;
        if (((ai > 0) && (codegen_emit_bytes_3(out, comma, 2) !=0))) {
          return -(1);
        }
        if (!(ast_ref_is_null(arg_ref2))) {
          (void)((arg_type_ref2 = pipeline_expr_resolved_type_ref(arena, arg_ref2)));
        }
        if ((codegen_emit_async_run_seed_push_name(out, arena, arg_type_ref2) !=0)) {
          return -(1);
        }
        if ((codegen_append_byte(out, 40) !=0)) {
          return -(1);
        }
        if ((!(ast_ref_is_null(arg_ref2)) && (codegen_emit_expr(arena, out, arg_ref2, ctx) !=0))) {
          return -(1);
        }
        if ((codegen_append_byte(out, 41) !=0)) {
          return -(1);
        }
        (void)((ai = (ai + 1)));
      }
      if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
        return -(1);
      }
      if ((codegen_emit_async_task_submit_call_by_symbol(out, &((prefix_buf)[0]), prefix_len, &(((callee_e.field_access_field_name))[0]), (callee_e.field_access_field_len)) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    return codegen_emit_async_task_submit_call_by_symbol(out, &((prefix_buf)[0]), prefix_len, &(((callee_e.field_access_field_name))[0]), (callee_e.field_access_field_len));
  }
  return 0;
}
int32_t codegen_emit_async_method_call_run(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t method_expr_ref, struct ast_PipelineDepCtx * ctx) {
  {
    uint8_t reset_name[25] = {115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 114, 101, 115, 101, 116};
    uint8_t comma[3] = {44, 32, 0};
    int32_t ai = 0;
    if ((((arena ==((struct ast_ASTArena *)(0))) || (out ==((struct codegen_CodegenOutBuf *)(0)))) || (ctx ==((struct ast_PipelineDepCtx *)(0))))) {
      return -(1);
    }
    if (((ast_ref_is_null(method_expr_ref) || (method_expr_ref <=0)) || (method_expr_ref > (arena->num_exprs)))) {
      return -(1);
    }
    struct ast_Expr method_e = ast_ast_arena_expr_get(arena, method_expr_ref);
    if ((((method_e.kind) !=49) || ((method_e.method_call_name_len) <=0))) {
      return -(1);
    }
    if (((method_e.method_call_num_args) > 0)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((reset_name)[0]), 25) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -(1);
      }
      while ((ai < (method_e.method_call_num_args))) {
        int32_t arg_ref = pipeline_expr_method_call_arg_ref(arena, method_expr_ref, ai);
        int32_t arg_type_ref = 0;
        if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
          return -(1);
        }
        if (!(ast_ref_is_null(arg_ref))) {
          (void)((arg_type_ref = pipeline_expr_resolved_type_ref(arena, arg_ref)));
        }
        if ((codegen_emit_async_run_seed_push_name(out, arena, arg_type_ref) !=0)) {
          return -(1);
        }
        if ((codegen_append_byte(out, 40) !=0)) {
          return -(1);
        }
        if ((!(ast_ref_is_null(arg_ref)) && (codegen_emit_expr(arena, out, arg_ref, ctx) !=0))) {
          return -(1);
        }
        if ((codegen_append_byte(out, 41) !=0)) {
          return -(1);
        }
        (void)((ai = (ai + 1)));
      }
      if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
        return -(1);
      }
      if ((codegen_emit_async_sched_call_by_name(out, &(((method_e.method_call_name))[0]), (method_e.method_call_name_len)) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    return codegen_emit_async_sched_call_by_name(out, &(((method_e.method_call_name))[0]), (method_e.method_call_name_len));
  }
  return 0;
}
int32_t codegen_find_module_func_index_by_name(struct ast_Module * module, uint8_t * nm, int32_t nm_len) {
  {
    int32_t fi = 0;
    if ((((module ==((struct ast_Module *)(0))) || (nm ==((uint8_t *)(0)))) || (nm_len <=0))) {
      return -(1);
    }
    while ((fi < (module->num_funcs))) {
      int32_t fn_len = pipeline_module_func_name_len_at(module, fi);
      if (((fn_len ==nm_len) && (fn_len > 0))) {
        uint8_t fn_name[64] = {};
        int32_t matched = 1;
        int32_t bi = 0;
        (void)(pipeline_module_func_name_copy64(module, fi, &((fn_name)[0])));
        while ((bi < fn_len)) {
          if (((fn_name)[bi] !=(nm)[bi])) {
            (void)((matched = 0));
            (void)((bi = fn_len));
          } else {
            (void)((bi = (bi + 1)));
          }
        }
        if ((matched !=0)) {
          return fi;
        }
      }
      (void)((fi = (fi + 1)));
    }
    return -(1);
  }
  return 0;
}
int32_t codegen_resolve_binding_import_dep_index(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t callee_expr_ref) {
  {
    struct ast_Expr callee_e = ast_ast_arena_expr_get(arena, callee_expr_ref);
    struct ast_Expr base_e = ast_ast_arena_expr_get(arena, (callee_e.field_access_base_ref));
    struct ast_Module * cur_mod = (ctx->current_codegen_module);
    int32_t nd = pipeline_dep_ctx_ndep(ctx);
    int32_t j = 0;
    int32_t n_imp = codegen_module_num_imports(cur_mod);
    if ((((ctx ==((struct ast_PipelineDepCtx *)(0))) || (arena ==((struct ast_ASTArena *)(0)))) || ((ctx->current_codegen_module) ==((struct ast_Module *)(0))))) {
      return -(1);
    }
    if (((ast_ref_is_null(callee_expr_ref) || (callee_expr_ref <=0)) || (callee_expr_ref > (arena->num_exprs)))) {
      return -(1);
    }
    if (((((callee_e.kind) !=44) || ((callee_e.field_access_base_ref) <=0)) || ((callee_e.field_access_base_ref) > (arena->num_exprs)))) {
      return -(1);
    }
    if (((((base_e.kind) !=3) || ((base_e.var_name_len) <=0)) || ((base_e.var_name_len) > 63))) {
      return -(1);
    }
    while (((j < n_imp) && (j < nd))) {
      if ((pipeline_module_import_kind_at(cur_mod, j) ==1)) {
        int32_t bind_len = pipeline_module_import_binding_name_len(cur_mod, j);
        if ((bind_len ==(base_e.var_name_len))) {
          int32_t matched = 1;
          int32_t kk = 0;
          while ((kk < bind_len)) {
            if ((((base_e.var_name))[kk] !=pipeline_module_import_binding_name_byte_at(cur_mod, j, kk))) {
              (void)((matched = 0));
              (void)((kk = bind_len));
            } else {
              (void)((kk = (kk + 1)));
            }
          }
          if ((matched !=0)) {
            uint8_t import_path[64] = {};
            int32_t import_path_len = codegen_module_import_path_len_at(cur_mod, j, &((import_path)[0]));
            if ((import_path_len <=0)) {
              return -(1);
            }
            return codegen_find_dep_index_by_path(ctx, &((import_path)[0]), import_path_len);
          }
        }
      }
      (void)((j = (j + 1)));
    }
    return -(1);
  }
  return 0;
}
extern int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena * arena, int32_t a, int32_t b);
int32_t codegen_find_module_func_index_by_name_overload(struct ast_ASTArena * arena, struct ast_Module * module,
int32_t call_expr_ref, uint8_t * nm, int32_t nm_len) {
  {
    int32_t fi = 0;
    int32_t first_idx = -1;
    int32_t best_idx = -1;
    int32_t best_score = -1;
    int32_t num_args = 0;
    if (((module ==0) || (nm ==0)) || (nm_len <=0)) {
      return -(1);
    }
    if (((call_expr_ref >0) && (call_expr_ref <= (arena->num_exprs)))) {
      (void)((num_args = pipeline_expr_call_num_args_at(arena, call_expr_ref)));
    }
    while ((fi < (module->num_funcs))) {
      int32_t fn_len = pipeline_module_func_name_len_at(module, fi);
      if (((fn_len ==nm_len) && (fn_len > 0))) {
        uint8_t fn_name[64] = {};
        int32_t matched = 1;
        int32_t bi = 0;
        pipeline_module_func_name_copy64(module, fi, &((fn_name)[0]));
        while ((bi < fn_len)) {
          if (((fn_name)[bi] != (nm)[bi])) {
            matched = 0;
            bi = fn_len;
          } else {
            bi = (bi + 1);
          }
        }
        if ((matched !=0)) {
          if ((first_idx < 0)) {
            first_idx = fi;
          }
          if ((num_args > 0)) {
            int32_t np = pipeline_module_func_num_params_at(module, fi);
            if ((np ==num_args)) {
              int32_t ai = 0;
              int32_t score = 0;
              int32_t ok = 1;
              while ((ai < num_args)) {
                int32_t arg_ref = pipeline_expr_call_arg_ref(arena, call_expr_ref, ai);
                int32_t param_ty = pipeline_module_func_param_type_ref_at(module, fi, ai);
                int32_t arg_ty = 0;
                int32_t sc = 0;
                if ((arg_ref <=0)) {
                  ok = 0;
                  break;
                }
                (void)((arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref)));
                if (((arg_ty > 0) && (param_ty > 0)) && (pipeline_typeck_type_refs_equal_c(arena, arg_ty, param_ty) !=0)) {
                  sc = 1000;
                } else if (((arg_ty > 0) && (param_ty > 0))) {
                  int32_t ak = pipeline_type_kind_ord_at(arena, arg_ty);
                  int32_t pk = pipeline_type_kind_ord_at(arena, param_ty);
                  if (((ak ==pk) && (ak !=0))) {
                    sc = 1;
                  } else {
                    sc = -(1);
                  }
                } else {
                  sc = 0;
                }
                if ((sc < 0)) {
                  ok = 0;
                  break;
                }
                score = (score + sc);
                ai = (ai + 1);
              }
              if (((ok !=0) && (score > best_score))) {
                best_score = score;
                best_idx = fi;
              }
            }
          }
        }
      }
      fi = (fi + 1);
    }
    if ((best_idx >=0)) {
        return best_idx;
    }
    return first_idx;
  }
}
int32_t codegen_resolve_call_target_func_index(struct ast_ASTArena * arena, struct ast_Module * module, int32_t call_expr_ref) {
  {
    int32_t func_ix = -(1);
    if (((module ==((struct ast_Module *)(0))) || (arena ==((struct ast_ASTArena *)(0))))) {
      return -(1);
    }
    (void)((func_ix = pipeline_expr_call_resolved_func_index_at(arena, call_expr_ref)));
    if (((func_ix >=0) && (func_ix < (module->num_funcs)))) {
      return func_ix;
    }
    if (((ast_ref_is_null(call_expr_ref) || (call_expr_ref <=0)) || (call_expr_ref > (arena->num_exprs)))) {
      return -(1);
    }
    struct ast_Expr call_e = ast_ast_arena_expr_get(arena, call_expr_ref);
    if (((call_e.kind) ==48)) {
      struct ast_Expr callee_e = ast_ast_arena_expr_get(arena, (call_e.call_callee_ref));
      if (((ast_ref_is_null((call_e.call_callee_ref)) || ((call_e.call_callee_ref) <=0)) || ((call_e.call_callee_ref) > (arena->num_exprs)))) {
        return -(1);
      }
      if ((((callee_e.kind) ==3) && ((callee_e.var_name_len) > 0))) {
        return codegen_find_module_func_index_by_name_overload(arena, module, call_expr_ref, &(((callee_e.var_name))[0]), (callee_e.var_name_len));
      }
      if ((((callee_e.kind) ==44) && ((callee_e.field_access_field_len) > 0))) {
        return codegen_find_module_func_index_by_name_overload(arena, module, call_expr_ref, &(((callee_e.field_access_field_name))[0]), (callee_e.field_access_field_len));
      }
      return -(1);
    }
    if ((((call_e.kind) ==49) && ((call_e.method_call_name_len) > 0))) {
      return codegen_find_module_func_index_by_name_overload(arena, module, call_expr_ref, &(((call_e.method_call_name))[0]), (call_e.method_call_name_len));
    }
    return -(1);
  }
  return 0;
}
int32_t codegen_expr_var_matches_func_param_index(struct ast_ASTArena * arena, int32_t var_ref, struct ast_Module * mod, int32_t func_index, int32_t param_idx, struct ast_PipelineDepCtx * ctx) {
  {
    int32_t np = pipeline_module_func_num_params_at(mod, func_index);
    struct ast_Expr base = ast_ast_arena_expr_get(arena, var_ref);
    int32_t p_name_len = pipeline_module_func_param_name_len_at(mod, func_index, param_idx);
    if (((ast_ref_is_null(var_ref) || (var_ref <=0)) || (var_ref > (arena->num_exprs)))) {
      return 0;
    }
    if (((func_index < 0) || (func_index >=(mod->num_funcs)))) {
      return 0;
    }
    if (((param_idx < 0) || (param_idx >=np))) {
      return 0;
    }
    if (((base.kind) !=3)) {
      return 0;
    }
    if ((p_name_len > 0)) {
      uint8_t pname_buf[32] = {};
      (void)(pipeline_module_func_param_name_copy32(mod, func_index, param_idx, &((pname_buf)[0])));
      if (((pname_buf)[0] > 32)) {
        int32_t j = 0;
        if (((base.var_name_len) !=p_name_len)) {
          return 0;
        }
        if ((((base.var_name_len) <=0) || (((base.var_name))[0] <=32))) {
          return 0;
        }
        while ((j < p_name_len)) {
          if ((((base.var_name))[j] !=(pname_buf)[j])) {
            return 0;
          }
          (void)((j = (j + 1)));
        }
        return 1;
      }
    }
    if ((ctx ==((struct ast_PipelineDepCtx *)(0)))) {
      return 0;
    }
    if (((ctx->current_func_single_empty_param_index) !=param_idx)) {
      return 0;
    }
    if ((((base.var_name_len) <=0) || (((base.var_name))[0] <=32))) {
      return 1;
    }
    return 0;
  }
  return 0;
}
int32_t codegen_symbuf_bytes_eq(uint8_t * buf, int32_t buf_len, uint8_t * lit, int32_t lit_len) {
  if ((((buf ==((uint8_t *)(0))) || (lit ==((uint8_t *)(0)))) || (buf_len !=lit_len))) {
    return 0;
  }
  int32_t i = 0;
  while ((i < lit_len)) {
    if (((buf)[i] !=(lit)[i])) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
int32_t codegen_call_num_args_override(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t num_args) {
  if ((num_args <=0)) {
    return num_args;
  }
  uint8_t buf[96] = {};
  int32_t full = 0;
  int32_t i = 0;
  if (((prefix !=((uint8_t *)(0))) && (prefix_len > 0))) {
    (void)((i = 0));
    while (((i < prefix_len) && (full < 96))) {
      (void)(((buf)[full] = (prefix)[i]));
      (void)((full = (full + 1)));
      (void)((i = (i + 1)));
    }
  }
  if (((name !=((uint8_t *)(0))) && (name_len > 0))) {
    (void)((i = 0));
    while (((i < name_len) && (full < 96))) {
      (void)(((buf)[full] = (name)[i]));
      (void)((full = (full + 1)));
      (void)((i = (i + 1)));
    }
  }
  uint8_t z0[13] = {118, 101, 99, 95, 108, 101, 110, 95, 101, 109, 112, 116, 121};
  uint8_t z1[21] = {115, 116, 100, 95, 118, 101, 99, 95, 118, 101, 99, 95, 108, 101, 110, 95, 101, 109, 112, 116, 121};
  uint8_t z2[15] = {97, 108, 108, 111, 99, 95, 115, 105, 122, 101, 95, 122, 101, 114, 111};
  uint8_t z3[24] = {115, 116, 100, 95, 104, 101, 97, 112, 95, 97, 108, 108, 111, 99, 95, 115, 105, 122, 101, 95, 122, 101, 114, 111};
  uint8_t z4[13] = {114, 117, 110, 116, 105, 109, 101, 95, 114, 101, 97, 100, 121};
  uint8_t z5[25] = {115, 116, 100, 95, 114, 117, 110, 116, 105, 109, 101, 95, 114, 117, 110, 116, 105, 109, 101, 95, 114, 101, 97, 100, 121};
  uint8_t z6[10] = {115, 116, 114, 105, 110, 103, 95, 110, 101, 119};
  uint8_t z7[21] = {115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 115, 116, 114, 105, 110, 103, 95, 110, 101, 119};
  uint8_t z8[11] = {112, 108, 97, 99, 101, 104, 111, 108, 100, 101, 114};
  uint8_t z9[22] = {115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 112, 108, 97, 99, 101, 104, 111, 108, 100, 101, 114};
  uint8_t z10[11] = {116, 104, 114, 101, 97, 100, 95, 115, 101, 108, 102};
  uint8_t z11[22] = {115, 116, 100, 95, 116, 104, 114, 101, 97, 100, 95, 116, 104, 114, 101, 97, 100, 95, 115, 101, 108, 102};
  uint8_t z12[22] = {116, 104, 114, 101, 97, 100, 95, 100, 117, 109, 109, 121, 95, 101, 110, 116, 114, 121, 95, 112, 116, 114};
  uint8_t z13[33] = {115, 116, 100, 95, 116, 104, 114, 101, 97, 100, 95, 116, 104, 114, 101, 97, 100, 95, 100, 117, 109, 109, 121, 95, 101, 110, 116, 114, 121, 95, 112, 116, 114};
  uint8_t z14[16] = {110, 111, 119, 95, 109, 111, 110, 111, 116, 111, 110, 105, 99, 95, 110, 115};
  uint8_t z15[25] = {115, 116, 100, 95, 116, 105, 109, 101, 95, 110, 111, 119, 95, 109, 111, 110, 111, 116, 111, 110, 105, 99, 95, 110, 115};
  uint8_t z16[16] = {110, 111, 119, 95, 109, 111, 110, 111, 116, 111, 110, 105, 99, 95, 109, 115};
  uint8_t z17[25] = {115, 116, 100, 95, 116, 105, 109, 101, 95, 110, 111, 119, 95, 109, 111, 110, 111, 116, 111, 110, 105, 99, 95, 109, 115};
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z0)[0]), 13) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z1)[0]), 21) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z2)[0]), 15) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z3)[0]), 24) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z4)[0]), 13) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z5)[0]), 25) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z6)[0]), 10) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z7)[0]), 21) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z8)[0]), 11) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z9)[0]), 22) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z10)[0]), 11) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z11)[0]), 22) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z12)[0]), 22) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z13)[0]), 33) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z14)[0]), 16) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z15)[0]), 25) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z16)[0]), 16) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z17)[0]), 25) !=0)) {
    return 0;
  }
  if ((num_args >=1)) {
    uint8_t o0[7] = {102, 109, 116, 95, 105, 51, 50};
    uint8_t o1[16] = {99, 111, 114, 101, 95, 102, 109, 116, 95, 102, 109, 116, 95, 105, 51, 50};
    uint8_t o2[9] = {112, 114, 105, 110, 116, 95, 105, 51, 50};
    uint8_t o3[16] = {115, 116, 100, 95, 105, 111, 95, 112, 114, 105, 110, 116, 95, 105, 51, 50};
    uint8_t o4[9] = {112, 114, 105, 110, 116, 95, 117, 51, 50};
    uint8_t o5[16] = {115, 116, 100, 95, 105, 111, 95, 112, 114, 105, 110, 116, 95, 117, 51, 50};
    uint8_t o6[9] = {112, 114, 105, 110, 116, 95, 105, 54, 52};
    uint8_t o7[16] = {115, 116, 100, 95, 105, 111, 95, 112, 114, 105, 110, 116, 95, 105, 54, 52};
    uint8_t o8[6] = {111, 107, 95, 105, 51, 50};
    uint8_t o9[18] = {99, 111, 114, 101, 95, 114, 101, 115, 117, 108, 116, 95, 111, 107, 95, 105, 51, 50};
    uint8_t o10[7] = {101, 114, 114, 95, 105, 51, 50};
    uint8_t o11[19] = {99, 111, 114, 101, 95, 114, 101, 115, 117, 108, 116, 95, 101, 114, 114, 95, 105, 51, 50};
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o0)[0]), 7) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o1)[0]), 16) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o2)[0]), 9) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o3)[0]), 16) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o4)[0]), 9) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o5)[0]), 16) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o6)[0]), 9) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o7)[0]), 16) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o8)[0]), 6) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o9)[0]), 18) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o10)[0]), 7) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o11)[0]), 19) !=0)) {
      return 1;
    }
  }
  return num_args;
}
int32_t codegen_name_bytes_prefix_eq(uint8_t * name, int32_t name_len, uint8_t * expect, int32_t exp_len) {
  if ((((name ==((uint8_t *)(0))) || (expect ==((uint8_t *)(0)))) || (name_len < exp_len))) {
    return 0;
  }
  int32_t i = 0;
  while ((i < exp_len)) {
    if (((name)[i] !=(expect)[i])) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
int32_t codegen_is_std_io_driver_bridge_name(uint8_t * name, int32_t name_len) {
  if ((name ==((uint8_t *)(0)))) {
    return 0;
  }
  uint8_t nm8[8] = {114, 101, 103, 105, 115, 116, 101, 114};
  if ((((name_len ==8) || (name_len ==9)) && (codegen_name_bytes_prefix_eq(name, name_len, &((nm8)[0]), 8) !=0))) {
    return 1;
  }
  uint8_t nm11[11] = {115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100};
  if ((((name_len ==11) || (name_len ==12)) && (codegen_name_bytes_prefix_eq(name, name_len, &((nm11)[0]), 11) !=0))) {
    return 1;
  }
  uint8_t nm12[12] = {115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101};
  if ((((name_len ==12) || (name_len ==13)) && (codegen_name_bytes_prefix_eq(name, name_len, &((nm12)[0]), 12) !=0))) {
    return 1;
  }
  uint8_t nm13[13] = {119, 97, 105, 116, 95, 114, 101, 97, 100, 97, 98, 108, 101};
  if ((((name_len ==13) || (name_len ==14)) && (codegen_name_bytes_prefix_eq(name, name_len, &((nm13)[0]), 13) !=0))) {
    return 1;
  }
  uint8_t nm22[22] = {114, 101, 103, 105, 115, 116, 101, 114, 95, 102, 105, 120, 101, 100, 95, 98, 117, 102, 102, 101, 114, 115};
  if (((name_len ==22) && (codegen_name_bytes_prefix_eq(name, name_len, &((nm22)[0]), 22) !=0))) {
    return 1;
  }
  return 0;
}
int32_t codegen_should_skip_emit_std_io_core_io_dup(uint8_t * dep_path, uint8_t * name, int32_t name_len) {
  uint8_t path_core[11] = {115, 116, 100, 46, 105, 111, 46, 99, 111, 114, 101};
  /* PLATFORM: SHARED — only skip fixed read/write (preamble weak); do NOT skip
   * submit_read / submit_*_batch: co-emit core → backend is authority; old skip left
   * weak stubs that call bare io_write_batch (UNDEF without runtime_asm_io_stubs). */
  uint8_t n_rf[18] = {115, 104, 117, 120, 95, 105, 111, 95, 114, 101, 97, 100, 95, 102, 105, 120, 101, 100};
  uint8_t n_wf[19] = {115, 104, 117, 120, 95, 105, 111, 95, 119, 114, 105, 116, 101, 95, 102, 105, 120, 101, 100};
  int32_t di = 0;
  if (((dep_path ==((uint8_t *)(0))) || (name ==((uint8_t *)(0))))) {
    return 0;
  }
  while ((di < 11)) {
    if (((dep_path)[di] !=(path_core)[di])) {
      return 0;
    }
    (void)((di = (di + 1)));
  }
  if ((((name_len ==18) || (name_len ==19)) && (codegen_name_bytes_prefix_eq(name, name_len, &((n_rf)[0]), 18) !=0))) {
    return 1;
  }
  if ((((name_len ==19) || (name_len ==20)) && (codegen_name_bytes_prefix_eq(name, name_len, &((n_wf)[0]), 19) !=0))) {
    return 1;
  }
  return 0;
}
int32_t codegen_should_skip_emit_std_io_trivial_handle(uint8_t * dep_path, uint8_t * name, int32_t name_len) {
  uint8_t path_io[7] = {115, 116, 100, 46, 105, 111, 0};
  uint8_t h_stdin[12] = {104, 97, 110, 100, 108, 101, 95, 115, 116, 100, 105, 110};
  uint8_t h_stdout[13] = {104, 97, 110, 100, 108, 101, 95, 115, 116, 100, 111, 117, 116};
  uint8_t h_stderr[13] = {104, 97, 110, 100, 108, 101, 95, 115, 116, 100, 101, 114, 114};
  uint8_t h_from_fd[15] = {104, 97, 110, 100, 108, 101, 95, 102, 114, 111, 109, 95, 102, 100, 0};
  int32_t di = 0;
  if ((name ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((dep_path !=((uint8_t *)(0)))) {
    while ((di < 7)) {
      if (((dep_path)[di] !=(path_io)[di])) {
        return 0;
      }
      (void)((di = (di + 1)));
    }
  }
  if ((((name_len ==12) || (name_len ==13)) && (codegen_name_bytes_prefix_eq(name, name_len, &((h_stdin)[0]), 12) !=0))) {
    return 1;
  }
  if ((((name_len ==13) || (name_len ==14)) && (codegen_name_bytes_prefix_eq(name, name_len, &((h_stdout)[0]), 13) !=0))) {
    return 1;
  }
  if ((((name_len ==13) || (name_len ==14)) && (codegen_name_bytes_prefix_eq(name, name_len, &((h_stderr)[0]), 13) !=0))) {
    return 1;
  }
  if ((((name_len ==15) || (name_len ==16)) && (codegen_name_bytes_prefix_eq(name, name_len, &((h_from_fd)[0]), 15) !=0))) {
    return 1;
  }
  return 0;
}
int32_t codegen_should_skip_emit_func(uint8_t * dep_path, uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len) {
  uint8_t full33[33] = {115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110};
  uint8_t full29[29] = {115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114};
  uint8_t path_driver[14] = {115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0};
  uint8_t path_io[7] = {115, 116, 100, 46, 105, 111, 0};
  uint8_t nm_len19[19] = {100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110};
  uint8_t nm_len15[15] = {100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114};
  uint8_t nm_gen19[19] = {100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 103, 101, 110};
  int32_t pi = 0;
  int32_t ni = 0;
  int32_t ok_path = 0;
  int32_t di = 0;
  uint8_t full33_gen[33] = {115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 103, 101, 110};
  if (((((prefix !=((uint8_t *)(0))) && (prefix_len > 0)) && (name !=((uint8_t *)(0)))) && (name_len > 0))) {
    int32_t total_len = (prefix_len + name_len);
    if ((total_len ==33)) {
      int32_t match_len = 1;
      int32_t match_gen = 1;
      (void)((pi = 0));
      while ((pi < prefix_len)) {
        if (((prefix)[pi] !=(full33)[pi])) {
          (void)((match_len = 0));
        }
        if (((prefix)[pi] !=(full33_gen)[pi])) {
          (void)((match_gen = 0));
        }
        (void)((pi = (pi + 1)));
      }
      (void)((ni = 0));
      while ((ni < name_len)) {
        if (((name)[ni] !=(full33)[(prefix_len + ni)])) {
          (void)((match_len = 0));
        }
        if (((name)[ni] !=(full33_gen)[(prefix_len + ni)])) {
          (void)((match_gen = 0));
        }
        (void)((ni = (ni + 1)));
      }
      if (((match_len !=0) || (match_gen !=0))) {
        return 1;
      }
    }
    if ((total_len ==29)) {
      (void)((pi = 0));
      while ((pi < prefix_len)) {
        if (((prefix)[pi] !=(full29)[pi])) {
          (void)((pi = (prefix_len + 1)));
          break;
        }
        (void)((pi = (pi + 1)));
      }
      if ((pi ==prefix_len)) {
        (void)((ni = 0));
        while ((ni < name_len)) {
          if (((name)[ni] !=(full29)[(prefix_len + ni)])) {
            (void)((ni = (name_len + 1)));
            break;
          }
          (void)((ni = (ni + 1)));
        }
        if ((ni ==name_len)) {
          return 1;
        }
      }
    }
  }
  if ((dep_path !=((uint8_t *)(0)))) {
    (void)((ok_path = 0));
    (void)((di = 0));
    while ((di < 14)) {
      if (((dep_path)[di] !=(path_driver)[di])) {
        (void)((ok_path = 0));
        break;
      }
      (void)((di = (di + 1)));
    }
    if ((di ==14)) {
      (void)((ok_path = 1));
    }
    if ((ok_path ==0)) {
      (void)((di = 0));
      while ((di < 7)) {
        if (((dep_path)[di] !=(path_io)[di])) {
          (void)((ok_path = 0));
          break;
        }
        (void)((di = (di + 1)));
      }
      if ((di ==7)) {
        (void)((ok_path = 1));
      }
    }
    if (((ok_path !=0) && (name !=((uint8_t *)(0))))) {
      if ((((name_len ==19) || (name_len ==20)) && (codegen_name_bytes_prefix_eq(name, name_len, &((nm_len19)[0]), 19) !=0))) {
        return 1;
      }
      if ((((name_len ==19) || (name_len ==20)) && (codegen_name_bytes_prefix_eq(name, name_len, &((nm_gen19)[0]), 19) !=0))) {
        return 1;
      }
      if ((((name_len ==15) || (name_len ==16)) && (codegen_name_bytes_prefix_eq(name, name_len, &((nm_len15)[0]), 15) !=0))) {
        return 1;
      }
    }
  }
  uint8_t pref_abi14[14] = {115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95};
  if (((((prefix !=((uint8_t *)(0))) && (prefix_len ==14)) && (name !=((uint8_t *)(0)))) && (codegen_name_bytes_prefix_eq(prefix, prefix_len, &((pref_abi14)[0]), 14) !=0))) {
    if ((codegen_is_std_io_driver_bridge_name(name, name_len) !=0)) {
      return 1;
    }
  }
  if (((dep_path !=((uint8_t *)(0))) && (name !=((uint8_t *)(0))))) {
    int32_t ok_drv_only = 0;
    (void)((di = 0));
    while ((di < 14)) {
      if (((dep_path)[di] !=(path_driver)[di])) {
        (void)((ok_drv_only = 0));
        break;
      }
      (void)((di = (di + 1)));
    }
    if ((di ==14)) {
      (void)((ok_drv_only = 1));
    }
    if (((ok_drv_only !=0) && (codegen_is_std_io_driver_bridge_name(name, name_len) !=0))) {
      return 1;
    }
  }
  if (((((prefix !=((uint8_t *)(0))) && (prefix_len ==14)) && (name !=((uint8_t *)(0)))) && (codegen_name_bytes_prefix_eq(prefix, prefix_len, &((pref_abi14)[0]), 14) !=0))) {
    if ((codegen_should_skip_emit_std_io_trivial_handle(((uint8_t *)(0)), name, name_len) !=0)) {
      return 1;
    }
  }
  if (((dep_path !=((uint8_t *)(0))) && (name !=((uint8_t *)(0))))) {
    uint8_t path_driver[14] = {115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0};
    int32_t di2 = 0;
    if ((codegen_should_skip_emit_std_io_core_io_dup(dep_path, name, name_len) !=0)) {
      return 1;
    }
    while ((di2 < 14)) {
      if (((dep_path)[di2] !=(path_driver)[di2])) {
        break;
      }
      (void)((di2 = (di2 + 1)));
    }
    if (((di2 ==14) && (codegen_should_skip_emit_std_io_trivial_handle(((uint8_t *)(0)), name, name_len) !=0))) {
      return 1;
    }
  }
  return 0;
}
int32_t codegen_force_param_std_io_driver_prefix_ok(uint8_t * prefix, int32_t prefix_len) {
  uint8_t exp13[13] = {115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114};
  if (((prefix ==((uint8_t *)(0))) || (prefix_len < 13))) {
    return 0;
  }
  int32_t i = 0;
  while ((i < 13)) {
    if (((prefix)[i] !=(exp13)[i])) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  if ((prefix_len > 13)) {
    uint8_t b14 = (prefix)[13];
    if (((b14 !=((uint8_t)(0))) && (b14 !=((uint8_t)(95))))) {
      return 0;
    }
  }
  return 1;
}
int32_t codegen_force_param_size_t(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index) {
  uint8_t rd_batch[21] = {115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102};
  uint8_t wr_batch[22] = {115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102};
  if ((param_index !=0)) {
    return 0;
  }
  if ((codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) ==0)) {
    return 0;
  }
  if ((name ==((uint8_t *)(0)))) {
    return 0;
  }
  if (((name_len ==21) && (codegen_name_bytes_prefix_eq(name, name_len, &((rd_batch)[0]), 21) !=0))) {
    return 1;
  }
  if (((name_len ==22) && (codegen_name_bytes_prefix_eq(name, name_len, &((wr_batch)[0]), 22) !=0))) {
    return 1;
  }
  return 0;
}
int32_t codegen_force_param_size_t_std_io_print_str_second(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index) {
  if ((param_index !=1)) {
    return 0;
  }
  if (((name ==((uint8_t *)(0))) || (name_len !=5))) {
    return 0;
  }
  if (((((((name)[0] !=112) || ((name)[1] !=114)) || ((name)[2] !=105)) || ((name)[3] !=110)) || ((name)[4] !=116))) {
    return 0;
  }
  uint8_t exp7[7] = {115, 116, 100, 95, 105, 111, 95};
  if (((prefix ==((uint8_t *)(0))) || (prefix_len < 7))) {
    return 0;
  }
  int32_t i = 0;
  while ((i < 7)) {
    if (((prefix)[i] !=(exp7)[i])) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
int32_t codegen_force_param_ptrdiff_t(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index) {
  uint8_t reg8[8] = {114, 101, 103, 105, 115, 116, 101, 114};
  uint8_t rd11[11] = {115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100};
  uint8_t wr12[12] = {115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101};
  if ((param_index !=0)) {
    return 0;
  }
  if ((codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) ==0)) {
    return 0;
  }
  if ((name ==((uint8_t *)(0)))) {
    return 0;
  }
  if (((name_len ==8) && (codegen_name_bytes_prefix_eq(name, name_len, &((reg8)[0]), 8) !=0))) {
    return 1;
  }
  if (((name_len ==11) && (codegen_name_bytes_prefix_eq(name, name_len, &((rd11)[0]), 11) !=0))) {
    return 1;
  }
  if (((name_len ==12) && (codegen_name_bytes_prefix_eq(name, name_len, &((wr12)[0]), 12) !=0))) {
    return 1;
  }
  return 0;
}
int32_t codegen_force_param_uint32_t(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index) {
  uint8_t rd11[11] = {115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100};
  uint8_t wr12[12] = {115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101};
  uint8_t reg_fixed_buf[33] = {115, 117, 98, 109, 105, 116, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 102, 105, 120, 101, 100, 95, 98, 117, 102, 102, 101, 114, 115, 95, 98, 117, 102};
  uint8_t rd_batch[21] = {115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102};
  uint8_t wr_batch[22] = {115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102};
  if ((codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) ==0)) {
    return 0;
  }
  if ((name ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((param_index ==1)) {
    if (((name_len ==11) && (codegen_name_bytes_prefix_eq(name, name_len, &((rd11)[0]), 11) !=0))) {
      return 1;
    }
    if (((name_len ==12) && (codegen_name_bytes_prefix_eq(name, name_len, &((wr12)[0]), 12) !=0))) {
      return 1;
    }
    if (((name_len ==33) && (codegen_name_bytes_prefix_eq(name, name_len, &((reg_fixed_buf)[0]), 33) !=0))) {
      return 1;
    }
    return 0;
  }
  if ((param_index ==3)) {
    if (((name_len ==21) && (codegen_name_bytes_prefix_eq(name, name_len, &((rd_batch)[0]), 21) !=0))) {
      return 1;
    }
    if (((name_len ==22) && (codegen_name_bytes_prefix_eq(name, name_len, &((wr_batch)[0]), 22) !=0))) {
      return 1;
    }
    return 0;
  }
  return 0;
}
int32_t codegen_use_buf_wrapper(uint8_t * name, int32_t name_len, int32_t num_args) {
  uint8_t reg15[15] = {115, 104, 117, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114};
  uint8_t rd18[18] = {115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100};
  uint8_t wr19[19] = {115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101};
  if (((name ==((uint8_t *)(0))) || (name_len <=0))) {
    return 0;
  }
  if ((((num_args ==1) && (name_len ==15)) && (codegen_name_bytes_prefix_eq(name, name_len, &((reg15)[0]), 15) !=0))) {
    return 1;
  }
  if ((((num_args ==2) && (name_len ==18)) && (codegen_name_bytes_prefix_eq(name, name_len, &((rd18)[0]), 18) !=0))) {
    return 1;
  }
  if ((((num_args ==2) && (name_len ==19)) && (codegen_name_bytes_prefix_eq(name, name_len, &((wr19)[0]), 19) !=0))) {
    return 1;
  }
  return 0;
}
int32_t codegen_emit_io_driver_buf_call_name(struct codegen_CodegenOutBuf * out, uint8_t * name, int32_t name_len, int32_t num_args) {
  uint8_t reg8[8] = {114, 101, 103, 105, 115, 116, 101, 114};
  uint8_t rd11[11] = {115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100};
  uint8_t wr12[12] = {115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101};
  uint8_t sym_reg[20] = {115, 104, 117, 120, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 98, 117, 102};
  uint8_t sym_rd[23] = {115, 104, 117, 120, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 117, 102};
  uint8_t sym_wr[24] = {115, 104, 117, 120, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 117, 102};
  if (((name ==((uint8_t *)(0))) || (name_len <=0))) {
    return 0;
  }
  if ((((num_args ==1) && (name_len ==8)) && (codegen_name_bytes_prefix_eq(name, name_len, &((reg8)[0]), 8) !=0))) {
    if ((codegen_emit_bytes_from_ptr(out, &((sym_reg)[0]), 20) !=0)) {
      return -(1);
    }
    return 1;
  }
  if ((((num_args ==2) && (name_len ==11)) && (codegen_name_bytes_prefix_eq(name, name_len, &((rd11)[0]), 11) !=0))) {
    if ((codegen_emit_bytes_from_ptr(out, &((sym_rd)[0]), 23) !=0)) {
      return -(1);
    }
    return 1;
  }
  if ((((num_args ==2) && (name_len ==12)) && (codegen_name_bytes_prefix_eq(name, name_len, &((wr12)[0]), 12) !=0))) {
    if ((codegen_emit_bytes_from_ptr(out, &((sym_wr)[0]), 24) !=0)) {
      return -(1);
    }
    return 1;
  }
  return 0;
}
int32_t codegen_try_emit_std_io_driver_buf_body(struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len) {
  {
    uint8_t fn_local[64] = {};
    int32_t fn_len = 0;
    int32_t nparams = 0;
    uint8_t p0[32] = {98, 117, 102, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    uint8_t p1[32] = {116, 105, 109, 101, 111, 117, 116, 95, 109, 115, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    uint8_t reg8[8] = {114, 101, 103, 105, 115, 116, 101, 114};
    uint8_t rd11[11] = {115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100};
    uint8_t wr12[12] = {115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101};
    uint8_t sym_reg[20] = {115, 104, 117, 120, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 98, 117, 102};
    uint8_t sym_rd[23] = {115, 104, 117, 120, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 117, 102};
    uint8_t sym_wr[24] = {115, 104, 117, 120, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 117, 102};
    uint8_t ret_kw[8] = {32, 32, 114, 101, 116, 117, 114, 110};
    uint8_t close_b[3] = {10, 125, 0};
    if ((codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) ==0)) {
      return 0;
    }
    int32_t p0_len = 3;
    int32_t p1_len = 10;
    (void)(pipeline_module_func_name_copy64(module, fi, &((fn_local)[0])));
    (void)((fn_len = pipeline_module_func_name_len_at(module, fi)));
    (void)((nparams = pipeline_module_func_num_params_at(module, fi)));
    if ((pipeline_module_func_param_name_len_at(module, fi, 0) > 0)) {
      (void)(pipeline_module_func_param_name_copy32(module, fi, 0, &((p0)[0])));
      (void)((p0_len = pipeline_module_func_param_name_len_at(module, fi, 0)));
    }
    if (((nparams > 1) && (pipeline_module_func_param_name_len_at(module, fi, 1) > 0))) {
      (void)(pipeline_module_func_param_name_copy32(module, fi, 1, &((p1)[0])));
      (void)((p1_len = pipeline_module_func_param_name_len_at(module, fi, 1)));
    }
    if ((((fn_len ==8) && (codegen_name_bytes_prefix_eq(&((fn_local)[0]), fn_len, &((reg8)[0]), 8) !=0)) && (nparams ==1))) {
      if ((codegen_emit_indent(out, 2) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((ret_kw)[0]), 8) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((sym_reg)[0]), 20) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((p0)[0]), p0_len) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 59) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((close_b)[0]), 2) !=0)) {
        return -(1);
      }
      return 1;
    }
    if ((((fn_len ==11) && (codegen_name_bytes_prefix_eq(&((fn_local)[0]), fn_len, &((rd11)[0]), 11) !=0)) && (nparams ==2))) {
      uint8_t comma[3] = {44, 32, 0};
      if ((codegen_emit_indent(out, 2) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((ret_kw)[0]), 8) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((sym_rd)[0]), 23) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((p0)[0]), p0_len) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((p1)[0]), p1_len) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 59) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((close_b)[0]), 2) !=0)) {
        return -(1);
      }
      return 1;
    }
    if ((((fn_len ==12) && (codegen_name_bytes_prefix_eq(&((fn_local)[0]), fn_len, &((wr12)[0]), 12) !=0)) && (nparams ==2))) {
      uint8_t comma2[3] = {44, 32, 0};
      if ((codegen_emit_indent(out, 2) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((ret_kw)[0]), 8) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((sym_wr)[0]), 24) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((p0)[0]), p0_len) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_3(out, comma2, 2) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((p1)[0]), p1_len) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 59) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((close_b)[0]), 2) !=0)) {
        return -(1);
      }
      return 1;
    }
    return 0;
  }
  return 0;
}
int32_t codegen_field_access_base_is_pointer_ref(struct ast_ASTArena * arena, int32_t base_ref) {
  if (((ast_ref_is_null(base_ref) || (base_ref <=0)) || (base_ref > (arena->num_exprs)))) {
    return 0;
  }
  struct ast_Expr base = ast_ast_arena_expr_get(arena, base_ref);
  if (((ast_ref_is_null((base.resolved_type_ref)) || ((base.resolved_type_ref) <=0)) || ((base.resolved_type_ref) > (arena->num_types)))) {
    return 0;
  }
  struct ast_Type ty = ast_ast_arena_type_get(arena, (base.resolved_type_ref));
  if (((ty.kind) ==9)) {
    return 1;
  }
  return 0;
}
int32_t codegen_field_access_base_type_resolved(struct ast_ASTArena * arena, int32_t base_ref) {
  if (((ast_ref_is_null(base_ref) || (base_ref <=0)) || (base_ref > (arena->num_exprs)))) {
    return 0;
  }
  struct ast_Expr base = ast_ast_arena_expr_get(arena, base_ref);
  if (((ast_ref_is_null((base.resolved_type_ref)) || ((base.resolved_type_ref) <=0)) || ((base.resolved_type_ref) > (arena->num_types)))) {
    return 0;
  }
  return 1;
}
/* PLATFORM: SHARED — C mirror of asm glue_asm_try_emit_fmt_string_lit_import_call.
 * METHOD_CALL or CALL+FIELD: fmt/debug print/println("…") → mangled (ptr,i32).
 * Returns 1 emitted, 0 skip, -1 error. Align codegen.x. */
int32_t codegen_try_emit_fmt_string_lit_call(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx) {
  struct ast_Expr e;
  struct ast_Expr callee;
  struct ast_Expr arg;
  int32_t callee_ref;
  int32_t path_len = 0;
  int32_t pre_len;
  int32_t name_len = 0;
  int32_t arg_ref = 0;
  int32_t slen;
  int32_t pi;
  uint8_t path[64];
  uint8_t pre[128];
  uint8_t mid[12] = {95, 117, 56, 95, 112, 116, 114, 95, 105, 51, 50, 0}; /* _u8_ptr_i32 */
  uint8_t comma[3] = {44, 32, 0};
  uint8_t *name_ptr = ((uint8_t *)(0));
  if ((((arena == ((struct ast_ASTArena *)(0))) || (out == ((struct codegen_CodegenOutBuf *)(0)))) || (ctx == ((struct ast_PipelineDepCtx *)(0))))) {
    return 0;
  }
  if (((expr_ref <= 0) || (expr_ref > (arena->num_exprs)))) {
    return 0;
  }
  e = ast_ast_arena_expr_get(arena, expr_ref);
  /* METHOD_CALL=49 (parser default for fmt.println("…")) */
  if (((((e.kind) == 49) && ((e.method_call_num_args) == 1)) && ((e.method_call_name_len) > 0))) {
    name_len = (e.method_call_name_len);
    name_ptr = &((e.method_call_name)[0]);
    path_len = codegen_resolve_binding_import_path_for_method_call(ctx, arena, expr_ref, &((path)[0]));
    arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, 0);
  } else if ((((e.kind) == 48) && ((e.call_num_args) == 1))) {
    /* CALL=48 + FIELD_ACCESS callee */
    callee_ref = (e.call_callee_ref);
    if (((callee_ref <= 0) || (callee_ref > (arena->num_exprs)))) {
      return 0;
    }
    callee = ast_ast_arena_expr_get(arena, callee_ref);
    if ((((callee.kind) != 44) || ((callee.field_access_field_len) <= 0))) {
      return 0;
    }
    name_len = (callee.field_access_field_len);
    name_ptr = &((callee.field_access_field_name)[0]);
    path_len = codegen_resolve_binding_import_path_for_field_access(ctx, arena, callee_ref, &((path)[0]));
    arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
  } else {
    return 0;
  }
  if (name_ptr == ((uint8_t *)(0))) {
    return 0;
  }
  if (((((name_len == 7) && (name_ptr[0] == 112)) && (name_ptr[1] == 114)) && (name_ptr[2] == 105)) && (name_ptr[3] == 110) && (name_ptr[4] == 116) && (name_ptr[5] == 108) && (name_ptr[6] == 110)) {
    /* println */
  } else if (((((name_len == 5) && (name_ptr[0] == 112)) && (name_ptr[1] == 114)) && (name_ptr[2] == 105)) && (name_ptr[3] == 110) && (name_ptr[4] == 116)) {
    /* print */
  } else {
    return 0;
  }
  if ((path_len <= 0)) {
    return 0;
  }
  if (((((((((path_len == 7) && (path[0] == 115)) && (path[1] == 116)) && (path[2] == 100)) && (path[3] == 46)) && (path[4] == 102)) && (path[5] == 109)) && (path[6] == 116))) {
    /* std.fmt */
  } else if (((((((((((path_len == 9) && (path[0] == 115)) && (path[1] == 116)) && (path[2] == 100)) && (path[3] == 46)) && (path[4] == 100)) && (path[5] == 101)) && (path[6] == 98)) && (path[7] == 117)) && (path[8] == 103))) {
    /* std.debug */
  } else {
    return 0;
  }
  if (((arg_ref <= 0) || (arg_ref > (arena->num_exprs)))) {
    return 0;
  }
  if ((pipeline_expr_kind_ord_at(arena, arg_ref) != 59)) {
    return 0;
  }
  arg = ast_ast_arena_expr_get(arena, arg_ref);
  slen = (arg.var_name_len);
  if ((slen < 0)) {
    (void)((slen = 0));
  }
  if ((slen > 64)) {
    (void)((slen = 64));
  }
  codegen_import_path_to_c_prefix_into(&((path)[0]), &((pre)[0]), 128);
  pre_len = 0;
  pi = 0;
  while (((pi < 128) && (pre[pi] != ((uint8_t)(0))))) {
    (void)((pre_len = (pre_len + 1)));
    (void)((pi = (pi + 1)));
  }
  if ((pre_len <= 0)) {
    return 0;
  }
  if ((codegen_emit_bytes_from_ptr(out, &((pre)[0]), pre_len) != 0)) {
    return -1;
  }
  if ((codegen_emit_bytes_from_ptr(out, name_ptr, name_len) != 0)) {
    return -1;
  }
  if ((codegen_emit_bytes_from_ptr(out, &((mid)[0]), 11) != 0)) {
    return -1;
  }
  if ((codegen_append_byte(out, 40) != 0)) {
    return -1;
  }
  if ((codegen_emit_expr(arena, out, arg_ref, ctx) != 0)) {
    return -1;
  }
  if ((codegen_emit_bytes_3(out, comma, 2) != 0)) {
    return -1;
  }
  if ((codegen_format_int(out, (int64_t)slen) != 0)) {
    return -1;
  }
  if ((codegen_append_byte(out, 41) != 0)) {
    return -1;
  }
  return 1;
}
/* PLATFORM: SHARED — call-arg slice ABI: TYPE_SLICE params are pointers (seed/glue).
 * Locals stay by-value → pass &(local); slice params already pointers → pass through.
 * Authority mirror of codegen.x emit_call_arg_slice_abi; only call/method arg positions. */
int32_t codegen_emit_call_arg_slice_abi(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t arg_ref, struct ast_PipelineDepCtx * ctx) {
  {
    struct ast_Expr arg;
    int32_t need_addr = 0;
    if (ast_ref_is_null(arg_ref)) {
      return codegen_append_byte(out, 48);
    }
    arg = ast_ast_arena_expr_get(arena, arg_ref);
    /* EXPR_ADDR_OF=51 — already an address expression */
    if (((arg.kind) ==51)) {
      return codegen_emit_expr(arena, out, arg_ref, ctx);
    }
    /* Slice param of current function → C pointer; do not add &. */
    if ((((ctx !=((struct ast_PipelineDepCtx *)(0))) && ((ctx->current_codegen_module) !=((struct ast_Module *)(0)))) && ((ctx->current_func_index) >=0))) {
      if ((codegen_field_access_base_is_pointer_param(arena, arg_ref, (ctx->current_codegen_module), (ctx->current_func_index)) !=0)) {
        int32_t is_slice_param = 0;
        if ((((arg.kind) ==3) && ((arg.var_name_len) > 0))) {
          struct ast_Module * mod = (ctx->current_codegen_module);
          int32_t fi = (ctx->current_func_index);
          int32_t np = pipeline_module_func_num_params_at(mod, fi);
          int32_t pi = 0;
          while ((pi < np)) {
            int32_t p_name_len = pipeline_module_func_param_name_len_at(mod, fi, pi);
            if (((p_name_len > 0) && (p_name_len ==(arg.var_name_len)))) {
              uint8_t pname_buf[32] = {};
              (void)(pipeline_module_func_param_name_copy32(mod, fi, pi, &((pname_buf)[0])));
              int matched = 1;
              int32_t j = 0;
              while (((j < p_name_len) && (j < 32))) {
                if (((pname_buf)[j] !=((arg.var_name))[j])) {
                  (void)((matched = 0));
                  break;
                }
                (void)((j = (j + 1)));
              }
              if (matched) {
                int32_t param_ty_ref = pipeline_module_func_param_type_ref_at(mod, fi, pi);
                if ((pipeline_type_kind_ord_at(arena, param_ty_ref) ==11)) {
                  (void)((is_slice_param = 1));
                }
              }
            }
            (void)((pi = (pi + 1)));
          }
        }
        if ((is_slice_param !=0)) {
          return codegen_emit_expr(arena, out, arg_ref, ctx);
        }
      }
    }
    /* Local / rvalue TYPE_SLICE → &(arg) for pointer param ABI. */
    if (((!(ast_ref_is_null((arg.resolved_type_ref))) && ((arg.resolved_type_ref) > 0)) && ((arg.resolved_type_ref) <=(arena->num_types)))) {
      struct ast_Type aty = ast_ast_arena_type_get(arena, (arg.resolved_type_ref));
      if (((aty.kind) ==11)) {
        (void)((need_addr = 1));
      }
    }
    if ((((need_addr ==0) && ((arg.kind) ==3)) && (ctx !=((struct ast_PipelineDepCtx *)(0))))) {
      if ((codegen_field_access_base_is_pointer_local(arena, arg_ref, ctx) ==0)) {
        int32_t br = 0;
        if ((((ctx->current_codegen_module) !=((struct ast_Module *)(0))) && ((ctx->current_func_index) >=0))) {
          (void)((br = pipeline_module_func_body_ref_at((ctx->current_codegen_module), (ctx->current_func_index))));
        }
        if (((ast_ref_is_null(br) || (br <=0)) || (br > (arena->num_blocks)))) {
          (void)((br = (ctx->current_block_ref)));
        }
        if (((!(ast_ref_is_null(br)) && (br > 0)) && (br <=(arena->num_blocks)))) {
          int32_t nlets = ast_ast_block_num_lets(arena, br);
          int32_t li = 0;
          while ((li < nlets)) {
            int32_t nl = pipeline_block_let_name_len(arena, br, li);
            if (((nl ==(arg.var_name_len)) && (nl > 0))) {
              uint8_t nb[64] = {};
              (void)(pipeline_block_let_name_copy64(arena, br, li, &((nb)[0])));
              int eq = 1;
              int32_t j2 = 0;
              while (((j2 < nl) && (j2 < 64))) {
                if (((nb)[j2] !=((arg.var_name))[j2])) {
                  (void)((eq = 0));
                  break;
                }
                (void)((j2 = (j2 + 1)));
              }
              if (eq) {
                int32_t tr = pipeline_block_let_type_ref(arena, br, li);
                if ((pipeline_type_kind_ord_at(arena, tr) ==11)) {
                  (void)((need_addr = 1));
                }
              }
            }
            (void)((li = (li + 1)));
          }
        }
      }
    }
    if ((need_addr !=0)) {
      uint8_t pre[3] = {38, 40, 0};
      if ((codegen_emit_bytes_3(out, pre, 2) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, arg_ref, ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    return codegen_emit_expr(arena, out, arg_ref, ctx);
  }
}
int32_t codegen_field_access_base_is_pointer_param(struct ast_ASTArena * arena, int32_t base_ref, struct ast_Module * mod, int32_t func_index) {
  {
    struct ast_Expr base = ast_ast_arena_expr_get(arena, base_ref);
    int32_t np = pipeline_module_func_num_params_at(mod, func_index);
    int32_t pi = 0;
    if (((ast_ref_is_null(base_ref) || (base_ref <=0)) || (base_ref > (arena->num_exprs)))) {
      return 0;
    }
    if ((((mod ==((struct ast_Module *)(0))) || (func_index < 0)) || (func_index >=(mod->num_funcs)))) {
      return 0;
    }
    if ((((base.kind) !=3) || ((base.var_name_len) <=0))) {
      return 0;
    }
    while ((pi < np)) {
      int32_t p_name_len = pipeline_module_func_param_name_len_at(mod, func_index, pi);
      if (((p_name_len > 0) && (p_name_len ==(base.var_name_len)))) {
        uint8_t pname_buf[32] = {};
        (void)(pipeline_module_func_param_name_copy32(mod, func_index, pi, &((pname_buf)[0])));
        int matched = 1;
        int32_t j = 0;
        while (((j < p_name_len) && (j < 32))) {
          if (((pname_buf)[j] !=((base.var_name))[j])) {
            (void)((matched = 0));
            break;
          }
          (void)((j = (j + 1)));
        }
        if (matched) {
          int32_t param_ty_ref = pipeline_module_func_param_type_ref_at(mod, func_index, pi);
          if (((!(ast_ref_is_null(param_ty_ref)) && (param_ty_ref > 0)) && (param_ty_ref <=(arena->num_types)))) {
            struct ast_Type pty = ast_ast_arena_type_get(arena, param_ty_ref);
            /* PLATFORM: SHARED — TYPE_PTR(9) or TYPE_SLICE(11): C params are pointers. */
            if ((((pty.kind) ==9) || ((pty.kind) ==11))) {
              return 1;
            }
          }
        }
      }
      (void)((pi = (pi + 1)));
    }
    return 0;
  }
  return 0;
}
/* PLATFORM: SHARED — local let s:*T fallback when dep co-emit leaves resolved_type empty.
 * Must resolve body/current block ref BEFORE num_lets; computing nlets with br==0 always
 * yields 0 → never match → field access emits '.' instead of '->' (compress gzip/zstd/brotli).
 * Authority mirror: codegen.x field_access_base_is_pointer_local (nlets after br). */
int32_t codegen_field_access_base_is_pointer_local(struct ast_ASTArena * arena, int32_t base_ref, struct ast_PipelineDepCtx * ctx) {
  {
    struct ast_Expr base;
    int32_t br = 0;
    int32_t nlets = 0;
    int32_t li = 0;
    if (((arena ==((struct ast_ASTArena *)(0))) || (ctx ==((struct ast_PipelineDepCtx *)(0))))) {
      return 0;
    }
    if (((ast_ref_is_null(base_ref) || (base_ref <=0)) || (base_ref > (arena->num_exprs)))) {
      return 0;
    }
    base = ast_ast_arena_expr_get(arena, base_ref);
    if ((((base.kind) !=3) || ((base.var_name_len) <=0))) {
      return 0;
    }
    if ((((ctx->current_codegen_module) !=((struct ast_Module *)(0))) && ((ctx->current_func_index) >=0))) {
      (void)((br = pipeline_module_func_body_ref_at((ctx->current_codegen_module), (ctx->current_func_index))));
    }
    if (((ast_ref_is_null(br) || (br <=0)) || (br > (arena->num_blocks)))) {
      (void)((br = (ctx->current_block_ref)));
    }
    if (((ast_ref_is_null(br) || (br <=0)) || (br > (arena->num_blocks)))) {
      return 0;
    }
    /* After br is valid — never call num_lets(arena, 0) above. */
    (void)((nlets = ast_ast_block_num_lets(arena, br)));
    while ((li < nlets)) {
      int32_t nl = pipeline_block_let_name_len(arena, br, li);
      if (((nl ==(base.var_name_len)) && (nl > 0))) {
        uint8_t nb[64] = {};
        (void)(pipeline_block_let_name_copy64(arena, br, li, &((nb)[0])));
        int eq = 1;
        int32_t j = 0;
        while (((j < nl) && (j < 64))) {
          if (((nb)[j] !=((base.var_name))[j])) {
            (void)((eq = 0));
            break;
          }
          (void)((j = (j + 1)));
        }
        if (eq) {
          int32_t tr = pipeline_block_let_type_ref(arena, br, li);
          if (((!(ast_ref_is_null(tr)) && (tr > 0)) && (tr <=(arena->num_types)))) {
            struct ast_Type lty = ast_ast_arena_type_get(arena, tr);
            /* TYPE_PTR = 9 */
            if (((lty.kind) ==9)) {
              return 1;
            }
          }
        }
      }
      (void)((li = (li + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t codegen_field_access_base_param_type_known(struct ast_ASTArena * arena, int32_t base_ref, struct ast_Module * mod, int32_t func_index) {
  {
    struct ast_Expr base = ast_ast_arena_expr_get(arena, base_ref);
    int32_t np = pipeline_module_func_num_params_at(mod, func_index);
    int32_t pi = 0;
    if (((ast_ref_is_null(base_ref) || (base_ref <=0)) || (base_ref > (arena->num_exprs)))) {
      return 0;
    }
    if ((((mod ==((struct ast_Module *)(0))) || (func_index < 0)) || (func_index >=(mod->num_funcs)))) {
      return 0;
    }
    if ((((base.kind) !=3) || ((base.var_name_len) <=0))) {
      return 0;
    }
    while ((pi < np)) {
      int32_t p_name_len = pipeline_module_func_param_name_len_at(mod, func_index, pi);
      if (((p_name_len > 0) && (p_name_len ==(base.var_name_len)))) {
        uint8_t pname_buf[32] = {};
        (void)(pipeline_module_func_param_name_copy32(mod, func_index, pi, &((pname_buf)[0])));
        int matched = 1;
        int32_t j = 0;
        while (((j < p_name_len) && (j < 32))) {
          if (((pname_buf)[j] !=((base.var_name))[j])) {
            (void)((matched = 0));
            break;
          }
          (void)((j = (j + 1)));
        }
        if (matched) {
          int32_t param_ty_ref = pipeline_module_func_param_type_ref_at(mod, func_index, pi);
          if (((!(ast_ref_is_null(param_ty_ref)) && (param_ty_ref > 0)) && (param_ty_ref <=(arena->num_types)))) {
            return 1;
          }
        }
      }
      (void)((pi = (pi + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t codegen_field_access_base_is_slice_param_name(struct ast_ASTArena * arena, int32_t base_ref) {
  if (((ast_ref_is_null(base_ref) || (base_ref <=0)) || (base_ref > (arena->num_exprs)))) {
    return 0;
  }
  struct ast_Expr base = ast_ast_arena_expr_get(arena, base_ref);
  if ((((base.kind) !=3) || ((base.var_name_len) <=0))) {
    return 0;
  }
  if (((base.var_name_len) ==6)) {
    if (((((((((base.var_name))[0] ==115) && (((base.var_name))[1] ==111)) && (((base.var_name))[2] ==117)) && (((base.var_name))[3] ==114)) && (((base.var_name))[4] ==99)) && (((base.var_name))[5] ==101))) {
      return 1;
    }
  }
  if (((base.var_name_len) ==7)) {
    if ((((((((((base.var_name))[0] ==111) && (((base.var_name))[1] ==117)) && (((base.var_name))[2] ==116)) && (((base.var_name))[3] ==95)) && (((base.var_name))[4] ==98)) && (((base.var_name))[5] ==117)) && (((base.var_name))[6] ==102))) {
      return 1;
    }
  }
  if (((((((((base.var_name_len) ==6) && (((base.var_name))[0] ==109)) && (((base.var_name))[1] ==111)) && (((base.var_name))[2] ==100)) && (((base.var_name))[3] ==117)) && (((base.var_name))[4] ==108)) && (((base.var_name))[5] ==101))) {
    return 1;
  }
  if ((((((((base.var_name_len) ==5) && (((base.var_name))[0] ==97)) && (((base.var_name))[1] ==114)) && (((base.var_name))[2] ==101)) && (((base.var_name))[3] ==110)) && (((base.var_name))[4] ==97))) {
    return 1;
  }
  if (((((((((((base.var_name_len) ==8) && (((base.var_name))[0] ==101)) && (((base.var_name))[1] ==108)) && (((base.var_name))[2] ==102)) && (((base.var_name))[3] ==95)) && (((base.var_name))[4] ==99)) && (((base.var_name))[5] ==116)) && (((base.var_name))[6] ==120)) && (((base.var_name))[7] ==120))) {
    return 1;
  }
  if ((((((((((base.var_name_len) ==7) && (((base.var_name))[0] ==99)) && (((base.var_name))[1] ==117)) && (((base.var_name))[2] ==114)) && (((base.var_name))[3] ==95)) && (((base.var_name))[4] ==109)) && (((base.var_name))[5] ==111)) && (((base.var_name))[6] ==100))) {
    return 1;
  }
  if ((((((base.var_name_len) ==3) && (((base.var_name))[0] ==99)) && (((base.var_name))[1] ==116)) && (((base.var_name))[2] ==120))) {
    return 1;
  }
  if ((((((((((base.var_name_len) ==7) && (((base.var_name))[0] ==99)) && (((base.var_name))[1] ==117)) && (((base.var_name))[2] ==114)) && (((base.var_name))[3] ==95)) && (((base.var_name))[4] ==109)) && (((base.var_name))[5] ==111)) && (((base.var_name))[6] ==100))) {
    return 1;
  }
  return 0;
}
int32_t codegen_block_stmt_order_has_let(struct ast_ASTArena * arena, int32_t block_ref, int32_t let_idx) {
  {
    int32_t nso = ast_ast_block_num_stmt_order(arena, block_ref);
    int32_t si = 0;
    while ((si < nso)) {
      if (((pipeline_block_stmt_order_kind(arena, block_ref, si) ==1) && (pipeline_block_stmt_order_idx(arena, block_ref, si) ==let_idx))) {
        return 1;
      }
      (void)((si = (si + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t codegen_c_prefix_redundant_with_name(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len) {
  if (((prefix ==((uint8_t *)(0))) || (name ==((uint8_t *)(0))))) {
    return 0;
  }
  if (((prefix_len <=0) || (name_len < prefix_len))) {
    return 0;
  }
  if ((((((prefix_len ==4) && ((prefix)[0] ==97)) && ((prefix)[1] ==115)) && ((prefix)[2] ==116)) && ((prefix)[3] ==95))) {
    return 0;
  }
  int32_t i = 0;
  while ((i < prefix_len)) {
    if (((name)[i] !=(prefix)[i])) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
int32_t codegen_append_byte(struct codegen_CodegenOutBuf * out, int32_t b) {
  if (((out->len) >=9437184)) {
    return -(1);
  }
  (void)((((out->data))[(out->len)] = ((uint8_t)((b & 255)))));
  (void)(((out->len) = ((out->len) + 1)));
  return 0;
}
int32_t codegen_append_byte_u8(struct codegen_CodegenOutBuf * out, uint8_t b) {
  return codegen_append_byte(out, ((int32_t)(b)));
}
int32_t codegen_emit_bytes_from_ptr(struct codegen_CodegenOutBuf * out, uint8_t * ptr, int32_t len) {
  int32_t i = 0;
  while ((i < len)) {
    if ((codegen_append_byte_u8(out, (ptr)[i]) !=0)) {
      return -(1);
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t codegen_emit_bytes_64(struct codegen_CodegenOutBuf * out, uint8_t * ptr, int32_t len) {
  return codegen_emit_bytes_from_ptr(out, ptr, len);
}
int32_t codegen_emit_bytes_32(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  int32_t i = 0;
  while ((i < len)) {
    if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
      return -(1);
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t codegen_emit_bytes_22(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  int32_t i = 0;
  while ((i < len)) {
    if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
      return -(1);
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t codegen_emit_bytes_9(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  int32_t i = 0;
  while ((i < len)) {
    if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
      return -(1);
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t codegen_emit_bytes_8(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  int32_t i = 0;
  while ((i < len)) {
    if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
      return -(1);
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t codegen_emit_bytes_7(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  int32_t i = 0;
  while ((i < len)) {
    if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
      return -(1);
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t codegen_emit_bytes_6(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  int32_t i = 0;
  while ((i < len)) {
    if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
      return -(1);
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t codegen_emit_bytes_5(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  int32_t i = 0;
  while ((i < len)) {
    if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
      return -(1);
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t codegen_emit_bytes_4(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  int32_t i = 0;
  while ((i < len)) {
    if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
      return -(1);
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t codegen_emit_bytes_3(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  int32_t i = 0;
  while ((i < len)) {
    if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
      return -(1);
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t codegen_emit_bytes_2(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  int32_t i = 0;
  while ((i < len)) {
    if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
      return -(1);
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t codegen_format_uint(struct codegen_CodegenOutBuf * out, int32_t val) {
  if ((val >=10)) {
    int32_t q = (val / 10);
    int32_t r = (val % 10);
    if ((codegen_format_uint(out, q) !=0)) {
      return -(1);
    }
    if ((codegen_append_byte(out, (48 + r)) !=0)) {
      return -(1);
    }
    return 0;
  }
  if ((codegen_append_byte(out, (48 + val)) !=0)) {
    return -(1);
  }
  return 0;
}
int32_t codegen_format_uint64(struct codegen_CodegenOutBuf * out, uint64_t val) {
  if ((val >=((uint64_t)(10)))) {
    uint64_t q = (val / ((uint64_t)(10)));
    uint64_t r = (val % ((uint64_t)(10)));
    if ((codegen_format_uint64(out, q) !=0)) {
      return -(1);
    }
    if ((codegen_append_byte(out, (48 + ((int32_t)(r)))) !=0)) {
      return -(1);
    }
    return 0;
  }
  if ((codegen_append_byte(out, (48 + ((int32_t)(val)))) !=0)) {
    return -(1);
  }
  return 0;
}
int32_t codegen_format_int(struct codegen_CodegenOutBuf * out, int64_t val) {
  if ((val >=0)) {
    return codegen_format_uint64(out, ((uint64_t)(val)));
  }
  int64_t u = (0 - val);
  if ((u < 0)) {
    uint8_t d[20] = {57, 50, 50, 51, 51, 55, 50, 48, 51, 54, 56, 53, 52, 55, 55, 53, 56, 48, 56, 0};
    int32_t i = 0;
    if ((codegen_append_byte(out, 45) !=0)) {
      return -(1);
    }
    while ((i < 19)) {
      if ((codegen_append_byte_u8(out, (d)[i]) !=0)) {
        return -(1);
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
  if ((codegen_append_byte(out, 45) !=0)) {
    return -(1);
  }
  return codegen_format_uint64(out, ((uint64_t)(u)));
}
int32_t codegen_emit_indent(struct codegen_CodegenOutBuf * out, int32_t indent) {
  int32_t i = 0;
  while ((i < indent)) {
    if ((codegen_append_byte(out, 32) !=0)) {
      return -(1);
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t codegen_emit_break_stmt(struct codegen_CodegenOutBuf * out, int32_t indent) {
  if ((codegen_emit_indent(out, indent) !=0)) {
    return -(1);
  }
  uint8_t br[8] = {98, 114, 101, 97, 107, 59, 10, 0};
  return codegen_emit_bytes_8(out, br, 7);
}
int32_t codegen_emit_continue_stmt(struct codegen_CodegenOutBuf * out, int32_t indent) {
  if ((codegen_emit_indent(out, indent) !=0)) {
    return -(1);
  }
  uint8_t co[11] = {99, 111, 110, 116, 105, 110, 117, 101, 59, 10, 0};
  return codegen_emit_bytes_from_ptr(out, &((co)[0]), 10);
}
int32_t codegen_emit_type_kind_ord(struct codegen_CodegenOutBuf * out, int32_t tk) {
  return codegen_emit_type_kind(out, tk);
}
int32_t codegen_emit_type_kind(struct codegen_CodegenOutBuf * out, int32_t kind_ord) {
  if ((kind_ord ==((int32_t)(0)))) {
    uint8_t s[8] = {105, 110, 116, 51, 50, 95, 116, 0};
    return codegen_emit_bytes_8(out, s, 7);
  }
  if ((kind_ord ==((int32_t)(5)))) {
    uint8_t s[8] = {105, 110, 116, 54, 52, 95, 116, 0};
    return codegen_emit_bytes_8(out, s, 7);
  }
  if ((kind_ord ==((int32_t)(1)))) {
    uint8_t s[4] = {105, 110, 116, 0};
    return codegen_emit_bytes_4(out, s, 3);
  }
  if ((kind_ord ==((int32_t)(2)))) {
    uint8_t s[9] = {117, 105, 110, 116, 56, 95, 116, 0, 0};
    return codegen_emit_bytes_9(out, s, 7);
  }
  if ((kind_ord ==((int32_t)(3)))) {
    uint8_t s[9] = {117, 105, 110, 116, 51, 50, 95, 116, 0};
    return codegen_emit_bytes_9(out, s, 8);
  }
  if ((kind_ord ==((int32_t)(4)))) {
    uint8_t s[9] = {117, 105, 110, 116, 54, 52, 95, 116, 0};
    return codegen_emit_bytes_9(out, s, 8);
  }
  if ((kind_ord ==((int32_t)(14)))) {
    uint8_t s[6] = {102, 108, 111, 97, 116, 0};
    return codegen_emit_bytes_6(out, s, 5);
  }
  if ((kind_ord ==((int32_t)(15)))) {
    uint8_t s[7] = {100, 111, 117, 98, 108, 101, 0};
    return codegen_emit_bytes_7(out, s, 6);
  }
  if ((kind_ord ==((int32_t)(16)))) {
    uint8_t s[5] = {118, 111, 105, 100, 0};
    return codegen_emit_bytes_5(out, s, 4);
  }
  if ((kind_ord ==((int32_t)(6)))) {
    uint8_t s[7] = {115, 105, 122, 101, 95, 116, 0};
    return codegen_emit_bytes_7(out, s, 6);
  }
  if ((kind_ord ==((int32_t)(7)))) {
    uint8_t s[8] = {115, 115, 105, 122, 101, 95, 116, 0};
    return codegen_emit_bytes_8(out, s, 7);
  }
  return -(1);
}
int32_t codegen_type_kind_append_to_scratch(uint8_t * scratch, int32_t cap, int32_t w, int32_t kind_ord) {
  if ((kind_ord ==((int32_t)(0)))) {
    uint8_t s[8] = {105, 110, 116, 51, 50, 95, 116, 0};
    int32_t i = 0;
    while ((i < 7)) {
      if ((w >=(cap - 1))) {
        return -(1);
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==((int32_t)(5)))) {
    uint8_t s[8] = {105, 110, 116, 54, 52, 95, 116, 0};
    int32_t i = 0;
    while ((i < 7)) {
      if ((w >=(cap - 1))) {
        return -(1);
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==((int32_t)(1)))) {
    uint8_t s[4] = {105, 110, 116, 0};
    int32_t i = 0;
    while ((i < 3)) {
      if ((w >=(cap - 1))) {
        return -(1);
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==((int32_t)(2)))) {
    uint8_t s[9] = {117, 105, 110, 116, 56, 95, 116, 0, 0};
    int32_t i = 0;
    while ((i < 7)) {
      if ((w >=(cap - 1))) {
        return -(1);
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==((int32_t)(3)))) {
    uint8_t s[9] = {117, 105, 110, 116, 51, 50, 95, 116, 0};
    int32_t i = 0;
    while ((i < 8)) {
      if ((w >=(cap - 1))) {
        return -(1);
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==((int32_t)(4)))) {
    uint8_t s[9] = {117, 105, 110, 116, 54, 52, 95, 116, 0};
    int32_t i = 0;
    while ((i < 8)) {
      if ((w >=(cap - 1))) {
        return -(1);
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==((int32_t)(14)))) {
    uint8_t s[6] = {102, 108, 111, 97, 116, 0};
    int32_t i = 0;
    while ((i < 5)) {
      if ((w >=(cap - 1))) {
        return -(1);
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==((int32_t)(15)))) {
    uint8_t s[7] = {100, 111, 117, 98, 108, 101, 0};
    int32_t i = 0;
    while ((i < 6)) {
      if ((w >=(cap - 1))) {
        return -(1);
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==((int32_t)(16)))) {
    uint8_t s[5] = {118, 111, 105, 100, 0};
    int32_t i = 0;
    while ((i < 4)) {
      if ((w >=(cap - 1))) {
        return -(1);
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==((int32_t)(6)))) {
    uint8_t s[7] = {115, 105, 122, 101, 95, 116, 0};
    int32_t i = 0;
    while ((i < 6)) {
      if ((w >=(cap - 1))) {
        return -(1);
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==((int32_t)(7)))) {
    uint8_t s[8] = {115, 115, 105, 122, 101, 95, 116, 0};
    int32_t i = 0;
    while ((i < 7)) {
      if ((w >=(cap - 1))) {
        return -(1);
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  return -(1);
}
int32_t codegen_emit_vector_c_type_out(struct codegen_CodegenOutBuf * out, int32_t elem_kind_ord, int32_t lanes) {
  if ((elem_kind_ord ==((int32_t)(0)))) {
    if ((lanes ==4)) {
      uint8_t s[8] = {105, 51, 50, 120, 52, 95, 116, 0};
      return codegen_emit_bytes_from_ptr(out, &((s)[0]), 7);
    }
    if ((lanes ==8)) {
      uint8_t s[8] = {105, 51, 50, 120, 56, 95, 116, 0};
      return codegen_emit_bytes_from_ptr(out, &((s)[0]), 7);
    }
    if ((lanes ==16)) {
      uint8_t sa[9] = {105, 51, 50, 120, 49, 54, 95, 116, 0};
      return codegen_emit_bytes_from_ptr(out, &((sa)[0]), 8);
    }
  }
  if ((elem_kind_ord ==((int32_t)(3)))) {
    if ((lanes ==4)) {
      uint8_t s[8] = {117, 51, 50, 120, 52, 95, 116, 0};
      return codegen_emit_bytes_from_ptr(out, &((s)[0]), 7);
    }
    if ((lanes ==8)) {
      uint8_t s[8] = {117, 51, 50, 120, 56, 95, 116, 0};
      return codegen_emit_bytes_from_ptr(out, &((s)[0]), 7);
    }
    if ((lanes ==16)) {
      uint8_t sa[9] = {117, 51, 50, 120, 49, 54, 95, 116, 0};
      return codegen_emit_bytes_from_ptr(out, &((sa)[0]), 8);
    }
  }
  /* F32 vector: "f32x4_t" / "f32x8_t" / "f32x16_t". elem_kind_ord==14 == TYPE_F32.
   * Without this branch, Vec4f falls through to the int32_t default and
   * collides with Vec8i (i32x8_t) overloads. Mirrors codegen.x emit_vector_c_type_out.
   * PLATFORM: SHARED. Manually mirrored because shux-c -E-extern hangs on macOS. */
  if ((elem_kind_ord ==((int32_t)(14)))) {
    if ((lanes ==4)) {
      uint8_t s[8] = {102, 51, 50, 120, 52, 95, 116, 0};
      return codegen_emit_bytes_from_ptr(out, &((s)[0]), 7);
    }
    if ((lanes ==8)) {
      uint8_t s[8] = {102, 51, 50, 120, 56, 95, 116, 0};
      return codegen_emit_bytes_from_ptr(out, &((s)[0]), 7);
    }
    if ((lanes ==16)) {
      uint8_t sa[9] = {102, 51, 50, 120, 49, 54, 95, 116, 0};
      return codegen_emit_bytes_from_ptr(out, &((sa)[0]), 8);
    }
  }
  uint8_t df[8] = {105, 110, 116, 51, 50, 95, 116, 0};
  return codegen_emit_bytes_from_ptr(out, &((df)[0]), 7);
}
int32_t codegen_type_kind_append_to_scratch_ord(uint8_t * scratch, int32_t cap, int32_t w, int32_t tk) {
  int32_t w2 = codegen_type_kind_append_to_scratch(scratch, cap, w, tk);
  if ((w2 < 0)) {
    return codegen_type_kind_append_to_scratch(scratch, cap, w, ((int32_t)(0)));
  }
  return w2;
}
int32_t codegen_type_to_c_repr(struct ast_ASTArena * arena, uint8_t * scratch, int32_t cap, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len) {
  return pipeline_codegen_type_to_c_repr(arena, scratch, cap, type_ref, struct_prefix, struct_prefix_len);
  return 0;
}
int32_t codegen_emit_type(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx) {
  {
    int32_t tk = 0;
    int32_t elem_ref = 0;
    int32_t arr_sz = 0;
    int32_t elem_kind = 0;
    int32_t name_len = 0;
    uint8_t nm[64] = {};
    if (ast_ref_is_null(type_ref)) {
      uint8_t s[8] = {105, 110, 116, 51, 50, 95, 116, 0};
      return codegen_emit_bytes_8(out, s, 7);
    }
    (void)((tk = pipeline_type_kind_ord_at(arena, type_ref)));
    (void)((elem_ref = pipeline_type_elem_ref_at(arena, type_ref)));
    (void)((arr_sz = pipeline_type_array_size_at(arena, type_ref)));
    if (((tk ==9) && !(ast_ref_is_null(elem_ref)))) {
      if ((codegen_emit_type(arena, out, elem_ref, struct_prefix, struct_prefix_len, ctx) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 32) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 42);
    }
    (void)((name_len = pipeline_type_named_name_into(arena, type_ref, &((nm)[0]))));
    if (((tk ==8) && (name_len > 0))) {
      uint8_t dep_prefix_buf[128] = {};
      int32_t dep_prefix_len = 0;
      if ((((((((name_len ==6) && ((nm)[0] ==66)) && ((nm)[1] ==117)) && ((nm)[2] ==102)) && ((nm)[3] ==102)) && ((nm)[4] ==101)) && ((nm)[5] ==114))) {
        uint8_t io_buf[22] = {115, 116, 114, 117, 99, 116, 32, 115, 116, 100, 95, 105, 111, 95, 66, 117, 102, 102, 101, 114, 0, 0};
        return codegen_emit_bytes_from_ptr(out, &((io_buf)[0]), 20);
      }
      if (((((((((name_len >=8) && ((nm)[0] ==79)) && ((nm)[1] ==112)) && ((nm)[2] ==116)) && ((nm)[3] ==105)) && ((nm)[4] ==111)) && ((nm)[5] ==110)) && ((nm)[6] ==95))) {
        uint8_t opt_head[20] = {115, 116, 114, 117, 99, 116, 32, 99, 111, 114, 101, 95, 111, 112, 116, 105, 111, 110, 95, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((opt_head)[0]), 19) !=0)) {
          return -(1);
        }
        int32_t oi = 0;
        while (((oi < name_len) && (oi < 64))) {
          if ((codegen_append_byte_u8(out, (nm)[oi]) !=0)) {
            return -(1);
          }
          (void)((oi = (oi + 1)));
        }
        return 0;
      }
      if (((((name_len ==3) && ((nm)[0] ==117)) && ((nm)[1] ==49)) && ((nm)[2] ==54))) {
        uint8_t u16_t[9] = {117, 105, 110, 116, 49, 54, 95, 116, 0};
        return codegen_emit_bytes_8(out, u16_t, 8);
      }
      if (((((name_len ==3) && ((nm)[0] ==105)) && ((nm)[1] ==49)) && ((nm)[2] ==54))) {
        uint8_t i16_t[8] = {105, 110, 116, 49, 54, 95, 116, 0};
        return codegen_emit_bytes_8(out, i16_t, 7);
      }
      if ((((name_len ==2) && ((nm)[0] ==105)) && ((nm)[1] ==56))) {
        uint8_t i8_t[7] = {105, 110, 116, 56, 95, 116, 0};
        return codegen_emit_bytes_8(out, i8_t, 6);
      }
      if (((((((name_len ==5) && ((nm)[0] ==105)) && ((nm)[1] ==51)) && ((nm)[2] ==50)) && ((nm)[3] ==120)) && ((nm)[4] ==52))) {
        return codegen_emit_vector_c_type_out(out, ((int32_t)(0)), 4);
      }
      if (((((((name_len ==5) && ((nm)[0] ==105)) && ((nm)[1] ==51)) && ((nm)[2] ==50)) && ((nm)[3] ==120)) && ((nm)[4] ==56))) {
        return codegen_emit_vector_c_type_out(out, ((int32_t)(0)), 8);
      }
      if (((((((name_len ==5) && ((nm)[0] ==117)) && ((nm)[1] ==51)) && ((nm)[2] ==50)) && ((nm)[3] ==120)) && ((nm)[4] ==52))) {
        return codegen_emit_vector_c_type_out(out, ((int32_t)(3)), 4);
      }
      if (((((((name_len ==5) && ((nm)[0] ==117)) && ((nm)[1] ==51)) && ((nm)[2] ==50)) && ((nm)[3] ==120)) && ((nm)[4] ==56))) {
        return codegen_emit_vector_c_type_out(out, ((int32_t)(3)), 8);
      }
      if ((((((((name_len ==6) && ((nm)[0] ==105)) && ((nm)[1] ==51)) && ((nm)[2] ==50)) && ((nm)[3] ==120)) && ((nm)[4] ==49)) && ((nm)[5] ==54))) {
        return codegen_emit_vector_c_type_out(out, ((int32_t)(0)), 16);
      }
      if ((((((((name_len ==6) && ((nm)[0] ==117)) && ((nm)[1] ==51)) && ((nm)[2] ==50)) && ((nm)[3] ==120)) && ((nm)[4] ==49)) && ((nm)[5] ==54))) {
        return codegen_emit_vector_c_type_out(out, ((int32_t)(3)), 16);
      }
      if ((((ctx !=((struct ast_PipelineDepCtx *)(0))) && ((ctx->current_codegen_module) !=((struct ast_Module *)(0)))) && (codegen_type_is_module_user_enum((ctx->current_codegen_module), arena, type_ref) !=0))) {
        uint8_t i32_enum[8] = {105, 110, 116, 51, 50, 95, 116, 0};
        return codegen_emit_bytes_8(out, i32_enum, 7);
      }
      if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
        uint8_t dep_enum_prefix[128] = {};
        int32_t dep_enum_prefix_len = codegen_type_dep_enum_prefix_into(ctx, arena, type_ref, &((dep_enum_prefix)[0]), 128);
        if ((dep_enum_prefix_len > 0)) {
          uint8_t e[8] = {101, 110, 117, 109, 32, 0, 0, 0};
          if ((codegen_emit_bytes_8(out, e, 5) !=0)) {
            return -(1);
          }
          if ((codegen_emit_bytes_from_ptr(out, &((dep_enum_prefix)[0]), dep_enum_prefix_len) !=0)) {
            return -(1);
          }
          int32_t bare_off2 = 0;
          int32_t bi2 = 0;
          while (((bi2 < name_len) && (bi2 < 64))) {
            if (((nm)[bi2] ==46)) {
              (void)((bare_off2 = (bi2 + 1)));
            }
            (void)((bi2 = (bi2 + 1)));
          }
          int32_t ci2 = bare_off2;
          while (((ci2 < name_len) && (ci2 < 64))) {
            if ((codegen_append_byte_u8(out, (nm)[ci2]) !=0)) {
              return -(1);
            }
            (void)((ci2 = (ci2 + 1)));
          }
          return 0;
        }
      }
      uint8_t s[8] = {115, 116, 114, 117, 99, 116, 32, 0};
      if ((codegen_emit_bytes_8(out, s, 7) !=0)) {
        return -(1);
      }
      (void)((dep_prefix_len = codegen_type_dep_struct_prefix_into(ctx, arena, type_ref, &((dep_prefix_buf)[0]), 128)));
      if ((dep_prefix_len ==0)) {
        int32_t qmod_end = 0;
        int qhas_dot = 0;
        int32_t qi = 0;
        while (((qi < name_len) && (qi < 64))) {
          if (((nm)[qi] ==46)) {
            (void)((qhas_dot = 1));
            (void)((qmod_end = qi));
          }
          (void)((qi = (qi + 1)));
        }
        if (((qhas_dot && (qmod_end > 0)) && (qmod_end < 64))) {
          uint8_t mod_path[64] = {};
          int32_t mi = 0;
          while ((mi < qmod_end)) {
            (void)(((mod_path)[mi] = (nm)[mi]));
            (void)((mi = (mi + 1)));
          }
          (void)(((mod_path)[mi] = ((uint8_t)(0))));
          (void)(codegen_import_path_to_c_prefix_into(&((mod_path)[0]), &((dep_prefix_buf)[0]), 128));
          (void)((dep_prefix_len = 0));
          while (((dep_prefix_len < 128) && ((dep_prefix_buf)[dep_prefix_len] !=((uint8_t)(0))))) {
            (void)((dep_prefix_len = (dep_prefix_len + 1)));
          }
        }
      }
      if ((dep_prefix_len > 0)) {
        if ((codegen_emit_bytes_from_ptr(out, &((dep_prefix_buf)[0]), dep_prefix_len) !=0)) {
          return -(1);
        }
      } else {
        if (((struct_prefix !=((uint8_t *)(0))) && (struct_prefix_len > 0))) {
          if ((codegen_emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) !=0)) {
            return -(1);
          }
        } else {
          if ((((ctx !=((struct ast_PipelineDepCtx *)(0))) && ((ctx->current_codegen_module) !=((struct ast_Module *)(0)))) && (codegen_type_is_module_user_struct((ctx->current_codegen_module), arena, type_ref) !=0))) {
            uint8_t cur_pre[128] = {};
            int32_t cur_pre_len = codegen_emit_prefix_len_from_ctx(ctx, &((cur_pre)[0]), 128);
            if (((cur_pre_len > 0) && (codegen_emit_bytes_from_ptr(out, &((cur_pre)[0]), cur_pre_len) !=0))) {
              return -(1);
            }
          } else {
            uint8_t ast_p[4] = {97, 115, 116, 95};
            if ((codegen_emit_bytes_4(out, ast_p, 4) !=0)) {
              return -(1);
            }
          }
        }
      }
      int32_t bare_off = 0;
      int32_t bi = 0;
      while (((bi < name_len) && (bi < 64))) {
        if (((nm)[bi] ==46)) {
          (void)((bare_off = (bi + 1)));
        }
        (void)((bi = (bi + 1)));
      }
      int32_t ci = bare_off;
      while (((ci < name_len) && (ci < 64))) {
        if ((codegen_append_byte_u8(out, (nm)[ci]) !=0)) {
          return -(1);
        }
        (void)((ci = (ci + 1)));
      }
      return 0;
    }
    if (((tk ==10) && !(ast_ref_is_null(elem_ref)))) {
      if ((codegen_emit_type(arena, out, elem_ref, struct_prefix, struct_prefix_len, ctx) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 32) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 42);
    }
    if (((tk ==11) && !(ast_ref_is_null(elem_ref)))) {
      uint8_t slb[256] = {};
      int32_t nl = codegen_type_to_c_repr(arena, &((slb)[0]), 256, type_ref, struct_prefix, struct_prefix_len);
      if ((nl <=0)) {
        return -(1);
      }
      int32_t si = 0;
      while ((si < nl)) {
        if ((codegen_append_byte_u8(out, (slb)[si]) !=0)) {
          return -(1);
        }
        (void)((si = (si + 1)));
      }
      return 0;
    }
    if (((tk ==13) && !(ast_ref_is_null(elem_ref)))) {
      (void)((elem_kind = pipeline_type_kind_ord_at(arena, elem_ref)));
      return codegen_emit_vector_c_type_out(out, elem_kind, arr_sz);
    }
    if (((tk ==12) && !(ast_ref_is_null(elem_ref)))) {
      return codegen_emit_type(arena, out, elem_ref, struct_prefix, struct_prefix_len, ctx);
    }
    return codegen_emit_type_kind_ord(out, tk);
  }
  return 0;
}
int32_t codegen_type_dep_struct_owner_index(struct ast_PipelineDepCtx * ctx, uint8_t * bare_nm, int32_t bare_len) {
  {
    int32_t best_di = -(1);
    int32_t best_export = 0;
    int32_t best_nf = 0;
    int32_t cur = -(1);
    int32_t di = 0;
    int32_t nd = 0;
    if ((((ctx ==((struct ast_PipelineDepCtx *)(0))) || (bare_nm ==((uint8_t *)(0)))) || (bare_len <=0))) {
      return -(1);
    }
    (void)((cur = (ctx->current_codegen_dep_index)));
    (void)((nd = pipeline_dep_ctx_ndep(ctx)));
    while ((di < nd)) {
      struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, di);
      if ((dep_mod !=((struct ast_Module *)(0)))) {
        int32_t li = 0;
        int32_t hit = 0;
        int32_t hit_export = 0;
        int32_t hit_nf = 0;
        while ((li < (dep_mod->num_struct_layouts))) {
          int32_t dep_name_len = pipeline_module_struct_layout_name_len(dep_mod, li);
          if ((dep_name_len ==bare_len)) {
            uint8_t dep_nm[64] = {};
            int eq = 1;
            int32_t j = 0;
            (void)(pipeline_module_struct_layout_name_into(dep_mod, li, &((dep_nm)[0])));
            while (((j < bare_len) && (j < 64))) {
              if (((dep_nm)[j] !=(bare_nm)[j])) {
                (void)((eq = 0));
                break;
              }
              (void)((j = (j + 1)));
            }
            if (eq) {
              (void)((hit = 1));
              (void)((hit_nf = pipeline_module_struct_layout_num_fields(dep_mod, li)));
              if ((pipeline_module_struct_layout_is_export_at(dep_mod, li) !=0)) {
                (void)((hit_export = 1));
              }
              break;
            }
          }
          (void)((li = (li + 1)));
        }
        if ((hit !=0)) {
          /* Empty same-name layouts must not steal ownership (incomplete type). */
          if ((best_di < 0)) {
            (void)((best_di = di));
            (void)((best_export = hit_export));
            (void)((best_nf = hit_nf));
          } else if (((hit_nf > 0) && (best_nf <=0))) {
            (void)((best_di = di));
            (void)((best_export = hit_export));
            (void)((best_nf = hit_nf));
          } else if (((((hit_nf > 0) && (best_nf > 0)) && (hit_export !=0)) && (best_export ==0))) {
            (void)((best_di = di));
            (void)((best_export = 1));
            (void)((best_nf = hit_nf));
          } else if ((((hit_export !=0) && (best_export ==0)) && (hit_nf >=best_nf))) {
            (void)((best_di = di));
            (void)((best_export = 1));
            (void)((best_nf = hit_nf));
          } else if ((((((hit_nf > 0) && (best_nf > 0)) && (hit_export !=0)) && (best_export !=0)) && (di ==cur))) {
            /* Dual true exports (Error): current module owns its own tag. */
            (void)((best_di = di));
            (void)((best_nf = hit_nf));
          } else if ((((((hit_nf > 0) && (best_nf > 0)) && (hit_export ==0)) && (best_export ==0)) && (di > best_di))) {
            /* Non-export competition: prefer later dep (leaf after parent). Token: token over lexer. */
            (void)((best_di = di));
            (void)((best_nf = hit_nf));
          }
        }
      }
      (void)((di = (di + 1)));
    }
    return best_di;
  }
  return 0;
}
int32_t codegen_type_dep_struct_prefix_into(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t type_ref, uint8_t * dst, int32_t dst_cap) {
  {
    int32_t name_len = 0;
    uint8_t ty_nm[64] = {};
    int32_t owner = -(1);
    if ((((((ctx ==((struct ast_PipelineDepCtx *)(0))) || (arena ==((struct ast_ASTArena *)(0)))) || (dst ==((uint8_t *)(0)))) || (dst_cap <=0)) || ast_ref_is_null(type_ref))) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, type_ref) !=8)) {
      return 0;
    }
    (void)((name_len = pipeline_type_named_name_into(arena, type_ref, &((ty_nm)[0]))));
    if ((name_len <=0)) {
      return 0;
    }
    int32_t bare_off = 0;
    int32_t bi = 0;
    while (((bi < name_len) && (bi < 64))) {
      if (((ty_nm)[bi] ==46)) {
        (void)((bare_off = (bi + 1)));
      }
      (void)((bi = (bi + 1)));
    }
    int32_t bare_len = (name_len - bare_off);
    (void)((owner = codegen_type_dep_struct_owner_index(ctx, &((ty_nm)[bare_off]), bare_len)));
    if ((owner >=0)) {
      uint8_t dep_path[64] = {};
      int32_t plen = codegen_dep_import_path_len_at(ctx, owner, &((dep_path)[0]));
      if ((plen > 0)) {
        int32_t out_len = 0;
        (void)(codegen_import_path_to_c_prefix_into(&((dep_path)[0]), dst, dst_cap));
        while (((out_len < dst_cap) && ((dst)[out_len] !=((uint8_t)(0))))) {
          (void)((out_len = (out_len + 1)));
        }
        return out_len;
      }
    }
    return 0;
  }
  return 0;
}
int32_t codegen_type_array_elem_is_u8(struct ast_ASTArena * arena, int32_t type_ref) {
  {
    int32_t inner = 0;
    if (((ast_ref_is_null(type_ref) || (type_ref <=0)) || (type_ref > (arena->num_types)))) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, type_ref) !=10)) {
      return 0;
    }
    (void)((inner = pipeline_type_elem_ref_at(arena, type_ref)));
    if (((ast_ref_is_null(inner) || (inner <=0)) || (inner > (arena->num_types)))) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, inner) ==2)) {
      return 1;
    }
    return 0;
  }
  return 0;
}
int32_t codegen_emit_local_fixed_array_elem_type(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, struct ast_PipelineDepCtx * ctx) {
  {
    int32_t inner = pipeline_type_elem_ref_at(arena, type_ref);
    if ((ast_ref_is_null(inner) || (codegen_emit_type(arena, out, inner, ((uint8_t *)(0)), 0, ctx) !=0))) {
      uint8_t fb[8] = {105, 110, 116, 51, 50, 95, 116, 0};
      return codegen_emit_bytes_8(out, fb, 7);
    }
    return 0;
  }
  return 0;
}
int32_t codegen_emit_local_fixed_array_suffix(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref) {
  {
    int32_t asz = pipeline_type_array_size_at(arena, type_ref);
    if ((codegen_append_byte(out, 91) !=0)) {
      return -(1);
    }
    if ((codegen_format_int(out, asz) !=0)) {
      return -(1);
    }
    return codegen_append_byte(out, 93);
  }
  return 0;
}
int32_t codegen_try_emit_slice_init_from_array_var(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t let_idx, int32_t let_type_ref, int32_t linit_ref) {
  {
    struct ast_Expr init_e = ast_ast_arena_expr_get(arena, linit_ref);
    int32_t arr_sz = 0;
    int32_t li = 0;
    uint8_t d1[9] = {32, 46, 100, 97, 116, 97, 32, 61, 32};
    uint8_t d2[12] = {44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32};
    uint8_t d3[4] = {32, 125, 0, 0};
    if ((ast_ref_is_null(let_type_ref) || (pipeline_type_kind_ord_at(arena, let_type_ref) !=11))) {
      return 0;
    }
    if (((ast_ref_is_null(linit_ref) || (linit_ref <=0)) || (linit_ref > (arena->num_exprs)))) {
      return 0;
    }
    if ((((init_e.kind) !=3) || ((init_e.var_name_len) <=0))) {
      return 0;
    }
    while ((li < let_idx)) {
      int32_t nlen = pipeline_block_let_name_len(arena, block_ref, li);
      if (((nlen ==(init_e.var_name_len)) && (nlen > 0))) {
        int32_t matched = 1;
        uint8_t nb[64] = {};
        (void)(pipeline_block_let_name_copy64(arena, block_ref, li, &((nb)[0])));
        int32_t ci = 0;
        while ((ci < nlen)) {
          if (((nb)[ci] !=((init_e.var_name))[ci])) {
            (void)((matched = 0));
            (void)((ci = nlen));
          } else {
            (void)((ci = (ci + 1)));
          }
        }
        if ((matched !=0)) {
          int32_t tr = pipeline_block_let_type_ref(arena, block_ref, li);
          if ((pipeline_type_kind_ord_at(arena, tr) ==10)) {
            (void)((arr_sz = pipeline_type_array_size_at(arena, tr)));
            (void)((li = let_idx));
          }
        }
      }
      (void)((li = (li + 1)));
    }
    if ((((arr_sz <=0) && !(ast_ref_is_null((init_e.resolved_type_ref)))) && ((init_e.resolved_type_ref) > 0))) {
      if ((pipeline_type_kind_ord_at(arena, (init_e.resolved_type_ref)) ==10)) {
        (void)((arr_sz = pipeline_type_array_size_at(arena, (init_e.resolved_type_ref))));
      }
    }
    if ((arr_sz <=0)) {
      return 0;
    }
    if ((codegen_append_byte(out, 123) !=0)) {
      return -(1);
    }
    if ((codegen_emit_bytes_from_ptr(out, &((d1)[0]), 9) !=0)) {
      return -(1);
    }
    if ((codegen_emit_bytes_64(out, &(((init_e.var_name))[0]), (init_e.var_name_len)) !=0)) {
      return -(1);
    }
    if ((codegen_emit_bytes_from_ptr(out, &((d2)[0]), 12) !=0)) {
      return -(1);
    }
    if ((codegen_format_int(out, arr_sz) !=0)) {
      return -(1);
    }
    if ((codegen_emit_bytes_4(out, d3, 2) !=0)) {
      return -(1);
    }
    return 1;
  }
  return 0;
}
/* PLATFORM: SHARED — STRUCT_LIT array-field type lookup (parser M1 host-cc array-init).
 * Authority mirror of codegen.x codegen_lookup_struct_field_type_ref; same commit. */
int32_t codegen_lookup_struct_field_type_ref(struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, uint8_t * struct_name, int32_t struct_name_len, uint8_t * field_name, int32_t field_name_len) {
  int32_t bare_off = 0;
  int32_t bi = 0;
  int32_t bare_len = 0;
  int32_t flen_use = 0;
  int32_t pass = 0;
  (void)arena;
  if ((((struct_name == ((uint8_t *)(0))) || (struct_name_len <= 0)) || (field_name == ((uint8_t *)(0)))) || (field_name_len <= 0)) {
    return 0;
  }
  while (((bi < struct_name_len) && (bi < 64))) {
    if ((((struct_name)[bi]) == 46)) {
      bare_off = (bi + 1);
    }
    bi = (bi + 1);
  }
  bare_len = (struct_name_len - bare_off);
  if ((bare_len <= 0)) {
    return 0;
  }
  flen_use = field_name_len;
  if ((flen_use > 64)) {
    flen_use = 64;
  }
  while ((pass < 2)) {
    int32_t nmod = 1;
    int32_t mi = 0;
    if ((pass == 1)) {
      if ((ctx == ((struct ast_PipelineDepCtx *)(0)))) {
        break;
      }
      nmod = pipeline_dep_ctx_ndep(ctx);
    }
    while ((mi < nmod)) {
      struct ast_Module * try_mod = ((struct ast_Module *)(0));
      if ((pass == 0)) {
        if (((ctx == ((struct ast_PipelineDepCtx *)(0))) || ((ctx->current_codegen_module) == ((struct ast_Module *)(0))))) {
          mi = (mi + 1);
          continue;
        }
        try_mod = (ctx->current_codegen_module);
      } else {
        try_mod = pipeline_dep_ctx_module_at(ctx, mi);
      }
      if ((try_mod != ((struct ast_Module *)(0)))) {
        int32_t k = 0;
        while ((k < (try_mod->num_struct_layouts))) {
          int32_t snl = pipeline_module_struct_layout_name_len(try_mod, k);
          if (((snl == bare_len) && (snl > 0))) {
            uint8_t snm[64] = {};
            int eq = 1;
            int32_t sj = 0;
            (void)(pipeline_module_struct_layout_name_into(try_mod, k, &((snm)[0])));
            while (((sj < snl) && (sj < 64))) {
              if ((((snm)[sj]) != ((struct_name)[(bare_off + sj)]))) {
                eq = 0;
                break;
              }
              sj = (sj + 1);
            }
            if (eq) {
              int32_t nf = pipeline_module_struct_layout_num_fields(try_mod, k);
              int32_t j = 0;
              while ((j < nf)) {
                int32_t fnl = pipeline_module_struct_layout_field_name_len(try_mod, k, j);
                if (((fnl == flen_use) && (fnl > 0))) {
                  uint8_t fnm[64] = {};
                  int feq = 1;
                  int32_t fj = 0;
                  (void)(pipeline_module_struct_layout_field_name_into(try_mod, k, j, &((fnm)[0])));
                  while (((fj < fnl) && (fj < 64))) {
                    if ((((fnm)[fj]) != ((field_name)[fj]))) {
                      feq = 0;
                      break;
                    }
                    fj = (fj + 1);
                  }
                  if (feq) {
                    return pipeline_module_struct_layout_field_type_ref(try_mod, k, j);
                  }
                }
                j = (j + 1);
              }
            }
          }
          k = (k + 1);
        }
      }
      mi = (mi + 1);
      if ((pass == 0)) {
        break;
      }
    }
    pass = (pass + 1);
  }
  return 0;
}
int32_t codegen_emit_braced_array_lit_init(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t init_ref, struct ast_PipelineDepCtx * ctx) {
  {
    int32_t n = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
    int32_t ai = 0;
    if (((ast_ref_is_null(init_ref) || (init_ref <=0)) || (init_ref > (arena->num_exprs)))) {
      uint8_t z[4] = {123, 32, 48, 0};
      if ((codegen_emit_bytes_4(out, z, 3) !=0)) {
        return -(1);
      }
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, init_ref) !=((int32_t)(46)))) {
      if ((codegen_emit_expr(arena, out, init_ref, ctx) !=0)) {
        return -(1);
      }
      return 0;
    }
    if ((codegen_append_byte(out, 123) !=0)) {
      return -(1);
    }
    while ((ai < n)) {
      if ((ai > 0)) {
        uint8_t comma[3] = {44, 32, 0};
        if ((codegen_emit_bytes_3(out, comma, 2) ==0)) {
          (void)((ai = ai));
        } else {
          return -(1);
        }
      }
      if ((codegen_emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, init_ref, ai), ctx) ==0)) {
        (void)((ai = (ai + 1)));
      } else {
        return -(1);
      }
    }
    if ((codegen_append_byte(out, 125) ==0)) {
      return 0;
    }
    return -(1);
  }
  return 0;
}
int32_t codegen_emit_struct_field_type_via_pipeline(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len) {
  return pipeline_codegen_emit_struct_field_type(arena, out, type_ref, struct_prefix, struct_prefix_len);
  return 0;
}
int32_t codegen_should_skip_emit_struct_layout_for_abi_dup(uint8_t * name, int32_t name_len) {
  if (((name ==((uint8_t *)(0))) || (name_len <=0))) {
    return 0;
  }
  uint8_t nm_buffer[7] = {66, 117, 102, 102, 101, 114, 0};
  uint8_t nm_completion[11] = {67, 111, 109, 112, 108, 101, 116, 105, 111, 110, 0};
  uint8_t nm_async_ctx[13] = {65, 115, 121, 110, 99, 67, 111, 110, 116, 101, 120, 116, 0};
  uint8_t nm_error[6] = {69, 114, 114, 111, 114, 0};
  uint8_t nm_error_chain[11] = {69, 114, 114, 111, 114, 67, 104, 97, 105, 110, 0};
  uint8_t nm_option_us[8] = {79, 112, 116, 105, 111, 110, 95, 0};
  uint8_t nm_option[7] = {79, 112, 116, 105, 111, 110, 0};
  uint8_t nm_result_i32[11] = {82, 101, 115, 117, 108, 116, 95, 105, 51, 50, 0};
  uint8_t nm_result_u8[10] = {82, 101, 115, 117, 108, 116, 95, 117, 56, 0};
  uint8_t nm_string[7] = {83, 116, 114, 105, 110, 103, 0};
  uint8_t nm_str_view[8] = {83, 116, 114, 86, 105, 101, 119, 0};
  uint8_t nm_tcp_stream[10] = {84, 99, 112, 83, 116, 114, 101, 97, 109, 0};
  uint8_t nm_tcp_listener[12] = {84, 99, 112, 76, 105, 115, 116, 101, 110, 101, 114, 0};
  uint8_t nm_udp_socket[10] = {85, 100, 112, 83, 111, 99, 107, 101, 116, 0};
  uint8_t nm_ipv4[9] = {73, 112, 118, 52, 65, 100, 100, 114, 0};
  uint8_t nm_ipv6[9] = {73, 112, 118, 54, 65, 100, 100, 114, 0};
  uint8_t nm_sock_v4[13] = {83, 111, 99, 107, 101, 116, 65, 100, 100, 114, 86, 52, 0};
  if (((name_len ==6) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_buffer)[0]), 6) !=0))) {
    return 1;
  }
  if (((name_len ==10) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_completion)[0]), 10) !=0))) {
    return 1;
  }
  if (((name_len ==12) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_async_ctx)[0]), 12) !=0))) {
    return 1;
  }
  if (((name_len ==5) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_error)[0]), 5) !=0))) {
    return 1;
  }
  if (((name_len ==10) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_error_chain)[0]), 10) !=0))) {
    return 1;
  }
  if (((name_len > 7) && (codegen_symbuf_bytes_eq(name, 7, &((nm_option_us)[0]), 7) !=0))) {
    return 1;
  }
  if (((name_len ==6) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_option)[0]), 6) !=0))) {
    return 1;
  }
  if (((name_len ==10) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_result_i32)[0]), 10) !=0))) {
    return 1;
  }
  if (((name_len ==9) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_result_u8)[0]), 9) !=0))) {
    return 1;
  }
  if (((name_len ==6) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_string)[0]), 6) !=0))) {
    return 1;
  }
  if (((name_len ==7) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_str_view)[0]), 7) !=0))) {
    return 1;
  }
  if (((name_len ==9) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_tcp_stream)[0]), 9) !=0))) {
    return 1;
  }
  if (((name_len ==11) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_tcp_listener)[0]), 11) !=0))) {
    return 1;
  }
  if (((name_len ==9) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_udp_socket)[0]), 9) !=0))) {
    return 1;
  }
  if (((name_len ==8) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_ipv4)[0]), 8) !=0))) {
    return 1;
  }
  if (((name_len ==8) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_ipv6)[0]), 8) !=0))) {
    return 1;
  }
  if (((name_len ==12) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_sock_v4)[0]), 12) !=0))) {
    return 1;
  }
  uint8_t nm_allocator[10] = {65, 108, 108, 111, 99, 97, 116, 111, 114, 0};
  uint8_t nm_arena64[8] = {65, 114, 101, 110, 97, 54, 52, 0};
  uint8_t nm_fs_iovec[11] = {70, 115, 73, 111, 118, 101, 99, 66, 117, 102, 0};
  uint8_t nm_iovec[6] = {73, 111, 118, 101, 99, 0};
  if (((name_len ==9) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_allocator)[0]), 9) !=0))) {
    return 1;
  }
  if (((name_len ==7) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_arena64)[0]), 7) !=0))) {
    return 1;
  }
  if (((name_len ==10) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_fs_iovec)[0]), 10) !=0))) {
    return 1;
  }
  if (((name_len ==5) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_iovec)[0]), 5) !=0))) {
    return 1;
  }
  return 0;
}
int32_t codegen_type_is_module_user_struct(struct ast_Module * module, struct ast_ASTArena * arena, int32_t type_ref) {
  {
    int32_t name_len = 0;
    uint8_t ty_nm[64] = {};
    if ((((module ==((struct ast_Module *)(0))) || (arena ==((struct ast_ASTArena *)(0)))) || ast_ref_is_null(type_ref))) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, type_ref) !=8)) {
      return 0;
    }
    (void)((name_len = pipeline_type_named_name_into(arena, type_ref, &((ty_nm)[0]))));
    if ((name_len <=0)) {
      return 0;
    }
    int32_t k = 0;
    while ((k < (module->num_struct_layouts))) {
      int32_t nl = pipeline_module_struct_layout_name_len(module, k);
      if ((nl ==name_len)) {
        uint8_t lay_nm[64] = {};
        (void)(pipeline_module_struct_layout_name_into(module, k, &((lay_nm)[0])));
        int eq = 1;
        int32_t j = 0;
        while (((j < nl) && (j < 64))) {
          if (((lay_nm)[j] !=(ty_nm)[j])) {
            (void)((eq = 0));
            break;
          }
          (void)((j = (j + 1)));
        }
        if (eq) {
          return 1;
        }
      }
      (void)((k = (k + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t codegen_type_is_module_user_enum(struct ast_Module * module, struct ast_ASTArena * arena, int32_t type_ref) {
  {
    int32_t name_len = 0;
    uint8_t ty_nm[64] = {};
    if ((((module ==((struct ast_Module *)(0))) || (arena ==((struct ast_ASTArena *)(0)))) || ast_ref_is_null(type_ref))) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, type_ref) !=8)) {
      return 0;
    }
    (void)((name_len = pipeline_type_named_name_into(arena, type_ref, &((ty_nm)[0]))));
    if ((name_len <=0)) {
      return 0;
    }
    int32_t ei = 0;
    while ((ei < (module->num_module_enums))) {
      int32_t enl = pipeline_module_enum_name_len(module, ei);
      if ((enl ==name_len)) {
        int eq = 1;
        int32_t j = 0;
        while (((j < name_len) && (j < 64))) {
          if ((pipeline_module_enum_name_byte_at(module, ei, j) !=(ty_nm)[j])) {
            (void)((eq = 0));
            break;
          }
          (void)((j = (j + 1)));
        }
        if (eq) {
          return 1;
        }
      }
      (void)((ei = (ei + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t codegen_type_dep_enum_prefix_into(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t type_ref, uint8_t * dst, int32_t dst_cap) {
  {
    int32_t name_len = 0;
    uint8_t ty_nm[64] = {};
    int32_t di = 0;
    if ((((((ctx ==((struct ast_PipelineDepCtx *)(0))) || (arena ==((struct ast_ASTArena *)(0)))) || (dst ==((uint8_t *)(0)))) || (dst_cap <=0)) || ast_ref_is_null(type_ref))) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, type_ref) !=8)) {
      return 0;
    }
    (void)((name_len = pipeline_type_named_name_into(arena, type_ref, &((ty_nm)[0]))));
    if ((name_len <=0)) {
      return 0;
    }
    int32_t bare_off = 0;
    int32_t bi = 0;
    while (((bi < name_len) && (bi < 64))) {
      if (((ty_nm)[bi] ==46)) {
        (void)((bare_off = (bi + 1)));
      }
      (void)((bi = (bi + 1)));
    }
    int32_t bare_len = (name_len - bare_off);
    (void)((di = 0));
    while ((di < pipeline_dep_ctx_ndep(ctx))) {
      struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, di);
      if ((dep_mod !=((struct ast_Module *)(0)))) {
        int32_t ei = 0;
        while ((ei < (dep_mod->num_module_enums))) {
          int32_t dep_name_len = pipeline_module_enum_name_len(dep_mod, ei);
          if ((dep_name_len ==bare_len)) {
            int eq = 1;
            int32_t j = 0;
            while (((j < bare_len) && (j < 64))) {
              if ((pipeline_module_enum_name_byte_at(dep_mod, ei, j) !=(ty_nm)[(bare_off + j)])) {
                (void)((eq = 0));
                break;
              }
              (void)((j = (j + 1)));
            }
            if (eq) {
              uint8_t dep_path[64] = {};
              int32_t plen = codegen_dep_import_path_len_at(ctx, di, &((dep_path)[0]));
              if ((plen > 0)) {
                int32_t out_len = 0;
                (void)(codegen_import_path_to_c_prefix_into(&((dep_path)[0]), dst, dst_cap));
                while (((out_len < dst_cap) && ((dst)[out_len] !=((uint8_t)(0))))) {
                  (void)((out_len = (out_len + 1)));
                }
                return out_len;
              }
            }
          }
          (void)((ei = (ei + 1)));
        }
      }
      (void)((di = (di + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t codegen_emit_struct_field_decl_x(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * field_name, int32_t field_name_len, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx) {
  {
    int32_t base_ref = type_ref;
    if (((ast_ref_is_null(type_ref) || (field_name ==((uint8_t *)(0)))) || (field_name_len <=0))) {
      return -(1);
    }
    while ((!(ast_ref_is_null(base_ref)) && (pipeline_type_kind_ord_at(arena, base_ref) ==10))) {
      int32_t inner = pipeline_type_elem_ref_at(arena, base_ref);
      if (ast_ref_is_null(inner)) {
        break;
      }
      (void)((base_ref = inner));
    }
    if ((codegen_emit_type(arena, out, base_ref, struct_prefix, struct_prefix_len, ctx) !=0)) {
      return -(1);
    }
    if ((codegen_append_byte(out, 32) !=0)) {
      return -(1);
    }
    if ((codegen_emit_bytes_from_ptr(out, field_name, field_name_len) !=0)) {
      return -(1);
    }
    int32_t dims_ref = type_ref;
    while ((!(ast_ref_is_null(dims_ref)) && (pipeline_type_kind_ord_at(arena, dims_ref) ==10))) {
      uint8_t lbr[2] = {91, 0};
      uint8_t rbr[2] = {93, 0};
      if ((codegen_emit_bytes_2(out, lbr, 1) !=0)) {
        return -(1);
      }
      if ((codegen_format_int(out, pipeline_type_array_size_at(arena, dims_ref)) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_2(out, rbr, 1) !=0)) {
        return -(1);
      }
      (void)((dims_ref = pipeline_type_elem_ref_at(arena, dims_ref)));
    }
    return 0;
  }
  return 0;
}
int32_t codegen_emit_module_struct_definitions(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx) {
  {
    int32_t k = 0;
    int32_t cur_di = -(1);
    if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
      (void)((cur_di = (ctx->current_codegen_dep_index)));
    }
    while ((k < (module->num_struct_layouts))) {
      int32_t nf = pipeline_module_struct_layout_num_fields(module, k);
      int32_t nl = pipeline_module_struct_layout_name_len(module, k);
      if (((nf <=0) || (nl <=0))) {
        (void)((k = (k + 1)));
        continue;
      }
      uint8_t ty_nm[64] = {};
      (void)(pipeline_module_struct_layout_name_into(module, k, &((ty_nm)[0])));
      /* PLATFORM: SHARED — entry + dep: only defining owner emits full layout.
       * Entry must skip dep-owned names (Lexer→parser_Lexer residual: field type_ref=0). */
      if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
        int32_t owner = codegen_type_dep_struct_owner_index(ctx, &((ty_nm)[0]), nl);
        if (((owner >=0) && (owner !=cur_di))) {
          (void)((k = (k + 1)));
          continue;
        }
      }
      if ((codegen_should_skip_emit_struct_layout_for_abi_dup(&((ty_nm)[0]), nl) !=0)) {
        (void)((k = (k + 1)));
        continue;
      }
      uint8_t claim_pfx[128] = {};
      int32_t claim_plen = 0;
      if (((struct_prefix !=((uint8_t *)(0))) && (struct_prefix_len > 0))) {
        int32_t ci = 0;
        (void)((claim_plen = struct_prefix_len));
        if ((claim_plen > 127)) {
          (void)((claim_plen = 127));
        }
        while ((ci < claim_plen)) {
          (void)(((claim_pfx)[ci] = (struct_prefix)[ci]));
          (void)((ci = (ci + 1)));
        }
      } else {
        if (!(((ctx !=((struct ast_PipelineDepCtx *)(0))) && ((ctx->current_codegen_dep_index) < 0)))) {
          (void)(((claim_pfx)[0] = 97));
          (void)(((claim_pfx)[1] = 115));
          (void)(((claim_pfx)[2] = 116));
          (void)(((claim_pfx)[3] = 95));
          (void)((claim_plen = 4));
        }
      }
      if ((pipeline_codegen_struct_tag_try_claim(&((claim_pfx)[0]), claim_plen, &((ty_nm)[0]), nl) ==0)) {
        (void)((k = (k + 1)));
        continue;
      }
      uint8_t hdr_top[8] = {115, 116, 114, 117, 99, 116, 32, 0};
      if ((codegen_emit_bytes_8(out, hdr_top, 7) !=0)) {
        return -(1);
      }
      if (((struct_prefix !=((uint8_t *)(0))) && (struct_prefix_len > 0))) {
        if ((codegen_emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) !=0)) {
          return -(1);
        }
      } else {
        if (((ctx !=((struct ast_PipelineDepCtx *)(0))) && ((ctx->current_codegen_dep_index) < 0))) {
        } else {
          uint8_t ast_top[4] = {97, 115, 116, 95};
          if ((codegen_emit_bytes_4(out, ast_top, 4) !=0)) {
            return -(1);
          }
        }
      }
      if ((codegen_emit_bytes_from_ptr(out, &((ty_nm)[0]), nl) !=0)) {
        return -(1);
      }
      uint8_t br1[4] = {32, 123, 10, 0};
      if ((codegen_emit_bytes_4(out, br1, 3) !=0)) {
        return -(1);
      }
      int32_t j = 0;
      while ((j < nf)) {
        int32_t flen = pipeline_module_struct_layout_field_name_len(module, k, j);
        int32_t ftr = pipeline_module_struct_layout_field_type_ref(module, k, j);
        if ((flen <=0)) {
          (void)((j = (j + 1)));
          continue;
        }
        if ((codegen_emit_indent(out, 2) !=0)) {
          return -(1);
        }
        uint8_t fnm[64] = {};
        (void)(pipeline_module_struct_layout_field_name_into(module, k, j, &((fnm)[0])));
        if ((codegen_emit_struct_field_decl_x(arena, out, ftr, &((fnm)[0]), flen, ((uint8_t *)(0)), 0, ctx) !=0)) {
          return -(1);
        }
        uint8_t semi_nl[3] = {59, 10, 0};
        if ((codegen_emit_bytes_3(out, semi_nl, 2) !=0)) {
          return -(1);
        }
        (void)((j = (j + 1)));
      }
      uint8_t close_ty[4] = {125, 59, 10, 10};
      if ((codegen_emit_bytes_4(out, close_ty, 4) !=0)) {
        return -(1);
      }
      (void)((k = (k + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t codegen_emit_module_struct_forward_declarations(struct ast_Module * module, struct codegen_CodegenOutBuf * out, uint8_t * struct_prefix, int32_t struct_prefix_len) {
  return codegen_emit_module_struct_forward_declarations_ctx(module, out, struct_prefix, struct_prefix_len, ((struct ast_PipelineDepCtx *)(0)));
}
int32_t codegen_emit_module_struct_forward_declarations_ctx(struct ast_Module * module, struct codegen_CodegenOutBuf * out, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx) {
  {
    int32_t k = 0;
    int32_t cur_di = -(1);
    if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
      (void)((cur_di = (ctx->current_codegen_dep_index)));
    }
    while ((k < (module->num_struct_layouts))) {
      int32_t nf = pipeline_module_struct_layout_num_fields(module, k);
      int32_t nl = pipeline_module_struct_layout_name_len(module, k);
      if (((nf <=0) || (nl <=0))) {
        (void)((k = (k + 1)));
        continue;
      }
      uint8_t ty_nm[64] = {};
      (void)(pipeline_module_struct_layout_name_into(module, k, &((ty_nm)[0])));
      /* PLATFORM: SHARED — entry + dep: only defining owner emits full layout.
       * Entry must skip dep-owned names (Lexer→parser_Lexer residual: field type_ref=0). */
      if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
        int32_t owner = codegen_type_dep_struct_owner_index(ctx, &((ty_nm)[0]), nl);
        if (((owner >=0) && (owner !=cur_di))) {
          (void)((k = (k + 1)));
          continue;
        }
      }
      uint8_t hdr[8] = {115, 116, 114, 117, 99, 116, 32, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((hdr)[0]), 7) !=0)) {
        return -(1);
      }
      if (((struct_prefix !=((uint8_t *)(0))) && (struct_prefix_len > 0))) {
        if ((codegen_emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) !=0)) {
          return -(1);
        }
      }
      if ((codegen_emit_bytes_from_ptr(out, &((ty_nm)[0]), nl) !=0)) {
        return -(1);
      }
      uint8_t semi_nl[2] = {59, 10};
      if ((codegen_emit_bytes_from_ptr(out, &((semi_nl)[0]), 2) !=0)) {
        return -(1);
      }
      (void)((k = (k + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t codegen_emit_module_enum_definitions(struct ast_Module * module, struct codegen_CodegenOutBuf * out, uint8_t * enum_prefix, int32_t enum_prefix_len) {
  {
    int32_t ei = 0;
    while ((ei < (module->num_module_enums))) {
      int32_t enl = pipeline_module_enum_name_len(module, ei);
      if ((enl <=0)) {
        (void)((ei = (ei + 1)));
        continue;
      }
      uint8_t enm[64] = {};
      uint8_t hdr[8] = {101, 110, 117, 109, 32, 0, 0, 0};
      uint8_t open[4] = {32, 123, 32, 0};
      uint8_t close[6] = {32, 125, 59, 10, 0, 0};
      uint8_t comma[3] = {44, 32, 0};
      (void)(pipeline_module_enum_name_byte_at(module, ei, 0));
      int32_t nk = 0;
      while (((nk < enl) && (nk < 64))) {
        (void)(((enm)[nk] = pipeline_module_enum_name_byte_at(module, ei, nk)));
        (void)((nk = (nk + 1)));
      }
      uint8_t claim_pfx[128] = {};
      int32_t claim_plen = 0;
      (void)(((claim_pfx)[0] = 101));
      (void)((claim_plen = 1));
      if (((enum_prefix !=((uint8_t *)(0))) && (enum_prefix_len > 0))) {
        int32_t ep = enum_prefix_len;
        if ((ep > 126)) {
          (void)((ep = 126));
        }
        int32_t ei2 = 0;
        while ((ei2 < ep)) {
          (void)(((claim_pfx)[(1 + ei2)] = (enum_prefix)[ei2]));
          (void)((ei2 = (ei2 + 1)));
        }
        (void)((claim_plen = (1 + ep)));
      }
      if ((pipeline_codegen_struct_tag_try_claim(&((claim_pfx)[0]), claim_plen, &((enm)[0]), enl) ==0)) {
        (void)((ei = (ei + 1)));
        continue;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((hdr)[0]), 5) !=0)) {
        return -(1);
      }
      if (((enum_prefix !=((uint8_t *)(0))) && (enum_prefix_len > 0))) {
        if ((codegen_emit_bytes_from_ptr(out, enum_prefix, enum_prefix_len) !=0)) {
          return -(1);
        }
      }
      if ((codegen_emit_bytes_from_ptr(out, &((enm)[0]), enl) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, open, 3) !=0)) {
        return -(1);
      }
      int32_t nv = pipeline_module_enum_num_variants(module, ei);
      int32_t vi = 0;
      while ((vi < nv)) {
        int32_t vlen = pipeline_module_enum_variant_name_len(module, ei, vi);
        uint8_t vnm[64] = {};
        int32_t vk = 0;
        if ((vi > 0)) {
          if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
            return -(1);
          }
        }
        while (((vk < vlen) && (vk < 64))) {
          (void)(((vnm)[vk] = pipeline_module_enum_variant_name_byte_at(module, ei, vi, vk)));
          (void)((vk = (vk + 1)));
        }
        if (((enum_prefix !=((uint8_t *)(0))) && (enum_prefix_len > 0))) {
          if ((codegen_emit_bytes_from_ptr(out, enum_prefix, enum_prefix_len) !=0)) {
            return -(1);
          }
        }
        if ((codegen_emit_bytes_from_ptr(out, &((enm)[0]), enl) !=0)) {
          return -(1);
        }
        if ((codegen_append_byte(out, 95) !=0)) {
          return -(1);
        }
        if (((vlen > 0) && (codegen_emit_bytes_from_ptr(out, &((vnm)[0]), vlen) !=0))) {
          return -(1);
        }
        (void)((vi = (vi + 1)));
      }
      if ((codegen_emit_bytes_from_ptr(out, &((close)[0]), 4) !=0)) {
        return -(1);
      }
      (void)((ei = (ei + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t codegen_emit_skipped_dep_type_definitions(struct ast_PipelineDepCtx * ctx, struct codegen_CodegenOutBuf * out) {
  /* PLATFORM: SHARED — import-first dep type emit (token before lexer) for by-value fields. */
  {
    struct ast_Module * saved_module;
    struct ast_ASTArena * saved_arena;
    int32_t saved_dep_index;
    int32_t saved_prefix_len;
    uint8_t saved_prefix[64] = {};
    int32_t sp = 0;
    int32_t nd;
    int32_t done[64];
    int32_t di_init;
    int32_t remaining = 0;
    int32_t di_count;
    int32_t pass;
    int32_t max_pass;
    if (((ctx ==((struct ast_PipelineDepCtx *)(0))) || (out ==((struct codegen_CodegenOutBuf *)(0))))) {
      return 0;
    }
    saved_module = (ctx->current_codegen_module);
    saved_arena = (ctx->current_codegen_arena);
    saved_dep_index = (ctx->current_codegen_dep_index);
    saved_prefix_len = (ctx->current_codegen_prefix_len);
    while ((sp < 64)) {
      (void)(((saved_prefix)[sp] = ((ctx->current_codegen_prefix_mirror))[sp]));
      (void)((sp = (sp + 1)));
    }
    nd = pipeline_dep_ctx_ndep(ctx);
    di_init = 0;
    while ((di_init < 64)) {
      (void)(((done)[di_init] = 0));
      (void)((di_init = (di_init + 1)));
    }
    di_count = 0;
    while ((di_count < nd)) {
      struct ast_Module * dep_mod0 = pipeline_dep_ctx_module_at(ctx, di_count);
      struct ast_ASTArena * dep_arena0 = pipeline_dep_ctx_arena_at(ctx, di_count);
      uint8_t dep_path0[64] = {};
      int32_t plen0 = codegen_dep_import_path_len_at(ctx, di_count, &((dep_path0)[0]));
      if ((((dep_mod0 !=((struct ast_Module *)(0))) && (dep_arena0 !=((struct ast_ASTArena *)(0)))) && (plen0 > 0))) {
        (void)((remaining = (remaining + 1)));
      } else {
        (void)(((done)[di_count] = 1));
      }
      (void)((di_count = (di_count + 1)));
    }
    pass = 0;
    max_pass = (nd + 2);
    while (((remaining > 0) && (pass < max_pass))) {
      int32_t progressed = 0;
      int32_t di = 0;
      while ((di < nd)) {
        if (((done)[di] !=0)) {
          (void)((di = (di + 1)));
          continue;
        }
        {
          struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, di);
          struct ast_ASTArena * dep_arena = pipeline_dep_ctx_arena_at(ctx, di);
          uint8_t dep_path[64] = {};
          int32_t dep_path_len = codegen_dep_import_path_len_at(ctx, di, &((dep_path)[0]));
          int32_t ready = 1;
          int32_t n_imp;
          int32_t ii;
          int32_t seen_before;
          int32_t pj;
          if ((((dep_mod ==((struct ast_Module *)(0))) || (dep_arena ==((struct ast_ASTArena *)(0)))) || (dep_path_len <=0))) {
            (void)(((done)[di] = 1));
            (void)((di = (di + 1)));
            continue;
          }
          n_imp = codegen_module_num_imports(dep_mod);
          ii = 0;
          while ((ii < n_imp)) {
            uint8_t ipath[64] = {};
            int32_t ilen = codegen_module_import_path_len_at(dep_mod, ii, &((ipath)[0]));
            if ((ilen > 0)) {
              int32_t idi = codegen_find_dep_index_by_path(ctx, &((ipath)[0]), ilen);
              if (((((idi >=0) && (idi < nd)) && (idi !=di)) && ((done)[idi] ==0))) {
                (void)((ready = 0));
                break;
              }
            }
            (void)((ii = (ii + 1)));
          }
          if ((ready ==0)) {
            (void)((di = (di + 1)));
            continue;
          }
          /* Path de-dupe: first *non-empty* registration is authority.
           * Empty earlier same-path slots must not suppress a later real module
           * (parser M1: missing struct ast_* → dual-extern). PLATFORM: SHARED. */
          seen_before = 0;
          pj = 0;
          while ((pj < di)) {
            uint8_t prev_path[64] = {};
            int32_t prev_len = codegen_dep_import_path_len_at(ctx, pj, &((prev_path)[0]));
            if ((prev_len ==dep_path_len)) {
              int eq_prev = 1;
              int32_t pk = 0;
              while (((pk < dep_path_len) && (pk < 64))) {
                if (((prev_path)[pk] !=(dep_path)[pk])) {
                  (void)((eq_prev = 0));
                  break;
                }
                (void)((pk = (pk + 1)));
              }
              if (eq_prev) {
                struct ast_Module * prev_mod = pipeline_dep_ctx_module_at(ctx, pj);
                if ((prev_mod != ((struct ast_Module *)(0))) && ((prev_mod->num_struct_layouts) > 0)) {
                  (void)((seen_before = 1));
                  break;
                }
              }
            }
            (void)((pj = (pj + 1)));
          }
          if ((seen_before ==0)) {
            uint8_t prefix_buf[128] = {};
            int32_t prefix_len = 0;
            int32_t px = 0;
            if ((codegen_path_is_std_io_core_bytes(&((dep_path)[0])) ==0)) {
              (void)(codegen_import_path_to_c_prefix_into(&((dep_path)[0]), &((prefix_buf)[0]), 128));
              while (((prefix_len < 128) && ((prefix_buf)[prefix_len] !=((uint8_t)(0))))) {
                (void)((prefix_len = (prefix_len + 1)));
              }
            }
            (void)(((ctx->current_codegen_module) = dep_mod));
            (void)(((ctx->current_codegen_arena) = dep_arena));
            (void)(((ctx->current_codegen_dep_index) = di));
            (void)(((ctx->current_codegen_prefix_len) = 0));
            while (((px < prefix_len) && (px < 63))) {
              (void)((((ctx->current_codegen_prefix_mirror))[px] = (prefix_buf)[px]));
              (void)((px = (px + 1)));
            }
            (void)((((ctx->current_codegen_prefix_mirror))[px] = ((uint8_t)(0))));
            (void)(((ctx->current_codegen_prefix_len) = px));
            if ((codegen_emit_module_enum_definitions(dep_mod, out, &((prefix_buf)[0]), prefix_len) !=0)) {
              return -(1);
            }
            if ((codegen_emit_module_struct_definitions(dep_mod, dep_arena, out, &((prefix_buf)[0]), prefix_len, ctx) !=0)) {
              return -(1);
            }
          }
          (void)(((done)[di] = 1));
          (void)((remaining = (remaining - 1)));
          (void)((progressed = 1));
          (void)((di = (di + 1)));
        }
      }
      if ((progressed ==0)) {
        int32_t dj = 0;
        while ((dj < nd)) {
          if (((done)[dj] ==0)) {
            struct ast_Module * dep_mod2 = pipeline_dep_ctx_module_at(ctx, dj);
            struct ast_ASTArena * dep_arena2 = pipeline_dep_ctx_arena_at(ctx, dj);
            uint8_t dep_path2[64] = {};
            int32_t plen2 = codegen_dep_import_path_len_at(ctx, dj, &((dep_path2)[0]));
            if ((((dep_mod2 !=((struct ast_Module *)(0))) && (dep_arena2 !=((struct ast_ASTArena *)(0)))) && (plen2 > 0))) {
              uint8_t prefix_buf2[128] = {};
              int32_t prefix_len2 = 0;
              int32_t px2 = 0;
              if ((codegen_path_is_std_io_core_bytes(&((dep_path2)[0])) ==0)) {
                (void)(codegen_import_path_to_c_prefix_into(&((dep_path2)[0]), &((prefix_buf2)[0]), 128));
                while (((prefix_len2 < 128) && ((prefix_buf2)[prefix_len2] !=((uint8_t)(0))))) {
                  (void)((prefix_len2 = (prefix_len2 + 1)));
                }
              }
              (void)(((ctx->current_codegen_module) = dep_mod2));
              (void)(((ctx->current_codegen_arena) = dep_arena2));
              (void)(((ctx->current_codegen_dep_index) = dj));
              while (((px2 < prefix_len2) && (px2 < 63))) {
                (void)((((ctx->current_codegen_prefix_mirror))[px2] = (prefix_buf2)[px2]));
                (void)((px2 = (px2 + 1)));
              }
              (void)((((ctx->current_codegen_prefix_mirror))[px2] = ((uint8_t)(0))));
              (void)(((ctx->current_codegen_prefix_len) = px2));
              if ((codegen_emit_module_enum_definitions(dep_mod2, out, &((prefix_buf2)[0]), prefix_len2) !=0)) {
                return -(1);
              }
              if ((codegen_emit_module_struct_definitions(dep_mod2, dep_arena2, out, &((prefix_buf2)[0]), prefix_len2, ctx) !=0)) {
                return -(1);
              }
            }
            (void)(((done)[dj] = 1));
            (void)((remaining = (remaining - 1)));
          }
          (void)((dj = (dj + 1)));
        }
      }
      (void)((pass = (pass + 1)));
    }
    (void)(((ctx->current_codegen_module) = saved_module));
    (void)(((ctx->current_codegen_arena) = saved_arena));
    (void)(((ctx->current_codegen_dep_index) = saved_dep_index));
    (void)(((ctx->current_codegen_prefix_len) = saved_prefix_len));
    sp = 0;
    while ((sp < 64)) {
      (void)((((ctx->current_codegen_prefix_mirror))[sp] = (saved_prefix)[sp]));
      (void)((sp = (sp + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t codegen_emit_dep_struct_forward_declarations(struct ast_PipelineDepCtx * ctx, struct codegen_CodegenOutBuf * out) {
  {
    int32_t saved_dep_index = (ctx->current_codegen_dep_index);
    int32_t nd = pipeline_dep_ctx_ndep(ctx);
    int32_t di = 0;
    if (((ctx ==((struct ast_PipelineDepCtx *)(0))) || (out ==((struct codegen_CodegenOutBuf *)(0))))) {
      return 0;
    }
    while ((di < nd)) {
      struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, di);
      if ((dep_mod !=((struct ast_Module *)(0)))) {
        uint8_t dep_path[64] = {};
        int32_t dep_path_len = codegen_dep_import_path_len_at(ctx, di, &((dep_path)[0]));
        uint8_t prefix_buf[128] = {};
        int32_t prefix_len = 0;
        if (((dep_path_len > 0) && (codegen_path_is_std_io_core_bytes(&((dep_path)[0])) ==0))) {
          (void)(codegen_import_path_to_c_prefix_into(&((dep_path)[0]), &((prefix_buf)[0]), 128));
          while (((prefix_len < 128) && ((prefix_buf)[prefix_len] !=((uint8_t)(0))))) {
            (void)((prefix_len = (prefix_len + 1)));
          }
        }
        (void)(((ctx->current_codegen_dep_index) = di));
        if ((codegen_emit_module_struct_forward_declarations_ctx(dep_mod, out, &((prefix_buf)[0]), prefix_len, ctx) !=0)) {
          (void)(((ctx->current_codegen_dep_index) = saved_dep_index));
          return -(1);
        }
      }
      (void)((di = (di + 1)));
    }
    (void)(((ctx->current_codegen_dep_index) = saved_dep_index));
    return 0;
  }
  return 0;
}
int32_t codegen_resolve_binding_import_path_for_field_access(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * dst) {
  {
    struct ast_Expr e = ast_ast_arena_expr_get(arena, expr_ref);
    struct ast_Expr base = ast_ast_arena_expr_get(arena, (e.field_access_base_ref));
    struct ast_Module * cur_mod = (ctx->current_codegen_module);
    int32_t j = 0;
    int32_t n_imp = codegen_module_num_imports(cur_mod);
    if (((ctx ==((struct ast_PipelineDepCtx *)(0))) || ((ctx->current_codegen_module) ==((struct ast_Module *)(0))))) {
      return 0;
    }
    if (((((arena ==((struct ast_ASTArena *)(0))) || (dst ==((uint8_t *)(0)))) || (expr_ref <=0)) || (expr_ref > (arena->num_exprs)))) {
      return 0;
    }
    if (((e.kind) !=44)) {
      return 0;
    }
    if ((((e.field_access_base_ref) <=0) || ((e.field_access_base_ref) > (arena->num_exprs)))) {
      return 0;
    }
    if ((((base.kind) !=3) || ((base.var_name_len) <=0))) {
      return 0;
    }
    while ((j < n_imp)) {
      int32_t bind_len = pipeline_module_import_binding_name_len(cur_mod, j);
      int eq = 1;
      int32_t kk = 0;
      if ((pipeline_module_import_kind_at(cur_mod, j) !=1)) {
        (void)((j = (j + 1)));
        continue;
      }
      if ((bind_len !=(base.var_name_len))) {
        (void)((j = (j + 1)));
        continue;
      }
      while ((kk < (base.var_name_len))) {
        if ((((base.var_name))[kk] !=pipeline_module_import_binding_name_byte_at(cur_mod, j, kk))) {
          (void)((eq = 0));
          break;
        }
        (void)((kk = (kk + 1)));
      }
      if (!(eq)) {
        (void)((j = (j + 1)));
        continue;
      }
      return codegen_module_import_path_len_at(cur_mod, j, dst);
    }
    return 0;
  }
  return 0;
}
int32_t codegen_resolve_binding_import_path_for_method_call(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * dst) {
  {
    struct ast_Expr e = ast_ast_arena_expr_get(arena, expr_ref);
    struct ast_Expr base = ast_ast_arena_expr_get(arena, (e.method_call_base_ref));
    struct ast_Module * cur_mod = (ctx->current_codegen_module);
    int32_t j = 0;
    int32_t n_imp = codegen_module_num_imports(cur_mod);
    if (((ctx ==((struct ast_PipelineDepCtx *)(0))) || ((ctx->current_codegen_module) ==((struct ast_Module *)(0))))) {
      return 0;
    }
    if (((((arena ==((struct ast_ASTArena *)(0))) || (dst ==((uint8_t *)(0)))) || (expr_ref <=0)) || (expr_ref > (arena->num_exprs)))) {
      return 0;
    }
    if (((e.kind) !=49)) {
      return 0;
    }
    if ((((e.method_call_base_ref) <=0) || ((e.method_call_base_ref) > (arena->num_exprs)))) {
      return 0;
    }
    if ((((base.kind) !=3) || ((base.var_name_len) <=0))) {
      return 0;
    }
    while ((j < n_imp)) {
      int32_t bind_len = pipeline_module_import_binding_name_len(cur_mod, j);
      int eq = 1;
      int32_t kk = 0;
      if ((pipeline_module_import_kind_at(cur_mod, j) !=1)) {
        (void)((j = (j + 1)));
        continue;
      }
      if ((bind_len !=(base.var_name_len))) {
        (void)((j = (j + 1)));
        continue;
      }
      while ((kk < (base.var_name_len))) {
        if ((((base.var_name))[kk] !=pipeline_module_import_binding_name_byte_at(cur_mod, j, kk))) {
          (void)((eq = 0));
          break;
        }
        (void)((kk = (kk + 1)));
      }
      if (!(eq)) {
        (void)((j = (j + 1)));
        continue;
      }
      return codegen_module_import_path_len_at(cur_mod, j, dst);
    }
    return 0;
  }
  return 0;
}
int32_t codegen_emit_import_module_field_symbol(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx) {
  if ((((ctx ==((struct ast_PipelineDepCtx *)(0))) || (arena ==((struct ast_ASTArena *)(0)))) || (out ==((struct codegen_CodegenOutBuf *)(0))))) {
    return -(1);
  }
  if (((expr_ref <=0) || (expr_ref > (arena->num_exprs)))) {
    return -(1);
  }
  struct ast_Expr e = ast_ast_arena_expr_get(arena, expr_ref);
  uint8_t dep_path[64] = {};
  int32_t dep_path_len = codegen_resolve_binding_import_path_for_field_access(ctx, arena, expr_ref, &((dep_path)[0]));
  if ((((e.kind) !=44) || (dep_path_len <=0))) {
    return -(1);
  }
  uint8_t pre[128] = {};
  (void)(codegen_import_path_to_c_prefix_into(&((dep_path)[0]), &((pre)[0]), 128));
  int32_t plen = 0;
  while (((plen < 128) && ((pre)[plen] !=0))) {
    (void)((plen = (plen + 1)));
  }
  if ((((plen > 0) && (codegen_c_prefix_redundant_with_name(&((pre)[0]), plen, &(((e.field_access_field_name))[0]), (e.field_access_field_len)) ==0)) && (codegen_emit_bytes_from_ptr(out, &((pre)[0]), plen) !=0))) {
    return -(1);
  }
  if ((((e.field_access_field_len) > 0) && (codegen_emit_bytes_from_ptr(out, &(((e.field_access_field_name))[0]), (e.field_access_field_len)) !=0))) {
    return -(1);
  }
  return 0;
}
int32_t codegen_emit_import_module_const_field(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx) {
  {
    struct ast_Expr e = ast_ast_arena_expr_get(arena, expr_ref);
    uint8_t dep_path[64] = {};
    int32_t dep_path_len = codegen_resolve_binding_import_path_for_field_access(ctx, arena, expr_ref, &((dep_path)[0]));
    int32_t dep_ix = codegen_find_dep_index_by_path(ctx, &((dep_path)[0]), dep_path_len);
    struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
    int32_t ti = 0;
    if (((ctx ==((struct ast_PipelineDepCtx *)(0))) || ((ctx->current_codegen_module) ==((struct ast_Module *)(0))))) {
      return -(1);
    }
    if (((expr_ref <=0) || (expr_ref > (arena->num_exprs)))) {
      return -(1);
    }
    if ((((e.kind) !=44) || (dep_path_len <=0))) {
      return -(1);
    }
    if (((dep_ix < 0) || (dep_ix >=pipeline_dep_ctx_ndep(ctx)))) {
      return -(1);
    }
    if ((dep_mod ==((struct ast_Module *)(0)))) {
      return -(1);
    }
    while ((ti < (dep_mod->num_top_level_lets))) {
      int32_t nlen = pipeline_module_top_level_let_name_len(dep_mod, ti);
      int nm_eq = 1;
      int32_t ni = 0;
      if ((pipeline_module_top_level_let_is_const(dep_mod, ti) ==0)) {
        (void)((ti = (ti + 1)));
        continue;
      }
      if ((nlen !=(e.field_access_field_len))) {
        (void)((ti = (ti + 1)));
        continue;
      }
      while ((ni < nlen)) {
        if ((pipeline_module_top_level_let_name_byte_at(dep_mod, ti, ni) !=((e.field_access_field_name))[ni])) {
          (void)((nm_eq = 0));
          break;
        }
        (void)((ni = (ni + 1)));
      }
      if (!(nm_eq)) {
        (void)((ti = (ti + 1)));
        continue;
      }
      return codegen_emit_import_module_field_symbol(arena, out, expr_ref, ctx);
    }
    return -(1);
  }
  return 0;
}
int32_t codegen_emit_expr(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx) {
  {
    struct ast_Expr e = ast_ast_arena_expr_get(arena, expr_ref);
    if (ast_ref_is_null(expr_ref)) {
      return 0;
    }
    if (((expr_ref <=0) || (expr_ref > (arena->num_exprs)))) {
      return 0;
    }
    /* PLATFORM: SHARED — consume typeck CTFE (const_folded_*); not emit optim expand. Skip VAR. */
    if (((e.const_folded_valid) != 0) && (pipeline_expr_kind_ord_at(arena, expr_ref) != 3)) {
      if ((codegen_format_int(out, (int64_t)(e.const_folded_val)) != 0)) {
        return -1;
      }
      return 0;
    }
    /* EXPR_CALL handled below after STRING_LIT / other kinds; string-lit print special is at CALL entry. */
    if ((pipeline_expr_kind_ord_at(arena, expr_ref) ==59)) {
      int32_t slen = (e.var_name_len);
      int emit_slice = 0;
      if ((slen < 0)) {
        (void)((slen = 0));
      }
      if ((slen > 64)) {
        (void)((slen = 64));
      }
      if (((!(ast_ref_is_null((e.resolved_type_ref))) && ((e.resolved_type_ref) > 0)) && ((e.resolved_type_ref) <=(arena->num_types)))) {
        struct ast_Type sty = ast_ast_arena_type_get(arena, (e.resolved_type_ref));
        if (((sty.kind) ==11)) {
          (void)((emit_slice = 1));
        }
      }
      uint8_t cast_open[14] = {40, 40, 117, 105, 110, 116, 56, 95, 116, 32, 42, 41, 34, 0};
      if (emit_slice) {
        uint8_t slice_mid[13] = {41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 40, 0};
        if ((codegen_append_byte(out, 40) !=0)) {
          return -(1);
        }
        if ((codegen_emit_type(arena, out, (e.resolved_type_ref), ((uint8_t *)(0)), 0, ctx) !=0)) {
          return -(1);
        }
        if ((codegen_emit_bytes_from_ptr(out, &((slice_mid)[0]), 12) !=0)) {
          return -(1);
        }
      }
      if ((codegen_emit_bytes_from_ptr(out, &((cast_open)[0]), 13) !=0)) {
        return -(1);
      }
      int32_t si = 0;
      while ((si < slen)) {
        int32_t b = ((int32_t)(((e.var_name))[si]));
        if ((b < 0)) {
          (void)((b = (b + 256)));
        }
        if ((b > 255)) {
          (void)((b = (b & 255)));
        }
        if ((codegen_append_byte(out, 92) !=0)) {
          return -(1);
        }
        if ((codegen_append_byte(out, 120) !=0)) {
          return -(1);
        }
        int32_t hi = (b / 16);
        int32_t lo = (b - (hi * 16));
        uint8_t hex[17] = {48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102, 0};
        if ((codegen_append_byte(out, (hex)[hi]) !=0)) {
          return -(1);
        }
        if ((codegen_append_byte(out, (hex)[lo]) !=0)) {
          return -(1);
        }
        (void)((si = (si + 1)));
      }
      if ((codegen_append_byte(out, 34) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -(1);
      }
      if (emit_slice) {
        uint8_t slice_tail[18] = {32, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((slice_tail)[0]), 13) !=0)) {
          return -(1);
        }
        if ((codegen_format_int(out, slen) !=0)) {
          return -(1);
        }
        if ((codegen_append_byte(out, 32) !=0)) {
          return -(1);
        }
        if ((codegen_append_byte(out, 125) !=0)) {
          return -(1);
        }
        return 0;
      }
      return 0;
    }
    if (((e.kind) ==0)) {
      return codegen_format_int(out, (e.int_val));
    }
    if (((e.kind) ==2)) {
      if (((e.int_val) !=0)) {
        return codegen_append_byte(out, 49);
      }
      return codegen_append_byte(out, 48);
    }
    if (((e.kind) ==3)) {
      uint8_t fallback[3] = {95, 48, 0};
      if ((((e.var_name_len) > 0) && (((e.var_name))[0] > 32))) {
        if (((((((e.var_name_len) ==3) && (((e.var_name))[0] ==109)) && (((e.var_name))[1] ==115)) && (((e.var_name))[2] ==103)) && (ctx !=((struct ast_PipelineDepCtx *)(0))))) {
          int use_l0 = 0;
          if ((((ctx->current_block_ref) !=0) && ((ctx->current_block_ref) <=(arena->num_blocks)))) {
            if (((ast_ast_block_num_lets(arena, (ctx->current_block_ref)) >=1) && (pipeline_block_let_name_len(arena, (ctx->current_block_ref), 0) ==0))) {
              (void)((use_l0 = 1));
            }
          }
          if (use_l0) {
            uint8_t l0[4] = {95, 108, 48, 0};
            return codegen_emit_bytes_4(out, l0, 3);
          }
        }
        return codegen_emit_bytes_64(out, &(((e.var_name))[0]), (e.var_name_len));
      }
      if (((ctx !=((struct ast_PipelineDepCtx *)(0))) && ((ctx->emit_expr_as_callee) !=0))) {
        uint8_t fallback[3] = {95, 48, 0};
        return codegen_emit_bytes_3(out, fallback, 2);
      }
      if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
        if (((ctx->current_func_single_empty_param_index) >=0)) {
          uint8_t place[4] = {95, 112, 48, 0};
          if ((codegen_emit_bytes_4(out, place, 2) !=0)) {
            return -(1);
          }
          return codegen_format_int(out, (ctx->current_func_single_empty_param_index));
        }
        if ((((ctx->current_func_empty_param_count) >=2) && ((ctx->current_emit_empty_var_next_index) < (ctx->current_func_empty_param_count)))) {
          int32_t param_idx = pipeline_dep_ctx_empty_param_at(ctx, (ctx->current_emit_empty_var_next_index));
          uint8_t place[4] = {95, 112, 48, 0};
          if ((codegen_emit_bytes_4(out, place, 2) !=0)) {
            return -(1);
          }
          if ((codegen_format_int(out, param_idx) !=0)) {
            return -(1);
          }
          (void)(((ctx->current_emit_empty_var_next_index) = ((ctx->current_emit_empty_var_next_index) + 1)));
          return 0;
        }
      }
      return codegen_emit_bytes_3(out, fallback, 2);
    }
    if (((e.kind) ==54)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_type(arena, out, (e.as_target_type_ref), ((uint8_t *)(0)), 0, ctx) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((!(ast_ref_is_null((e.as_operand_ref))) && (codegen_emit_expr(arena, out, (e.as_operand_ref), ctx) !=0))) {
        return -(1);
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -(1);
      }
      return 0;
    }
    if (((e.kind) ==41)) {
      uint8_t op[9] = {114, 101, 116, 117, 114, 110, 32, 0, 0};
      if ((codegen_emit_bytes_9(out, op, 7) !=0)) {
        return -(1);
      }
      if ((!(ast_ref_is_null((e.unary_operand_ref))) && (codegen_emit_expr(arena, out, (e.unary_operand_ref), ctx) !=0))) {
        return -(1);
      }
      return 0;
    }
    if (((e.kind) ==26)) {
      uint8_t open[4] = {40, 123, 32, 0};
      if ((codegen_emit_bytes_4(out, open, 3) !=0)) {
        return -(1);
      }
      if ((!(ast_ref_is_null((e.block_ref))) && (codegen_emit_block(arena, out, (e.block_ref), 2, ctx) !=0))) {
        return -(1);
      }
      uint8_t tail[8] = {32, 125, 41, 0, 0, 0, 0, 0};
      return codegen_emit_bytes_8(out, tail, 3);
    }
    if (((e.kind) ==4)) {
      uint8_t op[4] = {32, 43, 32, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, op, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==5)) {
      uint8_t op[4] = {32, 45, 32, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, op, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==28)) {
      uint8_t op[4] = {32, 61, 32, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, op, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if ((((((((((((e.kind) ==29) || ((e.kind) ==30)) || ((e.kind) ==31)) || ((e.kind) ==32)) || ((e.kind) ==33)) || ((e.kind) ==34)) || ((e.kind) ==35)) || ((e.kind) ==36)) || ((e.kind) ==37)) || ((e.kind) ==38))) {
      uint8_t op_buf[8] = {32, 43, 61, 32, 0, 0, 0, 0};
      int32_t op_len = 4;
      if (((e.kind) ==29)) {
        (void)(((op_buf)[1] = 43));
        (void)(((op_buf)[2] = 61));
        (void)((op_len = 4));
      }
      if (((e.kind) ==30)) {
        (void)(((op_buf)[1] = 45));
        (void)(((op_buf)[2] = 61));
        (void)((op_len = 4));
      }
      if (((e.kind) ==31)) {
        (void)(((op_buf)[1] = 42));
        (void)(((op_buf)[2] = 61));
        (void)((op_len = 4));
      }
      if (((e.kind) ==32)) {
        (void)(((op_buf)[1] = 47));
        (void)(((op_buf)[2] = 61));
        (void)((op_len = 4));
      }
      if (((e.kind) ==33)) {
        (void)(((op_buf)[1] = 37));
        (void)(((op_buf)[2] = 61));
        (void)((op_len = 4));
      }
      if (((e.kind) ==34)) {
        (void)(((op_buf)[1] = 38));
        (void)(((op_buf)[2] = 61));
        (void)((op_len = 4));
      }
      if (((e.kind) ==35)) {
        (void)(((op_buf)[1] = 124));
        (void)(((op_buf)[2] = 61));
        (void)((op_len = 4));
      }
      if (((e.kind) ==36)) {
        (void)(((op_buf)[1] = 94));
        (void)(((op_buf)[2] = 61));
        (void)((op_len = 4));
      }
      if (((e.kind) ==37)) {
        (void)(((op_buf)[1] = 60));
        (void)(((op_buf)[2] = 60));
        (void)(((op_buf)[3] = 61));
        (void)(((op_buf)[4] = 32));
        (void)((op_len = 5));
      }
      if (((e.kind) ==38)) {
        (void)(((op_buf)[1] = 62));
        (void)(((op_buf)[2] = 62));
        (void)(((op_buf)[3] = 61));
        (void)(((op_buf)[4] = 32));
        (void)((op_len = 5));
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_8(out, op_buf, op_len) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==22)) {
      uint8_t pre[3] = {45, 40, 0};
      if ((codegen_emit_bytes_3(out, pre, 2) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.unary_operand_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==51)) {
      uint8_t pre_a[3] = {38, 40, 0};
      if ((codegen_emit_bytes_3(out, pre_a, 2) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.unary_operand_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==52)) {
      uint8_t pre_d[3] = {42, 40, 0};
      if ((codegen_emit_bytes_3(out, pre_d, 2) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.unary_operand_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==58)) {
      int32_t op_ref = (e.unary_operand_ref);
      int32_t op_ty_ref = 0;
      uint8_t open[4] = {40, 123, 32, 0};
      uint8_t tmp_name[15] = {95, 95, 115, 104, 117, 120, 95, 116, 114, 121, 95, 116, 109, 112, 0};
      uint8_t assign_mid[5] = {32, 61, 32, 0, 0};
      uint8_t if_open[37] = {59, 32, 105, 102, 32, 40, 40, 95, 95, 115, 104, 117, 120, 95, 116, 114, 121, 95, 116, 109, 112, 41, 46, 101, 114, 114, 32, 33, 61, 32, 48, 41, 32, 123, 32, 114, 101};
      uint8_t turn_mid[39] = {116, 117, 114, 110, 32, 95, 95, 115, 104, 117, 120, 95, 116, 114, 121, 95, 116, 109, 112, 59, 32, 125, 32, 40, 95, 95, 115, 104, 117, 120, 95, 116, 114, 121, 95, 116, 109, 112, 0};
      uint8_t value_tail[7] = {41, 46, 118, 97, 108, 117, 101};
      uint8_t close_tail[4] = {59, 32, 125, 41};
      if (((ast_ref_is_null(op_ref) || (op_ref <=0)) || (op_ref > (arena->num_exprs)))) {
        return -(1);
      }
      (void)((op_ty_ref = pipeline_expr_resolved_type_ref(arena, op_ref)));
      if (ast_ref_is_null(op_ty_ref)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, open, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_type(arena, out, op_ty_ref, ((uint8_t *)(0)), 0, ctx) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 32) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((tmp_name)[0]), 14) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_5(out, assign_mid, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, op_ref, ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((if_open)[0]), 37) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((turn_mid)[0]), 38) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_from_ptr(out, &((value_tail)[0]), 7) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, close_tail, 4) !=0)) {
        return -(1);
      }
      return 0;
    }
    if (((e.kind) ==55)) {
      if ((!(ast_ref_is_null((e.unary_operand_ref))) && (codegen_emit_expr(arena, out, (e.unary_operand_ref), ctx) !=0))) {
        return -(1);
      }
      return 0;
    }
    if ((((e.kind) ==56) || ((e.kind) ==57))) {
      int32_t op_ref = (e.unary_operand_ref);
      int32_t dep_ix = -(1);
      int32_t func_ix = -(1);
      struct ast_Module * target_mod = ((struct ast_Module *)(0));
      int32_t n_args = 0;
      int32_t num_params = 0;
      int32_t ai = 0;
      int32_t op_is_call = 0;
      uint8_t reset_name[25] = {115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 114, 101, 115, 101, 116};
      uint8_t comma[3] = {44, 32, 0};
      if (((ctx ==((struct ast_PipelineDepCtx *)(0))) || ((ctx->current_codegen_module) ==((struct ast_Module *)(0))))) {
        return -(1);
      }
      if (((ast_ref_is_null(op_ref) || (op_ref <=0)) || (op_ref > (arena->num_exprs)))) {
        return -(1);
      }
      struct ast_Expr op = ast_ast_arena_expr_get(arena, op_ref);
      if (((op.kind) ==48)) {
        (void)((op_is_call = 1));
      } else {
        if (((op.kind) !=49)) {
          return -(1);
        }
      }
      if (((((e.kind) ==56) && ((op.kind) ==49)) && (codegen_emit_async_method_call_run(arena, out, op_ref, ctx) ==0))) {
        return 0;
      }
      if ((((op_is_call !=0) && ((op.call_callee_ref) > 0)) && ((op.call_callee_ref) <=(arena->num_exprs)))) {
        struct ast_Expr fast_callee = ast_ast_arena_expr_get(arena, (op.call_callee_ref));
        if ((((fast_callee.kind) ==44) && (codegen_emit_async_binding_import_call(arena, out, op_ref, ctx, (((e.kind) ==57) ? ({   1;
 }) : ({   0;
 }))) ==0))) {
          return 0;
        }
      }
      (void)((dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, op_ref)));
      if (((dep_ix < 0) && (op_is_call !=0))) {
        (void)((dep_ix = codegen_resolve_binding_import_dep_index(ctx, arena, (op.call_callee_ref))));
      }
      if ((dep_ix >=0)) {
        if ((dep_ix >=pipeline_dep_ctx_ndep(ctx))) {
          return -(1);
        }
        (void)((target_mod = pipeline_dep_ctx_module_at(ctx, dep_ix)));
      } else {
        (void)((target_mod = (ctx->current_codegen_module)));
      }
      if ((target_mod !=((struct ast_Module *)(0)))) {
        (void)((func_ix = codegen_resolve_call_target_func_index(arena, target_mod, op_ref)));
      }
      if (((dep_ix >=0) && (((target_mod ==((struct ast_Module *)(0))) || (func_ix < 0)) || (func_ix >=(target_mod->num_funcs))))) {
        return codegen_emit_async_binding_import_call(arena, out, op_ref, ctx, (((e.kind) ==57) ? ({   1;
 }) : ({   0;
 })));
      }
      if ((target_mod ==((struct ast_Module *)(0)))) {
        return -(1);
      }
      if (((func_ix < 0) || (func_ix >=(target_mod->num_funcs)))) {
        return -(1);
      }
      if ((op_is_call !=0)) {
        (void)((n_args = (op.call_num_args)));
      } else {
        (void)((n_args = (op.method_call_num_args)));
      }
      if ((n_args < 0)) {
        return -(1);
      }
      (void)((num_params = pipeline_module_func_num_params_at(target_mod, func_ix)));
      if (((e.kind) ==56)) {
        if ((n_args > 0)) {
          if ((codegen_append_byte(out, 40) !=0)) {
            return -(1);
          }
          if ((codegen_emit_bytes_from_ptr(out, &((reset_name)[0]), 25) !=0)) {
            return -(1);
          }
          if ((codegen_append_byte(out, 40) !=0)) {
            return -(1);
          }
          if ((codegen_append_byte(out, 41) !=0)) {
            return -(1);
          }
          (void)((ai = 0));
          while ((ai < n_args)) {
            int32_t arg_ref = 0;
            int32_t param_type_ref = 0;
            if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
              return -(1);
            }
            if ((op_is_call !=0)) {
              (void)((arg_ref = pipeline_expr_call_arg_ref(arena, op_ref, ai)));
            } else {
              (void)((arg_ref = pipeline_expr_method_call_arg_ref(arena, op_ref, ai)));
            }
            if ((ai < num_params)) {
              (void)((param_type_ref = pipeline_module_func_param_type_ref_at(target_mod, func_ix, ai)));
            }
            if ((codegen_emit_async_run_seed_push_name(out, arena, param_type_ref) !=0)) {
              return -(1);
            }
            if ((codegen_append_byte(out, 40) !=0)) {
              return -(1);
            }
            if ((!(ast_ref_is_null(arg_ref)) && (codegen_emit_expr(arena, out, arg_ref, ctx) !=0))) {
              return -(1);
            }
            if ((codegen_append_byte(out, 41) !=0)) {
              return -(1);
            }
            (void)((ai = (ai + 1)));
          }
          if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
            return -(1);
          }
          if ((codegen_emit_async_sched_call(out, target_mod, func_ix) !=0)) {
            return -(1);
          }
          return codegen_append_byte(out, 41);
        }
        return codegen_emit_async_sched_call(out, target_mod, func_ix);
      }
      if ((n_args > 0)) {
        if ((codegen_append_byte(out, 40) !=0)) {
          return -(1);
        }
        (void)((ai = 0));
        while ((ai < n_args)) {
          int32_t arg_ref2 = 0;
          int32_t param_type_ref2 = 0;
          if (((ai > 0) && (codegen_emit_bytes_3(out, comma, 2) !=0))) {
            return -(1);
          }
          if ((op_is_call !=0)) {
            (void)((arg_ref2 = pipeline_expr_call_arg_ref(arena, op_ref, ai)));
          } else {
            (void)((arg_ref2 = pipeline_expr_method_call_arg_ref(arena, op_ref, ai)));
          }
          if ((ai < num_params)) {
            (void)((param_type_ref2 = pipeline_module_func_param_type_ref_at(target_mod, func_ix, ai)));
          }
          if ((codegen_emit_async_run_seed_push_name(out, arena, param_type_ref2) !=0)) {
            return -(1);
          }
          if ((codegen_append_byte(out, 40) !=0)) {
            return -(1);
          }
          if ((!(ast_ref_is_null(arg_ref2)) && (codegen_emit_expr(arena, out, arg_ref2, ctx) !=0))) {
            return -(1);
          }
          if ((codegen_append_byte(out, 41) !=0)) {
            return -(1);
          }
          (void)((ai = (ai + 1)));
        }
        if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
          return -(1);
        }
        if ((codegen_emit_async_task_submit_call(out, target_mod, func_ix) !=0)) {
          return -(1);
        }
        return codegen_append_byte(out, 41);
      }
      return codegen_emit_async_task_submit_call(out, target_mod, func_ix);
    }
    if (((e.kind) ==25)) {
      uint8_t q[4] = {32, 63, 32, 0};
      uint8_t colon[4] = {32, 58, 32, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((!(ast_ref_is_null((e.if_cond_ref))) && (codegen_emit_expr(arena, out, (e.if_cond_ref), ctx) !=0))) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, q, 3) !=0)) {
        return -(1);
      }
      if ((!(ast_ref_is_null((e.if_then_ref))) && (codegen_emit_expr(arena, out, (e.if_then_ref), ctx) !=0))) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, colon, 3) !=0)) {
        return -(1);
      }
      if (!(ast_ref_is_null((e.if_else_ref)))) {
        if ((codegen_emit_expr(arena, out, (e.if_else_ref), ctx) !=0)) {
          return -(1);
        }
      } else {
        if ((codegen_append_byte(out, 48) !=0)) {
          return -(1);
        }
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==48)) {
      int32_t callee_ref = (e.call_callee_ref);
      /* PLATFORM: SHARED — fmt/debug println("…") single-arg string-lit specialization. */
      if ((ctx != ((struct ast_PipelineDepCtx *)(0)))) {
        int32_t fmt_lit_rc = codegen_try_emit_fmt_string_lit_call(arena, out, expr_ref, ctx);
        if ((fmt_lit_rc < 0)) {
          return -1;
        }
        if ((fmt_lit_rc > 0)) {
          return 0;
        }
      }
      if (((((!(ast_ref_is_null(callee_ref)) && (callee_ref > 0)) && (callee_ref <=(arena->num_exprs))) && (ctx !=((struct ast_PipelineDepCtx *)(0)))) && ((ctx->current_codegen_module) !=((struct ast_Module *)(0))))) {
        uint8_t sym_buf[128] = {};
        int32_t imp_j = -(1);
        int32_t sym_len = pipeline_asm_resolve_whole_import_qualified_symbol_c(arena, (ctx->current_codegen_module), callee_ref, &((sym_buf)[0]), &(imp_j));
        if (((sym_len > 0) && (sym_len < 128))) {
          struct ast_Expr callee_q = ast_ast_arena_expr_get(arena, callee_ref);
          uint8_t * fn_ptr_q = ((uint8_t *)(0));
          int32_t fn_len_q = 0;
          if ((((callee_q.kind) ==44) && ((callee_q.field_access_field_len) > 0))) {
            (void)((fn_ptr_q = &(((callee_q.field_access_field_name))[0])));
            (void)((fn_len_q = (callee_q.field_access_field_len)));
          } else {
            if ((((callee_q.kind) ==3) && ((callee_q.var_name_len) > 0))) {
              (void)((fn_ptr_q = &(((callee_q.var_name))[0])));
              (void)((fn_len_q = (callee_q.var_name_len)));
            }
          }
          struct ast_Module * dep_mod_q = ((struct ast_Module *)(0));
          if (((imp_j >=0) && (imp_j < pipeline_dep_ctx_ndep(ctx)))) {
            (void)((dep_mod_q = pipeline_dep_ctx_module_at(ctx, imp_j)));
          }
          int32_t mangled_emitted = 0;
          if ((((fn_len_q > 0) && (fn_len_q <=sym_len)) && (dep_mod_q !=((struct ast_Module *)(0))))) {
            int32_t pre_len_q = (sym_len - fn_len_q);
            if ((pre_len_q > 0)) {
              if ((codegen_emit_bytes_from_ptr(out, &((sym_buf)[0]), pre_len_q) !=0)) {
                return -(1);
              }
            }
            if ((codegen_emit_call_func_name(out, arena, ctx, expr_ref, dep_mod_q, fn_ptr_q, fn_len_q) !=0)) {
              return -(1);
            }
            (void)((mangled_emitted = 1));
          }
          if ((mangled_emitted ==0)) {
            if ((codegen_emit_bytes_from_ptr(out, &((sym_buf)[0]), sym_len) !=0)) {
              return -(1);
            }
          }
          if ((codegen_append_byte(out, 40) !=0)) {
            return -(1);
          }
          int32_t n_q = (e.call_num_args);
          int32_t ai_q = 0;
          while ((ai_q < n_q)) {
            if ((ai_q > 0)) {
              uint8_t comma_q[3] = {44, 32, 0};
              if ((codegen_emit_bytes_3(out, comma_q, 2) !=0)) {
                return -(1);
              }
            }
            if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai_q))) {
              if ((codegen_append_byte(out, 48) !=0)) {
                return -(1);
              }
            } else {
              if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai_q), ctx) !=0)) {
                return -(1);
              }
            }
            (void)((ai_q = (ai_q + 1)));
          }
          if ((codegen_append_byte(out, 41) !=0)) {
            return -(1);
          }
          return 0;
        }
      }
      if (((((!(ast_ref_is_null(callee_ref)) && (callee_ref > 0)) && (callee_ref <=(arena->num_exprs))) && (ctx !=((struct ast_PipelineDepCtx *)(0)))) && (pipeline_dep_ctx_ndep(ctx) > 0))) {
        int32_t dep_ix_fast = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
        struct ast_Expr callee_fast = ast_ast_arena_expr_get(arena, callee_ref);
        if (((((dep_ix_fast >=0) && (dep_ix_fast < pipeline_dep_ctx_ndep(ctx))) && ((callee_fast.kind) ==44)) && ((callee_fast.field_access_field_len) > 0))) {
          struct ast_Module * dep_mod_chk = pipeline_dep_ctx_module_at(ctx, dep_ix_fast);
          int32_t field_in_dep = 0;
          if ((dep_mod_chk !=((struct ast_Module *)(0)))) {
            int32_t fi_c = 0;
            while ((fi_c < (dep_mod_chk->num_funcs))) {
              int32_t fl = pipeline_module_func_name_len_at(dep_mod_chk, fi_c);
              if (((fl ==(callee_fast.field_access_field_len)) && (fl > 0))) {
                uint8_t fnc[64] = {};
                (void)(pipeline_module_func_name_copy64(dep_mod_chk, fi_c, &((fnc)[0])));
                int32_t eqc = 1;
                int32_t ic = 0;
                while ((ic < fl)) {
                  if (((fnc)[ic] !=((callee_fast.field_access_field_name))[ic])) {
                    (void)((eqc = 0));
                    (void)((ic = fl));
                  } else {
                    (void)((ic = (ic + 1)));
                  }
                }
                if ((eqc !=0)) {
                  (void)((field_in_dep = 1));
                  (void)((fi_c = (dep_mod_chk->num_funcs)));
                } else {
                  (void)((fi_c = (fi_c + 1)));
                }
              } else {
                (void)((fi_c = (fi_c + 1)));
              }
            }
          }
          if ((field_in_dep !=0)) {
            uint8_t dep_path_fast[64] = {};
            (void)(pipeline_dep_ctx_import_path_copy64(ctx, dep_ix_fast, &((dep_path_fast)[0])));
            uint8_t pre_fast[128] = {};
            (void)(codegen_import_path_to_c_prefix_into(&((dep_path_fast)[0]), &((pre_fast)[0]), 128));
            int32_t pre_fast_len = 0;
            while (((pre_fast_len < 128) && ((pre_fast)[pre_fast_len] !=0))) {
              (void)((pre_fast_len = (pre_fast_len + 1)));
            }
            int32_t drv_buf_fast = 0;
            if ((codegen_path_is_std_io_driver_bytes(&((dep_path_fast)[0])) !=0)) {
              (void)((drv_buf_fast = codegen_emit_io_driver_buf_call_name(out, &(((callee_fast.field_access_field_name))[0]), (callee_fast.field_access_field_len), (e.call_num_args))));
              if ((drv_buf_fast < 0)) {
                return -(1);
              }
            }
            if ((drv_buf_fast ==0)) {
              struct ast_Module * dep_mod_fast = pipeline_dep_ctx_module_at(ctx, dep_ix_fast);
              if ((((pre_fast_len > 0) && (codegen_c_prefix_redundant_with_name(&((pre_fast)[0]), pre_fast_len, &(((callee_fast.field_access_field_name))[0]), (callee_fast.field_access_field_len)) ==0)) && (codegen_emit_bytes_from_ptr(out, &((pre_fast)[0]), pre_fast_len) !=0))) {
                return -(1);
              }
              if ((dep_mod_fast ==((struct ast_Module *)(0)))) {
                (void)((dep_mod_fast = (ctx->current_codegen_module)));
              }
              if ((codegen_emit_call_func_name(out, arena, ctx, expr_ref, dep_mod_fast, &(((callee_fast.field_access_field_name))[0]), (callee_fast.field_access_field_len)) !=0)) {
                return -(1);
              }
            }
            if ((codegen_append_byte(out, 40) !=0)) {
              return -(1);
            }
            int32_t ai_fast = 0;
            while ((ai_fast < (e.call_num_args))) {
              if ((ai_fast > 0)) {
                uint8_t comma_fast[3] = {44, 32, 0};
                if ((codegen_emit_bytes_3(out, comma_fast, 2) !=0)) {
                  return -(1);
                }
              }
              if (((drv_buf_fast !=0) && (ai_fast ==0))) {
                uint8_t cast_buf[19] = {40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0};
                if ((codegen_emit_bytes_from_ptr(out, &((cast_buf)[0]), 18) !=0)) {
                  return -(1);
                }
              }
              if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai_fast))) {
                if ((codegen_append_byte(out, 48) !=0)) {
                  return -(1);
                }
              } else {
                if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai_fast), ctx) !=0)) {
                  return -(1);
                }
              }
              (void)((ai_fast = (ai_fast + 1)));
            }
            if ((codegen_append_byte(out, 41) !=0)) {
              return -(1);
            }
            return 0;
          }
        }
      }
      if ((((((!(ast_ref_is_null(callee_ref)) && (callee_ref > 0)) && (callee_ref <=(arena->num_exprs))) && (ctx !=((struct ast_PipelineDepCtx *)(0)))) && (pipeline_dep_ctx_ndep(ctx) > 0)) && ((ctx->current_codegen_module) !=((struct ast_Module *)(0))))) {
        struct ast_Expr callee = ast_ast_arena_expr_get(arena, callee_ref);
        struct ast_Module * cur_mod = (ctx->current_codegen_module);
        if (((((callee.kind) ==44) && ((callee.field_access_base_ref) > 0)) && ((callee.field_access_base_ref) <=(arena->num_exprs)))) {
          struct ast_Expr base = ast_ast_arena_expr_get(arena, (callee.field_access_base_ref));
          if (((((base.kind) ==3) && ((base.var_name_len) > 0)) && ((base.var_name_len) <=63))) {
            int32_t j = 0;
            int32_t nd_bind = pipeline_dep_ctx_ndep(ctx);
            int32_t n_imp = codegen_module_num_imports(cur_mod);
            while (((j < n_imp) && (j < nd_bind))) {
              if ((pipeline_module_import_kind_at(cur_mod, j) ==1)) {
                int32_t bind_len = pipeline_module_import_binding_name_len(cur_mod, j);
                if ((bind_len !=(base.var_name_len))) {
                  (void)((j = (j + 1)));
                  continue;
                }
                int eq = 1;
                int32_t kk = 0;
                while (((kk < (base.var_name_len)) && (kk < 64))) {
                  if ((((base.var_name))[kk] !=pipeline_module_import_binding_name_byte_at(cur_mod, j, kk))) {
                    (void)((eq = 0));
                    break;
                  }
                  (void)((kk = (kk + 1)));
                }
                if (eq) {
                  uint8_t dep_path_bind[64] = {};
                  int32_t dep_path_bind_len = codegen_module_import_path_len_at(cur_mod, j, &((dep_path_bind)[0]));
                  if ((dep_path_bind_len <=0)) {
                    (void)((j = (j + 1)));
                    continue;
                  }
                  int32_t dep_ix_bind = codegen_find_dep_index_by_path(ctx, &((dep_path_bind)[0]), dep_path_bind_len);
                  struct ast_Module * dep_mod_bind = cur_mod;
                  if (((dep_ix_bind >=0) && (dep_ix_bind < pipeline_dep_ctx_ndep(ctx)))) {
                    (void)((dep_mod_bind = pipeline_dep_ctx_module_at(ctx, dep_ix_bind)));
                  }
                  uint8_t pre_buf[128] = {};
                  (void)(codegen_import_path_to_c_prefix_into(&((dep_path_bind)[0]), &((pre_buf)[0]), 128));
                  int32_t pre_len = 0;
                  while (((pre_len < 128) && ((pre_buf)[pre_len] !=0))) {
                    (void)((pre_len = (pre_len + 1)));
                  }
                  int32_t drv_buf_bind = 0;
                  if ((codegen_path_is_std_io_driver_bytes(&((dep_path_bind)[0])) !=0)) {
                    (void)((drv_buf_bind = codegen_emit_io_driver_buf_call_name(out, &(((callee.field_access_field_name))[0]), (callee.field_access_field_len), (e.call_num_args))));
                    if ((drv_buf_bind < 0)) {
                      return -(1);
                    }
                  }
                  if ((drv_buf_bind ==0)) {
                    int32_t bind_pre = pre_len;
                    if (((dep_mod_bind !=((struct ast_Module *)(0))) && ((callee.field_access_field_len) > 0))) {
                      int32_t fi_b = 0;
                      while ((fi_b < (dep_mod_bind->num_funcs))) {
                        int32_t fl = pipeline_module_func_name_len_at(dep_mod_bind, fi_b);
                        if (((fl ==(callee.field_access_field_len)) && (fl > 0))) {
                          uint8_t fnb[64] = {};
                          (void)(pipeline_module_func_name_copy64(dep_mod_bind, fi_b, &((fnb)[0])));
                          int32_t eqb = 1;
                          int32_t bi_b = 0;
                          while ((bi_b < fl)) {
                            if (((fnb)[bi_b] !=((callee.field_access_field_name))[bi_b])) {
                              (void)((eqb = 0));
                              (void)((bi_b = fl));
                            } else {
                              (void)((bi_b = (bi_b + 1)));
                            }
                          }
                          if ((eqb !=0)) {
                            (void)((bind_pre = codegen_func_c_symbol_prefix_len(dep_mod_bind, fi_b, pre_len)));
                            (void)((fi_b = (dep_mod_bind->num_funcs)));
                          } else {
                            (void)((fi_b = (fi_b + 1)));
                          }
                        } else {
                          (void)((fi_b = (fi_b + 1)));
                        }
                      }
                    }
                    if ((((bind_pre > 0) && (codegen_c_prefix_redundant_with_name(&((pre_buf)[0]), bind_pre, &(((callee.field_access_field_name))[0]), (callee.field_access_field_len)) ==0)) && (codegen_emit_bytes_from_ptr(out, &((pre_buf)[0]), bind_pre) !=0))) {
                      return -(1);
                    }
                    if ((((callee.field_access_field_len) > 0) && (codegen_emit_call_func_name(out, arena, ctx, expr_ref, dep_mod_bind, &(((callee.field_access_field_name))[0]), (callee.field_access_field_len)) !=0))) {
                      return -(1);
                    }
                  }
                  if ((codegen_append_byte(out, 40) !=0)) {
                    return -(1);
                  }
                  int32_t n_dep = codegen_call_num_args_override(&((pre_buf)[0]), pre_len, &(((callee.field_access_field_name))[0]), (callee.field_access_field_len), (e.call_num_args));
                  int32_t ai = 0;
                  while ((ai < n_dep)) {
                    if ((ai > 0)) {
                      uint8_t comma[3] = {44, 32, 0};
                      if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
                        return -(1);
                      }
                    }
                    if (((drv_buf_bind !=0) && (ai ==0))) {
                      uint8_t cast_buf[19] = {40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0};
                      if ((codegen_emit_bytes_from_ptr(out, &((cast_buf)[0]), 18) !=0)) {
                        return -(1);
                      }
                    }
                    if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {
                      if ((codegen_append_byte(out, 48) !=0)) {
                        return -(1);
                      }
                    } else {
                      if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) !=0)) {
                        return -(1);
                      }
                    }
                    (void)((ai = (ai + 1)));
                  }
                  if ((codegen_append_byte(out, 41) !=0)) {
                    return -(1);
                  }
                  return 0;
                }
              }
              (void)((j = (j + 1)));
            }
          }
        }
        if ((((callee.kind) ==3) && ((callee.var_name_len) > 0))) {
          int32_t j = 0;
          int32_t nd_sel = pipeline_dep_ctx_ndep(ctx);
          int32_t n_imp = codegen_module_num_imports(cur_mod);
          while (((j < n_imp) && (j < nd_sel))) {
            if ((pipeline_module_import_kind_at(cur_mod, j) ==2)) {
              int32_t k = 0;
              int32_t sel_cnt = pipeline_module_import_select_count_at(cur_mod, j);
              while ((k < sel_cnt)) {
                int32_t sel_len = pipeline_module_import_select_name_len(cur_mod, j, k);
                if ((sel_len ==(callee.var_name_len))) {
                  int eq = 1;
                  int32_t kk = 0;
                  while (((kk < (callee.var_name_len)) && (kk < 64))) {
                    if ((((callee.var_name))[kk] !=pipeline_module_import_select_name_byte_at(cur_mod, j, k, kk))) {
                      (void)((eq = 0));
                      break;
                    }
                    (void)((kk = (kk + 1)));
                  }
                  if (eq) {
                    uint8_t dep_path_sel[64] = {};
                    int32_t dep_path_sel_len = codegen_module_import_path_len_at(cur_mod, j, &((dep_path_sel)[0]));
                    if ((dep_path_sel_len <=0)) {
                      (void)((k = (k + 1)));
                      continue;
                    }
                    uint8_t pre_buf[128] = {};
                    (void)(codegen_import_path_to_c_prefix_into(&((dep_path_sel)[0]), &((pre_buf)[0]), 128));
                    int32_t pre_len = 0;
                    while (((pre_len < 128) && ((pre_buf)[pre_len] !=0))) {
                      (void)((pre_len = (pre_len + 1)));
                    }
                    if ((((pre_len > 0) && (codegen_c_prefix_redundant_with_name(&((pre_buf)[0]), pre_len, (callee.var_name), (callee.var_name_len)) ==0)) && (codegen_emit_bytes_from_ptr(out, &((pre_buf)[0]), pre_len) !=0))) {
                      return -(1);
                    }
                    if ((codegen_emit_call_func_name(out, arena, ctx, expr_ref, cur_mod, &(((callee.var_name))[0]), (callee.var_name_len)) !=0)) {
                      return -(1);
                    }
                    if ((codegen_append_byte(out, 40) !=0)) {
                      return -(1);
                    }
                    int32_t n_dep = codegen_call_num_args_override(&((pre_buf)[0]), pre_len, &(((callee.var_name))[0]), (callee.var_name_len), (e.call_num_args));
                    int32_t ai = 0;
                    while ((ai < n_dep)) {
                      if ((ai > 0)) {
                        uint8_t comma[3] = {44, 32, 0};
                        if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
                          return -(1);
                        }
                      }
                      if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {
                        if ((codegen_append_byte(out, 48) !=0)) {
                          return -(1);
                        }
                      } else {
                        if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) !=0)) {
                          return -(1);
                        }
                      }
                      (void)((ai = (ai + 1)));
                    }
                    if ((codegen_append_byte(out, 41) !=0)) {
                      return -(1);
                    }
                    return 0;
                  }
                }
                (void)((k = (k + 1)));
              }
            }
            (void)((j = (j + 1)));
          }
          (void)((j = 0));
          int32_t nd_call = pipeline_dep_ctx_ndep(ctx);
          int32_t local_has_name = 0;
          if (((cur_mod !=((struct ast_Module *)(0))) && ((callee.var_name_len) > 0))) {
            int32_t lfi = 0;
            while ((lfi < (cur_mod->num_funcs))) {
              int32_t lnl = pipeline_module_func_name_len_at(cur_mod, lfi);
              if ((lnl ==(callee.var_name_len))) {
                uint8_t lnm[64] = {};
                (void)(pipeline_module_func_name_copy64(cur_mod, lfi, &((lnm)[0])));
                int32_t leq = 1;
                int32_t li = 0;
                while (((li < lnl) && (li < 64))) {
                  if (((lnm)[li] !=((callee.var_name))[li])) {
                    (void)((leq = 0));
                    break;
                  }
                  (void)((li = (li + 1)));
                }
                if ((leq !=0)) {
                  (void)((local_has_name = 1));
                  break;
                }
              }
              (void)((lfi = (lfi + 1)));
            }
          }
          while (((j < nd_call) && (local_has_name ==0))) {
            struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, j);
            struct ast_ASTArena * dep_arena = pipeline_dep_ctx_arena_at(ctx, j);
            if ((((dep_mod !=((struct ast_Module *)(0))) && (dep_arena !=((struct ast_ASTArena *)(0)))) && ((dep_mod->num_funcs) > 0))) {
              int32_t fi = 0;
              while ((fi < (dep_mod->num_funcs))) {
                int32_t func_ref = pipeline_module_func_ref_at(dep_mod, fi);
                if (((ast_ref_is_null(func_ref) || (func_ref <=0)) || (func_ref > (dep_arena->num_funcs)))) {
                  (void)((fi = (fi + 1)));
                  continue;
                }
                struct ast_Func df = ast_ast_arena_func_get(dep_arena, func_ref);
                if (((df.name_len) ==(callee.var_name_len))) {
                  int eq = 1;
                  int32_t k = 0;
                  while (((k < (callee.var_name_len)) && (k < 64))) {
                    if ((((callee.var_name))[k] !=((df.name))[k])) {
                      (void)((eq = 0));
                      break;
                    }
                    (void)((k = (k + 1)));
                  }
                  if ((eq && (pipeline_dep_ctx_import_path_len(ctx, j) > 0))) {
                    int32_t callee_is_extern = pipeline_module_func_is_extern_at(dep_mod, fi);
                    uint8_t dep_path_call[64] = {};
                    (void)(pipeline_dep_ctx_import_path_copy64(ctx, j, &((dep_path_call)[0])));
                    uint8_t pre_buf[128] = {};
                    (void)(codegen_import_path_to_c_prefix_into(&((dep_path_call)[0]), &((pre_buf)[0]), 128));
                    int32_t pre_len = 0;
                    while (((pre_len < 128) && ((pre_buf)[pre_len] !=0))) {
                      (void)((pre_len = (pre_len + 1)));
                    }
                    if (((callee_is_extern !=0) || (pipeline_module_func_is_no_mangle_at(dep_mod, fi) !=0))) {
                      (void)((pre_len = 0));
                    }
                    int32_t drv_buf_call = 0;
                    if ((codegen_path_is_std_io_driver_bytes(&((dep_path_call)[0])) !=0)) {
                      (void)((drv_buf_call = codegen_emit_io_driver_buf_call_name(out, &(((callee.var_name))[0]), (callee.var_name_len), (e.call_num_args))));
                      if ((drv_buf_call < 0)) {
                        return -(1);
                      }
                    }
                    if ((drv_buf_call ==0)) {
                      if ((((pre_len > 0) && (codegen_c_prefix_redundant_with_name(&((pre_buf)[0]), pre_len, (callee.var_name), (callee.var_name_len)) ==0)) && (codegen_emit_bytes_from_ptr(out, &((pre_buf)[0]), pre_len) !=0))) {
                        return -(1);
                      }
                      if ((codegen_emit_call_func_name(out, arena, ctx, expr_ref, cur_mod, &(((callee.var_name))[0]), (callee.var_name_len)) !=0)) {
                        return -(1);
                      }
                      if (((codegen_path_is_std_io_core_bytes(&((dep_path_call)[0])) !=0) && (codegen_use_buf_wrapper(&(((callee.var_name))[0]), (callee.var_name_len), (e.call_num_args)) !=0))) {
                        uint8_t suf_buf[8] = {95, 98, 117, 102, 0, 0, 0, 0};
                        if ((codegen_emit_bytes_from_ptr(out, &((suf_buf)[0]), 4) !=0)) {
                          return -(1);
                        }
                      }
                    }
                    if ((codegen_append_byte(out, 40) !=0)) {
                      return -(1);
                    }
                    int32_t n_dep = codegen_call_num_args_override(&((pre_buf)[0]), pre_len, (callee.var_name), (callee.var_name_len), (e.call_num_args));
                    int32_t fmt_i32_second_dep = 0;
                    if ((((((((((((e.call_num_args) ==2) && (n_dep ==1)) && ((callee.var_name_len) ==7)) && (((callee.var_name))[0] ==102)) && (((callee.var_name))[1] ==109)) && (((callee.var_name))[2] ==116)) && (((callee.var_name))[3] ==95)) && (((callee.var_name))[4] ==105)) && (((callee.var_name))[5] ==51)) && (((callee.var_name))[6] ==50))) {
                      if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, 0))) {
                        (void)((fmt_i32_second_dep = 1));
                      }
                    }
                    int32_t cast_buf0 = drv_buf_call;
                    int32_t ai = 0;
                    while ((ai < n_dep)) {
                      int32_t arg_idx_dep = ai;
                      if ((ai > 0)) {
                        uint8_t comma[3] = {44, 32, 0};
                        if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
                          return -(1);
                        }
                      }
                      if (((fmt_i32_second_dep !=0) && (ai ==0))) {
                        (void)((arg_idx_dep = 1));
                      }
                      if (((cast_buf0 !=0) && (ai ==0))) {
                        uint8_t cast_buf[19] = {40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0};
                        if ((codegen_emit_bytes_from_ptr(out, &((cast_buf)[0]), 18) !=0)) {
                          return -(1);
                        }
                      }
                      if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_dep))) {
                        if ((codegen_append_byte(out, 48) !=0)) {
                          return -(1);
                        }
                      } else {
                        if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_dep), ctx) !=0)) {
                          return -(1);
                        }
                      }
                      (void)((ai = (ai + 1)));
                    }
                    if (((codegen_is_submit_batch_buf_call((callee.var_name), (callee.var_name_len)) !=0) && ((e.call_num_args) ==3))) {
                      uint8_t comma0[4] = {44, 32, 48, 0};
                      if ((codegen_emit_bytes_4(out, comma0, 3) !=0)) {
                        return -(1);
                      }
                    }
                    if ((codegen_append_byte(out, 41) !=0)) {
                      return -(1);
                    }
                    return 0;
                  }
                }
                (void)((fi = (fi + 1)));
              }
            }
            (void)((j = (j + 1)));
          }
        }
      }
      if ((((((ctx !=((struct ast_PipelineDepCtx *)(0))) && ((ctx->ndep) > 0)) && !(ast_ref_is_null(callee_ref))) && (callee_ref > 0)) && (callee_ref <=(arena->num_exprs)))) {
        struct ast_Expr callee_fb = ast_ast_arena_expr_get(arena, callee_ref);
        if (((((((((((((callee_fb.kind) ==3) && ((callee_fb.var_name_len) ==9)) && (((callee_fb.var_name))[0] ==112)) && (((callee_fb.var_name))[1] ==114)) && (((callee_fb.var_name))[2] ==105)) && (((callee_fb.var_name))[3] ==110)) && (((callee_fb.var_name))[4] ==116)) && (((callee_fb.var_name))[5] ==95)) && (((callee_fb.var_name))[6] ==115)) && (((callee_fb.var_name))[7] ==116)) && (((callee_fb.var_name))[8] ==114))) {
          uint8_t std_io[8] = {115, 116, 100, 95, 105, 111, 95, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((std_io)[0]), 7) !=0)) {
            return -(1);
          }
          if ((codegen_emit_call_func_name(out, arena, ctx, expr_ref, (ctx->current_codegen_module), &(((callee_fb.var_name))[0]), (callee_fb.var_name_len)) !=0)) {
            return -(1);
          }
          if ((codegen_append_byte(out, 40) !=0)) {
            return -(1);
          }
          int32_t ai = 0;
          while ((ai < (e.call_num_args))) {
            if ((ai > 0)) {
              uint8_t comma[3] = {44, 32, 0};
              if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
                return -(1);
              }
            }
            if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {
              if ((codegen_append_byte(out, 48) !=0)) {
                return -(1);
              }
            } else {
              if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) !=0)) {
                return -(1);
              }
            }
            (void)((ai = (ai + 1)));
          }
          if ((codegen_append_byte(out, 41) !=0)) {
            return -(1);
          }
          return 0;
        }
      }
      if (((((((ctx !=((struct ast_PipelineDepCtx *)(0))) && ((ctx->current_codegen_module) !=((struct ast_Module *)(0)))) && ((ctx->current_codegen_arena) !=((struct ast_ASTArena *)(0)))) && !(ast_ref_is_null(callee_ref))) && (callee_ref > 0)) && (callee_ref <=(arena->num_exprs)))) {
        struct ast_Expr callee2 = ast_ast_arena_expr_get(arena, callee_ref);
        if ((((callee2.kind) ==3) && ((callee2.var_name_len) > 0))) {
          struct ast_Module * cur_mod = (ctx->current_codegen_module);
          struct ast_ASTArena * cur_arena = (ctx->current_codegen_arena);
          int32_t fi = 0;
          while ((fi < (cur_mod->num_funcs))) {
            int32_t func_ref = pipeline_module_func_ref_at(cur_mod, fi);
            if (((!(ast_ref_is_null(func_ref)) && (func_ref > 0)) && (func_ref <=(cur_arena->num_funcs)))) {
              struct ast_Func df = ast_ast_arena_func_get(cur_arena, func_ref);
              if (((df.name_len) ==(callee2.var_name_len))) {
                int eq = 1;
                int32_t k = 0;
                while (((k < (callee2.var_name_len)) && (k < 64))) {
                  if ((((callee2.var_name))[k] !=((df.name))[k])) {
                    (void)((eq = 0));
                    break;
                  }
                  (void)((k = (k + 1)));
                }
                if (eq) {
                  uint8_t cur_pre[128] = {};
                  uint8_t cur_dep_path_buf[128] = {};
                  int32_t cur_dep_plen = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, &((cur_dep_path_buf)[0]));
                  int32_t pl = 0;
                  if ((cur_dep_plen > 0)) {
                    (void)(codegen_import_path_to_c_prefix_into(&((cur_dep_path_buf)[0]), &((cur_pre)[0]), 128));
                    while (((pl < 128) && ((cur_pre)[pl] !=((uint8_t)(0))))) {
                      (void)((pl = (pl + 1)));
                    }
                  } else {
                    if (((ctx->current_codegen_prefix_len) > 0)) {
                      int32_t _cpl = (ctx->current_codegen_prefix_len);
                      int32_t pi = 0;
                      while (((pi < _cpl) && (pi < 127))) {
                        (void)(((cur_pre)[pi] = ((ctx->current_codegen_prefix_mirror))[pi]));
                        (void)((pi = (pi + 1)));
                      }
                      (void)(((cur_pre)[pi] = ((uint8_t)(0))));
                      (void)((pl = pi));
                    } else {
                      (void)(((cur_pre)[0] = ((uint8_t)(0))));
                      (void)((pl = 0));
                    }
                  }
                  if (((pipeline_module_func_is_extern_at(cur_mod, fi) !=0) || (pipeline_module_func_is_no_mangle_at(cur_mod, fi) !=0))) {
                    (void)((pl = 0));
                  }
                  if ((((pl > 0) && (codegen_c_prefix_redundant_with_name(&((cur_pre)[0]), pl, (callee2.var_name), (callee2.var_name_len)) ==0)) && (codegen_emit_bytes_from_ptr(out, &((cur_pre)[0]), pl) !=0))) {
                    return -(1);
                  }
                  if ((codegen_emit_call_func_name(out, arena, ctx, expr_ref, cur_mod, &(((callee2.var_name))[0]), (callee2.var_name_len)) !=0)) {
                    return -(1);
                  }
                  if ((codegen_append_byte(out, 40) !=0)) {
                    return -(1);
                  }
                  int32_t n_cur = codegen_call_num_args_override(&((cur_pre)[0]), pl, (callee2.var_name), (callee2.var_name_len), (e.call_num_args));
                  int32_t fmt_i32_second_cur = 0;
                  if ((((((((((((e.call_num_args) ==2) && (n_cur ==1)) && ((callee2.var_name_len) ==7)) && (((callee2.var_name))[0] ==102)) && (((callee2.var_name))[1] ==109)) && (((callee2.var_name))[2] ==116)) && (((callee2.var_name))[3] ==95)) && (((callee2.var_name))[4] ==105)) && (((callee2.var_name))[5] ==51)) && (((callee2.var_name))[6] ==50))) {
                    if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, 0))) {
                      (void)((fmt_i32_second_cur = 1));
                    }
                  }
                  int32_t ai = 0;
                  while ((ai < n_cur)) {
                    int32_t arg_idx_cur = ai;
                    if ((ai > 0)) {
                      uint8_t comma[3] = {44, 32, 0};
                      if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
                        return -(1);
                      }
                    }
                    if (((fmt_i32_second_cur !=0) && (ai ==0))) {
                      (void)((arg_idx_cur = 1));
                    }
                    if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_cur))) {
                      if ((codegen_append_byte(out, 48) !=0)) {
                        return -(1);
                      }
                    } else {
                      if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_cur), ctx) !=0)) {
                        return -(1);
                      }
                    }
                    (void)((ai = (ai + 1)));
                  }
                  if (((codegen_is_submit_batch_buf_call((callee2.var_name), (callee2.var_name_len)) !=0) && ((e.call_num_args) ==3))) {
                    uint8_t comma0[4] = {44, 32, 48, 0};
                    if ((codegen_emit_bytes_4(out, comma0, 3) !=0)) {
                      return -(1);
                    }
                  }
                  if ((codegen_append_byte(out, 41) !=0)) {
                    return -(1);
                  }
                  return 0;
                }
              }
            }
            (void)((fi = (fi + 1)));
          }
        }
      }
      if ((((!(ast_ref_is_null((e.call_callee_ref))) && ((e.call_num_args) ==2)) && ((e.call_callee_ref) > 0)) && ((e.call_callee_ref) <=(arena->num_exprs)))) {
        struct ast_Expr callee_fb = ast_ast_arena_expr_get(arena, (e.call_callee_ref));
        if ((((callee_fb.kind) ==3) && ((callee_fb.var_name_len) >=10))) {
          int prefix_ok = ((((((callee_fb.var_name))[0] ==109) && (((callee_fb.var_name))[1] ==97)) && (((callee_fb.var_name))[2] ==112)) && (((callee_fb.var_name))[3] ==95));
          int32_t off = ((callee_fb.var_name_len) - 6);
          int suffix_ok = (((((((off >=0) && (((callee_fb.var_name))[off] ==102)) && (((callee_fb.var_name))[(off + 1)] ==105)) && (((callee_fb.var_name))[(off + 2)] ==110)) && (((callee_fb.var_name))[(off + 3)] ==100)) && (((callee_fb.var_name))[(off + 4)] ==95)) && (((callee_fb.var_name))[(off + 5)] ==99));
          if ((prefix_ok && suffix_ok)) {
            uint8_t open[3] = {40, 40, 0};
            uint8_t mid1[10] = {41, 46, 107, 101, 121, 115, 44, 32, 40, 0};
            uint8_t mid2[14] = {41, 46, 111, 99, 99, 117, 112, 105, 101, 100, 44, 32, 40, 0};
            uint8_t mid3[8] = {41, 46, 99, 97, 112, 44, 32, 0};
            if ((codegen_emit_call_func_name(out, arena, ctx, expr_ref, (ctx->current_codegen_module), &(((callee_fb.var_name))[0]), (callee_fb.var_name_len)) !=0)) {
              return -(1);
            }
            if ((codegen_emit_bytes_3(out, open, 2) !=0)) {
              return -(1);
            }
            if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) !=0)) {
              return -(1);
            }
            if ((codegen_emit_bytes_from_ptr(out, &((mid1)[0]), 9) !=0)) {
              return -(1);
            }
            if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) !=0)) {
              return -(1);
            }
            if ((codegen_emit_bytes_from_ptr(out, &((mid2)[0]), 13) !=0)) {
              return -(1);
            }
            if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) !=0)) {
              return -(1);
            }
            if ((codegen_emit_bytes_8(out, mid3, 7) !=0)) {
              return -(1);
            }
            if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 1), ctx) !=0)) {
              return -(1);
            }
            if ((codegen_append_byte(out, 41) !=0)) {
              return -(1);
            }
            return 0;
          }
        }
      }
      int32_t need_4th = 0;
      if ((((!(ast_ref_is_null((e.call_callee_ref))) && ((e.call_callee_ref) > 0)) && ((e.call_callee_ref) <=(arena->num_exprs))) && ((e.call_num_args) ==3))) {
        struct ast_Expr callee_f4 = ast_ast_arena_expr_get(arena, (e.call_callee_ref));
        if ((((callee_f4.kind) ==3) && (codegen_is_submit_batch_buf_call((callee_f4.var_name), (callee_f4.var_name_len)) !=0))) {
          (void)((need_4th = 1));
        }
      }
      int32_t saved_callee_flag = 0;
      if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
        (void)((saved_callee_flag = (ctx->emit_expr_as_callee)));
        (void)(((ctx->emit_expr_as_callee) = 1));
      }
      if ((!(ast_ref_is_null((e.call_callee_ref))) && (codegen_emit_expr(arena, out, (e.call_callee_ref), ctx) !=0))) {
        if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
          (void)(((ctx->emit_expr_as_callee) = saved_callee_flag));
        }
        return -(1);
      }
      if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
        (void)(((ctx->emit_expr_as_callee) = saved_callee_flag));
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      uint8_t fallback_pre[64] = {};
      int32_t fallback_pl = 0;
      if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
        uint8_t fb_dep_path_buf[128] = {};
        int32_t fb_dep_plen = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, &((fb_dep_path_buf)[0]));
        if ((fb_dep_plen > 0)) {
          (void)(codegen_import_path_to_c_prefix_into(&((fb_dep_path_buf)[0]), &((fallback_pre)[0]), 64));
        } else {
          (void)(((fallback_pre)[0] = ((uint8_t)(0))));
        }
        while (((fallback_pl < 64) && ((fallback_pre)[fallback_pl] !=0))) {
          (void)((fallback_pl = (fallback_pl + 1)));
        }
      }
      int32_t n_fb = (e.call_num_args);
      int32_t use_second_arg = 0;
      if (((!(ast_ref_is_null((e.call_callee_ref))) && ((e.call_callee_ref) > 0)) && ((e.call_callee_ref) <=(arena->num_exprs)))) {
        struct ast_Expr callee_expr = ast_ast_arena_expr_get(arena, (e.call_callee_ref));
        if (((callee_expr.kind) ==3)) {
          (void)((n_fb = codegen_call_num_args_override(&((fallback_pre)[0]), fallback_pl, (callee_expr.var_name), (callee_expr.var_name_len), (e.call_num_args))));
          if (((((e.call_num_args) ==2) && (n_fb ==1)) && (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, 0)) !=0))) {
            (void)((use_second_arg = 1));
          }
        }
      }
      int32_t ai = 0;
      while ((ai < n_fb)) {
        int32_t arg_idx = ai;
        if ((ai > 0)) {
          uint8_t comma[3] = {44, 32, 0};
          if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
            return -(1);
          }
        }
        if (((use_second_arg !=0) && (ai ==0))) {
          (void)((arg_idx = 1));
        }
        if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx))) {
          if ((codegen_append_byte(out, 48) !=0)) {
            return -(1);
          }
        } else {
          if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx), ctx) !=0)) {
            return -(1);
          }
        }
        (void)((ai = (ai + 1)));
      }
      if ((need_4th !=0)) {
        uint8_t comma0[4] = {44, 32, 48, 0};
        if ((codegen_emit_bytes_4(out, comma0, 3) !=0)) {
          return -(1);
        }
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -(1);
      }
      return 0;
    }
    if (((e.kind) ==1)) {
      return pipeline_codegen_emit_float_lit_c(out, (e.float_val), (e.float_bits_lo), (e.float_bits_hi));
    }
    if (((e.kind) ==6)) {
      uint8_t op[4] = {32, 42, 32, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, op, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==7)) {
      uint8_t op[4] = {32, 47, 32, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, op, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==8)) {
      uint8_t op[4] = {32, 37, 32, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, op, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==14)) {
      uint8_t op[4] = {32, 61, 61, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, op, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==15)) {
      uint8_t op[4] = {32, 33, 61, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, op, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==16)) {
      uint8_t op[4] = {32, 60, 32, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, op, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==17)) {
      uint8_t op[4] = {32, 60, 61, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, op, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==18)) {
      uint8_t op[4] = {32, 62, 32, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, op, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==19)) {
      uint8_t op[4] = {32, 62, 61, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, op, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==20)) {
      uint8_t op[5] = {32, 38, 38, 32, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_5(out, op, 4) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==21)) {
      uint8_t op[5] = {32, 124, 124, 32, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_5(out, op, 4) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==9)) {
      uint8_t op[4] = {32, 60, 60, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, op, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==10)) {
      uint8_t op[4] = {32, 62, 62, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, op, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==11)) {
      uint8_t op[4] = {32, 38, 32, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, op, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==12)) {
      uint8_t op[4] = {32, 124, 32, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, op, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==13)) {
      uint8_t op[4] = {32, 94, 32, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_left_ref), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, op, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.binop_right_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==23)) {
      uint8_t pre[3] = {126, 40, 0};
      if ((codegen_emit_bytes_3(out, pre, 2) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.unary_operand_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==24)) {
      uint8_t pre[3] = {33, 40, 0};
      if ((codegen_emit_bytes_3(out, pre, 2) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, (e.unary_operand_ref), ctx) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==27)) {
      uint8_t q[4] = {32, 63, 32, 0};
      uint8_t colon[4] = {32, 58, 32, 0};
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((!(ast_ref_is_null((e.if_cond_ref))) && (codegen_emit_expr(arena, out, (e.if_cond_ref), ctx) !=0))) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, q, 3) !=0)) {
        return -(1);
      }
      if ((!(ast_ref_is_null((e.if_then_ref))) && (codegen_emit_expr(arena, out, (e.if_then_ref), ctx) !=0))) {
        return -(1);
      }
      if ((codegen_emit_bytes_4(out, colon, 3) !=0)) {
        return -(1);
      }
      if (!(ast_ref_is_null((e.if_else_ref)))) {
        if ((codegen_emit_expr(arena, out, (e.if_else_ref), ctx) !=0)) {
          return -(1);
        }
      } else {
        if ((codegen_append_byte(out, 48) !=0)) {
          return -(1);
        }
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==47)) {
      int32_t need_slice_data = (e.index_base_is_slice);
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((!(ast_ref_is_null((e.index_base_ref))) && (codegen_emit_expr(arena, out, (e.index_base_ref), ctx) !=0))) {
        return -(1);
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -(1);
      }
      if (((need_slice_data ==0) && !(ast_ref_is_null((e.index_base_ref))))) {
        int32_t base_ty = pipeline_expr_resolved_type_ref(arena, (e.index_base_ref));
        if (((!(ast_ref_is_null(base_ty)) && (base_ty > 0)) && (base_ty <=(arena->num_types)))) {
          if ((pipeline_type_kind_ord_at(arena, base_ty) ==11)) {
            (void)((need_slice_data = 1));
          }
        }
      }
      if ((need_slice_data !=0)) {
        /* PLATFORM: SHARED — slice/pointer base uses ->data (params are pointers). */
        int32_t use_arrow = 0;
        if (!(ast_ref_is_null((e.index_base_ref)))) {
          if ((codegen_field_access_base_is_pointer_ref(arena, (e.index_base_ref)) !=0)) {
            (void)((use_arrow = 1));
          }
          if ((((use_arrow ==0) && (ctx !=((struct ast_PipelineDepCtx *)(0)))) && (ctx->current_codegen_module !=((struct ast_Module *)(0)))) && ((ctx->current_func_index) >=0)) {
            if ((codegen_field_access_base_is_pointer_param(arena, (e.index_base_ref), (ctx->current_codegen_module), (ctx->current_func_index)) !=0)) {
              (void)((use_arrow = 1));
            }
          }
        }
        if ((use_arrow !=0)) {
          uint8_t arrow_data[8] = {45, 62, 100, 97, 116, 97, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((arrow_data)[0]), 6) !=0)) {
            return -(1);
          }
        } else {
          uint8_t dot[6] = {46, 100, 97, 116, 97, 0};
          if ((codegen_emit_bytes_6(out, dot, 5) !=0)) {
            return -(1);
          }
        }
      }
      if ((codegen_append_byte(out, 91) !=0)) {
        return -(1);
      }
      if ((!(ast_ref_is_null((e.index_index_ref))) && (codegen_emit_expr(arena, out, (e.index_index_ref), ctx) !=0))) {
        return -(1);
      }
      return codegen_append_byte(out, 93);
    }
    if (((e.kind) ==44)) {
      int32_t is_ptr_base = codegen_field_access_base_is_pointer_ref(arena, (e.field_access_base_ref));
      int32_t param_type_known = 0;
      if (((ctx !=((struct ast_PipelineDepCtx *)(0))) && ((ctx->current_codegen_module) !=((struct ast_Module *)(0))))) {
        (void)(pipeline_codegen_try_mark_enum_field_access((ctx->current_codegen_module), arena, expr_ref, ctx));
        (void)((e = ast_ast_arena_expr_get(arena, expr_ref)));
      }
      if (((e.field_access_is_enum_variant) !=0)) {
        return codegen_format_int(out, (e.enum_variant_tag));
      }
      if ((((ctx !=((struct ast_PipelineDepCtx *)(0))) && ((ctx->emit_expr_as_callee) !=0)) && (codegen_emit_import_module_field_symbol(arena, out, expr_ref, ctx) ==0))) {
        return 0;
      }
      if ((codegen_emit_import_module_const_field(arena, out, expr_ref, ctx) ==0)) {
        return 0;
      }
      if (((((ctx !=((struct ast_PipelineDepCtx *)(0))) && ((ctx->current_codegen_module) !=((struct ast_Module *)(0)))) && ((ctx->current_codegen_arena) ==arena)) && ((ctx->current_func_index) >=0))) {
        struct ast_Module * mod = (ctx->current_codegen_module);
        if (((ctx->current_func_index) < (mod->num_funcs))) {
          int32_t cfi = (ctx->current_func_index);
          uint8_t pref[128] = {};
          int32_t plen = codegen_emit_prefix_len_from_ctx(ctx, &((pref)[0]), 128);
          uint8_t cfn[64] = {};
          (void)(pipeline_module_func_name_copy64(mod, cfi, &((cfn)[0])));
          int32_t cfn_len = pipeline_module_func_name_len_at(mod, cfi);
          if ((codegen_force_param_ptrdiff_t(&((pref)[0]), plen, &((cfn)[0]), cfn_len, 0) !=0)) {
            if ((codegen_expr_var_matches_func_param_index(arena, (e.field_access_base_ref), mod, cfi, 0, ctx) !=0)) {
              return codegen_emit_expr(arena, out, (e.field_access_base_ref), ctx);
            }
          }
        }
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((!(ast_ref_is_null((e.field_access_base_ref))) && (codegen_emit_expr(arena, out, (e.field_access_base_ref), ctx) !=0))) {
        return -(1);
      }
      if ((((ctx !=((struct ast_PipelineDepCtx *)(0))) && ((ctx->current_codegen_module) !=((struct ast_Module *)(0)))) && ((ctx->current_func_index) >=0))) {
        if ((is_ptr_base ==0)) {
          (void)((is_ptr_base = codegen_field_access_base_is_pointer_param(arena, (e.field_access_base_ref), (ctx->current_codegen_module), (ctx->current_func_index))));
        }
        if ((is_ptr_base ==0)) {
          (void)((is_ptr_base = codegen_field_access_base_is_pointer_local(arena, (e.field_access_base_ref), ctx)));
        }
        (void)((param_type_known = codegen_field_access_base_param_type_known(arena, (e.field_access_base_ref), (ctx->current_codegen_module), (ctx->current_func_index))));
      }
      if ((((is_ptr_base ==0) && (param_type_known ==0)) && (codegen_field_access_base_type_resolved(arena, (e.field_access_base_ref)) ==0))) {
        if ((codegen_field_access_base_is_slice_param_name(arena, (e.field_access_base_ref)) !=0)) {
          (void)((is_ptr_base = 1));
        }
      }
      if ((is_ptr_base !=0)) {
        uint8_t arrow[3] = {45, 62, 0};
        if ((codegen_emit_bytes_3(out, arrow, 2) !=0)) {
          return -(1);
        }
      } else {
        uint8_t dot[2] = {46, 0};
        if ((codegen_emit_bytes_2(out, dot, 1) !=0)) {
          return -(1);
        }
      }
      if ((codegen_emit_bytes_64(out, &(((e.field_access_field_name))[0]), (e.field_access_field_len)) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==42)) {
      uint8_t p[22] = {115, 104, 117, 120, 95, 112, 97, 110, 105, 99, 95, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
      if ((codegen_emit_bytes_22(out, p, 12) !=0)) {
        return -(1);
      }
      if (ast_ref_is_null((e.unary_operand_ref))) {
        if ((codegen_append_byte(out, 48) !=0)) {
          return -(1);
        }
        if ((codegen_append_byte(out, 44) !=0)) {
          return -(1);
        }
        if ((codegen_append_byte(out, 48) !=0)) {
          return -(1);
        }
      } else {
        if ((codegen_append_byte(out, 49) !=0)) {
          return -(1);
        }
        if ((codegen_append_byte(out, 44) !=0)) {
          return -(1);
        }
        if ((codegen_emit_expr(arena, out, (e.unary_operand_ref), ctx) !=0)) {
          return -(1);
        }
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==39)) {
      return codegen_append_byte(out, 48);
    }
    if (((e.kind) ==40)) {
      return codegen_append_byte(out, 48);
    }
    if (((e.kind) ==49)) {
      /* PLATFORM: SHARED — fmt/debug println("…") METHOD_CALL form. */
      if ((ctx != ((struct ast_PipelineDepCtx *)(0)))) {
        int32_t fmt_mc_rc = codegen_try_emit_fmt_string_lit_call(arena, out, expr_ref, ctx);
        if ((fmt_mc_rc < 0)) {
          return -1;
        }
        if ((fmt_mc_rc > 0)) {
          return 0;
        }
      }

      uint8_t dot[2] = {46, 0};
      int32_t mi = 0;
      if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
        int32_t dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
        int32_t func_ix = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
        int32_t mc_resolved_ok = 0;
        if ((((dep_ix >=0) && (func_ix >=0)) && (dep_ix < pipeline_dep_ctx_ndep(ctx)))) {
          struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
          if (((dep_mod !=((struct ast_Module *)(0))) && (func_ix < (dep_mod->num_funcs)))) {
            uint8_t fn_name[64] = {};
            int32_t fn_len = pipeline_module_func_name_len_at(dep_mod, func_ix);
            int32_t name_ok = 0;
            if ((fn_len > 0)) {
              (void)(pipeline_module_func_name_copy64(dep_mod, func_ix, &((fn_name)[0])));
            }
            if ((((fn_len > 0) && (fn_len ==(e.method_call_name_len))) && ((e.method_call_name_len) > 0))) {
              int32_t mi = 0;
              (void)((name_ok = 1));
              while ((mi < fn_len)) {
                if (((fn_name)[mi] !=((e.method_call_name))[mi])) {
                  (void)((name_ok = 0));
                  (void)((mi = fn_len));
                } else {
                  (void)((mi = (mi + 1)));
                }
              }
            }
            if (((name_ok !=0) && (pipeline_module_func_num_params_at(dep_mod, func_ix) ==(e.method_call_num_args)))) {
              (void)((mc_resolved_ok = 1));
            }
            /* PLATFORM: SHARED — multi-import: call_resolved dep may be transitive (heap.libc)
             * while binding is std.heap; require path match. Keep typeck overload when path OK. */
            if ((mc_resolved_ok !=0)) {
              uint8_t bind_path[64] = {};
              int32_t bind_plen = codegen_resolve_binding_import_path_for_method_call(ctx, arena, expr_ref, &((bind_path)[0]));
              uint8_t dep_path_chk[64] = {};
              (void)(pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, &((dep_path_chk)[0])));
              int32_t dep_plen_chk = pipeline_dep_ctx_import_path_len(ctx, dep_ix);
              if ((bind_plen > 0)) {
                if ((bind_plen !=dep_plen_chk)) {
                  (void)((mc_resolved_ok = 0));
                } else {
                  int32_t bp = 0;
                  while ((bp < bind_plen)) {
                    if (((bind_path)[bp] !=((dep_path_chk)[bp]))) {
                      (void)((mc_resolved_ok = 0));
                      (void)((bp = bind_plen));
                    } else {
                      (void)((bp = (bp + 1)));
                    }
                  }
                }
              }
            }
            if ((mc_resolved_ok !=0)) {
              uint8_t dep_path[64] = {};
              (void)(pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, &((dep_path)[0])));
              uint8_t pre_buf[128] = {};
              (void)(codegen_import_path_to_c_prefix_into(&((dep_path)[0]), &((pre_buf)[0]), 128));
              int32_t pre_len = 0;
              while (((pre_len < 128) && ((pre_buf)[pre_len] !=0))) {
                (void)((pre_len = (pre_len + 1)));
              }
              int32_t drv_buf_mc = 0;
              if (((codegen_path_is_std_io_driver_bytes(&((dep_path)[0])) !=0) && (fn_len > 0))) {
                (void)((drv_buf_mc = codegen_emit_io_driver_buf_call_name(out, &((fn_name)[0]), fn_len, (e.method_call_num_args))));
                if ((drv_buf_mc < 0)) {
                  return -(1);
                }
              }
              if ((drv_buf_mc ==0)) {
                int32_t call_pre = codegen_func_c_symbol_prefix_len(dep_mod, func_ix, pre_len);
                if (((((call_pre > 0) && (fn_len > 0)) && (codegen_c_prefix_redundant_with_name(&((pre_buf)[0]), call_pre, &((fn_name)[0]), fn_len) ==0)) && (codegen_emit_bytes_from_ptr(out, &((pre_buf)[0]), call_pre) !=0))) {
                  return -(1);
                }
                struct ast_ASTArena * dep_arena = codegen_arena_for_module(ctx, dep_mod, arena);
                if ((dep_arena ==((struct ast_ASTArena *)(0)))) {
                  (void)((dep_arena = pipeline_dep_ctx_arena_at(ctx, dep_ix)));
                }
                if (((fn_len > 0) && (codegen_emit_func_link_name(out, dep_arena, dep_mod, func_ix) !=0))) {
                  return -(1);
                }
              }
              if ((codegen_append_byte(out, 40) !=0)) {
                return -(1);
              }
              int32_t n_dep = codegen_call_num_args_override(&((pre_buf)[0]), pre_len, &((fn_name)[0]), fn_len, (e.method_call_num_args));
              int32_t ai = 0;
              while ((ai < n_dep)) {
                int32_t dep_arg = pipeline_expr_method_call_arg_ref(arena, expr_ref, ai);
                if ((ai > 0)) {
                  uint8_t comma_dep[3] = {44, 32, 0};
                  if ((codegen_emit_bytes_3(out, comma_dep, 2) !=0)) {
                    return -(1);
                  }
                }
                if (((drv_buf_mc !=0) && (ai ==0))) {
                  uint8_t cast_buf[19] = {40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0};
                  if ((codegen_emit_bytes_from_ptr(out, &((cast_buf)[0]), 18) !=0)) {
                    return -(1);
                  }
                }
                if (ast_ref_is_null(dep_arg)) {
                  if ((codegen_append_byte(out, 48) !=0)) {
                    return -(1);
                  }
                } else {
                  /* PLATFORM: SHARED — method dep args: same slice pointer ABI as CALL. */
                  if ((codegen_emit_call_arg_slice_abi(arena, out, dep_arg, ctx) !=0)) {
                    return -(1);
                  }
                }
                (void)((ai = (ai + 1)));
              }
              return codegen_append_byte(out, 41);
            }
          }
        }
        uint8_t dep_path_fb[64] = {};
        int32_t dep_path_fb_len = codegen_resolve_binding_import_path_for_method_call(ctx, arena, expr_ref, &((dep_path_fb)[0]));
        if ((dep_path_fb_len > 0)) {
          uint8_t pre_fb[128] = {};
          (void)(codegen_import_path_to_c_prefix_into(&((dep_path_fb)[0]), &((pre_fb)[0]), 128));
          int32_t pre_fb_len = 0;
          while (((pre_fb_len < 128) && ((pre_fb)[pre_fb_len] !=0))) {
            (void)((pre_fb_len = (pre_fb_len + 1)));
          }
          int32_t drv_buf_fb = 0;
          if ((codegen_path_is_std_io_driver_bytes(&((dep_path_fb)[0])) !=0)) {
            (void)((drv_buf_fb = codegen_emit_io_driver_buf_call_name(out, &(((e.method_call_name))[0]), (e.method_call_name_len), (e.method_call_num_args))));
            if ((drv_buf_fb < 0)) {
              return -(1);
            }
          }
          if ((drv_buf_fb ==0)) {
            struct ast_Module * fb_dep_mod = ((struct ast_Module *)(0));
            int32_t dj = 0;
            if ((((pre_fb_len > 0) && (codegen_c_prefix_redundant_with_name(&((pre_fb)[0]), pre_fb_len, &(((e.method_call_name))[0]), (e.method_call_name_len)) ==0)) && (codegen_emit_bytes_from_ptr(out, &((pre_fb)[0]), pre_fb_len) !=0))) {
              return -(1);
            }
            while ((dj < pipeline_dep_ctx_ndep(ctx))) {
              uint8_t dj_path[64] = {};
              (void)(pipeline_dep_ctx_import_path_copy64(ctx, dj, &((dj_path)[0])));
              int32_t dj_plen = pipeline_dep_ctx_import_path_len(ctx, dj);
              if (((dj_plen ==dep_path_fb_len) && (dj_plen > 0))) {
                int32_t dj_eq = 1;
                int32_t dk = 0;
                while ((dk < dj_plen)) {
                  if (((dj_path)[dk] !=(dep_path_fb)[dk])) {
                    (void)((dj_eq = 0));
                    (void)((dk = dj_plen));
                  } else {
                    (void)((dk = (dk + 1)));
                  }
                }
                if ((dj_eq !=0)) {
                  (void)((fb_dep_mod = pipeline_dep_ctx_module_at(ctx, dj)));
                  (void)((dj = pipeline_dep_ctx_ndep(ctx)));
                }
              }
              (void)((dj = (dj + 1)));
            }
            if ((codegen_emit_call_func_name(out, arena, ctx, expr_ref, fb_dep_mod, &(((e.method_call_name))[0]), (e.method_call_name_len)) !=0)) {
              return -(1);
            }
          }
          if ((codegen_append_byte(out, 40) !=0)) {
            return -(1);
          }
          int32_t n_fb = codegen_call_num_args_override(&((pre_fb)[0]), pre_fb_len, &(((e.method_call_name))[0]), (e.method_call_name_len), (e.method_call_num_args));
          int32_t ai_fb = 0;
          while ((ai_fb < n_fb)) {
            int32_t arg_fb = pipeline_expr_method_call_arg_ref(arena, expr_ref, ai_fb);
            if ((ai_fb > 0)) {
              uint8_t comma_fb[3] = {44, 32, 0};
              if ((codegen_emit_bytes_3(out, comma_fb, 2) !=0)) {
                return -(1);
              }
            }
            if (((drv_buf_fb !=0) && (ai_fb ==0))) {
              uint8_t cast_buf[19] = {40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0};
              if ((codegen_emit_bytes_from_ptr(out, &((cast_buf)[0]), 18) !=0)) {
                return -(1);
              }
            }
            if (ast_ref_is_null(arg_fb)) {
              if ((codegen_append_byte(out, 48) !=0)) {
                return -(1);
              }
            } else {
              /* PLATFORM: SHARED — method fallback args: slice locals → &(s). */
              if ((codegen_emit_call_arg_slice_abi(arena, out, arg_fb, ctx) !=0)) {
                return -(1);
              }
            }
            (void)((ai_fb = (ai_fb + 1)));
          }
          return codegen_append_byte(out, 41);
        }
      }
      if (((((((((((e.method_call_name_len) ==6) && (((e.method_call_name))[0] ==100)) && (((e.method_call_name))[1] ==111)) && (((e.method_call_name))[2] ==117)) && (((e.method_call_name))[3] ==98)) && (((e.method_call_name))[4] ==108)) && (((e.method_call_name))[5] ==101)) && ((e.method_call_num_args) ==0)) && !(ast_ref_is_null((e.method_call_base_ref))))) {
        uint8_t mul2[6] = {32, 42, 32, 50, 41, 0};
        if ((codegen_append_byte(out, 40) !=0)) {
          return -(1);
        }
        if ((codegen_emit_expr(arena, out, (e.method_call_base_ref), ctx) !=0)) {
          return -(1);
        }
        if ((codegen_emit_bytes_from_ptr(out, &((mul2)[0]), 5) !=0)) {
          return -(1);
        }
        return 0;
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      if ((!(ast_ref_is_null((e.method_call_base_ref))) && (codegen_emit_expr(arena, out, (e.method_call_base_ref), ctx) !=0))) {
        return -(1);
      }
      if ((codegen_emit_bytes_2(out, dot, 1) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_64(out, &(((e.method_call_name))[0]), (e.method_call_name_len)) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -(1);
      }
      while ((mi < (e.method_call_num_args))) {
        int32_t m_arg = pipeline_expr_method_call_arg_ref(arena, expr_ref, mi);
        if ((mi > 0)) {
          uint8_t comma[3] = {44, 32, 0};
          if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
            return -(1);
          }
        }
        if (ast_ref_is_null(m_arg)) {
          if ((codegen_append_byte(out, 48) !=0)) {
            return -(1);
          }
        } else {
          /* PLATFORM: SHARED — residual method_call args: slice pointer ABI. */
          if ((codegen_emit_call_arg_slice_abi(arena, out, m_arg, ctx) !=0)) {
            return -(1);
          }
        }
        (void)((mi = (mi + 1)));
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -(1);
      }
      return codegen_append_byte(out, 41);
    }
    if (((e.kind) ==43)) {
      int32_t m0 = pipeline_expr_match_arm_result_ref(arena, expr_ref, 0);
      if (((e.match_num_arms) <=0)) {
        return codegen_append_byte(out, 48);
      }
      if ((!(ast_ref_is_null(m0)) && (codegen_emit_expr(arena, out, m0, ctx) !=0))) {
        return -(1);
      }
      return 0;
    }
    if (((e.kind) ==45)) {
      uint8_t sl_pfx[128] = {};
      int32_t sl_plen = codegen_emit_prefix_len_from_ctx(ctx, &((sl_pfx)[0]), 128);
      int32_t bare_user_lit = 0;
      /* PLATFORM: SHARED — compound lit defining-module tag (owner_index). */
      if (((ctx !=((struct ast_PipelineDepCtx *)(0))) && ((e.struct_lit_struct_name_len) > 0))) {
        int32_t lit_bare_off = 0;
        int32_t lit_bi = 0;
        int32_t lit_bare_len;
        int32_t lit_owner;
        while (((lit_bi < (e.struct_lit_struct_name_len)) && (lit_bi < 64))) {
          if ((((e.struct_lit_struct_name))[lit_bi] ==46)) {
            (void)((lit_bare_off = (lit_bi + 1)));
          }
          (void)((lit_bi = (lit_bi + 1)));
        }
        lit_bare_len = ((e.struct_lit_struct_name_len) - lit_bare_off);
        if ((lit_bare_len > 0)) {
          lit_owner = codegen_type_dep_struct_owner_index(ctx, &(((e.struct_lit_struct_name))[lit_bare_off]), lit_bare_len);
          if ((lit_owner >=0)) {
            uint8_t lit_path[64] = {};
            int32_t lit_plen = codegen_dep_import_path_len_at(ctx, lit_owner, &((lit_path)[0]));
            if ((lit_plen > 0)) {
              (void)(codegen_import_path_to_c_prefix_into(&((lit_path)[0]), &((sl_pfx)[0]), 128));
              (void)((sl_plen = 0));
              while (((sl_plen < 128) && ((sl_pfx)[sl_plen] !=((uint8_t)(0))))) {
                (void)((sl_plen = (sl_plen + 1)));
              }
            }
          }
        }
      }

      if (((((sl_plen ==0) && (ctx !=((struct ast_PipelineDepCtx *)(0)))) && ((ctx->current_codegen_dep_index) < 0)) && ((ctx->current_codegen_module) !=((struct ast_Module *)(0))))) {
        struct ast_Module * modu = (ctx->current_codegen_module);
        int32_t sk = 0;
        while ((sk < (modu->num_struct_layouts))) {
          int32_t snl = pipeline_module_struct_layout_name_len(modu, sk);
          if (((snl ==(e.struct_lit_struct_name_len)) && (snl > 0))) {
            uint8_t snm[64] = {};
            (void)(pipeline_module_struct_layout_name_into(modu, sk, &((snm)[0])));
            int eq2 = 1;
            int32_t sj = 0;
            while (((sj < snl) && (sj < 64))) {
              if (((snm)[sj] !=((e.struct_lit_struct_name))[sj])) {
                (void)((eq2 = 0));
                break;
              }
              (void)((sj = (sj + 1)));
            }
            if (eq2) {
              (void)((bare_user_lit = 1));
              break;
            }
          }
          (void)((sk = (sk + 1)));
        }
      }
      if ((codegen_should_skip_emit_struct_layout_for_abi_dup(&(((e.struct_lit_struct_name))[0]), (e.struct_lit_struct_name_len)) !=0)) {
        (void)((bare_user_lit = 0));
        if ((((e.struct_lit_struct_name_len) ==6) && (((e.struct_lit_struct_name))[0] ==66))) {
          (void)(((sl_pfx)[0] = 115));
          (void)(((sl_pfx)[1] = 116));
          (void)(((sl_pfx)[2] = 100));
          (void)(((sl_pfx)[3] = 95));
          (void)(((sl_pfx)[4] = 105));
          (void)(((sl_pfx)[5] = 111));
          (void)(((sl_pfx)[6] = 95));
          (void)(((sl_pfx)[7] = 100));
          (void)(((sl_pfx)[8] = 114));
          (void)(((sl_pfx)[9] = 105));
          (void)(((sl_pfx)[10] = 118));
          (void)(((sl_pfx)[11] = 101));
          (void)(((sl_pfx)[12] = 114));
          (void)(((sl_pfx)[13] = 95));
          (void)(((sl_pfx)[14] = 0));
          (void)((sl_plen = 14));
        } else {
          if ((((e.struct_lit_struct_name_len) ==5) && (((e.struct_lit_struct_name))[0] ==69))) {
            (void)(((sl_pfx)[0] = 115));
            (void)(((sl_pfx)[1] = 116));
            (void)(((sl_pfx)[2] = 100));
            (void)(((sl_pfx)[3] = 95));
            (void)(((sl_pfx)[4] = 101));
            (void)(((sl_pfx)[5] = 114));
            (void)(((sl_pfx)[6] = 114));
            (void)(((sl_pfx)[7] = 111));
            (void)(((sl_pfx)[8] = 114));
            (void)(((sl_pfx)[9] = 95));
            (void)(((sl_pfx)[10] = 0));
            (void)((sl_plen = 10));
          } else {
            if ((((((((((e.struct_lit_struct_name_len) >=8) && (((e.struct_lit_struct_name))[0] ==79)) && (((e.struct_lit_struct_name))[1] ==112)) && (((e.struct_lit_struct_name))[2] ==116)) && (((e.struct_lit_struct_name))[3] ==105)) && (((e.struct_lit_struct_name))[4] ==111)) && (((e.struct_lit_struct_name))[5] ==110)) && (((e.struct_lit_struct_name))[6] ==95))) {
              (void)(((sl_pfx)[0] = 99));
              (void)(((sl_pfx)[1] = 111));
              (void)(((sl_pfx)[2] = 114));
              (void)(((sl_pfx)[3] = 101));
              (void)(((sl_pfx)[4] = 95));
              (void)(((sl_pfx)[5] = 111));
              (void)(((sl_pfx)[6] = 112));
              (void)(((sl_pfx)[7] = 116));
              (void)(((sl_pfx)[8] = 105));
              (void)(((sl_pfx)[9] = 111));
              (void)(((sl_pfx)[10] = 110));
              (void)(((sl_pfx)[11] = 95));
              (void)(((sl_pfx)[12] = 0));
              (void)((sl_plen = 12));
            } else {
              if ((((e.struct_lit_struct_name_len) ==9) && (((e.struct_lit_struct_name))[0] ==82))) {
                (void)(((sl_pfx)[0] = 99));
                (void)(((sl_pfx)[1] = 111));
                (void)(((sl_pfx)[2] = 114));
                (void)(((sl_pfx)[3] = 101));
                (void)(((sl_pfx)[4] = 95));
                (void)(((sl_pfx)[5] = 114));
                (void)(((sl_pfx)[6] = 101));
                (void)(((sl_pfx)[7] = 115));
                (void)(((sl_pfx)[8] = 117));
                (void)(((sl_pfx)[9] = 108));
                (void)(((sl_pfx)[10] = 116));
                (void)(((sl_pfx)[11] = 95));
                (void)(((sl_pfx)[12] = 0));
                (void)((sl_plen = 12));
              } else {
                if (((((e.struct_lit_struct_name_len) ==10) && (((e.struct_lit_struct_name))[0] ==82)) && (((e.struct_lit_struct_name))[7] ==105))) {
                  (void)(((sl_pfx)[0] = 99));
                  (void)(((sl_pfx)[1] = 111));
                  (void)(((sl_pfx)[2] = 114));
                  (void)(((sl_pfx)[3] = 101));
                  (void)(((sl_pfx)[4] = 95));
                  (void)(((sl_pfx)[5] = 114));
                  (void)(((sl_pfx)[6] = 101));
                  (void)(((sl_pfx)[7] = 115));
                  (void)(((sl_pfx)[8] = 117));
                  (void)(((sl_pfx)[9] = 108));
                  (void)(((sl_pfx)[10] = 116));
                  (void)(((sl_pfx)[11] = 95));
                  (void)(((sl_pfx)[12] = 0));
                  (void)((sl_plen = 12));
                } else {
                  if (((((((e.struct_lit_struct_name_len) ==6) && (((e.struct_lit_struct_name))[0] ==83)) && (((e.struct_lit_struct_name))[1] ==116)) && (((e.struct_lit_struct_name))[2] ==114)) && (((e.struct_lit_struct_name))[3] ==105))) {
                    (void)(((sl_pfx)[0] = 115));
                    (void)(((sl_pfx)[1] = 116));
                    (void)(((sl_pfx)[2] = 100));
                    (void)(((sl_pfx)[3] = 95));
                    (void)(((sl_pfx)[4] = 115));
                    (void)(((sl_pfx)[5] = 116));
                    (void)(((sl_pfx)[6] = 114));
                    (void)(((sl_pfx)[7] = 105));
                    (void)(((sl_pfx)[8] = 110));
                    (void)(((sl_pfx)[9] = 103));
                    (void)(((sl_pfx)[10] = 95));
                    (void)(((sl_pfx)[11] = 0));
                    (void)((sl_plen = 11));
                  } else {
                    if (((((e.struct_lit_struct_name_len) ==7) && (((e.struct_lit_struct_name))[0] ==83)) && (((e.struct_lit_struct_name))[3] ==86))) {
                      (void)(((sl_pfx)[0] = 115));
                      (void)(((sl_pfx)[1] = 116));
                      (void)(((sl_pfx)[2] = 100));
                      (void)(((sl_pfx)[3] = 95));
                      (void)(((sl_pfx)[4] = 115));
                      (void)(((sl_pfx)[5] = 116));
                      (void)(((sl_pfx)[6] = 114));
                      (void)(((sl_pfx)[7] = 105));
                      (void)(((sl_pfx)[8] = 110));
                      (void)(((sl_pfx)[9] = 103));
                      (void)(((sl_pfx)[10] = 95));
                      (void)(((sl_pfx)[11] = 0));
                      (void)((sl_plen = 11));
                    } else {
                      if ((((e.struct_lit_struct_name_len) ==9) && (((e.struct_lit_struct_name))[0] ==84))) {
                        (void)(((sl_pfx)[0] = 115));
                        (void)(((sl_pfx)[1] = 116));
                        (void)(((sl_pfx)[2] = 100));
                        (void)(((sl_pfx)[3] = 95));
                        (void)(((sl_pfx)[4] = 110));
                        (void)(((sl_pfx)[5] = 101));
                        (void)(((sl_pfx)[6] = 116));
                        (void)(((sl_pfx)[7] = 95));
                        (void)(((sl_pfx)[8] = 0));
                        (void)((sl_plen = 8));
                      } else {
                        if ((((e.struct_lit_struct_name_len) ==11) && (((e.struct_lit_struct_name))[0] ==84))) {
                          (void)(((sl_pfx)[0] = 115));
                          (void)(((sl_pfx)[1] = 116));
                          (void)(((sl_pfx)[2] = 100));
                          (void)(((sl_pfx)[3] = 95));
                          (void)(((sl_pfx)[4] = 110));
                          (void)(((sl_pfx)[5] = 101));
                          (void)(((sl_pfx)[6] = 116));
                          (void)(((sl_pfx)[7] = 95));
                          (void)(((sl_pfx)[8] = 0));
                          (void)((sl_plen = 8));
                        } else {
                          if (((((e.struct_lit_struct_name_len) ==10) && (((e.struct_lit_struct_name))[0] ==70)) && (((e.struct_lit_struct_name))[1] ==115))) {
                            (void)(((sl_pfx)[0] = 115));
                            (void)(((sl_pfx)[1] = 116));
                            (void)(((sl_pfx)[2] = 100));
                            (void)(((sl_pfx)[3] = 95));
                            (void)(((sl_pfx)[4] = 102));
                            (void)(((sl_pfx)[5] = 115));
                            (void)(((sl_pfx)[6] = 95));
                            (void)(((sl_pfx)[7] = 0));
                            (void)((sl_plen = 7));
                          } else {
                            if (((((e.struct_lit_struct_name_len) ==5) && (((e.struct_lit_struct_name))[0] ==73)) && (((e.struct_lit_struct_name))[1] ==111))) {
                              (void)(((sl_pfx)[0] = 115));
                              (void)(((sl_pfx)[1] = 116));
                              (void)(((sl_pfx)[2] = 100));
                              (void)(((sl_pfx)[3] = 95));
                              (void)(((sl_pfx)[4] = 105));
                              (void)(((sl_pfx)[5] = 111));
                              (void)(((sl_pfx)[6] = 95));
                              (void)(((sl_pfx)[7] = 115));
                              (void)(((sl_pfx)[8] = 121));
                              (void)(((sl_pfx)[9] = 110));
                              (void)(((sl_pfx)[10] = 99));
                              (void)(((sl_pfx)[11] = 95));
                              (void)(((sl_pfx)[12] = 0));
                              (void)((sl_plen = 12));
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      uint8_t open[9] = {40, 115, 116, 114, 117, 99, 116, 32, 0};
      if ((codegen_emit_bytes_9(out, open, 8) !=0)) {
        return -(1);
      }
      if ((((bare_user_lit ==0) && (sl_plen > 0)) && (codegen_emit_bytes_from_ptr(out, &((sl_pfx)[0]), sl_plen) !=0))) {
        return -(1);
      }
      if ((codegen_emit_bytes_64(out, &(((e.struct_lit_struct_name))[0]), (e.struct_lit_struct_name_len)) !=0)) {
        return -(1);
      }
      uint8_t open2[5] = {41, 123, 32, 0, 0};
      if ((codegen_emit_bytes_5(out, open2, 3) !=0)) {
        return -(1);
      }
      int32_t fi = 0;
      int32_t nf_codegen = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
      while ((fi < nf_codegen)) {
        uint8_t sl_fnbuf[64] = {};
        int32_t flen = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, fi);
        uint8_t eq[4] = {32, 61, 32, 0};
        int32_t init_ref = pipeline_expr_struct_lit_init_ref(arena, expr_ref, fi);
        if ((fi > 0)) {
          uint8_t comma[3] = {44, 32, 0};
          if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
            return -(1);
          }
        }
        if ((codegen_append_byte(out, 46) !=0)) {
          return -(1);
        }
        (void)(pipeline_expr_struct_lit_field_name_into(arena, expr_ref, fi, &((sl_fnbuf)[0])));
        if ((flen > 64)) {
          if ((codegen_emit_bytes_64(out, &((sl_fnbuf)[0]), 64) !=0)) {
            return -(1);
          }
        } else {
          if ((codegen_emit_bytes_64(out, &((sl_fnbuf)[0]), flen) !=0)) {
            return -(1);
          }
        }
        if ((codegen_emit_bytes_4(out, eq, 3) !=0)) {
          return -(1);
        }
        if (!(ast_ref_is_null(init_ref))) {
          struct ast_Expr init_e = ast_ast_arena_expr_get(arena, init_ref);
          if (((init_e.kind) ==46)) {
            if (((init_e.array_lit_num_elems) ==0)) {
              uint8_t zero_init[6] = {123, 32, 48, 32, 125, 0};
              if ((codegen_emit_bytes_6(out, zero_init, 5) !=0)) {
                return -(1);
              }
            } else {
              if ((codegen_emit_braced_array_lit_init(arena, out, init_ref, ctx) !=0)) {
                return -(1);
              }
            }
          } else {
            /* PLATFORM: SHARED — array field ← VAR/param: expand to { src[0], … }. */
            int32_t use_elem_expand = 0;
            int32_t arr_sz = 0;
            int32_t flen_lk = flen;
            int32_t ftr = 0;
            if ((flen_lk > 64)) {
              flen_lk = 64;
            }
            ftr = codegen_lookup_struct_field_type_ref(arena, ctx, &(((e.struct_lit_struct_name))[0]), (e.struct_lit_struct_name_len), &((sl_fnbuf)[0]), flen_lk);
            if (((!(ast_ref_is_null(ftr))) && (pipeline_type_kind_ord_at(arena, ftr) == 10))) {
              arr_sz = pipeline_type_array_size_at(arena, ftr);
              if (((arr_sz > 0) && (arr_sz <= 512))) {
                use_elem_expand = 1;
              }
            } else {
              if (((!(ast_ref_is_null((init_e.resolved_type_ref)))) && (pipeline_type_kind_ord_at(arena, (init_e.resolved_type_ref)) == 10))) {
                arr_sz = pipeline_type_array_size_at(arena, (init_e.resolved_type_ref));
                if (((arr_sz > 0) && (arr_sz <= 512))) {
                  use_elem_expand = 1;
                }
              }
            }
            if ((use_elem_expand != 0)) {
              int32_t ai = 0;
              if ((codegen_append_byte(out, 123) !=0)) {
                return -(1);
              }
              while ((ai < arr_sz)) {
                if ((ai > 0)) {
                  uint8_t cm[3] = {44, 32, 0};
                  if ((codegen_emit_bytes_3(out, cm, 2) !=0)) {
                    return -(1);
                  }
                }
                if ((codegen_emit_expr(arena, out, init_ref, ctx) !=0)) {
                  return -(1);
                }
                if ((codegen_append_byte(out, 91) !=0)) {
                  return -(1);
                }
                if ((codegen_format_int(out, ((int64_t)(ai))) !=0)) {
                  return -(1);
                }
                if ((codegen_append_byte(out, 93) !=0)) {
                  return -(1);
                }
                (void)((ai = (ai + 1)));
              }
              if ((codegen_append_byte(out, 125) !=0)) {
                return -(1);
              }
            } else {
              if ((codegen_emit_expr(arena, out, init_ref, ctx) !=0)) {
                return -(1);
              }
            }
          }
        }
        (void)((fi = (fi + 1)));
      }
      uint8_t close[4] = {32, 125, 0, 0};
      return codegen_emit_bytes_4(out, close, 2);
    }
    if (((e.kind) ==46)) {
      int32_t n = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
      int32_t elem_type_ref = 0;
      int32_t is_slice = 0;
      int32_t is_vector = 0;
      if (((!(ast_ref_is_null((e.resolved_type_ref))) && ((e.resolved_type_ref) > 0)) && ((e.resolved_type_ref) <=(arena->num_types)))) {
        struct ast_Type ty = ast_ast_arena_type_get(arena, (e.resolved_type_ref));
        if (((ty.kind) ==11)) {
          (void)((is_slice = 1));
          (void)((elem_type_ref = (ty.elem_type_ref)));
        } else {
          if (((ty.kind) ==10)) {
            (void)((elem_type_ref = (ty.elem_type_ref)));
          } else {
            if (((ty.kind) ==13)) {
              (void)((is_vector = 1));
            } else {
              if ((((ty.kind) ==8) && ((ty.name_len) >=5))) {
                int32_t ni = 0;
                while ((ni < (ty.name_len))) {
                  if ((((ty.name))[ni] ==120)) {
                    (void)((is_vector = 1));
                    (void)((ni = (ty.name_len)));
                  } else {
                    (void)((ni = (ni + 1)));
                  }
                }
              }
            }
          }
        }
      }
      if ((is_vector !=0)) {
        int32_t vai = 0;
        uint8_t vclose[4] = {32, 125, 0, 0};
        if ((codegen_append_byte(out, 40) !=0)) {
          return -(1);
        }
        if ((codegen_emit_type(arena, out, (e.resolved_type_ref), ((uint8_t *)(0)), 0, ctx) !=0)) {
          return -(1);
        }
        if ((codegen_append_byte(out, 41) !=0)) {
          return -(1);
        }
        if ((codegen_append_byte(out, 123) !=0)) {
          return -(1);
        }
        while ((vai < n)) {
          if ((vai > 0)) {
            uint8_t comma[3] = {44, 32, 0};
            if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
              return -(1);
            }
          }
          if ((!(ast_ref_is_null(pipeline_expr_array_lit_elem_ref(arena, expr_ref, vai))) && (codegen_emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, expr_ref, vai), ctx) !=0))) {
            return -(1);
          }
          (void)((vai = (vai + 1)));
        }
        return codegen_emit_bytes_4(out, vclose, 2);
      }
      if (((elem_type_ref ==0) && (n > 0))) {
        int32_t first_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, 0);
        if (!(ast_ref_is_null(first_ref))) {
          struct ast_Expr first_e = ast_ast_arena_expr_get(arena, first_ref);
          (void)((elem_type_ref = (first_e.resolved_type_ref)));
        }
      }
      if ((is_slice !=0)) {
        uint8_t lp[3] = {40, 0, 0};
        if ((codegen_append_byte(out, 40) !=0)) {
          return -(1);
        }
        if ((codegen_emit_type(arena, out, (e.resolved_type_ref), ((uint8_t *)(0)), 0, ctx) !=0)) {
          uint8_t fallback[9] = {117, 105, 110, 116, 56, 95, 116, 0, 0};
          if ((codegen_emit_bytes_9(out, fallback, 7) !=0)) {
            return -(1);
          }
        }
        uint8_t slice_mid[22] = {41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        if ((codegen_emit_bytes_22(out, slice_mid, 11) !=0)) {
          return -(1);
        }
        if ((codegen_append_byte(out, 40) !=0)) {
          return -(1);
        }
        if ((!(ast_ref_is_null(elem_type_ref)) && (codegen_emit_type(arena, out, elem_type_ref, ((uint8_t *)(0)), 0, ctx) !=0))) {
          uint8_t fallback[9] = {117, 105, 110, 116, 56, 95, 116, 0, 0};
          if ((codegen_emit_bytes_9(out, fallback, 7) !=0)) {
            return -(1);
          }
        }
        uint8_t arr[5] = {91, 93, 41, 123, 0};
        if ((codegen_emit_bytes_5(out, arr, 4) !=0)) {
          return -(1);
        }
      } else {
        uint8_t arr[5] = {91, 93, 41, 123, 0};
        if ((codegen_append_byte(out, 40) !=0)) {
          return -(1);
        }
        if ((ast_ref_is_null(elem_type_ref) || (codegen_emit_type(arena, out, elem_type_ref, ((uint8_t *)(0)), 0, ctx) !=0))) {
          uint8_t fallback[9] = {117, 105, 110, 116, 56, 95, 116, 0, 0};
          if ((codegen_emit_bytes_9(out, fallback, 7) !=0)) {
            return -(1);
          }
        }
        if ((codegen_emit_bytes_5(out, arr, 4) !=0)) {
          return -(1);
        }
      }
      int32_t ai = 0;
      while ((ai < n)) {
        if ((ai > 0)) {
          uint8_t comma[3] = {44, 32, 0};
          if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
            return -(1);
          }
        }
        if ((!(ast_ref_is_null(pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai))) && (codegen_emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai), ctx) !=0))) {
          return -(1);
        }
        (void)((ai = (ai + 1)));
      }
      if ((is_slice !=0)) {
        uint8_t slice_end[22] = {32, 125, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0, 0, 0, 0, 0, 0};
        if ((codegen_emit_bytes_22(out, slice_end, 14) !=0)) {
          return -(1);
        }
        if ((codegen_format_int(out, ai) !=0)) {
          return -(1);
        }
        if ((codegen_append_byte(out, 32) !=0)) {
          return -(1);
        }
        if ((codegen_append_byte(out, 125) !=0)) {
          return -(1);
        }
        return codegen_append_byte(out, 41);
      }
      uint8_t close[4] = {32, 125, 0, 0};
      return codegen_emit_bytes_4(out, close, 2);
    }
    if (((e.kind) ==50)) {
      return codegen_append_byte(out, 48);
    }
    return -(1);
  }
  return 0;
}
int32_t codegen_callee_var_is_string_new(struct ast_Expr e) {
  if (((e.kind) !=3)) {
    return 0;
  }
  if (((e.var_name_len) ==10)) {
    uint8_t expect_sn[10] = {115, 116, 114, 105, 110, 95, 110, 101, 119, 0};
    int32_t i_sn = 0;
    while ((i_sn < 9)) {
      if ((((e.var_name))[i_sn] !=(expect_sn)[i_sn])) {
        return 0;
      }
      (void)((i_sn = (i_sn + 1)));
    }
    return 1;
  }
  if (((e.var_name_len) ==22)) {
    uint8_t expect_ssn[22] = {115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 115, 116, 114, 105, 110, 95, 110, 101, 119, 0, 0};
    int32_t i_ssn = 0;
    while ((i_ssn < 20)) {
      if ((((e.var_name))[i_ssn] !=(expect_ssn)[i_ssn])) {
        return 0;
      }
      (void)((i_ssn = (i_ssn + 1)));
    }
    return 1;
  }
  return 0;
}
int32_t codegen_emit_run_defers(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t indent, struct ast_PipelineDepCtx * ctx) {
  {
    int32_t ndef = 0;
    while ((ndef < 256)) {
      if ((pipeline_block_defer_body_ref(arena, block_ref, ndef) <=0)) {
        break;
      }
      (void)((ndef = (ndef + 1)));
    }
    int32_t di = (ndef - 1);
    while ((di >=0)) {
      int32_t dbody = pipeline_block_defer_body_ref(arena, block_ref, di);
      if ((dbody > 0)) {
        if ((codegen_emit_block(arena, out, dbody, indent, ctx) !=0)) {
          return -(1);
        }
      }
      (void)((di = (di - 1)));
    }
    return 0;
  }
  return 0;
}
int32_t codegen_current_func_returns_void(struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx) {
  {
    struct ast_Module * mod = (ctx->current_codegen_module);
    if (((((ctx ==((struct ast_PipelineDepCtx *)(0))) || ((ctx->current_codegen_module) ==((struct ast_Module *)(0)))) || ((ctx->current_codegen_arena) !=arena)) || ((ctx->current_func_index) < 0))) {
      return 0;
    }
    if (((ctx->current_func_index) >=(mod->num_funcs))) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(mod, (ctx->current_func_index))) ==((int32_t)(16)))) {
      return 1;
    }
    return 0;
  }
  return 0;
}
/* PLATFORM: SHARED — name==main helper for void main → exit 0 (align codegen.x). */
int32_t codegen_current_func_is_named_main(struct ast_PipelineDepCtx * ctx) {
  {
    struct ast_Module * mod;
    int32_t nlen;
    uint8_t nm[64];
    if (((ctx == ((struct ast_PipelineDepCtx *)(0))) || ((ctx->current_codegen_module) == ((struct ast_Module *)(0))) || ((ctx->current_func_index) < 0))) {
      return 0;
    }
    mod = (ctx->current_codegen_module);
    if (((ctx->current_func_index) >= (mod->num_funcs))) {
      return 0;
    }
    nlen = pipeline_module_func_name_len_at(mod, (ctx->current_func_index));
    if ((nlen != 4)) {
      return 0;
    }
    (void)(codegen_copy_func_name64_from_module(mod, (ctx->current_func_index), &((nm)[0])));
    if ((((((nm)[0] == 109) && ((nm)[1] == 97)) && ((nm)[2] == 105)) && ((nm)[3] == 110))) {
      return 1;
    }
    return 0;
  }
  return 0;
}
int32_t codegen_emit_return_stmt_with_context(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t indent, int32_t operand_ref, struct ast_PipelineDepCtx * ctx, int32_t fn_ret_void) {
  {
    uint8_t ret[8] = {114, 101, 116, 117, 114, 110, 32, 0};
    uint8_t sc[4] = {59, 10, 0, 0};
    if ((fn_ret_void !=0)) {
      uint8_t retv[9] = {114, 101, 116, 117, 114, 110, 59, 10, 0};
      if (!(ast_ref_is_null(operand_ref))) {
        uint8_t v[9] = {40, 118, 111, 105, 100, 41, 40, 0, 0};
        uint8_t scv[4] = {41, 59, 10, 0};
        if ((codegen_emit_indent(out, indent) !=0)) {
          return -(1);
        }
        if ((codegen_emit_bytes_9(out, v, 7) !=0)) {
          return -(1);
        }
        if ((codegen_emit_expr(arena, out, operand_ref, ctx) !=0)) {
          return -(1);
        }
        if ((codegen_emit_bytes_4(out, scv, 3) !=0)) {
          return -(1);
        }
      }
      if ((codegen_emit_indent(out, indent) !=0)) {
        return -(1);
      }
      /* PLATFORM: SHARED — void main → return 0 (C int entry). */
      if ((codegen_current_func_is_named_main(ctx) != 0)) {
        uint8_t ret0[12] = {114, 101, 116, 117, 114, 110, 32, 48, 59, 10, 0, 0};
        return codegen_emit_bytes_from_ptr(out, &((ret0)[0]), 10);
      }
      return codegen_emit_bytes_9(out, retv, 8);
    }
    if (!(ast_ref_is_null(operand_ref))) {
      if ((pipeline_expr_kind_ord_at(arena, operand_ref) ==((int32_t)(42)))) {
        uint8_t sc_panic[4] = {59, 10, 0, 0};
        if ((codegen_emit_indent(out, indent) !=0)) {
          return -(1);
        }
        if ((codegen_emit_expr(arena, out, operand_ref, ctx) !=0)) {
          return -(1);
        }
        return codegen_emit_bytes_4(out, sc_panic, 2);
      }
    }
    /* Cap-T001 filler return 0 for by-value struct → compound zero (host-cc). */
    if ((ctx != ((struct ast_PipelineDepCtx *)(0))) && (ctx->current_codegen_module != ((struct ast_Module *)(0)))
        && (ctx->current_func_index >= 0) && (ctx->current_func_index < (ctx->current_codegen_module->num_funcs))) {
      int32_t rty = pipeline_module_func_return_type_at(ctx->current_codegen_module, ctx->current_func_index);
      if ((!(ast_ref_is_null(rty))) && (pipeline_type_kind_ord_at(arena, rty) == 8)) {
        int32_t use_struct_zero = 0;
        if (ast_ref_is_null(operand_ref)) {
          (void)((use_struct_zero = 1));
        } else if ((pipeline_expr_kind_ord_at(arena, operand_ref) == 0)) {
          struct ast_Expr lit = ast_ast_arena_expr_get(arena, operand_ref);
          if (((lit.int_val) == 0)) {
            (void)((use_struct_zero = 1));
          }
        }
        if ((use_struct_zero != 0)) {
          uint8_t ret_open[8] = {114, 101, 116, 117, 114, 110, 32, 40};
          uint8_t ret_close[8] = {41, 123, 48, 125, 59, 10, 0, 0};
          if ((codegen_emit_indent(out, indent) !=0)) {
            return -(1);
          }
          if ((codegen_emit_bytes_from_ptr(out, &((ret_open)[0]), 8) !=0)) {
            return -(1);
          }
          if ((codegen_emit_type(arena, out, rty, ((uint8_t *)(0)), 0, ctx) !=0)) {
            return -(1);
          }
          if ((codegen_emit_bytes_from_ptr(out, &((ret_close)[0]), 6) !=0)) {
            return -(1);
          }
          return 0;
        }
      }
    }
    if ((codegen_emit_indent(out, indent) !=0)) {
      return -(1);
    }
    if ((codegen_emit_bytes_8(out, ret, 7) !=0)) {
      return -(1);
    }
    if ((!(ast_ref_is_null(operand_ref)) && (codegen_emit_expr(arena, out, operand_ref, ctx) !=0))) {
      return -(1);
    }
    return codegen_emit_bytes_4(out, sc, 2);
  }
  return 0;
}
int32_t codegen_emit_block_final_expr(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t final_ref, int32_t indent, struct ast_PipelineDepCtx * ctx, int32_t fn_ret_void) {
  if (ast_ref_is_null(final_ref)) {
    return 0;
  }
  struct ast_Expr fe = ast_ast_arena_expr_get(arena, final_ref);
  if (((fe.kind) ==39)) {
    return codegen_emit_break_stmt(out, indent);
  }
  if (((fe.kind) ==40)) {
    return codegen_emit_continue_stmt(out, indent);
  }
  if (((fe.kind) ==41)) {
    return codegen_emit_return_stmt_with_context(arena, out, indent, (fe.unary_operand_ref), ctx, fn_ret_void);
  }
  int32_t parent_br = 0;
  int32_t is_func_body = 0;
  if (((block_ref > 0) && (block_ref <=(arena->num_blocks)))) {
    struct ast_Block blk = ast_ast_arena_block_get(arena, block_ref);
    (void)((parent_br = (blk.parent_block_ref)));
  }
  /* PLATFORM: SHARED — only function body final uses return; EXPR_BLOCK value
   * contexts (if {1} else {0} as call arg) must emit expr; so ({1;}) is int. */
  if (((ctx != ((struct ast_PipelineDepCtx *)(0))) && ((ctx->current_codegen_module) != ((struct ast_Module *)(0))) && ((ctx->current_func_index) >= 0))) {
    int32_t fbody = pipeline_module_func_body_ref_at((ctx->current_codegen_module), (ctx->current_func_index));
    if (((!(ast_ref_is_null(fbody))) && (fbody == block_ref))) {
      (void)((is_func_body = 1));
    }
  }
  if (((parent_br > 0) || (is_func_body == 0))) {
    uint8_t end[4] = {59, 10, 0, 0};
    if ((codegen_emit_indent(out, indent) !=0)) {
      return -(1);
    }
    if ((codegen_emit_expr(arena, out, final_ref, ctx) !=0)) {
      return -(1);
    }
    return codegen_emit_bytes_from_ptr(out, &((end)[0]), 2);
  }
  return codegen_emit_return_stmt_with_context(arena, out, indent, final_ref, ctx, fn_ret_void);
}
int32_t codegen_emit_block(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t indent, struct ast_PipelineDepCtx * ctx) {
  {
    uint8_t blk_prefix[128] = {};
    int32_t blk_prefix_len = codegen_emit_prefix_len_from_ctx(ctx, &((blk_prefix)[0]), 128);
    int32_t fn_ret_void = codegen_current_func_returns_void(arena, ctx);
    if (ast_ref_is_null(block_ref)) {
      return 0;
    }
    if (((block_ref <=0) || (block_ref > (arena->num_blocks)))) {
      return 0;
    }
    if ((ast_ast_block_num_stmt_order(arena, block_ref) > 0)) {
      int32_t pre_li = 0;
      while ((pre_li < ast_ast_block_num_lets(arena, block_ref))) {
        if ((codegen_block_stmt_order_has_let(arena, block_ref, pre_li) ==0)) {
          uint8_t lname_pre[64] = {};
          (void)(pipeline_block_let_name_copy64(arena, block_ref, pre_li, &((lname_pre)[0])));
          int32_t lname_len_pre = pipeline_block_let_name_len(arena, block_ref, pre_li);
          int32_t let_type_pre = pipeline_block_let_type_ref(arena, block_ref, pre_li);
          int32_t linit_pre = pipeline_block_let_init_ref(arena, block_ref, pre_li);
          if ((codegen_emit_indent(out, indent) !=0)) {
            return -(1);
          }
          int32_t type_emitted_pre = 0;
          int32_t use_local_array_pre = 0;
          if ((!(ast_ref_is_null(let_type_pre)) && (pipeline_type_kind_ord_at(arena, let_type_pre) ==10))) {
            (void)((use_local_array_pre = 1));
          }
          if ((use_local_array_pre !=0)) {
            if ((codegen_emit_local_fixed_array_elem_type(arena, out, let_type_pre, ctx) !=0)) {
              return -(1);
            }
            (void)((type_emitted_pre = 1));
          }
          if ((type_emitted_pre ==0)) {
            if ((codegen_emit_type(arena, out, let_type_pre, ((uint8_t *)(0)), 0, ctx) !=0)) {
              return -(1);
            }
          }
          if ((codegen_append_byte(out, 32) !=0)) {
            return -(1);
          }
          if (((lname_len_pre > 0) && ((lname_pre)[0] > 32))) {
            if ((codegen_emit_bytes_64(out, &((lname_pre)[0]), lname_len_pre) !=0)) {
              return -(1);
            }
          } else {
            uint8_t place_pre[4] = {95, 108, 48, 0};
            if ((codegen_emit_bytes_4(out, place_pre, 2) !=0)) {
              return -(1);
            }
            if ((codegen_format_int(out, pre_li) !=0)) {
              return -(1);
            }
          }
          if ((use_local_array_pre !=0)) {
            if ((codegen_emit_local_fixed_array_suffix(arena, out, let_type_pre) !=0)) {
              return -(1);
            }
          }
          uint8_t eq_pre[4] = {32, 61, 32, 0};
          if ((codegen_emit_bytes_4(out, eq_pre, 3) !=0)) {
            return -(1);
          }
          if ((codegen_emit_expr(arena, out, linit_pre, ctx) !=0)) {
            return -(1);
          }
          uint8_t sc_pre[3] = {59, 10, 0};
          if ((codegen_emit_bytes_3(out, sc_pre, 2) !=0)) {
            return -(1);
          }
        }
        (void)((pre_li = (pre_li + 1)));
      }
      int32_t si = 0;
      while ((si < ast_ast_block_num_stmt_order(arena, block_ref))) {
        uint8_t k = ast_ast_block_stmt_order_kind(arena, block_ref, si);
        int32_t idx = ast_ast_block_stmt_order_idx(arena, block_ref, si);
        if ((k ==0)) {
          if (((idx >=0) && (idx < ast_ast_block_num_consts(arena, block_ref)))) {
            uint8_t cname_buf[64] = {};
            (void)(pipeline_block_const_name_copy64(arena, block_ref, idx, &((cname_buf)[0])));
            int32_t cname_len = pipeline_block_const_name_len(arena, block_ref, idx);
            int32_t ctype_ref = pipeline_block_const_type_ref(arena, block_ref, idx);
            int32_t cinit_ref = pipeline_block_const_init_ref(arena, block_ref, idx);
            if ((codegen_emit_indent(out, indent) !=0)) {
              return -(1);
            }
            if ((codegen_emit_type(arena, out, ctype_ref, ((uint8_t *)(0)), 0, ctx) !=0)) {
              return -(1);
            }
            uint8_t sp[3] = {32, 0, 0};
            if ((codegen_emit_bytes_3(out, sp, 1) !=0)) {
              return -(1);
            }
            if (((cname_len > 0) && ((cname_buf)[0] > 32))) {
              if ((codegen_emit_bytes_64(out, &((cname_buf)[0]), cname_len) !=0)) {
                return -(1);
              }
            } else {
              uint8_t place[4] = {95, 99, 48, 0};
              if ((codegen_emit_bytes_4(out, place, 2) !=0)) {
                return -(1);
              }
              if ((codegen_format_int(out, idx) !=0)) {
                return -(1);
              }
            }
            uint8_t eq[4] = {32, 61, 32, 0};
            if ((codegen_emit_bytes_4(out, eq, 3) !=0)) {
              return -(1);
            }
            if ((codegen_emit_expr(arena, out, cinit_ref, ctx) !=0)) {
              return -(1);
            }
            uint8_t sc[3] = {59, 10, 0};
            if ((codegen_emit_bytes_3(out, sc, 2) !=0)) {
              return -(1);
            }
          }
        } else {
          if ((k ==1)) {
            if (((idx >=0) && (idx < ast_ast_block_num_lets(arena, block_ref)))) {
              uint8_t lname_buf[64] = {};
              (void)(pipeline_block_let_name_copy64(arena, block_ref, idx, &((lname_buf)[0])));
              int32_t lname_len = pipeline_block_let_name_len(arena, block_ref, idx);
              int32_t let_type_ref = pipeline_block_let_type_ref(arena, block_ref, idx);
              int32_t linit_ref = pipeline_block_let_init_ref(arena, block_ref, idx);
              if ((codegen_emit_indent(out, indent) !=0)) {
                return -(1);
              }
              int32_t type_emitted = 0;
              int32_t use_local_array = 0;
              if ((!(ast_ref_is_null(let_type_ref)) && (pipeline_type_kind_ord_at(arena, let_type_ref) ==10))) {
                (void)((use_local_array = 1));
              }
              if ((use_local_array !=0)) {
                if ((codegen_emit_local_fixed_array_elem_type(arena, out, let_type_ref, ctx) !=0)) {
                  return -(1);
                }
                (void)((type_emitted = 1));
              }
              if (((!(ast_ref_is_null(linit_ref)) && (linit_ref > 0)) && (linit_ref <=(arena->num_exprs)))) {
                struct ast_Expr init_e = ast_ast_arena_expr_get(arena, linit_ref);
                if ((((type_emitted ==0) && ((init_e.kind) ==46)) && (codegen_type_array_elem_is_u8(arena, let_type_ref) !=0))) {
                  uint8_t u8ptr[9] = {117, 105, 110, 116, 56, 95, 116, 32, 0};
                  if ((codegen_emit_bytes_9(out, u8ptr, 7) !=0)) {
                    return -(1);
                  }
                  if ((codegen_append_byte(out, 42) !=0)) {
                    return -(1);
                  }
                  (void)((type_emitted = 1));
                }
                if (((((type_emitted ==0) && !(ast_ref_is_null((init_e.resolved_type_ref)))) && ((init_e.resolved_type_ref) > 0)) && ((init_e.resolved_type_ref) <=(arena->num_types)))) {
                  struct ast_Type rt = ast_ast_arena_type_get(arena, (init_e.resolved_type_ref));
                  if ((((rt.kind) ==8) && ((rt.name_len) >=6))) {
                    int32_t n0 = ((rt.name_len) - 6);
                    if (((((((((rt.name))[n0] ==83) && (((rt.name))[(n0 + 1)] ==116)) && (((rt.name))[(n0 + 2)] ==114)) && (((rt.name))[(n0 + 3)] ==105)) && (((rt.name))[(n0 + 4)] ==110)) && (((rt.name))[(n0 + 5)] ==103))) {
                      uint8_t str_ty[7] = {83, 116, 114, 105, 110, 103, 0};
                      if ((codegen_emit_bytes_from_ptr(out, &((str_ty)[0]), 6) !=0)) {
                        return -(1);
                      }
                      if ((codegen_append_byte(out, 32) !=0)) {
                        return -(1);
                      }
                      (void)((type_emitted = 1));
                    }
                  }
                }
                if ((((((type_emitted ==0) && ((init_e.kind) ==48)) && !(ast_ref_is_null((init_e.call_callee_ref)))) && ((init_e.call_callee_ref) > 0)) && ((init_e.call_callee_ref) <=(arena->num_exprs)))) {
                  struct ast_Expr callee_let = ast_ast_arena_expr_get(arena, (init_e.call_callee_ref));
                  if (((callee_let.kind) ==3)) {
                    if ((codegen_callee_var_is_string_new(callee_let) !=0)) {
                      uint8_t str_ty[7] = {83, 116, 114, 105, 110, 103, 0};
                      if ((codegen_emit_bytes_from_ptr(out, &((str_ty)[0]), 6) !=0)) {
                        return -(1);
                      }
                      if ((codegen_append_byte(out, 32) !=0)) {
                        return -(1);
                      }
                      (void)((type_emitted = 1));
                    }
                  }
                }
              }
              if ((type_emitted ==0)) {
                if ((((ast_ref_is_null(let_type_ref) && !(ast_ref_is_null(linit_ref))) && (linit_ref > 0)) && (linit_ref <=(arena->num_exprs)))) {
                  struct ast_Expr init_e = ast_ast_arena_expr_get(arena, linit_ref);
                  if (!(ast_ref_is_null((init_e.resolved_type_ref)))) {
                    (void)((let_type_ref = (init_e.resolved_type_ref)));
                  }
                }
                if ((codegen_emit_type(arena, out, let_type_ref, ((uint8_t *)(0)), 0, ctx) !=0)) {
                  return -(1);
                }
              }
              if ((codegen_append_byte(out, 32) !=0)) {
                return -(1);
              }
              if (((lname_len > 0) && ((lname_buf)[0] > 32))) {
                if ((codegen_emit_bytes_64(out, &((lname_buf)[0]), lname_len) !=0)) {
                  return -(1);
                }
              } else {
                uint8_t place[4] = {95, 108, 48, 0};
                if ((codegen_emit_bytes_4(out, place, 2) !=0)) {
                  return -(1);
                }
                if ((codegen_format_int(out, idx) !=0)) {
                  return -(1);
                }
              }
              if ((use_local_array !=0)) {
                if ((codegen_emit_local_fixed_array_suffix(arena, out, let_type_ref) !=0)) {
                  return -(1);
                }
              }
              uint8_t eq[4] = {32, 61, 32, 0};
              if ((codegen_emit_bytes_4(out, eq, 3) !=0)) {
                return -(1);
              }
              int32_t slice_init = 0;
              if (!(ast_ref_is_null(linit_ref))) {
                (void)((slice_init = codegen_try_emit_slice_init_from_array_var(arena, out, block_ref, idx, let_type_ref, linit_ref)));
              }
              if (ast_ref_is_null(linit_ref)) {
                uint8_t zinit_omit2[6] = {123, 32, 48, 32, 125, 0};
                if ((codegen_emit_bytes_6(out, zinit_omit2, 5) !=0)) {
                  return -(1);
                }
              } else {
                if ((slice_init ==1)) {
                } else {
                  if ((slice_init < 0)) {
                    return -(1);
                  } else {
                    if (((((use_local_array !=0) && !(ast_ref_is_null(linit_ref))) && (linit_ref > 0)) && (linit_ref <=(arena->num_exprs)))) {
                      struct ast_Expr init_e2 = ast_ast_arena_expr_get(arena, linit_ref);
                      if (((init_e2.kind) ==46)) {
                        if ((codegen_emit_braced_array_lit_init(arena, out, linit_ref, ctx) !=0)) {
                          return -(1);
                        }
                      } else {
                        if ((((init_e2.kind) ==0) && ((init_e2.int_val) ==0))) {
                          uint8_t zinit[6] = {123, 32, 48, 32, 125, 0};
                          if ((codegen_emit_bytes_6(out, zinit, 5) !=0)) {
                            return -(1);
                          }
                        } else {
                          if ((codegen_emit_expr(arena, out, linit_ref, ctx) !=0)) {
                            return -(1);
                          }
                        }
                      }
                    } else {
                      int32_t use_vec_z = 0;
                      int32_t use_vec_braced = 0;
                      if ((((!(ast_ref_is_null(linit_ref)) && (linit_ref > 0)) && (linit_ref <=(arena->num_exprs))) && !(ast_ref_is_null(let_type_ref)))) {
                        struct ast_Expr init_ez = ast_ast_arena_expr_get(arena, linit_ref);
                        int32_t tk_z = pipeline_type_kind_ord_at(arena, let_type_ref);
                        int32_t is_vec_ty = 0;
                        if ((tk_z ==13)) {
                          (void)((is_vec_ty = 1));
                        } else {
                          if ((tk_z ==8)) {
                            uint8_t vzn[64] = {};
                            int32_t vzn_l = pipeline_type_named_name_into(arena, let_type_ref, &((vzn)[0]));
                            int32_t vi = 0;
                            while ((vi < vzn_l)) {
                              if (((vzn)[vi] ==120)) {
                                (void)((is_vec_ty = 1));
                                (void)((vi = vzn_l));
                              } else {
                                (void)((vi = (vi + 1)));
                              }
                            }
                          }
                        }
                        if ((is_vec_ty !=0)) {
                          if ((((init_ez.kind) ==0) && ((init_ez.int_val) ==0))) {
                            (void)((use_vec_z = 1));
                          } else {
                            if (((init_ez.kind) ==46)) {
                              (void)((use_vec_braced = 1));
                            }
                          }
                        }
                      }
                      if ((use_vec_z !=0)) {
                        uint8_t vz[6] = {123, 32, 48, 32, 125, 0};
                        if ((codegen_emit_bytes_6(out, vz, 5) !=0)) {
                          return -(1);
                        }
                      } else {
                        if ((use_vec_braced !=0)) {
                          if ((codegen_emit_braced_array_lit_init(arena, out, linit_ref, ctx) !=0)) {
                            return -(1);
                          }
                        } else {
                          if ((codegen_emit_expr(arena, out, linit_ref, ctx) !=0)) {
                            return -(1);
                          }
                        }
                      }
                    }
                  }
                }
              }
              uint8_t sc[3] = {59, 10, 0};
              if ((codegen_emit_bytes_3(out, sc, 2) !=0)) {
                return -(1);
              }
            }
          } else {
            if ((k ==2)) {
              if (((idx >=0) && (idx < ast_ast_block_num_expr_stmts(arena, block_ref)))) {
                int32_t ex_ref = ast_ast_block_expr_stmt_ref(arena, block_ref, idx);
                struct ast_Expr st = ast_ast_arena_expr_get(arena, ex_ref);
                if (((st.kind) ==41)) {
                  if ((codegen_emit_return_stmt_with_context(arena, out, indent, (st.unary_operand_ref), ctx, fn_ret_void) !=0)) {
                    return -(1);
                  }
                } else {
                  if (((st.kind) ==39)) {
                    if ((codegen_emit_break_stmt(out, indent) !=0)) {
                      return -(1);
                    }
                  } else {
                    if (((st.kind) ==40)) {
                      if ((codegen_emit_continue_stmt(out, indent) !=0)) {
                        return -(1);
                      }
                    } else {
                      uint8_t v[9] = {40, 118, 111, 105, 100, 41, 40, 0, 0};
                      uint8_t sc[4] = {41, 59, 10, 0};
                      if ((codegen_emit_indent(out, indent) !=0)) {
                        return -(1);
                      }
                      if ((codegen_emit_bytes_9(out, v, 7) !=0)) {
                        return -(1);
                      }
                      if ((codegen_emit_expr(arena, out, ex_ref, ctx) !=0)) {
                        return -(1);
                      }
                      if ((codegen_emit_bytes_4(out, sc, 3) !=0)) {
                        return -(1);
                      }
                    }
                  }
                }
              }
            } else {
              if ((k ==3)) {
                if (((idx >=0) && (idx < ast_ast_block_num_loops(arena, block_ref)))) {
                  int32_t w_cr = ast_ast_block_while_cond_ref(arena, block_ref, idx);
                  int32_t w_br = ast_ast_block_while_body_ref(arena, block_ref, idx);
                  if ((codegen_emit_indent(out, indent) !=0)) {
                    return -(1);
                  }
                  uint8_t wh[8] = {119, 104, 105, 108, 101, 32, 40, 0};
                  if ((codegen_emit_bytes_8(out, wh, 7) !=0)) {
                    return -(1);
                  }
                  if ((codegen_emit_expr(arena, out, w_cr, ctx) !=0)) {
                    return -(1);
                  }
                  uint8_t paren[5] = {41, 32, 123, 10, 0};
                  if ((codegen_emit_bytes_5(out, paren, 4) !=0)) {
                    return -(1);
                  }
                  if ((codegen_emit_block(arena, out, w_br, (indent + 2), ctx) !=0)) {
                    return -(1);
                  }
                  if ((codegen_emit_indent(out, indent) !=0)) {
                    return -(1);
                  }
                  uint8_t close[3] = {125, 10, 0};
                  if ((codegen_emit_bytes_3(out, close, 2) !=0)) {
                    return -(1);
                  }
                }
              } else {
                if ((k ==4)) {
                  if (((idx >=0) && (idx < ast_ast_block_num_for_loops(arena, block_ref)))) {
                    int32_t fl_ir = ast_ast_block_for_init_ref(arena, block_ref, idx);
                    int32_t fl_cr = ast_ast_block_for_cond_ref(arena, block_ref, idx);
                    int32_t fl_sr = ast_ast_block_for_step_ref(arena, block_ref, idx);
                    int32_t fl_br = ast_ast_block_for_body_ref(arena, block_ref, idx);
                    if ((codegen_emit_indent(out, indent) !=0)) {
                      return -(1);
                    }
                    uint8_t fk[6] = {102, 111, 114, 32, 40, 0};
                    if ((codegen_emit_bytes_6(out, fk, 5) !=0)) {
                      return -(1);
                    }
                    if (!(ast_ref_is_null(fl_ir))) {
                      if ((codegen_emit_expr(arena, out, fl_ir, ctx) !=0)) {
                        return -(1);
                      }
                    }
                    uint8_t sc1[3] = {59, 32, 0};
                    if ((codegen_emit_bytes_3(out, sc1, 2) !=0)) {
                      return -(1);
                    }
                    if (!(ast_ref_is_null(fl_cr))) {
                      if ((codegen_emit_expr(arena, out, fl_cr, ctx) !=0)) {
                        return -(1);
                      }
                    }
                    uint8_t sc2[3] = {59, 32, 0};
                    if ((codegen_emit_bytes_3(out, sc2, 2) !=0)) {
                      return -(1);
                    }
                    if (!(ast_ref_is_null(fl_sr))) {
                      if ((codegen_emit_expr(arena, out, fl_sr, ctx) !=0)) {
                        return -(1);
                      }
                    }
                    uint8_t paren[5] = {41, 32, 123, 10, 0};
                    if ((codegen_emit_bytes_5(out, paren, 4) !=0)) {
                      return -(1);
                    }
                    if ((!(ast_ref_is_null(fl_br)) && (codegen_emit_block(arena, out, fl_br, (indent + 2), ctx) !=0))) {
                      return -(1);
                    }
                    if ((codegen_emit_indent(out, indent) !=0)) {
                      return -(1);
                    }
                    uint8_t close[3] = {125, 10, 0};
                    if ((codegen_emit_bytes_3(out, close, 2) !=0)) {
                      return -(1);
                    }
                  }
                } else {
                  if ((k ==5)) {
                    if (((idx >=0) && (idx < ast_ast_block_num_if_stmts(arena, block_ref)))) {
                      int32_t if_cond_r = ast_ast_block_if_cond_ref(arena, block_ref, idx);
                      int32_t if_then_r = ast_ast_block_if_then_body_ref(arena, block_ref, idx);
                      int32_t if_else_r = ast_ast_block_if_else_body_ref(arena, block_ref, idx);
                      if ((codegen_emit_indent(out, indent) !=0)) {
                        return -(1);
                      }
                      uint8_t ikw[5] = {105, 102, 32, 40, 0};
                      if ((codegen_emit_bytes_5(out, ikw, 4) !=0)) {
                        return -(1);
                      }
                      if ((codegen_emit_expr(arena, out, if_cond_r, ctx) !=0)) {
                        return -(1);
                      }
                      uint8_t paren_if[5] = {41, 32, 123, 10, 0};
                      if ((codegen_emit_bytes_5(out, paren_if, 4) !=0)) {
                        return -(1);
                      }
                      if ((codegen_emit_block(arena, out, if_then_r, (indent + 2), ctx) !=0)) {
                        return -(1);
                      }
                      if ((codegen_emit_indent(out, indent) !=0)) {
                        return -(1);
                      }
                      if ((if_else_r !=0)) {
                        uint8_t else_brace[9] = {125, 32, 101, 108, 115, 101, 32, 123, 10};
                        if ((codegen_emit_bytes_9(out, else_brace, 9) !=0)) {
                          return -(1);
                        }
                        if ((codegen_emit_block(arena, out, if_else_r, (indent + 2), ctx) !=0)) {
                          return -(1);
                        }
                        if ((codegen_emit_indent(out, indent) !=0)) {
                          return -(1);
                        }
                      }
                      uint8_t cif[3] = {125, 10, 0};
                      if ((codegen_emit_bytes_3(out, cif, 2) !=0)) {
                        return -(1);
                      }
                    }
                  } else {
                    if ((k ==6)) {
                      if (((idx >=0) && (idx < ast_ast_block_num_regions(arena, block_ref)))) {
                        int32_t reg_body = ast_ast_block_region_body_ref(arena, block_ref, idx);
                        int32_t need_scope = 0;
                        if (((!(ast_ref_is_null(reg_body)) && (reg_body > 0)) && (reg_body <=(arena->num_blocks)))) {
                          if (((ast_ast_block_num_lets(arena, reg_body) > 0) || (ast_ast_block_num_consts(arena, reg_body) > 0))) {
                            (void)((need_scope = 1));
                          }
                        }
                        if ((need_scope !=0)) {
                          uint8_t ob[2] = {123, 10};
                          uint8_t cb[3] = {125, 10, 0};
                          if ((codegen_emit_indent(out, indent) !=0)) {
                            return -(1);
                          }
                          if ((codegen_emit_bytes_2(out, ob, 2) !=0)) {
                            return -(1);
                          }
                          if ((codegen_emit_block(arena, out, reg_body, (indent + 2), ctx) !=0)) {
                            return -(1);
                          }
                          if ((codegen_emit_indent(out, indent) !=0)) {
                            return -(1);
                          }
                          if ((codegen_emit_bytes_3(out, cb, 2) !=0)) {
                            return -(1);
                          }
                        } else {
                          if ((codegen_emit_block(arena, out, reg_body, indent, ctx) !=0)) {
                            return -(1);
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        (void)((si = (si + 1)));
      }
      if ((codegen_emit_run_defers(arena, out, block_ref, indent, ctx) !=0)) {
        return -(1);
      }
      int32_t final_ref = ast_ast_block_final_expr_ref(arena, block_ref);
      if ((codegen_emit_block_final_expr(arena, out, block_ref, final_ref, indent, ctx, fn_ret_void) !=0)) {
        return -(1);
      }
      return 0;
    }
    int32_t i = 0;
    while ((i < ast_ast_block_num_consts(arena, block_ref))) {
      uint8_t cname_fb[64] = {};
      (void)(pipeline_block_const_name_copy64(arena, block_ref, i, &((cname_fb)[0])));
      int32_t cname_len_fb = pipeline_block_const_name_len(arena, block_ref, i);
      int32_t ctype_fb = pipeline_block_const_type_ref(arena, block_ref, i);
      int32_t cinit_fb = pipeline_block_const_init_ref(arena, block_ref, i);
      if ((codegen_emit_indent(out, indent) !=0)) {
        return -(1);
      }
      if ((codegen_emit_type(arena, out, ctype_fb, &((blk_prefix)[0]), blk_prefix_len, ctx) !=0)) {
        return -(1);
      }
      uint8_t sp[3] = {32, 0, 0};
      if ((codegen_emit_bytes_3(out, sp, 1) !=0)) {
        return -(1);
      }
      if (((cname_len_fb > 0) && ((cname_fb)[0] > 32))) {
        if ((codegen_emit_bytes_64(out, &((cname_fb)[0]), cname_len_fb) !=0)) {
          return -(1);
        }
      } else {
        uint8_t place[4] = {95, 99, 48, 0};
        if ((codegen_emit_bytes_4(out, place, 2) !=0)) {
          return -(1);
        }
        if ((codegen_format_int(out, i) !=0)) {
          return -(1);
        }
      }
      uint8_t eq[4] = {32, 61, 32, 0};
      if ((codegen_emit_bytes_4(out, eq, 3) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, cinit_fb, ctx) !=0)) {
        return -(1);
      }
      uint8_t sc[3] = {59, 10, 0};
      if ((codegen_emit_bytes_3(out, sc, 2) !=0)) {
        return -(1);
      }
      (void)((i = (i + 1)));
    }
    (void)((i = 0));
    while ((i < ast_ast_block_num_lets(arena, block_ref))) {
      uint8_t lname_fb[64] = {};
      (void)(pipeline_block_let_name_copy64(arena, block_ref, i, &((lname_fb)[0])));
      int32_t lname_len_fb = pipeline_block_let_name_len(arena, block_ref, i);
      int32_t let_type_ref = pipeline_block_let_type_ref(arena, block_ref, i);
      int32_t linit_fb = pipeline_block_let_init_ref(arena, block_ref, i);
      if ((codegen_emit_indent(out, indent) !=0)) {
        return -(1);
      }
      int32_t type_emitted = 0;
      int32_t use_local_array = 0;
      if ((!(ast_ref_is_null(let_type_ref)) && (pipeline_type_kind_ord_at(arena, let_type_ref) ==10))) {
        (void)((use_local_array = 1));
      }
      if ((use_local_array !=0)) {
        if ((codegen_emit_local_fixed_array_elem_type(arena, out, let_type_ref, ctx) !=0)) {
          return -(1);
        }
        (void)((type_emitted = 1));
      }
      if (((!(ast_ref_is_null(linit_fb)) && (linit_fb > 0)) && (linit_fb <=(arena->num_exprs)))) {
        struct ast_Expr init_e = ast_ast_arena_expr_get(arena, linit_fb);
        if ((((type_emitted ==0) && ((init_e.kind) ==46)) && (codegen_type_array_elem_is_u8(arena, let_type_ref) !=0))) {
          uint8_t u8ptr[9] = {117, 105, 110, 116, 56, 95, 116, 32, 0};
          if ((codegen_emit_bytes_9(out, u8ptr, 7) !=0)) {
            return -(1);
          }
          if ((codegen_append_byte(out, 42) !=0)) {
            return -(1);
          }
          (void)((type_emitted = 1));
        }
        if (((((type_emitted ==0) && !(ast_ref_is_null((init_e.resolved_type_ref)))) && ((init_e.resolved_type_ref) > 0)) && ((init_e.resolved_type_ref) <=(arena->num_types)))) {
          struct ast_Type rt2 = ast_ast_arena_type_get(arena, (init_e.resolved_type_ref));
          if ((((rt2.kind) ==8) && ((rt2.name_len) >=6))) {
            int32_t n02 = ((rt2.name_len) - 6);
            if (((((((((rt2.name))[n02] ==83) && (((rt2.name))[(n02 + 1)] ==116)) && (((rt2.name))[(n02 + 2)] ==114)) && (((rt2.name))[(n02 + 3)] ==105)) && (((rt2.name))[(n02 + 4)] ==110)) && (((rt2.name))[(n02 + 5)] ==103))) {
              uint8_t str_ty2a[7] = {83, 116, 114, 105, 110, 103, 0};
              if ((codegen_emit_bytes_from_ptr(out, &((str_ty2a)[0]), 6) !=0)) {
                return -(1);
              }
              if ((codegen_append_byte(out, 32) !=0)) {
                return -(1);
              }
              (void)((type_emitted = 1));
            }
          }
        }
        if ((((((type_emitted ==0) && ((init_e.kind) ==48)) && !(ast_ref_is_null((init_e.call_callee_ref)))) && ((init_e.call_callee_ref) > 0)) && ((init_e.call_callee_ref) <=(arena->num_exprs)))) {
          struct ast_Expr callee_let2 = ast_ast_arena_expr_get(arena, (init_e.call_callee_ref));
          if (((callee_let2.kind) ==3)) {
            if ((codegen_callee_var_is_string_new(callee_let2) !=0)) {
              uint8_t str_ty2[7] = {83, 116, 114, 105, 110, 103, 0};
              if ((codegen_emit_bytes_from_ptr(out, &((str_ty2)[0]), 6) !=0)) {
                return -(1);
              }
              if ((codegen_append_byte(out, 32) !=0)) {
                return -(1);
              }
              (void)((type_emitted = 1));
            }
          }
        }
      }
      if ((type_emitted ==0)) {
        if ((((ast_ref_is_null(let_type_ref) && !(ast_ref_is_null(linit_fb))) && (linit_fb > 0)) && (linit_fb <=(arena->num_exprs)))) {
          struct ast_Expr init_e = ast_ast_arena_expr_get(arena, linit_fb);
          if (!(ast_ref_is_null((init_e.resolved_type_ref)))) {
            (void)((let_type_ref = (init_e.resolved_type_ref)));
          }
        }
        if ((codegen_emit_type(arena, out, let_type_ref, &((blk_prefix)[0]), blk_prefix_len, ctx) !=0)) {
          return -(1);
        }
      }
      if ((codegen_append_byte(out, 32) !=0)) {
        return -(1);
      }
      if (((lname_len_fb > 0) && ((lname_fb)[0] > 32))) {
        if ((codegen_emit_bytes_64(out, &((lname_fb)[0]), lname_len_fb) !=0)) {
          return -(1);
        }
      } else {
        uint8_t place[4] = {95, 108, 48, 0};
        if ((codegen_emit_bytes_4(out, place, 2) !=0)) {
          return -(1);
        }
        if ((codegen_format_int(out, i) !=0)) {
          return -(1);
        }
      }
      if ((use_local_array !=0)) {
        if ((codegen_emit_local_fixed_array_suffix(arena, out, let_type_ref) !=0)) {
          return -(1);
        }
      }
      uint8_t eq[4] = {32, 61, 32, 0};
      if ((codegen_emit_bytes_4(out, eq, 3) !=0)) {
        return -(1);
      }
      if (ast_ref_is_null(linit_fb)) {
        uint8_t zinit_omit[6] = {123, 32, 48, 32, 125, 0};
        if ((codegen_emit_bytes_6(out, zinit_omit, 5) !=0)) {
          return -(1);
        }
      } else {
        if (((((use_local_array !=0) && !(ast_ref_is_null(linit_fb))) && (linit_fb > 0)) && (linit_fb <=(arena->num_exprs)))) {
          struct ast_Expr init_e3 = ast_ast_arena_expr_get(arena, linit_fb);
          if (((init_e3.kind) ==46)) {
            if ((codegen_emit_braced_array_lit_init(arena, out, linit_fb, ctx) !=0)) {
              return -(1);
            }
          } else {
            if ((((init_e3.kind) ==0) && ((init_e3.int_val) ==0))) {
              uint8_t zinit2[6] = {123, 32, 48, 32, 125, 0};
              if ((codegen_emit_bytes_6(out, zinit2, 5) !=0)) {
                return -(1);
              }
            } else {
              if ((codegen_emit_expr(arena, out, linit_fb, ctx) !=0)) {
                return -(1);
              }
            }
          }
        } else {
          if ((codegen_emit_expr(arena, out, linit_fb, ctx) !=0)) {
            return -(1);
          }
        }
      }
      uint8_t sc[3] = {59, 10, 0};
      if ((codegen_emit_bytes_3(out, sc, 2) !=0)) {
        return -(1);
      }
      (void)((i = (i + 1)));
    }
    (void)((i = 0));
    while ((i < ast_ast_block_num_expr_stmts(arena, block_ref))) {
      int32_t ex_fb = ast_ast_block_expr_stmt_ref(arena, block_ref, i);
      struct ast_Expr st = ast_ast_arena_expr_get(arena, ex_fb);
      if (((st.kind) ==41)) {
        if ((codegen_emit_return_stmt_with_context(arena, out, indent, (st.unary_operand_ref), ctx, fn_ret_void) !=0)) {
          return -(1);
        }
      } else {
        if (((st.kind) ==39)) {
          uint8_t br[8] = {98, 114, 101, 97, 107, 59, 10, 0};
          if ((codegen_emit_indent(out, indent) !=0)) {
            return -(1);
          }
          if ((codegen_emit_bytes_8(out, br, 7) !=0)) {
            return -(1);
          }
        } else {
          if (((st.kind) ==40)) {
            uint8_t co[11] = {99, 111, 110, 116, 105, 110, 117, 101, 59, 10, 0};
            if ((codegen_emit_indent(out, indent) !=0)) {
              return -(1);
            }
            if ((codegen_emit_bytes_from_ptr(out, &((co)[0]), 10) !=0)) {
              return -(1);
            }
          } else {
            uint8_t v[9] = {40, 118, 111, 105, 100, 41, 40, 0, 0};
            uint8_t sc[4] = {41, 59, 10, 0};
            if ((codegen_emit_indent(out, indent) !=0)) {
              return -(1);
            }
            if ((codegen_emit_bytes_9(out, v, 7) !=0)) {
              return -(1);
            }
            if ((codegen_emit_expr(arena, out, ex_fb, ctx) !=0)) {
              return -(1);
            }
            if ((codegen_emit_bytes_4(out, sc, 3) !=0)) {
              return -(1);
            }
          }
        }
      }
      (void)((i = (i + 1)));
    }
    (void)((i = 0));
    while ((i < ast_ast_block_num_loops(arena, block_ref))) {
      int32_t w_cr = ast_ast_block_while_cond_ref(arena, block_ref, i);
      int32_t w_br = ast_ast_block_while_body_ref(arena, block_ref, i);
      if ((codegen_emit_indent(out, indent) !=0)) {
        return -(1);
      }
      uint8_t wh[8] = {119, 104, 105, 108, 101, 32, 40, 0};
      if ((codegen_emit_bytes_8(out, wh, 7) !=0)) {
        return -(1);
      }
      if ((codegen_emit_expr(arena, out, w_cr, ctx) !=0)) {
        return -(1);
      }
      uint8_t paren[5] = {41, 32, 123, 10, 0};
      if ((codegen_emit_bytes_5(out, paren, 4) !=0)) {
        return -(1);
      }
      if ((codegen_emit_block(arena, out, w_br, (indent + 2), ctx) !=0)) {
        return -(1);
      }
      if ((codegen_emit_indent(out, indent) !=0)) {
        return -(1);
      }
      uint8_t close[3] = {125, 10, 0};
      if ((codegen_emit_bytes_3(out, close, 2) !=0)) {
        return -(1);
      }
      (void)((i = (i + 1)));
    }
    (void)((i = 0));
    while ((i < ast_ast_block_num_for_loops(arena, block_ref))) {
      int32_t fl_ir = ast_ast_block_for_init_ref(arena, block_ref, i);
      int32_t fl_cr = ast_ast_block_for_cond_ref(arena, block_ref, i);
      int32_t fl_sr = ast_ast_block_for_step_ref(arena, block_ref, i);
      int32_t fl_br = ast_ast_block_for_body_ref(arena, block_ref, i);
      if ((codegen_emit_indent(out, indent) !=0)) {
        return -(1);
      }
      uint8_t fk[6] = {102, 111, 114, 32, 40, 0};
      if ((codegen_emit_bytes_6(out, fk, 5) !=0)) {
        return -(1);
      }
      if (!(ast_ref_is_null(fl_ir))) {
        if ((codegen_emit_expr(arena, out, fl_ir, ctx) !=0)) {
          return -(1);
        }
      }
      uint8_t sc1[3] = {59, 32, 0};
      if ((codegen_emit_bytes_3(out, sc1, 2) !=0)) {
        return -(1);
      }
      if (!(ast_ref_is_null(fl_cr))) {
        if ((codegen_emit_expr(arena, out, fl_cr, ctx) !=0)) {
          return -(1);
        }
      }
      uint8_t sc2[3] = {59, 32, 0};
      if ((codegen_emit_bytes_3(out, sc2, 2) !=0)) {
        return -(1);
      }
      if (!(ast_ref_is_null(fl_sr))) {
        if ((codegen_emit_expr(arena, out, fl_sr, ctx) !=0)) {
          return -(1);
        }
      }
      uint8_t paren[5] = {41, 32, 123, 10, 0};
      if ((codegen_emit_bytes_5(out, paren, 4) !=0)) {
        return -(1);
      }
      if ((!(ast_ref_is_null(fl_br)) && (codegen_emit_block(arena, out, fl_br, (indent + 2), ctx) !=0))) {
        return -(1);
      }
      if ((codegen_emit_indent(out, indent) !=0)) {
        return -(1);
      }
      uint8_t close[3] = {125, 10, 0};
      if ((codegen_emit_bytes_3(out, close, 2) !=0)) {
        return -(1);
      }
      (void)((i = (i + 1)));
    }
    if ((codegen_emit_run_defers(arena, out, block_ref, indent, ctx) !=0)) {
      return -(1);
    }
    int32_t final_ref_plain = ast_ast_block_final_expr_ref(arena, block_ref);
    if ((codegen_emit_block_final_expr(arena, out, block_ref, final_ref_plain, indent, ctx, fn_ret_void) !=0)) {
      return -(1);
    }
    return 0;
  }
  return 0;
}
int32_t codegen_emit_suffix_bytes(uint8_t * dst, uint8_t * src, int32_t len) {
  int32_t i = 0;
  while ((i < len)) {
    (void)(((dst)[i] = (src)[i]));
    (void)((i = (i + 1)));
  }
  return len;
}
int32_t codegen_type_ref_to_suffix(struct ast_ASTArena * arena, int32_t type_ref, uint8_t * buf, int32_t buf_cap) {
  {
    int32_t tk = pipeline_type_kind_ord_at(arena, type_ref);
    if ((((type_ref <=0) || (buf ==((uint8_t *)(0)))) || (buf_cap <=0))) {
      return 0;
    }
    if ((tk ==((int32_t)(9)))) {
      int32_t elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
      int32_t n = codegen_type_ref_to_suffix(arena, elem_ref, buf, buf_cap);
      if (((n > 0) && ((n + 4) < buf_cap))) {
        (void)(((buf)[n] = 95));
        (void)(((buf)[(n + 1)] = 112));
        (void)(((buf)[(n + 2)] = 116));
        (void)(((buf)[(n + 3)] = 114));
        return (n + 4);
      }
      return n;
    }
    if ((tk ==((int32_t)(8)))) {
      int32_t nl = pipeline_type_named_name_into(arena, type_ref, buf);
      int32_t si = 0;
      while (((si < nl) && (si < buf_cap))) {
        if (((buf)[si] ==46)) {
          (void)(((buf)[si] = 95));
        }
        (void)((si = (si + 1)));
      }
      if (((nl > 0) && (nl < buf_cap))) {
        return nl;
      }
      return 0;
    }
    if ((tk ==((int32_t)(0)))) {
      uint8_t s[4] = {105, 51, 50, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 3);
    }
    if ((tk ==((int32_t)(5)))) {
      uint8_t s[4] = {105, 54, 52, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 3);
    }
    if ((tk ==((int32_t)(2)))) {
      uint8_t s[3] = {117, 56, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 2);
    }
    if ((tk ==((int32_t)(3)))) {
      uint8_t s[4] = {117, 51, 50, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 3);
    }
    if ((tk ==((int32_t)(4)))) {
      uint8_t s[4] = {117, 54, 52, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 3);
    }
    if ((tk ==((int32_t)(14)))) {
      uint8_t s[4] = {102, 51, 50, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 3);
    }
    if ((tk ==((int32_t)(15)))) {
      uint8_t s[4] = {102, 54, 52, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 3);
    }
    /* TYPE_VECTOR: mangle suffix <elem>x<lanes> (i32x4/f32x4/i32x8) so same-name vector
     * overloads get distinct C link symbols. Mirrors codegen.x codegen_type_ref_to_suffix.
     * PLATFORM: SHARED. */
    if ((tk ==((int32_t)(13)))) {
      int32_t elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
      int32_t lanes = pipeline_type_array_size_at(arena, type_ref);
      int32_t ek = 0;
      int32_t pos = 0;
      if ((elem_ref <= 0) || (lanes <= 0)) {
        return 0;
      }
      ek = pipeline_type_kind_ord_at(arena, elem_ref);
      if ((ek ==((int32_t)(0)))) {
        uint8_t pre[4] = {105, 51, 50, 0};
        pos = codegen_emit_suffix_bytes(buf, &((pre)[0]), 3);
      } else if ((ek ==((int32_t)(3)))) {
        uint8_t pre[4] = {117, 51, 50, 0};
        pos = codegen_emit_suffix_bytes(buf, &((pre)[0]), 3);
      } else if ((ek ==((int32_t)(14)))) {
        uint8_t pre[4] = {102, 51, 50, 0};
        pos = codegen_emit_suffix_bytes(buf, &((pre)[0]), 3);
      } else {
        return 0;
      }
      if ((pos <= 0)) {
        return 0;
      }
      if ((pos < buf_cap)) {
        (buf)[pos] = 120;
        pos = (pos + 1);
      } else {
        return pos;
      }
      if ((lanes ==4) && (pos < buf_cap)) {
        (buf)[pos] = 52;
        return (pos + 1);
      } else if ((lanes ==8) && (pos < buf_cap)) {
        (buf)[pos] = 56;
        return (pos + 1);
      } else if ((lanes ==16) && ((pos + 1) < buf_cap)) {
        (buf)[pos] = 49;
        (buf)[(pos + 1)] = 54;
        return (pos + 2);
      }
      return pos;
    }
    if ((tk ==((int32_t)(1)))) {
      uint8_t s[5] = {98, 111, 111, 108, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 4);
    }
    if ((tk ==((int32_t)(6)))) {
      uint8_t s[6] = {117, 115, 105, 122, 101, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 5);
    }
    if ((tk ==((int32_t)(7)))) {
      uint8_t s[6] = {105, 115, 105, 122, 101, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 5);
    }
    return 0;
  }
  return 0;
}
int32_t codegen_module_func_overload_count(struct ast_Module * module, uint8_t * name_ptr, int32_t name_len) {
  {
    int32_t c = 0;
    if ((((module ==((struct ast_Module *)(0))) || (name_ptr ==((uint8_t *)(0)))) || (name_len <=0))) {
      return 0;
    }
    int32_t i = 0;
    while ((i < (module->num_funcs))) {
      int32_t fn_len = pipeline_module_func_name_len_at(module, i);
      if (((fn_len ==name_len) && (fn_len > 0))) {
        uint8_t fn_name[64] = {};
        int32_t matched = 1;
        int32_t bi = 0;
        (void)(pipeline_module_func_name_copy64(module, i, &((fn_name)[0])));
        while ((bi < fn_len)) {
          if (((fn_name)[bi] !=(name_ptr)[bi])) {
            (void)((matched = 0));
            (void)((bi = fn_len));
          } else {
            (void)((bi = (bi + 1)));
          }
        }
        if ((matched !=0)) {
          (void)((c = (c + 1)));
        }
      }
      (void)((i = (i + 1)));
    }
    return c;
  }
  return 0;
}
int32_t codegen_func_param_sig_equal(struct ast_ASTArena * arena, struct ast_Module * mod_a, int32_t fi_a, struct ast_Module * mod_b, int32_t fi_b) {
  {
    int32_t np_a = pipeline_module_func_num_params_at(mod_a, fi_a);
    int32_t np_b = pipeline_module_func_num_params_at(mod_b, fi_b);
    if ((np_a !=np_b)) {
      return 0;
    }
    int32_t pi = 0;
    while ((pi < np_a)) {
      uint8_t sa[64] = {};
      uint8_t sb[64] = {};
      int32_t na = codegen_type_ref_to_suffix(arena, pipeline_module_func_param_type_ref_at(mod_a, fi_a, pi), &((sa)[0]), 64);
      int32_t nb = codegen_type_ref_to_suffix(arena, pipeline_module_func_param_type_ref_at(mod_b, fi_b, pi), &((sb)[0]), 64);
      if ((na !=nb)) {
        return 0;
      }
      int32_t k = 0;
      while ((k < na)) {
        if (((sa)[k] !=(sb)[k])) {
          return 0;
        }
        (void)((k = (k + 1)));
      }
      (void)((pi = (pi + 1)));
    }
    return 1;
  }
  return 0;
}
int32_t codegen_module_overload_param_sig_count(struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi) {
  {
    int32_t c = 0;
    if ((((module ==((struct ast_Module *)(0))) || (fi < 0)) || (fi >=(module->num_funcs)))) {
      return 0;
    }
    uint8_t fn_local[64] = {};
    (void)(codegen_copy_func_name64_from_module(module, fi, &((fn_local)[0])));
    int32_t fn_len = pipeline_module_func_name_len_at(module, fi);
    if ((fn_len <=0)) {
      return 0;
    }
    int32_t i = 0;
    while ((i < (module->num_funcs))) {
      int32_t g_len = pipeline_module_func_name_len_at(module, i);
      if (((g_len ==fn_len) && (g_len > 0))) {
        uint8_t g_name[64] = {};
        int32_t matched = 1;
        int32_t bi = 0;
        (void)(pipeline_module_func_name_copy64(module, i, &((g_name)[0])));
        while ((bi < g_len)) {
          if (((g_name)[bi] !=(fn_local)[bi])) {
            (void)((matched = 0));
            (void)((bi = g_len));
          } else {
            (void)((bi = (bi + 1)));
          }
        }
        if ((matched !=0)) {
          if ((codegen_func_param_sig_equal(arena, module, fi, module, i) !=0)) {
            (void)((c = (c + 1)));
          }
        }
      }
      (void)((i = (i + 1)));
    }
    return c;
  }
  return 0;
}
int32_t codegen_func_c_symbol_prefix_len(struct ast_Module * module, int32_t fi, int32_t prefix_len) {
  if ((prefix_len <=0)) {
    return 0;
  }
  if ((((module !=((struct ast_Module *)(0))) && (fi >=0)) && (pipeline_module_func_is_no_mangle_at(module, fi) !=0))) {
    return 0;
  }
  return prefix_len;
  return 0;
}
int32_t codegen_emit_func_link_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi) {
  {
    uint8_t fn_local[64] = {};
    int32_t fn_len = 0;
    int32_t overload_count = 0;
    int32_t np = 0;
    int32_t pi = 0;
    int32_t sig_count = 0;
    if ((((module ==((struct ast_Module *)(0))) || (fi < 0)) || (fi >=(module->num_funcs)))) {
      return -(1);
    }
    (void)((fn_len = pipeline_module_func_name_len_at(module, fi)));
    (void)(codegen_copy_func_name64_from_module(module, fi, &((fn_local)[0])));
    if ((fn_len <=0)) {
      return -(1);
    }
    if ((pipeline_module_func_is_no_mangle_at(module, fi) !=0)) {
      return codegen_emit_bytes_64(out, &((fn_local)[0]), fn_len);
    }
    (void)((overload_count = codegen_module_func_overload_count(module, &((fn_local)[0]), fn_len)));
    if ((overload_count <=1)) {
      return codegen_emit_bytes_64(out, &((fn_local)[0]), fn_len);
    }
    if ((codegen_emit_bytes_64(out, &((fn_local)[0]), fn_len) !=0)) {
      return -(1);
    }
    (void)((np = pipeline_module_func_num_params_at(module, fi)));
    (void)((pi = 0));
    while ((pi < np)) {
      uint8_t suf[64] = {};
      int32_t sl = codegen_type_ref_to_suffix(arena, pipeline_module_func_param_type_ref_at(module, fi, pi), &((suf)[0]), 64);
      if ((sl > 0)) {
        if ((codegen_append_byte(out, 95) !=0)) {
          return -(1);
        }
        if ((codegen_emit_bytes_from_ptr(out, &((suf)[0]), sl) !=0)) {
          return -(1);
        }
      }
      (void)((pi = (pi + 1)));
    }
    (void)((sig_count = codegen_module_overload_param_sig_count(arena, module, fi)));
    if ((sig_count > 1)) {
      int32_t ret_ref = pipeline_module_func_return_type_at(module, fi);
      uint8_t rs[64] = {};
      int32_t rsl = codegen_type_ref_to_suffix(arena, ret_ref, &((rs)[0]), 64);
      if ((rsl > 0)) {
        uint8_t ret_kw[5] = {95, 114, 101, 116, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((ret_kw)[0]), 4) !=0)) {
          return -(1);
        }
        if ((codegen_emit_bytes_from_ptr(out, &((rs)[0]), rsl) !=0)) {
          return -(1);
        }
      }
    }
    return 0;
  }
  return 0;
}
struct ast_ASTArena * codegen_arena_for_module(struct ast_PipelineDepCtx * ctx, struct ast_Module * module, struct ast_ASTArena * fallback) {
  {
    int32_t di = 0;
    int32_t nd = pipeline_dep_ctx_ndep(ctx);
    if (((ctx ==((struct ast_PipelineDepCtx *)(0))) || (module ==((struct ast_Module *)(0))))) {
      return fallback;
    }
    while ((di < nd)) {
      if ((pipeline_dep_ctx_module_at(ctx, di) ==module)) {
        struct ast_ASTArena * da = pipeline_dep_ctx_arena_at(ctx, di);
        if ((da !=((struct ast_ASTArena *)(0)))) {
          return da;
        }
        return fallback;
      }
      (void)((di = (di + 1)));
    }
    return fallback;
  }
  return 0;
}
int32_t codegen_emit_call_func_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, int32_t expr_ref, struct ast_Module * current_module, uint8_t * fallback_name, int32_t fallback_len) {
  if (((ctx !=((struct ast_PipelineDepCtx *)(0))) && (arena !=((struct ast_ASTArena *)(0))))) {
    int32_t func_ix = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
    int32_t dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
    struct ast_Expr call_e0 = ast_ast_arena_expr_get(arena, expr_ref);
    int32_t is_m0 = 0;
    if (((call_e0.kind) ==49)) {
      (void)((is_m0 = 1));
    }
    int32_t nargs0 = 0;
    if ((is_m0 !=0)) {
      (void)((nargs0 = (call_e0.method_call_num_args)));
    } else {
      (void)((nargs0 = (call_e0.call_num_args)));
    }
    if ((func_ix >=0)) {
      struct ast_Module * res_mod = ((struct ast_Module *)(0));
      if (((dep_ix >=0) && (dep_ix < pipeline_dep_ctx_ndep(ctx)))) {
        (void)((res_mod = pipeline_dep_ctx_module_at(ctx, dep_ix)));
      } else {
        (void)((res_mod = current_module));
      }
      if (((res_mod !=((struct ast_Module *)(0))) && (func_ix < (res_mod->num_funcs)))) {
        int32_t ok_res = 1;
        if ((pipeline_module_func_num_params_at(res_mod, func_ix) !=nargs0)) {
          (void)((ok_res = 0));
        }
        if (((ok_res !=0) && (fallback_len > 0))) {
          int32_t rlen = pipeline_module_func_name_len_at(res_mod, func_ix);
          if ((rlen !=fallback_len)) {
            (void)((ok_res = 0));
          } else {
            uint8_t rnm[64] = {};
            (void)(pipeline_module_func_name_copy64(res_mod, func_ix, &((rnm)[0])));
            int32_t ri = 0;
            while ((ri < rlen)) {
              if (((rnm)[ri] !=(fallback_name)[ri])) {
                (void)((ok_res = 0));
                (void)((ri = rlen));
              } else {
                (void)((ri = (ri + 1)));
              }
            }
          }
        }
        /* PLATFORM: SHARED — trust typeck resolved overload (args + expected return).
         * Do not clear ok_res when overload_count>1 (that emitted bare std_vec_new vs _ret_). */
        /* PLATFORM: SHARED — reject call_resolved on a different module than binding current_module. */
        if ((((ok_res !=0) && (current_module !=((struct ast_Module *)(0)))) && (res_mod !=current_module))) {
          (void)((ok_res = 0));
        }
        if ((ok_res !=0)) {
          struct ast_ASTArena * res_arena = codegen_arena_for_module(ctx, res_mod, arena);
          return codegen_emit_func_link_name(out, res_arena, res_mod, func_ix);
        }
      }
      (void)((func_ix = -(1)));
    }
    struct ast_Module * search_mod = ((struct ast_Module *)(0));
    struct ast_ASTArena * search_arena = arena;
    /* Prefer binding current_module over call_resolved dep_ix (closure multi-import). */
    if ((current_module !=((struct ast_Module *)(0)))) {
      (void)((search_mod = current_module));
      (void)((search_arena = codegen_arena_for_module(ctx, search_mod, arena)));
    } else if (((dep_ix >=0) && (dep_ix < pipeline_dep_ctx_ndep(ctx)))) {
      (void)((search_mod = pipeline_dep_ctx_module_at(ctx, dep_ix)));
      (void)((search_arena = pipeline_dep_ctx_arena_at(ctx, dep_ix)));
      if ((search_arena ==((struct ast_ASTArena *)(0)))) {
        (void)((search_arena = arena));
      }
    } else {
      (void)((search_mod = current_module));
      (void)((search_arena = codegen_arena_for_module(ctx, search_mod, arena)));
    }
    if (((search_mod !=((struct ast_Module *)(0))) && (fallback_len > 0))) {
      struct ast_Expr call_e = call_e0;
      int32_t is_method = is_m0;
      int32_t call_nargs = nargs0;
      int32_t found_fi = -(1);
      int32_t found_count = 0;
      int32_t fi_s = 0;
      while ((fi_s < (search_mod->num_funcs))) {
        int32_t fn_len = pipeline_module_func_name_len_at(search_mod, fi_s);
        if (((fn_len ==fallback_len) && (fn_len > 0))) {
          uint8_t fn_name[64] = {};
          (void)(pipeline_module_func_name_copy64(search_mod, fi_s, &((fn_name)[0])));
          int32_t matched = 1;
          int32_t bi = 0;
          while ((bi < fn_len)) {
            if (((fn_name)[bi] !=(fallback_name)[bi])) {
              (void)((matched = 0));
              (void)((bi = fn_len));
            } else {
              (void)((bi = (bi + 1)));
            }
          }
          if ((matched !=0)) {
            int32_t np = pipeline_module_func_num_params_at(search_mod, fi_s);
            if ((np ==call_nargs)) {
              int32_t types_match = 1;
              int32_t pi = 0;
              while (((pi < np) && (types_match !=0))) {
                int32_t arg_ref = 0;
                if ((is_method !=0)) {
                  (void)((arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, pi)));
                } else {
                  (void)((arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, pi)));
                }
                if (ast_ref_is_null(arg_ref)) {
                  (void)((types_match = 0));
                } else {
                  extern int32_t pipeline_expr_var_name_len(struct ast_ASTArena * a, int32_t expr_ref);
                  extern void pipeline_expr_var_name_into(struct ast_ASTArena * a, int32_t expr_ref, uint8_t * out);
                  extern int32_t pipeline_module_func_param_type_ref_for_name(struct ast_Module * m, int32_t func_index, uint8_t * vname, int32_t vname_len);
                  int32_t arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
                  /* PLATFORM: SHARED — dep module bodies not typeck'd: param VAR args have
                   * resolved_type=0. When arg is a VAR naming a param of the CURRENTLY emitted
                   * function, use that param's declared type. Mirrors codegen.x. */
                  if (((arg_ty <=0) && (ctx !=0)) && ((ctx->current_codegen_module !=0) && (ctx->current_func_index >=0))) {
                    if (pipeline_expr_kind_ord_at(arena, arg_ref) ==3) {
                      int32_t av_len = pipeline_expr_var_name_len(arena, arg_ref);
                      if (((av_len > 0) && (av_len <= 63))) {
                        uint8_t av_buf[64] = {};
                        pipeline_expr_var_name_into(arena, arg_ref, &((av_buf)[0]));
                        int32_t apt = pipeline_module_func_param_type_ref_for_name(ctx->current_codegen_module, ctx->current_func_index, &((av_buf)[0]), av_len);
                        if ((apt > 0)) {
                          (void)((arg_ty = apt));
                        }
                      }
                    }
                  }
                  if (((arg_ty <=0) && (pipeline_expr_kind_ord_at(arena, arg_ref) ==54))) {
                    int32_t as_tgt = pipeline_expr_as_target_type_ref_at(arena, arg_ref);
                    if ((as_tgt > 0)) {
                      (void)((arg_ty = as_tgt));
                    }
                  }
                  int32_t is_str_lit = 0;
                  if (((arg_ty <=0) && (pipeline_expr_kind_ord_at(arena, arg_ref) ==59))) {
                    (void)((is_str_lit = 1));
                  }
                  int32_t param_ty = pipeline_module_func_param_type_ref_at(search_mod, fi_s, pi);
                  uint8_t sa[64] = {};
                  uint8_t sb[64] = {};
                  int32_t na = 0;
                  int32_t nb = 0;
                  if (((((is_str_lit ==0) && (arg_ty > 0)) && (pipeline_type_kind_ord_at(arena, arg_ty) ==10)) && (pipeline_type_kind_ord_at(search_arena, param_ty) ==9))) {
                    int32_t ae = pipeline_type_elem_ref_at(arena, arg_ty);
                    int32_t pe = pipeline_type_elem_ref_at(search_arena, param_ty);
                    (void)((na = codegen_type_ref_to_suffix(arena, ae, &((sa)[0]), 64)));
                    (void)((nb = codegen_type_ref_to_suffix(search_arena, pe, &((sb)[0]), 64)));
                  } else {
                    if ((is_str_lit !=0)) {
                      (void)(((sa)[0] = 117));
                      (void)(((sa)[1] = 56));
                      (void)(((sa)[2] = 95));
                      (void)(((sa)[3] = 112));
                      (void)(((sa)[4] = 116));
                      (void)(((sa)[5] = 114));
                      (void)((na = 6));
                      (void)((nb = codegen_type_ref_to_suffix(search_arena, param_ty, &((sb)[0]), 64)));
                    } else {
                      (void)((na = codegen_type_ref_to_suffix(arena, arg_ty, &((sa)[0]), 64)));
                      (void)((nb = codegen_type_ref_to_suffix(search_arena, param_ty, &((sb)[0]), 64)));
                    }
                  }
                  { extern char *getenv(const char *); if (getenv("SHUX_CGFCN")) fprintf(stderr, "SHUX_CGFCN: fi_s=%d pi=%d arg_ty=%d param_ty=%d na=%d nb=%d\n", (int)fi_s, (int)pi, (int)arg_ty, (int)param_ty, (int)na, (int)nb); }
                  if ((na !=nb)) {
                    (void)((types_match = 0));
                  } else {
                    if ((na <=0)) {
                      (void)((types_match = 0));
                    } else {
                      int32_t k = 0;
                      while ((k < na)) {
                        if (((sa)[k] !=(sb)[k])) {
                          (void)((types_match = 0));
                          (void)((k = na));
                        } else {
                          (void)((k = (k + 1)));
                        }
                      }
                    }
                  }
                }
                (void)((pi = (pi + 1)));
              }
              if ((types_match !=0)) {
                (void)((found_fi = fi_s));
                (void)((found_count = (found_count + 1)));
              }
            }
          }
        }
        (void)((fi_s = (fi_s + 1)));
      }
      if (((found_count ==1) && (found_fi >=0))) {
        return codegen_emit_func_link_name(out, search_arena, search_mod, found_fi);
      }
      /* PLATFORM: SHARED — PTR overload (heap.free *u8): kind+elem match when suffix fails. */
      if ((((((found_count !=1) && (call_nargs ==1)) && (is_method !=0)) && (search_mod !=((struct ast_Module *)(0)))))) {
        int32_t arg0 = pipeline_expr_method_call_arg_ref(arena, expr_ref, 0);
        int32_t arg0_ty = 0;
        if ((arg0 > 0)) {
          (void)((arg0_ty = pipeline_expr_resolved_type_ref(arena, arg0)));
        }
        if (((arg0_ty > 0) && (pipeline_type_kind_ord_at(arena, arg0_ty) ==9))) {
          int32_t ae_k = 0;
          int32_t ae = pipeline_type_elem_ref_at(arena, arg0_ty);
          if ((ae > 0)) {
            (void)((ae_k = pipeline_type_kind_ord_at(arena, ae)));
          }
          int32_t fi_p = 0;
          int32_t best_p = -(1);
          int32_t n_p = 0;
          while ((fi_p < (search_mod->num_funcs))) {
            int32_t fl = pipeline_module_func_name_len_at(search_mod, fi_p);
            if ((((fl ==fallback_len) && (fl > 0)) && (pipeline_module_func_num_params_at(search_mod, fi_p) ==1))) {
              uint8_t fnm_p[64] = {};
              (void)(pipeline_module_func_name_copy64(search_mod, fi_p, &((fnm_p)[0])));
              int32_t me = 1;
              int32_t bi = 0;
              while ((bi < fl)) {
                if (((fnm_p)[bi] !=(fallback_name)[bi])) {
                  (void)((me = 0));
                  (void)((bi = fl));
                } else {
                  (void)((bi = (bi + 1)));
                }
              }
              if ((me !=0)) {
                int32_t pt = pipeline_module_func_param_type_ref_at(search_mod, fi_p, 0);
                if (((pt > 0) && (pipeline_type_kind_ord_at(search_arena, pt) ==9))) {
                  int32_t pe = pipeline_type_elem_ref_at(search_arena, pt);
                  if (((pe > 0) && (pipeline_type_kind_ord_at(search_arena, pe) ==ae_k))) {
                    (void)((best_p = fi_p));
                    (void)((n_p = (n_p + 1)));
                  }
                }
              }
            }
            (void)((fi_p = (fi_p + 1)));
          }
          if (((n_p ==1) && (best_p >=0))) {
            return codegen_emit_func_link_name(out, search_arena, search_mod, best_p);
          }
        }
      }
      if (((found_count !=1) && (call_nargs >=0))) {
        int32_t arity_fi = -(1);
        int32_t arity_count = 0;
        int32_t ext_fi = -(1);
        int32_t ext_count = 0;
        int32_t fi_a = 0;
        while ((fi_a < (search_mod->num_funcs))) {
          int32_t fn_len_a = pipeline_module_func_name_len_at(search_mod, fi_a);
          if (((fn_len_a ==fallback_len) && (fn_len_a > 0))) {
            uint8_t fn_name_a[64] = {};
            (void)(pipeline_module_func_name_copy64(search_mod, fi_a, &((fn_name_a)[0])));
            int32_t matched_a = 1;
            int32_t bi_a = 0;
            while ((bi_a < fn_len_a)) {
              if (((fn_name_a)[bi_a] !=(fallback_name)[bi_a])) {
                (void)((matched_a = 0));
                (void)((bi_a = fn_len_a));
              } else {
                (void)((bi_a = (bi_a + 1)));
              }
            }
            if ((matched_a !=0)) {
              int32_t np_a = pipeline_module_func_num_params_at(search_mod, fi_a);
              if ((np_a ==call_nargs)) {
                (void)((arity_fi = fi_a));
                (void)((arity_count = (arity_count + 1)));
                if (((pipeline_module_func_is_extern_at(search_mod, fi_a) !=0) || (pipeline_module_func_is_no_mangle_at(search_mod, fi_a) !=0))) {
                  (void)((ext_fi = fi_a));
                  (void)((ext_count = (ext_count + 1)));
                }
              }
            }
          }
          (void)((fi_a = (fi_a + 1)));
        }
        if (((ext_count ==1) && (ext_fi >=0))) {
          return codegen_emit_func_link_name(out, search_arena, search_mod, ext_fi);
        }
        if (((arity_count ==1) && (arity_fi >=0))) {
          return codegen_emit_func_link_name(out, search_arena, search_mod, arity_fi);
        }
      }
    }
  }
  if ((((ctx !=((struct ast_PipelineDepCtx *)(0))) && (fallback_len > 0)) && (arena !=((struct ast_ASTArena *)(0))))) {
    struct ast_Expr mc_e = ast_ast_arena_expr_get(arena, expr_ref);
    int32_t mc_nargs = 0;
    if (((mc_e.kind) ==49)) {
      (void)((mc_nargs = (mc_e.method_call_num_args)));
    } else {
      (void)((mc_nargs = (mc_e.call_num_args)));
    }
    int32_t dep_di = 0;
    int32_t nd = pipeline_dep_ctx_ndep(ctx);
    while ((dep_di < nd)) {
      struct ast_Module * dm = pipeline_dep_ctx_module_at(ctx, dep_di);
      struct ast_ASTArena * da = pipeline_dep_ctx_arena_at(ctx, dep_di);
      if (((dm !=((struct ast_Module *)(0))) && (da !=((struct ast_ASTArena *)(0))))) {
        int32_t fi_x = 0;
        int32_t found_x = -(1);
        while ((fi_x < (dm->num_funcs))) {
          int32_t fn_x = pipeline_module_func_name_len_at(dm, fi_x);
          if (((fn_x ==fallback_len) && (fn_x > 0))) {
            uint8_t fnm[64] = {};
            (void)(pipeline_module_func_name_copy64(dm, fi_x, &((fnm)[0])));
            int32_t mx = 1;
            int32_t bx = 0;
            while ((bx < fn_x)) {
              if (((fnm)[bx] !=(fallback_name)[bx])) {
                (void)((mx = 0));
                (void)((bx = fn_x));
              } else {
                (void)((bx = (bx + 1)));
              }
            }
            if (((mx !=0) && (pipeline_module_func_num_params_at(dm, fi_x) ==mc_nargs))) {
              (void)((found_x = fi_x));
              (void)((fi_x = (dm->num_funcs)));
            } else {
              (void)((fi_x = (fi_x + 1)));
            }
          } else {
            (void)((fi_x = (fi_x + 1)));
          }
        }
        if ((found_x >=0)) {
          return codegen_emit_func_link_name(out, da, dm, found_x);
        }
      }
      (void)((dep_di = (dep_di + 1)));
    }
  }
  return codegen_emit_bytes_from_ptr(out, fallback_name, fallback_len);
  return 0;
}
void codegen_copy_func_name64_from_module(struct ast_Module * module, int32_t fi, uint8_t * dst) {
  (void)(pipeline_module_func_name_copy64(module, fi, dst));
  (void)(0);
  return;
}
void codegen_copy_param_name32_from_module(struct ast_Module * module, int32_t fi, int32_t pi, uint8_t * dst) {
  (void)(pipeline_module_func_param_name_copy32(module, fi, pi, dst));
  (void)(0);
  return;
}
/* PLATFORM: SHARED — Cap-T001 unsafe region return scan for emit_func fallback.
 * Same semantics as codegen.x codegen_block_contains_return (seed pin). */
int32_t codegen_block_contains_return(struct ast_ASTArena * arena, int32_t block_ref) {
  int32_t ji;
  int32_t nes;
  int32_t ri;
  int32_t nr;
  if ((arena == ((struct ast_ASTArena *)(0))) || ast_ref_is_null(block_ref)) {
    return 0;
  }
  if (!(ast_ref_is_null(ast_ast_block_final_expr_ref(arena, block_ref)))) {
    return 1;
  }
  ji = 0;
  nes = ast_ast_block_num_expr_stmts(arena, block_ref);
  while ((ji < nes)) {
    struct ast_Expr se = ast_ast_arena_expr_get(arena, ast_ast_block_expr_stmt_ref(arena, block_ref, ji));
    if (((se.kind) == 41)) {
      return 1;
    }
    (void)((ji = (ji + 1)));
  }
  ri = 0;
  nr = ast_ast_block_num_regions(arena, block_ref);
  while ((ri < nr)) {
    int32_t rb = ast_ast_block_region_body_ref(arena, block_ref, ri);
    if ((codegen_block_contains_return(arena, rb) != 0)) {
      return 1;
    }
    (void)((ri = (ri + 1)));
  }
  return 0;
}

int32_t codegen_emit_func(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, int is_entry, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx, int32_t call_init_globals) {
  {
    uint8_t fn_local[64] = {};
    int32_t fn_len = 0;
    int name_is_main = 0;
    int force_entry_main = 0;
    int emit_c_main_symbol = 0;
    uint8_t main_name[4] = {109, 97, 105, 110};
    if (((fi < 0) || (fi >=(module->num_funcs)))) {
      return -(1);
    }
    (void)((fn_len = pipeline_module_func_name_len_at(module, fi)));
    (void)(codegen_copy_func_name64_from_module(module, fi, &((fn_local)[0])));
    if ((pipeline_module_func_is_used_at(module, fi) !=0)) {
      uint8_t used_attr[27] = {95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 115, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((used_attr)[0]), 22) !=0)) {
        return -(1);
      }
    }
    if ((pipeline_module_func_is_naked_at(module, fi) !=0)) {
      uint8_t naked_attr[29] = {95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 97, 107, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((naked_attr)[0]), 23) !=0)) {
        return -(1);
      }
    }
    if ((pipeline_module_func_is_entry_at(module, fi) !=0)) {
      uint8_t entry_attr[30] = {95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 111, 114, 101, 116, 117, 114, 110, 41, 41, 32, 0, 0, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((entry_attr)[0]), 26) !=0)) {
        return -(1);
      }
    }
    if ((pipeline_module_func_is_interrupt_at(module, fi) !=0)) {
      uint8_t int_attr[31] = {95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 105, 110, 116, 101, 114, 114, 117, 112, 116, 41, 41, 32, 0, 0, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((int_attr)[0]), 27) !=0)) {
        return -(1);
      }
    }
    if ((((((fn_len ==4) && ((fn_local)[0] ==109)) && ((fn_local)[1] ==97)) && ((fn_local)[2] ==105)) && ((fn_local)[3] ==110))) {
      (void)((name_is_main = 1));
    }
    if ((is_entry && ((module->num_funcs) ==1))) {
      if ((fn_len <=0)) {
        (void)((force_entry_main = 1));
      }
      if (((fn_local)[0] ==0)) {
        (void)((force_entry_main = 1));
      }
    }
    if (is_entry) {
      if (name_is_main) {
        (void)((emit_c_main_symbol = 1));
      }
    }
    if (force_entry_main) {
      (void)((emit_c_main_symbol = 1));
    }
    /* PLATFORM: SHARED — void main → int32_t main (align codegen.x). */
    {
      int32_t ret_ty_ref = pipeline_module_func_return_type_at(module, fi);
      int fn_ret_void_pre = (pipeline_type_kind_ord_at(arena, ret_ty_ref) == ((int32_t)(16)));
      if ((emit_c_main_symbol && fn_ret_void_pre)) {
        uint8_t i32_ty[8] = {105, 110, 116, 51, 50, 95, 116, 0};
        if ((codegen_emit_bytes_8(out, i32_ty, 7) !=0)) {
          return -(1);
        }
      } else if ((codegen_emit_type(arena, out, ret_ty_ref, prefix, prefix_len, ctx) !=0)) {
        return -(1);
      }
    }
    if ((codegen_append_byte(out, 32) !=0)) {
      return -(1);
    }
    if (emit_c_main_symbol) {
      if ((codegen_emit_bytes_4(out, main_name, 4) !=0)) {
        return -(1);
      }
    } else {
      int32_t sym_pre = codegen_func_c_symbol_prefix_len(module, fi, prefix_len);
      if ((((sym_pre > 0) && (codegen_c_prefix_redundant_with_name(prefix, sym_pre, &((fn_local)[0]), fn_len) ==0)) && (codegen_emit_bytes_from_ptr(out, prefix, sym_pre) !=0))) {
        return -(1);
      }
      if ((codegen_emit_func_link_name(out, arena, module, fi) !=0)) {
        return -(1);
      }
      if ((codegen_std_io_fixed_fd_emit_impl(prefix, prefix_len, &((fn_local)[0]), fn_len) !=0)) {
        uint8_t impl_suffix[6] = {95, 105, 109, 112, 108, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((impl_suffix)[0]), 5) !=0)) {
          return -(1);
        }
      }
    }
    uint8_t lpar[2] = {40, 0};
    if ((codegen_emit_bytes_2(out, lpar, 1) !=0)) {
      return -(1);
    }
    if ((pipeline_module_func_num_params_at(module, fi) ==0)) {
      uint8_t v[7] = {118, 111, 105, 100, 0, 0, 0};
      if ((codegen_emit_bytes_7(out, v, 4) !=0)) {
        return -(1);
      }
    } else {
      int32_t p = 0;
      while ((p < pipeline_module_func_num_params_at(module, fi))) {
        if ((p > 0)) {
          uint8_t comma[3] = {44, 32, 0};
          if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
            return -(1);
          }
        }
        if ((codegen_force_param_size_t_std_io_print_str_second(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
          uint8_t size_t_ps[32] = {115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
          if ((codegen_emit_bytes_32(out, size_t_ps, 7) !=0)) {
            return -(1);
          }
        } else {
          if ((codegen_force_param_size_t(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
            uint8_t size_t_buf[32] = {115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
            if ((codegen_emit_bytes_32(out, size_t_buf, 7) !=0)) {
              return -(1);
            }
          } else {
            if ((codegen_force_param_ptrdiff_t(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
              uint8_t ptrdiff_t_buf[32] = {112, 116, 114, 100, 105, 102, 102, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
              if ((codegen_emit_bytes_32(out, ptrdiff_t_buf, 10) !=0)) {
                return -(1);
              }
            } else {
              if ((codegen_force_param_uint32_t(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
                uint8_t u32_buf[32] = {117, 105, 110, 116, 51, 50, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
                if ((codegen_emit_bytes_32(out, u32_buf, 9) !=0)) {
                  return -(1);
                }
              } else {
                if ((codegen_force_param_i32(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
                  uint8_t i32_str[8] = {105, 110, 116, 51, 50, 95, 116, 0};
                  if ((codegen_emit_bytes_8(out, i32_str, 7) !=0)) {
                    return -(1);
                  }
                } else {
                  if ((codegen_emit_type(arena, out, pipeline_module_func_param_type_ref_at(module, fi, p), prefix, prefix_len, ctx) !=0)) {
                    return -(1);
                  }
                  /* PLATFORM: SHARED — TYPE_SLICE params as pointers (seed/glue ABI). */
                  if ((pipeline_type_kind_ord_at(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) ==11)) {
                    if ((codegen_append_byte(out, 32) !=0)) {
                      return -(1);
                    }
                    if ((codegen_append_byte(out, 42) !=0)) {
                      return -(1);
                    }
                  }
                }
              }
            }
          }
        }
        if ((codegen_append_byte(out, 32) !=0)) {
          return -(1);
        }
        if ((pipeline_module_func_param_name_len_at(module, fi, p) > 0)) {
          uint8_t plocal[32] = {};
          (void)(codegen_copy_param_name32_from_module(module, fi, p, &((plocal)[0])));
          if ((((plocal)[0] > 32) && (codegen_emit_bytes_32(out, plocal, pipeline_module_func_param_name_len_at(module, fi, p)) !=0))) {
            return -(1);
          }
        } else {
          uint8_t place[4] = {95, 112, 48, 0};
          if ((codegen_emit_bytes_4(out, place, 2) !=0)) {
            return -(1);
          }
          if ((codegen_format_int(out, p) !=0)) {
            return -(1);
          }
        }
        (void)((p = (p + 1)));
      }
    }
    uint8_t rpar[3] = {41, 32, 0};
    if ((codegen_emit_bytes_3(out, rpar, 2) !=0)) {
      return -(1);
    }
    uint8_t brace[3] = {123, 10, 0};
    if ((codegen_emit_bytes_3(out, brace, 2) !=0)) {
      return -(1);
    }
    if ((codegen_try_emit_std_io_driver_buf_body(out, module, fi, prefix, prefix_len) !=0)) {
      return 0;
    }
    int fn_ret_void = (pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(module, fi)) ==((int32_t)(16)));
    if ((call_init_globals !=0)) {
      if (is_entry) {
        if (emit_c_main_symbol) {
          uint8_t init_globals_call[22] = {105, 110, 105, 116, 95, 103, 108, 111, 98, 97, 108, 115, 40, 41, 59, 10, 0, 0, 0, 0, 0, 0};
          if ((codegen_emit_indent(out, 2) !=0)) {
            return -(1);
          }
          if ((codegen_emit_bytes_from_ptr(out, &((init_globals_call)[0]), 16) !=0)) {
            return -(1);
          }
        }
      }
    }
    int32_t saved_empty = -(1);
    int32_t saved_count = 0;
    int32_t saved_next = 0;
    if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
      int32_t empty_count = 0;
      int32_t empty_idx = -(1);
      int32_t pi = 0;
      (void)(pipeline_dep_ctx_empty_param_backup(ctx));
      (void)((saved_empty = (ctx->current_func_single_empty_param_index)));
      (void)((saved_count = (ctx->current_func_empty_param_count)));
      (void)((saved_next = (ctx->current_emit_empty_var_next_index)));
      while ((pi < pipeline_module_func_num_params_at(module, fi))) {
        if ((pipeline_module_func_param_name_len_at(module, fi, pi) <=0)) {
          (void)((empty_count = (empty_count + 1)));
          (void)((empty_idx = pi));
        }
        (void)((pi = (pi + 1)));
      }
      if ((empty_count ==1)) {
        (void)(((ctx->current_func_single_empty_param_index) = empty_idx));
        (void)(((ctx->current_func_empty_param_count) = 0));
        (void)(((ctx->current_emit_empty_var_next_index) = 0));
      } else {
        if ((empty_count >=2)) {
          int32_t ei = 0;
          (void)(((ctx->current_func_single_empty_param_index) = -(1)));
          (void)(pipeline_dep_ctx_empty_param_reset(ctx));
          (void)(((ctx->current_func_empty_param_count) = empty_count));
          (void)((pi = 0));
          while ((pi < pipeline_module_func_num_params_at(module, fi))) {
            if ((pipeline_module_func_param_name_len_at(module, fi, pi) <=0)) {
              (void)(pipeline_dep_ctx_empty_param_append(ctx, pi));
              (void)((ei = (ei + 1)));
            }
            (void)((pi = (pi + 1)));
          }
          (void)(((ctx->current_emit_empty_var_next_index) = 0));
        } else {
          (void)(((ctx->current_func_single_empty_param_index) = -(1)));
          (void)(((ctx->current_func_empty_param_count) = 0));
          (void)(((ctx->current_emit_empty_var_next_index) = 0));
        }
      }
    }
    if (!(ast_ref_is_null(pipeline_module_func_body_ref_at(module, fi)))) {
      int32_t saved_block = 0;
      if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
        (void)((saved_block = (ctx->current_block_ref)));
        (void)(((ctx->current_block_ref) = pipeline_module_func_body_ref_at(module, fi)));
      }
      if ((codegen_emit_block(arena, out, pipeline_module_func_body_ref_at(module, fi), 2, ctx) !=0)) {
        if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
          (void)(((ctx->current_block_ref) = saved_block));
        }
        return -(1);
      }
      if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
        (void)(((ctx->current_block_ref) = saved_block));
      }
    } else {
      if (!(ast_ref_is_null(pipeline_module_func_body_expr_ref_at(module, fi)))) {
        if (fn_ret_void) {
          if ((codegen_emit_indent(out, 2) !=0)) {
            return -(1);
          }
          if ((codegen_emit_expr(arena, out, pipeline_module_func_body_expr_ref_at(module, fi), ctx) !=0)) {
            return -(1);
          }
          if ((codegen_append_byte(out, 59) !=0)) {
            return -(1);
          }
          if ((codegen_append_byte(out, 10) !=0)) {
            return -(1);
          }
        } else {
          uint8_t ret_keyword[9] = {114, 101, 116, 117, 114, 110, 32, 0, 0};
          struct ast_Expr body_e = ast_ast_arena_expr_get(arena, pipeline_module_func_body_expr_ref_at(module, fi));
          if ((codegen_emit_indent(out, 2) !=0)) {
            return -(1);
          }
          if ((codegen_emit_bytes_9(out, ret_keyword, 7) !=0)) {
            return -(1);
          }
          if (((body_e.kind) ==41)) {
            if ((!(ast_ref_is_null((body_e.unary_operand_ref))) && (codegen_emit_expr(arena, out, (body_e.unary_operand_ref), ctx) !=0))) {
              return -(1);
            }
          } else {
            if ((codegen_emit_expr(arena, out, pipeline_module_func_body_expr_ref_at(module, fi), ctx) !=0)) {
              return -(1);
            }
          }
          if ((codegen_append_byte(out, 59) !=0)) {
            return -(1);
          }
          if ((codegen_append_byte(out, 10) !=0)) {
            return -(1);
          }
        }
      }
    }
    if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
      (void)(((ctx->current_func_single_empty_param_index) = saved_empty));
      (void)(((ctx->current_func_empty_param_count) = saved_count));
      (void)(((ctx->current_emit_empty_var_next_index) = saved_next));
      (void)(pipeline_dep_ctx_empty_param_restore(ctx));
    }
    /* Fallback return 0: Cap-T001 unsafe-region returns + by-value struct residual.
     * Default OFF when body_ref present (body already emitted via emit_block — including
     * returns nested in unsafe regions). Only keep scalar fallback for empty/expr-less bodies.
     * PLATFORM: SHARED — seed pin matches codegen.x; verify parser.x host-cc. */
    int need_fallback_return = 0;
    if (fn_ret_void) {
      /* PLATFORM: SHARED — void main process entry falls off → exit 0. */
      if (emit_c_main_symbol) {
        if (!(ast_ref_is_null(pipeline_module_func_body_ref_at(module, fi)))) {
          if ((codegen_block_contains_return(arena, pipeline_module_func_body_ref_at(module, fi)) == 0)) {
            (void)((need_fallback_return = 1));
          }
        } else {
          (void)((need_fallback_return = 1));
        }
      } else {
        (void)((need_fallback_return = 0));
      }
    } else if (!(ast_ref_is_null(pipeline_module_func_body_expr_ref_at(module, fi)))) {
      (void)((need_fallback_return = 0));
    } else if (!(ast_ref_is_null(pipeline_module_func_body_ref_at(module, fi)))) {
      /* Body block present: emit_block already ran. Append return 0 only if no return path
       * (including Cap-T001 unsafe region) AND return type is scalar/pointer. */
      int32_t body_br = pipeline_module_func_body_ref_at(module, fi);
      if ((codegen_block_contains_return(arena, body_br) == 0)) {
        int32_t ret_ord = pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(module, fi));
        /* Allow fallback only for integer-like / pointer (0..7 and TYPE_PTR=9). */
        if ((ret_ord >= 0 && ret_ord <= 7) || (ret_ord == 9)) {
          (void)((need_fallback_return = 1));
        }
      }
    } else {
      /* No body at all: scalar fallback for incomplete stubs. */
      int32_t ret_ord2 = pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(module, fi));
      if ((ret_ord2 >= 0 && ret_ord2 <= 7) || (ret_ord2 == 9)) {
        (void)((need_fallback_return = 1));
      }
    }
    if (need_fallback_return) {
      uint8_t ret0[9] = {114, 101, 116, 117, 114, 110, 32, 48, 59};
      if ((codegen_emit_indent(out, 2) !=0)) {
        return -(1);
      }
      if ((codegen_emit_bytes_9(out, ret0, 9) !=0)) {
        return -(1);
      }
      if ((codegen_append_byte(out, 10) !=0)) {
        return -(1);
      }
    }
    uint8_t close[3] = {125, 10, 0};
    if ((codegen_emit_bytes_3(out, close, 2) !=0)) {
      return -(1);
    }
    return 0;
  }
  return 0;
}
/* PLATFORM: SHARED — skip re-declaring libc symbols that conflict with system
 * headers when SHUX types (*u8→uint8_t*, i32→int32_t) differ from C. Must match
 * codegen.x codegen_is_libc_conflicting_extern_name (same names). */
int32_t codegen_is_libc_conflicting_extern_name(uint8_t * name, int32_t name_len) {
  if (((name ==((uint8_t *)(0))) || (name_len <=0))) {
    return 0;
  }
  /* read 4 */
  if ((((((name_len ==4) && ((name)[0] ==114)) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==100))) {
    return 1;
  }
  /* write 5 */
  if (((((((name_len ==5) && ((name)[0] ==119)) && ((name)[1] ==114)) && ((name)[2] ==105)) && ((name)[3] ==116)) && ((name)[4] ==101))) {
    return 1;
  }
  /* open 4 */
  if ((((((name_len ==4) && ((name)[0] ==111)) && ((name)[1] ==112)) && ((name)[2] ==101)) && ((name)[3] ==110))) {
    return 1;
  }
  /* close 5 */
  if (((((((name_len ==5) && ((name)[0] ==99)) && ((name)[1] ==108)) && ((name)[2] ==111)) && ((name)[3] ==115)) && ((name)[4] ==101))) {
    return 1;
  }
  /* fcntl 5 */
  if (((((((name_len ==5) && ((name)[0] ==102)) && ((name)[1] ==99)) && ((name)[2] ==110)) && ((name)[3] ==116)) && ((name)[4] ==108))) {
    return 1;
  }
  /* free 4 */
  if ((((((name_len ==4) && ((name)[0] ==102)) && ((name)[1] ==114)) && ((name)[2] ==101)) && ((name)[3] ==101))) {
    return 1;
  }
  /* malloc 6 */
  if ((((((((name_len ==6) && ((name)[0] ==109)) && ((name)[1] ==97)) && ((name)[2] ==108)) && ((name)[3] ==108)) && ((name)[4] ==111)) && ((name)[5] ==99))) {
    return 1;
  }
  /* calloc 6 */
  if ((((((((name_len ==6) && ((name)[0] ==99)) && ((name)[1] ==97)) && ((name)[2] ==108)) && ((name)[3] ==108)) && ((name)[4] ==111)) && ((name)[5] ==99))) {
    return 1;
  }
  /* realloc 7 — void* vs uint8_t* clash with stdlib.h (sync with codegen.x) */
  if (((((((((name_len ==7) && ((name)[0] ==114)) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==108)) && ((name)[4] ==108)) && ((name)[5] ==111)) && ((name)[6] ==99))) {
    return 1;
  }
  /* posix_memalign 14 — stdlib/POSIX prototype; skip SHUX redecl */
  if ((((((((((((((((name_len ==14) && ((name)[0] ==112)) && ((name)[1] ==111)) && ((name)[2] ==115)) && ((name)[3] ==105)) && ((name)[4] ==120)) && ((name)[5] ==95)) && ((name)[6] ==109)) && ((name)[7] ==101)) && ((name)[8] ==109)) && ((name)[9] ==97)) && ((name)[10] ==108)) && ((name)[11] ==105)) && ((name)[12] ==103)) && ((name)[13] ==110))) {
    return 1;
  }
  /* strtoul 7 — *u8 vs char* / u32 vs unsigned long (std/test) */
  if (((((((((name_len ==7) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==116)) && ((name)[4] ==111)) && ((name)[5] ==117)) && ((name)[6] ==108))) {
    return 1;
  }
  /* strtol 6 */
  if ((((((((name_len ==6) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==116)) && ((name)[4] ==111)) && ((name)[5] ==108))) {
    return 1;
  }
  /* strtoull 8 */
  if ((((((((((name_len ==8) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==116)) && ((name)[4] ==111)) && ((name)[5] ==117)) && ((name)[6] ==108)) && ((name)[7] ==108))) {
    return 1;
  }
  /* strtoll 7 */
  if (((((((((name_len ==7) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==116)) && ((name)[4] ==111)) && ((name)[5] ==108)) && ((name)[6] ==108))) {
    return 1;
  }
  /* memcpy 6 */
  if ((((((((name_len ==6) && ((name)[0] ==109)) && ((name)[1] ==101)) && ((name)[2] ==109)) && ((name)[3] ==99)) && ((name)[4] ==112)) && ((name)[5] ==121))) {
    return 1;
  }
  /* memcmp 6 */
  if ((((((((name_len ==6) && ((name)[0] ==109)) && ((name)[1] ==101)) && ((name)[2] ==109)) && ((name)[3] ==99)) && ((name)[4] ==109)) && ((name)[5] ==112))) {
    return 1;
  }
  /* memset 6 */
  if ((((((((name_len ==6) && ((name)[0] ==109)) && ((name)[1] ==101)) && ((name)[2] ==109)) && ((name)[3] ==115)) && ((name)[4] ==101)) && ((name)[5] ==116))) {
    return 1;
  }
  /* memchr 6 — glibc string.h may macro to _Generic; *u8 clash */
  if ((((((((name_len ==6) && ((name)[0] ==109)) && ((name)[1] ==101)) && ((name)[2] ==109)) && ((name)[3] ==99)) && ((name)[4] ==104)) && ((name)[5] ==114))) {
    return 1;
  }
  /* memrchr 7 */
  if (((((((((name_len ==7) && ((name)[0] ==109)) && ((name)[1] ==101)) && ((name)[2] ==109)) && ((name)[3] ==114)) && ((name)[4] ==99)) && ((name)[5] ==104)) && ((name)[6] ==114))) {
    return 1;
  }
  /* memmem 6 */
  if ((((((((name_len ==6) && ((name)[0] ==109)) && ((name)[1] ==101)) && ((name)[2] ==109)) && ((name)[3] ==109)) && ((name)[4] ==101)) && ((name)[5] ==109))) {
    return 1;
  }
  /* strchr 6 — string.h macro / char* clash (std/path) */
  if ((((((((name_len ==6) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==99)) && ((name)[4] ==104)) && ((name)[5] ==114))) {
    return 1;
  }
  /* strrchr 7 */
  if (((((((((name_len ==7) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==114)) && ((name)[4] ==99)) && ((name)[5] ==104)) && ((name)[6] ==114))) {
    return 1;
  }
  /* strcpy 6 */
  if ((((((((name_len ==6) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==99)) && ((name)[4] ==112)) && ((name)[5] ==121))) {
    return 1;
  }
  /* strncpy 7 */
  if (((((((((name_len ==7) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==110)) && ((name)[4] ==99)) && ((name)[5] ==112)) && ((name)[6] ==121))) {
    return 1;
  }
  /* getenv 6 */
  if ((((((((name_len ==6) && ((name)[0] ==103)) && ((name)[1] ==101)) && ((name)[2] ==116)) && ((name)[3] ==101)) && ((name)[4] ==110)) && ((name)[5] ==118))) {
    return 1;
  }
  /* getcwd 6 */
  if ((((((((name_len ==6) && ((name)[0] ==103)) && ((name)[1] ==101)) && ((name)[2] ==116)) && ((name)[3] ==99)) && ((name)[4] ==119)) && ((name)[5] ==100))) {
    return 1;
  }
  /* unlink 6 */
  if ((((((((name_len ==6) && ((name)[0] ==117)) && ((name)[1] ==110)) && ((name)[2] ==108)) && ((name)[3] ==105)) && ((name)[4] ==110)) && ((name)[5] ==107))) {
    return 1;
  }
  /* strlen 6 */
  if ((((((((name_len ==6) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==108)) && ((name)[4] ==101)) && ((name)[5] ==110))) {
    return 1;
  }
  /* strcmp 6 */
  if ((((((((name_len ==6) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==99)) && ((name)[4] ==109)) && ((name)[5] ==112))) {
    return 1;
  }
  /* strncmp 7 */
  if (((((((((name_len ==7) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==110)) && ((name)[4] ==99)) && ((name)[5] ==109)) && ((name)[6] ==112))) {
    return 1;
  }
  /* strstr 6 */
  if ((((((((name_len ==6) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==115)) && ((name)[4] ==116)) && ((name)[5] ==114))) {
    return 1;
  }
  /* setenv 6 */
  if ((((((((name_len ==6) && ((name)[0] ==115)) && ((name)[1] ==101)) && ((name)[2] ==116)) && ((name)[3] ==101)) && ((name)[4] ==110)) && ((name)[5] ==118))) {
    return 1;
  }
  /* system 6 */
  if ((((((((name_len ==6) && ((name)[0] ==115)) && ((name)[1] ==121)) && ((name)[2] ==115)) && ((name)[3] ==116)) && ((name)[4] ==101)) && ((name)[5] ==109))) {
    return 1;
  }
  /* fputs 5 */
  if (((((((name_len ==5) && ((name)[0] ==102)) && ((name)[1] ==112)) && ((name)[2] ==117)) && ((name)[3] ==116)) && ((name)[4] ==115))) {
    return 1;
  }
  /* strerror 8 */
  if ((((((((((name_len ==8) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==101)) && ((name)[4] ==114)) && ((name)[5] ==114)) && ((name)[6] ==111)) && ((name)[7] ==114))) {
    return 1;
  }
  /* opendir/closedir: not skipped — DIR* modeled as *u8 (sync codegen.x) */
  /* access 6 */
  if ((((((((name_len ==6) && ((name)[0] ==97)) && ((name)[1] ==99)) && ((name)[2] ==99)) && ((name)[3] ==101)) && ((name)[4] ==115)) && ((name)[5] ==115))) {
    return 1;
  }
  /* mkstemp 7 — wave30: root skip (was g05-sed-only); sync codegen.x */
  if (((((((((name_len ==7) && ((name)[0] ==109)) && ((name)[1] ==107)) && ((name)[2] ==115)) && ((name)[3] ==116)) && ((name)[4] ==101)) && ((name)[5] ==109)) && ((name)[6] ==112))) {
    return 1;
  }
  /* rename 6 — wave30: root skip (was g05-sed-only); sync codegen.x */
  if ((((((((name_len ==6) && ((name)[0] ==114)) && ((name)[1] ==101)) && ((name)[2] ==110)) && ((name)[3] ==97)) && ((name)[4] ==109)) && ((name)[5] ==101))) {
    return 1;
  }
  return 0;
}
int32_t codegen_find_mono_type_for_generic_func(struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi) {
  {
    uint8_t fn_local[64] = {};
    int32_t fn_len = pipeline_module_func_name_len_at(module, fi);
    int32_t ei = 1;
    if (((((arena ==((struct ast_ASTArena *)(0))) || (module ==((struct ast_Module *)(0)))) || (fi < 0)) || (fi >=(module->num_funcs)))) {
      return 0;
    }
    (void)(codegen_copy_func_name64_from_module(module, fi, &((fn_local)[0])));
    if ((fn_len <=0)) {
      return 0;
    }
    while ((ei <=(arena->num_exprs))) {
      struct ast_Expr e = ast_ast_arena_expr_get(arena, ei);
      if (((e.kind) ==48)) {
        int32_t matched = 0;
        if (((e.call_resolved_func_index) ==fi)) {
          (void)((matched = 1));
        } else {
          if (((!(ast_ref_is_null((e.call_callee_ref))) && ((e.call_callee_ref) > 0)) && ((e.call_callee_ref) <=(arena->num_exprs)))) {
            struct ast_Expr cal = ast_ast_arena_expr_get(arena, (e.call_callee_ref));
            if ((((cal.kind) ==3) && ((cal.var_name_len) ==fn_len))) {
              int32_t eq = 1;
              int32_t k = 0;
              while ((k < fn_len)) {
                if ((((cal.var_name))[k] !=(fn_local)[k])) {
                  (void)((eq = 0));
                  (void)((k = fn_len));
                } else {
                  (void)((k = (k + 1)));
                }
              }
              (void)((matched = eq));
            }
          }
        }
        if ((matched !=0)) {
          int32_t ty = (e.resolved_type_ref);
          if (((ty <=0) && ((e.call_num_args) > 0))) {
            int32_t a0 = pipeline_expr_call_arg_ref(arena, ei, 0);
            if ((a0 > 0)) {
              (void)((ty = pipeline_expr_resolved_type_ref(arena, a0)));
            }
          }
          if ((ty > 0)) {
            return ty;
          }
        }
      }
      (void)((ei = (ei + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t codegen_try_emit_generic_identity_mono(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx) {
  {
    int32_t ret_ty = pipeline_module_func_return_type_at(module, fi);
    int32_t p0_ty = pipeline_module_func_param_type_ref_at(module, fi, 0);
    uint8_t ret_nm[64] = {};
    uint8_t p0_nm[64] = {};
    int32_t ret_nl = pipeline_type_named_name_into(arena, ret_ty, &((ret_nm)[0]));
    int32_t p0_nl = pipeline_type_named_name_into(arena, p0_ty, &((p0_nm)[0]));
    int32_t bi = 0;
    int32_t mono_ty = codegen_find_mono_type_for_generic_func(arena, module, fi);
    int32_t pn_len = pipeline_module_func_param_name_len_at(module, fi, 0);
    uint8_t pn[32] = {};
    uint8_t fn_local[64] = {};
    int32_t fn_len = pipeline_module_func_name_len_at(module, fi);
    int32_t mono_sym_pre = codegen_func_c_symbol_prefix_len(module, fi, prefix_len);
    uint8_t open_body[4] = {41, 32, 123, 10};
    uint8_t ret_kw[8] = {114, 101, 116, 117, 114, 110, 32, 0};
    uint8_t end[3] = {59, 10, 125};
    if ((((arena ==((struct ast_ASTArena *)(0))) || (out ==((struct codegen_CodegenOutBuf *)(0)))) || (module ==((struct ast_Module *)(0))))) {
      return 0;
    }
    if (((fi < 0) || (fi >=(module->num_funcs)))) {
      return 0;
    }
    if ((pipeline_module_func_num_generic_params_at(module, fi) <=0)) {
      return 0;
    }
    if ((pipeline_module_func_is_extern_at(module, fi) !=0)) {
      return 0;
    }
    if ((pipeline_module_func_num_params_at(module, fi) !=1)) {
      return 0;
    }
    if (((ret_ty <=0) || (p0_ty <=0))) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, ret_ty) !=8)) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, p0_ty) !=8)) {
      return 0;
    }
    if (((ret_nl <=0) || (ret_nl !=p0_nl))) {
      return 0;
    }
    while ((bi < ret_nl)) {
      if (((ret_nm)[bi] !=(p0_nm)[bi])) {
        return 0;
      }
      (void)((bi = (bi + 1)));
    }
    if ((mono_ty <=0)) {
      return 0;
    }
    (void)(pipeline_module_func_param_name_copy32(module, fi, 0, &((pn)[0])));
    if ((pn_len <=0)) {
      (void)(((pn)[0] = 120));
      (void)((pn_len = 1));
    }
    if ((codegen_emit_type(arena, out, mono_ty, prefix, prefix_len, ctx) !=0)) {
      return -(1);
    }
    if ((codegen_append_byte(out, 32) !=0)) {
      return -(1);
    }
    (void)(codegen_copy_func_name64_from_module(module, fi, &((fn_local)[0])));
    if (((mono_sym_pre > 0) && (codegen_c_prefix_redundant_with_name(prefix, mono_sym_pre, &((fn_local)[0]), fn_len) ==0))) {
      if ((codegen_emit_bytes_from_ptr(out, prefix, mono_sym_pre) !=0)) {
        return -(1);
      }
    }
    if ((codegen_emit_func_link_name(out, arena, module, fi) !=0)) {
      return -(1);
    }
    if ((codegen_append_byte(out, 40) !=0)) {
      return -(1);
    }
    if ((codegen_emit_type(arena, out, mono_ty, prefix, prefix_len, ctx) !=0)) {
      return -(1);
    }
    if ((codegen_append_byte(out, 32) !=0)) {
      return -(1);
    }
    if ((codegen_emit_bytes_from_ptr(out, &((pn)[0]), pn_len) !=0)) {
      return -(1);
    }
    if ((codegen_emit_bytes_from_ptr(out, &((open_body)[0]), 4) !=0)) {
      return -(1);
    }
    if ((codegen_emit_indent(out, 2) !=0)) {
      return -(1);
    }
    if ((codegen_emit_bytes_from_ptr(out, &((ret_kw)[0]), 7) !=0)) {
      return -(1);
    }
    if ((codegen_emit_bytes_from_ptr(out, &((pn)[0]), pn_len) !=0)) {
      return -(1);
    }
    if ((codegen_emit_bytes_from_ptr(out, &((end)[0]), 3) !=0)) {
      return -(1);
    }
    if ((codegen_append_byte(out, 10) !=0)) {
      return -(1);
    }
    return 1;
  }
  return 0;
}
int32_t codegen_emit_func_extern_declaration(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx) {
  {
    uint8_t fn_local[64] = {};
    int32_t fn_len = pipeline_module_func_name_len_at(module, fi);
    uint8_t kw[8] = {101, 120, 116, 101, 114, 110, 32, 0};
    int32_t name_prefix_len = prefix_len;
    uint8_t lpar[2] = {40, 0};
    uint8_t end_proto[3] = {41, 59, 10};
    if (((fi < 0) || (fi >=(module->num_funcs)))) {
      return -(1);
    }
    if ((pipeline_module_func_num_generic_params_at(module, fi) > 0)) {
      return 0;
    }
    (void)(codegen_copy_func_name64_from_module(module, fi, &((fn_local)[0])));
    if (((pipeline_module_func_is_extern_at(module, fi) !=0) && (codegen_is_libc_conflicting_extern_name(&((fn_local)[0]), fn_len) !=0))) {
      return 0;
    }
    if ((codegen_emit_bytes_from_ptr(out, &((kw)[0]), 7) !=0)) {
      return -(1);
    }
    if ((pipeline_module_func_is_used_at(module, fi) !=0)) {
      uint8_t used_attr[27] = {95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 115, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((used_attr)[0]), 22) !=0)) {
        return -(1);
      }
    }
    if ((pipeline_module_func_is_naked_at(module, fi) !=0)) {
      uint8_t naked_attr[29] = {95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 97, 107, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((naked_attr)[0]), 23) !=0)) {
        return -(1);
      }
    }
    if ((pipeline_module_func_is_entry_at(module, fi) !=0)) {
      uint8_t entry_attr[30] = {95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 111, 114, 101, 116, 117, 114, 110, 41, 41, 32, 0, 0, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((entry_attr)[0]), 26) !=0)) {
        return -(1);
      }
    }
    if ((pipeline_module_func_is_interrupt_at(module, fi) !=0)) {
      uint8_t int_attr[31] = {95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 105, 110, 116, 101, 114, 114, 117, 112, 116, 41, 41, 32, 0, 0, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((int_attr)[0]), 27) !=0)) {
        return -(1);
      }
    }
    if ((codegen_emit_type(arena, out, pipeline_module_func_return_type_at(module, fi), prefix, prefix_len, ctx) !=0)) {
      return -(1);
    }
    if ((codegen_append_byte(out, 32) !=0)) {
      return -(1);
    }
    if ((pipeline_module_func_is_extern_at(module, fi) !=0)) {
      int _starts_with_prefix = 0;
      if (((prefix_len > 0) && (fn_len >=prefix_len))) {
        int32_t _k = 0;
        (void)((_starts_with_prefix = 1));
        while ((_k < prefix_len)) {
          if (((fn_local)[_k] !=(prefix)[_k])) {
            (void)((_starts_with_prefix = 0));
            break;
          }
          (void)((_k = (_k + 1)));
        }
      }
      if (!(_starts_with_prefix)) {
        (void)((name_prefix_len = 0));
      }
    }
    (void)((name_prefix_len = codegen_func_c_symbol_prefix_len(module, fi, name_prefix_len)));
    if ((((name_prefix_len > 0) && (codegen_c_prefix_redundant_with_name(prefix, name_prefix_len, &((fn_local)[0]), fn_len) ==0)) && (codegen_emit_bytes_from_ptr(out, prefix, name_prefix_len) !=0))) {
      return -(1);
    }
    if ((codegen_emit_func_link_name(out, arena, module, fi) !=0)) {
      return -(1);
    }
    if ((codegen_std_io_fixed_fd_emit_impl(prefix, prefix_len, &((fn_local)[0]), fn_len) !=0)) {
      uint8_t impl_suffix[6] = {95, 105, 109, 112, 108, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((impl_suffix)[0]), 5) !=0)) {
        return -(1);
      }
    }
    if ((codegen_emit_bytes_2(out, lpar, 1) !=0)) {
      return -(1);
    }
    if ((pipeline_module_func_num_params_at(module, fi) ==0)) {
      uint8_t v[7] = {118, 111, 105, 100, 0, 0, 0};
      if ((codegen_emit_bytes_7(out, v, 4) !=0)) {
        return -(1);
      }
    } else {
      int32_t p = 0;
      while ((p < pipeline_module_func_num_params_at(module, fi))) {
        if ((p > 0)) {
          uint8_t comma[3] = {44, 32, 0};
          if ((codegen_emit_bytes_3(out, comma, 2) !=0)) {
            return -(1);
          }
        }
        if ((codegen_force_param_size_t_std_io_print_str_second(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
          uint8_t size_t_buf2[32] = {115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
          if ((codegen_emit_bytes_32(out, size_t_buf2, 7) !=0)) {
            return -(1);
          }
        } else {
          if ((codegen_force_param_size_t(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
            uint8_t size_t_buf[32] = {115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
            if ((codegen_emit_bytes_32(out, size_t_buf, 7) !=0)) {
              return -(1);
            }
          } else {
            if ((codegen_force_param_ptrdiff_t(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
              uint8_t ptrdiff_t_buf[32] = {112, 116, 114, 100, 105, 102, 102, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
              if ((codegen_emit_bytes_32(out, ptrdiff_t_buf, 10) !=0)) {
                return -(1);
              }
            } else {
              if ((codegen_force_param_uint32_t(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
                uint8_t u32_buf[32] = {117, 105, 110, 116, 51, 50, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
                if ((codegen_emit_bytes_32(out, u32_buf, 9) !=0)) {
                  return -(1);
                }
              } else {
                if ((codegen_force_param_i32(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
                  uint8_t i32_str[8] = {105, 110, 116, 51, 50, 95, 116, 0};
                  if ((codegen_emit_bytes_8(out, i32_str, 7) !=0)) {
                    return -(1);
                  }
                } else {
                  if ((codegen_emit_type(arena, out, pipeline_module_func_param_type_ref_at(module, fi, p), prefix, prefix_len, ctx) !=0)) {
                    return -(1);
                  }
                  /* PLATFORM: SHARED — TYPE_SLICE params as pointers (seed/glue ABI). */
                  if ((pipeline_type_kind_ord_at(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) ==11)) {
                    if ((codegen_append_byte(out, 32) !=0)) {
                      return -(1);
                    }
                    if ((codegen_append_byte(out, 42) !=0)) {
                      return -(1);
                    }
                  }
                }
              }
            }
          }
        }
        if ((codegen_append_byte(out, 32) !=0)) {
          return -(1);
        }
        if ((pipeline_module_func_param_name_len_at(module, fi, p) > 0)) {
          uint8_t plocal[32] = {};
          (void)(codegen_copy_param_name32_from_module(module, fi, p, &((plocal)[0])));
          if ((((plocal)[0] > 32) && (codegen_emit_bytes_32(out, plocal, pipeline_module_func_param_name_len_at(module, fi, p)) !=0))) {
            return -(1);
          }
        } else {
          uint8_t place[4] = {95, 112, 48, 0};
          if ((codegen_emit_bytes_4(out, place, 2) !=0)) {
            return -(1);
          }
          if ((codegen_format_int(out, p) !=0)) {
            return -(1);
          }
        }
        (void)((p = (p + 1)));
      }
    }
    if (((pipeline_module_func_is_variadic_at(module, fi) !=0) && (pipeline_module_func_num_params_at(module, fi) > 0))) {
      uint8_t ellipsis[5] = {44, 32, 46, 46, 46};
      if ((codegen_emit_bytes_from_ptr(out, &((ellipsis)[0]), 5) !=0)) {
        return -(1);
      }
    }
    if ((codegen_emit_bytes_from_ptr(out, &((end_proto)[0]), 3) !=0)) {
      return -(1);
    }
    return 0;
  }
  return 0;
}
int32_t codegen_emit_import_dep_function_declarations(struct ast_Module * module, struct codegen_CodegenOutBuf * out, struct ast_PipelineDepCtx * ctx) {
  {
    struct ast_Module * saved_module = (ctx->current_codegen_module);
    struct ast_ASTArena * saved_arena = (ctx->current_codegen_arena);
    int32_t saved_dep_index = (ctx->current_codegen_dep_index);
    int32_t saved_prefix_len = (ctx->current_codegen_prefix_len);
    uint8_t saved_prefix[64] = {};
    int32_t sp = 0;
    int32_t n_imp = codegen_module_num_imports(module);
    int32_t imp_i = 0;
    if ((((module ==((struct ast_Module *)(0))) || (out ==((struct codegen_CodegenOutBuf *)(0)))) || (ctx ==((struct ast_PipelineDepCtx *)(0))))) {
      return 0;
    }
    while ((sp < 64)) {
      (void)(((saved_prefix)[sp] = ((ctx->current_codegen_prefix_mirror))[sp]));
      (void)((sp = (sp + 1)));
    }
    while ((imp_i < n_imp)) {
      uint8_t dep_path[64] = {};
      int32_t dep_path_len = codegen_module_import_path_len_at(module, imp_i, &((dep_path)[0]));
      if ((dep_path_len > 0)) {
        int32_t seen_before = 0;
        int32_t prev_i = 0;
        while ((prev_i < imp_i)) {
          uint8_t prev_path[64] = {};
          int32_t prev_len = codegen_module_import_path_len_at(module, prev_i, &((prev_path)[0]));
          if ((prev_len ==dep_path_len)) {
            int eq_prev = 1;
            int32_t pk = 0;
            while (((pk < dep_path_len) && (pk < 64))) {
              if (((prev_path)[pk] !=(dep_path)[pk])) {
                (void)((eq_prev = 0));
                break;
              }
              (void)((pk = (pk + 1)));
            }
            if (eq_prev) {
              (void)((seen_before = 1));
              break;
            }
          }
          (void)((prev_i = (prev_i + 1)));
        }
        if ((seen_before ==0)) {
          int32_t dep_ix = codegen_find_dep_index_by_path(ctx, &((dep_path)[0]), dep_path_len);
          struct ast_Module * dep_mod = ((struct ast_Module *)(0));
          struct ast_ASTArena * dep_arena = ((struct ast_ASTArena *)(0));
          int32_t dep_ctx_ix = dep_ix;
          if (getenv("SHUX_DEBUG_PREFIX"))
            fprintf(stderr, "shux: [DBG_PREFIX] emit_import_dep_decl module=%p n_imp=%d imp_i=%d dep_path=%.*s dep_ix=%d\n",
                    (void*)module, (int)n_imp, (int)imp_i, (int)dep_path_len, (char*)dep_path, (int)dep_ix);
          if (((dep_ix >=0) && (dep_ix < pipeline_dep_ctx_ndep(ctx)))) {
            (void)((dep_mod = pipeline_dep_ctx_module_at(ctx, dep_ix)));
            (void)((dep_arena = pipeline_dep_ctx_arena_at(ctx, dep_ix)));
            if (getenv("SHUX_DEBUG_PREFIX"))
              fprintf(stderr, "shux: [DBG_PREFIX]   -> dep_ix=%d dep_mod=%p num_funcs=%d\n",
                      (int)dep_ix, (void*)dep_mod, dep_mod ? (int)dep_mod->num_funcs : -1);
          }
          if ((((dep_mod ==((struct ast_Module *)(0))) || (dep_arena ==((struct ast_ASTArena *)(0)))) && (dep_path_len > 0))) {
            int32_t global_slot = codegen_find_seeded_global_dep_slot_by_path(&((dep_path)[0]), dep_path_len);
            if ((global_slot >=0)) {
              (void)((dep_mod = ((struct ast_Module *)(driver_dep_module_buf(global_slot)))));
              (void)((dep_arena = ((struct ast_ASTArena *)(driver_dep_arena_buf(global_slot)))));
              (void)((dep_ctx_ix = -(1)));
            }
          }
          if ((((dep_mod !=((struct ast_Module *)(0))) && (dep_arena !=((struct ast_ASTArena *)(0)))) && ((dep_mod->num_funcs) > 0))) {
            uint8_t prefix_buf[128] = {};
            int32_t prefix_len = 0;
            if ((codegen_path_is_std_io_core_bytes(&((dep_path)[0])) ==0)) {
              (void)(codegen_import_path_to_c_prefix_into(&((dep_path)[0]), &((prefix_buf)[0]), 128));
              while (((prefix_len < 128) && ((prefix_buf)[prefix_len] !=((uint8_t)(0))))) {
                (void)((prefix_len = (prefix_len + 1)));
              }
            }
            (void)(((ctx->current_codegen_module) = dep_mod));
            (void)(((ctx->current_codegen_arena) = dep_arena));
            (void)(((ctx->current_codegen_dep_index) = dep_ctx_ix));
            (void)(((ctx->current_codegen_prefix_len) = 0));
            int32_t px = 0;
            while (((px < prefix_len) && (px < 63))) {
              (void)((((ctx->current_codegen_prefix_mirror))[px] = (prefix_buf)[px]));
              (void)((px = (px + 1)));
            }
            (void)((((ctx->current_codegen_prefix_mirror))[px] = ((uint8_t)(0))));
            (void)(((ctx->current_codegen_prefix_len) = px));
            int32_t fi = 0;
            while ((fi < (dep_mod->num_funcs))) {
              if ((codegen_emit_func_extern_declaration(dep_arena, out, dep_mod, fi, &((prefix_buf)[0]), prefix_len, ctx) !=0)) {
                return -(1);
              }
              (void)((fi = (fi + 1)));
            }
          }
        }
      }
      (void)((imp_i = (imp_i + 1)));
    }
    (void)(((ctx->current_codegen_module) = saved_module));
    (void)(((ctx->current_codegen_arena) = saved_arena));
    (void)(((ctx->current_codegen_dep_index) = saved_dep_index));
    (void)(((ctx->current_codegen_prefix_len) = saved_prefix_len));
    (void)((sp = 0));
    while ((sp < 64)) {
      (void)((((ctx->current_codegen_prefix_mirror))[sp] = (saved_prefix)[sp]));
      (void)((sp = (sp + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t codegen_x_ast_emit_header(struct codegen_CodegenOutBuf * out) {
  uint8_t h[64] = {35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 116, 100, 105, 110, 116, 46, 104, 62, 10, 35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 116, 100, 100, 101, 102, 46, 104, 62, 10, 35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 121, 115, 47, 116, 121, 112, 101, 115, 46, 104, 62, 10, 0};
  return codegen_emit_bytes_64(out, &((h)[0]), 63);
}
extern int32_t pipeline_codegen_std_dep_link_only(uint8_t * path);
int32_t codegen_x_ast(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_PipelineDepCtx * ctx, int32_t dep_index) {
  {
    uint8_t prefix_buf[128] = {};
    int32_t prefix_len = 0;
    uint8_t dep_path_prefix[64] = {};
    int32_t dep_path_prefix_len = 0;
    int32_t call_init_globals = 0;
    int32_t i = 0;
    if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
      (void)(((ctx->current_codegen_module) = module));
      (void)(((ctx->current_codegen_arena) = arena));
      (void)(((ctx->current_codegen_dep_index) = dep_index));
    }
    if (((dep_index >=0) && (ctx !=((struct ast_PipelineDepCtx *)(0))))) {
      (void)((dep_path_prefix_len = codegen_dep_import_path_len_at(ctx, dep_index, &((dep_path_prefix)[0]))));
      if (((dep_path_prefix_len > 0) && (pipeline_codegen_std_dep_link_only(&((dep_path_prefix)[0])) !=0))) {
        return 0;
      }
    }
    if ((((dep_index >=0) && (ctx !=((struct ast_PipelineDepCtx *)(0)))) && (dep_path_prefix_len > 0))) {
      if ((codegen_path_is_std_io_core_bytes(&((dep_path_prefix)[0])) ==0)) {
        (void)(codegen_import_path_to_c_prefix_into(&((dep_path_prefix)[0]), &((prefix_buf)[0]), 128));
        while (((prefix_len < 128) && ((prefix_buf)[prefix_len] !=0))) {
          (void)((prefix_len = (prefix_len + 1)));
        }
      }
    }
    if (((prefix_len ==0) && (((dep_index < 0) || (dep_path_prefix_len ==0)) || (codegen_path_is_std_io_core_bytes(&((dep_path_prefix)[0])) ==0)))) {
      (void)((prefix_len = 0));
      (void)(((prefix_buf)[0] = ((uint8_t)(0))));
      if ((dep_path_prefix_len > 0)) {
        (void)(codegen_import_path_to_c_prefix_into(&((dep_path_prefix)[0]), &((prefix_buf)[0]), 128));
        while (((prefix_len < 128) && ((prefix_buf)[prefix_len] !=0))) {
          (void)((prefix_len = (prefix_len + 1)));
        }
      }
    }
    if ((((prefix_len ==0) && (dep_index < 0)) && (ctx !=((struct ast_PipelineDepCtx *)(0))))) {
      if (((ctx->entry_module_import_path_len) > 0)) {
        int32_t pi = 0;
        while (((pi < (ctx->entry_module_import_path_len)) && (pi < 127))) {
          (void)(((prefix_buf)[pi] = ((ctx->entry_module_import_path_mirror))[pi]));
          (void)((pi = (pi + 1)));
        }
        (void)(((prefix_buf)[pi] = ((uint8_t)(0))));
        (void)((prefix_len = pi));
      }
    }
    if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
      int32_t px = 0;
      (void)(((ctx->current_codegen_prefix_len) = 0));
      while (((px < prefix_len) && (px < 63))) {
        (void)((((ctx->current_codegen_prefix_mirror))[px] = (prefix_buf)[px]));
        (void)((px = (px + 1)));
      }
      (void)((((ctx->current_codegen_prefix_mirror))[px] = ((uint8_t)(0))));
      (void)(((ctx->current_codegen_prefix_len) = px));
    }
    if (((module->num_top_level_lets) > 0)) {
      int32_t ti = 0;
      while ((ti < (module->num_top_level_lets))) {
        if ((pipeline_module_top_level_let_is_const(module, ti) ==0)) {
          (void)((call_init_globals = 1));
          break;
        }
        (void)((ti = (ti + 1)));
      }
    }
    while ((i < (module->num_funcs))) {
      uint8_t skip_name[64] = {};
      int32_t skip_nl = pipeline_module_func_name_len_at(module, i);
      int32_t skip = 0;
      int32_t asm_backend = 0;
      int is_entry = ((i ==(module->main_func_index)) || ((module->num_funcs) ==1));
      int32_t saved_func_idx = -(1);
      if ((i ==0)) {
        int32_t fwd_fi = 0;
        if ((pipeline_codegen_c_file_prologue_done_get() ==0)) {
          if ((codegen_x_ast_emit_header(out) !=0)) {
            return -(1);
          }
          if ((codegen_emit_skipped_dep_type_definitions(ctx, out) !=0)) {
            return -(1);
          }
          if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
            (void)(((ctx->current_codegen_module) = module));
            (void)(((ctx->current_codegen_arena) = arena));
          }
          if ((codegen_emit_dep_struct_forward_declarations(ctx, out) !=0)) {
            return -(1);
          }
          (void)(pipeline_codegen_c_file_prologue_done_set(1));
        }
        if ((codegen_emit_import_dep_function_declarations(module, out, ctx) !=0)) {
          return -(1);
        }
        if ((dep_index < 0)) {
          if ((codegen_emit_module_enum_definitions(module, out, &((prefix_buf)[0]), prefix_len) !=0)) {
            return -(1);
          }
          if ((codegen_emit_module_struct_definitions(module, arena, out, &((prefix_buf)[0]), prefix_len, ctx) !=0)) {
            return -(1);
          }
        }
        while ((fwd_fi < (module->num_funcs))) {
          if ((pipeline_module_func_is_extern_at(module, fwd_fi) ==0)) {
            if ((codegen_emit_func_extern_declaration(arena, out, module, fwd_fi, &((prefix_buf)[0]), prefix_len, ctx) !=0)) {
              return -(1);
            }
          }
          (void)((fwd_fi = (fwd_fi + 1)));
        }
        if (((module->num_top_level_lets) > 0)) {
          int32_t ti = 0;
          while ((ti < (module->num_top_level_lets))) {
            int32_t is_const = pipeline_module_top_level_let_is_const(module, ti);
            int32_t name_len = pipeline_module_top_level_let_name_len(module, ti);
            if (((name_len <=0) || (name_len > 63))) {
              (void)((ti = (ti + 1)));
              continue;
            }
            uint8_t tl_name_buf[64] = {};
            int32_t tni = 0;
            while (((tni < name_len) && (tni < 64))) {
              (void)(((tl_name_buf)[tni] = pipeline_module_top_level_let_name_byte_at(module, ti, tni)));
              (void)((tni = (tni + 1)));
            }
            int32_t tl_ty = pipeline_module_top_level_let_type_ref(module, ti);
            int32_t tl_init = pipeline_module_top_level_let_init_ref(module, ti);
            int32_t is_fixed_arr = 0;
            if ((!(ast_ref_is_null(tl_ty)) && (pipeline_type_kind_ord_at(arena, tl_ty) ==10))) {
              (void)((is_fixed_arr = 1));
            }
            /* PLATFORM: SHARED — #undef bare top-level names before static object emit so
             * product preamble macros (O_CREAT, MAP_FAILED, S_IFMT, ...) and host macros
             * do not expand the declarator. Keep in sync with codegen.x.
             * (want_decl_init declared here: C decl-before-stmt for seed host cc.) */
            int32_t want_decl_init = 0;
            uint8_t undef_kw[8] = {35, 117, 110, 100, 101, 102, 32, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((undef_kw)[0]), 7) !=0)) {
              return -(1);
            }
            if ((codegen_emit_bytes_from_ptr(out, &((tl_name_buf)[0]), name_len) !=0)) {
              return -(1);
            }
            if ((codegen_append_byte(out, 10) !=0)) {
              return -(1);
            }
            if ((is_const !=0)) {
              uint8_t static_const[15] = {115, 116, 97, 116, 105, 99, 32, 99, 111, 110, 115, 116, 32, 0, 0};
              if ((codegen_emit_bytes_from_ptr(out, &((static_const)[0]), 13) !=0)) {
                return -(1);
              }
            } else {
              uint8_t static_[9] = {115, 116, 97, 116, 105, 99, 32, 0, 0};
              if ((codegen_emit_bytes_from_ptr(out, &((static_)[0]), 7) !=0)) {
                return -(1);
              }
            }
            if ((is_fixed_arr !=0)) {
              if ((codegen_emit_local_fixed_array_elem_type(arena, out, tl_ty, ctx) !=0)) {
                return -(1);
              }
            } else {
              if ((codegen_emit_type(arena, out, tl_ty, &((prefix_buf)[0]), 0, ctx) !=0)) {
                return -(1);
              }
            }
            if ((codegen_append_byte(out, 32) !=0)) {
              return -(1);
            }
            if ((codegen_emit_bytes_from_ptr(out, &((tl_name_buf)[0]), name_len) !=0)) {
              return -(1);
            }
            if ((is_fixed_arr !=0)) {
              if ((codegen_emit_local_fixed_array_suffix(arena, out, tl_ty) !=0)) {
                return -(1);
              }
            }
            /* PLATFORM: SHARED — decl-site init for fixed arrays, const, and mutable lets
             * whose init is a C static constant (pipeline_expr_is_c_static_const_init).
             * Library/dep .o has no main → init_globals never runs; BSS must not wipe -1
             * sentinels (e.g. shu_heap_trace_on). VAR-dependent inits (a+2) stay init_globals.
             * Keep in sync with codegen.x. */
            if (((is_fixed_arr !=0) && !(ast_ref_is_null(tl_init)))) {
              if ((pipeline_expr_kind_ord_at(arena, tl_init) ==((int32_t)(46)))) {
                if ((pipeline_expr_array_lit_num_elems_at(arena, tl_init) > 0)) {
                  (void)((want_decl_init = 1));
                }
              } else {
                (void)((want_decl_init = 1));
              }
            }
            if ((((is_const !=0) && (is_fixed_arr ==0)) && !(ast_ref_is_null(tl_init)))) {
              (void)((want_decl_init = 1));
            }
            if ((((is_const ==0) && (is_fixed_arr ==0)) && !(ast_ref_is_null(tl_init)))) {
              if ((pipeline_expr_is_c_static_const_init(arena, tl_init) !=0)) {
                (void)((want_decl_init = 1));
              }
            }
            if ((want_decl_init !=0)) {
              uint8_t eq[4] = {32, 61, 32, 0};
              if ((codegen_emit_bytes_4(out, eq, 3) !=0)) {
                return -(1);
              }
              if ((is_fixed_arr !=0)) {
                if ((codegen_emit_braced_array_lit_init(arena, out, tl_init, ctx) !=0)) {
                  return -(1);
                }
              } else {
                if ((codegen_emit_expr(arena, out, tl_init, ctx) !=0)) {
                  return -(1);
                }
              }
            }
            uint8_t sc[3] = {59, 10, 0};
            if ((codegen_emit_bytes_3(out, sc, 2) !=0)) {
              return -(1);
            }
            (void)((ti = (ti + 1)));
          }
          int32_t any_let = 0;
          (void)((ti = 0));
          while ((ti < (module->num_top_level_lets))) {
            if ((pipeline_module_top_level_let_is_const(module, ti) ==0)) {
              (void)((any_let = 1));
              break;
            }
            (void)((ti = (ti + 1)));
          }
          if ((((dep_index < 0) && (any_let ==0)) && ((module->main_func_index) >=0))) {
            int32_t dep_scan_i = 0;
            int32_t dep_ndep = pipeline_dep_ctx_ndep(ctx);
            while ((dep_scan_i < dep_ndep)) {
              uint8_t scan_path[64] = {};
              int32_t scan_plen = codegen_dep_import_path_len_at(ctx, dep_scan_i, &((scan_path)[0]));
              if (((scan_plen > 0) && (pipeline_codegen_std_dep_link_only(&((scan_path)[0])) !=0))) {
                (void)((dep_scan_i = (dep_scan_i + 1)));
                continue;
              }
              struct ast_Module * dep_scan_mod = pipeline_dep_ctx_module_at(ctx, dep_scan_i);
              if ((dep_scan_mod !=((struct ast_Module *)(0)))) {
                int32_t dep_ti = 0;
                while ((dep_ti < (dep_scan_mod->num_top_level_lets))) {
                  if ((pipeline_module_top_level_let_is_const(dep_scan_mod, dep_ti) ==0)) {
                    (void)((any_let = 1));
                    break;
                  }
                  (void)((dep_ti = (dep_ti + 1)));
                }
              }
              if ((any_let !=0)) {
                break;
              }
              (void)((dep_scan_i = (dep_scan_i + 1)));
            }
          }
          if (((any_let !=0) && (dep_index < 0))) {
            uint8_t init_globals_def[32] = {115, 116, 97, 116, 105, 99, 32, 118, 111, 105, 100, 32, 105, 110, 105, 116, 95, 103, 108, 111, 98, 97, 108, 115, 40, 118, 111, 105, 100, 41, 32, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((init_globals_def)[0]), 31) !=0)) {
              return -(1);
            }
            uint8_t brace3[3] = {123, 10, 0};
            if ((codegen_emit_bytes_3(out, brace3, 2) !=0)) {
              return -(1);
            }
            (void)((ti = 0));
            while ((ti < (module->num_top_level_lets))) {
              int32_t ig_ty = pipeline_module_top_level_let_type_ref(module, ti);
              int32_t nlen = pipeline_module_top_level_let_name_len(module, ti);
              uint8_t eq2[4] = {32, 61, 32, 0};
              uint8_t sc2[3] = {59, 10, 0};
              if ((pipeline_module_top_level_let_is_const(module, ti) !=0)) {
                (void)((ti = (ti + 1)));
                continue;
              }
              if ((!(ast_ref_is_null(ig_ty)) && (pipeline_type_kind_ord_at(arena, ig_ty) ==10))) {
                (void)((ti = (ti + 1)));
                continue;
              }
              if ((codegen_emit_indent(out, 2) !=0)) {
                return -(1);
              }
              if (((nlen > 0) && (nlen <=63))) {
                uint8_t tl_init_name[64] = {};
                int32_t tni2 = 0;
                while (((tni2 < nlen) && (tni2 < 64))) {
                  (void)(((tl_init_name)[tni2] = pipeline_module_top_level_let_name_byte_at(module, ti, tni2)));
                  (void)((tni2 = (tni2 + 1)));
                }
                if ((codegen_emit_bytes_from_ptr(out, &((tl_init_name)[0]), nlen) !=0)) {
                  return -(1);
                }
              }
              if ((codegen_emit_bytes_4(out, eq2, 3) !=0)) {
                return -(1);
              }
              if ((!(ast_ref_is_null(pipeline_module_top_level_let_init_ref(module, ti))) && (codegen_emit_expr(arena, out, pipeline_module_top_level_let_init_ref(module, ti), ctx) !=0))) {
                return -(1);
              }
              if ((codegen_emit_bytes_3(out, sc2, 2) !=0)) {
                return -(1);
              }
              (void)((ti = (ti + 1)));
            }
            int32_t dep_i = 0;
            int32_t ndep = 0;
            if (((module->main_func_index) >=0)) {
              (void)((ndep = pipeline_dep_ctx_ndep(ctx)));
            }
            while ((dep_i < ndep)) {
              uint8_t lo_path[64] = {};
              int32_t lo_plen = codegen_dep_import_path_len_at(ctx, dep_i, &((lo_path)[0]));
              if (((lo_plen > 0) && (pipeline_codegen_std_dep_link_only(&((lo_path)[0])) !=0))) {
                (void)((dep_i = (dep_i + 1)));
                continue;
              }
              struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, dep_i);
              if ((dep_mod !=((struct ast_Module *)(0)))) {
                struct ast_ASTArena * dep_arena = pipeline_dep_ctx_arena_at(ctx, dep_i);
                int32_t dti = 0;
                while ((dti < (dep_mod->num_top_level_lets))) {
                  if ((pipeline_module_top_level_let_is_const(dep_mod, dti) ==0)) {
                    int32_t dig_ty = pipeline_module_top_level_let_type_ref(dep_mod, dti);
                    if ((((dep_arena !=((struct ast_ASTArena *)(0))) && !(ast_ref_is_null(dig_ty))) && (pipeline_type_kind_ord_at(dep_arena, dig_ty) ==10))) {
                      (void)((dti = (dti + 1)));
                      continue;
                    }
                    if ((codegen_emit_indent(out, 2) !=0)) {
                      return -(1);
                    }
                    int32_t dnlen = pipeline_module_top_level_let_name_len(dep_mod, dti);
                    if (((dnlen > 0) && (dnlen <=63))) {
                      uint8_t dtl_name[64] = {};
                      int32_t dtni = 0;
                      while (((dtni < dnlen) && (dtni < 64))) {
                        (void)(((dtl_name)[dtni] = pipeline_module_top_level_let_name_byte_at(dep_mod, dti, dtni)));
                        (void)((dtni = (dtni + 1)));
                      }
                      if ((codegen_emit_bytes_from_ptr(out, &((dtl_name)[0]), dnlen) !=0)) {
                        return -(1);
                      }
                    }
                    uint8_t deq[4] = {32, 61, 32, 0};
                    if ((codegen_emit_bytes_4(out, deq, 3) !=0)) {
                      return -(1);
                    }
                    if ((!(ast_ref_is_null(pipeline_module_top_level_let_init_ref(dep_mod, dti))) && (codegen_emit_expr(dep_arena, out, pipeline_module_top_level_let_init_ref(dep_mod, dti), ctx) !=0))) {
                      return -(1);
                    }
                    uint8_t dsc[3] = {59, 10, 0};
                    if ((codegen_emit_bytes_3(out, dsc, 2) !=0)) {
                      return -(1);
                    }
                  }
                  (void)((dti = (dti + 1)));
                }
              }
              (void)((dep_i = (dep_i + 1)));
            }
            uint8_t close_brace[3] = {125, 10, 0};
            if ((codegen_emit_bytes_3(out, close_brace, 2) !=0)) {
              return -(1);
            }
          }
        }
      }
      (void)(codegen_copy_func_name64_from_module(module, i, &((skip_name)[0])));
      if ((pipeline_module_func_num_generic_params_at(module, i) > 0)) {
        int32_t mono_rc = codegen_try_emit_generic_identity_mono(arena, out, module, i, &((prefix_buf)[0]), prefix_len, ctx);
        if ((mono_rc < 0)) {
          return -(1);
        }
        (void)((i = (i + 1)));
        continue;
      }
      if ((pipeline_module_func_is_extern_at(module, i) !=0)) {
        if ((codegen_emit_func_extern_declaration(arena, out, module, i, &((prefix_buf)[0]), prefix_len, ctx) !=0)) {
          return -(1);
        }
        (void)((i = (i + 1)));
        continue;
      }
      if (((ctx !=((struct ast_PipelineDepCtx *)(0))) && ((ctx->use_asm_backend) !=0))) {
        (void)((asm_backend = 1));
      }
      (void)((skip = codegen_should_skip_emit_func_by_name(&((skip_name)[0]), skip_nl)));
      if (((skip ==0) && (asm_backend ==0))) {
        int32_t is_prelinked_dep = 0;
        if (((dep_index >=0) && (dep_path_prefix_len >=10))) {
          if ((((((((((((dep_path_prefix)[0] ==115) && ((dep_path_prefix)[1] ==116)) && ((dep_path_prefix)[2] ==100)) && (((dep_path_prefix)[3] ==46) || ((dep_path_prefix)[3] ==47))) && ((dep_path_prefix)[4] ==115)) && ((dep_path_prefix)[5] ==116)) && ((dep_path_prefix)[6] ==114)) && ((dep_path_prefix)[7] ==105)) && ((dep_path_prefix)[8] ==110)) && ((dep_path_prefix)[9] ==103))) {
            (void)((is_prelinked_dep = 1));
          }
        }
        if ((((is_prelinked_dep ==0) && (dep_index >=0)) && (dep_path_prefix_len >=9))) {
          if (((((((((((dep_path_prefix)[0] ==115) && ((dep_path_prefix)[1] ==116)) && ((dep_path_prefix)[2] ==100)) && (((dep_path_prefix)[3] ==46) || ((dep_path_prefix)[3] ==47))) && ((dep_path_prefix)[4] ==101)) && ((dep_path_prefix)[5] ==114)) && ((dep_path_prefix)[6] ==114)) && ((dep_path_prefix)[7] ==111)) && ((dep_path_prefix)[8] ==114))) {
            (void)((is_prelinked_dep = 1));
          }
        }
        if ((((is_prelinked_dep ==0) && (dep_index >=0)) && (dep_path_prefix_len >=11))) {
          if (((((((((((((dep_path_prefix)[0] ==115) && ((dep_path_prefix)[1] ==116)) && ((dep_path_prefix)[2] ==100)) && (((dep_path_prefix)[3] ==46) || ((dep_path_prefix)[3] ==47))) && ((dep_path_prefix)[4] ==99)) && ((dep_path_prefix)[5] ==111)) && ((dep_path_prefix)[6] ==110)) && ((dep_path_prefix)[7] ==116)) && ((dep_path_prefix)[8] ==101)) && ((dep_path_prefix)[9] ==120)) && ((dep_path_prefix)[10] ==116))) {
            (void)((is_prelinked_dep = 1));
          }
        }
        if (((((((((((((((is_prelinked_dep ==0) && (prefix_len >=11)) && ((prefix_buf)[0] ==115)) && ((prefix_buf)[1] ==116)) && ((prefix_buf)[2] ==100)) && ((prefix_buf)[3] ==95)) && ((prefix_buf)[4] ==115)) && ((prefix_buf)[5] ==116)) && ((prefix_buf)[6] ==114)) && ((prefix_buf)[7] ==105)) && ((prefix_buf)[8] ==110)) && ((prefix_buf)[9] ==103)) && ((prefix_buf)[10] ==95)) && (dep_index >=0))) {
          (void)((is_prelinked_dep = 1));
        }
        if ((((((((((((((is_prelinked_dep ==0) && (prefix_len >=10)) && ((prefix_buf)[0] ==115)) && ((prefix_buf)[1] ==116)) && ((prefix_buf)[2] ==100)) && ((prefix_buf)[3] ==95)) && ((prefix_buf)[4] ==101)) && ((prefix_buf)[5] ==114)) && ((prefix_buf)[6] ==114)) && ((prefix_buf)[7] ==111)) && ((prefix_buf)[8] ==114)) && ((prefix_buf)[9] ==95)) && (dep_index >=0))) {
          (void)((is_prelinked_dep = 1));
        }
        if ((((((((((((((((is_prelinked_dep ==0) && (prefix_len >=12)) && ((prefix_buf)[0] ==115)) && ((prefix_buf)[1] ==116)) && ((prefix_buf)[2] ==100)) && ((prefix_buf)[3] ==95)) && ((prefix_buf)[4] ==99)) && ((prefix_buf)[5] ==111)) && ((prefix_buf)[6] ==110)) && ((prefix_buf)[7] ==116)) && ((prefix_buf)[8] ==101)) && ((prefix_buf)[9] ==120)) && ((prefix_buf)[10] ==116)) && ((prefix_buf)[11] ==95)) && (dep_index >=0))) {
          (void)((is_prelinked_dep = 1));
        }
        if ((is_prelinked_dep !=0)) {
          (void)((skip = 1));
        }
      }
      if ((((skip !=0) && (prefix_len > 0)) && ((skip_nl ==11) || (skip_nl ==10)))) {
        (void)((skip = 0));
      }
      if ((((skip ==0) && (prefix_len ==0)) && (asm_backend ==0))) {
        (void)((skip = codegen_should_skip_emit_func_core_read_ptr(&((skip_name)[0]), skip_nl)));
      }
      if ((((skip ==0) && (prefix_len > 0)) && (asm_backend ==0))) {
        (void)((skip = codegen_should_skip_emit_func(((uint8_t *)(0)), &((prefix_buf)[0]), prefix_len, &((skip_name)[0]), skip_nl)));
      }
      if ((((((skip ==0) && (dep_index >=0)) && (ctx !=((struct ast_PipelineDepCtx *)(0)))) && (dep_path_prefix_len > 0)) && (asm_backend ==0))) {
        (void)((skip = codegen_should_skip_emit_func(&((dep_path_prefix)[0]), ((uint8_t *)(0)), 0, &((skip_name)[0]), skip_nl)));
      }
      if (((skip ==0) && (asm_backend ==0))) {
        uint8_t * skip_dep = ((uint8_t *)(0));
        if ((((dep_index >=0) && (ctx !=((struct ast_PipelineDepCtx *)(0)))) && (dep_path_prefix_len > 0))) {
          (void)((skip_dep = &((dep_path_prefix)[0])));
        }
        if ((skip_dep ==((uint8_t *)(0)))) {
          (void)((skip_dep = driver_get_current_dep_path_for_codegen()));
        }
        (void)((skip = codegen_should_skip_emit_func(skip_dep, ((uint8_t *)(0)), 0, &((skip_name)[0]), skip_nl)));
      }
      if ((skip !=0)) {
        (void)((i = (i + 1)));
        continue;
      }
      if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
        (void)((saved_func_idx = (ctx->current_func_index)));
        (void)(((ctx->current_func_index) = i));
      }
      if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
        int32_t px = 0;
        (void)(((ctx->current_codegen_module) = module));
        (void)(((ctx->current_codegen_arena) = arena));
        (void)(((ctx->current_codegen_dep_index) = dep_index));
        while (((px < prefix_len) && (px < 63))) {
          (void)((((ctx->current_codegen_prefix_mirror))[px] = (prefix_buf)[px]));
          (void)((px = (px + 1)));
        }
        (void)((((ctx->current_codegen_prefix_mirror))[px] = ((uint8_t)(0))));
        (void)(((ctx->current_codegen_prefix_len) = px));
      }
      if ((codegen_emit_func(arena, out, module, i, is_entry, &((prefix_buf)[0]), prefix_len, ctx, call_init_globals) !=0)) {
        (void)(driver_diagnostic_codegen_emit_func_fail(module, i));
        if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
          (void)(((ctx->current_func_index) = saved_func_idx));
        }
        return -(1);
      }
      if ((ctx !=((struct ast_PipelineDepCtx *)(0)))) {
        (void)(((ctx->current_func_index) = saved_func_idx));
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t codegen_should_skip_emit_func_by_name(uint8_t * name, int32_t name_len) {
  {
    uint8_t asm_seed_mega[25] = {97, 115, 109, 95, 99, 111, 100, 101, 103, 101, 110, 95, 97, 115, 116, 95, 115, 101, 101, 100, 95, 109, 101, 103, 97};
    uint8_t asm_to_elf_seed_mega[32] = {97, 115, 109, 95, 99, 111, 100, 101, 103, 101, 110, 95, 97, 115, 116, 95, 116, 111, 95, 101, 108, 102, 95, 115, 101, 101, 100, 95, 109, 101, 103, 97};
    if ((name ==((uint8_t *)(0)))) {
      return 0;
    }
    if ((pipeline_codegen_emit_seed_mega_enabled() ==0)) {
      if (((name_len ==25) && (codegen_name_bytes_prefix_eq(name, name_len, &((asm_seed_mega)[0]), 25) !=0))) {
        return 1;
      }
      if (((name_len ==32) && (codegen_name_bytes_prefix_eq(name, name_len, &((asm_to_elf_seed_mega)[0]), 32) !=0))) {
        return 1;
      }
    }
    return 0;
  }
  return 0;
}
int32_t codegen_is_submit_batch_buf_call(uint8_t * name, int32_t name_len) {
  uint8_t rd_batch[21] = {115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102};
  uint8_t wr_batch[22] = {115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102};
  if ((name ==((uint8_t *)(0)))) {
    return 0;
  }
  if (((name_len ==21) && (codegen_name_bytes_prefix_eq(name, name_len, &((rd_batch)[0]), 21) !=0))) {
    return 1;
  }
  if (((name_len ==22) && (codegen_name_bytes_prefix_eq(name, name_len, &((wr_batch)[0]), 22) !=0))) {
    return 1;
  }
  return 0;
}
int32_t codegen_force_param_i32(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index) {
  return 0;
}
int32_t codegen_should_skip_emit_func_core_read_ptr(uint8_t * name, int32_t name_len) {
  /* PLATFORM: SHARED — skip only read_ptr* / async with preamble weak.
   * Do NOT skip shux_io_register*: product C does not hard-link runtime_asm_io_stubs;
   * co-emit core → backend is authority (run-io-driver UNDEF _shux_io_register). */
  uint8_t shux_rpl20[20] = {115, 104, 117, 120, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110};
  uint8_t shux_rp16[16] = {115, 104, 117, 120, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114};
  if ((name ==((uint8_t *)(0)))) {
    return 0;
  }
  if (((name_len >=20) && (codegen_name_bytes_prefix_eq(name, name_len, &((shux_rpl20)[0]), 20) !=0))) {
    return 1;
  }
  if (((name_len ==16) && (codegen_name_bytes_prefix_eq(name, name_len, &((shux_rp16)[0]), 16) !=0))) {
    return 1;
  }
  uint8_t shux_rpb24[24] = {115, 104, 117, 120, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 98, 97, 99, 107, 101, 110, 100};
  if ((((name_len ==24) || (name_len ==25)) && (codegen_name_bytes_prefix_eq(name, name_len, &((shux_rpb24)[0]), 24) !=0))) {
    return 1;
  }
  uint8_t shux_sra25[25] = {115, 104, 117, 120, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 97, 115, 121, 110, 99};
  if ((((name_len ==25) || (name_len ==26)) && (codegen_name_bytes_prefix_eq(name, name_len, &((shux_sra25)[0]), 25) !=0))) {
    return 1;
  }
  return 0;
}
int32_t codegen_std_io_fixed_fd_emit_impl(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len) {
  uint8_t pre7[7] = {115, 116, 100, 95, 105, 111, 95};
  uint8_t rd13[13] = {114, 101, 97, 100, 95, 102, 105, 120, 101, 100, 95, 102, 100};
  uint8_t wr14[14] = {119, 114, 105, 116, 101, 95, 102, 105, 120, 101, 100, 95, 102, 100};
  if (((((prefix ==((uint8_t *)(0))) || (name ==((uint8_t *)(0)))) || (prefix_len < 7)) || (name_len <=0))) {
    return 0;
  }
  if ((codegen_name_bytes_prefix_eq(prefix, prefix_len, &((pre7)[0]), 7) ==0)) {
    return 0;
  }
  if (((name_len >=13) && (codegen_name_bytes_prefix_eq(name, name_len, &((rd13)[0]), 13) !=0))) {
    return 1;
  }
  if (((name_len >=14) && (codegen_name_bytes_prefix_eq(name, name_len, &((wr14)[0]), 14) !=0))) {
    return 1;
  }
  return 0;
}
