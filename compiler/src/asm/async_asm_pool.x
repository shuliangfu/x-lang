// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.

export extern "C" function pipeline_expr_kind_ord_at(a: *u8, er: i32): i32;
export extern "C" function pipeline_expr_unary_operand_ref_at(a: *u8, er: i32): i32;
export extern "C" function pipeline_expr_as_operand_ref_at(a: *u8, er: i32): i32;
export extern "C" function pipeline_expr_as_target_type_ref_at(a: *u8, er: i32): i32;
export extern "C" function pipeline_expr_binop_left_ref_at(a: *u8, er: i32): i32;
export extern "C" function pipeline_expr_binop_right_ref_at(a: *u8, er: i32): i32;
export extern "C" function pipeline_expr_field_access_base_ref(a: *u8, er: i32): i32;
export extern "C" function pipeline_expr_index_base_ref(a: *u8, er: i32): i32;
export extern "C" function pipeline_expr_index_index_ref(a: *u8, er: i32): i32;
export extern "C" function pipeline_expr_var_name_len(a: *u8, er: i32): i32;
export extern "C" function pipeline_expr_var_name_into(a: *u8, er: i32, out: *u8): void;
export extern "C" function ast_ast_block_num_lets(a: *u8, br: i32): i32;
export extern "C" function ast_ast_block_num_expr_stmts(a: *u8, br: i32): i32;
export extern "C" function ast_ast_block_num_stmt_order(a: *u8, br: i32): i32;
export extern "C" function ast_ast_block_stmt_order_kind(a: *u8, br: i32, si: i32): u8;
export extern "C" function ast_ast_block_stmt_order_idx(a: *u8, br: i32, si: i32): i32;
export extern "C" function pipeline_block_let_init_ref(a: *u8, br: i32, li: i32): i32;
export extern "C" function ast_pipeline_block_expr_stmt_ref(a: *u8, br: i32, ei: i32): i32;
export extern "C" function pipeline_asm_block_final_expr_ref_at(a: *u8, br: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(a: *u8, tr: i32): i32;
export extern "C" function pipeline_type_named_name_into(a: *u8, tr: i32, out: *u8): i32;
export extern "C" function pipeline_module_num_struct_layouts_at(m: *u8): i32;
export extern "C" function pipeline_module_struct_layout_name_len(m: *u8, k: i32): i32;
export extern "C" function pipeline_module_struct_layout_name_byte_at(m: *u8, k: i32, j: i32): u8;
export extern "C" function typeck_x_type_size_from_layout_glue(m: *u8, a: *u8, k: i32, depth: i32): i32;
export extern "C" function pipeline_module_func_is_async_at(m: *u8, fi: i32): i32;
export extern "C" function pipeline_module_func_body_ref_at(m: *u8, fi: i32): i32;
export extern "C" function pipeline_module_func_name_len_at(m: *u8, fi: i32): i32;
export extern "C" function pipeline_module_func_name_copy64(m: *u8, fi: i32, dst: *u8): void;
export extern "C" function pipeline_block_let_type_ref(a: *u8, br: i32, li: i32): i32;
export extern "C" function pipeline_block_let_name_len(a: *u8, br: i32, li: i32): i32;
export extern "C" function pipeline_block_let_name_copy64(a: *u8, br: i32, li: i32, dst: *u8): void;

/** Module doc anchor (prove surface symbol; no product callers).
 * @return always 0
 * PLATFORM: SHARED */
#[no_mangle]
export function async_asm_pool_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-142：async asm pool pure helpers ---- */

// See implementation.
// asm_pool_expr_is_await: see function docblock below.
/** Exported function `asm_pool_expr_is_await`.
 * Implements `asm_pool_expr_is_await`.
 * @param a *u8
 * @param er i32
 * @return i32
 */
#[no_mangle]
export function asm_pool_expr_is_await(a: *u8, er: i32): i32 {
  if (a == 0) { return 0; }
  if (er <= 0) { return 0; }
  unsafe {
    let ko: i32 = pipeline_expr_kind_ord_at(a, er);
    if (ko == 55) {
      let uop: i32 = pipeline_expr_unary_operand_ref_at(a, er);
      if (uop > 0) { return 1; }
      return 0;
    }
    if (ko != 54) { return 0; }
    if (pipeline_expr_as_target_type_ref_at(a, er) > 0) { return 0; }
    if (pipeline_expr_as_operand_ref_at(a, er) > 0) { return 0; }
    let uop2: i32 = pipeline_expr_unary_operand_ref_at(a, er);
    if (uop2 > 0) { return 1; }
  }
  return 0;
}

// asm_pool_expr_has_await: see function docblock below.
/** Exported function `asm_pool_expr_has_await`.
 * Implements `asm_pool_expr_has_await`.
 * @param a *u8
 * @param er i32
 * @return i32
 */
#[no_mangle]
export function asm_pool_expr_has_await(a: *u8, er: i32): i32 {
  if (a == 0) { return 0; }
  if (er <= 0) { return 0; }
  unsafe {
    if (asm_pool_expr_is_await(a, er) != 0) { return 1; }
    let ko: i32 = pipeline_expr_kind_ord_at(a, er);
    if (ko >= 4) {
      if (ko <= 21) {
        if (asm_pool_expr_has_await(a, pipeline_expr_binop_left_ref_at(a, er)) != 0) { return 1; }
        return asm_pool_expr_has_await(a, pipeline_expr_binop_right_ref_at(a, er));
      }
    }
    if (ko == 22) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if (ko == 23) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if (ko == 24) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if (ko == 54) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if (ko == 55) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if (ko == 51) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if (ko == 52) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if (ko == 44) {
      return asm_pool_expr_has_await(a, pipeline_expr_field_access_base_ref(a, er));
    }
    if (ko == 47) {
      if (asm_pool_expr_has_await(a, pipeline_expr_index_base_ref(a, er)) != 0) { return 1; }
      return asm_pool_expr_has_await(a, pipeline_expr_index_index_ref(a, er));
    }
  }
  return 0;
}

// asm_pool_expr_is_var_named: see function docblock below.
/** Exported function `asm_pool_expr_is_var_named`.
 * Implements `asm_pool_expr_is_var_named`.
 * @param a *u8
 * @param er i32
 * @param name *u8
 * @param nlen i32
 * @return i32
 */
#[no_mangle]
export function asm_pool_expr_is_var_named(a: *u8, er: i32, name: *u8, nlen: i32): i32 {
  if (a == 0) { return 0; }
  if (er <= 0) { return 0; }
  if (name == 0) { return 0; }
  if (nlen <= 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(a, er) != 3) { return 0; }
    let vlen: i32 = pipeline_expr_var_name_len(a, er);
    if (vlen != nlen) { return 0; }
    let vbuf: u8[64] = [];
    pipeline_expr_var_name_into(a, er, &vbuf[0]);
    let i: i32 = 0;
    while (i < nlen) {
      if (vbuf[i] != name[i]) { return 0; }
      i = i + 1;
    }
    return 1;
  }
  return 0;
}

