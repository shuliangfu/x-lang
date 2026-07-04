// P1-2：无符号整数按 2^N 取模（非 UB）；i32::MAX + 1 须为 0。
function main(): i32 {
  let max: u32 = 4294967295;
  let wrapped: u32 = max + 1;
  if (wrapped != 0) {
    return 1;
  }
  return 42;
}
