/**
 * backend_try_inline_dispatch.c — try_inline_* 与 array/struct lit reserve 的 C 实现
 *
 * M8 自举：含 Expr/Type 按值访问的 SU 真 emit 会宿主 SIGABRT；改 extern 后由本 TU 提供符号。
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/** WPO vec mono 符号最多编码 8 个 lane 常量（两向量各 4 lane）。 */
#define GLUE_WPO_MONO_MAX_ARGS 8

struct ast_ASTArena;
struct ast_Module;
struct ast_PipelineDepCtx;
struct platform_elf_ElfCodegenCtx;

/** 与 backend.sx / pipeline_glue AsmFuncCtx 前缀一致（含 dep_pipe，WPO-S3 跨模块内联解析 import callee）。 */
struct glue_AsmFuncCtx {
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

extern int32_t pipeline_expr_call_resolved_dep_index_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_resolved_func_index_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern struct ast_ASTArena *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);

extern int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_callee_ref_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_num_args_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_arg_ref(struct ast_ASTArena *arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_var_name_len(struct ast_ASTArena *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(struct ast_ASTArena *arena, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_expr_binop_left_ref_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_binop_right_ref_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_offset(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_layout_offset(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                      int32_t expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *arena, int32_t ty_ref);
extern int32_t pipeline_block_resolve_var_type_ref(struct ast_ASTArena *arena, int32_t block_ref, uint8_t *vname,
                                                 int32_t vlen);
extern int32_t asm_ctx_scope_block_ref_at(uint8_t *asm_ctx);
extern int32_t pipeline_asm_module_func_name_len_at(struct ast_Module *mod, int32_t fi);
extern void pipeline_asm_module_func_name_copy64(struct ast_Module *mod, int32_t fi, uint8_t *dst);
extern int32_t pipeline_module_num_funcs(struct ast_Module *mod);
extern int32_t pipeline_module_func_body_ref_at(struct ast_Module *mod, int32_t func_idx);
extern int32_t pipeline_module_func_num_params_at(struct ast_Module *mod, int32_t func_idx);
extern int32_t pipeline_module_func_param_name_len_at(struct ast_Module *mod, int32_t func_idx, int32_t param_ix);
extern void pipeline_module_func_param_name_copy32(struct ast_Module *mod, int32_t func_idx, int32_t param_ix,
                                                   uint8_t *dst);
extern int32_t pipeline_module_func_return_type_at(struct ast_Module *mod, int32_t func_idx);
extern int32_t pipeline_module_num_struct_layouts_at(struct ast_Module *mod);
extern int32_t pipeline_expr_int_val_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t asm_type_is_simd_vector(struct ast_ASTArena *arena, int32_t type_ref);
extern int32_t asm_type_is_simd_vector_spelling(struct ast_ASTArena *arena, int32_t type_ref);
extern int32_t backend_enc_mov_imm64_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lo, int32_t hi,
                                                 int32_t ta);
extern int32_t backend_enc_call_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len,
                                     int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm,
                                                int32_t ta);
extern int32_t backend_enc_call_stack_cleanup_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t bytes,
                                                   int32_t ta);
extern int codegen_wpo_mono_sym_format(const char *base, int nargs, const int *args, char *out, int cap);
extern void glue_wpo_mono_register_thunk(const char *base, int32_t av0, int32_t av1, int32_t folded);
extern void glue_wpo_mono_register_thunk_n(const char *base, int32_t nargs, const int32_t *args, int32_t folded);
extern int32_t pipeline_asm_block_final_expr_ref_at(struct ast_ASTArena *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena *arena, int32_t block_ref);
extern int32_t ast_ast_block_expr_stmt_ref(struct ast_ASTArena *arena, int32_t block_ref, int32_t stmt_i);
extern int32_t pipeline_expr_unary_operand_ref_at(struct ast_ASTArena *arena, int32_t expr_ref);

/** seed partial.o 导出 backend_ 前缀 fold helper。 */
extern int32_t backend_fold_func_returns_param0_field_sum(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                          int32_t func_idx);
extern int32_t backend_fold_func_returns_param0_single_field(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                             int32_t func_idx);
extern int32_t backend_fold_func_return_operand_ref(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                    int32_t func_idx);
extern int32_t backend_fold_func_x_plus_k_chain(struct ast_ASTArena *arena, struct ast_Module *mod, int32_t func_idx,
                                                int32_t depth);

/**
 * C 路径读函数 return 操作数（与 pipeline_glue.c glue_fold_func_return_operand_ref_c 一致）。
 * B-strict backend.o 桩 fold 失败时供 struct/field 内联 fold 使用。
 */
static int32_t glue_fold_func_return_operand_ref_module(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                        int32_t func_idx) {
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

/** 读取函数 return 操作数：backend 真 emit 优先，否则 module body_ref 路径。 */
static int32_t glue_try_fold_func_return_operand_ref(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                     int32_t func_idx) {
  int32_t r;
  r = backend_fold_func_return_operand_ref(arena, mod, func_idx);
  if (r > 0)
    return r;
  return glue_fold_func_return_operand_ref_module(arena, mod, func_idx);
}

extern int32_t backend_emit_expr_elf_slow(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                          int32_t expr_ref, struct glue_AsmFuncCtx *ctx, int32_t ta);
extern int32_t asm_ctx_local_find_offset_scoped(uint8_t *ctx, struct ast_ASTArena *arena, uint8_t *name,
                                                int32_t name_len);
extern int32_t asm_ctx_local_find_offset(uint8_t *ctx, uint8_t *name, int32_t name_len);

/**
 * try_inline 路径查局部槽：scope 子树优先，未命中回退全表（while 内外层 let）。
 */
static int32_t glue_try_inline_local_slot_off(uint8_t *ctx, struct ast_ASTArena *arena, uint8_t *name, int32_t name_len) {
  int32_t off;
  off = asm_ctx_local_find_offset_scoped(ctx, arena, name, name_len);
  if (off < 0)
    off = asm_ctx_local_find_offset(ctx, name, name_len);
  return off;
}

extern int32_t backend_enc_push_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_add_imm_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_load_32_from_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_add_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                               int32_t ta);
extern int32_t backend_enc_load_rbp_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                int32_t ta);
extern int32_t pipeline_asm_var_is_emit_func_param_ptr_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                         uint8_t *asm_ctx, int32_t var_expr_ref);
/** >8B 按值 struct 形参 home 槽为 hidden pointer（Vec3f_soa 等），field/index 须 load。 */
extern int32_t pipeline_asm_emit_func_param_is_indirect_struct_slot_c(struct ast_ASTArena *arena,
                                                                       struct ast_Module *mod, int32_t var_expr_ref);

/** TypeKind：与 ast.sx 序数一致。 */
enum {
  GLUE_TYPE_NAMED = 8,
  GLUE_TYPE_PTR = 9,
  GLUE_TYPE_ARRAY = 10
};

/** ExprKind.EXPR_VAR / EXPR_ARRAY_LIT / EXPR_STRUCT_LIT / EXPR_CALL / EXPR_FIELD_ACCESS */
enum {
  GLUE_EXPR_VAR = 3,
  GLUE_EXPR_FIELD_ACCESS = 44,
  GLUE_EXPR_STRUCT_LIT = 45,
  GLUE_EXPR_ARRAY_LIT = 46,
  GLUE_EXPR_INDEX = 47,
  GLUE_EXPR_CALL = 48
};

extern int32_t pipeline_asm_module_func_num_params_at(struct ast_Module *m, int32_t func_index);
extern int32_t pipeline_asm_module_func_param_name_len_at(struct ast_Module *m, int32_t func_index,
                                                          int32_t param_index);
extern void pipeline_asm_module_func_param_name_copy32(struct ast_Module *m, int32_t func_index,
                                                       int32_t param_index, uint8_t *dst);
extern int32_t pipeline_expr_struct_lit_init_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t j);
extern int32_t pipeline_expr_struct_lit_field_name_len(struct ast_ASTArena *a, int32_t expr_ref, int32_t j);
extern void pipeline_expr_struct_lit_field_name_into(struct ast_ASTArena *a, int32_t expr_ref, int32_t j,
                                                     uint8_t *out);
extern int32_t pipeline_expr_field_access_base_ref(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_name_len(struct ast_ASTArena *a, int32_t expr_ref);
extern void pipeline_expr_field_access_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out);
extern int32_t typeck_get_field_offset_from_layout_deps(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                                        uint8_t *type_name, int32_t type_name_len, uint8_t *field_name,
                                                        int32_t field_name_len);

extern int32_t pipeline_asm_emit_func_index_c(void);
extern struct ast_PipelineDepCtx *pipeline_asm_emit_dep_pipe_c(void);

extern int32_t pipeline_asm_array_lit_elem_type_ref(struct ast_ASTArena *arena, int32_t array_lit_expr_ref);
extern int32_t pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_elem_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_index_base_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_index_index_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_struct_lit_num_fields(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_type_named_name_into(struct ast_ASTArena *arena, int32_t ref, uint8_t *out64);
extern int32_t pipeline_type_elem_ref_at(struct ast_ASTArena *arena, int32_t ty_ref);
extern int32_t pipeline_module_num_struct_layouts_at(struct ast_Module *m);
extern int32_t pipeline_module_struct_layout_name_len(struct ast_Module *m, int32_t idx);
extern uint8_t pipeline_module_struct_layout_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t pipeline_module_struct_layout_num_fields(struct ast_Module *m, int32_t idx);
extern int32_t pipeline_module_struct_layout_field_name_len(struct ast_Module *m, int32_t li, int32_t j);
extern void pipeline_module_struct_layout_field_name_into(struct ast_Module *m, int32_t li, int32_t j,
                                                          uint8_t *out64);
extern int32_t pipeline_module_struct_layout_field_offset_at(struct ast_Module *m, int32_t li, int32_t j);
extern int32_t pipeline_asm_index_elem_byte_sz(struct ast_ASTArena *a, int32_t index_expr_ref);

/** 向上取整到 8 字节（与 backend.sx asm_align_up8 一致）。 */
static int32_t glue_align_up8_c(int32_t n) {
  int32_t m = n % 8;
  if (m != 0)
    n += (8 - m);
  return n;
}

/**
 * ARRAY_LIT 元素字节宽；与 pipeline_glue.c pipeline_asm_array_lit_elem_byte_sz_c 一致。
 */
int32_t asm_array_lit_elem_byte_sz(struct ast_ASTArena *arena, int32_t array_lit_ref) {
  int32_t elem_ty;
  int32_t kind_ord;
  if (!arena || array_lit_ref <= 0)
    return 4;
  elem_ty = pipeline_asm_array_lit_elem_type_ref(arena, array_lit_ref);
  if (elem_ty <= 0)
    return 4;
  kind_ord = pipeline_type_kind_ord_at(arena, elem_ty);
  if (kind_ord == 2 || kind_ord == 1)
    return 1;
  if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13)
    return 4;
  return 8;
}

