/* seeds/backend_call_dispatch_thin.from_x.c
 * G-02f backend_call_dispatch L2 thin surface — isomorphic with src/asm/backend_call_dispatch_thin.x
 * Product PREFER_X_O: g05_try_x_to_o(thin.x) + full seed rest (-DXLANG_L2_CALL_DISPATCH_THIN_FROM_X) ld -r
 * Cold full seed: seeds/backend_call_dispatch.from_x.c (unchanged)
 * Prove: thin.x vs this seed → nm IDENTICAL (public surface; heavy CALL C tail are U)
 * Regen: ./xlang -E ... src/asm/backend_call_dispatch_thin.x | filter DBG + polish externs
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW
 *            (read/write/close/lseek/open/pread/pwrite/setenv/unsetenv).
 *            include/poll.h and include/sys/uio.h shims also available.
 *            macOS/Linux delegate to system headers via #include_next.
 *            Historical #ifndef _WIN32 guard removed for safe includes. */
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
extern int32_t glue_asm_call_reg_max(int32_t ta);
extern int32_t glue_asm_call_stack_cleanup_bytes(int32_t ta, int32_t nargs);
extern int32_t glue_asm_append_export_c_suffix(uint8_t * sym, int32_t sym_len, int32_t cap);
extern int32_t glue_asm_string_lit_len(uint8_t * arena, int32_t expr_ref);
extern int32_t glue_call_param_type_ref_at(uint8_t * arena, int32_t call_expr_ref, int32_t param_index);
extern int32_t glue_call_param_is_f32_c(uint8_t * arena, int32_t type_ref);
extern int32_t glue_asm_c_prefix_redundant_with_name(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len);
extern int32_t glue_asm_import_path_segment_count(uint8_t * path, int32_t path_len);
extern int32_t glue_asm_import_path_slice_equal(uint8_t * module, int32_t imp_ix, int32_t off, int32_t seg_len, uint8_t * nm, int32_t nm_len);
extern int32_t glue_asm_import_binding_name_equal(uint8_t * module, int32_t imp_ix, uint8_t * nm, int32_t nm_len);
extern int32_t pipeline_asm_emit_get_call_f32_xmm_c(void);
extern int32_t glue_module_func_overload_count_c(uint8_t * m, uint8_t * name, int32_t name_len);
extern int32_t glue_asm_fill_c_prefix_from_module_import(uint8_t * cur_mod, int32_t imp_ix, uint8_t * pre_buf);
extern int32_t glue_asm_std_c_wrapper_fname_needs_export_c_suffix(uint8_t * fname, int32_t fname_len);
extern int32_t glue_asm_prefix_is_fmt_or_debug(uint8_t * pre, int32_t pre_len);
extern int32_t glue_asm_import_segment_at(uint8_t * module, int32_t imp_ix, int32_t want_seg, int32_t * ostr, int32_t * olen);
extern int32_t glue_asm_build_import_binding_call_sym(uint8_t * pre, int32_t pre_len, uint8_t * field_name, int32_t field_len, uint8_t * out_name);
extern int32_t glue_try_std_string_xlang_redirect_sym_local(uint8_t * name, int32_t name_len, uint8_t * sym_out, int32_t out_cap);
extern int32_t glue_try_std_encoding_redirect_sym_local(uint8_t * name, int32_t name_len, uint8_t * sym_out, int32_t out_cap);
extern int32_t glue_type_kind_to_suffix_c(int32_t kind_ord, uint8_t * out, int32_t out_cap);
extern int32_t glue_asm_emit_string_lit_ptr_rax_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t str_expr_ref, int32_t ta);
extern int32_t glue_sysv_x86_call_n_stack_c(uint8_t * arena, int32_t call_expr_ref, int32_t nargs);
extern int32_t glue_asm_build_dep_export_sym_c(uint8_t * name, int32_t name_len, uint8_t * out, int32_t out_cap);
extern int32_t glue_asm_enc_call_redirected(uint8_t * elf_ctx, uint8_t * name, int32_t name_len, int32_t ta);
extern int32_t glue_try_std_heap_redirect_sym_local(uint8_t * name, int32_t name_len, uint8_t * sym_out, int32_t out_cap);
extern int32_t pipeline_asm_abi_f32_xmm_enabled_c(void);
extern int32_t glue_asm_build_func_export_sym_c(uint8_t * m, uint8_t * a, int32_t func_ix, uint8_t * out, int32_t out_cap);
extern int32_t glue_asm_emit_jmp_skip_string_then_lea(uint8_t * ctx_bytes, int32_t ta, int32_t reg_k, uint8_t * sbuf, int32_t slen);
extern int32_t glue_spill_struct16_call_arg_to_lea_elf_c(uint8_t * arena, uint8_t * elf_ctx, uint8_t * ctx, int32_t pty, int32_t ta);
extern int32_t pipeline_asm_resolve_whole_import_qualified_symbol_c(uint8_t * arena, uint8_t * cur_mod, int32_t callee_expr_ref, uint8_t * sym_flat, int32_t * out_match_imp_j);
extern int32_t pipeline_asm_emit_call_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta);
extern int32_t pipeline_asm_emit_method_call_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta);
extern int32_t pipeline_asm_emit_call_args_text_c(uint8_t * arena, uint8_t * out, int32_t expr_ref, uint8_t * ctx, int32_t target_arch, int32_t nargs);
extern int32_t pipeline_asm_emit_call_args_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta, int32_t nargs);
extern int32_t glue_emit_call_args_elf_sysv_f32_xmm_c(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta, int32_t nargs);
extern int32_t glue_asm_emit_call_with_cleanup(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta, int32_t nargs, uint8_t * cname, int32_t clen);
extern int32_t glue_emit_one_call_arg_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t call_expr_ref, int32_t arg_ref, int32_t arg_index, uint8_t * ctx, int32_t ta);
extern int32_t glue_asm_build_call_export_sym_c(uint8_t * arena, int32_t call_expr_ref, int32_t callee_ref, uint8_t * mod, uint8_t * dep_pipe, uint8_t * out, int32_t out_cap);
extern int32_t glue_asm_try_emit_fmt_string_lit_import_call_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t call_expr_ref, uint8_t * ctx, int32_t ta, uint8_t * pre_buf, int32_t pre_len, uint8_t * field_name, int32_t field_len);
extern int32_t pipeline_asm_emit_set_call_f32_xmm(int32_t on);
extern int32_t glue_codegen_import_path_to_c_prefix_into(uint8_t * path, uint8_t * buf, int32_t buf_cap);
extern int32_t glue_asm_string_lit_into(uint8_t * arena, int32_t expr_ref, uint8_t * out64);
extern int32_t glue_sysv_x86_call_arg_slot_c(uint8_t * arena, int32_t call_expr_ref, int32_t nargs, int32_t arg_index, int32_t * out_kind, int32_t * out_reg_k, int32_t * out_stack_k);
extern int32_t glue_f32_xmm_flag_get_body(void);
extern int32_t pipeline_expr_kind_ord_at(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_var_name_len_for_string_lit_c(uint8_t * arena, int32_t er);
int32_t glue_asm_call_reg_max(int32_t ta) {
  if ((ta ==0)) {
    return 6;
  }
  return 8;
}
int32_t glue_asm_call_stack_cleanup_bytes(int32_t ta, int32_t nargs) {
  if ((nargs <=0)) {
    return 0;
  }
  if ((ta ==0)) {
    if ((nargs <=6)) {
      return 0;
    }
    if ((((nargs - 6) & 1) !=0)) {
      return (((nargs - 6) * 8) + 8);
    }
    return ((nargs - 6) * 8);
  }
  if ((ta ==2)) {
    return (0 - 1);
  }
  if ((nargs <=8)) {
    return 0;
  }
  return ((((nargs - 8) * 8) + 15) & (0 - 16));
}
int32_t glue_asm_append_export_c_suffix(uint8_t * sym, int32_t sym_len, int32_t cap) {
  if ((sym ==((uint8_t *)(0)))) {
    return sym_len;
  }
  if ((sym_len <=0)) {
    return sym_len;
  }
  if (((sym_len + 2) >=cap)) {
    return sym_len;
  }
  {
    (void)(((sym)[sym_len] = 95));
    (void)(((sym)[(sym_len + 1)] = 99));
  }
  return (sym_len + 2);
}
int32_t glue_asm_string_lit_len(uint8_t * arena, int32_t expr_ref) {
  if ((arena ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((expr_ref <=0)) {
    return 0;
  }
  {
    if ((pipeline_expr_kind_ord_at(arena, expr_ref) !=59)) {
      return 0;
    }
    return pipeline_expr_var_name_len_for_string_lit_c(arena, expr_ref);
  }
  return 0;
}
extern int32_t pipeline_asm_call_param_type_ref_at_c(uint8_t * arena, int32_t call_expr_ref, int32_t param_index);
int32_t glue_call_param_type_ref_at(uint8_t * arena, int32_t call_expr_ref, int32_t param_index) {
  {
    return pipeline_asm_call_param_type_ref_at_c(arena, call_expr_ref, param_index);
  }
  return 0;
}
extern int32_t pipeline_type_kind_ord_at(uint8_t * arena, int32_t ty);
int32_t glue_call_param_is_f32_c(uint8_t * arena, int32_t type_ref) {
  if ((arena ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((type_ref <=0)) {
    return 0;
  }
  {
    if ((pipeline_type_kind_ord_at(arena, type_ref) !=14)) {
      return 0;
    }
    return 1;
  }
  return 0;
}
int32_t glue_asm_c_prefix_redundant_with_name(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len) {
  if ((prefix ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((name ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((prefix_len !=6)) {
    return 0;
  }
  if ((name_len < 6)) {
    return 0;
  }
  {
    if (((prefix)[0] !=98)) {
      return 0;
    }
    if (((prefix)[1] !=117)) {
      return 0;
    }
    if (((prefix)[2] !=105)) {
      return 0;
    }
    if (((prefix)[3] !=108)) {
      return 0;
    }
    if (((prefix)[4] !=100)) {
      return 0;
    }
    if (((prefix)[5] !=95)) {
      return 0;
    }
    if (((name)[0] !=98)) {
      return 0;
    }
    if (((name)[1] !=117)) {
      return 0;
    }
    if (((name)[2] !=105)) {
      return 0;
    }
    if (((name)[3] !=108)) {
      return 0;
    }
    if (((name)[4] !=100)) {
      return 0;
    }
    if (((name)[5] !=95)) {
      return 0;
    }
    return 1;
  }
  return 0;
}
extern int32_t glue_asm_import_path_segment_count_impl(uint8_t * path, int32_t path_len);
int32_t glue_asm_import_path_segment_count(uint8_t * path, int32_t path_len) {
  {
    return glue_asm_import_path_segment_count_impl(path, path_len);
  }
  return 0;
}
extern int32_t glue_asm_import_path_slice_equal_impl(uint8_t * module, int32_t imp_ix, int32_t off, int32_t seg_len, uint8_t * nm, int32_t nm_len);
extern int32_t glue_asm_import_binding_name_equal_impl(uint8_t * module, int32_t imp_ix, uint8_t * nm, int32_t nm_len);
extern int32_t glue_f32_xmm_flag_get_body_impl(void);
int32_t glue_asm_import_path_slice_equal(uint8_t * module, int32_t imp_ix, int32_t off, int32_t seg_len, uint8_t * nm, int32_t nm_len) {
  {
    return glue_asm_import_path_slice_equal_impl(module, imp_ix, off, seg_len, nm, nm_len);
  }
  return 0;
}
int32_t glue_asm_import_binding_name_equal(uint8_t * module, int32_t imp_ix, uint8_t * nm, int32_t nm_len) {
  {
    return glue_asm_import_binding_name_equal_impl(module, imp_ix, nm, nm_len);
  }
  return 0;
}
int32_t pipeline_asm_emit_get_call_f32_xmm_c(void) {
  {
    return glue_f32_xmm_flag_get_body_impl();
  }
  return 0;
}
extern int32_t glue_module_func_overload_count_c_impl(uint8_t * m, uint8_t * name, int32_t name_len);
extern int32_t glue_asm_fill_c_prefix_from_module_import_impl(uint8_t * cur_mod, int32_t imp_ix, uint8_t * pre_buf);
extern int32_t glue_asm_std_c_wrapper_fname_needs_export_c_suffix_impl(uint8_t * fname, int32_t fname_len);
extern int32_t glue_asm_prefix_is_fmt_or_debug_impl(uint8_t * pre, int32_t pre_len);
int32_t glue_module_func_overload_count_c(uint8_t * m, uint8_t * name, int32_t name_len) {
  {
    return glue_module_func_overload_count_c_impl(m, name, name_len);
  }
  return 0;
}
int32_t glue_asm_fill_c_prefix_from_module_import(uint8_t * cur_mod, int32_t imp_ix, uint8_t * pre_buf) {
  {
    return glue_asm_fill_c_prefix_from_module_import_impl(cur_mod, imp_ix, pre_buf);
  }
  return (0 - 1);
}
int32_t glue_asm_std_c_wrapper_fname_needs_export_c_suffix(uint8_t * fname, int32_t fname_len) {
  {
    return glue_asm_std_c_wrapper_fname_needs_export_c_suffix_impl(fname, fname_len);
  }
  return 0;
}
int32_t glue_asm_prefix_is_fmt_or_debug(uint8_t * pre, int32_t pre_len) {
  {
    return glue_asm_prefix_is_fmt_or_debug_impl(pre, pre_len);
  }
  return 0;
}
extern int32_t glue_asm_import_segment_at_impl(uint8_t * module, int32_t imp_ix, int32_t want_seg, int32_t * ostr, int32_t * olen);
extern int32_t glue_asm_build_import_binding_call_sym_impl(uint8_t * pre, int32_t pre_len, uint8_t * field_name, int32_t field_len, uint8_t * out_name);
extern int32_t glue_try_std_string_xlang_redirect_sym_local_impl(uint8_t * name, int32_t name_len, uint8_t * sym_out, int32_t out_cap);
int32_t glue_asm_import_segment_at(uint8_t * module, int32_t imp_ix, int32_t want_seg, int32_t * ostr, int32_t * olen) {
  {
    return glue_asm_import_segment_at_impl(module, imp_ix, want_seg, ostr, olen);
  }
  return 0;
}
int32_t glue_asm_build_import_binding_call_sym(uint8_t * pre, int32_t pre_len, uint8_t * field_name, int32_t field_len, uint8_t * out_name) {
  {
    return glue_asm_build_import_binding_call_sym_impl(pre, pre_len, field_name, field_len, out_name);
  }
  return (0 - 1);
}
int32_t glue_try_std_string_xlang_redirect_sym_local(uint8_t * name, int32_t name_len, uint8_t * sym_out, int32_t out_cap) {
  {
    return glue_try_std_string_xlang_redirect_sym_local_impl(name, name_len, sym_out, out_cap);
  }
  return 0;
}
extern int32_t glue_try_std_encoding_redirect_sym_local_impl(uint8_t * name, int32_t name_len, uint8_t * sym_out, int32_t out_cap);
extern int32_t glue_type_kind_to_suffix_c_impl(int32_t kind_ord, uint8_t * out, int32_t out_cap);
extern int32_t glue_asm_emit_string_lit_ptr_rax_elf_c_impl(uint8_t * arena, uint8_t * elf_ctx, int32_t str_expr_ref, int32_t ta);
int32_t glue_try_std_encoding_redirect_sym_local(uint8_t * name, int32_t name_len, uint8_t * sym_out, int32_t out_cap) {
  {
    return glue_try_std_encoding_redirect_sym_local_impl(name, name_len, sym_out, out_cap);
  }
  return 0;
}
int32_t glue_type_kind_to_suffix_c(int32_t kind_ord, uint8_t * out, int32_t out_cap) {
  {
    return glue_type_kind_to_suffix_c_impl(kind_ord, out, out_cap);
  }
  return 0;
}
int32_t glue_asm_emit_string_lit_ptr_rax_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t str_expr_ref, int32_t ta) {
  {
    return glue_asm_emit_string_lit_ptr_rax_elf_c_impl(arena, elf_ctx, str_expr_ref, ta);
  }
  return (0 - 1);
}
extern int32_t glue_sysv_x86_call_n_stack_c_impl(uint8_t * arena, int32_t call_expr_ref, int32_t nargs);
extern int32_t glue_asm_build_dep_export_sym_c_impl(uint8_t * name, int32_t name_len, uint8_t * out, int32_t out_cap);
extern int32_t glue_asm_enc_call_redirected_impl(uint8_t * elf_ctx, uint8_t * name, int32_t name_len, int32_t ta);
int32_t glue_sysv_x86_call_n_stack_c(uint8_t * arena, int32_t call_expr_ref, int32_t nargs) {
  {
    return glue_sysv_x86_call_n_stack_c_impl(arena, call_expr_ref, nargs);
  }
  return 0;
}
int32_t glue_asm_build_dep_export_sym_c(uint8_t * name, int32_t name_len, uint8_t * out, int32_t out_cap) {
  {
    return glue_asm_build_dep_export_sym_c_impl(name, name_len, out, out_cap);
  }
  return (0 - 1);
}
int32_t glue_asm_enc_call_redirected(uint8_t * elf_ctx, uint8_t * name, int32_t name_len, int32_t ta) {
  {
    return glue_asm_enc_call_redirected_impl(elf_ctx, name, name_len, ta);
  }
  return (0 - 1);
}
extern int32_t glue_try_std_heap_redirect_sym_local_impl(uint8_t * name, int32_t name_len, uint8_t * sym_out, int32_t out_cap);
extern int32_t pipeline_asm_abi_f32_xmm_enabled_c_impl(void);
extern int32_t glue_asm_build_func_export_sym_c_impl(uint8_t * m, uint8_t * a, int32_t func_ix, uint8_t * out, int32_t out_cap);
int32_t glue_try_std_heap_redirect_sym_local(uint8_t * name, int32_t name_len, uint8_t * sym_out, int32_t out_cap) {
  {
    return glue_try_std_heap_redirect_sym_local_impl(name, name_len, sym_out, out_cap);
  }
  return 0;
}
int32_t pipeline_asm_abi_f32_xmm_enabled_c(void) {
  {
    return pipeline_asm_abi_f32_xmm_enabled_c_impl();
  }
  return 1;
}
int32_t glue_asm_build_func_export_sym_c(uint8_t * m, uint8_t * a, int32_t func_ix, uint8_t * out, int32_t out_cap) {
  {
    return glue_asm_build_func_export_sym_c_impl(m, a, func_ix, out, out_cap);
  }
  return (0 - 1);
}
extern int32_t glue_asm_emit_jmp_skip_string_then_lea_impl(uint8_t * ctx_bytes, int32_t ta, int32_t reg_k, uint8_t * sbuf, int32_t slen);
extern int32_t glue_spill_struct16_call_arg_to_lea_elf_c_impl(uint8_t * arena, uint8_t * elf_ctx, uint8_t * ctx, int32_t pty, int32_t ta);
extern int32_t pipeline_asm_resolve_whole_import_qualified_symbol_c_impl(uint8_t * arena, uint8_t * cur_mod, int32_t callee_expr_ref, uint8_t * sym_flat, int32_t * out_match_imp_j);
int32_t glue_asm_emit_jmp_skip_string_then_lea(uint8_t * ctx_bytes, int32_t ta, int32_t reg_k, uint8_t * sbuf, int32_t slen) {
  {
    return glue_asm_emit_jmp_skip_string_then_lea_impl(ctx_bytes, ta, reg_k, sbuf, slen);
  }
  return (0 - 1);
}
int32_t glue_spill_struct16_call_arg_to_lea_elf_c(uint8_t * arena, uint8_t * elf_ctx, uint8_t * ctx, int32_t pty, int32_t ta) {
  {
    return glue_spill_struct16_call_arg_to_lea_elf_c_impl(arena, elf_ctx, ctx, pty, ta);
  }
  return 0;
}
int32_t pipeline_asm_resolve_whole_import_qualified_symbol_c(uint8_t * arena, uint8_t * cur_mod, int32_t callee_expr_ref, uint8_t * sym_flat, int32_t * out_match_imp_j) {
  {
    return pipeline_asm_resolve_whole_import_qualified_symbol_c_impl(arena, cur_mod, callee_expr_ref, sym_flat, out_match_imp_j);
  }
  return (0 - 1);
}
extern int32_t pipeline_asm_emit_call_elf_c_impl(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta);
extern int32_t pipeline_asm_emit_method_call_elf_c_impl(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta);
extern int32_t pipeline_asm_emit_call_args_text_c_impl(uint8_t * arena, uint8_t * out, int32_t expr_ref, uint8_t * ctx, int32_t target_arch, int32_t nargs);
int32_t pipeline_asm_emit_call_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  {
    return pipeline_asm_emit_call_elf_c_impl(arena, elf_ctx, expr_ref, ctx, ta);
  }
  return (0 - 1);
}
int32_t pipeline_asm_emit_method_call_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  {
    return pipeline_asm_emit_method_call_elf_c_impl(arena, elf_ctx, expr_ref, ctx, ta);
  }
  return (0 - 1);
}
int32_t pipeline_asm_emit_call_args_text_c(uint8_t * arena, uint8_t * out, int32_t expr_ref, uint8_t * ctx, int32_t target_arch, int32_t nargs) {
  {
    return pipeline_asm_emit_call_args_text_c_impl(arena, out, expr_ref, ctx, target_arch, nargs);
  }
  return (0 - 1);
}
extern int32_t pipeline_asm_emit_call_args_elf_c_impl(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta, int32_t nargs);
extern int32_t glue_emit_call_args_elf_sysv_f32_xmm_c_impl(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta, int32_t nargs);
extern int32_t glue_asm_emit_call_with_cleanup_impl(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta, int32_t nargs, uint8_t * cname, int32_t clen);
int32_t pipeline_asm_emit_call_args_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta, int32_t nargs) {
  {
    return pipeline_asm_emit_call_args_elf_c_impl(arena, elf_ctx, expr_ref, ctx, ta, nargs);
  }
  return (0 - 1);
}
int32_t glue_emit_call_args_elf_sysv_f32_xmm_c(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta, int32_t nargs) {
  {
    return glue_emit_call_args_elf_sysv_f32_xmm_c_impl(arena, elf_ctx, expr_ref, ctx, ta, nargs);
  }
  return (0 - 1);
}
int32_t glue_asm_emit_call_with_cleanup(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta, int32_t nargs, uint8_t * cname, int32_t clen) {
  {
    return glue_asm_emit_call_with_cleanup_impl(arena, elf_ctx, expr_ref, ctx, ta, nargs, cname, clen);
  }
  return (0 - 1);
}
extern int32_t glue_emit_one_call_arg_elf_c_impl(uint8_t * arena, uint8_t * elf_ctx, int32_t call_expr_ref, int32_t arg_ref, int32_t arg_index, uint8_t * ctx, int32_t ta);
extern int32_t glue_asm_build_call_export_sym_c_impl(uint8_t * arena, int32_t call_expr_ref, int32_t callee_ref, uint8_t * mod, uint8_t * dep_pipe, uint8_t * out, int32_t out_cap);
extern int32_t glue_asm_try_emit_fmt_string_lit_import_call_elf_c_impl(uint8_t * arena, uint8_t * elf_ctx, int32_t call_expr_ref, uint8_t * ctx, int32_t ta, uint8_t * pre_buf, int32_t pre_len, uint8_t * field_name, int32_t field_len);
int32_t glue_emit_one_call_arg_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t call_expr_ref, int32_t arg_ref, int32_t arg_index, uint8_t * ctx, int32_t ta) {
  {
    return glue_emit_one_call_arg_elf_c_impl(arena, elf_ctx, call_expr_ref, arg_ref, arg_index, ctx, ta);
  }
  return (0 - 1);
}
int32_t glue_asm_build_call_export_sym_c(uint8_t * arena, int32_t call_expr_ref, int32_t callee_ref, uint8_t * mod, uint8_t * dep_pipe, uint8_t * out, int32_t out_cap) {
  {
    return glue_asm_build_call_export_sym_c_impl(arena, call_expr_ref, callee_ref, mod, dep_pipe, out, out_cap);
  }
  return (0 - 1);
}
int32_t glue_asm_try_emit_fmt_string_lit_import_call_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t call_expr_ref, uint8_t * ctx, int32_t ta, uint8_t * pre_buf, int32_t pre_len, uint8_t * field_name, int32_t field_len) {
  {
    return glue_asm_try_emit_fmt_string_lit_import_call_elf_c_impl(arena, elf_ctx, call_expr_ref, ctx, ta, pre_buf, pre_len, field_name, field_len);
  }
  return (0 - 1);
}
extern int32_t pipeline_asm_emit_set_call_f32_xmm_impl(int32_t on);
extern int32_t glue_codegen_import_path_to_c_prefix_into_impl(uint8_t * path, uint8_t * buf, int32_t buf_cap);
extern int32_t glue_asm_string_lit_into_impl(uint8_t * arena, int32_t expr_ref, uint8_t * out64);
extern int32_t glue_sysv_x86_call_arg_slot_c_impl(uint8_t * arena, int32_t call_expr_ref, int32_t nargs, int32_t arg_index, int32_t * out_kind, int32_t * out_reg_k, int32_t * out_stack_k);
int32_t pipeline_asm_emit_set_call_f32_xmm(int32_t on) {
  {
    return pipeline_asm_emit_set_call_f32_xmm_impl(on);
  }
  return 0;
}
int32_t glue_codegen_import_path_to_c_prefix_into(uint8_t * path, uint8_t * buf, int32_t buf_cap) {
  {
    return glue_codegen_import_path_to_c_prefix_into_impl(path, buf, buf_cap);
  }
  return 0;
}
int32_t glue_asm_string_lit_into(uint8_t * arena, int32_t expr_ref, uint8_t * out64) {
  {
    return glue_asm_string_lit_into_impl(arena, expr_ref, out64);
  }
  return 0;
}
int32_t glue_sysv_x86_call_arg_slot_c(uint8_t * arena, int32_t call_expr_ref, int32_t nargs, int32_t arg_index, int32_t * out_kind, int32_t * out_reg_k, int32_t * out_stack_k) {
  {
    return glue_sysv_x86_call_arg_slot_c_impl(arena, call_expr_ref, nargs, arg_index, out_kind, out_reg_k, out_stack_k);
  }
  return 0;
}
int32_t glue_f32_xmm_flag_get_body(void) {
  {
    return glue_f32_xmm_flag_get_body_impl();
  }
  return 0;
}
