// Isolated green: impl-level `<T: Trait>` when the type arg impls the bound.
// `impl<T: Clone> Foo<T>` + `Foo<A>` must compile; get returns 7 so a
// missing method cannot fake field identity.
// Neighborhood: impl_bound_viol.x (B no Clone) must T001.
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
struct A { n: i32 }
impl Clone for { function clone(self: A): i32 { return self.n; } }
struct Foo<T> { x: T }
impl<T: Clone> Foo<T> {
  function get(self: Foo): i32 { return 7; }
}
function main(): i32 {
  let a: A = { n: 42 };
  let f: Foo<A> = { x: a };
  return f.get();
}
