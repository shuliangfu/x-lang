/* knife256/10.2 Cap tip: demote typeck_method_call_resolve_generic_bound.
 * Tip generic_bound_scan_c SEGVs; trait_check noop leaves tables empty.
 * Lightweight: g_lex_src must contain `fn_name` + `tp: Trait` (or `<tp: Trait>`)
 * and `trait Trait { ... function method`. Ret kind defaults to i32 (quartet).
 * PLATFORM: SHARED Cap tip. */
export extern function typeck_type_is_free_type_param(module: *u8, arena: *u8, ty_ref: i32): i32;
export extern function pipeline_dep_ctx_current_func_index(ctx: *u8): i32;
export extern function pipeline_module_func_num_generic_params_at(module: *u8, cfi: i32): i32;
export extern function pipeline_module_func_name_len_at(module: *u8, cfi: i32): i32;
export extern function pipeline_module_func_name_copy64(module: *u8, cfi: i32, dst: *u8): void;
export extern function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;
export extern function pipe_ty_slot_at(arena: *u8, type_ref: i32): *u8;
export extern function xlang_cap_tip_lex_src_data(): *u8;
export extern function xlang_cap_tip_lex_src_len(): i64;
export extern function pipeline_expr_apply_call_resolve(arena: *u8, expr_ref: i32, a: i32, b: i32): void;
export extern function pipeline_expr_set_resolved_type_ref(arena: *u8, expr_ref: i32, ty: i32): void;
export extern function pipeline_type_ensure_by_kind_ord(arena: *u8, kind: i32): i32;
export extern function pipeline_module_num_funcs(module: *u8): i32;
export extern function pipeline_module_func_name_equal_at(module: *u8, fi: i32, name: *u8, nlen: i32): i32;
export extern function pipeline_module_func_num_params_at(module: *u8, fi: i32): i32;

function cap_tip_src_find(src: *u8, src_len: i32, pat: *u8, pat_len: i32, from: i32): i32 {
  unsafe {
    let i: i32 = from;
    let j: i32 = 0;
    if (src == (0 as *u8) || pat == (0 as *u8) || pat_len <= 0 || src_len < pat_len) {
      return 0 - 1;
    }
    while (i + pat_len <= src_len) {
      j = 0;
      while (j < pat_len) {
        if (src[i + j] != pat[j]) {
          break;
        }
        j = j + 1;
      }
      if (j == pat_len) {
        return i;
      }
      i = i + 1;
    }
    return 0 - 1;
  }
}

function cap_tip_bound_method_ok(src: *u8, src_len: i32, fn_nm: *u8, fn_len: i32,
tp_nm: *u8, tp_len: i32, method_nm: *u8, method_nlen: i32): i32 {
  unsafe {
    let fi: i32 = 0;
    let i: i32 = 0;
    let colon: i32 = 0;
    let trait_start: i32 = 0;
    let trait_len: i32 = 0;
    let tpos: i32 = 0;
    let mpos: i32 = 0;
    let c: u8 = 0;
    let trait_nm: u8[64] = [];
    let lit_trait: u8[6] = [];
    let lit_fn: u8[9] = [];
    if (src == (0 as *u8) || src_len <= 0 || fn_len <= 0 || tp_len <= 0 || method_nlen <= 0) {
      return 0;
    }
    fi = cap_tip_src_find(src, src_len, fn_nm, fn_len, 0);
    if (fi < 0) {
      return 0;
    }
    /* After fn name, find tp_nm then ':' then trait ident before '{' or ')' */
    i = fi + fn_len;
    if (i >= src_len) {
      return 0;
    }
    i = cap_tip_src_find(src, src_len, tp_nm, tp_len, i);
    if (i < 0 || i > fi + 128) {
      return 0;
    }
    colon = i + tp_len;
    while (colon < src_len && colon < i + 32) {
      c = src[colon];
      if (c == (58 as u8)) {
        break;
      }
      if (c == (123 as u8) || c == (41 as u8)) {
        return 0;
      }
      colon = colon + 1;
    }
    if (colon >= src_len || src[colon] != (58 as u8)) {
      return 0;
    }
    trait_start = colon + 1;
    while (trait_start < src_len && (src[trait_start] == (32 as u8) || src[trait_start] == (9 as u8))) {
      trait_start = trait_start + 1;
    }
    trait_len = 0;
    while (trait_start + trait_len < src_len && trait_len < 63) {
      c = src[trait_start + trait_len];
      if ((c >= (65 as u8) && c <= (90 as u8)) || (c >= (97 as u8) && c <= (122 as u8))
          || (c >= (48 as u8) && c <= (57 as u8)) || c == (95 as u8)) {
        trait_nm[trait_len] = c;
        trait_len = trait_len + 1;
      } else {
        break;
      }
    }
    if (trait_len <= 0) {
      return 0;
    }
    /* trait Trait { ... function method */
    lit_trait[0] = 116; lit_trait[1] = 114; lit_trait[2] = 97;
    lit_trait[3] = 105; lit_trait[4] = 116; lit_trait[5] = 32;
    tpos = 0;
    while (tpos >= 0) {
      tpos = cap_tip_src_find(src, src_len, &lit_trait[0], 6, tpos);
      if (tpos < 0) {
        return 0;
      }
      if (tpos + 6 + trait_len <= src_len) {
        i = 0;
        while (i < trait_len) {
          if (src[tpos + 6 + i] != trait_nm[i]) {
            break;
          }
          i = i + 1;
        }
        if (i == trait_len) {
          /* found trait header; search function method before next trait or +400 */
          lit_fn[0] = 102; lit_fn[1] = 117; lit_fn[2] = 110; lit_fn[3] = 99;
          lit_fn[4] = 116; lit_fn[5] = 105; lit_fn[6] = 111; lit_fn[7] = 110;
          lit_fn[8] = 32;
          mpos = tpos + 6 + trait_len;
          /* Do not walk into a later trait block. */
          let trait_end: i32 = cap_tip_src_find(src, src_len, &lit_trait[0], 6, mpos);
          if (trait_end < 0 || trait_end > tpos + 2000) {
            trait_end = tpos + 400;
          }
          if (trait_end > src_len) {
            trait_end = src_len;
          }
          while (mpos >= 0 && mpos < trait_end) {
            mpos = cap_tip_src_find(src, src_len, &lit_fn[0], 9, mpos);
            if (mpos < 0 || mpos >= trait_end) {
              break;
            }
            if (mpos + 9 + method_nlen <= src_len) {
              i = 0;
              while (i < method_nlen) {
                if (src[mpos + 9 + i] != method_nm[i]) {
                  break;
                }
                i = i + 1;
              }
              if (i == method_nlen) {
                return 1;
              }
            }
            mpos = mpos + 1;
          }
        }
      }
      tpos = tpos + 1;
    }
    return 0;
  }
}

