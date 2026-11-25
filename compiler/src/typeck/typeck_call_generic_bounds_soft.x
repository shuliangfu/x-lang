// Explicit turbofish `copy<A>(a)` used to return before trait bounds.
// `function copy<T: Clone + Default>` therefore accepted A that only
// impls Clone. This entry keeps the arity check, then reads the
// function header in the current source. Each trait after ':' or '+'
// must appear as `impl Trait for A`. A type-arg spelling that is the
// type parameter itself is not a concrete violation.
// The same header walk applies to `struct Foo<T: Trait>` at each
// `Foo<Arg>` that is not the struct header.
// PLATFORM: SHARED. The megas are the Darwin typeck object.

export extern "C" function pipeline_typeck_check_call_generic_type_args_c_mega(module: *u8, arena: *u8, expr_ref: i32, ctx: *u8, expected_ret: i32): i32;
export extern "C" function typeck_x_ast_mega(module: *u8, arena: *u8, ctx: *u8): i32;
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
export extern "C" function driver_diagnostic_typeck_assign_mismatch(is_compound: i32, line: i32, col: i32, expect_buf: *u8, expect_len: i32, found_buf: *u8, found_len: i32): void;
export extern "C" function pipeline_module_num_funcs(module: *u8): i32;
export extern "C" function pipeline_module_func_body_ref_at(module: *u8, fi: i32): i32;
export extern "C" function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern "C" function pipeline_block_let_type_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern "C" function ast_ast_block_let_init_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipe_mod_get_num_top_level_lets(module: *u8): i32;
export extern "C" function pipeline_module_top_level_let_init_ref(module: *u8, idx: i32): i32;
export extern "C" function pipeline_module_top_level_let_type_ref(module: *u8, idx: i32): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_set_const_folded(arena: *u8, expr_ref: i32, valid: i32, val: i32): void;

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

/**
 * 1 when the name at `at` is the ident after `struct`.
 * @param src *u8 — file bytes
 * @param at i32 — start of the name
 * @return i32 — 1 struct header, 0 otherwise
 * PLATFORM: SHARED.
 */
function cgb_prev_struct(src: *u8, at: i32): i32 {
  let p: i32 = 0;
  if (src == 0 as *u8 || at <= 0) {
    return 0;
  }
  p = at - 1;
  while (p >= 0) {
    if (src[p] == (32 as u8) || src[p] == (9 as u8) || src[p] == (10 as u8) || src[p] == (13 as u8)) {
      p = p - 1;
    } else {
      p = 0 - 2;
    }
  }
  if (p < -1) {
    p = at - 1;
    while (p >= 0 && (src[p] == (32 as u8) || src[p] == (9 as u8) || src[p] == (10 as u8) || src[p] == (13 as u8))) {
      p = p - 1;
    }
  }
  if (p < 5) {
    return 0;
  }
  if (src[p] != (116 as u8) || src[p - 1] != (99 as u8) || src[p - 2] != (117 as u8) || src[p - 3] != (114 as u8) || src[p - 4] != (116 as u8) || src[p - 5] != (115 as u8)) {
    return 0;
  }
  if (p >= 6 && cgb_is_ident(src[p - 6]) != 0) {
    return 0;
  }
  return 1;
}

/**
 * Length of the type-arg ident in slot `pos` of a use-site angle list.
 * @param src *u8 — file bytes
 * @param src_len i32 — byte count
 * @param lt i32 — index of '<'
 * @param pos i32 — 0-based argument slot
 * @param dst *u8 — dest, capacity >= 64
 * @return i32 — length, or 0 when the slot is absent
 * Nested '<' starts a new depth and is not a comma. PLATFORM: SHARED.
 */
function cgb_use_arg(src: *u8, src_len: i32, lt: i32, pos: i32, dst: *u8): i32 {
  let p: i32 = 0;
  let depth: i32 = 0;
  let slot: i32 = 0;
  let n: i32 = 0;
  let c: u8 = 0;
  p = lt + 1;
  depth = 1;
  slot = 0;
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
        if (depth == 1 && c == (44 as u8)) {
          slot = slot + 1;
          p = p + 1;
        } else {
          if (depth == 1 && slot == pos && cgb_is_ident(c) != 0) {
            n = cgb_ident(src, src_len, p, dst);
            return n;
          }
          if (depth == 1 && cgb_is_ident(c) != 0) {
            n = cgb_ident(src, src_len, p, dst);
            if (n > 0) {
              p = p + n;
            } else {
              p = p + 1;
            }
          } else {
            p = p + 1;
          }
        }
      }
    }
  }
  return 0;
}

