// Isolated green: 16B INDEX rvalue + method (4.2.15 dual-GP).
// emit_index 9–16B must *addr → rax+rdx, not leave-addr.
// PLATFORM: SHARED — Ubuntu gold typeck + emit.

struct Quad {
  a: i32
  b: i32
  c: i32
  d: i32
}

impl Quad {
  /**
   * Last field of a 16B receiver (offset 12 lives in rdx).
   * @param self Quad — copied dual-GP receiver
   * @return i32 — self.d
   */
  function last(self: Quad): i32 {
    return self.d;
  }
}

/**
 * CALL-arg neighborhood of INDEX Quad (same rvalue emit).
 * @param q Quad — by-value INTEGER class
 * @return i32 — q.d
 */
function take_q(q: Quad): i32 {
  return q.d;
}

/**
 * Probe: INDEX method / take / let of 16B Quad.
 * @return i32 — 0 ok; 1..4 name the miss
 */
function main(): i32 {
  let a: [2]Quad = [Quad { a: 1, b: 2, c: 3, d: 4 }, Quad { a: 5, b: 6, c: 7, d: 42 }];
  if (a[1].last() != 42) { return 1; }
  if (take_q(a[1]) != 42) { return 2; }
  let q: Quad = a[1];
  if (q.d != 42) { return 3; }
  if (q.last() != 42) { return 4; }
  return 0;
}
