// Thin pure: wave310/377/390 M2 — module_import Cap residual C→.x
//   (was wave263 C thin).
// ImportEntry LE 532B multi-module map + select rows; 18 exports.
// G.7: bodies match runtime_pipeline_abi.x wave110/wave263 leave.
// wave377: BAN PREFER (Darwin g05 BRANCH26); MACOS -E of T001-wrapped thin;
//   LINUX hard-skip (Ubuntu typeck rejects wrapped thin).
// wave390: HARD BAN reinject both ends (stamp .pabi_w390_module_import.stamp);
//   stay prior Darwin -E / Ubuntu prior -E until BRANCH26 root.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function xlang_ptr_slot_get(arr: *u8, i: i32): *u8;
export extern function xlang_ptr_slot_set(arr: *u8, i: i32, p: *u8): void;
export extern "C" function malloc(n: usize): *u8;
export extern "C" function free(p: *u8): void;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;

let g_pipe_imp_mod: u8[1024] = [];
let g_pipe_imp_n: i32[128] = [];
let g_pipe_imp_cap: i32[128] = [];
let g_pipe_imp_entries: u8[1024] = [];
let g_pipe_imp_sel_n: i32[128] = [];
let g_pipe_imp_sel_cap: i32[128] = [];
let g_pipe_imp_sel_rows: u8[1024] = [];
let g_pipe_imp_sel_lens: u8[1024] = [];

/**
 * Byte size of one ImportEntry (path 256 + binding 256 + 4 i32 fields).
 * @return i32 - 532
 * PLATFORM: SHARED LP64 - must match C sizeof(ImportEntry).
 */
function pipe_imp_entry_size(): i32 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return 532;
  }
}

/**
 * LP64 offsetof(struct ast_Module, num_imports).
 * @return i32 - 8
 * PLATFORM: SHARED LP64 - dual-end verified with sizeof Module=68.
 */
function pipe_imp_off_num_imports(): i32 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return 8;
  }
}

/**
 * Write module.num_imports header field (null-safe).
 * @param module *u8 - opaque ast_Module
 * @param n i32 - live import count
 * @return void
 */
function pipe_imp_set_header_n(module: *u8, n: i32): void {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return;
    }
    pipe_store_i32_le(module, pipe_imp_off_num_imports(), n);
  }
}

/**
 * Read module.num_imports header field (null -> 0).
 * @param module *u8 - opaque ast_Module
 * @return i32 - header count
 */
function pipe_imp_get_header_n(module: *u8): i32 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return 0;
    }
    return pipe_load_i32_le(module, pipe_imp_off_num_imports());
  }
}

/**
 * Find map slot for module pointer (exact key match).
 * @param module *u8 - module key; null -> -1
 * @return i32 - slot 0..127 or -1
 */
function pipe_imp_find_slot(module: *u8): i32 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return 0 - 1;
    }
    let i: i32 = 0;
    while (i < 128) {
      let k: *u8 = xlang_ptr_slot_get(&g_pipe_imp_mod[0], i);
      if (k == module) {
        return i;
      }
      i = i + 1;
    }
    return 0 - 1;
  }
}

/**
 * Soft-reset pure counts when header num_imports is 0 (parse/module reset).
 * Keeps malloc capacity; zeros live n_imports and select row count.
 * @param module *u8 - module key
 * @return void
 */
function pipe_imp_soft_sync(module: *u8): void {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return;
    }
    if (pipe_imp_get_header_n(module) != 0) {
      return;
    }
    let s: i32 = pipe_imp_find_slot(module);
    if (s < 0) {
      return;
    }
    g_pipe_imp_n[s] = 0;
    g_pipe_imp_sel_n[s] = 0;
  }
}

/**
 * Find or allocate a map slot for module.
 * @param module *u8 - module key; null -> -1
 * @return i32 - slot or -1 if map full
 */
