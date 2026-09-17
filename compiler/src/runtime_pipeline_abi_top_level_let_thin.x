// Thin pure: wave305 M2 — top_level_let Cap residual C→.x (was wave265 C thin).
// TopLevelLetEntry LE 276B map + hoist/sum faces; 16 exports.
// G.7: bodies match runtime_pipeline_abi.x wave265 leave.
// PRODUCT inject: -E+$CC via pipeline_abi_inject_top_level_let_thin
// (ALLOW_E_REPLACE + stamp). File-local maps OK under -E+$CC.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function xlang_ptr_slot_get(arr: *u8, i: i32): *u8;
export extern function xlang_ptr_slot_set(arr: *u8, i: i32, p: *u8): void;
export extern function pipe_arena_off_num_exprs(): i32;
export extern function pipe_modlet_scalar_init_is_ptr_addr(arena: *u8, m: *u8, init_ref: i32): i32;
export extern function pipeline_asm_let_init_stack_reserve_bytes(arena: *u8, type_ref: i32, init_ref: i32): i32;
export extern function pipeline_asm_modlet_name_is_shared(name: *u8, name_len: i32): i32;
export extern function pipeline_asm_module_func_is_extern_at(module: *u8, fi: i32): i32;
export extern function asm_local_slot_reg_offset(arena: *u8, type_ref: i32, off: i32, inout_off: *i32): i32;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_append_let(arena: *u8, br: i32, name: *u8, name_len: i32, type_ref: i32, init_ref: i32): i32;
export extern function pipeline_block_stmt_order_prepend_lets(arena: *u8, br: i32, let_start_idx: i32, let_count: i32): void;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_module_func_body_ref_at(module: *u8, fi: i32): i32;
export extern function pipeline_module_main_func_index(module: *u8): i32;
export extern function pipeline_module_num_funcs(module: *u8): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern "C" function malloc(n: usize): *u8;
export extern "C" function free(p: *u8): void;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;

let g_pipe_tl_mod: u8[1024] = [];
let g_pipe_tl_n: i32[128] = [];
let g_pipe_tl_cap: i32[128] = [];
let g_pipe_tl_entries: u8[1024] = [];

/**
 * Byte size of one TopLevelLetEntry (name + 5 i32 fields).
 * @return i32 - 276
 * PLATFORM: SHARED LP64 - must match C sizeof(TopLevelLetEntry).
 */
function pipe_tl_entry_size(): i32 {
  return 276;
}

/**
 * Byte offset of name_len within TopLevelLetEntry.
 * @return i32 - 128
 */
function pipe_tl_off_name_len(): i32 {
  return 256;
}

/**
 * Byte offset of type_ref within TopLevelLetEntry.
 * @return i32 - 260
 */
function pipe_tl_off_type_ref(): i32 {
  return 260;
}

/**
 * Byte offset of init_ref within TopLevelLetEntry.
 * @return i32 - 264
 */
function pipe_tl_off_init_ref(): i32 {
  return 264;
}

/**
 * Byte offset of is_const within TopLevelLetEntry.
 * @return i32 - 140
 */
function pipe_tl_off_is_const(): i32 {
  return 268;
}

/**
 * Byte offset of is_export within TopLevelLetEntry.
 * @return i32 - 272
 */
function pipe_tl_off_is_export(): i32 {
  return 272;
}

/**
 * Byte offset of entry idx within the flat entry table.
 * @param idx i32 - entry index
 * @return i32 - byte offset
 */
function pipe_tl_entry_off(idx: i32): i32 {
  return idx * pipe_tl_entry_size();
}

/**
 * LP64 offsetof(struct ast_Module, num_top_level_lets).
 * @return i32 - 12
 * PLATFORM: SHARED LP64 - dual-end; see pipe_mod_off_num_top_level_lets.
 */
function pipe_tl_off_header_n(): i32 {
  return 12;
}

/**
 * Read module.num_top_level_lets header field (null -> 0).
 * @param module *u8 - opaque ast_Module
 * @return i32 - header count
 */
function pipe_tl_get_header_n(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(module, pipe_tl_off_header_n());
}

