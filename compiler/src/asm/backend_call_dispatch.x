// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-9：backend_call_dispatch 产品源迁 seeds/backend_call_dispatch.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 锚点；分派实现仍在 seed C。
// 产品：cc seeds/backend_call_dispatch.from_x.c → src/asm/backend_call_dispatch.o

function backend_call_dispatch_x_doc_anchor(): i32 {
  return 0;
}

// G-02f-108：+ string_lit / f32 param / reg_max / import_sym 薄门闩。

extern "C" function glue_asm_string_lit_len_impl(arena: *u8, er: i32): i32;
extern "C" function glue_asm_string_lit_into_impl(arena: *u8, er: i32, out: *u8): void;
extern "C" function glue_codegen_import_path_to_c_prefix_into_impl(path: *u8, buf: *u8, cap: i32): void;
extern "C" function glue_asm_build_import_binding_call_sym_impl(pre: *u8, plen: i32, field: *u8, flen: i32, out: *u8): i32;

/* ---- G-02f-108：backend call dispatch helpers 门闩 ---- */

#[no_mangle]
function glue_asm_string_lit_len(arena: *u8, er: i32): i32 {
  unsafe { return glue_asm_string_lit_len_impl(arena, er); }
  return 0;
}

#[no_mangle]
function glue_asm_string_lit_into(arena: *u8, er: i32, out: *u8): void {
  unsafe { glue_asm_string_lit_into_impl(arena, er, out); }
}





#[no_mangle]
function glue_codegen_import_path_to_c_prefix_into(path: *u8, buf: *u8, cap: i32): void {
  unsafe { glue_codegen_import_path_to_c_prefix_into_impl(path, buf, cap); }
}



#[no_mangle]
function glue_asm_build_import_binding_call_sym(pre: *u8, plen: i32, field: *u8, flen: i32, out: *u8): i32 {
  unsafe { return glue_asm_build_import_binding_call_sym_impl(pre, plen, field, flen, out); }
  return 0;
}



// G-02f-109：+ overload/export_c/import path/heap redirect 薄门闩。

extern "C" function glue_module_func_overload_count_c_impl(m: *u8, name: *u8, nlen: i32): i32;
extern "C" function glue_asm_import_segment_at_impl(mod: *u8, ix: i32, want: i32, ostr: *i32, olen: *i32): i32;
extern "C" function glue_asm_fill_c_prefix_from_module_import_impl(mod: *u8, ix: i32, pre: *u8): i32;
extern "C" function glue_call_param_type_ref_at_impl(arena: *u8, call: i32, pix: i32): i32;
extern "C" function glue_try_std_heap_redirect_sym_local_impl(name: *u8, nlen: i32, out: *u8, cap: i32): i32;
extern "C" function glue_try_std_string_shux_redirect_sym_local_impl(name: *u8, nlen: i32, out: *u8, cap: i32): i32;

/* ---- G-02f-109：call_dispatch more helpers 门闩 ---- */

#[no_mangle]
function glue_module_func_overload_count_c(m: *u8, name: *u8, nlen: i32): i32 { unsafe { return glue_module_func_overload_count_c_impl(m, name, nlen); } return 0; }





#[no_mangle]
function glue_asm_import_segment_at(mod: *u8, ix: i32, want: i32, ostr: *i32, olen: *i32): i32 { unsafe { return glue_asm_import_segment_at_impl(mod, ix, want, ostr, olen); } return 0; }
#[no_mangle]
function glue_asm_fill_c_prefix_from_module_import(mod: *u8, ix: i32, pre: *u8): i32 { unsafe { return glue_asm_fill_c_prefix_from_module_import_impl(mod, ix, pre); } return 0; }
#[no_mangle]
function glue_call_param_type_ref_at(arena: *u8, call: i32, pix: i32): i32 { unsafe { return glue_call_param_type_ref_at_impl(arena, call, pix); } return 0; }
#[no_mangle]
function glue_try_std_heap_redirect_sym_local(name: *u8, nlen: i32, out: *u8, cap: i32): i32 { unsafe { return glue_try_std_heap_redirect_sym_local_impl(name, nlen, out, cap); } return 0; }
#[no_mangle]
function glue_try_std_string_shux_redirect_sym_local(name: *u8, nlen: i32, out: *u8, cap: i32): i32 { unsafe { return glue_try_std_string_shux_redirect_sym_local_impl(name, nlen, out, cap); } return 0; }


