// 7.3：a+= 后 return a+b 应复用 rbx 中的 b（仅 kill 左值 a 槽，勿整表 clear）。
function main(): i32 {
  let a: i32 = 1;
  let b: i32 = 2;
  let c: i32 = a + b;
  a += 10;
  return a + b;
}
