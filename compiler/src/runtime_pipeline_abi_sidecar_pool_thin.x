// Thin pure: wave308/366 M2 — sidecar_pool Cap residual C→.x (was wave275 C thin).
// Arena/Module/OneFunc sidecar BSS tables + get/free; 6 exports.
// G.7: bodies match runtime_pipeline_abi.x wave275 leave.
// PRODUCT inject: pipeline_abi_inject_sidecar_pool_thin (ALLOW_E_REPLACE + stamp).
// wave366: w308_* helpers via unsafe (T001); PREFER try + L2 gate.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function grow_vec_free(v: *u8): void;
export extern function grow_vec_init(v: *u8, elem_sz: i64, initial_cap: i32): i32;
export extern function pipe_gv_init_cap(): i32;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;


/**
 * LE i32 load via unsafe (T001). PLATFORM: SHARED.
 * wave366: wrap pipe_load_i32_le for PREFER_ASM pure-asm leave.
 */
function w308_load(base: *u8, off: i32): i32 {
  unsafe {
    return pipe_load_i32_le(base, off);
  }
}

/**
 * LE i32 store via unsafe (T001). PLATFORM: SHARED.
 * wave366: wrap pipe_store_i32_le for PREFER_ASM pure-asm leave.
 */
function w308_store(base: *u8, off: i32, v: i32): void {
  unsafe {
    pipe_store_i32_le(base, off, v);
  }
}

/**
 * Ptr-slot load via unsafe (T001). PLATFORM: SHARED.
 */
function w308_load_ptr(base: *u8, i: i32): *u8 {
  unsafe {
    return pipe_load_ptr_slot(base, i);
  }
}

/**
 * Ptr-slot store via unsafe (T001). PLATFORM: SHARED.
 */
function w308_store_ptr(base: *u8, i: i32, val: *u8): void {
  unsafe {
    pipe_store_ptr_slot(base, i, val);
  }
}

/**
 * grow_vec_init via unsafe (T001). PLATFORM: SHARED.
 */
function w308_gv_init(v: *u8, elem_sz: i64, initial_cap: i32): i32 {
  unsafe {
    return grow_vec_init(v, elem_sz, initial_cap);
  }
}

/**
 * grow_vec_free via unsafe (T001). PLATFORM: SHARED.
 */
function w308_gv_free(v: *u8): void {
  unsafe {
    grow_vec_free(v);
  }
}

/**
 * pipe_gv_init_cap via unsafe (T001). PLATFORM: SHARED.
 */
function w308_gv_init_cap(): i32 {
  unsafe {
    return pipe_gv_init_cap();
  }
}

/**
 * memset via unsafe (T001). PLATFORM: SHARED.
 */
function w308_memset(dst: *u8, c: i32, n: usize): *u8 {
  unsafe {
    return memset(dst, c, n);
  }
}

function pipe_arena_sc_size(): i32 { return 816; }
function pipe_arena_sc_max(): i32 { return 512; }
function pipe_module_sc_size(): i32 { return 432; }
function pipe_module_sc_max(): i32 { return 512; }
function pipe_onefunc_sc_size(): i32 { return 944; }
function pipe_onefunc_sc_max(): i32 { return 1024; }

// Flat BSS tables (zero-init; used flags start 0).
let g_pipe_arena_sc_blob: u8[417792] = [];
let g_pipe_module_sc_blob: u8[221184] = [];
let g_pipe_onefunc_sc_blob: u8[966656] = [];
// Arena/module: 2-slot MRU (copy src/dst ping-pong). Onefunc: 16-slot ring
// + used_hi (dummy-wire live keys). Miss walk for onefunc stops at used_hi.
// PLATFORM: SHARED — Darwin/Linux product thin; leftover-PE seed twin matches.
let g_pipe_arena_sc_last_key0: *u8 = 0 as *u8;
let g_pipe_arena_sc_last_sc0: *u8 = 0 as *u8;
let g_pipe_arena_sc_last_key1: *u8 = 0 as *u8;
let g_pipe_arena_sc_last_sc1: *u8 = 0 as *u8;
let g_pipe_module_sc_last_key0: *u8 = 0 as *u8;
let g_pipe_module_sc_last_sc0: *u8 = 0 as *u8;
let g_pipe_module_sc_last_key1: *u8 = 0 as *u8;
let g_pipe_module_sc_last_sc1: *u8 = 0 as *u8;
// Onefunc 16-slot ring: slot i stores key at ptr-index 2*i and sidecar at 2*i+1
// (LP64 8-byte cells; 16*(key+sc) = 256 bytes). Clock is next insert index.
// used_hi is exclusive end of occupied process-table slots (0..MAX).
// PLATFORM: SHARED — Darwin/Linux product thin; leftover-PE seed twin matches.
let g_pipe_onefunc_mru_blob: u8[256] = [];
let g_pipe_onefunc_mru_clock: i32 = 0;
let g_pipe_onefunc_sc_used_hi: i32 = 0;

