/**
 * pipeline_glue.c — 与 -E 产出的 pipeline_gen.c 同属一个翻译单元的 C 胶水代码。
 *
 * 用法：pipeline_gen.c 末尾有 #include "pipeline_glue.c"（由 runtime.c -E 或 build_patch 追加），
 * 编译 pipeline_gen.c 时由 cc 在同一 TU 内包含本文件，故可直接使用上方已定义的 ast_* / codegen_* 等类型。
 * 不单独编译；无补丁、无 sed，所有逻辑在此源文件内从根源提供。
 *
 * parser.x 聚合 -o 可执行时，runtime 在含入前 #define XLANG_PARSER_EXE_PIPELINE_GLUE：省略依赖
 * platform_elf_ElfCodegenCtx 完整定义与 codegen.o 转发符号的片段，避免单文件 TU 编译失败。
 *
 * ── extern 消费者索引（10.4.2 自举；删函数前 grep 本表）────────────────────────────
 * | 符号 | 消费者 |
 * |------|--------|
 * | parser_slice_from_buf / lexer_parser_slice_from_buf / pipeline_source_slice | parser.x, lexer.x, pipeline.x |
 * | parser_lex_from_lexer_result_ptr_into | parser.x（*LexerResult → *Lexer，避 typeck 链式 FIELD_ACCESS） |
 * | pipeline_run_x_pipeline | runtime.c（C 包装 buf+len） |
 * | pipeline_sizeof_* / pipeline_arena_offset_num_types | parser.x, lsp_diag.x；**PipelineDepCtx 增字段时须同步** runtime.c / lsp_diag_pipeline_sizes.c / ast.x |
 * | pipeline_expr_ref_is_assign_lvalue | parser.x |
 * | compound_assign_token_to_expr_kind_from_glue | parser.x |
 * | pipeline_expr_* / ast_pipeline_expr_* / implicit_tail_expr_disallowed_by_glue | ast.x, typeck.x |
 * | pipeline_type_* / pipeline_module_struct_layout_* | typeck.x, codegen.x |
 * | pipeline_module_func_* / pipeline_arena_func_* | parser.x |
 * | pipeline_asm_array_lit_elem_type_ref | asm/backend.x |
 * | pipeline_asm_cmp_cc_for_expr_kind_ord / pipeline_asm_arm64_cset_cond_enc_from_cc | asm/backend.x, arch/arm64_enc.x |
 * | pipeline_module_func_is_extern_at / pipeline_module_func_body_ref_at / pipeline_module_func_name_len_at | asm/backend.x, arch/arm64.x |
 * | pipeline_backend_get_return_expr_ref_at / pipeline_arm64_get_return_lit_ref_at | asm/backend.x, arch/arm64.x |
 * | std_io_driver_submit_*_batch_buf | pipeline_gen.c 同 TU（io.o 批量读写） |
 * | driver_get_module_num_funcs / driver_get_module_main_func_index | runtime.c 烟测 |
 * | driver_diagnostic_entry_* | pipeline.x（日常 no-op） |
 * 原因：X/asm 对大 struct 按值读写字段或 enum 比较易撕裂/ typeck 失败，暂保留 C 指针读池。
 */

#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include "xlang_weak.h"
#include "token.h"
#include "target_cpu.h"
#include "simd_enc.h"
#include "simd_loop.h"
#include "async_asm_pool.h"


/* wave240 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PLATFORM: SHARED — product pipeline_glue residual raw getenv call sites migrate to this face
 * (debug/trace/WPO/SIMD/pad/hot/stack-escape gates; same G.7 pattern as wave238/239 rt_run_*).
 * Header may already declare; explicit for this TU (included into pipeline_gen).
 */
extern char *link_abi_getenv(const char *name);
/* wave248 G.7: shell via public pure thin link_abi_system (wave224 → _impl host system);
 * not raw libc system. Cap residual host system stays only link_abi_system_impl.
 * PLATFORM: SHARED — debug curl residual (try_propagate report) migrates to this face
 * (same G.7 pattern as wave226 pure/modular twins + wave247 mega dual).
 */
extern int link_abi_system(const char *cmd);

struct xlang_slice_uint8_t {
  uint8_t *data;
  size_t length;
};

/* wave1283 G.7: pipeline_glue_AsmFuncCtxLayout typedef early shell (must precede
 * any asm emit domain #include that touches frame/locals).
 * wave125 BC pure-owned leave: cast helper pipeline_asm_ctx_layout live =
 * runtime_pipeline_abi pure (identity); seed cold twin under #ifndef FROM_X.
 * Typedef stays host-cc here — residual emit C needs C field syntax on ly->…;
 * pure cannot host C typedefs for residual TUs. PLATFORM: SHARED. */
struct backend_AsmFuncCtx;
/**
 * Layout overlay of backend AsmFuncCtx for C residual emit paths.
 * Field order must stay ABI-compatible with the X/asm AsmFuncCtx definition.
 * G.7: single authority typedef; do not redeclare in emit domains.
 */
typedef struct {
  int32_t frame_size;
  int32_t next_offset;
  int32_t num_locals;
  int32_t label_counter;
  struct ast_Module *module_ref;
  uint8_t loop_break_label_stack[512];
  int32_t loop_break_len_stack[8];
  uint8_t loop_continue_label_stack[512];
  int32_t loop_continue_len_stack[8];
  uint8_t break_label[128];
  int32_t break_len;
  uint8_t continue_label[128];
  int32_t continue_len;
  int32_t loop_label_depth;
  void *dep_pipe;
  uint8_t tail_join_label[128];
  int32_t tail_join_label_len;
} pipeline_glue_AsmFuncCtxLayout;
/** wave125 pure leave: identity cast AsmFuncCtx* → layout view (same address). */
extern pipeline_glue_AsmFuncCtxLayout *pipeline_asm_ctx_layout(struct backend_AsmFuncCtx *ctx);

/* wave1284 G.7: early forward-decl / extern shell migrated to
 * pipeline_glue_early_fwd.c (same-TU #include). Pure decls only;
 * static emit globals remain below. PLATFORM: SHARED. */
#include "pipeline_glue_early_fwd.c"

/* wave1290 G.7: emit/typeck active-context static globals (13: module / arena
 * / elf_ctx / func_index / scope_block / dep_pipe / active_module / call state
 * / sret home+active+ret_sz+reg_shift) migrated to pipeline_glue_statics.c
 * (same-TU single-definition site; all domain #includes below share it).
 * wave1284 had left these in glue; early_fwd holds only declarations.
 * PLATFORM: SHARED. */
#include "pipeline_glue_statics.c"

/* wave1185 G.7: parser result copy/lex/slice helper cluster (20 fns + 4 typedefs)
 * migrated to pipeline_parser_result.c (same-TU #include). Members: parser_slice_from_buf /
 * lexer_parser_slice_from_buf / pipeline_source_slice / parser_lexer_pos_before /
 * parser_lex_from_lexer_result_{ptr,val}_into / parser_lex_copy_from_collect_imports /
 * parser_lex_from_onefunc_result_ptr_into / parser_lex_from_extern_parse_result_ptr_into /
 * pipeline_parser_extern_parse_set_fail_c / pipeline_parser_library_result_copy_into_c /
 * pipeline_parser_try_skip_result_copy_into_c / parser_lex_from_try_skip_result_val_into /
 * parser_lex_from_library_result_val_into / pipeline_parser_set_onefunc_fail_c /
 * pipeline_parser_onefunc_buf_into_set_success_c + 4 glue-local typedefs
 * (ExternParseResult / LibraryParseResult / TrySkipAllowResult / OneFuncResult).
 * Depends on pipeline_module_fill_u8_64_from_src_c (extern fwd decl at parser_result.c L50;
 * definition migrated to ast_pool_arena.c EOF by wave1203). All extern. */
#include "pipeline_parser_result.c"
/* wave1285 G.7: mid forward-decl / extern shell migrated to
 * pipeline_glue_mid_fwd.c (same-TU #include). Pure decls only;
 * sits after parser_result and before codegen_outbuf.
 * PLATFORM: SHARED. */
#include "pipeline_glue_mid_fwd.c"

/* wave1101 G.7: codegen outbuf append domain (4 functions + macro) migrated to
 * pipeline_codegen_outbuf.c (same-TU #include). Members:
 * glue_codegen_out_append_bytes / _cstr / _int / _byte.
 * PLATFORM: SHARED. */
#include "pipeline_codegen_outbuf.c"
/* wave1285 G.7: backend/emit-path forward-decl + extern shell migrated to
 * pipeline_glue_backend_fwd.c (same-TU #include). Pure decls only;
 * sits after codegen_outbuf and before al_nc_seq + lea_common.
 * PLATFORM: SHARED. */
#include "pipeline_glue_backend_fwd.c"

static int32_t g_pipeline_asm_al_nc_seq;
/* wave143: pure durable Cap residual takes unique Lxlang_al_* seq (shared with
 * return/call_args residual same-TU direct access). PLATFORM: SHARED. */
int32_t glue_pipeline_asm_al_nc_seq_take_c(void) {
  int32_t seq = g_pipeline_asm_al_nc_seq;
  if (seq < 0 || seq > 999999)
    seq = 0;
  g_pipeline_asm_al_nc_seq = seq + 1;
  return seq;
}

/* wave123 pure-owned leave: pipeline_asm_emit_lea_common.c deleted.
 * live = runtime_pipeline_abi pure (glue_asm_lea_*_common_* +
 * glue_arm64_mov_x{0,8}_to_x{8,0}_elf_c); seed cold twin under #ifndef FROM_X.
 * Residual mega leaves (array_lit / return / call_args / field_access /
 * struct_let) call these public faces — extern prototypes only; do not re-open
 * a second COMMON lea / arm64 sret mov path (G.7).
 * PLATFORM: SHARED freestanding emit · LINUX+MACOS x86_64 SysV · MACOS|ARM64. */
extern int32_t glue_asm_lea_rax_common_rip_x86(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name,
                                               int32_t name_len);
extern int32_t glue_asm_lea_rbx_common_rip_x86(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name,
                                               int32_t name_len);
extern int32_t glue_arm64_mov_x0_to_x8_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t glue_arm64_mov_x8_to_x0_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t glue_asm_lea_rbx_common_adrp_arm64(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name,
                                                   int32_t name_len);
extern int32_t glue_asm_lea_rax_common_adrp_arm64(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name,
                                                   int32_t name_len);
/* wave1288 G.7: early emit inter-include forward-decl / define shell
 * (ARRAY_LIT caps + array_lit / async_cps_phase_reset / return_type_at
 * prototypes + binop scalar classifiers / var_decl / binop_mul prototypes
 * hoisted before return) migrated to pipeline_glue_emit_lea_fwd.c (same-TU
 * #include). Pure decls + #defines; no function bodies. PLATFORM: SHARED. */
#include "pipeline_glue_emit_lea_fwd.c"

/* wave144 pure-owned leave: pipeline_asm_emit_return.c deleted.
 * live = runtime_pipeline_abi pure (slice escape + return_elf_impl/_c + sret
 * memcpy/return_from_var + float promote pair + backend/asm/arm64 return_expr/lit);
 * seed cold twins under #ifndef FROM_X. Cap residual: expr_rec + float_widen +
 * enc slot + dual-gp length (block_inits) + type_size + spills + array_lit pure.
 * residual present 69→68. PLATFORM: SHARED freestanding emit. */

/* wave133 pure-owned leave: pipeline_asm_emit_unary.c deleted.
 * live = runtime_pipeline_abi pure (neg/lognot/bitnot + sxt + jz_after_bool);
 * seed cold twins under #ifndef FROM_X. Residual expr_rec (ko 22/23/24) +
 * match/fold call pure faces via emit_fwd extern decls — do not re-open a
 * second unary ELF face (G.7). PLATFORM: SHARED freestanding emit. */

/* wave138 pure-owned leave: pipeline_asm_emit_as.c deleted.
 * live = runtime_pipeline_abi pure (is_await / is_x_as_cast / await_sync /
 * try_propagate / float_lit / array_scalar / as_elf_impl / as_elf_c);
 * seed cold twins under #ifndef FROM_X. Cap residual float_bits + glue_arena
 * in ast_pool_arena.c; residual expr_rec/binop/block_body/struct_lit/array_lit
 * call pure faces via emit_fwd/lea_fwd extern decls — do not re-open a second
 * EXPR_AS ELF face (G.7). PLATFORM: SHARED freestanding emit. */
/* wave138: expr-kind ordinal macros kept in residual shell (was as.c header).
 * C AWAIT=54 / X EXPR_AS=54 collision; X EXPR_AWAIT=55; TRY_PROPAGATE 57/58;
 * STRING_LIT=59. Residual typeck_assign / check_expr / expr_rec consume these. */
#define GLUE_EXPR_KIND_ORD54 54
#define GLUE_EXPR_KIND_X_AWAIT 55
#define GLUE_EXPR_KIND_TRY_PROPAGATE 58
#define GLUE_EXPR_KIND_C_TRY_PROPAGATE 57
#define GLUE_EXPR_STRING_LIT_ORD 59

/* wave131 pure-owned leave: pipeline_asm_emit_async_cps.c deleted.
 * live = runtime_pipeline_abi pure (after_await + phase_reset + entry + end_func
 * + pure-owned CPS bag BSS 9124); seed cold twins under #ifndef FROM_X.
 * Residual as.c / return.c / block_body / mega_body call pure faces via
 * lea_fwd + emit_fwd extern decls — do not re-open a second async CPS ELF face (G.7).
 * PLATFORM: SHARED freestanding emit. */

/* wave128 pure-owned leave: pipeline_asm_emit_logand.c deleted.
 * live = runtime_pipeline_abi pure (logand_elf_impl + logor_elf_impl);
 * seed cold twin under #ifndef FROM_X. Residual expr_rec ko==20/21 calls these
 * public faces — prototypes in pipeline_glue_emit_fwd.c; do not re-open a
 * second LOGAND/LOGOR short-circuit ELF face (G.7).
 * PLATFORM: SHARED freestanding emit. */
/* wave1287 G.7: early emit inter-include forward-decl / static shell migrated to
 * pipeline_glue_emit_fwd.c (same-TU #include). Pure decls + glue_if_expr_arm_emit_depth
 * static + GLUE_TYPE_NAMED; no function bodies. PLATFORM: SHARED. */
#include "pipeline_glue_emit_fwd.c"
/* wave1289 G.7: mid-emit inter-include forward-decl / ordinal shell
 * (TypeKind/ExprKind ordinals + call/method/panic entry fwd + binop/field
 * operand loader fwd) migrated to pipeline_glue_emit_mid_fwd.c (same-TU
 * #include, hoisted before struct_lit — all consumers are later). Pure decls
 * + #defines; no function bodies. PLATFORM: SHARED. */
#include "pipeline_glue_emit_mid_fwd.c"

/* BC 8.3.1: asm ELF STRUCT_LIT emit domain
 * (field_store_sz + public wrapper + DEST_IN_RBX/rehome + fields + struct_lit_elf;
 *  Cap residual pure; same TU).
 * store_fixed_array_field / vector_let_init: pipeline_asm_emit_vector_let.c below. */
#include "pipeline_asm_emit_struct_lit.c"


/**
 * let v: i32xN = [..]：逐分量写入已分配向量栈槽（按值存放），勿 store 8 字节 temp 指针。
 */
/* wave143 pure leave */
extern int32_t pipeline_asm_array_lit_elem_byte_sz_c(struct ast_ASTArena *arena, int32_t expr_ref);

