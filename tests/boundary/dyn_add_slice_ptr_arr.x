// F7 leftover: dest-SLICE extra `[]*[N]T` (PTR-to-ARRAY elem of dest-SLICE).
// Produce: dest extras dest-SLICE-of-PTR ignored elem_array_ndims so
// `[]*[2]i32` reconstructed as `[]*i32` (typeck expected *i32, found *[2]i32).
// Named extra dest-stamped via the formal; host-C emit then used the ARRAY
// tag as a C type (`xlang_arr2_int32_t **data`) and `int32_t * al[]`
// vs `int32_t (*)[2]`.
// Store: registry elem_kind=PTR + eek=leaf + elem_array_ndims/dims
// (skip-trait after `[]*` then `[` already stores).
// Consume: host-C emit_call_arg_slice_abi / asm dest-SLICE wrap.
// G.7: complete dest-SLICE-of-PTR (ndims wrap ARRAY then wrap ptr/slice)
// + layout PTR-to-ARRAY (`E (*(*data))[N]`) + dest-SLICE ARRAY_LIT
// (`E (*__xlang_al[n])[N]`). No second dest-SLICE stamp / layout walker.
// Wrapper rdi/x0 = data unchanged.
// Lets (not a two-unsafe binop) so INDEX is the dest-stamp, not peel.
// Expected: compile = 0, run = 7 (v + (*p[0])[0] + (*p[0])[1] = 1+2+4).
// Neighborhood: dyn_add_slice_ptr.x / dyn_add_slice_arr.x / dyn_ret_ptr_arr.x.
// PLATFORM: SHARED — Ubuntu gold.

trait SumSPA {
  function sumspa(self, p: []*[2]i32): i32;
}
struct A { v: i32 }
impl SumSPA for A {
  function sumspa(self: A, p: []*[2]i32): i32 {
    let x: i32 = unsafe { (*p[0])[0] };
    let y: i32 = unsafe { (*p[0])[1] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumSPA = a;
  let row: [2]i32 = [2, 4];
  return x.sumspa([&row]);
}
