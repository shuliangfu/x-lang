// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Full text: LICENSE.Apache-2.0

// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
//   const dbkv = import("std.db.kv");
//   let store = dbkv.open(path, capacity);
//   dbkv.append_ts(store, key, key_len, payload, payload_len, ts_ns);

const mmap = import("std.sys.mmap");

/* See implementation. */
export const KV_OK: i32 = 0;
/* See implementation. */
export const KV_ERR_NULL: i32 = -1;
/* See implementation. */
export const KV_ERR_OPEN: i32 = -2;
/* See implementation. */
export const KV_ERR_FULL: i32 = -3;
/* See implementation. */
export const KV_ERR_NOT_FOUND: i32 = -6;
/* See implementation. */
export const KV_NOT_IMPL: i32 = -9;

/* See implementation. */
export const KV_SECTOR_BYTES: i32 = 4096;

/* See implementation. */
export struct KvStore {
  handle: i64;
}

extern function db_kv_open_c(path: *u8, capacity_bytes: u64): i64;
extern function db_kv_close_c(handle: i64): i32;
extern function db_kv_sync_c(handle: i64): i32;
extern function db_kv_put_c(handle: i64, key: *u8, key_len: u32, val: *u8, val_len: u32): i32;
extern function db_kv_append_ts_c(handle: i64, key: *u8, key_len: u32, val: *u8, val_len: u32, ts_ns: u64): i32;
extern function db_kv_get_c(handle: i64, key: *u8, key_len: u32, out: *u8, out_cap: u32): i32;
extern function db_kv_wal_flush_c(handle: i64): i32;
extern function db_kv_compact_c(handle: i64): i32;
extern function db_kv_compact_gen_c(handle: i64): u64;
extern function db_kv_wal_bytes_c(handle: i64): u64;
extern function db_kv_sst_level_count_c(handle: i64): u32;
extern function db_kv_smoke_c(path: *u8): i32;

/** Exported function `mmap_available`.
 * Implements `mmap_available`.
 * @return i32
 */
export function mmap_available(): i32 {
  return mmap.mmap_available();
}

/** Exported function `open`.
 * Implements `open`.
 * @param path *u8
 * @param capacity_bytes u64
 * @return KvStore
 */
export function open(path: *u8, capacity_bytes: u64): KvStore {
  let _rc: KvStore = 0;
  unsafe { _rc = KvStore { handle: db_kv_open_c(path, capacity_bytes) }; }
  return _rc;
}

/** Exported function `close`.
 * Implements `close`.
 * @param store KvStore
 * @return i32
 */
export function close(store: KvStore): i32 {
  unsafe { return db_kv_close_c(store.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `sync`.
 * Implements `sync`.
 * @param store KvStore
 * @return i32
 */
export function sync(store: KvStore): i32 {
  unsafe { return db_kv_sync_c(store.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `put`.
 * Implements `put`.
 * @param store KvStore
 * @param key *u8
 * @param key_len u32
 * @param val *u8
 * @param val_len u32
 * @return i32
 */
export function put(store: KvStore, key: *u8, key_len: u32, val: *u8, val_len: u32): i32 {
  unsafe { return db_kv_put_c(store.handle, key, key_len, val, val_len); }
  return 0; // unreachable — typeck workaround
}

/**
 * See implementation.
 * See implementation.
 */
export function append_ts(store: KvStore, key: *u8, key_len: u32, val: *u8, val_len: u32, ts_ns: u64): i32 {
  unsafe { return db_kv_append_ts_c(store.handle, key, key_len, val, val_len, ts_ns); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `get`.
 * Implements `get`.
 * @param store KvStore
 * @param key *u8
 * @param key_len u32
 * @param out *u8
 * @param out_cap u32
 * @return i32
 */
export function get(store: KvStore, key: *u8, key_len: u32, out: *u8, out_cap: u32): i32 {
  unsafe { return db_kv_get_c(store.handle, key, key_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `wal_flush`.
 * Implements `wal_flush`.
 * @param store KvStore
 * @return i32
 */
export function wal_flush(store: KvStore): i32 {
  unsafe { return db_kv_wal_flush_c(store.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `compact`.
 * Implements `compact`.
 * @param store KvStore
 * @return i32
 */
export function compact(store: KvStore): i32 {
  unsafe { return db_kv_compact_c(store.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `compact_generation`.
 * Implements `compact_generation`.
 * @param store KvStore
 * @return u64
 */
export function compact_generation(store: KvStore): u64 {
  unsafe { return db_kv_compact_gen_c(store.handle); }
  return 0 as u64; // unreachable — typeck workaround
}

/** Exported function `wal_bytes`.
 * Implements `wal_bytes`.
 * @param store KvStore
 * @return u64
 */
export function wal_bytes(store: KvStore): u64 {
  unsafe { return db_kv_wal_bytes_c(store.handle); }
  return 0 as u64; // unreachable — typeck workaround
}

/** Exported function `sst_level_count`.
 * Implements `sst_level_count`.
 * @param store KvStore
 * @return u32
 */
export function sst_level_count(store: KvStore): u32 {
  unsafe { return db_kv_sst_level_count_c(store.handle); }
  return 0 as u32; // unreachable — typeck workaround
}
