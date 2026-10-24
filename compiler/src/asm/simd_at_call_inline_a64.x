// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
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

// SHARED body of the SIMD @shuffle / @select inline.
// Typeck lowers @shuffle/@select to bare CALL (simd_shuffle /
// simd_select). Import simd.shuffle/select is METHOD_CALL kind 49
// with bare name "shuffle"/"select". Try pshufd / HW select first
// (Windows twin), then lane-scalar. PLATFORM: SHARED.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_num_args_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_arg_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_call_callee_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_call_callee_func_name_into_c(arena: *u8, callee_ref: i32, out: *u8, cap: i32): i32;
export extern function glue_vector_type_lanes_esz_c(arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32): i32;
export extern function glue_peel_comptime_array_lit_mask_c(arena: *u8, ctx: *u8, mask_ref: i32): i32;
export extern function glue_emit_vector_shuffle_lane_scalar_elf_c(
  arena: *u8, elf_ctx: *u8, src_ref: i32, mask_ref: i32, dst_off: i32, type_ref: i32, ctx: *u8, ta: i32
): i32;
export extern function glue_emit_vector_select_lane_scalar_elf_c(
  arena: *u8, elf_ctx: *u8, mask_ref: i32, a_ref: i32, b_ref: i32, dst_off: i32, type_ref: i32, ctx: *u8, ta: i32
): i32;
export extern function pipeline_expr_method_call_num_args_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_expr_method_call_arg_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function glue_asm_local_var_stack_off_scoped(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_shuffle_pshufd_imm8_from_mask_c(arena: *u8, mask_ref: i32, lanes: i32, out_imm: *i32): i32;
export extern function glue_simd_emit_cpu_features_c(): u32;
export extern function xlang_target_cpu_detect_host(): u32;
export extern function simd_enc_try_pshufd_rbp(elf_ctx: *u8, src: i32, dst: i32, imm8: i32, lanes: i32, ta: i32, feats: u32): i32;
export extern function simd_enc_try_hw_vector_select_rbp(elf_ctx: *u8, m: i32, a: i32, b: i32, d: i32, lanes: i32, is_f32: i32, ta: i32, feats: u32): i32;
export extern function glue_vector_elem_is_f32_c(arena: *u8, type_ref: i32): i32;
export extern function link_abi_getenv(name: *u8): *u8;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_asm_emit_func_index_c(): i32;
export extern function pipeline_module_func_body_ref_at(module: *u8, fi: i32): i32;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function asm_ctx_scope_block_ref_at(ctx: *u8): i32;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_let_name_len(arena: *u8, block_ref: i32, let_idx: i32): i32;
export extern function pipeline_block_let_name_copy64(arena: *u8, block_ref: i32, let_idx: i32, dst: *u8): void;
export extern function pipeline_block_let_init_ref(arena: *u8, block_ref: i32, let_idx: i32): i32;
export extern function pipeline_block_parent_block_ref_at(arena: *u8, block_ref: i32): i32;



/**
 * Peel mask expr to a comptime ARRAY_LIT ref.
 * glue_peel needs asm scope_block_ref; top-level function emit often
 * leaves it 0 while unscoped local_find still resolves VAR stack offs.
 * When glue_peel misses, walk the current emit function body (and
 * parents) by VAR name — same contract as glue_peel, for simd.shuffle
 * smoke `let m = [...]; simd.shuffle(v, m)`.
 * @return i32 — array-lit expr ref; 0 if not peelable
 * PLATFORM: SHARED.
 */
function at_peel_mask_lit(arena: *u8, ctx: *u8, mask_ref: i32): i32 {
  let got: i32 = 0;
  let ko: i32 = 0;
  let br: i32 = 0;
  let fi: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let nlet: i32 = 0;
  let li: i32 = 0;
  let vlen: i32 = 0;
  let llen: i32 = 0;
  let kk: i32 = 0;
  let is_match: i32 = 0;
  let init_ref: i32 = 0;
  let depth: i32 = 0;
  let vbuf: u8[256] = [];
  let lb: u8[256] = [];
  if (arena == (0 as *u8) || mask_ref <= 0) {
    return 0;
  }
  unsafe {
    got = glue_peel_comptime_array_lit_mask_c(arena, ctx, mask_ref);
  }
  if (got > 0) {
    return got;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, mask_ref);
  }
  if (ko == 46) {
    return mask_ref;
  }
  if (ko != 3 || ctx == (0 as *u8)) {
    return 0;
  }
  unsafe {
    br = asm_ctx_scope_block_ref_at(ctx);
  }
  if (br <= 0) {
    unsafe {
      fi = pipeline_asm_emit_func_index_c();
      mod = pipe_load_ptr_slot(ctx, 2);
    }
    if (mod != (0 as *u8) && fi >= 0) {
      unsafe {
        br = pipeline_module_func_body_ref_at(mod, fi);
      }
    }
  }
  if (br <= 0) {
    return 0;
  }
  unsafe {
    vlen = pipeline_expr_var_name_len(arena, mask_ref);
  }
  if (vlen <= 0 || vlen > 255) {
    return 0;
  }
  unsafe {
    pipeline_expr_var_name_into(arena, mask_ref, &vbuf[0]);
  }
  depth = 0;
  while (br > 0 && depth < 128) {
    unsafe {
      nlet = ast_ast_block_num_lets(arena, br);
    }
    li = 0;
    while (li < nlet) {
      unsafe {
        llen = pipeline_block_let_name_len(arena, br, li);
      }
      if (llen == vlen) {
        is_match = 1;
        unsafe {
          pipeline_block_let_name_copy64(arena, br, li, &lb[0]);
        }
        kk = 0;
        while (kk < vlen) {
          if (lb[kk] != vbuf[kk]) {
            is_match = 0;
          }
          kk = kk + 1;
        }
        if (is_match != 0) {
          unsafe {
            init_ref = pipeline_block_let_init_ref(arena, br, li);
          }
          if (init_ref > 0) {
            unsafe {
              ko = pipeline_expr_kind_ord_at(arena, init_ref);
            }
            if (ko == 46) {
              return init_ref;
            }
          }
          return 0;
        }
      }
      li = li + 1;
    }
    unsafe {
      br = pipeline_block_parent_block_ref_at(arena, br);
    }
    depth = depth + 1;
  }
  return 0;
}

