/**
 * pipeline_asm_emit_index_helpers.c — asm ELF INDEX residual helpers domain
 * (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding INDEX support helpers
 * that pipeline_asm_emit_index.c (esz + emit_index + addr_of + deref face)
 * depends on:
 * - glue_emit_module_from_ctx / param+local slot ptr load faces
 *   (stack_off_is_emit_param_ptr_slot, local_var_slot_needs_ptr_load,
 *   func_param_is_indirect_struct_slot)
 * - glue_field_access_field_type_ref_c / fixed_array_total_bytes /
 *   glue_index_elem_byte_sz_from_type_ref_c (INDEX stride inference)
 * - try_index_* forest (base→rax/rbx, assign-addr→rbx, eff_addr→rax;
 *   lit/var/add/sub/mul nested shapes + index scratch cache)
 *   · wave178: INDEX expr shape peel forest pure
 *     (var_plus_var_pair / var_add3 / var_minus_var_pair / var_minus_add3 /
 *      var_subadd3 / var_subsub3) — residual try_index faces call pure peel
 *   · wave179: local-slot ptr/addr + field-slot deref pure
 *     (enc_local_slot_ptr_or_addr{,_rbx}, index_deref_ptr_field_slot_{rax,rbx})
 *   · wave180: type/stride helpers pure
 *     (fixed_array_total_bytes, index_elem_byte_sz_from_type_ref,
 *      var_expr_type_ref_with_decl_fallback)
 *   · wave181: simple try_index assign-addr→rbx forest pure
 *     (var_lit / var_idx / plus_lit / plus_var / minus_lit / minus_var /
 *      mul_lit / mul_var) — residual base_to_rbx stays host; nested
 *      add3/subadd3/eff_addr still residual
 * - glue_emit_soa_index_field_addr_elf_c (DoD column-major arr[i].field)
 * - pipeline_asm_emit_lvalue_eff_addr_{elf,text}_c (VAR / FIELD / INDEX;
 *   ELF also DEREF; text twin folded wave1013 G.7 有则补全)
 *
 * G.7: single product-mega INDEX residual-helper face — do not open a second
 * try_index forest or lvalue_eff_addr path. Face emitters stay in
 * pipeline_asm_emit_index.c; index assign finish_store / bulk_mem_copy_spills /
 * Chaitin spill live in pipeline_asm_emit_spill.c (same TU, next include);
 * glue_emit_index_eff_addr_scaled_elf_c + local_slot_text live in
 * runtime_pipeline_abi pure (wave147 pure-owned leave).
 *
 * Callers: pipeline_asm_emit_index.c; assign INDEX lhs; call-arg base;
 * field_access INDEX-rooted chains; expr_elf_rec INDEX/ADDR_OF/DEREF;
 * text path M8-tail / backend wrappers for lvalue text.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c immediately
 * after pipeline_asm_emit_struct_let.c (before pipeline_asm_emit_spill.c).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 *   · LINUX+MACOS x86_64 SysV — lea/load slot + scaled index
 *   · MACOS|ARM64 AAPCS64 — index scratch / ldur co-path
 */

/* Forward decls / callees defined elsewhere in the same TU:
 * - pipeline_asm_index_elem_byte_sz_c (pipeline_asm_emit_index.c, later include)
 * - glue_field_access_effective_offset_c (def later near layout_offset)
 * - glue_type_size_simple / glue_type_ref_is_named_struct_layout_elf_c
 *   (named_struct body in call_args leaf wave1017; same-TU forward here)
 * - glue_var_expr_stack_off_elf_c (def after assign/index includes)
 * - glue_emit_index_eff_addr_scaled_elf_c (runtime_pipeline_abi pure wave147)
 * - glue_binop_stack_spill_* / glue_asm73_var_prefers_stack_spill (defs later)
 * - pipeline_asm_emit_expr_elf_rec / backend_enc_* / asm_ctx_local_*
 * - g_pipeline_asm_emit_module / g_pipeline_asm_emit_func_index
 *
 * Note: binop_stack_spill CAP statics live here (shared index-scratch depth
 * with 7.3 spill); their method bodies live in pipeline_asm_emit_spill.c.
 */

/** INDEX 元素字节宽（前向声明，定义见本文件后部）。 */
/* wave140 pure-owned leave: esz authority in runtime_pipeline_abi pure (#[no_mangle]).
 * Residual assign/binop/spill/lvalue_eff_addr Cap-call this face. PLATFORM: SHARED. */
extern int32_t pipeline_asm_index_elem_byte_sz_c(struct ast_ASTArena *arena, int32_t expr_ref);
/* wave151 Cap residual: pure field_access leave (was static in field_access leaf). */
extern int32_t glue_field_access_call_base_rvalue_elf_c(struct ast_ASTArena *arena,
    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref, struct backend_AsmFuncCtx *ctx,
    int32_t ta, int32_t leave_addr);
/** VAR 基址 FIELD_ACCESS 有效偏移（定义见 pipeline_expr_field_access_layout_offset 附近）。 */
int32_t glue_field_access_effective_offset_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                   int32_t fa_ref);

/** AsmFuncCtx.module_ref 在 X/C 布局中的字节偏移（与 backend.x fill_param_slots 一致）。 */
#define GLUE_ASM_CTX_MODULE_REF_OFF 16

/**
 * 从 emit 全局或 ctx 取当前 module；frame_size 估算会临时改写 g_pipeline_asm_emit_module。
 * wave132 pure leave Cap residual: was static (pure struct_let links here).
 */
struct ast_Module *glue_emit_module_from_ctx(struct backend_AsmFuncCtx *ctx) {
  if (g_pipeline_asm_emit_module)
    return g_pipeline_asm_emit_module;
  if (ctx)
    return *(struct ast_Module **)((uint8_t *)ctx + GLUE_ASM_CTX_MODULE_REF_OFF);
  return NULL;
}

/**
 * fp 负偏移 stack_off 是否对应当前 emit 函数的 *T 形参槽（8,16,…）；driver eq_* 的 buf[i] 须 load 勿 lea。
 */
static int32_t glue_stack_off_is_emit_param_ptr_slot_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                        int32_t func_index, int32_t stack_off) {
  int32_t pi;
  int32_t np;
  int32_t pty;
  if (!arena || !mod || func_index < 0 || func_index >= mod->num_funcs || stack_off < 8)
    return 0;
  if ((stack_off & 7) != 0)
    return 0;
  pi = (stack_off - 8) / 8;
  np = pipeline_module_func_num_params_at(mod, func_index);
  if (pi < 0 || pi >= np)
    return 0;
  pty = pipeline_module_func_param_type_ref_at(mod, func_index, pi);
  if (pty <= 0)
    return 0;
  return pipeline_type_kind_ord_at(arena, pty) == 9 ? 1 : 0;
}

/**
 * 形参为定长 T[N] 且 CALL 侧 lea 传址时，槽内为 8B 指针（非内联数组 blob）。
 */
static int32_t glue_emit_func_param_is_indirect_array_slot_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                              int32_t var_expr_ref) {
  uint8_t vname[128];
  int32_t vlen;
  int32_t fi;
  int32_t pty;
  if (!arena || !mod || var_expr_ref <= 0 || pipeline_expr_kind_ord_at(arena, var_expr_ref) != GLUE_EXPR_KIND_VAR)
    return 0;
  fi = g_pipeline_asm_emit_func_index;
  if (fi < 0 || fi >= (int32_t)mod->num_funcs)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
  if (vlen <= 0 || vlen > 127)
    return 0;
  pipeline_expr_var_name_into(arena, var_expr_ref, vname);
  pty = pipeline_module_func_param_type_ref_for_name(mod, fi, vname, vlen);
  return glue_type_is_fixed_array(arena, pty);
}

/** Same-TU forward: body in pipeline_asm_emit_call_args.c (wave1017 G.7 fold). */
static int32_t glue_type_ref_is_named_struct_layout_elf_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                            int32_t ty_ref);
int32_t glue_type_size_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref, int32_t depth);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);

/**
 * Named-struct formal param home is never a hidden pointer under SysV product paths.
 * PLATFORM: LINUX+MACOS x86_64 SysV —
 * - ≤8B / 9–16B INTEGER dual-GP / >16B MEMORY: home holds by-value (or full MEMORY copy)
 * - field/index use lea home+off, not load-pointer-then-index
 * G.7: matches CALL dual-GP (9–16B) + MEMORY push (>16B); Allocator dual-home closed here.
 * 供 pipeline_glue 与 backend_try_inline_dispatch 共用（API 保留；恒 0）。
 */
int32_t pipeline_asm_emit_func_param_is_indirect_struct_slot_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                                int32_t var_expr_ref) {
  (void)arena;
  (void)mod;
  (void)var_expr_ref;
  return 0;
}

/**
 * 局部 VAR 槽是否须 load 槽内指针（*T 形参 / T[N] 形参传址 / 块内 let *T）；resolved 缺失时按 stack_off 回落形参表。
 * wave332c: TYPE_SLICE formal is `struct xlang_slice_* *` (codegen.x); local let is by-value fat.
 * Without this, a.length / a[i] on slice params lea the pointer slot and read stack junk
 * (Ubuntu freestanding sum([1,2,3]) / len(b) residual after call-arg stamp).
 */
