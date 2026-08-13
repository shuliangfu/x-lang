// Isolated green: `let x: dyn Clone` must not drop main (was P001 no
// functions). Same type_ref peel as dyn_type.x. Init `0` matches the
// existing `let x: Clone = 0` path.
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
function main(): i32 {
  let x: dyn Clone = 0;
  return 7;
}
