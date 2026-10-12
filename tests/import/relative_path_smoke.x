// See implementation.
const slice = import("core.slice");
const option = import("core.option");

/**
 * Smoke the core.slice import.
 * get_i32 takes a slice and an index and returns Option_i32.
 * @return i32 — the element, or 1 when the option is empty
 */
function main(): i32 {
  let data: i32[1] = [7];
  let s: []i32 = data;
  let o: Option_i32 = slice.get_i32(s, 0 as usize);
  if (!option.is_some_i32(o)) { return 1; }
  return option.unwrap_or_i32(o, 0);
}
