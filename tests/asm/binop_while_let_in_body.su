// 7.3：while 体内 let t 参与 a+=；出口 live ∪ 后 return a+b（cfg-merge）。
function main(): i32 {
  let a: i32 = 0;
  let b: i32 = 2;
  while (a < 1) {
    let t: i32 = 1;
    a += t;
  }
  return a + b;
}
