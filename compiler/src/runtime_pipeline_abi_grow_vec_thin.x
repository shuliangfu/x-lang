// Thin pure: wave300/356 M2 — grow_vec Cap residual C→.x (was wave271 C thin).
// GrowVec LE sizeof 32: data*@0 cap@8 len@12 elem_sz@16 mmap@24.
// Faces: init / free / ensure / at / push / copy_append.
// Growth: INIT_CAP=256, GROW=4096, MMAP_THRESH=1MiB (POSIX mmap).
// G.7: bodies match runtime_pipeline_abi.x wave271 leave + seed cold twins.
// wave356: wrap all LE slot load/store helpers in unsafe (T001, same as
// w349/w354); PRODUCT inject PREFER_ASM both ends after typeck green.
// Stamp w356. PLATFORM: SHARED freestanding Cap leave · LINUX · MACOS.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function xlang_ptr_slot_get(arr: *u8, i: i32): *u8;
export extern function xlang_ptr_slot_set(arr: *u8, i: i32, p: *u8): void;
export extern function xlang_size_slot_get(arr: *u8, i: i32): i64;
export extern function xlang_size_slot_set(arr: *u8, i: i32, v: i64): void;
export extern "C" function malloc(n: usize): *u8;
export extern "C" function calloc(n: usize, sz: usize): *u8;
export extern "C" function realloc(p: *u8, n: usize): *u8;
export extern "C" function free(p: *u8): void;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
export extern "C" function mmap(addr: *u8, len: usize, prot: i32, flags: i32, fd: i32, off: i64): *u8;
export extern "C" function munmap(addr: *u8, len: usize): i32;

const W300_OFF_CAP: i32 = 8;
const W300_OFF_LEN: i32 = 12;
const W300_OFF_MMAP: i32 = 24;
const W300_INIT_CAP: i32 = 256;
const W300_GROW: i32 = 4096;
const W300_MMAP_THRESH: i64 = 1048576;

#[cfg(target_os = "linux")]
let g_w300_mmap_flags: i32 = 34;
#[cfg(target_os = "macos")]
let g_w300_mmap_flags: i32 = 4098;
#[cfg(not(target_os = "linux"))]
#[cfg(not(target_os = "macos"))]
let g_w300_mmap_flags: i32 = 0;

/**
 * Load GrowVec.data*. PLATFORM: SHARED LP64 — extern slot get in unsafe (T001).
 */
function w300_load_data(v: *u8): *u8 {
  unsafe {
    return xlang_ptr_slot_get(v, 0);
  }
}

/**
 * Store GrowVec.data*. PLATFORM: SHARED LP64 — extern slot set in unsafe (T001).
 */
function w300_store_data(v: *u8, p: *u8): void {
  unsafe {
    xlang_ptr_slot_set(v, 0, p);
  }
}

/**
 * Load GrowVec.cap. PLATFORM: SHARED LP64 — extern LE load in unsafe (T001).
 */
function w300_load_cap(v: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(v, W300_OFF_CAP);
  }
}

/**
 * Store GrowVec.cap. PLATFORM: SHARED LP64 — extern LE store in unsafe (T001).
 */
function w300_store_cap(v: *u8, c: i32): void {
  unsafe {
    pipe_store_i32_le(v, W300_OFF_CAP, c);
  }
}

/**
 * Load GrowVec.len. PLATFORM: SHARED LP64 — extern LE load in unsafe (T001).
 */
function w300_load_len(v: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(v, W300_OFF_LEN);
  }
}

/**
 * Store GrowVec.len. PLATFORM: SHARED LP64 — extern LE store in unsafe (T001).
 */
function w300_store_len(v: *u8, n: i32): void {
  unsafe {
    pipe_store_i32_le(v, W300_OFF_LEN, n);
  }
}

/**
 * Load GrowVec.elem_sz (size_t @16 = slot 2). PLATFORM: SHARED LP64.
 */
function w300_load_elem_sz(v: *u8): i64 {
  unsafe {
    return xlang_size_slot_get(v, 2);
  }
}

/**
 * Store GrowVec.elem_sz. PLATFORM: SHARED LP64.
 */
function w300_store_elem_sz(v: *u8, es: i64): void {
  unsafe {
    xlang_size_slot_set(v, 2, es);
  }
}

/**
 * Load GrowVec.mmap_backed. PLATFORM: SHARED LP64.
 */
function w300_load_mmap(v: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(v, W300_OFF_MMAP);
  }
}

/**
 * Store GrowVec.mmap_backed. PLATFORM: SHARED LP64.
 */
function w300_store_mmap(v: *u8, mm: i32): void {
  unsafe {
    pipe_store_i32_le(v, W300_OFF_MMAP, mm);
  }
}

/**
 * True when p is MAP_FAILED ((void*)-1).
 * PLATFORM: SHARED LP64 — slot round-trip in unsafe (T001).
 */
