// Isolated green: concrete A -> dyn Clone coerce with impl Clone for A
// registered in the impl table. Fat-ptr shape: data = &a, vtable = NULL
// (F3 fills vtable). No method call on dyn yet (F3).
// Neighborhood: dyn_type_let.x (literal 0 null-dyn), dyn_coerce_fail.x.
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
struct A { v: i32 }
impl Clone for A { function clone(self: A): i32 { return self.v; } }
function main(): i32 {
  let a: A = { v: 7 };
  let x: Clone = a;
  return 7;
}
