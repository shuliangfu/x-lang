// Isolated compile-fail: impl-level PLUS `T: Clone + Default` must check
// BOTH traits. A impls Clone only. Foo<A> must T001 Default.
// Expected: compile != 0, stderr contains "does not impl Default".
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
trait Default { function def(self): i32; }
struct A { n: i32 }
impl Clone for A { function clone(self: A): i32 { return self.n; } }
struct Foo<T> { x: T }
impl<T: Clone + Default> Foo<T> {
  function get(self: Foo): i32 { return 7; }
}
function main(): i32 {
  let a: A = { n: 42 };
  let f: Foo<A> = { x: a };
  return f.get();
}
