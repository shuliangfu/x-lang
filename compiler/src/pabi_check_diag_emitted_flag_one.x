// Official first-wins driver_check_diag_emitted_get compiles
// `p[0] != 0` as a compare of the flag *pointer* (low 32 bits)
// against 0, never loading the i32 at *p. The BSS address is
// never 0, so get always returns 1. note/reset store 1/0 into
// the local that holds the pointer, not *p. That is the official
// holds-indirect lowering of p[0] in a huge 0x1b8 frame, not a
// real diagnostic. After parse and typeck both return 0,
// rt_cp_step_pipeline's check-only arm then does
// `if (diag_em != 0) return 1`, and check_one_need_fallback_diag
// sees direct_diag=1 so CHK001 stays silent.
// Small-frame load/store so the slot is actually read and written.
// flag_slot itself (lea of the BSS word) stays official.
// PLATFORM: SHARED.

export extern function driver_check_diag_emitted_flag_slot(): *i32;

function flag_i32_load(p: *i32): i32 {
  if (p == (0 as *i32)) {
    return 0;
  }
  unsafe {
    return p[0];
  }
  return 0;
}

function flag_i32_store(p: *i32, v: i32): void {
  if (p == (0 as *i32)) {
    return;
  }
  unsafe {
    p[0] = v;
  }
}

#[no_mangle]
export function driver_check_diag_emitted_get(): i32 {
  let p: *i32 = 0 as *i32;
  let v: i32 = 0;
  unsafe {
    p = driver_check_diag_emitted_flag_slot();
    v = flag_i32_load(p);
  }
  if (v != 0) {
    return 1;
  }
  return 0;
}

#[no_mangle]
export function driver_check_diag_emitted_note(): void {
  unsafe {
    flag_i32_store(driver_check_diag_emitted_flag_slot(), 1);
  }
}

#[no_mangle]
export function driver_check_diag_emitted_reset(): void {
  unsafe {
    flag_i32_store(driver_check_diag_emitted_flag_slot(), 0);
  }
}
