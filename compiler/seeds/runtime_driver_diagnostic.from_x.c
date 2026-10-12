/* seeds/runtime_driver_diagnostic.from_x.c — C tail for runtime_driver_diagnostic.o.
 * wave853: the thin public bodies live only in src/runtime_driver_diagnostic_thin.x.
 * This file keeps the asm BSS family (file-scope let store still CG002s in .x)
 * and the declarations the tail calls. Product link pure-asms the thin, then
 * cc's this tail with -DXLANG_L2_RDD_THIN_FROM_X. No gcc -E. No cold full-seed.
 * PLATFORM: SHARED.
 */
#include "runtime_driver_diagnostic.h"
#include "runtime_driver_abi.h"
#include "runtime_diag_codes.h"
#include "lsp/lsp_diag.h"
#include "diag.h"

/* wave228 G.7: env via public pure thin link_abi_getenv. */
extern char *link_abi_getenv(const char *name);
#ifdef XLANG_L2_RDD_THIN_FROM_X
/* pure in thin: copy_bytes/note/fill/build/env_debug_pipe/parse_strict/report_prefixed/pipe_note
 * plus debug_log/parser_diag_xxx/typeck_block/fn/var/scratch +
 * parse_fail/codegen_fail/typeck_func_fail/ptr_field/ret_fail +
 * parse_skip/parse_commit_fail/parse_func_generic/parser_onefunc_param_ref +
 * typeck_import_const/warn_pad/warn_hot/hint_unused +
 * typeck_binop_operands/parse_commit_shape/parser_diagnostic_parse_commit_shape +
 * after_entry_parse_module/codegen_emit_func_fail
 * — rest must not #define those dropped publics.
 * Asm BSS bodies are later in this file and stay defined under FROM_X. */
/* thin supplies pure public for rest residual callers */
int driver_diag_env_debug_pipe(void);
int32_t driver_parse_strict_enabled(void);
int driver_diag_copy_bytes(char *dst, size_t dst_size, const uint8_t *src, int32_t src_len);
void driver_diag_note(const char *msg);
void driver_diag_report_prefixed(int32_t line, int32_t col, const char *msg);
void driver_diag_pipe_note(int32_t kind, int32_t a, int32_t b);
void driver_diag_fill_expr_part(char *dst, int32_t cap, const uint8_t *expr_buf, int32_t expr_len);
void driver_diag_build_expected_found(char *msg, int32_t msg_cap, const char *pref, const char *epart, const char *fpart);
#endif

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <xlang_fmt_cap.h> /* also Cap va via xlang_va_cap (10.7.1) */ /* Cap residual 10.7.2: cold driver_diagnostic → Cap fmt */
/* G.7: single Cap authority for this cold TU (after stdio). Prefer thin.x already avoids libc fmt. */
#undef snprintf
#undef vsnprintf
#define snprintf xlang_snprintf
#define vsnprintf xlang_vsnprintf

/* G-02f-73 diagnostic gates */
/* pure public from thin (no pure-dup _impl): parse_fail / typeck residual / skip / commit_fail /
 * warn / hint / generic / param / import / binop / commit_shape (+ parser alias) */
