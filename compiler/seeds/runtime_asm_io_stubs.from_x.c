/* seeds/runtime_asm_io_stubs.from_x.c — G-02f-20 product TU
 * Product: runtime_asm_io_stubs.o; logic still C until full .x port.
 */
/**
 * runtime_asm_io_stubs.c — seed asm 用户程序链接桩
 *
 * std.io 族 .x 模块在 pipeline/asm_codegen_elf_o 中跳过机器码生成；
 * 本 TU 提供 print_* / write_* / read_ptr 等 C ABI 符号，与 ../std/io/io.o 一并链入用户可执行文件。
 */
#if defined(__linux__)
#define _GNU_SOURCE
#endif
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#if defined(__unix__) || defined(__APPLE__)
#ifndef _WIN32
#include <unistd.h>
#endif
#endif

/**
 * Linux 裸 syscall write(2)；F-03 无 std/io/io.o 时供 nostdlib / gcc 链使用。
 * timeout_ms 在 seed 桩 v1 中忽略（同步写完全部 count 或返回错误）。
 */
#if defined(__linux__) && defined(__x86_64__)
static long seed_io_syscall_write(int fd, const void *buf, unsigned long count) {
  long ret;
  __asm__ volatile("syscall"
                   : "=a"(ret)
                   : "0"(1L), "D"((long)fd), "S"(buf), "d"(count)
                   : "rcx", "r11", "memory");
  return ret;
}

/** Linux x86_64 裸 syscall read(2)。 */
static long seed_io_syscall_read(int fd, void *buf, unsigned long count) {
  long ret;
  __asm__ volatile("syscall"
                   : "=a"(ret)
                   : "0"(0L), "D"((long)fd), "S"(buf), "d"(count)
                   : "rcx", "r11", "memory");
  return ret;
}
#endif

/** F-03：sync.x 机器码不在 io.o；本 TU 提供 io_write/io_read 同步 ABI。 */
ptrdiff_t io_write(int fd, const uint8_t *buf, size_t count, unsigned timeout_ms) {
  long n;
  (void)timeout_ms;
  if (!buf && count > 0)
    return (ptrdiff_t)-1;
#if defined(__linux__) && defined(__x86_64__)
  n = seed_io_syscall_write(fd, buf, (unsigned long)count);
#elif defined(__unix__) || defined(__APPLE__)
  n = (long)write(fd, buf, count);
#else
  n = -1;
#endif
  return (ptrdiff_t)n;
}

/** 同步读；hello 等仅写 stdout 时 read 路径可为空实现。 */
ptrdiff_t io_read(int fd, uint8_t *buf, size_t count, unsigned timeout_ms) {
  long n;
  (void)timeout_ms;
  if (!buf && count > 0)
    return (ptrdiff_t)-1;
#if defined(__linux__) && defined(__x86_64__)
  n = seed_io_syscall_read(fd, buf, (unsigned long)count);
#elif defined(__unix__) || defined(__APPLE__)
  n = (long)read(fd, buf, count);
#else
  n = -1;
#endif
  return (ptrdiff_t)n;
}

/** 与 io_read_ptr 配套的 TLS 缓冲（F-03 seed 桩：单线程单缓冲）。 */
static uint8_t g_io_read_ptr_buf[4096];
static int32_t g_io_read_ptr_len = 0;

/** stdin 指针读：读入 g_io_read_ptr_buf 并返回指针；EOF/错误返回 NULL。 */
uint8_t *io_read_ptr(unsigned handle, unsigned timeout_ms) {
  ptrdiff_t r;
  (void)timeout_ms;
  g_io_read_ptr_len = 0;
  if (handle != 0)
    return NULL;
  r = io_read(0, g_io_read_ptr_buf, sizeof g_io_read_ptr_buf, 0);
  if (r <= 0)
    return NULL;
  g_io_read_ptr_len = (int32_t)r;
  return g_io_read_ptr_buf;
}

/** 与 io_read_ptr 配套的可用长度桩。 */
int32_t io_read_ptr_len(void) {
  return 0;
}

/** std.io.core 注册单缓冲桩。 */
int32_t io_register_buffer(uint8_t *ptr, size_t len) {
  (void)ptr;
  (void)len;
  return 0;
}

/** std.io.core 三参注册。 */
int32_t shux_io_register(uint8_t *ptr, size_t len, size_t handle) {
  (void)handle;
  return io_register_buffer(ptr, len);
}

/** driver 侧 Buffer 描述符注册。 */
typedef struct { uint8_t *ptr; size_t len; size_t handle; } shu_buffer_abi_t;
int32_t shux_io_register_buf(intptr_t buf) {
  const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf;
  if (!b)
    return -1;
  return shux_io_register(b->ptr, b->len, b->handle);
}

