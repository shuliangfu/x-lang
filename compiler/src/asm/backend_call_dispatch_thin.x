// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-364/381：backend_call_dispatch L2 thin — pure 门闩（weak）。
// PREFER_X_O：thin.o + seed-rest（-DSHUX_L2_CALL_DISPATCH_THIN_FROM_X）ld -r
//   → backend_call_dispatch.o
//

export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_var_name_len_for_string_lit_c(arena: *u8, er: i32): i32;

#[no_mangle]
export function glue_asm_call_reg_max(ta: i32): i32 {
  if (ta == 0) {
    return 6;
  }
  return 8;
}

#[no_mangle]
export function glue_asm_call_stack_cleanup_bytes(ta: i32, nargs: i32): i32 {
  if (nargs <= 0) {
    return 0;
  }
  if (ta == 0) {
    if (nargs <= 6) {
      return 0;
    }
    if (((nargs - 6) & 1) != 0) {
      return (nargs - 6) * 8 + 8;
    }
    return (nargs - 6) * 8;
  }
  if (ta == 2) {
    return 0 - 1;
  }
  if (nargs <= 8) {
    return 0;
  }
  return (((nargs - 8) * 8 + 15) & (0 - 16));
}

#[no_mangle]
export function glue_asm_append_export_c_suffix(sym: *u8, sym_len: i32, cap: i32): i32 {
  if (sym == 0 as *u8) {
    return sym_len;
  }
  if (sym_len <= 0) {
    return sym_len;
  }
  if (sym_len + 2 >= cap) {
    return sym_len;
  }
  unsafe {
    sym[sym_len] = 95;
    sym[sym_len + 1] = 99;
  }
  return sym_len + 2;
}

// GLUE_EXPR_STRING_LIT_ORD = 59
#[no_mangle]
export function glue_asm_string_lit_len(arena: *u8, expr_ref: i32): i32 {
  if (arena == 0 as *u8) {
    return 0;
  }
  if (expr_ref <= 0) {
    return 0;
  }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, expr_ref) != 59) {
      return 0;
    }
    return pipeline_expr_var_name_len_for_string_lit_c(arena, expr_ref);
  }
  return 0;
}

// ---- G-02f-366：f32 type / param type_ref / path segment count ----
export extern "C" function pipeline_asm_call_param_type_ref_at_c(arena: *u8, call_expr_ref: i32, param_index: i32): i32;


#[no_mangle]
export function glue_call_param_type_ref_at(arena: *u8, call_expr_ref: i32, param_index: i32): i32 {
  unsafe {
    return pipeline_asm_call_param_type_ref_at_c(arena, call_expr_ref, param_index);
  }
  return 0;
}

// ---- G-02f-367：f32 判定 + build_ 前缀冗余 ----
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, ty: i32): i32;

/** True if type is scalar f32 (14) or f64 (15) for SysV xmm0–7 arg/param slotting.
 * Name keeps historical is_f32; f64 shares the SSE float register class (G.7 complete).
 * PLATFORM: SHARED classification / LINUX+MACOS x86_64 SysV xmm use. */
