/**
 * PLATFORM: MACOS|DARWIN arm64 tip PE only —
 * tip_l4_tip_pe_println_method_call_p001 (follow-on after face/binop/unary/primary).
 *
 * After expr twins, dig_str FACE ok=1 er=1 still P001; Cap dig_str reaches typeck.
 * Tip parser_asm_advance_past_stmt_semicolon_into_c is hollow: kind/idlen/tstart/
 * data/slen stay 0 (no peeks), then step + compare kind==SEMICOLON → always 0
 * (Cap 9 bl vs tip 3). empty/ret0 hang and dig_str post-expr P001 are collateral.
 * Soft Cap Prefer / Cap aside / Win banned.
 *
 * Tip-local host-cc twin from src/asm/pthin_lex_skip.x. typool typool-Calls
 * typool typool-shown unmangled skip helpers already typool typool-T typool typool-on
 * official-bag parser_asm_thin_glue.o (s292).
 */
#include <stddef.h>
#include <stdint.h>

enum { TOKEN_SEMICOLON = 95 };

extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_ident_len_c(void *lex_inout, void *source);
extern size_t parser_asm_lex_peek_token_start_c(void *lex_inout, void *source);
extern uint8_t *parser_asm_lex_source_data_c(void *source);
extern size_t parser_asm_lex_source_length_c(void *source);
extern size_t parser_asm_lex_pos_c(void *lex_inout);
extern int32_t parser_asm_lex_step_kind_c(void *lex_inout, void *source);

/* typool typool-shown official-bag T: parser_asm_lex_skip_* (authority
 * src/asm/pthin_lex_skip.x). typool typool-wrong BODIES_FROM_X-mangled
 * leaf names typool typool-were typool typool-UNDEF typool typool-on typool typool-Darwin official pure-ld (s288-s292). */
extern int32_t parser_asm_lex_skip_ident_is_unsafe_stmt(
    uint8_t *data, size_t length, size_t token_start, int32_t ident_len);
extern int32_t parser_asm_lex_skip_is_asi_stmt_head_kind(int32_t k);

int32_t parser_asm_advance_past_stmt_semicolon_into_c(void *lex_inout,
                                                     void *source) {
  int32_t kind;
  int32_t idlen;
  size_t tstart;
  uint8_t *data;
  size_t slen;
  if (!lex_inout || !source)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  idlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
  tstart = parser_asm_lex_peek_token_start_c(lex_inout, source);
  data = parser_asm_lex_source_data_c(source);
  slen = parser_asm_lex_source_length_c(source);
  if (tstart == 0)
    tstart = parser_asm_lex_pos_c(lex_inout);
  parser_asm_lex_step_kind_c(lex_inout, source);
  if (kind == TOKEN_SEMICOLON)
    return 1;
  if (parser_asm_lex_skip_ident_is_unsafe_stmt(data, slen, tstart, idlen) != 0)
    return 1;
  if (parser_asm_lex_skip_is_asi_stmt_head_kind(kind) != 0)
    return 1;
  return 0;
}