function pipe_imp_find_or_create(module: *u8): i32 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return 0 - 1;
    }
    pipe_imp_soft_sync(module);
    let found: i32 = pipe_imp_find_slot(module);
    if (found >= 0) {
      return found;
    }
    let i: i32 = 0;
    while (i < 128) {
      let k: *u8 = xlang_ptr_slot_get(&g_pipe_imp_mod[0], i);
      if (k == 0 as *u8) {
        xlang_ptr_slot_set(&g_pipe_imp_mod[0], i, module);
        g_pipe_imp_n[i] = 0;
        g_pipe_imp_cap[i] = 0;
        g_pipe_imp_sel_n[i] = 0;
        g_pipe_imp_sel_cap[i] = 0;
        xlang_ptr_slot_set(&g_pipe_imp_entries[0], i, 0 as *u8);
        xlang_ptr_slot_set(&g_pipe_imp_sel_rows[0], i, 0 as *u8);
        xlang_ptr_slot_set(&g_pipe_imp_sel_lens[0], i, 0 as *u8);
        return i;
      }
      i = i + 1;
    }
    return 0 - 1;
  }
}

/**
 * Ensure entry table capacity >= need for slot (malloc grow, double).
 * @param slot i32 - map slot
 * @param need i32 - required live+push capacity
 * @return i32 - 1 ok, 0 fail
 */
function pipe_imp_ensure_entries(slot: i32, need: i32): i32 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (slot < 0) {
      return 0;
    }
    if (slot >= 128) {
      return 0;
    }
    if (need <= 0) {
      return 1;
    }
    let cap: i32 = g_pipe_imp_cap[slot];
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
    let esz: i32 = pipe_imp_entry_size();
    let nbytes: usize = (new_cap * esz) as usize;
    // extern malloc/memset/memcpy/free require unsafe (T001).
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
    let old: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], slot);
    let old_n: i32 = g_pipe_imp_n[slot];
    if (old != 0 as *u8) {
      if (old_n > 0) {
        let old_bytes: usize = (old_n * esz) as usize;
        unsafe {
          memcpy(np, old, old_bytes);
        }
      }
      unsafe {
        free(old);
      }
    }
    xlang_ptr_slot_set(&g_pipe_imp_entries[0], slot, np);
    g_pipe_imp_cap[slot] = new_cap;
    return 1;
  }
}

/**
 * Ensure select row/lens capacity >= need for slot.
 * @param slot i32 - map slot
 * @param need i32 - required select row count
 * @return i32 - 1 ok, 0 fail
 */
function pipe_imp_ensure_select(slot: i32, need: i32): i32 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (slot < 0) {
      return 0;
    }
    if (slot >= 128) {
      return 0;
    }
    if (need <= 0) {
      return 1;
    }
    let cap: i32 = g_pipe_imp_sel_cap[slot];
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
    let row_bytes: usize = (new_cap * 64) as usize;
    let lens_bytes: usize = (new_cap * 4) as usize;
    let nrows: *u8 = 0 as *u8;
    let nlens: *u8 = 0 as *u8;
    unsafe {
      nrows = malloc(row_bytes);
      nlens = malloc(lens_bytes);
    }
    if (nrows == 0 as *u8) {
      if (nlens != 0 as *u8) {
        unsafe {
          free(nlens);
        }
      }
      return 0;
    }
    if (nlens == 0 as *u8) {
      unsafe {
        free(nrows);
      }
      return 0;
    }
    unsafe {
      memset(nrows, 0, row_bytes);
      memset(nlens, 0, lens_bytes);
    }
    let old_rows: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_rows[0], slot);
    let old_lens: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_lens[0], slot);
    let old_n: i32 = g_pipe_imp_sel_n[slot];
    if (old_rows != 0 as *u8) {
      if (old_n > 0) {
        unsafe {
          memcpy(nrows, old_rows, (old_n * 64) as usize);
        }
      }
      unsafe {
        free(old_rows);
      }
    }
    if (old_lens != 0 as *u8) {
      if (old_n > 0) {
        unsafe {
          memcpy(nlens, old_lens, (old_n * 4) as usize);
        }
      }
      unsafe {
        free(old_lens);
      }
    }
    xlang_ptr_slot_set(&g_pipe_imp_sel_rows[0], slot, nrows);
    xlang_ptr_slot_set(&g_pipe_imp_sel_lens[0], slot, nlens);
    g_pipe_imp_sel_cap[slot] = new_cap;
    return 1;
  }
}

/**
 * Pointer to ImportEntry byte base at idx for slot (null if OOB).
 * @param slot i32 - map slot
 * @param idx i32 - import index
 * @return *u8 - entry base or null
 */
