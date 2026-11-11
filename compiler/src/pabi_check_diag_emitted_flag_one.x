// Official first-wins BSS flag accessors compile `p[0]` as the
// pointer itself: get compares the slot address (never 0) and
// set/note/reset store into the local that holds the pointer.
// That is holds-indirect lowering in a huge 0x1b8 frame, not a
// real flag value. Small-frame load/store actually read and write
// the i32 at *p. flag_slot functions themselves (lea of the BSS
// word) stay official. Covers the whole driver_* flag-slot family.
// PLATFORM: SHARED.

export extern function driver_check_diag_emitted_flag_slot(): *i32;
export extern function driver_check_only_flag_slot(): *i32;
export extern function driver_freestanding_flag_slot(): *i32;
export extern function driver_sanitize_address_flag_slot(): *i32;
export extern function driver_fmt_check_only_flag_slot(): *i32;
export extern function driver_x_pipeline_skip_typeck_flag_slot(): *i32;
export extern function driver_x_pipeline_skip_codegen_flag_slot(): *i32;
export extern function driver_skip_codegen_dep_0_flag_slot(): *i32;
export extern function driver_large_stack_thread_flag_slot(): *i32;
export extern function link_abi_getenv(name: *u8): *u8;

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

function flag_i32_nonzero(p: *i32): i32 {
  let v: i32 = 0;
  unsafe {
    v = flag_i32_load(p);
  }
  if (v != 0) {
    return 1;
  }
  return 0;
}

#[no_mangle]
export function driver_check_diag_emitted_get(): i32 {
  unsafe {
    return flag_i32_nonzero(driver_check_diag_emitted_flag_slot());
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

#[no_mangle]
export function driver_check_only_get(): i32 {
  unsafe {
    return flag_i32_nonzero(driver_check_only_flag_slot());
  }
  return 0;
}

#[no_mangle]
export function driver_check_only_set(v: i32): void {
  unsafe {
    flag_i32_store(driver_check_only_flag_slot(), v);
  }
}

#[no_mangle]
export function driver_fmt_check_only_get(): i32 {
  unsafe {
    return flag_i32_nonzero(driver_fmt_check_only_flag_slot());
  }
  return 0;
}

#[no_mangle]
export function driver_fmt_check_only_set(v: i32): void {
  unsafe {
    flag_i32_store(driver_fmt_check_only_flag_slot(), v);
  }
}

#[no_mangle]
export function driver_freestanding_get(): i32 {
  unsafe {
    return flag_i32_nonzero(driver_freestanding_flag_slot());
  }
  return 0;
}

#[no_mangle]
export function driver_freestanding_set(v: i32): void {
  unsafe {
    flag_i32_store(driver_freestanding_flag_slot(), v);
  }
}

#[no_mangle]
export function driver_x_pipeline_skip_typeck_get(): i32 {
  unsafe {
    return flag_i32_nonzero(driver_x_pipeline_skip_typeck_flag_slot());
  }
  return 0;
}

#[no_mangle]
export function driver_x_pipeline_skip_typeck_set(v: i32): void {
  unsafe {
    flag_i32_store(driver_x_pipeline_skip_typeck_flag_slot(), v);
  }
}

#[no_mangle]
export function driver_x_pipeline_skip_codegen_get(): i32 {
  unsafe {
    return flag_i32_nonzero(driver_x_pipeline_skip_codegen_flag_slot());
  }
  return 0;
}

#[no_mangle]
export function driver_x_pipeline_skip_codegen_set(v: i32): void {
  unsafe {
    flag_i32_store(driver_x_pipeline_skip_codegen_flag_slot(), v);
  }
}

#[no_mangle]
export function driver_skip_codegen_dep_0_get(): i32 {
  unsafe {
    return flag_i32_nonzero(driver_skip_codegen_dep_0_flag_slot());
  }
  return 0;
}

#[no_mangle]
export function driver_skip_codegen_dep_0_set(v: i32): void {
  unsafe {
    flag_i32_store(driver_skip_codegen_dep_0_flag_slot(), v);
  }
}

#[no_mangle]
export function driver_is_large_stack_thread(): i32 {
  unsafe {
    return flag_i32_nonzero(driver_large_stack_thread_flag_slot());
  }
  return 0;
}

#[no_mangle]
export function driver_large_stack_thread_mark(on: i32): void {
  unsafe {
    flag_i32_store(driver_large_stack_thread_flag_slot(), on);
  }
}

#[no_mangle]
export function driver_sanitize_address_set(v: i32): void {
  unsafe {
    flag_i32_store(driver_sanitize_address_flag_slot(), v);
  }
}

#[no_mangle]
export function driver_sanitize_address_get(): i32 {
  let v: i32 = 0;
  let e: *u8 = 0 as *u8;
  unsafe {
    v = flag_i32_nonzero(driver_sanitize_address_flag_slot());
  }
  if (v != 0) {
    return 1;
  }
  unsafe {
    e = link_abi_getenv("XLANG_SANITIZE_ADDRESS");
    if (e == (0 as *u8)) {
      return 0;
    }
    if (e[0] == 0) {
      return 0;
    }
    if (e[0] == 48) {
      return 0;
    }
  }
  return 1;
}
