/**
 * runtime_asm_io_stubs.c — seed asm 用户程序链接桩
 *
 * std.io 族 .sx 模块在 pipeline/asm_codegen_elf_o 中跳过机器码生成；
 * 本 TU 提供 print_* / write_* / read_ptr 等 C ABI 符号，与 ../std/io/io.o 一并链入用户可执行文件。
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#if defined(__unix__) || defined(__APPLE__)
#include <unistd.h>
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

/** F-03：io_sync.sx 机器码不在 io.o；本 TU 提供 io_write/io_read 同步 ABI。 */
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

int32_t std_io_write_stdout(uint8_t *ptr, size_t len) {
  return seed_io_write_fd1(ptr, len, 0);
}

int32_t std_io_write_with_timeout(uint8_t *ptr, size_t len, uint32_t timeout_ms) {
  return seed_io_write_fd1(ptr, len, timeout_ms);
}

/** std.io.print_str C ABI：入口裸调 print_str 经 redirect 链入本符号。 */
int32_t std_io_print_str(uint8_t *ptr, size_t len) {
  return std_io_write_stdout(ptr, len);
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

int32_t std_io_read_ptr_len(void) {
  return io_read_ptr_len();
}
