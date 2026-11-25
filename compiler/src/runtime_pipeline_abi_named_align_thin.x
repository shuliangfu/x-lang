// Thin Cap tip: glue_type_align_simple — 10.44 i8 pack (named_builtin align 1).
// Egg TYPE_NAMED miss hard-coded al_out=4; Cap residual i8 must be 1 so
// struct {i8,i8,i8,i8} steps 0/1/2/3 (not 0/4/8/12) and stores don't smash neighbors.
// PLATFORM: SHARED — Darwin Cap tip demote egg → __demoted; Linux weak egg + redefine.

export extern function pipeline_arena_num_types(a: *u8): i32;
export extern function pipeline_type_kind_ord_at(a: *u8, ty_ref: i32): i32;
export extern function pipeline_type_named_name_into(a: *u8, ty_ref: i32, out: *u8): i32;
export extern function typeck_x_named_builtin_align(nm: *u8, nlen: i32): i32;
export extern function glue_type_align_simple__demoted(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;

/**
 * Cap tip align authority: named_builtin first for TYPE_NAMED miss path.
 * Non-builtin / non-named fall through to demoted egg body.
 * @return i32 — align bytes (1/2/4/8 typical)
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_type_align_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32 {
  let kind_ord: i32 = 0;
  let nt: i32 = 0;
  let name: u8[256] = [];
  let nlen: i32 = 0;
  let al: i32 = 0;
  if (a == (0 as *u8) || ty_ref <= 0 || depth > 1024) {
    return 1;
  }
  unsafe {
    nt = pipeline_arena_num_types(a);
  }
  if (ty_ref > nt) {
    return 1;
  }
  unsafe {
    kind_ord = pipeline_type_kind_ord_at(a, ty_ref);
  }
  /* TYPE_NAMED=8: Cap residual i8/i16/u16 via named_builtin (i8→1). */
  if (kind_ord == 8) {
    unsafe {
      nlen = pipeline_type_named_name_into(a, ty_ref, &name[0]);
    }
    if (nlen > 0 && nlen <= 255) {
      unsafe {
        al = typeck_x_named_builtin_align(&name[0], nlen);
      }
      if (al == 1 || al == 2 || al == 4 || al == 8) {
        return al;
      }
    }
  }
  unsafe {
    return glue_type_align_simple__demoted(m, a, ty_ref, depth);
  }
}
