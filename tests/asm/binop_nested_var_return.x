// 7.3：嵌套 VAR+VAR 返回链应直 ldr/add，勿 mov x2 暂存 rax（run-asm-binop-nested-var.sh）。
function main(): i32 {
  let a: i32 = 1;
  let b: i32 = 2;
  let c: i32 = 3;
  let d: i32 = 4;
  /** 1+2+3+4+10 = 20 */
  return a + b + c + d + 10;
}
