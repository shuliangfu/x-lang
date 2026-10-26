// 10.44: i8 struct fields must pack at 1-byte stride / 1-byte stores.
// Pre-fix: align/size miss → 4, so {i8×4} stepped 0/4/8/12.
// Expected: compile = 0, run = 0.
// PLATFORM: SHARED — Ubuntu gold; Win deferred.

struct Pack4 {
  a: i8;
  b: i8;
  c: i8;
  d: i8;
}

/**
 * Exit 0 when i8 fields are dense (stride 1) and stores do not smash neighbors.
 * @return i32 — 0 ok; 100+diff = bad stride; 1..n = smash/value checks
 */
export function main(): i32 {
  let r: Pack4 = { a: 1, b: 2, c: 3, d: 4 };
  let pa: *i8 = &r.a;
  let pb: *i8 = &r.b;
  let pc: *i8 = &r.c;
  let diff_ab: i32 = ((pb as usize) - (pa as usize)) as i32;
  let diff_bc: i32 = ((pc as usize) - (pb as usize)) as i32;
  if (diff_ab != 1) {
    return 100 + diff_ab;
  }
  if (diff_bc != 1) {
    return 110 + diff_bc;
  }
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
  // 1B store at a must not clear b (4B store at 0 would).
  r.a = 0x11;
  if ((r.b as i32) != 0x77) {
    return 5;
  }
  if ((r.a as i32) != 0x11) {
    return 6;
  }
  r.d = 0x55;
  if ((r.c as i32) != 3) {
    return 7;
  }
  if ((r.d as i32) != 0x55) {
    return 8;
  }
  return 0;
}
