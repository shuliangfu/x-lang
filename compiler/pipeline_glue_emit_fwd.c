/**
 * pipeline_glue_emit_fwd.c — Early emit inter-include forward-decl / static shell
 * after logand domain (BC 8.3 shell thin).
 *
 * wave1287 BC 8.3 G.7 same-TU domain fold from pipeline_glue.c:
 * pure forward declarations, static prototypes, and shared static state that
 * must be visible after pipeline_asm_emit_logand.c and before
 * pipeline_asm_emit_struct_lit.c (STRUCT_LIT / vector_let / field_access /
 * match / expr_rec chain).
 *
 * Sub-clusters (order preserved):
 *  - pipeline_asm_typekind_variant_tag static fwd (def at cmp.c EOF)
 *  - glue_if_expr_arm_emit_depth static (if/ternary arm depth; read in block_body)
 *  - pipeline_asm_emit_expr_if_arm_elf_c public fwd (def at block_body EOF)
 *  - dual-GP / named layout / type_size_simple / vector_let_init / struct field
 *    store / frame mag / field offset / store_retval / emit_module / struct
 *    let-init static prototypes
 *  - pipeline_asm_emit_set_call_sret_reg_shift_c public face
 *  - GLUE_TYPE_NAMED kind ordinal macro
 *
 * Include site: pipeline_glue.c immediately after pipeline_asm_emit_logand.c
 * and before STRUCT_LIT domain #include.
 * Not a separate .o — host-cc via pipeline_x.o.
 *
 * G.7: declarations + shared static only; no second implementation of any face.
 * PLATFORM: SHARED — host-cc residual shell.
 */

/* wave1033 G.7: pipeline_token_kind_variant_tag folded into
 * pipeline_asm_emit_field_access.c (same TU #include at L2489; no new DEPS).
 * Chinese docblock converted to English per G.9. field_access.c is the sole
 * in-TU leaf consumer (2 callsites); residual glue.c caller
 * pipeline_expr_enum_namespace_field_tag is after the #include site — no
 * forward decl needed. */
/* wave1146 G.7: TypeKind 枚举变体 tag (definition migrated to
 * pipeline_asm_emit_cmp.c EOF). Static fwd decl here provides
 * visibility to field_access.c (#include at L2281) and cmp.c
 * (#include at L3547) — both before the definition at cmp.c EOF. */
static int32_t pipeline_asm_typekind_variant_tag(const uint8_t *field_buf, int32_t flen);
/** if/三元分支块 emit 深度（定义见 glue_block_emit_stmt_i 旁；此处前置供 if_arm 使用）。 */
static int32_t glue_if_expr_arm_emit_depth;

/* wave1217 G.7: pipeline_asm_emit_expr_if_arm_elf_c (34 lines) migrated to
 * pipeline_asm_emit_block_body.c EOF (colocated with if-expr arm depth
 * consumer at block_body.c L900 — sole other reader of
 * glue_if_expr_arm_emit_depth; #include at L2095).
 * if/ternary branch emit: EXPR_BLOCK -> C block body sync emit; non-block
 * -> rec.
 * Deps:
 *  - pipeline_asm_ctx_layout (static fn, glue.c L86 — same TU, visible at
 *    block_body.c EOF since L86 < L2095)
 *  - glue_if_expr_arm_emit_depth (static var, glue.c L1347 — same TU,
 *    visible at block_body.c EOF since L1347 < L2095; both write site in
 *    this function + read site at block_body.c L900 stay in same TU)
 *  - pipeline_expr_kind_ord_at / pipeline_expr_block_ref_at /
 *    backend_ensure_block_local_slots / pipeline_asm_emit_block_body_sync_elf
 *    / pipeline_asm_emit_expr_elf_rec / link_abi_getenv (all extern,
 *    visible at block_body.c EOF via same-TU fwd decls / extern decls)
 * Fwd decl below retained — covers match.c L87/109/156/167 (#include L1567
 * < L2095) + expr_rec.c L124 (#include L1673 < L2095) callsites.
 * No dual authority — seeds only declare extern, no definition.
 * PLATFORM: SHARED — emits both x86_64 + arm64 ELF (ta param selects arch
 * inside delegated callees; no direct arch branch in this function). */
int32_t pipeline_asm_emit_expr_if_arm_elf_c(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t arm_ref,
                                                   struct backend_AsmFuncCtx *ctx, int32_t ta);

/**
 * 表达式级 if/三元 ELF 发射（C 实现）：避免 seed partial 中 backend.x EXPR_IF 经 -E 后漏打 else 标签（.L_else_N offset=-1）。
 * backend.x::emit_expr_elf 在 ek 25/27 时 extern 调用本函数。
 */
/* Forward: dual-GP / named layout used by STRUCT_LIT field store (defs later). */
static int32_t glue_sysv_dual_gp_byte_size_c(struct ast_ASTArena *arena, int32_t ty_ref);
static int32_t glue_type_named_layout_size_any_module_elf_c(struct ast_ASTArena *arena, int32_t ty_ref);
/* wave1032 G.7: glue_type_is_empty_struct_c folded into
 * pipeline_asm_emit_struct_lit.c (same TU #include at L2160; no new DEPS).
 * Chinese docblock converted to English per G.9. struct_lit.c is the sole
 * in-TU leaf consumer; residual glue.c callers (layout metrics / call
 * return size) are after the #include site — no forward decl needed. */
static int32_t glue_type_size_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref, int32_t depth);
/* wave349/350: STRUCT_LIT fixed TYPE_ARRAY field inline store (def after vector_let_init). */
static int32_t pipeline_asm_emit_vector_let_init_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref,
                                                       struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                       int32_t stack_slot_off);
static int32_t glue_struct_lit_store_fixed_array_field_elf_c(
    struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref,
    struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t sret_direct, int32_t base_off, int32_t foff, int32_t fty);
/* wave652: arch-aware struct field frame mag (nest_slot + fixed array field). */
static int32_t glue_struct_field_frame_mag_c(int32_t base_off, int32_t foff, int32_t ta);
/* Used by wave350 FIELD init; full def near pipeline_expr_field_access_layout_offset. */
static int32_t glue_field_access_effective_offset_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                   int32_t fa_ref);
/* wave351 CALL field init: reuse let-init CALL store authority (defs later). */
/* wave1048 G.7: glue_call_return_byte_size_c fwd decl removed — definition
 * migrated to pipeline_asm_emit_call_args.c (fwd decl at call_args.c:356,
 * visible after #include at L2392; struct_let.c:93 retains its own fwd decl
 * for struct_let.c:141 callsite before #include at L2266). */
static int32_t glue_store_retval_pair_to_rbp_elf_c(struct ast_Module *m, struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ty_ref,
                                                   int32_t slot_off, int32_t ta, int32_t init_ref,
                                                   struct backend_AsmFuncCtx *ctx);
static struct ast_Module *glue_emit_module_from_ctx(struct backend_AsmFuncCtx *ctx);
/* wave598: ARRAY_LIT of >8B named struct elems reuses struct let-init (dual-GP / sret / lit). */
static int32_t glue_emit_struct_type_let_init_elf_c(struct ast_ASTArena *arena,
                                                    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref,
                                                    struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                    int32_t let_ty_ref, int32_t stack_slot_off);
void pipeline_asm_emit_set_call_sret_reg_shift_c(int32_t shift);

/* GLUE_TYPE_NAMED (TYPE_NAMED kind ord) — used by struct_lit leaf + call_args leaf + later glue residual. */
#define GLUE_TYPE_NAMED 8

