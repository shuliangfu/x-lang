// ERR-01 负例：i32 返回函数内不可用 `?`（须与同型 Result 返回函数匹配）

const result = import("core.result");

function may_fail(): Result_i32 {
  return result.err_i32(1);
}

function main(): i32 {
  let v: i32 = may_fail()?;
  return v;
}
