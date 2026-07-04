// EXC-006：is_ok 三元恢复分支
const result = import("core.result");

function main(): i32 {
  let r: Result_i32 = result.err_i32(3);
  let v: i32 = result.is_ok_i32(r) ? r.value : 77;
  if (v != 77) { return 1; }
  let g: Result_i32 = result.ok_i32(11);
  let w: i32 = result.is_ok_i32(g) ? g.value : 0;
  if (w != 11) { return 2; }
  return 0;
}
