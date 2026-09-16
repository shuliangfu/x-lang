/**
 * LANG-009 / CORE-016 smoke: generic `struct Option<T>` + named
 * `Option<i32> { … }` lit (parse mangle → Option_i32) with multi-let and
 * multi-mono in one frame (field load width must follow typeck mono stamp).
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
  let b: Option<i32> = Option<i32> { is_some: true, value: 20 };
  let c: Option<u8> = Option<u8> { is_some: true, value: 7 };
  if (!a.is_some) { return 1; }
  if (a.value != 10) { return 2; }
  if (!b.is_some) { return 3; }
  if (b.value != 20) { return 4; }
  if (!c.is_some) { return 5; }
  if (c.value != 7) { return 6; }
  return 0;
}