/**
 * True if sidecar slot is used and its key pointer equals `key`.
 * @param sc *u8 — sidecar base; null -> 0
 * @param key *u8 — lookup key
 * @return i32 — 1 ok, 0 miss
 * PLATFORM: SHARED — 2-slot MRU helper for sidecar_get.
 */
function pipe_sc_last_slot_ok(sc: *u8, key: *u8): i32 {
  if (sc == 0 as *u8) {
    return 0;
  }
  if (w308_load(sc, 8) == 0) {
    return 0;
  }
  if (w308_load_ptr(sc, 0) != key) {
    return 0;
  }
  return 1;
}

/**
 * 2-slot MRU lookup for the arena sidecar table.
 * @param key *u8 — arena pointer key
 * @return *u8 — cached sidecar or null
 */
function pipe_arena_sc_recall(key: *u8): *u8 {
  if (g_pipe_arena_sc_last_key0 == key) {
    if (pipe_sc_last_slot_ok(g_pipe_arena_sc_last_sc0, key) != 0) {
      return g_pipe_arena_sc_last_sc0;
    }
  }
  if (g_pipe_arena_sc_last_key1 == key) {
    if (pipe_sc_last_slot_ok(g_pipe_arena_sc_last_sc1, key) != 0) {
      return g_pipe_arena_sc_last_sc1;
    }
  }
  return 0 as *u8;
}

/**
 * Remember arena sidecar as MRU slot 0; previous slot 0 shifts to 1.
 * @param key *u8 — arena pointer key
 * @param sc *u8 — sidecar base
 */
function pipe_arena_sc_remember(key: *u8, sc: *u8): void {
  if (g_pipe_arena_sc_last_key0 == key) {
    g_pipe_arena_sc_last_sc0 = sc;
    return;
  }
  g_pipe_arena_sc_last_key1 = g_pipe_arena_sc_last_key0;
  g_pipe_arena_sc_last_sc1 = g_pipe_arena_sc_last_sc0;
  g_pipe_arena_sc_last_key0 = key;
  g_pipe_arena_sc_last_sc0 = sc;
}

/**
 * Drop arena last-hit slots that point at `sc` (called from free).
 * @param sc *u8 — sidecar being freed
 */
function pipe_arena_sc_drop_last(sc: *u8): void {
  if (g_pipe_arena_sc_last_sc0 == sc) {
    g_pipe_arena_sc_last_key0 = 0 as *u8;
    g_pipe_arena_sc_last_sc0 = 0 as *u8;
  }
  if (g_pipe_arena_sc_last_sc1 == sc) {
    g_pipe_arena_sc_last_key1 = 0 as *u8;
    g_pipe_arena_sc_last_sc1 = 0 as *u8;
  }
}

/**
 * 2-slot MRU lookup for the module sidecar table.
 * @param key *u8 — module pointer key
 * @return *u8 — cached sidecar or null
 */
function pipe_module_sc_recall(key: *u8): *u8 {
  if (g_pipe_module_sc_last_key0 == key) {
    if (pipe_sc_last_slot_ok(g_pipe_module_sc_last_sc0, key) != 0) {
      return g_pipe_module_sc_last_sc0;
    }
  }
  if (g_pipe_module_sc_last_key1 == key) {
    if (pipe_sc_last_slot_ok(g_pipe_module_sc_last_sc1, key) != 0) {
      return g_pipe_module_sc_last_sc1;
    }
  }
  return 0 as *u8;
}

