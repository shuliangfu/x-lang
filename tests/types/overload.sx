// 函数重载烟测：同名不同形参，调用点按实参类型分派
function pick(x: i32): i32 { return x + 1; }
function pick(x: i64): i32 { return x as i32 + 2; }

function main(): i32 {
  if (pick(10) != 11) { return 1; }
  if (pick(20 as i64) != 22) { return 2; }
  return 0;
}