#[no_mangle]
export function glue_call_param_is_f32_c(arena: *u8, type_ref: i32): i32 {
  if (arena == 0 as *u8) {
    return 0;
  }
  if (type_ref <= 0) {
    return 0;
  }
  unsafe {
    let k: i32 = pipeline_type_kind_ord_at(arena, type_ref);
    // TYPE_F32=14, TYPE_F64=15 (ast TypeKind with LINEAR present).
    if (k == 14) {
      return 1;
    }
    if (k == 15) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
export function glue_asm_c_prefix_redundant_with_name(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32 {
  if (prefix == 0 as *u8) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (prefix_len != 6) {
    return 0;
  }
  if (name_len < 6) {
    return 0;
  }
  unsafe {
    if (prefix[0] != 98) {
      return 0;
    }
    if (prefix[1] != 117) {
      return 0;
    }
    if (prefix[2] != 105) {
      return 0;
    }
    if (prefix[3] != 108) {
      return 0;
    }
    if (prefix[4] != 100) {
      return 0;
    }
    if (prefix[5] != 95) {
      return 0;
    }
    if (name[0] != 98) {
      return 0;
    }
    if (name[1] != 117) {
      return 0;
    }
    if (name[2] != 105) {
      return 0;
    }
    if (name[3] != 108) {
      return 0;
    }
    if (name[4] != 100) {
      return 0;
    }
    if (name[5] != 95) {
      return 0;
    }
    return 1;
  }
  return 0;
}

// ---- G-02f-368：path 段数 forward 到 seed impl ----
export extern "C" function glue_asm_import_path_segment_count_impl(path: *u8, path_len: i32): i32;

#[no_mangle]
export function glue_asm_import_path_segment_count(path: *u8, path_len: i32): i32 {
  unsafe {
    return glue_asm_import_path_segment_count_impl(path, path_len);
  }
  return 0;
}

// ---- G-02f-369：import 比较 + f32 flag get → seed impl ----
export extern "C" function glue_asm_import_path_slice_equal_impl(module: *u8, imp_ix: i32, off: i32, seg_len: i32, nm: *u8, nm_len: i32): i32;
export extern "C" function glue_asm_import_binding_name_equal_impl(module: *u8, imp_ix: i32, nm: *u8, nm_len: i32): i32;
export extern "C" function glue_f32_xmm_flag_get_body_impl(): i32;

#[no_mangle]
export function glue_asm_import_path_slice_equal(module: *u8, imp_ix: i32, off: i32, seg_len: i32, nm: *u8, nm_len: i32): i32 {
  unsafe {
    return glue_asm_import_path_slice_equal_impl(module, imp_ix, off, seg_len, nm, nm_len);
  }
  return 0;
}

#[no_mangle]
export function glue_asm_import_binding_name_equal(module: *u8, imp_ix: i32, nm: *u8, nm_len: i32): i32 {
  unsafe {
    return glue_asm_import_binding_name_equal_impl(module, imp_ix, nm, nm_len);
  }
  return 0;
}

#[no_mangle]
export function pipeline_asm_emit_get_call_f32_xmm_c(): i32 {
  unsafe {
    return glue_f32_xmm_flag_get_body_impl();
  }
  return 0;
}

// ---- G-02f-370：overload / fill_c_prefix / std_c_wrapper / prefix_is_fmt → seed impl ----
export extern "C" function glue_module_func_overload_count_c_impl(m: *u8, name: *u8, name_len: i32): i32;
export extern "C" function glue_asm_fill_c_prefix_from_module_import_impl(cur_mod: *u8, imp_ix: i32, pre_buf: *u8): i32;
export extern "C" function glue_asm_std_c_wrapper_fname_needs_export_c_suffix_impl(fname: *u8, fname_len: i32): i32;
export extern "C" function glue_asm_prefix_is_fmt_or_debug_impl(pre: *u8, pre_len: i32): i32;

#[no_mangle]
export function glue_module_func_overload_count_c(m: *u8, name: *u8, name_len: i32): i32 {
  unsafe {
    return glue_module_func_overload_count_c_impl(m, name, name_len);
  }
  return 0;
}

#[no_mangle]
export function glue_asm_fill_c_prefix_from_module_import(cur_mod: *u8, imp_ix: i32, pre_buf: *u8): i32 {
  unsafe {
    return glue_asm_fill_c_prefix_from_module_import_impl(cur_mod, imp_ix, pre_buf);
  }
  return 0 - 1;
}

#[no_mangle]
export function glue_asm_std_c_wrapper_fname_needs_export_c_suffix(fname: *u8, fname_len: i32): i32 {
  unsafe {
    return glue_asm_std_c_wrapper_fname_needs_export_c_suffix_impl(fname, fname_len);
  }
  return 0;
}

#[no_mangle]
export function glue_asm_prefix_is_fmt_or_debug(pre: *u8, pre_len: i32): i32 {
  unsafe {
    return glue_asm_prefix_is_fmt_or_debug_impl(pre, pre_len);
  }
  return 0;
}

// ---- G-02f-371：import_segment_at / binding_call_sym / std_string_shux redirect → seed impl ----
export extern "C" function glue_asm_import_segment_at_impl(module: *u8, imp_ix: i32, want_seg: i32, ostr: *i32, olen: *i32): i32;
export extern "C" function glue_asm_build_import_binding_call_sym_impl(pre: *u8, pre_len: i32, field_name: *u8, field_len: i32, out_name: *u8): i32;
export extern "C" function glue_try_std_string_shux_redirect_sym_local_impl(name: *u8, name_len: i32, sym_out: *u8, out_cap: i32): i32;

#[no_mangle]
export function glue_asm_import_segment_at(module: *u8, imp_ix: i32, want_seg: i32, ostr: *i32, olen: *i32): i32 {
  unsafe {
    return glue_asm_import_segment_at_impl(module, imp_ix, want_seg, ostr, olen);
  }
  return 0;
}

#[no_mangle]
export function glue_asm_build_import_binding_call_sym(pre: *u8, pre_len: i32, field_name: *u8, field_len: i32, out_name: *u8): i32 {
  unsafe {
    return glue_asm_build_import_binding_call_sym_impl(pre, pre_len, field_name, field_len, out_name);
  }
  return 0 - 1;
}

#[no_mangle]
export function glue_try_std_string_shux_redirect_sym_local(name: *u8, name_len: i32, sym_out: *u8, out_cap: i32): i32 {
  unsafe {
    return glue_try_std_string_shux_redirect_sym_local_impl(name, name_len, sym_out, out_cap);
  }
  return 0;
}

// ---- G-02f-372：encoding redirect / type_kind_suffix / string_lit_ptr_rax → seed impl ----
export extern "C" function glue_try_std_encoding_redirect_sym_local_impl(name: *u8, name_len: i32, sym_out: *u8, out_cap: i32): i32;
export extern "C" function glue_type_kind_to_suffix_c_impl(kind_ord: i32, out: *u8, out_cap: i32): i32;
export extern "C" function glue_asm_emit_string_lit_ptr_rax_elf_c_impl(arena: *u8, elf_ctx: *u8, str_expr_ref: i32, ta: i32): i32;

#[no_mangle]
export function glue_try_std_encoding_redirect_sym_local(name: *u8, name_len: i32, sym_out: *u8, out_cap: i32): i32 {
  unsafe {
    return glue_try_std_encoding_redirect_sym_local_impl(name, name_len, sym_out, out_cap);
  }
  return 0;
}

#[no_mangle]
export function glue_type_kind_to_suffix_c(kind_ord: i32, out: *u8, out_cap: i32): i32 {
  unsafe {
    return glue_type_kind_to_suffix_c_impl(kind_ord, out, out_cap);
  }
  return 0;
}

#[no_mangle]
export function glue_asm_emit_string_lit_ptr_rax_elf_c(arena: *u8, elf_ctx: *u8, str_expr_ref: i32, ta: i32): i32 {
  unsafe {
    return glue_asm_emit_string_lit_ptr_rax_elf_c_impl(arena, elf_ctx, str_expr_ref, ta);
  }
  return 0 - 1;
}

// ---- G-02f-373：sysv n_stack / dep_export_sym / enc_call_redirected → seed impl ----
export extern "C" function glue_sysv_x86_call_n_stack_c_impl(arena: *u8, call_expr_ref: i32, nargs: i32): i32;
export extern "C" function glue_asm_build_dep_export_sym_c_impl(name: *u8, name_len: i32, out: *u8, out_cap: i32): i32;
export extern "C" function glue_asm_enc_call_redirected_impl(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;

#[no_mangle]
export function glue_sysv_x86_call_n_stack_c(arena: *u8, call_expr_ref: i32, nargs: i32): i32 {
  unsafe {
    return glue_sysv_x86_call_n_stack_c_impl(arena, call_expr_ref, nargs);
  }
  return 0;
}

#[no_mangle]
export function glue_asm_build_dep_export_sym_c(name: *u8, name_len: i32, out: *u8, out_cap: i32): i32 {
  unsafe {
    return glue_asm_build_dep_export_sym_c_impl(name, name_len, out, out_cap);
  }
  return 0 - 1;
}

#[no_mangle]
export function glue_asm_enc_call_redirected(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  unsafe {
    return glue_asm_enc_call_redirected_impl(elf_ctx, name, name_len, ta);
  }
  return 0 - 1;
}

// ---- G-02f-374：heap redirect / f32 xmm env / build_func_export_sym → seed impl ----
export extern "C" function glue_try_std_heap_redirect_sym_local_impl(name: *u8, name_len: i32, sym_out: *u8, out_cap: i32): i32;
export extern "C" function pipeline_asm_abi_f32_xmm_enabled_c_impl(): i32;
export extern "C" function glue_asm_build_func_export_sym_c_impl(m: *u8, a: *u8, func_ix: i32, out: *u8, out_cap: i32): i32;

#[no_mangle]
export function glue_try_std_heap_redirect_sym_local(name: *u8, name_len: i32, sym_out: *u8, out_cap: i32): i32 {
  unsafe {
    return glue_try_std_heap_redirect_sym_local_impl(name, name_len, sym_out, out_cap);
  }
  return 0;
}

#[no_mangle]
export function pipeline_asm_abi_f32_xmm_enabled_c(): i32 {
  unsafe {
    return pipeline_asm_abi_f32_xmm_enabled_c_impl();
  }
  return 1;
}

#[no_mangle]
export function glue_asm_build_func_export_sym_c(m: *u8, a: *u8, func_ix: i32, out: *u8, out_cap: i32): i32 {
  unsafe {
    return glue_asm_build_func_export_sym_c_impl(m, a, func_ix, out, out_cap);
  }
  return 0 - 1;
}

// ---- G-02f-375：jmp_skip_string_lea / spill_struct16 / resolve_whole_import → seed impl ----
export extern "C" function glue_asm_emit_jmp_skip_string_then_lea_impl(ctx_bytes: *u8, ta: i32, reg_k: i32, sbuf: *u8, slen: i32): i32;
export extern "C" function glue_spill_struct16_call_arg_to_lea_elf_c_impl(arena: *u8, elf_ctx: *u8, ctx: *u8, pty: i32, ta: i32): i32;
export extern "C" function pipeline_asm_resolve_whole_import_qualified_symbol_c_impl(arena: *u8, cur_mod: *u8, callee_expr_ref: i32, sym_flat: *u8, out_match_imp_j: *i32): i32;

#[no_mangle]
export function glue_asm_emit_jmp_skip_string_then_lea(ctx_bytes: *u8, ta: i32, reg_k: i32, sbuf: *u8, slen: i32): i32 {
  unsafe {
    return glue_asm_emit_jmp_skip_string_then_lea_impl(ctx_bytes, ta, reg_k, sbuf, slen);
  }
  return 0 - 1;
}

#[no_mangle]
export function glue_spill_struct16_call_arg_to_lea_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, pty: i32, ta: i32): i32 {
  unsafe {
    return glue_spill_struct16_call_arg_to_lea_elf_c_impl(arena, elf_ctx, ctx, pty, ta);
  }
  return 0;
}

#[no_mangle]
export function pipeline_asm_resolve_whole_import_qualified_symbol_c(arena: *u8, cur_mod: *u8, callee_expr_ref: i32, sym_flat: *u8, out_match_imp_j: *i32): i32 {
  unsafe {
    return pipeline_asm_resolve_whole_import_qualified_symbol_c_impl(arena, cur_mod, callee_expr_ref, sym_flat, out_match_imp_j);
  }
  return 0 - 1;
}

// ---- G-02f-376：emit_call_elf / emit_method_call / emit_call_args_text → seed impl ----
export extern "C" function pipeline_asm_emit_call_elf_c_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern "C" function pipeline_asm_emit_method_call_elf_c_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern "C" function pipeline_asm_emit_call_args_text_c_impl(arena: *u8, out: *u8, expr_ref: i32, ctx: *u8, target_arch: i32, nargs: i32): i32;

#[no_mangle]
export function pipeline_asm_emit_call_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return pipeline_asm_emit_call_elf_c_impl(arena, elf_ctx, expr_ref, ctx, ta);
  }
  return 0 - 1;
}

#[no_mangle]
export function pipeline_asm_emit_method_call_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return pipeline_asm_emit_method_call_elf_c_impl(arena, elf_ctx, expr_ref, ctx, ta);
  }
  return 0 - 1;
}

