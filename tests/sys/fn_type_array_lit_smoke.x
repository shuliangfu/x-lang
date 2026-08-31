// 10.3.1 slice12: ARRAY_LIT bare Cap names → TYPE_FN elems (let + struct field).
// Coerce-only (INDEX/call of TYPE_FN array is residual). Expect run=42.
// PLATFORM: SHARED.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

/**
 * Holder with a fixed array of TYPE_FN fields.
 * PLATFORM: SHARED.
 */
struct Holder {
  fs: [2]function(i32): i32
}

function main(): i32 {
  /* Local let: bare same-module names as Cap *u8 → TYPE_FN elems. */
  let fs: [2]function(i32): i32 = [helper_add_one, helper_add_one];
  /* Struct field: same ARRAY_LIT coerce authority. */
  let h: Holder = Holder { fs: [helper_add_one, helper_add_one] };
  /* Keep fs/h live without INDEX/call (codegen residual). */
  if (fs[0] as *u8 == 0 as *u8) {
    return 2;
  }
  if (h.fs[0] as *u8 == 0 as *u8) {
    return 3;
  }
  return 42;
}
