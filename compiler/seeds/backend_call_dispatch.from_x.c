/* G-02f-9 / R2 full（2026-07-14）：backend_call_dispatch 真迁
 * Logic source: src/asm/backend_call_dispatch.x
 * Product PREFER_X_O: g05_try_x_to_o(full.x) + rest (-DSHUX_BACKEND_CALL_DISPATCH_FROM_X) ld -r
 *   → src/asm/backend_call_dispatch.o
 * R2: full.x 吃满 CALL/emit/import 公共业务；FROM_X 下 rest 业务 T=0（仅 slice_marker）
 * 冷启动/无 PREFER：本文件完整 C 体（含 L2 thin hybrid 的 _impl 尾）
 * L2 thin hybrid（SHUX_L2_CALL_DISPATCH_THIN_FROM_X）仍作 full.x 失败时的回退路径。
 *
 * seeds/backend_call_dispatch.from_x.c — product backend dispatch TU (cold full C)
 */
#ifndef SHUX_BACKEND_CALL_DISPATCH_FROM_X
/* G-02f-364/368：PREFER hybrid thin 由 src/asm/backend_call_dispatch_thin.x；rest SHUX_L2_CALL_DISPATCH_THIN_FROM_X。
 * seeds/backend_call_dispatch.from_x.c — G-02f-9 product backend dispatch TU
 * G-02f-134 true .x pure helpers.
 * G-02f-133 true .x pure helpers.
 * G-02f-125 true .x pure helpers.
 * G-02f-123 true .x pure helpers.
 * G-02f-122 true .x pure helpers.
 * G-02f-121 true .x pure helpers.
 * G-02f-120 true .x pure helpers.
 * G-02f-114 true .x pure helpers.
 * G-02f-113 true .x pure helpers.
 * G-02f-110 helper gates.
 * G-02f-109 helper gates.
 * G-02f-108 helper gates.
 * G-02f-184: f32 xmm flags true .x; residual mega emit still dual.
 * Source intent: src/asm/backend_call_dispatch.x + this seed (product C body).
 * Product: → src/asm/backend_call_dispatch.o.
 */
/**
 * backend_call_dispatch.c — EXPR_CALL ELF 发射与 import 限定符号解析（C 实现）
 *
 * M8 自举：emit_expr_elf_call / emit_expr_elf_method_call / asm_emit_call_args_elf 等在 mega_entry 下为 ret0 桩；
 * 本 TU 供 pipeline_asm_emit_call_elf_c / pipeline_asm_emit_method_call_elf_c / pipeline_asm_emit_call_args_elf_c 真 emit。
 */
#include <stdint.h>

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "diag.h"
#include "runtime_pipeline_abi.h"
#ifdef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
struct ast_ASTArena;
struct ast_Module;
struct platform_elf_ElfCodegenCtx;
struct backend_AsmFuncCtx;
struct codegen_CodegenOutBuf;
int32_t glue_asm_call_reg_max(int32_t ta);
int32_t glue_asm_call_stack_cleanup_bytes(int32_t ta, int32_t nargs);
int32_t glue_asm_append_export_c_suffix(uint8_t *sym, int32_t sym_len, int32_t cap);
int32_t glue_asm_string_lit_len(struct ast_ASTArena *arena, int32_t expr_ref);
int32_t glue_call_param_type_ref_at(struct ast_ASTArena *arena, int32_t call_expr_ref, int32_t param_index);
int32_t glue_call_param_is_f32_c(struct ast_ASTArena *arena, int32_t type_ref);
int32_t glue_asm_c_prefix_redundant_with_name(const uint8_t *prefix, int32_t prefix_len, const uint8_t *name, int32_t name_len);
int32_t glue_asm_import_path_segment_count(const uint8_t *path, int32_t path_len);
int32_t glue_asm_import_path_slice_equal(struct ast_Module *module, int32_t imp_ix, int32_t off, int32_t seg_len, const uint8_t *nm, int32_t nm_len);
int32_t glue_asm_import_binding_name_equal(struct ast_Module *module, int32_t imp_ix, const uint8_t *nm, int32_t nm_len);
int32_t pipeline_asm_emit_get_call_f32_xmm_c(void);
int32_t glue_module_func_overload_count_c(struct ast_Module *m, const uint8_t *name, int32_t name_len);
int32_t glue_asm_std_c_wrapper_fname_needs_export_c_suffix(const uint8_t *fname, int32_t fname_len);
int32_t glue_asm_fill_c_prefix_from_module_import(struct ast_Module *cur_mod, int32_t imp_ix, uint8_t *pre_buf);
int32_t glue_asm_prefix_is_fmt_or_debug(const uint8_t *pre, int32_t pre_len);
int32_t glue_asm_import_segment_at(struct ast_Module *module, int32_t imp_ix, int32_t want_seg, int32_t *ostr, int32_t *olen);
int32_t glue_asm_build_import_binding_call_sym(const uint8_t *pre, int32_t pre_len, const uint8_t *field_name, int32_t field_len, uint8_t *out_name);
int32_t glue_try_std_string_shux_redirect_sym_local(const uint8_t *name, int32_t name_len, uint8_t *sym_out, int32_t out_cap);
int32_t glue_try_std_encoding_redirect_sym_local(const uint8_t *name, int32_t name_len, uint8_t *sym_out, int32_t out_cap);
int32_t glue_type_kind_to_suffix_c(int32_t kind_ord, uint8_t *out, int32_t out_cap);
int32_t glue_asm_emit_string_lit_ptr_rax_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t str_expr_ref, int32_t ta);
int32_t glue_sysv_x86_call_n_stack_c(struct ast_ASTArena *arena, int32_t call_expr_ref, int32_t nargs);
int32_t glue_asm_build_dep_export_sym_c(const uint8_t *name, int32_t name_len, uint8_t *out, int32_t out_cap);
int32_t glue_asm_enc_call_redirected(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len, int32_t ta);
int32_t glue_try_std_heap_redirect_sym_local(const uint8_t *name, int32_t name_len, uint8_t *sym_out, int32_t out_cap);
int32_t pipeline_asm_abi_f32_xmm_enabled_c(void);
int32_t glue_asm_build_func_export_sym_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t func_ix, uint8_t *out, int32_t out_cap);
int32_t glue_asm_emit_jmp_skip_string_then_lea(uint8_t *ctx_bytes, int32_t ta, int32_t reg_k, const uint8_t *sbuf, int32_t slen);
int32_t glue_spill_struct16_call_arg_to_lea_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, struct backend_AsmFuncCtx *ctx, int32_t pty, int32_t ta);
int32_t pipeline_asm_resolve_whole_import_qualified_symbol_c(struct ast_ASTArena *arena, struct ast_Module *cur_mod, int32_t callee_expr_ref, uint8_t *sym_flat, int32_t *out_match_imp_j);
int32_t pipeline_asm_emit_call_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
int32_t pipeline_asm_emit_method_call_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
int32_t pipeline_asm_emit_call_args_text_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out, int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t target_arch, int32_t nargs);
int32_t pipeline_asm_emit_call_args_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t nargs);
int32_t glue_emit_call_args_elf_sysv_f32_xmm_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t nargs);
int32_t glue_asm_emit_call_with_cleanup(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t nargs, uint8_t *cname, int32_t clen);
int32_t glue_emit_one_call_arg_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t call_expr_ref, int32_t arg_ref, int32_t arg_index, struct backend_AsmFuncCtx *ctx, int32_t ta);
int32_t glue_asm_build_call_export_sym_c(struct ast_ASTArena *arena, int32_t call_expr_ref, int32_t callee_ref, struct ast_Module *mod, struct ast_PipelineDepCtx *dep_pipe, uint8_t *out, int32_t out_cap);
int32_t glue_asm_try_emit_fmt_string_lit_import_call_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t call_expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta, const uint8_t *pre_buf, int32_t pre_len, const uint8_t *field_name, int32_t field_len);
void pipeline_asm_emit_set_call_f32_xmm(int32_t on);
void glue_codegen_import_path_to_c_prefix_into(const uint8_t *path, uint8_t *buf, int32_t buf_cap);
void glue_asm_string_lit_into(struct ast_ASTArena *arena, int32_t expr_ref, uint8_t *out64);
void glue_sysv_x86_call_arg_slot_c(struct ast_ASTArena *arena, int32_t call_expr_ref, int32_t nargs, int32_t arg_index, int32_t *out_kind, int32_t *out_reg_k, int32_t *out_stack_k);
int32_t glue_f32_xmm_flag_get_body(void);
#endif


static void backend_call_debugf(const char *fmt, ...) {
  char buf[256];
  va_list ap;
  if (!getenv("SHUX_ASM_DEBUG"))
    return;
  va_start(ap, fmt);
  (void)vsnprintf(buf, sizeof buf, fmt ? fmt : "asm call debug", ap);
  va_end(ap);
  buf[sizeof buf - 1] = '\0';
  diag_report(NULL, 0, 0, "note", buf, NULL);
}

extern const char *driver_get_current_dep_path_for_codegen(void);
extern int32_t pipeline_expr_call_resolved_dep_index_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_call_resolved_func_index_at(struct ast_ASTArena *a, int32_t expr_ref);
extern void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t j);
extern struct ast_ASTArena *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t j);
extern int32_t pipeline_module_num_funcs(struct ast_Module *m);
extern int32_t pipeline_module_func_name_equal_at(struct ast_Module *m, int32_t fi, uint8_t *name, int32_t name_len);
extern int32_t pipeline_asm_module_func_is_extern_at(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_asm_module_func_name_len_at(struct ast_Module *m, int32_t func_index);
extern void pipeline_asm_module_func_name_copy64(struct ast_Module *m, int32_t func_index, uint8_t *dst);
extern int32_t pipeline_module_func_num_params_at(struct ast_Module *m, int32_t func_idx);
extern int32_t pipeline_module_func_param_type_ref_at(struct ast_Module *m, int32_t fi, int32_t pi);
extern int32_t pipeline_module_func_return_type_at(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_type_elem_ref_at(struct ast_ASTArena *arena, int32_t type_ref);
extern int32_t pipeline_type_named_name_into(struct ast_ASTArena *arena, int32_t type_ref, uint8_t *out64);
extern struct ast_PipelineDepCtx *pipeline_asm_emit_dep_pipe_c(void);
extern int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_block_resolve_var_type_ref(struct ast_ASTArena *arena, int32_t block_ref, uint8_t *vname,
                                                    int32_t vlen);
extern int32_t asm_ctx_scope_block_ref_at(uint8_t *ctx);
extern int32_t pipeline_expr_var_name_len(struct ast_ASTArena *a, int32_t expr_ref);
extern void pipeline_expr_var_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64);
extern int32_t pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t pipeline_module_import_path_len(struct ast_Module *m, int32_t idx);
extern uint8_t pipeline_module_import_path_byte_at(struct ast_Module *m, int32_t idx, int32_t off);

struct ast_ASTArena;
struct ast_Module;
struct ast_Expr;
struct platform_elf_ElfCodegenCtx;
struct backend_AsmFuncCtx;
struct codegen_CodegenOutBuf;

/** 与 backend.x AsmFuncCtx 前缀一致（module_ref + dep_pipe）。 */
struct glue_AsmFuncCtxCall {
  int32_t frame_size;
  int32_t next_offset;
  int32_t num_locals;
  int32_t label_counter;
  struct ast_Module *module_ref;
  uint8_t loop_break_label_stack[512];
  int32_t loop_break_len_stack[8];
  uint8_t loop_continue_label_stack[512];
  int32_t loop_continue_len_stack[8];
  uint8_t break_label[64];
  int32_t break_len;
  uint8_t continue_label[64];
  int32_t continue_len;
  int32_t loop_label_depth;
  void *dep_pipe;
};

/** import ast.x ImportKind.IMPORT_BINDING */
#define GLUE_IMPORT_KIND_BINDING 1
/** parser_asm_primary_slice / ast.h AST_EXPR_STRING_LIT；内容在 var_name。 */
#define GLUE_EXPR_STRING_LIT_ORD 59
#define GLUE_EXPR_FIELD_ACCESS_ORD 44
#define GLUE_EXPR_VAR_ORD 3

extern int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n);
extern int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_callee_ref_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_num_args_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_arg_ref(struct ast_ASTArena *arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_var_name_len(struct ast_ASTArena *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(struct ast_ASTArena *arena, int32_t expr_ref, uint8_t *out);
extern struct ast_Expr *pipeline_arena_expr_ptr(struct ast_ASTArena *a, int32_t ref);
extern int32_t pipeline_expr_var_name_len_for_string_lit_c(struct ast_ASTArena *arena, int32_t expr_ref);

/** STRING_LIT（kind 59）字节长度。 */
/* G-02f-122：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_string_lit_len(struct ast_ASTArena *arena, int32_t expr_ref) {
  if (!arena || expr_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != GLUE_EXPR_STRING_LIT_ORD)
    return 0;
  return pipeline_expr_var_name_len_for_string_lit_c(arena, expr_ref);
}
#endif




/** 拷贝 STRING_LIT 内容到 out64（至多 63 字节）。 */
/* G-02f-139：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-380 call：_impl 返回 i32（供 thin -E）；public void 仍 seed-only 非 PREFER */
int32_t glue_asm_string_lit_into_impl(struct ast_ASTArena *arena, int32_t expr_ref, uint8_t *out64) {
  if (!out64)
    return 0;
  memset(out64, 0, 64);
  if (glue_asm_string_lit_len(arena, expr_ref) <= 0)
    return 0;
  pipeline_expr_var_name_into(arena, expr_ref, out64);
  return 0;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
void glue_asm_string_lit_into(struct ast_ASTArena *arena, int32_t expr_ref, uint8_t *out64) {
  (void)glue_asm_string_lit_into_impl(arena, expr_ref, out64);
}
#endif


/**
 * x86_64：jmp 跳过尾挂字面量，再 lea reg,[rip+disp] 指向字面量（避免字面量落在指令流中被执行）。
 * reg_k：0→rdi（fmt 实参 ptr），1→rax（*u8 表达式结果）。
 */
/* G-02f-143：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-375 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_asm_emit_jmp_skip_string_then_lea_impl(uint8_t *ctx_bytes, int32_t ta, int32_t reg_k,
    const uint8_t *sbuf, int32_t slen) {
  uint8_t jmp2[2];
  uint8_t lea7[7];
  uint8_t z;
  int32_t disp32;
  if (!ctx_bytes || !sbuf || slen <= 0 || slen > 63 || ta != 0)
    return -1;
  if (slen + 1 > 127)
    return -1;
  jmp2[0] = 0xeb;
  jmp2[1] = (uint8_t)(slen + 1);
  if (pipeline_elf_ctx_append_bytes(ctx_bytes, jmp2, 2) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes(ctx_bytes, (uint8_t *)sbuf, slen) != 0)
    return -1;
  z = 0;
  if (pipeline_elf_ctx_append_bytes(ctx_bytes, &z, 1) != 0)
    return -1;
  disp32 = -slen - 8;
  lea7[0] = 0x48;
  lea7[1] = 0x8d;
  lea7[2] = (uint8_t)(reg_k == 0 ? 0x3d : 0x05);
  lea7[3] = (uint8_t)(disp32);
  lea7[4] = (uint8_t)((uint32_t)disp32 >> 8);
  lea7[5] = (uint8_t)((uint32_t)disp32 >> 16);
  lea7[6] = (uint8_t)((uint32_t)disp32 >> 24);
  return pipeline_elf_ctx_append_bytes(ctx_bytes, lea7, 7);
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_emit_jmp_skip_string_then_lea(uint8_t *ctx_bytes, int32_t ta, int32_t reg_k,
    const uint8_t *sbuf, int32_t slen) {
  return glue_asm_emit_jmp_skip_string_then_lea_impl(ctx_bytes, ta, reg_k, sbuf, slen);
}
#endif

extern int32_t pipeline_expr_field_access_base_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_name_len(struct ast_ASTArena *a, int32_t expr_ref);
extern void pipeline_expr_field_access_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out);

extern int32_t pipeline_module_import_kind_at(struct ast_Module *m, int32_t idx);
extern int32_t pipeline_module_import_path_len(struct ast_Module *m, int32_t idx);
extern uint8_t pipeline_module_import_path_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t pipeline_module_import_binding_name_len(struct ast_Module *m, int32_t idx);
extern uint8_t pipeline_module_import_binding_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t pipeline_codegen_call_num_args_override(uint8_t *prefix, int32_t prefix_len, uint8_t *name,
                                                       int32_t name_len, int32_t num_args);
extern int32_t pipeline_asm_redirect_std_c_wrapper_sym(uint8_t *name, int32_t name_len, uint8_t *sym_out,
                                                         int32_t sym_cap);

extern void parser_get_module_import_path(void *module, int32_t i, uint8_t *out);
extern int32_t parser_get_module_num_imports(void *module);

extern void asm_qual_sym_layer_reset(void);
extern int32_t asm_qual_sym_layer_push(uint8_t *bytes, int32_t len);
extern int32_t asm_qual_sym_layer_count(void);
extern int32_t asm_qual_sym_layer_len(int32_t i);
extern void asm_qual_sym_layer_copy(int32_t i, uint8_t *dst, int32_t cap);

extern int32_t pipeline_asm_emit_expr_elf_for_call_args(struct ast_ASTArena *arena,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                        struct backend_AsmFuncCtx *ctx, int32_t ta);
extern void pipeline_asm_emit_set_call_param_type_ref(int32_t type_ref);
extern void pipeline_asm_emit_call_arg_begin_c(void);
extern void pipeline_asm_emit_call_arg_end_c(void);
extern int32_t pipeline_asm_call_param_type_ref_at_c(struct ast_ASTArena *arena, int32_t call_expr_ref,
                                                     int32_t param_index);
extern int32_t pipeline_asm_emit_expr_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out, int32_t expr_ref,
                                        struct backend_AsmFuncCtx *ctx, int32_t target_arch);
extern int32_t backend_arch_emit_mov_rax_to_arg_reg(struct codegen_CodegenOutBuf *out, int32_t k, int32_t ta);
extern int32_t backend_arch_emit_push_rax(struct codegen_CodegenOutBuf *out, int32_t ta);
extern int32_t backend_arch_emit_ldr_sp_offset_to_wi(struct codegen_CodegenOutBuf *out, int32_t i, int32_t ta);
extern int32_t backend_arch_emit_add_sp_imm(struct codegen_CodegenOutBuf *out, int32_t n, int32_t ta);

extern int32_t try_inline_param0_single_field_call_elf(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                       struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t try_inline_param0_field_sum_call_elf(struct ast_ASTArena *arena,
                                                    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                    struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t try_inline_x_plus_k_call_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t try_inline_wpo_const_scalar_binop_call_elf(struct ast_ASTArena *arena,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                          struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t try_inline_wpo_const_vector_lane_of_binop_call_elf(struct ast_ASTArena *arena,
                                                                  struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                  int32_t expr_ref, struct backend_AsmFuncCtx *ctx,
                                                                  int32_t ta);
extern int32_t try_call_wpo_mono_symbol_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t try_call_wpo_mono_vector_lane_of_binop_call_elf(struct ast_ASTArena *arena,
                                                               struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                               int32_t expr_ref, struct backend_AsmFuncCtx *ctx,
                                                               int32_t ta);

extern int32_t backend_enc_mov_rax_to_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_call_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len,
                                     int32_t ta);
extern int32_t backend_enc_push_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32, int32_t ta);
extern int32_t backend_enc_call_stack_cleanup_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t nbytes,
                                                   int32_t ta);
extern int32_t backend_enc_call_stack_reserve_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t nbytes,
                                                   int32_t ta);
extern int32_t backend_enc_store_x0_sp_offset_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_bytes,
                                                   int32_t ta);

/** bench stream_*_batch 等最多 11 实参；与 backend.x 6 参上限解耦。 */
/** 与 grow 池一致：>64 实参边界见 tests/pool-limits/many_call_args.x。 */
#define GLUE_ASM_MAX_CALL_ARGS 96

extern int32_t backend_enc_store_x0_sp_offset_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_bytes,
                                                   int32_t ta);
extern int32_t backend_enc_mov_eax_to_xmm_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                       int32_t ta);
extern int32_t backend_enc_mov_rax_to_xmm_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                       int32_t ta);
extern int32_t backend_enc_mov_xmm_arg_reg_to_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                       int32_t ta);
extern int32_t backend_enc_mov_xmm_arg_reg_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                       int32_t ta);
extern int32_t pipeline_asm_type_ref_byte_size_c(struct ast_ASTArena *arena, int32_t ty_ref);
extern int32_t pipeline_asm_deref_struct16_rax_ptr_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t pipeline_asm_call_struct16_ret_needs_rax_deref_c(struct ast_ASTArena *arena, int32_t call_expr_ref);
extern int32_t pipeline_asm_emit_call_sret_reg_shift_c(void);
extern int32_t backend_enc_store_rdx_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                 int32_t ta);
extern int32_t backend_enc_store_rax_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                 int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                               int32_t ta);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *arena, int32_t type_ref);

