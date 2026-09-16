/**
 * LANG-010 / CORE-016 smoke: generic `struct Result<T, E>` + named
 * `Result<i32, i32> { … }` lit (parse mangle → Result_i32 via E=i32 compress)
 * with multi-let in one frame (field load width follows typeck mono stamp).
 */
allow(padding) struct Result<T, E> {
  value: T;
  err: E;
}

/**
 * Program/test entry point.
 * @return i32 — 0 on success
 */
function main(): i32 {
  let a: Result<i32, i32> = Result<i32, i32> { value: 10, err: 0 };
  let b: Result<i32, i32> = Result<i32, i32> { value: 20, err: 1 };
  if (a.err != 0 || a.value != 10) { return 1; }
  if (b.err != 1 || b.value != 20) { return 2; }
  return 0;
}
