/**
 * runtime_asm_io_stubs.c — seed asm 用户程序链接桩
 *
 * std.io 族 .su 模块在 pipeline/asm_codegen_elf_o 中跳过机器码生成；
 * 本 TU 提供 print_* / write_* / read_ptr 等 C ABI 符号，与 ../std/io/io.o 一并链入用户可执行文件。
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

extern ptrdiff_t io_write(int fd, const uint8_t *buf, size_t count, unsigned timeout_ms);
extern ptrdiff_t io_read(int fd, uint8_t *buf, size_t count, unsigned timeout_ms);
extern uint8_t *io_read_ptr(unsigned handle, unsigned timeout_ms);
extern int32_t io_read_ptr_len(void);

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
