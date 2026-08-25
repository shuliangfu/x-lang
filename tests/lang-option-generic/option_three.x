/**
 * LANG-009 smoke: generic `struct Option<T>` + named `Option<i32> { … }` lit
 * (parse mangle → Option_i32). One mono per frame — multi-mono / multi-let
 * layout residual tracked under CORE-016 follow-up.
 */
allow(padding) struct Option<T> {
  is_some: bool;
  value: T;
}

/**
 * Program/test entry point.
 * @return i32 — 0 on success
 */
function main(): i32 {
  let a: Option<i32> = Option<i32> { is_some: true, value: 10 };
  if (!a.is_some) { return 1; }
  if (a.value != 10) { return 4; }
  return 0;
}