function w300_ptr_is_map_failed(p: *u8): i32 {
  let cell: u8[8];
  let bits: i64 = 0;
  let failed: i64 = 0 - 1;
  if (p == (0 as *u8)) {
    return 0;
  }
  unsafe {
    xlang_ptr_slot_set(&cell[0], 0, p);
    bits = xlang_size_slot_get(&cell[0], 0);
  }
  if (bits == failed) {
    return 1;
  }
  return 0;
}

/**
 * Allocate nbytes (mmap large when POSIX flags; else calloc).
 * PLATFORM: SHARED · LINUX|MACOS mmap · else calloc.
 */
function w300_alloc_bytes(nbytes: i64, out_mm: *i32): *u8 {
  let flags: i32 = g_w300_mmap_flags;
  let p: *u8 = 0 as *u8;
  let fd: i32 = 0 - 1;
  if (out_mm != (0 as *i32)) {
    unsafe {
      out_mm[0] = 0;
    }
  }
  if (nbytes <= 0) {
    return 0 as *u8;
  }
  if (flags != 0 && nbytes >= W300_MMAP_THRESH) {
    unsafe {
      p = mmap(0 as *u8, nbytes as usize, 3, flags, fd, 0);
    }
    if (p != (0 as *u8) && w300_ptr_is_map_failed(p) == 0) {
      if (out_mm != (0 as *i32)) {
        unsafe {
          out_mm[0] = 1;
        }
      }
      return p;
    }
  }
  unsafe {
    return calloc(1 as usize, nbytes as usize);
  }
}

/**
 * Free GrowVec data (munmap or free).
 * PLATFORM: SHARED.
 */
function w300_dealloc_bytes(p: *u8, nbytes: i64, mmap_backed: i32): void {
  if (p == (0 as *u8)) {
    return;
  }
  if (mmap_backed != 0) {
    if (nbytes > 0) {
      unsafe {
        munmap(p, nbytes as usize);
      }
    }
    return;
  }
  unsafe {
    free(p);
  }
}

/**
 * Initialize GrowVec with capacity initial_cap elements of size elem_sz.
 * @return 1 success, 0 failure
 * PLATFORM: SHARED freestanding Cap leave (wave300 .x thin).
 */
#[no_mangle]
export function grow_vec_init(v: *u8, elem_sz: i64, initial_cap: i32): i32 {
  let ic: i32 = initial_cap;
  let nbytes: i64 = 0;
  let mm: i32 = 0;
  let p: *u8 = 0 as *u8;
  if (v == (0 as *u8) || elem_sz <= 0) {
    return 0;
  }
  w300_store_data(v, 0 as *u8);
  w300_store_cap(v, 0);
  w300_store_len(v, 0);
  w300_store_elem_sz(v, elem_sz);
  w300_store_mmap(v, 0);
  if (ic <= 0) {
    ic = W300_INIT_CAP;
  }
  nbytes = (ic as i64) * elem_sz;
  p = w300_alloc_bytes(nbytes, &mm);
  if (p == (0 as *u8)) {
    return 0;
  }
  w300_store_data(v, p);
  w300_store_mmap(v, mm);
  w300_store_cap(v, ic);
  return 1;
}

/**
 * Free GrowVec data and reset fields.
 * PLATFORM: SHARED freestanding Cap leave (wave300 .x thin).
 */
#[no_mangle]
export function grow_vec_free(v: *u8): void {
  let data: *u8 = 0 as *u8;
  let cap: i32 = 0;
  let es: i64 = 0;
  let mm: i32 = 0;
  if (v == (0 as *u8)) {
    return;
  }
  data = w300_load_data(v);
  if (data != (0 as *u8)) {
    cap = w300_load_cap(v);
    es = w300_load_elem_sz(v);
    mm = w300_load_mmap(v);
    w300_dealloc_bytes(data, (cap as i64) * es, mm);
    w300_store_data(v, 0 as *u8);
  }
  w300_store_cap(v, 0);
  w300_store_len(v, 0);
  w300_store_mmap(v, 0);
}

/**
 * Ensure capacity for one more element.
 * @return 1 success, 0 failure
 * PLATFORM: SHARED freestanding Cap leave (wave300 .x thin).
 */
