// 无负载枚举 + match 分支（§7.4）：Color.Green 臂应返回 1
enum Color {
  Red,
  Green,
  Blue,
}

function main(): i32 {
  let c: Color = Color.Green;
  return match c { Color.Green => 1; Color.Red => 0; _ => -1; }
}
