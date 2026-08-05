/**
 * pipeline_glue_early_fwd.c — Early forward-decl / extern shell (BC 8.3 shell thin).
 *
 * wave1284 BC 8.3 G.7 same-TU early domain fold from pipeline_glue.c:
 * pure function forward declarations and externs that must be visible before
 * domain #includes. Authoritative *definitions* still live in ast_pool_*.c
 * (included near end of pipeline_glue.c) or other product TUs (link_abi,
 * driver_*, typeck_* seeds).
 *
 * Why extract: pipeline_glue.c residual is already 0 function bodies; the
 * remaining LOC is orchestration (#include order) + this declaration shell.
 * Colocating the shell in an early domain keeps glue as the include graph
 * only and documents the "must-precede-domains" contract in one place.
 *
 * Sub-clusters (order preserved for readability):
 *  - pipeline_module_func_* / export / visibility / enum_variant_tag
 *  - call_expected_ret_ty / emit_call_arg_active / asm_ctx scope / dep_pipe face
 *  - block labeled / region / arena ptr+alloc
 *  - module struct_layout_* / func param pool / elf_ctx reloc+append
 *  - WPO emit order / asm_diag skip / dep_ctx entry flags / codegen_out_buf len
 *  - (migration comments for already-extracted clusters retained)
 *
 * Not included here (stay in pipeline_glue.c):
 *  - static emit globals (g_pipeline_asm_emit_*, sret homes, scope/dep/elf)
 *  - domain #includes (parser_result, outbuf, emit_*, typeck_*, ast_pool, …)
 *
 * Include site: pipeline_glue.c immediately after AsmFuncCtxLayout typedef +
 * pipeline_asm_ctx_layout extern (wave125 pure leave; was ctx_layout.c include)
 * and before static emit globals. Not a separate .o — host-cc via pipeline_x.o.
 *
 * G.7: declarations only; no second implementation of any face.
 * PLATFORM: SHARED — host-cc residual shell.
 */


/** ast_pool.c 提供；须在下方 glue 之前声明（ast_pool.c 在文件末尾 #include）。 */
struct ast_Func *pipeline_module_func_ptr(struct ast_Module *m, int32_t func_index);
int32_t pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);
int32_t ast_pipeline_block_append_labeled(struct ast_ASTArena *a, int32_t br, int32_t label_len, int32_t is_goto,
                                        int32_t goto_target_len, int32_t return_expr_ref);
int32_t pipeline_module_func_alloc_slot(struct ast_Module *m);
void pipeline_module_func_name_write(struct ast_Module *m, int32_t func_index, uint8_t *name_bytes, int32_t name_len);
void pipeline_module_func_set_num_params(struct ast_Module *m, int32_t fi, int32_t n);
void pipeline_module_func_set_return_type(struct ast_Module *m, int32_t fi, int32_t type_ref);
void pipeline_module_func_set_body_ref(struct ast_Module *m, int32_t fi, int32_t body_ref);
void pipeline_module_func_set_body_expr_ref(struct ast_Module *m, int32_t fi, int32_t body_expr_ref);
void pipeline_module_func_set_is_extern(struct ast_Module *m, int32_t fi, int32_t is_extern);
void pipeline_module_func_set_is_async(struct ast_Module *m, int32_t fi, int32_t is_async);
void pipeline_module_func_set_is_used(struct ast_Module *m, int32_t fi, int32_t is_used);
int32_t pipeline_module_func_is_used_at(struct ast_Module *m, int32_t func_index);
void pipeline_module_func_set_is_naked(struct ast_Module *m, int32_t fi, int32_t is_naked);
int32_t pipeline_module_func_is_naked_at(struct ast_Module *m, int32_t func_index);
void pipeline_module_func_set_is_entry(struct ast_Module *m, int32_t fi, int32_t is_entry);
int32_t pipeline_module_func_is_entry_at(struct ast_Module *m, int32_t func_index);
void pipeline_module_func_set_is_no_mangle(struct ast_Module *m, int32_t fi, int32_t is_no_mangle);
int32_t pipeline_module_func_is_no_mangle_at(struct ast_Module *m, int32_t func_index);
void pipeline_module_func_set_is_interrupt(struct ast_Module *m, int32_t fi, int32_t is_interrupt);
int32_t pipeline_module_func_is_interrupt_at(struct ast_Module *m, int32_t func_index);
void pipeline_module_func_set_is_variadic(struct ast_Module *m, int32_t fi, int32_t is_variadic);
int32_t pipeline_module_func_is_variadic_at(struct ast_Module *m, int32_t func_index);
void pipeline_module_func_set_is_export(struct ast_Module *m, int32_t fi, int32_t is_export);
int32_t pipeline_module_func_is_export_at(struct ast_Module *m, int32_t func_index);
void pipeline_module_struct_layout_set_is_export(struct ast_Module *m, int32_t idx, int32_t v);
int32_t pipeline_module_struct_layout_is_export_at(struct ast_Module *m, int32_t idx);
void pipeline_module_enum_set_is_export(struct ast_Module *m, int32_t idx, int32_t v);
int32_t pipeline_module_enum_is_export_at(struct ast_Module *m, int32_t idx);
void pipeline_module_top_level_let_set_is_export(struct ast_Module *m, int32_t idx, int32_t is_export);
int32_t pipeline_module_top_level_let_is_export_at(struct ast_Module *m, int32_t idx);
/** XLANG_VISIBILITY: 0=compat 1=warn 2=strict；默认 compat（迁移期）。 */
int32_t pipeline_visibility_mode(void);
/** 跨模块访问函数：compat 放行；warn 告警并放行；strict 要求 is_export。返回 1 允许 0 拒绝。 */
int32_t pipeline_visibility_allow_func(struct ast_Module *m, int32_t fi, int32_t cross_module);
void pipeline_module_func_ref_set(struct ast_Module *m, int32_t func_index, int32_t func_ref);
/** ast_pool.c 提供；pipeline_backend_get_return_expr_ref 在 #include ast_pool 之前调用。 */
int32_t pipeline_module_enum_variant_tag_for_names(struct ast_Module *m, uint8_t *enum_name, int32_t enum_len,
                                                   uint8_t *variant_name, int32_t variant_len);
