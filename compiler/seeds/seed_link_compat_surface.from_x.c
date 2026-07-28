/* seeds/seed_link_compat_surface.from_x.c
 * G-02f-93 seed_link_compat R2 mixed surface - isomorphic with src/seed_link_compat.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/seed_link_compat.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (19 #[no_mangle])
 * Mode: mixed - 11 thin+rest forwards + 5 DIRECT stubs + 3 DIRECT compute
 * Cap residual: 20 extern bridges (lsp_io_lsp_* + lsp_main_impl + lsp_io_std_heap_* + std_sys_os_read_file_into
 *   + std_heap_free + pipeline_module_struct_layout_set_packed + asm_ctx_local_offset_at
 *   + pipeline_expr_kind_ord_at + pipeline_expr_field_access_base_ref + pipeline_expr_var_name_len/into
 *   + pipeline_module_num_funcs + pipeline_asm_module_func_name_len_at/copy64
 *   + pipeline_module_func_param_name_len_at/copy32)
 * No doc_anchor (seed_link_compat.x has none).
 * Note: typeck_/std_sys_/std_heap_/ast_/backend_/lsp_diag_/xlang_ prefix not trigger ast_ (confirmed wave545+).
 * Logic: 19 functions = 11 thin+rest + 5 DIRECT stubs (return -1) + 3 DIRECT compute.
 * Regen: ./xlang-c -E ... seed_link_compat.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern uint8_t *lsp_io_lsp_alloc(size_t size);
extern void lsp_io_lsp_free(uint8_t *ptr);
extern int32_t lsp_io_lsp_is_null(uint8_t *ptr);
extern int32_t lsp_main_impl(void);
extern uint8_t *lsp_io_std_heap_std_heap_alloc(size_t size);
extern uint8_t *lsp_io_std_heap_std_heap_alloc_zeroed(size_t size);
extern void lsp_io_std_heap_std_heap_free(uint8_t *ptr);
extern int32_t std_sys_os_read_file_into(uint8_t *path, uint8_t *buf, int32_t cap);
extern void std_heap_free(uint8_t *ptr);
extern void pipeline_module_struct_layout_set_packed(uint8_t *module, int32_t idx, int32_t v);
extern int32_t asm_ctx_local_offset_at(uint8_t *ctx, int32_t idx);
extern int32_t pipeline_expr_kind_ord_at(uint8_t *arena, int32_t er);
extern int32_t pipeline_expr_field_access_base_ref(uint8_t *arena, int32_t er);
extern int32_t pipeline_expr_var_name_len(uint8_t *arena, int32_t er);
extern void pipeline_expr_var_name_into(uint8_t *arena, int32_t er, uint8_t *out);
extern int32_t pipeline_module_num_funcs(uint8_t *mod);
extern int32_t pipeline_asm_module_func_name_len_at(uint8_t *mod, int32_t fi);
extern void pipeline_asm_module_func_name_copy64(uint8_t *mod, int32_t fi, uint8_t *dst);
extern int32_t pipeline_module_func_param_name_len_at(uint8_t *mod, int32_t func_idx, int32_t param_ix);
extern void pipeline_module_func_param_name_copy32(uint8_t *mod, int32_t func_idx, int32_t param_ix, uint8_t *dst);

/* === 11 thin+rest forwards === */

uint8_t *typeck_lsp_alloc(size_t size) {
  uint8_t *r = lsp_io_lsp_alloc(size);
  return r;
}

void typeck_lsp_free(uint8_t *ptr) {
  lsp_io_lsp_free(ptr);
}

int32_t typeck_lsp_is_null(uint8_t *ptr) {
  int32_t r = lsp_io_lsp_is_null(ptr);
  return r;
}

int32_t typeck_lsp_main_impl(void) {
  int32_t r = lsp_main_impl();
  return r;
}

uint8_t *typeck_std_heap_alloc(size_t size) {
  uint8_t *r = lsp_io_std_heap_std_heap_alloc(size);
  return r;
}

uint8_t *typeck_std_heap_alloc_zeroed(size_t size) {
  uint8_t *r = lsp_io_std_heap_std_heap_alloc_zeroed(size);
  return r;
}

