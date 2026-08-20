// Isolated: assign whose INDEX base is a METHOD/CALL SIMD result.
// Twin of tests/boundary/index_on_method.x (rvalue INDEX already green).
// Documented leftover after asm INDEX-on-METHOD SIMD:
// `add4(...)[0] = k` / `v[0] = add4(...)[0]` — rbx dest vs rhs in rax.
// Do not reopen dest-SLICE / nest>16 / TYPE_DYN / 4.2.4–5 / 4.2.7.
// Expected: compile = 0, run = 0 (host-C + asm).
// PLATFORM: SHARED — Ubuntu gold assign INDEX-on-METHOD.

const simd = import("std.simd");

/**
 * Add two i32x4 values so CALL-then-INDEX assign can be compared to METHOD.
 * @param a i32x4 — left lanes
 * @param b i32x4 — right lanes
 * @return i32x4 — a + b
 */
function add4(a: i32x4, b: i32x4): i32x4 {
  return a + b;
}

/**
 * Exit 0 when assign-from INDEX of METHOD/CALL SIMD is honest.
 * Do not assign TO a CALL SIMD temp (`id4(...)[0] = k`): host-C emits a
 * non-lvalue vector subscript. That write-to-temp is discarded anyway.
 * Non-const extras block WPO fold so a wrong store cannot hide behind mov-imm.
 * @return i32 — 0 ok, else the failing case
 */
function main(): i32 {
  /* RHS is INDEX-on-CALL: emit_assign_rhs uses the rax helper (already green). */
  let x: i32 = 0;
  x = add4([1, 2, 3, 4], [10, 20, 30, 40])[0];
  if (x != 11) { return 1; }

  /* LHS VAR INDEX, RHS INDEX-on-CALL (generic assign: rhs→rax, dest→rbx). */
  let arr: [4]i32 = [0, 0, 0, 0];
  arr[0] = add4([1, 2, 3, 4], [10, 20, 30, 40])[0];
  if (arr[0] != 11) { return 2; }

  /* LHS VAR INDEX of a SIMD local (neighborhood: base is VAR, not CALL). */
  let v: i32x4 = add4([1, 2, 3, 4], [10, 20, 30, 40]);
  v[0] = 99;
  if (v[0] != 99) { return 3; }
  if (v[1] != 22) { return 4; }

  /* Same-layer METHOD twin as RHS into a local. */
  let z: i32 = 10;
  let f: f32 = 0.0;
  f = simd.add([1.0, 2.0, 3.0, 4.0], [z as f32, 20.0, 30.0, 40.0])[0];
  if (f != 11.0) { return 5; }

  /* Non-const CALL RHS so fold cannot mov-imm the store. */
  let y: i32 = 10;
  arr[1] = add4([1, 2, 3, 4], [y, 20, 30, 40])[0];
  if (arr[1] != 11) { return 6; }

  /* Index itself is INDEX-on-CALL: arr[add4(...)[0]] = k. */
  arr[add4([0, 2, 3, 4], [2, 20, 30, 40])[0]] = 77;
  if (arr[2] != 77) { return 7; }

  return 0;
}
