// ERR-02：try/catch — try 内 ? 失败 goto catch（零成本）；catch (r) 绑定 Result

const result = import("core.result");

/** 负数 err，非负 ok doubled。 */
function may_fail(x: i32): Result_i32 {
  if (x < 0) {
    return result.err_i32(1);
  }
  return result.ok_i32(x * 2);
}

/** i32 返回函数内用 try/catch 处理 ?，不必整函数返回 Result。 */
function read_ok(): i32 {
  try {
    let v: i32 = may_fail(3)?;
    return v;
  } catch (r) {
    return result.unwrap_or_i32(r, 99);
  }
}

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