/* wave127 pure-owned leave: divisor_zero_check is public pure (was same-TU static).
 * Residual assign/binop call this face — extern only (G.7). */
extern int32_t pipeline_asm_emit_divisor_zero_check_rbx_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                             struct backend_AsmFuncCtx *ctx, int32_t ta);

/* wave146 pure-owned leave: pipeline_asm_emit_vector_let.c deleted.
 * live = runtime_pipeline_abi pure (leaf_elem + flat + vector_let_init +
 * field_frame_mag + store_fixed_array_field + type_is_fixed_array +
 * fixed_array let helpers); seed cold twins under #ifndef FROM_X.
 * Cap residual: vector_simd / struct_lit / call_args / index_helpers /
 * block_body call pure faces via emit_fwd extern decls — do not re-open a
 * second vector_let / fixed-array face (G.7).
 * PLATFORM: SHARED freestanding emit. */

/* wave1204 G.7: glue_vector_let_init_uses_direct_slot static fwd decl
 * removed — sole caller pipeline_asm_let_init_stack_reserve_bytes pure wave145.
 * Definition pure runtime_pipeline_abi (wave148 leave). PLATFORM: SHARED. */

/* wave1204 G.7: pipeline_asm_let_init_stack_reserve_bytes (1 fn, 9 lines)
 * migrated to pipeline_asm_emit_block_inits.c EOF (colocated with
 * glue_asm_init_expr_reserve_stack_bytes — its sole non-zero fallback callee).
 * 3 static callees all visible at block_inits.c #include point (L2404):
 *   glue_vector_let_init_uses_direct_slot  (vector_simd.c L2218, before L2404)
 *   glue_fixed_array_let_init_uses_direct_slot (vector_let.c L2063, before L2404)
 *   glue_asm_init_expr_reserve_stack_bytes  (block_inits.c EOF, same file)
 * Callers in context.c/ast_pool.c/ast_pool_top_level.c have same-TU visibility
 * (all #included AFTER L2404). modlet.c L530 (#include at L1543, BEFORE L2404)
 * uses extern fwd decl at modlet.c L336. No glue.c callsites remain.
 * Also removed: 2 static fwd decls (glue_asm_init_expr_reserve_stack_bytes
 * at old L1081 + glue_vector_let_init_uses_direct_slot at old L1464) — both
 * had pipeline_asm_let_init_stack_reserve_bytes as sole caller.
 * Root fix: original glue.c L1498 definition preceded vector_let.c #include
 * (L2063) — glue_fixed_array_let_init_uses_direct_slot had NO fwd decl,
 * relying on C implicit declaration. Migrating to block_inits.c (after all
 * #includes) fixes this latent issue.
 * PLATFORM: SHARED — pure stack byte arithmetic, no arch dependency. */


/* BC 8.3.1: asm ELF SIMD vector lane / shuffle / select / fma domain
 * (block_let_is_simd + lane operand/binop + var_copy + vector_binop_let +
 *  shuffle/select/fma/binop2 inline + emit_vector_type_let_init +
 *  colocated pure-call fold helpers; Cap residual pure; same TU).
 * glue_vector_type_lanes_esz / is_lane_binop / fixed-array wrappers stay above. */
/* wave148 pure-owned leave: pipeline_asm_emit_vector_simd.c deleted.
 * SIMD vector lane / shuffle / select / fma / CTFE fold faces live in
 * runtime_pipeline_abi pure (glue_block_let_is_simd_vector_type,
 * glue_emit_vector_type_let_init_elf_c, pipeline_asm_simd_try_inline_*,
 * glue_asm_local_var_stack_off_scoped, glue_module_func_index_by_name_c,
 * glue_fold_func_return_operand_ref_c, glue_expr_is_func_param_at_c, ...);
 * seed cold twins under #ifndef FROM_X. PLATFORM: SHARED. */
/* wave148 Cap residual externs for pure-owned faces (same-TU residual callers). */
extern int32_t glue_asm_local_var_stack_off_scoped(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx, int32_t var_expr_ref);
extern int32_t glue_module_func_index_by_name_c(struct ast_Module *mod, uint8_t *name, int32_t name_len);
extern int32_t glue_try_eval_pure_param0_scalar_func_c(struct ast_ASTArena *arena, struct ast_Module *mod, int32_t func_idx, int32_t arg_val, int32_t *out);
extern int32_t glue_fold_func_returns_param01_scalar_binop_c(struct ast_ASTArena *arena, struct ast_Module *mod, int32_t func_idx, int32_t *out_binop_ko);
extern int32_t glue_fold_func_returns_param0_index_const_c(struct ast_ASTArena *arena, struct ast_Module *mod, int32_t func_idx, int32_t *out_lane);
extern int32_t glue_fold_func_returns_param01_vector_binop_ctfe_c(struct ast_ASTArena *arena, struct ast_Module *mod, int32_t func_idx, int32_t *out_binop_ko);
extern int32_t glue_try_array_lit_lane_const_i32_c(struct ast_ASTArena *arena, int32_t arr_ref, int32_t lane, int32_t *out);
extern int32_t glue_fold_func_return_operand_ref_c(struct ast_ASTArena *arena, struct ast_Module *mod, int32_t func_idx);
extern int32_t glue_expr_is_func_param_at_c(struct ast_ASTArena *arena, struct ast_Module *mod, int32_t func_idx, int32_t expr_ref, int32_t param_ix);
extern int32_t glue_block_let_is_simd_vector_type(struct ast_ASTArena *arena, int32_t block_ref, int32_t let_idx);
extern int32_t glue_emit_vector_type_let_init_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref, struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t stack_slot_off, int32_t type_ref);
extern int32_t glue_vector_let_init_uses_direct_slot(struct ast_ASTArena *arena, int32_t type_ref, int32_t init_ref);
extern int32_t pipeline_asm_simd_try_inline_shuffle_call_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t call_ref, struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t stack_slot_off, int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_select_call_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t call_ref, struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t stack_slot_off, int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_fma3_call_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t call_ref, struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t stack_slot_off, int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_binop2_call_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t call_ref, struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t stack_slot_off, int32_t type_ref);



/* wave132 pure-owned leave: pipeline_asm_emit_struct_let.c deleted.
 * live = runtime_pipeline_abi pure (struct_let_init + type_let_init +
 * set/get call_sret_reg_shift + pure-owned sret flag);
 * seed cold twins under #ifndef FROM_X.
 * Cap residual: struct_lit_fields + try_inline* + set_call_expected_ret_ty +
 * call_return_byte_size + type_size_simple + named_layout + store_retval_pair +
 * emit_module_from_ctx (static→extern) + public emit_expr_elf_c.
 * Residual block_inits / vector_let / array_lit / assign / field_access /
 * call_args call pure faces via emit_fwd / backend_fwd extern decls —
 * do not re-open a second struct let-init ELF face (G.7).
 * PLATFORM: SHARED freestanding emit. */



/* BC 8.3.1: asm ELF INDEX residual helpers domain
 * (module_from_ctx + param/local slot ptr + field_type_ref + fixed_array
 *  total_bytes + index_elem_byte_sz_from_type_ref + try_index forest +
 *  soa_index_field_addr + lvalue_eff_addr; Cap residual pure; same TU).
 * index face (esz+emit+addr_of+deref): pipeline_asm_emit_index.c later.
 * 7.3 live/spill + bulk_mem_copy_spills: pipeline_asm_emit_spill.c next. */
#include "pipeline_asm_emit_index_helpers.c"


/* BC 8.3.1: asm ELF 7.3 live / Chaitin spill / bulk_mem / index-assign
 * residual domain (live_fwd + color + bulk_mem_copy_spills +
 * index_assign_finish_store + index scratch spill methods; Cap residual
 * pure; same TU). eff_addr_scaled → runtime_pipeline_abi pure (wave147). */
#include "pipeline_asm_emit_spill.c"

/* wave139 pure-owned leave: pipeline_asm_emit_modlet.c deleted.
 * Live = runtime_pipeline_abi pure (table BSS + 7 public faces); seed cold twins
 * under #ifndef FROM_X. Residual C callsites (assign/expr_rec/mega_body/top_level)
 * use extern decls in pipeline_glue_early_fwd.c. PLATFORM: SHARED. */


/* wave1291 G.7: glue_var_decl_type_ref_elf_c late redecl removed — now covered
 * by pipeline_glue_emit_lea_fwd.c (wave1288, same-TU before this site). */

/* wave142 pure-owned leave: pipeline_asm_emit_assign.c deleted.
 * Live authority = runtime_pipeline_abi pure (assign faces + field_assign_pair + body_expr_stmt_at).
 * Seed cold twins under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X. */


/* wave143 pure-owned leave: pipeline_asm_emit_array_lit.c deleted.
 * Live authority = runtime_pipeline_abi pure (elem_byte_sz + empty + emit/force_esz +
 * force_esz_from_elem + durable + fixed/array_temp_bytes + elem_type_ref).
 * Seed cold twins under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * Cap residual: leaf/flat stay vector_let (static→extern); al_nc_seq_take in glue.
 */


/* wave140 pure-owned leave: pipeline_asm_emit_index.c deleted.
 * Live = runtime_pipeline_abi pure (esz + INDEX/ADDR_OF/DEREF ELF faces); seed cold twins
 * under #ifndef FROM_X. Residual C callsites (expr_rec/assign/binop/helpers) use extern
 * decls in pipeline_glue_emit_fwd.c. Cap residual helpers remain index_helpers/spill (eff_addr pure wave147).
 * PLATFORM: SHARED. */


/* BC 8.3.1: asm ELF EXPR_MATCH / EXPR_IF emit domain
 * (match + expr_if; Cap residual pure; same TU). */
/* wave134 pure-owned leave: pipeline_asm_emit_match.c deleted.
 * live = runtime_pipeline_abi pure (match_elf + expr_if_elf + subject BSS +
 * name_is_subject_field); seed cold twins under #ifndef FROM_X. Residual
 * expr_rec (ko MATCH/IF) + host-C codegen call pure faces via emit_fwd
 * extern decls — do not re-open a second MATCH/EXPR_IF ELF face (G.7).
 * PLATFORM: SHARED freestanding emit. */


/* wave1212 G.7: glue_var_expr_stack_off_elf_c (18 lines, static) migrated to
 * pipeline_asm_emit_index_helpers.c EOF (colocated with 30+ callsites; #include
 * at L1530). Static fwd decl at L1109 retained — covers return.c L356
 * (#include L1302 < L1530) + glue.c internal callsites. Deps:
 * glue_asm_local_var_stack_off_scoped (vector_simd.c L93; #include L1513 < L1530).
 * PLATFORM: SHARED. */

/* wave124 pure-owned leave: pipeline_asm_emit_var_decl.c deleted.
 * live = runtime_pipeline_abi pure (glue_var_decl_type_ref_elf_c +
 * glue_lazy_append_block_let_local); seed cold twin under #ifndef FROM_X.
 * Residual mega leaves (assign/unary/binop/call_args/expr_rec/return/
 * block_inits/block_body) call these public faces — extern prototypes only;
 * do not re-open a second VAR type-ref / lazy block-let append path (G.7).
 * PLATFORM: SHARED freestanding emit. */
extern int32_t glue_var_decl_type_ref_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                            int32_t var_expr_ref);
extern int32_t glue_lazy_append_block_let_local(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                 int32_t block_ref, int32_t let_idx, uint8_t *name, int32_t name_len);
int32_t pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li);
void pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);

/* wave1018 G.7: glue_binop_as_needs_full_emit + try_binop residual
 * (load_operand / clobber / preserve-restore / commutative / left_rax /
 *  cmp_rbx_rax) folded into pipeline_asm_emit_binop.c.
 * wave1019: f32 VAR slot load + call_arg resolve folded into call_args leaf. */

/* wave147 pure-owned leave: pipeline_asm_emit_index_eff_addr.c deleted.
 * live = runtime_pipeline_abi pure (scaled + bounds + rvalue_slice_once + base/text
 * twins + public index_eff_addr elf/text faces); seed cold twins under #ifndef FROM_X.
 * Cap residual try_index forest + lvalue_eff_addr stay in index_helpers (static→extern
 * for eff_addr_rax helpers pure links). PLATFORM: SHARED freestanding emit.
 */

/* wave1020: expr_rec leaf (lit_i32 + rec + fast + emit_expr_elf_c) include
 * moved to after field_access — see wave1020 include below. Early forward
 * decls for rec/fast/lit_i32 remain above for index_helpers / array_lit. */

/* wave1291 G.7: glue_type_size_simple late redecl removed — now covered by
 * pipeline_glue_emit_fwd.c (wave1287, same-TU before this site). */

/** typeck ImportKind.IMPORT_BINDING / IMPORT_SELECT（与 ast.x 序数一致）。
 * wave1150 G.7: moved here from L8947 (was after call_args.c #include) so
 * glue_asm_resolve_call_target_module_c (migrated to call_args.c EOF) can
 * see GLUE_TYPECK_IMPORT_BINDING/SELECT. Anonymous enum — single authority. */
enum {
  GLUE_TYPECK_IMPORT_BINDING = 1,
  GLUE_TYPECK_IMPORT_SELECT = 2,
};

/* BC 8.3.1: asm ELF CALL-arg emit domain
 * (named_struct_layout predicate + lea_not_load + dual-GP load_var +
 *  named layout size + pass_addr + emit_expr_elf_for_call_args +
 *  call_arg resolve + f32 VAR slot load; Cap residual pure; same TU).
 * G.7 fold type_named_struct (wave1017) + resolve/f32 residual (wave1019). */
#include "pipeline_asm_emit_call_args.c"


/* wave1016 G.7: glue_emit_assign_rhs_to_rax folded into assign leaf; wave142 pure leave.
 * (included earlier after spill). Compound-assign uses binop helpers via
 * forwards in that leaf; early unary/as scalar/mul forwards remain ~2584.
 * binop residual scalar/ptr/add already in pipeline_asm_emit_binop.c (wave1015).
 * wave1017: type_named_struct predicate in call_args leaf (above).
 * wave1018: try_binop load/placement residual folded into binop leaf. */

/* wave127 pure-owned leave: pipeline_asm_emit_panic.c deleted.
 * live = runtime_pipeline_abi pure (xlang_panic_call + panic_elf +
 * panic_int_div_zero + divisor_zero_check_rbx); seed cold twin under
 * #ifndef FROM_X. Residual mega leaves (expr_rec / binop / assign /
 * index_eff_addr) call these public faces — prototypes in mid_fwd /
 * backend_fwd / above extern; do not re-open a second PANIC / div0 ELF
 * face (G.7). PLATFORM: SHARED freestanding emit. */

/* BC 8.3.1: asm ELF EXPR_BINOP emit domain
 * (add/sub/mul/div/mod/and/bitwise/shift + unsigned/64bit classifiers +
 * nested rax/rbx helpers + wave1015 residual scalar/ptr/add; Cap residual pure; same TU). */
#include "pipeline_asm_emit_binop.c"


/* BC 8.3.1: asm ELF EXPR_FIELD_ACCESS emit domain
 * (layout_by_name + call_arg struct/agg + call_base rvalue +
 * var_field_access + field_access_elf_fast; Cap residual pure; same TU). */
#include "pipeline_asm_emit_field_access.c"


/* BC 8.3.1 wave1020: asm ELF expr recursion + fast path domain
 * (lit_i32 + emit_expr_elf_rec + emit_expr_elf_c + emit_expr_elf_fast;
 *  Cap residual pure; same TU). G.7 fold fast residual into expr_rec leaf.
 * Include AFTER field_access / call_args / binop so fast callees exist.
 * Early forward decls (PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED / rec / fast)
 * remain near durable helpers for index_helpers / array_lit. */
