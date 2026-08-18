// F5 PTR-to-NAMED for-type probe: impl Trait for *A with self: *A.
// Tests:
//   - impl registry captures for_ptr=1 for impl Trait for *A
//   - static vtable emitted with name xlang_vtable_Clone_for_Ptr_A
//   - coerce site references the static (fast path is_ptr=1)
//   - dispatch passes recv.data (a *A) to clone(self: *A)
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
struct A { v: i32 }
impl Clone for *A { function clone(self: *A): i32 { return self.v; } }
function main(): i32 {
  let a: A = { v: 7 };
  let p: *A = &a;
  let x: dyn Clone = p;
  return x.clone();
}
