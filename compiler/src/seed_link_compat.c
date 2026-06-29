#include <stddef.h>
#include <stdint.h>

struct ast_Module;
struct backend_AsmFuncCtx;
struct platform_elf_ElfCodegenCtx;
struct codegen_CodegenOutBuf;

extern uint8_t *lsp_io_lsp_alloc(size_t size);
extern void lsp_io_lsp_free(uint8_t *ptr);
extern int32_t lsp_io_lsp_is_null(uint8_t *ptr);
extern ptrdiff_t lsp_io_read_message(int32_t fd, uint8_t *body_out, int32_t body_cap, uint8_t *state_buf);

extern int32_t lsp_main_impl(void);
extern int32_t lsp_diag_lsp_build_diagnostics_response(int32_t id_val, uint8_t *source, int32_t source_len,
                                                       uint8_t *out_buf, int32_t out_cap) __attribute__((weak));
extern int32_t lsp_diag_lsp_build_semantic_tokens_response(int32_t id_val, uint8_t *doc_buf, int32_t doc_len,
                                                           uint8_t *out_buf, int32_t out_cap) __attribute__((weak));
extern int32_t lsp_diag_hover_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                 uint8_t *out_buf, int32_t out_cap) __attribute__((weak));
extern int32_t lsp_diag_references_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                      int32_t *out_lines, int32_t *out_cols, int32_t max_refs)
    __attribute__((weak));
extern int32_t lsp_diag_definition_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                      int32_t *out_line, int32_t *out_col) __attribute__((weak));

extern uint8_t *lsp_io_std_heap_std_heap_alloc(size_t size);
extern uint8_t *lsp_io_std_heap_std_heap_alloc_zeroed(size_t size);
extern void lsp_io_std_heap_std_heap_free(uint8_t *ptr);

extern int32_t std_sys_os_read_file_into(uint8_t *path, uint8_t *buf, int32_t cap);
extern void std_heap_free(void *ptr);
extern ptrdiff_t io_read(int fd, uint8_t *buf, size_t count, unsigned timeout_ms);
extern ptrdiff_t io_write(int fd, uint8_t *buf, size_t count, unsigned timeout_ms);
extern void pipeline_module_struct_layout_set_packed(struct ast_Module *module, int32_t idx, int32_t v);
extern int32_t asm_ctx_local_offset_at(uint8_t *ctx, int32_t idx);
extern int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n);
extern int32_t pipeline_module_func_body_ref_at(struct ast_Module *m, int32_t func_index);
extern int32_t pipeline_module_num_funcs(struct ast_Module *mod);
extern int32_t pipeline_module_func_num_params_at(struct ast_Module *m, int32_t func_index);
extern int32_t pipeline_module_func_param_name_len_at(struct ast_Module *mod, int32_t func_idx, int32_t param_ix);
extern void pipeline_module_func_param_name_copy32(struct ast_Module *mod, int32_t func_idx, int32_t param_ix,
                                                   uint8_t *dst);
extern int32_t pipeline_asm_module_func_is_extern_at(struct ast_Module *m, int32_t func_index);
extern int32_t pipeline_asm_module_func_name_len_at(struct ast_Module *m, int32_t func_index);
extern void pipeline_asm_module_func_name_copy64(struct ast_Module *m, int32_t func_index, uint8_t *dst);
extern int32_t pipeline_asm_block_final_expr_ref_at(void *arena, int32_t br);
extern int32_t ast_ast_block_num_expr_stmts(void *arena, int32_t br);
extern int32_t ast_ast_block_expr_stmt_ref(void *arena, int32_t br, int32_t ei);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_unary_operand_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_binop_left_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_binop_right_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_int_val_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(void *arena, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_expr_call_num_args_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_arg_ref(void *arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_call_callee_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_base_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_field_access_name_into(void *arena, int32_t expr_ref, uint8_t *out);
extern int32_t append_asm_line(struct codegen_CodegenOutBuf *out, uint8_t *ptr, int32_t len);

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
  if (!lsp_diag_lsp_build_diagnostics_response)
    return -1;
  return lsp_diag_lsp_build_diagnostics_response(id_val, source, source_len, out_buf, out_cap);
}

__attribute__((weak)) int32_t typeck_lsp_build_semantic_tokens_response(int32_t id_val, uint8_t *doc_buf, int32_t doc_len,
                                                                        uint8_t *out_buf, int32_t out_cap) {
  if (!lsp_diag_lsp_build_semantic_tokens_response)
    return -1;
  return lsp_diag_lsp_build_semantic_tokens_response(id_val, doc_buf, doc_len, out_buf, out_cap);
}

__attribute__((weak)) int32_t typeck_lsp_diag_hover_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                                       uint8_t *out_buf, int32_t out_cap) {
  if (!lsp_diag_hover_at)
    return -1;
  return lsp_diag_hover_at(source, source_len, line_0, col_0, out_buf, out_cap);
}

