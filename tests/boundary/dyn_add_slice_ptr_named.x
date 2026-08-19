// F7 leftover: dest-SLICE extra `[]*Pair` dest-stamp (sit-red dyn
// extra asm 139 / host-C `(struct Pair *[]){&n}` into wrapper
// `struct xlang_slice_Pair_p *` → panic: 0). Produce: dest extras
// dest-SLICE-of-PTR skips elem_elem kind 8 so `[&n]` stays TYPE_ARRAY
// of PTR (no dest-SLICE stamp). Store: skip-trait already stores
// elem_kind=PTR + elem_elem_kind=NAMED + param_name="Pair" after
// `[]*` IDENT. Consume: host-C dest-SLICE wrap / asm dest wrap;
// fat layout `struct Pair **data` already exists. Named local +
// UFCS dest-stamp via the module-func formal (already 7). dest-ARRAY
// extra `[2]*Pair` already 7 (ADDR_OF elems; not this leaf).
// G.7: complete existing dest-SLICE-of-PTR reconstruct (param_name
// wrap named then wrap ptr then wrap slice + typeck_coerce_init_expr_to_decl).
// No second dest-SLICE stamp. Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + (*p[0]).a + (*p[0]).b = 1+2+4).
// Neighborhood: dyn_add_slice_ptr.x (`[]*i32`) / dyn_add_slice_named.x
// (`[]Pair`) / dyn_add_slice_arr_named.x (`[][2]Pair`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumSPP {
  function sumspp(self, p: []*Pair): i32;
}
struct Pair { a: i32, b: i32 }
struct A { v: i32 }
impl SumSPP for A {
  function sumspp(self: A, p: []*Pair): i32 {
    let x: i32 = unsafe { (*p[0]).a };
    let y: i32 = unsafe { (*p[0]).b };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumSPP = a;
  let n: Pair = { a: 2, b: 4 };
  return x.sumspp([&n]);
}
