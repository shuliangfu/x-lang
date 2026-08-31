// stage10 10.3.2: Cap-fn-ptr address-of + indirect call shapes.
// PLATFORM: SHARED — product xlang_asm -o; exit 42 on success.
// slice0: (fn as *u8); slice1: f(); slice2: f(arg); slice3: (*f)();
// slice4: stack arg beyond SysV GP (7th i32 on stack via emit_call_args).

#[no_mangle]
function helper_forty_two(): i32 {
  return 42;
}

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

#[no_mangle]
function helper_sum7(a: i32, b: i32, c: i32, d: i32, e: i32, f: i32, g: i32): i32 {
  return a + b + c + d + e + f + g;
}

function main(): i32 {
  let f0: *u8 = (helper_forty_two as *u8);
  let f1: *u8 = (helper_add_one as *u8);
  let f7: *u8 = (helper_sum7 as *u8);
  if (f0 == 0 as *u8) {
    return 2;
  }
  if (f1 == 0 as *u8) {
    return 3;
  }
  if (f7 == 0 as *u8) {
    return 7;
  }
  if (f0() != 42) {
    return 4;
  }
  if ((*f0)() != 42) {
    return 5;
  }
  if (f1(41) != 42) {
    return 6;
  }
  if ((*f1)(41) != 42) {
    return 8;
  }
  /* 1+2+3+4+5+6+21 = 42; 7th arg is stack on SysV x86_64. */
  return f7(1, 2, 3, 4, 5, 6, 21);
}
