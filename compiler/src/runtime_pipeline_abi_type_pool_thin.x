// Thin pure: wave301/357/372/372b/373/383/383b/515 M2 — type_pool Cap residual C→.x.
// Type LE: kind@0 name[256]@4 name_len@260 elem@264 array_size@268
//   region_label[256]@272 region_label_len@528 size=532.
// G.7: bodies match runtime_pipeline_abi.x wave270 leave (correct LE offsets;
// historic C thin used wrong 132/136/140/144/272 — replaced here).
// wave357: w301_load/store_i32 unsafe wrappers (T001).
// wave372/372b/373: Ubuntu PREFER then option T001 — Darwin PREFER / Ubuntu -E.
// wave383: Ubuntu tip PREFER L2 5/5 (option=102) — PREFER both ends.
// wave383b: HARD BAN tip force-reinject after green (Ubuntu 3rd tip reinject
//   → option T001; keep green PREFER overlay via stamp).
// wave515: tipU 2/5→6/6 — mid `tp=/k=/n=call()` drop U; pipe-cell heal;
//   stamp → w515; tip force-reinject still HARD BAN (keep PREFER overlay).
// PLATFORM: SHARED freestanding Cap leave · PREFER both ends · BAN force tip.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
export extern function pipeline_arena_type_ptr(arena: *u8, ref: i32): *u8;
export extern function pipeline_arena_type_alloc(arena: *u8): i32;
export extern function pipeline_arena_num_types(arena: *u8): i32;

/** Type LE field offsets (match mega pipe_ar_ty_*). PLATFORM: SHARED. */
function w301_ty_name_len_off(): i32 { return 260; }
function w301_ty_elem_off(): i32 { return 264; }
function w301_ty_arr_off(): i32 { return 268; }

function pipe_ty_ord_named(): i32 { return 8; }
function pipe_ty_ord_ptr(): i32 { return 9; }
function pipe_ty_ord_slice(): i32 { return 11; }
function pipe_ty_slot_size(): i32 { return 532; }

/**
 * Clamp kind ordinal to TypeKind range; invalid -> TYPE_I32 (0).
 * @param ord i32 - raw kind ordinal
 * @return i32 - clamped 0..16
 * PLATFORM: SHARED.
 */
function pipe_ty_kind_from_ord(ord: i32): i32 {
  if (ord < 0) {
    return 0;
  }
  if (ord > 16) {
    return 0;
  }
  return ord;
}

/**
 * Zero one Type slot (532 bytes).
 * @param t *u8 - Type*; null -> no-op
 * PLATFORM: SHARED.
 */
function pipe_ty_zero_slot(t: *u8): void {
  if (t == 0 as *u8) {
    return;
  }
  let k: i32 = 0;
  let n: i32 = pipe_ty_slot_size();
  while (k < n) {
    unsafe {
      t[k] = 0;
    }
    k = k + 1;
  }
}

/**
 * memcmp-style equal of n bytes.
 * @param a *u8 - left
 * @param b *u8 - right
 * @param n i32 - byte count; n<=0 -> equal
 * @return i32 - 1 equal, 0 not
 * PLATFORM: SHARED.
 */
function pipe_ty_bytes_eq(a: *u8, b: *u8, n: i32): i32 {
  if (n <= 0) {
    return 1;
  }
  if (a == 0 as *u8) {
    return 0;
  }
  if (b == 0 as *u8) {
    return 0;
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      if (a[i] != b[i]) {
        return 0;
      }
    }
    i = i + 1;
  }
  return 1;
}

/**
 * Copy n bytes src -> dst.
 * @param dst *u8 - destination
 * @param src *u8 - source
 * @param n i32 - count
 * PLATFORM: SHARED.
 */
function pipe_ty_copy_bytes(dst: *u8, src: *u8, n: i32): void {
  if (dst == 0 as *u8) {
    return;
  }
  if (src == 0 as *u8) {
    return;
  }
  if (n <= 0) {
    return;
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      dst[i] = src[i];
    }
    i = i + 1;
  }
}

