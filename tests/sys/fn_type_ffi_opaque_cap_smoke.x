// 10.3.1 slice15: true Cap *u8 → TYPE_FN assign cast + Cap CALL cast (host-C).
// Shapes: (1) let f: function = c; f(41)  (2) direct c(41).
// Expect asm + -E host-cc run=42. PLATFORM: SHARED.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

function main(): i32 {
  let c: *u8 = helper_add_one as *u8;
  let f: function(i32): i32 = c;
  if (f(41) != 42) {
    return 1;
  }
  return c(41);
}
