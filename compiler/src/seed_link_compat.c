#include <stddef.h>
#include <stdint.h>

struct ast_Module;
struct backend_AsmFuncCtx;

extern uint8_t *lsp_io_lsp_alloc(size_t size);
extern void lsp_io_lsp_free(uint8_t *ptr);
extern int32_t lsp_io_lsp_is_null(uint8_t *ptr);
extern ptrdiff_t lsp_io_read_message(int32_t fd, uint8_t *body_out, int32_t body_cap, uint8_t *state_buf);

extern int32_t lsp_main_impl(void);
extern int32_t lsp_diag_lsp_build_diagnostics_response(int32_t id_val, uint8_t *source, int32_t source_len,
                                                       uint8_t *out_buf, int32_t out_cap);
extern int32_t lsp_diag_lsp_build_semantic_tokens_response(int32_t id_val, uint8_t *doc_buf, int32_t doc_len,
                                                           uint8_t *out_buf, int32_t out_cap);
extern int32_t lsp_diag_hover_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                 uint8_t *out_buf, int32_t out_cap);
extern int32_t lsp_diag_references_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                      int32_t *out_lines, int32_t *out_cols, int32_t max_refs);
extern int32_t lsp_diag_definition_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                      int32_t *out_line, int32_t *out_col);

extern uint8_t *lsp_io_std_heap_std_heap_alloc(size_t size);
extern uint8_t *lsp_io_std_heap_std_heap_alloc_zeroed(size_t size);
extern void lsp_io_std_heap_std_heap_free(uint8_t *ptr);

extern int32_t std_sys_os_read_file_into(uint8_t *path, uint8_t *buf, int32_t cap);
extern void std_heap_free(void *ptr);
extern int32_t std_io_read(size_t handle, uint8_t *ptr, size_t len, uint32_t timeout_ms);
extern int32_t std_io_write(size_t handle, uint8_t *ptr, size_t len, uint32_t timeout_ms);
extern void pipeline_module_struct_layout_set_packed(struct ast_Module *module, int32_t idx, int32_t v);
extern int32_t asm_ctx_local_offset_at(uint8_t *ctx, int32_t idx);

__attribute__((weak)) uint8_t *typeck_lsp_alloc(size_t size) {
  return lsp_io_lsp_alloc(size);
}

__attribute__((weak)) void typeck_lsp_free(uint8_t *ptr) {
  lsp_io_lsp_free(ptr);
}

__attribute__((weak)) int32_t typeck_lsp_is_null(uint8_t *ptr) {
  return lsp_io_lsp_is_null(ptr);
}

__attribute__((weak)) ptrdiff_t typeck_read_message(int32_t fd, uint8_t *body_out, int32_t body_cap, uint8_t *state_buf) {
  return lsp_io_read_message(fd, body_out, body_cap, state_buf);
}

__attribute__((weak)) int32_t typeck_lsp_main_impl(void) {
  return lsp_main_impl();
}

__attribute__((weak)) int32_t typeck_lsp_build_diagnostics_response(int32_t id_val, uint8_t *source, int32_t source_len,
                                                                    uint8_t *out_buf, int32_t out_cap) {
  return lsp_diag_lsp_build_diagnostics_response(id_val, source, source_len, out_buf, out_cap);
}

__attribute__((weak)) int32_t typeck_lsp_build_semantic_tokens_response(int32_t id_val, uint8_t *doc_buf, int32_t doc_len,
                                                                        uint8_t *out_buf, int32_t out_cap) {
  return lsp_diag_lsp_build_semantic_tokens_response(id_val, doc_buf, doc_len, out_buf, out_cap);
}

__attribute__((weak)) int32_t typeck_lsp_diag_hover_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                                       uint8_t *out_buf, int32_t out_cap) {
  return lsp_diag_hover_at(source, source_len, line_0, col_0, out_buf, out_cap);
}

__attribute__((weak)) int32_t typeck_lsp_diag_references_at(uint8_t *source, int32_t source_len, int32_t line_0,
                                                            int32_t col_0, int32_t *out_lines, int32_t *out_cols,
                                                            int32_t max_refs) {
  return lsp_diag_references_at(source, source_len, line_0, col_0, out_lines, out_cols, max_refs);
}

__attribute__((weak)) int32_t typeck_lsp_diag_definition_at(uint8_t *source, int32_t source_len, int32_t line_0,
                                                            int32_t col_0, int32_t *out_line, int32_t *out_col) {
  return lsp_diag_definition_at(source, source_len, line_0, col_0, out_line, out_col);
}

__attribute__((weak)) uint8_t *typeck_std_heap_alloc(size_t size) {
  return lsp_io_std_heap_std_heap_alloc(size);
}

__attribute__((weak)) uint8_t *typeck_std_heap_alloc_zeroed(size_t size) {
  return lsp_io_std_heap_std_heap_alloc_zeroed(size);
}

__attribute__((weak)) void typeck_std_heap_free(uint8_t *ptr) {
  lsp_io_std_heap_std_heap_free(ptr);
}

__attribute__((weak)) int32_t std_sys_read_file_into(uint8_t *path, uint8_t *buf, int32_t cap) {
  return std_sys_os_read_file_into(path, buf, cap);
}

__attribute__((weak)) void std_heap_free_u8_ptr(uint8_t *ptr) {
  std_heap_free(ptr);
}

__attribute__((weak)) int32_t std_io_read_usize_u8_ptr_usize_u32(size_t handle, uint8_t *ptr, size_t len,
                                                                 uint32_t timeout_ms) {
  return std_io_read(handle, ptr, len, timeout_ms);
}

__attribute__((weak)) int32_t std_io_write_usize_u8_ptr_usize_u32(size_t handle, uint8_t *ptr, size_t len,
                                                                  uint32_t timeout_ms) {
  return std_io_write(handle, ptr, len, timeout_ms);
}

__attribute__((weak)) void ast_pipeline_module_struct_layout_set_packed(struct ast_Module *module, int32_t idx, int32_t v) {
  pipeline_module_struct_layout_set_packed(module, idx, v);
}

__attribute__((weak)) int32_t backend_asm_ctx_slot_offset(struct backend_AsmFuncCtx *ctx, int32_t slot_idx) {
  return asm_ctx_local_offset_at((uint8_t *)ctx, slot_idx);
}