#include "pipeline_asm_emit_expr_rec.c"

/* wave1166 G.7: pipeline_type_array_size_at migrated to ast_pool_type.c
 * (included from ast_pool.c L895). Fwd decls retained at L762 + L1887
 * for callsites before ast_pool.c #include at L5058.
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/** func 形参 / arena copy_slot 实现见 ast_pool.c（#include 进本 TU）。 */

/* wave1203 G.7: pipeline_module_fill_u8_64_from_src_c (1 fn, 15 lines) migrated
 * to ast_pool_arena.c EOF (colocated with wave1184 parser_library_init cluster —
 * 4 of 5 callsites at L541/560/584/676; 5th caller in pipeline_parser_result.c
 * L262 via extern fwd decl at L50). Fwd decl at glue.c L228 also removed (both
 * consumer files have their own fwd decls). No glue.c callsites. No static deps.
 * PLATFORM: SHARED — pure byte copy utility. */

/* wave1184 G.7: pipeline_parser_library_init_* + pipeline_parser_extern_init_arena_func
 * cluster (8 fns) migrated to ast_pool_arena.c EOF (same-TU #include via ast_pool.c
 * L886 -> ast_pool_arena.c). Members: library_init_bool_type / named_type / var_expr /
 * field_access_expr / enum_variant_expr / eq_expr / labeled_block + extern_init_arena_func.
 * All delegate to pipeline_arena_{type,expr,block,func}_ptr (defined in ast_pool_arena.c)
 * + pipeline_module_fill_u8_64 + ast_pipeline_block_append_labeled + pipeline_module_func_*.
 * Forward decls at ast_pool_arena.c L405-419 for same-TU visibility. All extern. */

/* wave1163 G.7: module_func name/body reader cluster (5 fns:
 * pipeline_module_func_name_write / name_copy64 / name_len_at /
 * is_extern_at / body_ref_at) migrated to ast_pool_module_func.c EOF
 * (colocated with module_func accessor domain). Forward decls at L96 /
 * L256-260 retained for early callsites (L637-649 etc.).
 * ast_pool.c #include at L5388 → ast_pool_module_func.c at L1222 within. */

/** struct_layout / import / top_level / enum / func 形参池实现见 ast_pool.c（文件末尾 #include）。 */

/* wave1210 G.7: glue_arena_expr_at_ref (5 lines, static) migrated to
 * pipeline_asm_emit_as.c EOF (colocated with earliest consumer; #include at L1324).
 * No static deps — sole call is pipeline_arena_expr_ptr (extern). Consumers all
 * #include after L1324: struct_lit (L1440), field_access (L1684), typeck_ctfe
 * (L1736), typeck_method_call (L4182). Existing static fwd decls in as.c L41
 * and field_access.c L712 now resolve to migrated def. PLATFORM: SHARED. */

/* wave965 BC 8.3.1: typeck CTFE producer (const whitelist + fold) — same TU slice.
 * Body: pipeline_typeck_ctfe.c. Requires glue_arena_expr_at_ref above.
 * PLATFORM: SHARED — host-cc via pipeline_x.o; STALE via PIPELINE_X_DEPS. */
#include "pipeline_typeck_ctfe.c"


/* wave1164 G.7: struct_lit accessor cluster (4 fns:
 * pipeline_expr_struct_lit_num_fields / type_name_len / type_name_into /
 * type_name_set) migrated to pipeline_asm_emit_struct_lit.c EOF (colocated
 * with STRUCT_LIT emit domain). glue_arena_expr_at_ref fwd decl in as.c L41
 * covers the migrated functions (same TU). Forward decl for num_fields at
 * L1540 retained (harmless). */

extern void driver_diagnostic_typeck_struct_padding_before(uint8_t *sname, int32_t sname_len, int32_t gap,
                                                           uint8_t *fname, int32_t fname_len);
extern void driver_diagnostic_typeck_struct_padding_trailing(uint8_t *sname, int32_t sname_len, int32_t gap);
extern void driver_diagnostic_typeck_struct_field_bad_size(uint8_t *sname, int32_t sname_len, uint8_t *fname,
                                                           int32_t fname_len);

static int32_t glue_type_align_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref, int32_t depth);
/* wave1291 G.7: glue_type_size_simple late redecl removed — covered by pipeline_glue_emit_fwd.c. */

/* wave1053 G.7: glue_struct_layout_metrics_c + typeck_typeck_struct_layout_metrics
 * migrated to pipeline_asm_emit_struct_lit.c (definitions at EOF). Static fwd
 * decl for metrics retained at glue.c:2794 (above) — callsites at glue.c:3050
 * (glue_type_align_simple recursive) + public wrapper removed below.
 * Public wrapper typeck_typeck_struct_layout_metrics was at glue.c:16631 —
 * extern-called by ast_pool.c:8151 (same pipeline_x.o symbol, no link change).
 * extern decls for driver_diagnostic_typeck_struct_padding_* / field_bad_size
 * retained below (still consumed by glue.c:2912/2962 warn_layout paths). */
static int32_t glue_struct_layout_metrics_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t li,
                                            int32_t depth, int32_t check_pad, int32_t *out_sz, int32_t *out_al);

/* wave1171 G.7: layout warn cluster (2 extern fns + 2 extern decls) migrated to
 * pipeline_asm_emit_struct_lit.c EOF. Colocated with glue_pad_fields_warn_enabled
 * (wave1070) + glue_field_type_atomic_sized (wave1071) + glue_hot_reorder_warn_enabled
 * (wave1072) + glue_type_size_simple (wave1056) — all static helpers consumed by
 * these warn functions were already migrated to struct_lit.c in earlier waves;
 * the extern consumer functions now join them in the same domain file.
 *
 * Migrated: pipeline_typeck_pad_fields_warn_layout + pipeline_typeck_hot_reorder_warn_layout
 * + extern decls for driver_diagnostic_warn_pad_fields_same_cache_line /
 *   driver_diagnostic_warn_hot_reorder_field.
 *
 * No glue.c callsites (sole callers are typeck_gen.c seed). No fwd decls needed.
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1054 G.7: glue_type_align_simple migrated to pipeline_asm_emit_struct_lit.c
 * (definition at EOF, after metrics). Static fwd decl retained above (L2787)
 * for glue.c callsites in pipeline_struct_layout_next_field_offset_ex body
 * + soa.c:94/140 via #include at L11697 (fwd decl at L2787 < L11697 visible).
 * struct_lit.c:65 fwd decl retained for struct_lit.c callsites at L726/L1040
 * (before EOF definition). Mutually recursive with glue_struct_layout_metrics_c
 * (wave1053 migrated to struct_lit.c EOF). */

/** DOD-S1：SoAStruct[N] 列主序总字节数；非 SoA 时返回 0 由调用方回落 AoS。 */
extern int32_t typeck_soa_array_storage_size_glue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                  int32_t elem_type_ref, int32_t array_len, int32_t depth);

/* wave1056 G.7: glue_type_size_simple migrated to pipeline_asm_emit_struct_lit.c
 * EOF (type sizing domain — completes struct layout registry triad:
 * size + align(wave1054) + metrics(wave1053)). Definition visible via same-TU
 * #include at L2095 < all callsites below. Static fwd decl at L1887 retained
 * for return.c (#include at L1957 < L2095) + glue.c callsites before L2095.
 * struct_lit.c local fwd decl at L81 retained for callsites before EOF def.
 * Redundant fwd decls in array_lit.c:35 / struct_let.c:95 / index_helpers.c:122
 * / index.c:35 harmless (C allows redeclaration); cleanup deferred.
 * Dependencies: typeck_x_type_size_from_layout_glue (extern L233 < 2095 visible)
 * + typeck_soa_array_storage_size_glue (extern above; also declared in
 * struct_lit.c for its body) + g_pipeline_asm_emit_dep_pipe (static global
 * L184 < 2095 visible). */



/**
 * wave625 Cap residual pure: force_esz for ARRAY_LIT packed into TYPE_SLICE / TYPE_ARRAY.
 *
 * Root: let/call/return only mapped scalar TypeKind → 1/4/8; TYPE_NAMED (Pt=8) stayed 0
 * → durable inferred default 4 → COMMON stored only w0 of by-value STRUCT_LIT (y lost)
 * while INDEX used glue_type_size_simple stride 8 → a[1].y unread (mac pure-asm sum=12).
 * Host-C static compound already correct (wave624).
 *
 * @param arena AST arena (non-null)
 * @param et TYPE_SLICE/ARRAY element type_ref (0 → 0)
 * @return 1/2/4/8 for scalars; layout size for TYPE_NAMED when known; else 0
 * PLATFORM: SHARED freestanding. G.7 authority for all force_esz call sites.
 */
/* wave1021: glue_array_lit_force_esz_from_elem_type_c body → pipeline_asm_emit_array_lit.c
 * (G.7; early forward above remains). */

/* wave1046 G.7: glue_func_return_byte_size_c migrated to
 * pipeline_asm_emit_call_args.c (definition at EOF; twin of
 * glue_func_param_agg_byte_size_c — same SysV ABI func sizing domain).
 * Same-TU #include at L2392 makes it visible to all glue.c callsites
 * below (frame-size reserve L5949 + sret activation L8968).
 * Dependencies: glue_type_size_simple (fwd decl L1887 < include 2392). */

/* wave1048 G.7: glue_call_return_byte_size_c migrated to
 * pipeline_asm_emit_call_args.c (definition at EOF; fwd decl at
 * call_args.c:356 — visible after #include at L2392 for glue.c:3269/3383
 * callsites. struct_let.c:93 retains its own fwd decl for struct_let.c:141).
 * Same CALL-expr return sizing domain as wave1046 glue_func_return_byte_size_c. */

/* wave1025 G.7: glue_emit_sret_memcpy_rbx_to_home_elf_c +
 * glue_emit_sret_return_from_var_elf_c + glue_copy_large_struct_from_rax_ptr_elf_c
 * wave144 pure leave: sret helpers live in runtime_pipeline_abi pure.
 * glue 1989-1991 forward decls kept (struct_lit/struct_let call them). */

/* wave1207 G.7: pipeline_asm_push_sysv_memory_by_value_elf_c (99 lines,
 * x86_64 SysV MEMORY push) migrated to pipeline_asm_emit_call_args.c EOF
 * (colocated with call-arg emit domain; #include at L1660). See call_args.c
 * EOF for full docblock + dep list. No TU-internal callsites — sole callers
 * are seeds (backend_call_dispatch.from_x.c L972/2540/3783/4008) via extern.
 * PLATFORM: LINUX+MACOS x86_64 SysV (ta==0). */

/* wave1208 G.7: pipeline_asm_store_memory_by_value_to_sp_elf_c (102 lines,
 * arm64 AAPCS64 MEMORY store) migrated to pipeline_asm_emit_call_args.c EOF
 * (colocated with call-arg emit domain; #include at L1660). G.7 twin of
 * push_sysv (x86 high-end push-reverse vs arm64 low-end copy-forward).
 * No TU-internal callsites — sole callers are seeds
 * (backend_call_dispatch.from_x.c L2644/4123) via extern.
 * PLATFORM: MACOS|ARM64 AAPCS64 (ta==1). */

/* wave1057 G.7: glue_sysv_dual_gp_byte_size_c migrated to
 * pipeline_asm_emit_call_args.c EOF (SysV ABI type classification domain).
 * Definition visible via same-TU #include at L2395 < all callsites below
 * (L3270/3398/3415/3421/3428). Static fwd decl at L2050 retained for
 * struct_lit.c:279 callsite (struct_lit.c #include at L2095 < call_args.c
 * #include at L2395). call_args.c:358 has its own fwd decl for callsites
 * at L396/L410/L1571 before the EOF definition. Dependency
 * glue_type_named_layout_size_any_module_elf_c already in call_args.c:454. */

/* wave1022: glue_slice_let_reent_deep_copy_after_dual_gp_elf_c body folded into
 * pipeline_asm_emit_call_args.c (G.7 有则补全; same TU). Callers: this residual
 * store_retval_pair (use_frame=1) + call_args for_call_args (use_frame=0).
 * g_pipeline_asm_al_nc_seq remains early in glue (shared with durable/return).
 */

/* wave1058 G.7: glue_store_retval_pair_to_rbp_elf_c migrated to
 * pipeline_asm_emit_call_args.c EOF (retval store domain). Definition
 * visible via same-TU #include at L2395 < callsite at L6291. Static fwd
 * decl at L2076 retained for struct_let.c:208 (struct_let.c #include at
 * L2269 < call_args.c L2395). struct_let.c:70 retains its own fwd decl.
 * block_body.c:595 + field_access.c:427 via #include > L2395 visible.
 * Dependencies: glue_type_size_simple (fwd L1887), glue_sysv_dual_gp_byte_size_c
 * (call_args.c:358), glue_copy_large_struct_from_rax_ptr (return.c:751),
 * glue_slice_dual_gp_length_off_c (fwd L1899), glue_slice_let_reent_deep_copy
 * (call_args.c:562), glue_deref_struct16/call_struct16_ret_needs_rax_deref
 * (#define-aliased to pipeline_asm_* externs, struct_let.c:76-77). */

/* wave1197 G.7: pipeline_asm_type_ref_byte_size_c migrated to
 * ast_pool_struct_layout.c EOF (same-TU #include via ast_pool.c L1615,
 * #include'd into glue.c at L3985 — after struct_lit.c L1438 where
 * glue_type_size_simple is defined as static; definition visible).
 * Sole callers are extern (backend_call_dispatch seed). PLATFORM: SHARED. */

/* wave1209 G.7: pipeline_asm_call_arg_value_byte_size_c (98 lines, call-arg
 * value byte size query for SysV GP packing) migrated to
 * pipeline_asm_emit_call_args.c EOF (colocated with call-arg size query domain;
 * #include at L1660). Resolves effective value size by checking formal param
 * type, expr resolved type, VAR decl type, FIELD_ACCESS field type in sequence,
 * taking the max. Returns 8 for TYPE_SLICE (pointer, 1 GP) and TYPE_ARRAY
 * (E* decay). Deps (all visible at #include point L1660):
 *  glue_type_size_simple                     (static, struct_lit.c L1270; #include L1440)
 *  glue_type_is_fixed_array                  (static, vector_let.c L739; #include L1455)
 *  glue_var_decl_type_ref_elf_c              (static, var_decl.c L51; #include L1610)
 *  glue_field_access_field_type_ref_c        (static, index_helpers.c L241; #include L1530)
 *  glue_type_named_layout_size_any_module_elf_c (static fwd decl, glue.c L1396)
 *  glue_field_access_layout_field_type_ref_by_name_c (static fwd decl, glue.c L1396)
 *  glue_sysv_dual_gp_byte_size_c             (static, call_args.c L1784)
 *  g_pipeline_asm_emit_module                (static var, glue.c L133; READ-ONLY)
 *  pipeline_expr_kind_ord_at / resolved_type_ref / pipeline_type_kind_ord_at (extern)
 * No TU-internal callsites — sole caller is seeds
 * (backend_call_dispatch.from_x.c L641) via extern.
 * PLATFORM: SHARED — size query; consumers apply LINUX+MACOS SysV 2-GP for 9–16B. */

/* wave1044 G.7: glue_struct_layout_compute_field_offset_c migrated to
 * pipeline_asm_emit_struct_lit.c (definition at EOF; forward decl at top
 * serves struct_lit.c callsites L152/L158 + glue.c internal callsites
 * L3759/3772/3774/3804 after #include 2092 — visible via that decl). */

