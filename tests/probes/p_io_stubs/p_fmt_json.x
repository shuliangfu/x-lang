// w1515 (5.7a): fmt.println(struct) goes through the JSON schema face.
const fmt = import("std.fmt");

struct In { x: i32, y: bool }
struct J { a: i32, b: bool, inner: In }

function main(): i32 {
  let j: J = J { a: 0 - 42, b: true, inner: In { x: 99, y: false } };
  fmt.println(j);
  let i2: In = In { x: 0 - 5, y: true };
  fmt.println(i2);
  return 0;
}
