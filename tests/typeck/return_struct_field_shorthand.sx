// return struct 简写 + STR-02 字段简写：`return { x, y: 2 }`
struct Point { x: i32; y: i32; }

function make_point(x: i32): Point {
  return { x, y: 2 };
}

function main(): i32 {
  let p: Point = make_point(7);
  if (p.x != 7 || p.y != 2) {
    return 1;
  }
  return 0;
}
