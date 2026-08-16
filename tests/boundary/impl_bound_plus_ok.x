// Isolated green: impl-level `T: Clone + Default` when the type arg impls both.
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
trait Default { function def(self): i32; }
struct A { n: i32 }
impl Clone for { function clone(self: A): i32 { return self.n; } }
impl Default for { function def(self: A): i32 { return 0; } }
struct Foo<T> { x: T }
impl<T: Clone + Default> Foo<T> {
  function get(self: Foo): i32 { return 7; }
}
function main(): i32 {
  let a: A = { n: 42 };
  let f: Foo<A> = { x: a };
  return f.get();
}