// asm_pool_expr_refs_name: see function docblock below.
/** Exported function `asm_pool_expr_refs_name`.
 * Implements `asm_pool_expr_refs_name`.
 * @param a *u8
 * @param er i32
 * @param name *u8
 * @param nlen i32
 * @return i32
 */
#[no_mangle]
export function asm_pool_expr_refs_name(a: *u8, er: i32, name: *u8, nlen: i32): i32 {
  if (a == 0) { return 0; }
  if (er <= 0) { return 0; }
  if (name == 0) { return 0; }
  if (nlen <= 0) { return 0; }
  unsafe {
    if (asm_pool_expr_is_var_named(a, er, name, nlen) != 0) { return 1; }
    let ko: i32 = pipeline_expr_kind_ord_at(a, er);
    if (ko >= 4) {
      if (ko <= 21) {
        if (asm_pool_expr_refs_name(a, pipeline_expr_binop_left_ref_at(a, er), name, nlen) != 0) { return 1; }
        return asm_pool_expr_refs_name(a, pipeline_expr_binop_right_ref_at(a, er), name, nlen);
      }
    }
    if (ko == 22) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if (ko == 23) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if (ko == 24) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if (ko == 54) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if (ko == 55) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if (ko == 51) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if (ko == 52) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if (ko == 44) {
      return asm_pool_expr_refs_name(a, pipeline_expr_field_access_base_ref(a, er), name, nlen);
    }
    if (ko == 47) {
      if (asm_pool_expr_refs_name(a, pipeline_expr_index_base_ref(a, er), name, nlen) != 0) { return 1; }
      return asm_pool_expr_refs_name(a, pipeline_expr_index_index_ref(a, er), name, nlen);
    }
  }
  return 0;
}

