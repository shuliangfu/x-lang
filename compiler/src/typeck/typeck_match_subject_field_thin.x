// Match subject field-bind type. One body.
// The layout-name compare used to call the byte getter and index the
// type name in one expression. This Darwin product clobbers the call
// result with the index, so no struct name matches and
// `let out: Holder = match w { Wrap { h } => h }` is XT001.
// PLATFORM: SHARED — typeck.x keeps the call; this thin is the body
// because the mega does not rebuild on the current product.

export extern function pipeline_typeck_match_subject_ty_get_c(): i32;
export extern function pipeline_typeck_match_subject_mod_get_c(): *u8;
export extern function pipeline_type_kind_ord_at(arena: *u8, ty_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, ty_ref: i32, out: *u8): i32;
export extern function pipeline_module_num_struct_layouts_at(module: *u8): i32;
export extern function pipeline_module_struct_layout_name_len(module: *u8, k: i32): i32;
export extern function pipeline_module_struct_layout_name_byte_at(module: *u8, k: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_num_fields(module: *u8, k: i32): i32;
export extern function pipeline_module_struct_layout_field_name_len(module: *u8, k: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_field_name_into(module: *u8, k: i32, j: i32, out: *u8): void;
export extern function pipeline_module_struct_layout_field_type_ref(module: *u8, k: i32, j: i32): i32;

/**
 * Resolve an unbound VAR as a field of the active match subject struct.
 * Subject cells live in runtime_pipeline_abi BSS (set before match arms).
 * @param module *u8 — current module; must be the subject module pointer
 * @param arena *u8 — type pool for the TYPE_NAMED name and field type_ref
 * @param name *u8 — VAR identifier bytes, not necessarily NUL-terminated
 * @param name_len i32 — byte length; must be > 0
 * @return i32 — field type_ref (>0) on hit; 0 if no active subject or no field
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_match_subject_field_type(module: *u8, arena: *u8, name: *u8,
name_len: i32): i32 {
  let ty: i32 = 0;
  let subj_mod: *u8 = 0 as *u8;
  let tnm: u8[256] = [];
  let tnl: i32 = 0;
  let nsl: i32 = 0;
  let k: i32 = 0;
  let fl: i32 = 0;
  let nf: i32 = 0;
  let fi: i32 = 0;
  let fnl: i32 = 0;
  let j: i32 = 0;
  let bi: i32 = 0;
  let name_eq: i32 = 0;
  let fnm: u8[256] = [];
  if (module == (0 as *u8) || arena == (0 as *u8) || name == (0 as *u8) || name_len <= 0) {
    return 0;
  }
  unsafe {
    ty = pipeline_typeck_match_subject_ty_get_c();
    subj_mod = pipeline_typeck_match_subject_mod_get_c();
  }
  if (ty <= 0 || subj_mod != module) {
    return 0;
  }
  // TYPE_NAMED ord == 8.
  unsafe {
    if (pipeline_type_kind_ord_at(arena, ty) != 8) {
      return 0;
    }
    tnl = pipeline_type_named_name_into(arena, ty, &tnm[0]);
  }
  if (tnl <= 0) {
    return 0;
  }
  unsafe {
    nsl = pipeline_module_num_struct_layouts_at(module);
  }
  k = 0;
  while (k < nsl) {
    unsafe {
      fl = pipeline_module_struct_layout_name_len(module, k);
    }
    if (fl == tnl) {
      name_eq = 1;
      bi = 0;
      while (bi < fl && name_eq != 0) {
        let lb: i32 = 0;
        let sb: i32 = 0;
        // Store both sides first. A compare that calls the getter and
        // indexes the name in one expression clobbers the call result
        // with the index on this Darwin product.
        unsafe {
          lb = pipeline_module_struct_layout_name_byte_at(module, k, bi);
        }
        sb = tnm[bi] as i32;
        if (lb != sb) {
          name_eq = 0;
        }
        bi = bi + 1;
      }
      if (name_eq != 0) {
        unsafe {
          nf = pipeline_module_struct_layout_num_fields(module, k);
        }
        fi = 0;
        while (fi < nf) {
          unsafe {
            fnl = pipeline_module_struct_layout_field_name_len(module, k, fi);
          }
          if (fnl == name_len) {
            j = 0;
            while (j < 128) {
              fnm[j] = 0;
              j = j + 1;
            }
            unsafe {
              pipeline_module_struct_layout_field_name_into(module, k, fi, &fnm[0]);
            }
            name_eq = 1;
            j = 0;
            while (j < fnl && name_eq != 0) {
              let left: i32 = 0;
              let right: i32 = 0;
              left = fnm[j] as i32;
              right = name[j] as i32;
              if (left != right) {
                name_eq = 0;
              }
              j = j + 1;
            }
            if (name_eq != 0) {
              unsafe {
                return pipeline_module_struct_layout_field_type_ref(module, k, fi);
              }
            }
          }
          fi = fi + 1;
        }
      }
    }
    k = k + 1;
  }
  return 0;
}
