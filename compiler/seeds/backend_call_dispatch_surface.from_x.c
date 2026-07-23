/* seeds/backend_call_dispatch_surface.from_x.c
 * R2 full surface — isomorphic with src/asm/backend_call_dispatch.x
 * Product PREFER_X_O: g05_try_x_to_o(backend_call_dispatch.x) + hybrid rest
 *   seeds/backend_call_dispatch.from_x.c (-DXLANG_BACKEND_CALL_DISPATCH_FROM_X) ld -r
 * R2: full.x 吃满 CALL/emit/import 公共业务；FROM_X rest 仅 slice_marker（业务 H=0）
 * Prove: full.x vs this seed → nm IDENTICAL
 * Regen: ./xlang -E ... src/asm/backend_call_dispatch.x | filter DBG + polish prologue
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
/* wave231 G.7: env via public pure thin link_abi_getenv (not raw libc getenv). */
extern char *link_abi_getenv(const char *name);
extern int32_t backend_call_dispatch_x_doc_anchor(void);
extern int32_t pipeline_asm_abi_f32_xmm_enabled_c(void);
extern void pipeline_asm_emit_set_call_f32_xmm(int32_t on);
extern int32_t pipeline_asm_emit_get_call_f32_xmm_c(void);
extern void glue_asm_string_lit_into(uint8_t * arena, int32_t er, uint8_t * out64);
extern void glue_codegen_import_path_to_c_prefix_into(uint8_t * path, uint8_t * buf, int32_t buf_cap);
extern int32_t glue_module_func_overload_count_c(uint8_t * m, uint8_t * name, int32_t nlen);
extern int32_t glue_asm_import_segment_at(uint8_t * mod, int32_t ix, int32_t want_seg, int32_t * ostr, int32_t * olen);
extern int32_t glue_asm_fill_c_prefix_from_module_import(uint8_t * mod, int32_t ix, uint8_t * pre);
extern int32_t call_dispatch_load_i32_le(uint8_t * p, int32_t off);
extern void call_dispatch_store_i32_le(uint8_t * p, int32_t off, int32_t v);
extern uint8_t * call_dispatch_load_ptr_le(uint8_t * p, int32_t off);
extern int32_t glue_asm_call_reg_max(int32_t ta);
extern int32_t glue_asm_emit_jmp_skip_string_then_lea(uint8_t * ctx_bytes, int32_t ta, int32_t reg_k, uint8_t * sbuf, int32_t slen);
extern void glue_sysv_x86_call_arg_slot_c(uint8_t * arena, int32_t call_expr_ref, int32_t nargs, int32_t arg_index, int32_t * out_kind, int32_t * out_reg_k, int32_t * out_stack_k);
extern int32_t glue_spill_struct16_call_arg_to_lea_elf_c(uint8_t * arena, uint8_t * elf, uint8_t * ctx, int32_t pty, int32_t ta);
extern int32_t glue_emit_call_args_elf_sysv_f32_xmm_c(uint8_t * arena, uint8_t * elf, int32_t er, uint8_t * ctx, int32_t ta, int32_t nargs);
extern int32_t glue_emit_one_call_arg_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t call_expr_ref, int32_t arg_ref, int32_t arg_index, uint8_t * ctx, int32_t ta);
extern int32_t glue_asm_build_call_export_sym_c(uint8_t * arena, int32_t call_expr_ref, int32_t callee_ref, uint8_t * mod, uint8_t * dep_pipe, uint8_t * out, int32_t out_cap);
extern int32_t glue_asm_build_dep_export_sym_c(uint8_t * name, int32_t name_len, uint8_t * out, int32_t out_cap);
extern int32_t glue_asm_build_func_export_sym_c(uint8_t * m, uint8_t * a, int32_t func_ix, uint8_t * out, int32_t out_cap);
extern int32_t glue_asm_try_emit_fmt_string_lit_import_call_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t call_expr_ref, uint8_t * ctx, int32_t ta, uint8_t * pre_buf, int32_t pre_len, uint8_t * field_name, int32_t field_len);
extern int32_t glue_asm_enc_call_redirected(uint8_t * elf_ctx, uint8_t * name, int32_t name_len, int32_t ta);
extern int32_t pipeline_asm_emit_call_args_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta, int32_t nargs);
extern int32_t glue_asm_emit_string_lit_ptr_rax_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t str_expr_ref, int32_t ta);
extern int32_t glue_asm_emit_call_with_cleanup(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta, int32_t nargs, uint8_t * cname, int32_t clen);
extern int32_t glue_asm_call_stack_cleanup_bytes(int32_t ta, int32_t nargs);
extern int32_t pipeline_asm_resolve_whole_import_qualified_symbol_c(uint8_t * arena, uint8_t * cur_mod, int32_t callee_expr_ref, uint8_t * sym_flat, int32_t * out_match_imp_j);
extern int32_t pipeline_asm_emit_call_args_text_c(uint8_t * arena, uint8_t * out, int32_t expr_ref, uint8_t * ctx, int32_t target_arch, int32_t nargs);
extern int32_t pipeline_asm_emit_method_call_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta);
extern int32_t pipeline_asm_emit_call_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta);
extern int32_t glue_asm_prefix_is_fmt_or_debug(uint8_t * pre, int32_t pre_len);
extern int32_t glue_call_param_is_f32_c(uint8_t * arena, int32_t tr);
extern int32_t glue_asm_std_c_wrapper_fname_needs_export_c_suffix(uint8_t * fname, int32_t nlen);
extern int32_t glue_asm_append_export_c_suffix(uint8_t * sym, int32_t slen, int32_t cap);
extern int32_t glue_asm_import_path_segment_count(uint8_t * path, int32_t plen);
extern int32_t glue_asm_c_prefix_redundant_with_name(uint8_t * pre, int32_t plen, uint8_t * name, int32_t nlen);
extern int32_t glue_type_kind_to_suffix_c(int32_t kind, uint8_t * out, int32_t cap);
extern int32_t glue_asm_import_path_slice_equal(uint8_t * mod, int32_t ix, int32_t off, int32_t slen, uint8_t * nm, int32_t nm_len);
extern int32_t glue_asm_import_binding_name_equal(uint8_t * mod, int32_t ix, uint8_t * nm, int32_t nlen);
extern int32_t glue_sysv_x86_call_n_stack_c(uint8_t * arena, int32_t call, int32_t nargs);
extern int32_t glue_asm_string_lit_len(uint8_t * arena, int32_t er);
extern int32_t glue_asm_build_import_binding_call_sym(uint8_t * pre, int32_t plen, uint8_t * field, int32_t flen, uint8_t * out);
extern int32_t glue_call_param_type_ref_at(uint8_t * arena, int32_t call, int32_t pix);
extern int32_t glue_try_std_string_xlang_redirect_sym_local(uint8_t * name, int32_t nlen, uint8_t * out, int32_t cap);
extern int32_t glue_try_std_encoding_redirect_sym_local(uint8_t * name, int32_t nlen, uint8_t * out, int32_t cap);
extern int32_t glue_try_std_heap_redirect_sym_local(uint8_t * name, int32_t nlen, uint8_t * out, int32_t cap);
static int32_t g_pipeline_asm_emit_call_f32_xmm;
static void init_globals(void) {
  g_pipeline_asm_emit_call_f32_xmm = 0;
}
int32_t backend_call_dispatch_x_doc_anchor(void) {
  return 0;
}
int32_t pipeline_asm_abi_f32_xmm_enabled_c(void) {
  {
    /* wave231 G.7: XLANG_ABI_F32_XMM via link_abi_getenv (not raw getenv). */
    uint8_t * env = (uint8_t *)link_abi_getenv((const char *)(uint8_t[]){83, 72, 85, 88, 95, 65, 66, 73, 95, 70, 51, 50, 95, 88, 77, 77, 0 });
    if ((env !=0)) {
      if (((env)[0] ==48)) {
        if (((env)[1] ==0)) {
          return 0;
        }
      }
    }
  }
  return 1;
}
void pipeline_asm_emit_set_call_f32_xmm(int32_t on) {
  if ((on !=0)) {
    (void)((g_pipeline_asm_emit_call_f32_xmm = 1));
  } else {
    (void)((g_pipeline_asm_emit_call_f32_xmm = 0));
  }
  (void)(0);
  return;
}
int32_t pipeline_asm_emit_get_call_f32_xmm_c(void) {
  return g_pipeline_asm_emit_call_f32_xmm;
}
extern void pipeline_expr_var_name_into(uint8_t * arena, int32_t er, uint8_t * out);
extern int32_t pipeline_expr_kind_ord_at(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_var_name_len_for_string_lit_c(uint8_t * arena, int32_t er);
extern int32_t pipeline_asm_call_param_type_ref_at_c(uint8_t * arena, int32_t call, int32_t pix);
extern int32_t pipeline_type_kind_ord_at(uint8_t * arena, int32_t type_ref);
void glue_asm_string_lit_into(uint8_t * arena, int32_t er, uint8_t * out64) {
  if ((out64 ==0)) {
    return;
  }
  int32_t zi = 0;
  while ((zi < 64)) {
    (void)(((out64)[zi] = 0));
    (void)((zi = (zi + 1)));
  }
  if ((arena ==0)) {
    return;
  }
  {
    if ((glue_asm_string_lit_len(arena, er) <=0)) {
      return;
    }
    (void)(pipeline_expr_var_name_into(arena, er, out64));
  }
  (void)(0);
  return;
}
void glue_codegen_import_path_to_c_prefix_into(uint8_t * path, uint8_t * buf, int32_t buf_cap) {
  if ((buf ==0)) {
    return;
  }
  if ((buf_cap <=0)) {
    return;
  }
  int32_t off = 0;
  int32_t pi = 0;
  if ((path !=0)) {
    while ((1 ==1)) {
      uint8_t ch = (path)[pi];
      if ((ch ==0)) {
        break;
      }
      if (((off + 2) >=buf_cap)) {
        break;
      }
      if ((ch ==46)) {
        (void)(((buf)[off] = 95));
      } else {
        (void)(((buf)[off] = ch));
      }
      (void)((off = (off + 1)));
      (void)((pi = (pi + 1)));
    }
  }
  if (((off + 1) < buf_cap)) {
    (void)(((buf)[off] = 95));
    (void)((off = (off + 1)));
  }
  if ((off < buf_cap)) {
    (void)(((buf)[off] = 0));
  }
  (void)(0);
  return;
}
extern void parser_get_module_import_path(uint8_t * mod, int32_t ix, uint8_t * path_bytes);
extern int32_t pipeline_module_num_funcs(uint8_t * m);
extern int32_t pipeline_asm_module_func_is_extern_at(uint8_t * m, int32_t i);
extern int32_t pipeline_module_func_name_equal_at(uint8_t * m, int32_t i, uint8_t * name, int32_t nlen);
extern int32_t parser_get_module_num_imports(uint8_t * mod);
extern int32_t pipeline_module_import_path_len(uint8_t * mod, int32_t idx);
extern uint8_t pipeline_module_import_path_byte_at_u8_ptr_i32_i32_retu8(uint8_t * mod, int32_t idx, int32_t k);
int32_t glue_module_func_overload_count_c(uint8_t * m, uint8_t * name, int32_t nlen) {
  if ((m ==0)) {
    return 0;
  }
  if ((name ==0)) {
    return 0;
  }
  if ((nlen <=0)) {
    return 0;
  }
  {
    int32_t c = 0;
    int32_t n = pipeline_module_num_funcs(m);
    int32_t i = 0;
    while ((i < n)) {
      if ((pipeline_asm_module_func_is_extern_at(m, i) ==0)) {
        if ((pipeline_module_func_name_equal_at(m, i, name, nlen) !=0)) {
          (void)((c = (c + 1)));
        }
      }
      (void)((i = (i + 1)));
    }
    return c;
  }
  return 0;
}
int32_t glue_asm_import_segment_at(uint8_t * mod, int32_t ix, int32_t want_seg, int32_t * ostr, int32_t * olen) {
  if ((mod ==0)) {
    return 0;
  }
  if ((ix < 0)) {
    return 0;
  }
  if ((ostr ==0)) {
    return 0;
  }
  if ((olen ==0)) {
    return 0;
  }
  {
    int32_t pl = pipeline_module_import_path_len(mod, ix);
    int32_t ci = 0;
    int32_t ss = 0;
    int32_t k = 0;
    if ((ix >=parser_get_module_num_imports(mod))) {
      return 0;
    }
    if ((pl <=0)) {
      return 0;
    }
    if ((pl > 63)) {
      return 0;
    }
    while ((k <=pl)) {
      int32_t at_end = 0;
      if ((k ==pl)) {
        (void)((at_end = 1));
      }
      int32_t dot = 0;
      if ((at_end ==0)) {
        if ((k < pl)) {
          if ((pipeline_module_import_path_byte_at_u8_ptr_i32_i32_retu8(mod, ix, k) ==46)) {
            (void)((dot = 1));
          }
        }
      }
      if (((at_end !=0) || (dot !=0))) {
        int32_t seg_len_here = (k - ss);
        if ((seg_len_here <=0)) {
          return 0;
        }
        if ((ci ==want_seg)) {
          (void)(((ostr)[0] = ss));
          (void)(((olen)[0] = seg_len_here));
          return 1;
        }
        if ((dot !=0)) {
          (void)((ss = (k + 1)));
        }
        (void)((ci = (ci + 1)));
      }
      (void)((k = (k + 1)));
    }
  }
  return 0;
}
int32_t glue_asm_fill_c_prefix_from_module_import(uint8_t * mod, int32_t ix, uint8_t * pre) {
  if ((mod ==0)) {
    return (0 - 1);
  }
  if ((pre ==0)) {
    return (0 - 1);
  }
  uint8_t path_bytes[64] = {};
  {
    (void)(parser_get_module_import_path(mod, ix, &((path_bytes)[0])));
    if (((path_bytes)[0] ==0)) {
      return (0 - 1);
    }
    (void)(glue_codegen_import_path_to_c_prefix_into(&((path_bytes)[0]), pre, 128));
  }
  int32_t pre_len = 0;
  while ((pre_len < 128)) {
    if (((pre)[pre_len] ==0)) {
      break;
    }
    (void)((pre_len = (pre_len + 1)));
  }
  if ((pre_len > 0)) {
    return pre_len;
  }
  return (0 - 1);
}
extern int32_t pipeline_elf_ctx_append_bytes(uint8_t * ctx, uint8_t * ptr, int32_t n);
extern int32_t pipeline_asm_redirect_std_c_wrapper_sym(uint8_t * name, int32_t nlen, uint8_t * out, int32_t cap);
extern int32_t backend_enc_call_arch(uint8_t * elf, uint8_t * name, int32_t nlen, int32_t ta);
extern int32_t backend_enc_call_stack_cleanup_arch(uint8_t * elf, int32_t nbytes, int32_t ta);
extern int32_t pipeline_asm_emit_call_sret_reg_shift_c(void);
extern int32_t backend_enc_store_x0_sp_offset_arch(uint8_t * elf, int32_t off_bytes, int32_t ta);
extern void pipeline_asm_emit_set_call_param_type_ref(int32_t tr);
extern void pipeline_asm_emit_call_arg_begin_c(void);
extern void pipeline_asm_emit_call_arg_end_c(void);
extern int32_t pipeline_asm_emit_expr_elf_for_call_args(uint8_t * arena, uint8_t * elf, int32_t ar, uint8_t * ctx, int32_t ta);
extern int32_t pipeline_asm_call_struct16_ret_needs_rax_deref_c(uint8_t * arena, int32_t call);
extern int32_t pipeline_asm_deref_struct16_rax_ptr_elf_c(uint8_t * elf, int32_t ta);
extern int32_t pipeline_expr_call_num_args_at(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_call_arg_ref(uint8_t * arena, int32_t er, int32_t i);
extern int32_t backend_enc_mov_imm32_to_w0_arch(uint8_t * elf, int32_t imm, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(uint8_t * elf, int32_t k, int32_t ta);
extern uint8_t * driver_get_current_dep_path_for_codegen(void);
extern int32_t pipeline_asm_module_func_name_len_at(uint8_t * m, int32_t fi);
extern void pipeline_asm_module_func_name_copy64(uint8_t * m, int32_t fi, uint8_t * dst);
extern int32_t pipeline_module_func_num_params_at(uint8_t * m, int32_t fi);
extern int32_t pipeline_module_func_param_type_ref_at(uint8_t * m, int32_t fi, int32_t pi);
extern int32_t pipeline_type_elem_ref_at(uint8_t * a, int32_t tr);
extern int32_t pipeline_asm_type_ref_byte_size_c(uint8_t * arena, int32_t pty);
extern int32_t backend_enc_store_rax_to_rbp_arch(uint8_t * elf, int32_t off, int32_t ta);
extern int32_t backend_enc_store_rdx_to_rbp_arch(uint8_t * elf, int32_t off, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rax_arch(uint8_t * elf, int32_t off, int32_t ta);
extern int32_t backend_enc_call_stack_reserve_arch(uint8_t * elf, int32_t nbytes, int32_t ta);
extern int32_t backend_enc_push_rax_arch(uint8_t * elf, int32_t ta);
extern int32_t backend_enc_mov_eax_to_xmm_arg_reg_arch(uint8_t * elf, int32_t k, int32_t ta);
extern int32_t pipeline_expr_var_name_len(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_call_resolved_dep_index_at(uint8_t * arena, int32_t call);
extern int32_t pipeline_dep_ctx_ndep(uint8_t * dep);
extern uint8_t * pipeline_dep_ctx_module_at(uint8_t * dep, int32_t j);
extern void pipeline_dep_ctx_import_path_copy64(uint8_t * dep, int32_t j, uint8_t * path);
extern int32_t pipeline_module_func_is_extern_at(uint8_t * m, int32_t fi);
extern int32_t pipeline_typeck_resolve_call_func_index_for_emit_c(uint8_t * m, uint8_t * a, int32_t call);
int32_t call_dispatch_load_i32_le(uint8_t * p, int32_t off) {
  if ((p ==0)) {
    return 0;
  }
  int32_t m = 256;
  int32_t a = ((int32_t)((p)[off]));
  (void)((a = (a + (((int32_t)((p)[(off + 1)])) * m))));
  (void)((a = (a + (((int32_t)((p)[(off + 2)])) * (m * m)))));
  (void)((a = (a + (((int32_t)((p)[(off + 3)])) * ((m * m) * m)))));
  return a;
}
void call_dispatch_store_i32_le(uint8_t * p, int32_t off, int32_t v) {
  if ((p ==0)) {
    return;
  }
  uint32_t u = ((uint32_t)(v));
  (void)(((p)[off] = ((uint8_t)((u & 255)))));
  (void)(((p)[(off + 1)] = ((uint8_t)(((u / 256) & 255)))));
  (void)(((p)[(off + 2)] = ((uint8_t)(((u / 65536) & 255)))));
  (void)(((p)[(off + 3)] = ((uint8_t)(((u / 16777216) & 255)))));
}
uint8_t * call_dispatch_load_ptr_le(uint8_t * p, int32_t off) {
  if ((p ==0)) {
    return ((uint8_t *)(0));
  }
  size_t m = 256;
  size_t m2 = (m * m);
  size_t m4 = (m2 * m2);
  size_t a = ((size_t)((p)[off]));
  (void)((a = (a + (((size_t)((p)[(off + 1)])) * m))));
  (void)((a = (a + (((size_t)((p)[(off + 2)])) * m2))));
  (void)((a = (a + (((size_t)((p)[(off + 3)])) * (m2 * m)))));
  (void)((a = (a + (((size_t)((p)[(off + 4)])) * m4))));
  (void)((a = (a + (((size_t)((p)[(off + 5)])) * (m4 * m)))));
  (void)((a = (a + (((size_t)((p)[(off + 6)])) * (m4 * m2)))));
  (void)((a = (a + (((size_t)((p)[(off + 7)])) * ((m4 * m2) * m)))));
  return ((uint8_t *)(a));
}
int32_t glue_asm_call_reg_max(int32_t ta) {
  if ((ta ==0)) {
    return 6;
  }
  return 8;
}
int32_t glue_asm_emit_jmp_skip_string_then_lea(uint8_t * ctx_bytes, int32_t ta, int32_t reg_k, uint8_t * sbuf, int32_t slen) {
  if ((ctx_bytes ==0)) {
    return (0 - 1);
  }
  if ((sbuf ==0)) {
    return (0 - 1);
  }
  if ((slen <=0)) {
    return (0 - 1);
  }
  if ((slen > 63)) {
    return (0 - 1);
  }
  if ((ta !=0)) {
    return (0 - 1);
  }
  if (((slen + 1) > 127)) {
    return (0 - 1);
  }
  {
    uint8_t jmp2[2] = {};
    (void)(((jmp2)[0] = 235));
    (void)(((jmp2)[1] = ((uint8_t)((slen + 1)))));
    if ((pipeline_elf_ctx_append_bytes(ctx_bytes, &((jmp2)[0]), 2) !=0)) {
      return (0 - 1);
    }
    if ((pipeline_elf_ctx_append_bytes(ctx_bytes, sbuf, slen) !=0)) {
      return (0 - 1);
    }
    uint8_t z = 0;
    if ((pipeline_elf_ctx_append_bytes(ctx_bytes, &(z), 1) !=0)) {
      return (0 - 1);
    }
    int32_t d = ((0 - slen) - 8);
    uint32_t u = ((uint32_t)(d));
    uint8_t lea7[7] = {};
    (void)(((lea7)[0] = 72));
    (void)(((lea7)[1] = 141));
    if ((reg_k ==0)) {
      (void)(((lea7)[2] = 61));
    } else {
      (void)(((lea7)[2] = 5));
    }
    (void)(((lea7)[3] = ((uint8_t)((u & 255)))));
    (void)(((lea7)[4] = ((uint8_t)(((u / 256) & 255)))));
    (void)(((lea7)[5] = ((uint8_t)(((u / 65536) & 255)))));
    (void)(((lea7)[6] = ((uint8_t)(((u / 16777216) & 255)))));
    return pipeline_elf_ctx_append_bytes(ctx_bytes, &((lea7)[0]), 7);
  }
  return (0 - 1);
}
void glue_sysv_x86_call_arg_slot_c(uint8_t * arena, int32_t call_expr_ref, int32_t nargs, int32_t arg_index, int32_t * out_kind, int32_t * out_reg_k, int32_t * out_stack_k) {
  if ((out_kind ==0)) {
    return;
  }
  if ((out_reg_k ==0)) {
    return;
  }
  if ((out_stack_k ==0)) {
    return;
  }
  int32_t gp = 0;
  int32_t xmm = 0;
  int32_t stk = 0;
  int32_t j = 0;
  while ((j <=arg_index)) {
    int32_t pty = glue_call_param_type_ref_at(arena, call_expr_ref, j);
    if ((j >=nargs)) {
      break;
    }
    if ((j ==arg_index)) {
      if ((glue_call_param_is_f32_c(arena, pty) !=0)) {
        if ((xmm < 8)) {
          (void)(((out_kind)[0] = 1));
          (void)(((out_reg_k)[0] = xmm));
        } else {
          (void)(((out_kind)[0] = 2));
          (void)(((out_stack_k)[0] = stk));
        }
      } else {
        if ((gp < 6)) {
          (void)(((out_kind)[0] = 0));
          (void)(((out_reg_k)[0] = gp));
        } else {
          (void)(((out_kind)[0] = 2));
          (void)(((out_stack_k)[0] = stk));
        }
      }
      return;
    }
    if ((glue_call_param_is_f32_c(arena, pty) !=0)) {
      if ((xmm < 8)) {
        (void)((xmm = (xmm + 1)));
      } else {
        (void)((stk = (stk + 1)));
      }
    } else {
      if ((gp < 6)) {
        (void)((gp = (gp + 1)));
      } else {
        (void)((stk = (stk + 1)));
      }
    }
    (void)((j = (j + 1)));
  }
  (void)(((out_kind)[0] = 2));
  (void)(((out_reg_k)[0] = 0));
  (void)(((out_stack_k)[0] = 0));
}
int32_t glue_spill_struct16_call_arg_to_lea_elf_c(uint8_t * arena, uint8_t * elf, uint8_t * ctx, int32_t pty, int32_t ta) {
  if ((ta !=0)) {
    return 0;
  }
  if ((elf ==0)) {
    return 0;
  }
  if ((ctx ==0)) {
    return 0;
  }
  {
    int32_t sz = pipeline_asm_type_ref_byte_size_c(arena, pty);
    if ((sz <=8)) {
      return 0;
    }
    if ((sz > 16)) {
      return 0;
    }
    int32_t next = call_dispatch_load_i32_le(ctx, 4);
    int32_t off = (next + 16);
    if ((off < 16)) {
      (void)((off = 16));
      (void)(call_dispatch_store_i32_le(ctx, 4, 0));
    }
    if ((off < 16)) {
      return (0 - 1);
    }
    if ((backend_enc_store_rax_to_rbp_arch(elf, off, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_store_rdx_to_rbp_arch(elf, (off - 8), ta) !=0)) {
      return (0 - 1);
    }
    (void)(call_dispatch_store_i32_le(ctx, 4, (off + 16)));
    return backend_enc_lea_rbp_to_rax_arch(elf, off, ta);
  }
  return 0;
}
int32_t glue_emit_call_args_elf_sysv_f32_xmm_c(uint8_t * arena, uint8_t * elf, int32_t er, uint8_t * ctx, int32_t ta, int32_t nargs) {
  if ((arena ==0)) {
    return (0 - 1);
  }
  if ((elf ==0)) {
    return (0 - 1);
  }
  if ((ctx ==0)) {
    return (0 - 1);
  }
  if ((nargs < 0)) {
    return (0 - 1);
  }
  if ((nargs > 96)) {
    return (0 - 1);
  }
  {
    int32_t n_stack = glue_sysv_x86_call_n_stack_c(arena, er, nargs);
    int32_t stack_reserve = 0;
    if ((n_stack > 0)) {
      (void)((stack_reserve = (n_stack * 8)));
      if (((n_stack & 1) !=0)) {
        (void)((stack_reserve = (stack_reserve + 8)));
      }
    }
    if ((backend_enc_call_stack_reserve_arch(elf, stack_reserve, ta) !=0)) {
      return (0 - 1);
    }
    int32_t stk_push[96] = {};
    int32_t n_stk_push = 0;
    int32_t i = 0;
    while ((i < nargs)) {
      int32_t kind = 0;
      int32_t reg_k = 0;
      int32_t stack_k = 0;
      (void)(glue_sysv_x86_call_arg_slot_c(arena, er, nargs, i, &(kind), &(reg_k), &(stack_k)));
      if ((kind ==2)) {
        if ((n_stk_push < 96)) {
          (void)(((stk_push)[n_stk_push] = i));
          (void)((n_stk_push = (n_stk_push + 1)));
        }
      }
      (void)((i = (i + 1)));
    }
    if ((n_stack > 0)) {
      if (((n_stack & 1) !=0)) {
        if ((backend_enc_mov_imm32_to_w0_arch(elf, 0, ta) !=0)) {
          return (0 - 1);
        }
        if ((backend_enc_push_rax_arch(elf, ta) !=0)) {
          return (0 - 1);
        }
      }
    }
    int32_t si = (n_stk_push - 1);
    while ((si >=0)) {
      int32_t arg_ref = pipeline_expr_call_arg_ref(arena, er, i);
      (void)((i = (stk_push)[si]));
      if ((arg_ref !=0)) {
        if ((glue_emit_one_call_arg_elf_c(arena, elf, er, arg_ref, i, ctx, ta) !=0)) {
          return (0 - 1);
        }
        if ((backend_enc_push_rax_arch(elf, ta) !=0)) {
          return (0 - 1);
        }
      }
      (void)((si = (si - 1)));
    }
    (void)(pipeline_asm_emit_set_call_f32_xmm(1));
    (void)((i = (nargs - 1)));
    while ((i >=0)) {
      int32_t arg_ref2 = pipeline_expr_call_arg_ref(arena, er, i);
      if ((arg_ref2 !=0)) {
        int32_t kind2 = 0;
        int32_t reg_k2 = 0;
        int32_t stack_k2 = 0;
        (void)(glue_sysv_x86_call_arg_slot_c(arena, er, nargs, i, &(kind2), &(reg_k2), &(stack_k2)));
        if ((kind2 !=2)) {
          if ((glue_emit_one_call_arg_elf_c(arena, elf, er, arg_ref2, i, ctx, ta) !=0)) {
            (void)(pipeline_asm_emit_set_call_f32_xmm(0));
            return (0 - 1);
          }
          if ((kind2 ==0)) {
            if ((backend_enc_mov_rax_to_arg_reg_arch(elf, reg_k2, ta) !=0)) {
              (void)(pipeline_asm_emit_set_call_f32_xmm(0));
              return (0 - 1);
            }
          } else {
            if ((backend_enc_mov_eax_to_xmm_arg_reg_arch(elf, reg_k2, ta) !=0)) {
              (void)(pipeline_asm_emit_set_call_f32_xmm(0));
              return (0 - 1);
            }
          }
        }
      }
      (void)((i = (i - 1)));
    }
    (void)(pipeline_asm_emit_set_call_f32_xmm(0));
    (void)(pipeline_asm_emit_set_call_param_type_ref(0));
    return 0;
  }
  return (0 - 1);
}
int32_t glue_emit_one_call_arg_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t call_expr_ref, int32_t arg_ref, int32_t arg_index, uint8_t * ctx, int32_t ta) {
  if ((arena ==0)) {
    return 0;
  }
  if ((elf_ctx ==0)) {
    return 0;
  }
  if ((ctx ==0)) {
    return 0;
  }
  if ((arg_ref ==0)) {
    return 0;
  }
  {
    int32_t pty0 = glue_call_param_type_ref_at(arena, call_expr_ref, arg_index);
    (void)(pipeline_asm_emit_set_call_param_type_ref(pty0));
    (void)(pipeline_asm_emit_call_arg_begin_c());
    if ((pipeline_asm_emit_expr_elf_for_call_args(arena, elf_ctx, arg_ref, ctx, ta) !=0)) {
      (void)(pipeline_asm_emit_call_arg_end_c());
      (void)(pipeline_asm_emit_set_call_param_type_ref(0));
      return (0 - 1);
    }
    int32_t pty = glue_call_param_type_ref_at(arena, call_expr_ref, arg_index);
    if ((pipeline_expr_kind_ord_at(arena, arg_ref) ==48)) {
      if ((pipeline_asm_call_struct16_ret_needs_rax_deref_c(arena, arg_ref) !=0)) {
        if ((pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta) !=0)) {
          (void)(pipeline_asm_emit_call_arg_end_c());
          (void)(pipeline_asm_emit_set_call_param_type_ref(0));
          return (0 - 1);
        }
      }
      if ((glue_spill_struct16_call_arg_to_lea_elf_c(arena, elf_ctx, ctx, pty, ta) !=0)) {
        (void)(pipeline_asm_emit_call_arg_end_c());
        (void)(pipeline_asm_emit_set_call_param_type_ref(0));
        return (0 - 1);
      }
    }
    (void)(pipeline_asm_emit_call_arg_end_c());
    (void)(pipeline_asm_emit_set_call_param_type_ref(0));
    return 0;
  }
  return 0;
}
int32_t glue_asm_build_call_export_sym_c(uint8_t * arena, int32_t call_expr_ref, int32_t callee_ref, uint8_t * mod, uint8_t * dep_pipe, uint8_t * out, int32_t out_cap) {
  if ((arena ==0)) {
    return (0 - 1);
  }
  if ((callee_ref <=0)) {
    return (0 - 1);
  }
  if ((out ==0)) {
    return (0 - 1);
  }
  if ((out_cap <=0)) {
    return (0 - 1);
  }
  {
    int32_t clen = pipeline_expr_var_name_len(arena, callee_ref);
    if ((clen <=0)) {
      return (0 - 1);
    }
    if ((clen > 63)) {
      return (0 - 1);
    }
    uint8_t cname[64] = {};
    (void)(pipeline_expr_var_name_into(arena, callee_ref, &((cname)[0])));
    int32_t rlen = glue_try_std_heap_redirect_sym_local(&((cname)[0]), clen, out, out_cap);
    if ((rlen > 0)) {
      return rlen;
    }
    int32_t dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, call_expr_ref);
    if ((dep_ix < 0)) {
      if ((dep_pipe !=0)) {
        int32_t nd = pipeline_dep_ctx_ndep(dep_pipe);
        int32_t j = 0;
        while ((j < nd)) {
          uint8_t * dm = pipeline_dep_ctx_module_at(dep_pipe, j);
          if ((dm !=0)) {
            int32_t nfunc = pipeline_module_num_funcs(dm);
            int32_t fi = 0;
            while ((fi < nfunc)) {
              if ((pipeline_module_func_name_equal_at(dm, fi, &((cname)[0]), clen) !=0)) {
                (void)((dep_ix = j));
                break;
              }
              (void)((fi = (fi + 1)));
            }
          }
          if ((dep_ix >=0)) {
            break;
          }
          (void)((j = (j + 1)));
        }
      }
    }
    if ((dep_ix >=0)) {
      if ((dep_pipe !=0)) {
        uint8_t * dep_mod = pipeline_dep_ctx_module_at(dep_pipe, dep_ix);
        if ((dep_mod !=0)) {
          int32_t nfunc2 = pipeline_module_num_funcs(dep_mod);
          int32_t fi2 = 0;
          while ((fi2 < nfunc2)) {
            if ((pipeline_module_func_name_equal_at(dep_mod, fi2, &((cname)[0]), clen) !=0)) {
              if ((pipeline_module_func_is_extern_at(dep_mod, fi2) !=0)) {
                if ((clen > 0)) {
                  if ((clen < out_cap)) {
                    int32_t ci = 0;
                    while ((ci < clen)) {
                      (void)(((out)[ci] = (cname)[ci]));
                      (void)((ci = (ci + 1)));
                    }
                    return clen;
                  }
                }
                return (0 - 1);
              }
              break;
            }
            (void)((fi2 = (fi2 + 1)));
          }
        }
        uint8_t path[64] = {};
        int32_t zi = 0;
        while ((zi < 64)) {
          (void)(((path)[zi] = 0));
          (void)((zi = (zi + 1)));
        }
        (void)(pipeline_dep_ctx_import_path_copy64(dep_pipe, dep_ix, &((path)[0])));
        if (((path)[0] !=0)) {
          uint8_t prefix[128] = {};
          (void)(glue_codegen_import_path_to_c_prefix_into(&((path)[0]), &((prefix)[0]), 128));
          int32_t plen = 0;
          while ((plen < 127)) {
            if (((prefix)[plen] ==0)) {
              break;
            }
            (void)((plen = (plen + 1)));
          }
          if ((plen > 0)) {
            return glue_asm_build_import_binding_call_sym(&((prefix)[0]), plen, &((cname)[0]), clen, out);
          }
        }
      }
    }
    if ((mod !=0)) {
      int32_t func_ix = pipeline_typeck_resolve_call_func_index_for_emit_c(mod, arena, call_expr_ref);
      if ((func_ix >=0)) {
        if ((pipeline_module_func_is_extern_at(mod, func_ix) !=0)) {
          if ((clen > 0)) {
            if ((clen < out_cap)) {
              int32_t ci2 = 0;
              while ((ci2 < clen)) {
                (void)(((out)[ci2] = (cname)[ci2]));
                (void)((ci2 = (ci2 + 1)));
              }
              return clen;
            }
          }
          return (0 - 1);
        }
        return glue_asm_build_func_export_sym_c(mod, arena, func_ix, out, out_cap);
      }
    }
    if ((clen > 0)) {
      if ((clen < out_cap)) {
        int32_t ci3 = 0;
        while ((ci3 < clen)) {
          (void)(((out)[ci3] = (cname)[ci3]));
          (void)((ci3 = (ci3 + 1)));
        }
        return clen;
      }
    }
  }
  return (0 - 1);
}
int32_t glue_asm_build_dep_export_sym_c(uint8_t * name, int32_t name_len, uint8_t * out, int32_t out_cap) {
  if ((name ==0)) {
    return (0 - 1);
  }
  if ((name_len <=0)) {
    return (0 - 1);
  }
  if ((out ==0)) {
    return (0 - 1);
  }
  if ((out_cap <=0)) {
    return (0 - 1);
  }
  {
    uint8_t * dep_path = driver_get_current_dep_path_for_codegen();
    int32_t pos = 0;
    if ((dep_path !=0)) {
      if (((dep_path)[0] !=0)) {
        uint8_t prefix[128] = {};
        (void)(glue_codegen_import_path_to_c_prefix_into(dep_path, &((prefix)[0]), 128));
        int32_t plen = 0;
        while ((plen < 127)) {
          if (((prefix)[plen] ==0)) {
            break;
          }
          (void)((plen = (plen + 1)));
        }
        if ((plen > 0)) {
          if ((glue_asm_c_prefix_redundant_with_name(&((prefix)[0]), plen, name, name_len) ==0)) {
            int32_t i = 0;
            while ((i < plen)) {
              if ((pos >=(out_cap - 1))) {
                break;
              }
              (void)(((out)[pos] = (prefix)[i]));
              (void)((pos = (pos + 1)));
              (void)((i = (i + 1)));
            }
          }
        }
      }
    }
    int32_t j = 0;
    while ((j < name_len)) {
      if ((pos >=(out_cap - 1))) {
        break;
      }
      (void)(((out)[pos] = (name)[j]));
      (void)((pos = (pos + 1)));
      (void)((j = (j + 1)));
    }
    if ((pos > 0)) {
      return pos;
    }
  }
  return (0 - 1);
}
int32_t glue_asm_build_func_export_sym_c(uint8_t * m, uint8_t * a, int32_t func_ix, uint8_t * out, int32_t out_cap) {
  if ((m ==0)) {
    return (0 - 1);
  }
  if ((a ==0)) {
    return (0 - 1);
  }
  if ((func_ix < 0)) {
    return (0 - 1);
  }
  if ((out ==0)) {
    return (0 - 1);
  }
  if ((out_cap <=0)) {
    return (0 - 1);
  }
  {
    int32_t fname_len = pipeline_asm_module_func_name_len_at(m, func_ix);
    if ((fname_len <=0)) {
      return (0 - 1);
    }
    if ((fname_len > 63)) {
      return (0 - 1);
    }
    uint8_t fname[64] = {};
    (void)(pipeline_asm_module_func_name_copy64(m, func_ix, &((fname)[0])));
    if ((glue_module_func_overload_count_c(m, &((fname)[0]), fname_len) <=1)) {
      int32_t pos0 = glue_asm_build_dep_export_sym_c(&((fname)[0]), fname_len, out, out_cap);
      if ((pos0 <=0)) {
        return (0 - 1);
      }
      if ((glue_asm_std_c_wrapper_fname_needs_export_c_suffix(&((fname)[0]), fname_len) !=0)) {
        (void)((pos0 = glue_asm_append_export_c_suffix(out, pos0, out_cap)));
      }
      if ((pos0 > 0)) {
        return pos0;
      }
      return (0 - 1);
    }
    int32_t pos = glue_asm_build_dep_export_sym_c(&((fname)[0]), fname_len, out, out_cap);
    if ((pos <=0)) {
      return (0 - 1);
    }
    int32_t np = pipeline_module_func_num_params_at(m, func_ix);
    int32_t pi = 0;
    while ((pi < np)) {
      int32_t pty = pipeline_module_func_param_type_ref_at(m, func_ix, pi);
      if ((pos >=(out_cap - 2))) {
        break;
      }
      if ((pty > 0)) {
        int32_t pk = pipeline_type_kind_ord_at(a, pty);
        if ((pk ==9)) {
          int32_t elem = pipeline_type_elem_ref_at(a, pty);
          if ((elem > 0)) {
            (void)((pk = pipeline_type_kind_ord_at(a, elem)));
          }
          if ((pos < (out_cap - 1))) {
            (void)(((out)[pos] = 95));
            (void)((pos = (pos + 1)));
          }
          if ((pos < (out_cap - 4))) {
            (void)(((out)[pos] = 112));
            (void)(((out)[(pos + 1)] = 116));
            (void)(((out)[(pos + 2)] = 114));
            (void)((pos = (pos + 3)));
          }
        }
        if ((pos < (out_cap - 1))) {
          (void)(((out)[pos] = 95));
          (void)((pos = (pos + 1)));
        }
        uint8_t suf[16] = {};
        int32_t sl = glue_type_kind_to_suffix_c(pk, &((suf)[0]), 16);
        if ((sl <=0)) {
          (void)((sl = glue_type_kind_to_suffix_c(0, &((suf)[0]), 16)));
        }
        if (((pos + sl) >=out_cap)) {
          return (0 - 1);
        }
        int32_t si = 0;
        while ((si < sl)) {
          (void)(((out)[pos] = (suf)[si]));
          (void)((pos = (pos + 1)));
          (void)((si = (si + 1)));
        }
      }
      (void)((pi = (pi + 1)));
    }
    if ((glue_asm_std_c_wrapper_fname_needs_export_c_suffix(&((fname)[0]), fname_len) !=0)) {
      (void)((pos = glue_asm_append_export_c_suffix(out, pos, out_cap)));
    }
    if ((pos > 0)) {
      return pos;
    }
  }
  return (0 - 1);
}
int32_t glue_asm_try_emit_fmt_string_lit_import_call_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t call_expr_ref, uint8_t * ctx, int32_t ta, uint8_t * pre_buf, int32_t pre_len, uint8_t * field_name, int32_t field_len) {
  if ((arena ==0)) {
    return 0;
  }
  if ((elf_ctx ==0)) {
    return 0;
  }
  if ((ctx ==0)) {
    return 0;
  }
  if ((call_expr_ref <=0)) {
    return 0;
  }
  if ((ta !=0)) {
    return 0;
  }
  {
    int32_t is_ln = 0;
    int32_t nargs = pipeline_expr_call_num_args_at(arena, call_expr_ref);
    int32_t arg_ref = pipeline_expr_call_arg_ref(arena, call_expr_ref, 0);
    int32_t slen = glue_asm_string_lit_len(arena, arg_ref);
    uint8_t sbuf[64] = {};
    uint8_t sym_flat[64] = {};
    int32_t sym_len = glue_asm_build_import_binding_call_sym(pre_buf, pre_len, field_name, field_len, &((sym_flat)[0]));
    if ((glue_asm_prefix_is_fmt_or_debug(pre_buf, pre_len) ==0)) {
      return 0;
    }
    if ((field_len ==7)) {
      if (((((((((field_name)[0] ==112) && ((field_name)[1] ==114)) && ((field_name)[2] ==105)) && ((field_name)[3] ==110)) && ((field_name)[4] ==116)) && ((field_name)[5] ==108)) && ((field_name)[6] ==110))) {
        (void)((is_ln = 1));
      } else {
        return 0;
      }
    } else {
      if ((field_len ==5)) {
        if (((((((field_name)[0] ==112) && ((field_name)[1] ==114)) && ((field_name)[2] ==105)) && ((field_name)[3] ==110)) && ((field_name)[4] ==116))) {
          (void)((is_ln = 0));
        } else {
          return 0;
        }
      } else {
        return 0;
      }
    }
    if ((nargs !=1)) {
      return 0;
    }
    if ((arg_ref <=0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, arg_ref) !=59)) {
      return 0;
    }
    if ((slen <=0)) {
      return (0 - 1);
    }
    if ((slen > 63)) {
      return (0 - 1);
    }
    (void)(glue_asm_string_lit_into(arena, arg_ref, &((sbuf)[0])));
    if ((sym_len <=0)) {
      return (0 - 1);
    }
    if ((is_ln ==0)) {
    }
    if ((glue_asm_emit_jmp_skip_string_then_lea(elf_ctx, ta, 0, &((sbuf)[0]), slen) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_mov_imm32_to_w0_arch(elf_ctx, slen, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) !=0)) {
      return (0 - 1);
    }
    if ((glue_asm_enc_call_redirected(elf_ctx, &((sym_flat)[0]), sym_len, ta) !=0)) {
      return (0 - 1);
    }
    return 1;
  }
  return 0;
}
int32_t glue_asm_enc_call_redirected(uint8_t * elf_ctx, uint8_t * name, int32_t name_len, int32_t ta) {
  if ((name ==0)) {
    return (0 - 1);
  }
  if ((name_len <=0)) {
    return (0 - 1);
  }
  {
    uint8_t redir[64] = {};
    int32_t rlen = glue_try_std_heap_redirect_sym_local(name, name_len, &((redir)[0]), 64);
    if ((rlen <=0)) {
      (void)((rlen = glue_try_std_string_xlang_redirect_sym_local(name, name_len, &((redir)[0]), 64)));
    }
    if ((rlen <=0)) {
      (void)((rlen = glue_try_std_encoding_redirect_sym_local(name, name_len, &((redir)[0]), 64)));
    }
    if ((rlen <=0)) {
      (void)((rlen = pipeline_asm_redirect_std_c_wrapper_sym(name, name_len, &((redir)[0]), 64)));
    }
    if ((rlen > 0)) {
      return backend_enc_call_arch(elf_ctx, &((redir)[0]), rlen, ta);
    }
    return backend_enc_call_arch(elf_ctx, name, name_len, ta);
  }
  return (0 - 1);
}
int32_t pipeline_asm_emit_call_args_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta, int32_t nargs) {
  if ((nargs < 0)) {
    return (0 - 1);
  }
  if ((nargs > 96)) {
    return (0 - 1);
  }
  {
    int32_t reg_max = glue_asm_call_reg_max(ta);
    if ((ta ==0)) {
      if ((pipeline_asm_abi_f32_xmm_enabled_c() !=0)) {
        if ((pipeline_asm_emit_call_sret_reg_shift_c() ==0)) {
          return glue_emit_call_args_elf_sysv_f32_xmm_c(arena, elf_ctx, expr_ref, ctx, ta, nargs);
        }
      }
    }
    int32_t sret_sh = 0;
    if ((ta ==0)) {
      (void)((sret_sh = pipeline_asm_emit_call_sret_reg_shift_c()));
    }
    int32_t eff_reg_max = (reg_max - sret_sh);
    int32_t n_stack = (nargs - eff_reg_max);
    if ((n_stack < 0)) {
      (void)((n_stack = 0));
    }
    if ((n_stack > 0)) {
      if ((ta ==2)) {
        return (0 - 1);
      }
    }
    int32_t stack_reserve = glue_asm_call_stack_cleanup_bytes(ta, nargs);
    if ((stack_reserve < 0)) {
      return (0 - 1);
    }
    if ((backend_enc_call_stack_reserve_arch(elf_ctx, stack_reserve, ta) !=0)) {
      return (0 - 1);
    }
    if ((ta ==0)) {
      if ((n_stack > 0)) {
        int32_t i0 = (nargs - 1);
        if (((n_stack & 1) !=0)) {
          if ((backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) !=0)) {
            return (0 - 1);
          }
          if ((backend_enc_push_rax_arch(elf_ctx, ta) !=0)) {
            return (0 - 1);
          }
        }
        while ((i0 >=eff_reg_max)) {
          int32_t arg_ref0 = pipeline_expr_call_arg_ref(arena, expr_ref, i0);
          if ((arg_ref0 !=0)) {
            if ((glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref0, i0, ctx, ta) !=0)) {
              return (0 - 1);
            }
            if ((backend_enc_push_rax_arch(elf_ctx, ta) !=0)) {
              return (0 - 1);
            }
          }
          (void)((i0 = (i0 - 1)));
        }
      }
    }
    if ((ta ==1)) {
      int32_t reg_n = nargs;
      if ((reg_n > eff_reg_max)) {
        (void)((reg_n = eff_reg_max));
      }
      int32_t i1 = (reg_n - 1);
      while ((i1 >=0)) {
        int32_t arg_ref1 = pipeline_expr_call_arg_ref(arena, expr_ref, i1);
        if ((arg_ref1 !=0)) {
          if ((glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref1, i1, ctx, ta) !=0)) {
            return (0 - 1);
          }
          if ((backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, (i1 + sret_sh), ta) !=0)) {
            return (0 - 1);
          }
        }
        (void)((i1 = (i1 - 1)));
      }
      int32_t i2 = eff_reg_max;
      while ((i2 < nargs)) {
        int32_t arg_ref2 = pipeline_expr_call_arg_ref(arena, expr_ref, i2);
        if ((arg_ref2 !=0)) {
          if ((glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref2, i2, ctx, ta) !=0)) {
            return (0 - 1);
          }
          if ((backend_enc_store_x0_sp_offset_arch(elf_ctx, ((i2 - eff_reg_max) * 8), ta) !=0)) {
            return (0 - 1);
          }
        }
        (void)((i2 = (i2 + 1)));
      }
      (void)(pipeline_asm_emit_set_call_param_type_ref(0));
      return 0;
    }
    int32_t i3 = (nargs - 1);
    while ((i3 >=0)) {
      int32_t arg_ref3 = pipeline_expr_call_arg_ref(arena, expr_ref, i3);
      if ((ta ==0)) {
        if ((i3 >=eff_reg_max)) {
          (void)((i3 = (i3 - 1)));
          continue;
        }
      }
      if ((arg_ref3 !=0)) {
        if ((glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref3, i3, ctx, ta) !=0)) {
          return (0 - 1);
        }
        if ((i3 < eff_reg_max)) {
          if ((backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, (i3 + sret_sh), ta) !=0)) {
            return (0 - 1);
          }
        }
      }
      (void)((i3 = (i3 - 1)));
    }
    (void)(pipeline_asm_emit_set_call_param_type_ref(0));
    return 0;
  }
  return (0 - 1);
}
int32_t glue_asm_emit_string_lit_ptr_rax_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t str_expr_ref, int32_t ta) {
  if ((arena ==0)) {
    return (0 - 1);
  }
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((str_expr_ref <=0)) {
    return (0 - 1);
  }
  if ((ta !=0)) {
    return (0 - 1);
  }
  {
    int32_t slen = glue_asm_string_lit_len(arena, str_expr_ref);
    uint8_t sbuf[64] = {};
    if ((pipeline_expr_kind_ord_at(arena, str_expr_ref) !=59)) {
      return (0 - 1);
    }
    if ((slen <=0)) {
      return (0 - 1);
    }
    if ((slen > 63)) {
      return (0 - 1);
    }
    (void)(glue_asm_string_lit_into(arena, str_expr_ref, &((sbuf)[0])));
    return glue_asm_emit_jmp_skip_string_then_lea(elf_ctx, ta, 1, &((sbuf)[0]), slen);
  }
  return (0 - 1);
}
int32_t glue_asm_emit_call_with_cleanup(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta, int32_t nargs, uint8_t * cname, int32_t clen) {
  {
    int32_t cleanup = glue_asm_call_stack_cleanup_bytes(ta, nargs);
    if ((pipeline_asm_emit_call_args_elf_c(arena, elf_ctx, expr_ref, ctx, ta, nargs) !=0)) {
      return (0 - 1);
    }
    if ((glue_asm_enc_call_redirected(elf_ctx, cname, clen, ta) !=0)) {
      return (0 - 1);
    }
    if ((cleanup < 0)) {
      return (0 - 1);
    }
    return backend_enc_call_stack_cleanup_arch(elf_ctx, cleanup, ta);
  }
  return (0 - 1);
}
int32_t glue_asm_call_stack_cleanup_bytes(int32_t ta, int32_t nargs) {
  if ((nargs <=0)) {
    return 0;
  }
  int32_t reg_max = glue_asm_call_reg_max(ta);
  int32_t n_stack = (nargs - reg_max);
  if ((n_stack <=0)) {
    return 0;
  }
  if ((ta ==0)) {
    int32_t bytes = (n_stack * 8);
    if (((n_stack & 1) !=0)) {
      (void)((bytes = (bytes + 8)));
    }
    return bytes;
  }
  if ((ta ==2)) {
    return -(1);
  }
  return (((n_stack * 8) + 15) & -(16));
}
extern void asm_qual_sym_layer_reset(void);
extern int32_t asm_qual_sym_layer_push(uint8_t * bytes, int32_t len);
extern int32_t asm_qual_sym_layer_count(void);
extern int32_t asm_qual_sym_layer_len(int32_t i);
extern void asm_qual_sym_layer_copy(int32_t i, uint8_t * dst, int32_t cap);
extern int32_t pipeline_expr_field_access_name_len(uint8_t * arena, int32_t er);
extern void pipeline_expr_field_access_name_into(uint8_t * arena, int32_t er, uint8_t * out);
extern int32_t pipeline_expr_field_access_base_ref(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_call_callee_ref_at(uint8_t * arena, int32_t er);
extern int32_t pipeline_module_import_kind_at(uint8_t * m, int32_t j);
extern int32_t pipeline_codegen_call_num_args_override(uint8_t * pre, int32_t plen, uint8_t * field, int32_t flen, int32_t nargs);
extern int32_t try_inline_param0_single_field_call_elf(uint8_t * a, uint8_t * elf, int32_t er, uint8_t * ctx, int32_t ta);
extern int32_t try_inline_param0_field_sum_call_elf(uint8_t * a, uint8_t * elf, int32_t er, uint8_t * ctx, int32_t ta);
extern int32_t try_inline_x_plus_k_call_elf(uint8_t * a, uint8_t * elf, int32_t er, uint8_t * ctx, int32_t ta);
extern int32_t try_call_wpo_mono_symbol_elf(uint8_t * a, uint8_t * elf, int32_t er, uint8_t * ctx, int32_t ta);
extern int32_t try_call_wpo_mono_vector_lane_of_binop_call_elf(uint8_t * a, uint8_t * elf, int32_t er, uint8_t * ctx, int32_t ta);
extern int32_t try_inline_wpo_const_vector_lane_of_binop_call_elf(uint8_t * a, uint8_t * elf, int32_t er, uint8_t * ctx, int32_t ta);
extern int32_t try_inline_wpo_const_scalar_binop_call_elf(uint8_t * a, uint8_t * elf, int32_t er, uint8_t * ctx, int32_t ta);
extern int32_t pipeline_expr_method_call_base_ref_at(uint8_t * a, int32_t er);
extern int32_t pipeline_expr_method_call_num_args_at(uint8_t * a, int32_t er);
extern int32_t pipeline_expr_method_call_name_len(uint8_t * a, int32_t er);
extern void pipeline_expr_method_call_name_into(uint8_t * a, int32_t er, uint8_t * out);
extern int32_t pipeline_expr_method_call_arg_ref(uint8_t * a, int32_t er, int32_t idx);
extern int32_t pipeline_asm_emit_expr_c(uint8_t * arena, uint8_t * out, int32_t er, uint8_t * ctx, int32_t ta);
extern int32_t backend_arch_emit_mov_rax_to_arg_reg(uint8_t * out, int32_t i, int32_t ta);
extern int32_t backend_arch_emit_push_rax(uint8_t * out, int32_t ta);
extern int32_t backend_arch_emit_ldr_sp_offset_to_wi(uint8_t * out, int32_t i, int32_t ta);
extern int32_t backend_arch_emit_add_sp_imm(uint8_t * out, int32_t imm, int32_t ta);
int32_t pipeline_asm_resolve_whole_import_qualified_symbol_c(uint8_t * arena, uint8_t * cur_mod, int32_t callee_expr_ref, uint8_t * sym_flat, int32_t * out_match_imp_j) {
  if ((arena ==0)) {
    return (0 - 1);
  }
  if ((cur_mod ==0)) {
    return (0 - 1);
  }
  if ((sym_flat ==0)) {
    return (0 - 1);
  }
  if ((callee_expr_ref <=0)) {
    return (0 - 1);
  }
  {
    int32_t cur_ref = callee_expr_ref;
    int32_t nstack = asm_qual_sym_layer_count();
    int32_t vnlen = pipeline_expr_var_name_len(arena, cur_ref);
    uint8_t vname_buf[64] = {};
    int32_t dep_j = 0;
    int32_t nimp = parser_get_module_num_imports(cur_mod);
    if ((pipeline_expr_kind_ord_at(arena, callee_expr_ref) !=44)) {
      return (0 - 1);
    }
    (void)(asm_qual_sym_layer_reset());
    while ((1 ==1)) {
      int32_t falen = pipeline_expr_field_access_name_len(arena, cur_ref);
      uint8_t layer_buf[64] = {};
      if ((cur_ref <=0)) {
        return (0 - 1);
      }
      if ((pipeline_expr_kind_ord_at(arena, cur_ref) !=44)) {
        break;
      }
      if ((falen <=0)) {
        break;
      }
      if ((falen > 63)) {
        break;
      }
      (void)(pipeline_expr_field_access_name_into(arena, cur_ref, &((layer_buf)[0])));
      if ((asm_qual_sym_layer_push(&((layer_buf)[0]), falen) < 0)) {
        return (0 - 1);
      }
      (void)((cur_ref = pipeline_expr_field_access_base_ref(arena, cur_ref)));
    }
    if ((cur_ref <=0)) {
      return (0 - 1);
    }
    if ((pipeline_expr_kind_ord_at(arena, cur_ref) !=3)) {
      return (0 - 1);
    }
    if ((vnlen <=0)) {
      return (0 - 1);
    }
    if ((vnlen > 63)) {
      return (0 - 1);
    }
    (void)(pipeline_expr_var_name_into(arena, cur_ref, &((vname_buf)[0])));
    while ((dep_j < nimp)) {
      int32_t plen = pipeline_module_import_path_len(cur_mod, dep_j);
      if ((plen <=0)) {
        (void)((dep_j = (dep_j + 1)));
        continue;
      }
      if ((plen > 63)) {
        (void)((dep_j = (dep_j + 1)));
        continue;
      }
      uint8_t path_cnt_buf[64] = {};
      int32_t pci = 0;
      while ((pci < plen)) {
        if ((pci >=64)) {
          break;
        }
        (void)(((path_cnt_buf)[pci] = pipeline_module_import_path_byte_at_u8_ptr_i32_i32_retu8(cur_mod, dep_j, pci)));
        (void)((pci = (pci + 1)));
      }
      int32_t pseg = glue_asm_import_path_segment_count(&((path_cnt_buf)[0]), plen);
      if ((pseg <=0)) {
        (void)((dep_j = (dep_j + 1)));
        continue;
      }
      if ((nstack !=pseg)) {
        (void)((dep_j = (dep_j + 1)));
        continue;
      }
      int32_t s0_rel = 0;
      int32_t s0_ln = 0;
      if ((glue_asm_import_segment_at(cur_mod, dep_j, 0, &(s0_rel), &(s0_ln)) ==0)) {
        (void)((dep_j = (dep_j + 1)));
        continue;
      }
      if ((glue_asm_import_path_slice_equal(cur_mod, dep_j, s0_rel, s0_ln, &((vname_buf)[0]), vnlen) ==0)) {
        (void)((dep_j = (dep_j + 1)));
        continue;
      }
      int32_t bad_mid = 0;
      int32_t sm = 1;
      while ((sm <=(pseg - 1))) {
        int32_t srv = 0;
        int32_t slv = 0;
        if ((glue_asm_import_segment_at(cur_mod, dep_j, sm, &(srv), &(slv)) ==0)) {
          (void)((bad_mid = 1));
          break;
        }
        int32_t lay_ix = (pseg - sm);
        uint8_t layer_mid[64] = {};
        (void)(asm_qual_sym_layer_copy(lay_ix, &((layer_mid)[0]), 64));
        if ((glue_asm_import_path_slice_equal(cur_mod, dep_j, srv, slv, &((layer_mid)[0]), asm_qual_sym_layer_len(lay_ix)) ==0)) {
          (void)((bad_mid = 1));
          break;
        }
        (void)((sm = (sm + 1)));
      }
      if ((bad_mid !=0)) {
        (void)((dep_j = (dep_j + 1)));
        continue;
      }
      uint8_t pre_buf[128] = {};
      int32_t pre_len = glue_asm_fill_c_prefix_from_module_import(cur_mod, dep_j, &((pre_buf)[0]));
      if ((pre_len <=0)) {
        (void)((dep_j = (dep_j + 1)));
        continue;
      }
      uint8_t layer0[64] = {};
      (void)(asm_qual_sym_layer_copy(0, &((layer0)[0]), 64));
      int32_t blt = glue_asm_build_import_binding_call_sym(&((pre_buf)[0]), pre_len, &((layer0)[0]), asm_qual_sym_layer_len(0), sym_flat);
      if ((out_match_imp_j !=0)) {
        (void)(((out_match_imp_j)[0] = dep_j));
      }
      return blt;
    }
  }
  return (0 - 1);
}
int32_t pipeline_asm_emit_call_args_text_c(uint8_t * arena, uint8_t * out, int32_t expr_ref, uint8_t * ctx, int32_t target_arch, int32_t nargs) {
  if ((arena ==0)) {
    return (0 - 1);
  }
  if ((out ==0)) {
    return (0 - 1);
  }
  if ((ctx ==0)) {
    return (0 - 1);
  }
  if ((expr_ref <=0)) {
    return (0 - 1);
  }
  if ((nargs < 0)) {
    return (0 - 1);
  }
  if ((nargs > 6)) {
    return (0 - 1);
  }
  if ((nargs <=0)) {
    return 0;
  }
  {
    int32_t i = 0;
    while ((i < nargs)) {
      int32_t arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
      if ((arg_ref !=0)) {
        if ((pipeline_asm_emit_expr_c(arena, out, arg_ref, ctx, target_arch) !=0)) {
          return (0 - 1);
        }
        if ((target_arch ==0)) {
          if ((backend_arch_emit_mov_rax_to_arg_reg(out, i, target_arch) !=0)) {
            return (0 - 1);
          }
        } else {
          if ((target_arch ==2)) {
            if ((backend_arch_emit_mov_rax_to_arg_reg(out, i, target_arch) !=0)) {
              return (0 - 1);
            }
          } else {
            if ((backend_arch_emit_push_rax(out, target_arch) !=0)) {
              return (0 - 1);
            }
          }
        }
      }
      (void)((i = (i + 1)));
    }
    if ((target_arch ==1)) {
      (void)((i = 0));
      while ((i < nargs)) {
        if ((backend_arch_emit_ldr_sp_offset_to_wi(out, i, target_arch) !=0)) {
          return (0 - 1);
        }
        (void)((i = (i + 1)));
      }
      if ((backend_arch_emit_add_sp_imm(out, (nargs * 16), target_arch) !=0)) {
        return (0 - 1);
      }
    }
    return 0;
  }
  return (0 - 1);
}
int32_t pipeline_asm_emit_method_call_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  if ((arena ==0)) {
    return (0 - 1);
  }
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((ctx ==0)) {
    return (0 - 1);
  }
  {
    uint8_t * mod_ref = call_dispatch_load_ptr_le(ctx, 16);
    int32_t nargs = pipeline_expr_method_call_num_args_at(arena, expr_ref);
    if ((nargs > 5)) {
      return (0 - 1);
    }
    int32_t base_ref = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    int32_t name_len = pipeline_expr_method_call_name_len(arena, expr_ref);
    if ((name_len <=0)) {
      return (0 - 1);
    }
    if ((name_len > 63)) {
      return (0 - 1);
    }
    uint8_t name[64] = {};
    (void)(pipeline_expr_method_call_name_into(arena, expr_ref, &((name)[0])));
    if ((mod_ref !=0)) {
      if ((base_ref > 0)) {
        if ((pipeline_expr_kind_ord_at(arena, base_ref) ==3)) {
          int32_t base_len = pipeline_expr_var_name_len(arena, base_ref);
          if ((base_len > 0)) {
            if ((base_len <=63)) {
              uint8_t base_name[64] = {};
              (void)(pipeline_expr_var_name_into(arena, base_ref, &((base_name)[0])));
              int32_t j = 0;
              int32_t nimp = parser_get_module_num_imports(mod_ref);
              while ((j < nimp)) {
                if ((pipeline_module_import_kind_at(mod_ref, j) ==1)) {
                  if ((glue_asm_import_binding_name_equal(mod_ref, j, &((base_name)[0]), base_len) !=0)) {
                    uint8_t pre_buf[128] = {};
                    int32_t pre_len = glue_asm_fill_c_prefix_from_module_import(mod_ref, j, &((pre_buf)[0]));
                    if ((pre_len <=0)) {
                      return (0 - 1);
                    }
                    uint8_t sym_flat[64] = {};
                    int32_t sym_len = glue_asm_build_import_binding_call_sym(&((pre_buf)[0]), pre_len, &((name)[0]), name_len, &((sym_flat)[0]));
                    if ((sym_len <=0)) {
                      return (0 - 1);
                    }
                    int32_t n_ov = pipeline_codegen_call_num_args_override(&((pre_buf)[0]), pre_len, &((name)[0]), name_len, nargs);
                    if ((ta ==1)) {
                      int32_t i = (nargs - 1);
                      while ((i >=0)) {
                        int32_t arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, i);
                        if ((arg_ref !=0)) {
                          if ((glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref, i, ctx, ta) !=0)) {
                            return (0 - 1);
                          }
                          if ((backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, i, ta) !=0)) {
                            return (0 - 1);
                          }
                        }
                        (void)((i = (i - 1)));
                      }
                    } else {
                      int32_t i2 = 0;
                      while ((i2 < nargs)) {
                        int32_t arg_ref2 = pipeline_expr_method_call_arg_ref(arena, expr_ref, i2);
                        if ((i2 >=6)) {
                          break;
                        }
                        if ((arg_ref2 !=0)) {
                          if ((glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref2, i2, ctx, ta) !=0)) {
                            return (0 - 1);
                          }
                          if ((backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, i2, ta) !=0)) {
                            return (0 - 1);
                          }
                        }
                        (void)((i2 = (i2 + 1)));
                      }
                    }
                    if ((glue_asm_enc_call_redirected(elf_ctx, &((sym_flat)[0]), sym_len, ta) !=0)) {
                      return (0 - 1);
                    }
                    int32_t cln = glue_asm_call_stack_cleanup_bytes(ta, n_ov);
                    if ((cln < 0)) {
                      return (0 - 1);
                    }
                    if ((backend_enc_call_stack_cleanup_arch(elf_ctx, cln, ta) !=0)) {
                      return (0 - 1);
                    }
                    return 0;
                  }
                }
                (void)((j = (j + 1)));
              }
            }
          }
        }
      }
    }
    if ((base_ref !=0)) {
      if ((pipeline_asm_emit_expr_elf_for_call_args(arena, elf_ctx, base_ref, ctx, ta) !=0)) {
        return (0 - 1);
      }
      if ((ta !=1)) {
        if ((backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) !=0)) {
          return (0 - 1);
        }
      }
    }
    if ((ta ==1)) {
      int32_t i3 = (nargs - 1);
      while ((i3 >=0)) {
        int32_t arg_ref3 = pipeline_expr_method_call_arg_ref(arena, expr_ref, i3);
        if ((arg_ref3 !=0)) {
          if ((glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref3, i3, ctx, ta) !=0)) {
            return (0 - 1);
          }
          if ((backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, (i3 + 1), ta) !=0)) {
            return (0 - 1);
          }
        }
        (void)((i3 = (i3 - 1)));
      }
    } else {
      int32_t i4 = 0;
      while ((i4 < nargs)) {
        int32_t arg_ref4 = pipeline_expr_method_call_arg_ref(arena, expr_ref, i4);
        if ((i4 >=6)) {
          break;
        }
        if ((arg_ref4 !=0)) {
          if ((glue_emit_one_call_arg_elf_c(arena, elf_ctx, expr_ref, arg_ref4, i4, ctx, ta) !=0)) {
            return (0 - 1);
          }
          if ((backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, (i4 + 1), ta) !=0)) {
            return (0 - 1);
          }
        }
        (void)((i4 = (i4 + 1)));
      }
    }
    return glue_asm_enc_call_redirected(elf_ctx, &((name)[0]), name_len, ta);
  }
  return (0 - 1);
}
int32_t pipeline_asm_emit_call_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  if ((arena ==0)) {
    return (0 - 1);
  }
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((ctx ==0)) {
    return (0 - 1);
  }
  {
    int32_t callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    if ((callee_ref <=0)) {
      return (0 - 1);
    }
    uint8_t * mod_ref = call_dispatch_load_ptr_le(ctx, 16);
    uint8_t * dep_pipe = call_dispatch_load_ptr_le(ctx, 1256);
    int32_t callee_ko = pipeline_expr_kind_ord_at(arena, callee_ref);
    if ((callee_ko ==44)) {
      uint8_t pre_fmt[16] = {};
      (void)(((pre_fmt)[0] = 115));
      (void)(((pre_fmt)[1] = 116));
      (void)(((pre_fmt)[2] = 100));
      (void)(((pre_fmt)[3] = 95));
      (void)(((pre_fmt)[4] = 102));
      (void)(((pre_fmt)[5] = 109));
      (void)(((pre_fmt)[6] = 116));
      (void)(((pre_fmt)[7] = 95));
      uint8_t fn_println[16] = {};
      (void)(((fn_println)[0] = 112));
      (void)(((fn_println)[1] = 114));
      (void)(((fn_println)[2] = 105));
      (void)(((fn_println)[3] = 110));
      (void)(((fn_println)[4] = 116));
      (void)(((fn_println)[5] = 108));
      (void)(((fn_println)[6] = 110));
      int32_t fa_lit = glue_asm_try_emit_fmt_string_lit_import_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta, &((pre_fmt)[0]), 8, &((fn_println)[0]), 7);
      if ((fa_lit < 0)) {
        return (0 - 1);
      }
      if ((fa_lit > 0)) {
        return 0;
      }
      uint8_t fn_print[16] = {};
      (void)(((fn_print)[0] = 112));
      (void)(((fn_print)[1] = 114));
      (void)(((fn_print)[2] = 105));
      (void)(((fn_print)[3] = 110));
      (void)(((fn_print)[4] = 116));
      (void)((fa_lit = glue_asm_try_emit_fmt_string_lit_import_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta, &((pre_fmt)[0]), 8, &((fn_print)[0]), 5)));
      if ((fa_lit < 0)) {
        return (0 - 1);
      }
      if ((fa_lit > 0)) {
        return 0;
      }
    }
    if ((mod_ref !=0)) {
      if ((callee_ko ==44)) {
        int32_t base_ref = pipeline_expr_field_access_base_ref(arena, callee_ref);
        if ((base_ref > 0)) {
          if ((pipeline_expr_kind_ord_at(arena, base_ref) ==3)) {
            int32_t base_len = pipeline_expr_var_name_len(arena, base_ref);
            if ((base_len > 0)) {
              if ((base_len <=63)) {
                uint8_t base_name[64] = {};
                (void)(pipeline_expr_var_name_into(arena, base_ref, &((base_name)[0])));
                int32_t field_len = pipeline_expr_field_access_name_len(arena, callee_ref);
                if ((field_len > 0)) {
                  if ((field_len <=63)) {
                    uint8_t field_name[64] = {};
                    (void)(pipeline_expr_field_access_name_into(arena, callee_ref, &((field_name)[0])));
                    int32_t j = 0;
                    int32_t nimp = parser_get_module_num_imports(mod_ref);
                    while ((j < nimp)) {
                      if ((pipeline_module_import_kind_at(mod_ref, j) ==1)) {
                        if ((glue_asm_import_binding_name_equal(mod_ref, j, &((base_name)[0]), base_len) !=0)) {
                          uint8_t pre_buf[128] = {};
                          int32_t pre_len = glue_asm_fill_c_prefix_from_module_import(mod_ref, j, &((pre_buf)[0]));
                          if ((pre_len <=0)) {
                            return (0 - 1);
                          }
                          uint8_t sym_flat[64] = {};
                          int32_t sym_len = glue_asm_build_import_binding_call_sym(&((pre_buf)[0]), pre_len, &((field_name)[0]), field_len, &((sym_flat)[0]));
                          if ((sym_len <=0)) {
                            return (0 - 1);
                          }
                          int32_t fmt_lit = glue_asm_try_emit_fmt_string_lit_import_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta, &((pre_buf)[0]), pre_len, &((field_name)[0]), field_len);
                          if ((fmt_lit < 0)) {
                            return (0 - 1);
                          }
                          if ((fmt_lit > 0)) {
                            return 0;
                          }
                          int32_t call_nargs = pipeline_expr_call_num_args_at(arena, expr_ref);
                          int32_t n_ov = pipeline_codegen_call_num_args_override(&((pre_buf)[0]), pre_len, &((field_name)[0]), field_len, call_nargs);
                          if ((pipeline_asm_emit_call_args_elf_c(arena, elf_ctx, expr_ref, ctx, ta, n_ov) !=0)) {
                            return (0 - 1);
                          }
                          if ((glue_asm_enc_call_redirected(elf_ctx, &((sym_flat)[0]), sym_len, ta) !=0)) {
                            return (0 - 1);
                          }
                          int32_t cln = glue_asm_call_stack_cleanup_bytes(ta, n_ov);
                          if ((cln < 0)) {
                            return (0 - 1);
                          }
                          if ((backend_enc_call_stack_cleanup_arch(elf_ctx, cln, ta) !=0)) {
                            return (0 - 1);
                          }
                          return 0;
                        }
                      }
                      (void)((j = (j + 1)));
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    if ((mod_ref !=0)) {
      if ((callee_ko ==44)) {
        int32_t imp_elt = 0;
        uint8_t sym_eh[64] = {};
        int32_t elen = pipeline_asm_resolve_whole_import_qualified_symbol_c(arena, mod_ref, callee_ref, &((sym_eh)[0]), &(imp_elt));
        if ((elen > 0)) {
          if ((imp_elt >=0)) {
            if ((imp_elt < parser_get_module_num_imports(mod_ref))) {
              int32_t field_len2 = pipeline_expr_field_access_name_len(arena, callee_ref);
              if ((field_len2 <=0)) {
                return (0 - 1);
              }
              if ((field_len2 > 63)) {
                return (0 - 1);
              }
              uint8_t field_name2[64] = {};
              (void)(pipeline_expr_field_access_name_into(arena, callee_ref, &((field_name2)[0])));
              uint8_t pre_eb[128] = {};
              int32_t pre_el = glue_asm_fill_c_prefix_from_module_import(mod_ref, imp_elt, &((pre_eb)[0]));
              if ((pre_el <=0)) {
                return (0 - 1);
              }
              int32_t call_nargs2 = pipeline_expr_call_num_args_at(arena, expr_ref);
              int32_t n_wo_elf = pipeline_codegen_call_num_args_override(&((pre_eb)[0]), pre_el, &((field_name2)[0]), field_len2, call_nargs2);
              if ((pipeline_asm_emit_call_args_elf_c(arena, elf_ctx, expr_ref, ctx, ta, n_wo_elf) !=0)) {
                return (0 - 1);
              }
              if ((glue_asm_enc_call_redirected(elf_ctx, &((sym_eh)[0]), elen, ta) !=0)) {
                return (0 - 1);
              }
              int32_t cln2 = glue_asm_call_stack_cleanup_bytes(ta, n_wo_elf);
              if ((cln2 < 0)) {
                return (0 - 1);
              }
              if ((backend_enc_call_stack_cleanup_arch(elf_ctx, cln2, ta) !=0)) {
                return (0 - 1);
              }
              return 0;
            }
          }
        }
      }
    }
    if ((callee_ko !=3)) {
      return (0 - 1);
    }
    int32_t nargs = pipeline_expr_call_num_args_at(arena, expr_ref);
    if ((nargs < 0)) {
      return (0 - 1);
    }
    if ((nargs > 96)) {
      return (0 - 1);
    }
    int32_t inline_rc = try_inline_param0_single_field_call_elf(arena, elf_ctx, expr_ref, ctx, ta);
    if ((inline_rc !=0)) {
      if ((inline_rc < 0)) {
        return (0 - 1);
      }
      return 0;
    }
    (void)((inline_rc = try_inline_param0_field_sum_call_elf(arena, elf_ctx, expr_ref, ctx, ta)));
    if ((inline_rc !=0)) {
      if ((inline_rc < 0)) {
        return (0 - 1);
      }
      return 0;
    }
    (void)((inline_rc = try_inline_x_plus_k_call_elf(arena, elf_ctx, expr_ref, ctx, ta)));
    if ((inline_rc !=0)) {
      if ((inline_rc < 0)) {
        return (0 - 1);
      }
      return 0;
    }
    (void)((inline_rc = try_call_wpo_mono_symbol_elf(arena, elf_ctx, expr_ref, ctx, ta)));
    if ((inline_rc !=0)) {
      if ((inline_rc < 0)) {
        return (0 - 1);
      }
      return 0;
    }
    (void)((inline_rc = try_call_wpo_mono_vector_lane_of_binop_call_elf(arena, elf_ctx, expr_ref, ctx, ta)));
    if ((inline_rc !=0)) {
      if ((inline_rc < 0)) {
        return (0 - 1);
      }
      return 0;
    }
    uint8_t kmono[16] = {};
    (void)(((kmono)[0] = 83));
    (void)(((kmono)[1] = 72));
    (void)(((kmono)[2] = 85));
    (void)(((kmono)[3] = 88));
    (void)(((kmono)[4] = 95));
    (void)(((kmono)[5] = 87));
    (void)(((kmono)[6] = 80));
    (void)(((kmono)[7] = 79));
    (void)(((kmono)[8] = 95));
    (void)(((kmono)[9] = 77));
    (void)(((kmono)[10] = 79));
    (void)(((kmono)[11] = 78));
    (void)(((kmono)[12] = 79));
    (void)(((kmono)[13] = 0));
    uint8_t knofold[20] = {};
    (void)(((knofold)[0] = 83));
    (void)(((knofold)[1] = 72));
    (void)(((knofold)[2] = 85));
    (void)(((knofold)[3] = 88));
    (void)(((knofold)[4] = 95));
    (void)(((knofold)[5] = 87));
    (void)(((knofold)[6] = 80));
    (void)(((knofold)[7] = 79));
    (void)(((knofold)[8] = 95));
    (void)(((knofold)[9] = 78));
    (void)(((knofold)[10] = 79));
    (void)(((knofold)[11] = 95));
    (void)(((knofold)[12] = 70));
    (void)(((knofold)[13] = 79));
    (void)(((knofold)[14] = 76));
    (void)(((knofold)[15] = 68));
    (void)(((knofold)[16] = 0));
    /* wave231 G.7: XLANG_WPO_MONO / XLANG_WPO_NO_FOLD via link_abi_getenv (not raw getenv). */
    if ((link_abi_getenv((const char *)&((kmono)[0])) ==0)) {
      if ((link_abi_getenv((const char *)&((knofold)[0])) ==0)) {
        (void)((inline_rc = try_inline_wpo_const_vector_lane_of_binop_call_elf(arena, elf_ctx, expr_ref, ctx, ta)));
        if ((inline_rc !=0)) {
          if ((inline_rc < 0)) {
            return (0 - 1);
          }
          return 0;
        }
        (void)((inline_rc = try_inline_wpo_const_scalar_binop_call_elf(arena, elf_ctx, expr_ref, ctx, ta)));
        if ((inline_rc !=0)) {
          if ((inline_rc < 0)) {
            return (0 - 1);
          }
          return 0;
        }
      }
    }
    int32_t clen0 = pipeline_expr_var_name_len(arena, callee_ref);
    if ((clen0 <=0)) {
      return (0 - 1);
    }
    if ((clen0 > 63)) {
      return (0 - 1);
    }
    uint8_t cname[64] = {};
    int32_t clen = glue_asm_build_call_export_sym_c(arena, expr_ref, callee_ref, mod_ref, dep_pipe, &((cname)[0]), 64);
    if ((clen <=0)) {
      return (0 - 1);
    }
    return glue_asm_emit_call_with_cleanup(arena, elf_ctx, expr_ref, ctx, ta, nargs, &((cname)[0]), clen);
  }
  return (0 - 1);
}
int32_t glue_asm_prefix_is_fmt_or_debug(uint8_t * pre, int32_t pre_len) {
  if ((pre ==0)) {
    return 0;
  }
  if ((pre_len < 8)) {
    return 0;
  }
  if ((pre_len >=8)) {
    if ((((((((((pre)[0] ==115) && ((pre)[1] ==116)) && ((pre)[2] ==100)) && ((pre)[3] ==95)) && ((pre)[4] ==102)) && ((pre)[5] ==109)) && ((pre)[6] ==116)) && ((pre)[7] ==95))) {
      return 1;
    }
  }
  if ((pre_len >=10)) {
    if ((((((((((((pre)[0] ==115) && ((pre)[1] ==116)) && ((pre)[2] ==100)) && ((pre)[3] ==95)) && ((pre)[4] ==100)) && ((pre)[5] ==101)) && ((pre)[6] ==98)) && ((pre)[7] ==117)) && ((pre)[8] ==103)) && ((pre)[9] ==95))) {
      return 1;
    }
  }
  return 0;
}
int32_t glue_call_param_is_f32_c(uint8_t * arena, int32_t tr) {
  if ((arena ==0)) {
    return 0;
  }
  if ((tr <=0)) {
    return 0;
  }
  {
    int32_t k = pipeline_type_kind_ord_at(arena, tr);
    if ((k ==14)) {
      return 1;
    }
  }
  return 0;
}
int32_t glue_asm_std_c_wrapper_fname_needs_export_c_suffix(uint8_t * fname, int32_t nlen) {
  if ((fname ==0)) {
    return 0;
  }
  if ((nlen <=0)) {
    return 0;
  }
  if ((nlen >=2)) {
    if (((fname)[(nlen - 2)] ==95)) {
      if (((fname)[(nlen - 1)] ==99)) {
        return 0;
      }
    }
  }
  if ((nlen >=4)) {
    if ((((((fname)[0] ==110) && ((fname)[1] ==101)) && ((fname)[2] ==116)) && ((fname)[3] ==95))) {
      return 1;
    }
  }
  if ((nlen >=3)) {
    if (((((fname)[0] ==102) && ((fname)[1] ==115)) && ((fname)[2] ==95))) {
      return 1;
    }
  }
  return 0;
}
int32_t glue_asm_append_export_c_suffix(uint8_t * sym, int32_t slen, int32_t cap) {
  if ((sym ==0)) {
    return slen;
  }
  if ((slen <=0)) {
    return slen;
  }
  if (((slen + 2) >=cap)) {
    return slen;
  }
  (void)(((sym)[slen] = 95));
  (void)(((sym)[(slen + 1)] = 99));
  return (slen + 2);
}
int32_t glue_asm_import_path_segment_count(uint8_t * path, int32_t plen) {
  if ((path ==0)) {
    return 0;
  }
  if ((plen <=0)) {
    return 0;
  }
  int32_t n = 1;
  int32_t ii = 0;
  while ((ii < plen)) {
    if (((path)[ii] ==46)) {
      (void)((n = (n + 1)));
    }
    (void)((ii = (ii + 1)));
  }
  return n;
}
extern uint8_t pipeline_module_import_path_byte_at_u8_ptr_i32_i32_retu8(uint8_t * mod, int32_t ix, int32_t off);
extern int32_t pipeline_module_import_binding_name_len(uint8_t * mod, int32_t ix);
extern uint8_t pipeline_module_import_binding_name_byte_at(uint8_t * mod, int32_t ix, int32_t i);
int32_t glue_asm_c_prefix_redundant_with_name(uint8_t * pre, int32_t plen, uint8_t * name, int32_t nlen) {
  if ((pre ==0)) {
    return 0;
  }
  if ((name ==0)) {
    return 0;
  }
  if ((plen !=6)) {
    return 0;
  }
  if ((nlen < plen)) {
    return 0;
  }
  if (((pre)[0] !=98)) {
    return 0;
  }
  if (((pre)[1] !=117)) {
    return 0;
  }
  if (((pre)[2] !=105)) {
    return 0;
  }
  if (((pre)[3] !=108)) {
    return 0;
  }
  if (((pre)[4] !=100)) {
    return 0;
  }
  if (((pre)[5] !=95)) {
    return 0;
  }
  int32_t i = 0;
  while ((i < plen)) {
    if (((name)[i] !=(pre)[i])) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
int32_t glue_type_kind_to_suffix_c(int32_t kind, uint8_t * out, int32_t cap) {
  if ((out ==0)) {
    return 0;
  }
  if ((cap <=0)) {
    return 0;
  }
  uint8_t s0 = 105;
  uint8_t s1 = 51;
  uint8_t s2 = 50;
  uint8_t s3 = 0;
  uint8_t s4 = 0;
  int32_t slen = 3;
  if ((kind ==5)) {
    (void)((s0 = 105));
    (void)((s1 = 54));
    (void)((s2 = 52));
    (void)((slen = 3));
  } else {
    if ((kind ==2)) {
      (void)((s0 = 117));
      (void)((s1 = 56));
      (void)((slen = 2));
    } else {
      if ((kind ==3)) {
        (void)((s0 = 117));
        (void)((s1 = 51));
        (void)((s2 = 50));
        (void)((slen = 3));
      } else {
        if ((kind ==4)) {
          (void)((s0 = 117));
          (void)((s1 = 54));
          (void)((s2 = 52));
          (void)((slen = 3));
        } else {
          if ((kind ==6)) {
            (void)((s0 = 117));
            (void)((s1 = 115));
            (void)((s2 = 105));
            (void)((s3 = 122));
            (void)((s4 = 101));
            (void)((slen = 5));
          } else {
            if ((kind ==7)) {
              (void)((s0 = 105));
              (void)((s1 = 115));
              (void)((s2 = 105));
              (void)((s3 = 122));
              (void)((s4 = 101));
              (void)((slen = 5));
            } else {
              if ((kind ==14)) {
                (void)((s0 = 102));
                (void)((s1 = 51));
                (void)((s2 = 50));
                (void)((slen = 3));
              } else {
                if ((kind ==15)) {
                  (void)((s0 = 102));
                  (void)((s1 = 54));
                  (void)((s2 = 52));
                  (void)((slen = 3));
                } else {
                  if ((kind ==1)) {
                    (void)((s0 = 98));
                    (void)((s1 = 111));
                    (void)((s2 = 111));
                    (void)((s3 = 108));
                    (void)((slen = 4));
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  int32_t i = 0;
  while ((i < slen)) {
    if ((i >=(cap - 1))) {
      break;
    }
    if ((i ==0)) {
      (void)(((out)[i] = s0));
    }
    if ((i ==1)) {
      (void)(((out)[i] = s1));
    }
    if ((i ==2)) {
      (void)(((out)[i] = s2));
    }
    if ((i ==3)) {
      (void)(((out)[i] = s3));
    }
    if ((i ==4)) {
      (void)(((out)[i] = s4));
    }
    (void)((i = (i + 1)));
  }
  return slen;
}
int32_t glue_asm_import_path_slice_equal(uint8_t * mod, int32_t ix, int32_t off, int32_t slen, uint8_t * nm, int32_t nm_len) {
  if ((slen !=nm_len)) {
    return 0;
  }
  if ((slen <=0)) {
    return 0;
  }
  if ((nm ==0)) {
    return 0;
  }
  int32_t i = 0;
  while ((i < slen)) {
    {
      uint8_t b = pipeline_module_import_path_byte_at_u8_ptr_i32_i32_retu8(mod, ix, (off + i));
      if ((b !=(nm)[i])) {
        return 0;
      }
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
int32_t glue_asm_import_binding_name_equal(uint8_t * mod, int32_t ix, uint8_t * nm, int32_t nlen) {
  if ((nm ==0)) {
    return 0;
  }
  if ((nlen <=0)) {
    return 0;
  }
  {
    int32_t bl = pipeline_module_import_binding_name_len(mod, ix);
    if ((bl !=nlen)) {
      return 0;
    }
    int32_t i = 0;
    while ((i < nlen)) {
      uint8_t b = pipeline_module_import_binding_name_byte_at(mod, ix, i);
      if ((b !=(nm)[i])) {
        return 0;
      }
      (void)((i = (i + 1)));
    }
  }
  return 1;
}
int32_t glue_sysv_x86_call_n_stack_c(uint8_t * arena, int32_t call, int32_t nargs) {
  int32_t gp = 0;
  int32_t xmm = 0;
  int32_t stk = 0;
  int32_t j = 0;
  while ((j < nargs)) {
    int32_t pty = glue_call_param_type_ref_at(arena, call, j);
    int32_t is_f = glue_call_param_is_f32_c(arena, pty);
    if ((is_f !=0)) {
      if ((xmm < 8)) {
        (void)((xmm = (xmm + 1)));
      } else {
        (void)((stk = (stk + 1)));
      }
    } else {
      if ((gp < 6)) {
        (void)((gp = (gp + 1)));
      } else {
        (void)((stk = (stk + 1)));
      }
    }
    (void)((j = (j + 1)));
  }
  return stk;
}
int32_t glue_asm_string_lit_len(uint8_t * arena, int32_t er) {
  if ((arena ==0)) {
    return 0;
  }
  if ((er <=0)) {
    return 0;
  }
  {
    int32_t k = pipeline_expr_kind_ord_at(arena, er);
    if ((k !=59)) {
      return 0;
    }
    return pipeline_expr_var_name_len_for_string_lit_c(arena, er);
  }
  return 0;
}
int32_t glue_asm_build_import_binding_call_sym(uint8_t * pre, int32_t plen, uint8_t * field, int32_t flen, uint8_t * out) {
  if ((out ==0)) {
    return (0 - 1);
  }
  int32_t pos = 0;
  int32_t skip_pre = 0;
  if ((plen > 0)) {
    if ((glue_asm_c_prefix_redundant_with_name(pre, plen, field, flen) !=0)) {
      (void)((skip_pre = 1));
    }
  }
  if ((skip_pre ==0)) {
    if ((plen > 0)) {
      int32_t pi = 0;
      while ((pi < plen)) {
        if ((pos >=63)) {
          break;
        }
        (void)(((out)[pos] = (pre)[pi]));
        (void)((pos = (pos + 1)));
        (void)((pi = (pi + 1)));
      }
    }
  }
  int32_t pi2 = 0;
  while ((pi2 < flen)) {
    if ((pos >=63)) {
      break;
    }
    (void)(((out)[pos] = (field)[pi2]));
    (void)((pos = (pos + 1)));
    (void)((pi2 = (pi2 + 1)));
  }
  if ((pos > 0)) {
    return pos;
  }
  return (0 - 1);
}
int32_t glue_call_param_type_ref_at(uint8_t * arena, int32_t call, int32_t pix) {
  {
    return pipeline_asm_call_param_type_ref_at_c(arena, call, pix);
  }
  return 0;
}
int32_t glue_try_std_string_xlang_redirect_sym_local(uint8_t * name, int32_t nlen, uint8_t * out, int32_t cap) {
  if ((name ==0)) {
    return 0;
  }
  if ((nlen <=11)) {
    return 0;
  }
  if ((out ==0)) {
    return 0;
  }
  if ((cap <=0)) {
    return 0;
  }
  if (((((((((((((name)[0] !=115) || ((name)[1] !=116)) || ((name)[2] !=100)) || ((name)[3] !=95)) || ((name)[4] !=115)) || ((name)[5] !=116)) || ((name)[6] !=114)) || ((name)[7] !=105)) || ((name)[8] !=110)) || ((name)[9] !=103)) || ((name)[10] !=95))) {
    return 0;
  }
  int32_t suffix_len = (nlen - 11);
  if ((suffix_len < 12)) {
    return 0;
  }
  if ((((((((((((((name)[11] !=115) || ((name)[12] !=104)) || ((name)[13] !=117)) || ((name)[14] !=120)) || ((name)[15] !=95)) || ((name)[16] !=115)) || ((name)[17] !=116)) || ((name)[18] !=114)) || ((name)[19] !=105)) || ((name)[20] !=110)) || ((name)[21] !=103)) || ((name)[22] !=95))) {
    return 0;
  }
  if (((suffix_len + 1) > cap)) {
    return 0;
  }
  int32_t i = 0;
  while ((i < suffix_len)) {
    (void)(((out)[i] = (name)[(11 + i)]));
    (void)((i = (i + 1)));
  }
  return suffix_len;
}
int32_t glue_try_std_encoding_redirect_sym_local(uint8_t * name, int32_t nlen, uint8_t * out, int32_t cap) {
  if ((name ==0)) {
    return 0;
  }
  if ((out ==0)) {
    return 0;
  }
  if ((cap <=0)) {
    return 0;
  }
  int32_t prefix_len = 13;
  if ((nlen <=prefix_len)) {
    return 0;
  }
  if (((((((((((((((name)[0] !=115) || ((name)[1] !=116)) || ((name)[2] !=100)) || ((name)[3] !=95)) || ((name)[4] !=101)) || ((name)[5] !=110)) || ((name)[6] !=99)) || ((name)[7] !=111)) || ((name)[8] !=100)) || ((name)[9] !=105)) || ((name)[10] !=110)) || ((name)[11] !=103)) || ((name)[12] !=95))) {
    return 0;
  }
  int32_t suffix_len = (nlen - prefix_len);
  if ((suffix_len <=0)) {
    return 0;
  }
  int32_t out_len = ((9 + suffix_len) + 2);
  if ((out_len >=cap)) {
    return 0;
  }
  (void)(((out)[0] = 101));
  (void)(((out)[1] = 110));
  (void)(((out)[2] = 99));
  (void)(((out)[3] = 111));
  (void)(((out)[4] = 100));
  (void)(((out)[5] = 105));
  (void)(((out)[6] = 110));
  (void)(((out)[7] = 103));
  (void)(((out)[8] = 95));
  int32_t i = 0;
  while ((i < suffix_len)) {
    (void)(((out)[(9 + i)] = (name)[(prefix_len + i)]));
    (void)((i = (i + 1)));
  }
  (void)(((out)[(9 + suffix_len)] = 95));
  (void)(((out)[((9 + suffix_len) + 1)] = 99));
  return out_len;
}
int32_t glue_try_std_heap_redirect_sym_local(uint8_t * name, int32_t nlen, uint8_t * out, int32_t cap) {
  if ((name ==0)) {
    return 0;
  }
  if ((nlen <=0)) {
    return 0;
  }
  if ((out ==0)) {
    return 0;
  }
  if ((cap <=0)) {
    return 0;
  }
  if ((nlen ==5)) {
    if (((((((name)[0] ==97) && ((name)[1] ==108)) && ((name)[2] ==108)) && ((name)[3] ==111)) && ((name)[4] ==99))) {
      if (((12 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 97));
      (void)(((out)[6] = 108));
      (void)(((out)[7] = 108));
      (void)(((out)[8] = 111));
      (void)(((out)[9] = 99));
      (void)(((out)[10] = 95));
      (void)(((out)[11] = 99));
      return 12;
    }
  }
  if ((nlen ==7)) {
    if (((((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==108)) && ((name)[4] ==108)) && ((name)[5] ==111)) && ((name)[6] ==99))) {
      if (((14 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 114));
      (void)(((out)[6] = 101));
      (void)(((out)[7] = 97));
      (void)(((out)[8] = 108));
      (void)(((out)[9] = 108));
      (void)(((out)[10] = 111));
      (void)(((out)[11] = 99));
      (void)(((out)[12] = 95));
      (void)(((out)[13] = 99));
      return 14;
    }
  }
  if ((nlen ==4)) {
    if ((((((name)[0] ==102) && ((name)[1] ==114)) && ((name)[2] ==101)) && ((name)[3] ==101))) {
      if (((11 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 102));
      (void)(((out)[6] = 114));
      (void)(((out)[7] = 101));
      (void)(((out)[8] = 101));
      (void)(((out)[9] = 95));
      (void)(((out)[10] = 99));
      return 11;
    }
  }
  if ((nlen ==9)) {
    if (((((((((((name)[0] ==97) && ((name)[1] ==108)) && ((name)[2] ==108)) && ((name)[3] ==111)) && ((name)[4] ==99)) && ((name)[5] ==95)) && ((name)[6] ==105)) && ((name)[7] ==51)) && ((name)[8] ==50))) {
      if (((16 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 97));
      (void)(((out)[6] = 108));
      (void)(((out)[7] = 108));
      (void)(((out)[8] = 111));
      (void)(((out)[9] = 99));
      (void)(((out)[10] = 95));
      (void)(((out)[11] = 105));
      (void)(((out)[12] = 51));
      (void)(((out)[13] = 50));
      (void)(((out)[14] = 95));
      (void)(((out)[15] = 99));
      return 16;
    }
  }
  if ((nlen ==21)) {
    if (((((((((((((((((((((((name)[0] ==97) && ((name)[1] ==108)) && ((name)[2] ==108)) && ((name)[3] ==111)) && ((name)[4] ==99)) && ((name)[5] ==95)) && ((name)[6] ==105)) && ((name)[7] ==51)) && ((name)[8] ==50)) && ((name)[9] ==95)) && ((name)[10] ==114)) && ((name)[11] ==101)) && ((name)[12] ==116)) && ((name)[13] ==95)) && ((name)[14] ==105)) && ((name)[15] ==51)) && ((name)[16] ==50)) && ((name)[17] ==95)) && ((name)[18] ==112)) && ((name)[19] ==116)) && ((name)[20] ==114))) {
      if (((16 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 97));
      (void)(((out)[6] = 108));
      (void)(((out)[7] = 108));
      (void)(((out)[8] = 111));
      (void)(((out)[9] = 99));
      (void)(((out)[10] = 95));
      (void)(((out)[11] = 105));
      (void)(((out)[12] = 51));
      (void)(((out)[13] = 50));
      (void)(((out)[14] = 95));
      (void)(((out)[15] = 99));
      return 16;
    }
  }
  if ((nlen ==20)) {
    if ((((((((((((((((((((((name)[0] ==97) && ((name)[1] ==108)) && ((name)[2] ==108)) && ((name)[3] ==111)) && ((name)[4] ==99)) && ((name)[5] ==95)) && ((name)[6] ==105)) && ((name)[7] ==51)) && ((name)[8] ==50)) && ((name)[9] ==95)) && ((name)[10] ==114)) && ((name)[11] ==101)) && ((name)[12] ==116)) && ((name)[13] ==95)) && ((name)[14] ==117)) && ((name)[15] ==56)) && ((name)[16] ==95)) && ((name)[17] ==112)) && ((name)[18] ==116)) && ((name)[19] ==114))) {
      if (((15 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 97));
      (void)(((out)[6] = 108));
      (void)(((out)[7] = 108));
      (void)(((out)[8] = 111));
      (void)(((out)[9] = 99));
      (void)(((out)[10] = 95));
      (void)(((out)[11] = 117));
      (void)(((out)[12] = 56));
      (void)(((out)[13] = 95));
      (void)(((out)[14] = 99));
      return 15;
    }
  }
  if ((nlen ==21)) {
    if (((((((((((((((((((((((name)[0] ==97) && ((name)[1] ==108)) && ((name)[2] ==108)) && ((name)[3] ==111)) && ((name)[4] ==99)) && ((name)[5] ==95)) && ((name)[6] ==105)) && ((name)[7] ==51)) && ((name)[8] ==50)) && ((name)[9] ==95)) && ((name)[10] ==114)) && ((name)[11] ==101)) && ((name)[12] ==116)) && ((name)[13] ==95)) && ((name)[14] ==117)) && ((name)[15] ==54)) && ((name)[16] ==52)) && ((name)[17] ==95)) && ((name)[18] ==112)) && ((name)[19] ==116)) && ((name)[20] ==114))) {
      if (((16 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 97));
      (void)(((out)[6] = 108));
      (void)(((out)[7] = 108));
      (void)(((out)[8] = 111));
      (void)(((out)[9] = 99));
      (void)(((out)[10] = 95));
      (void)(((out)[11] = 117));
      (void)(((out)[12] = 54));
      (void)(((out)[13] = 52));
      (void)(((out)[14] = 95));
      (void)(((out)[15] = 99));
      return 16;
    }
  }
  if ((nlen ==21)) {
    if (((((((((((((((((((((((name)[0] ==97) && ((name)[1] ==108)) && ((name)[2] ==108)) && ((name)[3] ==111)) && ((name)[4] ==99)) && ((name)[5] ==95)) && ((name)[6] ==105)) && ((name)[7] ==51)) && ((name)[8] ==50)) && ((name)[9] ==95)) && ((name)[10] ==114)) && ((name)[11] ==101)) && ((name)[12] ==116)) && ((name)[13] ==95)) && ((name)[14] ==102)) && ((name)[15] ==54)) && ((name)[16] ==52)) && ((name)[17] ==95)) && ((name)[18] ==112)) && ((name)[19] ==116)) && ((name)[20] ==114))) {
      if (((16 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 97));
      (void)(((out)[6] = 108));
      (void)(((out)[7] = 108));
      (void)(((out)[8] = 111));
      (void)(((out)[9] = 99));
      (void)(((out)[10] = 95));
      (void)(((out)[11] = 102));
      (void)(((out)[12] = 54));
      (void)(((out)[13] = 52));
      (void)(((out)[14] = 95));
      (void)(((out)[15] = 99));
      return 16;
    }
  }
  if ((nlen ==21)) {
    if (((((((((((((((((((((((name)[0] ==97) && ((name)[1] ==108)) && ((name)[2] ==108)) && ((name)[3] ==111)) && ((name)[4] ==99)) && ((name)[5] ==95)) && ((name)[6] ==105)) && ((name)[7] ==51)) && ((name)[8] ==50)) && ((name)[9] ==95)) && ((name)[10] ==114)) && ((name)[11] ==101)) && ((name)[12] ==116)) && ((name)[13] ==95)) && ((name)[14] ==102)) && ((name)[15] ==51)) && ((name)[16] ==50)) && ((name)[17] ==95)) && ((name)[18] ==112)) && ((name)[19] ==116)) && ((name)[20] ==114))) {
      if (((16 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 97));
      (void)(((out)[6] = 108));
      (void)(((out)[7] = 108));
      (void)(((out)[8] = 111));
      (void)(((out)[9] = 99));
      (void)(((out)[10] = 95));
      (void)(((out)[11] = 102));
      (void)(((out)[12] = 51));
      (void)(((out)[13] = 50));
      (void)(((out)[14] = 95));
      (void)(((out)[15] = 99));
      return 16;
    }
  }
  if ((nlen ==11)) {
    if (((((((((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==108)) && ((name)[4] ==108)) && ((name)[5] ==111)) && ((name)[6] ==99)) && ((name)[7] ==95)) && ((name)[8] ==105)) && ((name)[9] ==51)) && ((name)[10] ==50))) {
      if (((18 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 114));
      (void)(((out)[6] = 101));
      (void)(((out)[7] = 97));
      (void)(((out)[8] = 108));
      (void)(((out)[9] = 108));
      (void)(((out)[10] = 111));
      (void)(((out)[11] = 99));
      (void)(((out)[12] = 95));
      (void)(((out)[13] = 105));
      (void)(((out)[14] = 51));
      (void)(((out)[15] = 50));
      (void)(((out)[16] = 95));
      (void)(((out)[17] = 99));
      return 18;
    }
  }
  if ((nlen ==23)) {
    if (((((((((((((((((((((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==108)) && ((name)[4] ==108)) && ((name)[5] ==111)) && ((name)[6] ==99)) && ((name)[7] ==95)) && ((name)[8] ==105)) && ((name)[9] ==51)) && ((name)[10] ==50)) && ((name)[11] ==95)) && ((name)[12] ==114)) && ((name)[13] ==101)) && ((name)[14] ==116)) && ((name)[15] ==95)) && ((name)[16] ==105)) && ((name)[17] ==51)) && ((name)[18] ==50)) && ((name)[19] ==95)) && ((name)[20] ==112)) && ((name)[21] ==116)) && ((name)[22] ==114))) {
      if (((18 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 114));
      (void)(((out)[6] = 101));
      (void)(((out)[7] = 97));
      (void)(((out)[8] = 108));
      (void)(((out)[9] = 108));
      (void)(((out)[10] = 111));
      (void)(((out)[11] = 99));
      (void)(((out)[12] = 95));
      (void)(((out)[13] = 105));
      (void)(((out)[14] = 51));
      (void)(((out)[15] = 50));
      (void)(((out)[16] = 95));
      (void)(((out)[17] = 99));
      return 18;
    }
  }
  if ((nlen ==23)) {
    if (((((((((((((((((((((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==108)) && ((name)[4] ==108)) && ((name)[5] ==111)) && ((name)[6] ==99)) && ((name)[7] ==95)) && ((name)[8] ==117)) && ((name)[9] ==54)) && ((name)[10] ==52)) && ((name)[11] ==95)) && ((name)[12] ==114)) && ((name)[13] ==101)) && ((name)[14] ==116)) && ((name)[15] ==95)) && ((name)[16] ==117)) && ((name)[17] ==54)) && ((name)[18] ==52)) && ((name)[19] ==95)) && ((name)[20] ==112)) && ((name)[21] ==116)) && ((name)[22] ==114))) {
      if (((18 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 114));
      (void)(((out)[6] = 101));
      (void)(((out)[7] = 97));
      (void)(((out)[8] = 108));
      (void)(((out)[9] = 108));
      (void)(((out)[10] = 111));
      (void)(((out)[11] = 99));
      (void)(((out)[12] = 95));
      (void)(((out)[13] = 117));
      (void)(((out)[14] = 54));
      (void)(((out)[15] = 52));
      (void)(((out)[16] = 95));
      (void)(((out)[17] = 99));
      return 18;
    }
  }
  if ((nlen ==23)) {
    if (((((((((((((((((((((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==108)) && ((name)[4] ==108)) && ((name)[5] ==111)) && ((name)[6] ==99)) && ((name)[7] ==95)) && ((name)[8] ==102)) && ((name)[9] ==54)) && ((name)[10] ==52)) && ((name)[11] ==95)) && ((name)[12] ==114)) && ((name)[13] ==101)) && ((name)[14] ==116)) && ((name)[15] ==95)) && ((name)[16] ==102)) && ((name)[17] ==54)) && ((name)[18] ==52)) && ((name)[19] ==95)) && ((name)[20] ==112)) && ((name)[21] ==116)) && ((name)[22] ==114))) {
      if (((18 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 114));
      (void)(((out)[6] = 101));
      (void)(((out)[7] = 97));
      (void)(((out)[8] = 108));
      (void)(((out)[9] = 108));
      (void)(((out)[10] = 111));
      (void)(((out)[11] = 99));
      (void)(((out)[12] = 95));
      (void)(((out)[13] = 102));
      (void)(((out)[14] = 54));
      (void)(((out)[15] = 52));
      (void)(((out)[16] = 95));
      (void)(((out)[17] = 99));
      return 18;
    }
  }
  if ((nlen ==23)) {
    if (((((((((((((((((((((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==108)) && ((name)[4] ==108)) && ((name)[5] ==111)) && ((name)[6] ==99)) && ((name)[7] ==95)) && ((name)[8] ==102)) && ((name)[9] ==51)) && ((name)[10] ==50)) && ((name)[11] ==95)) && ((name)[12] ==114)) && ((name)[13] ==101)) && ((name)[14] ==116)) && ((name)[15] ==95)) && ((name)[16] ==102)) && ((name)[17] ==51)) && ((name)[18] ==50)) && ((name)[19] ==95)) && ((name)[20] ==112)) && ((name)[21] ==116)) && ((name)[22] ==114))) {
      if (((18 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 114));
      (void)(((out)[6] = 101));
      (void)(((out)[7] = 97));
      (void)(((out)[8] = 108));
      (void)(((out)[9] = 108));
      (void)(((out)[10] = 111));
      (void)(((out)[11] = 99));
      (void)(((out)[12] = 95));
      (void)(((out)[13] = 102));
      (void)(((out)[14] = 51));
      (void)(((out)[15] = 50));
      (void)(((out)[16] = 95));
      (void)(((out)[17] = 99));
      return 18;
    }
  }
  if ((nlen ==21)) {
    if (((((((((((((((((((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==108)) && ((name)[4] ==108)) && ((name)[5] ==111)) && ((name)[6] ==99)) && ((name)[7] ==95)) && ((name)[8] ==117)) && ((name)[9] ==56)) && ((name)[10] ==95)) && ((name)[11] ==114)) && ((name)[12] ==101)) && ((name)[13] ==116)) && ((name)[14] ==95)) && ((name)[15] ==117)) && ((name)[16] ==56)) && ((name)[17] ==95)) && ((name)[18] ==112)) && ((name)[19] ==116)) && ((name)[20] ==114))) {
      if (((17 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 114));
      (void)(((out)[6] = 101));
      (void)(((out)[7] = 97));
      (void)(((out)[8] = 108));
      (void)(((out)[9] = 108));
      (void)(((out)[10] = 111));
      (void)(((out)[11] = 99));
      (void)(((out)[12] = 95));
      (void)(((out)[13] = 117));
      (void)(((out)[14] = 56));
      (void)(((out)[15] = 95));
      (void)(((out)[16] = 99));
      return 17;
    }
  }
  if ((nlen ==8)) {
    if ((((((((((name)[0] ==102) && ((name)[1] ==114)) && ((name)[2] ==101)) && ((name)[3] ==101)) && ((name)[4] ==95)) && ((name)[5] ==105)) && ((name)[6] ==51)) && ((name)[7] ==50))) {
      if (((15 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 102));
      (void)(((out)[6] = 114));
      (void)(((out)[7] = 101));
      (void)(((out)[8] = 101));
      (void)(((out)[9] = 95));
      (void)(((out)[10] = 105));
      (void)(((out)[11] = 51));
      (void)(((out)[12] = 50));
      (void)(((out)[13] = 95));
      (void)(((out)[14] = 99));
      return 15;
    }
  }
  if ((nlen ==12)) {
    if ((((((((((((((name)[0] ==102) && ((name)[1] ==114)) && ((name)[2] ==101)) && ((name)[3] ==101)) && ((name)[4] ==95)) && ((name)[5] ==105)) && ((name)[6] ==51)) && ((name)[7] ==50)) && ((name)[8] ==95)) && ((name)[9] ==112)) && ((name)[10] ==116)) && ((name)[11] ==114))) {
      if (((15 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 102));
      (void)(((out)[6] = 114));
      (void)(((out)[7] = 101));
      (void)(((out)[8] = 101));
      (void)(((out)[9] = 95));
      (void)(((out)[10] = 105));
      (void)(((out)[11] = 51));
      (void)(((out)[12] = 50));
      (void)(((out)[13] = 95));
      (void)(((out)[14] = 99));
      return 15;
    }
  }
  if ((nlen ==12)) {
    if ((((((((((((((name)[0] ==102) && ((name)[1] ==114)) && ((name)[2] ==101)) && ((name)[3] ==101)) && ((name)[4] ==95)) && ((name)[5] ==117)) && ((name)[6] ==54)) && ((name)[7] ==52)) && ((name)[8] ==95)) && ((name)[9] ==112)) && ((name)[10] ==116)) && ((name)[11] ==114))) {
      if (((15 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 102));
      (void)(((out)[6] = 114));
      (void)(((out)[7] = 101));
      (void)(((out)[8] = 101));
      (void)(((out)[9] = 95));
      (void)(((out)[10] = 117));
      (void)(((out)[11] = 54));
      (void)(((out)[12] = 52));
      (void)(((out)[13] = 95));
      (void)(((out)[14] = 99));
      return 15;
    }
  }
  if ((nlen ==12)) {
    if ((((((((((((((name)[0] ==102) && ((name)[1] ==114)) && ((name)[2] ==101)) && ((name)[3] ==101)) && ((name)[4] ==95)) && ((name)[5] ==102)) && ((name)[6] ==54)) && ((name)[7] ==52)) && ((name)[8] ==95)) && ((name)[9] ==112)) && ((name)[10] ==116)) && ((name)[11] ==114))) {
      if (((15 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 102));
      (void)(((out)[6] = 114));
      (void)(((out)[7] = 101));
      (void)(((out)[8] = 101));
      (void)(((out)[9] = 95));
      (void)(((out)[10] = 102));
      (void)(((out)[11] = 54));
      (void)(((out)[12] = 52));
      (void)(((out)[13] = 95));
      (void)(((out)[14] = 99));
      return 15;
    }
  }
  if ((nlen ==12)) {
    if ((((((((((((((name)[0] ==102) && ((name)[1] ==114)) && ((name)[2] ==101)) && ((name)[3] ==101)) && ((name)[4] ==95)) && ((name)[5] ==102)) && ((name)[6] ==51)) && ((name)[7] ==50)) && ((name)[8] ==95)) && ((name)[9] ==112)) && ((name)[10] ==116)) && ((name)[11] ==114))) {
      if (((15 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 102));
      (void)(((out)[6] = 114));
      (void)(((out)[7] = 101));
      (void)(((out)[8] = 101));
      (void)(((out)[9] = 95));
      (void)(((out)[10] = 102));
      (void)(((out)[11] = 51));
      (void)(((out)[12] = 50));
      (void)(((out)[13] = 95));
      (void)(((out)[14] = 99));
      return 15;
    }
  }
  if ((nlen ==8)) {
    if ((((((((((name)[0] ==97) && ((name)[1] ==108)) && ((name)[2] ==108)) && ((name)[3] ==111)) && ((name)[4] ==99)) && ((name)[5] ==95)) && ((name)[6] ==117)) && ((name)[7] ==56))) {
      if (((15 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 97));
      (void)(((out)[6] = 108));
      (void)(((out)[7] = 108));
      (void)(((out)[8] = 111));
      (void)(((out)[9] = 99));
      (void)(((out)[10] = 95));
      (void)(((out)[11] = 117));
      (void)(((out)[12] = 56));
      (void)(((out)[13] = 95));
      (void)(((out)[14] = 99));
      return 15;
    }
  }
  if ((nlen ==10)) {
    if ((((((((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==108)) && ((name)[4] ==108)) && ((name)[5] ==111)) && ((name)[6] ==99)) && ((name)[7] ==95)) && ((name)[8] ==117)) && ((name)[9] ==56))) {
      if (((17 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 114));
      (void)(((out)[6] = 101));
      (void)(((out)[7] = 97));
      (void)(((out)[8] = 108));
      (void)(((out)[9] = 108));
      (void)(((out)[10] = 111));
      (void)(((out)[11] = 99));
      (void)(((out)[12] = 95));
      (void)(((out)[13] = 117));
      (void)(((out)[14] = 56));
      (void)(((out)[15] = 95));
      (void)(((out)[16] = 99));
      return 17;
    }
  }
  if ((nlen ==7)) {
    if (((((((((name)[0] ==102) && ((name)[1] ==114)) && ((name)[2] ==101)) && ((name)[3] ==101)) && ((name)[4] ==95)) && ((name)[5] ==117)) && ((name)[6] ==56))) {
      if (((14 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 102));
      (void)(((out)[6] = 114));
      (void)(((out)[7] = 101));
      (void)(((out)[8] = 101));
      (void)(((out)[9] = 95));
      (void)(((out)[10] = 117));
      (void)(((out)[11] = 56));
      (void)(((out)[12] = 95));
      (void)(((out)[13] = 99));
      return 14;
    }
  }
  if ((nlen ==9)) {
    if (((((((((((name)[0] ==97) && ((name)[1] ==108)) && ((name)[2] ==108)) && ((name)[3] ==111)) && ((name)[4] ==99)) && ((name)[5] ==95)) && ((name)[6] ==102)) && ((name)[7] ==51)) && ((name)[8] ==50))) {
      if (((16 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 97));
      (void)(((out)[6] = 108));
      (void)(((out)[7] = 108));
      (void)(((out)[8] = 111));
      (void)(((out)[9] = 99));
      (void)(((out)[10] = 95));
      (void)(((out)[11] = 102));
      (void)(((out)[12] = 51));
      (void)(((out)[13] = 50));
      (void)(((out)[14] = 95));
      (void)(((out)[15] = 99));
      return 16;
    }
  }
  if ((nlen ==11)) {
    if (((((((((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==108)) && ((name)[4] ==108)) && ((name)[5] ==111)) && ((name)[6] ==99)) && ((name)[7] ==95)) && ((name)[8] ==102)) && ((name)[9] ==51)) && ((name)[10] ==50))) {
      if (((18 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 114));
      (void)(((out)[6] = 101));
      (void)(((out)[7] = 97));
      (void)(((out)[8] = 108));
      (void)(((out)[9] = 108));
      (void)(((out)[10] = 111));
      (void)(((out)[11] = 99));
      (void)(((out)[12] = 95));
      (void)(((out)[13] = 102));
      (void)(((out)[14] = 51));
      (void)(((out)[15] = 50));
      (void)(((out)[16] = 95));
      (void)(((out)[17] = 99));
      return 18;
    }
  }
  if ((nlen ==8)) {
    if ((((((((((name)[0] ==102) && ((name)[1] ==114)) && ((name)[2] ==101)) && ((name)[3] ==101)) && ((name)[4] ==95)) && ((name)[5] ==102)) && ((name)[6] ==51)) && ((name)[7] ==50))) {
      if (((15 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 102));
      (void)(((out)[6] = 114));
      (void)(((out)[7] = 101));
      (void)(((out)[8] = 101));
      (void)(((out)[9] = 95));
      (void)(((out)[10] = 102));
      (void)(((out)[11] = 51));
      (void)(((out)[12] = 50));
      (void)(((out)[13] = 95));
      (void)(((out)[14] = 99));
      return 15;
    }
  }
  if ((nlen ==11)) {
    if (((((((((((((name)[0] ==99) && ((name)[1] ==111)) && ((name)[2] ==112)) && ((name)[3] ==121)) && ((name)[4] ==95)) && ((name)[5] ==105)) && ((name)[6] ==51)) && ((name)[7] ==50)) && ((name)[8] ==95)) && ((name)[9] ==97)) && ((name)[10] ==116))) {
      if (((18 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 99));
      (void)(((out)[6] = 111));
      (void)(((out)[7] = 112));
      (void)(((out)[8] = 121));
      (void)(((out)[9] = 95));
      (void)(((out)[10] = 105));
      (void)(((out)[11] = 51));
      (void)(((out)[12] = 50));
      (void)(((out)[13] = 95));
      (void)(((out)[14] = 97));
      (void)(((out)[15] = 116));
      (void)(((out)[16] = 95));
      (void)(((out)[17] = 99));
      return 18;
    }
  }
  if ((nlen ==10)) {
    if ((((((((((((name)[0] ==99) && ((name)[1] ==111)) && ((name)[2] ==112)) && ((name)[3] ==121)) && ((name)[4] ==95)) && ((name)[5] ==117)) && ((name)[6] ==56)) && ((name)[7] ==95)) && ((name)[8] ==97)) && ((name)[9] ==116))) {
      if (((17 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 99));
      (void)(((out)[6] = 111));
      (void)(((out)[7] = 112));
      (void)(((out)[8] = 121));
      (void)(((out)[9] = 95));
      (void)(((out)[10] = 117));
      (void)(((out)[11] = 56));
      (void)(((out)[12] = 95));
      (void)(((out)[13] = 97));
      (void)(((out)[14] = 116));
      (void)(((out)[15] = 95));
      (void)(((out)[16] = 99));
      return 17;
    }
  }
  if ((nlen ==11)) {
    if (((((((((((((name)[0] ==99) && ((name)[1] ==111)) && ((name)[2] ==112)) && ((name)[3] ==121)) && ((name)[4] ==95)) && ((name)[5] ==102)) && ((name)[6] ==51)) && ((name)[7] ==50)) && ((name)[8] ==95)) && ((name)[9] ==97)) && ((name)[10] ==116))) {
      if (((18 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 99));
      (void)(((out)[6] = 111));
      (void)(((out)[7] = 112));
      (void)(((out)[8] = 121));
      (void)(((out)[9] = 95));
      (void)(((out)[10] = 102));
      (void)(((out)[11] = 51));
      (void)(((out)[12] = 50));
      (void)(((out)[13] = 95));
      (void)(((out)[14] = 97));
      (void)(((out)[15] = 116));
      (void)(((out)[16] = 95));
      (void)(((out)[17] = 99));
      return 18;
    }
  }
  if ((nlen ==11)) {
    if (((((((((((((name)[0] ==99) && ((name)[1] ==111)) && ((name)[2] ==112)) && ((name)[3] ==121)) && ((name)[4] ==95)) && ((name)[5] ==117)) && ((name)[6] ==54)) && ((name)[7] ==52)) && ((name)[8] ==95)) && ((name)[9] ==97)) && ((name)[10] ==116))) {
      if (((18 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 99));
      (void)(((out)[6] = 111));
      (void)(((out)[7] = 112));
      (void)(((out)[8] = 121));
      (void)(((out)[9] = 95));
      (void)(((out)[10] = 117));
      (void)(((out)[11] = 54));
      (void)(((out)[12] = 52));
      (void)(((out)[13] = 95));
      (void)(((out)[14] = 97));
      (void)(((out)[15] = 116));
      (void)(((out)[16] = 95));
      (void)(((out)[17] = 99));
      return 18;
    }
  }
  if ((nlen ==11)) {
    if (((((((((((((name)[0] ==99) && ((name)[1] ==111)) && ((name)[2] ==112)) && ((name)[3] ==121)) && ((name)[4] ==95)) && ((name)[5] ==102)) && ((name)[6] ==54)) && ((name)[7] ==52)) && ((name)[8] ==95)) && ((name)[9] ==97)) && ((name)[10] ==116))) {
      if (((18 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 99));
      (void)(((out)[6] = 111));
      (void)(((out)[7] = 112));
      (void)(((out)[8] = 121));
      (void)(((out)[9] = 95));
      (void)(((out)[10] = 102));
      (void)(((out)[11] = 54));
      (void)(((out)[12] = 52));
      (void)(((out)[13] = 95));
      (void)(((out)[14] = 97));
      (void)(((out)[15] = 116));
      (void)(((out)[16] = 95));
      (void)(((out)[17] = 99));
      return 18;
    }
  }
  if ((nlen ==28)) {
    if ((((((((((((((((((((((((((((((name)[0] ==99) && ((name)[1] ==111)) && ((name)[2] ==112)) && ((name)[3] ==121)) && ((name)[4] ==95)) && ((name)[5] ==105)) && ((name)[6] ==51)) && ((name)[7] ==50)) && ((name)[8] ==95)) && ((name)[9] ==112)) && ((name)[10] ==116)) && ((name)[11] ==114)) && ((name)[12] ==95)) && ((name)[13] ==105)) && ((name)[14] ==51)) && ((name)[15] ==50)) && ((name)[16] ==95)) && ((name)[17] ==105)) && ((name)[18] ==51)) && ((name)[19] ==50)) && ((name)[20] ==95)) && ((name)[21] ==112)) && ((name)[22] ==116)) && ((name)[23] ==114)) && ((name)[24] ==95)) && ((name)[25] ==105)) && ((name)[26] ==51)) && ((name)[27] ==50))) {
      if (((18 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 99));
      (void)(((out)[6] = 111));
      (void)(((out)[7] = 112));
      (void)(((out)[8] = 121));
      (void)(((out)[9] = 95));
      (void)(((out)[10] = 105));
      (void)(((out)[11] = 51));
      (void)(((out)[12] = 50));
      (void)(((out)[13] = 95));
      (void)(((out)[14] = 97));
      (void)(((out)[15] = 116));
      (void)(((out)[16] = 95));
      (void)(((out)[17] = 99));
      return 18;
    }
  }
  if ((nlen ==26)) {
    if ((((((((((((((((((((((((((((name)[0] ==99) && ((name)[1] ==111)) && ((name)[2] ==112)) && ((name)[3] ==121)) && ((name)[4] ==95)) && ((name)[5] ==117)) && ((name)[6] ==56)) && ((name)[7] ==95)) && ((name)[8] ==112)) && ((name)[9] ==116)) && ((name)[10] ==114)) && ((name)[11] ==95)) && ((name)[12] ==105)) && ((name)[13] ==51)) && ((name)[14] ==50)) && ((name)[15] ==95)) && ((name)[16] ==117)) && ((name)[17] ==56)) && ((name)[18] ==95)) && ((name)[19] ==112)) && ((name)[20] ==116)) && ((name)[21] ==114)) && ((name)[22] ==95)) && ((name)[23] ==105)) && ((name)[24] ==51)) && ((name)[25] ==50))) {
      if (((17 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 99));
      (void)(((out)[6] = 111));
      (void)(((out)[7] = 112));
      (void)(((out)[8] = 121));
      (void)(((out)[9] = 95));
      (void)(((out)[10] = 117));
      (void)(((out)[11] = 56));
      (void)(((out)[12] = 95));
      (void)(((out)[13] = 97));
      (void)(((out)[14] = 116));
      (void)(((out)[15] = 95));
      (void)(((out)[16] = 99));
      return 17;
    }
  }
  if ((nlen ==28)) {
    if ((((((((((((((((((((((((((((((name)[0] ==99) && ((name)[1] ==111)) && ((name)[2] ==112)) && ((name)[3] ==121)) && ((name)[4] ==95)) && ((name)[5] ==102)) && ((name)[6] ==51)) && ((name)[7] ==50)) && ((name)[8] ==95)) && ((name)[9] ==112)) && ((name)[10] ==116)) && ((name)[11] ==114)) && ((name)[12] ==95)) && ((name)[13] ==105)) && ((name)[14] ==51)) && ((name)[15] ==50)) && ((name)[16] ==95)) && ((name)[17] ==102)) && ((name)[18] ==51)) && ((name)[19] ==50)) && ((name)[20] ==95)) && ((name)[21] ==112)) && ((name)[22] ==116)) && ((name)[23] ==114)) && ((name)[24] ==95)) && ((name)[25] ==105)) && ((name)[26] ==51)) && ((name)[27] ==50))) {
      if (((18 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 99));
      (void)(((out)[6] = 111));
      (void)(((out)[7] = 112));
      (void)(((out)[8] = 121));
      (void)(((out)[9] = 95));
      (void)(((out)[10] = 102));
      (void)(((out)[11] = 51));
      (void)(((out)[12] = 50));
      (void)(((out)[13] = 95));
      (void)(((out)[14] = 97));
      (void)(((out)[15] = 116));
      (void)(((out)[16] = 95));
      (void)(((out)[17] = 99));
      return 18;
    }
  }
  if ((nlen ==28)) {
    if ((((((((((((((((((((((((((((((name)[0] ==99) && ((name)[1] ==111)) && ((name)[2] ==112)) && ((name)[3] ==121)) && ((name)[4] ==95)) && ((name)[5] ==117)) && ((name)[6] ==54)) && ((name)[7] ==52)) && ((name)[8] ==95)) && ((name)[9] ==112)) && ((name)[10] ==116)) && ((name)[11] ==114)) && ((name)[12] ==95)) && ((name)[13] ==105)) && ((name)[14] ==51)) && ((name)[15] ==50)) && ((name)[16] ==95)) && ((name)[17] ==117)) && ((name)[18] ==54)) && ((name)[19] ==52)) && ((name)[20] ==95)) && ((name)[21] ==112)) && ((name)[22] ==116)) && ((name)[23] ==114)) && ((name)[24] ==95)) && ((name)[25] ==105)) && ((name)[26] ==51)) && ((name)[27] ==50))) {
      if (((18 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 99));
      (void)(((out)[6] = 111));
      (void)(((out)[7] = 112));
      (void)(((out)[8] = 121));
      (void)(((out)[9] = 95));
      (void)(((out)[10] = 117));
      (void)(((out)[11] = 54));
      (void)(((out)[12] = 52));
      (void)(((out)[13] = 95));
      (void)(((out)[14] = 97));
      (void)(((out)[15] = 116));
      (void)(((out)[16] = 95));
      (void)(((out)[17] = 99));
      return 18;
    }
  }
  if ((nlen ==28)) {
    if ((((((((((((((((((((((((((((((name)[0] ==99) && ((name)[1] ==111)) && ((name)[2] ==112)) && ((name)[3] ==121)) && ((name)[4] ==95)) && ((name)[5] ==102)) && ((name)[6] ==54)) && ((name)[7] ==52)) && ((name)[8] ==95)) && ((name)[9] ==112)) && ((name)[10] ==116)) && ((name)[11] ==114)) && ((name)[12] ==95)) && ((name)[13] ==105)) && ((name)[14] ==51)) && ((name)[15] ==50)) && ((name)[16] ==95)) && ((name)[17] ==102)) && ((name)[18] ==54)) && ((name)[19] ==52)) && ((name)[20] ==95)) && ((name)[21] ==112)) && ((name)[22] ==116)) && ((name)[23] ==114)) && ((name)[24] ==95)) && ((name)[25] ==105)) && ((name)[26] ==51)) && ((name)[27] ==50))) {
      if (((18 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 99));
      (void)(((out)[6] = 111));
      (void)(((out)[7] = 112));
      (void)(((out)[8] = 121));
      (void)(((out)[9] = 95));
      (void)(((out)[10] = 102));
      (void)(((out)[11] = 54));
      (void)(((out)[12] = 52));
      (void)(((out)[13] = 95));
      (void)(((out)[14] = 97));
      (void)(((out)[15] = 116));
      (void)(((out)[16] = 95));
      (void)(((out)[17] = 99));
      return 18;
    }
  }
  if ((nlen ==12)) {
    if ((((((((((((((name)[0] ==97) && ((name)[1] ==114)) && ((name)[2] ==101)) && ((name)[3] ==110)) && ((name)[4] ==97)) && ((name)[5] ==54)) && ((name)[6] ==52)) && ((name)[7] ==95)) && ((name)[8] ==105)) && ((name)[9] ==110)) && ((name)[10] ==105)) && ((name)[11] ==116))) {
      if (((19 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 97));
      (void)(((out)[6] = 114));
      (void)(((out)[7] = 101));
      (void)(((out)[8] = 110));
      (void)(((out)[9] = 97));
      (void)(((out)[10] = 54));
      (void)(((out)[11] = 52));
      (void)(((out)[12] = 95));
      (void)(((out)[13] = 105));
      (void)(((out)[14] = 110));
      (void)(((out)[15] = 105));
      (void)(((out)[16] = 116));
      (void)(((out)[17] = 95));
      (void)(((out)[18] = 99));
      return 19;
    }
  }
  if ((nlen ==13)) {
    if (((((((((((((((name)[0] ==97) && ((name)[1] ==114)) && ((name)[2] ==101)) && ((name)[3] ==110)) && ((name)[4] ==97)) && ((name)[5] ==54)) && ((name)[6] ==52)) && ((name)[7] ==95)) && ((name)[8] ==97)) && ((name)[9] ==108)) && ((name)[10] ==108)) && ((name)[11] ==111)) && ((name)[12] ==99))) {
      if (((20 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 97));
      (void)(((out)[6] = 114));
      (void)(((out)[7] = 101));
      (void)(((out)[8] = 110));
      (void)(((out)[9] = 97));
      (void)(((out)[10] = 54));
      (void)(((out)[11] = 52));
      (void)(((out)[12] = 95));
      (void)(((out)[13] = 97));
      (void)(((out)[14] = 108));
      (void)(((out)[15] = 108));
      (void)(((out)[16] = 111));
      (void)(((out)[17] = 99));
      (void)(((out)[18] = 95));
      (void)(((out)[19] = 99));
      return 20;
    }
  }
  if ((nlen ==14)) {
    if ((((((((((((((((name)[0] ==97) && ((name)[1] ==114)) && ((name)[2] ==101)) && ((name)[3] ==110)) && ((name)[4] ==97)) && ((name)[5] ==54)) && ((name)[6] ==52)) && ((name)[7] ==95)) && ((name)[8] ==100)) && ((name)[9] ==101)) && ((name)[10] ==105)) && ((name)[11] ==110)) && ((name)[12] ==105)) && ((name)[13] ==116))) {
      if (((21 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 97));
      (void)(((out)[6] = 114));
      (void)(((out)[7] = 101));
      (void)(((out)[8] = 110));
      (void)(((out)[9] = 97));
      (void)(((out)[10] = 54));
      (void)(((out)[11] = 52));
      (void)(((out)[12] = 95));
      (void)(((out)[13] = 100));
      (void)(((out)[14] = 101));
      (void)(((out)[15] = 105));
      (void)(((out)[16] = 110));
      (void)(((out)[17] = 105));
      (void)(((out)[18] = 116));
      (void)(((out)[19] = 95));
      (void)(((out)[20] = 99));
      return 21;
    }
  }
  if ((nlen ==7)) {
    if (((((((((name)[0] ==112) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==95)) && ((name)[4] ==109)) && ((name)[5] ==111)) && ((name)[6] ==100))) {
      if (((14 + 1) > cap)) {
        return 0;
      }
      (void)(((out)[0] = 104));
      (void)(((out)[1] = 101));
      (void)(((out)[2] = 97));
      (void)(((out)[3] = 112));
      (void)(((out)[4] = 95));
      (void)(((out)[5] = 112));
      (void)(((out)[6] = 116));
      (void)(((out)[7] = 114));
      (void)(((out)[8] = 95));
      (void)(((out)[9] = 109));
      (void)(((out)[10] = 111));
      (void)(((out)[11] = 100));
      (void)(((out)[12] = 95));
      (void)(((out)[13] = 99));
      return 14;
    }
  }
  return 0;
}
