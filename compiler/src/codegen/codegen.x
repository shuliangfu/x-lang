// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// See implementation.
//
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.

// Cap-T001 / LANG-007 S0 (M1→M2 codegen): functions that call export-extern
// pipeline_* / driver_* / glue use whole-body unsafe FFI gates.
// Residual (not Cap-T001): after wrap, first fail is XT001 — collect parse dep=ast
// pr_ok=-2 (parser state after entry parse of mega codegen.x). Product seed pin unchanged.
// PLATFORM: SHARED — product still pins codegen seed until M2.

const ast = import("ast");
// Bare import so the pin egg and the product compiler share one Buf type.
// PLATFORM: SHARED.
const codegen_outbuf = import("codegen_outbuf");
import codegen_outbuf;

// Block counters stay in the pipeline runtime. ast.x no longer defines them.
extern function ast_ast_block_num_lets(a: *ASTArena, br: i32): i32;
extern function ast_ast_block_num_stmt_order(a: *ASTArena, br: i32): i32;
extern function ast_ast_block_num_consts(a: *ASTArena, br: i32): i32;
extern function ast_ast_block_num_expr_stmts(a: *ASTArena, br: i32): i32;
extern function ast_ast_block_expr_stmt_ref(a: *ASTArena, br: i32, ei: i32): i32;
extern function ast_ast_block_final_expr_ref(a: *ASTArena, body_ref: i32): i32;
extern function ast_ast_block_num_regions(a: *ASTArena, br: i32): i32;
extern function ast_ast_block_region_body_ref(a: *ASTArena, br: i32, ri: i32): i32;
extern function ast_ast_block_stmt_order_kind(a: *ASTArena, br: i32, si: i32): u8;
extern function ast_ast_block_stmt_order_idx(a: *ASTArena, br: i32, si: i32): i32;
extern function ast_ast_block_num_loops(a: *ASTArena, br: i32): i32;
extern function ast_ast_block_while_cond_ref(a: *ASTArena, br: i32, wi: i32): i32;
extern function ast_ast_block_while_body_ref(a: *ASTArena, br: i32, wi: i32): i32;
extern function ast_ast_block_num_for_loops(a: *ASTArena, br: i32): i32;
extern function ast_ast_block_for_init_ref(a: *ASTArena, br: i32, fi: i32): i32;
extern function ast_ast_block_for_cond_ref(a: *ASTArena, br: i32, fi: i32): i32;
extern function ast_ast_block_for_step_ref(a: *ASTArena, br: i32, fi: i32): i32;
extern function ast_ast_block_for_body_ref(a: *ASTArena, br: i32, fi: i32): i32;
extern function ast_ast_block_num_if_stmts(a: *ASTArena, br: i32): i32;
extern function ast_ast_block_if_cond_ref(a: *ASTArena, br: i32, ii: i32): i32;
extern function ast_ast_block_if_then_body_ref(a: *ASTArena, br: i32, ii: i32): i32;
extern function ast_ast_block_if_else_body_ref(a: *ASTArena, br: i32, ii: i32): i32;

/* See implementation. */
export extern function pipeline_dep_ctx_import_path_len(ctx: *PipelineDepCtx, idx: i32): i32;
export extern function pipeline_dep_ctx_import_path_copy64(ctx: *PipelineDepCtx, idx: i32, dst: *u8): void;
export extern function pipeline_dep_ctx_module_at(ctx: *PipelineDepCtx, idx: i32): *Module;
export extern function pipeline_dep_ctx_arena_at(ctx: *PipelineDepCtx, idx: i32): *ASTArena;
export extern function pipeline_dep_ctx_ndep(ctx: *PipelineDepCtx): i32;

/* See implementation. */
export extern function pipeline_type_named_name_into(arena: *ASTArena, ref: i32, out64: *u8): i32;
export extern function pipeline_type_kind_ord_at(arena: *ASTArena, ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *ASTArena, ref: i32): i32;
export extern function pipeline_type_array_size_at(arena: *ASTArena, ref: i32): i32;
/** wave467: TYPE_NAMED type-pos arg at index (`Name<T,U>` sidecar). */
export extern function pipeline_type_type_arg_ref_at(arena: *ASTArena, type_ref: i32, idx: i32): i32;
export extern function pipeline_module_struct_layout_num_type_params_at(module: *Module, li: i32): i32;
export extern function pipeline_module_struct_layout_type_param_name_len(module: *Module, li: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_type_param_name_into(module: *Module, li: i32, j: i32, out64: *u8): void;
/**
 * Peel `type Alias = Target` for host-C emit (wave376).
 * @param arena *ASTArena — type pool
 * @param type_ref i32 — possibly TYPE_NAMED alias
 * @return i32 — underlying type_ref
 * PLATFORM: SHARED — needs g_typeck_active_module (set through typeck; kept for codegen).
 */
export extern function pipeline_typeck_resolve_type_alias_ref_c(arena: *ASTArena, type_ref: i32): i32;
/* See implementation. */
export extern function pipeline_codegen_type_to_c_repr(arena: *ASTArena, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
/* See implementation. */
export extern function pipeline_codegen_c_file_prologue_done_get(): i32;
export extern function pipeline_codegen_c_file_prologue_done_set(v: i32): void;
export extern function pipeline_codegen_c_file_prologue_done_reset(): void;
/* See implementation. */
export extern function pipeline_codegen_struct_tag_try_claim(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32;
/* See implementation. */
export extern function pipeline_codegen_emit_struct_field_type(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
/* See implementation. */
export extern function pipeline_codegen_emit_struct_field_decl(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, field_name: *u8, field_name_len: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
/* See implementation. */
export extern function pipeline_codegen_emit_seed_mega_enabled(): i32;
/** C-backend float literal emit (host snprintf; float_val + float_bits fallback).
 * Authority: runtime_pipeline_abi seed ALWAYS (WAVE289_CODEGEN_OUTBUF_ALWAYS) —
 * pipeline_codegen_emit_float_lit_c; dual-export ban (not pipeline_x / not strict_minimal).
 * PLATFORM: SHARED — required by force-regen codegen M2 (EXPR_FLOAT_LIT). */
export extern function pipeline_codegen_emit_float_lit_c(out: *CodegenOutBuf, float_val: f64, bits_lo: i32, bits_hi: i32): i32;
/* See implementation. */
export extern function driver_diagnostic_codegen_emit_func_fail(module: *Module, func_index: i32): void;
/* See implementation. */
export extern function pipeline_module_struct_layout_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_struct_layout_name_into(module: *Module, idx: i32, out64: *u8): void;
export extern function pipeline_module_struct_layout_num_fields(module: *Module, idx: i32): i32;
export extern function pipeline_module_struct_layout_field_type_ref(module: *Module, layout_idx: i32, field_idx: i32): i32;
export extern function pipeline_module_struct_layout_field_name_len(module: *Module, layout_idx: i32, field_idx: i32): i32;
export extern function pipeline_module_struct_layout_field_name_into(module: *Module, layout_idx: i32, field_idx: i32, out64: *u8): void;
/* See implementation. */
export extern function pipeline_module_struct_layout_is_export_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_kind_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_binding_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_binding_name_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_import_select_count_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_select_name_len(module: *Module, idx: i32, sel: i32): i32;
export extern function pipeline_module_import_select_name_byte_at(module: *Module, idx: i32, sel: i32, off: i32): u8;
export extern function pipeline_module_import_path_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_path_copy(module: *Module, idx: i32, dst: *u8, dst_cap: i32): void;
export extern function parser_get_module_num_imports(module: *Module): i32;
export extern function driver_dep_arena_buf(i: i32): *u8;
export extern function driver_dep_module_buf(i: i32): *u8;
export extern function driver_dep_seeded_get(i: i32): i32;
export extern function driver_dep_slot_for_path(path: *u8): i32;
/* See implementation. */
export extern function driver_get_current_dep_path_for_codegen(): *u8;
/* See implementation. */
export extern function pipeline_expr_kind_ord_at(arena: *ASTArena, expr_ref: i32): i32;
/** True if expr is a C static-initializer constant (pure lit tree; no free VAR).
 * PLATFORM: SHARED — gates mutable top-level let decl-site init vs init_globals. */
export extern function pipeline_expr_is_c_static_const_init(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *ASTArena, expr_ref: i32): i32;
/**
 * Stamp anonymous STRUCT_LIT dest name (typeck / host-C emit pair).
 * Why setter (not Expr get_copy/set_copy): ~400-byte Expr sret SIGBUS on arm64.
 * PLATFORM: SHARED — glue pipeline_expr_struct_lit_type_name_set.
 */
export extern function pipeline_expr_struct_lit_type_name_set(arena: *ASTArena, expr_ref: i32,
name: *u8, name_len: i32): void;
/**
 * Stamp expr resolved_type_ref without copying the whole Expr row.
 * @param arena *ASTArena — expression pool
 * @param expr_ref i32 — expr
 * @param type_ref i32 — dest type
 * PLATFORM: SHARED
 */
export extern function pipeline_expr_set_resolved_type_ref(arena: *ASTArena, expr_ref: i32,
type_ref: i32): void;
export extern function pipeline_expr_as_target_type_ref_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_call_arg_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_call_num_args_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_typeck_type_refs_equal_c(arena: *ASTArena, a: i32, b: i32): i32;
/** F2: TYPE_DYN null-sentinel test reused from typeck.x (G.7 single authority).
 * Returns 1 iff rhs_expr_ref is the literal 0 (null fat-ptr representation),
 * bypassing the concrete→dyn impl-lookup gate. @param rhs_type_ref reserved
 * (unused; kept for API symmetry with typeck). PLATFORM: SHARED. */
export extern function typeck_dyn_rhs_is_null_sentinel(arena: *ASTArena, rhs_type_ref: i32, rhs_expr_ref: i32): i32;
/**
 * Cap 10.7.1 name table (typeck.x). Host-C must not emit `extern void va_start`
 * / `va_end` / `va_copy` / `va_arg*` — those are typeck faces rewritten to
 * xlang_va_* macros; clang treats va_start/va_end as builtins (redeclare hard-error).
 * @param name *u8 — bare identifier
 * @param name_len i32 — byte length
 * @return i32 — 1 Cap va builtin, 0 otherwise
 * PLATFORM: SHARED — G.7 single name table; skip-emit calls this, does not copy names.
 */
export extern function typeck_is_cap_va_builtin_name(name: *u8, name_len: i32): i32;
/*
 * F3 TYPE_DYN(17) vtable-dispatch authority — G.7 accessors over the trait
 * registry `g_xlang_skip_trait_reg[]`. Method declaration order in the trait
 * body defines the vtable slot index (slot 0 = first declared method).
 *
 * `xlang_skip_trait_method_count_c` + `xlang_skip_trait_method_name_into_c`
 * are used by codegen to enumerate trait methods when building the per-impl
 * function-pointer array at the concrete->dyn coerce site (Step 4).
 * `xlang_skip_trait_method_ret_kind_c` gives the builtin return kind for the
 * function-pointer cast (only needed if the cast tightens past `void`).
 *
 * Bodies live in analysis/archive/parser_asm/parser_asm_skip_tl_slice.inc (Class BZ) (twins of
 * xlang_skip_impl_self_matches_for_c). codegen must NOT iterate
 * g_xlang_skip_trait_reg_* globals directly.
 * PLATFORM: SHARED.
 */
export extern function xlang_skip_trait_method_count_c(trait_nm: *u8, trait_nlen: i32): i32;
export extern function xlang_skip_trait_method_name_into_c(trait_nm: *u8, trait_nlen: i32,
        slot: i32, out64: *u8): i32;
export extern function xlang_skip_trait_method_ret_kind_c(trait_nm: *u8, trait_nlen: i32,
        slot: i32): i32;
/**
 * Formal TypeKind ordinal for one trait-method parameter (including self at 0).
 * Call-site host-C dyn casts use extra i → param_ix i+1 so the fn-ptr
 * type matches codegen_emit_vtable_wrapper_def (no default-arg promotion).
 * Body: analysis/archive/parser_asm/parser_asm_skip_tl_slice.inc (Class BZ) (G.7 single accessor).
 * @param trait_nm *u8 — trait name bytes; null rejected
 * @param trait_nlen i32 — name length; must be > 0
 * @param slot i32 — vtable slot (0-based)
 * @param param_ix i32 — formal index including self
 * @return i32 — TypeKind ord, or -1 if trait/slot/param missing
 * PLATFORM: SHARED parse + typeck + host-C emit
 */
export extern function xlang_skip_trait_method_param_kind_c(trait_nm: *u8, trait_nlen: i32,
        slot: i32, param_ix: i32): i32;
/*
 * F4 per-impl vtable statics: impl-registry iterator accessors + type alloc
 * helpers. Iterators (bodies in analysis/archive/parser_asm/parser_asm_skip_tl_slice.inc (Class BZ))
 * let codegen enumerate every `impl Trait for Type` to emit a module-level
 * static vtable per impl. Type alloc helpers (bodies in
 * src/asm/pipeline_glue_strict_minimal.x) reconstruct a type_ref from a
 * for-type name so codegen can reuse `codegen_find_impl_method_for_type`
 * (single G.7 authority for impl method lookup). codegen must NOT touch the
 * g_xlang_skip_impl_* globals directly.
 * PLATFORM: SHARED.
 */
export extern function xlang_skip_impl_seen_count_c(): i32;
export extern function xlang_skip_impl_trait_name_into_c(si: i32, out64: *u8): i32;
export extern function xlang_skip_impl_for_type_into_c(si: i32, out_kind: *i32,
        out_is_ptr: *i32, out_name64: *u8, out_nlen_ptr: *i32): i32;
export extern function pipeline_type_find_or_alloc_named(arena: *ASTArena,
        name: *u8, nlen: i32): i32;
export extern function pipeline_type_find_or_alloc_compound(arena: *ASTArena,
        kind_ord: i32, elem_ref: i32, asz: i32): i32;
/** wave452: CALL turbofish type-arg type_ref (sidecar); 0 if count-only / missing. */
export extern function pipeline_expr_call_type_arg_ref_at(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_call_num_type_args_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_call_resolved_dep_index_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_call_resolved_func_index_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_arg_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_match_arm_result_ref(arena: *ASTArena, expr_ref: i32, i: i32): i32;
/** True if match arm i is the `_` wildcard (ends nested-ternary chain). */
export extern function pipeline_expr_match_arm_is_wildcard(arena: *ASTArena, expr_ref: i32, i: i32): i32;
/** Integer literal pattern value for match arm i (non-enum, non-wildcard). */
export extern function pipeline_expr_match_arm_lit_val(arena: *ASTArena, expr_ref: i32, i: i32): i32;
/** True if match arm i compares against an enum variant tag. */
export extern function pipeline_expr_match_arm_is_enum_variant(arena: *ASTArena, expr_ref: i32, i: i32): i32;
/** Enum variant index used as compare value for match arm i. */
export extern function pipeline_expr_match_arm_variant_index(arena: *ASTArena, expr_ref: i32, i: i32): i32;
/** wave700: optional match-arm guard expr (`pat if cond =>`); 0 = none. */
export extern function pipeline_expr_match_arm_guard_ref(arena: *ASTArena, expr_ref: i32, i: i32): i32;
/**
 * wave707: host-C match field-bind emit context (see runtime_pipeline_abi.x;
 * pipeline_glue.c left wave309).
 * PLATFORM: SHARED — set around match arm/guard emit; clear or restore after.
 */
export extern function pipeline_codegen_match_set_subject_c(module: *Module, matched_ref: i32, subject_ty: i32): void;
export extern function pipeline_codegen_match_clear_subject_c(): void;
export extern function pipeline_codegen_match_matched_ref_c(): i32;
export extern function pipeline_codegen_match_subject_ty_c(): i32;
export extern function pipeline_codegen_match_mod_c(): *Module;
export extern function pipeline_codegen_match_name_is_subject_field_c(module: *Module, arena: *ASTArena, name: *u8, name_len: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_field_name_len(arena: *ASTArena, expr_ref: i32, j: i32): i32;
export extern function pipeline_expr_struct_lit_field_name_into(arena: *ASTArena, expr_ref: i32, j: i32, out: *u8): void;
export extern function pipeline_expr_struct_lit_init_ref(arena: *ASTArena, expr_ref: i32, j: i32): i32;
export extern function pipeline_expr_struct_lit_num_fields(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_module_enum_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_enum_name_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_enum_num_variants(module: *Module, idx: i32): i32;
export extern function pipeline_module_enum_variant_name_len(module: *Module, idx: i32, variant_idx: i32): i32;
export extern function pipeline_module_enum_variant_name_byte_at(module: *Module, idx: i32, variant_idx: i32, off: i32): u8;
/** Codegen-time: mark Enum.Variant / import.Enum.Variant (sets is_enum_variant + tag). */
export extern function pipeline_codegen_try_mark_enum_field_access(module: *Module, arena: *ASTArena, expr_ref: i32, dep_ctx: *PipelineDepCtx): void;
export extern function pipeline_module_top_level_let_is_const(module: *Module, idx: i32): i32;
export extern function pipeline_module_top_level_let_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_top_level_let_name_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_top_level_let_type_ref(module: *Module, idx: i32): i32;
export extern function pipeline_module_top_level_let_init_ref(module: *Module, idx: i32): i32;
export extern function pipeline_expr_int_val_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_codegen_dep_skip_x_bootstrap_partial(path: *u8): i32;
/* See implementation. */
export extern function pipeline_module_func_name_copy64(module: *Module, fi: i32, dst: *u8): void;
export extern function pipeline_module_func_param_name_copy32(module: *Module, fi: i32, pi: i32, dst: *u8): void;
/* See implementation. */
export extern function pipeline_module_func_num_params_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_param_name_len_at(module: *Module, fi: i32, pi: i32): i32;
export extern function pipeline_module_func_param_type_ref_at(module: *Module, fi: i32, pi: i32): i32;
export extern function pipeline_module_func_name_len_at(module: *Module, fi: i32): i32;
/* See implementation. */
export extern function pipeline_module_func_num_generic_params_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_return_type_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_body_ref_at(module: *Module, fi: i32): i32;
/**
 * wave343 Cap residual: find `let s: T[] = a` where a is fixed TYPE_ARRAY under
 * body_ref (top-level and nested if/while/for/region/EXPR_BLOCK). Authority in
 * runtime_pipeline_abi.x (pipeline_glue.c left wave309; shared freestanding escape).
 * Soft: reassign; untyped-let.
 * @param arena *ASTArena — AST arena
 * @param body_ref i32 — function body block ref
 * @param vname *u8 — return VAR name bytes
 * @param vlen i32 — name length
 * @param out_arr_sz *i32 — fixed array N on success
 * @param out_elem_tr *i32 — element type ref on success
 * @param out_arr_init_ref *i32 — init VAR expr ref (may be null)
 * @return i32 — 1 found; 0 not found
 * PLATFORM: SHARED
 */
export extern function pipeline_find_fixed_array_slice_escape(arena: *ASTArena, body_ref: i32, vname: *u8, vlen: i32, out_arr_sz: *i32, out_elem_tr: *i32, out_arr_init_ref: *i32): i32;
/* See implementation. */
export extern function pipeline_dep_ctx_empty_param_reset(ctx: *PipelineDepCtx): void;
export extern function pipeline_dep_ctx_empty_param_append(ctx: *PipelineDepCtx, pi: i32): i32;
export extern function pipeline_dep_ctx_empty_param_at(ctx: *PipelineDepCtx, i: i32): i32;
export extern function pipeline_dep_ctx_empty_param_backup(ctx: *PipelineDepCtx): void;
export extern function pipeline_dep_ctx_empty_param_restore(ctx: *PipelineDepCtx): void;
export extern function pipeline_module_func_body_expr_ref_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_extern_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_used_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_naked_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_entry_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_no_mangle_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_interrupt_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_variadic_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_param_type_ref_at(module: *Module, fi: i32, pi: i32): i32;
/* See implementation. */
export extern function pipeline_block_const_name_copy64(arena: *ASTArena, br: i32, ci: i32, dst: *u8): void;
export extern function pipeline_block_const_name_len(arena: *ASTArena, br: i32, ci: i32): i32;
export extern function pipeline_block_const_type_ref(arena: *ASTArena, br: i32, ci: i32): i32;
export extern function pipeline_block_const_init_ref(arena: *ASTArena, br: i32, ci: i32): i32;
export extern function pipeline_block_let_name_copy64(arena: *ASTArena, br: i32, li: i32, dst: *u8): void;
export extern function pipeline_block_let_name_len(arena: *ASTArena, br: i32, li: i32): i32;
export extern function pipeline_block_let_type_ref(arena: *ASTArena, br: i32, li: i32): i32;
export extern function pipeline_block_let_init_ref(arena: *ASTArena, br: i32, li: i32): i32;
export extern function pipeline_block_if_cond_ref(arena: *ASTArena, br: i32, ii: i32): i32;
export extern function pipeline_block_if_then_body_ref(arena: *ASTArena, br: i32, ii: i32): i32;
export extern function pipeline_block_if_else_body_ref(arena: *ASTArena, br: i32, ii: i32): i32;
/* See implementation. */
export extern function pipeline_block_defer_body_ref(arena: *ASTArena, br: i32, di: i32): i32;
export extern function pipeline_module_func_ref_at(module: *Module, func_index: i32): i32;
/* See implementation. */
export extern function pipeline_asm_resolve_whole_import_qualified_symbol_c(arena: *ASTArena, cur_mod: *Module, callee_expr_ref: i32, sym_flat: *u8, out_match_imp_j: *i32): i32;
export extern function pipeline_block_stmt_order_kind(arena: *ASTArena, br: i32, si: i32): u8;
export extern function pipeline_block_stmt_order_idx(arena: *ASTArena, br: i32, si: i32): i32;
/** wave379: labeled/goto stmt_order kind=7 accessors. PLATFORM: SHARED. */
export extern function pipeline_block_num_labeled_stmts(arena: *ASTArena, br: i32): i32;
export extern function pipeline_block_labeled_is_goto(arena: *ASTArena, br: i32, li: i32): i32;
export extern function pipeline_block_labeled_label_len(arena: *ASTArena, br: i32, li: i32): i32;
export extern function pipeline_block_labeled_label_copy32(arena: *ASTArena, br: i32, li: i32, dst: *u8): void;
export extern function pipeline_block_labeled_goto_target_len(arena: *ASTArena, br: i32, li: i32): i32;
export extern function pipeline_block_labeled_goto_target_copy32(arena: *ASTArena, br: i32, li: i32, dst: *u8): void;
export extern function pipeline_block_labeled_return_expr_ref(arena: *ASTArena, br: i32, li: i32): i32;

/**
 * See implementation.
 */
/** Exported function `codegen_path_is_std_io_driver_bytes`.
 * Implements `codegen_path_is_std_io_driver_bytes`.
 * @param path *u8
 * @return i32
 */
export function codegen_path_is_std_io_driver_bytes(path: *u8): i32 {
  let expect: u8[14] = [115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0];
  let i: i32 = 0;
  if (path == 0 as *u8) {
    return 0;
  }
  while (i < 14) {
    if (path[i] != expect[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/** Exported function `codegen_path_is_std_io_core_bytes`.
 * Implements `codegen_path_is_std_io_core_bytes`.
 * @param path *u8
 * @return i32
 */
export function codegen_path_is_std_io_core_bytes(path: *u8): i32 {
  let expect: u8[12] = [115, 116, 100, 46, 105, 111, 46, 99, 111, 114, 101, 0];
  let i: i32 = 0;
  /* See implementation. */
  let pi: i32 = 0;
  let ei: i32 = 0;
  if (path == 0 as *u8) {
    return 0;
  }
  while (i < 12) {
    pi = path[i] as i32;
    ei = expect[i] as i32;
    if (pi != ei) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_import_path_to_c_prefix_into(path: *u8, buf: *u8, buf_cap: i32): void {
  if (buf == 0 as *u8 || buf_cap <= 0) {
    return;
  }
  let off: i32 = 0;
  let pi: i32 = 0;
  while (path != 0 as *u8) {
    let ch: u8 = path[pi];
    if (ch == 0 as u8) {
      break;
    }
    if (off + 2 >= buf_cap) {
      break;
    }
    if (ch == 46 as u8) {
      buf[off] = 95 as u8;
    } else {
      buf[off] = ch;
    }
    off = off + 1;
    pi = pi + 1;
  }
  if (off + 1 < buf_cap) {
    buf[off] = 95 as u8;
    off = off + 1;
  }
  buf[off] = 0 as u8;
}

/**
 * See implementation.
 */
export function codegen_dep_import_path_len_at(ctx: *PipelineDepCtx, idx: i32, dst: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let plen: i32 = pipeline_dep_ctx_import_path_len(ctx, idx);
    if (plen <= 0) {
      return 0;
    }
    pipeline_dep_ctx_import_path_copy64(ctx, idx, dst);
    return plen;
  }
}

/**
 * See implementation.
 */
export function codegen_ctx_dep_path_for_current_codegen_module_into(ctx: *PipelineDepCtx, dst: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    let nd: i32 = pipeline_dep_ctx_ndep(ctx);
    let j: i32 = 0;
    while (j < nd) {
      if (pipeline_dep_ctx_module_at(ctx, j) == ctx.current_codegen_module) {
        return codegen_dep_import_path_len_at(ctx, j, dst);
      }
      j = j + 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_module_import_path_len_at(module: *Module, import_idx: i32, dst: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (module == 0 as *Module || dst == 0 as *u8 || import_idx < 0) {
      return 0;
    }
    let plen: i32 = pipeline_module_import_path_len(module, import_idx);
    if (plen <= 0) {
      return 0;
    }
    pipeline_module_import_path_copy(module, import_idx, dst, 64);
    return plen;
  }
}

/**
 * See implementation.
 */
export function codegen_find_dep_index_by_path(ctx: *PipelineDepCtx, path: *u8, path_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || path == 0 as *u8 || path_len <= 0) {
      return -1;
    }
    let di: i32 = 0;
    let nd: i32 = pipeline_dep_ctx_ndep(ctx);
    while (di < nd) {
      let dep_path: u8[256] = [];
      let dep_len: i32 = codegen_dep_import_path_len_at(ctx, di, &dep_path[0]);
      if (dep_len == path_len) {
        let eq: bool = true;
        let k: i32 = 0;
        while (k < path_len && k < 64) {
          if (dep_path[k] != path[k]) {
            eq = false;
            break;
          }
          k = k + 1;
        }
        if (eq) {
          return di;
        }
      }
      di = di + 1;
    }
    return -1;
  }
}

/** Exported function `codegen_find_seeded_global_dep_slot_by_path`.
 * Implements `codegen_find_seeded_global_dep_slot_by_path`.
 * @param path *u8
 * @param path_len i32
 * @return i32
 */
export function codegen_find_seeded_global_dep_slot_by_path(path: *u8, path_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (path == 0 as *u8 || path_len <= 0 || path_len > 255) {
      return -1;
    }
    let path_buf: u8[256] = [];
    let i: i32 = 0;
    while (i < path_len && i < 63) {
      path_buf[i] = path[i];
      i = i + 1;
    }
    path_buf[i] = 0 as u8;
    let gs: i32 = driver_dep_slot_for_path(&path_buf[0]);
    if (gs >= 0 && driver_dep_seeded_get(gs) != 0) {
      return gs;
    }
    return -1;
  }
}

/** Exported function `codegen_module_num_imports`.
 * Implements `codegen_module_num_imports`.
 * @param module *Module
 * @return i32
 */
export function codegen_module_num_imports(module: *Module): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (module == 0 as *Module) {
      return 0;
    }
    let n_imp: i32 = parser_get_module_num_imports(module);
    if (n_imp > 0) {
      return n_imp;
    }
    return module.num_imports;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_emit_prefix_len_from_ctx(ctx: *PipelineDepCtx, buf: *u8, buf_cap: i32): i32 {
  if (buf == 0 as *u8 || buf_cap <= 0 || ctx == 0 as *PipelineDepCtx) {
    return 0;
  }
  buf[0] = 0 as u8;
  /*
   * See implementation.
   * See implementation.
   */
  if (ctx.current_codegen_dep_index < 0 && ctx.entry_module_import_path_len > 0) {
    let pi: i32 = 0;
    while (pi < ctx.entry_module_import_path_len && pi < buf_cap - 1) {
      buf[pi] = ctx.entry_module_import_path_mirror[pi];
      pi = pi + 1;
    }
    buf[pi] = 0 as u8;
    return pi;
  }
  if (ctx.current_codegen_prefix_len > 0) {
    let pi: i32 = 0;
    while (pi < ctx.current_codegen_prefix_len && pi < buf_cap - 1) {
      buf[pi] = ctx.current_codegen_prefix_mirror[pi];
      pi = pi + 1;
    }
    buf[pi] = 0 as u8;
    return pi;
  }
  let path_buf: u8[256] = [];
  let path_len: i32 = 0;
  if (ctx.current_codegen_dep_index >= 0) {
    path_len = codegen_dep_import_path_len_at(ctx, ctx.current_codegen_dep_index, &path_buf[0]);
  }
  if (path_len == 0) {
    path_len = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, &path_buf[0]);
  }
  if (path_len == 0) {
    return 0;
  }
  if (codegen_path_is_std_io_core_bytes(&path_buf[0]) != 0) {
    return 0;
  }
  codegen_import_path_to_c_prefix_into(&path_buf[0], buf, buf_cap);
  let i: i32 = 0;
  while (i < buf_cap && buf[i] != 0 as u8) {
    i = i + 1;
  }
  return i;
}

/** Exported function `codegen_emit_async_run_seed_push_name`.
 * Implements `codegen_emit_async_run_seed_push_name`.
 * @param out *CodegenOutBuf
 * @param arena *ASTArena
 * @param type_ref i32
 * @return i32
 */
export function codegen_emit_async_run_seed_push_name(out: *CodegenOutBuf, arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let push_i32: u8[29] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 105, 51, 50];
    let push_u32: u8[29] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 117, 51, 50];
    let push_i64: u8[29] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 105, 54, 52];
    let push_usize: u8[31] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 117, 115, 105, 122, 101];
    let kind_ord: i32 = TypeKind.TYPE_I32 as i32;
    if (arena != 0 as *ASTArena && !ast.ref_is_null(type_ref)) {
      kind_ord = pipeline_type_kind_ord_at(arena, type_ref);
    }
    if (kind_ord == (TypeKind.TYPE_U32 as i32)) {
      return codegen_emit_bytes_from_ptr(out, &push_u32[0], 28);
    }
    if (kind_ord == (TypeKind.TYPE_I64 as i32)) {
      return codegen_emit_bytes_from_ptr(out, &push_i64[0], 28);
    }
    if (kind_ord == (TypeKind.TYPE_USIZE as i32)) {
      return codegen_emit_bytes_from_ptr(out, &push_usize[0], 30);
    }
    return codegen_emit_bytes_from_ptr(out, &push_i32[0], 28);
  }
}

/** Exported function `codegen_emit_async_sched_call`.
 * Implements `codegen_emit_async_sched_call`.
 * @param out *CodegenOutBuf
 * @param module *Module
 * @param func_index i32
 * @return i32
 */
export function codegen_emit_async_sched_call(out: *CodegenOutBuf, module: *Module, func_index: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let sched_prefix: u8[18] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 115, 99, 104, 101, 100, 95];
    let fn_name: u8[256] = [];
    let fn_len: i32 = 0;
    if (module == 0 as *Module || func_index < 0 || func_index >= module.num_funcs) {
      return -1;
    }
    fn_len = pipeline_module_func_name_len_at(module, func_index);
    if (fn_len <= 0) {
      return -1;
    }
    pipeline_module_func_name_copy64(module, func_index, &fn_name[0]);
    if (codegen_emit_bytes_from_ptr(out, &sched_prefix[0], 17) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &fn_name[0], fn_len) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    return codegen_append_byte(out, 41);
  }
}

/** Exported function `codegen_emit_async_sched_call_by_name`.
 * Implements `codegen_emit_async_sched_call_by_name`.
 * @param out *CodegenOutBuf
 * @param fn_name *u8
 * @param fn_len i32
 * @return i32
 */
export function codegen_emit_async_sched_call_by_name(out: *CodegenOutBuf, fn_name: *u8, fn_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let sched_prefix: u8[18] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 115, 99, 104, 101, 100, 95];
    if (out == 0 as *CodegenOutBuf || fn_name == 0 as *u8 || fn_len <= 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &sched_prefix[0], 17) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, fn_name, fn_len) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    return codegen_append_byte(out, 41);
  }
}

/** Exported function `codegen_emit_async_task_submit_call`.
 * Implements `codegen_emit_async_task_submit_call`.
 * @param out *CodegenOutBuf
 * @param module *Module
 * @param func_index i32
 * @return i32
 */
export function codegen_emit_async_task_submit_call(out: *CodegenOutBuf, module: *Module, func_index: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let submit_name: u8[23] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 116, 97, 115, 107, 95, 115, 117, 98, 109, 105, 116];
    let cast_prefix: u8[19] = [40, 105, 110, 116, 51, 50, 95, 116, 32, 40, 42, 41, 40, 118, 111, 105, 100, 41, 41];
    let fn_name: u8[256] = [];
    let fn_len: i32 = 0;
    if (module == 0 as *Module || func_index < 0 || func_index >= module.num_funcs) {
      return -1;
    }
    fn_len = pipeline_module_func_name_len_at(module, func_index);
    if (fn_len <= 0) {
      return -1;
    }
    pipeline_module_func_name_copy64(module, func_index, &fn_name[0]);
    if (codegen_emit_bytes_from_ptr(out, &submit_name[0], 22) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &cast_prefix[0], 19) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &fn_name[0], fn_len) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 41) != 0) {
      return -1;
    }
    return 0;
  }
}

/** Exported function `codegen_emit_async_task_submit_call_by_symbol`.
 * Implements `codegen_emit_async_task_submit_call_by_symbol`.
 * @param out *CodegenOutBuf
 * @param prefix *u8
 * @param prefix_len i32
 * @param fn_name *u8
 * @param fn_len i32
 * @return i32
 */
export function codegen_emit_async_task_submit_call_by_symbol(out: *CodegenOutBuf, prefix: *u8, prefix_len: i32, fn_name: *u8, fn_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let submit_name: u8[23] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 116, 97, 115, 107, 95, 115, 117, 98, 109, 105, 116];
    let cast_prefix: u8[19] = [40, 105, 110, 116, 51, 50, 95, 116, 32, 40, 42, 41, 40, 118, 111, 105, 100, 41, 41];
    if (out == 0 as *CodegenOutBuf || fn_name == 0 as *u8 || fn_len <= 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &submit_name[0], 22) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &cast_prefix[0], 19) != 0) {
      return -1;
    }
    if (prefix != 0 as *u8 && prefix_len > 0 && codegen_c_prefix_redundant_with_name(prefix, prefix_len, fn_name, fn_len) == 0 && codegen_emit_bytes_from_ptr(out, prefix, prefix_len) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, fn_name, fn_len) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 41) != 0) {
      return -1;
    }
    return 0;
  }
}

/** Exported function `codegen_emit_async_binding_import_call`.
 * Implements `codegen_emit_async_binding_import_call`.
 * @param arena *ASTArena
 * @param out *CodegenOutBuf
 * @param call_expr_ref i32
 * @param ctx *PipelineDepCtx
 * @param is_spawn i32
 * @return i32
 */
export function codegen_emit_async_binding_import_call(arena: *ASTArena, out: *CodegenOutBuf, call_expr_ref: i32, ctx: *PipelineDepCtx, is_spawn: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let reset_name: u8[26] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 114, 101, 115, 101, 116];
    let comma: u8[3] = [44, 32, 0];
    let dep_path: u8[256] = [];
    let prefix_buf: u8[256] = [];
    let dep_ix: i32 = -1;
    let n_args: i32 = 0;
    let ai: i32 = 0;
    let prefix_len: i32 = 0;
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || ctx == 0 as *PipelineDepCtx) {
      return -1;
    }
    if (ast.ref_is_null(call_expr_ref) || call_expr_ref <= 0 || call_expr_ref > arena.num_exprs) {
      return -1;
    }
    let call_e: Expr = ast.ast_arena_expr_get(arena, call_expr_ref);
    if ((call_e.kind as i32) != (ExprKind.EXPR_CALL as i32) || ast.ref_is_null(call_e.call_callee_ref) || call_e.call_callee_ref <= 0 || call_e.call_callee_ref > arena.num_exprs) {
      return -1;
    }
    let callee_e: Expr = ast.ast_arena_expr_get(arena, call_e.call_callee_ref);
    if ((callee_e.kind as i32) != (ExprKind.EXPR_FIELD_ACCESS as i32) || callee_e.field_access_field_len <= 0) {
      return -1;
    }
    n_args = call_e.call_num_args;
    if (n_args < 0) {
      return -1;
    }
    if (is_spawn == 0) {
      if (n_args > 0) {
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        if (codegen_emit_bytes_from_ptr(out, &reset_name[0], 25) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 41) != 0) {
          return -1;
        }
        ai = 0;
        while (ai < n_args) {
          let arg_ref: i32 = pipeline_expr_call_arg_ref(arena, call_expr_ref, ai);
          let arg_type_ref: i32 = 0;
          if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
            return -1;
          }
          if (!ast.ref_is_null(arg_ref)) {
            arg_type_ref = pipeline_expr_resolved_type_ref(arena, arg_ref);
          }
          if (codegen_emit_async_run_seed_push_name(out, arena, arg_type_ref) != 0) {
            return -1;
          }
          if (codegen_append_byte(out, 40) != 0) {
            return -1;
          }
          if (!ast.ref_is_null(arg_ref) && codegen_emit_expr(arena, out, arg_ref, ctx) != 0) {
            return -1;
          }
          if (codegen_append_byte(out, 41) != 0) {
            return -1;
          }
          ai = ai + 1;
        }
        if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
          return -1;
        }
        if (codegen_emit_async_sched_call_by_name(out, &callee_e.field_access_field_name[0], callee_e.field_access_field_len) != 0) {
          return -1;
        }
        return codegen_append_byte(out, 41);
      }
      return codegen_emit_async_sched_call_by_name(out, &callee_e.field_access_field_name[0], callee_e.field_access_field_len);
    }
    dep_ix = codegen_resolve_binding_import_dep_index(ctx, arena, call_e.call_callee_ref);
    /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
    let ndep_as: i32 = pipeline_dep_ctx_ndep(ctx);
    if (dep_ix < 0 || dep_ix >= ndep_as) {
      return -1;
    }
    pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, &dep_path[0]);
    codegen_import_path_to_c_prefix_into(&dep_path[0], &prefix_buf[0], 128);
    while (prefix_len < 128 && prefix_buf[prefix_len] != 0) {
      prefix_len = prefix_len + 1;
    }
    if (n_args > 0) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      ai = 0;
      while (ai < n_args) {
        let arg_ref2: i32 = pipeline_expr_call_arg_ref(arena, call_expr_ref, ai);
        let arg_type_ref2: i32 = 0;
        if (ai > 0 && codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
          return -1;
        }
        if (!ast.ref_is_null(arg_ref2)) {
          arg_type_ref2 = pipeline_expr_resolved_type_ref(arena, arg_ref2);
        }
        if (codegen_emit_async_run_seed_push_name(out, arena, arg_type_ref2) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        if (!ast.ref_is_null(arg_ref2) && codegen_emit_expr(arena, out, arg_ref2, ctx) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 41) != 0) {
          return -1;
        }
        ai = ai + 1;
      }
      if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
        return -1;
      }
      if (codegen_emit_async_task_submit_call_by_symbol(out, &prefix_buf[0], prefix_len, &callee_e.field_access_field_name[0], callee_e.field_access_field_len) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    return codegen_emit_async_task_submit_call_by_symbol(out, &prefix_buf[0], prefix_len, &callee_e.field_access_field_name[0], callee_e.field_access_field_len);
  }
}

/** Exported function `codegen_emit_async_method_call_run`.
 * Implements `codegen_emit_async_method_call_run`.
 * @param arena *ASTArena
 * @param out *CodegenOutBuf
 * @param method_expr_ref i32
 * @param ctx *PipelineDepCtx
 * @return i32
 */
export function codegen_emit_async_method_call_run(arena: *ASTArena, out: *CodegenOutBuf, method_expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let reset_name: u8[26] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 114, 101, 115, 101, 116];
    let comma: u8[3] = [44, 32, 0];
    let ai: i32 = 0;
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || ctx == 0 as *PipelineDepCtx) {
      return -1;
    }
    if (ast.ref_is_null(method_expr_ref) || method_expr_ref <= 0 || method_expr_ref > arena.num_exprs) {
      return -1;
    }
    let method_e: Expr = ast.ast_arena_expr_get(arena, method_expr_ref);
    if ((method_e.kind as i32) != (ExprKind.EXPR_METHOD_CALL as i32) || method_e.method_call_name_len <= 0) {
      return -1;
    }
    if (method_e.method_call_num_args > 0) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_from_ptr(out, &reset_name[0], 25) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 41) != 0) {
        return -1;
      }
      while (ai < method_e.method_call_num_args) {
        let arg_ref: i32 = pipeline_expr_method_call_arg_ref(arena, method_expr_ref, ai);
        let arg_type_ref: i32 = 0;
        if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
          return -1;
        }
        if (!ast.ref_is_null(arg_ref)) {
          arg_type_ref = pipeline_expr_resolved_type_ref(arena, arg_ref);
        }
        if (codegen_emit_async_run_seed_push_name(out, arena, arg_type_ref) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        if (!ast.ref_is_null(arg_ref) && codegen_emit_expr(arena, out, arg_ref, ctx) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 41) != 0) {
          return -1;
        }
        ai = ai + 1;
      }
      if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
        return -1;
      }
      if (codegen_emit_async_sched_call_by_name(out, &method_e.method_call_name[0], method_e.method_call_name_len) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    return codegen_emit_async_sched_call_by_name(out, &method_e.method_call_name[0], method_e.method_call_name_len);
  }
}

/** Exported function `codegen_find_module_func_index_by_name`.
 * Implements `codegen_find_module_func_index_by_name`.
 * @param module *Module
 * @param nm *u8
 * @param nm_len i32
 * @return i32
 */
export function codegen_find_module_func_index_by_name(module: *Module, nm: *u8, nm_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (module == 0 as *Module || nm == 0 as *u8 || nm_len <= 0) {
      return -1;
    }
    let fi: i32 = 0;
    while (fi < module.num_funcs) {
      let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
      if (fn_len == nm_len && fn_len > 0) {
        let fn_name: u8[256] = [];
        let matched: i32 = 1;
        let bi: i32 = 0;
        pipeline_module_func_name_copy64(module, fi, &fn_name[0]);
        while (bi < fn_len) {
          if (fn_name[bi] != nm[bi]) {
            matched = 0;
            bi = fn_len;
          } else {
            bi = bi + 1;
          }
        }
        if (matched != 0) {
          return fi;
        }
      }
      fi = fi + 1;
    }
    return -1;
  }
}

/** Exported function `codegen_resolve_binding_import_dep_index`.
 * Implements `codegen_resolve_binding_import_dep_index`.
 * @param ctx *PipelineDepCtx
 * @param arena *ASTArena
 * @param callee_expr_ref i32
 * @return i32
 */
export function codegen_resolve_binding_import_dep_index(ctx: *PipelineDepCtx, arena: *ASTArena, callee_expr_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || arena == 0 as *ASTArena || ctx.current_codegen_module == 0 as *Module) {
      return -1;
    }
    if (ast.ref_is_null(callee_expr_ref) || callee_expr_ref <= 0 || callee_expr_ref > arena.num_exprs) {
      return -1;
    }
    let callee_e: Expr = ast.ast_arena_expr_get(arena, callee_expr_ref);
    if ((callee_e.kind as i32) != (ExprKind.EXPR_FIELD_ACCESS as i32) || callee_e.field_access_base_ref <= 0 || callee_e.field_access_base_ref > arena.num_exprs) {
      return -1;
    }
    let base_e: Expr = ast.ast_arena_expr_get(arena, callee_e.field_access_base_ref);
    if ((base_e.kind as i32) != (ExprKind.EXPR_VAR as i32) || base_e.var_name_len <= 0 || base_e.var_name_len > 255) {
      return -1;
    }
    let cur_mod: *Module = ctx.current_codegen_module;
    let nd: i32 = pipeline_dep_ctx_ndep(ctx);
    let j: i32 = 0;
    let n_imp: i32 = codegen_module_num_imports(cur_mod);
    while (j < n_imp && j < nd) {
      if (pipeline_module_import_kind_at(cur_mod, j) == 1) {
        let bind_len: i32 = pipeline_module_import_binding_name_len(cur_mod, j);
        if (bind_len == base_e.var_name_len) {
          let matched: i32 = 1;
          let kk: i32 = 0;
          while (kk < bind_len) {
            if (base_e.var_name[kk] != pipeline_module_import_binding_name_byte_at(cur_mod, j, kk)) {
              matched = 0;
              kk = bind_len;
            } else {
              kk = kk + 1;
            }
          }
          if (matched != 0) {
            let import_path: u8[256] = [];
            let import_path_len: i32 = codegen_module_import_path_len_at(cur_mod, j, &import_path[0]);
            if (import_path_len <= 0) {
              return -1;
            }
            return codegen_find_dep_index_by_path(ctx, &import_path[0], import_path_len);
          }
        }
      }
      j = j + 1;
    }
    return -1;
  }
}

/** Exported function `codegen_find_module_func_index_by_name_overload`.
 * Implements `codegen_find_module_func_index_by_name_overload`.
 * Overload-aware fallback: when typeck did not set call_resolved_func_index (e.g. dep
 * module body not typeck'd), score same-name funcs by arg resolved_type vs param type
 * and pick the best. Falls back to first-match when no args or all scores tie.
 * Why: codegen_find_module_func_index_by_name returns the FIRST match by name, which is
 * wrong when a module has same-name overloads (std_simd mul Vec8i vs Vec4f). Without this,
 * dot(a:Vec4f,b:Vec4f) { return hsum(mul(a,b)); } emits the Vec8i mul (first) -> cc
 * "conflicting types". PLATFORM: SHARED.
 * @param arena *ASTArena
 * @param module *Module
 * @param call_expr_ref i32
 * @param nm *u8
 * @param nm_len i32
 * @return i32
 */
export function codegen_find_module_func_index_by_name_overload(arena: *ASTArena, module: *Module,
call_expr_ref: i32, nm: *u8, nm_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let fi: i32 = 0;
    let first_idx: i32 = -1;
    let best_idx: i32 = -1;
    let best_score: i32 = -1;
    let num_args: i32 = 0;
    if (module == 0 as *Module || nm == 0 as *u8 || nm_len <= 0) {
      return -1;
    }
    if (call_expr_ref > 0 && call_expr_ref <= arena.num_exprs) {
      num_args = pipeline_expr_call_num_args_at(arena, call_expr_ref);
    }
    while (fi < module.num_funcs) {
      let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
      if (fn_len == nm_len && fn_len > 0) {
        let fn_name: u8[256] = [];
        let matched: i32 = 1;
        let bi: i32 = 0;
        pipeline_module_func_name_copy64(module, fi, &fn_name[0]);
        while (bi < fn_len) {
          if (fn_name[bi] != nm[bi]) {
            matched = 0;
            bi = fn_len;
          } else {
            bi = bi + 1;
          }
        }
        if (matched != 0) {
          if (first_idx < 0) {
            first_idx = fi;
          }
          if (num_args > 0) {
            let np: i32 = pipeline_module_func_num_params_at(module, fi);
            if (np == num_args) {
              let ai: i32 = 0;
              let score: i32 = 0;
              let ok: i32 = 1;
              while (ai < num_args) {
                let arg_ref: i32 = pipeline_expr_call_arg_ref(arena, call_expr_ref, ai);
                let param_ty: i32 = pipeline_module_func_param_type_ref_at(module, fi, ai);
                let arg_ty: i32 = 0;
                let sc: i32 = 0;
                if (arg_ref <= 0) {
                  ok = 0;
                  break;
                }
                arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
                if (arg_ty > 0 && param_ty > 0 && pipeline_typeck_type_refs_equal_c(arena, arg_ty, param_ty) != 0) {
                  sc = 1000;
                } else if (arg_ty > 0 && param_ty > 0) {
                  let ak: i32 = pipeline_type_kind_ord_at(arena, arg_ty);
                  let pk: i32 = pipeline_type_kind_ord_at(arena, param_ty);
                  if (ak == pk && ak != 0) {
                    sc = 1;
                  } else {
                    sc = -1;
                  }
                } else {
                  sc = 0;
                }
                if (sc < 0) {
                  ok = 0;
                  break;
                }
                score = score + sc;
                ai = ai + 1;
              }
              if (ok != 0 && score > best_score) {
                best_score = score;
                best_idx = fi;
              }
            }
          }
        }
      }
      fi = fi + 1;
    }
    if (best_idx >= 0) {
      return best_idx;
    }
    return first_idx;
  }
}

/** Exported function `codegen_resolve_call_target_func_index`.
 * Implements `codegen_resolve_call_target_func_index`.
 * @param arena *ASTArena
 * @param module *Module
 * @param call_expr_ref i32
 * @return i32
 */
export function codegen_resolve_call_target_func_index(arena: *ASTArena, module: *Module, call_expr_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let func_ix: i32 = -1;
    if (module == 0 as *Module || arena == 0 as *ASTArena) {
      return -1;
    }
    func_ix = pipeline_expr_call_resolved_func_index_at(arena, call_expr_ref);
    if (func_ix >= 0 && func_ix < module.num_funcs) {
      return func_ix;
    }
    if (ast.ref_is_null(call_expr_ref) || call_expr_ref <= 0 || call_expr_ref > arena.num_exprs) {
      return -1;
    }
    let call_e: Expr = ast.ast_arena_expr_get(arena, call_expr_ref);
    if ((call_e.kind as i32) == (ExprKind.EXPR_CALL as i32)) {
      if (ast.ref_is_null(call_e.call_callee_ref) || call_e.call_callee_ref <= 0 || call_e.call_callee_ref > arena.num_exprs) {
        return -1;
      }
      let callee_e: Expr = ast.ast_arena_expr_get(arena, call_e.call_callee_ref);
      if ((callee_e.kind as i32) == (ExprKind.EXPR_VAR as i32) && callee_e.var_name_len > 0) {
        return codegen_find_module_func_index_by_name_overload(arena, module, call_expr_ref, &callee_e.var_name[0], callee_e.var_name_len);
      }
      if ((callee_e.kind as i32) == (ExprKind.EXPR_FIELD_ACCESS as i32) && callee_e.field_access_field_len > 0) {
        return codegen_find_module_func_index_by_name_overload(arena, module, call_expr_ref, &callee_e.field_access_field_name[0], callee_e.field_access_field_len);
      }
      return -1;
    }
    if ((call_e.kind as i32) == (ExprKind.EXPR_METHOD_CALL as i32) && call_e.method_call_name_len > 0) {
      return codegen_find_module_func_index_by_name_overload(arena, module, call_expr_ref, &call_e.method_call_name[0], call_e.method_call_name_len);
    }
    return -1;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function expr_var_matches_func_param_index(arena: *ASTArena, var_ref: i32, mod: *Module, func_index: i32, param_idx: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ast.ref_is_null(var_ref) || var_ref <= 0 || var_ref > arena.num_exprs) {
      return 0;
    }
    if (func_index < 0 || func_index >= mod.num_funcs) {
      return 0;
    }
    /* See implementation. */
    let np: i32 = pipeline_module_func_num_params_at(mod, func_index);
    if (param_idx < 0 || param_idx >= np) {
      return 0;
    }
    let base: Expr = ast.ast_arena_expr_get(arena, var_ref);
    if ((base.kind as i32) != (ExprKind.EXPR_VAR as i32)) {
      return 0;
    }
    let p_name_len: i32 = pipeline_module_func_param_name_len_at(mod, func_index, param_idx);
    if (p_name_len > 0) {
      let pname_buf: u8[256] = [];
      pipeline_module_func_param_name_copy32(mod, func_index, param_idx, &pname_buf[0]);
      if (pname_buf[0] > 32) {
        if (base.var_name_len != p_name_len) {
          return 0;
        }
        if (base.var_name_len <= 0 || (base.var_name[0] <= 32)) {
          return 0;
        }
        let j: i32 = 0;
        while (j < p_name_len) {
          if (base.var_name[j] != pname_buf[j]) {
            return 0;
          }
          j = j + 1;
        }
        return 1;
      }
    }
    if (ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    if (ctx.current_func_single_empty_param_index != param_idx) {
      return 0;
    }
    if (base.var_name_len <= 0 || (base.var_name[0] <= 32)) {
      return 1;
    }
    return 0;
  }
}

/** Exported function `codegen_symbuf_bytes_eq`.
 * Implements `codegen_symbuf_bytes_eq`.
 * @param buf *u8
 * @param buf_len i32
 * @param lit *u8
 * @param lit_len i32
 * @return i32
 */
export function codegen_symbuf_bytes_eq(buf: *u8, buf_len: i32, lit: *u8, lit_len: i32): i32 {
  if (buf == 0 as *u8 || lit == 0 as *u8 || buf_len != lit_len) {
    return 0;
  }
  let i: i32 = 0;
  while (i < lit_len) {
    if (buf[i] != lit[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_call_num_args_override(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, num_args: i32): i32 {
  if (num_args <= 0) {
    return num_args;
  }
  let buf: u8[96] = [];
  let full: i32 = 0;
  let i: i32 = 0;
  if (prefix != 0 as *u8 && prefix_len > 0) {
    i = 0;
    while (i < prefix_len && full < 96) {
      buf[full] = prefix[i];
      full = full + 1;
      i = i + 1;
    }
  }
  if (name != 0 as *u8 && name_len > 0) {
    i = 0;
    while (i < name_len && full < 96) {
      buf[full] = name[i];
      full = full + 1;
      i = i + 1;
    }
  }
  let z0: u8[13] = [118,101,99,95,108,101,110,95,101,109,112,116,121];
  let z1: u8[21] = [115,116,100,95,118,101,99,95,118,101,99,95,108,101,110,95,101,109,112,116,121];
  let z2: u8[15] = [97,108,108,111,99,95,115,105,122,101,95,122,101,114,111];
  let z3: u8[24] = [115,116,100,95,104,101,97,112,95,97,108,108,111,99,95,115,105,122,101,95,122,101,114,111];
  let z4: u8[13] = [114,117,110,116,105,109,101,95,114,101,97,100,121];
  let z5: u8[25] = [115,116,100,95,114,117,110,116,105,109,101,95,114,117,110,116,105,109,101,95,114,101,97,100,121];
  let z6: u8[10] = [115,116,114,105,110,103,95,110,101,119];
  let z7: u8[21] = [115,116,100,95,115,116,114,105,110,103,95,115,116,114,105,110,103,95,110,101,119];
  let z8: u8[11] = [112,108,97,99,101,104,111,108,100,101,114];
  let z9: u8[22] = [115,116,100,95,115,116,114,105,110,103,95,112,108,97,99,101,104,111,108,100,101,114];
  let z10: u8[11] = [116,104,114,101,97,100,95,115,101,108,102];
  let z11: u8[22] = [115,116,100,95,116,104,114,101,97,100,95,116,104,114,101,97,100,95,115,101,108,102];
  let z12: u8[22] = [116,104,114,101,97,100,95,100,117,109,109,121,95,101,110,116,114,121,95,112,116,114];
  let z13: u8[33] = [115,116,100,95,116,104,114,101,97,100,95,116,104,114,101,97,100,95,100,117,109,109,121,95,101,110,116,114,121,95,112,116,114];
  let z14: u8[16] = [110,111,119,95,109,111,110,111,116,111,110,105,99,95,110,115];
  let z15: u8[25] = [115,116,100,95,116,105,109,101,95,110,111,119,95,109,111,110,111,116,111,110,105,99,95,110,115];
  let z16: u8[16] = [110,111,119,95,109,111,110,111,116,111,110,105,99,95,109,115];
  let z17: u8[25] = [115,116,100,95,116,105,109,101,95,110,111,119,95,109,111,110,111,116,111,110,105,99,95,109,115];
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z0[0], 13) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z1[0], 21) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z2[0], 15) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z3[0], 24) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z4[0], 13) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z5[0], 25) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z6[0], 10) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z7[0], 21) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z8[0], 11) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z9[0], 22) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z10[0], 11) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z11[0], 22) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z12[0], 22) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z13[0], 33) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z14[0], 16) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z15[0], 25) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z16[0], 16) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z17[0], 25) != 0) {
    return 0;
  }
  if (num_args >= 1) {
    let o0: u8[7] = [102,109,116,95,105,51,50];
    let o1: u8[16] = [99,111,114,101,95,102,109,116,95,102,109,116,95,105,51,50];
    let o2: u8[9] = [112,114,105,110,116,95,105,51,50];
    let o3: u8[16] = [115,116,100,95,105,111,95,112,114,105,110,116,95,105,51,50];
    let o4: u8[9] = [112,114,105,110,116,95,117,51,50];
    let o5: u8[16] = [115,116,100,95,105,111,95,112,114,105,110,116,95,117,51,50];
    let o6: u8[9] = [112,114,105,110,116,95,105,54,52];
    let o7: u8[16] = [115,116,100,95,105,111,95,112,114,105,110,116,95,105,54,52];
    let o8: u8[6] = [111,107,95,105,51,50];
    let o9: u8[18] = [99,111,114,101,95,114,101,115,117,108,116,95,111,107,95,105,51,50];
    let o10: u8[7] = [101,114,114,95,105,51,50];
    let o11: u8[19] = [99,111,114,101,95,114,101,115,117,108,116,95,101,114,114,95,105,51,50];
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o0[0], 7) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o1[0], 16) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o2[0], 9) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o3[0], 16) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o4[0], 9) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o5[0], 16) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o6[0], 9) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o7[0], 16) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o8[0], 6) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o9[0], 18) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o10[0], 7) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o11[0], 19) != 0) {
      return 1;
    }
  }
  return num_args;
}

/**
 * See implementation.
 */
export function codegen_name_bytes_prefix_eq(name: *u8, name_len: i32, expect: *u8, exp_len: i32): i32 {
  if (name == 0 as *u8 || expect == 0 as *u8 || name_len < exp_len) {
    return 0;
  }
  let i: i32 = 0;
  while (i < exp_len) {
    if (name[i] != expect[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_is_std_io_driver_bridge_name(name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8) {
    return 0;
  }
  /* register — 8 */
  let nm8: u8[8] = [114, 101, 103, 105, 115, 116, 101, 114];
  if ((name_len == 8 || name_len == 9) && codegen_name_bytes_prefix_eq(name, name_len, &nm8[0], 8) != 0) {
    return 1;
  }
  /* submit_read — 11 */
  let nm11: u8[11] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
  if ((name_len == 11 || name_len == 12) && codegen_name_bytes_prefix_eq(name, name_len, &nm11[0], 11) != 0) {
    return 1;
  }
  /* submit_write — 12 */
  let nm12: u8[12] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
  if ((name_len == 12 || name_len == 13) && codegen_name_bytes_prefix_eq(name, name_len, &nm12[0], 12) != 0) {
    return 1;
  }
  /* wait_readable — 13 */
  let nm13: u8[13] = [119, 97, 105, 116, 95, 114, 101, 97, 100, 97, 98, 108, 101];
  if ((name_len == 13 || name_len == 14) && codegen_name_bytes_prefix_eq(name, name_len, &nm13[0], 13) != 0) {
    return 1;
  }
  /* register_fixed_buffers — 22 */
  let nm22: u8[22] = [114, 101, 103, 105, 115, 116, 101, 114, 95, 102, 105, 120, 101, 100, 95, 98, 117, 102, 102, 101, 114, 115];
  if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, &nm22[0], 22) != 0) {
    return 1;
  }
  /* See implementation. */
  return 0;
}

/**
 * Skip emitting std.io.core bodies that duplicate runtime/io.o strong symbols.
 *
 * Purpose: when product C co-emits std.io.core, do not redefine xlang_io_read_fixed
 * (and siblings) that product preamble already provides as weak stubs / io.o.
 *
 * Parameters:
 *   dep_path  — module path bytes; must start with "std.io.core" (11 bytes).
 *   name      — bare function name (no module prefix).
 *   name_len  — name length; allow exact or exact+1 (historical trailing-NUL window).
 *
 * Returns 1 to skip emit, 0 to emit.
 *
 * Contract: match tables use full "xlang_io_*" (with 'x'), never historic shu-prefixed io brand.
 * Batch names are checked before short submit_read/write prefixes.
 * PLATFORM: SHARED — link-name contract; Cap force + pin product matrix.
 */
export function codegen_should_skip_emit_std_io_core_io_dup(dep_path: *u8, name: *u8, name_len: i32): i32 {
  let path_core: u8[11] = [115, 116, 100, 46, 105, 111, 46, 99, 111, 114, 101];
  /* xlang_io_read_fixed — 18 (preamble weak returns -1; avoid redef with weak). */
  let n_rf: u8[19] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 114, 101, 97, 100, 95, 102, 105, 120, 101, 100];
  /* xlang_io_write_fixed — 19 */
  let n_wf: u8[20] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 119, 114, 105, 116, 101, 95, 102, 105, 120, 101, 100];
  /*
   * See implementation.
   * See implementation.
   * See implementation.
   * See implementation.
   * See implementation.
   * Do NOT skip xlang_io_submit_write either (no weak; Cap force hello residual).
   * PLATFORM: SHARED — product C path; Cap force + pin seed.
   */
  let di: i32 = 0;
  if (dep_path == 0 as *u8 || name == 0 as *u8) {
    return 0;
  }
  while (di < 11) {
    if (dep_path[di] != path_core[di]) {
      return 0;
    }
    di = di + 1;
  }
  if ((name_len == 18 || name_len == 19) && codegen_name_bytes_prefix_eq(name, name_len, &n_rf[0], 18) != 0) {
    return 1;
  }
  if ((name_len == 19 || name_len == 20) && codegen_name_bytes_prefix_eq(name, name_len, &n_wf[0], 19) != 0) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_should_skip_emit_std_io_trivial_handle(dep_path: *u8, name: *u8, name_len: i32): i32 {
  let path_io: u8[7] = [115, 116, 100, 46, 105, 111, 0];
  let h_stdin: u8[12] = [104, 97, 110, 100, 108, 101, 95, 115, 116, 100, 105, 110];
  let h_stdout: u8[13] = [104, 97, 110, 100, 108, 101, 95, 115, 116, 100, 111, 117, 116];
  let h_stderr: u8[13] = [104, 97, 110, 100, 108, 101, 95, 115, 116, 100, 101, 114, 114];
  let h_from_fd: u8[15] = [104, 97, 110, 100, 108, 101, 95, 102, 114, 111, 109, 95, 102, 100, 0];
  let di: i32 = 0;
  if (name == 0 as *u8) {
    return 0;
  }
  if (dep_path != 0 as *u8) {
    while (di < 7) {
      if (dep_path[di] != path_io[di]) {
        return 0;
      }
      di = di + 1;
    }
  }
  if ((name_len == 12 || name_len == 13) && codegen_name_bytes_prefix_eq(name, name_len, &h_stdin[0], 12) != 0) {
    return 1;
  }
  if ((name_len == 13 || name_len == 14) && codegen_name_bytes_prefix_eq(name, name_len, &h_stdout[0], 13) != 0) {
    return 1;
  }
  if ((name_len == 13 || name_len == 14) && codegen_name_bytes_prefix_eq(name, name_len, &h_stderr[0], 13) != 0) {
    return 1;
  }
  if ((name_len == 15 || name_len == 16) && codegen_name_bytes_prefix_eq(name, name_len, &h_from_fd[0], 15) != 0) {
    return 1;
  }
  return 0;
}

/**
 * wave377/wave681 Cap residual pure: same-module true redefinition first-wins body emit.
 * Host C rejects two strong definitions of the same link name (BLD001). Skip a later
 * non-extern body only when it is a true redefinition of an earlier non-extern body:
 * same surface name, same arity, structurally equal param types, and structurally equal
 * return type.
 * True overloads (e.g. pick(i32) vs pick(i64)) share name+arity but differ in param
 * types and mangle to distinct host symbols — they must still be emitted (wave383:
 * name+arity-only skip dropped overload_pick_i64 → types gate link UNDEF).
 *
 * wave681 root fix: each parse site allocates a distinct type_ref slot even for the same
 * surface type (`i32`, `S`). Comparing type_ref **identity** only worked for zero-param
 * redefs; one-param free funcs and same-impl methods both emitted host bodies → BLD001.
 * Authority: `pipeline_typeck_type_refs_equal_c` structural equality (G.7 complete same
 * helper; no second type-compare path).
 *
 * @param arena *ASTArena — type pool for structural type_refs_equal (null → identity fallback)
 * @param module *Module — current module (null → 0)
 * @param fi i32 — candidate function index
 * @return i32 — 1 skip (superseded by earlier same-signature body); 0 emit this body
 * PLATFORM: SHARED — host-C body emit path; methods and free funcs share this gate.
 */
export function codegen_should_skip_later_same_name_body(arena: *ASTArena, module: *Module, fi: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (module == 0 as *Module || fi <= 0) {
      return 0;
    }
    if (pipeline_module_func_is_extern_at(module, fi) != 0) {
      return 0;
    }
    let nlen: i32 = pipeline_module_func_name_len_at(module, fi);
    if (nlen <= 0 || nlen > 255) {
      return 0;
    }
    let name: u8[256] = [];
    pipeline_module_func_name_copy64(module, fi, &name[0]);
    let np: i32 = pipeline_module_func_num_params_at(module, fi);
    let ret_fi: i32 = pipeline_module_func_return_type_at(module, fi);
    let j: i32 = 0;
    while (j < fi) {
      if (pipeline_module_func_is_extern_at(module, j) == 0) {
        let jlen: i32 = pipeline_module_func_name_len_at(module, j);
        if (jlen == nlen && pipeline_module_func_num_params_at(module, j) == np) {
          let jname: u8[256] = [];
          pipeline_module_func_name_copy64(module, j, &jname[0]);
          let eq: i32 = 1;
          let k: i32 = 0;
          while (k < nlen) {
            if (name[k] != jname[k]) {
              eq = 0;
            }
            k = k + 1;
          }
          // Same name+arity is not enough: compare param types (true redef vs overload).
          // wave681: structural equality — identity of type_ref slots is not stable across
          // two parse sites of the same surface type (method get(self:S) twice, f(x:i32) twice).
          if (eq != 0) {
            let pi: i32 = 0;
            while (pi < np) {
              let ta: i32 = pipeline_module_func_param_type_ref_at(module, fi, pi);
              let tb: i32 = pipeline_module_func_param_type_ref_at(module, j, pi);
              if (arena != 0 as *ASTArena) {
                if (pipeline_typeck_type_refs_equal_c(arena, ta, tb) == 0) {
                  eq = 0;
                }
              } else {
                if (ta != tb) {
                  eq = 0;
                }
              }
              pi = pi + 1;
            }
          }
          // Return type must also match for true redefinition (host mangle may omit ret
          // when only one param-sig overload exists — same link name if params equal).
          if (eq != 0) {
            let ret_j: i32 = pipeline_module_func_return_type_at(module, j);
            if (arena != 0 as *ASTArena) {
              if (pipeline_typeck_type_refs_equal_c(arena, ret_fi, ret_j) == 0) {
                eq = 0;
              }
            } else {
              if (ret_fi != ret_j) {
                eq = 0;
              }
            }
          }
          if (eq != 0) {
            return 1;
          }
        }
      }
      j = j + 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function codegen_should_skip_emit_func(dep_path: *u8, prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32 {
  /* See implementation. */
  let full33: u8[33] = [115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110];
  let full29: u8[29] = [115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114];
  /* See implementation. */
  let path_driver: u8[14] = [115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0];
  let path_io: u8[7] = [115, 116, 100, 46, 105, 111, 0];
  /* See implementation. */
  let nm_len19: u8[19] = [100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110];
  let nm_len15: u8[15] = [100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114];
  /* driver_read_ptr_gen — 19 (same length as ptr_len; distinct suffix) */
  let nm_gen19: u8[19] = [100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 103, 101, 110];
  let pi: i32 = 0;
  let ni: i32 = 0;
  let ok_path: i32 = 0;
  let di: i32 = 0;
  /* full33_gen: std_io_driver_driver_read_ptr_gen (33) — same length as ptr_len; must not early-return 0 on mismatch. */
  let full33_gen: u8[33] = [115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 103, 101, 110];
  if (prefix != 0 as *u8 && prefix_len > 0 && name != 0 as *u8 && name_len > 0) {
    let total_len: i32 = prefix_len + name_len;
    if (total_len == 33) {
      let match_len: i32 = 1;
      let match_gen: i32 = 1;
      pi = 0;
      while (pi < prefix_len) {
        if (prefix[pi] != full33[pi]) {
          match_len = 0;
        }
        if (prefix[pi] != full33_gen[pi]) {
          match_gen = 0;
        }
        pi = pi + 1;
      }
      ni = 0;
      while (ni < name_len) {
        if (name[ni] != full33[prefix_len + ni]) {
          match_len = 0;
        }
        if (name[ni] != full33_gen[prefix_len + ni]) {
          match_gen = 0;
        }
        ni = ni + 1;
      }
      if (match_len != 0 || match_gen != 0) {
        return 1;
      }
      /* fall through — other total-33 names are not auto-skipped */
    }
    if (total_len == 29) {
      pi = 0;
      while (pi < prefix_len) {
        if (prefix[pi] != full29[pi]) {
          /* fall through on mismatch (do not abort whole skip) */
          pi = prefix_len + 1;
          break;
        }
        pi = pi + 1;
      }
      if (pi == prefix_len) {
        ni = 0;
        while (ni < name_len) {
          if (name[ni] != full29[prefix_len + ni]) {
            ni = name_len + 1;
            break;
          }
          ni = ni + 1;
        }
        if (ni == name_len) {
          return 1;
        }
      }
    }
  }
  if (dep_path != 0 as *u8) {
    ok_path = 0;
    di = 0;
    while (di < 14) {
      if (dep_path[di] != path_driver[di]) {
        ok_path = 0;
        break;
      }
      di = di + 1;
    }
    if (di == 14) {
      ok_path = 1;
    }
    if (ok_path == 0) {
      di = 0;
      while (di < 7) {
        if (dep_path[di] != path_io[di]) {
          ok_path = 0;
          break;
        }
        di = di + 1;
      }
      if (di == 7) {
        ok_path = 1;
      }
    }
    if (ok_path != 0 && name != 0 as *u8) {
      if ((name_len == 19 || name_len == 20) && codegen_name_bytes_prefix_eq(name, name_len, &nm_len19[0], 19) != 0) {
        return 1;
      }
      if ((name_len == 19 || name_len == 20) && codegen_name_bytes_prefix_eq(name, name_len, &nm_gen19[0], 19) != 0) {
        return 1;
      }
      if ((name_len == 15 || name_len == 16) && codegen_name_bytes_prefix_eq(name, name_len, &nm_len15[0], 15) != 0) {
        return 1;
      }
    }
  }
  /* See implementation. */
  let pref_abi14: u8[14] = [115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95];
  if (prefix != 0 as *u8 && prefix_len == 14 && name != 0 as *u8 && codegen_name_bytes_prefix_eq(prefix, prefix_len, &pref_abi14[0], 14) != 0) {
    if (codegen_is_std_io_driver_bridge_name(name, name_len) != 0) {
      return 1;
    }
  }
  if (dep_path != 0 as *u8 && name != 0 as *u8) {
    let ok_drv_only: i32 = 0;
    di = 0;
    while (di < 14) {
      if (dep_path[di] != path_driver[di]) {
        ok_drv_only = 0;
        break;
      }
      di = di + 1;
    }
    if (di == 14) {
      ok_drv_only = 1;
    }
    if (ok_drv_only != 0 && codegen_is_std_io_driver_bridge_name(name, name_len) != 0) {
      return 1;
    }
  }
  /* See implementation. */
  if (prefix != 0 as *u8 && prefix_len == 14 && name != 0 as *u8
      && codegen_name_bytes_prefix_eq(prefix, prefix_len, &pref_abi14[0], 14) != 0) {
    if (codegen_should_skip_emit_std_io_trivial_handle(0 as *u8, name, name_len) != 0) {
      return 1;
    }
  }
  if (dep_path != 0 as *u8 && name != 0 as *u8) {
    if (codegen_should_skip_emit_std_io_core_io_dup(dep_path, name, name_len) != 0) {
      return 1;
    }
    let path_driver: u8[14] = [115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0];
    let di2: i32 = 0;
    while (di2 < 14) {
      if (dep_path[di2] != path_driver[di2]) {
        break;
      }
      di2 = di2 + 1;
    }
    if (di2 == 14 && codegen_should_skip_emit_std_io_trivial_handle(0 as *u8, name, name_len) != 0) {
      return 1;
    }
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_force_param_std_io_driver_prefix_ok(prefix: *u8, prefix_len: i32): i32 {
  let exp13: u8[13] = [115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114];
  if (prefix == 0 as *u8 || prefix_len < 13) {
    return 0;
  }
  let i: i32 = 0;
  while (i < 13) {
    if (prefix[i] != exp13[i]) {
      return 0;
    }
    i = i + 1;
  }
  if (prefix_len > 13) {
    let b14: u8 = prefix[13];
    if (b14 != 0 as u8 && b14 != 95 as u8) {
      return 0;
    }
  }
  return 1;
}

/**
 * See implementation.
 */
export function codegen_force_param_size_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  let rd_batch: u8[21] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102];
  let wr_batch: u8[22] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102];
  if (param_index != 0) {
    return 0;
  }
  if (codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len == 21 && codegen_name_bytes_prefix_eq(name, name_len, &rd_batch[0], 21) != 0) {
    return 1;
  }
  if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, &wr_batch[0], 22) != 0) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_force_param_size_t_std_io_print_str_second(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  if (param_index != 1) {
    return 0;
  }
  if (name == 0 as *u8 || name_len != 5) {
    return 0;
  }
  /* "print" */
  if (name[0] != 112 || name[1] != 114 || name[2] != 105 || name[3] != 110 || name[4] != 116) {
    return 0;
  }
  let exp7: u8[7] = [115, 116, 100, 95, 105, 111, 95];
  if (prefix == 0 as *u8 || prefix_len < 7) {
    return 0;
  }
  let i: i32 = 0;
  while (i < 7) {
    if (prefix[i] != exp7[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * See implementation.
 */
export function codegen_force_param_ptrdiff_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  let reg8: u8[8] = [114, 101, 103, 105, 115, 116, 101, 114];
  let rd11: u8[11] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
  let wr12: u8[12] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
  if (param_index != 0) {
    return 0;
  }
  if (codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len == 8 && codegen_name_bytes_prefix_eq(name, name_len, &reg8[0], 8) != 0) {
    return 1;
  }
  if (name_len == 11 && codegen_name_bytes_prefix_eq(name, name_len, &rd11[0], 11) != 0) {
    return 1;
  }
  if (name_len == 12 && codegen_name_bytes_prefix_eq(name, name_len, &wr12[0], 12) != 0) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 */
export function codegen_force_param_uint32_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  let rd11: u8[11] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
  let wr12: u8[12] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
  let reg_fixed_buf: u8[33] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 102, 105, 120, 101, 100, 95, 98, 117, 102, 102, 101, 114, 115, 95, 98, 117, 102];
  let rd_batch: u8[21] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102];
  let wr_batch: u8[22] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102];
  if (codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (param_index == 1) {
    if (name_len == 11 && codegen_name_bytes_prefix_eq(name, name_len, &rd11[0], 11) != 0) {
      return 1;
    }
    if (name_len == 12 && codegen_name_bytes_prefix_eq(name, name_len, &wr12[0], 12) != 0) {
      return 1;
    }
    if (name_len == 33 && codegen_name_bytes_prefix_eq(name, name_len, &reg_fixed_buf[0], 33) != 0) {
      return 1;
    }
    return 0;
  }
  if (param_index == 3) {
    if (name_len == 21 && codegen_name_bytes_prefix_eq(name, name_len, &rd_batch[0], 21) != 0) {
      return 1;
    }
    if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, &wr_batch[0], 22) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/**
 * See implementation.
 */
export function codegen_use_buf_wrapper(name: *u8, name_len: i32, num_args: i32): i32 {
  let reg15: u8[15] = [115, 104, 117, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114];
  let rd18: u8[18] = [115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
  let wr19: u8[19] = [115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
  if (name == 0 as *u8 || name_len <= 0) {
    return 0;
  }
  if (num_args == 1 && name_len == 15 && codegen_name_bytes_prefix_eq(name, name_len, &reg15[0], 15) != 0) {
    return 1;
  }
  if (num_args == 2 && name_len == 18 && codegen_name_bytes_prefix_eq(name, name_len, &rd18[0], 18) != 0) {
    return 1;
  }
  if (num_args == 2 && name_len == 19 && codegen_name_bytes_prefix_eq(name, name_len, &wr19[0], 19) != 0) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_emit_io_driver_buf_call_name(out: *CodegenOutBuf, name: *u8, name_len: i32, num_args: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let reg8: u8[8] = [114, 101, 103, 105, 115, 116, 101, 114];
    let rd11: u8[11] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
    let wr12: u8[12] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
    /* See implementation. */
    let sym_reg: u8[21] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 98, 117, 102];
    let sym_rd: u8[24] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 117, 102];
    let sym_wr: u8[25] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 117, 102];
    if (name == 0 as *u8 || name_len <= 0) {
      return 0;
    }
    if (num_args == 1 && name_len == 8 && codegen_name_bytes_prefix_eq(name, name_len, &reg8[0], 8) != 0) {
      /* PLATFORM: SHARED — sym_reg is 21 bytes ("xlang_io_register_buf"). wave323 */
      if (codegen_emit_bytes_from_ptr(out, &sym_reg[0], 21) != 0) {
        return -1;
      }
      return 1;
    }
    if (num_args == 2 && name_len == 11 && codegen_name_bytes_prefix_eq(name, name_len, &rd11[0], 11) != 0) {
      /* PLATFORM: SHARED — sym_rd is 24 bytes ("xlang_io_submit_read_buf"); 23 truncates to _bu. wave323 */
      if (codegen_emit_bytes_from_ptr(out, &sym_rd[0], 24) != 0) {
        return -1;
      }
      return 1;
    }
    if (num_args == 2 && name_len == 12 && codegen_name_bytes_prefix_eq(name, name_len, &wr12[0], 12) != 0) {
      /* PLATFORM: SHARED — sym_wr is 25 bytes ("xlang_io_submit_write_buf"). wave323 */
      if (codegen_emit_bytes_from_ptr(out, &sym_wr[0], 25) != 0) {
        return -1;
      }
      return 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_try_emit_std_io_driver_buf_body(out: *CodegenOutBuf, module: *Module, fi: i32, prefix: *u8, prefix_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let fn_local: u8[256] = [];
    let fn_len: i32 = 0;
    let nparams: i32 = 0;
    /* wave585 Cap residual: param name scratch 32→128 for *copy32 payload. */
    let p0: u8[256] = [];
    let p1: u8[256] = [];
    let reg8: u8[8] = [114, 101, 103, 105, 115, 116, 101, 114];
    let rd11: u8[11] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
    let wr12: u8[12] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
    let sym_reg: u8[21] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 98, 117, 102];
    let sym_rd: u8[24] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 117, 102];
    let sym_wr: u8[25] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 117, 102];
    let ret_kw: u8[8] = [32, 32, 114, 101, 116, 117, 114, 110];
    let close_b: u8[3] = [10, 125, 0];
    if (codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {
      return 0;
    }
    let p0_len: i32 = 3;
    let p1_len: i32 = 10;
    /* Default short names "buf" / "timeout_ms" (std.io.driver helpers). */
    p0[0] = 98; p0[1] = 117; p0[2] = 102;
    p1[0] = 116; p1[1] = 105; p1[2] = 109; p1[3] = 101; p1[4] = 111; p1[5] = 117;
    p1[6] = 116; p1[7] = 95; p1[8] = 109; p1[9] = 115;
    pipeline_module_func_name_copy64(module, fi, &fn_local[0]);
    fn_len = pipeline_module_func_name_len_at(module, fi);
    nparams = pipeline_module_func_num_params_at(module, fi);
    if (pipeline_module_func_param_name_len_at(module, fi, 0) > 0) {
      pipeline_module_func_param_name_copy32(module, fi, 0, &p0[0]);
      p0_len = pipeline_module_func_param_name_len_at(module, fi, 0);
    }
    if (nparams > 1 && pipeline_module_func_param_name_len_at(module, fi, 1) > 0) {
      pipeline_module_func_param_name_copy32(module, fi, 1, &p1[0]);
      p1_len = pipeline_module_func_param_name_len_at(module, fi, 1);
    }
    if (fn_len == 8 && codegen_name_bytes_prefix_eq(&fn_local[0], fn_len, &reg8[0], 8) != 0 && nparams == 1) {
      if (codegen_emit_indent(out, 2) != 0) { return -1; }
      if (codegen_emit_bytes_from_ptr(out, &ret_kw[0], 8) != 0) { return -1; }
      /* PLATFORM: SHARED — sym_reg 21 bytes (wave323). */
      if (codegen_emit_bytes_from_ptr(out, &sym_reg[0], 21) != 0) { return -1; }
      if (codegen_append_byte(out, 40) != 0) { return -1; }
      if (codegen_emit_bytes_from_ptr(out, &p0[0], p0_len) != 0) { return -1; }
      if (codegen_append_byte(out, 41) != 0) { return -1; }
      if (codegen_append_byte(out, 59) != 0) { return -1; }
      if (codegen_emit_bytes_from_ptr(out, &close_b[0], 2) != 0) { return -1; }
      return 1;
    }
    if (fn_len == 11 && codegen_name_bytes_prefix_eq(&fn_local[0], fn_len, &rd11[0], 11) != 0 && nparams == 2) {
      if (codegen_emit_indent(out, 2) != 0) { return -1; }
      if (codegen_emit_bytes_from_ptr(out, &ret_kw[0], 8) != 0) { return -1; }
      /* PLATFORM: SHARED — sym_rd length 24 (wave323 root: was 23 → _bu). */
      if (codegen_emit_bytes_from_ptr(out, &sym_rd[0], 24) != 0) { return -1; }
      if (codegen_append_byte(out, 40) != 0) { return -1; }
      if (codegen_emit_bytes_from_ptr(out, &p0[0], p0_len) != 0) { return -1; }
      let comma: u8[3] = [44, 32, 0];
      if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) { return -1; }
      if (codegen_emit_bytes_from_ptr(out, &p1[0], p1_len) != 0) { return -1; }
      if (codegen_append_byte(out, 41) != 0) { return -1; }
      if (codegen_append_byte(out, 59) != 0) { return -1; }
      if (codegen_emit_bytes_from_ptr(out, &close_b[0], 2) != 0) { return -1; }
      return 1;
    }
    if (fn_len == 12 && codegen_name_bytes_prefix_eq(&fn_local[0], fn_len, &wr12[0], 12) != 0 && nparams == 2) {
      if (codegen_emit_indent(out, 2) != 0) { return -1; }
      if (codegen_emit_bytes_from_ptr(out, &ret_kw[0], 8) != 0) { return -1; }
      /* PLATFORM: SHARED — sym_wr 25 bytes (wave323). */
      if (codegen_emit_bytes_from_ptr(out, &sym_wr[0], 25) != 0) { return -1; }
      if (codegen_append_byte(out, 40) != 0) { return -1; }
      if (codegen_emit_bytes_from_ptr(out, &p0[0], p0_len) != 0) { return -1; }
      let comma2: u8[3] = [44, 32, 0];
      if (codegen_emit_bytes_3(out, &comma2[0], 2) != 0) { return -1; }
      if (codegen_emit_bytes_from_ptr(out, &p1[0], p1_len) != 0) { return -1; }
      if (codegen_append_byte(out, 41) != 0) { return -1; }
      if (codegen_append_byte(out, 59) != 0) { return -1; }
      if (codegen_emit_bytes_from_ptr(out, &close_b[0], 2) != 0) { return -1; }
      return 1;
    }
    return 0;
  }
}

/** Exported function `field_access_base_is_pointer_ref`.
 * Implements `field_access_base_is_pointer_ref`.
 * @param arena *ASTArena
 * @param base_ref i32
 * @return i32
 */
export function field_access_base_is_pointer_ref(arena: *ASTArena, base_ref: i32): i32 {
  if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
    return 0;
  }
  let base: Expr = ast.ast_arena_expr_get(arena, base_ref);
  if (ast.ref_is_null(base.resolved_type_ref) || base.resolved_type_ref <= 0 || base.resolved_type_ref > arena.num_types) {
    return 0;
  }
  let ty: Type = ast.ast_arena_type_get(arena, base.resolved_type_ref);
  if ((ty.kind as i32) == (TypeKind.TYPE_PTR as i32)) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function field_access_base_type_resolved(arena: *ASTArena, base_ref: i32): i32 {
  if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
    return 0;
  }
  let base: Expr = ast.ast_arena_expr_get(arena, base_ref);
  if (ast.ref_is_null(base.resolved_type_ref) || base.resolved_type_ref <= 0 || base.resolved_type_ref > arena.num_types) {
    return 0;
  }
  return 1;
}

/**
 * PLATFORM: SHARED — C mirror of asm glue_asm_try_emit_fmt_string_lit_import_call.
 *
 * Product contract (std.fmt README): `print("…")` / `println("…")` single string
 * literal is a compiler specialization → call print/println(ptr, len) with the
 * literal length. Asm backend already does this; C must not fall through to the
 * bare `std_fmt_println(u8[]*)` overload with a raw pointer (empty stdout / UB).
 *
 * Returns: 1 if this call was fully emitted; 0 if not applicable; -1 on emit error.
 */
export function codegen_try_emit_fmt_string_lit_call(arena: *ASTArena, out: *CodegenOutBuf,
expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    let callee_ref: i32 = 0;
    let callee: Expr = e;
    let path: u8[128] = [];
    let path_len: i32 = 0;
    let pre: u8[256] = [];
    let pre_len: i32 = 0;
    let name_ptr: *u8 = 0 as *u8;
    let name_len: i32 = 0;
    let arg_ref: i32 = 0;
    let arg: Expr = e;
    let slen: i32 = 0;
    let mid: u8[12] = [95, 117, 56, 95, 112, 116, 114, 95, 105, 51, 50, 0]; /* _u8_ptr_i32 */
    let comma: u8[3] = [44, 32, 0];
    let is_method: i32 = 0;
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    e = ast.ast_arena_expr_get(arena, expr_ref);
    /*
     * Product surface is binding.print/println("…"):
     * - METHOD_CALL: fmt.println("…")  (parser default)
     * - CALL + FIELD_ACCESS callee: fmt.println as callee (alt shape)
     */
    if ((e.kind as i32) == (ExprKind.EXPR_METHOD_CALL as i32) && e.method_call_num_args == 1
        && e.method_call_name_len > 0) {
      is_method = 1;
      name_len = e.method_call_name_len;
      name_ptr = &e.method_call_name[0];
      path_len = codegen_resolve_binding_import_path_for_method_call(ctx, arena, expr_ref, &path[0]);
      arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, 0);
    } else if ((e.kind as i32) == (ExprKind.EXPR_CALL as i32) && e.call_num_args == 1) {
      callee_ref = e.call_callee_ref;
      if (callee_ref <= 0 || callee_ref > arena.num_exprs) {
        return 0;
      }
      callee = ast.ast_arena_expr_get(arena, callee_ref);
      if ((callee.kind as i32) != (ExprKind.EXPR_FIELD_ACCESS as i32) || callee.field_access_field_len <= 0) {
        return 0;
      }
      name_len = callee.field_access_field_len;
      name_ptr = &callee.field_access_field_name[0];
      path_len = codegen_resolve_binding_import_path_for_field_access(ctx, arena, callee_ref, &path[0]);
      arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
    } else {
      return 0;
    }
    /* println / print */
    if (name_len == 7 && name_ptr[0] == 112 && name_ptr[1] == 114 && name_ptr[2] == 105
        && name_ptr[3] == 110 && name_ptr[4] == 116 && name_ptr[5] == 108 && name_ptr[6] == 110) {
      /* println */
    } else if (name_len == 5 && name_ptr[0] == 112 && name_ptr[1] == 114 && name_ptr[2] == 105
        && name_ptr[3] == 110 && name_ptr[4] == 116) {
      /* print */
    } else {
      return 0;
    }
    if (path_len <= 0) {
      return 0;
    }
    /* std.fmt (7) or std.debug (9) */
    if (path_len == 7 && path[0] == 115 && path[1] == 116 && path[2] == 100 && path[3] == 46
        && path[4] == 102 && path[5] == 109 && path[6] == 116) {
      /* ok */
    } else if (path_len == 9 && path[0] == 115 && path[1] == 116 && path[2] == 100 && path[3] == 46
        && path[4] == 100 && path[5] == 101 && path[6] == 98 && path[7] == 117 && path[8] == 103) {
      /* ok */
    } else {
      return 0;
    }
    if (arg_ref <= 0 || arg_ref > arena.num_exprs) {
      return 0;
    }
    if (pipeline_expr_kind_ord_at(arena, arg_ref) != 59) {
      return 0;
    }
    arg = ast.ast_arena_expr_get(arena, arg_ref);
    slen = arg.var_name_len;
    if (slen < 0) {
      slen = 0;
    }
    if (slen > 64) {
      slen = 64;
    }
    codegen_import_path_to_c_prefix_into(&path[0], &pre[0], 128);
    pre_len = 0;
    while (pre_len < 128 && pre[pre_len] != 0 as u8) {
      pre_len = pre_len + 1;
    }
    if (pre_len <= 0) {
      return 0;
    }
    /* std_fmt_println_u8_ptr_i32( (uint8_t*)"…", N ) */
    if (codegen_emit_bytes_from_ptr(out, &pre[0], pre_len) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, name_ptr, name_len) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &mid[0], 11) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    if (codegen_emit_expr(arena, out, arg_ref, ctx) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
      return -1;
    }
    if (format_int(out, slen as i64) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 41) != 0) {
      return -1;
    }
    /* is_method is assigned but not read; XLANG has no unused-warning, so no
     * `(void)is_method;` C-style cast needed (such syntax hangs the parser). */
    return 1;
  }
}

/**
 * wave463 Cap residual (CORE-001): host-C intrinsic for `size_of<T>()` / `align_of<T>()`.
 *
 * Product surface (`core.types`):
 *   - free: `size_of<i32>()` / `align_of<Pair>()`
 *   - import-qualified: `types.size_of<i32>()` / `types.align_of<*u8>()`
 *
 * Root failure before this wave:
 *   1. Zero-param generics with type args only (ret is i32, not T) have
 *      `cw_mono = np + re = 0`, so call-site mono mangling is skipped → bare
 *      `core_types_size_of()` (undeclared → BLD001 on import path).
 *   2. Core stub body is `return 0`, so even same-module bare emit is wrong
 *      for layout (size_of<i32>() must be 4, not 0).
 *
 * Authority: expand at the CALL site to host C
 *   `((int32_t)(sizeof(TYPE)))` or `((int32_t)(_Alignof(TYPE)))`
 * using the turbofish type_arg type_ref (wave452 sidecar). Do not open a
 * second mono path for these layout builtins (G.7 single authority).
 *
 * @param arena *ASTArena — expr / type_arg sidecar
 * @param out *CodegenOutBuf — host-C text buffer
 * @param expr_ref i32 — EXPR_CALL site
 * @param ctx *PipelineDepCtx — codegen_emit_type needs module/struct prefix context
 * @return i32 — 1 fully emitted; 0 not applicable; -1 emit error
 * PLATFORM: SHARED host-C (C11 sizeof/_Alignof; gcc/clang product path)
 */
export function codegen_try_emit_size_align_of_call(arena: *ASTArena, out: *CodegenOutBuf,
expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    let callee_ref: i32 = 0;
    let callee: Expr = e;
    let name_ptr: *u8 = 0 as *u8;
    let name_len: i32 = 0;
    let is_size: i32 = 0;
    let is_align: i32 = 0;
    let n_ta: i32 = 0;
    let ta: i32 = 0;
    /* ((int32_t)(sizeof( */
    let open_sz: u8[18] = [40, 40, 105, 110, 116, 51, 50, 95, 116, 41, 40, 115, 105, 122, 101, 111, 102, 40];
    /* ((int32_t)(_Alignof( */
    let open_al: u8[20] = [40, 40, 105, 110, 116, 51, 50, 95, 116, 41, 40, 95, 65, 108, 105, 103, 110, 111, 102, 40];
    /* ))) */
    let close3: u8[4] = [41, 41, 41, 0];
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    e = ast.ast_arena_expr_get(arena, expr_ref);
    /* Zero value args; at least one type arg (turbofish or angle list). */
    if ((e.kind as i32) != (ExprKind.EXPR_CALL as i32) || e.call_num_args != 0) {
      return 0;
    }
    n_ta = pipeline_expr_call_num_type_args_at(arena, expr_ref);
    if (n_ta < 1) {
      return 0;
    }
    callee_ref = e.call_callee_ref;
    if (callee_ref <= 0 || callee_ref > arena.num_exprs) {
      return 0;
    }
    callee = ast.ast_arena_expr_get(arena, callee_ref);
    if ((callee.kind as i32) == (ExprKind.EXPR_FIELD_ACCESS as i32) && callee.field_access_field_len > 0) {
      name_ptr = &callee.field_access_field_name[0];
      name_len = callee.field_access_field_len;
    } else if ((callee.kind as i32) == (ExprKind.EXPR_VAR as i32) && callee.var_name_len > 0) {
      name_ptr = &callee.var_name[0];
      name_len = callee.var_name_len;
    } else {
      return 0;
    }
    /* Exact bare name: size_of (7) / align_of (8). Not size_of_i32 etc. */
    if (name_len == 7 && name_ptr[0] == 115 && name_ptr[1] == 105 && name_ptr[2] == 122
        && name_ptr[3] == 101 && name_ptr[4] == 95 && name_ptr[5] == 111 && name_ptr[6] == 102) {
      is_size = 1;
    } else if (name_len == 8 && name_ptr[0] == 97 && name_ptr[1] == 108 && name_ptr[2] == 105
        && name_ptr[3] == 103 && name_ptr[4] == 110 && name_ptr[5] == 95 && name_ptr[6] == 111
        && name_ptr[7] == 102) {
      is_align = 1;
    } else {
      return 0;
    }
    ta = pipeline_expr_call_type_arg_ref_at(arena, expr_ref, 0);
    if (ta <= 0) {
      return 0;
    }
    if (is_size != 0) {
      if (codegen_emit_bytes_from_ptr(out, &open_sz[0], 18) != 0) {
        return -1;
      }
    } else if (is_align != 0) {
      if (codegen_emit_bytes_from_ptr(out, &open_al[0], 20) != 0) {
        return -1;
      }
    } else {
      return 0;
    }
    /*
     * TYPE_ARRAY: bare codegen_emit_type lowers to `E *` (pointer decay for params/locals).
     * sizeof/_Alignof need the true fixed shape `E[N]…` (CORE-001 u8[4] → 4 / align 1).
     * Reuse wave357 local fixed-array peel + suffix (G.7; no third array emit path).
     */
    if (pipeline_type_kind_ord_at(arena, ta) == (TypeKind.TYPE_ARRAY as i32)) {
      if (codegen_emit_local_fixed_array_elem_type(arena, out, ta, ctx) != 0) {
        return -1;
      }
      if (codegen_emit_local_fixed_array_suffix(arena, out, ta) != 0) {
        return -1;
      }
    } else {
      /* Named struct / pointer / scalar — codegen_emit_type owns prefix resolve. */
      if (codegen_emit_type(arena, out, ta, 0 as *u8, 0, ctx) != 0) {
        return -1;
      }
    }
    if (codegen_emit_bytes_from_ptr(out, &close3[0], 3) != 0) {
      return -1;
    }
    return 1;
  }
}

/**
 * Host-C: set formal type_ref for the next emit_call_arg_slice_abi invocation.
 * wave395: TYPE_ARRAY → fat materialize only when formal is TYPE_SLICE (not *T).
 * Callers must set before each arg and clear (0) after. PLATFORM: SHARED host-C.
 */
export extern function codegen_set_host_call_arg_param_ty(param_ty_ref: i32): void;

/** Read host call-arg formal type_ref (0 = unknown / not slice formal). */
export extern function codegen_get_host_call_arg_param_ty(): i32;

/**
 * Allocate a unique id for host-C call-site TYPE_ARRAY deep-copy temps (`__xlang_caN`).
 * wave397: CALL/METHOD returning T[N] as TYPE_SLICE formal must not share callee
 * `__xlang_ar` across dual args in one call (last-wins → wrong sums).
 * @return i32 — non-negative monotonic id (wraps at i32 max → 0)
 * PLATFORM: SHARED host-C counter (seed body).
 */
export extern function codegen_next_host_call_array_tmp_id(): i32;

/**
 * Stage 10 S3.1 slice 1 (10.1.1): host-C raw syscall intrinsic for
 * `raw_syscall0..raw_syscall6(nr, a1..aN)` — Linux x86_64 kernel ABI.
 *
 * Product surface (`std.sys.linux`, cfg target_os="linux"):
 *   - import-qualified: `linux.raw_syscall3(1, fd, buf, len)` (write)
 *   - bare same-module calls also match (callee EXPR_VAR)
 *
 * Authority (G.7): expand at the CALL site to
 *   `((int64_t)(__xlang_raw_syscallN((long)(nr),(long)(a1),...)))`
 * — same single-authority shape as the wave463 size_of/align_of intrinsic;
 * do not open a second lowering path for syscalls. The static-inline helpers
 * (register constraints + `syscall`, clobber rcx/r11/memory) are emitted once
 * per TU by codegen_emit_raw_syscall_helpers behind
 * `#if linux && x86_64` / `#elif linux && aarch64`: the host cc preprocessor
 * is the platform truth (Darwin drops both; Ubuntu x86_64 takes syscall;
 * Linux aarch64 takes svc #0). The `.x` bodies in std.sys.linux panic —
 * asm intercept (10.1.1 x86_64 / 10.1.2 ELF aarch64) is the product `-o` path.
 *
 * @param arena *ASTArena — expr / callee slots
 * @param out *CodegenOutBuf — host-C text buffer
 * @param expr_ref i32 — EXPR_CALL site
 * @param ctx *PipelineDepCtx — arg emit context
 * @return i32 — 1 fully emitted; 0 not applicable; -1 emit error
 * PLATFORM: SHARED host-C emit; runtime LINUX x86_64 or LINUX aarch64 (#if helpers).
 */
export function codegen_try_emit_raw_syscall_call(arena: *ASTArena, out: *CodegenOutBuf,
expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    let callee_ref: i32 = 0;
    let callee: Expr = e;
    let name_ptr: *u8 = 0 as *u8;
    let name_len: i32 = 0;
    let arity: i32 = -1;
    let n_args: i32 = 0;
    let ai: i32 = 0;
    let pi: i32 = 0;
    let is_method: i32 = 0;
    let arg_ref: i32 = 0;
    /* ((int64_t)(__xlang_raw_syscall — arity digit + '(' appended after match. */
    let open_pre: u8[30] = [40, 40, 105, 110, 116, 54, 52, 95, 116, 41, 40, 95, 95, 120, 108, 97,
      110, 103, 95, 114, 97, 119, 95, 115, 121, 115, 99, 97, 108, 108];
    /* (long)( */
    let arg_open: u8[7] = [40, 108, 111, 110, 103, 41, 40];
    /* , */
    let comma_sp: u8[2] = [44, 32];
    /* ))) — close call paren, int64_t cast, outer wrap. */
    let close3: u8[3] = [41, 41, 41];
    /* raw_syscall — 11 prefix bytes; callee must be exactly raw_syscall<digit>. */
    let pfx: u8[11] = [114, 97, 119, 95, 115, 121, 115, 99, 97, 108, 108];
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    e = ast.ast_arena_expr_get(arena, expr_ref);
    /*
     * Dot calls parse as METHOD_CALL (kind 49, fmt.println default shape);
     * bare calls and the alt FIELD_ACCESS-callee shape are EXPR_CALL (48).
     * Both shapes name the same builtin and lower identically (fmt_lit twin).
     */
    if ((e.kind as i32) == (ExprKind.EXPR_METHOD_CALL as i32)) {
      if (e.method_call_name_len <= 0) {
        return 0;
      }
      name_ptr = &e.method_call_name[0];
      name_len = e.method_call_name_len;
      n_args = e.method_call_num_args;
      is_method = 1;
    } else if ((e.kind as i32) == (ExprKind.EXPR_CALL as i32)) {
      callee_ref = e.call_callee_ref;
      if (callee_ref <= 0 || callee_ref > arena.num_exprs) {
        return 0;
      }
      callee = ast.ast_arena_expr_get(arena, callee_ref);
      if ((callee.kind as i32) == (ExprKind.EXPR_FIELD_ACCESS as i32) && callee.field_access_field_len > 0) {
        name_ptr = &callee.field_access_field_name[0];
        name_len = callee.field_access_field_len;
      } else if ((callee.kind as i32) == (ExprKind.EXPR_VAR as i32) && callee.var_name_len > 0) {
        name_ptr = &callee.var_name[0];
        name_len = callee.var_name_len;
      } else {
        return 0;
      }
      n_args = e.call_num_args;
    } else {
      return 0;
    }
    /* Exact shape: raw_syscall0..raw_syscall6 (len 12; suffix digit = arity). */
    if (name_len != 12) {
      return 0;
    }
    while (pi < 11) {
      if (name_ptr[pi] != pfx[pi]) {
        return 0;
      }
      pi = pi + 1;
    }
    arity = name_ptr[11] as i32 - 48;
    if (arity < 0 || arity > 6) {
      return 0;
    }
    if (n_args != arity + 1) {
      return 0;
    }
    if (codegen_emit_bytes_from_ptr(out, &open_pre[0], 30) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 48 + arity) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    /* Scalar i64 formals only: clear the host slice-formal sidecar (wave395). */
    codegen_set_host_call_arg_param_ty(0);
    while (ai < n_args) {
      if (ai > 0) {
        if (codegen_emit_bytes_from_ptr(out, &comma_sp[0], 2) != 0) {
          return -1;
        }
      }
      if (codegen_emit_bytes_from_ptr(out, &arg_open[0], 7) != 0) {
        return -1;
      }
      if (is_method != 0) {
        arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, ai);
      } else {
        arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, ai);
      }
      if (emit_call_arg_slice_abi(arena, out, arg_ref, ctx) != 0) {
        codegen_set_host_call_arg_param_ty(0);
        return -1;
      }
      if (codegen_append_byte(out, 41) != 0) {
        return -1;
      }
      ai = ai + 1;
    }
    codegen_set_host_call_arg_param_ty(0);
    if (codegen_emit_bytes_from_ptr(out, &close3[0], 3) != 0) {
      return -1;
    }
    return 1;
  }
}

/**
 * Cap 10.7.1 language slice7: rewrite Cap va builtins to xlang_va_* macros.
 *
 * Call names (typeck via export-extern in user TU; not libc):
 *   va_start(ap, last) → xlang_va_start(ap, last)
 *   va_end(ap)         → xlang_va_end(ap)
 *   va_copy(dst, src)  → xlang_va_copy(dst, src)
 *   va_arg_i32(ap)     → ((int32_t)(xlang_va_arg(ap, int32_t)))
 *   va_arg_i64(ap)     → ((int64_t)(xlang_va_arg(ap, int64_t)))
 *   va_arg_ptr(ap)     → ((uint8_t *)(xlang_va_arg(ap, uint8_t *)))
 *   va_arg<T>(ap)      → ((CType)(xlang_va_arg(ap, CType)))  [slice14]
 *   va_arg<f32>(ap)    → ((float)(xlang_va_arg(ap, double))) [slice16; C promote]
 *
 * Typed form reuses existing turbofish `id<T>(…)` (G.7 size_of<T> pattern);
 * no type-as-value parse. Header face: emit_header `#include <xlang_va_cap.h>`.
 * VaList TYPE_NAMED → xlang_va_list in codegen_emit_type.
 *
 * @param arena *ASTArena — expr / callee slots
 * @param out *CodegenOutBuf — host-C text buffer
 * @param expr_ref i32 — EXPR_CALL or EXPR_METHOD_CALL site
 * @param ctx *PipelineDepCtx — arg emit context
 * @return i32 — 1 fully emitted; 0 not applicable; -1 emit error
 * PLATFORM: SHARED host-C (GCC/Clang Cap; MSVC residual).
 */
export function codegen_try_emit_va_cap_call(arena: *ASTArena, out: *CodegenOutBuf,
expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — Cap va macro rewrite (host-C only).
  unsafe {
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    let callee_ref: i32 = 0;
    let callee: Expr = e;
    let name_ptr: *u8 = 0 as *u8;
    let name_len: i32 = 0;
    let n_args: i32 = 0;
    let is_method: i32 = 0;
    let which: i32 = 0;
    let expect_args: i32 = 0;
    let ai: i32 = 0;
    let arg_ref: i32 = 0;
    /* xlang_va_start( / xlang_va_end( / xlang_va_copy( — shared "xlang_va_" prefix. */
    let pfx: u8[9] = [120, 108, 97, 110, 103, 95, 118, 97, 95];
    /* start( end( copy( suffixes after prefix (lengths 6/4/5). */
    let s_start: u8[6] = [115, 116, 97, 114, 116, 40];
    let s_end: u8[4] = [101, 110, 100, 40];
    let s_copy: u8[5] = [99, 111, 112, 121, 40];
    /* ((int32_t)(xlang_va_arg( */
    let open_i32: u8[24] = [40, 40, 105, 110, 116, 51, 50, 95, 116, 41, 40, 120, 108, 97, 110, 103, 95, 118, 97, 95, 97, 114, 103, 40];
    /* ((int64_t)(xlang_va_arg( */
    let open_i64: u8[24] = [40, 40, 105, 110, 116, 54, 52, 95, 116, 41, 40, 120, 108, 97, 110, 103, 95, 118, 97, 95, 97, 114, 103, 40];
    /* ((uint8_t *)(xlang_va_arg( */
    let open_ptr: u8[26] = [40, 40, 117, 105, 110, 116, 56, 95, 116, 32, 42, 41, 40, 120, 108, 97, 110, 103, 95, 118, 97, 95, 97, 114, 103, 40];
    /* , int32_t))) */
    let close_i32: u8[13] = [44, 32, 105, 110, 116, 51, 50, 95, 116, 41, 41, 41, 0];
    /* , int64_t))) */
    let close_i64: u8[13] = [44, 32, 105, 110, 116, 54, 52, 95, 116, 41, 41, 41, 0];
    /* , uint8_t *))) */
    let close_ptr: u8[15] = [44, 32, 117, 105, 110, 116, 56, 95, 116, 32, 42, 41, 41, 41, 0];
    let comma_sp: u8[2] = [44, 32];
    /* slice14 typed va_arg<T>: `((` + codegen_emit_type(T) + `)(xlang_va_arg(` + ap + `, ` + T + `)))` */
    let open2: u8[2] = [40, 40];
    let mid_typed: u8[16] = [41, 40, 120, 108, 97, 110, 103, 95, 118, 97, 95, 97, 114, 103, 40, 0];
    let close3t: u8[3] = [41, 41, 41];
    let n_ta: i32 = 0;
    let ta_ref: i32 = 0;
    let ta_is_f32: i32 = 0;
    let nm_double: u8[6] = [100, 111, 117, 98, 108, 101]; /* double */
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    e = ast.ast_arena_expr_get(arena, expr_ref);
    if ((e.kind as i32) == (ExprKind.EXPR_METHOD_CALL as i32)) {
      if (e.method_call_name_len <= 0) {
        return 0;
      }
      name_ptr = &e.method_call_name[0];
      name_len = e.method_call_name_len;
      n_args = e.method_call_num_args;
      is_method = 1;
    } else if ((e.kind as i32) == (ExprKind.EXPR_CALL as i32)) {
      callee_ref = e.call_callee_ref;
      if (callee_ref <= 0 || callee_ref > arena.num_exprs) {
        return 0;
      }
      callee = ast.ast_arena_expr_get(arena, callee_ref);
      if ((callee.kind as i32) == (ExprKind.EXPR_FIELD_ACCESS as i32) && callee.field_access_field_len > 0) {
        name_ptr = &callee.field_access_field_name[0];
        name_len = callee.field_access_field_len;
      } else if ((callee.kind as i32) == (ExprKind.EXPR_VAR as i32) && callee.var_name_len > 0) {
        name_ptr = &callee.var_name[0];
        name_len = callee.var_name_len;
      } else {
        return 0;
      }
      n_args = e.call_num_args;
    } else {
      return 0;
    }
    /* Match Cap names (byte-exact; FIELD_ACCESS leaf / bare VAR).
     * va_arg_i32 / va_arg_i64 / va_arg_ptr are 10 bytes each. */
    if (name_len == 8 && name_ptr[0] == 118 && name_ptr[1] == 97 && name_ptr[2] == 95
        && name_ptr[3] == 115 && name_ptr[4] == 116 && name_ptr[5] == 97
        && name_ptr[6] == 114 && name_ptr[7] == 116) {
      which = 1;
      expect_args = 2;
    } else if (name_len == 6 && name_ptr[0] == 118 && name_ptr[1] == 97 && name_ptr[2] == 95
        && name_ptr[3] == 101 && name_ptr[4] == 110 && name_ptr[5] == 100) {
      which = 2;
      expect_args = 1;
    } else if (name_len == 7 && name_ptr[0] == 118 && name_ptr[1] == 97 && name_ptr[2] == 95
        && name_ptr[3] == 99 && name_ptr[4] == 111 && name_ptr[5] == 112
        && name_ptr[6] == 121) {
      which = 3;
      expect_args = 2;
    } else if (name_len == 10 && name_ptr[0] == 118 && name_ptr[1] == 97 && name_ptr[2] == 95
        && name_ptr[3] == 97 && name_ptr[4] == 114 && name_ptr[5] == 103
        && name_ptr[6] == 95 && name_ptr[7] == 105 && name_ptr[8] == 51
        && name_ptr[9] == 50) {
      which = 4;
      expect_args = 1;
    } else if (name_len == 10 && name_ptr[0] == 118 && name_ptr[1] == 97 && name_ptr[2] == 95
        && name_ptr[3] == 97 && name_ptr[4] == 114 && name_ptr[5] == 103
        && name_ptr[6] == 95 && name_ptr[7] == 105 && name_ptr[8] == 54
        && name_ptr[9] == 52) {
      which = 5;
      expect_args = 1;
    } else if (name_len == 10 && name_ptr[0] == 118 && name_ptr[1] == 97 && name_ptr[2] == 95
        && name_ptr[3] == 97 && name_ptr[4] == 114 && name_ptr[5] == 103
        && name_ptr[6] == 95 && name_ptr[7] == 112 && name_ptr[8] == 116
        && name_ptr[9] == 114) {
      which = 6;
      expect_args = 1;
    } else if (name_len == 6 && name_ptr[0] == 118 && name_ptr[1] == 97 && name_ptr[2] == 95
        && name_ptr[3] == 97 && name_ptr[4] == 114 && name_ptr[5] == 103) {
      /* Cap 10.7.1 slice14: va_arg<T>(ap) turbofish. Distinct from va_end. */
      which = 7;
      expect_args = 1;
    } else {
      return 0;
    }
    if (n_args != expect_args) {
      return 0;
    }
    codegen_set_host_call_arg_param_ty(0);
    if (which == 7) {
      n_ta = pipeline_expr_call_num_type_args_at(arena, expr_ref);
      ta_ref = pipeline_expr_call_type_arg_ref_at(arena, expr_ref, 0);
      if (n_ta < 1 || ta_ref <= 0) {
        codegen_set_host_call_arg_param_ty(0);
        return 0;
      }
      /* C default promotions: unnamed float is passed as double. */
      ta_is_f32 = 0;
      if (pipeline_type_kind_ord_at(arena, ta_ref) == 14) {
        ta_is_f32 = 1;
      }
      if (codegen_emit_bytes_from_ptr(out, &open2[0], 2) != 0) {
        codegen_set_host_call_arg_param_ty(0);
        return -1;
      }
      if (codegen_emit_type(arena, out, ta_ref, 0 as *u8, 0, ctx) != 0) {
        codegen_set_host_call_arg_param_ty(0);
        return -1;
      }
      if (codegen_emit_bytes_from_ptr(out, &mid_typed[0], 15) != 0) {
        codegen_set_host_call_arg_param_ty(0);
        return -1;
      }
      if (is_method != 0) {
        arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, 0);
      } else {
        arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
      }
      if (emit_call_arg_slice_abi(arena, out, arg_ref, ctx) != 0) {
        codegen_set_host_call_arg_param_ty(0);
        return -1;
      }
      if (codegen_emit_bytes_from_ptr(out, &comma_sp[0], 2) != 0) {
        codegen_set_host_call_arg_param_ty(0);
        return -1;
      }
      if (ta_is_f32 != 0) {
        if (codegen_emit_bytes_from_ptr(out, &nm_double[0], 6) != 0) {
          codegen_set_host_call_arg_param_ty(0);
          return -1;
        }
      } else if (codegen_emit_type(arena, out, ta_ref, 0 as *u8, 0, ctx) != 0) {
        codegen_set_host_call_arg_param_ty(0);
        return -1;
      }
      if (codegen_emit_bytes_from_ptr(out, &close3t[0], 3) != 0) {
        codegen_set_host_call_arg_param_ty(0);
        return -1;
      }
      codegen_set_host_call_arg_param_ty(0);
      return 1;
    }
    if (which == 1) {
      if (codegen_emit_bytes_from_ptr(out, &pfx[0], 9) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_from_ptr(out, &s_start[0], 6) != 0) {
        return -1;
      }
    } else if (which == 2) {
      if (codegen_emit_bytes_from_ptr(out, &pfx[0], 9) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_from_ptr(out, &s_end[0], 4) != 0) {
        return -1;
      }
    } else if (which == 3) {
      if (codegen_emit_bytes_from_ptr(out, &pfx[0], 9) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_from_ptr(out, &s_copy[0], 5) != 0) {
        return -1;
      }
    } else if (which == 4) {
      if (codegen_emit_bytes_from_ptr(out, &open_i32[0], 24) != 0) {
        return -1;
      }
    } else if (which == 5) {
      if (codegen_emit_bytes_from_ptr(out, &open_i64[0], 24) != 0) {
        return -1;
      }
    } else if (which == 6) {
      if (codegen_emit_bytes_from_ptr(out, &open_ptr[0], 26) != 0) {
        return -1;
      }
    } else {
      return 0;
    }
    while (ai < n_args) {
      if (ai > 0) {
        if (codegen_emit_bytes_from_ptr(out, &comma_sp[0], 2) != 0) {
          return -1;
        }
      }
      if (is_method != 0) {
        arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, ai);
      } else {
        arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, ai);
      }
      if (emit_call_arg_slice_abi(arena, out, arg_ref, ctx) != 0) {
        codegen_set_host_call_arg_param_ty(0);
        return -1;
      }
      ai = ai + 1;
    }
    if (which >= 1 && which <= 3) {
      if (codegen_append_byte(out, 41) != 0) {
        return -1;
      }
    } else if (which == 4) {
      if (codegen_emit_bytes_from_ptr(out, &close_i32[0], 12) != 0) {
        return -1;
      }
    } else if (which == 5) {
      if (codegen_emit_bytes_from_ptr(out, &close_i64[0], 12) != 0) {
        return -1;
      }
    } else if (which == 6) {
      if (codegen_emit_bytes_from_ptr(out, &close_ptr[0], 14) != 0) {
        return -1;
      }
    }
    codegen_set_host_call_arg_param_ty(0);
    return 1;
  }
}

/**
 * wave409 Cap residual pure: finish TYPE_SLICE let from CALL/METHOD with frame deep-copy.
 * Type+name already written. Emits `; E __xlang_ldN[1024]; { S __sp = call; copy; name=fat(ld); }`.
 * Fixes true recursion last-wins on callee static `__xlang_al` (walk 18→36).
 * Authority body in seed codegen_gen (G.7 twin of freestanding glue reent deep-copy).
 * @param arena *ASTArena — type/elem lookup
 * @param out *CodegenOutBuf — host-C text
 * @param indent i32 — block indent
 * @param name *u8 — let C name bytes
 * @param name_len i32 — name length
 * @param let_type_ref i32 — TYPE_SLICE type ref
 * @param linit_ref i32 — CALL/METHOD init expr
 * @param ctx *PipelineDepCtx — emit context
 * @return i32 — 0 success, -1 fail
 * PLATFORM: SHARED host-C
 */
export extern function codegen_emit_slice_let_reent_finish(arena: *ASTArena, out: *CodegenOutBuf, indent: i32, name: *u8, name_len: i32, let_type_ref: i32, linit_ref: i32, ctx: *PipelineDepCtx): i32;

/**
 * Emit one call argument under seed/glue slice ABI (PLATFORM: SHARED).
 *
 * Why: TYPE_SLICE params lower as `struct xlang_slice_* *`. Locals stay by-value
 * structs, so call sites must pass `&local` (seed: `&(slice)`). Slice params are
 * already pointers — pass through. ADDR_OF is left unchanged.
 *
 * wave395: fixed TYPE_ARRAY local (`let a: T[N]`) as slice* formal must materialize
 * a C fat `{.data=a,.length=N}` then pass its address. Bare `a` is `T*` (array decay),
 * not `struct xlang_slice_* *` → host reads length from wrong memory (e.g. a[2]=30).
 * wave396: same for CALL/METHOD return `T[N]` and FIELD_ACCESS of fixed array field
 * (`len_of(take3(1))` / `sum3(b.a)` bare `E*` as slice* → length half garbage).
 * INDEX `take(a[i])` of `[K][N]T`: same fat; C `a[i]` decays to E*.
 * Identity ascription `take(a as [2]i32)` peels to the ARRAY operand.
 * wave397: CALL/METHOD `.data` deep-copies into unique `__xlang_caN[N]` so dual
 * same-call formals do not both alias callee static `__xlang_ar` (host 66→39).
 * wave400: ARRAY_LIT as TYPE_SLICE formal uses wave345 `__xlang_sp` materialize
 * (not bare `&(rvalue compound)`) so host-C BLD001 closes; dual lit formals OK.
 * wave406: CALL/METHOD returning TYPE_SLICE as formal deep-copies payload into
 * unique `__xlang_sdN[1024]` so dual same-call formals do not both alias callee
 * static `__xlang_al` (host sum2(take(1),take(2)) 72→69). ARRAY_LIT path stays
 * fat-only (each lit has its own block-static). Soft residual: true recursion /
 * heap-free reentrancy beyond dual same-call still last-wins on static temps.
 * Gate: only when codegen_get_host_call_arg_param_ty is TYPE_SLICE (else bare
 * emit for *T / Buffer formals — option/hello). G.7: same compound as let-init.
 *
 * Invariant: only for call/method arg positions; never for general codegen_emit_expr.
 */
export function emit_call_arg_slice_abi(arena: *ASTArena, out: *CodegenOutBuf, arg_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (ast.ref_is_null(arg_ref)) {
      return codegen_append_byte(out, 48);
    }
    let arg: Expr = ast.ast_arena_expr_get(arena, arg_ref);
    if ((arg.kind as i32) == (ExprKind.EXPR_ADDR_OF as i32)) {
      return codegen_emit_expr(arena, out, arg_ref, ctx);
    }
    /* Already a slice param of the current function → C pointer; do not add &. */
    if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0) {
      if (field_access_base_is_pointer_param(arena, arg_ref, ctx.current_codegen_module, ctx.current_func_index) != 0) {
        /* pointer_param now treats TYPE_SLICE params as pointers */
        let is_slice_param: i32 = 0;
        let base: Expr = arg;
        if ((base.kind as i32) == (ExprKind.EXPR_VAR as i32) && base.var_name_len > 0) {
          let mod: *Module = ctx.current_codegen_module;
          let fi: i32 = ctx.current_func_index;
          let np: i32 = pipeline_module_func_num_params_at(mod, fi);
          let pi: i32 = 0;
          while (pi < np) {
            let p_name_len: i32 = pipeline_module_func_param_name_len_at(mod, fi, pi);
            if (p_name_len > 0 && p_name_len == base.var_name_len) {
              let pname_buf: u8[256] = [];
              pipeline_module_func_param_name_copy32(mod, fi, pi, &pname_buf[0]);
              let matched: bool = true;
              let j: i32 = 0;
              while (j < p_name_len && j < 32) {
                if (pname_buf[j] != base.var_name[j]) {
                  matched = false;
                  break;
                }
                j = j + 1;
              }
              if (matched) {
                let param_ty_ref: i32 = pipeline_module_func_param_type_ref_at(mod, fi, pi);
                if (pipeline_type_kind_ord_at(arena, param_ty_ref) == (TypeKind.TYPE_SLICE as i32)) {
                  is_slice_param = 1;
                }
              }
            }
            pi = pi + 1;
          }
        }
        if (is_slice_param != 0) {
          return codegen_emit_expr(arena, out, arg_ref, ctx);
        }
      }
    }
    /*
     * wave395/396 Cap residual pure: fixed TYPE_ARRAY rvalue → slice* formal.
     * Emit: &((struct xlang_slice_T){ .data = <arr>, .length = N })
     * wave395: EXPR_VAR local; wave396: EXPR_CALL / METHOD_CALL / FIELD_ACCESS.
     * INDEX (`take(a[i])` of `[K][N]T` / `[][N]T`): same wrap; C `a[i]` decays
     * to E*. Identity ARRAY/SLICE ascription (`take(a as [2]i32)`) peels so
     * VAR/INDEX/FIELD consumers fire — scalar `5 as i32` stays wrapped.
     * PLATFORM: SHARED host-C (fs: pipeline_asm_emit_expr_elf_for_call_args).
     */
    {
      let arr_sz: i32 = 0;
      let arr_tr: i32 = 0;
      let elem_tr: i32 = 0;
      let is_arr_rvalue: i32 = 0;
      let peel_hop: i32 = 0;
      /* Identity ascription: take(a as [2]i32) must see the ARRAY operand. */
      while (peel_hop < 8 && (arg.kind as i32) == (ExprKind.EXPR_AS as i32)) {
        let as_tgt: i32 = arg.as_target_type_ref;
        let as_op: i32 = arg.as_operand_ref;
        let as_tk: i32 = 0;
        if (ast.ref_is_null(as_tgt) || ast.ref_is_null(as_op) || as_op <= 0 || as_op > arena.num_exprs) {
          peel_hop = 8;
        } else {
          as_tk = pipeline_type_kind_ord_at(arena, as_tgt);
          if (as_tk != (TypeKind.TYPE_ARRAY as i32) && as_tk != (TypeKind.TYPE_SLICE as i32)) {
            peel_hop = 8;
          } else {
            arg_ref = as_op;
            arg = ast.ast_arena_expr_get(arena, arg_ref);
            peel_hop = peel_hop + 1;
          }
        }
      }
      /* VAR / CALL / METHOD / FIELD / INDEX — kinds that can carry fixed TYPE_ARRAY. */
      if ((arg.kind as i32) == (ExprKind.EXPR_VAR as i32) && arg.var_name_len > 0) {
        is_arr_rvalue = 1;
      } else if ((arg.kind as i32) == (ExprKind.EXPR_CALL as i32) || (arg.kind as i32) == (ExprKind.EXPR_METHOD_CALL as i32)
          || (arg.kind as i32) == (ExprKind.EXPR_FIELD_ACCESS as i32)
          || (arg.kind as i32) == (ExprKind.EXPR_INDEX as i32)) {
        is_arr_rvalue = 1;
      }
      if (is_arr_rvalue != 0) {
        if (!ast.ref_is_null(arg.resolved_type_ref) && arg.resolved_type_ref > 0
            && arg.resolved_type_ref <= arena.num_types) {
          if (pipeline_type_kind_ord_at(arena, arg.resolved_type_ref) == (TypeKind.TYPE_ARRAY as i32)) {
            arr_tr = arg.resolved_type_ref;
            arr_sz = pipeline_type_array_size_at(arena, arr_tr);
          }
        }
        /*
         * INDEX: dest-SLICE may stamp the INDEX expr to TYPE_SLICE (hide N).
         * Call-arg score does not stamp — resolved is usually TYPE_ARRAY.
         * Fallback N from base elem TYPE_ARRAY (`[K][N]T` / `[][N]T`).
         * PLATFORM: SHARED host-C.
         */
        if (arr_sz <= 0 && (arg.kind as i32) == (ExprKind.EXPR_INDEX as i32)) {
          let ix_base: i32 = pipeline_expr_index_base_ref(arena, arg_ref);
          if (ix_base > 0 && ix_base <= arena.num_exprs) {
            let bty: i32 = pipeline_expr_resolved_type_ref(arena, ix_base);
            if (!ast.ref_is_null(bty) && bty > 0) {
              let bk: i32 = pipeline_type_kind_ord_at(arena, bty);
              if (bk == (TypeKind.TYPE_ARRAY as i32) || bk == (TypeKind.TYPE_SLICE as i32)) {
                let ety: i32 = pipeline_type_elem_ref_at(arena, bty);
                if (!ast.ref_is_null(ety) && ety > 0) {
                  if (pipeline_type_kind_ord_at(arena, ety) == (TypeKind.TYPE_ARRAY as i32)) {
                    arr_tr = ety;
                    arr_sz = pipeline_type_array_size_at(arena, ety);
                  }
                }
              }
            }
          }
        }
        /* VAR: resolve from let decl when resolved stamp missing. */
        if (arr_sz <= 0 && (arg.kind as i32) == (ExprKind.EXPR_VAR as i32) && arg.var_name_len > 0
            && ctx != 0 as *PipelineDepCtx) {
          let br: i32 = 0;
          if (ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0) {
            br = pipeline_module_func_body_ref_at(ctx.current_codegen_module, ctx.current_func_index);
          }
          if (ast.ref_is_null(br) || br <= 0 || br > arena.num_blocks) {
            br = ctx.current_block_ref;
          }
          if (!ast.ref_is_null(br) && br > 0 && br <= arena.num_blocks) {
            let nlets: i32 = ast_ast_block_num_lets(arena, br);
            let li: i32 = 0;
            while (li < nlets) {
              let nl: i32 = pipeline_block_let_name_len(arena, br, li);
              if (nl == arg.var_name_len && nl > 0) {
                let nb: u8[256] = [];
                pipeline_block_let_name_copy64(arena, br, li, &nb[0]);
                let eq: bool = true;
                let j2: i32 = 0;
                while (j2 < nl && j2 < 64) {
                  if (nb[j2] != arg.var_name[j2]) {
                    eq = false;
                    break;
                  }
                  j2 = j2 + 1;
                }
                if (eq) {
                  let tr: i32 = pipeline_block_let_type_ref(arena, br, li);
                  if (pipeline_type_kind_ord_at(arena, tr) == (TypeKind.TYPE_ARRAY as i32)) {
                    arr_tr = tr;
                    arr_sz = pipeline_type_array_size_at(arena, tr);
                  }
                }
              }
              li = li + 1;
            }
          }
        }
        if (arr_sz > 0) {
          /*
           * Only for TYPE_SLICE formals. *u8 / *Buffer / other formals need array
           * decay (bare `a` / `take()` / `b.a`), not fat compound
           * (wave395 regression: option/hello).
           */
          let formal_ty: i32 = codegen_get_host_call_arg_param_ty();
          if (formal_ty <= 0
              || pipeline_type_kind_ord_at(arena, formal_ty) != (TypeKind.TYPE_SLICE as i32)) {
            return codegen_emit_expr(arena, out, arg_ref, ctx);
          }
          /* &(( */
          let open: u8[4] = [38, 40, 40, 0];
          if (codegen_emit_bytes_from_ptr(out, &open[0], 3) != 0) {
            return -1;
          }
          /*
           * wave619/wave624: fat tag via codegen_emit_type(formal SLICE) — single authority with
           * locals/formals (ctx-aware NAMED tags + scalar stdint map). Prior type_to_c_repr
           * with empty prefix forced `ast_` and drifted from module struct tags.
           * PLATFORM: SHARED host-C. G.7: no second elem→suffix table.
           */
          if (codegen_emit_type(arena, out, formal_ty, 0 as *u8, 0, ctx) != 0) {
            /* Fallback: struct xlang_slice_int32_t */
            let fb: u8[28] = [
              115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95,
              105, 110, 116, 51, 50, 95, 116, 0, 0
            ];
            if (codegen_emit_bytes_from_ptr(out, &fb[0], 26) != 0) {
              return -1;
            }
          }
          /* ){ .data =  */
          let mid1: u8[14] = [41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 0, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &mid1[0], 11) != 0) {
            return -1;
          }
          /*
           * .data = …
           * VAR: bare name (array decay → durable local E*).
           * CALL/METHOD: deep-copy into unique static __xlang_caN (wave397).
           *   Host lowers TYPE_ARRAY return as E* into callee static __xlang_ar;
           *   dual same-call formals would both alias last write (66 vs 39).
           * FIELD: codegen_emit_expr (address of embedded payload; durable with base).
           * PLATFORM: SHARED host-C.
           */
          if ((arg.kind as i32) == (ExprKind.EXPR_VAR as i32) && arg.var_name_len > 0) {
            if (codegen_emit_bytes_64(out, &arg.var_name[0], arg.var_name_len) != 0) {
              return -1;
            }
          } else if ((arg.kind as i32) == (ExprKind.EXPR_CALL as i32) || (arg.kind as i32) == (ExprKind.EXPR_METHOD_CALL as i32)) {
            let tid: i32 = codegen_next_host_call_array_tmp_id();
            /* ({ static  */
            let ca_open: u8[12] = [40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0];
            if (codegen_emit_bytes_from_ptr(out, &ca_open[0], 10) != 0) {
              return -1;
            }
            /* elem type */
            if (ast.ref_is_null(elem_tr) || elem_tr <= 0
                || codegen_emit_type(arena, out, elem_tr, 0 as *u8, 0, ctx) != 0) {
              let fb_e: u8[9] = [105, 110, 116, 51, 50, 95, 116, 0, 0];
              if (codegen_emit_bytes_from_ptr(out, &fb_e[0], 7) != 0) {
                return -1;
              }
            }
            /*  __xlang_ca */
            let ca_nm: u8[14] = [32, 95, 95, 120, 108, 97, 110, 103, 95, 99, 97, 0, 0, 0];
            if (codegen_emit_bytes_from_ptr(out, &ca_nm[0], 11) != 0) {
              return -1;
            }
            if (format_int(out, tid as i64) != 0) {
              return -1;
            }
            /* [N];  */
            if (codegen_append_byte(out, 91) != 0) {
              return -1;
            }
            if (format_int(out, arr_sz as i64) != 0) {
              return -1;
            }
            let ca_sz_end: u8[4] = [93, 59, 32, 0];
            if (codegen_emit_bytes_from_ptr(out, &ca_sz_end[0], 3) != 0) {
              return -1;
            }
            /* E *__xlang_rp = <call>;  */
            if (ast.ref_is_null(elem_tr) || elem_tr <= 0
                || codegen_emit_type(arena, out, elem_tr, 0 as *u8, 0, ctx) != 0) {
              let fb_rp: u8[9] = [105, 110, 116, 51, 50, 95, 116, 0, 0];
              if (codegen_emit_bytes_from_ptr(out, &fb_rp[0], 7) != 0) {
                return -1;
              }
            }
            let rp_asg: u8[16] = [32, 42, 95, 95, 120, 108, 97, 110, 103, 95, 114, 112, 32, 61, 32, 0];
            if (codegen_emit_bytes_from_ptr(out, &rp_asg[0], 15) != 0) {
              return -1;
            }
            if (codegen_emit_expr(arena, out, arg_ref, ctx) != 0) {
              return -1;
            }
            let rp_sc: u8[4] = [59, 32, 0, 0];
            if (codegen_emit_bytes_4(out, &rp_sc[0], 2) != 0) {
              return -1;
            }
            /* element-wise copy (no memcpy header dependency) */
            let ai_ca: i32 = 0;
            while (ai_ca < arr_sz) {
              /* __xlang_caN[ */
              let ca_asg: u8[14] = [95, 95, 120, 108, 97, 110, 103, 95, 99, 97, 0, 0, 0, 0];
              if (codegen_emit_bytes_from_ptr(out, &ca_asg[0], 10) != 0) {
                return -1;
              }
              if (format_int(out, tid as i64) != 0) {
                return -1;
              }
              if (codegen_append_byte(out, 91) != 0) {
                return -1;
              }
              if (format_int(out, ai_ca as i64) != 0) {
                return -1;
              }
              /* ] = __xlang_rp[ */
              let ca_mid: u8[16] = [93, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 114, 112, 91, 0];
              if (codegen_emit_bytes_from_ptr(out, &ca_mid[0], 15) != 0) {
                return -1;
              }
              if (format_int(out, ai_ca as i64) != 0) {
                return -1;
              }
              let ca_el_end: u8[4] = [93, 59, 32, 0];
              if (codegen_emit_bytes_from_ptr(out, &ca_el_end[0], 3) != 0) {
                return -1;
              }
              ai_ca = ai_ca + 1;
            }
            /* __xlang_caN; }) */
            let ca_ret: u8[14] = [95, 95, 120, 108, 97, 110, 103, 95, 99, 97, 0, 0, 0, 0];
            if (codegen_emit_bytes_from_ptr(out, &ca_ret[0], 10) != 0) {
              return -1;
            }
            if (format_int(out, tid as i64) != 0) {
              return -1;
            }
            let ca_close: u8[6] = [59, 32, 125, 41, 0, 0];
            if (codegen_emit_bytes_from_ptr(out, &ca_close[0], 4) != 0) {
              return -1;
            }
          } else {
            /* FIELD_ACCESS etc.: address of embedded array */
            if (codegen_emit_expr(arena, out, arg_ref, ctx) != 0) {
              return -1;
            }
          }
          /* , .length =  */
          let mid2: u8[14] = [44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &mid2[0], 12) != 0) {
            return -1;
          }
          if (format_int(out, arr_sz as i64) != 0) {
            return -1;
          }
          /*  })  — `}` closes compound body; `)` closes outer `&(`  */
          let close: u8[4] = [32, 125, 41, 0];
          if (codegen_emit_bytes_from_ptr(out, &close[0], 3) != 0) {
            return -1;
          }
          return 0;
        }
      }
    }
    /* Local / rvalue slice → &(arg) for pointer param ABI. */
    let need_addr: i32 = 0;
    if (!ast.ref_is_null(arg.resolved_type_ref) && arg.resolved_type_ref > 0 && arg.resolved_type_ref <= arena.num_types) {
      let aty: Type = ast.ast_arena_type_get(arena, arg.resolved_type_ref);
      if ((aty.kind as i32) == (TypeKind.TYPE_SLICE as i32)) {
        need_addr = 1;
      }
    }
    if (need_addr == 0 && (arg.kind as i32) == (ExprKind.EXPR_VAR as i32) && ctx != 0 as *PipelineDepCtx) {
      /* Local let annotated as TYPE_SLICE */
      if (field_access_base_is_pointer_local(arena, arg_ref, ctx) == 0) {
        let br: i32 = 0;
        if (ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0) {
          br = pipeline_module_func_body_ref_at(ctx.current_codegen_module, ctx.current_func_index);
        }
        if (ast.ref_is_null(br) || br <= 0 || br > arena.num_blocks) {
          br = ctx.current_block_ref;
        }
        if (!ast.ref_is_null(br) && br > 0 && br <= arena.num_blocks) {
          let nlets: i32 = ast_ast_block_num_lets(arena, br);
          let li: i32 = 0;
          while (li < nlets) {
            let nl: i32 = pipeline_block_let_name_len(arena, br, li);
            if (nl == arg.var_name_len && nl > 0) {
              let nb: u8[256] = [];
              pipeline_block_let_name_copy64(arena, br, li, &nb[0]);
              let eq: bool = true;
              let j2: i32 = 0;
              while (j2 < nl && j2 < 64) {
                if (nb[j2] != arg.var_name[j2]) {
                  eq = false;
                  break;
                }
                j2 = j2 + 1;
              }
              if (eq) {
                let tr: i32 = pipeline_block_let_type_ref(arena, br, li);
                if (pipeline_type_kind_ord_at(arena, tr) == (TypeKind.TYPE_SLICE as i32)) {
                  need_addr = 1;
                }
              }
            }
            li = li + 1;
          }
        }
      }
    }
    if (need_addr != 0) {
      /*
       * wave345: CALL/METHOD rvalue slice cannot take address (`&(take())` is
       * invalid C). Materialize into a GNU stmt-expr temp then pass its address.
       * wave400: ARRAY_LIT same — codegen_emit_expr yields compound-literal rvalue
       * `({ static E __xlang_al[]={…}; (struct slice){.data=…,.length=N}; })`;
       * wrapping `&(...)` is BLD001 "cannot take the address of an rvalue".
       * Local VAR stays `&(s)`. PLATFORM: SHARED host-C (fs dual-GP call-arg
       * already materializes — glue wave332).
       * wave406: CALL/METHOD fat alone is insufficient — callee return ARRAY_LIT
       * uses one function-static `__xlang_al`; dual same-call formals both point
       * at last write (72 vs 69). Deep-copy payload into unique `__xlang_sdN`.
       * Soft residual: true recursion / heap-free reentrancy beyond dual same-call.
       */
      if ((arg.kind as i32) == (ExprKind.EXPR_CALL as i32) || (arg.kind as i32) == (ExprKind.EXPR_METHOD_CALL as i32)) {
        /*
         * ({ static S __xlang_spN; static E __xlang_sdN[1024]; size_t __xlang_snN;
         *    size_t __xlang_siN; __xlang_spN = <call>; __xlang_snN = min(len,1024);
         *    for (...) __xlang_sdN[i] = __xlang_spN.data[i];
         *    __xlang_spN.data = __xlang_sdN; __xlang_spN.length = __xlang_snN;
         *    &__xlang_spN; })
         * PLATFORM: SHARED host-C. Cap 1024 (wave418; twin freestanding max_n).
         */
        let ty_ref: i32 = arg.resolved_type_ref;
        let tid: i32 = codegen_next_host_call_array_tmp_id();
        let elem_tr: i32 = 0;
        if (!ast.ref_is_null(ty_ref) && ty_ref > 0 && ty_ref <= arena.num_types) {
          elem_tr = pipeline_type_elem_ref_at(arena, ty_ref);
        }
        /* ({ static  */
        let open_stmt: u8[12] = [40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &open_stmt[0], 10) != 0) {
          return -1;
        }
        if (!ast.ref_is_null(ty_ref) && ty_ref > 0 && ty_ref <= arena.num_types) {
          if (codegen_emit_type(arena, out, ty_ref, 0 as *u8, 0, ctx) != 0) {
            return -1;
          }
        } else {
          let fb: u8[32] = [
            115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 0, 0, 0, 0, 0, 0
          ];
          if (codegen_emit_bytes_from_ptr(out, &fb[0], 26) != 0) {
            return -1;
          }
        }
        /*  __xlang_sp */
        let sp_nm: u8[14] = [32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &sp_nm[0], 11) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* ; static  */
        let st2: u8[10] = [59, 32, 115, 116, 97, 116, 105, 99, 32, 0];
        if (codegen_emit_bytes_from_ptr(out, &st2[0], 9) != 0) {
          return -1;
        }
        /* elem type for sd buffer */
        if (ast.ref_is_null(elem_tr) || elem_tr <= 0
            || codegen_emit_type(arena, out, elem_tr, 0 as *u8, 0, ctx) != 0) {
          let fb_e: u8[9] = [105, 110, 116, 51, 50, 95, 116, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &fb_e[0], 7) != 0) {
            return -1;
          }
        }
        /*  __xlang_sd */
        let sd_nm: u8[14] = [32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 100, 0, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &sd_nm[0], 11) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* [1024]; size_t __xlang_sn */
        let sd_mid: u8[28] = [
          91, 49, 48, 50, 52, 93, 59, 32, 115, 105, 122, 101, 95, 116, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 110, 0, 0
        ];
        if (codegen_emit_bytes_from_ptr(out, &sd_mid[0], 25) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* ; size_t __xlang_si */
        let si_decl: u8[24] = [
          59, 32, 115, 105, 122, 101, 95, 116, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105, 0, 0, 0, 0, 0
        ];
        if (codegen_emit_bytes_from_ptr(out, &si_decl[0], 19) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* ; __xlang_sp */
        let sp_asg: u8[14] = [59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &sp_asg[0], 12) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /*  =  */
        let eq_sp: u8[4] = [32, 61, 32, 0];
        if (codegen_emit_bytes_from_ptr(out, &eq_sp[0], 3) != 0) {
          return -1;
        }
        if (codegen_emit_expr(arena, out, arg_ref, ctx) != 0) {
          return -1;
        }
        /* ; __xlang_snN = __xlang_spN.length; if (__xlang_snN > 512) __xlang_snN = 512;  */
        let sn_asg: u8[14] = [59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 110, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &sn_asg[0], 12) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /*  = __xlang_sp */
        let sn_eq: u8[14] = [32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0];
        if (codegen_emit_bytes_from_ptr(out, &sn_eq[0], 13) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* .length; if (__xlang_sn */
        let sn_len: u8[28] = [
          46, 108, 101, 110, 103, 116, 104, 59, 32, 105, 102, 32, 40, 95, 95, 120, 108, 97, 110, 103, 95, 115, 110, 0, 0, 0, 0, 0
        ];
        if (codegen_emit_bytes_from_ptr(out, &sn_len[0], 23) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /*  > 1024) __xlang_sn */
        let sn_cap: u8[20] = [
          32, 62, 32, 49, 48, 50, 52, 41, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 110, 0
        ];
        if (codegen_emit_bytes_from_ptr(out, &sn_cap[0], 19) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /*  = 1024; for (__xlang_si */
        let for_open: u8[28] = [
          32, 61, 32, 49, 48, 50, 52, 59, 32, 102, 111, 114, 32, 40, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105, 0, 0, 0
        ];
        if (codegen_emit_bytes_from_ptr(out, &for_open[0], 24) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /*  = 0; __xlang_si */
        let for_mid1: u8[16] = [32, 61, 32, 48, 59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105];
        /* note: 16 bytes exact — use from_ptr with 16 */
        if (codegen_emit_bytes_from_ptr(out, &for_mid1[0], 16) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /*  < __xlang_sn */
        let for_mid2: u8[16] = [32, 60, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 110, 0, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &for_mid2[0], 13) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* ; __xlang_si */
        let for_mid3: u8[14] = [59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &for_mid3[0], 12) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* ++) __xlang_sd */
        let for_body: u8[16] = [43, 43, 41, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 100, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &for_body[0], 14) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* [__xlang_si */
        let idx_open: u8[14] = [91, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105, 0, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &idx_open[0], 11) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* ] = __xlang_sp */
        let copy_mid: u8[16] = [93, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &copy_mid[0], 14) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* .data[__xlang_si */
        let data_idx: u8[20] = [
          46, 100, 97, 116, 97, 91, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105, 0, 0, 0, 0
        ];
        if (codegen_emit_bytes_from_ptr(out, &data_idx[0], 16) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* ]; __xlang_sp */
        let after_copy: u8[16] = [93, 59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &after_copy[0], 13) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* .data = __xlang_sd */
        let data_asg: u8[20] = [
          46, 100, 97, 116, 97, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 100, 0, 0
        ];
        if (codegen_emit_bytes_from_ptr(out, &data_asg[0], 18) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* ; __xlang_sp */
        let len_asg: u8[14] = [59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &len_asg[0], 12) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* .length = __xlang_sn */
        let len_eq: u8[24] = [
          46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 110, 0, 0, 0, 0
        ];
        if (codegen_emit_bytes_from_ptr(out, &len_eq[0], 20) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* ; &__xlang_sp */
        let end_sp: u8[16] = [59, 32, 38, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &end_sp[0], 13) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* ; }) */
        let close_sp: u8[6] = [59, 32, 125, 41, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &close_sp[0], 4) != 0) {
          return -1;
        }
        return 0;
      }
      if ((arg.kind as i32) == (ExprKind.EXPR_ARRAY_LIT as i32)) {
        let ty_ref: i32 = arg.resolved_type_ref;
        /* ({ static  — wave400: ARRAY_LIT rvalue needs addressable fat. */
        let open_stmt: u8[12] = [40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &open_stmt[0], 10) != 0) {
          return -1;
        }
        if (!ast.ref_is_null(ty_ref) && ty_ref > 0 && ty_ref <= arena.num_types) {
          if (codegen_emit_type(arena, out, ty_ref, 0 as *u8, 0, ctx) != 0) {
            return -1;
          }
        } else {
          let fb: u8[32] = [
            115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 0, 0, 0, 0, 0, 0
          ];
          if (codegen_emit_bytes_from_ptr(out, &fb[0], 26) != 0) {
            return -1;
          }
        }
        /*  __xlang_sp; __xlang_sp =  */
        let sp_decl: u8[28] = [
          32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 32, 61, 32, 0, 0
        ];
        if (codegen_emit_bytes_from_ptr(out, &sp_decl[0], 26) != 0) {
          return -1;
        }
        if (codegen_emit_expr(arena, out, arg_ref, ctx) != 0) {
          return -1;
        }
        /* ; &__xlang_sp; }) */
        let end_sp: u8[20] = [59, 32, 38, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 59, 32, 125, 41, 0, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &end_sp[0], 17) != 0) {
          return -1;
        }
        return 0;
      }
      let pre: u8[3] = [38, 40, 0];
      if (codegen_emit_bytes_3(out, &pre[0], 2) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, arg_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    return codegen_emit_expr(arena, out, arg_ref, ctx);
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function field_access_base_is_pointer_param(arena: *ASTArena, base_ref: i32, mod: *Module, func_index: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
      return 0;
    }
    if (mod == 0 as *Module || func_index < 0 || func_index >= mod.num_funcs) {
      return 0;
    }
    let base: Expr = ast.ast_arena_expr_get(arena, base_ref);
    if ((base.kind as i32) != (ExprKind.EXPR_VAR as i32) || base.var_name_len <= 0) {
      return 0;
    }
    let np: i32 = pipeline_module_func_num_params_at(mod, func_index);
    let pi: i32 = 0;
    while (pi < np) {
      let p_name_len: i32 = pipeline_module_func_param_name_len_at(mod, func_index, pi);
      if (p_name_len > 0 && p_name_len == base.var_name_len) {
        let pname_buf: u8[256] = [];
        pipeline_module_func_param_name_copy32(mod, func_index, pi, &pname_buf[0]);
        let matched: bool = true;
        let j: i32 = 0;
        while (j < p_name_len && j < 32) {
          if (pname_buf[j] != base.var_name[j]) {
            matched = false;
            break;
          }
          j = j + 1;
        }
        if (matched) {
          let param_ty_ref: i32 = pipeline_module_func_param_type_ref_at(mod, func_index, pi);
          if (!ast.ref_is_null(param_ty_ref) && param_ty_ref > 0 && param_ty_ref <= arena.num_types) {
            let pty: Type = ast.ast_arena_type_get(arena, param_ty_ref);
            /* PLATFORM: SHARED — C ABI: *T and u8[] (TYPE_SLICE) params are pointers.
             * Seed/glue pass slices as struct xlang_slice_* *; field access must use ->. */
            if ((pty.kind as i32) == (TypeKind.TYPE_PTR as i32) || (pty.kind as i32) == (TypeKind.TYPE_SLICE as i32)) {
              return 1;
            }
          }
        }
      }
      pi = pi + 1;
    }
    return 0;
  }
}

/* See implementation. */
export function field_access_base_is_pointer_local(arena: *ASTArena, base_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (arena == 0 as *ASTArena || ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
      return 0;
    }
    let base: Expr = ast.ast_arena_expr_get(arena, base_ref);
    if ((base.kind as i32) != (ExprKind.EXPR_VAR as i32) || base.var_name_len <= 0) {
      return 0;
    }
    let br: i32 = 0;
    if (ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0) {
      br = pipeline_module_func_body_ref_at(ctx.current_codegen_module, ctx.current_func_index);
    }
    if (ast.ref_is_null(br) || br <= 0 || br > arena.num_blocks) {
      br = ctx.current_block_ref;
    }
    if (ast.ref_is_null(br) || br <= 0 || br > arena.num_blocks) {
      return 0;
    }
    let nlets: i32 = ast_ast_block_num_lets(arena, br);
    let li: i32 = 0;
    while (li < nlets) {
      let nl: i32 = pipeline_block_let_name_len(arena, br, li);
      if (nl == base.var_name_len && nl > 0) {
        let nb: u8[256] = [];
        pipeline_block_let_name_copy64(arena, br, li, &nb[0]);
        let eq: bool = true;
        let j: i32 = 0;
        while (j < nl && j < 64) {
          if (nb[j] != base.var_name[j]) {
            eq = false;
            break;
          }
          j = j + 1;
        }
        if (eq) {
          let tr: i32 = pipeline_block_let_type_ref(arena, br, li);
          if (!ast.ref_is_null(tr) && tr > 0 && tr <= arena.num_types) {
            let lty: Type = ast.ast_arena_type_get(arena, tr);
            if ((lty.kind as i32) == (TypeKind.TYPE_PTR as i32)) {
              return 1;
            }
          }
        }
      }
      li = li + 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function field_access_base_param_type_known(arena: *ASTArena, base_ref: i32, mod: *Module, func_index: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
      return 0;
    }
    if (mod == 0 as *Module || func_index < 0 || func_index >= mod.num_funcs) {
      return 0;
    }
    let base: Expr = ast.ast_arena_expr_get(arena, base_ref);
    if ((base.kind as i32) != (ExprKind.EXPR_VAR as i32) || base.var_name_len <= 0) {
      return 0;
    }
    let np: i32 = pipeline_module_func_num_params_at(mod, func_index);
    let pi: i32 = 0;
    while (pi < np) {
      let p_name_len: i32 = pipeline_module_func_param_name_len_at(mod, func_index, pi);
      if (p_name_len > 0 && p_name_len == base.var_name_len) {
        let pname_buf: u8[256] = [];
        pipeline_module_func_param_name_copy32(mod, func_index, pi, &pname_buf[0]);
        let matched: bool = true;
        let j: i32 = 0;
        while (j < p_name_len && j < 32) {
          if (pname_buf[j] != base.var_name[j]) {
            matched = false;
            break;
          }
          j = j + 1;
        }
        if (matched) {
          let param_ty_ref: i32 = pipeline_module_func_param_type_ref_at(mod, func_index, pi);
          if (!ast.ref_is_null(param_ty_ref) && param_ty_ref > 0 && param_ty_ref <= arena.num_types) {
            return 1;
          }
        }
      }
      pi = pi + 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function field_access_base_is_slice_param_name(arena: *ASTArena, base_ref: i32): i32 {
  if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
    return 0;
  }
  let base: Expr = ast.ast_arena_expr_get(arena, base_ref);
  if ((base.kind as i32) != (ExprKind.EXPR_VAR as i32) || base.var_name_len <= 0) {
    return 0;
  }
  /* See implementation. */
  if (base.var_name_len == 6) {
    if (base.var_name[0] == 115 && base.var_name[1] == 111 && base.var_name[2] == 117 && base.var_name[3] == 114 && base.var_name[4] == 99 && base.var_name[5] == 101) {
      return 1;
    }
  }
  /* See implementation. */
  if (base.var_name_len == 7) {
    if (base.var_name[0] == 111 && base.var_name[1] == 117 && base.var_name[2] == 116 && base.var_name[3] == 95 && base.var_name[4] == 98 && base.var_name[5] == 117 && base.var_name[6] == 102) {
      return 1;
    }
  }
  /* See implementation. */
  if (base.var_name_len == 6 && base.var_name[0] == 109 && base.var_name[1] == 111 && base.var_name[2] == 100 && base.var_name[3] == 117 && base.var_name[4] == 108 && base.var_name[5] == 101) {
    return 1;
  }
  if (base.var_name_len == 5 && base.var_name[0] == 97 && base.var_name[1] == 114 && base.var_name[2] == 101 && base.var_name[3] == 110 && base.var_name[4] == 97) {
    return 1;
  }
  if (base.var_name_len == 8 && base.var_name[0] == 101 && base.var_name[1] == 108 && base.var_name[2] == 102 && base.var_name[3] == 95 && base.var_name[4] == 99 && base.var_name[5] == 116 && base.var_name[6] == 120 && base.var_name[7] == 120) {
    return 1;
  }
  if (base.var_name_len == 7 && base.var_name[0] == 99 && base.var_name[1] == 117 && base.var_name[2] == 114 && base.var_name[3] == 95 && base.var_name[4] == 109 && base.var_name[5] == 111 && base.var_name[6] == 100) {
    return 1;
  }
  if (base.var_name_len == 3 && base.var_name[0] == 99 && base.var_name[1] == 116 && base.var_name[2] == 120) {
    return 1;
  }
  /* See implementation. */
  if (base.var_name_len == 7 && base.var_name[0] == 99 && base.var_name[1] == 117 && base.var_name[2] == 114 && base.var_name[3] == 95 && base.var_name[4] == 109 && base.var_name[5] == 111 && base.var_name[6] == 100) {
    return 1;
  }
  return 0;
}

/** Exported function `block_stmt_order_has_let`.
 * Implements `block_stmt_order_has_let`.
 * @param arena *ASTArena
 * @param block_ref i32
 * @param let_idx i32
 * @return i32
 */
export function block_stmt_order_has_let(arena: *ASTArena, block_ref: i32, let_idx: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let nso: i32 = ast_ast_block_num_stmt_order(arena, block_ref);
    let si: i32 = 0;
    while (si < nso) {
      if (pipeline_block_stmt_order_kind(arena, block_ref, si) == 1 && pipeline_block_stmt_order_idx(arena, block_ref, si) == let_idx) {
        return 1;
      }
      si = si + 1;
    }
    return 0;
  }
}


/* codegen_c_prefix_redundant_with_name moved earlier for monofile typeck order */


/* See implementation. */
/* See implementation. */
// Layout is codegen_outbuf.x, shared with codegen_late.x.
// PLATFORM: SHARED.
export extern function codegen_collect_generic_struct_mono_combos(module: *Module, arena: *ASTArena, layout_k: i32, layout_nm: *u8, layout_nl: i32, ntp: i32, combos_out: *i32, max_combos: i32): i32;
export extern function codegen_emit_generic_struct_mono_suffix(out: *CodegenOutBuf, arena: *ASTArena, mono_tys: *i32, ntp: i32): i32;
export extern function codegen_generic_struct_fill_concrete_args(module: *Module, arena: *ASTArena, type_ref: i32, ntp: i32, mono_out: *i32, ctx: *PipelineDepCtx): i32;
export extern function codegen_module_struct_layout_index_by_name(module: *Module, layout_nm: *u8, layout_nl: i32): i32;
export extern function codegen_type_ref_is_host_concrete(module: *Module, arena: *ASTArena, ty: i32): i32;
export extern function codegen_type_refs_same_for_mono(arena: *ASTArena, a: i32, b: i32): i32;

export extern function codegen_try_emit_impl_method_mono_call_name(out: *CodegenOutBuf, arena: *ASTArena, ctx: *PipelineDepCtx, module: *Module, fi: i32, receiver_ty: i32): i32;

export extern function codegen_emit_local_fixed_array_elem_type(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, ctx: *PipelineDepCtx): i32;

export extern function codegen_emit_local_fixed_array_suffix(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32): i32;


/* Forward decls: monofile typeck is single-pass by function order; callees defined later need early surface. PLATFORM: SHARED. */
/* Early helpers (monofile typeck single-pass order). PLATFORM: SHARED. */
/* Used by codegen_collect_generic_struct_mono_combos (~L6973) before their late defs. */
export extern function codegen_func_ret_type_param_extra(arena: *ASTArena, module: *Module, fi: i32): i32;
export extern function codegen_collect_mono_combos_for_generic_func(arena: *ASTArena, module: *Module, fi: i32, combos_out: *i32, max_combos: i32, num_params: i32, ret_extra: i32): i32;
/* Used by codegen_emit_call_func_name before late mono helpers. PLATFORM: SHARED monofile. */
export extern function codegen_call_mono_type_at(arena: *ASTArena, ei: i32, arg_idx: i32, num_args: i32): i32;
export extern function codegen_call_ret_type_param_concrete_at(arena: *ASTArena, ei: i32): i32;
export extern function codegen_emit_mono_mangled_name(out: *CodegenOutBuf, arena: *ASTArena, module: *Module, fi: i32, mono_tys: *i32, num_mono: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *ASTArena, expr_ref: i32, out: *u8): void;
export extern function pipeline_expr_var_name_len(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_module_func_param_type_ref_for_name(module: *Module, func_index: i32, name: *u8, name_len: i32): i32;

/* append helpers first */
export function codegen_append_byte(out: *CodegenOutBuf, b: i32): i32 {
  if (out.length >= 9437184) {
    return -1;
  }
  /* See implementation. */
  out.data[out.length] = (b & 255) as u8;
  out.length = out.length + 1;
  return 0;
}

export function append_byte_u8(out: *CodegenOutBuf, b: u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    return codegen_append_byte(out, b as i32);
  }
}
export function codegen_emit_bytes_4(out: *CodegenOutBuf, buf: *u8, len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let i: i32 = 0;
    while (i < len) {
      if (append_byte_u8(out, buf[i]) != 0) {
        return -1;
      }
      i = i + 1;
    }
    return 0;
  }
}

export function emit_bytes_5(out: *CodegenOutBuf, buf: *u8, len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let i: i32 = 0;
    while (i < len) {
      if (append_byte_u8(out, buf[i]) != 0) {
        return -1;
      }
      i = i + 1;
    }
    return 0;
  }
}

export function emit_bytes_6(out: *CodegenOutBuf, buf: *u8, len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let i: i32 = 0;
    while (i < len) {
      if (append_byte_u8(out, buf[i]) != 0) {
        return -1;
      }
      i = i + 1;
    }
    return 0;
  }
}

export function codegen_emit_bytes_7(out: *CodegenOutBuf, buf: *u8, len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let i: i32 = 0;
    while (i < len) {
      if (append_byte_u8(out, buf[i]) != 0) {
        return -1;
      }
      i = i + 1;
    }
    return 0;
  }
}

export function codegen_emit_bytes_8(out: *CodegenOutBuf, buf: *u8, len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let i: i32 = 0;
    while (i < len) {
      if (append_byte_u8(out, buf[i]) != 0) {
        return -1;
      }
      i = i + 1;
    }
    return 0;
  }
}

export function codegen_emit_bytes_9(out: *CodegenOutBuf, buf: *u8, len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let i: i32 = 0;
    while (i < len) {
      if (append_byte_u8(out, buf[i]) != 0) {
        return -1;
      }
      i = i + 1;
    }
    return 0;
  }
}

export function emit_bytes_22(out: *CodegenOutBuf, buf: *u8, len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let i: i32 = 0;
    while (i < len) {
      if (append_byte_u8(out, buf[i]) != 0) {
        return -1;
      }
      i = i + 1;
    }
    return 0;
  }
}

export function codegen_emit_bytes_32(out: *CodegenOutBuf, buf: *u8, len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let i: i32 = 0;
    while (i < len) {
      if (append_byte_u8(out, buf[i]) != 0) {
        return -1;
      }
      i = i + 1;
    }
    return 0;
  }
}

export function codegen_emit_bytes_64(out: *CodegenOutBuf, ptr: *u8, len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    return codegen_emit_bytes_from_ptr(out, ptr, len);
  }
}

/** Exported function `codegen_append_byte`.
 * Implements `codegen_append_byte`.
 * @param out *CodegenOutBuf
 * @param b i32
 * @return i32
 */





/** Exported function `codegen_emit_bytes_from_ptr`.
 * Implements `codegen_emit_bytes_from_ptr`.
 * @param out *CodegenOutBuf
 * @param ptr *u8
 * @param len i32
 * @return i32
 */
export function codegen_emit_bytes_from_ptr(out: *CodegenOutBuf, ptr: *u8, len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let i: i32 = 0;
    while (i < len) {
      if (append_byte_u8(out, ptr[i]) != 0) {
        return -1;
      }
      i = i + 1;
    }
    return 0;
  }
}

/** Exported function `codegen_emit_bytes_3`.
 * Implements `codegen_emit_bytes_3`.
 * @param out *CodegenOutBuf
 * @param buf u8[3]
 * @param len i32
 * @return i32
 */
export function codegen_emit_bytes_3(out: *CodegenOutBuf, buf: *u8, len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let i: i32 = 0;
    while (i < len) {
      if (append_byte_u8(out, buf[i]) != 0) {
        return -1;
      }
      i = i + 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_c_prefix_redundant_with_name(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32 {
  if (prefix == 0 as *u8 || name == 0 as *u8) {
    return 0;
  }
  if (prefix_len <= 0 || name_len < prefix_len) {
    return 0;
  }
  /* See implementation. */
  if (prefix_len == 4 && prefix[0] == 97 && prefix[1] == 115 && prefix[2] == 116 && prefix[3] == 95) {
    return 0;
  }
  let i: i32 = 0;
  while (i < prefix_len) {
    if (name[i] != prefix[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

export extern function codegen_append_byte(out: *CodegenOutBuf, b: i32): i32;
export extern function codegen_emit_expr(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *PipelineDepCtx): i32;
export extern function codegen_resolve_binding_import_dep_index(ctx: *PipelineDepCtx, arena: *ASTArena, callee_expr_ref: i32): i32;
export extern function codegen_emit_async_run_seed_push_name(out: *CodegenOutBuf, arena: *ASTArena, type_ref: i32): i32;
export extern function codegen_emit_async_sched_call_by_name(out: *CodegenOutBuf, fn_name: *u8, fn_len: i32): i32;
export extern function codegen_emit_async_task_submit_call_by_symbol(out: *CodegenOutBuf, prefix: *u8, prefix_len: i32, fn_name: *u8, fn_len: i32): i32;
export extern function codegen_c_prefix_redundant_with_name(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32;



/* codegen_append_byte moved earlier for monofile typeck order */


/** Exported function `append_byte_u8`.
 * Implements `append_byte_u8`.
 * @param out *CodegenOutBuf
 * @param b u8
 * @return i32
 */



/* codegen_emit_bytes_from_ptr moved earlier for monofile typeck order */


/**
 * See implementation.
 */

/* codegen_emit_bytes_64 early */

/** Exported function `codegen_emit_bytes_32`.
 * Implements `codegen_emit_bytes_32`.
 * @param out *CodegenOutBuf
 * @param buf u8[32]
 * @param len i32
 * @return i32
 */

/* codegen_emit_bytes_32 early */

/** Exported function `emit_bytes_22`.
 * Implements `emit_bytes_22`.
 * @param out *CodegenOutBuf
 * @param buf u8[22]
 * @param len i32
 * @return i32
 */

/* emit_bytes_22 early */

/** Exported function `codegen_emit_bytes_9`.
 * Implements `codegen_emit_bytes_9`.
 * @param out *CodegenOutBuf
 * @param buf u8[9]
 * @param len i32
 * @return i32
 */

/* codegen_emit_bytes_9 early */

/** Exported function `codegen_emit_bytes_8`.
 * Implements `codegen_emit_bytes_8`.
 * @param out *CodegenOutBuf
 * @param buf u8[8]
 * @param len i32
 * @return i32
 */

/* codegen_emit_bytes_8 early */

/** Exported function `codegen_emit_bytes_7`.
 * Implements `codegen_emit_bytes_7`.
 * @param out *CodegenOutBuf
 * @param buf u8[7]
 * @param len i32
 * @return i32
 */

/* codegen_emit_bytes_7 early */

/** Exported function `emit_bytes_6`.
 * Implements `emit_bytes_6`.
 * @param out *CodegenOutBuf
 * @param buf u8[6]
 * @param len i32
 * @return i32
 */

/* emit_bytes_6 early */

/** Exported function `emit_bytes_5`.
 * Implements `emit_bytes_5`.
 * @param out *CodegenOutBuf
 * @param buf u8[5]
 * @param len i32
 * @return i32
 */

/* emit_bytes_5 early */

/** Exported function `codegen_emit_bytes_4`.
 * Implements `codegen_emit_bytes_4`.
 * @param out *CodegenOutBuf
 * @param buf u8[4]
 * @param len i32
 * @return i32
 */

/* codegen_emit_bytes_4 early */


/* codegen_emit_bytes_3 moved earlier for monofile typeck order */

/** Exported function `codegen_emit_bytes_2`.
 * Implements `codegen_emit_bytes_2`.
 * @param out *CodegenOutBuf
 * @param buf *u8 — byte pointer (any stack array via &a[0])
 * @param len i32
 * @return i32
 */
export function codegen_emit_bytes_2(out: *CodegenOutBuf, buf: *u8, len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  // buf is *u8 (not fixed u8[2]) so u8[3] temps and longer peers can pass &a[0].
  unsafe {
    if (buf == 0 as *u8) {
      return 0 - 1;
    }
    let i: i32 = 0;
    while (i < len) {
      if (append_byte_u8(out, buf[i]) != 0) {
        return -1;
      }
      i = i + 1;
    }
    return 0;
  }
}

/** Exported function `format_uint`.
 * Implements `format_uint`.
 * @param out *CodegenOutBuf
 * @param val i32
 * @return i32
 */
// no_mangle: codegen_late calls format_uint. A codegen_ prefix misses that call.
#[no_mangle]
export function format_uint(out: *CodegenOutBuf, val: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (val >= 10) {
      let q: i32 = val / 10;
      let r: i32 = val % 10;
      if (format_uint(out, q) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 48 + r) != 0) {
        return -1;
      }
      return 0;
    }
    if (codegen_append_byte(out, 48 + val) != 0) {
      return -1;
    }
    return 0;
  }
}

/** Exported function `format_uint64`.
 * Implements `format_uint64`.
 * @param out *CodegenOutBuf
 * @param val u64
 * @return i32
 */
export function format_uint64(out: *CodegenOutBuf, val: u64): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (val >= (10 as u64)) {
      let q: u64 = val / (10 as u64);
      let r: u64 = val % (10 as u64);
      if (format_uint64(out, q) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 48 + (r as i32)) != 0) {
        return -1;
      }
      return 0;
    }
    if (codegen_append_byte(out, 48 + (val as i32)) != 0) {
      return -1;
    }
    return 0;
  }
}

/** Exported function `format_int`.
 * Implements `format_int`.
 * @param out *CodegenOutBuf
 * @param val i64
 * @return i32
 */
// no_mangle: codegen_late calls format_int. A codegen_ prefix misses that call.
#[no_mangle]
export function format_int(out: *CodegenOutBuf, val: i64): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (val >= 0) {
      return format_uint64(out, val as u64);
    }
    let u: i64 = 0 - val;
    if (u < 0) {
      /* See implementation. */
      if (codegen_append_byte(out, 45) != 0) {
        return -1;
      }
      let d: u8[20] = [57, 50, 50, 51, 51, 55, 50, 48, 51, 54, 56, 53, 52, 55, 55, 53, 56, 48, 56, 0];
      let i: i32 = 0;
      while (i < 19) {
        if (append_byte_u8(out, d[i]) != 0) {
          return -1;
        }
        i = i + 1;
      }
      return 0;
    }
    if (codegen_append_byte(out, 45) != 0) {
      return -1;
    }
    return format_uint64(out, u as u64);
  }
}

/** Exported function `codegen_emit_indent`.
 * Implements `codegen_emit_indent`.
 * @param out *CodegenOutBuf
 * @param indent i32
 * @return i32
 */
export function codegen_emit_indent(out: *CodegenOutBuf, indent: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let i: i32 = 0;
    while (i < indent) {
      if (codegen_append_byte(out, 32) != 0) {
        return -1;
      }
      i = i + 1;
    }
    return 0;
  }
}

/** Exported function `emit_break_stmt`.
 * Implements `emit_break_stmt`.
 * @param out *CodegenOutBuf
 * @param indent i32
 * @return i32
 */
export function emit_break_stmt(out: *CodegenOutBuf, indent: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (codegen_emit_indent(out, indent) != 0) {
      return -1;
    }
    let br: u8[8] = [98, 114, 101, 97, 107, 59, 10, 0];
    return codegen_emit_bytes_8(out, &br[0], 7);
  }
}

/** Exported function `emit_continue_stmt`.
 * Implements `emit_continue_stmt`.
 * @param out *CodegenOutBuf
 * @param indent i32
 * @return i32
 */
export function emit_continue_stmt(out: *CodegenOutBuf, indent: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (codegen_emit_indent(out, indent) != 0) {
      return -1;
    }
    let co: u8[11] = [99, 111, 110, 116, 105, 110, 117, 101, 59, 10, 0];
    return codegen_emit_bytes_from_ptr(out, &co[0], 10);
  }
}

/** Exported function `emit_type_kind_ord`.
 * Implements `emit_type_kind_ord`.
 * @param out *CodegenOutBuf
 * @param tk i32
 * @return i32
 */
export function emit_type_kind_ord(out: *CodegenOutBuf, tk: i32): i32 {
  return codegen_emit_type_kind(out, tk);
}

/** Exported function `codegen_emit_type_kind`.
 * Implements `codegen_emit_type_kind`.
 * @param out *CodegenOutBuf
 * @param kind_ord i32
 * @return i32
 */
export function codegen_emit_type_kind(out: *CodegenOutBuf, kind_ord: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (kind_ord == (TypeKind.TYPE_I32 as i32)) {
      let s: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
      return codegen_emit_bytes_8(out, &s[0], 7);
    }
    if (kind_ord == (TypeKind.TYPE_I64 as i32)) {
      let s: u8[8] = [105, 110, 116, 54, 52, 95, 116, 0];
      return codegen_emit_bytes_8(out, &s[0], 7);
    }
    if (kind_ord == (TypeKind.TYPE_BOOL as i32)) {
      let s: u8[4] = [105, 110, 116, 0];
      return codegen_emit_bytes_4(out, &s[0], 3);
    }
    if (kind_ord == (TypeKind.TYPE_U8 as i32)) {
      let s: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
      return codegen_emit_bytes_9(out, &s[0], 7);
    }
    if (kind_ord == (TypeKind.TYPE_U32 as i32)) {
      let s: u8[9] = [117, 105, 110, 116, 51, 50, 95, 116, 0];
      return codegen_emit_bytes_9(out, &s[0], 8);
    }
    if (kind_ord == (TypeKind.TYPE_U64 as i32)) {
      let s: u8[9] = [117, 105, 110, 116, 54, 52, 95, 116, 0];
      return codegen_emit_bytes_9(out, &s[0], 8);
    }
    if (kind_ord == (TypeKind.TYPE_F32 as i32)) {
      let s: u8[6] = [102, 108, 111, 97, 116, 0];
      return emit_bytes_6(out, &s[0], 5);
    }
    if (kind_ord == (TypeKind.TYPE_F64 as i32)) {
      let s: u8[7] = [100, 111, 117, 98, 108, 101, 0];
      return codegen_emit_bytes_7(out, &s[0], 6);
    }
    if (kind_ord == (TypeKind.TYPE_VOID as i32)) {
      let s: u8[5] = [118, 111, 105, 100, 0];
      return emit_bytes_5(out, &s[0], 4);
    }
    if (kind_ord == (TypeKind.TYPE_USIZE as i32)) {
      let s: u8[7] = [115, 105, 122, 101, 95, 116, 0];
      return codegen_emit_bytes_7(out, &s[0], 6);
    }
    if (kind_ord == (TypeKind.TYPE_ISIZE as i32)) {
      let s: u8[8] = [115, 115, 105, 122, 101, 95, 116, 0];
      return codegen_emit_bytes_8(out, &s[0], 7);
    }
    // TYPE_DYN (17): fat trait object {data*, vtable*} host-C name.
    // Same string as pipeline_codegen_type_to_c_repr tk==17 branch and as the
    // XLANG_DYN_OBJ header struct tag. Must stay 20 bytes ("struct xlang_dyn_obj").
    // PLATFORM: SHARED host-C. G.7 single authority — do NOT duplicate elsewhere.
    if (kind_ord == (TypeKind.TYPE_DYN as i32)) {
      let s: u8[22] = [115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 100, 121, 110, 95, 111, 98, 106, 0, 0];
      return codegen_emit_bytes_from_ptr(out, &s[0], 20);
    }
    /*
     * 10.3.1: TYPE_FN (18) non-declarator fallthrough stays Cap opaque
     * `uint8_t *` (codegen_emit_type_kind). Named declarator / Cap assign cast →
     * codegen_emit_c_fnptr_decl; Cap *u8 CALL cast → codegen_try_emit_cap_u8_call
     * (slice15). Unblocks -E CG003 (codegen_emit_type_kind miss → -1).
     * PLATFORM: SHARED host-C. G.7 twin type_to_c_repr / type_kind_append.
     */
    if (kind_ord == (TypeKind.TYPE_FN as i32)) {
      let s: u8[10] = [117, 105, 110, 116, 56, 95, 116, 32, 42, 0];
      return codegen_emit_bytes_from_ptr(out, &s[0], 9);
    }
    return -1;
  }
}

/**
 * Emit the host-C dyn-dispatch function-pointer suffix after the return type.
 *
 * Completes the F3 call-site cast so extras match codegen_emit_vtable_wrapper_def.
 * Scalar extras already used codegen_emit_type_kind (f32 leftover). NAMED / PTR / SLICE
 * / ARRAY extras used to keep `, ...)` — Darwin AAPCS64 then stacks the extra
 * while the wrapper reads it from x1 (sit-red dyn_add_named/ptr/slice true
 * host-C 98/153/95; i32 extras already 7). Ubuntu SysV GP extras often fake-
 * green through the same registers as variadic.
 *
 * Shape: `(*)(void*` + `, <C-type>` for each extra + `)`. Prefer dest-stamped
 * extra arg type_ref + the same codegen_emit_type / named-array / SLICE-pointer ABI as
 * the wrapper (G.7 complete this function; no second suffix). Registry
 * param_kind remains the scalar fallback when the extra has no type_ref.
 * LINEAR / VECTOR extras still `, ...)` (not this leaf). Zero extras emit
 * `(*)(void*)`. First formal stays void* data.
 *
 * Extracted from codegen_emit_expr so the METHOD_CALL nest does not rise (nest freeze 64).
 * Not a second dispatch path: codegen_emit_expr still owns the call site.
 *
 * @param out *CodegenOutBuf — destination buffer
 * @param arena *ASTArena — extra arg type_ref + receiver trait-name lookup
 * @param ctx *PipelineDepCtx — prefix for codegen_emit_type; may be null
 * @param expr_ref i32 — METHOD_CALL expr (extra i → method_call arg i)
 * @param base_ref i32 — receiver expr_ref (TYPE_DYN; trait name source)
 * @param slot i32 — vtable slot (call_resolved_func_index)
 * @param nargs i32 — explicit extra count (not including data)
 * @return i32 — 0 on success, -1 on emit failure
 * PLATFORM: SHARED host-C; Ubuntu gold. First formal stays void* data.
 */
export function codegen_emit_dyn_host_c_fn_ptr_suffix(out: *CodegenOutBuf, arena: *ASTArena,
        ctx: *PipelineDepCtx, expr_ref: i32, base_ref: i32, slot: i32, nargs: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (out == 0 as *CodegenOutBuf) {
      return -1;
    }
    /* "(*)(void*" — 9 bytes. Typed extras follow; do not bake ", ...". */
    let open_suf: u8[9] = [40, 42, 41, 40, 118, 111, 105, 100, 42];
    if (codegen_emit_bytes_from_ptr(out, &open_suf[0], 9) != 0) {
      return -1;
    }
    let trait_nm: u8[64] = [];
    let trait_nlen: i32 = 0;
    if (arena != 0 as *ASTArena && base_ref > 0) {
      let base_ty: i32 = pipeline_expr_resolved_type_ref(arena, base_ref);
      if (base_ty > 0) {
        trait_nlen = pipeline_type_named_name_into(arena, base_ty, &trait_nm[0]);
      }
    }
    let pref: *u8 = 0 as *u8;
    let pref_len: i32 = 0;
    if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_prefix_len > 0) {
      pref = &ctx.current_codegen_prefix_mirror[0];
      pref_len = ctx.current_codegen_prefix_len;
    }
    let typed: i32 = 1;
    if (nargs > 0 && trait_nlen <= 0 && expr_ref <= 0) {
      typed = 0;
    }
    let chk: i32 = 0;
    while (chk < nargs) {
      let can: i32 = 0;
      let ty: i32 = 0;
      if (arena != 0 as *ASTArena && expr_ref > 0) {
        let arg_ref: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, chk);
        if (arg_ref > 0 && !ast.ref_is_null(arg_ref)) {
          ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
        }
      }
      if (ty > 0) {
        let tk: i32 = pipeline_type_kind_ord_at(arena, ty);
        /* LINEAR / VECTOR stay the variadic leftover (not this leaf). */
        if (tk != (TypeKind.TYPE_LINEAR as i32) && tk != (TypeKind.TYPE_VECTOR as i32)) {
          can = 1;
        }
      }
      if (can == 0) {
        let pk: i32 = -1;
        if (trait_nlen > 0) {
          pk = xlang_skip_trait_method_param_kind_c(&trait_nm[0], trait_nlen, slot, chk + 1);
        }
        if (pk == (TypeKind.TYPE_I32 as i32)) { can = 1; }
        if (pk == (TypeKind.TYPE_BOOL as i32)) { can = 1; }
        if (pk == (TypeKind.TYPE_U8 as i32)) { can = 1; }
        if (pk == (TypeKind.TYPE_U32 as i32)) { can = 1; }
        if (pk == (TypeKind.TYPE_U64 as i32)) { can = 1; }
        if (pk == (TypeKind.TYPE_I64 as i32)) { can = 1; }
        if (pk == (TypeKind.TYPE_USIZE as i32)) { can = 1; }
        if (pk == (TypeKind.TYPE_ISIZE as i32)) { can = 1; }
        if (pk == (TypeKind.TYPE_F32 as i32)) { can = 1; }
        if (pk == (TypeKind.TYPE_F64 as i32)) { can = 1; }
        if (pk == (TypeKind.TYPE_VOID as i32)) { can = 1; }
        if (pk == (TypeKind.TYPE_DYN as i32)) { can = 1; }
      }
      if (can == 0) {
        typed = 0;
      }
      chk = chk + 1;
    }
    if (typed == 0) {
      /* ", ...)" — 6 bytes. Leftover only when an extra still cannot emit. */
      let varargs: u8[6] = [44, 32, 46, 46, 46, 41];
      return codegen_emit_bytes_from_ptr(out, &varargs[0], 6);
    }
    chk = 0;
    while (chk < nargs) {
      if (codegen_append_byte(out, 44) != 0) { return -1; }
      if (codegen_append_byte(out, 32) != 0) { return -1; }
      let ty2: i32 = 0;
      if (arena != 0 as *ASTArena && expr_ref > 0) {
        let arg_ref2: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, chk);
        if (arg_ref2 > 0 && !ast.ref_is_null(arg_ref2)) {
          ty2 = pipeline_expr_resolved_type_ref(arena, arg_ref2);
        }
      }
      if (ty2 > 0) {
        /* Same C form as wrapper extras: named-array / codegen_emit_type / SLICE *. */
        if (type_uses_named_array_decl(arena, ty2) != 0) {
          if (codegen_emit_c_ptr_to_fixed_array_decl(arena, out, ty2, 0 as *u8, 0, ctx) != 0) {
            return -1;
          }
        } else {
          if (codegen_emit_type(arena, out, ty2, pref, pref_len, ctx) != 0) {
            return -1;
          }
          if (pipeline_type_kind_ord_at(arena, ty2) == (TypeKind.TYPE_SLICE as i32)) {
            if (codegen_append_byte(out, 32) != 0) { return -1; }
            if (codegen_append_byte(out, 42) != 0) { return -1; }
          }
        }
      } else {
        let pk2: i32 = xlang_skip_trait_method_param_kind_c(&trait_nm[0], trait_nlen,
                slot, chk + 1);
        if (codegen_emit_type_kind(out, pk2) != 0) {
          return -1;
        }
      }
      chk = chk + 1;
    }
    /* ")" close the function-pointer parameter list. */
    return codegen_append_byte(out, 41);
  }
}

/** Exported function `type_kind_append_to_scratch`.
 * Implements `type_kind_append_to_scratch`.
 * @param scratch *u8
 * @param cap i32
 * @param w i32
 * @param kind_ord i32
 * @return i32
 */
export function type_kind_append_to_scratch(scratch: *u8, cap: i32, w: i32, kind_ord: i32): i32 {
  if (kind_ord == (TypeKind.TYPE_I32 as i32)) {
    let s: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
    let i: i32 = 0;
    while (i < 7) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_I64 as i32)) {
    let s: u8[8] = [105, 110, 116, 54, 52, 95, 116, 0];
    let i: i32 = 0;
    while (i < 7) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_BOOL as i32)) {
    let s: u8[4] = [105, 110, 116, 0];
    let i: i32 = 0;
    while (i < 3) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_U8 as i32)) {
    let s: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
    let i: i32 = 0;
    while (i < 7) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_U32 as i32)) {
    let s: u8[9] = [117, 105, 110, 116, 51, 50, 95, 116, 0];
    let i: i32 = 0;
    while (i < 8) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_U64 as i32)) {
    let s: u8[9] = [117, 105, 110, 116, 54, 52, 95, 116, 0];
    let i: i32 = 0;
    while (i < 8) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_F32 as i32)) {
    let s: u8[6] = [102, 108, 111, 97, 116, 0];
    let i: i32 = 0;
    while (i < 5) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_F64 as i32)) {
    let s: u8[7] = [100, 111, 117, 98, 108, 101, 0];
    let i: i32 = 0;
    while (i < 6) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_VOID as i32)) {
    let s: u8[5] = [118, 111, 105, 100, 0];
    let i: i32 = 0;
    while (i < 4) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_USIZE as i32)) {
    let s: u8[7] = [115, 105, 122, 101, 95, 116, 0];
    let i: i32 = 0;
    while (i < 6) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_ISIZE as i32)) {
    let s: u8[8] = [115, 115, 105, 122, 101, 95, 116, 0];
    let i: i32 = 0;
    while (i < 7) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  // TYPE_DYN (17): fat trait object host-C name. Twin of codegen_emit_type_kind
  // TYPE_DYN branch; must stay 20 bytes. PLATFORM: SHARED host-C.
  if (kind_ord == (TypeKind.TYPE_DYN as i32)) {
    let s: u8[22] = [115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 100, 121, 110, 95, 111, 98, 106, 0, 0];
    let i: i32 = 0;
    while (i < 20) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  /* 10.3.1: TYPE_FN → uint8_t * (Cap opaque ABI). Twin codegen_emit_type_kind. */
  if (kind_ord == (TypeKind.TYPE_FN as i32)) {
    let s: u8[10] = [117, 105, 110, 116, 56, 95, 116, 32, 42, 0];
    let i: i32 = 0;
    while (i < 9) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  return -1;
}

/** Exported function `emit_vector_c_type_out`.
 * Implements `emit_vector_c_type_out`.
 * Emits the C type name (i32x4_t / u32x8_t / f32x4_t ...) for a VECTOR type
 * given its element TypeKind ord and lane count. The emitted names must match
 * the typedefs in seeds/rt_preamble.from_x.c (§10 vector block).
 * PLATFORM: SHARED — used by both C and asm codegen paths.
 * @param out *CodegenOutBuf
 * @param elem_kind_ord i32 — TypeKind ord of the vector element (I32/U32/F32)
 * @param lanes i32 — 4 / 8 / 16
 * @return i32
 */
export function emit_vector_c_type_out(out: *CodegenOutBuf, elem_kind_ord: i32, lanes: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (elem_kind_ord == (TypeKind.TYPE_I32 as i32)) {
      if (lanes == 4) {
        let s: u8[8] = [105, 51, 50, 120, 52, 95, 116, 0];
        return codegen_emit_bytes_from_ptr(out, &s[0], 7);
      }
      if (lanes == 8) {
        let s: u8[8] = [105, 51, 50, 120, 56, 95, 116, 0];
        return codegen_emit_bytes_from_ptr(out, &s[0], 7);
      }
      if (lanes == 16) {
        let sa: u8[9] = [105, 51, 50, 120, 49, 54, 95, 116, 0];
        return codegen_emit_bytes_from_ptr(out, &sa[0], 8);
      }
    }
    if (elem_kind_ord == (TypeKind.TYPE_U32 as i32)) {
      if (lanes == 4) {
        let s: u8[8] = [117, 51, 50, 120, 52, 95, 116, 0];
        return codegen_emit_bytes_from_ptr(out, &s[0], 7);
      }
      if (lanes == 8) {
        let s: u8[8] = [117, 51, 50, 120, 56, 95, 116, 0];
        return codegen_emit_bytes_from_ptr(out, &s[0], 7);
      }
      if (lanes == 16) {
        let sa: u8[9] = [117, 51, 50, 120, 49, 54, 95, 116, 0];
        return codegen_emit_bytes_from_ptr(out, &sa[0], 8);
      }
    }
    /* F32 vector: "f32x4_t" / "f32x8_t" / "f32x16_t". Without this branch, Vec4f
     * falls through to the int32_t default and collides with Vec8i overloads. */
    if (elem_kind_ord == (TypeKind.TYPE_F32 as i32)) {
      if (lanes == 4) {
        let s: u8[8] = [102, 51, 50, 120, 52, 95, 116, 0];
        return codegen_emit_bytes_from_ptr(out, &s[0], 7);
      }
      if (lanes == 8) {
        let s: u8[8] = [102, 51, 50, 120, 56, 95, 116, 0];
        return codegen_emit_bytes_from_ptr(out, &s[0], 7);
      }
      if (lanes == 16) {
        let sa: u8[9] = [102, 51, 50, 120, 49, 54, 95, 116, 0];
        return codegen_emit_bytes_from_ptr(out, &sa[0], 8);
      }
    }
    let df: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
    return codegen_emit_bytes_from_ptr(out, &df[0], 7);
  }
}

/** Exported function `type_kind_append_to_scratch_ord`.
 * Implements `type_kind_append_to_scratch_ord`.
 * @param scratch *u8
 * @param cap i32
 * @param w i32
 * @param tk i32
 * @return i32
 */
export function type_kind_append_to_scratch_ord(scratch: *u8, cap: i32, w: i32, tk: i32): i32 {
  let w2: i32 = type_kind_append_to_scratch(scratch, cap, w, tk);
  if (w2 < 0) {
    return type_kind_append_to_scratch(scratch, cap, w, TypeKind.TYPE_I32 as i32);
  }
  return w2;
}

/** Exported function `type_to_c_repr`.
 * Implements `type_to_c_repr`.
 * @param arena *ASTArena
 * @param scratch *u8
 * @param cap i32
 * @param type_ref i32
 * @param struct_prefix *u8
 * @param struct_prefix_len i32
 * @return i32
 */
export function type_to_c_repr(arena: *ASTArena, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    return pipeline_codegen_type_to_c_repr(arena, scratch, cap, type_ref, struct_prefix, struct_prefix_len);
  }
}

/** Exported function `codegen_emit_type`.
 * Implements `codegen_emit_type`.
 * @param arena *ASTArena
 * @param out *CodegenOutBuf
 * @param type_ref i32
 * @param struct_prefix *u8
 * @param struct_prefix_len i32
 * @param ctx *PipelineDepCtx
 * @return i32
 */
export function codegen_emit_type(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let tk: i32 = 0;
    let elem_ref: i32 = 0;
    let arr_sz: i32 = 0;
    let elem_kind: i32 = 0;
    let name_len: i32 = 0;
    let nm: u8[256] = [];

    if (ast.ref_is_null(type_ref)) {
      let s: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
      return codegen_emit_bytes_8(out, &s[0], 7);
    }
    /*
     * wave376 Cap residual: host-C must not emit `struct ast_Coord` for
     * `type Coord = i32` (incomplete type BLD001). Peel aliases to the
     * underlying TYPE_* / named struct before kind dispatch.
     * PLATFORM: SHARED — resolve uses active module from typeck phase.
     */
    type_ref = pipeline_typeck_resolve_type_alias_ref_c(arena, type_ref);
    if (ast.ref_is_null(type_ref)) {
      let s2: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
      return codegen_emit_bytes_8(out, &s2[0], 7);
    }
    /*
     * wave445 C5: monomorphization type substitution. When mono_active=1 (emitting a
     * generic function's mono body), replace any type_ref matching a generic type param
     * (T, U, ...) with the corresponding concrete type_ref (A, B, ...). This handles
     * `let y: T` -> `let y: A` and param/return type refs encountered during body walk.
     *
     * Two-stage match:
     *   1. Direct type_ref equality — works when body type_ref shares the param's
     *      type_ref node (e.g. the param's own declared type).
     *   2. Name-based fallback — typeck does NOT always reuse the param's type_ref node
     *      for body occurrences; `let y: T` allocates a fresh TYPE_NAMED with name "T"
     *      whose type_ref differs from the param's. We compare the type's name against
     *      each generic param's name and substitute on match. Builtin types (i32, etc.)
     *      have no name (pipeline_type_named_name_into returns 0), so they skip the
     *      fallback and rely on direct equality, which is stable for builtins.
     *
     * No infinite recursion (wave447): when value params are builtins (i32), mono
     * maps param type_ref → call-arg type_ref; typeck often reuses the same i32
     * type_ref node, so generic==concrete. Recursing codegen_emit_type on the same ref
     * stack-overflows (SEGV in resolve_type_alias). Guard: only recurse when
     * concrete != type_ref. Identity T→A still recurses once then emits A.
     * PLATFORM: SHARED — mono state in PipelineDepCtx (L4 ABI); gated by mono_active.
     */
    if (ctx != 0 as *PipelineDepCtx && ctx.mono_active != 0 && ctx.mono_num_types > 0) {
      let mi: i32 = 0;
      while (mi < ctx.mono_num_types && mi < 8) {
        let conc: i32 = ctx.mono_concrete_type_refs[mi];
        if (type_ref == ctx.mono_generic_type_refs[mi] && conc > 0 && conc != type_ref) {
          return codegen_emit_type(arena, out, conc, struct_prefix, struct_prefix_len, ctx);
        }
        mi = mi + 1;
      }
      /*
       * wave445 C5 name-match fallback: cover body TYPE_NAMED nodes whose type_ref
       * differs from the param's (e.g. `let y: T`). Compare names; substitute on
       * equality. Mirrors codegen_find_impl_method_for_type C6 name-match fallback.
       * wave447: also skip when concrete == type_ref (self-map).
       */
      let fb_nm: u8[256] = [];
      let fb_len: i32 = pipeline_type_named_name_into(arena, type_ref, &fb_nm[0]);
      if (fb_len > 0) {
        let mi2: i32 = 0;
        while (mi2 < ctx.mono_num_types && mi2 < 8) {
          let conc2: i32 = ctx.mono_concrete_type_refs[mi2];
          if (conc2 > 0 && conc2 != type_ref) {
            let gnm: u8[256] = [];
            let gname_len: i32 = pipeline_type_named_name_into(arena, ctx.mono_generic_type_refs[mi2], &gnm[0]);
            if (gname_len == fb_len && gname_len > 0) {
              let names_eq: i32 = 1;
              let ci: i32 = 0;
              while (ci < gname_len) {
                if (gnm[ci] != fb_nm[ci]) {
                  names_eq = 0;
                  ci = gname_len;
                } else {
                  ci = ci + 1;
                }
              }
              if (names_eq != 0) {
                return codegen_emit_type(arena, out, conc2, struct_prefix, struct_prefix_len, ctx);
              }
            }
          }
          mi2 = mi2 + 1;
        }
      }
    }
    tk = pipeline_type_kind_ord_at(arena, type_ref);
    elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
    arr_sz = pipeline_type_array_size_at(arena, type_ref);
    if (tk == TypeKind.TYPE_PTR as i32 && !ast.ref_is_null(elem_ref)) {
      /*
       * PTR → TYPE_ARRAY (`*[N]T`). C cannot host abstract `E (*)[N]` before
       * a function name (`int32_t (*)[2] getpa()` is invalid). Return /
       * fn-ptr ABI peels to first-element `E *`, matching `[N]T` return.
       * Named locals/params still use codegen_emit_c_ptr_to_fixed_array_decl
       * (`E (*name)[N]`). Sit-red dyn_ret_ptr_arr host-C void-cast then
       * `int32_t (*)[2] getpa` after dest-stamp.
       * G.7 complete this codegen_emit_type branch (no second return emitter).
       * PLATFORM: SHARED host-C.
       */
      if (pipeline_type_kind_ord_at(arena, elem_ref) == (TypeKind.TYPE_ARRAY as i32)) {
        if (codegen_emit_local_fixed_array_elem_type(arena, out, elem_ref, ctx) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 32) != 0) {
          return -1;
        }
        return codegen_append_byte(out, 42);
      }
      if (codegen_emit_type(arena, out, elem_ref, struct_prefix, struct_prefix_len, ctx) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 32) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 42);
    }
    name_len = pipeline_type_named_name_into(arena, type_ref, &nm[0]);
    if (tk == TypeKind.TYPE_NAMED as i32 && name_len > 0) {
      let dep_prefix_buf: u8[256] = [];
      let dep_prefix_len: i32 = 0;
      /* Cap 10.7.1 slice7: VaList → xlang_va_list (header from emit_header). */
      if (name_len == 6 && nm[0] == 86 && nm[1] == 97 && nm[2] == 76
          && nm[3] == 105 && nm[4] == 115 && nm[5] == 116) {
        let vl: u8[14] = [120, 108, 97, 110, 103, 95, 118, 97, 95, 108, 105, 115, 116, 0];
        return codegen_emit_bytes_from_ptr(out, &vl[0], 13);
      }
      /* See implementation. */
      if (name_len == 6 && nm[0] == 66 && nm[1] == 117 && nm[2] == 102 && nm[3] == 102
          && nm[4] == 101 && nm[5] == 114) {
        let io_buf: u8[22] = [115, 116, 114, 117, 99, 116, 32, 115, 116, 100, 95, 105, 111, 95, 66, 117, 102, 102, 101, 114, 0, 0];
        return codegen_emit_bytes_from_ptr(out, &io_buf[0], 20);
      }
      /*
       * See implementation.
       * See implementation.
       * See implementation.
       * See implementation.
       * See implementation.
       */
      if (name_len >= 8 && nm[0] == 79 && nm[1] == 112 && nm[2] == 116 && nm[3] == 105
          && nm[4] == 111 && nm[5] == 110 && nm[6] == 95) {
        let opt_head: u8[20] = [115, 116, 114, 117, 99, 116, 32, 99, 111, 114, 101, 95, 111, 112, 116, 105, 111, 110, 95, 0];
        if (codegen_emit_bytes_from_ptr(out, &opt_head[0], 19) != 0) {
          return -1;
        }
        let oi: i32 = 0;
        while (oi < name_len && oi < 64) {
          if (append_byte_u8(out, nm[oi]) != 0) {
            return -1;
          }
          oi = oi + 1;
        }
        return 0;
      }
      /*
       * ABI-dup canonical tag for Result_* mono shorts (same class as Option_*):
       * rt_preamble owns complete `struct core_result_Result_{i32,u8}`; layout co-emit
       * is skipped (codegen_should_skip_emit_struct_layout_for_abi_dup). STRUCT_LIT
       * already prefixes `core_result_` (see struct_lit path), but bare codegen_emit_type of
       * TYPE_NAMED `Result_i32` / `Result_u8` previously emitted incomplete
       * `struct Result_*` → host-cc "incomplete result type" on formal core/result
       * and forced a shell `#define Result_i32 core_result_Result_i32` dual-authority
       * in xlang_compile_std_module.sh.
       * Root fix (G.7 single authority): codegen_emit_type rewrites short Result_* to
       * `struct core_result_` + full name, matching Option_ / STRUCT_LIT / preamble.
       * Covers Result_i32 (10), Result_u8 (9), and future Result_* mono suffixes.
       * PLATFORM: SHARED — product codegen_x FROM_X; dual-end L2 (mac + Ubuntu).
       */
      if (name_len >= 8 && nm[0] == 82 && nm[1] == 101 && nm[2] == 115 && nm[3] == 117
          && nm[4] == 108 && nm[5] == 116 && nm[6] == 95) {
        /* "struct core_result_" — 19 bytes; then append Result_i32 / Result_u8 / … */
        let res_head: u8[20] = [115, 116, 114, 117, 99, 116, 32, 99, 111, 114, 101, 95, 114, 101, 115, 117, 108, 116, 95, 0];
        if (codegen_emit_bytes_from_ptr(out, &res_head[0], 19) != 0) {
          return -1;
        }
        let ri: i32 = 0;
        while (ri < name_len && ri < 64) {
          if (append_byte_u8(out, nm[ri]) != 0) {
            return -1;
          }
          ri = ri + 1;
        }
        return 0;
      }
      /*
       * ABI-dup canonical tag: rt_preamble owns `struct std_string_String` (+ typedef
       * String) and `struct std_string_StrView`; the per-module layout is skipped
       * (codegen_should_skip_emit_struct_layout_for_abi_dup). Bare `struct String`
       * is therefore an INCOMPLETE host-C type that mismatches the STRUCT_LIT
       * compound literal `struct std_string_String` emitted in function bodies →
       * host-cc "returning 'struct std_string_String' from incompatible result type
       * 'struct String'" (std/string/mod.x -x -E entry-only path).
       * Root fix: codegen_emit_type must use the same canonical namespaced tag as the
       * STRUCT_LIT emitter (codegen.x:12568-12580) and rt_preamble authority.
       * Mirrors the existing Buffer→struct std_io_Buffer pattern above.
       * PLATFORM: SHARED — seed pin same commit; G.8 dual-end L2.
       */
      if (name_len == 6 && nm[0] == 83 && nm[1] == 116 && nm[2] == 114
          && nm[3] == 105 && nm[4] == 110 && nm[5] == 103) {
        /* "struct std_string_String" — canonical preamble tag. */
        let s_string: u8[26] = [115, 116, 114, 117, 99, 116, 32, 115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 83, 116, 114, 105, 110, 103, 0, 0];
        return codegen_emit_bytes_from_ptr(out, &s_string[0], 24);
      }
      if (name_len == 7 && nm[0] == 83 && nm[1] == 116 && nm[2] == 114
          && nm[3] == 86 && nm[4] == 105 && nm[5] == 101 && nm[6] == 119) {
        /* "struct std_string_StrView" — canonical preamble tag. */
        let s_view: u8[27] = [115, 116, 114, 117, 99, 116, 32, 115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 83, 116, 114, 86, 105, 101, 119, 0, 0];
        return codegen_emit_bytes_from_ptr(out, &s_view[0], 25);
      }
      /*
       * ABI-dup canonical tags (same class as String/Buffer):
       * rt_preamble owns `struct std_error_Error` / `struct std_error_ErrorChain`
       * / `struct std_heap_Allocator`; per-module layouts are skipped by
       * codegen_should_skip_emit_struct_layout_for_abi_dup. Bare `struct Error`
       * as a function result type is incomplete host-C while STRUCT_LIT already
       * emits `struct std_error_Error` → host-cc fail on std/error (and heap).
       * Root fix: codegen_emit_type uses the same canonical namespaced tags.
       * PLATFORM: SHARED — seed pin same commit; G.8 dual-end L2.
       */
      if (name_len == 5 && nm[0] == 69 && nm[1] == 114 && nm[2] == 114
          && nm[3] == 111 && nm[4] == 114) {
        /* "struct std_error_Error" — 22 bytes. */
        let s_err: u8[24] = [115, 116, 114, 117, 99, 116, 32, 115, 116, 100, 95, 101, 114, 114, 111, 114, 95, 69, 114, 114, 111, 114, 0, 0];
        return codegen_emit_bytes_from_ptr(out, &s_err[0], 22);
      }
      if (name_len == 10 && nm[0] == 69 && nm[1] == 114 && nm[2] == 114
          && nm[3] == 111 && nm[4] == 114 && nm[5] == 67 && nm[6] == 104
          && nm[7] == 97 && nm[8] == 105 && nm[9] == 110) {
        /* "struct std_error_ErrorChain" — 27 bytes. */
        let s_chain: u8[28] = [115, 116, 114, 117, 99, 116, 32, 115, 116, 100, 95, 101, 114, 114, 111, 114, 95, 69, 114, 114, 111, 114, 67, 104, 97, 105, 110, 0];
        return codegen_emit_bytes_from_ptr(out, &s_chain[0], 27);
      }
      if (name_len == 9 && nm[0] == 65 && nm[1] == 108 && nm[2] == 108
          && nm[3] == 111 && nm[4] == 99 && nm[5] == 97 && nm[6] == 116
          && nm[7] == 111 && nm[8] == 114) {
        /* "struct std_heap_Allocator" — 25 bytes. */
        let s_alloc: u8[26] = [115, 116, 114, 117, 99, 116, 32, 115, 116, 100, 95, 104, 101, 97, 112, 95, 65, 108, 108, 111, 99, 97, 116, 111, 114, 0];
        return codegen_emit_bytes_from_ptr(out, &s_alloc[0], 25);
      }
      if (name_len == 7 && nm[0] == 65 && nm[1] == 114 && nm[2] == 101
          && nm[3] == 110 && nm[4] == 97 && nm[5] == 54 && nm[6] == 52) {
        /* "struct std_heap_Arena64" — 23 bytes. Preamble owns layout (abi_dup skip). */
        let s_arena: u8[24] = [115, 116, 114, 117, 99, 116, 32, 115, 116, 100, 95, 104, 101, 97, 112, 95, 65, 114, 101, 110, 97, 54, 52, 0];
        return codegen_emit_bytes_from_ptr(out, &s_arena[0], 23);
      }
      /* See implementation. */
      if (name_len == 3 && nm[0] == 117 && nm[1] == 49 && nm[2] == 54) {
        let u16_t: u8[9] = [117, 105, 110, 116, 49, 54, 95, 116, 0];
        return codegen_emit_bytes_8(out, &u16_t[0], 8);
      }
      if (name_len == 3 && nm[0] == 105 && nm[1] == 49 && nm[2] == 54) {
        let i16_t: u8[8] = [105, 110, 116, 49, 54, 95, 116, 0];
        return codegen_emit_bytes_8(out, &i16_t[0], 7);
      }
      if (name_len == 2 && nm[0] == 105 && nm[1] == 56) {
        let i8_t: u8[7] = [105, 110, 116, 56, 95, 116, 0];
        return codegen_emit_bytes_8(out, &i8_t[0], 6);
      }
      /*
       * See implementation.
       * See implementation.
       */
      if (name_len == 5 && nm[0] == 105 && nm[1] == 51 && nm[2] == 50 && nm[3] == 120 && nm[4] == 52) {
        return emit_vector_c_type_out(out, TypeKind.TYPE_I32 as i32, 4);
      }
      if (name_len == 5 && nm[0] == 105 && nm[1] == 51 && nm[2] == 50 && nm[3] == 120 && nm[4] == 56) {
        return emit_vector_c_type_out(out, TypeKind.TYPE_I32 as i32, 8);
      }
      if (name_len == 5 && nm[0] == 117 && nm[1] == 51 && nm[2] == 50 && nm[3] == 120 && nm[4] == 52) {
        return emit_vector_c_type_out(out, TypeKind.TYPE_U32 as i32, 4);
      }
      if (name_len == 5 && nm[0] == 117 && nm[1] == 51 && nm[2] == 50 && nm[3] == 120 && nm[4] == 56) {
        return emit_vector_c_type_out(out, TypeKind.TYPE_U32 as i32, 8);
      }
      if (name_len == 6 && nm[0] == 105 && nm[1] == 51 && nm[2] == 50 && nm[3] == 120 && nm[4] == 49 && nm[5] == 54) {
        return emit_vector_c_type_out(out, TypeKind.TYPE_I32 as i32, 16);
      }
      if (name_len == 6 && nm[0] == 117 && nm[1] == 51 && nm[2] == 50 && nm[3] == 120 && nm[4] == 49 && nm[5] == 54) {
        return emit_vector_c_type_out(out, TypeKind.TYPE_U32 as i32, 16);
      }
      /* See implementation. */
      if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module
          && codegen_type_is_module_user_enum(ctx.current_codegen_module, arena, type_ref) != 0) {
        let i32_enum: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
        return codegen_emit_bytes_8(out, &i32_enum[0], 7);
      }
      /* See implementation. */
      if (ctx != 0 as *PipelineDepCtx) {
        let dep_enum_prefix: u8[256] = [];
        let dep_enum_prefix_len: i32 = codegen_type_dep_enum_prefix_into(ctx, arena, type_ref, &dep_enum_prefix[0], 128);
        if (dep_enum_prefix_len > 0) {
          let e: u8[8] = [101, 110, 117, 109, 32, 0, 0, 0];
          if (codegen_emit_bytes_8(out, &e[0], 5) != 0) {
            return -1;
          }
          if (codegen_emit_bytes_from_ptr(out, &dep_enum_prefix[0], dep_enum_prefix_len) != 0) {
            return -1;
          }
          let bare_off2: i32 = 0;
          let bi2: i32 = 0;
          while (bi2 < name_len && bi2 < 64) {
            if (nm[bi2] == 46) {
              bare_off2 = bi2 + 1;
            }
            bi2 = bi2 + 1;
          }
          let ci2: i32 = bare_off2;
          while (ci2 < name_len && ci2 < 128) {
            if (append_byte_u8(out, nm[ci2]) != 0) {
              return -1;
            }
            ci2 = ci2 + 1;
          }
          return 0;
        }
      }
      let s: u8[8] = [115, 116, 114, 117, 99, 116, 32, 0];
      if (codegen_emit_bytes_8(out, &s[0], 7) != 0) {
        return -1;
      }
      dep_prefix_len = codegen_type_dep_struct_prefix_into(ctx, arena, type_ref, &dep_prefix_buf[0], 128);
      /* See implementation. */
      if (dep_prefix_len == 0) {
        let qmod_end: i32 = 0;
        let qhas_dot: bool = false;
        let qi: i32 = 0;
        while (qi < name_len && qi < 64) {
          if (nm[qi] == 46) {
            qhas_dot = true;
            qmod_end = qi;
          }
          qi = qi + 1;
        }
        if (qhas_dot && qmod_end > 0 && qmod_end < 64) {
          let mod_path: u8[256] = [];
          let mi: i32 = 0;
          while (mi < qmod_end) {
            mod_path[mi] = nm[mi];
            mi = mi + 1;
          }
          mod_path[mi] = 0 as u8;
          codegen_import_path_to_c_prefix_into(&mod_path[0], &dep_prefix_buf[0], 128);
          dep_prefix_len = 0;
          while (dep_prefix_len < 128 && dep_prefix_buf[dep_prefix_len] != 0 as u8) {
            dep_prefix_len = dep_prefix_len + 1;
          }
        }
      }
      /* See implementation. */
      if (dep_prefix_len > 0) {
        if (codegen_emit_bytes_from_ptr(out, &dep_prefix_buf[0], dep_prefix_len) != 0) {
          return -1;
        }
      } else if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
        if (codegen_emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) != 0) {
          return -1;
        }
      } else if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module
          && codegen_type_is_module_user_struct(ctx.current_codegen_module, arena, type_ref) != 0) {
        /* See implementation. */
        let cur_pre: u8[256] = [];
        let cur_pre_len: i32 = codegen_emit_prefix_len_from_ctx(ctx, &cur_pre[0], 128);
        if (cur_pre_len > 0 && codegen_emit_bytes_from_ptr(out, &cur_pre[0], cur_pre_len) != 0) {
          return -1;
        }
      } else if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_dep_index < 0) {
        /* wave624: entry module bare tag — match codegen_emit_module_struct_definitions. */
      } else {
        /* dep / no-ctx fallback: historical ast_ prefix */
        let ast_p: u8[4] = [97, 115, 116, 95];
        if (codegen_emit_bytes_4(out, &ast_p[0], 4) != 0) {
          return -1;
        }
      }
      /* See implementation. */
      let bare_off: i32 = 0;
      let bi: i32 = 0;
      while (bi < name_len && bi < 64) {
        if (nm[bi] == 46) {
          bare_off = bi + 1;
        }
        bi = bi + 1;
      }
      let ci: i32 = bare_off;
      while (ci < name_len && ci < 128) {
        if (append_byte_u8(out, nm[ci]) != 0) {
          return -1;
        }
        ci = ci + 1;
      }
      /*
       * wave481 + tag unify: generic struct multi mono C tag — append `_A` /
       * `_i32_i32` when TYPE_NAMED carries concrete type-pos args (Wrap&lt;A&gt;).
       * Matches typeck named-inst + mangled defs from
       * codegen_emit_module_struct_definitions. PLATFORM: SHARED host-C.
       */
      if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module) {
        if (codegen_maybe_emit_generic_struct_mono_suffix_for_type(ctx.current_codegen_module, arena, out, type_ref, ctx) != 0) {
          return -1;
        }
      }
      return 0;
    }
    /*
     * TYPE_ARRAY abstract decay is one `E *` (pointer to first element).
     * `[N]T` peels once: codegen_emit_type(elem) + ` *` → `int32_t *`.
     * `[K][N]T` must not recurse: codegen_emit_type(elem=`[N]T`) is already `E *`,
     * then another ` *` produced `int32_t * *` (sit-red dyn_ret_arr2 /
     * named-local host-C: `int32_t ** rp = t` Ubuntu -Wincompatible-pointer-types;
     * mac clang warning + memcpy of two row-pointer bit patterns false-green 10).
     * G.7: complete this decay — peel every ARRAY layer to the leaf via
     * codegen_emit_local_fixed_array_elem_type, then one star. Named params/extras
     * still use codegen_emit_c_ptr_to_fixed_array_decl (`E (*name)[N]`); this path
     * is return types, wrapper ret, proto ret, and dyn call-site casts.
     * C function syntax cannot host abstract `E (*)[N]` before the name
     * (`int32_t (*)[2] get22()` is invalid); first-element `E *` matches
     * `[N]T` ABI and memcpy(sizeof dest) consumers.
     * PLATFORM: SHARED host-C emit; Ubuntu gold.
     */
    if (tk == TypeKind.TYPE_ARRAY as i32 && !ast.ref_is_null(elem_ref)) {
      if (pipeline_type_kind_ord_at(arena, elem_ref) == (TypeKind.TYPE_ARRAY as i32)) {
        if (codegen_emit_local_fixed_array_elem_type(arena, out, type_ref, ctx) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 32) != 0) {
          return -1;
        }
        return codegen_append_byte(out, 42);
      }
      if (codegen_emit_type(arena, out, elem_ref, struct_prefix, struct_prefix_len, ctx) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 32) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 42);
    }
    /*
     * TYPE_SLICE → `struct xlang_slice_<elemTag>`.
     * wave624 Cap residual pure: NAMED user structs must use the same C tag as
     * codegen_emit_module_struct_definitions (entry bare / module prefix / dep
     * prefix). Prior path always called type_to_c_repr with the caller's prefix
     * only — empty prefix forced `ast_` → incomplete `xlang_slice_ast_Pt` while
     * the layout was `struct Pt` / `struct mod_Pt`, and locals vs formals dual-tagged.
     * Scalar i8/i16/u16 still go through type_to_c_repr (stdint map, wave619).
     * PLATFORM: SHARED host-C. G.7: single tag authority with struct emit.
     *
     * wave689 Cap residual: free []T mono ret/body.
     * Identity map keys the formal's TYPE_SLICE node; ret/body use distinct []T
     * nodes so C5 type_ref equality fails. TYPE_SLICE NAMED-elem path never
     * recurses codegen_emit_type(elem) (unlike TYPE_PTR), so wave688 free-T peels still
     * leave ret as incomplete `struct xlang_slice_<mod>_T` (by-value BLD001;
     * pointer ret is false-green incomplete struct *). Structural match: mono
     * gen TYPE_SLICE whose free TYPE_NAMED leaf name equals this type_ref's free
     * leaf → emit concrete ([]i32 → struct xlang_slice_int32_t). G.7: complete
     * same codegen_emit_type authority (not a second subst path).
     *
     * wave690 Cap residual: free []T when mono maps bare T only.
     * take_two<T>(a:T,b:T):[]T formals are TYPE_NAMED T→i32; wave689 only matches
     * gen TYPE_SLICE (formal was []T). Ret/body distinct []T + ARRAY_LIT fat still
     * emit incomplete `struct xlang_slice_<mod>_T` / `struct xlang_slice_T`.
     * Match free NAMED elem against mono gen TYPE_NAMED → wrap type_to_c_repr(concrete)
     * as fat tag (same construction as pipeline_codegen_type_to_c_repr SLICE).
     * G.7: complete same codegen_emit_type (not a second subst). PLATFORM: SHARED host-C.
     */
    if (tk == TypeKind.TYPE_SLICE as i32 && !ast.ref_is_null(elem_ref)) {
      if (ctx != 0 as *PipelineDepCtx && ctx.mono_active != 0 && ctx.mono_num_types > 0) {
        if (pipeline_type_kind_ord_at(arena, elem_ref) == (TypeKind.TYPE_NAMED as i32)) {
          let cur_sl_nm: u8[256] = [];
          let cur_sl_nl: i32 = pipeline_type_named_name_into(arena, elem_ref, &cur_sl_nm[0]);
          if (cur_sl_nl > 0) {
            let mi_sl: i32 = 0;
            while (mi_sl < ctx.mono_num_types && mi_sl < 8) {
              let g_sl: i32 = ctx.mono_generic_type_refs[mi_sl];
              let c_sl: i32 = ctx.mono_concrete_type_refs[mi_sl];
              if (c_sl > 0 && c_sl != type_ref && g_sl > 0
                  && pipeline_type_kind_ord_at(arena, g_sl) == (TypeKind.TYPE_SLICE as i32)
                  && pipeline_type_kind_ord_at(arena, c_sl) == (TypeKind.TYPE_SLICE as i32)) {
                let e_gen_sl: i32 = pipeline_type_elem_ref_at(arena, g_sl);
                if (e_gen_sl > 0
                    && pipeline_type_kind_ord_at(arena, e_gen_sl) == (TypeKind.TYPE_NAMED as i32)) {
                  let g_sl_nm: u8[256] = [];
                  let g_sl_nl: i32 = pipeline_type_named_name_into(arena, e_gen_sl, &g_sl_nm[0]);
                  if (g_sl_nl == cur_sl_nl && g_sl_nl > 0) {
                    let eq_sl: i32 = 1;
                    let ci_sl: i32 = 0;
                    while (ci_sl < g_sl_nl) {
                      if (g_sl_nm[ci_sl] != cur_sl_nm[ci_sl]) {
                        eq_sl = 0;
                        ci_sl = g_sl_nl;
                      } else {
                        ci_sl = ci_sl + 1;
                      }
                    }
                    if (eq_sl != 0) {
                      return codegen_emit_type(arena, out, c_sl, struct_prefix, struct_prefix_len, ctx);
                    }
                  }
                }
              }
              mi_sl = mi_sl + 1;
            }
            /*
             * wave690: bare free T formals (map gen is TYPE_NAMED, not TYPE_SLICE).
             * Prefer wave689 gen-SLICE match above when present.
             */
            let mi_bt: i32 = 0;
            while (mi_bt < ctx.mono_num_types && mi_bt < 8) {
              let g_bt: i32 = ctx.mono_generic_type_refs[mi_bt];
              let c_bt: i32 = ctx.mono_concrete_type_refs[mi_bt];
              if (c_bt > 0 && c_bt != type_ref && g_bt > 0
                  && pipeline_type_kind_ord_at(arena, g_bt) == (TypeKind.TYPE_NAMED as i32)) {
                let g_bt_nm: u8[256] = [];
                let g_bt_nl: i32 = pipeline_type_named_name_into(arena, g_bt, &g_bt_nm[0]);
                if (g_bt_nl == cur_sl_nl && g_bt_nl > 0) {
                  let eq_bt: i32 = 1;
                  let ci_bt: i32 = 0;
                  while (ci_bt < g_bt_nl) {
                    if (g_bt_nm[ci_bt] != cur_sl_nm[ci_bt]) {
                      eq_bt = 0;
                      ci_bt = g_bt_nl;
                    } else {
                      ci_bt = ci_bt + 1;
                    }
                  }
                  if (eq_bt != 0) {
                    /*
                     * Fat tag = "struct xlang_slice_" + type_to_c_repr(concrete)
                     * with optional leading "struct " stripped (ast_pool twin).
                     */
                    let eb_bt: u8[896] = [];
                    let n_bt: i32 = type_to_c_repr(arena, &eb_bt[0], 896, c_bt, struct_prefix, struct_prefix_len);
                    if (n_bt > 0) {
                      let sp_bt: i32 = 0;
                      if (n_bt >= 7 && eb_bt[0] == 115 && eb_bt[1] == 116 && eb_bt[2] == 114
                          && eb_bt[3] == 117 && eb_bt[4] == 99 && eb_bt[5] == 116 && eb_bt[6] == 32) {
                        sp_bt = 7;
                        while (sp_bt < n_bt && eb_bt[sp_bt] == 32) {
                          sp_bt = sp_bt + 1;
                        }
                      }
                      let plen_bt: i32 = n_bt - sp_bt;
                      if (plen_bt > 0) {
                        let hdr_bt: u8[20] = [
                          115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0
                        ];
                        if (codegen_emit_bytes_from_ptr(out, &hdr_bt[0], 19) != 0) {
                          return -1;
                        }
                        let pi_bt: i32 = 0;
                        while (pi_bt < plen_bt) {
                          if (append_byte_u8(out, eb_bt[sp_bt + pi_bt]) != 0) {
                            return -1;
                          }
                          pi_bt = pi_bt + 1;
                        }
                        return 0;
                      }
                    }
                  }
                }
              }
              mi_bt = mi_bt + 1;
            }
          }
        }
      }
      let ek: i32 = pipeline_type_kind_ord_at(arena, elem_ref);
      if (ek == (TypeKind.TYPE_NAMED as i32)) {
        let enm: u8[256] = [];
        let enl: i32 = pipeline_type_named_name_into(arena, elem_ref, &enm[0]);
        /* wave619: short int aliases → stdint slice tags via type_to_c_repr. */
        let is_short_int: i32 = 0;
        if (enl == 2 && enm[0] == 105 && enm[1] == 56) {
          is_short_int = 1;
        }
        if (enl == 3 && enm[0] == 105 && enm[1] == 49 && enm[2] == 54) {
          is_short_int = 1;
        }
        if (enl == 3 && enm[0] == 117 && enm[1] == 49 && enm[2] == 54) {
          is_short_int = 1;
        }
        if (is_short_int == 0 && enl > 0) {
          let hdr_sl: u8[20] = [
            115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0
          ];
          if (codegen_emit_bytes_from_ptr(out, &hdr_sl[0], 19) != 0) {
            return -1;
          }
          /* Mirror TYPE_NAMED prefix resolution for the element tag. */
          let dep_prefix_buf2: u8[256] = [];
          let dep_prefix_len2: i32 = codegen_type_dep_struct_prefix_into(ctx, arena, elem_ref, &dep_prefix_buf2[0], 128);
          if (dep_prefix_len2 == 0) {
            let qmod_end2: i32 = 0;
            let qhas_dot2: bool = false;
            let qi2: i32 = 0;
            while (qi2 < enl && qi2 < 64) {
              if (enm[qi2] == 46) {
                qhas_dot2 = true;
                qmod_end2 = qi2;
              }
              qi2 = qi2 + 1;
            }
            if (qhas_dot2 && qmod_end2 > 0 && qmod_end2 < 64) {
              let mod_path2: u8[256] = [];
              let mi2: i32 = 0;
              while (mi2 < qmod_end2) {
                mod_path2[mi2] = enm[mi2];
                mi2 = mi2 + 1;
              }
              mod_path2[mi2] = 0 as u8;
              codegen_import_path_to_c_prefix_into(&mod_path2[0], &dep_prefix_buf2[0], 128);
              dep_prefix_len2 = 0;
              while (dep_prefix_len2 < 128 && dep_prefix_buf2[dep_prefix_len2] != 0 as u8) {
                dep_prefix_len2 = dep_prefix_len2 + 1;
              }
            }
          }
          if (dep_prefix_len2 > 0) {
            if (codegen_emit_bytes_from_ptr(out, &dep_prefix_buf2[0], dep_prefix_len2) != 0) {
              return -1;
            }
          } else if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
            if (codegen_emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) != 0) {
              return -1;
            }
          } else if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module
              && codegen_type_is_module_user_struct(ctx.current_codegen_module, arena, elem_ref) != 0) {
            let cur_pre2: u8[256] = [];
            let cur_pre_len2: i32 = codegen_emit_prefix_len_from_ctx(ctx, &cur_pre2[0], 128);
            if (cur_pre_len2 > 0 && codegen_emit_bytes_from_ptr(out, &cur_pre2[0], cur_pre_len2) != 0) {
              return -1;
            }
          } else if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_dep_index < 0) {
            /* entry module bare — match struct definitions */
          } else {
            let ast_p2: u8[4] = [97, 115, 116, 95];
            if (codegen_emit_bytes_4(out, &ast_p2[0], 4) != 0) {
              return -1;
            }
          }
          let bare_off2: i32 = 0;
          let bi3: i32 = 0;
          while (bi3 < enl && bi3 < 64) {
            if (enm[bi3] == 46) {
              bare_off2 = bi3 + 1;
            }
            bi3 = bi3 + 1;
          }
          let ci3: i32 = bare_off2;
          while (ci3 < enl && ci3 < 128) {
            if (append_byte_u8(out, enm[ci3]) != 0) {
              return -1;
            }
            ci3 = ci3 + 1;
          }
          return 0;
        }
      }
      /*
       * wave693 Cap residual pure: nested TYPE_SLICE ([][]T / [][]Named) falls
       * through to type_to_c_repr. Entry-module locals often pass empty
       * struct_prefix while one-level NAMED slice tags use
       * codegen_emit_prefix_len_from_ctx (file-stem). Without the same prefix
       * here, `let m: [][]Cell` becomes incomplete `xlang_slice_xlang_slice_Cell`
       * while `[]Cell` / formals use `xlang_slice_*_<pfx>Cell`. G.7: same tag
       * authority as NAMED one-level path above. PLATFORM: SHARED host-C.
       */
      let pfx_use: *u8 = struct_prefix;
      let pfx_len_use: i32 = struct_prefix_len;
      let cur_pre_sl: u8[256] = [];
      if ((pfx_use == 0 as *u8 || pfx_len_use <= 0) && ctx != 0 as *PipelineDepCtx) {
        let pl_sl: i32 = codegen_emit_prefix_len_from_ctx(ctx, &cur_pre_sl[0], 128);
        if (pl_sl > 0) {
          pfx_use = &cur_pre_sl[0];
          pfx_len_use = pl_sl;
        }
      }
      let slb: u8[896] = [];
      let nl: i32 = type_to_c_repr(arena, &slb[0], 896, type_ref, pfx_use, pfx_len_use);
      if (nl <= 0) {
        return -1;
      }
      let si: i32 = 0;
      while (si < nl) {
        if (append_byte_u8(out, slb[si]) != 0) {
          return -1;
        }
        si = si + 1;
      }
      return 0;
    }
    /* See implementation. */
    if (tk == TypeKind.TYPE_VECTOR as i32 && !ast.ref_is_null(elem_ref)) {
      elem_kind = pipeline_type_kind_ord_at(arena, elem_ref);
      return emit_vector_c_type_out(out, elem_kind, arr_sz);
    }
    /* See implementation. */
    if (tk == TypeKind.TYPE_LINEAR as i32 && !ast.ref_is_null(elem_ref)) {
      return codegen_emit_type(arena, out, elem_ref, struct_prefix, struct_prefix_len, ctx);
    }
    /*
     * 10.3.1: TYPE_FN → abstract C fnptr `Ret (*)(T0,…)`.
     * Named locals/params use codegen_emit_c_fnptr_decl with name (like *[N]T).
     * PLATFORM: SHARED host-C. G.7 single declarator authority.
     */
    if (tk == TypeKind.TYPE_FN as i32) {
      return codegen_emit_c_fnptr_decl(arena, out, type_ref, 0 as *u8, 0, 0, ctx);
    }
    return emit_type_kind_ord(out, tk);
  }
}

/**
 * Pick defining-module dep index for a bare struct name across the dep pool.
 *
 * Why: co-emit can leave the same bare name in several modules (merge, struct-lit
 * pollution). Wrong owner → dual C tags (lexer_Token vs token_Token) and incomplete
 * by-value fields (LexerResult before Token).
 *
 * Ranking (PLATFORM: SHARED):
 *  1) Prefer layouts with num_fields > 0 over empty placeholders.
 *  2) Prefer is_export=1 (true `export struct`) over non-export copies.
 *  3) When both candidates are export: prefer current_codegen_dep_index so dual real
 *     types (std_context_Error vs std_error_Error) each emit under their own prefix.
 *  4) When both are non-export (pollution competition, e.g. Token in lexer+token with
 *     is_export still 0 on product parser pin): prefer the **latest** dep index — leaf
 *     imports are registered after parents (token after lexer), so the defining file wins.
 *
 * Returns -1 if no dep has the bare name; otherwise a pipeline_dep_ctx index.
 */
export function codegen_type_dep_struct_owner_index(ctx: *PipelineDepCtx, bare_nm: *u8, bare_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let best_di: i32 = -1;
    let best_export: i32 = 0;
    let best_nf: i32 = 0;
    let cur: i32 = -1;
    let di: i32 = 0;
    let nd: i32 = 0;
    if (ctx == 0 as *PipelineDepCtx || bare_nm == 0 as *u8 || bare_len <= 0) {
      return -1;
    }
    cur = ctx.current_codegen_dep_index;
    nd = pipeline_dep_ctx_ndep(ctx);
    while (di < nd) {
      let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, di);
      if (dep_mod != 0 as *Module) {
        let li: i32 = 0;
        let hit: i32 = 0;
        let hit_export: i32 = 0;
        let hit_nf: i32 = 0;
        while (li < dep_mod.num_struct_layouts) {
          let dep_name_len: i32 = pipeline_module_struct_layout_name_len(dep_mod, li);
          if (dep_name_len == bare_len) {
            let dep_nm: u8[256] = [];
            let eq: bool = true;
            let j: i32 = 0;
            pipeline_module_struct_layout_name_into(dep_mod, li, &dep_nm[0]);
            while (j < bare_len && j < 64) {
              if (dep_nm[j] != bare_nm[j]) {
                eq = false;
                break;
              }
              j = j + 1;
            }
            if (eq) {
              hit = 1;
              hit_nf = pipeline_module_struct_layout_num_fields(dep_mod, li);
              if (pipeline_module_struct_layout_is_export_at(dep_mod, li) != 0) {
                hit_export = 1;
              }
              break;
            }
          }
          li = li + 1;
        }
        if (hit != 0) {
          /* Empty same-name layouts must not steal ownership (incomplete type). */
          if (best_di < 0) {
            best_di = di;
            best_export = hit_export;
            best_nf = hit_nf;
          } else if (hit_nf > 0 && best_nf <= 0) {
            best_di = di;
            best_export = hit_export;
            best_nf = hit_nf;
          } else if (hit_nf > 0 && best_nf > 0 && hit_export != 0 && best_export == 0) {
            best_di = di;
            best_export = 1;
            best_nf = hit_nf;
          } else if (hit_export != 0 && best_export == 0 && hit_nf >= best_nf) {
            best_di = di;
            best_export = 1;
            best_nf = hit_nf;
          } else if (hit_nf > 0 && best_nf > 0 && hit_export != 0 && best_export != 0 && di == cur) {
            /* Dual true exports (Error): current module owns its own tag. */
            best_di = di;
            best_nf = hit_nf;
          } else if (hit_nf > 0 && best_nf > 0 && hit_export == 0 && best_export == 0 && di > best_di) {
            /*
             * Non-export competition: prefer later dep (leaf import after parent).
             * Token: lexer di=0 pollution vs token di=1 definition → token wins.
             * Do not apply cur preference here — that re-emitted lexer_Token and
             * broke LexerResult by-value field completeness (parser M1 host-cc).
             */
            best_di = di;
            best_nf = hit_nf;
          }
        }
      }
      di = di + 1;
    }
    return best_di;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function codegen_type_dep_struct_prefix_into(ctx: *PipelineDepCtx, arena: *ASTArena, type_ref: i32, dst: *u8, dst_cap: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let name_len: i32 = 0;
    let ty_nm: u8[256] = [];
    let owner: i32 = -1;
    if (ctx == 0 as *PipelineDepCtx || arena == 0 as *ASTArena || dst == 0 as *u8 || dst_cap <= 0 || ast.ref_is_null(type_ref)) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, type_ref) != (TypeKind.TYPE_NAMED as i32)) {
      return 0;
    }
    name_len = pipeline_type_named_name_into(arena, type_ref, &ty_nm[0]);
    if (name_len <= 0) {
      return 0;
    }
    /* See implementation. */
    let bare_off: i32 = 0;
    let bi: i32 = 0;
    while (bi < name_len && bi < 64) {
      if (ty_nm[bi] == 46) {
        bare_off = bi + 1;
      }
      bi = bi + 1;
    }
    let bare_len: i32 = name_len - bare_off;
    owner = codegen_type_dep_struct_owner_index(ctx, &ty_nm[bare_off], bare_len);
    if (owner >= 0) {
      let dep_path: u8[256] = [];
      let plen: i32 = codegen_dep_import_path_len_at(ctx, owner, &dep_path[0]);
      if (plen > 0) {
        codegen_import_path_to_c_prefix_into(&dep_path[0], dst, dst_cap);
        let out_len: i32 = 0;
        while (out_len < dst_cap && dst[out_len] != 0 as u8) {
          out_len = out_len + 1;
        }
        return out_len;
      }
    }
    return 0;
  }
}

/**
 * See implementation.
 */
export function type_array_elem_is_u8(arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let inner: i32 = 0;
    if (ast.ref_is_null(type_ref) || type_ref <= 0 || type_ref > arena.num_types) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, type_ref) != (TypeKind.TYPE_ARRAY as i32)) {
      return 0;
    }
    inner = pipeline_type_elem_ref_at(arena, type_ref);
    if (ast.ref_is_null(inner) || inner <= 0 || inner > arena.num_types) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, inner) == (TypeKind.TYPE_U8 as i32) as i32) {
      return 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 */
/**
 * Host-C: emit a C pointer-to-fixed-array declarator.
 * wave636: TYPE_PTR → TYPE_ARRAY (`*[N]T`) must be `E (*name)[N]`, not `E * *`.
 * dest-SLICE return/assign of INDEX: TYPE_ARRAY → TYPE_ARRAY (`[K][N]T` param)
 * decays to a pointer to the row, the same C form `E (*name)[N]…`.
 * `[K]*[N]T` (ARRAY of PTR-to-ARRAY) param-decays to a pointer to `*[N]T`,
 * so the C form is `E (**name)[N]…` (abstract `E (**)[N]…`). Sit-red
 * dyn_add_arr_ptr_arr host-C INDEX `(*((p)[0]))[0]` when p was `E **`
 * (`*(p[0])` is a scalar, not an array).
 * Abstract codegen_emit_type peels ARRAY to `E *` twice → `int32_t ** a` and
 * `(a)[0]` reads the first row's scalars as a pointer (memcpy SEGV).
 * C form: `E (*name)[N][M]…` (name_len==0 → abstract `E (*)[N]…`).
 * Reuses codegen_emit_local_fixed_array_elem_type + suffix (G.7; no third peel).
 * @param arena *ASTArena — type pool
 * @param out *CodegenOutBuf — C text sink
 * @param ptr_type_ref i32 — TYPE_PTR→TYPE_ARRAY, TYPE_ARRAY→TYPE_ARRAY, or TYPE_ARRAY→TYPE_PTR→TYPE_ARRAY
 * @param name *u8 — optional declarator name (may be null when name_len==0)
 * @param name_len i32 — 0 for abstract type (casts / sizeof)
 * @param ctx *PipelineDepCtx — nested named/struct emit
 * @return i32 — 0 success, -1 failure
 * PLATFORM: SHARED host-C emit
 */
export function codegen_emit_c_ptr_to_fixed_array_decl(arena: *ASTArena, out: *CodegenOutBuf, ptr_type_ref: i32, name: *u8, name_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let arr_tr: i32 = 0;
    let decl_tk: i32 = 0;
    if (ast.ref_is_null(ptr_type_ref)) {
      return -1;
    }
    decl_tk = pipeline_type_kind_ord_at(arena, ptr_type_ref);
    if (decl_tk != (TypeKind.TYPE_PTR as i32) && decl_tk != (TypeKind.TYPE_ARRAY as i32)) {
      return -1;
    }
    arr_tr = pipeline_type_elem_ref_at(arena, ptr_type_ref);
    /*
     * `[K]*[N]T` param decay: pointer to `*[N]T` → `E (**name)[N]`.
     * Do not fall through to ARRAY-of-ARRAY (`arr_tr` is PTR, not ARRAY).
     * Kind checks are inlined (this function is defined before
     * type_is_ptr_to_fixed_array). PLATFORM: SHARED host-C.
     */
    if (decl_tk == (TypeKind.TYPE_ARRAY as i32) && !ast.ref_is_null(arr_tr)
        && pipeline_type_kind_ord_at(arena, arr_tr) == (TypeKind.TYPE_PTR as i32)) {
      let inner_arr: i32 = pipeline_type_elem_ref_at(arena, arr_tr);
      if (ast.ref_is_null(inner_arr)
          || pipeline_type_kind_ord_at(arena, inner_arr) != (TypeKind.TYPE_ARRAY as i32)) {
        return -1;
      }
      if (codegen_emit_local_fixed_array_elem_type(arena, out, inner_arr, ctx) != 0) {
        return -1;
      }
      /* " (**" */
      if (codegen_append_byte(out, 32) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 42) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 42) != 0) {
        return -1;
      }
      if (name_len > 0 && name != 0 as *u8) {
        if (codegen_emit_bytes_from_ptr(out, name, name_len) != 0) {
          return -1;
        }
      }
      if (codegen_append_byte(out, 41) != 0) {
        return -1;
      }
      return codegen_emit_local_fixed_array_suffix(arena, out, inner_arr);
    }
    if (ast.ref_is_null(arr_tr) || pipeline_type_kind_ord_at(arena, arr_tr) != (TypeKind.TYPE_ARRAY as i32)) {
      return -1;
    }
    /* Leaf element type (peel multi-dim). */
    if (codegen_emit_local_fixed_array_elem_type(arena, out, arr_tr, ctx) != 0) {
      return -1;
    }
    /* " (*" */
    if (codegen_append_byte(out, 32) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 42) != 0) {
      return -1;
    }
    if (name_len > 0 && name != 0 as *u8) {
      if (codegen_emit_bytes_from_ptr(out, name, name_len) != 0) {
        return -1;
      }
    }
    /* ")" */
    if (codegen_append_byte(out, 41) != 0) {
      return -1;
    }
    /* [N][M]… */
    return codegen_emit_local_fixed_array_suffix(arena, out, arr_tr);
  }
}

/**
 * Host-C: true when type_ref is TYPE_PTR whose pointee is fixed TYPE_ARRAY (`*[N]T`).
 * @param arena *ASTArena — type pool
 * @param type_ref i32 — candidate type
 * @return i32 — 1 if pointer-to-fixed-array, else 0
 * PLATFORM: SHARED host-C emit
 */
export function type_is_ptr_to_fixed_array(arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0.
  unsafe {
    let elem: i32 = 0;
    if (ast.ref_is_null(type_ref) || pipeline_type_kind_ord_at(arena, type_ref) != (TypeKind.TYPE_PTR as i32)) {
      return 0;
    }
    elem = pipeline_type_elem_ref_at(arena, type_ref);
    if (ast.ref_is_null(elem) || pipeline_type_kind_ord_at(arena, elem) != (TypeKind.TYPE_ARRAY as i32)) {
      return 0;
    }
    return 1;
  }
}

/**
 * Host-C: true when type_ref is TYPE_ARRAY whose element is also TYPE_ARRAY (`[K][N]T`).
 * Param decay must be `E (*name)[N]…`, not recursive codegen_emit_type `E * *`.
 * @param arena *ASTArena — type pool
 * @param type_ref i32 — candidate type
 * @return i32 — 1 if array-of-fixed-array, else 0
 * PLATFORM: SHARED host-C emit
 */
export function type_is_array_of_fixed_array(arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0.
  unsafe {
    let elem: i32 = 0;
    if (ast.ref_is_null(type_ref) || pipeline_type_kind_ord_at(arena, type_ref) != (TypeKind.TYPE_ARRAY as i32)) {
      return 0;
    }
    elem = pipeline_type_elem_ref_at(arena, type_ref);
    if (ast.ref_is_null(elem) || pipeline_type_kind_ord_at(arena, elem) != (TypeKind.TYPE_ARRAY as i32)) {
      return 0;
    }
    return 1;
  }
}

/**
 * Host-C: true when a param/abstract type needs a named C array declarator
 * (`E (*name)[N]…` / `E (**name)[N]…`) instead of codegen_emit_type + trailing name.
 * Covers `*[N]T`, `[K][N]T`, and `[K]*[N]T` (G.7 single emit_c_ptr path).
 * `[K]*T` (ARRAY of PTR-to-leaf) stays codegen_emit_type `E **` — not this leaf.
 * @param arena *ASTArena — type pool
 * @param type_ref i32 — candidate type
 * @return i32 — 1 if named declarator required, else 0
 * PLATFORM: SHARED host-C emit
 */
// no_mangle: codegen_late calls type_uses_named_array_decl. A codegen_ prefix misses that call.
#[no_mangle]
export function type_uses_named_array_decl(arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0.
  unsafe {
    let elem: i32 = 0;
    if (type_is_ptr_to_fixed_array(arena, type_ref) != 0) {
      return 1;
    }
    if (type_is_array_of_fixed_array(arena, type_ref) != 0) {
      return 1;
    }
    /* `[K]*[N]T`: ARRAY whose element is PTR-to-fixed-ARRAY. */
    if (ast.ref_is_null(type_ref) || pipeline_type_kind_ord_at(arena, type_ref) != (TypeKind.TYPE_ARRAY as i32)) {
      return 0;
    }
    elem = pipeline_type_elem_ref_at(arena, type_ref);
    return type_is_ptr_to_fixed_array(arena, elem);
  }
}

/**
 * True when type_ref is Cap fn-ptr surface `*u8` (TYPE_PTR → TYPE_U8).
 * Host-C Cap→fn assign cast / Cap CALL cast gate (10.3.1 slice15).
 * @param arena *ASTArena — type pool
 * @param type_ref i32 — resolved type
 * @return i32 — 1 Cap *u8, 0 otherwise
 * PLATFORM: SHARED host-C.
 */
export function codegen_type_is_cap_u8_ptr(arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let er: i32 = 0;
    if (arena == 0 as *ASTArena || type_ref <= 0) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, type_ref) != (TypeKind.TYPE_PTR as i32)) {
      return 0;
    }
    er = pipeline_type_elem_ref_at(arena, type_ref);
    if (er <= 0) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, er) == (TypeKind.TYPE_U8 as i32)) {
      return 1;
    }
    return 0;
  }
}

/**
 * Host-C abstract fnptr type from CALL site: `Ret (*)(T0, …)`.
 * Used when Cap *u8 is called (no TYPE_FN node on callee). Ret/arg types from
 * stamped CALL / arg resolved types; missing → int32_t; 0-arg → void.
 * @param arena *ASTArena — type/expr pool
 * @param out *CodegenOutBuf — C text sink
 * @param call_ref i32 — EXPR_CALL
 * @param ctx *PipelineDepCtx — nested codegen_emit_type
 * @return i32 — 0 success, -1 failure
 * PLATFORM: SHARED host-C. Complements codegen_emit_c_fnptr_decl (TYPE_FN authority).
 */
export function codegen_emit_c_fnptr_abstract_from_call(arena: *ASTArena, out: *CodegenOutBuf,
call_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ret_ty: i32 = 0;
    let n: i32 = 0;
    let i: i32 = 0;
    let arg_ref: i32 = 0;
    let arg_ty: i32 = 0;
    let i32t: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
    let void5: u8[5] = [118, 111, 105, 100, 0];
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || call_ref <= 0) {
      return -1;
    }
    ret_ty = pipeline_expr_resolved_type_ref(arena, call_ref);
    if (ret_ty <= 0) {
      if (codegen_emit_bytes_8(out, &i32t[0], 7) != 0) {
        return -1;
      }
    } else if (codegen_emit_type(arena, out, ret_ty, 0 as *u8, 0, ctx) != 0) {
      return -1;
    }
    /* " (*(" */
    if (codegen_append_byte(out, 32) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 42) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 41) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    n = pipeline_expr_call_num_args_at(arena, call_ref);
    if (n <= 0) {
      if (codegen_emit_bytes_from_ptr(out, &void5[0], 4) != 0) {
        return -1;
      }
    } else {
      i = 0;
      while (i < n) {
        if (i > 0) {
          let comma: u8[3] = [44, 32, 0];
          if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
            return -1;
          }
        }
        arg_ref = pipeline_expr_call_arg_ref(arena, call_ref, i);
        arg_ty = 0;
        if (!ast.ref_is_null(arg_ref) && arg_ref > 0) {
          arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
        }
        if (arg_ty <= 0) {
          if (codegen_emit_bytes_8(out, &i32t[0], 7) != 0) {
            return -1;
          }
        } else if (codegen_emit_type(arena, out, arg_ty, 0 as *u8, 0, ctx) != 0) {
          return -1;
        }
        i = i + 1;
      }
    }
    if (codegen_append_byte(out, 41) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * Host-C Cap `*u8` CALL → `((Ret (*)(T…))(callee))(args)`.
 * Without cast, gcc: called object type 'uint8_t *' is not a function.
 * TYPE_FN / named declarator callees return 0 (unhandled).
 * @param arena *ASTArena — expr pool
 * @param out *CodegenOutBuf — C text sink
 * @param expr_ref i32 — EXPR_CALL
 * @param ctx *PipelineDepCtx — nested emit
 * @return i32 — 1 emitted, 0 not Cap surface, -1 failure
 * PLATFORM: SHARED host-C. 10.3.1 slice15.
 */
export function codegen_try_emit_cap_u8_call(arena: *ASTArena, out: *CodegenOutBuf,
expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    let callee_ref: i32 = 0;
    let cal_ty: i32 = 0;
    let n: i32 = 0;
    let ai: i32 = 0;
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf) {
      return -1;
    }
    if ((e.kind as i32) != (ExprKind.EXPR_CALL as i32)) {
      return 0;
    }
    callee_ref = e.call_callee_ref;
    if (ast.ref_is_null(callee_ref) || callee_ref <= 0 || callee_ref > arena.num_exprs) {
      return 0;
    }
    cal_ty = pipeline_expr_resolved_type_ref(arena, callee_ref);
    if (codegen_type_is_cap_u8_ptr(arena, cal_ty) == 0) {
      return 0;
    }
    /* ((abstract)(callee))(args) */
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    if (codegen_emit_c_fnptr_abstract_from_call(arena, out, expr_ref, ctx) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 41) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    if (codegen_emit_expr(arena, out, callee_ref, ctx) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 41) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 41) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    n = e.call_num_args;
    ai = 0;
    while (ai < n) {
      if (ai > 0) {
        let comma: u8[3] = [44, 32, 0];
        if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
          return -1;
        }
      }
      if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {
        if (codegen_append_byte(out, 48) != 0) {
          return -1;
        }
      } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) != 0) {
        return -1;
      }
      ai = ai + 1;
    }
    if (codegen_append_byte(out, 41) != 0) {
      return -1;
    }
    return 1;
  }
}

/**
 * Host-C: emit a C function-pointer declarator for TYPE_FN (10.3.1).
 *
 * Storage (parser): elem=return, array_size=n_params, type_args=params.
 * Form: `Ret (*name)(T0, T1, …)` or abstract `Ret (*)(T0, …)` when name_len==0.
 * Zero params → `(void)` (ISO C empty-prototype ban). Nested TYPE_FN params
 * recurse via codegen_emit_type → abstract form.
 *
 * 10.3.1 slice11: when `array_ty` is TYPE_ARRAY… peeling to `fn_ty`, emit
 * dims after the name inside the pointer parens:
 *   `Ret (*name[N][M])(args)` — not invalid `Ret (*)(args) name[N]`.
 * Pass array_ty==0 for bare TYPE_FN / abstract / params.
 *
 * @param arena *ASTArena — type pool
 * @param out *CodegenOutBuf — C text sink
 * @param fn_ty i32 — TYPE_FN type_ref (leaf)
 * @param name *u8 — optional declarator name (null when name_len==0)
 * @param name_len i32 — 0 for abstract type (casts / codegen_emit_type)
 * @param array_ty i32 — 0 or outermost TYPE_ARRAY of fn_ty; dims after name
 * @param ctx *PipelineDepCtx — nested emit
 * @return i32 — 0 success, -1 failure
 * PLATFORM: SHARED host-C. G.7 single TYPE_FN declarator authority.
 */
export function codegen_emit_c_fnptr_decl(arena: *ASTArena, out: *CodegenOutBuf, fn_ty: i32, name: *u8,
name_len: i32, array_ty: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ret_ty: i32 = 0;
    let n: i32 = 0;
    let i: i32 = 0;
    let pty: i32 = 0;
    let dims_ref: i32 = 0;
    let depth: i32 = 0;
    let asz: i32 = 0;
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || fn_ty <= 0) {
      return -1;
    }
    if (pipeline_type_kind_ord_at(arena, fn_ty) != (TypeKind.TYPE_FN as i32)) {
      return -1;
    }
    ret_ty = pipeline_type_elem_ref_at(arena, fn_ty);
    if (ret_ty <= 0) {
      /* Missing ret → void. */
      let v: u8[5] = [118, 111, 105, 100, 0];
      if (codegen_emit_bytes_from_ptr(out, &v[0], 4) != 0) {
        return -1;
      }
    } else if (codegen_emit_type(arena, out, ret_ty, 0 as *u8, 0, ctx) != 0) {
      return -1;
    }
    /* " (*" */
    if (codegen_append_byte(out, 32) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 42) != 0) {
      return -1;
    }
    if (name_len > 0 && name != 0 as *u8) {
      if (codegen_emit_bytes_from_ptr(out, name, name_len) != 0) {
        return -1;
      }
    }
    /*
     * Array-of-fnptr: dims bind to the pointer name, not after the prototype.
     * PLATFORM: SHARED host-C (ISO C `Ret (*a[N])(T)`).
     */
    if (array_ty > 0 && pipeline_type_kind_ord_at(arena, array_ty) == (TypeKind.TYPE_ARRAY as i32)) {
      dims_ref = array_ty;
      depth = 0;
      while (!ast.ref_is_null(dims_ref)
          && pipeline_type_kind_ord_at(arena, dims_ref) == (TypeKind.TYPE_ARRAY as i32)
          && depth < 8) {
        asz = pipeline_type_array_size_at(arena, dims_ref);
        if (codegen_append_byte(out, 91) != 0) {
          return -1;
        }
        if (format_int(out, asz) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 93) != 0) {
          return -1;
        }
        dims_ref = pipeline_type_elem_ref_at(arena, dims_ref);
        depth = depth + 1;
      }
    }
    /* ")(" */
    if (codegen_append_byte(out, 41) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    n = pipeline_type_array_size_at(arena, fn_ty);
    if (n < 0) {
      n = 0;
    }
    if (n == 0) {
      let vd: u8[5] = [118, 111, 105, 100, 0];
      if (codegen_emit_bytes_from_ptr(out, &vd[0], 4) != 0) {
        return -1;
      }
    } else {
      i = 0;
      while (i < n) {
        if (i > 0) {
          if (codegen_append_byte(out, 44) != 0) {
            return -1;
          }
          if (codegen_append_byte(out, 32) != 0) {
            return -1;
          }
        }
        pty = pipeline_type_type_arg_ref_at(arena, fn_ty, i);
        if (pty <= 0) {
          return -1;
        }
        if (codegen_emit_type(arena, out, pty, 0 as *u8, 0, ctx) != 0) {
          return -1;
        }
        i = i + 1;
      }
    }
    if (codegen_append_byte(out, 41) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * Host-C: emit the scalar/base type of a fixed TYPE_ARRAY local (peels multi-dim).
 * wave357 Cap residual pure: `[2][3]i32` must emit `int32_t` not `int32_t *` then `[2]`.
 * Prior: one-level peel + codegen_emit_type(TYPE_ARRAY)→`E *` produced `int32_t * a[2]` (pointer rows).
 * G.7: same peel loop as codegen_emit_struct_field_decl_x dims path.
 * @param arena *ASTArena — type pool
 * @param out *CodegenOutBuf — C text sink
 * @param type_ref i32 — outermost TYPE_ARRAY
 * @param ctx *PipelineDepCtx — nested named/struct emit
 * @return i32 — 0 success
 * PLATFORM: SHARED host-C emit
 */
export function codegen_emit_local_fixed_array_elem_type(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let base_ref: i32 = type_ref;
    /* Peel all TYPE_ARRAY layers to the scalar/struct leaf (multi-dim C: E a[N][M]). */
    while (!ast.ref_is_null(base_ref) && pipeline_type_kind_ord_at(arena, base_ref) == (TypeKind.TYPE_ARRAY as i32)) {
      let inner: i32 = pipeline_type_elem_ref_at(arena, base_ref);
      if (ast.ref_is_null(inner)) {
        break;
      }
      base_ref = inner;
    }
    if (ast.ref_is_null(base_ref) || codegen_emit_type(arena, out, base_ref, 0 as *u8, 0, ctx) != 0) {
      let fb: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
      return codegen_emit_bytes_8(out, &fb[0], 7);
    }
    return 0;
  }
}

/**
 * Host-C: emit all `[N][M]…` suffixes for a fixed multi-dim TYPE_ARRAY local.
 * wave357: C-style `T a[N][M]` matches product type peel order (outer N first).
 * @param arena *ASTArena — type pool
 * @param out *CodegenOutBuf — C text sink
 * @param type_ref i32 — outermost TYPE_ARRAY
 * @return i32 — 0 success
 * PLATFORM: SHARED host-C emit
 */
export function codegen_emit_local_fixed_array_suffix(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let dims_ref: i32 = type_ref;
    let depth: i32 = 0;
    while (!ast.ref_is_null(dims_ref) && pipeline_type_kind_ord_at(arena, dims_ref) == (TypeKind.TYPE_ARRAY as i32)
        && depth < 8) {
      let asz: i32 = pipeline_type_array_size_at(arena, dims_ref);
      if (codegen_append_byte(out, 91) != 0) {
        return -1;
      }
      if (format_int(out, asz) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 93) != 0) {
        return -1;
      }
      dims_ref = pipeline_type_elem_ref_at(arena, dims_ref);
      depth = depth + 1;
    }
    return 0;
  }
}

/**
 * Host-C: finish a fixed TYPE_ARRAY local after `E name[N]` has been emitted (no `=` yet).
 *
 * - null / zero lit → ` = { 0 };`
 * - EXPR_ARRAY_LIT → ` = { elems };`
 * - other rvalue (CALL / METHOD / VAR / FIELD / …) → `;\n` + indent +
 *   `memcpy((void*)(name), (const void*)(<expr>), sizeof(name));`
 *
 * Root (wave353 Cap residual): C forbids `T t[N] = ptr` and `T t[N] = other_array`.
 * Host lowers TYPE_ARRAY returns as `E*` (wave352 durable static); memcpy once-evals CALL.
 * G.7: single authority for local fixed-array let init; reuses wave334 memcpy form.
 *
 * @param arena *ASTArena — expression pool
 * @param out *CodegenOutBuf — C text sink
 * @param indent i32 — indentation for the optional memcpy statement
 * @param name *u8 — C local identifier bytes (may be placeholder `_lN`)
 * @param name_len i32 — byte length of name; must match what was just emitted
 * @param linit_ref i32 — init expression ref; null/invalid → zero brace init
 * @param dest_type_ref i32 — let dest TYPE_ARRAY (may be 0); stamps ARRAY_LIT
 *   resolved_type_ref when dep typeck left it empty so braced STRUCT_LIT elems
 *   can recover Iovec (fs_formal posix readv4 incomplete `struct std_fs_posix_`).
 * @param ctx *PipelineDepCtx — emit context for nested expr
 * @return i32 — 0 on success, -1 on hard emit failure
 * PLATFORM: SHARED host-C emit (string.h memcpy already in product preamble).
 */
export function emit_local_fixed_array_let_finish(arena: *ASTArena, out: *CodegenOutBuf, indent: i32, name: *u8, name_len: i32, linit_ref: i32, dest_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let use_brace: i32 = 0;
    let use_zero: i32 = 0;
    if (ast.ref_is_null(linit_ref) || linit_ref <= 0 || linit_ref > arena.num_exprs) {
      use_zero = 1;
    } else {
      let ie: Expr = ast.ast_arena_expr_get(arena, linit_ref);
      if ((ie.kind as i32) == (ExprKind.EXPR_ARRAY_LIT as i32)) {
        use_brace = 1;
      } else if ((ie.kind as i32) == (ExprKind.EXPR_LIT as i32) && ie.int_val == 0) {
        use_zero = 1;
      }
    }
    if (use_brace != 0) {
      /* Dep co-emit can leave ARRAY_LIT resolved_type_ref empty; let dest is
       * the authority (already used for `E name[N]`). Stamp so braced
       * STRUCT_LIT elems recover TYPE_NAMED (Iovec) instead of empty prefix.
       * PLATFORM: SHARED host-C. */
      if (!ast.ref_is_null(dest_type_ref) && dest_type_ref > 0 && dest_type_ref <= arena.num_types) {
        let dk: i32 = pipeline_type_kind_ord_at(arena, dest_type_ref);
        if (dk == (TypeKind.TYPE_ARRAY as i32) || dk == (TypeKind.TYPE_SLICE as i32)) {
          let ie_d: Expr = ast.ast_arena_expr_get(arena, linit_ref);
          if (ast.ref_is_null(ie_d.resolved_type_ref) || ie_d.resolved_type_ref <= 0) {
            pipeline_expr_set_resolved_type_ref(arena, linit_ref, dest_type_ref);
          }
        }
      }
      let eqb: u8[4] = [32, 61, 32, 0];
      if (codegen_emit_bytes_4(out, &eqb[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_braced_array_lit_init(arena, out, linit_ref, ctx) != 0) {
        return -1;
      }
      let scb: u8[3] = [59, 10, 0];
      return codegen_emit_bytes_3(out, &scb[0], 2);
    }
    if (use_zero != 0) {
      let z: u8[10] = [32, 61, 32, 123, 32, 48, 32, 125, 59, 10];
      return codegen_emit_bytes_from_ptr(out, &z[0], 10);
    }
    /* Non-brace rvalue: declare then memcpy (once-eval of CALL/METHOD). */
    if (codegen_append_byte(out, 59) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 10) != 0) {
      return -1;
    }
    if (codegen_emit_indent(out, indent) != 0) {
      return -1;
    }
    /* memcpy((void*)( */
    let pref: u8[16] = [109, 101, 109, 99, 112, 121, 40, 40, 118, 111, 105, 100, 42, 41, 40, 0];
    if (codegen_emit_bytes_from_ptr(out, &pref[0], 15) != 0) {
      return -1;
    }
    if (name_len > 0 && codegen_emit_bytes_64(out, &name[0], name_len) != 0) {
      return -1;
    }
    /* ), (const void*)( */
    let mid: u8[20] = [41, 44, 32, 40, 99, 111, 110, 115, 116, 32, 118, 111, 105, 100, 42, 41, 40, 0, 0, 0];
    if (codegen_emit_bytes_from_ptr(out, &mid[0], 17) != 0) {
      return -1;
    }
    if (codegen_emit_expr(arena, out, linit_ref, ctx) != 0) {
      return -1;
    }
    /* ), sizeof( */
    let mid_sz: u8[12] = [41, 44, 32, 115, 105, 122, 101, 111, 102, 40, 0, 0];
    if (codegen_emit_bytes_from_ptr(out, &mid_sz[0], 10) != 0) {
      return -1;
    }
    if (name_len > 0 && codegen_emit_bytes_64(out, &name[0], name_len) != 0) {
      return -1;
    }
    /* ));\n */
    let tail: u8[4] = [41, 41, 59, 10];
    return codegen_emit_bytes_from_ptr(out, &tail[0], 4);
  }
}

/**
 * True when a dest-SLICE let init CALL/METHOD's callee already returns TYPE_SLICE.
 * dest-SLICE of a callee that returns TYPE_ARRAY (`mk(): [N]T`) must wrap via
 * try_emit_slice_init_from_array_var — typeck stamps the CALL expr to TYPE_SLICE
 * but ARRAY return ABI is E*, so wave409 reent `__xlang_sp = mk()` is BLD001.
 * Same-module: current_codegen_module + caller arena. Dep-module: dep arena
 * (type_ref is arena-local). Unknown / missing ctx → 0 (try_emit or codegen_emit_expr).
 * @param arena *ASTArena — caller expr/type pool
 * @param linit_ref i32 — CALL (48) or METHOD_CALL (49)
 * @param ctx *PipelineDepCtx — current module + dep table; null → 0
 * @return i32 — 1 callee return TYPE_SLICE; 0 otherwise
 * PLATFORM: SHARED host-C (let-init reent gate).
 * Seed twin: codegen_gen.linux.x86_64.c (live `-E` is host-cc of that seed).
 * Do not fork a second let-init reent gate.
 */
export function codegen_slice_let_call_returns_slice(arena: *ASTArena, linit_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || ast.ref_is_null(linit_ref) || ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    let func_ix: i32 = pipeline_expr_call_resolved_func_index_at(arena, linit_ref);
    let dep_ix: i32 = pipeline_expr_call_resolved_dep_index_at(arena, linit_ref);
    if (dep_ix < 0 && ctx.current_codegen_module != 0 as *Module && func_ix >= 0
        && func_ix < ctx.current_codegen_module.num_funcs) {
      let rty: i32 = pipeline_module_func_return_type_at(ctx.current_codegen_module, func_ix);
      if (!ast.ref_is_null(rty) && rty > 0) {
        if (pipeline_type_kind_ord_at(arena, rty) == 11) {
          return 1;
        }
      }
      return 0;
    }
    if (dep_ix >= 0 && func_ix >= 0) {
      let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, dep_ix);
      let dep_ar: *ASTArena = pipeline_dep_ctx_arena_at(ctx, dep_ix);
      if (dep_mod != 0 as *Module && func_ix < dep_mod.num_funcs) {
        let rty_d: i32 = pipeline_module_func_return_type_at(dep_mod, func_ix);
        if (!ast.ref_is_null(rty_d) && rty_d > 0 && dep_ar != 0 as *ASTArena) {
          if (pipeline_type_kind_ord_at(dep_ar, rty_d) == 11) {
            return 1;
          }
        }
      }
    }
    return 0;
  }
}

/**
 * Host-C: wrap a fixed TYPE_ARRAY rvalue as a TYPE_SLICE compound.
 * Emits `(T[]){ .data = <arr>, .length = N }` — typed compound is legal both
 * as a declaration initializer (`let s: T[] = arr`) and as an assignment
 * (`__xlang_al[i] = …` inside ARRAY_LIT non-const fill). C array decays.
 *
 * Paths (G.7 single authority — complete, do not fork):
 * - EXPR_VAR: prior `let a: T[N]` local (original Cap residual).
 * - wave348: EXPR_FIELD_ACCESS with VAR base + fixed TYPE_ARRAY field
 *   (`let s: T[] = b.a`). Prior: bare `(b.a)` is not a slice compound → host-cc red;
 *   freestanding dual-GP unwritten → panic/SIGSEGV.
 *   Import-module const FIELD (`dep.A`) is not a struct member: this helper
 *   returns 0; try_emit_dest_slice_from_module_array_var dispatches to
 *   try_emit_dest_slice_from_import_const_field (`{.data=A,.length=N}`).
 * - Non-VAR FIELD base (`let s:[]T = W{}.xs` / `mk().xs` / `rows[i].xs`):
 *   dest-SLICE stamps FIELD to TYPE_SLICE, hiding N. Recover N from the
 *   base TYPE_NAMED layout. `.data` is `((base).field)` (C array decays).
 *   CALL/METHOD bases memcpy into a unique static[N] (return temps die).
 *   STRUCT_LIT compound literals have block duration — view is legal.
 * - ARRAY_LIT dest-elem TYPE_SLICE + VAR/FIELD row (`[][]T = [a]`). Typeck
 *   stamps the row's resolved_type_ref to TYPE_SLICE, so N comes from the
 *   let/const decl (not the stamped expr). Same-block consts and parent
 *   lets/consts are scanned when the prior-let walk misses.
 * - EXPR_CALL / EXPR_METHOD_CALL returning TYPE_ARRAY (`[][]T = [mk()]`,
 *   `let s:[]T = dep.mk()`). Typeck stamps the expr to TYPE_SLICE; N is the
 *   callee return `[N]T` size (same-module or dep-arena). `.data = mk()` is
 *   legal: ARRAY return ABI is E*. Let-init reent is only for callee TYPE_SLICE.
 * - EXPR_INDEX of `[K][N]T` / `[][N]T` (`let s:[]T = a[i]`, `[][]T = [a[1]]`).
 *   N from base elem TYPE_ARRAY. C `a[i]` decays to E*.
 * - Block `const` dest-SLICE (`const s:[]T = a[1]` / `= b`): codegen_emit_block kind=0
 *   reuses this helper. Prior: `s = (a)[1]` assigned a pointer into the slice
 *   struct (host-cc BLD001). Typed compound is a legal C initializer.
 * - Module-level dest-SLICE const (`const s:[]T = A[1]` / `= B` at file scope):
 *   codegen_x_ast top-level decl reuses this helper. C static init allows
 *   `{.data = A[1], .length = N}` when `.data` is an address constant
 *   (static array / row). Module VAR N is NOT recovered here (local-slot
 *   cap — a module walk / 8th Module* / extra helper call here regressed
 *   cis host). Callers use try_emit_dest_slice_from_module_array_var
 *   after this returns 0. CALL/statement-expr is not a C static constant
 *   — typeck rejects those as module const; this helper still wraps them
 *   for init_globals assign.
 * - Module dest-SLICE ARRAY_LIT (`const t:[]T = [10,32]` / `[][]T = [[…]]`)
 *   is NOT this helper. File-scope wrap lives in
 *   codegen_emit_file_scope_dest_slice_array_lit (codegen_x_ast decl-site).
 *   `(E[]){…}` / nested `(inner[]){…}` are address constants. Adding
 *   ARRAY_LIT here would also fire from init_globals (`block_ref=0`)
 *   and dangle a function-scope compound.
 *
 * @param arena *ASTArena — expression/type pool
 * @param out *CodegenOutBuf — C text sink
 * @param block_ref i32 — enclosing block (let/const scan for VAR path)
 * @param let_idx i32 — current let index; prior lets only for VAR match in this block
 * @param let_type_ref i32 — must be TYPE_SLICE (kind 11)
 * @param linit_ref i32 — init expr (VAR, FIELD_ACCESS, CALL, METHOD_CALL, or INDEX)
 * @param ctx *PipelineDepCtx — codegen_emit_type prefix; null OK for scalar []i32
 * @return i32 — 1 emitted; 0 not applicable; -1 hard fail
 * PLATFORM: SHARED host-C emit (mirror freestanding glue_emit_slice_from_array_let_init).
 * Seed twin: codegen_gen.linux.x86_64.c (live `-E` is host-cc of that seed).
 * Do not fork a second CALL/METHOD wrap, dest-SLICE non-VAR FIELD wrap,
 * or dest-SLICE VAR parent-block const scan.
 */
// no_mangle: codegen_late calls try_emit_slice_init_from_array_var. A codegen_ prefix misses that call.
#[no_mangle]
export function try_emit_slice_init_from_array_var(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, let_idx: i32, let_type_ref: i32, linit_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ast.ref_is_null(let_type_ref) || pipeline_type_kind_ord_at(arena, let_type_ref) != 11) {
      return 0;
    }
    if (ast.ref_is_null(linit_ref) || linit_ref <= 0 || linit_ref > arena.num_exprs) {
      return 0;
    }
    let init_e: Expr = ast.ast_arena_expr_get(arena, linit_ref);
    let arr_sz: i32 = 0;
    let is_field: i32 = 0;
    let is_call: i32 = 0;
    let field_base_ko: i32 = 0;
    let base_e: Expr = init_e;
    let init_ko: i32 = pipeline_expr_kind_ord_at(arena, linit_ref);

    if (init_ko == 3 && init_e.var_name_len > 0) {
      let li: i32 = 0;
      while (li < let_idx) {
        let nlen: i32 = pipeline_block_let_name_len(arena, block_ref, li);
        if (nlen == init_e.var_name_len && nlen > 0) {
          let matched: i32 = 1;
          let nb: u8[256] = [];
          pipeline_block_let_name_copy64(arena, block_ref, li, &nb[0]);
          let ci: i32 = 0;
          while (ci < nlen) {
            if (nb[ci] != init_e.var_name[ci]) {
              matched = 0;
              ci = nlen;
            } else {
              ci = ci + 1;
            }
          }
          if (matched != 0) {
            let tr: i32 = pipeline_block_let_type_ref(arena, block_ref, li);
            if (pipeline_type_kind_ord_at(arena, tr) == 10) {
              arr_sz = pipeline_type_array_size_at(arena, tr);
              li = let_idx;
            }
          }
        }
        li = li + 1;
      }
      if (arr_sz <= 0 && !ast.ref_is_null(init_e.resolved_type_ref) && init_e.resolved_type_ref > 0) {
        if (pipeline_type_kind_ord_at(arena, init_e.resolved_type_ref) == 10) {
          arr_sz = pipeline_type_array_size_at(arena, init_e.resolved_type_ref);
        }
      }
      /*
       * Typeck stamps `[a]` row resolved_type_ref to TYPE_SLICE, so the fallback
       * above misses N. Decl type is still TYPE_ARRAY: scan same-block consts,
       * then parent lets/consts. Seed twin: codegen_gen.linux.x86_64.c
       * (live `-E` is host-cc of that seed). Do not fork a second dest-SLICE
       * VAR parent-block const scan. PLATFORM: SHARED host-C.
       */
      if (arr_sz <= 0) {
        let brw: i32 = block_ref;
        let hop: i32 = 0;
        while (arr_sz <= 0 && hop < 32) {
          if (ast.ref_is_null(brw) || brw <= 0 || brw > arena.num_blocks) {
            hop = 32;
          } else {
            if (hop > 0) {
              let nlets_w: i32 = ast_ast_block_num_lets(arena, brw);
              let liw: i32 = 0;
              while (liw < nlets_w && arr_sz <= 0) {
                let nlen_w: i32 = pipeline_block_let_name_len(arena, brw, liw);
                if (nlen_w == init_e.var_name_len && nlen_w > 0) {
                  let matched_w: i32 = 1;
                  let nbw: u8[256] = [];
                  pipeline_block_let_name_copy64(arena, brw, liw, &nbw[0]);
                  let ciw: i32 = 0;
                  while (ciw < nlen_w) {
                    if (nbw[ciw] != init_e.var_name[ciw]) {
                      matched_w = 0;
                      ciw = nlen_w;
                    } else {
                      ciw = ciw + 1;
                    }
                  }
                  if (matched_w != 0) {
                    let trw: i32 = pipeline_block_let_type_ref(arena, brw, liw);
                    if (pipeline_type_kind_ord_at(arena, trw) == 10) {
                      arr_sz = pipeline_type_array_size_at(arena, trw);
                    }
                  }
                }
                liw = liw + 1;
              }
            }
            let nconst_w: i32 = ast_ast_block_num_consts(arena, brw);
            let ci_c: i32 = 0;
            while (ci_c < nconst_w && arr_sz <= 0) {
              let clen: i32 = pipeline_block_const_name_len(arena, brw, ci_c);
              if (clen == init_e.var_name_len && clen > 0) {
                let matched_c: i32 = 1;
                let nbc: u8[256] = [];
                pipeline_block_const_name_copy64(arena, brw, ci_c, &nbc[0]);
                let cic: i32 = 0;
                while (cic < clen) {
                  if (nbc[cic] != init_e.var_name[cic]) {
                    matched_c = 0;
                    cic = clen;
                  } else {
                    cic = cic + 1;
                  }
                }
                if (matched_c != 0) {
                  let trc: i32 = pipeline_block_const_type_ref(arena, brw, ci_c);
                  if (pipeline_type_kind_ord_at(arena, trc) == 10) {
                    arr_sz = pipeline_type_array_size_at(arena, trc);
                  }
                }
              }
              ci_c = ci_c + 1;
            }
            let blkw: Block = ast.ast_arena_block_get(arena, brw);
            brw = blkw.parent_block_ref;
            hop = hop + 1;
          }
        }
      }
    } else if (init_ko == 44
               && init_e.field_access_field_len > 0
               && init_e.field_access_base_ref > 0
               && init_e.field_access_base_ref <= arena.num_exprs) {
      /*
       * dest-SLICE FIELD: VAR / STRUCT_LIT / CALL / METHOD / INDEX.
       * Typeck stamps FIELD to TYPE_SLICE, hiding N. Recover N from the
       * base TYPE_NAMED layout (same as glue_field_access_field_type_ref).
       * CALL/METHOD return temps die — .data memcpy into unique static[N].
       * STRUCT_LIT C compound has block duration; INDEX/VAR view the object.
       * Seed twin: codegen_gen.linux.x86_64.c (live `-E` is host-cc of that seed).
       * Do not fork a second dest-SLICE non-VAR FIELD wrap.
       * PLATFORM: SHARED host-C.
       */
      is_field = 1;
      base_e = ast.ast_arena_expr_get(arena, init_e.field_access_base_ref);
      field_base_ko = pipeline_expr_kind_ord_at(arena, init_e.field_access_base_ref);
      if (!ast.ref_is_null(init_e.resolved_type_ref) && init_e.resolved_type_ref > 0) {
        if (pipeline_type_kind_ord_at(arena, init_e.resolved_type_ref) == 10) {
          arr_sz = pipeline_type_array_size_at(arena, init_e.resolved_type_ref);
        }
      }
      if (arr_sz <= 0 && ctx != 0 as *PipelineDepCtx) {
        let snm: u8[256] = [];
        let snl: i32 = 0;
        if (field_base_ko == 45 && base_e.struct_lit_struct_name_len > 0) {
          snl = base_e.struct_lit_struct_name_len;
          let si: i32 = 0;
          while (si < snl && si < 127) {
            snm[si] = base_e.struct_lit_struct_name[si];
            si = si + 1;
          }
        } else {
          let bty: i32 = pipeline_expr_resolved_type_ref(arena, init_e.field_access_base_ref);
          if (!ast.ref_is_null(bty) && bty > 0) {
            let bk: i32 = pipeline_type_kind_ord_at(arena, bty);
            if (bk == 9) {
              bty = pipeline_type_elem_ref_at(arena, bty);
              if (!ast.ref_is_null(bty) && bty > 0) {
                bk = pipeline_type_kind_ord_at(arena, bty);
              }
            }
            if (bk == 8) {
              snl = pipeline_type_named_name_into(arena, bty, &snm[0]);
            }
          }
        }
        if (snl > 0) {
          let ftr: i32 = codegen_lookup_struct_field_type_ref(
            arena, ctx, &snm[0], snl,
            &init_e.field_access_field_name[0], init_e.field_access_field_len);
          if (!ast.ref_is_null(ftr) && ftr > 0) {
            if (pipeline_type_kind_ord_at(arena, ftr) == 10) {
              arr_sz = pipeline_type_array_size_at(arena, ftr);
            }
          }
        }
      }
      /*
       * dest-SLICE import-module const FIELD (`dep.A`): typeck stamps
       * the FIELD to TYPE_SLICE (arr_sz=0). Import bindings may also
       * be TYPE_NAMED, so a named-gate cannot distinguish them from
       * struct fields. Return 0 whenever N is missing — caller
       * fallback wraps `{.data=A,.length=N}`. Struct fields that
       * recovered N (arr_sz>0) still wrap here. PLATFORM: SHARED host-C.
       */
      if (arr_sz <= 0) {
        return 0;
      }
    } else if ((init_ko == 48 || init_ko == 49) && ctx != 0 as *PipelineDepCtx) {
      /*
       * CALL / METHOD_CALL row: N from callee return TYPE_ARRAY.
       * Typeck stamps the dest-SLICE row to TYPE_SLICE, hiding N.
       * Same-module: current_codegen_module + caller arena.
       * Dep-module: dep module + dep arena (type_ref is arena-local).
       * PLATFORM: SHARED host-C.
       */
      is_call = 1;
      let func_ix: i32 = pipeline_expr_call_resolved_func_index_at(arena, linit_ref);
      let dep_ix: i32 = pipeline_expr_call_resolved_dep_index_at(arena, linit_ref);
      let res_mod: *Module = ctx.current_codegen_module;
      if (dep_ix < 0 && res_mod != 0 as *Module && func_ix >= 0
          && func_ix < res_mod.num_funcs) {
        let rty: i32 = pipeline_module_func_return_type_at(res_mod, func_ix);
        if (!ast.ref_is_null(rty) && rty > 0) {
          if (pipeline_type_kind_ord_at(arena, rty) == 10) {
            arr_sz = pipeline_type_array_size_at(arena, rty);
          }
        }
      } else if (dep_ix >= 0 && func_ix >= 0) {
        let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, dep_ix);
        let dep_ar: *ASTArena = pipeline_dep_ctx_arena_at(ctx, dep_ix);
        if (dep_mod != 0 as *Module && func_ix < dep_mod.num_funcs) {
          let rty_d: i32 = pipeline_module_func_return_type_at(dep_mod, func_ix);
          if (!ast.ref_is_null(rty_d) && rty_d > 0 && dep_ar != 0 as *ASTArena) {
            if (pipeline_type_kind_ord_at(dep_ar, rty_d) == 10) {
              arr_sz = pipeline_type_array_size_at(dep_ar, rty_d);
            }
          }
        }
      }
      if (arr_sz <= 0) {
        return 0;
      }
    } else if (init_ko == 47) {
      /*
       * INDEX row: dest-SLICE stamps INDEX to TYPE_SLICE, hiding N.
       * N from base elem TYPE_ARRAY. C `a[i]` of `[K][N]T` / `[][N]T`
       * decays to E* — `.data = a[i]` is a legal pointer rvalue.
       * PLATFORM: SHARED host-C.
       */
      is_call = 1;
      let ix_base: i32 = pipeline_expr_index_base_ref(arena, linit_ref);
      if (ix_base > 0 && ix_base <= arena.num_exprs) {
        let bty: i32 = pipeline_expr_resolved_type_ref(arena, ix_base);
        if (!ast.ref_is_null(bty) && bty > 0) {
          let bk: i32 = pipeline_type_kind_ord_at(arena, bty);
          if (bk == 10 || bk == 11) {
            let ety: i32 = pipeline_type_elem_ref_at(arena, bty);
            if (!ast.ref_is_null(ety) && ety > 0) {
              if (pipeline_type_kind_ord_at(arena, ety) == 10) {
                arr_sz = pipeline_type_array_size_at(arena, ety);
              }
            }
          }
        }
        /*
         * Module-level dest-SLICE const INDEX: typeck may accept the
         * const-expr without stamping the base VAR (no block walk).
         * Recover N from the base name's module TYPE_ARRAY decl:
         * `[K][N]T` → elem size N. Also honor a still-unstamped INDEX
         * resolved TYPE_ARRAY (the row). PLATFORM: SHARED host-C.
         */
        if (arr_sz <= 0) {
          let ity: i32 = pipeline_expr_resolved_type_ref(arena, linit_ref);
          if (!ast.ref_is_null(ity) && ity > 0) {
            if (pipeline_type_kind_ord_at(arena, ity) == 10) {
              arr_sz = pipeline_type_array_size_at(arena, ity);
            }
          }
        }
        if (arr_sz <= 0 && ctx != 0 as *PipelineDepCtx) {
          let be: Expr = ast.ast_arena_expr_get(arena, ix_base);
          if (pipeline_expr_kind_ord_at(arena, ix_base) == 3 && be.var_name_len > 0) {
            let ix_mod: *Module = ctx.current_codegen_module;
            if (ix_mod != 0 as *Module) {
              let tli: i32 = 0;
              while (tli < ix_mod.num_top_level_lets && arr_sz <= 0) {
                let nlen_tl: i32 = pipeline_module_top_level_let_name_len(ix_mod, tli);
                if (nlen_tl == be.var_name_len && nlen_tl > 0) {
                  let matched_tl: i32 = 1;
                  let ci_tl: i32 = 0;
                  while (ci_tl < nlen_tl) {
                    if (pipeline_module_top_level_let_name_byte_at(ix_mod, tli, ci_tl) != be.var_name[ci_tl]) {
                      matched_tl = 0;
                      ci_tl = nlen_tl;
                    } else {
                      ci_tl = ci_tl + 1;
                    }
                  }
                  if (matched_tl != 0) {
                    let tr_tl: i32 = pipeline_module_top_level_let_type_ref(ix_mod, tli);
                    if (!ast.ref_is_null(tr_tl) && pipeline_type_kind_ord_at(arena, tr_tl) == 10) {
                      let ety_tl: i32 = pipeline_type_elem_ref_at(arena, tr_tl);
                      if (!ast.ref_is_null(ety_tl) && pipeline_type_kind_ord_at(arena, ety_tl) == 10) {
                        arr_sz = pipeline_type_array_size_at(arena, ety_tl);
                      }
                    }
                  }
                }
                tli = tli + 1;
              }
            }
          }
        }
      }
      if (arr_sz <= 0) {
        return 0;
      }
    } else {
      return 0;
    }
    if (arr_sz <= 0 && is_field == 0) {
      return 0;
    }
    /* Typed compound: `(T[]){ .data = …, .length = N }` — assignment-safe. */
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    if (codegen_emit_type(arena, out, let_type_ref, 0 as *u8, 0, ctx) != 0) {
      let fb_sl: u8[28] = [
        115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95,
        105, 110, 116, 51, 50, 95, 116, 0, 0
      ];
      if (codegen_emit_bytes_from_ptr(out, &fb_sl[0], 26) != 0) {
        return -1;
      }
    }
    if (codegen_append_byte(out, 41) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 123) != 0) {
      return -1;
    }
    let d1: u8[9] = [32, 46, 100, 97, 116, 97, 32, 61, 32];
    if (codegen_emit_bytes_from_ptr(out, &d1[0], 9) != 0) {
      return -1;
    }
    if (is_field != 0) {
      if (field_base_ko == 48 || field_base_ko == 49) {
        /*
         * CALL/METHOD return temps die at the end of the full expression.
         * Copy the field array into a unique static[N] (same durability as
         * dest-SLICE ARRAY_LIT). PLATFORM: SHARED host-C.
         */
        let tid: i32 = codegen_next_host_call_array_tmp_id();
        let elem_tr: i32 = pipeline_type_elem_ref_at(arena, let_type_ref);
        /* ({ static  */
        let fb_open: u8[12] = [40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &fb_open[0], 10) != 0) {
          return -1;
        }
        if (!ast.ref_is_null(elem_tr) && elem_tr > 0) {
          if (codegen_emit_type(arena, out, elem_tr, 0 as *u8, 0, ctx) != 0) {
            let fb_e: u8[9] = [105, 110, 116, 51, 50, 95, 116, 0, 0];
            if (codegen_emit_bytes_9(out, &fb_e[0], 7) != 0) {
              return -1;
            }
          }
        } else {
          let fb_e2: u8[9] = [105, 110, 116, 51, 50, 95, 116, 0, 0];
          if (codegen_emit_bytes_9(out, &fb_e2[0], 7) != 0) {
            return -1;
          }
        }
        /*  __xlang_fb */
        let fb_nm: u8[12] = [32, 95, 95, 120, 108, 97, 110, 103, 95, 102, 98, 0];
        if (codegen_emit_bytes_from_ptr(out, &fb_nm[0], 11) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 91) != 0) {
          return -1;
        }
        if (format_int(out, arr_sz) != 0) {
          return -1;
        }
        /* ]; memcpy((void*)(__xlang_fb */
        let fb_cp: u8[32] = [
          93, 59, 32, 109, 101, 109, 99, 112, 121, 40, 40, 118, 111, 105, 100, 42,
          41, 40, 95, 95, 120, 108, 97, 110, 103, 95, 102, 98, 0, 0, 0, 0
        ];
        if (codegen_emit_bytes_from_ptr(out, &fb_cp[0], 28) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* ), (const void*)(( */
        let fb_mid: u8[24] = [
          41, 44, 32, 40, 99, 111, 110, 115, 116, 32, 118, 111, 105, 100, 42, 41,
          40, 40, 0, 0, 0, 0, 0, 0
        ];
        if (codegen_emit_bytes_from_ptr(out, &fb_mid[0], 18) != 0) {
          return -1;
        }
        if (codegen_emit_expr(arena, out, init_e.field_access_base_ref, ctx) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 41) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 46) != 0) {
          return -1;
        }
        if (codegen_emit_bytes_64(out, &init_e.field_access_field_name[0], init_e.field_access_field_len) != 0) {
          return -1;
        }
        /* ), sizeof(__xlang_fb */
        let fb_sz: u8[24] = [
          41, 44, 32, 115, 105, 122, 101, 111, 102, 40, 95, 95, 120, 108, 97, 110,
          103, 95, 102, 98, 0, 0, 0, 0
        ];
        if (codegen_emit_bytes_from_ptr(out, &fb_sz[0], 20) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* )); __xlang_fb */
        let fb_tl: u8[16] = [41, 41, 59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 102, 98, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &fb_tl[0], 14) != 0) {
          return -1;
        }
        if (format_int(out, tid as i64) != 0) {
          return -1;
        }
        /* ; }) */
        let fb_end: u8[8] = [59, 32, 125, 41, 0, 0, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &fb_end[0], 4) != 0) {
          return -1;
        }
      } else if (field_base_ko == 3 && base_e.var_name_len > 0) {
        if (codegen_emit_bytes_64(out, &base_e.var_name[0], base_e.var_name_len) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 46) != 0) {
          return -1;
        }
        if (codegen_emit_bytes_64(out, &init_e.field_access_field_name[0], init_e.field_access_field_len) != 0) {
          return -1;
        }
      } else {
        /* STRUCT_LIT / INDEX / DEREF: ((base).field) — C array decays. */
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        if (codegen_emit_expr(arena, out, init_e.field_access_base_ref, ctx) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 41) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 46) != 0) {
          return -1;
        }
        if (codegen_emit_bytes_64(out, &init_e.field_access_field_name[0], init_e.field_access_field_len) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 41) != 0) {
          return -1;
        }
      }
    } else if (is_call != 0) {
      /* ARRAY return ABI is E* — `.data = mk()` is a legal pointer rvalue. */
      if (codegen_emit_expr(arena, out, linit_ref, ctx) != 0) {
        return -1;
      }
    } else {
      if (codegen_emit_bytes_64(out, &init_e.var_name[0], init_e.var_name_len) != 0) {
        return -1;
      }
    }
    let d2: u8[12] = [44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32];
    if (codegen_emit_bytes_from_ptr(out, &d2[0], 12) != 0) {
      return -1;
    }
    if (arr_sz > 0) {
      if (format_int(out, arr_sz) != 0) {
        return -1;
      }
    } else {
      /* (sizeof(b.a)/sizeof((b.a)[0])) — host-C length when typeck N missing. */
      let sz0: u8[8] = [40, 115, 105, 122, 101, 111, 102, 40];
      let sz1: u8[12] = [41, 47, 115, 105, 122, 101, 111, 102, 40, 40, 0, 0];
      let sz2: u8[8] = [41, 91, 48, 93, 41, 41, 0, 0]; /* )[0])) */
      if (codegen_emit_bytes_from_ptr(out, &sz0[0], 8) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_64(out, &base_e.var_name[0], base_e.var_name_len) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 46) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_64(out, &init_e.field_access_field_name[0], init_e.field_access_field_len) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_from_ptr(out, &sz1[0], 10) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_64(out, &base_e.var_name[0], base_e.var_name_len) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 46) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_64(out, &init_e.field_access_field_name[0], init_e.field_access_field_len) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_from_ptr(out, &sz2[0], 6) != 0) {
        return -1;
      }
    }
    let d3: u8[4] = [32, 125, 0, 0];
    if (codegen_emit_bytes_4(out, &d3[0], 2) != 0) {
      return -1;
    }
    return 1;
  }
}

/**
 * Host-C dest-SLICE wrap of an import-module const FIELD (`dep.A`).
 * try_emit treats `dep.A` as a struct member (`dep.A`) because the
 * base is EXPR_VAR. Import bindings are not TYPE_NAMED, so try_emit
 * now returns 0. This sibling emits `(T){ .data = <import-const>, .length = N }`
 * with N from the dep-arena TYPE_ARRAY (type_ref is not portable).
 * `.data` reuses emit_import_module_const_field (INT_LIT or inlined
 * `(E[]){…}`) because consts-only deps are not co-emitted.
 *
 * G.7: fallback family, own local-slot budget. Invoked from
 * try_emit_dest_slice_from_module_array_var when linit is FIELD so
 * every try_emit==0 caller is covered. Do not add this walk to
 * try_emit. Do not add an 8th pointer param.
 * Seed twin: codegen_gen.linux.x86_64.c (live `-E` is host-cc of that
 * seed). Do not fork a second import-const FIELD wrap.
 *
 * @param arena *ASTArena — caller type/expr pool (dest_type_ref)
 * @param out *CodegenOutBuf — C text sink
 * @param dest_type_ref i32 — dest TYPE_SLICE (kind 11)
 * @param linit_ref i32 — EXPR_FIELD_ACCESS of an import binding
 * @param ctx *PipelineDepCtx — dep table; null → 0
 * @return i32 — 1 emitted; 0 not applicable; -1 hard fail
 * PLATFORM: SHARED host-C emit
 */
export function try_emit_dest_slice_from_import_const_field(
  arena: *ASTArena,
  out: *CodegenOutBuf,
  dest_type_ref: i32,
  linit_ref: i32,
  ctx: *PipelineDepCtx
): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf) {
      return 0;
    }
    if (ast.ref_is_null(dest_type_ref) || pipeline_type_kind_ord_at(arena, dest_type_ref) != 11) {
      return 0;
    }
    if (ast.ref_is_null(linit_ref) || linit_ref <= 0 || linit_ref > arena.num_exprs) {
      return 0;
    }
    if (ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    let init_e: Expr = ast.ast_arena_expr_get(arena, linit_ref);
    if ((init_e.kind as i32) != 44 || init_e.field_access_field_len <= 0) {
      return 0;
    }
    let dep_path: u8[128] = [];
    let dep_path_len: i32 = codegen_resolve_binding_import_path_for_field_access(
      ctx, arena, linit_ref, &dep_path[0]);
    if (dep_path_len <= 0) {
      return 0;
    }
    let dep_ix: i32 = codegen_find_dep_index_by_path(ctx, &dep_path[0], dep_path_len);
    /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
    let ndep_fa: i32 = pipeline_dep_ctx_ndep(ctx);
    if (dep_ix < 0 || dep_ix >= ndep_fa) {
      return 0;
    }
    let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, dep_ix);
    let dep_ar: *ASTArena = pipeline_dep_ctx_arena_at(ctx, dep_ix);
    if (dep_mod == 0 as *Module || dep_ar == 0 as *ASTArena) {
      return 0;
    }
    let arr_sz: i32 = 0;
    let ti: i32 = 0;
    while (ti < dep_mod.num_top_level_lets && arr_sz <= 0) {
      if (pipeline_module_top_level_let_is_const(dep_mod, ti) == 0) {
        ti = ti + 1;
      } else {
        let nlen: i32 = pipeline_module_top_level_let_name_len(dep_mod, ti);
        if (nlen == init_e.field_access_field_len && nlen > 0) {
          let matched: i32 = 1;
          let ci: i32 = 0;
          while (ci < nlen) {
            if (pipeline_module_top_level_let_name_byte_at(dep_mod, ti, ci)
                != init_e.field_access_field_name[ci]) {
              matched = 0;
              ci = nlen;
            } else {
              ci = ci + 1;
            }
          }
          if (matched != 0) {
            let tr: i32 = pipeline_module_top_level_let_type_ref(dep_mod, ti);
            if (!ast.ref_is_null(tr) && pipeline_type_kind_ord_at(dep_ar, tr) == 10) {
              arr_sz = pipeline_type_array_size_at(dep_ar, tr);
            }
          }
        }
        ti = ti + 1;
      }
    }
    if (arr_sz <= 0) {
      return 0;
    }
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    if (codegen_emit_type(arena, out, dest_type_ref, 0 as *u8, 0, ctx) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 41) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 123) != 0) {
      return -1;
    }
    let d1: u8[12] = [32, 46, 100, 97, 116, 97, 32, 61, 32, 0, 0, 0];
    if (codegen_emit_bytes_from_ptr(out, &d1[0], 9) != 0) {
      return -1;
    }
    /*
     * .data = emit_import_module_const_field: INT_LIT digits or inlined
     * `(T[]){…}` (consts-only deps have no file-static `A`). Fallback
     * bare field name if the import lookup misses. PLATFORM: SHARED.
     */
    if (emit_import_module_const_field(arena, out, linit_ref, ctx) != 0) {
      if (codegen_emit_bytes_64(out, &init_e.field_access_field_name[0], init_e.field_access_field_len) != 0) {
        return -1;
      }
    }
    let d2: u8[16] = [44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0, 0];
    if (codegen_emit_bytes_from_ptr(out, &d2[0], 12) != 0) {
      return -1;
    }
    if (format_int(out, arr_sz) != 0) {
      return -1;
    }
    let d3: u8[4] = [32, 125, 0, 0];
    if (codegen_emit_bytes_4(out, &d3[0], 2) != 0) {
      return -1;
    }
    return 1;
  }
}

/**
 * Host-C dest-SLICE wrap of a module top-level TYPE_ARRAY VAR.
 * try_emit_slice_init_from_array_var only scans block lets/consts. A
 * module-table walk / 8th Module* / extra helper call inside that
 * function overflows the assembler local-slot cap (cis / nslvar host
 * BLD001). File-scope decl and init_globals already inlined this walk
 * after try_emit==0. Function-scope codegen_emit_block had no fallback →
 * `s = A` (array into slice struct) host-cc BLD001.
 *
 * G.7: one helper. Callers invoke it only after try_emit returns 0.
 * Never add this walk to try_emit. Never add ARRAY_LIT here
 * (function-scope (E[]){…} would dangle if init_globals reused it).
 * Import-module const FIELD dispatches to
 * try_emit_dest_slice_from_import_const_field (own slot budget).
 *
 * Emits `(T){ .data = Name, .length = N }` when linit is EXPR_VAR
 * matching a current_codegen_module top-level let/const of TYPE_ARRAY.
 * Uses Expr.kind (not kind_ord sidecar) so a missed EXPR_VAR stamp
 * still matches, same as the former file-scope inline fallback.
 *
 * @param arena *ASTArena — type/expr pool (same arena as dest_type_ref)
 * @param out *CodegenOutBuf — C text sink
 * @param dest_type_ref i32 — dest TYPE_SLICE (kind 11)
 * @param linit_ref i32 — init expr; EXPR_VAR or import-module const FIELD
 * @param ctx *PipelineDepCtx — current_codegen_module; null → 0
 * @return i32 — 1 emitted; 0 not applicable; -1 hard fail
 * PLATFORM: SHARED host-C emit
 */
// no_mangle: codegen_late calls try_emit_dest_slice_from_module_array_var. A codegen_ prefix misses that call.
#[no_mangle]
export function try_emit_dest_slice_from_module_array_var(
  arena: *ASTArena,
  out: *CodegenOutBuf,
  dest_type_ref: i32,
  linit_ref: i32,
  ctx: *PipelineDepCtx
): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf) {
      return 0;
    }
    if (ast.ref_is_null(dest_type_ref) || pipeline_type_kind_ord_at(arena, dest_type_ref) != 11) {
      return 0;
    }
    if (ast.ref_is_null(linit_ref) || linit_ref <= 0 || linit_ref > arena.num_exprs) {
      return 0;
    }
    if (ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    let init_e: Expr = ast.ast_arena_expr_get(arena, linit_ref);
    /*
     * Import-module const FIELD (`dep.A`) is not a current-module VAR.
     * Dispatch before the current_codegen_module gate: the sibling
     * walks the dep table, not this module. PLATFORM: SHARED.
     */
    if ((init_e.kind as i32) == 44) {
      return try_emit_dest_slice_from_import_const_field(
        arena, out, dest_type_ref, linit_ref, ctx);
    }
    if (ctx.current_codegen_module == 0 as *Module) {
      return 0;
    }
    if ((init_e.kind as i32) != 3 || init_e.var_name_len <= 0) {
      return 0;
    }
    let scan_mod: *Module = ctx.current_codegen_module;
    let arr_sz: i32 = 0;
    let ti: i32 = 0;
    while (ti < scan_mod.num_top_level_lets && arr_sz <= 0) {
      let nlen: i32 = pipeline_module_top_level_let_name_len(scan_mod, ti);
      if (nlen == init_e.var_name_len && nlen > 0) {
        let matched: i32 = 1;
        let ci: i32 = 0;
        while (ci < nlen) {
          if (pipeline_module_top_level_let_name_byte_at(scan_mod, ti, ci) != init_e.var_name[ci]) {
            matched = 0;
            ci = nlen;
          } else {
            ci = ci + 1;
          }
        }
        if (matched != 0) {
          let tr: i32 = pipeline_module_top_level_let_type_ref(scan_mod, ti);
          if (!ast.ref_is_null(tr) && pipeline_type_kind_ord_at(arena, tr) == 10) {
            arr_sz = pipeline_type_array_size_at(arena, tr);
          }
        }
      }
      ti = ti + 1;
    }
    if (arr_sz <= 0) {
      return 0;
    }
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    if (codegen_emit_type(arena, out, dest_type_ref, 0 as *u8, 0, ctx) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 41) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 123) != 0) {
      return -1;
    }
    let d1: u8[12] = [32, 46, 100, 97, 116, 97, 32, 61, 32, 0, 0, 0];
    if (codegen_emit_bytes_from_ptr(out, &d1[0], 9) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &init_e.var_name[0], init_e.var_name_len) != 0) {
      return -1;
    }
    let d2: u8[16] = [44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0, 0];
    if (codegen_emit_bytes_from_ptr(out, &d2[0], 12) != 0) {
      return -1;
    }
    if (format_int(out, arr_sz) != 0) {
      return -1;
    }
    let d3: u8[4] = [32, 125, 0, 0];
    if (codegen_emit_bytes_4(out, &d3[0], 2) != 0) {
      return -1;
    }
    return 1;
  }
}

/**
 * Peel TYPE_ARRAY / TYPE_PTR / TYPE_SLICE (and aliases) down to TYPE_NAMED.
 * Anonymous `{ fields }` inside `let x: Iovec[4] = [{...}]` must recover dest
 * Iovec, not the enclosing function return (often i64) and not empty prefix.
 * @param arena *ASTArena — type pool
 * @param type_ref i32 — dest type; 0/null → 0
 * @return i32 — TYPE_NAMED ref or 0
 * PLATFORM: SHARED host-C STRUCT_LIT dest peel (pair skip_abi_dup Iovec).
 */
export function codegen_peel_named_dest_type(arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let rec: i32 = type_ref;
    let peel: i32 = 0;
    if (arena == 0 as *ASTArena || ast.ref_is_null(type_ref) || type_ref <= 0) {
      return 0;
    }
    while (peel < 4) {
      if (ast.ref_is_null(rec) || rec <= 0 || rec > arena.num_types) {
        return 0;
      }
      rec = pipeline_typeck_resolve_type_alias_ref_c(arena, rec);
      if (ast.ref_is_null(rec) || rec <= 0 || rec > arena.num_types) {
        return 0;
      }
      let k: i32 = pipeline_type_kind_ord_at(arena, rec);
      if (k == (TypeKind.TYPE_NAMED as i32)) {
        return rec;
      }
      if (k == (TypeKind.TYPE_ARRAY as i32) || k == (TypeKind.TYPE_PTR as i32)
          || k == (TypeKind.TYPE_SLICE as i32)) {
        rec = pipeline_type_elem_ref_at(arena, rec);
        peel = peel + 1;
        continue;
      }
      return 0;
    }
    return 0;
  }
}

/**
 * Stamp anonymous STRUCT_LIT dest name from dest TYPE_NAMED (peel compounds).
 * Dep co-emit leaves struct_lit_struct_name empty; typeck only backfills entry.
 * Let `buf: Buffer = {…}` and array `{f}` elems both use this (G.7 one stamp).
 * @param arena *ASTArena — expression pool
 * @param expr_ref i32 — EXPR_STRUCT_LIT
 * @param dest_type_ref i32 — let/array dest; 0 ok (falls back to expr resolved)
 * @return i32 — 1 stamped, 0 not applicable
 * PLATFORM: SHARED host-C. Why setter: Expr sret SIGBUS on arm64.
 */
export function codegen_stamp_anon_struct_lit_dest(arena: *ASTArena, expr_ref: i32, dest_type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || ast.ref_is_null(expr_ref) || expr_ref <= 0
        || expr_ref > arena.num_exprs) {
      return 0;
    }
    if (pipeline_expr_kind_ord_at(arena, expr_ref) != (ExprKind.EXPR_STRUCT_LIT as i32)) {
      return 0;
    }
    let el: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    if (el.struct_lit_struct_name_len > 0) {
      return 0;
    }
    let dest_n: i32 = codegen_peel_named_dest_type(arena, dest_type_ref);
    if (ast.ref_is_null(dest_n) || dest_n <= 0) {
      dest_n = codegen_peel_named_dest_type(arena, el.resolved_type_ref);
    }
    if (ast.ref_is_null(dest_n) || dest_n <= 0) {
      return 0;
    }
    let dnm: u8[256] = [];
    let dnl: i32 = pipeline_type_named_name_into(arena, dest_n, &dnm[0]);
    if (dnl <= 0 || dnl > 255) {
      return 0;
    }
    pipeline_expr_struct_lit_type_name_set(arena, expr_ref, &dnm[0], dnl);
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, dest_n);
    return 1;
  }
}

/**
 * Host-C: emit `{ e0, e1, … }` for ARRAY_LIT (fixed TYPE_ARRAY / vector let-init).
 * wave357 Cap residual pure: nested ARRAY_LIT rows recurse (multi-dim `{{1,2},{3,4}}`).
 * Prior: each row went through codegen_emit_expr → `(int32_t[]){…}` compound → illegal for `E a[N][M]`.
 * ARRAY-of-SLICE (`[N][]T = [[1,2],[3,4]]`): dest elem is TYPE_SLICE. Recurse-braces
 * yields `struct xlang_slice_* x[N] = {{1,2},{3,4}}` (BLD001 — ints into fat fields).
 * G.7: same authority; TYPE_ARRAY rows still recurse; TYPE_SLICE ARRAY_LIT rows
 * reuse codegen_emit_expr (durable `({ static E al[]={…}; (slice){.data=al,.length=N}; })`);
 * TYPE_SLICE VAR/FIELD/CALL rows reuse try_emit_slice_init_from_array_var
 * (`[N][]T = [a, [3,4]]` / `[mk()]` — codegen_emit_expr of a VAR is a bare array).
 * Module TYPE_ARRAY VAR rows (`[][]T = [A]`) fall through to
 * try_emit_dest_slice_from_module_array_var after try_emit==0.
 * @param arena *ASTArena — expression pool
 * @param out *CodegenOutBuf — C text sink
 * @param init_ref i32 — ARRAY_LIT or fallback expr
 * @param ctx *PipelineDepCtx — nested emit
 * @return i32 — 0 success
 * PLATFORM: SHARED host-C emit
 * Seed twin: codegen_gen.linux.x86_64.c (live `-E` is host-cc of that seed).
 * Do not fork a second dest-ARRAY `[N][]T` wrap_br.
 */
export function codegen_emit_braced_array_lit_init(arena: *ASTArena, out: *CodegenOutBuf, init_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ast.ref_is_null(init_ref) || init_ref <= 0 || init_ref > arena.num_exprs) {
      let z: u8[4] = [123, 32, 48, 0];
      if (codegen_emit_bytes_4(out, &z[0], 3) != 0) {
        return -1;
      }
      return 0;
    }
    /* See implementation. */
    if (pipeline_expr_kind_ord_at(arena, init_ref) != (46 as i32)) {
      if (codegen_emit_expr(arena, out, init_ref, ctx) != 0) {
        return -1;
      }
      return 0;
    }
    /*
     * Dest-elem TYPE_SLICE (`[N][]T` / `[][]T` if this helper is reused):
     * every nested ARRAY_LIT row is a fat slice, not a braced C array.
     * Also honor a stamped elem resolved_type_ref when the outer dest is missing.
     * PLATFORM: SHARED host-C.
     */
    let dest_elem_is_slice: i32 = 0;
    let self_e: Expr = ast.ast_arena_expr_get(arena, init_ref);
    if (!ast.ref_is_null(self_e.resolved_type_ref) && self_e.resolved_type_ref > 0
        && self_e.resolved_type_ref <= arena.num_types) {
      let stk: i32 = pipeline_type_kind_ord_at(arena, self_e.resolved_type_ref);
      if (stk == (TypeKind.TYPE_ARRAY as i32) || stk == (TypeKind.TYPE_SLICE as i32)) {
        let et: i32 = pipeline_type_elem_ref_at(arena, self_e.resolved_type_ref);
        if (!ast.ref_is_null(et) && pipeline_type_kind_ord_at(arena, et) == (TypeKind.TYPE_SLICE as i32)) {
          dest_elem_is_slice = 1;
        }
      }
    }
    if (codegen_append_byte(out, 123) != 0) {
      return -1;
    }
    let n: i32 = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
    let ai: i32 = 0;
    while (ai < n) {
      if (ai > 0) {
        let comma: u8[3] = [44, 32, 0];
        if (codegen_emit_bytes_3(out, &comma[0], 2) == 0) {
          ai = ai;
        } else {
          return -1;
        }
      }
      let elem_ref: i32 = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
      let row_is_slice: i32 = dest_elem_is_slice;
      if (row_is_slice == 0 && !ast.ref_is_null(elem_ref) && elem_ref > 0 && elem_ref <= arena.num_exprs) {
        let er: Expr = ast.ast_arena_expr_get(arena, elem_ref);
        if (!ast.ref_is_null(er.resolved_type_ref) && er.resolved_type_ref > 0
            && er.resolved_type_ref <= arena.num_types) {
          if (pipeline_type_kind_ord_at(arena, er.resolved_type_ref) == (TypeKind.TYPE_SLICE as i32)) {
            row_is_slice = 1;
          }
        }
      }
      /* Nested TYPE_ARRAY row: recurse braces (not codegen_emit_expr — that yields (T[]){…}).
       * Nested TYPE_SLICE ARRAY_LIT: codegen_emit_expr (durable static + {.data,.length}).
       * Nested TYPE_SLICE VAR/FIELD/CALL: try_emit wrap (bare `a` / `mk()` is not a fat). */
      if (!ast.ref_is_null(elem_ref) && pipeline_expr_kind_ord_at(arena, elem_ref) == (46 as i32)
          && row_is_slice == 0) {
        if (codegen_emit_braced_array_lit_init(arena, out, elem_ref, ctx) != 0) {
          return -1;
        }
        ai = ai + 1;
      } else {
        let wrap_br: i32 = 0;
        if (row_is_slice != 0 && !ast.ref_is_null(elem_ref)) {
          let br_br: i32 = 0;
          let nlets_br: i32 = 0;
          let et_br: i32 = 0;
          if (ctx != 0 as *PipelineDepCtx) {
            br_br = ctx.current_block_ref;
            if ((ast.ref_is_null(br_br) || br_br <= 0 || br_br > arena.num_blocks)
                && ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0) {
              br_br = pipeline_module_func_body_ref_at(ctx.current_codegen_module, ctx.current_func_index);
            }
            if (!ast.ref_is_null(br_br) && br_br > 0 && br_br <= arena.num_blocks) {
              nlets_br = ast_ast_block_num_lets(arena, br_br);
            }
          }
          if (!ast.ref_is_null(self_e.resolved_type_ref) && self_e.resolved_type_ref > 0
              && self_e.resolved_type_ref <= arena.num_types) {
            let stk_br: i32 = pipeline_type_kind_ord_at(arena, self_e.resolved_type_ref);
            if (stk_br == (TypeKind.TYPE_ARRAY as i32) || stk_br == (TypeKind.TYPE_SLICE as i32)) {
              et_br = pipeline_type_elem_ref_at(arena, self_e.resolved_type_ref);
            }
          }
          if (ast.ref_is_null(et_br) || et_br <= 0) {
            let er_br: Expr = ast.ast_arena_expr_get(arena, elem_ref);
            et_br = er_br.resolved_type_ref;
          }
          if (!ast.ref_is_null(et_br) && et_br > 0
              && pipeline_type_kind_ord_at(arena, et_br) == (TypeKind.TYPE_SLICE as i32)) {
            wrap_br = try_emit_slice_init_from_array_var(arena, out, br_br, nlets_br, et_br, elem_ref, ctx);
            if (wrap_br == 0) {
              wrap_br = try_emit_dest_slice_from_module_array_var(arena, out, et_br, elem_ref, ctx);
            }
          }
        }
        if (wrap_br < 0) {
          return -1;
        }
        /*
         * Stamp dest TYPE_NAMED onto anonymous STRUCT_LIT elems so codegen_emit_expr
         * skip_abi_dup sees Iovec → std_io_sync_, not empty prefix std_fs_posix_
         * (fs_formal KEEP_C host-cc incomplete type → missing fs.o → BLD001).
         * ARRAY_LIT dest is stamped by typeck or emit_local_fixed_array_let_finish.
         * PLATFORM: SHARED host-C. G.7 complete STRUCT_LIT dest (pair http Result).
         */
        if (wrap_br == 0 && !ast.ref_is_null(elem_ref)) {
          let _st: i32 = codegen_stamp_anon_struct_lit_dest(arena, elem_ref, self_e.resolved_type_ref);
          _st = _st;
        }
        if (wrap_br == 0 && codegen_emit_expr(arena, out, elem_ref, ctx) != 0) {
          return -1;
        }
        ai = ai + 1;
      }
    }
    if (codegen_append_byte(out, 125) == 0) {
      return 0;
    }
    return -1;
  }
}

/**
 * See implementation.
 */
export function emit_struct_field_type_via_pipeline(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    return pipeline_codegen_emit_struct_field_type(arena, out, type_ref, struct_prefix, struct_prefix_len);
  }
}

/**
 * Look up the type_ref of `struct_name.field_name` in the entry module then deps.
 *
 * Purpose: STRUCT_LIT array-field emit must know the field is TYPE_ARRAY so it can
 * expand `.name = src` (illegal in C) into `.name = { src[0], …, src[N-1] }`.
 * Parameters: arena unused (layout lives on Module); ctx may be null → 0.
 * struct_name may be bare (`OneFuncResult`) or dotted; bare tail is matched.
 * Returns: field type_ref, or 0 if not found.
 * PLATFORM: SHARED — co-emit C TU; verify parser.x host-cc array-init residual.
 */
export function codegen_lookup_struct_field_type_ref(
  arena: *ASTArena,
  ctx: *PipelineDepCtx,
  struct_name: *u8,
  struct_name_len: i32,
  field_name: *u8,
  field_name_len: i32
): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    /* arena unused (layout lives on Module); XLANG has no unused-warning, so no
     * `(void)(arena);` C-style cast needed (such syntax hangs the parser). */
    if (struct_name == 0 as *u8 || struct_name_len <= 0 || field_name == 0 as *u8 || field_name_len <= 0) {
      return 0;
    }
    let bare_off: i32 = 0;
    let bi: i32 = 0;
    while (bi < struct_name_len && bi < 64) {
      if (struct_name[bi] == 46) {
        bare_off = bi + 1;
      }
      bi = bi + 1;
    }
    let bare_len: i32 = struct_name_len - bare_off;
    if (bare_len <= 0) {
      return 0;
    }
    /* wave588 Cap residual: field name content ≤255 (StructLitFieldEntry / layout name[256]). */
    let flen_use: i32 = field_name_len;
    if (flen_use > 127) {
      flen_use = 127;
    }
    let try_mod: *Module = 0 as *Module;
    let pass: i32 = 0;
    while (pass < 2) {
      let nmod: i32 = 1;
      if (pass == 1) {
        if (ctx == 0 as *PipelineDepCtx) {
          break;
        }
        nmod = pipeline_dep_ctx_ndep(ctx);
      }
      let mi: i32 = 0;
      while (mi < nmod) {
        if (pass == 0) {
          if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module) {
            mi = mi + 1;
            continue;
          }
          try_mod = ctx.current_codegen_module;
        } else {
          try_mod = pipeline_dep_ctx_module_at(ctx, mi);
        }
        if (try_mod != 0 as *Module) {
          let k: i32 = 0;
          while (k < try_mod.num_struct_layouts) {
            let snl: i32 = pipeline_module_struct_layout_name_len(try_mod, k);
            if (snl == bare_len && snl > 0) {
              let snm: u8[256] = [];
              pipeline_module_struct_layout_name_into(try_mod, k, &snm[0]);
              let eq: bool = true;
              let sj: i32 = 0;
              while (sj < snl && sj < 64) {
                if (snm[sj] != struct_name[bare_off + sj]) {
                  eq = false;
                  break;
                }
                sj = sj + 1;
              }
              if (eq) {
                let nf: i32 = pipeline_module_struct_layout_num_fields(try_mod, k);
                let j: i32 = 0;
                while (j < nf) {
                  let fnl: i32 = pipeline_module_struct_layout_field_name_len(try_mod, k, j);
                  if (fnl == flen_use && fnl > 0) {
                    let fnm: u8[256] = [];
                    pipeline_module_struct_layout_field_name_into(try_mod, k, j, &fnm[0]);
                    let feq: bool = true;
                    let fj: i32 = 0;
                    while (fj < fnl && fj < 64) {
                      if (fnm[fj] != field_name[fj]) {
                        feq = false;
                        break;
                      }
                      fj = fj + 1;
                    }
                    if (feq) {
                      return pipeline_module_struct_layout_field_type_ref(try_mod, k, j);
                    }
                  }
                  j = j + 1;
                }
              }
            }
            k = k + 1;
          }
        }
        mi = mi + 1;
        if (pass == 0) {
          break;
        }
      }
      pass = pass + 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function codegen_should_skip_emit_struct_layout_for_abi_dup(name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8 || name_len <= 0) {
    return 0;
  }
  let nm_buffer: u8[7] = [66, 117, 102, 102, 101, 114, 0];
  let nm_completion: u8[11] = [67, 111, 109, 112, 108, 101, 116, 105, 111, 110, 0];
  let nm_async_ctx: u8[13] = [65, 115, 121, 110, 99, 67, 111, 110, 116, 101, 120, 116, 0];
  /* See implementation. */
  let nm_error: u8[6] = [69, 114, 114, 111, 114, 0];
  let nm_error_chain: u8[11] = [69, 114, 114, 111, 114, 67, 104, 97, 105, 110, 0];
  /*
   * See implementation.
   * See implementation.
   * PLATFORM: SHARED — seed pin and .x must agree (dual-authority ban).
   */
  let nm_option_us: u8[8] = [79, 112, 116, 105, 111, 110, 95, 0];
  /* See implementation. */
  let nm_option: u8[7] = [79, 112, 116, 105, 111, 110, 0];
  /*
   * rt_preamble one-liner also owns Result_i32 / Result_u8 (core_result_* tags).
   * Co-emit full layout → redefinition of 'core_result_Result_*' (hello / fmt path).
   * 【Invariant】bare Result_i32 / Result_u8 skip — same authority as seed pin.
   */
  let nm_result_i32: u8[11] = [82, 101, 115, 117, 108, 116, 95, 105, 51, 50, 0];
  let nm_result_u8: u8[10] = [82, 101, 115, 117, 108, 116, 95, 117, 56, 0];
  /*
   * See implementation.
   *   struct std_string_String { ... }; typedef ... String;
   *   struct std_string_StrView { ... };
   * See implementation.
   * See implementation.
   */
  let nm_string: u8[7] = [83, 116, 114, 105, 110, 103, 0];
  let nm_str_view: u8[8] = [83, 116, 114, 86, 105, 101, 119, 0];
  /*
   * See implementation.
   *   std_net_TcpStream/Listener/UdpSocket/Ipv4Addr/Ipv6Addr
   * See implementation.
   */
  let nm_tcp_stream: u8[10] = [84, 99, 112, 83, 116, 114, 101, 97, 109, 0];
  let nm_tcp_listener: u8[12] = [84, 99, 112, 76, 105, 115, 116, 101, 110, 101, 114, 0];
  let nm_udp_socket: u8[10] = [85, 100, 112, 83, 111, 99, 107, 101, 116, 0];
  let nm_ipv4: u8[9] = [73, 112, 118, 52, 65, 100, 100, 114, 0];
  let nm_ipv6: u8[9] = [73, 112, 118, 54, 65, 100, 100, 114, 0];
  let nm_sock_v4: u8[13] = [83, 111, 99, 107, 101, 116, 65, 100, 100, 114, 86, 52, 0];
  if (name_len == 6 && codegen_symbuf_bytes_eq(name, name_len, &nm_buffer[0], 6) != 0) {
    return 1;
  }
  if (name_len == 10 && codegen_symbuf_bytes_eq(name, name_len, &nm_completion[0], 10) != 0) {
    return 1;
  }
  if (name_len == 12 && codegen_symbuf_bytes_eq(name, name_len, &nm_async_ctx[0], 12) != 0) {
    return 1;
  }
  if (name_len == 5 && codegen_symbuf_bytes_eq(name, name_len, &nm_error[0], 5) != 0) {
    return 1;
  }
  if (name_len == 10 && codegen_symbuf_bytes_eq(name, name_len, &nm_error_chain[0], 10) != 0) {
    return 1;
  }
  /* See implementation. */
  if (name_len > 7 && codegen_symbuf_bytes_eq(name, 7, &nm_option_us[0], 7) != 0) {
    return 1;
  }
  if (name_len == 6 && codegen_symbuf_bytes_eq(name, name_len, &nm_option[0], 6) != 0) {
    return 1;
  }
  /* Result_i32 / Result_u8 — preamble owns complete core_result_* layouts. */
  if (name_len == 10 && codegen_symbuf_bytes_eq(name, name_len, &nm_result_i32[0], 10) != 0) {
    return 1;
  }
  if (name_len == 9 && codegen_symbuf_bytes_eq(name, name_len, &nm_result_u8[0], 9) != 0) {
    return 1;
  }
  if (name_len == 6 && codegen_symbuf_bytes_eq(name, name_len, &nm_string[0], 6) != 0) {
    return 1;
  }
  if (name_len == 7 && codegen_symbuf_bytes_eq(name, name_len, &nm_str_view[0], 7) != 0) {
    return 1;
  }
  if (name_len == 9 && codegen_symbuf_bytes_eq(name, name_len, &nm_tcp_stream[0], 9) != 0) {
    return 1;
  }
  if (name_len == 11 && codegen_symbuf_bytes_eq(name, name_len, &nm_tcp_listener[0], 11) != 0) {
    return 1;
  }
  if (name_len == 9 && codegen_symbuf_bytes_eq(name, name_len, &nm_udp_socket[0], 9) != 0) {
    return 1;
  }
  if (name_len == 8 && codegen_symbuf_bytes_eq(name, name_len, &nm_ipv4[0], 8) != 0) {
    return 1;
  }
  if (name_len == 8 && codegen_symbuf_bytes_eq(name, name_len, &nm_ipv6[0], 8) != 0) {
    return 1;
  }
  if (name_len == 12 && codegen_symbuf_bytes_eq(name, name_len, &nm_sock_v4[0], 12) != 0) {
    return 1;
  }
  /* Preamble owns Allocator/Arena64/FsIovecBuf/Iovec — skip co-emit redefinition.
   * PLATFORM: SHARED — keep lets flat at function scope. Nested `{ let ... }` anon
   * blocks are parse-skipped by the current product parser (residual body then
   * mis-ingested as top-level lets → illegal static/init_globals in force-regen). */
  let nm_allocator: u8[10] = [65, 108, 108, 111, 99, 97, 116, 111, 114, 0];
  let nm_arena64: u8[8] = [65, 114, 101, 110, 97, 54, 52, 0];
  let nm_fs_iovec: u8[11] = [70, 115, 73, 111, 118, 101, 99, 66, 117, 102, 0];
  let nm_iovec: u8[6] = [73, 111, 118, 101, 99, 0];
  if (name_len == 9 && codegen_symbuf_bytes_eq(name, name_len, &nm_allocator[0], 9) != 0) {
    return 1;
  }
  if (name_len == 7 && codegen_symbuf_bytes_eq(name, name_len, &nm_arena64[0], 7) != 0) {
    return 1;
  }
  if (name_len == 10 && codegen_symbuf_bytes_eq(name, name_len, &nm_fs_iovec[0], 10) != 0) {
    return 1;
  }
  if (name_len == 5 && codegen_symbuf_bytes_eq(name, name_len, &nm_iovec[0], 5) != 0) {
    return 1;
  }
  return 0;
}

/** Exported function `codegen_type_is_module_user_struct`.
 * Implements `codegen_type_is_module_user_struct`.
 * @param module *Module
 * @param arena *ASTArena
 * @param type_ref i32
 * @return i32
 */
export function codegen_type_is_module_user_struct(module: *Module, arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let name_len: i32 = 0;
    let ty_nm: u8[256] = [];
    if (module == 0 as *Module || arena == 0 as *ASTArena || ast.ref_is_null(type_ref)) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, type_ref) != (TypeKind.TYPE_NAMED as i32)) {
      return 0;
    }
    name_len = pipeline_type_named_name_into(arena, type_ref, &ty_nm[0]);
    if (name_len <= 0) {
      return 0;
    }
    let k: i32 = 0;
    while (k < module.num_struct_layouts) {
      let nl: i32 = pipeline_module_struct_layout_name_len(module, k);
      if (nl == name_len) {
        let lay_nm: u8[256] = [];
        pipeline_module_struct_layout_name_into(module, k, &lay_nm[0]);
        let eq: bool = true;
        let j: i32 = 0;
        while (j < nl && j < 64) {
          if (lay_nm[j] != ty_nm[j]) {
            eq = false;
            break;
          }
          j = j + 1;
        }
        if (eq) {
          return 1;
        }
      }
      k = k + 1;
    }
    return 0;
  }
}

/** Return 1 when type_ref names an enum declared on module.
 *
 * Callers emit that type as int32_t. A miss falls through to `struct Name`,
 * which host cc rejects once the enum tag already exists.
 *
 * @param module *Module — enum table to scan; null returns 0
 * @param arena *ASTArena — type pool; null returns 0
 * @param type_ref i32 — must be TYPE_NAMED; otherwise returns 0
 * @return i32 — 1 on a full name match, 0 otherwise
 * PLATFORM: SHARED. The byte compare is split for WINDOWS (see the loop).
 */
export function codegen_type_is_module_user_enum(module: *Module, arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let name_len: i32 = 0;
    let ty_nm: u8[256] = [];
    if (module == 0 as *Module || arena == 0 as *ASTArena || ast.ref_is_null(type_ref)) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, type_ref) != (TypeKind.TYPE_NAMED as i32)) {
      return 0;
    }
    name_len = pipeline_type_named_name_into(arena, type_ref, &ty_nm[0]);
    if (name_len <= 0) {
      return 0;
    }
    let ei: i32 = 0;
    while (ei < module.num_module_enums) {
      let enl: i32 = pipeline_module_enum_name_len(module, ei);
      if (enl == name_len) {
        let eq: bool = true;
        let j: i32 = 0;
        while (j < name_len && j < 64) {
          /* Store each byte before the compare.
           * PLATFORM: WINDOWS. v1 keeps the call result in rbx, then reuses
           * rbx as the index of ty_nm[j]. The compare becomes the type-name
           * byte against j, so every enum misses and the field is emitted
           * as struct. Measured on compile.x -E (ast_Expr.kind). */
          let enum_b: i32 = pipeline_module_enum_name_byte_at(module, ei, j) as i32;
          let name_b: i32 = ty_nm[j] as i32;
          if (enum_b != name_b) {
            eq = false;
            break;
          }
          j = j + 1;
        }
        if (eq) {
          return 1;
        }
      }
      ei = ei + 1;
    }
    return 0;
  }
}

/** Exported function `codegen_type_dep_enum_prefix_into`.
 * Implements `codegen_type_dep_enum_prefix_into`.
 * @param ctx *PipelineDepCtx
 * @param arena *ASTArena
 * @param type_ref i32
 * @param dst *u8
 * @param dst_cap i32
 * @return i32
 */
export function codegen_type_dep_enum_prefix_into(ctx: *PipelineDepCtx, arena: *ASTArena, type_ref: i32, dst: *u8, dst_cap: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let name_len: i32 = 0;
    let ty_nm: u8[256] = [];
    let di: i32 = 0;
    if (ctx == 0 as *PipelineDepCtx || arena == 0 as *ASTArena || dst == 0 as *u8 || dst_cap <= 0 || ast.ref_is_null(type_ref)) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, type_ref) != (TypeKind.TYPE_NAMED as i32)) {
      return 0;
    }
    name_len = pipeline_type_named_name_into(arena, type_ref, &ty_nm[0]);
    if (name_len <= 0) {
      return 0;
    }
    let bare_off: i32 = 0;
    let bi: i32 = 0;
    while (bi < name_len && bi < 64) {
      if (ty_nm[bi] == 46) {
        bare_off = bi + 1;
      }
      bi = bi + 1;
    }
    let bare_len: i32 = name_len - bare_off;
    di = 0;
    /* Load ndep before comparing it with the index.
     * PLATFORM: WINDOWS. The compare keeps the index in rbx and pushes it
     * in the Win64 home slot. pipeline_dep_ctx_ndep spills rcx (the dep
     * context) over that push, so the reloaded index is the context
     * pointer. A negative low half stays signed-less than the count, and
     * the walk never ends. Measured on compile.x -E. */
    let ndep_di: i32 = pipeline_dep_ctx_ndep(ctx);
    while (di < ndep_di) {
      let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, di);
      if (dep_mod != 0 as *Module) {
        let ei: i32 = 0;
        while (ei < dep_mod.num_module_enums) {
          let dep_name_len: i32 = pipeline_module_enum_name_len(dep_mod, ei);
          if (dep_name_len == bare_len) {
            let eq: bool = true;
            let j: i32 = 0;
            while (j < bare_len && j < 64) {
              /* Same rbx reuse as codegen_type_is_module_user_enum.
               * PLATFORM: WINDOWS. The index of the type-name byte must not
               * share a register with the enum byte just returned. */
              let enum_b: i32 = pipeline_module_enum_name_byte_at(dep_mod, ei, j) as i32;
              let name_at: i32 = bare_off + j;
              let name_b: i32 = ty_nm[name_at] as i32;
              if (enum_b != name_b) {
                eq = false;
                break;
              }
              j = j + 1;
            }
            if (eq) {
              let dep_path: u8[256] = [];
              let plen: i32 = codegen_dep_import_path_len_at(ctx, di, &dep_path[0]);
              if (plen > 0) {
                codegen_import_path_to_c_prefix_into(&dep_path[0], dst, dst_cap);
                let out_len: i32 = 0;
                while (out_len < dst_cap && dst[out_len] != 0 as u8) {
                  out_len = out_len + 1;
                }
                return out_len;
              }
            }
          }
          ei = ei + 1;
        }
      }
      di = di + 1;
    }
    return 0;
  }
}

/**
 * wave480 Cap residual pure: is type_ref host-C concrete (not a free type param)?
 *
 * Builtins / PTR / ARRAY / SLICE / … emit as complete C types. TYPE_NAMED is concrete
 * only when the name matches a module struct layout (user type A/B). TYPE_NAMED that
 * does not match any layout is a free type param (T/U) — emitting `struct ast_T` is
 * incomplete (BLD001).
 *
 * Used by codegen_resolve_generic_struct_field_type so mono substitution prefers
 * Pair&lt;A,B&gt; / Wrap&lt;A&gt; over generic function return Wrap&lt;T&gt; (first-match
 * used to stamp T and leave incomplete fields).
 *
 * @param module *Module — layouts for concrete named types
 * @param arena *ASTArena
 * @param ty i32 — type_ref to classify
 * @return i32 — 1 concrete, 0 free type-param / invalid
 * PLATFORM: SHARED host-C mono for generic struct fields.
 */
/**
 * wave480/485: host-complete type for generic-struct mono.
 * wave485: generic layouts require every type-arg host-concrete (recursive);
 * bare Wrap / Wrap&lt;T&gt; free param is NOT concrete (prevents incomplete Wrap__Wrap_T).
 * @param module *Module
 * @param arena *ASTArena
 * @param ty i32 — type_ref
 * @return i32 — 1 concrete, 0 free / incomplete generic
 * PLATFORM: SHARED host-C — G.7 twin of seed
 */
export function codegen_type_ref_is_host_concrete(module: *Module, arena: *ASTArena, ty: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (module == 0 as *Module || arena == 0 as *ASTArena || ty <= 0) {
      return 0;
    }
    let k: i32 = pipeline_type_kind_ord_at(arena, ty);
    // TYPE_NAMED ord = 8 (ast TypeKind). Non-named kinds are host-complete for fields.
    if (k != (TypeKind.TYPE_NAMED as i32)) {
      return 1;
    }
    let nm: u8[256] = [];
    let nl: i32 = pipeline_type_named_name_into(arena, ty, &nm[0]);
    if (nl <= 0) {
      return 0;
    }
    let sk: i32 = 0;
    while (sk < module.num_struct_layouts) {
      let sl: i32 = pipeline_module_struct_layout_name_len(module, sk);
      if (sl == nl) {
        let snm: u8[256] = [];
        pipeline_module_struct_layout_name_into(module, sk, &snm[0]);
        let bi: i32 = 0;
        /* name_eq: not `match` — `match` is a reserved keyword (match expr). */
        let name_eq: i32 = 1;
        while (bi < nl) {
          if (snm[bi] != nm[bi]) {
            name_eq = 0;
          }
          bi = bi + 1;
        }
        if (name_eq != 0) {
          let ntp: i32 = pipeline_module_struct_layout_num_type_params_at(module, sk);
          if (ntp <= 0) {
            return 1;
          }
          // Generic layout: every type-pos arg must be host-concrete.
          let ai: i32 = 0;
          while (ai < ntp && ai < 4) {
            let arg: i32 = pipeline_type_type_arg_ref_at(arena, ty, ai);
            if (arg <= 0 && ai == 0) {
              arg = pipeline_type_elem_ref_at(arena, ty);
            }
            if (arg <= 0) {
              return 0;
            }
            if (codegen_type_ref_is_host_concrete(module, arena, arg) == 0) {
              return 0;
            }
            ai = ai + 1;
          }
          return 1;
        }
      }
      sk = sk + 1;
    }
    return 0;
  }
}

/**
 * wave466/467 Cap residual pure: host-C mono for type-param fields on generic structs.
 * wave480: prefer concrete type-args (skip free T/U from generic fn return types).
 *
 * Layout may store `v: T` / `b: U` (TYPE_NAMED type-params). Emitting as `struct ast_T`
 * is incomplete (BLD001). Resolve a concrete type:
 *   1) TYPE_NAMED uses of the layout with type-pos args (`Pair<A,B>`): map field type
 *      name to layout type-param slot (wave467 multi sidecar), else slot0 (wave466);
 *      **skip** mono that is itself a free type param (wave480)
 *   2) STRUCT_LIT field init resolved type for matching field name (bare Name);
 *      same concrete filter (wave480)
 * PLATFORM: SHARED host-C.
 *
 * @param module *Module
 * @param arena *ASTArena
 * @param layout_nm *u8 — struct layout name
 * @param layout_nl i32
 * @param field_nm *u8 — field name
 * @param field_nl i32
 * @param ftr i32 — layout field type_ref
 * @return i32 — concrete type_ref to emit, or ftr if no mono found
 */
export function codegen_resolve_generic_struct_field_type(module: *Module, arena: *ASTArena, layout_nm: *u8, layout_nl: i32, field_nm: *u8, field_nl: i32, ftr: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (module == 0 as *Module || arena == 0 as *ASTArena || ftr <= 0) {
      return ftr;
    }
    if (layout_nm == 0 as *u8 || layout_nl <= 0 || field_nm == 0 as *u8 || field_nl <= 0) {
      return ftr;
    }
    // Only substitute unconstrained TYPE_NAMED (type params). Module concrete stays.
    if (pipeline_type_kind_ord_at(arena, ftr) != (TypeKind.TYPE_NAMED as i32)) {
      return ftr;
    }
    let ftn: u8[256] = [];
    let ftnl: i32 = pipeline_type_named_name_into(arena, ftr, &ftn[0]);
    if (ftnl <= 0) {
      return ftr;
    }
    // If field type name matches a real layout, it is concrete — keep.
    let sk: i32 = 0;
    while (sk < module.num_struct_layouts) {
      let sl: i32 = pipeline_module_struct_layout_name_len(module, sk);
      if (sl == ftnl) {
        let snm: u8[256] = [];
        pipeline_module_struct_layout_name_into(module, sk, &snm[0]);
        let bi: i32 = 0;
        /* name_eq: not `match` — `match` is a reserved keyword (match expr). */
        let name_eq: i32 = 1;
        while (bi < ftnl) {
          if (snm[bi] != ftn[bi]) {
            name_eq = 0;
          }
          bi = bi + 1;
        }
        if (name_eq != 0) {
          return ftr;
        }
      }
      sk = sk + 1;
    }
    // Map field type name T/U → type-param slot on layout Pair.
    let tp_slot: i32 = 0;
    sk = 0;
    while (sk < module.num_struct_layouts) {
      let sl2: i32 = pipeline_module_struct_layout_name_len(module, sk);
      if (sl2 == layout_nl && layout_nl > 0) {
        let snm2: u8[256] = [];
        pipeline_module_struct_layout_name_into(module, sk, &snm2[0]);
        let eq2: i32 = 1;
        let bi2: i32 = 0;
        while (bi2 < layout_nl) {
          if (snm2[bi2] != layout_nm[bi2]) {
            eq2 = 0;
          }
          bi2 = bi2 + 1;
        }
        if (eq2 != 0) {
          let ntp: i32 = pipeline_module_struct_layout_num_type_params_at(module, sk);
          if (ntp > 0) {
            tp_slot = -1;
            let tj: i32 = 0;
            while (tj < ntp) {
              let tpl: i32 = pipeline_module_struct_layout_type_param_name_len(module, sk, tj);
              if (tpl == ftnl) {
                let tpn: u8[256] = [];
                pipeline_module_struct_layout_type_param_name_into(module, sk, tj, &tpn[0]);
                let peq: i32 = 1;
                let pi: i32 = 0;
                while (pi < ftnl) {
                  if (tpn[pi] != ftn[pi]) {
                    peq = 0;
                  }
                  pi = pi + 1;
                }
                if (peq != 0) {
                  tp_slot = tj;
                  tj = ntp;
                }
              }
              tj = tj + 1;
            }
            if (tp_slot < 0) {
              return ftr;
            }
          }
          sk = module.num_struct_layouts;
        }
      }
      sk = sk + 1;
    }
    // (1) Type-position Pair<A,B>: type-arg at tp_slot (prefer concrete; wave480).
    let ti: i32 = 1;
    while (ti <= arena.num_types) {
      if (pipeline_type_kind_ord_at(arena, ti) == (TypeKind.TYPE_NAMED as i32)) {
        let tnm: u8[256] = [];
        let tnl: i32 = pipeline_type_named_name_into(arena, ti, &tnm[0]);
        if (tnl == layout_nl && tnl > 0) {
          let eq: i32 = 1;
          let ci: i32 = 0;
          while (ci < tnl) {
            if (tnm[ci] != layout_nm[ci]) {
              eq = 0;
            }
            ci = ci + 1;
          }
          if (eq != 0) {
            let mono: i32 = pipeline_type_type_arg_ref_at(arena, ti, tp_slot);
            if (mono <= 0) {
              if (tp_slot == 0) {
                mono = pipeline_type_elem_ref_at(arena, ti);
              }
            }
            // wave480: skip free type params (T from Wrap<T> ret); keep scanning for A.
            if (mono > 0 && codegen_type_ref_is_host_concrete(module, arena, mono) != 0) {
              return mono;
            }
          }
        }
      }
      ti = ti + 1;
    }
    // (2) Bare Name + STRUCT_LIT field init by field name (prefer concrete; wave480).
    let ei: i32 = 1;
    while (ei <= arena.num_exprs) {
      if (pipeline_expr_kind_ord_at(arena, ei) == (ExprKind.EXPR_STRUCT_LIT as i32)) {
        let e: Expr = ast.ast_arena_expr_get(arena, ei);
        if (e.struct_lit_struct_name_len == layout_nl && layout_nl > 0) {
          let seq: i32 = 1;
          let si: i32 = 0;
          while (si < layout_nl) {
            if (e.struct_lit_struct_name[si] != layout_nm[si]) {
              seq = 0;
            }
            si = si + 1;
          }
          if (seq != 0) {
            let nf: i32 = pipeline_expr_struct_lit_num_fields(arena, ei);
            let fj: i32 = 0;
            while (fj < nf) {
              let fl: i32 = pipeline_expr_struct_lit_field_name_len(arena, ei, fj);
              if (fl == field_nl) {
                let fnb: u8[256] = [];
                pipeline_expr_struct_lit_field_name_into(arena, ei, fj, &fnb[0]);
                let feq: i32 = 1;
                let fi: i32 = 0;
                while (fi < fl) {
                  if (fnb[fi] != field_nm[fi]) {
                    feq = 0;
                  }
                  fi = fi + 1;
                }
                if (feq != 0) {
                  let iref: i32 = pipeline_expr_struct_lit_init_ref(arena, ei, fj);
                  if (iref > 0) {
                    let ity: i32 = pipeline_expr_resolved_type_ref(arena, iref);
                    if (ity > 0 && codegen_type_ref_is_host_concrete(module, arena, ity) != 0) {
                      return ity;
                    }
                  }
                }
              }
              fj = fj + 1;
            }
          }
        }
      }
      ei = ei + 1;
    }
    return ftr;
  }
}

/**
 * wave481: find module struct layout index by bare name.
 * @param module *Module
 * @param layout_nm *u8 — layout bare name
 * @param layout_nl i32
 * @return i32 — layout index, or -1
 * PLATFORM: SHARED
 */
export function codegen_module_struct_layout_index_by_name(module: *Module, layout_nm: *u8, layout_nl: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (module == 0 as *Module || layout_nm == 0 as *u8 || layout_nl <= 0) {
      return -1;
    }
    let sk: i32 = 0;
    while (sk < module.num_struct_layouts) {
      let sl: i32 = pipeline_module_struct_layout_name_len(module, sk);
      if (sl == layout_nl) {
        let snm: u8[256] = [];
        pipeline_module_struct_layout_name_into(module, sk, &snm[0]);
        let eq: i32 = 1;
        let bi: i32 = 0;
        while (bi < layout_nl) {
          if (snm[bi] != layout_nm[bi]) {
            eq = 0;
          }
          bi = bi + 1;
        }
        if (eq != 0) {
          return sk;
        }
      }
      sk = sk + 1;
    }
    return -1;
  }
}

/**
 * wave482: resolve free TYPE_NAMED (T/U) through active function mono map.
 * @param module *Module
 * @param arena *ASTArena
 * @param ctx *PipelineDepCtx — may be null
 * @param ty i32 — candidate type_ref
 * @return i32 — concrete type_ref or 0
 * PLATFORM: SHARED host-C — twin of seed
 */
function codegen_generic_struct_resolve_arg_via_ctx(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx, ty: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (module == 0 as *Module || arena == 0 as *ASTArena || ty <= 0) {
      return 0;
    }
    if (codegen_type_ref_is_host_concrete(module, arena, ty) != 0) {
      return ty;
    }
    if (ctx == 0 as *PipelineDepCtx || ctx.mono_active == 0 || ctx.mono_num_types <= 0) {
      return 0;
    }
    let mi: i32 = 0;
    while (mi < ctx.mono_num_types && mi < 8) {
      let gen: i32 = ctx.mono_generic_type_refs[mi];
      let conc: i32 = ctx.mono_concrete_type_refs[mi];
      if (gen > 0 && conc > 0 && conc != ty && ty == gen) {
        if (codegen_type_ref_is_host_concrete(module, arena, conc) != 0) {
          return conc;
        }
      }
      mi = mi + 1;
    }
    let fb_nm: u8[256] = [];
    let fb_len: i32 = pipeline_type_named_name_into(arena, ty, &fb_nm[0]);
    if (fb_len <= 0) {
      return 0;
    }
    mi = 0;
    while (mi < ctx.mono_num_types && mi < 8) {
      let gen2: i32 = ctx.mono_generic_type_refs[mi];
      let conc2: i32 = ctx.mono_concrete_type_refs[mi];
      if (gen2 > 0 && conc2 > 0 && conc2 != ty) {
        let gnm: u8[256] = [];
        let gnl: i32 = pipeline_type_named_name_into(arena, gen2, &gnm[0]);
        if (gnl == fb_len && gnl > 0) {
          let eq: i32 = 1;
          let bi: i32 = 0;
          while (bi < gnl) {
            if (gnm[bi] != fb_nm[bi]) {
              eq = 0;
            }
            bi = bi + 1;
          }
          if (eq != 0 && codegen_type_ref_is_host_concrete(module, arena, conc2) != 0) {
            return conc2;
          }
        }
      }
      mi = mi + 1;
    }
    return 0;
  }
}

/**
 * wave482: resolve free type via explicit mono map arrays (collect path).
 * @param module *Module
 * @param arena *ASTArena
 * @param ty i32
 * @param mono_gen *i32
 * @param mono_conc *i32
 * @param nmono i32
 * @return i32 — concrete or 0
 * PLATFORM: SHARED
 */
function codegen_generic_struct_resolve_arg_via_map(module: *Module, arena: *ASTArena, ty: i32, mono_gen: *i32, mono_conc: *i32, nmono: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (module == 0 as *Module || arena == 0 as *ASTArena || ty <= 0 || mono_gen == 0 as *i32 || mono_conc == 0 as *i32 || nmono <= 0) {
      return 0;
    }
    if (codegen_type_ref_is_host_concrete(module, arena, ty) != 0) {
      return ty;
    }
    let mi: i32 = 0;
    while (mi < nmono && mi < 8) {
      if (mono_gen[mi] > 0 && mono_conc[mi] > 0 && mono_conc[mi] != ty && ty == mono_gen[mi]) {
        if (codegen_type_ref_is_host_concrete(module, arena, mono_conc[mi]) != 0) {
          return mono_conc[mi];
        }
      }
      mi = mi + 1;
    }
    let fb_nm: u8[256] = [];
    let fb_len: i32 = pipeline_type_named_name_into(arena, ty, &fb_nm[0]);
    if (fb_len <= 0) {
      return 0;
    }
    mi = 0;
    while (mi < nmono && mi < 8) {
      if (mono_gen[mi] > 0 && mono_conc[mi] > 0 && mono_conc[mi] != ty) {
        let gnm: u8[256] = [];
        let gnl: i32 = pipeline_type_named_name_into(arena, mono_gen[mi], &gnm[0]);
        if (gnl == fb_len && gnl > 0) {
          let eq: i32 = 1;
          let bi: i32 = 0;
          while (bi < gnl) {
            if (gnm[bi] != fb_nm[bi]) {
              eq = 0;
            }
            bi = bi + 1;
          }
          if (eq != 0 && codegen_type_ref_is_host_concrete(module, arena, mono_conc[mi]) != 0) {
            return mono_conc[mi];
          }
        }
      }
      mi = mi + 1;
    }
    return 0;
  }
}

/**
 * wave481/482: fill concrete type-arg combo for TYPE_NAMED layout use (Wrap&lt;A&gt; / Pair&lt;A,B&gt;).
 * All ntp slots must resolve to host-concrete types; free T/U via mono map when ctx active.
 * @param module *Module
 * @param arena *ASTArena
 * @param type_ref i32 — TYPE_NAMED with type-pos args
 * @param ntp i32 — layout type-param count
 * @param mono_out *i32 — length ntp (max 4)
 * @param ctx *PipelineDepCtx — optional mono map (null OK)
 * @return i32 — ntp on full concrete combo, else 0
 * PLATFORM: SHARED host-C generic struct multi mono
 */
export function codegen_generic_struct_fill_concrete_args(module: *Module, arena: *ASTArena, type_ref: i32, ntp: i32, mono_out: *i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (module == 0 as *Module || arena == 0 as *ASTArena || type_ref <= 0 || mono_out == 0 as *i32) {
      return 0;
    }
    if (ntp <= 0 || ntp > 4) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, type_ref) != (TypeKind.TYPE_NAMED as i32)) {
      return 0;
    }
    let si: i32 = 0;
    while (si < ntp) {
      let mono: i32 = pipeline_type_type_arg_ref_at(arena, type_ref, si);
      if (mono <= 0 && si == 0) {
        mono = pipeline_type_elem_ref_at(arena, type_ref);
      }
      if (mono > 0 && codegen_type_ref_is_host_concrete(module, arena, mono) == 0) {
        mono = codegen_generic_struct_resolve_arg_via_ctx(module, arena, ctx, mono);
      }
      if (mono <= 0 || codegen_type_ref_is_host_concrete(module, arena, mono) == 0) {
        return 0;
      }
      mono_out[si] = mono;
      si = si + 1;
    }
    return ntp;
  }
}

/**
 * wave481 + host-C STRUCT_LIT tag unify: build mangled generic struct tag
 * `Name_suf0[_suf1…]` into out_nm (single `_`, same spelling as typeck
 * `typeck_named_inst_mangle_into` / LANG-009 `Box_i32` / `Option_i32`).
 * Prior `__` outer joiner dual-emitted `Box__i32` beside typeck `Box_i32`.
 * @param arena *ASTArena
 * @param layout_nm *u8
 * @param layout_nl i32
 * @param mono_tys *i32 — concrete combo
 * @param ntp i32
 * @param out_nm *u8 — capacity out_cap
 * @param out_cap i32
 * @return i32 — mangled length, or 0 on failure
 * PLATFORM: SHARED — G.7 one host-C mono tag authority with typeck named-inst
 */
function codegen_generic_struct_mangled_name_into(arena: *ASTArena, layout_nm: *u8, layout_nl: i32, mono_tys: *i32, ntp: i32, out_nm: *u8, out_cap: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || layout_nm == 0 as *u8 || layout_nl <= 0 || mono_tys == 0 as *i32 || out_nm == 0 as *u8) {
      return 0;
    }
    if (ntp <= 0 || out_cap <= layout_nl + 1) {
      return 0;
    }
    let o: i32 = 0;
    let bi: i32 = 0;
    while (bi < layout_nl && o < out_cap) {
      out_nm[o] = layout_nm[bi];
      o = o + 1;
      bi = bi + 1;
    }
    // Single `_` — matches typeck named-inst (`Box_i32`); try_claim then
    // dedupes phase-1 mono against phase-0 mangled layouts.
    if (o + 1 >= out_cap) {
      return 0;
    }
    out_nm[o] = 95;
    o = o + 1;
    let mi: i32 = 0;
    while (mi < ntp) {
      if (mi > 0) {
        if (o >= out_cap) {
          return 0;
        }
        out_nm[o] = 95;
        o = o + 1;
      }
      let suf: u8[256] = [];
      let sl: i32 = codegen_type_ref_to_suffix(arena, mono_tys[mi], &suf[0], 64);
      if (sl <= 0) {
        return 0;
      }
      let si: i32 = 0;
      while (si < sl) {
        if (o >= out_cap) {
          return 0;
        }
        out_nm[o] = suf[si];
        o = o + 1;
        si = si + 1;
      }
      mi = mi + 1;
    }
    return o;
  }
}

/**
 * wave484/485: build mono arg suffix bytes from a field init expression.
 * STRUCT_LIT recurses into nested field structure (ignores ambient resolved_type_ref).
 * wave485: leaf free T under mono maps via ctx (T→A) for nest&lt;T&gt; body STRUCT_LIT.
 * Other inits use codegen_type_ref_to_suffix(resolved/mono-mapped).
 * @param arena *ASTArena
 * @param module *Module
 * @param init_ref i32
 * @param buf *u8
 * @param buf_cap i32
 * @param ctx *PipelineDepCtx — may be null; mono map used when active
 * @return i32 — bytes written, or 0 on failure
 * PLATFORM: SHARED host-C — G.7 twin of seed
 */
function codegen_mono_suffix_bytes_from_init(arena: *ASTArena, module: *Module, init_ref: i32, buf: *u8, buf_cap: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || module == 0 as *Module || init_ref <= 0 || buf == 0 as *u8 || buf_cap <= 0) {
      return 0;
    }
    if (pipeline_expr_kind_ord_at(arena, init_ref) == (ExprKind.EXPR_STRUCT_LIT as i32)) {
      let e: Expr = ast.ast_arena_expr_get(arena, init_ref);
      let nl: i32 = e.struct_lit_struct_name_len;
      if (nl <= 0 || nl >= buf_cap) {
        return 0;
      }
      let pos: i32 = 0;
      let i: i32 = 0;
      while (i < nl) {
        buf[pos] = e.struct_lit_struct_name[i];
        pos = pos + 1;
        i = i + 1;
      }
      let lk: i32 = codegen_module_struct_layout_index_by_name(module, &e.struct_lit_struct_name[0], nl);
      if (lk < 0) {
        return pos;
      }
      let ntp: i32 = pipeline_module_struct_layout_num_type_params_at(module, lk);
      if (ntp <= 0) {
        return pos;
      }
      let tj: i32 = 0;
      while (tj < ntp && tj < 4) {
        let tpl: i32 = pipeline_module_struct_layout_type_param_name_len(module, lk, tj);
        let tpn: u8[256] = [];
        pipeline_module_struct_layout_type_param_name_into(module, lk, tj, &tpn[0]);
        let found: i32 = 0;
        let nf: i32 = pipeline_module_struct_layout_num_fields(module, lk);
        let fj: i32 = 0;
        while (fj < nf) {
          let ftr: i32 = pipeline_module_struct_layout_field_type_ref(module, lk, fj);
          if (pipeline_type_kind_ord_at(arena, ftr) == (TypeKind.TYPE_NAMED as i32)) {
            let ftn: u8[256] = [];
            let ftnl: i32 = pipeline_type_named_name_into(arena, ftr, &ftn[0]);
            if (ftnl == tpl && ftnl > 0) {
              let peq: i32 = 1;
              let pi: i32 = 0;
              while (pi < ftnl) {
                if (ftn[pi] != tpn[pi]) {
                  peq = 0;
                }
                pi = pi + 1;
              }
              if (peq != 0) {
                let flen: i32 = pipeline_module_struct_layout_field_name_len(module, lk, fj);
                let fnm: u8[256] = [];
                pipeline_module_struct_layout_field_name_into(module, lk, fj, &fnm[0]);
                let lit_nf: i32 = pipeline_expr_struct_lit_num_fields(arena, init_ref);
                let li: i32 = 0;
                while (li < lit_nf) {
                  let lfl: i32 = pipeline_expr_struct_lit_field_name_len(arena, init_ref, li);
                  if (lfl == flen && flen > 0) {
                    let lfn: u8[256] = [];
                    pipeline_expr_struct_lit_field_name_into(arena, init_ref, li, &lfn[0]);
                    let feq: i32 = 1;
                    let fi: i32 = 0;
                    while (fi < flen) {
                      if (lfn[fi] != fnm[fi]) {
                        feq = 0;
                      }
                      fi = fi + 1;
                    }
                    if (feq != 0) {
                      let iref: i32 = pipeline_expr_struct_lit_init_ref(arena, init_ref, li);
                      let asuf: u8[256] = [];
                      let al: i32 = codegen_mono_suffix_bytes_from_init(arena, module, iref, &asuf[0], 64, ctx);
                      // wave485: leaf may lack resolved_type under mono body; map layout T via mono.
                      if (al <= 0 && ctx != 0 as *PipelineDepCtx && ctx.mono_active != 0 && ctx.mono_num_types > 0) {
                        let mi_f: i32 = 0;
                        while (mi_f < ctx.mono_num_types && mi_f < 8) {
                          let gtr_f: i32 = ctx.mono_generic_type_refs[mi_f];
                          let ctr_f: i32 = ctx.mono_concrete_type_refs[mi_f];
                          if (gtr_f > 0 && ctr_f > 0) {
                            let gnm_f: u8[256] = [];
                            let gnl_f: i32 = pipeline_type_named_name_into(arena, gtr_f, &gnm_f[0]);
                            if (gnl_f == tpl && gnl_f > 0) {
                              let geq_f: i32 = 1;
                              let gi_f: i32 = 0;
                              while (gi_f < gnl_f) {
                                if (gnm_f[gi_f] != tpn[gi_f]) {
                                  geq_f = 0;
                                }
                                gi_f = gi_f + 1;
                              }
                              if (geq_f != 0 && codegen_type_ref_is_host_concrete(module, arena, ctr_f) != 0) {
                                al = codegen_type_ref_to_suffix(arena, ctr_f, &asuf[0], 64);
                                mi_f = ctx.mono_num_types;
                              }
                            }
                          }
                          mi_f = mi_f + 1;
                        }
                      }
                      if (al <= 0 || pos + 1 + al >= buf_cap) {
                        return 0;
                      }
                      buf[pos] = 95;
                      pos = pos + 1;
                      let aj: i32 = 0;
                      while (aj < al) {
                        buf[pos] = asuf[aj];
                        pos = pos + 1;
                        aj = aj + 1;
                      }
                      found = 1;
                      li = lit_nf;
                      fj = nf;
                    }
                  }
                  li = li + 1;
                }
              }
            }
          }
          fj = fj + 1;
        }
        if (found == 0) {
          return 0;
        }
        tj = tj + 1;
      }
      return pos;
    }
    let rty: i32 = pipeline_expr_resolved_type_ref(arena, init_ref);
    if (rty <= 0) {
      // wave485: unstamped INT lit as type-arg slot (Pair { …, b: 1 }) → i32.
      if (pipeline_expr_kind_ord_at(arena, init_ref) == (ExprKind.EXPR_LIT as i32) && buf_cap > 3) {
        buf[0] = 105;
        buf[1] = 51;
        buf[2] = 50;
        return 3;
      }
      return 0;
    }
    // wave485: free T under mono → concrete via ctx map.
    let mapped: i32 = codegen_generic_struct_resolve_arg_via_ctx(module, arena, ctx, rty);
    if (mapped > 0) {
      rty = mapped;
    }
    return codegen_type_ref_to_suffix(arena, rty, buf, buf_cap);
  }
}

/**
 * wave484/485 + tag unify: emit STRUCT_LIT mono `_suf…` from field structure
 * (not ambient type). Single `_` matches typeck named-inst / mangled defs.
 * @param ctx *PipelineDepCtx — mono map for leaf free type params
 * @return i32 — 1 emitted, 0 not applicable, -1 fail
 * PLATFORM: SHARED host-C — G.7 one mono tag authority with typeck
 */
export function codegen_try_emit_struct_lit_mono_from_fields(module: *Module, arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, layout_nm: *u8, layout_nl: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (module == 0 as *Module || arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || expr_ref <= 0) {
      return 0;
    }
    if (layout_nm == 0 as *u8 || layout_nl <= 0) {
      return 0;
    }
    let lk: i32 = codegen_module_struct_layout_index_by_name(module, layout_nm, layout_nl);
    if (lk < 0) {
      return 0;
    }
    let ntp: i32 = pipeline_module_struct_layout_num_type_params_at(module, lk);
    if (ntp <= 0 || ntp > 4) {
      return 0;
    }
    // Probe fillable.
    let tj: i32 = 0;
    while (tj < ntp) {
      let asuf: u8[256] = [];
      let al: i32 = 0;
      let tpl: i32 = pipeline_module_struct_layout_type_param_name_len(module, lk, tj);
      let tpn: u8[256] = [];
      pipeline_module_struct_layout_type_param_name_into(module, lk, tj, &tpn[0]);
      let found: i32 = 0;
      let nf: i32 = pipeline_module_struct_layout_num_fields(module, lk);
      let fj: i32 = 0;
      while (fj < nf) {
        let ftr: i32 = pipeline_module_struct_layout_field_type_ref(module, lk, fj);
        if (pipeline_type_kind_ord_at(arena, ftr) == (TypeKind.TYPE_NAMED as i32)) {
          let ftn: u8[256] = [];
          let ftnl: i32 = pipeline_type_named_name_into(arena, ftr, &ftn[0]);
          if (ftnl == tpl && ftnl > 0) {
            let peq: i32 = 1;
            let pi: i32 = 0;
            while (pi < ftnl) {
              if (ftn[pi] != tpn[pi]) {
                peq = 0;
              }
              pi = pi + 1;
            }
            if (peq != 0) {
              let flen: i32 = pipeline_module_struct_layout_field_name_len(module, lk, fj);
              let fnm: u8[256] = [];
              pipeline_module_struct_layout_field_name_into(module, lk, fj, &fnm[0]);
              let lit_nf: i32 = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
              let li: i32 = 0;
              while (li < lit_nf) {
                let lfl: i32 = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, li);
                if (lfl == flen && flen > 0) {
                  let lfn: u8[256] = [];
                  pipeline_expr_struct_lit_field_name_into(arena, expr_ref, li, &lfn[0]);
                  let feq: i32 = 1;
                  let fi: i32 = 0;
                  while (fi < flen) {
                    if (lfn[fi] != fnm[fi]) {
                      feq = 0;
                    }
                    fi = fi + 1;
                  }
                  if (feq != 0) {
                    let iref: i32 = pipeline_expr_struct_lit_init_ref(arena, expr_ref, li);
                    al = codegen_mono_suffix_bytes_from_init(arena, module, iref, &asuf[0], 64, ctx);
                    if (al <= 0) {
                      return 0;
                    }
                    found = 1;
                    li = lit_nf;
                    fj = nf;
                  }
                }
                li = li + 1;
              }
            }
          }
        }
        fj = fj + 1;
      }
      if (found == 0) {
        return 0;
      }
      tj = tj + 1;
    }
    // Emit _suf0[_suf1…] (single `_`; was `__`)
    if (codegen_append_byte(out, 95) != 0) {
      return -1;
    }
    let first: i32 = 1;
    tj = 0;
    while (tj < ntp) {
      let tpl2: i32 = pipeline_module_struct_layout_type_param_name_len(module, lk, tj);
      let tpn2: u8[256] = [];
      pipeline_module_struct_layout_type_param_name_into(module, lk, tj, &tpn2[0]);
      let done: i32 = 0;
      let nf2: i32 = pipeline_module_struct_layout_num_fields(module, lk);
      let fj2: i32 = 0;
      while (fj2 < nf2) {
        let ftr2: i32 = pipeline_module_struct_layout_field_type_ref(module, lk, fj2);
        if (pipeline_type_kind_ord_at(arena, ftr2) == (TypeKind.TYPE_NAMED as i32)) {
          let ftn2: u8[256] = [];
          let ftnl2: i32 = pipeline_type_named_name_into(arena, ftr2, &ftn2[0]);
          if (ftnl2 == tpl2 && ftnl2 > 0) {
            let peq2: i32 = 1;
            let pi2: i32 = 0;
            while (pi2 < ftnl2) {
              if (ftn2[pi2] != tpn2[pi2]) {
                peq2 = 0;
              }
              pi2 = pi2 + 1;
            }
            if (peq2 != 0) {
              let flen2: i32 = pipeline_module_struct_layout_field_name_len(module, lk, fj2);
              let fnm2: u8[256] = [];
              pipeline_module_struct_layout_field_name_into(module, lk, fj2, &fnm2[0]);
              let lit_nf2: i32 = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
              let li2: i32 = 0;
              while (li2 < lit_nf2) {
                let lfl2: i32 = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, li2);
                if (lfl2 == flen2 && flen2 > 0) {
                  let lfn2: u8[256] = [];
                  pipeline_expr_struct_lit_field_name_into(arena, expr_ref, li2, &lfn2[0]);
                  let feq2: i32 = 1;
                  let fi2: i32 = 0;
                  while (fi2 < flen2) {
                    if (lfn2[fi2] != fnm2[fi2]) {
                      feq2 = 0;
                    }
                    fi2 = fi2 + 1;
                  }
                  if (feq2 != 0) {
                    let iref2: i32 = pipeline_expr_struct_lit_init_ref(arena, expr_ref, li2);
                    let asuf2: u8[256] = [];
                    let al2: i32 = codegen_mono_suffix_bytes_from_init(arena, module, iref2, &asuf2[0], 64, ctx);
                    if (al2 <= 0) {
                      return -1;
                    }
                    if (first == 0) {
                      if (codegen_append_byte(out, 95) != 0) {
                        return -1;
                      }
                    }
                    first = 0;
                    if (codegen_emit_bytes_from_ptr(out, &asuf2[0], al2) != 0) {
                      return -1;
                    }
                    done = 1;
                    li2 = lit_nf2;
                    fj2 = nf2;
                  }
                }
                li2 = li2 + 1;
              }
            }
          }
        }
        fj2 = fj2 + 1;
      }
      if (done == 0) {
        return -1;
      }
      tj = tj + 1;
    }
    return 1;
  }
}

/**
 * wave481 + tag unify: emit mono suffix `_suf0[_suf1…]` after a base C struct
 * tag name. Single `_` matches typeck named-inst / STRUCT_LIT (`Box_i32`).
 * @param out *CodegenOutBuf
 * @param arena *ASTArena
 * @param mono_tys *i32
 * @param ntp i32
 * @return i32 — 0 ok, -1 fail
 * PLATFORM: SHARED — G.7 one host-C mono tag authority with typeck
 */
export function codegen_emit_generic_struct_mono_suffix(out: *CodegenOutBuf, arena: *ASTArena, mono_tys: *i32, ntp: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (out == 0 as *CodegenOutBuf || arena == 0 as *ASTArena || mono_tys == 0 as *i32 || ntp <= 0) {
      return -1;
    }
    /* Single `_` joiner (was `__`); aligns codegen_emit_type + STRUCT_LIT with typeck. */
    if (codegen_append_byte(out, 95) != 0) {
      return -1;
    }
    let mi: i32 = 0;
    while (mi < ntp) {
      if (mi > 0) {
        if (codegen_append_byte(out, 95) != 0) {
          return -1;
        }
      }
      let suf: u8[256] = [];
      let sl: i32 = codegen_type_ref_to_suffix(arena, mono_tys[mi], &suf[0], 64);
      if (sl <= 0) {
        return -1;
      }
      if (codegen_emit_bytes_from_ptr(out, &suf[0], sl) != 0) {
        return -1;
      }
      mi = mi + 1;
    }
    return 0;
  }
}

/**
 * wave481: substitute a layout field type_ref using an explicit mono combo.
 * TYPE_NAMED matching type-param slot j → mono_tys[j]; else keep ftr.
 * @param module *Module
 * @param arena *ASTArena
 * @param layout_k i32 — layout index
 * @param ftr i32 — layout field type_ref
 * @param mono_tys *i32
 * @param ntp i32
 * @return i32 — concrete type_ref for host emit
 * PLATFORM: SHARED
 */
function codegen_generic_struct_field_type_from_mono(module: *Module, arena: *ASTArena, layout_k: i32, ftr: i32, mono_tys: *i32, ntp: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (module == 0 as *Module || arena == 0 as *ASTArena || ftr <= 0 || mono_tys == 0 as *i32 || ntp <= 0) {
      return ftr;
    }
    if (pipeline_type_kind_ord_at(arena, ftr) != (TypeKind.TYPE_NAMED as i32)) {
      return ftr;
    }
    let ftn: u8[256] = [];
    let ftnl: i32 = pipeline_type_named_name_into(arena, ftr, &ftn[0]);
    if (ftnl <= 0) {
      return ftr;
    }
    let tj: i32 = 0;
    while (tj < ntp) {
      let tpl: i32 = pipeline_module_struct_layout_type_param_name_len(module, layout_k, tj);
      if (tpl == ftnl) {
        let tpn: u8[256] = [];
        pipeline_module_struct_layout_type_param_name_into(module, layout_k, tj, &tpn[0]);
        let peq: i32 = 1;
        let pi: i32 = 0;
        while (pi < ftnl) {
          if (tpn[pi] != ftn[pi]) {
            peq = 0;
          }
          pi = pi + 1;
        }
        if (peq != 0 && mono_tys[tj] > 0) {
          return mono_tys[tj];
        }
      }
      tj = tj + 1;
    }
    return ftr;
  }
}

/**
 * wave484: structural equality of two type_refs for mono combo dedup.
 * Name-only equal is insufficient: Wrap&lt;A&gt; and Wrap&lt;Wrap&lt;A&gt;&gt; share name "Wrap".
 * Recurses into type-pos args via pipeline_type_type_arg_ref_at.
 * @param arena *ASTArena
 * @param a i32 — type_ref
 * @param b i32 — type_ref
 * @return i32 — 1 if same mono shape, 0 otherwise
 * PLATFORM: SHARED host-C
 */
export function codegen_type_refs_same_for_mono(arena: *ASTArena, a: i32, b: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (a == b && a > 0) {
      return 1;
    }
    if (arena == 0 as *ASTArena || a <= 0 || b <= 0) {
      return 0;
    }
    let ka: i32 = pipeline_type_kind_ord_at(arena, a);
    let kb: i32 = pipeline_type_kind_ord_at(arena, b);
    if (ka != kb) {
      return 0;
    }
    if (ka == (TypeKind.TYPE_NAMED as i32)) {
      let nma: u8[256] = [];
      let nmb: u8[256] = [];
      let nla: i32 = pipeline_type_named_name_into(arena, a, &nma[0]);
      let nlb: i32 = pipeline_type_named_name_into(arena, b, &nmb[0]);
      if (nla <= 0 || nla != nlb) {
        return 0;
      }
      let ni: i32 = 0;
      while (ni < nla) {
        if (nma[ni] != nmb[ni]) {
          return 0;
        }
        ni = ni + 1;
      }
      let ai: i32 = 0;
      while (ai < 4) {
        let aa: i32 = pipeline_type_type_arg_ref_at(arena, a, ai);
        let bb: i32 = pipeline_type_type_arg_ref_at(arena, b, ai);
        if (aa <= 0 && bb <= 0) {
          return 1;
        }
        if (aa <= 0 || bb <= 0) {
          return 0;
        }
        if (codegen_type_refs_same_for_mono(arena, aa, bb) == 0) {
          return 0;
        }
        ai = ai + 1;
      }
      return 1;
    }
    if (ka == (TypeKind.TYPE_PTR as i32)) {
      return codegen_type_refs_same_for_mono(arena, pipeline_type_elem_ref_at(arena, a), pipeline_type_elem_ref_at(arena, b));
    }
    // Non-named builtins of same kind are equal for mono keys.
    return 1;
  }
}

/**
 * wave484: nesting depth of type-pos args (0 = leaf / no args).
 * Used to emit shallower mono layouts before deeper ones (avoid incomplete field types).
 * @param arena *ASTArena
 * @param ty i32
 * @return i32 — depth
 * PLATFORM: SHARED host-C
 */
function codegen_type_ref_type_arg_nest_depth(arena: *ASTArena, ty: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || ty <= 0) {
      return 0;
    }
    let maxd: i32 = 0;
    let ai: i32 = 0;
    while (ai < 4) {
      let arg: i32 = pipeline_type_type_arg_ref_at(arena, ty, ai);
      if (arg <= 0) {
        ai = 4;
      } else {
        let d: i32 = 1 + codegen_type_ref_type_arg_nest_depth(arena, arg);
        if (d > maxd) {
          maxd = d;
        }
        ai = ai + 1;
      }
    }
    return maxd;
  }
}

/**
 * wave484: max type-arg nest depth across a mono combo (ntp slots).
 * @param arena *ASTArena
 * @param mono_tys *i32
 * @param ntp i32
 * @return i32
 * PLATFORM: SHARED
 */
function codegen_generic_struct_combo_nest_depth(arena: *ASTArena, mono_tys: *i32, ntp: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || mono_tys == 0 as *i32 || ntp <= 0) {
      return 0;
    }
    let maxd: i32 = 0;
    let i: i32 = 0;
    while (i < ntp) {
      let d: i32 = codegen_type_ref_type_arg_nest_depth(arena, mono_tys[i]);
      if (d > maxd) {
        maxd = d;
      }
      i = i + 1;
    }
    return maxd;
  }
}

/**
 * wave484: sort mono combos by nest depth ascending (in-place bubble, max 8).
 * Ensures Wrap__A is defined before Wrap__Wrap_A before Wrap__Wrap_Wrap_A.
 * @param arena *ASTArena
 * @param combos *i32 — layout combos[c * ntp + slot]
 * @param ncombo i32
 * @param ntp i32
 * @return void
 * PLATFORM: SHARED host-C
 */
export function codegen_generic_struct_sort_mono_combos_by_depth(arena: *ASTArena, combos: *i32, ncombo: i32, ntp: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || combos == 0 as *i32 || ncombo <= 1 || ntp <= 0) {
      return;
    }
    let i: i32 = 0;
    while (i < ncombo) {
      let j: i32 = i + 1;
      while (j < ncombo) {
        let di: i32 = codegen_generic_struct_combo_nest_depth(arena, &combos[i * ntp], ntp);
        let dj: i32 = codegen_generic_struct_combo_nest_depth(arena, &combos[j * ntp], ntp);
        if (dj < di) {
          let s: i32 = 0;
          while (s < ntp) {
            let tmp: i32 = combos[i * ntp + s];
            combos[i * ntp + s] = combos[j * ntp + s];
            combos[j * ntp + s] = tmp;
            s = s + 1;
          }
        }
        j = j + 1;
      }
      i = i + 1;
    }
  }
}

/**
 * wave481: collect unique concrete mono combos for a generic struct layout.
 * Sources: TYPE_NAMED type-pos uses (Wrap&lt;A&gt;) and STRUCT_LIT field-init mapping.
 * Layout: combos_out[c * ntp + slot]; max_combos cap (typically 8).
 * wave484: dedup uses structural type_arg equality (not name-only).
 * @return i32 — number of unique combos
 * PLATFORM: SHARED host-C multi mono
 */
export function codegen_collect_generic_struct_mono_combos(module: *Module, arena: *ASTArena, layout_k: i32, layout_nm: *u8, layout_nl: i32, ntp: i32, combos_out: *i32, max_combos: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (module == 0 as *Module || arena == 0 as *ASTArena || layout_nm == 0 as *u8 || combos_out == 0 as *i32) {
      return 0;
    }
    if (ntp <= 0 || ntp > 4 || max_combos <= 0 || layout_nl <= 0) {
      return 0;
    }
    let combo_count: i32 = 0;
    // (1) TYPE_NAMED uses with concrete type-pos args.
    let ti: i32 = 1;
    while (ti <= arena.num_types) {
      if (pipeline_type_kind_ord_at(arena, ti) == (TypeKind.TYPE_NAMED as i32)) {
        let tnm: u8[256] = [];
        let tnl: i32 = pipeline_type_named_name_into(arena, ti, &tnm[0]);
        if (tnl == layout_nl && tnl > 0) {
          let eq: i32 = 1;
          let ci: i32 = 0;
          while (ci < tnl) {
            if (tnm[ci] != layout_nm[ci]) {
              eq = 0;
            }
            ci = ci + 1;
          }
          if (eq != 0) {
            let combo: i32[4] = [];
            if (codegen_generic_struct_fill_concrete_args(module, arena, ti, ntp, &combo[0], 0 as *PipelineDepCtx) == ntp) {
              let found: i32 = 0;
              let c0: i32 = 0;
              while (c0 < combo_count) {
                let same: i32 = 1;
                let s0: i32 = 0;
                while (s0 < ntp) {
                  // wave484: structural mono equal (nested type-args), not name-only.
                  let ca: i32 = combos_out[c0 * ntp + s0];
                  let cb: i32 = combo[s0];
                  if (codegen_type_refs_same_for_mono(arena, ca, cb) == 0) {
                    same = 0;
                    s0 = ntp;
                  }
                  s0 = s0 + 1;
                }
                if (same != 0) {
                  found = 1;
                  c0 = combo_count;
                }
                c0 = c0 + 1;
              }
              if (found == 0 && combo_count < max_combos) {
                let s1: i32 = 0;
                while (s1 < ntp) {
                  combos_out[combo_count * ntp + s1] = combo[s1];
                  s1 = s1 + 1;
                }
                combo_count = combo_count + 1;
              }
            }
          }
        }
      }
      ti = ti + 1;
    }
    // (2) STRUCT_LIT bare Name { … }: map field type-param slots via init resolved types.
    let ei: i32 = 1;
    while (ei <= arena.num_exprs) {
      if (pipeline_expr_kind_ord_at(arena, ei) == (ExprKind.EXPR_STRUCT_LIT as i32)) {
        let e: Expr = ast.ast_arena_expr_get(arena, ei);
        if (e.struct_lit_struct_name_len == layout_nl && layout_nl > 0) {
          let seq: i32 = 1;
          let si: i32 = 0;
          while (si < layout_nl) {
            if (e.struct_lit_struct_name[si] != layout_nm[si]) {
              seq = 0;
            }
            si = si + 1;
          }
          if (seq != 0) {
            let combo2: i32[4] = [];
            let filled: i32 = 0;
            let ok: i32 = 1;
            let tj: i32 = 0;
            while (tj < ntp) {
              combo2[tj] = 0;
              tj = tj + 1;
            }
            // For each layout field whose type is type-param slot j, take init concrete.
            let nf: i32 = pipeline_module_struct_layout_num_fields(module, layout_k);
            let fj: i32 = 0;
            while (fj < nf) {
              let ftr: i32 = pipeline_module_struct_layout_field_type_ref(module, layout_k, fj);
              if (pipeline_type_kind_ord_at(arena, ftr) == (TypeKind.TYPE_NAMED as i32)) {
                let ftn: u8[256] = [];
                let ftnl: i32 = pipeline_type_named_name_into(arena, ftr, &ftn[0]);
                let slot: i32 = -1;
                let pj: i32 = 0;
                while (pj < ntp) {
                  let tpl: i32 = pipeline_module_struct_layout_type_param_name_len(module, layout_k, pj);
                  if (tpl == ftnl && ftnl > 0) {
                    let tpn: u8[256] = [];
                    pipeline_module_struct_layout_type_param_name_into(module, layout_k, pj, &tpn[0]);
                    let peq: i32 = 1;
                    let pi: i32 = 0;
                    while (pi < ftnl) {
                      if (tpn[pi] != ftn[pi]) {
                        peq = 0;
                      }
                      pi = pi + 1;
                    }
                    if (peq != 0) {
                      slot = pj;
                      pj = ntp;
                    }
                  }
                  pj = pj + 1;
                }
                if (slot >= 0) {
                  // Match STRUCT_LIT field by layout field name.
                  let flen: i32 = pipeline_module_struct_layout_field_name_len(module, layout_k, fj);
                  let fnm: u8[256] = [];
                  pipeline_module_struct_layout_field_name_into(module, layout_k, fj, &fnm[0]);
                  let lit_nf: i32 = pipeline_expr_struct_lit_num_fields(arena, ei);
                  let li: i32 = 0;
                  while (li < lit_nf) {
                    let lfl: i32 = pipeline_expr_struct_lit_field_name_len(arena, ei, li);
                    if (lfl == flen && flen > 0) {
                      let lfn: u8[256] = [];
                      pipeline_expr_struct_lit_field_name_into(arena, ei, li, &lfn[0]);
                      let feq: i32 = 1;
                      let fi: i32 = 0;
                      while (fi < flen) {
                        if (lfn[fi] != fnm[fi]) {
                          feq = 0;
                        }
                        fi = fi + 1;
                      }
                      if (feq != 0) {
                        let iref: i32 = pipeline_expr_struct_lit_init_ref(arena, ei, li);
                        if (iref > 0) {
                          let ity: i32 = pipeline_expr_resolved_type_ref(arena, iref);
                          if (ity > 0 && codegen_type_ref_is_host_concrete(module, arena, ity) != 0) {
                            if (combo2[slot] == 0) {
                              combo2[slot] = ity;
                              filled = filled + 1;
                            }
                          }
                        }
                        li = lit_nf;
                      }
                    }
                    li = li + 1;
                  }
                }
              }
              fj = fj + 1;
            }
            // All slots filled?
            let scheck: i32 = 0;
            while (scheck < ntp) {
              if (combo2[scheck] <= 0) {
                ok = 0;
              }
              scheck = scheck + 1;
            }
            if (ok != 0 && filled > 0) {
              let found2: i32 = 0;
              let c1: i32 = 0;
              while (c1 < combo_count) {
                let same2: i32 = 1;
                let s2: i32 = 0;
                while (s2 < ntp) {
                  // wave484: structural mono equal (nested type-args).
                  let ca2: i32 = combos_out[c1 * ntp + s2];
                  let cb2: i32 = combo2[s2];
                  if (codegen_type_refs_same_for_mono(arena, ca2, cb2) == 0) {
                    same2 = 0;
                    s2 = ntp;
                  }
                  s2 = s2 + 1;
                }
                if (same2 != 0) {
                  found2 = 1;
                  c1 = combo_count;
                }
                c1 = c1 + 1;
              }
              if (found2 == 0 && combo_count < max_combos) {
                let s3: i32 = 0;
                while (s3 < ntp) {
                  combos_out[combo_count * ntp + s3] = combo2[s3];
                  s3 = s3 + 1;
                }
                combo_count = combo_count + 1;
              }
            }
          }
        }
      }
      ei = ei + 1;
    }
    /*
     * wave482: harvest combos from generic function mono (bare multi mono).
     * chain `make_pair(A,B).a` lacks TYPE_NAMED Pair&lt;A,B&gt; type-pos; STRUCT_LIT
     * inits are free T/U — without this, Pair__A_B def is skipped → BLD001.
     * PLATFORM: SHARED host-C; twin of seed.
     */
    let fi_h: i32 = 0;
    while (fi_h < module.num_funcs && combo_count < max_combos) {
      if (pipeline_module_func_num_generic_params_at(module, fi_h) > 0 && pipeline_module_func_is_extern_at(module, fi_h) == 0) {
        let np_h: i32 = pipeline_module_func_num_params_at(module, fi_h);
        if (np_h >= 0 && np_h <= 8) {
          let ret_extra_h: i32 = codegen_func_ret_type_param_extra(arena, module, fi_h);
          let combo_width_h: i32 = np_h + ret_extra_h;
          if (combo_width_h > 0 && combo_width_h <= 8) {
            let combos_fn: i32[128] = [];
            let ncombo_fn: i32 = codegen_collect_mono_combos_for_generic_func(arena, module, fi_h, &combos_fn[0], 16, np_h, ret_extra_h);
            let ci_fn: i32 = 0;
            while (ci_fn < ncombo_fn && combo_count < max_combos) {
              let mono_gen: i32[8] = [];
              let mono_conc: i32[8] = [];
              let nmono: i32 = 0;
              let ret_ty_fn: i32 = pipeline_module_func_return_type_at(module, fi_h);
              let pi_h: i32 = 0;
              while (pi_h < np_h && nmono < 8) {
                mono_gen[nmono] = pipeline_module_func_param_type_ref_at(module, fi_h, pi_h);
                mono_conc[nmono] = combos_fn[ci_fn * combo_width_h + pi_h];
                nmono = nmono + 1;
                pi_h = pi_h + 1;
              }
              if (ret_extra_h != 0 && nmono < 8) {
                let ta_c: i32 = combos_fn[ci_fn * combo_width_h + np_h];
                if (ta_c > 0 && ta_c != ret_ty_fn) {
                  mono_gen[nmono] = ret_ty_fn;
                  mono_conc[nmono] = ta_c;
                  nmono = nmono + 1;
                }
              }
              let tr_i: i32 = 0;
              while (tr_i < np_h + 1) {
                let try_tr: i32 = ret_ty_fn;
                if (tr_i < np_h) {
                  try_tr = pipeline_module_func_param_type_ref_at(module, fi_h, tr_i);
                }
                if (try_tr > 0 && pipeline_type_kind_ord_at(arena, try_tr) == (TypeKind.TYPE_NAMED as i32)) {
                  let tnm_r: u8[256] = [];
                  let tnl_r: i32 = pipeline_type_named_name_into(arena, try_tr, &tnm_r[0]);
                  if (tnl_r == layout_nl && tnl_r > 0) {
                    let eq_r: i32 = 1;
                    let bi_r: i32 = 0;
                    while (bi_r < tnl_r) {
                      if (tnm_r[bi_r] != layout_nm[bi_r]) {
                        eq_r = 0;
                      }
                      bi_r = bi_r + 1;
                    }
                    if (eq_r != 0) {
                      let combo_r: i32[4] = [];
                      let filled_r: i32 = 0;
                      let ok_r: i32 = 1;
                      let si_r: i32 = 0;
                      while (si_r < ntp) {
                        let arg: i32 = pipeline_type_type_arg_ref_at(arena, try_tr, si_r);
                        if (arg <= 0 && si_r == 0) {
                          arg = pipeline_type_elem_ref_at(arena, try_tr);
                        }
                        if (arg > 0 && codegen_type_ref_is_host_concrete(module, arena, arg) == 0) {
                          arg = codegen_generic_struct_resolve_arg_via_map(module, arena, arg, &mono_gen[0], &mono_conc[0], nmono);
                        }
                        if (arg <= 0 || codegen_type_ref_is_host_concrete(module, arena, arg) == 0) {
                          ok_r = 0;
                          si_r = ntp;
                        } else {
                          combo_r[si_r] = arg;
                          filled_r = filled_r + 1;
                        }
                        si_r = si_r + 1;
                      }
                      if (ok_r == 0 || filled_r != ntp) {
                        ok_r = 1;
                        filled_r = 0;
                        si_r = 0;
                        while (si_r < ntp) {
                          let tpl_h: i32 = pipeline_module_struct_layout_type_param_name_len(module, layout_k, si_r);
                          let tpn_h: u8[256] = [];
                          pipeline_module_struct_layout_type_param_name_into(module, layout_k, si_r, &tpn_h[0]);
                          let found_slot: i32 = 0;
                          let mi_m: i32 = 0;
                          while (mi_m < nmono && mi_m < 8) {
                            if (mono_gen[mi_m] > 0 && mono_conc[mi_m] > 0) {
                              let gnm_h: u8[256] = [];
                              let gnl_h: i32 = pipeline_type_named_name_into(arena, mono_gen[mi_m], &gnm_h[0]);
                              if (gnl_h == tpl_h && gnl_h > 0) {
                                let geq_h: i32 = 1;
                                let gi_h: i32 = 0;
                                while (gi_h < gnl_h) {
                                  if (gnm_h[gi_h] != tpn_h[gi_h]) {
                                    geq_h = 0;
                                  }
                                  gi_h = gi_h + 1;
                                }
                                if (geq_h != 0 && codegen_type_ref_is_host_concrete(module, arena, mono_conc[mi_m]) != 0) {
                                  combo_r[si_r] = mono_conc[mi_m];
                                  found_slot = 1;
                                  filled_r = filled_r + 1;
                                  mi_m = nmono;
                                }
                              }
                            }
                            mi_m = mi_m + 1;
                          }
                          if (found_slot == 0) {
                            ok_r = 0;
                            si_r = ntp;
                          }
                          si_r = si_r + 1;
                        }
                      }
                      if (ok_r != 0 && filled_r == ntp) {
                        let found_r: i32 = 0;
                        let c_r: i32 = 0;
                        while (c_r < combo_count) {
                          let same_r: i32 = 1;
                          let s_r: i32 = 0;
                          while (s_r < ntp) {
                            if (codegen_type_refs_same_for_mono(arena, combos_out[c_r * ntp + s_r], combo_r[s_r]) == 0) {
                              same_r = 0;
                            }
                            s_r = s_r + 1;
                          }
                          if (same_r != 0) {
                            found_r = 1;
                            c_r = combo_count;
                          }
                          c_r = c_r + 1;
                        }
                        if (found_r == 0 && combo_count < max_combos) {
                          let s_a: i32 = 0;
                          while (s_a < ntp) {
                            combos_out[combo_count * ntp + s_a] = combo_r[s_a];
                            s_a = s_a + 1;
                          }
                          combo_count = combo_count + 1;
                        }
                      }
                    }
                  }
                }
                tr_i = tr_i + 1;
              }
              ci_fn = ci_fn + 1;
            }
          }
        }
      }
      fi_h = fi_h + 1;
    }
    return combo_count;
  }
}

/**
 * wave481/482: if type_ref resolves to a generic layout with concrete args (or mono map),
 * emit mono C tag suffix onto out. No-op (return 0) when not multi-mono applicable.
 * @param module *Module
 * @param arena *ASTArena
 * @param out *CodegenOutBuf
 * @param type_ref i32
 * @param ctx *PipelineDepCtx — optional; mono_active enables free T/U map
 * @return i32 — 0 ok (incl. no-op), -1 emit error
 * PLATFORM: SHARED
 */
export function codegen_maybe_emit_generic_struct_mono_suffix_for_type(module: *Module, arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (module == 0 as *Module || arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || type_ref <= 0) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, type_ref) != (TypeKind.TYPE_NAMED as i32)) {
      return 0;
    }
    let nm: u8[256] = [];
    let nl: i32 = pipeline_type_named_name_into(arena, type_ref, &nm[0]);
    if (nl <= 0) {
      return 0;
    }
    // bare name after last '.'
    let bare_off: i32 = 0;
    let bi: i32 = 0;
    while (bi < nl && bi < 64) {
      if (nm[bi] == 46) {
        bare_off = bi + 1;
      }
      bi = bi + 1;
    }
    let bare_len: i32 = nl - bare_off;
    if (bare_len <= 0) {
      return 0;
    }
    let lk: i32 = codegen_module_struct_layout_index_by_name(module, &nm[bare_off], bare_len);
    if (lk < 0) {
      return 0;
    }
    let ntp: i32 = pipeline_module_struct_layout_num_type_params_at(module, lk);
    if (ntp <= 0) {
      return 0;
    }
    let mono: i32[4] = [];
    if (codegen_generic_struct_fill_concrete_args(module, arena, type_ref, ntp, &mono[0], ctx) == ntp) {
      return codegen_emit_generic_struct_mono_suffix(out, arena, &mono[0], ntp);
    }
    /*
     * wave482: under mono_active, map layout type-param names through mono map
     * when type_ref still has free T/U (Pair&lt;T,U&gt; signature of mono instance).
     */
    if (ctx != 0 as *PipelineDepCtx && ctx.mono_active != 0 && ctx.mono_num_types > 0 && ntp <= 4) {
      let tj: i32 = 0;
      let ok: i32 = 1;
      while (tj < ntp) {
        let tpl: i32 = pipeline_module_struct_layout_type_param_name_len(module, lk, tj);
        let tpn: u8[256] = [];
        pipeline_module_struct_layout_type_param_name_into(module, lk, tj, &tpn[0]);
        mono[tj] = 0;
        let found: i32 = 0;
        let mi_m: i32 = 0;
        while (mi_m < ctx.mono_num_types && mi_m < 8) {
          let gtr: i32 = ctx.mono_generic_type_refs[mi_m];
          let ctr: i32 = ctx.mono_concrete_type_refs[mi_m];
          if (gtr > 0 && ctr > 0) {
            let gnm: u8[256] = [];
            let gnl: i32 = pipeline_type_named_name_into(arena, gtr, &gnm[0]);
            if (gnl == tpl && gnl > 0) {
              let geq: i32 = 1;
              let gi: i32 = 0;
              while (gi < gnl) {
                if (gnm[gi] != tpn[gi]) {
                  geq = 0;
                }
                gi = gi + 1;
              }
              if (geq != 0 && codegen_type_ref_is_host_concrete(module, arena, ctr) != 0) {
                mono[tj] = ctr;
                found = 1;
                mi_m = ctx.mono_num_types;
              }
            }
          }
          mi_m = mi_m + 1;
        }
        if (found == 0) {
          ok = 0;
          tj = ntp;
        }
        tj = tj + 1;
      }
      if (ok != 0) {
        return codegen_emit_generic_struct_mono_suffix(out, arena, &mono[0], ntp);
      }
    }
    /*
     * wave489 Cap residual: generic-impl method self `Box&lt;T&gt;` / free type-args on a
     * layout that has exactly one host-concrete mono combo in the module (e.g. only
     * `Box&lt;i32&gt;` uses). fill_concrete fails on free T; mono_active map is off when
     * emitting the free function signature (impl methods hoist as free fns, not under
     * generic-function mono). Reuse collect authority: if unique combo, append that
     * suffix so host-C matches monomorphized receivers (`struct Box_i32`) instead of
     * incomplete bare `struct Box` BLD001.
     * Multi-combo `impl for Box<T>` with Box<A>+Box<B>: wave498 fixed via per-combo
     * mangled methods emitted by codegen_try_emit_generic_impl_method_mono + call-side
     * codegen_try_emit_impl_method_mono_call_name (5 call paths: UFCS / dep / C6 /
     * re-search / PTR overload). No longer soft.
     * PLATFORM: SHARED host-C.
     */
    if (ntp <= 4) {
      let combos: i32[32] = [];
      let nc: i32 = codegen_collect_generic_struct_mono_combos(module, arena, lk, &nm[bare_off], bare_len, ntp, &combos[0], 8);
      if (nc == 1) {
        return codegen_emit_generic_struct_mono_suffix(out, arena, &combos[0], ntp);
      }
      if (nc > 1) {
        let match_combo: i32[4] = [];
        let mi: i32 = 0;
        while (mi < nc) {
          let matched: i32 = 1;
          let si: i32 = 0;
          while (si < ntp) {
            let arg_ref: i32 = pipeline_type_type_arg_ref_at(arena, type_ref, si);
            if (arg_ref <= 0) {
              matched = 0;
              si = ntp;
            } else if (codegen_type_refs_same_for_mono(arena, arg_ref, combos[mi * ntp + si]) == 0) {
              matched = 0;
              si = ntp;
            }
            si = si + 1;
          }
          if (matched != 0) {
            let sj: i32 = 0;
            while (sj < ntp) {
              match_combo[sj] = combos[mi * ntp + sj];
              sj = sj + 1;
            }
            return codegen_emit_generic_struct_mono_suffix(out, arena, &match_combo[0], ntp);
          }
          mi = mi + 1;
        }
      }
    }
    return 0;
  }
}

/**
 * wave495: build a type-param-name → concrete type_ref mono map for a function's
 * params, derived from each generic-struct param's unique mono combo.
 *
 * Why: hoisted generic inherent impl methods (`impl Wrap<T> { function get(self: Wrap<T>): T }`)
 * have num_generic_params == 0 (the <T> is on the impl, not the fn), so they bypass
 * codegen_try_emit_generic_identity_mono and are emitted by emit_func. Without mono_active,
 * the return type T emits as `struct T` (incomplete BLD001) while the self param Wrap<T>
 * is rescued by the wave489 unique-combo suffix mechanism. This helper derives the
 * T→concrete mapping from the self param's unique combo so emit_func can set mono_active
 * and let codegen_emit_type's name-based fallback (L4033-L4060) substitute T in ret type + body.
 *
 * Guards (only handle the unique-combo case; multi-combo stays soft per wave490):
 *   - skip param if fill_concrete_args succeeds (param already concrete)
 *   - skip param if collect_combos returns nc != 1
 *   - skip type-arg slot if pipeline_type_type_arg_ref_at returns <= 0 (bare struct)
 *   - dedup by formal_arg type_ref (don't double-map same T from two params)
 *
 * @param module *Module
 * @param arena *ASTArena
 * @param fi i32 — function index
 * @param gen_refs *i32 — out: formal type-arg type_refs (cap max_entries)
 * @param conc_refs *i32 — out: concrete combo type_refs (cap max_entries)
 * @param max_entries i32 — typically 8 (matches PipelineDepCtx.mono_*_type_refs[8])
 * @return i32 — number of map entries (0..max_entries), or 0 on no-map / error
 * PLATFORM: SHARED — mirrors seed codegen_gen.linux.x86_64.c same commit.
 */
function codegen_build_func_param_mono_map(module: *Module, arena: *ASTArena, fi: i32, gen_refs: *i32, conc_refs: *i32, max_entries: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (module == 0 as *Module || arena == 0 as *ASTArena || gen_refs == 0 as *i32 || conc_refs == 0 as *i32 || max_entries <= 0) {
      return 0;
    }
    if (fi < 0 || fi >= module.num_funcs) {
      return 0;
    }
    let map_count: i32 = 0;
    let num_params: i32 = pipeline_module_func_num_params_at(module, fi);
    let p: i32 = 0;
    while (p < num_params) {
      let pty_raw: i32 = pipeline_module_func_param_type_ref_at(module, fi, p);
      if (pty_raw <= 0) {
        p = p + 1;
        continue;
      }
      /* Peel aliases (Cap residual wave376) to reach TYPE_NAMED. */
      let pty: i32 = pipeline_typeck_resolve_type_alias_ref_c(arena, pty_raw);
      if (pty <= 0) {
        p = p + 1;
        continue;
      }
      if (pipeline_type_kind_ord_at(arena, pty) != (TypeKind.TYPE_NAMED as i32)) {
        p = p + 1;
        continue;
      }
      let nm: u8[256] = [];
      let nl: i32 = pipeline_type_named_name_into(arena, pty, &nm[0]);
      if (nl <= 0) {
        p = p + 1;
        continue;
      }
      /* bare name after last '.' */
      let bare_off: i32 = 0;
      let bi: i32 = 0;
      while (bi < nl && bi < 64) {
        if (nm[bi] == 46) {
          bare_off = bi + 1;
        }
        bi = bi + 1;
      }
      let bare_len: i32 = nl - bare_off;
      if (bare_len <= 0) {
        p = p + 1;
        continue;
      }
      let lk: i32 = codegen_module_struct_layout_index_by_name(module, &nm[bare_off], bare_len);
      if (lk < 0) {
        p = p + 1;
        continue;
      }
      let ntp: i32 = pipeline_module_struct_layout_num_type_params_at(module, lk);
      if (ntp <= 0) {
        p = p + 1;
        continue;
      }
      /* Skip if param is already concrete (e.g. Wrap<i32>); fill_concrete succeeds. */
      let mono_chk: i32[4] = [];
      if (codegen_generic_struct_fill_concrete_args(module, arena, pty, ntp, &mono_chk[0], 0 as *PipelineDepCtx) == ntp) {
        p = p + 1;
        continue;
      }
      /* Has free type-args — collect combos. Only handle unique combo (wave489). */
      let combos: i32[32] = [];
      let nc: i32 = codegen_collect_generic_struct_mono_combos(module, arena, lk, &nm[bare_off], bare_len, ntp, &combos[0], 8);
      if (nc != 1) {
        p = p + 1;
        continue;
      }
      /* Map each formal type-arg → combo concrete. */
      let tj: i32 = 0;
      while (tj < ntp) {
        let formal_arg: i32 = pipeline_type_type_arg_ref_at(arena, pty, tj);
        let concrete_arg: i32 = combos[tj];
        if (formal_arg > 0 && concrete_arg > 0 && map_count < max_entries) {
          /* Dedup by formal_arg type_ref. */
          let dup: i32 = 0;
          let dk: i32 = 0;
          while (dk < map_count) {
            if (gen_refs[dk] == formal_arg) {
              dup = 1;
              dk = map_count;
            }
            dk = dk + 1;
          }
          if (dup == 0) {
            gen_refs[map_count] = formal_arg;
            conc_refs[map_count] = concrete_arg;
            map_count = map_count + 1;
          }
        }
        tj = tj + 1;
      }
      p = p + 1;
    }
    return map_count;
  }
}

/**
 * Host-C: emit one struct field declarator (`<type> <name>` or TYPE_FN form).
 *
 * Fixed arrays peel to scalar/base then append `[N]` dims (same as locals).
 * TYPE_FN (10.3.1 slice10): `Ret (*field)(args)` via codegen_emit_c_fnptr_decl —
 * abstract `Ret (*)(args) field` is invalid C.
 * `[N]function(...)` (slice11): `Ret (*field[N])(args)` via array_ty dims.
 *
 * @param arena *ASTArena — type pool
 * @param out *CodegenOutBuf — C text sink
 * @param type_ref i32 — field type (may be TYPE_ARRAY nest)
 * @param field_name *u8 — field identifier bytes
 * @param field_name_len i32 — name length; must be > 0
 * @param struct_prefix *u8 — optional named-struct tag prefix
 * @param struct_prefix_len i32 — prefix length
 * @param ctx *PipelineDepCtx — nested emit
 * @return i32 — 0 success, -1 failure
 * PLATFORM: SHARED host-C. G.7 single struct-field declarator path.
 */
export function codegen_emit_struct_field_decl_x(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, field_name: *u8, field_name_len: i32, struct_prefix: *u8, struct_prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let base_ref: i32 = type_ref;
    let array_ty: i32 = 0;
    if (ast.ref_is_null(type_ref) || field_name == 0 as *u8 || field_name_len <= 0) {
      return -1;
    }
    /*
     * 10.3.1 slice10/11: bare TYPE_FN → Ret (*name)(args); ARRAY of TYPE_FN →
     * Ret (*name[N]…)(args). Peel first so one G.7 codegen_emit_c_fnptr_decl path.
     * PLATFORM: SHARED host-C.
     */
    while (!ast.ref_is_null(base_ref) && pipeline_type_kind_ord_at(arena, base_ref) == (TypeKind.TYPE_ARRAY as i32)) {
      let inner: i32 = pipeline_type_elem_ref_at(arena, base_ref);
      if (ast.ref_is_null(inner)) {
        break;
      }
      base_ref = inner;
    }
    if (pipeline_type_kind_ord_at(arena, base_ref) == (TypeKind.TYPE_FN as i32)) {
      if (pipeline_type_kind_ord_at(arena, type_ref) == (TypeKind.TYPE_ARRAY as i32)) {
        array_ty = type_ref;
      }
      return codegen_emit_c_fnptr_decl(arena, out, base_ref, field_name, field_name_len, array_ty, ctx);
    }
    /* Reset peel for non-FN arrays (scalar/struct leaf + trailing dims). */
    base_ref = type_ref;
    while (!ast.ref_is_null(base_ref) && pipeline_type_kind_ord_at(arena, base_ref) == (TypeKind.TYPE_ARRAY as i32)) {
      let inner2: i32 = pipeline_type_elem_ref_at(arena, base_ref);
      if (ast.ref_is_null(inner2)) {
        break;
      }
      base_ref = inner2;
    }
    if (codegen_emit_type(arena, out, base_ref, struct_prefix, struct_prefix_len, ctx) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 32) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, field_name, field_name_len) != 0) {
      return -1;
    }
    let dims_ref: i32 = type_ref;
    while (!ast.ref_is_null(dims_ref) && pipeline_type_kind_ord_at(arena, dims_ref) == (TypeKind.TYPE_ARRAY as i32)) {
      let lbr: u8[2] = [91, 0];
      let rbr: u8[2] = [93, 0];
      if (codegen_emit_bytes_2(out, &lbr[0], 1) != 0) {
        return -1;
      }
      if (format_int(out, pipeline_type_array_size_at(arena, dims_ref)) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_2(out, &rbr[0], 1) != 0) {
        return -1;
      }
      dims_ref = pipeline_type_elem_ref_at(arena, dims_ref);
    }
    return 0;
  }
}


/**
 * Repeat the C tag prefix `xlang_slice_` `n` times.
 * Builds nested fat tags: nest=3 → xlang_slice_xlang_slice_xlang_slice_.
 * @param out *CodegenOutBuf — C text buffer; null rejected
 * @param n i32 — repeat count; n<=0 is a successful no-op
 * @return i32 — 0 on success, -1 on emit failure
 * PLATFORM: SHARED host-C fat-slice tag. G.7 single prefix emitter.
 */
function codegen_emit_xlang_slice_prefix_rep(out: *CodegenOutBuf, n: i32): i32 {
  if (out == 0 as *CodegenOutBuf) {
    return -1;
  }
  if (n <= 0) {
    return 0;
  }
  let pfx: u8[16] = [
    120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0, 0, 0, 0
  ];
  let i: i32 = 0;
  while (i < n) {
    if (codegen_emit_bytes_from_ptr(out, &pfx[0], 12) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Emit one host-C fat-slice layout at nest depth `nest`.
 * nest==1 and leaf_is_struct==0:
 *   struct xlang_slice_<elem> { <elem> *data; size_t length; };
 * nest==1 and leaf_is_struct==1:
 *   struct xlang_slice_<pfx><elem> { struct <pfx><elem> *data; size_t length; };
 * nest>=2:
 *   struct xlang_slice_×nest_<pfx><elem> {
 *     struct xlang_slice_×(nest-1)_<pfx><elem> *data; size_t length; };
 * Hard cap nest<=64 (4.2.3 1..16 + nest>16 soft 17..52 + nest>52 jump
 * 53..64). Product freeze at 64 (named stop; not one-nest-per-leaf).
 * Piecewise emit — no u8[256] whole-line buffer. type_to_c_repr scratch is
 * 896; nest 52 i32 tag is 638; nest 53 is 650 (overflows 640);
 * nest 63 is 770 (overflows 768); nest 64 is 782 (12*64+14). Family
 * skipped 768 because 64 does not fit. Do not raise to 65 this leaf.
 * @param out *CodegenOutBuf — C text buffer; null rejected
 * @param nest i32 — slice nest depth; must be 1..64
 * @param pfx *u8 — optional struct-tag prefix; null or pfx_len<=0 means none
 * @param pfx_len i32 — prefix byte count
 * @param elem *u8 — leaf C type name (int32_t) or named tag (Cell)
 * @param elem_len i32 — elem byte count; must be > 0
 * @param leaf_is_struct i32 — 1 → nest-1 pointee is `struct <pfx><elem>`; 0 → raw `<elem>`
 * @return i32 — 0 on success, -1 on emit failure
 * PLATFORM: SHARED host-C. G.7: one emitter for scalar table + named companion.
 */
function codegen_emit_slice_fat_one(out: *CodegenOutBuf, nest: i32, pfx: *u8, pfx_len: i32, elem: *u8, elem_len: i32, leaf_is_struct: i32): i32 {
  if (out == 0 as *CodegenOutBuf || elem == 0 as *u8 || elem_len <= 0) {
    return -1;
  }
  if (nest < 1) {
    return -1;
  }
  if (nest > 64) {
    return -1;
  }
  /* "struct " */
  let hs: u8[8] = [115, 116, 114, 117, 99, 116, 32, 0];
  if (codegen_emit_bytes_from_ptr(out, &hs[0], 7) != 0) {
    return -1;
  }
  if (codegen_emit_xlang_slice_prefix_rep(out, nest) != 0) {
    return -1;
  }
  if (pfx != 0 as *u8 && pfx_len > 0) {
    if (codegen_emit_bytes_from_ptr(out, pfx, pfx_len) != 0) {
      return -1;
    }
  }
  if (codegen_emit_bytes_from_ptr(out, elem, elem_len) != 0) {
    return -1;
  }
  /* " { " */
  let mid0: u8[4] = [32, 123, 32, 0];
  if (codegen_emit_bytes_from_ptr(out, &mid0[0], 3) != 0) {
    return -1;
  }
  if (nest == 1 && leaf_is_struct == 0) {
    if (codegen_emit_bytes_from_ptr(out, elem, elem_len) != 0) {
      return -1;
    }
  } else {
    if (codegen_emit_bytes_from_ptr(out, &hs[0], 7) != 0) {
      return -1;
    }
    if (nest == 1) {
      if (pfx != 0 as *u8 && pfx_len > 0) {
        if (codegen_emit_bytes_from_ptr(out, pfx, pfx_len) != 0) {
          return -1;
        }
      }
      if (codegen_emit_bytes_from_ptr(out, elem, elem_len) != 0) {
        return -1;
      }
    } else {
      if (codegen_emit_xlang_slice_prefix_rep(out, nest - 1) != 0) {
        return -1;
      }
      if (pfx != 0 as *u8 && pfx_len > 0) {
        if (codegen_emit_bytes_from_ptr(out, pfx, pfx_len) != 0) {
          return -1;
        }
      }
      if (codegen_emit_bytes_from_ptr(out, elem, elem_len) != 0) {
        return -1;
      }
    }
  }
  /* " *data; size_t length; };\n" */
  let tail: u8[28] = [
    32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108,
    101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0
  ];
  if (codegen_emit_bytes_from_ptr(out, &tail[0], 26) != 0) {
    return -1;
  }
  return 0;
}

/**
 * Emit host-C scalar fat-slice layouts for every nest in [min_nest, max_nest].
 * Elem set matches wave619 / rt_preamble: uint8_t int8_t int16_t uint16_t
 * int int32_t uint32_t int64_t uint64_t size_t ssize_t float double.
 * @param out *CodegenOutBuf — C text buffer; null rejected
 * @param min_nest i32 — inclusive start; must be 1..64
 * @param max_nest i32 — inclusive end; must be min_nest..64
 * @return i32 — 0 on success, -1 on emit failure
 * PLATFORM: SHARED host-C. G.7: same elem set as rt_preamble 1..8.
 */
function codegen_emit_scalar_slice_nests(out: *CodegenOutBuf, min_nest: i32, max_nest: i32): i32 {
  if (out == 0 as *CodegenOutBuf) {
    return -1;
  }
  if (min_nest < 1 || max_nest > 64 || min_nest > max_nest) {
    return -1;
  }
  let e0: u8[16] = [117, 105, 110, 116, 56, 95, 116, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let e1: u8[16] = [105, 110, 116, 56, 95, 116, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let e2: u8[16] = [105, 110, 116, 49, 54, 95, 116, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let e3: u8[16] = [117, 105, 110, 116, 49, 54, 95, 116, 0, 0, 0, 0, 0, 0, 0, 0];
  let e4: u8[16] = [105, 110, 116, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let e5: u8[16] = [105, 110, 116, 51, 50, 95, 116, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let e6: u8[16] = [117, 105, 110, 116, 51, 50, 95, 116, 0, 0, 0, 0, 0, 0, 0, 0];
  let e7: u8[16] = [105, 110, 116, 54, 52, 95, 116, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let e8: u8[16] = [117, 105, 110, 116, 54, 52, 95, 116, 0, 0, 0, 0, 0, 0, 0, 0];
  let e9: u8[16] = [115, 105, 122, 101, 95, 116, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let e10: u8[16] = [115, 115, 105, 122, 101, 95, 116, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let e11: u8[16] = [102, 108, 111, 97, 116, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let e12: u8[16] = [100, 111, 117, 98, 108, 101, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let nest: i32 = min_nest;
  while (nest <= max_nest) {
    if (codegen_emit_slice_fat_one(out, nest, 0 as *u8, 0, &e0[0], 7, 0) != 0) {
      return -1;
    }
    if (codegen_emit_slice_fat_one(out, nest, 0 as *u8, 0, &e1[0], 6, 0) != 0) {
      return -1;
    }
    if (codegen_emit_slice_fat_one(out, nest, 0 as *u8, 0, &e2[0], 7, 0) != 0) {
      return -1;
    }
    if (codegen_emit_slice_fat_one(out, nest, 0 as *u8, 0, &e3[0], 8, 0) != 0) {
      return -1;
    }
    if (codegen_emit_slice_fat_one(out, nest, 0 as *u8, 0, &e4[0], 3, 0) != 0) {
      return -1;
    }
    if (codegen_emit_slice_fat_one(out, nest, 0 as *u8, 0, &e5[0], 7, 0) != 0) {
      return -1;
    }
    if (codegen_emit_slice_fat_one(out, nest, 0 as *u8, 0, &e6[0], 8, 0) != 0) {
      return -1;
    }
    if (codegen_emit_slice_fat_one(out, nest, 0 as *u8, 0, &e7[0], 7, 0) != 0) {
      return -1;
    }
    if (codegen_emit_slice_fat_one(out, nest, 0 as *u8, 0, &e8[0], 8, 0) != 0) {
      return -1;
    }
    if (codegen_emit_slice_fat_one(out, nest, 0 as *u8, 0, &e9[0], 6, 0) != 0) {
      return -1;
    }
    if (codegen_emit_slice_fat_one(out, nest, 0 as *u8, 0, &e10[0], 7, 0) != 0) {
      return -1;
    }
    if (codegen_emit_slice_fat_one(out, nest, 0 as *u8, 0, &e11[0], 5, 0) != 0) {
      return -1;
    }
    if (codegen_emit_slice_fat_one(out, nest, 0 as *u8, 0, &e12[0], 6, 0) != 0) {
      return -1;
    }
    nest = nest + 1;
  }
  return 0;
}

/**
 * Emit host-C SIMD typedefs that emit_vector_c_type_out / type_to_c_repr spell
 * (i32x4_t / u32x8_t / f32x4_t …). Bare `-E` used to omit them; `-o` already
 * injects the same set via rt_preamble §10. Guard XLANG_VECTOR_TYPES so a
 * later `-o` (rt_preamble first, then this header) does not depend on C11
 * identical-typedef redefinition.
 * @param out *CodegenOutBuf — C text buffer; null rejected
 * @return i32 — 0 on success, -1 on emit failure
 * PLATFORM: SHARED host-C. G.7: same typedef set as rt_preamble §10.
 */
function codegen_emit_vector_typedefs(out: *CodegenOutBuf): i32 {
  if (out == 0 as *CodegenOutBuf) {
    return -1;
  }
  /* #ifndef XLANG_VECTOR_TYPES\n#define XLANG_VECTOR_TYPES\n */
  let g: u8[64] = [
    35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 86, 69,
    67, 84, 79, 82, 95, 84, 89, 80, 69, 83, 10,
    35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 86, 69,
    67, 84, 79, 82, 95, 84, 89, 80, 69, 83, 10,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  ];
  if (codegen_emit_bytes_64(out, &g[0], 54) != 0) {
    return -1;
  }
  /* #if defined(__GNUC__) || defined(__clang__)\n */
  let gif: u8[48] = [
    35, 105, 102, 32, 100, 101, 102, 105, 110, 101, 100, 40, 95, 95, 71, 78,
    85, 67, 95, 95, 41, 32, 124, 124, 32, 100, 101, 102, 105, 110, 101, 100,
    40, 95, 95, 99, 108, 97, 110, 103, 95, 95, 41, 10, 0, 0, 0, 0
  ];
  if (codegen_emit_bytes_64(out, &gif[0], 44) != 0) {
    return -1;
  }
  /* GNU vector_size typedefs — same spellings as emit_vector_c_type_out. */
  let t0: u8[64] = [
    116, 121, 112, 101, 100, 101, 102, 32, 105, 110, 116, 51, 50, 95, 116, 32,
    105, 51, 50, 120, 52, 95, 116, 32, 95, 95, 97, 116, 116, 114, 105, 98,
    117, 116, 101, 95, 95, 40, 40, 118, 101, 99, 116, 111, 114, 95, 115, 105,
    122, 101, 40, 49, 54, 41, 41, 41, 59, 10, 0, 0, 0, 0, 0, 0
  ];
  let t1: u8[64] = [
    116, 121, 112, 101, 100, 101, 102, 32, 105, 110, 116, 51, 50, 95, 116, 32,
    105, 51, 50, 120, 56, 95, 116, 32, 95, 95, 97, 116, 116, 114, 105, 98,
    117, 116, 101, 95, 95, 40, 40, 118, 101, 99, 116, 111, 114, 95, 115, 105,
    122, 101, 40, 51, 50, 41, 41, 41, 59, 10, 0, 0, 0, 0, 0, 0
  ];
  let t2: u8[64] = [
    116, 121, 112, 101, 100, 101, 102, 32, 105, 110, 116, 51, 50, 95, 116, 32,
    105, 51, 50, 120, 49, 54, 95, 116, 32, 95, 95, 97, 116, 116, 114, 105, 98,
    117, 116, 101, 95, 95, 40, 40, 118, 101, 99, 116, 111, 114, 95, 115, 105,
    122, 101, 40, 54, 52, 41, 41, 41, 59, 10, 0, 0, 0, 0, 0
  ];
  let t3: u8[64] = [
    116, 121, 112, 101, 100, 101, 102, 32, 117, 105, 110, 116, 51, 50, 95, 116,
    32, 117, 51, 50, 120, 52, 95, 116, 32, 95, 95, 97, 116, 116, 114, 105, 98,
    117, 116, 101, 95, 95, 40, 40, 118, 101, 99, 116, 111, 114, 95, 115, 105,
    122, 101, 40, 49, 54, 41, 41, 41, 59, 10, 0, 0, 0, 0, 0
  ];
  let t4: u8[64] = [
    116, 121, 112, 101, 100, 101, 102, 32, 117, 105, 110, 116, 51, 50, 95, 116,
    32, 117, 51, 50, 120, 56, 95, 116, 32, 95, 95, 97, 116, 116, 114, 105, 98,
    117, 116, 101, 95, 95, 40, 40, 118, 101, 99, 116, 111, 114, 95, 115, 105,
    122, 101, 40, 51, 50, 41, 41, 41, 59, 10, 0, 0, 0, 0, 0
  ];
  let t5: u8[64] = [
    116, 121, 112, 101, 100, 101, 102, 32, 117, 105, 110, 116, 51, 50, 95, 116,
    32, 117, 51, 50, 120, 49, 54, 95, 116, 32, 95, 95, 97, 116, 116, 114, 105,
    98, 117, 116, 101, 95, 95, 40, 40, 118, 101, 99, 116, 111, 114, 95, 115,
    105, 122, 101, 40, 54, 52, 41, 41, 41, 59, 10, 0, 0, 0, 0
  ];
  let t6: u8[64] = [
    116, 121, 112, 101, 100, 101, 102, 32, 102, 108, 111, 97, 116, 32, 102, 51,
    50, 120, 52, 95, 116, 32, 95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101,
    95, 95, 40, 40, 118, 101, 99, 116, 111, 114, 95, 115, 105, 122, 101, 40, 49,
    54, 41, 41, 41, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0
  ];
  let t7: u8[64] = [
    116, 121, 112, 101, 100, 101, 102, 32, 102, 108, 111, 97, 116, 32, 102, 51,
    50, 120, 56, 95, 116, 32, 95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101,
    95, 95, 40, 40, 118, 101, 99, 116, 111, 114, 95, 115, 105, 122, 101, 40, 51,
    50, 41, 41, 41, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0
  ];
  let t8: u8[64] = [
    116, 121, 112, 101, 100, 101, 102, 32, 102, 108, 111, 97, 116, 32, 102, 51,
    50, 120, 49, 54, 95, 116, 32, 95, 95, 97, 116, 116, 114, 105, 98, 117, 116,
    101, 95, 95, 40, 40, 118, 101, 99, 116, 111, 114, 95, 115, 105, 122, 101, 40,
    54, 52, 41, 41, 41, 59, 10, 0, 0, 0, 0, 0, 0, 0
  ];
  if (codegen_emit_bytes_64(out, &t0[0], 58) != 0) { return -1; }
  if (codegen_emit_bytes_64(out, &t1[0], 58) != 0) { return -1; }
  if (codegen_emit_bytes_64(out, &t2[0], 59) != 0) { return -1; }
  if (codegen_emit_bytes_64(out, &t3[0], 59) != 0) { return -1; }
  if (codegen_emit_bytes_64(out, &t4[0], 59) != 0) { return -1; }
  if (codegen_emit_bytes_64(out, &t5[0], 60) != 0) { return -1; }
  if (codegen_emit_bytes_64(out, &t6[0], 56) != 0) { return -1; }
  if (codegen_emit_bytes_64(out, &t7[0], 56) != 0) { return -1; }
  if (codegen_emit_bytes_64(out, &t8[0], 57) != 0) { return -1; }
  /* #else\n */
  let el: u8[8] = [35, 101, 108, 115, 101, 10, 0, 0];
  if (codegen_emit_bytes_64(out, &el[0], 6) != 0) {
    return -1;
  }
  /* Fallback struct typedefs for non-GNU host-cc. */
  let s0: u8[48] = [
    116, 121, 112, 101, 100, 101, 102, 32, 115, 116, 114, 117, 99, 116, 32, 123,
    32, 105, 110, 116, 51, 50, 95, 116, 32, 101, 91, 52, 93, 59, 32, 125, 32,
    105, 51, 50, 120, 52, 95, 116, 59, 10, 0, 0, 0, 0, 0, 0
  ];
  let s1: u8[48] = [
    116, 121, 112, 101, 100, 101, 102, 32, 115, 116, 114, 117, 99, 116, 32, 123,
    32, 105, 110, 116, 51, 50, 95, 116, 32, 101, 91, 56, 93, 59, 32, 125, 32,
    105, 51, 50, 120, 56, 95, 116, 59, 10, 0, 0, 0, 0, 0, 0
  ];
  let s2: u8[48] = [
    116, 121, 112, 101, 100, 101, 102, 32, 115, 116, 114, 117, 99, 116, 32, 123,
    32, 105, 110, 116, 51, 50, 95, 116, 32, 101, 91, 49, 54, 93, 59, 32, 125, 32,
    105, 51, 50, 120, 49, 54, 95, 116, 59, 10, 0, 0, 0, 0
  ];
  let s3: u8[48] = [
    116, 121, 112, 101, 100, 101, 102, 32, 115, 116, 114, 117, 99, 116, 32, 123,
    32, 117, 105, 110, 116, 51, 50, 95, 116, 32, 101, 91, 52, 93, 59, 32, 125, 32,
    117, 51, 50, 120, 52, 95, 116, 59, 10, 0, 0, 0, 0, 0
  ];
  let s4: u8[48] = [
    116, 121, 112, 101, 100, 101, 102, 32, 115, 116, 114, 117, 99, 116, 32, 123,
    32, 117, 105, 110, 116, 51, 50, 95, 116, 32, 101, 91, 56, 93, 59, 32, 125, 32,
    117, 51, 50, 120, 56, 95, 116, 59, 10, 0, 0, 0, 0, 0
  ];
  let s5: u8[48] = [
    116, 121, 112, 101, 100, 101, 102, 32, 115, 116, 114, 117, 99, 116, 32, 123,
    32, 117, 105, 110, 116, 51, 50, 95, 116, 32, 101, 91, 49, 54, 93, 59, 32, 125,
    32, 117, 51, 50, 120, 49, 54, 95, 116, 59, 10, 0, 0, 0
  ];
  let s6: u8[48] = [
    116, 121, 112, 101, 100, 101, 102, 32, 115, 116, 114, 117, 99, 116, 32, 123,
    32, 102, 108, 111, 97, 116, 32, 101, 91, 52, 93, 59, 32, 125, 32, 102, 51,
    50, 120, 52, 95, 116, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0
  ];
  let s7: u8[48] = [
    116, 121, 112, 101, 100, 101, 102, 32, 115, 116, 114, 117, 99, 116, 32, 123,
    32, 102, 108, 111, 97, 116, 32, 101, 91, 56, 93, 59, 32, 125, 32, 102, 51,
    50, 120, 56, 95, 116, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0
  ];
  let s8: u8[48] = [
    116, 121, 112, 101, 100, 101, 102, 32, 115, 116, 114, 117, 99, 116, 32, 123,
    32, 102, 108, 111, 97, 116, 32, 101, 91, 49, 54, 93, 59, 32, 125, 32, 102,
    51, 50, 120, 49, 54, 95, 116, 59, 10, 0, 0, 0, 0, 0, 0
  ];
  if (codegen_emit_bytes_64(out, &s0[0], 42) != 0) { return -1; }
  if (codegen_emit_bytes_64(out, &s1[0], 42) != 0) { return -1; }
  if (codegen_emit_bytes_64(out, &s2[0], 44) != 0) { return -1; }
  if (codegen_emit_bytes_64(out, &s3[0], 43) != 0) { return -1; }
  if (codegen_emit_bytes_64(out, &s4[0], 43) != 0) { return -1; }
  if (codegen_emit_bytes_64(out, &s5[0], 45) != 0) { return -1; }
  if (codegen_emit_bytes_64(out, &s6[0], 40) != 0) { return -1; }
  if (codegen_emit_bytes_64(out, &s7[0], 40) != 0) { return -1; }
  if (codegen_emit_bytes_64(out, &s8[0], 42) != 0) { return -1; }
  /* #endif\n#endif\n */
  let ge2: u8[16] = [35, 101, 110, 100, 105, 102, 10, 35, 101, 110, 100, 105, 102, 10, 0, 0];
  if (codegen_emit_bytes_64(out, &ge2[0], 14) != 0) {
    return -1;
  }
  return 0;
}

/**
 * Emit companion fat-slice layouts for a named struct C tag.
 * After `struct TAG { ... };` emit nest 1..64 companion fat layouts
 * (`struct xlang_slice_×k_TAG { struct xlang_slice_×(k-1)_TAG *data; size_t length; }`,
 * nest=1 pointee is `struct TAG`). 4.2.3: loop through codegen_emit_slice_fat_one
 * (seed twin was wave698 unrolled 1..7 leftover; now the same 1..64 loop.
 * nest>16 soft 17..52; nest>52 jump 53..64).
 * @param out *CodegenOutBuf — C text buffer
 * @param pfx *u8 — struct tag prefix (empty for entry bare)
 * @param pfx_len i32 — prefix byte count; 0 means bare tag
 * @param name *u8 — bare or mono-mangled struct name
 * @param name_len i32 — name length; must be > 0
 * @return i32 — 0 on success, -1 on emit failure
 * PLATFORM: SHARED host-C. G.7: same tag as codegen_emit_module_struct_definitions.
 */
export function codegen_emit_companion_named_slice_layout(out: *CodegenOutBuf, pfx: *u8, pfx_len: i32, name: *u8, name_len: i32): i32 {
  if (out == 0 as *CodegenOutBuf || name == 0 as *u8 || name_len <= 0) {
    return -1;
  }
  /*
   * 4.2.3 + nest>16 soft + nest>52 jump: loop nest 1..64 through the
   * shared fat emitter. Product freeze at 64.
   * PLATFORM: SHARED host-C. G.7 complete same companion authority.
   */
  let nest: i32 = 1;
  while (nest <= 64) {
    if (codegen_emit_slice_fat_one(out, nest, pfx, pfx_len, name, name_len, 1) != 0) {
      return -1;
    }
    nest = nest + 1;
  }
  return 0;
}

/**
 * Host-C: true when an ARRAY_LIT tree is a compile-time constant (LIT / BOOL_LIT
 * or nested ARRAY_LIT of the same). Used so `[][N]T = [[…],[…]]` can be a
 * durable multi-dim static, not pointer rows.
 * @param arena *ASTArena — expression pool
 * @param expr_ref i32 — ARRAY_LIT or leaf
 * @return i32 — 1 if every leaf is LIT/BOOL_LIT, else 0
 * PLATFORM: SHARED host-C emit
 */
function codegen_array_lit_tree_is_const(arena: *ASTArena, expr_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || ast.ref_is_null(expr_ref) || expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    let ek: i32 = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (ek == 0 || ek == 2) {
      return 1;
    }
    if (ek != 46) {
      return 0;
    }
    let n: i32 = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
    let i: i32 = 0;
    while (i < n) {
      let er: i32 = pipeline_expr_array_lit_elem_ref(arena, expr_ref, i);
      if (codegen_array_lit_tree_is_const(arena, er) == 0) {
        return 0;
      }
      i = i + 1;
    }
    return 1;
  }
}

/**
 * File-scope dest-SLICE ARRAY_LIT wrap:
 * `(T){ .data = (E[]){payload}, .length = N }`.
 *
 * Scalar / TYPE_ARRAY elem: payload is emit_braced (ints / `{{…}}`).
 * TYPE_SLICE elem (`[][]T`): each const ARRAY_LIT row recurses this
 * helper so nested `(E[]){…}` stays a file-scope address constant.
 * emit_braced / codegen_emit_expr would inject GNU statement-expr rows —
 * legal in functions, illegal as a C static initializer (BLD001).
 *
 * Function-scope and init_globals must not call this: a block-scope
 * `(E[]){…}` has automatic duration and would dangle. try_emit must
 * not grow an ARRAY_LIT arm for the same reason (init_globals uses
 * block_ref=0).
 *
 * @param arena *ASTArena — expr/type pool
 * @param out *CodegenOutBuf — C text sink
 * @param dest_ty i32 — dest TYPE_SLICE (kind 11)
 * @param lit_ref i32 — EXPR_ARRAY_LIT kind 46; const tree
 * @param ctx *PipelineDepCtx — codegen_emit_type prefix; null OK for []i32
 * @return i32 — 1 emitted; 0 not applicable; -1 hard fail
 * PLATFORM: SHARED host-C (C static initializer only)
 * Seed twin: codegen_gen.linux.x86_64.c
 * codegen_emit_file_scope_dest_slice_array_lit (live `-E` is host-cc of
 * that seed). Do not fork a second file-scope dest-SLICE ARRAY_LIT wrap.
 */
function codegen_emit_file_scope_dest_slice_array_lit(
  arena: *ASTArena,
  out: *CodegenOutBuf,
  dest_ty: i32,
  lit_ref: i32,
  ctx: *PipelineDepCtx
): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf) {
      return 0;
    }
    if (ast.ref_is_null(dest_ty) || dest_ty <= 0) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, dest_ty) != 11) {
      return 0;
    }
    if (ast.ref_is_null(lit_ref) || lit_ref <= 0 || lit_ref > arena.num_exprs) {
      return 0;
    }
    if (pipeline_expr_kind_ord_at(arena, lit_ref) != 46) {
      return 0;
    }
    if (codegen_array_lit_tree_is_const(arena, lit_ref) == 0) {
      return 0;
    }
    let n: i32 = pipeline_expr_array_lit_num_elems_at(arena, lit_ref);
    let elem: i32 = pipeline_type_elem_ref_at(arena, dest_ty);
    if (n <= 0 || ast.ref_is_null(elem) || elem <= 0) {
      return 0;
    }
    let ek: i32 = pipeline_type_kind_ord_at(arena, elem);
    /* Nested [][]T: every row must itself be a const ARRAY_LIT so the
     * recursive wrap cannot fail after the `(T){.data=` prefix is out. */
    if (ek == 11) {
      let ri: i32 = 0;
      while (ri < n) {
        let er: i32 = pipeline_expr_array_lit_elem_ref(arena, lit_ref, ri);
        if (ast.ref_is_null(er) || er <= 0 || er > arena.num_exprs) {
          return 0;
        }
        if (pipeline_expr_kind_ord_at(arena, er) != 46) {
          return 0;
        }
        if (codegen_array_lit_tree_is_const(arena, er) == 0) {
          return 0;
        }
        ri = ri + 1;
      }
    }
    /* (T){ .data = ( */
    if (codegen_append_byte(out, 40) != 0) {
      return -1;
    }
    if (codegen_emit_type(arena, out, dest_ty, 0 as *u8, 0, ctx) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 41) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 123) != 0) {
      return -1;
    }
    let ad1: u8[12] = [32, 46, 100, 97, 116, 97, 32, 61, 32, 40, 0, 0];
    if (codegen_emit_bytes_from_ptr(out, &ad1[0], 10) != 0) {
      return -1;
    }
    if (ek == 10) {
      if (codegen_emit_local_fixed_array_elem_type(arena, out, elem, ctx) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 91) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 93) != 0) {
        return -1;
      }
      if (codegen_emit_local_fixed_array_suffix(arena, out, elem) != 0) {
        return -1;
      }
    } else {
      if (codegen_emit_type(arena, out, elem, 0 as *u8, 0, ctx) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 91) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 93) != 0) {
        return -1;
      }
    }
    if (codegen_append_byte(out, 41) != 0) {
      return -1;
    }
    if (ek == 11) {
      if (codegen_append_byte(out, 123) != 0) {
        return -1;
      }
      let ai: i32 = 0;
      while (ai < n) {
        if (ai > 0) {
          let comma: u8[3] = [44, 32, 0];
          if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
            return -1;
          }
        }
        let er2: i32 = pipeline_expr_array_lit_elem_ref(arena, lit_ref, ai);
        let row: i32 = codegen_emit_file_scope_dest_slice_array_lit(arena, out, elem, er2, ctx);
        if (row <= 0) {
          return -1;
        }
        ai = ai + 1;
      }
      if (codegen_append_byte(out, 125) != 0) {
        return -1;
      }
    } else {
      if (codegen_emit_braced_array_lit_init(arena, out, lit_ref, ctx) != 0) {
        return -1;
      }
    }
    let ad2: u8[16] = [44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0, 0];
    if (codegen_emit_bytes_from_ptr(out, &ad2[0], 12) != 0) {
      return -1;
    }
    if (format_int(out, n) != 0) {
      return -1;
    }
    let ad3: u8[4] = [32, 125, 0, 0];
    if (codegen_emit_bytes_4(out, &ad3[0], 2) != 0) {
      return -1;
    }
    return 1;
  }
}

/**
 * Host-C: emit fat layouts for TYPE_SLICE whose element is TYPE_ARRAY or
 * TYPE_PTR, and for dest extras dest-SLICE-of-SLICE extra ARRAY / PTR
 * (`[][][2]T` / `[][]*T`) whose elem is TYPE_SLICE whose chain hits
 * ARRAY or PTR. ARRAY: `struct xlang_slice_xlang_arrN_<elem>
 * { E (*data)[N]…; }`. PTR: `struct xlang_slice_<elem>_p
 * { E **data; size_t length; }` so the sanitized type_to_c_repr tag
 * (`*` → `_p`) has a matching complete type. SLICE-of-(SLICE-of-
 * ARRAY/PTR): inner fat is already emitted (smaller type-ref); outer
 * is `{ <inner-tag> *data; size_t length; }`. Scalar `[][]T` stays
 * the nest table (chain hits neither ARRAY nor PTR — do not
 * re-emit). Sit-red `[][][2]i32`: dest extras dest-stamps dest-SLICE
 * of dest-SLICE of ARRAY but walker skipped elem=SLICE → incomplete
 * `xlang_slice_xlang_slice_xlang_arr2_int32_t`. Sit-red `[]*i32`:
 * tag was `struct xlang_slice_int32_t *` (pointer, not a tag) and no
 * `{ E **data }` companion. Sit-red `[][2]Pair`: NAMED leaf needs
 * `struct Pair` complete before `E (*data)[N]` (`sizeof(Pair)`);
 * caller emits this walker after module struct defs (not at prologue).
 * G.7: complete this walker (do not invent a second slice-of-PTR /
 * slice-of-ARRAY-of-NAMED / slice-of-slice-of-ARRAY emitter).
 * Tag matches type_to_c_repr. Do not invent -3 / a second dest-SLICE
 * stamp. nest walk cap 64.
 * Seed twin: codegen_gen.linux.x86_64.c codegen_emit_slice_of_fixed_array_layouts
 * (live `-E` is host-cc of that seed). Do not fork a second walker.
 * @param arena *ASTArena — type pool
 * @param out *CodegenOutBuf — C text sink
 * @param ctx *PipelineDepCtx — optional prefix for NAMED leaves
 * @return i32 — 0 success, -1 emit failure
 * PLATFORM: SHARED host-C. G.7 complete type_to_c / fat-layout authority.
 */
export function codegen_emit_slice_of_fixed_array_layouts(arena: *ASTArena, out: *CodegenOutBuf, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf) {
      return -1;
    }
    let pfx_use: *u8 = 0 as *u8;
    let pfx_len_use: i32 = 0;
    let cur_pre: u8[256] = [];
    if (ctx != 0 as *PipelineDepCtx) {
      let pl: i32 = codegen_emit_prefix_len_from_ctx(ctx, &cur_pre[0], 128);
      if (pl > 0) {
        pfx_use = &cur_pre[0];
        pfx_len_use = pl;
      }
    }
    let nt: i32 = arena.num_types;
    let ti: i32 = 1;
    while (ti <= nt) {
      if (pipeline_type_kind_ord_at(arena, ti) == (TypeKind.TYPE_SLICE as i32)) {
        let elem: i32 = pipeline_type_elem_ref_at(arena, ti);
        let elem_k: i32 = 0;
        if (!ast.ref_is_null(elem) && elem > 0 && elem <= nt) {
          elem_k = pipeline_type_kind_ord_at(arena, elem);
        }
        /*
         * dest extras dest-SLICE-of-SLICE extra ARRAY / PTR
         * (`[][][2]T` / `[][]*T`): elem is SLICE whose chain hits
         * ARRAY or PTR. Scalar `[][]T` chain hits a leaf — skip so
         * the nest table stays the unique emitter. Walk cap 64
         * (nest freeze). PLATFORM: SHARED host-C. G.7: complete
         * this walker.
         */
        let hit_ap: i32 = 0;
        if (elem_k == (TypeKind.TYPE_ARRAY as i32) || elem_k == (TypeKind.TYPE_PTR as i32)) {
          hit_ap = 1;
        } else if (elem_k == (TypeKind.TYPE_SLICE as i32)) {
          let walk: i32 = elem;
          let guard: i32 = 0;
          while (guard < 64 && walk > 0 && walk <= nt) {
            let wk: i32 = pipeline_type_kind_ord_at(arena, walk);
            if (wk == (TypeKind.TYPE_ARRAY as i32) || wk == (TypeKind.TYPE_PTR as i32)) {
              hit_ap = 1;
              walk = 0;
            } else if (wk == (TypeKind.TYPE_SLICE as i32)) {
              let next: i32 = pipeline_type_elem_ref_at(arena, walk);
              if (ast.ref_is_null(next) || next <= 0 || next == walk) {
                walk = 0;
              } else {
                walk = next;
                guard = guard + 1;
              }
            } else {
              walk = 0;
            }
          }
        }
        if (hit_ap != 0) {
          let seen: i32 = 0;
          let slb: u8[896] = [];
          let nl: i32 = type_to_c_repr(arena, &slb[0], 896, ti, pfx_use, pfx_len_use);
          if (nl <= 0) {
            return -1;
          }
          let tj: i32 = 1;
          while (tj < ti) {
            if (pipeline_type_kind_ord_at(arena, tj) == (TypeKind.TYPE_SLICE as i32)) {
              let slj: u8[896] = [];
              let nj: i32 = type_to_c_repr(arena, &slj[0], 896, tj, pfx_use, pfx_len_use);
              if (nj == nl && nj > 0) {
                let eq: i32 = 1;
                let ci: i32 = 0;
                while (ci < nl) {
                  if (slb[ci] != slj[ci]) {
                    eq = 0;
                    ci = nl;
                  } else {
                    ci = ci + 1;
                  }
                }
                if (eq != 0) {
                  seen = 1;
                  tj = ti;
                }
              }
            }
            tj = tj + 1;
          }
          if (seen == 0) {
            let si: i32 = 0;
            while (si < nl) {
              if (append_byte_u8(out, slb[si]) != 0) {
                return -1;
              }
              si = si + 1;
            }
            /* " { " */
            let mid0: u8[4] = [32, 123, 32, 0];
            if (codegen_emit_bytes_from_ptr(out, &mid0[0], 3) != 0) {
              return -1;
            }
            if (elem_k == (TypeKind.TYPE_ARRAY as i32)) {
              if (codegen_emit_local_fixed_array_elem_type(arena, out, elem, ctx) != 0) {
                return -1;
              }
              /* " (*data)" */
              let dcl: u8[10] = [32, 40, 42, 100, 97, 116, 97, 41, 0, 0];
              if (codegen_emit_bytes_from_ptr(out, &dcl[0], 8) != 0) {
                return -1;
              }
              if (codegen_emit_local_fixed_array_suffix(arena, out, elem) != 0) {
                return -1;
              }
            } else if (elem_k == (TypeKind.TYPE_SLICE as i32)) {
              /*
               * Outer dest-SLICE of dest-SLICE of ARRAY/PTR: data is
               * a pointer to the inner fat (already complete at a
               * smaller type-ref). type_to_c_repr(elem) is
               * `struct xlang_slice_…`. PLATFORM: SHARED host-C.
               */
              let inner_eb: u8[896] = [];
              let inner_nl: i32 = type_to_c_repr(arena, &inner_eb[0], 896, elem, pfx_use, pfx_len_use);
              if (inner_nl <= 0) {
                return -1;
              }
              let inner_i: i32 = 0;
              while (inner_i < inner_nl) {
                if (append_byte_u8(out, inner_eb[inner_i]) != 0) {
                  return -1;
                }
                inner_i = inner_i + 1;
              }
              /* " *data" */
              let sl_dcl: u8[8] = [32, 42, 100, 97, 116, 97, 0, 0];
              if (codegen_emit_bytes_from_ptr(out, &sl_dcl[0], 6) != 0) {
                return -1;
              }
            } else {
              /*
               * PTR elem: type_to_c_repr(*T) is `E *`; plus ` *data` → `E **data`.
               * PTR-to-ARRAY (`[]*[N]T`): type_to_c_repr(*[N]T) is the ARRAY
               * tag (`xlang_arrN_E *`) which is not a C type (sit-red
               * `unknown type name 'xlang_arr2_int32_t'`). G.7: reuse
               * codegen_emit_c_ptr_to_fixed_array_decl with name `(*data)` →
               * `E (*(*data))[N]`. Scalar `[]*T` stays `E **data`.
               * PLATFORM: SHARED host-C.
               */
              if (type_is_ptr_to_fixed_array(arena, elem) != 0) {
                let ptr_arr_nm: u8[10] = [40, 42, 100, 97, 116, 97, 41, 0, 0, 0];
                if (codegen_emit_c_ptr_to_fixed_array_decl(arena, out, elem, &ptr_arr_nm[0], 7, ctx) != 0) {
                  return -1;
                }
              } else {
                let ptr_eb: u8[896] = [];
                let ptr_nl: i32 = type_to_c_repr(arena, &ptr_eb[0], 896, elem, pfx_use, pfx_len_use);
                if (ptr_nl <= 0) {
                  return -1;
                }
                let ptr_i: i32 = 0;
                while (ptr_i < ptr_nl) {
                  if (append_byte_u8(out, ptr_eb[ptr_i]) != 0) {
                    return -1;
                  }
                  ptr_i = ptr_i + 1;
                }
                /* " *data" */
                let ptr_dcl: u8[8] = [32, 42, 100, 97, 116, 97, 0, 0];
                if (codegen_emit_bytes_from_ptr(out, &ptr_dcl[0], 6) != 0) {
                  return -1;
                }
              }
            }
            /* "; size_t length; };\n" */
            let tail: u8[24] = [
              59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59,
              32, 125, 59, 10, 0, 0, 0, 0
            ];
            if (codegen_emit_bytes_from_ptr(out, &tail[0], 20) != 0) {
              return -1;
            }
          }
        }
      }
      ti = ti + 1;
    }
    return 0;
  }
}

/**
 * Emit host-C `struct` definitions for module layouts.
 * wave488: two-phase so mono mangled tags (Wrap__A) never precede non-generic
 * field types (A) — prior layout-order pass caused incomplete type BLD001.
 * Phase 0: non-generic (and generic with zero mono combos).
 * Phase 1: collect mono combos globally, sort by type-arg nest depth, emit.
 * wave624: after each struct body, emit companion `xlang_slice_<TAG>` fat layout.
 * @param module *Module — current module layouts
 * @param arena *ASTArena — type graph for mono combos / field subst
 * @param out *CodegenOutBuf — C text buffer
 * @param struct_prefix *u8 — optional name prefix (dep modules)
 * @param struct_prefix_len i32 — prefix byte length
 * @param ctx *PipelineDepCtx — owner / entry vs dep emit gates
 * @return i32 — 0 ok, -1 emit failure
 * PLATFORM: SHARED host-C
 */
export function codegen_emit_module_struct_definitions(module: *Module, arena: *ASTArena, out: *CodegenOutBuf, struct_prefix: *u8, struct_prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  // (Do not leave a stray `/**` here: unclosed block comment → L001 swallows the rest of the file.)
  unsafe {
    let cur_di: i32 = -1;
    if (ctx != 0 as *PipelineDepCtx) {
      cur_di = ctx.current_codegen_dep_index;
    }
    let phase: i32 = 0;
    while (phase < 2) {
      let k: i32 = 0;
      let job_k: i32[32] = [];
      let job_ntp: i32[32] = [];
      let job_depth: i32[32] = [];
      let job_mono: i32[128] = [];
      let njob: i32 = 0;
      while (k < module.num_struct_layouts) {
        let nf: i32 = pipeline_module_struct_layout_num_fields(module, k);
        let nl: i32 = pipeline_module_struct_layout_name_len(module, k);
        if (nl <= 0) {
          k = k + 1;
          continue;
        }
        let ty_nm: u8[256] = [];
        pipeline_module_struct_layout_name_into(module, k, &ty_nm[0]);
        if (ctx != 0 as *PipelineDepCtx) {
          let owner: i32 = codegen_type_dep_struct_owner_index(ctx, &ty_nm[0], nl);
          if (owner >= 0 && owner != cur_di) {
            k = k + 1;
            continue;
          }
        }
        if (codegen_should_skip_emit_struct_layout_for_abi_dup(&ty_nm[0], nl) != 0) {
          k = k + 1;
          continue;
        }
        let claim_pfx: u8[256] = [];
        let claim_plen: i32 = 0;
        if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
          claim_plen = struct_prefix_len;
          if (claim_plen > 255) {
            claim_plen = 127;
          }
          let ci: i32 = 0;
          while (ci < claim_plen) {
            claim_pfx[ci] = struct_prefix[ci];
            ci = ci + 1;
          }
        } else if (!(ctx != 0 as *PipelineDepCtx && ctx.current_codegen_dep_index < 0)) {
          claim_pfx[0] = 97;
          claim_pfx[1] = 115;
          claim_pfx[2] = 116;
          claim_pfx[3] = 95;
          claim_plen = 4;
        }
        let ntp_gs: i32 = pipeline_module_struct_layout_num_type_params_at(module, k);
        let combos_gs: i32[32] = [];
        let ncombo_gs: i32 = 0;
        if (ntp_gs > 0 && ntp_gs <= 4 && arena != 0 as *ASTArena) {
          ncombo_gs = codegen_collect_generic_struct_mono_combos(module, arena, k, &ty_nm[0], nl, ntp_gs, &combos_gs[0], 8);
        }
        if (phase == 0) {
          // Defer mono mangled defs so A is complete before Wrap__A.
          if (ncombo_gs > 0) {
            k = k + 1;
            continue;
          }
          // PLATFORM: SHARED — LANG-007 S0: export extern claim must sit in unsafe.
          let claimed_top: i32 = 0;
          unsafe {
            claimed_top = pipeline_codegen_struct_tag_try_claim(&claim_pfx[0], claim_plen, &ty_nm[0], nl);
          }
          if (claimed_top == 0) {
            k = k + 1;
            continue;
          }
          let hdr_top: u8[8] = [115, 116, 114, 117, 99, 116, 32, 0];
          if (codegen_emit_bytes_8(out, &hdr_top[0], 7) != 0) {
            return -1;
          }
          if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
            if (codegen_emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) != 0) {
              return -1;
            }
          } else if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_dep_index < 0) {
            /* entry module: bare file prefix */
          } else {
            let ast_top: u8[4] = [97, 115, 116, 95];
            if (codegen_emit_bytes_4(out, &ast_top[0], 4) != 0) {
              return -1;
            }
          }
          if (codegen_emit_bytes_from_ptr(out, &ty_nm[0], nl) != 0) {
            return -1;
          }
          let br1: u8[4] = [32, 123, 10, 0];
          if (codegen_emit_bytes_4(out, &br1[0], 3) != 0) {
            return -1;
          }
          let j: i32 = 0;
          while (j < nf) {
            // PLATFORM: SHARED — LANG-007 S0: export extern layout reads.
            let flen: i32 = 0;
            let ftr: i32 = 0;
            unsafe {
              flen = pipeline_module_struct_layout_field_name_len(module, k, j);
              ftr = pipeline_module_struct_layout_field_type_ref(module, k, j);
            }
            if (flen <= 0) {
              j = j + 1;
              continue;
            }
            if (codegen_emit_indent(out, 2) != 0) {
              return -1;
            }
            let fnm: u8[256] = [];
            unsafe {
              pipeline_module_struct_layout_field_name_into(module, k, j, &fnm[0]);
            }
            ftr = codegen_resolve_generic_struct_field_type(module, arena, &ty_nm[0], nl, &fnm[0], flen, ftr);
            if (codegen_emit_struct_field_decl_x(arena, out, ftr, &fnm[0], flen, 0 as *u8, 0, ctx) != 0) {
              return -1;
            }
            let semi_nl: u8[3] = [59, 10, 0];
            if (codegen_emit_bytes_3(out, &semi_nl[0], 2) != 0) {
              return -1;
            }
            j = j + 1;
          }
          let close_ty: u8[4] = [125, 59, 10, 10];
          if (codegen_emit_bytes_4(out, &close_ty[0], 4) != 0) {
            return -1;
          }
          /* wave624: companion fat slice so []Named host-C is complete. */
          if (codegen_emit_companion_named_slice_layout(out, &claim_pfx[0], claim_plen, &ty_nm[0], nl) != 0) {
            return -1;
          }
          k = k + 1;
          continue;
        }
        // phase 1 collect mono jobs
        if (ncombo_gs > 0) {
          let cc: i32 = 0;
          while (cc < ncombo_gs && njob < 32) {
            let mono_c: i32[4] = [];
            let ms: i32 = 0;
            while (ms < ntp_gs) {
              mono_c[ms] = combos_gs[cc * ntp_gs + ms];
              ms = ms + 1;
            }
            job_k[njob] = k;
            job_ntp[njob] = ntp_gs;
            job_depth[njob] = codegen_generic_struct_combo_nest_depth(arena, &mono_c[0], ntp_gs);
            ms = 0;
            while (ms < ntp_gs) {
              job_mono[njob * 4 + ms] = mono_c[ms];
              ms = ms + 1;
            }
            while (ms < 4) {
              job_mono[njob * 4 + ms] = 0;
              ms = ms + 1;
            }
            njob = njob + 1;
            cc = cc + 1;
          }
        }
        k = k + 1;
      }
      if (phase == 1) {
        // Sort jobs by nest depth ascending (cross-layout: Pair before Wrap of Pair).
        let i: i32 = 0;
        while (i < njob) {
          let j: i32 = i + 1;
          while (j < njob) {
            if (job_depth[j] < job_depth[i]) {
              let tmp: i32 = job_k[i];
              job_k[i] = job_k[j];
              job_k[j] = tmp;
              tmp = job_ntp[i];
              job_ntp[i] = job_ntp[j];
              job_ntp[j] = tmp;
              tmp = job_depth[i];
              job_depth[i] = job_depth[j];
              job_depth[j] = tmp;
              let s: i32 = 0;
              while (s < 4) {
                tmp = job_mono[i * 4 + s];
                job_mono[i * 4 + s] = job_mono[j * 4 + s];
                job_mono[j * 4 + s] = tmp;
                s = s + 1;
              }
            }
            j = j + 1;
          }
          i = i + 1;
        }
        let ji: i32 = 0;
        while (ji < njob) {
          let jk: i32 = job_k[ji];
          let jntp: i32 = job_ntp[ji];
          // PLATFORM: SHARED — LANG-007 S0: export extern layout reads.
          let jnf: i32 = 0;
          let jnl: i32 = 0;
          unsafe {
            jnf = pipeline_module_struct_layout_num_fields(module, jk);
            jnl = pipeline_module_struct_layout_name_len(module, jk);
          }
          if (jnl <= 0 || jntp <= 0) {
            ji = ji + 1;
            continue;
          }
          let jty: u8[256] = [];
          unsafe {
            pipeline_module_struct_layout_name_into(module, jk, &jty[0]);
          }
          let mono_c: i32[4] = [];
          let ms: i32 = 0;
          while (ms < jntp && ms < 4) {
            mono_c[ms] = job_mono[ji * 4 + ms];
            ms = ms + 1;
          }
          let claim_pfx2: u8[256] = [];
          let claim_plen2: i32 = 0;
          if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
            claim_plen2 = struct_prefix_len;
            if (claim_plen2 > 127) {
              claim_plen2 = 127;
            }
            let ci2: i32 = 0;
            while (ci2 < claim_plen2) {
              claim_pfx2[ci2] = struct_prefix[ci2];
              ci2 = ci2 + 1;
            }
          } else if (!(ctx != 0 as *PipelineDepCtx && ctx.current_codegen_dep_index < 0)) {
            claim_pfx2[0] = 97;
            claim_pfx2[1] = 115;
            claim_pfx2[2] = 116;
            claim_pfx2[3] = 95;
            claim_plen2 = 4;
          }
          let mangled: u8[96] = [];
          let mlen: i32 = codegen_generic_struct_mangled_name_into(arena, &jty[0], jnl, &mono_c[0], jntp, &mangled[0], 96);
          if (mlen <= 0) {
            ji = ji + 1;
            continue;
          }
          // PLATFORM: SHARED — LANG-007 S0: export extern claim must sit in unsafe.
          let claimed_mono: i32 = 0;
          unsafe {
            claimed_mono = pipeline_codegen_struct_tag_try_claim(&claim_pfx2[0], claim_plen2, &mangled[0], mlen);
          }
          if (claimed_mono == 0) {
            ji = ji + 1;
            continue;
          }
          let hdr_m: u8[8] = [115, 116, 114, 117, 99, 116, 32, 0];
          if (codegen_emit_bytes_8(out, &hdr_m[0], 7) != 0) {
            return -1;
          }
          if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
            if (codegen_emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) != 0) {
              return -1;
            }
          } else if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_dep_index < 0) {
            /* entry bare */
          } else {
            let ast_m: u8[4] = [97, 115, 116, 95];
            if (codegen_emit_bytes_4(out, &ast_m[0], 4) != 0) {
              return -1;
            }
          }
          if (codegen_emit_bytes_from_ptr(out, &mangled[0], mlen) != 0) {
            return -1;
          }
          let br_m: u8[4] = [32, 123, 10, 0];
          if (codegen_emit_bytes_4(out, &br_m[0], 3) != 0) {
            return -1;
          }
          let j_m: i32 = 0;
          while (j_m < jnf) {
            // PLATFORM: SHARED — LANG-007 S0: export extern layout reads.
            let flen_m: i32 = 0;
            let ftr_m: i32 = 0;
            unsafe {
              flen_m = pipeline_module_struct_layout_field_name_len(module, jk, j_m);
              ftr_m = pipeline_module_struct_layout_field_type_ref(module, jk, j_m);
            }
            if (flen_m <= 0) {
              j_m = j_m + 1;
              continue;
            }
            if (codegen_emit_indent(out, 2) != 0) {
              return -1;
            }
            let fnm_m: u8[256] = [];
            unsafe {
              pipeline_module_struct_layout_field_name_into(module, jk, j_m, &fnm_m[0]);
            }
            ftr_m = codegen_generic_struct_field_type_from_mono(module, arena, jk, ftr_m, &mono_c[0], jntp);
            if (codegen_emit_struct_field_decl_x(arena, out, ftr_m, &fnm_m[0], flen_m, 0 as *u8, 0, ctx) != 0) {
              return -1;
            }
            let semi_m: u8[3] = [59, 10, 0];
            if (codegen_emit_bytes_3(out, &semi_m[0], 2) != 0) {
              return -1;
            }
            j_m = j_m + 1;
          }
          let close_m: u8[4] = [125, 59, 10, 10];
          if (codegen_emit_bytes_4(out, &close_m[0], 4) != 0) {
            return -1;
          }
          /* wave624: companion fat slice for mono-mangled TAG. */
          if (codegen_emit_companion_named_slice_layout(out, &claim_pfx2[0], claim_plen2, &mangled[0], mlen) != 0) {
            return -1;
          }
          ji = ji + 1;
        }
      }
      phase = phase + 1;
    }
    return 0;
  }
}

/** Exported function `codegen_emit_module_struct_forward_declarations`.
 * Implements `codegen_emit_module_struct_forward_declarations`.
 * @param module *Module
 * @param out *CodegenOutBuf
 * @param struct_prefix *u8
 * @param struct_prefix_len i32
 * @return i32
 */
export function codegen_emit_module_struct_forward_declarations(module: *Module, out: *CodegenOutBuf, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  return codegen_emit_module_struct_forward_declarations_ctx(module, out, struct_prefix, struct_prefix_len, 0 as *PipelineDepCtx);
}

/** Exported function `codegen_emit_module_struct_forward_declarations_ctx`.
 * Implements `codegen_emit_module_struct_forward_declarations_ctx`.
 * @param module *Module
 * @param out *CodegenOutBuf
 * @param struct_prefix *u8
 * @param struct_prefix_len i32
 * @param ctx *PipelineDepCtx
 * @return i32
 */
export function codegen_emit_module_struct_forward_declarations_ctx(module: *Module, out: *CodegenOutBuf, struct_prefix: *u8, struct_prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let k: i32 = 0;
    let cur_di: i32 = -1;
    if (ctx != 0 as *PipelineDepCtx) {
      cur_di = ctx.current_codegen_dep_index;
    }
    while (k < module.num_struct_layouts) {
      let nl: i32 = pipeline_module_struct_layout_name_len(module, k);
      /* wave365: forward-declare zero-field layouts too (only need a valid name). */
      if (nl <= 0) {
        k = k + 1;
        continue;
      }
      let ty_nm: u8[256] = [];
      pipeline_module_struct_layout_name_into(module, k, &ty_nm[0]);
      /* PLATFORM: SHARED — same owner skip as codegen_emit_module_struct_definitions (entry + dep). */
      if (ctx != 0 as *PipelineDepCtx) {
        let owner: i32 = codegen_type_dep_struct_owner_index(ctx, &ty_nm[0], nl);
        if (owner >= 0 && owner != cur_di) {
          k = k + 1;
          continue;
        }
      }
      /* "struct " */
      let hdr: u8[8] = [115, 116, 114, 117, 99, 116, 32, 0];
      if (codegen_emit_bytes_from_ptr(out, &hdr[0], 7) != 0) {
        return -1;
      }
      if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
        if (codegen_emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) != 0) {
          return -1;
        }
      }
      if (codegen_emit_bytes_from_ptr(out, &ty_nm[0], nl) != 0) {
        return -1;
      }
      /* ";\n" */
      let semi_nl: u8[2] = [59, 10];
      if (codegen_emit_bytes_from_ptr(out, &semi_nl[0], 2) != 0) {
        return -1;
      }
      k = k + 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_emit_module_enum_definitions(module: *Module, out: *CodegenOutBuf, enum_prefix: *u8, enum_prefix_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let ei: i32 = 0;
    while (ei < module.num_module_enums) {
      let enl: i32 = pipeline_module_enum_name_len(module, ei);
      if (enl <= 0) {
        ei = ei + 1;
        continue;
      }
      let enm: u8[256] = [];
      let hdr: u8[8] = [101, 110, 117, 109, 32, 0, 0, 0];
      let open: u8[4] = [32, 123, 32, 0];
      let close: u8[6] = [32, 125, 59, 10, 0, 0];
      let comma: u8[3] = [44, 32, 0];
      pipeline_module_enum_name_byte_at(module, ei, 0);
      let nk: i32 = 0;
      while (nk < enl && nk < 64) {
        enm[nk] = pipeline_module_enum_name_byte_at(module, ei, nk);
        nk = nk + 1;
      }
      /* See implementation. */
      let claim_pfx: u8[256] = [];
      let claim_plen: i32 = 0;
      claim_pfx[0] = 101;
      claim_plen = 1;
      if (enum_prefix != 0 as *u8 && enum_prefix_len > 0) {
        let ep: i32 = enum_prefix_len;
        if (ep > 126) {
          ep = 126;
        }
        let ei2: i32 = 0;
        while (ei2 < ep) {
          claim_pfx[1 + ei2] = enum_prefix[ei2];
          ei2 = ei2 + 1;
        }
        claim_plen = 1 + ep;
      }
      if (pipeline_codegen_struct_tag_try_claim(&claim_pfx[0], claim_plen, &enm[0], enl) == 0) {
        ei = ei + 1;
        continue;
      }
      if (codegen_emit_bytes_from_ptr(out, &hdr[0], 5) != 0) {
        return -1;
      }
      if (enum_prefix != 0 as *u8 && enum_prefix_len > 0) {
        if (codegen_emit_bytes_from_ptr(out, enum_prefix, enum_prefix_len) != 0) {
          return -1;
        }
      }
      if (codegen_emit_bytes_from_ptr(out, &enm[0], enl) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_4(out, &open[0], 3) != 0) {
        return -1;
      }
      let nv: i32 = pipeline_module_enum_num_variants(module, ei);
      let vi: i32 = 0;
      while (vi < nv) {
        let vlen: i32 = pipeline_module_enum_variant_name_len(module, ei, vi);
        let vnm: u8[256] = [];
        let vk: i32 = 0;
        if (vi > 0) {
          if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
            return -1;
          }
        }
        while (vk < vlen && vk < 64) {
          vnm[vk] = pipeline_module_enum_variant_name_byte_at(module, ei, vi, vk);
          vk = vk + 1;
        }
        if (enum_prefix != 0 as *u8 && enum_prefix_len > 0) {
          if (codegen_emit_bytes_from_ptr(out, enum_prefix, enum_prefix_len) != 0) {
            return -1;
          }
        }
        if (codegen_emit_bytes_from_ptr(out, &enm[0], enl) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 95) != 0) {
          return -1;
        }
        if (vlen > 0 && codegen_emit_bytes_from_ptr(out, &vnm[0], vlen) != 0) {
          return -1;
        }
        vi = vi + 1;
      }
      if (codegen_emit_bytes_from_ptr(out, &close[0], 4) != 0) {
        return -1;
      }
      ei = ei + 1;
    }
    return 0;
  }
}

/**
 * Emit enum/struct type definitions for every dep module in import-first order.
 *
 * Why: flat di order registers parents before leaf imports (lexer before token).
 * LexerResult embeds token.Token by value → host C needs token_Token complete before
 * lexer_LexerResult (parser M1 host-cc residual).
 *
 * Algorithm (PLATFORM: SHARED): Kahn-style multi-pass over dep indices — a dep is
 * emitted only when every import path that resolves to another dep slot is already
 * emitted (or not in the pool). Caps at nd+2 passes; remainder emitted in di order.
 * Path de-dupe still applies. Restores current_codegen_* after work.
 */
export function codegen_emit_skipped_dep_type_definitions(ctx: *PipelineDepCtx, out: *CodegenOutBuf): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || out == 0 as *CodegenOutBuf) {
      return 0;
    }
    let saved_module: *Module = ctx.current_codegen_module;
    let saved_arena: *ASTArena = ctx.current_codegen_arena;
    let saved_dep_index: i32 = ctx.current_codegen_dep_index;
    let saved_prefix_len: i32 = ctx.current_codegen_prefix_len;
    let saved_prefix: u8[256] = [];
    let sp: i32 = 0;
    while (sp < 64) {
      saved_prefix[sp] = ctx.current_codegen_prefix_mirror[sp];
      sp = sp + 1;
    }
    let nd: i32 = pipeline_dep_ctx_ndep(ctx);
    /* Cap 64 dep slots for emit-done flags (product graphs are far smaller). */
    let done: i32[64] = [];
    let di_init: i32 = 0;
    while (di_init < 64) {
      done[di_init] = 0;
      di_init = di_init + 1;
    }
    let remaining: i32 = 0;
    let di_count: i32 = 0;
    while (di_count < nd) {
      let dep_mod0: *Module = pipeline_dep_ctx_module_at(ctx, di_count);
      let dep_arena0: *ASTArena = pipeline_dep_ctx_arena_at(ctx, di_count);
      let dep_path0: u8[256] = [];
      let plen0: i32 = codegen_dep_import_path_len_at(ctx, di_count, &dep_path0[0]);
      if (dep_mod0 != 0 as *Module && dep_arena0 != 0 as *ASTArena && plen0 > 0) {
        remaining = remaining + 1;
      } else {
        done[di_count] = 1;
      }
      di_count = di_count + 1;
    }
    let pass: i32 = 0;
    let max_pass: i32 = nd + 2;
    while (remaining > 0 && pass < max_pass) {
      let progressed: i32 = 0;
      let di: i32 = 0;
      while (di < nd) {
        if (done[di] != 0) {
          di = di + 1;
          continue;
        }
        let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, di);
        let dep_arena: *ASTArena = pipeline_dep_ctx_arena_at(ctx, di);
        let dep_path: u8[256] = [];
        let dep_path_len: i32 = codegen_dep_import_path_len_at(ctx, di, &dep_path[0]);
        if (dep_mod == 0 as *Module || dep_arena == 0 as *ASTArena || dep_path_len <= 0) {
          done[di] = 1;
          di = di + 1;
          continue;
        }
        /* Ready iff every resolved import dep is already emitted. */
        let ready: i32 = 1;
        let n_imp: i32 = codegen_module_num_imports(dep_mod);
        let ii: i32 = 0;
        while (ii < n_imp) {
          let ipath: u8[256] = [];
          let ilen: i32 = codegen_module_import_path_len_at(dep_mod, ii, &ipath[0]);
          if (ilen > 0) {
            let idi: i32 = codegen_find_dep_index_by_path(ctx, &ipath[0], ilen);
            if (idi >= 0 && idi < nd && idi != di && done[idi] == 0) {
              ready = 0;
              break;
            }
          }
          ii = ii + 1;
        }
        if (ready == 0) {
          di = di + 1;
          continue;
        }
        /* Path de-dupe: first *non-empty* registration (lower di) is authority.
         * Why: an earlier same-path slot with num_struct_layouts==0 (failed/partial load)
         * must not suppress a later real module (parser M1: missing struct ast_* full
         * layouts → dual-extern incomplete tags). Later empty re-regs still suppressed
         * once a non-empty slot for the path was seen.
         * PLATFORM: SHARED — co-emit C TU; verify parser.x -E host-cc + typeck -E. */
        let seen_before: i32 = 0;
        let pj: i32 = 0;
        while (pj < di) {
          let prev_path: u8[256] = [];
          let prev_len: i32 = codegen_dep_import_path_len_at(ctx, pj, &prev_path[0]);
          if (prev_len == dep_path_len) {
            let eq_prev: bool = true;
            let pk: i32 = 0;
            while (pk < dep_path_len && pk < 64) {
              if (prev_path[pk] != dep_path[pk]) {
                eq_prev = false;
                break;
              }
              pk = pk + 1;
            }
            if (eq_prev) {
              let prev_mod: *Module = pipeline_dep_ctx_module_at(ctx, pj);
              if (prev_mod != 0 as *Module && prev_mod.num_struct_layouts > 0) {
                seen_before = 1;
                break;
              }
            }
          }
          pj = pj + 1;
        }
        if (seen_before == 0) {
          let prefix_buf: u8[256] = [];
          let prefix_len: i32 = 0;
          if (codegen_path_is_std_io_core_bytes(&dep_path[0]) == 0) {
            codegen_import_path_to_c_prefix_into(&dep_path[0], &prefix_buf[0], 128);
            while (prefix_len < 128 && prefix_buf[prefix_len] != 0 as u8) {
              prefix_len = prefix_len + 1;
            }
          }
          ctx.current_codegen_module = dep_mod;
          ctx.current_codegen_arena = dep_arena;
          ctx.current_codegen_dep_index = di;
          ctx.current_codegen_prefix_len = 0;
          let px: i32 = 0;
          while (px < prefix_len && px < 63) {
            ctx.current_codegen_prefix_mirror[px] = prefix_buf[px];
            px = px + 1;
          }
          ctx.current_codegen_prefix_mirror[px] = 0 as u8;
          ctx.current_codegen_prefix_len = px;
          if (codegen_emit_module_enum_definitions(dep_mod, out, &prefix_buf[0], prefix_len) != 0) {
            return -1;
          }
          if (codegen_emit_module_struct_definitions(dep_mod, dep_arena, out, &prefix_buf[0], prefix_len, ctx) != 0) {
            return -1;
          }
        }
        done[di] = 1;
        remaining = remaining - 1;
        progressed = 1;
        di = di + 1;
      }
      if (progressed == 0) {
        /* Cycle / unresolved: emit remaining in di order. */
        let dj: i32 = 0;
        while (dj < nd) {
          if (done[dj] == 0) {
            let dep_mod2: *Module = pipeline_dep_ctx_module_at(ctx, dj);
            let dep_arena2: *ASTArena = pipeline_dep_ctx_arena_at(ctx, dj);
            let dep_path2: u8[256] = [];
            let plen2: i32 = codegen_dep_import_path_len_at(ctx, dj, &dep_path2[0]);
            if (dep_mod2 != 0 as *Module && dep_arena2 != 0 as *ASTArena && plen2 > 0) {
              let prefix_buf2: u8[256] = [];
              let prefix_len2: i32 = 0;
              if (codegen_path_is_std_io_core_bytes(&dep_path2[0]) == 0) {
                codegen_import_path_to_c_prefix_into(&dep_path2[0], &prefix_buf2[0], 128);
                while (prefix_len2 < 128 && prefix_buf2[prefix_len2] != 0 as u8) {
                  prefix_len2 = prefix_len2 + 1;
                }
              }
              ctx.current_codegen_module = dep_mod2;
              ctx.current_codegen_arena = dep_arena2;
              ctx.current_codegen_dep_index = dj;
              let px2: i32 = 0;
              while (px2 < prefix_len2 && px2 < 63) {
                ctx.current_codegen_prefix_mirror[px2] = prefix_buf2[px2];
                px2 = px2 + 1;
              }
              ctx.current_codegen_prefix_mirror[px2] = 0 as u8;
              ctx.current_codegen_prefix_len = px2;
              if (codegen_emit_module_enum_definitions(dep_mod2, out, &prefix_buf2[0], prefix_len2) != 0) {
                return -1;
              }
              if (codegen_emit_module_struct_definitions(dep_mod2, dep_arena2, out, &prefix_buf2[0], prefix_len2, ctx) != 0) {
                return -1;
              }
            }
            done[dj] = 1;
            remaining = remaining - 1;
          }
          dj = dj + 1;
        }
      }
      pass = pass + 1;
    }
    ctx.current_codegen_module = saved_module;
    ctx.current_codegen_arena = saved_arena;
    ctx.current_codegen_dep_index = saved_dep_index;
    ctx.current_codegen_prefix_len = saved_prefix_len;
    sp = 0;
    while (sp < 64) {
      ctx.current_codegen_prefix_mirror[sp] = saved_prefix[sp];
      sp = sp + 1;
    }
    return 0;
  }
}

/** Exported function `codegen_emit_dep_struct_forward_declarations`.
 * Implements `codegen_emit_dep_struct_forward_declarations`.
 * @param ctx *PipelineDepCtx
 * @param out *CodegenOutBuf
 * @return i32
 */
export function codegen_emit_dep_struct_forward_declarations(ctx: *PipelineDepCtx, out: *CodegenOutBuf): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || out == 0 as *CodegenOutBuf) {
      return 0;
    }
    let saved_dep_index: i32 = ctx.current_codegen_dep_index;
    let nd: i32 = pipeline_dep_ctx_ndep(ctx);
    let di: i32 = 0;
    while (di < nd) {
      let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, di);
      if (dep_mod != 0 as *Module) {
        let dep_path: u8[256] = [];
        let dep_path_len: i32 = codegen_dep_import_path_len_at(ctx, di, &dep_path[0]);
        let prefix_buf: u8[256] = [];
        let prefix_len: i32 = 0;
        if (dep_path_len > 0 && codegen_path_is_std_io_core_bytes(&dep_path[0]) == 0) {
          codegen_import_path_to_c_prefix_into(&dep_path[0], &prefix_buf[0], 128);
          while (prefix_len < 128 && prefix_buf[prefix_len] != 0 as u8) {
            prefix_len = prefix_len + 1;
          }
        }
        ctx.current_codegen_dep_index = di;
        if (codegen_emit_module_struct_forward_declarations_ctx(dep_mod, out, &prefix_buf[0], prefix_len, ctx) != 0) {
          ctx.current_codegen_dep_index = saved_dep_index;
          return -1;
        }
      }
      di = di + 1;
    }
    /* Owner-prefixed file-scope forwards (dedupe by claim of mangled tag). */
    di = 0;
    while (di < nd) {
      let dep_mod2: *Module = pipeline_dep_ctx_module_at(ctx, di);
      if (dep_mod2 != 0 as *Module) {
        let k: i32 = 0;
        while (k < dep_mod2.num_struct_layouts) {
          let nl: i32 = pipeline_module_struct_layout_name_len(dep_mod2, k);
          let nf: i32 = pipeline_module_struct_layout_num_fields(dep_mod2, k);
          if (nl > 0 && nf > 0) {
            let ty_nm: u8[256] = [];
            pipeline_module_struct_layout_name_into(dep_mod2, k, &ty_nm[0]);
            let owner: i32 = codegen_type_dep_struct_owner_index(ctx, &ty_nm[0], nl);
            if (owner >= 0) {
              let opath: u8[256] = [];
              let oplen: i32 = codegen_dep_import_path_len_at(ctx, owner, &opath[0]);
              let opfx: u8[256] = [];
              let opfx_len: i32 = 0;
              if (oplen > 0 && codegen_path_is_std_io_core_bytes(&opath[0]) == 0) {
                codegen_import_path_to_c_prefix_into(&opath[0], &opfx[0], 128);
                while (opfx_len < 128 && opfx[opfx_len] != 0 as u8) {
                  opfx_len = opfx_len + 1;
                }
              }
              /* C allows redundant `struct Tag;` — emit owner-prefixed forward always.
               * Do not try_claim: that would block later full layout emit of the same tag. */
              let hdr: u8[8] = [115, 116, 114, 117, 99, 116, 32, 0];
              if (codegen_emit_bytes_from_ptr(out, &hdr[0], 7) != 0) {
                ctx.current_codegen_dep_index = saved_dep_index;
                return -1;
              }
              if (opfx_len > 0 && codegen_emit_bytes_from_ptr(out, &opfx[0], opfx_len) != 0) {
                ctx.current_codegen_dep_index = saved_dep_index;
                return -1;
              }
              if (codegen_emit_bytes_from_ptr(out, &ty_nm[0], nl) != 0) {
                ctx.current_codegen_dep_index = saved_dep_index;
                return -1;
              }
              let semi_nl: u8[2] = [59, 10];
              if (codegen_emit_bytes_from_ptr(out, &semi_nl[0], 2) != 0) {
                ctx.current_codegen_dep_index = saved_dep_index;
                return -1;
              }
            }
          }
          k = k + 1;
        }
      }
      di = di + 1;
    }
    ctx.current_codegen_dep_index = saved_dep_index;
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_resolve_binding_import_path_for_field_access(ctx: *PipelineDepCtx, arena: *ASTArena, expr_ref: i32, dst: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module) {
      return 0;
    }
    if (arena == 0 as *ASTArena || dst == 0 as *u8 || expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    if ((e.kind as i32) != (ExprKind.EXPR_FIELD_ACCESS as i32)) {
      return 0;
    }
    if (e.field_access_base_ref <= 0 || e.field_access_base_ref > arena.num_exprs) {
      return 0;
    }
    let base: Expr = ast.ast_arena_expr_get(arena, e.field_access_base_ref);
    if ((base.kind as i32) != (ExprKind.EXPR_VAR as i32) || base.var_name_len <= 0) {
      return 0;
    }
    let cur_mod: *Module = ctx.current_codegen_module;
    let j: i32 = 0;
    let n_imp: i32 = codegen_module_num_imports(cur_mod);
    while (j < n_imp) {
      if (pipeline_module_import_kind_at(cur_mod, j) != 1) {
        j = j + 1;
        continue;
      }
      let bind_len: i32 = pipeline_module_import_binding_name_len(cur_mod, j);
      if (bind_len != base.var_name_len) {
        j = j + 1;
        continue;
      }
      let eq: bool = true;
      let kk: i32 = 0;
      while (kk < base.var_name_len) {
        if (base.var_name[kk] != pipeline_module_import_binding_name_byte_at(cur_mod, j, kk)) {
          eq = false;
          break;
        }
        kk = kk + 1;
      }
      if (!eq) {
        j = j + 1;
        continue;
      }
      return codegen_module_import_path_len_at(cur_mod, j, dst);
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_resolve_binding_import_path_for_method_call(ctx: *PipelineDepCtx, arena: *ASTArena, expr_ref: i32, dst: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module) {
      return 0;
    }
    if (arena == 0 as *ASTArena || dst == 0 as *u8 || expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    if ((e.kind as i32) != (ExprKind.EXPR_METHOD_CALL as i32)) {
      return 0;
    }
    if (e.method_call_base_ref <= 0 || e.method_call_base_ref > arena.num_exprs) {
      return 0;
    }
    let base: Expr = ast.ast_arena_expr_get(arena, e.method_call_base_ref);
    if ((base.kind as i32) != (ExprKind.EXPR_VAR as i32) || base.var_name_len <= 0) {
      return 0;
    }
    let cur_mod: *Module = ctx.current_codegen_module;
    let j: i32 = 0;
    let n_imp: i32 = codegen_module_num_imports(cur_mod);
    while (j < n_imp) {
      if (pipeline_module_import_kind_at(cur_mod, j) != 1) {
        j = j + 1;
        continue;
      }
      let bind_len: i32 = pipeline_module_import_binding_name_len(cur_mod, j);
      if (bind_len != base.var_name_len) {
        j = j + 1;
        continue;
      }
      let eq: bool = true;
      let kk: i32 = 0;
      while (kk < base.var_name_len) {
        if (base.var_name[kk] != pipeline_module_import_binding_name_byte_at(cur_mod, j, kk)) {
          eq = false;
          break;
        }
        kk = kk + 1;
      }
      if (!eq) {
        j = j + 1;
        continue;
      }
      return codegen_module_import_path_len_at(cur_mod, j, dst);
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function emit_import_module_field_symbol(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf) {
      return -1;
    }
    if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return -1;
    }
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    let dep_path: u8[128] = [];
    let dep_path_len: i32 = codegen_resolve_binding_import_path_for_field_access(ctx, arena, expr_ref, &dep_path[0]);
    if ((e.kind as i32) != (ExprKind.EXPR_FIELD_ACCESS as i32) || dep_path_len <= 0) {
      return -1;
    }
    let pre: u8[256] = [];
    codegen_import_path_to_c_prefix_into(&dep_path[0], &pre[0], 128);
    let plen: i32 = 0;
    while (plen < 128 && pre[plen] != 0) {
      plen = plen + 1;
    }
    if (plen > 0 && codegen_c_prefix_redundant_with_name(&pre[0], plen, &e.field_access_field_name[0], e.field_access_field_len) == 0 && codegen_emit_bytes_from_ptr(out, &pre[0], plen) != 0) {
      return -1;
    }
    if (e.field_access_field_len > 0 && codegen_emit_bytes_from_ptr(out, &e.field_access_field_name[0], e.field_access_field_len) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * Emit C for `binding.CONST` when CONST is a dep-module top-level const.
 * Prefer the const init literal (INT_LIT → decimal digits) so host C does not
 * need a mangled symbol that never matches file-static `static const int32_t NAME`.
 * INT_LIT init_ref / kind / int_val are read from the dep arena
 * (`pipeline_dep_ctx_arena_at`); the caller arena is not portable.
 * Fallback: bare field name (matches dep const emit without module prefix).
 * @param arena *ASTArena — caller expr pool (FIELD itself)
 * @param out *CodegenOutBuf
 * @param expr_ref i32 — EXPR_FIELD_ACCESS
 * @param ctx *PipelineDepCtx
 * @return i32 — 0 ok, -1 not an import-module const field
 * PLATFORM: SHARED — G.7 single emit path for import const fields.
 */
export function emit_import_module_const_field(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module) {
      return -1;
    }
    if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return -1;
    }
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    let dep_path: u8[128] = [];
    let dep_path_len: i32 = codegen_resolve_binding_import_path_for_field_access(ctx, arena, expr_ref, &dep_path[0]);
    if ((e.kind as i32) != (ExprKind.EXPR_FIELD_ACCESS as i32) || dep_path_len <= 0) {
      return -1;
    }
    let dep_ix: i32 = codegen_find_dep_index_by_path(ctx, &dep_path[0], dep_path_len);
    /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
    let ndep_fld: i32 = pipeline_dep_ctx_ndep(ctx);
    if (dep_ix < 0 || dep_ix >= ndep_fld) {
      return -1;
    }
    let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, dep_ix);
    if (dep_mod == 0 as *Module) {
      return -1;
    }
    let ti: i32 = 0;
    while (ti < dep_mod.num_top_level_lets) {
      if (pipeline_module_top_level_let_is_const(dep_mod, ti) == 0) {
        ti = ti + 1;
        continue;
      }
      let nlen: i32 = pipeline_module_top_level_let_name_len(dep_mod, ti);
      if (nlen != e.field_access_field_len) {
        ti = ti + 1;
        continue;
      }
      let nm_eq: bool = true;
      let ni: i32 = 0;
      while (ni < nlen) {
        if (pipeline_module_top_level_let_name_byte_at(dep_mod, ti, ni) != e.field_access_field_name[ni]) {
          nm_eq = false;
          break;
        }
        ni = ni + 1;
      }
      if (!nm_eq) {
        ti = ti + 1;
        continue;
      }
      /*
       * wave703: dep top-level const is emitted as file-static bare name
       * (`static const int32_t POLL_PENDING = 0`), not `std_async_POLL_PENDING`.
       * Prior emit_import_module_field_symbol prefixed the path → BLD001 undeclared.
       * Prefer INT_LIT init value; else bare field name. PLATFORM: SHARED.
       */
      /*
       * init_ref / kind / int_val live in the dep arena. The caller
       * arena must not be used: a dep INT_LIT index is not portable
       * (kind_ord_at(caller, init_ref) misses → bare undeclared `K`).
       * PLATFORM: SHARED host-C.
       */
      let init_ref: i32 = pipeline_module_top_level_let_init_ref(dep_mod, ti);
      let dep_ar: *ASTArena = pipeline_dep_ctx_arena_at(ctx, dep_ix);
      if (dep_ar != 0 as *ASTArena && init_ref > 0 && init_ref <= dep_ar.num_exprs
      && pipeline_expr_kind_ord_at(dep_ar, init_ref) == 0) {
        if (format_int(out, pipeline_expr_int_val_at(dep_ar, init_ref) as i64) != 0) {
          return -1;
        }
        return 0;
      }
      /*
       * ARRAY_LIT: inline `(T[]){…}` so dest-SLICE `.data` / INDEX base do
       * not need file-static `A`. Consts-only deps are not co-emitted
       * (driver `nf > 0` gate — pipeline_abi leftover). PLATFORM: SHARED.
       */
      if (dep_ar != 0 as *ASTArena && init_ref > 0 && init_ref <= dep_ar.num_exprs
      && pipeline_expr_kind_ord_at(dep_ar, init_ref) == 46) {
        let tr_al: i32 = pipeline_module_top_level_let_type_ref(dep_mod, ti);
        let elem_k: i32 = TypeKind.TYPE_I32 as i32;
        if (!ast.ref_is_null(tr_al) && pipeline_type_kind_ord_at(dep_ar, tr_al) == 10) {
          let et_al: i32 = pipeline_type_elem_ref_at(dep_ar, tr_al);
          if (!ast.ref_is_null(et_al) && et_al > 0) {
            elem_k = pipeline_type_kind_ord_at(dep_ar, et_al);
          }
        }
        /*
         * Durable static: `(T[]){…}` dies at the end of a statement-expr
         * assignment (`__xlang_al[0] = {.data=(T[]){…}}` → wrap_row 33).
         * Unique `__xlang_icN` so dual uses in one function do not alias.
         * PLATFORM: SHARED host-C.
         */
        let tid_al: i32 = codegen_next_host_call_array_tmp_id();
        let ic_open: u8[12] = [40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &ic_open[0], 10) != 0) {
          return -1;
        }
        if (codegen_emit_type_kind(out, elem_k) != 0) {
          let fb_i32: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
          if (codegen_emit_bytes_8(out, &fb_i32[0], 7) != 0) {
            return -1;
          }
        }
        let ic_nm: u8[12] = [32, 95, 95, 120, 108, 97, 110, 103, 95, 105, 99, 0];
        if (codegen_emit_bytes_from_ptr(out, &ic_nm[0], 11) != 0) {
          return -1;
        }
        if (format_int(out, tid_al as i64) != 0) {
          return -1;
        }
        let ic_eq: u8[8] = [91, 93, 32, 61, 32, 0, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &ic_eq[0], 5) != 0) {
          return -1;
        }
        if (codegen_emit_braced_array_lit_init(dep_ar, out, init_ref, ctx) != 0) {
          return -1;
        }
        let ic_sc: u8[4] = [59, 32, 0, 0];
        if (codegen_emit_bytes_4(out, &ic_sc[0], 2) != 0) {
          return -1;
        }
        let ic_use: u8[12] = [95, 95, 120, 108, 97, 110, 103, 95, 105, 99, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &ic_use[0], 10) != 0) {
          return -1;
        }
        if (format_int(out, tid_al as i64) != 0) {
          return -1;
        }
        let ic_end: u8[8] = [59, 32, 125, 41, 0, 0, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &ic_end[0], 4) != 0) {
          return -1;
        }
        return 0;
      }
      if (e.field_access_field_len > 0
      && codegen_emit_bytes_from_ptr(out, &e.field_access_field_name[0], e.field_access_field_len) != 0) {
        return -1;
      }
      return 0;
    }
    return -1;
  }
}

/**
 * wave707: if VAR is a match struct field bind (not local/param), emit `(matched).field`.
 * typeck stores struct patterns as wildcards and resolves field names as subject fields;
 * host-C must not emit bare undeclared identifiers.
 * @param arena *ASTArena
 * @param out *CodegenOutBuf
 * @param ctx *PipelineDepCtx
 * @param name *u8 — VAR name bytes
 * @param name_len i32
 * @return i32 — 0 emitted field access; 1 not a field bind; -1 emit fail
 * PLATFORM: SHARED — G.7 with pipeline_codegen_match_* glue.
 */
function codegen_try_emit_match_field_bind(arena: *ASTArena, out: *CodegenOutBuf, ctx: *PipelineDepCtx,
    name: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — host-C match field bind as subject.field.
  unsafe {
    let mod: *Module = 0 as *Module;
    let matched_ref: i32 = 0;
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || name == 0 as *u8 || name_len <= 0) {
      return 1;
    }
    if (ctx != 0 as *PipelineDepCtx) {
      mod = ctx.current_codegen_module;
    }
    if (mod == 0 as *Module) {
      mod = pipeline_codegen_match_mod_c();
    }
    if (mod == 0 as *Module) {
      return 1;
    }
    if (codegen_name_is_local_binding(arena, ctx, name, name_len) != 0) {
      return 1;
    }
    if (pipeline_codegen_match_name_is_subject_field_c(mod, arena, name, name_len) == 0) {
      return 1;
    }
    matched_ref = pipeline_codegen_match_matched_ref_c();
    if (matched_ref <= 0 || ast.ref_is_null(matched_ref)) {
      return 1;
    }
    /* (subject.field) */
    if (codegen_append_byte(out, 40) != 0) {
      return 0 - 1;
    }
    if (codegen_emit_expr(arena, out, matched_ref, ctx) != 0) {
      return 0 - 1;
    }
    if (codegen_append_byte(out, 46) != 0) {
      return 0 - 1;
    }
    if (codegen_emit_bytes_64(out, &name[0], name_len) != 0) {
      return 0 - 1;
    }
    if (codegen_append_byte(out, 41) != 0) {
      return 0 - 1;
    }
    return 0;
  }
}

/**
 * wave707: push match subject field-bind context for arm/guard emit (save/restore).
 * @param module *Module — current codegen module
 * @param matched_ref i32 — match subject expr
 * @param arena *ASTArena — for resolved type of subject
 * @return void — side effect only
 * PLATFORM: SHARED
 */
function codegen_match_push_subject(module: *Module, matched_ref: i32, arena: *ASTArena): void {
  // PLATFORM: SHARED — set host-C match subject for field binds.
  unsafe {
    let ty: i32 = 0;
    if (module == 0 as *Module || arena == 0 as *ASTArena || matched_ref <= 0 || ast.ref_is_null(matched_ref)) {
      pipeline_codegen_match_clear_subject_c();
      return;
    }
    ty = pipeline_expr_resolved_type_ref(arena, matched_ref);
    pipeline_codegen_match_set_subject_c(module, matched_ref, ty);
  }
}

/**
 * wave371: emit match arm result in value position (C ternary).
 * EXPR_RETURN unwraps to its operand so host `return match { 1 => return 42; … }`
 * becomes `return (subj==1?(42):…)` instead of illegal `return (…?(return 42):…)`.
 * wave372: mid-body match with RETURN arms uses statement if/else (see
 * codegen_emit_match_as_stmt); ternary remains for expression/value position only.
 * @param arena *ASTArena
 * @param out *CodegenOutBuf
 * @param res_ref i32 — arm result expr
 * @param ctx *PipelineDepCtx
 * @return i32 — 0 ok, -1 fail
 * PLATFORM: SHARED — host-C match ternary arm value.
 */
function codegen_emit_match_arm_value(arena: *ASTArena, out: *CodegenOutBuf, res_ref: i32,
    ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — host-C match arm value / RETURN unwrap.
  unsafe {
    if (ast.ref_is_null(res_ref)) {
      return codegen_append_byte(out, 48);
    }
    let re: Expr = ast.ast_arena_expr_get(arena, res_ref);
    if ((re.kind as i32) == (ExprKind.EXPR_RETURN as i32)) {
      if (ast.ref_is_null(re.unary_operand_ref)) {
        return codegen_append_byte(out, 48);
      }
      return codegen_emit_expr(arena, out, re.unary_operand_ref, ctx);
    }
    return codegen_emit_expr(arena, out, res_ref, ctx);
  }
}

/**
 * True if a block contains an explicit `return` statement (expr_stmt, final RETURN,
 * nested region body, or nested EXPR_BLOCK). Does **not** treat a value final_expr
 * (e.g. `{ 42 }`) as return — unlike codegen_block_contains_return.
 * @param arena *ASTArena — expression arena
 * @param block_ref i32 — block pool ref
 * @return i32 — 1 if explicit return present, else 0
 * PLATFORM: SHARED — host-C match stmt form gate (wave374).
 */
function codegen_block_has_explicit_return(arena: *ASTArena, block_ref: i32): i32 {
  // PLATFORM: SHARED — only real return control, not value final_expr.
  unsafe {
    if (arena == 0 as *ASTArena || ast.ref_is_null(block_ref)) {
      return 0;
    }
    if (block_ref <= 0 || block_ref > arena.num_blocks) {
      return 0;
    }
    let ji: i32 = 0;
    let nes: i32 = ast_ast_block_num_expr_stmts(arena, block_ref);
    while (ji < nes) {
      let se_ref: i32 = ast_ast_block_expr_stmt_ref(arena, block_ref, ji);
      let se: Expr = ast.ast_arena_expr_get(arena, se_ref);
      if ((se.kind as i32) == (ExprKind.EXPR_RETURN as i32)) {
        return 1;
      }
      if ((se.kind as i32) == (ExprKind.EXPR_BLOCK as i32) && codegen_block_has_explicit_return(arena, se.block_ref) != 0) {
        return 1;
      }
      ji = ji + 1;
    }
    let fr: i32 = ast_ast_block_final_expr_ref(arena, block_ref);
    if (!ast.ref_is_null(fr)) {
      let fe: Expr = ast.ast_arena_expr_get(arena, fr);
      if ((fe.kind as i32) == (ExprKind.EXPR_RETURN as i32)) {
        return 1;
      }
      if ((fe.kind as i32) == (ExprKind.EXPR_BLOCK as i32) && codegen_block_has_explicit_return(arena, fe.block_ref) != 0) {
        return 1;
      }
    }
    let ri: i32 = 0;
    let nr: i32 = ast_ast_block_num_regions(arena, block_ref);
    while (ri < nr) {
      let rb: i32 = ast_ast_block_region_body_ref(arena, block_ref, ri);
      if (codegen_block_has_explicit_return(arena, rb) != 0) {
        return 1;
      }
      ri = ri + 1;
    }
    return 0;
  }
}

/**
 * True if a match arm result is return-control: bare `return e` or `{ … return …; }`.
 * Value blocks `{ 42 }` are not return-control (stay ternary / final return value).
 * @param arena *ASTArena
 * @param res_ref i32 — arm result expr
 * @return i32 — 1 if return-control, else 0
 * PLATFORM: SHARED — host-C match stmt form gate (wave374).
 */
function codegen_match_arm_result_is_return_control(arena: *ASTArena, res_ref: i32): i32 {
  // PLATFORM: SHARED — arm root RETURN or block with explicit return.
  unsafe {
    if (ast.ref_is_null(res_ref)) {
      return 0;
    }
    let re: Expr = ast.ast_arena_expr_get(arena, res_ref);
    if ((re.kind as i32) == (ExprKind.EXPR_RETURN as i32)) {
      return 1;
    }
    if ((re.kind as i32) == (ExprKind.EXPR_BLOCK as i32)) {
      return codegen_block_has_explicit_return(arena, re.block_ref);
    }
    return 0;
  }
}

/**
 * True if any match arm is return-control (needs statement if/else, not ternary).
 * Covers bare `=> return N` (wave372) and block arms `=> { return N; }` (wave374).
 * @param arena *ASTArena — expression arena
 * @param expr_ref i32 — EXPR_MATCH node
 * @return i32 — 1 if any arm is return-control, else 0
 * PLATFORM: SHARED — host-C match stmt form gate (wave372/wave374).
 */
function codegen_match_has_return_arm(arena: *ASTArena, expr_ref: i32): i32 {
  // PLATFORM: SHARED — scan arm results for return-control.
  unsafe {
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    let n: i32 = e.match_num_arms;
    let i: i32 = 0;
    while (i < n) {
      let res: i32 = pipeline_expr_match_arm_result_ref(arena, expr_ref, i);
      if (codegen_match_arm_result_is_return_control(arena, res) != 0) {
        return 1;
      }
      i = i + 1;
    }
    return 0;
  }
}

/**
 * Emit one match arm body as a C statement (true `return` or discarded value).
 * @param arena *ASTArena
 * @param out *CodegenOutBuf
 * @param res_ref i32 — arm result
 * @param indent i32 — base indent of the surrounding match stmt
 * @param ctx *PipelineDepCtx
 * @param fn_ret_void i32 — current function returns void
 * @return i32 — 0 ok, -1 fail
 * PLATFORM: SHARED — host-C match stmt arm body (wave372).
 */
function codegen_emit_match_stmt_arm_body(arena: *ASTArena, out: *CodegenOutBuf, res_ref: i32,
    indent: i32, ctx: *PipelineDepCtx, fn_ret_void: i32): i32 {
  // PLATFORM: SHARED — RETURN → real return; BLOCK → codegen_emit_block; else (void)(value);
  unsafe {
    if (!ast.ref_is_null(res_ref)) {
      let re: Expr = ast.ast_arena_expr_get(arena, res_ref);
      if ((re.kind as i32) == (ExprKind.EXPR_RETURN as i32)) {
        return emit_return_stmt_with_context(arena, out, indent + 2, re.unary_operand_ref, ctx,
            fn_ret_void);
      }
      /* wave374: block arm `{ return N; … }` as real statements inside if/else body */
      if ((re.kind as i32) == (ExprKind.EXPR_BLOCK as i32) && !ast.ref_is_null(re.block_ref)) {
        return codegen_emit_block(arena, out, re.block_ref, indent + 2, ctx);
      }
    }
    if (codegen_emit_indent(out, indent + 2) != 0) {
      return -1;
    }
    let v: u8[9] = [40, 118, 111, 105, 100, 41, 40, 0, 0];
    if (codegen_emit_bytes_9(out, &v[0], 7) != 0) {
      return -1;
    }
    if (ast.ref_is_null(res_ref)) {
      if (codegen_append_byte(out, 48) != 0) {
        return -1;
      }
    } else if (codegen_emit_expr(arena, out, res_ref, ctx) != 0) {
      return -1;
    }
    let sc: u8[4] = [41, 59, 10, 0];
    return codegen_emit_bytes_4(out, &sc[0], 3);
  }
}

/**
 * Host-C statement form for mid-body EXPR_MATCH with RETURN arms.
 * Nested ternary cannot contain `return` and wave371 value-unwrap made following
 * statements reachable (`(void)((v==1?(42):0)); return 7;` → exit 7).
 * Emits if/else if/else with real `return` (same shape as bare if return follow).
 * @param arena *ASTArena
 * @param out *CodegenOutBuf
 * @param expr_ref i32 — EXPR_MATCH
 * @param indent i32 — statement indent
 * @param ctx *PipelineDepCtx
 * @param fn_ret_void i32 — current function returns void
 * @return i32 — 0 ok, -1 fail
 * PLATFORM: SHARED — host-C match early-return stmt (wave372). G.7 single authority.
 */
function codegen_emit_match_as_stmt(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32,
    indent: i32, ctx: *PipelineDepCtx, fn_ret_void: i32): i32 {
  // PLATFORM: SHARED — if/else chain; seed twin same commit.
  // wave707: subject field-bind context for arm bodies.
  unsafe {
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    let n: i32 = e.match_num_arms;
    let matched: i32 = e.match_matched_ref;
    let i: i32 = 0;
    let opened: i32 = 0;
    let wild_i: i32 = -1;
    let eq: u8[3] = [61, 61, 0];
    let if_kw: u8[4] = [105, 102, 32, 0];
    let else_if: u8[11] = [125, 32, 101, 108, 115, 101, 32, 105, 102, 32, 0];
    let else_br: u8[9] = [125, 32, 101, 108, 115, 101, 32, 123, 0];
    let open_br: u8[4] = [41, 32, 123, 0];
    let close_br: u8[3] = [125, 10, 0];
    let if1: u8[8] = [105, 102, 32, 40, 49, 41, 32, 0];
    let cmp_val: i32 = 0;
    let res: i32 = 0;
    /* wave708: guard support in stmt path (struct field lit patterns). */
    let guard_ref: i32 = 0;
    let and_and: u8[3] = [38, 38, 0];
    let prev_mod: *Module = pipeline_codegen_match_mod_c();
    let prev_mref: i32 = pipeline_codegen_match_matched_ref_c();
    let prev_ty: i32 = pipeline_codegen_match_subject_ty_c();
    let cur_mod: *Module = 0 as *Module;
    if (ctx != 0 as *PipelineDepCtx) {
      cur_mod = ctx.current_codegen_module;
    }
    if (cur_mod != 0 as *Module) {
      codegen_match_push_subject(cur_mod, matched, arena);
    }
    while (i < n) {
      guard_ref = pipeline_expr_match_arm_guard_ref(arena, expr_ref, i);
      if (pipeline_expr_match_arm_is_wildcard(arena, expr_ref, i) != 0
      && (ast.ref_is_null(guard_ref) || guard_ref <= 0)) {
        wild_i = i;
      } else {
        if (codegen_emit_indent(out, indent) != 0) {
          return -1;
        }
        if (opened == 0) {
          if (codegen_emit_bytes_from_ptr(out, &if_kw[0], 3) != 0) {
            return -1;
          }
        } else {
          if (codegen_emit_bytes_from_ptr(out, &else_if[0], 10) != 0) {
            return -1;
          }
        }
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        if (pipeline_expr_match_arm_is_wildcard(arena, expr_ref, i) != 0) {
          /* wave708: wildcard + guard — condition is the guard expression. */
          if (codegen_emit_expr(arena, out, guard_ref, ctx) != 0) {
            return -1;
          }
        } else {
          if (ast.ref_is_null(matched) || codegen_emit_expr(arena, out, matched, ctx) != 0) {
            return -1;
          }
          if (codegen_emit_bytes_2(out, &eq[0], 2) != 0) {
            return -1;
          }
          if (pipeline_expr_match_arm_is_enum_variant(arena, expr_ref, i) != 0) {
            cmp_val = pipeline_expr_match_arm_variant_index(arena, expr_ref, i);
          } else {
            cmp_val = pipeline_expr_match_arm_lit_val(arena, expr_ref, i);
          }
          if (format_int(out, cmp_val as i64) != 0) {
            return -1;
          }
          /* wave708: non-wildcard + guard — append `&& (guard_expr)`. */
          if (!ast.ref_is_null(guard_ref) && guard_ref > 0) {
            if (codegen_emit_bytes_2(out, &and_and[0], 2) != 0) {
              return -1;
            }
            if (codegen_append_byte(out, 40) != 0) {
              return -1;
            }
            if (codegen_emit_expr(arena, out, guard_ref, ctx) != 0) {
              return -1;
            }
            if (codegen_append_byte(out, 41) != 0) {
              return -1;
            }
          }
        }
        if (codegen_emit_bytes_from_ptr(out, &open_br[0], 3) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 10) != 0) {
          return -1;
        }
        res = pipeline_expr_match_arm_result_ref(arena, expr_ref, i);
        if (codegen_emit_match_stmt_arm_body(arena, out, res, indent, ctx, fn_ret_void) != 0) {
          return -1;
        }
        opened = 1;
      }
      i = i + 1;
    }
    if (wild_i >= 0) {
      if (codegen_emit_indent(out, indent) != 0) {
        return -1;
      }
      if (opened != 0) {
        /* "} else {\n" */
        if (codegen_emit_bytes_from_ptr(out, &else_br[0], 8) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 10) != 0) {
          return -1;
        }
      } else {
        /* only wildcard: if (1) {\n body } */
        if (codegen_emit_bytes_from_ptr(out, &if1[0], 7) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 123) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 10) != 0) {
          return -1;
        }
      }
      res = pipeline_expr_match_arm_result_ref(arena, expr_ref, wild_i);
      if (codegen_emit_match_stmt_arm_body(arena, out, res, indent, ctx, fn_ret_void) != 0) {
        return -1;
      }
      opened = 1;
    }
    if (opened != 0) {
      if (codegen_emit_indent(out, indent) != 0) {
        pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
        return 0 - 1;
      }
      {
        let brc: i32 = codegen_emit_bytes_3(out, &close_br[0], 2);
        pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
        return brc;
      }
    }
    pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
    return 0;
  }
}

/**
 * Host-C emit for EXPR_MATCH arms[arm_i..): nested ternary chain.
 * @param arena *ASTArena — expression arena
 * @param out *CodegenOutBuf — C text sink
 * @param expr_ref i32 — EXPR_MATCH node
 * @param ctx *PipelineDepCtx — emit context (may be null)
 * @param arm_i i32 — current arm index (0-based)
 * @return i32 — 0 on success, -1 on emit failure
 * PLATFORM: SHARED — mirrors freestanding pipeline_asm_emit_match_elf_c semantics
 * (first match wins; wildcard ends chain). Host C re-emits the subject per arm
 * (subjects are typically VAR/param). G.7: completes arm-0 residual that only
 * emitted the first arm result without comparing. wave371: RETURN arm unwrap.
 */
function codegen_emit_match_from_arm(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32,
    ctx: *PipelineDepCtx, arm_i: i32): i32 {
  // PLATFORM: SHARED — host-C match nested ternary; seed twin same commit.
  // wave700: optional guard — wildcard+guard falls through; lit+guard uses &&.
  // wave707: subject field-bind context for arm result/guard VAR emit.
  unsafe {
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    let n: i32 = e.match_num_arms;
    let matched: i32 = e.match_matched_ref;
    let res: i32 = 0;
    let cmp_val: i32 = 0;
    let guard_ref: i32 = 0;
    let eq: u8[3] = [61, 61, 0];
    let and_and: u8[3] = [38, 38, 0];
    let prev_mod: *Module = pipeline_codegen_match_mod_c();
    let prev_mref: i32 = pipeline_codegen_match_matched_ref_c();
    let prev_ty: i32 = pipeline_codegen_match_subject_ty_c();
    let cur_mod: *Module = 0 as *Module;
    let rc: i32 = 0;
    if (arm_i >= n) {
      return codegen_append_byte(out, 48);
    }
    if (ctx != 0 as *PipelineDepCtx) {
      cur_mod = ctx.current_codegen_module;
    }
    if (cur_mod != 0 as *Module) {
      codegen_match_push_subject(cur_mod, matched, arena);
    }
    guard_ref = pipeline_expr_match_arm_guard_ref(arena, expr_ref, arm_i);
    res = pipeline_expr_match_arm_result_ref(arena, expr_ref, arm_i);
    /* Terminal wildcard (no guard): just the result. */
    if (pipeline_expr_match_arm_is_wildcard(arena, expr_ref, arm_i) != 0
    && (ast.ref_is_null(guard_ref) || guard_ref <= 0)) {
      rc = codegen_emit_match_arm_value(arena, out, res, ctx);
      pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
      return rc;
    }
    /* (cond?(result):(rest)) where cond is guard-only, lit, or lit&&guard */
    if (codegen_append_byte(out, 40) != 0) {
      pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
      return 0 - 1;
    }
    if (pipeline_expr_match_arm_is_wildcard(arena, expr_ref, arm_i) != 0) {
      /* Guaranteed guard_ref present (else branch above). */
      if (codegen_emit_expr(arena, out, guard_ref, ctx) != 0) {
        pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
        return 0 - 1;
      }
    } else {
      if (codegen_append_byte(out, 40) != 0) {
        pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
        return 0 - 1;
      }
      if (ast.ref_is_null(matched) || codegen_emit_expr(arena, out, matched, ctx) != 0) {
        pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
        return 0 - 1;
      }
      if (codegen_emit_bytes_2(out, &eq[0], 2) != 0) {
        pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
        return 0 - 1;
      }
      if (pipeline_expr_match_arm_is_enum_variant(arena, expr_ref, arm_i) != 0) {
        cmp_val = pipeline_expr_match_arm_variant_index(arena, expr_ref, arm_i);
      } else {
        cmp_val = pipeline_expr_match_arm_lit_val(arena, expr_ref, arm_i);
      }
      if (format_int(out, cmp_val as i64) != 0) {
        pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
        return 0 - 1;
      }
      if (codegen_append_byte(out, 41) != 0) {
        pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
        return 0 - 1;
      }
      if (!ast.ref_is_null(guard_ref) && guard_ref > 0) {
        if (codegen_emit_bytes_2(out, &and_and[0], 2) != 0) {
          pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
          return 0 - 1;
        }
        if (codegen_append_byte(out, 40) != 0) {
          pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
          return 0 - 1;
        }
        if (codegen_emit_expr(arena, out, guard_ref, ctx) != 0) {
          pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
          return 0 - 1;
        }
        if (codegen_append_byte(out, 41) != 0) {
          pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
          return 0 - 1;
        }
      }
    }
    if (codegen_append_byte(out, 63) != 0) {
      pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
      return 0 - 1;
    }
    if (codegen_append_byte(out, 40) != 0) {
      pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
      return 0 - 1;
    }
    if (codegen_emit_match_arm_value(arena, out, res, ctx) != 0) {
      pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
      return 0 - 1;
    }
    if (codegen_append_byte(out, 41) != 0) {
      pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
      return 0 - 1;
    }
    if (codegen_append_byte(out, 58) != 0) {
      pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
      return 0 - 1;
    }
    /* Recurse with parent subject restored so nested match gets clean push. */
    pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
    if (codegen_emit_match_from_arm(arena, out, expr_ref, ctx, arm_i + 1) != 0) {
      return 0 - 1;
    }
    return codegen_append_byte(out, 41);
  }
}

/**
 * Emit a single expression as C source text into out.
 * @param arena *ASTArena — expression arena
 * @param out *CodegenOutBuf — C text sink
 * @param expr_ref i32 — expression ref
 * @param ctx *PipelineDepCtx — emit context (may be null)
 * @return i32 — 0 on success, -1 on failure
 */
export function codegen_emit_expr(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ast.ref_is_null(expr_ref)) {
      return 0;
    }
    if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    /**
     * PLATFORM: SHARED — consume typeck CTFE (const_folded_*). Authority is typeck fold,
     * not emit-side optim; C path mirrors asm mov-imm when typeck folded the tree.
     * Skip VAR (ord 3): pool field may be stale; VAR names resolve via const/let slots.
     * Skip FLOAT_LIT (ord 1): wave287 — i32 fold truncates fractions; emit via
     * pipeline_codegen_emit_float_lit_c on float_val (seed codegen twin same commit).
     */
    if (e.const_folded_valid != 0 && pipeline_expr_kind_ord_at(arena, expr_ref) != 3
    && pipeline_expr_kind_ord_at(arena, expr_ref) != 1) {
      if (format_int(out, e.const_folded_val as i64) != 0) {
        return -1;
      }
      return 0;
    }
    /* STRING_LIT (kind 59): emit C string or slice literal from e.var_name.
     * PLATFORM: SHARED — close this block comment before the if (wave323).
     * Root: unclosed block comment soft-skipped whole codegen_emit_expr on tip -E.
     */
    if (pipeline_expr_kind_ord_at(arena, expr_ref) == 59) {
      let slen: i32 = e.var_name_len;
      let emit_slice: bool = false;
      if (slen < 0) {
        slen = 0;
      }
      if (slen > 64) {
        slen = 64;
      }
      if (!ast.ref_is_null(e.resolved_type_ref) && e.resolved_type_ref > 0 && e.resolved_type_ref <= arena.num_types) {
        let sty: Type = ast.ast_arena_type_get(arena, e.resolved_type_ref);
        if ((sty.kind as i32) == (TypeKind.TYPE_SLICE as i32)) {
          emit_slice = true;
        }
      }
      /* See implementation. */
      let cast_open: u8[14] = [40, 40, 117, 105, 110, 116, 56, 95, 116, 32, 42, 41, 34, 0];
      if (emit_slice) {
        let slice_mid: u8[13] = [41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 40, 0];
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        if (codegen_emit_type(arena, out, e.resolved_type_ref, 0 as *u8, 0, ctx) != 0) {
          return -1;
        }
        if (codegen_emit_bytes_from_ptr(out, &slice_mid[0], 12) != 0) {
          return -1;
        }
      }
      if (codegen_emit_bytes_from_ptr(out, &cast_open[0], 13) != 0) {
        return -1;
      }
      let si: i32 = 0;
      while (si < slen) {
        let b: i32 = e.var_name[si] as i32;
        if (b < 0) {
          b = b + 256;
        }
        if (b > 255) {
          b = b & 255;
        }
        /* \xHH */
        if (codegen_append_byte(out, 92) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 120) != 0) {
          return -1;
        }
        let hi: i32 = b / 16;
        let lo: i32 = b - hi * 16;
        let hex: u8[17] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102, 0];
        if (codegen_append_byte(out, hex[hi]) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, hex[lo]) != 0) {
          return -1;
        }
        si = si + 1;
      }
      /* Close the C string quote and cast paren; slice path adds .length = N. */
      if (codegen_append_byte(out, 34) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 41) != 0) {
        return -1;
      }
      if (emit_slice) {
        let slice_tail: u8[18] = [32, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &slice_tail[0], 13) != 0) {
          return -1;
        }
        if (format_int(out, slen) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 32) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 125) != 0) {
          return -1;
        }
        return 0;
      }
      return 0;
    }
    if ((e.kind as i32) == (ExprKind.EXPR_LIT as i32)) {
      return format_int(out, e.int_val);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_BOOL_LIT as i32)) {
      if (e.int_val != 0) {
        return codegen_append_byte(out, 49);
      }
      return codegen_append_byte(out, 48);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_VAR as i32)) {
      /* See implementation. */
      if (e.var_name_len > 0 && (e.var_name[0] > 32)) {
        /* See implementation. */
        if (e.var_name_len == 3 && e.var_name[0] == 109 && e.var_name[1] == 115 && e.var_name[2] == 103 && ctx != 0 as *PipelineDepCtx) {
          let use_l0: bool = false;
          if (ctx.current_block_ref != 0 && ctx.current_block_ref <= arena.num_blocks) {
            if (ast_ast_block_num_lets(arena, ctx.current_block_ref) >= 1 && pipeline_block_let_name_len(arena, ctx.current_block_ref, 0) == 0) {
              use_l0 = true;
            }
          }
          if (use_l0) {
            let l0: u8[4] = [95, 108, 48, 0];
            return codegen_emit_bytes_4(out, &l0[0], 3);
          }
        }
        /*
         * wave707: match struct field bind → (subject).field before bare/fn-value emit.
         * PLATFORM: SHARED — G.7 with pipeline_codegen_match_* subject context.
         */
        {
          let mfb: i32 = codegen_try_emit_match_field_bind(arena, out, ctx, &e.var_name[0], e.var_name_len);
          if (mfb == 0) {
            return 0;
          }
          if (mfb < 0) {
            return 0 - 1;
          }
        }
        /*
         * wave101 soft residual: same-module bare function used as value (e.g. cast
         * `(f as *u8)`) must emit G.7 link symbol (module prefix + overload mangle),
         * not the bare source name. Locals keep bare emit via name_is_local_binding.
         * PLATFORM: SHARED — def/call/extern already use codegen_emit_func_link_name.
         */
        let fn_val: i32 = codegen_try_emit_fn_as_value(out, arena, ctx, &e.var_name[0], e.var_name_len);
        if (fn_val == 0) {
          return 0;
        }
        if (fn_val < 0) {
          return 0 - 1;
        }
        return codegen_emit_bytes_64(out, &e.var_name[0], e.var_name_len);
      }
      if (ctx != 0 as *PipelineDepCtx && ctx.emit_expr_as_callee != 0) {
        let fallback: u8[3] = [95, 48, 0];
        return codegen_emit_bytes_3(out, &fallback[0], 2);
      }
      if (ctx != 0 as *PipelineDepCtx) {
        if (ctx.current_func_single_empty_param_index >= 0) {
          let place: u8[4] = [95, 112, 48, 0];
          if (codegen_emit_bytes_4(out, &place[0], 2) != 0) {
            return -1;
          }
          return format_int(out, ctx.current_func_single_empty_param_index);
        }
        if (ctx.current_func_empty_param_count >= 2 && ctx.current_emit_empty_var_next_index < ctx.current_func_empty_param_count) {
          let param_idx: i32 = pipeline_dep_ctx_empty_param_at(ctx, ctx.current_emit_empty_var_next_index);
          let place: u8[4] = [95, 112, 48, 0];
          if (codegen_emit_bytes_4(out, &place[0], 2) != 0) {
            return -1;
          }
          if (format_int(out, param_idx) != 0) {
            return -1;
          }
          ctx.current_emit_empty_var_next_index = ctx.current_emit_empty_var_next_index + 1;
          return 0;
        }
      }
      let fallback: u8[3] = [95, 48, 0];
      return codegen_emit_bytes_3(out, &fallback[0], 2);
    }
    /*
     * wave459 Cap residual pure: host-C aggregate `as` cast.
     * Root: EXPR_AS always emitted `((TYPE)(op))`. C permits that only for
     * scalar/pointer targets; `((struct A)(x))` is rejected by host gcc
     * ("used type 'struct A' where arithmetic or pointer type is required")
     * → BLD001 (soft leave-off after wave458 multi-T mono / STRUCT_LIT path).
     * Fix: when target (after alias peel + mono subst) is a module user struct,
     * emit C99 compound literal `((TYPE){ (op) })` — initializes first field
     * (remaining fields zero). Matches product intent of `T { v: x }` for the
     * scalar→single-field-struct monomorphization probes (`as_t<A>(7)`).
     * Scalar/pointer targets keep the historical C cast path.
     *
     * wave461 Cap residual pure: compound literal only when the operand is
     * NOT already a module user struct. wave459 always wrapped op as the
     * first field, so `let b: A = a as A` / `a as B` emitted
     * `((struct A){ (a) })` → host C "initializing int32_t with struct A"
     * BLD001. Same-type struct op → identity `(op)`.
     *
     * wave462 Cap residual pure: struct-valued operand for *different* target
     * (A→B or struct→scalar) still failed host C — wave461 identity only works
     * when types match; `struct B b = (a)` is incompatible, `((int32_t)(a))`
     * needs arithmetic/pointer. Root: no legal host emit for layout-compatible
     * reinterpret. Fix (same EXPR_AS authority): when op is module user struct
     * and types are not equal, emit GNU statement-expression type-pun used
     * elsewhere in host-C (call-array temps): 
     * `({ OP_TY __xlang_as_o = (op); *(TGT *)(void *)&__xlang_as_o; })`.
     * Same-type keeps identity; scalar→struct keeps compound; scalar→scalar cast.
     * G.7: EXPR_AS only; reuse codegen_mono_subst_type +
     * codegen_type_is_module_user_struct + pipeline_expr_resolved_type_ref +
     * pipeline_typeck_type_refs_equal_c (no second cast path).
     * PLATFORM: SHARED host-C emit (GNU stmt-expr; product host gcc/clang).
     */
    if ((e.kind as i32) == (ExprKind.EXPR_AS as i32)) {
      let as_tgt: i32 = e.as_target_type_ref;
      if (!ast.ref_is_null(as_tgt)) {
        as_tgt = pipeline_typeck_resolve_type_alias_ref_c(arena, as_tgt);
        as_tgt = codegen_mono_subst_type(ctx, arena, as_tgt);
      }
      /*
       * Aggregate ascription (`[lit] as []T` / `as [N]T`): C cast of an
       * array/slice is BLD001. Identity-emit the operand so ARRAY_LIT uses
       * the existing SLICE fat / TYPE_ARRAY braced paths (typeck stamps
       * ARRAY_LIT SLICE for `as []T`). Scalar/ptr `as` stays below.
       * G.7: no second fat builder. PLATFORM: SHARED host-C emit.
       */
      if (!ast.ref_is_null(as_tgt)) {
        let as_tk: i32 = pipeline_type_kind_ord_at(arena, as_tgt);
        if (as_tk == (TypeKind.TYPE_SLICE as i32) || as_tk == (TypeKind.TYPE_ARRAY as i32)) {
          if (!ast.ref_is_null(e.as_operand_ref)) {
            return codegen_emit_expr(arena, out, e.as_operand_ref, ctx);
          }
          return -1;
        }
      }
      let as_struct: i32 = 0;
      if (!ast.ref_is_null(as_tgt) && ctx != 0 as *PipelineDepCtx
          && ctx.current_codegen_module != 0 as *Module
          && codegen_type_is_module_user_struct(ctx.current_codegen_module, arena, as_tgt) != 0) {
        as_struct = 1;
      }
      /* wave461/462: resolve operand type (alias + mono); detect module user struct. */
      let op_ty: i32 = 0;
      let as_op_struct: i32 = 0;
      if (!ast.ref_is_null(e.as_operand_ref) && ctx != 0 as *PipelineDepCtx
          && ctx.current_codegen_module != 0 as *Module) {
        op_ty = pipeline_expr_resolved_type_ref(arena, e.as_operand_ref);
        if (!ast.ref_is_null(op_ty)) {
          op_ty = pipeline_typeck_resolve_type_alias_ref_c(arena, op_ty);
          op_ty = codegen_mono_subst_type(ctx, arena, op_ty);
          if (!ast.ref_is_null(op_ty)
              && codegen_type_is_module_user_struct(ctx.current_codegen_module, arena, op_ty) != 0) {
            as_op_struct = 1;
          }
        }
      }
      /* Same-type struct op + struct target: identity value copy `(op)`. */
      if (as_struct != 0 && as_op_struct != 0
          && !ast.ref_is_null(op_ty) && !ast.ref_is_null(as_tgt)
          && pipeline_typeck_type_refs_equal_c(arena, op_ty, as_tgt) != 0) {
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        if (!ast.ref_is_null(e.as_operand_ref) && codegen_emit_expr(arena, out, e.as_operand_ref, ctx) != 0) {
          return -1;
        }
        return codegen_append_byte(out, 41);
      }
      /*
       * wave462: struct-valued op → different type (A→B or struct→scalar/pointer).
       * Host cannot cast or assign across struct types; layout-compatible
       * reinterpret via address-of temp (GNU stmt-expr, already used for
       * __xlang_ca / __xlang_sp deep-copy paths).
       * Form: ({ OP_TY __xlang_as_o = (op); *(TGT *)(void *)&__xlang_as_o; })
       */
      if (as_op_struct != 0 && !ast.ref_is_null(op_ty)) {
        /* ({  */
        let as_pun_open: u8[4] = [40, 123, 32, 0];
        if (codegen_emit_bytes_from_ptr(out, &as_pun_open[0], 3) != 0) {
          return -1;
        }
        if (codegen_emit_type(arena, out, op_ty, 0 as *u8, 0, ctx) != 0) {
          return -1;
        }
        /*  __xlang_as_o = ( */
        let as_pun_nm: u8[20] = [
          32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 115, 95, 111, 32, 61, 32, 40, 0, 0, 0
        ];
        if (codegen_emit_bytes_from_ptr(out, &as_pun_nm[0], 17) != 0) {
          return -1;
        }
        if (!ast.ref_is_null(e.as_operand_ref) && codegen_emit_expr(arena, out, e.as_operand_ref, ctx) != 0) {
          return -1;
        }
        /* ); *( */
        let as_pun_mid: u8[8] = [41, 59, 32, 42, 40, 0, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &as_pun_mid[0], 5) != 0) {
          return -1;
        }
        if (codegen_emit_type(arena, out, e.as_target_type_ref, 0 as *u8, 0, ctx) != 0) {
          return -1;
        }
        /*  *)(void *)&__xlang_as_o; }) */
        let as_pun_end: u8[32] = [
          32, 42, 41, 40, 118, 111, 105, 100, 32, 42, 41, 38, 95, 95, 120, 108,
          97, 110, 103, 95, 97, 115, 95, 111, 59, 32, 125, 41, 0, 0, 0, 0
        ];
        if (codegen_emit_bytes_from_ptr(out, &as_pun_end[0], 28) != 0) {
          return -1;
        }
        return 0;
      }
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_type(arena, out, e.as_target_type_ref, 0 as *u8, 0, ctx) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 41) != 0) {
        return -1;
      }
      if (as_struct != 0) {
        /* Compound literal: (TYPE){ (op) } — scalar/non-struct op only (wave461). */
        if (codegen_append_byte(out, 123) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 32) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        if (!ast.ref_is_null(e.as_operand_ref) && codegen_emit_expr(arena, out, e.as_operand_ref, ctx) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 41) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 32) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 125) != 0) {
          return -1;
        }
        return codegen_append_byte(out, 41);
      }
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.as_operand_ref) && codegen_emit_expr(arena, out, e.as_operand_ref, ctx) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 41) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 41) != 0) {
        return -1;
      }
      return 0;
    }
    if ((e.kind as i32) == (ExprKind.EXPR_RETURN as i32)) {
      let op: u8[9] = [114, 101, 116, 117, 114, 110, 32, 0, 0];
      if (codegen_emit_bytes_9(out, &op[0], 7) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.unary_operand_ref) && codegen_emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
        return -1;
      }
      return 0;
    }
    if ((e.kind as i32) == (ExprKind.EXPR_BLOCK as i32)) {
      let open: u8[4] = [40, 123, 32, 0];
      if (codegen_emit_bytes_4(out, &open[0], 3) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.block_ref) && codegen_emit_block(arena, out, e.block_ref, 2, ctx) != 0) {
        return -1;
      }
      let tail: u8[8] = [32, 125, 41, 0, 0, 0, 0, 0];
      return codegen_emit_bytes_8(out, &tail[0], 3);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_ADD as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 43, 32, 0];
      if (codegen_emit_bytes_4(out, &op[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_SUB as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 45, 32, 0];
      if (codegen_emit_bytes_4(out, &op[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_ASSIGN as i32)) {
      /*
       * wave334 Cap residual pure: fixed TYPE_ARRAY whole-array assign.
       * Root: C arrays are not assignable — host gcc rejects
       *   `int32_t a[3] = {…}; (void)((a = (int32_t[]){…}));`
       * Emit memcpy into the array storage instead.
       * Form: (memcpy((void*)(lhs), (const void*)(rhs), sizeof(lhs)))
       * G.7 single host-C authority; freestanding uses direct slot write in glue.
       * PLATFORM: SHARED host-C emit.
       */
      let lt_ref: i32 = pipeline_expr_resolved_type_ref(arena, e.binop_left_ref);
      let is_fa: i32 = 0;
      if (lt_ref > 0 && pipeline_type_kind_ord_at(arena, lt_ref) == (TypeKind.TYPE_ARRAY as i32)) {
        is_fa = 1;
      }
      /*
       * [N]T → []T assign: stack-view fat. Same frame as let s = a (no escape).
       * Do not stamp SLICE — RHS stays TYPE_ARRAY so .data is the array.
       * PLATFORM: SHARED host-C. G.7 reuse fat compound (try_emit / call-arg).
       * Seed twin: codegen_gen.linux.x86_64.c (live `-E` is host-cc of that seed).
       * Do not fork a second dest-SLICE ASSIGN ARRAY wrap.
       */
      if (lt_ref > 0 && pipeline_type_kind_ord_at(arena, lt_ref) == (TypeKind.TYPE_SLICE as i32)) {
        let rt_as: i32 = pipeline_expr_resolved_type_ref(arena, e.binop_right_ref);
        let as_n: i32 = 0;
        if (rt_as > 0 && pipeline_type_kind_ord_at(arena, rt_as) == (TypeKind.TYPE_ARRAY as i32)) {
          as_n = pipeline_type_array_size_at(arena, rt_as);
        }
        if (as_n > 0) {
          if (codegen_append_byte(out, 40) != 0) {
            return -1;
          }
          if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
            return -1;
          }
          let as_eq: u8[4] = [32, 61, 32, 40];
          if (codegen_emit_bytes_4(out, &as_eq[0], 4) != 0) {
            return -1;
          }
          if (codegen_emit_type(arena, out, lt_ref, 0 as *u8, 0, ctx) != 0) {
            return -1;
          }
          let as_d: u8[12] = [41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 0];
          if (codegen_emit_bytes_from_ptr(out, &as_d[0], 11) != 0) {
            return -1;
          }
          if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
            return -1;
          }
          let as_l: u8[16] = [44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &as_l[0], 12) != 0) {
            return -1;
          }
          if (format_int(out, as_n as i64) != 0) {
            return -1;
          }
          let as_c: u8[4] = [32, 125, 41, 0];
          if (codegen_emit_bytes_4(out, &as_c[0], 3) != 0) {
            return -1;
          }
          return 0;
        }
      }
      if (is_fa != 0) {
        let pref: u8[16] = [109, 101, 109, 99, 112, 121, 40, 40, 118, 111, 105, 100, 42, 41, 40, 0];
        let mid: u8[20] = [41, 44, 32, 40, 99, 111, 110, 115, 116, 32, 118, 111, 105, 100, 42, 41, 40, 0, 0, 0];
        let mid_sz: u8[12] = [41, 44, 32, 115, 105, 122, 101, 111, 102, 40, 0, 0];
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        if (codegen_emit_bytes_from_ptr(out, &pref[0], 15) != 0) {
          return -1;
        }
        if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
          return -1;
        }
        if (codegen_emit_bytes_from_ptr(out, &mid[0], 17) != 0) {
          return -1;
        }
        if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
          return -1;
        }
        if (codegen_emit_bytes_from_ptr(out, &mid_sz[0], 10) != 0) {
          return -1;
        }
        if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 41) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 41) != 0) {
          return -1;
        }
        return codegen_append_byte(out, 41);
      }
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 61, 32, 0];
      if (codegen_emit_bytes_4(out, &op[0], 3) != 0) {
        return -1;
      }
      /* F2: TYPE_DYN LHS + concrete (non-null-sentinel) RHS assign -> wrap
       * RHS in fat-ptr compound literal. Twin of let-emit dyn_wrap path.
       * F3: vtable now built from trait methods via codegen_emit_dyn_vtable_close.
       * PLATFORM: SHARED host-C. */
      let dyn_wrap: i32 = 0;
      let lt_dyn: i32 = pipeline_typeck_resolve_type_alias_ref_c(arena, lt_ref);
      if (lt_dyn > 0 && pipeline_type_kind_ord_at(arena, lt_dyn) == (TypeKind.TYPE_DYN as i32)) {
        let rhs_rt: i32 = pipeline_expr_resolved_type_ref(arena, e.binop_right_ref);
        if (typeck_dyn_rhs_is_null_sentinel(arena, rhs_rt, e.binop_right_ref) == 0) {
          dyn_wrap = 1;
          /*
           * F5 PTR-to-NAMED for-type: when RHS is itself a pointer (TYPE_PTR),
           * do NOT take address-of — data IS the pointer (matches impl self: *T
           * for impl Trait for *T). For by-value RHS, keep & so data becomes a
           * pointer to the value (matches impl self: *T for impl Trait for T).
           * Byte layout: "(struct xlang_dyn_obj){ .data = " (32 bytes) + "&("
           * (2 bytes) for by-value, or "(" (1 byte) for by-pointer RHS.
           * PLATFORM: SHARED host-C; seed codegen_gen.linux.x86_64.c mirrors.
           */
          let dyn_open: u8[34] = [40, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 100, 121, 110, 95, 111, 98, 106, 41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 38, 40];
          let rhs_kind_ord: i32 = pipeline_type_kind_ord_at(arena, rhs_rt);
          if (rhs_kind_ord == (TypeKind.TYPE_PTR as i32)) {
            /* Skip byte 32 (the &); emit bytes 0..31 + byte 33 (the open paren). */
            if (codegen_emit_bytes_from_ptr(out, &dyn_open[0], 32) != 0) {
              return -1;
            }
            if (codegen_append_byte(out, dyn_open[33]) != 0) {
              return -1;
            }
          } else {
            /*
             * F6: Builtin by-value RHS — emit "&((<C-type>){" so & has a
             * valid lvalue (compound literal). codegen_emit_dyn_vtable_close
             * closes with "}". Non-builtin by-value keeps the F2 "&(" path
             * (NAMED RHS has storage).
             * PLATFORM: SHARED host-C; seed codegen_gen.linux.x86_64.c mirrors.
             */
            let bnm: u8[16] = [];
            let blen: i32 = codegen_builtin_type_name_into(rhs_kind_ord, &bnm[0]);
            if (blen > 0) {
              /* Emit "(struct xlang_dyn_obj){ .data = " — 32 bytes (dyn_open 0..31). */
              if (codegen_emit_bytes_from_ptr(out, &dyn_open[0], 32) != 0) { return -1; }
              /* Emit "&((" — 3 bytes. */
              if (codegen_append_byte(out, 38) != 0) { return -1; }
              if (codegen_append_byte(out, 40) != 0) { return -1; }
              if (codegen_append_byte(out, 40) != 0) { return -1; }
              /* Emit the C type (int32_t/f64/...). */
              if (codegen_emit_type_kind(out, rhs_kind_ord) != 0) { return -1; }
              /* Emit "){" — 2 bytes (close cast + open compound literal). */
              if (codegen_append_byte(out, 41) != 0) { return -1; }
              if (codegen_append_byte(out, 123) != 0) { return -1; }
            } else {
              if (codegen_emit_bytes_from_ptr(out, &dyn_open[0], 34) != 0) {
                return -1;
              }
            }
          }
        }
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      if (dyn_wrap != 0) {
        let rhs_rt: i32 = pipeline_expr_resolved_type_ref(arena, e.binop_right_ref);
        if (codegen_emit_dyn_vtable_close(arena, out, ctx, lt_dyn, rhs_rt) != 0) {
          return -1;
        }
      }
      return codegen_append_byte(out, 41);
    }
    /* See implementation. */
    if ((e.kind as i32) == (ExprKind.EXPR_ADD_ASSIGN as i32) || (e.kind as i32) == (ExprKind.EXPR_SUB_ASSIGN as i32) || (e.kind as i32) == (ExprKind.EXPR_MUL_ASSIGN as i32) || (e.kind as i32) == (ExprKind.EXPR_DIV_ASSIGN as i32) || (e.kind as i32) == (ExprKind.EXPR_MOD_ASSIGN as i32)
        || (e.kind as i32) == (ExprKind.EXPR_BITAND_ASSIGN as i32) || (e.kind as i32) == (ExprKind.EXPR_BITOR_ASSIGN as i32) || (e.kind as i32) == (ExprKind.EXPR_BITXOR_ASSIGN as i32) || (e.kind as i32) == (ExprKind.EXPR_SHL_ASSIGN as i32) || (e.kind as i32) == (ExprKind.EXPR_SHR_ASSIGN as i32)) {
      let op_buf: u8[8] = [32, 43, 61, 32, 0, 0, 0, 0];
      let op_len: i32 = 4;
      if ((e.kind as i32) == (ExprKind.EXPR_ADD_ASSIGN as i32)) {
        op_buf[1] = 43;
        op_buf[2] = 61;
        op_len = 4;
      }
      if ((e.kind as i32) == (ExprKind.EXPR_SUB_ASSIGN as i32)) {
        op_buf[1] = 45;
        op_buf[2] = 61;
        op_len = 4;
      }
      if ((e.kind as i32) == (ExprKind.EXPR_MUL_ASSIGN as i32)) {
        op_buf[1] = 42;
        op_buf[2] = 61;
        op_len = 4;
      }
      if ((e.kind as i32) == (ExprKind.EXPR_DIV_ASSIGN as i32)) {
        op_buf[1] = 47;
        op_buf[2] = 61;
        op_len = 4;
      }
      if ((e.kind as i32) == (ExprKind.EXPR_MOD_ASSIGN as i32)) {
        op_buf[1] = 37;
        op_buf[2] = 61;
        op_len = 4;
      }
      if ((e.kind as i32) == (ExprKind.EXPR_BITAND_ASSIGN as i32)) {
        op_buf[1] = 38;
        op_buf[2] = 61;
        op_len = 4;
      }
      if ((e.kind as i32) == (ExprKind.EXPR_BITOR_ASSIGN as i32)) {
        op_buf[1] = 124;
        op_buf[2] = 61;
        op_len = 4;
      }
      if ((e.kind as i32) == (ExprKind.EXPR_BITXOR_ASSIGN as i32)) {
        op_buf[1] = 94;
        op_buf[2] = 61;
        op_len = 4;
      }
      if ((e.kind as i32) == (ExprKind.EXPR_SHL_ASSIGN as i32)) {
        op_buf[1] = 60;
        op_buf[2] = 60;
        op_buf[3] = 61;
        op_buf[4] = 32;
        op_len = 5;
      }
      if ((e.kind as i32) == (ExprKind.EXPR_SHR_ASSIGN as i32)) {
        op_buf[1] = 62;
        op_buf[2] = 62;
        op_buf[3] = 61;
        op_buf[4] = 32;
        op_len = 5;
      }
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      /* See implementation. */
      if (codegen_emit_bytes_8(out, &op_buf[0], op_len) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_NEG as i32)) {
      let pre: u8[3] = [45, 40, 0];
      if (codegen_emit_bytes_3(out, &pre[0], 2) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    /* See implementation. */
    if ((e.kind as i32) == (ExprKind.EXPR_ADDR_OF as i32)) {
      let pre_a: u8[3] = [38, 40, 0];
      if (codegen_emit_bytes_3(out, &pre_a[0], 2) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    /* See implementation. */
    if ((e.kind as i32) == (ExprKind.EXPR_DEREF as i32)) {
      let pre_d: u8[3] = [42, 40, 0];
      if (codegen_emit_bytes_3(out, &pre_d[0], 2) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    /* TRY_PROPAGATE: emit ({ Result_T tmp = op; if (tmp.err != 0) { return tmp; } tmp.value; }).
     * PLATFORM: SHARED host-C statement-expression shape (wave323).
     * Root: orphan comment lines after a closed block soft-skipped codegen_emit_expr on tip -E.
     */
    if ((e.kind as i32) == (ExprKind.EXPR_TRY_PROPAGATE as i32)) {
      let op_ref: i32 = e.unary_operand_ref;
      let op_ty_ref: i32 = 0;
      let open: u8[4] = [40, 123, 32, 0];
      let tmp_name: u8[16] = [95, 95, 120, 108, 97, 110, 103, 95, 116, 114, 121, 95, 116, 109, 112, 0];
      let assign_mid: u8[5] = [32, 61, 32, 0, 0];
      let if_open: u8[38] = [59, 32, 105, 102, 32, 40, 40, 95, 95, 120, 108, 97, 110, 103, 95, 116, 114, 121, 95, 116, 109, 112, 41, 46, 101, 114, 114, 32, 33, 61, 32, 48, 41, 32, 123, 32, 114, 101];
      let turn_mid: u8[41] = [116, 117, 114, 110, 32, 95, 95, 120, 108, 97, 110, 103, 95, 116, 114, 121, 95, 116, 109, 112, 59, 32, 125, 32, 40, 95, 95, 120, 108, 97, 110, 103, 95, 116, 114, 121, 95, 116, 109, 112, 0];
      let value_tail: u8[7] = [41, 46, 118, 97, 108, 117, 101];
      let close_tail: u8[4] = [59, 32, 125, 41];
      if (ast.ref_is_null(op_ref) || op_ref <= 0 || op_ref > arena.num_exprs) {
        return -1;
      }
      op_ty_ref = pipeline_expr_resolved_type_ref(arena, op_ref);
      if (ast.ref_is_null(op_ty_ref)) {
        return -1;
      }
      if (codegen_emit_bytes_4(out, &open[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_type(arena, out, op_ty_ref, 0 as *u8, 0, ctx) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 32) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_from_ptr(out, &tmp_name[0], 14) != 0) {
        return -1;
      }
      if (emit_bytes_5(out, &assign_mid[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, op_ref, ctx) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_from_ptr(out, &if_open[0], 37) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_from_ptr(out, &turn_mid[0], 38) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_from_ptr(out, &value_tail[0], 7) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_4(out, &close_tail[0], 4) != 0) {
        return -1;
      }
      return 0;
    }
    if ((e.kind as i32) == (ExprKind.EXPR_AWAIT as i32)) {
      if (!ast.ref_is_null(e.unary_operand_ref) && codegen_emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
        return -1;
      }
      return 0;
    }
    if ((e.kind as i32) == (ExprKind.EXPR_RUN as i32) || (e.kind as i32) == (ExprKind.EXPR_SPAWN as i32)) {
      let op_ref: i32 = e.unary_operand_ref;
      let dep_ix: i32 = -1;
      let func_ix: i32 = -1;
      let target_mod: *Module = 0 as *Module;
      let n_args: i32 = 0;
      let num_params: i32 = 0;
      let ai: i32 = 0;
      let op_is_call: i32 = 0;
      let reset_name: u8[26] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 114, 101, 115, 101, 116];
      let comma: u8[3] = [44, 32, 0];
      if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module) {
        return -1;
      }
      if (ast.ref_is_null(op_ref) || op_ref <= 0 || op_ref > arena.num_exprs) {
        return -1;
      }
      let op: Expr = ast.ast_arena_expr_get(arena, op_ref);
      if ((op.kind as i32) == (ExprKind.EXPR_CALL as i32)) {
        op_is_call = 1;
      } else if ((op.kind as i32) != (ExprKind.EXPR_METHOD_CALL as i32)) {
        return -1;
      }
      if ((e.kind as i32) == (ExprKind.EXPR_RUN as i32) && (op.kind as i32) == (ExprKind.EXPR_METHOD_CALL as i32) && codegen_emit_async_method_call_run(arena, out, op_ref, ctx) == 0) {
        return 0;
      }
      if (op_is_call != 0 && op.call_callee_ref > 0 && op.call_callee_ref <= arena.num_exprs) {
        let fast_callee: Expr = ast.ast_arena_expr_get(arena, op.call_callee_ref);
        if ((fast_callee.kind as i32) == (ExprKind.EXPR_FIELD_ACCESS as i32) && codegen_emit_async_binding_import_call(arena, out, op_ref, ctx, if ((e.kind as i32) == (ExprKind.EXPR_SPAWN as i32)) { 1 } else { 0 }) == 0) {
          return 0;
        }
      }
      dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, op_ref);
      if (dep_ix < 0 && op_is_call != 0) {
        dep_ix = codegen_resolve_binding_import_dep_index(ctx, arena, op.call_callee_ref);
      }
      if (dep_ix >= 0) {
        /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
        let ndep_op: i32 = pipeline_dep_ctx_ndep(ctx);
        if (dep_ix >= ndep_op) {
          return -1;
        }
        target_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
      } else {
        target_mod = ctx.current_codegen_module;
      }
      if (target_mod != 0 as *Module) {
        func_ix = codegen_resolve_call_target_func_index(arena, target_mod, op_ref);
      }
      if (dep_ix >= 0 && (target_mod == 0 as *Module || func_ix < 0 || func_ix >= target_mod.num_funcs)) {
        return codegen_emit_async_binding_import_call(arena, out, op_ref, ctx, if ((e.kind as i32) == (ExprKind.EXPR_SPAWN as i32)) { 1 } else { 0 });
      }
      if (target_mod == 0 as *Module) {
        return -1;
      }
      if (func_ix < 0 || func_ix >= target_mod.num_funcs) {
        return -1;
      }
      if (op_is_call != 0) {
        n_args = op.call_num_args;
      } else {
        n_args = op.method_call_num_args;
      }
      if (n_args < 0) {
        return -1;
      }
      num_params = pipeline_module_func_num_params_at(target_mod, func_ix);
      if ((e.kind as i32) == (ExprKind.EXPR_RUN as i32)) {
        if (n_args > 0) {
          if (codegen_append_byte(out, 40) != 0) {
            return -1;
          }
          if (codegen_emit_bytes_from_ptr(out, &reset_name[0], 25) != 0) {
            return -1;
          }
          if (codegen_append_byte(out, 40) != 0) {
            return -1;
          }
          if (codegen_append_byte(out, 41) != 0) {
            return -1;
          }
          ai = 0;
          while (ai < n_args) {
            let arg_ref: i32 = 0;
            let param_type_ref: i32 = 0;
            if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
              return -1;
            }
            if (op_is_call != 0) {
              arg_ref = pipeline_expr_call_arg_ref(arena, op_ref, ai);
            } else {
              arg_ref = pipeline_expr_method_call_arg_ref(arena, op_ref, ai);
            }
            if (ai < num_params) {
              param_type_ref = pipeline_module_func_param_type_ref_at(target_mod, func_ix, ai);
            }
            if (codegen_emit_async_run_seed_push_name(out, arena, param_type_ref) != 0) {
              return -1;
            }
            if (codegen_append_byte(out, 40) != 0) {
              return -1;
            }
            if (!ast.ref_is_null(arg_ref) && codegen_emit_expr(arena, out, arg_ref, ctx) != 0) {
              return -1;
            }
            if (codegen_append_byte(out, 41) != 0) {
              return -1;
            }
            ai = ai + 1;
          }
          if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
            return -1;
          }
          if (codegen_emit_async_sched_call(out, target_mod, func_ix) != 0) {
            return -1;
          }
          return codegen_append_byte(out, 41);
        }
        return codegen_emit_async_sched_call(out, target_mod, func_ix);
      }
      if (n_args > 0) {
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        ai = 0;
        while (ai < n_args) {
          let arg_ref2: i32 = 0;
          let param_type_ref2: i32 = 0;
          if (ai > 0 && codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
            return -1;
          }
          if (op_is_call != 0) {
            arg_ref2 = pipeline_expr_call_arg_ref(arena, op_ref, ai);
          } else {
            arg_ref2 = pipeline_expr_method_call_arg_ref(arena, op_ref, ai);
          }
          if (ai < num_params) {
            param_type_ref2 = pipeline_module_func_param_type_ref_at(target_mod, func_ix, ai);
          }
          if (codegen_emit_async_run_seed_push_name(out, arena, param_type_ref2) != 0) {
            return -1;
          }
          if (codegen_append_byte(out, 40) != 0) {
            return -1;
          }
          if (!ast.ref_is_null(arg_ref2) && codegen_emit_expr(arena, out, arg_ref2, ctx) != 0) {
            return -1;
          }
          if (codegen_append_byte(out, 41) != 0) {
            return -1;
          }
          ai = ai + 1;
        }
        if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
          return -1;
        }
        if (codegen_emit_async_task_submit_call(out, target_mod, func_ix) != 0) {
          return -1;
        }
        return codegen_append_byte(out, 41);
      }
      return codegen_emit_async_task_submit_call(out, target_mod, func_ix);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_IF as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.if_cond_ref) && codegen_emit_expr(arena, out, e.if_cond_ref, ctx) != 0) {
        return -1;
      }
      let q: u8[4] = [32, 63, 32, 0];
      if (codegen_emit_bytes_4(out, &q[0], 3) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.if_then_ref) && codegen_emit_expr(arena, out, e.if_then_ref, ctx) != 0) {
        return -1;
      }
      let colon: u8[4] = [32, 58, 32, 0];
      if (codegen_emit_bytes_4(out, &colon[0], 3) != 0) {
        return -1;
      }
      /* See implementation. */
      if (!ast.ref_is_null(e.if_else_ref)) {
        if (codegen_emit_expr(arena, out, e.if_else_ref, ctx) != 0) {
          return -1;
        }
      } else {
        if (codegen_append_byte(out, 48) != 0) {
          return -1;
        }
      }
      return codegen_append_byte(out, 41);
    }
    /* See implementation. */
    if ((e.kind as i32) == (ExprKind.EXPR_CALL as i32)) {
      let callee_ref: i32 = e.call_callee_ref;
      /* PLATFORM: SHARED — fmt/debug println("…") single-arg string-lit specialization. */
      if (ctx != 0 as *PipelineDepCtx) {
        let fmt_lit_rc: i32 = codegen_try_emit_fmt_string_lit_call(arena, out, expr_ref, ctx);
        if (fmt_lit_rc < 0) {
          return -1;
        }
        if (fmt_lit_rc > 0) {
          return 0;
        }
      }
      /* wave463: size_of<T>/align_of<T> → sizeof/_Alignof (CORE-001; before bare call). */
      if (ctx != 0 as *PipelineDepCtx) {
        let sa_rc: i32 = codegen_try_emit_size_align_of_call(arena, out, expr_ref, ctx);
        if (sa_rc < 0) {
          return -1;
        }
        if (sa_rc > 0) {
          return 0;
        }
      }
      /* stage10 S3.1 slice1 (10.1.1): raw_syscall0..6 → __xlang_raw_syscallN
       * (Linux x86_64 kernel ABI; before bare call, after size_of authority). */
      if (ctx != 0 as *PipelineDepCtx) {
        let rs_rc: i32 = codegen_try_emit_raw_syscall_call(arena, out, expr_ref, ctx);
        if (rs_rc < 0) {
          return -1;
        }
        if (rs_rc > 0) {
          return 0;
        }
      }
      /* Cap 10.7.1 slice7: va_start/end/copy/va_arg_* → xlang_va_* macros. */
      if (ctx != 0 as *PipelineDepCtx) {
        let va_rc: i32 = codegen_try_emit_va_cap_call(arena, out, expr_ref, ctx);
        if (va_rc < 0) {
          return -1;
        }
        if (va_rc > 0) {
          return 0;
        }
      }
      /* 10.3.1 slice15: Cap *u8 CALL → ((Ret (*)(T…))(callee))(args).
       * Before import/bare; TYPE_FN declarator callees stay uncast.
       * PLATFORM: SHARED host-C. */
      if (ctx != 0 as *PipelineDepCtx) {
        let cap_call_rc: i32 = codegen_try_emit_cap_u8_call(arena, out, expr_ref, ctx);
        if (cap_call_rc < 0) {
          return -1;
        }
        if (cap_call_rc > 0) {
          return 0;
        }
      }
      /* See implementation. */
      if (!ast.ref_is_null(callee_ref) && callee_ref > 0 && callee_ref <= arena.num_exprs && ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module) {
        let sym_buf: u8[256] = [];
        let imp_j: i32 = -1;
        let sym_len: i32 = pipeline_asm_resolve_whole_import_qualified_symbol_c(arena, ctx.current_codegen_module, callee_ref, &sym_buf[0], &imp_j);
        if (sym_len > 0 && sym_len < 128) {
          /* Why: sym_buf holds "prefix_funcname". Split into prefix + funcname and mangle
             funcname for overloads. Invariant: callee must be FIELD_ACCESS or VAR; imp_j maps
             to dep module; if dep_mod_q is NULL fall back to whole-symbol emit. */
          let callee_q: Expr = ast.ast_arena_expr_get(arena, callee_ref);
          let fn_ptr_q: *u8 = 0 as *u8;
          let fn_len_q: i32 = 0;
          if ((callee_q.kind as i32) == (ExprKind.EXPR_FIELD_ACCESS as i32) && callee_q.field_access_field_len > 0) {
            fn_ptr_q = &callee_q.field_access_field_name[0];
            fn_len_q = callee_q.field_access_field_len;
          } else if ((callee_q.kind as i32) == (ExprKind.EXPR_VAR as i32) && callee_q.var_name_len > 0) {
            fn_ptr_q = &callee_q.var_name[0];
            fn_len_q = callee_q.var_name_len;
          }
          let dep_mod_q: *Module = 0 as *Module;
          /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
          let ndep_imp: i32 = pipeline_dep_ctx_ndep(ctx);
          if (imp_j >= 0 && imp_j < ndep_imp) {
            dep_mod_q = pipeline_dep_ctx_module_at(ctx, imp_j);
          }
          let mangled_emitted: i32 = 0;
          if (fn_len_q > 0 && fn_len_q <= sym_len && dep_mod_q != 0 as *Module) {
            let pre_len_q: i32 = sym_len - fn_len_q;
            if (pre_len_q > 0) {
              if (codegen_emit_bytes_from_ptr(out, &sym_buf[0], pre_len_q) != 0) {
                return -1;
              }
            }
            if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, dep_mod_q, fn_ptr_q, fn_len_q) != 0) {
              return -1;
            }
            mangled_emitted = 1;
          }
          if (mangled_emitted == 0) {
            if (codegen_emit_bytes_from_ptr(out, &sym_buf[0], sym_len) != 0) {
              return -1;
            }
          }
          if (codegen_append_byte(out, 40) != 0) {
            return -1;
          }
          let n_q: i32 = e.call_num_args;
          let ai_q: i32 = 0;
          while (ai_q < n_q) {
            if (ai_q > 0) {
              let comma_q: u8[3] = [44, 32, 0];
              if (codegen_emit_bytes_3(out, &comma_q[0], 2) != 0) {
                return -1;
              }
            }
            if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai_q))) {
              if (codegen_append_byte(out, 48) != 0) {
                return -1;
              }
            } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai_q), ctx) != 0) {
              return -1;
            }
            ai_q = ai_q + 1;
          }
          if (codegen_append_byte(out, 41) != 0) {
            return -1;
          }
          return 0;
        }
      }
      /* See implementation. */
      if (!ast.ref_is_null(callee_ref) && callee_ref > 0 && callee_ref <= arena.num_exprs && ctx != 0 as *PipelineDepCtx && pipeline_dep_ctx_ndep(ctx) > 0) {
        let dep_ix_fast: i32 = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
        let callee_fast: Expr = ast.ast_arena_expr_get(arena, callee_ref);
        /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
        let ndep_fast: i32 = pipeline_dep_ctx_ndep(ctx);
        if (dep_ix_fast >= 0 && dep_ix_fast < ndep_fast && (callee_fast.kind as i32) == (ExprKind.EXPR_FIELD_ACCESS as i32) && callee_fast.field_access_field_len > 0) {
          let dep_mod_chk: *Module = pipeline_dep_ctx_module_at(ctx, dep_ix_fast);
          let field_in_dep: i32 = 0;
          if (dep_mod_chk != 0 as *Module) {
            let fi_c: i32 = 0;
            while (fi_c < dep_mod_chk.num_funcs) {
              let fl: i32 = pipeline_module_func_name_len_at(dep_mod_chk, fi_c);
              if (fl == callee_fast.field_access_field_len && fl > 0) {
                let fnc: u8[256] = [];
                pipeline_module_func_name_copy64(dep_mod_chk, fi_c, &fnc[0]);
                let eqc: i32 = 1;
                let ic: i32 = 0;
                while (ic < fl) {
                  if (fnc[ic] != callee_fast.field_access_field_name[ic]) {
                    eqc = 0;
                    ic = fl;
                  } else {
                    ic = ic + 1;
                  }
                }
                if (eqc != 0) {
                  field_in_dep = 1;
                  fi_c = dep_mod_chk.num_funcs;
                } else {
                  fi_c = fi_c + 1;
                }
              } else {
                fi_c = fi_c + 1;
              }
            }
          }
          if (field_in_dep != 0) {
          let dep_path_fast: u8[256] = [];
          pipeline_dep_ctx_import_path_copy64(ctx, dep_ix_fast, &dep_path_fast[0]);
          let pre_fast: u8[256] = [];
          codegen_import_path_to_c_prefix_into(&dep_path_fast[0], &pre_fast[0], 128);
          let pre_fast_len: i32 = 0;
          while (pre_fast_len < 128 && pre_fast[pre_fast_len] != 0) {
            pre_fast_len = pre_fast_len + 1;
          }
          /* See implementation. */
          let drv_buf_fast: i32 = 0;
          if (codegen_path_is_std_io_driver_bytes(&dep_path_fast[0]) != 0) {
            drv_buf_fast = codegen_emit_io_driver_buf_call_name(out, &callee_fast.field_access_field_name[0], callee_fast.field_access_field_len, e.call_num_args);
            if (drv_buf_fast < 0) {
              return -1;
            }
          }
          if (drv_buf_fast == 0) {
            if (pre_fast_len > 0 && codegen_c_prefix_redundant_with_name(&pre_fast[0], pre_fast_len, &callee_fast.field_access_field_name[0], callee_fast.field_access_field_len) == 0 && codegen_emit_bytes_from_ptr(out, &pre_fast[0], pre_fast_len) != 0) {
              return -1;
            }
            /* See implementation. */
            let dep_mod_fast: *Module = pipeline_dep_ctx_module_at(ctx, dep_ix_fast);
            if (dep_mod_fast == 0 as *Module) {
              dep_mod_fast = ctx.current_codegen_module;
            }
            if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, dep_mod_fast, &callee_fast.field_access_field_name[0], callee_fast.field_access_field_len) != 0) {
              return -1;
            }
          }
          if (codegen_append_byte(out, 40) != 0) {
            return -1;
          }
          let ai_fast: i32 = 0;
          while (ai_fast < e.call_num_args) {
            if (ai_fast > 0) {
              let comma_fast: u8[3] = [44, 32, 0];
              if (codegen_emit_bytes_3(out, &comma_fast[0], 2) != 0) {
                return -1;
              }
            }
            if (drv_buf_fast != 0 && ai_fast == 0) {
              let cast_buf: u8[19] = [40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0];
              if (codegen_emit_bytes_from_ptr(out, &cast_buf[0], 18) != 0) {
                return -1;
              }
            }
            if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai_fast))) {
              if (codegen_append_byte(out, 48) != 0) {
                return -1;
              }
            } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai_fast), ctx) != 0) {
              return -1;
            }
            ai_fast = ai_fast + 1;
          }
          if (codegen_append_byte(out, 41) != 0) {
            return -1;
          }
          return 0;
          }
        }
      }
      if (!ast.ref_is_null(callee_ref) && callee_ref > 0 && callee_ref <= arena.num_exprs && ctx != 0 as *PipelineDepCtx && pipeline_dep_ctx_ndep(ctx) > 0 && ctx.current_codegen_module != 0 as *Module) {
        let callee: Expr = ast.ast_arena_expr_get(arena, callee_ref);
        let cur_mod: *Module = ctx.current_codegen_module;
        /* See implementation. */
        if ((callee.kind as i32) == (ExprKind.EXPR_FIELD_ACCESS as i32) && callee.field_access_base_ref > 0 && callee.field_access_base_ref <= arena.num_exprs) {
          let base: Expr = ast.ast_arena_expr_get(arena, callee.field_access_base_ref);
          if ((base.kind as i32) == (ExprKind.EXPR_VAR as i32) && base.var_name_len > 0 && base.var_name_len <= 63) {
            let j: i32 = 0;
            let nd_bind: i32 = pipeline_dep_ctx_ndep(ctx);
            let n_imp: i32 = codegen_module_num_imports(cur_mod);
            while (j < n_imp && j < nd_bind) {
              if (pipeline_module_import_kind_at(cur_mod, j) == 1) {
                let bind_len: i32 = pipeline_module_import_binding_name_len(cur_mod, j);
                if (bind_len != base.var_name_len) {
                  j = j + 1;
                  continue;
                }
                let eq: bool = true;
                let kk: i32 = 0;
                while (kk < base.var_name_len && kk < 64) {
                  if (base.var_name[kk] != pipeline_module_import_binding_name_byte_at(cur_mod, j, kk)) {
                    eq = false;
                    break;
                  }
                  kk = kk + 1;
                }
                if (eq) {
                  let dep_path_bind: u8[256] = [];
                  let dep_path_bind_len: i32 = codegen_module_import_path_len_at(cur_mod, j, &dep_path_bind[0]);
                  if (dep_path_bind_len <= 0) {
                    j = j + 1;
                    continue;
                  }
                  /* Why: use dep_mod not cur_mod; passing cur_mod misses free/bump overloads on main.
                     Invariant: dep_path_bind from cur_mod import table; dep_ix path-matched into dep_ctx.
                     Asm/Perf: codegen_find_dep_index_by_path is O(ndep); only when binding hits. */
                  let dep_ix_bind: i32 = codegen_find_dep_index_by_path(ctx, &dep_path_bind[0], dep_path_bind_len);
                  let dep_mod_bind: *Module = cur_mod;
                  /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
                  let ndep_ixb: i32 = pipeline_dep_ctx_ndep(ctx);
                  if (dep_ix_bind >= 0 && dep_ix_bind < ndep_ixb) {
                    dep_mod_bind = pipeline_dep_ctx_module_at(ctx, dep_ix_bind);
                  }
                  let pre_buf: u8[128] = [];
                  codegen_import_path_to_c_prefix_into(&dep_path_bind[0], &pre_buf[0], 128);
                  let pre_len: i32 = 0;
                  while (pre_len < 128 && pre_buf[pre_len] != 0) {
                    pre_len = pre_len + 1;
                  }
                  /* See implementation. */
                  let drv_buf_bind: i32 = 0;
                  if (codegen_path_is_std_io_driver_bytes(&dep_path_bind[0]) != 0) {
                    drv_buf_bind = codegen_emit_io_driver_buf_call_name(out, &callee.field_access_field_name[0], callee.field_access_field_len, e.call_num_args);
                    if (drv_buf_bind < 0) {
                      return -1;
                    }
                  }
                  if (drv_buf_bind == 0) {
                    /* See implementation. */
                    let bind_pre: i32 = pre_len;
                    if (dep_mod_bind != 0 as *Module && callee.field_access_field_len > 0) {
                      let fi_b: i32 = 0;
                      while (fi_b < dep_mod_bind.num_funcs) {
                        let fl: i32 = pipeline_module_func_name_len_at(dep_mod_bind, fi_b);
                        if (fl == callee.field_access_field_len && fl > 0) {
                          let fnb: u8[256] = [];
                          pipeline_module_func_name_copy64(dep_mod_bind, fi_b, &fnb[0]);
                          let eqb: i32 = 1;
                          let bi_b: i32 = 0;
                          while (bi_b < fl) {
                            if (fnb[bi_b] != callee.field_access_field_name[bi_b]) {
                              eqb = 0;
                              bi_b = fl;
                            } else {
                              bi_b = bi_b + 1;
                            }
                          }
                          if (eqb != 0) {
                            bind_pre = codegen_func_c_symbol_prefix_len(dep_mod_bind, fi_b, pre_len);
                            fi_b = dep_mod_bind.num_funcs;
                          } else {
                            fi_b = fi_b + 1;
                          }
                        } else {
                          fi_b = fi_b + 1;
                        }
                      }
                    }
                    if (bind_pre > 0 && codegen_c_prefix_redundant_with_name(&pre_buf[0], bind_pre, &callee.field_access_field_name[0], callee.field_access_field_len) == 0 && codegen_emit_bytes_from_ptr(out, &pre_buf[0], bind_pre) != 0) {
                      return -1;
                    }
                    if (callee.field_access_field_len > 0 && codegen_emit_call_func_name(out, arena, ctx, expr_ref, dep_mod_bind, &callee.field_access_field_name[0], callee.field_access_field_len) != 0) {
                      return -1;
                    }
                  }
                  if (codegen_append_byte(out, 40) != 0) {
                    return -1;
                  }
                  let n_dep: i32 = codegen_call_num_args_override(&pre_buf[0], pre_len, &callee.field_access_field_name[0], callee.field_access_field_len, e.call_num_args);
                  let ai: i32 = 0;
                  while (ai < n_dep) {
                    if (ai > 0) {
                      let comma: u8[3] = [44, 32, 0];
                      if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
                        return -1;
                      }
                    }
                    if (drv_buf_bind != 0 && ai == 0) {
                      let cast_buf: u8[19] = [40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0];
                      if (codegen_emit_bytes_from_ptr(out, &cast_buf[0], 18) != 0) {
                        return -1;
                      }
                    }
                    if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {
                      if (codegen_append_byte(out, 48) != 0) {
                        return -1;
                      }
                    } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) != 0) {
                      return -1;
                    }
                    ai = ai + 1;
                  }
                  if (codegen_append_byte(out, 41) != 0) {
                    return -1;
                  }
                  return 0;
                }
              }
              j = j + 1;
            }
          }
        }
        if ((callee.kind as i32) == (ExprKind.EXPR_VAR as i32) && callee.var_name_len > 0) {
          /* See implementation. */
          let j: i32 = 0;
          let nd_sel: i32 = pipeline_dep_ctx_ndep(ctx);
          let n_imp: i32 = codegen_module_num_imports(cur_mod);
          while (j < n_imp && j < nd_sel) {
            if (pipeline_module_import_kind_at(cur_mod, j) == 2) {
              let k: i32 = 0;
              let sel_cnt: i32 = pipeline_module_import_select_count_at(cur_mod, j);
              while (k < sel_cnt) {
                let sel_len: i32 = pipeline_module_import_select_name_len(cur_mod, j, k);
                if (sel_len == callee.var_name_len) {
                  let eq: bool = true;
                  let kk: i32 = 0;
                  while (kk < callee.var_name_len && kk < 64) {
                    if (callee.var_name[kk] != pipeline_module_import_select_name_byte_at(cur_mod, j, k, kk)) {
                      eq = false;
                      break;
                    }
                    kk = kk + 1;
                  }
                  if (eq) {
                    let dep_path_sel: u8[256] = [];
                    let dep_path_sel_len: i32 = codegen_module_import_path_len_at(cur_mod, j, &dep_path_sel[0]);
                    if (dep_path_sel_len <= 0) {
                      k = k + 1;
                      continue;
                    }
                    let pre_buf: u8[128] = [];
                    codegen_import_path_to_c_prefix_into(&dep_path_sel[0], &pre_buf[0], 128);
                    let pre_len: i32 = 0;
                    while (pre_len < 128 && pre_buf[pre_len] != 0) {
                      pre_len = pre_len + 1;
                    }
                    if (pre_len > 0 && codegen_c_prefix_redundant_with_name(&pre_buf[0], pre_len, callee.var_name, callee.var_name_len) == 0 && codegen_emit_bytes_from_ptr(out, &pre_buf[0], pre_len) != 0) {
                      return -1;
                    }
                    if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, cur_mod, &callee.var_name[0], callee.var_name_len) != 0) {
                      return -1;
                    }
                    if (codegen_append_byte(out, 40) != 0) {
                      return -1;
                    }
                    let n_dep: i32 = codegen_call_num_args_override(&pre_buf[0], pre_len, &callee.var_name[0], callee.var_name_len, e.call_num_args);
                    let ai: i32 = 0;
                    while (ai < n_dep) {
                      if (ai > 0) {
                        let comma: u8[3] = [44, 32, 0];
                        if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
                          return -1;
                        }
                      }
                      if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {
                        if (codegen_append_byte(out, 48) != 0) {
                          return -1;
                        }
                      } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) != 0) {
                        return -1;
                      }
                      ai = ai + 1;
                    }
                    if (codegen_append_byte(out, 41) != 0) {
                      return -1;
                    }
                    return 0;
                  }
                }
                k = k + 1;
              }
            }
            j = j + 1;
          }
          j = 0;
          let nd_call: i32 = pipeline_dep_ctx_ndep(ctx);
          /*
           * Local-first bare-name CALL (align pin seed).
           * Purpose: if current_codegen_module already defines the bare name
           *   (e.g. core.result.unwrap_or), do not scan earlier deps and steal
           *   a same-named symbol (core.option.unwrap_or → core_option_unwrap_or).
           * Authority: seeds/codegen_gen.linux.x86_64.c local_has_name before
           *   while (j < nd_call && local_has_name == 0).
           * Uses pipeline_module_func_name_* (not arena Func) — reliable for slim modules.
           * PLATFORM: SHARED — Cap force si co-emit matrix.
           */
          let local_has_name: i32 = 0;
          if (cur_mod != 0 as *Module && callee.var_name_len > 0) {
            let lfi: i32 = 0;
            while (lfi < cur_mod.num_funcs) {
              let lnl: i32 = pipeline_module_func_name_len_at(cur_mod, lfi);
              if (lnl == callee.var_name_len) {
                let lnm: u8[256] = [];
                pipeline_module_func_name_copy64(cur_mod, lfi, &lnm[0]);
                let leq: i32 = 1;
                let li: i32 = 0;
                while (li < lnl && li < 64) {
                  if (lnm[li] != callee.var_name[li]) {
                    leq = 0;
                    break;
                  }
                  li = li + 1;
                }
                if (leq != 0) {
                  local_has_name = 1;
                  break;
                }
              }
              lfi = lfi + 1;
            }
          }
          while (j < nd_call && local_has_name == 0) {
            let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, j);
            let dep_arena: *ASTArena = pipeline_dep_ctx_arena_at(ctx, j);
            if (dep_mod != 0 as *Module && dep_arena != 0 as *ASTArena && dep_mod.num_funcs > 0) {
              let fi: i32 = 0;
              while (fi < dep_mod.num_funcs) {
                /* Cap 4.2.8: compare via module name faces (not arena Func by-value).
                 * Arena Func get can tear name_len after layout raise; module faces are
                 * the same authority as local_has_name above (G.7 single path). */
                let dnl: i32 = pipeline_module_func_name_len_at(dep_mod, fi);
                if (dnl == callee.var_name_len && dnl > 0) {
                  let dnm: u8[256] = [];
                  pipeline_module_func_name_copy64(dep_mod, fi, &dnm[0]);
                  let eq: bool = true;
                  let k: i32 = 0;
                  while (k < callee.var_name_len) {
                    if (callee.var_name[k] != dnm[k]) {
                      eq = false;
                      break;
                    }
                    k = k + 1;
                  }
                  if (eq && pipeline_dep_ctx_import_path_len(ctx, j) > 0) {
                    /* Why extern: dep extern symbols must match emit_func_extern_declaration or the linker fails. */
                    let callee_is_extern: i32 = pipeline_module_func_is_extern_at(dep_mod, fi);
                    let dep_path_call: u8[256] = [];
                    pipeline_dep_ctx_import_path_copy64(ctx, j, &dep_path_call[0]);
                    let pre_buf: u8[128] = [];
                    codegen_import_path_to_c_prefix_into(&dep_path_call[0], &pre_buf[0], 128);
                    let pre_len: i32 = 0;
                    while (pre_len < 128 && pre_buf[pre_len] != 0) {
                      pre_len = pre_len + 1;
                    }
                    /* See implementation. */
                    if (callee_is_extern != 0 || pipeline_module_func_is_no_mangle_at(dep_mod, fi) != 0) {
                      pre_len = 0;
                    }
                    let drv_buf_call: i32 = 0;
                    if (codegen_path_is_std_io_driver_bytes(&dep_path_call[0]) != 0) {
                      drv_buf_call = codegen_emit_io_driver_buf_call_name(out, &callee.var_name[0], callee.var_name_len, e.call_num_args);
                      if (drv_buf_call < 0) {
                        return -1;
                      }
                    }
                    if (drv_buf_call == 0) {
                      if (pre_len > 0 && codegen_c_prefix_redundant_with_name(&pre_buf[0], pre_len, callee.var_name, callee.var_name_len) == 0 && codegen_emit_bytes_from_ptr(out, &pre_buf[0], pre_len) != 0) {
                        return -1;
                      }
                      /* Pass dep_mod (not cur_mod): emit_call_func_name rejects
                       * call_resolved when res_mod != current_module, which dropped the
                       * bare name after the prefix → link `_core_option_` (empty fn). */
                      if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, dep_mod, &callee.var_name[0], callee.var_name_len) != 0) {
                        return -1;
                      }
                      if (codegen_path_is_std_io_core_bytes(&dep_path_call[0]) != 0 && codegen_use_buf_wrapper(&callee.var_name[0], callee.var_name_len, e.call_num_args) != 0) {
                        let suf_buf: u8[8] = [95, 98, 117, 102, 0, 0, 0, 0];
                        if (codegen_emit_bytes_from_ptr(out, &suf_buf[0], 4) != 0) {
                          return -1;
                        }
                      }
                    }
                    if (codegen_append_byte(out, 40) != 0) {
                      return -1;
                    }
                    let n_dep: i32 = codegen_call_num_args_override(&pre_buf[0], pre_len, callee.var_name, callee.var_name_len, e.call_num_args);
                    let fmt_i32_second_dep: i32 = 0;
                    if (e.call_num_args == 2 && n_dep == 1 && callee.var_name_len == 7 && callee.var_name[0] == 102 && callee.var_name[1] == 109 && callee.var_name[2] == 116 && callee.var_name[3] == 95 && callee.var_name[4] == 105 && callee.var_name[5] == 51 && callee.var_name[6] == 50) {
                      if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, 0))) {
                        fmt_i32_second_dep = 1;
                      }
                    }
                    let cast_buf0: i32 = drv_buf_call;
                    let ai: i32 = 0;
                    while (ai < n_dep) {
                      if (ai > 0) {
                        let comma: u8[3] = [44, 32, 0];
                        if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
                          return -1;
                        }
                      }
                      let arg_idx_dep: i32 = ai;
                      if (fmt_i32_second_dep != 0 && ai == 0) {
                        arg_idx_dep = 1;
                      }
                      if (cast_buf0 != 0 && ai == 0) {
                        let cast_buf: u8[19] = [40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0];
                        if (codegen_emit_bytes_from_ptr(out, &cast_buf[0], 18) != 0) {
                          return -1;
                        }
                      }
                      if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_dep))) {
                        if (codegen_append_byte(out, 48) != 0) {
                          return -1;
                        }
                      } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_dep), ctx) != 0) {
                        return -1;
                      }
                      ai = ai + 1;
                    }
                    if (codegen_is_submit_batch_buf_call(callee.var_name, callee.var_name_len) != 0 && e.call_num_args == 3) {
                      let comma0: u8[4] = [44, 32, 48, 0];
                      if (codegen_emit_bytes_4(out, &comma0[0], 3) != 0) {
                        return -1;
                      }
                    }
                    if (codegen_append_byte(out, 41) != 0) {
                      return -1;
                    }
                    return 0;
                  }
                }
                fi = fi + 1;
              }
            }
            j = j + 1;
          }
        }
      }
      /* See implementation. */
      if (ctx != 0 as *PipelineDepCtx && ctx.ndep > 0 && !ast.ref_is_null(callee_ref) && callee_ref > 0 && callee_ref <= arena.num_exprs) {
        let callee_fb: Expr = ast.ast_arena_expr_get(arena, callee_ref);
        if ((callee_fb.kind as i32) == (ExprKind.EXPR_VAR as i32) && callee_fb.var_name_len == 9
            && callee_fb.var_name[0] == 112 && callee_fb.var_name[1] == 114 && callee_fb.var_name[2] == 105 && callee_fb.var_name[3] == 110
            && callee_fb.var_name[4] == 116 && callee_fb.var_name[5] == 95 && callee_fb.var_name[6] == 115 && callee_fb.var_name[7] == 116 && callee_fb.var_name[8] == 114) {
          let std_io: u8[8] = [115, 116, 100, 95, 105, 111, 95, 0];
          if (codegen_emit_bytes_from_ptr(out, &std_io[0], 7) != 0) {
            return -1;
          }
          if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, ctx.current_codegen_module, &callee_fb.var_name[0], callee_fb.var_name_len) != 0) {
            return -1;
          }
          if (codegen_append_byte(out, 40) != 0) {
            return -1;
          }
          let ai: i32 = 0;
          while (ai < e.call_num_args) {
            if (ai > 0) {
              let comma: u8[3] = [44, 32, 0];
              if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
                return -1;
              }
            }
            if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {
              if (codegen_append_byte(out, 48) != 0) {
                return -1;
              }
            } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) != 0) {
              return -1;
            }
            ai = ai + 1;
          }
          if (codegen_append_byte(out, 41) != 0) {
            return -1;
          }
          return 0;
        }
      }
      /* See implementation. */
      if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module && ctx.current_codegen_arena != 0 as *ASTArena && !ast.ref_is_null(callee_ref) && callee_ref > 0 && callee_ref <= arena.num_exprs) {
        let callee2: Expr = ast.ast_arena_expr_get(arena, callee_ref);
        if ((callee2.kind as i32) == (ExprKind.EXPR_VAR as i32) && callee2.var_name_len > 0) {
          let cur_mod: *Module = ctx.current_codegen_module;
          let cur_arena: *ASTArena = ctx.current_codegen_arena;
          let fi: i32 = 0;
          while (fi < cur_mod.num_funcs) {
            let func_ref: i32 = pipeline_module_func_ref_at(cur_mod, fi);
            if (!ast.ref_is_null(func_ref) && func_ref > 0 && func_ref <= cur_arena.num_funcs) {
              let df: Func = ast.ast_arena_func_get(cur_arena, func_ref);
              if (df.name_len == callee2.var_name_len) {
                let eq: bool = true;
                let k: i32 = 0;
                while (k < callee2.var_name_len && k < 64) {
                  if (callee2.var_name[k] != df.name[k]) {
                    eq = false;
                    break;
                  }
                  k = k + 1;
                }
                if (eq) {
                  let cur_pre: u8[256] = [];
                  /*
                   * Same-module bare call prefix (align pin seed CALL callee2 path).
                   * Purpose: prefer path of current_codegen_module in the dep pool
                   *   (core_result_ while emitting result), then entry pin / mirror.
                   *   Do NOT only use codegen_emit_prefix_len_from_ctx: it prefers
                   *   current_codegen_prefix_mirror which import/dep walks can leave
                   *   on a prior dep (e.g. core_option_ → bare unwrap_or mis-prefixed).
                   * Authority: seeds/codegen_gen.linux.x86_64.c same-module VAR CALL.
                   * PLATFORM: SHARED — Cap force si (result→result, not option).
                   */
                  let cur_dep_path_buf: u8[256] = [];
                  let cur_dep_plen: i32 = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, &cur_dep_path_buf[0]);
                  let pl: i32 = 0;
                  if (cur_dep_plen > 0) {
                    codegen_import_path_to_c_prefix_into(&cur_dep_path_buf[0], &cur_pre[0], 128);
                    while (pl < 128 && cur_pre[pl] != 0 as u8) {
                      pl = pl + 1;
                    }
                  } else if (ctx.current_codegen_prefix_len > 0) {
                    let _cpl: i32 = ctx.current_codegen_prefix_len;
                    let pi: i32 = 0;
                    while (pi < _cpl && pi < 127) {
                      cur_pre[pi] = ctx.current_codegen_prefix_mirror[pi];
                      pi = pi + 1;
                    }
                    cur_pre[pi] = 0 as u8;
                    pl = pi;
                  } else {
                    cur_pre[0] = 0 as u8;
                    pl = 0;
                  }
                  /* See implementation. */
                  if (pipeline_module_func_is_extern_at(cur_mod, fi) != 0
                      || pipeline_module_func_is_no_mangle_at(cur_mod, fi) != 0) {
                    pl = 0;
                  }
                  if (pl > 0 && codegen_c_prefix_redundant_with_name(&cur_pre[0], pl, callee2.var_name, callee2.var_name_len) == 0 && codegen_emit_bytes_from_ptr(out, &cur_pre[0], pl) != 0) {
                    return -1;
                  }
                  if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, cur_mod, &callee2.var_name[0], callee2.var_name_len) != 0) {
                    return -1;
                  }
                  if (codegen_append_byte(out, 40) != 0) {
                    return -1;
                  }
                  let n_cur: i32 = codegen_call_num_args_override(&cur_pre[0], pl, callee2.var_name, callee2.var_name_len, e.call_num_args);
                  let fmt_i32_second_cur: i32 = 0;
                  if (e.call_num_args == 2 && n_cur == 1 && callee2.var_name_len == 7 && callee2.var_name[0] == 102 && callee2.var_name[1] == 109 && callee2.var_name[2] == 116 && callee2.var_name[3] == 95 && callee2.var_name[4] == 105 && callee2.var_name[5] == 51 && callee2.var_name[6] == 50) {
                    if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, 0))) {
                      fmt_i32_second_cur = 1;
                    }
                  }
                  let ai: i32 = 0;
                  while (ai < n_cur) {
                    if (ai > 0) {
                      let comma: u8[3] = [44, 32, 0];
                      if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
                        return -1;
                      }
                    }
                    let arg_idx_cur: i32 = ai;
                    if (fmt_i32_second_cur != 0 && ai == 0) {
                      arg_idx_cur = 1;
                    }
                    if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_cur))) {
                      if (codegen_append_byte(out, 48) != 0) {
                        return -1;
                      }
                    } else {
                      /* wave395: pass formal type so TYPE_ARRAY→fat only for TYPE_SLICE. */
                      let pty_cur: i32 = 0;
                      if (arg_idx_cur < pipeline_module_func_num_params_at(cur_mod, fi)) {
                        pty_cur = pipeline_module_func_param_type_ref_at(cur_mod, fi, arg_idx_cur);
                      }
                      codegen_set_host_call_arg_param_ty(pty_cur);
                      if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_cur), ctx) != 0) {
                        codegen_set_host_call_arg_param_ty(0);
                        return -1;
                      }
                      codegen_set_host_call_arg_param_ty(0);
                    }
                    ai = ai + 1;
                  }
                  if (codegen_is_submit_batch_buf_call(callee2.var_name, callee2.var_name_len) != 0 && e.call_num_args == 3) {
                    let comma0: u8[4] = [44, 32, 48, 0];
                    if (codegen_emit_bytes_4(out, &comma0[0], 3) != 0) {
                      return -1;
                    }
                  }
                  if (codegen_append_byte(out, 41) != 0) {
                    return -1;
                  }
                  return 0;
                }
              }
            }
            fi = fi + 1;
          }
        }
      }
      /* See implementation. */
      if (!ast.ref_is_null(e.call_callee_ref) && e.call_num_args == 2 && e.call_callee_ref > 0 && e.call_callee_ref <= arena.num_exprs) {
        let callee_fb: Expr = ast.ast_arena_expr_get(arena, e.call_callee_ref);
        if ((callee_fb.kind as i32) == (ExprKind.EXPR_VAR as i32) && callee_fb.var_name_len >= 10) {
          let prefix_ok: bool = callee_fb.var_name[0] == 109 && callee_fb.var_name[1] == 97 && callee_fb.var_name[2] == 112 && callee_fb.var_name[3] == 95;
          let off: i32 = callee_fb.var_name_len - 6;
          let suffix_ok: bool = off >= 0 && callee_fb.var_name[off] == 102 && callee_fb.var_name[off + 1] == 105 && callee_fb.var_name[off + 2] == 110 && callee_fb.var_name[off + 3] == 100 && callee_fb.var_name[off + 4] == 95 && callee_fb.var_name[off + 5] == 99;
          if (prefix_ok && suffix_ok) {
            if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, ctx.current_codegen_module, &callee_fb.var_name[0], callee_fb.var_name_len) != 0) {
              return -1;
            }
            let open: u8[3] = [40, 40, 0];
            if (codegen_emit_bytes_3(out, &open[0], 2) != 0) {
              return -1;
            }
            if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) != 0) {
              return -1;
            }
            /* See implementation. */
            let mid1: u8[10] = [41, 46, 107, 101, 121, 115, 44, 32, 40, 0];
            if (codegen_emit_bytes_from_ptr(out, &mid1[0], 9) != 0) {
              return -1;
            }
            if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) != 0) {
              return -1;
            }
            /* See implementation. */
            let mid2: u8[14] = [41, 46, 111, 99, 99, 117, 112, 105, 101, 100, 44, 32, 40, 0];
            if (codegen_emit_bytes_from_ptr(out, &mid2[0], 13) != 0) {
              return -1;
            }
            if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) != 0) {
              return -1;
            }
            /* See implementation. */
            let mid3: u8[8] = [41, 46, 99, 97, 112, 44, 32, 0];
            if (codegen_emit_bytes_8(out, &mid3[0], 7) != 0) {
              return -1;
            }
            if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 1), ctx) != 0) {
              return -1;
            }
            if (codegen_append_byte(out, 41) != 0) {
              return -1;
            }
            return 0;
          }
        }
      }
      let need_4th: i32 = 0;
      if (!ast.ref_is_null(e.call_callee_ref) && e.call_callee_ref > 0 && e.call_callee_ref <= arena.num_exprs && e.call_num_args == 3) {
        let callee_f4: Expr = ast.ast_arena_expr_get(arena, e.call_callee_ref);
        if ((callee_f4.kind as i32) == (ExprKind.EXPR_VAR as i32) && codegen_is_submit_batch_buf_call(callee_f4.var_name, callee_f4.var_name_len) != 0) {
          need_4th = 1;
        }
      }
      let saved_callee_flag: i32 = 0;
      if (ctx != 0 as *PipelineDepCtx) {
        saved_callee_flag = ctx.emit_expr_as_callee;
        ctx.emit_expr_as_callee = 1;
      }
      if (!ast.ref_is_null(e.call_callee_ref) && codegen_emit_expr(arena, out, e.call_callee_ref, ctx) != 0) {
        if (ctx != 0 as *PipelineDepCtx) {
          ctx.emit_expr_as_callee = saved_callee_flag;
        }
        return -1;
      }
      if (ctx != 0 as *PipelineDepCtx) {
        ctx.emit_expr_as_callee = saved_callee_flag;
      }
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      let fallback_pre: u8[256] = [];
      let fallback_pl: i32 = 0;
      if (ctx != 0 as *PipelineDepCtx) {
        let fb_dep_path_buf: u8[256] = [];
        let fb_dep_plen: i32 = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, &fb_dep_path_buf[0]);
        if (fb_dep_plen > 0) {
          codegen_import_path_to_c_prefix_into(&fb_dep_path_buf[0], &fallback_pre[0], 64);
        } else {
          fallback_pre[0] = 0 as u8;
        }
        while (fallback_pl < 64 && fallback_pre[fallback_pl] != 0) {
          fallback_pl = fallback_pl + 1;
        }
      }
      let n_fb: i32 = e.call_num_args;
      /* See implementation. */
      let use_second_arg: i32 = 0;
      if (!ast.ref_is_null(e.call_callee_ref) && e.call_callee_ref > 0 && e.call_callee_ref <= arena.num_exprs) {
        let callee_expr: Expr = ast.ast_arena_expr_get(arena, e.call_callee_ref);
        if ((callee_expr.kind as i32) == (ExprKind.EXPR_VAR as i32)) {
          n_fb = codegen_call_num_args_override(&fallback_pre[0], fallback_pl, callee_expr.var_name, callee_expr.var_name_len, e.call_num_args);
          /* PLATFORM: SHARED — ref_is_null is bool; do not compare != 0 (T001). wave323 */
          if (e.call_num_args == 2 && n_fb == 1 && ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, 0))) {
            use_second_arg = 1;
          }
        }
      }
      let ai: i32 = 0;
      while (ai < n_fb) {
        if (ai > 0) {
          let comma: u8[3] = [44, 32, 0];
          if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
            return -1;
          }
        }
        let arg_idx: i32 = ai;
        if (use_second_arg != 0 && ai == 0) {
          arg_idx = 1;
        }
        if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx))) {
          if (codegen_append_byte(out, 48) != 0) {
            return -1;
          }
        } else {
          let pty_fb: i32 = 0;
          let rfi_fb: i32 = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
          if (rfi_fb >= 0 && ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module) {
            if (arg_idx < pipeline_module_func_num_params_at(ctx.current_codegen_module, rfi_fb)) {
              pty_fb = pipeline_module_func_param_type_ref_at(ctx.current_codegen_module, rfi_fb, arg_idx);
            }
          }
          codegen_set_host_call_arg_param_ty(pty_fb);
          if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx), ctx) != 0) {
            codegen_set_host_call_arg_param_ty(0);
            return -1;
          }
          codegen_set_host_call_arg_param_ty(0);
        }
        ai = ai + 1;
      }
      if (need_4th != 0) {
        let comma0: u8[4] = [44, 32, 48, 0];
        if (codegen_emit_bytes_4(out, &comma0[0], 3) != 0) {
          return -1;
        }
      }
      if (codegen_append_byte(out, 41) != 0) {
        return -1;
      }
      return 0;
    }
    /* FLOAT_LIT: emit real value via C helper (old seed stub always wrote 0.0).
     * Authority: pipeline_codegen_emit_float_lit_c seed ALWAYS WAVE289 (runtime_pipeline_abi). */
    if ((e.kind as i32) == (ExprKind.EXPR_FLOAT_LIT as i32)) {
      return pipeline_codegen_emit_float_lit_c(out, e.float_val, e.float_bits_lo, e.float_bits_hi);
    }
    /* See implementation. */
    if ((e.kind as i32) == (ExprKind.EXPR_MUL as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 42, 32, 0];
      if (codegen_emit_bytes_4(out, &op[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_DIV as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 47, 32, 0];
      if (codegen_emit_bytes_4(out, &op[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_MOD as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 37, 32, 0];
      if (codegen_emit_bytes_4(out, &op[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    /* See implementation. */
    if ((e.kind as i32) == (ExprKind.EXPR_EQ as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 61, 61, 0];
      if (codegen_emit_bytes_4(out, &op[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_NE as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 33, 61, 0];
      if (codegen_emit_bytes_4(out, &op[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_LT as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 60, 32, 0];
      if (codegen_emit_bytes_4(out, &op[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_LE as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 60, 61, 0];
      if (codegen_emit_bytes_4(out, &op[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_GT as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 62, 32, 0];
      if (codegen_emit_bytes_4(out, &op[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_GE as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 62, 61, 0];
      if (codegen_emit_bytes_4(out, &op[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_LOGAND as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[5] = [32, 38, 38, 32, 0];
      if (emit_bytes_5(out, &op[0], 4) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_LOGOR as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[5] = [32, 124, 124, 32, 0];
      if (emit_bytes_5(out, &op[0], 4) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_SHL as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 60, 60, 0];
      if (codegen_emit_bytes_4(out, &op[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_SHR as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 62, 62, 0];
      if (codegen_emit_bytes_4(out, &op[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_BITAND as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 38, 32, 0];
      if (codegen_emit_bytes_4(out, &op[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_BITOR as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 124, 32, 0];
      if (codegen_emit_bytes_4(out, &op[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_BITXOR as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 94, 32, 0];
      if (codegen_emit_bytes_4(out, &op[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    /* See implementation. */
    if ((e.kind as i32) == (ExprKind.EXPR_BITNOT as i32)) {
      let pre: u8[3] = [126, 40, 0];
      if (codegen_emit_bytes_3(out, &pre[0], 2) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_LOGNOT as i32)) {
      let pre: u8[3] = [33, 40, 0];
      if (codegen_emit_bytes_3(out, &pre[0], 2) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    /* See implementation. */
    if ((e.kind as i32) == (ExprKind.EXPR_TERNARY as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.if_cond_ref) && codegen_emit_expr(arena, out, e.if_cond_ref, ctx) != 0) {
        return -1;
      }
      let q: u8[4] = [32, 63, 32, 0];
      if (codegen_emit_bytes_4(out, &q[0], 3) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.if_then_ref) && codegen_emit_expr(arena, out, e.if_then_ref, ctx) != 0) {
        return -1;
      }
      let colon: u8[4] = [32, 58, 32, 0];
      if (codegen_emit_bytes_4(out, &colon[0], 3) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.if_else_ref)) {
        if (codegen_emit_expr(arena, out, e.if_else_ref, ctx) != 0) {
          return -1;
        }
      } else {
        if (codegen_append_byte(out, 48) != 0) {
          return -1;
        }
      }
      return codegen_append_byte(out, 41);
    }
    /* See implementation. */
    if ((e.kind as i32) == (ExprKind.EXPR_INDEX as i32)) {
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.index_base_ref) && codegen_emit_expr(arena, out, e.index_base_ref, ctx) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 41) != 0) {
        return -1;
      }
      /*
       * See implementation.
       * See implementation.
       */
      let need_slice_data: i32 = e.index_base_is_slice;
      if (need_slice_data == 0 && !ast.ref_is_null(e.index_base_ref)) {
        let base_ty: i32 = pipeline_expr_resolved_type_ref(arena, e.index_base_ref);
        if (!ast.ref_is_null(base_ty) && base_ty > 0 && base_ty <= arena.num_types) {
          if (pipeline_type_kind_ord_at(arena, base_ty) == 11) {
            need_slice_data = 1;
          }
        }
      }
      if (need_slice_data != 0) {
        /* PLATFORM: SHARED — slice params are pointers: use ->data not .data.
         * Why: Cap by-value→pointer param ABI; INDEX used to hardcode `.data` → host-cc error. */
        let use_arrow: i32 = 0;
        if (!ast.ref_is_null(e.index_base_ref)) {
          if (field_access_base_is_pointer_ref(arena, e.index_base_ref) != 0) {
            use_arrow = 1;
          }
          if (use_arrow == 0 && ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0) {
            if (field_access_base_is_pointer_param(arena, e.index_base_ref, ctx.current_codegen_module, ctx.current_func_index) != 0) {
              use_arrow = 1;
            }
          }
        }
        if (use_arrow != 0) {
          let arrow_data: u8[8] = [45, 62, 100, 97, 116, 97, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &arrow_data[0], 6) != 0) {
            return -1;
          }
        } else {
          let dot: u8[6] = [46, 100, 97, 116, 97, 0];
          if (emit_bytes_6(out, &dot[0], 5) != 0) {
            return -1;
          }
        }
      }
      if (codegen_append_byte(out, 91) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.index_index_ref) && codegen_emit_expr(arena, out, e.index_index_ref, ctx) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 93);
    }
    /* See implementation. */
    if ((e.kind as i32) == (ExprKind.EXPR_FIELD_ACCESS as i32)) {
      /* PLATFORM: SHARED — mark Enum.Variant / import.Enum.Variant on this arena
       * before re-reading e (seed call site must pass codegen_emit_expr arena, not a
       * possibly-stale current_codegen_arena). */
      if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module) {
        pipeline_codegen_try_mark_enum_field_access(ctx.current_codegen_module, arena, expr_ref, ctx);
        e = ast.ast_arena_expr_get(arena, expr_ref);
      }
      if (e.field_access_is_enum_variant != 0) {
        /* See implementation. */
        return format_int(out, e.enum_variant_tag);
      }
      /*
       * wave346 Cap residual pure: fixed TYPE_ARRAY / TYPE_VECTOR `.length` is
       * compile-time N. C arrays are not structs — never emit `a.length`.
       * G.7: same authority as typeck field_slice (usize) + freestanding imm N.
       * PLATFORM: SHARED host-C emit; seed must match this block.
       */
      if (e.field_access_field_len == 6
          && e.field_access_field_name[0] == 108
          && e.field_access_field_name[1] == 101
          && e.field_access_field_name[2] == 110
          && e.field_access_field_name[3] == 103
          && e.field_access_field_name[4] == 116
          && e.field_access_field_name[5] == 104
          && !ast.ref_is_null(e.field_access_base_ref)
          && e.field_access_base_ref > 0
          && e.field_access_base_ref <= arena.num_exprs) {
        let base_e: Expr = ast.ast_arena_expr_get(arena, e.field_access_base_ref);
        let base_ty: i32 = base_e.resolved_type_ref;
        if (!ast.ref_is_null(base_ty) && base_ty > 0 && base_ty <= arena.num_types) {
          let bk: i32 = pipeline_type_kind_ord_at(arena, base_ty);
          /* TYPE_ARRAY=10, TYPE_VECTOR=13 */
          if (bk == 10 || bk == 13) {
            let asz: i32 = pipeline_type_array_size_at(arena, base_ty);
            if (asz > 0) {
              /* ((size_t)N) — matches slice .length C type (size_t). */
              let open_cast: u8[16] = [
                40, 40, 115, 105, 122, 101, 95, 116, 41, 0, 0, 0, 0, 0, 0, 0
              ];
              if (codegen_emit_bytes_from_ptr(out, &open_cast[0], 9) != 0) {
                return -1;
              }
              if (format_int(out, asz) != 0) {
                return -1;
              }
              return codegen_append_byte(out, 41);
            }
          }
        }
      }
      /* See implementation. */
      if (ctx != 0 as *PipelineDepCtx && ctx.emit_expr_as_callee != 0 && emit_import_module_field_symbol(arena, out, expr_ref, ctx) == 0) {
        return 0;
      }
      /* See implementation. */
      if (emit_import_module_const_field(arena, out, expr_ref, ctx) == 0) {
        return 0;
      }
      /*
       * See implementation.
       * See implementation.
       */
      if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module && ctx.current_codegen_arena == arena && ctx.current_func_index >= 0) {
        let mod: *Module = ctx.current_codegen_module;
        if (ctx.current_func_index < mod.num_funcs) {
          let cfi: i32 = ctx.current_func_index;
          let pref: u8[256] = [];
          let plen: i32 = codegen_emit_prefix_len_from_ctx(ctx, &pref[0], 128);
          let cfn: u8[256] = [];
          pipeline_module_func_name_copy64(mod, cfi, &cfn[0]);
          let cfn_len: i32 = pipeline_module_func_name_len_at(mod, cfi);
          if (codegen_force_param_ptrdiff_t(&pref[0], plen, &cfn[0], cfn_len, 0) != 0) {
            if (expr_var_matches_func_param_index(arena, e.field_access_base_ref, mod, cfi, 0, ctx) != 0) {
              return codegen_emit_expr(arena, out, e.field_access_base_ref, ctx);
            }
          }
        }
      }
      /*
       * wave638 Cap residual pure: host-C FIELD base must be a primary.
       * Historical shape `(base.field)` with DEREF base `*(p)` emitted `(*(p).v)`,
       * which C parses as `*((p).v)` (`.` binds tighter than unary `*`) → BLD001.
       * G.7: emit `((base).field)` / `((base)->field)` so postfix attaches to the
       * whole base (including `(*p)`). INDEX already wraps base alone — leave it.
       * PLATFORM: SHARED host-C emit; seed codegen_gen must match.
       */
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.field_access_base_ref) && codegen_emit_expr(arena, out, e.field_access_base_ref, ctx) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 41) != 0) {
        return -1;
      }
      /* See implementation. */
      let is_ptr_base: i32 = field_access_base_is_pointer_ref(arena, e.field_access_base_ref);
      let param_type_known: i32 = 0;
      if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0) {
        if (is_ptr_base == 0) {
          is_ptr_base = field_access_base_is_pointer_param(arena, e.field_access_base_ref, ctx.current_codegen_module, ctx.current_func_index);
        }
        if (is_ptr_base == 0) {
          is_ptr_base = field_access_base_is_pointer_local(arena, e.field_access_base_ref, ctx);
        }
        param_type_known = field_access_base_param_type_known(arena, e.field_access_base_ref, ctx.current_codegen_module, ctx.current_func_index);
      }
      if (is_ptr_base == 0 && param_type_known == 0 && field_access_base_type_resolved(arena, e.field_access_base_ref) == 0) {
        if (field_access_base_is_slice_param_name(arena, e.field_access_base_ref) != 0) {
          is_ptr_base = 1;
        }
      }
      if (is_ptr_base != 0) {
        let arrow: u8[3] = [45, 62, 0];
        if (codegen_emit_bytes_3(out, &arrow[0], 2) != 0) {
          return -1;
        }
      } else {
        let dot: u8[2] = [46, 0];
        if (codegen_emit_bytes_2(out, &dot[0], 1) != 0) {
          return -1;
        }
      }
      if (codegen_emit_bytes_64(out, &e.field_access_field_name[0], e.field_access_field_len) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    /*
     * EXPR_PANIC → host `xlang_panic_(has_msg, msg_val)`.
     * ABI: void xlang_panic_(int has_msg, intptr_t msg_val) (runtime_panic / std.runtime).
     * has_msg: 0=bare, 1=integer payload, 2=NUL-terminated cstr pointer (full width).
     * Integer msgs (panic(42)) → has_msg=1 + (intptr_t)(expr).
     * String/*u8 (panic("…") / panic(p: *u8)) → has_msg=2 + (intptr_t)(expr) so LP64
     * keeps the full pointer; runtime prints the cstr then aborts (wave386).
     * PLATFORM: SHARED — cast every non-null msg through (intptr_t)(…) for host C;
     * evidence path still receives (int)truncation of payload.
     * G.7 authority: this emit only; seed codegen_gen must match.
     */
    if ((e.kind as i32) == (ExprKind.EXPR_PANIC as i32)) {
      let p: u8[23] = [120, 108, 97, 110, 103, 95, 112, 97, 110, 105, 99, 95, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      // "(intptr_t)(" — pointer-width payload (wave386; was (int)(intptr_t) truncating cstr).
      let cast_open: u8[12] = [40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 0];
      if (emit_bytes_22(out, &p[0], 13) != 0) {
        return -1;
      }
      if (ast.ref_is_null(e.unary_operand_ref)) {
        if (codegen_append_byte(out, 48) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 44) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 48) != 0) {
          return -1;
        }
      } else {
        // Classify payload: STRING_LIT (59) or TYPE_PTR → cstr (has_msg=2); else integer (1).
        let is_cstr: i32 = 0;
        let op_ref: i32 = e.unary_operand_ref;
        if (pipeline_expr_kind_ord_at(arena, op_ref) == 59) {
          is_cstr = 1;
        } else {
          if (op_ref > 0 && op_ref <= arena.num_exprs) {
            let op_e: Expr = ast.ast_arena_expr_get(arena, op_ref);
            if (!ast.ref_is_null(op_e.resolved_type_ref) && op_e.resolved_type_ref > 0
            && op_e.resolved_type_ref <= arena.num_types) {
              let oty: Type = ast.ast_arena_type_get(arena, op_e.resolved_type_ref);
              if ((oty.kind as i32) == (TypeKind.TYPE_PTR as i32)) {
                is_cstr = 1;
              }
            }
          }
        }
        // '1' (49) integer · '2' (50) cstr
        if (is_cstr != 0) {
          if (codegen_append_byte(out, 50) != 0) {
            return -1;
          }
        } else {
          if (codegen_append_byte(out, 49) != 0) {
            return -1;
          }
        }
        if (codegen_append_byte(out, 44) != 0) {
          return -1;
        }
        if (codegen_emit_bytes_from_ptr(out, &cast_open[0], 11) != 0) {
          return -1;
        }
        if (codegen_emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 41) != 0) {
          return -1;
        }
      }
      return codegen_append_byte(out, 41);
    }
    /* See implementation. */
    if ((e.kind as i32) == (ExprKind.EXPR_BREAK as i32)) {
      return codegen_append_byte(out, 48);
    }
    if ((e.kind as i32) == (ExprKind.EXPR_CONTINUE as i32)) {
      return codegen_append_byte(out, 48);
    }
    /* See implementation. */
    if ((e.kind as i32) == (ExprKind.EXPR_METHOD_CALL as i32)) {
      /* PLATFORM: SHARED — fmt/debug println("…") (METHOD_CALL form). */
      if (ctx != 0 as *PipelineDepCtx) {
        let fmt_mc_rc: i32 = codegen_try_emit_fmt_string_lit_call(arena, out, expr_ref, ctx);
        if (fmt_mc_rc < 0) {
          return -1;
        }
        if (fmt_mc_rc > 0) {
          return 0;
        }
      }
      /* stage10 S3.1 slice1 (10.1.1): dot-call raw_syscall0..6 shape
       * (linux.raw_syscall3(...) parses here, fmt.println default shape). */
      if (ctx != 0 as *PipelineDepCtx) {
        let rs_mc_rc: i32 = codegen_try_emit_raw_syscall_call(arena, out, expr_ref, ctx);
        if (rs_mc_rc < 0) {
          return -1;
        }
        if (rs_mc_rc > 0) {
          return 0;
        }
      }
      /* Cap 10.7.1 slice7: method-shape va_* → xlang_va_* (same leaf names). */
      if (ctx != 0 as *PipelineDepCtx) {
        let va_mc_rc: i32 = codegen_try_emit_va_cap_call(arena, out, expr_ref, ctx);
        if (va_mc_rc < 0) {
          return -1;
        }
        if (va_mc_rc > 0) {
          return 0;
        }
      }
      /*
       * F3 TYPE_DYN(17) vtable indirect-dispatch call-site emit.
       *
       * Typeck stamped call_resolved_dep_index = -2 (DYN_DISPATCH_DEP_SENTINEL)
       * with call_resolved_func_index = slot for any `recv.method()` where
       * recv : dyn Trait. Here we emit a C indirect call through the receiver's
       * vtable:
       *   ((ret(*)(void*, T1, T2, ...))((void**)recv.vtable)[slot])(recv.data, args...)
       *
       * The receiver must be emitted twice: once to fetch .vtable (slot lookup),
       * once to fetch .data (the self pointer passed as arg 0). The receiver is
       * a VAR (codegen emits the variable name), so emitting twice is safe and
       * idempotent. Args 1..N follow the receiver pointer with a ", " separator.
       *
       * Fn-ptr extras are typed (codegen_emit_dyn_host_c_fn_ptr_suffix) so they
       * match the wrapper formals. A trailing `(void*, ...)` would default-
       * promote f32 extras to f64 (host-C dyn_add_f32 leftover).
       * Return-type cast uses the resolved type_ref (F4 registry ret kind).
       * PLATFORM: SHARED — mirrors seeds/codegen_gen.linux.x86_64.c.
       */
      let dep_ix_dyn: i32 = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
      if (dep_ix_dyn == (0 - 2)) {
        let dyn_slot: i32 = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
        /* "(" outer group open (groups cast + subscript + call). */
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        /* "(" cast open. */
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        /* Emit the return type from the resolved type_ref.
         * Prefer codegen_emit_type whenever a type_ref exists (same as emit_func /
         * wrapper): NAMED / PTR / ARRAY / SLICE are not C tokens for
         * codegen_emit_type_kind (sit-red `struct Pair r = (void)call` /
         * `int32_t *p = (void)call`). Scalars also go through codegen_emit_type.
         * Falls back to codegen_emit_type_kind("void") when unresolved.
         * G.7 complete this cast; no second emitter. PLATFORM: SHARED. */
        let dyn_ret_ty: i32 = pipeline_expr_resolved_type_ref(arena, expr_ref);
        let dyn_ret_kind: i32 = (TypeKind.TYPE_VOID as i32);
        if (dyn_ret_ty > 0) {
          dyn_ret_kind = pipeline_type_kind_ord_at(arena, dyn_ret_ty);
        }
        if (dyn_ret_ty > 0) {
          if (codegen_emit_type(arena, out, dyn_ret_ty, 0 as *u8, 0, ctx) != 0) {
            return -1;
          }
        } else if (codegen_emit_type_kind(out, dyn_ret_kind) != 0) {
          return -1;
        }
        /* Fn-ptr suffix: typed extras matching the wrapper (not variadic). */
        if (codegen_emit_dyn_host_c_fn_ptr_suffix(out, arena, ctx, expr_ref,
                e.method_call_base_ref, dyn_slot, e.method_call_num_args) != 0) {
          return -1;
        }
        /* ")" cast close. */
        if (codegen_append_byte(out, 41) != 0) {
          return -1;
        }
        /* "(" value group open (groups the vtable cast + field access). */
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        /* "(" vtable cast open. */
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        /* "void**" — 6 bytes, the vtable-pointer cast type. */
        let dyn_v_cast: u8[6] = [118, 111, 105, 100, 42, 42];
        if (codegen_emit_bytes_from_ptr(out, &dyn_v_cast[0], 6) != 0) {
          return -1;
        }
        /* ")" vtable cast close. */
        if (codegen_append_byte(out, 41) != 0) {
          return -1;
        }
        /* Emit receiver variable name (e.g. `x`). */
        if (codegen_emit_expr(arena, out, e.method_call_base_ref, ctx) != 0) {
          return -1;
        }
        /* ".vtable)" — 8 bytes: 7 for field access + 1 for value-group close. */
        let dyn_vtable_close: u8[8] = [46, 118, 116, 97, 98, 108, 101, 41];
        if (codegen_emit_bytes_from_ptr(out, &dyn_vtable_close[0], 8) != 0) {
          return -1;
        }
        /* "[" slot "]" — subscript into the vtable function-pointer array. */
        if (codegen_append_byte(out, 91) != 0) {
          return -1;
        }
        if (format_uint(out, dyn_slot) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 93) != 0) {
          return -1;
        }
        /* ")" outer group close — end of the callable expression. */
        if (codegen_append_byte(out, 41) != 0) {
          return -1;
        }
        /* "(" call-args open — begin arg list (receiver.data is arg 0 / self). */
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        /* Emit receiver variable name again (for .data access). */
        if (codegen_emit_expr(arena, out, e.method_call_base_ref, ctx) != 0) {
          return -1;
        }
        /* ".data" — 5 bytes, the data field of the fat-ptr (self pointer). */
        let dyn_data: u8[5] = [46, 100, 97, 116, 97];
        if (codegen_emit_bytes_from_ptr(out, &dyn_data[0], 5) != 0) {
          return -1;
        }
        /* Emit explicit args 1..N, each preceded by ", ". */
        let dyn_ai: i32 = 0;
        while (dyn_ai < e.method_call_num_args) {
          let dyn_sep: u8[2] = [44, 32];
          if (codegen_emit_bytes_from_ptr(out, &dyn_sep[0], 2) != 0) {
            return -1;
          }
          let dyn_arg_ref: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, dyn_ai);
          if (ast.ref_is_null(dyn_arg_ref)) {
            if (codegen_append_byte(out, 48) != 0) {
              return -1;
            }
          } else {
            /* PLATFORM: SHARED — method args use same slice pointer ABI as CALL. */
            if (emit_call_arg_slice_abi(arena, out, dyn_arg_ref, ctx) != 0) {
              return -1;
            }
          }
          dyn_ai = dyn_ai + 1;
        }
        /* ")" call-args close. */
        return codegen_append_byte(out, 41);
      }
      /*
       * wave445 C6: per-mono method call re-resolution. When emitting a mono body,
       * typeck's call_resolved_func_index for `x.clone()` (x: T generic) points at the
       * trait method (signature-only, no body) because typeck processed the body with
       * T unresolved. Re-resolve to the impl method for the concrete receiver type
       * (e.g., A::clone for x: A in foo__A). Falls through to existing logic if no
       * impl method found (preserves prior behavior).
       * PLATFORM: SHARED — mono state in PipelineDepCtx; uses codegen_mono_subst_type
       * + codegen_find_impl_method_for_type (single resolution authority).
       */
      if (ctx != 0 as *PipelineDepCtx && ctx.mono_active != 0
          && e.method_call_base_ref > 0 && e.method_call_base_ref <= arena.num_exprs
          && e.method_call_name_len > 0) {
        let base_mono: Expr = ast.ast_arena_expr_get(arena, e.method_call_base_ref);
        let recv_ty: i32 = pipeline_expr_resolved_type_ref(arena, e.method_call_base_ref);
        let mono_mod: *Module = ctx.current_codegen_module;
        let mono_fi: i32 = ctx.current_func_index;
        /*
         * If typeck didn't resolve the base type (generic body, resolved_type_ref=0),
         * try to infer from a VAR base by matching param names (e.g. x.clone() where
         * x is the generic param). This covers the common case where the receiver is
         * a direct parameter reference. Let-binding receiver (y.dup()) needs a separate
         * let-scan fallback (deferred to wave446).
         * PLATFORM: SHARED — mirrors seed codegen_gen.linux.x86_64.c C6 branch.
         */
        /* PLATFORM: SHARED — Expr.kind is enum; cast before == lit (T001). wave323 */
        if (recv_ty <= 0 && mono_mod != 0 as *Module && (base_mono.kind as i32) == 3) {
          let parm_i: i32 = 0;
          let nparm: i32 = pipeline_module_func_num_params_at(mono_mod, mono_fi);
          while (parm_i < nparm) {
            let pname: u8[256] = [];
            let pnl: i32 = pipeline_module_func_param_name_len_at(mono_mod, mono_fi, parm_i);
            pipeline_module_func_param_name_copy32(mono_mod, mono_fi, parm_i, &pname[0]);
            if (pnl == base_mono.var_name_len && pnl > 0) {
              let peq: i32 = 1;
              let pi2: i32 = 0;
              while (pi2 < pnl) {
                if (pname[pi2] != base_mono.var_name[pi2]) {
                  peq = 0;
                  pi2 = pnl;
                } else {
                  pi2 = pi2 + 1;
                }
              }
              if (peq != 0) {
                recv_ty = pipeline_module_func_param_type_ref_at(mono_mod, mono_fi, parm_i);
                parm_i = 999;
              }
            }
            parm_i = parm_i + 1;
          }
        }
        /*
         * wave445 C6 local-let fallback: if recv_ty is still unresolved and the
         * base is a VAR, scan the current block's let bindings for a name match
         * to infer the receiver type (e.g. `let y: T = x; y.dup()` — y's type is
         * T from the let declaration). codegen_mono_subst_type then maps T -> concrete.
         * Why needed: typeck leaves resolved_type_ref=0 for generic-body VARs whose
         * type is a generic param (T), so pipeline_expr_resolved_type_ref returns 0.
         * PLATFORM: SHARED — mirrors seed codegen_gen.linux.x86_64.c C6 local-let.
         */
        /* PLATFORM: SHARED — Expr.kind enum cast before == lit (T001). wave323 */
        if (recv_ty <= 0 && (base_mono.kind as i32) == 3 && ctx.current_block_ref > 0) {
          let blk: i32 = ctx.current_block_ref;
          let nlets: i32 = ast_ast_block_num_lets(arena, blk);
          let li: i32 = 0;
          while (li < nlets) {
            let lname: u8[256] = [];
            let lnl: i32 = pipeline_block_let_name_len(arena, blk, li);
            pipeline_block_let_name_copy64(arena, blk, li, &lname[0]);
            if (lnl == base_mono.var_name_len && lnl > 0) {
              let leq: i32 = 1;
              let li2: i32 = 0;
              while (li2 < lnl) {
                if (lname[li2] != base_mono.var_name[li2]) {
                  leq = 0;
                  li2 = lnl;
                } else {
                  li2 = li2 + 1;
                }
              }
              if (leq != 0) {
                recv_ty = pipeline_block_let_type_ref(arena, blk, li);
                li = 999;
              }
            }
            li = li + 1;
          }
        }
        let concrete_ty: i32 = codegen_mono_subst_type(ctx, arena, recv_ty);
        if (concrete_ty != recv_ty && concrete_ty > 0) {
          let cur_mod_mono: *Module = ctx.current_codegen_module;
          if (cur_mod_mono != 0 as *Module) {
            let impl_fi: i32 = codegen_find_impl_method_for_type(cur_mod_mono, arena,
              &e.method_call_name[0], e.method_call_name_len, concrete_ty);
            if (impl_fi >= 0) {
              /*
               * Emit impl method call: <link_name>(<receiver>, <explicit args>).
               * The receiver (self) is arg 0 — typeck stores it as
               * method_call_base_ref, NOT in method_call_args. Emit it first,
               * then each explicit arg with a ", " separator. For 0-arg methods
               * (e.g., x.clone()), only the receiver is emitted:
               * <link_name>(<receiver>).
               * PLATFORM: SHARED — mirrors seed codegen_gen.linux.x86_64.c C6 emit.
               */
              /*
               * Emit module prefix (e.g. w445_let_binding_) before the link name.
               * codegen_emit_func_link_name emits only the bare name + overload
               * suffixes; the module prefix is emitted separately, mirroring the
               * normal CALL path (codegen_func_c_symbol_prefix_len + emit).
               * The prefix lives in ctx.current_codegen_prefix_mirror (filled
               * per-module at codegen entry). Without this, `dup(y)` would clash
               * with libc dup(int) instead of calling w445_let_binding_dup.
               * PLATFORM: SHARED — mirrors seed codegen_gen.linux.x86_64.c C6 prefix.
               */
              if (ctx.current_codegen_prefix_len > 0) {
                if (codegen_emit_bytes_from_ptr(out, &ctx.current_codegen_prefix_mirror[0], ctx.current_codegen_prefix_len) != 0) {
                  return -1;
                }
              }
              let c6_mono_rc: i32 = codegen_try_emit_impl_method_mono_call_name(out, arena, ctx, cur_mod_mono, impl_fi, concrete_ty);
              if (c6_mono_rc < 0) {
                return -1;
              }
              if (c6_mono_rc == 0) {
                if (codegen_emit_func_link_name(out, arena, cur_mod_mono, impl_fi) != 0) {
                  return -1;
                }
              }
              if (codegen_append_byte(out, 40) != 0) {
                return -1;
              }
              /* Emit receiver as arg 0 (self parameter). */
              if (e.method_call_base_ref <= 0) {
                if (codegen_append_byte(out, 48) != 0) {
                  return -1;
                }
              } else {
                /* PLATFORM: SHARED — receiver uses same slice pointer ABI as CALL. */
                if (emit_call_arg_slice_abi(arena, out, e.method_call_base_ref, ctx) != 0) {
                  return -1;
                }
              }
              /* Emit explicit args (arg 1..N), each preceded by ", ". */
              let ai_mono: i32 = 0;
              while (ai_mono < e.method_call_num_args) {
                let cs_mono: u8[2] = [44, 32];
                if (codegen_emit_bytes_from_ptr(out, &cs_mono[0], 2) != 0) {
                  return -1;
                }
                let dep_arg_mono: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, ai_mono);
                if (ast.ref_is_null(dep_arg_mono)) {
                  if (codegen_append_byte(out, 48) != 0) {
                    return -1;
                  }
                } else {
                  /* PLATFORM: SHARED — method args use same slice pointer ABI as CALL. */
                  if (emit_call_arg_slice_abi(arena, out, dep_arg_mono, ctx) != 0) {
                    return -1;
                  }
                }
                ai_mono = ai_mono + 1;
              }
              return codegen_append_byte(out, 41);
            }
          }
        }
      }
      if (ctx != 0 as *PipelineDepCtx) {
        let dep_ix: i32 = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
        let func_ix: i32 = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
        /*
         * See implementation.
         * See implementation.
         * See implementation.
         * See implementation.
         * See implementation.
         */
        let mc_resolved_ok: i32 = 0;
        /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
        let ndep_mc: i32 = pipeline_dep_ctx_ndep(ctx);
        if (dep_ix >= 0 && func_ix >= 0 && dep_ix < ndep_mc) {
          let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, dep_ix);
          if (dep_mod != 0 as *Module && func_ix < dep_mod.num_funcs) {
            let fn_name: u8[256] = [];
            let fn_len: i32 = pipeline_module_func_name_len_at(dep_mod, func_ix);
            let name_ok: i32 = 0;
            if (fn_len > 0) {
              pipeline_module_func_name_copy64(dep_mod, func_ix, &fn_name[0]);
            }
            if (fn_len > 0 && fn_len == e.method_call_name_len && e.method_call_name_len > 0) {
              name_ok = 1;
              let mi: i32 = 0;
              while (mi < fn_len) {
                if (fn_name[mi] != e.method_call_name[mi]) {
                  name_ok = 0;
                  mi = fn_len;
                } else {
                  mi = mi + 1;
                }
              }
            }
            if (name_ok != 0 && pipeline_module_func_num_params_at(dep_mod, func_ix) == e.method_call_num_args) {
              mc_resolved_ok = 1;
            }
            /*
             * PLATFORM: SHARED — multi-import closure can leave call_resolved dep_ix on a
             * transitive dep (e.g. std.heap.libc) while the binding is std.heap. Name+arity
             * alone then emits std_heap_libc_free instead of std_heap_free_u8_ptr.
             * Trust resolved only when dep path matches the import binding path.
             * When path matches, keep typeck's overload pick (do not force re-search).
             */
            if (mc_resolved_ok != 0) {
              let bind_path: u8[128] = [];
              let bind_plen: i32 = codegen_resolve_binding_import_path_for_method_call(ctx, arena, expr_ref, &bind_path[0]);
              let dep_path_chk: u8[256] = [];
              pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, &dep_path_chk[0]);
              let dep_plen_chk: i32 = pipeline_dep_ctx_import_path_len(ctx, dep_ix);
              if (bind_plen > 0) {
                if (bind_plen != dep_plen_chk) {
                  mc_resolved_ok = 0;
                } else {
                  let bp: i32 = 0;
                  while (bp < bind_plen) {
                    if (bind_path[bp] != dep_path_chk[bp]) {
                      mc_resolved_ok = 0;
                      bp = bind_plen;
                    } else {
                      bp = bp + 1;
                    }
                  }
                }
              }
            }
            if (mc_resolved_ok != 0) {
            let dep_path: u8[256] = [];
            pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, &dep_path[0]);
            let pre_buf: u8[128] = [];
            codegen_import_path_to_c_prefix_into(&dep_path[0], &pre_buf[0], 128);
            let pre_len: i32 = 0;
            while (pre_len < 128 && pre_buf[pre_len] != 0) {
              pre_len = pre_len + 1;
            }
            /* See implementation. */
            let drv_buf_mc: i32 = 0;
            if (codegen_path_is_std_io_driver_bytes(&dep_path[0]) != 0 && fn_len > 0) {
              drv_buf_mc = codegen_emit_io_driver_buf_call_name(out, &fn_name[0], fn_len, e.method_call_num_args);
              if (drv_buf_mc < 0) {
                return -1;
              }
            }
            if (drv_buf_mc == 0) {
              /* See implementation. */
              let call_pre: i32 = codegen_func_c_symbol_prefix_len(dep_mod, func_ix, pre_len);
              if (call_pre > 0 && fn_len > 0 && codegen_c_prefix_redundant_with_name(&pre_buf[0], call_pre, &fn_name[0], fn_len) == 0 && codegen_emit_bytes_from_ptr(out, &pre_buf[0], call_pre) != 0) {
                return -1;
              }
              /* Why: typeck/parse mangle must match emit path; overloads (e.g. heap.free x6)
                 mismatch define-side mangled names -> link errors.
                 dep param type_ref lives in that module's arena — prefer dep_ctx arena,
                 else codegen_arena_for_module (null arena → empty suffixes → bare free).
                 Invariant: fn_len>0 guarantees a name; codegen_emit_func_link_name checks overload_count. */
              /* Prefer module→arena map (stable); dep_ix arena can be stale/null on Linux. */
              let dep_arena: *ASTArena = codegen_arena_for_module(ctx, dep_mod, arena);
              if (dep_arena == 0 as *ASTArena) {
                dep_arena = pipeline_dep_ctx_arena_at(ctx, dep_ix);
              }
              if (fn_len > 0) {
                let dep_recv_ty: i32 = 0;
                if (!ast.ref_is_null(e.method_call_base_ref)) {
                  dep_recv_ty = pipeline_expr_resolved_type_ref(arena, e.method_call_base_ref);
                }
                let dep_mono_rc: i32 = 0;
                if (dep_recv_ty > 0) {
                  dep_mono_rc = codegen_try_emit_impl_method_mono_call_name(out, dep_arena, ctx, dep_mod, func_ix, dep_recv_ty);
                }
                if (dep_mono_rc < 0) {
                  return -1;
                }
                if (dep_mono_rc == 0) {
                  if (codegen_emit_func_link_name(out, dep_arena, dep_mod, func_ix) != 0) {
                    return -1;
                  }
                }
              }
            }
            if (codegen_append_byte(out, 40) != 0) {
              return -1;
            }
            let n_dep: i32 = codegen_call_num_args_override(&pre_buf[0], pre_len, &fn_name[0], fn_len, e.method_call_num_args);
            let ai: i32 = 0;
            while (ai < n_dep) {
              if (ai > 0) {
                let comma_dep: u8[3] = [44, 32, 0];
                if (codegen_emit_bytes_3(out, &comma_dep[0], 2) != 0) {
                  return -1;
                }
              }
              if (drv_buf_mc != 0 && ai == 0) {
                let cast_buf: u8[19] = [40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0];
                if (codegen_emit_bytes_from_ptr(out, &cast_buf[0], 18) != 0) {
                  return -1;
                }
              }
              let dep_arg: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, ai);
              if (ast.ref_is_null(dep_arg)) {
                if (codegen_append_byte(out, 48) != 0) {
                  return -1;
                }
              /* PLATFORM: SHARED — method dep args use same slice pointer ABI as CALL. */
              } else if (emit_call_arg_slice_abi(arena, out, dep_arg, ctx) != 0) {
                return -1;
              }
              ai = ai + 1;
            }
            return codegen_append_byte(out, 41);
            }
          }
        }
        let dep_path_fb: u8[128] = [];
        let dep_path_fb_len: i32 = codegen_resolve_binding_import_path_for_method_call(ctx, arena, expr_ref, &dep_path_fb[0]);
        if (dep_path_fb_len > 0) {
          let pre_fb: u8[128] = [];
          codegen_import_path_to_c_prefix_into(&dep_path_fb[0], &pre_fb[0], 128);
          let pre_fb_len: i32 = 0;
          while (pre_fb_len < 128 && pre_fb[pre_fb_len] != 0) {
            pre_fb_len = pre_fb_len + 1;
          }
          /* See implementation. */
          let drv_buf_fb: i32 = 0;
          if (codegen_path_is_std_io_driver_bytes(&dep_path_fb[0]) != 0) {
            drv_buf_fb = codegen_emit_io_driver_buf_call_name(out, &e.method_call_name[0], e.method_call_name_len, e.method_call_num_args);
            if (drv_buf_fb < 0) {
              return -1;
            }
          }
          if (drv_buf_fb == 0) {
            if (pre_fb_len > 0 && codegen_c_prefix_redundant_with_name(&pre_fb[0], pre_fb_len, &e.method_call_name[0], e.method_call_name_len) == 0 && codegen_emit_bytes_from_ptr(out, &pre_fb[0], pre_fb_len) != 0) {
              return -1;
            }
            /* Why: import path → dep module for mangling.
               Invariant: dep_path_fb is compared bytewise to each dep import_path; search on unique match. */
            let fb_dep_mod: *Module = 0 as *Module;
            let dj: i32 = 0;
            /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
            let ndep_dj: i32 = pipeline_dep_ctx_ndep(ctx);
            while (dj < ndep_dj) {
              let dj_path: u8[256] = [];
              pipeline_dep_ctx_import_path_copy64(ctx, dj, &dj_path[0]);
              let dj_plen: i32 = pipeline_dep_ctx_import_path_len(ctx, dj);
              if (dj_plen == dep_path_fb_len && dj_plen > 0) {
                let dj_eq: i32 = 1;
                let dk: i32 = 0;
                while (dk < dj_plen) {
                  if (dj_path[dk] != dep_path_fb[dk]) {
                    dj_eq = 0;
                    dk = dj_plen;
                  } else {
                    dk = dk + 1;
                  }
                }
                if (dj_eq != 0) {
                  fb_dep_mod = pipeline_dep_ctx_module_at(ctx, dj);
                  dj = ndep_dj;
                }
              }
              dj = dj + 1;
            }
            if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, fb_dep_mod, &e.method_call_name[0], e.method_call_name_len) != 0) {
              return -1;
            }
          }
          if (codegen_append_byte(out, 40) != 0) {
            return -1;
          }
          let n_fb: i32 = codegen_call_num_args_override(&pre_fb[0], pre_fb_len, &e.method_call_name[0], e.method_call_name_len, e.method_call_num_args);
          let ai_fb: i32 = 0;
          while (ai_fb < n_fb) {
            if (ai_fb > 0) {
              let comma_fb: u8[3] = [44, 32, 0];
              if (codegen_emit_bytes_3(out, &comma_fb[0], 2) != 0) {
                return -1;
              }
            }
            if (drv_buf_fb != 0 && ai_fb == 0) {
              let cast_buf: u8[19] = [40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0];
              if (codegen_emit_bytes_from_ptr(out, &cast_buf[0], 18) != 0) {
                return -1;
              }
            }
            let arg_fb: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, ai_fb);
            if (ast.ref_is_null(arg_fb)) {
              if (codegen_append_byte(out, 48) != 0) {
                return -1;
              }
            /* PLATFORM: SHARED — method fallback args: slice locals → &(s). */
            } else if (emit_call_arg_slice_abi(arena, out, arg_fb, ctx) != 0) {
              return -1;
            }
            ai_fb = ai_fb + 1;
          }
          return codegen_append_byte(out, 41);
        }
      }
      /*
       * wave358 Cap residual pure — host-C UFCS same-module free method.
       * typeck sets call_resolved dep_ix=-1 + func_ix; freestanding ELF already
       * places receiver as arg0. Emit free_fn(receiver, args...) with G.7 link name.
       * PLATFORM: SHARED — mac + Ubuntu L2.
       */
      if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module) {
        let uf_dep: i32 = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
        let uf_fn: i32 = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
        let uf_mod: *Module = ctx.current_codegen_module;
        if (uf_fn >= 0 && uf_dep < 0 && uf_fn < uf_mod.num_funcs
            && e.method_call_name_len > 0) {
          /*
           * Same-module prefix + link name (align CALL callee2 path).
           * Do not use codegen_emit_call_func_name alone: it compares nparams to
           * method_call_num_args (no receiver) and rejects UFCS (nparams=nargs+1),
           * then falls back to bare name without file prefix → host-cc BLD001.
           */
          let cur_pre: u8[256] = [];
          let cur_dep_path_buf: u8[256] = [];
          let cur_dep_plen: i32 = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, &cur_dep_path_buf[0]);
          let pl: i32 = 0;
          if (cur_dep_plen > 0) {
            codegen_import_path_to_c_prefix_into(&cur_dep_path_buf[0], &cur_pre[0], 128);
            while (pl < 128 && cur_pre[pl] != 0 as u8) {
              pl = pl + 1;
            }
          } else if (ctx.current_codegen_prefix_len > 0) {
            let _cpl: i32 = ctx.current_codegen_prefix_len;
            let pi: i32 = 0;
            while (pi < _cpl && pi < 127) {
              cur_pre[pi] = ctx.current_codegen_prefix_mirror[pi];
              pi = pi + 1;
            }
            cur_pre[pi] = 0 as u8;
            pl = pi;
          }
          if (pipeline_module_func_is_extern_at(uf_mod, uf_fn) != 0
              || pipeline_module_func_is_no_mangle_at(uf_mod, uf_fn) != 0) {
            pl = 0;
          }
          if (pl > 0 && codegen_c_prefix_redundant_with_name(&cur_pre[0], pl, &e.method_call_name[0], e.method_call_name_len) == 0
              && codegen_emit_bytes_from_ptr(out, &cur_pre[0], pl) != 0) {
            return -1;
          }
          let uf_arena: *ASTArena = arena;
          if (ctx.current_codegen_arena != 0 as *ASTArena) {
            uf_arena = ctx.current_codegen_arena;
          }
          let uf_bty_mono: i32 = 0;
          if (!ast.ref_is_null(e.method_call_base_ref)) {
            uf_bty_mono = pipeline_expr_resolved_type_ref(arena, e.method_call_base_ref);
          }
          let uf_mono_rc: i32 = 0;
          if (uf_bty_mono > 0) {
            uf_mono_rc = codegen_try_emit_impl_method_mono_call_name(out, uf_arena, ctx, uf_mod, uf_fn, uf_bty_mono);
          }
          if (uf_mono_rc < 0) {
            return -1;
          }
          if (uf_mono_rc == 0) {
            if (codegen_emit_func_link_name(out, uf_arena, uf_mod, uf_fn) != 0) {
              return -1;
            }
          }
          if (codegen_append_byte(out, 40) != 0) {
            return -1;
          }
          if (!ast.ref_is_null(e.method_call_base_ref)) {
            /*
             * wave360: UFCS auto-ref — self: *T with value receiver → &receiver.
             * PLATFORM: SHARED — host-C twin of freestanding lea path.
             */
            let uf_are: i32 = 0;
            let uf_p0: i32 = pipeline_module_func_param_type_ref_at(uf_mod, uf_fn, 0);
            let uf_bty: i32 = pipeline_expr_resolved_type_ref(arena, e.method_call_base_ref);
            if (uf_p0 > 0 && uf_bty > 0
                && pipeline_type_kind_ord_at(uf_arena, uf_p0) == (TypeKind.TYPE_PTR as i32)) {
              let uf_pe: i32 = pipeline_type_elem_ref_at(uf_arena, uf_p0);
              if (uf_pe > 0
                  && pipeline_typeck_type_refs_equal_c(uf_arena, uf_bty, uf_p0) == 0
                  && pipeline_typeck_type_refs_equal_c(uf_arena, uf_bty, uf_pe) != 0) {
                uf_are = 1;
              }
            }
            if (uf_are != 0) {
              if (codegen_append_byte(out, 38) != 0) {
                return -1;
              }
              if (codegen_emit_expr(arena, out, e.method_call_base_ref, ctx) != 0) {
                return -1;
              }
            } else if (emit_call_arg_slice_abi(arena, out, e.method_call_base_ref, ctx) != 0) {
              return -1;
            }
          } else {
            if (codegen_append_byte(out, 48) != 0) {
              return -1;
            }
          }
          let mi_uf: i32 = 0;
          while (mi_uf < e.method_call_num_args) {
            let comma_uf: u8[3] = [44, 32, 0];
            if (codegen_emit_bytes_3(out, &comma_uf[0], 2) != 0) {
              return -1;
            }
            let m_arg_uf: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, mi_uf);
            if (ast.ref_is_null(m_arg_uf)) {
              if (codegen_append_byte(out, 48) != 0) {
                return -1;
              }
            } else if (emit_call_arg_slice_abi(arena, out, m_arg_uf, ctx) != 0) {
              return -1;
            }
            mi_uf = mi_uf + 1;
          }
          return codegen_append_byte(out, 41);
        }
      }
      /*
       * bootstrap: i32.double() → (x * 2) when no UFCS free fn.
       */
      if (e.method_call_name_len == 6
          && e.method_call_name[0] == 100 && e.method_call_name[1] == 111
          && e.method_call_name[2] == 117 && e.method_call_name[3] == 98
          && e.method_call_name[4] == 108 && e.method_call_name[5] == 101
          && e.method_call_num_args == 0
          && !ast.ref_is_null(e.method_call_base_ref)) {
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        if (codegen_emit_expr(arena, out, e.method_call_base_ref, ctx) != 0) {
          return -1;
        }
        let mul2: u8[6] = [32, 42, 32, 50, 41, 0];
        if (codegen_emit_bytes_from_ptr(out, &mul2[0], 5) != 0) {
          return -1;
        }
        return 0;
      }
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.method_call_base_ref) && codegen_emit_expr(arena, out, e.method_call_base_ref, ctx) != 0) {
        return -1;
      }
      let dot: u8[2] = [46, 0];
      if (codegen_emit_bytes_2(out, &dot[0], 1) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_64(out, &e.method_call_name[0], e.method_call_name_len) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 40) != 0) {
        return -1;
      }
      let mi: i32 = 0;
      while (mi < e.method_call_num_args) {
        if (mi > 0) {
          let comma: u8[3] = [44, 32, 0];
          if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
            return -1;
          }
        }
        let m_arg: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, mi);
        if (ast.ref_is_null(m_arg)) {
          if (codegen_append_byte(out, 48) != 0) {
            return -1;
          }
        /* PLATFORM: SHARED — residual method_call args: slice pointer ABI. */
        } else if (emit_call_arg_slice_abi(arena, out, m_arg, ctx) != 0) {
          return -1;
        }
        mi = mi + 1;
      }
      if (codegen_append_byte(out, 41) != 0) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    /**
     * PLATFORM: SHARED — host-C EXPR_MATCH nested ternary (wave326).
     * Residual: arm 0 only → always first result (e.g. match x {1=>40;2=>42;_=>7}
     * with x=2 returned 40). Freestanding ELF already complete via
     * pipeline_asm_emit_match_elf_c; host path must compare subject.
     * G.7: complete this emit authority; seed codegen_gen twin same commit.
     */
    if ((e.kind as i32) == (ExprKind.EXPR_MATCH as i32)) {
      if (e.match_num_arms <= 0) {
        return codegen_append_byte(out, 48);
      }
      return codegen_emit_match_from_arm(arena, out, expr_ref, ctx, 0);
    }
    /* See implementation. */
    if ((e.kind as i32) == (ExprKind.EXPR_STRUCT_LIT as i32)) {
      /*
       * Anonymous `{ fields }` (no type name) must still emit a complete C tag.
       * Entry-module typeck backfills struct_lit_struct_name (typeck.x); dep
       * co-emit under host-C `-o` can leave the name empty, so the module prefix
       * alone becomes incomplete `struct core_result_` while signatures use
       * `struct core_result_Result_i32` (cookbook http_chunked_decode BLD001).
       * Recover dest TYPE_NAMED from resolved_type_ref (peel TYPE_ARRAY/PTR/SLICE
       * so `{f}` inside `Iovec[4] = [{...}]` is Iovec, not empty prefix), else
       * the enclosing function return type; existing skip_abi_dup / prefix rewrite
       * then applies (Result_* → core_result_; Iovec → std_io_sync_).
       * Mutates the local Expr copy only.
       * G.7: complete this STRUCT_LIT emit (pair typeck backfill); no second tagger.
       * PLATFORM: SHARED host-C.
       */
      if (e.struct_lit_struct_name_len <= 0) {
        let rec_ty: i32 = e.resolved_type_ref;
        if (ast.ref_is_null(rec_ty)) {
          rec_ty = pipeline_expr_resolved_type_ref(arena, expr_ref);
        }
        rec_ty = codegen_peel_named_dest_type(arena, rec_ty);
        if (ast.ref_is_null(rec_ty) && ctx != 0 as *PipelineDepCtx
            && ctx.current_codegen_module != 0 as *Module
            && ctx.current_func_index >= 0) {
          rec_ty = codegen_peel_named_dest_type(arena,
            pipeline_module_func_return_type_at(ctx.current_codegen_module, ctx.current_func_index));
        }
        if (!ast.ref_is_null(rec_ty)
            && pipeline_type_kind_ord_at(arena, rec_ty) == (TypeKind.TYPE_NAMED as i32)) {
          let rec_nm: u8[256] = [];
          let rec_nl: i32 = pipeline_type_named_name_into(arena, rec_ty, &rec_nm[0]);
          if (rec_nl > 0 && rec_nl <= 255) {
            let rec_i: i32 = 0;
            while (rec_i < rec_nl) {
              e.struct_lit_struct_name[rec_i] = rec_nm[rec_i];
              rec_i = rec_i + 1;
            }
            e.struct_lit_struct_name_len = rec_nl;
          }
        }
      }
      let sl_pfx: u8[256] = [];
      let sl_plen: i32 = codegen_emit_prefix_len_from_ctx(ctx, &sl_pfx[0], 128);
      let bare_user_lit: i32 = 0;
      /*
       * PLATFORM: SHARED — compound lit must use defining-module C tag.
       * Entry/ctx prefix alone yields parser_Token while the full def is token_Token
       * (or lexer_Token pollution) → incomplete type (parser M1 host-cc residual).
       * Authority: codegen_type_dep_struct_owner_index (same as codegen_emit_type).
       */
      if (ctx != 0 as *PipelineDepCtx && e.struct_lit_struct_name_len > 0) {
        let lit_bare_off: i32 = 0;
        let lit_bi: i32 = 0;
        while (lit_bi < e.struct_lit_struct_name_len && lit_bi < 64) {
          if (e.struct_lit_struct_name[lit_bi] == 46) {
            lit_bare_off = lit_bi + 1;
          }
          lit_bi = lit_bi + 1;
        }
        let lit_bare_len: i32 = e.struct_lit_struct_name_len - lit_bare_off;
        if (lit_bare_len > 0) {
          let lit_owner: i32 = codegen_type_dep_struct_owner_index(ctx, &e.struct_lit_struct_name[lit_bare_off], lit_bare_len);
          if (lit_owner >= 0) {
            let lit_path: u8[256] = [];
            let lit_plen: i32 = codegen_dep_import_path_len_at(ctx, lit_owner, &lit_path[0]);
            if (lit_plen > 0) {
              codegen_import_path_to_c_prefix_into(&lit_path[0], &sl_pfx[0], 128);
              sl_plen = 0;
              while (sl_plen < 128 && sl_pfx[sl_plen] != 0 as u8) {
                sl_plen = sl_plen + 1;
              }
            }
          }
        }
      }
      if (sl_plen == 0 && ctx != 0 as *PipelineDepCtx && ctx.current_codegen_dep_index < 0 && ctx.current_codegen_module != 0 as *Module) {
        let modu: *Module = ctx.current_codegen_module;
        let sk: i32 = 0;
        while (sk < modu.num_struct_layouts) {
          let snl: i32 = pipeline_module_struct_layout_name_len(modu, sk);
          if (snl == e.struct_lit_struct_name_len && snl > 0) {
            let snm: u8[256] = [];
            pipeline_module_struct_layout_name_into(modu, sk, &snm[0]);
            let eq2: bool = true;
            let sj: i32 = 0;
            while (sj < snl && sj < 64) {
              if (snm[sj] != e.struct_lit_struct_name[sj]) {
                eq2 = false;
                break;
              }
              sj = sj + 1;
            }
            if (eq2) {
              bare_user_lit = 1;
              break;
            }
          }
          sk = sk + 1;
        }
      }
      /*
       * Preamble ABI types: compound lit must use the defining-module C tag, not the
       * entry-module prefix. Catch-all std_net_ was wrong for Option_* → incomplete
       * std_net_Option_i32 (option/si matrix red under force-regen).
       * PLATFORM: SHARED — align with seed pin + codegen_emit_type Option_/Result_ authority.
       */
      if (codegen_should_skip_emit_struct_layout_for_abi_dup(&e.struct_lit_struct_name[0], e.struct_lit_struct_name_len) != 0) {
        bare_user_lit = 0;
        if (e.struct_lit_struct_name_len == 6 && e.struct_lit_struct_name[0] == 66) {
          /* Buffer → std_io_driver_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 105; sl_pfx[5] = 111; sl_pfx[6] = 95; sl_pfx[7] = 100;
          sl_pfx[8] = 114; sl_pfx[9] = 105; sl_pfx[10] = 118; sl_pfx[11] = 101;
          sl_pfx[12] = 114; sl_pfx[13] = 95; sl_pfx[14] = 0;
          sl_plen = 14;
        } else if (e.struct_lit_struct_name_len == 5 && e.struct_lit_struct_name[0] == 69) {
          /* Error → std_error_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 101; sl_pfx[5] = 114; sl_pfx[6] = 114; sl_pfx[7] = 111;
          sl_pfx[8] = 114; sl_pfx[9] = 95; sl_pfx[10] = 0;
          sl_plen = 10;
        } else if (e.struct_lit_struct_name_len == 10
            && e.struct_lit_struct_name[0] == 69 && e.struct_lit_struct_name[5] == 67) {
          /* ErrorChain → std_error_ (pair codegen_emit_type canonical tag). */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 101; sl_pfx[5] = 114; sl_pfx[6] = 114; sl_pfx[7] = 111;
          sl_pfx[8] = 114; sl_pfx[9] = 95; sl_pfx[10] = 0;
          sl_plen = 10;
        } else if (e.struct_lit_struct_name_len == 9
            && e.struct_lit_struct_name[0] == 65 && e.struct_lit_struct_name[1] == 108
            && e.struct_lit_struct_name[2] == 108 && e.struct_lit_struct_name[3] == 111) {
          /* Allocator → std_heap_ (pair codegen_emit_type canonical tag). */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 104; sl_pfx[5] = 101; sl_pfx[6] = 97; sl_pfx[7] = 112;
          sl_pfx[8] = 95; sl_pfx[9] = 0;
          sl_plen = 9;
        } else if (e.struct_lit_struct_name_len == 7
            && e.struct_lit_struct_name[0] == 65 && e.struct_lit_struct_name[1] == 114
            && e.struct_lit_struct_name[2] == 101 && e.struct_lit_struct_name[3] == 110
            && e.struct_lit_struct_name[4] == 97 && e.struct_lit_struct_name[5] == 54
            && e.struct_lit_struct_name[6] == 52) {
          /* Arena64 → std_heap_ (pair codegen_emit_type canonical tag). */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 104; sl_pfx[5] = 101; sl_pfx[6] = 97; sl_pfx[7] = 112;
          sl_pfx[8] = 95; sl_pfx[9] = 0;
          sl_plen = 9;
        } else if (e.struct_lit_struct_name_len >= 8 && e.struct_lit_struct_name[0] == 79
            && e.struct_lit_struct_name[1] == 112 && e.struct_lit_struct_name[2] == 116
            && e.struct_lit_struct_name[3] == 105 && e.struct_lit_struct_name[4] == 111
            && e.struct_lit_struct_name[5] == 110 && e.struct_lit_struct_name[6] == 95) {
          /* Option_* → core_option_ (same invariant as codegen_emit_type monomorph path) */
          sl_pfx[0] = 99; sl_pfx[1] = 111; sl_pfx[2] = 114; sl_pfx[3] = 101;
          sl_pfx[4] = 95; sl_pfx[5] = 111; sl_pfx[6] = 112; sl_pfx[7] = 116;
          sl_pfx[8] = 105; sl_pfx[9] = 111; sl_pfx[10] = 110; sl_pfx[11] = 95;
          sl_pfx[12] = 0;
          sl_plen = 12;
        } else if (e.struct_lit_struct_name_len == 9 && e.struct_lit_struct_name[0] == 82) {
          /* Result_u8 → core_result_ */
          sl_pfx[0] = 99; sl_pfx[1] = 111; sl_pfx[2] = 114; sl_pfx[3] = 101;
          sl_pfx[4] = 95; sl_pfx[5] = 114; sl_pfx[6] = 101; sl_pfx[7] = 115;
          sl_pfx[8] = 117; sl_pfx[9] = 108; sl_pfx[10] = 116; sl_pfx[11] = 95;
          sl_pfx[12] = 0;
          sl_plen = 12;
        } else if (e.struct_lit_struct_name_len == 10 && e.struct_lit_struct_name[0] == 82
            && e.struct_lit_struct_name[7] == 105) {
          /* Result_i32 → core_result_ */
          sl_pfx[0] = 99; sl_pfx[1] = 111; sl_pfx[2] = 114; sl_pfx[3] = 101;
          sl_pfx[4] = 95; sl_pfx[5] = 114; sl_pfx[6] = 101; sl_pfx[7] = 115;
          sl_pfx[8] = 117; sl_pfx[9] = 108; sl_pfx[10] = 116; sl_pfx[11] = 95;
          sl_pfx[12] = 0;
          sl_plen = 12;
        } else if (e.struct_lit_struct_name_len == 6 && e.struct_lit_struct_name[0] == 83 && e.struct_lit_struct_name[1] == 116 && e.struct_lit_struct_name[2] == 114 && e.struct_lit_struct_name[3] == 105) {
          /* String → std_string_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 115; sl_pfx[5] = 116; sl_pfx[6] = 114; sl_pfx[7] = 105;
          sl_pfx[8] = 110; sl_pfx[9] = 103; sl_pfx[10] = 95; sl_pfx[11] = 0;
          sl_plen = 11;
        } else if (e.struct_lit_struct_name_len == 7 && e.struct_lit_struct_name[0] == 83 && e.struct_lit_struct_name[3] == 86) {
          /* StrView → std_string_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 115; sl_pfx[5] = 116; sl_pfx[6] = 114; sl_pfx[7] = 105;
          sl_pfx[8] = 110; sl_pfx[9] = 103; sl_pfx[10] = 95; sl_pfx[11] = 0;
          sl_plen = 11;
        } else if (e.struct_lit_struct_name_len == 9 && e.struct_lit_struct_name[0] == 84) {
          /* TcpStream → std_net_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 110; sl_pfx[5] = 101; sl_pfx[6] = 116; sl_pfx[7] = 95;
          sl_pfx[8] = 0;
          sl_plen = 8;
        } else if (e.struct_lit_struct_name_len == 11 && e.struct_lit_struct_name[0] == 84) {
          /* TcpListener → std_net_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 110; sl_pfx[5] = 101; sl_pfx[6] = 116; sl_pfx[7] = 95;
          sl_pfx[8] = 0;
          sl_plen = 8;
        } else if (e.struct_lit_struct_name_len == 10 && e.struct_lit_struct_name[0] == 70 && e.struct_lit_struct_name[1] == 115) {
          /* FsIovecBuf → std_fs_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 102; sl_pfx[5] = 115; sl_pfx[6] = 95; sl_pfx[7] = 0;
          sl_plen = 7;
        } else if (e.struct_lit_struct_name_len == 5 && e.struct_lit_struct_name[0] == 73 && e.struct_lit_struct_name[1] == 111) {
          /* Iovec → std_io_sync_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 105; sl_pfx[5] = 111; sl_pfx[6] = 95;
          sl_pfx[7] = 115; sl_pfx[8] = 121; sl_pfx[9] = 110; sl_pfx[10] = 99;
          sl_pfx[11] = 95; sl_pfx[12] = 0;
          sl_plen = 12;
        }
        /* other abi_dup names: keep sl_pfx from ctx (do not force std_net_) */
      }
      /*
       * wave352 Cap residual pure: STRUCT_LIT TYPE_ARRAY field + CALL/METHOD_CALL init.
       * Root: use_elem_expand emitted `{ fill(n)[0], fill(n)[1], fill(n)[2] }` (N calls;
       * side effects ×N) and host array return is still a dangling stack compound
       * (warning + UB if not copied immediately once).
       * G.7: when any field is CALL/METHOD + fixed TYPE_ARRAY, wrap the whole compound
       * in a GNU stmt-expr: materialize each such CALL once into `static E __xlang_aaK[N]`,
       * immediate element copy (captures dangle before clobber), then brace-expand from
       * the static. Mirrors wave341 durable static / wave345 stmt-expr materialize.
       * Soft: reentrancy last-wins on static temps; freestanding already wave351.
       * PLATFORM: SHARED host-C emit (seed pin same commit).
       */
      let nf_codegen: i32 = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
      let need_call_mat: i32 = 0;
      let si_scan: i32 = 0;
      while (si_scan < nf_codegen) {
        let iref_s: i32 = pipeline_expr_struct_lit_init_ref(arena, expr_ref, si_scan);
        if (!ast.ref_is_null(iref_s)) {
          let ie_s: Expr = ast.ast_arena_expr_get(arena, iref_s);
          if ((ie_s.kind as i32) == (ExprKind.EXPR_CALL as i32) || (ie_s.kind as i32) == (ExprKind.EXPR_METHOD_CALL as i32)) {
            let fnbuf_s: u8[256] = [];
            pipeline_expr_struct_lit_field_name_into(arena, expr_ref, si_scan, &fnbuf_s[0]);
            let flen_s: i32 = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, si_scan);
            /* wave588 Cap residual: content ≤255 (name[256]); do not clamp designator lookup to 64. */
            if (flen_s > 127) {
              flen_s = 127;
            }
            let ftr_s: i32 = codegen_lookup_struct_field_type_ref(
              arena, ctx, &e.struct_lit_struct_name[0], e.struct_lit_struct_name_len, &fnbuf_s[0], flen_s);
            let arr_ty_s: i32 = 0;
            if (!ast.ref_is_null(ftr_s)
                && pipeline_type_kind_ord_at(arena, ftr_s) == (TypeKind.TYPE_ARRAY as i32)) {
              arr_ty_s = ftr_s;
            } else if (!ast.ref_is_null(ie_s.resolved_type_ref)
                && pipeline_type_kind_ord_at(arena, ie_s.resolved_type_ref) == (TypeKind.TYPE_ARRAY as i32)) {
              arr_ty_s = ie_s.resolved_type_ref;
            }
            if (!ast.ref_is_null(arr_ty_s)) {
              let asz_s: i32 = pipeline_type_array_size_at(arena, arr_ty_s);
              if (asz_s > 0 && asz_s <= 512) {
                need_call_mat = 1;
              }
            }
          }
        }
        si_scan = si_scan + 1;
      }
      if (need_call_mat != 0) {
        /* ({  */
        let mat_open: u8[4] = [40, 123, 32, 0];
        if (codegen_emit_bytes_4(out, &mat_open[0], 3) != 0) {
          return -1;
        }
        let mi: i32 = 0;
        while (mi < nf_codegen) {
          let iref_m: i32 = pipeline_expr_struct_lit_init_ref(arena, expr_ref, mi);
          if (ast.ref_is_null(iref_m)) {
            mi = mi + 1;
            continue;
          }
          let ie_m: Expr = ast.ast_arena_expr_get(arena, iref_m);
          if ((ie_m.kind as i32) != (ExprKind.EXPR_CALL as i32) && (ie_m.kind as i32) != (ExprKind.EXPR_METHOD_CALL as i32)) {
            mi = mi + 1;
            continue;
          }
          let fnbuf_m: u8[256] = [];
          pipeline_expr_struct_lit_field_name_into(arena, expr_ref, mi, &fnbuf_m[0]);
          let flen_m: i32 = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, mi);
          /* wave588 Cap residual: content ≤255 (name[256]). */
          if (flen_m > 127) {
            flen_m = 127;
          }
          let ftr_m: i32 = codegen_lookup_struct_field_type_ref(
            arena, ctx, &e.struct_lit_struct_name[0], e.struct_lit_struct_name_len, &fnbuf_m[0], flen_m);
          let arr_ty_m: i32 = 0;
          if (!ast.ref_is_null(ftr_m)
              && pipeline_type_kind_ord_at(arena, ftr_m) == (TypeKind.TYPE_ARRAY as i32)) {
            arr_ty_m = ftr_m;
          } else if (!ast.ref_is_null(ie_m.resolved_type_ref)
              && pipeline_type_kind_ord_at(arena, ie_m.resolved_type_ref) == (TypeKind.TYPE_ARRAY as i32)) {
            arr_ty_m = ie_m.resolved_type_ref;
          }
          if (ast.ref_is_null(arr_ty_m)) {
            mi = mi + 1;
            continue;
          }
          let asz_m: i32 = pipeline_type_array_size_at(arena, arr_ty_m);
          if (asz_m <= 0 || asz_m > 512) {
            mi = mi + 1;
            continue;
          }
          let elem_m: i32 = pipeline_type_elem_ref_at(arena, arr_ty_m);
          /* static E __xlang_aaK[N]; E *__xlang_apK = CALL; copy elems */
          let st_kw: u8[8] = [115, 116, 97, 116, 105, 99, 32, 0];
          if (codegen_emit_bytes_from_ptr(out, &st_kw[0], 7) != 0) {
            return -1;
          }
          if (ast.ref_is_null(elem_m) || codegen_emit_type(arena, out, elem_m, 0 as *u8, 0, ctx) != 0) {
            let fb_i32: u8[9] = [105, 110, 116, 51, 50, 95, 116, 0, 0];
            if (codegen_emit_bytes_from_ptr(out, &fb_i32[0], 7) != 0) {
              return -1;
            }
          }
          /*  __xlang_aa */
          let aa_nm: u8[12] = [32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 97, 0];
          if (codegen_emit_bytes_from_ptr(out, &aa_nm[0], 11) != 0) {
            return -1;
          }
          if (format_int(out, mi as i64) != 0) {
            return -1;
          }
          if (codegen_append_byte(out, 91) != 0) {
            return -1;
          }
          if (format_int(out, asz_m as i64) != 0) {
            return -1;
          }
          /* ];  */
          let aa_end: u8[4] = [93, 59, 32, 0];
          if (codegen_emit_bytes_from_ptr(out, &aa_end[0], 3) != 0) {
            return -1;
          }
          if (ast.ref_is_null(elem_m) || codegen_emit_type(arena, out, elem_m, 0 as *u8, 0, ctx) != 0) {
            let fb_i32b: u8[9] = [105, 110, 116, 51, 50, 95, 116, 0, 0];
            if (codegen_emit_bytes_from_ptr(out, &fb_i32b[0], 7) != 0) {
              return -1;
            }
          }
          /*  *__xlang_ap */
          let ap_nm: u8[14] = [32, 42, 95, 95, 120, 108, 97, 110, 103, 95, 97, 112, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &ap_nm[0], 12) != 0) {
            return -1;
          }
          if (format_int(out, mi as i64) != 0) {
            return -1;
          }
          /*  =  */
          let ap_eq: u8[4] = [32, 61, 32, 0];
          if (codegen_emit_bytes_4(out, &ap_eq[0], 3) != 0) {
            return -1;
          }
          if (codegen_emit_expr(arena, out, iref_m, ctx) != 0) {
            return -1;
          }
          /* ;  */
          let ap_sc: u8[4] = [59, 32, 0, 0];
          if (codegen_emit_bytes_4(out, &ap_sc[0], 2) != 0) {
            return -1;
          }
          let ai_m: i32 = 0;
          while (ai_m < asz_m) {
            /* __xlang_aaK[ */
            let cp_aa: u8[12] = [95, 95, 120, 108, 97, 110, 103, 95, 97, 97, 0, 0];
            if (codegen_emit_bytes_from_ptr(out, &cp_aa[0], 10) != 0) {
              return -1;
            }
            if (format_int(out, mi as i64) != 0) {
              return -1;
            }
            if (codegen_append_byte(out, 91) != 0) {
              return -1;
            }
            if (format_int(out, ai_m as i64) != 0) {
              return -1;
            }
            /* ] = __xlang_apK[ */
            let cp_mid: u8[16] = [93, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 112, 0, 0];
            if (codegen_emit_bytes_from_ptr(out, &cp_mid[0], 14) != 0) {
              return -1;
            }
            if (format_int(out, mi as i64) != 0) {
              return -1;
            }
            if (codegen_append_byte(out, 91) != 0) {
              return -1;
            }
            if (format_int(out, ai_m as i64) != 0) {
              return -1;
            }
            /* ];  */
            let cp_end: u8[4] = [93, 59, 32, 0];
            if (codegen_emit_bytes_from_ptr(out, &cp_end[0], 3) != 0) {
              return -1;
            }
            ai_m = ai_m + 1;
          }
          mi = mi + 1;
        }
      }
      let open: u8[9] = [40, 115, 116, 114, 117, 99, 116, 32, 0];
      if (codegen_emit_bytes_9(out, &open[0], 8) != 0) {
        return -1;
      }
      /*
       * wave458: STRUCT_LIT name mono subst (`return T { .v = 7 }` under mono).
       * codegen_emit_type already rewrites TYPE_NAMED T→A for signatures/lets, but
       * STRUCT_LIT emits the source type name string. When mono_active and the
       * lit name equals a mapped generic param name, emit the concrete type name
       * (and keep module prefix) so host C gets `struct …_A` not incomplete T.
       * PLATFORM: SHARED — G.7 same mono map as codegen_emit_type C5.
       */
      let sl_emit_name: u8[256] = [];
      let sl_emit_nlen: i32 = e.struct_lit_struct_name_len;
      let sl_ni: i32 = 0;
      while (sl_ni < sl_emit_nlen && sl_ni < 64) {
        sl_emit_name[sl_ni] = e.struct_lit_struct_name[sl_ni];
        sl_ni = sl_ni + 1;
      }
      if (ctx != 0 as *PipelineDepCtx && ctx.mono_active != 0 && ctx.mono_num_types > 0
          && sl_emit_nlen > 0) {
        let mi_sl: i32 = 0;
        while (mi_sl < ctx.mono_num_types && mi_sl < 8) {
          let gtr_sl: i32 = ctx.mono_generic_type_refs[mi_sl];
          let ctr_sl: i32 = ctx.mono_concrete_type_refs[mi_sl];
          if (gtr_sl > 0 && ctr_sl > 0 && ctr_sl != gtr_sl) {
            let gnm_sl: u8[256] = [];
            let gnl_sl: i32 = pipeline_type_named_name_into(arena, gtr_sl, &gnm_sl[0]);
            if (gnl_sl == sl_emit_nlen && gnl_sl > 0) {
              let eq_sl: i32 = 1;
              let bi_sl: i32 = 0;
              while (bi_sl < gnl_sl) {
                if (gnm_sl[bi_sl] != sl_emit_name[bi_sl]) {
                  eq_sl = 0;
                  bi_sl = gnl_sl;
                } else {
                  bi_sl = bi_sl + 1;
                }
              }
              if (eq_sl != 0) {
                let cnm_sl: u8[256] = [];
                let cnl_sl: i32 = pipeline_type_named_name_into(arena, ctr_sl, &cnm_sl[0]);
                if (cnl_sl > 0 && cnl_sl <= 64) {
                  let ci_sl: i32 = 0;
                  while (ci_sl < cnl_sl) {
                    sl_emit_name[ci_sl] = cnm_sl[ci_sl];
                    ci_sl = ci_sl + 1;
                  }
                  sl_emit_nlen = cnl_sl;
                }
                mi_sl = ctx.mono_num_types;
              }
            }
          }
          mi_sl = mi_sl + 1;
        }
      }
      if (bare_user_lit == 0 && sl_plen > 0 && codegen_emit_bytes_from_ptr(out, &sl_pfx[0], sl_plen) != 0) {
        return -1;
      }
      if (codegen_emit_bytes_64(out, &sl_emit_name[0], sl_emit_nlen) != 0) {
        return -1;
      }
      /*
       * wave481/484: STRUCT_LIT compound tag must match mono mangled defs.
       * wave484: **prefer field-init combo first** — nested Wrap { inner: Wrap {…} }
       * often stamps ambient outer resolved_type_ref on every lit (same Wrap&lt;Wrap&lt;A&gt;&gt;),
       * which made middle lit emit Wrap__Wrap_A instead of Wrap__A (BLD001).
       * Field inits encode true nesting; resolved_type_ref is fallback for typed sites.
       * PLATFORM: SHARED host-C.
       */
      if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module) {
        let mod_sl: *Module = ctx.current_codegen_module;
        let rty_sl: i32 = e.resolved_type_ref;
        let did_mono: i32 = 0;
        // (0) wave484: structural field mono (nested Wrap lit; ignore ambient type).
        {
          let st0: i32 = codegen_try_emit_struct_lit_mono_from_fields(mod_sl, arena, out, expr_ref, &sl_emit_name[0], sl_emit_nlen, ctx);
          if (st0 < 0) {
            return -1;
          }
          if (st0 > 0) {
            did_mono = 1;
          }
        }
        // (1) Field-init combo via type_ref (legacy path when structural not applicable).
        if (did_mono == 0) {
          let lk2: i32 = codegen_module_struct_layout_index_by_name(mod_sl, &sl_emit_name[0], sl_emit_nlen);
          if (lk2 >= 0) {
            let ntp2: i32 = pipeline_module_struct_layout_num_type_params_at(mod_sl, lk2);
            if (ntp2 > 0 && ntp2 <= 4) {
              let combo_sl: i32[4] = [];
              let filled_sl: i32 = 0;
              let ok_sl: i32 = 1;
              let tj_sl: i32 = 0;
              while (tj_sl < ntp2) {
                combo_sl[tj_sl] = 0;
                tj_sl = tj_sl + 1;
              }
              let nf_lay: i32 = pipeline_module_struct_layout_num_fields(mod_sl, lk2);
              let fj_sl: i32 = 0;
              while (fj_sl < nf_lay) {
                let ftr_sl: i32 = pipeline_module_struct_layout_field_type_ref(mod_sl, lk2, fj_sl);
                if (pipeline_type_kind_ord_at(arena, ftr_sl) == (TypeKind.TYPE_NAMED as i32)) {
                  let ftn_sl: u8[256] = [];
                  let ftnl_sl: i32 = pipeline_type_named_name_into(arena, ftr_sl, &ftn_sl[0]);
                  let slot_sl: i32 = -1;
                  let pj_sl: i32 = 0;
                  while (pj_sl < ntp2) {
                    let tpl_sl: i32 = pipeline_module_struct_layout_type_param_name_len(mod_sl, lk2, pj_sl);
                    if (tpl_sl == ftnl_sl && ftnl_sl > 0) {
                      let tpn_sl: u8[256] = [];
                      pipeline_module_struct_layout_type_param_name_into(mod_sl, lk2, pj_sl, &tpn_sl[0]);
                      let peq_sl: i32 = 1;
                      let pi_sl: i32 = 0;
                      while (pi_sl < ftnl_sl) {
                        if (tpn_sl[pi_sl] != ftn_sl[pi_sl]) {
                          peq_sl = 0;
                        }
                        pi_sl = pi_sl + 1;
                      }
                      if (peq_sl != 0) {
                        slot_sl = pj_sl;
                        pj_sl = ntp2;
                      }
                    }
                    pj_sl = pj_sl + 1;
                  }
                  if (slot_sl >= 0) {
                    let flen_sl: i32 = pipeline_module_struct_layout_field_name_len(mod_sl, lk2, fj_sl);
                    let fnm_sl: u8[256] = [];
                    pipeline_module_struct_layout_field_name_into(mod_sl, lk2, fj_sl, &fnm_sl[0]);
                    let lit_nf_sl: i32 = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
                    let li_sl: i32 = 0;
                    while (li_sl < lit_nf_sl) {
                      let lfl_sl: i32 = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, li_sl);
                      if (lfl_sl == flen_sl && flen_sl > 0) {
                        let lfn_sl: u8[256] = [];
                        pipeline_expr_struct_lit_field_name_into(arena, expr_ref, li_sl, &lfn_sl[0]);
                        let feq_sl: i32 = 1;
                        let fi_sl: i32 = 0;
                        while (fi_sl < flen_sl) {
                          if (lfn_sl[fi_sl] != fnm_sl[fi_sl]) {
                            feq_sl = 0;
                          }
                          fi_sl = fi_sl + 1;
                        }
                        if (feq_sl != 0) {
                          let iref_sl: i32 = pipeline_expr_struct_lit_init_ref(arena, expr_ref, li_sl);
                          if (iref_sl > 0) {
                            let ity_sl: i32 = pipeline_expr_resolved_type_ref(arena, iref_sl);
                            if (ity_sl > 0 && codegen_type_ref_is_host_concrete(mod_sl, arena, ity_sl) != 0) {
                              if (combo_sl[slot_sl] == 0) {
                                combo_sl[slot_sl] = ity_sl;
                                filled_sl = filled_sl + 1;
                              }
                            }
                          }
                          li_sl = lit_nf_sl;
                        }
                      }
                      li_sl = li_sl + 1;
                    }
                  }
                }
                fj_sl = fj_sl + 1;
              }
              let sc_sl: i32 = 0;
              while (sc_sl < ntp2) {
                if (combo_sl[sc_sl] <= 0) {
                  ok_sl = 0;
                }
                sc_sl = sc_sl + 1;
              }
              if (ok_sl != 0 && filled_sl > 0) {
                if (codegen_emit_generic_struct_mono_suffix(out, arena, &combo_sl[0], ntp2) != 0) {
                  return -1;
                }
                did_mono = 1;
              }
            }
          }
        }
        // (2) Fallback: resolved_type_ref type-pos args (typed let / ret ambient).
        if (did_mono == 0 && rty_sl > 0) {
          if (codegen_maybe_emit_generic_struct_mono_suffix_for_type(mod_sl, arena, out, rty_sl, ctx) != 0) {
            return -1;
          }
          let mono_chk: i32[4] = [];
          let lk_sl: i32 = codegen_module_struct_layout_index_by_name(mod_sl, &sl_emit_name[0], sl_emit_nlen);
          if (lk_sl >= 0) {
            let ntp_sl: i32 = pipeline_module_struct_layout_num_type_params_at(mod_sl, lk_sl);
            if (ntp_sl > 0 && codegen_generic_struct_fill_concrete_args(mod_sl, arena, rty_sl, ntp_sl, &mono_chk[0], ctx) == ntp_sl) {
              did_mono = 1;
            }
          }
        }
        /*
         * (3) wave481: generic function mono body bare Pair { a: x, b: y } —
         * map layout type-params through ctx.mono_* (T→A,U→B).
         * PLATFORM: SHARED host-C mono.
         */
        if (did_mono == 0 && ctx.mono_active != 0 && ctx.mono_num_types > 0) {
          let lk_m: i32 = codegen_module_struct_layout_index_by_name(mod_sl, &sl_emit_name[0], sl_emit_nlen);
          if (lk_m >= 0) {
            let ntp_m: i32 = pipeline_module_struct_layout_num_type_params_at(mod_sl, lk_m);
            if (ntp_m > 0 && ntp_m <= 4) {
              let combo_m: i32[4] = [];
              let ok_m: i32 = 1;
              let tj_m: i32 = 0;
              while (tj_m < ntp_m) {
                combo_m[tj_m] = 0;
                let tpl_m: i32 = pipeline_module_struct_layout_type_param_name_len(mod_sl, lk_m, tj_m);
                let tpn_m: u8[256] = [];
                pipeline_module_struct_layout_type_param_name_into(mod_sl, lk_m, tj_m, &tpn_m[0]);
                let mi_m: i32 = 0;
                while (mi_m < ctx.mono_num_types && mi_m < 8) {
                  let gtr_m: i32 = ctx.mono_generic_type_refs[mi_m];
                  let ctr_m: i32 = ctx.mono_concrete_type_refs[mi_m];
                  if (gtr_m > 0 && ctr_m > 0) {
                    let gnm_m: u8[256] = [];
                    let gnl_m: i32 = pipeline_type_named_name_into(arena, gtr_m, &gnm_m[0]);
                    if (gnl_m == tpl_m && gnl_m > 0) {
                      let geq: i32 = 1;
                      let gi: i32 = 0;
                      while (gi < gnl_m) {
                        if (gnm_m[gi] != tpn_m[gi]) {
                          geq = 0;
                        }
                        gi = gi + 1;
                      }
                      if (geq != 0) {
                        combo_m[tj_m] = ctr_m;
                        mi_m = ctx.mono_num_types;
                      }
                    }
                  }
                  mi_m = mi_m + 1;
                }
                if (combo_m[tj_m] <= 0) {
                  ok_m = 0;
                }
                tj_m = tj_m + 1;
              }
              if (ok_m != 0) {
                if (codegen_emit_generic_struct_mono_suffix(out, arena, &combo_m[0], ntp_m) != 0) {
                  return -1;
                }
                did_mono = 1;
              }
            }
          }
        }
      }
      let open2: u8[5] = [41, 123, 32, 0, 0];
      if (emit_bytes_5(out, &open2[0], 3) != 0) {
        return -1;
      }
      let fi: i32 = 0;
      while (fi < nf_codegen) {
        if (fi > 0) {
          let comma: u8[3] = [44, 32, 0];
          if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
            return -1;
          }
        }
        if (codegen_append_byte(out, 46) != 0) {
          return -1;
        }
        let sl_fnbuf: u8[256] = [];
        pipeline_expr_struct_lit_field_name_into(arena, expr_ref, fi, &sl_fnbuf[0]);
        let flen: i32 = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, fi);
        /* wave588 Cap residual: host-C field designator content ≤255 (StructLitFieldEntry.name[256]).
         * Prior flen>64 trunc to 64 → designator mismatch vs layout field decl (fldh 75/127 BLD001).
         * PLATFORM: SHARED host-C; seed pin same commit. */
        if (flen > 255) {
          flen = 127;
        }
        if (flen > 0 && codegen_emit_bytes_from_ptr(out, &sl_fnbuf[0], flen) != 0) {
          return -1;
        }
        let eq: u8[4] = [32, 61, 32, 0];
        if (codegen_emit_bytes_4(out, &eq[0], 3) != 0) {
          return -1;
        }
        /* STRUCT_LIT array fields: C designated init cannot take an array/pointer RHS.
         * - EXPR_ARRAY_LIT empty → `{ 0 }`; non-empty → codegen_emit_braced_array_lit_init
         * - VAR/param (u8[N] or decayed *u8) → expand `.name = { src[0], …, src[N-1] }`
         *   (parser M1 host-cc residual: `.name = z64` / `.name = name64` illegal).
         * - CALL/METHOD (wave352): brace-expand from materialize static __xlang_aaK
         * Do NOT codegen_emit_expr alone for TYPE_ARRAY fields (pointer-to-integer on first elem).
         * PLATFORM: SHARED — seed pin same commit; verify parser.x -E host-cc. */
        let init_ref: i32 = pipeline_expr_struct_lit_init_ref(arena, expr_ref, fi);
        if (!ast.ref_is_null(init_ref)) {
          let init_e: Expr = ast.ast_arena_expr_get(arena, init_ref);
          if ((init_e.kind as i32) == (ExprKind.EXPR_ARRAY_LIT as i32)) {
            if (init_e.array_lit_num_elems == 0) {
              let zero_init: u8[6] = [123, 32, 48, 32, 125, 0];
              if (emit_bytes_6(out, &zero_init[0], 5) != 0) {
                return -1;
              }
            } else {
              if (codegen_emit_braced_array_lit_init(arena, out, init_ref, ctx) != 0) {
                return -1;
              }
            }
          } else {
            let use_elem_expand: i32 = 0;
            let arr_sz: i32 = 0;
            let flen_lk: i32 = flen;
            if (flen_lk > 127) {
              flen_lk = 127;
            }
            let ftr: i32 = codegen_lookup_struct_field_type_ref(
              arena, ctx, &e.struct_lit_struct_name[0], e.struct_lit_struct_name_len, &sl_fnbuf[0], flen_lk);
            if (!ast.ref_is_null(ftr)
                && pipeline_type_kind_ord_at(arena, ftr) == (TypeKind.TYPE_ARRAY as i32)) {
              arr_sz = pipeline_type_array_size_at(arena, ftr);
              if (arr_sz > 0 && arr_sz <= 512) {
                use_elem_expand = 1;
              }
            } else if (!ast.ref_is_null(init_e.resolved_type_ref)
                && pipeline_type_kind_ord_at(arena, init_e.resolved_type_ref) == (TypeKind.TYPE_ARRAY as i32)) {
              arr_sz = pipeline_type_array_size_at(arena, init_e.resolved_type_ref);
              if (arr_sz > 0 && arr_sz <= 512) {
                use_elem_expand = 1;
              }
            }
            let is_call_init: i32 = 0;
            if ((init_e.kind as i32) == (ExprKind.EXPR_CALL as i32) || (init_e.kind as i32) == (ExprKind.EXPR_METHOD_CALL as i32)) {
              is_call_init = 1;
            }
            if (use_elem_expand != 0 && is_call_init != 0 && need_call_mat != 0) {
              /* { __xlang_aaK[0], …, __xlang_aaK[N-1] } — single materialize above */
              if (codegen_append_byte(out, 123) != 0) {
                return -1;
              }
              let ai_c: i32 = 0;
              while (ai_c < arr_sz) {
                if (ai_c > 0) {
                  let cm_c: u8[3] = [44, 32, 0];
                  if (codegen_emit_bytes_3(out, &cm_c[0], 2) != 0) {
                    return -1;
                  }
                }
                let aa_rd: u8[12] = [95, 95, 120, 108, 97, 110, 103, 95, 97, 97, 0, 0];
                if (codegen_emit_bytes_from_ptr(out, &aa_rd[0], 10) != 0) {
                  return -1;
                }
                if (format_int(out, fi as i64) != 0) {
                  return -1;
                }
                if (codegen_append_byte(out, 91) != 0) {
                  return -1;
                }
                if (format_int(out, ai_c as i64) != 0) {
                  return -1;
                }
                if (codegen_append_byte(out, 93) != 0) {
                  return -1;
                }
                ai_c = ai_c + 1;
              }
              if (codegen_append_byte(out, 125) != 0) {
                return -1;
              }
            } else if (use_elem_expand != 0) {
              if (codegen_append_byte(out, 123) != 0) {
                return -1;
              }
              let ai: i32 = 0;
              while (ai < arr_sz) {
                if (ai > 0) {
                  let cm: u8[3] = [44, 32, 0];
                  if (codegen_emit_bytes_3(out, &cm[0], 2) != 0) {
                    return -1;
                  }
                }
                if (codegen_emit_expr(arena, out, init_ref, ctx) != 0) {
                  return -1;
                }
                if (codegen_append_byte(out, 91) != 0) {
                  return -1;
                }
                if (format_int(out, ai as i64) != 0) {
                  return -1;
                }
                if (codegen_append_byte(out, 93) != 0) {
                  return -1;
                }
                ai = ai + 1;
              }
              if (codegen_append_byte(out, 125) != 0) {
                return -1;
              }
            } else {
              if (codegen_emit_expr(arena, out, init_ref, ctx) != 0) {
                return -1;
              }
            }
          }
        }
        fi = fi + 1;
      }
      if (need_call_mat != 0) {
        /*  }; }) */
        let mat_close: u8[8] = [32, 125, 59, 32, 125, 41, 0, 0];
        return codegen_emit_bytes_from_ptr(out, &mat_close[0], 6);
      }
      let close: u8[4] = [32, 125, 0, 0];
      return codegen_emit_bytes_4(out, &close[0], 2);
    }
    /* See implementation. */
    if ((e.kind as i32) == (ExprKind.EXPR_ARRAY_LIT as i32)) {
      let n: i32 = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
      let elem_type_ref: i32 = 0;
      let is_slice: i32 = 0;
      let is_vector: i32 = 0;
      if (!ast.ref_is_null(e.resolved_type_ref) && e.resolved_type_ref > 0 && e.resolved_type_ref <= arena.num_types) {
        let ty: Type = ast.ast_arena_type_get(arena, e.resolved_type_ref);
        if ((ty.kind as i32) == (TypeKind.TYPE_SLICE as i32)) {
          is_slice = 1;
          elem_type_ref = ty.elem_type_ref;
        } else if ((ty.kind as i32) == (TypeKind.TYPE_ARRAY as i32)) {
          elem_type_ref = ty.elem_type_ref;
        } else if ((ty.kind as i32) == (TypeKind.TYPE_VECTOR as i32)) {
          /* See implementation. */
          is_vector = 1;
        } else if ((ty.kind as i32) == (TypeKind.TYPE_NAMED as i32) && ty.name_len >= 5) {
          /* See implementation. */
          let ni: i32 = 0;
          while (ni < ty.name_len) {
            if (ty.name[ni] == 120) {
              is_vector = 1;
              ni = ty.name_len;
            } else {
              ni = ni + 1;
            }
          }
        }
      }
      if (is_vector != 0) {
        /* (vec_ty){ e0, e1, ... } compound literal */
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        if (codegen_emit_type(arena, out, e.resolved_type_ref, 0 as *u8, 0, ctx) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 41) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 123) != 0) {
          return -1;
        }
        let vai: i32 = 0;
        while (vai < n) {
          if (vai > 0) {
            let comma: u8[3] = [44, 32, 0];
            if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
              return -1;
            }
          }
          if (!ast.ref_is_null(pipeline_expr_array_lit_elem_ref(arena, expr_ref, vai))
              && codegen_emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, expr_ref, vai), ctx) != 0) {
            return -1;
          }
          vai = vai + 1;
        }
        let vclose: u8[4] = [32, 125, 0, 0];
        return codegen_emit_bytes_4(out, &vclose[0], 2);
      }
      if (elem_type_ref == 0 && n > 0) {
        let first_ref: i32 = pipeline_expr_array_lit_elem_ref(arena, expr_ref, 0);
        if (!ast.ref_is_null(first_ref)) {
          let first_e: Expr = ast.ast_arena_expr_get(arena, first_ref);
          elem_type_ref = first_e.resolved_type_ref;
        }
      }
      if (is_slice != 0) {
        /*
         * wave335 Cap residual pure: TYPE_SLICE + ARRAY_LIT durable static when all elems
         * are compile-time LIT/BOOL_LIT (return-safe; matches freestanding text-embed).
         * wave340: non-const elems cannot be `static E __xlang_al[] = {n,…}` (C rejects
         * non-constant initializers) — temporarily used block compound.
         * wave341: non-const also durable via runtime-filled static buffer (return-safe):
         *   const → ({ static E __xlang_al[]={…}; (slice){.data=__xlang_al,.length=N}; })
         *   non-const → ({ static E __xlang_al[N]; __xlang_al[i]=ei; …;
         *                 (slice){.data=__xlang_al,.length=N}; })
         * Reentrancy: last-call wins (same as const static); Minimal Core OK.
         * PLATFORM: SHARED host-C emit.
         */
        if (n == 0) {
          /* Empty: null data is durable; no static needed. */
          if (codegen_append_byte(out, 40) != 0) {
            return -1;
          }
          if (codegen_emit_type(arena, out, e.resolved_type_ref, 0 as *u8, 0, ctx) != 0) {
            let fallback: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
            if (codegen_emit_bytes_9(out, &fallback[0], 7) != 0) {
              return -1;
            }
          }
          let empty_tail: u8[40] = [41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 40, 118, 111, 105, 100, 32, 42, 41, 48, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 48, 32, 125, 0, 0, 0, 0, 0];
          /* ){ .data = (void *)0, .length = 0 } */
          if (codegen_emit_bytes_from_ptr(out, &empty_tail[0], 35) != 0) {
            return -1;
          }
          return 0;
        }
        /*
         * [][N]T ARRAY_LIT: elem is TYPE_ARRAY. codegen_emit_type(ARRAY) is `E *` (param
         * decay) so the scalar-slice path emitted `static int32_t *al[]` and
         * INDEX `(x).data[0][1]` was i32[1] (BLD001). G.7: same durable static
         * as scalar slices; payload is `E al[][N]` / memcpy rows. Tag comes
         * from type_to_c_repr (`xlang_slice_xlang_arrN_…`).
         * Seed twin: codegen_gen.linux.x86_64.c dest-SLICE ARRAY_LIT elem=ARRAY
         * (live `-E` is host-cc of that seed). Do not fork a second init.
         * PLATFORM: SHARED host-C emit.
         */
        let elem_is_arr: i32 = 0;
        if (!ast.ref_is_null(elem_type_ref) && elem_type_ref > 0 && elem_type_ref <= arena.num_types) {
          if (pipeline_type_kind_ord_at(arena, elem_type_ref) == (TypeKind.TYPE_ARRAY as i32)) {
            elem_is_arr = 1;
          }
        }
        if (elem_is_arr != 0) {
          let row_const: i32 = codegen_array_lit_tree_is_const(arena, expr_ref);
          /*
           * `[][N][]T`: tree_is_const is 1 (every leaf is LIT) but
           * emit_braced of ARRAY-of-SLICE injects GNU stmt-expr rows
           * `({ static E inner[]={…}; (slice){.data=inner,.length=K}; })`.
           * Those are not C constant expressions, so
           * `static E al[][N] = {{ stmt-expr, … }}` is BLD001
           * (initializer element is not a compile-time constant).
           * Sit-red dyn_add_slice_arr_slice true host-C cc fail
           * (asm already 7; Darwin `--backend c -o` is often an
           * asm-sized fake host-C binary).
           * Do not broaden tree_is_const — file-scope dest-SLICE
           * ARRAY_LIT still needs "leaf lits" = 1 with
           * codegen_emit_file_scope_dest_slice_array_lit (block-scope
           * `(E[]){…}` would dangle).
           * ADDR_OF `[][N]*T` already fails tree_is_const (not LIT).
           * G.7: same memcpy path as non-const `[][N]T` rows (wave341).
           * One peel: elem of `[N][]T` is TYPE_SLICE.
           * PLATFORM: SHARED host-C.
           */
          if (row_const != 0 && !ast.ref_is_null(elem_type_ref)
              && elem_type_ref > 0 && elem_type_ref <= arena.num_types) {
            let row_e: i32 = pipeline_type_elem_ref_at(arena, elem_type_ref);
            if (!ast.ref_is_null(row_e) && row_e > 0 && row_e <= arena.num_types
                && pipeline_type_kind_ord_at(arena, row_e) == (TypeKind.TYPE_SLICE as i32)) {
              row_const = 0;
            }
          }
          /* ({ static  */
          let ar_open: u8[12] = [40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &ar_open[0], 10) != 0) {
            return -1;
          }
          if (codegen_emit_local_fixed_array_elem_type(arena, out, elem_type_ref, ctx) != 0) {
            let fb_ar: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
            if (codegen_emit_bytes_9(out, &fb_ar[0], 7) != 0) {
              return -1;
            }
          }
          /*  __xlang_al */
          let ar_nm: u8[12] = [32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 108, 0];
          if (codegen_emit_bytes_from_ptr(out, &ar_nm[0], 11) != 0) {
            return -1;
          }
          if (row_const != 0) {
            /* [] */
            if (codegen_append_byte(out, 91) != 0) {
              return -1;
            }
            if (codegen_append_byte(out, 93) != 0) {
              return -1;
            }
            if (codegen_emit_local_fixed_array_suffix(arena, out, elem_type_ref) != 0) {
              return -1;
            }
            /*  =  */
            let ar_eq: u8[4] = [32, 61, 32, 0];
            if (codegen_emit_bytes_4(out, &ar_eq[0], 3) != 0) {
              return -1;
            }
            if (codegen_emit_braced_array_lit_init(arena, out, expr_ref, ctx) != 0) {
              return -1;
            }
            /* ;  */
            let ar_sc: u8[4] = [59, 32, 0, 0];
            if (codegen_emit_bytes_from_ptr(out, &ar_sc[0], 2) != 0) {
              return -1;
            }
          } else {
            /* [n] */
            if (codegen_append_byte(out, 91) != 0) {
              return -1;
            }
            if (format_int(out, n) != 0) {
              return -1;
            }
            if (codegen_append_byte(out, 93) != 0) {
              return -1;
            }
            if (codegen_emit_local_fixed_array_suffix(arena, out, elem_type_ref) != 0) {
              return -1;
            }
            /* ;  */
            let ar_sc2: u8[4] = [59, 32, 0, 0];
            if (codegen_emit_bytes_from_ptr(out, &ar_sc2[0], 2) != 0) {
              return -1;
            }
            let ai_ar: i32 = 0;
            while (ai_ar < n) {
              /* memcpy((void*)(__xlang_al[ */
              let mcp: u8[32] = [
                109, 101, 109, 99, 112, 121, 40, 40, 118, 111, 105, 100, 42, 41, 40, 95,
                95, 120, 108, 97, 110, 103, 95, 97, 108, 91, 0, 0, 0, 0, 0, 0
              ];
              if (codegen_emit_bytes_from_ptr(out, &mcp[0], 26) != 0) {
                return -1;
              }
              if (format_int(out, ai_ar) != 0) {
                return -1;
              }
              /* ]), (const void*)( */
              let mcp_m: u8[20] = [93, 41, 44, 32, 40, 99, 111, 110, 115, 116, 32, 118, 111, 105, 100, 42, 41, 40, 0, 0];
              if (codegen_emit_bytes_from_ptr(out, &mcp_m[0], 18) != 0) {
                return -1;
              }
              if (!ast.ref_is_null(pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai_ar))
                  && codegen_emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai_ar), ctx) != 0) {
                return -1;
              }
              /* ), sizeof(__xlang_al[ */
              let mcp_sz: u8[24] = [
                41, 44, 32, 115, 105, 122, 101, 111, 102, 40, 95, 95, 120, 108, 97, 110,
                103, 95, 97, 108, 91, 0, 0, 0
              ];
              if (codegen_emit_bytes_from_ptr(out, &mcp_sz[0], 21) != 0) {
                return -1;
              }
              if (format_int(out, ai_ar) != 0) {
                return -1;
              }
              /* ]));  */
              let mcp_t: u8[8] = [93, 41, 41, 59, 32, 0, 0, 0];
              if (codegen_emit_bytes_from_ptr(out, &mcp_t[0], 5) != 0) {
                return -1;
              }
              ai_ar = ai_ar + 1;
            }
          }
          /* ( */
          if (codegen_append_byte(out, 40) != 0) {
            return -1;
          }
          if (codegen_emit_type(arena, out, e.resolved_type_ref, 0 as *u8, 0, ctx) != 0) {
            let fb_sl: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
            if (codegen_emit_bytes_9(out, &fb_sl[0], 7) != 0) {
              return -1;
            }
          }
          /* ){ .data = __xlang_al, .length =  */
          let ar_mid: u8[36] = [41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 108, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &ar_mid[0], 33) != 0) {
            return -1;
          }
          if (format_int(out, n) != 0) {
            return -1;
          }
          /*  }; }) */
          let ar_end: u8[8] = [32, 125, 59, 32, 125, 41, 0, 0];
          return codegen_emit_bytes_from_ptr(out, &ar_end[0], 6);
        }
        /* All elems EXPR_LIT(0)/BOOL_LIT(2) → durable static (wave335); else block compound. */
        let all_const: i32 = 1;
        let ci: i32 = 0;
        while (ci < n) {
          let er: i32 = pipeline_expr_array_lit_elem_ref(arena, expr_ref, ci);
          if (ast.ref_is_null(er)) {
            all_const = 0;
          } else {
            let ek: i32 = pipeline_expr_kind_ord_at(arena, er);
            if (ek != 0 && ek != 2) {
              all_const = 0;
            }
          }
          ci = ci + 1;
        }
        if (all_const != 0) {
          /* ({ static  */
          let open_stmt: u8[12] = [40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &open_stmt[0], 10) != 0) {
            return -1;
          }
          if (!ast.ref_is_null(elem_type_ref) && codegen_emit_type(arena, out, elem_type_ref, 0 as *u8, 0, ctx) != 0) {
            let fallback: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
            if (codegen_emit_bytes_9(out, &fallback[0], 7) != 0) {
              return -1;
            }
          }
          /*  __xlang_al[] = { */
          let al_head: u8[18] = [32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 108, 91, 93, 32, 61, 32, 123, 0];
          if (codegen_emit_bytes_from_ptr(out, &al_head[0], 17) != 0) {
            return -1;
          }
          let ai: i32 = 0;
          while (ai < n) {
            if (ai > 0) {
              let comma: u8[3] = [44, 32, 0];
              if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
                return -1;
              }
            }
            if (!ast.ref_is_null(pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai)) && codegen_emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai), ctx) != 0) {
              return -1;
            }
            ai = ai + 1;
          }
          /* }; ( */
          let mid: u8[6] = [125, 59, 32, 40, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &mid[0], 4) != 0) {
            return -1;
          }
          if (codegen_emit_type(arena, out, e.resolved_type_ref, 0 as *u8, 0, ctx) != 0) {
            let fallback: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
            if (codegen_emit_bytes_9(out, &fallback[0], 7) != 0) {
              return -1;
            }
          }
          /* ){ .data = __xlang_al, .length =  */
          let slice_mid: u8[36] = [41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 108, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &slice_mid[0], 33) != 0) {
            return -1;
          }
          if (format_int(out, ai) != 0) {
            return -1;
          }
          /*  }; }) */
          let slice_end: u8[8] = [32, 125, 59, 32, 125, 41, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &slice_end[0], 6) != 0) {
            return -1;
          }
          return 0;
        }
        /*
         * wave341 Cap residual pure: non-const TYPE_SLICE + ARRAY_LIT durable static fill.
         * Root: wave340 block compound `(E[]){n,…}` has automatic duration → return dangles
         * (Ubuntu/host `return [n,n+10,n+20]` idx garbage; length OK).
         * G.7: same static authority as const path; runtime stores for non-const elems.
         * Emit: ({ static E __xlang_al[N]; __xlang_al[i]=ei; …; (slice){.data=__xlang_al,.length=N}; })
         * PLATFORM: SHARED host-C emit.
         */
        /* ({ static  */
        let nc_open: u8[12] = [40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &nc_open[0], 10) != 0) {
          return -1;
        }
        /*
         * dest-SLICE of PTR-to-ARRAY (`[]*[N]T`): codegen_emit_type peels
         * `*[N]T` to first-element `E *` so the buffer was
         * `static int32_t * __xlang_al[1]; al[0]=&(row)` (sit-red
         * incompatible-pointer-types vs `int32_t (*)[2]`). G.7: same
         * declarator as codegen_emit_c_ptr_to_fixed_array_decl —
         * `E (*__xlang_al[n])[N]`. Scalar `[]*T` stays `E * al[n]`.
         * PLATFORM: SHARED host-C.
         */
        if (!ast.ref_is_null(elem_type_ref) && type_is_ptr_to_fixed_array(arena, elem_type_ref) != 0) {
          let pal_arr: i32 = pipeline_type_elem_ref_at(arena, elem_type_ref);
          if (codegen_emit_local_fixed_array_elem_type(arena, out, pal_arr, ctx) != 0) {
            let fb_pal: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
            if (codegen_emit_bytes_9(out, &fb_pal[0], 7) != 0) {
              return -1;
            }
          }
          /*  (*__xlang_al[ */
          let pal_h: u8[16] = [32, 40, 42, 95, 95, 120, 108, 97, 110, 103, 95, 97, 108, 91, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &pal_h[0], 14) != 0) {
            return -1;
          }
          if (format_int(out, n) != 0) {
            return -1;
          }
          /* ]) */
          let pal_t: u8[4] = [93, 41, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &pal_t[0], 2) != 0) {
            return -1;
          }
          if (codegen_emit_local_fixed_array_suffix(arena, out, pal_arr) != 0) {
            return -1;
          }
          /* ;  */
          let pal_sc: u8[4] = [59, 32, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &pal_sc[0], 2) != 0) {
            return -1;
          }
        } else {
          if (!ast.ref_is_null(elem_type_ref) && codegen_emit_type(arena, out, elem_type_ref, 0 as *u8, 0, ctx) != 0) {
            let fallback: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
            if (codegen_emit_bytes_9(out, &fallback[0], 7) != 0) {
              return -1;
            }
          }
          /*  __xlang_al[ */
          let nc_al_br: u8[14] = [32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 108, 91, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &nc_al_br[0], 12) != 0) {
            return -1;
          }
          if (format_int(out, n) != 0) {
            return -1;
          }
          /* ];  */
          let nc_sz_end: u8[4] = [93, 59, 32, 0];
          if (codegen_emit_bytes_from_ptr(out, &nc_sz_end[0], 3) != 0) {
            return -1;
          }
        }
        let ai_nc: i32 = 0;
        while (ai_nc < n) {
          /* __xlang_al[ */
          let nc_asg_h: u8[14] = [95, 95, 120, 108, 97, 110, 103, 95, 97, 108, 91, 0, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &nc_asg_h[0], 11) != 0) {
            return -1;
          }
          if (format_int(out, ai_nc) != 0) {
            return -1;
          }
          /* ] =  */
          let nc_asg_m: u8[6] = [93, 32, 61, 32, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &nc_asg_m[0], 4) != 0) {
            return -1;
          }
          /*
           * Dest-elem TYPE_SLICE + VAR/FIELD TYPE_ARRAY (`[][]T = [a]`):
           * assign a typed fat, not `__xlang_al[i]=a` (array into slice = BLD001).
           * G.7: reuse try_emit_slice_init_from_array_var. PLATFORM: SHARED host-C.
           * Seed twin: codegen_gen.linux.x86_64.c dest-SLICE ARRAY_LIT wrap_nc
           * (live `-E` is host-cc of that seed). Do not fork a second wrap.
           */
          let er_nc: i32 = pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai_nc);
          let wrap_nc: i32 = 0;
          if (!ast.ref_is_null(er_nc) && !ast.ref_is_null(elem_type_ref)
              && pipeline_type_kind_ord_at(arena, elem_type_ref) == (TypeKind.TYPE_SLICE as i32)) {
            let br_nc: i32 = 0;
            let nlets_nc: i32 = 0;
            if (ctx != 0 as *PipelineDepCtx) {
              br_nc = ctx.current_block_ref;
              if ((ast.ref_is_null(br_nc) || br_nc <= 0 || br_nc > arena.num_blocks)
                  && ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0) {
                br_nc = pipeline_module_func_body_ref_at(ctx.current_codegen_module, ctx.current_func_index);
              }
              if (!ast.ref_is_null(br_nc) && br_nc > 0 && br_nc <= arena.num_blocks) {
                nlets_nc = ast_ast_block_num_lets(arena, br_nc);
              }
            }
            wrap_nc = try_emit_slice_init_from_array_var(arena, out, br_nc, nlets_nc, elem_type_ref, er_nc, ctx);
            if (wrap_nc == 0) {
              wrap_nc = try_emit_dest_slice_from_module_array_var(arena, out, elem_type_ref, er_nc, ctx);
            }
          }
          if (wrap_nc < 0) {
            return -1;
          }
          if (wrap_nc == 0 && !ast.ref_is_null(er_nc) && codegen_emit_expr(arena, out, er_nc, ctx) != 0) {
            return -1;
          }
          /* ;  */
          let nc_asg_t: u8[4] = [59, 32, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &nc_asg_t[0], 2) != 0) {
            return -1;
          }
          ai_nc = ai_nc + 1;
        }
        /* ( */
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        if (codegen_emit_type(arena, out, e.resolved_type_ref, 0 as *u8, 0, ctx) != 0) {
          let fallback: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
          if (codegen_emit_bytes_9(out, &fallback[0], 7) != 0) {
            return -1;
          }
        }
        /* ){ .data = __xlang_al, .length =  */
        let nc_slice_mid: u8[36] = [41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 108, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &nc_slice_mid[0], 33) != 0) {
          return -1;
        }
        if (format_int(out, ai_nc) != 0) {
          return -1;
        }
        /*  }; }) */
        let nc_slice_end: u8[8] = [32, 125, 59, 32, 125, 41, 0, 0];
        if (codegen_emit_bytes_from_ptr(out, &nc_slice_end[0], 6) != 0) {
          return -1;
        }
        return 0;
      } else {
        /*
         * [K][N]T ARRAY_LIT: codegen_emit_type(elem) is `E *` so this path produced
         * `(int32_t *[]){(int32_t[]){1,2},…}` = E **. Wrapper/impl want
         * `E (*)[N]`. Sit-red dyn_add_arr2 host-C 219 after wrapper
         * named-array. G.7: `(E[][N]){{…}}` via existing
         * codegen_emit_local_fixed_array_elem_type + suffix + braced init
         * (twin of [][N]T slice path). PLATFORM: SHARED host-C.
         */
        let elem_is_arr: i32 = 0;
        let elem_is_ptr_arr: i32 = 0;
        if (!ast.ref_is_null(elem_type_ref) && elem_type_ref > 0 && elem_type_ref <= arena.num_types) {
          if (pipeline_type_kind_ord_at(arena, elem_type_ref) == (TypeKind.TYPE_ARRAY as i32)) {
            elem_is_arr = 1;
          }
          if (type_is_ptr_to_fixed_array(arena, elem_type_ref) != 0) {
            elem_is_ptr_arr = 1;
          }
        }
        if (elem_is_arr != 0) {
          if (codegen_append_byte(out, 40) != 0) {
            return -1;
          }
          if (codegen_emit_local_fixed_array_elem_type(arena, out, elem_type_ref, ctx) != 0) {
            let fb_md: u8[9] = [105, 110, 116, 51, 50, 95, 116, 0, 0];
            if (codegen_emit_bytes_9(out, &fb_md[0], 7) != 0) {
              return -1;
            }
          }
          if (codegen_append_byte(out, 91) != 0) {
            return -1;
          }
          if (codegen_append_byte(out, 93) != 0) {
            return -1;
          }
          if (codegen_emit_local_fixed_array_suffix(arena, out, elem_type_ref) != 0) {
            return -1;
          }
          if (codegen_append_byte(out, 41) != 0) {
            return -1;
          }
          if (codegen_emit_braced_array_lit_init(arena, out, expr_ref, ctx) != 0) {
            return -1;
          }
          return 0;
        }
        /*
         * `[K]*[N]T` ARRAY_LIT extra: codegen_emit_type(`*[N]T`) peels to `E *` so
         * this path produced `(int32_t *[]){&r0,&r1}` vs wrapper
         * `int32_t (**)[2]`. Sit-red dyn_add_arr_ptr_arr host-C
         * incompatible-pointer-types. G.7: `(E (*[])[N]){…}` twin of
         * dest-SLICE `E (*al[n])[N]`. Scalar `[K]*T` stays `(E[]){…}`.
         * PLATFORM: SHARED host-C.
         */
        if (elem_is_ptr_arr != 0) {
          let pal_arr: i32 = pipeline_type_elem_ref_at(arena, elem_type_ref);
          if (codegen_append_byte(out, 40) != 0) {
            return -1;
          }
          if (codegen_emit_local_fixed_array_elem_type(arena, out, pal_arr, ctx) != 0) {
            let fb_pa: u8[9] = [105, 110, 116, 51, 50, 95, 116, 0, 0];
            if (codegen_emit_bytes_9(out, &fb_pa[0], 7) != 0) {
              return -1;
            }
          }
          /*  (*[]) */
          let pa_mid: u8[8] = [32, 40, 42, 91, 93, 41, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &pa_mid[0], 6) != 0) {
            return -1;
          }
          if (codegen_emit_local_fixed_array_suffix(arena, out, pal_arr) != 0) {
            return -1;
          }
          if (codegen_append_byte(out, 41) != 0) {
            return -1;
          }
          if (codegen_emit_braced_array_lit_init(arena, out, expr_ref, ctx) != 0) {
            return -1;
          }
          return 0;
        }
        /* Scalar-elem ARRAY_LIT: `(E[]){ e0, e1, … }`. */
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        if (ast.ref_is_null(elem_type_ref) || codegen_emit_type(arena, out, elem_type_ref, 0 as *u8, 0, ctx) != 0) {
          let fallback: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
          if (codegen_emit_bytes_9(out, &fallback[0], 7) != 0) {
            return -1;
          }
        }
        let arr: u8[5] = [91, 93, 41, 123, 0];
        if (emit_bytes_5(out, &arr[0], 4) != 0) {
          return -1;
        }
      }
      let ai: i32 = 0;
      while (ai < n) {
        if (ai > 0) {
          let comma: u8[3] = [44, 32, 0];
          if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
            return -1;
          }
        }
        if (!ast.ref_is_null(pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai)) && codegen_emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai), ctx) != 0) {
          return -1;
        }
        ai = ai + 1;
      }
      let close: u8[4] = [32, 125, 0, 0];
      return codegen_emit_bytes_4(out, &close[0], 2);
    }
    /* See implementation. */
    if ((e.kind as i32) == (ExprKind.EXPR_ENUM_VARIANT as i32)) {
      return codegen_append_byte(out, 48);
    }
    return -1;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_callee_var_is_string_new(e: Expr): i32 {
  if ((e.kind as i32) != (ExprKind.EXPR_VAR as i32)) {
    return 0;
  }
  if (e.var_name_len == 10) {
    let expect_sn: u8[10] = [115, 116, 114, 105, 110, 95, 110, 101, 119, 0];
    let i_sn: i32 = 0;
    while (i_sn < 9) {
      if (e.var_name[i_sn] != expect_sn[i_sn]) {
        return 0;
      }
      i_sn = i_sn + 1;
    }
    return 1;
  }
  if (e.var_name_len == 22) {
    let expect_ssn: u8[22] = [115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 115, 116, 114, 105, 110, 95, 110, 101, 119, 0, 0];
    let i_ssn: i32 = 0;
    while (i_ssn < 20) {
      if (e.var_name[i_ssn] != expect_ssn[i_ssn]) {
        return 0;
      }
      i_ssn = i_ssn + 1;
    }
    return 1;
  }
  return 0;
}

/*
 * One-shot handoff: last dest-from-region dest emit consumes this so
 * wrapping defers already hoisted inner-first are not run again.
 * codegen_emit_block copies it into a local and clears it so prefix / sibling
 * codegen_emit_block children stay skip=0. Both stmt_order>0 last-dest and
 * stmt_order==0 dest-region-body (defer pool + final_expr dest) honor
 * it. Not a second emit path.
 * PLATFORM: SHARED host-C dest-from-region dest-region-body last-wins.
 */
let g_codegen_skip_wrap_dest: i32 = 0;

/**
 * Run wrapping defers of a dest-from-region last so_k==6 dest chain,
 * inner first then this block (dest-in-rbx LIFO last-wins outer).
 * host-C GNU stmt-expr still needs dest last, so the caller hoists
 * this walk then this wrapping, then emits dest with skip-wrap.
 * @param arena *ASTArena — AST owner
 * @param out *CodegenOutBuf — C text sink
 * @param block_ref i32 — dest-from-region last dest body; null is a no-op
 * @param indent i32 — spaces of indent for each defer body
 * @param ctx *PipelineDepCtx — current func / module for nested emit
 * @return i32 — 0 ok, -1 emit failure
 * PLATFORM: SHARED host-C dest-from-region stacked last-wins.
 */
function emit_run_dest_fromreg_wrapping_defers(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, indent: i32, ctx: *PipelineDepCtx): i32 {
  // Block counters are pipeline-runtime externs, so the body stays in unsafe.
  unsafe {
    if (ast.ref_is_null(block_ref) || block_ref <= 0 || block_ref > arena.num_blocks) {
      return 0;
    }
    let so_n: i32 = ast_ast_block_num_stmt_order(arena, block_ref);
    let final_now: i32 = ast_ast_block_final_expr_ref(arena, block_ref);
    if (so_n > 0 && ast.ref_is_null(final_now)) {
      let last_k: u8 = ast_ast_block_stmt_order_kind(arena, block_ref, so_n - 1);
      if (last_k == 6) {
        let last_idx: i32 = ast_ast_block_stmt_order_idx(arena, block_ref, so_n - 1);
        /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
        let nreg_wrap: i32 = ast_ast_block_num_regions(arena, block_ref);
        if (last_idx >= 0 && last_idx < nreg_wrap) {
          let last_body: i32 = ast_ast_block_region_body_ref(arena, block_ref, last_idx);
          if (emit_run_dest_fromreg_wrapping_defers(arena, out, last_body, indent, ctx) != 0) {
            return -1;
          }
        }
      }
    }
    return emit_run_defers(arena, out, block_ref, indent, ctx);
  }
}

/**
 * See implementation.
 */
export function emit_run_defers(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, indent: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let ndef: i32 = 0;
    while (ndef < 256) {
      if (pipeline_block_defer_body_ref(arena, block_ref, ndef) <= 0) {
        break;
      }
      ndef = ndef + 1;
    }
    let di: i32 = ndef - 1;
    while (di >= 0) {
      let dbody: i32 = pipeline_block_defer_body_ref(arena, block_ref, di);
      if (dbody > 0) {
        if (codegen_emit_block(arena, out, dbody, indent, ctx) != 0) {
          return -1;
        }
      }
      di = di - 1;
    }
    return 0;
  }
}

/** Exported function `codegen_current_func_returns_void`.
 * Implements `codegen_current_func_returns_void`.
 * @param arena *ASTArena
 * @param ctx *PipelineDepCtx
 * @return i32
 */
export function codegen_current_func_returns_void(arena: *ASTArena, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module || ctx.current_codegen_arena != arena || ctx.current_func_index < 0) {
      return 0;
    }
    let mod: *Module = ctx.current_codegen_module;
    if (ctx.current_func_index >= mod.num_funcs) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(mod, ctx.current_func_index)) == (TypeKind.TYPE_VOID as i32)) {
      return 1;
    }
    return 0;
  }
}

/** Return 1 when the current function is named the four bytes `main`.
 * Purpose: Zig-like void main maps to process exit 0 on the C entry symbol.
 * Parameters: ctx — dep context with current_codegen_module / current_func_index.
 * Returns: 1 if name is main, else 0.
 * PLATFORM: SHARED — language entry contract; dual-end product matrix.
 */
export function codegen_current_func_is_named_main(ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module || ctx.current_func_index < 0) {
      return 0;
    }
    let mod: *Module = ctx.current_codegen_module;
    if (ctx.current_func_index >= mod.num_funcs) {
      return 0;
    }
    let nlen: i32 = pipeline_module_func_name_len_at(mod, ctx.current_func_index);
    if (nlen != 4) {
      return 0;
    }
    let nm: u8[256] = [];
    codegen_copy_func_name64_from_module(mod, ctx.current_func_index, &nm[0]);
    if (nm[0] == 109 && nm[1] == 97 && nm[2] == 105 && nm[3] == 110) {
      return 1;
    }
    return 0;
  }
}

/**
 * Emit a C `return` statement with Cap-T001 / host-cc awareness.
 *
 * Why: Cap-T001 wrappers often end with typeck filler `return 0` after a real
 * `return glue(...)`. Bare `return 0` is illegal when the function returns a
 * struct by value (Lexer, OneFuncResult, …) → host-cc "returning 'int' from …".
 * For TYPE_NAMED returns, int-lit/empty `return 0` becomes
 * `return (struct Tag){0};` (valid C dead code).
 * PLATFORM: SHARED — seed pin same commit; verify parser.x host-cc.
 */
export function emit_return_stmt_with_context(arena: *ASTArena, out: *CodegenOutBuf, indent: i32, operand_ref: i32, ctx: *PipelineDepCtx, fn_ret_void: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    /*
     * wave374: `return match { … => { return N; }; }` — do not nest return in
     * ternary value position. Emit match as if/else with real returns.
     * Value-only match arms still use the normal `return (ternary…)` path below.
     * PLATFORM: SHARED — G.7 codegen_emit_match_as_stmt authority.
     */
    if (fn_ret_void == 0 && !ast.ref_is_null(operand_ref)) {
      let mop: Expr = ast.ast_arena_expr_get(arena, operand_ref);
      if ((mop.kind as i32) == (ExprKind.EXPR_MATCH as i32) && codegen_match_has_return_arm(arena, operand_ref) != 0) {
        return codegen_emit_match_as_stmt(arena, out, operand_ref, indent, ctx, fn_ret_void);
      }
    }

    if (fn_ret_void != 0) {
      if (!ast.ref_is_null(operand_ref)) {
        if (codegen_emit_indent(out, indent) != 0) {
          return -1;
        }
        let v: u8[9] = [40, 118, 111, 105, 100, 41, 40, 0, 0];
        if (codegen_emit_bytes_9(out, &v[0], 7) != 0) {
          return -1;
        }
        if (codegen_emit_expr(arena, out, operand_ref, ctx) != 0) {
          return -1;
        }
        let scv: u8[4] = [41, 59, 10, 0];
        if (codegen_emit_bytes_4(out, &scv[0], 3) != 0) {
          return -1;
        }
      }
      if (codegen_emit_indent(out, indent) != 0) {
        return -1;
      }
      /* PLATFORM: SHARED — Zig-like void main: process entry is C int32_t main, so
       * bare `return;` becomes `return 0;` (implicit exit code 0). Non-main void
       * functions keep a bare `return;`. */
      if (codegen_current_func_is_named_main(ctx) != 0) {
        let ret0: u8[12] = [114, 101, 116, 117, 114, 110, 32, 48, 59, 10, 0, 0];
        return codegen_emit_bytes_from_ptr(out, &ret0[0], 10);
      }
      let retv: u8[9] = [114, 101, 116, 117, 114, 110, 59, 10, 0];
      return codegen_emit_bytes_9(out, &retv[0], 8);
    }
    /* See implementation. */
    if (!ast.ref_is_null(operand_ref)) {
      if (pipeline_expr_kind_ord_at(arena, operand_ref) == (42 as i32)) {
        if (codegen_emit_indent(out, indent) != 0) {
          return -1;
        }
        if (codegen_emit_expr(arena, out, operand_ref, ctx) != 0) {
          return -1;
        }
        let sc_panic: u8[4] = [59, 10, 0, 0];
        return codegen_emit_bytes_4(out, &sc_panic[0], 2);
      }
    }
    /*
     * By-value struct + Cap-T001 filler `return 0`: host C rejects `return 0` for
     * incomplete/struct return types. Emit compound zero instead.
     */
    if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module
        && ctx.current_func_index >= 0 && ctx.current_func_index < ctx.current_codegen_module.num_funcs) {
      let rty: i32 = pipeline_module_func_return_type_at(ctx.current_codegen_module, ctx.current_func_index);
      /*
       * wave352 Cap residual pure: host `return` of fixed TYPE_ARRAY.
       * Root: codegen_emit_type lowers TYPE_ARRAY as `ELEM *`; `return (E[]){…}` is a
       * stack compound (clang -Wreturn-stack-address; -O2 clobbers → STRUCT_LIT
       * CALL field init sum garbage even after once-materialize).
       * G.7: durable static[N] fill then return pointer (wave341 slice static
       * authority; reentrancy last-wins soft). ARRAY_LIT stores elems; other
       * rvalues once-eval to pointer then element copy.
       * PLATFORM: SHARED host-C emit.
       */
      if (!ast.ref_is_null(rty) && pipeline_type_kind_ord_at(arena, rty) == (TypeKind.TYPE_ARRAY as i32)
          && !ast.ref_is_null(operand_ref)) {
        let arr_sz_r: i32 = pipeline_type_array_size_at(arena, rty);
        let elem_r: i32 = pipeline_type_elem_ref_at(arena, rty);
        if (arr_sz_r > 0 && arr_sz_r <= 512) {
          /*
           * `[K][N]T` return: codegen_emit_type(elem) is `E *`, so the 1D path
           * emitted `static E * __xlang_ar[K]; E ** rp = operand` — Ubuntu
           * rejects `int32_t ** rp = int32_t[K][N]`. Sit-red dyn_ret_arr2
           * / named-local (same produce). G.7: complete this wrap — durable
           * `static E __xlang_ar[K][N]` (peel+suffix) then memcpy / brace
           * init, return `(E *)__xlang_ar` so it matches codegen_emit_type decay.
           * 1D `[N]T` keeps the element-copy path below (already green).
           * PLATFORM: SHARED host-C emit; Ubuntu gold.
           */
          if (!ast.ref_is_null(elem_r)
              && pipeline_type_kind_ord_at(arena, elem_r) == (TypeKind.TYPE_ARRAY as i32)) {
            if (codegen_emit_indent(out, indent) != 0) {
              return -1;
            }
            /* return ({ static  */
            let md_open: u8[20] = [114, 101, 116, 117, 114, 110, 32, 40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0, 0];
            if (codegen_emit_bytes_from_ptr(out, &md_open[0], 17) != 0) {
              return -1;
            }
            if (codegen_emit_local_fixed_array_elem_type(arena, out, rty, ctx) != 0) {
              return -1;
            }
            /*  __xlang_ar */
            let md_nm: u8[12] = [32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 114, 0];
            if (codegen_emit_bytes_from_ptr(out, &md_nm[0], 11) != 0) {
              return -1;
            }
            if (codegen_emit_local_fixed_array_suffix(arena, out, rty) != 0) {
              return -1;
            }
            if (pipeline_expr_kind_ord_at(arena, operand_ref) == (ExprKind.EXPR_ARRAY_LIT as i32)) {
              /*  = {…};  */
              let md_eq: u8[4] = [32, 61, 32, 0];
              if (codegen_emit_bytes_4(out, &md_eq[0], 3) != 0) {
                return -1;
              }
              if (codegen_emit_braced_array_lit_init(arena, out, operand_ref, ctx) != 0) {
                return -1;
              }
              let md_sc: u8[4] = [59, 32, 0, 0];
              if (codegen_emit_bytes_4(out, &md_sc[0], 2) != 0) {
                return -1;
              }
            } else {
              /* ; memcpy((void*)( */
              let md_cp1: u8[20] = [59, 32, 109, 101, 109, 99, 112, 121, 40, 40, 118, 111, 105, 100, 42, 41, 40, 0, 0, 0];
              if (codegen_emit_bytes_from_ptr(out, &md_cp1[0], 17) != 0) {
                return -1;
              }
              let md_cpn: u8[12] = [95, 95, 120, 108, 97, 110, 103, 95, 97, 114, 0, 0];
              if (codegen_emit_bytes_from_ptr(out, &md_cpn[0], 10) != 0) {
                return -1;
              }
              /* ), (const void*)( */
              let md_cp2: u8[20] = [41, 44, 32, 40, 99, 111, 110, 115, 116, 32, 118, 111, 105, 100, 42, 41, 40, 0, 0, 0];
              if (codegen_emit_bytes_from_ptr(out, &md_cp2[0], 17) != 0) {
                return -1;
              }
              if (codegen_emit_expr(arena, out, operand_ref, ctx) != 0) {
                return -1;
              }
              /* ), sizeof(__xlang_ar));  */
              let md_cp3: u8[28] = [41, 44, 32, 115, 105, 122, 101, 111, 102, 40, 95, 95, 120, 108, 97, 110, 103, 95, 97, 114, 41, 41, 59, 32, 0, 0, 0, 0];
              if (codegen_emit_bytes_from_ptr(out, &md_cp3[0], 24) != 0) {
                return -1;
              }
            }
            /* ( */
            if (codegen_append_byte(out, 40) != 0) {
              return -1;
            }
            if (codegen_emit_local_fixed_array_elem_type(arena, out, rty, ctx) != 0) {
              return -1;
            }
            /*  *)__xlang_ar; });\n */
            let md_end: u8[22] = [32, 42, 41, 95, 95, 120, 108, 97, 110, 103, 95, 97, 114, 59, 32, 125, 41, 59, 10, 0, 0, 0];
            if (codegen_emit_bytes_from_ptr(out, &md_end[0], 19) != 0) {
              return -1;
            }
            return 0;
          }
          if (codegen_emit_indent(out, indent) != 0) {
            return -1;
          }
          /* return ({ static  */
          let ar_open: u8[20] = [114, 101, 116, 117, 114, 110, 32, 40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &ar_open[0], 17) != 0) {
            return -1;
          }
          if (ast.ref_is_null(elem_r) || codegen_emit_type(arena, out, elem_r, 0 as *u8, 0, ctx) != 0) {
            let fb_ar: u8[9] = [105, 110, 116, 51, 50, 95, 116, 0, 0];
            if (codegen_emit_bytes_from_ptr(out, &fb_ar[0], 7) != 0) {
              return -1;
            }
          }
          /*  __xlang_ar[ */
          let ar_nm: u8[14] = [32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 114, 91, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &ar_nm[0], 12) != 0) {
            return -1;
          }
          if (format_int(out, arr_sz_r as i64) != 0) {
            return -1;
          }
          /* ];  */
          let ar_sz_end: u8[4] = [93, 59, 32, 0];
          if (codegen_emit_bytes_from_ptr(out, &ar_sz_end[0], 3) != 0) {
            return -1;
          }
          let op_k: i32 = pipeline_expr_kind_ord_at(arena, operand_ref);
          if (op_k == (ExprKind.EXPR_ARRAY_LIT as i32)) {
            let n_lit: i32 = pipeline_expr_array_lit_num_elems_at(arena, operand_ref);
            let ai_r: i32 = 0;
            while (ai_r < arr_sz_r) {
              /* __xlang_ar[ */
              let ar_asg: u8[14] = [95, 95, 120, 108, 97, 110, 103, 95, 97, 114, 91, 0, 0, 0];
              if (codegen_emit_bytes_from_ptr(out, &ar_asg[0], 11) != 0) {
                return -1;
              }
              if (format_int(out, ai_r as i64) != 0) {
                return -1;
              }
              /* ] =  */
              let ar_eq: u8[6] = [93, 32, 61, 32, 0, 0];
              if (codegen_emit_bytes_from_ptr(out, &ar_eq[0], 4) != 0) {
                return -1;
              }
              if (ai_r < n_lit) {
                let er_r: i32 = pipeline_expr_array_lit_elem_ref(arena, operand_ref, ai_r);
                if (!ast.ref_is_null(er_r) && codegen_emit_expr(arena, out, er_r, ctx) != 0) {
                  return -1;
                } else if (ast.ref_is_null(er_r)) {
                  if (codegen_append_byte(out, 48) != 0) {
                    return -1;
                  }
                }
              } else {
                if (codegen_append_byte(out, 48) != 0) {
                  return -1;
                }
              }
              /* ;  */
              let ar_sc: u8[4] = [59, 32, 0, 0];
              if (codegen_emit_bytes_4(out, &ar_sc[0], 2) != 0) {
                return -1;
              }
              ai_r = ai_r + 1;
            }
          } else {
            /* E *__xlang_rp = <operand>; copy */
            if (ast.ref_is_null(elem_r) || codegen_emit_type(arena, out, elem_r, 0 as *u8, 0, ctx) != 0) {
              let fb_rp: u8[9] = [105, 110, 116, 51, 50, 95, 116, 0, 0];
              if (codegen_emit_bytes_from_ptr(out, &fb_rp[0], 7) != 0) {
                return -1;
              }
            }
            /*  *__xlang_rp =  */
            let rp_nm: u8[16] = [32, 42, 95, 95, 120, 108, 97, 110, 103, 95, 114, 112, 32, 61, 32, 0];
            if (codegen_emit_bytes_from_ptr(out, &rp_nm[0], 15) != 0) {
              return -1;
            }
            if (codegen_emit_expr(arena, out, operand_ref, ctx) != 0) {
              return -1;
            }
            /* ;  */
            let rp_sc: u8[4] = [59, 32, 0, 0];
            if (codegen_emit_bytes_4(out, &rp_sc[0], 2) != 0) {
              return -1;
            }
            let ai_c: i32 = 0;
            while (ai_c < arr_sz_r) {
              let cp_h: u8[14] = [95, 95, 120, 108, 97, 110, 103, 95, 97, 114, 91, 0, 0, 0];
              if (codegen_emit_bytes_from_ptr(out, &cp_h[0], 11) != 0) {
                return -1;
              }
              if (format_int(out, ai_c as i64) != 0) {
                return -1;
              }
              /* ] = __xlang_rp[ */
              let cp_m: u8[16] = [93, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 114, 112, 91, 0];
              if (codegen_emit_bytes_from_ptr(out, &cp_m[0], 15) != 0) {
                return -1;
              }
              if (format_int(out, ai_c as i64) != 0) {
                return -1;
              }
              let cp_e: u8[4] = [93, 59, 32, 0];
              if (codegen_emit_bytes_from_ptr(out, &cp_e[0], 3) != 0) {
                return -1;
              }
              ai_c = ai_c + 1;
            }
          }
          /* __xlang_ar; })\n */
          let ar_end: u8[20] = [95, 95, 120, 108, 97, 110, 103, 95, 97, 114, 59, 32, 125, 41, 59, 10, 0, 0, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &ar_end[0], 16) != 0) {
            return -1;
          }
          return 0;
        }
      }
      /*
       * [N]T → []T return: durable static copy then fat.
       * Stack view {.data=a,.length=N} dangles after return (wave342 lesson
       * on `return s` where s aliases a). ARRAY_LIT Path already durables;
       * already-typed VAR/FIELD/STRUCT_LIT.field need the same COMMON-like
       * static. Do not stamp SLICE (operand stays TYPE_ARRAY).
       * PLATFORM: SHARED host-C emit. G.7 complete emit_return wrap.
       * Seed twin: codegen_gen.linux.x86_64.c (live `-E` is host-cc of that seed).
       * Do not fork a second dest-SLICE RETURN ARRAY wrap.
       */
      if (!ast.ref_is_null(rty) && pipeline_type_kind_ord_at(arena, rty) == (TypeKind.TYPE_SLICE as i32)
          && !ast.ref_is_null(operand_ref)) {
        let op_tr: i32 = pipeline_expr_resolved_type_ref(arena, operand_ref);
        let rar_n: i32 = 0;
        let rar_elem: i32 = 0;
        if (op_tr > 0 && pipeline_type_kind_ord_at(arena, op_tr) == (TypeKind.TYPE_ARRAY as i32)) {
          rar_n = pipeline_type_array_size_at(arena, op_tr);
          rar_elem = pipeline_type_elem_ref_at(arena, op_tr);
        }
        if (rar_n > 0 && rar_n <= 1024 && !ast.ref_is_null(rar_elem)) {
          if (codegen_emit_indent(out, indent) != 0) {
            return -1;
          }
          /* return ({ static  */
          let rar_o: u8[20] = [114, 101, 116, 117, 114, 110, 32, 40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &rar_o[0], 17) != 0) {
            return -1;
          }
          if (codegen_emit_type(arena, out, rar_elem, 0 as *u8, 0, ctx) != 0) {
            let rar_fb: u8[9] = [105, 110, 116, 51, 50, 95, 116, 0, 0];
            if (codegen_emit_bytes_from_ptr(out, &rar_fb[0], 7) != 0) {
              return -1;
            }
          }
          /*  __xlang_rar[ */
          let rar_nm: u8[16] = [32, 95, 95, 120, 108, 97, 110, 103, 95, 114, 97, 114, 91, 0, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &rar_nm[0], 13) != 0) {
            return -1;
          }
          if (format_int(out, rar_n as i64) != 0) {
            return -1;
          }
          /* ]; memcpy(__xlang_rar, (const void*)( */
          let rar_cp: u8[48] = [
            93, 59, 32, 109, 101, 109, 99, 112, 121, 40, 95, 95, 120, 108, 97, 110, 103, 95, 114, 97, 114, 44, 32, 40, 99, 111, 110, 115, 116, 32, 118, 111, 105, 100, 42, 41, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
          ];
          if (codegen_emit_bytes_from_ptr(out, &rar_cp[0], 37) != 0) {
            return -1;
          }
          if (codegen_emit_expr(arena, out, operand_ref, ctx) != 0) {
            return -1;
          }
          /* ), sizeof(__xlang_rar));  */
          let rar_sz: u8[28] = [
            41, 44, 32, 115, 105, 122, 101, 111, 102, 40, 95, 95, 120, 108, 97, 110, 103, 95, 114, 97, 114, 41, 41, 59, 32, 0, 0, 0
          ];
          if (codegen_emit_bytes_from_ptr(out, &rar_sz[0], 25) != 0) {
            return -1;
          }
          if (codegen_append_byte(out, 40) != 0) {
            return -1;
          }
          if (codegen_emit_type(arena, out, rty, 0 as *u8, 0, ctx) != 0) {
            return -1;
          }
          /* ){ .data = __xlang_rar, .length =  */
          let rar_ft: u8[40] = [
            41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 114, 97, 114, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0, 0, 0, 0
          ];
          if (codegen_emit_bytes_from_ptr(out, &rar_ft[0], 34) != 0) {
            return -1;
          }
          if (format_int(out, rar_n as i64) != 0) {
            return -1;
          }
          /*  }; })\n */
          let rar_e: u8[12] = [32, 125, 59, 32, 125, 41, 59, 10, 0, 0, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &rar_e[0], 8) != 0) {
            return -1;
          }
          return 0;
        }
      }
      if (!ast.ref_is_null(rty) && pipeline_type_kind_ord_at(arena, rty) == (TypeKind.TYPE_NAMED as i32)) {
        let use_struct_zero: i32 = 0;
        if (ast.ref_is_null(operand_ref)) {
          use_struct_zero = 1;
        } else if (pipeline_expr_kind_ord_at(arena, operand_ref) == (ExprKind.EXPR_LIT as i32)) {
          let lit: Expr = ast.ast_arena_expr_get(arena, operand_ref);
          if (lit.int_val == 0) {
            use_struct_zero = 1;
          }
        }
        if (use_struct_zero != 0) {
          if (codegen_emit_indent(out, indent) != 0) {
            return -1;
          }
          /* return ( */
          let ret_open: u8[8] = [114, 101, 116, 117, 114, 110, 32, 40];
          if (codegen_emit_bytes_from_ptr(out, &ret_open[0], 8) != 0) {
            return -1;
          }
          if (codegen_emit_type(arena, out, rty, 0 as *u8, 0, ctx) != 0) {
            return -1;
          }
          /* ){0};\n */
          let ret_close: u8[8] = [41, 123, 48, 125, 59, 10, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &ret_close[0], 6) != 0) {
            return -1;
          }
          return 0;
        }
      }
      /*
       * wave342–344 Cap residual pure: host `return s` where
       *   `let a: T[N] = …; let s: T[] = a; …; return s` (body-top or nested block)
       * Root: try_emit_slice_init_from_array_var emits `{.data=a,.length=N}` (stack view).
       * Local aliasing is correct; return of the view dangles (run=1 vs 60).
       * G.7: durable static[N] + memcpy from s.data with runtime min(s.length, N).
       * wave343: pipeline_find_fixed_array_slice_escape (nested + resolved ARRAY).
       * wave344: reassign residual — prior used compile-time N for memcpy/length
       * (after s=[40,50] still length=3 → 340).
       * wave419: raise host escape cap 256→1024 to match freestanding
       * GLUE_ARRAY_LIT_MAX_ELEMS / deep-copy max_n (wave415/418). Prior n>256
       * fell back to bare `return s` (dangling); dual same-call often UB-luck via
       * call-arg deep-copy until n=1024 SIGSEGV. Soft: untyped-let; trait; true
       * recursion last-wins on function-static __xlang_esc (no heap yet).
       * PLATFORM: SHARED host-C emit (matches freestanding COMMON escape).
       */
      if (!ast.ref_is_null(rty) && pipeline_type_kind_ord_at(arena, rty) == (TypeKind.TYPE_SLICE as i32)
          && !ast.ref_is_null(operand_ref)
          && pipeline_expr_kind_ord_at(arena, operand_ref) == (ExprKind.EXPR_VAR as i32)) {
        let body_br: i32 = pipeline_module_func_body_ref_at(ctx.current_codegen_module, ctx.current_func_index);
        if (!ast.ref_is_null(body_br) && body_br > 0) {
          let op_e: Expr = ast.ast_arena_expr_get(arena, operand_ref);
          let arr_sz: i32 = 0;
          let elem_tr: i32 = 0;
          let arr_init_dummy: i32 = 0;
          let found_esc: i32 = 0;
          unsafe {
            found_esc = pipeline_find_fixed_array_slice_escape(arena, body_br, &op_e.var_name[0], op_e.var_name_len, &arr_sz, &elem_tr, &arr_init_dummy);
          }
          if (found_esc != 0 && arr_sz > 0 && arr_sz <= 1024 && !ast.ref_is_null(elem_tr)) {
            if (codegen_emit_indent(out, indent) != 0) {
              return -1;
            }
            /* return ({ static  */
            let open1: u8[20] = [114, 101, 116, 117, 114, 110, 32, 40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0, 0];
            if (codegen_emit_bytes_from_ptr(out, &open1[0], 17) != 0) {
              return -1;
            }
            if (codegen_emit_type(arena, out, elem_tr, 0 as *u8, 0, ctx) != 0) {
              let fallback: u8[9] = [105, 110, 116, 51, 50, 95, 116, 0, 0];
              if (codegen_emit_bytes_9(out, &fallback[0], 7) != 0) {
                return -1;
              }
            }
            /*  __xlang_esc[ */
            let esc_br: u8[16] = [32, 95, 95, 120, 108, 97, 110, 103, 95, 101, 115, 99, 91, 0, 0, 0];
            if (codegen_emit_bytes_from_ptr(out, &esc_br[0], 13) != 0) {
              return -1;
            }
            if (format_int(out, arr_sz) != 0) {
              return -1;
            }
            /* ]; size_t __xlang_esc_n = (size_t) */
            let mid1: u8[48] = [
              93, 59, 32, 115, 105, 122, 101, 95, 116, 32, 95, 95, 120, 108, 97, 110, 103, 95, 101, 115, 99, 95, 110, 32, 61, 32, 40, 115, 105, 122, 101, 95, 116, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            ];
            if (codegen_emit_bytes_from_ptr(out, &mid1[0], 34) != 0) {
              return -1;
            }
            if (codegen_emit_bytes_64(out, &op_e.var_name[0], op_e.var_name_len) != 0) {
              return -1;
            }
            /* .length; if (__xlang_esc_n > (size_t) */
            let mid2a: u8[48] = [
              46, 108, 101, 110, 103, 116, 104, 59, 32, 105, 102, 32, 40, 95, 95, 120, 108, 97, 110, 103, 95, 101, 115, 99, 95, 110, 32, 62, 32, 40, 115, 105, 122, 101, 95, 116, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            ];
            if (codegen_emit_bytes_from_ptr(out, &mid2a[0], 37) != 0) {
              return -1;
            }
            if (format_int(out, arr_sz) != 0) {
              return -1;
            }
            /* ) __xlang_esc_n = (size_t) */
            let mid2b: u8[32] = [
              41, 32, 95, 95, 120, 108, 97, 110, 103, 95, 101, 115, 99, 95, 110, 32, 61, 32, 40, 115, 105, 122, 101, 95, 116, 41, 0, 0, 0, 0, 0, 0
            ];
            if (codegen_emit_bytes_from_ptr(out, &mid2b[0], 26) != 0) {
              return -1;
            }
            if (format_int(out, arr_sz) != 0) {
              return -1;
            }
            /* ; memcpy(__xlang_esc,  */
            let mid2c: u8[28] = [
              59, 32, 109, 101, 109, 99, 112, 121, 40, 95, 95, 120, 108, 97, 110, 103, 95, 101, 115, 99, 44, 32, 0, 0, 0, 0, 0, 0
            ];
            if (codegen_emit_bytes_from_ptr(out, &mid2c[0], 22) != 0) {
              return -1;
            }
            if (codegen_emit_bytes_64(out, &op_e.var_name[0], op_e.var_name_len) != 0) {
              return -1;
            }
            /* .data, __xlang_esc_n * sizeof(__xlang_esc[0])); ( */
            let mid3: u8[56] = [
              46, 100, 97, 116, 97, 44, 32, 95, 95, 120, 108, 97, 110, 103, 95, 101, 115, 99, 95, 110, 32, 42, 32, 115, 105, 122, 101, 111, 102, 40, 95, 95, 120, 108, 97, 110, 103, 95, 101, 115, 99, 91, 48, 93, 41, 41, 59, 32, 40, 0, 0, 0, 0, 0, 0, 0
            ];
            if (codegen_emit_bytes_from_ptr(out, &mid3[0], 49) != 0) {
              return -1;
            }
            if (codegen_emit_type(arena, out, rty, 0 as *u8, 0, ctx) != 0) {
              return -1;
            }
            /* ){ .data = __xlang_esc, .length = __xlang_esc_n }; })\n */
            let end1: u8[256] = [
              41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 101, 115, 99, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 101, 115, 99, 95, 110, 32, 125, 59, 32, 125, 41, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0
            ];
            if (codegen_emit_bytes_from_ptr(out, &end1[0], 55) != 0) {
              return -1;
            }
            return 0;
          }
        }
        /*
         * wave345 Cap residual pure: host `return s` when `s` is a TYPE_SLICE
         * formal. C ABI lowers TYPE_SLICE params as `struct xlang_slice_* *`
         * (G.7 field_access_base_is_pointer_param / call-arg `&local`), but the
         * function returns the slice by value. Bare `return s` is type-error in
         * host-cc (`*` vs value). Freestanding already dual-GP-loads fat* (wave332).
         * G.7: reuse pointer-param classifier; emit `return *s;` when rty is
         * TYPE_SLICE and operand is that formal (not a local by-value fat).
         * PLATFORM: SHARED host-C emit. Soft: untyped-let; reentrancy last-wins.
         */
        if (field_access_base_is_pointer_param(arena, operand_ref, ctx.current_codegen_module, ctx.current_func_index) != 0) {
          let op_e2: Expr = ast.ast_arena_expr_get(arena, operand_ref);
          if (op_e2.var_name_len > 0) {
            if (codegen_emit_indent(out, indent) != 0) {
              return -1;
            }
            /* return * */
            let ret_star: u8[12] = [114, 101, 116, 117, 114, 110, 32, 42, 0, 0, 0, 0];
            if (codegen_emit_bytes_from_ptr(out, &ret_star[0], 8) != 0) {
              return -1;
            }
            if (codegen_emit_bytes_64(out, &op_e2.var_name[0], op_e2.var_name_len) != 0) {
              return -1;
            }
            let sc_star: u8[4] = [59, 10, 0, 0];
            return codegen_emit_bytes_4(out, &sc_star[0], 2);
          }
        }
      }
    }
    if (codegen_emit_indent(out, indent) != 0) {
      return -1;
    }
    let ret: u8[8] = [114, 101, 116, 117, 114, 110, 32, 0];
    if (codegen_emit_bytes_8(out, &ret[0], 7) != 0) {
      return -1;
    }
    /*
     * PTR-to-ARRAY return (`*[N]T`): codegen_emit_type peels to `E *` so
     * `return &self.p` (`E (*)[N]`) is Ubuntu -Wincompatible-pointer-types.
     * Cast to the peeled return type. G.7 complete this return emit
     * (no second return path). PLATFORM: SHARED host-C; Ubuntu gold.
     */
    if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module
        && ctx.current_func_index >= 0
        && ctx.current_func_index < ctx.current_codegen_module.num_funcs
        && !ast.ref_is_null(operand_ref)) {
      let parr_rty: i32 = pipeline_module_func_return_type_at(ctx.current_codegen_module,
              ctx.current_func_index);
      if (type_is_ptr_to_fixed_array(arena, parr_rty) != 0) {
        if (codegen_append_byte(out, 40) != 0) {
          return -1;
        }
        if (codegen_emit_type(arena, out, parr_rty, 0 as *u8, 0, ctx) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 41) != 0) {
          return -1;
        }
      }
    }
    if (!ast.ref_is_null(operand_ref) && codegen_emit_expr(arena, out, operand_ref, ctx) != 0) {
      return -1;
    }
    let sc: u8[4] = [59, 10, 0, 0];
    return codegen_emit_bytes_4(out, &sc[0], 2);
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function emit_block_final_expr(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, final_ref: i32, indent: i32, ctx: *PipelineDepCtx, fn_ret_void: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ast.ref_is_null(final_ref)) {
      return 0;
    }
    let fe: Expr = ast.ast_arena_expr_get(arena, final_ref);
    if ((fe.kind as i32) == (ExprKind.EXPR_BREAK as i32)) {
      return emit_break_stmt(out, indent);
    }
    if ((fe.kind as i32) == (ExprKind.EXPR_CONTINUE as i32)) {
      return emit_continue_stmt(out, indent);
    }
    if ((fe.kind as i32) == (ExprKind.EXPR_RETURN as i32)) {
      return emit_return_stmt_with_context(arena, out, indent, fe.unary_operand_ref, ctx, fn_ret_void);
    }
    /*
     * wave374: function-final `match { … => { return N; }; }` must not become
     * `return (subj==…?(({ return N; })):…)` (void stmt-expr in value position).
     * Same gate as mid-body: return-control arms → if/else real return.
     * PLATFORM: SHARED — host-C match stmt form (G.7 codegen_emit_match_as_stmt).
     */
    if ((fe.kind as i32) == (ExprKind.EXPR_MATCH as i32) && codegen_match_has_return_arm(arena, final_ref) != 0) {
      return codegen_emit_match_as_stmt(arena, out, final_ref, indent, ctx, fn_ret_void);
    }
    let parent_br: i32 = 0;
    if (block_ref > 0 && block_ref <= arena.num_blocks) {
      let blk: Block = ast.ast_arena_block_get(arena, block_ref);
      parent_br = blk.parent_block_ref;
    }
    /*
     * Nested / non-function-body final: emit `expr;` not return.
     * PLATFORM: SHARED — GNU statement expr `({ ... })` (EXPR_BLOCK as value, e.g.
     * `if (a==b){1}else{0}` as call arg) must end with a value expression.
     * `return 1;` makes the statement-expr void → host-cc "void to int32_t".
     * Only the real function body block may use return for final_expr.
     */
    let is_func_body: i32 = 0;
    if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module
        && ctx.current_func_index >= 0) {
      let fbody: i32 = pipeline_module_func_body_ref_at(ctx.current_codegen_module, ctx.current_func_index);
      if (!ast.ref_is_null(fbody) && fbody == block_ref) {
        is_func_body = 1;
      }
    }
    if (parent_br > 0 || is_func_body == 0) {
      if (codegen_emit_indent(out, indent) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, final_ref, ctx) != 0) {
        return -1;
      }
      let end: u8[4] = [59, 10, 0, 0];
      return codegen_emit_bytes_from_ptr(out, &end[0], 2);
    }
    return emit_return_stmt_with_context(arena, out, indent, final_ref, ctx, fn_ret_void);
  }
}

/**
 * Emit one Block as host-C statements (GNU stmt-expr when used as a value).
 * @param arena *ASTArena — AST owner
 * @param out *CodegenOutBuf — C text sink
 * @param block_ref i32 — block to emit; null/out-of-range is a no-op
 * @param indent i32 — spaces of indent for each statement
 * @param ctx *PipelineDepCtx — current func / module for return and types
 * @return i32 — 0 ok, -1 emit failure
 * PLATFORM: SHARED — host-C dest-from-region intermediate last-value:
 * last so_k==6 with no final_expr is dest; wrapping defers run first
 * so dest stays the GNU stmt-expr last value (not `(m=1)`).
 * Stacked dest-from-region wrapping hoists inner first then outer
 * (dest-in-rbx LIFO last-wins), dest still last.
 * dest-region-body `with_arena { defer; dest }` is often stmt_order==0
 * (defer pool + final_expr dest); that fallback also honors skip-wrap
 * so dest-region-body defer is not run again after wrapping.
 */
export function codegen_emit_block(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, indent: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    /* Consume one-shot skip so prefix / sibling codegen_emit_block stay 0. */
    let skip_wrap_dest: i32 = g_codegen_skip_wrap_dest;
    g_codegen_skip_wrap_dest = 0;

    let blk_prefix: u8[256] = [];
    let blk_prefix_len: i32 = codegen_emit_prefix_len_from_ctx(ctx, &blk_prefix[0], 128);
    let fn_ret_void: i32 = codegen_current_func_returns_void(arena, ctx);
    if (ast.ref_is_null(block_ref)) {
      return 0;
    }
    if (block_ref <= 0 || block_ref > arena.num_blocks) {
      return 0;
    }
    if (ast_ast_block_num_stmt_order(arena, block_ref) > 0) {
      /* dest-from-region intermediate: last so_k==6 is dest when
       * the block has no final_expr. Wrapping defers used to run
       * AFTER that dest, so GNU stmt-expr last value was (m=1)
       * assigned to Wrap (host-C cc fail). G.7: same
       * emit_run_defers, before dest, dest stays last.
       * Stacked dest-from-region last dest hoists last dest wrapping
       * first (inner) then this wrapping (outer) so last-wins matches
       * dest-in-rbx LIFO; dest emit then skip-wrap so dest stays last.
       * Prefix region + final_expr dest is unchanged (defers
       * still run after prefix stmts, before final_expr).
       * PLATFORM: SHARED host-C dest-from-region stacked last-wins. */
      let so_n: i32 = ast_ast_block_num_stmt_order(arena, block_ref);
      let last_dest_region: i32 = 0;
      let final_now: i32 = ast_ast_block_final_expr_ref(arena, block_ref);
      if (so_n > 0 && ast.ref_is_null(final_now)) {
        let last_k: u8 = ast_ast_block_stmt_order_kind(arena, block_ref, so_n - 1);
        if (last_k == 6) {
          last_dest_region = 1;
        }
      }
      /* See implementation. */
      let pre_li: i32 = 0;
      /* Load every block bound before comparing it with an index.
       * PLATFORM: WINDOWS. A call in `index < count()` keeps the index
       * in rbx and pushes it in the Win64 home slot. The callee spills
       * rcx (the arena) over that push, so the reloaded index is the
       * arena pointer. Measured on `return 7;`: stmt-order count is 1,
       * saved index 0 comes back as the arena, the walk is skipped, and
       * the C body is empty. The same push sits on every bound below. */
      let nlets_pre: i32 = ast_ast_block_num_lets(arena, block_ref);
      while (pre_li < nlets_pre) {
        if (block_stmt_order_has_let(arena, block_ref, pre_li) == 0) {
          let lname_pre: u8[256] = [];
          pipeline_block_let_name_copy64(arena, block_ref, pre_li, &lname_pre[0]);
          let lname_len_pre: i32 = pipeline_block_let_name_len(arena, block_ref, pre_li);
          let let_type_pre: i32 = pipeline_block_let_type_ref(arena, block_ref, pre_li);
          let linit_pre: i32 = pipeline_block_let_init_ref(arena, block_ref, pre_li);
          if (codegen_emit_indent(out, indent) != 0) {
            return -1;
          }
          let type_emitted_pre: i32 = 0;
          let use_local_array_pre: i32 = 0;
          if (!ast.ref_is_null(let_type_pre) && pipeline_type_kind_ord_at(arena, let_type_pre) == 10) {
            use_local_array_pre = 1;
          }
          if (use_local_array_pre != 0) {
            if (codegen_emit_local_fixed_array_elem_type(arena, out, let_type_pre, ctx) != 0) {
              return -1;
            }
            type_emitted_pre = 1;
          }
          if (type_emitted_pre == 0) {
            if (codegen_emit_type(arena, out, let_type_pre, 0 as *u8, 0, ctx) != 0) {
              return -1;
            }
          }
          if (codegen_append_byte(out, 32) != 0) {
            return -1;
          }
          /* Emit C local name into emit_nm_pre so memcpy finish can reuse it. */
          let emit_nm_pre: u8[256] = [];
          let emit_nml_pre: i32 = 0;
          if (lname_len_pre > 0 && (lname_pre[0] > 32)) {
            let ci: i32 = 0;
            while (ci < lname_len_pre && ci < 128) {
              emit_nm_pre[ci] = lname_pre[ci];
              ci = ci + 1;
            }
            emit_nml_pre = lname_len_pre;
          } else {
            emit_nm_pre[0] = 95;
            emit_nm_pre[1] = 108;
            emit_nml_pre = 2;
            let v: i32 = pre_li;
            let digs: u8[12] = [];
            let nd: i32 = 0;
            if (v == 0) {
              digs[0] = 48;
              nd = 1;
            } else {
              let tmp: i32 = v;
              while (tmp > 0 && nd < 12) {
                digs[nd] = ((tmp % 10) + 48) as u8;
                tmp = tmp / 10;
                nd = nd + 1;
              }
              let a: i32 = 0;
              let b: i32 = nd - 1;
              while (a < b) {
                let sw: u8 = digs[a];
                digs[a] = digs[b];
                digs[b] = sw;
                a = a + 1;
                b = b - 1;
              }
            }
            let pi: i32 = 0;
            while (pi < nd && emit_nml_pre < 128) {
              emit_nm_pre[emit_nml_pre] = digs[pi];
              emit_nml_pre = emit_nml_pre + 1;
              pi = pi + 1;
            }
          }
          if (codegen_emit_bytes_64(out, &emit_nm_pre[0], emit_nml_pre) != 0) {
            return -1;
          }
          if (use_local_array_pre != 0) {
            if (codegen_emit_local_fixed_array_suffix(arena, out, let_type_pre) != 0) {
              return -1;
            }
          }
          /* wave353: fixed TYPE_ARRAY local — brace lit or memcpy (not T t[N]=ptr). */
          if (use_local_array_pre != 0) {
            if (emit_local_fixed_array_let_finish(arena, out, indent, &emit_nm_pre[0], emit_nml_pre, linit_pre, let_type_pre, ctx) != 0) {
              return -1;
            }
          } else {
            let eq_pre: u8[4] = [32, 61, 32, 0];
            if (codegen_emit_bytes_4(out, &eq_pre[0], 3) != 0) {
              return -1;
            }
            /* F2: TYPE_DYN LHS + concrete (non-null-sentinel) RHS -> wrap in
             * fat-ptr compound literal so host-C sees
             * `struct xlang_dyn_obj x = (struct xlang_dyn_obj){...};` and not
             * `struct xlang_dyn_obj x = a;` (type mismatch). Null-dyn sentinel
             * (literal 0) keeps the F1 bare-init path. F3: vtable now built
             * from trait methods via codegen_emit_dyn_vtable_close.
             * PLATFORM: SHARED host-C. */
            let dyn_wrap: i32 = 0;
            let lt_dyn: i32 = pipeline_typeck_resolve_type_alias_ref_c(arena, let_type_pre);
            if (!ast.ref_is_null(lt_dyn)
                && pipeline_type_kind_ord_at(arena, lt_dyn) == (TypeKind.TYPE_DYN as i32)) {
              let rhs_rt: i32 = pipeline_expr_resolved_type_ref(arena, linit_pre);
              if (typeck_dyn_rhs_is_null_sentinel(arena, rhs_rt, linit_pre) == 0) {
                dyn_wrap = 1;
                /*
                 * F5 PTR-to-NAMED for-type: when RHS is itself a pointer
                 * (TYPE_PTR), do NOT take address-of — data IS the pointer
                 * (matches impl self: *T for impl Trait for *T). For by-value
                 * RHS, keep & so data becomes a pointer to the value.
                 * Byte layout: "(struct xlang_dyn_obj){ .data = " (32 bytes)
                 * + "&(" (2 bytes) for by-value, or "(" (1 byte) for by-pointer.
                 * PLATFORM: SHARED host-C; seed codegen_gen.linux.x86_64.c mirrors.
                 */
                let dyn_open: u8[34] = [40, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 100, 121, 110, 95, 111, 98, 106, 41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 38, 40];
                let rhs_kind_ord: i32 = pipeline_type_kind_ord_at(arena, rhs_rt);
                if (rhs_kind_ord == (TypeKind.TYPE_PTR as i32)) {
                  /* Skip byte 32 (the &); emit bytes 0..31 + byte 33 (the open paren). */
                  if (codegen_emit_bytes_from_ptr(out, &dyn_open[0], 32) != 0) {
                    return -1;
                  }
                  if (codegen_append_byte(out, dyn_open[33]) != 0) {
                    return -1;
                  }
                } else {
                  /*
                   * F6: Builtin by-value RHS — emit "&((<C-type>){" so & has
                   * a valid lvalue (compound literal).
                   * codegen_emit_dyn_vtable_close closes with "}". Non-builtin
                   * by-value keeps the F2 "&(" path (NAMED RHS has storage).
                   * PLATFORM: SHARED host-C; seed codegen_gen.linux.x86_64.c mirrors.
                   */
                  let bnm: u8[16] = [];
                  let blen: i32 = codegen_builtin_type_name_into(rhs_kind_ord, &bnm[0]);
                  if (blen > 0) {
                    /* Emit "(struct xlang_dyn_obj){ .data = " — 32 bytes (dyn_open 0..31). */
                    if (codegen_emit_bytes_from_ptr(out, &dyn_open[0], 32) != 0) { return -1; }
                    /* Emit "&((" — 3 bytes. */
                    if (codegen_append_byte(out, 38) != 0) { return -1; }
                    if (codegen_append_byte(out, 40) != 0) { return -1; }
                    if (codegen_append_byte(out, 40) != 0) { return -1; }
                    /* Emit the C type (int32_t/f64/...). */
                    if (codegen_emit_type_kind(out, rhs_kind_ord) != 0) { return -1; }
                    /* Emit "){" — 2 bytes (close cast + open compound literal). */
                    if (codegen_append_byte(out, 41) != 0) { return -1; }
                    if (codegen_append_byte(out, 123) != 0) { return -1; }
                  } else {
                    if (codegen_emit_bytes_from_ptr(out, &dyn_open[0], 34) != 0) {
                      return -1;
                    }
                  }
                }
              }
            }
            let _stp: i32 = codegen_stamp_anon_struct_lit_dest(arena, linit_pre, let_type_pre);
            _stp = _stp;
            if (codegen_emit_expr(arena, out, linit_pre, ctx) != 0) {
              return -1;
            }
            if (dyn_wrap != 0) {
              let rhs_rt: i32 = pipeline_expr_resolved_type_ref(arena, linit_pre);
              if (codegen_emit_dyn_vtable_close(arena, out, ctx, lt_dyn, rhs_rt) != 0) {
                return -1;
              }
            }
            let sc_pre: u8[3] = [59, 10, 0];
            if (codegen_emit_bytes_3(out, &sc_pre[0], 2) != 0) {
              return -1;
            }
          }
        }
        pre_li = pre_li + 1;
      }
      let si: i32 = 0;
      /* so_n is the count loaded above. Re-calling here pushes si. PLATFORM: WINDOWS. */
      while (si < so_n) {
        let k: u8 = ast_ast_block_stmt_order_kind(arena, block_ref, si);
        let idx: i32 = ast_ast_block_stmt_order_idx(arena, block_ref, si);
        /* Hoist wrapping defers before dest-from-region dest.
         * skip_wrap_dest: already hoisted inner-first on the caller. */
        if (skip_wrap_dest == 0 && last_dest_region != 0 && si == (so_n - 1)) {
          let last_idx_h: i32 = ast_ast_block_stmt_order_idx(arena, block_ref, so_n - 1);
          /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
          let nreg_dest: i32 = ast_ast_block_num_regions(arena, block_ref);
          if (last_idx_h >= 0 && last_idx_h < nreg_dest) {
            let last_body_h: i32 = ast_ast_block_region_body_ref(arena, block_ref, last_idx_h);
            if (emit_run_dest_fromreg_wrapping_defers(arena, out, last_body_h, indent, ctx) != 0) {
              return -1;
            }
          }
          if (emit_run_defers(arena, out, block_ref, indent, ctx) != 0) {
            return -1;
          }
        }
        if (k == 0) {
          /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
          let nconst_k: i32 = ast_ast_block_num_consts(arena, block_ref);
          if (idx >= 0 && idx < nconst_k) {
            let cname_buf: u8[256] = [];
            pipeline_block_const_name_copy64(arena, block_ref, idx, &cname_buf[0]);
            let cname_len: i32 = pipeline_block_const_name_len(arena, block_ref, idx);
            let ctype_ref: i32 = pipeline_block_const_type_ref(arena, block_ref, idx);
            let cinit_ref: i32 = pipeline_block_const_init_ref(arena, block_ref, idx);
            if (codegen_emit_indent(out, indent) != 0) {
              return -1;
            }
            if (codegen_emit_type(arena, out, ctype_ref, 0 as *u8, 0, ctx) != 0) {
              return -1;
            }
            let sp: u8[3] = [32, 0, 0];
            if (codegen_emit_bytes_3(out, &sp[0], 1) != 0) {
              return -1;
            }
            /* See implementation. */
            if (cname_len > 0 && (cname_buf[0] > 32)) {
              if (codegen_emit_bytes_64(out, &cname_buf[0], cname_len) != 0) {
                return -1;
              }
            } else {
              let place: u8[4] = [95, 99, 48, 0];
              if (codegen_emit_bytes_4(out, &place[0], 2) != 0) {
                return -1;
              }
              if (format_int(out, idx) != 0) {
                return -1;
              }
            }
            let eq: u8[4] = [32, 61, 32, 0];
            if (codegen_emit_bytes_4(out, &eq[0], 3) != 0) {
              return -1;
            }
            /*
             * dest-SLICE const INDEX/VAR/FIELD/CALL: same wrap as let.
             * Prior: codegen_emit_expr only → `s = (a)[1]` (pointer into slice struct)
             * → host-cc BLD001. G.7: reuse try_emit_slice_init_from_array_var.
             * let_idx = num_lets so VAR scan sees all lets; const scan is
             * independent of let_idx. PLATFORM: SHARED host-C.
             */
            let slice_cinit: i32 = 0;
            if (!ast.ref_is_null(cinit_ref)) {
              let nlets_c: i32 = ast_ast_block_num_lets(arena, block_ref);
              slice_cinit = try_emit_slice_init_from_array_var(arena, out, block_ref, nlets_c, ctype_ref, cinit_ref, ctx);
              if (slice_cinit == 0) {
                slice_cinit = try_emit_dest_slice_from_module_array_var(arena, out, ctype_ref, cinit_ref, ctx);
              }
            }
            if (slice_cinit < 0) {
              return -1;
            } else if (slice_cinit == 0) {
              if (codegen_emit_expr(arena, out, cinit_ref, ctx) != 0) {
                return -1;
              }
            }
            let sc: u8[3] = [59, 10, 0];
            if (codegen_emit_bytes_3(out, &sc[0], 2) != 0) {
              return -1;
            }
          }
        } else if (k == 1) {
          /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
          let nlets_k: i32 = ast_ast_block_num_lets(arena, block_ref);
          if (idx >= 0 && idx < nlets_k) {
            let lname_buf: u8[256] = [];
            pipeline_block_let_name_copy64(arena, block_ref, idx, &lname_buf[0]);
            let lname_len: i32 = pipeline_block_let_name_len(arena, block_ref, idx);
            let let_type_ref: i32 = pipeline_block_let_type_ref(arena, block_ref, idx);
            let linit_ref: i32 = pipeline_block_let_init_ref(arena, block_ref, idx);
            if (codegen_emit_indent(out, indent) != 0) {
              return -1;
            }
            /* See implementation. */
            let type_emitted: i32 = 0;
            let use_local_array: i32 = 0;
            let use_ptr_to_array: i32 = 0;
            let use_fnptr: i32 = 0;
            let fnptr_array_ty: i32 = 0;
            let use_fnptr_array_init: i32 = 0;
            let fn_leaf: i32 = 0;
            if (!ast.ref_is_null(let_type_ref) && pipeline_type_kind_ord_at(arena, let_type_ref) == 10) {
              use_local_array = 1;
            }
            /*
             * wave636: `let p: *[N]T = &a` → `E (*p)[N] = &a` (name inside declarator).
             * Bare codegen_emit_type + name would yield invalid `E (*)[N] p`.
             */
            if (use_local_array == 0 && !ast.ref_is_null(let_type_ref) && type_is_ptr_to_fixed_array(arena, let_type_ref) != 0) {
              use_ptr_to_array = 1;
            }
            /*
             * 10.3.1: `let f: function(T): R = …` → `R (*f)(T)`.
             * Bare codegen_emit_type abstract + name → invalid `R (*)(T) f`.
             * slice11: `let a: [N]function(...)=…` → `R (*a[N])(…)` (not abstract+suffix).
             * PLATFORM: SHARED host-C. G.7 codegen_emit_c_fnptr_decl.
             */
            if (use_local_array != 0 && !ast.ref_is_null(let_type_ref)) {
              fn_leaf = let_type_ref;
              while (!ast.ref_is_null(fn_leaf)
                  && pipeline_type_kind_ord_at(arena, fn_leaf) == (TypeKind.TYPE_ARRAY as i32)) {
                let inn: i32 = pipeline_type_elem_ref_at(arena, fn_leaf);
                if (ast.ref_is_null(inn)) {
                  break;
                }
                fn_leaf = inn;
              }
              if (pipeline_type_kind_ord_at(arena, fn_leaf) == (TypeKind.TYPE_FN as i32)) {
                use_fnptr = 1;
                fnptr_array_ty = let_type_ref;
                use_fnptr_array_init = 1;
                use_local_array = 0;
              }
            }
            if (use_local_array == 0 && use_ptr_to_array == 0 && use_fnptr == 0
                && !ast.ref_is_null(let_type_ref)
                && pipeline_type_kind_ord_at(arena, let_type_ref) == (TypeKind.TYPE_FN as i32)) {
              use_fnptr = 1;
            }
            if (use_local_array != 0) {
              if (codegen_emit_local_fixed_array_elem_type(arena, out, let_type_ref, ctx) != 0) {
                return -1;
              }
              type_emitted = 1;
            }
            if (!ast.ref_is_null(linit_ref) && linit_ref > 0 && linit_ref <= arena.num_exprs) {
              let init_e: Expr = ast.ast_arena_expr_get(arena, linit_ref);
              if (type_emitted == 0 && (init_e.kind as i32) == (ExprKind.EXPR_ARRAY_LIT as i32) && type_array_elem_is_u8(arena, let_type_ref) != 0) {
                let u8ptr: u8[9] = [117, 105, 110, 116, 56, 95, 116, 32, 0];
                if (codegen_emit_bytes_9(out, &u8ptr[0], 7) != 0) {
                  return -1;
                }
                if (codegen_append_byte(out, 42) != 0) {
                  return -1;
                }
                type_emitted = 1;
              }
              /*
               * See implementation.
               * See implementation.
               * See implementation.
               * See implementation.
               */
              if (type_emitted == 0 && !ast.ref_is_null(init_e.resolved_type_ref) && init_e.resolved_type_ref > 0 && init_e.resolved_type_ref <= arena.num_types) {
                let rt: Type = ast.ast_arena_type_get(arena, init_e.resolved_type_ref);
                if ((rt.kind as i32) == (TypeKind.TYPE_NAMED as i32) && rt.name_len >= 6) {
                  let n0: i32 = rt.name_len - 6;
                  if (rt.name[n0] == 83 && rt.name[n0 + 1] == 116 && rt.name[n0 + 2] == 114 && rt.name[n0 + 3] == 105 && rt.name[n0 + 4] == 110 && rt.name[n0 + 5] == 103) {
                    let str_ty: u8[7] = [83, 116, 114, 105, 110, 103, 0];
                    if (codegen_emit_bytes_from_ptr(out, &str_ty[0], 6) != 0) {
                      return -1;
                    }
                    if (codegen_append_byte(out, 32) != 0) {
                      return -1;
                    }
                    type_emitted = 1;
                  }
                }
              }
              if (type_emitted == 0 && (init_e.kind as i32) == (ExprKind.EXPR_CALL as i32) && !ast.ref_is_null(init_e.call_callee_ref) && init_e.call_callee_ref > 0 && init_e.call_callee_ref <= arena.num_exprs) {
                let callee_let: Expr = ast.ast_arena_expr_get(arena, init_e.call_callee_ref);
                if ((callee_let.kind as i32) == (ExprKind.EXPR_VAR as i32)) {
                  if (codegen_callee_var_is_string_new(callee_let) != 0) {
                    let str_ty: u8[7] = [83, 116, 114, 105, 110, 103, 0];
                    if (codegen_emit_bytes_from_ptr(out, &str_ty[0], 6) != 0) {
                      return -1;
                    }
                    if (codegen_append_byte(out, 32) != 0) {
                      return -1;
                    }
                    type_emitted = 1;
                  }
                }
              }
            }
            /* Emit C local name into emit_nm so wave353 memcpy finish can reuse it. */
            let emit_nm: u8[256] = [];
            let emit_nml: i32 = 0;
            if (lname_len > 0 && (lname_buf[0] > 32)) {
              let ci2: i32 = 0;
              while (ci2 < lname_len && ci2 < 128) {
                emit_nm[ci2] = lname_buf[ci2];
                ci2 = ci2 + 1;
              }
              emit_nml = lname_len;
            } else {
              emit_nm[0] = 95;
              emit_nm[1] = 108;
              emit_nml = 2;
              let v2: i32 = idx;
              let digs2: u8[12] = [];
              let nd2: i32 = 0;
              if (v2 == 0) {
                digs2[0] = 48;
                nd2 = 1;
              } else {
                let tmp2: i32 = v2;
                while (tmp2 > 0 && nd2 < 12) {
                  digs2[nd2] = ((tmp2 % 10) + 48) as u8;
                  tmp2 = tmp2 / 10;
                  nd2 = nd2 + 1;
                }
                let a2: i32 = 0;
                let b2: i32 = nd2 - 1;
                while (a2 < b2) {
                  let sw2: u8 = digs2[a2];
                  digs2[a2] = digs2[b2];
                  digs2[b2] = sw2;
                  a2 = a2 + 1;
                  b2 = b2 - 1;
                }
              }
              let pi2: i32 = 0;
              while (pi2 < nd2 && emit_nml < 128) {
                emit_nm[emit_nml] = digs2[pi2];
                emit_nml = emit_nml + 1;
                pi2 = pi2 + 1;
              }
            }
            /*
             * wave636: named pointer-to-array declarator embeds the name
             * (`int32_t (*p)[2]`). Skip bare codegen_emit_type + trailing name.
             */
            if (use_ptr_to_array != 0 && type_emitted == 0) {
              if (codegen_emit_c_ptr_to_fixed_array_decl(arena, out, let_type_ref, &emit_nm[0], emit_nml, ctx) != 0) {
                return -1;
              }
              type_emitted = 1;
            } else if (use_fnptr != 0 && type_emitted == 0) {
              fn_leaf = let_type_ref;
              if (fnptr_array_ty > 0) {
                fn_leaf = fnptr_array_ty;
                while (!ast.ref_is_null(fn_leaf)
                    && pipeline_type_kind_ord_at(arena, fn_leaf) == (TypeKind.TYPE_ARRAY as i32)) {
                  let inn2: i32 = pipeline_type_elem_ref_at(arena, fn_leaf);
                  if (ast.ref_is_null(inn2)) {
                    break;
                  }
                  fn_leaf = inn2;
                }
              }
              if (codegen_emit_c_fnptr_decl(arena, out, fn_leaf, &emit_nm[0], emit_nml, fnptr_array_ty, ctx) != 0) {
                return -1;
              }
              type_emitted = 1;
            } else if (type_emitted == 0) {
              if (ast.ref_is_null(let_type_ref) && !ast.ref_is_null(linit_ref) && linit_ref > 0 && linit_ref <= arena.num_exprs) {
                let init_e: Expr = ast.ast_arena_expr_get(arena, linit_ref);
                if (!ast.ref_is_null(init_e.resolved_type_ref)) {
                  let_type_ref = init_e.resolved_type_ref;
                }
              }
              if (codegen_emit_type(arena, out, let_type_ref, 0 as *u8, 0, ctx) != 0) {
                return -1;
              }
            }
            if (use_ptr_to_array == 0 && use_fnptr == 0) {
              if (codegen_append_byte(out, 32) != 0) {
                return -1;
              }
              if (codegen_emit_bytes_64(out, &emit_nm[0], emit_nml) != 0) {
                return -1;
              }
            }
            if (use_local_array != 0) {
              if (codegen_emit_local_fixed_array_suffix(arena, out, let_type_ref) != 0) {
                return -1;
              }
            }
            /*
             * wave353 Cap residual pure: host fixed TYPE_ARRAY local let.
             * Root: C rejects `T t[N] = fill()` / `T t[N] = a` (not brace/string).
             * Authority: emit_local_fixed_array_let_finish — brace lit or memcpy once-eval.
             */
            if (use_local_array != 0) {
              if (emit_local_fixed_array_let_finish(arena, out, indent, &emit_nm[0], emit_nml, linit_ref, let_type_ref, ctx) != 0) {
                return -1;
              }
            } else if (use_fnptr_array_init != 0) {
              /* slice11: declarator already has [N]; reuse ARRAY let-finish for init. */
              if (emit_local_fixed_array_let_finish(arena, out, indent, &emit_nm[0], emit_nml, linit_ref, fnptr_array_ty, ctx) != 0) {
                return -1;
              }
            } else if (!ast.ref_is_null(let_type_ref) && pipeline_type_kind_ord_at(arena, let_type_ref) == 11
                       && !ast.ref_is_null(linit_ref)
                       && (pipeline_expr_kind_ord_at(arena, linit_ref) == 48
                           || pipeline_expr_kind_ord_at(arena, linit_ref) == 49)
                       && codegen_slice_let_call_returns_slice(arena, linit_ref, ctx) != 0) {
              /*
               * wave409: TYPE_SLICE let from CALL/METHOD that already returns
               * TYPE_SLICE — frame deep-copy (true reentrancy).
               * dest-SLICE of a callee that returns TYPE_ARRAY (`let s:[]T=mk()`
               * / `dep.mk()`) must not enter here: typeck stamps the CALL to
               * TYPE_SLICE, but mk() ABI is E*. G.7: try_emit wraps those.
               * Type+name already written; finish with ; buffer; { call; copy; name=fat }.
               * PLATFORM: SHARED host-C.
               */
              if (codegen_emit_slice_let_reent_finish(arena, out, indent, &emit_nm[0], emit_nml, let_type_ref, linit_ref, ctx) != 0) {
                return -1;
              }
            } else {
              let eq: u8[4] = [32, 61, 32, 0];
              if (codegen_emit_bytes_4(out, &eq[0], 3) != 0) {
                return -1;
              }
              /*
               * dest `*[N]T` local is `E (*name)[N]`; codegen_emit_type peels
               * PTR-to-ARRAY function returns to `E *`. Explicit cast so
               * Ubuntu gcc accepts `int32_t (*p)[2] = getpa()`.
               * G.7 complete this let-init (reuse abstract
               * codegen_emit_c_ptr_to_fixed_array_decl). PLATFORM: SHARED host-C.
               */
              if (use_ptr_to_array != 0 && !ast.ref_is_null(linit_ref)) {
                if (codegen_append_byte(out, 40) != 0) {
                  return -1;
                }
                if (codegen_emit_c_ptr_to_fixed_array_decl(arena, out, let_type_ref, 0 as *u8, 0, ctx) != 0) {
                  return -1;
                }
                if (codegen_append_byte(out, 41) != 0) {
                  return -1;
                }
              }
              /*
               * 10.3.1 slice15: TYPE_FN let = Cap/opaque → `(Ret (*)(args))init`.
               * Without cast gcc: incompatible pointer types assigning to
               * 'int32_t (*)(int32_t)' from 'uint8_t *'. Skip [N]TYPE_FN
               * (use_fnptr_array_init). G.7 reuse codegen_emit_c_fnptr_decl abstract.
               * PLATFORM: SHARED host-C.
               */
              if (use_fnptr != 0 && use_fnptr_array_init == 0 && !ast.ref_is_null(linit_ref)) {
                let cast_fn: i32 = fn_leaf;
                if (cast_fn <= 0) {
                  cast_fn = let_type_ref;
                }
                if (codegen_append_byte(out, 40) != 0) {
                  return -1;
                }
                if (codegen_emit_c_fnptr_decl(arena, out, cast_fn, 0 as *u8, 0, 0, ctx) != 0) {
                  return -1;
                }
                if (codegen_append_byte(out, 41) != 0) {
                  return -1;
                }
              }
              let slice_init: i32 = 0;
              if (!ast.ref_is_null(linit_ref)) {
                slice_init = try_emit_slice_init_from_array_var(arena, out, block_ref, idx, let_type_ref, linit_ref, ctx);
                if (slice_init == 0) {
                  slice_init = try_emit_dest_slice_from_module_array_var(arena, out, let_type_ref, linit_ref, ctx);
                }
              }
              if (ast.ref_is_null(linit_ref)) {
                let zinit_omit2: u8[6] = [123, 32, 48, 32, 125, 0];
                if (emit_bytes_6(out, &zinit_omit2[0], 5) != 0) {
                  return -1;
                }
              } else if (slice_init == 1) {
                /* slice compound already written */
              } else if (slice_init < 0) {
                return -1;
              } else {
                let use_vec_z: i32 = 0;
                let use_vec_braced: i32 = 0;
                if (!ast.ref_is_null(linit_ref) && linit_ref > 0 && linit_ref <= arena.num_exprs
                    && !ast.ref_is_null(let_type_ref)) {
                  let init_ez: Expr = ast.ast_arena_expr_get(arena, linit_ref);
                  let tk_z: i32 = pipeline_type_kind_ord_at(arena, let_type_ref);
                  let is_vec_ty: i32 = 0;
                  if (tk_z == TypeKind.TYPE_VECTOR as i32) {
                    is_vec_ty = 1;
                  } else if (tk_z == TypeKind.TYPE_NAMED as i32) {
                    let vzn: u8[256] = [];
                    let vzn_l: i32 = pipeline_type_named_name_into(arena, let_type_ref, &vzn[0]);
                    let vi: i32 = 0;
                    while (vi < vzn_l) {
                      if (vzn[vi] == 120) {
                        is_vec_ty = 1;
                        vi = vzn_l;
                      } else {
                        vi = vi + 1;
                      }
                    }
                  }
                  if (is_vec_ty != 0) {
                    if ((init_ez.kind as i32) == (ExprKind.EXPR_LIT as i32) && init_ez.int_val == 0) {
                      use_vec_z = 1;
                    } else if ((init_ez.kind as i32) == (ExprKind.EXPR_ARRAY_LIT as i32)) {
                      use_vec_braced = 1;
                    }
                  }
                }
                if (use_vec_z != 0) {
                  let vz: u8[6] = [123, 32, 48, 32, 125, 0];
                  if (emit_bytes_6(out, &vz[0], 5) != 0) {
                    return -1;
                  }
                } else if (use_vec_braced != 0) {
                  if (codegen_emit_braced_array_lit_init(arena, out, linit_ref, ctx) != 0) {
                    return -1;
                  }
                } else {
                  /* F2: TYPE_DYN LHS + concrete (non-null-sentinel) RHS -> wrap
                   * in fat-ptr compound literal. F3: vtable now built from
                   * trait methods via codegen_emit_dyn_vtable_close.
                   * PLATFORM: SHARED host-C. */
                  let dyn_wrap: i32 = 0;
                  let lt_dyn: i32 = pipeline_typeck_resolve_type_alias_ref_c(arena, let_type_ref);
                  if (lt_dyn > 0 && pipeline_type_kind_ord_at(arena, lt_dyn) == (TypeKind.TYPE_DYN as i32)) {
                    let rhs_rt: i32 = pipeline_expr_resolved_type_ref(arena, linit_ref);
                    if (typeck_dyn_rhs_is_null_sentinel(arena, rhs_rt, linit_ref) == 0) {
                      dyn_wrap = 1;
                      /*
                       * F5 PTR-to-NAMED for-type: when RHS is itself a pointer
                       * (TYPE_PTR), do NOT take address-of — data IS the pointer
                       * (matches impl self: *T for impl Trait for *T). For by-value
                       * RHS, keep & so data becomes a pointer to the value.
                       * Byte layout: "(struct xlang_dyn_obj){ .data = " (32 bytes)
                       * + "&(" (2 bytes) for by-value, or "(" (1 byte) for by-pointer.
                       * PLATFORM: SHARED host-C; seed codegen_gen.linux.x86_64.c mirrors.
                       */
                      let dyn_open: u8[34] = [40, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 100, 121, 110, 95, 111, 98, 106, 41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 38, 40];
                      let rhs_kind_ord: i32 = pipeline_type_kind_ord_at(arena, rhs_rt);
                      if (rhs_kind_ord == (TypeKind.TYPE_PTR as i32)) {
                        /* Skip byte 32 (the &); emit bytes 0..31 + byte 33 (the open paren). */
                        if (codegen_emit_bytes_from_ptr(out, &dyn_open[0], 32) != 0) {
                          return -1;
                        }
                        if (codegen_append_byte(out, dyn_open[33]) != 0) {
                          return -1;
                        }
                      } else {
                        /*
                         * F6: Builtin by-value RHS — emit "&((<C-type>){" so
                         * & has a valid lvalue (compound literal).
                         * codegen_emit_dyn_vtable_close closes with "}".
                         * Non-builtin by-value keeps the F2 "&(" path
                         * (NAMED RHS has storage).
                         * PLATFORM: SHARED host-C; seed mirrors.
                         */
                        let bnm: u8[16] = [];
                        let blen: i32 = codegen_builtin_type_name_into(rhs_kind_ord, &bnm[0]);
                        if (blen > 0) {
                          /* Emit "(struct xlang_dyn_obj){ .data = " — 32 bytes (dyn_open 0..31). */
                          if (codegen_emit_bytes_from_ptr(out, &dyn_open[0], 32) != 0) { return -1; }
                          /* Emit "&((" — 3 bytes. */
                          if (codegen_append_byte(out, 38) != 0) { return -1; }
                          if (codegen_append_byte(out, 40) != 0) { return -1; }
                          if (codegen_append_byte(out, 40) != 0) { return -1; }
                          /* Emit the C type (int32_t/f64/...). */
                          if (codegen_emit_type_kind(out, rhs_kind_ord) != 0) { return -1; }
                          /* Emit "){" — 2 bytes (close cast + open compound literal). */
                          if (codegen_append_byte(out, 41) != 0) { return -1; }
                          if (codegen_append_byte(out, 123) != 0) { return -1; }
                        } else {
                          if (codegen_emit_bytes_from_ptr(out, &dyn_open[0], 34) != 0) {
                            return -1;
                          }
                        }
                      }
                    }
                  }
                  let _stn: i32 = codegen_stamp_anon_struct_lit_dest(arena, linit_ref, let_type_ref);
                  _stn = _stn;
                  if (codegen_emit_expr(arena, out, linit_ref, ctx) != 0) {
                    return -1;
                  }
                  if (dyn_wrap != 0) {
                    let rhs_rt: i32 = pipeline_expr_resolved_type_ref(arena, linit_ref);
                    if (codegen_emit_dyn_vtable_close(arena, out, ctx, lt_dyn, rhs_rt) != 0) {
                      return -1;
                    }
                  }
                }
              }
              let sc: u8[3] = [59, 10, 0];
              if (codegen_emit_bytes_3(out, &sc[0], 2) != 0) {
                return -1;
              }
            }
          }
        } else if (k == 2) {
          /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
          let nexpr_k: i32 = ast_ast_block_num_expr_stmts(arena, block_ref);
          if (idx >= 0 && idx < nexpr_k) {
            let ex_ref: i32 = ast_ast_block_expr_stmt_ref(arena, block_ref, idx);
            let st: Expr = ast.ast_arena_expr_get(arena, ex_ref);
            if ((st.kind as i32) == (ExprKind.EXPR_RETURN as i32)) {
              if (emit_return_stmt_with_context(arena, out, indent, st.unary_operand_ref, ctx, fn_ret_void) != 0) {
                return -1;
              }
            } else if ((st.kind as i32) == (ExprKind.EXPR_BREAK as i32)) {
              if (emit_break_stmt(out, indent) != 0) {
                return -1;
              }
            } else if ((st.kind as i32) == (ExprKind.EXPR_CONTINUE as i32)) {
              if (emit_continue_stmt(out, indent) != 0) {
                return -1;
              }
            } else if ((st.kind as i32) == (ExprKind.EXPR_MATCH as i32)
                && codegen_match_has_return_arm(arena, ex_ref) != 0) {
              /* wave372: mid-body match + return arms → if/else real early-return */
              if (codegen_emit_match_as_stmt(arena, out, ex_ref, indent, ctx, fn_ret_void) != 0) {
                return -1;
              }
            } else {
              if (codegen_emit_indent(out, indent) != 0) {
                return -1;
              }
              let v: u8[9] = [40, 118, 111, 105, 100, 41, 40, 0, 0];
              if (codegen_emit_bytes_9(out, &v[0], 7) != 0) {
                return -1;
              }
              if (codegen_emit_expr(arena, out, ex_ref, ctx) != 0) {
                return -1;
              }
              let sc: u8[4] = [41, 59, 10, 0];
              if (codegen_emit_bytes_4(out, &sc[0], 3) != 0) {
                return -1;
              }
            }
          }
        } else if (k == 3) {
          /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
          let nloop_k: i32 = ast_ast_block_num_loops(arena, block_ref);
          if (idx >= 0 && idx < nloop_k) {
            let w_cr: i32 = ast_ast_block_while_cond_ref(arena, block_ref, idx);
            let w_br: i32 = ast_ast_block_while_body_ref(arena, block_ref, idx);
            if (codegen_emit_indent(out, indent) != 0) {
              return -1;
            }
            let wh: u8[8] = [119, 104, 105, 108, 101, 32, 40, 0];
            if (codegen_emit_bytes_8(out, &wh[0], 7) != 0) {
              return -1;
            }
            if (codegen_emit_expr(arena, out, w_cr, ctx) != 0) {
              return -1;
            }
            let paren: u8[5] = [41, 32, 123, 10, 0];
            if (emit_bytes_5(out, &paren[0], 4) != 0) {
              return -1;
            }
            if (codegen_emit_block(arena, out, w_br, indent + 2, ctx) != 0) {
              return -1;
            }
            if (codegen_emit_indent(out, indent) != 0) {
              return -1;
            }
            let close: u8[3] = [125, 10, 0];
            if (codegen_emit_bytes_3(out, &close[0], 2) != 0) {
              return -1;
            }
          }
        } else if (k == 4) {
          /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
          let nfor_k: i32 = ast_ast_block_num_for_loops(arena, block_ref);
          if (idx >= 0 && idx < nfor_k) {
            let fl_ir: i32 = ast_ast_block_for_init_ref(arena, block_ref, idx);
            let fl_cr: i32 = ast_ast_block_for_cond_ref(arena, block_ref, idx);
            let fl_sr: i32 = ast_ast_block_for_step_ref(arena, block_ref, idx);
            let fl_br: i32 = ast_ast_block_for_body_ref(arena, block_ref, idx);
            if (codegen_emit_indent(out, indent) != 0) {
              return -1;
            }
            let fk: u8[6] = [102, 111, 114, 32, 40, 0];
            if (emit_bytes_6(out, &fk[0], 5) != 0) {
              return -1;
            }
            if (!ast.ref_is_null(fl_ir)) {
              if (codegen_emit_expr(arena, out, fl_ir, ctx) != 0) {
                return -1;
              }
            }
            let sc1: u8[3] = [59, 32, 0];
            if (codegen_emit_bytes_3(out, &sc1[0], 2) != 0) {
              return -1;
            }
            if (!ast.ref_is_null(fl_cr)) {
              if (codegen_emit_expr(arena, out, fl_cr, ctx) != 0) {
                return -1;
              }
            }
            let sc2: u8[3] = [59, 32, 0];
            if (codegen_emit_bytes_3(out, &sc2[0], 2) != 0) {
              return -1;
            }
            if (!ast.ref_is_null(fl_sr)) {
              if (codegen_emit_expr(arena, out, fl_sr, ctx) != 0) {
                return -1;
              }
            }
            let paren: u8[5] = [41, 32, 123, 10, 0];
            if (emit_bytes_5(out, &paren[0], 4) != 0) {
              return -1;
            }
            if (!ast.ref_is_null(fl_br) && codegen_emit_block(arena, out, fl_br, indent + 2, ctx) != 0) {
              return -1;
            }
            if (codegen_emit_indent(out, indent) != 0) {
              return -1;
            }
            let close: u8[3] = [125, 10, 0];
            if (codegen_emit_bytes_3(out, &close[0], 2) != 0) {
              return -1;
            }
          }
        } else if (k == 5) {
          /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
          let nif_k: i32 = ast_ast_block_num_if_stmts(arena, block_ref);
          if (idx >= 0 && idx < nif_k) {
            let if_cond_r: i32 = ast_ast_block_if_cond_ref(arena, block_ref, idx);
            let if_then_r: i32 = ast_ast_block_if_then_body_ref(arena, block_ref, idx);
            let if_else_r: i32 = ast_ast_block_if_else_body_ref(arena, block_ref, idx);
            if (codegen_emit_indent(out, indent) != 0) {
              return -1;
            }
            let ikw: u8[5] = [105, 102, 32, 40, 0];
            if (emit_bytes_5(out, &ikw[0], 4) != 0) {
              return -1;
            }
            if (codegen_emit_expr(arena, out, if_cond_r, ctx) != 0) {
              return -1;
            }
            let paren_if: u8[5] = [41, 32, 123, 10, 0];
            if (emit_bytes_5(out, &paren_if[0], 4) != 0) {
              return -1;
            }
            if (codegen_emit_block(arena, out, if_then_r, indent + 2, ctx) != 0) {
              return -1;
            }
            if (codegen_emit_indent(out, indent) != 0) {
              return -1;
            }
            if (if_else_r != 0) {
              /* See implementation. */
              let else_brace: u8[9] = [125, 32, 101, 108, 115, 101, 32, 123, 10];
              if (codegen_emit_bytes_9(out, &else_brace[0], 9) != 0) {
                return -1;
              }
              if (codegen_emit_block(arena, out, if_else_r, indent + 2, ctx) != 0) {
                return -1;
              }
              if (codegen_emit_indent(out, indent) != 0) {
                return -1;
              }
            }
            let cif: u8[3] = [125, 10, 0];
            if (codegen_emit_bytes_3(out, &cif[0], 2) != 0) {
              return -1;
            }
          }
        } else if (k == 6) {
          /**
           * See implementation.
           * See implementation.
           * See implementation.
           * See implementation.
           * See implementation.
           */
          /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
          let nreg_k: i32 = ast_ast_block_num_regions(arena, block_ref);
          if (idx >= 0 && idx < nreg_k) {
            let reg_body: i32 = ast_ast_block_region_body_ref(arena, block_ref, idx);
            let need_scope: i32 = 0;
            if (!ast.ref_is_null(reg_body) && reg_body > 0 && reg_body <= arena.num_blocks) {
              if (ast_ast_block_num_lets(arena, reg_body) > 0
                  || ast_ast_block_num_consts(arena, reg_body) > 0) {
                need_scope = 1;
              }
            }
            if (need_scope != 0) {
              if (codegen_emit_indent(out, indent) != 0) {
                return -1;
              }
              let ob: u8[2] = [123, 10];
              if (codegen_emit_bytes_2(out, &ob[0], 2) != 0) {
                return -1;
              }
              /* Last dest-from-region dest: wrapping already hoisted. */
              let saved_skip_sc: i32 = g_codegen_skip_wrap_dest;
              if (last_dest_region != 0 && si == (so_n - 1)) {
                g_codegen_skip_wrap_dest = 1;
              }
              if (codegen_emit_block(arena, out, reg_body, indent + 2, ctx) != 0) {
                return -1;
              }
              g_codegen_skip_wrap_dest = saved_skip_sc;
              if (codegen_emit_indent(out, indent) != 0) {
                return -1;
              }
              let cb: u8[3] = [125, 10, 0];
              if (codegen_emit_bytes_3(out, &cb[0], 2) != 0) {
                return -1;
              }
            } else {
              let saved_skip_ns: i32 = g_codegen_skip_wrap_dest;
              if (last_dest_region != 0 && si == (so_n - 1)) {
                g_codegen_skip_wrap_dest = 1;
              }
              if (codegen_emit_block(arena, out, reg_body, indent, ctx) != 0) {
                return -1;
              }
              g_codegen_skip_wrap_dest = saved_skip_ns;
            }
          }
        } else if (k == 7) {
          /**
           * wave379: labeled/goto (docs/03).
           * is_goto → `goto T;`; else `L:` then optional `return e;`.
           * PLATFORM: SHARED host-C. wave387: freestanding/default asm kind=7 closed
           * in pipeline_asm_emit_block_body_sync_elf (G.7 labeled pool + enc_jmp/label).
           */
          /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
          let nlab_k: i32 = pipeline_block_num_labeled_stmts(arena, block_ref);
          if (idx >= 0 && idx < nlab_k) {
            let is_g: i32 = pipeline_block_labeled_is_goto(arena, block_ref, idx);
            if (is_g != 0) {
              if (codegen_emit_indent(out, indent) != 0) {
                return -1;
              }
              /* "goto " */
              let gkw: u8[6] = [103, 111, 116, 111, 32, 0];
              if (codegen_emit_bytes_from_ptr(out, &gkw[0], 5) != 0) {
                return -1;
              }
              /* wave586 Cap residual: label/goto name scratch 128 (content ≤255). */
              let gt_buf: u8[256] = [];
              pipeline_block_labeled_goto_target_copy32(arena, block_ref, idx, &gt_buf[0]);
              let gt_len: i32 = pipeline_block_labeled_goto_target_len(arena, block_ref, idx);
              if (gt_len > 0 && gt_len <= 255) {
                if (codegen_emit_bytes_from_ptr(out, &gt_buf[0], gt_len) != 0) {
                  return -1;
                }
              }
              let gend: u8[3] = [59, 10, 0];
              if (codegen_emit_bytes_from_ptr(out, &gend[0], 2) != 0) {
                return -1;
              }
            } else {
              /* wave586 Cap residual: label name scratch 128 (content ≤255). */
              let lb_buf: u8[256] = [];
              pipeline_block_labeled_label_copy32(arena, block_ref, idx, &lb_buf[0]);
              let lb_len: i32 = pipeline_block_labeled_label_len(arena, block_ref, idx);
              if (lb_len > 0 && lb_len <= 255) {
                if (codegen_emit_indent(out, indent) != 0) {
                  return -1;
                }
                if (codegen_emit_bytes_from_ptr(out, &lb_buf[0], lb_len) != 0) {
                  return -1;
                }
                let colon_nl: u8[3] = [58, 10, 0];
                if (codegen_emit_bytes_from_ptr(out, &colon_nl[0], 2) != 0) {
                  return -1;
                }
              }
              let ret_ref_lab: i32 = pipeline_block_labeled_return_expr_ref(arena, block_ref, idx);
              if (!ast.ref_is_null(ret_ref_lab) && ret_ref_lab > 0) {
                if (emit_return_stmt_with_context(arena, out, indent, ret_ref_lab, ctx, fn_ret_void) != 0) {
                  return -1;
                }
              } else if (ret_ref_lab == 0 && lb_len > 0) {
                /* Pure label or bare `return;` with null operand: if return_expr was
                 * intentionally empty for labeled bare return, emit `return;` for void. */
                /* Pure label only — no return. */
              }
            }
          }
        }
        si = si + 1;
      }
      if (skip_wrap_dest == 0 && last_dest_region == 0) {
        if (emit_run_defers(arena, out, block_ref, indent, ctx) != 0) {
          return -1;
        }
      }
      let final_ref: i32 = ast_ast_block_final_expr_ref(arena, block_ref);
      if (emit_block_final_expr(arena, out, block_ref, final_ref, indent, ctx, fn_ret_void) != 0) {
        return -1;
      }
      return 0;
    }
    /* See implementation. */
    let i: i32 = 0;
    /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
    let nconst_fb: i32 = ast_ast_block_num_consts(arena, block_ref);
    while (i < nconst_fb) {
      let cname_fb: u8[256] = [];
      pipeline_block_const_name_copy64(arena, block_ref, i, &cname_fb[0]);
      let cname_len_fb: i32 = pipeline_block_const_name_len(arena, block_ref, i);
      let ctype_fb: i32 = pipeline_block_const_type_ref(arena, block_ref, i);
      let cinit_fb: i32 = pipeline_block_const_init_ref(arena, block_ref, i);
      if (codegen_emit_indent(out, indent) != 0) {
        return -1;
      }
      if (codegen_emit_type(arena, out, ctype_fb, &blk_prefix[0], blk_prefix_len, ctx) != 0) {
        return -1;
      }
      let sp: u8[3] = [32, 0, 0];
      if (codegen_emit_bytes_3(out, &sp[0], 1) != 0) {
        return -1;
      }
      /* See implementation. */
      if (cname_len_fb > 0 && (cname_fb[0] > 32)) {
        if (codegen_emit_bytes_64(out, &cname_fb[0], cname_len_fb) != 0) {
          return -1;
        }
      } else {
        let place: u8[4] = [95, 99, 48, 0];
        if (codegen_emit_bytes_4(out, &place[0], 2) != 0) {
          return -1;
        }
        if (format_int(out, i) != 0) {
          return -1;
        }
      }
      let eq: u8[4] = [32, 61, 32, 0];
      if (codegen_emit_bytes_4(out, &eq[0], 3) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, cinit_fb, ctx) != 0) {
        return -1;
      }
      let sc: u8[3] = [59, 10, 0];
      if (codegen_emit_bytes_3(out, &sc[0], 2) != 0) {
        return -1;
      }
      i = i + 1;
    }
    i = 0;
    /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
    let nlets_fb: i32 = ast_ast_block_num_lets(arena, block_ref);
    while (i < nlets_fb) {
      let lname_fb: u8[256] = [];
      pipeline_block_let_name_copy64(arena, block_ref, i, &lname_fb[0]);
      let lname_len_fb: i32 = pipeline_block_let_name_len(arena, block_ref, i);
      let let_type_ref: i32 = pipeline_block_let_type_ref(arena, block_ref, i);
      let linit_fb: i32 = pipeline_block_let_init_ref(arena, block_ref, i);
      if (codegen_emit_indent(out, indent) != 0) {
        return -1;
      }
      /* See implementation. */
      let type_emitted: i32 = 0;
      let use_local_array: i32 = 0;
      let use_fnptr: i32 = 0;
      let fnptr_array_ty: i32 = 0;
      let use_fnptr_array_init: i32 = 0;
      let fn_leaf_fb: i32 = 0;
      if (!ast.ref_is_null(let_type_ref) && pipeline_type_kind_ord_at(arena, let_type_ref) == 10) {
        use_local_array = 1;
      }
      /* 10.3.1 fallback let: TYPE_FN → named fnptr declarator (mirror primary path). */
      if (use_local_array != 0 && !ast.ref_is_null(let_type_ref)) {
        fn_leaf_fb = let_type_ref;
        while (!ast.ref_is_null(fn_leaf_fb)
            && pipeline_type_kind_ord_at(arena, fn_leaf_fb) == (TypeKind.TYPE_ARRAY as i32)) {
          let inn_fb: i32 = pipeline_type_elem_ref_at(arena, fn_leaf_fb);
          if (ast.ref_is_null(inn_fb)) {
            break;
          }
          fn_leaf_fb = inn_fb;
        }
        if (pipeline_type_kind_ord_at(arena, fn_leaf_fb) == (TypeKind.TYPE_FN as i32)) {
          use_fnptr = 1;
          fnptr_array_ty = let_type_ref;
          use_fnptr_array_init = 1;
          use_local_array = 0;
        }
      }
      if (use_local_array == 0 && use_fnptr == 0 && !ast.ref_is_null(let_type_ref)
          && pipeline_type_kind_ord_at(arena, let_type_ref) == (TypeKind.TYPE_FN as i32)) {
        use_fnptr = 1;
      }
      if (use_local_array != 0) {
        if (codegen_emit_local_fixed_array_elem_type(arena, out, let_type_ref, ctx) != 0) {
          return -1;
        }
        type_emitted = 1;
      }
      if (!ast.ref_is_null(linit_fb) && linit_fb > 0 && linit_fb <= arena.num_exprs) {
        let init_e: Expr = ast.ast_arena_expr_get(arena, linit_fb);
        if (type_emitted == 0 && (init_e.kind as i32) == (ExprKind.EXPR_ARRAY_LIT as i32) && type_array_elem_is_u8(arena, let_type_ref) != 0) {
          let u8ptr: u8[9] = [117, 105, 110, 116, 56, 95, 116, 32, 0];
          if (codegen_emit_bytes_9(out, &u8ptr[0], 7) != 0) {
            return -1;
          }
          if (codegen_append_byte(out, 42) != 0) {
            return -1;
          }
          type_emitted = 1;
        }
        if (type_emitted == 0 && !ast.ref_is_null(init_e.resolved_type_ref) && init_e.resolved_type_ref > 0 && init_e.resolved_type_ref <= arena.num_types) {
          let rt2: Type = ast.ast_arena_type_get(arena, init_e.resolved_type_ref);
          if ((rt2.kind as i32) == (TypeKind.TYPE_NAMED as i32) && rt2.name_len >= 6) {
            let n02: i32 = rt2.name_len - 6;
            if (rt2.name[n02] == 83 && rt2.name[n02 + 1] == 116 && rt2.name[n02 + 2] == 114 && rt2.name[n02 + 3] == 105 && rt2.name[n02 + 4] == 110 && rt2.name[n02 + 5] == 103) {
              /* See implementation. */
              let str_ty2a: u8[7] = [83, 116, 114, 105, 110, 103, 0];
              if (codegen_emit_bytes_from_ptr(out, &str_ty2a[0], 6) != 0) {
                return -1;
              }
              if (codegen_append_byte(out, 32) != 0) {
                return -1;
              }
              type_emitted = 1;
            }
          }
        }
        if (type_emitted == 0 && (init_e.kind as i32) == (ExprKind.EXPR_CALL as i32) && !ast.ref_is_null(init_e.call_callee_ref) && init_e.call_callee_ref > 0 && init_e.call_callee_ref <= arena.num_exprs) {
          let callee_let2: Expr = ast.ast_arena_expr_get(arena, init_e.call_callee_ref);
          if ((callee_let2.kind as i32) == (ExprKind.EXPR_VAR as i32)) {
            if (codegen_callee_var_is_string_new(callee_let2) != 0) {
              let str_ty2: u8[7] = [83, 116, 114, 105, 110, 103, 0];
              if (codegen_emit_bytes_from_ptr(out, &str_ty2[0], 6) != 0) {
                return -1;
              }
              if (codegen_append_byte(out, 32) != 0) {
                return -1;
              }
              type_emitted = 1;
            }
          }
        }
      }
      /* Build local name before type emit (fnptr embeds name in declarator). */
      let emit_nm_fb: u8[256] = [];
      let emit_nml_fb: i32 = 0;
      if (lname_len_fb > 0 && (lname_fb[0] > 32)) {
        let ci3: i32 = 0;
        while (ci3 < lname_len_fb && ci3 < 128) {
          emit_nm_fb[ci3] = lname_fb[ci3];
          ci3 = ci3 + 1;
        }
        emit_nml_fb = lname_len_fb;
      } else {
        emit_nm_fb[0] = 95;
        emit_nm_fb[1] = 108;
        emit_nml_fb = 2;
        let v3: i32 = i;
        let digs3: u8[12] = [];
        let nd3: i32 = 0;
        if (v3 == 0) {
          digs3[0] = 48;
          nd3 = 1;
        } else {
          let tmp3: i32 = v3;
          while (tmp3 > 0 && nd3 < 12) {
            digs3[nd3] = ((tmp3 % 10) + 48) as u8;
            tmp3 = tmp3 / 10;
            nd3 = nd3 + 1;
          }
          let a3: i32 = 0;
          let b3: i32 = nd3 - 1;
          while (a3 < b3) {
            let sw3: u8 = digs3[a3];
            digs3[a3] = digs3[b3];
            digs3[b3] = sw3;
            a3 = a3 + 1;
            b3 = b3 - 1;
          }
        }
        let pi3: i32 = 0;
        while (pi3 < nd3 && emit_nml_fb < 128) {
          emit_nm_fb[emit_nml_fb] = digs3[pi3];
          emit_nml_fb = emit_nml_fb + 1;
          pi3 = pi3 + 1;
        }
      }
      if (use_fnptr != 0 && type_emitted == 0) {
        fn_leaf_fb = let_type_ref;
        if (fnptr_array_ty > 0) {
          fn_leaf_fb = fnptr_array_ty;
          while (!ast.ref_is_null(fn_leaf_fb)
              && pipeline_type_kind_ord_at(arena, fn_leaf_fb) == (TypeKind.TYPE_ARRAY as i32)) {
            let inn_fb2: i32 = pipeline_type_elem_ref_at(arena, fn_leaf_fb);
            if (ast.ref_is_null(inn_fb2)) {
              break;
            }
            fn_leaf_fb = inn_fb2;
          }
        }
        if (codegen_emit_c_fnptr_decl(arena, out, fn_leaf_fb, &emit_nm_fb[0], emit_nml_fb, fnptr_array_ty, ctx) != 0) {
          return -1;
        }
        type_emitted = 1;
      } else if (type_emitted == 0) {
        if (ast.ref_is_null(let_type_ref) && !ast.ref_is_null(linit_fb) && linit_fb > 0 && linit_fb <= arena.num_exprs) {
          let init_e: Expr = ast.ast_arena_expr_get(arena, linit_fb);
          if (!ast.ref_is_null(init_e.resolved_type_ref)) {
            let_type_ref = init_e.resolved_type_ref;
          }
        }
        if (codegen_emit_type(arena, out, let_type_ref, &blk_prefix[0], blk_prefix_len, ctx) != 0) {
          return -1;
        }
      }
      if (use_fnptr == 0) {
        if (codegen_append_byte(out, 32) != 0) {
          return -1;
        }
        if (codegen_emit_bytes_64(out, &emit_nm_fb[0], emit_nml_fb) != 0) {
          return -1;
        }
      }
      if (use_local_array != 0) {
        if (codegen_emit_local_fixed_array_suffix(arena, out, let_type_ref) != 0) {
          return -1;
        }
      }
      /* wave353: fixed TYPE_ARRAY local let finish (brace or memcpy). */
      if (use_local_array != 0) {
        if (emit_local_fixed_array_let_finish(arena, out, indent, &emit_nm_fb[0], emit_nml_fb, linit_fb, let_type_ref, ctx) != 0) {
          return -1;
        }
      } else if (use_fnptr_array_init != 0) {
        if (emit_local_fixed_array_let_finish(arena, out, indent, &emit_nm_fb[0], emit_nml_fb, linit_fb, fnptr_array_ty, ctx) != 0) {
          return -1;
        }
      } else {
        let eq: u8[4] = [32, 61, 32, 0];
        if (codegen_emit_bytes_4(out, &eq[0], 3) != 0) {
          return -1;
        }
        /* 10.3.1 slice15: TYPE_FN let init Cap cast (fallback block path). */
        if (use_fnptr != 0 && use_fnptr_array_init == 0 && !ast.ref_is_null(linit_fb)) {
          let cast_fn_fb: i32 = fn_leaf_fb;
          if (cast_fn_fb <= 0) {
            cast_fn_fb = let_type_ref;
          }
          if (codegen_append_byte(out, 40) != 0) {
            return -1;
          }
          if (codegen_emit_c_fnptr_decl(arena, out, cast_fn_fb, 0 as *u8, 0, 0, ctx) != 0) {
            return -1;
          }
          if (codegen_append_byte(out, 41) != 0) {
            return -1;
          }
        }
        if (ast.ref_is_null(linit_fb)) {
          let zinit_omit: u8[6] = [123, 32, 48, 32, 125, 0];
          if (emit_bytes_6(out, &zinit_omit[0], 5) != 0) {
            return -1;
          }
        } else {
          let _stf: i32 = codegen_stamp_anon_struct_lit_dest(arena, linit_fb, let_type_ref);
          _stf = _stf;
          if (codegen_emit_expr(arena, out, linit_fb, ctx) != 0) {
            return -1;
          }
        }
        let sc: u8[3] = [59, 10, 0];
        if (codegen_emit_bytes_3(out, &sc[0], 2) != 0) {
          return -1;
        }
      }
      i = i + 1;
    }
    /* See implementation. */
    i = 0;
    /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
    let nexpr_fb: i32 = ast_ast_block_num_expr_stmts(arena, block_ref);
    while (i < nexpr_fb) {
      let ex_fb: i32 = ast_ast_block_expr_stmt_ref(arena, block_ref, i);
      let st: Expr = ast.ast_arena_expr_get(arena, ex_fb);
      if ((st.kind as i32) == (ExprKind.EXPR_RETURN as i32)) {
        if (emit_return_stmt_with_context(arena, out, indent, st.unary_operand_ref, ctx, fn_ret_void) != 0) {
          return -1;
        }
      } else if ((st.kind as i32) == (ExprKind.EXPR_BREAK as i32)) {
        if (codegen_emit_indent(out, indent) != 0) {
          return -1;
        }
        let br: u8[8] = [98, 114, 101, 97, 107, 59, 10, 0];
        if (codegen_emit_bytes_8(out, &br[0], 7) != 0) {
          return -1;
        }
      } else if ((st.kind as i32) == (ExprKind.EXPR_CONTINUE as i32)) {
        if (codegen_emit_indent(out, indent) != 0) {
          return -1;
        }
        let co: u8[11] = [99, 111, 110, 116, 105, 110, 117, 101, 59, 10, 0];
        if (codegen_emit_bytes_from_ptr(out, &co[0], 10) != 0) {
          return -1;
        }
      } else if ((st.kind as i32) == (ExprKind.EXPR_MATCH as i32)
          && codegen_match_has_return_arm(arena, ex_fb) != 0) {
        /* wave372: mid-body match + return arms → if/else real early-return */
        if (codegen_emit_match_as_stmt(arena, out, ex_fb, indent, ctx, fn_ret_void) != 0) {
          return -1;
        }
      } else {
        if (codegen_emit_indent(out, indent) != 0) {
          return -1;
        }
        let v: u8[9] = [40, 118, 111, 105, 100, 41, 40, 0, 0];
        if (codegen_emit_bytes_9(out, &v[0], 7) != 0) {
          return -1;
        }
        if (codegen_emit_expr(arena, out, ex_fb, ctx) != 0) {
          return -1;
        }
        let sc: u8[4] = [41, 59, 10, 0];
        if (codegen_emit_bytes_4(out, &sc[0], 3) != 0) {
          return -1;
        }
      }
      i = i + 1;
    }
    i = 0;
    /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
    let nloop_fb: i32 = ast_ast_block_num_loops(arena, block_ref);
    while (i < nloop_fb) {
      let w_cr: i32 = ast_ast_block_while_cond_ref(arena, block_ref, i);
      let w_br: i32 = ast_ast_block_while_body_ref(arena, block_ref, i);
      if (codegen_emit_indent(out, indent) != 0) {
        return -1;
      }
      let wh: u8[8] = [119, 104, 105, 108, 101, 32, 40, 0];
      if (codegen_emit_bytes_8(out, &wh[0], 7) != 0) {
        return -1;
      }
      if (codegen_emit_expr(arena, out, w_cr, ctx) != 0) {
        return -1;
      }
      let paren: u8[5] = [41, 32, 123, 10, 0];
      if (emit_bytes_5(out, &paren[0], 4) != 0) {
        return -1;
      }
      if (codegen_emit_block(arena, out, w_br, indent + 2, ctx) != 0) {
        return -1;
      }
      if (codegen_emit_indent(out, indent) != 0) {
        return -1;
      }
      let close: u8[3] = [125, 10, 0];
      if (codegen_emit_bytes_3(out, &close[0], 2) != 0) {
        return -1;
      }
      i = i + 1;
    }
    i = 0;
    /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
    let nfor_fb: i32 = ast_ast_block_num_for_loops(arena, block_ref);
    while (i < nfor_fb) {
      let fl_ir: i32 = ast_ast_block_for_init_ref(arena, block_ref, i);
      let fl_cr: i32 = ast_ast_block_for_cond_ref(arena, block_ref, i);
      let fl_sr: i32 = ast_ast_block_for_step_ref(arena, block_ref, i);
      let fl_br: i32 = ast_ast_block_for_body_ref(arena, block_ref, i);
      if (codegen_emit_indent(out, indent) != 0) {
        return -1;
      }
      let fk: u8[6] = [102, 111, 114, 32, 40, 0];
      if (emit_bytes_6(out, &fk[0], 5) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(fl_ir)) {
        if (codegen_emit_expr(arena, out, fl_ir, ctx) != 0) {
          return -1;
        }
      }
      let sc1: u8[3] = [59, 32, 0];
      if (codegen_emit_bytes_3(out, &sc1[0], 2) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(fl_cr)) {
        if (codegen_emit_expr(arena, out, fl_cr, ctx) != 0) {
          return -1;
        }
      }
      let sc2: u8[3] = [59, 32, 0];
      if (codegen_emit_bytes_3(out, &sc2[0], 2) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(fl_sr)) {
        if (codegen_emit_expr(arena, out, fl_sr, ctx) != 0) {
          return -1;
        }
      }
      let paren: u8[5] = [41, 32, 123, 10, 0];
      if (emit_bytes_5(out, &paren[0], 4) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(fl_br) && codegen_emit_block(arena, out, fl_br, indent + 2, ctx) != 0) {
        return -1;
      }
      if (codegen_emit_indent(out, indent) != 0) {
        return -1;
      }
      let close: u8[3] = [125, 10, 0];
      if (codegen_emit_bytes_3(out, &close[0], 2) != 0) {
        return -1;
      }
      i = i + 1;
    }
    /* dest-region-body dest is often stmt_order==0 (defer pool +
     * final_expr dest). Wrapping already hoisted dest-region-body
     * then wrapping (LIFO last-wins outer). skip-wrap must skip
     * this second emit_run_defers so dest stays GNU last value.
     * PLATFORM: SHARED host-C dest-from-region dest-region-body last-wins. */
    if (skip_wrap_dest == 0) {
      if (emit_run_defers(arena, out, block_ref, indent, ctx) != 0) {
        return -1;
      }
    }
    /* See implementation. */
    let final_ref_plain: i32 = ast_ast_block_final_expr_ref(arena, block_ref);
    if (emit_block_final_expr(arena, out, block_ref, final_ref_plain, indent, ctx, fn_ret_void) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function emit_suffix_bytes(dst: *u8, src: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    dst[i] = src[i];
    i = i + 1;
  }
  return len;
}

/**
 * Map a type_ref to a C-safe mangle suffix (overload / mono / generic-struct tags).
 * wave484: TYPE_NAMED with type-pos args appends nested `_` + recursive arg suffixes
 * so Wrap&lt;Wrap&lt;A&gt;&gt; ≠ Wrap&lt;A&gt; (name-only collided as "Wrap").
 * @param arena *ASTArena — type arena
 * @param type_ref i32 — type to mangle
 * @param buf *u8 — output buffer
 * @param buf_cap i32 — capacity
 * @return i32 — bytes written, or 0 on failure
 * PLATFORM: SHARED — G.7 single authority with seed codegen_gen
 */
export function codegen_type_ref_to_suffix(arena: *ASTArena, type_ref: i32, buf: *u8, buf_cap: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (type_ref <= 0 || buf == 0 as *u8 || buf_cap <= 0) {
      return 0;
    }
    let tk: i32 = pipeline_type_kind_ord_at(arena, type_ref);
    /* See implementation. */
    if (tk == (TypeKind.TYPE_PTR as i32)) {
      let elem_ref: i32 = pipeline_type_elem_ref_at(arena, type_ref);
      let n: i32 = codegen_type_ref_to_suffix(arena, elem_ref, buf, buf_cap);
      if (n > 0 && n + 4 < buf_cap) {
        buf[n] = 95;
        buf[n + 1] = 112;
        buf[n + 2] = 116;
        buf[n + 3] = 114;
        return n + 4;
      }
      return n;
    }
    /*
     * TYPE_NAMED: base name, then nested type-pos args as `_` + recursive suffixes.
     * Examples: A → "A"; Wrap&lt;A&gt; → "Wrap_A"; Wrap&lt;Wrap&lt;A&gt;&gt; → "Wrap_Wrap_A";
     * Pair&lt;A,B&gt; → "Pair_A_B". Outer mono tags also use Name_… (single `_`;
     * same as typeck named-inst — no dual `Name__…` authority).
     * PLATFORM: SHARED — uses pipeline_type_type_arg_ref_at (wave466/467 sidecar).
     */
    if (tk == (TypeKind.TYPE_NAMED as i32)) {
      let nl: i32 = pipeline_type_named_name_into(arena, type_ref, buf);
      let si: i32 = 0;
      while (si < nl && si < buf_cap) {
        if (buf[si] == 46) { buf[si] = 95; }
        si = si + 1;
      }
      if (nl <= 0 || nl >= buf_cap) {
        return 0;
      }
      let pos: i32 = nl;
      let ai: i32 = 0;
      while (ai < 4) {
        let arg: i32 = pipeline_type_type_arg_ref_at(arena, type_ref, ai);
        if (arg <= 0) {
          ai = 4;
        } else {
          let asuf: u8[256] = [];
          let al: i32 = codegen_type_ref_to_suffix(arena, arg, &asuf[0], 64);
          if (al <= 0) {
            ai = 4;
          } else if (pos + 1 + al >= buf_cap) {
            ai = 4;
          } else {
            buf[pos] = 95;
            pos = pos + 1;
            let aj: i32 = 0;
            while (aj < al) {
              buf[pos] = asuf[aj];
              pos = pos + 1;
              aj = aj + 1;
            }
            ai = ai + 1;
          }
        }
      }
      return pos;
    }
    /* See implementation. */
    if (tk == (TypeKind.TYPE_I32 as i32)) {
      let s: u8[4] = [105, 51, 50, 0];
      return emit_suffix_bytes(buf, &s[0], 3);
    }
    if (tk == (TypeKind.TYPE_I64 as i32)) {
      let s: u8[4] = [105, 54, 52, 0];
      return emit_suffix_bytes(buf, &s[0], 3);
    }
    if (tk == (TypeKind.TYPE_U8 as i32)) {
      let s: u8[3] = [117, 56, 0];
      return emit_suffix_bytes(buf, &s[0], 2);
    }
    if (tk == (TypeKind.TYPE_U32 as i32)) {
      let s: u8[4] = [117, 51, 50, 0];
      return emit_suffix_bytes(buf, &s[0], 3);
    }
    if (tk == (TypeKind.TYPE_U64 as i32)) {
      let s: u8[4] = [117, 54, 52, 0];
      return emit_suffix_bytes(buf, &s[0], 3);
    }
    if (tk == (TypeKind.TYPE_F32 as i32)) {
      let s: u8[4] = [102, 51, 50, 0];
      return emit_suffix_bytes(buf, &s[0], 3);
    }
    if (tk == (TypeKind.TYPE_F64 as i32)) {
      let s: u8[4] = [102, 54, 52, 0];
      return emit_suffix_bytes(buf, &s[0], 3);
    }
    /* TYPE_VECTOR: mangle suffix as <elem>x<lanes> (e.g. i32x4 / f32x4 / i32x8) so
     * same-name vector overloads (std_simd_add Vec8i vs Vec4f) get distinct C link
     * symbols. Without this, two vector overloads both emit a bare name and cc reports
     * "conflicting types". PLATFORM: SHARED — mirrors emit_vector_c_type_out spelling. */
    if (tk == (TypeKind.TYPE_VECTOR as i32)) {
      let elem_ref: i32 = pipeline_type_elem_ref_at(arena, type_ref);
      let lanes: i32 = pipeline_type_array_size_at(arena, type_ref);
      let ek: i32 = 0;
      let pos: i32 = 0;
      if (elem_ref <= 0 || lanes <= 0) {
        return 0;
      }
      ek = pipeline_type_kind_ord_at(arena, elem_ref);
      /* element prefix: i32->"i32", u32->"u32", f32->"f32" */
      if (ek == (TypeKind.TYPE_I32 as i32)) {
        let pre: u8[4] = [105, 51, 50, 0];
        pos = emit_suffix_bytes(buf, &pre[0], 3);
      } else if (ek == (TypeKind.TYPE_U32 as i32)) {
        let pre: u8[4] = [117, 51, 50, 0];
        pos = emit_suffix_bytes(buf, &pre[0], 3);
      } else if (ek == (TypeKind.TYPE_F32 as i32)) {
        let pre: u8[4] = [102, 51, 50, 0];
        pos = emit_suffix_bytes(buf, &pre[0], 3);
      } else {
        return 0;
      }
      if (pos <= 0) {
        return 0;
      }
      /* 'x' separator */
      if (pos < buf_cap) {
        buf[pos] = 120;
        pos = pos + 1;
      } else {
        return pos;
      }
      /* lanes decimal: 4 / 8 / 16 */
      if (lanes == 4 && pos < buf_cap) {
        buf[pos] = 52;
        return pos + 1;
      } else if (lanes == 8 && pos < buf_cap) {
        buf[pos] = 56;
        return pos + 1;
      } else if (lanes == 16 && pos + 1 < buf_cap) {
        buf[pos] = 49;
        buf[pos + 1] = 54;
        return pos + 2;
      }
      return pos;
    }
    if (tk == (TypeKind.TYPE_BOOL as i32)) {
      let s: u8[5] = [98, 111, 111, 108, 0];
      return emit_suffix_bytes(buf, &s[0], 4);
    }
    if (tk == (TypeKind.TYPE_USIZE as i32)) {
      let s: u8[6] = [117, 115, 105, 122, 101, 0];
      return emit_suffix_bytes(buf, &s[0], 5);
    }
    if (tk == (TypeKind.TYPE_ISIZE as i32)) {
      let s: u8[6] = [105, 115, 105, 122, 101, 0];
      return emit_suffix_bytes(buf, &s[0], 5);
    }
    /*
     * wave687 Cap residual: TYPE_ARRAY → `<elem>_a<N>` (e.g. i32_a2 for i32[2]).
     * Multi-dim peels via recursive elem suffix (`i32_a3_a2` for i32[2][3] outer=2).
     * Why: generic formals `T[N]` bind call-arg concrete `i32[N]` as mono combo keys;
     * codegen_emit_mono_mangled_name requires a non-empty suffix. Prior fall-through
     * returned 0 → mono emit -1 → XP003 entry-module fail (typeck already green after
     * wave686). Mirrors TYPE_PTR (`_ptr`) / TYPE_VECTOR (`xN`) style.
     * PLATFORM: SHARED — G.7 single authority; seed twin must match.
     */
    if (tk == (TypeKind.TYPE_ARRAY as i32)) {
      let elem_ref: i32 = pipeline_type_elem_ref_at(arena, type_ref);
      let asz: i32 = pipeline_type_array_size_at(arena, type_ref);
      let n: i32 = codegen_type_ref_to_suffix(arena, elem_ref, buf, buf_cap);
      if (n <= 0 || asz <= 0) {
        return 0;
      }
      /* `_a` then decimal size (up to 6 digits). */
      if (n + 2 >= buf_cap) {
        return 0;
      }
      buf[n] = 95;
      buf[n + 1] = 97;
      n = n + 2;
      let digs: u8[8] = [];
      let nd: i32 = 0;
      let v: i32 = asz;
      while (v > 0 && nd < 6) {
        digs[nd] = ((v % 10) + 48) as u8;
        nd = nd + 1;
        v = v / 10;
      }
      if (nd <= 0) {
        return 0;
      }
      if (n + nd >= buf_cap) {
        return 0;
      }
      let di: i32 = nd - 1;
      while (di >= 0) {
        buf[n] = digs[di];
        n = n + 1;
        di = di - 1;
      }
      return n;
    }
    /*
     * wave687 Cap residual: TYPE_SLICE → `<elem>_slc` (e.g. i32_slc for []i32).
     * Same mono-mangle authority gap as TYPE_ARRAY; formals `[]T` use call-arg
     * `[]i32` as combo keys. PLATFORM: SHARED — seed twin must match.
     */
    if (tk == (TypeKind.TYPE_SLICE as i32)) {
      let elem_ref: i32 = pipeline_type_elem_ref_at(arena, type_ref);
      let n: i32 = codegen_type_ref_to_suffix(arena, elem_ref, buf, buf_cap);
      if (n > 0 && n + 4 < buf_cap) {
        buf[n] = 95;
        buf[n + 1] = 115;
        buf[n + 2] = 108;
        buf[n + 3] = 99;
        return n + 4;
      }
      return 0;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_module_func_overload_count(module: *Module, name_ptr: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let c: i32 = 0;
    if (module == 0 as *Module || name_ptr == 0 as *u8 || name_len <= 0) {
      return 0;
    }
    let i: i32 = 0;
    while (i < module.num_funcs) {
      let fn_len: i32 = pipeline_module_func_name_len_at(module, i);
      if (fn_len == name_len && fn_len > 0) {
        let fn_name: u8[256] = [];
        let matched: i32 = 1;
        let bi: i32 = 0;
        pipeline_module_func_name_copy64(module, i, &fn_name[0]);
        while (bi < fn_len) {
          if (fn_name[bi] != name_ptr[bi]) {
            matched = 0;
            bi = fn_len;
          } else {
            bi = bi + 1;
          }
        }
        if (matched != 0) {
          c = c + 1;
        }
      }
      i = i + 1;
    }
    return c;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_func_param_sig_equal(arena: *ASTArena, mod_a: *Module, fi_a: i32, mod_b: *Module, fi_b: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let np_a: i32 = pipeline_module_func_num_params_at(mod_a, fi_a);
    let np_b: i32 = pipeline_module_func_num_params_at(mod_b, fi_b);
    if (np_a != np_b) {
      return 0;
    }
    let pi: i32 = 0;
    while (pi < np_a) {
      let sa: u8[256] = [];
      let sb: u8[256] = [];
      let na: i32 = codegen_type_ref_to_suffix(arena, pipeline_module_func_param_type_ref_at(mod_a, fi_a, pi), &sa[0], 64);
      let nb: i32 = codegen_type_ref_to_suffix(arena, pipeline_module_func_param_type_ref_at(mod_b, fi_b, pi), &sb[0], 64);
      if (na != nb) {
        return 0;
      }
      let k: i32 = 0;
      while (k < na) {
        if (sa[k] != sb[k]) {
          return 0;
        }
        k = k + 1;
      }
      pi = pi + 1;
    }
    return 1;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_module_overload_param_sig_count(arena: *ASTArena, module: *Module, fi: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let c: i32 = 0;
    if (module == 0 as *Module || fi < 0 || fi >= module.num_funcs) {
      return 0;
    }
    let fn_local: u8[256] = [];
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
    if (fn_len <= 0) {
      return 0;
    }
    let i: i32 = 0;
    while (i < module.num_funcs) {
      let g_len: i32 = pipeline_module_func_name_len_at(module, i);
      if (g_len == fn_len && g_len > 0) {
        let g_name: u8[256] = [];
        let matched: i32 = 1;
        let bi: i32 = 0;
        pipeline_module_func_name_copy64(module, i, &g_name[0]);
        while (bi < g_len) {
          if (g_name[bi] != fn_local[bi]) {
            matched = 0;
            bi = g_len;
          } else {
            bi = bi + 1;
          }
        }
        if (matched != 0) {
          if (codegen_func_param_sig_equal(arena, module, fi, module, i) != 0) {
            c = c + 1;
          }
        }
      }
      i = i + 1;
    }
    return c;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function codegen_func_c_symbol_prefix_len(module: *Module, fi: i32, prefix_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (prefix_len <= 0) {
      return 0;
    }
    if (module != 0 as *Module && fi >= 0 && pipeline_module_func_is_no_mangle_at(module, fi) != 0) {
      return 0;
    }
    return prefix_len;
  }
}


// Bodies are in codegen_late.x. File-private extern: the late TU
// defines them and does not import this module.
// PLATFORM: SHARED.
extern function codegen_emit_func_link_name(out: *CodegenOutBuf, arena: *ASTArena, module: *Module, fi: i32): i32;
extern function codegen_name_is_local_binding(arena: *ASTArena, ctx: *PipelineDepCtx, name: *u8, name_len: i32): i32;
extern function codegen_try_emit_fn_as_value(out: *CodegenOutBuf, arena: *ASTArena, ctx: *PipelineDepCtx, name: *u8, name_len: i32): i32;
extern function codegen_arena_for_module(ctx: *PipelineDepCtx, module: *Module, fallback: *ASTArena): *ASTArena;
extern function codegen_emit_call_func_name(out: *CodegenOutBuf, arena: *ASTArena, ctx: *PipelineDepCtx, expr_ref: i32, current_module: *Module, fallback_name: *u8, fallback_len: i32): i32;
extern function codegen_copy_func_name64_from_module(module: *Module, fi: i32, dst: *u8): void;
extern function codegen_block_contains_return(arena: *ASTArena, block_ref: i32): i32;
extern function emit_func(arena: *ASTArena, out: *CodegenOutBuf, module: *Module, fi: i32, is_entry: bool, prefix: *u8, prefix_len: i32, ctx: *PipelineDepCtx, call_init_globals: i32): i32;
extern function codegen_mono_subst_type(ctx: *PipelineDepCtx, arena: *ASTArena, type_ref: i32): i32;
extern function codegen_find_impl_method_for_type(module: *Module, arena: *ASTArena, method_name: *u8, method_name_len: i32, receiver_type_ref: i32): i32;
extern function codegen_builtin_type_name_into(kind_ord: i32, out: *u8): i32;
extern function codegen_emit_vtable_wrapper_def(out: *CodegenOutBuf, arena: *ASTArena, cur_mod: *Module, ctx: *PipelineDepCtx, trait_nm: *u8, trait_nlen: i32, for_nm: *u8, for_nlen: i32, for_ptr: i32, slot_i: i32, recv_rt: i32): i32;
extern function codegen_emit_dyn_vtable_close(arena: *ASTArena, out: *CodegenOutBuf, ctx: *PipelineDepCtx, lt_dyn: i32, rhs_rt: i32): i32;
extern function codegen_try_emit_generic_identity_mono(arena: *ASTArena, out: *CodegenOutBuf, module: *Module, fi: i32, prefix: *u8, prefix_len: i32, ctx: *PipelineDepCtx): i32;
extern function codegen_try_emit_generic_impl_method_mono(arena: *ASTArena, out: *CodegenOutBuf, module: *Module, fi: i32, prefix: *u8, prefix_len: i32, ctx: *PipelineDepCtx): i32;
extern function emit_func_extern_declaration(arena: *ASTArena, out: *CodegenOutBuf, module: *Module, fi: i32, prefix: *u8, prefix_len: i32, ctx: *PipelineDepCtx): i32;
extern function codegen_emit_raw_syscall_helpers(out: *CodegenOutBuf): i32;
extern function codegen_x_ast(module: *Module, arena: *ASTArena, out: *CodegenOutBuf, ctx: *PipelineDepCtx, dep_index: i32): i32;
extern function codegen_is_submit_batch_buf_call(name: *u8, name_len: i32): i32;
