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

// knife256/10.2 product entry of typeck_field_reverse_infer_base_type.
// Cap tip cannot re-emit typeck.x. The linked mega returns 0 when two
// layouts share a field name, so `{ xs: [1.0, 2.0] }.xs` never becomes
// [2]f32 and the call checker emits T001 against []f32. Darwin ld aliases
// that text to typeck_field_reverse_infer_base_type_mega and weakens the
// old name, so this strong definition is the one the BRANCH26 site calls.
// A unique name is returned unchanged. Only a 0 result whose base is a
// struct literal (kind 45) is scanned again: a float literal (kind 1)
// keeps a field whose element kind is f32 or f64; an integer literal
// (kind 0) keeps a field whose element kind is neither. Two survivors,
// or a literal that is not an array of a literal, stay 0.
// PLATFORM: SHARED — the type rule is the same on macOS, Ubuntu, and
// Windows. The alias is the Darwin link step.

export extern "C" function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_field_access_name_len(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_field_access_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_struct_lit_num_fields(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_struct_lit_field_name_len(arena: *u8, expr_ref: i32, j: i32): i32;
export extern "C" function pipeline_expr_struct_lit_field_name_into(arena: *u8, expr_ref: i32, j: i32,
out: *u8): void;
export extern "C" function pipeline_expr_struct_lit_init_ref(arena: *u8, expr_ref: i32, j: i32): i32;
export extern "C" function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern "C" function pipeline_module_num_struct_layouts_at(module: *u8): i32;
export extern "C" function pipeline_module_struct_layout_num_fields(module: *u8, layout_idx: i32): i32;
export extern "C" function pipeline_module_struct_layout_field_name_len(module: *u8, layout_idx: i32,
j: i32): i32;
export extern "C" function pipeline_module_struct_layout_field_name_into(module: *u8, layout_idx: i32,
j: i32, out: *u8): void;
export extern "C" function pipeline_module_struct_layout_field_type_ref(module: *u8, layout_idx: i32,
j: i32): i32;
export extern "C" function pipeline_module_struct_layout_name_len(module: *u8, idx: i32): i32;
export extern "C" function pipeline_module_struct_layout_name_into(module: *u8, idx: i32, out: *u8): void;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern "C" function typeck_find_or_alloc_named_type_ref(arena: *u8, name: *u8, name_len: i32): i32;

/**
 * Return the unique owner struct, or the one layout a struct-literal
 * element kind can still tell apart.
 * @param module *u8 — module with struct layouts; null returns 0
 * @param arena *u8 — expression and type pool; null returns 0
 * @param expr_ref i32 — FIELD_ACCESS; <= 0 returns 0
 * @param outer_expected i32 — ambient field-result type; not read
 * @return i32 — TYPE_NAMED of the owner, or 0 when still ambiguous
 * The mega result is kept whenever it is positive. Kind 45 is the only
 * base that is scanned again. Kind 46 is the only initializer that
 * supplies an element. Kind 1 wants type kind 14 or 15. Kind 0 wants any
 * other element kind. Name buffers are 256 bytes because the into-helpers
 * clear that many. One function, no helper, no chained &&.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_field_reverse_infer_base_type(module: *u8, arena: *u8,
expr_ref: i32, outer_expected: i32): i32 {
  // PLATFORM: SHARED — unique-name path stays on the mega; this adds the literal filter.
  unsafe {
    let ord_struct_lit: i32 = 45;
    let ord_array_lit: i32 = 46;
    let ord_int_lit: i32 = 0;
    let ord_float_lit: i32 = 1;
    let ord_array: i32 = 10;
    let ord_f32: i32 = 14;
    let ord_f64: i32 = 15;
    let base_er: i32 = 0;
    let base_k: i32 = 0;
    let fl: i32 = 0;
    let nf_lit: i32 = 0;
    let j: i32 = 0;
    let fjl: i32 = 0;
    let bi: i32 = 0;
    let match_f: i32 = 0;
    let init_ref: i32 = 0;
    let elem0: i32 = 0;
    let elem_k: i32 = 0;
    let want_flt: i32 = -1;
    let nsl: i32 = 0;
    let k: i32 = 0;
    let nf: i32 = 0;
    let ftr: i32 = 0;
    let fk: i32 = 0;
    let et: i32 = 0;
    let ekind: i32 = 0;
    let keep: i32 = 0;
    let hits: i32 = 0;
    let unique_ty: i32 = 0;
    let lnl: i32 = 0;
    let nty: i32 = 0;
    let fn_buf: u8[256] = [];
    let fjn: u8[256] = [];
    let lnm: u8[256] = [];
    /* Self-contained: unique owner first (was mega). No redefine-sym dance. */
    if (module == 0 as *u8) {
      return 0;
    }
    if (arena == 0 as *u8) {
      return 0;
    }
    if (expr_ref <= 0) {
      return 0;
    }
    fl = pipeline_expr_field_access_name_len(arena, expr_ref);
    if (fl <= 0) {
      return 0;
    }
    if (fl > 255) {
      return 0;
    }
    pipeline_expr_field_access_name_into(arena, expr_ref, &fn_buf[0]);
    nsl = pipeline_module_num_struct_layouts_at(module);
    hits = 0;
    unique_ty = 0;
    k = 0;
    while (k < nsl) {
      nf = pipeline_module_struct_layout_num_fields(module, k);
      j = 0;
      while (j < nf) {
        fjl = pipeline_module_struct_layout_field_name_len(module, k, j);
        if (fjl == fl) {
          pipeline_module_struct_layout_field_name_into(module, k, j, &fjn[0]);
          match_f = 1;
          bi = 0;
          while (bi < fl) {
            if (fjn[bi] != fn_buf[bi]) {
              match_f = 0;
            }
            bi = bi + 1;
          }
          if (match_f != 0) {
            lnl = pipeline_module_struct_layout_name_len(module, k);
            if (lnl > 0) {
              if (lnl <= 255) {
                pipeline_module_struct_layout_name_into(module, k, &lnm[0]);
                nty = typeck_find_or_alloc_named_type_ref(arena, &lnm[0], lnl);
                if (nty > 0) {
                  if (!(hits == 1 && unique_ty == nty)) {
                    hits = hits + 1;
                    unique_ty = nty;
                    if (hits > 1) {
                      /* ambiguous — fall through to STRUCT_LIT elem filter */
                      hits = 0;
                      unique_ty = 0;
                      k = nsl;
                      j = nf;
                    }
                  }
                }
              }
            }
          }
        }
        j = j + 1;
      }
      k = k + 1;
    }
    if (hits == 1) {
      return unique_ty;
    }
    base_er = pipeline_expr_field_access_base_ref(arena, expr_ref);
    if (base_er <= 0) {
      return 0;
    }
    base_k = pipeline_expr_kind_ord_at(arena, base_er);
    if (base_k != ord_struct_lit) {
      return 0;
    }
    fl = pipeline_expr_field_access_name_len(arena, expr_ref);
    if (fl <= 0) {
      return 0;
    }
    if (fl > 255) {
      return 0;
    }
    pipeline_expr_field_access_name_into(arena, expr_ref, &fn_buf[0]);
    /* The literal's own field, not the first field. Name compare is bytes. */
    nf_lit = pipeline_expr_struct_lit_num_fields(arena, base_er);
    init_ref = 0;
    j = 0;
    while (j < nf_lit) {
      fjl = pipeline_expr_struct_lit_field_name_len(arena, base_er, j);
      if (fjl == fl) {
        pipeline_expr_struct_lit_field_name_into(arena, base_er, j, &fjn[0]);
        match_f = 1;
        bi = 0;
        while (bi < fl) {
          if (fjn[bi] != fn_buf[bi]) {
            match_f = 0;
          }
          bi = bi + 1;
        }
        if (match_f != 0) {
          init_ref = pipeline_expr_struct_lit_init_ref(arena, base_er, j);
          j = nf_lit;
        }
      }
      j = j + 1;
    }
    if (init_ref <= 0) {
      return 0;
    }
    if (pipeline_expr_kind_ord_at(arena, init_ref) != ord_array_lit) {
      return 0;
    }
    if (pipeline_expr_array_lit_num_elems_at(arena, init_ref) <= 0) {
      return 0;
    }
    elem0 = pipeline_expr_array_lit_elem_ref(arena, init_ref, 0);
    if (elem0 <= 0) {
      return 0;
    }
    elem_k = pipeline_expr_kind_ord_at(arena, elem0);
    want_flt = -1;
    if (elem_k == ord_float_lit) {
      want_flt = 1;
    }
    if (elem_k == ord_int_lit) {
      want_flt = 0;
    }
    if (want_flt < 0) {
      return 0;
    }
    nsl = pipeline_module_num_struct_layouts_at(module);
    hits = 0;
    unique_ty = 0;
    k = 0;
    while (k < nsl) {
      nf = pipeline_module_struct_layout_num_fields(module, k);
      j = 0;
      while (j < nf) {
        fjl = pipeline_module_struct_layout_field_name_len(module, k, j);
        if (fjl == fl) {
          pipeline_module_struct_layout_field_name_into(module, k, j, &fjn[0]);
          match_f = 1;
          bi = 0;
          while (bi < fl) {
            if (fjn[bi] != fn_buf[bi]) {
              match_f = 0;
            }
            bi = bi + 1;
          }
          if (match_f != 0) {
            /*
             * TYPE_ARRAY (10) stores the element one step in. A bare f32
             * field uses its own kind. Float lits keep 14/15 only.
             */
            ftr = pipeline_module_struct_layout_field_type_ref(module, k, j);
            ekind = -1;
            if (ftr > 0) {
              fk = pipeline_type_kind_ord_at(arena, ftr);
              if (fk == ord_array) {
                et = pipeline_type_elem_ref_at(arena, ftr);
                if (et > 0) {
                  ekind = pipeline_type_kind_ord_at(arena, et);
                }
              } else {
                ekind = fk;
              }
            }
            keep = 0;
            if (want_flt == 1) {
              if (ekind == ord_f32) {
                keep = 1;
              }
              if (ekind == ord_f64) {
                keep = 1;
              }
            }
            if (want_flt == 0) {
              if (ekind >= 0) {
                if (ekind != ord_f32) {
                  if (ekind != ord_f64) {
                    keep = 1;
                  }
                }
              }
            }
            if (keep != 0) {
              lnl = pipeline_module_struct_layout_name_len(module, k);
              if (lnl > 0) {
                if (lnl <= 255) {
                  pipeline_module_struct_layout_name_into(module, k, &lnm[0]);
                  nty = typeck_find_or_alloc_named_type_ref(arena, &lnm[0], lnl);
                  if (nty > 0) {
                    if (!(hits == 1 && unique_ty == nty)) {
                      hits = hits + 1;
                      unique_ty = nty;
                      if (hits > 1) {
                        return 0;
                      }
                    }
                  }
                }
              }
            }
          }
        }
        j = j + 1;
      }
      k = k + 1;
    }
    if (hits == 1) {
      return unique_ty;
    }
    return 0;
  }
}
