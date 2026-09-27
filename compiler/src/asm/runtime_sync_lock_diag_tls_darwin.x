// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// runtime_sync_lock_diag_tls_darwin.x — Darwin arm64 lock-order diagnostic.
//
// The cold ensure path pure-asms src/asm/runtime_sync_lock_diag_tls.x
// (append helpers and the two public wrappers) and this file (the
// table, the per-thread held stack, and the lock hooks), then ld -r.
// It does not pass seeds/runtime_sync_lock_diag_tls.from_x.c to host cc.
// Linux and Windows keep that C seed, including the __thread arrays.
//
// This compiler cannot emit __thread. The held stack is one malloc
// per thread, published with pthread_setspecific. The key itself and
// the process-wide counters live in file-level lets. A direct store
// to a file-level let does not emit, so writers memcpy after the
// address is loaded into a local. Passing &let as a call argument
// makes this compiler exit 139. A 256-byte stack array does not fit,
// so the 64-slot meta table is two malloc buffers. Each function
// keeps a single loop. Index loads copy the index into a local first.
//
// Held block layout (196 bytes):
//   0..127    16 mutex pointers
//   128..191  16 little-endian order ids
//   192..195  little-endian depth
// Meta table: 64 pointers and 64 order ids, allocated on first use.
//
// This object is a user companion. It is not in the g05 compiler
// image. A missing object after pure-asm faults falls back to the
// C seed.
//
// PLATFORM: MACOS|DARWIN arm64.

/**
 * Byte copy. Publishes file-level slots this compiler cannot store.
 * @param d *u8 — destination
 * @param s *u8 — source
 * @param n i64 — byte count
 * @return *u8 — destination
 * PLATFORM: POSIX
 */
export extern "C" function memcpy(d: *u8, s: *u8, n: i64): *u8;

/**
 * Fill a buffer with one byte.
 * @param d *u8 — destination
 * @param c i32 — byte value
 * @param n i64 — byte count
 * @return *u8 — destination
 * PLATFORM: POSIX
 */
export extern "C" function memset(d: *u8, c: i32, n: i64): *u8;

/**
 * Heap buffer.
 * @param n i64 — byte count
 * @return *u8 — buffer, or null
 * PLATFORM: POSIX
 */
export extern "C" function malloc(n: i64): *u8;

/**
 * Create a thread-local key. Darwin pthread_key_t is 8 bytes.
 * The destructor pointer is null: the smoke process exits with the
 * held block still live, matching the C __thread lifetime.
 * @param key *u8 — out pointer to an 8-byte key
 * @param dtor *u8 — destructor, or null
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_key_create(key: *u8, dtor: *u8): i32;

/**
 * Read the current thread's value for a key.
 * @param key i64 — pthread_key_t bits
 * @return *u8 — value, or null
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_getspecific(key: i64): *u8;

/**
 * Publish the current thread's value for a key.
 * @param key i64 — pthread_key_t bits
 * @param val *u8 — value
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_setspecific(key: i64, val: *u8): i32;

/**
 * Append a literal. Defined in the thin TU.
 * @param out *u8 — destination
 * @param pos i32 — write index
 * @param cap i32 — capacity
 * @param s *u8 — bytes
 * @param n i32 — count
 * @return i32 — new index, or -1
 * PLATFORM: SHARED
 */
export extern "C" function sync_lock_diag_append_lit(out: *u8, pos: i32, cap: i32, s: *u8, n: i32): i32;

/**
 * Append a decimal i32. Defined in the thin TU.
 * @param out *u8 — destination
 * @param pos i32 — write index
 * @param cap i32 — capacity
 * @param v i32 — value
 * @return i32 — new index, or -1
 * PLATFORM: SHARED
 */
export extern "C" function sync_lock_diag_append_i32(out: *u8, pos: i32, cap: i32, v: i32): i32;

/**
 * Allocate a mutex. Defined in runtime_sync_os.
 * @return *u8 — mutex, or null
 * PLATFORM: SHARED
 */
