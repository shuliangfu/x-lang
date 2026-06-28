// LANG-007 U4 负例：S0 内 *T 解引用须 typeck 拒绝
function main(): i32 {
  let p: *i32 = 0;
  let v: i32 = *p;
  return v;
}
