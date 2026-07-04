// EXC-006：or_i32 左 Ok 保留（短路恢复链）
const result = import("core.result");

function main(): i32 {
  let a: Result_i32 = result.or_i32(result.ok_i32(5), result.ok_i32(9));
  if (result.expect_i32_or_panic(a) != 5) { return 1; }
  return 0;
}