/* G-02e：原 pipeline_abi_f32_xmm.c 并入本 TU，去掉独立手写 C 文件。 */
/* G-02f-184：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-366 thin get */ int32_t g_pipeline_asm_emit_call_f32_xmm;

/** 默认开启 f32 xmm ABI；SHUX_ABI_F32_XMM=0 回落 legacy f64 widen。 */
/* G-02f-184：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-374 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t pipeline_asm_abi_f32_xmm_enabled_c_impl(void) {
  const char *env = getenv("SHUX_ABI_F32_XMM");
  if (env && env[0] == '0' && env[1] == '\0')
    return 0;
  return 1;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t pipeline_asm_abi_f32_xmm_enabled_c(void) {
  return pipeline_asm_abi_f32_xmm_enabled_c_impl();
}
#endif

/* G-02f-380 call：_impl 返回 i32（供 thin -E）；public void 仍 seed-only 非 PREFER */
int32_t pipeline_asm_emit_set_call_f32_xmm_impl(int32_t on) {
  g_pipeline_asm_emit_call_f32_xmm = on != 0 ? 1 : 0;
  return 0;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
void pipeline_asm_emit_set_call_f32_xmm(int32_t on) {
  (void)pipeline_asm_emit_set_call_f32_xmm_impl(on);
}
#endif

/* G-02f-381 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_f32_xmm_flag_get_body_impl(void) {
  return g_pipeline_asm_emit_call_f32_xmm;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_f32_xmm_flag_get_body(void) {
  return glue_f32_xmm_flag_get_body_impl();
}
#endif

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t pipeline_asm_emit_get_call_f32_xmm_c(void) {
  return glue_f32_xmm_flag_get_body();
}
#endif

#define GLUE_TYPE_F32_ORD 14
#define GLUE_TYPE_F64_ORD 15

int32_t glue_call_param_type_ref_at(struct ast_ASTArena *arena, int32_t call_expr_ref, int32_t param_index);
int32_t glue_emit_one_call_arg_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            int32_t call_expr_ref, int32_t arg_ref, int32_t arg_index,
                                            struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t pipeline_expr_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t expr_ref);

/** 形参/实参 type_ref 是否走 SysV SSE 浮点寄存器类（f32 或 f64）。
 * Historical name is_f32; f64 shares xmm0–7 (G.7 complete, not a second gate).
 * PLATFORM: SHARED kind check / LINUX+MACOS x86_64 SysV xmm slotting. */
/* G-02f-120：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_call_param_is_f32_c(struct ast_ASTArena *arena, int32_t type_ref) {
  int32_t k;
  if (!arena || type_ref <= 0)
    return 0;
  k = pipeline_type_kind_ord_at(arena, type_ref);
  return (k == GLUE_TYPE_F32_ORD || k == GLUE_TYPE_F64_ORD) ? 1 : 0;
}
#endif

/**
 * True if call arg should use SysV xmm (param type f32/f64, or arg is FLOAT_LIT / resolved float).
 * Completes import callees when dep param type_ref mapping is missing.
 */
static int32_t glue_call_arg_is_sse_float_c(struct ast_ASTArena *arena, int32_t call_expr_ref, int32_t arg_index,
                                            int32_t pty) {
  int32_t arg_ref;
  int32_t ko;
  int32_t atr;
  int32_t ak;
  if (glue_call_param_is_f32_c(arena, pty))
    return 1;
  if (!arena || call_expr_ref <= 0 || arg_index < 0)
    return 0;
  arg_ref = pipeline_expr_call_arg_ref(arena, call_expr_ref, arg_index);
  if (arg_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, arg_ref);
  if (ko == 1) /* FLOAT_LIT → default f64 bits / SysV xmm */
    return 1;
  atr = pipeline_expr_resolved_type_ref(arena, arg_ref);
  if (atr <= 0)
    return 0;
  ak = pipeline_type_kind_ord_at(arena, atr);
  return (ak == 14 || ak == 15) ? 1 : 0;
}

/** f64 width for movq vs movd when placing into xmm. */
static int32_t glue_call_arg_is_f64_width_c(struct ast_ASTArena *arena, int32_t call_expr_ref, int32_t arg_index,
                                            int32_t pty) {
  int32_t arg_ref;
  int32_t atr;
  int32_t ak;
  if (pty > 0 && pipeline_type_kind_ord_at(arena, pty) == 15)
    return 1;
  if (!arena || call_expr_ref <= 0)
    return 0;
  arg_ref = pipeline_expr_call_arg_ref(arena, call_expr_ref, arg_index);
  if (arg_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, arg_ref) == 1)
    return 1; /* float lit default f64 */
  atr = pipeline_expr_resolved_type_ref(arena, arg_ref);
  if (atr <= 0)
    return 0;
  ak = pipeline_type_kind_ord_at(arena, atr);
  return ak == 15 ? 1 : 0;
}




/** SysV x86_64：第 arg_index 个实参的寄存器/栈归属（0=gp 1=xmm 2=stack）。 */
/* G-02f-141：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-380 call：_impl 返回 i32（供 thin -E）；public void 仍 seed-only 非 PREFER */
int32_t glue_sysv_x86_call_arg_slot_c_impl(struct ast_ASTArena *arena, int32_t call_expr_ref, int32_t nargs,
                                          int32_t arg_index, int32_t *out_kind, int32_t *out_reg_k,
                                          int32_t *out_stack_k) {
  int32_t gp;
  int32_t xmm;
  int32_t stk;
  int32_t j;
  int32_t pty;
  if (!out_kind || !out_reg_k || !out_stack_k)
    return 0;
  gp = 0;
  xmm = 0;
  stk = 0;
  for (j = 0; j <= arg_index && j < nargs; j++) {
    pty = glue_call_param_type_ref_at(arena, call_expr_ref, j);
    if (j == arg_index) {
      if (glue_call_arg_is_sse_float_c(arena, call_expr_ref, j, pty)) {
        if (xmm < 8) {
          *out_kind = 1;
          *out_reg_k = xmm;
        } else {
          *out_kind = 2;
          *out_stack_k = stk;
        }
      } else if (gp < 6) {
        *out_kind = 0;
        *out_reg_k = gp;
      } else {
        *out_kind = 2;
        *out_stack_k = stk;
      }
      return 0;
    }
    if (glue_call_arg_is_sse_float_c(arena, call_expr_ref, j, pty)) {
      if (xmm < 8)
        xmm++;
      else
        stk++;
    } else if (gp < 6) {
      gp++;
    } else {
      stk++;
    }
  }
  *out_kind = 2;
  *out_reg_k = 0;
  *out_stack_k = 0;
  return 0;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
void glue_sysv_x86_call_arg_slot_c(struct ast_ASTArena *arena, int32_t call_expr_ref, int32_t nargs,
                                          int32_t arg_index, int32_t *out_kind, int32_t *out_reg_k,
                                          int32_t *out_stack_k) {
  (void)glue_sysv_x86_call_arg_slot_c_impl(arena, call_expr_ref, nargs, arg_index, out_kind, out_reg_k, out_stack_k);
}
#endif


/** SysV x86_64：统计走栈的实参个数（gp/xmm 寄存器用尽后的余量）。 */
/* G-02f-121：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-373 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_sysv_x86_call_n_stack_c_impl(struct ast_ASTArena *arena, int32_t call_expr_ref, int32_t nargs) {
  int32_t gp;
  int32_t xmm;
  int32_t stk;
  int32_t j;
  int32_t pty;
  gp = 0;
  xmm = 0;
  stk = 0;
  for (j = 0; j < nargs; j++) {
    pty = glue_call_param_type_ref_at(arena, call_expr_ref, j);
    if (glue_call_arg_is_sse_float_c(arena, call_expr_ref, j, pty)) {
      if (xmm < 8)
        xmm++;
      else
        stk++;
    } else if (gp < 6) {
      gp++;
    } else {
      stk++;
    }
  }
  return stk;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_sysv_x86_call_n_stack_c(struct ast_ASTArena *arena, int32_t call_expr_ref, int32_t nargs) {
  return glue_sysv_x86_call_n_stack_c_impl(arena, call_expr_ref, nargs);
}
#endif




/**
 * 9–16B struct 实参：CALL 结果在 rax/rdx，须 spill 到栈再 lea 传址（C callee / import 与 lea VAR 一致）。
 */
/* G-02f-145：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-375 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_spill_struct16_call_arg_to_lea_elf_c_impl(struct ast_ASTArena *arena,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                          struct backend_AsmFuncCtx *ctx, int32_t pty,
                                                          int32_t ta) {
  int32_t sz;
  int32_t off;
  struct glue_AsmFuncCtxCall *ly;
  if (ta != 0 || !elf_ctx || !ctx)
    return 0;
  sz = pipeline_asm_type_ref_byte_size_c(arena, pty);
  if (sz <= 8 || sz > 16)
    return 0;
  ly = (struct glue_AsmFuncCtxCall *)ctx;
  /**
   * spill 区须在全部局部之后：rax@off、rdx@(off-8)；若 off==next_offset 则 rdx 半覆盖上一 local。
   * 且 off-8>=16，避免 rdx 写入 saved rbp（[rbp]）。
   */
  off = ly->next_offset + 16;
  if (off < 16) {
    off = 16;
    ly->next_offset = 0;
  }
  if (off < 16)
    return -1;
  if (backend_enc_store_rax_to_rbp_arch(elf_ctx, off, ta) != 0)
    return -1;
  if (backend_enc_store_rdx_to_rbp_arch(elf_ctx, off - 8, ta) != 0)
    return -1;
  ly->next_offset = off + 16;
  return backend_enc_lea_rbp_to_rax_arch(elf_ctx, off, ta);
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_spill_struct16_call_arg_to_lea_elf_c(struct ast_ASTArena *arena,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                          struct backend_AsmFuncCtx *ctx, int32_t pty,
                                                          int32_t ta) {
  return glue_spill_struct16_call_arg_to_lea_elf_c_impl(arena, elf_ctx, ctx, pty, ta);
}
#endif


/** x86 SysV f32 xmm CALL 实参：gp/xmm 分轨 + 栈实参（SHUX_ABI_F32_XMM=1）。 */
/* G-02f-145：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-377 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_emit_call_args_elf_sysv_f32_xmm_c_impl(struct ast_ASTArena *arena,
                                                      struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                      struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t nargs) {
  int32_t n_stack;
  int32_t stack_reserve;
  int32_t i;
  int32_t arg_ref;
  int32_t kind;
  int32_t reg_k;
  int32_t stack_k;
  int32_t stk_push[GLUE_ASM_MAX_CALL_ARGS];
  int32_t n_stk_push;
  int32_t si;

  n_stack = glue_sysv_x86_call_n_stack_c(arena, expr_ref, nargs);
  stack_reserve = 0;
  if (n_stack > 0) {
    stack_reserve = n_stack * 8;
    if (n_stack & 1)
      stack_reserve += 8;
  }
  if (backend_enc_call_stack_reserve_arch(elf_ctx, stack_reserve, ta) != 0)
    return -1;
  n_stk_push = 0;
  for (i = 0; i < nargs; i++) {
    glue_sysv_x86_call_arg_slot_c(arena, expr_ref, nargs, i, &kind, &reg_k, &stack_k);
    if (kind == 2)
      stk_push[n_stk_push++] = i;
  }
  if (n_stack > 0 && (n_stack & 1)) {
    if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
  }
  for (si = n_stk_push - 1; si >= 0; si--) {
    i = stk_push[si];
    arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
    if (arg_ref == 0)
      continue;
    if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref, i, ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
  }
  pipeline_asm_emit_set_call_f32_xmm(1);
  /** 高序号寄存器实参先 emit，避免 ok_i32(…) 等 clobber 已装入 rdi 的低序号实参。 */
  for (i = nargs - 1; i >= 0; i--) {
    int32_t arg_ko;
    int32_t pty;
    int32_t mov_rc;
    int32_t use_xmm;
    int32_t xk;
    arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
    if (arg_ref == 0)
      continue;
    glue_sysv_x86_call_arg_slot_c(arena, expr_ref, nargs, i, &kind, &reg_k, &stack_k);
    if (kind == 2)
      continue;
    if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref, i, ctx, ta) != 0) {
      pipeline_asm_emit_set_call_f32_xmm(0);
      return -1;
    }
    pty = glue_call_param_type_ref_at(arena, expr_ref, i);
    arg_ko = pipeline_expr_kind_ord_at(arena, arg_ref);
    /**
     * SysV float placement: slot kind==1, or FLOAT_LIT (1), or param/arg f32/f64.
     * Use arg_ref already resolved for emit — do not re-fetch (slot helper can miss).
     */
    /** G.7: single float-slot predicate (param type OR FLOAT_LIT OR resolved f32/f64). */
    use_xmm = (kind == 1) || glue_call_arg_is_sse_float_c(arena, expr_ref, i, pty);
    if (!use_xmm) {
      if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, reg_k, ta) != 0) {
        pipeline_asm_emit_set_call_f32_xmm(0);
        return -1;
      }
    } else {
      xk = (kind == 1) ? reg_k : 0;
      if (glue_call_arg_is_f64_width_c(arena, expr_ref, i, pty) || arg_ko == 1 ||
          (pty > 0 && pipeline_type_kind_ord_at(arena, pty) == 15))
        mov_rc = backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx, xk, ta);
      else
        mov_rc = backend_enc_mov_eax_to_xmm_arg_reg_arch(elf_ctx, xk, ta);
      if (mov_rc != 0) {
        pipeline_asm_emit_set_call_f32_xmm(0);
        return -1;
      }
    }
  }
  pipeline_asm_emit_set_call_f32_xmm(0);
  pipeline_asm_emit_set_call_param_type_ref(0);
  return 0;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_emit_call_args_elf_sysv_f32_xmm_c(struct ast_ASTArena *arena,
                                                      struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                      struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t nargs) {
  return glue_emit_call_args_elf_sysv_f32_xmm_c_impl(arena, elf_ctx, expr_ref, ctx, ta, nargs);
}
#endif


