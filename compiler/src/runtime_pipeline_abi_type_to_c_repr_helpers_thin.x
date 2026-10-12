// Thin pure: host-C type_to_c_repr HELPERS leaf (cg_ttc_* + kind/vector/append).
// G.7: bodies MUST match the same symbols in runtime_pipeline_abi.x /
// runtime_pipeline_abi_type_to_c_repr_thin.x (full leaf keeps main).
// ensure: pipeline_abi_inject_type_to_c_repr_thin dispatches this on LINUX.
// wave412: LINUX PREFER helpers-only (full tip -c XT001 misattr @cg_ttc;
//   helpers-only -c green ~6100B; main body size/typeck still BAN tip reinject).
//   MACOS still injects full thin (helpers+main) PREFER.
// wave539 Soft Cap: drop 5 unused extern decls (tipU 0/5 → 0/0);
//   stamp w539 HARD BAN tip PRODUCT reinject (keep prior PREFER; stamp-only).
// PLATFORM: SHARED freestanding codegen · LINUX gold · MACOS.

function cg_ttc_write_bytes(dst: *u8, cap: i32, src: *u8, n: i32): i32 {
  if (dst == 0 as *u8) {
    return -1;
  }
  if (src == 0 as *u8) {
    return -1;
  }
  if (n <= 0) {
    return -1;
  }
  if (cap < n) {
    return -1;
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      dst[i] = src[i];
    }
    i = i + 1;
  }
  return n;
}

/**
 * Write a non-negative decimal integer at dst[off] (no NUL).
 * @param dst *u8 — destination; null → -1
 * @param cap i32 — destination capacity
 * @param off i32 — start offset; must be >= 0
 * @param v i32 — value; v < 0 treated as 0
 * @return i32 — offset after the last written digit, or -1 on overflow
 * PLATFORM: SHARED — type_to_c ARRAY tag `xlang_arr<N>_…`.
 */
function cg_ttc_write_uint_at(dst: *u8, cap: i32, off: i32, v: i32): i32 {
  if (dst == 0 as *u8 || cap <= 0 || off < 0 || off >= cap) {
    return -1;
  }
  let n: i32 = v;
  if (n < 0) {
    n = 0;
  }
  let tmp: u8[16] = [];
  let tlen: i32 = 0;
  if (n == 0) {
    tmp[0] = 48;
    tlen = 1;
  } else {
    while (n > 0 && tlen < 16) {
      let d: i32 = n - (n / 10) * 10;
      tmp[tlen] = (48 + d) as u8;
      tlen = tlen + 1;
      n = n / 10;
    }
  }
  if (off + tlen > cap) {
    return -1;
  }
  let i: i32 = 0;
  while (i < tlen) {
    unsafe {
      dst[off + i] = tmp[tlen - 1 - i];
    }
    i = i + 1;
  }
  return off + tlen;
}

/**
 * TypeKind builtin -> C type name into dst (no NUL).
 * @param dst *u8 - destination buffer
 * @param cap i32 - capacity
 * @param kind i32 - TypeKind ordinal (0..16); 8..13 compound kinds return -1
 * @return i32 - byte count, or -1 if unsupported / overflow
 * wave109 pure: G.7 single product authority (was type_kind_cstr+copy).
 * PLATFORM: SHARED - F32/F64/VOID ordinals match ast.x TypeKind (wave618).
 */
