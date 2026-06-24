/**
 * runtime_driver_diagnostic.h — pipeline/typeck/asm 诊断 ABI 声明（Phase E-04 v34）
 *
 * 文件职责：声明 driver_diagnostic_*、parser_diag_*、typeck 诊断 scratch；供 pipeline.sx / typeck.sx / C typeck 链接。
 * 所属模块：compiler 运行时 driver 诊断；实现于 runtime_driver_diagnostic.c。
 * 与其它文件的关系：依赖 lsp_diag、runtime_driver_abi；不依赖 C 前端头。
 */

#ifndef SHUX_RUNTIME_DRIVER_DIAGNOSTIC_H
#define SHUX_RUNTIME_DRIVER_DIAGNOSTIC_H

#include <stdint.h>

/** parse 失败（main_idx / num_funcs / arena_num_types）。 */
void driver_diagnostic_parse_fail(int32_t main_idx, int32_t num_funcs, int32_t arena_num_types);

/** SHUX_PARSE_STRICT=1 时 parse_into_buf 单函数失败返回 -2。 */
int32_t driver_parse_strict_enabled(void);

/** parse_into_buf 跳过无法解析的 function 时打印诊断。 */
void driver_diagnostic_parse_skip_function(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len,
                                           const uint8_t *name);

void driver_diagnostic_typeck_fail(void);
void driver_diagnostic_typeck_func_fail(int32_t func_idx, const uint8_t *name, int32_t name_len, int32_t kind);
void driver_diagnostic_typeck_ptr_field(int32_t bt_kind, int32_t inner_kind, int32_t inner_nlen, int32_t base_resolved_ref,
                                        int32_t num_struct_layouts);
void driver_diagnostic_typeck_ret_fail(int32_t stage, int32_t op_expr_ref, int32_t expect_ty_ref, int32_t got_ty_ref);
void driver_diagnostic_typeck_return_mismatch(int32_t line, int32_t col, const uint8_t *expect_buf, int32_t expect_len,
                                              const uint8_t *found_buf, int32_t found_len);
void driver_diagnostic_typeck_break_continue_outside(int32_t line, int32_t col, int32_t is_break);
void driver_diagnostic_typeck_linear_addr_of(int32_t line, int32_t col);
void driver_diagnostic_typeck_enum_no_variant(int32_t line, int32_t col);
void driver_diagnostic_typeck_subscript_base(int32_t line, int32_t col);
void driver_diagnostic_typeck_struct_padding_before(const uint8_t *sname, int32_t sname_len, int32_t gap,
                                                    const uint8_t *fname, int32_t fname_len);
void driver_diagnostic_typeck_struct_padding_trailing(const uint8_t *sname, int32_t sname_len, int32_t gap);
void driver_diagnostic_typeck_struct_field_bad_size(const uint8_t *sname, int32_t sname_len, const uint8_t *fname,
                                                    int32_t fname_len);
void driver_diagnostic_typeck_assign_mismatch(int32_t is_compound, int32_t line, int32_t col, const uint8_t *expect_buf,
                                              int32_t expect_len, const uint8_t *found_buf, int32_t found_len);

/** typeck.sx 诊断 scratch（勿嵌套于 driver_diagnostic 实参）。 */
uint8_t *driver_typeck_diag_scratch_expect(void);
uint8_t *driver_typeck_diag_scratch_found(void);

void driver_diagnostic_typeck_block_enter(int32_t func_idx, int32_t block_ref, int32_t n_const, int32_t n_let, int32_t n_loop,
                                          int32_t n_for, int32_t n_expr, int32_t final_ref);
void driver_diagnostic_typeck_fn_enter(int32_t func_idx, const uint8_t *name, int32_t name_len);
void driver_diagnostic_before_codegen(int32_t num_funcs, int32_t out_len);
void driver_diagnostic_entry_already(int32_t v);
void driver_diagnostic_source_len(int32_t len);
void driver_diagnostic_after_entry_parse(int32_t num_funcs);
void driver_diagnostic_parse_commit_fail(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len,
                                         const uint8_t *name);
void driver_diagnostic_after_entry_parse_module(void *module);
void driver_diagnostic_pipe_marker(int32_t id);
void driver_diagnostic_after_dep_codegen(int32_t j, int32_t out_len);
void driver_diagnostic_codegen_fail(int32_t dep_index, int32_t is_dep);
void driver_diagnostic_codegen_emit_func_fail(void *module, int32_t func_index);
void driver_diagnostic_asm_unsupported_expr(int32_t kind);
void driver_diagnostic_asm_elf_unresolved_patch(const uint8_t *name, int32_t len);
void driver_diagnostic_asm_macho_empty_reloc(int32_t reloc_idx);
void driver_diagnostic_asm_macho_missing_und_reloc(int32_t reloc_idx);
void driver_diagnostic_asm_set_last_expr_kind(int32_t k);
void driver_diagnostic_asm_set_current_func(const uint8_t *name, int32_t len);
void driver_diagnostic_asm_print_current_func(void);
void driver_diagnostic_asm_var_not_found(const uint8_t *name, int32_t len, int32_t num_locals, const uint8_t *first_slot,
                                         int32_t first_len);
void driver_diagnostic_asm_fail_at(int32_t loc);

void driver_debug_log(int32_t step);
void parser_diag_tok_kind(int32_t k);
void parser_diag_ident_len(int32_t len);
void parser_diag_scan_fail(int32_t step);
int parser_is_ident_allow(const uint8_t *ident, int len);

/** C typeck 也调用（须在 pipeline 条件编译外）。 */
void driver_diagnostic_warn_pad_fields_same_cache_line(const uint8_t *sname, int32_t sname_len, const uint8_t *f0,
                                                     int32_t f0_len, const uint8_t *f1, int32_t f1_len);
void driver_diagnostic_warn_hot_reorder_field(const uint8_t *sname, int32_t sname_len, const uint8_t *hot,
                                              int32_t hot_len, const uint8_t *cold, int32_t cold_len);
void driver_diagnostic_hint_unused_binding(int32_t line, int32_t col, const uint8_t *name, int32_t name_len);

#endif /* SHUX_RUNTIME_DRIVER_DIAGNOSTIC_H */
