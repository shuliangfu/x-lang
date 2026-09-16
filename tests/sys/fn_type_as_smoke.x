// 10.3.1: `as function(...)` Cap/TYPE_FN opaque fn-ptr cast.
// Cap *u8 → TYPE_FN and bare name → TYPE_FN (LEA); call-through → 42.
// PLATFORM: SHARED.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

function main(): i32 {
  /* Cap local → TYPE_FN via as (reinterpret; emit loads Cap). */
  let c: *u8 = helper_add_one;
  let f0: function(i32): i32 = c as function(i32): i32;
  if (f0(40) != 41) {
    return 2;
  }
  /* Bare no_mangle name → TYPE_FN via as (LEA). */
  let f1: function(i32): i32 = helper_add_one as function(i32): i32;
  if (f1(41) != 42) {
    return 3;
  }
  /* TYPE_FN → Cap *u8 via as (surface twin). */
  let c1: *u8 = f1 as *u8;
  return c1(41);
}
