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
// G-02f-139：string_lit_into / import_path_to_c_prefix 真迁 .x

extern "C" function pipeline_expr_var_name_into(arena: *u8, er: i32, out: *u8): void;

/* ---- G-02f-108 / G-02f-139：backend call dispatch helpers ---- */

// G-02f-139：拷贝 STRING_LIT 内容到 out64（至多 63 字节，先清零）
#[no_mangle]
function glue_asm_string_lit_into(arena: *u8, er: i32, out64: *u8): void {
  if (out64 == 0) { return; }
  let zi: i32 = 0;
  while (zi < 64) {
    out64[zi] = 0;
    zi = zi + 1;
  }
  if (arena == 0) { return; }
  unsafe {
    if (glue_asm_string_lit_len(arena, er) <= 0) { return; }
    pipeline_expr_var_name_into(arena, er, out64);
  }
}

// G-02f-139：import 路径 → C 前缀（'.'→'_'，末尾再补 '_'）
#[no_mangle]
function glue_codegen_import_path_to_c_prefix_into(path: *u8, buf: *u8, buf_cap: i32): void {
  if (buf == 0) { return; }
  if (buf_cap <= 0) { return; }
  let off: i32 = 0;
  let pi: i32 = 0;
  if (path != 0) {
    while (1 == 1) {
      let ch: u8 = path[pi];
      if (ch == 0) { break; }
      if (off + 2 >= buf_cap) { break; }
      // '.'=46 → '_'=95
      if (ch == 46) {
        buf[off] = 95;
      } else {
        buf[off] = ch;
      }
      off = off + 1;
      pi = pi + 1;
    }
  }
  if (off + 1 < buf_cap) {
    buf[off] = 95;
    off = off + 1;
  }
  if (off < buf_cap) {
    buf[off] = 0;
  }
}







// G-02f-109：+ overload/export_c/import path/heap redirect 薄门闩。

extern "C" function parser_get_module_import_path(mod: *u8, ix: i32, path_bytes: *u8): void;
extern "C" function pipeline_module_num_funcs(m: *u8): i32;
extern "C" function pipeline_asm_module_func_is_extern_at(m: *u8, i: i32): i32;
extern "C" function pipeline_module_func_name_equal_at(m: *u8, i: i32, name: *u8, nlen: i32): i32;
extern "C" function parser_get_module_num_imports(mod: *u8): i32;
extern "C" function pipeline_module_import_path_len(mod: *u8, idx: i32): i32;
extern "C" function pipeline_module_import_path_byte_at(mod: *u8, idx: i32, k: i32): u8;

/* ---- G-02f-109 / G-02f-133 / G-02f-134：call_dispatch more helpers ---- */

// G-02f-134：非 extern 同名函数计数
#[no_mangle]
function glue_module_func_overload_count_c(m: *u8, name: *u8, nlen: i32): i32 {
  if (m == 0) { return 0; }
  if (name == 0) { return 0; }
  if (nlen <= 0) { return 0; }
  unsafe {
    let c: i32 = 0;
    let n: i32 = pipeline_module_num_funcs(m);
    let i: i32 = 0;
    while (i < n) {
      if (pipeline_asm_module_func_is_extern_at(m, i) == 0) {
        if (pipeline_module_func_name_equal_at(m, i, name, nlen) != 0) {
          c = c + 1;
        }
      }
      i = i + 1;
    }
    return c;
  }
  return 0;
}

// G-02f-134：import path 第 want_seg 段起止
#[no_mangle]
function glue_asm_import_segment_at(mod: *u8, ix: i32, want_seg: i32, ostr: *i32, olen: *i32): i32 {
  if (mod == 0) { return 0; }
  if (ix < 0) { return 0; }
  if (ostr == 0) { return 0; }
  if (olen == 0) { return 0; }
  unsafe {
    if (ix >= parser_get_module_num_imports(mod)) { return 0; }
    let pl: i32 = pipeline_module_import_path_len(mod, ix);
    if (pl <= 0) { return 0; }
    if (pl > 63) { return 0; }
    let ci: i32 = 0;
    let ss: i32 = 0;
    let k: i32 = 0;
    while (k <= pl) {
      let at_end: i32 = 0;
      if (k == pl) { at_end = 1; }
      let dot: i32 = 0;
      if (at_end == 0) {
        if (k < pl) {
          if (pipeline_module_import_path_byte_at(mod, ix, k) == 46) { dot = 1; }
        }
      }
      if (at_end != 0 || dot != 0) {
        let seg_len_here: i32 = k - ss;
        if (seg_len_here <= 0) { return 0; }
        if (ci == want_seg) {
          ostr[0] = ss;
          olen[0] = seg_len_here;
          return 1;
        }
        if (dot != 0) { ss = k + 1; }
        ci = ci + 1;
      }
      k = k + 1;
    }
  }
  return 0;
}

// G-02f-133：import path → C 前缀
#[no_mangle]
function glue_asm_fill_c_prefix_from_module_import(mod: *u8, ix: i32, pre: *u8): i32 {
  if (mod == 0) { return 0 - 1; }
  if (pre == 0) { return 0 - 1; }
  let path_bytes: u8[64] = [];
  unsafe {
    parser_get_module_import_path(mod, ix, &path_bytes[0]);
    if (path_bytes[0] == 0) { return 0 - 1; }
    glue_codegen_import_path_to_c_prefix_into(&path_bytes[0], pre, 128);
  }
  let pre_len: i32 = 0;
  while (pre_len < 128) {
    if (pre[pre_len] == 0) { break; }
    pre_len = pre_len + 1;
  }
  if (pre_len > 0) { return pre_len; }
  return 0 - 1;
}





