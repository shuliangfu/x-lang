// LANG-007 U3：extern 声明 C 符号，FFI 边界由 unsafe { } 信封包裹
extern function putchar(c: i32): i32;

/** 入口：在 unsafe 内输出 'A'，成功返回 0。 */
function main(): i32 {
  unsafe {
    putchar(65);
  }
  return 0;
}
