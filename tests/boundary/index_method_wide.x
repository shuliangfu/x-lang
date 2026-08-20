// Isolated green: >16B INDEX MEMORY consume (4.2.15 leftover).
// emit_index esz>16 leaves the element address; METHOD / take / let / return
// must memcpy from *rax (not treat the pointer as the first 8B).
// PLATFORM: SHARED — Ubuntu gold typeck + emit.

struct Wide {
  a: i32
  b: i32
  c: i32
  d: i32
  e: i32
}

impl Wide {
  /**
   * Last field of a 20B MEMORY-class receiver (offset 16 lives past dual-GP).
   * @param self Wide — copied MEMORY by-value receiver
   * @return i32 — self.e
   */
  function last(self: Wide): i32 {
    return self.e;
  }
}

/**
 * CALL-arg neighborhood of INDEX Wide (same MEMORY push).
 * @param w Wide — by-value MEMORY class
 * @return i32 — w.e
 */
function take_w(w: Wide): i32 {
  return w.e;
}

/**
 * Return neighborhood of INDEX Wide (sret memcpy from leave-addr).
 * @param a [2]Wide — fixed array
 * @return Wide — a[1] by value
 */
function ret_idx(a: [2]Wide): Wide {
  return a[1];
}

/**
 * Probe: INDEX method / take / let / return of 20B Wide.
 * @return i32 — 0 ok; 1..5 name the miss
 */
function main(): i32 {
  let a: [2]Wide = [
    { a: 1, b: 2, c: 3, d: 4, e: 5 },
    { a: 10, b: 20, c: 30, d: 40, e: 42 }
  ];
  if (a[1].last() != 42) { return 1; }
  if (take_w(a[1]) != 42) { return 2; }
  let w: Wide = a[1];
  if (w.e != 42) { return 3; }
  if (w.last() != 42) { return 4; }
  let r: Wide = ret_idx(a);
  if (r.e != 42) { return 5; }
  return 0;
}
