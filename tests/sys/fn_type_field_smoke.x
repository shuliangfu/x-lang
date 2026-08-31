// 10.3.3 slice2: TYPE_FN as struct field (init + load + indirect call).
// Opaque Cap-fn-ptr ABI; TYPE_FN field is pointer-sized (glue_type_size=8).
// Expect run=42. PLATFORM: SHARED.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

/**
 * Holder with a TYPE_FN field (opaque fn-ptr layout).
 * PLATFORM: SHARED.
 */
struct Holder {
  f: function(i32): i32
}

function main(): i32 {
  /* Cap bare name → TYPE_FN field (struct-lit surface coerce). */
  let h0: Holder = Holder { f: helper_add_one };
  let g0: function(i32): i32 = h0.f;
  if (g0(41) != 42) {
    return 2;
  }
  /* TYPE_FN local → TYPE_FN field. */
  let p: function(i32): i32 = helper_add_one;
  let h1: Holder = Holder { f: p };
  let g1: function(i32): i32 = h1.f;
  if (g1(40) != 41) {
    return 3;
  }
  /* Direct field call through Cap blr. */
  return h1.f(41);
}
