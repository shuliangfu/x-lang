/* Win tip-cold: tip diag_extract_line can SEGV at src[i] when
 * diag_ctx_get_source() is stale/unmapped (overlay -backend asm -c path).
 * Strong T before tip diag.o. Bounds + VirtualQuery before any load.
 * PLATFORM: WINDOWS. */
#include <stdint.h>
#include <stddef.h>
#ifdef _WIN32
#include <windows.h>
#endif

extern const char *diag_ctx_get_source(void);
extern size_t diag_ctx_get_source_len(void);

static int win_readable(const void *p, size_t n) {
  MEMORY_BASIC_INFORMATION mbi;
  const uint8_t *u;
  size_t left;
  if (!p)
    return 0;
  if ((uintptr_t)p < 0x10000ull)
    return 0;
  u = (const uint8_t *)p;
  left = n ? n : 1;
  while (left) {
    SIZE_T q = VirtualQuery(u, &mbi, sizeof mbi);
    size_t chunk;
    if (q == 0)
      return 0;
    if (mbi.State != MEM_COMMIT)
      return 0;
    if (!(mbi.Protect & (PAGE_READONLY | PAGE_READWRITE | PAGE_EXECUTE_READ |
                         PAGE_EXECUTE_READWRITE | PAGE_WRITECOPY |
                         PAGE_EXECUTE_WRITECOPY)))
      return 0;
    if (mbi.Protect & (PAGE_NOACCESS | PAGE_GUARD))
      return 0;
    chunk = (size_t)(((const uint8_t *)mbi.BaseAddress + mbi.RegionSize) - u);
    if (chunk == 0)
      return 0;
    if (chunk > left)
      chunk = left;
    u += chunk;
    left -= chunk;
  }
  return 1;
}

int diag_extract_line(int line_no, const char **line_start_out,
                      size_t *line_len_out) {
  const char *src;
  size_t len64;
  size_t len;
  int line;
  size_t i;
  size_t start;

  if (line_no <= 0 || !line_start_out || !line_len_out)
    return -1;
  src = diag_ctx_get_source();
  len64 = diag_ctx_get_source_len();
  if (!src || len64 == 0)
    return -1;
  if (len64 > 0x7fffffffull)
    len = 0x7fffffffu;
  else
    len = (size_t)len64;
  if (!win_readable(src, len))
    return -1;

  line = 1;
  i = 0;
  start = 0;
  while (i < len) {
    if (line == line_no)
      break;
    if ((unsigned char)src[i] == 10) {
      line++;
      start = i + 1;
    }
    i++;
  }
  if (line != line_no)
    return -1;
  while (i < len) {
    unsigned char c = (unsigned char)src[i];
    if (c == 10 || c == 13)
      break;
    i++;
  }
  *line_start_out = src + start;
  *line_len_out = i - start;
  return 0;
}
