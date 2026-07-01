#include <stdarg.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

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

__attribute__((weak)) int32_t lsp_diag_lsp_build_diagnostics_response(int32_t id_val, uint8_t *source, int32_t source_len,
                                                                      uint8_t *out_buf, int32_t out_cap) {
  (void)id_val;
  (void)source;
  (void)source_len;
  (void)out_buf;
  (void)out_cap;
  return -1;
}

__attribute__((weak)) int32_t lsp_diag_lsp_build_semantic_tokens_response(int32_t id_val, uint8_t *doc_buf, int32_t doc_len,
                                                                         uint8_t *out_buf, int32_t out_cap) {
  (void)id_val;
  (void)doc_buf;
  (void)doc_len;
  (void)out_buf;
  (void)out_cap;
  return -1;
}

__attribute__((weak)) int32_t lsp_diag_hover_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                                uint8_t *out_buf, int32_t out_cap) {
  (void)source;
  (void)source_len;
  (void)line_0;
  (void)col_0;
  (void)out_buf;
  (void)out_cap;
  return -1;
}

__attribute__((weak)) int32_t lsp_diag_references_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                                     int32_t *out_lines, int32_t *out_cols, int32_t max_refs) {
  (void)source;
  (void)source_len;
  (void)line_0;
  (void)col_0;
  (void)out_lines;
  (void)out_cols;
  (void)max_refs;
  return -1;
}

__attribute__((weak)) int32_t lsp_diag_definition_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                                     int32_t *out_line, int32_t *out_col) {
  (void)source;
  (void)source_len;
  (void)line_0;
  (void)col_0;
  (void)out_line;
  (void)out_col;
  return -1;
}

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

static int32_t shux_append_asmf(struct codegen_CodegenOutBuf *out, const char *fmt, ...) {
  char buf[128];
  int n;
  va_list ap;
  va_start(ap, fmt);
  n = vsnprintf(buf, sizeof(buf), fmt, ap);
  va_end(ap);
  if (n < 0 || (size_t)n >= sizeof(buf))
    return -1;
  return append_asm_line(out, (uint8_t *)buf, n);
}

static const char *shux_x86_setcc_name(int32_t cc) {
  switch (cc) {
  case 1:
    return "setne";
  case 2:
    return "setl";
  case 3:
    return "setle";
  case 4:
    return "setg";
  case 5:
    return "setge";
  default:
    return "sete";
  }
}

static const char *shux_x86_arg_reg_name(int32_t k) {
  static const char *const regs[] = {"rdi", "rsi", "rdx", "rcx", "r8", "r9"};
  if (k < 0)
    k = 0;
  if (k > 5)
    k = 5;
  return regs[k];
}

__attribute__((weak)) int32_t arch_x86_64_emit_prologue(struct codegen_CodegenOutBuf *out, int32_t frame_sz) {
  if (frame_sz < 0)
    frame_sz = 0;
  if (shux_append_asmf(out, "pushq %%rbp") != 0)
    return -1;
  if (shux_append_asmf(out, "movq %%rsp, %%rbp") != 0)
    return -1;
  return shux_append_asmf(out, "subq $%d, %%rsp", frame_sz);
}

__attribute__((weak)) int32_t arch_x86_64_emit_epilogue(struct codegen_CodegenOutBuf *out, int32_t frame_sz) {
  (void)frame_sz;
  if (shux_append_asmf(out, "movq %%rsp, %%rbp") != 0)
    return -1;
  return shux_append_asmf(out, "ret");
}

__attribute__((weak)) int32_t arch_x86_64_emit_ret_imm32(struct codegen_CodegenOutBuf *out, int32_t imm) {
  return shux_append_asmf(out, "movl $%d, %%eax", imm);
}

__attribute__((weak)) int32_t arch_x86_64_emit_mov_imm32_to_rbx(struct codegen_CodegenOutBuf *out, int32_t imm) {
  return shux_append_asmf(out, "movl $%d, %%ebx", imm);
}

