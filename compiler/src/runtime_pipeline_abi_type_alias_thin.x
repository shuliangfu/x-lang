// Thin pure: wave303/358/491 M2 — type_alias Cap residual C→.x (was wave262 C thin).
// TypeAliasEntry LE 264B: name[256]@0 name_len@256 target@260.
// Multi-module malloc map (128 slots) + 8 faces.
// G.7: bodies match runtime_pipeline_abi.x wave262 leave.
// wave358: w303_* unsafe wrappers; PRODUCT inject PREFER_ASM.
// wave491: no-local malloc (tipU 9/9); tip PRODUCT reinject HARD BAN
//   (opt hang). Stamp w491 skip — keep prior overlay.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, p: *u8): void;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function xlang_ptr_slot_get(arr: *u8, i: i32): *u8;
export extern function xlang_ptr_slot_set(arr: *u8, i: i32, p: *u8): void;
export extern "C" function malloc(n: usize): *u8;
export extern "C" function free(p: *u8): void;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;

/**
 * Ptr-slot get via unsafe (T001). PLATFORM: SHARED.
 */
function w303_ptr_get(arr: *u8, i: i32): *u8 {
  unsafe {
    return xlang_ptr_slot_get(arr, i);
  }
}

/**
 * Ptr-slot set via unsafe (T001). PLATFORM: SHARED.
 */
function w303_ptr_set(arr: *u8, i: i32, p: *u8): void {
  unsafe {
    xlang_ptr_slot_set(arr, i, p);
  }
}

/**
 * LE i32 load via unsafe (T001). PLATFORM: SHARED.
 */
function w303_load_i32(base: *u8, off: i32): i32 {
  unsafe {
    return pipe_load_i32_le(base, off);
  }
}

/**
 * LE i32 store via unsafe (T001). PLATFORM: SHARED.
 */
function w303_store_i32(base: *u8, off: i32, v: i32): void {
  unsafe {
    pipe_store_i32_le(base, off, v);
  }
}

let g_pipe_ta_mod: u8[1024] = [];
let g_pipe_ta_n: i32[128] = [];
let g_pipe_ta_cap: i32[128] = [];
let g_pipe_ta_entries: u8[1024] = [];

/**
 * Byte size of one TypeAliasEntry (name[128] + name_len + target_type_ref).
 * @return i32 - 264
 * PLATFORM: SHARED LP64 - must match C sizeof(TypeAliasEntry).
 */
function pipe_ta_entry_size(): i32 {
  return 264;
}

/**
 * Byte offset of name_len within TypeAliasEntry.
 * @return i32 - 128
 * PLATFORM: SHARED LP64.
 */
function pipe_ta_off_name_len(): i32 {
  return 256;
}

/**
 * Byte offset of target_type_ref within TypeAliasEntry.
 * @return i32 - 260
 * PLATFORM: SHARED LP64.
 */
function pipe_ta_off_target(): i32 {
  return 260;
}

/**
 * Byte offset of entry idx within the flat entry table.
 * @param idx i32 - entry index
 * @return i32 - byte offset
 */
function pipe_ta_entry_off(idx: i32): i32 {
  return idx * pipe_ta_entry_size();
}

/**
 * Find map slot for module pointer (exact key match).
 * @param module *u8 - module key; null -> -1
 * @return i32 - slot 0..127 or -1
 */
