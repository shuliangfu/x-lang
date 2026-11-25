/**
 * PLATFORM: WINDOWS tip PE only — knife 11.60.
 *
 * Tip miswires parser_asm_try_skip_allow_padding_into_c as e9 →
 * parser_asm_lex_step_kind_c. After cfg-const skip (same knife), hello
 * XP008 moved to std.io.win32 @ `allow(padding) struct`.
 *
 * Tip-local C twin of compiler/src/asm/pthin_try_skip_allow.x
 * parser_asm_try_skip_allow_padding_into_c. Calls tip PE lex_* +
 * skip_balanced_parens_into_c only. Soft Cap mix banned.
 */
#include <stdint.h>
#include <stddef.h>

enum { TOKEN_LPAREN = 82 };

extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern void parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_skip_balanced_parens_into_c(void *lex_inout, void *source);

int32_t parser_asm_try_skip_allow_padding_into_c(void *lex_inout, void *source) {
  int32_t kind;
  if (!lex_inout || !source)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_LPAREN)
    return 0;
  parser_asm_lex_step_kind_c(lex_inout, source);
  parser_asm_skip_balanced_parens_into_c(lex_inout, source);
  return 1;
}