/* wave147 pure Cap residual: static→extern (index_eff_addr pure leave). PLATFORM: SHARED. */
int32_t glue_local_var_slot_needs_ptr_load_elf_c(struct ast_ASTArena *arena, int32_t var_expr_ref,
                                                         int32_t stack_off, struct backend_AsmFuncCtx *ctx) {
  struct ast_Module *mod;
  if (asm_local_var_slot_holds_indirect_ptr(arena, var_expr_ref, glue_emit_module_from_ctx(ctx), (uint8_t *)ctx) != 0)
    return 1;
  mod = glue_emit_module_from_ctx(ctx);
  if (mod && g_pipeline_asm_emit_func_index >= 0 &&
      pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena, mod, var_expr_ref) != 0)
    return 1;
  if (mod && g_pipeline_asm_emit_func_index >= 0 &&
      glue_emit_func_param_is_indirect_array_slot_c(arena, mod, var_expr_ref) != 0)
    return 1;
  if (mod && g_pipeline_asm_emit_func_index >= 0 &&
      glue_stack_off_is_emit_param_ptr_slot_c(arena, mod, g_pipeline_asm_emit_func_index, stack_off) != 0)
    return 1;
  /*
   * PLATFORM: SHARED — TYPE_SLICE params lower as pointers (1 GP home).
   * Local TYPE_SLICE lets stay by-value dual-GP (needs_ptr_load=0).
   * G.7: complete the *T / T[N] / T[] param pointer set.
   */
  if (mod && g_pipeline_asm_emit_func_index >= 0 && arena && var_expr_ref > 0 &&
      pipeline_expr_kind_ord_at(arena, var_expr_ref) == (int32_t)ast_ExprKind_EXPR_VAR) {
    uint8_t vname[128];
    int32_t vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
    int32_t pty;
    if (vlen > 0 && vlen <= 63) {
      pipeline_expr_var_name_into(arena, var_expr_ref, vname);
      pty = pipeline_module_func_param_type_ref_for_name(mod, g_pipeline_asm_emit_func_index, vname, vlen);
      if (pty > 0 && pipeline_type_kind_ord_at(arena, pty) == (int32_t)ast_TypeKind_TYPE_SLICE)
        return 1;
    }
  }
  return 0;
}

/**
 * wave179 pure-owned: local VAR slot → rax/rbx (load *T/slice* / lea by-value).
 * Cap residual try_index / lvalue call pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX local slot.
 */
int32_t glue_enc_local_slot_ptr_or_addr_elf_c(struct ast_ASTArena *arena,
                                                     struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t var_expr_ref,
                                                     int32_t stack_off, struct backend_AsmFuncCtx *ctx, int32_t ta);
int32_t glue_enc_local_slot_ptr_or_addr_rbx_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         int32_t var_expr_ref, int32_t stack_off,
                                                         struct backend_AsmFuncCtx *ctx, int32_t ta);

/** TYPE_PTR 在 TypeKind 序数表中的值（与 pipeline_asm_index_elem_byte_sz_c 一致）。 */
#define GLUE_TYPE_KIND_PTR 9

/**
 * struct layout 名与 TYPE_NAMED 对齐：精确相等或 type 为 vec.Vec_u8、layout 为 Vec_u8 等末段匹配。
 */
static int32_t glue_struct_layout_name_matches_type_name_c(struct ast_Module *mod, int32_t li, uint8_t *type_name,
                                                           int32_t type_len) {
  int32_t ln;
  int32_t j;
  if (!mod || li < 0 || !type_name || type_len <= 0)
    return 0;
  ln = pipeline_module_struct_layout_name_len(mod, li);
  if (ln <= 0)
    return 0;
  if (ln == type_len) {
    for (j = 0; j < ln; j++) {
      if (pipeline_module_struct_layout_name_byte_at(mod, li, j) != type_name[j])
        return 0;
    }
    return 1;
  }
  if (type_len > ln + 1 && type_name[type_len - ln - 1] == (uint8_t)'.') {
    for (j = 0; j < ln; j++) {
      if (pipeline_module_struct_layout_name_byte_at(mod, li, j) != type_name[type_len - ln + j])
        return 0;
    }
    return 1;
  }
  return 0;
}

/**
 * FIELD_ACCESS 字段类型 ref：优先 expr resolved_type，回落 module struct layout（*Vec3f_soa.col_x 等）。
 */
/* wave140 pure leave Cap residual: was static; pure index esz links here. PLATFORM: SHARED. */
int32_t glue_field_access_field_type_ref_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                           int32_t fa_ref) {
  struct ast_Expr *ex;
  int32_t tr;
  uint8_t field_name[128];
  int32_t flen;
  int32_t base_ref;
  if (!arena || fa_ref <= 0)
    return 0;
  if (fa_ref <= 0 || fa_ref > arena->num_exprs)
    return 0;
  ex = pipeline_arena_expr_ptr(arena, fa_ref);
  if (!ex)
    return 0;
  flen = ex->field_access_field_len;
  if (flen <= 0 || flen > 127)
    return 0;
  memcpy(field_name, ex->field_access_field_name, (size_t)flen);
  base_ref = ex->field_access_base_ref;
  /** 形参/局部 struct 字段优先 layout（勿信 FA resolved_type 误绑 *f64）。 */
  if (base_ref > 0 && pipeline_expr_kind_ord_at(arena, base_ref) == GLUE_EXPR_KIND_VAR && mod) {
    int32_t base_ty;
    int32_t fi;
    uint8_t vname[128];
    int32_t vlen;
    struct ast_Type *tp;
    uint8_t struct_name[128];
    int32_t nlen;
    int32_t k;
    int32_t j;
    base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
    if (base_ty <= 0) {
      fi = g_pipeline_asm_emit_func_index;
      vlen = pipeline_expr_var_name_len(arena, base_ref);
      if (fi >= 0 && fi < mod->num_funcs && vlen > 0 && vlen <= 63) {
        pipeline_expr_var_name_into(arena, base_ref, vname);
        base_ty = pipeline_module_func_param_type_ref_for_name(mod, fi, vname, vlen);
      }
    }
    if (base_ty <= 0 && g_pipeline_asm_emit_scope_block > 0) {
      vlen = pipeline_expr_var_name_len(arena, base_ref);
      if (vlen > 0 && vlen <= 63) {
        pipeline_expr_var_name_into(arena, base_ref, vname);
        base_ty = pipeline_block_resolve_var_type_ref(arena, g_pipeline_asm_emit_scope_block, vname, vlen);
      }
    }
    if (base_ty > 0) {
      tp = pipeline_arena_type_ptr(arena, base_ty);
      if (tp && tp->kind == ast_TypeKind_TYPE_PTR && tp->elem_type_ref > 0) {
        base_ty = tp->elem_type_ref;
        tp = pipeline_arena_type_ptr(arena, base_ty);
      }
      if (tp && tp->kind == ast_TypeKind_TYPE_NAMED) {
        nlen = tp->name_len;
        if (nlen > 0 && nlen <= 63) {
          memcpy(struct_name, tp->name, (size_t)nlen);
          for (k = 0; k < (int32_t)mod->num_struct_layouts; k++) {
            if (!glue_struct_layout_name_matches_type_name_c(mod, k, struct_name, nlen))
              continue;
            for (j = 0; j < pipeline_module_struct_layout_num_fields(mod, k); j++) {
              int32_t fnlen = pipeline_module_struct_layout_field_name_len(mod, k, j);
              int32_t feq = 1;
              int32_t fi2;
              if (fnlen != flen)
                continue;
              for (fi2 = 0; fi2 < fnlen; fi2++) {
                uint8_t fb[128];
                pipeline_module_struct_layout_field_name_into(mod, k, j, fb);
                if (fb[fi2] != field_name[fi2]) {
                  feq = 0;
                  break;
                }
              }
              if (!feq)
                continue;
              return pipeline_module_struct_layout_field_type_ref(mod, k, j);
            }
          }
        }
      }
    }
  }
  tr = pipeline_expr_resolved_type_ref(arena, fa_ref);
  if (tr > 0)
    return tr;
  /** 勿按字段名全局扫描：多个 struct 均有 ptr 时会误命中 *f64 等（v.ptr[v.len] INDEX esz→8 SIGSEGV）。 */
  return 0;
}

/**
 * wave180 pure-owned: fixed TYPE_ARRAY total payload bytes (recursive multi-dim).
 * Cap residual try_index / esz / array_lit call pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding layout · LINUX gold.
 */
int32_t glue_fixed_array_total_bytes_c(struct ast_ASTArena *arena, int32_t ty_ref, int32_t depth);

/**
 * wave180 pure-owned: INDEX element / pointer-base stride from type ref.
 * Cap residual try_index / emit_index / array_lit call pure; G.7 single authority.
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
 */
int32_t glue_index_elem_byte_sz_from_type_ref_c(struct ast_ASTArena *arena, int32_t tr);

/**
 * wave179 pure-owned: FIELD slot auto-deref *T / TYPE_SLICE into rax or rbx.
 * Cap residual try_index base paths call pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX field base.
 */
int32_t glue_index_deref_ptr_field_slot_rax_elf_c(struct ast_ASTArena *arena,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                          int32_t fa_ref, int32_t ta);
int32_t glue_index_deref_ptr_field_slot_rbx_elf_c(struct ast_ASTArena *arena,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                          int32_t fa_ref, int32_t ta);

/**
 * wave180 pure-owned: VAR type for emit (resolved + param/scope/body decl fallback).
 * Cap residual INDEX/slice faces call pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding · skip_typeck import asm recovery.
 */
int32_t glue_var_expr_type_ref_with_decl_fallback_c(struct ast_ASTArena *arena, int32_t var_ref);

/**
 * wave182 pure-owned: INDEX base materialize → rax / rbx (2 faces).
 * Cap residual nested add3/subadd3/eff_addr call pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX base.
 */