/**
 * 定长 ARRAY_LIT 初值在栈 temp 区占用字节数（不含 8 字节指针槽）。
 */
int32_t asm_array_lit_reserve_stack_bytes(struct ast_ASTArena *arena, int32_t init_ref) {
  int32_t n;
  int32_t esz;
  if (!arena || init_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != GLUE_EXPR_ARRAY_LIT)
    return 0;
  n = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  if (n <= 0)
    return 0;
  esz = asm_array_lit_elem_byte_sz(arena, init_ref);
  return glue_align_up8_c(n * esz);
}

/**
 * STRUCT_LIT 初值在 temp 区按 8 字节/字段存放。
 */
int32_t asm_struct_lit_reserve_stack_bytes(struct ast_ASTArena *arena, int32_t init_ref) {
  int32_t nf;
  if (!arena || init_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != GLUE_EXPR_STRUCT_LIT)
    return 0;
  nf = pipeline_expr_struct_lit_num_fields(arena, init_ref);
  if (nf <= 0)
    return 0;
  return glue_align_up8_c(nf * 8);
}

/** 按名称查本模块函数下标；-1 未找到（定义见下）。 */
static int32_t glue_module_func_index_by_name(struct ast_Module *mod, uint8_t *name, int32_t name_len);

/**
 * 解析 CALL 的 callee（同模块或 typeck 填写的 import dep/func）；写 callee 模块/arena/函数下标。
 * 返回 1=命中，0=未匹配。
 */
static int32_t glue_call_lookup_callee_mod_fi_arena(struct ast_ASTArena *caller_arena, int32_t call_ref,
                                                    struct glue_AsmFuncCtx *ctx, struct ast_ASTArena **out_ca,
                                                    struct ast_Module **out_cm, int32_t *out_fi) {
  struct ast_PipelineDepCtx *pctx;
  struct ast_Module *entry_mod;
  int32_t callee_ref;
  int32_t dep_ix;
  int32_t func_ix;
  int32_t clen;
  uint8_t cname[64];
  int32_t j;
  if (!caller_arena || call_ref <= 0 || !ctx || !out_ca || !out_cm || !out_fi)
    return 0;
  entry_mod = ctx->module_ref;
  if (!entry_mod)
    return 0;
  *out_ca = caller_arena;
  *out_cm = entry_mod;
  *out_fi = -1;
  dep_ix = pipeline_expr_call_resolved_dep_index_at(caller_arena, call_ref);
  func_ix = pipeline_expr_call_resolved_func_index_at(caller_arena, call_ref);
  if (func_ix >= 0) {
    *out_fi = func_ix;
    if (dep_ix >= 0) {
      pctx = (struct ast_PipelineDepCtx *)ctx->dep_pipe;
      if (!pctx)
        pctx = pipeline_asm_emit_dep_pipe_c();
      if (!pctx)
        return 0;
      *out_cm = pipeline_dep_ctx_module_at(pctx, dep_ix);
      if (!*out_cm)
        return 0;
      if (pipeline_dep_ctx_arena_at(pctx, dep_ix))
        *out_ca = pipeline_dep_ctx_arena_at(pctx, dep_ix);
    }
    return (*out_cm != 0) ? 1 : 0;
  }
  callee_ref = pipeline_expr_call_callee_ref_at(caller_arena, call_ref);
  if (callee_ref <= 0)
    return 0;
  /** import binding：`vec.vec_u8_new()` 等 FIELD_ACCESS callee。 */
  if (pipeline_expr_kind_ord_at(caller_arena, callee_ref) == 44) {
    int32_t field_len = pipeline_expr_field_access_name_len(caller_arena, callee_ref);
    uint8_t field_name[64];
    if (field_len > 0 && field_len <= 63) {
      pipeline_expr_field_access_name_into(caller_arena, callee_ref, field_name);
      pctx = (struct ast_PipelineDepCtx *)ctx->dep_pipe;
      if (!pctx)
        pctx = pipeline_asm_emit_dep_pipe_c();
      if (pctx) {
        j = 0;
        while (j < pipeline_dep_ctx_ndep(pctx)) {
          struct ast_Module *dm = pipeline_dep_ctx_module_at(pctx, j);
          struct ast_ASTArena *da = pipeline_dep_ctx_arena_at(pctx, j);
          if (dm) {
            *out_fi = glue_module_func_index_by_name(dm, field_name, field_len);
            if (*out_fi >= 0) {
              *out_cm = dm;
              if (da)
                *out_ca = da;
              return 1;
            }
          }
          j = j + 1;
        }
      }
    }
    return 0;
  }
  if (pipeline_expr_kind_ord_at(caller_arena, callee_ref) != GLUE_EXPR_VAR)
    return 0;
  clen = pipeline_expr_var_name_len(caller_arena, callee_ref);
  if (clen <= 0 || clen > 63)
    return 0;
  pipeline_expr_var_name_into(caller_arena, callee_ref, cname);
  *out_fi = glue_module_func_index_by_name(entry_mod, cname, clen);
  if (*out_fi >= 0)
    return 1;
  pctx = (struct ast_PipelineDepCtx *)ctx->dep_pipe;
  if (!pctx)
    pctx = pipeline_asm_emit_dep_pipe_c();
  if (!pctx)
    return 0;
  j = 0;
  while (j < pipeline_dep_ctx_ndep(pctx)) {
    struct ast_Module *dm;
    struct ast_ASTArena *da;
    dm = pipeline_dep_ctx_module_at(pctx, j);
    da = pipeline_dep_ctx_arena_at(pctx, j);
    if (dm) {
      *out_fi = glue_module_func_index_by_name(dm, cname, clen);
      if (*out_fi >= 0) {
        *out_cm = dm;
        if (da)
          *out_ca = da;
        return 1;
      }
    }
    j = j + 1;
  }
  return 0;
}

/**
 * 按名称查本模块函数下标；-1 未找到。
 */
static int32_t glue_module_func_index_by_name(struct ast_Module *mod, uint8_t *name, int32_t name_len) {
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

/** EXPR_LIT(0) / EXPR_BOOL_LIT(2) 读整型常量；失败返回 0。 */
static int32_t glue_try_expr_const_i32(struct ast_ASTArena *arena, int32_t expr_ref, int32_t *out) {
  int32_t ko;
  if (!arena || expr_ref <= 0 || !out)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 0 || ko == 2) {
    *out = pipeline_expr_int_val_at(arena, expr_ref);
    return 1;
  }
  return 0;
}

static int32_t glue_expr_is_func_param_at(struct ast_ASTArena *arena, struct ast_Module *mod, int32_t func_idx,
                                          int32_t expr_ref, int32_t param_ix);

/** 标量 i32 binop 编译期求值；不支持的 ko 或除零返回 0。 */
static int32_t glue_const_scalar_binop_eval_i32(int32_t binop_ko, int32_t a, int32_t b, int32_t *out) {
  int64_t wide;
  if (!out)
    return 0;
  switch (binop_ko) {
    case 4:
      wide = (int64_t)a + (int64_t)b;
      break;
    case 5:
      wide = (int64_t)a - (int64_t)b;
      break;
    case 6:
      wide = (int64_t)a * (int64_t)b;
      break;
    case 7:
      if (b == 0)
        return 0;
      wide = (int64_t)a / (int64_t)b;
      break;
    case 8:
      if (b == 0)
        return 0;
      wide = (int64_t)a % (int64_t)b;
      break;
    default:
      return 0;
  }
  *out = (int32_t)wide;
  return 1;
}

/**
 * callee 是否为 `return param0 binop param1`（两 i32 形参、非向量返回）。
 * 成功写 *out_binop_ko（4=add,5=sub,6=mul,7=div,8=mod）。
 */
static int32_t glue_fold_func_returns_param01_scalar_binop(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                           int32_t func_idx, int32_t *out_binop_ko) {
  int32_t ret_ref;
  int32_t ko;
  int32_t al;
  int32_t ar;
  int32_t ret_ty;
  if (!out_binop_ko || !arena || !mod || func_idx < 0)
    return 0;
  if (pipeline_module_func_num_params_at(mod, func_idx) != 2)
    return 0;
  ret_ty = pipeline_module_func_return_type_at(mod, func_idx);
  if (ret_ty > 0 &&
      (asm_type_is_simd_vector_spelling(arena, ret_ty) != 0 || asm_type_is_simd_vector(arena, ret_ty) != 0))
    return 0;
  ret_ref = glue_try_fold_func_return_operand_ref(arena, mod, func_idx);
  if (ret_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, ret_ref);
  if (ko != 4 && ko != 5 && ko != 6 && ko != 7 && ko != 8)
    return 0;
  al = pipeline_expr_binop_left_ref_at(arena, ret_ref);
  ar = pipeline_expr_binop_right_ref_at(arena, ret_ref);
  if (glue_expr_is_func_param_at(arena, mod, func_idx, al, 0) == 0)
    return 0;
  if (glue_expr_is_func_param_at(arena, mod, func_idx, ar, 1) == 0)
    return 0;
  *out_binop_ko = ko;
  return 1;
}

