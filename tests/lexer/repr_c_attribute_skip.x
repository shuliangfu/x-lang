// B-03 v0 烟测：#[repr(C)] 属性 + 无 padding 的 i32 字段对（Point 8 字节）。
#[repr(C)]
struct Point {
  x: i32
  y: i32
}

function main(): i32 {
  let p: Point = Point { x: 4, y: 6 };
  return p.x + p.y;
}
