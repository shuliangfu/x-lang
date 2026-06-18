// STD-149：std.math fenv 能力检测烟测
const math = import("std.math");

function main(): i32 {
  let avail: i32 = fenv_available();
  if (avail != 0 && avail != 1) {
    return 1;
  }
  // stub 平台：API 应返回 FENV_NOT_IMPL（-9）
  if (avail == 0) {
    if (test_exceptions(31) != -9) { return 2; }
    return 0;
  }
  // fenv 可用：clear/raise/test 往返
  if (clear_exceptions(31) != 0) { return 3; }
  if (test_exceptions(31) != 0) { return 4; }
  if (raise_exceptions(4) != 0) { return 5; }
  if ((test_exceptions(4) & 4) == 0) { return 6; }
  if (clear_exceptions(31) != 0) { return 7; }
  return 0;
}
