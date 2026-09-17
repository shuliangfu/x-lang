// Thin pure: wave306/360 M2 — module_enum Cap residual C→.x (was wave264 C thin).
// ModuleEnumEntry LE ~66828B map + mark helpers; 15 exports.
// G.7: bodies match runtime_pipeline_abi.x wave264 leave.
// wave360: w306_* unsafe wrappers for slot/LE/product faces (T001);
// PRODUCT inject PREFER_ASM try. Stamp w360.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function xlang_ptr_slot_get(arr: *u8, i: i32): *u8;
export extern function xlang_ptr_slot_set(arr: *u8, i: i32, p: *u8): void;
export extern function pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8;
export extern function pipeline_dep_ctx_ndep(ctx: *u8): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_is_enum_variant(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_expr_field_access_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_set_field_access_enum_variant(a: *u8, expr_ref: i32, tag: i32): void;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out64: *u8): void;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_typeck_get_dep_ctx(): *u8;
export extern "C" function malloc(n: usize): *u8;
export extern "C" function free(p: *u8): void;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;


/**
 * Ptr-slot get via unsafe (T001). PLATFORM: SHARED.
 */
function w306_ptr_get(arr: *u8, i: i32): *u8 {
  unsafe {
    return xlang_ptr_slot_get(arr, i);
  }
}

/**
 * Ptr-slot set via unsafe (T001). PLATFORM: SHARED.
 */
function w306_ptr_set(arr: *u8, i: i32, p: *u8): void {
  unsafe {
    xlang_ptr_slot_set(arr, i, p);
  }
}

/**
 * LE i32 load via unsafe (T001). PLATFORM: SHARED.
 */
function w306_load_i32(base: *u8, off: i32): i32 {
  unsafe {
    return pipe_load_i32_le(base, off);
  }
}

/**
 * LE i32 store via unsafe (T001). PLATFORM: SHARED.
 */
function w306_store_i32(base: *u8, off: i32, v: i32): void {
  unsafe {
    pipe_store_i32_le(base, off, v);
  }
}

/**
 * Typeck dep ctx via unsafe (T001). PLATFORM: SHARED.
 */
function w306_get_dep_ctx(): *u8 {
  unsafe {
    return pipeline_typeck_get_dep_ctx();
  }
}

/**
 * Field-access is enum variant via unsafe (T001). PLATFORM: SHARED.
 */
function w306_field_access_is_enum_variant(a: *u8, expr_ref: i32): i32 {
  unsafe {
    return pipeline_expr_field_access_is_enum_variant(a, expr_ref);
  }
}

/**
 * Set field-access enum variant tag via unsafe (T001). PLATFORM: SHARED.
 */
function w306_set_field_access_enum_variant(a: *u8, expr_ref: i32, tag: i32): void {
  unsafe {
    pipeline_expr_set_field_access_enum_variant(a, expr_ref, tag);
  }
}


let g_pipe_en_mod: u8[1024] = [];
let g_pipe_en_n: i32[128] = [];
let g_pipe_en_cap: i32[128] = [];
let g_pipe_en_entries: u8[1024] = [];

/**
 * Byte size of one ModuleEnumEntry (name + lens + 256 variant rows + lens + export).
 * @return i32 - 66828
 * PLATFORM: SHARED LP64 - must match C sizeof(ModuleEnumEntry).
 */
function pipe_en_entry_size(): i32 {
  return 66828;
}

/**
 * Max variants per enum (TokenKind etc.).
 * @return i32 - 256
 * PLATFORM: SHARED - ≡ MODULE_ENUM_MAX_VARIANTS.
 */
function pipe_en_max_variants(): i32 {
  return 256;
}

/**
 * Byte offset of name_len within ModuleEnumEntry.
 * @return i32 - 256
 */
function pipe_en_off_name_len(): i32 {
  return 256;
}

/**
 * Byte offset of num_variants within ModuleEnumEntry.
 * @return i32 - 260
 */
