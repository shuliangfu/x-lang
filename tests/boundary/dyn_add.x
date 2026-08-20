// F7 extra-arg dyn dispatch: impl Trait method with one extra GP arg.
// `x.add(3)` must pack 3 into rsi/x1 after data in rdi/x0, then blr wrapper.
// Wrapper first arg stays data (trampoline only touches self).
// Neighborhood: dyn_call_ok.x (0 extra), dyn_builtin.x (0 extra, builtin).
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

trait Add {
  function add(self, k: i32): i32;
}
struct A { v: i32 }
impl Add for A {
  function add(self: A, k: i32): i32 { return self.v + k; }
}
function main(): i32 {
  let a: A = { v: 4 };
  let x: Add = a;
  return x.add(3);
}
