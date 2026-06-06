// 7.3：线性块内 a/b/d 同时参与 binop 链（为全图着色压测：>2 槽同时活跃）；run-asm-binop-block-var.sh。
function main(): i32 {
  let a: i32 = 1;
  let b: i32 = 2;
  let d: i32 = 3;
  let t: i32 = a + b;
  let u: i32 = t + d;
  return u;
}