/* wave1052 G.7: glue_sync_struct_layout_field_offsets_c migrated to
 * pipeline_asm_emit_struct_lit.c (definition at EOF). Forward decl below
 * retained for glue.c:11850 callsite (fill_struct_layouts — module layout
 * finalization pass). struct_lit.c:77 also has a forward decl; same-TU
 * #include at glue.c:2095 makes the definition visible to glue.c. */
/* Non-static after 8.3.3 R2 (typeck_x.o fill_soa calls this). */
void glue_sync_struct_layout_field_offsets_c(struct ast_Module *m, struct ast_ASTArena *a);

/* wave1050 G.7: glue_struct_layout_field_offset_by_name_c migrated to
 * pipeline_asm_emit_field_access.c (definition at EOF; field_access.c:708 fwd
 * decl retained for callsites at L811/L832/L866/L884 — all in field_access.c,
 * before the definition). glue.c has zero self-callsites — pure leaf consumed
 * only by field_access.c. */

/* wave1049 G.7: glue_struct_layout_index_by_type_name_c migrated to
 * pipeline_asm_emit_struct_lit.c (definition at EOF; struct_lit.c:59 fwd
 * decl retained for struct_lit.c:162 callsite. field_access.c:706 fwd decl
 * retained for field_access.c:830/882 callsite — field_access.c #include
 * at L2419 > struct_lit.c L2095 so definition is visible there). glue.c
 * has zero self-callsites — pure leaf consumed by struct_lit + field_access. */

/* wave1197 G.7: pipeline_struct_layout_next_field_offset_ex +
 * pipeline_struct_layout_next_field_offset (2 fns) migrated to
 * ast_pool_struct_layout.c EOF (same-TU #include via ast_pool.c L1615,
 * #include'd into glue.c at L3985 — after struct_lit.c L1438 where
 * glue_type_size_simple / glue_type_align_simple / glue_type_is_empty_struct_c
 * are defined as statics; definitions visible). Sole in-TU caller was
 * _offset→_ex (internal, moved together); all other callers are extern
 * (typeck.x / parser.x / parser_asm_struct_layout_slice.inc seed).
 * PLATFORM: SHARED. */

/* wave1051 G.7: pipeline_expr_struct_lit_value_bytes migrated to
 * pipeline_asm_emit_struct_lit.c (definition at EOF; struct_lit.c:69 fwd decl
 * for glue_struct_layout_metrics_c added — static, defined later in TU at
 * glue.c:2794). glue.c:1693 public forward decl retained (public symbol).
 * Consumed by struct_lit.c:612 + field_access.c:330 — field_access.c #include
 * at L2419 > struct_lit.c L2095 so definition is visible there. glue.c has
 * zero self-callsites — pure leaf consumed by struct_lit + field_access. */

/* wave1035 G.7: pipeline_expr_struct_lit_field_offset_at +
 * pipeline_expr_struct_lit_field_type_ref_at folded into
 * pipeline_asm_emit_struct_lit.c (included at glue.c:2172). struct_lit.c
 * is the sole in-TU leaf consumer (offset: 1 callsite L276; type_ref: 2
 * callsites L119/L278); residual glue.c wrappers codegen_/backend_ at
 * L17076/L17084 are after struct_lit.c #include — definition visible,
 * no forward decl needed. Seed backend_try_inline_dispatch consumes via
 * extern — symbol still in pipeline_x.o.
 */

/** struct_lit 字段名/init 读 API 见 ast_pool.c（侧车池）。 */

/* wave1216 G.7: pipeline_expr_kind_ord_at (7 lines) migrated to
 * pipeline_parse_orch.c EOF (colocated with sole dep glue_arena_expr_kind_at_ref
 * — wave1211 migrated to parse_orch.c L982; #include at L2902).
 * ast pool expr kind ordinal reader — invalid ref -> -1.
 * Dep: glue_arena_expr_kind_at_ref (static, parse_orch.c L982, same file —
 *   direct call, no fwd decl needed).
 * Fwd decls at L1008 + L2016 retained — cover all TU-internal callsites
 * in #include'd files (parse_orch.c L2902, ast_pool.c L2847, asm_emit_*.c
 * L1525-1673, check_block.c L4195, etc.) and seeds via extern.
 * No dual authority (seeds only declare extern, no definition).
 * PLATFORM: SHARED — pure reader, no arch dependency. */

/* wave1162 G.7: int_val_at + int64_val_at migrated to
 * pipeline_asm_emit_expr_rec.c EOF. Fwd decls at L1530-1531. */

/* wave1172 G.7: pipeline_typeck_check_expr_int_lit_c migrated to
 * pipeline_typeck_coerce_init.c EOF. Colocated with coerce_init domain —
 * int literal type resolution (i32 vs i64) is the entry point for literal
 * coerce. No glue.c callsites (sole caller is typeck_gen.c seed).
 * Dependencies: glue_arena_expr_at_ref (static, glue.c L2437 < coerce_init.c
 * #include L8661) + pipeline_type_ensure_by_kind_ord (fwd decl glue.c L769).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1162 G.7: unary/field_access/var/null/binop accessor cluster
 * (11 fns: unary_operand_ref_at, field_access_name_into/len/base_ref,
 * var_name_into/len_for_string_lit/len, is_null_keyword_c,
 * tag_null_keyword_c, binop_left/right_ref_at) migrated to
 * pipeline_asm_emit_expr_rec.c EOF. Fwd decls at L1530-1571. */

/* wave1146 G.7: pipeline_asm_typekind_variant_tag lived at cmp.c EOF;
 * wave137 pure-owned leave: table + CMP face live in runtime_pipeline_abi
 * pure (no_mangle). field_access Cap residual calls pure via extern
 * (pipeline_glue_emit_fwd.c). */

/* wave137 pure-owned leave: pipeline_asm_emit_cmp.c deleted.
 * Live = runtime_pipeline_abi pure:
 *   pipeline_asm_cmp_cc_for_expr_kind_ord
 *   pipeline_asm_arm64_cset_cond_enc_from_cc
 *   pipeline_asm_typekind_variant_tag
 *   pipeline_asm_emit_cmp_elf
 * Cap residual: try_binop_cmp + var stack_off + slot invalidate_rbx +
 * enc ucomisd/ucomiss/setcc + CTFE folded + call_return_kind + enum_namespace_tag.
 * seed cold twins under #ifndef FROM_X. PLATFORM: SHARED. */


/* wave1287 G.7: block-accessor + block-if emit pure-fwd shell migrated to
 * pipeline_glue_emit_block_fwd.c (same-TU #include). Pure decls only;
 * definitions in ast_pool_block / later domain leaves. PLATFORM: SHARED. */
#include "pipeline_glue_emit_block_fwd.c"

/* wave1055 G.7: glue_fixed_array_temp_bytes + glue_array_temp_bytes_for_let_init
 * migrated to pipeline_asm_emit_array_lit.c EOF (array temp sizing domain).
 * Definitions visible via same-TU #include at L2299 < all callsites below
 * (L4018/4042/6402/6483 + block_body.c:473/606 via #include at L4117).
 * Dependencies (glue_type_size_simple fwd decl L1887 < 2299; public pipeline_*
 * / ast_pipeline_* / pipeline_asm_array_lit_elem_type_ref @ L1278) all visible
 * at array_lit.c. No fwd decl retained in glue.c — zero callsites before L2299. */

/* wave1105 G.7: asm_func_ctx next_offset management domain (3 fns) lived in
 * pipeline_asm_emit_next_offset.c (same-TU #include).
 * wave126 BC pure-owned leave: glue_align_next_offset +
 * pipeline_asm_bump_next_offset_for_array_lit +
 * pipeline_asm_bump_next_offset_after_let_init live = runtime_pipeline_abi pure;
 * seed cold twins under #ifndef FROM_X. Cap residual:
 * glue_array_temp_bytes_for_let_init (array_lit residual, static→extern) +
 * pipeline_expr_* / pipeline_block_let_type_ref. Host-cc leaf deleted.
 * Forward decls remain in pipeline_glue_backend_fwd.c / array_lit (non-static).
 * PLATFORM: SHARED. */

/* wave1043 G.7: glue_emit_array_let_empty_init migrated to
 * pipeline_asm_emit_block_body.c (sole consumer block_body_sync_elf +
 * glue.c internal callsites 6791/6872 after #include 4459 — visible via
 * forward decl in block_body.c). Definition removed from here. */

/* wave1073 G.7: glue_block_stmt_order_has_return migrated to
 * pipeline_asm_emit_block_body.c EOF (block stmt_order return scanner,
 * consumed by block_body_sync_elf + block_if_stmt). Static same-TU:
 * block_body.c #include L3872 < fwd decl L48 < def EOF. Callsites:
 * block_body.c:819/851 + block_if_stmt.c:82 (via #include L3875 > L3872).
 * Deps: ast_ast_block_* / ast_pipeline_block_* / pipeline_expr_kind_ord_at
 * / pipeline_block_labeled_* (all extern). */

/* wave1291 G.7: glue_asm_emit_array_lit_durable_ptr_rax_elf_c +
 * glue_array_lit_emit_scalar_elem_to_rax_elf_c late redecls removed — both
 * now covered by pipeline_glue_emit_lea_fwd.c (wave1288, same-TU before here). */

/* wave145 pure-owned leave: pipeline_asm_emit_block_inits.c deleted.
 * Faces live in runtime_pipeline_abi.x (+ seed cold twins under ifndef FROM_X):
 * dual_gp, slice_from_array, block_inits_elf, skip-typeck fill cluster,
 * fill_block_locals_tree, let_init_stack_reserve. Residual C Cap residual.
 * PLATFORM: SHARED freestanding emit.
 */


/* wave122 pure-owned leave: pipeline_asm_emit_with_arena.c deleted.
 * live = runtime_pipeline_abi pure (glue_with_arena_scope_* /
 * glue_wa_* / glue_emit_with_arena_*); seed cold twin under #ifndef FROM_X.
 * Residual block_body (same mega TU) still calls the public faces — extern
 * prototypes only; do not re-open a second WA scope path (G.7).
 * PLATFORM: SHARED — dual-end L2 after leave. */
extern int32_t glue_with_arena_scope_active_c(void);
extern int32_t glue_with_arena_scope_top_off_c(void);
extern void glue_wa_emit_begin_func_c(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena, int32_t body_ref);
extern int32_t glue_wa_scope_alloc_off_c(struct backend_AsmFuncCtx *ctx);
extern void glue_wa_scope_push_c(int32_t wa_off);
extern void glue_wa_scope_pop_c(void);
extern int32_t glue_emit_with_arena_init_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            struct backend_AsmFuncCtx *ctx, int32_t wa_off, int32_t cap_ref, int32_t ta);
extern int32_t glue_emit_with_arena_deinit_elf(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t wa_off, int32_t ta);


/* BC 8.3.1: asm ELF block body sync emit domain (defer + body_sync + accessors; same TU). */
#include "pipeline_asm_emit_block_body.c"

/* wave129 pure-owned leave: pipeline_asm_emit_block_if_stmt.c deleted.
 * live = runtime_pipeline_abi pure (block_if_stmt_elf + if_then_block_body_elf_c);
 * seed cold twin under #ifndef FROM_X. Residual block_body_sync if arm + backend.x
 * call public faces — prototype in pipeline_glue_emit_block_fwd.c; do not re-open a
 * second then-first block-if ELF face (G.7).
 * PLATFORM: SHARED freestanding emit. */


/* wave1034 G.7: pipeline_expr_float_bits_lo/hi_at folded into
 * pipeline_asm_emit_as.c (included at glue.c:2062). as.c is the sole
 * in-TU leaf consumer (4 callsites: array_lit pack + float_lit emit);
 * ast_pool.c wrapper (pipeline_expr_float_bits_lo/hi) is after as.c
 * #include — definition visible, no forward decl needed. */

/* wave1159 G.7: pipeline_expr_call_callee_ref_at migrated to
 * pipeline_typeck_method_call.c EOF. Fwd decl already exists above. */

/* wave1160 G.7: expr accessor cluster (10 extern fns) migrated to
 * pipeline_asm_emit_expr_rec.c EOF (colocated with expr ELF recursion
 * dispatcher domain). Fwd decls already exist at L1532-1578 (before
 * #include L2210). ast_pipeline_* wrappers also migrated. */

/* wave1159 G.7: method_call accessor cluster (4 extern fns) migrated to
 * pipeline_typeck_method_call.c EOF (colocated with method_call typeck
 * domain). Fwd decls in method_call.c top; visible via #include L9703. */

/* wave1173 G.7: type init/find-or-alloc cluster (6 fns + 1 static helper
 * glue_type_kind_from_ord) migrated to ast_pool_type.c EOF. Colocated with
 * type pool domain — all allocate/find type slots via pipeline_arena_type_alloc
 * + pipeline_arena_type_ptr (ast_pool_arena.c, included before ast_pool_type.c).
 * No glue.c callsites for the 5 init/find_or_alloc fns (sole callers are
 * typeck_gen.c / codegen_gen.c seeds via extern). pipeline_type_ensure_by_kind_ord
 * fwd decl retained at L773 for callsites (all after ast_pool.c #include at
 * L5058; fwd decl retained defensively).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1176 G.7: backend return-expr ref cluster (8 fns) migrated to
 * runtime_pipeline_abi pure (wave144 leave) (colocated with EXPR_RETURN emit domain).
 * Members: pipeline_backend_get_return_expr_ref / _at +
 * pipeline_arm64_get_return_lit_ref / _at + pipeline_backend_type_kind_ord_at
 * (L3514 below, also removed) + pipeline_asm_get_return_expr_ref_at (L4546,
 * also removed) + pipeline_asm_get_return_lit_ref_at (L4615, also removed) +
 * arch_arm64_pipeline_asm_get_return_lit_ref_at (L4638, also removed).
 *
 * wave144 pure leave: faces live in runtime_pipeline_abi pure; Cap residual:
 * pipeline_arena_block_ptr (L215) / pipeline_block_labeled_return_expr_ref
 * (L203) / pipeline_arena_expr_ptr (L214) / pipeline_block_expr_stmt_ref (L92)
 * / pipeline_module_func_ptr (L91) / pipeline_type_kind_ord_at (L761).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1202 G.7: pipeline_asm_index_elem_byte_sz public wrapper (1 fn) migrated
 * to pipeline_asm_emit_index.c EOF (colocated with static
 * pipeline_asm_index_elem_byte_sz_c at L43 — the sole implementation this
 * wrapper delegates to). No glue.c callsites (sole callers are seeds:
 * backend_try_inline_dispatch*.from_x.c via extern decl). No extern fwd decl
 * needed — definition visible via same-TU #include at L1556. PLATFORM: SHARED. */

/* wave1161 G.7: index/field_access/line/col accessor cluster (10 extern
 * fns) migrated to pipeline_asm_emit_expr_rec.c EOF (colocated with
 * expr ELF recursion dispatcher). Fwd decls already exist at L1554-1565.
 * Note: pipeline_expr_set_field_access_enum_variant,
 * pipeline_expr_set_field_access_soa_stride remain in glue.c (different
 * domain / dependency). */

