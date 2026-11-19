/* Host-gcc twin of typool parser_asm_parse_as_suffix_into_slice_c
 * (pthin_expr_as_suffix_tramp.x). fromsrc_s114 residual: typool
 * leftover slice T 0x140473d44 never memcpy'd the 16-byte cursor at
 * out+8 into local cur before calling parser_asm_parse_as_suffix_x_into_c,
 * and passed a wrong 2nd arg as lex_inout. Live GDB on
 * fromsrc_s114_noaslr check examples/hello.x (repo cwd): AS_SLICE_ENTER
 * out.pos=3862 (space before `as` in `(one_u << 63) as i64` inside
 * core.fmt fmt_i64_to_buf) then AS_X returned eax=1 with out.pos still
 * 3862 — TOKEN_AS never consumed — then host-cc parse_block / onefunc
 * failed (parse skip at byte 3865 / 3622). typool leftover
 * parser_asm_parse_as_suffix_x_into_c / typool parse_type_ref /
 * typool fputc / typool diag / typool rec are not in this thin.
 * docs-only .x, do not idx8. Do not JMP typool rec T 0x140087de4. */
#include <stdint.h>
#include <string.h>

extern int32_t parser_asm_parse_as_suffix_x_into_c(void *arena, void *lex_inout,
                                                   void *source, int32_t *out_ok,
                                                   int32_t *out_expr_ref);

void parser_asm_parse_as_suffix_into_slice_c(void *arena, void *source,
                                            void *out) {
  uint8_t cur[16];
  int32_t ok;
  int32_t refv;
  int32_t rc;
  int32_t *op;

  if (out == 0 || source == 0) {
    return;
  }
  op = (int32_t *)out;
  ok = op[0];
  if (ok == 0) {
    return;
  }
  memset(cur, 0, sizeof(cur));
  refv = op[1];
  memcpy(cur, (uint8_t *)out + 8, 16);
  rc = parser_asm_parse_as_suffix_x_into_c(arena, cur, source, &ok, &refv);
  memcpy((uint8_t *)out + 8, cur, 16);
  op[1] = refv;
  if (rc == 0 || ok == 0) {
    op[0] = 0;
  } else {
    op[0] = ok;
  }
}
