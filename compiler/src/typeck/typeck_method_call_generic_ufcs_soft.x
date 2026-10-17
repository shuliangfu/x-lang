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

// knife256/10.2 product entry of typeck_method_call_generic_ufcs.
// Cap tip cannot re-emit typeck.x. The mega unifies only when the self
// formal still contains a free type parameter. `impl<T: Clone> Foo<T>`
// hoists `get(self: Foo)` with no generic params, so Foo<A> is not Foo
// and f.get() is LANG-004. This entry keeps the mega result. A miss
// whose receiver is Foo<A> reads the impl header in the current source:
// no bounds accept the method; each Trait must appear as
// `impl Trait for A`. The same check applies to `impl Foo<T: Trait>`
// and to `impl<T: Trait> Trait for Foo<T>`.
// A missing bound emits "does not impl" and stays
// a miss, so the caller still reports LANG-004.
// PLATFORM: SHARED. The alias of the mega is the Darwin link step.

export extern "C" function typeck_method_call_generic_ufcs_mega(module: *u8, arena: *u8, expr_ref: i32,
base_ty: i32, method_nm: *u8, method_nlen: i32, num_args: i32): i32;
export extern "C" function pipeline_module_num_funcs(module: *u8): i32;
export extern "C" function pipeline_module_func_name_equal_at(module: *u8, fi: i32, name: *u8, nlen: i32): i32;
export extern "C" function pipeline_module_func_num_params_at(module: *u8, fi: i32): i32;
export extern "C" function pipeline_module_func_param_type_ref_at(module: *u8, fi: i32, pi: i32): i32;
export extern "C" function pipeline_module_func_return_type_at(module: *u8, fi: i32): i32;
export extern "C" function pipeline_module_func_owner_binds_base_at(module: *u8, fi: i32, base: *u8, base_len: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, ty: i32): i32;
export extern "C" function pipeline_type_named_name_into(arena: *u8, ty: i32, out: *u8): i32;
export extern "C" function pipeline_type_type_arg_ref_at(arena: *u8, ty: i32, idx: i32): i32;
export extern "C" function pipeline_expr_apply_call_resolve(arena: *u8, expr_ref: i32, dep: i32, fi: i32): void;
export extern "C" function pipeline_expr_set_resolved_type_ref(arena: *u8, expr_ref: i32, ty: i32): void;
export extern "C" function pipeline_expr_line_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_col_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function xlang_cap_tip_lex_src_data(): *u8;
export extern "C" function xlang_cap_tip_lex_src_len(): i64;
export extern "C" function xlang_generic_bound_diag_not_impl_c(ta: *u8, ta_len: i32, trait_nm: *u8, trait_nlen: i32, line: i32, col: i32): i32;

/**
 * Index of pat in src at or after from, or -1.
 * @param src *u8 — file bytes; null returns -1
 * @param src_len i32 — byte count
 * @param pat *u8 — needle; null returns -1
 * @param pat_len i32 — needle length; <= 0 returns -1
 * @param from i32 — start index; negative is treated as 0
 * @return i32 — first hit, or -1
 * PLATFORM: SHARED.
 */
