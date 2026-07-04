// EXC-006：is_err 守卫后选择默认（不读取 value）
const result = import("core.result");

function main(): i32 {
  let r: Result_i32 = result.err_i32(7);
  let v: i32 = result.is_err_i32(r) ? 66 : r.value;
  if (v != 66) { return 1; }
  return 0;
}
