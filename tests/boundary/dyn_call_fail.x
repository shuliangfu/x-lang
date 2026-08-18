// F3 negative: x.bogus() where trait Clone has no method bogus. Typeck
// slot lookup (xlang_skip_trait_method_slot_c) returns -1 -> compile reject.
// No codegen emitted; no vtable dispatch.
// Neighborhood: dyn_call_ok.x (valid method -> green), dyn_coerce_fail.x
// (missing impl -> coerce reject).
// Expected: compile != 0.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
struct A { v: i32 }
impl Clone for A { function clone(self: A): i32 { return self.v; } }
function main(): i32 {
  let a: A = { v: 7 };
  let x: dyn Clone = a;
  return x.bogus();
}