/**
 * 模块内是否存在与 name 同名的 struct_layout（与 backend.sx asm_module_named_type_has_struct_layout 一致）。
 */
static int32_t glue_module_named_type_has_struct_layout(struct ast_Module *mod, uint8_t *name, int32_t name_len) {
  int32_t k;
  int32_t nlen;
  int32_t j;
  if (!mod || !name || name_len <= 0)
    return 0;
  for (k = 0; k < pipeline_module_num_struct_layouts_at(mod); k++) {
    nlen = pipeline_module_struct_layout_name_len(mod, k);
    if (nlen != name_len || nlen <= 0)
      continue;
    for (j = 0; j < name_len; j++) {
      if (pipeline_module_struct_layout_name_byte_at(mod, k, j) != name[j])
        break;
    }
    if (j == name_len)
      return 1;
  }
  return 0;
}

/**
 * 类型 ref 是否为模块内具 layout 的命名 struct（Pair 等）。
 */
static int32_t glue_type_ref_is_named_struct_layout(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                    int32_t ty_ref) {
  uint8_t nm[64];
  int32_t nlen;
  if (ty_ref <= 0 || !mod)
    return 0;
  if (pipeline_type_kind_ord_at(arena, ty_ref) != GLUE_TYPE_NAMED)
    return 0;
  nlen = pipeline_type_named_name_into(arena, ty_ref, nm);
  if (nlen <= 0)
    return 0;
  return glue_module_named_type_has_struct_layout(mod, nm, nlen);
}

/**
 * 局部槽是否为 8 字节间接指针（*T、形参 struct 按值传参时的指针槽）。
 * 块内 let struct（Pair 等）已按 layout 直写栈槽，field/index 基址须 lea 勿 load。
 * asm_ctx 非空时优先读块内 let/const 声明类型（expr.resolved_type 可能误标为 *T）。
 */
int32_t asm_local_var_slot_holds_indirect_ptr(struct ast_ASTArena *arena, int32_t expr_ref,
                                            struct ast_Module *mod, uint8_t *asm_ctx) {
  int32_t tr;
  int32_t kind;
  int32_t decl_ty;
  int32_t scope_br;
  int32_t has_block_decl;
  uint8_t vname[64];
  int32_t vlen;
  if (!arena || expr_ref <= 0)
    return 0;
  has_block_decl = 0;
  decl_ty = 0;
  if (asm_ctx && pipeline_expr_kind_ord_at(arena, expr_ref) == GLUE_EXPR_VAR) {
    vlen = pipeline_expr_var_name_len(arena, expr_ref);
    if (vlen > 0 && vlen <= 63) {
      pipeline_expr_var_name_into(arena, expr_ref, vname);
      scope_br = asm_ctx_scope_block_ref_at(asm_ctx);
      if (scope_br > 0) {
        decl_ty = pipeline_block_resolve_var_type_ref(arena, scope_br, vname, vlen);
        if (decl_ty > 0)
          has_block_decl = 1;
      }
    }
  }
  if (has_block_decl) {
    kind = pipeline_type_kind_ord_at(arena, decl_ty);
    if (kind == GLUE_TYPE_PTR)
      return 1;
    /** let Pair 等内联栈对象：基址 lea。 */
    if (glue_type_ref_is_named_struct_layout(arena, mod, decl_ty))
      return 0;
    return 0;
  }
  tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (tr <= 0) {
    /** emit 时 resolved 缺失：仍须识别当前函数 *T / 大块 struct 形参。 */
    if (pipeline_asm_var_is_emit_func_param_ptr_c(arena, mod, asm_ctx, expr_ref) != 0)
      return 1;
    if (mod && pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena, mod, expr_ref) != 0)
      return 1;
    return 0;
  }
  kind = pipeline_type_kind_ord_at(arena, tr);
  if (kind == GLUE_TYPE_PTR)
    return 1;
  /** 命名 struct：块内 let 仍 lea；>8B 形参 hidden pointer 槽须 load（vec3f_soa_sum_x 的 v.len / v.col_x）。 */
  if (glue_type_ref_is_named_struct_layout(arena, mod, tr)) {
    if (mod && pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena, mod, expr_ref) != 0)
      return 1;
    return 0;
  }
  if (kind == GLUE_TYPE_NAMED)
    return 0;
  /** resolved 误标时回落 module 形参表（仅 *T 形参）。 */
  if (pipeline_asm_var_is_emit_func_param_ptr_c(arena, mod, asm_ctx, expr_ref) != 0)
    return 1;
  return 0;
}

/**
 * INDEX 元素字节宽；委托 pipeline_glue.c（避免 SU Type 按值 emit）。
 */
int32_t asm_index_elem_byte_sz(struct ast_ASTArena *arena, int32_t index_expr_ref) {
  return pipeline_asm_index_elem_byte_sz(arena, index_expr_ref);
}

/**
 * 局部 VAR 槽是否为间接指针（内部用，try_inline 路径）。
 * 须传入 ctx->module_ref，否则 let Pair 等会误判为形参指针槽。
 */
static int32_t glue_local_var_slot_holds_indirect_ptr(struct ast_ASTArena *arena, int32_t expr_ref,
                                                      uint8_t *asm_ctx) {
  struct ast_Module *mod_ref = 0;
  if (asm_ctx)
    mod_ref = ((struct glue_AsmFuncCtx *)asm_ctx)->module_ref;
  return asm_local_var_slot_holds_indirect_ptr(arena, expr_ref, mod_ref, asm_ctx);
}

/**
 * 将局部 VAR 有效地址装入 rax/x0（指针槽 load，值槽 lea）。
 */
static int32_t glue_enc_local_slot_ptr_or_addr(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                              int32_t arg_ref, int32_t slot_off, int32_t ta, uint8_t *asm_ctx) {
  if (glue_local_var_slot_holds_indirect_ptr(arena, arg_ref, asm_ctx) != 0)
    return backend_enc_load_rbp_to_rax_arch(elf_ctx, slot_off, ta);
  return backend_enc_lea_rbp_to_rax_arch(elf_ctx, slot_off, ta);
}

/** 小 struct 按值返回：struct_lit 字段数上限（Pair 等）。 */
#define GLUE_INLINE_MAX_STRUCT_LIT_FIELDS 8

/**
 * expr 是否为 func 第 param_ix 形参同名 VAR。
 */
static int32_t glue_expr_is_func_param_at(struct ast_ASTArena *arena, struct ast_Module *mod, int32_t func_idx,
                                          int32_t expr_ref, int32_t param_ix) {
  uint8_t pbuf[32];
  uint8_t vbuf[64];
  int32_t plen;
  int32_t vlen;
  int32_t k;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != GLUE_EXPR_VAR)
    return 0;
  plen = pipeline_asm_module_func_param_name_len_at(mod, func_idx, param_ix);
  vlen = pipeline_expr_var_name_len(arena, expr_ref);
  if (plen <= 0 || plen != vlen)
    return 0;
  pipeline_asm_module_func_param_name_copy32(mod, func_idx, param_ix, pbuf);
  pipeline_expr_var_name_into(arena, expr_ref, vbuf);
  k = 0;
  while (k < plen) {
    if (pbuf[k] != vbuf[k])
      return 0;
    k = k + 1;
  }
  return 1;
}

/**
 * struct_lit 第 field_j 字段 init 来自哪一形参；成功写 out_param_ix。
 */
static int32_t glue_struct_lit_field_init_param_index(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                      int32_t func_idx, int32_t lit_ref, int32_t field_j,
                                                      int32_t *out_param_ix) {
  int32_t init_ref;
  int32_t np;
  int32_t pi;
  if (!out_param_ix)
    return -1;
  init_ref = pipeline_expr_struct_lit_init_ref(arena, lit_ref, field_j);
  if (init_ref <= 0)
    return -1;
  np = pipeline_asm_module_func_num_params_at(mod, func_idx);
  pi = 0;
  while (pi < np) {
    if (glue_expr_is_func_param_at(arena, mod, func_idx, init_ref, pi) != 0) {
      *out_param_ix = pi;
      return 0;
    }
    pi = pi + 1;
  }
  return -1;
}

/**
 * 函数体是否为 `return Struct { f: param… }`（各字段 init 均为形参 VAR）。
 */
static int32_t glue_fold_func_returns_param_struct_lit(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                       int32_t func_idx, int32_t *out_lit_ref) {
  int32_t ret_ref;
  int32_t nf;
  int32_t fj;
  int32_t pix;
  if (!out_lit_ref)
    return 0;
  /** struct lit fold 须走 module body_ref；backend.o 桩 fold 可能返回非 0 但非 STRUCT_LIT。 */
  ret_ref = glue_fold_func_return_operand_ref_module(arena, mod, func_idx);
  if (ret_ref <= 0)
    ret_ref = backend_fold_func_return_operand_ref(arena, mod, func_idx);
  if (ret_ref <= 0 || pipeline_expr_kind_ord_at(arena, ret_ref) != GLUE_EXPR_STRUCT_LIT)
    return 0;
  nf = pipeline_expr_struct_lit_num_fields(arena, ret_ref);
  if (nf <= 0 || nf > GLUE_INLINE_MAX_STRUCT_LIT_FIELDS)
    return 0;
  fj = 0;
  while (fj < nf) {
    if (glue_struct_lit_field_init_param_index(arena, mod, func_idx, ret_ref, fj, &pix) != 0)
      return 0;
    fj = fj + 1;
  }
  *out_lit_ref = ret_ref;
  return 1;
}

/**
 * struct_lit 中字段名 fn/fnlen 对应的字段下标；失败返回 -1。
 */
