/* Prefer-M2 Cap soft tiphead SoftCap named-struct name identity (10.69 DIG3).
 * Soft Cap SoftCap-green first-wins T body: end_pos - nlen then JMP *_buf_c.
 * tip thin_glue historically emits a bare JMP to *_buf_c (drops end_pos-nlen).
 * Host-cc this twin on Windows; g05_relink_env prepends pe_at_end_fix.o.
 * PLATFORM: WINDOWS | MSYS | MINGW. Matches tip.x pthin_lex_skip Prefer-M2 shield. */
#include <stdint.h>
#include <stddef.h>

extern void parser_asm_copy_slice_to_name64_buf_c(
    uint8_t *source, int32_t source_len, size_t start, int32_t nlen, uint8_t *out);

void parser_asm_copy_slice_to_name64_at_end_buf_c(
    uint8_t *source, int32_t source_len, size_t end_pos, int32_t nlen, uint8_t *out) {
  if (out == NULL || nlen <= 0 || source == NULL) {
    return;
  }
  size_t start = end_pos - (size_t)nlen;
  parser_asm_copy_slice_to_name64_buf_c(source, source_len, start, nlen, out);
}
