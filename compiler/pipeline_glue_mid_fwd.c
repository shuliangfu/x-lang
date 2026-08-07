/**
 * pipeline_glue_mid_fwd.c — Mid forward-decl / extern shell after parser_result
 * (BC 8.3 shell thin).
 *
 * wave1285 BC 8.3 G.7 same-TU mid domain fold from pipeline_glue.c:
 * pure function forward declarations and externs that must be visible after
 * pipeline_parser_result.c and before pipeline_codegen_outbuf.c (and later
 * emit domains). Authoritative *definitions* live in domain .c files included
 * later in the same TU (parse_orch / ast_pool_* / typeck / emit leaves) or
 * other product TUs (driver_*, io.o).
 *
 * Sub-clusters (order preserved):
 *  - migration notes (run_x_pipeline / sizeof / debug_module_funcs already folded)
 *  - arena/block num_* + debug_trace_named_func_bodies fwd
 *  - driver_asm_build_skip_typeck retained extern (emit_struct_lit early callsite)
 *  - std.io.driver batch read/write extern stubs
 *  - type/block/expr/module_func/typeck fwd decls for pre-ast_pool callsites
 *  - static glue_arena_expr_kind_at_ref prototype (def in parse_orch)
 *
 * Not included here:
 *  - static emit globals (early glue after early_fwd)
 *  - backend_enc / arm64 / emit-path large extern shell → pipeline_glue_backend_fwd.c
 *  - domain #includes
 *
 * Include site: pipeline_glue.c immediately after pipeline_parser_result.c and
 * before pipeline_codegen_outbuf.c. Not a separate .o — host-cc via pipeline_x.o.
 *
 * G.7: declarations only; no second implementation of any face.
 * PLATFORM: SHARED — host-cc residual shell.
 */


/* wave1283 G.7: pipeline_run_x_pipeline const-buf thin wrapper migrated to
 * pipeline_run_x_pipeline.c EOF (same-TU domain; under !XLANG_PARSER_EXE_PIPELINE_GLUE).
 * runtime.c is the sole external consumer (buf+len face → _impl). */

/* wave1193 G.7: sizeof cluster (5 fns) migrated to pipeline_parse_orch.c EOF.
 * wave1213 G.7: pipeline_sizeof_elf_ctx (6 lines, #ifdef guarded) migrated to
 * pipeline_elf_codegen_forwarders.c EOF (ELF codegen domain; #include at L2971).
 * #ifdef XLANG_PARSER_EXE_PIPELINE_GLUE guard is TU-level — works at any TU pos.
 * No TU-internal callsites — sole consumers are seeds via extern.
 * PLATFORM: SHARED LP64. */

#include <stdio.h>
/* wave1193 G.7: pipeline_debug_module_funcs + driver_get_module_num_funcs
 * + driver_get_module_main_func_index (3 fns) migrated to
 * pipeline_parse_orch.c EOF. Colocated with parse orchestration
 * diagnostic domain. PLATFORM: SHARED. */

/** 这些 arena/block 查询与 body trace helper 在本 TU 后段实现；前置声明用于前面的调试入口。 */
int32_t ast_ast_block_num_consts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_regions(struct ast_ASTArena *a, int32_t br);
void pipeline_debug_trace_named_func_bodies(const char *phase, void *module, void *arena);

/* wave1193 G.7: driver_diagnostic_entry_module + driver forwarding
 * cluster + driver_diagnostic_entry_block_after_parse (15 fns +
 * 5 driver_* extern decls) migrated to pipeline_parse_orch.c EOF.
 * Colocated with parse/load/typeck orchestration domain — all are
 * thin extern forwarders to driver_* in runtime.c. driver_*
 * extern decls (driver_diagnostic_after_entry_parse /
 * driver_pipeline_entry_source_len / driver_typeck_skip_large_entry /
 * driver_asm_build_skip_typeck / driver_diagnostic_pipe_marker /
 * driver_check_only_get / driver_x_pipeline_skip_typeck_get) are
 * redeclared locally inside the migrated function bodies in
 * parse_orch.c. PLATFORM: SHARED. */
/* Retained extern: driver_asm_build_skip_typeck still called by
 * pipeline_asm_emit_struct_lit.c (L1027/L1071, #include at L1663
 * before parse_orch.c #include at L4263). */
extern int32_t driver_asm_build_skip_typeck(void);

