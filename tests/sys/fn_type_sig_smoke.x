// 10.3.1 signature slice: hard-reject arity/ret/param mismatch.
// Positive: matching bare → TYPE_FN call-through → 42.
// Negatives compiled separately (expect typeck fail).
// PLATFORM: SHARED.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

function main(): i32 {
  /* Matching Cap bare → TYPE_FN. */
  let f: function(i32): i32 = helper_add_one;
  if (f(41) != 42) {
    return 2;
  }
  /* Matching TYPE_FN → TYPE_FN assign. */
  let f2: function(i32): i32 = f;
  if (f2(40) != 41) {
    return 3;
  }
  /* Matching as function. */
  let f3: function(i32): i32 = helper_add_one as function(i32): i32;
  return f3(41);
}
