// See implementation.
const fmt = import("std.fmt");

/* See implementation. */
struct Inner {
  tag: i32;
}

struct Point {
  x: i32;
  y: i32;
  inner: Inner;
}

/* See implementation. */
struct Option_i32 {
  is_some: bool;
  value: i32;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let p: Point = Point { x: 1, y: 2, inner: Inner { tag: 99 } };
  let _: i32 = fmt.println(p);
  let arr: i32[3] = [10, 20, 30];
  let _: i32 = fmt.println(arr);
  let msg: u8[5] = [72, 101, 108, 108, 111];
  let _: i32 = fmt.println(msg);
  let opt: Option_i32 = { is_some: true, value: 42 };
  let _: i32 = fmt.println(opt);
  let empty: Option_i32 = { is_some: false, value: 0 };
  let _: i32 = fmt.println(empty);
  return 0;
}
