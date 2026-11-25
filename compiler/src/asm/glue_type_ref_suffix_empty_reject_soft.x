// knife256/10.2: Cap tip type_ref_to_suffix empty-reject soft.
// PLATFORM: SHARED · MACOS Cap tip prepend.
export extern "C" function pipeline_type_kind_ord_at(a: *u8, type_ref: i32): i32;
export extern "C" function pipeline_type_elem_ref_at(a: *u8, type_ref: i32): i32;
export extern "C" function pipeline_type_array_size_at(a: *u8, type_ref: i32): i32;
export extern "C" function pipeline_type_named_name_into(a: *u8, type_ref: i32, out: *u8): i32;

#[no_mangle]
export export function glue_type_kind_to_suffix_c(kind: i32, out: *u8, cap: i32): i32 {
  if (out == 0 as *u8) { return 0; }
  if (cap <= 0) { return 0; }
  let s0: u8 = 0; let s1: u8 = 0; let s2: u8 = 0; let s3: u8 = 0; let s4: u8 = 0;
  let slen: i32 = 0;
  if (kind == 0) { // TYPE_I32 — explicit, not default
    s0 = 105; s1 = 51; s2 = 50; slen = 3;
  } else if (kind == 5) { // i64
    s0 = 105; s1 = 54; s2 = 52; slen = 3;
  } else if (kind == 2) { // u8
    s0 = 117; s1 = 56; slen = 2;
  } else if (kind == 3) { // u32
    s0 = 117; s1 = 51; s2 = 50; slen = 3;
  } else if (kind == 4) { // u64
    s0 = 117; s1 = 54; s2 = 52; slen = 3;
  } else if (kind == 6) { // usize
    s0 = 117; s1 = 115; s2 = 105; s3 = 122; s4 = 101; slen = 5;
  } else if (kind == 7) { // isize
    s0 = 105; s1 = 115; s2 = 105; s3 = 122; s4 = 101; slen = 5;
  } else if (kind == 14) { // f32
    s0 = 102; s1 = 51; s2 = 50; slen = 3;
  } else if (kind == 15) { // f64
    s0 = 102; s1 = 54; s2 = 52; slen = 3;
  } else if (kind == 1) { // bool
    s0 = 98; s1 = 111; s2 = 111; s3 = 108; slen = 4;
  } else {
    return 0;
  }
  let i: i32 = 0;
  while (i < slen) {
    if (i >= cap - 1) { break; }
    if (i == 0) { out[i] = s0; }
    if (i == 1) { out[i] = s1; }
    if (i == 2) { out[i] = s2; }
    if (i == 3) { out[i] = s3; }
    if (i == 4) { out[i] = s4; }
    i = i + 1;
  }
  return slen;
}

