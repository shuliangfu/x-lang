/**
 * pipeline_glue_backend_fwd.c — Backend / emit-path forward-decl + extern shell
 * (BC 8.3 shell thin).
 *
 * wave1285 BC 8.3 G.7 same-TU mid domain fold from pipeline_glue.c:
 * pure forward declarations and externs that must be visible after
 * pipeline_codegen_outbuf.c and before pipeline_asm_emit_lea_common.c (first
 * emit-domain #include of the heavy chain). Definitions live in seed asm
 * backend objects, domain emit leaves included later in this TU, or other
 * product TUs (backend_enc_dispatch / arm64_enc / thin_delegate / …).
 *
 * Sub-clusters (order preserved):
 *  - call_resolve / implicit_tail / type-pool / array_lit_elem_type_ref notes+fwd
 *  - backend_emit_expr_elf_slow + backend_enc_*_arch family
 *  - asm_*_m8_tail_thin_delegate_c_name face
 *  - arch_arm64_enc_* register-move / load helpers
 *  - FP convert / cmp / arithmetic enc faces
 *  - local-slot / scope / block resolve helpers
 *  - sret / array_lit / force_esz / spill static prototypes for later defs
 *  - PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED macro
 *
 * Not included here:
 *  - static g_pipeline_asm_al_nc_seq (emit global; stays in glue before lea include)
 *  - domain #includes (lea_common and all later emit leaves)
 *
 * Include site: pipeline_glue.c immediately after pipeline_codegen_outbuf.c and
 * before g_pipeline_asm_al_nc_seq + lea_common include.
 * Not a separate .o — host-cc via pipeline_x.o.
 *
 * G.7: declarations only; no second implementation of any face.
 * PLATFORM: SHARED — host-cc residual shell.
 */


/* wave1235 G.7: pipeline_codegen_emit_float_lit_c migrated to
 * pipeline_codegen_outbuf.c EOF (colocated with sole callee
 * glue_codegen_out_append_cstr at L76 — codegen outbuf append domain).
 * Deps: codegen_CodegenOutBuf (global) + snprintf (libc via TU chain).
 * Sole extern caller: codegen_gen.c L10593 + codegen.x seed.
 * PLATFORM: SHARED. */

/* wave1236 G.7: codegen_try_emit_slice_init_from_array_var migrated to
 * pipeline_codegen_outbuf.c EOF (colocated with glue_codegen_out_append_*
 * callees — codegen outbuf append domain). #if guard preserved (extern fn
 * dup of .x seed). All deps visible via earlier fwd decls (L213/396-406,
 * all before outbuf.c #include at L445).
 * Sole extern caller: codegen_gen.c L13530 + codegen.x seed.
 * PLATFORM: SHARED. */

/**
 * ast.x extern：块末若为 RETURN/PANIC/BREAK/CONTINUE，返回 1（禁止隐式尾）；非法 ref 视为 1。
 * 符号名 deliberately 无前缀，供 X「extern function」原样映射，避免与其它 ast_ast_* extern 串联重复前缀。
 */
/* wave1159 G.7: call_resolve cluster (8 extern fns) migrated to
 * pipeline_typeck_method_call.c EOF (colocated with method_call typeck
 * domain). Extern fwd decls below for callsites before #include L9703. */
void pipeline_expr_apply_call_resolve(struct ast_ASTArena *a, int32_t expr_ref, int32_t dep_ix,
                                    int32_t func_ix);
int32_t pipeline_expr_call_resolved_dep_index_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_call_resolved_func_index_at(struct ast_ASTArena *a, int32_t expr_ref);

/* wave1196 G.7: implicit_tail_expr_disallowed_by_glue migrated to
 * ast_pool_arena.c EOF (same-TU #include via ast_pool.c L886).
 * Colocated with arena expr kind accessors. Migrated version inlines
 * glue_arena_expr_kind_at_ref logic via pipeline_arena_expr_ptr
 * (defined in ast_pool_arena.c L41). Callers: ast_pool_block.c L1599
 * (via ast_ast_expr_disallows_implicit_tail wrapper) + check_block.c
 * L677 + cross-TU seeds. PLATFORM: SHARED. */
int implicit_tail_expr_disallowed_by_glue(struct ast_ASTArena *a, int32_t expr_ref);