export function pipeline_codegen_type_kind_copy(dst: *u8, cap: i32, kind: i32): i32 {
  if (kind == 0) {
    return cg_ttc_write_bytes(dst, cap, "int32_t", 7);
  }
  if (kind == 1) {
    return cg_ttc_write_bytes(dst, cap, "int", 3);
  }
  if (kind == 2) {
    return cg_ttc_write_bytes(dst, cap, "uint8_t", 7);
  }
  if (kind == 3) {
    return cg_ttc_write_bytes(dst, cap, "uint32_t", 8);
  }
  if (kind == 4) {
    return cg_ttc_write_bytes(dst, cap, "uint64_t", 8);
  }
  if (kind == 5) {
    return cg_ttc_write_bytes(dst, cap, "int64_t", 7);
  }
  if (kind == 6) {
    return cg_ttc_write_bytes(dst, cap, "size_t", 6);
  }
  if (kind == 7) {
    return cg_ttc_write_bytes(dst, cap, "ssize_t", 7);
  }
  // 8..13: NAMED/PTR/ARRAY/SLICE/LINEAR/VECTOR handled in type_to_c_repr
  if (kind == 14) {
    return cg_ttc_write_bytes(dst, cap, "float", 5);
  }
  if (kind == 15) {
    return cg_ttc_write_bytes(dst, cap, "double", 6);
  }
  if (kind == 16) {
    return cg_ttc_write_bytes(dst, cap, "void", 4);
  }
  return -1;
}

/**
 * VECTOR type C name into dst (elem_kind x lanes).
 * @param dst *u8 - destination buffer
 * @param cap i32 - capacity
 * @param elem_kind i32 - ord_i32=0 / ord_u32=3 / ord_f32=14
 * @param lanes i32 - 4 / 8 / 16
 * @return i32 - byte count, or -1 if no match / overflow
 * wave109 pure: G.7 single product authority (was vector_type_cstr+copy).
 * PLATFORM: SHARED.
 */
export function pipeline_codegen_vector_type_copy(dst: *u8, cap: i32, elem_kind: i32, lanes: i32): i32 {
  if (elem_kind == 0) {
    if (lanes == 4) {
      return cg_ttc_write_bytes(dst, cap, "i32x4_t", 7);
    }
    if (lanes == 8) {
      return cg_ttc_write_bytes(dst, cap, "i32x8_t", 7);
    }
    if (lanes == 16) {
      return cg_ttc_write_bytes(dst, cap, "i32x16_t", 8);
    }
  }
  if (elem_kind == 3) {
    if (lanes == 4) {
      return cg_ttc_write_bytes(dst, cap, "u32x4_t", 7);
    }
    if (lanes == 8) {
      return cg_ttc_write_bytes(dst, cap, "u32x8_t", 7);
    }
    if (lanes == 16) {
      return cg_ttc_write_bytes(dst, cap, "u32x16_t", 8);
    }
  }
  // F32 vector (Vec4f / f32x4 / f32x8 / f32x16). elem_kind=14 == ord_f32.
  if (elem_kind == 14) {
    if (lanes == 4) {
      return cg_ttc_write_bytes(dst, cap, "f32x4_t", 7);
    }
    if (lanes == 8) {
      return cg_ttc_write_bytes(dst, cap, "f32x8_t", 7);
    }
    if (lanes == 16) {
      return cg_ttc_write_bytes(dst, cap, "f32x16_t", 8);
    }
  }
  return -1;
}

/**
 * Append TypeKind C name onto scratch[w..); return next write index.
 * @param scratch *u8 - scratch buffer
 * @param cap i32 - capacity
 * @param w i32 - current write index
 * @param kind i32 - TypeKind ordinal
 * @return i32 - next write index, or -1 on overflow / unsupported
 * wave109 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
export function pipeline_codegen_type_kind_append(scratch: *u8, cap: i32, w: i32, kind: i32): i32 {
  let tmp: u8[16] = [];
  let n: i32 = pipeline_codegen_type_kind_copy(&tmp[0], 16, kind);
  if (n <= 0) {
    return -1;
  }
  if (scratch == 0 as *u8) {
    return -1;
  }
  let i: i32 = 0;
  while (i < n) {
    if (w >= cap - 1) {
      return -1;
    }
    unsafe {
      scratch[w] = tmp[i];
    }
    w = w + 1;
    i = i + 1;
  }
  return w;
}