/**
 * 当前架构整数 CALL 寄存器实参个数（x86_64 SysV=6，AAPCS64/RISC-V=8）。
 */
/* G-02f-113：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_call_reg_max(int32_t ta) {
  if (ta == 0)
    return 6;
  return 8;
}
#endif



/**
 * call 完成后须回收的 outgoing 栈字节数（含 16 字节对齐垫层）。
 */
/* G-02f-113：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_call_stack_cleanup_bytes(int32_t ta, int32_t nargs) {
  int32_t reg_max;
  int32_t n_stack;
  if (nargs <= 0)
    return 0;
  reg_max = glue_asm_call_reg_max(ta);
  n_stack = nargs - reg_max;
  if (n_stack <= 0)
    return 0;
  if (ta == 0) {
    int32_t bytes = n_stack * 8;
    if (n_stack & 1)
      bytes += 8;
    return bytes;
  }
  if (ta == 2)
    return -1;
  return (n_stack * 8 + 15) & ~15;
}
#endif



/**
 * 将 import 路径转为 C 符号前缀（`.`→`_`，末尾再补 `_`），与 codegen.x codegen_import_path_to_c_prefix_into 一致。
 */
/* G-02f-139：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-380 call：_impl 返回 i32（供 thin -E）；public void 仍 seed-only 非 PREFER */
int32_t glue_codegen_import_path_to_c_prefix_into_impl(const uint8_t *path, uint8_t *buf, int32_t buf_cap) {
  int32_t off;
  int32_t pi;
  if (!buf || buf_cap <= 0)
    return 0;
  off = 0;
  pi = 0;
  while (path) {
    uint8_t ch = path[pi];
    if (ch == 0)
      break;
    if (off + 2 >= buf_cap)
      break;
    buf[off] = (ch == 46) ? 95 : ch;
    off++;
    pi++;
  }
  if (off + 1 < buf_cap) {
    buf[off] = 95;
    off++;
  }
  buf[off] = 0;
  return 0;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
void glue_codegen_import_path_to_c_prefix_into(const uint8_t *path, uint8_t *buf, int32_t buf_cap) {
  (void)glue_codegen_import_path_to_c_prefix_into_impl(path, buf, buf_cap);
}
#endif


/** 前缀为 ASCII 「build_」（6 字节）且 name 已含此前缀时返回 1。 */
/* G-02f-121：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_c_prefix_redundant_with_name(const uint8_t *prefix, int32_t prefix_len, const uint8_t *name,
                                                     int32_t name_len) {
  int32_t i;
  if (!prefix || !name || prefix_len != 6 || name_len < prefix_len)
    return 0;
  if (prefix[0] != 98 || prefix[1] != 117 || prefix[2] != 105 || prefix[3] != 108 || prefix[4] != 100 ||
      prefix[5] != 95)
    return 0;
  for (i = 0; i < prefix_len; i++) {
    if (name[i] != prefix[i])
      return 0;
  }
  return 1;
}
#endif




/** 将 C 前缀与字段名拼成至多 63 字节的 call 符号；成功返回长度，失败 -1。 */
/* G-02f-122：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-371 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_asm_build_import_binding_call_sym_impl(const uint8_t *pre, int32_t pre_len, const uint8_t *field_name,
                                                      int32_t field_len, uint8_t *out_name) {
  int32_t pos;
  int32_t pi;
  pos = 0;
  if (pre_len > 0 && !glue_asm_c_prefix_redundant_with_name(pre, pre_len, field_name, field_len)) {
    pi = 0;
    while (pi < pre_len && pos < 63) {
      out_name[pos++] = pre[pi++];
    }
  }
  pi = 0;
  while (pi < field_len && pos < 63)
    out_name[pos++] = field_name[pi++];
  return pos > 0 ? pos : -1;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_build_import_binding_call_sym(const uint8_t *pre, int32_t pre_len, const uint8_t *field_name,
                                                      int32_t field_len, uint8_t *out_name) {
  return glue_asm_build_import_binding_call_sym_impl(pre, pre_len, field_name, field_len, out_name);
}
#endif




/**
 * co-emit dep 模块时函数标签与同模块 call 须带 import 路径前缀（与 import 限定 call 一致）。
 * 无 dep 路径时返回裸函数名；成功返回符号字节长度，失败 -1。
 */
/* G-02f-144：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-373 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_asm_build_dep_export_sym_c_impl(const uint8_t *name, int32_t name_len, uint8_t *out, int32_t out_cap) {
  const char *dep_path;
  uint8_t prefix[128];
  int32_t plen;
  int32_t pos;
  int32_t i;
  if (!name || name_len <= 0 || !out || out_cap <= 0)
    return -1;
  dep_path = driver_get_current_dep_path_for_codegen();
  pos = 0;
  if (dep_path && dep_path[0]) {
    glue_codegen_import_path_to_c_prefix_into((const uint8_t *)dep_path, prefix, 128);
    plen = 0;
    while (plen < 127 && prefix[plen])
      plen++;
    if (plen > 0 && !glue_asm_c_prefix_redundant_with_name(prefix, plen, name, name_len)) {
      for (i = 0; i < plen && pos < out_cap - 1; i++)
        out[pos++] = prefix[i];
    }
  }
  for (i = 0; i < name_len && pos < out_cap - 1; i++)
    out[pos++] = name[i];
  return pos > 0 ? pos : -1;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_build_dep_export_sym_c(const uint8_t *name, int32_t name_len, uint8_t *out, int32_t out_cap) {
  return glue_asm_build_dep_export_sym_c_impl(name, name_len, out, out_cap);
}
#endif

/** 将 TypeKind 序数写成 overload mangled 后缀（对齐 codegen.c type_to_suffix 标量子集）。 */
/* G-02f-121：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-372 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_type_kind_to_suffix_c_impl(int32_t kind_ord, uint8_t *out, int32_t out_cap) {
  static const uint8_t lit_i32[3] = { 105, 51, 50 };
  static const uint8_t lit_i64[3] = { 105, 54, 52 };
  static const uint8_t lit_u8[2] = { 117, 56 };
  static const uint8_t lit_u32[3] = { 117, 51, 50 };
  static const uint8_t lit_u64[3] = { 117, 54, 52 };
  static const uint8_t lit_usize[5] = { 117, 115, 105, 122, 101 };
  static const uint8_t lit_isize[5] = { 105, 115, 105, 122, 101 };
  static const uint8_t lit_f32[3] = { 102, 51, 50 };
  static const uint8_t lit_f64[3] = { 102, 54, 52 };
  static const uint8_t lit_bool[4] = { 98, 111, 111, 108 };
  const uint8_t *src;
  int32_t slen;
  int32_t i;
  if (!out || out_cap <= 0)
    return 0;
  src = lit_i32;
  slen = 3;
  if (kind_ord == 5) {
    src = lit_i64;
    slen = 3;
  } else if (kind_ord == 2) {
    src = lit_u8;
    slen = 2;
  } else if (kind_ord == 3) {
    src = lit_u32;
    slen = 3;
  } else if (kind_ord == 4) {
    src = lit_u64;
    slen = 3;
  } else if (kind_ord == 6) {
    src = lit_usize;
    slen = 5;
  } else if (kind_ord == 7) {
    src = lit_isize;
    slen = 5;
  } else if (kind_ord == 14) {
    src = lit_f32;
    slen = 3;
  } else if (kind_ord == 15) {
    src = lit_f64;
    slen = 3;
  } else if (kind_ord == 1) {
    src = lit_bool;
    slen = 4;
  }
  for (i = 0; i < slen && i < out_cap - 1; i++)
    out[i] = src[i];
  return slen;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_type_kind_to_suffix_c(int32_t kind_ord, uint8_t *out, int32_t out_cap) {
  return glue_type_kind_to_suffix_c_impl(kind_ord, out, out_cap);
}
#endif

/* Forward: overload mid / export builders need helpers before their definitions. */
int32_t glue_module_func_overload_count_c_impl(struct ast_Module *m, const uint8_t *name, int32_t name_len);
static int32_t glue_asm_overload_param_sig_count_c(struct ast_ASTArena *a, struct ast_Module *m, int32_t func_ix);

/**
 * PLATFORM: SHARED — resolve arg type for import overload mangle.
 * Prefer expr.resolved_type; for VAR fall back to scope-block let type
 * (g_pipeline_asm_emit_scope_block path used by FIELD_ACCESS layout).
 */
static int32_t glue_asm_call_arg_type_ref_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                           int32_t arg_ref) {
  int32_t ty;
  int32_t ko;
  int32_t scope_br;
  uint8_t vname[64];
  int32_t vlen;
  if (!arena || arg_ref <= 0)
    return 0;
  ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
  if (ty > 0)
    return ty;
  ko = pipeline_expr_kind_ord_at(arena, arg_ref);
  if (ko != 3 || !ctx) /* VAR */
    return 0;
  vlen = pipeline_expr_var_name_len(arena, arg_ref);
  if (vlen <= 0 || vlen > 63)
    return 0;
  pipeline_expr_var_name_into(arena, arg_ref, vname);
  scope_br = asm_ctx_scope_block_ref_at((uint8_t *)ctx);
  if (scope_br > 0) {
    ty = pipeline_block_resolve_var_type_ref(arena, scope_br, vname, vlen);
    if (ty > 0)
      return ty;
  }
  return 0;
}

/**
 * PLATFORM: SHARED — type_ref → overload mangle suffix (align codegen_type_ref_to_suffix).
 * PTR: elem suffix + "_ptr"; NAMED: type name ('.'→'_'); scalars: glue_type_kind_to_suffix.
 * Authority for asm call/export symbols that must match formal std .o (len_String, Vec_u8_ptr).
 */
static int32_t glue_asm_type_ref_to_suffix_c(struct ast_ASTArena *a, int32_t type_ref, uint8_t *out,
                                            int32_t out_cap) {
  int32_t tk;
  int32_t n;
  int32_t si;
  if (!a || type_ref <= 0 || !out || out_cap <= 0)
    return 0;
  tk = pipeline_type_kind_ord_at(a, type_ref);
  /* TYPE_PTR = 9 */
  if (tk == 9) {
    int32_t elem = pipeline_type_elem_ref_at(a, type_ref);
    n = glue_asm_type_ref_to_suffix_c(a, elem, out, out_cap);
    if (n > 0 && n + 4 < out_cap) {
      out[n] = (uint8_t)'_';
      out[n + 1] = (uint8_t)'p';
      out[n + 2] = (uint8_t)'t';
      out[n + 3] = (uint8_t)'r';
      return n + 4;
    }
    return n;
  }
  /* Named / user types: always try type name (String, Vec_u8, …). */
  n = pipeline_type_named_name_into(a, type_ref, out);
  if (n > 0 && n < out_cap) {
    for (si = 0; si < n && si < out_cap; si++) {
      if (out[si] == (uint8_t)'.')
        out[si] = (uint8_t)'_';
    }
    return n;
  }
  return glue_type_kind_to_suffix_c(tk, out, out_cap);
}

/**
 * PLATFORM: SHARED — overload mid name only (no module / current_dep path).
 * Aligns codegen_emit_func_link_name: bare when overload_count<=1; else name_t1_t2[_ret_T].
 * CALL-site authority must NOT use glue_asm_build_dep_export_sym_c (that prefixes the
 * *user* current_dep_path, not std.string → wrong mid or 64-byte overflow → bare).
 * G.7: single mid builder for import-binding mangle.
 */