/* wave1166 G.7: type pool cold accessors cluster (8 fns) migrated to
 * ast_pool_type.c (included from ast_pool.c L895). Colocated with type
 * pool domain — all read/write ast_Type struct fields via pipeline_arena_type_ptr
 * (defined in ast_pool_arena.c, included before ast_pool_type.c at L886).
 *
 * Migrated: pipeline_type_named_name_into / region_label_into /
 * region_label_len_at / set_region_label_at / find_or_alloc_slice /
 * kind_ord_at / elem_ref_at / array_size_at (L2216 below, also removed).
 *
 * Forward decls retained:
 * - pipeline_type_kind_ord_at: L761 (before callsites throughout glue.c)
 * - pipeline_type_array_size_at: L762 + L1989 (before callsites + L2210
 *   pipeline_asm_emit_expr_rec.c #include)
 * Other 5 fns have no glue.c callsites before ast_pool.c #include at L5160
 * (sole callers are typeck_gen.c / codegen_gen.c seeds via extern).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/**
 * asm/backend.x asm_expr_array_elem_store_sz_bytes：从数组字面量 expr 池 ref 取 TYPE_ARRAY 的 elem_type_ref。
 * 无效、非数组或 elem 缺失时返回 0。在 C 内读池，避免 .x 中 `let e: Expr = ast_arena_expr_get` 后字段访问触发 typeck 失败，
 * 亦避免 backend import codegen 时 pipeline_type_* 调用被编成 codegen_ 前缀导致链接未定义。
 */
/* wave1195 G.7: pipeline_asm_array_lit_elem_type_ref migrated to
 * pipeline_asm_emit_array_lit.c EOF (same-TU #include at L1574).
 * Colocated with array_lit emit domain. Extern fwd decl below
 * ensures visibility for callsites before #include (as.c L1345,
 * vector_let.c L1476). PLATFORM: SHARED. */
int32_t pipeline_asm_array_lit_elem_type_ref(struct ast_ASTArena *arena, int32_t array_lit_expr_ref);

/* wave1031 G.7: pipeline_asm_cmp_cc_for_expr_kind_ord +
 * pipeline_asm_arm64_cset_cond_enc_from_cc folded into
 * pipeline_asm_emit_cmp.c (same TU #include at L4407; no new DEPS).
 * Chinese docblocks converted to English per G.9. cmp.c is the sole
 * in-TU consumer of cmp_cc_for_expr_kind_ord; arm64_cset_cond_enc_from_cc
 * is also extern'd by arm64_enc.x / backend_enc_dispatch.x seeds — same
 * pipeline_x.o symbol, no link change. */
/**
 * seed asm 后端（asm_backend_partial.o）提供的 enc/emit 符号；在 C 内实现二元运算，
 * 避免 xlang-c -E 将 if/return 包进 statement expression 导致 emit_expr_elf fallthrough。
 */
struct platform_elf_ElfCodegenCtx;
struct backend_AsmFuncCtx;

extern int32_t backend_emit_expr_elf_slow(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                          int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_epilogue_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_prologue_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t frame_size, int32_t ta);
extern int32_t asm_backend_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                         int32_t out_cap, int32_t *out_len);
extern int32_t asm_pipeline_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                          int32_t out_cap, int32_t *out_len);
extern int32_t asm_parser_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                          int32_t out_cap, int32_t *out_len);
extern int32_t asm_driver_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                        int32_t out_cap, int32_t *out_len);
/** typeck EMIT_HEAVY 第二遍：桩路径 bl→typeck_x.o 同名符号（扩 __text，避免 mega X emit Abort）。 */
extern int32_t asm_typeck_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                        int32_t out_cap, int32_t *out_len);
extern int32_t backend_enc_mov_imm32_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta);
/** EXPR_FLOAT_LIT 64 位立即数入 rax/x0（backend.x backend_enc_mov_imm64_to_rax_arch）。 */
extern int32_t backend_enc_mov_imm64_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lo, int32_t hi,
                                                   int32_t ta);
extern int32_t backend_enc_push_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_store_x0_sp_offset_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_bytes,
                                                   int32_t ta);