export function pipe_imp_entry_at(slot: i32, idx: i32): *u8 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (slot < 0) {
      return 0 as *u8;
    }
    if (idx < 0) {
      return 0 as *u8;
    }
    if (idx >= g_pipe_imp_n[slot]) {
      return 0 as *u8;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], slot);
    if (base == 0 as *u8) {
      return 0 as *u8;
    }
    // Cap 4.2.8: byte offset = idx * pipe_imp_entry_size() (532; was 340).
    let off: i32 = idx * pipe_imp_entry_size();
    // return base+off by reconstructing from raw address bits is unavailable;
    // use index into flat table: xlang path indexes base[off + field]
    // Callers pass (base, idx) pair - store base and use idx*esz offset in field ops.
    return base;
  }
}

/**
 * Field offset of entry idx inside entries buffer.
 * @param idx i32 - import index
 * @return i32 - byte offset
 */
function pipe_imp_entry_off(idx: i32): i32 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return idx * pipe_imp_entry_size();
  }
}

/**
 * Free pure import storage for one module and clear map slot.
 * @param module *u8 - module key; null -> no-op
 * @return void
 * wave110: called from Cap ast_pool_module_release (strong pure) and cold weak empty.
 * PLATFORM: SHARED - product hybrid owns free of malloc tables.
 */
#[no_mangle]
export function pipeline_module_import_storage_release(module: *u8): void {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return;
    }
    let s: i32 = pipe_imp_find_slot(module);
    if (s < 0) {
      return;
    }
    let e: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
    if (e != 0 as *u8) {
      unsafe {
        free(e);
      }
    }
    let r: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_rows[0], s);
    if (r != 0 as *u8) {
      unsafe {
        free(r);
      }
    }
    let l: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_lens[0], s);
    if (l != 0 as *u8) {
      unsafe {
        free(l);
      }
    }
    xlang_ptr_slot_set(&g_pipe_imp_mod[0], s, 0 as *u8);
    xlang_ptr_slot_set(&g_pipe_imp_entries[0], s, 0 as *u8);
    xlang_ptr_slot_set(&g_pipe_imp_sel_rows[0], s, 0 as *u8);
    xlang_ptr_slot_set(&g_pipe_imp_sel_lens[0], s, 0 as *u8);
    g_pipe_imp_n[s] = 0;
    g_pipe_imp_cap[s] = 0;
    g_pipe_imp_sel_n[s] = 0;
    g_pipe_imp_sel_cap[s] = 0;
  }
}

/**
 * Allocate one ImportEntry for module; return index or -1.
 * @param module *u8 - opaque ast_Module; null -> -1
 * @return i32 - new import index (>=0) or -1
 * wave110 pure Cap residual: G.7 product authority (historical ast_pool GrowVec).
 * Updates module.num_imports header ≡ Cap m->num_imports = sc->imports.length.
 * PLATFORM: SHARED - Cap XLANG_WEAK cold twin for non-PREFER links.
 */
#[no_mangle]
export function pipeline_module_import_alloc(module: *u8): i32 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return 0 - 1;
    }
    let s: i32 = pipe_imp_find_or_create(module);
    if (s < 0) {
      return 0 - 1;
    }
    let n: i32 = g_pipe_imp_n[s];
    if (pipe_imp_ensure_entries(s, n + 1) == 0) {
      return 0 - 1;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
    if (base == 0 as *u8) {
      return 0 - 1;
    }
    let off: i32 = pipe_imp_entry_off(n);
    // Cap 4.2.8: zero new ImportEntry (532 bytes; was 340). Incomplete zero left
    // binding_name_len@520 / select_* garbage → T001 "no impl for method".
    let esz: i32 = pipe_imp_entry_size();
    let k: i32 = 0;
    while (k < esz) {
      unsafe {
        base[off + k] = 0;
      }
      k = k + 1;
    }
    g_pipe_imp_n[s] = n + 1;
    pipe_imp_set_header_n(module, n + 1);
    return n;
  }
}

/**
 * Set import path bytes at idx (len 1..255).
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param bytes *u8 - path bytes
 * @param len i32 - byte length; <=0 or >255 -> no-op
 * @return void
 * PLATFORM: SHARED - ≡ Cap pipeline_module_import_set_path.
 */