int32_t glue_try_index_var_or_field_base_to_rax_elf_c(struct ast_ASTArena *arena,
                                                              struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                              int32_t base_ref, struct backend_AsmFuncCtx *ctx,
                                                              int32_t ta);
int32_t glue_try_index_var_or_field_base_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                              struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                              int32_t base_ref, struct backend_AsmFuncCtx *ctx,
                                                              int32_t ta);

/**
 * wave181 pure-owned: simple try_index assign-addr→rbx forest (8 faces).
 * Cap residual nested add3/subadd3/eff_addr call pure; base pure since wave182.
 * G.7 single authority — no host body. PLATFORM: SHARED freestanding INDEX assign.
 */
int32_t glue_try_index_var_lit_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         int32_t base_ref, int32_t idx_ref,
                                                         struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t esz);
int32_t glue_try_index_var_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                           struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                           int32_t base_ref, int32_t idx_ref,
                                                           struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t esz);
int32_t glue_try_index_var_plus_lit_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                  struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                  int32_t base_ref, int32_t idx_ref,
                                                                  struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                  int32_t esz);
int32_t glue_try_index_var_plus_var_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                  struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                  int32_t base_ref, int32_t idx_ref,
                                                                  struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                  int32_t esz);
int32_t glue_try_index_var_minus_lit_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                   int32_t base_ref, int32_t idx_ref,
                                                                   struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                   int32_t esz);
int32_t glue_try_index_var_minus_var_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                   int32_t base_ref, int32_t idx_ref,
                                                                   struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                   int32_t esz);
int32_t glue_try_index_var_mul_lit_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                  struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                  int32_t base_ref, int32_t idx_ref,
                                                                  struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                  int32_t esz);
int32_t glue_try_index_var_mul_var_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                 struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                 int32_t base_ref, int32_t idx_ref,
                                                                 struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                 int32_t esz);

/* wave178 pure-owned INDEX expr shape peel forest (runtime_pipeline_abi pure).
 * Cap residual try_index faces call these; G.7 single authority — no static twin.
 * PLATFORM: SHARED freestanding INDEX peel. */
int32_t glue_index_expr_var_plus_var_pair_elf_c(struct ast_ASTArena *arena, int32_t add_ref,
                                               int32_t *out_left_var, int32_t *out_right_var);
int32_t glue_index_expr_var_add3_elf_c(struct ast_ASTArena *arena, int32_t add_ref, int32_t *out_i,
                                      int32_t *out_j, int32_t *out_k);
int32_t glue_index_expr_var_minus_var_pair_elf_c(struct ast_ASTArena *arena, int32_t sub_ref,
                                                int32_t *out_left_var, int32_t *out_right_var);
int32_t glue_index_expr_var_minus_add3_elf_c(struct ast_ASTArena *arena, int32_t sub_ref, int32_t *out_i,
                                            int32_t *out_j, int32_t *out_k);
int32_t glue_index_expr_var_subadd3_elf_c(struct ast_ASTArena *arena, int32_t add_ref, int32_t *out_i,
                                         int32_t *out_j, int32_t *out_k);
int32_t glue_index_expr_var_subsub3_elf_c(struct ast_ASTArena *arena, int32_t sub_ref, int32_t *out_i,
                                         int32_t *out_j, int32_t *out_k);

/**
 * INDEX assign：VAR/FIELD 基址 + ((VAR+VAR)+VAR) ADD 链 → scratch 缩放寻址入 rbx。
 * 0=OK，-1=错，-2=不适用（如 i+j+k / i+(j+k)）。
 */
int32_t glue_try_index_var_plus_var_plus_var_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                            int32_t base_ref, int32_t idx_ref,
                                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                            int32_t esz) {
  int32_t i_ref;
  int32_t j_ref;
  int32_t k_ref;
  int32_t i_off;
  int32_t j_off;
  int32_t k_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (!glue_index_expr_var_add3_elf_c(arena, idx_ref, &i_ref, &j_ref, &k_ref))
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rbx_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
  if (i_off < 0 || j_off < 0 || k_off < 0)
    return -2;
  if (backend_enc_load_rbp_index_scratch_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_index_scratch_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
    return -1;
  if (backend_enc_index_scratch_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_rbx_plus_index_scratch_scaled_arch(elf_ctx, esz, ta);
}

/**
 * INDEX assign：VAR/FIELD 基址 + ((VAR-VAR)+VAR) 混合 ADD/SUB → scratch 缩放寻址入 rbx。
 * 0=OK，-1=错，-2=不适用（如 i-j+k）。
 */
int32_t glue_try_index_var_minus_var_plus_var_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                            int32_t base_ref, int32_t idx_ref,
                                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                            int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t i_ref;
  int32_t j_ref;
  int32_t k_ref;
  int32_t i_off;
  int32_t j_off;
  int32_t k_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 4)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (!glue_index_expr_var_minus_var_pair_elf_c(arena, left_ref, &i_ref, &j_ref))
    return -2;
  if (pipeline_expr_kind_ord_at(arena, right_ref) != GLUE_EXPR_KIND_VAR)
    return -2;
  k_ref = right_ref;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rbx_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
  if (i_off < 0 || j_off < 0 || k_off < 0)
    return -2;
  if (backend_enc_load_rbp_index_scratch_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_index_scratch_sub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
    return -1;
  if (backend_enc_index_scratch_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_rbx_plus_index_scratch_scaled_arch(elf_ctx, esz, ta);
}

/**
 * INDEX assign：VAR/FIELD 基址 + ((VAR-VAR)-VAR) 混合 SUB → scratch 缩放寻址入 rbx。
 * 0=OK，-1=错，-2=不适用（如 (i-j)-k）。
 */
typedef struct {
  int32_t valid;
  size_t ctx_key;
  uint64_t i_key;
  uint64_t j_key;
  int32_t slot_depth;
} GlueIndexMinusPairCache;

static GlueIndexMinusPairCache glue_index_minus_pair_cache;

typedef struct {
  int32_t valid;
  size_t ctx_key;
  uint64_t i_key;
  uint64_t j_key;
  uint64_t k_key;
  int32_t slot_depth;
} GlueIndexSubadd3SumCache;

static GlueIndexSubadd3SumCache glue_index_subadd3_sum_cache;
static int32_t glue_index_scratch_stack_depth;

/** 7.3：Chaitin 溢出或物理 spill 槽用尽时的栈帧 spill（which=5；与 index scratch 共用 push 深度）。 */
#define GLUE_BINOP_STACK_SPILL_CAP 12
/** 7.3：栈帧 spill 着色号（物理槽 0–5 对应 x10–x15）。 */
#define GLUE_ASM73_SPILL_WHICH_STACK 6
static int32_t glue_binop_stack_spill_off[GLUE_BINOP_STACK_SPILL_CAP];
static int32_t glue_binop_stack_spill_at_depth[GLUE_BINOP_STACK_SPILL_CAP];
static int32_t glue_binop_stack_spill_n;
/**
 * wave403: arm64 binop left-in-rax frame spill nest (not SP push / not x9).
 * Cap for nested (a op b) op (c op d) across CALL; cleared at block emit entry.
 */
#define GLUE_BINOP_RAX_FRAME_SPILL_CAP 16
static int32_t glue_binop_rax_frame_spill_off[GLUE_BINOP_RAX_FRAME_SPILL_CAP];
static int32_t glue_binop_rax_frame_spill_n;

/* wave149 Cap residual: pure binop preserve_rax nest (was same-TU static access). PLATFORM: SHARED. */
int32_t glue_binop_rax_frame_spill_push(int32_t home) {
  if (glue_binop_rax_frame_spill_n >= GLUE_BINOP_RAX_FRAME_SPILL_CAP)
    return -1;
  glue_binop_rax_frame_spill_off[glue_binop_rax_frame_spill_n++] = home;
  return 0;
}
int32_t glue_binop_rax_frame_spill_pop(void) {
  if (glue_binop_rax_frame_spill_n <= 0)
    return -1;
  return glue_binop_rax_frame_spill_off[--glue_binop_rax_frame_spill_n];
}
int32_t glue_binop_rax_frame_spill_depth(void) {
  return glue_binop_rax_frame_spill_n;
}

/* wave153 Cap residual: pure block_body leave CAP depth setters.
 * CAP arrays stay residual (G.7); pure only clears depths at body entry.
 * PLATFORM: SHARED freestanding emit.
 */
void glue_binop_rax_frame_spill_n_set(int32_t v) {
  glue_binop_rax_frame_spill_n = v < 0 ? 0 : v;
}

void glue_index_scratch_stack_depth_set(int32_t v) {
  glue_index_scratch_stack_depth = v < 0 ? 0 : v;
}

/**
 * wave169 Cap residual: thin get for pure index-scratch leave.
 * PLATFORM: SHARED freestanding 7.3 / MACOS|ARM64 index scratch stack.
 */
int32_t glue_index_scratch_stack_depth_get(void) {
  return glue_index_scratch_stack_depth;
}

/* wave153 Cap residual: def in spill.c */
void glue_binop_stack_spill_clear(void);
/* wave163 Cap residual: non-static (pure intersect leave + invalidate_slot). */
void glue_binop_stack_spill_drop_off(int32_t off);
/* wave166 Cap residual: non-static face for pure pressure-evict leave (def spill.c). */
int32_t glue_binop_stack_spill_find_depth(int32_t off);
/* wave169 pure-owned: glue_binop_stack_spill_push_elf_c (runtime_pipeline_abi pure). */
int32_t glue_binop_stack_spill_push_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta, int32_t off,
                                                  int32_t from_rbx);
/* wave170 Cap residual thin (def spill.c): pure try_reload leave uses this. */
int32_t glue_binop_stack_spill_try_reload_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                                int32_t off, int32_t to_rbx);
/* wave149 Cap residual non-static (def spill.c). */
int32_t glue_asm73_var_prefers_stack_spill(int32_t off);