export extern "C" function sync_mutex_new_c(): *u8;

/**
 * Free a mutex.
 * @param m *u8 — mutex
 * PLATFORM: SHARED
 */
export extern "C" function sync_mutex_free_c(m: *u8): void;

/**
 * Lock a mutex. Calls the diagnostic hooks in this file.
 * @param m *u8 — mutex
 * @return i32 — 0, or -1 when the diagnostic rejects the lock
 * PLATFORM: SHARED
 */
export extern "C" function sync_mutex_lock_c(m: *u8): i32;

/**
 * Unlock a mutex. Calls the diagnostic hooks in this file.
 * @param m *u8 — mutex
 * @return i32 — 0, or -1 when the diagnostic rejects the unlock
 * PLATFORM: SHARED
 */
export extern "C" function sync_mutex_unlock_c(m: *u8): i32;

/** 1 when the diagnostic is on. PLATFORM: MACOS|DARWIN */
export let diag_enabled: i32 = 0;

/** Last diagnostic error. 0, -1 recursive, -2 order, -3 unlock, -4 table. */
export let diag_last_err: i32 = 0;

/** Successful lock records. PLATFORM: MACOS|DARWIN */
export let diag_acquires: i32 = 0;

/** Order-violation count. PLATFORM: MACOS|DARWIN */
export let diag_contentions: i32 = 0;

/** Live meta slots, 0..64. PLATFORM: MACOS|DARWIN */
export let diag_meta_n: i32 = 0;

/** 64 mutex pointers. Null until first use. PLATFORM: MACOS|DARWIN */
export let diag_ptrs: *u8 = 0;

/** 64 little-endian order ids. Null until first use. PLATFORM: MACOS|DARWIN */
export let diag_ords: *u8 = 0;

/** pthread_key_t bits. 0 is a legal key, so diag_key_ok is the flag. */
export let diag_key: i64 = 0;

/** 1 after pthread_key_create succeeds. PLATFORM: MACOS|DARWIN */
export let diag_key_ok: i32 = 0;

/**
 * Copy one i32 into a slot.
 * @param slot *i32 — destination
 * @param v i32 — value
 * PLATFORM: MACOS|DARWIN
 */
function diag_set_i32(slot: *i32, v: i32): void {
  let tmp: i32 = v;
  unsafe {
    memcpy(slot as *u8, &tmp as *u8, 4);
  }
}

/**
 * Copy one pointer into a slot.
 * @param slot **u8 — destination
 * @param v *u8 — pointer
 * PLATFORM: MACOS|DARWIN
 */
function diag_set_ptr(slot: **u8, v: *u8): void {
  let tmp: *u8 = v;
  unsafe {
    memcpy(slot as *u8, &tmp as *u8, 8);
  }
}

/**
 * Copy one i64 into a slot.
 * @param slot *i64 — destination
 * @param v i64 — value
 * PLATFORM: MACOS|DARWIN
 */
function diag_set_i64(slot: *i64, v: i64): void {
  let tmp: i64 = v;
  unsafe {
    memcpy(slot as *u8, &tmp as *u8, 8);
  }
}

/**
 * Publish diag_enabled.
 * @param v i32 — 0 or 1
 * PLATFORM: MACOS|DARWIN
 */
function diag_enabled_set(v: i32): void {
  let slot: *i32 = &diag_enabled;
  diag_set_i32(slot, v);
}

/**
 * Publish diag_last_err.
 * @param v i32 — error code
 * PLATFORM: MACOS|DARWIN
 */
function diag_last_err_set(v: i32): void {
  let slot: *i32 = &diag_last_err;
  diag_set_i32(slot, v);
}

/**
 * Publish diag_acquires.
 * @param v i32 — count
 * PLATFORM: MACOS|DARWIN
 */
function diag_acquires_set(v: i32): void {
  let slot: *i32 = &diag_acquires;
  diag_set_i32(slot, v);
}

/**
 * Publish diag_contentions.
 * @param v i32 — count
 * PLATFORM: MACOS|DARWIN
 */