void driver_diagnostic_parse_fail(int32_t main_idx, int32_t num_funcs, int32_t arena_num_types);
void driver_diagnostic_parse_skip_function(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, const uint8_t *name);
void driver_diagnostic_typeck_func_fail(int32_t func_idx, const uint8_t *name, int32_t name_len, int32_t kind);
void driver_diagnostic_typeck_ptr_field(int32_t bt_kind, int32_t inner_kind, int32_t inner_nlen, int32_t base_resolved_ref, int32_t num_struct_layouts);
void driver_diagnostic_typeck_ret_fail(int32_t stage, int32_t op_expr_ref, int32_t expect_ty_ref, int32_t got_ty_ref);
void driver_diagnostic_typeck_binop_operands(int32_t expr_ref, int32_t left_ref, int32_t right_ref, int32_t left_kind, int32_t right_kind, int32_t left_block_ref, int32_t right_block_ref, int32_t left_ty_ref, int32_t right_ty_ref, const uint8_t *left_ty, int32_t left_ty_len, const uint8_t *right_ty, int32_t right_ty_len);
void driver_diagnostic_parser_onefunc_param_ref(const uint8_t *func_name, int32_t func_name_len, const uint8_t *param_name, int32_t param_name_len, int32_t stage, int32_t param_idx, int32_t type_ref);
void driver_diagnostic_typeck_return_mismatch(int32_t line, int32_t col, const uint8_t *expect_buf, int32_t expect_len, const uint8_t *found_buf, int32_t found_len);
void driver_diagnostic_typeck_return_unresolved(int32_t line, int32_t col, const uint8_t *expr_buf, int32_t expr_len);
void driver_diagnostic_typeck_return_subexpr(int32_t line, int32_t col, const uint8_t *expr_buf, int32_t expr_len);
void driver_diagnostic_typeck_call_not_generic(int32_t line, int32_t col, const uint8_t *name, int32_t name_len);
void driver_diagnostic_typeck_call_wrong_num_type_args(int32_t line, int32_t col, const uint8_t *name, int32_t name_len, int32_t expect_n, int32_t got_n);
void driver_diagnostic_typeck_call_requires_type_args(int32_t line, int32_t col, const uint8_t *name, int32_t name_len);
void driver_diagnostic_typeck_import_const_must_be_qualified(int32_t line, int32_t col, const uint8_t *name, int32_t name_len, const uint8_t *binding, int32_t binding_len);
void driver_diagnostic_typeck_struct_padding_before(const uint8_t *sname, int32_t sname_len, int32_t gap, const uint8_t *fname, int32_t fname_len);
void driver_diagnostic_typeck_struct_padding_trailing(const uint8_t *sname, int32_t sname_len, int32_t gap);
void driver_diagnostic_typeck_struct_field_bad_size(const uint8_t *sname, int32_t sname_len, const uint8_t *fname, int32_t fname_len);
void driver_diagnostic_typeck_assign_mismatch(int32_t is_compound, int32_t line, int32_t col, const uint8_t *expect_buf, int32_t expect_len, const uint8_t *found_buf, int32_t found_len);
void driver_diagnostic_typeck_block_enter(int32_t func_idx, int32_t block_ref, int32_t n_const, int32_t n_let, int32_t n_loop, int32_t n_for, int32_t n_expr, int32_t final_ref);
void driver_diagnostic_typeck_fn_enter(int32_t func_idx, const uint8_t *name, int32_t name_len);
void driver_diagnostic_typeck_var_resolution(int32_t expr_ref, const uint8_t *name, int32_t name_len, int32_t func_idx, int32_t block_ref, int32_t source, int32_t type_ref);

void driver_diagnostic_parse_commit_fail(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, const uint8_t *name);
void driver_diagnostic_parse_func_generic(int32_t byte_pos, int32_t num_funcs_so_far, const uint8_t *name, int32_t name_len, int32_t num_generic_params, int32_t is_main);
void driver_diagnostic_parse_commit_shape(int32_t byte_pos, int32_t num_funcs_so_far, const uint8_t *name, int32_t name_len, int32_t phase, int32_t block_ref, int32_t pool_num_consts, int32_t pool_num_lets, int32_t pool_num_ifs, int32_t pool_num_regions, int32_t pool_num_stmt_order, int32_t block_num_consts, int32_t block_num_lets, int32_t block_num_ifs, int32_t block_num_regions, int32_t block_num_stmt_order, int32_t final_expr_ref);
void parser_diagnostic_parse_commit_shape(int32_t byte_pos, int32_t num_funcs_so_far, const uint8_t *name, int32_t name_len, int32_t phase, int32_t block_ref, int32_t pool_num_consts, int32_t pool_num_lets, int32_t pool_num_ifs, int32_t pool_num_regions, int32_t pool_num_stmt_order, int32_t block_num_consts, int32_t block_num_lets, int32_t block_num_ifs, int32_t block_num_regions, int32_t block_num_stmt_order, int32_t final_expr_ref);
void driver_diagnostic_after_entry_parse_module(void *module);

