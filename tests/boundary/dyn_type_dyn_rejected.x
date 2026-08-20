// P013: `dyn Trait` is not a second type-position path. Write the trait
// name (`let x: Clone = a`). Sticky hard-fail so an unused
// `take(x: dyn Clone)` cannot vanish while main stays green (old P001
// silent-drop hole).
// Expected: compile != 0, stderr contains P013.
// Neighborhood: dyn_type.x / dyn_type_implicit.x / dyn_type_let.x.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
function take(x: dyn Clone): i32 { return 7; }
function main(): i32 {
  return 7;
}
