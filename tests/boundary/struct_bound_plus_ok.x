// Isolated green: struct-level `T: Clone + Default` when the type arg impls both.
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
trait Default { function def(self): i32; }
struct A { n: i32 }
impl Clone for { function clone(self: A): i32 { return self.n; } }
impl Default for { function def(self: A): i32 { return 0; } }
struct Foo<T: Clone + Default> { x: T }
function main(): i32 {
  let a: A = { n: 42 };
  let f: Foo<A> = { x: a };
  return f.x.n;
}
