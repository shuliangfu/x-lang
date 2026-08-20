// F7 leftover: dyn extra `*i32` + by-value NAMED `self.v` (sit-red 139).
// Produce: w189_stack_off_is_emit_param_ptr_slot mapped stack_off with
// `(off-8)/8` so the by-value NAMED self home at 16 became param index 1.
// When that extra is TYPE_PTR, FIELD_ACCESS of `self.v` pointer-loaded
// the stored value (v=1 as a pointer) → SIGSEGV. Named module-func
// `(self: A, p: *i32)` shared the sit-red. Dyn extra `*i32` without
// `self.v` already 7 (extra pass is fine). dest-SLICE extra + `self.v`
// already 7 (kind 11 never hits this helper).
// Store: fill_param_slots param 0 starts at 16, then +8. Consume:
// glue_enc_local_slot_ptr_or_addr_elf_c → lea of by-value home.
// G.7: complete w189 walk (same homes as fill_param_slots; no second
// mapper). Wrapper rdi/x0 = data unchanged. PTR-outer `*[N][]T` is
// the same produce (neighborhood dyn_add_ptr_arr_slice.x).
// Expected: compile = 0, run = 7 (v + *p = 1+6).
// Neighborhood: dyn_add.x (`i32` extra) / dyn_add_slice.x (`[]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumP {
  function sump(self, p: *i32): i32;
}
struct A { v: i32 }
impl SumP for A {
  function sump(self: A, p: *i32): i32 {
    let x: i32 = unsafe { *p };
    return self.v + x;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumP = a;
  let n: i32 = 6;
  return x.sump(&n);
}