// G-02f-110：+ jmp/lea/arg slot/export/call cleanup 薄门闩。

extern "C" function glue_asm_emit_jmp_skip_string_then_lea_impl(ctx: *u8, ta: i32, reg: i32, sbuf: *u8, slen: i32): i32;
extern "C" function glue_spill_struct16_call_arg_to_lea_elf_c_impl(arena: *u8, elf: *u8, c: *u8): i32;
extern "C" function glue_emit_call_args_elf_sysv_f32_xmm_c_impl(arena: *u8, elf: *u8, er: i32, c: *u8): i32;
extern "C" function glue_emit_one_call_arg_elf_c_impl(arena: *u8, elf: *u8, call: i32, a: i32, b: i32): i32;
extern "C" function glue_asm_build_call_export_sym_c_impl(pre: *u8, name: *u8, out: *u8, cap: i32): i32;
extern "C" function glue_asm_try_emit_fmt_string_lit_import_call_elf_c_impl(arena: *u8, elf: *u8, er: i32): i32;
extern "C" function pipeline_asm_redirect_std_c_wrapper_sym(name: *u8, nlen: i32, out: *u8, cap: i32): i32;
extern "C" function backend_enc_call_arch(elf: *u8, name: *u8, nlen: i32, ta: i32): i32;
extern "C" function pipeline_asm_emit_call_args_elf_c(arena: *u8, elf: *u8, er: i32, ctx: *u8, ta: i32, nargs: i32): i32;
extern "C" function backend_enc_call_stack_cleanup_arch(elf: *u8, nbytes: i32, ta: i32): i32;
extern "C" function glue_asm_call_reg_max(ta: i32): i32;

/* ---- G-02f-110 / G-02f-141：call_dispatch emit helpers ---- */

#[no_mangle]
function glue_asm_emit_jmp_skip_string_then_lea(ctx: *u8, ta: i32, reg: i32, sbuf: *u8, slen: i32): i32 { unsafe { return glue_asm_emit_jmp_skip_string_then_lea_impl(ctx, ta, reg, sbuf, slen); } return 0; }

// G-02f-141：SysV x86_64 第 arg_index 实参槽（0=gp 1=xmm 2=stack）
#[no_mangle]
function glue_sysv_x86_call_arg_slot_c(
  arena: *u8, call_expr_ref: i32, nargs: i32, arg_index: i32, out_kind: *i32, out_reg_k: *i32, out_stack_k: *i32
): void {
  if (out_kind == 0) { return; }
  if (out_reg_k == 0) { return; }
  if (out_stack_k == 0) { return; }
  let gp: i32 = 0;
  let xmm: i32 = 0;
  let stk: i32 = 0;
  let j: i32 = 0;
  while (j <= arg_index) {
    if (j >= nargs) { break; }
    let pty: i32 = glue_call_param_type_ref_at(arena, call_expr_ref, j);
    if (j == arg_index) {
      if (glue_call_param_is_f32_c(arena, pty) != 0) {
        if (xmm < 8) {
          out_kind[0] = 1;
          out_reg_k[0] = xmm;
        } else {
          out_kind[0] = 2;
          out_stack_k[0] = stk;
        }
      } else {
        if (gp < 6) {
          out_kind[0] = 0;
          out_reg_k[0] = gp;
        } else {
          out_kind[0] = 2;
          out_stack_k[0] = stk;
        }
      }
      return;
    }
    if (glue_call_param_is_f32_c(arena, pty) != 0) {
      if (xmm < 8) { xmm = xmm + 1; }
      else { stk = stk + 1; }
    } else {
      if (gp < 6) { gp = gp + 1; }
      else { stk = stk + 1; }
    }
    j = j + 1;
  }
  out_kind[0] = 2;
  out_reg_k[0] = 0;
  out_stack_k[0] = 0;
}

#[no_mangle]
function glue_spill_struct16_call_arg_to_lea_elf_c(arena: *u8, elf: *u8, c: *u8): i32 { unsafe { return glue_spill_struct16_call_arg_to_lea_elf_c_impl(arena, elf, c); } return 0; }
#[no_mangle]
function glue_emit_call_args_elf_sysv_f32_xmm_c(arena: *u8, elf: *u8, er: i32, c: *u8): i32 { unsafe { return glue_emit_call_args_elf_sysv_f32_xmm_c_impl(arena, elf, er, c); } return 0; }
#[no_mangle]
function glue_emit_one_call_arg_elf_c(arena: *u8, elf: *u8, call: i32, a: i32, b: i32): i32 { unsafe { return glue_emit_one_call_arg_elf_c_impl(arena, elf, call, a, b); } return 0; }
#[no_mangle]
function glue_asm_build_call_export_sym_c(pre: *u8, name: *u8, out: *u8, cap: i32): i32 { unsafe { return glue_asm_build_call_export_sym_c_impl(pre, name, out, cap); } return 0; }

