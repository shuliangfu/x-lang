/**
 * Cookbook NET-04：resolve_ex 对 invalid.invalid 须失败（STD-029）。
 */
const net = import("std.net");

function main(): i32 {
  /** "invalid.invalid" */
  let bad: u8[16] = [
    105, 110, 118, 97, 108, 105, 100, 46, 105, 110, 118, 97, 108, 105, 100, 0
  ];
  let err: i32 = 0;
  let addr: u32 = 0;
  if (net.resolve_ex(&bad[0], &addr, &err) == 0) { return 1; }
  if (err != net.resolve_err_host_not_found() && err != net.resolve_err_no_data()) { return 2; }
  return 0;
}
