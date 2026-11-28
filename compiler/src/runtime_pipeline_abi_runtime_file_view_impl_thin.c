/* Host-gcc twins of runtime_release_file_view_impl and
 * runtime_read_file_view_impl (runtime_io_abi.x). typool first-wins
 * T runtime_release_file_view_impl 0x1400c6cf0 / T
 * runtime_read_file_view_impl 0x1400c6ea8 (fromsrc_s82) compile
 * `v.field` through the local pointer slot &v, not the view:
 *   lea rbx,[rbp-OFF]; mov [rbx+field],imm  /  mov rax,[rbx+field]
 * typool read zeros v.needs_free/v.needs_munmap as
 *   lea rbx,[rbp-0x28]; mov DWORD PTR [rbx+0x10],0; mov [rbx+0x14],0
 * which is [rbp-0x18]/[rbp-0x14], the saved `out` argument. Writer RIP
 * typool 0x1400c6f5f / typool 0x1400c6f6e. GDB: typool then called
 * thin xlang_runtime_file_view_read_malloc_impl with r8=nil (fd=3,
 * size=233). Caller return RIP thin check_one_file at 0x140001ac1
 * and thin runtime_read_file_malloc_impl at 0x140046464.
 * typool release loads "v.data" as *(&v) (the view pointer itself)
 * and "v.needs_free" from stack garbage, then free()s the view
 * struct (stack 0x103fb2d8), not v.data (nil). Writer RIP typool
 * 0x1400c6e3a / typool 0x1400c6e45; call typool 0x1400c6e48.
 * Caller return RIP typool runtime_release_file_view+70 at
 * 0x1400c7772, from thin runtime_read_file_malloc_impl (release
 * sites 0x140046501 / 0x140046628). Layout: data@0 length@8
 * needs_free@16 needs_munmap@20. Host-gcc twins index through the
 * view pointer. Both faces proven live this hang; first-wins
 * together. docs-only .x, do not idx8. Do not JMP typool rec
 * T 0x140087de4. Do not fold typool diag_io_fputc / typool cfg_apply
 * / typool contains_ci / typool wrappers in this thin. */
#include <stdint.h>
#include <stdlib.h>

extern int open(const char *path, int flags, int mode);
extern int close(int fd);
/* PLATFORM: WINDOWS tipU and typool typool-shown Darwin runtime_io_abi.o
 * export runtime_io_abi_rio_*; LINUX typool typool-exports short rio_*
 * (same bodies). Soft Cap twin must resolve on both; typool typool-wrong
 * short name typool typool-UNDEF typool typool-wipe Ubuntu g05 (s234) and
 * typool typool-shown typool typool-Darwin official pure-ld (s288–s291). */
#if defined(_WIN32) || defined(__CYGWIN__) || defined(__APPLE__)
extern int64_t runtime_io_abi_rio_lseek64(int fd, int64_t off, int whence);
extern int runtime_io_abi_rio_munmap(void *p, uint64_t n);
#define XLANG_RIO_LSEEK64 runtime_io_abi_rio_lseek64
#define XLANG_RIO_MUNMAP runtime_io_abi_rio_munmap
#else
extern int64_t rio_lseek64(int fd, int64_t off, int whence);
extern int rio_munmap(void *p, uint64_t n);
#define XLANG_RIO_LSEEK64 rio_lseek64
#define XLANG_RIO_MUNMAP rio_munmap
#endif
extern int32_t xlang_runtime_file_view_read_malloc_impl(int32_t fd, int64_t size, uint8_t *out);

enum { OFF_DATA = 0 };
enum { OFF_LENGTH = 8 };
enum { OFF_NEEDS_FREE = 16 };
enum { OFF_NEEDS_MUNMAP = 20 };
enum { OPEN_RDONLY_BINARY = 32768 };

void runtime_release_file_view_impl(uint8_t *view) {
  uint8_t *data;
  uint64_t length;
  int32_t needs_free;
  int32_t needs_munmap;

  if (view == 0) {
    return;
  }
  data = *(uint8_t **)(view + OFF_DATA);
  length = *(uint64_t *)(view + OFF_LENGTH);
  needs_free = *(int32_t *)(view + OFF_NEEDS_FREE);
  needs_munmap = *(int32_t *)(view + OFF_NEEDS_MUNMAP);
  if (needs_munmap != 0) {
    if (data != 0) {
      if (length > 0) {
        XLANG_RIO_MUNMAP(data, length);
      }
    }
  }
  if (needs_free != 0) {
    if (data != 0) {
      free(data);
    }
  }
  *(uint8_t **)(view + OFF_DATA) = 0;
  *(uint64_t *)(view + OFF_LENGTH) = 0;
  *(int32_t *)(view + OFF_NEEDS_FREE) = 0;
  *(int32_t *)(view + OFF_NEEDS_MUNMAP) = 0;
}

int32_t runtime_read_file_view_impl(uint8_t *path, uint8_t *out) {
  int32_t fd;
  int64_t size_i;
  int64_t back;

  if (path == 0) {
    return -1;
  }
  if (out == 0) {
    return -1;
  }
  *(uint8_t **)(out + OFF_DATA) = 0;
  *(uint64_t *)(out + OFF_LENGTH) = 0;
  *(int32_t *)(out + OFF_NEEDS_FREE) = 0;
  *(int32_t *)(out + OFF_NEEDS_MUNMAP) = 0;
  fd = open((const char *)path, OPEN_RDONLY_BINARY, 0);
  if (fd < 0) {
    return -1;
  }
  size_i = XLANG_RIO_LSEEK64(fd, 0, 2);
  if (size_i < 0) {
    close(fd);
    return -1;
  }
  if (size_i == 0) {
    close(fd);
    return 0;
  }
  back = XLANG_RIO_LSEEK64(fd, 0, 0);
  if (back < 0) {
    close(fd);
    return -1;
  }
  return xlang_runtime_file_view_read_malloc_impl(fd, size_i, out);
}