#[no_mangle]
export function pipeline_module_import_set_path(module: *u8, idx: i32, bytes: *u8, len: i32): void {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
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
    pipe_imp_soft_sync(module);
    let s: i32 = pipe_imp_find_slot(module);
    if (s < 0) {
      return;
    }
    if (idx < 0) {
      return;
    }
    if (idx >= g_pipe_imp_n[s]) {
      return;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
    if (base == 0 as *u8) {
      return;
    }
    let off: i32 = pipe_imp_entry_off(idx);
    let z: i32 = 0;
    while (z < 256) {
      unsafe {
        base[off + z] = 0;
      }
      z = z + 1;
    }
    let i: i32 = 0;
    while (i < len) {
      unsafe {
        base[off + i] = bytes[i];
      }
      i = i + 1;
    }
    pipe_store_i32_le(base, off + 256, len);
  }
}

/**
 * Import path length at idx.
 * @param module *u8 - module
 * @param idx i32 - import index
 * @return i32 - path_len or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_path_len(module: *u8, idx: i32): i32 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return 0;
    }
    pipe_imp_soft_sync(module);
    let s: i32 = pipe_imp_find_slot(module);
    if (s < 0) {
      return 0;
    }
    if (idx < 0) {
      return 0;
    }
    if (idx >= g_pipe_imp_n[s]) {
      return 0;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
    if (base == 0 as *u8) {
      return 0;
    }
    return pipe_load_i32_le(base, pipe_imp_entry_off(idx) + 256);
  }
}

/**
 * Copy import path to dst with trailing NUL (cap includes NUL).
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param dst *u8 - destination
 * @param dst_cap i32 - capacity
 * @return void
 * wave110 pure: G.7 product path_copy authority (wave99 path64 thin consumer).
 * PLATFORM: SHARED - Cap XLANG_WEAK cold twin.
 */
#[no_mangle]
export function pipeline_module_import_path_copy(module: *u8, idx: i32, dst: *u8, dst_cap: i32): void {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (dst == 0 as *u8) {
      return;
    }
    if (dst_cap <= 0) {
      return;
    }
    unsafe {
      dst[0] = 0;
    }
    if (module == 0 as *u8) {
      return;
    }
    pipe_imp_soft_sync(module);
    let s: i32 = pipe_imp_find_slot(module);
    if (s < 0) {
      return;
    }
    if (idx < 0) {
      return;
    }
    if (idx >= g_pipe_imp_n[s]) {
      return;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
    if (base == 0 as *u8) {
      return;
    }
    let off: i32 = pipe_imp_entry_off(idx);
    let n: i32 = pipe_load_i32_le(base, off + 256);
    if (n >= dst_cap) {
      n = dst_cap - 1;
    }
    let i: i32 = 0;
    while (i < n) {
      unsafe {
        dst[i] = base[off + i];
      }
      i = i + 1;
    }
    unsafe {
      dst[n] = 0;
    }
  }
}