static int32_t glue_struct_lit_field_index_by_name(struct ast_ASTArena *arena, int32_t lit_ref, uint8_t *fn,
                                                   int32_t fnlen) {
  int32_t nf;
  int32_t j;
  uint8_t sb[64];
  int32_t slen;
  int32_t k;
  nf = pipeline_expr_struct_lit_num_fields(arena, lit_ref);
  j = 0;
  while (j < nf) {
    slen = pipeline_expr_struct_lit_field_name_len(arena, lit_ref, j);
    if (slen == fnlen && slen > 0 && slen <= 63) {
      pipeline_expr_struct_lit_field_name_into(arena, lit_ref, j, sb);
      k = 0;
      while (k < slen) {
        if (sb[k] != fn[k])
          break;
        k = k + 1;
      }
      if (k == slen)
        return j;
    }
    j = j + 1;
  }
  return -1;
}

/**
 * 外层 field_access 经 inner CALL（struct_lit 按值返回）映射到实参 expr_ref。
 */
static int32_t glue_inner_call_arg_for_field_access(struct ast_ASTArena *arena, struct glue_AsmFuncCtx *ctx,
                                                    int32_t inner_call_ref, int32_t outer_field_ref,
                                                    int32_t *out_arg_ref) {
  struct ast_ASTArena *callee_arena;
  struct ast_Module *callee_mod;
  int32_t inner_fi;
  int32_t lit_ref;
  int32_t fj;
  int32_t pix;
  int32_t flen;
  uint8_t fname[64];
  if (!out_arg_ref || inner_call_ref <= 0 || outer_field_ref <= 0 || !ctx)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, inner_call_ref) != GLUE_EXPR_CALL)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, outer_field_ref) != GLUE_EXPR_FIELD_ACCESS)
    return 0;
  if (glue_call_lookup_callee_mod_fi_arena(arena, inner_call_ref, ctx, &callee_arena, &callee_mod, &inner_fi) == 0)
    return 0;
  if (glue_fold_func_returns_param_struct_lit(callee_arena, callee_mod, inner_fi, &lit_ref) == 0)
    return 0;
  flen = pipeline_expr_field_access_name_len(arena, outer_field_ref);
  if (flen <= 0 || flen > 63)
    return 0;
  pipeline_expr_field_access_name_into(arena, outer_field_ref, fname);
  fj = glue_struct_lit_field_index_by_name(callee_arena, lit_ref, fname, flen);
  if (fj < 0)
    return 0;
  if (glue_struct_lit_field_init_param_index(callee_arena, callee_mod, inner_fi, lit_ref, fj, &pix) != 0)
    return 0;
  *out_arg_ref = pipeline_expr_call_arg_ref(arena, inner_call_ref, pix);
  return (*out_arg_ref > 0) ? 1 : 0;
}

/**
 * ELF CALL 内联：同模块 f(arg0) 且 f 为 return p.f（param0 单字段）时字段 load。
 * 返回 1=已内联，0=未匹配，-1=错误。
 */
int32_t try_inline_param0_single_field_call_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                int32_t expr_ref, struct glue_AsmFuncCtx *ctx, int32_t ta) {
  struct ast_ASTArena *callee_arena;
  struct ast_Module *callee_mod;
  int32_t fi;
  int32_t ret_ref;
  int32_t off;
  int32_t arg_ref;
  uint8_t vname[64];
  int32_t vlen;
  int32_t slot_off;
  struct ast_Module *layout_mod;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return 0;
  if (pipeline_expr_call_num_args_at(arena, expr_ref) != 1)
    return 0;
  if (glue_call_lookup_callee_mod_fi_arena(arena, expr_ref, ctx, &callee_arena, &callee_mod, &fi) == 0)
    return 0;
  if (backend_fold_func_returns_param0_single_field(callee_arena, callee_mod, fi) == 0)
    return 0;
  ret_ref = glue_try_fold_func_return_operand_ref(callee_arena, callee_mod, fi);
  if (ret_ref <= 0)
    return 0;
  /** 勿信 typeck 误填的 field_access_offset（跨 import 常见 fi*8）；只走 struct layout。 */
  off = pipeline_expr_field_access_layout_offset(callee_arena, callee_mod, ret_ref);
  arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
  if (arg_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, arg_ref) == GLUE_EXPR_CALL) {
    int32_t inner_arg;
    if (glue_inner_call_arg_for_field_access(arena, ctx, arg_ref, ret_ref, &inner_arg) == 0)
      return 0;
    if (backend_emit_expr_elf_slow(arena, elf_ctx, inner_arg, ctx, ta) != 0)
      return -1;
    return 1;
  }
  if (pipeline_expr_kind_ord_at(arena, arg_ref) != GLUE_EXPR_VAR)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, arg_ref);
  if (vlen <= 0)
    return 0;
  pipeline_expr_var_name_into(arena, arg_ref, vname);
  slot_off = glue_try_inline_local_slot_off((uint8_t *)ctx, arena, vname, vlen);
  if (slot_off < 0)
    return 0;
  if (glue_enc_local_slot_ptr_or_addr(arena, elf_ctx, arg_ref, slot_off, ta, (uint8_t *)ctx) != 0)
    return -1;
  if (backend_enc_add_imm_to_rax_arch(elf_ctx, off, ta) != 0)
    return -1;
  if (backend_enc_load_32_from_rax_arch(elf_ctx, ta) != 0)
    return -1;
  return 1;
}

/**
 * 在 dep 编译单元 struct layout 中按字段名查偏移（import Pair 等 caller 无 layout 时）。
 */
static int32_t glue_dep_module_field_offset_by_name(struct ast_PipelineDepCtx *pctx, uint8_t *field_name,
                                                    int32_t flen) {
  int32_t nd;
  int32_t di;
  int32_t k;
  int32_t j;
  if (!pctx || !field_name || flen <= 0)
    return -1;
  nd = pipeline_dep_ctx_ndep(pctx);
  di = 0;
  while (di < nd) {
    struct ast_Module *dm = pipeline_dep_ctx_module_at(pctx, di);
    if (dm) {
      for (k = 0; k < pipeline_module_num_struct_layouts_at(dm); k++) {
        for (j = 0; j < pipeline_module_struct_layout_num_fields(dm, k); j++) {
          int32_t fnlen = pipeline_module_struct_layout_field_name_len(dm, k, j);
          int32_t feq = 1;
          int32_t fi;
          if (fnlen != flen)
            continue;
          for (fi = 0; fi < fnlen; fi++) {
            uint8_t fb[64];
            pipeline_module_struct_layout_field_name_into(dm, k, j, fb);
            if (fb[fi] != field_name[fi]) {
              feq = 0;
              break;
            }
          }
          if (!feq)
            continue;
          return pipeline_module_struct_layout_field_offset_at(dm, k, j);
        }
      }
    }
    di = di + 1;
  }
  return -1;
}

/**
 * 解析 VAR 基址 FIELD_ACCESS 的字节偏移；import struct layout 在 dep 模块时走 deps 回落。
 */
static int32_t glue_inline_var_field_access_offset(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                   struct ast_PipelineDepCtx *pctx, uint8_t *asm_ctx,
                                                   int32_t fa_ref) {
  int32_t base_ref;
  int32_t base_ty;
  int32_t scope_br;
  int32_t kind;
  uint8_t vname[64];
  int32_t vlen;
  uint8_t struct_name[64];
  int32_t nlen;
  uint8_t field_name[64];
  int32_t flen;
  int32_t off;
  int32_t fi;
  int32_t body_ref;
  if (!arena || !mod || fa_ref <= 0)
    return -1;
  base_ref = pipeline_expr_field_access_base_ref(arena, fa_ref);
  if (base_ref <= 0 || pipeline_expr_kind_ord_at(arena, base_ref) != GLUE_EXPR_VAR)
    return -1;
  base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
  scope_br = asm_ctx ? asm_ctx_scope_block_ref_at(asm_ctx) : 0;
  if (base_ty <= 0 && scope_br > 0) {
    vlen = pipeline_expr_var_name_len(arena, base_ref);
    if (vlen > 0 && vlen <= 63) {
      pipeline_expr_var_name_into(arena, base_ref, vname);
      base_ty = pipeline_block_resolve_var_type_ref(arena, scope_br, vname, vlen);
    }
  }
  /** main final_expr 等 scope 未挂 sidecar 时：从当前 emit 函数体查 let 类型。 */
  if (base_ty <= 0 && asm_ctx) {
    fi = pipeline_asm_emit_func_index_c();
    vlen = pipeline_expr_var_name_len(arena, base_ref);
    if (fi >= 0 && fi < pipeline_module_num_funcs(mod) && vlen > 0 && vlen <= 63) {
      pipeline_expr_var_name_into(arena, base_ref, vname);
      body_ref = pipeline_module_func_body_ref_at(mod, fi);
      if (body_ref > 0)
        base_ty = pipeline_block_resolve_var_type_ref(arena, body_ref, vname, vlen);
    }
  }
  flen = pipeline_expr_field_access_name_len(arena, fa_ref);
  if (flen <= 0 || flen > 63)
    return -1;
  pipeline_expr_field_access_name_into(arena, fa_ref, field_name);
  /** import struct：caller 无 layout / base_ty 缺失时仍可从 dep 按字段名查 a/b 偏移。 */
  if (pctx) {
    off = glue_dep_module_field_offset_by_name(pctx, field_name, flen);
    if (off >= 0)
      return off;
  }
  if (base_ty <= 0)
    return -1;
  kind = pipeline_type_kind_ord_at(arena, base_ty);
  if (kind == GLUE_TYPE_PTR) {
    base_ty = pipeline_type_elem_ref_at(arena, base_ty);
    if (base_ty <= 0)
      return -1;
    kind = pipeline_type_kind_ord_at(arena, base_ty);
  }
  if (kind != GLUE_TYPE_NAMED)
    return -1;
  nlen = pipeline_type_named_name_into(arena, base_ty, struct_name);
  if (pctx) {
    off = typeck_get_field_offset_from_layout_deps(mod, pctx, struct_name, nlen, field_name, flen);
    if (off >= 0)
      return off;
  }
  return pipeline_expr_field_access_layout_offset(arena, mod, fa_ref);
}