/**
 * PLATFORM: SHARED — expected return type for import CALL/METHOD_CALL overload mangle.
 * Asm user -o with imports skips entry .x typeck (C precheck is a separate arena); zero-arg
 * overloads (vec.new) would otherwise pick first (Vec_i32). Let-init install sets this from
 * the declaration type (let v: Vec_u8 = vec.new()).
 */
/* wave1195 G.7: pipeline_asm_set/call_expected_ret_ty_c + static var
 * g_pipeline_asm_call_expected_ret_ty migrated to
 * pipeline_asm_emit_call_args.c EOF (same-TU #include at L1679).
 * Colocated with call_args domain. Extern fwd decls below ensure
 * visibility for callsites before #include (struct_let.c at L1539).
 * PLATFORM: SHARED. */
void pipeline_asm_set_call_expected_ret_ty_c(int32_t type_ref);
int32_t pipeline_asm_call_expected_ret_ty_c(void);

int32_t pipeline_asm_emit_call_arg_active_c(void);
/** backend_try_inline / SIMD emit：读取当前 dep 池（定义见本文件后部）。 */
struct ast_PipelineDepCtx *pipeline_asm_emit_dep_pipe_c(void);

/** asm_ctx scope 设置（定义见本文件后部；前置声明供 glue_asm_ctx_set_scope_block 调用）。 */
void asm_ctx_set_scope_block(uint8_t *ctx, int32_t block_ref);

/* wave1152 G.7: glue_asm_ctx_set_scope_block migrated to
 * pipeline_asm_emit_block_body.c EOF (block scope setter; colocated
 * with block_body_sync domain — all 13 callsites are in block_body.c /
 * block_if_stmt.c / fold_count_up_while.c / glue.c:5121, all after
 * block_body.c #include at L3623).
 *
 * Static fwd decl at block_body.c:53 (callsites at lines 295/700/865
 * precede EOF definition). Deps g_pipeline_asm_emit_scope_block (L182)
 * + asm_ctx_set_scope_block (L191) both before #include L3623 — visible.
 * PLATFORM: SHARED. */
