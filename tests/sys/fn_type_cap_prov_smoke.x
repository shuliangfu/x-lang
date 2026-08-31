// 10.3.1 slice9: Cap provenance hard-reject wrong TYPE_FN from recoverable Cap.
// Positive: Cap local from `helper as *u8` → matching TYPE_FN → 42.
// Negatives: wrong arity via Cap local / `as *u8` (expect typeck fail).
// PLATFORM: SHARED.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

function main(): i32 {
  let c: *u8 = helper_add_one as *u8;
  let f: function(i32): i32 = c;
  return f(41);
}
