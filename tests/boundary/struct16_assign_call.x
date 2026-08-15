// Isolated: 16B struct assign dest after X-to-X CALL (`y = id16(x)`).
// Let-init `let y = id16(x)` already stores rax+rdx via store_retval_pair.
// VAR assign used to store only rax, so y.b stayed 0 (exit 2).
// Nested dest-across-call (outer assigns inner, caller assigns outer) is
// the same store. Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail without dual-GP.

allow(padding) struct Pair {
  a: i64
  b: i64
}

/**
 * Identity on a 16B INTEGER-class struct (AAPCS64 / SysV dual-GP).
 * @param p Pair — lo in x0/rdi, hi in x1/rsi
 * @return Pair — same pair in x0+x1 / rax+rdx
 */
function id16(p: Pair): Pair {
  return p;
}

/**
 * Inner 16B transform used by the nested assign probe.
 * @param p Pair — input
 * @return Pair — {a+1, b+2}
 */
function inner(p: Pair): Pair {
  return Pair { a: p.a + 1, b: p.b + 2 };
}

/**
 * Nested dest-across-call: assign inner into a local, then return it.
 * @param p Pair — input
 * @return Pair — inner(p)
 */
function outer(p: Pair): Pair {
  let t: Pair = Pair { a: 0, b: 0 };
  t = inner(p);
  return t;
}

/**
 * Exit 0 when assign dest writes both 8B halves (not only lo).
 * @return i32 — 0 ok; 1..2 simple assign; 3..4 nested assign
 */
function main(): i32 {
  let x: Pair = Pair { a: 11, b: 22 };
  let y: Pair = Pair { a: 0, b: 0 };
  y = id16(x);
  if (y.a != 11) { return 1; }
  if (y.b != 22) { return 2; }
  let z: Pair = Pair { a: 0, b: 0 };
  z = outer(x);
  if (z.a != 12) { return 3; }
  if (z.b != 24) { return 4; }
  return 0;
}