void driver_diagnostic_codegen_fail(int32_t dep_index, int32_t is_dep);
void driver_diagnostic_codegen_emit_func_fail(void *module, int32_t func_index);
void driver_diagnostic_asm_unsupported_expr(int32_t kind);
void driver_diagnostic_asm_elf_unresolved_patch(const uint8_t *name, int32_t len);
void driver_diagnostic_asm_macho_empty_reloc(int32_t reloc_idx);
void driver_diagnostic_asm_macho_missing_und_reloc(int32_t reloc_idx);
void driver_diagnostic_asm_print_current_func(void);
void driver_diagnostic_asm_var_not_found(const uint8_t *name, int32_t len, int32_t num_locals, const uint8_t *first_slot, int32_t first_len);
void driver_diagnostic_asm_fail_at(int32_t loc);
void driver_debug_log(int32_t step);
void parser_diag_tok_kind(int32_t k);
void parser_diag_ident_len(int32_t len);
void parser_diag_scan_fail(int32_t step);
int parser_is_ident_allow(const uint8_t *ident, int len);
void driver_diagnostic_warn_pad_fields_same_cache_line(const uint8_t *sname, int32_t sname_len, const uint8_t *f0, int32_t f0_len, const uint8_t *f1, int32_t f1_len);
void driver_diagnostic_warn_hot_reorder_field(const uint8_t *sname, int32_t sname_len, const uint8_t *hot, int32_t hot_len, const uint8_t *cold, int32_t cold_len);
void driver_diagnostic_hint_unused_binding(int32_t line, int32_t col, const uint8_t *name, int32_t name_len);

extern int32_t pipeline_module_num_funcs(void *module);
extern int32_t pipeline_module_func_is_extern_at(void *module, int32_t fi);

/* wave6: lsp_diag_get_enabled authority is runtime_lsp_glue / stubs (G.7 with flag).
 * diagnostic no longer defines getter or _impl (cold + FROM_X). */

/* pure 权威：thin.x driver_diag_report_prefixed；冷启动保留全 C 体；FROM_X 无 pure-dup _impl（H↓）。 */


/* wave6: Cap-va report_x is cold-seed only. Under FROM_X, pure thin XP001/XP002 cover
 * the only historical callers; no external UNDEF references. PLATFORM: SHARED cold path. */
/* G-02f-121：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* pure 权威：thin.x driver_diag_copy_bytes；冷启动全 C；FROM_X 无 pure-dup _impl */

/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */




/* pure authority: thin.x driver_diagnostic_parse_fail (append_i32 + XP001);
 * cold keeps C body; FROM_X no pure-dup _impl (H↓). */




/**
 * Non-zero: parse_into_buf hard-fails on soft-skip paths (ok=-2) and skip diags fire.
 * True when XLANG_PARSE_STRICT is truthy OR driver_check_only_get() (xlang check).
 * pure authority: thin.x; cold keeps public body; FROM_X drops pure-dup.
 * PLATFORM: SHARED — 2026-08-05 check false-green root (soft empty module).
 */

/**
 * parse_into_buf 跳过无法解析的 function 时打印诊断（XLANG_DEBUG_PARSE=1 或 XLANG_PARSE_STRICT=1）。
 * byte_pos 为源缓冲字节偏移；name 可为 NULL。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* pure authority: thin.x driver_diagnostic_parse_skip_function; cold keeps C body; FROM_X no pure-dup _impl (H↓). */





/**
 * .x 流水线中 typeck_x_ast / typeck_x_ast_library 失败时打印一行 stderr。
 * 与 C 路径 lsp_diag_report_typeck 在 !lsp_diag_enabled 时的前缀一致，供 run-typeck.sh、check-7.2 等识别（.x typeck 当前不向 stderr 逐条报原因）。
 */

/**
 * .x typeck: label failed function (index + name) and failure kind before typeck_fail line.
 * kind: 5 = check_block failed; -6 = non-void function implicit tail expression.
 * pure authority: thin.x driver_diagnostic_typeck_func_fail (append + XT001);
 * cold keeps C body; FROM_X no pure-dup _impl (H↓).
 */




