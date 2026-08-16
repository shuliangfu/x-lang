// Isolated compile-fail: free T with no bound still cannot `x.clone()`.
// Expected: compile != 0, LANG-004 / no impl for type with method.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
struct A { n: i32 }
impl Clone for { function clone(self: A): i32 { return 7; } }
function copy<T>(x: T): i32 { return x.clone(); }
function main(): i32 {
  let a: A = { n: 42 };
  return copy<A>(a);
}
