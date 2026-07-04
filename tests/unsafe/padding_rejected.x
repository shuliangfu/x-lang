// LANG-007 U1 负例：无 allow(padding) 时隐式 padding 须 typeck 拒绝
struct WithGap {
  a: u8
  b: i32
}

function main(): i32 {
  return 0;
}