function ufcs_src_find(src: *u8, src_len: i32, pat: *u8, pat_len: i32, from: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  if (src == 0 as *u8) {
    return 0 - 1;
  }
  if (pat == 0 as *u8) {
    return 0 - 1;
  }
  if (pat_len <= 0) {
    return 0 - 1;
  }
  if (src_len < pat_len) {
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
 * 1 when c can continue an identifier.
 * @param c u8 — source byte
 * @return i32 — 1 ident, 0 stop
 * PLATFORM: SHARED.
 */
function ufcs_is_ident(c: u8): i32 {
  if (c >= (65 as u8)) {
    if (c <= (90 as u8)) {
      return 1;
    }
  }
  if (c >= (97 as u8)) {
    if (c <= (122 as u8)) {
      return 1;
    }
  }
  if (c >= (48 as u8)) {
    if (c <= (57 as u8)) {
      return 1;
    }
  }
  if (c == (95 as u8)) {
    return 1;
  }
  return 0;
}

/**
 * 1 when src has `impl Trait for Name` as whole idents.
 * @param src *u8 — file bytes
 * @param src_len i32 — byte count
 * @param trait_nm *u8 — trait spelling
 * @param trait_len i32 — trait length
 * @param arg_nm *u8 — concrete type-arg spelling
 * @param arg_len i32 — type-arg length
 * @return i32 — 1 found, 0 missing
 * Spaces and newlines may sit between the words. PLATFORM: SHARED.
 */
function ufcs_impl_for_present(src: *u8, src_len: i32, trait_nm: *u8, trait_len: i32, arg_nm: *u8, arg_len: i32): i32 {
  let lit: u8[5] = [];
  let from: i32 = 0;
  let at: i32 = 0;
  let p: i32 = 0;
  let n: i32 = 0;
  let k: i32 = 0;
  lit[0] = 105;
  lit[1] = 109;
  lit[2] = 112;
  lit[3] = 108;
  lit[4] = 32;
  from = 0;
  while (from >= 0) {
    at = ufcs_src_find(src, src_len, &lit[0], 5, from);
    if (at < 0) {
      return 0;
    }
    p = at + 5;
    while (p < src_len) {
      if (src[p] == (32 as u8) || src[p] == (9 as u8) || src[p] == (10 as u8) || src[p] == (13 as u8)) {
        p = p + 1;
      } else {
        p = src_len;
      }
    }
    p = at + 5;
    while (p < src_len) {
      if (src[p] == (32 as u8) || src[p] == (9 as u8) || src[p] == (10 as u8) || src[p] == (13 as u8)) {
        p = p + 1;
      } else {
        break;
      }
    }
    n = 0;
    k = 0;
    if (p + trait_len <= src_len) {
      k = 0;
      while (k < trait_len) {
        if (src[p + k] != trait_nm[k]) {
          k = trait_len + 1;
        } else {
          k = k + 1;
        }
      }
      if (k == trait_len) {
        if (p + trait_len >= src_len) {
          n = 0;
        } else {
          if (ufcs_is_ident(src[p + trait_len]) == 0) {
            n = 1;
          }
        }
      }
    }
    if (n != 0) {
      p = p + trait_len;
      while (p < src_len) {
        if (src[p] == (32 as u8) || src[p] == (9 as u8) || src[p] == (10 as u8) || src[p] == (13 as u8)) {
          p = p + 1;
        } else {
          break;
        }
      }
      if (p + 4 <= src_len) {
        if (src[p] == (102 as u8)) {
          if (src[p + 1] == (111 as u8)) {
            if (src[p + 2] == (114 as u8)) {
              if (ufcs_is_ident(src[p + 3]) == 0) {
                p = p + 3;
                while (p < src_len) {
                  if (src[p] == (32 as u8) || src[p] == (9 as u8) || src[p] == (10 as u8) || src[p] == (13 as u8)) {
                    p = p + 1;
                  } else {
                    break;
                  }
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
                  if (k == arg_len) {
                    if (p + arg_len >= src_len) {
                      return 1;
                    }
                    if (ufcs_is_ident(src[p + arg_len]) == 0) {
                      return 1;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    from = at + 1;
  }
  return 0;
}

/**
 * Read one ident at p into dst. Returns the length, or 0.
 * @param src *u8 — file bytes
 * @param src_len i32 — byte count
 * @param p i32 — start; updated is not returned, length is
 * @param dst *u8 — caller buffer, capacity >= 64
 * @return i32 — ident length, 0 if p is not an ident
 * The caller advances by the length. PLATFORM: SHARED.
 */
function ufcs_read_ident(src: *u8, src_len: i32, p: i32, dst: *u8): i32 {
  let n: i32 = 0;
  if (p < 0) {
    return 0;
  }
  if (p >= src_len) {
    return 0;
  }
  if (ufcs_is_ident(src[p]) == 0) {
    return 0;
  }
  while (p + n < src_len) {
    if (n >= 63) {
      return n;
    }
    if (ufcs_is_ident(src[p + n]) == 0) {
      return n;
    }
    dst[n] = src[p + n];
    n = n + 1;
  }
  return n;
}

/**
 * Length of the suffix after `Self_`, or 0 when recv is not that instance.
 * @param recv *u8 — receiver spelling, such as Foo_A
 * @param recv_len i32 — receiver length
 * @param selfn *u8 — formal self spelling, such as Foo
 * @param self_len i32 — formal length
 * @param arg_nm *u8 — dest for the suffix; capacity >= 64
 * @return i32 — suffix length, or 0
 * Foo_A with self Foo yields A. A second '_' in the suffix is kept.
 * PLATFORM: SHARED.
 */
function ufcs_inst_suffix(recv: *u8, recv_len: i32, selfn: *u8, self_len: i32, arg_nm: *u8): i32 {
  let bi: i32 = 0;
  let n: i32 = 0;
  if (self_len <= 0) {
    return 0;
  }
  if (recv_len <= self_len) {
    return 0;
  }
  if (recv[self_len] != (95 as u8)) {
    return 0;
  }
  while (bi < self_len) {
    if (selfn[bi] != recv[bi]) {
      return 0;
    }
    bi = bi + 1;
  }
  n = recv_len - self_len - 1;
  if (n <= 0) {
    return 0;
  }
  if (n > 63) {
    return 0;
  }
  bi = 0;
  while (bi < n) {
    arg_nm[bi] = recv[self_len + 1 + bi];
    bi = bi + 1;
  }
  return n;
}

/**
 * 1 when the impl header for this method accepts the type argument.
 * @param src *u8 — current file
 * @param src_len i32 — byte count
 * @param self_nm *u8 — formal self spelling (Foo)
 * @param self_len i32 — formal length
 * @param arg_nm *u8 — concrete type-arg spelling (A)
 * @param arg_len i32 — type-arg length
 * @param method_nm *u8 — method bytes
 * @param method_nlen i32 — method length
 * @param arena *u8 — expression pool, for the diagnostic line
 * @param expr_ref i32 — METHOD_CALL
 * @return i32 — 1 accept, 0 no header or a bound failed
 * A failed bound has already emitted "does not impl". PLATFORM: SHARED.
 */
function ufcs_header_ok(src: *u8, src_len: i32, self_nm: *u8, self_len: i32, arg_nm: *u8, arg_len: i32,
method_nm: *u8, method_nlen: i32, arena: *u8, expr_ref: i32): i32 {
  // PLATFORM: SHARED — impl header and `impl Trait for Arg` live in the same file.
  unsafe {
  let from: i32 = 0;
  let ok_hdr: i32 = 0;
  let nb: i32 = 0;
  let at: i32 = 0;
  let p: i32 = 0;
  let bi: i32 = 0;
  let impl_at: i32 = 0;
  let back: i32 = 0;
  let depth: i32 = 0;
  let expect_tr: i32 = 0;
  let tl: i32 = 0;
  let for_len: i32 = 0;
  let miss: i32 = 0;
  let line: i32 = 0;
  let col: i32 = 0;
  let lit_fn: u8[9] = [];
  let for_nm: u8[64] = [];
  let traits: u8[256] = [];
  let tlen: i32[4] = [];
  lit_fn[0] = 102;
  lit_fn[1] = 117;
  lit_fn[2] = 110;
  lit_fn[3] = 99;
  lit_fn[4] = 116;
  lit_fn[5] = 105;
  lit_fn[6] = 111;
  lit_fn[7] = 110;
  lit_fn[8] = 32;
  from = 0;
  ok_hdr = 0;
  nb = 0;
  while (from >= 0) {
    if (ok_hdr != 0) {
      from = 0 - 1;
    } else {
      at = ufcs_src_find(src, src_len, &lit_fn[0], 9, from);
      if (at < 0) {
        from = 0 - 1;
      } else {
        p = at + 9;
        bi = 0;
        while (bi < method_nlen) {
          if (p + bi >= src_len) {
            bi = method_nlen + 1;
          } else {
            if (src[p + bi] != method_nm[bi]) {
              bi = method_nlen + 1;
            } else {
              bi = bi + 1;
            }
          }
        }
        if (bi == method_nlen) {
          if (p + method_nlen < src_len) {
            if (ufcs_is_ident(src[p + method_nlen]) != 0) {
              bi = 0;
            }
          }
        }
        if (bi == method_nlen) {
          impl_at = 0 - 1;
          back = at;
          while (back >= 4) {
            if (src[back - 4] == (105 as u8)) {
              if (src[back - 3] == (109 as u8)) {
                if (src[back - 2] == (112 as u8)) {
                  if (src[back - 1] == (108 as u8)) {
                    if (back - 5 < 0) {
                      impl_at = back - 4;
                      back = 0;
                    } else {
                      if (ufcs_is_ident(src[back - 5]) == 0) {
                        impl_at = back - 4;
                        back = 0;
                      }
                    }
                  }
                }
              }
            }
            if (back > 0) {
              back = back - 1;
            }
          }
          if (impl_at >= 0) {
            p = impl_at + 4;
            while (p < src_len) {
              if (src[p] == (32 as u8) || src[p] == (9 as u8) || src[p] == (10 as u8) || src[p] == (13 as u8)) {
                p = p + 1;
              } else {
                break;
              }
            }
            nb = 0;
            if (p < src_len) {
              if (src[p] == (60 as u8)) {
                depth = 1;
                expect_tr = 0;
                p = p + 1;
                while (p < src_len && depth > 0) {
                    if (src[p] == (60 as u8)) {
                      depth = depth + 1;
                      p = p + 1;
                    } else {
                      if (src[p] == (62 as u8)) {
                        depth = depth - 1;
                        p = p + 1;
                      } else {
                        if (depth == 1) {
                          if (src[p] == (58 as u8)) {
                            expect_tr = 1;
                            p = p + 1;
                          } else {
                            if (src[p] == (43 as u8)) {
                              expect_tr = 1;
                              p = p + 1;
                            } else {
                              if (expect_tr != 0) {
                                if (ufcs_is_ident(src[p]) != 0) {
                                  if (nb < 4) {
                                    tl = ufcs_read_ident(src, src_len, p, &traits[nb * 64]);
                                    if (tl > 0) {
                                      tlen[nb] = tl;
                                      nb = nb + 1;
                                      p = p + tl;
                                      expect_tr = 0;
                                    } else {
                                      p = p + 1;
                                    }
                                  } else {
                                    p = p + 1;
                                  }
                                } else {
                                  p = p + 1;
                                }
                              } else {
                                p = p + 1;
                              }
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
            while (p < src_len) {
              if (src[p] == (32 as u8) || src[p] == (9 as u8) || src[p] == (10 as u8) || src[p] == (13 as u8)) {
                p = p + 1;
              } else {
                break;
              }
            }
            for_len = ufcs_read_ident(src, src_len, p, &for_nm[0]);
            if (for_len == self_len) {
              bi = 0;
              ok_hdr = 1;
              while (bi < self_len) {
                if (for_nm[bi] != self_nm[bi]) {
                  ok_hdr = 0;
                }
                bi = bi + 1;
              }
              if (ok_hdr != 0) {
                nb = ufcs_append_angle_bounds(src, src_len, p + for_len, &traits[0], &tlen[0], nb);
                from = 0 - 1;
              }
            }
            if (ok_hdr == 0 && for_len > 0) {
              if (ufcs_impl_for_is_self(src, src_len, p, for_len, &self_nm[0], self_len) != 0) {
                ok_hdr = 1;
                from = 0 - 1;
              }
            }
          }
        }
        if (from >= 0) {
          from = at + 1;
        }
      }
    }
  }
  if (ok_hdr == 0) {
    return 0;
  }
  miss = 0;
  bi = 0;
  line = pipeline_expr_line_at(arena, expr_ref);
  col = pipeline_expr_col_at(arena, expr_ref);
  while (bi < nb) {
    if (ufcs_impl_for_present(src, src_len, &traits[bi * 64], tlen[bi], &arg_nm[0], arg_len) == 0) {
      xlang_generic_bound_diag_not_impl_c(&arg_nm[0], arg_len, &traits[bi * 64], tlen[bi], line, col);
      miss = 1;
    }
    bi = bi + 1;
  }
  if (miss != 0) {
    return 0;
  }
  return 1;
  }
}

/**
 * Append trait names that follow ':' or '+' inside one angle list.
 * @param src *u8 — file bytes
 * @param src_len i32 — byte count
 * @param p i32 — index just after the impl type name
 * @param traits *u8 — 4 rows of 64 bytes
 * @param tlen *i32 — 4 lengths
 * @param nb i32 — traits already recorded
 * @return i32 — new trait count
 * Spaces before '<' are skipped. No '<' leaves nb unchanged.
 * `T` with no colon is not a trait. At most 4 traits.
 * PLATFORM: SHARED.
 */
function ufcs_append_angle_bounds(src: *u8, src_len: i32, p: i32, traits: *u8, tlen: *i32, nb: i32): i32 {
  let depth: i32 = 0;
  let expect_tr: i32 = 0;
  let tl: i32 = 0;
  let done: i32 = 0;
  let c: u8 = 0;
  if (src == 0 as *u8) {
    return nb;
  }
  if (p < 0) {
    return nb;
  }
  while (p < src_len && done == 0) {
    c = src[p];
    if (c == (32 as u8) || c == (9 as u8) || c == (10 as u8) || c == (13 as u8)) {
      p = p + 1;
    } else {
      done = 1;
    }
  }
  if (done == 0) {
    return nb;
  }
  if (src[p] != (60 as u8)) {
    return nb;
  }
  depth = 1;
  expect_tr = 0;
  p = p + 1;
  while (p < src_len) {
    if (depth <= 0) {
      p = src_len;
    } else {
      c = src[p];
      if (c == (60 as u8)) {
        depth = depth + 1;
        p = p + 1;
      } else {
        if (c == (62 as u8)) {
          depth = depth - 1;
          p = p + 1;
        } else {
          if (depth == 1) {
            if (c == (58 as u8) || c == (43 as u8)) {
              expect_tr = 1;
              p = p + 1;
            } else {
              if (expect_tr != 0) {
                if (ufcs_is_ident(c) != 0) {
                  if (nb < 4) {
                    tl = ufcs_read_ident(src, src_len, p, &traits[nb * 64]);
                    if (tl > 0) {
                      tlen[nb] = tl;
                      nb = nb + 1;
                      p = p + tl;
                      expect_tr = 0;
                    } else {
                      p = p + 1;
                    }
                  } else {
                    p = p + 1;
                  }
                } else {
                  p = p + 1;
                }
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
  return nb;
}

/**
 * 1 when `p` is `Trait for Self`, with Self a whole ident.
 * @param src *u8 — file bytes
 * @param src_len i32 — byte count
 * @param p i32 — start of the trait ident
 * @param ident_len i32 — trait ident length
 * @param self_nm *u8 — formal self spelling
 * @param self_len i32 — formal length
 * @return i32 — 1 the for-type is Self, 0 otherwise
 * Spaces may sit around `for`. A following `<T>` is left to the caller.
 * PLATFORM: SHARED.
 */
function ufcs_impl_for_is_self(src: *u8, src_len: i32, p: i32, ident_len: i32, self_nm: *u8, self_len: i32): i32 {
  let q: i32 = 0;
  let n: i32 = 0;
  let k: i32 = 0;
  if (src == 0 as *u8 || self_nm == 0 as *u8 || ident_len <= 0 || self_len <= 0) {
    return 0;
  }
  q = p + ident_len;
  while (q < src_len && (src[q] == (32 as u8) || src[q] == (9 as u8) || src[q] == (10 as u8) || src[q] == (13 as u8))) {
    q = q + 1;
  }
  if (q + 3 > src_len) {
    return 0;
  }
  if (src[q] != (102 as u8) || src[q + 1] != (111 as u8) || src[q + 2] != (114 as u8)) {
    return 0;
  }
  if (q + 3 < src_len && ufcs_is_ident(src[q + 3]) != 0) {
    return 0;
  }
  q = q + 3;
  while (q < src_len && (src[q] == (32 as u8) || src[q] == (9 as u8) || src[q] == (10 as u8) || src[q] == (13 as u8))) {
    q = q + 1;
  }
  n = 0;
  while (q + n < src_len && n < self_len && ufcs_is_ident(src[q + n]) != 0) {
    n = n + 1;
  }
  if (n != self_len) {
    return 0;
  }
  if (q + n < src_len && ufcs_is_ident(src[q + n]) != 0) {
    return 0;
  }
  k = 0;
  while (k < self_len) {
    if (src[q + k] != self_nm[k]) {
      return 0;
    }
    k = k + 1;
  }
  return 1;
}

/**
 * Stamp f.get() when the impl header's for-type is the receiver and
 * every bound is implemented by the first type argument.
 * @param module *u8 — caller module
 * @param arena *u8 — expression pool
 * @param expr_ref i32 — METHOD_CALL
 * @param base_ty i32 — receiver; must be a named type with a type arg
 * @param method_nm *u8 — method bytes
 * @param method_nlen i32 — method length
 * @param num_args i32 — extras after self
 * @return i32 — 1 stamped, 0 no such impl or a bound failed
 * A failed bound has already emitted "does not impl". The caller then
 * reports LANG-004 as well. One type argument only. PLATFORM: SHARED.
 */
/**
 * Func index of get(self: Foo) for a Foo_A receiver, or -1.
 * @param module *u8 — caller module
 * @param arena *u8 — type pool
 * @param method_nm *u8 — method bytes
 * @param method_nlen i32 — method length
 * @param num_args i32 — extras after self
 * @param recv_nm *u8 — receiver spelling Foo_A
 * @param recv_len i32 — receiver length
 * @param arg_nm *u8 — dest suffix; filled when the type-arg slot was empty
 * @param arg_len_io *i32 — in: existing suffix length; out: suffix length
 * @return i32 — func index, or -1
 * Owner must be the formal self name. PLATFORM: SHARED.
 */
function ufcs_find_hit(module: *u8, arena: *u8, method_nm: *u8, method_nlen: i32, num_args: i32,
recv_nm: *u8, recv_len: i32, arg_nm: *u8, arg_len_io: *i32): i32 {
  // PLATFORM: SHARED — one scan of the module func table.
  unsafe {
  let nf: i32 = 0;
  let fi: i32 = 0;
  let hit: i32 = 0 - 1;
  let hit_loose: i32 = 0 - 1;
  let self_ty: i32 = 0;
  let self_len: i32 = 0;
  let arg_len: i32 = 0;
  let self_nm: u8[64] = [];
  arg_len = arg_len_io[0];
  nf = pipeline_module_num_funcs(module);
  while (fi < nf) {
    if (hit < 0) {
      if (pipeline_module_func_name_equal_at(module, fi, method_nm, method_nlen) != 0) {
        if (pipeline_module_func_num_params_at(module, fi) == num_args + 1) {
          self_ty = pipeline_module_func_param_type_ref_at(module, fi, 0);
          if (self_ty > 0) {
            if (pipeline_type_kind_ord_at(arena, self_ty) == 8) {
              self_len = pipeline_type_named_name_into(arena, self_ty, &self_nm[0]);
              if (arg_len <= 0) {
                arg_len = ufcs_inst_suffix(recv_nm, recv_len, &self_nm[0], self_len, arg_nm);
              }
              if (arg_len > 0) {
                if (pipeline_module_func_owner_binds_base_at(module, fi, &self_nm[0], self_len) != 0) {
                  hit = fi;
                } else {
                  if (hit_loose < 0) {
                    hit_loose = fi;
                  }
                }
              }
            }
          }
        }
      }
    }
    fi = fi + 1;
  }
  if (hit < 0) {
    hit = hit_loose;
  }
  arg_len_io[0] = arg_len;
  return hit;
  }
}

function ufcs_impl_header_method(module: *u8, arena: *u8, expr_ref: i32, base_ty: i32,
method_nm: *u8, method_nlen: i32, num_args: i32): i32 {
  // PLATFORM: SHARED — extern reads of the module, the type pool, and the source.
  unsafe {
  let src: *u8 = 0 as *u8;
  let src_len64: i64 = 0;
  let src_len: i32 = 0;
  let recv_len: i32 = 0;
  let arg_ty: i32 = 0;
  let arg_len: i32 = 0;
  let self_ty: i32 = 0;
  let self_len: i32 = 0;
  let nf: i32 = 0;
  let fi: i32 = 0;
  let hit: i32 = 0 - 1;
  let ret_ty: i32 = 0;
  let recv_nm: u8[64] = [];
  let arg_nm: u8[64] = [];
  let self_nm: u8[64] = [];
  src = xlang_cap_tip_lex_src_data();
  src_len64 = xlang_cap_tip_lex_src_len();
  if (src == 0 as *u8) {
    return 0;
  }
  if (src_len64 <= 0) {
    return 0;
  }
  if (src_len64 > 2000000) {
    return 0;
  }
  src_len = src_len64 as i32;
  if (pipeline_type_kind_ord_at(arena, base_ty) != 8) {
    return 0;
  }
  recv_len = pipeline_type_named_name_into(arena, base_ty, &recv_nm[0]);
  if (recv_len <= 0) {
    return 0;
  }
  if (recv_len > 63) {
    return 0;
  }
  /* Foo<A> is spelled Foo_A. The type-arg slot is empty. One '_' suffix
   * is the concrete argument. Two suffixes stay on the mega path.
   * PLATFORM: SHARED. */
  arg_ty = pipeline_type_type_arg_ref_at(arena, base_ty, 0);
  arg_len = 0;
  if (arg_ty > 0) {
    if (pipeline_type_type_arg_ref_at(arena, base_ty, 1) > 0) {
      return 0;
    }
    arg_len = pipeline_type_named_name_into(arena, arg_ty, &arg_nm[0]);
  }
  let arg_box: i32[1] = [];
  arg_box[0] = arg_len;
  hit = ufcs_find_hit(module, arena, method_nm, method_nlen, num_args, &recv_nm[0], recv_len, &arg_nm[0], &arg_box[0]);
  arg_len = arg_box[0];
  if (hit < 0) {
    return 0;
  }
  self_ty = pipeline_module_func_param_type_ref_at(module, hit, 0);
  self_len = pipeline_type_named_name_into(arena, self_ty, &self_nm[0]);
  if (ufcs_header_ok(src, src_len, &self_nm[0], self_len, &arg_nm[0], arg_len, method_nm, method_nlen, arena, expr_ref) == 0) {
    return 0;
  }
  ret_ty = pipeline_module_func_return_type_at(module, hit);
  if (ret_ty <= 0) {
    return 0;
  }
  pipeline_expr_apply_call_resolve(arena, expr_ref, 0 - 1, hit);
  pipeline_expr_set_resolved_type_ref(arena, expr_ref, ret_ty);
  return 1;
  }
}

/**
 * Generic method UFCS, then an impl header whose self is the bare for-type.
 * @param module *u8 — caller module; null returns the mega result
 * @param arena *u8 — expression pool; null returns the mega result
 * @param expr_ref i32 — METHOD_CALL
 * @param base_ty i32 — receiver type
 * @param method_nm *u8 — method bytes
 * @param method_nlen i32 — method length
 * @param num_args i32 — extras after self
 * @return i32 — 1 when the call is stamped, 0 when it is not
 * The mega result wins when it is already 1. A receiver without a type
 * argument stays on the later exact UFCS. PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_method_call_generic_ufcs(module: *u8, arena: *u8, expr_ref: i32,
base_ty: i32, method_nm: *u8, method_nlen: i32, num_args: i32): i32 {
  // PLATFORM: SHARED — one UFCS entry for generic self and impl<T> Foo<T>.
  unsafe {
  let got: i32 = 0;
  got = typeck_method_call_generic_ufcs_mega(module, arena, expr_ref, base_ty, method_nm, method_nlen, num_args);
  if (got != 0) {
    return got;
  }
  if (module == 0 as *u8) {
    return 0;
  }
  if (arena == 0 as *u8) {
    return 0;
  }
  return ufcs_impl_header_method(module, arena, expr_ref, base_ty, method_nm, method_nlen, num_args);
  }
}
