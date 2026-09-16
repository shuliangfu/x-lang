// 10.3.1 slice12 NEG: ARRAY_LIT bare Cap onto wrong TYPE_FN arity must typeck-fail.
// Expect build!=0. PLATFORM: SHARED.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

function main(): i32 {
  /* helper is (i32)->i32; dest elems are (i32,i32)->i32 — hard reject. */
  let fs: [2]function(i32, i32): i32 = [helper_add_one, helper_add_one];
  return 0;
}
