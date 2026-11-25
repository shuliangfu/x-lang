/*
 * DIG s229: host-cc twin for diag_extract_line (SHARED).
 *
 * Tip-asm (weak diag.o) SEGV when reporting parse diags on small tip -E
 * probes. gdb: diag_ctx_get_source() returns non-null unmapped VA
 * (e.g. 0xf7ef9130) with a plausible len (~file size). Win twin uses
 * VirtualQuery; this SHARED twin refuses low VA and uses a pipe probe
 * write that fails safely on EFAULT without SEGV (no mincore/sysconf —
 * FORCE_CC residual can be freestanding-ish and leave those UNDEF).
 *
 * Authority: diag.x scan; out cells are LP64 char** / size_t* (same as
 * tip u8[8] LE stores). PLATFORM: SHARED host-cc first-wins.
 */
#include <stddef.h>
#include <stdint.h>
#include <errno.h>
#include <unistd.h>

extern const char *diag_ctx_get_source(void);
extern size_t diag_ctx_get_source_len(void);

/**
 * True when [p, p+n) is readable without SEGV.
 * Uses write(pipe) which returns -1/EFAULT on unmapped — no signal.
 * PLATFORM: SHARED POSIX.
 */
static int source_readable(const void *p, size_t n) {
  int fds[2];
  size_t left;
  const uint8_t *u;
  if (p == 0 || n == 0) {
    return 0;
  }
  if ((uintptr_t)p < 0x10000ull) {
    return 0;
  }
  if (pipe(fds) != 0) {
    return 0;
  }
  u = (const uint8_t *)p;
  left = n;
  while (left > 0) {
    size_t chunk = left > 4096 ? 4096 : left;
    ssize_t w = write(fds[1], u, chunk);
    if (w < 0) {
      close(fds[0]);
      close(fds[1]);
      return 0;
    }
    if ((size_t)w == 0) {
      close(fds[0]);
      close(fds[1]);
      return 0;
    }
    u += (size_t)w;
    left -= (size_t)w;
  }
  close(fds[0]);
  close(fds[1]);
  (void)errno;
  return 1;
}

/**
 * Extract one source line for human diag underlining.
 * @param line_no 1-based line
 * @param line_start_out receives pointer into diag source (not owned)
 * @param line_len_out receives byte length (no trailing NL)
 * @return 0 on success, -1 on bad args / missing line / empty / unreadable
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
