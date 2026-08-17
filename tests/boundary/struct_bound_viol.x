// Isolated compile-fail: struct-level `<T: Trait>` must reject a type arg
// that does not impl the bound. B has no Clone; `let f: Foo<B>` was
// false-green (mono Foo__B, run=1).
// Expected: compile != 0, stderr contains "does not impl Clone".
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
struct A { n: i32 }
impl Clone for A { function clone(self: A): i32 { return self.n; } }
struct B { n: i32 }
struct Foo<T: Clone> { x: T }
function main(): i32 {
  let b: B = { n: 1 };
  let f: Foo<B> = { x: b };
  return f.x.n;
}
