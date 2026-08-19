// F7 leftover: dest-SLICE extra `[]*i32` dest-stamp (PTR elem of dest-SLICE).
// Produce: skip-trait after `[]` STAR stored elem_kind=-1 (token_to_type_kind
// does not handle STAR) AND dest extras skipped kind 9, so `[&n, &m]` stayed
// TYPE_ARRAY of PTR (no dest-SLICE fat wrap).
// Store: registry param_elem_kind=PTR + param_elem_elem_kind=leaf after `[]*`.
// Consume: host-C emit_call_arg_slice_abi / asm dest-SLICE wrap.
// Sit-red dyn host-C run=133 (`(int32_t *[]){&n,&m}` into a fat slice*);
// UFCS / named local already dest-stamp (host-C 7). Assign-only is false-green
// (impl ignores p). asm INDEX of slice-of-ptr remains CG002 leftover.
// G.7: complete skip-trait STAR after `[]` + dest-SLICE extras wrap PTR then
// slice + typeck_coerce_init_expr_to_decl. No second dest-SLICE stamp.
// Wrapper rdi/x0 = data unchanged.
// Expected: host-C compile = 0, run = 7 (v + *p[0] + *p[1] = 1+2+4).
// Neighborhood: dyn_add_slice.x / slice_of_ptr_let.x / dyn_add_slice_arr.x.
// PLATFORM: SHARED — Ubuntu gold.

trait SumSP {
  function sumsp(self, p: []*i32): i32;
}
struct A { v: i32 }
impl SumSP for A {
  function sumsp(self: A, p: []*i32): i32 {
    return self.v + unsafe { *p[0] } + unsafe { *p[1] };
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: dyn SumSP = a;
  let n: i32 = 2;
  let m: i32 = 4;
  return x.sumsp([&n, &m]);
}
