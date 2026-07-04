// STD-080/081：std.option + std.result 组合子与互转烟测
const option = import("std.option");
const result = import("std.result");
const err = import("std.error");
// Option_* / Result_* 类型定义在 core 层；import 以注册类型供注解与字段访问。
const _core_option = import("core.option");
const _core_result = import("core.result");

function main(): i32 {
  let o1: Option_i32 = option.some(10);
  let o2: Option_i32 = option.none();
  let r_ok: Result_i32 = result.ok(42);
  let r_err: Result_i32 = result.err(code_not_found());
  let o3: Option_i32 = option.from_result(r_ok);
  let r1: Result_i32 = option.to_result(o1, code_invalid());
  let r2: Result_i32 = option.to_result(o2, code_not_found());
  let r3: Result_i32 = result.from_error_code(ok());
  let r4: Result_i32 = result.from_value(7, ok());
  let r5: Result_i32 = result.from_value(0, code_invalid());
  let m1: Option_i32 = option.map(o1, 20);
  let m2: Result_i32 = result.map(r_ok, 100);
  let a1: Result_i32 = result.and_then(r_ok, result.ok(1));
  let a2: Option_i32 = option.and_then(o1, option.some(99));
  let f1: Result_i32 = result.or_else(r_err, result.ok(5));

  if (option.unwrap_or(o1, 0) != 10) { return 1; }
  if (option.is_none(o2) == 0) { return 2; }
  if (option.is_some(o3) == 0 || o3.value != 42) { return 3; }
  if (result.is_ok(r1) == 0 || r1.value != 10) { return 4; }
  if (result.is_err(r2) == 0) { return 5; }
  if (result.err_code(r3) != ok()) { return 6; }
  if (r4.value != 7) { return 7; }
  if (result.is_ok(r5) != 0) { return 8; }
  if (m1.value != 20) { return 9; }
  if (m2.value != 100) { return 10; }
  if (a1.value != 1) { return 11; }
  if (a2.value != 99) { return 12; }
  if (f1.value != 5) { return 13; }
  return 0;
}
