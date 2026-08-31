// stage10 10.3.2: Cap-fn-ptr address-of + 0-arg indirect call (f()).
// PLATFORM: SHARED — product xlang_asm -o; exit 42 on success.
// slice0: (fn as *u8); slice1: call through *u8 (no TYPE_FN / no args yet).

#[no_mangle]
function helper_forty_two(): i32 {
  return 42;
}

function main(): i32 {
  let f: *u8 = (helper_forty_two as *u8);
  if (f == 0 as *u8) {
    return 2;
  }
  return f();
}