/** std.io.core submit_read 桩。 */
int32_t shux_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_ms) {
  (void)ptr;
  (void)len;
  (void)handle;
  (void)timeout_ms;
  return 0;
}

/** std.io.core submit_write 桩。 */
int32_t shux_io_submit_write(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_ms) {
  (void)ptr;
  (void)len;
  (void)handle;
  (void)timeout_ms;
  return 0;
}

size_t std_io_handle_stdin(void) {
  return 0;
}

size_t std_io_handle_stdout(void) {
  return 1;
}

size_t std_io_handle_stderr(void) {
  return 2;
}

int32_t std_io_write(size_t handle, uint8_t *ptr, size_t len, uint32_t timeout_ms) {
  ptrdiff_t r = io_write((int)handle, (const uint8_t *)ptr, len, timeout_ms);
  if (r < 0)
    return -1;
  return (int32_t)r;
}

int32_t std_io_read(size_t handle, uint8_t *ptr, size_t len, uint32_t timeout_ms) {
  ptrdiff_t r = io_read((int)handle, ptr, len, timeout_ms);
  if (r < 0)
    return -1;
  return (int32_t)r;
}

/** stdout 写：供 std_io_write_stdout / write_with_timeout 桩使用。 */
static int32_t seed_io_write_fd1(uint8_t *ptr, size_t len, uint32_t timeout_ms) {
  ptrdiff_t r;
  if (!ptr && len > 0)
    return -1;
  r = io_write(1, (const uint8_t *)ptr, len, timeout_ms);
  if (r < 0)
    return -1;
  return (int32_t)r;
}

int32_t std_io_print_i32(int32_t x) {
  (void)printf("%d\n", (int)x);
  return 0;
}

int32_t std_io_print_u32(uint32_t x) {
  (void)printf("%u\n", (unsigned)x);
  return 0;
}

int32_t std_io_print_i64(int64_t x) {
  (void)printf("%lld\n", (long long)x);
  return 0;
}

__attribute__((weak)) int32_t std_io_write_stdout(uint8_t *ptr, size_t len) {
  return seed_io_write_fd1(ptr, len, 0);
}

__attribute__((weak)) int32_t std_io_write_with_timeout(uint8_t *ptr, size_t len, uint32_t timeout_ms) {
  return seed_io_write_fd1(ptr, len, timeout_ms);
}

/** std.io.print(ptr,len) C ABI：mangled std_io_print_u8_ptr_usize。 */
__attribute__((weak)) int32_t std_io_print_u8_ptr_usize(uint8_t *ptr, size_t len) {
  return std_io_write_stdout(ptr, len);
}

/** 兼容旧链接名 std_io_print_str。 */
__attribute__((weak)) int32_t std_io_print_str(uint8_t *ptr, size_t len) {
  return std_io_print_u8_ptr_usize(ptr, len);
}

/** std.fmt.println(ptr,len)：跳过 fmt 模块 co-emit 时由入口 CALL 链入。 */
int32_t std_fmt_println(uint8_t *ptr, size_t len) {
  int32_t r = std_io_print_str(ptr, len);
  uint8_t nl = 10;
  (void)std_io_print_str(&nl, 1);
  return r;
}

/** 兜底：未走 redirect 的 call 仍可直接链到 print_str。 */
int32_t print_str(uint8_t *ptr, size_t len) {
  return std_io_print_str(ptr, len);
}

uint8_t *std_io_read_stdin_ptr(void) {
  return io_read_ptr(0, 0);
}

int32_t std_io_ptr_len(void) {
  return io_read_ptr_len();
}

/** 兼容旧链接名。 */
int32_t std_io_read_ptr_len(void) {
  return std_io_ptr_len();
}

/** M-5：u8[] slice ABI（与 mod.x / read_ptr.x ShuxSliceU8 一致）。 */
typedef struct ShuxSliceU8 {
  uint8_t *data;
  size_t length;
} ShuxSliceU8;

/** 零拷贝读 stdin slice；转发 io_read_ptr(0,0) 打包为 slice。 */
ShuxSliceU8 std_io_read_stdin_ptr_slice(void) {
  ShuxSliceU8 s;
  s.data = io_read_ptr(0, 0);
  s.length = s.data ? (size_t)g_io_read_ptr_len : 0;
  return s;
}

/** 零拷贝读 slice；handle 0=stdin。 */
ShuxSliceU8 std_io_read_ptr_slice(size_t handle, uint32_t timeout_ms) {
  ShuxSliceU8 s;
  s.data = io_read_ptr((unsigned)handle, timeout_ms);
  s.length = s.data ? (size_t)g_io_read_ptr_len : 0;
  return s;
}

/**
 * 批量读桩：net/tcp 等链 net.o 时解析 io_read_batch；seed 路径退化为首段 io_read。
 * 参数 p1..p3 在桩 v1 中忽略，与 bootstrap_seed_io_stubs.c 行为一致。
 */