#[no_mangle]
export function pipeline_asm_emit_call_args_text_c(arena: *u8, out: *u8, expr_ref: i32, ctx: *u8, target_arch: i32, nargs: i32): i32 {
  unsafe {
    return pipeline_asm_emit_call_args_text_c_impl(arena, out, expr_ref, ctx, target_arch, nargs);
  }
  return 0 - 1;
}

// ---- G-02f-377：call_args_elf / sysv_f32_xmm_args / emit_call_with_cleanup → seed impl ----
export extern "C" function pipeline_asm_emit_call_args_elf_c_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, nargs: i32): i32;
export extern "C" function glue_emit_call_args_elf_sysv_f32_xmm_c_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, nargs: i32): i32;
export extern "C" function glue_asm_emit_call_with_cleanup_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, nargs: i32, cname: *u8, clen: i32): i32;

#[no_mangle]
export function pipeline_asm_emit_call_args_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, nargs: i32): i32 {
  unsafe {
    return pipeline_asm_emit_call_args_elf_c_impl(arena, elf_ctx, expr_ref, ctx, ta, nargs);
  }
  return 0 - 1;
}

#[no_mangle]
export function glue_emit_call_args_elf_sysv_f32_xmm_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, nargs: i32): i32 {
  unsafe {
    return glue_emit_call_args_elf_sysv_f32_xmm_c_impl(arena, elf_ctx, expr_ref, ctx, ta, nargs);
  }
  return 0 - 1;
}