static int32_t glue_asm_build_func_overload_mid_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t func_ix,
                                                   uint8_t *out, int32_t out_cap) {
  uint8_t fname[64];
  int32_t fname_len;
  int32_t pos;
  int32_t np;
  int32_t pi;
  int32_t pty;
  int32_t sl;
  int32_t sig_count;
  uint8_t suf[64];
  if (!m || !a || func_ix < 0 || !out || out_cap <= 0)
    return -1;
  fname_len = pipeline_asm_module_func_name_len_at(m, func_ix);
  if (fname_len <= 0 || fname_len >= out_cap || fname_len > 63)
    return -1;
  pipeline_asm_module_func_name_copy64(m, func_ix, fname);
  memcpy(out, fname, (size_t)fname_len);
  pos = fname_len;
  /* Use _impl: mid builder lives in seed rest (may compile under THIN_FROM_X). */
  if (glue_module_func_overload_count_c_impl(m, fname, fname_len) <= 1)
    return pos;
  np = pipeline_module_func_num_params_at(m, func_ix);
  for (pi = 0; pi < np && pos < out_cap - 2; pi++) {
    pty = pipeline_module_func_param_type_ref_at(m, func_ix, pi);
    if (pty <= 0)
      continue;
    sl = glue_asm_type_ref_to_suffix_c(a, pty, suf, 64);
    if (sl <= 0)
      continue;
    if (pos + 1 + sl >= out_cap)
      return -1;
    out[pos++] = (uint8_t)'_';
    memcpy(out + pos, suf, (size_t)sl);
    pos += sl;
  }
  sig_count = glue_asm_overload_param_sig_count_c(a, m, func_ix);
  if (sig_count > 1) {
    int32_t ret_ref = pipeline_module_func_return_type_at(m, func_ix);
    int32_t rsl = ret_ref > 0 ? glue_asm_type_ref_to_suffix_c(a, ret_ref, suf, 64) : 0;
    if (rsl > 0) {
      if (pos + 4 + rsl >= out_cap)
        return -1;
      out[pos++] = (uint8_t)'_';
      out[pos++] = (uint8_t)'r';
      out[pos++] = (uint8_t)'e';
      out[pos++] = (uint8_t)'t';
      memcpy(out + pos, suf, (size_t)rsl);
      pos += rsl;
    }
  }
  return pos > 0 ? pos : -1;
}

/**
 * PLATFORM: SHARED — resolve dep module for import-binding CALL.
 * Prefer typeck dep_ix; else match dep import_path to user import j (not index j==dep_ix).
 */
static struct ast_Module *glue_asm_res_mod_for_import_binding_c(struct ast_PipelineDepCtx *dp,
                                                                struct ast_Module *user_mod, int32_t imp_j,
                                                                int32_t r_dep, struct ast_ASTArena **out_arena,
                                                                struct ast_ASTArena *fallback_arena) {
  int32_t nd;
  int32_t iplen;
  int32_t di;
  if (out_arena)
    *out_arena = fallback_arena;
  if (!dp)
    return 0;
  nd = pipeline_dep_ctx_ndep(dp);
  if (r_dep >= 0 && r_dep < nd) {
    struct ast_Module *rm = pipeline_dep_ctx_module_at(dp, r_dep);
    struct ast_ASTArena *ra = pipeline_dep_ctx_arena_at(dp, r_dep);
    if (out_arena && ra)
      *out_arena = ra;
    return rm;
  }
  if (!user_mod || imp_j < 0)
    return 0;
  iplen = pipeline_module_import_path_len(user_mod, imp_j);
  if (iplen <= 0 || iplen > 63)
    return 0;
  for (di = 0; di < nd; di++) {
    uint8_t dpath[64];
    int32_t dplen;
    int32_t k;
    int32_t eq;
    dplen = pipeline_dep_ctx_import_path_len(dp, di);
    if (dplen != iplen)
      continue;
    pipeline_dep_ctx_import_path_copy64(dp, di, dpath);
    eq = 1;
    for (k = 0; k < iplen; k++) {
      if (dpath[k] != pipeline_module_import_path_byte_at(user_mod, imp_j, k)) {
        eq = 0;
        break;
      }
    }
    if (eq) {
      struct ast_Module *rm = pipeline_dep_ctx_module_at(dp, di);
      struct ast_ASTArena *ra = pipeline_dep_ctx_arena_at(dp, di);
      if (out_arena && ra)
        *out_arena = ra;
      return rm;
    }
  }
  return 0;
}

/** Count overloads that share the same param-type suffix signature as func_ix (for _ret_ mangle). */
static int32_t glue_asm_overload_param_sig_count_c(struct ast_ASTArena *a, struct ast_Module *m, int32_t func_ix) {
  uint8_t fname[64];
  int32_t fname_len;
  int32_t np0;
  int32_t i;
  int32_t c;
  if (!a || !m || func_ix < 0)
    return 0;
  fname_len = pipeline_asm_module_func_name_len_at(m, func_ix);
  if (fname_len <= 0 || fname_len > 63)
    return 0;
  pipeline_asm_module_func_name_copy64(m, func_ix, fname);
  np0 = pipeline_module_func_num_params_at(m, func_ix);
  c = 0;
  for (i = 0; i < pipeline_module_num_funcs(m); i++) {
    int32_t npi;
    int32_t pi;
    int32_t same;
    if (pipeline_asm_module_func_is_extern_at(m, i) != 0)
      continue;
    if (!pipeline_module_func_name_equal_at(m, i, fname, fname_len))
      continue;
    npi = pipeline_module_func_num_params_at(m, i);
    if (npi != np0)
      continue;
    same = 1;
    for (pi = 0; pi < np0; pi++) {
      uint8_t sa[64];
      uint8_t sb[64];
      int32_t na;
      int32_t nb;
      int32_t k;
      na = glue_asm_type_ref_to_suffix_c(a, pipeline_module_func_param_type_ref_at(m, func_ix, pi), sa, 64);
      nb = glue_asm_type_ref_to_suffix_c(a, pipeline_module_func_param_type_ref_at(m, i, pi), sb, 64);
      if (na != nb) {
        same = 0;
        break;
      }
      for (k = 0; k < na; k++) {
        if (sa[k] != sb[k]) {
          same = 0;
          break;
        }
      }
      if (!same)
        break;
    }
    if (same)
      c++;
  }
  return c;
}

/** 统计模块内同名函数个数（>1 时 emit/call 须 mangled 符号）。 */
/* G-02f-134：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-370 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_module_func_overload_count_c_impl(struct ast_Module *m, const uint8_t *name, int32_t name_len) {
  int32_t i;
  int32_t c;
  if (!m || !name || name_len <= 0)
    return 0;
  c = 0;
  for (i = 0; i < pipeline_module_num_funcs(m); i++) {
    if (pipeline_asm_module_func_is_extern_at(m, i) != 0)
      continue;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)name, name_len))
      c++;
  }
  return c;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_module_func_overload_count_c(struct ast_Module *m, const uint8_t *name, int32_t name_len) {
  return glue_module_func_overload_count_c_impl(m, name, name_len);
}
#endif


/**
 * net_/fs_ 模块函数定义符号与 pipeline_asm_redirect_std_c_wrapper_sym 一致：补 _c 后缀。
 * 调用侧 net_foo → net_foo_c；定义侧须同名，否则 net.o ld -r 合并后内部 U 符号无法解析。
 */
/* G-02f-120：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-370 call：实现体始终 seed；public PREFER 时 thin forward（-E 丢 pure 嵌套） */
int32_t glue_asm_std_c_wrapper_fname_needs_export_c_suffix_impl(const uint8_t *fname, int32_t fname_len) {
  if (!fname || fname_len <= 0)
    return 0;
  if (fname_len >= 2 && fname[fname_len - 2] == '_' && fname[fname_len - 1] == 'c')
    return 0;
  if (fname_len >= 4 && memcmp(fname, "net_", 4) == 0)
    return 1;
  if (fname_len >= 3 && memcmp(fname, "fs_", 3) == 0)
    return 1;
  return 0;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_std_c_wrapper_fname_needs_export_c_suffix(const uint8_t *fname, int32_t fname_len) {
  return glue_asm_std_c_wrapper_fname_needs_export_c_suffix_impl(fname, fname_len);
}
#endif




/** 在 sym[sym_len] 处追加 _c；空间不足则返回原 sym_len。 */
/* G-02f-120：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_append_export_c_suffix(uint8_t *sym, int32_t sym_len, int32_t cap) {
  if (!sym || sym_len <= 0 || sym_len + 2 >= cap)
    return sym_len;
  sym[sym_len] = '_';
  sym[sym_len + 1] = 'c';
  return sym_len + 2;
}
#endif




/**
 * 函数定义/ CALL 导出符号：无 overload 时用裸名+dep 前缀；有 overload 时用 name_t1_t2（如 pick_i32）。
 * PLATFORM: SHARED — G.7 complete authority: named/ptr suffixes + _ret_ when param-sig collides
 * (align codegen_emit_func_link_name). string.len → len_String; vec.new → new_retVec_u8.
 */
/* G-02f-144：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-374 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_asm_build_func_export_sym_c_impl(struct ast_Module *m, struct ast_ASTArena *a, int32_t func_ix,
                                         uint8_t *out, int32_t out_cap) {
  uint8_t fname[64];
  int32_t fname_len;
  int32_t pos;
  int32_t np;
  int32_t pi;
  int32_t pty;
  int32_t sl;
  int32_t sig_count;
  uint8_t suf[64];
  if (!m || !a || func_ix < 0 || !out || out_cap <= 0)
    return -1;
  fname_len = pipeline_asm_module_func_name_len_at(m, func_ix);
  if (fname_len <= 0 || fname_len > 63)
    return -1;
  pipeline_asm_module_func_name_copy64(m, func_ix, fname);
  if (glue_module_func_overload_count_c(m, fname, fname_len) <= 1) {
    pos = glue_asm_build_dep_export_sym_c(fname, fname_len, out, out_cap);
    if (pos <= 0)
      return -1;
    if (glue_asm_std_c_wrapper_fname_needs_export_c_suffix(fname, fname_len))
      pos = glue_asm_append_export_c_suffix(out, pos, out_cap);
    return pos > 0 ? pos : -1;
  }
  pos = glue_asm_build_dep_export_sym_c(fname, fname_len, out, out_cap);
  if (pos <= 0)
    return -1;
  np = pipeline_module_func_num_params_at(m, func_ix);
  for (pi = 0; pi < np && pos < out_cap - 2; pi++) {
    pty = pipeline_module_func_param_type_ref_at(m, func_ix, pi);
    if (pty <= 0)
      continue;
    sl = glue_asm_type_ref_to_suffix_c(a, pty, suf, 64);
    if (sl <= 0)
      continue;
    if (pos < out_cap - 1)
      out[pos++] = (uint8_t)'_';
    if (pos + sl >= out_cap)
      return -1;
    memcpy(out + pos, suf, (size_t)sl);
    pos += sl;
  }
  /* Same param-sig overloads: append _ret_<T> (e.g. new_retVec_u8). */
  sig_count = glue_asm_overload_param_sig_count_c(a, m, func_ix);
  if (sig_count > 1) {
    int32_t ret_ref = pipeline_module_func_return_type_at(m, func_ix);
    int32_t rsl = glue_asm_type_ref_to_suffix_c(a, ret_ref, suf, 64);
    if (rsl > 0) {
      if (pos + 4 + rsl >= out_cap)
        return -1;
      out[pos++] = (uint8_t)'_';
      out[pos++] = (uint8_t)'r';
      out[pos++] = (uint8_t)'e';
      out[pos++] = (uint8_t)'t';
      memcpy(out + pos, suf, (size_t)rsl);
      pos += rsl;
    }
  }
  if (glue_asm_std_c_wrapper_fname_needs_export_c_suffix(fname, fname_len))
    pos = glue_asm_append_export_c_suffix(out, pos, out_cap);
  return pos > 0 ? pos : -1;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_build_func_export_sym_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t func_ix,
                                         uint8_t *out, int32_t out_cap) {
  return glue_asm_build_func_export_sym_c_impl(m, a, func_ix, out, out_cap);
}
#endif