/* wave1178 G.7: pipeline_expr_typeck_set_float_bits_from_val migrated to
 * pipeline_typeck_coerce_init.c EOF (colocated with int_lit coerce domain).
 * pipeline_dep_ctx_typeck_loop_depth_at migrated to ast_pool_dep_ctx.c EOF
 * (colocated with PipelineDepCtx cold accessor domain).
 * Both have no glue.c callsites (sole callers are typeck_gen.c seed via
 * extern). PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1179 G.7: field_access enum/soa setter cluster (5 fns) migrated to
 * pipeline_asm_emit_field_access.c EOF (colocated with FIELD_ACCESS emit
 * domain). Members: pipeline_expr_set_field_access_enum_variant +
 * pipeline_expr_set_field_access_soa_stride +
 * pipeline_expr_field_access_is_enum_variant +
 * pipeline_expr_enum_namespace_field_tag +
 * pipeline_expr_enum_field_tag_via_module (def + fwd decl L3196, both
 * removed).
 *
 * All deps fwd-declared before pipeline_asm_emit_field_access.c #include
 * at L2111: glue_arena_expr_at_ref (static fwd decl in field_access.c L712)
 * + pipeline_expr_kind_ord_at / var_name_* / field_access_name_* (L1554-1565)
 * + pipeline_token_kind_variant_tag (L1773) + glue_enum_field_name_equal
 * (static in field_access.c L1169) + g_pipeline_asm_emit_module (L132).
 * No glue.c callsites (sole callers are typeck_gen.c / codegen_gen.c seeds
 * via extern). PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/** typeck.x get_field_offset_from_layout_deps；asm emit 跨模块 struct 字段偏移回落。 */
extern int32_t typeck_get_field_offset_from_layout_deps(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                                        uint8_t *type_name, int32_t type_name_len, uint8_t *field_name,
                                                        int32_t field_name_len);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);

/* wave1026 G.7: glue_dep_layout_field_offset_by_name_c +
 * glue_field_layout_offset_for_{var_base,base}_field +
 * glue_field_access_effective_offset_c +
 * pipeline_expr_field_access_layout_offset +
 * glue_field_access_load_bytes_for_type_ref +
 * pipeline_expr_field_access_load_byte_sz
 * folded into pipeline_asm_emit_field_access.c (same TU #include; no new DEPS).
 * glue 1726-1727 public fwd decls kept (backend_try_inline extern).
 * glue 2500 static fwd decl kept (index_helpers/assign/index_eff_addr/vector_let). */

/* wave1074 G.7: glue_enum_field_name_equal migrated to
 * pipeline_asm_emit_field_access.c EOF (enum variant name prefix match,
 * consumed by pipeline_expr_enum_namespace_field_tag — also migrated in
 * wave1179). Static same-TU: field_access.c #include L2111 < def EOF.
 * Deps: strlen / memcmp (libc, global). */

/* wave141 pure-owned leave: pipeline_asm_emit_context.c deleted.
 * Live = runtime_pipeline_abi pure (set/get context + param-ptr lookup +
 * compute_frame_size + fill_param_slots + param_home_elf + fill_local_slots).
 * Cap residual: glue_statics cells via pipeline_asm_emit_ctx_*_get/set +
 * host_is_arm64 + param width/agg/return + frame walk sums + enc/sret/PGO.
 * Residual C may still direct-access g_pipeline_asm_emit_* statics (same cells).
 * Seed cold twins under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: SHARED freestanding. */

/* wave1179: pipeline_expr_enum_field_tag_via_module migrated to
 * pipeline_asm_emit_field_access.c EOF (colocated with enum_namespace_field_tag). */
/* wave1176: pipeline_backend_type_kind_ord_at migrated to
 * runtime_pipeline_abi pure (wave144 leave) (colocated with backend return-expr cluster). */

/* wave1175 G.7: asm-prefixed module func forwarders (7 fns) migrated to
 * ast_pool_module_func.c EOF. Colocated with pipeline_module_func_* domain.
 * Fwd decls retained at L778/L7685 + added L767-770 for 5 fns previously
 * without declarations. All callsites before ast_pool.c #include at L5055
 * resolved via fwd decls.
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave139: modlet domain pure-owned leave (was wave1100 same-TU #include). Live=runtime_pipeline_abi pure; residual callsites via early_fwd extern. PLATFORM: SHARED. */

/**
 * 栈帧大小：模拟 fill_param + 块树 fill_local 后的 next_offset（真实 struct/vector 槽宽）
 * + 数组 temp + with_arena temp + SysV call-arg spill + 最小 scratch + 64B。
 *
 * PLATFORM: SHARED frame formula; call-spill advance is LINUX+MACOS x86_64 SysV
 * (glue_sysv_spill_rax_rdx_to_frame_c permanently bumps next_offset by 32B/reg-arg).
 * arm64 does not use that spill path — over-reserve is safe.
 */
/* wave1046 G.7: glue_func_return_byte_size_c forward decl removed —
 * definition migrated to pipeline_asm_emit_call_args.c (same-TU #include
 * at L2392, before all callsites below). */
/* wave1047 G.7: glue_func_param_home_width_c forward decl removed —
 * definition migrated to pipeline_asm_emit_call_args.c (same-TU #include
 * at L2392, before all callsites below). */
/* wave1045 G.7: glue_func_param_agg_byte_size_c forward decl removed —
 * definition migrated to pipeline_asm_emit_call_args.c (same-TU #include
 * at L2392, before all callsites below). */

/**
 * Permanent next_offset advance per spilled SysV register-class call arg.
 * Matches glue_sysv_spill_rax_rdx_to_frame_c: off = next+16; next = off+16.
 * PLATFORM: LINUX+MACOS x86_64 SysV (producer); SHARED frame-size consumer.
 */
/* wave1138-1140 G.7: frame-size spill byte summation cluster migrated to
 * pipeline_asm_emit_spill.c EOF (glue_asm_sum_expr_call_spill_bytes +
 * glue_sum_block_slice_reent_dc_bytes_c + glue_asm_sum_block_call_spill_bytes
 * + 3 macros GLUE_ASM_CALL_SPILL_SLOT_BYTES / _FRAME_WALK_VISIT_MAX /
 * _FRAME_WALK_DEPTH_MAX). Visible here via #include at L2181. Extern fwd
 * decls below kept for other callers (pipeline_block_*_ref at L7592/L10719). */


extern int32_t pipeline_expr_method_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_block_while_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
extern int32_t pipeline_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
extern int32_t pipeline_block_for_init_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_step_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_body_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t pipeline_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri);

/* wave1200 G.7: frame/param/local slots cluster (4 fns) migrated to
 * pipeline_asm_emit_context.c EOF (colocated with asm emit context domain).
 * Members: pipeline_asm_compute_frame_size_c + pipeline_asm_fill_param_slots
 * + pipeline_asm_emit_param_home_elf_c + pipeline_asm_fill_local_slots.
 * Same-TU #include at L2570 (before this point) makes definitions visible
 * to all callers below (L3145/L3521/L3558/L3562/L3576).
 * All static deps visible at #include point:
 * g_pipeline_asm_emit_module/_arena/_func_sret_active/_sret_home_off (L132-188);
 * pipeline_asm_ctx_layout static at L86; asm_ctx_local_reset/
 * asm_ctx_fill_locals_block_tree fwd decls L962-963;
 * pipeline_asm_abi_f32_xmm_enabled_c extern at L890;
 * pipeline_asm_hoist_target_func_index fwd decl L967;
 * pipeline_asm_sum_module_top_level_lets_stack fwd decl L968;
 * glue_func_param_home_width_c/glue_func_param_agg_byte_size_c/
 * pipeline_asm_emit_param_home_elf_sysv_f32_xmm_c in call_args.c (#include L1656).
 * Fwd decls retained: pipeline_asm_compute_frame_size_c at L965 (harmless).
 * PLATFORM: SHARED. */

/* wave1102 G.7: asm label integer format domain (2 functions) migrated to
 * pipeline_asm_label_format.c (same-TU #include). Members:
 * glue_format_u32_to_buf / glue_format_i32_to_buf.
 * PLATFORM: SHARED. */
#include "pipeline_asm_label_format.c"

/* wave1201 G.7: asm label format public wrappers (2 fns) migrated to
 * pipeline_asm_label_format.c EOF (colocated with wave1102 integer format
 * primitives — sole consumers of glue_format_u32_to_buf / glue_format_i32_to_buf).
 * Members: pipeline_asm_emit_next_label_c (".Lf<scope>_<n>") +
 * pipeline_asm_format_label_id_c (".L_<id>").
 * Same-TU #include at L2653 makes definitions visible to all callers below
 * (mega_body callsite at L3173). Static deps visible at #include point:
 * pipeline_asm_ctx_layout (L86) + pipeline_glue_AsmFuncCtxLayout (struct top)
 * + pipeline_elf_label_mod_scope_active (extern L836).
 * Extern fwd decl retained at L835 (pipeline_asm_emit_next_label_c — called
 * by glue.c L3173 mega_body). PLATFORM: SHARED. */

/* wave1206 G.7: pipeline_asm_emit_if_then_block_body_elf_c (1 fn, 21 lines)
 * was in pipeline_asm_emit_block_if_stmt.c EOF; wave129 pure-owned leave →
 * runtime_pipeline_abi pure (colocated with if-stmt
 * emit domain; #include at L2421). Deps: pipeline_asm_ctx_layout (static L86,
 * before L2421) + pipeline_glue_AsmFuncCtxLayout (struct top) +
 * pipeline_asm_fill_local_slots (defined in context.c L2564, AFTER L2421 —
 * extern fwd decl added at block_if_stmt.c L25) + backend_emit_block_body_sync_elf
 * (extern fwd decl at glue.c L1068). No TU-internal callsites — sole callers
 * are seeds (backend.x L1282) via extern + ast_pool.c symbol table L9796.
 * PLATFORM: SHARED — pure block body emit orchestration, no arch branch. */

/* wave1154 quarantined + wave1239 physically deleted: glue_emit_block_stmt_
 * order_let_const_elf (~134 LOC, static, zero callsites — superseded by
 * backend_emit_block_body_sync_elf in pipeline_asm_emit_block_body.c which
 * handles stmt_order let/const init via the same code path). PLATFORM: SHARED. */

/* wave1199 G.7: backend_emit_loop_body_content_elf_sync migrated to
 * pipeline_asm_emit_fold_count_up_while.c EOF (colocated with while/for
 * loop emit + count_up_while fold domain). Same-TU #include at L3395.
 * Fwd decl at L1004 retained (before block_body.c #include at L2427
 * which calls it at L667/L674). PLATFORM: SHARED. */

/* wave1106 G.7: fold pattern detection primitives domain (13 fns)
 * migrated to pipeline_asm_emit_fold_primitives.c (same-TU #include).
 * Members: glue_fold_expr_var_refs_same_c / glue_fold_parse_while_lt_i_n_c /
 * glue_fold_block_let_init_lit_c / glue_parse_i_mul_add_lit_c /
 * glue_is_assign_var_add_one_c / glue_expr_is_param0_field_access_c /
 * glue_fold_func_returns_param0_field_sum_c / glue_is_field_assign_from_var_c /
 * glue_is_field_assign_i_plus_one_c / glue_is_assign_s_plus_pair_field_sum_call_c /
 * glue_is_assign_u8_index_store_cast_i_c / glue_is_assign_sum_plus_u8_index_cast_c
 * + glue_expr_var_name_eq_let_idx_c (moved from after x86_enc_helpers #include).
 * #include point AFTER pipeline_asm_emit_vector_simd.c (L2218, provides
 * glue_expr_is_func_param_at_c + glue_fold_func_return_operand_ref_c) and
 * pipeline_asm_emit_as.c (L1938, provides glue_expr_is_x_as_cast_at_c);
 * BEFORE pipeline_asm_emit_x86_enc_helpers.c (L6032) — x86 encoders are
 * consumed by fold EMITTERS that follow, primitives must precede them.
 * Consumers (glue_match_* / glue_try_fold_* / backend_try_fold_count_up_while_elf)
 * all follow this #include point.
 * Deps: pipeline_expr_* / pipeline_block_* / ast_ast_block_* / pipeline_call_*
 * (all public pool accessors) + GLUE_EXPR_KIND_VAR (macro, earlier in glue.c).
 * No static deps on other glue domains.
 * PLATFORM: SHARED. */
/* wave136 pure-owned leave: pipeline_asm_emit_fold_primitives.c deleted.
 * live = runtime_pipeline_abi pure (13 fold pattern detectors);
 * seed cold twins under #ifndef FROM_X. Residual fold_count_up_while calls pure
 * faces via extern decls below — do not re-open a second fold-primitives face (G.7).
 * Cap residual pure uses: pool faces + glue_expr_is_func_param_at_c /
 * glue_fold_func_return_operand_ref_c (vector_simd non-static) +
 * glue_expr_is_x_as_cast_at_c (as non-static).
 * PLATFORM: SHARED. */
extern int32_t glue_fold_expr_var_refs_same_c(struct ast_ASTArena *arena, int32_t a_ref, int32_t b_ref);
extern int32_t glue_fold_parse_while_lt_i_n_c(struct ast_ASTArena *arena, int32_t cond_ref, int32_t *out_i_ref,
                                              int32_t *out_n_is_lit, int32_t *out_n_lit, int32_t *out_n_ref);
extern int32_t glue_fold_block_let_init_lit_c(struct ast_ASTArena *arena, int32_t block_ref, int32_t var_ref,
                                              int32_t *out_lit);
extern int32_t glue_parse_i_mul_add_lit_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t i_ref,
                                          int32_t *out_c1, int32_t *out_c2);
extern int32_t glue_is_assign_var_add_one_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t target_ref);
extern int32_t glue_expr_is_param0_field_access_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                  int32_t func_idx, int32_t expr_ref);
extern int32_t glue_fold_func_returns_param0_field_sum_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                         int32_t func_idx);
extern int32_t glue_is_field_assign_from_var_c(struct ast_ASTArena *arena, int32_t er, int32_t pair_ref,
                                               uint8_t field_ch, int32_t src_ref);
extern int32_t glue_is_field_assign_i_plus_one_c(struct ast_ASTArena *arena, int32_t er, int32_t pair_ref,
                                                 int32_t i_ref);
extern int32_t glue_is_assign_s_plus_pair_field_sum_call_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                           int32_t er, int32_t *out_s_ref, int32_t pair_ref);
extern int32_t glue_is_assign_u8_index_store_cast_i_c(struct ast_ASTArena *arena, int32_t er, int32_t *out_buf_ref,
                                                      int32_t i_ref);
extern int32_t glue_is_assign_sum_plus_u8_index_cast_c(struct ast_ASTArena *arena, int32_t er, int32_t *out_sum_ref,
                                                       int32_t *out_buf_ref, int32_t j_ref);
extern int32_t glue_expr_var_name_eq_let_idx_c(struct ast_ASTArena *arena, int32_t var_expr_ref,
                                               int32_t body_ref, int32_t let_idx);


/* wave1106: remaining 11 fold primitives (glue_fold_parse_while_lt_i_n_c through
 * glue_is_assign_s_plus_pair_field_sum_call_c) removed — now provided by
 * pipeline_asm_emit_fold_primitives.c #include above. */

/* wave1068 G.7: glue_field_assign_pair_base_ref_c migrated to
 * pipeline_asm_emit_assign.c EOF (fold/affine pattern detection). Static
 * same-TU: asm_emit_assign.c #include L2294 < def L6499 < callsite L6664.
 * Deps: pipeline_expr_kind_ord_at / pipeline_expr_binop_left_ref_at /
 * pipeline_expr_field_access_base_ref (all extern). */

/* wave1106: glue_is_assign_u8_index_store_cast_i_c +
 * glue_is_assign_sum_plus_u8_index_cast_c removed — now provided by
 * pipeline_asm_emit_fold_primitives.c #include above. */

