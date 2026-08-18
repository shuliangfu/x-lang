// F7 leftover: host-C `[2][2]i32` extra (wrapper + ARRAY_LIT).
// Produce: wrapper emit_type → `int32_t * * a1`; ARRAY_LIT else →
// `(int32_t *[]){(int32_t[]){…}}`. Impl already `int32_t (*p)[2]`.
// Sit-red host-C run=219. G.7: complete existing wrapper + ARRAY_LIT
// else (no second emitter). First formal stays void* data.
// Expected: compile = 0, run = 11 (v + p[0][0]+p[0][1]+p[1][0]+p[1][1]).
// Neighborhood: dyn_add_arr1.x (`[2]i32` extra, still `int32_t *`).
// PLATFORM: SHARED — Ubuntu gold.

trait Sum2 {
  function sum2(self, p: [2][2]i32): i32;
}
struct A { v: i32 }
impl Sum2 for A {
  function sum2(self: A, p: [2][2]i32): i32 {
    return self.v + p[0][0] + p[0][1] + p[1][0] + p[1][1];
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: dyn Sum2 = a;
  return x.sum2([[1, 2], [3, 4]]);
}
