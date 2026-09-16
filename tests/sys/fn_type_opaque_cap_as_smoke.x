// 10.3.1 slice16: opaque Cap→TYPE_FN via explicit `as function` escape.
// Null Cap has no recoverable fn; `as` asserts signature (do not call).
// PLATFORM: SHARED.

function main(): i32 {
  let c: *u8 = 0 as *u8;
  let f: function(i32): i32 = c as function(i32): i32;
  /* Binding only — calling null Cap would SEGV. */
  return 42;
}