int32_t pipeline_block_labeled_return_expr_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
/* wave379/wave387: labeled pool accessors (stmt_order kind=7 goto/label/labeled-return). */
int32_t pipeline_block_num_labeled_stmts(struct ast_ASTArena *a, int32_t br);
int32_t pipeline_block_labeled_is_goto(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t pipeline_block_labeled_label_len(struct ast_ASTArena *a, int32_t br, int32_t li);
void pipeline_block_labeled_label_copy32(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
int32_t pipeline_block_labeled_goto_target_len(struct ast_ASTArena *a, int32_t br, int32_t li);
void pipeline_block_labeled_goto_target_copy32(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
/** MEM-C1：块内 region/with_arena 第 ri 条 cap expr ref；0 表示普通 region。 */
int32_t pipeline_block_region_with_arena_cap_ref(struct ast_ASTArena *a, int32_t br, int32_t ri);
struct ast_Type *pipeline_arena_type_ptr(struct ast_ASTArena *a, int32_t ref);
struct ast_Expr *pipeline_arena_expr_ptr(struct ast_ASTArena *a, int32_t ref);
struct ast_Block *pipeline_arena_block_ptr(struct ast_ASTArena *a, int32_t ref);
struct ast_Func *pipeline_arena_func_ptr(struct ast_ASTArena *a, int32_t ref);
int32_t pipeline_arena_type_alloc(struct ast_ASTArena *a);
/* 8.3.3 host-cc leave: pipeline_typeck_field_soa_index_c retired with
 * pipeline_typeck_soa.c. Emit path calls typeck_soa_field_soa_index (typeck_x.o). */
int32_t pipeline_arena_expr_alloc(struct ast_ASTArena *a);
int32_t pipeline_arena_block_alloc(struct ast_ASTArena *a);
int32_t pipeline_arena_func_alloc(struct ast_ASTArena *a);
int32_t pipeline_module_struct_layout_alloc(struct ast_Module *m);
void pipeline_module_struct_layout_reset_slot(struct ast_Module *m, int32_t idx);
void pipeline_module_struct_layout_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
void pipeline_module_struct_layout_set_field(struct ast_Module *m, int32_t li, int32_t j, uint8_t *fname_bytes,
                                              int32_t fname_len, int32_t ftype_ref, int32_t foff);
/* wave1203 G.7: pipeline_module_fill_u8_64_from_src_c fwd decl removed —
 * definition migrated to ast_pool_arena.c EOF (colocated with wave1184
 * parser_library_init cluster — 4 of 5 callsites are there). Both consumer
 * files have their own fwd decls: ast_pool_arena.c L503 (same file) +
 * pipeline_parser_result.c L50 (extern, cross-file). No glue.c callsites. */
int32_t pipeline_module_struct_layout_name_len(struct ast_Module *m, int32_t idx);
uint8_t pipeline_module_struct_layout_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
void pipeline_module_struct_layout_name_into(struct ast_Module *m, int32_t idx, uint8_t *out64);
extern int typeck_float64_bits_lo(double d);
extern int typeck_float64_bits_hi(double d);
/** 模块顶层 const 字面量回落（非 hoist 目标函数内 VAR AF_INET 等）；定义见 ast_pool.c。 */
extern int32_t asm_module_top_level_const_lit_i32(struct ast_Module *m, struct ast_ASTArena *a, uint8_t *name,
                                                   int32_t name_len, int32_t *out_imm);
extern int32_t typeck_x_type_size_from_layout_glue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t li, int32_t depth);
extern int32_t typeck_x_type_align_from_layout_glue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                     int32_t li, int32_t depth);
int32_t pipeline_module_struct_layout_num_fields(struct ast_Module *m, int32_t idx);
int32_t pipeline_module_num_struct_layouts_at(struct ast_Module *m);
int32_t pipeline_module_struct_layout_allow_padding_at(struct ast_Module *m, int32_t idx);
int32_t pipeline_module_struct_layout_repr_compatible_at(struct ast_Module *m, int32_t idx);
void pipeline_module_struct_layout_set_num_fields(struct ast_Module *m, int32_t idx, int32_t nf);
int32_t pipeline_module_struct_layout_field_type_ref(struct ast_Module *m, int32_t li, int32_t j);
int32_t pipeline_module_struct_layout_field_name_len(struct ast_Module *m, int32_t li, int32_t j);
void pipeline_module_struct_layout_field_name_into(struct ast_Module *m, int32_t li, int32_t j, uint8_t *out64);
int32_t pipeline_module_struct_layout_field_offset_at(struct ast_Module *m, int32_t li, int32_t j);
void pipeline_module_struct_layout_set_field_offset(struct ast_Module *m, int32_t li, int32_t j, int32_t foff);
int32_t pipeline_module_struct_layout_field_align_at(struct ast_Module *m, int32_t li, int32_t j);
void pipeline_module_struct_layout_set_field_align(struct ast_Module *m, int32_t li, int32_t j, int32_t al);
/** func 形参池读 API；glue 内 asm 转发在 ast_pool.c 定义之前调用。 */
int32_t pipeline_module_func_num_params_at(struct ast_Module *m, int32_t func_index);
int32_t pipeline_module_func_name_len_at(struct ast_Module *m, int32_t func_index);
void pipeline_module_func_name_copy64(struct ast_Module *m, int32_t func_index, uint8_t *dst);
int32_t pipeline_module_func_name_equal_at(struct ast_Module *m, int32_t func_index, uint8_t *name, int32_t name_len);
int32_t pipeline_module_func_is_extern_at(struct ast_Module *m, int32_t func_index);
int32_t pipeline_module_func_body_ref_at(struct ast_Module *m, int32_t func_index);
int32_t pipeline_module_func_param_name_len_at(struct ast_Module *m, int32_t func_index, int32_t param_index);
void pipeline_module_func_param_name_copy32(struct ast_Module *m, int32_t func_index, int32_t param_index,
                                            uint8_t *dst);
int32_t pipeline_module_func_param_type_ref_for_name(struct ast_Module *m, int32_t func_index, uint8_t *var_name,
                                                     int32_t var_name_len);
int32_t pipeline_module_func_param_type_ref_at(struct ast_Module *m, int32_t func_index, int32_t param_index);
/** macho/elf：reloc_sym_names 行读写（ast_pool.c）。 */
uint8_t *pipeline_elf_ctx_reloc_sym_name_ptr(uint8_t *ctx_bytes, int32_t idx);
void pipeline_elf_ctx_reloc_sym_name_copy64(uint8_t *ctx_bytes, int32_t idx, uint8_t *dst);
int32_t pipeline_elf_ctx_reloc_name_len(uint8_t *ctx_bytes, int32_t idx);
void pipeline_elf_ctx_reloc_sidecar_reset(uint8_t *ctx_bytes);
int32_t pipeline_elf_ctx_reloc_offset_at(uint8_t *ctx_bytes, int32_t idx);
int32_t pipeline_elf_ctx_reloc_shndx_at(uint8_t *ctx_bytes, int32_t idx);
int32_t pipeline_elf_ctx_sym_shndx_at(uint8_t *ctx_bytes, int32_t idx);
int32_t pipeline_elf_pgo_hot_enabled(void);
void pipeline_elf_ctx_set_emit_hot(uint8_t *ctx_bytes, int32_t hot);
int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n);
int32_t pipeline_elf_ctx_emit_code_len(uint8_t *ctx_bytes);
int32_t pipeline_elf_ctx_ensure_label(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len);
int32_t pipeline_elf_ctx_append_patch(uint8_t *ctx_bytes, int32_t rel32_offset, uint8_t *name, int32_t name_len,
                                      int32_t imm_bits);