#[no_mangle]
export function glue_asm_emit_call_with_cleanup(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, nargs: i32, cname: *u8, clen: i32): i32 {
  unsafe {
    return glue_asm_emit_call_with_cleanup_impl(arena, elf_ctx, expr_ref, ctx, ta, nargs, cname, clen);
  }
  return 0 - 1;
}

// ---- G-02f-378：emit_one_call_arg / build_call_export_sym / fmt_string_lit_import_call → seed impl ----
export extern "C" function glue_emit_one_call_arg_elf_c_impl(arena: *u8, elf_ctx: *u8, call_expr_ref: i32, arg_ref: i32, arg_index: i32, ctx: *u8, ta: i32): i32;
export extern "C" function glue_asm_build_call_export_sym_c_impl(arena: *u8, call_expr_ref: i32, callee_ref: i32, mod: *u8, dep_pipe: *u8, out: *u8, out_cap: i32): i32;
export extern "C" function glue_asm_try_emit_fmt_string_lit_import_call_elf_c_impl(arena: *u8, elf_ctx: *u8, call_expr_ref: i32, ctx: *u8, ta: i32, pre_buf: *u8, pre_len: i32, field_name: *u8, field_len: i32): i32;

#[no_mangle]
export function glue_emit_one_call_arg_elf_c(arena: *u8, elf_ctx: *u8, call_expr_ref: i32, arg_ref: i32, arg_index: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return glue_emit_one_call_arg_elf_c_impl(arena, elf_ctx, call_expr_ref, arg_ref, arg_index, ctx, ta);
  }
  return 0 - 1;
}

