/**
 * LANG-009 烟测：import("core.option") 后使用 Option<i32> 与既有 Option_i32 API 并存。
 */
const option = import("core.option");

function main(): i32 {
  let g: Option<i32> = Option<i32> { is_some: true, value: 42 };
  let f: Option_i32 = option.some_i32(7);
  if (!g.is_some || g.value != 42) { return 1; }
  if (!option.is_some_i32(f) || option.unwrap_or_i32(f, 0) != 7) { return 2; }
  return 0;
}
