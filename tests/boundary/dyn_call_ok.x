// F3 positive: concrete A -> dyn Clone coerce with impl, then vtable dispatch
// of x.clone() through slot 0. A::clone returns self.v = 7.
// Neighborhood: dyn_coerce_ok.x (coerce only, no call), dyn_call_fail.x (bad
// method name -> typeck reject).
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
struct A { v: i32 }
impl Clone for A { function clone(self: A): i32 { return self.v; } }
function main(): i32 {
  let a: A = { v: 7 };
  let x: dyn Clone = a;
  return x.clone();
}