/* wave135 pure-owned leave: pipeline_asm_emit_x86_enc_helpers.c deleted.
 * live = runtime_pipeline_abi pure (27 glue_enc_x86_* + glue_emit_lcg_xor_body_x86_c);
 * seed cold twins under #ifndef FROM_X. Residual fold_count_up_while calls pure
 * faces via extern decls below — do not re-open a second x86 micro-encoder face (G.7).
 * PLATFORM: LINUX+MACOS x86_64 SysV raw encoders. */
extern int32_t glue_enc_x86_cmpl_eax_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);
extern int32_t glue_enc_x86_imull_imm_eax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);
extern int32_t glue_enc_x86_addl_imm_eax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);
extern int32_t glue_enc_x86_addl_imm_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off, int32_t imm32);
extern int32_t glue_enc_x86_movl_rbp_off_to_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off);
extern int32_t glue_enc_x86_movl_rbp_off_to_edx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off);
extern int32_t glue_enc_x86_movl_ecx_to_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off);
extern int32_t glue_enc_x86_movl_edx_to_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off);
extern int32_t glue_enc_x86_cmpl_ecx_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);
extern int32_t glue_enc_x86_xor_eax_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t glue_enc_x86_imul_ecx_edx_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);
extern int32_t glue_enc_x86_addl_imm_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);
extern int32_t glue_enc_x86_xorl_ecx_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t glue_enc_x86_incl_edx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t glue_enc_x86_cmpl_edx_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);
extern int32_t glue_emit_lcg_xor_body_x86_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t c1, int32_t c2);
extern int32_t glue_enc_x86_imul_eax_ecx_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);
extern int32_t glue_enc_x86_xor_ecx_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t glue_enc_x86_xor_edx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t glue_enc_x86_movl_ecx_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t glue_enc_x86_xorl_eax_edx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t glue_enc_x86_incl_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t glue_enc_x86_xorl_eax_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off);
extern int32_t glue_enc_x86_mov_al_mem_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t glue_enc_x86_movzx_ecx_mem_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t glue_enc_x86_add_ecx_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off);
extern int32_t glue_enc_x86_imul_eax_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);


/* wave1106: glue_expr_var_name_eq_let_idx_c removed — now provided by
 * pipeline_asm_emit_fold_primitives.c #include above (moved from here). */

/* wave1069 G.7: glue_body_expr_stmt_at_c migrated to
 * pipeline_asm_emit_assign.c EOF (fold/affine pattern detection). Static
 * same-TU: asm_emit_assign.c #include L2294 < def L6604 < callsite L6657.
 * Deps: ast_ast_block_stmt_order_kind / ast_ast_block_stmt_order_idx /
 * ast_pipeline_block_expr_stmt_ref (all extern). */

/* wave1107-1110 G.7: count_up_while loop folding domain (17 fns)
 * migrated to pipeline_asm_emit_fold_count_up_while.c (same-TU #include).
 * Members: glue_match_struct_pair_n2_body_pattern_c /
 *   glue_try_fold_struct_pair_n2_while_elf_c / glue_try_fold_u8_fill_index_while_elf_c /
 *   glue_try_fold_u8_sum_index_while_elf_c / glue_mem_copy_fold_final_sum_i32 /
 *   glue_match_u8_fill_index_while_pattern_c / glue_match_u8_sum_index_while_pattern_c /
 *   glue_match_u8_fill_index_while_c / glue_match_u8_sum_index_while_c /
 *   glue_try_fold_mem_copy_outer_while_elf_c / glue_try_fold_lcg_xor_while_elf_c /
 *   glue_fold_expr_is_func_param0_c / glue_fold_func_x_plus_k_chain_c /
 *   glue_fold_affine_i_plus_k_expr_c / glue_fold_is_assign_s_plus_affine_i_c /
 *   glue_fold_parse_affine_sum_body_c / backend_try_fold_count_up_while_elf.
 * Deps: fold primitives (wave136 pure leave faces) +
 *   x86 encoders (wave135 pure leave faces) +
 *   glue_asm_local_var_stack_off_scoped (runtime_pipeline_abi pure wave148) +
 *   glue_enc_local_slot_ptr_or_addr_rbx_elf_c (pipeline_asm_emit_index_helpers.c) +
 *   pipeline_asm_emit_next_label_c / glue_asm_ctx_set_scope_block (pipeline_glue.c) +
 *   glue_body_expr_stmt_at_c / glue_field_assign_pair_base_ref_c (pipeline_asm_emit_assign.c).
 * Same-TU: wave136 fold_primitives pure externs + wave135 x86 pure externs < this #include
 *   < backend_emit_while_loop_elf_sync def. Forward decl at ~L1605 remains.
 * PLATFORM: SHARED. */
#include "pipeline_asm_emit_fold_count_up_while.c"

/* wave1199 G.7: backend_emit_while/for_loop_elf_sync +
 * pipeline_asm_emit_while/for/loop_body_content_elf_c (3 thin wrappers) +
 * pipeline_asm_emit_skip_heavy_or_thin_stub_elf_c (6 fns) migrated to
 * pipeline_asm_emit_fold_count_up_while.c EOF (colocated with count_up_while
 * fold domain). Same-TU #include at L3395. All static deps visible:
 * spill.c L1533 (glue_loop_break_exit_push/pop + glue_asm_cache_invalidate_
 * at_cfg_merge_selective + glue_asm_loop_phi_invalidate_carried_defs +
 * glue_asm_loop_merge_live_union + glue_live_fwd_apply_expr_effect);
 * unary.c L1319 (glue_enc_jz_after_bool_in_eax); array_lit.c L1551 +
 * expr_rec.c L1689 (pipeline_asm_emit_expr_elf_rec static def);
 * glue_try_fold_* / backend_try_fold_count_up_while_elf in THIS file above;
 * pipeline_asm_ctx_layout static at glue.c L86.
 * Fwd decls retained: backend_emit_* at L999-1006 (before block_body.c
 * #include at L2427); pipeline_asm_emit_next_label_c extern at L835;
 * backend_ensure_block_local_slots extern at L837.
 * Sole caller of skip_heavy_or_thin_stub: mega_body at L3830 (after this
 * file's #include at L3395 — visible). PLATFORM: SHARED. */


/* wave1176: pipeline_asm_get_return_lit_ref_at migrated to
 * runtime_pipeline_abi pure (wave144 leave) (colocated with backend return-expr cluster). */

/* wave1177 G.7: arch_arm64 module_func + return_lit forwarders (5 fns)
 * migrated to ast_pool_module_func.c EOF (4 module_func forwarders) +
 * runtime_pipeline_abi pure (wave144 leave) (arch_arm64_pipeline_asm_get_return_lit_ref_at
 * already migrated in wave1176 block). The 4 module_func forwarders are
 * colocated with the asm_module_func forwarder family (wave1175).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1196 G.7: ast_expr_layout_prime_call_resolved + ast_ast_arena_init
 * + ast_ast_arena_type/expr/block/func_alloc (6 fns) migrated to
 * ast_pool_arena.c EOF (same-TU #include via ast_pool.c L886, which
 * is before this point). ast_pool.c L1278 calls ast_ast_arena_init
 * after L886 #include — definition visible. pipeline_parse_orch.c
 * L88 has extern fwd decl for L380 callsite.
 * PLATFORM: SHARED. */

/** ast_pool.c 内 pipeline_elf_ctx_resolve_patches 需前置声明（standalone TU 由 pipeline_glue_types.inc 提供）。 */
#ifndef XLANG_PIPELINE_GLUE_STANDALONE_TU
void driver_diagnostic_asm_elf_unresolved_patch(const uint8_t *name, int32_t name_len);
#endif
struct platform_elf_ElfCodegenCtx;
void pipeline_elf_log_unresolved_patch(struct platform_elf_ElfCodegenCtx *ctx, int32_t patch_idx);

/* wave1282 G.7: pipeline_asm_glue_emit_module_ref migrated to
 * pipeline_asm_emit_context.c (alias of pipeline_asm_emit_module_ref_c —
 * same g_pipeline_asm_emit_module static). PLATFORM: SHARED. */

extern int32_t typeck_x_type_size_from_layout_glue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t li, int32_t depth);
extern int32_t typeck_x_type_align_from_layout_glue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                     int32_t li, int32_t depth);

/* wave1104 G.7: WPO-S2 mono thunk domain was pipeline_asm_emit_wpo_mono.c
 * (same-TU #include). wave130 pure-owned leave: live =
 * runtime_pipeline_abi pure (reset/register_n/register + emit_thunks + bag BSS).
 * Cap residual: codegen_wpo_mono_sym_format + backend_enc_*_arch +
 * pipeline_dep_ctx_target_arch + link_abi_getenv. Leaf deleted.
 * PLATFORM: SHARED. */

/* wave1067 G.7: pipeline_asm_ctx_reset_for_func_c migrated to
 * pipeline_asm_emit_block_body.c EOF (per-func ctx reset). Static
 * same-TU: block_body.c #include L3872 < def L8255 < callsite L8342.
 * Deps: pipeline_glue_AsmFuncCtxLayout (struct < L3872);
 * asm_ctx_local_reset (extern). */

/**
 * M8-tail ELF mega 主循环 C 体：打破 seed_mega→backend_asm_codegen_ast_to_elf→pipeline 递归 SIGSEGV。
 * 端口 backend.x asm_codegen_ast_to_elf_seed_mega（2517+）。
 */
/** co-emit dep 导出符号前缀；定义见 backend_call_dispatch.c。 */
extern int32_t glue_asm_build_dep_export_sym_c(const uint8_t *name, int32_t name_len, uint8_t *out, int32_t out_cap);
extern int32_t glue_asm_build_func_export_sym_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t func_ix,
                                                uint8_t *out, int32_t out_cap);
extern int32_t pipeline_typeck_pick_overload_func_index_for_call_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                                  int32_t call_expr_ref);
extern int32_t pipeline_typeck_resolve_call_func_index_for_emit_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                                  int32_t call_expr_ref);

/* wave1238 G.7: pipeline_backend_asm_codegen_ast_to_elf_mega_body_c migrated
 * to pipeline_asm_codegen_mega_body.c (same-TU #include at this site). Sole
 * caller: ast_pool.c L1733. All deps visible at this #include point (identical
 * to pre-migration visibility): pipeline_glue_AsmFuncCtxLayout typedef (L84) +
 * pipeline_asm_ctx_layout static (L86) + pipeline_asm_compute_frame_size_c
 * (L811) + g_pipeline_asm_*sret* globals + GLUE_TYPE_KIND_F32/F64_ORD macros +
 * extern decls above (L2403-2409). PLATFORM: SHARED — asm codegen orchestrator. */
#include "pipeline_asm_codegen_mega_body.c"

#include "ast_pool.c"
/* R2 unbundle (2026-07-21): async_asm_pool is a separate product TU
 * (src/async/async_asm_pool.o), not embedded here.
 * Cold: seeds/async_asm_pool.from_x.c full C.
 * PREFER: src/asm/async_asm_pool.x + rest (-DXLANG_ASYNC_ASM_POOL_FROM_X, marker).
 * Call sites use include/async_asm_pool.h (top of this file).
 * PLATFORM: SHARED — link DRIVER_SEED_SUPPORT / g05_relink_env. */
/* #include "seeds/async_asm_pool.from_x.c" — retired; see src/async/async_asm_pool.o */

extern void parser_parse_into_init(struct ast_Module *module, struct ast_ASTArena *arena);
extern struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena *arena, struct ast_Module *module,
                                                            uint8_t *data, int32_t len);
extern int32_t parser_copy_module_import_path64(struct ast_Module *module, int32_t idx, uint8_t out[128]);
extern int32_t preprocess_x_buf(uint8_t *source_buf, ptrdiff_t source_len, uint8_t *out_buf,
                                             int32_t out_cap);
extern uint8_t *driver_dep_arena_buf(int32_t i);
extern uint8_t *driver_dep_module_buf(int32_t i);

/* wave1186 G.7: pipeline parse/load/typeck orchestration cluster (24 fns)
 * migrated to pipeline_parse_orch.c (same-TU #include). Members:
 * pipeline_parse_into_buf_impl_c / _c
 * pipeline_load_import_from_disk_impl_c / _c
 * pipeline_sync_dep_slots_from_driver_impl_c / _c
 * pipeline_parse_into_with_init_buf_impl_c / _c
 * pipeline_parse_into_buf / pipeline_load_import_from_disk /
 * pipeline_sync_dep_slots_from_driver / pipeline_resolve_path_x /
 * pipeline_read_file_x / pipeline_parse_into_with_init_buf (XLANG_WEAK standalone)
 * pipeline_lsp_diag_parse_typeck_buf_impl_c / _c
 * pipeline_lsp_diag_parse_entry_buf_impl_c
 * pipeline_parse_into_with_init_c
 * pipeline_typeck_after_parse_ok_impl_c / _c
 * pipeline_typeck_after_parse_ok_buf_impl_c
 * pipeline_typeck_x_stack_escape_gate_from_src_c
 * pipeline_lsp_diag_parse_typeck_buf / pipeline_typeck_after_parse_ok (XLANG_WEAK standalone)
 * No static state; all extern deps. PLATFORM: SHARED. */
#include "pipeline_parse_orch.c"


extern int32_t backend_emit_expr_call(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out, int32_t expr_ref,
                                      struct ast_Expr e, struct backend_AsmFuncCtx *ctx, int32_t target_arch);
extern int32_t backend_emit_expr_method_call(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                             int32_t expr_ref, struct ast_Expr e, struct backend_AsmFuncCtx *ctx,
                                             int32_t target_arch);

/* wave1205 G.7: pipeline_asm_emit_expr_call_c + pipeline_asm_emit_expr_method_call_c
 * (2 fns, 20 lines) migrated to pipeline_asm_emit_call_args.c EOF (colocated with
 * call-arg emit domain; #include at L1660). Both are thin M8-tail wrappers that
 * pool-copy ast_Expr then delegate to seed partial backend_emit_expr{,_method}_call.
 * No TU-internal callsites — sole callers are seeds (backend.x L1610/L1626) via
 * extern + ast_pool.c symbol table L9812/L9813. Extern fwd decls above are now
 * redundant (migrated defs in call_args.c have their own fwd decls at L64-72);
 * retained here for documentation — may be removed in a later cleanup pass.
 * PLATFORM: SHARED — pure delegation, no arch branch. */

/* wave1118-1123 G.7: skipped-typeck array-lit/var type backfill domain (5 fns)
 * migrated to pipeline_asm_emit_block_inits.c EOF (block-init domain; forms
 * a tight interdependent cluster with glue_let_name_matches_var wave1084).
 * Members: glue_fill_array_lit_from_decl / glue_expr_in_scope_block_c /
 * glue_fill_var_types_from_params_for_func /
 * glue_fill_var_types_from_lets_in_block / glue_fill_array_lit_types_in_block.
 * #include at L3689 < all callsites (L8981+ public skipped-typeck path).
 * Zero fwd decls required. PLATFORM: SHARED. */

/* wave1229 G.7: pipeline_fill_array_lit_types_for_skipped_typeck migrated to
 * pipeline_asm_emit_block_inits.c (after glue_fill_array_lit_types_in_block —
 * sole callee; same skipped-typeck array-lit domain as wave1118-1123).
 * #include at L2072 < former def site; definition visible to all later
 * same-TU callsites and to cross-TU via extern (ast_pool / pipeline_abi).
 * No glue.c body retained. PLATFORM: SHARED. */

