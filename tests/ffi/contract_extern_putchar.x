// SAFE-004 C7：extern C ABI — putchar 由调用方保证参数合法；须在 unsafe 内调用。
extern function putchar(c: i32): i32;

function main(): i32 {
  let n: i32 = 0;
  unsafe {
    n = putchar(66);
  }
  if (n < 0) {
    return 1;
  }
  return 0;
}
