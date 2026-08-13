// Isolated green: return-type `dyn Trait` must not drop the function.
// Body is a constant so a missing mk cannot fake main.
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
function mk(): dyn Clone { return 0; }
function main(): i32 {
  return 7;
}
