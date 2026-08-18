// F7 leftover: dyn Trait f32 extra must honor typeck FLOAT_LIT stamp.
// Unstamped 3.0 is f64; impl param_home / ARM64 GP-in read the low 32 bits → 0.
// After stamp, emit packs IEEE f32 bits (glue_emit_float_lit_to_rax_elf_c).
// Host-C: call-site cast must be typed (void*, float), not (void*, ...),
// or default-arg promotion still widens 3.0f to double (run=1).
// Mix: integer extra stays GP; f32 extra is xmm0 (x86) / GP (ARM64 local impl).
// Wrapper first arg stays data (trampoline only touches self).
// Neighborhood: dyn_add_f64.x (f64 extra), dyn_add.x (i32 extra).
// Expected: compile = 0, run = 7 (asm and host-C).
// PLATFORM: SHARED — Ubuntu gold (xmm movd); Darwin extras stay GP.

trait AddF32 {
  function add(self, k: f32): i32;
}
trait MixF32 {
  function mix(self, i: i32, f: f32): i32;
}
struct A { v: i32 }
impl AddF32 for A {
  function add(self: A, k: f32): i32 { return self.v + (k as i32); }
}
impl MixF32 for A {
  function mix(self: A, i: i32, f: f32): i32 { return self.v + i + (f as i32); }
}
function main(): i32 {
  let a: A = { v: 4 };
  let x: dyn AddF32 = a;
  if (x.add(3.0) != 7) { return 1; }
  let y: dyn MixF32 = a;
  if (y.mix(1, 2.0) != 7) { return 2; }
  return 7;
}
