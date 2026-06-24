// MEM-B0：同块内 defer 逆序（LIFO）执行后再 return。
function main(): i32 {
  let acc: i32 = 0;
  defer { acc = acc * 10 + 1; }
  defer { acc = acc * 10 + 2; }
  return acc;
}
