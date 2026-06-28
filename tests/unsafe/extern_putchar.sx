// LANG-007 U3：extern 声明 C 符号，FFI 边界由 unsafe { } 信封包裹
extern function putchar(c: i32): i32;

/** 入口：在 unsafe 内输出 'A'，返回 putchar 结果（非零即成功路径）。 */
function main(): i32 {
  let n: i32 = 0;
  unsafe {
    n = putchar(65);
  }
  return if (n >= 0) { 0 } else { 1 };
}
