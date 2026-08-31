// stage10 10.3.2: Cap-fn-ptr address-of + indirect call (0-arg and 1-arg).
// PLATFORM: SHARED — product xlang_asm -o; exit 42 on success.
// slice0: (fn as *u8); slice1: f(); slice2: f(arg) GP via spill+call_args+blr.

#[no_mangle]
function helper_forty_two(): i32 {
  return 42;
}

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

function main(): i32 {
  let f0: *u8 = (helper_forty_two as *u8);
  let f1: *u8 = (helper_add_one as *u8);
  if (f0 == 0 as *u8) {
    return 2;
  }
  if (f1 == 0 as *u8) {
    return 3;
  }
  if (f0() != 42) {
    return 4;
  }
  return f1(41);
}
