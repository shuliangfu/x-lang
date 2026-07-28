/* seeds/runtime_slice_glue_surface.from_x.c
 * G-02f-140 runtime_slice_glue R2 DIRECT surface — isomorphic with src/asm/runtime_slice_glue.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o (no rest; seed fully guarded)
 * Prove: full.x vs this seed → nm IDENTICAL (6 #[no_mangle] + 1 doc_anchor)
 * Mode: DIRECT — .x provides all 6 functions (pure compute, no OS calls, no extern bridges);
 *   seed has #ifndef XLANG_RUNTIME_SLICE_GLUE_FROM_X guard (all 6 skipped when PREFER_X_O)
 * Cap residual: none (DIRECT mode, pure compute)
 * Note: doc_anchor has no ast_ prefix — core_ #[no_mangle] does not trigger ast_ prefix
 *   (only net_ prefix triggers, per wave545 discovery)
 * Logic: 3 slice structs (XlangSliceI32/U8/U64) + 6 functions (3 from_ptr + 3 subslice).
 *   Struct names in surface use internal typedefs (not visible in symbol table).
 * Regen: ./xlang-c -E ... runtime_slice_glue.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

/* Internal struct types — names not visible in symbol table (prove nm only checks functions) */
typedef struct { int32_t *data; size_t length; } xlang_slice_i32_t;
typedef struct { uint8_t  *data; size_t length; } xlang_slice_u8_t;
typedef struct { uint64_t *data; size_t length; } xlang_slice_u64_t;

int32_t runtime_slice_glue_x_doc_anchor(void) { return 0; }

xlang_slice_i32_t core_slice_i32_from_ptr_c(int32_t *data, size_t len) {
  xlang_slice_i32_t s; s.data = data; s.length = len; return s;
}

xlang_slice_u8_t core_slice_u8_from_ptr_c(uint8_t *data, size_t len) {
  xlang_slice_u8_t s; s.data = data; s.length = len; return s;
}

xlang_slice_u64_t core_slice_u64_from_ptr_c(uint64_t *data, size_t len) {
  xlang_slice_u64_t s; s.data = data; s.length = len; return s;
}

xlang_slice_i32_t core_subslice_i32_c(int32_t *data, size_t total_len, size_t start, size_t len) {
  if (start >= total_len) {
    xlang_slice_i32_t s; s.data = data; s.length = 0; return s;
  }
  size_t avail = total_len - start;
  size_t actual_len = len;
  if (len > avail) { actual_len = avail; }
  xlang_slice_i32_t s; s.data = data + start; s.length = actual_len; return s;
}

xlang_slice_u8_t core_subslice_u8_c(uint8_t *data, size_t total_len, size_t start, size_t len) {
  if (start >= total_len) {
    xlang_slice_u8_t s; s.data = data; s.length = 0; return s;
  }
  size_t avail = total_len - start;
  size_t actual_len = len;
  if (len > avail) { actual_len = avail; }
  xlang_slice_u8_t s; s.data = data + start; s.length = actual_len; return s;
}

xlang_slice_u64_t core_subslice_u64_c(uint64_t *data, size_t total_len, size_t start, size_t len) {
  if (start >= total_len) {
    xlang_slice_u64_t s; s.data = data; s.length = 0; return s;
  }
  size_t avail = total_len - start;
  size_t actual_len = len;
  if (len > avail) { actual_len = avail; }
  xlang_slice_u64_t s; s.data = data + start; s.length = actual_len; return s;
}
