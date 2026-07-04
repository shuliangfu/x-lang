/**
 * typeck_asm_bare_link_alias.c — build_asm/typeck.o 裸符号 → pipeline_glue 的 typeck_ 前缀名
 *
 * 由 compiler/scripts/gen_typeck_asm_bare_link_alias.py 从 typeck.x 签名生成。
 */
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;

extern int32_t check_block(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);

/** build_asm check_block → glue typeck_check_block。 */
int32_t typeck_check_block(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  return check_block(module, arena, block_ref, return_type_ref, ctx);
}

extern int32_t check_block_as_loop_body(struct ast_Module * module, struct ast_ASTArena * arena, int32_t body_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);

/** build_asm check_block_as_loop_body → glue typeck_check_block_as_loop_body。 */
int32_t typeck_check_block_as_loop_body(struct ast_Module * module, struct ast_ASTArena * arena, int32_t body_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  return check_block_as_loop_body(module, arena, body_ref, return_type_ref, ctx);
}

extern int32_t check_block_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);

/** build_asm check_block_impl → glue typeck_check_block_impl。 */
int32_t typeck_check_block_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  return check_block_impl(module, arena, block_ref, return_type_ref, ctx);
}

extern int32_t check_expr(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);

/** build_asm check_expr → glue typeck_check_expr。 */
int32_t typeck_check_expr(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  return check_expr(module, arena, expr_ref, return_type_ref, ctx);
}

extern int32_t check_expr_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);

/** build_asm check_expr_impl → glue typeck_check_expr_impl。 */
int32_t typeck_check_expr_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  return check_expr_impl(module, arena, expr_ref, return_type_ref, ctx);
}

extern int32_t check_expr_impl_mega(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);

/** build_asm check_expr_impl_mega → glue typeck_check_expr_impl_mega。 */
int32_t typeck_check_expr_impl_mega(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  return check_expr_impl_mega(module, arena, expr_ref, return_type_ref, ctx);
}

extern int32_t dep_return_type_to_caller_arena(struct ast_ASTArena * dep_arena, int32_t dep_return_type_ref, struct ast_ASTArena * caller_arena);

/** build_asm dep_return_type_to_caller_arena → glue typeck_dep_return_type_to_caller_arena。 */
int32_t typeck_dep_return_type_to_caller_arena(struct ast_ASTArena * dep_arena, int32_t dep_return_type_ref, struct ast_ASTArena * caller_arena) {
  return dep_return_type_to_caller_arena(dep_arena, dep_return_type_ref, caller_arena);
}

extern int32_t ensure_array_type_ref_named_elem(struct ast_ASTArena * a, uint8_t * elem_nm, int32_t elem_nm_len, int32_t array_size);

/** build_asm ensure_array_type_ref_named_elem → glue typeck_ensure_array_type_ref_named_elem。 */
int32_t typeck_ensure_array_type_ref_named_elem(struct ast_ASTArena * a, uint8_t * elem_nm, int32_t elem_nm_len, int32_t array_size) {
  return ensure_array_type_ref_named_elem(a, elem_nm, elem_nm_len, array_size);
}

extern int32_t ensure_bool_type_ref(struct ast_ASTArena * arena);

/** build_asm ensure_bool_type_ref → glue typeck_ensure_bool_type_ref。 */
int32_t typeck_ensure_bool_type_ref(struct ast_ASTArena * arena) {
  return ensure_bool_type_ref(arena);
}

extern int32_t ensure_f32_type_ref(struct ast_ASTArena * arena);

/** build_asm ensure_f32_type_ref → glue typeck_ensure_f32_type_ref。 */
int32_t typeck_ensure_f32_type_ref(struct ast_ASTArena * arena) {
  return ensure_f32_type_ref(arena);
}

extern int32_t ensure_f64_type_ref(struct ast_ASTArena * arena);

/** build_asm ensure_f64_type_ref → glue typeck_ensure_f64_type_ref。 */
int32_t typeck_ensure_f64_type_ref(struct ast_ASTArena * arena) {
  return ensure_f64_type_ref(arena);
}

extern int32_t ensure_i32_type_ref(struct ast_ASTArena * arena);

/** build_asm ensure_i32_type_ref → glue typeck_ensure_i32_type_ref。 */
int32_t typeck_ensure_i32_type_ref(struct ast_ASTArena * arena) {
  return ensure_i32_type_ref(arena);
}

extern int32_t ensure_i64_type_ref(struct ast_ASTArena * caller_arena);