function diag_contentions_set(v: i32): void {
  let slot: *i32 = &diag_contentions;
  diag_set_i32(slot, v);
}

/**
 * Publish diag_meta_n.
 * @param v i32 — slot count
 * PLATFORM: MACOS|DARWIN
 */
function diag_meta_n_set(v: i32): void {
  let slot: *i32 = &diag_meta_n;
  diag_set_i32(slot, v);
}

/**
 * Publish the pointer table.
 * @param v *u8 — 512-byte buffer
 * PLATFORM: MACOS|DARWIN
 */
function diag_ptrs_set(v: *u8): void {
  let slot: **u8 = &diag_ptrs;
  diag_set_ptr(slot, v);
}

/**
 * Publish the order table.
 * @param v *u8 — 256-byte buffer
 * PLATFORM: MACOS|DARWIN
 */
function diag_ords_set(v: *u8): void {
  let slot: **u8 = &diag_ords;
  diag_set_ptr(slot, v);
}

/**
 * Publish the pthread key bits.
 * @param v i64 — key
 * PLATFORM: MACOS|DARWIN
 */
function diag_key_set(v: i64): void {
  let slot: *i64 = &diag_key;
  diag_set_i64(slot, v);
}

/**
 * Publish the key-ready flag.
 * @param v i32 — 0 or 1
 * PLATFORM: MACOS|DARWIN
 */
function diag_key_ok_set(v: i32): void {
  let slot: *i32 = &diag_key_ok;
  diag_set_i32(slot, v);
}

/**
 * Store a little-endian i32 at a byte offset.
 * The value is non-negative (a depth or an order id).
 * @param base *u8 — buffer
 * @param off i32 — byte offset
 * @param v i32 — value
 * PLATFORM: MACOS|DARWIN
 */
function diag_store_i32(base: *u8, off: i32, v: i32): void {
  let j0: i32 = off;
  let b0: i32 = v & 255;
  base[j0] = b0 as u8;
  let j1: i32 = off + 1;
  let b1: i32 = (v >> 8) & 255;
  base[j1] = b1 as u8;
  let j2: i32 = off + 2;
  let b2: i32 = (v >> 16) & 255;
  base[j2] = b2 as u8;
  let j3: i32 = off + 3;
  let b3: i32 = (v >> 24) & 255;
  base[j3] = b3 as u8;
}

/**
 * Load one byte as an i32. Split out of diag_load_i32 so that
 * function's frame covers its own spills.
 * @param base *u8 — buffer
 * @param off i32 — byte offset
 * @return i32 — byte value, 0..255
 * PLATFORM: MACOS|DARWIN
 */
function diag_load_byte(base: *u8, off: i32): i32 {
  let j: i32 = off;
  let b: u8 = base[j];
  return b as i32;
}

/**
 * Load two little-endian bytes as an i32.
 * @param base *u8 — buffer
 * @param off i32 — byte offset of the low byte
 * @return i32 — value
 * PLATFORM: MACOS|DARWIN
 */
function diag_load_pair(base: *u8, off: i32): i32 {
  let lo: i32 = diag_load_byte(base, off);
  let hi: i32 = diag_load_byte(base, off + 1);
  return lo + (hi << 8);
}

/**
 * Load a little-endian i32 at a byte offset.
 * @param base *u8 — buffer
 * @param off i32 — byte offset
 * @return i32 — value
 * PLATFORM: MACOS|DARWIN
 */
function diag_load_i32(base: *u8, off: i32): i32 {
  let lo: i32 = diag_load_pair(base, off);
  let hi: i32 = diag_load_pair(base, off + 2);
  return lo + (hi << 16);
}

/**
 * Store one mutex pointer in the held block.
 * The block starts with 16 pointers, so the index is a pointer index.
 * @param h *u8 — held block
 * @param i i32 — slot
 * @param m *u8 — mutex
 * PLATFORM: MACOS|DARWIN
 */
