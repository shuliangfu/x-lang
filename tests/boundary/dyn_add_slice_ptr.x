// F7 leftover: asm binop of `unsafe { *e }` (EXPR_BLOCK peel).
// dest-SLICE extra `[]*i32` dest-stamp is already closed (host-C 7).
// Produce: glue_try_binop_load_operand returned -2 for EXPR_BLOCK (26), so
// `self.v + unsafe { *p[0] } + unsafe { *p[1] }` did emit_expr(BLOCK)
// after ARM64 rax frame-spill → CG002. INDEX-only and `0 + unsafe { *q }`
// were already green; bare `unsafe { return x + *q; }` (DEREF, not BLOCK)
// was already green. Ubuntu x86 hid (emit_expr(BLOCK) happened to work).
// Store: peel helper + dual-slot walkers (same as await/AS).
// Consume: emit_deref / emit_index as themselves.
// G.7: complete load_operand + clobber walkers. No second DEREF emitter.
// Wrapper rdi/x0 = data unchanged.
// Expected: asm + host-C compile = 0, run = 7 (v + *p[0] + *p[1] = 1+2+4).
// Neighborhood: dyn_add_slice.x / slice_of_ptr_let.x / dyn_add_slice_arr.x.
// PLATFORM: SHARED — Ubuntu gold · MACOS|ARM64 was the live CG002.

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
  let x: SumSP = a;
  let n: i32 = 2;
  let m: i32 = 4;
  return x.sumsp([&n, &m]);
}
