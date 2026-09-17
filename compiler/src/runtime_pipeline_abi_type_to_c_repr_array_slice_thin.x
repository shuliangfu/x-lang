// Thin pure: ttc ARRAY/SLICE tag writers (wave434).
// G.7: twin of type_to_c_repr main / mega.
// PRODUCT: LINUX PREFER; keep separate from NAMED thin (Ubuntu co-file XT001).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, ref: i32, out64: *u8): i32;
export extern function pipeline_codegen_type_to_c_repr(arena: *u8, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
export extern function cg_ttc_write_bytes(dst: *u8, cap: i32, src: *u8, n: i32): i32;
export extern function cg_ttc_write_uint_at(dst: *u8, cap: i32, off: i32, v: i32): i32;

/**
 * Strip leading "struct " and spaces from eb[0..n); return start index.
 */
function cg_ttc_strip_struct_prefix(eb: *u8, n: i32): i32 {
  unsafe {
    let sp: i32 = 0;
    let ch: u8 = 0;
    let out: i32 = 0;
    let hit: i32 = 0;
    let ok: i32 = 0;
    if (eb == 0 as *u8 || n < 7) {
      return 0;
    }
    unsafe {
      if (eb[0] == 115 && eb[1] == 116 && eb[2] == 114 && eb[3] == 117 && eb[4] == 99 && eb[5] == 116 && eb[6] == 32) {
        ok = 1;
      }
    }
    if (ok == 0) {
      return 0;
    }
    sp = 7;
    out = n;
    while (sp < n) {
      if (hit == 0) {
        unsafe {
          ch = eb[sp];
        }
        if (ch != 32) {
          hit = 1;
          out = sp;
        }
      }
      sp = sp + 1;
    }
    return out;
  }
}

/**
 * Append sanitized elem tag from eb[sp..n) into scratch starting at w.
 * Keep [A-Za-z0-9_]; map * → _p; skip spaces/brackets.
 * @return i32 — new write offset, or -1
 */
function cg_ttc_append_sanitized(scratch: *u8, cap: i32, w: i32, eb: *u8, sp: i32, n: i32): i32 {
  unsafe {
    let pi: i32 = sp;
    let ch: u8 = 0;
    let keep: i32 = 0;
    while (pi < n) {
      unsafe {
        ch = eb[pi];
      }
      if (ch == 42) {
        if (w + 2 >= cap) {
          return -1;
        }
        unsafe {
          scratch[w] = 95;
          scratch[w + 1] = 112;
        }
        w = w + 2;
      } else {
        keep = 0;
        if (ch >= 48 && ch <= 57) {
          keep = 1;
        }
        if (ch >= 65 && ch <= 90) {
          keep = 1;
        }
        if (ch >= 97 && ch <= 122) {
          keep = 1;
        }
        if (ch == 95) {
          keep = 1;
        }
        if (keep != 0) {
          if (w >= cap) {
            return -1;
          }
          unsafe {
            scratch[w] = ch;
          }
          w = w + 1;
        }
      }
      pi = pi + 1;
    }
    return w;
  }
}

#[no_mangle]
export function cg_ttc_write_array_tag(arena: *u8, scratch: *u8, cap: i32, elem_ref: i32, arr_sz: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  unsafe {
    let eb: u8[896] = [];
    let n_el: i32 = 0;
    let sp_el: i32 = 0;
    let w_ar: i32 = 0;
    let hdr_ar: u8[9] = [120, 108, 97, 110, 103, 95, 97, 114, 114];
    if (arr_sz <= 0) {
      return pipeline_codegen_type_to_c_repr(arena, scratch, cap, elem_ref, struct_prefix, struct_prefix_len);
    }
    n_el = pipeline_codegen_type_to_c_repr(arena, &eb[0], 896, elem_ref, struct_prefix, struct_prefix_len);
    if (n_el < 0 || n_el >= 896) {
      return -1;
    }
    sp_el = cg_ttc_strip_struct_prefix(&eb[0], n_el);
    if (9 >= cap) {
      return -1;
    }
    w_ar = 0;
    while (w_ar < 9) {
      unsafe {
        scratch[w_ar] = hdr_ar[w_ar];
      }
      w_ar = w_ar + 1;
    }
    w_ar = cg_ttc_write_uint_at(scratch, cap, w_ar, arr_sz);
    if (w_ar < 0 || w_ar + 1 >= cap) {
      return -1;
    }
    unsafe {
      scratch[w_ar] = 95;
    }
    w_ar = w_ar + 1;
    w_ar = cg_ttc_append_sanitized(scratch, cap, w_ar, &eb[0], sp_el, n_el);
    if (w_ar < 0 || w_ar <= 10) {
      return -1;
    }
    return w_ar;
  }
}

#[no_mangle]
export function cg_ttc_write_slice_tag(arena: *u8, scratch: *u8, cap: i32, elem_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  unsafe {
    let eb: u8[896] = [];
    let n: i32 = 0;
    let sp: i32 = 0;
    let plen: i32 = 0;
    let hi: i32 = 0;
    let w_sl: i32 = 0;
    let hdr: u8[19] = [115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95];
    n = pipeline_codegen_type_to_c_repr(arena, &eb[0], 896, elem_ref, struct_prefix, struct_prefix_len);
    if (n < 0 || n >= 896) {
      return -1;
    }
    sp = cg_ttc_strip_struct_prefix(&eb[0], n);
    plen = n - sp;
    if (plen <= 0 || 19 >= cap) {
      return -1;
    }
    hi = 0;
    while (hi < 19) {
      unsafe {
        scratch[hi] = hdr[hi];
      }
      hi = hi + 1;
    }
    w_sl = cg_ttc_append_sanitized(scratch, cap, 19, &eb[0], sp, n);
    if (w_sl < 0 || w_sl <= 19) {
      return -1;
    }
    return w_sl;
  }
}
