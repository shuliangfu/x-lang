// LANG-007 U4：unsafe { } 内允许 *T 解引用
function read_u8(p: *u8): u8 {
  unsafe {
    return *p;
  }
}

/** 入口：静态变量取址并在 unsafe 内读一字节，正常返回 0。 */
function main(): i32 {
  let x: u8 = 42;
  let v: u8 = read_u8(&x);
  return if (v == 42) { 0 } else { 1 };
}
