// Isolated compile-fail: `T: Clone + Default` must check BOTH traits.
// A impls Clone only. copy<A> must T001 Default (was false-green: PLUS ignored).
// Neighborhood: plus_bound_ok.x (both impls) stays green; single-bound viol still T001.
// Expected: compile != 0, stderr contains "does not impl Default".
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
trait Default { function def(self): i32; }
struct A { n: i32 }
impl Clone for A { function clone(self: A): i32 { return self.n; } }
function copy<T: Clone + Default>(x: T): i32 { return 42; }
function main(): i32 {
  let a: A = { n: 42 };
  return copy<A>(a);
}
