/* Host-gcc twin of typool lexer_cfg_skip_ws (cfg_eval_gen seed).
 * typool first-wins T (fromsrc_s102 0x14037e04c) typool-wrongs
 * `if (is_ws == 0) break;` as jmp typool 0x14037e071 (while-head)
 * at typool writer RIP typool 0x14037e186, instead of breaking to
 * typool 0x14037e1a8 / ret typool 0x14037e1b9. Live HW-BP on
 * fromsrc_s102_noaslr check examples/hello.x (repo cwd): ENTER n=1
 * from typool lexer_cfg_eval_expr_range+0x4c, p=0 end=19 c=116 ('t');
 * WRONG_JMP n=72258 in 5s, all same p=0 c='t' flag=0; INCR=0; RET=0.
 * Two clean timed hangs (~4s / ~8s, no output) agreed — real hang,
 * not an alarm artifact. Same typool typool-wrong class as typool
 * skip_ws / typool skip_comment / typool normalize / typool
 * generic_bound_scan. typool tip / body_into / skip_function /
 * append_i32 / fputc / try_keyword_c / typool rec / typool
 * lexer_next_impl wholesale are not in this thin. docs-only .x,
 * do not idx8. Do not JMP typool rec T 0x140087de4. */
#include <stdint.h>

int32_t lexer_cfg_skip_ws(uint8_t *buf, int32_t p, int32_t end) {
  uint8_t c;
  int32_t is_ws;

  if (buf == 0)
    return p;
  while (p < end) {
    c = buf[p];
    is_ws = 0;
    if (c == 32)
      is_ws = 1;
    if (c == 9)
      is_ws = 1;
    if (c == 10)
      is_ws = 1;
    if (c == 13)
      is_ws = 1;
    if (is_ws == 0)
      break;
    p = p + 1;
  }
  return p;
}
