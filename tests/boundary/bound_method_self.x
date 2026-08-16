// Isolated green: generic-body method with trait ret Self → T.
// Expected: compile = 0, run = 7 (clone must run; not identity n=42).
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): Self; }
struct A { n: i32 }
impl Clone for { function clone(self: A): A { return { n: 7 }; } }
function copy<T: Clone>(x: T): T { return x.clone(); }
function main(): i32 {
  let a: A = { n: 42 };
  let b: A = copy<A>(a);
  return b.n;
}
