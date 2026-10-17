// Two impl methods with the same name and signature were both spelled
// `module_g_reti32`. Darwin ld then asserts on duplicate atoms in one
// file, so `B.g()` never links. The impl owner is already stamped on
// the function slot. Append it only when the name is overloaded.
// A unique method keeps the previous spelling.
// PLATFORM: SHARED.

export extern "C" function glue_asm_build_func_export_sym_c_mega(
  m: *u8, a: *u8, func_ix: i32, out: *u8, out_cap: i32
): i32;
export extern "C" function glue_module_func_overload_count_c(m: *u8, name: *u8, nlen: i32): i32;
export extern "C" function pipeline_asm_module_func_name_len_at(m: *u8, fi: i32): i32;
export extern "C" function pipeline_asm_module_func_name_copy64(m: *u8, fi: i32, dst: *u8): void;
export extern "C" function pipeline_module_func_owner_copy(m: *u8, fi: i32, dst: *u8, cap: i32): i32;

/**
 * Spell a function's link name, plus `_Owner` when the name is shared.
 * @param m *u8 — module; null returns -1
 * @param a *u8 — arena; null returns -1
 * @param func_ix i32 — function slot; negative returns -1
 * @param out *u8 — caller buffer; null returns -1
 * @param out_cap i32 — capacity; the owner suffix must fit
 * @return i32 — spelled length, or -1
 * The previous builder supplies the module prefix and the param/return
 * suffix. Owner bytes come from the impl latch. One method named g is
 * unchanged. Two methods named g become `…_g_reti32_A` and `…_g_reti32_B`.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_asm_build_func_export_sym_c(
  m: *u8, a: *u8, func_ix: i32, out: *u8, out_cap: i32
): i32 {
  // PLATFORM: SHARED — owner suffix after the existing overload spelling.
  unsafe {
    let n: i32 = 0;
    let olen: i32 = 0;
    let nlen: i32 = 0;
    let i: i32 = 0;
    let fname: u8[256] = [];
    let own: u8[64] = [];
    n = glue_asm_build_func_export_sym_c_mega(m, a, func_ix, out, out_cap);
    if (n <= 0) {
      return n;
    }
    if (m == (0 as *u8)) {
      return n;
    }
    nlen = pipeline_asm_module_func_name_len_at(m, func_ix);
    if (nlen <= 0 || nlen > 255) {
      return n;
    }
    pipeline_asm_module_func_name_copy64(m, func_ix, &fname[0]);
    if (glue_module_func_overload_count_c(m, &fname[0], nlen) <= 1) {
      return n;
    }
    olen = pipeline_module_func_owner_copy(m, func_ix, &own[0], 63);
    if (olen <= 0) {
      return n;
    }
    if (n + 1 + olen >= out_cap) {
      return 0 - 1;
    }
    out[n] = 95;
    i = 0;
    while (i < olen) {
      out[n + 1 + i] = own[i];
      i = i + 1;
    }
    return n + 1 + olen;
  }
}
