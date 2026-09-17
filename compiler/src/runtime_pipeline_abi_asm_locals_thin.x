// Thin pure: wave304 M2 — asm_locals Cap residual C→.x (was wave267 C thin).
// AsmLocalSlotEntry LE 264B + AsmBlockSlot tables; 64-slot ctx maps; 12 faces.
// G.7: bodies match runtime_pipeline_abi.x wave267 leave.
// PRODUCT inject: -E+$CC via pipeline_abi_inject_asm_locals_thin
// (ALLOW_E_REPLACE + stamp). File-local maps OK under -E+$CC.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function xlang_ptr_slot_get(arr: *u8, i: i32): *u8;
export extern function xlang_ptr_slot_set(arr: *u8, i: i32, p: *u8): void;
export extern "C" function malloc(n: usize): *u8;
export extern "C" function free(p: *u8): void;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;

let g_pipe_al_ctx: u8[512] = [];
let g_pipe_al_used: i32[64] = [];
let g_pipe_al_n: i32[64] = [];
let g_pipe_al_cap: i32[64] = [];
let g_pipe_al_slots: u8[512] = [];
let g_pipe_al_bn: i32[64] = [];
let g_pipe_al_bcap: i32[64] = [];
let g_pipe_al_brefs: u8[512] = [];
let g_pipe_al_bbases: u8[512] = [];

/**
 * Byte size of one pure AsmLocalSlotEntry.
 * @return i32 - 264
 * PLATFORM: SHARED LP64 - must match C sizeof(AsmLocalSlotEntry).
 */
function pipe_al_entry_size(): i32 {
  return 264;
}

/**
 * Max concurrent AsmFuncCtx sidecars (historical MAX_ASM_LOCALS_SIDECARS).
 * @return i32 - 64
 */
function pipe_al_max_slots(): i32 {
  return 64;
}

/**
 * Offsets within local entry.
 */
function pipe_al_off_name_len(): i32 { return 256; }
function pipe_al_off_offset(): i32 { return 260; }

/**
 * Find map slot for AsmFuncCtx key (create optional).
 * @param ctx *u8 - AsmFuncCtx*; null -> -1
 * @param create i32 - non-zero allocates free slot
 * @return i32 - slot 0..63 or -1
 * PLATFORM: SHARED - sole product map authority after asm_locals leave.
 */
