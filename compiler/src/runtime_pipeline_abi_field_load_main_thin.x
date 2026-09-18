// Thin pure: field_load REST load_byte_sz (layout via layout_match thin).
// G.7: body MUST match field_load_sz_thin / mega (layout delegated).
// wave433: layout walk extracted to field_load_layout_thin.
// wave485: no-local peer-flat — try_layout + name_heur peers.
//   PRODUCT inject: LINUX PREFER (stamp w485); MACOS full thin path unchanged.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_field_access_base_ref(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_len(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_into(a: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_expr_resolved_type_ref(a: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(a: *u8, ty_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(a: *u8, ref: i32): i32;
export extern function glue_field_access_load_bytes_for_type_ref(a: *u8, ty_ref: i32): i32;
export extern function field_load_sz_try_layout_elf_c(a: *u8, m: *u8, base_tr: i32, field_name: *u8, flen: i32): i32;
export extern function field_load_sz_name_heur_elf_c(field_name: *u8, flen: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * FIELD_ACCESS load width (base-layout / resolved / is_some|is_none heuristic).
 * wave485: no-local — re-call / pipe cells; peers for layout + name heur.
 * @param a *u8 - ASTArena*
 * @param m *u8 - Module*
 * @param expr_ref i32 - FIELD_ACCESS expr ref
 * @return i32 - load byte size
 * PLATFORM: SHARED — G.7 thin twin of runtime_pipeline_abi.x authority.
 */
#[no_mangle]
export function pipeline_expr_field_access_load_byte_sz(a: *u8, m: *u8, expr_ref: i32): i32 {
  unsafe {
    let field_name: u8[256] = [];
    /* cell[0]=base_tr; cell[4]=layout hit */
    let cell: u8[8] = [];

    if (a == (0 as *u8) || expr_ref <= 0) {
      return 8;
    }
    if (pipeline_expr_field_access_base_ref(a, expr_ref) <= 0) {
      return 8;
    }
    if (pipeline_expr_field_access_name_len(a, expr_ref) <= 0) {
      return 8;
    }
    if (pipeline_expr_field_access_name_len(a, expr_ref) > 255) {
      return 8;
    }
    pipeline_expr_field_access_name_into(a, expr_ref, &field_name[0]);

    if (pipeline_expr_resolved_type_ref(a, expr_ref) > 0) {
      if (pipeline_type_kind_ord_at(a, pipeline_expr_resolved_type_ref(a, expr_ref)) != 8) {
        if (pipeline_type_kind_ord_at(a, pipeline_expr_resolved_type_ref(a, expr_ref)) != 10) {
          if (pipeline_type_kind_ord_at(a, pipeline_expr_resolved_type_ref(a, expr_ref)) != 11) {
            if (pipeline_type_kind_ord_at(a, pipeline_expr_resolved_type_ref(a, expr_ref)) != 12) {
              return glue_field_access_load_bytes_for_type_ref(a, pipeline_expr_resolved_type_ref(a, expr_ref));
            }
          }
        }
      }
    }

    pipe_store_i32_le(&cell[0], 0, pipeline_expr_resolved_type_ref(a, pipeline_expr_field_access_base_ref(a, expr_ref)));
    if (pipe_load_i32_le(&cell[0], 0) > 0) {
      if (pipeline_type_kind_ord_at(a, pipe_load_i32_le(&cell[0], 0)) == 9) {
        if (pipeline_type_elem_ref_at(a, pipe_load_i32_le(&cell[0], 0)) > 0) {
          pipe_store_i32_le(&cell[0], 0, pipeline_type_elem_ref_at(a, pipe_load_i32_le(&cell[0], 0)));
        }
      }
    }
    pipe_store_i32_le(&cell[0], 4, field_load_sz_try_layout_elf_c(a, m, pipe_load_i32_le(&cell[0], 0), &field_name[0], pipeline_expr_field_access_name_len(a, expr_ref)));
    if (pipe_load_i32_le(&cell[0], 4) != 0) {
      return pipe_load_i32_le(&cell[0], 4);
    }
    return field_load_sz_name_heur_elf_c(&field_name[0], pipeline_expr_field_access_name_len(a, expr_ref));
  }
}
