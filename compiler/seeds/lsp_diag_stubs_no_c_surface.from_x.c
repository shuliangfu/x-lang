/* seeds/lsp_diag_stubs_no_c_surface.from_x.c
 * G-02f-82 lsp_diag_stubs_no_c R2 DIRECT surface - isomorphic with src/lsp/lsp_diag_stubs_no_c.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/lsp_diag_stubs_no_c.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (4 #[no_mangle] + 1 doc_anchor)
 * Mode: DIRECT - 4 #[no_mangle] (lsp_diag_copy_text_impl + json_escape_str_impl + lsp_diag_copy_text + json_escape_str)
 *   lsp_diag_copy_text/json_escape_str forward to _impl functions (same module, both #[no_mangle])
 * Cap residual: none (pure compute, no extern bridges)
 * doc_anchor lsp_diag_stubs_no_c_x_doc_anchor (no ast_; no module prefix on doc_anchor).
 * Note: lsp_diag_/json_escape_ prefix not trigger ast_ (confirmed wave545+).
 * Logic: 4 DIRECT functions. seed 全守卫 #ifndef XLANG_LSP_DIAG_STUBS_NO_C_FROM_X.
 * Regen: ./xlang-c -E ... lsp_diag_stubs_no_c.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

int32_t lsp_diag_stubs_no_c_x_doc_anchor(void) { return 0; }

/* lsp_diag_copy_text_impl: DIRECT pure compute (null guards + byte copy loop) */
void lsp_diag_copy_text_impl(uint8_t *dst, int32_t cap, uint8_t *src) {
  if (dst == 0 || cap <= 0) { return; }
  if (src == 0) { dst[0] = 0; return; }
  int32_t n = 0;
  while (n + 1 < cap && src[n] != 0) {
    dst[n] = src[n];
    n = n + 1;
  }
  dst[n] = 0;
}

/* json_escape_str_impl: DIRECT pure compute (JSON escape: " \ → \, newline → \n, CR → \r, tab → \t) */
int32_t json_escape_str_impl(uint8_t *msg, uint8_t *out, int32_t out_cap) {
  int32_t k = 0;
  if (msg == 0 || out == 0 || out_cap <= 0) { return 0; }
  int32_t i = 0;
  uint8_t bs = 92;   /* backslash */
  uint8_t n_ch = 110; /* 'n' */
  uint8_t r_ch = 114; /* 'r' */
  uint8_t t_ch = 116; /* 't' */
  while (msg[i] != 0 && k < out_cap - 2) {
    uint8_t c = msg[i];
    if (c == 34 || c == 92) {
      if (k + 2 >= out_cap) { out[k] = 0; return k; }
      out[k] = bs; k = k + 1; out[k] = c; k = k + 1;
    } else if (c == 10) {
      if (k + 2 >= out_cap) { out[k] = 0; return k; }
      out[k] = bs; k = k + 1; out[k] = n_ch; k = k + 1;
    } else if (c == 13) {
      if (k + 2 >= out_cap) { out[k] = 0; return k; }
      out[k] = bs; k = k + 1; out[k] = r_ch; k = k + 1;
    } else if (c == 9) {
      if (k + 2 >= out_cap) { out[k] = 0; return k; }
      out[k] = bs; k = k + 1; out[k] = t_ch; k = k + 1;
    } else {
      out[k] = c; k = k + 1;
    }
    i = i + 1;
  }
  if (k < out_cap) { out[k] = 0; }
  return k;
}

/* lsp_diag_copy_text: DIRECT forward to lsp_diag_copy_text_impl (same module #[no_mangle]) */
void lsp_diag_copy_text(uint8_t *dst, int32_t cap, uint8_t *src) {
  lsp_diag_copy_text_impl(dst, cap, src);
}

/* json_escape_str: DIRECT forward to json_escape_str_impl (same module #[no_mangle]) */
int32_t json_escape_str(uint8_t *msg, uint8_t *out, int32_t out_cap) {
  return json_escape_str_impl(msg, out, out_cap);
}