/* std.io.driver 单次 _buf 声明与 inline 已由 -E 产出在 pipeline_gen.c 顶部（runtime.c -E 路径 preamble），此处仅保留批量读写桩。 */

struct std_io_driver_Buffer;

/* std.io.driver 批量读写桩：pipeline_gen.c 同 TU 已定义 struct std_io_driver_Buffer；io.o 提供 io_read_batch_buf/io_write_batch_buf，供 xlang_x 链接时解析。 */
extern ptrdiff_t io_read_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms);
extern ptrdiff_t io_write_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms);

int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *arena, int32_t ref);
int32_t pipeline_type_array_size_at(struct ast_ASTArena *arena, int32_t ref);
/* wave251: TYPE_NAMED mono meta stamp (elem + array_size) for pure alloc. */
int32_t pipeline_type_set_elem_array_size_at(struct ast_ASTArena *arena, int32_t ref, int32_t elem_ref,
                                            int32_t array_size);
/* wave1166: type pool accessors migrated to ast_pool_type.c (via ast_pool.c
 * #include at L5058). Fwd decls for callsites before that #include. */
int32_t pipeline_type_elem_ref_at(struct ast_ASTArena *arena, int32_t ref);
int32_t pipeline_type_named_name_into(struct ast_ASTArena *arena, int32_t ref, uint8_t *out64);
int32_t pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li);
void pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
int32_t pipeline_expr_var_name_len(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_expr_var_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out);
int32_t pipeline_module_struct_layout_packed_at(struct ast_Module *m, int32_t layout_idx);
int32_t pipeline_type_ensure_by_kind_ord(struct ast_ASTArena *a, int32_t kind_ord);
int32_t pipeline_typeck_get_dep_return_type_in_caller_arena_c(int32_t from_dep_index, int32_t dep_return_type_ref,
                                                              struct ast_ASTArena *caller_arena,
                                                              struct ast_PipelineDepCtx *ctx);
int32_t pipeline_asm_call_struct16_ret_needs_rax_deref_c(struct ast_ASTArena *arena, int32_t call_expr_ref);
int32_t pipeline_asm_module_func_name_len_at(struct ast_Module *m, int32_t func_index);
void pipeline_asm_module_func_name_copy64(struct ast_Module *m, int32_t func_index, uint8_t *dst);
/* wave1175: asm-prefixed module func forwarders migrated to
 * ast_pool_module_func.c EOF. Fwd decls for callsites before ast_pool.c
 * #include at L5055. */
int32_t pipeline_asm_module_func_is_extern_at(struct ast_Module *m, int32_t func_index);
int32_t pipeline_asm_module_func_body_ref_at(struct ast_Module *m, int32_t func_index);
int32_t pipeline_asm_module_func_num_params_at(struct ast_Module *m, int32_t func_index);
int32_t pipeline_asm_module_func_param_name_len_at(struct ast_Module *m, int32_t func_index, int32_t param_index);
void pipeline_asm_module_func_param_name_copy32(struct ast_Module *m, int32_t func_index, int32_t param_index, uint8_t *dst);

/* wave1194 G.7: std_io_driver batch read/write stubs (2 fns) +
 * pipeline_expr_ref_is_assign_lvalue + compound_assign_token_to_expr_kind_from_glue
 * (2 fns) migrated to pipeline_parse_orch.c EOF (same-TU #include at L4104).
 * Colocated with parse/load/typeck orchestration domain — all are
 * parser-facing helpers (TokenKind→ExprKind mapping, lvalue check) or
 * io driver stubs (batch read/write forwarders to io.o).
 * glue_arena_expr_kind_at_ref (static) retained here — also called by
 * implicit_tail_expr_disallowed_by_glue (L672) + pipeline_expr_kind_ord_at
 * (L2396); visible to parse_orch.c via same-TU definition at L433 above.
 * PLATFORM: SHARED.
 *
 * wave1211 G.7: definition migrated to pipeline_parse_orch.c EOF (colocated
 * with sole external consumer at L939; #include at L2902). Static fwd decl
 * below retained — covers glue.c L1967 callsite (pipeline_expr_kind_ord_at,
 * stays in glue.c). parse_orch.c L897 has its own static fwd decl. */
static enum ast_ExprKind glue_arena_expr_kind_at_ref(struct ast_ASTArena *a, int32_t expr_ref);

