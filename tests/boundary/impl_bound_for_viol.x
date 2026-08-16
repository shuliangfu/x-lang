// Isolated compile-fail: `impl<T: Trait> Trait for Type` peek-FOR path.
// Bounds are keyed by the for-type; Foo<B> (B no Clone) must T001.
// Expected: compile != 0, stderr contains "does not impl Clone".
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
struct A { n: i32 }
impl Clone for { function clone(self: A): i32 { return self.n; } }
struct B { n: i32 }
struct Foo<T> { x: T }
impl<T: Clone> Clone for Foo<T> {
  function clone(self: Foo): i32 { return 7; }
}
function main(): i32 {
  let b: B = { n: 1 };
  let f: Foo<B> = { x: b };
  return f.clone();
}
