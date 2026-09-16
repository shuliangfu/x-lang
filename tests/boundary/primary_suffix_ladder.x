// Suffix chain ladder: field / method / index / call / turbofish-call.
struct P { x: i32, y: i32, }
impl P {
  function get(self: P): i32 { return self.x + self.y; }
  function mk(x: i32): P { let p: P = { x: x, y: x }; return p; }
}
function add(a: i32, b: i32): i32 { return a + b; }
function ident<T>(v: T): T { return v; }
function main(): i32 {
  let p: P = { x: 30, y: 12 };
  let f1: i32 = p.x;                       // field
  let f2: i32 = p.get();                   // method
  let f3: i32 = p.y + p.x;                 // chained fields
  let c1: i32 = add(1, 2);                 // call
  let i1: i32 = ident<i32>(5);             // turbofish call
  let arr: [3]i32 = [7, 8, 9];
  let ix: i32 = arr[1];                    // index
  return f1 - f2 + f3 + c1 + i1 + ix;      // 30-42+42+3+5+8 = 46
}
