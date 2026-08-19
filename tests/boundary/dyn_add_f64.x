// F7 leftover: Trait f64 extra is SysV xmm0, not rsi.
// FLOAT_LIT defaults to f64 — no typeck stamp needed for this leaf.
// x86 impl param_home reads xmm; ARM64 local impl stays GP-in (unchanged).
// Mix: integer extra stays rsi/x1, f64 extra is xmm0 (x86).
// Wrapper first arg stays data (trampoline only touches self).
// Neighborhood: dyn_add.x (i32 extra GP), dyn_call_ok.x (0 extra).
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold (xmm); Darwin extras stay GP.

trait AddF {
  function add(self, k: f64): i32;
}
trait Mix {
  function mix(self, i: i32, f: f64): i32;
}
struct A { v: i32 }
impl AddF for A {
  function add(self: A, k: f64): i32 { return self.v + (k as i32); }
}
impl Mix for A {
  function mix(self: A, i: i32, f: f64): i32 { return self.v + i + (f as i32); }
}
function main(): i32 {
  let a: A = { v: 4 };
  let x: AddF = a;
  if (x.add(3.0) != 7) { return 1; }
  let y: Mix = a;
  if (y.mix(1, 2.0) != 7) { return 2; }
  return 7;
}