// asm_pool_block_rest_refs_name: see function docblock below.
/** Exported function `asm_pool_block_rest_refs_name`.
 * Implements `asm_pool_block_rest_refs_name`.
 * @param a *u8
 * @param br i32
 * @param from_exclusive i32
 * @param name *u8
 * @param nlen i32
 * @return i32
 */
#[no_mangle]
export function asm_pool_block_rest_refs_name(a: *u8, br: i32, from_exclusive: i32, name: *u8, nlen: i32): i32 {
  if (a == 0) { return 0; }
  if (br <= 0) { return 0; }
  if (name == 0) { return 0; }
  if (nlen <= 0) { return 0; }
  unsafe {
    let nso: i32 = ast_ast_block_num_stmt_order(a, br);
    let si: i32 = from_exclusive + 1;
    while (si < nso) {
      let kind: u8 = ast_ast_block_stmt_order_kind(a, br, si);
      let idx: i32 = ast_ast_block_stmt_order_idx(a, br, si);
      if (kind == 1) {
        if (idx >= 0) {
          if (idx < ast_ast_block_num_lets(a, br)) {
            let init: i32 = pipeline_block_let_init_ref(a, br, idx);
            if (init > 0) {
              if (asm_pool_expr_refs_name(a, init, name, nlen) != 0) { return 1; }
            }
          }
        }
      } else {
        if (kind == 2) {
          if (idx >= 0) {
            if (idx < ast_ast_block_num_expr_stmts(a, br)) {
              let ex: i32 = ast_pipeline_block_expr_stmt_ref(a, br, idx);
              if (ex > 0) {
                if (asm_pool_expr_refs_name(a, ex, name, nlen) != 0) { return 1; }
              }
            }
          }
        }
      }
      si = si + 1;
    }
    let fin: i32 = pipeline_asm_block_final_expr_ref_at(a, br);
    if (fin > 0) {
      if (asm_pool_expr_refs_name(a, fin, name, nlen) != 0) { return 1; }
    }
  }
  return 0;
}

// See implementation.
// asm_pool_type_size_bytes: see function docblock below.
/** Exported function `asm_pool_type_size_bytes`.
 * Implements `asm_pool_type_size_bytes`.
 * @param a *u8
 * @param m *u8
 * @param type_ref i32
 * @return i32
 */
#[no_mangle]
export function asm_pool_type_size_bytes(a: *u8, m: *u8, type_ref: i32): i32 {
  if (a == 0) { return 8; }
  if (type_ref <= 0) { return 8; }
  unsafe {
    let kind: i32 = pipeline_type_kind_ord_at(a, type_ref);
    if (kind == 0) { return 4; }
    if (kind == 1) { return 4; }
    if (kind == 2) { return 1; }
    if (kind == 3) { return 8; }
    if (kind == 4) { return 8; }
    if (kind == 5) { return 8; }
    if (kind == 6) { return 8; }
    if (kind == 7) { return 8; }
    if (kind == 9) { return 8; }
    if (kind == 8) {
      let name: u8[64] = [];
      let nlen: i32 = pipeline_type_named_name_into(a, type_ref, &name[0]);
      if (nlen <= 0) { return 8; }
      if (m == 0) { return 8; }
      let nlay: i32 = pipeline_module_num_struct_layouts_at(m);
      let k: i32 = 0;
      while (k < nlay) {
        let ln: i32 = pipeline_module_struct_layout_name_len(m, k);
        if (ln == nlen) {
          let j: i32 = 0;
          let eq: i32 = 1;
          while (j < nlen) {
            if (pipeline_module_struct_layout_name_byte_at(m, k, j) != name[j]) {
              eq = 0;
              break;
            }
            j = j + 1;
          }
          if (eq != 0) {
            let sz: i32 = typeck_x_type_size_from_layout_glue(m, a, k, 0);
            if (sz > 0) { return sz; }
            return 8;
          }
        }
        k = k + 1;
      }
      return 8;
    }
  }
  return 8;
}

