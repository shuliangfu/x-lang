/* seeds/backend_try_inline_dispatch_surface.from_x.c
 * R2 full surface — isomorphic with src/asm/backend_try_inline_dispatch.x
 * Product PREFER_X_O: g05_try_x_to_o(backend_try_inline_dispatch.x) + hybrid rest
 *   seeds/backend_try_inline_dispatch.from_x.c (-DSHUX_BACKEND_TRY_INLINE_DISPATCH_FROM_X) ld -r
 * R2: full.x 吃满 try_inline/glue 公共业务；FROM_X rest 仅 slice_marker（业务 H=0）
 * Prove: full.x vs this seed → nm IDENTICAL
 * Regen: ./shux -E ... src/asm/backend_try_inline_dispatch.x | filter DBG + polish prologue
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
/* wave232 G.7: env via public pure thin link_abi_getenv (not raw libc getenv). */
extern char *link_abi_getenv(const char *name);
extern int32_t backend_try_inline_dispatch_x_doc_anchor(void);
extern int32_t glue_module_func_index_by_name(uint8_t * mod, uint8_t * name, int32_t nlen);
extern int32_t glue_const_scalar_binop_eval_i32(int32_t ko, int32_t a, int32_t b, int32_t * out);
extern int32_t glue_module_named_type_has_struct_layout(uint8_t * mod, uint8_t * name, int32_t nlen);
extern int32_t glue_type_ref_is_named_struct_layout(uint8_t * arena, uint8_t * mod, int32_t ty_ref);
extern uint8_t * g02f_load_ptr_at(uint8_t * p, int32_t off);
extern void g02f_store_ptr_at(uint8_t * p, int32_t off, uint8_t * val);
extern int32_t asm_local_var_slot_holds_indirect_ptr(uint8_t * arena, int32_t expr_ref, uint8_t * mod, uint8_t * asm_ctx);
extern int32_t glue_local_var_slot_holds_indirect_ptr(uint8_t * arena, int32_t er, uint8_t * asm_ctx);
extern int32_t glue_expr_is_func_param_at(uint8_t * arena, uint8_t * mod, int32_t fi, int32_t er, int32_t pix);
extern int32_t glue_fold_func_return_operand_ref_module(uint8_t * arena, uint8_t * mod, int32_t fi);
extern int32_t glue_try_fold_func_return_operand_ref(uint8_t * arena, uint8_t * mod, int32_t fi);
extern int32_t glue_call_lookup_callee_mod_fi_arena(uint8_t * caller_arena, int32_t call_ref, uint8_t * ctx, uint8_t * out_ca, uint8_t * out_cm, int32_t * out_fi);
extern int32_t glue_fold_func_returns_param01_scalar_binop(uint8_t * arena, uint8_t * mod, int32_t func_idx, int32_t * out_binop_ko);
extern int32_t glue_enc_local_slot_ptr_or_addr(uint8_t * arena, uint8_t * elf, int32_t arg_ref, int32_t slot_off, int32_t ta, uint8_t * asm_ctx);
extern int32_t glue_arch_emit_local_slot_ptr_or_addr_text(uint8_t * arena, uint8_t * out, int32_t arg_ref, int32_t slot_off, int32_t ta, uint8_t * asm_ctx);
extern int32_t glue_struct_lit_field_init_param_index(uint8_t * arena, uint8_t * mod, int32_t fi, int32_t lit, int32_t fj, int32_t * out_pix);
extern int32_t glue_fold_func_returns_param_struct_lit(uint8_t * arena, uint8_t * mod, int32_t func_idx, int32_t * out_lit_ref);
extern int32_t glue_struct_lit_field_index_by_name(uint8_t * arena, int32_t lit_ref, uint8_t * fn, int32_t fnlen);
extern int32_t glue_inner_call_arg_for_field_access(uint8_t * arena, uint8_t * ctx, int32_t inner_call_ref, int32_t outer_field_ref, int32_t * out_arg_ref);
extern int32_t glue_dep_module_field_offset_by_name(uint8_t * pctx, uint8_t * field_name, int32_t flen);
extern int32_t glue_inline_var_field_access_offset(uint8_t * arena, uint8_t * mod, uint8_t * pctx, uint8_t * asm_ctx, int32_t fa_ref);
extern int32_t glue_try_array_lit_lane_const_i32(uint8_t * arena, int32_t arr_ref, int32_t lane, int32_t * out);
extern int32_t glue_fold_func_returns_param01_vector_binop(uint8_t * arena, uint8_t * mod, int32_t func_idx, int32_t * out_binop_ko);
extern int32_t glue_fold_func_returns_param0_index_const(uint8_t * arena, uint8_t * mod, int32_t func_idx, int32_t * out_lane);
extern int32_t glue_call_is_zero_arg_default_alloc(uint8_t * arena, int32_t call_ref);
extern int32_t glue_const_struct_lit_field_can_inline(uint8_t * arena, uint8_t * mod, int32_t func_idx, int32_t lit_ref, int32_t fj);
extern int32_t glue_emit_default_alloc_to_rbx_offset(uint8_t * elf_ctx, int32_t foff, int32_t fsz, int32_t ta);
extern int32_t glue_fold_func_returns_const_struct_lit(uint8_t * arena, uint8_t * mod, int32_t func_idx, int32_t * out_lit_ref);
extern int32_t glue_align_up8_c(int32_t n);
extern int32_t glue_is_vector_lane_scalar_binop_ko(int32_t ko);
extern int32_t glue_try_expr_const_i32(uint8_t * arena, int32_t er, int32_t * out);
extern int32_t glue_try_inline_local_slot_off(uint8_t * ctx, uint8_t * arena, uint8_t * name, int32_t nlen);
extern int32_t try_inline_x_plus_k_call_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta);
extern int32_t try_inline_param0_single_field_call_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta);
extern int32_t try_inline_param0_field_sum_call_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta);
extern int32_t try_inline_var_field_sum_binop_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t left_ref, int32_t right_ref, uint8_t * ctx, int32_t ta);
extern int32_t try_inline_wpo_const_scalar_binop_call_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta);
extern int32_t try_inline_wpo_const_vector_lane_of_binop_call_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta);
extern int32_t try_call_wpo_mono_symbol_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta);
extern int32_t try_inline_const_struct_lit_return_call_to_slot_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t call_ref, uint8_t * ctx, int32_t ta, int32_t stack_slot_off);
extern int32_t try_inline_struct_lit_return_call_to_slot_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t call_ref, uint8_t * ctx, int32_t ta, int32_t stack_slot_off);
extern int32_t try_call_wpo_mono_vector_lane_of_binop_call_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta);
extern int32_t asm_array_lit_elem_byte_sz(uint8_t * arena, int32_t array_lit_ref);
extern int32_t pipeline_asm_array_lit_elem_byte_sz_c(uint8_t * arena, int32_t array_lit_ref);
extern int32_t asm_array_lit_reserve_stack_bytes(uint8_t * arena, int32_t init_ref);
extern int32_t pipeline_asm_array_lit_reserve_stack_bytes_c(uint8_t * arena, int32_t init_ref);
extern int32_t asm_struct_lit_reserve_stack_bytes(uint8_t * arena, int32_t init_ref);
extern int32_t pipeline_asm_struct_lit_reserve_stack_bytes_c(uint8_t * arena, int32_t init_ref);
extern int32_t asm_index_elem_byte_sz(uint8_t * arena, int32_t index_expr_ref);
extern int32_t pipeline_asm_enc_local_slot_ptr_or_addr_elf_c(uint8_t * arena, uint8_t * elf, int32_t arg_ref, int32_t slot_off, int32_t ta, uint8_t * asm_ctx);
extern int32_t pipeline_asm_arch_emit_local_slot_ptr_or_addr_text_c(uint8_t * arena, uint8_t * out, int32_t arg_ref, int32_t slot_off, int32_t ta, uint8_t * asm_ctx);
int32_t backend_try_inline_dispatch_x_doc_anchor(void) {
  return 0;
}
extern int32_t pipeline_expr_resolved_type_ref(uint8_t * arena, int32_t er);
extern int32_t asm_ctx_scope_block_ref_at(uint8_t * asm_ctx);
extern int32_t pipeline_block_resolve_var_type_ref(uint8_t * arena, int32_t br, uint8_t * vname, int32_t vlen);
extern int32_t pipeline_module_num_struct_layouts_at(uint8_t * mod);
extern int32_t pipeline_module_struct_layout_name_len(uint8_t * mod, int32_t idx);
extern uint8_t pipeline_module_struct_layout_name_byte_at(uint8_t * mod, int32_t idx, int32_t off);
extern int32_t pipeline_type_kind_ord_at(uint8_t * arena, int32_t tr);
extern int32_t pipeline_type_named_name_into(uint8_t * arena, int32_t tr, uint8_t * out64);
extern int32_t pipeline_asm_module_func_param_name_len_at(uint8_t * mod, int32_t fi, int32_t pix);
extern void pipeline_asm_module_func_param_name_copy32(uint8_t * mod, int32_t fi, int32_t pix, uint8_t * dst);
extern int32_t pipeline_asm_module_func_num_params_at(uint8_t * mod, int32_t fi);
extern int32_t pipeline_module_num_funcs(uint8_t * mod);
extern int32_t pipeline_asm_module_func_name_len_at(uint8_t * mod, int32_t fi);
extern void pipeline_asm_module_func_name_copy64(uint8_t * mod, int32_t fi, uint8_t * dst);
extern int32_t pipeline_module_func_body_ref_at(uint8_t * mod, int32_t fi);
extern int32_t pipeline_asm_block_final_expr_ref_at(uint8_t * arena, int32_t body);
extern int32_t pipeline_expr_unary_operand_ref_at(uint8_t * arena, int32_t er);
extern int32_t ast_ast_block_num_expr_stmts(uint8_t * arena, int32_t body);
extern int32_t ast_ast_block_expr_stmt_ref(uint8_t * arena, int32_t body, int32_t ei);
extern int32_t pipeline_expr_struct_lit_num_fields(uint8_t * arena, int32_t lit);
extern int32_t pipeline_expr_struct_lit_field_name_len(uint8_t * arena, int32_t lit, int32_t j);
extern void pipeline_expr_struct_lit_field_name_into(uint8_t * arena, int32_t lit, int32_t j, uint8_t * dst);
extern int32_t pipeline_expr_kind_ord_at(uint8_t * arena, int32_t er);
extern int32_t pipeline_asm_emit_func_param_is_indirect_struct_slot_c(uint8_t * arena, uint8_t * mod, int32_t er);
extern int32_t pipeline_asm_var_is_emit_func_param_ptr_c(uint8_t * arena, uint8_t * mod, uint8_t * asm_ctx, int32_t er);
extern int32_t pipeline_asm_index_elem_byte_sz(uint8_t * arena, int32_t index_expr_ref);
extern int32_t pipeline_asm_array_lit_elem_type_ref(uint8_t * arena, int32_t array_lit);
extern int32_t pipeline_expr_var_name_len(uint8_t * arena, int32_t er);
extern void pipeline_expr_var_name_into(uint8_t * arena, int32_t er, uint8_t * out);
extern int32_t backend_fold_func_return_operand_ref(uint8_t * arena, uint8_t * mod, int32_t fi);
int32_t glue_module_func_index_by_name(uint8_t * mod, uint8_t * name, int32_t nlen) {
  if ((mod ==0)) {
    return (0 - 1);
  }
  if ((name ==0)) {
    return (0 - 1);
  }
  if ((nlen <=0)) {
    return (0 - 1);
  }
  if ((nlen > 63)) {
    return (0 - 1);
  }
  {
    int32_t nfuncs = pipeline_module_num_funcs(mod);
    int32_t fi = 0;
    while ((fi < nfuncs)) {
      int32_t flen = pipeline_asm_module_func_name_len_at(mod, fi);
      if ((flen ==nlen)) {
        uint8_t fb[64] = {};
        (void)(pipeline_asm_module_func_name_copy64(mod, fi, &((fb)[0])));
        int32_t k = 0;
        int32_t ok = 1;
        while ((k < nlen)) {
          if (((fb)[k] !=(name)[k])) {
            (void)((ok = 0));
            break;
          }
          (void)((k = (k + 1)));
        }
        if ((ok !=0)) {
          return fi;
        }
      }
      (void)((fi = (fi + 1)));
    }
  }
  return (0 - 1);
}
int32_t glue_const_scalar_binop_eval_i32(int32_t ko, int32_t a, int32_t b, int32_t * out) {
  if ((out ==0)) {
    return 0;
  }
  int64_t wide = 0;
  if ((ko ==4)) {
    (void)((wide = (((int64_t)(a)) + ((int64_t)(b)))));
  } else {
    if ((ko ==5)) {
      (void)((wide = (((int64_t)(a)) - ((int64_t)(b)))));
    } else {
      if ((ko ==6)) {
        (void)((wide = (((int64_t)(a)) * ((int64_t)(b)))));
      } else {
        if ((ko ==7)) {
          if ((b ==0)) {
            return 0;
          }
          (void)((wide = (((int64_t)(a)) / ((int64_t)(b)))));
        } else {
          if ((ko ==8)) {
            if ((b ==0)) {
              return 0;
            }
            (void)((wide = (((int64_t)(a)) % ((int64_t)(b)))));
          } else {
            return 0;
          }
        }
      }
    }
  }
  {
    (void)(((out)[0] = ((int32_t)(wide))));
  }
  return 1;
}
int32_t glue_module_named_type_has_struct_layout(uint8_t * mod, uint8_t * name, int32_t nlen) {
  if ((mod ==0)) {
    return 0;
  }
  if ((name ==0)) {
    return 0;
  }
  if ((nlen <=0)) {
    return 0;
  }
  {
    int32_t n = pipeline_module_num_struct_layouts_at(mod);
    int32_t k = 0;
    while ((k < n)) {
      int32_t ln = pipeline_module_struct_layout_name_len(mod, k);
      if ((ln ==nlen)) {
        if ((ln > 0)) {
          int32_t j = 0;
          int32_t ok = 1;
          while ((j < nlen)) {
            if ((pipeline_module_struct_layout_name_byte_at(mod, k, j) !=(name)[j])) {
              (void)((ok = 0));
              break;
            }
            (void)((j = (j + 1)));
          }
          if ((ok !=0)) {
            return 1;
          }
        }
      }
      (void)((k = (k + 1)));
    }
  }
  return 0;
}
int32_t glue_type_ref_is_named_struct_layout(uint8_t * arena, uint8_t * mod, int32_t ty_ref) {
  if ((ty_ref <=0)) {
    return 0;
  }
  if ((mod ==0)) {
    return 0;
  }
  {
    uint8_t nm[64] = {};
    int32_t nlen = pipeline_type_named_name_into(arena, ty_ref, &((nm)[0]));
    if ((pipeline_type_kind_ord_at(arena, ty_ref) !=8)) {
      return 0;
    }
    if ((nlen <=0)) {
      return 0;
    }
    return glue_module_named_type_has_struct_layout(mod, &((nm)[0]), nlen);
  }
  return 0;
}
uint8_t * g02f_load_ptr_at(uint8_t * p, int32_t off) {
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
void g02f_store_ptr_at(uint8_t * p, int32_t off, uint8_t * val) {
  if ((p ==0)) {
    return;
  }
  size_t a = ((size_t)(val));
  size_t m = 256;
  (void)(((p)[(off + 0)] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[(off + 1)] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[(off + 2)] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[(off + 3)] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[(off + 4)] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[(off + 5)] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[(off + 6)] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[(off + 7)] = ((uint8_t)((a % m)))));
}
int32_t asm_local_var_slot_holds_indirect_ptr(uint8_t * arena, int32_t expr_ref, uint8_t * mod, uint8_t * asm_ctx) {
  if ((arena ==0)) {
    return 0;
  }
  if ((expr_ref <=0)) {
    return 0;
  }
  int32_t has_block_decl = 0;
  int32_t decl_ty = 0;
  int32_t ko = 0;
  {
    (void)((ko = pipeline_expr_kind_ord_at(arena, expr_ref)));
  }
  if ((asm_ctx !=0)) {
    if ((ko ==3)) {
      int32_t vlen = 0;
      {
        (void)((vlen = pipeline_expr_var_name_len(arena, expr_ref)));
      }
      if ((vlen > 0)) {
        if ((vlen <=63)) {
          uint8_t vname[64] = {};
          {
            (void)(pipeline_expr_var_name_into(arena, expr_ref, &((vname)[0])));
          }
          int32_t scope_br = 0;
          {
            (void)((scope_br = asm_ctx_scope_block_ref_at(asm_ctx)));
          }
          if ((scope_br > 0)) {
            {
              (void)((decl_ty = pipeline_block_resolve_var_type_ref(arena, scope_br, &((vname)[0]), vlen)));
            }
            if ((decl_ty > 0)) {
              (void)((has_block_decl = 1));
            }
          }
        }
      }
    }
  }
  if ((has_block_decl !=0)) {
    int32_t kind = 0;
    {
      (void)((kind = pipeline_type_kind_ord_at(arena, decl_ty)));
    }
    if ((kind ==9)) {
      return 1;
    }
    if ((glue_type_ref_is_named_struct_layout(arena, mod, decl_ty) !=0)) {
      return 0;
    }
    return 0;
  }
  int32_t tr = 0;
  {
    (void)((tr = pipeline_expr_resolved_type_ref(arena, expr_ref)));
  }
  if ((tr <=0)) {
    {
      if ((pipeline_asm_var_is_emit_func_param_ptr_c(arena, mod, asm_ctx, expr_ref) !=0)) {
        return 1;
      }
      if ((mod !=0)) {
        if ((pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena, mod, expr_ref) !=0)) {
          return 1;
        }
      }
    }
    return 0;
  }
  int32_t kind2 = 0;
  {
    (void)((kind2 = pipeline_type_kind_ord_at(arena, tr)));
  }
  if ((kind2 ==9)) {
    return 1;
  }
  if ((glue_type_ref_is_named_struct_layout(arena, mod, tr) !=0)) {
    if ((mod !=0)) {
      {
        if ((pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena, mod, expr_ref) !=0)) {
          return 1;
        }
      }
    }
    return 0;
  }
  if ((kind2 ==8)) {
    return 0;
  }
  {
    if ((pipeline_asm_var_is_emit_func_param_ptr_c(arena, mod, asm_ctx, expr_ref) !=0)) {
      return 1;
    }
  }
  return 0;
}
int32_t glue_local_var_slot_holds_indirect_ptr(uint8_t * arena, int32_t er, uint8_t * asm_ctx) {
  uint8_t * mod_ref = ((uint8_t *)(0));
  if ((asm_ctx !=0)) {
    (void)((mod_ref = g02f_load_ptr_at(asm_ctx, 16)));
  }
  return asm_local_var_slot_holds_indirect_ptr(arena, er, mod_ref, asm_ctx);
}
int32_t glue_expr_is_func_param_at(uint8_t * arena, uint8_t * mod, int32_t fi, int32_t er, int32_t pix) {
  if ((arena ==0)) {
    return 0;
  }
  if ((mod ==0)) {
    return 0;
  }
  {
    int32_t plen = pipeline_asm_module_func_param_name_len_at(mod, fi, pix);
    int32_t vlen = pipeline_expr_var_name_len(arena, er);
    uint8_t pbuf[32] = {};
    uint8_t vbuf[64] = {};
    int32_t k = 0;
    if ((pipeline_expr_kind_ord_at(arena, er) !=3)) {
      return 0;
    }
    if ((plen <=0)) {
      return 0;
    }
    if ((plen !=vlen)) {
      return 0;
    }
    (void)(pipeline_asm_module_func_param_name_copy32(mod, fi, pix, &((pbuf)[0])));
    (void)(pipeline_expr_var_name_into(arena, er, &((vbuf)[0])));
    while ((k < plen)) {
      if (((pbuf)[k] !=(vbuf)[k])) {
        return 0;
      }
      (void)((k = (k + 1)));
    }
    return 1;
  }
  return 0;
}
int32_t glue_fold_func_return_operand_ref_module(uint8_t * arena, uint8_t * mod, int32_t fi) {
  if ((arena ==0)) {
    return 0;
  }
  if ((mod ==0)) {
    return 0;
  }
  if ((fi < 0)) {
    return 0;
  }
  {
    int32_t body_ref = pipeline_module_func_body_ref_at(mod, fi);
    if ((body_ref <=0)) {
      return 0;
    }
    int32_t fin = pipeline_asm_block_final_expr_ref_at(arena, body_ref);
    if ((fin !=0)) {
      if ((pipeline_expr_kind_ord_at(arena, fin) ==41)) {
        int32_t op_e = pipeline_expr_unary_operand_ref_at(arena, fin);
        if ((op_e !=0)) {
          return op_e;
        }
      }
      return fin;
    }
    int32_t nes = ast_ast_block_num_expr_stmts(arena, body_ref);
    int32_t found = 0;
    int32_t op_ref = 0;
    int32_t ei = 0;
    while ((ei < nes)) {
      int32_t er = ast_ast_block_expr_stmt_ref(arena, body_ref, ei);
      if ((er > 0)) {
        if ((pipeline_expr_kind_ord_at(arena, er) ==41)) {
          int32_t op_e = pipeline_expr_unary_operand_ref_at(arena, er);
          if ((op_e !=0)) {
            (void)((found = (found + 1)));
            (void)((op_ref = op_e));
          }
        }
      }
      (void)((ei = (ei + 1)));
    }
    if ((found ==1)) {
      return op_ref;
    }
  }
  return 0;
}
int32_t glue_try_fold_func_return_operand_ref(uint8_t * arena, uint8_t * mod, int32_t fi) {
  {
    int32_t r = backend_fold_func_return_operand_ref(arena, mod, fi);
    if ((r > 0)) {
      return r;
    }
    return glue_fold_func_return_operand_ref_module(arena, mod, fi);
  }
  return 0;
}
extern int32_t backend_enc_load_rbp_to_rax_arch(uint8_t * elf, int32_t offset, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rax_arch(uint8_t * elf, int32_t offset, int32_t ta);
extern int32_t backend_arch_emit_load_rbp_to_rax(uint8_t * out, int32_t off, int32_t ta);
extern int32_t backend_arch_emit_lea_rbp_to_rax(uint8_t * out, int32_t off, int32_t ta);
extern int32_t pipeline_expr_call_resolved_dep_index_at(uint8_t * arena, int32_t call);
extern int32_t pipeline_expr_call_resolved_func_index_at(uint8_t * arena, int32_t call);
extern uint8_t * pipeline_dep_ctx_arena_at(uint8_t * pctx, int32_t di);
extern uint8_t * pipeline_asm_emit_dep_pipe_c_retu8_ptr(void);
extern int32_t pipeline_expr_call_arg_ref(uint8_t * arena, int32_t er, int32_t idx);
extern int32_t pipeline_expr_call_callee_ref_at(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_field_access_name_len_u8_ptr_i32_reti32(uint8_t * arena, int32_t er);
extern void pipeline_expr_field_access_name_into_u8_ptr_i32_u8_ptr(uint8_t * arena, int32_t er, uint8_t * out);
extern int32_t pipeline_expr_array_lit_num_elems_at(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_array_lit_elem_ref(uint8_t * arena, int32_t er, int32_t lane);
extern int32_t pipeline_expr_struct_lit_init_ref(uint8_t * arena, int32_t lit, int32_t fj);
extern int32_t pipeline_module_func_return_type_at(uint8_t * mod, int32_t fi);
extern int32_t asm_type_is_simd_vector_spelling(uint8_t * arena, int32_t tr);
extern int32_t asm_type_is_simd_vector(uint8_t * arena, int32_t tr);
extern int32_t pipeline_expr_binop_left_ref_at_u8_ptr_i32_reti32(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_binop_right_ref_at_u8_ptr_i32_reti32(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_index_base_ref(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_index_index_ref(uint8_t * arena, int32_t er);
extern int32_t pipeline_dep_ctx_ndep_u8_ptr_reti32(uint8_t * pctx);
extern uint8_t * pipeline_dep_ctx_module_at_u8_ptr_i32_retu8_ptr(uint8_t * pctx, int32_t di);
extern int32_t pipeline_module_struct_layout_num_fields(uint8_t * mod, int32_t li);
extern int32_t pipeline_module_struct_layout_field_name_len(uint8_t * mod, int32_t li, int32_t j);
extern void pipeline_module_struct_layout_field_name_into(uint8_t * mod, int32_t li, int32_t j, uint8_t * dst);
extern int32_t pipeline_module_struct_layout_field_offset_at(uint8_t * mod, int32_t li, int32_t j);
extern int32_t pipeline_expr_field_access_base_ref_u8_ptr_i32_reti32(uint8_t * arena, int32_t er);
extern int32_t pipeline_asm_emit_func_index_c(void);
extern int32_t pipeline_type_elem_ref_at(uint8_t * arena, int32_t tr);
extern int32_t typeck_get_field_offset_from_layout_deps(uint8_t * mod, uint8_t * pctx, uint8_t * tname, int32_t tlen, uint8_t * fname, int32_t flen);
extern int32_t pipeline_expr_field_access_layout_offset(uint8_t * arena, uint8_t * mod, int32_t fa);
int32_t glue_call_lookup_callee_mod_fi_arena(uint8_t * caller_arena, int32_t call_ref, uint8_t * ctx, uint8_t * out_ca, uint8_t * out_cm, int32_t * out_fi) {
  if ((caller_arena ==0)) {
    return 0;
  }
  if ((call_ref <=0)) {
    return 0;
  }
  if ((ctx ==0)) {
    return 0;
  }
  if ((out_ca ==0)) {
    return 0;
  }
  if ((out_cm ==0)) {
    return 0;
  }
  if ((out_fi ==0)) {
    return 0;
  }
  {
    uint8_t * entry_mod = g02f_load_ptr_at(ctx, 16);
    if ((entry_mod ==0)) {
      return 0;
    }
    (void)(g02f_store_ptr_at(out_ca, 0, caller_arena));
    (void)(g02f_store_ptr_at(out_cm, 0, entry_mod));
    (void)(((out_fi)[0] = (0 - 1)));
    int32_t dep_ix = pipeline_expr_call_resolved_dep_index_at(caller_arena, call_ref);
    int32_t func_ix = pipeline_expr_call_resolved_func_index_at(caller_arena, call_ref);
    if ((func_ix >=0)) {
      (void)(((out_fi)[0] = func_ix));
      if ((dep_ix >=0)) {
        uint8_t * pctx = g02f_load_ptr_at(ctx, 1256);
        if ((pctx ==0)) {
          (void)((pctx = pipeline_asm_emit_dep_pipe_c_retu8_ptr()));
        }
        if ((pctx ==0)) {
          return 0;
        }
        uint8_t * cm = pipeline_dep_ctx_module_at_u8_ptr_i32_retu8_ptr(pctx, dep_ix);
        if ((cm ==0)) {
          return 0;
        }
        (void)(g02f_store_ptr_at(out_cm, 0, cm));
        uint8_t * da = pipeline_dep_ctx_arena_at(pctx, dep_ix);
        if ((da !=0)) {
          (void)(g02f_store_ptr_at(out_ca, 0, da));
        }
      }
      if ((g02f_load_ptr_at(out_cm, 0) !=0)) {
        return 1;
      }
      return 0;
    }
    int32_t callee_ref = pipeline_expr_call_callee_ref_at(caller_arena, call_ref);
    if ((callee_ref <=0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(caller_arena, callee_ref) ==44)) {
      int32_t field_len = pipeline_expr_field_access_name_len_u8_ptr_i32_reti32(caller_arena, callee_ref);
      if ((field_len > 0)) {
        if ((field_len <=63)) {
          uint8_t field_name[64] = {};
          (void)(pipeline_expr_field_access_name_into_u8_ptr_i32_u8_ptr(caller_arena, callee_ref, &((field_name)[0])));
          uint8_t * pctx2 = g02f_load_ptr_at(ctx, 1256);
          if ((pctx2 ==0)) {
            (void)((pctx2 = pipeline_asm_emit_dep_pipe_c_retu8_ptr()));
          }
          if ((pctx2 !=0)) {
            int32_t j = 0;
            int32_t nd = pipeline_dep_ctx_ndep_u8_ptr_reti32(pctx2);
            while ((j < nd)) {
              uint8_t * dm = pipeline_dep_ctx_module_at_u8_ptr_i32_retu8_ptr(pctx2, j);
              uint8_t * da2 = pipeline_dep_ctx_arena_at(pctx2, j);
              if ((dm !=0)) {
                int32_t fi2 = glue_module_func_index_by_name(dm, &((field_name)[0]), field_len);
                if ((fi2 >=0)) {
                  (void)(((out_fi)[0] = fi2));
                  (void)(g02f_store_ptr_at(out_cm, 0, dm));
                  if ((da2 !=0)) {
                    (void)(g02f_store_ptr_at(out_ca, 0, da2));
                  }
                  return 1;
                }
              }
              (void)((j = (j + 1)));
            }
          }
        }
      }
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(caller_arena, callee_ref) !=3)) {
      return 0;
    }
    int32_t clen = pipeline_expr_var_name_len(caller_arena, callee_ref);
    if ((clen <=0)) {
      return 0;
    }
    if ((clen > 63)) {
      return 0;
    }
    uint8_t cname[64] = {};
    (void)(pipeline_expr_var_name_into(caller_arena, callee_ref, &((cname)[0])));
    int32_t fi3 = glue_module_func_index_by_name(entry_mod, &((cname)[0]), clen);
    if ((fi3 >=0)) {
      (void)(((out_fi)[0] = fi3));
      return 1;
    }
    uint8_t * pctx3 = g02f_load_ptr_at(ctx, 1256);
    if ((pctx3 ==0)) {
      (void)((pctx3 = pipeline_asm_emit_dep_pipe_c_retu8_ptr()));
    }
    if ((pctx3 ==0)) {
      return 0;
    }
    int32_t j2 = 0;
    int32_t nd2 = pipeline_dep_ctx_ndep_u8_ptr_reti32(pctx3);
    while ((j2 < nd2)) {
      uint8_t * dm2 = pipeline_dep_ctx_module_at_u8_ptr_i32_retu8_ptr(pctx3, j2);
      uint8_t * da3 = pipeline_dep_ctx_arena_at(pctx3, j2);
      if ((dm2 !=0)) {
        int32_t fi4 = glue_module_func_index_by_name(dm2, &((cname)[0]), clen);
        if ((fi4 >=0)) {
          (void)(((out_fi)[0] = fi4));
          (void)(g02f_store_ptr_at(out_cm, 0, dm2));
          if ((da3 !=0)) {
            (void)(g02f_store_ptr_at(out_ca, 0, da3));
          }
          return 1;
        }
      }
      (void)((j2 = (j2 + 1)));
    }
  }
  return 0;
}
int32_t glue_fold_func_returns_param01_scalar_binop(uint8_t * arena, uint8_t * mod, int32_t func_idx, int32_t * out_binop_ko) {
  if ((out_binop_ko ==0)) {
    return 0;
  }
  if ((arena ==0)) {
    return 0;
  }
  if ((mod ==0)) {
    return 0;
  }
  if ((func_idx < 0)) {
    return 0;
  }
  {
    int32_t ret_ty = pipeline_module_func_return_type_at(mod, func_idx);
    int32_t ret_ref = glue_try_fold_func_return_operand_ref(arena, mod, func_idx);
    int32_t ko = pipeline_expr_kind_ord_at(arena, ret_ref);
    int32_t al = pipeline_expr_binop_left_ref_at_u8_ptr_i32_reti32(arena, ret_ref);
    int32_t ar = pipeline_expr_binop_right_ref_at_u8_ptr_i32_reti32(arena, ret_ref);
    if ((pipeline_asm_module_func_num_params_at(mod, func_idx) !=2)) {
      return 0;
    }
    if ((ret_ty > 0)) {
      if ((asm_type_is_simd_vector_spelling(arena, ret_ty) !=0)) {
        return 0;
      }
      if ((asm_type_is_simd_vector(arena, ret_ty) !=0)) {
        return 0;
      }
    }
    if ((ret_ref <=0)) {
      return 0;
    }
    if ((ko !=4)) {
      if ((ko !=5)) {
        if ((ko !=6)) {
          if ((ko !=7)) {
            if ((ko !=8)) {
              return 0;
            }
          }
        }
      }
    }
    if ((glue_expr_is_func_param_at(arena, mod, func_idx, al, 0) ==0)) {
      return 0;
    }
    if ((glue_expr_is_func_param_at(arena, mod, func_idx, ar, 1) ==0)) {
      return 0;
    }
    (void)(((out_binop_ko)[0] = ko));
    return 1;
  }
  return 0;
}
int32_t glue_enc_local_slot_ptr_or_addr(uint8_t * arena, uint8_t * elf, int32_t arg_ref, int32_t slot_off, int32_t ta, uint8_t * asm_ctx) {
  {
    if ((glue_local_var_slot_holds_indirect_ptr(arena, arg_ref, asm_ctx) !=0)) {
      return backend_enc_load_rbp_to_rax_arch(elf, slot_off, ta);
    }
    return backend_enc_lea_rbp_to_rax_arch(elf, slot_off, ta);
  }
  return 0;
}
int32_t glue_arch_emit_local_slot_ptr_or_addr_text(uint8_t * arena, uint8_t * out, int32_t arg_ref, int32_t slot_off, int32_t ta, uint8_t * asm_ctx) {
  {
    if ((glue_local_var_slot_holds_indirect_ptr(arena, arg_ref, asm_ctx) !=0)) {
      return backend_arch_emit_load_rbp_to_rax(out, slot_off, ta);
    }
    return backend_arch_emit_lea_rbp_to_rax(out, slot_off, ta);
  }
  return 0;
}
int32_t glue_struct_lit_field_init_param_index(uint8_t * arena, uint8_t * mod, int32_t fi, int32_t lit, int32_t fj, int32_t * out_pix) {
  if ((out_pix ==0)) {
    return (0 - 1);
  }
  {
    int32_t init_ref = pipeline_expr_struct_lit_init_ref(arena, lit, fj);
    if ((init_ref <=0)) {
      return (0 - 1);
    }
    int32_t np = pipeline_asm_module_func_num_params_at(mod, fi);
    int32_t pi = 0;
    while ((pi < np)) {
      if ((glue_expr_is_func_param_at(arena, mod, fi, init_ref, pi) !=0)) {
        (void)(((out_pix)[0] = pi));
        return 0;
      }
      (void)((pi = (pi + 1)));
    }
  }
  return (0 - 1);
}
int32_t glue_fold_func_returns_param_struct_lit(uint8_t * arena, uint8_t * mod, int32_t func_idx, int32_t * out_lit_ref) {
  if ((out_lit_ref ==0)) {
    return 0;
  }
  if ((arena ==0)) {
    return 0;
  }
  if ((mod ==0)) {
    return 0;
  }
  {
    int32_t ret_ref = glue_fold_func_return_operand_ref_module(arena, mod, func_idx);
    if ((ret_ref <=0)) {
      (void)((ret_ref = backend_fold_func_return_operand_ref(arena, mod, func_idx)));
    }
    if ((ret_ref <=0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, ret_ref) !=45)) {
      return 0;
    }
    int32_t nf = pipeline_expr_struct_lit_num_fields(arena, ret_ref);
    if ((nf <=0)) {
      return 0;
    }
    if ((nf > 8)) {
      return 0;
    }
    int32_t fj = 0;
    while ((fj < nf)) {
      int32_t pix = 0;
      if ((glue_struct_lit_field_init_param_index(arena, mod, func_idx, ret_ref, fj, &(pix)) !=0)) {
        return 0;
      }
      (void)((fj = (fj + 1)));
    }
    (void)(((out_lit_ref)[0] = ret_ref));
    return 1;
  }
  return 0;
}
int32_t glue_struct_lit_field_index_by_name(uint8_t * arena, int32_t lit_ref, uint8_t * fn, int32_t fnlen) {
  if ((arena ==0)) {
    return (0 - 1);
  }
  if ((fn ==0)) {
    return (0 - 1);
  }
  {
    int32_t nf = pipeline_expr_struct_lit_num_fields(arena, lit_ref);
    int32_t j = 0;
    while ((j < nf)) {
      int32_t slen = pipeline_expr_struct_lit_field_name_len(arena, lit_ref, j);
      if ((slen ==fnlen)) {
        if ((slen > 0)) {
          if ((slen <=63)) {
            uint8_t sb[64] = {};
            (void)(pipeline_expr_struct_lit_field_name_into(arena, lit_ref, j, &((sb)[0])));
            int32_t k = 0;
            int32_t ok = 1;
            while ((k < slen)) {
              if (((sb)[k] !=(fn)[k])) {
                (void)((ok = 0));
                break;
              }
              (void)((k = (k + 1)));
            }
            if ((ok !=0)) {
              return j;
            }
          }
        }
      }
      (void)((j = (j + 1)));
    }
  }
  return (0 - 1);
}
int32_t glue_inner_call_arg_for_field_access(uint8_t * arena, uint8_t * ctx, int32_t inner_call_ref, int32_t outer_field_ref, int32_t * out_arg_ref) {
  if ((out_arg_ref ==0)) {
    return 0;
  }
  if ((inner_call_ref <=0)) {
    return 0;
  }
  if ((outer_field_ref <=0)) {
    return 0;
  }
  if ((ctx ==0)) {
    return 0;
  }
  if ((arena ==0)) {
    return 0;
  }
  {
    uint8_t ca_slot[8] = {};
    uint8_t cm_slot[8] = {};
    int32_t inner_fi = 0;
    uint8_t * callee_arena = g02f_load_ptr_at(&((ca_slot)[0]), 0);
    uint8_t * callee_mod = g02f_load_ptr_at(&((cm_slot)[0]), 0);
    int32_t lit_ref = 0;
    int32_t flen = pipeline_expr_field_access_name_len_u8_ptr_i32_reti32(arena, outer_field_ref);
    uint8_t fname[64] = {};
    int32_t fj = glue_struct_lit_field_index_by_name(callee_arena, lit_ref, &((fname)[0]), flen);
    int32_t pix = 0;
    int32_t arg = pipeline_expr_call_arg_ref(arena, inner_call_ref, pix);
    if ((pipeline_expr_kind_ord_at(arena, inner_call_ref) !=48)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, outer_field_ref) !=44)) {
      return 0;
    }
    if ((glue_call_lookup_callee_mod_fi_arena(arena, inner_call_ref, ctx, &((ca_slot)[0]), &((cm_slot)[0]), &(inner_fi)) ==0)) {
      return 0;
    }
    if ((glue_fold_func_returns_param_struct_lit(callee_arena, callee_mod, inner_fi, &(lit_ref)) ==0)) {
      return 0;
    }
    if ((flen <=0)) {
      return 0;
    }
    if ((flen > 63)) {
      return 0;
    }
    (void)(pipeline_expr_field_access_name_into_u8_ptr_i32_u8_ptr(arena, outer_field_ref, &((fname)[0])));
    if ((fj < 0)) {
      return 0;
    }
    if ((glue_struct_lit_field_init_param_index(callee_arena, callee_mod, inner_fi, lit_ref, fj, &(pix)) !=0)) {
      return 0;
    }
    (void)(((out_arg_ref)[0] = arg));
    if ((arg > 0)) {
      return 1;
    }
  }
  return 0;
}
int32_t glue_dep_module_field_offset_by_name(uint8_t * pctx, uint8_t * field_name, int32_t flen) {
  if ((pctx ==0)) {
    return (0 - 1);
  }
  if ((field_name ==0)) {
    return (0 - 1);
  }
  if ((flen <=0)) {
    return (0 - 1);
  }
  {
    int32_t nd = pipeline_dep_ctx_ndep_u8_ptr_reti32(pctx);
    int32_t di = 0;
    while ((di < nd)) {
      uint8_t * dm = pipeline_dep_ctx_module_at_u8_ptr_i32_retu8_ptr(pctx, di);
      if ((dm !=0)) {
        int32_t nlay = pipeline_module_num_struct_layouts_at(dm);
        int32_t k = 0;
        while ((k < nlay)) {
          int32_t nf = pipeline_module_struct_layout_num_fields(dm, k);
          int32_t j = 0;
          while ((j < nf)) {
            int32_t fnlen = pipeline_module_struct_layout_field_name_len(dm, k, j);
            if ((fnlen ==flen)) {
              if ((fnlen > 0)) {
                if ((fnlen <=63)) {
                  uint8_t fb[64] = {};
                  (void)(pipeline_module_struct_layout_field_name_into(dm, k, j, &((fb)[0])));
                  int32_t fi = 0;
                  int32_t feq = 1;
                  while ((fi < fnlen)) {
                    if (((fb)[fi] !=(field_name)[fi])) {
                      (void)((feq = 0));
                      break;
                    }
                    (void)((fi = (fi + 1)));
                  }
                  if ((feq !=0)) {
                    return pipeline_module_struct_layout_field_offset_at(dm, k, j);
                  }
                }
              }
            }
            (void)((j = (j + 1)));
          }
          (void)((k = (k + 1)));
        }
      }
      (void)((di = (di + 1)));
    }
  }
  return (0 - 1);
}
int32_t glue_inline_var_field_access_offset(uint8_t * arena, uint8_t * mod, uint8_t * pctx, uint8_t * asm_ctx, int32_t fa_ref) {
  if ((arena ==0)) {
    return (0 - 1);
  }
  if ((mod ==0)) {
    return (0 - 1);
  }
  if ((fa_ref <=0)) {
    return (0 - 1);
  }
  {
    int32_t base_ref = pipeline_expr_field_access_base_ref_u8_ptr_i32_reti32(arena, fa_ref);
    if ((base_ref <=0)) {
      return (0 - 1);
    }
    if ((pipeline_expr_kind_ord_at(arena, base_ref) !=3)) {
      return (0 - 1);
    }
    int32_t base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
    int32_t scope_br = 0;
    if ((asm_ctx !=0)) {
      (void)((scope_br = asm_ctx_scope_block_ref_at(asm_ctx)));
    }
    if ((base_ty <=0)) {
      if ((scope_br > 0)) {
        int32_t vlen = pipeline_expr_var_name_len(arena, base_ref);
        if ((vlen > 0)) {
          if ((vlen <=63)) {
            uint8_t vname[64] = {};
            (void)(pipeline_expr_var_name_into(arena, base_ref, &((vname)[0])));
            (void)((base_ty = pipeline_block_resolve_var_type_ref(arena, scope_br, &((vname)[0]), vlen)));
          }
        }
      }
    }
    if ((base_ty <=0)) {
      if ((asm_ctx !=0)) {
        int32_t fi = pipeline_asm_emit_func_index_c();
        int32_t vlen = pipeline_expr_var_name_len(arena, base_ref);
        if ((fi >=0)) {
          if ((fi < pipeline_module_num_funcs(mod))) {
            if ((vlen > 0)) {
              if ((vlen <=63)) {
                uint8_t vname[64] = {};
                (void)(pipeline_expr_var_name_into(arena, base_ref, &((vname)[0])));
                int32_t body_ref = pipeline_module_func_body_ref_at(mod, fi);
                if ((body_ref > 0)) {
                  (void)((base_ty = pipeline_block_resolve_var_type_ref(arena, body_ref, &((vname)[0]), vlen)));
                }
              }
            }
          }
        }
      }
    }
    int32_t flen = pipeline_expr_field_access_name_len_u8_ptr_i32_reti32(arena, fa_ref);
    if ((flen <=0)) {
      return (0 - 1);
    }
    if ((flen > 63)) {
      return (0 - 1);
    }
    uint8_t field_name[64] = {};
    (void)(pipeline_expr_field_access_name_into_u8_ptr_i32_u8_ptr(arena, fa_ref, &((field_name)[0])));
    if ((pctx !=0)) {
      int32_t off = glue_dep_module_field_offset_by_name(pctx, &((field_name)[0]), flen);
      if ((off >=0)) {
        return off;
      }
    }
    if ((base_ty <=0)) {
      return (0 - 1);
    }
    int32_t kind = pipeline_type_kind_ord_at(arena, base_ty);
    if ((kind ==9)) {
      (void)((base_ty = pipeline_type_elem_ref_at(arena, base_ty)));
      if ((base_ty <=0)) {
        return (0 - 1);
      }
      (void)((kind = pipeline_type_kind_ord_at(arena, base_ty)));
    }
    if ((kind !=8)) {
      return (0 - 1);
    }
    uint8_t struct_name[64] = {};
    int32_t nlen = pipeline_type_named_name_into(arena, base_ty, &((struct_name)[0]));
    if ((pctx !=0)) {
      int32_t off2 = typeck_get_field_offset_from_layout_deps(mod, pctx, &((struct_name)[0]), nlen, &((field_name)[0]), flen);
      if ((off2 >=0)) {
        return off2;
      }
    }
    return pipeline_expr_field_access_layout_offset(arena, mod, fa_ref);
  }
  return (0 - 1);
}
int32_t glue_try_array_lit_lane_const_i32(uint8_t * arena, int32_t arr_ref, int32_t lane, int32_t * out) {
  if ((arena ==0)) {
    return 0;
  }
  if ((arr_ref <=0)) {
    return 0;
  }
  if ((out ==0)) {
    return 0;
  }
  if ((lane < 0)) {
    return 0;
  }
  {
    int32_t elem_ref = pipeline_expr_array_lit_elem_ref(arena, arr_ref, lane);
    if ((pipeline_expr_kind_ord_at(arena, arr_ref) !=46)) {
      return 0;
    }
    if ((lane >=pipeline_expr_array_lit_num_elems_at(arena, arr_ref))) {
      return 0;
    }
    return glue_try_expr_const_i32(arena, elem_ref, out);
  }
  return 0;
}
int32_t glue_fold_func_returns_param01_vector_binop(uint8_t * arena, uint8_t * mod, int32_t func_idx, int32_t * out_binop_ko) {
  if ((out_binop_ko ==0)) {
    return 0;
  }
  if ((arena ==0)) {
    return 0;
  }
  if ((mod ==0)) {
    return 0;
  }
  if ((func_idx < 0)) {
    return 0;
  }
  {
    int32_t ret_ty = pipeline_module_func_return_type_at(mod, func_idx);
    int32_t ret_ref = glue_try_fold_func_return_operand_ref(arena, mod, func_idx);
    int32_t ko = pipeline_expr_kind_ord_at(arena, ret_ref);
    int32_t al = pipeline_expr_binop_left_ref_at_u8_ptr_i32_reti32(arena, ret_ref);
    int32_t ar = pipeline_expr_binop_right_ref_at_u8_ptr_i32_reti32(arena, ret_ref);
    if ((pipeline_asm_module_func_num_params_at(mod, func_idx) !=2)) {
      return 0;
    }
    if ((ret_ref <=0)) {
      return 0;
    }
    if ((glue_is_vector_lane_scalar_binop_ko(ko) ==0)) {
      return 0;
    }
    if ((ret_ty > 0)) {
      if ((asm_type_is_simd_vector_spelling(arena, ret_ty) ==0)) {
        if ((asm_type_is_simd_vector(arena, ret_ty) ==0)) {
          if ((ko !=51)) {
            return 0;
          }
        }
      }
    }
    if ((ko ==51)) {
      (void)((ko = 4));
    }
    if ((glue_expr_is_func_param_at(arena, mod, func_idx, al, 0) ==0)) {
      return 0;
    }
    if ((glue_expr_is_func_param_at(arena, mod, func_idx, ar, 1) ==0)) {
      return 0;
    }
    (void)(((out_binop_ko)[0] = ko));
    return 1;
  }
  return 0;
}
int32_t glue_fold_func_returns_param0_index_const(uint8_t * arena, uint8_t * mod, int32_t func_idx, int32_t * out_lane) {
  if ((out_lane ==0)) {
    return 0;
  }
  if ((arena ==0)) {
    return 0;
  }
  if ((mod ==0)) {
    return 0;
  }
  if ((func_idx < 0)) {
    return 0;
  }
  {
    int32_t ret_ref = glue_try_fold_func_return_operand_ref(arena, mod, func_idx);
    int32_t base_ref = pipeline_expr_index_base_ref(arena, ret_ref);
    int32_t idx_ref = pipeline_expr_index_index_ref(arena, ret_ref);
    int32_t lane = 0;
    if ((pipeline_asm_module_func_num_params_at(mod, func_idx) !=1)) {
      return 0;
    }
    if ((ret_ref <=0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, ret_ref) !=47)) {
      return 0;
    }
    if ((glue_expr_is_func_param_at(arena, mod, func_idx, base_ref, 0) ==0)) {
      return 0;
    }
    if ((glue_try_expr_const_i32(arena, idx_ref, &(lane)) ==0)) {
      return 0;
    }
    (void)(((out_lane)[0] = lane));
    return 1;
  }
  return 0;
}
extern int32_t pipeline_expr_call_num_args_at(uint8_t * arena, int32_t er);
extern int32_t glue_with_arena_scope_active_c(void);
extern int32_t glue_with_arena_scope_top_off_c(void);
extern int32_t backend_enc_mov_imm64_to_rax_arch(uint8_t * elf, int32_t lo, int32_t hi, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(uint8_t * elf, int32_t off, int32_t sz, int32_t ta);
extern int32_t backend_enc_call_arch(uint8_t * elf, uint8_t * name, int32_t nlen, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(uint8_t * elf, int32_t imm, int32_t ta);
int32_t glue_call_is_zero_arg_default_alloc(uint8_t * arena, int32_t call_ref) {
  if ((arena ==0)) {
    return 0;
  }
  if ((call_ref <=0)) {
    return 0;
  }
  {
    int32_t callee_ref = pipeline_expr_call_callee_ref_at(arena, call_ref);
    int32_t ko = pipeline_expr_kind_ord_at(arena, callee_ref);
    uint8_t nm[64] = {};
    if ((pipeline_expr_kind_ord_at(arena, call_ref) !=48)) {
      return 0;
    }
    if ((pipeline_expr_call_num_args_at(arena, call_ref) !=0)) {
      return 0;
    }
    if ((callee_ref <=0)) {
      return 0;
    }
    if ((ko ==3)) {
      int32_t nlen = pipeline_expr_var_name_len(arena, callee_ref);
      if ((nlen !=13)) {
        return 0;
      }
      (void)(pipeline_expr_var_name_into(arena, callee_ref, &((nm)[0])));
      if (((((((((((((((nm)[0] ==100) && ((nm)[1] ==101)) && ((nm)[2] ==102)) && ((nm)[3] ==97)) && ((nm)[4] ==117)) && ((nm)[5] ==108)) && ((nm)[6] ==116)) && ((nm)[7] ==95)) && ((nm)[8] ==97)) && ((nm)[9] ==108)) && ((nm)[10] ==108)) && ((nm)[11] ==111)) && ((nm)[12] ==99))) {
        return 1;
      }
      return 0;
    }
    if ((ko ==44)) {
      int32_t nlen = pipeline_expr_field_access_name_len_u8_ptr_i32_reti32(arena, callee_ref);
      if ((nlen !=13)) {
        return 0;
      }
      (void)(pipeline_expr_field_access_name_into_u8_ptr_i32_u8_ptr(arena, callee_ref, &((nm)[0])));
      if (((((((((((((((nm)[0] ==100) && ((nm)[1] ==101)) && ((nm)[2] ==102)) && ((nm)[3] ==97)) && ((nm)[4] ==117)) && ((nm)[5] ==108)) && ((nm)[6] ==116)) && ((nm)[7] ==95)) && ((nm)[8] ==97)) && ((nm)[9] ==108)) && ((nm)[10] ==108)) && ((nm)[11] ==111)) && ((nm)[12] ==99))) {
        return 1;
      }
      return 0;
    }
  }
  return 0;
}
int32_t glue_const_struct_lit_field_can_inline(uint8_t * arena, uint8_t * mod, int32_t func_idx, int32_t lit_ref, int32_t fj) {
  if ((arena ==0)) {
    return 0;
  }
  {
    int32_t init_ref = pipeline_expr_struct_lit_init_ref(arena, lit_ref, fj);
    if ((init_ref <=0)) {
      return 0;
    }
    int32_t pix = 0;
    if ((glue_struct_lit_field_init_param_index(arena, mod, func_idx, lit_ref, fj, &(pix)) ==0)) {
      return 0;
    }
    int32_t ko = pipeline_expr_kind_ord_at(arena, init_ref);
    if ((ko ==48)) {
      return glue_call_is_zero_arg_default_alloc(arena, init_ref);
    }
    if ((ko ==0)) {
      return 1;
    }
    if ((ko ==1)) {
      return 1;
    }
    if ((ko ==2)) {
      return 1;
    }
  }
  return 0;
}
int32_t glue_emit_default_alloc_to_rbx_offset(uint8_t * elf_ctx, int32_t foff, int32_t fsz, int32_t ta) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  {
    uint8_t da[32] = {};
    int32_t sz = fsz;
    if ((glue_with_arena_scope_active_c() !=0)) {
      int32_t wa_off = glue_with_arena_scope_top_off_c();
      if ((backend_enc_mov_imm64_to_rax_arch(elf_ctx, 1, 0, ta) !=0)) {
        return (0 - 1);
      }
      if ((backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff, 8, ta) !=0)) {
        return (0 - 1);
      }
      if ((backend_enc_lea_rbp_to_rax_arch(elf_ctx, wa_off, ta) !=0)) {
        return (0 - 1);
      }
      if ((backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, (foff + 8), 8, ta) !=0)) {
        return (0 - 1);
      }
      return 0;
    }
    (void)(((da)[0] = 115));
    (void)(((da)[1] = 116));
    (void)(((da)[2] = 100));
    (void)(((da)[3] = 95));
    (void)(((da)[4] = 104));
    (void)(((da)[5] = 101));
    (void)(((da)[6] = 97));
    (void)(((da)[7] = 112));
    (void)(((da)[8] = 95));
    (void)(((da)[9] = 100));
    (void)(((da)[10] = 101));
    (void)(((da)[11] = 102));
    (void)(((da)[12] = 97));
    (void)(((da)[13] = 117));
    (void)(((da)[14] = 108));
    (void)(((da)[15] = 116));
    (void)(((da)[16] = 95));
    (void)(((da)[17] = 97));
    (void)(((da)[18] = 108));
    (void)(((da)[19] = 108));
    (void)(((da)[20] = 111));
    (void)(((da)[21] = 99));
    if ((backend_enc_call_arch(elf_ctx, &((da)[0]), 27, ta) !=0)) {
      return (0 - 1);
    }
    if ((sz <=0)) {
      (void)((sz = 8));
    }
    if ((sz > 16)) {
      (void)((sz = 16));
    }
    if ((backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff, sz, ta) !=0)) {
      return (0 - 1);
    }
    if ((sz >=16)) {
      return 0;
    }
    if ((backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) !=0)) {
      return (0 - 1);
    }
    return backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, (foff + 8), 8, ta);
  }
  return (0 - 1);
}
int32_t glue_fold_func_returns_const_struct_lit(uint8_t * arena, uint8_t * mod, int32_t func_idx, int32_t * out_lit_ref) {
  if ((out_lit_ref ==0)) {
    return 0;
  }
  if ((arena ==0)) {
    return 0;
  }
  if ((mod ==0)) {
    return 0;
  }
  {
    int32_t ret_ref = glue_fold_func_return_operand_ref_module(arena, mod, func_idx);
    if ((ret_ref <=0)) {
      (void)((ret_ref = backend_fold_func_return_operand_ref(arena, mod, func_idx)));
    }
    if ((ret_ref <=0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, ret_ref) !=45)) {
      return 0;
    }
    int32_t nf = pipeline_expr_struct_lit_num_fields(arena, ret_ref);
    if ((nf <=0)) {
      return 0;
    }
    if ((nf > 8)) {
      return 0;
    }
    int32_t fj = 0;
    while ((fj < nf)) {
      int32_t init_ref = pipeline_expr_struct_lit_init_ref(arena, ret_ref, fj);
      if ((init_ref <=0)) {
        return 0;
      }
      int32_t pix = 0;
      if ((glue_struct_lit_field_init_param_index(arena, mod, func_idx, ret_ref, fj, &(pix)) ==0)) {
        return 0;
      }
      int32_t ko = pipeline_expr_kind_ord_at(arena, init_ref);
      if ((ko ==48)) {
        if ((glue_call_is_zero_arg_default_alloc(arena, init_ref) ==0)) {
          return 0;
        }
      } else {
        if ((ko !=0)) {
          if ((ko !=1)) {
            if ((ko !=2)) {
              return 0;
            }
          }
        }
      }
      (void)((fj = (fj + 1)));
    }
    (void)(((out_lit_ref)[0] = ret_ref));
    return 1;
  }
  return 0;
}
int32_t glue_align_up8_c(int32_t n) {
  int32_t m = (n % 8);
  if ((m !=0)) {
    (void)((n = (n + (8 - m))));
  }
  return n;
}
int32_t glue_is_vector_lane_scalar_binop_ko(int32_t ko) {
  if ((ko ==51)) {
    (void)((ko = 4));
  }
  if ((ko < 4)) {
    return 0;
  }
  if ((ko > 13)) {
    return 0;
  }
  return 1;
}
extern int32_t pipeline_expr_int_val_at(uint8_t * arena, int32_t er);
int32_t glue_try_expr_const_i32(uint8_t * arena, int32_t er, int32_t * out) {
  if ((arena ==0)) {
    return 0;
  }
  if ((er <=0)) {
    return 0;
  }
  if ((out ==0)) {
    return 0;
  }
  {
    int32_t ko = pipeline_expr_kind_ord_at(arena, er);
    if ((ko ==0)) {
      (void)(((out)[0] = pipeline_expr_int_val_at(arena, er)));
      return 1;
    }
    if ((ko ==2)) {
      (void)(((out)[0] = pipeline_expr_int_val_at(arena, er)));
      return 1;
    }
  }
  return 0;
}
extern int32_t asm_ctx_local_find_offset_scoped(uint8_t * ctx, uint8_t * arena, uint8_t * name, int32_t nlen);
extern int32_t asm_ctx_local_find_offset(uint8_t * ctx, uint8_t * name, int32_t nlen);
int32_t glue_try_inline_local_slot_off(uint8_t * ctx, uint8_t * arena, uint8_t * name, int32_t nlen) {
  {
    int32_t off = asm_ctx_local_find_offset_scoped(ctx, arena, name, nlen);
    if ((off < 0)) {
      (void)((off = asm_ctx_local_find_offset(ctx, name, nlen)));
    }
    return off;
  }
  return (0 - 1);
}
extern int32_t backend_fold_func_x_plus_k_chain(uint8_t * arena, uint8_t * mod, int32_t fi, int32_t depth);
extern int32_t pipeline_asm_emit_expr_elf_c(uint8_t * arena, uint8_t * elf, int32_t er, uint8_t * ctx, int32_t ta);
extern int32_t backend_enc_add_imm_to_rax_arch(uint8_t * elf, int32_t imm, int32_t ta);
extern int32_t backend_fold_func_returns_param0_single_field(uint8_t * arena, uint8_t * mod, int32_t fi);
extern int32_t backend_fold_func_returns_param0_field_sum(uint8_t * arena, uint8_t * mod, int32_t fi);
extern int32_t backend_enc_load_32_from_rax_arch(uint8_t * elf, int32_t ta);
extern int32_t backend_enc_push_rax_arch(uint8_t * elf, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(uint8_t * elf, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(uint8_t * elf, int32_t ta);
extern int32_t backend_enc_add_rax_rbx_arch(uint8_t * elf, int32_t ta);
extern int32_t pipeline_expr_binop_left_ref_at_u8_ptr_i32_reti32(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_binop_right_ref_at_u8_ptr_i32_reti32(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_field_access_base_ref_u8_ptr_i32_reti32(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_field_access_name_len_u8_ptr_i32_reti32(uint8_t * arena, int32_t er);
extern void pipeline_expr_field_access_name_into_u8_ptr_i32_u8_ptr(uint8_t * arena, int32_t er, uint8_t * out);
extern uint8_t * pipeline_asm_emit_dep_pipe_c_retu8_ptr(void);
extern int32_t pipeline_dep_ctx_ndep_u8_ptr_reti32(uint8_t * pctx);
extern uint8_t * pipeline_dep_ctx_module_at_u8_ptr_i32_retu8_ptr(uint8_t * pctx, int32_t di);
int32_t try_inline_x_plus_k_call_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  if ((arena ==0)) {
    return 0;
  }
  if ((elf_ctx ==0)) {
    return 0;
  }
  if ((ctx ==0)) {
    return 0;
  }
  if ((expr_ref <=0)) {
    return 0;
  }
  {
    uint8_t * mod_ref = g02f_load_ptr_at(ctx, 16);
    if ((mod_ref ==0)) {
      return 0;
    }
    int32_t callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    if ((callee_ref <=0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, callee_ref) !=3)) {
      return 0;
    }
    if ((pipeline_expr_call_num_args_at(arena, expr_ref) !=1)) {
      return 0;
    }
    int32_t clen = pipeline_expr_var_name_len(arena, callee_ref);
    if ((clen <=0)) {
      return 0;
    }
    if ((clen > 63)) {
      return 0;
    }
    uint8_t cname[64] = {};
    (void)(pipeline_expr_var_name_into(arena, callee_ref, &((cname)[0])));
    int32_t fi = glue_module_func_index_by_name(mod_ref, &((cname)[0]), clen);
    if ((fi < 0)) {
      return 0;
    }
    int32_t k = backend_fold_func_x_plus_k_chain(arena, mod_ref, fi, 0);
    if ((k < 0)) {
      return 0;
    }
    if ((k ==0)) {
      int32_t ret_ref = glue_fold_func_return_operand_ref_module(arena, mod_ref, fi);
      if ((ret_ref <=0)) {
        (void)((ret_ref = backend_fold_func_return_operand_ref(arena, mod_ref, fi)));
      }
      if ((ret_ref <=0)) {
        return 0;
      }
      if ((pipeline_expr_kind_ord_at(arena, ret_ref) !=3)) {
        return 0;
      }
      int32_t plen = pipeline_asm_module_func_param_name_len_at(mod_ref, fi, 0);
      int32_t rlen = pipeline_expr_var_name_len(arena, ret_ref);
      if ((plen <=0)) {
        return 0;
      }
      if ((plen > 63)) {
        return 0;
      }
      if ((rlen !=plen)) {
        return 0;
      }
      uint8_t pname[64] = {};
      uint8_t rname[64] = {};
      (void)(pipeline_asm_module_func_param_name_copy32(mod_ref, fi, 0, &((pname)[0])));
      (void)(pipeline_expr_var_name_into(arena, ret_ref, &((rname)[0])));
      int32_t pi = 0;
      while ((pi < plen)) {
        if (((pname)[pi] !=(rname)[pi])) {
          return 0;
        }
        (void)((pi = (pi + 1)));
      }
    }
    int32_t arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
    if ((arg_ref <=0)) {
      return (0 - 1);
    }
    if ((pipeline_asm_emit_expr_elf_c(arena, elf_ctx, arg_ref, ctx, ta) !=0)) {
      return (0 - 1);
    }
    if ((k !=0)) {
      if ((backend_enc_add_imm_to_rax_arch(elf_ctx, k, ta) !=0)) {
        return (0 - 1);
      }
    }
    return 1;
  }
  return 0;
}
int32_t try_inline_param0_single_field_call_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  if ((arena ==0)) {
    return 0;
  }
  if ((elf_ctx ==0)) {
    return 0;
  }
  if ((ctx ==0)) {
    return 0;
  }
  if ((expr_ref <=0)) {
    return 0;
  }
  {
    uint8_t ca_slot[8] = {};
    uint8_t cm_slot[8] = {};
    int32_t fi = 0;
    uint8_t * callee_arena = g02f_load_ptr_at(&((ca_slot)[0]), 0);
    uint8_t * callee_mod = g02f_load_ptr_at(&((cm_slot)[0]), 0);
    int32_t ret_ref = glue_try_fold_func_return_operand_ref(callee_arena, callee_mod, fi);
    int32_t off = pipeline_expr_field_access_layout_offset(callee_arena, callee_mod, ret_ref);
    int32_t arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
    int32_t vlen = pipeline_expr_var_name_len(arena, arg_ref);
    uint8_t vname[64] = {};
    int32_t slot_off = glue_try_inline_local_slot_off(ctx, arena, &((vname)[0]), vlen);
    if ((pipeline_expr_call_num_args_at(arena, expr_ref) !=1)) {
      return 0;
    }
    if ((glue_call_lookup_callee_mod_fi_arena(arena, expr_ref, ctx, &((ca_slot)[0]), &((cm_slot)[0]), &(fi)) ==0)) {
      return 0;
    }
    if ((callee_arena ==0)) {
      return 0;
    }
    if ((callee_mod ==0)) {
      return 0;
    }
    if ((backend_fold_func_returns_param0_single_field(callee_arena, callee_mod, fi) ==0)) {
      return 0;
    }
    if ((ret_ref <=0)) {
      return 0;
    }
    if ((arg_ref <=0)) {
      return (0 - 1);
    }
    if ((pipeline_expr_kind_ord_at(arena, arg_ref) ==48)) {
      int32_t inner_arg = 0;
      if ((glue_inner_call_arg_for_field_access(arena, ctx, arg_ref, ret_ref, &(inner_arg)) ==0)) {
        return 0;
      }
      if ((pipeline_asm_emit_expr_elf_c(arena, elf_ctx, inner_arg, ctx, ta) !=0)) {
        return (0 - 1);
      }
      return 1;
    }
    if ((pipeline_expr_kind_ord_at(arena, arg_ref) !=3)) {
      return 0;
    }
    if ((vlen <=0)) {
      return 0;
    }
    (void)(pipeline_expr_var_name_into(arena, arg_ref, &((vname)[0])));
    if ((slot_off < 0)) {
      return 0;
    }
    if ((glue_enc_local_slot_ptr_or_addr(arena, elf_ctx, arg_ref, slot_off, ta, ctx) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_add_imm_to_rax_arch(elf_ctx, off, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_load_32_from_rax_arch(elf_ctx, ta) !=0)) {
      return (0 - 1);
    }
    return 1;
  }
  return 0;
}
int32_t try_inline_param0_field_sum_call_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  if ((arena ==0)) {
    return 0;
  }
  if ((elf_ctx ==0)) {
    return 0;
  }
  if ((ctx ==0)) {
    return 0;
  }
  if ((expr_ref <=0)) {
    return 0;
  }
  {
    uint8_t ca_slot[8] = {};
    uint8_t cm_slot[8] = {};
    int32_t fi = 0;
    uint8_t * callee_arena = g02f_load_ptr_at(&((ca_slot)[0]), 0);
    uint8_t * callee_mod = g02f_load_ptr_at(&((cm_slot)[0]), 0);
    int32_t ret_ref = glue_try_fold_func_return_operand_ref(callee_arena, callee_mod, fi);
    int32_t al = pipeline_expr_binop_left_ref_at_u8_ptr_i32_reti32(callee_arena, ret_ref);
    int32_t ar = pipeline_expr_binop_right_ref_at_u8_ptr_i32_reti32(callee_arena, ret_ref);
    int32_t off_a = pipeline_expr_field_access_layout_offset(callee_arena, callee_mod, al);
    int32_t off_b = pipeline_expr_field_access_layout_offset(callee_arena, callee_mod, ar);
    int32_t arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
    int32_t vlen = pipeline_expr_var_name_len(arena, arg_ref);
    uint8_t vname[64] = {};
    int32_t slot_off = glue_try_inline_local_slot_off(ctx, arena, &((vname)[0]), vlen);
    if ((pipeline_expr_call_num_args_at(arena, expr_ref) !=1)) {
      return 0;
    }
    if ((glue_call_lookup_callee_mod_fi_arena(arena, expr_ref, ctx, &((ca_slot)[0]), &((cm_slot)[0]), &(fi)) ==0)) {
      return 0;
    }
    if ((callee_arena ==0)) {
      return 0;
    }
    if ((callee_mod ==0)) {
      return 0;
    }
    if ((backend_fold_func_returns_param0_field_sum(callee_arena, callee_mod, fi) ==0)) {
      return 0;
    }
    if ((ret_ref <=0)) {
      return 0;
    }
    if ((arg_ref <=0)) {
      return (0 - 1);
    }
    if ((pipeline_expr_kind_ord_at(arena, arg_ref) ==48)) {
      int32_t inner_arg_a = 0;
      int32_t inner_arg_b = 0;
      if ((glue_inner_call_arg_for_field_access(arena, ctx, arg_ref, al, &(inner_arg_a)) ==0)) {
        return 0;
      }
      if ((glue_inner_call_arg_for_field_access(arena, ctx, arg_ref, ar, &(inner_arg_b)) ==0)) {
        return 0;
      }
      if ((pipeline_asm_emit_expr_elf_c(arena, elf_ctx, inner_arg_a, ctx, ta) !=0)) {
        return (0 - 1);
      }
      if ((backend_enc_push_rax_arch(elf_ctx, ta) !=0)) {
        return (0 - 1);
      }
      if ((pipeline_asm_emit_expr_elf_c(arena, elf_ctx, inner_arg_b, ctx, ta) !=0)) {
        return (0 - 1);
      }
      if ((backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) !=0)) {
        return (0 - 1);
      }
      if ((backend_enc_pop_rax_arch(elf_ctx, ta) !=0)) {
        return (0 - 1);
      }
      if ((backend_enc_add_rax_rbx_arch(elf_ctx, ta) !=0)) {
        return (0 - 1);
      }
      return 1;
    }
    if ((pipeline_expr_kind_ord_at(arena, arg_ref) !=3)) {
      return 0;
    }
    if ((vlen <=0)) {
      return 0;
    }
    (void)(pipeline_expr_var_name_into(arena, arg_ref, &((vname)[0])));
    if ((slot_off < 0)) {
      return 0;
    }
    if ((glue_enc_local_slot_ptr_or_addr(arena, elf_ctx, arg_ref, slot_off, ta, ctx) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_push_rax_arch(elf_ctx, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_add_imm_to_rax_arch(elf_ctx, off_a, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_load_32_from_rax_arch(elf_ctx, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_pop_rax_arch(elf_ctx, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_add_imm_to_rax_arch(elf_ctx, off_b, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_load_32_from_rax_arch(elf_ctx, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_add_rax_rbx_arch(elf_ctx, ta) !=0)) {
      return (0 - 1);
    }
    return 1;
  }
  return 0;
}
int32_t try_inline_var_field_sum_binop_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t left_ref, int32_t right_ref, uint8_t * ctx, int32_t ta) {
  if ((arena ==0)) {
    return 0;
  }
  if ((elf_ctx ==0)) {
    return 0;
  }
  if ((ctx ==0)) {
    return 0;
  }
  if ((left_ref <=0)) {
    return 0;
  }
  if ((right_ref <=0)) {
    return 0;
  }
  {
    int32_t base_l = pipeline_expr_field_access_base_ref_u8_ptr_i32_reti32(arena, left_ref);
    int32_t base_r = pipeline_expr_field_access_base_ref_u8_ptr_i32_reti32(arena, right_ref);
    uint8_t * pctx = g02f_load_ptr_at(ctx, 1256);
    int32_t off_a = (0 - 1);
    int32_t off_b = (0 - 1);
    int32_t nd = pipeline_dep_ctx_ndep_u8_ptr_reti32(pctx);
    int32_t di = 0;
    int32_t vlen = pipeline_expr_var_name_len(arena, base_l);
    uint8_t vname[64] = {};
    int32_t slot_off = glue_try_inline_local_slot_off(ctx, arena, &((vname)[0]), vlen);
    if ((pipeline_expr_kind_ord_at(arena, left_ref) !=44)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, right_ref) !=44)) {
      return 0;
    }
    if ((base_l <=0)) {
      return 0;
    }
    if ((base_r !=base_l)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, base_l) !=3)) {
      return 0;
    }
    if ((pctx ==0)) {
      (void)((pctx = pipeline_asm_emit_dep_pipe_c_retu8_ptr()));
    }
    if ((pctx ==0)) {
      return 0;
    }
    while ((di < nd)) {
      uint8_t * dm = pipeline_dep_ctx_module_at_u8_ptr_i32_retu8_ptr(pctx, di);
      if ((off_a >=0)) {
        if ((off_b >=0)) {
          break;
        }
      }
      if ((dm !=0)) {
        if ((off_a < 0)) {
          (void)((off_a = pipeline_expr_field_access_layout_offset(arena, dm, left_ref)));
        }
        if ((off_b < 0)) {
          (void)((off_b = pipeline_expr_field_access_layout_offset(arena, dm, right_ref)));
        }
      }
      (void)((di = (di + 1)));
    }
    if ((off_a < 0)) {
      int32_t flen_a = pipeline_expr_field_access_name_len_u8_ptr_i32_reti32(arena, left_ref);
      if ((flen_a > 0)) {
        if ((flen_a <=63)) {
          uint8_t fname_a[64] = {};
          (void)(pipeline_expr_field_access_name_into_u8_ptr_i32_u8_ptr(arena, left_ref, &((fname_a)[0])));
          (void)((off_a = glue_dep_module_field_offset_by_name(pctx, &((fname_a)[0]), flen_a)));
        }
      }
    }
    if ((off_b < 0)) {
      int32_t flen_b = pipeline_expr_field_access_name_len_u8_ptr_i32_reti32(arena, right_ref);
      if ((flen_b > 0)) {
        if ((flen_b <=63)) {
          uint8_t fname_b[64] = {};
          (void)(pipeline_expr_field_access_name_into_u8_ptr_i32_u8_ptr(arena, right_ref, &((fname_b)[0])));
          (void)((off_b = glue_dep_module_field_offset_by_name(pctx, &((fname_b)[0]), flen_b)));
        }
      }
    }
    if ((off_a < 0)) {
      return 0;
    }
    if ((off_b < 0)) {
      return 0;
    }
    if ((vlen <=0)) {
      return 0;
    }
    (void)(pipeline_expr_var_name_into(arena, base_l, &((vname)[0])));
    if ((slot_off < 0)) {
      return 0;
    }
    if ((glue_enc_local_slot_ptr_or_addr(arena, elf_ctx, base_l, slot_off, ta, ctx) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_push_rax_arch(elf_ctx, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_add_imm_to_rax_arch(elf_ctx, off_a, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_load_32_from_rax_arch(elf_ctx, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_pop_rax_arch(elf_ctx, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_add_imm_to_rax_arch(elf_ctx, off_b, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_load_32_from_rax_arch(elf_ctx, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_add_rax_rbx_arch(elf_ctx, ta) !=0)) {
      return (0 - 1);
    }
    return 1;
  }
  return 0;
}
extern int32_t pipeline_expr_struct_lit_field_offset_at(uint8_t * a, uint8_t * m, int32_t er, int32_t fj);
extern int32_t pipeline_expr_struct_lit_field_store_sz(uint8_t * a, uint8_t * m, int32_t er, int32_t fj);
extern int32_t backend_enc_call_stack_cleanup_arch(uint8_t * elf, int32_t nbytes, int32_t ta);
extern void glue_wpo_mono_register_thunk(uint8_t * name, int32_t a0, int32_t a1, int32_t folded);
extern int32_t codegen_wpo_mono_sym_format(uint8_t * name, int32_t nargs, int32_t * args, uint8_t * out, int32_t out_cap);
int32_t try_inline_wpo_const_scalar_binop_call_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  if ((arena ==0)) {
    return 0;
  }
  if ((elf_ctx ==0)) {
    return 0;
  }
  if ((ctx ==0)) {
    return 0;
  }
  if ((expr_ref <=0)) {
    return 0;
  }
  {
    uint8_t * mod_ref = g02f_load_ptr_at(ctx, 16);
    int32_t callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    int32_t clen = pipeline_expr_var_name_len(arena, callee_ref);
    uint8_t cname[64] = {};
    int32_t fi = glue_module_func_index_by_name(mod_ref, &((cname)[0]), clen);
    int32_t binop_ko = 0;
    int32_t arg0 = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
    int32_t arg1 = pipeline_expr_call_arg_ref(arena, expr_ref, 1);
    int32_t av0 = 0;
    int32_t av1 = 0;
    int32_t folded = 0;
    int32_t hi = 0;
    if ((pipeline_expr_kind_ord_at(arena, expr_ref) !=48)) {
      return 0;
    }
    if ((mod_ref ==0)) {
      return 0;
    }
    if ((pipeline_expr_call_num_args_at(arena, expr_ref) !=2)) {
      return 0;
    }
    if ((callee_ref <=0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, callee_ref) !=3)) {
      return 0;
    }
    if ((clen <=0)) {
      return 0;
    }
    if ((clen > 63)) {
      return 0;
    }
    (void)(pipeline_expr_var_name_into(arena, callee_ref, &((cname)[0])));
    if ((fi < 0)) {
      return 0;
    }
    if ((glue_fold_func_returns_param01_scalar_binop(arena, mod_ref, fi, &(binop_ko)) ==0)) {
      return 0;
    }
    if ((arg0 <=0)) {
      return 0;
    }
    if ((arg1 <=0)) {
      return 0;
    }
    if ((glue_try_expr_const_i32(arena, arg0, &(av0)) ==0)) {
      return 0;
    }
    if ((glue_try_expr_const_i32(arena, arg1, &(av1)) ==0)) {
      return 0;
    }
    if ((glue_const_scalar_binop_eval_i32(binop_ko, av0, av1, &(folded)) ==0)) {
      return 0;
    }
    if ((folded < 0)) {
      (void)((hi = (0 - 1)));
    }
    if ((backend_enc_mov_imm64_to_rax_arch(elf_ctx, folded, hi, ta) !=0)) {
      return (0 - 1);
    }
    return 1;
  }
  return 0;
}
int32_t try_inline_wpo_const_vector_lane_of_binop_call_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  if ((arena ==0)) {
    return 0;
  }
  if ((elf_ctx ==0)) {
    return 0;
  }
  if ((ctx ==0)) {
    return 0;
  }
  if ((expr_ref <=0)) {
    return 0;
  }
  {
    uint8_t * mod_ref = g02f_load_ptr_at(ctx, 16);
    int32_t outer_callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    int32_t olen = pipeline_expr_var_name_len(arena, outer_callee_ref);
    uint8_t outer_name[64] = {};
    int32_t outer_fi = glue_module_func_index_by_name(mod_ref, &((outer_name)[0]), olen);
    int32_t lane = 0;
    int32_t inner_call_ref = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
    int32_t inner_callee_ref = pipeline_expr_call_callee_ref_at(arena, inner_call_ref);
    int32_t ilen = pipeline_expr_var_name_len(arena, inner_callee_ref);
    uint8_t inner_name[64] = {};
    int32_t inner_fi = glue_module_func_index_by_name(mod_ref, &((inner_name)[0]), ilen);
    int32_t binop_ko = 0;
    int32_t arg0 = pipeline_expr_call_arg_ref(arena, inner_call_ref, 0);
    int32_t arg1 = pipeline_expr_call_arg_ref(arena, inner_call_ref, 1);
    int32_t av0 = 0;
    int32_t av1 = 0;
    int32_t folded = 0;
    int32_t hi = 0;
    if ((pipeline_expr_kind_ord_at(arena, expr_ref) !=48)) {
      return 0;
    }
    if ((mod_ref ==0)) {
      return 0;
    }
    if ((pipeline_expr_call_num_args_at(arena, expr_ref) !=1)) {
      return 0;
    }
    if ((outer_callee_ref <=0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, outer_callee_ref) !=3)) {
      return 0;
    }
    if ((olen <=0)) {
      return 0;
    }
    if ((olen > 63)) {
      return 0;
    }
    (void)(pipeline_expr_var_name_into(arena, outer_callee_ref, &((outer_name)[0])));
    if ((outer_fi < 0)) {
      return 0;
    }
    if ((glue_fold_func_returns_param0_index_const(arena, mod_ref, outer_fi, &(lane)) ==0)) {
      return 0;
    }
    if ((inner_call_ref <=0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, inner_call_ref) !=48)) {
      return 0;
    }
    if ((pipeline_expr_call_num_args_at(arena, inner_call_ref) !=2)) {
      return 0;
    }
    if ((inner_callee_ref <=0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, inner_callee_ref) !=3)) {
      return 0;
    }
    if ((ilen <=0)) {
      return 0;
    }
    if ((ilen > 63)) {
      return 0;
    }
    (void)(pipeline_expr_var_name_into(arena, inner_callee_ref, &((inner_name)[0])));
    if ((inner_fi < 0)) {
      return 0;
    }
    if ((glue_fold_func_returns_param01_vector_binop(arena, mod_ref, inner_fi, &(binop_ko)) ==0)) {
      return 0;
    }
    if ((arg0 <=0)) {
      return 0;
    }
    if ((arg1 <=0)) {
      return 0;
    }
    if ((glue_try_array_lit_lane_const_i32(arena, arg0, lane, &(av0)) ==0)) {
      return 0;
    }
    if ((glue_try_array_lit_lane_const_i32(arena, arg1, lane, &(av1)) ==0)) {
      return 0;
    }
    if ((glue_const_scalar_binop_eval_i32(binop_ko, av0, av1, &(folded)) ==0)) {
      return 0;
    }
    if ((folded < 0)) {
      (void)((hi = (0 - 1)));
    }
    if ((backend_enc_mov_imm64_to_rax_arch(elf_ctx, folded, hi, ta) !=0)) {
      return (0 - 1);
    }
    return 1;
  }
  return 0;
}
int32_t try_call_wpo_mono_symbol_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  if ((arena ==0)) {
    return 0;
  }
  if ((elf_ctx ==0)) {
    return 0;
  }
  if ((ctx ==0)) {
    return 0;
  }
  if ((expr_ref <=0)) {
    return 0;
  }
  {
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
    /* wave232 G.7: SHUX_WPO_MONO via link_abi_getenv (not raw getenv). */
    if ((link_abi_getenv((const char *)&((kmono)[0])) ==0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, expr_ref) !=48)) {
      return 0;
    }
    uint8_t * mod_ref = g02f_load_ptr_at(ctx, 16);
    if ((mod_ref ==0)) {
      return 0;
    }
    if ((pipeline_expr_call_num_args_at(arena, expr_ref) !=2)) {
      return 0;
    }
    int32_t callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    if ((callee_ref <=0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, callee_ref) !=3)) {
      return 0;
    }
    int32_t clen = pipeline_expr_var_name_len(arena, callee_ref);
    if ((clen <=0)) {
      return 0;
    }
    if ((clen > 63)) {
      return 0;
    }
    uint8_t cname[64] = {};
    (void)(pipeline_expr_var_name_into(arena, callee_ref, &((cname)[0])));
    (void)(((cname)[clen] = 0));
    int32_t fi = glue_module_func_index_by_name(mod_ref, &((cname)[0]), clen);
    if ((fi < 0)) {
      return 0;
    }
    int32_t binop_ko = 0;
    if ((glue_fold_func_returns_param01_scalar_binop(arena, mod_ref, fi, &(binop_ko)) ==0)) {
      return 0;
    }
    int32_t arg0 = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
    int32_t arg1 = pipeline_expr_call_arg_ref(arena, expr_ref, 1);
    if ((arg0 <=0)) {
      return 0;
    }
    if ((arg1 <=0)) {
      return 0;
    }
    int32_t av0 = 0;
    int32_t av1 = 0;
    if ((glue_try_expr_const_i32(arena, arg0, &(av0)) ==0)) {
      return 0;
    }
    if ((glue_try_expr_const_i32(arena, arg1, &(av1)) ==0)) {
      return 0;
    }
    int32_t folded = 0;
    if ((glue_const_scalar_binop_eval_i32(binop_ko, av0, av1, &(folded)) ==0)) {
      return 0;
    }
    (void)(glue_wpo_mono_register_thunk(&((cname)[0]), av0, av1, folded));
    int32_t args[2] = {};
    (void)(((args)[0] = av0));
    (void)(((args)[1] = av1));
    uint8_t sym[128] = {};
    int32_t sym_len = codegen_wpo_mono_sym_format(&((cname)[0]), 2, &((args)[0]), &((sym)[0]), 128);
    if ((sym_len <=0)) {
      return (0 - 1);
    }
    if ((backend_enc_call_arch(elf_ctx, &((sym)[0]), sym_len, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_call_stack_cleanup_arch(elf_ctx, 0, ta) !=0)) {
      return (0 - 1);
    }
    return 1;
  }
  return 0;
}
int32_t try_inline_const_struct_lit_return_call_to_slot_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t call_ref, uint8_t * ctx, int32_t ta, int32_t stack_slot_off) {
  if ((arena ==0)) {
    return 0;
  }
  if ((elf_ctx ==0)) {
    return 0;
  }
  if ((ctx ==0)) {
    return 0;
  }
  if ((call_ref <=0)) {
    return 0;
  }
  {
    uint8_t ca_slot[8] = {};
    uint8_t cm_slot[8] = {};
    int32_t fi = 0;
    uint8_t * callee_arena = g02f_load_ptr_at(&((ca_slot)[0]), 0);
    uint8_t * callee_mod = g02f_load_ptr_at(&((cm_slot)[0]), 0);
    int32_t lit_ref = 0;
    int32_t nf = pipeline_expr_struct_lit_num_fields(callee_arena, lit_ref);
    int32_t fj = 0;
    if ((pipeline_expr_kind_ord_at(arena, call_ref) !=48)) {
      return 0;
    }
    if ((pipeline_expr_call_num_args_at(arena, call_ref) !=0)) {
      return 0;
    }
    if ((glue_call_lookup_callee_mod_fi_arena(arena, call_ref, ctx, &((ca_slot)[0]), &((cm_slot)[0]), &(fi)) ==0)) {
      return 0;
    }
    if ((callee_arena ==0)) {
      return 0;
    }
    if ((callee_mod ==0)) {
      return 0;
    }
    if ((glue_fold_func_returns_const_struct_lit(callee_arena, callee_mod, fi, &(lit_ref)) ==0)) {
      return 0;
    }
    while ((fj < nf)) {
      if ((glue_const_struct_lit_field_can_inline(callee_arena, callee_mod, fi, lit_ref, fj) ==0)) {
        return 0;
      }
      (void)((fj = (fj + 1)));
    }
    if ((backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) !=0)) {
      return (0 - 1);
    }
    (void)((fj = 0));
    while ((fj < nf)) {
      int32_t init_ref = pipeline_expr_struct_lit_init_ref(callee_arena, lit_ref, fj);
      int32_t foff = pipeline_expr_struct_lit_field_offset_at(callee_arena, callee_mod, lit_ref, fj);
      int32_t fsz = pipeline_expr_struct_lit_field_store_sz(callee_arena, callee_mod, lit_ref, fj);
      if ((pipeline_expr_kind_ord_at(callee_arena, init_ref) ==48)) {
        if ((glue_call_is_zero_arg_default_alloc(callee_arena, init_ref) ==0)) {
          return 0;
        }
        if ((glue_emit_default_alloc_to_rbx_offset(elf_ctx, foff, fsz, ta) !=0)) {
          return (0 - 1);
        }
      } else {
        if ((pipeline_asm_emit_expr_elf_c(callee_arena, elf_ctx, init_ref, ctx, ta) !=0)) {
          return (0 - 1);
        }
        if ((backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff, fsz, ta) !=0)) {
          return (0 - 1);
        }
      }
      (void)((fj = (fj + 1)));
    }
    return 1;
  }
  return 0;
}
int32_t try_inline_struct_lit_return_call_to_slot_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t call_ref, uint8_t * ctx, int32_t ta, int32_t stack_slot_off) {
  if ((arena ==0)) {
    return 0;
  }
  if ((elf_ctx ==0)) {
    return 0;
  }
  if ((ctx ==0)) {
    return 0;
  }
  if ((call_ref <=0)) {
    return 0;
  }
  {
    uint8_t ca_slot[8] = {};
    uint8_t cm_slot[8] = {};
    int32_t fi = 0;
    uint8_t * callee_arena = g02f_load_ptr_at(&((ca_slot)[0]), 0);
    uint8_t * callee_mod = g02f_load_ptr_at(&((cm_slot)[0]), 0);
    int32_t lit_ref = 0;
    int32_t nf = pipeline_expr_struct_lit_num_fields(callee_arena, lit_ref);
    int32_t fj = 0;
    if ((pipeline_expr_kind_ord_at(arena, call_ref) !=48)) {
      return 0;
    }
    if ((glue_call_lookup_callee_mod_fi_arena(arena, call_ref, ctx, &((ca_slot)[0]), &((cm_slot)[0]), &(fi)) ==0)) {
      return 0;
    }
    if ((callee_arena ==0)) {
      return 0;
    }
    if ((callee_mod ==0)) {
      return 0;
    }
    if ((glue_fold_func_returns_param_struct_lit(callee_arena, callee_mod, fi, &(lit_ref)) ==0)) {
      return 0;
    }
    if ((nf <=0)) {
      return 0;
    }
    if ((nf > 8)) {
      return 0;
    }
    if ((backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) !=0)) {
      return (0 - 1);
    }
    while ((fj < nf)) {
      int32_t pix = 0;
      if ((glue_struct_lit_field_init_param_index(callee_arena, callee_mod, fi, lit_ref, fj, &(pix)) !=0)) {
        return (0 - 1);
      }
      int32_t arg_ref = pipeline_expr_call_arg_ref(arena, call_ref, pix);
      if ((arg_ref <=0)) {
        return (0 - 1);
      }
      int32_t foff = pipeline_expr_struct_lit_field_offset_at(callee_arena, callee_mod, lit_ref, fj);
      int32_t fsz = pipeline_expr_struct_lit_field_store_sz(callee_arena, callee_mod, lit_ref, fj);
      if ((pipeline_asm_emit_expr_elf_c(arena, elf_ctx, arg_ref, ctx, ta) !=0)) {
        return (0 - 1);
      }
      if ((backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff, fsz, ta) !=0)) {
        return (0 - 1);
      }
      (void)((fj = (fj + 1)));
    }
    return 1;
  }
  return 0;
}
extern void glue_wpo_mono_register_thunk_n(uint8_t * name, int32_t nargs, int32_t * args, int32_t folded);
int32_t try_call_wpo_mono_vector_lane_of_binop_call_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  if ((arena ==0)) {
    return 0;
  }
  if ((elf_ctx ==0)) {
    return 0;
  }
  if ((ctx ==0)) {
    return 0;
  }
  if ((expr_ref <=0)) {
    return 0;
  }
  {
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
    /* wave232 G.7: SHUX_WPO_MONO via link_abi_getenv (not raw getenv). */
    if ((link_abi_getenv((const char *)&((kmono)[0])) ==0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, expr_ref) !=48)) {
      return 0;
    }
    uint8_t * mod_ref = g02f_load_ptr_at(ctx, 16);
    if ((mod_ref ==0)) {
      return 0;
    }
    if ((pipeline_expr_call_num_args_at(arena, expr_ref) !=1)) {
      return 0;
    }
    int32_t outer_callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    if ((outer_callee_ref <=0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, outer_callee_ref) !=3)) {
      return 0;
    }
    int32_t olen = pipeline_expr_var_name_len(arena, outer_callee_ref);
    if ((olen <=0)) {
      return 0;
    }
    if ((olen > 63)) {
      return 0;
    }
    uint8_t outer_name[64] = {};
    (void)(pipeline_expr_var_name_into(arena, outer_callee_ref, &((outer_name)[0])));
    (void)(((outer_name)[olen] = 0));
    int32_t outer_fi = glue_module_func_index_by_name(mod_ref, &((outer_name)[0]), olen);
    if ((outer_fi < 0)) {
      return 0;
    }
    int32_t lane = 0;
    if ((glue_fold_func_returns_param0_index_const(arena, mod_ref, outer_fi, &(lane)) ==0)) {
      return 0;
    }
    int32_t inner_call_ref = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
    if ((inner_call_ref <=0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, inner_call_ref) !=48)) {
      return 0;
    }
    if ((pipeline_expr_call_num_args_at(arena, inner_call_ref) !=2)) {
      return 0;
    }
    int32_t inner_callee_ref = pipeline_expr_call_callee_ref_at(arena, inner_call_ref);
    if ((inner_callee_ref <=0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, inner_callee_ref) !=3)) {
      return 0;
    }
    int32_t ilen = pipeline_expr_var_name_len(arena, inner_callee_ref);
    if ((ilen <=0)) {
      return 0;
    }
    if ((ilen > 63)) {
      return 0;
    }
    uint8_t inner_name[64] = {};
    (void)(pipeline_expr_var_name_into(arena, inner_callee_ref, &((inner_name)[0])));
    int32_t inner_fi = glue_module_func_index_by_name(mod_ref, &((inner_name)[0]), ilen);
    if ((inner_fi < 0)) {
      return 0;
    }
    int32_t binop_ko = 0;
    if ((glue_fold_func_returns_param01_vector_binop(arena, mod_ref, inner_fi, &(binop_ko)) ==0)) {
      return 0;
    }
    int32_t arg0 = pipeline_expr_call_arg_ref(arena, inner_call_ref, 0);
    int32_t arg1 = pipeline_expr_call_arg_ref(arena, inner_call_ref, 1);
    if ((arg0 <=0)) {
      return 0;
    }
    if ((arg1 <=0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, arg0) !=46)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, arg1) !=46)) {
      return 0;
    }
    int32_t nargs = pipeline_expr_array_lit_num_elems_at(arena, arg0);
    if ((nargs <=0)) {
      return 0;
    }
    if ((nargs !=pipeline_expr_array_lit_num_elems_at(arena, arg1))) {
      return 0;
    }
    if ((nargs > 4)) {
      return 0;
    }
    int32_t mono_args[8] = {};
    int32_t li = 0;
    while ((li < nargs)) {
      int32_t e0 = 0;
      int32_t e1 = 0;
      if ((glue_try_array_lit_lane_const_i32(arena, arg0, li, &(e0)) ==0)) {
        return 0;
      }
      if ((glue_try_array_lit_lane_const_i32(arena, arg1, li, &(e1)) ==0)) {
        return 0;
      }
      (void)(((mono_args)[li] = e0));
      (void)(((mono_args)[(nargs + li)] = e1));
      (void)((li = (li + 1)));
    }
    int32_t av0 = 0;
    int32_t av1 = 0;
    if ((glue_try_array_lit_lane_const_i32(arena, arg0, lane, &(av0)) ==0)) {
      return 0;
    }
    if ((glue_try_array_lit_lane_const_i32(arena, arg1, lane, &(av1)) ==0)) {
      return 0;
    }
    int32_t folded = 0;
    if ((glue_const_scalar_binop_eval_i32(binop_ko, av0, av1, &(folded)) ==0)) {
      return 0;
    }
    (void)(glue_wpo_mono_register_thunk_n(&((outer_name)[0]), (nargs * 2), &((mono_args)[0]), folded));
    uint8_t sym[128] = {};
    int32_t sym_len = codegen_wpo_mono_sym_format(&((outer_name)[0]), (nargs * 2), &((mono_args)[0]), &((sym)[0]), 128);
    if ((sym_len <=0)) {
      return (0 - 1);
    }
    if ((backend_enc_call_arch(elf_ctx, &((sym)[0]), sym_len, ta) !=0)) {
      return (0 - 1);
    }
    if ((backend_enc_call_stack_cleanup_arch(elf_ctx, 0, ta) !=0)) {
      return (0 - 1);
    }
    return 1;
  }
  return 0;
}
int32_t asm_array_lit_elem_byte_sz(uint8_t * arena, int32_t array_lit_ref) {
  if ((arena ==0)) {
    return 4;
  }
  if ((array_lit_ref <=0)) {
    return 4;
  }
  int32_t elem_ty = 0;
  {
    (void)((elem_ty = pipeline_asm_array_lit_elem_type_ref(arena, array_lit_ref)));
  }
  if ((elem_ty <=0)) {
    return 4;
  }
  int32_t kind_ord = 0;
  {
    (void)((kind_ord = pipeline_type_kind_ord_at(arena, elem_ty)));
  }
  if ((kind_ord ==2)) {
    return 1;
  }
  if ((kind_ord ==1)) {
    return 1;
  }
  if ((kind_ord ==0)) {
    return 4;
  }
  if ((kind_ord ==3)) {
    return 4;
  }
  if ((kind_ord ==13)) {
    return 4;
  }
  return 8;
}
int32_t pipeline_asm_array_lit_elem_byte_sz_c(uint8_t * arena, int32_t array_lit_ref) {
  return asm_array_lit_elem_byte_sz(arena, array_lit_ref);
}
int32_t asm_array_lit_reserve_stack_bytes(uint8_t * arena, int32_t init_ref) {
  if ((arena ==0)) {
    return 0;
  }
  if ((init_ref <=0)) {
    return 0;
  }
  int32_t ko = 0;
  {
    (void)((ko = pipeline_expr_kind_ord_at(arena, init_ref)));
  }
  if ((ko !=46)) {
    return 0;
  }
  int32_t n = 0;
  {
    (void)((n = pipeline_expr_array_lit_num_elems_at(arena, init_ref)));
  }
  if ((n <=0)) {
    return 0;
  }
  int32_t esz = asm_array_lit_elem_byte_sz(arena, init_ref);
  return glue_align_up8_c((n * esz));
}
int32_t pipeline_asm_array_lit_reserve_stack_bytes_c(uint8_t * arena, int32_t init_ref) {
  return asm_array_lit_reserve_stack_bytes(arena, init_ref);
}
int32_t asm_struct_lit_reserve_stack_bytes(uint8_t * arena, int32_t init_ref) {
  if ((arena ==0)) {
    return 0;
  }
  if ((init_ref <=0)) {
    return 0;
  }
  int32_t ko = 0;
  {
    (void)((ko = pipeline_expr_kind_ord_at(arena, init_ref)));
  }
  if ((ko !=45)) {
    return 0;
  }
  int32_t nf = 0;
  {
    (void)((nf = pipeline_expr_struct_lit_num_fields(arena, init_ref)));
  }
  if ((nf <=0)) {
    return 0;
  }
  return glue_align_up8_c((nf * 8));
}
int32_t pipeline_asm_struct_lit_reserve_stack_bytes_c(uint8_t * arena, int32_t init_ref) {
  return asm_struct_lit_reserve_stack_bytes(arena, init_ref);
}
int32_t asm_index_elem_byte_sz(uint8_t * arena, int32_t index_expr_ref) {
  {
    return pipeline_asm_index_elem_byte_sz(arena, index_expr_ref);
  }
  return 0;
}
int32_t pipeline_asm_enc_local_slot_ptr_or_addr_elf_c(uint8_t * arena, uint8_t * elf, int32_t arg_ref, int32_t slot_off, int32_t ta, uint8_t * asm_ctx) {
  return glue_enc_local_slot_ptr_or_addr(arena, elf, arg_ref, slot_off, ta, asm_ctx);
}
int32_t pipeline_asm_arch_emit_local_slot_ptr_or_addr_text_c(uint8_t * arena, uint8_t * out, int32_t arg_ref, int32_t slot_off, int32_t ta, uint8_t * asm_ctx) {
  return glue_arch_emit_local_slot_ptr_or_addr_text(arena, out, arg_ref, slot_off, ta, asm_ctx);
}