/**
 * Cap residual type_ptr via unsafe.
 * wave515: ban mid `tp=call()`; pipe-ptr cell (tip keeps U).
 * @param a *u8 - ASTArena*
 * @param ref i32 - type ref
 * @return *u8 - Type* or null
 * PLATFORM: SHARED.
 */
function pipe_ty_ptr(a: *u8, ref: i32): *u8 {
  let pcell: u8[8] = [];
  unsafe {
    pipe_store_ptr_slot(&pcell[0], 0, pipeline_arena_type_ptr(a, ref));
    return pipe_load_ptr_slot(&pcell[0], 0);
  }
}

/**
 * Cap residual type_alloc via unsafe.
 * wave515: ban mid `k=call()`; pipe-cell (tip keeps U).
 * @param a *u8 - ASTArena*
 * @return i32 - new type ref or 0
 * PLATFORM: SHARED.
 */
function pipe_ty_alloc(a: *u8): i32 {
  let cell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_arena_type_alloc(a));
    return pipe_load_i32_le(&cell[0], 0);
  }
}

/**
 * Cap residual num_types via unsafe.
 * wave515: ban mid `n=call()`; pipe-cell (tip keeps U).
 * @param a *u8 - ASTArena*
 * @return i32 - type count
 * PLATFORM: SHARED.
 */
function pipe_ty_num_types(a: *u8): i32 {
  let cell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_arena_num_types(a));
    return pipe_load_i32_le(&cell[0], 0);
  }
}

/**
 * LE i32 load via unsafe (T001). PLATFORM: SHARED.
 */
function w301_load_i32(base: *u8, off: i32): i32 {
  unsafe {
    return pipe_load_i32_le(base, off);
  }
}

/**
 * LE i32 store via unsafe (T001). PLATFORM: SHARED.
 */
function w301_store_i32(base: *u8, off: i32, v: i32): void {
  unsafe {
    pipe_store_i32_le(base, off, v);
  }
}

/**
 * Resolve Type* for ref with bounds check.
 * @param arena *u8 - ASTArena*
 * @param ref i32 - 1-based type ref
 * @return *u8 - Type* or null
 * PLATFORM: SHARED.
 */
function pipe_ty_slot_at(arena: *u8, ref: i32): *u8 {
  if (arena == 0 as *u8) {
    return 0 as *u8;
  }
  if (ref <= 0) {
    return 0 as *u8;
  }
  let nt: i32 = pipe_ty_num_types(arena);
  if (ref > nt) {
    return 0 as *u8;
  }
  return pipe_ty_ptr(arena, ref);
}

