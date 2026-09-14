// IDENT head via .x: VAR + field/method/index/turbofish + struct-lit Type{} + self.
struct P { x: i32, y: i32, }
impl P { function get(self: P): i32 { return self.x * 10 + self.y; } }
function twice<T>(v: T): T { return v; }
function main(): i32 {
  let p: P = { x: 3, y: 4 };
  let a: i32 = p.get();              // method on ident-chain
  let q: P = P { x: 5, y: 6 };       // qualified struct lit head
  let b: i32 = q.get();
  let c: i32 = twice<i32>(7);        // turbofish on ident
  let d: i32 = p.x + q.y;            // fields
  let cond: i32 = 0;
  if cond == 0 { return a + b + c + d; }   // bare-if authority (LBRACE pref)
  return 1;
}
