/**
 * pipeline_asm_emit_struct_let.c — asm ELF struct let-init emit domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding struct-typed let init:
 * - pipeline_asm_emit_struct_let_init_elf_c (STRUCT_LIT → fields into slot)
 * - glue_emit_struct_type_let_init_elf_c (STRUCT_LIT / CALL / METHOD_CALL
 *   dispatch: inline return, SysV sret, dual-GP store_retval)
 * - pipeline_asm_emit_set_call_sret_reg_shift_c /
 *   pipeline_asm_emit_call_sret_reg_shift_c (hidden sret GP shift flag)
 *
 * G.7: single product-mega struct let-init face — do not open a second
 * sret/inline path for let p: Struct = call()/METHOD_CALL.
 * store_retval_pair / call_return_byte_size / type_size_simple remain in
 * glue (defs later; shared by call-arg / block_inits residual).
 * STRUCT_LIT field writer: pipeline_asm_emit_struct_lit.c.
 *
 * Callers: durable ARRAY_LIT fill; block const/let inits; call-arg big-struct
 * MEMORY path; field_access STRUCT_LIT root.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c immediately
 * after pipeline_asm_emit_vector_simd.c (before INDEX/param helpers residual).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 *   · LINUX+MACOS x86_64 SysV — sret reg shift + dual-GP store
 *   · MACOS|ARM64 AAPCS64 — x8 IRRL sret (no GP shift)
 */

/* Forward decls / callees defined elsewhere in the same TU:
 * - try_inline_struct_lit_return_call_to_slot_elf /
 *   try_inline_const_struct_lit_return_call_to_slot_elf (backend_try_inline)
 * - glue_store_retval_pair_to_rbp_elf_c / glue_call_return_byte_size_c
 * - glue_type_size_simple / glue_type_named_layout_size_any_module_elf_c
 * - glue_emit_module_from_ctx / pipeline_asm_emit_expr_elf_rec
 * - pipeline_asm_set_call_expected_ret_ty_c / glue_arm64_mov_x0_to_x8_elf_c
 * - pipeline_asm_emit_struct_lit_fields_elf_c (struct_lit.c)
 * - g_pipeline_asm_call_sret_reg_shift / g_pipeline_asm_emit_module
 */

/**
 * let p: Struct = Struct { ... }：字段直接写入已分配栈槽，勿 store 临时区指针到局部。
 */
static int32_t pipeline_asm_emit_struct_let_init_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref,
                                                       struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                       int32_t stack_slot_off) {
  if (pipeline_expr_kind_ord_at(arena, init_ref) != 45)
    return -1;
  return pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
}

/** let p: Struct = mk(...) 小 struct 按值返回 CALL 内联（backend_try_inline_dispatch.c）。 */
extern int32_t try_inline_struct_lit_return_call_to_slot_elf(struct ast_ASTArena *arena,
                                                             struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                             int32_t call_ref, struct backend_AsmFuncCtx *ctx,
                                                             int32_t ta, int32_t stack_slot_off);
/** vec_*_new() 等零实参 + 常量 struct 返回 CALL 内联（backend_try_inline_dispatch.c）。 */
extern int32_t try_inline_const_struct_lit_return_call_to_slot_elf(struct ast_ASTArena *arena,
                                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                   int32_t call_ref, struct backend_AsmFuncCtx *ctx,
                                                                   int32_t ta, int32_t stack_slot_off);
extern int32_t try_inline_var_field_sum_binop_elf(struct ast_ASTArena *arena,
                                                    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t left_ref,
                                                    int32_t right_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);

/**
 * CALL/expr 结果落 let 栈槽：SysV x86 对 9–16B struct 写 rax+rdx 两段。
 * wave409: ctx required for TYPE_SLICE CALL/METHOD reent deep-copy frame alloc.
 */
static int32_t glue_store_retval_pair_to_rbp_elf_c(struct ast_Module *m, struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ty_ref,
                                                   int32_t slot_off, int32_t ta, int32_t init_ref,
                                                   struct backend_AsmFuncCtx *ctx);
