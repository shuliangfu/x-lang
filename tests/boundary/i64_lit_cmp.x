// Wide i64 INT_LIT must not ride the i32-imm fast path (2^32 low half is 0).
// PLATFORM: SHARED — mov_imm32 zero-extends on SysV x86_64 and AAPCS64.

/**
 * i64 compare / add against a wide literal plus i32-fit neighborhood.
 * @return i32 — 0 on success; 1..8 name the failed assertion
 */
function main(): i32 {
  let a: i64 = 4294967296;
  if (a != 4294967296) { return 1; }
  if (a == 0) { return 2; }

  let b: i64 = 4294967296;
  if (a != b) { return 3; }

  let p1: i64 = 4294967297;
  if (p1 != 4294967297) { return 4; }

  let one: i64 = 1;
  let s: i64 = one + 4294967296;
  let sh: i64 = s >> 32;
  if (sh != 1) { return 5; }

  let m: i64 = 2147483647;
  if (m != 2147483647) { return 6; }

  let x: i32 = 0 - 5;
  if (x != -5) { return 7; }
  if (x != 0 - 5) { return 8; }

  return 0;
}
