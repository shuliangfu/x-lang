/*
 * DIG s229: host-cc twin for diag_extract_line (SHARED).
 *
 * Tip-asm (and weak src/diag.o) SEGV inside extract when reporting
 * parse diags (P011) on small tip -E probes: bare `main() -> i32`,
 * Wrap/Token nest, etc. Win already had rt_diag_extract_line_win_fix.c
 * (VirtualQuery); Linux/Darwin had no first-wins twin.
 *
 * Authority matches diag.x: null/empty source → -1; scan to line_no;
 * write start/len through out cells (LP64: char** / size_t* == tip u8[8]
 * LE store). PLATFORM: SHARED host-cc first-wins.
 */
#include <stddef.h>
#include <stdint.h>

extern const char *diag_ctx_get_source(void);
extern size_t diag_ctx_get_source_len(void);

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
