// LANG-007 U4 负例：S0 内 *T 解引用须 typeck 拒绝
// 用 return *p（非 let 初始化）：部分 typeck_gen 的 let-init 路径不遍历 RHS deref。
function main(): i32 {
  let p: *i32 = 0;
  return *p;
}