/**
 * Remember module sidecar as MRU slot 0; previous slot 0 shifts to 1.
 * @param key *u8 — module pointer key
 * @param sc *u8 — sidecar base
 */
function pipe_module_sc_remember(key: *u8, sc: *u8): void {
  if (g_pipe_module_sc_last_key0 == key) {
    g_pipe_module_sc_last_sc0 = sc;
    return;
  }
  g_pipe_module_sc_last_key1 = g_pipe_module_sc_last_key0;
  g_pipe_module_sc_last_sc1 = g_pipe_module_sc_last_sc0;
  g_pipe_module_sc_last_key0 = key;
  g_pipe_module_sc_last_sc0 = sc;
}

/**
 * Drop module last-hit slots that point at `sc` (called from free).
 * @param sc *u8 — sidecar being freed
 */
function pipe_module_sc_drop_last(sc: *u8): void {
  if (g_pipe_module_sc_last_sc0 == sc) {
    g_pipe_module_sc_last_key0 = 0 as *u8;
    g_pipe_module_sc_last_sc0 = 0 as *u8;
  }
  if (g_pipe_module_sc_last_sc1 == sc) {
    g_pipe_module_sc_last_key1 = 0 as *u8;
    g_pipe_module_sc_last_sc1 = 0 as *u8;
  }
}

/**
 * Onefunc ring capacity (covers dummy-wire live keys without MAX walk).
 * @return i32 — 16
 */
function pipe_onefunc_mru_n(): i32 {
  return 16;
}

/**
 * 16-slot ring lookup for the onefunc sidecar table.
 * @param key *u8 — onefunc pointer key
 * @return *u8 — cached sidecar or null
 */
function pipe_onefunc_sc_recall(key: *u8): *u8 {
  let n: i32 = pipe_onefunc_mru_n();
  let i: i32 = 0;
  let blob: *u8 = 0 as *u8;
  unsafe {
    blob = &g_pipe_onefunc_mru_blob[0];
  }
  while (i < n) {
    let k: *u8 = w308_load_ptr(blob, i * 2);
    if (k == key) {
      let sc: *u8 = w308_load_ptr(blob, i * 2 + 1);
      if (pipe_sc_last_slot_ok(sc, key) != 0) {
        return sc;
      }
    }
    i = i + 1;
  }
  return 0 as *u8;
}

/**
 * Remember onefunc sidecar in the 16-slot ring (update in place, else clock insert).
 * @param key *u8 — onefunc pointer key
 * @param sc *u8 — sidecar base
 */
function pipe_onefunc_sc_remember(key: *u8, sc: *u8): void {
  let n: i32 = pipe_onefunc_mru_n();
  let i: i32 = 0;
  let blob: *u8 = 0 as *u8;
  let slot: i32 = 0;
  unsafe {
    blob = &g_pipe_onefunc_mru_blob[0];
  }
  while (i < n) {
    let k: *u8 = w308_load_ptr(blob, i * 2);
    if (k == key) {
      w308_store_ptr(blob, i * 2 + 1, sc);
      return;
    }
    i = i + 1;
  }
  slot = g_pipe_onefunc_mru_clock;
  if (slot < 0) {
    slot = 0;
  }
  if (slot >= n) {
    slot = 0;
  }
  w308_store_ptr(blob, slot * 2, key);
  w308_store_ptr(blob, slot * 2 + 1, sc);
  slot = slot + 1;
  if (slot >= n) {
    slot = 0;
  }
  g_pipe_onefunc_mru_clock = slot;
}

/**
 * Drop onefunc ring slots that point at `sc` (called from free).
 * @param sc *u8 — sidecar being freed
 */