#[no_mangle]
export function grow_vec_ensure(v: *u8): i32 {
  let len: i32 = 0;
  let cap: i32 = 0;
  let need: i32 = 0;
  let es: i64 = 0;
  let old_cap: i32 = 0;
  let nc: i32 = 0;
  let mm_flag: i32 = 0;
  let use_geo: i32 = 0;
  let old_bytes: i64 = 0;
  let new_bytes: i64 = 0;
  let data: *u8 = 0 as *u8;
  let mm: i32 = 0;
  let p: *u8 = 0 as *u8;
  let p2: *u8 = 0 as *u8;
  if (v == (0 as *u8)) {
    return 0;
  }
  len = w300_load_len(v);
  cap = w300_load_cap(v);
  need = len + 1;
  if (need <= cap) {
    return 1;
  }
  es = w300_load_elem_sz(v);
  if (es <= 0) {
    return 0;
  }
  old_cap = cap;
  nc = cap;
  if (nc <= 0) {
    nc = W300_GROW;
  }
  mm_flag = w300_load_mmap(v);
  if (mm_flag != 0 || (need as i64) * es >= W300_MMAP_THRESH || (nc as i64) * es >= W300_MMAP_THRESH) {
    use_geo = 1;
  }
  if (use_geo != 0) {
    while (nc < need) {
      if (nc > 1073741823) {
        nc = need;
        break;
      }
      nc = nc * 2;
    }
    if (nc < need) {
      nc = need;
    }
  } else {
    while (nc < need) {
      nc = nc + W300_GROW;
    }
  }
  old_bytes = (old_cap as i64) * es;
  new_bytes = (nc as i64) * es;
  data = w300_load_data(v);
  if (mm_flag != 0 || new_bytes >= W300_MMAP_THRESH) {
    p = w300_alloc_bytes(new_bytes, &mm);
    if (p == (0 as *u8)) {
      return 0;
    }
    if (data != (0 as *u8) && old_bytes > 0) {
      unsafe {
        memcpy(p, data, old_bytes as usize);
      }
    }
    w300_dealloc_bytes(data, old_bytes, mm_flag);
    w300_store_data(v, p);
    w300_store_mmap(v, mm);
    w300_store_cap(v, nc);
    return 1;
  }
  unsafe {
    p2 = realloc(data, new_bytes as usize);
  }
  if (p2 == (0 as *u8)) {
    return 0;
  }
  if (new_bytes > old_bytes) {
    unsafe {
      memset(p2 + (old_bytes as usize), 0, (new_bytes - old_bytes) as usize);
    }
  }
  w300_store_data(v, p2);
  w300_store_mmap(v, 0);
  w300_store_cap(v, nc);
  return 1;
}

/**
 * Return pointer to element idx, or null if out of range.
 * PLATFORM: SHARED freestanding Cap leave (wave300 .x thin).
 */
#[no_mangle]
export function grow_vec_at(v: *u8, idx: i32): *u8 {
  let data: *u8 = 0 as *u8;
  let len: i32 = 0;
  let es: i64 = 0;
  let off: i64 = 0;
  if (v == (0 as *u8)) {
    return 0 as *u8;
  }
  data = w300_load_data(v);
  if (data == (0 as *u8) || idx < 0) {
    return 0 as *u8;
  }
  len = w300_load_len(v);
  if (idx >= len) {
    return 0 as *u8;
  }
  es = w300_load_elem_sz(v);
  if (es <= 0) {
    return 0 as *u8;
  }
  off = (idx as i64) * es;
  return data + (off as usize);
}

/**
 * Append one zeroed element; return new index or -1.
 * PLATFORM: SHARED freestanding Cap leave (wave300 .x thin).
 */
#[no_mangle]
export function grow_vec_push(v: *u8): i32 {
  let idx: i32 = 0;
  let data: *u8 = 0 as *u8;
  let es: i64 = 0;
  let off: i64 = 0;
  if (v == (0 as *u8)) {
    return -1;
  }
  if (grow_vec_ensure(v) == 0) {
    return -1;
  }
  idx = w300_load_len(v);
  data = w300_load_data(v);
  es = w300_load_elem_sz(v);
  if (data == (0 as *u8) || es <= 0) {
    return -1;
  }
  off = (idx as i64) * es;
  unsafe {
    memset(data + (off as usize), 0, es as usize);
  }
  w300_store_len(v, idx + 1);
  return idx;
}

/**
 * Append all elements of src onto dst (element-wise memcpy).
 * PLATFORM: SHARED freestanding Cap leave (wave300 .x thin).
 */
#[no_mangle]
export function grow_vec_copy_append(dst: *u8, src: *u8): void {
  let sn: i32 = 0;
  let ses: i64 = 0;
  let i: i32 = 0;
  let ps: *u8 = 0 as *u8;
  let pd: *u8 = 0 as *u8;
  let dn: i32 = 0;
  if (dst == (0 as *u8) || src == (0 as *u8)) {
    return;
  }
  sn = w300_load_len(src);
  ses = w300_load_elem_sz(src);
  if (ses <= 0) {
    return;
  }
  while (i < sn) {
    ps = grow_vec_at(src, i);
    if (grow_vec_push(dst) < 0) {
      return;
    }
    dn = w300_load_len(dst);
    pd = grow_vec_at(dst, dn - 1);
    if (ps != (0 as *u8) && pd != (0 as *u8)) {
      unsafe {
        memcpy(pd, ps, ses as usize);
      }
    }
    i = i + 1;
  }
}
