// note743y.3 / 10.2: tip peel mega for emit_expr_elf_fast.
// wave152 leftover body lived under !FROM_X in seeds/runtime_pipeline_abi.from_x.c;
// tip prefer FROM_X drops it → hollow W → L2 missing main. Cap tip Darwin keeps
// Cap freeze T renamed to *_mega; Linux gold needs this pure-asm twin.
// fnptr_var_lea_thin exports pipeline_asm_emit_expr_elf_fast and calls mega.
// PLATFORM: SHARED · LINUX tip-cold gold · no host-cc.

export extern "C" function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern "C" function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern "C" function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern "C" function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
export extern "C" function pipeline_arena_expr_ptr(a: *u8, ref: i32): *u8;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_const_folded_valid_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_const_folded_val_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, ty: i32): i32;
export extern "C" function pipeline_type_named_name_into(arena: *u8, ty: i32, out: *u8): i32;
export extern "C" function pipeline_expr_int64_val_at(arena: *u8, expr_ref: i32): i64;
export extern "C" function pipeline_expr_enum_variant_tag_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern "C" function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, ty: i32): i32;
export extern "C" function backend_enc_mov_imm32_to_w0_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern "C" function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern "C" function backend_enc_lea_sym_to_reg_arch(elf_ctx: *u8, reg: i32, name: *u8, name_len: i32, ta: i32): i32;
export extern "C" function glue_i32_to_f32_bits(v: i32): i32;
export extern "C" function glue_i64_to_f32_bits(v: i64): i32;
export extern "C" function glue_i64_to_f64_bits(v: i64, lo: *i32, hi: *i32): void;
export extern "C" function glue_emit_float_lit_to_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ta: i32, a: i32, b: i32): i32;
export extern "C" function pipeline_asm_emit_field_access_elf_fast_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern "C" function pipeline_asm_modlet_load_to_rax_elf_c(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern "C" function glue_call_arg_resolve_var_stack_off_elf_c(arena: *u8, ctx: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_asm_emit_module_ref_c(): *u8;
export extern "C" function asm_module_top_level_const_lit_i32(mod: *u8, arena: *u8, name: *u8, name_len: i32, out: *i32): i32;
export extern "C" function glue_try_emit_match_subject_field_var_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, name: *u8, name_len: i32): i32;
export extern "C" function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern "C" function glue_module_func_index_by_name_c(mod: *u8, name: *u8, name_len: i32): i32;
export extern "C" function pipeline_elf_ctx_macho_leading_underscore(elf_ctx: *u8): i32;
export extern "C" function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, expr_ref: i32): i32;
export extern "C" function glue_load_f32_var_slot_to_rax_elf_c(elf_ctx: *u8, arena: *u8, ctx: *u8, expr_ref: i32, off: i32, ta: i32): i32;
export extern "C" function glue_load_var_as_value_to_rax_rdx_elf_c(elf_ctx: *u8, arena: *u8, ctx: *u8, expr_ref: i32, off: i32, ta: i32): i32;
export extern "C" function pipeline_asm_emit_binop_add_elf_c(arena: *u8, elf_ctx: *u8, left: i32, right: i32, ctx: *u8, ta: i32): i32;
export extern "C" function pipeline_asm_emit_binop_sub_elf_c(arena: *u8, elf_ctx: *u8, left: i32, right: i32, ctx: *u8, ta: i32): i32;
export extern "C" function pipeline_asm_emit_binop_mul_elf_c(arena: *u8, elf_ctx: *u8, left: i32, right: i32, ctx: *u8, ta: i32): i32;
export extern "C" function pipeline_asm_emit_binop_div_elf_c(arena: *u8, elf_ctx: *u8, left: i32, right: i32, ctx: *u8, ta: i32): i32;
export extern "C" function pipeline_asm_emit_binop_mod_elf_c(arena: *u8, elf_ctx: *u8, left: i32, right: i32, ctx: *u8, ta: i32): i32;
export extern "C" function pipeline_asm_emit_binop_and_elf_c(arena: *u8, elf_ctx: *u8, left: i32, right: i32, ctx: *u8, ta: i32): i32;
export extern "C" function pipeline_asm_emit_binop_shift_elf_c(arena: *u8, elf_ctx: *u8, left: i32, right: i32, ctx: *u8, ta: i32, is_shr: i32): i32;
export extern "C" function pipeline_asm_emit_binop_bitwise_elf_c(arena: *u8, elf_ctx: *u8, left: i32, right: i32, ctx: *u8, ta: i32, is_or: i32): i32;
export extern "C" function link_abi_getenv(name: *u8): *u8;

