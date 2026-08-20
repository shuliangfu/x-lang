// Type-position trait name is the only TYPE_DYN producer (`let x: Clone = a`).
// Sit-red was assignment mismatch (TYPE_NAMED Clone vs A). Produce: type_ref
// IDENT wrap of a registered trait. Store: TYPE_DYN kind / trait name.
// Consume: F2 coerce + F3 dispatch. Do not write `dyn Clone` (P013).
// Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (x.clone() of A{v:7}).
// Neighborhood: dyn_type_let.x / dyn_type.x / dyn_add.x.
// PLATFORM: SHARED — Ubuntu gold.

trait Clone { function clone(self): i32; }
struct A { v: i32 }
impl Clone for A {
  function clone(self: A): i32 {
    return self.v;
  }
}
function main(): i32 {
  let a: A = { v: 7 };
  let x: Clone = a;
  return x.clone();
}
