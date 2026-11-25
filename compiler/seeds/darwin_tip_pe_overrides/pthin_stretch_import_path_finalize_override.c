/**
 * PLATFORM: MACOS|DARWIN arm64 tip PE only —
 * tip_l4_tip_pe_println_method_call_p001 follow-on.
 *
 * Tip PE hollows parser_asm_stretch_import_path_finalize_c (0 bl vs Cap
 * normalize+skip_ws+validate). Collect twin reaches finalize with path
 * "std.fmt" n=7; tip returns 0 → no import_alloc → fmt unbound → typeck
 * fail → tip-only diag hang. Soft Cap Prefer / Cap aside / Win banned.
 * Twin from src/asm/pthin_stretch.x finalize.
 */
#include <stddef.h>
#include <stdint.h>

extern int32_t parser_asm_stretch_import_path_normalize_c(uint8_t *path_buf, int32_t path_len);
extern size_t parser_asm_stretch_skip_ws_and_comments_c(const uint8_t *source, size_t source_len,
                                                       size_t pos);
extern int32_t parser_asm_stretch_import_path_validate_c(uint8_t *path_buf, int32_t path_len);

int32_t parser_asm_stretch_import_path_finalize_c(uint8_t *path_buf, int32_t path_len,
                                                 uint8_t *source, size_t source_len) {
  int32_t nlen;
  size_t np;

  if (!path_buf || path_len <= 0)
    return 0;
  nlen = parser_asm_stretch_import_path_normalize_c(path_buf, path_len);
  if (nlen <= 0)
    return 0;
  if (source && source_len > 0) {
    np = parser_asm_stretch_skip_ws_and_comments_c(source, source_len, 0);
    if (np == source_len)
      return 0;
  }
  if (parser_asm_stretch_import_path_validate_c(path_buf, nlen) != 0)
    return nlen;
  return 0;
}
