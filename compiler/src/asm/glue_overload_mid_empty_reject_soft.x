// knife256/10.2: Cap tip dep empty type names → bare/false mid.
// Soft first-wins: if overload_count>1 but no '_' suffix was written,
// return -1 so import mangle falls back to caller-arg mid (entry types OK).
// PLATFORM: SHARED · MACOS Cap tip prepend.

export extern "C" function pipeline_asm_module_func_name_len_at(m: *u8, fi: i32): i32;
export extern "C" function pipeline_asm_module_func_name_copy64(m: *u8, fi: i32, dst: *u8): void;
export extern "C" function pipeline_module_func_num_params_at(m: *u8, fi: i32): i32;
export extern "C" function pipeline_module_func_param_type_ref_at(m: *u8, fi: i32, pi: i32): i32;
export extern "C" function pipeline_module_func_return_type_at(m: *u8, fi: i32): i32;
export extern "C" function glue_module_func_overload_count_c(m: *u8, name: *u8, nlen: i32): i32;
export extern "C" function glue_asm_type_ref_to_suffix_c(a: *u8, type_ref: i32, out: *u8, out_cap: i32): i32;
export extern "C" function glue_asm_overload_param_sig_count_c(a: *u8, m: *u8, func_ix: i32): i32;

#[no_mangle]
export function glue_asm_build_func_overload_mid_c(m: *u8, a: *u8, func_ix: i32, out: *u8, out_cap: i32): i32 {
  if (m == 0 as *u8) { return 0 - 1; }
  if (a == 0 as *u8) { return 0 - 1; }
  if (func_ix < 0) { return 0 - 1; }
  if (out == 0 as *u8) { return 0 - 1; }
  if (out_cap <= 0) { return 0 - 1; }
  unsafe {
    let fname_len: i32 = pipeline_asm_module_func_name_len_at(m, func_ix);
    if (fname_len <= 0) { return 0 - 1; }
    if (fname_len >= out_cap) { return 0 - 1; }
    if (fname_len > 255) { return 0 - 1; }
    let fname: u8[256] = [];
    pipeline_asm_module_func_name_copy64(m, func_ix, &fname[0]);
    let pos: i32 = 0;
    while (pos < fname_len) {
      out[pos] = fname[pos];
      pos = pos + 1;
    }
    let oc: i32 = glue_module_func_overload_count_c(m, &fname[0], fname_len);
    if (oc <= 1) {
      return pos;
    }
    let np: i32 = pipeline_module_func_num_params_at(m, func_ix);
    let pi: i32 = 0;
    let wrote: i32 = 0;
    while (pi < np) {
      if (pos >= out_cap - 2) { break; }
      let pty: i32 = pipeline_module_func_param_type_ref_at(m, func_ix, pi);
      if (pty > 0) {
        let suf: u8[64] = [];
        let sl: i32 = glue_asm_type_ref_to_suffix_c(a, pty, &suf[0], 64);
        if (sl > 0) {
          if (suf[0] == 0) {
            sl = 0;
          }
        }
        if (sl > 0) {
          if (pos + 1 + sl >= out_cap) { return 0 - 1; }
          out[pos] = 95;
          pos = pos + 1;
          let si: i32 = 0;
          while (si < sl) {
            out[pos] = suf[si];
            pos = pos + 1;
            si = si + 1;
          }
          wrote = 1;
        }
      }
      pi = pi + 1;
    }
    // No usable param suffixes (empty dep type names) → force caller-arg mid.
    if (wrote == 0) {
      return 0 - 1;
    }
    let sig_count: i32 = glue_asm_overload_param_sig_count_c(a, m, func_ix);
    if (sig_count > 1) {
      let ret_ref: i32 = pipeline_module_func_return_type_at(m, func_ix);
      if (ret_ref > 0) {
        let rsuf: u8[64] = [];
        let rsl: i32 = glue_asm_type_ref_to_suffix_c(a, ret_ref, &rsuf[0], 64);
        if (rsl > 0) {
          if (rsuf[0] == 0) { rsl = 0; }
        }
        if (rsl > 0) {
          if (pos + 4 + rsl >= out_cap) { return 0 - 1; }
          out[pos] = 95; pos = pos + 1;
          out[pos] = 114; pos = pos + 1;
          out[pos] = 101; pos = pos + 1;
          out[pos] = 116; pos = pos + 1;
          let ri: i32 = 0;
          while (ri < rsl) {
            out[pos] = rsuf[ri];
            pos = pos + 1;
            ri = ri + 1;
          }
          wrote = 1;
        }
      }
    }
    if (pos > 0) { return pos; }
  }
  return 0 - 1;
}