/** FIELD_ACCESS base type debug; XLANG_TYPECK_PTR=1 enables note.
 * pure authority: thin.x driver_diagnostic_typeck_ptr_field (append+note);
 * cold keeps C body; FROM_X no pure-dup _impl (H↓). */




/** EXPR_RETURN fail debug; XLANG_TYPECK_RET=1 prints refs. stage 1=operand check -1; 2=got vs expect mismatch.
 * pure authority: thin.x driver_diagnostic_typeck_ret_fail (append+note);
 * cold keeps C body; FROM_X no pure-dup _impl (H↓). */


/* pure authority: thin.x driver_diagnostic_typeck_binop_operands; cold keeps C body;
 * FROM_X no pure-dup _impl (H↓ / rest T↓). */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */


/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */


/* pure authority: thin.x driver_diagnostic_parser_onefunc_param_ref; cold keeps C body; FROM_X no pure-dup _impl (H↓). */





/** .x typeck：`return expr` 表达式类型与函数返回类型不符；行文与 assignment type mismatch 对齐。 */
/* G-02f-176：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* pure 权威：thin.x driver_diagnostic_typeck_return_mismatch；冷启动全 C；FROM_X 无 pure-dup _impl */



/* G-02f-175：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */


/* pure 权威：thin.x driver_diagnostic_typeck_return_unresolved；冷启动全 C；FROM_X 无 pure-dup _impl */

/* G-02f-175：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */


/* pure 权威：thin.x driver_diagnostic_typeck_return_subexpr；冷启动全 C；FROM_X 无 pure-dup _impl */



/* G-02f-177：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */


/* pure 权威：thin.x driver_diagnostic_typeck_call_not_generic；冷启动全 C；FROM_X 无 pure-dup _impl */



/* G-02f-177：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */


/* pure 权威：thin.x driver_diagnostic_typeck_call_wrong_num_type_args；冷启动全 C；FROM_X 无 pure-dup _impl */

/* G-02f-177：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */


/* pure 权威：thin.x driver_diagnostic_typeck_call_requires_type_args；冷启动全 C；FROM_X 无 pure-dup _impl */





/**
 * .x 流水线 typeck：赋值 / 复合赋值左右类型不符时打印一行 stderr，与 typeck.c 经 lsp_diag_report_typeck 的措辞一致，
 * 以便 run-typeck、负例与 xlang-c 对齐（含 "assignment type mismatch: expected …, found …"）。
 */
/** .x typeck：break/continue 不在循环内时打印，与 typeck.c TYPECK_ERR 措辞一致。 */
/* pure 权威：thin.x driver_diagnostic_typeck_break_continue_outside；冷启动全 C；FROM_X 无 pure-dup _impl */

/* wave285/wave289 Cap residual: pure 权威 thin.x driver_diagnostic_typeck_invalid_ptr_binop；
 * 冷启动全 C；FROM_X 无 pure-dup _impl。wave289 also unary -~ on ptr. PLATFORM: SHARED. */

/* wave286/wave289 Cap residual: pure 权威 thin.x driver_diagnostic_typeck_invalid_float_binop；
 * 冷启动全 C；FROM_X 无 pure-dup _impl。wave289 also unary ~ on f32/f64. PLATFORM: SHARED. */



/* wave657 Cap residual: pure authority thin.x driver_diagnostic_typeck_invalid_aggregate_cmp;
 * cold-start full C; FROM_X no pure-dup _impl. PLATFORM: SHARED. */

/* wave659 Cap residual: pure authority thin.x driver_diagnostic_typeck_invalid_as_cast;
 * cold-start full C; FROM_X no pure-dup _impl. PLATFORM: SHARED. */

/* wave677 Cap residual: pure authority thin.x driver_diagnostic_typeck_invalid_bool_binop;
 * cold twin under #ifndef XLANG_L2_RDD_THIN_FROM_X. */

/* wave678 Cap residual: pure authority thin.x driver_diagnostic_typeck_assign_to_const. */

