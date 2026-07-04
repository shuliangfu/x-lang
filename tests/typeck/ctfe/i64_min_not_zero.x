// P0-4 回归：INT64_MIN 常量 `0 - 9223372036854775807 - 1` 不得被 CTFE/lexer 折叠为 0。
// 曾导致 core.fmt fmt_i64_to_buf(0) 误判 INT64_MIN → fmt_f64_to_buf(0.0) exit 16。
function main(): i32 {
  let i64_min: i64 = 0 - 9223372036854775807 - 1;
  let zero: i64 = 0;
  if (zero == i64_min) {
    return 1;
  }
  return 42;
}