#[no_mangle]
export function glue_asm_type_ref_to_suffix_c(a: *u8, type_ref: i32, out: *u8, out_cap: i32): i32 {
  if (a == 0 as *u8) { return 0; }
  if (type_ref <= 0) { return 0; }
  if (out == 0 as *u8) { return 0; }
  if (out_cap <= 0) { return 0; }
  unsafe {
    let tk: i32 = pipeline_type_kind_ord_at(a, type_ref);
    // TYPE_PTR = 9
    if (tk == 9) {
      let elem: i32 = pipeline_type_elem_ref_at(a, type_ref);
      let n: i32 = glue_asm_type_ref_to_suffix_c(a, elem, out, out_cap);
      if (n > 0) {
        if (n + 4 < out_cap) {
          out[n] = 95; // _
          out[n + 1] = 112; // p
          out[n + 2] = 116; // t
          out[n + 3] = 114; // r
          return n + 4;
        }
      }
      return n;
    }
    // TYPE_SLICE = 11 → <elem>_slc (std_fmt_println_u8_slc; wave687 C twin).
    if (tk == 11) {
      let elem_s: i32 = pipeline_type_elem_ref_at(a, type_ref);
      let ns: i32 = glue_asm_type_ref_to_suffix_c(a, elem_s, out, out_cap);
      if (ns > 0) {
        if (ns + 4 < out_cap) {
          out[ns] = 95; // _
          out[ns + 1] = 115; // s
          out[ns + 2] = 108; // l
          out[ns + 3] = 99; // c
          return ns + 4;
        }
      }
      return 0;
    }
    // TYPE_ARRAY = 10 → <elem>_aN (align codegen wave687).
    if (tk == 10) {
      let elem_a: i32 = pipeline_type_elem_ref_at(a, type_ref);
      let asz: i32 = pipeline_type_array_size_at(a, type_ref);
      let na: i32 = glue_asm_type_ref_to_suffix_c(a, elem_a, out, out_cap);
      if (na <= 0) { return 0; }
      if (asz <= 0) { return 0; }
      if (na + 2 >= out_cap) { return 0; }
      out[na] = 95; // _
      out[na + 1] = 97; // a
      na = na + 2;
      let digs: u8[8] = [];
      let nd: i32 = 0;
      let v: i32 = asz;
      while (v > 0) {
        if (nd >= 6) { break; }
        digs[nd] = ((v % 10) + 48) as u8;
        nd = nd + 1;
        v = v / 10;
      }
      if (nd <= 0) { return 0; }
      if (na + nd >= out_cap) { return 0; }
      let di: i32 = nd - 1;
      while (di >= 0) {
        out[na] = digs[di];
        na = na + 1;
        di = di - 1;
      }
      return na;
    }
    // TYPE_VECTOR = 13 → <elem>x<lanes> (f32x4 / i32x8). G.7 ≡ codegen_type_ref_to_suffix.
    // Root (run-perf-simd-xlangffle-select): without this, import METHOD mid skips the
    // vector param → U std_simd_shuffle_i32_a4 while host-C formal exports
    // std_simd_shuffle_f32x4_i32_a4 (BLD001). PLATFORM: SHARED pure-asm product.
    if (tk == 13) {
      let elem_v: i32 = pipeline_type_elem_ref_at(a, type_ref);
      let lanes: i32 = pipeline_type_array_size_at(a, type_ref);
      let ek: i32 = 0;
      let pos: i32 = 0;
      if (elem_v <= 0) { return 0; }
      if (lanes <= 0) { return 0; }
      ek = pipeline_type_kind_ord_at(a, elem_v);
      // TYPE_I32=0 → i32; TYPE_U32=3 → u32; TYPE_F32=14 → f32
      if (ek == 0) {
        if (out_cap < 4) { return 0; }
        out[0] = 105; out[1] = 51; out[2] = 50; pos = 3;
      } else if (ek == 3) {
        if (out_cap < 4) { return 0; }
        out[0] = 117; out[1] = 51; out[2] = 50; pos = 3;
      } else if (ek == 14) {
        if (out_cap < 4) { return 0; }
        out[0] = 102; out[1] = 51; out[2] = 50; pos = 3;
      } else {
        return 0;
      }
      if (pos >= out_cap) { return 0; }
      out[pos] = 120; // 'x'
      pos = pos + 1;
      if (lanes == 4) {
        if (pos >= out_cap) { return 0; }
        out[pos] = 52; // '4'
        return pos + 1;
      }
      if (lanes == 8) {
        if (pos >= out_cap) { return 0; }
        out[pos] = 56; // '8'
        return pos + 1;
      }
      if (lanes == 16) {
        if (pos + 1 >= out_cap) { return 0; }
        out[pos] = 49; // '1'
        out[pos + 1] = 54; // '6'
        return pos + 2;
      }
      return 0;
    }
    // NAMED / user types: prefer type name (String, StrView, Vec_u8, …).
    // knife256/10.2: Cap tip dep wrap smash can leave name_len>0 with zero
    // bytes → mid length_ (false len) → U _std_string_length_. Reject empty.
    let n2: i32 = pipeline_type_named_name_into(a, type_ref, out);
    if (n2 > 0) {
      if (n2 < out_cap) {
        if (out[0] == 0) {
          return 0;
        }
        let si: i32 = 0;
        while (si < n2) {
          if (out[si] == 46) { // '.'
            out[si] = 95;
          }
          si = si + 1;
        }
        return n2;
      }
    }
    return glue_type_kind_to_suffix_c(tk, out, out_cap);
  }
  return 0;
}