// G-02f-110：+ jmp/lea/arg slot/export/call cleanup 薄门闩。

extern "C" function glue_asm_emit_jmp_skip_string_then_lea_impl(ctx: *u8, ta: i32, reg: i32, sbuf: *u8, slen: i32): i32;
extern "C" function glue_sysv_x86_call_arg_slot_c_impl(arena: *u8, call: i32, nargs: i32, aidx: i32, out: *i32): void;
extern "C" function glue_spill_struct16_call_arg_to_lea_elf_c_impl(arena: *u8, elf: *u8, c: *u8): i32;
extern "C" function glue_emit_call_args_elf_sysv_f32_xmm_c_impl(arena: *u8, elf: *u8, er: i32, c: *u8): i32;
extern "C" function glue_emit_one_call_arg_elf_c_impl(arena: *u8, elf: *u8, call: i32, a: i32, b: i32): i32;
extern "C" function glue_asm_build_call_export_sym_c_impl(pre: *u8, name: *u8, out: *u8, cap: i32): i32;
extern "C" function glue_try_std_encoding_redirect_sym_local_impl(name: *u8, nlen: i32, out: *u8, cap: i32): i32;
extern "C" function glue_asm_enc_call_redirected_impl(elf: *u8, name: *u8): i32;
extern "C" function glue_asm_prefix_is_fmt_or_debug_impl(pre: *u8, plen: i32): i32;
extern "C" function glue_asm_try_emit_fmt_string_lit_import_call_elf_c_impl(arena: *u8, elf: *u8, er: i32): i32;
extern "C" function glue_asm_emit_call_with_cleanup_impl(elf: *u8, name: *u8, nbytes: i32): i32;

/* ---- G-02f-110：call_dispatch emit helpers 门闩 ---- */

#[no_mangle]
function glue_asm_emit_jmp_skip_string_then_lea(ctx: *u8, ta: i32, reg: i32, sbuf: *u8, slen: i32): i32 { unsafe { return glue_asm_emit_jmp_skip_string_then_lea_impl(ctx, ta, reg, sbuf, slen); } return 0; }
#[no_mangle]
function glue_sysv_x86_call_arg_slot_c(arena: *u8, call: i32, nargs: i32, aidx: i32, out: *i32): void { unsafe { glue_sysv_x86_call_arg_slot_c_impl(arena, call, nargs, aidx, out); } }
#[no_mangle]
function glue_spill_struct16_call_arg_to_lea_elf_c(arena: *u8, elf: *u8, c: *u8): i32 { unsafe { return glue_spill_struct16_call_arg_to_lea_elf_c_impl(arena, elf, c); } return 0; }
#[no_mangle]
function glue_emit_call_args_elf_sysv_f32_xmm_c(arena: *u8, elf: *u8, er: i32, c: *u8): i32 { unsafe { return glue_emit_call_args_elf_sysv_f32_xmm_c_impl(arena, elf, er, c); } return 0; }
#[no_mangle]
function glue_emit_one_call_arg_elf_c(arena: *u8, elf: *u8, call: i32, a: i32, b: i32): i32 { unsafe { return glue_emit_one_call_arg_elf_c_impl(arena, elf, call, a, b); } return 0; }
#[no_mangle]
function glue_asm_build_call_export_sym_c(pre: *u8, name: *u8, out: *u8, cap: i32): i32 { unsafe { return glue_asm_build_call_export_sym_c_impl(pre, name, out, cap); } return 0; }
#[no_mangle]
function glue_try_std_encoding_redirect_sym_local(name: *u8, nlen: i32, out: *u8, cap: i32): i32 { unsafe { return glue_try_std_encoding_redirect_sym_local_impl(name, nlen, out, cap); } return 0; }
#[no_mangle]
function glue_asm_enc_call_redirected(elf: *u8, name: *u8): i32 { unsafe { return glue_asm_enc_call_redirected_impl(elf, name); } return 0; }