extern int32_t backend_enc_push_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** arm64 INDEX binop：mov x2/x1 暂存 rbx（asm_backend_partial.o / build_asm/arm64_enc.o）。 */
extern int32_t arch_arm64_enc_enc_mov_rbx_to_x2(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x2_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rax_to_x2(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x2_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rax_to_x9(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x9_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rax_to_x10(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x10_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rbx_to_x10(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x10_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rax_to_x11(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x11_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rbx_to_x11(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x11_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rax_to_x12(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x12_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rbx_to_x12(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x12_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rax_to_x13(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x13_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rbx_to_x13(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x13_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rax_to_x14(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x14_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rbx_to_x14(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x14_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rax_to_x15(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x15_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rbx_to_x15(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x15_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
/** arm64：从 outgoing 栈槽 slot 装入 xreg（与 enc_push_rax/rbx 的 16B 槽对齐）。 */
extern int32_t arch_arm64_enc_enc_ldr_sp_slot_to_xreg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot,
                                                       int32_t reg);
extern int32_t backend_enc_store_rax_to_rbx_indirect_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t elem_sz,
                                                          int32_t ta);
extern int32_t asm_local_var_slot_holds_indirect_ptr(struct ast_ASTArena *arena, int32_t expr_ref,
                                                     struct ast_Module *mod, uint8_t *asm_ctx);
extern int32_t asm_ctx_scope_block_ref_at(uint8_t *ctx);
extern int32_t pipeline_block_resolve_var_type_ref(struct ast_ASTArena *arena, int32_t block_ref, uint8_t *vname,
                                                   int32_t vlen);
extern int32_t pipeline_block_find_var_decl_block_ref(struct ast_ASTArena *arena, int32_t block_ref, uint8_t *vname,
                                                      int32_t vlen);
extern int32_t backend_enc_add_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_addss_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** f32 bits in eax/rbx → product bits in eax (mulss); freestanding f32 `*` (wave294). */
extern int32_t backend_enc_mulss_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** f32 bits: left ebx − right eax → eax (subss); freestanding f32 `-` (wave298). */
extern int32_t backend_enc_subss_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** f32 bits: left eax − right ebx → eax (subss); freestanding f32 `-` (wave298). */
extern int32_t backend_enc_subss_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** f32 bits: left eax / right ebx → eax (divss); freestanding f32 `/` (wave298). */
extern int32_t backend_enc_divss_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_addsd_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_subsd_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_subsd_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mulsd_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_divsd_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_ucomisd_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/* wave621: f32 ordered compare (ucomiss / fcmp s); sibling of ucomisd. */
extern int32_t backend_enc_ucomiss_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_fp_cmp_setcc_movzbl_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t cc, int32_t ta);
extern int32_t backend_enc_cvttss2si_eax_from_f32_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** f64 bits in rax → truncated i32 in eax (cvttsd2si); freestanding `as i32` (wave291). */
extern int32_t backend_enc_cvttsd2si_eax_from_f64_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** f32 bits in eax → truncated i64 in rax (REX.W cvttss2si); freestanding `as i64/u64` (wave303). */
extern int32_t backend_enc_cvttss2si_rax_from_f32_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** f64 bits in rax → truncated i64 in rax (REX.W cvttsd2si); freestanding `as i64/u64` (wave303). */
extern int32_t backend_enc_cvttsd2si_rax_from_f64_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_cvtsd2ss_eax_from_f64_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_cvtsi2ss_eax_from_i32_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** i64/u64 in rax → f32 bits in eax (REX.W cvtsi2ss); freestanding `as f32` (wave299). */
extern int32_t backend_enc_cvtsi2ss_eax_from_i64_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** u64 in rax → f32 bits in eax (unsigned convert seq); freestanding `as f32` when >2^63-1 (wave304). */
extern int32_t backend_enc_cvtsi2ss_eax_from_u64_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** i32 in eax → f64 bits in rax (cvtsi2sd); freestanding `as f64` (wave292). */
extern int32_t backend_enc_cvtsi2sd_rax_from_i32_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** i64/u64 in rax → f64 bits in rax (REX.W cvtsi2sd); freestanding `as f64` (wave295). */
extern int32_t backend_enc_cvtsi2sd_rax_from_i64_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** u64 in rax → f64 bits in rax (unsigned convert seq); freestanding `as f64` when >2^63-1 (wave304). */
extern int32_t backend_enc_cvtsi2sd_rax_from_u64_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** f32 bits in eax → f64 bits in rax (cvtss2sd); freestanding `as f64` (wave293). */
extern int32_t backend_enc_cvtss2sd_rax_from_f32_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_store_eax_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                  int32_t ta);
extern int32_t backend_enc_sub_rbx_rax_then_mov_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_sub_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_imul_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_and_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** 按位或/异或、移位计数与 shl/shr（backend_enc_dispatch.c）。 */
extern int32_t backend_enc_or_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_xor_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rbx_to_ecx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_shl_cl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_shr_cl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_sar_cl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_shl_cl_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_shr_cl_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_sar_cl_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_idiv_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_div_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_cltd_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_edx_to_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_rem_mod_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_rem_mod_unsigned_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_cmp_setcc_movzbl_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t cc, int32_t ta);
extern int32_t backend_enc_jz_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                   int32_t ta);
/** match 臂相等分支：cmp 后 beq/je（backend_enc_dispatch.c）。 */
extern int32_t backend_enc_jeq_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                    int32_t ta);
/** cmp left(rbx) vs right(rax)；match 字面量臂比较用。 */
extern int32_t backend_enc_cmp_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** cmp left(rax) vs right(rbx)；INDEX 下标 < 0 检查用。 */
extern int32_t backend_enc_cmp_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_jnz_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                    int32_t ta);
extern int32_t backend_enc_jne_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                      int32_t ta);
extern int32_t backend_enc_jmp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                    int32_t ta);
extern int32_t backend_enc_jge_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                    int32_t ta);
extern int32_t backend_enc_jle_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                    int32_t ta);
extern int32_t backend_enc_jl_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                   int32_t ta);
extern int32_t backend_enc_label_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len,
                                      int32_t is_func, int32_t ta);
extern int32_t pipeline_asm_emit_next_label_c(struct backend_AsmFuncCtx *ctx, uint8_t *buf, int32_t buf_size);
extern int32_t pipeline_elf_label_mod_scope_active(void);
extern void backend_ensure_block_local_slots(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena,
                                             int32_t block_ref);
extern int32_t backend_emit_block_body_sync_elf(struct ast_ASTArena *arena,
                                                struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t block_ref,
                                                struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t backend_block_slot_base_for(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena,
                                           int32_t block_ref);
extern int32_t backend_asm_ctx_slot_offset(struct backend_AsmFuncCtx *ctx, int32_t slot_idx);
extern int32_t backend_enc_store_rax_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off,
                                                 int32_t ta);
/** SysV 16B struct：rdx 半落栈 / 从栈槽 load 到 rax+rdx。 */
extern int32_t backend_enc_store_rdx_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off,
                                                 int32_t ta);
