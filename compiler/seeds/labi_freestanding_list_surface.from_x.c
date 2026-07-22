#include <stdint.h>
#if !defined(__STDC_VERSION__) || __STDC_VERSION__ < 201112L
#error "Generated code needs C11. Compile with -std=gnu11 or -std=c11."
#endif
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#if !defined(_WIN32) && !defined(_WIN64)
#include <unistd.h>
#else
#include <io.h>
#include <sys/types.h>
#endif
#if !defined(_WIN32) && !defined(_WIN64)
#include <sys/uio.h>
#endif
#if !defined(_WIN32) && !defined(_WIN64)
#include <poll.h>
#endif
#ifndef O_RDONLY
#define O_RDONLY 0
#endif
#ifndef O_WRONLY
#define O_WRONLY 1
#endif
#ifndef O_RDWR
#define O_RDWR 2
#endif
#if defined(__APPLE__)
#ifndef O_CREAT
#define O_CREAT 512
#endif
#ifndef O_TRUNC
#define O_TRUNC 1024
#endif
#ifndef O_APPEND
#define O_APPEND 8
#endif
#ifndef F_NOCACHE
#define F_NOCACHE 48
#endif
#else
#ifndef O_CREAT
#define O_CREAT 64
#endif
#ifndef O_TRUNC
#define O_TRUNC 512
#endif
#ifndef O_APPEND
#define O_APPEND 1024
#endif
#endif
#ifndef PROT_READ
#define PROT_READ 1
#endif
#ifndef PROT_WRITE
#define PROT_WRITE 2
#endif
#ifndef MAP_SHARED
#define MAP_SHARED 1
#endif
#ifndef MAP_PRIVATE
#define MAP_PRIVATE 2
#endif
#ifndef MAP_FAILED
#define MAP_FAILED ((int64_t)-1)
#endif
#ifndef S_IFMT
#define S_IFMT 61440u
#endif
#ifndef S_IFDIR
#define S_IFDIR 16384u
#endif
#ifndef S_IFREG
#define S_IFREG 32768u
#endif
#ifndef FS_IOV_BUF_MAX
#define FS_IOV_BUF_MAX 16
#endif
#ifndef DIRENT_D_NAME_OFF
#if defined(__APPLE__)
#define DIRENT_D_NAME_OFF ((size_t)21)
#else
#define DIRENT_D_NAME_OFF ((size_t)19)
#endif
#endif
#if !defined(_WIN32) && !defined(_WIN64)
#if defined(__APPLE__)
extern int *__error(void);
#else
extern int *__errno_location(void);
#endif
extern int32_t fcntl(int32_t fd, int32_t cmd, int32_t arg);
extern int32_t madvise(uint8_t *addr, size_t len, int32_t advice);
extern int32_t open(uint8_t *path, int32_t flags, int32_t mode);
static inline int32_t fs_libc_open(uint8_t *path, int32_t flags, int32_t mode) {
  return open(path, flags, mode);
}
#define fs_note_last_error_posix std_fs_posix_fs_note_last_error_posix
#endif
static inline ssize_t shux_sys_read(int32_t fd, uint8_t *buf, size_t count) {
  return read((int)fd, (void *)buf, count);
}
static inline ssize_t shux_sys_write(int32_t fd, uint8_t *buf, size_t count) {
  return write((int)fd, (const void *)buf, count);
}
#if !defined(_WIN32) && !defined(_WIN64)
static inline ssize_t shux_sys_readv(int32_t fd, uint8_t *iov, int32_t iovcnt) {
  return readv((int)fd, (const struct iovec *)(const void *)iov, (int)iovcnt);
}
#endif
#if !defined(_WIN32) && !defined(_WIN64)
static inline ssize_t shux_sys_writev(int32_t fd, uint8_t *iov, int32_t iovcnt) {
  return writev((int)fd, (const struct iovec *)(const void *)iov, (int)iovcnt);
}
#endif
#if !defined(_WIN32) && !defined(_WIN64)
static inline int32_t shux_sys_poll(uint8_t *fds, int32_t nfds, int32_t timeout) {
  return (int32_t)poll((struct pollfd *)(void *)fds, (nfds_t)nfds, (int)timeout);
}
#endif
#if !defined(_WIN32) && !defined(_WIN64)
static inline ssize_t shux_sys_pread(int32_t fd, uint8_t *buf, size_t count, int64_t offset) {
  return pread((int)fd, (void *)buf, count, (off_t)offset);
}
#endif
#if !defined(_WIN32) && !defined(_WIN64)
static inline ssize_t shux_sys_pwrite(int32_t fd, uint8_t *buf, size_t count, int64_t offset) {
  return pwrite((int)fd, (const void *)buf, count, (off_t)offset);
}
#endif
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
typedef float f32x4_t __attribute__((vector_size(16)));
typedef float f32x8_t __attribute__((vector_size(32)));
typedef float f32x16_t __attribute__((vector_size(64)));
#else
typedef struct { int32_t e[4]; } i32x4_t;
typedef struct { int32_t e[8]; } i32x8_t;
typedef struct { int32_t e[16]; } i32x16_t;
typedef struct { uint32_t e[4]; } u32x4_t;
typedef struct { uint32_t e[8]; } u32x8_t;
typedef struct { uint32_t e[16]; } u32x16_t;
typedef struct { float e[4]; } f32x4_t;
typedef struct { float e[8]; } f32x8_t;
typedef struct { float e[16]; } f32x16_t;
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
#ifndef __cplusplus
/* 仅补 co-emit 未定义的符号；勿桩 submit_read / submit_*_batch / submit_write（core 强定义）。 */
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
__attribute__((weak)) int32_t process_shux_argc_get(void) { return 0; }
__attribute__((weak)) uint8_t *process_shux_argv_get(int32_t i) { (void)i; return (uint8_t *)0; }
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
extern uint8_t * labi_fs_env_freestanding(void);
extern int32_t labi_fs_io_sym_count(void);
extern uint8_t * labi_fs_io_sym_at(int32_t i);
extern uint8_t * labi_fs_panic_sym(void);
extern int32_t labi_fs_ensure_catalog_count(void);
extern int32_t labi_fs_ensure_catalog_step_at(int32_t i, size_t * stem_out, size_t * out_base_out, size_t * src_rel_out);
extern uint8_t * labi_fs_ensure_out_base(int32_t i);
extern uint8_t * labi_fs_ensure_src_rel(int32_t i);
extern uint8_t * labi_fs_ensure_stem(int32_t i);
extern uint8_t * labi_fs_crt0_out_base(void);
extern uint8_t * labi_fs_crt0_src_rel(void);
extern uint8_t * labi_fs_io_out_base(void);
extern uint8_t * labi_fs_io_src_rel(void);
extern int32_t labi_fs_heap_c_needle_count(void);
extern uint8_t * labi_fs_heap_c_needle_at(int32_t i);
extern int32_t labi_fs_heap_o_sym_count(void);
extern uint8_t * labi_fs_heap_o_sym_at(int32_t i);
extern int32_t labi_fs_memcpy_face_sym_count(void);
extern uint8_t * labi_fs_memcpy_face_sym_at(int32_t i);
extern int32_t link_abi_generated_c_needs_libc_heap(uint8_t * c_path);
extern int32_t link_abi_user_o_needs_libc_heap(uint8_t * user_o);
extern int32_t link_abi_user_o_needs_freestanding_nostdlib_face(uint8_t * user_o);
extern int32_t labi_fs_gen_fs_needle_count(void);
extern uint8_t * labi_fs_gen_fs_needle_at(int32_t i);
extern int32_t labi_fs_gen_random_needle_count(void);
extern uint8_t * labi_fs_gen_random_needle_at(int32_t i);
extern int32_t labi_fs_gen_time_needle_count(void);
extern uint8_t * labi_fs_gen_time_needle_at(int32_t i);
extern int32_t labi_fs_gen_runtime_needle_count(void);
extern uint8_t * labi_fs_gen_runtime_needle_at(int32_t i);
extern int32_t link_abi_generated_c_needs_fs(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_random(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_time(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_runtime(uint8_t * c_path);
extern int32_t labi_fs_gen_zlib_needle_count(void);
extern uint8_t * labi_fs_gen_zlib_needle_at(int32_t i);
extern int32_t labi_fs_gen_zstd_needle_count(void);
extern uint8_t * labi_fs_gen_zstd_needle_at(int32_t i);
extern int32_t labi_fs_gen_brotli_needle_count(void);
extern uint8_t * labi_fs_gen_brotli_needle_at(int32_t i);
extern int32_t link_abi_generated_c_needs_zlib(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_zstd(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_brotli(uint8_t * c_path);
extern int32_t labi_fs_gen_core_slice_needle_count(void);
extern uint8_t * labi_fs_gen_core_slice_needle_at(int32_t i);
extern int32_t labi_fs_gen_db_kv_needle_count(void);
extern uint8_t * labi_fs_gen_db_kv_needle_at(int32_t i);
extern int32_t labi_fs_gen_db_arrow_needle_count(void);
extern uint8_t * labi_fs_gen_db_arrow_needle_at(int32_t i);
extern int32_t link_abi_generated_c_needs_core_slice(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_db_kv(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_db_arrow(uint8_t * c_path);
extern int32_t labi_fs_gen_provides_core_mem_needle_count(void);
extern uint8_t * labi_fs_gen_provides_core_mem_needle_at(int32_t i);
extern int32_t labi_fs_gen_provides_std_heap_needle_count(void);
extern uint8_t * labi_fs_gen_provides_std_heap_needle_at(int32_t i);
extern int32_t link_abi_generated_c_provides_core_mem(uint8_t * c_path);
extern int32_t link_abi_generated_c_provides_std_heap(uint8_t * c_path);
extern int32_t labi_fs_gen_win32_needle_count(void);
extern uint8_t * labi_fs_gen_win32_needle_at(int32_t i);
extern int32_t labi_fs_gen_win32_wsa_needle_count(void);
extern uint8_t * labi_fs_gen_win32_wsa_needle_at(int32_t i);
extern int32_t link_abi_generated_c_needs_win32(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_win32_wsa(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_core_builtin(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_core_mem(uint8_t * c_path);
extern int32_t labi_fs_gen_async_scheduler_needle_count(void);
extern uint8_t * labi_fs_gen_async_scheduler_needle_at(int32_t i);
extern int32_t shux_generated_c_needs_async_scheduler(uint8_t * c_path);
uint8_t * labi_fs_env_freestanding(void) {
  uint8_t * p = ((uint8_t *)"\x53\x48\x55\x58\x5f\x46\x52\x45\x45\x53\x54\x41\x4e\x44\x49\x4e\x47");
  return p;
}
int32_t labi_fs_io_sym_count(void) {
  return 13;
}
uint8_t * labi_fs_io_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x77\x72\x69\x74\x65");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x72\x65\x61\x64");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x63\x6c\x6f\x73\x65");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x65\x78\x69\x74");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x6f\x70\x65\x6e");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x6f\x70\x65\x6e\x61\x74");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x6d\x6d\x61\x70");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x6d\x75\x6e\x6d\x61\x70");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x73\x6f\x63\x6b\x65\x74");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x63\x6f\x6e\x6e\x65\x63\x74");
    return p;
  }
  if ((i ==10)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x62\x69\x6e\x64");
    return p;
  }
  if ((i ==11)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x6c\x69\x73\x74\x65\x6e");
    return p;
  }
  if ((i ==12)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x61\x63\x63\x65\x70\x74");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_fs_panic_sym(void) {
  uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x70\x61\x6e\x69\x63\x5f");
  return p;
}
int32_t labi_fs_ensure_catalog_count(void) {
  return 2;
}
int32_t labi_fs_ensure_catalog_step_at(int32_t i, size_t * stem_out, size_t * out_base_out, size_t * src_rel_out) {
  if ((i < 0)) {
    return 0;
  }
  if ((i >=2)) {
    return 0;
  }
  if ((i ==0)) {
    if ((stem_out !=0)) {
      uint8_t * p = ((uint8_t *)"\x63\x72\x74\x30\x5f\x75\x73\x65\x72");
      (void)(((stem_out)[0] = ((size_t)(p))));
    }
    if ((out_base_out !=0)) {
      uint8_t * p = ((uint8_t *)"\x63\x72\x74\x30\x5f\x75\x73\x65\x72\x2e\x6f");
      (void)(((out_base_out)[0] = ((size_t)(p))));
    }
    if ((src_rel_out !=0)) {
      uint8_t * p = ((uint8_t *)"\x73\x72\x63\x2f\x61\x73\x6d\x2f\x63\x72\x74\x30\x5f\x75\x73\x65\x72\x5f\x78\x38\x36\x5f\x36\x34\x2e\x73");
      (void)(((src_rel_out)[0] = ((size_t)(p))));
    }
    return 1;
  }
  if ((i ==1)) {
    if ((stem_out !=0)) {
      uint8_t * p = ((uint8_t *)"\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f");
      (void)(((stem_out)[0] = ((size_t)(p))));
    }
    if ((out_base_out !=0)) {
      uint8_t * p = ((uint8_t *)"\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f\x2e\x6f");
      (void)(((out_base_out)[0] = ((size_t)(p))));
    }
    if ((src_rel_out !=0)) {
      uint8_t * p = ((uint8_t *)"\x73\x72\x63\x2f\x61\x73\x6d\x2f\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f\x5f\x78\x38\x36\x5f\x36\x34\x2e\x73");
      (void)(((src_rel_out)[0] = ((size_t)(p))));
    }
    return 1;
  }
  return 0;
}
uint8_t * labi_fs_ensure_out_base(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x63\x72\x74\x30\x5f\x75\x73\x65\x72\x2e\x6f");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f\x2e\x6f");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_fs_ensure_src_rel(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x72\x63\x2f\x61\x73\x6d\x2f\x63\x72\x74\x30\x5f\x75\x73\x65\x72\x5f\x78\x38\x36\x5f\x36\x34\x2e\x73");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x72\x63\x2f\x61\x73\x6d\x2f\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f\x5f\x78\x38\x36\x5f\x36\x34\x2e\x73");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_fs_ensure_stem(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x63\x72\x74\x30\x5f\x75\x73\x65\x72");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_fs_crt0_out_base(void) {
  uint8_t * p = ((uint8_t *)"\x63\x72\x74\x30\x5f\x75\x73\x65\x72\x2e\x6f");
  return p;
}
uint8_t * labi_fs_crt0_src_rel(void) {
  uint8_t * p = ((uint8_t *)"\x73\x72\x63\x2f\x61\x73\x6d\x2f\x63\x72\x74\x30\x5f\x75\x73\x65\x72\x5f\x78\x38\x36\x5f\x36\x34\x2e\x73");
  return p;
}
uint8_t * labi_fs_io_out_base(void) {
  uint8_t * p = ((uint8_t *)"\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f\x2e\x6f");
  return p;
}
uint8_t * labi_fs_io_src_rel(void) {
  uint8_t * p = ((uint8_t *)"\x73\x72\x63\x2f\x61\x73\x6d\x2f\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f\x5f\x78\x38\x36\x5f\x36\x34\x2e\x73");
  return p;
}
extern int32_t link_abi_generated_c_contains_substr(uint8_t * c_path, uint8_t * needle);
extern int32_t shux_link_obj_needs_undef_sym(uint8_t * user_o, uint8_t * sym);
int32_t labi_fs_heap_c_needle_count(void) {
  return 9;
}
uint8_t * labi_fs_heap_c_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x6d\x61\x6c\x6c\x6f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x63\x61\x6c\x6c\x6f\x63");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x72\x65\x61\x6c\x6c\x6f\x63");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x70\x6f\x73\x69\x78\x5f\x6d\x65\x6d\x61\x6c\x69\x67\x6e");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x63");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x63");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x68\x65\x61\x70\x5f\x72\x65\x61\x6c\x6c\x6f\x63\x5f\x63");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x7a\x65\x72\x6f\x65\x64\x5f\x63");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x67\x65\x74\x65\x6e\x76");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fs_heap_o_sym_count(void) {
  return 6;
}
uint8_t * labi_fs_heap_o_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x6d\x61\x6c\x6c\x6f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x63\x61\x6c\x6c\x6f\x63");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x72\x65\x61\x6c\x6c\x6f\x63");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x66\x72\x65\x65");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x70\x6f\x73\x69\x78\x5f\x6d\x65\x6d\x61\x6c\x69\x67\x6e");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x67\x65\x74\x65\x6e\x76");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fs_memcpy_face_sym_count(void) {
  return 3;
}
uint8_t * labi_fs_memcpy_face_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x6d\x65\x6d\x63\x70\x79");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x6d\x65\x6d\x63\x6d\x70");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x6d\x65\x6d\x73\x65\x74");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_generated_c_needs_libc_heap(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_heap_c_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_heap_c_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_user_o_needs_libc_heap(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_heap_o_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_fs_heap_o_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_user_o_needs_freestanding_nostdlib_face(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  if ((link_abi_user_o_needs_libc_heap(user_o) !=0)) {
    return 1;
  }
  int32_t n = labi_fs_memcpy_face_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_fs_memcpy_face_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_fs_gen_fs_needle_count(void) {
  return 5;
}
uint8_t * labi_fs_gen_fs_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x66\x73\x5f\x6f\x70\x65\x6e\x5f\x72\x65\x61\x64\x5f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x66\x73\x5f\x6c\x61\x73\x74\x5f\x65\x72\x72\x6f\x72\x5f\x63");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x66\x73\x5f\x63\x6c\x6f\x73\x65\x5f\x63");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x66\x73\x5f\x72\x65\x61\x64\x5f\x63");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x66\x73\x5f\x77\x72\x69\x74\x65\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fs_gen_random_needle_count(void) {
  return 3;
}
uint8_t * labi_fs_gen_random_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x72\x61\x6e\x64\x6f\x6d\x5f\x72\x6e\x67\x5f\x73\x6d\x6f\x6b\x65\x5f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x72\x61\x6e\x64\x6f\x6d\x5f\x66\x69\x6c\x6c\x5f\x62\x79\x74\x65\x73\x5f\x63");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x72\x61\x6e\x64\x6f\x6d\x5f\x75\x36\x34\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fs_gen_time_needle_count(void) {
  return 10;
}
uint8_t * labi_fs_gen_time_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x6d\x6f\x6e\x6f\x74\x6f\x6e\x69\x63\x5f\x6e\x73");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x73\x6c\x65\x65\x70\x5f\x6d\x73");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x64\x75\x72\x61\x74\x69\x6f\x6e\x5f\x6e\x73");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x77\x61\x6c\x6c\x5f\x6e\x73");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x66\x6f\x72\x6d\x61\x74\x5f\x74\x69\x6d\x65\x7a\x6f\x6e\x65\x5f\x73\x6d\x6f\x6b\x65");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x6d\x6f\x6e\x6f\x74\x6f\x6e\x69\x63\x5f\x6e\x73\x5f\x63");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x73\x6c\x65\x65\x70\x5f\x6d\x73\x5f\x63");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x64\x75\x72\x61\x74\x69\x6f\x6e\x5f\x6e\x73\x5f\x63");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x77\x61\x6c\x6c\x5f\x6e\x73\x5f\x63");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x66\x6f\x72\x6d\x61\x74\x5f\x74\x69\x6d\x65\x7a\x6f\x6e\x65\x5f\x73\x6d\x6f\x6b\x65\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fs_gen_runtime_needle_count(void) {
  return 3;
}
uint8_t * labi_fs_gen_runtime_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x63\x72\x61\x73\x68\x5f\x65\x76\x69\x64\x65\x6e\x63\x65\x5f\x63\x6f\x6c\x6c\x65\x63\x74\x5f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x61\x6e\x69\x63");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x62\x6f\x72\x74");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_generated_c_needs_fs(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_fs_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_fs_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_generated_c_needs_random(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_random_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_random_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_generated_c_needs_time(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_time_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_time_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_generated_c_needs_runtime(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_runtime_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_runtime_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_fs_gen_zlib_needle_count(void) {
  return 7;
}
uint8_t * labi_fs_gen_zlib_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x5f\x63\x6f\x6d\x70\x72\x65\x73\x73\x32");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x5f\x64\x65\x66\x6c\x61\x74\x65");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x5f\x69\x6e\x66\x6c\x61\x74\x65");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x5f\x75\x6e\x63\x6f\x6d\x70\x72\x65\x73\x73");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x6d\x70\x72\x65\x73\x73\x32");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x64\x65\x66\x6c\x61\x74\x65\x49\x6e\x69\x74");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x69\x6e\x66\x6c\x61\x74\x65\x49\x6e\x69\x74");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fs_gen_zstd_needle_count(void) {
  return 5;
}
uint8_t * labi_fs_gen_zstd_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x5a\x53\x54\x44\x5f\x63\x6f\x6d\x70\x72\x65\x73\x73");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x5a\x53\x54\x44\x5f\x64\x65\x63\x6f\x6d\x70\x72\x65\x73\x73");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x5a\x53\x54\x44\x5f\x63\x72\x65\x61\x74\x65");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x5a\x53\x54\x44\x5f\x66\x72\x65\x65");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x5a\x53\x54\x44\x5f\x69\x73\x45\x72\x72\x6f\x72");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fs_gen_brotli_needle_count(void) {
  return 2;
}
uint8_t * labi_fs_gen_brotli_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x42\x72\x6f\x74\x6c\x69\x45\x6e\x63\x6f\x64\x65\x72");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x42\x72\x6f\x74\x6c\x69\x44\x65\x63\x6f\x64\x65\x72");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_generated_c_needs_zlib(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_zlib_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_zlib_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_generated_c_needs_zstd(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_zstd_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_zstd_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_generated_c_needs_brotli(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_brotli_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_brotli_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_fs_gen_core_slice_needle_count(void) {
  return 6;
}
uint8_t * labi_fs_gen_core_slice_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x69\x33\x32\x5f\x66\x72\x6f\x6d\x5f\x70\x74\x72\x5f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x75\x62\x73\x6c\x69\x63\x65\x5f\x69\x33\x32\x5f\x63");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x75\x38\x5f\x66\x72\x6f\x6d\x5f\x70\x74\x72\x5f\x63");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x75\x62\x73\x6c\x69\x63\x65\x5f\x75\x38\x5f\x63");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x75\x36\x34\x5f\x66\x72\x6f\x6d\x5f\x70\x74\x72\x5f\x63");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x75\x62\x73\x6c\x69\x63\x65\x5f\x75\x36\x34\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fs_gen_db_kv_needle_count(void) {
  return 7;
}
uint8_t * labi_fs_gen_db_kv_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x64\x62\x5f\x6b\x76\x5f\x6f\x70\x65\x6e\x5f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x64\x62\x5f\x6b\x76\x5f\x70\x75\x74\x5f\x63");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x64\x62\x5f\x6b\x76\x5f\x67\x65\x74\x5f\x63");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x64\x62\x5f\x6b\x76\x5f\x61\x70\x70\x65\x6e\x64\x5f\x74\x73\x5f\x63");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x64\x62\x5f\x6b\x76\x5f\x77\x61\x6c\x5f\x66\x6c\x75\x73\x68\x5f\x63");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x64\x62\x5f\x6b\x76\x5f\x63\x6f\x6d\x70\x61\x63\x74\x5f\x63");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x64\x62\x5f\x6b\x76\x5f\x73\x73\x74\x5f\x6c\x65\x76\x65\x6c\x5f\x63\x6f\x75\x6e\x74\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fs_gen_db_arrow_needle_count(void) {
  return 3;
}
uint8_t * labi_fs_gen_db_arrow_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x61\x72\x72\x6f\x77\x5f\x63\x6f\x6c\x75\x6d\x6e\x5f");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x61\x72\x72\x6f\x77\x5f\x62\x61\x74\x63\x68\x5f");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x61\x72\x72\x6f\x77\x5f\x73\x6d\x6f\x6b\x65\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_generated_c_needs_core_slice(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_core_slice_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_core_slice_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_generated_c_needs_db_kv(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_db_kv_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_db_kv_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_generated_c_needs_db_arrow(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_db_arrow_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_db_arrow_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_fs_gen_provides_core_mem_needle_count(void) {
  return 3;
}
uint8_t * labi_fs_gen_provides_core_mem_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x76\x6f\x69\x64\x20\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x6d\x65\x6d\x5f\x63\x6f\x70\x79\x28");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x69\x6e\x74\x33\x32\x5f\x74\x20\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x70\x6c\x61\x63\x65\x68\x6f\x6c\x64\x65\x72\x28\x76\x6f\x69\x64\x29\x20\x7b");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x69\x6e\x74\x33\x32\x5f\x74\x20\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x61\x6c\x69\x67\x6e\x5f\x6f\x66\x5f\x69\x33\x32\x28\x76\x6f\x69\x64\x29\x20\x7b");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fs_gen_provides_std_heap_needle_count(void) {
  return 3;
}
uint8_t * labi_fs_gen_provides_std_heap_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x75\x69\x6e\x74\x38\x5f\x74\x20\x2a\x20\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x63\x28\x73\x69\x7a\x65\x5f\x74\x20\x73\x69\x7a\x65\x29\x20\x7b");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x76\x6f\x69\x64\x20\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x63\x28\x75\x69\x6e\x74\x38\x5f\x74\x20\x2a\x20\x70\x74\x72\x29\x20\x7b");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x63\x28\x73\x69\x7a\x65\x5f\x74\x20\x73\x69\x7a\x65\x29\x20\x7b");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_generated_c_provides_core_mem(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_provides_core_mem_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_provides_core_mem_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_generated_c_provides_std_heap(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_provides_std_heap_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_provides_std_heap_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_fs_gen_win32_needle_count(void) {
  return 9;
}
uint8_t * labi_fs_gen_win32_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x47\x65\x74\x53\x74\x64\x48\x61\x6e\x64\x6c\x65");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x57\x72\x69\x74\x65\x46\x69\x6c\x65");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x43\x72\x65\x61\x74\x65\x46\x69\x6c\x65\x41");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x52\x65\x61\x64\x46\x69\x6c\x65");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x43\x6c\x6f\x73\x65\x48\x61\x6e\x64\x6c\x65");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x45\x78\x69\x74\x50\x72\x6f\x63\x65\x73\x73");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x77\x69\x6e\x33\x32\x5f\x77\x72\x69\x74\x65");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x77\x69\x6e\x33\x32\x5f\x72\x65\x61\x64\x5f\x66\x69\x6c\x65\x5f\x69\x6e\x74\x6f");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x77\x69\x6e\x33\x32\x5f\x65\x78\x69\x74\x5f\x70\x72\x6f\x63\x65\x73\x73");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fs_gen_win32_wsa_needle_count(void) {
  return 3;
}
uint8_t * labi_fs_gen_win32_wsa_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x57\x53\x41\x53\x74\x61\x72\x74\x75\x70");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x57\x53\x41\x43\x6c\x65\x61\x6e\x75\x70");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x77\x69\x6e\x33\x32\x5f\x6e\x65\x74\x5f\x61\x76\x61\x69\x6c\x61\x62\x6c\x65");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_generated_c_needs_win32(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_win32_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_win32_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_generated_c_needs_win32_wsa(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_win32_wsa_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_win32_wsa_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_generated_c_needs_core_builtin(uint8_t * c_path) {
  return 0;
}
int32_t link_abi_generated_c_needs_core_mem(uint8_t * c_path) {
  return 0;
}
int32_t labi_fs_gen_async_scheduler_needle_count(void) {
  return 9;
}
uint8_t * labi_fs_gen_async_scheduler_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x63\x70\x73\x5f\x73\x75\x73\x70\x65\x6e\x64");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x74\x61\x73\x6b\x5f\x73\x75\x62\x6d\x69\x74");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x63\x6f\x6f\x70\x5f\x70\x69\x6e\x67\x70\x6f\x6e\x67\x5f\x6a\x6d\x70");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x63\x6f\x6f\x70\x5f\x70\x69\x6e\x67\x70\x6f\x6e\x67");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x64\x72\x61\x69\x6e\x5f\x75\x6e\x74\x69\x6c\x5f\x69\x64\x6c\x65");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x71\x75\x65\x75\x65\x5f\x72\x65\x73\x65\x74");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x62\x69\x6e\x64\x5f\x63\x6f\x6e\x74\x65\x78\x74\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t shux_generated_c_needs_async_scheduler(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_async_scheduler_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_async_scheduler_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
