// Isolated green: `*Clone` pointee is PTR of TYPE_DYN (type-position
// trait name). Do not write `*dyn Clone` (P013). STAR used to keep IDENT
// "dyn" and drop the function.
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
function take(x: *Clone): i32 { return 7; }
function main(): i32 {
  return 7;
}
