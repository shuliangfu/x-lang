// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-9：backend_try_inline_dispatch 产品源迁 seeds/backend_try_inline_dispatch.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 锚点；分派实现仍在 seed C。
// 产品：cc seeds/backend_try_inline_dispatch.from_x.c → src/asm/backend_try_inline_dispatch.o

function backend_try_inline_dispatch_x_doc_anchor(): i32 {
  return 0;
}

// G-02f-109：+ align/const fold/module lookup/param 薄门闩。

extern "C" function pipeline_module_num_struct_layouts_at(mod: *u8): i32;
extern "C" function pipeline_module_struct_layout_name_len(mod: *u8, idx: i32): i32;
extern "C" function pipeline_module_struct_layout_name_byte_at(mod: *u8, idx: i32, off: i32): u8;
extern "C" function pipeline_type_kind_ord_at(arena: *u8, tr: i32): i32;
extern "C" function pipeline_type_named_name_into(arena: *u8, tr: i32, out64: *u8): i32;
extern "C" function asm_local_var_slot_holds_indirect_ptr(arena: *u8, er: i32, mod: *u8, asm_ctx: *u8): i32;
extern "C" function pipeline_asm_module_func_param_name_len_at(mod: *u8, fi: i32, pix: i32): i32;
extern "C" function pipeline_asm_module_func_param_name_copy32(mod: *u8, fi: i32, pix: i32, dst: *u8): void;
extern "C" function pipeline_asm_module_func_num_params_at(mod: *u8, fi: i32): i32;
extern "C" function pipeline_module_num_funcs(mod: *u8): i32;
extern "C" function pipeline_asm_module_func_name_len_at(mod: *u8, fi: i32): i32;
extern "C" function pipeline_asm_module_func_name_copy64(mod: *u8, fi: i32, dst: *u8): void;
extern "C" function pipeline_module_func_body_ref_at(mod: *u8, fi: i32): i32;
extern "C" function pipeline_asm_block_final_expr_ref_at(arena: *u8, body: i32): i32;
extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, er: i32): i32;
extern "C" function ast_ast_block_num_expr_stmts(arena: *u8, body: i32): i32;
extern "C" function ast_ast_block_expr_stmt_ref(arena: *u8, body: i32, ei: i32): i32;
extern "C" function pipeline_expr_struct_lit_num_fields(arena: *u8, lit: i32): i32;
extern "C" function pipeline_expr_struct_lit_field_name_len(arena: *u8, lit: i32, j: i32): i32;
extern "C" function pipeline_expr_struct_lit_field_name_into(arena: *u8, lit: i32, j: i32, dst: *u8): void;
extern "C" function pipeline_expr_kind_ord_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_var_name_len(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_var_name_into(arena: *u8, er: i32, out: *u8): void;
extern "C" function backend_fold_func_return_operand_ref(arena: *u8, mod: *u8, fi: i32): i32;

/* ---- G-02f-109 / G-02f-134：try_inline helpers ---- */

// G-02f-134：按名找函数下标
#[no_mangle]
function glue_module_func_index_by_name(mod: *u8, name: *u8, nlen: i32): i32 {
  if (mod == 0) { return 0 - 1; }
  if (name == 0) { return 0 - 1; }
  if (nlen <= 0) { return 0 - 1; }
  if (nlen > 63) { return 0 - 1; }
  unsafe {
    let nfuncs: i32 = pipeline_module_num_funcs(mod);
    let fi: i32 = 0;
    while (fi < nfuncs) {
      let flen: i32 = pipeline_asm_module_func_name_len_at(mod, fi);
      if (flen == nlen) {
        let fb: u8[64] = [];
        pipeline_asm_module_func_name_copy64(mod, fi, &fb[0]);
        let k: i32 = 0;
        let ok: i32 = 1;
        while (k < nlen) {
          if (fb[k] != name[k]) { ok = 0; break; }
          k = k + 1;
        }
        if (ok != 0) { return fi; }
      }
      fi = fi + 1;
    }
  }
  return 0 - 1;
}

// G-02f-129：标量 i32 binop 编译期求值（4=add..8=mod）
#[no_mangle]
function glue_const_scalar_binop_eval_i32(ko: i32, a: i32, b: i32, out: *i32): i32 {
  if (out == 0) { return 0; }
  let wide: i64 = 0;
  if (ko == 4) {
    wide = (a as i64) + (b as i64);
  } else if (ko == 5) {
    wide = (a as i64) - (b as i64);
  } else if (ko == 6) {
    wide = (a as i64) * (b as i64);
  } else if (ko == 7) {
    if (b == 0) { return 0; }
    wide = (a as i64) / (b as i64);
  } else if (ko == 8) {
    if (b == 0) { return 0; }
    wide = (a as i64) % (b as i64);
  } else {
    return 0;
  }
  unsafe { out[0] = wide as i32; }
  return 1;
}

#[no_mangle]
// G-02f-135：模块内是否有命名 struct layout
#[no_mangle]
function glue_module_named_type_has_struct_layout(mod: *u8, name: *u8, nlen: i32): i32 {
  if (mod == 0) { return 0; }
  if (name == 0) { return 0; }
  if (nlen <= 0) { return 0; }
  unsafe {
    let n: i32 = pipeline_module_num_struct_layouts_at(mod);
    let k: i32 = 0;
    while (k < n) {
      let ln: i32 = pipeline_module_struct_layout_name_len(mod, k);
      if (ln == nlen) {
        if (ln > 0) {
          let j: i32 = 0;
          let ok: i32 = 1;
          while (j < nlen) {
            if (pipeline_module_struct_layout_name_byte_at(mod, k, j) != name[j]) {
              ok = 0;
              break;
            }
            j = j + 1;
          }
          if (ok != 0) { return 1; }
        }
      }
      k = k + 1;
    }
  }
  return 0;
}

// G-02f-135：TYPE_NAMED=8 且模块有 layout
#[no_mangle]
function glue_type_ref_is_named_struct_layout(arena: *u8, mod: *u8, ty_ref: i32): i32 {
  if (ty_ref <= 0) { return 0; }
  if (mod == 0) { return 0; }
  unsafe {
    if (pipeline_type_kind_ord_at(arena, ty_ref) != 8) { return 0; }
    let nm: u8[64] = [];
    let nlen: i32 = pipeline_type_named_name_into(arena, ty_ref, &nm[0]);
    if (nlen <= 0) { return 0; }
    return glue_module_named_type_has_struct_layout(mod, &nm[0], nlen);
  }
  return 0;
}
// G-02f-132：从 AsmFuncCtx 偏移 16 读 module_ref（4×i32 后，64 位 LE）
function g02f_load_ptr_at(p: *u8, off: i32): *u8 {
  if (p == 0) { return 0 as *u8; }
  let m: usize = 256;
  let m2: usize = m * m;
  let m4: usize = m2 * m2;
  let a: usize = p[off] as usize;
  a = a + (p[off + 1] as usize) * m;
  a = a + (p[off + 2] as usize) * m2;
  a = a + (p[off + 3] as usize) * (m2 * m);
  a = a + (p[off + 4] as usize) * m4;
  a = a + (p[off + 5] as usize) * (m4 * m);
  a = a + (p[off + 6] as usize) * (m4 * m2);
  a = a + (p[off + 7] as usize) * (m4 * m2 * m);
  return a as *u8;
}

#[no_mangle]
function glue_local_var_slot_holds_indirect_ptr(arena: *u8, er: i32, asm_ctx: *u8): i32 {
  let mod_ref: *u8 = 0 as *u8;
  if (asm_ctx != 0) {
    mod_ref = g02f_load_ptr_at(asm_ctx, 16);
  }
  unsafe {
    return asm_local_var_slot_holds_indirect_ptr(arena, er, mod_ref, asm_ctx);
  }
  return 0;
}

// G-02f-132：VAR 是否为指定形参
#[no_mangle]
function glue_expr_is_func_param_at(arena: *u8, mod: *u8, fi: i32, er: i32, pix: i32): i32 {
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, er) != 3) { return 0; }
    let plen: i32 = pipeline_asm_module_func_param_name_len_at(mod, fi, pix);
    let vlen: i32 = pipeline_expr_var_name_len(arena, er);
    if (plen <= 0) { return 0; }
    if (plen != vlen) { return 0; }
    let pbuf: u8[32] = [];
    let vbuf: u8[64] = [];
    pipeline_asm_module_func_param_name_copy32(mod, fi, pix, &pbuf[0]);
    pipeline_expr_var_name_into(arena, er, &vbuf[0]);
    let k: i32 = 0;
    while (k < plen) {
      if (pbuf[k] != vbuf[k]) { return 0; }
      k = k + 1;
    }
    return 1;
  }
  return 0;
}
#[no_mangle]
// G-02f-134：module body_ref 路径读 return 操作数（41=RETURN）
#[no_mangle]
function glue_fold_func_return_operand_ref_module(arena: *u8, mod: *u8, fi: i32): i32 {
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  if (fi < 0) { return 0; }
  unsafe {
    let body_ref: i32 = pipeline_module_func_body_ref_at(mod, fi);
    if (body_ref <= 0) { return 0; }
    let fin: i32 = pipeline_asm_block_final_expr_ref_at(arena, body_ref);
    if (fin != 0) {
      if (pipeline_expr_kind_ord_at(arena, fin) == 41) {
        let op_e: i32 = pipeline_expr_unary_operand_ref_at(arena, fin);
        if (op_e != 0) { return op_e; }
      }
      return fin;
    }
    let nes: i32 = ast_ast_block_num_expr_stmts(arena, body_ref);
    let found: i32 = 0;
    let op_ref: i32 = 0;
    let ei: i32 = 0;
    while (ei < nes) {
      let er: i32 = ast_ast_block_expr_stmt_ref(arena, body_ref, ei);
      if (er > 0) {
        if (pipeline_expr_kind_ord_at(arena, er) == 41) {
          let op_e: i32 = pipeline_expr_unary_operand_ref_at(arena, er);
          if (op_e != 0) {
            found = found + 1;
            op_ref = op_e;
          }
        }
      }
      ei = ei + 1;
    }
    if (found == 1) { return op_ref; }
  }
  return 0;
}