function diag_held_mutex_set(h: *u8, i: i32, m: *u8): void {
  let arr: **u8 = h as **u8;
  arr[i] = m;
}

/**
 * Load one mutex pointer from the held block.
 * The index is copied into a local before the load.
 * @param h *u8 — held block
 * @param i i32 — slot
 * @return *u8 — mutex
 * PLATFORM: MACOS|DARWIN
 */
function diag_held_mutex_get(h: *u8, i: i32): *u8 {
  let j: i32 = i;
  let arr: **u8 = h as **u8;
  return arr[j];
}

/**
 * Store one order id. Orders sit at byte 128.
 * @param h *u8 — held block
 * @param i i32 — slot
 * @param v i32 — order id
 * PLATFORM: MACOS|DARWIN
 */
function diag_held_order_set(h: *u8, i: i32, v: i32): void {
  let off: i32 = 128 + i * 4;
  diag_store_i32(h, off, v);
}

/**
 * Load one order id.
 * @param h *u8 — held block
 * @param i i32 — slot
 * @return i32 — order id
 * PLATFORM: MACOS|DARWIN
 */
function diag_held_order_get(h: *u8, i: i32): i32 {
  let off: i32 = 128 + i * 4;
  return diag_load_i32(h, off);
}

/**
 * Store the held depth. The depth sits at byte 192.
 * @param h *u8 — held block
 * @param n i32 — depth
 * PLATFORM: MACOS|DARWIN
 */
function diag_held_n_set(h: *u8, n: i32): void {
  diag_store_i32(h, 192, n);
}

/**
 * Load the held depth.
 * @param h *u8 — held block
 * @return i32 — depth
 * PLATFORM: MACOS|DARWIN
 */
function diag_held_n_get(h: *u8): i32 {
  return diag_load_i32(h, 192);
}

/**
 * Create the pthread key once.
 * @return i64 — key bits, or 0 when create failed and the flag is still clear
 * PLATFORM: MACOS|DARWIN
 */
function diag_key_ensure(): i64 {
  if (diag_key_ok != 0) {
    return diag_key;
  }
  let k: i64 = 0;
  let rc: i32 = 0;
  unsafe {
    rc = pthread_key_create(&k as *u8, 0);
  }
  if (rc != 0) {
    return 0;
  }
  diag_key_set(k);
  diag_key_ok_set(1);
  return k;
}

/**
 * Current thread's held block. Allocates 196 zero bytes on first use.
 * @return *u8 — block, or null
 * PLATFORM: MACOS|DARWIN
 */
function diag_tls_held(): *u8 {
  let key: i64 = diag_key_ensure();
  if (diag_key_ok == 0) {
    return 0;
  }
  let h: *u8 = 0;
  unsafe {
    h = pthread_getspecific(key);
  }
  if (h != 0) {
    return h;
  }
  unsafe {
    h = malloc(196);
  }
  if (h == 0) {
    return 0;
  }
  unsafe {
    memset(h, 0, 196);
    pthread_setspecific(key, h);
  }
  return h;
}

/**
 * Allocate the process-wide meta table once.
 * @return i32 — 0, or -1 when malloc fails
 * PLATFORM: MACOS|DARWIN
 */
function diag_meta_ensure(): i32 {
  // A live pad pulls the edge store inside this frame.
  // The unpadded store sat eight bytes past the allocation.
  let frame_pad: u8[64] = [];
  frame_pad[0] = 0;
  if (diag_ptrs != 0) {
    return 0;
  }
  let p: *u8 = 0;
  let o: *u8 = 0;
  unsafe {
    p = malloc(512);
    o = malloc(256);
  }
  if (p == 0) {
    return 0 - 1;
  }
  if (o == 0) {
    return 0 - 1;
  }
  unsafe {
    memset(p, 0, 512);
    memset(o, 0, 256);
  }
  diag_ptrs_set(p);
  diag_ords_set(o);
  return 0;
}

