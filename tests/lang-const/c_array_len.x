// LANG-006：数组字面量在 i32 上下文折叠为元素个数
function main(): i32 {
  const N: i32 = [1, 2, 3, 4];
  return N;
}
