// MEM-A1：双指针形参不得均标 restrict（可能重叠）。
function touch_two(a: *i32, b: *i32): void {
  return;
}

function main(): i32 {
  let x: i32 = 0;
  let y: i32 = 0;
  touch_two(&x, &y);
  return 0;
}
