// Explicit turbofish `copy<A>(a)` used to return before trait bounds.
// `function copy<T: Clone + Default>` therefore accepted A that only
// impls Clone. This entry keeps the arity check, then reads the
// function header in the current source. Each trait after ':' or '+'
// must appear as `impl Trait for A`. A type-arg spelling that is the
// type parameter itself is not a concrete violation.
// PLATFORM: SHARED. The mega is the Darwin typeck object.

export extern "C" function pipeline_typeck_check_call_generic_type_args_c_mega(module: *u8, arena: *u8, expr_ref: i32, ctx: *u8, expected_ret: i32): i32;
export extern "C" function pipeline_expr_call_resolved_func_index_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_module_func_num_generic_params_at(module: *u8, fi: i32): i32;
export extern "C" function pipeline_expr_call_num_type_args_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_call_type_arg_ref_at(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern "C" function pipeline_module_func_name_len_at(module: *u8, fi: i32): i32;
export extern "C" function pipeline_module_func_name_copy64(module: *u8, fi: i32, dst: *u8): void;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, ty: i32): i32;
export extern "C" function pipeline_type_named_name_into(arena: *u8, ty: i32, out: *u8): i32;
export extern "C" function pipeline_expr_line_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_col_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function xlang_cap_tip_lex_src_data(): *u8;
export extern "C" function xlang_cap_tip_lex_src_len(): i64;
export extern "C" function xlang_generic_bound_diag_not_impl_c(ta: *u8, ta_len: i32, trait_nm: *u8, trait_nlen: i32, line: i32, col: i32): i32;

/**
 * 1 when c continues an identifier.
 * @param c u8 — source byte
 * @return i32 — 1 ident, 0 stop
 * PLATFORM: SHARED.
 */
function cgb_is_ident(c: u8): i32 {
  if (c >= (65 as u8) && c <= (90 as u8)) {
    return 1;
  }
  if (c >= (97 as u8) && c <= (122 as u8)) {
    return 1;
  }
  if (c >= (48 as u8) && c <= (57 as u8)) {
    return 1;
  }
  if (c == (95 as u8)) {
    return 1;
  }
  return 0;
}

/**
 * Index of pat at or after from, or -1.
 * @param src *u8 — file bytes
 * @param src_len i32 — byte count
 * @param pat *u8 — needle
 * @param pat_len i32 — needle length
 * @param from i32 — start
 * @return i32 — hit, or -1
 * PLATFORM: SHARED.
 */
