/* Host-gcc twin of typool rt_rec_top_const (rt_parse_diag.x).
 * typool first-wins T 0x140245608 (fromsrc_s89) compiled the import-path
 *   while (rt_rec_next_tok(src, s, &cx[0]) != 0) {
 *     if (rt_rec_is_punct(&cx[0], 59) != 0) {
 *       break;
 *     }
 *     if (rt_rec_is_top_start(&cx[0]) != 0) {
 *       rt_rec_fail(..., "expected ';' after const x = import('path')");
 *       ...
 *     }
 *   }
 * as a jump to the while-head, not out of the loop:
 *   test eax; je not_semi; jmp 0x140245972 (while-head)
 * After thin rt_rec_next_tok returns the real semicolon (k=25 ch=59
 * line=3 col=30), typool jumps back, consumes `function`, and reports
 * a false P001 at @:5:1. Writer RIP typool 0x140245a04. Caller return
 * RIP typool runtime_report_parse_recovery_diagnostics at typool
 * 0x140246fa0. typool rt_rec_next_tok / typool rt_rec_is_punct /
 * typool rt_rec_fail / typool diag_io_fputc / typool
 * driver_diag_append_i32 / typool rt_rec_top_function / typool
 * rt_rec_body_let are not in this thin. The later typool-wrong jmp
 * typool 0x140245c19 in the same face's second semicolon loop is
 * fixed together. Host-gcc twin uses a real break.
 * GDB on fromsrc_s89 check examples/hello.x (repo cwd), live call/ret:
 * TOK 1 k=2 const; ENTER_TOP_CONST n=1 ret=0x140246fa0; TOK 2..8
 * ident, '=', import, '(', string, ')', ';' (k=25 ch=59); typool-wrong
 * jmp n=1 at ';' tok_r=8; FAIL line=5 col=1 "expected ';' after const
 * x = import('path')"; RET_TOP_CONST n=1 eax=1 brk1=1 fail=1 tok_r=9.
 * Same typool-wrong class as typool rt_rec_next_tok /
 * typool rt_rec_skip_ws_comment / typool parse_directive_into
 * break-as-jmp to while-head. docs-only .x, do not idx8. Do not JMP
 * typool rec T 0x140087de4. */
#include <stdint.h>

extern int32_t rt_rec_next_tok(uint8_t *src, int32_t *s, int32_t *t);
extern int32_t rt_rec_is_punct(int32_t *t, int32_t ch);
extern int32_t rt_rec_is_top_start(int32_t *t);
extern void rt_rec_rewind(int32_t *s, int32_t *t);
extern void rt_rec_recover_to_top_start(uint8_t *src, int32_t *s);
extern void rt_rec_fail(int32_t line, int32_t col, uint8_t *msg);

int32_t rt_rec_top_const(uint8_t *src, int32_t *s, int32_t *depth) {
  int32_t cn[6];
  int32_t ce[6];
  int32_t cr[6];
  int32_t cx[6];
  int32_t cerr;
  int32_t i;

  for (i = 0; i < 6; i = i + 1) {
    cn[i] = 0;
    ce[i] = 0;
    cr[i] = 0;
    cx[i] = 0;
  }
  cerr = 0;
  if (rt_rec_next_tok(src, s, &cn[0]) == 0) {
    return -1;
  }
  if (cn[0] == 22) {
    if (rt_rec_next_tok(src, s, &ce[0]) == 0) {
      return -1;
    }
    if (rt_rec_is_punct(&ce[0], 61) != 0) {
      if (rt_rec_next_tok(src, s, &cr[0]) == 0) {
        return -1;
      }
      if (cr[0] != 15) {
        rt_rec_fail(cr[2], cr[3], (uint8_t *)"expected const x = import('path')");
        rt_rec_rewind(s, &cr[0]);
        rt_rec_recover_to_top_start(src, s);
        return 1;
      }
      while (rt_rec_next_tok(src, s, &cx[0]) != 0) {
        if (rt_rec_is_punct(&cx[0], 59) != 0) {
          break;
        }
        if (rt_rec_is_top_start(&cx[0]) != 0) {
          rt_rec_fail(cx[2], cx[3], (uint8_t *)"expected ';' after const x = import('path')");
          rt_rec_rewind(s, &cx[0]);
          return 1;
        }
      }
      return 0;
    }
    rt_rec_rewind(s, &ce[0]);
  } else {
    rt_rec_rewind(s, &cn[0]);
  }
  while (rt_rec_next_tok(src, s, &cx[0]) != 0) {
    if (rt_rec_is_punct(&cx[0], 59) != 0) {
      break;
    }
    if (rt_rec_is_punct(&cx[0], 123) != 0) {
      depth[0] = depth[0] + 1;
      break;
    }
    if (rt_rec_is_top_start(&cx[0]) != 0) {
      rt_rec_fail(cx[2], cx[3], (uint8_t *)"expected ';' after top-level const");
      rt_rec_rewind(s, &cx[0]);
      cerr = 1;
      break;
    }
  }
  return cerr;
}
