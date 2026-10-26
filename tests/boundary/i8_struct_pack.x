// 10.44: i8 struct fields must pack at 1-byte stride / 1-byte stores.
// Pre-fix: align/size miss → 4, so {i8×4} stepped 0/4/8/12 and a
// wide store at field b smashed neighbors (or left gaps).
// Expected: compile = 0, run = 0.
// PLATFORM: SHARED — Ubuntu gold; Win deferred.

allow(padding) struct Pack4 {
  a: i8;
  b: i8;
  c: i8;
  d: i8;
}

/**
 * Exit 0 when i8 fields are dense and byte stores do not smash neighbors.
 * @return i32 — 0 ok; 1..n = which check failed
 */
export function main(): i32 {
  let r: Pack4 = { a: 1, b: 2, c: 3, d: 4 };
  r.b = 0x77;
  if ((r.a as i32) != 1) {
    return 1;
  }
  if ((r.b as i32) != 0x77) {
    return 2;
  }
  if ((r.c as i32) != 3) {
    return 3;
  }
  if ((r.d as i32) != 4) {
    return 4;
  }
  // Store at a must not clear b (would if 4B write at offset 0).
  r.a = 0x11;
  if ((r.b as i32) != 0x77) {
    return 5;
  }
  if ((r.a as i32) != 0x11) {
    return 6;
  }
  // Store at d (offset 3 when packed) must not clobber c.
  r.d = 0x55;
  if ((r.c as i32) != 3) {
    return 7;
  }
  if ((r.d as i32) != 0x55) {
    return 8;
  }
  return 0;
}