/** build_asm ensure_i64_type_ref → glue typeck_ensure_i64_type_ref。 */
int32_t typeck_ensure_i64_type_ref(struct ast_ASTArena * caller_arena) {
  return ensure_i64_type_ref(caller_arena);
}

extern int32_t ensure_kind_only_type_ref(struct ast_ASTArena * w, int32_t kind);

/** build_asm ensure_kind_only_type_ref → glue typeck_ensure_kind_only_type_ref。 */
int32_t typeck_ensure_kind_only_type_ref(struct ast_ASTArena * w, int32_t kind) {
  return ensure_kind_only_type_ref(w, kind);
}

extern int32_t ensure_struct_layout_from_struct_lit(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref);

/** build_asm ensure_struct_layout_from_struct_lit → glue typeck_ensure_struct_layout_from_struct_lit。 */
int32_t typeck_ensure_struct_layout_from_struct_lit(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref) {
  return ensure_struct_layout_from_struct_lit(module, arena, expr_ref);
}

extern int32_t ensure_u8_type_ref(struct ast_ASTArena * arena);

/** build_asm ensure_u8_type_ref → glue typeck_ensure_u8_type_ref。 */
int32_t typeck_ensure_u8_type_ref(struct ast_ASTArena * arena) {
  return ensure_u8_type_ref(arena);
}

extern int32_t ensure_usize_type_ref(struct ast_ASTArena * arena);

/** build_asm ensure_usize_type_ref → glue typeck_ensure_usize_type_ref。 */
int32_t typeck_ensure_usize_type_ref(struct ast_ASTArena * arena) {
  return ensure_usize_type_ref(arena);
}

extern int32_t ensure_void_type_ref(struct ast_ASTArena * a);

/** build_asm ensure_void_type_ref → glue typeck_ensure_void_type_ref。 */
int32_t typeck_ensure_void_type_ref(struct ast_ASTArena * a) {
  return ensure_void_type_ref(a);
}

extern int32_t entry_module_find_struct_layout_index(struct ast_Module * mod, uint8_t * nm, int32_t nlen);

/** build_asm entry_module_find_struct_layout_index → glue typeck_entry_module_find_struct_layout_index。 */
int32_t typeck_entry_module_find_struct_layout_index(struct ast_Module * mod, uint8_t * nm, int32_t nlen) {
  return entry_module_find_struct_layout_index(mod, nm, nlen);
}

extern int32_t expr_field_access_fallback_scalar_type_ref(struct ast_ASTArena * arena, uint8_t * field_name, int32_t field_name_len);

/** build_asm expr_field_access_fallback_scalar_type_ref → glue typeck_expr_field_access_fallback_scalar_type_ref。 */
int32_t typeck_expr_field_access_fallback_scalar_type_ref(struct ast_ASTArena * arena, uint8_t * field_name, int32_t field_name_len) {
  return expr_field_access_fallback_scalar_type_ref(arena, field_name, field_name_len);
}

extern int32_t expr_type_ref(struct ast_ASTArena * arena, int32_t expr_ref);

/** build_asm expr_type_ref → glue typeck_expr_type_ref。 */
int32_t typeck_expr_type_ref(struct ast_ASTArena * arena, int32_t expr_ref) {
  return expr_type_ref(arena, expr_ref);
}

extern int32_t expr_var_name_equal_func(struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_Module * mod, int32_t func_index);

/** build_asm expr_var_name_equal_func → glue typeck_expr_var_name_equal_func。 */
int32_t typeck_expr_var_name_equal_func(struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_Module * mod, int32_t func_index) {
  return expr_var_name_equal_func(arena, callee_expr_ref, mod, func_index);
}

extern int32_t find_func_return_type_in_module(struct ast_Module * mod, struct ast_ASTArena * mod_arena, struct ast_ASTArena * caller_arena, struct ast_ASTArena * callee_arena, int32_t callee_expr_ref, int32_t from_dep_index, struct ast_PipelineDepCtx * ctx, int32_t * func_index_out);

/** build_asm find_func_return_type_in_module → glue typeck_find_func_return_type_in_module。 */
int32_t typeck_find_func_return_type_in_module(struct ast_Module * mod, struct ast_ASTArena * mod_arena, struct ast_ASTArena * caller_arena, struct ast_ASTArena * callee_arena, int32_t callee_expr_ref, int32_t from_dep_index, struct ast_PipelineDepCtx * ctx, int32_t * func_index_out) {
  return find_func_return_type_in_module(mod, mod_arena, caller_arena, callee_arena, callee_expr_ref, from_dep_index, ctx, func_index_out);
}

