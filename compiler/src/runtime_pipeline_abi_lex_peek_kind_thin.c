/*
 * Host-gcc Soft Cap for parser_asm_lex_peek_kind_c (DIG s247 residual).
 *
 * tipU `let raw: u8[72] = []` does not zero the stack slot on Win PE. Soft Cap
 * tip `lexer_next_buf_into` at EOF writes next_lex.pos/line but leaves tok.kind
 * (@+16) uninit → peek returns a heap-looking garbage i32 (e.g. 272592080).
 * Host Soft Cap generic_bound_scan then never sees TOKEN_EOF=0 and spins.
 *
 * Soft Cap: memset the 72-byte result before fill so an unwritten kind stays 0.
 * PLATFORM: SHARED host-cc. Do not tip-assemble. Docs twin .x is docs-only.
 */
#include <stdint.h>
#include <string.h>

extern int32_t parser_asm_lex_bridge_fill(void *lex_in, void *source, void *raw);

/**
 * Peek next token kind without advancing the lexer.
 * @param lex opaque lexer; null → 0
 * @param source opaque fat slice; null → 0
 * @return token kind, or 0 (TOKEN_EOF) on null / fill fail / unwritten kind
 */
int32_t parser_asm_lex_peek_kind_c(void *lex, void *source) {
  uint8_t raw[72];
  int32_t kind;
  if (lex == 0 || source == 0) {
    return 0;
  }
  /* Soft Cap: tipU leaves raw[] uninit; EOF path may skip kind store. */
  memset(raw, 0, sizeof(raw));
  if (parser_asm_lex_bridge_fill(lex, source, raw) == 0) {
    return 0;
  }
  memcpy(&kind, raw + 16, sizeof(kind));
  return kind;
}