/**
 * Path byte at off for import idx.
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param off i32 - byte offset in path
 * @return u8 - byte or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_path_byte_at(module: *u8, idx: i32, off: i32): u8 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return 0 as u8;
    }
    if (off < 0) {
      return 0 as u8;
    }
    pipe_imp_soft_sync(module);
    let s: i32 = pipe_imp_find_slot(module);
    if (s < 0) {
      return 0 as u8;
    }
    if (idx < 0) {
      return 0 as u8;
    }
    if (idx >= g_pipe_imp_n[s]) {
      return 0 as u8;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
    if (base == 0 as *u8) {
      return 0 as u8;
    }
    let eoff: i32 = pipe_imp_entry_off(idx);
    let plen: i32 = pipe_load_i32_le(base, eoff + 256);
    if (off >= plen) {
      return 0 as u8;
    }
    if (off >= 256) {
      return 0 as u8;
    }
    let b: u8 = 0;
    unsafe {
      b = base[eoff + off];
    }
    return b;
  }
}

/**
 * Set import kind at idx.
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param kind i32 - kind code
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_set_kind(module: *u8, idx: i32, kind: i32): void {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return;
    }
    pipe_imp_soft_sync(module);
    let s: i32 = pipe_imp_find_slot(module);
    if (s < 0) {
      return;
    }
    if (idx < 0) {
      return;
    }
    if (idx >= g_pipe_imp_n[s]) {
      return;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
    if (base == 0 as *u8) {
      return;
    }
    pipe_store_i32_le(base, pipe_imp_entry_off(idx) + 260, kind);
  }
}

/**
 * Import kind at idx.
 * @param module *u8 - module
 * @param idx i32 - import index
 * @return i32 - kind or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_kind_at(module: *u8, idx: i32): i32 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return 0;
    }
    pipe_imp_soft_sync(module);
    let s: i32 = pipe_imp_find_slot(module);
    if (s < 0) {
      return 0;
    }
    if (idx < 0) {
      return 0;
    }
    if (idx >= g_pipe_imp_n[s]) {
      return 0;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
    if (base == 0 as *u8) {
      return 0;
    }
    return pipe_load_i32_le(base, pipe_imp_entry_off(idx) + 260);
  }
}

/**
 * Set binding name at idx (len 1..64).
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param bytes *u8 - name bytes
 * @param len i32 - length; <=0 or >64 -> no-op
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_set_binding_name(module: *u8, idx: i32, bytes: *u8, len: i32): void {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return;
    }
    if (bytes == 0 as *u8) {
      return;
    }
    if (len <= 0) {
      return;
    }
    if (len > 64) {
      return;
    }
    pipe_imp_soft_sync(module);
    let s: i32 = pipe_imp_find_slot(module);
    if (s < 0) {
      return;
    }
    if (idx < 0) {
      return;
    }
    if (idx >= g_pipe_imp_n[s]) {
      return;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
    if (base == 0 as *u8) {
      return;
    }
    let eoff: i32 = pipe_imp_entry_off(idx);
    let z: i32 = 0;
    while (z < 64) {
      unsafe {
        base[eoff + 264 + z] = 0;
      }
      z = z + 1;
    }
    let i: i32 = 0;
    while (i < len) {
      unsafe {
        base[eoff + 264 + i] = bytes[i];
      }
      i = i + 1;
    }
    pipe_store_i32_le(base, eoff + 520, len);
  }
}

/**
 * Binding name length at idx.
 * @param module *u8 - module
 * @param idx i32 - import index
 * @return i32 - length or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_binding_name_len(module: *u8, idx: i32): i32 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return 0;
    }
    pipe_imp_soft_sync(module);
    let s: i32 = pipe_imp_find_slot(module);
    if (s < 0) {
      return 0;
    }
    if (idx < 0) {
      return 0;
    }
    if (idx >= g_pipe_imp_n[s]) {
      return 0;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
    if (base == 0 as *u8) {
      return 0;
    }
    return pipe_load_i32_le(base, pipe_imp_entry_off(idx) + 520);
  }
}

/**
 * Binding name byte at off.
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param off i32 - offset in binding name
 * @return u8 - byte or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_binding_name_byte_at(module: *u8, idx: i32, off: i32): u8 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return 0 as u8;
    }
    if (off < 0) {
      return 0 as u8;
    }
    if (off >= 64) {
      return 0 as u8;
    }
    pipe_imp_soft_sync(module);
    let s: i32 = pipe_imp_find_slot(module);
    if (s < 0) {
      return 0 as u8;
    }
    if (idx < 0) {
      return 0 as u8;
    }
    if (idx >= g_pipe_imp_n[s]) {
      return 0 as u8;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
    if (base == 0 as *u8) {
      return 0 as u8;
    }
    let eoff: i32 = pipe_imp_entry_off(idx);
    let bl: i32 = pipe_load_i32_le(base, eoff + 520);
    if (off >= bl) {
      return 0 as u8;
    }
    let b: u8 = 0;
    unsafe {
      b = base[eoff + 264 + off];
    }
    return b;
  }
}

/**
 * Set select_count field only (does not grow select pool).
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param n i32 - select count
 * @return void
 * PLATFORM: SHARED - ≡ Cap set_select_count.
 */
#[no_mangle]
export function pipeline_module_import_set_select_count(module: *u8, idx: i32, n: i32): void {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return;
    }
    pipe_imp_soft_sync(module);
    let s: i32 = pipe_imp_find_slot(module);
    if (s < 0) {
      return;
    }
    if (idx < 0) {
      return;
    }
    if (idx >= g_pipe_imp_n[s]) {
      return;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
    if (base == 0 as *u8) {
      return;
    }
    pipe_store_i32_le(base, pipe_imp_entry_off(idx) + 528, n);
  }
}

