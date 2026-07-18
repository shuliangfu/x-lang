/**
 * See implementation.
 */
allow(padding) struct HotLate {
  big: f64
  hot: i32
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let s: HotLate = HotLate { big: 1.0, hot: 2 };
  return s.hot;
}
