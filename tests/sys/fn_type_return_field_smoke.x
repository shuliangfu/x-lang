// 10.3.3 slice1: TYPE_FN as return value.
// Opaque Cap-fn-ptr ABI — bare name / Cap *u8 coerce onto TYPE_FN return;
// TYPE_FN value may return as Cap *u8. Field layout/call residual → slice2.
// Expect run=42. PLATFORM: SHARED.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

/**
 * Return a TYPE_FN value (bare name → Cap *u8 → TYPE_FN return coerce).
 * @return function(i32): i32
 * PLATFORM: SHARED.
 */
function get_fn(): function(i32): i32 {
  return helper_add_one;
}

/**
 * Cap *u8 return twin — exercises TYPE_FN local → *u8 return coerce.
 * @param f function(i32): i32
 * @return *u8
 * PLATFORM: SHARED.
 */
function as_cap(f: function(i32): i32): *u8 {
  return f;
}

function main(): i32 {
  let f: function(i32): i32 = get_fn();
  if (f(41) != 42) {
    return 2;
  }
  let c: *u8 = as_cap(f);
  return c(41);
}