static int32_t glue_deref_struct16_rax_ptr_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
static int32_t glue_call_struct16_ret_needs_rax_deref_c(struct ast_ASTArena *arena, int32_t call_expr_ref);
#define glue_deref_struct16_rax_ptr_elf_c pipeline_asm_deref_struct16_rax_ptr_elf_c
#define glue_call_struct16_ret_needs_rax_deref_c pipeline_asm_call_struct16_ret_needs_rax_deref_c
/* wave1150 G.7: glue_asm_resolve_call_target_module_c definition migrated to
 * pipeline_asm_emit_call_args.c EOF (was in glue.c L9843). This static fwd
 * decl (struct_let.c #include at L2120 < call_args.c #include at L2251)
 * provides TU-wide visibility for all callers. */
static int32_t glue_asm_resolve_call_target_module_c(struct ast_ASTArena *arena, int32_t call_expr_ref,
                                                     struct ast_Module **mod_out, int32_t *func_ix_out,
                                                     int32_t *dep_ix_out);

/** 设置 CALL hidden sret 寄存器右移（backend_call_dispatch 读）。 */
void pipeline_asm_emit_set_call_sret_reg_shift_c(int32_t shift) {
  g_pipeline_asm_call_sret_reg_shift = shift > 0 ? 1 : 0;
}

/** 读取 CALL hidden sret 寄存器右移。 */
int32_t pipeline_asm_emit_call_sret_reg_shift_c(void) {
  return g_pipeline_asm_call_sret_reg_shift;
}

/** CALL 目标返回类型字节宽（定义见 glue_type_size_simple 之后）。 */
static int32_t glue_call_return_byte_size_c(struct ast_ASTArena *arena, int32_t call_expr_ref);
/** Type byte size (def later); needed for let_ty sret fallback before first full def. */
static int32_t glue_type_size_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref, int32_t depth);
/** Named layout size across dep modules (def after glue_type_size_simple). */
static int32_t glue_type_named_layout_size_any_module_elf_c(struct ast_ASTArena *arena, int32_t ty_ref);
/** CALL 返回 TypeKind 序数；定义见 pipeline_asm_call_param_type_ref_at_c 之后。 */
int32_t pipeline_asm_call_return_type_kind_ord_c(struct ast_ASTArena *arena, int32_t call_expr_ref);

/** 从 emit 全局或 ctx 取当前 module（前向声明，定义见 GLUE_ASM_CTX_MODULE_REF_OFF 附近）。 */
static struct ast_Module *glue_emit_module_from_ctx(struct backend_AsmFuncCtx *ctx);

/**
 * let p: Struct 初始化：STRUCT_LIT 或 struct_lit 按值返回 CALL 内联；0=已处理，-1=错误，-2=非 struct let init。
 */
