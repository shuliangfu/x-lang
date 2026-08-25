/**
 * LANG-010 smoke: generic `struct Result<T, E>` + named `Result<i32, i32> { … }`
 * (parse mangle → Result_i32 via CORE-016 E=i32 compress). One mono let per
 * frame — multi-let layout residual is CORE-016 follow-up.
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
  if (a.err != 0 || a.value != 10) { return 1; }
  return 0;
}
