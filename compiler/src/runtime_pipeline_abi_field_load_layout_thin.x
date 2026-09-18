// Thin pure: field_load layout-match Cap residual (wave433/w485).
// G.7: layout walk twin of field_load main / mega.
// wave433: nested byte-while → copy+bytes_eq (Ubuntu empty .o).
// wave485: no-local — ban mid `x=call()` (tip U=2/11); re-call + pipe cells.
//   PRODUCT inject: LINUX PREFER (stamp w485); MACOS full thin path unchanged.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_type_named_name_into(a: *u8, ty_ref: i32, out: *u8): i32;
export extern function pipeline_module_num_struct_layouts_at(m: *u8): i32;
export extern function pipeline_module_struct_layout_name_len(m: *u8, k: i32): i32;
export extern function pipeline_module_struct_layout_name_byte_at(m: *u8, k: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_num_fields(m: *u8, k: i32): i32;
export extern function pipeline_module_struct_layout_field_name_len(m: *u8, k: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_field_name_into(m: *u8, k: i32, j: i32, out: *u8): void;
export extern function pipeline_module_struct_layout_field_type_ref(m: *u8, k: i32, j: i32): i32;
export extern function pipeline_type_kind_ord_at(a: *u8, ty_ref: i32): i32;
export extern function glue_field_access_load_bytes_for_type_ref(a: *u8, ty_ref: i32): i32;
export extern function field_load_sz_bytes_eq(a: *u8, b: *u8, n: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * Copy layout name bytes at index k into out[0..nlen).
 * wave485: no-local — ban `b=call()` in while; call-as-store.
 * @param m *u8 — Module*
 * @param k i32 — layout index
 * @param out *u8 — destination buffer (capacity >= nlen)
 * @param nlen i32 — byte count to copy
 * @return void
 * PLATFORM: SHARED freestanding layout name copy.
 */
function field_load_sz_copy_layout_name(m: *u8, k: i32, out: *u8, nlen: i32): void {
  unsafe {
    let j: i32 = 0;
    while (j < nlen) {
      out[j] = pipeline_module_struct_layout_name_byte_at(m, k, j) as u8;
      j = j + 1;
    }
  }
}

/**
 * Match base TYPE_NAMED against module layouts; return field load width or 0.
 * wave485: no-local — pipe cell for nlen; re-call in while; ban mid `x=call()`.
 * @param a *u8 — ASTArena*
 * @param m *u8 — Module*
 * @param base_tr i32 — base type ref (PTR already peeled by caller)
 * @param field_name *u8 — field name bytes
 * @param flen i32 — field name length
 * @return i32 — load byte size when matched non-NAMED field; 0 if no match
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS co-path.
 */
#[no_mangle]
export function field_load_sz_layout_match(a: *u8, m: *u8, base_tr: i32, field_name: *u8, flen: i32): i32 {
  unsafe {
    let struct_name: u8[256] = [];
    let layout_name: u8[256] = [];
    let fb: u8[256] = [];
    /* cell[0]=nlen */
    let cell: u8[4] = [];
    let k: i32 = 0;
    let j: i32 = 0;

    if (a == (0 as *u8) || m == (0 as *u8) || base_tr <= 0 || field_name == (0 as *u8) || flen <= 0) {
      return 0;
    }
    pipe_store_i32_le(&cell[0], 0, pipeline_type_named_name_into(a, base_tr, &struct_name[0]));
    if (pipe_load_i32_le(&cell[0], 0) <= 0) {
      return 0;
    }
    if (pipe_load_i32_le(&cell[0], 0) > 63) {
      return 0;
    }
    k = 0;
    while (k < pipeline_module_num_struct_layouts_at(m)) {
      if (pipeline_module_struct_layout_name_len(m, k) == pipe_load_i32_le(&cell[0], 0)) {
        field_load_sz_copy_layout_name(m, k, &layout_name[0], pipe_load_i32_le(&cell[0], 0));
        if (field_load_sz_bytes_eq(&struct_name[0], &layout_name[0], pipe_load_i32_le(&cell[0], 0)) != 0) {
          j = 0;
          while (j < pipeline_module_struct_layout_num_fields(m, k)) {
            if (pipeline_module_struct_layout_field_name_len(m, k, j) == flen) {
              pipeline_module_struct_layout_field_name_into(m, k, j, &fb[0]);
              if (field_load_sz_bytes_eq(&fb[0], field_name, flen) != 0) {
                if (pipeline_type_kind_ord_at(a, pipeline_module_struct_layout_field_type_ref(m, k, j)) != 8) {
                  return glue_field_access_load_bytes_for_type_ref(a, pipeline_module_struct_layout_field_type_ref(m, k, j));
                }
              }
            }
            j = j + 1;
          }
        }
      }
      k = k + 1;
    }
    return 0;
  }
}
