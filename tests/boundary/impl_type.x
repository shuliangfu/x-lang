// Isolated green: type-position `impl Trait` (TOKEN_IMPL prefix) must
// parse. Same silent-drop hole as `dyn Trait` in type_ref.
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
function take(x: impl Clone): i32 { return 7; }
function main(): i32 {
  return 7;
}