/**
 * Store one meta pointer. The table is 64 pointers.
 * @param i i32 — slot
 * @param m *u8 — mutex
 * PLATFORM: MACOS|DARWIN
 */
function diag_meta_ptr_set(i: i32, m: *u8): void {
  let arr: **u8 = diag_ptrs as **u8;
  arr[i] = m;
}

/**
 * Load one meta pointer. The index is copied into a local first.
 * @param i i32 — slot
 * @return *u8 — mutex
 * PLATFORM: MACOS|DARWIN
 */
function diag_meta_ptr_get(i: i32): *u8 {
  let j: i32 = i;
  let arr: **u8 = diag_ptrs as **u8;
  return arr[j];
}

/**
 * Store one meta order id. Four little-endian bytes per slot.
 * @param i i32 — slot
 * @param v i32 — order id
 * PLATFORM: MACOS|DARWIN
 */
function diag_meta_ord_set(i: i32, v: i32): void {
  let off: i32 = i * 4;
  diag_store_i32(diag_ords, off, v);
}

/**
 * Load one meta order id.
 * @param i i32 — slot
 * @return i32 — order id
 * PLATFORM: MACOS|DARWIN
 */
function diag_meta_ord_get(i: i32): i32 {
  // A live pad pulls the scaled index inside this frame.
  // The unpadded store sat eight bytes past the allocation.
  let frame_pad: u8[64] = [];
  frame_pad[0] = 0;
  let off: i32 = i * 4;
  return diag_load_i32(diag_ords, off);
}

