// F7 leftover: dyn Trait extras beyond the GP file must go on the stack.
// x86 SysV: rdi=data + GP1..5 extras; 6th extra is [rsp] at the wrapper call.
// ARM64 AAPCS64: x0=data + x1..x7 extras so 6 extras stay in GP (no stack).
// Wrapper is prologue+call+epilogue (not a tail jmp); it must copy incoming
// stack extras onto the impl outgoing stack. rdi/x0 stays data on entry.
// Host-C wrapper formals are impl params 1..N (safety cap 96).
// Expected: compile = 0, run = 7 (asm and host-C).
// PLATFORM: SHARED — Ubuntu gold (one stack word); Darwin 6 extras in GP.

trait Sum6 {
  function add6(self, a: i32, b: i32, c: i32, d: i32, e: i32, f: i32): i32;
}
struct A { v: i32 }
impl Sum6 for A {
  function add6(self: A, a: i32, b: i32, c: i32, d: i32, e: i32, f: i32): i32 {
    return self.v + a + b + c + d + e + f;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: dyn Sum6 = a;
  return x.add6(1, 1, 1, 1, 1, 1);
}
