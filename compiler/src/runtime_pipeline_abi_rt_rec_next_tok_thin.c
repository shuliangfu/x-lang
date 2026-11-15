/* Host-gcc twin of typool rt_rec_next_tok (rt_parse_diag.x).
 * typool first-wins T 0x140244340 (fromsrc_s88) compiled the ident loop
 *   while (s[0] < s[3]) {
 *     nn = rt_rec_peek(src, s);
 *     if (rt_rec_is_alpha(nn) == 0 && rt_rec_is_digit(nn) == 0 && nn != 95) {
 *       break;
 *     }
 *     nd = rt_rec_get(src, s);
 *   }
 * as a jump to the while-head, not out of the loop:
 *   ...; je get; jmp 0x14024454b (while-head)
 * After the first thin rt_rec_skip_ws_comment returns, typool peeks a
 * space (nn=32) forever and never returns. Writer RIP typool
 * 0x14024462d. Caller return RIP typool 0x140246ae3, immediately after
 * `call rt_rec_next_tok`. typool rt_rec_peek / typool rt_rec_get /
 * typool rt_rec_skip_ws_comment / typool diag_io_fputc are not in this
 * thin. typool peek continues to enter and return during the spin.
 * GDB on fromsrc_s88 check examples/hello.x (repo cwd), live call/ret:
 * ENTER_NEXT n=1 ret=0x140246ae3; SKIP_RET n=1; typool-wrong jmp hit
 * 200 times with nn=32 s0=150 s3=233 stuck; peek_e=354; tok_e=1 tok_r=0
 * skip_r=1. Same typool-wrong class as typool rt_rec_skip_ws_comment /
 * typool parse_directive_into / typool driver_diag_append_cstr
 * break-as-jmp to while-head. Host-gcc twin uses a real break. The
 * digit and string loops in this same face are fixed together.
 * docs-only .x, do not idx8. Do not JMP typool rec T 0x140087de4. */
#include <stdint.h>

extern void rt_rec_skip_ws_comment(uint8_t *src, int32_t *s);
extern int32_t rt_rec_peek(uint8_t *src, int32_t *s);
extern int32_t rt_rec_get(uint8_t *src, int32_t *s);
extern int32_t rt_rec_is_alpha(int32_t c);
extern int32_t rt_rec_is_digit(int32_t c);
extern int32_t rt_rec_classify_ident(uint8_t *p, int32_t n);

int32_t rt_rec_next_tok(uint8_t *src, int32_t *s, int32_t *t) {
  int32_t nc;
  int32_t nn;
  int32_t nstart;
  int32_t nd;

  rt_rec_skip_ws_comment(src, s);
  if (s[0] >= s[3]) {
    t[0] = 0;
    t[1] = 0;
    t[2] = s[1];
    t[3] = s[2];
    t[4] = s[0];
    t[5] = s[0];
    return 0;
  }
  t[2] = s[1];
  t[3] = s[2];
  nstart = s[0];
  t[4] = nstart;
  nc = rt_rec_get(src, s);
  if (rt_rec_is_alpha(nc) != 0 || nc == 95) {
    while (s[0] < s[3]) {
      nn = rt_rec_peek(src, s);
      if (rt_rec_is_alpha(nn) == 0 && rt_rec_is_digit(nn) == 0 && nn != 95) {
        break;
      }
      nd = rt_rec_get(src, s);
    }
    t[5] = s[0];
    t[0] = rt_rec_classify_ident(&src[nstart], s[0] - nstart);
    t[1] = 0;
    return 1;
  }
  if (rt_rec_is_digit(nc) != 0) {
    while (rt_rec_is_digit(rt_rec_peek(src, s)) != 0) {
      nd = rt_rec_get(src, s);
    }
    t[5] = s[0];
    t[0] = 23;
    t[1] = 0;
    return 1;
  }
  if (nc == 34) {
    while (s[0] < s[3]) {
      nn = rt_rec_get(src, s);
      if (nn == 92 && s[0] < s[3]) {
        nd = rt_rec_get(src, s);
      } else {
        if (nn == 34 || nn == 0) {
          break;
        }
      }
    }
    t[5] = s[0];
    t[0] = 24;
    t[1] = 0;
    return 1;
  }
  t[0] = 25;
  t[1] = nc;
  t[5] = s[0];
  return 1;
}
