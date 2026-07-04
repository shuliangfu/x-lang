// LANG-007 U1：allow(padding) 显式 opt-in 后隐式 padding 合法
allow(padding)
struct WithGap {
  a: u8
  b: i32
}

/** 入口：读字段 b，期望返回 2。 */
function main(): i32 {
  let x: WithGap = WithGap { a: 1, b: 2 };
  return x.b;
}
