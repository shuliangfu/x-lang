/* Host-gcc twin of typool rt_rec_top_function (rt_parse_diag.x).
 * typool first-wins T 0x14024605c (fromsrc_s90) compiled
 *   if (rt_rec_is_punct(&fx[0], 123) != 0) {
 *     depth[0] = depth[0] + 1;
 *     break;
 *   }
 * as a jump to the while-head after incrementing depth:
 *   ...; mov depth[0]+1; jmp 0x1402460bb (while-head)
 * Writer RIP typool 0x1402461ea. After thin rt_rec_next_tok returns
 * the real '{' (k=25 ch=123), typool jumps back, consumes the first
 * in-body `let`, and reports a false P001 "expected '{' before
 * function body". Caller return RIP typool
 * runtime_report_parse_recovery_diagnostics at typool 0x140247325.
 * The same-face typool-wrong jmp typool 0x140246273 (extern-function
 * semicolon break) is fixed together. typool rt_rec_next_tok /
 * typool rt_rec_is_punct / typool rt_rec_fail / typool
 * diag_io_fputc / typool driver_diag_append_i32 / typool
 * driver_diagnostic_parse_skip_function are not in this thin.
 * GDB on fromsrc_s90 typool-leaf check tests/option/main.x, live:
 * ENTER_TOP_FN n=1 ret=0x140247325; typool-wrong jmp n=1 fx k=25
 * ch=123 line=8 col=22; FAIL line=10 col=3 "expected '{' before
 * function body"; RET_TOP_FN n=1 eax=1 brk_brace=1 brk_fnsemi=0
 * fail=1. Same typool-wrong class as typool rt_rec_top_const.
 * Host-gcc twin uses a real break. docs-only .x, do not idx8.
 * Do not JMP typool rec T 0x140087de4. */
#include <stdint.h>

extern int32_t rt_rec_next_tok(uint8_t *src, int32_t *s, int32_t *t);
extern int32_t rt_rec_is_punct(int32_t *t, int32_t ch);
extern int32_t rt_rec_is_top_start(int32_t *t);
extern void rt_rec_rewind(int32_t *s, int32_t *t);
extern void rt_rec_fail(int32_t line, int32_t col, uint8_t *msg);

int32_t rt_rec_top_function(uint8_t *src, int32_t *s, int32_t *depth) {
  int32_t fx[6];
  int32_t saw_rparen;
  int32_t i;

  for (i = 0; i < 6; i = i + 1) {
    fx[i] = 0;
  }
  saw_rparen = 0;
  while (rt_rec_next_tok(src, s, &fx[0]) != 0) {
    if (rt_rec_is_punct(&fx[0], 40) != 0) {
      continue;
    }
    if (rt_rec_is_punct(&fx[0], 41) != 0) {
      saw_rparen = 1;
      continue;
    }
    if (rt_rec_is_punct(&fx[0], 123) != 0) {
      depth[0] = depth[0] + 1;
      break;
    }
    if (saw_rparen != 0 && rt_rec_is_punct(&fx[0], 59) != 0) {
      break;
    }
    if (saw_rparen != 0 && rt_rec_is_top_start(&fx[0]) != 0) {
      rt_rec_fail(fx[2], fx[3], (uint8_t *)"expected '{' before function body");
      rt_rec_rewind(s, &fx[0]);
      return 1;
    }
    if (fx[0] == 0) {
      break;
    }
  }
  return 0;
}
