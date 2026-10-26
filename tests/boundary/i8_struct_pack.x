// Knife 10.44: i8 struct fields must pack with 1-byte stride (not 4).
// Index through *u8 base — if align(i8)==4, store of `a` leaves padding at
// base[1] so reading base[1] != written `b`. allow(padding) alone is false-green.
struct Pack4 {
  a: i8;
  b: i8;
  c: i8;
  d: i8;
}

export function main(): i32 {
  let r: Pack4 = { a: 1, b: 2, c: 3, d: 4 };
  let base: *u8 = (&r) as *u8;
  let b0: i32 = (base[0]) as i32;
  let b1: i32 = (base[1]) as i32;
  let b2: i32 = (base[2]) as i32;
  let b3: i32 = (base[3]) as i32;
  if (b0 != 1) { return 1; }
  if (b1 != 2) { return 2; }
  if (b2 != 3) { return 3; }
  if (b3 != 4) { return 4; }
  // Wide store must not stomp neighbor: rewrite a after b is set.
  r.a = 7;
  if ((base[0] as i32) != 7) { return 5; }
  if ((base[1] as i32) != 2) { return 6; }
  return 0;
}
