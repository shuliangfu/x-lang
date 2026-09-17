// Thin pure: wave307 M2 — struct_layout Cap residual C→.x (was wave266 C thin).
// StructLayout multi-module map + field/offset faces; 36 exports.
// G.7: bodies match runtime_pipeline_abi.x wave266 leave.
// PRODUCT inject: -E+$CC via pipeline_abi_inject_struct_layout_thin
// (ALLOW_E_REPLACE + stamp). File-local maps OK under -E+$CC.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function xlang_ptr_slot_get(arr: *u8, i: i32): *u8;
export extern function xlang_ptr_slot_set(arr: *u8, i: i32, p: *u8): void;
export extern function glue_type_align_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_type_is_empty_struct_c(module: *u8, arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;
export extern function pipeline_asm_emit_ctx_module_get(): *u8;
export extern "C" function malloc(n: usize): *u8;
export extern "C" function free(p: *u8): void;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;

let g_pipe_sl_mod: u8[1024] = [];
let g_pipe_sl_n: i32[128] = [];
let g_pipe_sl_cap: i32[128] = [];
let g_pipe_sl_layouts: u8[1024] = [];
let g_pipe_sl_fn: i32[128] = [];
let g_pipe_sl_fcap: i32[128] = [];
let g_pipe_sl_fields: u8[1024] = [];
let g_pipe_sl_tpn: i32[128] = [];
let g_pipe_sl_tpcap: i32[128] = [];
let g_pipe_sl_tp: u8[1024] = [];

/**
 * Byte size of one pure StructLayout entry (C 160 + tp meta 8).
 * @return i32 - 296
 * PLATFORM: SHARED LP64.
 */
function pipe_sl_layout_size(): i32 {
  return 296;
}

/**
 * Byte size of one StructLayoutFieldEntry.
 * @return i32 - 272
 * PLATFORM: SHARED LP64 - must match C sizeof(StructLayoutFieldEntry).
 */
function pipe_sl_field_size(): i32 {
  return 272;
}

/**
 * Byte size of one LayoutTypeParamEntry.
 * @return i32 - 260
 * PLATFORM: SHARED LP64 - must match C sizeof(LayoutTypeParamEntry).
 */
function pipe_sl_tp_size(): i32 {
  return 260;
}

/**
 * Offsets within pure layout entry.
 */
function pipe_sl_off_name_len(): i32 { return 256; }
function pipe_sl_off_field_base(): i32 { return 260; }
function pipe_sl_off_num_fields(): i32 { return 264; }
function pipe_sl_off_allow_padding(): i32 { return 268; }
function pipe_sl_off_soa(): i32 { return 272; }
function pipe_sl_off_packed(): i32 { return 276; }
function pipe_sl_off_repr_compatible(): i32 { return 280; }
function pipe_sl_off_is_export(): i32 { return 284; }
function pipe_sl_off_tp_base(): i32 { return 288; }
function pipe_sl_off_tp_count(): i32 { return 292; }

/**
 * Offsets within field entry.
 */
function pipe_sl_foff_name_len(): i32 { return 256; }
function pipe_sl_foff_offset(): i32 { return 260; }
function pipe_sl_foff_type_ref(): i32 { return 264; }
function pipe_sl_foff_align(): i32 { return 268; }

/**
 * LP64 offsetof(struct ast_Module, num_struct_layouts) == 16.
 * @return i32 - 16
 * PLATFORM: SHARED LP64.
 */
function pipe_sl_off_header_n(): i32 {
  return 16;
}

/**
 * Read module.num_struct_layouts header (null -> 0).
 * @param module *u8 - opaque ast_Module
 * @return i32 - header count
 */
function pipe_sl_get_header_n(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(module, pipe_sl_off_header_n());
}

/**
 * Write module.num_struct_layouts header (null-safe).
 * @param module *u8 - opaque ast_Module
 * @param n i32 - live layout count
 * @return void
 */
function pipe_sl_set_header_n(module: *u8, n: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  pipe_store_i32_le(module, pipe_sl_off_header_n(), n);
}

/**
 * Find map slot for module pointer.
 * @param module *u8 - module key; null -> -1
 * @return i32 - slot 0..127 or -1
 */
function pipe_sl_find_slot(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  let i: i32 = 0;
  while (i < 128) {
    let k: *u8 = xlang_ptr_slot_get(&g_pipe_sl_mod[0], i);
    if (k == module) {
      return i;
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Soft-reset pure counts when header num_struct_layouts is 0.
 * Zeros layout/field/tp live n; keeps malloc capacity.
 * @param module *u8 - module key
 * @return void
 */
function pipe_sl_soft_sync(module: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  if (pipe_sl_get_header_n(module) != 0) {
    return;
  }
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return;
  }
  g_pipe_sl_n[s] = 0;
  g_pipe_sl_fn[s] = 0;
  g_pipe_sl_tpn[s] = 0;
}

/**
 * Find or allocate a map slot for module.
 * @param module *u8 - module key; null -> -1
 * @return i32 - slot or -1 if map full
 */
function pipe_sl_find_or_create(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  pipe_sl_soft_sync(module);
  let found: i32 = pipe_sl_find_slot(module);
  if (found >= 0) {
    return found;
  }
  let i: i32 = 0;
  while (i < 128) {
    let k: *u8 = xlang_ptr_slot_get(&g_pipe_sl_mod[0], i);
    if (k == 0 as *u8) {
      xlang_ptr_slot_set(&g_pipe_sl_mod[0], i, module);
      g_pipe_sl_n[i] = 0;
      g_pipe_sl_cap[i] = 0;
      xlang_ptr_slot_set(&g_pipe_sl_layouts[0], i, 0 as *u8);
      g_pipe_sl_fn[i] = 0;
      g_pipe_sl_fcap[i] = 0;
      xlang_ptr_slot_set(&g_pipe_sl_fields[0], i, 0 as *u8);
      g_pipe_sl_tpn[i] = 0;
      g_pipe_sl_tpcap[i] = 0;
      xlang_ptr_slot_set(&g_pipe_sl_tp[0], i, 0 as *u8);
      return i;
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Ensure layout table capacity >= need for slot (malloc grow, double).
 * @param slot i32 - map slot
 * @param need i32 - required capacity
 * @return i32 - 1 ok, 0 fail
 */
function pipe_sl_ensure_layouts(slot: i32, need: i32): i32 {
  if (slot < 0) {
    return 0;
  }
  if (slot >= 128) {
    return 0;
  }
  if (need <= 0) {
    return 1;
  }
  let cap: i32 = g_pipe_sl_cap[slot];
  if (cap >= need) {
    return 1;
  }
  let new_cap: i32 = cap;
  if (new_cap < 4) {
    new_cap = 4;
  }
  while (new_cap < need) {
    new_cap = new_cap * 2;
  }
  let esz: i32 = pipe_sl_layout_size();
  let nbytes: usize = (new_cap * esz) as usize;
  let np: *u8 = 0 as *u8;
  unsafe {
    np = malloc(nbytes);
  }
  if (np == 0 as *u8) {
    return 0;
  }
  unsafe {
    memset(np, 0, nbytes);
  }
  let old: *u8 = xlang_ptr_slot_get(&g_pipe_sl_layouts[0], slot);
  let old_n: i32 = g_pipe_sl_n[slot];
  if (old != 0 as *u8) {
    if (old_n > 0) {
      let copy_n: usize = (old_n * esz) as usize;
      unsafe {
        memcpy(np, old, copy_n);
      }
    }
    unsafe {
      free(old);
    }
  }
  xlang_ptr_slot_set(&g_pipe_sl_layouts[0], slot, np);
  g_pipe_sl_cap[slot] = new_cap;
  return 1;
}

/**
 * Ensure field table capacity >= need for slot.
 * @param slot i32 - map slot
 * @param need i32 - required capacity
 * @return i32 - 1 ok, 0 fail
 */
function pipe_sl_ensure_fields(slot: i32, need: i32): i32 {
  if (slot < 0) {
    return 0;
  }
  if (slot >= 128) {
    return 0;
  }
  if (need <= 0) {
    return 1;
  }
  let cap: i32 = g_pipe_sl_fcap[slot];
  if (cap >= need) {
    return 1;
  }
  let new_cap: i32 = cap;
  if (new_cap < 4) {
    new_cap = 4;
  }
  while (new_cap < need) {
    new_cap = new_cap * 2;
  }
  let esz: i32 = pipe_sl_field_size();
  let nbytes: usize = (new_cap * esz) as usize;
  let np: *u8 = 0 as *u8;
  unsafe {
    np = malloc(nbytes);
  }
  if (np == 0 as *u8) {
    return 0;
  }
  unsafe {
    memset(np, 0, nbytes);
  }
  let old: *u8 = xlang_ptr_slot_get(&g_pipe_sl_fields[0], slot);
  let old_n: i32 = g_pipe_sl_fn[slot];
  if (old != 0 as *u8) {
    if (old_n > 0) {
      let copy_n: usize = (old_n * esz) as usize;
      unsafe {
        memcpy(np, old, copy_n);
      }
    }
    unsafe {
      free(old);
    }
  }
  xlang_ptr_slot_set(&g_pipe_sl_fields[0], slot, np);
  g_pipe_sl_fcap[slot] = new_cap;
  return 1;
}

/**
 * Ensure type-param table capacity >= need for slot.
 * @param slot i32 - map slot
 * @param need i32 - required capacity
 * @return i32 - 1 ok, 0 fail
 */
function pipe_sl_ensure_tp(slot: i32, need: i32): i32 {
  if (slot < 0) {
    return 0;
  }
  if (slot >= 128) {
    return 0;
  }
  if (need <= 0) {
    return 1;
  }
  let cap: i32 = g_pipe_sl_tpcap[slot];
  if (cap >= need) {
    return 1;
  }
  let new_cap: i32 = cap;
  if (new_cap < 4) {
    new_cap = 4;
  }
  while (new_cap < need) {
    new_cap = new_cap * 2;
  }
  let esz: i32 = pipe_sl_tp_size();
  let nbytes: usize = (new_cap * esz) as usize;
  let np: *u8 = 0 as *u8;
  unsafe {
    np = malloc(nbytes);
  }
  if (np == 0 as *u8) {
    return 0;
  }
  unsafe {
    memset(np, 0, nbytes);
  }
  let old: *u8 = xlang_ptr_slot_get(&g_pipe_sl_tp[0], slot);
  let old_n: i32 = g_pipe_sl_tpn[slot];
  if (old != 0 as *u8) {
    if (old_n > 0) {
      let copy_n: usize = (old_n * esz) as usize;
      unsafe {
        memcpy(np, old, copy_n);
      }
    }
    unsafe {
      free(old);
    }
  }
  xlang_ptr_slot_set(&g_pipe_sl_tp[0], slot, np);
  g_pipe_sl_tpcap[slot] = new_cap;
  return 1;
}

/**
 * Pointer to layout entry at (slot, idx); null if OOB.
 * @param slot i32 - map slot
 * @param idx i32 - layout index
 * @return *u8 - entry base or null
 */
function pipe_sl_layout_at(slot: i32, idx: i32): *u8 {
  if (slot < 0) {
    return 0 as *u8;
  }
  if (slot >= 128) {
    return 0 as *u8;
  }
  if (idx < 0) {
    return 0 as *u8;
  }
  if (idx >= g_pipe_sl_n[slot]) {
    return 0 as *u8;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_sl_layouts[0], slot);
  if (base == 0 as *u8) {
    return 0 as *u8;
  }
  return base + (idx * pipe_sl_layout_size());
}

/**
 * Pointer to field entry at absolute field index; null if OOB.
 * @param slot i32 - map slot
 * @param abs i32 - absolute field index in module field pool
 * @return *u8 - field entry or null
 */
function pipe_sl_field_abs(slot: i32, abs: i32): *u8 {
  if (slot < 0) {
    return 0 as *u8;
  }
  if (slot >= 128) {
    return 0 as *u8;
  }
  if (abs < 0) {
    return 0 as *u8;
  }
  if (abs >= g_pipe_sl_fn[slot]) {
    return 0 as *u8;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_sl_fields[0], slot);
  if (base == 0 as *u8) {
    return 0 as *u8;
  }
  return base + (abs * pipe_sl_field_size());
}

/**
 * Get or create field entry for layout li field j (create=1 grows pool).
 * Mirrors Cap module_layout_field_entry field_base semantics (-1 unset).
 * @param module *u8 - module
 * @param li i32 - layout index
 * @param j i32 - field index
 * @param create i32 - 0 read, 1 create
 * @return *u8 - field entry or null
 */
function pipe_sl_field_entry(module: *u8, li: i32, j: i32, create: i32): *u8 {
  if (module == 0 as *u8) {
    return 0 as *u8;
  }
  if (li < 0) {
    return 0 as *u8;
  }
  if (j < 0) {
    return 0 as *u8;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return 0 as *u8;
  }
  let sl: *u8 = pipe_sl_layout_at(s, li);
  if (sl == 0 as *u8) {
    return 0 as *u8;
  }
  let fb: i32 = pipe_load_i32_le(sl, pipe_sl_off_field_base());
  let nf: i32 = pipe_load_i32_le(sl, pipe_sl_off_num_fields());
  if (create == 0) {
    if (j >= nf) {
      return 0 as *u8;
    }
    if (fb < 0) {
      return 0 as *u8;
    }
    let abs0: i32 = fb + j;
    return pipe_sl_field_abs(s, abs0);
  }
  if (fb < 0) {
    fb = g_pipe_sl_fn[s];
    pipe_store_i32_le(sl, pipe_sl_off_field_base(), fb);
  }
  let abs1: i32 = fb + j;
  while (g_pipe_sl_fn[s] <= abs1) {
    let cur: i32 = g_pipe_sl_fn[s];
    if (pipe_sl_ensure_fields(s, cur + 1) == 0) {
      return 0 as *u8;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_sl_fields[0], s);
    if (base == 0 as *u8) {
      return 0 as *u8;
    }
    let off: i32 = cur * pipe_sl_field_size();
    unsafe {
      memset(base + off, 0, pipe_sl_field_size() as usize);
    }
    g_pipe_sl_fn[s] = cur + 1;
  }
  if (j + 1 > nf) {
    pipe_store_i32_le(sl, pipe_sl_off_num_fields(), j + 1);
  }
  return pipe_sl_field_abs(s, abs1);
}

/**
 * Soft-reset pure struct_layout live counts (keep malloc capacity).
 * @param module *u8 - module key; null -> no-op
 * @return void
 * PLATFORM: SHARED - product hybrid owns live count.
 */
#[no_mangle]
export function pipeline_module_struct_layout_storage_reset(module: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    pipe_sl_set_header_n(module, 0);
    return;
  }
  g_pipe_sl_n[s] = 0;
  g_pipe_sl_fn[s] = 0;
  g_pipe_sl_tpn[s] = 0;
  pipe_sl_set_header_n(module, 0);
}

/**
 * Free pure struct_layout storage for one module and clear map slot.
 * @param module *u8 - module key; null -> no-op
 * @return void
 * wave266: called from Cap ast_pool_module_release (strong pure).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_struct_layout_storage_release(module: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return;
  }
  let e: *u8 = xlang_ptr_slot_get(&g_pipe_sl_layouts[0], s);
  if (e != 0 as *u8) {
    unsafe {
      free(e);
    }
  }
  let f: *u8 = xlang_ptr_slot_get(&g_pipe_sl_fields[0], s);
  if (f != 0 as *u8) {
    unsafe {
      free(f);
    }
  }
  let t: *u8 = xlang_ptr_slot_get(&g_pipe_sl_tp[0], s);
  if (t != 0 as *u8) {
    unsafe {
      free(t);
    }
  }
  xlang_ptr_slot_set(&g_pipe_sl_mod[0], s, 0 as *u8);
  xlang_ptr_slot_set(&g_pipe_sl_layouts[0], s, 0 as *u8);
  xlang_ptr_slot_set(&g_pipe_sl_fields[0], s, 0 as *u8);
  xlang_ptr_slot_set(&g_pipe_sl_tp[0], s, 0 as *u8);
  g_pipe_sl_n[s] = 0;
  g_pipe_sl_cap[s] = 0;
  g_pipe_sl_fn[s] = 0;
  g_pipe_sl_fcap[s] = 0;
  g_pipe_sl_tpn[s] = 0;
  g_pipe_sl_tpcap[s] = 0;
  pipe_sl_set_header_n(module, 0);
}

/**
 * Allocate one StructLayout for module; return index or -1.
 * Sets field_base=-1 and tp_base=-1 (unhooked pools).
 * @param module *u8 - opaque ast_Module; null -> -1
 * @return i32 - new layout index or -1
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_struct_layout_alloc(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  let s: i32 = pipe_sl_find_or_create(module);
  if (s < 0) {
    return 0 - 1;
  }
  let n: i32 = g_pipe_sl_n[s];
  if (pipe_sl_ensure_layouts(s, n + 1) == 0) {
    return 0 - 1;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_sl_layouts[0], s);
  if (base == 0 as *u8) {
    return 0 - 1;
  }
  let off: i32 = n * pipe_sl_layout_size();
  unsafe {
    memset(base + off, 0, pipe_sl_layout_size() as usize);
  }
  let sl: *u8 = base + off;
  let m1: i32 = 0 - 1;
  pipe_store_i32_le(sl, pipe_sl_off_field_base(), m1);
  pipe_store_i32_le(sl, pipe_sl_off_tp_base(), m1);
  g_pipe_sl_n[s] = n + 1;
  pipe_sl_set_header_n(module, n + 1);
  return n;
}

/**
 * Reset one layout slot to empty (field_base/tp_base=-1, zero flags).
 * @param module *u8 - module
 * @param idx i32 - layout index
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_struct_layout_reset_slot(module: *u8, idx: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    return;
  }
  unsafe {
    memset(sl, 0, pipe_sl_layout_size() as usize);
  }
  let m1: i32 = 0 - 1;
  pipe_store_i32_le(sl, pipe_sl_off_field_base(), m1);
  pipe_store_i32_le(sl, pipe_sl_off_tp_base(), m1);
}

/**
 * Set layout name (content 1..255).
 * @param module *u8 - module
 * @param idx i32 - layout index
 * @param bytes *u8 - name bytes
 * @param len i32 - content length 1..127
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_struct_layout_set_name(module: *u8, idx: i32, bytes: *u8, len: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  if (bytes == 0 as *u8) {
    return;
  }
  if (len <= 0) {
    return;
  }
  if (len > 255) {
    return;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    return;
  }
  pipe_store_i32_le(sl, pipe_sl_off_name_len(), len);
  let i: i32 = 0;
  while (i < len) {
    unsafe {
      sl[i] = bytes[i];
    }
    i = i + 1;
  }
  while (i < 128) {
    unsafe {
      sl[i] = 0;
    }
    i = i + 1;
  }
}

/**
 * Set field j on layout li (create field pool entry).
 * @param module *u8 - module
 * @param li i32 - layout index
 * @param j i32 - field index
 * @param fname_bytes *u8 - field name
 * @param fname_len i32 - 1..127
 * @param ftype_ref i32 - field type ref
 * @param foff i32 - field offset
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_struct_layout_set_field(module: *u8, li: i32, j: i32, fname_bytes: *u8, fname_len: i32, ftype_ref: i32, foff: i32): void {
  if (fname_len <= 0) {
    return;
  }
  if (fname_len > 255) {
    return;
  }
  if (j < 0) {
    return;
  }
  let fe: *u8 = pipe_sl_field_entry(module, li, j, 1);
  if (fe == 0 as *u8) {
    return;
  }
  pipe_store_i32_le(fe, pipe_sl_foff_name_len(), fname_len);
  pipe_store_i32_le(fe, pipe_sl_foff_type_ref(), ftype_ref);
  pipe_store_i32_le(fe, pipe_sl_foff_offset(), foff);
  pipe_store_i32_le(fe, pipe_sl_foff_align(), 0);
  let i: i32 = 0;
  while (i < 128) {
    unsafe {
      fe[i] = 0;
    }
    i = i + 1;
  }
  if (fname_bytes != 0 as *u8) {
    i = 0;
    while (i < fname_len) {
      unsafe {
        fe[i] = fname_bytes[i];
      }
      i = i + 1;
    }
  }
}

/**
 * Read layout name length.
 * @param module *u8 - module
 * @param idx i32 - layout index
 * @return i32 - name_len or 0
 */
#[no_mangle]
export function pipeline_module_struct_layout_name_len(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(sl, pipe_sl_off_name_len());
}

/**
 * Copy layout name into out64 (128-byte row).
 * @param module *u8 - module
 * @param idx i32 - layout index
 * @param out64 *u8 - 128-byte dest
 * @return void
 */
#[no_mangle]
export function pipeline_module_struct_layout_name_into(module: *u8, idx: i32, out64: *u8): void {
  if (out64 == 0 as *u8) {
    return;
  }
  if (module == 0 as *u8) {
    unsafe {
      memset(out64, 0, 256 as usize);
    }
    return;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    unsafe {
      memset(out64, 0, 256 as usize);
    }
    return;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    unsafe {
      memset(out64, 0, 256 as usize);
    }
    return;
  }
  unsafe {
    memcpy(out64, sl, 256 as usize);
  }
}

/**
 * Read one layout name byte; return i32 for Cap export-extern contract.
 * @param module *u8 - module
 * @param idx i32 - layout index
 * @param off i32 - byte offset 0..127
 * @return i32 - byte or 0
 */
#[no_mangle]
export function pipeline_module_struct_layout_name_byte_at(module: *u8, idx: i32, off: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  if (off < 0) {
    return 0;
  }
  if (off >= 128) {
    return 0;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    return 0;
  }
  let nlen: i32 = pipe_load_i32_le(sl, pipe_sl_off_name_len());
  if (off >= nlen) {
    return 0;
  }
  unsafe {
    return sl[off] as i32;
  }
}

/**
 * Read layout num_fields.
 * @param module *u8 - module
 * @param idx i32 - layout index
 * @return i32 - num_fields or 0
 */
#[no_mangle]
export function pipeline_module_struct_layout_num_fields(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(sl, pipe_sl_off_num_fields());
}

/**
 * Write layout num_fields.
 * @param module *u8 - module
 * @param idx i32 - layout index
 * @param nf i32 - field count
 * @return void
 */
#[no_mangle]
export function pipeline_module_struct_layout_set_num_fields(module: *u8, idx: i32, nf: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    return;
  }
  pipe_store_i32_le(sl, pipe_sl_off_num_fields(), nf);
}

/**
 * Read field type_ref.
 * @param module *u8 - module
 * @param li i32 - layout index
 * @param j i32 - field index
 * @return i32 - type_ref or 0
 */
#[no_mangle]
export function pipeline_module_struct_layout_field_type_ref(module: *u8, li: i32, j: i32): i32 {
  if (j < 0) {
    return 0;
  }
  let fe: *u8 = pipe_sl_field_entry(module, li, j, 0);
  if (fe == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(fe, pipe_sl_foff_type_ref());
}

/**
 * Read field name length (content 1..255 valid).
 * @param module *u8 - module
 * @param li i32 - layout index
 * @param j i32 - field index
 * @return i32 - name_len or 0
 */
#[no_mangle]
export function pipeline_module_struct_layout_field_name_len(module: *u8, li: i32, j: i32): i32 {
  if (j < 0) {
    return 0;
  }
  let fe: *u8 = pipe_sl_field_entry(module, li, j, 0);
  if (fe == 0 as *u8) {
    return 0;
  }
  let fl: i32 = pipe_load_i32_le(fe, pipe_sl_foff_name_len());
  if (fl > 0) {
    if (fl <= 255) {
      return fl;
    }
  }
  return 0;
}

/**
 * Copy field name into out64 (128-byte row).
 * @param module *u8 - module
 * @param li i32 - layout index
 * @param j i32 - field index
 * @param out64 *u8 - 128-byte dest
 * @return void
 */
#[no_mangle]
export function pipeline_module_struct_layout_field_name_into(module: *u8, li: i32, j: i32, out64: *u8): void {
  if (out64 == 0 as *u8) {
    return;
  }
  if (j < 0) {
    unsafe {
      memset(out64, 0, 256 as usize);
    }
    return;
  }
  let fe: *u8 = pipe_sl_field_entry(module, li, j, 0);
  if (fe == 0 as *u8) {
    unsafe {
      memset(out64, 0, 256 as usize);
    }
    return;
  }
  unsafe {
    memcpy(out64, fe, 256 as usize);
  }
}

/**
 * Write field offset.
 * @param module *u8 - module
 * @param li i32 - layout index
 * @param j i32 - field index
 * @param foff i32 - offset
 * @return void
 */
#[no_mangle]
export function pipeline_module_struct_layout_set_field_offset(module: *u8, li: i32, j: i32, foff: i32): void {
  if (j < 0) {
    return;
  }
  let fe: *u8 = pipe_sl_field_entry(module, li, j, 0);
  if (fe == 0 as *u8) {
    return;
  }
  pipe_store_i32_le(fe, pipe_sl_foff_offset(), foff);
}

/**
 * Read field offset.
 * @param module *u8 - module
 * @param li i32 - layout index
 * @param j i32 - field index
 * @return i32 - offset or 0
 */
#[no_mangle]
export function pipeline_module_struct_layout_field_offset_at(module: *u8, li: i32, j: i32): i32 {
  if (j < 0) {
    return 0;
  }
  let fe: *u8 = pipe_sl_field_entry(module, li, j, 0);
  if (fe == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(fe, pipe_sl_foff_offset());
}

/**
 * Read field align(N); 0 means type-only align.
 * @param module *u8 - module
 * @param li i32 - layout index
 * @param j i32 - field index
 * @return i32 - align or 0
 */
#[no_mangle]
export function pipeline_module_struct_layout_field_align_at(module: *u8, li: i32, j: i32): i32 {
  if (j < 0) {
    return 0;
  }
  let fe: *u8 = pipe_sl_field_entry(module, li, j, 0);
  if (fe == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(fe, pipe_sl_foff_align());
}

/**
 * Write field align(N).
 * @param module *u8 - module
 * @param li i32 - layout index
 * @param j i32 - field index
 * @param al i32 - align (>=0)
 * @return void
 */
#[no_mangle]
export function pipeline_module_struct_layout_set_field_align(module: *u8, li: i32, j: i32, al: i32): void {
  if (j < 0) {
    return;
  }
  if (al < 0) {
    return;
  }
  let fe: *u8 = pipe_sl_field_entry(module, li, j, 0);
  if (fe == 0 as *u8) {
    return;
  }
  pipe_store_i32_le(fe, pipe_sl_foff_align(), al);
}

/**
 * Append type-param name for struct Name<T,...>.
 * @param module *u8 - module
 * @param li i32 - layout index
 * @param name *u8 - param name
 * @param name_len i32 - 1..255
 * @return i32 - 0 ok, -1 fail
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_struct_layout_append_type_param(module: *u8, li: i32, name: *u8, name_len: i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (li < 0) {
    return 0 - 1;
  }
  if (name == 0 as *u8) {
    return 0 - 1;
  }
  if (name_len <= 0) {
    return 0 - 1;
  }
  if (name_len > 255) {
    return 0 - 1;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_or_create(module);
  if (s < 0) {
    return 0 - 1;
  }
  let sl: *u8 = pipe_sl_layout_at(s, li);
  if (sl == 0 as *u8) {
    return 0 - 1;
  }
  let tp_base: i32 = pipe_load_i32_le(sl, pipe_sl_off_tp_base());
  let tp_count: i32 = pipe_load_i32_le(sl, pipe_sl_off_tp_count());
  if (tp_base < 0) {
    tp_base = g_pipe_sl_tpn[s];
    tp_count = 0;
    pipe_store_i32_le(sl, pipe_sl_off_tp_base(), tp_base);
    pipe_store_i32_le(sl, pipe_sl_off_tp_count(), 0);
  }
  let abs: i32 = tp_base + tp_count;
  while (g_pipe_sl_tpn[s] <= abs) {
    let cur: i32 = g_pipe_sl_tpn[s];
    if (pipe_sl_ensure_tp(s, cur + 1) == 0) {
      return 0 - 1;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_sl_tp[0], s);
    if (base == 0 as *u8) {
      return 0 - 1;
    }
    let off: i32 = cur * pipe_sl_tp_size();
    unsafe {
      memset(base + off, 0, pipe_sl_tp_size() as usize);
    }
    g_pipe_sl_tpn[s] = cur + 1;
  }
  let tbase: *u8 = xlang_ptr_slot_get(&g_pipe_sl_tp[0], s);
  if (tbase == 0 as *u8) {
    return 0 - 1;
  }
  let ent: *u8 = tbase + (abs * pipe_sl_tp_size());
  unsafe {
    memset(ent, 0, pipe_sl_tp_size() as usize);
  }
  pipe_store_i32_le(ent, 128, name_len);
  let i: i32 = 0;
  while (i < name_len) {
    unsafe {
      ent[i] = name[i];
    }
    i = i + 1;
  }
  pipe_store_i32_le(sl, pipe_sl_off_tp_count(), tp_count + 1);
  return 0;
}

/**
 * Number of type params on layout li.
 * @param module *u8 - module
 * @param li i32 - layout index
 * @return i32 - count or 0
 */
#[no_mangle]
export function pipeline_module_struct_layout_num_type_params_at(module: *u8, li: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let sl: *u8 = pipe_sl_layout_at(s, li);
  if (sl == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(sl, pipe_sl_off_tp_count());
}

/**
 * Type-param name length at (li, j).
 * @param module *u8 - module
 * @param li i32 - layout index
 * @param j i32 - param index
 * @return i32 - name_len or 0
 */
#[no_mangle]
export function pipeline_module_struct_layout_type_param_name_len(module: *u8, li: i32, j: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  if (li < 0) {
    return 0;
  }
  if (j < 0) {
    return 0;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let sl: *u8 = pipe_sl_layout_at(s, li);
  if (sl == 0 as *u8) {
    return 0;
  }
  let tp_base: i32 = pipe_load_i32_le(sl, pipe_sl_off_tp_base());
  let tp_count: i32 = pipe_load_i32_le(sl, pipe_sl_off_tp_count());
  if (tp_base < 0) {
    return 0;
  }
  if (j >= tp_count) {
    return 0;
  }
  let abs: i32 = tp_base + j;
  if (abs < 0) {
    return 0;
  }
  if (abs >= g_pipe_sl_tpn[s]) {
    return 0;
  }
  let tbase: *u8 = xlang_ptr_slot_get(&g_pipe_sl_tp[0], s);
  if (tbase == 0 as *u8) {
    return 0;
  }
  let ent: *u8 = tbase + (abs * pipe_sl_tp_size());
  let nl: i32 = pipe_load_i32_le(ent, 128);
  if (nl > 0) {
    if (nl <= 255) {
      return nl;
    }
  }
  return 0;
}

/**
 * Copy type-param name into out64 (128-byte row).
 * @param module *u8 - module
 * @param li i32 - layout index
 * @param j i32 - param index
 * @param out64 *u8 - 128-byte dest
 * @return void
 */
#[no_mangle]
export function pipeline_module_struct_layout_type_param_name_into(module: *u8, li: i32, j: i32, out64: *u8): void {
  if (out64 == 0 as *u8) {
    return;
  }
  unsafe {
    memset(out64, 0, 256 as usize);
  }
  if (module == 0 as *u8) {
    return;
  }
  if (li < 0) {
    return;
  }
  if (j < 0) {
    return;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return;
  }
  let sl: *u8 = pipe_sl_layout_at(s, li);
  if (sl == 0 as *u8) {
    return;
  }
  let tp_base: i32 = pipe_load_i32_le(sl, pipe_sl_off_tp_base());
  let tp_count: i32 = pipe_load_i32_le(sl, pipe_sl_off_tp_count());
  if (tp_base < 0) {
    return;
  }
  if (j >= tp_count) {
    return;
  }
  let abs: i32 = tp_base + j;
  if (abs < 0) {
    return;
  }
  if (abs >= g_pipe_sl_tpn[s]) {
    return;
  }
  let tbase: *u8 = xlang_ptr_slot_get(&g_pipe_sl_tp[0], s);
  if (tbase == 0 as *u8) {
    return;
  }
  let ent: *u8 = tbase + (abs * pipe_sl_tp_size());
  let nl: i32 = pipe_load_i32_le(ent, 128);
  if (nl <= 0) {
    return;
  }
  unsafe {
    memcpy(out64, ent, 256 as usize);
  }
}

/**
 * Flag setters/getters for allow_padding / soa / packed / repr_compatible / is_export.
 */
#[no_mangle]
export function pipeline_module_struct_layout_set_allow_padding(module: *u8, idx: i32, v: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    return;
  }
  pipe_store_i32_le(sl, pipe_sl_off_allow_padding(), v);
}

#[no_mangle]
export function pipeline_module_struct_layout_allow_padding_at(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(sl, pipe_sl_off_allow_padding());
}

#[no_mangle]
export function pipeline_module_struct_layout_set_soa(module: *u8, idx: i32, v: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    return;
  }
  pipe_store_i32_le(sl, pipe_sl_off_soa(), v);
}

#[no_mangle]
export function pipeline_module_struct_layout_soa_at(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(sl, pipe_sl_off_soa());
}

#[no_mangle]
export function pipeline_module_struct_layout_set_packed(module: *u8, idx: i32, v: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    return;
  }
  pipe_store_i32_le(sl, pipe_sl_off_packed(), v);
}

#[no_mangle]
export function pipeline_module_struct_layout_packed_at(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(sl, pipe_sl_off_packed());
}

#[no_mangle]
export function pipeline_module_struct_layout_set_repr_compatible(module: *u8, idx: i32, v: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    return;
  }
  pipe_store_i32_le(sl, pipe_sl_off_repr_compatible(), v);
}

#[no_mangle]
export function pipeline_module_struct_layout_repr_compatible_at(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(sl, pipe_sl_off_repr_compatible());
}

#[no_mangle]
export function pipeline_module_struct_layout_set_is_export(module: *u8, idx: i32, v: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    return;
  }
  pipe_store_i32_le(sl, pipe_sl_off_is_export(), v);
}

#[no_mangle]
export function pipeline_module_struct_layout_is_export_at(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(sl, pipe_sl_off_is_export());
}

/**
 * Read module.num_struct_layouts (header; soft-sync pure map).
 * @param module *u8 - module
 * @return i32 - count or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_num_struct_layouts_at(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_sl_soft_sync(module);
  return pipe_sl_get_header_n(module);
}

/**
 * Byte size of type_ref for backend_call_dispatch (emit module cell).
 * @param arena *u8 - ASTArena
 * @param ty_ref i32 - type ref
 * @return i32 - byte size via pure glue_type_size_simple
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_asm_type_ref_byte_size_c(arena: *u8, ty_ref: i32): i32 {
  let mod: *u8 = pipeline_asm_emit_ctx_module_get();
  return glue_type_size_simple(mod, arena, ty_ref, 0);
}

/**
 * §11.1 aligned next field offset (packed dense or align(N)+type align).
 * @param m *u8 - module
 * @param a *u8 - arena
 * @param layout_idx i32 - layout index
 * @param new_field_type_ref i32 - type of next field
 * @param field_align_req i32 - explicit align(N); 0 = type only
 * @return i32 - next field offset
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_struct_layout_next_field_offset_ex(m: *u8, a: *u8, layout_idx: i32, new_field_type_ref: i32, field_align_req: i32): i32 {
  if (m == 0 as *u8) {
    return 0;
  }
  if (layout_idx < 0) {
    return 0;
  }
  let current: i32 = 0;
  let nf: i32 = pipeline_module_struct_layout_num_fields(m, layout_idx);
  if (pipeline_module_struct_layout_packed_at(m, layout_idx) != 0) {
    let j: i32 = 0;
    while (j < nf) {
      let ftr: i32 = pipeline_module_struct_layout_field_type_ref(m, layout_idx, j);
      let fsize: i32 = glue_type_size_simple(m, a, ftr, 0);
      if (fsize < 0) {
        fsize = 4;
      } else {
        if (fsize == 0) {
          if (glue_type_is_empty_struct_c(m, a, ftr, 0) == 0) {
            fsize = 4;
          }
        }
      }
      current = current + fsize;
      j = j + 1;
    }
    return current;
  }
  let j2: i32 = 0;
  while (j2 < nf) {
    let ftr2: i32 = pipeline_module_struct_layout_field_type_ref(m, layout_idx, j2);
    let fa: i32 = pipeline_module_struct_layout_field_align_at(m, layout_idx, j2);
    let A: i32 = glue_type_align_simple(m, a, ftr2, 0);
    if (A <= 0) {
      A = 1;
    }
    if (fa > A) {
      A = fa;
    }
    let fsize2: i32 = glue_type_size_simple(m, a, ftr2, 0);
    if (fsize2 < 0) {
      fsize2 = 4;
    } else {
      if (fsize2 == 0) {
        if (glue_type_is_empty_struct_c(m, a, ftr2, 0) == 0) {
          fsize2 = 4;
        }
      }
    }
    let rem: i32 = current % A;
    let gap: i32 = A - rem;
    gap = gap % A;
    current = current + gap + fsize2;
    j2 = j2 + 1;
  }
  let A2: i32 = glue_type_align_simple(m, a, new_field_type_ref, 0);
  if (A2 <= 0) {
    A2 = 1;
  }
  if (field_align_req > A2) {
    A2 = field_align_req;
  }
  let rem2: i32 = current % A2;
  let gap2: i32 = A2 - rem2;
  gap2 = gap2 % A2;
  return current + gap2;
}

/**
 * Wrapper: next_field_offset_ex with field_align_req=0.
 * @param m *u8 - module
 * @param a *u8 - arena
 * @param layout_idx i32 - layout index
 * @param new_field_type_ref i32 - type of next field
 * @return i32 - next field offset
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_struct_layout_next_field_offset(m: *u8, a: *u8, layout_idx: i32, new_field_type_ref: i32): i32 {
  return pipeline_struct_layout_next_field_offset_ex(m, a, layout_idx, new_field_type_ref, 0);
}

