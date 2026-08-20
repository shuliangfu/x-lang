// F7 leftover: ARM64 wrapper stack-copy needs 8 extras (x0=data + x1..x7
// extras; 8th extra is [sp] after prologue). x86 already stacked at 6 extras;
// 8 extras put 3 words on the SysV stack. Last extra is -1 so a missed
// stack copy cannot false-green as zero. Sit-red Darwin run=5: copy
// load_x29_pos clobbered x0 (self.v became h=-1). Wrapper rdi/x0 stays data.
// Expected: compile = 0, run = 7 (asm and host-C).
// PLATFORM: SHARED — Ubuntu gold + Darwin stack copy.

trait Sum8 {
  function add8(self, a: i32, b: i32, c: i32, d: i32, e: i32, f: i32, g: i32, h: i32): i32;
}
struct A { v: i32 }
impl Sum8 for A {
  function add8(self: A, a: i32, b: i32, c: i32, d: i32, e: i32, f: i32, g: i32, h: i32): i32 {
    return self.v + a + b + c + d + e + f + g + h;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: Sum8 = a;
  return x.add8(1, 1, 1, 1, 1, 1, 1, 0 - 1);
}
