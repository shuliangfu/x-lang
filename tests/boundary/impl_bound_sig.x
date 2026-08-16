// Isolated green: `Foo<T>` in a generic signature must not false-red
// when Foo's impl carries `T: Clone` (`T` is Foo's type-param name).
// Body is a constant — field access on free T is another layer.
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
struct A { n: i32 }
impl Clone for { function clone(self: A): i32 { return 7; } }
struct Foo<T> { x: T }
impl<T: Clone> Foo<T> {
  function get(self: Foo): i32 { return 7; }
}
function wrap<T: Clone>(x: Foo<T>): i32 { return 7; }
function main(): i32 {
  let a: A = { n: 7 };
  let f: Foo<A> = { x: a };
  return wrap<A>(f);
}
