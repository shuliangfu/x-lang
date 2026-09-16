// STD-080/081 roundtrip: std.option ↔ std.result + std.error bridge.
// PLATFORM: SHARED — qualify err.* (bare ok()/code_* resolve to result.ok arity-1 → T001).
// Bool compares use false (is_* returns bool; == 0 is incompatible-types T001).
const option = import("std.option");
const result = import("std.result");
const err = import("std.error");
const _core_option = import("core.option");
const _core_result = import("core.result");

/**
 * Program/test entry: option/result construct, map, and_then, error bridge.
 * @return i32 — 0 on success; 1..13 identify failing check
 */
function main(): i32 {
  let o1: Option_i32 = option.some(10);
  let o2: Option_i32 = option.none();
  let r_ok: Result_i32 = result.ok(42);
  let r_err: Result_i32 = result.err(err.code_not_found());
  let o3: Option_i32 = option.from_result(r_ok);
  let r1: Result_i32 = option.to_result(o1, err.code_invalid());
  let r2: Result_i32 = option.to_result(o2, err.code_not_found());
  let r3: Result_i32 = result.from_error_code(err.ok());
  let r4: Result_i32 = result.from_value(7, err.ok());
  let r5: Result_i32 = result.from_value(0, err.code_invalid());
  let m1: Option_i32 = option.map(o1, 20);
  let m2: Result_i32 = result.map(r_ok, 100);
  let a1: Result_i32 = result.and_then(r_ok, result.ok(1));
  let a2: Option_i32 = option.and_then(o1, option.some(99));
  let f1: Result_i32 = result.or_else(r_err, result.ok(5));

  if (option.unwrap_or(o1, 0) != 10) { return 1; }
  if (option.is_none(o2) == false) { return 2; }
  if (option.is_some(o3) == false || o3.value != 42) { return 3; }
  if (result.is_ok(r1) == false || r1.value != 10) { return 4; }
  if (result.is_err(r2) == false) { return 5; }
  if (result.err_code(r3) != err.ok()) { return 6; }
  if (r4.value != 7) { return 7; }
  if (result.is_ok(r5) != false) { return 8; }
  if (m1.value != 20) { return 9; }
  if (m2.value != 100) { return 10; }
  if (a1.value != 1) { return 11; }
  if (a2.value != 99) { return 12; }
  if (f1.value != 5) { return 13; }
  return 0;
}