/**
 * Find the meta slot for a mutex.
 * @param m *u8 — mutex
 * @return i32 — slot, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_find_meta_idx_impl(m: *u8): i32 {
  if (m == 0) {
    return 0 - 1;
  }
  if (diag_meta_ensure() != 0) {
    return 0 - 1;
  }
  let n: i32 = diag_meta_n;
  let i: i32 = 0;
  while (i < n) {
    if (diag_meta_ptr_get(i) == m) {
      return i;
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Order id bound to a mutex. 0 means unbound or id 0.
 * @param m *u8 — mutex
 * @return i32 — order id
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_get_order_impl(m: *u8): i32 {
  let idx: i32 = sync_lock_diag_find_meta_idx_impl(m);
  if (idx < 0) {
    return 0;
  }
  return diag_meta_ord_get(idx);
}

/**
 * Push a held mutex. Full stack returns -1.
 * @param m *u8 — mutex
 * @param order_id i32 — order id
 * @return i32 — 0, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_tls_push_c(m: *u8, order_id: i32): i32 {
  let h: *u8 = diag_tls_held();
  if (h == 0) {
    return 0 - 1;
  }
  let n: i32 = diag_held_n_get(h);
  if (n >= 16) {
    return 0 - 1;
  }
  diag_held_mutex_set(h, n, m);
  diag_held_order_set(h, n, order_id);
  diag_held_n_set(h, n + 1);
  return 0;
}

/**
 * Pop the held stack. Empty is a no-op.
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_tls_pop_c(): void {
  let h: *u8 = diag_tls_held();
  if (h == 0) {
    return;
  }
  let n: i32 = diag_held_n_get(h);
  if (n > 0) {
    diag_held_n_set(h, n - 1);
  }
}

/**
 * Query a mutex in the held stack.
 * 0 absent, 1 held but not top, 2 held and top.
 * @param m *u8 — mutex
 * @return i32 — 0, 1, or 2
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_tls_has_c(m: *u8): i32 {
  let h: *u8 = diag_tls_held();
  if (h == 0) {
    return 0;
  }
  let n: i32 = diag_held_n_get(h);
  let i: i32 = 0;
  while (i < n) {
    if (diag_held_mutex_get(h, i) == m) {
      if (i == n - 1) {
        return 2;
      }
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Largest order id currently held. 0 when the stack is empty.
 * @return i32 — max order
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_tls_max_order_c(): i32 {
  let h: *u8 = diag_tls_held();
  if (h == 0) {
    return 0;
  }
  let n: i32 = diag_held_n_get(h);
  let mx: i32 = 0;
  let i: i32 = 0;
  while (i < n) {
    let ord: i32 = diag_held_order_get(h, i);
    if (ord > mx) {
      mx = ord;
    }
    i = i + 1;
  }
  return mx;
}

/**
 * Held-stack depth for this thread.
 * @return i32 — depth
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_tls_count_c(): i32 {
  let h: *u8 = diag_tls_held();
  if (h == 0) {
    return 0;
  }
  return diag_held_n_get(h);
}

/**
 * Clear this thread's held stack.
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_tls_clear_c(): void {
  let h: *u8 = diag_tls_held();
  if (h == 0) {
    return;
  }
  diag_held_n_set(h, 0);
}

/**
 * Reject a recursive lock or an order inversion.
 * Disabled diagnostic returns 0.
 * @param m *u8 — mutex about to be locked
 * @return i32 — 0, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_before_lock(m: *u8): i32 {
  if (diag_enabled == 0) {
    return 0;
  }
  if (sync_lock_diag_tls_has_c(m) != 0) {
    diag_last_err_set(0 - 1);
    return 0 - 1;
  }
  let oid: i32 = sync_lock_diag_get_order_impl(m);
  if (oid != 0) {
    let maxo: i32 = sync_lock_diag_tls_max_order_c();
    if (maxo > 0) {
      if (oid <= maxo) {
        diag_last_err_set(0 - 2);
        diag_contentions_set(diag_contentions + 1);
        return 0 - 1;
      }
    }
  }
  return 0;
}

/**
 * Record a successful lock on the held stack.
 * @param m *u8 — mutex
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_after_lock(m: *u8): void {
  if (diag_enabled == 0) {
    return;
  }
  let oid: i32 = sync_lock_diag_get_order_impl(m);
  if (sync_lock_diag_tls_push_c(m, oid) != 0) {
    diag_last_err_set(0 - 4);
    return;
  }
  diag_acquires_set(diag_acquires + 1);
  diag_last_err_set(0);
}

/**
 * Reject an unlock that is not the stack top.
 * @param m *u8 — mutex
 * @return i32 — 0, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_before_unlock(m: *u8): i32 {
  if (diag_enabled == 0) {
    return 0;
  }
  if (sync_lock_diag_tls_count_c() <= 0) {
    diag_last_err_set(0 - 3);
    return 0 - 1;
  }
  if (sync_lock_diag_tls_has_c(m) != 2) {
    diag_last_err_set(0 - 3);
    return 0 - 1;
  }
  return 0;
}

/**
 * Pop the held stack after a successful unlock.
 * @param m *u8 — mutex, unused
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_after_unlock(m: *u8): void {
  if (diag_enabled == 0) {
    return;
  }
  sync_lock_diag_tls_pop_c();
  diag_last_err_set(0);
}

/**
 * Turn the diagnostic on or off.
 * @param on i32 — nonzero enables
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_set_enabled_c(on: i32): void {
  if (on != 0) {
    diag_enabled_set(1);
    return;
  }
  diag_enabled_set(0);
}

/**
 * Whether the diagnostic is on.
 * @return i32 — 0 or 1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_is_enabled_c(): i32 {
  if (diag_enabled != 0) {
    return 1;
  }
  return 0;
}

/**
 * Bind an order id to a mutex. 0 skips the order check.
 * @param m *u8 — mutex
 * @param id i32 — order id
 * @return i32 — 0, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_mutex_set_id_c(m: *u8, id: i32): i32 {
  if (m == 0) {
    return 0 - 1;
  }
  let idx: i32 = sync_lock_diag_find_meta_idx_impl(m);
  if (idx >= 0) {
    diag_meta_ord_set(idx, id);
    return 0;
  }
  if (diag_meta_n >= 64) {
    diag_last_err_set(0 - 4);
    return 0 - 1;
  }
  let n: i32 = diag_meta_n;
  diag_meta_ptr_set(n, m);
  diag_meta_ord_set(n, id);
  diag_meta_n_set(n + 1);
  return 0;
}

/**
 * Last diagnostic error code.
 * @return i32 — 0 or a negative code
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_last_err_c(): i32 {
  return diag_last_err;
}

/**
 * Clear meta, counters, and this thread's held stack.
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_clear_c(): void {
  diag_last_err_set(0);
  diag_acquires_set(0);
  diag_contentions_set(0);
  diag_meta_n_set(0);
  sync_lock_diag_tls_clear_c();
}

/**
 * Append one "name=value" field. One string per function so the
 * snapshot frame stays inside its spill slots.
 * @param out *u8 — destination
 * @param cap i32 — capacity
 * @param pos i32 — write index
 * @param lit *u8 — label including the trailing '='
 * @param n i32 — label length
 * @param v i32 — value
 * @return i32 — new index, or -1
 * PLATFORM: MACOS|DARWIN
 */
