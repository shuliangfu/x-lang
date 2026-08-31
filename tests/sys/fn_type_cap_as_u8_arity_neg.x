// 10.3.1 slice9 NEG: `bare as *u8` onto wrong TYPE_FN arity.
// Expect typeck fail (build != 0). PLATFORM: SHARED.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

function main(): i32 {
  let f: function(i32, i32): i32 = helper_add_one as *u8;
  return 0;
}
