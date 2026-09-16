// 10.3.1 slice8: TYPE_FN as function param — host-C `Ret (*f)(T)`.
// Acceptance: -E emits named fnptr formal; host-cc builds; run exits 42.
// PLATFORM: SHARED host-C (asm path covered by fn_type_param_smoke).

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

/**
 * Apply a TYPE_FN formal via indirect call (host-C callable declarator).
 * @param f function(i32): i32
 * @param x i32
 * @return i32 — f(x)
 * PLATFORM: SHARED.
 */
function apply(f: function(i32): i32, x: i32): i32 {
  return f(x);
}

function main(): i32 {
  return apply(helper_add_one, 41);
}