__attribute__((weak)) int32_t typeck_lsp_diag_references_at(uint8_t *source, int32_t source_len, int32_t line_0,
                                                            int32_t col_0, int32_t *out_lines, int32_t *out_cols,
                                                            int32_t max_refs) {
  if (!lsp_diag_references_at)
    return -1;
  return lsp_diag_references_at(source, source_len, line_0, col_0, out_lines, out_cols, max_refs);
}

__attribute__((weak)) int32_t typeck_lsp_diag_definition_at(uint8_t *source, int32_t source_len, int32_t line_0,
                                                            int32_t col_0, int32_t *out_line, int32_t *out_col) {
  if (!lsp_diag_definition_at)
    return -1;
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
  return (int32_t)io_read((int)handle, ptr, len, (unsigned)timeout_ms);
}

__attribute__((weak)) int32_t std_io_write_usize_u8_ptr_usize_u32(size_t handle, uint8_t *ptr, size_t len,
                                                                  uint32_t timeout_ms) {
  return (int32_t)io_write((int)handle, ptr, len, (unsigned)timeout_ms);
}

__attribute__((weak)) void ast_pipeline_module_struct_layout_set_packed(struct ast_Module *module, int32_t idx, int32_t v) {
  pipeline_module_struct_layout_set_packed(module, idx, v);
}

__attribute__((weak)) int32_t backend_asm_ctx_slot_offset(struct backend_AsmFuncCtx *ctx, int32_t slot_idx) {
  return asm_ctx_local_offset_at((uint8_t *)ctx, slot_idx);
}

__attribute__((weak)) int32_t backend_fold_func_return_operand_ref(void *arena, struct ast_Module *mod, int32_t func_idx) {
  int32_t body_ref;
  int32_t fin;
  int32_t nes;
  int32_t found;
  int32_t op_ref;
  int32_t ei;
  int32_t er;
  int32_t op_e;

  if (!arena || !mod || func_idx < 0)
    return 0;
  body_ref = pipeline_module_func_body_ref_at(mod, func_idx);
  if (body_ref <= 0)
    return 0;
  fin = pipeline_asm_block_final_expr_ref_at(arena, body_ref);
  if (fin != 0) {
    if (pipeline_expr_kind_ord_at(arena, fin) == 41) {
      op_e = pipeline_expr_unary_operand_ref_at(arena, fin);
      if (op_e != 0)
        return op_e;
    }
    return fin;
  }
  nes = ast_ast_block_num_expr_stmts(arena, body_ref);
  found = 0;
  op_ref = 0;
  for (ei = 0; ei < nes; ei++) {
    er = ast_ast_block_expr_stmt_ref(arena, body_ref, ei);
    if (er > 0 && pipeline_expr_kind_ord_at(arena, er) == 41) {
      op_e = pipeline_expr_unary_operand_ref_at(arena, er);
      if (op_e != 0) {
        found = found + 1;
        op_ref = op_e;
      }
    }
  }
  return found == 1 ? op_ref : 0;
}

static int32_t shux_expr_is_func_param_at(void *arena, struct ast_Module *mod, int32_t func_idx, int32_t expr_ref,
                                          int32_t param_ix) {
  uint8_t pbuf[32];
  uint8_t vbuf[64];
  int32_t plen;
  int32_t vlen;
  int32_t k;

  if (!arena || !mod || expr_ref <= 0 || param_ix < 0 || pipeline_expr_kind_ord_at(arena, expr_ref) != 3)
    return 0;
  plen = pipeline_module_func_param_name_len_at(mod, func_idx, param_ix);
  vlen = pipeline_expr_var_name_len(arena, expr_ref);
  if (plen <= 0 || plen != vlen || plen > 31)
    return 0;
  pipeline_module_func_param_name_copy32(mod, func_idx, param_ix, pbuf);
  pipeline_expr_var_name_into(arena, expr_ref, vbuf);
  for (k = 0; k < plen; k++) {
    if (pbuf[k] != vbuf[k])
      return 0;
  }
  return 1;
}

static int32_t shux_expr_is_param0_field_access(void *arena, struct ast_Module *mod, int32_t func_idx, int32_t expr_ref) {
  if (!arena || !mod || func_idx < 0 || expr_ref <= 0 || pipeline_expr_kind_ord_at(arena, expr_ref) != 44)
    return 0;
  return shux_expr_is_func_param_at(arena, mod, func_idx, pipeline_expr_field_access_base_ref(arena, expr_ref), 0);
}