/** import 路径缓冲区中 '.' 分段数。 */
/* G-02f-120：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-368：循环体始终在 seed；public 符号 PREFER 时由 thin forward */
int32_t glue_asm_import_path_segment_count_impl(const uint8_t *path, int32_t path_len) {
  int32_t n;
  int32_t ii;
  if (!path || path_len <= 0)
    return 0;
  n = 1;
  for (ii = 0; ii < path_len; ii++) {
    if (path[ii] == 46)
      n++;
  }
  return n;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_import_path_segment_count(const uint8_t *path, int32_t path_len) {
  return glue_asm_import_path_segment_count_impl(path, path_len);
}
#endif




/** 比较 module import 路径切片与外部字节序列是否相等。 */
/* G-02f-121：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-369 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_asm_import_path_slice_equal_impl(struct ast_Module *module, int32_t imp_ix, int32_t off, int32_t seg_len, const uint8_t *nm, int32_t nm_len) {
  int32_t i;
  if (seg_len != nm_len || seg_len <= 0)
    return 0;
  for (i = 0; i < seg_len; i++) {
    if (pipeline_module_import_path_byte_at(module, imp_ix, off + i) != nm[i])
      return 0;
  }
  return 1;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_import_path_slice_equal(struct ast_Module *module, int32_t imp_ix, int32_t off, int32_t seg_len, const uint8_t *nm, int32_t nm_len) {
  return glue_asm_import_path_slice_equal_impl(module, imp_ix, off, seg_len, nm, nm_len);
}
#endif




/** 比较 import 绑定名与外部字节序列是否相等。 */
/* G-02f-121：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-369 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_asm_import_binding_name_equal_impl(struct ast_Module *module, int32_t imp_ix, const uint8_t *nm, int32_t nm_len) {
  int32_t bl;
  int32_t i;
  bl = pipeline_module_import_binding_name_len(module, imp_ix);
  if (bl != nm_len || nm_len <= 0)
    return 0;
  for (i = 0; i < nm_len; i++) {
    if (pipeline_module_import_binding_name_byte_at(module, imp_ix, i) != nm[i])
      return 0;
  }
  return 1;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_import_binding_name_equal(struct ast_Module *module, int32_t imp_ix, const uint8_t *nm, int32_t nm_len) {
  return glue_asm_import_binding_name_equal_impl(module, imp_ix, nm, nm_len);
}
#endif




/** pipeline_module_import_path 内第 want_seg 段起点偏移与长度。 */
/* G-02f-134：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-371 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_asm_import_segment_at_impl(struct ast_Module *module, int32_t imp_ix, int32_t want_seg, int32_t *ostr,
                                          int32_t *olen) {
  int32_t pl;
  int32_t ci;
  int32_t ss;
  int32_t k;
  if (!module || imp_ix < 0 || imp_ix >= parser_get_module_num_imports(module))
    return 0;
  pl = pipeline_module_import_path_len(module, imp_ix);
  if (pl <= 0 || pl > 63)
    return 0;
  ci = 0;
  ss = 0;
  for (k = 0; k <= pl; k++) {
    int32_t at_end = (k == pl);
    int32_t dot = (!at_end && k < pl && pipeline_module_import_path_byte_at(module, imp_ix, k) == 46);
    if (at_end || dot) {
      int32_t seg_len_here = k - ss;
      if (seg_len_here <= 0)
        return 0;
      if (ci == want_seg) {
        *ostr = ss;
        *olen = seg_len_here;
        return 1;
      }
      if (dot)
        ss = k + 1;
      ci++;
    }
  }
  return 0;

}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_import_segment_at(struct ast_Module *module, int32_t imp_ix, int32_t want_seg, int32_t *ostr,
                                          int32_t *olen) {
  return glue_asm_import_segment_at_impl(module, imp_ix, want_seg, ostr, olen);
}
#endif


/** 将 module 第 imp_ix 槽 import 逻辑路径转成 C ABI 前缀；成功返回前缀字节长度。 */
/* G-02f-133：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-370 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_asm_fill_c_prefix_from_module_import_impl(struct ast_Module *cur_mod, int32_t imp_ix, uint8_t *pre_buf) {
  uint8_t path_bytes[64];
  int32_t pre_len;
  parser_get_module_import_path(cur_mod, imp_ix, path_bytes);
  if (path_bytes[0] == 0)
    return -1;
  glue_codegen_import_path_to_c_prefix_into(path_bytes, pre_buf, 128);
  pre_len = 0;
  while (pre_len < 128 && pre_buf[pre_len] != 0)
    pre_len++;
  return pre_len > 0 ? pre_len : -1;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_fill_c_prefix_from_module_import(struct ast_Module *cur_mod, int32_t imp_ix, uint8_t *pre_buf) {
  return glue_asm_fill_c_prefix_from_module_import_impl(cur_mod, imp_ix, pre_buf);
}
#endif


/**
 * `import a.b…` + `a.b….method(args)` 形式解析 C ABI 符号；成功写 sym_flat 并返回长度。
 * pipe 参数保留兼容，查找一律基于 cur_mod->imports。
 */
/* G-02f-147：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-375 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t pipeline_asm_resolve_whole_import_qualified_symbol_c_impl(struct ast_ASTArena *arena, struct ast_Module *cur_mod,
                                                              int32_t callee_expr_ref, uint8_t *sym_flat,
                                                              int32_t *out_match_imp_j) {
  int32_t cur_ref;
  uint8_t layer_buf[64];
  int32_t nstack;
  int32_t dep_j;
  if (!arena || !cur_mod || !sym_flat || callee_expr_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, callee_expr_ref) != 44)
    return -1;
  asm_qual_sym_layer_reset();
  cur_ref = callee_expr_ref;
  while (1) {
    int32_t falen;
    if (cur_ref <= 0)
      return -1;
    falen = pipeline_expr_field_access_name_len(arena, cur_ref);
    if (pipeline_expr_kind_ord_at(arena, cur_ref) != 44 || falen <= 0 || falen > 63)
      break;
    pipeline_expr_field_access_name_into(arena, cur_ref, layer_buf);
    if (asm_qual_sym_layer_push(layer_buf, falen) < 0)
      return -1;
    cur_ref = pipeline_expr_field_access_base_ref(arena, cur_ref);
  }
  nstack = asm_qual_sym_layer_count();
  if (cur_ref <= 0)
    return -1;
  {
    int32_t vnlen;
    uint8_t vname_buf[64];
    vnlen = pipeline_expr_var_name_len(arena, cur_ref);
    if (pipeline_expr_kind_ord_at(arena, cur_ref) != 3 || vnlen <= 0 || vnlen > 63)
      return -1;
    pipeline_expr_var_name_into(arena, cur_ref, vname_buf);
    dep_j = 0;
    while (dep_j < parser_get_module_num_imports(cur_mod)) {
      int32_t plen;
      uint8_t path_cnt_buf[64];
      int32_t pci;
      int32_t pseg;
      int32_t s0_rel;
      int32_t s0_ln;
      plen = pipeline_module_import_path_len(cur_mod, dep_j);
      if (plen <= 0 || plen > 63) {
        dep_j++;
        continue;
      }
      for (pci = 0; pci < plen && pci < 64; pci++)
        path_cnt_buf[pci] = pipeline_module_import_path_byte_at(cur_mod, dep_j, pci);
      pseg = glue_asm_import_path_segment_count(path_cnt_buf, plen);
      if (pseg <= 0 || nstack != pseg) {
        dep_j++;
        continue;
      }
      if (!glue_asm_import_segment_at(cur_mod, dep_j, 0, &s0_rel, &s0_ln) ||
          !glue_asm_import_path_slice_equal(cur_mod, dep_j, s0_rel, s0_ln, vname_buf, vnlen)) {
        dep_j++;
        continue;
      }
      {
        int32_t bad_mid = 0;
        int32_t sm;
        for (sm = 1; sm <= pseg - 1; sm++) {
          int32_t srv;
          int32_t slv;
          int32_t lay_ix;
          if (!glue_asm_import_segment_at(cur_mod, dep_j, sm, &srv, &slv)) {
            bad_mid = 1;
            break;
          }
          lay_ix = pseg - sm;
          asm_qual_sym_layer_copy(lay_ix, layer_buf, 64);
          if (!glue_asm_import_path_slice_equal(cur_mod, dep_j, srv, slv, layer_buf, asm_qual_sym_layer_len(lay_ix))) {
            bad_mid = 1;
            break;
          }
        }
        if (bad_mid) {
          dep_j++;
          continue;
        }
      }
      {
        uint8_t pre_buf[128];
        int32_t pre_len;
        int32_t blt;
        pre_len = glue_asm_fill_c_prefix_from_module_import(cur_mod, dep_j, pre_buf);
        if (pre_len <= 0) {
          dep_j++;
          continue;
        }
        asm_qual_sym_layer_copy(0, layer_buf, 64);
        blt = glue_asm_build_import_binding_call_sym(pre_buf, pre_len, layer_buf, asm_qual_sym_layer_len(0), sym_flat);
        if (out_match_imp_j)
          *out_match_imp_j = dep_j;
        return blt;
      }
    }
  }
  return -1;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t pipeline_asm_resolve_whole_import_qualified_symbol_c(struct ast_ASTArena *arena, struct ast_Module *cur_mod,
                                                              int32_t callee_expr_ref, uint8_t *sym_flat,
                                                              int32_t *out_match_imp_j) {
  return pipeline_asm_resolve_whole_import_qualified_symbol_c_impl(arena, cur_mod, callee_expr_ref, sym_flat, out_match_imp_j);
}
#endif

/**
 * text 路径：为 call 准备至多 6 个实参（与 backend.x asm_emit_call_args_text 语义一致）。
 * 供 backend.x 薄包装 bl 委托（M8-tail）。
 */
/* G-02f-147：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-376 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t pipeline_asm_emit_call_args_text_c_impl(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                           int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t target_arch,
                                           int32_t nargs) {
  int32_t i;
  int32_t arg_ref;
  if (!arena || !out || !ctx || expr_ref <= 0)
    return -1;
  if (nargs < 0 || nargs > 6)
    return -1;
  if (nargs <= 0)
    return 0;
  for (i = 0; i < nargs; i++) {
    arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
    if (arg_ref == 0)
      continue;
    if (pipeline_asm_emit_expr_c(arena, out, arg_ref, ctx, target_arch) != 0)
      return -1;
    if (target_arch == 0 || target_arch == 2) {
      if (backend_arch_emit_mov_rax_to_arg_reg(out, i, target_arch) != 0)
        return -1;
    } else if (backend_arch_emit_push_rax(out, target_arch) != 0) {
      return -1;
    }
  }
  if (target_arch == 1) {
    for (i = 0; i < nargs; i++) {
      if (backend_arch_emit_ldr_sp_offset_to_wi(out, i, target_arch) != 0)
        return -1;
    }
    if (backend_arch_emit_add_sp_imm(out, nargs * 16, target_arch) != 0)
      return -1;
  }
  return 0;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t pipeline_asm_emit_call_args_text_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                           int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t target_arch,
                                           int32_t nargs) {
  return pipeline_asm_emit_call_args_text_c_impl(arena, out, expr_ref, ctx, target_arch, nargs);
}
#endif

/**
 * ELF 路径：为 enc_call 准备实参（寄存器 + outgoing 栈；经 pipeline_asm_emit_expr_elf_for_call_args）。
 * 供 backend.x asm_emit_call_args_elf 薄包装（M8-tail）。
 */
/* G-02f-122：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_call_param_type_ref_at(struct ast_ASTArena *arena, int32_t call_expr_ref, int32_t param_index) {
  return pipeline_asm_call_param_type_ref_at_c(arena, call_expr_ref, param_index);
}
#endif




/** 设置 callee 形参 type_ref 后 emit 单个 CALL 实参。 */
/* G-02f-144：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-378 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_emit_one_call_arg_elf_c_impl(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            int32_t call_expr_ref, int32_t arg_ref, int32_t arg_index,
                                            struct backend_AsmFuncCtx *ctx, int32_t ta) {
  if (!arena || !elf_ctx || !ctx || arg_ref == 0)
    return 0;
  pipeline_asm_emit_set_call_param_type_ref(glue_call_param_type_ref_at(arena, call_expr_ref, arg_index));
  pipeline_asm_emit_call_arg_begin_c();
  if (pipeline_asm_emit_expr_elf_for_call_args(arena, elf_ctx, arg_ref, ctx, ta) != 0) {
    pipeline_asm_emit_call_arg_end_c();
    pipeline_asm_emit_set_call_param_type_ref(0);
    return -1;
  }
  {
    int32_t pty = glue_call_param_type_ref_at(arena, call_expr_ref, arg_index);
    /** 嵌套 CALL 实参：C struct 返回 rax=指针，须 deref 后再 spill/lea。 */
    if (pipeline_expr_kind_ord_at(arena, arg_ref) == 48 &&
        pipeline_asm_call_struct16_ret_needs_rax_deref_c(arena, arg_ref) != 0) {
      if (pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta) != 0) {
        pipeline_asm_emit_call_arg_end_c();
        pipeline_asm_emit_set_call_param_type_ref(0);
        return -1;
      }
    }
    /** 仅嵌套 CALL 返回 16B struct（rax+rdx）；VAR lea 已在 rax 中，勿 spill（rdx 可能已失效）。 */
    if (pipeline_expr_kind_ord_at(arena, arg_ref) == 48 &&
        glue_spill_struct16_call_arg_to_lea_elf_c(arena, elf_ctx, ctx, pty, ta) != 0) {
      pipeline_asm_emit_call_arg_end_c();
      pipeline_asm_emit_set_call_param_type_ref(0);
      return -1;
    }
  }
  pipeline_asm_emit_call_arg_end_c();
  pipeline_asm_emit_set_call_param_type_ref(0);
  return 0;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_emit_one_call_arg_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            int32_t call_expr_ref, int32_t arg_ref, int32_t arg_index,
                                            struct backend_AsmFuncCtx *ctx, int32_t ta) {
  return glue_emit_one_call_arg_elf_c_impl(arena, elf_ctx, call_expr_ref, arg_ref, arg_index, ctx, ta);
}
#endif


/* G-02f-146：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-377 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t pipeline_asm_emit_call_args_elf_c_impl(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                          int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta,
                                          int32_t nargs) {
  int32_t reg_max;
  int32_t n_stack;
  int32_t stack_reserve;
  int32_t i;
  int32_t arg_ref;

  if (nargs < 0 || nargs > GLUE_ASM_MAX_CALL_ARGS)
    return -1;
  reg_max = glue_asm_call_reg_max(ta);
  /** hidden sret 时 rdi 已预装 dest；走下方 gp 位移路径，勿进 f32-xmm 分轨（未实现 sret 位移）。 */
  if (ta == 0 && pipeline_asm_abi_f32_xmm_enabled_c() && pipeline_asm_emit_call_sret_reg_shift_c() == 0)
    return glue_emit_call_args_elf_sysv_f32_xmm_c(arena, elf_ctx, expr_ref, ctx, ta, nargs);
  {
    int32_t sret_sh = (ta == 0) ? pipeline_asm_emit_call_sret_reg_shift_c() : 0;
    int32_t eff_reg_max = reg_max - sret_sh;
    n_stack = nargs - eff_reg_max;
    if (n_stack < 0)
      n_stack = 0;
    if (n_stack > 0 && ta == 2)
      return -1;

    stack_reserve = glue_asm_call_stack_cleanup_bytes(ta, nargs);
    if (stack_reserve < 0)
      return -1;
    if (backend_enc_call_stack_reserve_arch(elf_ctx, stack_reserve, ta) != 0)
      return -1;

    /** x86_64：奇数个栈实参时先 push 8B 对齐垫（须在实参之前，否则 callee 0x10(%rbp) 错位）；再右到左 push 栈实参。 */
    if (ta == 0 && n_stack > 0) {
      if (n_stack & 1) {
        if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0)
          return -1;
        if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
          return -1;
      }
      for (i = nargs - 1; i >= eff_reg_max; i--) {
        arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
        if (arg_ref != 0) {
          if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref, i, ctx, ta) != 0)
            return -1;
          if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
            return -1;
        }
      }
    }

    /**
     * AAPCS64：实参经 x0 中转再 mov 到 xN；须从高序号寄存器实参向低序号 emit，
     * 避免 emit arg1 覆盖已就位的 arg0（memcmp(pc,pe,16) 曾把 16 误装入 x0 致 SIGSEGV）。
     */
    if (ta == 1) {
      int32_t reg_n = nargs < eff_reg_max ? nargs : eff_reg_max;
      for (i = reg_n - 1; i >= 0; i--) {
        arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
        if (arg_ref == 0)
          continue;
        if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref, i, ctx, ta) != 0)
          return -1;
        if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, i + sret_sh, ta) != 0)
          return -1;
      }
      for (i = eff_reg_max; i < nargs; i++) {
        arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
        if (arg_ref == 0)
          continue;
        if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref, i, ctx, ta) != 0)
          return -1;
        if (backend_enc_store_x0_sp_offset_arch(elf_ctx, (i - eff_reg_max) * 8, ta) != 0)
          return -1;
      }
      pipeline_asm_emit_set_call_param_type_ref(0);
      return 0;
    }

    /** x86 寄存器实参逆序 emit（hidden sret 时 rdi 已预装 dest，用户 arg i → reg i+sret_sh）。 */
    for (i = nargs - 1; i >= 0; i--) {
      if (ta == 0 && i >= eff_reg_max)
        continue;
      arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
      if (arg_ref == 0)
        continue;
      if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref, i, ctx, ta) != 0)
        return -1;
      if (i < eff_reg_max) {
        if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, i + sret_sh, ta) != 0)
          return -1;
      }
    }
    pipeline_asm_emit_set_call_param_type_ref(0);
    return 0;
  }
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t pipeline_asm_emit_call_args_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                          int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta,
                                          int32_t nargs) {
  return pipeline_asm_emit_call_args_elf_c_impl(arena, elf_ctx, expr_ref, ctx, ta, nargs);
}
#endif

/**
 * std.heap 薄包装 → heap_*_c / libc 符号。
 * co-emit 时 std.heap 模块常仅含 allocator_*（无 alloc/arena64_alloc 体）；须 redirect 避免 std_heap_* UND。
 */
