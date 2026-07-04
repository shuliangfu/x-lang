// STD-059：fenv clear/test 烟测（掩码用字面量，避免模块 const 解析问题）
const math = import("std.math");

function main(): i32 {
  let rc: i32 = clear_exceptions(31);
  if (rc != 0 && rc != -9) {
    return 1;
  }
  let flags: i32 = test_exceptions(31);
  if (flags == -9) {
    return 0;
  }
  if (flags != 0) {
    return 2;
  }
  rc = raise_exceptions(4);
  if (rc != 0) {
    return 3;
  }
  flags = test_exceptions(4);
  if ((flags & 4) == 0) {
    return 4;
  }
  rc = clear_exceptions(31);
  if (rc != 0) {
    return 5;
  }
  return 0;
}
