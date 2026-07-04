struct Point { x: i32; y: i32; }

function main(): i32 {
  let p: Point = Point { x: 1, y: 2 };
  let r: i32 = match p {
    Point { x: 1, y: 2 } => 0;
    _ => 1;
  };
  return r;
}