/* G-02f-125：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-374 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_try_std_heap_redirect_sym_local_impl(const uint8_t *name, int32_t name_len, uint8_t *sym_out,
                                                    int32_t out_cap) {
  static const struct {
    const char *from;
    const char *to;
  } k_tab[] = {
      /** 核心堆 API：co-emit 薄模块缺函数体，链 runtime_heap_user.o（heap_*_c）。 */
      {"alloc", "heap_alloc_c"},
      {"realloc", "heap_realloc_c"},
      {"free", "heap_free_c"},
      {"alloc_i32", "heap_alloc_i32_c"},
      {"alloc_i32_ret_i32_ptr", "heap_alloc_i32_c"},
      {"alloc_i32_ret_u8_ptr", "heap_alloc_u8_c"},
      {"alloc_i32_ret_u64_ptr", "heap_alloc_u64_c"},
      {"alloc_i32_ret_f64_ptr", "heap_alloc_f64_c"},
      {"alloc_i32_ret_f32_ptr", "heap_alloc_f32_c"},
      {"realloc_i32", "heap_realloc_i32_c"},
      {"realloc_i32_ret_i32_ptr", "heap_realloc_i32_c"},
      {"realloc_u64_ret_u64_ptr", "heap_realloc_u64_c"},
      {"realloc_f64_ret_f64_ptr", "heap_realloc_f64_c"},
      {"realloc_f32_ret_f32_ptr", "heap_realloc_f32_c"},
      {"realloc_u8_ret_u8_ptr", "heap_realloc_u8_c"},
      {"free_i32", "heap_free_i32_c"},
      {"free_i32_ptr", "heap_free_i32_c"},
      {"free_u64_ptr", "heap_free_u64_c"},
      {"free_f64_ptr", "heap_free_f64_c"},
      {"free_f32_ptr", "heap_free_f32_c"},
      {"alloc_u8", "heap_alloc_u8_c"},
      {"realloc_u8", "heap_realloc_u8_c"},
      {"free_u8", "heap_free_u8_c"},
      {"alloc_f32", "heap_alloc_f32_c"},
      {"realloc_f32", "heap_realloc_f32_c"},
      {"free_f32", "heap_free_f32_c"},
      {"copy_i32_at", "heap_copy_i32_at_c"},
      {"copy_u8_at", "heap_copy_u8_at_c"},
      {"copy_f32_at", "heap_copy_f32_at_c"},
      {"copy_u64_at", "heap_copy_u64_at_c"},
      {"copy_f64_at", "heap_copy_f64_at_c"},
      {"copy_i32_ptr_i32_i32_ptr_i32", "heap_copy_i32_at_c"},
      {"copy_u8_ptr_i32_u8_ptr_i32", "heap_copy_u8_at_c"},
      {"copy_f32_ptr_i32_f32_ptr_i32", "heap_copy_f32_at_c"},
      {"copy_u64_ptr_i32_u64_ptr_i32", "heap_copy_u64_at_c"},
      {"copy_f64_ptr_i32_f64_ptr_i32", "heap_copy_f64_at_c"},
      {"arena64_init", "heap_arena64_init_c"},
      {"arena64_alloc", "heap_arena64_alloc_c"},
      {"arena64_deinit", "heap_arena64_deinit_c"},
      {"ptr_mod", "heap_ptr_mod_c"},
  };
  size_t i;
  if (!name || name_len <= 0 || !sym_out || out_cap <= 0)
    return 0;
  for (i = 0; i < sizeof(k_tab) / sizeof(k_tab[0]); i++) {
    size_t flen = strlen(k_tab[i].from);
    size_t tlen = strlen(k_tab[i].to);
    if ((int32_t)flen != name_len || memcmp(name, k_tab[i].from, flen) != 0)
      continue;
    if ((int32_t)tlen + 1 > out_cap)
      return 0;
    memcpy(sym_out, k_tab[i].to, tlen);
    return (int32_t)tlen;
  }
  return 0;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_try_std_heap_redirect_sym_local(const uint8_t *name, int32_t name_len, uint8_t *sym_out,
                                                    int32_t out_cap) {
  return glue_try_std_heap_redirect_sym_local_impl(name, name_len, sym_out, out_cap);
}
#endif




/**
 * co-emit std.string 时 extern shux_string_* 带 std_string_ 前缀；redirect 到 string.o 符号。
 */
/* G-02f-123：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-371 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_try_std_string_shux_redirect_sym_local_impl(const uint8_t *name, int32_t name_len, uint8_t *sym_out,
                                                            int32_t out_cap) {
  int32_t suffix_len;
  if (!name || name_len <= 11 || !sym_out || out_cap <= 0)
    return 0;
  if (memcmp(name, "std_string_", 11) != 0)
    return 0;
  suffix_len = name_len - 11;
  if (suffix_len < 12 || memcmp(name + 11, "shux_string_", 12) != 0)
    return 0;
  if (suffix_len + 1 > out_cap)
    return 0;
  memcpy(sym_out, name + 11, (size_t)suffix_len);
  return suffix_len;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_try_std_string_shux_redirect_sym_local(const uint8_t *name, int32_t name_len, uint8_t *sym_out,
                                                            int32_t out_cap) {
  return glue_try_std_string_shux_redirect_sym_local_impl(name, name_len, sym_out, out_cap);
}
#endif




/**
 * VAR callee 导出符号：overload mangled → std.heap redirect → typeck dep 前缀 → co-emit dep 前缀。
 */
extern int32_t pipeline_typeck_resolve_call_func_index_for_emit_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                                  int32_t call_expr_ref);
/** 查询函数是否为 extern 声明（无函数体，定义由外部桩/libc 提供）。 */
extern int32_t pipeline_module_func_is_extern_at(struct ast_Module *module, int32_t fi);

/* G-02f-145：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-378 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_asm_build_call_export_sym_c_impl(struct ast_ASTArena *arena, int32_t call_expr_ref,
                                                int32_t callee_ref, struct ast_Module *mod,
                                                struct ast_PipelineDepCtx *dep_pipe, uint8_t *out, int32_t out_cap) {
  uint8_t cname[64];
  int32_t clen;
  int32_t dep_ix;
  uint8_t path[64];
  uint8_t prefix[128];
  int32_t plen;
  int32_t rlen;

  if (!arena || callee_ref <= 0 || !out || out_cap <= 0)
    return -1;
  clen = pipeline_expr_var_name_len(arena, callee_ref);
  if (clen <= 0 || clen > 63)
    return -1;
  pipeline_expr_var_name_into(arena, callee_ref, cname);
  rlen = glue_try_std_heap_redirect_sym_local(cname, clen, out, out_cap);
  if (rlen > 0)
    return rlen;
  dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, call_expr_ref);
  if (dep_ix < 0 && dep_pipe) {
    int32_t nd = pipeline_dep_ctx_ndep(dep_pipe);
    int32_t j;
    int32_t fi;
    for (j = 0; j < nd; j++) {
      struct ast_Module *dm = pipeline_dep_ctx_module_at(dep_pipe, j);
      if (!dm)
        continue;
      for (fi = 0; fi < pipeline_module_num_funcs(dm); fi++) {
        if (pipeline_module_func_name_equal_at(dm, fi, cname, clen)) {
          dep_ix = j;
          break;
        }
      }
      if (dep_ix >= 0)
        break;
    }
  }
  if (dep_ix >= 0 && dep_pipe) {
    /* 【Why extern 裸名】dep 池匹配到 extern function（shux_sys_* / libc open/lseek 等）时，
     * 定义由 freestanding_io 桩或 libc 提供（裸名），勿加 dep 前缀（否则 ld 缺符号
     * std_sys_linux_shux_sys_listen / std_sys_linux_open）。 */
    struct ast_Module *dep_mod = pipeline_dep_ctx_module_at(dep_pipe, dep_ix);
    if (dep_mod) {
      int32_t fi2;
      for (fi2 = 0; fi2 < pipeline_module_num_funcs(dep_mod); fi2++) {
        if (pipeline_module_func_name_equal_at(dep_mod, fi2, cname, clen)) {
          if (pipeline_module_func_is_extern_at(dep_mod, fi2) != 0) {
            if (clen > 0 && clen < out_cap) {
              memcpy(out, cname, (size_t)clen);
              return clen;
            }
            return -1;
          }
          break;
        }
      }
    }
    memset(path, 0, sizeof(path));
    pipeline_dep_ctx_import_path_copy64(dep_pipe, dep_ix, path);
    if (path[0]) {
      glue_codegen_import_path_to_c_prefix_into(path, prefix, 128);
      plen = 0;
      while (plen < 127 && prefix[plen])
        plen++;
      if (plen > 0)
        return glue_asm_build_import_binding_call_sym(prefix, plen, cname, clen, out);
    }
  }
  if (mod) {
    int32_t func_ix = pipeline_typeck_resolve_call_func_index_for_emit_c(mod, arena, call_expr_ref);
    if (func_ix >= 0) {
      /* extern 函数（shux_sys_* / libc）用裸名：定义由 freestanding_io 桩或 libc 提供，
       * 勿加 dep 前缀（否则 ld 缺符号 std_heap_page_mmap_shux_sys_mmap）。 */
      if (pipeline_module_func_is_extern_at(mod, func_ix) != 0) {
        if (clen > 0 && clen < out_cap) {
          memcpy(out, cname, (size_t)clen);
          return clen;
        }
        return -1;
      }
      return glue_asm_build_func_export_sym_c(mod, arena, func_ix, out, out_cap);
    }
  }
  /* 兜底：被调用函数既不在 dep 列表也不在当前模块 → extern 函数（shux_sys_*, libc）。
   * extern 定义由 freestanding_io 桩或 libc 提供（裸名），勿加 dep 前缀
   *（否则 ld 缺符号 std_heap_page_mmap_shux_sys_mmap）。 */
  if (clen > 0 && clen < out_cap) {
    memcpy(out, cname, (size_t)clen);
    return clen;
  }
  return -1;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_build_call_export_sym_c(struct ast_ASTArena *arena, int32_t call_expr_ref,
                                                int32_t callee_ref, struct ast_Module *mod,
                                                struct ast_PipelineDepCtx *dep_pipe, uint8_t *out, int32_t out_cap) {
  return glue_asm_build_call_export_sym_c_impl(arena, call_expr_ref, callee_ref, mod, dep_pipe, out, out_cap);
}
#endif


/**
 * co-emit std.encoding/mod.x：std_encoding_utf8_valid -> encoding_utf8_valid_c（链 std/encoding/encoding.o）。
 */
/* G-02f-123：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-372 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_try_std_encoding_redirect_sym_local_impl(const uint8_t *name, int32_t name_len, uint8_t *sym_out,
                                                        int32_t out_cap) {
  const int32_t prefix_len = 13; /* "std_encoding_" */
  int32_t suffix_len;
  int32_t out_len;
  if (!name || name_len <= prefix_len || !sym_out || out_cap <= 0)
    return 0;
  if (memcmp(name, "std_encoding_", (size_t)prefix_len) != 0)
    return 0;
  suffix_len = name_len - prefix_len;
  if (suffix_len <= 0)
    return 0;
  out_len = 9 + suffix_len + 2; /* encoding_ + suffix + _c */
  if (out_len >= out_cap)
    return 0;
  memcpy(sym_out, "encoding_", 9);
  memcpy(sym_out + 9, name + prefix_len, (size_t)suffix_len);
  sym_out[9 + suffix_len] = '_';
  sym_out[9 + suffix_len + 1] = 'c';
  return out_len;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_try_std_encoding_redirect_sym_local(const uint8_t *name, int32_t name_len, uint8_t *sym_out,
                                                        int32_t out_cap) {
  return glue_try_std_encoding_redirect_sym_local_impl(name, name_len, sym_out, out_cap);
}
#endif




/** 经 std.fs/net/std.heap 薄包装重定向表发射 call；无命中则直调 name。 */
/* G-02f-141：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-373 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_asm_enc_call_redirected_impl(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len,
                                            int32_t ta) {
  uint8_t redir[64];
  int32_t rlen;
  int32_t rc;
  int32_t is_std_math;
  if (!name || name_len <= 0)
    return -1;
  {
    FILE *tf = fopen("/tmp/shux_asm_call_syms.txt", "a");
    if (tf) {
      fprintf(tf, "enc_call name=%.*s\n", (int)name_len, (const char *)name);
      fclose(tf);
    }
  }
  is_std_math = (ta == 0 && name_len >= 9 && name[0] == 's' && name[1] == 't' && name[2] == 'd' &&
                 name[3] == '_' && name[4] == 'm' && name[5] == 'a' && name[6] == 't' && name[7] == 'h' &&
                 name[8] == '_')
                    ? 1
                    : 0;
  /**
   * PLATFORM: LINUX+MACOS x86_64 SysV — std_math_* choke (G.7 single authority).
   * Before CALL: f64 arg bits sit in rax after arg emit (mov rdi leaves rax); place xmm0.
   * After CALL: harvest xmm0 → rax for internal GPR float convention.
   */
  if (is_std_math) {
    if (backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx, 0, ta) != 0)
      return -1;
  }
  rlen = glue_try_std_heap_redirect_sym_local(name, name_len, redir, 64);
  if (rlen <= 0)
    rlen = glue_try_std_string_shux_redirect_sym_local(name, name_len, redir, 64);
  if (rlen <= 0)
    rlen = glue_try_std_encoding_redirect_sym_local(name, name_len, redir, 64);
  if (rlen <= 0)
    rlen = pipeline_asm_redirect_std_c_wrapper_sym(name, name_len, redir, 64);
  if (rlen > 0) {
    backend_call_debugf("call redirect %.*s -> %.*s", (int)name_len, (char *)name, (int)rlen, (char *)redir);
    rc = backend_enc_call_arch(elf_ctx, redir, rlen, ta);
  } else {
    rc = backend_enc_call_arch(elf_ctx, name, name_len, ta);
  }
  if (rc != 0)
    return rc;
  if (is_std_math)
    return backend_enc_mov_xmm_arg_reg_to_rax_arch(elf_ctx, 0, ta);
  return 0;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_enc_call_redirected(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len,
                                            int32_t ta) {
  return glue_asm_enc_call_redirected_impl(elf_ctx, name, name_len, ta);
}
#endif


/**
 * import 路径前缀是否为 std.fmt / std.debug（println/print 字符串字面量特化）。
 */
/* G-02f-114：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-370 call：实现体始终 seed；public PREFER 时 thin forward（-E 丢 pure 嵌套） */
int32_t glue_asm_prefix_is_fmt_or_debug_impl(const uint8_t *pre, int32_t pre_len) {
  if (!pre || pre_len < 8)
    return 0;
  if (pre_len >= 8 && memcmp(pre, "std_fmt_", 8) == 0)
    return 1;
  if (pre_len >= 10 && memcmp(pre, "std_debug_", 10) == 0)
    return 1;
  return 0;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_prefix_is_fmt_or_debug(const uint8_t *pre, int32_t pre_len) {
  return glue_asm_prefix_is_fmt_or_debug_impl(pre, pre_len);
}
#endif



/**
 * 将 STRING_LIT 字节追加到 .text 尾（紧跟 lea [rip+0]），结果指针装入 rax（x86_64）。
 * 供 fmt.println 特化与其它须 *u8 实参的路径复用。
 */
/* G-02f-146：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-372 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_asm_emit_string_lit_ptr_rax_elf_c_impl(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                               int32_t str_expr_ref, int32_t ta) {
  uint8_t sbuf[64];
  int32_t slen;
  if (!arena || !elf_ctx || str_expr_ref <= 0 || ta != 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, str_expr_ref) != GLUE_EXPR_STRING_LIT_ORD)
    return -1;
  slen = glue_asm_string_lit_len(arena, str_expr_ref);
  if (slen <= 0 || slen > 63)
    return -1;
  glue_asm_string_lit_into(arena, str_expr_ref, sbuf);
  if (glue_asm_emit_jmp_skip_string_then_lea((uint8_t *)elf_ctx, ta, 1, sbuf, slen) != 0)
    return -1;
  return 0;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_emit_string_lit_ptr_rax_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                               int32_t str_expr_ref, int32_t ta) {
  return glue_asm_emit_string_lit_ptr_rax_elf_c_impl(arena, elf_ctx, str_expr_ref, ta);
}
#endif

/**
 * fmt/debug binding.print / println("…"): embed rodata + call std_fmt_print or
 * std_fmt_println(ptr,len). Avoid generic emit_expr on STRING_LIT (hello.x SIGSEGV).
 */
/* G-02f-144：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-378 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_asm_try_emit_fmt_string_lit_import_call_elf_c_impl(struct ast_ASTArena *arena,
                                                                  struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                  int32_t call_expr_ref, struct backend_AsmFuncCtx *ctx,
                                                                  int32_t ta, const uint8_t *pre_buf, int32_t pre_len,
                                                                  const uint8_t *field_name, int32_t field_len) {
  int32_t is_ln;
  int32_t nargs;
  int32_t arg_ref;
  int32_t slen;
  uint8_t sym_flat[64];
  int32_t sym_len;
  uint8_t sbuf[64];
  if (!arena || !elf_ctx || !ctx || call_expr_ref <= 0 || ta != 0)
    return 0;
  nargs = pipeline_expr_call_num_args_at(arena, call_expr_ref);
  arg_ref = (nargs == 1) ? pipeline_expr_call_arg_ref(arena, call_expr_ref, 0) : 0;
  backend_call_debugf("try fmt lit pre=%.*s field=%.*s nargs=%d arg_ko=%d", (int)pre_len,
                      pre_len > 0 ? (char *)pre_buf : "", (int)field_len, field_len > 0 ? (char *)field_name : "",
                      (int)nargs, arg_ref > 0 ? (int)pipeline_expr_kind_ord_at(arena, arg_ref) : -1);
  if (!glue_asm_prefix_is_fmt_or_debug(pre_buf, pre_len))
    return 0;
  if (field_len == 7 && memcmp(field_name, "println", 7) == 0)
    is_ln = 1;
  else if (field_len == 5 && memcmp(field_name, "print", 5) == 0)
    is_ln = 0;
  else
    return 0;
  nargs = pipeline_expr_call_num_args_at(arena, call_expr_ref);
  if (nargs != 1)
    return 0;
  arg_ref = pipeline_expr_call_arg_ref(arena, call_expr_ref, 0);
  if (arg_ref <= 0 || pipeline_expr_kind_ord_at(arena, arg_ref) != GLUE_EXPR_STRING_LIT_ORD)
    return 0;
  slen = glue_asm_string_lit_len(arena, arg_ref);
  if (slen <= 0 || slen > 63)
    return -1;
  glue_asm_string_lit_into(arena, arg_ref, sbuf);
  sym_len = glue_asm_build_import_binding_call_sym(pre_buf, pre_len, field_name, field_len, sym_flat);
  if (sym_len <= 0)
    return -1;
  (void)is_ln;
  backend_call_debugf("fmt string lit call %.*s slen=%d", (int)sym_len, (char *)sym_flat, (int)slen);
  if (glue_asm_emit_jmp_skip_string_then_lea((uint8_t *)elf_ctx, ta, 0, sbuf, slen) != 0)
    return -1;
  /** arg1 = len */
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, slen, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (glue_asm_enc_call_redirected(elf_ctx, sym_flat, sym_len, ta) != 0)
    return -1;
  return 1;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_try_emit_fmt_string_lit_import_call_elf_c(struct ast_ASTArena *arena,
                                                                  struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                  int32_t call_expr_ref, struct backend_AsmFuncCtx *ctx,
                                                                  int32_t ta, const uint8_t *pre_buf, int32_t pre_len,
                                                                  const uint8_t *field_name, int32_t field_len) {
  return glue_asm_try_emit_fmt_string_lit_import_call_elf_c_impl(arena, elf_ctx, call_expr_ref, ctx, ta, pre_buf, pre_len, field_name, field_len);
}
#endif


extern int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);