#[no_mangle]
function glue_asm_call_stack_cleanup_bytes(ta: i32, nargs: i32): i32 {
  if (nargs <= 0) {
    return 0;
  }
  let reg_max: i32 = glue_asm_call_reg_max(ta);
  let n_stack: i32 = nargs - reg_max;
  if (n_stack <= 0) {
    return 0;
  }
  if (ta == 0) {
    let bytes: i32 = n_stack * 8;
    if ((n_stack & 1) != 0) {
      bytes = bytes + 8;
    }
    return bytes;
  }
  if (ta == 2) {
    return -1;
  }
  return (n_stack * 8 + 15) & -16;
}

// G-02f-114：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

#[no_mangle]
function glue_asm_prefix_is_fmt_or_debug(pre: *u8, pre_len: i32): i32 {
  if (pre == 0) { return 0; }
  if (pre_len < 8) { return 0; }
  // "std_fmt_"
  if (pre_len >= 8) {
    if (pre[0] == 115 && pre[1] == 116 && pre[2] == 100 && pre[3] == 95
        && pre[4] == 102 && pre[5] == 109 && pre[6] == 116 && pre[7] == 95) {
      return 1;
    }
  }
  // "std_debug_"
  if (pre_len >= 10) {
    if (pre[0] == 115 && pre[1] == 116 && pre[2] == 100 && pre[3] == 95
        && pre[4] == 100 && pre[5] == 101 && pre[6] == 98 && pre[7] == 117
        && pre[8] == 103 && pre[9] == 95) {
      return 1;
    }
  }
  return 0;
}

// G-02f-120：call_dispatch pure helpers 真迁 .x

extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;

#[no_mangle]
function glue_call_param_is_f32_c(arena: *u8, tr: i32): i32 {
  if (arena == 0) { return 0; }
  if (tr <= 0) { return 0; }
  unsafe {
    let k: i32 = pipeline_type_kind_ord_at(arena, tr);
    // GLUE_TYPE_F32_ORD = 14
    if (k == 14) { return 1; }
  }
  return 0;
}

#[no_mangle]
function glue_asm_std_c_wrapper_fname_needs_export_c_suffix(fname: *u8, nlen: i32): i32 {
  if (fname == 0) { return 0; }
  if (nlen <= 0) { return 0; }
  if (nlen >= 2) {
    if (fname[nlen - 2] == 95) { // '_'
      if (fname[nlen - 1] == 99) { // 'c'
        return 0;
      }
    }
  }
  if (nlen >= 4) {
    if (fname[0]==110 && fname[1]==101 && fname[2]==116 && fname[3]==95) { return 1; } // net_
  }
  if (nlen >= 3) {
    if (fname[0]==102 && fname[1]==115 && fname[2]==95) { return 1; } // fs_
  }
  return 0;
}

#[no_mangle]
function glue_asm_append_export_c_suffix(sym: *u8, slen: i32, cap: i32): i32 {
  if (sym == 0) { return slen; }
  if (slen <= 0) { return slen; }
  if (slen + 2 >= cap) { return slen; }
  sym[slen] = 95; // '_'
  sym[slen + 1] = 99; // 'c'
  return slen + 2;
}

#[no_mangle]
function glue_asm_import_path_segment_count(path: *u8, plen: i32): i32 {
  if (path == 0) { return 0; }
  if (plen <= 0) { return 0; }
  let n: i32 = 1;
  let ii: i32 = 0;
  while (ii < plen) {
    if (path[ii] == 46) { n = n + 1; } // '.'
    ii = ii + 1;
  }
  return n;
}

// G-02f-121：call_dispatch pure helpers 真迁 .x

extern "C" function pipeline_module_import_path_byte_at(mod: *u8, ix: i32, off: i32): u8;
extern "C" function pipeline_module_import_binding_name_len(mod: *u8, ix: i32): i32;
extern "C" function pipeline_module_import_binding_name_byte_at(mod: *u8, ix: i32, i: i32): u8;
// glue_call_param_type_ref_at / glue_call_param_is_f32_c already in this TU or linked

