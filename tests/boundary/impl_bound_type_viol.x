// Isolated compile-fail: same-pattern `impl Type<T: Trait>` (IDENT after
// impl, then `<`). B has no Clone; Foo<B> must T001.
// Expected: compile != 0, stderr contains "does not impl Clone".
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
struct A { n: i32 }
impl Clone for A { function clone(self: A): i32 { return self.n; } }
struct B { n: i32 }
struct Foo<T> { x: T }
impl Foo<T: Clone> {
  function get(self: Foo): i32 { return 7; }
}
function main(): i32 {
  let b: B = { n: 1 };
  let f: Foo<B> = { x: b };
  return f.get();
}
