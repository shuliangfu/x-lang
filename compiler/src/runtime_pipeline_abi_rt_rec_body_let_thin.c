/* Host-gcc twin of typool rt_rec_body_let (rt_parse_diag.x).
 * typool first-wins T 0x1402463ec (fromsrc_s90) compiled
 *   if (lk == 25 && lch == 59 && nest == 0) {
 *     break;
 *   }
 * as a jump to the while-head, not out of the loop:
 *   ...; jmp 0x14024645f (while-head)
 * Writer RIP typool 0x140246541. After thin rt_rec_next_tok returns
 * the real semicolon, typool jumps back, keeps scanning, and later
 * reports a false P001 "expected ';' after let". Caller return RIP
 * typool runtime_report_parse_recovery_diagnostics at typool
 * 0x1402473b8. typool rt_rec_next_tok / typool rt_rec_is_stmt_start
 * / typool rt_rec_fail / typool diag_io_fputc / typool
 * driver_diag_append_i32 / typool driver_diagnostic_parse_skip_function
 * are not in this thin.
 * GDB on fromsrc_s90 typool-leaf check tests/option/main.x, live:
 * ENTER_BODY_LET n=1 ret=0x1402473b8; typool-wrong jmp hit 71 times
 * at real semicolons (first k=25 ch=59 line=10 col=58); FAIL line=100
 * col=3 "expected ';' after let"; RET_BODY_LET n=1 eax=1
 * brk_letsemi=71 fail=2. Independently proven from typool
 * rt_rec_top_function. Same typool-wrong class as typool
 * rt_rec_top_const / typool rt_rec_top_function. Host-gcc twin uses
 * a real break. docs-only .x, do not idx8. Do not JMP typool rec
 * T 0x140087de4. */
#include <stdint.h>

extern int32_t rt_rec_next_tok(uint8_t *src, int32_t *s, int32_t *t);
extern int32_t rt_rec_is_stmt_start(int32_t *t);
extern void rt_rec_rewind(int32_t *s, int32_t *t);
extern void rt_rec_fail(int32_t line, int32_t col, uint8_t *msg);

int32_t rt_rec_body_let(uint8_t *src, int32_t *s) {
  int32_t lx[6];
  int32_t saw_eq;
  int32_t nest;
  int32_t lk;
  int32_t lch;
  int32_t i;

  for (i = 0; i < 6; i = i + 1) {
    lx[i] = 0;
  }
  saw_eq = 0;
  nest = 0;
  while (rt_rec_next_tok(src, s, &lx[0]) != 0) {
    lk = lx[0];
    lch = lx[1];
    if (lk == 25 && lch == 59 && nest == 0) {
      break;
    }
    if (lk == 25 && (lch == 40 || lch == 91 || lch == 123)) {
      nest = nest + 1;
      continue;
    }
    if (lk == 25 && (lch == 41 || lch == 93 || lch == 125)) {
      if (nest > 0) {
        nest = nest - 1;
        continue;
      }
      if (lch == 125) {
        rt_rec_fail(lx[2], lx[3], (uint8_t *)"expected ';' after let");
        rt_rec_rewind(s, &lx[0]);
        return 1;
      }
      continue;
    }
    if (lk == 25 && lch == 61 && nest == 0) {
      saw_eq = 1;
      continue;
    }
    if (nest == 0 && rt_rec_is_stmt_start(&lx[0]) != 0 && lk != 1) {
      if (saw_eq != 0
          && (lk == 3 || lk == 17 || lk == 11
              || lk == 10 || lk == 7 || lk == 6
              || lk == 5 || (lk == 25 && lch == 123))) {
        continue;
      }
      rt_rec_fail(lx[2], lx[3], (uint8_t *)"expected ';' after let");
      rt_rec_rewind(s, &lx[0]);
      return 1;
    }
    if (lk == 0) {
      break;
    }
  }
  return 0;
}