extern int32_t backend_enc_load_qword_from_rbx_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_qword_rbx8_to_rdx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rdx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                 int32_t ta);
extern int32_t pipeline_asm_deref_struct16_rax_ptr_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rdx_to_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                   int32_t ta);
/** 将栈槽地址装入 rax/x0（定长数组 let 无 init 时写指针用）。 */
extern int32_t backend_enc_lea_rbp_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                               int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                               int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off,
                                                        int32_t sz, int32_t ta);
extern int32_t backend_enc_mov_rbx_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                int32_t ta);
extern int32_t backend_enc_load_rbp_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                int32_t ta);
/** i32xN lane：x86 movl 取 4B 分量（backend_enc_dispatch.c）。 */
extern int32_t backend_enc_load_rbp_lane_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                     int32_t esz, int32_t ta);
extern int32_t backend_enc_load_rbp_lane_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                     int32_t esz, int32_t ta);
extern int32_t backend_enc_store_x_reg_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t reg,
                                                   int32_t offset, int32_t ta);
extern int32_t backend_enc_load_x29_pos_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_pos,
                                                    int32_t ta);
extern int32_t backend_enc_mov_arg_reg_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                   int32_t ta);
/** SysV f32 xmm 形参：movd xmmK, eax（backend_enc_dispatch.c）。 */
extern int32_t backend_enc_mov_xmm_arg_reg_to_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                       int32_t ta);
extern int32_t backend_enc_mov_xmm_arg_reg_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                       int32_t ta);
extern int32_t backend_enc_mov_eax_to_xmm_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                       int32_t ta);
extern int32_t backend_enc_mov_rax_to_xmm_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                       int32_t ta);
/** XLANG_ABI_F32_XMM=1 时启用（pipeline_abi_f32_xmm.c）。 */
extern int32_t pipeline_asm_abi_f32_xmm_enabled_c(void);
extern int32_t backend_enc_load_rbp_pos_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_pos,
                                                    int32_t ta);
extern int32_t backend_enc_pop_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_rax_plus_rbx_scale1_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_rax_plus_rbx_scale4_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_rax_plus_rbx_scale8_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                    int32_t ta);
extern int32_t backend_enc_call_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len,
                                      int32_t ta);
extern int32_t backend_enc_add_imm_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_add_imm_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_load_rbp_index_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                          int32_t ta);
extern int32_t backend_enc_rbx_plus_index_scratch_scaled_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t esz,
                                                               int32_t ta);
extern int32_t backend_enc_add_imm_to_index_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm,
                                                            int32_t ta);