#[no_mangle]
function glue_asm_c_prefix_redundant_with_name(pre: *u8, plen: i32, name: *u8, nlen: i32): i32 {
  // prefix must be "build_" (6 chars) and name starts with it
  if (pre == 0) { return 0; }
  if (name == 0) { return 0; }
  if (plen != 6) { return 0; }
  if (nlen < plen) { return 0; }
  // build_
  if (pre[0] != 98) { return 0; }
  if (pre[1] != 117) { return 0; }
  if (pre[2] != 105) { return 0; }
  if (pre[3] != 108) { return 0; }
  if (pre[4] != 100) { return 0; }
  if (pre[5] != 95) { return 0; }
  let i: i32 = 0;
  while (i < plen) {
    if (name[i] != pre[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

#[no_mangle]
function glue_type_kind_to_suffix_c(kind: i32, out: *u8, cap: i32): i32 {
  if (out == 0) { return 0; }
  if (cap <= 0) { return 0; }
  // default i32
  let s0: u8 = 105; let s1: u8 = 51; let s2: u8 = 50; let s3: u8 = 0; let s4: u8 = 0;
  let slen: i32 = 3;
  if (kind == 5) { // i64
    s0 = 105; s1 = 54; s2 = 52; slen = 3;
  } else if (kind == 2) { // u8
    s0 = 117; s1 = 56; slen = 2;
  } else if (kind == 3) { // u32
    s0 = 117; s1 = 51; s2 = 50; slen = 3;
  } else if (kind == 4) { // u64
    s0 = 117; s1 = 54; s2 = 52; slen = 3;
  } else if (kind == 6) { // usize
    s0 = 117; s1 = 115; s2 = 105; s3 = 122; s4 = 101; slen = 5;
  } else if (kind == 7) { // isize
    s0 = 105; s1 = 115; s2 = 105; s3 = 122; s4 = 101; slen = 5;
  } else if (kind == 14) { // f32
    s0 = 102; s1 = 51; s2 = 50; slen = 3;
  } else if (kind == 15) { // f64
    s0 = 102; s1 = 54; s2 = 52; slen = 3;
  } else if (kind == 1) { // bool
    s0 = 98; s1 = 111; s2 = 111; s3 = 108; slen = 4;
  }
  let i: i32 = 0;
  while (i < slen) {
    if (i >= cap - 1) { break; }
    if (i == 0) { out[i] = s0; }
    if (i == 1) { out[i] = s1; }
    if (i == 2) { out[i] = s2; }
    if (i == 3) { out[i] = s3; }
    if (i == 4) { out[i] = s4; }
    i = i + 1;
  }
  return slen;
}

#[no_mangle]
function glue_asm_import_path_slice_equal(mod: *u8, ix: i32, off: i32, slen: i32, nm: *u8, nm_len: i32): i32 {
  if (slen != nm_len) { return 0; }
  if (slen <= 0) { return 0; }
  if (nm == 0) { return 0; }
  let i: i32 = 0;
  while (i < slen) {
    unsafe {
      let b: u8 = pipeline_module_import_path_byte_at(mod, ix, off + i);
      if (b != nm[i]) { return 0; }
    }
    i = i + 1;
  }
  return 1;
}

#[no_mangle]
function glue_asm_import_binding_name_equal(mod: *u8, ix: i32, nm: *u8, nlen: i32): i32 {
  if (nm == 0) { return 0; }
  if (nlen <= 0) { return 0; }
  unsafe {
    let bl: i32 = pipeline_module_import_binding_name_len(mod, ix);
    if (bl != nlen) { return 0; }
    let i: i32 = 0;
    while (i < nlen) {
      let b: u8 = pipeline_module_import_binding_name_byte_at(mod, ix, i);
      if (b != nm[i]) { return 0; }
      i = i + 1;
    }
  }
  return 1;
}

#[no_mangle]
function glue_sysv_x86_call_n_stack_c(arena: *u8, call: i32, nargs: i32): i32 {
  let gp: i32 = 0;
  let xmm: i32 = 0;
  let stk: i32 = 0;
  let j: i32 = 0;
  while (j < nargs) {
    let pty: i32 = glue_call_param_type_ref_at(arena, call, j);
    let is_f: i32 = glue_call_param_is_f32_c(arena, pty);
    if (is_f != 0) {
      if (xmm < 8) { xmm = xmm + 1; }
      else { stk = stk + 1; }
    } else {
      if (gp < 6) { gp = gp + 1; }
      else { stk = stk + 1; }
    }
    j = j + 1;
  }
  return stk;
}
