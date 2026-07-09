// LANG-007 U4：unsafe { } 内允许 *T 解引用
// 指针与解引用均在 unsafe 体内；避免 if 表达式与跨 region 查 outer let 的 typeck/codegen 债。
function main(): i32 {
  unsafe {
    let x: u8 = 42;
    let p: *u8 = &x;
    let v: u8 = *p;
  }
  return 0;
}
