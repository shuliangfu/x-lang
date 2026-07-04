// 负例：块内连续语句间缺分号（`}` 前单独 return 可省略分号，见 run-parser.sh 头注释）
function main(): i32 {
  return 0
  return 1;
}
