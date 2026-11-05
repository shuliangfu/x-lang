/**
 * PLATFORM: MACOS|DARWIN arm64 tip PE only —
 * tip_l4_tip_pe_println_method_call_p001 follow-on.
 *
 * Tip finalize twin correctly calls tip normalize; tip normalize returns 0
 * for path "std.fmt" n=7 (Cap returns 7). validate tip returns 1 for the
 * same bytes — tip normalize body hollow/wrong. Soft Cap Prefer banned.
 * Twin from src/asm/pthin_stretch.x normalize (+ inline ident_continue_ok).
 */
#include <stddef.h>
#include <stdint.h>

extern int32_t parser_asm_stretch_import_path_validate_c(uint8_t *path_buf, int32_t path_len);

static int32_t stretch_ident_continue_ok(uint8_t c) {
  if (c == 95)
    return 1;
  if (c >= 48 && c <= 57)
    return 1;
  if (c >= 65 && c <= 90)
    return 1;
  if (c >= 97 && c <= 122)
    return 1;
  return 0;
}

int32_t parser_asm_stretch_import_path_normalize_c(uint8_t *path_buf, int32_t path_len) {
  int32_t i;
  int32_t out_len;
  uint8_t c;
  uint8_t last;

  if (!path_buf || path_len <= 0)
    return 0;
  if (path_len > 63)
    path_len = 63;
  if (parser_asm_stretch_import_path_validate_c(path_buf, path_len) == 0)
    return 0;
  i = 0;
  out_len = 0;
  while (i < path_len) {
    c = path_buf[i];
    if (c == 0)
      break;
    if (c == 46) {
      path_buf[out_len] = c;
      out_len++;
    } else if (stretch_ident_continue_ok(c) != 0) {
      path_buf[out_len] = c;
      out_len++;
    }
    i++;
  }
  while (out_len > 0) {
    last = path_buf[out_len - 1];
    if (last != 46)
      break;
    out_len--;
  }
  return out_len;
}