function pipe_onefunc_sc_drop_last(sc: *u8): void {
  let n: i32 = pipe_onefunc_mru_n();
  let i: i32 = 0;
  let blob: *u8 = 0 as *u8;
  unsafe {
    blob = &g_pipe_onefunc_mru_blob[0];
  }
  while (i < n) {
    let s: *u8 = w308_load_ptr(blob, i * 2 + 1);
    if (s == sc) {
      w308_store_ptr(blob, i * 2, 0 as *u8);
      w308_store_ptr(blob, i * 2 + 1, 0 as *u8);
    }
    i = i + 1;
  }
}

/**
 * Exclusive end of occupied onefunc process-table slots (0..MAX).
 * @return i32 — used_hi clamped to [0, MAX]
 */
function pipe_onefunc_sc_used_lim(): i32 {
  let lim: i32 = g_pipe_onefunc_sc_used_hi;
  let mx: i32 = pipe_onefunc_sc_max();
  if (lim < 0) {
    return 0;
  }
  if (lim > mx) {
    return mx;
  }
  return lim;
}

/**
 * Pointer to ArenaSidecar slot i (0..511).
 * @param i i32 - slot index
 * @return *u8 - sidecar base or null if i out of range
 * PLATFORM: SHARED freestanding arena sidecar table.
 */
function pipe_arena_sc_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= pipe_arena_sc_max()) {
    return 0 as *u8;
  }
  let off: i64 = (i as i64) * (pipe_arena_sc_size() as i64);
  return &g_pipe_arena_sc_blob[0] + (off as usize);
}

/**
 * Pointer to ModuleSidecar slot i (0..511).
 * @param i i32 - slot index
 * @return *u8 - sidecar base or null
 * PLATFORM: SHARED freestanding module sidecar table.
 */
function pipe_module_sc_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= pipe_module_sc_max()) {
    return 0 as *u8;
  }
  let off: i64 = (i as i64) * (pipe_module_sc_size() as i64);
  return &g_pipe_module_sc_blob[0] + (off as usize);
}

/**
 * Pointer to OneFuncSidecar slot i (0..1023).
 * @param i i32 - slot index
 * @return *u8 - sidecar base or null
 * PLATFORM: SHARED freestanding onefunc sidecar table.
 */
function pipe_onefunc_sc_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= pipe_onefunc_sc_max()) {
    return 0 as *u8;
  }
  let off: i64 = (i as i64) * (pipe_onefunc_sc_size() as i64);
  return &g_pipe_onefunc_sc_blob[0] + (off as usize);
}

/**
 * After a slot is marked unused, drop trailing empty slots from used_hi.
 */
function pipe_onefunc_sc_shrink_hi(): void {
  while (g_pipe_onefunc_sc_used_hi > 0) {
    let last: *u8 = pipe_onefunc_sc_at(g_pipe_onefunc_sc_used_hi - 1);
    if (w308_load(last, 8) != 0) {
      return;
    }
    g_pipe_onefunc_sc_used_hi = g_pipe_onefunc_sc_used_hi - 1;
  }
}


function pipe_arena_sc_free(sc: *u8): void {
  if (sc == 0 as *u8) {
    return;
  }
  pipe_arena_sc_drop_last(sc);
  w308_gv_free(sc + (16 as usize));
  w308_gv_free(sc + (48 as usize));
  w308_gv_free(sc + (80 as usize));
  w308_gv_free(sc + (112 as usize));
  w308_gv_free(sc + (144 as usize));
  w308_gv_free(sc + (176 as usize));
  w308_gv_free(sc + (208 as usize));
  w308_gv_free(sc + (240 as usize));
  w308_gv_free(sc + (272 as usize));
  w308_gv_free(sc + (304 as usize));
  w308_gv_free(sc + (336 as usize));
  w308_gv_free(sc + (368 as usize));
  w308_gv_free(sc + (400 as usize));
  w308_gv_free(sc + (432 as usize));
  w308_gv_free(sc + (464 as usize));
  w308_gv_free(sc + (496 as usize));
  w308_gv_free(sc + (528 as usize));
  w308_gv_free(sc + (560 as usize));
  w308_gv_free(sc + (592 as usize));
  w308_gv_free(sc + (624 as usize));
  w308_gv_free(sc + (656 as usize));
  w308_gv_free(sc + (688 as usize));
  w308_gv_free(sc + (720 as usize));
  w308_gv_free(sc + (752 as usize));
  w308_gv_free(sc + (784 as usize));
  unsafe {
    w308_memset(sc, 0, pipe_arena_sc_size() as usize);
  }
}

