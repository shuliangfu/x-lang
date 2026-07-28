/* seeds/runtime_sync_lock_diag_tls_surface.from_x.c
 * G-02f-142 runtime_sync_lock_diag_tls R2 thin surface — isomorphic with src/asm/runtime_sync_lock_diag_tls.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_SYNC_LOCK_DIAG_TLS_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (5 #[no_mangle] + 1 doc_anchor)
 * Mode: mixed — 2 thin+rest (find_meta_idx + get_order) + 3 DIRECT (append_byte + append_lit + append_i32)
 * Cap residual: 2 _impl bridges in runtime_sync_lock_diag_tls.from_x.c (find_meta_idx + get_order —
 *   pthread_mutexattr protocol lookup + lock order metadata; rest functions have #ifndef guard)
 * Note: doc_anchor has no ast_ prefix — sync_ #[no_mangle] does not trigger ast_ prefix
 *   (only net_ prefix triggers, per wave545-546 discovery)
 * Logic: append_byte/lit/i32 are pure compute (DIRECT mode, no extern bridges);
 *   find_meta_idx/get_order are thin wrappers forwarding to _impl bridges.
 * Regen: ./xlang-c -E ... runtime_sync_lock_diag_tls.x | filter DBG + polish prologue
 */
#include <stdint.h>

extern int32_t sync_lock_diag_find_meta_idx_impl(uint8_t *m);
extern int32_t sync_lock_diag_get_order_impl(uint8_t *m);

int32_t runtime_sync_lock_diag_tls_x_doc_anchor(void) { return 0; }

int32_t sync_lock_diag_find_meta_idx(uint8_t *m) {
  return sync_lock_diag_find_meta_idx_impl(m);
}

int32_t sync_lock_diag_get_order(uint8_t *m) {
  return sync_lock_diag_get_order_impl(m);
}

int32_t sync_lock_diag_append_byte(uint8_t *out, int32_t pos, int32_t cap, uint8_t b) {
  if (out == 0) { return -1; }
  if (pos < 0) { return -1; }
  if (pos >= cap) { return -1; }
  out[pos] = b;
  return pos + 1;
}

int32_t sync_lock_diag_append_lit(uint8_t *out, int32_t pos, int32_t cap, uint8_t *s, int32_t n) {
  int32_t i = 0;
  while (i < n) {
    pos = sync_lock_diag_append_byte(out, pos, cap, s[i]);
    if (pos < 0) { return -1; }
    i = i + 1;
  }
  return pos;
}

int32_t sync_lock_diag_append_i32(uint8_t *out, int32_t pos, int32_t cap, int32_t v) {
  if (out == 0) { return -1; }
  if (pos < 0) { return -1; }
  if (cap <= pos) { return -1; }
  if (v == 0) {
    return sync_lock_diag_append_byte(out, pos, cap, 48);
  }
  int32_t x = v;
  if (x < 0) {
    pos = sync_lock_diag_append_byte(out, pos, cap, 45);
    if (pos < 0) { return -1; }
    x = -x;
  }
  int32_t d0 = 0, d1 = 0, d2 = 0, d3 = 0, d4 = 0;
  int32_t d5 = 0, d6 = 0, d7 = 0, d8 = 0, d9 = 0;
  int32_t n = 0;
  while (x > 0) {
    int32_t dig = x - (x / 10) * 10;
    if (n == 0) { d0 = dig; }
    if (n == 1) { d1 = dig; }
    if (n == 2) { d2 = dig; }
    if (n == 3) { d3 = dig; }
    if (n == 4) { d4 = dig; }
    if (n == 5) { d5 = dig; }
    if (n == 6) { d6 = dig; }
    if (n == 7) { d7 = dig; }
    if (n == 8) { d8 = dig; }
    if (n == 9) { d9 = dig; }
    n = n + 1;
    x = x / 10;
  }
  while (n > 0) {
    n = n - 1;
    int32_t dig = 0;
    if (n == 0) { dig = d0; }
    if (n == 1) { dig = d1; }
    if (n == 2) { dig = d2; }
    if (n == 3) { dig = d3; }
    if (n == 4) { dig = d4; }
    if (n == 5) { dig = d5; }
    if (n == 6) { dig = d6; }
    if (n == 7) { dig = d7; }
    if (n == 8) { dig = d8; }
    if (n == 9) { dig = d9; }
    uint8_t ch = (uint8_t)(dig + 48);
    pos = sync_lock_diag_append_byte(out, pos, cap, ch);
    if (pos < 0) { return -1; }
  }
  return pos;
}
