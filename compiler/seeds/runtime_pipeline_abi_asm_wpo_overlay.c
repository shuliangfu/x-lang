/*
 * wave742 leftover gcc overlay TU: WAVE274 WPO cap FUNCS 4096 / EDGES 16384.
 *
 * Live product leftover is host-cc of the .x leave (g_aw_* BSS still 2048).
 * Whole from_x re-cc cannot compile WAVE274 (FROM_X skip / type-conflicts).
 * PREFER of asm_wpo_thin stays HARD BAN: Darwin file-level let is Lxml
 * COMMON with BRANCH26 lea, and ld -r falls back to libtool → g05 n_sect=2
 * on _Lxml_eeba97b0edf5c0f6 (w369b / w741).
 *
 * This TU host-cc's the leftover C twin with complete product-pool structs
 * so field access compiles, then sidecars into g05 in front of pabi (do
 * not Darwin ld -r merge into pabi). Public pipeline_asm_wpo_* faces
 * first-win; leftover T in pabi is redefined. Do not PREFER the thin.
 * Do not gcc -E of .x as the repair.
 *
 * Struct layouts copy codegen_gen.c / parser_gen.c product pool (u8[256]
 * names). Offsets must match pipeline_arena_expr_ptr / module_func_at.
 * PLATFORM: SHARED leftover gcc · LINUX gold · MACOS co-path.
 */
#ifndef XLANG_PABI_ASM_WPO_OVERLAY_STRUCTS
#define XLANG_PABI_ASM_WPO_OVERLAY_STRUCTS 1

#include <stddef.h>
#include <stdint.h>

/* Product pool ast_Expr (codegen_gen.c). kind is i32, not a C enum. */
struct ast_Expr {
  int32_t kind;
  int32_t resolved_type_ref;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t var_name[256];
  int32_t var_name_len;
  int32_t binop_left_ref;
  int32_t binop_right_ref;
  int32_t unary_operand_ref;
  int32_t if_cond_ref;
  int32_t if_then_ref;
  int32_t if_else_ref;
  int32_t block_ref;
  int32_t match_matched_ref;
  int32_t match_arm_base;
  int32_t match_num_arms;
  int32_t field_access_base_ref;
  uint8_t field_access_field_name[256];
  int32_t field_access_field_len;
  int32_t field_access_is_enum_variant;
  int32_t field_access_offset;
  int32_t field_access_soa_stride;
  int32_t index_base_ref;
  int32_t index_index_ref;
  int32_t index_base_is_slice;
  int32_t call_callee_ref;
  int32_t call_arg_base;
  int32_t call_num_args;
  int32_t call_num_type_args;
  int32_t method_call_base_ref;
  uint8_t method_call_name[256];
  int32_t method_call_name_len;
  int32_t method_call_arg_base;
  int32_t method_call_num_args;
  int32_t const_folded_val;
  int32_t const_folded_valid;
  int32_t index_proven_in_bounds;
  uint8_t struct_lit_struct_name[256];
  int32_t struct_lit_struct_name_len;
  int32_t struct_lit_field_base;
  int32_t struct_lit_num_fields;
  int32_t array_lit_elem_base;
  int32_t array_lit_num_elems;
  int32_t float_bits_lo;
  int32_t float_bits_hi;
  int32_t enum_variant_tag;
  int32_t as_operand_ref;
  int32_t as_target_type_ref;
  int32_t call_resolved_func_index;
  int32_t call_resolved_dep_index;
};

struct ast_Block {
  int32_t const_base;
  int32_t num_consts;
  int32_t let_base;
  int32_t num_lets;
  int32_t num_early_lets;
  int32_t loop_base;
  int32_t num_loops;
  int32_t for_loop_base;
  int32_t num_for_loops;
  int32_t if_base;
  int32_t num_if_stmts;
  int32_t region_base;
  int32_t num_regions;
  int32_t defer_base;
  int32_t num_defers;
  int32_t labeled_base;
  int32_t num_labeled_stmts;
  int32_t expr_stmt_base;
  int32_t num_expr_stmts;
  int32_t final_expr_ref;
  int32_t stmt_order_base;
  int32_t num_stmt_order;
  int32_t parent_block_ref;
};

struct ast_LabeledStmt {
  uint8_t label[256];
  int32_t label_len;
  int32_t is_goto;
  uint8_t goto_target[256];
  int32_t goto_target_len;
  int32_t return_expr_ref;
};

struct ast_Func {
  uint8_t name[256];
  int32_t name_len;
  int32_t param_base;
  int32_t num_params;
  int32_t num_generic_params;
  int32_t return_type_ref;
  int32_t body_ref;
  int32_t body_expr_ref;
  int32_t is_extern;
  int32_t is_async;
  int32_t is_used;
  int32_t is_naked;
  int32_t is_entry;
  int32_t is_no_mangle;
  int32_t is_interrupt;
  int32_t abi_kind;
  int32_t is_variadic;
  int32_t is_export;
};

#endif /* XLANG_PABI_ASM_WPO_OVERLAY_STRUCTS */

#include "runtime_pipeline_abi_asm_wpo.from_x.c"
