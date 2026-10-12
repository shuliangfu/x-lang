// Thin pure: INDEX ko47 FIELD-base arm (wave479).
// G.7: part of glue_binop_index_ko47_clobbers_rbx (peer-flat).
// wave479: tip U=3/3. PRODUCT inject: LINUX PREFER (stamp w479); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;

/**
 * Return 1 if INDEX base is FIELD whose base kind in {45,46,47,48,49}.
 * wave479: no-local — re-call; ban `let x=call()`.
 * @return i32 — 1 clobber; 0 not
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_binop_index_ko47_fa_elf_c(arena: *u8, expr_ref: i32): i32 {
  unsafe {
    if (pipeline_expr_index_base_ref(arena, expr_ref) > 0) {
      if (pipeline_expr_kind_ord_at(arena, pipeline_expr_index_base_ref(arena, expr_ref)) == 44) {
        if (pipeline_expr_field_access_base_ref(arena, pipeline_expr_index_base_ref(arena, expr_ref)) > 0) {
          if (pipeline_expr_kind_ord_at(arena, pipeline_expr_field_access_base_ref(arena, pipeline_expr_index_base_ref(arena, expr_ref))) == 46) {
            return 1;
          }
          if (pipeline_expr_kind_ord_at(arena, pipeline_expr_field_access_base_ref(arena, pipeline_expr_index_base_ref(arena, expr_ref))) == 45) {
            return 1;
          }
          if (pipeline_expr_kind_ord_at(arena, pipeline_expr_field_access_base_ref(arena, pipeline_expr_index_base_ref(arena, expr_ref))) == 48) {
            return 1;
          }
          if (pipeline_expr_kind_ord_at(arena, pipeline_expr_field_access_base_ref(arena, pipeline_expr_index_base_ref(arena, expr_ref))) == 49) {
            return 1;
          }
          if (pipeline_expr_kind_ord_at(arena, pipeline_expr_field_access_base_ref(arena, pipeline_expr_index_base_ref(arena, expr_ref))) == 47) {
            return 1;
          }
        }
      }
    }
    return 0;
  }
}
