// LANG-007 U4：unsafe { } 内允许通过 *T 访问内存
// 用 p[0] 赋值：双平台 C 后端可编；let v=*p 在 Linux codegen 出 0 func，跨 unsafe 赋值在 Darwin typeck 失败。
function main(): i32 {
  unsafe {
    let x: i32 = 42;
    let p: *i32 = &x;
    p[0] = 1;
  }
  return 0;
}
