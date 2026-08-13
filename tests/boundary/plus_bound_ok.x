// Isolated green: `T: Clone + Default` when the type arg impls both traits.
// Body does not call methods on T (generic-body method resolve is another layer).
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
trait Default { function def(self): i32; }
struct A { n: i32 }
impl Clone for A { function clone(self: A): i32 { return self.n; } }
impl Default for A { function def(self: A): i32 { return 0; } }
function copy<T: Clone + Default>(x: T): i32 { return 42; }
function main(): i32 {
  let a: A = A { n: 42 };
  return copy<A>(a);
}
