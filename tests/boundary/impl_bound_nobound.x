// Isolated green: generic impl without a bound stays unconstrained.
// `impl<T> Foo<T>` + Foo<B> (B impls nothing) must still compile.
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

struct B { n: i32 }
struct Foo<T> { x: T }
impl<T> Foo<T> {
  function get(self: Foo): i32 { return 7; }
}
function main(): i32 {
  let b: B = { n: 1 };
  let f: Foo<B> = { x: b };
  return f.get();
}