/**
 * 1-based line of byte index `at`.
 * @param src *u8 — file bytes
 * @param at i32 — byte index
 * @return i32 — line
 * PLATFORM: SHARED.
 */
function cgb_line_at(src: *u8, at: i32): i32 {
  let i: i32 = 0;
  let line: i32 = 1;
  if (src == 0 as *u8 || at <= 0) {
    return 1;
  }
  while (i < at) {
    if (src[i] == (10 as u8)) {
      line = line + 1;
    }
    i = i + 1;
  }
  return line;
}

/**
 * 1-based column of byte index `at`.
 * @param src *u8 — file bytes
 * @param at i32 — byte index
 * @return i32 — column
 * PLATFORM: SHARED.
 */
function cgb_col_at(src: *u8, at: i32): i32 {
  let i: i32 = 0;
  let col: i32 = 1;
  if (src == 0 as *u8 || at <= 0) {
    return 1;
  }
  while (i < at) {
    if (src[i] == (10 as u8)) {
      col = 1;
    } else {
      col = col + 1;
    }
    i = i + 1;
  }
  return col;
}

/**
 * Reject Foo<Arg> when struct Foo<T: Trait> and Arg does not impl Trait.
 * @param src *u8 — file bytes
 * @param src_len i32 — byte count
 * @return i32 — 0 ok, -1 a bound failed
 * Headers without ':' are unconstrained. Foo<T> uses the parameter
 * name and is not a concrete miss. PLATFORM: SHARED.
 */
function cgb_struct_file(src: *u8, src_len: i32): i32 {
  let lit: u8[7] = [];
  let from: i32 = 0;
  let at: i32 = 0;
  let p: i32 = 0;
  let nlen: i32 = 0;
  let lt: i32 = 0;
  let ufrom: i32 = 0;
  let uat: i32 = 0;
  let ult: i32 = 0;
  let ai: i32 = 0;
  let alen: i32 = 0;
  let line: i32 = 0;
  let col: i32 = 0;
  let name: u8[64] = [];
  let arg_nm: u8[64] = [];
  lit[0] = 115;
  lit[1] = 116;
  lit[2] = 114;
  lit[3] = 117;
  lit[4] = 99;
  lit[5] = 116;
  lit[6] = 32;
  from = 0;
  while (from >= 0) {
    at = cgb_find(src, src_len, &lit[0], 7, from);
    if (at < 0) {
      from = 0 - 1;
    } else {
      p = at + 7;
      while (p < src_len && (src[p] == (32 as u8) || src[p] == (9 as u8) || src[p] == (10 as u8) || src[p] == (13 as u8))) {
        p = p + 1;
      }
      nlen = cgb_ident(src, src_len, p, &name[0]);
      lt = 0 - 1;
      if (nlen > 0) {
        lt = cgb_header_lt(src, src_len, p, nlen);
      }
      if (lt >= 0) {
        ufrom = 0;
        while (ufrom >= 0) {
          uat = cgb_find(src, src_len, &name[0], nlen, ufrom);
          if (uat < 0) {
            ufrom = 0 - 1;
          } else {
            ult = 0 - 1;
            if (uat != p && cgb_prev_struct(src, uat) == 0) {
              if (uat == 0 || cgb_is_ident(src[uat - 1]) == 0) {
                if (uat + nlen >= src_len || cgb_is_ident(src[uat + nlen]) == 0) {
                  ult = uat + nlen;
                  while (ult < src_len && (src[ult] == (32 as u8) || src[ult] == (9 as u8) || src[ult] == (10 as u8) || src[ult] == (13 as u8))) {
                    ult = ult + 1;
                  }
                  if (ult >= src_len || src[ult] != (60 as u8)) {
                    ult = 0 - 1;
                  }
                }
              }
            }
            if (ult >= 0) {
              ai = 0;
              while (ai < 4) {
                alen = cgb_use_arg(src, src_len, ult, ai, &arg_nm[0]);
                if (alen <= 0) {
                  ai = 4;
                } else {
                  line = cgb_line_at(src, ult);
                  col = cgb_col_at(src, ult);
                  if (cgb_check_angle(src, src_len, lt, &arg_nm[0], alen, ai, line, col) == 0) {
                    return 0 - 1;
                  }
                  ai = ai + 1;
                }
              }
            }
            ufrom = uat + nlen;
          }
        }
      }
      from = at + 7;
    }
  }
  return 0;
}

