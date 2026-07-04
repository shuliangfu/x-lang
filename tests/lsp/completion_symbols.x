/**
 * TOOL-003 golden：textDocument/completion 应返回函数/struct/enum/import/关键字/内建类型。
 */
const mem = import("core.mem");

struct Point {
  x: i32
  y: i32
}

enum Kind {
  Alpha
  Beta
}

function add_one(v: i32): i32 {
  return v + 1;
}

function main(): i32 {
  let p: Point = Point { x: 1, y: 2 };
  return add_one(p.x);
}