/**
 * PLATFORM: SHARED — call return TypeKind for SSE harvest.
 * Prefer call expr resolved_type (typeck). Weak full helper may live in pipeline_glue_standalone
 * (not always on g05 product link); keep authority in this TU for product g05.
 */
static int32_t glue_asm_call_return_type_kind_ord_c(struct ast_ASTArena *arena, int32_t call_expr_ref) {
  int32_t rty;
  if (!arena || call_expr_ref <= 0)
    return -1;
  rty = pipeline_expr_resolved_type_ref(arena, call_expr_ref);
  if (rty > 0)
    return pipeline_type_kind_ord_at(arena, rty);
  return -1;
}

/**
 * PLATFORM: LINUX+MACOS x86_64 SysV — after CALL, harvest f32/f64 return from xmm0 into eax/rax.
 * Internal asm value convention keeps scalar float bits in GPR; C/libm returns in xmm0.
 * Authority: glue_asm_call_return_type_kind_ord_c (resolved_type).
 */
static int32_t glue_asm_harvest_sse_call_ret_to_gpr_c(struct ast_ASTArena *arena,
                                                      struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                      int32_t call_expr_ref, int32_t ta) {
  int32_t kind;
  if (ta != 0 || !arena || !elf_ctx || call_expr_ref <= 0)
    return 0;
  kind = glue_asm_call_return_type_kind_ord_c(arena, call_expr_ref);
  if (kind == 14)
    return backend_enc_mov_xmm_arg_reg_to_eax_arch(elf_ctx, 0, ta);
  if (kind == 15 || kind < 0)
    return backend_enc_mov_xmm_arg_reg_to_rax_arch(elf_ctx, 0, ta);
  return 0;
}

static int32_t glue_asm_harvest_sse_or_std_math_c(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   int32_t expr_ref, int32_t ta, uint8_t *cname, int32_t clen);

/**
 * 发射实参、call 目标符号，并按 ABI 回收 outgoing 栈区。
 */
/* G-02f-141：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-377 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t glue_asm_emit_call_with_cleanup_impl(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                               int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta,
                                               int32_t nargs, uint8_t *cname, int32_t clen) {
  int32_t cleanup;
  if (pipeline_asm_emit_call_args_elf_c(arena, elf_ctx, expr_ref, ctx, ta, nargs) != 0)
    return -1;
  if (glue_asm_enc_call_redirected(elf_ctx, cname, clen, ta) != 0)
    return -1;
  cleanup = glue_asm_call_stack_cleanup_bytes(ta, nargs);
  if (cleanup < 0)
    return -1;
  if (backend_enc_call_stack_cleanup_arch(elf_ctx, cleanup, ta) != 0)
    return -1;
  if (glue_asm_harvest_sse_or_std_math_c(arena, elf_ctx, expr_ref, ta, cname, clen) != 0)
    return -1;
  /** Always append movq rax,xmm0 after call on x86_64 — diagnostic force; refine later.
   * If this still does not appear in user main, emit path is not with_cleanup. */
  if (ta == 0)
    return backend_enc_mov_xmm_arg_reg_to_rax_arch(elf_ctx, 0, ta);
  return 0;
}

/**
 * Harvest f64 SysV ret; force movq for std_math_* symbols when type kind mis-resolved.
 */