extern int32_t backend_enc_load_rbp_index_secondary_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                  int32_t offset, int32_t ta);
extern int32_t backend_enc_index_scratch_add_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_sub_imm_from_index_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm,
                                                              int32_t ta);
extern int32_t backend_enc_index_scratch_sub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_index_scratch_rsub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_rbx_index_rsub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mul_imm_to_index_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lit,
                                                          int32_t ta);
extern int32_t backend_enc_mul_imm_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lit, int32_t ta);
extern int32_t backend_enc_add_imm_to_rbx_index_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm,
                                                      int32_t ta);
extern int32_t backend_enc_sub_imm_from_rbx_index_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm,
                                                          int32_t ta);
extern int32_t backend_enc_rbx_index_add_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_rbx_index_sub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_index_scratch_mul_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t arch_arm64_enc_enc_u32_le(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t val);
extern int32_t backend_enc_rbx_index_mul_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_neg_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/* wave290 Cap residual: EXPR_BITNOT ELF emit needs notl/mvn (mirror NEG/LOGNOT). */
extern int32_t backend_enc_not_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_test_eax_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_test_rbx_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_setz_movzbl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_64_from_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_32_from_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_i32_indirect_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_zext8_from_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_arch_emit_load_rbp_to_rax(struct codegen_CodegenOutBuf *out, int32_t off, int32_t ta);
extern int32_t backend_arch_emit_lea_rbp_to_rax(struct codegen_CodegenOutBuf *out, int32_t off, int32_t ta);
extern int32_t backend_arch_emit_add_imm_to_rax(struct codegen_CodegenOutBuf *out, int32_t imm, int32_t ta);
extern int32_t backend_arch_emit_load_64_from_rax(struct codegen_CodegenOutBuf *out, int32_t ta);
extern int32_t backend_arch_emit_push_rax(struct codegen_CodegenOutBuf *out, int32_t ta);
extern int32_t backend_arch_emit_pop_rax(struct codegen_CodegenOutBuf *out, int32_t ta);
extern int32_t backend_arch_emit_mov_rax_to_rbx(struct codegen_CodegenOutBuf *out, int32_t ta);
extern int32_t backend_arch_emit_rax_plus_rbx_scale1(struct codegen_CodegenOutBuf *out, int32_t ta);
extern int32_t backend_arch_emit_rax_plus_rbx_scale4(struct codegen_CodegenOutBuf *out, int32_t ta);
extern int32_t backend_arch_emit_rax_plus_rbx_scale8(struct codegen_CodegenOutBuf *out, int32_t ta);
extern int32_t pipeline_asm_emit_expr_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out, int32_t expr_ref,
                                        struct backend_AsmFuncCtx *ctx, int32_t target_arch);
extern int32_t asm_ctx_local_find_offset(uint8_t *ctx, uint8_t *name, int32_t name_len);
extern int32_t asm_ctx_local_count(uint8_t *ctx);
extern int32_t asm_ctx_block_slot_get(uint8_t *ctx, int32_t block_ref);
extern void asm_ctx_block_slot_set(uint8_t *ctx, int32_t block_ref, int32_t slot_base);
int32_t asm_ctx_local_append(uint8_t *ctx, uint8_t *name, int32_t name_len, int32_t offset);
int32_t asm_ctx_local_count(uint8_t *ctx);
void asm_ctx_set_scope_block(uint8_t *ctx, int32_t block_ref);
int32_t asm_ctx_local_find_offset_scoped(uint8_t *ctx, struct ast_ASTArena *arena, uint8_t *name,
                                          int32_t name_len);
void pipeline_asm_patch_module_parent_links(struct ast_Module *m, struct ast_ASTArena *a);
/** 遍历块树登记全部 const/let 栈槽（ast_pool.c；前置声明，定义在 #include ast_pool.c 之后）。 */
void asm_ctx_fill_locals_block_tree(uint8_t *ctx, struct ast_ASTArena *arena, int32_t block_ref,
                                    int32_t *inout_next_offset, int32_t *inout_num_locals);
void asm_ctx_local_reset(uint8_t *ctx);
int32_t pipeline_asm_compute_frame_size_c(int32_t num_params, struct ast_ASTArena *arena, int32_t block_ref,
                                          struct ast_Module *mod, int32_t func_index);
