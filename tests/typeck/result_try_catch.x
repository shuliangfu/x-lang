// See implementation.

const result = import("core.result");

/** Internal function `may_fail`.
 * Implements `may_fail`.
 * @param x i32
 * @return Result_i32
 */
function may_fail(x: i32): Result_i32 {
  if (x < 0) {
    return result.err_i32(1);
  }
  return result.ok_i32(x * 2);
}

/** Internal function `read_ok`.
 * Read path helper `read_ok`.
 * @return i32
 */
function read_ok(): i32 {
  try {
    let v: i32 = may_fail(3)?;
    return v;
  } catch (r) {
    return result.unwrap_or_i32(r, 99);
  }
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (read_ok() != 6) {
    return 1;
  }
  try {
    let v: i32 = may_fail(-1)?;
    return v;
  } catch (r) {
    if (!result.is_err_i32(r)) {
      return 2;
    }
    return 0;
  }
}
