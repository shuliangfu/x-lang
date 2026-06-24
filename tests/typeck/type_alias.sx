// §2.24 类型别名：type Alias = TargetType;（纯 typeck 别名，零运行时成本）
struct Point { x: i32; y: i32; }

type P = Point;
type Coord = i32;
type PP = P;
type IntPtr = *i32;

function main(): i32 {
  let p: P = Point { x: 1, y: 2 };
  let p2: PP = { x: 3, y: 4 };
  let c: Coord = 42;
  let ip: IntPtr = 0 as *i32;
  if (p.x != 1 || p.y != 2 || p2.x != 3 || p2.y != 4 || c != 42) {
    return 1;
  }
  if (ip != 0 as *i32) {
    return 2;
  }
  return 0;
}
