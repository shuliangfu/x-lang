/**
 * PLATFORM: WINDOWS tip PE only — strong override for
 *   parser_asm_is_pointee_type_token_c
 *
 * Root (刀 11.46): tip PE W body at VA 0x1405c1560 saves rcx (kind) to
 * stack but every compare uses stale %ebx (never loaded from the Win64
 * arg). Call site in __stale_parser_asm_parse_star_type_x_into_c leaves
 * ebx=0 → is_pointee always 0 → `*T` / `*u8` param parse fails →
 * set_onefunc_fail soft-skip incomplete → body `let` re-parsed as
 * module top-level → dual-fn P012 (hello / core.fmt).
 *
 * .x source (pthin_lex_skip.x) is correct; tip PE codegen ABI bug only.
 * Byte patch (same effect): at fn+0x0c `48 89 c8`→`48 89 cb`,
 * fn+0x0f `48 89 45 f0`→`48 89 5d f0` (mov %rcx,%rbx; spill rbx).
 * bak md5 8adfb6e0…; patched tip md5 e1b269dc… (LAN windows-server).
 *
 * Ords = pthin pin (PE lexer), NOT token.x new enum.
 * Do NOT raise Soft Cap / tiphead; do NOT Soft Cap G05 mix tip.
 */
#include <stdint.h>

enum {
  TOKEN_IDENT = 59,
  TOKEN_I32 = 60,
  TOKEN_BOOL = 61,
  TOKEN_U8 = 62,
  TOKEN_U32 = 63,
  TOKEN_U64 = 64,
  TOKEN_I64 = 65,
  TOKEN_USIZE = 66,
  TOKEN_ISIZE = 67,
  TOKEN_F32 = 77,
  TOKEN_F64 = 78,
  TOKEN_VOID = 79
};

int32_t parser_asm_is_pointee_type_token_c(int32_t kind) {
  if (kind == TOKEN_IDENT) {
    return 1;
  }
  if (kind == TOKEN_I32 || kind == TOKEN_I64 || kind == TOKEN_BOOL) {
    return 1;
  }
  if (kind == TOKEN_U8 || kind == TOKEN_U32 || kind == TOKEN_U64) {
    return 1;
  }
  if (kind == TOKEN_USIZE || kind == TOKEN_ISIZE || kind == TOKEN_VOID) {
    return 1;
  }
  if (kind == TOKEN_F32 || kind == TOKEN_F64) {
    return 1;
  }
  return 0;
}
