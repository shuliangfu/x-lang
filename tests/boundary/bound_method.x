// Isolated green: generic-body method via bound.
// `T: Clone` must allow `x.clone()`; impl returns 7 (not 42) so identity
// mono `return param0` cannot false-green.
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
struct A { n: i32 }
impl Clone for A { function clone(self: A): i32 { return 7; } }
function copy<T: Clone>(x: T): i32 { return x.clone(); }
function main(): i32 {
  let a: A = { n: 42 };
  return copy<A>(a);
}
