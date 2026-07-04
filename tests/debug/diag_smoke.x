// CORE-019：debug_assert_eq_i32_diag 烟测（typeck；失败路径不执行）
const debug = import("core.debug");

function main(): i32 {
  if (debug.debug_assert_eq_i32_diag(1, 1, 99) != 0) { return 1; }
  debug.debug_diag_store(10, 20, 1);
  return 0;
}