/* wave172 pure-owned: minus_pair/subadd3 cache spill helpers (runtime_pipeline_abi pure). */
int32_t glue_index_minus_pair_cache_hit(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                       int32_t i_ref, int32_t j_ref, int32_t ta);
int32_t glue_index_minus_pair_cache_spill_after_sub_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         struct backend_AsmFuncCtx *ctx, int32_t i_ref,
                                                         int32_t j_ref, int32_t ta);
/* wave171 pure-owned: index-scratch enc reload faces (runtime_pipeline_abi pure). */
int32_t glue_index_reload_scratch_slot_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                            int32_t slot_depth);
/* wave169 pure-owned: glue_index_scratch_spills_cleanup_all_elf_c (runtime_pipeline_abi pure). */
int32_t glue_index_scratch_spills_cleanup_all_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/* wave172 pure-owned: subadd3 sum cache hit (runtime_pipeline_abi pure). */
int32_t glue_index_subadd3_sum_cache_hit(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                        int32_t i_ref, int32_t j_ref, int32_t k_ref, int32_t ta);
/* wave171 pure-owned: reload slot → rbx (runtime_pipeline_abi pure). */
int32_t glue_index_reload_scratch_slot_to_rbx_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                                   int32_t slot_depth);

int32_t glue_try_index_var_minus_var_minus_var_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                             struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                             int32_t base_ref, int32_t idx_ref,
                                                                             struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                             int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t i_ref;
  int32_t j_ref;
  int32_t k_ref;
  int32_t i_off;
  int32_t j_off;
  int32_t k_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 5)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (!glue_index_expr_var_minus_var_pair_elf_c(arena, left_ref, &i_ref, &j_ref))
    return -2;
  if (pipeline_expr_kind_ord_at(arena, right_ref) != GLUE_EXPR_KIND_VAR)
    return -2;
  k_ref = right_ref;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rbx_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  /** Reuse stack-spilled (i-j) from a prior INDEX assign (e.g. before (i-j+k)*lit). */
  if (glue_index_minus_pair_cache_hit(arena, ctx, i_ref, j_ref, ta)) {
    k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
    if (k_off < 0)
      return -2;
    if (glue_index_reload_scratch_slot_elf_c(elf_ctx, ta, glue_index_minus_pair_cache.slot_depth) != 0)
      return -1;
    if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
      return -1;
    if (backend_enc_index_scratch_sub_secondary_arch(elf_ctx, ta) != 0)
      return -1;
    return backend_enc_rbx_plus_index_scratch_scaled_arch(elf_ctx, esz, ta);
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
  if (i_off < 0 || j_off < 0 || k_off < 0)
    return -2;
  if (backend_enc_load_rbp_index_scratch_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_index_scratch_sub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (glue_index_minus_pair_cache_spill_after_sub_elf_c(arena, elf_ctx, ctx, i_ref, j_ref, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
    return -1;
  if (backend_enc_index_scratch_sub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_rbx_plus_index_scratch_scaled_arch(elf_ctx, esz, ta);
}

/**
 * INDEX assign：VAR/FIELD 基址 + (VAR-(VAR+VAR)) 右结合 SUB → scratch 缩放寻址入 rbx。
 * 0=OK，-1=错，-2=不适用（如 i-(j+k)）。
 */
int32_t glue_try_index_var_minus_add3_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                    struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                    int32_t base_ref, int32_t idx_ref,
                                                                    struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                    int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t i_ref;
  int32_t j_ref;
  int32_t k_ref;
  int32_t i_off;
  int32_t j_off;
  int32_t k_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 5)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, left_ref) != GLUE_EXPR_KIND_VAR)
    return -2;
  if (!glue_index_expr_var_plus_var_pair_elf_c(arena, right_ref, &j_ref, &k_ref))
    return -2;
  i_ref = left_ref;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rbx_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
  if (i_off < 0 || j_off < 0 || k_off < 0)
    return -2;
  if (backend_enc_load_rbp_index_scratch_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
    return -1;
  if (backend_enc_index_scratch_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_index_scratch_rsub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_rbx_plus_index_scratch_scaled_arch(elf_ctx, esz, ta);
}

/**
 * INDEX assign：VAR/FIELD 基址 + ((VAR-(VAR+VAR))*lit) MUL 嵌套 → scratch 缩放寻址入 rbx。
 * 0=OK，-1=错，-2=不适用（如 (i-(j+k))*2）。
 */
int32_t glue_try_index_var_minus_add3_mul_lit_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                              struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                              int32_t base_ref, int32_t idx_ref,
                                                                              struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                              int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t lit_imm;
  int32_t i_ref;
  int32_t j_ref;
  int32_t k_ref;
  int32_t i_off;
  int32_t j_off;
  int32_t k_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 6)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (glue_index_expr_var_minus_add3_elf_c(arena, left_ref, &i_ref, &j_ref, &k_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm))
      return -2;
  } else if (glue_index_expr_var_minus_add3_elf_c(arena, right_ref, &i_ref, &j_ref, &k_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm))
      return -2;
  } else {
    return -2;
  }
  if (lit_imm <= 1 || lit_imm > 65535)
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rbx_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
  if (i_off < 0 || j_off < 0 || k_off < 0)
    return -2;
  if (backend_enc_load_rbp_index_scratch_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
    return -1;
  if (backend_enc_index_scratch_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_index_scratch_rsub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mul_imm_to_index_scratch_arch(elf_ctx, lit_imm, ta) != 0)
    return -1;
  return backend_enc_rbx_plus_index_scratch_scaled_arch(elf_ctx, esz, ta);
}

/**
 * INDEX assign：VAR/FIELD 基址 + ((VAR-VAR)*lit) MUL 嵌套 → scratch 缩放寻址入 rbx。
 * 0=OK，-1=错，-2=不适用（如 (i-j)*2）。
 */
int32_t glue_try_index_var_minus_var_mul_lit_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                           struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                           int32_t base_ref, int32_t idx_ref,
                                                                           struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                           int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t lit_imm;
  int32_t i_ref;
  int32_t j_ref;
  int32_t i_off;
  int32_t j_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 6)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (glue_index_expr_var_minus_var_pair_elf_c(arena, left_ref, &i_ref, &j_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm))
      return -2;
  } else if (glue_index_expr_var_minus_var_pair_elf_c(arena, right_ref, &i_ref, &j_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm))
      return -2;
  } else {
    return -2;
  }
  if (lit_imm <= 1 || lit_imm > 65535)
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rbx_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  /** Reuse stack-spilled (i-j) from a prior INDEX assign (e.g. after (i-j+k)*lit). */
  if (glue_index_minus_pair_cache_hit(arena, ctx, i_ref, j_ref, ta)) {
    if (glue_index_reload_scratch_slot_elf_c(elf_ctx, ta, glue_index_minus_pair_cache.slot_depth) != 0)
      return -1;
    if (backend_enc_mul_imm_to_index_scratch_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    return backend_enc_rbx_plus_index_scratch_scaled_arch(elf_ctx, esz, ta);
  }
  /** Stale scratch spills — drop before recomputing (i-j). */
  if (glue_index_minus_pair_cache.valid || glue_index_subadd3_sum_cache.valid) {
    if (glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta) != 0)
      return -1;
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  if (i_off < 0 || j_off < 0)
    return -2;
  if (backend_enc_load_rbp_index_scratch_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_index_scratch_sub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (glue_index_minus_pair_cache_spill_after_sub_elf_c(arena, elf_ctx, ctx, i_ref, j_ref, ta) != 0)
    return -1;
  if (backend_enc_mul_imm_to_index_scratch_arch(elf_ctx, lit_imm, ta) != 0)
    return -1;
  return backend_enc_rbx_plus_index_scratch_scaled_arch(elf_ctx, esz, ta);
}

/**
 * INDEX assign：VAR/FIELD 基址 + ((VAR-VAR-VAR)*lit) MUL 嵌套 → scratch 缩放寻址入 rbx。
 * 0=OK，-1=错，-2=不适用（如 (i-j-k)*2）。
 */
int32_t glue_try_index_var_subsub3_mul_lit_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                         int32_t base_ref, int32_t idx_ref,
                                                                         struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                         int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t lit_imm;
  int32_t i_ref;
  int32_t j_ref;
  int32_t k_ref;
  int32_t i_off;
  int32_t j_off;
  int32_t k_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 6)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (glue_index_expr_var_subsub3_elf_c(arena, left_ref, &i_ref, &j_ref, &k_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm))
      return -2;
  } else if (glue_index_expr_var_subsub3_elf_c(arena, right_ref, &i_ref, &j_ref, &k_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm))
      return -2;
  } else {
    return -2;
  }
  if (lit_imm <= 1 || lit_imm > 65535)
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rbx_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
  if (i_off < 0 || j_off < 0 || k_off < 0)
    return -2;
  if (backend_enc_load_rbp_index_scratch_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_index_scratch_sub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
    return -1;
  if (backend_enc_index_scratch_sub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mul_imm_to_index_scratch_arch(elf_ctx, lit_imm, ta) != 0)
    return -1;
  return backend_enc_rbx_plus_index_scratch_scaled_arch(elf_ctx, esz, ta);
}

