// Isolated green: generic struct without a bound stays unconstrained.
// `struct Foo<T>` + Foo<B> (B impls nothing) must still compile.
// Expected: compile = 0, run = 1.
// PLATFORM: SHARED — Ubuntu gold.

struct B { n: i32 }
struct Foo<T> { x: T }
function main(): i32 {
  let b: B = B { n: 1 };
  let f: Foo<B> = Foo { x: b };
  return f.x.n;
}