/**
 * Copy Type.name into out64; return name_len.
 * @param arena *u8 - ASTArena*
 * @param ref i32 - type ref
 * @param out64 *u8 - buffer
 * @return i32 - full name_len or 0
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_named_name_into(arena: *u8, ref: i32, out64: *u8): i32 {
  if (out64 == 0 as *u8) {
    return 0;
  }
  let t: *u8 = pipe_ty_slot_at(arena, ref);
  if (t == 0 as *u8) {
    return 0;
  }
  let n: i32 = w301_load_i32(t, w301_ty_name_len_off());
  let cn: i32 = n;
  if (cn > 255) {
    cn = 255;
  }
  if (cn > 0) {
    pipe_ty_copy_bytes(out64, t + 4, cn);
  }
  return n;
}

/**
 * Copy region_label into out64; return region_label_len.
 * @param arena *u8 - ASTArena*
 * @param ref i32 - type ref
 * @param out64 *u8 - buffer
 * @return i32 - full len or 0
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_region_label_into(arena: *u8, ref: i32, out64: *u8): i32 {
  if (out64 == 0 as *u8) {
    return 0;
  }
  let t: *u8 = pipe_ty_slot_at(arena, ref);
  if (t == 0 as *u8) {
    return 0;
  }
  let n: i32 = w301_load_i32(t, 528);
  if (n <= 0) {
    return 0;
  }
  let cn: i32 = n;
  if (cn > 255) {
    cn = 255;
  }
  if (cn > 0) {
    pipe_ty_copy_bytes(out64, t + 272, cn);
  }
  return n;
}

/**
 * Read region_label_len.
 * @param arena *u8 - ASTArena*
 * @param ref i32 - type ref
 * @return i32 - len or 0
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_region_label_len_at(arena: *u8, ref: i32): i32 {
  let t: *u8 = pipe_ty_slot_at(arena, ref);
  if (t == 0 as *u8) {
    return 0;
  }
  let n: i32 = w301_load_i32(t, 528);
  if (n > 0) {
    return n;
  }
  return 0;
}

/**
 * Write region label on TYPE_SLICE or TYPE_PTR.
 * @param arena *u8 - ASTArena*
 * @param ref i32 - type ref
 * @param label *u8 - label bytes
 * @param label_len i32 - 1..127
 * @return i32 - 1 ok, 0 fail
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_set_region_label_at(arena: *u8, ref: i32, label: *u8, label_len: i32): i32 {
  if (label == 0 as *u8) {
    return 0;
  }
  if (label_len <= 0) {
    return 0;
  }
  if (label_len > 255) {
    return 0;
  }
  let t: *u8 = pipe_ty_slot_at(arena, ref);
  if (t == 0 as *u8) {
    return 0;
  }
  let kind: i32 = w301_load_i32(t, 0);
  if (kind != pipe_ty_ord_slice()) {
    if (kind != pipe_ty_ord_ptr()) {
      return 0;
    }
  }
  let z: i32 = 0;
  while (z < 128) {
    unsafe {
      t[144 + z] = 0;
    }
    z = z + 1;
  }
  pipe_ty_copy_bytes(t + 272, label, label_len);
  w301_store_i32(t, 528, label_len);
  return 1;
}

/**
 * Find or allocate TYPE_SLICE.
 * @param a *u8 - ASTArena*
 * @param elem_ref i32 - elem type
 * @param region *u8 - label
 * @param region_len i32 - 0..127
 * @return i32 - type ref or 0
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_find_or_alloc_slice(a: *u8, elem_ref: i32, reg_lab: *u8, region_len: i32): i32 {
  // Flattened match loop: deep nested ifs were dropped by -E codegen (no C body).
  if (a == 0 as *u8) {
    return 0;
  }
  if (region_len < 0) {
    return 0;
  }
  if (region_len > 255) {
    return 0;
  }
  if (region_len > 0) {
    if (reg_lab == 0 as *u8) {
      return 0;
    }
  }
  let nt: i32 = pipe_ty_num_types(a);
  let k: i32 = 1;
  while (k <= nt) {
    let t: *u8 = pipe_ty_ptr(a, k);
    if (t == 0 as *u8) {
      k = k + 1;
      continue;
    }
    if (w301_load_i32(t, 0) != pipe_ty_ord_slice()) {
      k = k + 1;
      continue;
    }
    if (w301_load_i32(t, w301_ty_elem_off()) != elem_ref) {
      k = k + 1;
      continue;
    }
    if (w301_load_i32(t, w301_ty_arr_off()) != 0) {
      k = k + 1;
      continue;
    }
    if (w301_load_i32(t, w301_ty_name_len_off()) != 0) {
      k = k + 1;
      continue;
    }
    if (w301_load_i32(t, 528) != region_len) {
      k = k + 1;
      continue;
    }
    if (region_len == 0) {
      return k;
    }
    if (pipe_ty_bytes_eq(t + 272, reg_lab, region_len) != 0) {
      return k;
    }
    k = k + 1;
  }
  k = pipe_ty_alloc(a);
  if (k <= 0) {
    return 0;
  }
  let t2: *u8 = pipe_ty_ptr(a, k);
  if (t2 == 0 as *u8) {
    return 0;
  }
  pipe_ty_zero_slot(t2);
  w301_store_i32(t2, 0, pipe_ty_ord_slice());
  w301_store_i32(t2, w301_ty_elem_off(), elem_ref);
  if (region_len > 0) {
    if (reg_lab != 0 as *u8) {
      pipe_ty_copy_bytes(t2 + 272, reg_lab, region_len);
      w301_store_i32(t2, 528, region_len);
    }
  }
  return k;
}

/**
 * Find or allocate TYPE_PTR with optional region.
 * @param a *u8 - ASTArena*
 * @param elem_ref i32 - elem type >0
 * @param region *u8 - label
 * @param region_len i32 - 0..127
 * @return i32 - type ref or 0
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_find_or_alloc_ptr(a: *u8, elem_ref: i32, reg_lab: *u8, region_len: i32): i32 {
  // Flattened match loop: deep nested ifs were dropped by -E codegen (no C body).
  if (a == 0 as *u8) {
    return 0;
  }
  if (elem_ref <= 0) {
    return 0;
  }
  if (region_len < 0) {
    return 0;
  }
  if (region_len > 255) {
    return 0;
  }
  if (region_len > 0) {
    if (reg_lab == 0 as *u8) {
      return 0;
    }
  }
  let nt: i32 = pipe_ty_num_types(a);
  let k: i32 = 1;
  while (k <= nt) {
    let t: *u8 = pipe_ty_ptr(a, k);
    if (t == 0 as *u8) {
      k = k + 1;
      continue;
    }
    if (w301_load_i32(t, 0) != pipe_ty_ord_ptr()) {
      k = k + 1;
      continue;
    }
    if (w301_load_i32(t, w301_ty_elem_off()) != elem_ref) {
      k = k + 1;
      continue;
    }
    if (w301_load_i32(t, w301_ty_arr_off()) != 0) {
      k = k + 1;
      continue;
    }
    if (w301_load_i32(t, w301_ty_name_len_off()) != 0) {
      k = k + 1;
      continue;
    }
    if (w301_load_i32(t, 528) != region_len) {
      k = k + 1;
      continue;
    }
    if (region_len == 0) {
      return k;
    }
    if (pipe_ty_bytes_eq(t + 272, reg_lab, region_len) != 0) {
      return k;
    }
    k = k + 1;
  }
  k = pipe_ty_alloc(a);
  if (k <= 0) {
    return 0;
  }
  let t2: *u8 = pipe_ty_ptr(a, k);
  if (t2 == 0 as *u8) {
    return 0;
  }
  pipe_ty_zero_slot(t2);
  w301_store_i32(t2, 0, pipe_ty_ord_ptr());
  w301_store_i32(t2, w301_ty_elem_off(), elem_ref);
  if (region_len > 0) {
    if (reg_lab != 0 as *u8) {
      pipe_ty_copy_bytes(t2 + 272, reg_lab, region_len);
      w301_store_i32(t2, 528, region_len);
    }
  }
  return k;
}

/**
 * Read Type.kind ordinal; -1 invalid.
 * @param arena *u8 - ASTArena*
 * @param ref i32 - type ref
 * @return i32 - kind or -1
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32 {
  let t: *u8 = pipe_ty_slot_at(arena, ref);
  if (t == 0 as *u8) {
    return 0 - 1;
  }
  return w301_load_i32(t, 0);
}

/**
 * Read Type.elem_type_ref.
 * @param arena *u8 - ASTArena*
 * @param ref i32 - type ref
 * @return i32 - elem ref or 0
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32 {
  let t: *u8 = pipe_ty_slot_at(arena, ref);
  if (t == 0 as *u8) {
    return 0;
  }
  return w301_load_i32(t, w301_ty_elem_off());
}

/**
 * Stamp elem_type_ref + array_size.
 * @param arena *u8 - ASTArena*
 * @param ref i32 - type ref
 * @param elem_ref i32 - elem
 * @param array_size i32 - size/lanes
 * @return i32 - 1 ok, 0 fail
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_set_elem_array_size_at(arena: *u8, ref: i32, elem_ref: i32, array_size: i32): i32 {
  let t: *u8 = pipe_ty_slot_at(arena, ref);
  if (t == 0 as *u8) {
    return 0;
  }
  w301_store_i32(t, w301_ty_elem_off(), elem_ref);
  w301_store_i32(t, w301_ty_arr_off(), array_size);
  return 1;
}

/**
 * Read Type.array_size.
 * @param arena *u8 - ASTArena*
 * @param ref i32 - type ref
 * @return i32 - array_size or 0
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_array_size_at(arena: *u8, ref: i32): i32 {
  let t: *u8 = pipe_ty_slot_at(arena, ref);
  if (t == 0 as *u8) {
    return 0;
  }
  return w301_load_i32(t, w301_ty_arr_off());
}

/**
 * Find or allocate primitive by kind ordinal.
 * @param a *u8 - ASTArena*
 * @param kind_ord i32 - 0..16
 * @return i32 - type ref or 0
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_ensure_by_kind_ord(a: *u8, kind_ord: i32): i32 {
  if (a == 0 as *u8) {
    return 0;
  }
  if (kind_ord < 0) {
    return 0;
  }
  if (kind_ord > 16) {
    return 0;
  }
  let kind: i32 = pipe_ty_kind_from_ord(kind_ord);
  let nt: i32 = pipe_ty_num_types(a);
  let k: i32 = 1;
  while (k <= nt) {
    let t: *u8 = pipe_ty_ptr(a, k);
    if (t != 0 as *u8) {
      if (w301_load_i32(t, 0) == kind) {
        if (w301_load_i32(t, w301_ty_name_len_off()) == 0) {
          if (w301_load_i32(t, w301_ty_elem_off()) == 0) {
            if (w301_load_i32(t, w301_ty_arr_off()) == 0) {
              return k;
            }
          }
        }
      }
    }
    k = k + 1;
  }
  k = pipe_ty_alloc(a);
  if (k <= 0) {
    return 0;
  }
  let t2: *u8 = pipe_ty_ptr(a, k);
  if (t2 == 0 as *u8) {
    return 0;
  }
  pipe_ty_zero_slot(t2);
  w301_store_i32(t2, 0, kind);
  return k;
}

/**
 * Init pre-allocated primitive slot.
 * @param a *u8 - ASTArena*
 * @param ref i32 - type ref
 * @param kind_ord i32 - 0..16
 * @return i32 - 1 ok, 0 fail
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_init_primitive_kind_at(a: *u8, ref: i32, kind_ord: i32): i32 {
  if (a == 0 as *u8) {
    return 0;
  }
  if (ref <= 0) {
    return 0;
  }
  if (kind_ord < 0) {
    return 0;
  }
  if (kind_ord > 16) {
    return 0;
  }
  let nt: i32 = pipe_ty_num_types(a);
  if (ref > nt) {
    return 0;
  }
  let t: *u8 = pipe_ty_ptr(a, ref);
  if (t == 0 as *u8) {
    return 0;
  }
  pipe_ty_zero_slot(t);
  w301_store_i32(t, 0, pipe_ty_kind_from_ord(kind_ord));
  return 1;
}

/**
 * Init pre-allocated TYPE_NAMED slot.
 * @param a *u8 - ASTArena*
 * @param ref i32 - type ref
 * @param name *u8 - name
 * @param name_len i32 - 1..255
 * @return i32 - 1 ok, 0 fail
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_init_named_at(a: *u8, ref: i32, name: *u8, name_len: i32): i32 {
  if (a == 0 as *u8) {
    return 0;
  }
  if (ref <= 0) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len <= 0) {
    return 0;
  }
  if (name_len > 255) {
    return 0;
  }
  let nt: i32 = pipe_ty_num_types(a);
  if (ref > nt) {
    return 0;
  }
  let t: *u8 = pipe_ty_ptr(a, ref);
  if (t == 0 as *u8) {
    return 0;
  }
  pipe_ty_zero_slot(t);
  w301_store_i32(t, 0, pipe_ty_ord_named());
  w301_store_i32(t, w301_ty_name_len_off(), name_len);
  pipe_ty_copy_bytes(t + 4, name, name_len);
  return 1;
}

/**
 * Init pre-allocated compound slot.
 * @param a *u8 - ASTArena*
 * @param ref i32 - type ref
 * @param kind_ord i32 - 0..15
 * @param elem_ref i32 - elem
 * @param array_size i32 - size
 * @return i32 - 1 ok, 0 fail
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_init_compound_kind_at(a: *u8, ref: i32, kind_ord: i32, elem_ref: i32,
                                                    array_size: i32): i32 {
  if (a == 0 as *u8) {
    return 0;
  }
  if (ref <= 0) {
    return 0;
  }
  if (kind_ord < 0) {
    return 0;
  }
  if (kind_ord > 15) {
    return 0;
  }
  let nt: i32 = pipe_ty_num_types(a);
  if (ref > nt) {
    return 0;
  }
  let t: *u8 = pipe_ty_ptr(a, ref);
  if (t == 0 as *u8) {
    return 0;
  }
  pipe_ty_zero_slot(t);
  w301_store_i32(t, 0, pipe_ty_kind_from_ord(kind_ord));
  w301_store_i32(t, w301_ty_elem_off(), elem_ref);
  w301_store_i32(t, w301_ty_arr_off(), array_size);
  return 1;
}

/**
 * Find or allocate TYPE_NAMED by name.
 * @param a *u8 - ASTArena*
 * @param name *u8 - name
 * @param name_len i32 - 1..255
 * @return i32 - type ref or 0
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_find_or_alloc_named(a: *u8, name: *u8, name_len: i32): i32 {
  if (a == 0 as *u8) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len <= 0) {
    return 0;
  }
  if (name_len > 255) {
    return 0;
  }
  let nt: i32 = pipe_ty_num_types(a);
  let k: i32 = 1;
  while (k <= nt) {
    let t: *u8 = pipe_ty_ptr(a, k);
    if (t != 0 as *u8) {
      if (w301_load_i32(t, 0) == pipe_ty_ord_named()) {
        if (w301_load_i32(t, w301_ty_name_len_off()) == name_len) {
          if (pipe_ty_bytes_eq(t + 4, name, name_len) != 0) {
            return k;
          }
        }
      }
    }
    k = k + 1;
  }
  k = pipe_ty_alloc(a);
  if (k <= 0) {
    return 0;
  }
  let t2: *u8 = pipe_ty_ptr(a, k);
  if (t2 == 0 as *u8) {
    return 0;
  }
  pipe_ty_zero_slot(t2);
  w301_store_i32(t2, 0, pipe_ty_ord_named());
  w301_store_i32(t2, w301_ty_name_len_off(), name_len);
  pipe_ty_copy_bytes(t2 + 4, name, name_len);
  return k;
}

/**
 * Find or allocate compound by kind+elem+size (unlabelled).
 * @param a *u8 - ASTArena*
 * @param kind_ord i32 - 0..15
 * @param elem_ref i32 - elem
 * @param array_size i32 - size
 * @return i32 - type ref or 0
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_find_or_alloc_compound(a: *u8, kind_ord: i32, elem_ref: i32,
                                                     array_size: i32): i32 {
  if (a == 0 as *u8) {
    return 0;
  }
  if (kind_ord < 0) {
    return 0;
  }
  if (kind_ord > 15) {
    return 0;
  }
  let kind: i32 = pipe_ty_kind_from_ord(kind_ord);
  let nt: i32 = pipe_ty_num_types(a);
  let k: i32 = 1;
  while (k <= nt) {
    let t: *u8 = pipe_ty_ptr(a, k);
    if (t != 0 as *u8) {
      if (w301_load_i32(t, 0) == kind) {
        if (w301_load_i32(t, w301_ty_elem_off()) == elem_ref) {
          if (w301_load_i32(t, w301_ty_arr_off()) == array_size) {
            if (w301_load_i32(t, w301_ty_name_len_off()) == 0) {
              if (w301_load_i32(t, 528) == 0) {
                return k;
              }
            }
          }
        }
      }
    }
    k = k + 1;
  }
  k = pipe_ty_alloc(a);
  if (k <= 0) {
    return 0;
  }
  let t2: *u8 = pipe_ty_ptr(a, k);
  if (t2 == 0 as *u8) {
    return 0;
  }
  pipe_ty_zero_slot(t2);
  w301_store_i32(t2, 0, kind);
  w301_store_i32(t2, w301_ty_elem_off(), elem_ref);
  w301_store_i32(t2, w301_ty_arr_off(), array_size);
  return k;
}

// end wave270 pure-owned leave


