// Thin pure: peel ARRAY/SLICE/PTR layers for INDEX dest type (wave441/445).
// wave445: `*out_ltr =` heal Ubuntu pure-asm CG002.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;

/**
 * Peel chain_n ARRAY/SLICE/PTR layers from ltr_in into out_ltr.
 * @return i32 — 0 ok; -3 emptied
 * PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function glue_emit_assign_index_array_peel_elf_c(arena: *u8, ltr_in: i32, chain_n: i32, out_ltr: *i32): i32 {
  unsafe {
    let ltr: i32 = 0;
    let walk_i: i32 = 0;
    let ltk_pre: i32 = 0;
    ltr = ltr_in;
    walk_i = 0;
    while (walk_i < chain_n) {
      if (ltr <= 0) {
        break;
      }
      ltk_pre = pipeline_type_kind_ord_at(arena, ltr);
      if (ltk_pre == 10) {
        ltr = pipeline_type_elem_ref_at(arena, ltr);
      } else {
        if (ltk_pre == 11) {
          ltr = pipeline_type_elem_ref_at(arena, ltr);
        } else {
          if (ltk_pre == 9) {
            ltr = pipeline_type_elem_ref_at(arena, ltr);
          } else {
            ltr = 0;
          }
        }
      }
      walk_i = walk_i + 1;
    }
    if (ltr <= 0) {
      return 0 - 3;
    }
    *out_ltr = ltr;
    return 0;
  }
}
