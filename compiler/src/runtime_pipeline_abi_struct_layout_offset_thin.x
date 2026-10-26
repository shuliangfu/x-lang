// 10.44: layout offset callers must use public glue_type_align_simple (named_align
// thin / i8→1). Egg redefine demotes align_simple in the same .o, so
// compute_field_offset / next_field_offset_ex bind the demoted i8→4 body.
// This TU is first-wins T; call sites here resolve to the thin align.
// PLATFORM: SHARED.

export extern function pipeline_module_num_struct_layouts_at(m: *u8): i32;
export extern function pipeline_module_struct_layout_num_fields(m: *u8, li: i32): i32;
export extern function pipeline_module_struct_layout_field_type_ref(m: *u8, li: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_field_align_at(m: *u8, li: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_packed_at(m: *u8, li: i32): i32;
export extern function pipeline_module_struct_layout_set_field_offset(m: *u8, li: i32, j: i32, off: i32): void;
export extern function glue_type_align_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_type_is_empty_struct_c(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;

/**
 * Field offset via public align_simple (10.44 i8 pack).
 * @return i32 — byte offset of field fj
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_struct_layout_compute_field_offset_c(m: *u8, a: *u8, li: i32, fj: i32): i32 {
  let current: i32 = 0;
  let j: i32 = 0;
  let nf: i32 = 0;
  let nlayouts: i32 = 0;
  let ftr: i32 = 0;
  let A: i32 = 0;
  let fa: i32 = 0;
  let rem: i32 = 0;
  let gap: i32 = 0;
  let fsize: i32 = 0;
  let empty: i32 = 0;
  if (m == (0 as *u8) || a == (0 as *u8) || li < 0 || fj < 0) {
    if (fj >= 0) {
      return fj * 8;
    }
    return 0;
  }
  unsafe {
    nlayouts = pipeline_module_num_struct_layouts_at(m);
  }
  if (li >= nlayouts) {
    return fj * 8;
  }
  unsafe {
    nf = pipeline_module_struct_layout_num_fields(m, li);
  }
  if (fj >= nf) {
    return fj * 8;
  }
  current = 0;
  j = 0;
  while (j <= fj) {
    unsafe {
      ftr = pipeline_module_struct_layout_field_type_ref(m, li, j);
      fa = pipeline_module_struct_layout_field_align_at(m, li, j);
      A = glue_type_align_simple(m, a, ftr, 0);
    }
    if (A <= 0) {
      A = 1;
    }
    if (fa > A) {
      A = fa;
    }
    rem = current % A;
    gap = A - rem;
    gap = gap % A;
    if (j == fj) {
      return current + gap;
    }
    current = current + gap;
    unsafe {
      fsize = glue_type_size_simple(m, a, ftr, 0);
      empty = glue_type_is_empty_struct_c(m, a, ftr, 0);
    }
    if (fsize < 0 || (fsize == 0 && empty == 0)) {
      fsize = 4;
    }
    current = current + fsize;
    j = j + 1;
  }
  return fj * 8;
}

/**
 * Next field offset; uses public align_simple (10.44).
 * @return i32 — next offset
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_struct_layout_next_field_offset_ex(m: *u8, a: *u8, layout_idx: i32, new_field_type_ref: i32, field_align_req: i32): i32 {
  let current: i32 = 0;
  let nf: i32 = 0;
  let j: i32 = 0;
  let ftr: i32 = 0;
  let fsize: i32 = 0;
  let j2: i32 = 0;
  let ftr2: i32 = 0;
  let fa: i32 = 0;
  let A: i32 = 0;
  let fsize2: i32 = 0;
  let rem: i32 = 0;
  let gap: i32 = 0;
  let A2: i32 = 0;
  let rem2: i32 = 0;
  let gap2: i32 = 0;
  let pk: i32 = 0;
  let empty: i32 = 0;
  if (m == (0 as *u8)) {
    return 0;
  }
  if (layout_idx < 0) {
    return 0;
  }
  unsafe {
    nf = pipeline_module_struct_layout_num_fields(m, layout_idx);
    pk = pipeline_module_struct_layout_packed_at(m, layout_idx);
  }
  if (pk != 0) {
    j = 0;
    while (j < nf) {
      unsafe {
        ftr = pipeline_module_struct_layout_field_type_ref(m, layout_idx, j);
        fsize = glue_type_size_simple(m, a, ftr, 0);
        empty = glue_type_is_empty_struct_c(m, a, ftr, 0);
      }
      if (fsize < 0) {
        fsize = 4;
      } else {
        if (fsize == 0) {
          if (empty == 0) {
            fsize = 4;
          }
        }
      }
      current = current + fsize;
      j = j + 1;
    }
    return current;
  }
  j2 = 0;
  while (j2 < nf) {
    unsafe {
      ftr2 = pipeline_module_struct_layout_field_type_ref(m, layout_idx, j2);
      fa = pipeline_module_struct_layout_field_align_at(m, layout_idx, j2);
      A = glue_type_align_simple(m, a, ftr2, 0);
      fsize2 = glue_type_size_simple(m, a, ftr2, 0);
      empty = glue_type_is_empty_struct_c(m, a, ftr2, 0);
    }
    if (A <= 0) {
      A = 1;
    }
    if (fa > A) {
      A = fa;
    }
    if (fsize2 < 0) {
      fsize2 = 4;
    } else {
      if (fsize2 == 0) {
        if (empty == 0) {
          fsize2 = 4;
        }
      }
    }
    rem = current % A;
    gap = A - rem;
    gap = gap % A;
    current = current + gap + fsize2;
    j2 = j2 + 1;
  }
  unsafe {
    A2 = glue_type_align_simple(m, a, new_field_type_ref, 0);
  }
  if (A2 <= 0) {
    A2 = 1;
  }
  if (field_align_req > A2) {
    A2 = field_align_req;
  }
  rem2 = current % A2;
  gap2 = A2 - rem2;
  gap2 = gap2 % A2;
  return current + gap2;
}

/**
 * Wrapper: next_field_offset_ex with field_align_req=0.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_struct_layout_next_field_offset(m: *u8, a: *u8, layout_idx: i32, new_field_type_ref: i32): i32 {
  return pipeline_struct_layout_next_field_offset_ex(m, a, layout_idx, new_field_type_ref, 0);
}

/**
 * Sync field_offset via thin compute (public align).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_sync_struct_layout_field_offsets_c(m: *u8, a: *u8): void {
  let li: i32 = 0;
  let nf: i32 = 0;
  let j: i32 = 0;
  let off: i32 = 0;
  let nlayouts: i32 = 0;
  if (m == (0 as *u8) || a == (0 as *u8)) {
    return;
  }
  unsafe {
    nlayouts = pipeline_module_num_struct_layouts_at(m);
  }
  li = 0;
  while (li < nlayouts) {
    unsafe {
      nf = pipeline_module_struct_layout_num_fields(m, li);
    }
    j = 0;
    while (j < nf) {
      off = glue_struct_layout_compute_field_offset_c(m, a, li, j);
      unsafe {
        pipeline_module_struct_layout_set_field_offset(m, li, j, off);
      }
      j = j + 1;
    }
    li = li + 1;
  }
}
