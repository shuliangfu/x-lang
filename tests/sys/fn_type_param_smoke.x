// 10.3.3 slice0: TYPE_FN as function parameter + call-through.
// Grammar (H02): `function(...): Ret`. Opaque Cap-fn-ptr ABI — bare name /
// Cap *u8 / TYPE_FN value may bind a TYPE_FN formal; callee uses Cap blr.
// Expect run=42. PLATFORM: SHARED.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

/**
 * Apply a TYPE_FN formal to `x` (indirect call).
 * @param f function(i32): i32 — Cap-opaque fn pointer
 * @param x i32
 * @return i32 — f(x)
 * PLATFORM: SHARED.
 */
function apply(f: function(i32): i32, x: i32): i32 {
  return f(x);
}

function main(): i32 {
  /* Bare fn name → TYPE_FN formal (wave100 stamps Cap *u8; score coerces). */
  if (apply(helper_add_one, 41) != 42) {
    return 2;
  }
  /* Cap *u8 → TYPE_FN formal. */
  let c: *u8 = (helper_add_one as *u8);
  if (apply(c, 40) != 41) {
    return 3;
  }
  /* TYPE_FN local → TYPE_FN formal (exact / surface). */
  let p: function(i32): i32 = helper_add_one;
  if (apply(p, 39) != 40) {
    return 4;
  }
  /* TYPE_FN value → Cap *u8 formal (reverse opaque ABI). */
  return apply_cap(p, 41);
}

/**
 * Cap *u8 formal twin of apply — exercises TYPE_FN → *u8 call-arg coerce.
 * @param f *u8
 * @param x i32
 * @return i32
 * PLATFORM: SHARED.
 */
function apply_cap(f: *u8, x: i32): i32 {
  return f(x);
}