function cgb_find(src: *u8, src_len: i32, pat: *u8, pat_len: i32, from: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  if (src == 0 as *u8 || pat == 0 as *u8 || pat_len <= 0) {
    return 0 - 1;
  }
  i = from;
  if (i < 0) {
    i = 0;
  }
  while (i + pat_len <= src_len) {
    j = 0;
    while (j < pat_len) {
      if (src[i + j] != pat[j]) {
        j = pat_len + 1;
      } else {
        j = j + 1;
      }
    }
    if (j == pat_len) {
      return i;
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Read an ident at p. Returns length, or 0.
 * @param src *u8 — file bytes
 * @param src_len i32 — byte count
 * @param p i32 — start
 * @param dst *u8 — dest, capacity >= 64
 * @return i32 — length
 * PLATFORM: SHARED.
 */
function cgb_ident(src: *u8, src_len: i32, p: i32, dst: *u8): i32 {
  let n: i32 = 0;
  if (p < 0 || p >= src_len) {
    return 0;
  }
  if (cgb_is_ident(src[p]) == 0) {
    return 0;
  }
  while (p + n < src_len && n < 63 && cgb_is_ident(src[p + n]) != 0) {
    dst[n] = src[p + n];
    n = n + 1;
  }
  return n;
}

/**
 * 1 when the file has `impl Trait for Name` as whole idents.
 * @param src *u8 — file bytes
 * @param src_len i32 — byte count
 * @param trait_nm *u8 — trait spelling
 * @param trait_len i32 — trait length
 * @param arg_nm *u8 — concrete type spelling
 * @param arg_len i32 — type length
 * @return i32 — 1 found, 0 missing
 * PLATFORM: SHARED.
 */
function cgb_impl_for(src: *u8, src_len: i32, trait_nm: *u8, trait_len: i32, arg_nm: *u8, arg_len: i32): i32 {
  let lit: u8[5] = [];
  let from: i32 = 0;
  let at: i32 = 0;
  let p: i32 = 0;
  let k: i32 = 0;
  let ok: i32 = 0;
  lit[0] = 105;
  lit[1] = 109;
  lit[2] = 112;
  lit[3] = 108;
  lit[4] = 32;
  from = 0;
  while (from >= 0) {
    at = cgb_find(src, src_len, &lit[0], 5, from);
    if (at < 0) {
      return 0;
    }
    p = at + 5;
    while (p < src_len && (src[p] == (32 as u8) || src[p] == (9 as u8) || src[p] == (10 as u8) || src[p] == (13 as u8))) {
      p = p + 1;
    }
    ok = 0;
    if (p + trait_len <= src_len) {
      k = 0;
      while (k < trait_len) {
        if (src[p + k] != trait_nm[k]) {
          k = trait_len + 1;
        } else {
          k = k + 1;
        }
      }
      if (k == trait_len && (p + trait_len >= src_len || cgb_is_ident(src[p + trait_len]) == 0)) {
        ok = 1;
      }
    }
    if (ok != 0) {
      p = p + trait_len;
      while (p < src_len && (src[p] == (32 as u8) || src[p] == (9 as u8) || src[p] == (10 as u8) || src[p] == (13 as u8))) {
        p = p + 1;
      }
      if (p + 3 < src_len && src[p] == (102 as u8) && src[p + 1] == (111 as u8) && src[p + 2] == (114 as u8) && (src[p + 3] == (32 as u8) || src[p + 3] == (9 as u8))) {
        p = p + 4;
        while (p < src_len && (src[p] == (32 as u8) || src[p] == (9 as u8) || src[p] == (10 as u8) || src[p] == (13 as u8))) {
          p = p + 1;
        }
        k = 0;
        if (p + arg_len <= src_len) {
          while (k < arg_len) {
            if (src[p + k] != arg_nm[k]) {
              k = arg_len + 1;
            } else {
              k = k + 1;
            }
          }
          if (k == arg_len && (p + arg_len >= src_len || cgb_is_ident(src[p + arg_len]) == 0)) {
            return 1;
          }
        }
      }
    }
    from = at + 5;
  }
  return 0;
}

/**
 * Check one concrete type arg against the function header's bounds.
 * @param src *u8 — file bytes
 * @param src_len i32 — byte count
 * @param lt i32 — index of the header '<'
 * @param arg_nm *u8 — concrete type spelling
 * @param arg_len i32 — spelling length
 * @param arg_pos i32 — type-arg slot
 * @param line i32 — diagnostic line
 * @param col i32 — diagnostic column
 * @return i32 — 1 ok, 0 a trait is missing
 * A trait is required only for this slot. The type-parameter name
 * itself is not a missing impl. PLATFORM: SHARED.
 */
function cgb_check_angle(src: *u8, src_len: i32, lt: i32, arg_nm: *u8, arg_len: i32, arg_pos: i32, line: i32, col: i32): i32 {
  let p: i32 = 0;
  let depth: i32 = 0;
  let pos: i32 = 0;
  let expect: i32 = 0;
  let tl: i32 = 0;
  let tp_len: i32 = 0;
  let same: i32 = 0;
  let k: i32 = 0;
  let c: u8 = 0;
  let trait_nm: u8[64] = [];
  let tp_nm: u8[64] = [];
  p = lt + 1;
  depth = 1;
  pos = 0;
  expect = 0;
  tp_len = 0;
  while (p < src_len && depth > 0) {
    c = src[p];
    if (c == (60 as u8)) {
      depth = depth + 1;
      p = p + 1;
    } else {
      if (c == (62 as u8)) {
        depth = depth - 1;
        p = p + 1;
      } else {
        if (depth != 1) {
          p = p + 1;
        } else {
          if (c == (44 as u8)) {
            pos = pos + 1;
            expect = 0;
            p = p + 1;
          } else {
            if (c == (58 as u8) || c == (43 as u8)) {
              expect = 1;
              p = p + 1;
            } else {
              if (cgb_is_ident(c) != 0) {
                if (expect != 0) {
                  tl = cgb_ident(src, src_len, p, &trait_nm[0]);
                  if (tl > 0 && pos == arg_pos) {
                    same = 0;
                    if (tp_len == arg_len) {
                      same = 1;
                      k = 0;
                      while (k < arg_len) {
                        if (tp_nm[k] != arg_nm[k]) {
                          same = 0;
                        }
                        k = k + 1;
                      }
                    }
                    if (same == 0) {
                      if (cgb_impl_for(src, src_len, &trait_nm[0], tl, arg_nm, arg_len) == 0) {
                        unsafe {
                          xlang_generic_bound_diag_not_impl_c(arg_nm, arg_len, &trait_nm[0], tl, line, col);
                        }
                        return 0;
                      }
                    }
                  }
                  if (tl > 0) {
                    p = p + tl;
                  } else {
                    p = p + 1;
                  }
                  expect = 0;
                } else {
                  tl = cgb_ident(src, src_len, p, &tp_nm[0]);
                  if (pos == arg_pos && tl > 0) {
                    tp_len = tl;
                  }
                  if (tl > 0) {
                    p = p + tl;
                  } else {
                    p = p + 1;
                  }
                }
              } else {
                p = p + 1;
              }
            }
          }
        }
      }
    }
  }
  return 1;
}

/**
 * 1 when this name occurrence is a bounded generic header.
 * @param src *u8 — file bytes
 * @param src_len i32 — byte count
 * @param at i32 — index of the name
 * @param nlen i32 — name length
 * @return i32 — index of '<', or -1
 * The '<' must contain a ':' so a call `copy<A>` is not a header.
 * PLATFORM: SHARED.
 */
function cgb_header_lt(src: *u8, src_len: i32, at: i32, nlen: i32): i32 {
  let p: i32 = 0;
  let depth: i32 = 0;
  let saw: i32 = 0;
  if (at > 0 && cgb_is_ident(src[at - 1]) != 0) {
    return 0 - 1;
  }
  if (at + nlen < src_len && cgb_is_ident(src[at + nlen]) != 0) {
    return 0 - 1;
  }
  p = at + nlen;
  while (p < src_len && (src[p] == (32 as u8) || src[p] == (9 as u8) || src[p] == (10 as u8) || src[p] == (13 as u8))) {
    p = p + 1;
  }
  if (p >= src_len || src[p] != (60 as u8)) {
    return 0 - 1;
  }
  depth = 1;
  saw = 0;
  p = p + 1;
  while (p < src_len && depth > 0) {
    if (src[p] == (60 as u8)) {
      depth = depth + 1;
    } else {
      if (src[p] == (62 as u8)) {
        depth = depth - 1;
      } else {
        if (depth == 1 && src[p] == (58 as u8)) {
          saw = 1;
        }
      }
    }
    p = p + 1;
  }
  if (saw == 0) {
    return 0 - 1;
  }
  p = at + nlen;
  while (p < src_len && (src[p] == (32 as u8) || src[p] == (9 as u8) || src[p] == (10 as u8) || src[p] == (13 as u8))) {
    p = p + 1;
  }
  return p;
}

/**
 * Reject a turbofish whose header bounds are not implemented.
 * @param module *u8 — callee module
 * @param arena *u8 — expression pool
 * @param expr_ref i32 — CALL
 * @return i32 — 0 ok, -1 a bound failed
 * No explicit type args is not a failure here. PLATFORM: SHARED.
 */
function cgb_explicit(module: *u8, arena: *u8, expr_ref: i32): i32 {
  unsafe {
    let fi: i32 = 0;
    let ngen: i32 = 0;
    let nargs: i32 = 0;
    let nlen: i32 = 0;
    let ai: i32 = 0;
    let ty: i32 = 0;
    let alen: i32 = 0;
    let src_len64: i64 = 0;
    let src_len: i32 = 0;
    let from: i32 = 0;
    let at: i32 = 0;
    let lt: i32 = 0;
    let line: i32 = 0;
    let col: i32 = 0;
    let src: *u8 = 0 as *u8;
    let name: u8[64] = [];
    let arg_nm: u8[64] = [];
    fi = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
    if (fi < 0) {
      return 0;
    }
    ngen = pipeline_module_func_num_generic_params_at(module, fi);
    nargs = pipeline_expr_call_num_type_args_at(arena, expr_ref);
    if (ngen <= 0 || nargs <= 0 || ngen != nargs) {
      return 0;
    }
    nlen = pipeline_module_func_name_len_at(module, fi);
    if (nlen <= 0 || nlen > 63) {
      return 0;
    }
    pipeline_module_func_name_copy64(module, fi, &name[0]);
    src = xlang_cap_tip_lex_src_data();
    src_len64 = xlang_cap_tip_lex_src_len();
    if (src == 0 as *u8 || src_len64 <= 0 || src_len64 > 2000000) {
      return 0;
    }
    src_len = src_len64 as i32;
    line = pipeline_expr_line_at(arena, expr_ref);
    col = pipeline_expr_col_at(arena, expr_ref);
    from = 0;
    lt = 0 - 1;
    while (from >= 0 && lt < 0) {
      at = cgb_find(src, src_len, &name[0], nlen, from);
      if (at < 0) {
        from = 0 - 1;
      } else {
        lt = cgb_header_lt(src, src_len, at, nlen);
        from = at + nlen;
      }
    }
    if (lt < 0) {
      return 0;
    }
    ai = 0;
    while (ai < nargs) {
      ty = pipeline_expr_call_type_arg_ref_at(arena, expr_ref, ai);
      if (ty > 0 && pipeline_type_kind_ord_at(arena, ty) == 8) {
        alen = pipeline_type_named_name_into(arena, ty, &arg_nm[0]);
        if (alen > 0 && alen <= 63) {
          if (cgb_check_angle(src, src_len, lt, &arg_nm[0], alen, ai, line, col) == 0) {
            return 0 - 1;
          }
        }
      }
      ai = ai + 1;
    }
    return 0;
  }
}

/**
 * Arity gate, then trait bounds on an explicit turbofish.
 * @param module *u8 — caller module
 * @param arena *u8 — expression pool
 * @param expr_ref i32 — CALL
 * @param ctx *u8 — dep context; unused by the bound scan
 * @param expected_ret i32 — ambient return; passed to the arity gate
 * @return i32 — 0 ok, non-zero diagnostic already emitted
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_typeck_check_call_generic_type_args_c(module: *u8, arena: *u8, expr_ref: i32, ctx: *u8, expected_ret: i32): i32 {
  // PLATFORM: SHARED — mega owns arity; this owns explicit bounds.
  unsafe {
    let rc: i32 = 0;
    rc = pipeline_typeck_check_call_generic_type_args_c_mega(module, arena, expr_ref, ctx, expected_ret);
    if (rc != 0) {
      return rc;
    }
    if (module == 0 as *u8 || arena == 0 as *u8) {
      return 0;
    }
    return cgb_explicit(module, arena, expr_ref);
  }
}