int32_t pipeline_asm_hoist_target_func_index(struct ast_Module *m);
int32_t pipeline_asm_sum_module_top_level_lets_stack(struct ast_ASTArena *a, struct ast_Module *m, int32_t off);
int32_t pipeline_module_top_level_let_name_len(struct ast_Module *m, int32_t idx);
uint8_t pipeline_module_top_level_let_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
int32_t pipeline_module_top_level_let_type_ref(struct ast_Module *m, int32_t idx);
int32_t pipeline_module_top_level_let_init_ref(struct ast_Module *m, int32_t idx);
int32_t pipeline_module_top_level_let_is_const(struct ast_Module *m, int32_t idx);
int32_t asm_local_slot_bytes(struct ast_ASTArena *arena, int32_t type_ref);
int32_t asm_bump_off_before_struct_local(struct ast_ASTArena *arena, int32_t type_ref, int32_t off);
int32_t asm_bump_off_align_for_local(struct ast_ASTArena *arena, int32_t type_ref, int32_t off);
int32_t asm_local_slot_reg_offset(struct ast_ASTArena *arena, int32_t type_ref, int32_t off, int32_t *inout_off);
int32_t asm_sum_block_local_slot_bytes(struct ast_ASTArena *arena, int32_t block_ref);
int32_t asm_sum_block_array_temp_bytes(struct ast_ASTArena *arena, int32_t block_ref);
/** MEM-C1：with_arena 栈上 Arena64 临时区总字节（compute_frame_size 用）。 */
int32_t asm_sum_block_wa_temp_bytes(struct ast_ASTArena *arena, int32_t block_ref);
int32_t asm_type_is_simd_vector(struct ast_ASTArena *arena, int32_t type_ref);
int32_t asm_type_is_simd_vector_spelling(struct ast_ASTArena *arena, int32_t type_ref);
int32_t pipeline_block_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
int32_t pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li);

/* wave1149 G.7: pipeline_asm_fill_block_locals_tree migrated to
 * pipeline_asm_emit_block_inits.c EOF (block-local slot allocation
 * domain; colocated with const/let init emit). Visible here via
 * #include at L3617 (before callers at L5230 / block_body.c /
 * block_if_stmt.c). Direct g_pipeline_asm_emit_module write replaced
 * with pipeline_asm_emit_set_module() public setter (G.7 single
 * authority). PLATFORM: SHARED. */
extern int32_t backend_try_fold_count_up_while_elf(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t block_ref,
                                                   int32_t loop_idx, struct backend_AsmFuncCtx *ctx, int32_t ta);
/** M8-tail 薄包装打破：循环 emit 真实现在 C glue（勿再调 partial 的 backend_emit_*_elf 薄桩）。 */
int32_t backend_emit_while_loop_elf_sync(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                         int32_t block_ref, int32_t loop_idx, struct backend_AsmFuncCtx *ctx,
                                         int32_t ta);
int32_t backend_emit_for_loop_elf_sync(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                       int32_t block_ref, int32_t for_idx, struct backend_AsmFuncCtx *ctx, int32_t ta);
int32_t backend_emit_loop_body_content_elf_sync(struct ast_ASTArena *arena,
                                                struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t body_ref,
                                                struct backend_AsmFuncCtx *ctx, int32_t ta);

int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_int_val_at(struct ast_ASTArena *a, int32_t expr_ref);
int64_t pipeline_expr_int64_val_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_const_folded_valid_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_const_folded_val_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_binop_left_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_binop_right_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
/* wave1034 G.7: pipeline_expr_float_bits_lo/hi_at folded into
 * pipeline_asm_emit_as.c (same TU #include; no new DEPS). as.c is the
 * sole in-TU leaf consumer (4 callsites); ast_pool.c wrapper is after
 * as.c #include — definition visible, no forward decl needed. */
int32_t pipeline_expr_struct_lit_num_fields(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_struct_lit_init_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t j);
int32_t pipeline_expr_enum_variant_tag_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_field_access_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref);
/* Forward declaration: definition lives in ast_pool.c (#include'd below at L21844).
 * Required so the C5-enum-variant whitelist pre-mark and fold handler can call
 * the marker before ast_pool.c is textually included. */