/** Load little-endian i32 from byte buffer at off.
 * @param p buffer (null → 0)
 * @param off byte offset
 * @return i32 value
 * PLATFORM: SHARED — host endian for layout bytes. */
#[no_mangle]
export function asm_pool_load_i32_le(p: *u8, off: i32): i32 {
  if (p == 0) { return 0; }
  let m: i32 = 256;
  let a: i32 = p[off] as i32;
  a = a + (p[off + 1] as i32) * m;
  a = a + (p[off + 2] as i32) * (m * m);
  a = a + (p[off + 3] as i32) * (m * m * m);
  return a;
}

/** Store little-endian i32 into byte buffer at off.
 * @param p buffer (null → no-op)
 * @param off byte offset
 * @param v value
 * PLATFORM: SHARED */
#[no_mangle]
export function asm_pool_store_i32_le(p: *u8, off: i32, v: i32): void {
  if (p == 0) { return; }
  let u: u32 = v as u32;
  p[off] = (u & 255) as u8;
  p[off + 1] = ((u / 256) & 255) as u8;
  p[off + 2] = ((u / 65536) & 255) as u8;
  p[off + 3] = ((u / 16777216) & 255) as u8;
}

// See implementation.
// AsyncAsmPoolLiveVar: name[64]@0 name_len@64 size_bytes@68 frame_data_off@72; stride 76
// ASYNC_LIVE_MAX_VARS=64
/** Exported function `asm_pool_live_add`.
 * Implements `asm_pool_live_add`.
 * @param lay *u8
 * @param name *u8
 * @param nlen i32
 * @param sz i32
 * @return void
 */
#[no_mangle]
export function asm_pool_live_add(lay: *u8, name: *u8, nlen: i32, sz: i32): void {
  if (lay == 0) { return; }
  if (name == 0) { return; }
  if (nlen <= 0) { return; }
  if (nlen > 63) { return; }
  unsafe {
    let num: i32 = asm_pool_load_i32_le(lay, 8);
    if (num >= 64) { return; }
    let i: i32 = 0;
    while (i < num) {
      let base: i32 = 12 + i * 76;
      let elen: i32 = asm_pool_load_i32_le(lay, base + 64);
      if (elen == nlen) {
        let eq: i32 = 1;
        let j: i32 = 0;
        while (j < nlen) {
          if (lay[base + j] != name[j]) {
            eq = 0;
            break;
          }
          j = j + 1;
        }
        if (eq != 0) { return; }
      }
      i = i + 1;
    }
    let off: i32 = 0;
    i = 0;
    while (i < num) {
      let base2: i32 = 12 + i * 76;
      off = off + asm_pool_load_i32_le(lay, base2 + 68);
      i = i + 1;
    }
    let slot: i32 = 12 + num * 76;
    let k: i32 = 0;
    while (k < nlen) {
      lay[slot + k] = name[k];
      k = k + 1;
    }
    lay[slot + nlen] = 0;
    asm_pool_store_i32_le(lay, slot + 64, nlen);
    let sz2: i32 = sz;
    if (sz2 <= 0) { sz2 = 4; }
    asm_pool_store_i32_le(lay, slot + 68, sz2);
    asm_pool_store_i32_le(lay, slot + 72, off);
    asm_pool_store_i32_le(lay, 8, num + 1);
  }
}

