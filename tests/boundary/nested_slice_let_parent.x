// dest-SLICE let of same-block const / parent const / parent let.
// try_emit VAR used to scan only prior lets then resolved TYPE_ARRAY;
// typeck stamps dest-SLICE to TYPE_SLICE so N is hidden and wrap misses.
// INDEX consume so a missing length cannot fake-green.
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold typeck + host-C / asm emit.

/**
 * Exit 42 when dest-SLICE lets of same-block const / parent const / parent
 * let wrap, plus ARRAY_LIT wrap of a parent const.
 * @return i32 — 42 ok, else the failing check
 */
function main(): i32 {
  const a: [2]i32 = [10, 32];
  let b: [2]i32 = [1, 2];
  let s0: []i32 = a;
  if (s0.length != 2) { return 1; }
  if (s0[0] != 10) { return 2; }
  if (s0[1] != 32) { return 3; }

  if (1 != 0) {
    let s1: []i32 = a;
    if (s1.length != 2) { return 4; }
    if (s1[0] != 10) { return 5; }
    if (s1[1] != 32) { return 6; }

    let s2: []i32 = b;
    if (s2.length != 2) { return 7; }
    if (s2[0] != 1) { return 8; }
    if (s2[1] != 2) { return 9; }

    let ss: [1][]i32 = [a];
    if (ss[0].length != 2) { return 10; }
    if (ss[0][0] != 10) { return 11; }
    if (ss[0][1] != 32) { return 12; }
  }

  return 42;
}
