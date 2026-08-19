// Type-position trait name is TYPE_DYN without writing `dyn`.
// Sit-red `let x: Clone = a` was assignment mismatch (TYPE_NAMED Clone vs A).
// Produce: type_ref IDENT of a registered trait stayed TYPE_NAMED.
// Store: type_ref kind / trait name. Consume: F2 coerce + F3 dispatch
// require TYPE_DYN. G.7: complete type_ref IDENT (registered trait →
// same TYPE_DYN wrap as `dyn Trait` peel). `dyn Trait` still works
// (peel sees already-DYN inner, no nested fat). Wrapper rdi/x0 = data
// unchanged.
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