/* wave680 Cap residual: pure authority thin.x driver_diagnostic_typeck_duplicate_local. */

/* pure 权威：thin.x driver_diagnostic_typeck_if_condition_not_bool；冷启动全 C；FROM_X 无 pure-dup _impl */


/* pure 权威：thin.x driver_diagnostic_typeck_while_condition_not_bool；冷启动全 C；FROM_X 无 pure-dup _impl */


/* pure 权威：thin.x driver_diagnostic_typeck_for_condition_not_bool；冷启动全 C；FROM_X 无 pure-dup _impl */


/** LANG-007 v2：S0 内 *T 解引用须在 unsafe { } 内。 */
/* pure 权威：thin.x driver_diagnostic_typeck_deref_outside_unsafe；冷启动全 C；FROM_X 无 pure-dup _impl */


/** LANG-007 v2：S0 内 extern 调用须在 unsafe { } 内。 */
/* pure 权威：thin.x driver_diagnostic_typeck_extern_call_outside_unsafe；冷启动全 C；FROM_X 无 pure-dup _impl */


/** .x typeck：对 linear 值取址时打印，与 typeck.c「cannot take address of linear value」一致。 */
/* pure 权威：thin.x driver_diagnostic_typeck_linear_addr_of；冷启动全 C；FROM_X 无 pure-dup _impl */


/** .x typeck：import 顶层 const 裸名访问时打印，与 typeck.c TYPECK_ERR 措辞对齐。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* pure authority: thin.x driver_diagnostic_typeck_import_const_must_be_qualified; cold keeps C body; FROM_X no pure-dup _impl (H↓). */





/** .x typeck：match 臂 Enum.Variant 在模块枚举表中未命中（与 typeck.c TYPECK_ERR 措辞一致）。 */
/* pure 权威：thin.x driver_diagnostic_typeck_enum_no_variant；冷启动全 C；FROM_X 无 pure-dup _impl */
/* pure 权威：thin.x driver_diagnostic_typeck_struct_padding_before；冷启动全 C；FROM_X 无 pure-dup _impl */


/** .x typeck：下标基类型非数组/切片/指针时打印，与 typeck.c TYPECK_ERR 措辞一致。 */
/* pure 权威：thin.x driver_diagnostic_typeck_subscript_base；冷启动全 C；FROM_X 无 pure-dup _impl */


/** ERR-01：`?` 要求 enclosing function 返回与 operand 同型的 Result（run-typeck result_try_bad.x）。 */
/* pure 权威：thin.x driver_diagnostic_typeck_try_propagate_bad_enclosing；冷启动全 C；FROM_X 无 pure-dup _impl */


/** .x typeck：结构体 §11.1 隐式 padding 前间隙；行文与 typeck.c TYPECK_ERR_AT 一致。 */
/* G-02f-178：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */



/* G-02f-178：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */


/* pure 权威：thin.x driver_diagnostic_typeck_struct_padding_trailing；冷启动全 C；FROM_X 无 pure-dup _impl */

/* G-02f-178：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */


/* pure 权威：thin.x driver_diagnostic_typeck_struct_field_bad_size；冷启动全 C；FROM_X 无 pure-dup _impl */

/* G-02f-176：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* pure 权威：thin.x driver_diagnostic_typeck_assign_mismatch；冷启动全 C；FROM_X 无 pure-dup _impl */





/* pure 权威：thin.x scratch expect/found BSS + typeck_block/fn/var debug（append+note）；
 * 冷启动保留 C 体；FROM_X 无 pure-dup _impl（H↓）。 */




/** -x -E 多文件诊断：codegen 前打印 module.num_funcs 与 out_buf.length，便于排查 dep 产出为空。 */
/** 供 .x 探测 XLANG_DEBUG_PIPE（G-02f-164）。 */
/* pure 权威：thin.x driver_diag_env_debug_pipe；冷启动保留 _impl + public；FROM_X 剔除 pure-dup（H↓）。 */
/** pure 权威：thin.x driver_diag_pipe_note（append+note，无 va_list reportf）；
 * 冷启动保留 reportf 体；FROM_X 无 pure-dup _impl（H↓）。
 * kind：0=before_codegen 1=source_len 2=after_entry 3=pipe_marker。 */

