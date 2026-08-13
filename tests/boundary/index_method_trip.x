// Isolated green: 12B INDEX rvalue + method (4.2.15 dual-GP).
// emit_index 9–16B must *addr → rax+rdx, not leave-addr.
// PLATFORM: SHARED — Ubuntu gold typeck + emit.

struct Trip {
  a: i32
  b: i32
  c: i32
}

impl Trip {
  /**
   * Last field of a 12B receiver (offset 8 lives in rdx).
   * @param self Trip — copied dual-GP receiver
   * @return i32 — self.c
   */
  function last(self: Trip): i32 {
    return self.c;
  }
}

/**
 * CALL-arg neighborhood of INDEX Trip (same rvalue emit).
 * @param t Trip — by-value INTEGER class
 * @return i32 — t.c
 */
function take_t(t: Trip): i32 {
  return t.c;
}

/**
 * Probe: INDEX method / take / let of 12B Trip.
 * @return i32 — 0 ok; 1..4 name the miss
 */
function main(): i32 {
  let a: [2]Trip = [Trip { a: 1, b: 2, c: 3 }, Trip { a: 4, b: 5, c: 42 }];
  if (a[1].last() != 42) { return 1; }
  if (take_t(a[1]) != 42) { return 2; }
  let t: Trip = a[1];
  if (t.c != 42) { return 3; }
  if (t.last() != 42) { return 4; }
  return 0;
}