ptrdiff_t io_read_batch(int32_t fd, uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2,
                        size_t l2, uint8_t *p3, size_t l3, int32_t n, unsigned timeout_ms) {
  (void)p1;
  (void)l1;
  (void)p2;
  (void)l2;
  (void)p3;
  (void)l3;
  (void)n;
  return io_read(fd, p0, l0, timeout_ms);
}

/**
 * 批量写桩：net/tcp 等链 net.o 时解析 io_write_batch；seed 路径退化为首段 io_write。
 */
ptrdiff_t io_write_batch(int32_t fd, uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2,
                         size_t l2, uint8_t *p3, size_t l3, int32_t n, unsigned timeout_ms) {
  (void)p1;
  (void)l1;
  (void)p2;
  (void)l2;
  (void)p3;
  (void)l3;
  (void)n;
  return io_write(fd, p0, l0, timeout_ms);
}

/** driver.Buffer 批读写：与 std/io/sync.x 的 IoBatchBuf 布局一致（ptr+len 对）。 */
typedef struct ShuxIoBatchBuf {
  uint8_t *ptr;
  size_t len;
} ShuxIoBatchBuf;

/** 批量读 buf 桩：逐段 io_read 累加；timeout_ms 在桩 v1 中仅传给首段。 */
ptrdiff_t io_read_batch_buf(int32_t fd, const ShuxIoBatchBuf *bufs, int32_t n, unsigned timeout_ms) {
  ptrdiff_t total = 0;
  int32_t i;
  if (!bufs || n <= 0)
    return (ptrdiff_t)-1;
  for (i = 0; i < n; i++) {
    ptrdiff_t r = io_read(fd, bufs[i].ptr, bufs[i].len, i == 0 ? timeout_ms : 0);
    if (r < 0)
      return r;
    total += r;
    if ((size_t)r < bufs[i].len)
      break;
  }
  return total;
}

/**
 * io_read_batch_provided 弱桩：io_batch.x 链 net.o 时解析；seed 路径返回 -1（无 io_uring provided）。
 */
__attribute__((weak)) int32_t io_read_batch_provided(int32_t fd, int32_t n, uint32_t timeout_ms, uint32_t *out_bids,
                                                     uint32_t *out_lens) {
  (void)fd;
  (void)n;
  (void)timeout_ms;
  (void)out_bids;
  (void)out_lens;
  return -1;
}

/**
 * tcp.x Linux cfg 引用 io_uring_*；std.io 尚无独立 io.o 时由弱桩满足 net.o 合并后的 U 符号。
 * 真 io_uring 实现链入后覆盖弱符号。
 */
__attribute__((weak)) int32_t io_uring_connect(uint32_t addr_u32, uint32_t port_u32, uint32_t timeout_ms) {
  (void)addr_u32;
  (void)port_u32;
  (void)timeout_ms;
  return -1;
}

__attribute__((weak)) int32_t io_uring_accept(int32_t listener_fd, uint32_t timeout_ms) {
  (void)listener_fd;
  (void)timeout_ms;
  return -1;
}

__attribute__((weak)) int32_t io_uring_accept_many(int32_t listener_fd, int32_t *out_fds, int32_t n, uint32_t timeout_ms) {
  (void)listener_fd;
  (void)out_fds;
  (void)n;
  (void)timeout_ms;
  return -1;
}

__attribute__((weak)) int32_t io_uring_connect_many(uint32_t addr_u32, uint32_t port_u32, int32_t *out_fds, int32_t n,
                                                    uint32_t timeout_ms) {
  (void)addr_u32;
  (void)port_u32;
  (void)out_fds;
  (void)n;
  (void)timeout_ms;
  return -1;
}

__attribute__((weak)) int32_t io_uring_prefetch_fd(int32_t fd) {
  (void)fd;
  return 0;
}

/** 批量写 buf 桩：逐段 io_write 累加。 */
ptrdiff_t io_write_batch_buf(int32_t fd, const ShuxIoBatchBuf *bufs, int32_t n, unsigned timeout_ms) {
  ptrdiff_t total = 0;
  int32_t i;
  if (!bufs || n <= 0)
    return (ptrdiff_t)-1;
  for (i = 0; i < n; i++) {
    ptrdiff_t r = io_write(fd, bufs[i].ptr, bufs[i].len, i == 0 ? timeout_ms : 0);
    if (r < 0)
      return r;
    total += r;
    if ((size_t)r < bufs[i].len)
      break;
  }
  return total;
}

#if defined(__linux__) && defined(__GLIBC__)
#define SHUX_NET_UDP_GLUE_WEAK __attribute__((weak))
#include "runtime_net_udp_batch.c"
#undef SHUX_NET_UDP_GLUE_WEAK
#endif
