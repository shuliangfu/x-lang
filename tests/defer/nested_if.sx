// MEM-B0：嵌套块 defer 先于外层 return 路径上的函数级 defer。
function main(): i32 {
  let acc: i32 = 0;
  defer { acc = acc + 100; }
  if (1 == 1) {
    defer { acc = acc + 1; }
    acc = 10;
  }
  return acc;
}
