/* Host-gcc twin of lexer_cfg_eval_target_os (cfg_eval.x
 * cfg_eval_target_os / seeds cfg_eval_gen).
 * typool first-wins T 0x14037ebf0 (fromsrc_s103) compiles
 * `let lit_target_os: u8[10] = [116,97,114,103,101,116,95,111,115,0]`
 * as qword stores through a bogus base:
 *   lea rax,[rbp+0x1eba5420]; mov QWORD PTR [rbx+stride],imm
 * with stride 0x363 between bytes. Writer RIP typool 0x14037ec24
 * (store of 0x74 / 't'). GDB: entered from typool
 * lexer_cfg_eval_expr_range + 491 (caller return RIP 0x14037f8b7);
 * computed dest 0x2ef969d0 is unmapped -> SIGSEGV (RC=0xC0000005).
 * Same typool-wrong class as typool lexer_cfg_parse_triple_literals.
 * typool lexer_cfg_eval_target_arch 0x14037f030 and typool
 * lexer_cfg_eval_freestanding_flag 0x14037f49c have the same lea
 * pattern but were not live-pinned on this hello run and are not
 * folded here. Host-gcc twin keeps the lit on the stack and indexes
 * u8 directly. docs-only .x, do not idx8. Do not JMP typool rec T
 * 0x140087de4. Do not fold typool diag_io_fputc / typool rec /
 * typool lexer_next_impl wholesale in this thin. */
#include <stdint.h>

extern int32_t lexer_cfg_range_eq_ci(uint8_t *buf, int32_t b, int32_t e, uint8_t *lit);
extern int32_t lexer_cfg_skip_ws(uint8_t *buf, int32_t p, int32_t end);
extern uint8_t *lexer_cfg_effective_os_lit(void);

int32_t lexer_cfg_eval_target_os(uint8_t *buf, int32_t p, int32_t end) {
  uint8_t lit_target_os[10];
  int32_t lit;

  lit_target_os[0] = 116;
  lit_target_os[1] = 97;
  lit_target_os[2] = 114;
  lit_target_os[3] = 103;
  lit_target_os[4] = 101;
  lit_target_os[5] = 116;
  lit_target_os[6] = 95;
  lit_target_os[7] = 111;
  lit_target_os[8] = 115;
  lit_target_os[9] = 0;

  if ((p + 9) > end) {
    return -1;
  }
  if (lexer_cfg_range_eq_ci(buf, p, p + 9, &lit_target_os[0]) == 0) {
    return -1;
  }
  p = p + 9;
  p = lexer_cfg_skip_ws(buf, p, end);
  if (p >= end) {
    return 0;
  }
  if (buf[p] != 61) {
    return 0;
  }
  p = p + 1;
  if (p < end) {
    if (buf[p] == 61) {
      p = p + 1;
    }
  }
  p = lexer_cfg_skip_ws(buf, p, end);
  if (p >= end) {
    return 0;
  }
  if (buf[p] != 34) {
    return 0;
  }
  p = p + 1;
  lit = p;
  while (p < end) {
    if (buf[p] == 34) {
      break;
    }
    p = p + 1;
  }
  if (lexer_cfg_range_eq_ci(buf, lit, p, lexer_cfg_effective_os_lit()) != 0) {
    return 1;
  }
  return 0;
}