extern int32_t find_func_return_type_in_module_by_name(struct ast_Module * mod, struct ast_ASTArena * caller_arena, uint8_t * name, int32_t name_len, int32_t from_dep_index, struct ast_PipelineDepCtx * ctx, int32_t * func_index_out);

/** build_asm find_func_return_type_in_module_by_name → glue typeck_find_func_return_type_in_module_by_name。 */
int32_t typeck_find_func_return_type_in_module_by_name(struct ast_Module * mod, struct ast_ASTArena * caller_arena, uint8_t * name, int32_t name_len, int32_t from_dep_index, struct ast_PipelineDepCtx * ctx, int32_t * func_index_out) {
  return find_func_return_type_in_module_by_name(mod, caller_arena, name, name_len, from_dep_index, ctx, func_index_out);
}

extern int32_t find_or_alloc_array_type_ref(struct ast_ASTArena * a, int32_t elem_ref, int32_t array_size);

/** build_asm find_or_alloc_array_type_ref → glue typeck_find_or_alloc_array_type_ref。 */
int32_t typeck_find_or_alloc_array_type_ref(struct ast_ASTArena * a, int32_t elem_ref, int32_t array_size) {
  return find_or_alloc_array_type_ref(a, elem_ref, array_size);
}

extern int32_t find_or_alloc_linear_type_ref(struct ast_ASTArena * w, int32_t elem_ref);

/** build_asm find_or_alloc_linear_type_ref → glue typeck_find_or_alloc_linear_type_ref。 */
int32_t typeck_find_or_alloc_linear_type_ref(struct ast_ASTArena * w, int32_t elem_ref) {
  return find_or_alloc_linear_type_ref(w, elem_ref);
}

extern int32_t find_or_alloc_named_type_ref(struct ast_ASTArena * arena, uint8_t * name, int32_t name_len);

/** build_asm find_or_alloc_named_type_ref → glue typeck_find_or_alloc_named_type_ref。 */
int32_t typeck_find_or_alloc_named_type_ref(struct ast_ASTArena * arena, uint8_t * name, int32_t name_len) {
  return find_or_alloc_named_type_ref(arena, name, name_len);
}

extern int32_t find_or_alloc_ptr_type_ref(struct ast_ASTArena * w, int32_t elem_ref);

/** build_asm find_or_alloc_ptr_type_ref → glue typeck_find_or_alloc_ptr_type_ref。 */
int32_t typeck_find_or_alloc_ptr_type_ref(struct ast_ASTArena * w, int32_t elem_ref) {
  return find_or_alloc_ptr_type_ref(w, elem_ref);
}

extern int32_t find_or_alloc_slice_type_ref(struct ast_ASTArena * w, int32_t elem_ref);

/** build_asm find_or_alloc_slice_type_ref → glue typeck_find_or_alloc_slice_type_ref。 */
int32_t typeck_find_or_alloc_slice_type_ref(struct ast_ASTArena * w, int32_t elem_ref) {
  return find_or_alloc_slice_type_ref(w, elem_ref);
}

extern int32_t find_or_alloc_vector_type_ref(struct ast_ASTArena * w, int32_t elem_ref, int32_t array_size);

/** build_asm find_or_alloc_vector_type_ref → glue typeck_find_or_alloc_vector_type_ref。 */
int32_t typeck_find_or_alloc_vector_type_ref(struct ast_ASTArena * w, int32_t elem_ref, int32_t array_size) {
  return find_or_alloc_vector_type_ref(w, elem_ref, array_size);
}

extern int32_t func_body_has_implicit_return_tail(struct ast_ASTArena * arena, int32_t body_ref);

/** build_asm func_body_has_implicit_return_tail → glue typeck_func_body_has_implicit_return_tail。 */
int32_t typeck_func_body_has_implicit_return_tail(struct ast_ASTArena * arena, int32_t body_ref) {
  return func_body_has_implicit_return_tail(arena, body_ref);
}

extern int32_t func_body_tail_expr_ref_for_implicit_rule(struct ast_ASTArena * arena, int32_t body_ref);

/** build_asm func_body_tail_expr_ref_for_implicit_rule → glue typeck_func_body_tail_expr_ref_for_implicit_rule。 */
int32_t typeck_func_body_tail_expr_ref_for_implicit_rule(struct ast_ASTArena * arena, int32_t body_ref) {
  return func_body_tail_expr_ref_for_implicit_rule(arena, body_ref);
}

