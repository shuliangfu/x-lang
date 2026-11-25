/* Host-gcc twin of xlang_runtime_file_view_read_malloc_impl
 * (file_view_read_malloc_impl_fix.x / runtime_io_abi.x). typool
 * first-wins T 0x140046370 (fromsrc_s83; typool leftover W
 * 0x1400c7e1c not entered) compiled
 * `out_view.data = buf; out_view.length = size_u;
 *  out_view.needs_free = 1; out_view.needs_munmap = 0`
 * as shallow lea through &out_view (the local pointer slot at
 * [rbp-0x48]):
 *   mov rax,[rbp-0x20]; mov [rbp-0x48],rax
 *   lea rbx,[rbp-0x48]; mov [rbx+0],buf; mov [rbx+8],size; ...
 * Writer RIP typool-compiled first-wins 0x1400465a2 (store data
 * into &out, clobbering the saved out pointer). GDB: dest=
 * 0x103fe518 == &out_slot, real out 0x103fecd0 left data=nil
 * len=0 needs_free=0; stack slot received buf / 0xe9 / 1 / 0;
 * eax=0. Caller return RIP thin runtime_read_file_view_impl at
 * 0x14000166f (twice: check_one_file view and thin
 * runtime_read_file_malloc_impl local view). Host-gcc twin
 * indexes through the out pointer. typool `buf+off` was 32-bit
 * add eax,ebx in the same face (not the empty-view writer;
 * heap was low-4GB this run). docs-only .x, do not idx8. Do not
 * JMP typool rec T 0x140087de4. Do not fold typool diag_io_fputc
 * / typool write_u8_at / typool runtime_read_file_malloc_impl in
 * this thin. */
#include <stdint.h>
#include <stdlib.h>

extern int close(int fd);
extern intptr_t xlang_sys_read(int fd, uint8_t *buf, uint64_t count);

enum { OFF_DATA = 0 };
enum { OFF_LENGTH = 8 };
enum { OFF_NEEDS_FREE = 16 };
enum { OFF_NEEDS_MUNMAP = 20 };

int32_t xlang_runtime_file_view_read_malloc_impl(int32_t fd, int64_t size, uint8_t *out) {
  uint64_t size_u;
  uint8_t *buf;
  uint64_t off;
  intptr_t n;

  size_u = (uint64_t)size;
  buf = (uint8_t *)malloc((size_t)size_u + 1);
  if (buf == 0) {
    close(fd);
    return -1;
  }
  off = 0;
  while (off < size_u) {
    n = xlang_sys_read(fd, buf + off, size_u - off);
    if (n < 0) {
      free(buf);
      close(fd);
      return -1;
    }
    if (n == 0) {
      break;
    }
    off = off + (uint64_t)n;
  }
  close(fd);
  if (off != size_u) {
    free(buf);
    return -1;
  }
  buf[size_u] = 0;
  if (out == 0) {
    free(buf);
    return -1;
  }
  *(uint8_t **)(out + OFF_DATA) = buf;
  *(uint64_t *)(out + OFF_LENGTH) = size_u;
  *(int32_t *)(out + OFF_NEEDS_FREE) = 1;
  *(int32_t *)(out + OFF_NEEDS_MUNMAP) = 0;
  return 0;
}
