// LANG-007 U4：unsafe { } 内允许 *T 解引用
// let 均在 unsafe 内；外层 return 0（return 不可作 unsafe 块尾巴表达式）。
function main(): i32 {
  unsafe {
    let x: u8 = 42;
    let p: *u8 = &x;
    let v: u8 = *p;
  }
  return 0;
}
