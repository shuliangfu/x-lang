// n 已是 i64 时，return i64 上下文内三元不应要求 n as i64
function f_i64(n: i64): i64 {
  return n >= 0 ? n : -1;
}

// n 为 i32 时，两分支 i32 + i32 汇合为 i32，return i64 需靠后续拓宽（若未实现则可能报错）
function f_i32(n: i32): i64 {
  return n >= 0 ? n : -1;
}

function main(): i32 {
  let a: i64 = f_i64(1);
  let b: i64 = f_i32(1);
  if (a < 0 || b < 0) {
    return 1;
  }
  return 0;
}