/**
 * Read one callee-name byte as i32.
 * @param buf *u8 — name bytes; null returns -1
 * @param i i32 — index; negative returns -1
 * @return i32 — byte 0..255, or -1 when buf is null or i is negative
 * The caller checks the name length first. PLATFORM: SHARED.
 */
function at_name_byte(buf: *u8, i: i32): i32 {
  let c: u8 = 0;
  if (buf == (0 as *u8) || i < 0) {
    return 0 - 1;
  }
  unsafe {
    c = buf[i];
  }
  return c as i32;
}

/**
 * True when buf[i] is the expected byte.
 * @param buf *u8 — name bytes
 * @param i i32 — index
 * @param b i32 — expected byte 0..255
 * @return i32 — 1 match; 0 otherwise
 * PLATFORM: SHARED.
 */
function at_name_has(buf: *u8, i: i32, b: i32): i32 {
  if (at_name_byte(buf, i) != b) {
    return 0;
  }
  return 1;
}

/**
 * True when the name starts with simd_.
 * @param buf *u8 — name bytes; length is checked by the caller
 * @return i32 — 1 match; 0 otherwise
 * Bytes are s i m d _. PLATFORM: SHARED.
 */
function at_name_simd_us(buf: *u8): i32 {
  if (at_name_has(buf, 0, 115) == 0) {
    return 0;
  }
  if (at_name_has(buf, 1, 105) == 0) {
    return 0;
  }
  if (at_name_has(buf, 2, 109) == 0) {
    return 0;
  }
  if (at_name_has(buf, 3, 100) == 0) {
    return 0;
  }
  if (at_name_has(buf, 4, 95) == 0) {
    return 0;
  }
  return 1;
}

/**
 * True when seven bytes at off spell shuffle.
 * @param buf *u8 — name bytes
 * @param off i32 — start index
 * @return i32 — 1 match; 0 otherwise
 * PLATFORM: SHARED.
 */