/**
 * p.a + p.b 内联：同一 VAR 基址两字段 load32 + add（WPO-S3 cross_ret 等）。
 * 返回 1=已内联，0=未匹配，-1=错误。
 */
int32_t try_inline_var_field_sum_binop_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                           int32_t left_ref, int32_t right_ref, struct glue_AsmFuncCtx *ctx,
                                           int32_t ta) {
  struct ast_PipelineDepCtx *pctx;
  int32_t base_l;
  int32_t base_r;
  int32_t off_a;
  int32_t off_b;
  uint8_t vname[64];
  int32_t vlen;
  int32_t slot_off;
  if (!arena || !elf_ctx || !ctx || left_ref <= 0 || right_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, left_ref) != GLUE_EXPR_FIELD_ACCESS)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, right_ref) != GLUE_EXPR_FIELD_ACCESS)
    return 0;
  base_l = pipeline_expr_field_access_base_ref(arena, left_ref);
  base_r = pipeline_expr_field_access_base_ref(arena, right_ref);
  if (base_l <= 0 || base_r != base_l)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, base_l) != GLUE_EXPR_VAR)
    return 0;
  pctx = (struct ast_PipelineDepCtx *)ctx->dep_pipe;
  if (!pctx)
    pctx = pipeline_asm_emit_dep_pipe_c();
  if (!pctx)
    return 0;
  {
    struct ast_Module *dm;
    int32_t di;
    int32_t nd;
    off_a = -1;
    off_b = -1;
    nd = pipeline_dep_ctx_ndep(pctx);
    di = 0;
    while (di < nd && (off_a < 0 || off_b < 0)) {
      dm = pipeline_dep_ctx_module_at(pctx, di);
      if (dm) {
        if (off_a < 0)
          off_a = pipeline_expr_field_access_layout_offset(arena, dm, left_ref);
        if (off_b < 0)
          off_b = pipeline_expr_field_access_layout_offset(arena, dm, right_ref);
      }
      di = di + 1;
    }
    if (off_a < 0 || off_b < 0) {
      uint8_t fname_a[64];
      uint8_t fname_b[64];
      int32_t flen_a;
      int32_t flen_b;
      flen_a = pipeline_expr_field_access_name_len(arena, left_ref);
      flen_b = pipeline_expr_field_access_name_len(arena, right_ref);
      if (flen_a > 0 && flen_a <= 63 && flen_b > 0 && flen_b <= 63) {
        pipeline_expr_field_access_name_into(arena, left_ref, fname_a);
        pipeline_expr_field_access_name_into(arena, right_ref, fname_b);
        if (off_a < 0)
          off_a = glue_dep_module_field_offset_by_name(pctx, fname_a, flen_a);
        if (off_b < 0)
          off_b = glue_dep_module_field_offset_by_name(pctx, fname_b, flen_b);
      }
    }
  }
  if (off_a < 0 || off_b < 0)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, base_l);
  if (vlen <= 0)
    return 0;
  pipeline_expr_var_name_into(arena, base_l, vname);
  slot_off = glue_try_inline_local_slot_off((uint8_t *)ctx, arena, vname, vlen);
  if (slot_off < 0)
    return 0;
  if (glue_enc_local_slot_ptr_or_addr(arena, elf_ctx, base_l, slot_off, ta, (uint8_t *)ctx) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_add_imm_to_rax_arch(elf_ctx, off_a, ta) != 0)
    return -1;
  if (backend_enc_load_32_from_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_add_imm_to_rax_arch(elf_ctx, off_b, ta) != 0)
    return -1;
  if (backend_enc_load_32_from_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_add_rax_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  return 1;
}

/**
 * ELF CALL 内联：同模块 f(arg0) 且 f 为 return p.f0 + p.f1 时字段 load + add。
 * 返回 1=已内联，0=未匹配，-1=错误。
 */
int32_t try_inline_param0_field_sum_call_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                             int32_t expr_ref, struct glue_AsmFuncCtx *ctx, int32_t ta) {
  struct ast_ASTArena *callee_arena;
  struct ast_Module *callee_mod;
  int32_t fi;
  int32_t ret_ref;
  int32_t al;
  int32_t ar;
  int32_t off_a;
  int32_t off_b;
  int32_t arg_ref;
  uint8_t vname[64];
  int32_t vlen;
  int32_t slot_off;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return 0;
  if (pipeline_expr_call_num_args_at(arena, expr_ref) != 1)
    return 0;
  if (glue_call_lookup_callee_mod_fi_arena(arena, expr_ref, ctx, &callee_arena, &callee_mod, &fi) == 0)
    return 0;
  if (backend_fold_func_returns_param0_field_sum(callee_arena, callee_mod, fi) == 0)
    return 0;
  ret_ref = glue_try_fold_func_return_operand_ref(callee_arena, callee_mod, fi);
  if (ret_ref <= 0)
    return 0;
  al = pipeline_expr_binop_left_ref_at(callee_arena, ret_ref);
  ar = pipeline_expr_binop_right_ref_at(callee_arena, ret_ref);
  off_a = pipeline_expr_field_access_layout_offset(callee_arena, callee_mod, al);
  off_b = pipeline_expr_field_access_layout_offset(callee_arena, callee_mod, ar);
  arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
  if (arg_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, arg_ref) == GLUE_EXPR_CALL) {
    int32_t inner_arg_a;
    int32_t inner_arg_b;
    if (glue_inner_call_arg_for_field_access(arena, ctx, arg_ref, al, &inner_arg_a) == 0)
      return 0;
    if (glue_inner_call_arg_for_field_access(arena, ctx, arg_ref, ar, &inner_arg_b) == 0)
      return 0;
    if (backend_emit_expr_elf_slow(arena, elf_ctx, inner_arg_a, ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_emit_expr_elf_slow(arena, elf_ctx, inner_arg_b, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_add_rax_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    return 1;
  }
  if (pipeline_expr_kind_ord_at(arena, arg_ref) != GLUE_EXPR_VAR)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, arg_ref);
  if (vlen <= 0)
    return 0;
  pipeline_expr_var_name_into(arena, arg_ref, vname);
  slot_off = glue_try_inline_local_slot_off((uint8_t *)ctx, arena, vname, vlen);
  if (slot_off < 0)
    return 0;
  if (glue_enc_local_slot_ptr_or_addr(arena, elf_ctx, arg_ref, slot_off, ta, (uint8_t *)ctx) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_add_imm_to_rax_arch(elf_ctx, off_a, ta) != 0)
    return -1;
  if (backend_enc_load_32_from_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_add_imm_to_rax_arch(elf_ctx, off_b, ta) != 0)
    return -1;
  if (backend_enc_load_32_from_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_add_rax_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  return 1;
}

/**
 * ELF CALL 简单内联：同模块 f(x) 且 f 为 x+K 链时 emit 实参后 add K。
 * 返回 1=已内联，0=未匹配，-1=错误。
 */
int32_t try_inline_x_plus_k_call_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                     int32_t expr_ref, struct glue_AsmFuncCtx *ctx, int32_t ta) {
  struct ast_Module *mod_ref;
  int32_t callee_ref;
  int32_t fi;
  int32_t k;
  int32_t arg_ref;
  uint8_t cname[64];
  int32_t clen;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return 0;
  mod_ref = ctx->module_ref;
  if (!mod_ref)
    return 0;
  callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
  if (callee_ref <= 0 || pipeline_expr_kind_ord_at(arena, callee_ref) != GLUE_EXPR_VAR)
    return 0;
  if (pipeline_expr_call_num_args_at(arena, expr_ref) != 1)
    return 0;
  clen = pipeline_expr_var_name_len(arena, callee_ref);
  if (clen <= 0 || clen > 63)
    return 0;
  pipeline_expr_var_name_into(arena, callee_ref, cname);
  fi = glue_module_func_index_by_name(mod_ref, cname, clen);
  if (fi < 0)
    return 0;
  k = backend_fold_func_x_plus_k_chain(arena, mod_ref, fi, 0);
  if (k < 0)
    return 0;
  /**
   * k==0 时须确认为真 identity（return param0）；backend fold 链式 +0 可能误匹配 vec_*_reserve_one 等，
   * 内联后只剩实参 load，if (reserve_one(v)!=0) 等条件会变成 if (v!=0)。
   */
  if (k == 0) {
    int32_t ret_ref;
    uint8_t pname[64];
    uint8_t rname[64];
    int32_t plen;
    int32_t rlen;
    ret_ref = glue_fold_func_return_operand_ref_module(arena, mod_ref, fi);
    if (ret_ref <= 0)
      ret_ref = backend_fold_func_return_operand_ref(arena, mod_ref, fi);
    if (ret_ref <= 0 || pipeline_expr_kind_ord_at(arena, ret_ref) != GLUE_EXPR_VAR)
      return 0;
    plen = pipeline_module_func_param_name_len_at(mod_ref, fi, 0);
    rlen = pipeline_expr_var_name_len(arena, ret_ref);
    if (plen <= 0 || plen > 63 || rlen != plen)
      return 0;
    pipeline_module_func_param_name_copy32(mod_ref, fi, 0, pname);
    pipeline_expr_var_name_into(arena, ret_ref, rname);
    if (memcmp(pname, rname, (size_t)plen) != 0)
      return 0;
  }
  arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
  if (arg_ref <= 0)
    return -1;
  if (backend_emit_expr_elf_slow(arena, elf_ctx, arg_ref, ctx, ta) != 0)
    return -1;
  if (k != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, k, ta) != 0)
    return -1;
  return 1;
}

/** ARRAY_LIT 第 lane 个元素是否为整型常量；成功写 *out。 */
static int32_t glue_try_array_lit_lane_const_i32(struct ast_ASTArena *arena, int32_t arr_ref, int32_t lane,
                                                 int32_t *out) {
  int32_t elem_ref;
  if (!arena || arr_ref <= 0 || !out || lane < 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, arr_ref) != GLUE_EXPR_ARRAY_LIT)
    return 0;
  if (lane >= pipeline_expr_array_lit_num_elems_at(arena, arr_ref))
    return 0;
  elem_ref = pipeline_expr_array_lit_elem_ref(arena, arr_ref, lane);
  return glue_try_expr_const_i32(arena, elem_ref, out);
}