static int32_t shux_module_func_index_by_name(struct ast_Module *mod, uint8_t *name, int32_t name_len) {
  int32_t fi;
  int32_t flen;
  uint8_t fb[64];
  int32_t k;

  if (!mod || !name || name_len <= 0 || name_len > 63)
    return -1;
  for (fi = 0; fi < pipeline_module_num_funcs(mod); fi++) {
    flen = pipeline_asm_module_func_name_len_at(mod, fi);
    if (flen != name_len)
      continue;
    pipeline_asm_module_func_name_copy64(mod, fi, fb);
    for (k = 0; k < name_len; k++) {
      if (fb[k] != name[k])
        break;
    }
    if (k == name_len)
      return fi;
  }
  return -1;
}

__attribute__((weak)) int32_t backend_fold_func_returns_param0_field_sum(void *arena, struct ast_Module *mod,
                                                                         int32_t func_idx) {
  int32_t ret_ref;
  int32_t al;
  int32_t ar;

  ret_ref = backend_fold_func_return_operand_ref(arena, mod, func_idx);
  if (ret_ref <= 0 || pipeline_expr_kind_ord_at(arena, ret_ref) != 4)
    return 0;
  al = pipeline_expr_binop_left_ref_at(arena, ret_ref);
  ar = pipeline_expr_binop_right_ref_at(arena, ret_ref);
  if (!shux_expr_is_param0_field_access(arena, mod, func_idx, al))
    return 0;
  return shux_expr_is_param0_field_access(arena, mod, func_idx, ar) ? 1 : 0;
}

__attribute__((weak)) int32_t backend_fold_func_returns_param0_single_field(void *arena, struct ast_Module *mod,
                                                                            int32_t func_idx) {
  int32_t ret_ref = backend_fold_func_return_operand_ref(arena, mod, func_idx);
  if (ret_ref <= 0)
    return 0;
  return shux_expr_is_param0_field_access(arena, mod, func_idx, ret_ref);
}

__attribute__((weak)) int32_t backend_fold_func_x_plus_k_chain(void *arena, struct ast_Module *mod, int32_t func_idx,
                                                               int32_t depth) {
  int32_t ret_ref;
  int32_t right_ref;
  int32_t left_ref;
  int32_t arg0;
  int32_t callee_ref;
  int32_t clen;
  uint8_t cname[64];
  int32_t inner_fi;
  int32_t inner_k;
  int32_t addend;

  if (depth > 12 || !arena || !mod || func_idx < 0)
    return -1;
  if (pipeline_asm_module_func_is_extern_at(mod, func_idx) != 0)
    return -1;
  if (pipeline_module_func_num_params_at(mod, func_idx) != 1)
    return -1;
  ret_ref = backend_fold_func_return_operand_ref(arena, mod, func_idx);
  if (ret_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, ret_ref) != 4 && pipeline_expr_kind_ord_at(arena, ret_ref) != 51)
    return -1;
  right_ref = pipeline_expr_binop_right_ref_at(arena, ret_ref);
  if (pipeline_expr_kind_ord_at(arena, right_ref) != 0)
    return -1;
  addend = pipeline_expr_int_val_at(arena, right_ref);
  left_ref = pipeline_expr_binop_left_ref_at(arena, ret_ref);
  if (shux_expr_is_func_param_at(arena, mod, func_idx, left_ref, 0) != 0)
    return addend;
  if (pipeline_expr_kind_ord_at(arena, left_ref) != 48)
    return -1;
  if (pipeline_expr_call_num_args_at(arena, left_ref) != 1)
    return -1;
  arg0 = pipeline_expr_call_arg_ref(arena, left_ref, 0);
  if (shux_expr_is_func_param_at(arena, mod, func_idx, arg0, 0) == 0)
    return -1;
  callee_ref = pipeline_expr_call_callee_ref_at(arena, left_ref);
  if (callee_ref <= 0 || pipeline_expr_kind_ord_at(arena, callee_ref) != 3)
    return -1;
  clen = pipeline_expr_var_name_len(arena, callee_ref);
  if (clen <= 0 || clen > 63)
    return -1;
  pipeline_expr_var_name_into(arena, callee_ref, cname);
  inner_fi = shux_module_func_index_by_name(mod, cname, clen);
  if (inner_fi < 0)
    return -1;
  inner_k = backend_fold_func_x_plus_k_chain(arena, mod, inner_fi, depth + 1);
  if (inner_k < 0)
    return -1;
  return inner_k + addend;
}

