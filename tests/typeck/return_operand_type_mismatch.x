// 负例：非 void 函数 return 表达式类型须与签名一致；typeck 应拒绝 bool→i32。
// 回归：run-typeck.sh / run-check.sh 断言 check 失败并带诊断。
function main(): i32 {
  let x: bool = true;
  return x;
}
