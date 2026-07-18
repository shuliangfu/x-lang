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

/** Internal function `chain_ok`.
 * Implements `chain_ok`.
 * @param x i32
 * @return Result_i32
 */
function chain_ok(x: i32): Result_i32 {
  let v: i32 = may_fail(x)?;
  return result.ok_i32(v + 1);
}

/** Internal function `chain_err`.
 * Implements `chain_err`.
 * @return Result_i32
 */
function chain_err(): Result_i32 {
  let v: i32 = may_fail(-1)?;
  return result.ok_i32(v);
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let ok: Result_i32 = chain_ok(3);
  if (result.is_err_i32(ok)) {
    return 1;
  }
  if (result.unwrap_or_i32(ok, 0) != 7) {
    return 2;
  }
  let bad: Result_i32 = chain_err();
  if (!result.is_err_i32(bad)) {
    return 3;
  }
  return 0;
}
