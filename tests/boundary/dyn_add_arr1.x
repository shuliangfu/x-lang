// F7 leftover: skip-trait prefix `[N]T` extra (sit-red T001 impl match).
// Produce: param_slice_need_rb bailed on INT so `[2]i32` stayed SLICE vs impl ARRAY.
// G.7: complete the existing scanner (twin of wave436 `*[N]T`); no second parser.
// Expected: compile = 0, run = 7 (v + p[0] + p[1] = 1+2+4).
// Neighborhood: dyn_add.x (i32 extra), dyn_add_stack.x (6 extras).
// PLATFORM: SHARED — Ubuntu gold.

trait Sum1 {
  function sum1(self, p: [2]i32): i32;
}
struct A { v: i32 }
impl Sum1 for A {
  function sum1(self: A, p: [2]i32): i32 { return self.v + p[0] + p[1]; }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: dyn Sum1 = a;
  return x.sum1([2, 4]);
}