/**
 * INDEX assign：VAR/FIELD 基址 + ((VAR-VAR+VAR)*lit) MUL 嵌套 → scratch 缩放寻址入 rbx。
 * 0=OK，-1=错，-2=不适用（如 (i-j+k)*2）。
 */
/* wave172 pure-owned: minus_pair/subadd3 cache spill helpers (runtime_pipeline_abi pure). */
int32_t glue_index_subadd3_sum_cache_hit(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                        int32_t i_ref, int32_t j_ref, int32_t k_ref, int32_t ta);
int32_t glue_index_subadd3_sum_cache_spill_store_elf_c(struct ast_ASTArena *arena,
                                                      struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                      struct backend_AsmFuncCtx *ctx, int32_t i_ref,
                                                      int32_t j_ref, int32_t k_ref, int32_t ta);
int32_t glue_index_minus_pair_cache_spill_after_sub_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         struct backend_AsmFuncCtx *ctx, int32_t i_ref,
                                                         int32_t j_ref, int32_t ta);
int32_t glue_index_minus_pair_cache_hit(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                       int32_t i_ref, int32_t j_ref, int32_t ta);
/* wave169 pure-owned (runtime_pipeline_abi pure). */
int32_t glue_index_scratch_spills_cleanup_all_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/* wave172 pure-owned: pop top stale (i-j+k) spill (runtime_pipeline_abi pure). */
int32_t glue_index_subadd3_spill_pop_top_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/* wave171 pure-owned: reload faces (runtime_pipeline_abi pure). */
int32_t glue_index_reload_scratch_slot_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                            int32_t slot_depth);

int32_t glue_try_index_var_subadd3_mul_lit_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                         int32_t base_ref, int32_t idx_ref,
                                                                         struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                         int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t lit_imm;
  int32_t i_ref;
  int32_t j_ref;
  int32_t k_ref;
  int32_t i_off;
  int32_t j_off;
  int32_t k_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 6)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (glue_index_expr_var_subadd3_elf_c(arena, left_ref, &i_ref, &j_ref, &k_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm))
      return -2;
  } else if (glue_index_expr_var_subadd3_elf_c(arena, right_ref, &i_ref, &j_ref, &k_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm))
      return -2;
  } else {
    return -2;
  }
  if (lit_imm <= 1 || lit_imm > 65535)
    return -2;
  if (glue_index_subadd3_sum_cache.valid &&
      !glue_index_subadd3_sum_cache_hit(arena, ctx, i_ref, j_ref, k_ref, ta)) {
    if (glue_index_subadd3_spill_pop_top_elf_c(elf_ctx, ta) != 0)
      return -1;
  }
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rbx_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  /** Reuse stack-spilled (i-j+k) sum from a prior INDEX assign in this block. */
  if (glue_index_subadd3_sum_cache_hit(arena, ctx, i_ref, j_ref, k_ref, ta)) {
    if (glue_index_reload_scratch_slot_elf_c(elf_ctx, ta, glue_index_subadd3_sum_cache.slot_depth) != 0)
      return -1;
    if (backend_enc_mul_imm_to_index_scratch_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    return backend_enc_rbx_plus_index_scratch_scaled_arch(elf_ctx, esz, ta);
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
  if (i_off < 0 || j_off < 0 || k_off < 0)
    return -2;
  if (backend_enc_load_rbp_index_scratch_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_index_scratch_sub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (glue_index_minus_pair_cache_spill_after_sub_elf_c(arena, elf_ctx, ctx, i_ref, j_ref, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
    return -1;
  if (backend_enc_index_scratch_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (glue_index_subadd3_sum_cache_spill_store_elf_c(arena, elf_ctx, ctx, i_ref, j_ref, k_ref, ta) != 0)
    return -1;
  if (backend_enc_mul_imm_to_index_scratch_arch(elf_ctx, lit_imm, ta) != 0)
    return -1;
  return backend_enc_rbx_plus_index_scratch_scaled_arch(elf_ctx, esz, ta);
}

/**
 * INDEX assign：VAR/FIELD 基址 + ((VAR+VAR+VAR)*lit) MUL 嵌套 → scratch 缩放寻址入 rbx。
 * 0=OK，-1=错，-2=不适用（如 (i+j+k)*2）。
 */
int32_t glue_try_index_var_add3_mul_lit_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                        struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                        int32_t base_ref, int32_t idx_ref,
                                                                        struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                        int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t lit_imm;
  int32_t i_ref;
  int32_t j_ref;
  int32_t k_ref;
  int32_t i_off;
  int32_t j_off;
  int32_t k_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 6)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (glue_index_expr_var_add3_elf_c(arena, left_ref, &i_ref, &j_ref, &k_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm))
      return -2;
  } else if (glue_index_expr_var_add3_elf_c(arena, right_ref, &i_ref, &j_ref, &k_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm))
      return -2;
  } else {
    return -2;
  }
  if (lit_imm <= 1 || lit_imm > 65535)
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rbx_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
  if (i_off < 0 || j_off < 0 || k_off < 0)
    return -2;
  if (backend_enc_load_rbp_index_scratch_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_index_scratch_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
    return -1;
  if (backend_enc_index_scratch_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mul_imm_to_index_scratch_arch(elf_ctx, lit_imm, ta) != 0)
    return -1;
  return backend_enc_rbx_plus_index_scratch_scaled_arch(elf_ctx, esz, ta);
}

/**
 * INDEX assign：VAR/FIELD 基址 + ((VAR+VAR)*lit) MUL 嵌套 → scratch 缩放寻址入 rbx。
 * 0=OK，-1=错，-2=不适用（如 (i+j)*2）。
 */
int32_t glue_try_index_var_plus_var_mul_lit_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                          int32_t base_ref, int32_t idx_ref,
                                                                          struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                          int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t lit_imm;
  int32_t i_ref;
  int32_t j_ref;
  int32_t i_off;
  int32_t j_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 6)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (glue_index_expr_var_plus_var_pair_elf_c(arena, left_ref, &i_ref, &j_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm))
      return -2;
  } else if (glue_index_expr_var_plus_var_pair_elf_c(arena, right_ref, &i_ref, &j_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm))
      return -2;
  } else {
    return -2;
  }
  if (lit_imm <= 1 || lit_imm > 65535)
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rbx_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  if (i_off < 0 || j_off < 0)
    return -2;
  if (backend_enc_load_rbp_index_scratch_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_index_scratch_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mul_imm_to_index_scratch_arch(elf_ctx, lit_imm, ta) != 0)
    return -1;
  return backend_enc_rbx_plus_index_scratch_scaled_arch(elf_ctx, esz, ta);
}

/**
 * INDEX 读/址：VAR/FIELD 基址 + (VAR*lit) MUL 下标 → 有效地址入 rax（base + rbx*esz）。
 * 0=OK，-1=错，-2=不适用（assign 用 glue_try_index_var_mul_lit_idx_addr_to_rbx）。
 */
/* wave147 pure Cap residual: static→extern. PLATFORM: SHARED. */
int32_t glue_try_index_var_mul_lit_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                              struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                              int32_t base_ref, int32_t idx_ref,
                                                              struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                              int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t lit_imm;
  int32_t var_ref;
  int32_t var_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 6)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    var_ref = left_ref;
  } else if (pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm)) {
    var_ref = right_ref;
  } else {
    return -2;
  }
  if (lit_imm <= 1 || lit_imm > 65535)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, var_ref) != GLUE_EXPR_KIND_VAR)
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  var_off = glue_var_expr_stack_off_elf_c(arena, ctx, var_ref);
  if (var_off < 0)
    return -2;
  if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, var_off, ta) != 0)
    return -1;
  if (backend_enc_mul_imm_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * INDEX 读/址：VAR/FIELD 基址 + (VAR*VAR) MUL 下标 → 有效地址入 rax。
 */
/* wave147 pure Cap residual: static→extern. PLATFORM: SHARED. */
int32_t glue_try_index_var_mul_var_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                              struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                              int32_t base_ref, int32_t idx_ref,
                                                              struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                              int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t loff;
  int32_t roff;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 6)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, left_ref) != GLUE_EXPR_KIND_VAR)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, right_ref) != GLUE_EXPR_KIND_VAR)
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  loff = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
  roff = glue_var_expr_stack_off_elf_c(arena, ctx, right_ref);
  if (loff < 0 || roff < 0)
    return -2;
  if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, loff, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, roff, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_mul_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * INDEX 读/址：VAR/FIELD 基址 + (VAR+lit) ADD 下标 → 有效地址入 rax。
 */
