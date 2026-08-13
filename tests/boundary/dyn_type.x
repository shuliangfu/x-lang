// Isolated green: type-position `dyn Trait` must parse (not silently drop
// the function). `take` is unused so a missing body cannot fake the result;
// -E must still contain `take`. Neighborhood: dyn_type_let / dyn_type_ptr /
// impl_type.
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
function take(x: dyn Clone): i32 { return 7; }
function main(): i32 {
  return 7;
}
