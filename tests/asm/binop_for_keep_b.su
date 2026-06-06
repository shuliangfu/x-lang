// 7.3：for 后 let x=b 复用 rbx（汇合 live ∪，cfg-merge ldur 门禁）。
function main(): i32 {
  let a: i32 = 0;
  let b: i32 = 2;
  let c: i32 = a + b;
  for ( ; a < 1 ; ) {
    a += 1;
  }
  let x: i32 = b;
  return x + a;
}
