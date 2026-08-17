// Isolated compile-fail: T: Clone does not grant `def`.
// Expected: compile != 0, LANG-004 / no impl for type with method.
// Neighborhood: bound_method.x stays green; plus_bound still T001.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
trait Default { function def(self): i32; }
struct A { n: i32 }
impl Clone for A { function clone(self: A): i32 { return 7; } }
impl Default for A { function def(self: A): i32 { return 0; } }
function copy<T: Clone>(x: T): i32 { return x.def(); }
function main(): i32 {
  let a: A = { n: 42 };
  return copy<A>(a);
}