__attribute__((weak)) int32_t arch_x86_64_emit_mov_imm64_to_rax(struct codegen_CodegenOutBuf *out, int32_t lo, int32_t hi) {
  return shux_append_asmf(out, "movq $0x%08x%08x, %%rax", (uint32_t)hi, (uint32_t)lo);
}

__attribute__((weak)) int32_t arch_x86_64_emit_mov_rax_to_arg_reg(struct codegen_CodegenOutBuf *out, int32_t k) {
  return shux_append_asmf(out, "movq %%rax, %%%s", shux_x86_arg_reg_name(k));
}

__attribute__((weak)) int32_t arch_x86_64_emit_call(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len) {
  return shux_append_asmf(out, "call %.*s", (int)name_len, (const char *)name);
}

__attribute__((weak)) int32_t arch_x86_64_emit_section_text(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, ".text");
}

__attribute__((weak)) int32_t arch_x86_64_emit_globl(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len) {
  return shux_append_asmf(out, ".globl %.*s", (int)name_len, (const char *)name);
}

__attribute__((weak)) int32_t arch_x86_64_emit_push_rax(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "pushq %%rax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_add_sp_imm(struct codegen_CodegenOutBuf *out, int32_t nbytes) {
  if (nbytes <= 0)
    return 0;
  return shux_append_asmf(out, "addq $%d, %%rsp", nbytes);
}

__attribute__((weak)) int32_t arch_x86_64_emit_pop_rbx(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "popq %%rbx");
}

