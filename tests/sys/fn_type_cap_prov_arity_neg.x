// 10.3.1 slice9 NEG: Cap local with recoverable fn → wrong TYPE_FN arity.
// Expect typeck fail (build != 0). PLATFORM: SHARED.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

function main(): i32 {
  let c: *u8 = helper_add_one as *u8;
  let f: function(i32, i32): i32 = c;
  return 0;
}