function diag_snap_field(out: *u8, cap: i32, pos: i32, lit: *u8, n: i32, v: i32): i32 {
  let p: i32 = pos;
  unsafe {
    p = sync_lock_diag_append_lit(out, p, cap, lit, n);
  }
  if (p < 0) {
    return 0 - 1;
  }
  unsafe {
    p = sync_lock_diag_append_i32(out, p, cap, v);
  }
  return p;
}

/**
 * Append "enabled=<n>". The label lives in this function so the
 * snapshot caller does not keep five string addresses live.
 * @param out *u8 — destination
 * @param cap i32 — capacity
 * @param pos i32 — write index
 * @return i32 — new index, or -1
 * PLATFORM: MACOS|DARWIN
 */
function diag_snap_enabled(out: *u8, cap: i32, pos: i32): i32 {
  return diag_snap_field(out, cap, pos, "enabled=", 8, diag_enabled);
}

/**
 * Append " held=<n>".
 * @param out *u8 — destination
 * @param cap i32 — capacity
 * @param pos i32 — write index
 * @param held i32 — stack depth
 * @return i32 — new index, or -1
 * PLATFORM: MACOS|DARWIN
 */
function diag_snap_held(out: *u8, cap: i32, pos: i32, held: i32): i32 {
  return diag_snap_field(out, cap, pos, " held=", 6, held);
}

/**
 * Append " acquires=<n>".
 * @param out *u8 — destination
 * @param cap i32 — capacity
 * @param pos i32 — write index
 * @return i32 — new index, or -1
 * PLATFORM: MACOS|DARWIN
 */
function diag_snap_acquires(out: *u8, cap: i32, pos: i32): i32 {
  return diag_snap_field(out, cap, pos, " acquires=", 10, diag_acquires);
}

/**
 * Append " contentions=<n>".
 * @param out *u8 — destination
 * @param cap i32 — capacity
 * @param pos i32 — write index
 * @return i32 — new index, or -1
 * PLATFORM: MACOS|DARWIN
 */
function diag_snap_contentions(out: *u8, cap: i32, pos: i32): i32 {
  return diag_snap_field(out, cap, pos, " contentions=", 13, diag_contentions);
}

/**
 * Append " last_err=<n>".
 * @param out *u8 — destination
 * @param cap i32 — capacity
 * @param pos i32 — write index
 * @return i32 — new index, or -1
 * PLATFORM: MACOS|DARWIN
 */
function diag_snap_last_err(out: *u8, cap: i32, pos: i32): i32 {
  return diag_snap_field(out, cap, pos, " last_err=", 10, diag_last_err);
}

