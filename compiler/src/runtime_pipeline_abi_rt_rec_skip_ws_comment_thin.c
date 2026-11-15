/* Host-gcc twin of typool rt_rec_skip_ws_comment (rt_parse_diag.x).
 * typool first-wins T 0x14024318c (fromsrc_s87) compiled the line-comment
 * inner loop
 *   while (true) {
 *     wd = rt_rec_peek(src, s);
 *     if (wd == 0 || wd == 10) { break; }
 *     wd = rt_rec_get(src, s);
 *   }
 * as a jump to the inner while-head, not out of the loop:
 *   call rt_rec_peek; ...; je get; jmp 0x1402433c8 (inner while-head)
 * When a `//` line hits newline, typool peeks wd=10 forever and never
 * breaks, never continues the outer loop, and never returns. Writer RIP
 * typool 0x140243449 (jmp to the inner while-head on wd==0 or wd==10).
 * Caller return RIP typool 0x14024421c, immediately after
 * `call rt_rec_skip_ws_comment`. typool rt_rec_peek itself enters and
 * returns (live peek_e==peek_r) and is not this hang. typool
 * rt_rec_get / typool driver_diag_append_i32 / typool diag_io_fputc /
 * typool rt_rec_peek are not in this thin.
 * GDB on fromsrc_s87 check examples/hello.x (repo cwd), live call/ret:
 * ENTER_SKIP n=1 src=heap s=stack ret=0x14024421c s0=0 s3=233; after
 * skipping the first `//` line, typool-wrong jmp hit 200 times with
 * wd=10 s0=63 s3=233 stuck; peek_e=264 peek_r=264; skip_e=1 skip_r=0.
 * Same typool-wrong class as typool parse_directive_into /
 * typool driver_diag_append_cstr / typool path_should_ignore
 * break-as-jmp to while-head. Host-gcc twin uses a real break. The
 * block-comment `if (wd == 0) break` in this same face is fixed
 * together. docs-only .x, do not idx8. Do not JMP typool rec T
 * 0x140087de4. */
#include <stdint.h>

extern int32_t rt_rec_peek(uint8_t *src, int32_t *s);
extern int32_t rt_rec_get(uint8_t *src, int32_t *s);

void rt_rec_skip_ws_comment(uint8_t *src, int32_t *s) {
  int32_t wc;
  int32_t wn;
  int32_t wi;
  int32_t wd;

  while (1) {
    wc = rt_rec_peek(src, s);
    if (wc == 0) {
      return;
    }
    if (wc == 32 || wc == 9 || wc == 13 || wc == 10) {
      wd = rt_rec_get(src, s);
      continue;
    }
    wi = s[0];
    if (wc == 47 && wi + 1 < s[3]) {
      wn = (int32_t)src[wi + 1];
      if (wn == 47) {
        while (1) {
          wd = rt_rec_peek(src, s);
          if (wd == 0 || wd == 10) {
            break;
          }
          wd = rt_rec_get(src, s);
        }
        continue;
      }
      if (wn == 42) {
        wd = rt_rec_get(src, s);
        wd = rt_rec_get(src, s);
        while (s[0] < s[3]) {
          wd = rt_rec_get(src, s);
          if (wd == 0) {
            break;
          }
          if (wd == 42 && rt_rec_peek(src, s) == 47) {
            wd = rt_rec_get(src, s);
            break;
          }
        }
        continue;
      }
    }
    return;
  }
}