/** 向量逐 lane 标量 binop kind（与 pipeline_glue glue_is_vector_lane_scalar_binop_ko 一致）。 */
static int32_t glue_is_vector_lane_scalar_binop_ko(int32_t ko) {
  if (ko == 51)
    ko = 4;
  return (ko >= 4 && ko <= 13) ? 1 : 0;
}

/**
 * callee 是否为 `return param0 binop param1`（两形参、SIMD 向量返回）。
 * 成功写 *out_binop_ko（4=add,5=sub,6=mul,7=div,8=mod 等）。
 */
static int32_t glue_fold_func_returns_param01_vector_binop(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                           int32_t func_idx, int32_t *out_binop_ko) {
  int32_t ret_ref;
  int32_t ko;
  int32_t al;
  int32_t ar;
  int32_t ret_ty;
  if (!out_binop_ko || !arena || !mod || func_idx < 0)
    return 0;
  if (pipeline_module_func_num_params_at(mod, func_idx) != 2)
    return 0;
  ret_ty = pipeline_module_func_return_type_at(mod, func_idx);
  ret_ref = glue_try_fold_func_return_operand_ref(arena, mod, func_idx);
  if (ret_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, ret_ref);
  if (!glue_is_vector_lane_scalar_binop_ko(ko))
    return 0;
  /** typeck 常留默认 i32；若 return 已是向量 binop 形态则仍匹配。 */
  if (ret_ty > 0 &&
      asm_type_is_simd_vector_spelling(arena, ret_ty) == 0 && asm_type_is_simd_vector(arena, ret_ty) == 0 &&
      ko != 51)
    return 0;
  if (ko == 51)
    ko = 4;
  al = pipeline_expr_binop_left_ref_at(arena, ret_ref);
  ar = pipeline_expr_binop_right_ref_at(arena, ret_ref);
  if (glue_expr_is_func_param_at(arena, mod, func_idx, al, 0) == 0)
    return 0;
  if (glue_expr_is_func_param_at(arena, mod, func_idx, ar, 1) == 0)
    return 0;
  *out_binop_ko = ko;
  return 1;
}

/**
 * callee 是否为 `return param0[index_const]`（单形参、标量返回）；成功写 *out_lane。
 */
static int32_t glue_fold_func_returns_param0_index_const(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                         int32_t func_idx, int32_t *out_lane) {
  int32_t ret_ref;
  int32_t base_ref;
  int32_t idx_ref;
  int32_t lane;
  if (!out_lane || !arena || !mod || func_idx < 0)
    return 0;
  if (pipeline_module_func_num_params_at(mod, func_idx) != 1)
    return 0;
  ret_ref = glue_try_fold_func_return_operand_ref(arena, mod, func_idx);
  if (ret_ref <= 0 || pipeline_expr_kind_ord_at(arena, ret_ref) != GLUE_EXPR_INDEX)
    return 0;
  base_ref = pipeline_expr_index_base_ref(arena, ret_ref);
  idx_ref = pipeline_expr_index_index_ref(arena, ret_ref);
  if (glue_expr_is_func_param_at(arena, mod, func_idx, base_ref, 0) == 0)
    return 0;
  if (glue_try_expr_const_i32(arena, idx_ref, &lane) == 0)
    return 0;
  *out_lane = lane;
  return 1;
}

/**
 * WPO-S2 vec 特化：laneK(vec_binop([const…],[const…])) 编译期 fold 为标量 imm（rax）。
 * 典型：lane0(vec_add4([1,2,3,4],[10,20,30,40])) → 11。
 * 返回 1=已 fold，0=未匹配，-1=错误。
 */
int32_t try_inline_wpo_const_vector_lane_of_binop_call_elf(struct ast_ASTArena *arena,
                                                           struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                           struct glue_AsmFuncCtx *ctx, int32_t ta) {
  struct ast_Module *mod_ref;
  int32_t outer_callee_ref;
  int32_t outer_fi;
  int32_t lane;
  int32_t inner_call_ref;
  int32_t inner_callee_ref;
  int32_t inner_fi;
  int32_t binop_ko;
  int32_t arg0;
  int32_t arg1;
  int32_t av0;
  int32_t av1;
  int32_t folded;
  int32_t hi;
  uint8_t outer_name[64];
  uint8_t inner_name[64];
  int32_t olen;
  int32_t ilen;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != GLUE_EXPR_CALL)
    return 0;
  mod_ref = ctx->module_ref;
  if (!mod_ref)
    return 0;
  if (pipeline_expr_call_num_args_at(arena, expr_ref) != 1)
    return 0;
  outer_callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
  if (outer_callee_ref <= 0 || pipeline_expr_kind_ord_at(arena, outer_callee_ref) != GLUE_EXPR_VAR)
    return 0;
  olen = pipeline_expr_var_name_len(arena, outer_callee_ref);
  if (olen <= 0 || olen > 63)
    return 0;
  pipeline_expr_var_name_into(arena, outer_callee_ref, outer_name);
  outer_fi = glue_module_func_index_by_name(mod_ref, outer_name, olen);
  if (outer_fi < 0)
    return 0;
  if (glue_fold_func_returns_param0_index_const(arena, mod_ref, outer_fi, &lane) == 0)
    return 0;
  inner_call_ref = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
  if (inner_call_ref <= 0 || pipeline_expr_kind_ord_at(arena, inner_call_ref) != GLUE_EXPR_CALL)
    return 0;
  if (pipeline_expr_call_num_args_at(arena, inner_call_ref) != 2)
    return 0;
  inner_callee_ref = pipeline_expr_call_callee_ref_at(arena, inner_call_ref);
  if (inner_callee_ref <= 0 || pipeline_expr_kind_ord_at(arena, inner_callee_ref) != GLUE_EXPR_VAR)
    return 0;
  ilen = pipeline_expr_var_name_len(arena, inner_callee_ref);
  if (ilen <= 0 || ilen > 63)
    return 0;
  pipeline_expr_var_name_into(arena, inner_callee_ref, inner_name);
  inner_fi = glue_module_func_index_by_name(mod_ref, inner_name, ilen);
  if (inner_fi < 0)
    return 0;
  if (glue_fold_func_returns_param01_vector_binop(arena, mod_ref, inner_fi, &binop_ko) == 0)
    return 0;
  arg0 = pipeline_expr_call_arg_ref(arena, inner_call_ref, 0);
  arg1 = pipeline_expr_call_arg_ref(arena, inner_call_ref, 1);
  if (arg0 <= 0 || arg1 <= 0)
    return 0;
  if (glue_try_array_lit_lane_const_i32(arena, arg0, lane, &av0) == 0)
    return 0;
  if (glue_try_array_lit_lane_const_i32(arena, arg1, lane, &av1) == 0)
    return 0;
  if (glue_const_scalar_binop_eval_i32(binop_ko, av0, av1, &folded) == 0)
    return 0;
  hi = (folded < 0) ? -1 : 0;
  if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, folded, hi, ta) != 0)
    return -1;
  return 1;
}

/**
 * WPO-S2：两整型常量实参 + callee 为 `return param0 binop param1`（i32 标量）时编译期 fold 到 rax。
 * 返回 1=已内联，0=未匹配，-1=错误。
 */
int32_t try_inline_wpo_const_scalar_binop_call_elf(struct ast_ASTArena *arena,
                                                    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                    struct glue_AsmFuncCtx *ctx, int32_t ta) {
  struct ast_Module *mod_ref;
  int32_t callee_ref;
  int32_t fi;
  int32_t binop_ko;
  int32_t arg0;
  int32_t arg1;
  int32_t av0;
  int32_t av1;
  int32_t folded;
  int32_t hi;
  uint8_t cname[64];
  int32_t clen;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != GLUE_EXPR_CALL)
    return 0;
  mod_ref = ctx->module_ref;
  if (!mod_ref)
    return 0;
  if (pipeline_expr_call_num_args_at(arena, expr_ref) != 2)
    return 0;
  callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
  if (callee_ref <= 0 || pipeline_expr_kind_ord_at(arena, callee_ref) != GLUE_EXPR_VAR)
    return 0;
  clen = pipeline_expr_var_name_len(arena, callee_ref);
  if (clen <= 0 || clen > 63)
    return 0;
  pipeline_expr_var_name_into(arena, callee_ref, cname);
  fi = glue_module_func_index_by_name(mod_ref, cname, clen);
  if (fi < 0)
    return 0;
  if (glue_fold_func_returns_param01_scalar_binop(arena, mod_ref, fi, &binop_ko) == 0)
    return 0;
  arg0 = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
  arg1 = pipeline_expr_call_arg_ref(arena, expr_ref, 1);
  if (arg0 <= 0 || arg1 <= 0)
    return 0;
  if (glue_try_expr_const_i32(arena, arg0, &av0) == 0)
    return 0;
  if (glue_try_expr_const_i32(arena, arg1, &av1) == 0)
    return 0;
  if (glue_const_scalar_binop_eval_i32(binop_ko, av0, av1, &folded) == 0)
    return 0;
  hi = (folded < 0) ? -1 : 0;
  if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, folded, hi, ta) != 0)
    return -1;
  return 1;
}

/**
 * WPO-S2 monomorphize：SHUX_WPO_MONO=1 时将全常量实参 call 改调单态符号（零实参 thunk）。
 * 返回 1=已发射 call，0=未匹配或未启用，-1=错误。
 */