/**
 * Write the text snapshot. Returns the byte count, or -1.
 * @param out *u8 — destination
 * @param cap i32 — capacity
 * @return i32 — bytes, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_snapshot_c(out: *u8, cap: i32): i32 {
  if (out == 0) {
    return 0 - 1;
  }
  if (cap <= 0) {
    return 0 - 1;
  }
  let held: i32 = sync_lock_diag_tls_count_c();
  let pos: i32 = diag_snap_enabled(out, cap, 0);
  if (pos < 0) {
    return 0 - 1;
  }
  pos = diag_snap_held(out, cap, pos, held);
  if (pos < 0) {
    return 0 - 1;
  }
  pos = diag_snap_acquires(out, cap, pos);
  if (pos < 0) {
    return 0 - 1;
  }
  pos = diag_snap_contentions(out, cap, pos);
  if (pos < 0) {
    return 0 - 1;
  }
  pos = diag_snap_last_err(out, cap, pos);
  if (pos < 0) {
    return 0 - 1;
  }
  if (pos >= cap) {
    return 0 - 1;
  }
  return pos;
}

/**
 * Order and recursion smoke. Same return codes as the C seed.
 * 0 is success. 1..10 name the failed step.
 * @return i32 — 0, or a step code
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_lock_diag_smoke_c(): i32 {
  let m1: *u8 = 0;
  let m2: *u8 = 0;
  unsafe {
    m1 = sync_mutex_new_c();
    m2 = sync_mutex_new_c();
  }
  if (m1 == 0) {
    unsafe { sync_mutex_free_c(m1); }
    unsafe { sync_mutex_free_c(m2); }
    return 1;
  }
  if (m2 == 0) {
    unsafe { sync_mutex_free_c(m1); }
    unsafe { sync_mutex_free_c(m2); }
    return 1;
  }
  sync_lock_diag_clear_c();
  sync_lock_diag_set_enabled_c(1);
  if (sync_lock_diag_mutex_set_id_c(m1, 1) != 0) {
    return 2;
  }
  if (sync_lock_diag_mutex_set_id_c(m2, 2) != 0) {
    return 2;
  }
  let lk: i32 = 0;
  unsafe {
    lk = sync_mutex_lock_c(m1);
  }
  if (lk != 0) {
    return 3;
  }
  unsafe {
    lk = sync_mutex_lock_c(m2);
  }
  if (lk != 0) {
    return 3;
  }
  unsafe {
    lk = sync_mutex_unlock_c(m2);
  }
  if (lk != 0) {
    return 4;
  }
  unsafe {
    lk = sync_mutex_unlock_c(m1);
  }
  if (lk != 0) {
    return 4;
  }
  unsafe {
    lk = sync_mutex_lock_c(m2);
  }
  if (lk != 0) {
    return 5;
  }
  unsafe {
    lk = sync_mutex_lock_c(m1);
  }
  if (lk != 0 - 1) {
    unsafe { sync_mutex_unlock_c(m2); }
    return 6;
  }
  if (sync_lock_diag_last_err_c() != 0 - 2) {
    unsafe { sync_mutex_unlock_c(m2); }
    return 6;
  }
  unsafe { sync_mutex_unlock_c(m2); }
  unsafe {
    lk = sync_mutex_lock_c(m1);
  }
  if (lk != 0) {
    return 7;
  }
  unsafe {
    lk = sync_mutex_lock_c(m1);
  }
  if (lk != 0 - 1) {
    unsafe { sync_mutex_unlock_c(m1); }
    return 8;
  }
  if (sync_lock_diag_last_err_c() != 0 - 1) {
    unsafe { sync_mutex_unlock_c(m1); }
    return 8;
  }
  unsafe { sync_mutex_unlock_c(m1); }
  let snap: *u8 = 0;
  unsafe {
    snap = malloc(96);
  }
  if (snap == 0) {
    return 9;
  }
  if (sync_lock_diag_snapshot_c(snap, 96) <= 0) {
    return 9;
  }
  sync_lock_diag_set_enabled_c(0);
  unsafe {
    lk = sync_mutex_lock_c(m1);
  }
  if (lk != 0) {
    return 10;
  }
  unsafe {
    lk = sync_mutex_unlock_c(m1);
  }
  if (lk != 0) {
    return 10;
  }
  unsafe {
    sync_mutex_free_c(m1);
    sync_mutex_free_c(m2);
  }
  return 0;
}