// G-02f-128：glue_try_fold_func_return_operand_ref 真迁 .x
#[no_mangle]
function glue_try_fold_func_return_operand_ref(arena: *u8, mod: *u8, fi: i32): i32 {
  unsafe {
    let r: i32 = backend_fold_func_return_operand_ref(arena, mod, fi);
    if (r > 0) { return r; }
    return glue_fold_func_return_operand_ref_module(arena, mod, fi);
  }
  return 0;
}


// G-02f-110：+ fold/struct lit/field offset/vector binop 薄门闩。

extern "C" function glue_call_lookup_callee_mod_fi_arena_impl(arena: *u8, call: i32, ctx: *u8, out_mod: *u8): i32;
extern "C" function backend_enc_load_rbp_to_rax_arch(elf: *u8, offset: i32, ta: i32): i32;
extern "C" function backend_enc_lea_rbp_to_rax_arch(elf: *u8, offset: i32, ta: i32): i32;
extern "C" function backend_arch_emit_load_rbp_to_rax(out: *u8, off: i32, ta: i32): i32;
extern "C" function backend_arch_emit_lea_rbp_to_rax(out: *u8, off: i32, ta: i32): i32;

extern "C" function glue_inner_call_arg_for_field_access_impl(arena: *u8, er: i32): i32;
extern "C" function glue_dep_module_field_offset_by_name_impl(mod: *u8, name: *u8, nlen: i32): i32;
extern "C" function glue_inline_var_field_access_offset_impl(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_array_lit_num_elems_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_array_lit_elem_ref(arena: *u8, er: i32, lane: i32): i32;
extern "C" function pipeline_expr_struct_lit_init_ref(arena: *u8, lit: i32, fj: i32): i32;
extern "C" function glue_fold_func_returns_param01_vector_binop_impl(arena: *u8, mod: *u8, fi: i32, out: *i32): i32;
extern "C" function pipeline_module_func_return_type_at(mod: *u8, fi: i32): i32;
extern "C" function asm_type_is_simd_vector_spelling(arena: *u8, tr: i32): i32;
extern "C" function asm_type_is_simd_vector(arena: *u8, tr: i32): i32;
extern "C" function pipeline_expr_binop_left_ref_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_binop_right_ref_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_index_base_ref(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_index_index_ref(arena: *u8, er: i32): i32;

/* ---- G-02f-110 / G-02f-136：try_inline fold/field ---- */

#[no_mangle]
function glue_call_lookup_callee_mod_fi_arena(arena: *u8, call: i32, ctx: *u8, out_mod: *u8): i32 { unsafe { return glue_call_lookup_callee_mod_fi_arena_impl(arena, call, ctx, out_mod); } return 0; }

// G-02f-136：return param0 binop param1（两 i32 形参、非向量返回）；out=ko 4..8
#[no_mangle]
function glue_fold_func_returns_param01_scalar_binop(arena: *u8, mod: *u8, func_idx: i32, out_binop_ko: *i32): i32 {
  if (out_binop_ko == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  if (func_idx < 0) { return 0; }
  unsafe {
    if (pipeline_asm_module_func_num_params_at(mod, func_idx) != 2) { return 0; }
    let ret_ty: i32 = pipeline_module_func_return_type_at(mod, func_idx);
    if (ret_ty > 0) {
      if (asm_type_is_simd_vector_spelling(arena, ret_ty) != 0) { return 0; }
      if (asm_type_is_simd_vector(arena, ret_ty) != 0) { return 0; }
    }
    let ret_ref: i32 = glue_try_fold_func_return_operand_ref(arena, mod, func_idx);
    if (ret_ref <= 0) { return 0; }
    let ko: i32 = pipeline_expr_kind_ord_at(arena, ret_ref);
    if (ko != 4) {
      if (ko != 5) {
        if (ko != 6) {
          if (ko != 7) {
            if (ko != 8) { return 0; }
          }
        }
      }
    }
    let al: i32 = pipeline_expr_binop_left_ref_at(arena, ret_ref);
    let ar: i32 = pipeline_expr_binop_right_ref_at(arena, ret_ref);
    if (glue_expr_is_func_param_at(arena, mod, func_idx, al, 0) == 0) { return 0; }
    if (glue_expr_is_func_param_at(arena, mod, func_idx, ar, 1) == 0) { return 0; }
    out_binop_ko[0] = ko;
    return 1;
  }
  return 0;
}
// G-02f-131：local slot enc/emit 真迁 .x
#[no_mangle]
function glue_enc_local_slot_ptr_or_addr(arena: *u8, elf: *u8, arg_ref: i32, slot_off: i32, ta: i32, asm_ctx: *u8): i32 {
  unsafe {
    if (glue_local_var_slot_holds_indirect_ptr(arena, arg_ref, asm_ctx) != 0) {
      return backend_enc_load_rbp_to_rax_arch(elf, slot_off, ta);
    }
    return backend_enc_lea_rbp_to_rax_arch(elf, slot_off, ta);
  }
  return 0;
}

#[no_mangle]
function glue_arch_emit_local_slot_ptr_or_addr_text(arena: *u8, out: *u8, arg_ref: i32, slot_off: i32, ta: i32, asm_ctx: *u8): i32 {
  unsafe {
    if (glue_local_var_slot_holds_indirect_ptr(arena, arg_ref, asm_ctx) != 0) {
      return backend_arch_emit_load_rbp_to_rax(out, slot_off, ta);
    }
    return backend_arch_emit_lea_rbp_to_rax(out, slot_off, ta);
  }
  return 0;
}
#[no_mangle]
// G-02f-134：struct lit 字段 init 对应形参下标；成功 0，失败 -1
#[no_mangle]
function glue_struct_lit_field_init_param_index(arena: *u8, mod: *u8, fi: i32, lit: i32, fj: i32, out_pix: *i32): i32 {
  if (out_pix == 0) { return 0 - 1; }
  unsafe {
    let init_ref: i32 = pipeline_expr_struct_lit_init_ref(arena, lit, fj);
    if (init_ref <= 0) { return 0 - 1; }
    let np: i32 = pipeline_asm_module_func_num_params_at(mod, fi);
    let pi: i32 = 0;
    while (pi < np) {
      if (glue_expr_is_func_param_at(arena, mod, fi, init_ref, pi) != 0) {
        out_pix[0] = pi;
        return 0;
      }
      pi = pi + 1;
    }
  }
  return 0 - 1;
}

#[no_mangle]
// G-02f-135：return Struct{f:param…}；STRUCT_LIT=45，max fields=8
#[no_mangle]
function glue_fold_func_returns_param_struct_lit(arena: *u8, mod: *u8, func_idx: i32, out_lit_ref: *i32): i32 {
  if (out_lit_ref == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  unsafe {
    let ret_ref: i32 = glue_fold_func_return_operand_ref_module(arena, mod, func_idx);
    if (ret_ref <= 0) {
      ret_ref = backend_fold_func_return_operand_ref(arena, mod, func_idx);
    }
    if (ret_ref <= 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, ret_ref) != 45) { return 0; }
    let nf: i32 = pipeline_expr_struct_lit_num_fields(arena, ret_ref);
    if (nf <= 0) { return 0; }
    if (nf > 8) { return 0; }
    let fj: i32 = 0;
    while (fj < nf) {
      let pix: i32 = 0;
      if (glue_struct_lit_field_init_param_index(arena, mod, func_idx, ret_ref, fj, &pix) != 0) {
        return 0;
      }
      fj = fj + 1;
    }
    out_lit_ref[0] = ret_ref;
    return 1;
  }
  return 0;
}

// G-02f-134：struct lit 按字段名查下标
#[no_mangle]
function glue_struct_lit_field_index_by_name(arena: *u8, lit_ref: i32, fn: *u8, fnlen: i32): i32 {
  if (arena == 0) { return 0 - 1; }
  if (fn == 0) { return 0 - 1; }
  unsafe {
    let nf: i32 = pipeline_expr_struct_lit_num_fields(arena, lit_ref);
    let j: i32 = 0;
    while (j < nf) {
      let slen: i32 = pipeline_expr_struct_lit_field_name_len(arena, lit_ref, j);
      if (slen == fnlen) {
        if (slen > 0) {
          if (slen <= 63) {
            let sb: u8[64] = [];
            pipeline_expr_struct_lit_field_name_into(arena, lit_ref, j, &sb[0]);
            let k: i32 = 0;
            let ok: i32 = 1;
            while (k < slen) {
              if (sb[k] != fn[k]) { ok = 0; break; }
              k = k + 1;
            }
            if (ok != 0) { return j; }
          }
        }
      }
      j = j + 1;
    }
  }
  return 0 - 1;
}
#[no_mangle]
function glue_inner_call_arg_for_field_access(arena: *u8, er: i32): i32 { unsafe { return glue_inner_call_arg_for_field_access_impl(arena, er); } return 0; }
#[no_mangle]
function glue_dep_module_field_offset_by_name(mod: *u8, name: *u8, nlen: i32): i32 { unsafe { return glue_dep_module_field_offset_by_name_impl(mod, name, nlen); } return 0; }
#[no_mangle]
function glue_inline_var_field_access_offset(arena: *u8, er: i32): i32 { unsafe { return glue_inline_var_field_access_offset_impl(arena, er); } return 0; }
#[no_mangle]
// G-02f-133：ARRAY_LIT=46 第 lane 常量
#[no_mangle]
function glue_try_array_lit_lane_const_i32(arena: *u8, arr_ref: i32, lane: i32, out: *i32): i32 {
  if (arena == 0) { return 0; }
  if (arr_ref <= 0) { return 0; }
  if (out == 0) { return 0; }
  if (lane < 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, arr_ref) != 46) { return 0; }
    if (lane >= pipeline_expr_array_lit_num_elems_at(arena, arr_ref)) { return 0; }
    let elem_ref: i32 = pipeline_expr_array_lit_elem_ref(arena, arr_ref, lane);
    return glue_try_expr_const_i32(arena, elem_ref, out);
  }
  return 0;
}
#[no_mangle]
function glue_fold_func_returns_param01_vector_binop(arena: *u8, mod: *u8, fi: i32, out: *i32): i32 { unsafe { return glue_fold_func_returns_param01_vector_binop_impl(arena, mod, fi, out); } return 0; }

// G-02f-136：return param0[index_const]（单形参）；成功写 *out_lane
#[no_mangle]
function glue_fold_func_returns_param0_index_const(arena: *u8, mod: *u8, func_idx: i32, out_lane: *i32): i32 {
  if (out_lane == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  if (func_idx < 0) { return 0; }
  unsafe {
    if (pipeline_asm_module_func_num_params_at(mod, func_idx) != 1) { return 0; }
    let ret_ref: i32 = glue_try_fold_func_return_operand_ref(arena, mod, func_idx);
    if (ret_ref <= 0) { return 0; }
    // GLUE_EXPR_INDEX = 47
    if (pipeline_expr_kind_ord_at(arena, ret_ref) != 47) { return 0; }
    let base_ref: i32 = pipeline_expr_index_base_ref(arena, ret_ref);
    let idx_ref: i32 = pipeline_expr_index_index_ref(arena, ret_ref);
    if (glue_expr_is_func_param_at(arena, mod, func_idx, base_ref, 0) == 0) { return 0; }
    let lane: i32 = 0;
    if (glue_try_expr_const_i32(arena, idx_ref, &lane) == 0) { return 0; }
    out_lane[0] = lane;
    return 1;
  }
  return 0;
}

// G-02f-111：+ default_alloc / const struct lit fold 薄门闩。

extern "C" function glue_emit_default_alloc_to_rbx_offset_impl(elf: *u8, off: i32): i32;
extern "C" function pipeline_expr_call_num_args_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_call_callee_ref_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_field_access_name_len(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_field_access_name_into(arena: *u8, er: i32, out: *u8): void;

/* ---- G-02f-111 / G-02f-131：try_inline alloc/const-lit ---- */

// G-02f-131：零实参 default_alloc CALL 真迁 .x（GLUE_EXPR_CALL=48, VAR=3, FIELD=44）
#[no_mangle]
function glue_call_is_zero_arg_default_alloc(arena: *u8, call_ref: i32): i32 {
  if (arena == 0) { return 0; }
  if (call_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, call_ref) != 48) { return 0; }
    if (pipeline_expr_call_num_args_at(arena, call_ref) != 0) { return 0; }
    let callee_ref: i32 = pipeline_expr_call_callee_ref_at(arena, call_ref);
    if (callee_ref <= 0) { return 0; }
    let ko: i32 = pipeline_expr_kind_ord_at(arena, callee_ref);
    let nm: u8[64] = [];
    if (ko == 3) {
      let nlen: i32 = pipeline_expr_var_name_len(arena, callee_ref);
      if (nlen != 13) { return 0; }
      pipeline_expr_var_name_into(arena, callee_ref, &nm[0]);
      // "default_alloc"
      if (nm[0]==100 && nm[1]==101 && nm[2]==102 && nm[3]==97 && nm[4]==117 && nm[5]==108
          && nm[6]==116 && nm[7]==95 && nm[8]==97 && nm[9]==108 && nm[10]==108 && nm[11]==111
          && nm[12]==99) {
        return 1;
      }
      return 0;
    }
    if (ko == 44) {
      let nlen: i32 = pipeline_expr_field_access_name_len(arena, callee_ref);
      if (nlen != 13) { return 0; }
      pipeline_expr_field_access_name_into(arena, callee_ref, &nm[0]);
      if (nm[0]==100 && nm[1]==101 && nm[2]==102 && nm[3]==97 && nm[4]==117 && nm[5]==108
          && nm[6]==116 && nm[7]==95 && nm[8]==97 && nm[9]==108 && nm[10]==108 && nm[11]==111
          && nm[12]==99) {
        return 1;
      }
      return 0;
    }
  }
  return 0;
}

#[no_mangle]
// G-02f-133：const struct lit 字段可否 inline（CALL=48）
#[no_mangle]
function glue_const_struct_lit_field_can_inline(arena: *u8, mod: *u8, func_idx: i32, lit_ref: i32, fj: i32): i32 {
  if (arena == 0) { return 0; }
  unsafe {
    let init_ref: i32 = pipeline_expr_struct_lit_init_ref(arena, lit_ref, fj);
    if (init_ref <= 0) { return 0; }
    let pix: i32 = 0;
    if (glue_struct_lit_field_init_param_index(arena, mod, func_idx, lit_ref, fj, &pix) == 0) {
      return 0;
    }
    let ko: i32 = pipeline_expr_kind_ord_at(arena, init_ref);
    if (ko == 48) {
      return glue_call_is_zero_arg_default_alloc(arena, init_ref);
    }
    if (ko == 0) { return 1; }
    if (ko == 1) { return 1; }
    if (ko == 2) { return 1; }
  }
  return 0;
}
#[no_mangle]
function glue_emit_default_alloc_to_rbx_offset(elf: *u8, off: i32): i32 { unsafe { return glue_emit_default_alloc_to_rbx_offset_impl(elf, off); } return 0; }

// G-02f-136：return Struct{f: 常量…/default_alloc}；STRUCT_LIT=45，max fields=8
#[no_mangle]
function glue_fold_func_returns_const_struct_lit(arena: *u8, mod: *u8, func_idx: i32, out_lit_ref: *i32): i32 {
  if (out_lit_ref == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  unsafe {
    let ret_ref: i32 = glue_fold_func_return_operand_ref_module(arena, mod, func_idx);
    if (ret_ref <= 0) {
      ret_ref = backend_fold_func_return_operand_ref(arena, mod, func_idx);
    }
    if (ret_ref <= 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, ret_ref) != 45) { return 0; }
    let nf: i32 = pipeline_expr_struct_lit_num_fields(arena, ret_ref);
    if (nf <= 0) { return 0; }
    if (nf > 8) { return 0; }
    let fj: i32 = 0;
    while (fj < nf) {
      let init_ref: i32 = pipeline_expr_struct_lit_init_ref(arena, ret_ref, fj);
      if (init_ref <= 0) { return 0; }
      let pix: i32 = 0;
      // 与 seed 一致：init 不得是形参（param_index 成功则拒）
      if (glue_struct_lit_field_init_param_index(arena, mod, func_idx, ret_ref, fj, &pix) == 0) {
        return 0;
      }
      let ko: i32 = pipeline_expr_kind_ord_at(arena, init_ref);
      // CALL=48 → 仅允许零实参 default_alloc
      if (ko == 48) {
        if (glue_call_is_zero_arg_default_alloc(arena, init_ref) == 0) { return 0; }
      } else {
        if (ko != 0) {
          if (ko != 1) {
            if (ko != 2) { return 0; }
          }
        }
      }
      fj = fj + 1;
    }
    out_lit_ref[0] = ret_ref;
    return 1;
  }
  return 0;
}

// G-02f-113：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

#[no_mangle]
function glue_align_up8_c(n: i32): i32 {
  let m: i32 = n % 8;
  if (m != 0) {
    n = n + (8 - m);
  }
  return n;
}

#[no_mangle]
function glue_is_vector_lane_scalar_binop_ko(ko: i32): i32 {
  if (ko == 51) {
    ko = 4;
  }
  if (ko < 4) {
    return 0;
  }
  if (ko > 13) {
    return 0;
  }
  return 1;
}

// G-02f-126：glue_try_expr_const_i32 真迁 .x

extern "C" function pipeline_expr_int_val_at(arena: *u8, er: i32): i32;

#[no_mangle]
function glue_try_expr_const_i32(arena: *u8, er: i32, out: *i32): i32 {
  if (arena == 0) { return 0; }
  if (er <= 0) { return 0; }
  if (out == 0) { return 0; }
  unsafe {
    let ko: i32 = pipeline_expr_kind_ord_at(arena, er);
    // EXPR_INT / related lit kinds 0 or 2 in pipeline ord
    if (ko == 0) {
      out[0] = pipeline_expr_int_val_at(arena, er);
      return 1;
    }
    if (ko == 2) {
      out[0] = pipeline_expr_int_val_at(arena, er);
      return 1;
    }
  }
  return 0;
}

// G-02f-127：glue_try_inline_local_slot_off 真迁 .x

extern "C" function asm_ctx_local_find_offset_scoped(ctx: *u8, arena: *u8, name: *u8, nlen: i32): i32;
extern "C" function asm_ctx_local_find_offset(ctx: *u8, name: *u8, nlen: i32): i32;

#[no_mangle]
function glue_try_inline_local_slot_off(ctx: *u8, arena: *u8, name: *u8, nlen: i32): i32 {
  unsafe {
    let off: i32 = asm_ctx_local_find_offset_scoped(ctx, arena, name, nlen);
    if (off < 0) {
      off = asm_ctx_local_find_offset(ctx, name, nlen);
    }
    return off;
  }
  return 0 - 1;
}

