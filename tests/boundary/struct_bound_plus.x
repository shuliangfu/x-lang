// Isolated compile-fail: struct-level PLUS `T: Clone + Default` must check
// BOTH traits. A impls Clone only. Foo<A> must T001 Default.
// Expected: compile != 0, stderr contains "does not impl Default".
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
trait Default { function def(self): i32; }
struct A { n: i32 }
impl Clone for A { function clone(self: A): i32 { return self.n; } }
struct Foo<T: Clone + Default> { x: T }
function main(): i32 {
  let a: A = A { n: 42 };
  let f: Foo<A> = Foo { x: a };
  return f.x.n;
}
