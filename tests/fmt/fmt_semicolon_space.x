// fmt 分号后空格回归：紧凑写法应格式化为 "; "（字符串内 ; 不变）。
// 供 tests/run-fmt-wrap.sh 使用。

function fmt_test_tight_semicolons(): i32 {
  let prefix: u8[16] = [];
  prefix[0]=1; prefix[1]=2; prefix[2]=3; prefix[3]=4;
  let s: u8[8] = [];
  s[0]=97; s[1]=59; s[2]=98;
  return prefix[0] + prefix[3];
}

function main(): i32 {
  return fmt_test_tight_semicolons();
}
