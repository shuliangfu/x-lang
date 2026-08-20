// Isolated green: `let x: Clone = 0` (null-dyn sentinel) must not drop
// main (was P001 no functions). One path — type-position trait name.
// Writing `dyn Clone` is P013.
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
function main(): i32 {
  let x: Clone = 0;
  return 7;
}