__attribute__((weak)) int32_t arch_x86_64_emit_pop_rax(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "popq %%rax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_add_rax_rbx(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "addq %%rbx, %%rax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_sub_rbx_rax_then_mov(struct codegen_CodegenOutBuf *out) {
  if (shux_append_asmf(out, "subq %%rax, %%rbx") != 0)
    return -1;
  return shux_append_asmf(out, "movq %%rbx, %%rax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_imul_rbx_rax(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "imulq %%rbx, %%rax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_neg_eax(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "negl %%eax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_mov_rax_to_rbx(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "movq %%rax, %%rbx");
}

__attribute__((weak)) int32_t arch_x86_64_emit_mov_rbx_to_rax(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "movq %%rbx, %%rax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_cmp_rbx_rax(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "cmpl %%eax, %%ebx");
}

__attribute__((weak)) int32_t arch_x86_64_emit_cmp_setcc(struct codegen_CodegenOutBuf *out, int32_t cc) {
  if (shux_append_asmf(out, "cmpl %%eax, %%ebx") != 0)
    return -1;
  if (shux_append_asmf(out, "%s %%al", shux_x86_setcc_name(cc)) != 0)
    return -1;
  return shux_append_asmf(out, "movzbl %%al, %%eax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_not_eax(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "notl %%eax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_and_rbx_rax(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "andl %%ebx, %%eax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_or_rbx_rax(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "orl %%ebx, %%eax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_xor_rbx_rax(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "xorl %%ebx, %%eax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_mov_rbx_to_ecx(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "movl %%ebx, %%ecx");
}

__attribute__((weak)) int32_t arch_x86_64_emit_shl_cl_eax(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "sall %%cl, %%eax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_shr_cl_eax(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "shrl %%cl, %%eax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_sar_cl_eax(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "sarl %%cl, %%eax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_store_rax_to_rbp(struct codegen_CodegenOutBuf *out, int32_t off) {
  return shux_append_asmf(out, "movq %%rax, -%d(%%rbp)", off);
}

__attribute__((weak)) int32_t arch_x86_64_emit_load_rbp_to_rax(struct codegen_CodegenOutBuf *out, int32_t off) {
  return shux_append_asmf(out, "movq -%d(%%rbp), %%rax", off);
}

__attribute__((weak)) int32_t arch_x86_64_emit_lea_rbp_to_rax(struct codegen_CodegenOutBuf *out, int32_t off) {
  return shux_append_asmf(out, "leaq -%d(%%rbp), %%rax", off);
}

__attribute__((weak)) int32_t arch_x86_64_emit_rax_plus_rbx_scale1(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "leaq (%%rax,%%rbx,1), %%rax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_rax_plus_rbx_scale4(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "leaq (%%rax,%%rbx,4), %%rax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_rax_plus_rbx_scale8(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "leaq (%%rax,%%rbx,8), %%rax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_store_rax_to_rbx_indirect(struct codegen_CodegenOutBuf *out, int32_t elem_sz) {
  if (elem_sz == 1)
    return shux_append_asmf(out, "movb %%al, (%%rbx)");
  if (elem_sz == 4)
    return shux_append_asmf(out, "movl %%eax, (%%rbx)");
  return shux_append_asmf(out, "movq %%rax, (%%rbx)");
}

__attribute__((weak)) int32_t arch_x86_64_emit_load_32_from_rax(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "movl (%%rax), %%eax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_load_zext8_from_rax(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "movzbl (%%rax), %%eax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_add_imm_to_rax(struct codegen_CodegenOutBuf *out, int32_t imm) {
  if (imm == 0)
    return 0;
  return shux_append_asmf(out, "addq $%d, %%rax", imm);
}

__attribute__((weak)) int32_t arch_x86_64_emit_load_64_from_rax(struct codegen_CodegenOutBuf *out) {
  return shux_append_asmf(out, "movq (%%rax), %%rax");
}

__attribute__((weak)) int32_t arch_x86_64_emit_store_rax_to_rbx_offset(struct codegen_CodegenOutBuf *out, int32_t off,
                                                                       int32_t store_size) {
  if (store_size == 8)
    return shux_append_asmf(out, "movq %%rax, %d(%%rbx)", off);
  return shux_append_asmf(out, "movl %%eax, %d(%%rbx)", off);
}

__attribute__((weak)) int32_t arch_x86_64_emit_jz(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len) {
  if (shux_append_asmf(out, "test %%eax, %%eax") != 0)
    return -1;
  return shux_append_asmf(out, "je %.*s", (int)label_len, (const char *)label);
}

__attribute__((weak)) int32_t arch_x86_64_emit_jeq(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len) {
  return shux_append_asmf(out, "je %.*s", (int)label_len, (const char *)label);
}

__attribute__((weak)) int32_t arch_x86_64_emit_jnz(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len) {
  if (shux_append_asmf(out, "test %%eax, %%eax") != 0)
    return -1;
  return shux_append_asmf(out, "jne %.*s", (int)label_len, (const char *)label);
}

__attribute__((weak)) int32_t arch_x86_64_emit_jmp(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len) {
  return shux_append_asmf(out, "jmp %.*s", (int)label_len, (const char *)label);
}

__attribute__((weak)) int32_t arch_x86_64_emit_label(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len) {
  return shux_append_asmf(out, "%.*s:", (int)name_len, (const char *)name);
}

#define SHUX_ARCH_TEXT_STUB0(name) \
  __attribute__((weak)) int32_t name(struct codegen_CodegenOutBuf *out) { \
    (void)out; \
    return -1; \
  }

#define SHUX_ARCH_TEXT_STUB1(name, t1, a1) \
  __attribute__((weak)) int32_t name(struct codegen_CodegenOutBuf *out, t1 a1) { \
    (void)out; \
    (void)a1; \
    return -1; \
  }

#define SHUX_ARCH_TEXT_STUB2(name, t1, a1, t2, a2) \
  __attribute__((weak)) int32_t name(struct codegen_CodegenOutBuf *out, t1 a1, t2 a2) { \
    (void)out; \
    (void)a1; \
    (void)a2; \
    return -1; \
  }

SHUX_ARCH_TEXT_STUB1(arch_arm64_emit_add_imm_to_rax, int32_t, imm)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_add_rax_rbx)
SHUX_ARCH_TEXT_STUB1(arch_arm64_emit_add_sp_imm, int32_t, n)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_and_rbx_rax)
SHUX_ARCH_TEXT_STUB2(arch_arm64_emit_call, uint8_t *, name, int32_t, name_len)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_cmp_rbx_rax)
SHUX_ARCH_TEXT_STUB1(arch_arm64_emit_cmp_setcc, int32_t, cc)
SHUX_ARCH_TEXT_STUB1(arch_arm64_emit_epilogue, int32_t, frame_sz)
SHUX_ARCH_TEXT_STUB2(arch_arm64_emit_globl, uint8_t *, name, int32_t, name_len)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_imul_rbx_rax)
SHUX_ARCH_TEXT_STUB2(arch_arm64_emit_jeq, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_TEXT_STUB2(arch_arm64_emit_jmp, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_TEXT_STUB2(arch_arm64_emit_jnz, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_TEXT_STUB2(arch_arm64_emit_jz, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_TEXT_STUB2(arch_arm64_emit_label, uint8_t *, name, int32_t, name_len)
SHUX_ARCH_TEXT_STUB1(arch_arm64_emit_ldr_sp_offset_to_wi, int32_t, i)
SHUX_ARCH_TEXT_STUB1(arch_arm64_emit_lea_rbp_to_rax, int32_t, off)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_load_32_from_rax)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_load_64_from_rax)
SHUX_ARCH_TEXT_STUB1(arch_arm64_emit_load_rbp_to_rax, int32_t, off)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_load_zext8_from_rax)
SHUX_ARCH_TEXT_STUB1(arch_arm64_emit_mov_imm32_to_rbx, int32_t, imm)
SHUX_ARCH_TEXT_STUB2(arch_arm64_emit_mov_imm64_to_rax, int32_t, lo, int32_t, hi)
SHUX_ARCH_TEXT_STUB1(arch_arm64_emit_mov_rax_to_arg_reg, int32_t, k)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_mov_rax_to_rbx)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_mov_rbx_to_ecx)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_mov_rbx_to_rax)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_neg_eax)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_not_eax)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_or_rbx_rax)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_pop_rax)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_pop_rbx)
SHUX_ARCH_TEXT_STUB1(arch_arm64_emit_prologue, int32_t, frame_sz)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_push_rax)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_rax_plus_rbx_scale1)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_rax_plus_rbx_scale4)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_rax_plus_rbx_scale8)
SHUX_ARCH_TEXT_STUB1(arch_arm64_emit_ret_imm32, int32_t, imm)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_sar_cl_eax)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_section_text)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_shl_cl_eax)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_shr_cl_eax)
SHUX_ARCH_TEXT_STUB1(arch_arm64_emit_store_rax_to_rbp, int32_t, off)
SHUX_ARCH_TEXT_STUB1(arch_arm64_emit_store_rax_to_rbx_indirect, int32_t, elem_sz)
SHUX_ARCH_TEXT_STUB2(arch_arm64_emit_store_rax_to_rbx_offset, int32_t, offset, int32_t, store_size)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_sub_rbx_rax_then_mov)
SHUX_ARCH_TEXT_STUB0(arch_arm64_emit_xor_rbx_rax)