/* wave147 pure Cap residual: static→extern. PLATFORM: SHARED. */
int32_t glue_try_index_var_plus_lit_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                               struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                               int32_t base_ref, int32_t idx_ref,
                                                               struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                               int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t lit_imm;
  int32_t var_ref;
  int32_t var_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 4)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    var_ref = left_ref;
  } else if (pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm)) {
    var_ref = right_ref;
  } else {
    return -2;
  }
  if (pipeline_expr_kind_ord_at(arena, var_ref) != GLUE_EXPR_KIND_VAR)
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  var_off = glue_var_expr_stack_off_elf_c(arena, ctx, var_ref);
  if (var_off < 0)
    return -2;
  if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, var_off, ta) != 0)
    return -1;
  if (lit_imm != 0 && backend_enc_add_imm_to_rbx_index_arch(elf_ctx, lit_imm, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * INDEX 读/址：VAR/FIELD 基址 + (VAR-lit) SUB 下标 → 有效地址入 rax。
 */
/* wave147 pure Cap residual: static→extern. PLATFORM: SHARED. */
int32_t glue_try_index_var_minus_lit_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                                struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                int32_t base_ref, int32_t idx_ref,
                                                                struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t lit_imm;
  int32_t var_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 5)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (!pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm))
    return -2;
  if (pipeline_expr_kind_ord_at(arena, left_ref) != GLUE_EXPR_KIND_VAR)
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  var_off = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
  if (var_off < 0)
    return -2;
  if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, var_off, ta) != 0)
    return -1;
  if (lit_imm != 0 && backend_enc_sub_imm_from_rbx_index_arch(elf_ctx, lit_imm, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * INDEX 读/址：VAR/FIELD 基址 + (VAR+VAR) ADD 下标 → 有效地址入 rax。
 */
/* wave147 pure Cap residual: static→extern. PLATFORM: SHARED. */
int32_t glue_try_index_var_plus_var_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                               struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                               int32_t base_ref, int32_t idx_ref,
                                                               struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                               int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t loff;
  int32_t roff;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 4)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, left_ref) != GLUE_EXPR_KIND_VAR)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, right_ref) != GLUE_EXPR_KIND_VAR)
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  loff = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
  roff = glue_var_expr_stack_off_elf_c(arena, ctx, right_ref);
  if (loff < 0 || roff < 0)
    return -2;
  if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, loff, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, roff, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * INDEX 读/址：VAR/FIELD 基址 + (VAR-VAR) SUB 下标 → 有效地址入 rax。
 */
/* wave147 pure Cap residual: static→extern. PLATFORM: SHARED. */
int32_t glue_try_index_var_minus_var_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                                struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                int32_t base_ref, int32_t idx_ref,
                                                                struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t loff;
  int32_t roff;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 5)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, left_ref) != GLUE_EXPR_KIND_VAR)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, right_ref) != GLUE_EXPR_KIND_VAR)
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  loff = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
  roff = glue_var_expr_stack_off_elf_c(arena, ctx, right_ref);
  if (loff < 0 || roff < 0)
    return -2;
  if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, loff, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, roff, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_sub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * INDEX 读/址：VAR/FIELD 基址 + ((VAR+VAR)+VAR) ADD 链 → 有效地址入 rax。
 * 支持 i+j+k 与 i+(j+k) 两种结合性。
 */
/* wave147 pure Cap residual: static→extern. PLATFORM: SHARED. */
int32_t glue_try_index_var_plus_var_plus_var_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                                        struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                        int32_t base_ref, int32_t idx_ref,
                                                                        struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                        int32_t esz) {
  int32_t i_ref;
  int32_t j_ref;
  int32_t k_ref;
  int32_t i_off;
  int32_t j_off;
  int32_t k_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (!glue_index_expr_var_add3_elf_c(arena, idx_ref, &i_ref, &j_ref, &k_ref))
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
  if (i_off < 0 || j_off < 0 || k_off < 0)
    return -2;
  if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * INDEX 读/址：VAR/FIELD 基址 + ((VAR-VAR)+VAR) 混合 ADD/SUB → 有效地址入 rax。
 */
/* wave147 pure Cap residual: static→extern. PLATFORM: SHARED. */
int32_t glue_try_index_var_minus_var_plus_var_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                         int32_t base_ref, int32_t idx_ref,
                                                                         struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                         int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t i_ref;
  int32_t j_ref;
  int32_t k_ref;
  int32_t i_off;
  int32_t j_off;
  int32_t k_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 4)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (!glue_index_expr_var_minus_var_pair_elf_c(arena, left_ref, &i_ref, &j_ref))
    return -2;
  if (pipeline_expr_kind_ord_at(arena, right_ref) != GLUE_EXPR_KIND_VAR)
    return -2;
  k_ref = right_ref;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  /** Reuse stack-spilled (i-j+k) from a prior INDEX assign in this block. */
  if (glue_index_subadd3_sum_cache_hit(arena, ctx, i_ref, j_ref, k_ref, ta)) {
    if (glue_index_reload_scratch_slot_to_rbx_elf_c(elf_ctx, ta, glue_index_subadd3_sum_cache.slot_depth) != 0)
      return -1;
    return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
  }
  /** Reuse stack-spilled (i-j) then add k. */
  if (glue_index_minus_pair_cache_hit(arena, ctx, i_ref, j_ref, ta)) {
    k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
    if (k_off < 0)
      return -2;
    if (glue_index_reload_scratch_slot_to_rbx_elf_c(elf_ctx, ta, glue_index_minus_pair_cache.slot_depth) != 0)
      return -1;
    if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
      return -1;
    if (backend_enc_rbx_index_add_secondary_arch(elf_ctx, ta) != 0)
      return -1;
    return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
  if (i_off < 0 || j_off < 0 || k_off < 0)
    return -2;
  if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_sub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * INDEX 读/址：VAR/FIELD 基址 + ((VAR-VAR)-VAR) 混合 SUB → 有效地址入 rax。
 */
/* wave147 pure Cap residual: static→extern. PLATFORM: SHARED. */
int32_t glue_try_index_var_minus_var_minus_var_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                          int32_t base_ref, int32_t idx_ref,
                                                                          struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                          int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t i_ref;
  int32_t j_ref;
  int32_t k_ref;
  int32_t i_off;
  int32_t j_off;
  int32_t k_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 5)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (!glue_index_expr_var_minus_var_pair_elf_c(arena, left_ref, &i_ref, &j_ref))
    return -2;
  if (pipeline_expr_kind_ord_at(arena, right_ref) != GLUE_EXPR_KIND_VAR)
    return -2;
  k_ref = right_ref;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  /** Reuse stack-spilled (i-j) from a prior INDEX assign (e.g. after (i-j+k)*lit). */
  if (glue_index_minus_pair_cache_hit(arena, ctx, i_ref, j_ref, ta)) {
    k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
    if (k_off < 0)
      return -2;
    if (glue_index_reload_scratch_slot_to_rbx_elf_c(elf_ctx, ta, glue_index_minus_pair_cache.slot_depth) != 0)
      return -1;
    if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
      return -1;
    if (backend_enc_rbx_index_sub_secondary_arch(elf_ctx, ta) != 0)
      return -1;
    return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
  if (i_off < 0 || j_off < 0 || k_off < 0)
    return -2;
  if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_sub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_sub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * INDEX 读/址：VAR/FIELD 基址 + (VAR-(VAR+VAR)) 右结合 SUB → 有效地址入 rax。
 */
/* wave147 pure Cap residual: static→extern. PLATFORM: SHARED. */
int32_t glue_try_index_var_minus_add3_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                   int32_t base_ref, int32_t idx_ref,
                                                                   struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                   int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t i_ref;
  int32_t j_ref;
  int32_t k_ref;
  int32_t i_off;
  int32_t j_off;
  int32_t k_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 5)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, left_ref) != GLUE_EXPR_KIND_VAR)
    return -2;
  if (!glue_index_expr_var_plus_var_pair_elf_c(arena, right_ref, &j_ref, &k_ref))
    return -2;
  i_ref = left_ref;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
  if (i_off < 0 || j_off < 0 || k_off < 0)
    return -2;
  if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_rsub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * INDEX 读/址：VAR/FIELD 基址 + ((VAR-(VAR+VAR))*lit) MUL 嵌套 → 有效地址入 rax。
 */
/* wave147 pure Cap residual: static→extern. PLATFORM: SHARED. */
int32_t glue_try_index_var_minus_add3_mul_lit_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                                           struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                           int32_t base_ref, int32_t idx_ref,
                                                                           struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                           int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t lit_imm;
  int32_t i_ref;
  int32_t j_ref;
  int32_t k_ref;
  int32_t i_off;
  int32_t j_off;
  int32_t k_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 6)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (glue_index_expr_var_minus_add3_elf_c(arena, left_ref, &i_ref, &j_ref, &k_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm))
      return -2;
  } else if (glue_index_expr_var_minus_add3_elf_c(arena, right_ref, &i_ref, &j_ref, &k_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm))
      return -2;
  } else {
    return -2;
  }
  if (lit_imm <= 1 || lit_imm > 65535)
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
  if (i_off < 0 || j_off < 0 || k_off < 0)
    return -2;
  if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_rsub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mul_imm_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * INDEX 读/址：VAR/FIELD 基址 + ((VAR-VAR)*lit) MUL 嵌套 → 有效地址入 rax。
 */