/* G-02f-164：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* pure 权威：thin.x driver_diagnostic_before_codegen；冷启动全 C；FROM_X 无 pure-dup _impl */



/** 诊断：pipeline 入口 ctx.entry_already_parsed。由 pipeline.x 调用。需要时取消注释 fprintf。 */

/** 诊断：解析前 source_len。由 pipeline.x 调用。需要时取消注释 fprintf。 */
/* G-02f-164：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* pure 权威：thin.x driver_diagnostic_source_len；冷启动全 C；FROM_X 无 pure-dup _impl */



/** 诊断：entry 解析后 module.num_funcs，便于确认是否未解析（0）。由 pipeline.x 调用。需要时取消注释 fprintf。 */
/* G-02f-164：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* pure 权威：thin.x driver_diagnostic_after_entry_parse；冷启动全 C；FROM_X 无 pure-dup _impl */



extern int32_t pipeline_module_num_funcs(void *module);
extern int32_t pipeline_module_func_is_extern_at(void *module, int32_t fi);

/**
 * 诊断：parse_into_buf commit 失败（arena/侧车池满等）；XLANG_DEBUG_PARSE=1 或 XLANG_PARSE_STRICT=1。
 * 大模块 typeck 单函数 commit 失败时不应整文件 abort，由 seed parse 改 skip+continue。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* pure authority: thin.x driver_diagnostic_parse_commit_fail; cold keeps C body; FROM_X no pure-dup _impl (H↓). */





/**
 * 诊断：parse_into/parse_into_buf 在提交函数槽前打印 generic 计数，定位 OneFuncResult 到 module.funcs 的污染链。
 * 环境变量 XLANG_DEBUG_PARSE_GENERIC=1。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* pure authority: thin.x driver_diagnostic_parse_func_generic; cold keeps C body; FROM_X no pure-dup _impl (H↓). */





/**
 * 诊断：函数体提交前后打印 OneFunc sidecar 与 Block 形状，定位污染发生在 fill 之前还是 body_ref 绑定之后。
 * 环境变量 XLANG_DEBUG_PARSE_COMMIT=1。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* pure authority: thin.x driver_diagnostic_parse_commit_shape; cold keeps C body;
 * FROM_X no pure-dup _impl (H↓ / rest T↓). */

/* pure authority: thin.x parser_diagnostic_parse_commit_shape (zero-logic alias of driver_*);
 * cold keeps C forward; FROM_X no pure-dup _impl. */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */

/* wave302 G.7: parse_commit_pre/post cold twin (thin.x pure authority when PREFER_X_O;
 * dual-export ban vs pipeline_glue_strict_minimal — body deleted there). PLATFORM: SHARED. */




/**
 * 诊断：entry 解析后 num_funcs / num_defined / num_extern 分项（A-11 typeck 截断：target num_defined=146）。
 * pure authority: thin.x driver_diagnostic_after_entry_parse_module (pipeline API + append+note);
 * cold keeps C body; FROM_X no pure-dup _impl (H↓ / rest T↓ wave4).
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */




/** 诊断：pipeline/typeck 阶段 marker；XLANG_DEBUG_PIPE=1 时打印（1=merge 后，2=typeck library 入口，3=validate 后）。 */
/* G-02f-164：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* pure 权威：thin.x driver_diagnostic_pipe_marker；冷启动全 C；FROM_X 无 pure-dup _impl */



/** 每个 dep codegen 后打印 j 与 out_buf.length，确认 buffer 是否递增。需要时取消注释 fprintf。 */

/** codegen fail note: which dep (is_dep!=0) or entry module (is_dep==0).
 * pure authority: thin.x driver_diagnostic_codegen_fail (append+note);
 * cold keeps C body; FROM_X no pure-dup _impl (H↓). */




