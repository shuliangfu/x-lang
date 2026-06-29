// TST-002：std.vec 边界烟测（Vec_i32 push/pop/clear/reserve）
//
// 【文件职责】≥8 边界 case；动态数组基本路径。
// 【运行方式】tests/run-tst-002-boundary-gate.sh
const vec = import("std.vec");

function main(): i32 {
  let v: Vec_i32 = vec.new();
  // case 1：新建为空
  if (vec.is_empty(v) != 1) { return 1; }
  // case 2：新建 cap 为 0（首次 push 懒分配）
  if (vec.capacity(v) != 0) { return 2; }
  // case 3：push 三个元素
  if (vec.push(&v, 10) != 0) { return 3; }
  if (vec.push(&v, 20) != 0) { return 4; }
  if (vec.push(&v, 30) != 0) { return 5; }
  // case 4：长度
  if (vec.len(v) != 3) { return 6; }
  // case 5：get/set
  if (vec.get(v, 1) != 20) { return 7; }
  vec.set(&v, 1, 21);
  if (vec.get(v, 1) != 21) { return 8; }
  // case 6：pop
  let popped: i32 = vec.pop(&v);
  if (popped != 30) { return 9; }
  if (vec.len(v) != 2) { return 10; }
  // case 7：append_slice (now called extend)
  let tail: i32[2] = [40, 50];
  if (vec.extend(&v, &tail[0], 2) != 0) { return 11; }
  if (vec.len(v) != 4) { return 12; }
  // case 8：clear 后为空
  vec.clear(&v);
  if (vec.is_empty(v) != 1) { return 13; }
  // case 9：truncate + deinit
  if (vec.push(&v, 1) != 0) { return 14; }
  vec.truncate(&v, 0);
  if (vec.len(v) != 0) { return 15; }
  vec.deinit(&v);
  return 0;
}