extern int32_t get_dep_return_type_in_caller_arena(int32_t from_dep_index, int32_t dep_return_type_ref, struct ast_ASTArena * caller_arena, struct ast_PipelineDepCtx * ctx);

/** build_asm get_dep_return_type_in_caller_arena → glue typeck_get_dep_return_type_in_caller_arena。 */
int32_t typeck_get_dep_return_type_in_caller_arena(int32_t from_dep_index, int32_t dep_return_type_ref, struct ast_ASTArena * caller_arena, struct ast_PipelineDepCtx * ctx) {
  return get_dep_return_type_in_caller_arena(from_dep_index, dep_return_type_ref, caller_arena, ctx);
}

extern int32_t get_field_offset_from_layout(struct ast_Module * module, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len);

/** build_asm get_field_offset_from_layout → glue typeck_get_field_offset_from_layout。 */
int32_t typeck_get_field_offset_from_layout(struct ast_Module * module, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len) {
  return get_field_offset_from_layout(module, type_name, type_name_len, field_name, field_name_len);
}

extern int32_t get_field_offset_from_layout_deps(struct ast_Module * module, struct ast_PipelineDepCtx * ctx, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len);

/** build_asm get_field_offset_from_layout_deps → glue typeck_get_field_offset_from_layout_deps。 */
int32_t typeck_get_field_offset_from_layout_deps(struct ast_Module * module, struct ast_PipelineDepCtx * ctx, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len) {
  return get_field_offset_from_layout_deps(module, ctx, type_name, type_name_len, field_name, field_name_len);
}

extern int32_t get_field_type_ref_from_layout(struct ast_Module * module, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len);

/** build_asm get_field_type_ref_from_layout → glue typeck_get_field_type_ref_from_layout。 */
int32_t typeck_get_field_type_ref_from_layout(struct ast_Module * module, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len) {
  return get_field_type_ref_from_layout(module, type_name, type_name_len, field_name, field_name_len);
}

extern int32_t get_field_type_ref_from_layout_deps(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len);

/** build_asm get_field_type_ref_from_layout_deps → glue typeck_get_field_type_ref_from_layout_deps。 */
int32_t typeck_get_field_type_ref_from_layout_deps(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len) {
  return get_field_type_ref_from_layout_deps(module, arena, ctx, type_name, type_name_len, field_name, field_name_len);
}

extern int32_t name_equal(uint8_t * a, int32_t a_len, uint8_t * b, int32_t b_len);

/** build_asm name_equal → glue typeck_name_equal。 */
int32_t typeck_name_equal(uint8_t * a, int32_t a_len, uint8_t * b, int32_t b_len) {
  return name_equal(a, a_len, b, b_len);
}

extern int32_t resolve_call_binding_import_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t * dep_index_out, int32_t * func_index_out);

/** build_asm resolve_call_binding_import_return_type → glue typeck_resolve_call_binding_import_return_type。 */
int32_t typeck_resolve_call_binding_import_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t * dep_index_out, int32_t * func_index_out) {
  return resolve_call_binding_import_return_type(module, arena, callee_expr_ref, ctx, dep_index_out, func_index_out);
}

extern int32_t resolve_call_callee_local_module(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx);

/** build_asm resolve_call_callee_local_module → glue typeck_resolve_call_callee_local_module。 */
int32_t typeck_resolve_call_callee_local_module(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx) {
  return resolve_call_callee_local_module(module, arena, callee_expr_ref, ctx);
}

extern int32_t resolve_call_callee_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, int32_t call_expr_ref, struct ast_PipelineDepCtx * ctx);

/** build_asm resolve_call_callee_return_type → glue typeck_resolve_call_callee_return_type。 */
int32_t typeck_resolve_call_callee_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, int32_t call_expr_ref, struct ast_PipelineDepCtx * ctx) {
  return resolve_call_callee_return_type(module, arena, callee_expr_ref, call_expr_ref, ctx);
}

extern int32_t resolve_call_callee_scan_dep(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, int32_t callee_ord, struct ast_PipelineDepCtx * ctx, int32_t dep_i, int32_t imax);

/** build_asm resolve_call_callee_scan_dep → glue typeck_resolve_call_callee_scan_dep。 */
int32_t typeck_resolve_call_callee_scan_dep(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, int32_t callee_ord, struct ast_PipelineDepCtx * ctx, int32_t dep_i, int32_t imax) {
  return resolve_call_callee_scan_dep(module, arena, callee_expr_ref, callee_ord, ctx, dep_i, imax);
}

