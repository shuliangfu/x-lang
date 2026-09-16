// LANG-005 regression: associated call `X.g()` must bind X's OWN impl,
// not whichever same-named method registered first. B implements g via
// trait U (returns 9); A implements g via trait T (returns 7). Before
// the owner sidecar, B.g() ran A's body (run=7).
// Expected: compile = 0, run = 9.
// PLATFORM: SHARED — Ubuntu gold.
trait T { function g(): i32; }
trait U { function g(): i32; }
struct A { n: i32 }
struct B { m: i32 }
impl T for A { function g(): i32 { return 7; } }
impl U for B { function g(): i32 { return 9; } }
function main(): i32 {
  return B.g();
}