/* wave1181 G.7: elf/codegen prefix forwarder cluster (18 fns) migrated to
 * pipeline_elf_codegen_forwarders.c (new domain file, same-TU #include below).
 * Members:
 *  - platform_elf_pipeline_elf_ctx_reloc_* (7 fns: sym_name_ptr/copy64/name_len,
 *    sidecar_reset, offset_at/set, shndx_at) — ElfCodegenCtx reloc accessors
 *  - platform_elf_pipeline_elf_ctx_sym_shndx_at (1 fn) — symtab shndx accessor
 *  - platform_elf_pipeline_elf_pgo_hot_enabled / elf_ctx_set_emit_hot (2 fns) — PGO hot/cold tag
 *  - platform_elf_pipeline_elf_ctx_append_bytes (1 fn) — raw byte stream into ctx
 *  - platform_elf_pipeline_elf_write_o_pgo_to_buf (1 fn) — flush ctx to CodegenOutBuf
 *  - codegen_codegen_out_buf_len / set_len (2 fns) — codegen_ prefix out_buf accessors
 *  - pipeline_codegen_out_buf_len / set_len (2 fns) — pipeline_ prefix aliases
 *  - codegen_pipeline_scratch_buf64 / _slot (2 fns) — codegen_ prefix scratch accessors
 *
 * All 18 are pure pass-through forwarders to unprefixed pipeline_elf_* /
 * codegen_out_buf_* / pipeline_scratch_buf64* implementations in ast_pool.c /
 * pipeline_elf.c / codegen.c. No static state; safe to colocate.
 */
#include "pipeline_elf_codegen_forwarders.c"
/* wave1182 G.7: ast_pipeline forwarder cluster (246 fns) migrated to
 * pipeline_ast_forwarders.c (new domain file, same-TU #include below).
 *
 * Members (246 ast_pipeline forwarders + 1 utility + 1 ast_ast_pool forwarder):
 *  - ast_pipeline_module_func_ (alloc_slot/ref_set/return_type/body_ref/is_extern/
 *    is_async/num_params/num_generic_params/name_equal/name_byte/body_expr_ref)
 *  - ast_pipeline_dep_ctx_ (reset/ndep/module_at/arena_at/set_X/codegen_prefix_X/
 *    current_X/entry_already_parsed/asm_entry_module_only/check_only_mode/
 *    use_asm_backend/entry_dir_byte_at/import_path/set_path_buf_byte/loaded_buf/
 *    ensure_source_buffers/free_source_buffers/heap_destroy/path_buf/preprocess_buf)
 *  - ast_pipeline_ctx_lib_root_ (count/len/copy/byte_at)
 *  - ast_pipeline_scratch_buf (64/96/128/256 + slot variants)
 *  - ast_pipeline_codegen_ (type_kind_copy/append/vector_type_copy/call_num_args/
 *    skip_emit/force_param/use_buf_wrapper/io_driver/fixed_fd/lsp_io)
 *  - ast_pipeline_elf_ctx_ (append_patch/append_reloc)
 *  - ast_pipeline_block_ (append_const/let/if/region/unsafe/with_arena/while/for/
 *    expr_stmt/stmt_order/labeled/fill_X/const_X/let_X/if_X/resolve_var_type_ref)
 *  - ast_pipeline_module_ (import_alloc/set_path/set_kind/set_binding_name/
 *    enum_alloc/enum_set_name/struct_layout_X/top_level_let_X)
 *  - ast_pipeline_onefunc_ (num_consts/lets/whiles/fors/const_X/let_X/append_X/
 *    copy_sidecar)
 *  - ast_pipeline_arena_ (type/expr/block/func cap/alloc)
 *  - pipeline_copy_lib_root_to_buf256 (utility: zero-fill + copy lib_root to 256B buf)
 *  - ast_ast_pool_onefunc_reset (forwarder to ast_pool_onefunc_reset)
 *
 * All 246 ast_pipeline functions are pure pass-through forwarders to unprefixed
 * pipeline_ implementations in ast_pool.c. No static state; safe to colocate.
 */
#include "pipeline_ast_forwarders.c"
/* wave1286 G.7: typeck forward-decl / extern shell migrated to
 * pipeline_glue_typeck_fwd.c (same-TU #include). Pure decls only;
 * sits after ast_forwarders and before typeck_assign.
 * PLATFORM: SHARED. */
#include "pipeline_glue_typeck_fwd.c"

#include "pipeline_typeck_assign.c"

/* 8.3.3 host-cc leave (2026-08-05): pipeline_typeck_soa.c + pipeline_typeck_field_access.c
 * removed from this host-cc mega-TU. All SoA / field_access business + former thin
 * pipeline_*_c surfaces live in typeck.x → typeck_x.o. Product callers use
 * typeck_soa_* / typeck_* / typeck_reject_bare_import_const directly (G.7).
 * PLATFORM: SHARED — residual BC host-cc for these two files is gone. */

/* wave1286 G.7: typeck mid forward-decl / extern shell migrated to
 * pipeline_glue_typeck_mid_fwd.c (same-TU #include). Pure decls only;
 * sits after typeck_assign (field_access #include retired) and before region_assign.
 * PLATFORM: SHARED. */
#include "pipeline_glue_typeck_mid_fwd.c"

#include "pipeline_typeck_region_assign.c"


/* wave1214 G.7: pipeline_typeck_check_call_struct_stack_escape_c (67 lines)
 * migrated to pipeline_typeck_region_assign.c EOF (colocated with region/escape
 * assign-site domain; #include at L3678). WPO-S3 CALL path stack escape check.
 * Deps all visible at L3678: pipeline_typeck_resolve_call_func_index_c (static
 * fwd decl L3628), typeck_expr_is_addr_of_block_local_c (static, this file),
 * typeck_type_is_named_struct_c (static, struct_lit.c #include L1435).
 * No TU-internal callsites in glue.c — sole callers are region_assign.c L1009
 * (same file) + check_expr.c L129 (#include L4265 > L3678 — visible).
 * PLATFORM: SHARED — Cap-T001: inside unsafe { } skip (depth>0). */

/* wave1136 G.7: typeck_scan_expr_stack_escape_c migrated to
 * pipeline_typeck_region_assign.c EOF (colocated with WPO-S3 assign/return
 * escape checks). Visible here via #include at L9934. */

/* wave1167 G.7: region scope + scan_module + read_ptr + stamp_let cluster
 * (7 extern fns + 3 statics + TYPECK_REGION_SCOPE_MAX macro) migrated to
 * pipeline_typeck_region_assign.c EOF. Colocated with region_assign domain
 * — all region scope push/pop/len/stamp and module-level stack-escape scan
 * belong with typeck_scan_block_stack_escape_c (wave1137).
 *
 * Statics (g_typeck_region_saved_len / saved_label / scope_n) now in
 * region_assign.c alongside g_typeck_with_arena_scope_n (L307).
 *
 * Forward decls:
 * - pipeline_typeck_scan_module_struct_stack_escape_c: fwd decl at L5610
 *   (before callsites L5645/5656/5703 < region_assign.c #include L8417)
 * - pipeline_dep_ctx_scope_region_push_c / _pop_c / _len_at: fwd decls in
 *   region_assign.c L327-329 (before callsites L409/416/1112/1121/1128)
 * - pipeline_typeck_is_read_ptr_slice_callee_c /
 *   pipeline_typeck_read_ptr_slice_return_ref_c / pipeline_type_stamp_block_let_region_c:
 *   extern, called from seed (typeck_gen.linux.x86_64.c) not from glue.c TU;
 *   no fwd decl needed in glue.c.
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1089 G.7: pipeline_module_func_overload_count_c migrated to
 * pipeline_typeck_method_call.c EOF (overload gating sub-domain of method call
 * resolution). Static (non-extern): same-TU — static fwd decl at glue.c:12315
 * (before all callsites L13176+) < method_call.c #include at L14053 < def EOF.
 * Deps: pipeline_asm_module_func_is_extern_at / pipeline_module_func_name_equal_at
 * (both extern). PLATFORM: SHARED. */
static int32_t pipeline_module_func_overload_count_c(struct ast_Module *m, uint8_t *name, int32_t name_len);

/* wave1090-1094 G.7: overload resolution domain (call_arg_assignable + match_score
 * + expect_match + pick_overload + resolve_call_func_index) migrated to
 * pipeline_typeck_method_call.c EOF (overload dispatch sub-domain of method call).
 * Static (non-extern): same-TU — fwd decls below (before all callsites L12695+,
 * L13233+ wrappers, L13360+, L13743+) < method_call.c #include at L14053 < def EOF.
 * resolve_call_func_index_c also has static fwd decl at glue.c:12315 (before
 * callsite L12695). Deps: pipeline_expr_kind_ord_at / pipeline_typeck_expr_type_ref_c
 * / pipeline_expr_as_target_type_ref_at / pipeline_type_kind_ord_at /
 * pipeline_typeck_type_refs_equal_c / pipeline_typeck_integer_widen_ok_refs_c
 * (static, fwd decl at glue.c:10381) / pipeline_typeck_float_widen_ok_c (static,
 * fwd decl at glue.c:10354) / pipeline_type_elem_ref_at / pipeline_expr_int_val_at
 * / pipeline_expr_call_num_args_at / pipeline_module_func_num_params_at /
 * pipeline_expr_call_arg_ref / pipeline_module_func_param_type_ref_at /
 * pipeline_module_func_return_type_at / typeck_overload_expected_ret_peek
 * (extern, declared in-function-body) / pipeline_expr_call_callee_ref_at /
 * pipeline_arena_expr_ptr / pipeline_asm_module_func_is_extern_at /
 * pipeline_module_func_name_equal_at / pipeline_expr_apply_call_resolve /
 * pipeline_expr_call_resolved_func_index_at (all extern unless noted).
 * PLATFORM: SHARED. */
static int32_t pipeline_typeck_call_arg_assignable_c(struct ast_ASTArena *arena, int32_t arg_ref, int32_t param_ref);
static int32_t pipeline_typeck_overload_match_score_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t func_ix,
                                                      int32_t call_expr_ref);
static int32_t pipeline_typeck_overload_expect_match_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                       int32_t func_ix);
static int32_t pipeline_typeck_pick_overload_func_index_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                          int32_t call_expr_ref);

/* wave1170 G.7: overload wrapper cluster (2 extern fns:
 * pipeline_typeck_resolve_call_func_index_for_emit_c /
 * pipeline_typeck_pick_overload_func_index_for_call_c) migrated to
 * pipeline_typeck_method_call.c EOF. Colocated with static overload resolvers
 * (pipeline_typeck_resolve_call_func_index_c / _pick_overload_func_index_c,
 * wave1090-1094, same file).
 * Extern fwd decls at L5081/5083 cover ast_pool.c:11607 callsite.
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1150 G.7: glue_asm_resolve_call_target_module_c migrated to
 * pipeline_asm_emit_call_args.c EOF (CALL-target module/func_index resolver;
 * colocated with call-arg packing domain — every call-arg emitter calls this
 * resolver to get mod/func_ix/dep_ix before packing args).
 *
 * Visibility: static fwd decl at pipeline_asm_emit_struct_let.c:78 (struct_let.c
 * #include at L2120 < call_args.c #include at L2251) provides TU-wide visibility
 * for callers in call_args.c body that precede the EOF definition.
 *
 * GLUE_TYPECK_IMPORT_BINDING/SELECT enum moved before call_args.c #include at
 * L2241 so the migrated function can see the enum constants.
 *
 * Deps (fwd decls added at call_args.c EOF before the definition):
 *   - g_pipeline_asm_emit_module / g_pipeline_asm_emit_dep_pipe (same-TU globals)
 *   - pipeline_typeck_resolve_call_func_index_c (static; method_call.c #include
 *     at L10491 > call_args.c #include at L2251; static fwd decl in call_args.c)
 *   - pipeline_typeck_find_func_return_type_in_module_c (extern; def at L8926 >
 *     L2251; extern fwd decl in call_args.c)
 *   - parser_get_module_num_imports (extern; extern fwd decl in call_args.c)
 *   - pipeline_expr_* / pipeline_dep_ctx_* / pipeline_module_import_* (extern)
 * PLATFORM: SHARED. */

/* wave1060 G.7: pipeline_asm_deref_struct16_rax_ptr_elf_c migrated to
 * pipeline_asm_emit_call_args.c EOF (struct16 retval deref domain).
 * Extern prototype at L1493 < call_args.c #include L2395 visible.
 * struct_let.c:75 #define alias retained (glue_ name -> pipeline_asm_).
 * Dependencies: backend_enc_*_arch (global extern). */

/* wave1061 G.7: pipeline_asm_call_struct16_ret_needs_rax_deref_c migrated to
 * pipeline_asm_emit_call_args.c EOF (struct16 retval deref classifier domain,
 * twin of wave1060 deref action). Extern prototype at L791 < call_args.c
 * #include L2395 visible to all callsites. struct_let.c:77 #define alias
 * retained (glue_ name -> pipeline_asm_). Dependencies: glue_asm_resolve_
 * call_target_module_c (static fwd decl struct_let.c:78, def still in this
 * file at L13555); pipeline_module_func_* / pipeline_typeck_* / glue_type_*
 * (same-TU / extern). */

/* wave1063 G.7: pipeline_asm_call_param_type_ref_at_c migrated to
 * pipeline_asm_emit_call_args.c EOF (call param type_ref resolve domain,
 * twin of wave1062 call_return_type_kind_ord). Extern (non-static): seed
 * extern C link (backend_call_dispatch.x:19 / backend_call_dispatch_thin.x:104);
 * struct_let.c:98 comment references it (via #include L2269 < call_args.c
 * L2395). Dependencies: glue_asm_resolve_call_target_module_c (static fwd
 * decl struct_let.c:78, def still at L13555); pipeline_module_func_param_
 * type_ref_at (extern L261); pipeline_typeck_get_dep_return_type_in_caller_
 * arena_c (extern L788); pipeline_dep_ctx_arena_at (extern decl wave1062 in
 * call_args.c); pipeline_dep_ctx_ndep / pipeline_dep_ctx_module_at /
 * pipeline_get_dep_arena_slot / pipeline_typeck_dep_return_type_to_caller_
 * arena_c (extern decls wave1063 in call_args.c; defs at L11661/11663/
 * 11664/11846 > #include L2395); g_pipeline_asm_emit_module /
 * g_pipeline_asm_emit_dep_pipe (globals). */

/* wave1062 G.7: pipeline_asm_call_return_type_kind_ord_c migrated to
 * pipeline_asm_emit_call_args.c EOF (call return TypeKind resolve domain,
 * twin of wave1061 struct16 deref classifier). Extern prototype at
 * struct_let.c:99 (via #include L2269 < call_args.c L2395) visible to all
 * callsites. Dependencies: glue_asm_resolve_call_target_module_c (static
 * fwd decl struct_let.c:78, def still at L13555);
 * pipeline_dep_ctx_arena_at extern decl added in call_args.c (def at
 * L11662 > #include L2395); rest < L2395 / extern / global. */

/* wave1114 G.7: typeck_layout_index_for_named_type_c migrated to
 * pipeline_asm_emit_struct_lit.c EOF (struct layout registry index lookup,
 * co-located with typeck_type_is_named_struct_c wave1113). Static
 * (non-extern): same-TU — struct_lit.c #include at L2051 < callsites
 * (L11213+). PLATFORM: SHARED. */

/* wave1124 G.7: typeck_struct_layouts_same_shape_c migrated to
 * pipeline_asm_emit_struct_lit.c EOF (MOD-02 same-shape comparator for
 * repr(compatible) ptr coerce; co-located with struct layout registry).
 * Static (non-extern): same-TU — struct_lit.c #include at L2051 < callsite
 * (inside pipeline_typeck_call_arg_repr_compatible_ok_c). PLATFORM: SHARED. */

