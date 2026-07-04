// parser 最小回归：if 分支后紧跟 unsafe + return，不应卡死或回扫到错误 token。
function main(): i32 {
  if (1 == 1) {
    unsafe {
      return 1;
    }
  }
  return 0;
}