/** codegen emit_func 失败时打印函数下标与名称（pipeline_glue / ast_pool 提供读 API）。
 * pure authority: thin.x driver_diagnostic_codegen_emit_func_fail (pipeline name API + append+CG003);
 * cold keeps C body; FROM_X no pure-dup _impl (H↓ / rest T↓ wave4). */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */




/** asm 后端：不支持的 ExprKind 时由 backend.x 调用，便于定位 rc=-6；kind 为 ast_ExprKind 枚举值。 */
/* G-02f-179：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* pure 权威：thin.x driver_diagnostic_asm_unsupported_expr；冷启动全 C；FROM_X 无 pure-dup _impl */





/** asm 后端：elf_resolve_patches 找不到补丁目标标签。 */
/* G-02f-179：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* pure 权威：thin.x driver_diagnostic_asm_elf_unresolved_patch；冷启动全 C；FROM_X 无 pure-dup _impl */





/** asm 后端：Mach-O 写出时 reloc 符号名为空。 */
/* G-02f-179：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* pure 权威：thin.x driver_diagnostic_asm_macho_empty_reloc；冷启动全 C；FROM_X 无 pure-dup _impl */





/** asm 后端：Mach-O 写出时外部 reloc 未命中 und 池（常与 macho_leading_underscore 未置 1 有关）。 */
/* G-02f-179：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* pure 权威：thin.x driver_diagnostic_asm_macho_missing_und_reloc；冷启动全 C；FROM_X 无 pure-dup _impl */





/* Asm BSS family stays in this TU. The thin .x does not own these stores:
 * a file-scope let store still CG002s, so one C static buffer is the store
 * and the notes that read it. PLATFORM: SHARED.
 */
/** asm 后端：记录当前正在 emit 的 ExprKind 序数，供 fail_at 时打印。 */
static int driver_diagnostic_asm_last_expr_kind = -1;
void driver_diagnostic_asm_last_expr_kind_set_impl(int32_t k) {
    driver_diagnostic_asm_last_expr_kind = (int)k;
}
void driver_diagnostic_asm_last_expr_kind_set(int32_t k) {
    driver_diagnostic_asm_last_expr_kind_set_impl(k);
}
void driver_diagnostic_asm_set_last_expr_kind(int32_t k) {
    driver_diagnostic_asm_last_expr_kind_set_impl(k);
}

/** asm 后端：记录当前正在 codegen 的函数名，供 var_not_found 时打印。 */
static uint8_t driver_diagnostic_asm_current_func[72];
static int driver_diagnostic_asm_current_func_len = 0;
void driver_diagnostic_asm_current_func_store_impl(const uint8_t *name, int32_t len) {
    driver_diagnostic_asm_current_func_len = (len > 0 && len <= 64) ? (int)len : 0;
    if (name && driver_diagnostic_asm_current_func_len > 0) {
        for (int i = 0; i < driver_diagnostic_asm_current_func_len; i++)
            driver_diagnostic_asm_current_func[i] = name[i];
    }
}
void driver_diagnostic_asm_current_func_maybe_trace_impl(void) {
    /* Class AO: XLANG_ASM_FUNC_TRACE Cap note retired (mirror thin). */
}
void driver_diagnostic_asm_current_func_store(const uint8_t *name, int32_t len) {
    driver_diagnostic_asm_current_func_store_impl(name, len);
}
void driver_diagnostic_asm_current_func_maybe_trace(void) {
    driver_diagnostic_asm_current_func_maybe_trace_impl();
}
void driver_diagnostic_asm_set_current_func(const uint8_t *name, int32_t len) {
    driver_diagnostic_asm_current_func_store_impl(name, len);
    driver_diagnostic_asm_current_func_maybe_trace_impl();
}

/** backend_asm_codegen_ast_to_elf 返回 -1 时打印当前函数名（XLANG_ASM_DEBUG）。 */
void driver_diagnostic_asm_print_current_func(void)
{
    if (driver_diagnostic_asm_current_func_len > 0)
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "asm codegen failed in func=%.*s",
                     driver_diagnostic_asm_current_func_len,
                     (const char *)driver_diagnostic_asm_current_func);
    else
        diag_report(NULL, 0, 0, "note", "asm codegen failed (func unknown)", NULL);
}