/* wave1198 G.7: pipeline_typeck_call_arg_repr_compatible_ok_c migrated to
 * pipeline_typeck_check_expr.c EOF (same-TU #include at L5444, after
 * struct_lit.c L1438 + vector_simd.c L1509 + ast_pool.c L3985 — all
 * same-TU static deps visible). Extern fwd decl added in
 * pipeline_typeck_method_call.c L435 for L2734 callsite in
 * typeck_check_call_ptr_struct_compat_c (method_call.c #include at L5307
 * < check_expr.c #include at L5444). Sole callers: typeck_check_call_ptr_
 * struct_compat_c (method_call.c) + typeck.x typeck_check_expr_call +
 * typeck_gen seed. PLATFORM: SHARED. */

/* wave1233 G.7: pipeline_typeck_check_call_slice_region_c + 2 fwd decls
 * (typeck_check_call_ptr_struct_compat_c static + check_extern_call_unsafe_boundary_c
 * extern) migrated to pipeline_typeck_region_assign.c EOF (M-3 slice region domain,
 * colocated with pipeline_typeck_check_slice_region_assign_c). Sole extern caller:
 * typeck.x typeck_check_expr_call + typeck_gen seed. PLATFORM: SHARED. */

/* wave1234 G.7: pipeline_typeck_check_block_one_region_c migrated to
 * pipeline_typeck_region_assign.c EOF (colocated with with_arena scope +
 * region scope push/pop — M-3 / MEM-C1 region dispatch domain).
 * Deps visible via earlier fwd decls: pipeline_block_region_* (ast_pool.c
 * #include L2839) + unsafe_depth_push/pop (fwd at L3238-3239) +
 * typeck_with_arena_scope_push/pop + pipeline_dep_ctx_scope_region_push/pop
 * (both in region_assign.c). Redundant unsafe_depth fwd decls (were L3750-3751)
 * dropped — L3238-3239 already covers all callsites.
 * Sole extern caller: typeck_gen.c L9100 + typeck.x seed. PLATFORM: SHARED. */

/* typeck coerce-init domain (lit/float/enum/call/array/vector/struct/slice):
 * pipeline_typeck_coerce_init.c */
#include "pipeline_typeck_coerce_init.c"

/** 前向声明：check_expr_impl C 委托内递归 check 子表达式。 */
int32_t pipeline_typeck_check_expr_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                     int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
int32_t pipeline_typeck_check_block_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                      int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);

/* wave1065 G.7: pipeline_typeck_expr_is_any_assign_kind_c migrated to
 * pipeline_typeck_coerce_init.c EOF (assign-kind classifier, consumed by
 * check_block_one_region). Static same-TU: coerce_init.c #include L14126 <
 * def L14135 < sole callsite L15308. Deps: ast_ExprKind_* enum (global). */

/** typeck.o / typeck_x_no_layout 子 helper；kind 分派经 pipeline_typeck_check_expr_impl_mega_c 调用。 */
extern int32_t typeck_check_expr_try_propagate(struct ast_Module *module, struct ast_ASTArena *arena,
                                               int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);

/* wave1147 G.7: debug_try_propagate_report_glue_c migrated to
 * pipeline_typeck_method_call.c EOF (debug-point D try-propagate
 * reporter; colocated with call dispatch / overload resolution domain).
 * Static fwd decl below — sole caller pipeline_typeck_check_expr_
 * try_propagate_c at L10419 is BEFORE method_call.c #include at L10525;
 * definition at method_call.c EOF (after #include). Deps: link_abi_getenv
 * / link_abi_system (extern) + libc fopen/fgets/fclose/snprintf/strncmp/
 * strcspn. PLATFORM: SHARED. */
// #region debug-point D:try-propagate-strong-state
/* wave1190 G.7: debug_try_propagate_report_glue_c static fwd decl removed —
 * sole caller pipeline_typeck_check_expr_try_propagate_c migrated to
 * pipeline_typeck_check_expr.c EOF (after method_call.c #include, so the
 * definition in method_call.c EOF wave1147 is directly visible).
 * PLATFORM: SHARED. */
// #endregion

/* wave1190 G.7: pipeline_typeck_check_expr_try_propagate_c +
 * typeck_check_expr_try_propagate wrapper migrated to
 * pipeline_typeck_check_expr.c EOF (colocated with wave1188 entry/dispatch
 * domain + wave1189 sub-class cluster). debug_try_propagate_report_glue_c
 * (static, wave1147 in method_call.c EOF) visible at check_expr.c #include
 * point (after method_call.c #include). PLATFORM: SHARED. */

/* wave1215 G.7: pipeline_codegen_emit_expr_try_propagate_c (21 lines)
 * migrated to pipeline_codegen_outbuf.c EOF (colocated with C-backend codegen
 * outbuf append domain; #include at L445). ERR-01 GNU stmt expr desugar for
 * `expr?` operator.
 * Deps:
 *  - pipeline_expr_unary_operand_ref_at (extern fwd decl at codegen_outbuf.c
 *    L122; original glue.c fwd decl at L1050 is after L445 — redeclared in
 *    target file to keep visibility)
 *  - codegen_emit_expr / codegen_emit_bytes_from_ptr (extern, in-function-body
 *    declarations preserved verbatim from original)
 * No TU-internal callsites in glue.c — sole callers are seeds
 * (codegen.x / runtime_pipeline_abi.x) via extern.
 * PLATFORM: SHARED — C codegen path, no arch branch. */

/* typeck method_call + generic UFCS mono domain (BC 8.3.1):
 * pipeline_typeck_method_call.c */
#include "pipeline_typeck_method_call.c"

/* wave1096 G.7: glue_generic_call_fixup_resolved_type_c migrated to
 * pipeline_typeck_method_call.c EOF. Static (non-extern): same-TU —
 * method_call.c #include at L13803 < def EOF < callsites L14181 + L14757.
 * PLATFORM: SHARED. */

/* wave1148 G.7: pipeline_typeck_bootstrap_expr_fixup_c migrated to
 * pipeline_typeck_method_call.c EOF (bootstrap typeck post-processing
 * expr fixup; colocated with glue_generic_call_fixup_resolved_type_c
 * wave1096 + call dispatch / overload resolution domain). Static fwd
 * decl at L8131 (before sole caller pipeline_typeck_check_expr_return_c
 * at L8191, before method_call.c #include at L10499). Deps:
 * pipeline_expr_kind_ord_at / pipeline_expr_resolved_type_ref /
 * pipeline_expr_method_call_* / pipeline_expr_set_resolved_type_ref /
 * pipeline_type_kind_ord_at / pipeline_type_ensure_by_kind_ord (all extern)
 * + glue_generic_call_fixup_resolved_type_c (static, same file). PLATFORM: SHARED. */

/**
 * EXPR_CALL：委托 typeck_x.o 后做泛型返回类型单态化 fixup（bootstrap parser 未存 call type_args）。
 * LANG-007 v2：S0 内 extern 调用须位于 unsafe { } 块内。
 */
extern void driver_diagnostic_typeck_extern_call_outside_unsafe(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_call_not_generic(int32_t line, int32_t col, const uint8_t *name, int32_t name_len);
extern void driver_diagnostic_typeck_call_wrong_num_type_args(int32_t line, int32_t col, const uint8_t *name,
                                                              int32_t name_len, int32_t expect_n, int32_t got_n);
extern void driver_diagnostic_typeck_call_requires_type_args(int32_t line, int32_t col, const uint8_t *name,
                                                             int32_t name_len);
extern int32_t pipeline_module_func_num_generic_params_at(struct ast_Module *m, int32_t func_index);
extern int32_t pipeline_expr_call_num_type_args_at(struct ast_ASTArena *a, int32_t expr_ref);

/* wave1198 G.7: pipeline_typeck_check_extern_call_unsafe_boundary_c migrated
 * to pipeline_typeck_check_expr.c EOF (same-TU #include at L5444, after
 * vector_simd.c L1509 where glue_module_func_index_by_name_c static def at
 * L856 is visible). Fwd decl at L5021 retained (before L5044 callsite in
 * pipeline_typeck_check_call_slice_region_c which stays in glue.c —
 * dual-authority seed file). Static fwd decl of glue_module_func_index_by_
 * name_c removed (no remaining callers in glue.c body). Sole callers:
 * check_call_slice_region_c (glue.c) + typeck.x typeck_check_expr_call +
 * typeck_gen seed. PLATFORM: SHARED. */

/* wave1095 G.7: pipeline_typeck_named_is_module_type_c migrated to
 * pipeline_typeck_method_call.c EOF. Static fwd decl at method_call.c:348
 * (before callsites L476-L872) < method_call.c #include at L13803 < def EOF.
 * PLATFORM: SHARED. */

/* wave1097 G.7: pipeline_typeck_try_infer_generic_call_from_args_c migrated to
 * pipeline_typeck_method_call.c EOF. Static (non-extern): same-TU —
 * method_call.c #include at L13803 < def EOF < callsite inside
 * check_call_generic_type_args_c (same migration batch). PLATFORM: SHARED. */

/* wave1098 G.7: pipeline_typeck_check_inferred_generic_bounds_c migrated to
 * pipeline_typeck_method_call.c EOF. Static (non-extern): same-TU —
 * method_call.c #include at L13803 < def EOF < callsite inside
 * check_call_generic_type_args_c (same migration batch). PLATFORM: SHARED. */

/* wave1099 G.7: pipeline_typeck_check_call_generic_type_args_c migrated to
 * pipeline_typeck_method_call.c EOF. Static (non-extern): same-TU —
 * method_call.c #include at L13803 < def EOF < callsite L14743
 * (inside pipeline_typeck_check_expr_call_c). PLATFORM: SHARED. */

/* wave1190 G.7: pipeline_typeck_check_expr_call_c migrated to
 * pipeline_typeck_check_expr.c EOF (colocated with wave1188 entry/dispatch
 * domain + wave1189 sub-class cluster + try_propagate_c). Static helpers
 * glue_generic_call_fixup_resolved_type_c (wave1096) +
 * pipeline_typeck_check_call_generic_type_args_c (wave1099) visible at
 * check_expr.c #include point (method_call.c #include before check_expr.c).
 * pipeline_typeck_check_extern_call_unsafe_boundary_c (extern, defined above
 * at L6010) visible via fwd decl. typeck_check_expr_call wrapper below stays
 * (calls call_c via fwd decl at L4777). PLATFORM: SHARED. */

/* wave1282 G.7: typeck_check_expr_{call,deref,method_call} wrappers migrated
 * to pipeline_typeck_check_expr.c EOF. PLATFORM: SHARED. */

/* wave1188 G.7: typeck check_expr entry/dispatch cluster (5 fns + 2 XLANG_WEAK)
 * migrated to pipeline_typeck_check_expr.c (same-TU #include). Members:
 * pipeline_typeck_check_expr_impl_mega_c (full ExprKind dispatch)
 * + XLANG_WEAK check_expr_impl_mega (glue-only fallback; typeck_x.o overrides)
 * + pipeline_typeck_check_expr_impl_c (simple kind C path + mega fallback)
 * + XLANG_WEAK check_expr_impl (glue-only fallback; typeck.o EMIT_HEAVY overrides)
 * + pipeline_typeck_check_expr_c (boundary check → try_propagate / impl_c)
 * All extern (non-static): cross-TU calls (typeck_x.o / typeck.o / seeds).
 * XLANG_WEAK definitions retained for product pure strong-symbol override.
 * Sub-class helpers (panic/match/return/unary/addr_of/deref/index/var) remain
 * in pipeline_glue.c (interleaved with assign/soa/field_access domain slices).
 * call_c + try_propagate_c remain in pipeline_glue.c (before method_call.c
 * #include for debug_try_propagate_report_glue_c + glue_module_func_index_by_name_c).
 * PLATFORM: SHARED. */
#include "pipeline_typeck_check_expr.c"

/* typeck check_block orchestration domain (BC 8.3.1):
 * pipeline_typeck_check_block.c */
#include "pipeline_typeck_check_block.c"

extern int32_t check_block(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                           int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);

/* wave1187 G.7: typeck orchestration cluster (10 fns + 2 statics + 3 XLANG_WEAK)
 * migrated to pipeline_typeck_orch.c (same-TU #include). Members:
 * pipeline_typeck_x_ast_check_one_func_c / pipeline_typeck_x_ast_impl_c /
 * pipeline_typeck_x_ast_library_c / pipeline_typeck_x_ast_c
 * + g_pipeline_typeck_diag_soft_suppress static + diag_soft_suppress_set/get (XLANG_WEAK)
 * + g_pipeline_typeck_dep_ctx_cold static + set_dep_ctx/get_dep_ctx (XLANG_WEAK)
 * + pipeline_typeck_dep_prerun_module_c (XLANG_WEAK)
 * + typeck_validate_struct_layouts_zero_padding_glue
 * + typeck_x_type_size_from_layout_glue / typeck_x_type_align_from_layout_glue
 * Also: codegen_/backend_pipeline_expr_struct_lit_field_offset_at/_store_sz (4 fns)
 *   migrated to pipeline_asm_emit_expr_rec.c EOF (same-TU #include at L1914).
 * All extern (non-static): cross-TU calls (driver.x / lsp.x / runtime_pipeline_abi.x / seeds).
 * XLANG_WEAK definitions retained for product pure strong-symbol override.
 * PLATFORM: SHARED. */
#include "pipeline_typeck_orch.c"

/* wave1183 G.7: ast_ast_block_* control flow + ast_ast_expr_* apply cluster
 * (11 fns) migrated to ast_pool_block.c EOF (same-TU #include already exists).
 * Members: while/for/if cond/body/init/step/then/else ref + resolve_var_to_type_ref
 * + disallows_implicit_tail + apply_call_resolve.
 * All pure forwarders to pipeline_block_ / pipeline_expr_ / implicit_tail_ impls. */

/* wave1183 G.7: ast_pipeline_arena_* forwarder cluster (12 fns) migrated
 * to ast_pool_arena.c EOF (same-TU #include already exists).
 * Members: type/expr/block/func get_copy/set_copy + expr_write_var/binop.
 * All pure forwarders to pipeline_arena_* impls in ast_pool_arena.c. */

/* wave1183 G.7: ast_pipeline_expr_* + codegen_pipeline_expr_* +
 * backend_pipeline_expr_* forwarder cluster (40 fns) migrated to
 * pipeline_asm_emit_expr_rec.c EOF (same-TU #include already exists).
 * Members: call/method_call/match/struct_lit/array_lit/float/if/block/
 * match/const_folded/index/field_access accessors + codegen_/backend_ twins.
 * All pure forwarders to pipeline_expr_ / pipeline_module_ impls. */
/* wave1187 G.7: codegen_/backend_pipeline_expr_struct_lit_field_offset_at /
 * _field_store_sz (4 fns) migrated to pipeline_asm_emit_expr_rec.c EOF. */

/* wave1053 G.7: typeck_typeck_struct_layout_metrics migrated to
 * pipeline_asm_emit_struct_lit.c (definition at EOF). Public symbol —
 * extern-called by ast_pool.c:8151 (same pipeline_x.o symbol, no link
 * change). glue.c:16551/16564/16576 callsites (typeck_validate_* wrappers)
 * see the definition via same-TU #include at glue.c:2095. */
/* wave1187 G.7: typeck_validate_struct_layouts_zero_padding_glue +
 * typeck_x_type_size_from_layout_glue + typeck_x_type_align_from_layout_glue
 * (3 fns) migrated to pipeline_typeck_orch.c (same-TU #include above). */
