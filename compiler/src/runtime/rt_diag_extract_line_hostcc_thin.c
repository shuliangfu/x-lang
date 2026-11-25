/*
 * DIG s229: host-cc twin for diag_extract_line (SHARED).
 *
 * Tip get_source() returns a non-null unmapped VA (gdb: 0xf7ef9130) with a
 * plausible len while reporting P011 on small tip -E probes → SEGV in
 * extract. Freestanding residual link cannot pull pipe/mincore; this twin
 * refuses underline (return -1) so human diag still emits without SEGV.
 * Root get_source tipU load is a follow-on UNIQUE. PLATFORM: SHARED.
 */
#include <stddef.h>
#include <stdint.h>

/**
 * Extract one source line for human diag underlining.
 * Soft Cap: always skip underline when tip source ctx is untrustworthy.
 * @return -1 (no line); never SEGV
 */
int diag_extract_line(int line_no, const char **line_start_out,
                      size_t *line_len_out) {
  (void)line_no;
  if (line_start_out != 0) {
    *line_start_out = 0;
  }
  if (line_len_out != 0) {
    *line_len_out = 0;
  }
  return -1;
}