int32_t pipeline_elf_ctx_append_reloc(uint8_t *ctx_bytes, int32_t offset, uint8_t *name, int32_t name_len);
int32_t pipeline_elf_write_o_pgo_to_buf(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out);
/** PLATFORM: MACOS pure-asm MH_OBJECT; strong platform_macho_write overrides Darwin weak stubs. */
int32_t platform_macho_write_macho_o_to_buf(void *elf_ctx, void *out_buf);
/* wave1100 G.7: pipeline_asm_modlet_name_is_shared + load_to_rax + store_from_rax +
 * prepare_and_emit migrated to pipeline_asm_emit_modlet.c (same-TU #include at L2291,
 * before all callsites: assign.c store + expr_rec.c load + glue.c L8257+ prepare/seed). */
/* ast_pool.c — SHN_COMMON object symbols (modlet + wave341 non-const array-lit durable). */
int32_t pipeline_elf_ctx_add_common_sym(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t size,
                                        int32_t align);
int32_t pipeline_asm_wpo_pgo_is_hot_func(struct ast_Module *m, int32_t fi);
/** ast_pool.c WPO emit 序（#include 之后定义）；ELF mega 主循环前向声明。 */
void pipeline_asm_wpo_pgo_emit_order_prepare(struct ast_Module *m);
int32_t pipeline_asm_wpo_pgo_emit_order_count(struct ast_Module *m);
int32_t pipeline_asm_wpo_pgo_emit_order_at(struct ast_Module *m, int32_t order_index);
int32_t asm_diag_start_func_skip(void);
int32_t asm_skip_heavy_module_func_body(struct ast_Module *m, struct ast_ASTArena *arena, int32_t func_index);
extern void driver_diagnostic_asm_set_current_func(const uint8_t *name, int32_t len);
/** pipeline.x：PipelineDepCtx / CodegenOutBuf 字段 glue（ast_pool.c）。 */
int32_t pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_module_num_funcs(struct ast_Module *m);
int32_t pipeline_module_main_func_index(struct ast_Module *m);
int32_t pipeline_arena_num_types(struct ast_ASTArena *a);
int32_t pipeline_dep_ctx_asm_entry_module_only(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_dep_ctx_check_only_mode(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_dep_ctx_use_asm_backend(struct ast_PipelineDepCtx *ctx);
uint8_t pipeline_dep_ctx_entry_dir_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off);
int32_t codegen_out_buf_len(struct codegen_CodegenOutBuf *out);
void codegen_out_buf_set_len(struct codegen_CodegenOutBuf *out, int32_t n);

/* wave1193 G.7: parser_diagnostic cluster (4 fns) migrated to
 * pipeline_parse_orch.c EOF. Colocated with parse orchestration
 * domain — all are thin extern forwarders to driver_diagnostic_*
 * in runtime.c. PLATFORM: SHARED. */

/* wave1153 dead code delete: parser_diagnostic_parse_commit_shape removed
 * (static wrapper delegating to driver_diagnostic_parse_commit_shape extern;
 * zero callsites in glue.c TU — superseded by runtime_driver_diagnostic.x
 * export function which is linked independently). */

