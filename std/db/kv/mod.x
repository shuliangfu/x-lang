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

// std.db.kv — mmap LSM-Tree 键值引擎 v3（WAL + 3 级 SST 去重合并 + 压实，无 SQL）
//
// 【文件职责】
// 高频 Tick / 突触权重：Arena 序列化 → WAL 热写 → flush/compact 入主文件。
// 底层 mmap 走 std.sys.mmap；实现见 kv.x + kv_mmap_glue.c（F-05 v2）。
//
// 【用法】
//   const dbkv = import("std.db.kv");
//   let store = dbkv.open(path, capacity);
//   dbkv.append_ts(store, key, key_len, payload, payload_len, ts_ns);

const mmap = import("std.sys.mmap");

/** 成功。 */
export const KV_OK: i32 = 0;
/** 空参数。 */
export const KV_ERR_NULL: i32 = -1;
/** 打开/mmap 失败。 */
export const KV_ERR_OPEN: i32 = -2;
/** 空间不足。 */
export const KV_ERR_FULL: i32 = -3;
/** key 未找到。 */
export const KV_ERR_NOT_FOUND: i32 = -6;
/** 平台未实现。 */
export const KV_NOT_IMPL: i32 = -9;

/** 默认扇区大小（与 kv.x KV_SECTOR 一致）。 */
export const KV_SECTOR_BYTES: i32 = 4096;

/** 不透明 KV 存储句柄。 */
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

/** mmap 子系统是否可用（委托 std.sys.mmap）。 */
export function mmap_available(): i32 {
  return mmap.mmap_available();
}

/** 打开/创建 mmap KV + WAL（path.wal）；capacity_bytes 建议 ≥ 64KiB。 */
export function open(path: *u8, capacity_bytes: u64): KvStore {
  let _rc: KvStore = 0;
  unsafe { _rc = KvStore { handle: db_kv_open_c(path, capacity_bytes) }; }
  return _rc;
}

/** 关闭并 munmap 主文件与 WAL。 */
export function close(store: KvStore): i32 {
  unsafe { return db_kv_close_c(store.handle); }
  return 0; // unreachable — typeck workaround
}

/** msync 刷盘（主文件 + WAL）。 */
export function sync(store: KvStore): i32 {
  unsafe { return db_kv_sync_c(store.handle); }
  return 0; // unreachable — typeck workaround
}

/** 写入键值（ts_ns=0）；热路径写 WAL 层。 */
export function put(store: KvStore, key: *u8, key_len: u32, val: *u8, val_len: u32): i32 {
  unsafe { return db_kv_put_c(store.handle, key, key_len, val, val_len); }
  return 0; // unreachable — typeck workaround
}

/**
 * 时序追加：带 ts_ns 的 Append-Only 写（Tick / 权重流）。
 * Arena bump 序列化后写入 WAL mmap 区。
 */
export function append_ts(store: KvStore, key: *u8, key_len: u32, val: *u8, val_len: u32, ts_ns: u64): i32 {
  unsafe { return db_kv_append_ts_c(store.handle, key, key_len, val, val_len, ts_ns); }
  return 0; // unreachable — typeck workaround
}

/** 读取最新值；成功返回字节数，KV_ERR_NOT_FOUND 等 <0。 */
export function get(store: KvStore, key: *u8, key_len: u32, out: *u8, out_cap: u32): i32 {
  unsafe { return db_kv_get_c(store.handle, key, key_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** WAL 刷入主文件（L0→L1 分层合并）。 */
export function wal_flush(store: KvStore): i32 {
  unsafe { return db_kv_wal_flush_c(store.handle); }
  return 0; // unreachable — typeck workaround
}

/** LSM 压实：主文件去重保留最新 key，清空 WAL。 */
export function compact(store: KvStore): i32 {
  unsafe { return db_kv_compact_c(store.handle); }
  return 0; // unreachable — typeck workaround
}

/** 压实世代号（每次 compact +1）。 */
export function compact_generation(store: KvStore): u64 {
  unsafe { return db_kv_compact_gen_c(store.handle); }
  return 0 as u64; // unreachable — typeck workaround
}

/** 当前 WAL 区已用字节数（不含 4KiB 头）。 */
export function wal_bytes(store: KvStore): u64 {
  unsafe { return db_kv_wal_bytes_c(store.handle); }
  return 0 as u64; // unreachable — typeck workaround
}

/** 已冻结 SST 层数（L2+ 侧车 *.sst.N；compact 后递增）。 */
export function sst_level_count(store: KvStore): u32 {
  unsafe { return db_kv_sst_level_count_c(store.handle); }
  return 0 as u32; // unreachable — typeck workaround
}
