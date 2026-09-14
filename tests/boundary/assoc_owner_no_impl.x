// LANG-005 regression (negative): a struct with NO impl at all must not
// borrow another struct's same-named method. A implements g; B never
// implements anything. Before the fix B.g() compiled and ran A's body.
// Expected: compile = 1 (clean reject).
// PLATFORM: SHARED — Ubuntu gold.
trait T { function g(): i32; }
struct A { n: i32 }
struct B { m: i32 }
impl T for A { function g(): i32 { return 7; } }
function main(): i32 {
  return B.g();
}
