/*
 * DIG s229: host-cc twin for diag_extract_line (SHARED).
 *
 * Tip-asm (and weak src/diag.o) SEGV inside extract when reporting
 * parse diags (P011) on small tip -E probes: bare `main() -> i32`,
 * Wrap/Token nest, etc. gdb: get_source() returns non-null but
 * unmapped (e.g. 0xf7ef9130) while len looks plausible (~file size).
 * Win already had VirtualQuery twin; Linux/Darwin need the same refuse.
 *
 * Authority matches diag.x + Win fix: null/empty/unreadable → -1;
 * scan to line_no; write start/len through out cells (LP64: char** /
 * size_t* == tip u8[8] LE store). PLATFORM: SHARED host-cc first-wins.
 */
#include <stddef.h>
#include <stdint.h>
#include <unistd.h>
#if defined(__linux__)
#include <sys/mman.h>
#elif defined(__APPLE__)
#include <sys/mman.h>
#endif

extern const char *diag_ctx_get_source(void);
extern size_t diag_ctx_get_source_len(void);

/**
 * True when [p, p+n) looks mapped for reading (mincore / reject low VA).
 * PLATFORM: SHARED — Linux/Darwin mincore; else low-VA reject only.
 */
static int source_readable(const void *p, size_t n) {
  const uint8_t *u;
  size_t page;
  size_t left;
  if (p == 0 || n == 0) {
    return 0;
  }
  if ((uintptr_t)p < 0x10000ull) {
    return 0;
  }
#if defined(__linux__) || defined(__APPLE__)
  page = (size_t)sysconf(_SC_PAGESIZE);
  if (page == 0) {
    page = 4096;
  }
  u = (const uint8_t *)((uintptr_t)p & ~(uintptr_t)(page - 1));
  left = ((const uint8_t *)p + n) - u;
  while (left > 0) {
    unsigned char vec = 0;
    size_t chunk = left < page ? left : page;
    /* mincore fails with ENOMEM/EINVAL when the range is not mapped. */
    if (mincore((void *)u, page, (char *)&vec) != 0) {
      return 0;
    }
    u += page;
    if (left <= page) {
      break;
    }
    left -= page;
  }
  return 1;
#else
  (void)n;
  return 1;
#endif
}

/**
 * Extract one source line for human diag underlining.
 * @param line_no 1-based line
 * @param line_start_out receives pointer into diag source (not owned)
 * @param line_len_out receives byte length (no trailing NL)
 * @return 0 on success, -1 on bad args / missing line / empty source
 */
int diag_extract_line(int line_no, const char **line_start_out,
                      size_t *line_len_out) {
  const char *src;
  size_t len64;
  size_t len;
  int line;
  size_t i;
  size_t start;

  if (line_no <= 0 || line_start_out == 0 || line_len_out == 0) {
    return -1;
  }
  src = diag_ctx_get_source();
  len64 = diag_ctx_get_source_len();
  if (src == 0 || len64 == 0) {
    return -1;
  }
  if (len64 > 0x7fffffffull) {
    len = 0x7fffffffu;
  } else {
    len = (size_t)len64;
  }
  /* DIG s229: tip get_source can return unmapped VA with a plausible len. */
  if (!source_readable(src, len)) {
    return -1;
  }

  line = 1;
  i = 0;
  start = 0;
  while (i < len) {
    if (line == line_no) {
      break;
    }
    if ((unsigned char)src[i] == 10) {
      line = line + 1;
      start = i + 1;
    }
    i = i + 1;
  }
  if (line != line_no) {
    return -1;
  }
  while (i < len) {
    unsigned char c = (unsigned char)src[i];
    if (c == 10 || c == 13) {
      break;
    }
    i = i + 1;
  }
  *line_start_out = src + start;
  *line_len_out = i - start;
  return 0;
}