SHUX_ARCH_TEXT_STUB1(arch_riscv64_emit_add_imm_to_rax, int32_t, imm)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_add_rax_rbx)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_and_rbx_rax)
SHUX_ARCH_TEXT_STUB2(arch_riscv64_emit_call, uint8_t *, name, int32_t, name_len)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_cmp_rbx_rax)
SHUX_ARCH_TEXT_STUB1(arch_riscv64_emit_cmp_setcc, int32_t, cc)
SHUX_ARCH_TEXT_STUB1(arch_riscv64_emit_epilogue, int32_t, frame_sz)
SHUX_ARCH_TEXT_STUB2(arch_riscv64_emit_globl, uint8_t *, name, int32_t, name_len)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_imul_rbx_rax)
SHUX_ARCH_TEXT_STUB2(arch_riscv64_emit_jeq, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_TEXT_STUB2(arch_riscv64_emit_jmp, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_TEXT_STUB2(arch_riscv64_emit_jnz, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_TEXT_STUB2(arch_riscv64_emit_jz, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_TEXT_STUB2(arch_riscv64_emit_label, uint8_t *, name, int32_t, name_len)
SHUX_ARCH_TEXT_STUB1(arch_riscv64_emit_lea_rbp_to_rax, int32_t, off)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_load_32_from_rax)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_load_64_from_rax)
SHUX_ARCH_TEXT_STUB1(arch_riscv64_emit_load_rbp_to_rax, int32_t, off)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_load_zext8_from_rax)
SHUX_ARCH_TEXT_STUB1(arch_riscv64_emit_mov_imm32_to_rbx, int32_t, imm)
SHUX_ARCH_TEXT_STUB2(arch_riscv64_emit_mov_imm64_to_rax, int32_t, lo, int32_t, hi)
SHUX_ARCH_TEXT_STUB1(arch_riscv64_emit_mov_rax_to_arg_reg, int32_t, k)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_mov_rax_to_rbx)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_mov_rbx_to_ecx)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_mov_rbx_to_rax)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_neg_eax)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_not_eax)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_or_rbx_rax)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_pop_rax)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_pop_rbx)
SHUX_ARCH_TEXT_STUB1(arch_riscv64_emit_prologue, int32_t, frame_sz)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_push_rax)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_rax_plus_rbx_scale1)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_rax_plus_rbx_scale4)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_rax_plus_rbx_scale8)
SHUX_ARCH_TEXT_STUB1(arch_riscv64_emit_ret_imm32, int32_t, imm)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_sar_cl_eax)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_section_text)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_shl_cl_eax)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_shr_cl_eax)
SHUX_ARCH_TEXT_STUB1(arch_riscv64_emit_store_rax_to_rbp, int32_t, off)
SHUX_ARCH_TEXT_STUB1(arch_riscv64_emit_store_rax_to_rbx_indirect, int32_t, elem_sz)
SHUX_ARCH_TEXT_STUB2(arch_riscv64_emit_store_rax_to_rbx_offset, int32_t, offset, int32_t, store_size)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_sub_rbx_rax_then_mov)
SHUX_ARCH_TEXT_STUB0(arch_riscv64_emit_xor_rbx_rax)

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