extern int32_t resolve_call_callee_try_binding_import(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t callee_ord);

/** build_asm resolve_call_callee_try_binding_import → glue typeck_resolve_call_callee_try_binding_import。 */
int32_t typeck_resolve_call_callee_try_binding_import(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t callee_ord) {
  return resolve_call_callee_try_binding_import(module, arena, callee_expr_ref, ctx, callee_ord);
}

extern int32_t resolve_call_callee_try_whole_import(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t callee_ord);

/** build_asm resolve_call_callee_try_whole_import → glue typeck_resolve_call_callee_try_whole_import。 */
int32_t typeck_resolve_call_callee_try_whole_import(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t callee_ord) {
  return resolve_call_callee_try_whole_import(module, arena, callee_expr_ref, ctx, callee_ord);
}

extern int32_t resolve_call_select_import_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, int32_t callee_ord, int32_t dep_ix, struct ast_PipelineDepCtx * ctx, int32_t * func_index_out);

/** build_asm resolve_call_select_import_return_type → glue typeck_resolve_call_select_import_return_type。 */
int32_t typeck_resolve_call_select_import_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, int32_t callee_ord, int32_t dep_ix, struct ast_PipelineDepCtx * ctx, int32_t * func_index_out) {
  return resolve_call_select_import_return_type(module, arena, callee_expr_ref, callee_ord, dep_ix, ctx, func_index_out);
}

extern int32_t resolve_whole_import_qualified_call_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t * dep_index_out, int32_t * func_index_out);

/** build_asm resolve_whole_import_qualified_call_return_type → glue typeck_resolve_whole_import_qualified_call_return_type。 */
int32_t typeck_resolve_whole_import_qualified_call_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t * dep_index_out, int32_t * func_index_out) {
  return resolve_whole_import_qualified_call_return_type(module, arena, callee_expr_ref, ctx, dep_index_out, func_index_out);
}

extern int32_t type_kind_ordinal(int32_t k);

/** build_asm type_kind_ordinal → glue typeck_type_kind_ordinal。 */
int32_t typeck_type_kind_ordinal(int32_t k) {
  return type_kind_ordinal(k);
}

extern int32_t type_ref_is_bool(struct ast_ASTArena * arena, int32_t type_ref);

/** build_asm type_ref_is_bool → glue typeck_type_ref_is_bool。 */
int32_t typeck_type_ref_is_bool(struct ast_ASTArena * arena, int32_t type_ref) {
  return type_ref_is_bool(arena, type_ref);
}

extern int32_t type_ref_is_bool_impl(struct ast_ASTArena * arena, int32_t type_ref);

/** build_asm type_ref_is_bool_impl → glue typeck_type_ref_is_bool_impl。 */
int32_t typeck_type_ref_is_bool_impl(struct ast_ASTArena * arena, int32_t type_ref) {
  return type_ref_is_bool_impl(arena, type_ref);
}

extern int32_t type_refs_equal(struct ast_ASTArena * arena, int32_t a, int32_t b);

/** build_asm type_refs_equal → glue typeck_type_refs_equal。 */
int32_t typeck_type_refs_equal(struct ast_ASTArena * arena, int32_t a, int32_t b) {
  return type_refs_equal(arena, a, b);
}

extern int32_t type_refs_equal_impl(struct ast_ASTArena * arena, int32_t a, int32_t b);

/** build_asm type_refs_equal_impl → glue typeck_type_refs_equal_impl。 */
int32_t typeck_type_refs_equal_impl(struct ast_ASTArena * arena, int32_t a, int32_t b) {
  return type_refs_equal_impl(arena, a, b);
}

extern int32_t type_refs_equal_named(struct ast_ASTArena * arena, int32_t a, int32_t b);

/** build_asm type_refs_equal_named → glue typeck_type_refs_equal_named。 */
int32_t typeck_type_refs_equal_named(struct ast_ASTArena * arena, int32_t a, int32_t b) {
  return type_refs_equal_named(arena, a, b);
}

extern int32_t type_refs_equal_same_kind(struct ast_ASTArena * arena, int32_t a, int32_t b, int32_t kind_ord);

/** build_asm type_refs_equal_same_kind → glue typeck_type_refs_equal_same_kind。 */
int32_t typeck_type_refs_equal_same_kind(struct ast_ASTArena * arena, int32_t a, int32_t b, int32_t kind_ord) {
  return type_refs_equal_same_kind(arena, a, b, kind_ord);
}

