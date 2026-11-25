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

// Linked body of pipeline_asm_modlet_seed_nonzero_inits_elf_c.
// The pabi copy hardcodes the high half to 0, so a file-level
// `let g: i32 = -7` is stored as 0x00000000fffffff9. An 8-byte
// load then fails `g != -7`. This file is the same seed as
// runtime_pipeline_abi_modlet_thin.x, including the signed high
// half. The modlet table itself stays the pabi BSS symbol.
// pipe_modlet_table_base is the arm64 stub that returns it.
// PLATFORM: SHARED seed. The table stub is MACOS|ARM64.

export extern function pipe_modlet_table_base(): *u8;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_module_main_func_index(module: *u8): i32;
export extern function pipe_modlet_get_n(): i32;
export extern function pipe_modlet_off_init_imm(i: i32): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_modlet_off_name_len(i: i32): i32;
export extern function pipe_modlet_off_name(i: i32): i32;
export extern function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern function pipeline_asm_modlet_store_from_rax_elf_c(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern function pipeline_asm_emit_ctx_arena_get(): *u8;
export extern function pipe_mod_get_num_top_level_lets(module: *u8): i32;
export extern function pipe_arena_off_num_exprs(): i32;
export extern function pipeline_module_top_level_let_name_len(module: *u8, idx: i32): i32;
export extern function pipeline_module_top_level_let_name_byte_at(module: *u8, idx: i32, byte_i: i32): i32;
export extern function pipeline_module_top_level_let_type_ref(module: *u8, idx: i32): i32;
export extern function pipeline_module_top_level_let_init_ref(module: *u8, idx: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_asm_modlet_find(name: *u8, name_len: i32): i32;
export extern function pipe_modlet_off_cell_size(i: i32): i32;
export extern function pipe_modlet_cell_is_array(csz: i32): i32;
export extern function pipe_modlet_cell_is_data(csz: i32): i32;
export extern function pipeline_asm_modlet_lea_rbx_arch(elf_ctx: *u8, idx: i32, ta: i32): i32;
export extern function pipe_modlet_seed_array_lit_elems_to_rbx(
  arena: *u8, elf_ctx: *u8, init_ref: i32, et: i32, ta: i32, byte_off: i32, module: *u8
): i32;

/**
 * Pointer to name bytes at byte offset off inside the modlet table.
 * @param tab *u8 — table base; null returns null
 * @param off i32 — byte offset; negative returns null
 * @return *u8 — address of that byte
 * PLATFORM: SHARED.
 */
function seed_tab_at(tab: *u8, off: i32): *u8 {
  if (tab == (0 as *u8) || off < 0) {
    return 0 as *u8;
  }
  return ((tab as usize) + (off as usize)) as *u8;
}

/**
 * High half for one scalar COMMON seed immediate.
 * init_imm is one 32-bit two's-complement word. A non-negative word
 * always has high half 0. A negative word sign-extends (high half -1)
 * only for a signed cell: i32, i64, isize, or Cap residual i8/i16.
 * Unsigned cells stay zero-extended, including u32 all-ones, whose
 * low word is negative when read as i32. u8, u32, u64, usize, and
 * Cap residual u16 take this path. Any other kind, or a missing
 * module, arena, or name, keeps the historic zero high half.
 * The lookup matches the modlet name against top-level lets. The
 * 32-bit table cannot hold an i64 outside that word; this function
 * does not invent the missing half.
 * @param imm i32 — folded init_imm; may be negative
 * @param name *u8 — modlet name bytes; not NUL-terminated
 * @param name_len i32 — name length; <= 0 returns 0
 * @return i32 — 0 or -1, passed as hi to backend_enc_mov_imm64_to_rax_arch
 * PLATFORM: SHARED — main-entry COMMON seed. Library .data bake stays
 * on pipe_modlet_bake_scalar_imm_to_data.
 */
function pipe_modlet_seed_imm_hi(imm: i32, name: *u8, name_len: i32): i32 {
  let mod: *u8 = (0 as *u8);
  let arena: *u8 = (0 as *u8);
  let nlets: i32 = 0;
  let tl: i32 = 0;
  if (imm >= 0) {
    return 0;
  }
  if (name == (0 as *u8) || name_len <= 0 || name_len > 255) {
    return 0;
  }
  unsafe { mod = pipeline_asm_emit_module_ref_c(); }
  unsafe { arena = pipeline_asm_emit_ctx_arena_get(); }
  if (mod == (0 as *u8) || arena == (0 as *u8)) {
    return 0;
  }
  unsafe { nlets = pipe_mod_get_num_top_level_lets(mod); }
  tl = 0;
  while (tl < nlets) {
    let nlen: i32 = 0;
    unsafe { nlen = pipeline_module_top_level_let_name_len(mod, tl); }
    if (nlen == name_len) {
      let same: i32 = 1;
      let k: i32 = 0;
      while (k < nlen) {
        let b: i32 = 0;
        unsafe { b = pipeline_module_top_level_let_name_byte_at(mod, tl, k); }
        if (b != (name[k] as i32)) {
          same = 0;
          break;
        }
        k = k + 1;
      }
      if (same != 0) {
        let tr: i32 = 0;
        let tk: i32 = 0;
        unsafe { tr = pipeline_module_top_level_let_type_ref(mod, tl); }
        if (tr <= 0) {
          return 0;
        }
        unsafe { tk = pipeline_type_kind_ord_at(arena, tr); }
        // u8=2, u32=3, u64=4, usize=6. Bit 31 stays in the low word.
        if (tk == 2 || tk == 3 || tk == 4 || tk == 6) {
          return 0;
        }
        // i32=0, i64=5, isize=7.
        if (tk == 0 || tk == 5 || tk == 7) {
          return 0 - 1;
        }
        // TYPE_NAMED=8. Only Cap residual i8/i16 sign-extend.
        // u16 and every other spelling stay zero-extended.
        if (tk == 8) {
          let nm: u8[8] = [];
          let nl: i32 = 0;
          unsafe { nl = pipeline_type_named_name_into(arena, tr, &(nm[0])); }
          if (nl == 2) {
            if (nm[0] == 105) {
              if (nm[1] == 56) {
                return 0 - 1;
              }
            }
          }
          if (nl == 3) {
            if (nm[0] == 105) {
              if (nm[1] == 49) {
                if (nm[2] == 54) {
                  return 0 - 1;
                }
              }
            }
          }
        }
        return 0;
      }
    }
    tl = tl + 1;
  }
  return 0;
}

/**
 * Seed COMMON cells once on hoist-target entry.
 * Scalar cells: non-zero init_imm. A signed negative word is
 * sign-extended by pipe_modlet_seed_imm_hi so `let g: i32 = -7`
 * compares equal to -7. Unsigned words, including u32 all-ones,
 * stay zero-extended.
 * TYPE_ARRAY ARRAY_LIT cells: prepare emits zero BSS; write LIT elems
 * into COMMON so dest-SLICE / INDEX LEA sees the source payload.
 * Empty `u8[N]=[]` stays zero.
 * @param elf_ctx *u8 — ElfCodegenCtx; null returns 0
 * @param ta i32 — 0 x86_64, 1 arm64; other values return 0
 * @return i32 — 0 ok; -1 mov/store fail
 * Library TUs (main_func_index < 0) do not seed here.
 * PLATFORM: SHARED freestanding · MACOS|ARM64 table base.
 */
export extern function pipe_modlet_fold_f64_elem_bits(
  arena: *u8, eref: i32, out_lo: *i32, out_hi: *i32
): i32;
#[no_mangle]
export function pipeline_asm_modlet_seed_nonzero_inits_elf_c(elf_ctx: *u8, ta: i32): i32 {
  // Every extern call in this body is inside this unsafe.
  // PLATFORM: SHARED.
  unsafe {
  if (elf_ctx == 0 as *u8 || (ta != 0 && ta != 1)) {
    return 0;
  }
  let mod0: *u8 = (0 as *u8);
  unsafe { mod0 = pipeline_asm_emit_module_ref_c(); }
  if (mod0 != (0 as *u8)) {
    let mi: i32 = 0;
    unsafe { mi = pipeline_module_main_func_index(mod0); }
    if (mi < 0) {
      return 0;
    }
  }
  let tab: *u8 = (0 as *u8);
  unsafe { tab = pipe_modlet_table_base(); }
  if (tab == (0 as *u8)) {
    return 0 - 1;
  }
  let n: i32 = pipe_modlet_get_n();
  let i: i32 = 0;
  // 10.53: arena early for f64 re-fold (table may only hold 32-bit lo).
  let arena_seed: *u8 = (0 as *u8);
  unsafe { arena_seed = pipeline_asm_emit_ctx_arena_get(); }
  while (i < n) {
    let imm: i32 = 0;
    let hi: i32 = 0;
    let nlen: i32 = 0;
    let nbase: i32 = 0;
    let used_f64: i32 = 0;
    unsafe { imm = pipe_load_i32_le(tab, pipe_modlet_off_init_imm(i)); }
    unsafe { nlen = pipe_load_i32_le(tab, pipe_modlet_off_name_len(i)); }
    nbase = pipe_modlet_off_name(i);
    // Re-fold module f64 lets from AST when present (lo may be 0, e.g. 1.0).
    if (arena_seed != (0 as *u8) && mod0 != (0 as *u8) && nlen > 0 && nlen <= 255) {
      let nlets: i32 = 0;
      let tl: i32 = 0;
      unsafe { nlets = pipe_mod_get_num_top_level_lets(mod0); }
      while (tl < nlets) {
        let tlen: i32 = 0;
        unsafe { tlen = pipeline_module_top_level_let_name_len(mod0, tl); }
        if (tlen == nlen) {
          let same: i32 = 1;
          let k: i32 = 0;
          while (k < nlen) {
            let b: i32 = 0;
            let cb: i32 = 0;
            unsafe {
              b = pipeline_module_top_level_let_name_byte_at(mod0, tl, k);
              cb = (tab[nbase + k] as i32);
            }
            if (b != cb) { same = 0; break; }
            k = k + 1;
          }
          if (same != 0) {
            let tr: i32 = 0;
            let ir: i32 = 0;
            let tk: i32 = 0;
            let flo: i32 = 0;
            let fhi: i32 = 0;
            let fb: i32 = 0;
            unsafe {
              tr = pipeline_module_top_level_let_type_ref(mod0, tl);
              ir = pipeline_module_top_level_let_init_ref(mod0, tl);
            }
            if (tr > 0) {
              unsafe { tk = pipeline_type_kind_ord_at(arena_seed, tr); }
            }
            if (tk == 15 && ir > 0) {
              unsafe { fb = pipe_modlet_fold_f64_elem_bits(arena_seed, ir, &flo, &fhi); }
              if (fb != 0) {
                imm = flo;
                hi = fhi;
                used_f64 = 1;
              }
            }
            break;
          }
        }
        tl = tl + 1;
      }
    }
    if (used_f64 == 0) {
      // Signed negatives need hi=-1. Unsigned bit 31 stays hi=0.
      if (imm != 0) {
        hi = pipe_modlet_seed_imm_hi(imm, seed_tab_at(tab, nbase), nlen);
      }
    }
    if (imm != 0 || hi != 0) {
      let rc: i32 = 0;
      unsafe {
        rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, imm, hi, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      if (pipeline_asm_modlet_store_from_rax_elf_c(elf_ctx, seed_tab_at(tab, nbase), nlen, ta) != 0) {
        return 0 - 1;
      }
    }
    i = i + 1;
  }
  // Module TYPE_ARRAY ARRAY_LIT (const + mutable) → COMMON is BSS zero
  // until we store elems here (hoist skips all TYPE_ARRAY). dest-SLICE
  // wrap / INDEX LEAs the cell; without this seed A[0] reads 0.
  // PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
  let arena: *u8 = (0 as *u8);
  unsafe { arena = pipeline_asm_emit_ctx_arena_get(); }
  let mod: *u8 = (0 as *u8);
  unsafe { mod = pipeline_asm_emit_module_ref_c(); }
  if (arena != (0 as *u8) && mod != (0 as *u8)) {
    let nlets: i32 = 0;
    unsafe { nlets = pipe_mod_get_num_top_level_lets(mod); }
    let nexprs: i32 = 0;
    unsafe { nexprs = pipe_load_i32_le(arena, pipe_arena_off_num_exprs()); }
    let tl: i32 = 0;
    while (tl < nlets) {
      let nlen: i32 = 0;
      let init_ref: i32 = 0;
      let type_ref: i32 = 0;
      let ik: i32 = 0;
      let tk: i32 = 0;
      let idx: i32 = 0;
      let csz: i32 = 0;
      let et: i32 = 0;
      let rc2: i32 = 0;
      let name_buf: u8[256] = [];
      let k: i32 = 0;
      unsafe {
        nlen = pipeline_module_top_level_let_name_len(mod, tl);
      }
      if (nlen > 0 && nlen <= 255) {
        k = 0;
        while (k < nlen) {
          unsafe {
            name_buf[k] = pipeline_module_top_level_let_name_byte_at(mod, tl, k) as u8;
          }
          k = k + 1;
        }
        idx = pipeline_asm_modlet_find(&name_buf[0], nlen);
        if (idx >= 0) {
          unsafe { csz = pipe_load_i32_le(tab, pipe_modlet_off_cell_size(idx)); }
          // Skip .data-backed cells: bytes already baked at prepare.
          // PLATFORM: SHARED — library-TU .data knife.
          if (pipe_modlet_cell_is_array(csz) != 0 && pipe_modlet_cell_is_data(csz) == 0) {
            unsafe {
              init_ref = pipeline_module_top_level_let_init_ref(mod, tl);
              type_ref = pipeline_module_top_level_let_type_ref(mod, tl);
            }
            if (init_ref > 0 && init_ref <= nexprs && type_ref > 0) {
              unsafe {
                ik = pipeline_expr_kind_ord_at(arena, init_ref);
                tk = pipeline_type_kind_ord_at(arena, type_ref);
              }
              if (ik == 46 && tk == 10) {
                unsafe {
                  et = pipeline_type_elem_ref_at(arena, type_ref);
                }
                if (pipeline_asm_modlet_lea_rbx_arch(elf_ctx, idx, ta) == 0) {
                  rc2 = pipe_modlet_seed_array_lit_elems_to_rbx(
                    arena, elf_ctx, init_ref, et, ta, 0, mod);
                  if (rc2 != 0) {
                    return rc2;
                  }
                }
              }
            }
          }
        }
      }
      tl = tl + 1;
    }
  }
  return 0;
  }
}
