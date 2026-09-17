// Thin pure: field_load layout-match Cap residual (wave433).
// G.7: layout walk twin of field_load main / mega.
// PRODUCT: LINUX PREFER with main thin; nested byte-while → copy+bytes_eq
//   (Ubuntu tip empty .o / -E omit T when byte-compare while nested in layout).
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

/**
 * Copy layout name bytes at index k into out[0..nlen).
 * Single-level while — Ubuntu asm emit fails when this is inlined inside a
 * nested byte-compare while in the layout walker.
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
    let b: i32 = 0;
    while (j < nlen) {
      unsafe {
        b = pipeline_module_struct_layout_name_byte_at(m, k, j);
      }
      out[j] = b as u8;
      j = j + 1;
    }
  }
}

/**
 * Match base TYPE_NAMED against module layouts; return field load width or 0.
 * Uses copy+field_load_sz_bytes_eq (no nested byte-compare while).
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
    let nlen: i32 = 0;
    let k: i32 = 0;
    let j: i32 = 0;
    let ftr: i32 = 0;
    let ftr_kind: i32 = 0;
    let nsl: i32 = 0;
    let nf: i32 = 0;
    let fnlen: i32 = 0;
    let fb: u8[256] = [];
    let ln: i32 = 0;
    let hit: i32 = 0;
    if (a == (0 as *u8) || m == (0 as *u8) || base_tr <= 0 || field_name == (0 as *u8) || flen <= 0) {
      return 0;
    }
    unsafe {
      nlen = pipeline_type_named_name_into(a, base_tr, &struct_name[0]);
    }
    if (nlen <= 0 || nlen > 63) {
      return 0;
    }
    unsafe {
      nsl = pipeline_module_num_struct_layouts_at(m);
    }
    k = 0;
    while (k < nsl) {
      unsafe {
        ln = pipeline_module_struct_layout_name_len(m, k);
      }
      if (ln == nlen) {
        field_load_sz_copy_layout_name(m, k, &layout_name[0], nlen);
        if (field_load_sz_bytes_eq(&struct_name[0], &layout_name[0], nlen) != 0) {
          unsafe {
            nf = pipeline_module_struct_layout_num_fields(m, k);
          }
          j = 0;
          while (j < nf) {
            unsafe {
              fnlen = pipeline_module_struct_layout_field_name_len(m, k, j);
            }
            if (fnlen == flen) {
              unsafe {
                pipeline_module_struct_layout_field_name_into(m, k, j, &fb[0]);
              }
              if (field_load_sz_bytes_eq(&fb[0], field_name, fnlen) != 0) {
                unsafe {
                  ftr = pipeline_module_struct_layout_field_type_ref(m, k, j);
                  ftr_kind = pipeline_type_kind_ord_at(a, ftr);
                }
                /* Free TYPE_NAMED fields → 0 (fall through); concrete → width. */
                if (ftr_kind != 8) {
                  hit = glue_field_access_load_bytes_for_type_ref(a, ftr);
                  return hit;
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
