// dest-SLICE let of non-VAR FIELD base: W{}.xs / mk().xs / rows[i].xs.
// try_emit used to require VAR base and assign a C array to a slice
// (run=1 / SEGV). Same helper wraps STRUCT_LIT / CALL / INDEX.
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold typeck + host-C / asm emit.

struct W {
  xs: [2]i32
}

/**
 * Return a W so let s = mk().xs exercises CALL.field dest-SLICE.
 * @return W — xs = [3, 4]
 */
function mk(): W {
  return { xs: [3, 4] };
}

/**
 * Exit 42 when dest-SLICE lets of STRUCT_LIT / CALL / INDEX / VAR field wrap.
 * @return i32 — 42 ok, else the failing check
 */
function main(): i32 {
  let s0: []i32 = { xs: [1, 2] }.xs;
  if (s0.length != 2) { return 1; }
  if (s0[0] != 1) { return 2; }
  if (s0[1] != 2) { return 3; }

  let s1: []i32 = mk().xs;
  if (s1.length != 2) { return 4; }
  if (s1[0] != 3) { return 5; }
  if (s1[1] != 4) { return 6; }

  let rows: [2]W = [{ xs: [5, 6] }, { xs: [7, 8] }];
  let s2: []i32 = rows[1].xs;
  if (s2.length != 2) { return 7; }
  if (s2[0] != 7) { return 8; }
  if (s2[1] != 8) { return 9; }

  let w: W = { xs: [10, 11] };
  let s3: []i32 = w.xs;
  if (s3.length != 2) { return 10; }
  if (s3[0] != 10) { return 11; }

  let ss: [1][]i32 = [{ xs: [20, 22] }.xs];
  if (ss[0].length != 2) { return 12; }
  if (ss[0][0] != 20) { return 13; }
  if (ss[0][1] != 22) { return 14; }

  return 42;
}
