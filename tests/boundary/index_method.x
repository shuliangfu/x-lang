// Isolated green: impl method on INDEX (4.2.15).
// 4B / 8B receivers plus slice INDEX; combo exit 0.
// PLATFORM: SHARED — Ubuntu gold typeck + emit.

struct S {
  v: i32
}

impl S {
  /**
   * Inherent getter used as INDEX receiver (a[i].get).
   * @param self S — copied receiver
   * @return i32 — self.v
   */
  function get(self: S): i32 {
    return self.v;
  }

  /**
   * Inherent adder used as INDEX receiver with an extra arg.
   * @param self S — copied receiver
   * @param dx i32 — addend
   * @return i32 — self.v + dx
   */
  function add(self: S, dx: i32): i32 {
    return self.v + dx;
  }
}

struct Pair {
  a: i32
  b: i32
}

impl Pair {
  /**
   * 8B INDEX receiver (esz==8 already loaded before this knife).
   * @param self Pair — copied receiver
   * @return i32 — self.b
   */
  function last(self: Pair): i32 {
    return self.b;
  }
}

/**
 * Probe: INDEX method on fixed array, slice, lit index, var index, extra arg.
 * @return i32 — 0 ok; 1..4 name the miss
 */
function main(): i32 {
  let a: [2]S = [{ v: 10 }, { v: 32 }];
  let i: i32 = 1;
  if (a[i].get() != 32) { return 1; }
  if (a[0].add(5) != 15) { return 2; }
  let s: []S = [{ v: 1 }, { v: 2 }, { v: 3 }];
  if (s[2].get() != 3) { return 3; }
  if (a[1].add(s[0].get()) != 33) { return 4; }
  let p: [2]Pair = [{ a: 1, b: 2 }, { a: 10, b: 42 }];
  if (p[1].last() != 42) { return 5; }
  return 0;
}