__attribute__((weak)) int32_t arch_x86_64_emit_epilogue(struct codegen_CodegenOutBuf *out, int32_t frame_sz) {
  uint8_t line1[16] = {'m', 'o', 'v', 'q', ' ', '%', 'r', 's', 'p', ',', ' ', '%', 'r', 'b', 'p', 0};
  uint8_t line2[4] = {'r', 'e', 't', 0};
  (void)frame_sz;
  if (append_asm_line(out, line1, 15) != 0)
    return -1;
  return append_asm_line(out, line2, 3);
}

__attribute__((weak)) int32_t arch_x86_64_emit_prologue(struct codegen_CodegenOutBuf *out, int32_t frame_sz) {
  uint8_t line1[12] = {'p', 'u', 's', 'h', 'q', ' ', '%', 'r', 'b', 'p', 0, 0};
  uint8_t line2[16] = {'m', 'o', 'v', 'q', ' ', '%', 'r', 's', 'p', ',', ' ', '%', 'r', 'b', 'p', 0};
  uint8_t sub_buf[32] = {'s', 'u', 'b', 'q', ' ', '$', 0};
  int32_t n;

  if (append_asm_line(out, line1, 10) != 0)
    return -1;
  if (append_asm_line(out, line2, 15) != 0)
    return -1;
  if (frame_sz < 0)
    frame_sz = 0;
  n = 0;
  if (frame_sz == 0) {
    sub_buf[6] = '0';
    n = 1;
  } else {
    int32_t tmp = frame_sz;
    uint8_t digits[16];
    int32_t dn = 0;
    int32_t i;
    while (tmp > 0 && dn < 16) {
      digits[dn++] = (uint8_t)('0' + (tmp % 10));
      tmp /= 10;
    }
    for (i = dn - 1; i >= 0; i--)
      sub_buf[6 + n++] = digits[i];
  }
  sub_buf[6 + n] = ',';
  sub_buf[6 + n + 1] = ' ';
  sub_buf[6 + n + 2] = '%';
  sub_buf[6 + n + 3] = 'r';
  sub_buf[6 + n + 4] = 's';
  sub_buf[6 + n + 5] = 'p';
  return append_asm_line(out, sub_buf, 6 + n + 6);
}

__attribute__((weak)) int32_t arch_arm64_emit_epilogue(struct codegen_CodegenOutBuf *out, int32_t frame_sz) {
  (void)out;
  (void)frame_sz;
  return -1;
}

__attribute__((weak)) int32_t arch_riscv64_emit_prologue(struct codegen_CodegenOutBuf *out, int32_t frame_sz) {
  (void)out;
  (void)frame_sz;
  return -1;
}

__attribute__((weak)) int32_t arch_riscv64_emit_epilogue(struct codegen_CodegenOutBuf *out, int32_t frame_sz) {
  (void)out;
  (void)frame_sz;
  return -1;
}

__attribute__((weak)) int32_t arch_arm64_enc_enc_u32_le(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t val) {
  uint8_t bytes[4];
  bytes[0] = (uint8_t)(val & 255);
  bytes[1] = (uint8_t)((val >> 8) & 255);
  bytes[2] = (uint8_t)((val >> 16) & 255);
  bytes[3] = (uint8_t)((val >> 24) & 255);
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, bytes, 4) : -1;
}

#define SHUX_ARM64_GLUE_STUB1(name)                                    \
  __attribute__((weak)) int32_t name(struct platform_elf_ElfCodegenCtx *elf_ctx) { \
    (void)elf_ctx;                                                     \
    return -1;                                                         \
  }

#define SHUX_ARM64_GLUE_STUB3(name)                                                        \
  __attribute__((weak)) int32_t name(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t a, int32_t b) { \
    (void)elf_ctx;                                                                         \
    (void)a;                                                                               \
    (void)b;                                                                               \
    return -1;                                                                             \
  }

SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_rbx_to_x2)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_x2_to_rbx)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_rax_to_x2)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_x2_to_rax)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_rax_to_x9)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_x9_to_rax)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_rax_to_x10)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_x10_to_rax)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_rbx_to_x10)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_x10_to_rbx)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_rax_to_x11)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_x11_to_rax)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_rbx_to_x11)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_x11_to_rbx)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_rax_to_x12)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_x12_to_rax)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_rbx_to_x12)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_x12_to_rbx)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_rax_to_x13)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_x13_to_rax)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_rbx_to_x13)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_x13_to_rbx)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_rax_to_x14)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_x14_to_rax)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_rbx_to_x14)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_x14_to_rbx)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_rax_to_x15)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_x15_to_rax)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_rbx_to_x15)
SHUX_ARM64_GLUE_STUB1(arch_arm64_enc_enc_mov_x15_to_rbx)
SHUX_ARM64_GLUE_STUB3(arch_arm64_enc_enc_ldr_sp_slot_to_xreg)

#undef SHUX_ARM64_GLUE_STUB1
#undef SHUX_ARM64_GLUE_STUB3
