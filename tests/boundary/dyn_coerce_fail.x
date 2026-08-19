// Isolated compile-fail: `let x: Clone = b` where B does NOT impl Clone.
// Typeck impl-lookup gate rejects; downstream type_refs_equal mismatch emits
// "expected dyn Clone, found B" diagnostic. No codegen.
// Neighborhood: dyn_coerce_ok.x (impl exists -> green).
// Expected: compile != 0, stderr contains "dyn Clone".
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
struct B { v: i32 }
function main(): i32 {
  let b: B = { v: 9 };
  let x: Clone = b;
  return 7;
}
