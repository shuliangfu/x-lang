// 7.3：局部 VAR+VAR 二元运算应直 ldr 到 rax/rbx，免 push/pop（run-asm-binop-var.sh）。
function main(): i32 {
  let a: i32 = 10;
  let b: i32 = 20;
  let sa: i32 = 2;
  let sb: i32 = 1;
  let c: i32 = a + b;   // 30
  let d: i32 = a & b;   // 0
  let e: i32 = a | b;   // 30
  let f: i32 = a ^ b;   // 30
  let g: i32 = a << sa; // 40
  let h: i32 = b >> sb; // 10
  let j: i32 = b / a;   // 2
  let k: i32 = b % a;   // 0
  let i: i32 = 0;
  if (a < b) {
    i = 1;
  }
  // 30 + 0 + 30 + 30 + 40 + 10 + 2 + 0 + 1 = 143
  return c + d + e + f + g + h + j + k + i;
}