int32_t try_call_wpo_mono_symbol_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                     int32_t expr_ref, struct glue_AsmFuncCtx *ctx, int32_t ta) {
  struct ast_Module *mod_ref;
  int32_t callee_ref;
  int32_t fi;
  int32_t binop_ko;
  int32_t arg0;
  int32_t arg1;
  int32_t av0;
  int32_t av1;
  int32_t folded;
  int32_t args[2];
  char sym[128];
  int sym_len;
  uint8_t cname[64];
  int32_t clen;
  if (!getenv("SHUX_WPO_MONO"))
    return 0;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != GLUE_EXPR_CALL)
    return 0;
  mod_ref = ctx->module_ref;
  if (!mod_ref)
    return 0;
  if (pipeline_expr_call_num_args_at(arena, expr_ref) != 2)
    return 0;
  callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
  if (callee_ref <= 0 || pipeline_expr_kind_ord_at(arena, callee_ref) != GLUE_EXPR_VAR)
    return 0;
  clen = pipeline_expr_var_name_len(arena, callee_ref);
  if (clen <= 0 || clen > 63)
    return 0;
  pipeline_expr_var_name_into(arena, callee_ref, cname);
  cname[clen] = 0;
  fi = glue_module_func_index_by_name(mod_ref, cname, clen);
  if (fi < 0)
    return 0;
  if (glue_fold_func_returns_param01_scalar_binop(arena, mod_ref, fi, &binop_ko) == 0)
    return 0;
  arg0 = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
  arg1 = pipeline_expr_call_arg_ref(arena, expr_ref, 1);
  if (arg0 <= 0 || arg1 <= 0)
    return 0;
  if (glue_try_expr_const_i32(arena, arg0, &av0) == 0)
    return 0;
  if (glue_try_expr_const_i32(arena, arg1, &av1) == 0)
    return 0;
  if (glue_const_scalar_binop_eval_i32(binop_ko, av0, av1, &folded) == 0)
    return 0;
  glue_wpo_mono_register_thunk((const char *)cname, av0, av1, folded);
  args[0] = av0;
  args[1] = av1;
  sym_len = codegen_wpo_mono_sym_format((const char *)cname, 2, args, sym, (int)sizeof(sym));
  if (sym_len <= 0)
    return -1;
  if (backend_enc_call_arch(elf_ctx, (uint8_t *)sym, sym_len, ta) != 0)
    return -1;
  if (backend_enc_call_stack_cleanup_arch(elf_ctx, 0, ta) != 0)
    return -1;
  return 1;
}

/**
 * WPO-S2 vec mono：laneK(vec_binop([const…],[const…])) → bl 单态 thunk（零实参，rax=fold 结果）。
 * 符号形如 lane0__wpo_1_2_3_4_10_20_30_40（8 个 lane 常量实参 profile）。
 * 返回 1=已发射 call，0=未匹配或未启用，-1=错误。
 */
int32_t try_call_wpo_mono_vector_lane_of_binop_call_elf(struct ast_ASTArena *arena,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                          int32_t expr_ref, struct glue_AsmFuncCtx *ctx, int32_t ta) {
  struct ast_Module *mod_ref;
  int32_t outer_callee_ref;
  int32_t outer_fi;
  int32_t lane;
  int32_t inner_call_ref;
  int32_t inner_callee_ref;
  int32_t inner_fi;
  int32_t binop_ko;
  int32_t arg0;
  int32_t arg1;
  int32_t av0;
  int32_t av1;
  int32_t folded;
  int32_t mono_args[GLUE_WPO_MONO_MAX_ARGS];
  int32_t nargs;
  int32_t li;
  char sym[128];
  int sym_len;
  uint8_t outer_name[64];
  int32_t olen;
  if (!getenv("SHUX_WPO_MONO"))
    return 0;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != GLUE_EXPR_CALL)
    return 0;
  mod_ref = ctx->module_ref;
  if (!mod_ref)
    return 0;
  if (pipeline_expr_call_num_args_at(arena, expr_ref) != 1)
    return 0;
  outer_callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
  if (outer_callee_ref <= 0 || pipeline_expr_kind_ord_at(arena, outer_callee_ref) != GLUE_EXPR_VAR)
    return 0;
  olen = pipeline_expr_var_name_len(arena, outer_callee_ref);
  if (olen <= 0 || olen > 63)
    return 0;
  pipeline_expr_var_name_into(arena, outer_callee_ref, outer_name);
  outer_name[olen] = 0;
  outer_fi = glue_module_func_index_by_name(mod_ref, outer_name, olen);
  if (outer_fi < 0)
    return 0;
  if (glue_fold_func_returns_param0_index_const(arena, mod_ref, outer_fi, &lane) == 0)
    return 0;
  inner_call_ref = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
  if (inner_call_ref <= 0 || pipeline_expr_kind_ord_at(arena, inner_call_ref) != GLUE_EXPR_CALL)
    return 0;
  if (pipeline_expr_call_num_args_at(arena, inner_call_ref) != 2)
    return 0;
  inner_callee_ref = pipeline_expr_call_callee_ref_at(arena, inner_call_ref);
  if (inner_callee_ref <= 0 || pipeline_expr_kind_ord_at(arena, inner_callee_ref) != GLUE_EXPR_VAR)
    return 0;
  {
    uint8_t inner_name[64];
    int32_t ilen;
    ilen = pipeline_expr_var_name_len(arena, inner_callee_ref);
    if (ilen <= 0 || ilen > 63)
      return 0;
    pipeline_expr_var_name_into(arena, inner_callee_ref, inner_name);
    inner_fi = glue_module_func_index_by_name(mod_ref, inner_name, ilen);
  }
  if (inner_fi < 0)
    return 0;
  if (glue_fold_func_returns_param01_vector_binop(arena, mod_ref, inner_fi, &binop_ko) == 0)
    return 0;
  arg0 = pipeline_expr_call_arg_ref(arena, inner_call_ref, 0);
  arg1 = pipeline_expr_call_arg_ref(arena, inner_call_ref, 1);
  if (arg0 <= 0 || arg1 <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, arg0) != GLUE_EXPR_ARRAY_LIT ||
      pipeline_expr_kind_ord_at(arena, arg1) != GLUE_EXPR_ARRAY_LIT)
    return 0;
  nargs = pipeline_expr_array_lit_num_elems_at(arena, arg0);
  if (nargs <= 0 || nargs != pipeline_expr_array_lit_num_elems_at(arena, arg1))
    return 0;
  if (nargs > GLUE_WPO_MONO_MAX_ARGS / 2)
    return 0;
  for (li = 0; li < nargs; li++) {
    int32_t e0;
    int32_t e1;
    if (glue_try_array_lit_lane_const_i32(arena, arg0, li, &e0) == 0)
      return 0;
    if (glue_try_array_lit_lane_const_i32(arena, arg1, li, &e1) == 0)
      return 0;
    mono_args[li] = e0;
    mono_args[nargs + li] = e1;
  }
  if (glue_try_array_lit_lane_const_i32(arena, arg0, lane, &av0) == 0)
    return 0;
  if (glue_try_array_lit_lane_const_i32(arena, arg1, lane, &av1) == 0)
    return 0;
  if (glue_const_scalar_binop_eval_i32(binop_ko, av0, av1, &folded) == 0)
    return 0;
  glue_wpo_mono_register_thunk_n((const char *)outer_name, nargs * 2, mono_args, folded);
  sym_len = codegen_wpo_mono_sym_format((const char *)outer_name, nargs * 2, mono_args, sym, (int)sizeof(sym));
  if (sym_len <= 0)
    return -1;
  if (backend_enc_call_arch(elf_ctx, (uint8_t *)sym, sym_len, ta) != 0)
    return -1;
  if (backend_enc_call_stack_cleanup_arch(elf_ctx, 0, ta) != 0)
    return -1;
  return 1;
}

extern int32_t pipeline_expr_struct_lit_field_offset_at(struct ast_ASTArena *a, struct ast_Module *m,
                                                        int32_t expr_ref, int32_t field_ix);
extern int32_t pipeline_expr_struct_lit_field_store_sz(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref,
                                                     int32_t field_ix);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                          int32_t store_size, int32_t ta);

/**
 * 零实参 CALL 的 callee 是否为 `default_allocator` / `heap.default_allocator`。
 */
static int32_t glue_call_is_zero_arg_default_allocator(struct ast_ASTArena *arena, int32_t call_ref) {
  int32_t callee_ref;
  int32_t nlen;
  int32_t narg;
  uint8_t nm[64];
  if (!arena || call_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, call_ref) != GLUE_EXPR_CALL)
    return 0;
  narg = pipeline_expr_call_num_args_at(arena, call_ref);
  if (narg != 0) {
    if (getenv("SHUX_ASM_DEBUG"))
      fprintf(stderr, "shux: default_allocator call narg=%d ref=%d\n", (int)narg, (int)call_ref);
    return 0;
  }
  callee_ref = pipeline_expr_call_callee_ref_at(arena, call_ref);
  if (callee_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, callee_ref) == GLUE_EXPR_VAR) {
    nlen = pipeline_expr_var_name_len(arena, callee_ref);
    if (nlen <= 0 || nlen > 63)
      return 0;
    pipeline_expr_var_name_into(arena, callee_ref, nm);
    return (nlen == 17 && memcmp(nm, "default_allocator", 17) == 0) ? 1 : 0;
  }
  if (pipeline_expr_kind_ord_at(arena, callee_ref) == 44) {
    nlen = pipeline_expr_field_access_name_len(arena, callee_ref);
    if (nlen <= 0 || nlen > 63)
      return 0;
    pipeline_expr_field_access_name_into(arena, callee_ref, nm);
    if (nlen == 17 && memcmp(nm, "default_allocator", 17) == 0)
      return 1;
    if (getenv("SHUX_ASM_DEBUG"))
      fprintf(stderr, "shux: default_allocator field callee nlen=%d ref=%d\n", (int)nlen, (int)callee_ref);
    return 0;
  }
  if (getenv("SHUX_ASM_DEBUG"))
    fprintf(stderr, "shux: default_allocator callee kind=%d ref=%d call=%d\n",
            (int)pipeline_expr_kind_ord_at(arena, callee_ref), (int)callee_ref, (int)call_ref);
  return 0;
}

/**
 * const struct lit 单字段是否可内联到 let 栈槽（仅校验，不发射指令）。
 */