#define SHUX_ARCH_ENC_STUB0(name)                                               \
  __attribute__((weak)) int32_t name(struct platform_elf_ElfCodegenCtx *elf_ctx) { \
    (void)elf_ctx;                                                              \
    return -1;                                                                  \
  }

#define SHUX_ARCH_ENC_STUB1(name, t1, a1)                                             \
  __attribute__((weak)) int32_t name(struct platform_elf_ElfCodegenCtx *elf_ctx, t1 a1) { \
    (void)elf_ctx;                                                                    \
    (void)a1;                                                                         \
    return -1;                                                                        \
  }

#define SHUX_ARCH_ENC_STUB2(name, t1, a1, t2, a2)                                             \
  __attribute__((weak)) int32_t name(struct platform_elf_ElfCodegenCtx *elf_ctx, t1 a1, t2 a2) { \
    (void)elf_ctx;                                                                           \
    (void)a1;                                                                                \
    (void)a2;                                                                                \
    return -1;                                                                               \
  }

#define SHUX_ARCH_ENC_STUB3(name, t1, a1, t2, a2, t3, a3)                                             \
  __attribute__((weak)) int32_t name(struct platform_elf_ElfCodegenCtx *elf_ctx, t1 a1, t2 a2, t3 a3) { \
    (void)elf_ctx;                                                                                    \
    (void)a1;                                                                                          \
    (void)a2;                                                                                          \
    (void)a3;                                                                                          \
    return -1;                                                                                         \
  }