function pipe_module_sc_free(sc: *u8): void {
  if (sc == 0 as *u8) {
    return;
  }
  pipe_module_sc_drop_last(sc);
  w308_gv_free(sc + (16 as usize));
  w308_gv_free(sc + (48 as usize));
  w308_gv_free(sc + (80 as usize));
  w308_gv_free(sc + (112 as usize));
  w308_gv_free(sc + (144 as usize));
  w308_gv_free(sc + (176 as usize));
  w308_gv_free(sc + (208 as usize));
  w308_gv_free(sc + (240 as usize));
  w308_gv_free(sc + (272 as usize));
  w308_gv_free(sc + (304 as usize));
  w308_gv_free(sc + (336 as usize));
  w308_gv_free(sc + (368 as usize));
  w308_gv_free(sc + (400 as usize));
  unsafe {
    w308_memset(sc, 0, pipe_module_sc_size() as usize);
  }
}

function pipe_onefunc_sc_free(sc: *u8): void {
  if (sc == 0 as *u8) {
    return;
  }
  pipe_onefunc_sc_drop_last(sc);
  w308_gv_free(sc + (16 as usize));
  w308_gv_free(sc + (48 as usize));
  w308_gv_free(sc + (80 as usize));
  w308_gv_free(sc + (112 as usize));
  w308_gv_free(sc + (144 as usize));
  w308_gv_free(sc + (176 as usize));
  w308_gv_free(sc + (208 as usize));
  w308_gv_free(sc + (240 as usize));
  w308_gv_free(sc + (272 as usize));
  w308_gv_free(sc + (304 as usize));
  w308_gv_free(sc + (336 as usize));
  w308_gv_free(sc + (368 as usize));
  w308_gv_free(sc + (400 as usize));
  w308_gv_free(sc + (432 as usize));
  w308_gv_free(sc + (464 as usize));
  w308_gv_free(sc + (496 as usize));
  w308_gv_free(sc + (528 as usize));
  w308_gv_free(sc + (560 as usize));
  w308_gv_free(sc + (592 as usize));
  w308_gv_free(sc + (624 as usize));
  w308_gv_free(sc + (656 as usize));
  w308_gv_free(sc + (688 as usize));
  w308_gv_free(sc + (720 as usize));
  w308_gv_free(sc + (752 as usize));
  w308_gv_free(sc + (784 as usize));
  w308_gv_free(sc + (816 as usize));
  w308_gv_free(sc + (848 as usize));
  w308_gv_free(sc + (880 as usize));
  w308_gv_free(sc + (912 as usize));
  unsafe {
    w308_memset(sc, 0, pipe_onefunc_sc_size() as usize);
  }
  pipe_onefunc_sc_shrink_hi();
}

/**
 * Free all GrowVec data buffers owned by a arena sidecar and mark slot unused.
 * @param sc *u8 — arena sidecar base; null -> no-op
 * @return void
 * wave275 pure-owned leave. PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function arena_sidecar_free(sc: *u8): void {
  pipe_arena_sc_free(sc);
}

/**
 * Free all GrowVec data buffers owned by a module sidecar and mark slot unused.
 * @param sc *u8 — module sidecar base; null -> no-op
 * @return void
 * wave275 pure-owned leave. PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function module_sidecar_free(sc: *u8): void {
  pipe_module_sc_free(sc);
}

/**
 * Free all GrowVec data buffers owned by a onefunc sidecar and mark slot unused.
 * @param sc *u8 — onefunc sidecar base; null -> no-op
 * @return void
 * wave275 pure-owned leave. PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function onefunc_sidecar_free(sc: *u8): void {
  pipe_onefunc_sc_free(sc);
}

/**
 * Lookup or create arena sidecar for pointer key.
 * @param key *u8 — arena/module/onefunc key; null -> null
 * @param create i32 — non-zero to allocate free slot + init GrowVecs
 * @return *u8 — sidecar base or null
 * wave275 pure-owned leave; G.7 single process table.
 * P2 Darwin -o: 2-slot MRU before the MAX=512 linear walk.
 * PLATFORM: SHARED freestanding arena Cap leave.
 */
