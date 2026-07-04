// TOOL-009 golden：match 臂与 enum 变体高亮
enum Color { RED, GREEN, BLUE }

function pick(c: Color): i32 {
  return match (c) {
    RED => 1,
    GREEN => 2,
    BLUE => 3,
  };
}