function at_name_shuffle_at(buf: *u8, off: i32): i32 {
  if (at_name_has(buf, off, 115) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 1, 104) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 2, 117) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 3, 102) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 4, 102) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 5, 108) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 6, 101) == 0) {
    return 0;
  }
  return 1;
}

/**
 * True when six bytes at off spell select.
 * @param buf *u8 — name bytes
 * @param off i32 — start index
 * @return i32 — 1 match; 0 otherwise
 * PLATFORM: SHARED.
 */
function at_name_select_at(buf: *u8, off: i32): i32 {
  if (at_name_has(buf, off, 115) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 1, 101) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 2, 108) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 3, 101) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 4, 99) == 0) {
    return 0;
  }
  if (at_name_has(buf, off + 5, 116) == 0) {
    return 0;
  }
  return 1;
}

/**
 * True when the name starts with vec4f_.
 * @param buf *u8 — name bytes
 * @return i32 — 1 match; 0 otherwise
 * PLATFORM: SHARED.
 */
function at_name_vec4f_us(buf: *u8): i32 {
  if (at_name_has(buf, 0, 118) == 0) {
    return 0;
  }
  if (at_name_has(buf, 1, 101) == 0) {
    return 0;
  }
  if (at_name_has(buf, 2, 99) == 0) {
    return 0;
  }
  if (at_name_has(buf, 3, 52) == 0) {
    return 0;
  }
  if (at_name_has(buf, 4, 102) == 0) {
    return 0;
  }
  if (at_name_has(buf, 5, 95) == 0) {
    return 0;
  }
  return 1;
}

/**
 * True when the name starts with vec8i_.
 * @param buf *u8 — name bytes
 * @return i32 — 1 match; 0 otherwise
 * PLATFORM: SHARED.
 */
function at_name_vec8i_us(buf: *u8): i32 {
  if (at_name_has(buf, 0, 118) == 0) {
    return 0;
  }
  if (at_name_has(buf, 1, 101) == 0) {
    return 0;
  }
  if (at_name_has(buf, 2, 99) == 0) {
    return 0;
  }
  if (at_name_has(buf, 3, 56) == 0) {
    return 0;
  }
  if (at_name_has(buf, 4, 105) == 0) {
    return 0;
  }
  if (at_name_has(buf, 5, 95) == 0) {
    return 0;
  }
  return 1;
}

/**
 * Lane count required by a shuffle callee name.
 * @param buf *u8 — callee name bytes
 * @param n i32 — byte count
 * @return i32 — 0 any lane count; 4 or 8 when the prefix says so; -1 no match
 * simd_shuffle is 12 bytes. vec4f_shuffle and vec8i_shuffle are 13.
 * PLATFORM: SHARED.
 */
function at_shuffle_expect_lanes(buf: *u8, n: i32): i32 {
  if (n == 12 && at_name_simd_us(buf) != 0 && at_name_shuffle_at(buf, 5) != 0) {
    return 0;
  }
  if (n == 13 && at_name_vec4f_us(buf) != 0 && at_name_shuffle_at(buf, 6) != 0) {
    return 4;
  }
  if (n == 13 && at_name_vec8i_us(buf) != 0 && at_name_shuffle_at(buf, 6) != 0) {
    return 8;
  }
  /* import METHOD bare name: simd.shuffle → "shuffle". */
  if (n == 7 && at_name_shuffle_at(buf, 0) != 0) {
    return 0;
  }
  return 0 - 1;
}

/**
 * Lane count required by a select callee name.
 * @param buf *u8 — callee name bytes
 * @param n i32 — byte count
 * @return i32 — 0 any lane count; 4 or 8 when the prefix says so; -1 no match
 * simd_select is 11 bytes. vec4f_select and vec8i_select are 12.
 * PLATFORM: SHARED.
 */