/**
 * Append one select name row for import idx.
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param bytes *u8 - name bytes
 * @param len i32 - length; capped to 63
 * @return i32 - new select index within import or -1
 * PLATFORM: SHARED - ≡ Cap append_select_name (dynamic grow, no 8-cap).
 */
#[no_mangle]
export function pipeline_module_import_append_select_name(module: *u8, idx: i32, bytes: *u8, len: i32): i32 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return 0 - 1;
    }
    if (bytes == 0 as *u8) {
      return 0 - 1;
    }
    if (len <= 0) {
      return 0 - 1;
    }
    if (idx < 0) {
      return 0 - 1;
    }
    pipe_imp_soft_sync(module);
    let s: i32 = pipe_imp_find_or_create(module);
    if (s < 0) {
      return 0 - 1;
    }
    if (idx >= g_pipe_imp_n[s]) {
      return 0 - 1;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
    if (base == 0 as *u8) {
      return 0 - 1;
    }
    let eoff: i32 = pipe_imp_entry_off(idx);
    let scount: i32 = pipe_load_i32_le(base, eoff + 528);
    if (scount == 0) {
      pipe_store_i32_le(base, eoff + 524, g_pipe_imp_sel_n[s]);
    }
    let vi: i32 = g_pipe_imp_sel_n[s];
    if (pipe_imp_ensure_select(s, vi + 1) == 0) {
      return 0 - 1;
    }
    let rows: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_rows[0], s);
    let lens: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_lens[0], s);
    if (rows == 0 as *u8) {
      return 0 - 1;
    }
    if (lens == 0 as *u8) {
      return 0 - 1;
    }
    let row_off: i32 = vi * 64;
    let z: i32 = 0;
    while (z < 64) {
      unsafe {
        rows[row_off + z] = 0;
      }
      z = z + 1;
    }
    let n: i32 = len;
    if (n > 255) {
      n = 255;
    }
    let i: i32 = 0;
    while (i < n) {
      unsafe {
        rows[row_off + i] = bytes[i];
      }
      i = i + 1;
    }
    pipe_store_i32_le(lens, vi * 4, n);
    g_pipe_imp_sel_n[s] = vi + 1;
    pipe_store_i32_le(base, eoff + 528, scount + 1);
    return scount;
  }
}

/**
 * select_count at import idx.
 * @param module *u8 - module
 * @param idx i32 - import index
 * @return i32 - count or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_select_count_at(module: *u8, idx: i32): i32 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return 0;
    }
    pipe_imp_soft_sync(module);
    let s: i32 = pipe_imp_find_slot(module);
    if (s < 0) {
      return 0;
    }
    if (idx < 0) {
      return 0;
    }
    if (idx >= g_pipe_imp_n[s]) {
      return 0;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
    if (base == 0 as *u8) {
      return 0;
    }
    return pipe_load_i32_le(base, pipe_imp_entry_off(idx) + 528);
  }
}

/**
 * Set or grow-to select name at (idx, sel).
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param sel i32 - select index within import
 * @param bytes *u8 - name bytes
 * @param len i32 - length
 * @return void
 * PLATFORM: SHARED - ≡ Cap set_select_name (append until sel reachable).
 */
