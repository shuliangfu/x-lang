// Isolated green: type-position trait name is TYPE_DYN (`take(x: Clone)`).
// One path — do not write `dyn Clone`. `take` is unused so a missing body
// cannot fake the result; -E must still contain `take`. Neighborhood:
// dyn_type_let / dyn_type_ptr / dyn_type_implicit / impl_type.
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
function take(x: Clone): i32 { return 7; }
function main(): i32 {
  return 7;
}