/* wave147 pure Cap residual: static→extern. PLATFORM: SHARED. */
int32_t glue_try_index_var_minus_var_mul_lit_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                                        struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                        int32_t base_ref, int32_t idx_ref,
                                                                        struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                        int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t lit_imm;
  int32_t i_ref;
  int32_t j_ref;
  int32_t i_off;
  int32_t j_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 6)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (glue_index_expr_var_minus_var_pair_elf_c(arena, left_ref, &i_ref, &j_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm))
      return -2;
  } else if (glue_index_expr_var_minus_var_pair_elf_c(arena, right_ref, &i_ref, &j_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm))
      return -2;
  } else {
    return -2;
  }
  if (lit_imm <= 1 || lit_imm > 65535)
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  /** Reuse stack-spilled (i-j) from a prior INDEX assign in this block. */
  if (glue_index_minus_pair_cache_hit(arena, ctx, i_ref, j_ref, ta)) {
    if (glue_index_reload_scratch_slot_to_rbx_elf_c(elf_ctx, ta, glue_index_minus_pair_cache.slot_depth) != 0)
      return -1;
    if (backend_enc_mul_imm_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  if (i_off < 0 || j_off < 0)
    return -2;
  if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_sub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mul_imm_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * INDEX 读/址：VAR/FIELD 基址 + ((VAR-VAR+VAR)*lit) MUL 嵌套 → 有效地址入 rax。
 */
/* wave147 pure Cap residual: static→extern. PLATFORM: SHARED. */
int32_t glue_try_index_var_subadd3_mul_lit_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                                      struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                      int32_t base_ref, int32_t idx_ref,
                                                                      struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                      int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t lit_imm;
  int32_t i_ref;
  int32_t j_ref;
  int32_t k_ref;
  int32_t i_off;
  int32_t j_off;
  int32_t k_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 6)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (glue_index_expr_var_subadd3_elf_c(arena, left_ref, &i_ref, &j_ref, &k_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm))
      return -2;
  } else if (glue_index_expr_var_subadd3_elf_c(arena, right_ref, &i_ref, &j_ref, &k_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm))
      return -2;
  } else {
    return -2;
  }
  if (lit_imm <= 1 || lit_imm > 65535)
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  /** Reuse stack-spilled (i-j+k) sum from a prior INDEX assign in this block. */
  if (glue_index_subadd3_sum_cache_hit(arena, ctx, i_ref, j_ref, k_ref, ta)) {
    if (glue_index_reload_scratch_slot_to_rbx_elf_c(elf_ctx, ta, glue_index_subadd3_sum_cache.slot_depth) != 0)
      return -1;
    if (backend_enc_mul_imm_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
  if (i_off < 0 || j_off < 0 || k_off < 0)
    return -2;
  if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_sub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mul_imm_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * INDEX 读/址：VAR/FIELD 基址 + ((VAR-VAR-VAR)*lit) MUL 嵌套 → 有效地址入 rax。
 */
/* wave147 pure Cap residual: static→extern. PLATFORM: SHARED. */
int32_t glue_try_index_var_subsub3_mul_lit_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                                      struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                      int32_t base_ref, int32_t idx_ref,
                                                                      struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                      int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t lit_imm;
  int32_t i_ref;
  int32_t j_ref;
  int32_t k_ref;
  int32_t i_off;
  int32_t j_off;
  int32_t k_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 6)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (glue_index_expr_var_subsub3_elf_c(arena, left_ref, &i_ref, &j_ref, &k_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm))
      return -2;
  } else if (glue_index_expr_var_subsub3_elf_c(arena, right_ref, &i_ref, &j_ref, &k_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm))
      return -2;
  } else {
    return -2;
  }
  if (lit_imm <= 1 || lit_imm > 65535)
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
  if (i_off < 0 || j_off < 0 || k_off < 0)
    return -2;
  if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_sub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_sub_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mul_imm_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * INDEX 读/址：VAR/FIELD 基址 + ((VAR+VAR+VAR)*lit) MUL 嵌套 → 有效地址入 rax。
 */
/* wave147 pure Cap residual: static→extern. PLATFORM: SHARED. */
int32_t glue_try_index_var_add3_mul_lit_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                   int32_t base_ref, int32_t idx_ref,
                                                                   struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                   int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t lit_imm;
  int32_t i_ref;
  int32_t j_ref;
  int32_t k_ref;
  int32_t i_off;
  int32_t j_off;
  int32_t k_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 6)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (glue_index_expr_var_add3_elf_c(arena, left_ref, &i_ref, &j_ref, &k_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm))
      return -2;
  } else if (glue_index_expr_var_add3_elf_c(arena, right_ref, &i_ref, &j_ref, &k_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm))
      return -2;
  } else {
    return -2;
  }
  if (lit_imm <= 1 || lit_imm > 65535)
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  k_off = glue_var_expr_stack_off_elf_c(arena, ctx, k_ref);
  if (i_off < 0 || j_off < 0 || k_off < 0)
    return -2;
  if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, k_off, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mul_imm_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * INDEX 读/址：VAR/FIELD 基址 + ((VAR+VAR)*lit) MUL 嵌套 → 有效地址入 rax。
 */
/* wave147 pure Cap residual: static→extern. PLATFORM: SHARED. */
int32_t glue_try_index_var_plus_var_mul_lit_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                                       struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                       int32_t base_ref, int32_t idx_ref,
                                                                       struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                       int32_t esz) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t lit_imm;
  int32_t i_ref;
  int32_t j_ref;
  int32_t i_off;
  int32_t j_off;
  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, idx_ref) != 6)
    return -2;
  left_ref = pipeline_expr_binop_left_ref_at(arena, idx_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, idx_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -2;
  if (glue_index_expr_var_plus_var_pair_elf_c(arena, left_ref, &i_ref, &j_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm))
      return -2;
  } else if (glue_index_expr_var_plus_var_pair_elf_c(arena, right_ref, &i_ref, &j_ref)) {
    if (!pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm))
      return -2;
  } else {
    return -2;
  }
  if (lit_imm <= 1 || lit_imm > 65535)
    return -2;
  {
    int32_t br;
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
  }
  i_off = glue_var_expr_stack_off_elf_c(arena, ctx, i_ref);
  j_off = glue_var_expr_stack_off_elf_c(arena, ctx, j_ref);
  if (i_off < 0 || j_off < 0)
    return -2;
  if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, i_off, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx, j_off, ta) != 0)
    return -1;
  if (backend_enc_rbx_index_add_secondary_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mul_imm_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * DOD-S1：SoA 数组 `arr[i].field` 有效地址 → rax = base + col_base + index*stride。
 * index_expr_ref 为 INDEX 表达式；fa_ref 为外层 FIELD_ACCESS（含 col_base/stride）。
 */
/* wave151 Cap residual: pure field_access leave (was static). PLATFORM: SHARED. */
int32_t glue_emit_soa_index_field_addr_elf_c(struct ast_ASTArena *arena,
                                                     struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                     int32_t index_expr_ref, int32_t fa_ref,
                                                     struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t base_ref;
  int32_t idx_ref;
  int32_t col_base;
  int32_t stride;
  int32_t lit_i;
  int32_t br;
  if (!arena || !elf_ctx || !ctx || index_expr_ref <= 0 || fa_ref <= 0)
    return -1;
  base_ref = pipeline_expr_index_base_ref(arena, index_expr_ref);
  idx_ref = pipeline_expr_index_index_ref(arena, index_expr_ref);
  col_base = pipeline_expr_field_access_offset(arena, fa_ref);
  stride = pipeline_expr_field_access_soa_stride(arena, fa_ref);
  if (base_ref <= 0 || idx_ref <= 0 || stride <= 0)
    return -1;
  br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
  if (br != 0)
    return br;
  if (col_base != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, col_base, ta) != 0)
    return -1;
  if (pipeline_asm_expr_lit_i32_at_c(arena, idx_ref, &lit_i)) {
    if (lit_i != 0) {
      int64_t dyn = (int64_t)lit_i * (int64_t)stride;
      if (dyn != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, (int32_t)dyn, ta) != 0)
        return -1;
    }
    return 0;
  }
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, idx_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (stride != 1 && backend_enc_mul_imm_to_rbx_arch(elf_ctx, stride, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_add_rax_rbx_arch(elf_ctx, ta);
}

/**
 * Forward decls for lvalue text twin (wave147 pure-owned leave):
 * - pipeline_asm_emit_index_eff_addr_text_c — pure public face
 * - glue_arch_emit_local_slot_ptr_or_addr_text_c — pure helper (was static in leaf)
 * residual calls via extern. PLATFORM: SHARED.
 */
extern int32_t pipeline_asm_emit_index_eff_addr_text_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                int32_t ix_ref, struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                int32_t elem_sz);
extern int32_t glue_arch_emit_local_slot_ptr_or_addr_text_c(struct ast_ASTArena *arena,
                                                            struct codegen_CodegenOutBuf *out, int32_t var_expr_ref,
                                                            int32_t stack_off, struct backend_AsmFuncCtx *ctx,
                                                            int32_t ta);

/**
 * 赋值左值有效地址入 rax/x0（VAR / 链式 FIELD_ACCESS / INDEX）；M8-tail 薄包装 bl 目标。
 */