// async_asm_pool_fn_id_from_name: see function docblock below.
/** Exported function `async_asm_pool_fn_id_from_name`.
 * Implements `async_asm_pool_fn_id_from_name`.
 * @param name *u8
 * @param name_len i32
 * @return u32
 */
#[no_mangle]
export function async_asm_pool_fn_id_from_name(name: *u8, name_len: i32): u32 {
  if (name == 0) { return 1; }
  if (name_len <= 0) { return 1; }
  let h: u32 = 2166136261;
  let i: i32 = 0;
  while (i < name_len) {
    h = (h ^ (name[i] as u32)) * 16777619;
    i = i + 1;
  }
  if (h == 0) { return 1; }
  return h;
}

// async_asm_pool_func_needs_cps: see function docblock below.
/** Exported function `async_asm_pool_func_needs_cps`.
 * Implements `async_asm_pool_func_needs_cps`.
 * @param arena *u8
 * @param mod *u8
 * @param func_index i32
 * @return i32
 */
#[no_mangle]
export function async_asm_pool_func_needs_cps(arena: *u8, mod: *u8, func_index: i32): i32 {
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  if (func_index < 0) { return 0; }
  unsafe {
    if (pipeline_module_func_is_async_at(mod, func_index) == 0) { return 0; }
    let br: i32 = pipeline_module_func_body_ref_at(mod, func_index);
    if (br <= 0) { return 0; }
    let nso: i32 = ast_ast_block_num_stmt_order(arena, br);
    let si: i32 = 0;
    while (si < nso) {
      if (ast_ast_block_stmt_order_kind(arena, br, si) == 1) {
        let li: i32 = ast_ast_block_stmt_order_idx(arena, br, si);
        let init: i32 = pipeline_block_let_init_ref(arena, br, li);
        if (init > 0) {
          if (asm_pool_expr_has_await(arena, init) != 0) { return 1; }
        }
      }
      si = si + 1;
    }
  }
  return 0;
}

/** Build AsyncAsmPoolLayout for one async function (R2 full true-migrate).
 * Walks stmt_order, finds let-inits with await, and records live vars that the
 * continuation still references (including the await let itself).
 *
 * AsyncAsmPoolLayout byte layout (PLATFORM: SHARED, little-endian host):
 *   fn_id@0 u32, num_awaits@4 i32, num_live@8 i32,
 *   live[64]@12 stride 76 (name[64], name_len@+64, size_bytes@+68, frame_data_off@+72),
 *   await_stmt_idx@4876 i32; total 4880 bytes.
 *
 * @param arena AST arena (opaque)
 * @param mod module (opaque)
 * @param func_index function index in module
 * @param out layout buffer (must be at least 4880 bytes)
 * @return 0 success with awaits, 1 no CPS needed, -1 bad args
 * PLATFORM: SHARED — pure pool API; product cold seed retains C body until glue unbundle. */