function at_select_expect_lanes(buf: *u8, n: i32): i32 {
  if (n == 11 && at_name_simd_us(buf) != 0 && at_name_select_at(buf, 5) != 0) {
    return 0;
  }
  if (n == 12 && at_name_vec4f_us(buf) != 0 && at_name_select_at(buf, 6) != 0) {
    return 4;
  }
  if (n == 12 && at_name_vec8i_us(buf) != 0 && at_name_select_at(buf, 6) != 0) {
    return 8;
  }
  /* import METHOD bare name: simd.select → "select". */
  if (n == 6 && at_name_select_at(buf, 0) != 0) {
    return 0;
  }
  return 0 - 1;
}

/**
 * Inline simd_shuffle / vec4f_shuffle / vec8i_shuffle CALL or METHOD.
 * @param arena *u8 — AST arena; null returns 0
 * @param elf_ctx *u8 — encoder; null returns 0
 * @param call_ref i32 — CALL(48) or METHOD_CALL(49)
 * @param ctx *u8 — asm function frame; null returns 0
 * @param ta i32 — 0 x86_64, 1 arm64
 * @param stack_slot_off i32 — destination slot of lane 0; negative returns 0
 * @param type_ref i32 — result vector type
 * @return i32 — 1 stored; 0 not this call; -1 error
 * Import simd.shuffle is METHOD with bare name "shuffle". Try pshufd
 * first (unless XLANG_SIMD_HW=0), then lane-scalar. PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_asm_simd_try_inline_shuffle_call_elf_c(
  arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32,
  stack_slot_off: i32, type_ref: i32
): i32 {
  let ko: i32 = 0;
  let nargs: i32 = 0;
  let callee_ref: i32 = 0;
  let clen: i32 = 0;
  let cname: u8[256] = [];
  let expect: i32 = 0;
  let lanes: i32 = 0;
  let esz: i32 = 0;
  let arg0: i32 = 0;
  let arg1: i32 = 0;
  let mask_lit: i32 = 0;
  let mask_ko: i32 = 0;
  let rc: i32 = 0;
  let is_method: i32 = 0;
  let src_off: i32 = 0;
  let imm8: i32 = 0;
  let imm_cell: i32[1] = [];
  let feats: u32 = 0;
  let hw_env: *u8 = 0 as *u8;
  let hw_key: u8[16] = [];
  let hw_off: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8)) {
    return 0;
  }
  if (call_ref <= 0 || stack_slot_off < 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, call_ref);
  }
  if (ko != 48 && ko != 49) {
    return 0;
  }
  if (ko == 49) {
    is_method = 1;
  }
  if (is_method != 0) {
    unsafe {
      nargs = pipeline_expr_method_call_num_args_at(arena, call_ref);
    }
  } else {
    unsafe {
      nargs = pipeline_expr_call_num_args_at(arena, call_ref);
    }
  }
  if (nargs != 2) {
    return 0;
  }
  if (is_method != 0) {
    unsafe {
      clen = pipeline_expr_method_call_name_len(arena, call_ref);
    }
    if (clen <= 0 || clen >= 64) {
      return 0;
    }
    unsafe {
      pipeline_expr_method_call_name_into(arena, call_ref, &cname[0]);
    }
  } else {
    unsafe {
      callee_ref = pipeline_expr_call_callee_ref_at(arena, call_ref);
    }
    if (callee_ref <= 0) {
      return 0;
    }
    unsafe {
      clen = glue_call_callee_func_name_into_c(arena, callee_ref, &cname[0], 256);
    }
    if (clen <= 0 || clen >= 256) {
      return 0;
    }
  }
  expect = at_shuffle_expect_lanes(&cname[0], clen);
  if (expect < 0) {
    return 0;
  }
  unsafe {
    rc = glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  if (expect != 0 && lanes != expect) {
    return 0;
  }
  if (is_method != 0) {
    unsafe {
      arg0 = pipeline_expr_method_call_arg_ref(arena, call_ref, 0);
      arg1 = pipeline_expr_method_call_arg_ref(arena, call_ref, 1);
    }
  } else {
    unsafe {
      arg0 = pipeline_expr_call_arg_ref(arena, call_ref, 0);
      arg1 = pipeline_expr_call_arg_ref(arena, call_ref, 1);
    }
  }
  if (arg0 <= 0 || arg1 <= 0) {
    return 0 - 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, arg0);
  }
  if (ko != 3) {
    return 0;
  }
  unsafe {
    mask_lit = at_peel_mask_lit(arena, ctx, arg1);
  }
  if (mask_lit <= 0) {
    unsafe {
      mask_ko = pipeline_expr_kind_ord_at(arena, arg1);
    }
    if (mask_ko == 46) {
      mask_lit = arg1;
    }
  }
  if (mask_lit <= 0) {
    return 0;
  }
  unsafe {
    src_off = glue_asm_local_var_stack_off_scoped(arena, ctx, arg0);
  }
  if (src_off < 0) {
    return 0;
  }
  /* XLANG_SIMD_HW=0 disables HW pshufd (lane-scalar only). */
  hw_key[0] = 88;
  hw_key[1] = 76;
  hw_key[2] = 65;
  hw_key[3] = 78;
  hw_key[4] = 71;
  hw_key[5] = 95;
  hw_key[6] = 83;
  hw_key[7] = 73;
  hw_key[8] = 77;
  hw_key[9] = 68;
  hw_key[10] = 95;
  hw_key[11] = 72;
  hw_key[12] = 87;
  hw_key[13] = 0;
  unsafe {
    hw_env = link_abi_getenv(&hw_key[0]);
  }
  hw_off = 0;
  if (hw_env != (0 as *u8)) {
    unsafe {
      hw_off = hw_env[0] as i32;
    }
  }
  if (hw_env == (0 as *u8) || hw_off != 48) {
    unsafe {
      rc = glue_shuffle_pshufd_imm8_from_mask_c(arena, mask_lit, lanes, &imm_cell[0]);
    }
    if (rc == 0) {
      imm8 = imm_cell[0];
      unsafe {
        feats = glue_simd_emit_cpu_features_c();
      }
      if (feats == (0 as u32)) {
        unsafe {
          feats = xlang_target_cpu_detect_host();
        }
      }
      unsafe {
        rc = simd_enc_try_pshufd_rbp(elf_ctx, src_off, stack_slot_off, imm8, lanes, ta, feats);
      }
      if (rc == 0) {
        return 1;
      }
    }
  }
  unsafe {
    rc = glue_emit_vector_shuffle_lane_scalar_elf_c(
      arena, elf_ctx, arg0, mask_lit, stack_slot_off, type_ref, ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 1;
}

/**
 * Inline simd_select / vec4f_select / vec8i_select CALL or METHOD.
 * @param arena *u8 — AST arena; null returns 0
 * @param elf_ctx *u8 — encoder; null returns 0
 * @param call_ref i32 — CALL(48) or METHOD_CALL(49)
 * @param ctx *u8 — asm function frame; null returns 0
 * @param ta i32 — 0 x86_64, 1 arm64
 * @param stack_slot_off i32 — destination slot of lane 0; negative returns 0
 * @param type_ref i32 — result vector type
 * @return i32 — 1 stored; 0 not this call; -1 error
 * Import simd.select is METHOD with bare name "select". Try HW
 * blend first (unless XLANG_SIMD_HW=0), then lane-scalar.
 * Smoke args are VARs (stack-off via scoped local). PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_asm_simd_try_inline_select_call_elf_c(
  arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32,
  stack_slot_off: i32, type_ref: i32
): i32 {
  let ko: i32 = 0;
  let nargs: i32 = 0;
  let callee_ref: i32 = 0;
  let clen: i32 = 0;
  let cname: u8[256] = [];
  let expect: i32 = 0;
  let lanes: i32 = 0;
  let esz: i32 = 0;
  let arg_m: i32 = 0;
  let arg_a: i32 = 0;
  let arg_b: i32 = 0;
  let rc: i32 = 0;
  let is_method: i32 = 0;
  let off_m: i32 = 0;
  let off_a: i32 = 0;
  let off_b: i32 = 0;
  let is_f32: i32 = 0;
  let feats: u32 = 0;
  let hw_env: *u8 = 0 as *u8;
  let hw_key: u8[16] = [];
  let hw_off: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8)) {
    return 0;
  }
  if (call_ref <= 0 || stack_slot_off < 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, call_ref);
  }
  if (ko != 48 && ko != 49) {
    return 0;
  }
  if (ko == 49) {
    is_method = 1;
  }
  if (is_method != 0) {
    unsafe {
      nargs = pipeline_expr_method_call_num_args_at(arena, call_ref);
    }
  } else {
    unsafe {
      nargs = pipeline_expr_call_num_args_at(arena, call_ref);
    }
  }
  if (nargs != 3) {
    return 0;
  }
  if (is_method != 0) {
    unsafe {
      clen = pipeline_expr_method_call_name_len(arena, call_ref);
    }
    if (clen <= 0 || clen >= 64) {
      return 0;
    }
    unsafe {
      pipeline_expr_method_call_name_into(arena, call_ref, &cname[0]);
    }
  } else {
    unsafe {
      callee_ref = pipeline_expr_call_callee_ref_at(arena, call_ref);
    }
    if (callee_ref <= 0) {
      return 0;
    }
    unsafe {
      clen = glue_call_callee_func_name_into_c(arena, callee_ref, &cname[0], 256);
    }
    if (clen <= 0 || clen >= 256) {
      return 0;
    }
  }
  expect = at_select_expect_lanes(&cname[0], clen);
  if (expect < 0) {
    return 0;
  }
  unsafe {
    rc = glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  if (expect != 0 && lanes != expect) {
    return 0;
  }
  if (is_method != 0) {
    unsafe {
      arg_m = pipeline_expr_method_call_arg_ref(arena, call_ref, 0);
      arg_a = pipeline_expr_method_call_arg_ref(arena, call_ref, 1);
      arg_b = pipeline_expr_method_call_arg_ref(arena, call_ref, 2);
    }
  } else {
    unsafe {
      arg_m = pipeline_expr_call_arg_ref(arena, call_ref, 0);
      arg_a = pipeline_expr_call_arg_ref(arena, call_ref, 1);
      arg_b = pipeline_expr_call_arg_ref(arena, call_ref, 2);
    }
  }
  if (arg_m <= 0 || arg_a <= 0 || arg_b <= 0) {
    return 0 - 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, arg_m);
  }
  if (ko != 3) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, arg_a);
  }
  if (ko != 3) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, arg_b);
  }
  if (ko != 3) {
    return 0;
  }
  unsafe {
    off_m = glue_asm_local_var_stack_off_scoped(arena, ctx, arg_m);
    off_a = glue_asm_local_var_stack_off_scoped(arena, ctx, arg_a);
    off_b = glue_asm_local_var_stack_off_scoped(arena, ctx, arg_b);
  }
  if (off_m < 0 || off_a < 0 || off_b < 0) {
    return 0;
  }
  unsafe {
    is_f32 = glue_vector_elem_is_f32_c(arena, type_ref);
  }
  hw_key[0] = 88;
  hw_key[1] = 76;
  hw_key[2] = 65;
  hw_key[3] = 78;
  hw_key[4] = 71;
  hw_key[5] = 95;
  hw_key[6] = 83;
  hw_key[7] = 73;
  hw_key[8] = 77;
  hw_key[9] = 68;
  hw_key[10] = 95;
  hw_key[11] = 72;
  hw_key[12] = 87;
  hw_key[13] = 0;
  unsafe {
    hw_env = link_abi_getenv(&hw_key[0]);
  }
  hw_off = 0;
  if (hw_env != (0 as *u8)) {
    unsafe {
      hw_off = hw_env[0] as i32;
    }
  }
  if (hw_env == (0 as *u8) || hw_off != 48) {
    unsafe {
      feats = glue_simd_emit_cpu_features_c();
    }
    if (feats == (0 as u32)) {
      unsafe {
        feats = xlang_target_cpu_detect_host();
      }
    }
    unsafe {
      rc = simd_enc_try_hw_vector_select_rbp(
        elf_ctx, off_m, off_a, off_b, stack_slot_off, lanes, is_f32, ta, feats);
    }
    if (rc == 0) {
      return 1;
    }
  }
  unsafe {
    rc = glue_emit_vector_select_lane_scalar_elf_c(
      arena, elf_ctx, arg_m, arg_a, arg_b, stack_slot_off, type_ref, ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 1;
}