void typeck_std_heap_free(uint8_t *ptr) {
  lsp_io_std_heap_std_heap_free(ptr);
}

int32_t std_sys_read_file_into(uint8_t *path, uint8_t *buf, int32_t cap) {
  int32_t r = std_sys_os_read_file_into(path, buf, cap);
  return r;
}

void std_heap_free_u8_ptr(uint8_t *ptr) {
  std_heap_free(ptr);
}

void ast_pipeline_module_struct_layout_set_packed(uint8_t *module, int32_t idx, int32_t v) {
  pipeline_module_struct_layout_set_packed(module, idx, v);
}

int32_t backend_asm_ctx_slot_offset(uint8_t *ctx, int32_t slot_idx) {
  int32_t r = asm_ctx_local_offset_at(ctx, slot_idx);
  return r;
}

/* === 5 DIRECT stubs (return -1) === */

int32_t lsp_diag_lsp_build_diagnostics_response(int32_t id_val, uint8_t *source, int32_t source_len, uint8_t *out_buf,
                                                int32_t out_cap) {
  return 0 - 1;
}

int32_t lsp_diag_lsp_build_semantic_tokens_response(int32_t id_val, uint8_t *doc_buf, int32_t doc_len, uint8_t *out_buf,
                                                    int32_t out_cap) {
  return 0 - 1;
}

int32_t lsp_diag_hover_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0, uint8_t *out_buf,
                          int32_t out_cap) {
  return 0 - 1;
}

int32_t lsp_diag_references_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0, int32_t *out_lines,
                               int32_t *out_cols, int32_t max_refs) {
  return 0 - 1;
}

int32_t lsp_diag_definition_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0, int32_t *out_line,
                               int32_t *out_col) {
  return 0 - 1;
}

/* === 3 DIRECT compute === */

int32_t xlang_expr_is_func_param_at(uint8_t *arena, uint8_t *mod, int32_t func_idx, int32_t expr_ref, int32_t param_ix) {
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  if (param_ix < 0) { return 0; }
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != 3) { return 0; }
  int32_t plen = pipeline_module_func_param_name_len_at(mod, func_idx, param_ix);
  int32_t vlen = pipeline_expr_var_name_len(arena, expr_ref);
  if (plen <= 0) { return 0; }
  if (plen != vlen) { return 0; }
  if (plen > 31) { return 0; }
  uint8_t pbuf[32] = {};
  uint8_t vbuf[64] = {};
  pipeline_module_func_param_name_copy32(mod, func_idx, param_ix, &pbuf[0]);
  pipeline_expr_var_name_into(arena, expr_ref, &vbuf[0]);
  int32_t k = 0;
  while (k < plen) {
    if (pbuf[k] != vbuf[k]) { return 0; }
    k = k + 1;
  }
  return 1;
}

int32_t xlang_expr_is_param0_field_access(uint8_t *arena, uint8_t *mod, int32_t func_idx, int32_t expr_ref) {
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  if (func_idx < 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != 44) { return 0; }
  int32_t base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
  return xlang_expr_is_func_param_at(arena, mod, func_idx, base_ref, 0);
}

int32_t xlang_module_func_index_by_name(uint8_t *mod, uint8_t *name, int32_t name_len) {
  if (mod == 0) { return 0 - 1; }
  if (name == 0) { return 0 - 1; }
  if (name_len <= 0) { return 0 - 1; }
  if (name_len > 63) { return 0 - 1; }
  int32_t nfuncs = pipeline_module_num_funcs(mod);
  int32_t fi = 0;
  while (fi < nfuncs) {
    int32_t flen = pipeline_asm_module_func_name_len_at(mod, fi);
    if (flen == name_len) {
      uint8_t fb[64] = {};
      pipeline_asm_module_func_name_copy64(mod, fi, &fb[0]);
      int32_t k = 0;
      int32_t ok = 1;
      while (k < name_len) {
        if (fb[k] != name[k]) { ok = 0; break; }
        k = k + 1;
      }
      if (ok != 0) { return fi; }
    }
    fi = fi + 1;
  }
  return 0 - 1;
}
