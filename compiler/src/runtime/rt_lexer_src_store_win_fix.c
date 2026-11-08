/* Win tip-cold fix: lexer_src_park_pe.s data_store/len_store were getters
 * (movq g→%rax; ret) but .x callers pass out:*u8 expecting *out = parked.
 * parked stayed null → lexer empty src → SEGV in lexer_skip_whitespace.
 * Strong T park+store+BSS in one TU before pe.s / hollow (PE first-win).
 * PLATFORM: WINDOWS. */
#include <stdint.h>

static uint8_t *g_lex_src_data_fix;
static uint64_t g_lex_src_len_fix;

void lexer_src_park(uint8_t *data, int32_t len) {
  g_lex_src_data_fix = data;
  g_lex_src_len_fix = (uint64_t)(int64_t)len;
}

void lexer_src_data_store(uint8_t *out) {
  if (out) {
    *(uint8_t **)out = g_lex_src_data_fix;
  }
}

void lexer_src_len_store(uint8_t *out) {
  if (out) {
    *(uint64_t *)out = g_lex_src_len_fix;
  }
}
