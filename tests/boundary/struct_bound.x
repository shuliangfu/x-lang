// Isolated green: struct-level `<T: Trait>` when the type arg impls the bound.
// `Foo<A>` must compile; A impls Clone. Discriminator is field n=42.
// Neighborhood: struct_bound_viol.x (B no Clone) must T001.
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
struct A { n: i32 }
impl Clone for A { function clone(self: A): i32 { return self.n; } }
struct Foo<T: Clone> { x: T }
function main(): i32 {
  let a: A = A { n: 42 };
  let f: Foo<A> = Foo { x: a };
  return f.x.n;
}