/**
 * Stamp LANG-006 length on a module `const N: i32 = [1, 2, 3, 4]`.
 * @param module *u8 — module after the mega accepted it
 * @param arena *u8 — expression pool
 * @return i32 — 0
 * Function-scope consts are folded by typeck_fold_block_const_init.
 * A module let never reaches that fold, so the array address was
 * returned as the integer. Integer decl kinds are 0 and 2..7.
 * Bool (1) is left alone. A real array declaration is not kind 0..7.
 * PLATFORM: SHARED.
 */
function cgb_mod_array_len(module: *u8, arena: *u8): i32 {
  unsafe {
    let n: i32 = 0;
    let i: i32 = 0;
    let init_ref: i32 = 0;
    let decl: i32 = 0;
    let dk: i32 = 0;
    let ne: i32 = 0;
    if (module == 0 as *u8 || arena == 0 as *u8) {
      return 0;
    }
    n = pipe_mod_get_num_top_level_lets(module);
    i = 0;
    while (i < n && i < 256) {
      init_ref = pipeline_module_top_level_let_init_ref(module, i);
      decl = pipeline_module_top_level_let_type_ref(module, i);
      if (init_ref > 0 && decl > 0 && pipeline_expr_kind_ord_at(arena, init_ref) == 46) {
        dk = pipeline_type_kind_ord_at(arena, decl);
        if (dk == 0 || (dk >= 2 && dk <= 7)) {
          ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
          if (ne > 0) {
            pipeline_expr_set_const_folded(arena, init_ref, 1, ne);
          }
        }
      }
      i = i + 1;
    }
    return 0;
  }
}

/**
 * Module typeck, then struct-header bounds on Foo<Arg>.
 * @param module *u8 — module; passed to the mega
 * @param arena *u8 — type pool; passed to the mega
 * @param ctx *u8 — dep context; passed to the mega
 * @return i32 — 0 ok, non-zero diagnostic already emitted
 * The source scan runs only after the mega accepts the module.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_x_ast(module: *u8, arena: *u8, ctx: *u8): i32 {
  // PLATFORM: SHARED — mega owns the module; this owns struct bounds.
  unsafe {
    let rc: i32 = 0;
    let src: *u8 = 0 as *u8;
    let src_len64: i64 = 0;
    let src_len: i32 = 0;
    rc = typeck_x_ast_mega(module, arena, ctx);
    if (rc != 0) {
      return rc;
    }
    cgb_mod_array_len(module, arena);
    src = xlang_cap_tip_lex_src_data();
    src_len64 = xlang_cap_tip_lex_src_len();
    if (src == 0 as *u8 || src_len64 <= 0 || src_len64 > 2000000) {
      return 0;
    }
    src_len = src_len64 as i32;
    if (cgb_struct_file(src, src_len) != 0) {
      return 0 - 1;
    }
    return cgb_dyn_lets(module, arena, src, src_len);
  }
}

/**
 * 1 when the file declares `trait Name` as a whole ident.
 * @param src *u8 — file bytes
 * @param src_len i32 — byte count
 * @param name *u8 — trait spelling
 * @param nlen i32 — spelling length
 * @return i32 — 1 declared, 0 not
 * PLATFORM: SHARED.
 */