SHUX_ARCH_ENC_STUB2(arch_arm64_enc_enc_jz, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_ENC_STUB2(arch_arm64_enc_enc_jnz, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_ENC_STUB2(arch_arm64_enc_enc_jne, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_ENC_STUB2(arch_arm64_enc_enc_jeq, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_ENC_STUB2(arch_arm64_enc_enc_jge, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_ENC_STUB2(arch_arm64_enc_enc_jmp, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_ENC_STUB3(arch_arm64_enc_enc_label, uint8_t *, name, int32_t, name_len, int32_t, is_func)
SHUX_ARCH_ENC_STUB1(arch_arm64_enc_enc_mov_rax_to_arg_reg, int32_t, k)
SHUX_ARCH_ENC_STUB1(arch_arm64_enc_enc_add_sp_imm12, int32_t, imm)
SHUX_ARCH_ENC_STUB1(arch_arm64_enc_enc_sub_sp_imm12, int32_t, imm)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_sub_rax_rbx)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_sub_rbx_rax_then_mov)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_test_eax_eax)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_test_rbx_rbx)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_xor_rbx_rax)
SHUX_ARCH_ENC_STUB1(arch_arm64_enc_enc_add_imm_to_rax, int32_t, imm)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_add_rax_rbx)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_and_rbx_rax)
SHUX_ARCH_ENC_STUB2(arch_arm64_enc_enc_call, uint8_t *, name, int32_t, name_len)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_cltd)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_cmp_rbx_rax)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_cmp_rax_rbx)
SHUX_ARCH_ENC_STUB1(arch_arm64_enc_enc_cmp_setcc_movzbl, int32_t, cc)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_epilogue)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_idiv_rbx)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_imul_rbx_rax)
SHUX_ARCH_ENC_STUB1(arch_arm64_enc_enc_lea_rbp_to_rax, int32_t, offset)
SHUX_ARCH_ENC_STUB1(arch_arm64_enc_enc_lea_rbp_to_rbx, int32_t, offset)
SHUX_ARCH_ENC_STUB1(arch_arm64_enc_enc_load_rbp_to_rax, int32_t, offset)
SHUX_ARCH_ENC_STUB1(arch_arm64_enc_enc_load_rbp_to_rbx, int32_t, offset)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_mov_edx_to_eax)
SHUX_ARCH_ENC_STUB1(arch_arm64_enc_enc_mov_imm32_to_rbx, int32_t, imm32)
SHUX_ARCH_ENC_STUB2(arch_arm64_enc_enc_mov_imm64_to_rax, int32_t, lo, int32_t, hi)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_mov_rax_to_rbx)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_mov_rbx_to_ecx)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_neg_eax)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_not_eax)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_or_rbx_rax)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_pop_rax)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_pop_rbx)
SHUX_ARCH_ENC_STUB1(arch_arm64_enc_enc_prologue, int32_t, frame_sz)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_push_rax)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_push_rbx)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_rax_plus_rbx_scale1)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_rax_plus_rbx_scale4)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_rax_plus_rbx_scale8)
SHUX_ARCH_ENC_STUB1(arch_arm64_enc_enc_ret_imm32, int32_t, imm32)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_sar_cl_eax)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_setz_movzbl_eax)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_shl_cl_eax)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_shr_cl_eax)
SHUX_ARCH_ENC_STUB1(arch_arm64_enc_enc_store_rax_to_rbp, int32_t, offset)
SHUX_ARCH_ENC_STUB2(arch_arm64_enc_enc_store_x_reg_to_rbp, int32_t, reg, int32_t, offset)
SHUX_ARCH_ENC_STUB1(arch_arm64_enc_enc_str_x0_sp_offset, int32_t, off_bytes)