function pipe_ta_find_slot(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  let i: i32 = 0;
  while (i < 128) {
    let k: *u8 = w303_ptr_get(&g_pipe_ta_mod[0], i);
    if (k == module) {
      return i;
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Find or allocate a map slot for module.
 * @param module *u8 - module key; null -> -1
 * @return i32 - slot or -1 if map full
 */
function pipe_ta_find_or_create(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  let found: i32 = pipe_ta_find_slot(module);
  if (found >= 0) {
    return found;
  }
  let i: i32 = 0;
  while (i < 128) {
    let k: *u8 = w303_ptr_get(&g_pipe_ta_mod[0], i);
    if (k == 0 as *u8) {
      w303_ptr_set(&g_pipe_ta_mod[0], i, module);
      g_pipe_ta_n[i] = 0;
      g_pipe_ta_cap[i] = 0;
      w303_ptr_set(&g_pipe_ta_entries[0], i, 0 as *u8);
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
function pipe_ta_ensure_entries(slot: i32, need: i32): i32 {
  if (slot < 0) {
    return 0;
  }
  if (slot >= 128) {
    return 0;
  }
  if (need <= 0) {
    return 1;
  }
  let cap: i32 = g_pipe_ta_cap[slot];
  if (cap >= need) {
    return 1;
  }
  let new_cap: i32 = cap;
  if (new_cap < 8) {
    new_cap = 8;
  }
  while (new_cap < need) {
    new_cap = new_cap * 2;
  }
  let esz: i32 = pipe_ta_entry_size();
  let nbytes: usize = (new_cap * esz) as usize;
  let cell: u8[8];
  unsafe {
    /* PLATFORM: SHARED — tip drops mid `np=malloc()`; pipe cell + re-load. */
    pipe_store_ptr_slot(&cell[0], 0, malloc(nbytes));
    if (pipe_load_ptr_slot(&cell[0], 0) == (0 as *u8)) {
      return 0;
    }
  }
  let old: *u8 = w303_ptr_get(&g_pipe_ta_entries[0], slot);
  let old_n: i32 = g_pipe_ta_n[slot];
  if (old != 0 as *u8) {
    if (old_n > 0) {
      let copy_n: usize = (old_n * esz) as usize;
      unsafe {
        memcpy(pipe_load_ptr_slot(&cell[0], 0), old, copy_n);
      }
    }
    unsafe {
      free(old);
    }
  }
  unsafe {
    w303_ptr_set(&g_pipe_ta_entries[0], slot, pipe_load_ptr_slot(&cell[0], 0));
  }
  g_pipe_ta_cap[slot] = new_cap;
  return 1;
}

/**
 * Pointer to TypeAliasEntry at (slot, idx); null if OOB.
 * @param slot i32 - map slot
 * @param idx i32 - entry index
 * @return *u8 - entry base or null
 */
function pipe_ta_entry_at(slot: i32, idx: i32): *u8 {
  if (slot < 0) {
    return 0 as *u8;
  }
  if (slot >= 128) {
    return 0 as *u8;
  }
  if (idx < 0) {
    return 0 as *u8;
  }
  if (idx >= g_pipe_ta_n[slot]) {
    return 0 as *u8;
  }
  let base: *u8 = w303_ptr_get(&g_pipe_ta_entries[0], slot);
  if (base == 0 as *u8) {
    return 0 as *u8;
  }
  return base + pipe_ta_entry_off(idx);
}

/**
 * Soft-reset pure type-alias count for module (keep malloc capacity).
 * Called from ast_pool_module_reset so re-parse does not see stale aliases.
 * @param module *u8 - module key; null -> no-op
 * @return void
 * PLATFORM: SHARED - product hybrid owns live count.
 */
#[no_mangle]
export function pipeline_module_type_alias_storage_reset(module: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  let s: i32 = pipe_ta_find_slot(module);
  if (s < 0) {
    return;
  }
  g_pipe_ta_n[s] = 0;
}

/**
 * Free pure type-alias storage for one module and clear map slot.
 * @param module *u8 - module key; null -> no-op
 * @return void
 * wave262: called from Cap ast_pool_module_release (strong pure).
 * PLATFORM: SHARED - product hybrid owns free of malloc tables.
 */
#[no_mangle]
export function pipeline_module_type_alias_storage_release(module: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  let s: i32 = pipe_ta_find_slot(module);
  if (s < 0) {
    return;
  }
  let e: *u8 = w303_ptr_get(&g_pipe_ta_entries[0], s);
  if (e != 0 as *u8) {
    unsafe {
      free(e);
    }
  }
  w303_ptr_set(&g_pipe_ta_mod[0], s, 0 as *u8);
  w303_ptr_set(&g_pipe_ta_entries[0], s, 0 as *u8);
  g_pipe_ta_n[s] = 0;
  g_pipe_ta_cap[s] = 0;
}

/**
 * Allocate one TypeAliasEntry for module; return index or -1.
 * @param module *u8 - opaque ast_Module; null -> -1
 * @return i32 - new alias index (>=0) or -1
 * wave262 pure Cap residual leave: G.7 product authority (historical GrowVec).
 * PLATFORM: SHARED - seed cold twin under #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_module_type_alias_alloc(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  let s: i32 = pipe_ta_find_or_create(module);
  if (s < 0) {
    return 0 - 1;
  }
  let n: i32 = g_pipe_ta_n[s];
  if (pipe_ta_ensure_entries(s, n + 1) == 0) {
    return 0 - 1;
  }
  let base: *u8 = w303_ptr_get(&g_pipe_ta_entries[0], s);
  if (base == 0 as *u8) {
    return 0 - 1;
  }
  let off: i32 = pipe_ta_entry_off(n);
  // zero new entry (136 bytes)
  let k: i32 = 0;
  while (k < 136) {
    unsafe {
      base[off + k] = 0;
    }
    k = k + 1;
  }
  g_pipe_ta_n[s] = n + 1;
  return n;
}

/**
 * Write type-alias name + target type ref into pure map slot.
 * @param module *u8 - module
 * @param idx i32 - alias index
 * @param name *u8 - alias name bytes
 * @param name_len i32 - content length 1..255 (storage name[256])
 * @param target_type_ref i32 - target type ref
 * @return void
 * wave582 Cap residual: name content max 255 (match AST / TypeAliasEntry).
 * PLATFORM: SHARED - ≡ Cap pipeline_module_type_alias_set; DEBUG_PIPE notes cold-only.
 */
#[no_mangle]
export function pipeline_module_type_alias_set(module: *u8, idx: i32, name: *u8, name_len: i32,
                                               target_type_ref: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  if (name == 0 as *u8) {
    return;
  }
  if (name_len <= 0) {
    return;
  }
  if (name_len > 255) {
    return;
  }
  let s: i32 = pipe_ta_find_slot(module);
  if (s < 0) {
    return;
  }
  let e: *u8 = pipe_ta_entry_at(s, idx);
  if (e == 0 as *u8) {
    return;
  }
  let i: i32 = 0;
  while (i < name_len) {
    unsafe {
      e[i] = name[i];
    }
    i = i + 1;
  }
  while (i < 128) {
    unsafe {
      e[i] = 0;
    }
    i = i + 1;
  }
  w303_store_i32(e, pipe_ta_off_name_len(), name_len);
  w303_store_i32(e, pipe_ta_off_target(), target_type_ref);
}

/**
 * Read type-alias name length.
 * @param module *u8 - module
 * @param idx i32 - alias index
 * @return i32 - name_len or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_type_alias_name_len(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  let s: i32 = pipe_ta_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let e: *u8 = pipe_ta_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0;
  }
  return w303_load_i32(e, pipe_ta_off_name_len());
}

/**
 * Read type-alias name byte at off; OOB -> 0.
 * @param module *u8 - module
 * @param idx i32 - alias index
 * @param off i32 - byte offset in name[128]
 * @return u8 - name byte or 0
 * wave582: off bound 128. PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_type_alias_name_byte_at(module: *u8, idx: i32, off: i32): u8 {
  if (module == 0 as *u8) {
    return 0 as u8;
  }
  if (off < 0) {
    return 0 as u8;
  }
  if (off >= 128) {
    return 0 as u8;
  }
  let s: i32 = pipe_ta_find_slot(module);
  if (s < 0) {
    return 0 as u8;
  }
  let e: *u8 = pipe_ta_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0 as u8;
  }
  let b: u8 = 0 as u8;
  unsafe {
    b = e[off];
  }
  return b;
}

/**
 * Read type-alias target type ref.
 * @param module *u8 - module
 * @param idx i32 - alias index
 * @return i32 - target_type_ref or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_type_alias_target_ref(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  let s: i32 = pipe_ta_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let e: *u8 = pipe_ta_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0;
  }
  return w303_load_i32(e, pipe_ta_off_target());
}

/**
 * Read module type-alias count from pure map (not Cap GrowVec).
 * @param module *u8 - module
 * @return i32 - live alias count or 0
 * PLATFORM: SHARED - G.7 sole product authority after wave262 leave.
 */
#[no_mangle]
export function pipeline_module_num_type_aliases_at(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  let s: i32 = pipe_ta_find_slot(module);
  if (s < 0) {
    return 0;
  }
  return g_pipe_ta_n[s];
}