static int32_t glue_const_struct_lit_field_can_inline(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                      int32_t func_idx, int32_t lit_ref, int32_t fj) {
  int32_t init_ref;
  int32_t ko;
  int32_t pix;
  init_ref = pipeline_expr_struct_lit_init_ref(arena, lit_ref, fj);
  if (init_ref <= 0)
    return 0;
  if (glue_struct_lit_field_init_param_index(arena, mod, func_idx, lit_ref, fj, &pix) == 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, init_ref);
  if (ko == GLUE_EXPR_CALL)
    return glue_call_is_zero_arg_default_allocator(arena, init_ref);
  return (ko == 0 || ko == 1 || ko == 2) ? 1 : 0;
}

/**
 * default_allocator() 内联：call runtime default_allocator，按 fsz 写入 rbx+foff（8 或 16B）。
 */
static int32_t glue_emit_default_allocator_to_rbx_offset(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t foff,
                                                         int32_t fsz, int32_t ta) {
  static const uint8_t da_sym[28] = "std_heap_default_allocator";
  if (backend_enc_call_arch(elf_ctx, (uint8_t *)da_sym, 27, ta) != 0)
    return -1;
  if (fsz <= 0)
    fsz = 8;
  if (fsz > 16)
    fsz = 16;
  if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff, fsz, ta) != 0)
    return -1;
  /** Allocator 16B：仅写低 8B 时 kind=heap 但 arena 字段未清零，reserve 读 al.kind 越界。 */
  if (fsz >= 16)
    return 0;
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0)
    return -1;
  return backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff + 8, 8, ta);
}

/**
 * 函数体是否为 `return Struct { f: 常量… }`（各字段 init 均为整型/浮点字面量，无形参）。
 */
static int32_t glue_fold_func_returns_const_struct_lit(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                       int32_t func_idx, int32_t *out_lit_ref) {
  int32_t ret_ref;
  int32_t nf;
  int32_t fj;
  int32_t init_ref;
  int32_t pix;
  int32_t ko;
  if (!out_lit_ref)
    return 0;
  /** 与 param struct lit fold 一致：module body 优先，backend 桩次之。 */
  ret_ref = glue_fold_func_return_operand_ref_module(arena, mod, func_idx);
  if (ret_ref <= 0)
    ret_ref = backend_fold_func_return_operand_ref(arena, mod, func_idx);
  if (ret_ref <= 0 || pipeline_expr_kind_ord_at(arena, ret_ref) != GLUE_EXPR_STRUCT_LIT) {
    if (getenv("SHUX_ASM_DEBUG"))
      fprintf(stderr, "shux: const_struct fold miss ret fi=%d ret_ref=%d kind=%d\n", (int)func_idx, (int)ret_ref,
              ret_ref > 0 ? (int)pipeline_expr_kind_ord_at(arena, ret_ref) : -1);
    return 0;
  }
  nf = pipeline_expr_struct_lit_num_fields(arena, ret_ref);
  if (nf <= 0 || nf > GLUE_INLINE_MAX_STRUCT_LIT_FIELDS)
    return 0;
  fj = 0;
  while (fj < nf) {
    init_ref = pipeline_expr_struct_lit_init_ref(arena, ret_ref, fj);
    if (init_ref <= 0)
      return 0;
    if (glue_struct_lit_field_init_param_index(arena, mod, func_idx, ret_ref, fj, &pix) == 0)
      return 0;
    ko = pipeline_expr_kind_ord_at(arena, init_ref);
    /** vec_u8_new 等：Struct 末字段可为零实参 default_allocator() CALL。 */
    if (ko == GLUE_EXPR_CALL) {
      if (glue_call_is_zero_arg_default_allocator(arena, init_ref) == 0) {
        if (getenv("SHUX_ASM_DEBUG"))
          fprintf(stderr, "shux: const_struct fold miss call fi=%d fj=%d init=%d\n", (int)func_idx, (int)fj,
                  (int)init_ref);
        return 0;
      }
    } else if (ko != 0 && ko != 1 && ko != 2) {
      if (getenv("SHUX_ASM_DEBUG"))
        fprintf(stderr, "shux: const_struct fold miss ko fi=%d fj=%d ko=%d init=%d\n", (int)func_idx, (int)fj, (int)ko,
                (int)init_ref);
      return 0;
    }
    fj = fj + 1;
  }
  *out_lit_ref = ret_ref;
  return 1;
}

/**
 * let v: Struct = mk() 内联：零实参且 callee 为 return Struct { 常量… } 时，字段直写 let 栈槽。
 * 返回 1=已内联，0=未匹配，-1=错误。
 */
int32_t try_inline_const_struct_lit_return_call_to_slot_elf(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t call_ref, struct glue_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t stack_slot_off) {
  struct ast_ASTArena *callee_arena;
  struct ast_Module *callee_mod;
  int32_t fi;
  int32_t lit_ref;
  int32_t nf;
  int32_t fj;
  int32_t init_ref;
  int32_t foff;
  int32_t fsz;
  if (!arena || !elf_ctx || !ctx || call_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, call_ref) != GLUE_EXPR_CALL)
    return 0;
  if (pipeline_expr_call_num_args_at(arena, call_ref) != 0)
    return 0;
  if (glue_call_lookup_callee_mod_fi_arena(arena, call_ref, ctx, &callee_arena, &callee_mod, &fi) == 0) {
    if (getenv("SHUX_ASM_DEBUG"))
      fprintf(stderr, "shux: const_struct_call_inline miss lookup call_ref=%d\n", (int)call_ref);
    return 0;
  }
  if (glue_fold_func_returns_const_struct_lit(callee_arena, callee_mod, fi, &lit_ref) == 0) {
    if (getenv("SHUX_ASM_DEBUG"))
      fprintf(stderr, "shux: const_struct_call_inline miss fold fi=%d\n", (int)fi);
    return 0;
  }
  nf = pipeline_expr_struct_lit_num_fields(callee_arena, lit_ref);
  /** 预检全部字段可内联后再发射，避免部分写入后回落 CALL+8B store 破坏栈槽。 */
  fj = 0;
  while (fj < nf) {
    if (glue_const_struct_lit_field_can_inline(callee_arena, callee_mod, fi, lit_ref, fj) == 0) {
      if (getenv("SHUX_ASM_DEBUG"))
        fprintf(stderr, "shux: const_struct_call_inline miss field fj=%d fi=%d\n", (int)fj, (int)fi);
      return 0;
    }
    fj = fj + 1;
  }
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  fj = 0;
  while (fj < nf) {
    init_ref = pipeline_expr_struct_lit_init_ref(callee_arena, lit_ref, fj);
    foff = pipeline_expr_struct_lit_field_offset_at(callee_arena, callee_mod, lit_ref, fj);
    fsz = pipeline_expr_struct_lit_field_store_sz(callee_arena, callee_mod, lit_ref, fj);
    if (pipeline_expr_kind_ord_at(callee_arena, init_ref) == GLUE_EXPR_CALL) {
      /** default_allocator()：直写 kind=heap + null arena，勿 call 返回悬空栈指针。 */
      if (glue_call_is_zero_arg_default_allocator(callee_arena, init_ref) == 0)
        return 0;
      if (glue_emit_default_allocator_to_rbx_offset(elf_ctx, foff, fsz, ta) != 0)
        return -1;
    } else if (backend_emit_expr_elf_slow(callee_arena, elf_ctx, init_ref, ctx, ta) != 0) {
      return -1;
    } else if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff, fsz, ta) != 0) {
      return -1;
    }
    fj = fj + 1;
  }
  if (getenv("SHUX_ASM_DEBUG"))
    fprintf(stderr, "shux: const_struct_call_inline OK lit_ref=%d nf=%d fi=%d\n", (int)lit_ref, (int)nf, (int)fi);
  return 1;
}

/**
 * let p: Struct = mk(...) 内联：callee 为 return Struct { f: param… } 时，CALL 实参直写 let 栈槽。
 * 返回 1=已内联，0=未匹配，-1=错误。
 */
int32_t try_inline_struct_lit_return_call_to_slot_elf(struct ast_ASTArena *arena,
                                                      struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t call_ref,
                                                      struct glue_AsmFuncCtx *ctx, int32_t ta,
                                                      int32_t stack_slot_off) {
  struct ast_ASTArena *callee_arena;
  struct ast_Module *callee_mod;
  int32_t fi;
  int32_t lit_ref;
  int32_t nf;
  int32_t fj;
  int32_t pix;
  int32_t arg_ref;
  int32_t foff;
  int32_t fsz;
  if (!arena || !elf_ctx || !ctx || call_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, call_ref) != GLUE_EXPR_CALL)
    return 0;
  if (glue_call_lookup_callee_mod_fi_arena(arena, call_ref, ctx, &callee_arena, &callee_mod, &fi) == 0)
    return 0;
  if (glue_fold_func_returns_param_struct_lit(callee_arena, callee_mod, fi, &lit_ref) == 0)
    return 0;
  nf = pipeline_expr_struct_lit_num_fields(callee_arena, lit_ref);
  if (nf <= 0 || nf > GLUE_INLINE_MAX_STRUCT_LIT_FIELDS)
    return 0;
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  fj = 0;
  while (fj < nf) {
    if (glue_struct_lit_field_init_param_index(callee_arena, callee_mod, fi, lit_ref, fj, &pix) != 0)
      return -1;
    arg_ref = pipeline_expr_call_arg_ref(arena, call_ref, pix);
    if (arg_ref <= 0)
      return -1;
    foff = pipeline_expr_struct_lit_field_offset_at(callee_arena, callee_mod, lit_ref, fj);
    fsz = pipeline_expr_struct_lit_field_store_sz(callee_arena, callee_mod, lit_ref, fj);
    if (backend_emit_expr_elf_slow(arena, elf_ctx, arg_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff, fsz, ta) != 0)
      return -1;
    fj = fj + 1;
  }
  return 1;
}