// G-02f-141：std 重定向表后 enc call
#[no_mangle]
function glue_asm_enc_call_redirected(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  if (name == 0) { return 0 - 1; }
  if (name_len <= 0) { return 0 - 1; }
  unsafe {
    let redir: u8[64] = [];
    let rlen: i32 = glue_try_std_heap_redirect_sym_local(name, name_len, &redir[0], 64);
    if (rlen <= 0) {
      rlen = glue_try_std_string_shux_redirect_sym_local(name, name_len, &redir[0], 64);
    }
    if (rlen <= 0) {
      rlen = glue_try_std_encoding_redirect_sym_local(name, name_len, &redir[0], 64);
    }
    if (rlen <= 0) {
      rlen = pipeline_asm_redirect_std_c_wrapper_sym(name, name_len, &redir[0], 64);
    }
    if (rlen > 0) {
      return backend_enc_call_arch(elf_ctx, &redir[0], rlen, ta);
    }
    return backend_enc_call_arch(elf_ctx, name, name_len, ta);
  }
  return 0 - 1;
}

// G-02f-141：emit args + call + stack cleanup
#[no_mangle]
function glue_asm_emit_call_with_cleanup(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, nargs: i32, cname: *u8, clen: i32
): i32 {
  unsafe {
    if (pipeline_asm_emit_call_args_elf_c(arena, elf_ctx, expr_ref, ctx, ta, nargs) != 0) {
      return 0 - 1;
    }
    if (glue_asm_enc_call_redirected(elf_ctx, cname, clen, ta) != 0) {
      return 0 - 1;
    }
    let cleanup: i32 = glue_asm_call_stack_cleanup_bytes(ta, nargs);
    if (cleanup < 0) { return 0 - 1; }
    return backend_enc_call_stack_cleanup_arch(elf_ctx, cleanup, ta);
  }
  return 0 - 1;
}

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

// G-02f-122：call_dispatch pure helpers 真迁 .x

extern "C" function pipeline_expr_kind_ord_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_var_name_len_for_string_lit_c(arena: *u8, er: i32): i32;
extern "C" function pipeline_asm_call_param_type_ref_at_c(arena: *u8, call: i32, pix: i32): i32;

#[no_mangle]
function glue_asm_string_lit_len(arena: *u8, er: i32): i32 {
  if (arena == 0) { return 0; }
  if (er <= 0) { return 0; }
  unsafe {
    let k: i32 = pipeline_expr_kind_ord_at(arena, er);
    // GLUE_EXPR_STRING_LIT_ORD = 59
    if (k != 59) { return 0; }
    return pipeline_expr_var_name_len_for_string_lit_c(arena, er);
  }
  return 0;
}

#[no_mangle]
function glue_asm_build_import_binding_call_sym(pre: *u8, plen: i32, field: *u8, flen: i32, out: *u8): i32 {
  if (out == 0) { return 0 - 1; }
  let pos: i32 = 0;
  let skip_pre: i32 = 0;
  if (plen > 0) {
    if (glue_asm_c_prefix_redundant_with_name(pre, plen, field, flen) != 0) {
      skip_pre = 1;
    }
  }
  if (skip_pre == 0) {
    if (plen > 0) {
      let pi: i32 = 0;
      while (pi < plen) {
        if (pos >= 63) { break; }
        out[pos] = pre[pi];
        pos = pos + 1;
        pi = pi + 1;
      }
    }
  }
  let pi2: i32 = 0;
  while (pi2 < flen) {
    if (pos >= 63) { break; }
    out[pos] = field[pi2];
    pos = pos + 1;
    pi2 = pi2 + 1;
  }
  if (pos > 0) { return pos; }
  return 0 - 1;
}

#[no_mangle]
function glue_call_param_type_ref_at(arena: *u8, call: i32, pix: i32): i32 {
  unsafe {
    return pipeline_asm_call_param_type_ref_at_c(arena, call, pix);
  }
  return 0;
}

// G-02f-123：std redirect pure helpers 真迁 .x

#[no_mangle]
function glue_try_std_string_shux_redirect_sym_local(name: *u8, nlen: i32, out: *u8, cap: i32): i32 {
  if (name == 0) { return 0; }
  if (nlen <= 11) { return 0; }
  if (out == 0) { return 0; }
  if (cap <= 0) { return 0; }
  // "std_string_"
  if (name[0]!=115||name[1]!=116||name[2]!=100||name[3]!=95||name[4]!=115||name[5]!=116
      ||name[6]!=114||name[7]!=105||name[8]!=110||name[9]!=103||name[10]!=95) {
    return 0;
  }
  let suffix_len: i32 = nlen - 11;
  if (suffix_len < 12) { return 0; }
  // "shux_string_"
  if (name[11]!=115||name[12]!=104||name[13]!=117||name[14]!=120||name[15]!=95
      ||name[16]!=115||name[17]!=116||name[18]!=114||name[19]!=105||name[20]!=110
      ||name[21]!=103||name[22]!=95) {
    return 0;
  }
  if (suffix_len + 1 > cap) { return 0; }
  let i: i32 = 0;
  while (i < suffix_len) {
    out[i] = name[11 + i];
    i = i + 1;
  }
  return suffix_len;
}

#[no_mangle]
function glue_try_std_encoding_redirect_sym_local(name: *u8, nlen: i32, out: *u8, cap: i32): i32 {
  if (name == 0) { return 0; }
  if (out == 0) { return 0; }
  if (cap <= 0) { return 0; }
  let prefix_len: i32 = 13; // "std_encoding_"
  if (nlen <= prefix_len) { return 0; }
  // std_encoding_
  if (name[0]!=115||name[1]!=116||name[2]!=100||name[3]!=95||name[4]!=101||name[5]!=110
      ||name[6]!=99||name[7]!=111||name[8]!=100||name[9]!=105||name[10]!=110||name[11]!=103
      ||name[12]!=95) {
    return 0;
  }
  let suffix_len: i32 = nlen - prefix_len;
  if (suffix_len <= 0) { return 0; }
  let out_len: i32 = 9 + suffix_len + 2; // encoding_ + suffix + _c
  if (out_len >= cap) { return 0; }
  // encoding_
  out[0]=101; out[1]=110; out[2]=99; out[3]=111; out[4]=100; out[5]=105; out[6]=110; out[7]=103; out[8]=95;
  let i: i32 = 0;
  while (i < suffix_len) {
    out[9 + i] = name[prefix_len + i];
    i = i + 1;
  }
  out[9 + suffix_len] = 95;
  out[9 + suffix_len + 1] = 99;
  return out_len;
}