function pipe_en_off_num_variants(): i32 {
  return 260;
}

/**
 * Byte offset of variant_name[0][0] within ModuleEnumEntry.
 * @return i32 - 264
 */
function pipe_en_off_variant_name0(): i32 {
  return 264;
}

/**
 * Byte offset of variant_name_len[0] within ModuleEnumEntry.
 * @return i32 - 65800
 */
function pipe_en_off_variant_name_len0(): i32 {
  return 65800;
}

/**
 * Byte offset of is_export within ModuleEnumEntry.
 * @return i32 - 66824
 */
function pipe_en_off_is_export(): i32 {
  return 66824;
}

/**
 * Byte offset of entry idx within the flat entry table.
 * @param idx i32 - entry index
 * @return i32 - byte offset
 */
function pipe_en_entry_off(idx: i32): i32 {
  return idx * pipe_en_entry_size();
}

/**
 * LP64 offsetof(struct ast_Module, num_module_enums).
 * @return i32 - 64
 * PLATFORM: SHARED LP64 - dual-end; see pipe_mod_off_num_module_enums.
 */
function pipe_en_off_header_n(): i32 {
  return 64;
}

/**
 * Read module.num_module_enums header field (null -> 0).
 * @param module *u8 - opaque ast_Module
 * @return i32 - header count
 */
function pipe_en_get_header_n(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  return w306_load_i32(module, pipe_en_off_header_n());
}

/**
 * Write module.num_module_enums header field (null-safe).
 * @param module *u8 - opaque ast_Module
 * @param n i32 - live enum count
 * @return void
 */
function pipe_en_set_header_n(module: *u8, n: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  w306_store_i32(module, pipe_en_off_header_n(), n);
}

/**
 * Find map slot for module pointer (exact key match).
 * @param module *u8 - module key; null -> -1
 * @return i32 - slot 0..127 or -1
 */