static int32_t glue_asm_harvest_sse_or_std_math_c(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   int32_t expr_ref, int32_t ta, uint8_t *cname, int32_t clen) {
  int32_t hr;
  hr = glue_asm_harvest_sse_call_ret_to_gpr_c(arena, elf_ctx, expr_ref, ta);
  if (hr != 0)
    return hr;
  if (ta == 0 && cname && clen >= 9 && cname[0] == 's' && cname[1] == 't' && cname[2] == 'd' &&
      cname[3] == '_' && cname[4] == 'm' && cname[5] == 'a' && cname[6] == 't' && cname[7] == 'h' &&
      cname[8] == '_') {
    return backend_enc_mov_xmm_arg_reg_to_rax_arch(elf_ctx, 0, ta);
  }
  return 0;
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t glue_asm_emit_call_with_cleanup(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                               int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta,
                                               int32_t nargs, uint8_t *cname, int32_t clen) {
  return glue_asm_emit_call_with_cleanup_impl(arena, elf_ctx, expr_ref, ctx, ta, nargs, cname, clen);
}
#endif


/**
 * EXPR_CALL ELF 全路径：IMPORT_BINDING / whole-import FIELD_ACCESS callee、VAR callee、try_inline。
 * 供 pipeline_asm_emit_expr_elf_rec 与 backend.x emit_expr_elf_call 委托。
 */
/* G-02f-147：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-376 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t pipeline_asm_emit_call_elf_c_impl(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                     int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  struct glue_AsmFuncCtxCall *ly;
  struct ast_Module *mod_ref;
  int32_t callee_ref;
  int32_t callee_ko;
  int32_t nargs;
  int32_t inline_rc;
  uint8_t cname[64];
  int32_t clen;

  callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
  if (callee_ref <= 0)
    return -1;
  ly = (struct glue_AsmFuncCtxCall *)ctx;
  mod_ref = ly ? ly->module_ref : 0;
  callee_ko = pipeline_expr_kind_ord_at(arena, callee_ref);
  backend_call_debugf("emit call elf callee_ko=%d call_nargs=%d", (int)callee_ko,
                      (int)pipeline_expr_call_num_args_at(arena, expr_ref));
  /* Always-on diagnostic while hunting bare import mangle (remove after green). */
  fprintf(stderr, "shux: emit_call_elf_impl callee_ko=%d nargs=%d\n", (int)callee_ko,
          (int)pipeline_expr_call_num_args_at(arena, expr_ref));

  /** hello.x: fmt.print/println string lit → call std_fmt_print / std_fmt_println. */
  if (callee_ko == GLUE_EXPR_FIELD_ACCESS_ORD) {
    int32_t fa_lit = glue_asm_try_emit_fmt_string_lit_import_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta,
                                                                        (const uint8_t *)"std_fmt_", 8, (const uint8_t *)"println",
                                                                        7);
    if (fa_lit < 0)
      return -1;
    if (fa_lit > 0)
      return 0;
    fa_lit = glue_asm_try_emit_fmt_string_lit_import_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta,
                                                                (const uint8_t *)"std_fmt_", 8, (const uint8_t *)"print", 5);
    if (fa_lit < 0)
      return -1;
    if (fa_lit > 0)
      return 0;
  }

  /** import binding + `binding.field(args)` callee。 */
  if (mod_ref && callee_ko == 44) {
    int32_t base_ref = pipeline_expr_field_access_base_ref(arena, callee_ref);
    if (base_ref > 0 && pipeline_expr_kind_ord_at(arena, base_ref) == 3) {
      uint8_t base_name[64];
      int32_t base_len = pipeline_expr_var_name_len(arena, base_ref);
      if (base_len > 0 && base_len <= 63) {
        int32_t j;
        uint8_t field_name[64];
        int32_t field_len;
        pipeline_expr_var_name_into(arena, base_ref, base_name);
        field_len = pipeline_expr_field_access_name_len(arena, callee_ref);
        if (field_len > 0 && field_len <= 63) {
          pipeline_expr_field_access_name_into(arena, callee_ref, field_name);
          for (j = 0; j < parser_get_module_num_imports(mod_ref); j++) {
            if (pipeline_module_import_kind_at(mod_ref, j) == GLUE_IMPORT_KIND_BINDING &&
                glue_asm_import_binding_name_equal(mod_ref, j, base_name, base_len)) {
              uint8_t pre_buf[128];
              uint8_t sym_flat[64];
              int32_t pre_len;
              int32_t sym_len;
              int32_t call_nargs;
              int32_t n_ov;
              pre_len = glue_asm_fill_c_prefix_from_module_import(mod_ref, j, pre_buf);
              if (pre_len <= 0)
                return -1;
              /*
               * PLATFORM: SHARED — import-binding CALL mangle authority (G.7).
               * Align C codegen_emit_call_func_name / codegen_emit_func_link_name:
               *   1) resolve dep module (typeck dep_ix OR import-path match; never j==dep_ix)
               *   2) resolve func_ix (typeck or arity+type scan)
               *   3) mid = overload mid from *formal* param types (no user current_dep_path)
               *   4) sym = import_c_prefix + mid
               * Fallback: caller-arena arg/ret suffixes when formals unavailable.
               * Bare prefix+field → U std_string_len vs formal std_string_len_StrView.
               */
              {
                int32_t r_func = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
                int32_t r_dep = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
                struct ast_PipelineDepCtx *dp = pipeline_asm_emit_dep_pipe_c();
                uint8_t mid[64];
                int32_t mid_len = -1;
                int32_t dbg_use_fi = -2;
                int32_t dbg_nfunc = -1;
                int32_t dbg_ovc = -1;
                int32_t dbg_ndep = -1;
                sym_len = -1;
                if (!dp && ly && ly->dep_pipe)
                  dp = (struct ast_PipelineDepCtx *)ly->dep_pipe;
                if (dp)
                  dbg_ndep = pipeline_dep_ctx_ndep(dp);
                if (dp) {
                  struct ast_ASTArena *res_arena = arena;
                  struct ast_Module *res_mod =
                      glue_asm_res_mod_for_import_binding_c(dp, mod_ref, j, r_dep, &res_arena, arena);
                  int32_t use_fi = r_func;
                  int32_t want_np = pipeline_expr_call_num_args_at(arena, expr_ref);
                  if (res_mod)
                    dbg_nfunc = pipeline_module_num_funcs(res_mod);
                  /* Validate typeck func_ix (name + arity) on res_mod; else rescan. */
                  if (res_mod && use_fi >= 0 && use_fi < pipeline_module_num_funcs(res_mod)) {
                    int32_t ok = 1;
                    if (pipeline_module_func_num_params_at(res_mod, use_fi) != want_np)
                      ok = 0;
                    else if (!pipeline_module_func_name_equal_at(res_mod, use_fi, field_name, field_len))
                      ok = 0;
                    if (!ok)
                      use_fi = -1;
                  } else {
                    use_fi = -1;
                  }
                  if (res_mod && use_fi < 0) {
                    int32_t fi;
                    int32_t exp_ty = pipeline_expr_resolved_type_ref(arena, expr_ref);
                    int32_t best = -1;
                    int32_t best_score = -1;
                    for (fi = 0; fi < pipeline_module_num_funcs(res_mod); fi++) {
                      int32_t np;
                      int32_t score;
                      int32_t pi;
                      if (pipeline_asm_module_func_is_extern_at(res_mod, fi) != 0)
                        continue;
                      if (!pipeline_module_func_name_equal_at(res_mod, fi, field_name, field_len))
                        continue;
                      np = pipeline_module_func_num_params_at(res_mod, fi);
                      if (np != want_np)
                        continue;
                      score = 1;
                      for (pi = 0; pi < np && pi < 8; pi++) {
                        int32_t arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, pi);
                        int32_t arg_ty = glue_asm_call_arg_type_ref_c(arena, ctx, arg_ref);
                        int32_t pty = pipeline_module_func_param_type_ref_at(res_mod, fi, pi);
                        uint8_t sa[64];
                        uint8_t sb[64];
                        int32_t na;
                        int32_t nb;
                        int32_t k;
                        if (arg_ty <= 0 || pty <= 0)
                          continue;
                        na = glue_asm_type_ref_to_suffix_c(arena, arg_ty, sa, 64);
                        nb = glue_asm_type_ref_to_suffix_c(res_arena, pty, sb, 64);
                        if (na > 0 && na == nb) {
                          int32_t eq = 1;
                          for (k = 0; k < na; k++) {
                            if (sa[k] != sb[k]) {
                              eq = 0;
                              break;
                            }
                          }
                          if (eq)
                            score += 10;
                        }
                      }
                      if (want_np == 0 && exp_ty > 0) {
                        int32_t rty = pipeline_module_func_return_type_at(res_mod, fi);
                        uint8_t sa[64];
                        uint8_t sb[64];
                        int32_t na = glue_asm_type_ref_to_suffix_c(arena, exp_ty, sa, 64);
                        int32_t nb = rty > 0 ? glue_asm_type_ref_to_suffix_c(res_arena, rty, sb, 64) : 0;
                        int32_t k;
                        if (na > 0 && na == nb) {
                          int32_t eq = 1;
                          for (k = 0; k < na; k++) {
                            if (sa[k] != sb[k]) {
                              eq = 0;
                              break;
                            }
                          }
                          if (eq)
                            score += 20;
                        }
                      }
                      if (score > best_score) {
                        best_score = score;
                        best = fi;
                      }
                    }
                    use_fi = best;
                  }
                  if (res_mod && use_fi >= 0 && use_fi < pipeline_module_num_funcs(res_mod)) {
                    dbg_use_fi = use_fi;
                    {
                      uint8_t fnb[64];
                      int32_t fnl = pipeline_asm_module_func_name_len_at(res_mod, use_fi);
                      if (fnl > 0 && fnl <= 63) {
                        pipeline_asm_module_func_name_copy64(res_mod, use_fi, fnb);
                        dbg_ovc = glue_module_func_overload_count_c_impl(res_mod, fnb, fnl);
                      }
                    }
                    mid_len = glue_asm_build_func_overload_mid_c(res_mod, res_arena, use_fi, mid, 64);
                    if (mid_len > 0) {
                      sym_len = glue_asm_build_import_binding_call_sym(pre_buf, pre_len, mid, mid_len, sym_flat);
                      if (sym_len <= 0)
                        mid_len = -1;
                    }
                  } else {
                    dbg_use_fi = use_fi;
                  }
                }
                if (getenv("SHUX_ASM_MANGLE_TRACE")) {
                  FILE *tf = fopen("/tmp/shux_asm_mangle_trace.txt", "a");
                  if (tf) {
                    fprintf(tf,
                            "field=%.*s pre_len=%d r_func=%d r_dep=%d ndep=%d nfunc=%d use_fi=%d ovc=%d mid_len=%d "
                            "sym_len=%d mid=%.*s sym=%.*s\n",
                            (int)field_len, (const char *)field_name, (int)pre_len, (int)r_func, (int)r_dep,
                            (int)dbg_ndep, (int)dbg_nfunc, (int)dbg_use_fi, (int)dbg_ovc, (int)mid_len, (int)sym_len,
                            mid_len > 0 ? (int)mid_len : 0, mid_len > 0 ? (const char *)mid : "",
                            sym_len > 0 ? (int)sym_len : 0, sym_len > 0 ? (const char *)sym_flat : "");
                    fclose(tf);
                  }
                }
                /*
                 * PLATFORM: SHARED — caller-arena arg/ret mangle when formals mid stayed bare
                 * or res_mod unresolved. Formal: len_StrView / new_retVec_u8.
                 */
                if (sym_len <= 0 || (sym_len == pre_len + field_len &&
                                     memcmp(sym_flat + pre_len, field_name, (size_t)field_len) == 0)) {
                  int32_t n_args = pipeline_expr_call_num_args_at(arena, expr_ref);
                  int32_t pos;
                  int32_t pi;
                  int32_t alen = 0;
                  if (field_len > 0 && field_len < 64) {
                    memcpy(mid, field_name, (size_t)field_len);
                    alen = field_len;
                  }
                  for (pi = 0; pi < n_args && alen < 60; pi++) {
                    int32_t arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, pi);
                    int32_t arg_ty = glue_asm_call_arg_type_ref_c(arena, ctx, arg_ref);
                    uint8_t suf[64];
                    int32_t sl = arg_ty > 0 ? glue_asm_type_ref_to_suffix_c(arena, arg_ty, suf, 64) : 0;
                    if (sl <= 0)
                      continue;
                    if (alen + 1 + sl >= 64)
                      break;
                    mid[alen++] = (uint8_t)'_';
                    memcpy(mid + alen, suf, (size_t)sl);
                    alen += sl;
                  }
                  if (n_args == 0) {
                    int32_t exp_ty = pipeline_expr_resolved_type_ref(arena, expr_ref);
                    uint8_t suf[64];
                    int32_t sl = exp_ty > 0 ? glue_asm_type_ref_to_suffix_c(arena, exp_ty, suf, 64) : 0;
                    if (sl > 0 && alen + 4 + sl < 64) {
                      mid[alen++] = (uint8_t)'_';
                      mid[alen++] = (uint8_t)'r';
                      mid[alen++] = (uint8_t)'e';
                      mid[alen++] = (uint8_t)'t';
                      memcpy(mid + alen, suf, (size_t)sl);
                      alen += sl;
                    }
                  }
                  if (alen > field_len) {
                    pos = glue_asm_build_import_binding_call_sym(pre_buf, pre_len, mid, alen, sym_flat);
                    if (pos > 0)
                      sym_len = pos;
                  }
                }
                if (sym_len <= 0) {
                  sym_len = glue_asm_build_import_binding_call_sym(pre_buf, pre_len, field_name, field_len,
                                                                  sym_flat);
                }
              }
              if (sym_len <= 0)
                return -1;
              {
                int32_t fmt_lit =
                    glue_asm_try_emit_fmt_string_lit_import_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta, pre_buf,
                                                                       pre_len, field_name, field_len);
                if (fmt_lit < 0)
                  return -1;
                if (fmt_lit > 0)
                  return 0;
              }
              call_nargs = pipeline_expr_call_num_args_at(arena, expr_ref);
              n_ov = pipeline_codegen_call_num_args_override(pre_buf, pre_len, field_name, field_len, call_nargs);
              if (pipeline_asm_emit_call_args_elf_c(arena, elf_ctx, expr_ref, ctx, ta, n_ov) != 0)
                return -1;
              if (glue_asm_enc_call_redirected(elf_ctx, sym_flat, sym_len, ta) != 0)
                return -1;
              {
                int32_t cln = glue_asm_call_stack_cleanup_bytes(ta, n_ov);
                if (cln < 0 || backend_enc_call_stack_cleanup_arch(elf_ctx, cln, ta) != 0)
                  return -1;
              }
              if (glue_asm_harvest_sse_or_std_math_c(arena, elf_ctx, expr_ref, ta, sym_flat, sym_len) != 0)
                return -1;
              if (ta == 0 && backend_enc_mov_xmm_arg_reg_to_rax_arch(elf_ctx, 0, ta) != 0)
                return -1;
              return 0;
            }
          }
        }
      }
    }
  }

  /** `import a.b` + `a.b.c.method(args)` whole-import 限定 callee。 */
  if (mod_ref && callee_ko == 44) {
    int32_t imp_elt = 0;
    uint8_t sym_eh[64];
    int32_t elen;
    uint8_t field_name[64];
    int32_t field_len;
    elen = pipeline_asm_resolve_whole_import_qualified_symbol_c(arena, mod_ref, callee_ref, sym_eh, &imp_elt);
    if (elen > 0 && imp_elt >= 0 && imp_elt < parser_get_module_num_imports(mod_ref)) {
      uint8_t pre_eb[128];
      int32_t pre_el;
      int32_t call_nargs2;
      int32_t n_wo_elf;
      field_len = pipeline_expr_field_access_name_len(arena, callee_ref);
      if (field_len <= 0 || field_len > 63)
        return -1;
      pipeline_expr_field_access_name_into(arena, callee_ref, field_name);
      pre_el = glue_asm_fill_c_prefix_from_module_import(mod_ref, imp_elt, pre_eb);
      if (pre_el <= 0)
        return -1;
      call_nargs2 = pipeline_expr_call_num_args_at(arena, expr_ref);
      n_wo_elf = pipeline_codegen_call_num_args_override(pre_eb, pre_el, field_name, field_len, call_nargs2);
      if (pipeline_asm_emit_call_args_elf_c(arena, elf_ctx, expr_ref, ctx, ta, n_wo_elf) != 0)
        return -1;
      if (glue_asm_enc_call_redirected(elf_ctx, sym_eh, elen, ta) != 0)
        return -1;
      {
        int32_t cln2 = glue_asm_call_stack_cleanup_bytes(ta, n_wo_elf);
        if (cln2 < 0 || backend_enc_call_stack_cleanup_arch(elf_ctx, cln2, ta) != 0)
          return -1;
      }
      if (glue_asm_harvest_sse_or_std_math_c(arena, elf_ctx, expr_ref, ta, sym_eh, elen) != 0)
        return -1;
      if (ta == 0 && backend_enc_mov_xmm_arg_reg_to_rax_arch(elf_ctx, 0, ta) != 0)
        return -1;
      return 0;
    }
  }

  /** 同模块 VAR callee。 */
  if (callee_ko != 3)
    return -1;
  nargs = pipeline_expr_call_num_args_at(arena, expr_ref);
  if (nargs < 0 || nargs > GLUE_ASM_MAX_CALL_ARGS)
    return -1;
  if (nargs == 1)
    backend_call_debugf("emit call1 ref=%d callee_ko=%d", (int)expr_ref, (int)callee_ko);
  inline_rc = try_inline_param0_single_field_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
  if (inline_rc != 0) {
    backend_call_debugf("emit call inline param0_field rc=%d ref=%d", (int)inline_rc, (int)expr_ref);
    return inline_rc < 0 ? -1 : 0;
  }
  inline_rc = try_inline_param0_field_sum_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
  if (inline_rc != 0) {
    backend_call_debugf("emit call inline field_sum rc=%d ref=%d", (int)inline_rc, (int)expr_ref);
    return inline_rc < 0 ? -1 : 0;
  }
  inline_rc = try_inline_x_plus_k_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
  if (inline_rc != 0) {
    backend_call_debugf("emit call inline x_plus_k rc=%d ref=%d", (int)inline_rc, (int)expr_ref);
    return inline_rc < 0 ? -1 : 0;
  }
  inline_rc = try_call_wpo_mono_symbol_elf(arena, elf_ctx, expr_ref, ctx, ta);
  if (inline_rc != 0) {
    backend_call_debugf("emit call inline wpo_mono rc=%d ref=%d", (int)inline_rc, (int)expr_ref);
    return inline_rc < 0 ? -1 : 0;
  }
  inline_rc = try_call_wpo_mono_vector_lane_of_binop_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
  if (inline_rc != 0)
    return inline_rc < 0 ? -1 : 0;
  if (!getenv("SHUX_WPO_MONO") && !getenv("SHUX_WPO_NO_FOLD")) {
    /* SHUX_WPO_NO_FOLD=1：bench/对照时禁用常量实参 fold（仍允许 mono 路径）。 */
    inline_rc = try_inline_wpo_const_vector_lane_of_binop_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
    if (inline_rc != 0)
      return inline_rc < 0 ? -1 : 0;
    inline_rc = try_inline_wpo_const_scalar_binop_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
    if (inline_rc != 0)
      return inline_rc < 0 ? -1 : 0;
  }
  clen = pipeline_expr_var_name_len(arena, callee_ref);
  if (clen <= 0 || clen > 63)
    return -1;
  clen = glue_asm_build_call_export_sym_c(arena, expr_ref, callee_ref, mod_ref, ly ? ly->dep_pipe : 0, cname, 64);
  if (clen <= 0)
    return -1;
  backend_call_debugf("call elf c %.*s nargs=%d", (int)clen, (char *)cname, (int)nargs);
  return glue_asm_emit_call_with_cleanup(arena, elf_ctx, expr_ref, ctx, ta, nargs, cname, clen);
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t pipeline_asm_emit_call_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                     int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  return pipeline_asm_emit_call_elf_c_impl(arena, elf_ctx, expr_ref, ctx, ta);
}
#endif

extern int32_t pipeline_expr_method_call_base_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_name_len(struct ast_ASTArena *a, int32_t expr_ref);
extern void pipeline_expr_method_call_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64);
extern int32_t pipeline_expr_method_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);

/**
 * EXPR_METHOD_CALL ELF：receiver 作 arg0，实参 arg1..argN，enc_call(method_name)。
 * 供 backend.x emit_expr_elf_method_call 薄包装（M8-tail）。
 */
/* G-02f-147：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-376 call：实现体始终 seed；public PREFER 时 thin forward */
int32_t pipeline_asm_emit_method_call_elf_c_impl(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  struct glue_AsmFuncCtxCall *ly;
  struct ast_Module *mod_ref;
  int32_t nargs;
  int32_t base_ref;
  int32_t i;
  int32_t name_len;
  uint8_t name[64];

  ly = (struct glue_AsmFuncCtxCall *)ctx;
  mod_ref = ly ? ly->module_ref : 0;
  nargs = pipeline_expr_method_call_num_args_at(arena, expr_ref);
  if (nargs > 5)
    return -1;
  base_ref = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
  name_len = pipeline_expr_method_call_name_len(arena, expr_ref);
  if (name_len <= 0 || name_len > 63)
    return -1;
  pipeline_expr_method_call_name_into(arena, expr_ref, name);
  /** import binding：encoding.foo(args) 静态调用，receiver 不入参。 */
  if (mod_ref && base_ref > 0 && pipeline_expr_kind_ord_at(arena, base_ref) == GLUE_EXPR_VAR_ORD) {
    uint8_t base_name[64];
    int32_t base_len = pipeline_expr_var_name_len(arena, base_ref);
    if (base_len > 0 && base_len <= 63) {
      int32_t j;
      pipeline_expr_var_name_into(arena, base_ref, base_name);
      for (j = 0; j < parser_get_module_num_imports(mod_ref); j++) {
        if (pipeline_module_import_kind_at(mod_ref, j) == GLUE_IMPORT_KIND_BINDING &&
            glue_asm_import_binding_name_equal(mod_ref, j, base_name, base_len)) {
          uint8_t pre_buf[128];
          uint8_t sym_flat[64];
          int32_t pre_len;
          int32_t sym_len;
          int32_t n_ov;
          pre_len = glue_asm_fill_c_prefix_from_module_import(mod_ref, j, pre_buf);
          if (pre_len <= 0)
            return -1;
          sym_len = glue_asm_build_import_binding_call_sym(pre_buf, pre_len, name, name_len, sym_flat);
          if (sym_len <= 0)
            return -1;
          n_ov = pipeline_codegen_call_num_args_override(pre_buf, pre_len, name, name_len, nargs);
          if (ta == 1) {
            for (i = nargs - 1; i >= 0; i--) {
              int32_t arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, i);
              if (arg_ref != 0) {
                if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref, i, ctx, ta) != 0)
                  return -1;
                if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, i, ta) != 0)
                  return -1;
              }
            }
          } else {
            for (i = 0; i < nargs && i < 6; i++) {
              int32_t arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, i);
              if (arg_ref != 0) {
                if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref, i, ctx, ta) != 0)
                  return -1;
                if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, i, ta) != 0)
                  return -1;
              }
            }
          }
          if (glue_asm_enc_call_redirected(elf_ctx, sym_flat, sym_len, ta) != 0)
            return -1;
          {
            int32_t cln = glue_asm_call_stack_cleanup_bytes(ta, n_ov);
            if (cln < 0 || backend_enc_call_stack_cleanup_arch(elf_ctx, cln, ta) != 0)
              return -1;
          }
          return 0;
        }
      }
    }
  }
  if (base_ref != 0) {
    if (pipeline_asm_emit_expr_elf_for_call_args(arena, elf_ctx, base_ref, ctx, ta) != 0)
      return -1;
    if (ta != 1 && backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
      return -1;
  }
  /** AAPCS64：receiver 已在 x0；其余实参从高序号向低序号 emit，勿覆盖 x0。 */
  if (ta == 1) {
    for (i = nargs - 1; i >= 0; i--) {
      int32_t arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, i);
      if (arg_ref != 0) {
        if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref, i, ctx, ta) != 0)
          return -1;
        if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, i + 1, ta) != 0)
          return -1;
      }
    }
  } else {
    for (i = 0; i < nargs && i < 6; i++) {
      int32_t arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, i);
      if (arg_ref != 0) {
        if (glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref, i, ctx, ta) != 0)
          return -1;
        if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, i + 1, ta) != 0)
          return -1;
      }
    }
  }
  return glue_asm_enc_call_redirected(elf_ctx, name, name_len, ta);
}

#ifndef SHUX_L2_CALL_DISPATCH_THIN_FROM_X
int32_t pipeline_asm_emit_method_call_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  return pipeline_asm_emit_method_call_elf_c_impl(arena, elf_ctx, expr_ref, ctx, ta);
}
#endif


#else /* SHUX_BACKEND_CALL_DISPATCH_FROM_X：产品 rest 业务 H=0 */
int backend_call_dispatch_slice_marker(void) {
  return 0;
}
#endif /* SHUX_BACKEND_CALL_DISPATCH_FROM_X */