function pipe_al_find(ctx: *u8, create: i32): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  let i: i32 = 0;
  while (i < 64) {
    if (g_pipe_al_used[i] != 0) {
      let k: *u8 = xlang_ptr_slot_get(&g_pipe_al_ctx[0], i);
      if (k == ctx) {
        return i;
      }
    }
    i = i + 1;
  }
  if (create == 0) {
    return 0 - 1;
  }
  i = 0;
  while (i < 64) {
    if (g_pipe_al_used[i] == 0) {
      g_pipe_al_used[i] = 1;
      xlang_ptr_slot_set(&g_pipe_al_ctx[0], i, ctx);
      g_pipe_al_n[i] = 0;
      g_pipe_al_cap[i] = 0;
      xlang_ptr_slot_set(&g_pipe_al_slots[0], i, 0 as *u8);
      g_pipe_al_bn[i] = 0;
      g_pipe_al_bcap[i] = 0;
      xlang_ptr_slot_set(&g_pipe_al_brefs[0], i, 0 as *u8);
      xlang_ptr_slot_set(&g_pipe_al_bbases[0], i, 0 as *u8);
      return i;
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Ensure local-entry table capacity >= need for slot.
 * @param slot i32 - map slot
 * @param need i32 - required capacity
 * @return i32 - 1 ok, 0 fail
 */
function pipe_al_ensure_slots(slot: i32, need: i32): i32 {
  if (slot < 0) {
    return 0;
  }
  if (slot >= 64) {
    return 0;
  }
  if (need <= 0) {
    return 1;
  }
  let cap: i32 = g_pipe_al_cap[slot];
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
  let esz: i32 = pipe_al_entry_size();
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
  let old: *u8 = xlang_ptr_slot_get(&g_pipe_al_slots[0], slot);
  let old_n: i32 = g_pipe_al_n[slot];
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
  xlang_ptr_slot_set(&g_pipe_al_slots[0], slot, np);
  g_pipe_al_cap[slot] = new_cap;
  return 1;
}

/**
 * Ensure block_ref / slot_base parallel tables capacity >= need.
 * @param slot i32 - map slot
 * @param need i32 - required capacity
 * @return i32 - 1 ok, 0 fail
 */
function pipe_al_ensure_blocks(slot: i32, need: i32): i32 {
  if (slot < 0) {
    return 0;
  }
  if (slot >= 64) {
    return 0;
  }
  if (need <= 0) {
    return 1;
  }
  let cap: i32 = g_pipe_al_bcap[slot];
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
  let nbytes: usize = (new_cap * 4) as usize;
  let nr: *u8 = 0 as *u8;
  let nb: *u8 = 0 as *u8;
  unsafe {
    nr = malloc(nbytes);
    nb = malloc(nbytes);
  }
  if (nr == 0 as *u8 || nb == 0 as *u8) {
    if (nr != 0 as *u8) {
      unsafe { free(nr); }
    }
    if (nb != 0 as *u8) {
      unsafe { free(nb); }
    }
    return 0;
  }
  unsafe {
    memset(nr, 0, nbytes);
    memset(nb, 0, nbytes);
  }
  let old_r: *u8 = xlang_ptr_slot_get(&g_pipe_al_brefs[0], slot);
  let old_b: *u8 = xlang_ptr_slot_get(&g_pipe_al_bbases[0], slot);
  let old_n: i32 = g_pipe_al_bn[slot];
  if (old_n > 0) {
    let copy_n: usize = (old_n * 4) as usize;
    if (old_r != 0 as *u8) {
      unsafe { memcpy(nr, old_r, copy_n); }
    }
    if (old_b != 0 as *u8) {
      unsafe { memcpy(nb, old_b, copy_n); }
    }
  }
  if (old_r != 0 as *u8) {
    unsafe { free(old_r); }
  }
  if (old_b != 0 as *u8) {
    unsafe { free(old_b); }
  }
  xlang_ptr_slot_set(&g_pipe_al_brefs[0], slot, nr);
  xlang_ptr_slot_set(&g_pipe_al_bbases[0], slot, nb);
  g_pipe_al_bcap[slot] = new_cap;
  return 1;
}

/**
 * Pointer to local entry at idx (null if OOB).
 * @param slot i32 - map slot
 * @param idx i32 - entry index
 * @return *u8 - entry base or null
 */
function pipe_al_at(slot: i32, idx: i32): *u8 {
  if (slot < 0 || slot >= 64) {
    return 0 as *u8;
  }
  if (idx < 0 || idx >= g_pipe_al_n[slot]) {
    return 0 as *u8;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_al_slots[0], slot);
  if (base == 0 as *u8) {
    return 0 as *u8;
  }
  return base + (idx * pipe_al_entry_size());
}

/**
 * Clear block_ref -> slot_base table for one AsmFuncCtx (keep slot occupied).
 * @param ctx *u8 - AsmFuncCtx* key; null / unknown -> no-op
 * @return void
 * wave267 pure: G.7 single product authority (historical asm_ctx_block_slot_reset).
 * PLATFORM: SHARED - sole provider after asm_locals leave.
 */
#[no_mangle]
export function asm_ctx_block_slot_reset(ctx: *u8): void {
  let s: i32 = pipe_al_find(ctx, 0);
  if (s < 0) {
    return;
  }
  g_pipe_al_bn[s] = 0;
}

/**
 * Clear local slot grow pool and block_slot table for one AsmFuncCtx.
 * @param ctx *u8 - AsmFuncCtx* key; null / unknown -> no-op
 * @return void
 * wave267 pure: G.7 single product authority (historical asm_ctx_local_reset).
 * PLATFORM: SHARED - also clears block_slot to avoid cross-func block_ref collision.
 */
#[no_mangle]
export function asm_ctx_local_reset(ctx: *u8): void {
  let s: i32 = pipe_al_find(ctx, 0);
  if (s < 0) {
    return;
  }
  g_pipe_al_n[s] = 0;
  g_pipe_al_bn[s] = 0;
}

/**
 * Local slot count for ctx (0 if unknown/null).
 * @param ctx *u8 - AsmFuncCtx* key
 * @return i32 - live local count
 * wave267 pure: G.7 single product authority (historical asm_ctx_local_count).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_ctx_local_count(ctx: *u8): i32 {
  let s: i32 = pipe_al_find(ctx, 0);
  if (s < 0) {
    return 0;
  }
  return g_pipe_al_n[s];
}

/**
 * Append one local slot (name + stack offset); returns index or -1.
 * @param ctx *u8 - AsmFuncCtx* key; null -> -1
 * @param name *u8 - local name bytes; null -> -1
 * @param name_len i32 - full name length stored; bytes clamped to 127 into name[128]
 * @param offset i32 - stack offset (typically negative from rbp)
 * @return i32 - new index >=0, or -1 on fail
 * wave267 pure: G.7 single product authority (historical asm_ctx_local_append).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_ctx_local_append(ctx: *u8, name: *u8, name_len: i32, offset: i32): i32 {
  if (ctx == 0 as *u8 || name == 0 as *u8 || name_len <= 0) {
    return 0 - 1;
  }
  let s: i32 = pipe_al_find(ctx, 1);
  if (s < 0) {
    return 0 - 1;
  }
  let idx: i32 = g_pipe_al_n[s];
  if (pipe_al_ensure_slots(s, idx + 1) == 0) {
    return 0 - 1;
  }
  let ent: *u8 = xlang_ptr_slot_get(&g_pipe_al_slots[0], s);
  if (ent == 0 as *u8) {
    return 0 - 1;
  }
  let base: *u8 = ent + (idx * pipe_al_entry_size());
  unsafe {
    memset(base, 0, pipe_al_entry_size() as usize);
  }
  let n: i32 = name_len;
  if (n > 255) {
    n = 255;
  }
  let k: i32 = 0;
  while (k < n) {
    unsafe {
      base[k] = name[k];
    }
    k = k + 1;
  }
  pipe_store_i32_le(base, pipe_al_off_name_len(), name_len);
  pipe_store_i32_le(base, pipe_al_off_offset(), offset);
  g_pipe_al_n[s] = idx + 1;
  return idx;
}

/**
 * Name length of local slot idx (0 if OOB).
 * @param ctx *u8 - AsmFuncCtx* key
 * @param idx i32 - local index
 * @return i32 - stored name_len (may exceed 255 if historical clamp only on bytes)
 * wave267 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_ctx_local_name_len(ctx: *u8, idx: i32): i32 {
  let s: i32 = pipe_al_find(ctx, 0);
  if (s < 0) {
    return 0;
  }
  let ent: *u8 = pipe_al_at(s, idx);
  if (ent == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(ent, pipe_al_off_name_len());
}

/**
 * One name byte at off for local idx (0 if OOB).
 * @param ctx *u8 - AsmFuncCtx* key
 * @param idx i32 - local index
 * @param off i32 - byte offset into name
 * @return u8 - name byte or 0
 * wave267 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_ctx_local_name_byte_at(ctx: *u8, idx: i32, off: i32): u8 {
  if (off < 0) {
    return 0 as u8;
  }
  let s: i32 = pipe_al_find(ctx, 0);
  if (s < 0) {
    return 0 as u8;
  }
  let ent: *u8 = pipe_al_at(s, idx);
  if (ent == 0 as *u8) {
    return 0 as u8;
  }
  let nlen: i32 = pipe_load_i32_le(ent, pipe_al_off_name_len());
  if (off >= nlen) {
    return 0 as u8;
  }
  // Bytes only stored up to 127; beyond is zero from memset.
  if (off >= 127) {
    return 0 as u8;
  }
  let b: u8 = 0 as u8;
  unsafe {
    b = ent[off];
  }
  return b;
}

/**
 * Copy local name into dst (128 bytes, zero-padded). Historical ABI *copy64 name.
 * @param ctx *u8 - AsmFuncCtx* key
 * @param idx i32 - local index
 * @param dst *u8 - destination; null -> no-op; writes 128 bytes
 * @return void
 * wave267 pure: G.7 single product authority (wave581: name[128] surface).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_ctx_local_name_copy64(ctx: *u8, idx: i32, dst: *u8): void {
  if (dst == 0 as *u8) {
    return;
  }
  unsafe {
    memset(dst, 0, 256 as usize);
  }
  let s: i32 = pipe_al_find(ctx, 0);
  if (s < 0) {
    return;
  }
  let ent: *u8 = pipe_al_at(s, idx);
  if (ent == 0 as *u8) {
    return;
  }
  let nlen: i32 = pipe_load_i32_le(ent, pipe_al_off_name_len());
  let n: i32 = nlen;
  if (n > 255) {
    n = 255;
  }
  let k: i32 = 0;
  while (k < n) {
    unsafe {
      dst[k] = ent[k];
    }
    k = k + 1;
  }
}

/**
 * Stack offset of local idx (0 if OOB).
 * @param ctx *u8 - AsmFuncCtx* key
 * @param idx i32 - local index
 * @return i32 - offset
 * wave267 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_ctx_local_offset_at(ctx: *u8, idx: i32): i32 {
  let s: i32 = pipe_al_find(ctx, 0);
  if (s < 0) {
    return 0;
  }
  let ent: *u8 = pipe_al_at(s, idx);
  if (ent == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(ent, pipe_al_off_offset());
}

/**
 * Search locals back-to-front for name; return stack offset or -1.
 * @param ctx *u8 - AsmFuncCtx* key; null -> -1
 * @param name *u8 - name bytes; null -> -1
 * @param name_len i32 - exact length match required
 * @return i32 - offset or -1
 * wave267 pure: G.7 single product authority (historical asm_ctx_local_find_offset).
 * PLATFORM: SHARED - inner block same-name shadows outer (scan from end).
 */
#[no_mangle]
export function asm_ctx_local_find_offset(ctx: *u8, name: *u8, name_len: i32): i32 {
  if (ctx == 0 as *u8 || name == 0 as *u8 || name_len <= 0) {
    return 0 - 1;
  }
  let s: i32 = pipe_al_find(ctx, 0);
  if (s < 0) {
    return 0 - 1;
  }
  let i: i32 = g_pipe_al_n[s] - 1;
  while (i >= 0) {
    let ent: *u8 = pipe_al_at(s, i);
    if (ent != 0 as *u8) {
      let elen: i32 = pipe_load_i32_le(ent, pipe_al_off_name_len());
      if (elen == name_len) {
        let k: i32 = 0;
        let ok: i32 = 1;
        while (k < name_len) {
          // Compare against stored bytes (clamp 255); beyond clamp must be zero names only if name_len>255 rare.
          let eb: u8 = 0 as u8;
          if (k < 127) {
            unsafe { eb = ent[k]; }
          }
          let nb: u8 = 0 as u8;
          unsafe { nb = name[k]; }
          if (eb != nb) {
            ok = 0;
            break;
          }
          k = k + 1;
        }
        if (ok != 0) {
          return pipe_load_i32_le(ent, pipe_al_off_offset());
        }
      }
    }
    i = i - 1;
  }
  return 0 - 1;
}

/**
 * backend.x local_offset C face: exact name match, then zero-name fallback (<=32).
 * @param ctx *u8 - AsmFuncCtx* (backend_AsmFuncCtx*)
 * @param name *u8 - name bytes
 * @param name_len i32 - name length
 * @return i32 - offset or -1
 * wave267 pure: G.7 single product authority (historical pipeline_asm_local_offset_c).
 * PLATFORM: SHARED - M8-tail thin wrapper bl target.
 */
#[no_mangle]
export function pipeline_asm_local_offset_c(ctx: *u8, name: *u8, name_len: i32): i32 {
  if (ctx == 0 as *u8 || name == 0 as *u8 || name_len <= 0) {
    return 0 - 1;
  }
  let nloc: i32 = asm_ctx_local_count(ctx);
  let i: i32 = 0;
  while (i < nloc) {
    if (asm_ctx_local_name_len(ctx, i) == name_len) {
      let eq: i32 = 1;
      let k: i32 = 0;
      while (k < name_len) {
        if (name[k] != asm_ctx_local_name_byte_at(ctx, i, k)) {
          eq = 0;
          break;
        }
        k = k + 1;
      }
      if (eq != 0) {
        return asm_ctx_local_offset_at(ctx, i);
      }
    }
    i = i + 1;
  }
  // Self-host tear path: name_len<=32 and sidecar slot name is all zeros still match.
  if (name_len > 0 && name_len <= 32) {
    let j: i32 = 0;
    while (j < nloc) {
      if (asm_ctx_local_name_len(ctx, j) == name_len) {
        let all_zero: i32 = 1;
        let k2: i32 = 0;
        while (k2 < name_len) {
          if (asm_ctx_local_name_byte_at(ctx, j, k2) != (0 as u8)) {
            all_zero = 0;
            break;
          }
          k2 = k2 + 1;
        }
        if (all_zero != 0) {
          return asm_ctx_local_offset_at(ctx, j);
        }
      }
      j = j + 1;
    }
  }
  return 0 - 1;
}

/**
 * Record block_ref starting local index (fill before ensure_block_locals).
 * @param ctx *u8 - AsmFuncCtx* key; null -> no-op
 * @param block_ref i32 - block ref; <=0 ignored
 * @param slot_base i32 - starting local index for this block
 * @return void
 * wave267 pure: G.7 single product authority (historical asm_ctx_block_slot_set).
 * PLATFORM: SHARED - append-only; get scans from end for latest.
 */
#[no_mangle]
export function asm_ctx_block_slot_set(ctx: *u8, block_ref: i32, slot_base: i32): void {
  if (ctx == 0 as *u8 || block_ref <= 0) {
    return;
  }
  let s: i32 = pipe_al_find(ctx, 1);
  if (s < 0) {
    return;
  }
  let idx: i32 = g_pipe_al_bn[s];
  if (pipe_al_ensure_blocks(s, idx + 1) == 0) {
    return;
  }
  let pr: *u8 = xlang_ptr_slot_get(&g_pipe_al_brefs[0], s);
  let pb: *u8 = xlang_ptr_slot_get(&g_pipe_al_bbases[0], s);
  if (pr == 0 as *u8 || pb == 0 as *u8) {
    return;
  }
  pipe_store_i32_le(pr, idx * 4, block_ref);
  pipe_store_i32_le(pb, idx * 4, slot_base);
  g_pipe_al_bn[s] = idx + 1;
}

/**
 * Lookup block_ref starting local index; -1 if unregistered.
 * @param ctx *u8 - AsmFuncCtx* key; null -> -1
 * @param block_ref i32 - block ref; <=0 -> -1
 * @return i32 - slot_base or -1
 * wave267 pure: G.7 single product authority (historical asm_ctx_block_slot_get).
 * PLATFORM: SHARED - scan from end (latest registration wins).
 */
#[no_mangle]
export function asm_ctx_block_slot_get(ctx: *u8, block_ref: i32): i32 {
  if (ctx == 0 as *u8 || block_ref <= 0) {
    return 0 - 1;
  }
  let s: i32 = pipe_al_find(ctx, 0);
  if (s < 0) {
    return 0 - 1;
  }
  let i: i32 = g_pipe_al_bn[s] - 1;
  let pr: *u8 = xlang_ptr_slot_get(&g_pipe_al_brefs[0], s);
  let pb: *u8 = xlang_ptr_slot_get(&g_pipe_al_bbases[0], s);
  if (pr == 0 as *u8 || pb == 0 as *u8) {
    return 0 - 1;
  }
  while (i >= 0) {
    let br: i32 = pipe_load_i32_le(pr, i * 4);
    if (br == block_ref) {
      return pipe_load_i32_le(pb, i * 4);
    }
    i = i - 1;
  }
  return 0 - 1;
}