/** asm 后端：EXPR_VAR 在 local_offset 未找到时由 backend.x 调用。 */
void driver_diagnostic_asm_var_not_found(const uint8_t *name, int32_t len, int32_t num_locals,
    const uint8_t *first_slot, int32_t first_len)
{
    char namebuf[65];
    char firstbuf[65];
    const char *func_name = "?";
    int func_name_len = 1;

    driver_diag_copy_bytes(namebuf, sizeof(namebuf), name, len);
    driver_diag_copy_bytes(firstbuf, sizeof(firstbuf), first_slot, first_len);
    if (driver_diagnostic_asm_current_func_len > 0) {
        func_name = (const char *)driver_diagnostic_asm_current_func;
        func_name_len = driver_diagnostic_asm_current_func_len;
    }
    if (num_locals > 0 && first_slot && first_len > 0 && first_len <= 64) {
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "asm codegen EXPR_VAR not in ctx: \"%s\" (func: %.*s, num_locals=%d, first_slot=\"%s\" len=%d)",
                     namebuf, func_name_len, func_name, (int)num_locals, firstbuf, (int)first_len);
    } else {
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "asm codegen EXPR_VAR not in ctx: \"%s\" (func: %.*s, num_locals=%d)",
                     namebuf, func_name_len, func_name, (int)num_locals);
    }
}

/** asm 后端：返回 -1 前调用，loc 表示失败位置。 */
void driver_diagnostic_asm_fail_at(int32_t loc)
{
    const char *func_name = "?";
    int func_name_len = 1;
    if (driver_diagnostic_asm_current_func_len > 0) {
        func_name = (const char *)driver_diagnostic_asm_current_func;
        func_name_len = driver_diagnostic_asm_current_func_len;
    }
    if (driver_diagnostic_asm_current_func_len > 0) {
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "asm codegen func=%.*s fail_at=%d (last_expr_kind=%d)",
                     func_name_len, func_name, (int)loc, driver_diagnostic_asm_last_expr_kind);
        return;
    }
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "asm codegen fail_at=%d (last_expr_kind=%d)",
                 (int)loc, driver_diagnostic_asm_last_expr_kind);
}
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */




/* pure 权威：thin.x driver_debug_log / parser_diag_*（append+note，无 va_list reportf）；
 * 冷启动保留 reportf 体；FROM_X 无 pure-dup _impl（H↓）。 */


/* G-02f-116：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */



/** DOD-CL -pad-fields：相邻 atomic-sized 与普通字段同 cache line 且无 align(64) 分隔。
 * 须在 #if XLANG_USE_X_PIPELINE 外：C 前端 typeck.o（xlang-c）也调用。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* pure authority: thin.x driver_diagnostic_warn_pad_fields_same_cache_line; cold keeps C body; FROM_X no pure-dup _impl (H↓). */





/** DOD-CL-S2 -hot-reorder：热标量字段宜置大字段之前；C 前端 typeck.o 亦调用。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* pure authority: thin.x driver_diagnostic_warn_hot_reorder_field; cold keeps C body; FROM_X no pure-dup _impl (H↓). */





/** L6-unused-hint：未使用的 let/const/import 绑定（XLANG_UNUSED_HINT=1；info 层，默认不阻断 check）。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* pure authority: thin.x driver_diagnostic_hint_unused_binding; cold keeps C body; FROM_X no pure-dup _impl (H↓). */


/* G-02f-341：.x helpers 供 thin 门闩 _impl */
/* pure 权威：thin.x driver_diag_note；冷启动全 C；FROM_X 无 pure-dup _impl */


/* pure 权威：thin.x driver_diag_fill_expr_part；冷启动全 C；FROM_X 无 pure-dup _impl */


/* pure 权威：thin.x driver_diag_build_expected_found；冷启动全 C；FROM_X 无 pure-dup _impl */


/* pure authority: thin.x runtime_driver_diagnostic_slice_marker; cold keeps C; FROM_X no pure-dup. */

