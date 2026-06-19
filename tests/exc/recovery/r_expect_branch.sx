// EXC-006：expect 成功路径（可恢复边界内）
const result = import("core.result");

function main(): i32 {
  let r: Result_i32 = result.ok_i32(21);
  let v: i32 = result.expect_i32(r, 0);
  if (v != 21) { return 1; }
  return 0;
}