void pipeline_expr_try_mark_enum_field_access(struct ast_Module *m, struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_field_access_base_ref(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_field_access_name_len(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_expr_field_access_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out);
int32_t pipeline_expr_var_name_len(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_expr_var_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out);
int32_t pipeline_expr_enum_namespace_field_tag(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_field_access_offset(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_field_access_layout_offset(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref);
int32_t pipeline_expr_field_access_load_byte_sz(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref);
int32_t pipeline_expr_field_access_soa_stride(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_struct_lit_field_store_sz(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref,
                                                int32_t field_ix);
int32_t pipeline_expr_struct_lit_value_bytes(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref);
int32_t pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_array_lit_elem_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
int32_t pipeline_expr_index_base_ref(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_index_index_ref(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_asm_array_lit_elem_type_ref(struct ast_ASTArena *arena, int32_t array_lit_expr_ref);
int32_t pipeline_expr_if_cond_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_call_callee_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
int32_t pipeline_expr_unary_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_as_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_as_target_type_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_if_then_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_if_else_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_block_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_match_num_arms_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_match_matched_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_match_arm_result_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
int32_t pipeline_expr_match_arm_is_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
int32_t pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
int32_t pipeline_expr_match_arm_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
int32_t pipeline_expr_match_arm_variant_index(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
int32_t pipeline_asm_emit_block_body_sync_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                              int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);

extern int32_t asm_array_lit_reserve_stack_bytes(struct ast_ASTArena *arena, int32_t init_ref);
extern int32_t asm_struct_lit_reserve_stack_bytes(struct ast_ASTArena *arena, int32_t init_ref);

/* wave1204 G.7: glue_asm_init_expr_reserve_stack_bytes static fwd decl
 * removed — sole caller pipeline_asm_let_init_stack_reserve_bytes
 * migrated to pipeline_asm_emit_block_inits.c EOF (same file as the
 * definition). Both extern fwd decls above retained (asm_array_lit /
 * asm_struct_lit_reserve_stack_bytes are still called by the definition
 * in block_inits.c via same-TU #include at L2404). PLATFORM: SHARED. */

#define PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED (-99)

int32_t pipeline_asm_emit_expr_elf_fast(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                        int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
int32_t pipeline_asm_emit_cmp_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                  int32_t cmp_expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
static int32_t pipeline_asm_emit_expr_elf_rec(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                              int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
/**
 * wave589/593/608 FIELD on CALL/METHOD/STRUCT_LIT rvalue; leave_addr=1 → field slot
 * address in rax (INDEX base), leave_addr=0 → load field (rvalue).
 * Def later; INDEX base helpers (wave609) call before the body is defined.
 */
static int32_t glue_field_access_call_base_rvalue_elf_c(struct ast_ASTArena *arena,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                        struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t leave_addr);
static int32_t glue_emit_index_eff_addr_scaled_elf_c(struct ast_ASTArena *arena,
                                                      struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ix_ref,
                                                      int32_t base_ref, int32_t idx_ref, struct backend_AsmFuncCtx *ctx,
                                                      int32_t ta, int32_t esz);
/* wave127 pure-owned leave: was same-TU static in pipeline_asm_emit_panic.c.
 * Public pure face — residual binop / index_eff_addr call via this extern. */
extern int32_t pipeline_asm_emit_panic_int_div_zero_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
static int32_t glue_binop_preserve_rax_for_rbx_load_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t ta, struct backend_AsmFuncCtx *ctx);
static int32_t glue_binop_restore_rax_after_rbx_load_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                               int32_t ta);
static int32_t pipeline_asm_expr_lit_i32_at_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t *out_imm);
static int32_t glue_index_elem_byte_sz_from_type_ref_c(struct ast_ASTArena *arena, int32_t tr);
static int32_t glue_expr_emit_may_clobber_rbx_elf_c(struct ast_ASTArena *arena, int32_t expr_ref);
/* wave137 Cap residual: non-static (cmp pure leave). */
int32_t glue_var_expr_stack_off_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                              int32_t var_expr_ref);
static int32_t glue_emit_index_add_index_to_base_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t idx_ref, struct backend_AsmFuncCtx *ctx,
                                                            int32_t ta, int32_t esz);
static int32_t glue_emit_index_rax_plus_rbx_scaled_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t esz,
                                                          int32_t ta);
/* wave1037: 16 glue_try_index_var_* fwd declarations removed (G.7 same-leaf fold).
 * Definitions live in pipeline_asm_emit_index_helpers.c (included at line ~2352,
 * before all consuming leaves: assign/array_lit/index/index_eff_addr/call_args/
 * field_access/block_inits). glue.c has no direct call sites — fwd was redundant. */

/* wave1237 G.7: backend_ctx_push_loop_labels / backend_ctx_pop_loop_labels
 * migrated to pipeline_asm_emit_fold_count_up_while.c EOF (colocated with sole
 * caller — loop folding domain consumes the AsmFuncCtx loop-label stack via
 * backend_try_fold_count_up_while_elf at L1413/1484). Fwd decls kept here
 * (before #include at L2405) so the call sites in fold_count_up_while.c see
 * them; definitions at fold_count_up_while.c EOF. Deps visible at #include
 * L2405: pipeline_glue_AsmFuncCtxLayout typedef (L84) + pipeline_asm_ctx_layout
 * static (L86). PLATFORM: SHARED. */
int32_t backend_ctx_push_loop_labels(struct backend_AsmFuncCtx *ctx, uint8_t *exit_buf, int32_t exit_len,
                                     uint8_t *loop_buf, int32_t loop_len);
void backend_ctx_pop_loop_labels(struct backend_AsmFuncCtx *ctx);

/** EXPR_RETURN：可选 emit 操作数后 jmp 函数尾汇合标签 tail_join_label。 */
static int32_t glue_index_scratch_spills_cleanup_all_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** SysV sret 写回（定义见 glue_type_size_simple 之后）。 */
static int32_t glue_emit_sret_memcpy_rbx_to_home_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t sz,
                                                       int32_t ta);
static int32_t glue_emit_sret_return_from_var_elf_c(struct ast_ASTArena *arena,
                                                    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t var_expr_ref,
                                                    struct backend_AsmFuncCtx *ctx, int32_t ta);
/* wave333: return ARRAY_LIT→TYPE_SLICE dual-GP (defs later).
 * wave631: force_esz>0 overrides lit-inferred elem width (TYPE_SLICE formal / large NAMED). */
int32_t pipeline_asm_emit_array_lit_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                          int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
static int32_t pipeline_asm_emit_array_lit_force_esz_elf_c(struct ast_ASTArena *arena,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                          int32_t expr_ref, struct backend_AsmFuncCtx *ctx,
                                                          int32_t ta, int32_t force_esz);
void pipeline_asm_bump_next_offset_for_array_lit(struct ast_ASTArena *arena, int32_t expr_ref,
                                                 struct backend_AsmFuncCtx *ctx);
/* wave126 pure leave: after_let_init live = runtime_pipeline_abi pure (was same-TU def only). */
void pipeline_asm_bump_next_offset_after_let_init(struct ast_ASTArena *arena, int32_t block_ref, int32_t let_idx,
                                                   int32_t init_ref, struct backend_AsmFuncCtx *ctx);
static int32_t pipeline_asm_array_lit_elem_byte_sz_c(struct ast_ASTArena *arena, int32_t expr_ref);
/* wave132 Cap residual: type_size_simple public for pure struct_let leave. */
int32_t glue_type_size_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref, int32_t depth);
/**
 * wave625 Cap residual pure: ARRAY_LIT→TYPE_SLICE force_esz from formal/let elem type.
 * Scalars 1/4/8; TYPE_NAMED → glue_type_size_simple (Pt=8, S24=24).
 * wave632: durable COMMON packs scalar {1,2,4,8} and bulk-fills force_esz>8 NAMED
 * (return [S24{…}] must not fall to stack → dangle). Stack force_esz still used when
 * durable cannot pack (weird widths / capacity).
 * G.7: single authority for let-init / call-arg / return force_esz (was 4× scalar-only).
 * PLATFORM: SHARED freestanding · LINUX gold + MACOS|ARM64.
 */
static int32_t glue_array_lit_force_esz_from_elem_type_c(struct ast_ASTArena *arena, int32_t et);
/* wave692: used by durable TYPE_SLICE fat pack before full defs later in TU. */
static int32_t glue_slice_dual_gp_length_off_c(int32_t data_home, int32_t ta);
/* wave126 pure leave: glue_align_next_offset live = runtime_pipeline_abi pure (no longer static). */
void glue_align_next_offset(struct backend_AsmFuncCtx *ctx);
/* wave132 pure-owned leave: struct let-init live in runtime_pipeline_abi pure
 * (was same-TU static in pipeline_asm_emit_struct_let.c). PLATFORM: SHARED. */
extern int32_t glue_emit_struct_type_let_init_elf_c(struct ast_ASTArena *arena,
                                                    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref,
                                                    struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                    int32_t let_ty_ref, int32_t stack_slot_off);
extern int32_t pipeline_asm_emit_struct_let_init_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref,
                                                       struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                       int32_t stack_slot_off);
static int32_t glue_emit_bulk_mem_copy_spills_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                     int32_t src_spill, int32_t dst_spill, int32_t esz,
                                                     int32_t ta);
/* wave1021: durable doc/body folded into pipeline_asm_emit_array_lit.c.
 * Seq counter for non-const COMMON labels (shared: durable + return escape + reent). */
