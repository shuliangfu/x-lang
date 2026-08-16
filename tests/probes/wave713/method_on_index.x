// wave713 · 4.2.15 impl method on INDEX · valid X rewrite of the old Rust-syntax probe.
// Product gate: tests/boundary/index_method.x (and trip/quad dual-GP).
// Expected: return 0
// PLATFORM: SHARED — Ubuntu gold.

struct S { v: i32 }

impl S {
  /**
   * Inherent getter on INDEX receiver.
   * @param self S — copied receiver
   * @return i32 — self.v
   */
  function get(self: S): i32 { return self.v; }
  /**
   * Inherent adder on INDEX receiver.
   * @param self S — copied receiver
   * @param dx i32 — addend
   * @return i32 — self.v + dx
   */
  function add(self: S, dx: i32): i32 { return self.v + dx; }
}

function main(): i32 {
  let a: [2]S = [{ v: 10 }, { v: 32 }];
  let i: i32 = 1;
  let r1: i32 = a[i].get();
  let r2: i32 = a[0].add(5);
  let s: []S = [{ v: 1 }, { v: 2 }, { v: 3 }];
  let r3: i32 = s[2].get();
  let r4: i32 = a[1].add(s[0].get());
  return r1 + r2 + r3 + r4 - 83;
}