/**
 * Write module.num_top_level_lets header field (null-safe).
 * @param module *u8 - opaque ast_Module
 * @param n i32 - live top-level let count
 * @return void
 */
function pipe_tl_set_header_n(module: *u8, n: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  pipe_store_i32_le(module, pipe_tl_off_header_n(), n);
}

/**
 * Find map slot for module pointer (exact key match).
 * @param module *u8 - module key; null -> -1
 * @return i32 - slot 0..127 or -1
 */
function pipe_tl_find_slot(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  let i: i32 = 0;
  while (i < 128) {
    let k: *u8 = xlang_ptr_slot_get(&g_pipe_tl_mod[0], i);
    if (k == module) {
      return i;
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Soft-reset pure counts when header num_top_level_lets is 0 (parse/module reset).
 * Keeps malloc capacity; zeros live n.
 * @param module *u8 - module key
 * @return void
 */
function pipe_tl_soft_sync(module: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  if (pipe_tl_get_header_n(module) != 0) {
    return;
  }
  let s: i32 = pipe_tl_find_slot(module);
  if (s < 0) {
    return;
  }
  g_pipe_tl_n[s] = 0;
}

/**
 * Find or allocate a map slot for module.
 * @param module *u8 - module key; null -> -1
 * @return i32 - slot or -1 if map full
 */
function pipe_tl_find_or_create(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  pipe_tl_soft_sync(module);
  let found: i32 = pipe_tl_find_slot(module);
  if (found >= 0) {
    return found;
  }
  let i: i32 = 0;
  while (i < 128) {
    let k: *u8 = xlang_ptr_slot_get(&g_pipe_tl_mod[0], i);
    if (k == 0 as *u8) {
      xlang_ptr_slot_set(&g_pipe_tl_mod[0], i, module);
      g_pipe_tl_n[i] = 0;
      g_pipe_tl_cap[i] = 0;
      xlang_ptr_slot_set(&g_pipe_tl_entries[0], i, 0 as *u8);
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
function pipe_tl_ensure_entries(slot: i32, need: i32): i32 {
  if (slot < 0) {
    return 0;
  }
  if (slot >= 128) {
    return 0;
  }
  if (need <= 0) {
    return 1;
  }
  let cap: i32 = g_pipe_tl_cap[slot];
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
  let esz: i32 = pipe_tl_entry_size();
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
  let old: *u8 = xlang_ptr_slot_get(&g_pipe_tl_entries[0], slot);
  let old_n: i32 = g_pipe_tl_n[slot];
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
  xlang_ptr_slot_set(&g_pipe_tl_entries[0], slot, np);
  g_pipe_tl_cap[slot] = new_cap;
  return 1;
}

/**
 * Pointer to TopLevelLetEntry at (slot, idx); null if OOB.
 * @param slot i32 - map slot
 * @param idx i32 - entry index
 * @return *u8 - entry base or null
 */
function pipe_tl_entry_at(slot: i32, idx: i32): *u8 {
  if (slot < 0) {
    return 0 as *u8;
  }
  if (slot >= 128) {
    return 0 as *u8;
  }
  if (idx < 0) {
    return 0 as *u8;
  }
  if (idx >= g_pipe_tl_n[slot]) {
    return 0 as *u8;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_tl_entries[0], slot);
  if (base == 0 as *u8) {
    return 0 as *u8;
  }
  return base + pipe_tl_entry_off(idx);
}

/**
 * Soft-reset pure top-level-let count for module (keep malloc capacity).
 * Called from ast_pool_module_reset so re-parse does not see stale lets.
 * @param module *u8 - module key; null -> no-op
 * @return void
 * PLATFORM: SHARED - product hybrid owns live count.
 */
#[no_mangle]
export function pipeline_module_top_level_let_storage_reset(module: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  let s: i32 = pipe_tl_find_slot(module);
  if (s < 0) {
    pipe_tl_set_header_n(module, 0);
    return;
  }
  g_pipe_tl_n[s] = 0;
  pipe_tl_set_header_n(module, 0);
}

/**
 * Free pure top-level-let storage for one module and clear map slot.
 * @param module *u8 - module key; null -> no-op
 * @return void
 * wave265: called from Cap ast_pool_module_release (strong pure).
 * PLATFORM: SHARED - product hybrid owns free of malloc tables.
 */
#[no_mangle]
export function pipeline_module_top_level_let_storage_release(module: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  let s: i32 = pipe_tl_find_slot(module);
  if (s < 0) {
    return;
  }
  let e: *u8 = xlang_ptr_slot_get(&g_pipe_tl_entries[0], s);
  if (e != 0 as *u8) {
    unsafe {
      free(e);
    }
  }
  xlang_ptr_slot_set(&g_pipe_tl_mod[0], s, 0 as *u8);
  xlang_ptr_slot_set(&g_pipe_tl_entries[0], s, 0 as *u8);
  g_pipe_tl_n[s] = 0;
  g_pipe_tl_cap[s] = 0;
  pipe_tl_set_header_n(module, 0);
}

/**
 * Allocate one TopLevelLetEntry for module; return index or -1.
 * @param module *u8 - opaque ast_Module; null -> -1
 * @return i32 - new let index (>=0) or -1
 * wave265 pure Cap residual leave: G.7 product authority (historical GrowVec).
 * Updates module.num_top_level_lets header ≡ Cap m->num_top_level_lets = sc->len.
 * PLATFORM: SHARED - seed cold twin under #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_module_top_level_let_alloc(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  let s: i32 = pipe_tl_find_or_create(module);
  if (s < 0) {
    return 0 - 1;
  }
  let n: i32 = g_pipe_tl_n[s];
  if (pipe_tl_ensure_entries(s, n + 1) == 0) {
    return 0 - 1;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_tl_entries[0], s);
  if (base == 0 as *u8) {
    return 0 - 1;
  }
  let off: i32 = pipe_tl_entry_off(n);
  let esz: i32 = pipe_tl_entry_size();
  unsafe {
    memset(base + off, 0, esz as usize);
  }
  g_pipe_tl_n[s] = n + 1;
  pipe_tl_set_header_n(module, n + 1);
  return n;
}

/**
 * Set top-level let slot fields (name, type_ref, init_ref, is_const).
 * @param module *u8 - module
 * @param idx i32 - let index
 * @param name *u8 - name bytes
 * @param name_len i32 - content length 1..255
 * @param type_ref i32 - type ref
 * @param init_ref i32 - init expr ref
 * @param is_const i32 - 0/1 const
 * @return void
 * wave581 Cap residual: name content max 255. PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_top_level_let_set(module: *u8, idx: i32, name: *u8, name_len: i32, type_ref: i32, init_ref: i32, is_const: i32): void {
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
  pipe_tl_soft_sync(module);
  let s: i32 = pipe_tl_find_slot(module);
  if (s < 0) {
    return;
  }
  let e: *u8 = pipe_tl_entry_at(s, idx);
  if (e == 0 as *u8) {
    return;
  }
  let n: i32 = name_len;
  let i: i32 = 0;
  while (i < n) {
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
  pipe_store_i32_le(e, pipe_tl_off_name_len(), n);
  pipe_store_i32_le(e, pipe_tl_off_type_ref(), type_ref);
  pipe_store_i32_le(e, pipe_tl_off_init_ref(), init_ref);
  pipe_store_i32_le(e, pipe_tl_off_is_const(), is_const);
}

/**
 * Stamp top-level const type_ref after inference from init.
 * @param module *u8 - module
 * @param idx i32 - let index
 * @param type_ref i32 - inferred type
 * @return void
 * PLATFORM: SHARED typeck/AST.
 */
#[no_mangle]
export function pipeline_module_top_level_let_set_type_ref(module: *u8, idx: i32, type_ref: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  pipe_tl_soft_sync(module);
  let s: i32 = pipe_tl_find_slot(module);
  if (s < 0) {
    return;
  }
  let e: *u8 = pipe_tl_entry_at(s, idx);
  if (e == 0 as *u8) {
    return;
  }
  pipe_store_i32_le(e, pipe_tl_off_type_ref(), type_ref);
}

/**
 * Read name length of top-level let idx.
 * @param module *u8 - module
 * @param idx i32 - let index
 * @return i32 - name_len or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_top_level_let_name_len(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_tl_soft_sync(module);
  let s: i32 = pipe_tl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let e: *u8 = pipe_tl_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(e, pipe_tl_off_name_len());
}

/**
 * Read one name byte of top-level let idx.
 * @param module *u8 - module
 * @param idx i32 - let index
 * @param off i32 - byte offset 0..126
 * @return i32 - name byte (0..255) or 0; i32 matches prior Cap export extern contract
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_top_level_let_name_byte_at(module: *u8, idx: i32, off: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  if (off < 0) {
    return 0;
  }
  if (off >= 127) {
    return 0;
  }
  pipe_tl_soft_sync(module);
  let s: i32 = pipe_tl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let e: *u8 = pipe_tl_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0;
  }
  let nlen: i32 = pipe_load_i32_le(e, pipe_tl_off_name_len());
  if (off >= nlen) {
    return 0;
  }
  unsafe {
    return e[off] as i32;
  }
}

/**
 * Read type_ref of top-level let idx.
 * @param module *u8 - module
 * @param idx i32 - let index
 * @return i32 - type_ref or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_top_level_let_type_ref(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_tl_soft_sync(module);
  let s: i32 = pipe_tl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let e: *u8 = pipe_tl_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(e, pipe_tl_off_type_ref());
}

/**
 * Read init_ref of top-level let idx.
 * @param module *u8 - module
 * @param idx i32 - let index
 * @return i32 - init_ref or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_top_level_let_init_ref(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_tl_soft_sync(module);
  let s: i32 = pipe_tl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let e: *u8 = pipe_tl_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(e, pipe_tl_off_init_ref());
}

/**
 * Read is_const flag of top-level let idx.
 * @param module *u8 - module
 * @param idx i32 - let index
 * @return i32 - is_const or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_top_level_let_is_const(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_tl_soft_sync(module);
  let s: i32 = pipe_tl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let e: *u8 = pipe_tl_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(e, pipe_tl_off_is_const());
}

/**
 * Set is_export flag for top-level let idx.
 * @param module *u8 - module
 * @param idx i32 - let index
 * @param is_export i32 - 0/1 export
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_top_level_let_set_is_export(module: *u8, idx: i32, is_export: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  pipe_tl_soft_sync(module);
  let s: i32 = pipe_tl_find_slot(module);
  if (s < 0) {
    return;
  }
  let e: *u8 = pipe_tl_entry_at(s, idx);
  if (e == 0 as *u8) {
    return;
  }
  pipe_store_i32_le(e, pipe_tl_off_is_export(), is_export);
}

/**
 * Read is_export flag for top-level let idx.
 * @param module *u8 - module
 * @param idx i32 - let index
 * @return i32 - is_export or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_top_level_let_is_export_at(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_tl_soft_sync(module);
  let s: i32 = pipe_tl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let e: *u8 = pipe_tl_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(e, pipe_tl_off_is_export());
}

/**
 * Compare top-level let name at idx with probe name[0..name_len).
 * @param module *u8 - module
 * @param idx i32 - let index
 * @param name *u8 - probe
 * @param name_len i32 - probe length
 * @return i32 - 1 match, 0 miss
 */
function pipe_tl_name_eq(module: *u8, idx: i32, name: *u8, name_len: i32): i32 {
  let nl: i32 = pipeline_module_top_level_let_name_len(module, idx);
  if (nl != name_len) {
    return 0;
  }
  let k: i32 = 0;
  while (k < name_len) {
    let b: i32 = pipeline_module_top_level_let_name_byte_at(module, idx, k);
    let pb: i32 = 0;
    unsafe {
      pb = name[k] as i32;
    }
    if (b != pb) {
      return 0;
    }
    k = k + 1;
  }
  return 1;
}

/**
 * 1 if a module top-level let/const slot has this name and is_const.
 * @param module *u8 - module
 * @param vname *u8 - probe name bytes
 * @param vlen i32 - probe length
 * @return i32 - 1 const top-level, 0 otherwise
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_top_level_name_is_const(module: *u8, vname: *u8, vlen: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  if (vname == 0 as *u8) {
    return 0;
  }
  if (vlen <= 0) {
    return 0;
  }
  pipe_tl_soft_sync(module);
  let n: i32 = pipe_tl_get_header_n(module);
  let i: i32 = 0;
  while (i < n) {
    if (pipe_tl_name_eq(module, i, vname, vlen) != 0) {
      if (pipeline_module_top_level_let_is_const(module, i) != 0) {
        return 1;
      }
      return 0;
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Return the hoist target function index: main when set, else first non-extern body.
 * @param module *u8 - module
 * @return i32 - func index, or -1 if none
 * PLATFORM: SHARED - asm frame layout / backend pre-mega path.
 */
#[no_mangle]
export function pipeline_asm_hoist_target_func_index(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  let mi: i32 = pipeline_module_main_func_index(module);
  if (mi >= 0) {
    return mi;
  }
  let nf: i32 = pipeline_module_num_funcs(module);
  let fi: i32 = 0;
  while (fi < nf) {
    let is_ext: i32 = 0;
    let br: i32 = 0;
    unsafe {
      is_ext = pipeline_asm_module_func_is_extern_at(module, fi);
      br = pipeline_module_func_body_ref_at(module, fi);
    }
    if (is_ext == 0) {
      if (br > 0) {
        return fi;
      }
    }
    fi = fi + 1;
  }
  return 0 - 1;
}

/**
 * Hoist module top-level let/const into main (or first non-extern body) for asm
 * stack-slot init. Keeps num_top_level_lets so emit can still fall back to
 * module const literals for other functions.
 *
 * Stage 12.0.5: do NOT hoist *any* fixed TYPE_ARRAY module lets
 * (ARRAY_LIT init), const or mutable. Those become SHN_COMMON via
 * pipeline_asm_modlet_prepare_and_emit_elf_c; hoisting them stacked full
 * payload on the hoist-target frame (labi_path_pure g_labi_* ~sum N*2)
 * while COMMON already held the durable home — dual stack/BSS + SEGV.
 * dest-SLICE ARRAY_LIT (`const t:[]T=[…]`) and const `[N][]T` (elem
 * TYPE_SLICE fat rows) still hoist — prepare skips those (seed is LIT
 * only; durable dest_elem_ty is the fat-row home).
 *
 * 9.6.0: do NOT hoist mutable scalar LIT/BOOL top-level lets either.
 * prepare registers them as 8-byte SHN_COMMON (wave139 gate: init_kind
 * 0/2 with is_const==0) and seed_nonzero_inits seeds the home once on
 * hoist-target entry. Hoisting stacked a second stale main frame slot
 * beside the COMMON home — slot-first consumers (compare fast path /
 * lit-left twin / INDEX base) read the slot while RMW reads COMMON
 * (probe p12: `g=g+1; g=g+1; if g==2` compared a never-updated slot and
 * returned false; p14 proved the init reaches COMMON). Skipping keeps
 * COMMON the single home; every consumer then falls to the generic
 * modlet-first VAR emit (= proven non-hoist-function behavior, p16).
 * The skip re-checks init_ref validity because ik_h is sampled only when
 * init_ref is in range — an un-initialized let must still hoist (prepare
 * skips it too, so no COMMON cell exists for it).
 *
 * Scalar ADDR_OF / fn-ptr (tk 9/18, pipe_modlet_scalar_init_is_ptr_addr)
 * also stay un-hoisted: prepare bakes an 8-byte .data cell + absolute64
 * RELA so non-hoist functions / library TUs see the pointer. Dual-home
 * would leave other() reading an unseeded slot (q4-shaped main-only was
 * the historic hoist green).
 *
 * prepend_lets count must equal the number actually appended (not raw n), else
 * skipped COMMON arrays would desync stmt_order vs block lets.
 *
 * @param module *u8 - module
 * @param arena *u8 - ASTArena
 * @return void
 * Cap residual: pipeline_block_append_let + pipeline_block_stmt_order_prepend_lets.
 * PLATFORM: SHARED - asm emit / backend pre-mega path.
 */
#[no_mangle]
export function pipeline_module_hoist_top_level_lets_into_main(module: *u8, arena: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  if (arena == 0 as *u8) {
    return;
  }
  pipe_tl_soft_sync(module);
  let n: i32 = pipe_tl_get_header_n(module);
  if (n <= 0) {
    return;
  }
  let mi: i32 = pipeline_module_main_func_index(module);
  if (mi < 0) {
    mi = 0 - 1;
    let nf: i32 = pipeline_module_num_funcs(module);
    let fi: i32 = 0;
    while (fi < nf) {
      let is_ext: i32 = 0;
      let br0: i32 = 0;
      unsafe {
        is_ext = pipeline_asm_module_func_is_extern_at(module, fi);
        br0 = pipeline_module_func_body_ref_at(module, fi);
      }
      if (is_ext == 0) {
        if (br0 > 0) {
          mi = fi;
          fi = nf;
        } else {
          fi = fi + 1;
        }
      } else {
        fi = fi + 1;
      }
    }
    if (mi < 0) {
      return;
    }
  }
  let br: i32 = 0;
  unsafe {
    br = pipeline_module_func_body_ref_at(module, mi);
  }
  if (br <= 0) {
    return;
  }
  let let_start_idx: i32 = 0;
  unsafe {
    let_start_idx = ast_ast_block_num_lets(arena, br);
  }
  let nexprs: i32 = pipe_load_i32_le(arena, pipe_arena_off_num_exprs());
  let hoisted: i32 = 0;
  let tl: i32 = 0;
  while (tl < n) {
    let name_len: i32 = pipeline_module_top_level_let_name_len(module, tl);
    if (name_len > 0) {
      if (name_len <= 255) {
        let type_ref: i32 = pipeline_module_top_level_let_type_ref(module, tl);
        let init_ref: i32 = pipeline_module_top_level_let_init_ref(module, tl);
        // Skip COMMON-bound fixed arrays (match prepare/sum/register).
        let skip_common_arr: i32 = 0;
        if (type_ref > 0) {
          let tk_h: i32 = 0;
          let ik_h: i32 = 0;
          unsafe {
            tk_h = pipeline_type_kind_ord_at(arena, type_ref);
            if (init_ref > 0 && init_ref <= nexprs) {
              ik_h = pipeline_expr_kind_ord_at(arena, init_ref);
            }
          }
          if (tk_h == 10) {
            let is_c_arr: i32 = 0;
            unsafe {
              is_c_arr = pipeline_module_top_level_let_is_const(module, tl);
            }
            // Mutable TYPE_ARRAY always COMMON (Stage 12.0.5).
            // Const TYPE_ARRAY COMMON unless elem is TYPE_SLICE (`[N][]T`
            // fat rows — hoist + durable; prepare skips those).
            // PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
            if (is_c_arr == 0) {
              skip_common_arr = 1;
            } else {
              let et_h: i32 = 0;
              let etk_h: i32 = 0;
              unsafe {
                et_h = pipeline_type_elem_ref_at(arena, type_ref);
              }
              if (et_h > 0) {
                unsafe {
                  etk_h = pipeline_type_kind_ord_at(arena, et_h);
                }
              }
              if (etk_h != 11) {
                skip_common_arr = 1;
              }
            }
          } else {
            if (ik_h == 46) {
              let is_c_h: i32 = 0;
              unsafe {
                is_c_h = pipeline_module_top_level_let_is_const(module, tl);
              }
              // Mutable dest-SLICE ARRAY_LIT stays un-hoisted (pre-existing).
              // Const dest-SLICE ARRAY_LIT still hoists (no TYPE_ARRAY cell).
              if (is_c_h == 0) {
                skip_common_arr = 1;
              }
            } else {
              // 9.6.0: mutable scalar LIT/BOOL init is modlet COMMON-owned
              // (prepare registers init_kind 0/2 with is_const==0). Hoisting
              // stacked a stale main frame slot beside the COMMON home and
              // slot-first consumers read the slot (p12 miscompile). ik_h is
              // only meaningful when init_ref was in range, so re-check it:
              // an un-initialized let has no COMMON cell and must still
              // hoist. Const scalars keep hoisting (prepare skips those).
              // PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
              if ((ik_h == 0 || ik_h == 2) && init_ref > 0 && init_ref <= nexprs) {
                let is_c_sc: i32 = 0;
                unsafe {
                  is_c_sc = pipeline_module_top_level_let_is_const(module, tl);
                }
                if (is_c_sc == 0) {
                  skip_common_arr = 1;
                }
              }
            }
          }
          // Scalar ADDR_OF / fn-ptr: same predicate as prepare register.
          // PLATFORM: SHARED — 9.6.0 dual-home class.
          if (skip_common_arr == 0 && (tk_h == 9 || tk_h == 18) && init_ref > 0 && init_ref <= nexprs) {
            if (pipe_modlet_scalar_init_is_ptr_addr(arena, module, init_ref) != 0) {
              skip_common_arr = 1;
            }
          }
        }
        if (skip_common_arr == 0) {
          let name_buf: u8[256] = [];
          let k: i32 = 0;
          while (k < name_len) {
            name_buf[k] = pipeline_module_top_level_let_name_byte_at(module, tl, k) as u8;
            k = k + 1;
          }
          unsafe {
            let _al: i32 = pipeline_block_append_let(arena, br, &name_buf[0], name_len, type_ref, init_ref);
          }
          hoisted = hoisted + 1;
        }
      }
    }
    tl = tl + 1;
  }
  if (hoisted > 0) {
    unsafe {
      pipeline_block_stmt_order_prepend_lets(arena, br, let_start_idx, hoisted);
    }
  }
}

/**
 * Accumulate stack occupancy of module top-level let/const slots for non-hoist
 * target functions (frame_size estimate). Skipped (never per-func stack):
 *   · shared modlet cells (scalar lit COMMON / text cells)
 *   · fixed TYPE_ARRAY module lets (Stage 12.0.5: full COMMON via prepare;
 *     stacking them once per function blew frames by sum(g_labi_* ) ~160KB)
 * @param arena *u8 - ASTArena
 * @param mod *u8 - module
 * @param off i32 - incoming frame offset
 * @return i32 - updated frame offset
 * PLATFORM: SHARED - asm emit frame layout.
 */
#[no_mangle]
export function pipeline_asm_sum_module_top_level_lets_stack(arena: *u8, mod: *u8, off: i32): i32 {
  if (arena == 0 as *u8) {
    return off;
  }
  if (mod == 0 as *u8) {
    return off;
  }
  pipe_tl_soft_sync(mod);
  let n: i32 = pipe_tl_get_header_n(mod);
  if (n <= 0) {
    return off;
  }
  let cur: i32 = off;
  let tl: i32 = 0;
  while (tl < n) {
    let type_ref: i32 = pipeline_module_top_level_let_type_ref(mod, tl);
    if (type_ref > 0) {
      let skip: i32 = 0;
      let init_ref: i32 = pipeline_module_top_level_let_init_ref(mod, tl);
      // Stage 12.0.5: module fixed arrays → COMMON via prepare (never per-func stack).
      // Skip when TYPE_ARRAY (10) OR ARRAY_LIT init (46) — dual signal; type_kind alone
      // can miss when top_level type_ref is not yet stamped ARRAY at sum time.
      let tk: i32 = 0;
      let ik: i32 = 0;
      unsafe {
        tk = pipeline_type_kind_ord_at(arena, type_ref);
        if (init_ref > 0) {
          ik = pipeline_expr_kind_ord_at(arena, init_ref);
        }
      }
      if (tk == 10 || ik == 46) {
        skip = 1;
      }
      let name_len: i32 = pipeline_module_top_level_let_name_len(mod, tl);
      if (skip == 0 && name_len > 0) {
        let name_buf: u8[256] = [];
        let k: i32 = 0;
        while (k < name_len) {
          name_buf[k] = pipeline_module_top_level_let_name_byte_at(mod, tl, k) as u8;
          k = k + 1;
        }
        if (pipeline_asm_modlet_name_is_shared(&name_buf[0], name_len) != 0) {
          skip = 1;
        }
      }
      if (skip == 0) {
        let off_slot: i32[1] = [];
        off_slot[0] = cur;
        unsafe {
          let _so: i32 = asm_local_slot_reg_offset(arena, type_ref, cur, &off_slot[0]);
        }
        cur = off_slot[0];
        cur = cur + pipeline_asm_let_init_stack_reserve_bytes(arena, type_ref, init_ref);
      }
    }
    tl = tl + 1;
  }
  return cur;
}