/**
 * wave152 emit_expr_elf_fast body, renamed mega for tip peel + lea thin.
 * @return i32 — 0 ok, -1 hard fail, -99 unhandled
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_asm_emit_expr_elf_fast_mega(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let ko: i32 = 0;
    let nexprs: i32 = 0;
    let unhandled: i32 = 0 - 99;
    let f32_ord: i32 = 14;
    let f64_ord: i32 = 15;
    if (expr_ref == 0) {
      return 0 - 1;
    }
    if (arena == 0 as *u8) {
      return unhandled;
    }
    nexprs = pipe_load_i32_le(arena, 4);
    if (expr_ref <= 0 || expr_ref > nexprs) {
      return unhandled;
    }
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (pipeline_expr_const_folded_valid_at(arena, expr_ref) != 0 && ko != 3) {
      let cfold_imm: i32 = pipeline_expr_const_folded_val_at(arena, expr_ref);
      let cfold_use_imm32: i32 = 1;
      if (ko == 48) {
        let wpo_mono: *u8 = link_abi_getenv("XLANG_WPO_MONO");
        let wpo_nofold: *u8 = link_abi_getenv("XLANG_WPO_NO_FOLD");
        if (wpo_mono != 0 as *u8 && (pipe_load_i32_le(wpo_mono, 0) & 255) != 0) {
          cfold_use_imm32 = 0;
        }
        if (wpo_nofold != 0 as *u8 && (pipe_load_i32_le(wpo_nofold, 0) & 255) != 0) {
          cfold_use_imm32 = 0;
        }
      }
      if (cfold_use_imm32 != 0) {
        let cfold_tr: i32 = pipeline_expr_resolved_type_ref(arena, expr_ref);
        let cfold_k: i32 = 0 - 1;
        if (cfold_tr > 0) {
          cfold_k = pipeline_type_kind_ord_at(arena, cfold_tr);
        }
        if (cfold_k == 2) {
          return backend_enc_mov_imm32_to_w0_arch(elf_ctx, cfold_imm & 255, ta);
        }
        if (cfold_k == 3) {
          return backend_enc_mov_imm32_to_w0_arch(elf_ctx, cfold_imm, ta);
        }
        if (cfold_k == 8) {
          let nm: u8[256] = [];
          let nlen: i32 = pipeline_type_named_name_into(arena, cfold_tr, &nm[0]);
          if (nlen == 3 && nm[0] == 117 && nm[1] == 49 && nm[2] == 54) {
            return backend_enc_mov_imm32_to_w0_arch(elf_ctx, cfold_imm & 65535, ta);
          }
        }
        if (cfold_k == f32_ord) {
          return backend_enc_mov_imm32_to_w0_arch(elf_ctx, glue_i32_to_f32_bits(cfold_imm), ta);
        }
        if (cfold_k == f64_ord) {
          let lo: i32 = 0;
          let hi: i32 = 0;
          glue_i64_to_f64_bits(cfold_imm as i64, &lo, &hi);
          return backend_enc_mov_imm64_to_rax_arch(elf_ctx, lo, hi, ta);
        }
        if (cfold_imm >= 0) {
          return backend_enc_mov_imm32_to_w0_arch(elf_ctx, cfold_imm, ta);
        }
        {
          let v64: i64 = cfold_imm as i64;
          let lo2: i32 = (v64 as i32);
          let hi2: i32 = ((v64 >> 32) as i32);
          return backend_enc_mov_imm64_to_rax_arch(elf_ctx, lo2, hi2, ta);
        }
      }
    }
    if (ko == 0 || ko == 2) {
      /* note743y.6.12 Soft Cap: INT_VAL lo/hi via expr* pipe loads — ban
       * tip int64_val_at U-starve + `as i32` of 0x80000000 → 0. */
      let lo4: i32 = 0;
      let hi4: i32 = 0;
      let ex: *u8 = 0 as *u8;
      let pcell: u8[8] = [];
      let fits: i32 = 0;
      let v64: i64 = 0;
      let vcell: u8[8] = [];
      pipe_store_ptr_slot(&pcell[0], 0, pipeline_arena_expr_ptr(arena, expr_ref));
      ex = pipe_load_ptr_slot(&pcell[0], 0);
      if (ex == 0 as *u8) {
        return 0 - 1;
      }
      lo4 = pipe_load_i32_le(ex, 16);
      hi4 = pipe_load_i32_le(ex, 20);
      if (hi4 == 0 && lo4 >= 0) {
        fits = 1;
      }
      if (hi4 == (0 - 1) && lo4 < 0) {
        fits = 1;
      }
      if (ko == 0) {
        let rty: i32 = pipeline_expr_resolved_type_ref(arena, expr_ref);
        if (rty > 0) {
          let rk: i32 = pipeline_type_kind_ord_at(arena, rty);
          pipe_store_i32_le(&vcell[0], 0, lo4);
          pipe_store_i32_le(&vcell[0], 4, hi4);
          memcpy((&v64 as *u8), &vcell[0], 8 as usize);
          if (rk == f32_ord) {
            return backend_enc_mov_imm32_to_w0_arch(elf_ctx, glue_i64_to_f32_bits(v64), ta);
          }
          if (rk == f64_ord) {
            let lo3: i32 = 0;
            let hi3: i32 = 0;
            glue_i64_to_f64_bits(v64, &lo3, &hi3);
            return backend_enc_mov_imm64_to_rax_arch(elf_ctx, lo3, hi3, ta);
          }
        }
      }
      if (ko == 2 || fits != 0) {
        return backend_enc_mov_imm32_to_w0_arch(elf_ctx, lo4, ta);
      }
      return backend_enc_mov_imm64_to_rax_arch(elf_ctx, lo4, hi4, ta);
    }
    if (ko == 1) {
      return glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, expr_ref, ta, 0, 0);
    }
    if (ko == 50) {
      return backend_enc_mov_imm32_to_w0_arch(elf_ctx, pipeline_expr_enum_variant_tag_at(arena, expr_ref), ta);
    }
    if (ko == 44) {
      return pipeline_asm_emit_field_access_elf_fast_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
    if (ko == 3) {
      let vname: u8[256] = [];
      let vlen: i32 = pipeline_expr_var_name_len(arena, expr_ref);
      let off: i32 = 0;
      if (vlen <= 0) {
        return 0 - 1;
      }
      pipeline_expr_var_name_into(arena, expr_ref, &vname[0]);
      if (pipeline_asm_modlet_load_to_rax_elf_c(elf_ctx, &vname[0], vlen, ta) == 0) {
        return 0;
      }
      off = glue_call_arg_resolve_var_stack_off_elf_c(arena, ctx, expr_ref);
      if (off < 0) {
        let mod_imm: i32 = 0;
        let mod: *u8 = pipeline_asm_emit_module_ref_c();
        if (mod != 0 as *u8 && asm_module_top_level_const_lit_i32(mod, arena, &vname[0], vlen, &mod_imm) != 0) {
          return backend_enc_mov_imm32_to_w0_arch(elf_ctx, mod_imm, ta);
        }
        if (glue_try_emit_match_subject_field_var_elf_c(arena, elf_ctx, ctx, ta, &vname[0], vlen) == 0) {
          return 0;
        }
        {
          let cap_tr: i32 = pipeline_expr_resolved_type_ref(arena, expr_ref);
          let cap_ko: i32 = 0;
          let cap_er: i32 = 0;
          let cap_eko: i32 = 0;
          let cap_ok: i32 = 0;
          if (cap_tr > 0) {
            cap_ko = pipeline_type_kind_ord_at(arena, cap_tr);
            if (cap_ko == 18) {
              cap_ok = 1;
            } else if (cap_ko == 9) {
              cap_er = pipeline_type_elem_ref_at(arena, cap_tr);
              if (cap_er > 0) {
                cap_eko = pipeline_type_kind_ord_at(arena, cap_er);
                if (cap_eko == 2) {
                  cap_ok = 1;
                }
              }
            }
          }
          if (cap_ok != 0 && vlen > 0 && vlen < 128) {
            let fnptr_sym: u8[130] = [];
            let fnptr_sym_len: i32 = 0;
            let fnptr_k: i32 = 0;
            let fnptr_fi: i32 = 0;
            let fnptr_macho: i32 = 0;
            let fnptr_mod: *u8 = glue_emit_module_from_ctx(ctx);
            if (fnptr_mod != 0 as *u8) {
              fnptr_fi = glue_module_func_index_by_name_c(fnptr_mod, &vname[0], vlen);
              if (fnptr_fi >= 0) {
                fnptr_macho = pipeline_elf_ctx_macho_leading_underscore(elf_ctx);
                if (fnptr_macho != 0) {
                  fnptr_sym[0] = 95;
                  fnptr_k = 0;
                  while (fnptr_k < vlen) {
                    fnptr_sym[fnptr_k + 1] = vname[fnptr_k];
                    fnptr_k = fnptr_k + 1;
                  }
                  fnptr_sym_len = vlen + 1;
                } else {
                  fnptr_k = 0;
                  while (fnptr_k < vlen) {
                    fnptr_sym[fnptr_k] = vname[fnptr_k];
                    fnptr_k = fnptr_k + 1;
                  }
                  fnptr_sym_len = vlen;
                }
                return backend_enc_lea_sym_to_reg_arch(elf_ctx, 0, &fnptr_sym[0], fnptr_sym_len, ta);
              }
            }
          }
        }
        return 0 - 1;
      }
      {
        let vtr: i32 = glue_var_decl_type_ref_elf_c(arena, ctx, expr_ref);
        if (vtr > 0 && pipeline_type_kind_ord_at(arena, vtr) == f32_ord) {
          return glue_load_f32_var_slot_to_rax_elf_c(elf_ctx, arena, ctx, expr_ref, off, ta);
        }
      }
      return glue_load_var_as_value_to_rax_rdx_elf_c(elf_ctx, arena, ctx, expr_ref, off, ta);
    }
    if (ko == 41) {
      return unhandled;
    }
    if (ko == 4) {
      return pipeline_asm_emit_binop_add_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref), pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta);
    }
    if (ko == 5) {
      return pipeline_asm_emit_binop_sub_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref), pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta);
    }
    if (ko == 6) {
      return pipeline_asm_emit_binop_mul_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref), pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta);
    }
    if (ko == 7) {
      return pipeline_asm_emit_binop_div_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref), pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta);
    }
    if (ko == 8) {
      return pipeline_asm_emit_binop_mod_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref), pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta);
    }
    if (ko == 11) {
      return pipeline_asm_emit_binop_and_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref), pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta);
    }
    if (ko == 9) {
      return pipeline_asm_emit_binop_shift_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref), pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta, 0);
    }
    if (ko == 10) {
      return pipeline_asm_emit_binop_shift_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref), pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta, 1);
    }
    if (ko == 12) {
      return pipeline_asm_emit_binop_bitwise_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref), pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta, 0);
    }
    if (ko == 13) {
      return pipeline_asm_emit_binop_bitwise_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref), pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta, 1);
    }
    return unhandled;
  }
}