#[no_mangle]
export function glue_asm_build_call_export_sym_c(arena: *u8, call_expr_ref: i32, callee_ref: i32, mod: *u8, dep_pipe: *u8, out: *u8, out_cap: i32): i32 {
  unsafe {
    return glue_asm_build_call_export_sym_c_impl(arena, call_expr_ref, callee_ref, mod, dep_pipe, out, out_cap);
  }
  return 0 - 1;
}

#[no_mangle]
export function glue_asm_try_emit_fmt_string_lit_import_call_elf_c(arena: *u8, elf_ctx: *u8, call_expr_ref: i32, ctx: *u8, ta: i32, pre_buf: *u8, pre_len: i32, field_name: *u8, field_len: i32): i32 {
  unsafe {
    return glue_asm_try_emit_fmt_string_lit_import_call_elf_c_impl(arena, elf_ctx, call_expr_ref, ctx, ta, pre_buf, pre_len, field_name, field_len);
  }
  return 0 - 1;
}

// ---- G-02f-380：void 公开符号 → thin i32 壳 + seed int32 _impl（-E 可 emit）----
export extern "C" function pipeline_asm_emit_set_call_f32_xmm_impl(on: i32): i32;
export extern "C" function glue_codegen_import_path_to_c_prefix_into_impl(path: *u8, buf: *u8, buf_cap: i32): i32;
export extern "C" function glue_asm_string_lit_into_impl(arena: *u8, expr_ref: i32, out64: *u8): i32;
export extern "C" function glue_sysv_x86_call_arg_slot_c_impl(arena: *u8, call_expr_ref: i32, nargs: i32, arg_index: i32, out_kind: *i32, out_reg_k: *i32, out_stack_k: *i32): i32;

#[no_mangle]
export function pipeline_asm_emit_set_call_f32_xmm(on: i32): i32 {
  unsafe {
    return pipeline_asm_emit_set_call_f32_xmm_impl(on);
  }
  return 0;
}

#[no_mangle]
export function glue_codegen_import_path_to_c_prefix_into(path: *u8, buf: *u8, buf_cap: i32): i32 {
  unsafe {
    return glue_codegen_import_path_to_c_prefix_into_impl(path, buf, buf_cap);
  }
  return 0;
}

#[no_mangle]
export function glue_asm_string_lit_into(arena: *u8, expr_ref: i32, out64: *u8): i32 {
  unsafe {
    return glue_asm_string_lit_into_impl(arena, expr_ref, out64);
  }
  return 0;
}

#[no_mangle]
export function glue_sysv_x86_call_arg_slot_c(arena: *u8, call_expr_ref: i32, nargs: i32, arg_index: i32, out_kind: *i32, out_reg_k: *i32, out_stack_k: *i32): i32 {
  unsafe {
    return glue_sysv_x86_call_arg_slot_c_impl(arena, call_expr_ref, nargs, arg_index, out_kind, out_reg_k, out_stack_k);
  }
  return 0;
}

// ---- G-02f-381：f32 flag get_body public thin shell ----
#[no_mangle]
export function glue_f32_xmm_flag_get_body(): i32 {
  unsafe {
    return glue_f32_xmm_flag_get_body_impl();
  }
  return 0;
}
