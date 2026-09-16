// LANG-005 regression (negative): an EMPTY impl block must not satisfy
// the receiver for a zero-arg associated call. A implements g; B's impl
// is empty. Before the fix this compiled and ran A's body.
// Expected: compile = 1 (clean reject).
// PLATFORM: SHARED — Ubuntu gold.
trait T { function g(): i32; }
struct A { n: i32 }
struct B { m: i32 }
impl T for A { function g(): i32 { return 7; } }
impl T for B { }
function main(): i32 {
  return B.g();
}
