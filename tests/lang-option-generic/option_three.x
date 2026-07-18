/**
 * See implementation.
 */
allow(padding) struct Option<T> {
  is_some: bool;
  value: T;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: Option<i32> = Option<i32> { is_some: true, value: 10 };
  let b: Option<u8> = Option<u8> { is_some: true, value: 5 };
  let c: Option<*u8> = Option<*u8> { is_some: false, value: 0 };

  if (!a.is_some) { return 1; }
  if (!b.is_some) { return 2; }
  if (c.is_some) { return 3; }
  if (a.value != 10) { return 4; }
  if (b.value != 5) { return 5; }

  return 0;
}