function pipe_en_find_slot(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  let i: i32 = 0;
  while (i < 128) {
    let k: *u8 = w306_ptr_get(&g_pipe_en_mod[0], i);
    if (k == module) {
      return i;
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Soft-reset pure counts when header num_module_enums is 0 (parse/module reset).
 * Keeps malloc capacity; zeros live n.
 * @param module *u8 - module key
 * @return void
 */
function pipe_en_soft_sync(module: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  if (pipe_en_get_header_n(module) != 0) {
    return;
  }
  let s: i32 = pipe_en_find_slot(module);
  if (s < 0) {
    return;
  }
  g_pipe_en_n[s] = 0;
}

/**
 * Find or allocate a map slot for module.
 * @param module *u8 - module key; null -> -1
 * @return i32 - slot or -1 if map full
 */
function pipe_en_find_or_create(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  pipe_en_soft_sync(module);
  let found: i32 = pipe_en_find_slot(module);
  if (found >= 0) {
    return found;
  }
  let i: i32 = 0;
  while (i < 128) {
    let k: *u8 = w306_ptr_get(&g_pipe_en_mod[0], i);
    if (k == 0 as *u8) {
      w306_ptr_set(&g_pipe_en_mod[0], i, module);
      g_pipe_en_n[i] = 0;
      g_pipe_en_cap[i] = 0;
      w306_ptr_set(&g_pipe_en_entries[0], i, 0 as *u8);
      return i;
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Ensure entry table capacity >= need for slot (malloc grow, double).
 * @param slot i32 - map slot
 * @param need i32 - required live+push capacity
 * @return i32 - 1 ok, 0 fail
 */
function pipe_en_ensure_entries(slot: i32, need: i32): i32 {
  if (slot < 0) {
    return 0;
  }
  if (slot >= 128) {
    return 0;
  }
  if (need <= 0) {
    return 1;
  }
  let cap: i32 = g_pipe_en_cap[slot];
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
  let esz: i32 = pipe_en_entry_size();
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
  let old: *u8 = w306_ptr_get(&g_pipe_en_entries[0], slot);
  let old_n: i32 = g_pipe_en_n[slot];
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
  w306_ptr_set(&g_pipe_en_entries[0], slot, np);
  g_pipe_en_cap[slot] = new_cap;
  return 1;
}

/**
 * Pointer to ModuleEnumEntry at (slot, idx); null if OOB.
 * @param slot i32 - map slot
 * @param idx i32 - entry index
 * @return *u8 - entry base or null
 */
function pipe_en_entry_at(slot: i32, idx: i32): *u8 {
  if (slot < 0) {
    return 0 as *u8;
  }
  if (slot >= 128) {
    return 0 as *u8;
  }
  if (idx < 0) {
    return 0 as *u8;
  }
  if (idx >= g_pipe_en_n[slot]) {
    return 0 as *u8;
  }
  let base: *u8 = w306_ptr_get(&g_pipe_en_entries[0], slot);
  if (base == 0 as *u8) {
    return 0 as *u8;
  }
  return base + pipe_en_entry_off(idx);
}

/**
 * Soft-reset pure module-enum count for module (keep malloc capacity).
 * Called from ast_pool_module_reset so re-parse does not see stale enums.
 * Also clears header num_module_enums when pure n was non-zero.
 * @param module *u8 - module key; null -> no-op
 * @return void
 * PLATFORM: SHARED - product hybrid owns live count.
 */
#[no_mangle]
export function pipeline_module_enum_storage_reset(module: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  let s: i32 = pipe_en_find_slot(module);
  if (s < 0) {
    pipe_en_set_header_n(module, 0);
    return;
  }
  g_pipe_en_n[s] = 0;
  pipe_en_set_header_n(module, 0);
}

/**
 * Free pure module-enum storage for one module and clear map slot.
 * @param module *u8 - module key; null -> no-op
 * @return void
 * wave264: called from Cap ast_pool_module_release (strong pure).
 * PLATFORM: SHARED - product hybrid owns free of malloc tables.
 */
#[no_mangle]
export function pipeline_module_enum_storage_release(module: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  let s: i32 = pipe_en_find_slot(module);
  if (s < 0) {
    return;
  }
  let e: *u8 = w306_ptr_get(&g_pipe_en_entries[0], s);
  if (e != 0 as *u8) {
    unsafe {
      free(e);
    }
  }
  w306_ptr_set(&g_pipe_en_mod[0], s, 0 as *u8);
  w306_ptr_set(&g_pipe_en_entries[0], s, 0 as *u8);
  g_pipe_en_n[s] = 0;
  g_pipe_en_cap[s] = 0;
  pipe_en_set_header_n(module, 0);
}

/**
 * Allocate one ModuleEnumEntry for module; return index or -1.
 * @param module *u8 - opaque ast_Module; null -> -1
 * @return i32 - new enum index (>=0) or -1
 * wave264 pure Cap residual leave: G.7 product authority (historical GrowVec).
 * Updates module.num_module_enums header ≡ Cap m->num_module_enums = sc->len.
 * PLATFORM: SHARED - seed cold twin under #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_module_enum_alloc(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  let s: i32 = pipe_en_find_or_create(module);
  if (s < 0) {
    return 0 - 1;
  }
  let n: i32 = g_pipe_en_n[s];
  if (pipe_en_ensure_entries(s, n + 1) == 0) {
    return 0 - 1;
  }
  let base: *u8 = w306_ptr_get(&g_pipe_en_entries[0], s);
  if (base == 0 as *u8) {
    return 0 - 1;
  }
  let off: i32 = pipe_en_entry_off(n);
  let esz: i32 = pipe_en_entry_size();
  unsafe {
    memset(base + off, 0, esz as usize);
  }
  g_pipe_en_n[s] = n + 1;
  pipe_en_set_header_n(module, n + 1);
  return n;
}

/**
 * Set module enum type name at idx; clears variants and is_export.
 * @param module *u8 - module
 * @param idx i32 - enum index
 * @param bytes *u8 - name bytes
 * @param len i32 - content length 1..255 (storage name[256])
 * @return void
 * wave582 Cap residual: name content max 255. PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_enum_set_name(module: *u8, idx: i32, bytes: *u8, len: i32): void {
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
  pipe_en_soft_sync(module);
  let s: i32 = pipe_en_find_slot(module);
  if (s < 0) {
    return;
  }
  let e: *u8 = pipe_en_entry_at(s, idx);
  if (e == 0 as *u8) {
    return;
  }
  let i: i32 = 0;
  while (i < len) {
    unsafe {
      e[i] = bytes[i];
    }
    i = i + 1;
  }
  while (i < 128) {
    unsafe {
      e[i] = 0;
    }
    i = i + 1;
  }
  w306_store_i32(e, pipe_en_off_name_len(), len);
  w306_store_i32(e, pipe_en_off_num_variants(), 0);
  w306_store_i32(e, pipe_en_off_is_export(), 0);
}

/**
 * Set is_export flag for module enum idx.
 * @param module *u8 - module
 * @param idx i32 - enum index
 * @param v i32 - 0/1 export
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_enum_set_is_export(module: *u8, idx: i32, v: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  pipe_en_soft_sync(module);
  let s: i32 = pipe_en_find_slot(module);
  if (s < 0) {
    return;
  }
  let e: *u8 = pipe_en_entry_at(s, idx);
  if (e == 0 as *u8) {
    return;
  }
  w306_store_i32(e, pipe_en_off_is_export(), v);
}

/**
 * Read is_export flag for module enum idx.
 * @param module *u8 - module
 * @param idx i32 - enum index
 * @return i32 - is_export or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_enum_is_export_at(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_en_soft_sync(module);
  let s: i32 = pipe_en_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let e: *u8 = pipe_en_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0;
  }
  return w306_load_i32(e, pipe_en_off_is_export());
}

/**
 * Append variant name to module enum idx; returns tag 0..n-1 or -1.
 * @param module *u8 - module
 * @param idx i32 - enum index
 * @param bytes *u8 - variant name bytes
 * @param len i32 - content length 1..255
 * @return i32 - variant tag or -1 (full / OOB / null)
 * wave582 Cap residual; rows are u8[256] since Cap 4.2.8 (name[256]
 * world, variant_name_len@65800 ⇒ 256 stride — a 128 stride wrote
 * variant #1+ into the middle of row 0's tail and readers at
 * 264+vi*256 saw empty names: every multi-variant enum failed
 * typeck T001; see the 2026-09-13 L4 std/http run).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_enum_append_variant(module: *u8, idx: i32, bytes: *u8, len: i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (bytes == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  if (len > 255) {
    return 0 - 1;
  }
  pipe_en_soft_sync(module);
  let s: i32 = pipe_en_find_slot(module);
  if (s < 0) {
    return 0 - 1;
  }
  let e: *u8 = pipe_en_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0 - 1;
  }
  let nv: i32 = w306_load_i32(e, pipe_en_off_num_variants());
  if (nv >= pipe_en_max_variants()) {
    return 0 - 1;
  }
  let voff: i32 = pipe_en_off_variant_name0() + nv * 256;
  let k: i32 = 0;
  while (k < 256) {
    unsafe {
      e[voff + k] = 0;
    }
    k = k + 1;
  }
  k = 0;
  while (k < len) {
    unsafe {
      e[voff + k] = bytes[k];
    }
    k = k + 1;
  }
  let loff: i32 = pipe_en_off_variant_name_len0() + nv * 4;
  w306_store_i32(e, loff, len);
  w306_store_i32(e, pipe_en_off_num_variants(), nv + 1);
  return nv;
}

/**
 * Compare entry name[0..nlen) with name[0..name_len).
 * @param e *u8 - ModuleEnumEntry base
 * @param name *u8 - probe name
 * @param name_len i32 - probe length
 * @return i32 - 1 match, 0 miss
 */
function pipe_en_name_eq(e: *u8, name: *u8, name_len: i32): i32 {
  if (e == 0 as *u8) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  let nlen: i32 = w306_load_i32(e, pipe_en_off_name_len());
  if (nlen != name_len) {
    return 0;
  }
  let j: i32 = 0;
  while (j < name_len) {
    let b: u8 = 0 as u8;
    unsafe {
      b = e[j];
    }
    if (b != name[j]) {
      return 0;
    }
    j = j + 1;
  }
  return 1;
}

/**
 * Find variant tag in one ModuleEnumEntry by variant name.
 * @param e *u8 - entry
 * @param variant_name *u8 - variant bytes
 * @param variant_len i32 - length
 * @return i32 - tag or -1
 */
function pipe_en_variant_tag_in_entry(e: *u8, variant_name: *u8, variant_len: i32): i32 {
  if (e == 0 as *u8) {
    return 0 - 1;
  }
  if (variant_name == 0 as *u8) {
    return 0 - 1;
  }
  let nv: i32 = w306_load_i32(e, pipe_en_off_num_variants());
  let vi: i32 = 0;
  while (vi < nv) {
    let loff: i32 = pipe_en_off_variant_name_len0() + vi * 4;
    let vlen: i32 = w306_load_i32(e, loff);
    if (vlen == variant_len) {
      let voff: i32 = pipe_en_off_variant_name0() + vi * 256;
      let j: i32 = 0;
      let ok: i32 = 1;
      while (j < variant_len) {
        if (ok != 0) {
          let b: u8 = 0 as u8;
          unsafe {
            b = e[voff + j];
          }
          if (b != variant_name[j]) {
            ok = 0;
          }
        }
        j = j + 1;
      }
      if (ok != 0) {
        return vi;
      }
    }
    vi = vi + 1;
  }
  return 0 - 1;
}

/**
 * Search pure enum map for enum_name.variant_name tag in one module.
 * @param module *u8 - module
 * @param enum_name *u8 - enum type name
 * @param enum_len i32 - length
 * @param variant_name *u8 - variant name
 * @param variant_len i32 - length
 * @return i32 - tag or -1
 */
function pipe_en_tag_in_module(module: *u8, enum_name: *u8, enum_len: i32, variant_name: *u8, variant_len: i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  pipe_en_soft_sync(module);
  let s: i32 = pipe_en_find_slot(module);
  if (s < 0) {
    return 0 - 1;
  }
  let n: i32 = g_pipe_en_n[s];
  let ei: i32 = 0;
  while (ei < n) {
    let e: *u8 = pipe_en_entry_at(s, ei);
    if (e != 0 as *u8) {
      if (pipe_en_name_eq(e, enum_name, enum_len) != 0) {
        let tag: i32 = pipe_en_variant_tag_in_entry(e, variant_name, variant_len);
        return tag;
      }
    }
    ei = ei + 1;
  }
  return 0 - 1;
}

/**
 * Look up enum variant tag by type name + variant name (current module then deps).
 * @param m *u8 - current module
 * @param enum_name *u8 - enum type name bytes
 * @param enum_len i32 - length
 * @param variant_name *u8 - variant name bytes
 * @param variant_len i32 - length
 * @return i32 - tag 0..n-1 or -1
 * wave264 pure Cap residual leave: G.7 product authority.
 * Dep search via pure pipeline_typeck_get_dep_ctx + Cap pipeline_dep_ctx_*.
 * PLATFORM: SHARED - seed cold twin under #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_module_enum_variant_tag_for_names(m: *u8, enum_name: *u8, enum_len: i32, variant_name: *u8, variant_len: i32): i32 {
  if (m == 0 as *u8) {
    return 0 - 1;
  }
  if (enum_name == 0 as *u8) {
    return 0 - 1;
  }
  if (enum_len <= 0) {
    return 0 - 1;
  }
  if (variant_name == 0 as *u8) {
    return 0 - 1;
  }
  if (variant_len <= 0) {
    return 0 - 1;
  }
  let tag: i32 = pipe_en_tag_in_module(m, enum_name, enum_len, variant_name, variant_len);
  if (tag >= 0) {
    return tag;
  }
  let dep_ctx: *u8 = w306_get_dep_ctx();
  if (dep_ctx == 0 as *u8) {
    return 0 - 1;
  }
  let ndep: i32 = 0;
  unsafe {
    ndep = pipeline_dep_ctx_ndep(dep_ctx);
  }
  let di: i32 = 0;
  while (di < ndep) {
    let dep_mod: *u8 = 0 as *u8;
    unsafe {
      dep_mod = pipeline_dep_ctx_module_at(dep_ctx, di);
    }
    if (dep_mod != 0 as *u8) {
      if (dep_mod != m) {
        tag = pipe_en_tag_in_module(dep_mod, enum_name, enum_len, variant_name, variant_len);
        if (tag >= 0) {
          return tag;
        }
      }
    }
    di = di + 1;
  }
  return 0 - 1;
}

/**
 * Read enum type name length.
 * @param module *u8 - module
 * @param idx i32 - enum index
 * @return i32 - name_len or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_enum_name_len(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_en_soft_sync(module);
  let s: i32 = pipe_en_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let e: *u8 = pipe_en_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0;
  }
  return w306_load_i32(e, pipe_en_off_name_len());
}

/**
 * Read enum type name byte at off; OOB -> 0.
 * @param module *u8 - module
 * @param idx i32 - enum index
 * @param off i32 - byte offset in name[128]
 * @return u8 - name byte or 0
 * wave582: off bound 128. PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_enum_name_byte_at(module: *u8, idx: i32, off: i32): u8 {
  if (module == 0 as *u8) {
    return 0 as u8;
  }
  if (off < 0) {
    return 0 as u8;
  }
  if (off >= 128) {
    return 0 as u8;
  }
  pipe_en_soft_sync(module);
  let s: i32 = pipe_en_find_slot(module);
  if (s < 0) {
    return 0 as u8;
  }
  let e: *u8 = pipe_en_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0 as u8;
  }
  let nlen: i32 = w306_load_i32(e, pipe_en_off_name_len());
  if (off >= nlen) {
    return 0 as u8;
  }
  let b: u8 = 0 as u8;
  unsafe {
    b = e[off];
  }
  return b;
}

/**
 * Read num_variants for module enum idx.
 * @param module *u8 - module
 * @param idx i32 - enum index
 * @return i32 - num_variants or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_enum_num_variants(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_en_soft_sync(module);
  let s: i32 = pipe_en_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let e: *u8 = pipe_en_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0;
  }
  return w306_load_i32(e, pipe_en_off_num_variants());
}

/**
 * Read variant name length at (idx, variant_idx).
 * @param module *u8 - module
 * @param idx i32 - enum index
 * @param variant_idx i32 - variant tag
 * @return i32 - name length or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_enum_variant_name_len(module: *u8, idx: i32, variant_idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  if (variant_idx < 0) {
    return 0;
  }
  pipe_en_soft_sync(module);
  let s: i32 = pipe_en_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let e: *u8 = pipe_en_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0;
  }
  let nv: i32 = w306_load_i32(e, pipe_en_off_num_variants());
  if (variant_idx >= nv) {
    return 0;
  }
  let loff: i32 = pipe_en_off_variant_name_len0() + variant_idx * 4;
  return w306_load_i32(e, loff);
}

/**
 * Read variant name byte at (idx, variant_idx, off).
 * @param module *u8 - module
 * @param idx i32 - enum index
 * @param variant_idx i32 - variant tag
 * @param off i32 - byte offset in variant_name row
 * @return u8 - byte or 0
 * wave582: off bound 128. PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_enum_variant_name_byte_at(module: *u8, idx: i32, variant_idx: i32, off: i32): u8 {
  if (module == 0 as *u8) {
    return 0 as u8;
  }
  if (variant_idx < 0) {
    return 0 as u8;
  }
  if (off < 0) {
    return 0 as u8;
  }
  if (off >= 128) {
    return 0 as u8;
  }
  pipe_en_soft_sync(module);
  let s: i32 = pipe_en_find_slot(module);
  if (s < 0) {
    return 0 as u8;
  }
  let e: *u8 = pipe_en_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0 as u8;
  }
  let nv: i32 = w306_load_i32(e, pipe_en_off_num_variants());
  if (variant_idx >= nv) {
    return 0 as u8;
  }
  let loff: i32 = pipe_en_off_variant_name_len0() + variant_idx * 4;
  let vlen: i32 = w306_load_i32(e, loff);
  if (off >= vlen) {
    return 0 as u8;
  }
  let voff: i32 = pipe_en_off_variant_name0() + variant_idx * 256;
  let b: u8 = 0 as u8;
  unsafe {
    b = e[voff + off];
  }
  return b;
}

/**
 * Extract enum type name for Enum.Variant or import.Enum.Variant into out[128].
 * @param arena *u8 - AST arena
 * @param base_ref i32 - field_access base expr ref
 * @param ename_out *u8 - output buffer (>=128)
 * @return i32 - enum name length or 0
 * EXPR_VAR=3 bare Enum.Variant; EXPR_FIELD_ACCESS=44 import.Enum.Variant.
 * PLATFORM: SHARED pure helper.
 */
function pipe_en_name_from_fa_base(arena: *u8, base_ref: i32, ename_out: *u8): i32 {
  if (arena == 0 as *u8) {
    return 0;
  }
  if (ename_out == 0 as *u8) {
    return 0;
  }
  if (base_ref <= 0) {
    return 0;
  }
  let kind: i32 = 0;
  unsafe {
    kind = pipeline_expr_kind_ord_at(arena, base_ref);
  }
  // EXPR_VAR = 3
  if (kind == 3) {
    let elen: i32 = 0;
    unsafe {
      elen = pipeline_expr_var_name_len(arena, base_ref);
    }
    if (elen <= 0) {
      return 0;
    }
    if (elen > 255) {
      elen = 127;
    }
    let tmp: u8[256] = [];
    unsafe {
      pipeline_expr_var_name_into(arena, base_ref, &tmp[0]);
    }
    let i: i32 = 0;
    while (i < elen) {
      unsafe {
        ename_out[i] = tmp[i];
      }
      i = i + 1;
    }
    return elen;
  }
  // EXPR_FIELD_ACCESS = 44
  if (kind == 44) {
    let elen2: i32 = 0;
    unsafe {
      elen2 = pipeline_expr_field_access_name_len(arena, base_ref);
    }
    if (elen2 <= 0) {
      return 0;
    }
    if (elen2 > 255) {
      elen2 = 255;
    }
    let tmp2: u8[256] = [];
    unsafe {
      pipeline_expr_field_access_name_into(arena, base_ref, &tmp2[0]);
    }
    let j: i32 = 0;
    while (j < elen2) {
      unsafe {
        ename_out[j] = tmp2[j];
      }
      j = j + 1;
    }
    return elen2;
  }
  return 0;
}

/**
 * If expr is TypeName.Variant or import.TypeName.Variant, set is_enum_variant + tag.
 * @param m *u8 - module
 * @param a *u8 - arena
 * @param expr_ref i32 - field_access expr ref
 * @return void
 * wave264 pure Cap residual leave. Uses pure variant_tag_for_names (deps via typeck dep ctx).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_expr_try_mark_enum_field_access(m: *u8, a: *u8, expr_ref: i32): void {
  if (m == 0 as *u8) {
    return;
  }
  if (a == 0 as *u8) {
    return;
  }
  if (expr_ref <= 0) {
    return;
  }
  let kind: i32 = 0;
  unsafe {
    kind = pipeline_expr_kind_ord_at(a, expr_ref);
  }
  if (kind != 44) {
    return;
  }
  if (w306_field_access_is_enum_variant(a, expr_ref) != 0) {
    return;
  }
  let base_ref: i32 = 0;
  unsafe {
    base_ref = pipeline_expr_field_access_base_ref(a, expr_ref);
  }
  let ename: u8[256] = [];
  let elen: i32 = pipe_en_name_from_fa_base(a, base_ref, &ename[0]);
  if (elen <= 0) {
    return;
  }
  let vlen: i32 = 0;
  unsafe {
    vlen = pipeline_expr_field_access_name_len(a, expr_ref);
  }
  if (vlen <= 0) {
    return;
  }
  if (vlen > 255) {
    return;
  }
  let vname: u8[256] = [];
  unsafe {
    pipeline_expr_field_access_name_into(a, expr_ref, &vname[0]);
  }
  let tag: i32 = pipeline_module_enum_variant_tag_for_names(m, &ename[0], elen, &vname[0], vlen);
  if (tag < 0) {
    return;
  }
  w306_set_field_access_enum_variant(a, expr_ref, tag);
}

/**
 * Codegen-time enum variant marking: current module then explicit dep_ctx walk.
 * @param m *u8 - module
 * @param a *u8 - arena
 * @param expr_ref i32 - field_access expr ref
 * @param dep_ctx *u8 - PipelineDepCtx (may be null)
 * @return void
 * PLATFORM: SHARED - mark import.Enum.Variant so emit outputs tag integer.
 * wave264 pure Cap residual leave.
 */
#[no_mangle]
export function pipeline_codegen_try_mark_enum_field_access(m: *u8, a: *u8, expr_ref: i32, dep_ctx: *u8): void {
  if (m == 0 as *u8) {
    return;
  }
  if (a == 0 as *u8) {
    return;
  }
  if (expr_ref <= 0) {
    return;
  }
  let kind: i32 = 0;
  unsafe {
    kind = pipeline_expr_kind_ord_at(a, expr_ref);
  }
  if (kind != 44) {
    return;
  }
  if (w306_field_access_is_enum_variant(a, expr_ref) != 0) {
    return;
  }
  let base_ref: i32 = 0;
  unsafe {
    base_ref = pipeline_expr_field_access_base_ref(a, expr_ref);
  }
  let ename: u8[256] = [];
  let elen: i32 = pipe_en_name_from_fa_base(a, base_ref, &ename[0]);
  if (elen <= 0) {
    return;
  }
  let vlen: i32 = 0;
  unsafe {
    vlen = pipeline_expr_field_access_name_len(a, expr_ref);
  }
  if (vlen <= 0) {
    return;
  }
  if (vlen > 255) {
    return;
  }
  let vname: u8[256] = [];
  unsafe {
    pipeline_expr_field_access_name_into(a, expr_ref, &vname[0]);
  }
  let tag: i32 = pipe_en_tag_in_module(m, &ename[0], elen, &vname[0], vlen);
  if (tag >= 0) {
    w306_set_field_access_enum_variant(a, expr_ref, tag);
    return;
  }
  if (dep_ctx == 0 as *u8) {
    return;
  }
  let ndep: i32 = 0;
  unsafe {
    ndep = pipeline_dep_ctx_ndep(dep_ctx);
  }
  let di: i32 = 0;
  while (di < ndep) {
    let dep_mod: *u8 = 0 as *u8;
    unsafe {
      dep_mod = pipeline_dep_ctx_module_at(dep_ctx, di);
    }
    if (dep_mod != 0 as *u8) {
      if (dep_mod != m) {
        tag = pipe_en_tag_in_module(dep_mod, &ename[0], elen, &vname[0], vlen);
        if (tag >= 0) {
          w306_set_field_access_enum_variant(a, expr_ref, tag);
          return;
        }
      }
    }
    di = di + 1;
  }
}

