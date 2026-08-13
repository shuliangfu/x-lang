// Isolated green: `*dyn Trait` pointee must peel (same type_ref as
// `dyn Trait`; STAR used to keep IDENT "dyn" and drop the function).
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
function take(x: *dyn Clone): i32 { return 7; }
function main(): i32 {
  return 7;
}