static int32_t glue_emit_struct_type_let_init_elf_c(struct ast_ASTArena *arena,
                                                    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref,
                                                    struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                    int32_t let_ty_ref, int32_t stack_slot_off) {
  int32_t ko;
  int32_t inl;
  if (!arena || !elf_ctx || !ctx || init_ref <= 0)
    return -2;
  ko = pipeline_expr_kind_ord_at(arena, init_ref);
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    fprintf(stderr, "xlang: struct_let_init ko=%d ref=%d slot=%d\n", (int)ko, (int)init_ref, (int)stack_slot_off);
  if (ko == 45)
    return pipeline_asm_emit_struct_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
  /**
   * PLATFORM: LINUX+MACOS x86_64 SysV — large struct let init from CALL (48) or METHOD_CALL (49).
   * Root: import `vec.new()` is METHOD_CALL; historical path only handled CALL → no sret, store rax only
   * → Vec (32B) half-initialized → push/realloc invalid pointer. G.7: same sret authority for both kinds.
   */
  if (ko == 48 || ko == 49) {
    int32_t emit_rc;
    if (ko == 48) {
      inl = try_inline_struct_lit_return_call_to_slot_elf(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
      if (inl == 1)
        return 0;
      inl = try_inline_const_struct_lit_return_call_to_slot_elf(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
      if (inl == 1)
        return 0;
    }
    /**
     * PLATFORM: SHARED — install let decl type as expected return for import overload mangle
     * (vec.new → new_retVec_u8). Cleared on all exit paths of this CALL/METHOD_CALL branch.
     */
    pipeline_asm_set_call_expected_ret_ty_c(let_ty_ref > 0 ? let_ty_ref : 0);
    {
      int32_t call_ret_sz = glue_call_return_byte_size_c(arena, init_ref);
      /**
       * Prefer call return size; fall back / widen from let annotation when call ret is weak.
       * PLATFORM: SHARED (SysV sret gate) — LINUX+MACOS x86_64.
       *
       * Root (length.x Option_u8 exit 4): call_ret_sz for get_u8 is correctly 8 (rax return),
       * but named_layout over-reported Option_u8 as 24 (cross-arena field type_ref sizing /
       * bare-name layout hit). Old code always replaced let_sz with named when let_sz<=16,
       * inflating 8→24 and taking false sret (hidden rdi = dest; callee still uses rdi as
       * first arg) → slot never written; deferred is_some_u8 fails.
       *
       * Rule: once callee return is a valid register class (1..16), never let named_layout
       * push into MEMORY/sret (>16). Named may still widen dual-GP within ≤16, or upgrade
       * when call_ret/size_simple is weak (≤0 or scalar fallback 4) for true large structs
       * (vec.new etc.).
       */
      if (call_ret_sz <= 16 && let_ty_ref > 0) {
        int32_t let_sz = glue_type_size_simple(g_pipeline_asm_emit_module, arena, let_ty_ref, 0);
        int32_t named_sz = 0;
        int32_t best;
        if (let_sz <= 16)
          named_sz = glue_type_named_layout_size_any_module_elf_c(arena, let_ty_ref);
        best = let_sz;
        if (named_sz > best) {
          if (call_ret_sz > 0 && call_ret_sz <= 16 && named_sz > 16) {
            /* keep best — do not false-sret over a known register-class call ret */
          } else if (let_sz <= 4 || call_ret_sz <= 0 || named_sz <= 16) {
            best = named_sz;
          }
        }
        if (best > call_ret_sz)
          call_ret_sz = best;
      }
      /**
       * >16B struct return into let slot (callee writes; no glue_store_retval).
       * PLATFORM: LINUX+MACOS x86_64 SysV — hidden dest in rdi + GP arg shift.
       * PLATFORM: MACOS|ARM64 AAPCS64 (wave591) — dest in x8; no GP shift.
       */
      if (call_ret_sz > 16 && (ta == 0 || ta == 1)) {
        if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0) {
          pipeline_asm_set_call_expected_ret_ty_c(0);
          return -1;
        }
        if (ta == 0) {
          if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0) {
            pipeline_asm_set_call_expected_ret_ty_c(0);
            return -1;
          }
          pipeline_asm_emit_set_call_sret_reg_shift_c(1);
        } else {
          /* AAPCS64: Indirect Result Location Register x8. */
          if (glue_arm64_mov_x0_to_x8_elf_c(elf_ctx) != 0) {
            pipeline_asm_set_call_expected_ret_ty_c(0);
            return -1;
          }
        }
        emit_rc = pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta);
        pipeline_asm_emit_set_call_sret_reg_shift_c(0);
        pipeline_asm_set_call_expected_ret_ty_c(0);
        return emit_rc != 0 ? -1 : 0;
      }
    }
    /** Scalar / ≤16B import CALL/METHOD_CALL: emit then store rax[+rdx]. */
    emit_rc = pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta);
    pipeline_asm_set_call_expected_ret_ty_c(0);
    if (emit_rc != 0)
      return -1;
    if (glue_store_retval_pair_to_rbp_elf_c(glue_emit_module_from_ctx(ctx), arena, elf_ctx, let_ty_ref,
                                            stack_slot_off, ta, init_ref, ctx) != 0)
      return -1;
    return 0;
  }
  return -2;
}