// G-02f-125：glue_try_std_heap_redirect_sym_local 真迁 .x

#[no_mangle]
function glue_try_std_heap_redirect_sym_local(name: *u8, nlen: i32, out: *u8, cap: i32): i32 {
  if (name == 0) { return 0; }
  if (nlen <= 0) { return 0; }
  if (out == 0) { return 0; }
  if (cap <= 0) { return 0; }
  if (nlen == 5) {
    if (name[0]==97 && name[1]==108 && name[2]==108 && name[3]==111 && name[4]==99) {
      if (12 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 97;
      out[6] = 108;
      out[7] = 108;
      out[8] = 111;
      out[9] = 99;
      out[10] = 95;
      out[11] = 99;
      return 12;
    }
  }
  if (nlen == 7) {
    if (name[0]==114 && name[1]==101 && name[2]==97 && name[3]==108 && name[4]==108 && name[5]==111 && name[6]==99) {
      if (14 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 114;
      out[6] = 101;
      out[7] = 97;
      out[8] = 108;
      out[9] = 108;
      out[10] = 111;
      out[11] = 99;
      out[12] = 95;
      out[13] = 99;
      return 14;
    }
  }
  if (nlen == 4) {
    if (name[0]==102 && name[1]==114 && name[2]==101 && name[3]==101) {
      if (11 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 102;
      out[6] = 114;
      out[7] = 101;
      out[8] = 101;
      out[9] = 95;
      out[10] = 99;
      return 11;
    }
  }
  if (nlen == 9) {
    if (name[0]==97 && name[1]==108 && name[2]==108 && name[3]==111 && name[4]==99 && name[5]==95 && name[6]==105 && name[7]==51 && name[8]==50) {
      if (16 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 97;
      out[6] = 108;
      out[7] = 108;
      out[8] = 111;
      out[9] = 99;
      out[10] = 95;
      out[11] = 105;
      out[12] = 51;
      out[13] = 50;
      out[14] = 95;
      out[15] = 99;
      return 16;
    }
  }
  if (nlen == 21) {
    if (name[0]==97 && name[1]==108 && name[2]==108 && name[3]==111 && name[4]==99 && name[5]==95 && name[6]==105 && name[7]==51 && name[8]==50 && name[9]==95 && name[10]==114 && name[11]==101 && name[12]==116 && name[13]==95 && name[14]==105 && name[15]==51 && name[16]==50 && name[17]==95 && name[18]==112 && name[19]==116 && name[20]==114) {
      if (16 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 97;
      out[6] = 108;
      out[7] = 108;
      out[8] = 111;
      out[9] = 99;
      out[10] = 95;
      out[11] = 105;
      out[12] = 51;
      out[13] = 50;
      out[14] = 95;
      out[15] = 99;
      return 16;
    }
  }
  if (nlen == 20) {
    if (name[0]==97 && name[1]==108 && name[2]==108 && name[3]==111 && name[4]==99 && name[5]==95 && name[6]==105 && name[7]==51 && name[8]==50 && name[9]==95 && name[10]==114 && name[11]==101 && name[12]==116 && name[13]==95 && name[14]==117 && name[15]==56 && name[16]==95 && name[17]==112 && name[18]==116 && name[19]==114) {
      if (15 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 97;
      out[6] = 108;
      out[7] = 108;
      out[8] = 111;
      out[9] = 99;
      out[10] = 95;
      out[11] = 117;
      out[12] = 56;
      out[13] = 95;
      out[14] = 99;
      return 15;
    }
  }
  if (nlen == 21) {
    if (name[0]==97 && name[1]==108 && name[2]==108 && name[3]==111 && name[4]==99 && name[5]==95 && name[6]==105 && name[7]==51 && name[8]==50 && name[9]==95 && name[10]==114 && name[11]==101 && name[12]==116 && name[13]==95 && name[14]==117 && name[15]==54 && name[16]==52 && name[17]==95 && name[18]==112 && name[19]==116 && name[20]==114) {
      if (16 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 97;
      out[6] = 108;
      out[7] = 108;
      out[8] = 111;
      out[9] = 99;
      out[10] = 95;
      out[11] = 117;
      out[12] = 54;
      out[13] = 52;
      out[14] = 95;
      out[15] = 99;
      return 16;
    }
  }
  if (nlen == 21) {
    if (name[0]==97 && name[1]==108 && name[2]==108 && name[3]==111 && name[4]==99 && name[5]==95 && name[6]==105 && name[7]==51 && name[8]==50 && name[9]==95 && name[10]==114 && name[11]==101 && name[12]==116 && name[13]==95 && name[14]==102 && name[15]==54 && name[16]==52 && name[17]==95 && name[18]==112 && name[19]==116 && name[20]==114) {
      if (16 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 97;
      out[6] = 108;
      out[7] = 108;
      out[8] = 111;
      out[9] = 99;
      out[10] = 95;
      out[11] = 102;
      out[12] = 54;
      out[13] = 52;
      out[14] = 95;
      out[15] = 99;
      return 16;
    }
  }
  if (nlen == 21) {
    if (name[0]==97 && name[1]==108 && name[2]==108 && name[3]==111 && name[4]==99 && name[5]==95 && name[6]==105 && name[7]==51 && name[8]==50 && name[9]==95 && name[10]==114 && name[11]==101 && name[12]==116 && name[13]==95 && name[14]==102 && name[15]==51 && name[16]==50 && name[17]==95 && name[18]==112 && name[19]==116 && name[20]==114) {
      if (16 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 97;
      out[6] = 108;
      out[7] = 108;
      out[8] = 111;
      out[9] = 99;
      out[10] = 95;
      out[11] = 102;
      out[12] = 51;
      out[13] = 50;
      out[14] = 95;
      out[15] = 99;
      return 16;
    }
  }
  if (nlen == 11) {
    if (name[0]==114 && name[1]==101 && name[2]==97 && name[3]==108 && name[4]==108 && name[5]==111 && name[6]==99 && name[7]==95 && name[8]==105 && name[9]==51 && name[10]==50) {
      if (18 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 114;
      out[6] = 101;
      out[7] = 97;
      out[8] = 108;
      out[9] = 108;
      out[10] = 111;
      out[11] = 99;
      out[12] = 95;
      out[13] = 105;
      out[14] = 51;
      out[15] = 50;
      out[16] = 95;
      out[17] = 99;
      return 18;
    }
  }
  if (nlen == 23) {
    if (name[0]==114 && name[1]==101 && name[2]==97 && name[3]==108 && name[4]==108 && name[5]==111 && name[6]==99 && name[7]==95 && name[8]==105 && name[9]==51 && name[10]==50 && name[11]==95 && name[12]==114 && name[13]==101 && name[14]==116 && name[15]==95 && name[16]==105 && name[17]==51 && name[18]==50 && name[19]==95 && name[20]==112 && name[21]==116 && name[22]==114) {
      if (18 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 114;
      out[6] = 101;
      out[7] = 97;
      out[8] = 108;
      out[9] = 108;
      out[10] = 111;
      out[11] = 99;
      out[12] = 95;
      out[13] = 105;
      out[14] = 51;
      out[15] = 50;
      out[16] = 95;
      out[17] = 99;
      return 18;
    }
  }
  if (nlen == 23) {
    if (name[0]==114 && name[1]==101 && name[2]==97 && name[3]==108 && name[4]==108 && name[5]==111 && name[6]==99 && name[7]==95 && name[8]==117 && name[9]==54 && name[10]==52 && name[11]==95 && name[12]==114 && name[13]==101 && name[14]==116 && name[15]==95 && name[16]==117 && name[17]==54 && name[18]==52 && name[19]==95 && name[20]==112 && name[21]==116 && name[22]==114) {
      if (18 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 114;
      out[6] = 101;
      out[7] = 97;
      out[8] = 108;
      out[9] = 108;
      out[10] = 111;
      out[11] = 99;
      out[12] = 95;
      out[13] = 117;
      out[14] = 54;
      out[15] = 52;
      out[16] = 95;
      out[17] = 99;
      return 18;
    }
  }
  if (nlen == 23) {
    if (name[0]==114 && name[1]==101 && name[2]==97 && name[3]==108 && name[4]==108 && name[5]==111 && name[6]==99 && name[7]==95 && name[8]==102 && name[9]==54 && name[10]==52 && name[11]==95 && name[12]==114 && name[13]==101 && name[14]==116 && name[15]==95 && name[16]==102 && name[17]==54 && name[18]==52 && name[19]==95 && name[20]==112 && name[21]==116 && name[22]==114) {
      if (18 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 114;
      out[6] = 101;
      out[7] = 97;
      out[8] = 108;
      out[9] = 108;
      out[10] = 111;
      out[11] = 99;
      out[12] = 95;
      out[13] = 102;
      out[14] = 54;
      out[15] = 52;
      out[16] = 95;
      out[17] = 99;
      return 18;
    }
  }
  if (nlen == 23) {
    if (name[0]==114 && name[1]==101 && name[2]==97 && name[3]==108 && name[4]==108 && name[5]==111 && name[6]==99 && name[7]==95 && name[8]==102 && name[9]==51 && name[10]==50 && name[11]==95 && name[12]==114 && name[13]==101 && name[14]==116 && name[15]==95 && name[16]==102 && name[17]==51 && name[18]==50 && name[19]==95 && name[20]==112 && name[21]==116 && name[22]==114) {
      if (18 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 114;
      out[6] = 101;
      out[7] = 97;
      out[8] = 108;
      out[9] = 108;
      out[10] = 111;
      out[11] = 99;
      out[12] = 95;
      out[13] = 102;
      out[14] = 51;
      out[15] = 50;
      out[16] = 95;
      out[17] = 99;
      return 18;
    }
  }
  if (nlen == 21) {
    if (name[0]==114 && name[1]==101 && name[2]==97 && name[3]==108 && name[4]==108 && name[5]==111 && name[6]==99 && name[7]==95 && name[8]==117 && name[9]==56 && name[10]==95 && name[11]==114 && name[12]==101 && name[13]==116 && name[14]==95 && name[15]==117 && name[16]==56 && name[17]==95 && name[18]==112 && name[19]==116 && name[20]==114) {
      if (17 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 114;
      out[6] = 101;
      out[7] = 97;
      out[8] = 108;
      out[9] = 108;
      out[10] = 111;
      out[11] = 99;
      out[12] = 95;
      out[13] = 117;
      out[14] = 56;
      out[15] = 95;
      out[16] = 99;
      return 17;
    }
  }
  if (nlen == 8) {
    if (name[0]==102 && name[1]==114 && name[2]==101 && name[3]==101 && name[4]==95 && name[5]==105 && name[6]==51 && name[7]==50) {
      if (15 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 102;
      out[6] = 114;
      out[7] = 101;
      out[8] = 101;
      out[9] = 95;
      out[10] = 105;
      out[11] = 51;
      out[12] = 50;
      out[13] = 95;
      out[14] = 99;
      return 15;
    }
  }
  if (nlen == 12) {
    if (name[0]==102 && name[1]==114 && name[2]==101 && name[3]==101 && name[4]==95 && name[5]==105 && name[6]==51 && name[7]==50 && name[8]==95 && name[9]==112 && name[10]==116 && name[11]==114) {
      if (15 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 102;
      out[6] = 114;
      out[7] = 101;
      out[8] = 101;
      out[9] = 95;
      out[10] = 105;
      out[11] = 51;
      out[12] = 50;
      out[13] = 95;
      out[14] = 99;
      return 15;
    }
  }
  if (nlen == 12) {
    if (name[0]==102 && name[1]==114 && name[2]==101 && name[3]==101 && name[4]==95 && name[5]==117 && name[6]==54 && name[7]==52 && name[8]==95 && name[9]==112 && name[10]==116 && name[11]==114) {
      if (15 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 102;
      out[6] = 114;
      out[7] = 101;
      out[8] = 101;
      out[9] = 95;
      out[10] = 117;
      out[11] = 54;
      out[12] = 52;
      out[13] = 95;
      out[14] = 99;
      return 15;
    }
  }
  if (nlen == 12) {
    if (name[0]==102 && name[1]==114 && name[2]==101 && name[3]==101 && name[4]==95 && name[5]==102 && name[6]==54 && name[7]==52 && name[8]==95 && name[9]==112 && name[10]==116 && name[11]==114) {
      if (15 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 102;
      out[6] = 114;
      out[7] = 101;
      out[8] = 101;
      out[9] = 95;
      out[10] = 102;
      out[11] = 54;
      out[12] = 52;
      out[13] = 95;
      out[14] = 99;
      return 15;
    }
  }
  if (nlen == 12) {
    if (name[0]==102 && name[1]==114 && name[2]==101 && name[3]==101 && name[4]==95 && name[5]==102 && name[6]==51 && name[7]==50 && name[8]==95 && name[9]==112 && name[10]==116 && name[11]==114) {
      if (15 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 102;
      out[6] = 114;
      out[7] = 101;
      out[8] = 101;
      out[9] = 95;
      out[10] = 102;
      out[11] = 51;
      out[12] = 50;
      out[13] = 95;
      out[14] = 99;
      return 15;
    }
  }
  if (nlen == 8) {
    if (name[0]==97 && name[1]==108 && name[2]==108 && name[3]==111 && name[4]==99 && name[5]==95 && name[6]==117 && name[7]==56) {
      if (15 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 97;
      out[6] = 108;
      out[7] = 108;
      out[8] = 111;
      out[9] = 99;
      out[10] = 95;
      out[11] = 117;
      out[12] = 56;
      out[13] = 95;
      out[14] = 99;
      return 15;
    }
  }
  if (nlen == 10) {
    if (name[0]==114 && name[1]==101 && name[2]==97 && name[3]==108 && name[4]==108 && name[5]==111 && name[6]==99 && name[7]==95 && name[8]==117 && name[9]==56) {
      if (17 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 114;
      out[6] = 101;
      out[7] = 97;
      out[8] = 108;
      out[9] = 108;
      out[10] = 111;
      out[11] = 99;
      out[12] = 95;
      out[13] = 117;
      out[14] = 56;
      out[15] = 95;
      out[16] = 99;
      return 17;
    }
  }
  if (nlen == 7) {
    if (name[0]==102 && name[1]==114 && name[2]==101 && name[3]==101 && name[4]==95 && name[5]==117 && name[6]==56) {
      if (14 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 102;
      out[6] = 114;
      out[7] = 101;
      out[8] = 101;
      out[9] = 95;
      out[10] = 117;
      out[11] = 56;
      out[12] = 95;
      out[13] = 99;
      return 14;
    }
  }
  if (nlen == 9) {
    if (name[0]==97 && name[1]==108 && name[2]==108 && name[3]==111 && name[4]==99 && name[5]==95 && name[6]==102 && name[7]==51 && name[8]==50) {
      if (16 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 97;
      out[6] = 108;
      out[7] = 108;
      out[8] = 111;
      out[9] = 99;
      out[10] = 95;
      out[11] = 102;
      out[12] = 51;
      out[13] = 50;
      out[14] = 95;
      out[15] = 99;
      return 16;
    }
  }
  if (nlen == 11) {
    if (name[0]==114 && name[1]==101 && name[2]==97 && name[3]==108 && name[4]==108 && name[5]==111 && name[6]==99 && name[7]==95 && name[8]==102 && name[9]==51 && name[10]==50) {
      if (18 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 114;
      out[6] = 101;
      out[7] = 97;
      out[8] = 108;
      out[9] = 108;
      out[10] = 111;
      out[11] = 99;
      out[12] = 95;
      out[13] = 102;
      out[14] = 51;
      out[15] = 50;
      out[16] = 95;
      out[17] = 99;
      return 18;
    }
  }
  if (nlen == 8) {
    if (name[0]==102 && name[1]==114 && name[2]==101 && name[3]==101 && name[4]==95 && name[5]==102 && name[6]==51 && name[7]==50) {
      if (15 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 102;
      out[6] = 114;
      out[7] = 101;
      out[8] = 101;
      out[9] = 95;
      out[10] = 102;
      out[11] = 51;
      out[12] = 50;
      out[13] = 95;
      out[14] = 99;
      return 15;
    }
  }
  if (nlen == 11) {
    if (name[0]==99 && name[1]==111 && name[2]==112 && name[3]==121 && name[4]==95 && name[5]==105 && name[6]==51 && name[7]==50 && name[8]==95 && name[9]==97 && name[10]==116) {
      if (18 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 99;
      out[6] = 111;
      out[7] = 112;
      out[8] = 121;
      out[9] = 95;
      out[10] = 105;
      out[11] = 51;
      out[12] = 50;
      out[13] = 95;
      out[14] = 97;
      out[15] = 116;
      out[16] = 95;
      out[17] = 99;
      return 18;
    }
  }
  if (nlen == 10) {
    if (name[0]==99 && name[1]==111 && name[2]==112 && name[3]==121 && name[4]==95 && name[5]==117 && name[6]==56 && name[7]==95 && name[8]==97 && name[9]==116) {
      if (17 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 99;
      out[6] = 111;
      out[7] = 112;
      out[8] = 121;
      out[9] = 95;
      out[10] = 117;
      out[11] = 56;
      out[12] = 95;
      out[13] = 97;
      out[14] = 116;
      out[15] = 95;
      out[16] = 99;
      return 17;
    }
  }
  if (nlen == 11) {
    if (name[0]==99 && name[1]==111 && name[2]==112 && name[3]==121 && name[4]==95 && name[5]==102 && name[6]==51 && name[7]==50 && name[8]==95 && name[9]==97 && name[10]==116) {
      if (18 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 99;
      out[6] = 111;
      out[7] = 112;
      out[8] = 121;
      out[9] = 95;
      out[10] = 102;
      out[11] = 51;
      out[12] = 50;
      out[13] = 95;
      out[14] = 97;
      out[15] = 116;
      out[16] = 95;
      out[17] = 99;
      return 18;
    }
  }
  if (nlen == 11) {
    if (name[0]==99 && name[1]==111 && name[2]==112 && name[3]==121 && name[4]==95 && name[5]==117 && name[6]==54 && name[7]==52 && name[8]==95 && name[9]==97 && name[10]==116) {
      if (18 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 99;
      out[6] = 111;
      out[7] = 112;
      out[8] = 121;
      out[9] = 95;
      out[10] = 117;
      out[11] = 54;
      out[12] = 52;
      out[13] = 95;
      out[14] = 97;
      out[15] = 116;
      out[16] = 95;
      out[17] = 99;
      return 18;
    }
  }
  if (nlen == 11) {
    if (name[0]==99 && name[1]==111 && name[2]==112 && name[3]==121 && name[4]==95 && name[5]==102 && name[6]==54 && name[7]==52 && name[8]==95 && name[9]==97 && name[10]==116) {
      if (18 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 99;
      out[6] = 111;
      out[7] = 112;
      out[8] = 121;
      out[9] = 95;
      out[10] = 102;
      out[11] = 54;
      out[12] = 52;
      out[13] = 95;
      out[14] = 97;
      out[15] = 116;
      out[16] = 95;
      out[17] = 99;
      return 18;
    }
  }
  if (nlen == 28) {
    if (name[0]==99 && name[1]==111 && name[2]==112 && name[3]==121 && name[4]==95 && name[5]==105 && name[6]==51 && name[7]==50 && name[8]==95 && name[9]==112 && name[10]==116 && name[11]==114 && name[12]==95 && name[13]==105 && name[14]==51 && name[15]==50 && name[16]==95 && name[17]==105 && name[18]==51 && name[19]==50 && name[20]==95 && name[21]==112 && name[22]==116 && name[23]==114 && name[24]==95 && name[25]==105 && name[26]==51 && name[27]==50) {
      if (18 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 99;
      out[6] = 111;
      out[7] = 112;
      out[8] = 121;
      out[9] = 95;
      out[10] = 105;
      out[11] = 51;
      out[12] = 50;
      out[13] = 95;
      out[14] = 97;
      out[15] = 116;
      out[16] = 95;
      out[17] = 99;
      return 18;
    }
  }
  if (nlen == 26) {
    if (name[0]==99 && name[1]==111 && name[2]==112 && name[3]==121 && name[4]==95 && name[5]==117 && name[6]==56 && name[7]==95 && name[8]==112 && name[9]==116 && name[10]==114 && name[11]==95 && name[12]==105 && name[13]==51 && name[14]==50 && name[15]==95 && name[16]==117 && name[17]==56 && name[18]==95 && name[19]==112 && name[20]==116 && name[21]==114 && name[22]==95 && name[23]==105 && name[24]==51 && name[25]==50) {
      if (17 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 99;
      out[6] = 111;
      out[7] = 112;
      out[8] = 121;
      out[9] = 95;
      out[10] = 117;
      out[11] = 56;
      out[12] = 95;
      out[13] = 97;
      out[14] = 116;
      out[15] = 95;
      out[16] = 99;
      return 17;
    }
  }
  if (nlen == 28) {
    if (name[0]==99 && name[1]==111 && name[2]==112 && name[3]==121 && name[4]==95 && name[5]==102 && name[6]==51 && name[7]==50 && name[8]==95 && name[9]==112 && name[10]==116 && name[11]==114 && name[12]==95 && name[13]==105 && name[14]==51 && name[15]==50 && name[16]==95 && name[17]==102 && name[18]==51 && name[19]==50 && name[20]==95 && name[21]==112 && name[22]==116 && name[23]==114 && name[24]==95 && name[25]==105 && name[26]==51 && name[27]==50) {
      if (18 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 99;
      out[6] = 111;
      out[7] = 112;
      out[8] = 121;
      out[9] = 95;
      out[10] = 102;
      out[11] = 51;
      out[12] = 50;
      out[13] = 95;
      out[14] = 97;
      out[15] = 116;
      out[16] = 95;
      out[17] = 99;
      return 18;
    }
  }
  if (nlen == 28) {
    if (name[0]==99 && name[1]==111 && name[2]==112 && name[3]==121 && name[4]==95 && name[5]==117 && name[6]==54 && name[7]==52 && name[8]==95 && name[9]==112 && name[10]==116 && name[11]==114 && name[12]==95 && name[13]==105 && name[14]==51 && name[15]==50 && name[16]==95 && name[17]==117 && name[18]==54 && name[19]==52 && name[20]==95 && name[21]==112 && name[22]==116 && name[23]==114 && name[24]==95 && name[25]==105 && name[26]==51 && name[27]==50) {
      if (18 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 99;
      out[6] = 111;
      out[7] = 112;
      out[8] = 121;
      out[9] = 95;
      out[10] = 117;
      out[11] = 54;
      out[12] = 52;
      out[13] = 95;
      out[14] = 97;
      out[15] = 116;
      out[16] = 95;
      out[17] = 99;
      return 18;
    }
  }
  if (nlen == 28) {
    if (name[0]==99 && name[1]==111 && name[2]==112 && name[3]==121 && name[4]==95 && name[5]==102 && name[6]==54 && name[7]==52 && name[8]==95 && name[9]==112 && name[10]==116 && name[11]==114 && name[12]==95 && name[13]==105 && name[14]==51 && name[15]==50 && name[16]==95 && name[17]==102 && name[18]==54 && name[19]==52 && name[20]==95 && name[21]==112 && name[22]==116 && name[23]==114 && name[24]==95 && name[25]==105 && name[26]==51 && name[27]==50) {
      if (18 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 99;
      out[6] = 111;
      out[7] = 112;
      out[8] = 121;
      out[9] = 95;
      out[10] = 102;
      out[11] = 54;
      out[12] = 52;
      out[13] = 95;
      out[14] = 97;
      out[15] = 116;
      out[16] = 95;
      out[17] = 99;
      return 18;
    }
  }
  if (nlen == 12) {
    if (name[0]==97 && name[1]==114 && name[2]==101 && name[3]==110 && name[4]==97 && name[5]==54 && name[6]==52 && name[7]==95 && name[8]==105 && name[9]==110 && name[10]==105 && name[11]==116) {
      if (19 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 97;
      out[6] = 114;
      out[7] = 101;
      out[8] = 110;
      out[9] = 97;
      out[10] = 54;
      out[11] = 52;
      out[12] = 95;
      out[13] = 105;
      out[14] = 110;
      out[15] = 105;
      out[16] = 116;
      out[17] = 95;
      out[18] = 99;
      return 19;
    }
  }
  if (nlen == 13) {
    if (name[0]==97 && name[1]==114 && name[2]==101 && name[3]==110 && name[4]==97 && name[5]==54 && name[6]==52 && name[7]==95 && name[8]==97 && name[9]==108 && name[10]==108 && name[11]==111 && name[12]==99) {
      if (20 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 97;
      out[6] = 114;
      out[7] = 101;
      out[8] = 110;
      out[9] = 97;
      out[10] = 54;
      out[11] = 52;
      out[12] = 95;
      out[13] = 97;
      out[14] = 108;
      out[15] = 108;
      out[16] = 111;
      out[17] = 99;
      out[18] = 95;
      out[19] = 99;
      return 20;
    }
  }
  if (nlen == 14) {
    if (name[0]==97 && name[1]==114 && name[2]==101 && name[3]==110 && name[4]==97 && name[5]==54 && name[6]==52 && name[7]==95 && name[8]==100 && name[9]==101 && name[10]==105 && name[11]==110 && name[12]==105 && name[13]==116) {
      if (21 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 97;
      out[6] = 114;
      out[7] = 101;
      out[8] = 110;
      out[9] = 97;
      out[10] = 54;
      out[11] = 52;
      out[12] = 95;
      out[13] = 100;
      out[14] = 101;
      out[15] = 105;
      out[16] = 110;
      out[17] = 105;
      out[18] = 116;
      out[19] = 95;
      out[20] = 99;
      return 21;
    }
  }
  if (nlen == 7) {
    if (name[0]==112 && name[1]==116 && name[2]==114 && name[3]==95 && name[4]==109 && name[5]==111 && name[6]==100) {
      if (14 + 1 > cap) { return 0; }
      out[0] = 104;
      out[1] = 101;
      out[2] = 97;
      out[3] = 112;
      out[4] = 95;
      out[5] = 112;
      out[6] = 116;
      out[7] = 114;
      out[8] = 95;
      out[9] = 109;
      out[10] = 111;
      out[11] = 100;
      out[12] = 95;
      out[13] = 99;
      return 14;
    }
  }
  return 0;
}
