// Strong body for glue_type_size_simple.
//
// runtime_pipeline_abi.x is the authority: glue_layout_name_matches_named_type_c
// matches a TYPE_NAMED spelling to a struct layout by exact name or by the
// last segment (token.Token matches Token; MyToken does not). The linked
// egg was built earlier. Its glue_type_size_simple is weak and compares
// names with exact length and bytes only, so an imported token.Token misses
// and returns 4. Lexer is 16, that miss makes LexerResult 32, and the
// allow(padding) lexer result never carries ident_len.
//
// This file is the strong definition of the same symbol. The suffix helper
// is private in the mega, so the algorithm is copied here and is not a
// second size policy. g05_relink_env.sh compiles this with the current
// product and links it ahead of pabi. Do not rebuild the egg.
// Align stays the egg body: Token at align 4 still starts at offset 16
// after a 16-byte Lexer, so LexerResult is 72 from size alone.
// PLATFORM: SHARED.

export extern function pipeline_arena_num_types(arena: *u8): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;
export extern function pipeline_module_num_struct_layouts_at(mod: *u8): i32;
export extern function pipeline_module_struct_layout_name_len(mod: *u8, k: i32): i32;
export extern function pipeline_module_struct_layout_name_byte_at(mod: *u8, k: i32, j: i32): i32;
export extern function typeck_x_type_size_from_layout_glue(module: *u8, arena: *u8, li: i32, depth: i32): i32;
export extern function typeck_soa_array_storage_size_glue(module: *u8, arena: *u8, elem_type_ref: i32, array_len: i32, depth: i32): i32;
export extern function pipeline_asm_emit_dep_pipe_c(): *u8;
export extern function pipeline_dep_ctx_ndep(ctx: *u8): i32;
export extern function pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8;
export extern function pipeline_dep_ctx_arena_at(ctx: *u8, idx: i32): *u8;
export extern function glue_vector_type_lanes_esz_c(arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32): i32;

/**
 * Local copy of glue_layout_name_matches_named_type_c.
 * Exact layout-name equality, else a qualified suffix: the byte before
 * the trailing segment is '.' and those trailing bytes equal the layout.
 * token.Token matches Token. MyToken does not. The mega helper is private
 * and is not a linkable symbol, so this TU cannot call it.
 * @param m *u8 — module that owns the layout; null returns 0
 * @param k i32 — layout index
 * @param name *u8 — TYPE_NAMED bytes; not required to be NUL-terminated
 * @param nlen i32 — byte count of name; must be > 0
 * @return i32 — 1 on match, 0 otherwise
 * PLATFORM: SHARED.
 */
function named_size_layout_matches_c(m: *u8, k: i32, name: *u8, nlen: i32): i32 {
  let ln: i32 = 0;
  let j: i32 = 0;
  let b: i32 = 0;
  let ch: i32 = 0;
  if (m == (0 as *u8) || name == (0 as *u8) || nlen <= 0) {
    return 0;
  }
  unsafe {
    ln = pipeline_module_struct_layout_name_len(m, k);
  }
  if (ln <= 0) {
    return 0;
  }
  // Exact: same length and the same bytes. Same as glue_struct_layout_name_eq_c.
  if (ln == nlen) {
    j = 0;
    while (j < nlen) {
      unsafe {
        b = pipeline_module_struct_layout_name_byte_at(m, k, j);
      }
      if (b != (name[j] as i32)) {
        return 0;
      }
      j = j + 1;
    }
    return 1;
  }
  // Suffix: name[nlen - ln - 1] == '.' and the tail equals the layout name.
  if (nlen > ln + 1) {
    ch = name[nlen - ln - 1] as i32;
    if (ch == 46) {
      j = 0;
      while (j < ln) {
        unsafe {
          b = pipeline_module_struct_layout_name_byte_at(m, k, j);
        }
        if (b != (name[nlen - ln + j] as i32)) {
          return 0;
        }
        j = j + 1;
      }
      return 1;
    }
  }
  return 0;
}

/**
 * Byte size of a type. Strong link of glue_type_size_simple.
 * Scalar, array, slice, and SIMD paths match runtime_pipeline_abi.x.
 * TYPE_NAMED uses named_size_layout_matches_c, including imported modules.
 * The current-module hit passes the caller's arena. A dep hit passes that
 * dep module and that dep arena. A non-SIMD miss stays 4.
 * @param m *u8 — Module*; null skips the current-module layout walk
 * @param a *u8 — ASTArena*; null returns 0
 * @param ty_ref i32 — type ref; must be in 1 .. arena type count
 * @param depth i32 — recursion depth; above 64 returns 0
 * @return i32 — byte size; 0 on miss of a non-named type, 4 on a named miss
 * The egg weak body still exact-matches and is not the linked body.
 * PLATFORM: SHARED — Linux first-wins, Darwin weak egg, Windows weaken.
 */
