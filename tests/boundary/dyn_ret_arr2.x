// F7 leftover: host-C ret `[2][2]i32` (sit-red Ubuntu
// -Wincompatible-pointer-types `int32_t ** rp = t`; mac clang
// false-green run=10 from row-pointer bit patterns).
// Produce: emit_type peels ARRAY twice → `int32_t **`; return wrap
// emits `static int32_t * __xlang_ar[2]`. typeck ndims already closed.
// G.7: complete emit_type decay (one E*) + emit_return wrap
// (static E ar[K][N] + memcpy, return (E*)ar). No second emitter.
// Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0. host-C run = 10 (1+2+3+4) both ends.
// asm dest `[K][N]T` copy leftover is NOT this leaf (named-local
// non-dyn `[2][2]i32` ret also run=3).
// Neighborhood: dyn_ret_arr.x ([2]i32) / dyn_add_arr2.x ([2][2]i32 extra).
// PLATFORM: SHARED — Ubuntu gold.

trait Get22 {
  function get22(self): [2][2]i32;
}
struct A { v: i32 }
impl Get22 for A {
  function get22(self: A): [2][2]i32 {
    let t: [2][2]i32 = [[self.v, 2], [3, 4]];
    return t;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: dyn Get22 = a;
  let r: [2][2]i32 = x.get22();
  return r[0][0] + r[0][1] + r[1][0] + r[1][1];
}