int32_t pipeline_asm_emit_lvalue_eff_addr_elf_c(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lval_ref,
                                                   struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t ko;
  if (!arena || !elf_ctx || !ctx || lval_ref <= 0)
    return -1;
  ko = pipeline_expr_kind_ord_at(arena, lval_ref);
  if (ko == 3) {
    uint8_t vname[128];
    int32_t vlen;
    int32_t off;
    vlen = pipeline_expr_var_name_len(arena, lval_ref);
    if (vlen <= 0 || vlen > 127)
      return -1;
    pipeline_expr_var_name_into(arena, lval_ref, vname);
    off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
    if (off < 0)
      return -1;
    /** 左值 VAR 默认 lea 栈槽；*T/T[N] 才 load 指针（见 holds_indirect + let 声明类型）。 */
    return glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, lval_ref, off, ctx, ta);
  }
  if (ko == 44) {
    int32_t base_ref;
    int32_t field_off;
    if (pipeline_expr_field_access_is_enum_variant(arena, lval_ref) != 0)
      return -1;
    base_ref = pipeline_expr_field_access_base_ref(arena, lval_ref);
    if (base_ref <= 0)
      return -1;
    /** VAR 基址字段左值：let struct lea / 形参 struct load 指针（与 var_field_access 读路径一致）。 */
    if (pipeline_expr_kind_ord_at(arena, base_ref) == 3) {
      uint8_t vname[128];
      int32_t vlen;
      int32_t var_off;
      vlen = pipeline_expr_var_name_len(arena, base_ref);
      if (vlen <= 0 || vlen > 127)
        return -1;
      pipeline_expr_var_name_into(arena, base_ref, vname);
      var_off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
      if (var_off < 0)
        var_off = asm_ctx_local_find_offset((uint8_t *)ctx, vname, vlen);
      if (var_off < 0)
        return -1;
      if (glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, base_ref, var_off, ctx, ta) != 0)
        return -1;
      field_off = glue_field_access_effective_offset_c(arena, g_pipeline_asm_emit_module, lval_ref);
      if (field_off != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, field_off, ta) != 0)
        return -1;
      return 0;
    }
    /** DOD-S1：arr[i].field 列主序寻址，勿按 AoS INDEX+field_off 叠加。 */
    if (pipeline_expr_kind_ord_at(arena, base_ref) == 47) {
      if (pipeline_expr_field_access_soa_stride(arena, lval_ref) <= 0 && g_pipeline_asm_emit_module != NULL)
        /* 8.3.3 host-cc leave: typeck.x authority (no pipeline_typeck_soa.c thin). */
        {
          extern int32_t typeck_soa_field_soa_index(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t expr_ref, int32_t base_ref);
          (void)typeck_soa_field_soa_index(g_pipeline_asm_emit_module, arena, lval_ref, base_ref);
        }
      if (pipeline_expr_field_access_soa_stride(arena, lval_ref) > 0) {
        return glue_emit_soa_index_field_addr_elf_c(arena, elf_ctx, base_ref, lval_ref, ctx, ta);
      }
    }
    if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, base_ref, ctx, ta) != 0)
      return -1;
    /*
     * wave596 Cap residual pure: pointer intermediate field (`w.p.f`).
     * Root: chain lvalue only lea/add field offsets — never load *T mid-field →
     * rax stays address of the pointer slot → outer load reads pointer low bits
     * (host-C hides via temporary `.`). INDEX path already had
     * glue_index_deref_ptr_field_slot_rax_elf_c; complete same auto-deref here.
     * G.7: single authority for *T field auto-deref on field-access chains.
     * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
     */
    if (pipeline_expr_kind_ord_at(arena, base_ref) == 44) {
      if (glue_index_deref_ptr_field_slot_rax_elf_c(arena, elf_ctx, base_ref, ta) != 0)
        return -1;
    }
    field_off = glue_field_access_effective_offset_c(arena, g_pipeline_asm_emit_module, lval_ref);
    if (field_off != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, field_off, ta) != 0)
      return -1;
    return 0;
  }
  if (ko == 47) {
    int32_t base_ref;
    int32_t idx_ref;
    int32_t esz;
    base_ref = pipeline_expr_index_base_ref(arena, lval_ref);
    idx_ref = pipeline_expr_index_index_ref(arena, lval_ref);
    if (base_ref <= 0 || idx_ref <= 0)
      return -1;
    esz = pipeline_asm_index_elem_byte_sz_c(arena, lval_ref);
    return glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, lval_ref, base_ref, idx_ref, ctx, ta, esz);
  }
  /**
   * wave324 Cap residual pure: EXPR_DEREF as lvalue effective address (ko==52).
   * *p = rhs needs the pointer bits in rax (operand only) — not a load of *p.
   * PLATFORM: SHARED emit / LINUX freestanding gold (mac host-gcc hid via *(p)=).
   */
  if (ko == 52) {
    int32_t op = pipeline_expr_unary_operand_ref_at(arena, lval_ref);
    if (op <= 0)
      return -1;
    return pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta);
  }
  return -1;
}

/**
 * Assign lvalue effective address text path (VAR / chained FIELD_ACCESS / INDEX).
 * Twin of pipeline_asm_emit_lvalue_eff_addr_elf_c for M8-tail / backend text
 * wrappers. INDEX arm delegates to pipeline_asm_emit_index_eff_addr_text_c;
 * local slot uses glue_arch_emit_local_slot_ptr_or_addr_text_c (same-TU later
 * in index_eff_addr leaf). wave596: auto-deref *T intermediate field before
 * next field offset (w.p.f / chain) — same authority as ELF / INDEX ptr-field.
 * DEREF (ko==52) is ELF-only on this face (text residual never had it).
 * G.7 wave1013: folded from glue residual into this leaf beside ELF twin.
 * PLATFORM: SHARED freestanding text path · LINUX gold · MACOS co-path.
 */
int32_t pipeline_asm_emit_lvalue_eff_addr_text_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                 int32_t lval_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t ko;
  if (!arena || !out || !ctx || lval_ref <= 0)
    return -1;
  ko = pipeline_expr_kind_ord_at(arena, lval_ref);
  if (ko == 3) {
    uint8_t vname[128];
    int32_t vlen;
    int32_t off;
    vlen = pipeline_expr_var_name_len(arena, lval_ref);
    if (vlen <= 0 || vlen > 127)
      return -1;
    pipeline_expr_var_name_into(arena, lval_ref, vname);
    off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
    if (off < 0)
      return -1;
    return glue_arch_emit_local_slot_ptr_or_addr_text_c(arena, out, lval_ref, off, ctx, ta);
  }
  if (ko == 44) {
    int32_t base_ref;
    int32_t field_off;
    if (pipeline_expr_field_access_is_enum_variant(arena, lval_ref) != 0)
      return -1;
    base_ref = pipeline_expr_field_access_base_ref(arena, lval_ref);
    if (base_ref <= 0)
      return -1;
    if (pipeline_expr_kind_ord_at(arena, base_ref) == 3) {
      uint8_t vname[128];
      int32_t vlen;
      int32_t var_off;
      vlen = pipeline_expr_var_name_len(arena, base_ref);
      if (vlen <= 0 || vlen > 127)
        return -1;
      pipeline_expr_var_name_into(arena, base_ref, vname);
      var_off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
      if (var_off < 0)
        var_off = asm_ctx_local_find_offset((uint8_t *)ctx, vname, vlen);
      if (var_off < 0)
        return -1;
      if (glue_arch_emit_local_slot_ptr_or_addr_text_c(arena, out, base_ref, var_off, ctx, ta) != 0)
        return -1;
      field_off = glue_field_access_effective_offset_c(arena, g_pipeline_asm_emit_module, lval_ref);
      if (field_off != 0 && backend_arch_emit_add_imm_to_rax(out, field_off, ta) != 0)
        return -1;
      return 0;
    }
    if (pipeline_asm_emit_lvalue_eff_addr_text_c(arena, out, base_ref, ctx, ta) != 0)
      return -1;
    /*
     * wave596: twin of ELF lvalue — auto-deref *T intermediate field before next
     * field offset (w.p.f / chain). G.7 same authority as INDEX ptr-field slot.
     * PLATFORM: SHARED freestanding text path.
     */
    if (pipeline_expr_kind_ord_at(arena, base_ref) == 44) {
      int32_t ftr = glue_field_access_field_type_ref_c(arena, g_pipeline_asm_emit_module, base_ref);
      int32_t fk = (ftr > 0) ? pipeline_type_kind_ord_at(arena, ftr) : 0;
      if ((fk == GLUE_TYPE_KIND_PTR || fk == GLUE_TYPE_KIND_SLICE) &&
          backend_arch_emit_load_64_from_rax(out, ta) != 0)
        return -1;
    }
    field_off = glue_field_access_effective_offset_c(arena, g_pipeline_asm_emit_module, lval_ref);
    if (field_off != 0 && backend_arch_emit_add_imm_to_rax(out, field_off, ta) != 0)
      return -1;
    return 0;
  }
  if (ko == 47) {
    int32_t esz;
    esz = pipeline_asm_index_elem_byte_sz_c(arena, lval_ref);
    return pipeline_asm_emit_index_eff_addr_text_c(arena, out, lval_ref, ctx, ta, esz);
  }
  return -1;
}

/* wave1212 G.7: glue_var_expr_stack_off_elf_c migrated from pipeline_glue.c
 * L1578-1595. Resolves VAR expression stack offset via scoped local table,
 * falls back to name lookup. Colocated with index_helpers.c (30+ callsites;
 * #include at glue.c L1530).
 * Deps: glue_asm_local_var_stack_off_scoped (runtime_pipeline_abi pure wave148;
 *       #include L1513 < L1530 — visible),
 *       pipeline_expr_kind_ord_at (extern),
 *       pipeline_expr_var_name_len/into (extern),
 *       asm_ctx_local_find_offset (extern fwd decl, glue.c L956),
 *       GLUE_EXPR_KIND_VAR (macro, glue.c early).
 * Consumers (all #include after L1530 — visible via existing static fwd decl
 * at glue.c L1109): return.c L356 (#include L1302 — covered by glue.c fwd decl),
 * index_helpers.c L617+ (this file), assign.c L313 (#include L1550),
 * index_eff_addr.c L86+ (#include L1637), call_args.c L178+ (#include L1660),
 * binop.c L106+ (#include L1678). PLATFORM: SHARED. */
/* wave137 Cap residual for cmp pure leave: non-static face. */
int32_t glue_var_expr_stack_off_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                             int32_t var_expr_ref) {
  int32_t off;
  if (!arena || !ctx || var_expr_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, var_expr_ref) != GLUE_EXPR_KIND_VAR)
    return -1;
  off = glue_asm_local_var_stack_off_scoped(arena, ctx, var_expr_ref);
  if (off < 0) {
    uint8_t vname[128];
    int32_t vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
    if (vlen <= 0 || vlen > 127)
      return -1;
    pipeline_expr_var_name_into(arena, var_expr_ref, vname);
    off = asm_ctx_local_find_offset((uint8_t *)ctx, vname, vlen);
  }
  return off;
}
