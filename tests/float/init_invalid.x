// 负例：f32 初值为 none，应 typeck 失败（整型 1 在 typeck.x 可隐式转 f32，见 run-float.sh）
function main(): i32 {
  let x: f32 = none;
  return 0;
}