SHUX_ARCH_ENC_STUB2(arch_riscv64_enc_enc_jz, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_ENC_STUB2(arch_riscv64_enc_enc_jnz, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_ENC_STUB2(arch_riscv64_enc_enc_jeq, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_ENC_STUB2(arch_riscv64_enc_enc_jge, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_ENC_STUB2(arch_riscv64_enc_enc_jmp, uint8_t *, label, int32_t, label_len)
SHUX_ARCH_ENC_STUB3(arch_riscv64_enc_enc_label, uint8_t *, name, int32_t, name_len, int32_t, is_func)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_mov_rax_to_arg_reg, int32_t, k)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_add_sp_imm12, int32_t, imm)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_add_imm_to_rax, int32_t, imm)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_add_rax_rbx)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_and_rbx_rax)
SHUX_ARCH_ENC_STUB2(arch_riscv64_enc_enc_call, uint8_t *, name, int32_t, name_len)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_cltd)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_cmp_rbx_rax)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_cmp_setcc_movzbl, int32_t, cc)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_epilogue)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_idiv_rbx)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_imul_rbx_rax)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_lea_rbp_to_rax, int32_t, offset)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_lea_rbp_to_rbx, int32_t, offset)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_load_rbp_to_rax, int32_t, offset)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_load_rbp_to_rbx, int32_t, offset)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_mov_edx_to_eax)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_mov_imm32_to_rbx, int32_t, imm32)
SHUX_ARCH_ENC_STUB2(arch_riscv64_enc_enc_mov_imm64_to_rax, int32_t, lo, int32_t, hi)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_mov_rax_to_rbx)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_mov_rbx_to_ecx)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_neg_eax)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_not_eax)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_or_rbx_rax)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_pop_rax)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_pop_rbx)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_prologue, int32_t, frame_sz)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_push_rax)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_push_rbx)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_rax_plus_rbx_scale1)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_rax_plus_rbx_scale4)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_rax_plus_rbx_scale8)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_ret_imm32, int32_t, imm32)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_sar_cl_eax)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_setz_movzbl_eax)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_shl_cl_eax)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_shr_cl_eax)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_store_rax_to_rbp, int32_t, offset)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_sub_rbx_rax_then_mov)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_test_eax_eax)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_test_rbx_rbx)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_xor_rbx_rax)

SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_load_32_from_rax)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_load_64_from_rax)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_load_zext8_from_rax)
SHUX_ARCH_ENC_STUB1(arch_arm64_enc_enc_add_imm_to_rbx, int32_t, imm)
SHUX_ARCH_ENC_STUB1(arch_arm64_enc_enc_load_rbp_to_x2, int32_t, offset)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_rbx_plus_x2_scale1)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_rbx_plus_x2_scale4)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_rbx_plus_x2_scale8)
SHUX_ARCH_ENC_STUB1(arch_arm64_enc_enc_store_rax_to_rbx_indirect, int32_t, elem_sz)
SHUX_ARCH_ENC_STUB2(arch_arm64_enc_enc_store_rax_to_rbx_offset, int32_t, offset, int32_t, store_size)
SHUX_ARCH_ENC_STUB0(arch_arm64_enc_enc_mov_rbx_to_rax)

SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_mul_rbx_a3)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_load_32_from_rax)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_load_64_from_rax)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_load_zext8_from_rax)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_store_rax_to_rbx_indirect, int32_t, elem_sz)
SHUX_ARCH_ENC_STUB2(arch_riscv64_enc_enc_store_rax_to_rbx_offset, int32_t, offset, int32_t, store_size)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_mov_rbx_to_rax)

SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_add_imm_to_rbx, int32_t, imm)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_sub_imm_from_rbx_index, int32_t, imm)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_add_rbx_a3)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_sub_rbx_a3)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_mul_a2_a3)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_mul_imm_to_rbx, int32_t, lit)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_mul_imm_to_a2, int32_t, lit)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_add_imm_to_a2, int32_t, imm)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_sub_imm_from_a2, int32_t, imm)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_load_rbp_to_a2, int32_t, offset)
SHUX_ARCH_ENC_STUB1(arch_riscv64_enc_enc_load_rbp_to_a3, int32_t, offset)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_add_a2_a3)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_sub_a2_a3)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_rsub_a2_a3)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_rsub_rbx_a3)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_rbx_plus_a2_scale1)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_rbx_plus_a2_scale4)
SHUX_ARCH_ENC_STUB0(arch_riscv64_enc_enc_rbx_plus_a2_scale8)