#[no_mangle]
export function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32 {
  let kind_ord: i32 = 0;
  let nt: i32 = 0;
  let elem_ref: i32 = 0;
  let asz: i32 = 0;
  let es: i32 = 0;
  let soa_sz: i32 = 0;
  let vl: i32 = 0;
  let ves: i32 = 0;
  let name: u8[256] = [];
  let nlen: i32 = 0;
  let k: i32 = 0;
  let nlayouts: i32 = 0;
  let di: i32 = 0;
  let nd: i32 = 0;
  let dm: *u8 = 0 as *u8;
  let da: *u8 = 0 as *u8;
  let dep: *u8 = 0 as *u8;
  let sz: i32 = 0;
  let vok: i32 = 1;
  if (a == (0 as *u8) || ty_ref <= 0 || depth > 64) {
    return 0;
  }
  unsafe {
    nt = pipeline_arena_num_types(a);
  }
  if (ty_ref > nt) {
    return 0;
  }
  unsafe {
    kind_ord = pipeline_type_kind_ord_at(a, ty_ref);
  }
  // UNIT=16
  if (kind_ord == 16) {
    return 0;
  }
  // bool=2
  if (kind_ord == 2) {
    return 1;
  }
  // i32=0 u32=3 u8=1 f32=14 are 4 bytes. TYPE_VECTOR=13 is not a scalar.
  if (kind_ord == 0 || kind_ord == 3 || kind_ord == 1 || kind_ord == 14) {
    return 4;
  }
  // i64/u64/usize/isize/ptr/f64/TYPE_FN: 5,4,6,7,15,9,18 are 8 bytes.
  if (kind_ord == 5 || kind_ord == 4 || kind_ord == 6 || kind_ord == 7 || kind_ord == 15
      || kind_ord == 9 || kind_ord == 18) {
    return 8;
  }
  // SLICE=11 is 16 bytes.
  if (kind_ord == 11) {
    return 16;
  }
  // ARRAY=10 LINEAR=12 TYPE_VECTOR=13 are N times the element size.
  if (kind_ord == 10 || kind_ord == 12 || kind_ord == 13) {
    unsafe {
      elem_ref = pipeline_type_elem_ref_at(a, ty_ref);
      asz = pipeline_type_array_size_at(a, ty_ref);
    }
    if (elem_ref <= 0 || asz <= 0) {
      // TYPE_VECTOR without array_size: lanes*esz, not the 0 to 8 byte floor.
      // This TU sees the helper as extern, so the call stays inside unsafe.
      if (kind_ord == 13) {
        unsafe {
          vok = glue_vector_type_lanes_esz_c(a, ty_ref, &vl, &ves);
        }
        if (vok == 0 && vl > 0 && ves > 0) {
          return vl * ves;
        }
      }
      return 0;
    }
    // SoA only for fixed ARRAY (not SIMD VECTOR).
    if (kind_ord == 10 || kind_ord == 12) {
      unsafe {
        soa_sz = typeck_soa_array_storage_size_glue(m, a, elem_ref, asz, depth + 1);
      }
      if (soa_sz > 0) {
        return soa_sz;
      }
    }
    es = glue_type_size_simple(m, a, elem_ref, depth + 1);
    if (es > 0) {
      return asz * es;
    }
    return 0;
  }
  // TYPE_NAMED=8
  if (kind_ord == 8) {
    unsafe {
      nlen = pipeline_type_named_name_into(a, ty_ref, &name[0]);
    }
    if (nlen <= 0 || nlen > 255) {
      return 4;
    }
    if (m != (0 as *u8)) {
      unsafe {
        nlayouts = pipeline_module_num_struct_layouts_at(m);
      }
      k = 0;
      while (k < nlayouts) {
        // Qualified TYPE_NAMED (token.Token) shares the mega suffix rule.
        if (named_size_layout_matches_c(m, k, &name[0], nlen) != 0) {
          unsafe {
            return typeck_x_type_size_from_layout_glue(m, a, k, depth + 1);
          }
        }
        k = k + 1;
      }
    }
    // Dep layout. Field type_refs are that module's arena indices.
    // A qualified name matches the layout's last segment.
    unsafe {
      dep = pipeline_asm_emit_dep_pipe_c();
    }
    if (dep != (0 as *u8)) {
      unsafe {
        nd = pipeline_dep_ctx_ndep(dep);
      }
      di = 0;
      while (di < nd) {
        unsafe {
          dm = pipeline_dep_ctx_module_at(dep, di);
          da = pipeline_dep_ctx_arena_at(dep, di);
        }
        if (dm != (0 as *u8) && da != (0 as *u8)) {
          unsafe {
            nlayouts = pipeline_module_num_struct_layouts_at(dm);
          }
          k = 0;
          while (k < nlayouts) {
            if (named_size_layout_matches_c(dm, k, &name[0], nlen) != 0) {
              unsafe {
                sz = typeck_x_type_size_from_layout_glue(dm, da, k, depth + 1);
              }
              if (sz > 0) {
                return sz;
              }
            }
            k = k + 1;
          }
        }
        di = di + 1;
      }
    }
    // No struct layout: SIMD named spelling is lanes*esz. Non-SIMD named stay 4.
    // Same extern call as above: unsafe here, branch outside.
    unsafe {
      vok = glue_vector_type_lanes_esz_c(a, ty_ref, &vl, &ves);
    }
    if (vok == 0 && vl > 0 && ves > 0) {
      return vl * ves;
    }
    return 4;
  }
  return 0;
}
