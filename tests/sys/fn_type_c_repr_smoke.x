// 10.3.1 slice7: TYPE_FN host-C declarator `Ret (*name)(args)` via -E.
// Acceptance: -E succeeds; host-cc builds and run exits 42 (f(41) callable).
// PLATFORM: SHARED host-C.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

function main(): i32 {
  let f: function(i32): i32 = helper_add_one;
  return f(41);
}
