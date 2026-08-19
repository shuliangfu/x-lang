// F4 positive: multiple impls of the same trait coexist via per-impl statics.
// Two structs A and B both implement Clone; each gets its own vtable static
// (xlang_vtable_Clone_for_A and xlang_vtable_Clone_for_B). The coerce sites
// reference the matching static, so x.clone() and y.clone() dispatch through
// independent vtables to A::clone and B::clone respectively.
// Neighborhood: dyn_call_ok.x (single impl F3 regression), dyn_vtable_ptr_for.x
// (PTR receiver variant).
// Expected: compile = 0, run = 9 (A.v=4 + B.w=5).
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
struct A { v: i32 }
struct B { w: i32 }
impl Clone for A { function clone(self: A): i32 { return self.v; } }
impl Clone for B { function clone(self: B): i32 { return self.w; } }
function main(): i32 {
  let a: A = { v: 4 };
  let b: B = { w: 5 };
  let x: Clone = a;
  let y: Clone = b;
  return x.clone() + y.clone();
}
