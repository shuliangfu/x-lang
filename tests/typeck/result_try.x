// ERR-01：Result `?` 传播 — foo()? desugar 为 err 早退 + unwrap value（零成本）

const result = import("core.result");

/** 负数返回 err，非负返回 doubled。 */
function may_fail(x: i32): Result_i32 {
  if (x < 0) {
    return result.err_i32(1);
  }
  return result.ok_i32(x * 2);
}

/** 链式传播：先 may_fail，再 +1 包装为 ok。 */
function chain_ok(x: i32): Result_i32 {
  let v: i32 = may_fail(x)?;
  return result.ok_i32(v + 1);
}

/** err 路径：负参应在 may_fail 处早退。 */
function chain_err(): Result_i32 {
  let v: i32 = may_fail(-1)?;
  return result.ok_i32(v);
}

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
