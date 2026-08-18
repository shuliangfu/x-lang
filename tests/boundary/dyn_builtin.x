// F6 host-C / F7-neighborhood asm: impl Trait for builtin (i32).
// Coerce `let x: dyn Clone = 7` must materialize a fat {data,vtable}
// whose data points at the i32 7 and whose vtable is the static
// xlang_vtable_Clone_for_i32. Dispatch x.clone() through slot 0.
// Neighborhood: dyn_call_ok.x (NAMED for-type), dyn_vtable_ptr_for.x.
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
impl Clone for i32 { function clone(self: i32): i32 { return self; } }
function main(): i32 {
  let x: dyn Clone = 7;
  return x.clone();
}