function cgb_trait_declared(src: *u8, src_len: i32, name: *u8, nlen: i32): i32 {
  let lit: u8[6] = [];
  let from: i32 = 0;
  let at: i32 = 0;
  let p: i32 = 0;
  let k: i32 = 0;
  lit[0] = 116;
  lit[1] = 114;
  lit[2] = 97;
  lit[3] = 105;
  lit[4] = 116;
  lit[5] = 32;
  from = 0;
  while (from >= 0) {
    at = cgb_find(src, src_len, &lit[0], 6, from);
    if (at < 0) {
      return 0;
    }
    p = at + 6;
    while (p < src_len && (src[p] == (32 as u8) || src[p] == (9 as u8) || src[p] == (10 as u8) || src[p] == (13 as u8))) {
      p = p + 1;
    }
    k = 0;
    if (p + nlen <= src_len) {
      while (k < nlen) {
        if (src[p + k] != name[k]) {
          k = nlen + 1;
        } else {
          k = k + 1;
        }
      }
      if (k == nlen && (p + nlen >= src_len || cgb_is_ident(src[p + nlen]) == 0)) {
        return 1;
      }
    }
    from = at + 6;
  }
  return 0;
}

/**
 * Reject `let x: Trait = value` when value's type has no impl.
 * @param module *u8 — module just typechecked
 * @param arena *u8 — expression pool
 * @param src *u8 — file bytes
 * @param src_len i32 — byte count
 * @return i32 — 0 ok, -1 mismatch already reported
 * A dyn or trait-named let accepts the init only when the source has
 * `impl Trait for Type`. The null sentinel is not a named init.
 * PLATFORM: SHARED.
 */
function cgb_dyn_lets(module: *u8, arena: *u8, src: *u8, src_len: i32): i32 {
  unsafe {
    let nf: i32 = 0;
    let fi: i32 = 0;
    let br: i32 = 0;
    let nl: i32 = 0;
    let li: i32 = 0;
    let decl: i32 = 0;
    let init_ref: i32 = 0;
    let init_ty: i32 = 0;
    let dk: i32 = 0;
    let ik: i32 = 0;
    let tlen: i32 = 0;
    let clen: i32 = 0;
    let line: i32 = 0;
    let col: i32 = 0;
    let i: i32 = 0;
    let trait_nm: u8[64] = [];
    let conc_nm: u8[64] = [];
    let expect: u8[80] = [];
    nf = pipeline_module_num_funcs(module);
    fi = 0;
    while (fi < nf && fi < 64) {
      br = pipeline_module_func_body_ref_at(module, fi);
      if (br > 0) {
        nl = ast_ast_block_num_lets(arena, br);
        li = 0;
        while (li < nl && li < 64) {
          decl = pipeline_block_let_type_ref(arena, br, li);
          init_ref = ast_ast_block_let_init_ref(arena, br, li);
          if (decl > 0 && init_ref > 0) {
            dk = pipeline_type_kind_ord_at(arena, decl);
            tlen = pipeline_type_named_name_into(arena, decl, &trait_nm[0]);
            if (tlen > 0 && tlen <= 63 && (dk == 17 || (dk == 8 && cgb_trait_declared(src, src_len, &trait_nm[0], tlen) != 0))) {
              init_ty = pipeline_expr_resolved_type_ref(arena, init_ref);
              if (init_ty > 0) {
                ik = pipeline_type_kind_ord_at(arena, init_ty);
                if (ik == 8) {
                  clen = pipeline_type_named_name_into(arena, init_ty, &conc_nm[0]);
                  if (clen > 0 && clen <= 63) {
                    if (cgb_impl_for(src, src_len, &trait_nm[0], tlen, &conc_nm[0], clen) == 0) {
                      expect[0] = 100;
                      expect[1] = 121;
                      expect[2] = 110;
                      expect[3] = 32;
                      i = 0;
                      while (i < tlen && i < 70) {
                        expect[4 + i] = trait_nm[i];
                        i = i + 1;
                      }
                      line = pipeline_expr_line_at(arena, init_ref);
                      col = pipeline_expr_col_at(arena, init_ref);
                      driver_diagnostic_typeck_assign_mismatch(0, line, col, &expect[0], 4 + i, &conc_nm[0], clen);
                      return 0 - 1;
                    }
                  }
                }
              }
            }
          }
          li = li + 1;
        }
      }
      fi = fi + 1;
    }
    return 0;
  }
}