#[no_mangle]
export function arena_sidecar_get(key: *u8, create: i32): *u8 {
  if (key == 0 as *u8) {
    return 0 as *u8;
  }
  let hit: *u8 = pipe_arena_sc_recall(key);
  if (hit != 0 as *u8) {
    return hit;
  }
  let i: i32 = 0;
  while (i < pipe_arena_sc_max()) {
    let sc: *u8 = pipe_arena_sc_at(i);
    let used: i32 = w308_load(sc, 8);
    if (used != 0) {
      let k: *u8 = w308_load_ptr(sc, 0);
      if (k == key) {
        pipe_arena_sc_remember(key, sc);
        return sc;
      }
    }
    i = i + 1;
  }
  if (create == 0) {
    return 0 as *u8;
  }
  i = 0;
  while (i < pipe_arena_sc_max()) {
    let sc2: *u8 = pipe_arena_sc_at(i);
    let used2: i32 = w308_load(sc2, 8);
    if (used2 == 0) {
      w308_store_ptr(sc2, 0, key);
      w308_store(sc2, 8, 1);
      let ic: i32 = w308_gv_init_cap();
      if (w308_gv_init(sc2 + (16 as usize), 532, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (48 as usize), 1224, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (80 as usize), 92, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (112 as usize), 324, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (144 as usize), 268, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (176 as usize), 268, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (208 as usize), 12, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (240 as usize), 268, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (272 as usize), 8, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (304 as usize), 16, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (336 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      /* Cap 4.2.8 sync: W277_LabeledStmt is 528 (label[256]+goto_target[256]);
       * the stale 272 (128-era) stride made the 2nd+ labeled stmt's 528-byte
       * write smash the neighboring slot — same class as the onefunc region
       * stride fix (2026-09-13). */
      if (w308_gv_init(sc2 + (368 as usize), 528, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (400 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (432 as usize), 8, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (464 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (496 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (528 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (560 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (592 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (624 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (656 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (688 as usize), 24, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (720 as usize), 264, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (752 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (784 as usize), 264, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      pipe_arena_sc_remember(key, sc2);
      return sc2;
    }
    i = i + 1;
  }
  return 0 as *u8;
}

/**
 * Lookup or create module sidecar for pointer key.
 * @param key *u8 — arena/module/onefunc key; null -> null
 * @param create i32 — non-zero to allocate free slot + init GrowVecs
 * @return *u8 — sidecar base or null
 * wave275 pure-owned leave; G.7 single process table.
 * P2 Darwin -o: 2-slot MRU before the MAX=512 linear walk.
 * PLATFORM: SHARED freestanding module Cap leave.
 */
#[no_mangle]
export function module_sidecar_get(key: *u8, create: i32): *u8 {
  if (key == 0 as *u8) {
    return 0 as *u8;
  }
  let hit: *u8 = pipe_module_sc_recall(key);
  if (hit != 0 as *u8) {
    return hit;
  }
  let i: i32 = 0;
  while (i < pipe_module_sc_max()) {
    let sc: *u8 = pipe_module_sc_at(i);
    let used: i32 = w308_load(sc, 8);
    if (used != 0) {
      let k: *u8 = w308_load_ptr(sc, 0);
      if (k == key) {
        pipe_module_sc_remember(key, sc);
        return sc;
      }
    }
    i = i + 1;
  }
  if (create == 0) {
    return 0 as *u8;
  }
  i = 0;
  while (i < pipe_module_sc_max()) {
    let sc2: *u8 = pipe_module_sc_at(i);
    let used2: i32 = w308_load(sc2, 8);
    if (used2 == 0) {
      w308_store_ptr(sc2, 0, key);
      w308_store(sc2, 8, 1);
      let ic: i32 = w308_gv_init_cap();
      if (w308_gv_init(sc2 + (16 as usize), 324, ic) == 0) {
        pipe_module_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (48 as usize), 4, ic) == 0) {
        pipe_module_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (80 as usize), 532, ic) == 0) {
        pipe_module_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (112 as usize), 288, ic) == 0) {
        pipe_module_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (144 as usize), 276, ic) == 0) {
        pipe_module_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (176 as usize), 264, ic) == 0) {
        pipe_module_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (208 as usize), 66828, ic) == 0) {
        pipe_module_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (240 as usize), 256, ic) == 0) {
        pipe_module_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (272 as usize), 4, ic) == 0) {
        pipe_module_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (304 as usize), 264, ic) == 0) {
        pipe_module_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (336 as usize), 272, ic) == 0) {
        pipe_module_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (368 as usize), 260, ic) == 0) {
        pipe_module_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (400 as usize), 8, ic) == 0) {
        pipe_module_sc_free(sc2);
        return 0 as *u8;
      }
      pipe_module_sc_remember(key, sc2);
      return sc2;
    }
    i = i + 1;
  }
  return 0 as *u8;
}

/**
 * Lookup or create onefunc sidecar for pointer key.
 * @param key *u8 — arena/module/onefunc key; null -> null
 * @param create i32 — non-zero to allocate free slot + init GrowVecs
 * @return *u8 — sidecar base or null
 * wave275 pure-owned leave; G.7 single process table.
 * P2 Darwin -o: 16-slot ring before the used_hi linear walk (dummy-wire live
 * keys miss a 2-slot src/dst cache; miss walk stops at last occupied slot).
 * PLATFORM: SHARED freestanding onefunc Cap leave.
 */
#[no_mangle]
export function onefunc_sidecar_get(key: *u8, create: i32): *u8 {
  if (key == 0 as *u8) {
    return 0 as *u8;
  }
  let hit: *u8 = pipe_onefunc_sc_recall(key);
  if (hit != 0 as *u8) {
    return hit;
  }
  let i: i32 = 0;
  let lim: i32 = pipe_onefunc_sc_used_lim();
  while (i < lim) {
    let sc: *u8 = pipe_onefunc_sc_at(i);
    let used: i32 = w308_load(sc, 8);
    if (used != 0) {
      let k: *u8 = w308_load_ptr(sc, 0);
      if (k == key) {
        pipe_onefunc_sc_remember(key, sc);
        return sc;
      }
    }
    i = i + 1;
  }
  if (create == 0) {
    return 0 as *u8;
  }
  i = 0;
  while (i < pipe_onefunc_sc_max()) {
    let sc2: *u8 = pipe_onefunc_sc_at(i);
    let used2: i32 = w308_load(sc2, 8);
    if (used2 == 0) {
      w308_store_ptr(sc2, 0, key);
      w308_store(sc2, 8, 1);
      if (i + 1 > g_pipe_onefunc_sc_used_hi) {
        g_pipe_onefunc_sc_used_hi = i + 1;
      }
      let ic: i32 = w308_gv_init_cap();
      if (w308_gv_init(sc2 + (16 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (48 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (80 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (112 as usize), 256, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (144 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (176 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (208 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (240 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (272 as usize), 256, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (304 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (336 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (368 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (400 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (432 as usize), 1, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (464 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (496 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (528 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (560 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (592 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (624 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (656 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (688 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (720 as usize), 256, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (752 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (784 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (816 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      /* Cap 4.2.8 missed mirror (live thin authority): W281_RegionEntry is
       * 268 (label[256]) — the stale 140 stride made entry N+1's 268-byte
       * write overlap entry N's tail, smashing body_ref/with_arena_cap_ref
       * (offsets 260/264) with label bytes: consecutive unsafe/region
       * statements lost all but the last (2026-09-13 L4 forensics m5/m9). */
      if (w308_gv_init(sc2 + (848 as usize), 268, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (880 as usize), 4, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      if (w308_gv_init(sc2 + (912 as usize), 528, ic) == 0) {
        pipe_onefunc_sc_free(sc2);
        return 0 as *u8;
      }
      pipe_onefunc_sc_remember(key, sc2);
      return sc2;
    }
    i = i + 1;
  }
  return 0 as *u8;
}