#[no_mangle]
export function pipeline_module_import_set_select_name(module: *u8, idx: i32, sel: i32, bytes: *u8, len: i32): void {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return;
    }
    if (bytes == 0 as *u8) {
      return;
    }
    if (len <= 0) {
      return;
    }
    if (sel < 0) {
      return;
    }
    pipe_imp_soft_sync(module);
    let s: i32 = pipe_imp_find_or_create(module);
    if (s < 0) {
      return;
    }
    if (idx < 0) {
      return;
    }
    if (idx >= g_pipe_imp_n[s]) {
      return;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
    if (base == 0 as *u8) {
      return;
    }
    let eoff: i32 = pipe_imp_entry_off(idx);
    while (1 == 1) {
      let scount: i32 = pipe_load_i32_le(base, eoff + 528);
      if (scount > sel) {
        break;
      }
      let ap: i32 = pipeline_module_import_append_select_name(module, idx, bytes, len);
      if (ap < 0) {
        return;
      }
      // Cap: if sel < scount-1 after append return - only last append fills target.
      scount = pipe_load_i32_le(base, eoff + 528);
      if (sel < scount - 1) {
        return;
      }
    }
    let sbase: i32 = pipe_load_i32_le(base, eoff + 524);
    let abs: i32 = sbase + sel;
    let rows: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_rows[0], s);
    let lens: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_lens[0], s);
    if (rows == 0 as *u8) {
      return;
    }
    if (lens == 0 as *u8) {
      return;
    }
    if (abs < 0) {
      return;
    }
    if (abs >= g_pipe_imp_sel_n[s]) {
      return;
    }
    let row_off: i32 = abs * 64;
    let z: i32 = 0;
    while (z < 64) {
      unsafe {
        rows[row_off + z] = 0;
      }
      z = z + 1;
    }
    let n: i32 = len;
    if (n > 255) {
      n = 255;
    }
    let i: i32 = 0;
    while (i < n) {
      unsafe {
        rows[row_off + i] = bytes[i];
      }
      i = i + 1;
    }
    pipe_store_i32_le(lens, abs * 4, n);
  }
}

/**
 * Select name length at (idx, sel).
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param sel i32 - select index
 * @return i32 - length or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_select_name_len(module: *u8, idx: i32, sel: i32): i32 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return 0;
    }
    if (sel < 0) {
      return 0;
    }
    pipe_imp_soft_sync(module);
    let s: i32 = pipe_imp_find_slot(module);
    if (s < 0) {
      return 0;
    }
    if (idx < 0) {
      return 0;
    }
    if (idx >= g_pipe_imp_n[s]) {
      return 0;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
    if (base == 0 as *u8) {
      return 0;
    }
    let eoff: i32 = pipe_imp_entry_off(idx);
    let scount: i32 = pipe_load_i32_le(base, eoff + 528);
    if (sel >= scount) {
      return 0;
    }
    let sbase: i32 = pipe_load_i32_le(base, eoff + 524);
    let abs: i32 = sbase + sel;
    if (abs < 0) {
      return 0;
    }
    if (abs >= g_pipe_imp_sel_n[s]) {
      return 0;
    }
    let lens: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_lens[0], s);
    if (lens == 0 as *u8) {
      return 0;
    }
    return pipe_load_i32_le(lens, abs * 4);
  }
}

/**
 * Select name byte at (idx, sel, off).
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param sel i32 - select index
 * @param off i32 - byte offset
 * @return u8 - byte or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_select_name_byte_at(module: *u8, idx: i32, sel: i32, off: i32): u8 {
  // wave377: Cap-T001 whole-body unsafe (PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == 0 as *u8) {
      return 0 as u8;
    }
    if (sel < 0) {
      return 0 as u8;
    }
    if (off < 0) {
      return 0 as u8;
    }
    pipe_imp_soft_sync(module);
    let s: i32 = pipe_imp_find_slot(module);
    if (s < 0) {
      return 0 as u8;
    }
    if (idx < 0) {
      return 0 as u8;
    }
    if (idx >= g_pipe_imp_n[s]) {
      return 0 as u8;
    }
    let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
    if (base == 0 as *u8) {
      return 0 as u8;
    }
    let eoff: i32 = pipe_imp_entry_off(idx);
    let scount: i32 = pipe_load_i32_le(base, eoff + 528);
    if (sel >= scount) {
      return 0 as u8;
    }
    let sbase: i32 = pipe_load_i32_le(base, eoff + 524);
    let abs: i32 = sbase + sel;
    if (abs < 0) {
      return 0 as u8;
    }
    if (abs >= g_pipe_imp_sel_n[s]) {
      return 0 as u8;
    }
    let nlen: i32 = pipeline_module_import_select_name_len(module, idx, sel);
    if (off >= nlen) {
      return 0 as u8;
    }
    if (off >= 64) {
      return 0 as u8;
    }
    let rows: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_rows[0], s);
    if (rows == 0 as *u8) {
      return 0 as u8;
    }
    let b: u8 = 0;
    unsafe {
      b = rows[abs * 64 + off];
    }
    return b;
  }
}