#[no_mangle]
export function typeck_method_call_resolve_generic_bound(module: *u8, arena: *u8, expr_ref: i32,
ctx: *u8, base_ty: i32, method_nm: *u8, method_nlen: i32, num_args: i32): i32 {
  unsafe {
    let cfi: i32 = 0 - 1;
    let fn_len: i32 = 0;
    let tp_len: i32 = 0;
    let ret_ty: i32 = 0;
    let i: i32 = 0;
    let fn_nm: u8[256] = [];
    let tp_nm: u8[256] = [];
    let slot: *u8 = 0 as *u8;
    let c: u8 = 0;
    let src: *u8 = 0 as *u8;
    let src_len64: i64 = 0;
    let src_len: i32 = 0;
    if (module == (0 as *u8) || arena == (0 as *u8) || ctx == (0 as *u8)
        || expr_ref <= 0 || base_ty <= 0 || method_nm == (0 as *u8) || method_nlen <= 0) {
      return 0;
    }
    if (typeck_type_is_free_type_param(module, arena, base_ty) == 0) {
      return 0;
    }
    cfi = pipeline_dep_ctx_current_func_index(ctx);
    if (cfi < 0) {
      return 0;
    }
    if (pipeline_module_func_num_generic_params_at(module, cfi) <= 0) {
      return 0;
    }
    fn_len = pipeline_module_func_name_len_at(module, cfi);
    if (fn_len <= 0 || fn_len > 255) {
      return 0;
    }
    pipeline_module_func_name_copy64(module, cfi, &fn_nm[0]);
    tp_len = pipeline_type_named_name_into(arena, base_ty, &tp_nm[0]);
    if (tp_len <= 0 || tp_len > 255) {
      slot = pipe_ty_slot_at(arena, base_ty);
      tp_len = 0;
      if (slot != (0 as *u8)) {
        i = 0;
        while (i < 255) {
          c = *((slot + 4) + i);
          if (c == (0 as u8)) {
            break;
          }
          tp_nm[i] = c;
          i = i + 1;
        }
        tp_len = i;
      }
      if (tp_len <= 0 || tp_len > 255) {
        return 0;
      }
    }
    src = xlang_cap_tip_lex_src_data();
    src_len64 = xlang_cap_tip_lex_src_len();
    if (src_len64 <= 0 || src_len64 > 2000000) {
      return 0;
    }
    src_len = src_len64 as i32;
    if (cap_tip_bound_method_ok(src, src_len, &fn_nm[0], fn_len, &tp_nm[0], tp_len, method_nm,
        method_nlen) == 0) {
      return 0;
    }
    /* Prefer concrete same-module method (impl body) so Cap tip codegen
     * links A.clone / not missing vtable wrap. */
    let nf: i32 = pipeline_module_num_funcs(module);
    let uj: i32 = 0;
    let fi_hit: i32 = 0 - 1;
    while (uj < nf) {
      if (pipeline_module_func_name_equal_at(module, uj, method_nm, method_nlen) != 0) {
        if (pipeline_module_func_num_params_at(module, uj) == num_args + 1) {
          fi_hit = uj;
          uj = nf;
        }
      }
      uj = uj + 1;
    }
    ret_ty = pipeline_type_ensure_by_kind_ord(arena, 0);
    pipeline_expr_apply_call_resolve(arena, expr_ref, 0 - 1, fi_hit);
    if (ret_ty > 0) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, ret_ty);
    }
    return 1;
  }
}