#[no_mangle]
export function async_asm_pool_build_layout(arena: *u8, mod: *u8, func_index: i32, out: *u8): i32 {
  if (arena == 0) { return 0 - 1; }
  if (mod == 0) { return 0 - 1; }
  if (out == 0) { return 0 - 1; }
  if (func_index < 0) { return 0 - 1; }
  // Zero entire layout (sizeof AsyncAsmPoolLayout == 4880).
  let zi: i32 = 0;
  while (zi < 4880) {
    out[zi] = 0;
    zi = zi + 1;
  }
  if (async_asm_pool_func_needs_cps(arena, mod, func_index) == 0) {
    return 1;
  }
  unsafe {
    let fname: u8[64] = [];
    let fnlen: i32 = pipeline_module_func_name_len_at(mod, func_index);
    pipeline_module_func_name_copy64(mod, func_index, fname);
    let fid: u32 = async_asm_pool_fn_id_from_name(fname, fnlen);
    asm_pool_store_i32_le(out, 0, fid as i32);
    // await_stmt_idx = -1 until first await let is seen
    asm_pool_store_i32_le(out, 4876, 0 - 1);
    let br: i32 = pipeline_module_func_body_ref_at(mod, func_index);
    let nso: i32 = ast_ast_block_num_stmt_order(arena, br);
    // defined_names[64][64] flattened; defined_lens[64]
    let defined_names: u8[4096] = [];
    let defined_lens: i32[64] = [];
    let n_def: i32 = 0;
    let si: i32 = 0;
    while (si < nso) {
      let kind: u8 = ast_ast_block_stmt_order_kind(arena, br, si);
      let idx: i32 = ast_ast_block_stmt_order_idx(arena, br, si);
      let nlets: i32 = ast_ast_block_num_lets(arena, br);
      if (kind == 1) {
        if (idx >= 0) {
          if (idx < nlets) {
            let init: i32 = pipeline_block_let_init_ref(arena, br, idx);
            if (init > 0) {
              if (asm_pool_expr_has_await(arena, init) != 0) {
                let na: i32 = asm_pool_load_i32_le(out, 4);
                asm_pool_store_i32_le(out, 4, na + 1);
                let cur_await: i32 = asm_pool_load_i32_le(out, 4876);
                if (cur_await < 0) {
                  asm_pool_store_i32_le(out, 4876, si);
                }
                // Live-add each previously defined name still referenced after this await.
                let li: i32 = 0;
                while (li < n_def) {
                  let dlen: i32 = defined_lens[li];
                  let dbase: i32 = li * 64;
                  let dname: u8[64] = [];
                  let di: i32 = 0;
                  while (di < dlen) {
                    dname[di] = defined_names[dbase + di];
                    di = di + 1;
                  }
                  if (asm_pool_block_rest_refs_name(arena, br, si, dname, dlen) != 0) {
                    let tref: i32 = 0;
                    let j: i32 = 0;
                    while (j < nlets) {
                      if (pipeline_block_let_name_len(arena, br, j) == dlen) {
                        let nb: u8[64] = [];
                        pipeline_block_let_name_copy64(arena, br, j, nb);
                        let eq: i32 = 1;
                        let bi: i32 = 0;
                        while (bi < dlen) {
                          if (nb[bi] != dname[bi]) {
                            eq = 0;
                            break;
                          }
                          bi = bi + 1;
                        }
                        if (eq != 0) {
                          tref = pipeline_block_let_type_ref(arena, br, j);
                          break;
                        }
                      }
                      j = j + 1;
                    }
                    let sz: i32 = asm_pool_type_size_bytes(arena, mod, tref);
                    asm_pool_live_add(out, dname, dlen, sz);
                  }
                  li = li + 1;
                }
                // Await let itself if referenced after suspend (same as C static hoist).
                let cur_nb: u8[64] = [];
                let cur_len: i32 = pipeline_block_let_name_len(arena, br, idx);
                if (cur_len > 0) {
                  if (cur_len <= 63) {
                    pipeline_block_let_name_copy64(arena, br, idx, cur_nb);
                    if (asm_pool_block_rest_refs_name(arena, br, si, cur_nb, cur_len) != 0) {
                      let tref2: i32 = pipeline_block_let_type_ref(arena, br, idx);
                      let sz2: i32 = asm_pool_type_size_bytes(arena, mod, tref2);
                      asm_pool_live_add(out, cur_nb, cur_len, sz2);
                    }
                  }
                }
              }
            }
            // Record this let as defined for later await live-sets.
            let llen: i32 = pipeline_block_let_name_len(arena, br, idx);
            if (llen > 0) {
              if (llen <= 63) {
                if (n_def < 64) {
                  let lnb: u8[64] = [];
                  pipeline_block_let_name_copy64(arena, br, idx, lnb);
                  let dbase2: i32 = n_def * 64;
                  let k: i32 = 0;
                  while (k < llen) {
                    defined_names[dbase2 + k] = lnb[k];
                    k = k + 1;
                  }
                  defined_lens[n_def] = llen;
                  n_def = n_def + 1;
                }
              }
            }
          }
        }
      }
      si = si + 1;
    }
    let num_awaits: i32 = asm_pool_load_i32_le(out, 4);
    if (num_awaits > 0) {
      return 0;
    }
  }
  return 1;
}
