// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
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

// std.db.kv.kv — F-05 v2：mmap LSM KV v3（WAL + 多级 SST + 压实，无 SQL）
//
// 【文件职责】
// 从 kv.c 迁出 WAL/LSM/SST/compact/smoke 全量逻辑；mmap 见 kv_mmap_glue.c。
//
// 【分层】
// - L0 WAL（*.wal）：热写路径
// - L1 Main（数据文件）：wal_flush 合并后的可变 SST
// - L2+ Frozen（*.sst.N）：compact 后冻结的不可变 SST
//
// 【记录】rec_magic | rec_len | ts_ns | key_len | val_len | key | val

const KV_SECTOR: u32 = 4096;
const KV_VERSION: u32 = 3;
const KV_REC_MAGIC: u32 = 0x00434552;
const KV_MAX_KEY: u32 = 4096;
const KV_MAX_VAL: u32 = 16777216;
const KV_ARENA_CAP: usize = 262144;
const KV_MT_CAP: u32 = 8192;
const KV_SST_SLOTS: u32 = 3;
const KV_LAYER_MAIN: u8 = 0;
const KV_LAYER_WAL: u8 = 1;
const KV_LAYER_SST_BASE: u8 = 10;
const KV_STORE_MEM_SIZE: usize = 459400;

allow(padding) struct KvHeader {
  magic: u8[8];
  version: u32;
  sector: u32;
  capacity: u64;
  write_pos: u64;
  record_count: u64;
  compact_gen: u64;
  sst_count: u32;
  _pad_sst: u32;
}

allow(padding) struct KvWalHeader {
  magic: u8[8];
  capacity: u64;
  write_pos: u64;
  record_count: u64;
}

allow(padding) struct KvSstHeader {
  magic: u8[8];
  slot: u32;
  _pad: u32;
  capacity: u64;
  write_pos: u64;
  frozen_compact_gen: u64;
}

allow(padding) struct KvMtEntry {
  off: u64;
  key_len: u32;
  key_hash: u32;
  layer: u8;
  _pad: u8[3];
}

allow(padding) struct KvStoreMem {
  map: i64;
  map_size: usize;
  hdr: i64;
  wal_map: i64;
  wal_map_size: usize;
  wal_hdr: i64;
  sst_map: i64[3];
  sst_map_size: usize[3];
  sst_hdr: i64[3];
  data_path: u8[512];
  mt: KvMtEntry[8192];
  mt_count: u32;
  arena: u8[262144];
  arena_off: usize;
}

extern function memcpy(dst: *u8, src: *u8, n: usize): *u8;
extern function memcmp(a: *u8, b: *u8, n: usize): i32;
extern function memset(s: *u8, c: i32, n: usize): *u8;
extern function calloc(nmemb: usize, size: usize): *u8;
extern function free(ptr: *u8): void;
extern function malloc(size: usize): *u8;
extern function strlen(s: *u8): usize;

extern function shu_kv_mmap_file_c(path: *u8, min_size: usize, out_size: *usize): i64;
extern function shu_kv_munmap_c(addr: i64, len: usize): i32;
extern function shu_kv_msync_c(addr: i64, len: usize): i32;

function kv_hash_key(key: *u8, len: u32): u32 {
  let h: u32 = 2166136261;
  let i: u32 = 0;
  while (i < len) {
    h = h ^ (key[i] as u32);
    h = h * 16777619;
    i = i + 1;
  }
  return h;
}

function kv_keys_equal(a: *u8, alen: u32, b: *u8, blen: u32): i32 {
  if (alen != blen) { return 0; }
  unsafe { return memcmp(a, b, alen) == 0 ? 1 : 0; }
}

function kv_mt_clear(s: *KvStoreMem): void { s.mt_count = 0; }

function kv_read_u32_at(base: *u8, off: u64): u32 {
  let i: usize = off as usize;
  return (base[i] as u32) | ((base[i + 1] as u32) << 8) | ((base[i + 2] as u32) << 16) | ((base[i + 3] as u32) << 24);
}

function kv_write_u32_at(base: *u8, off: u64, v: u32): void {
  let i: usize = off as usize;
  base[i] = (v & 0xff) as u8;
  base[i + 1] = ((v >> 8) & 0xff) as u8;
  base[i + 2] = ((v >> 16) & 0xff) as u8;
  base[i + 3] = ((v >> 24) & 0xff) as u8;
}

function kv_write_u64_at(base: *u8, off: u64, v: u64): void {
  kv_write_u32_at(base, off, (v & 0xffffffff) as u32);
  kv_write_u32_at(base, off + (4 as u64), ((v >> 32) & 0xffffffff) as u32);
}

function kv_magic_is_kv(m: *u8): i32 {
  return m[0] == 83 && m[1] == 72 && m[2] == 85 && m[3] == 75 && m[4] == 86 && m[5] == 48 && m[6] == 49 ? 1 : 0;
}

function kv_magic_is_wal(m: *u8): i32 {
  return m[0] == 83 && m[1] == 72 && m[2] == 85 && m[3] == 87 && m[4] == 65 && m[5] == 76 && m[6] == 48 ? 1 : 0;
}

function kv_magic_is_sst(m: *u8): i32 {
  return m[0] == 83 && m[1] == 72 && m[2] == 85 && m[3] == 83 && m[4] == 83 && m[5] == 84 && m[6] == 48 ? 1 : 0;
}

function kv_layer_base_cap(s: *KvStoreMem, layer: u8, out_cap: *u64): *u8 {
  let slot: u32 = 0;
  let wh: *KvWalHeader = 0;
  let hh: *KvHeader = 0;
  let sh: *KvSstHeader = 0;
  if (s == 0 || out_cap == 0) { return 0; }
  if (layer == KV_LAYER_WAL) {
    if (s.wal_hdr != 0 as i64) {
      wh = s.wal_hdr as *KvWalHeader;
      out_cap[0] = wh.capacity;
    } else { out_cap[0] = 0; }
    return s.wal_map as *u8;
  }
  if (layer == KV_LAYER_MAIN) {
    if (s.hdr != 0 as i64) {
      hh = s.hdr as *KvHeader;
      out_cap[0] = hh.capacity;
    } else { out_cap[0] = 0; }
    return s.map as *u8;
  }
  if (layer >= KV_LAYER_SST_BASE) {
    slot = (layer as u32) - (KV_LAYER_SST_BASE as u32);
    if (slot < KV_SST_SLOTS && s.sst_hdr[slot] != 0 as i64) {
      sh = s.sst_hdr[slot] as *KvSstHeader;
      out_cap[0] = sh.capacity;
      return s.sst_map[slot] as *u8;
    }
  }
  return 0;
}

function kv_mt_put_ex(s: *KvStoreMem, off: u64, key: *u8, key_len: u32, layer: u8): void {
  let h: u32 = kv_hash_key(key, key_len);
  let i: u32 = 0;
  let cap: u64 = 0;
  let base: *u8 = 0 as *u8;
  let klen: u32 = 0;
  let key_off: usize = 0;
  while (i < s.mt_count) {
    if (s.mt[i].key_hash == h && s.mt[i].key_len == key_len) {
      base = kv_layer_base_cap(s, s.mt[i].layer, &cap);
      if (base != 0 && s.mt[i].off + 24 <= cap) {
        klen = kv_read_u32_at(base, s.mt[i].off + 16);
        key_off = (s.mt[i].off + 24) as usize;
        if (klen == key_len && kv_keys_equal(base + key_off, klen, key, key_len) != 0) {
          s.mt[i].off = off;
          s.mt[i].layer = layer;
          return;
        }
      }
    }
    i = i + 1;
  }
  i = 0;
  while (i < s.mt_count) {
    if (s.mt[i].key_hash == h && s.mt[i].key_len == key_len) {
      s.mt[i].off = off;
      s.mt[i].layer = layer;
      return;
    }
    i = i + 1;
  }
  if (s.mt_count < KV_MT_CAP) {
    s.mt[s.mt_count].off = off;
    s.mt[s.mt_count].key_len = key_len;
    s.mt[s.mt_count].key_hash = h;
    s.mt[s.mt_count].layer = layer;
    s.mt_count = s.mt_count + 1;
  }
}

function kv_mt_get_off(s: *KvStoreMem, key: *u8, key_len: u32): u64 {
  let h: u32 = kv_hash_key(key, key_len);
  let i: u32 = 0;
  while (i < s.mt_count) {
    if (s.mt[i].key_hash == h && s.mt[i].key_len == key_len) { return s.mt[i].off; }
    i = i + 1;
  }
  return 0;
}

function kv_arena_alloc(s: *KvStoreMem, n: usize, align_bytes: usize): *u8 {
  let off: usize = s.arena_off;
  let mask: usize = align_bytes - 1;
  if ((align_bytes & mask) != 0) { return 0; }
  off = (off + mask) & (0 ^ mask);
  if (off + n > KV_ARENA_CAP) { return 0; }
  s.arena_off = off + n;
  return &s.arena[off] as *u8;
}

function kv_arena_reset(s: *KvStoreMem): void { s.arena_off = 0; }

function kv_copy_cstr(dst: *u8, src: *u8, cap: usize): void {
  let n: usize = 0;
  unsafe { n = strlen(src); }
  if (n + 1 > cap) { n = cap - 1; }
  unsafe { memcpy(dst, src, n); }
  dst[n] = 0;
}

function kv_build_wal_path(data_path: *u8, wal_path: *u8, wal_cap: usize): void {
  let n: usize = 0;
  kv_copy_cstr(wal_path, data_path, wal_cap);
  unsafe { n = strlen(wal_path); }
  if (n + 5 <= wal_cap) {
    wal_path[n] = 46; wal_path[n + 1] = 119; wal_path[n + 2] = 97; wal_path[n + 3] = 108; wal_path[n + 4] = 0;
  }
}

function kv_u32_to_dec(buf: *u8, cap: usize, v: u32): usize {
  let tmp: u8[16] = [];
  let n: usize = 0;
  let x: u32 = v;
  let i: usize = 0;
  if (cap == 0) { return 0; }
  if (x == 0) { buf[0] = 48; return 1; }
  while (x > 0 && n < 16) { tmp[n] = (48 + (x % 10)) as u8; x = x / 10; n = n + 1; }
  if (n > cap) { return 0; }
  while (n > 0) { n = n - 1; buf[i] = tmp[n]; i = i + 1; }
  return i;
}

function kv_build_sst_path(data_path: *u8, slot: u32, out: *u8, out_cap: usize): void {
  let n: usize = 0;
  let m: usize = 0;
  kv_copy_cstr(out, data_path, out_cap);
  unsafe { n = strlen(out); }
  if (n + 6 > out_cap) { return; }
  out[n] = 46; out[n + 1] = 115; out[n + 2] = 115; out[n + 3] = 116; out[n + 4] = 46;
  m = kv_u32_to_dec(out + (n + 5), out_cap - (n + 5), slot);
  out[n + 5 + m] = 0;
}

function kv_mmap_file(path: *u8, min_size: usize, out_size: *usize): i64 {
  unsafe { return shu_kv_mmap_file_c(path, min_size, out_size); }
}

function kv_read_at_map(base: *u8, cap: u64, off: u64, key: *u8, key_len: u32, out: *u8, out_cap: u32): i32 {
  let rmagic: u32 = 0;
  let rlen: u32 = 0;
  let klen: u32 = 0;
  let vlen: u32 = 0;
  if (off + 24 > cap) { return -1; }
  rmagic = kv_read_u32_at(base, off);
  rlen = kv_read_u32_at(base, off + 4);
  if (rmagic != KV_REC_MAGIC || rlen < 24) { return -2; }
  klen = kv_read_u32_at(base, off + 16);
  vlen = kv_read_u32_at(base, off + 20);
  if (klen != key_len || off + 24 + (klen as u64) + (vlen as u64) > cap) { return -3; }
  if (kv_keys_equal(base + ((off + 24) as usize), klen, key, key_len) == 0) { return -4; }
  if (vlen > out_cap) { return -5; }
  unsafe { memcpy(out, base + ((off + 24 + (klen as u64)) as usize), vlen); }
  return vlen as i32;
}

function kv_find_latest_in_map(base: *u8, map_cap: u64, end_off: u64, min_off: u64, key: *u8, key_len: u32, out: *u8, out_cap: u32, found_off: *u64): i32 {
  let off: u64 = min_off;
  let last_r: i32 = -6;
  let rmagic: u32 = 0;
  let rlen: u32 = 0;
  let r: i32 = 0;
  while (off < end_off) {
    if (off + 24 > map_cap) { break; }
    rmagic = kv_read_u32_at(base, off);
    rlen = kv_read_u32_at(base, off + 4);
    if (rmagic != KV_REC_MAGIC || rlen < 24 || off + (rlen as u64) > end_off || off + (rlen as u64) > map_cap) { break; }
    r = kv_read_at_map(base, map_cap, off, key, key_len, out, out_cap);
    if (r >= 0) { last_r = r; if (found_off != 0) { found_off[0] = off; } }
    off = off + (rlen as u64);
  }
  return last_r;
}

function kv_rebuild_mt_from_map(s: *KvStoreMem, base: *u8, map_cap: u64, end_off: u64, layer: u8): void {
  let off: u64 = KV_SECTOR as u64;
  let rmagic: u32 = 0;
  let rlen: u32 = 0;
  let klen: u32 = 0;
  while (off < end_off) {
    if (off + 24 > map_cap) { break; }
    rmagic = kv_read_u32_at(base, off);
    rlen = kv_read_u32_at(base, off + 4);
    if (rmagic != KV_REC_MAGIC || rlen < 24 || off + (rlen as u64) > end_off || off + (rlen as u64) > map_cap) { break; }
    klen = kv_read_u32_at(base, off + 16);
    if (klen > 0 && klen <= KV_MAX_KEY && off + 24 + (klen as u64) <= map_cap) {
      kv_mt_put_ex(s, off, base + ((off + 24) as usize), klen, layer);
    }
    off = off + (rlen as u64);
  }
}

function kv_write_record_to_map(base: *u8, cap: u64, write_pos: *u64, rec: *u8, rec_len: usize): i64 {
  let off: u64 = write_pos[0];
  if (off + (rec_len as u64) > cap) { return -1 as i64; }
  unsafe { memcpy(base + (off as usize), rec, rec_len); }
  write_pos[0] = off + (rec_len as u64);
  return off as i64;
}

function kv_serialize_record(s: *KvStoreMem, key: *u8, key_len: u32, val: *u8, val_len: u32, ts_ns: u64, out_rec: *i64, out_len: *usize): i32 {
  let base: *u8 = 0 as *u8;
  let payload: u32 = 0;
  let rec_len: u32 = 0;
  if (s == 0 || key == 0 || val == 0 || key_len == 0 || key_len > KV_MAX_KEY || val_len > KV_MAX_VAL) { return -1; }
  payload = 8 + 4 + 4 + key_len + val_len;
  rec_len = 4 + 4 + payload;
  kv_arena_reset(s);
  base = kv_arena_alloc(s, rec_len, 8);
  if (base == 0) { return -2; }
  kv_write_u32_at(base, 0, KV_REC_MAGIC);
  kv_write_u32_at(base, 4, rec_len);
  kv_write_u64_at(base, 8, ts_ns);
  kv_write_u32_at(base, 16, key_len);
  kv_write_u32_at(base, 20, val_len);
  unsafe { memcpy(base + 24, key, key_len); }
  unsafe { memcpy(base + ((24 + key_len) as usize), val, val_len); }
  out_rec[0] = base as i64;
  out_len[0] = rec_len as usize;
  return 0;
}

function kv_write_magic_kv(dst: *u8): void {
  dst[0] = 83; dst[1] = 72; dst[2] = 85; dst[3] = 75; dst[4] = 86; dst[5] = 48; dst[6] = 49; dst[7] = 0;
}

function kv_write_magic_wal(dst: *u8): void {
  dst[0] = 83; dst[1] = 72; dst[2] = 85; dst[3] = 87; dst[4] = 65; dst[5] = 76; dst[6] = 48; dst[7] = 49;
}

function kv_write_magic_sst(dst: *u8): void {
  dst[0] = 83; dst[1] = 72; dst[2] = 85; dst[3] = 83; dst[4] = 83; dst[5] = 84; dst[6] = 48; dst[7] = 50;
}

function kv_open_sst_slots(s: *KvStoreMem): i32 {
  let i: u32 = 0;
  let path: u8[512] = [];
  let map_sz: usize = 0;
  let sh: *KvSstHeader = 0 as *KvSstHeader;
  let hdr: *KvHeader = 0 as *KvHeader;
  if (s == 0 || s.hdr == 0 as i64) { return -1; }
  hdr = s.hdr as *KvHeader;
  if (hdr.sst_count > KV_SST_SLOTS) { hdr.sst_count = KV_SST_SLOTS; }
  while (i < hdr.sst_count) {
    kv_build_sst_path(&s.data_path[0], i, &path[0], 512);
    s.sst_map[i] = kv_mmap_file(&path[0], hdr.capacity as usize, &map_sz);
    if (s.sst_map[i] == 0 as i64) { return -2; }
    s.sst_map_size[i] = map_sz;
    s.sst_hdr[i] = s.sst_map[i];
    sh = s.sst_hdr[i] as *KvSstHeader;
    if (kv_magic_is_sst(&sh.magic[0]) == 0) {
      unsafe { memset(sh as *u8, 0, 40); }
      kv_write_magic_sst(&sh.magic[0]);
      sh.slot = i;
      sh.capacity = map_sz as u64;
      sh.write_pos = KV_SECTOR as u64;
      sh.frozen_compact_gen = 0;
    }
    if (sh.write_pos < KV_SECTOR as u64) { sh.write_pos = KV_SECTOR as u64; }
    i = i + 1;
  }
  return 0;
}

function kv_sst_merge_dedup(s: *KvStoreMem, src_slot: u32, dst_slot: u32): i32 {
  let i: u32 = 0;
  let live_n: u32 = 0;
  let live_offs: *u64 = 0 as *u64;
  let live_layers: *u8 = 0 as *u8;
  let dst_base: *u8 = 0 as *u8;
  let out_buf: *u8 = 0 as *u8;
  let out_len: usize = 0;
  let out_cap: usize = 0;
  let cap: u64 = 0;
  let base: *u8 = 0 as *u8;
  let p: *u8 = 0 as *u8;
  let rlen: u32 = 0;
  let src_hdr: *KvSstHeader = 0 as *KvSstHeader;
  let dst_hdr: *KvSstHeader = 0 as *KvSstHeader;
  if (s == 0 || src_slot >= KV_SST_SLOTS || dst_slot >= KV_SST_SLOTS || src_slot == dst_slot) { return -1; }
  if (s.sst_hdr[src_slot] == 0 as i64 || s.sst_hdr[dst_slot] == 0 as i64) { return 0; }
  if (s.sst_map[src_slot] == 0 as i64 || s.sst_map[dst_slot] == 0 as i64) { return 0; }
  src_hdr = s.sst_hdr[src_slot] as *KvSstHeader;
  dst_hdr = s.sst_hdr[dst_slot] as *KvSstHeader;
  kv_mt_clear(s);
  kv_rebuild_mt_from_map(s, s.sst_map[src_slot] as *u8, src_hdr.capacity, src_hdr.write_pos, (KV_LAYER_SST_BASE + (src_slot as u8)) as u8);
  kv_rebuild_mt_from_map(s, s.sst_map[dst_slot] as *u8, dst_hdr.capacity, dst_hdr.write_pos, (KV_LAYER_SST_BASE + (dst_slot as u8)) as u8);
  live_n = s.mt_count;
  if (live_n == 0) { src_hdr.write_pos = KV_SECTOR as u64; return 0; }
  unsafe { live_offs = calloc(live_n, 8) as *u64; }
  unsafe { live_layers = calloc(live_n, 1); }
  if (live_offs == 0 || live_layers == 0) {
    unsafe { free(live_offs as *u8); }
    unsafe { free(live_layers); }
    return -2;
  }
  i = 0;
  while (i < live_n) { live_offs[i] = s.mt[i].off; live_layers[i] = s.mt[i].layer; i = i + 1; }
  out_cap = (dst_hdr.capacity - (KV_SECTOR as u64)) as usize;
  unsafe { out_buf = malloc(out_cap); }
  if (out_buf == 0) {
    unsafe { free(live_offs as *u8); }
    unsafe { free(live_layers); }
    return -2;
  }
  out_len = 0;
  i = 0;
  while (i < live_n) {
    base = kv_layer_base_cap(s, live_layers[i], &cap);
    if (base != 0 && live_offs[i] + 24 <= cap) {
      p = base + (live_offs[i] as usize);
      rlen = kv_read_u32_at(p, 4);
      if (rlen >= 24 && out_len + (rlen) <= out_cap) {
        unsafe { memcpy(out_buf + out_len, p, rlen); }
        out_len = out_len + (rlen);
      }
    }
    i = i + 1;
  }
  unsafe { free(live_offs as *u8); }
  unsafe { free(live_layers); }
  dst_base = s.sst_map[dst_slot] as *u8;
  unsafe { memset(dst_base + (KV_SECTOR as usize), 0, (dst_hdr.capacity - (KV_SECTOR as u64)) as usize); }
  unsafe { memcpy(dst_base + (KV_SECTOR as usize), out_buf, out_len); }
  unsafe { free(out_buf); }
  dst_hdr.write_pos = (KV_SECTOR as u64) + (out_len as u64);
  unsafe { memset(s.sst_map[src_slot] as *u8 + (KV_SECTOR as usize), 0, (src_hdr.capacity - (KV_SECTOR as u64)) as usize); }
  src_hdr.write_pos = KV_SECTOR as u64;
  unsafe { if (shu_kv_msync_c(s.sst_map[dst_slot], s.sst_map_size[dst_slot]) == 0) { return 0; } }
  return -3;
}

function kv_freeze_main_to_sst(s: *KvStoreMem): i32 {
  let data_len: u64 = 0;
  let slot: u32 = 0;
  let path: u8[512] = [];
  let main_base: *u8 = 0 as *u8;
  let sst_base: *u8 = 0 as *u8;
  let map_sz: usize = 0;
  let sh: *KvSstHeader = 0 as *KvSstHeader;
  let hdr: *KvHeader = 0 as *KvHeader;
  if (s == 0 || s.hdr == 0 as i64) { return -1; }
  hdr = s.hdr as *KvHeader;
  data_len = hdr.write_pos - (KV_SECTOR as u64);
  if (data_len == 0) { return 0; }
  if (hdr.sst_count >= KV_SST_SLOTS) {
    if (kv_sst_merge_dedup(s, 0, 1) != 0) { return -5; }
    if (kv_sst_merge_dedup(s, 1, 2) != 0) { return -5; }
    sh = s.sst_hdr[0] as *KvSstHeader;
    sh.write_pos = KV_SECTOR as u64;
    sh = s.sst_hdr[1] as *KvSstHeader;
    sh.write_pos = KV_SECTOR as u64;
    hdr.sst_count = 2;
    slot = 2;
  } else {
    slot = hdr.sst_count;
  }
  kv_build_sst_path(&s.data_path[0], slot, &path[0], 512);
  if (s.sst_map[slot] == 0 as i64) {
    s.sst_map[slot] = kv_mmap_file(&path[0], hdr.capacity as usize, &map_sz);
    if (s.sst_map[slot] == 0 as i64) { return -2; }
    s.sst_map_size[slot] = map_sz;
    s.sst_hdr[slot] = s.sst_map[slot];
    sh = s.sst_hdr[slot] as *KvSstHeader;
    unsafe { memset(sh as *u8, 0, 40); }
    kv_write_magic_sst(&sh.magic[0]);
    sh.slot = slot;
    sh.capacity = map_sz as u64;
    sh.write_pos = KV_SECTOR as u64;
  }
  main_base = s.map as *u8;
  sst_base = s.sst_map[slot] as *u8;
  sh = s.sst_hdr[slot] as *KvSstHeader;
  if ((KV_SECTOR as u64) + data_len > sh.capacity) { return -3; }
  unsafe { memcpy(sst_base + (KV_SECTOR as usize), main_base + (KV_SECTOR as usize), data_len as usize); }
  sh.write_pos = (KV_SECTOR as u64) + data_len;
  sh.frozen_compact_gen = hdr.compact_gen;
  if (slot >= hdr.sst_count) { hdr.sst_count = slot + 1; }
  unsafe { memset(main_base + (KV_SECTOR as usize), 0, (hdr.capacity - (KV_SECTOR as u64)) as usize); }
  hdr.write_pos = KV_SECTOR as u64;
  hdr.record_count = 0;
  unsafe { if (shu_kv_msync_c(s.sst_map[slot], s.sst_map_size[slot]) == 0) { return 0; } }
  return -4;
}

function kv_db_open_impl(path: *u8, capacity_bytes: u64): i64 {
  let s: *KvStoreMem = 0 as *KvStoreMem;
  let wal_path: u8[512] = [];
  let cap: usize = 0;
  let map_sz: usize = 0;
  let wal_sz: usize = 0;
  let i: u32 = 0;
  let hdr: *KvHeader = 0 as *KvHeader;
  let wh: *KvWalHeader = 0 as *KvWalHeader;
  let sh: *KvSstHeader = 0 as *KvSstHeader;
  if (path == 0 || capacity_bytes < KV_SECTOR as u64) { return 0 as i64; }
  cap = capacity_bytes as usize;
  if ((cap % (KV_SECTOR as usize)) != 0) { cap = ((cap / (KV_SECTOR as usize)) + 1) * (KV_SECTOR); }
  unsafe { s = calloc(1, KV_STORE_MEM_SIZE) as *KvStoreMem; }
  if (s == 0) { return 0 as i64; }
  kv_copy_cstr(&s.data_path[0], path, 512);
  s.map = kv_mmap_file(path, cap, &map_sz);
  if (s.map == 0 as i64) { unsafe { free(s as *u8); } return 0 as i64; }
  s.map_size = map_sz;
  s.hdr = s.map;
  hdr = s.hdr as *KvHeader;
  if (kv_magic_is_kv(&hdr.magic[0]) == 0) {
    unsafe { memset(hdr as *u8, 0, 48); }
    kv_write_magic_kv(&hdr.magic[0]);
    hdr.version = KV_VERSION;
    hdr.sector = KV_SECTOR;
    hdr.capacity = map_sz as u64;
    hdr.write_pos = KV_SECTOR as u64;
    hdr.record_count = 0;
    hdr.compact_gen = 0;
    hdr.sst_count = 0;
  }
  if (hdr.version < KV_VERSION) { hdr.sst_count = 0; hdr.version = KV_VERSION; }
  if (hdr.write_pos < KV_SECTOR as u64) { hdr.write_pos = KV_SECTOR as u64; }
  kv_build_wal_path(&s.data_path[0], &wal_path[0], 512);
  s.wal_map = kv_mmap_file(&wal_path[0], cap, &wal_sz);
  if (s.wal_map == 0 as i64) {
    unsafe { shu_kv_munmap_c(s.map, s.map_size); }
    unsafe { free(s as *u8); }
    return 0 as i64;
  }
  s.wal_map_size = wal_sz;
  s.wal_hdr = s.wal_map;
  wh = s.wal_hdr as *KvWalHeader;
  if (kv_magic_is_wal(&wh.magic[0]) == 0) {
    unsafe { memset(wh as *u8, 0, 32); }
    kv_write_magic_wal(&wh.magic[0]);
    wh.capacity = wal_sz as u64;
    wh.write_pos = KV_SECTOR as u64;
    wh.record_count = 0;
  }
  if (wh.write_pos < KV_SECTOR as u64) { wh.write_pos = KV_SECTOR as u64; }
  if (kv_open_sst_slots(s) != 0) {
    unsafe { shu_kv_munmap_c(s.wal_map, s.wal_map_size); }
    unsafe { shu_kv_munmap_c(s.map, s.map_size); }
    unsafe { free(s as *u8); }
    return 0 as i64;
  }
  kv_rebuild_mt_from_map(s, s.map as *u8, hdr.capacity, hdr.write_pos, KV_LAYER_MAIN);
  kv_rebuild_mt_from_map(s, s.wal_map as *u8, wh.capacity, wh.write_pos, KV_LAYER_WAL);
  i = 0;
  while (i < hdr.sst_count) {
    if (s.sst_hdr[i] != 0 as i64) {
      sh = s.sst_hdr[i] as *KvSstHeader;
      kv_rebuild_mt_from_map(s, s.sst_map[i] as *u8, sh.capacity, sh.write_pos, (KV_LAYER_SST_BASE + (i as u8)) as u8);
    }
    i = i + 1;
  }
  return s as i64;
}

function kv_db_close_impl(handle: i64): i32 {
  let s: *KvStoreMem = handle as *KvStoreMem;
  let i: u32 = 0;
  if (s == 0) { return -1; }
  unsafe { if (s.wal_map != 0 as i64) { shu_kv_munmap_c(s.wal_map, s.wal_map_size); } }
  i = 0;
  while (i < KV_SST_SLOTS) {
    unsafe { if (s.sst_map[i] != 0 as i64) { shu_kv_munmap_c(s.sst_map[i], s.sst_map_size[i]); } }
    i = i + 1;
  }
  unsafe { if (s.map != 0 as i64) { shu_kv_munmap_c(s.map, s.map_size); } }
  unsafe { free(s as *u8); }
  return 0;
}

function kv_db_sync_impl(handle: i64): i32 {
  let s: *KvStoreMem = handle as *KvStoreMem;
  let i: u32 = 0;
  let hdr: *KvHeader = 0 as *KvHeader;
  if (s == 0 || s.map == 0 as i64) { return -1; }
  unsafe { if (s.wal_map != 0 as i64 && shu_kv_msync_c(s.wal_map, s.wal_map_size) != 0) { return -1; } }
  hdr = s.hdr as *KvHeader;
  i = 0;
  while (i < hdr.sst_count && i < KV_SST_SLOTS) {
    unsafe { if (s.sst_map[i] != 0 as i64 && shu_kv_msync_c(s.sst_map[i], s.sst_map_size[i]) != 0) { return -1; } }
    i = i + 1;
  }
  unsafe { if (shu_kv_msync_c(s.map, s.map_size) == 0) { return 0; } }
  return -1;
}

function kv_db_append_wal(s: *KvStoreMem, key: *u8, key_len: u32, val: *u8, val_len: u32, ts_ns: u64): i32 {
  let rec: i64 = 0;
  let rec_len: usize = 0;
  let off: i64 = 0;
  let wh: *KvWalHeader = 0 as *KvWalHeader;
  if (s == 0 || s.wal_hdr == 0 as i64 || s.wal_map == 0 as i64) { return -1; }
  if (kv_serialize_record(s, key, key_len, val, val_len, ts_ns, &rec, &rec_len) != 0) { return -2; }
  wh = s.wal_hdr as *KvWalHeader;
  off = kv_write_record_to_map(s.wal_map as *u8, wh.capacity, &wh.write_pos, rec as *u8, rec_len);
  if (off < 0 as i64) { return -3; }
  wh.record_count = wh.record_count + 1;
  kv_mt_put_ex(s, off as u64, key, key_len, KV_LAYER_WAL);
  return 0;
}

function kv_db_get_impl(handle: i64, key: *u8, key_len: u32, out: *u8, out_cap: u32): i32 {
  let s: *KvStoreMem = handle as *KvStoreMem;
  let off: u64 = 0;
  let r: i32 = 0;
  let i: u32 = 0;
  let j: u32 = 0;
  let base: *u8 = 0 as *u8;
  let cap: u64 = 0;
  let layer: u8 = KV_LAYER_MAIN;
  let h: u32 = 0;
  let end_off: u64 = 0;
  let hdr: *KvHeader = 0 as *KvHeader;
  let wh: *KvWalHeader = 0 as *KvWalHeader;
  let sh: *KvSstHeader = 0 as *KvSstHeader;
  if (s == 0 || key == 0 || out == 0 || key_len == 0) { return -1; }
  off = kv_mt_get_off(s, key, key_len);
  if (off != 0) {
    h = kv_hash_key(key, key_len);
    j = 0;
    while (j < s.mt_count) {
      if (s.mt[j].key_hash == h && s.mt[j].key_len == key_len) {
        layer = s.mt[j].layer;
        off = s.mt[j].off;
        break;
      }
      j = j + 1;
    }
    base = kv_layer_base_cap(s, layer, &cap);
    if (base != 0) {
      r = kv_read_at_map(base, cap, off, key, key_len, out, out_cap);
      if (r >= 0) { return r; }
    }
  }
  wh = s.wal_hdr as *KvWalHeader;
  r = kv_find_latest_in_map(s.wal_map as *u8, wh.capacity, wh.write_pos, KV_SECTOR as u64, key, key_len, out, out_cap, &off);
  if (r >= 0) { kv_mt_put_ex(s, off, key, key_len, KV_LAYER_WAL); return r; }
  hdr = s.hdr as *KvHeader;
  r = kv_find_latest_in_map(s.map as *u8, hdr.capacity, hdr.write_pos, KV_SECTOR as u64, key, key_len, out, out_cap, &off);
  if (r >= 0) { kv_mt_put_ex(s, off, key, key_len, KV_LAYER_MAIN); return r; }
  i = hdr.sst_count;
  while (i > 0) {
    let slot: u32 = i - 1;
    if (s.sst_hdr[slot] != 0 as i64) {
      sh = s.sst_hdr[slot] as *KvSstHeader;
      end_off = sh.write_pos;
      r = kv_find_latest_in_map(s.sst_map[slot] as *u8, sh.capacity, end_off, KV_SECTOR as u64, key, key_len, out, out_cap, &off);
      if (r >= 0) { kv_mt_put_ex(s, off, key, key_len, (KV_LAYER_SST_BASE + (slot as u8)) as u8); return r; }
    }
    i = i - 1;
  }
  return -6;
}

function kv_db_wal_flush_impl(handle: i64): i32 {
  let s: *KvStoreMem = handle as *KvStoreMem;
  let off: u64 = 0;
  let wal_base: *u8 = 0 as *u8;
  let i: u32 = 0;
  let rmagic: u32 = 0;
  let rlen: u32 = 0;
  let wh: *KvWalHeader = 0 as *KvWalHeader;
  let hdr: *KvHeader = 0 as *KvHeader;
  let sh: *KvSstHeader = 0 as *KvSstHeader;
  if (s == 0 || s.wal_hdr == 0 as i64) { return 0; }
  wh = s.wal_hdr as *KvWalHeader;
  if (wh.write_pos <= KV_SECTOR as u64) { return 0; }
  wal_base = s.wal_map as *u8;
  hdr = s.hdr as *KvHeader;
  off = KV_SECTOR as u64;
  while (off < wh.write_pos) {
    rmagic = kv_read_u32_at(wal_base, off);
    rlen = kv_read_u32_at(wal_base, off + 4);
    if (rmagic != KV_REC_MAGIC || rlen < 24 || off + (rlen as u64) > wh.write_pos) { break; }
    if (off + (rlen as u64) > hdr.capacity) { return -3; }
    unsafe { memcpy(s.map as *u8 + (hdr.write_pos as usize), wal_base + (off as usize), rlen as usize); }
    hdr.write_pos = hdr.write_pos + (rlen as u64);
    hdr.record_count = hdr.record_count + 1;
    off = off + (rlen as u64);
  }
  wh.write_pos = KV_SECTOR as u64;
  wh.record_count = 0;
  kv_mt_clear(s);
  kv_rebuild_mt_from_map(s, s.map as *u8, hdr.capacity, hdr.write_pos, KV_LAYER_MAIN);
  i = 0;
  while (i < hdr.sst_count) {
    if (s.sst_hdr[i] != 0 as i64) {
      sh = s.sst_hdr[i] as *KvSstHeader;
      kv_rebuild_mt_from_map(s, s.sst_map[i] as *u8, sh.capacity, sh.write_pos, (KV_LAYER_SST_BASE + (i as u8)) as u8);
    }
    i = i + 1;
  }
  unsafe { if (shu_kv_msync_c(s.map, s.map_size) == 0) { return 0; } }
  return -4;
}

function kv_db_compact_impl(handle: i64): i32 {
  let s: *KvStoreMem = handle as *KvStoreMem;
  let live_offs: *u64 = 0 as *u64;
  let live_n: u32 = 0;
  let i: u32 = 0;
  let main_base: *u8 = 0 as *u8;
  let compact_buf: *u8 = 0 as *u8;
  let compact_len: usize = 0;
  let compact_cap: usize = 0;
  let rlen: u32 = 0;
  let hdr: *KvHeader = 0 as *KvHeader;
  let wh: *KvWalHeader = 0 as *KvWalHeader;
  let sh: *KvSstHeader = 0 as *KvSstHeader;
  if (s == 0 || s.hdr == 0 as i64) { return -1; }
  hdr = s.hdr as *KvHeader;
  if (kv_db_wal_flush_impl(handle) != 0) { /* continue */ }
  kv_mt_clear(s);
  kv_rebuild_mt_from_map(s, s.map as *u8, hdr.capacity, hdr.write_pos, KV_LAYER_MAIN);
  unsafe { live_offs = calloc(KV_MT_CAP as usize, 8) as *u64; }
  if (live_offs == 0) { return -2; }
  live_n = s.mt_count;
  i = 0;
  while (i < s.mt_count) { live_offs[i] = s.mt[i].off; i = i + 1; }
  compact_cap = (hdr.write_pos - (KV_SECTOR as u64)) as usize;
  if (compact_cap == 0) { unsafe { free(live_offs as *u8); } return 0; }
  unsafe { compact_buf = malloc(compact_cap); }
  if (compact_buf == 0) { unsafe { free(live_offs as *u8); } return -2; }
  compact_len = 0;
  main_base = s.map as *u8;
  i = 0;
  while (i < live_n) {
    rlen = kv_read_u32_at(main_base, live_offs[i] + 4);
    if (rlen >= 24 && compact_len + (rlen) <= compact_cap) {
      unsafe { memcpy(compact_buf + compact_len, main_base + (live_offs[i] as usize), rlen); }
      compact_len = compact_len + (rlen);
    }
    i = i + 1;
  }
  unsafe { free(live_offs as *u8); }
  unsafe { memset(main_base + (KV_SECTOR as usize), 0, (hdr.capacity - (KV_SECTOR as u64)) as usize); }
  unsafe { memcpy(main_base + (KV_SECTOR as usize), compact_buf, compact_len); }
  unsafe { free(compact_buf); }
  hdr.write_pos = (KV_SECTOR as u64) + (compact_len as u64);
  hdr.record_count = live_n;
  hdr.compact_gen = hdr.compact_gen + 1;
  kv_mt_clear(s);
  kv_rebuild_mt_from_map(s, main_base, hdr.capacity, hdr.write_pos, KV_LAYER_MAIN);
  if (kv_freeze_main_to_sst(s) != 0) { return -4; }
  kv_mt_clear(s);
  kv_rebuild_mt_from_map(s, main_base, hdr.capacity, hdr.write_pos, KV_LAYER_MAIN);
  i = 0;
  while (i < hdr.sst_count) {
    if (s.sst_hdr[i] != 0 as i64) {
      sh = s.sst_hdr[i] as *KvSstHeader;
      kv_rebuild_mt_from_map(s, s.sst_map[i] as *u8, sh.capacity, sh.write_pos, (KV_LAYER_SST_BASE + (i as u8)) as u8);
    }
    i = i + 1;
  }
  wh = s.wal_hdr as *KvWalHeader;
  if (wh != 0) { wh.write_pos = KV_SECTOR as u64; wh.record_count = 0; }
  unsafe { if (shu_kv_msync_c(s.map, s.map_size) == 0) { return 0; } }
  return -3;
}

function kv_db_smoke_impl(path: *u8): i32 {
  let h: i64 = 0;
  let key: u8[4] = [116, 105, 99, 107];
  let val: u8[8] = [1, 2, 3, 4, 5, 6, 7, 8];
  let out: u8[16] = [];
  let n: i32 = 0;
  h = kv_db_open_impl(path, 65536);
  if (h == 0 as i64) { return -1; }
  if (kv_db_append_wal(h as *KvStoreMem, &key[0], 4, &val[0], 8, 123456789 as u64) != 0) { kv_db_close_impl(h); return -2; }
  n = kv_db_get_impl(h, &key[0], 4, &out[0], 16);
  unsafe { if (n != 8 || memcmp(&out[0], &val[0], 8) != 0) { kv_db_close_impl(h); return -3; } }
  if (kv_db_wal_flush_impl(h) != 0) { kv_db_close_impl(h); return -4; }
  if (kv_db_compact_impl(h) != 0) { kv_db_close_impl(h); return -5; }
  if (db_kv_sst_level_count_c(h) == 0) { kv_db_close_impl(h); return -8; }
  n = kv_db_get_impl(h, &key[0], 4, &out[0], 16);
  unsafe { if (n != 8 || memcmp(&out[0], &val[0], 8) != 0) { kv_db_close_impl(h); return -6; } }
  val[0] = 42;
  if (kv_db_append_wal(h as *KvStoreMem, &key[0], 4, &val[0], 8, 999 as u64) != 0) { kv_db_close_impl(h); return -9; }
  if (kv_db_wal_flush_impl(h) != 0 || kv_db_compact_impl(h) != 0) { kv_db_close_impl(h); return -10; }
  n = kv_db_get_impl(h, &key[0], 4, &out[0], 16);
  if (n != 8 || out[0] != 42) { kv_db_close_impl(h); return -11; }
  if (kv_db_sync_impl(h) != 0) { kv_db_close_impl(h); return -7; }
  kv_db_close_impl(h);
  return 0;
}

#[cfg(target_os = "linux")]
function db_kv_open_c(path: *u8, capacity_bytes: u64): i64 { return kv_db_open_impl(path, capacity_bytes); }

#[cfg(target_os = "macos")]
function db_kv_open_c(path: *u8, capacity_bytes: u64): i64 { return kv_db_open_impl(path, capacity_bytes); }

#[cfg(target_os = "linux")]
function db_kv_close_c(handle: i64): i32 { return kv_db_close_impl(handle); }

#[cfg(target_os = "macos")]
function db_kv_close_c(handle: i64): i32 { return kv_db_close_impl(handle); }

#[cfg(target_os = "linux")]
function db_kv_sync_c(handle: i64): i32 { return kv_db_sync_impl(handle); }

#[cfg(target_os = "macos")]
function db_kv_sync_c(handle: i64): i32 { return kv_db_sync_impl(handle); }

function db_kv_put_c(handle: i64, key: *u8, key_len: u32, val: *u8, val_len: u32): i32 {
  return kv_db_append_wal(handle as *KvStoreMem, key, key_len, val, val_len, 0 as u64);
}

function db_kv_append_ts_c(handle: i64, key: *u8, key_len: u32, val: *u8, val_len: u32, ts_ns: u64): i32 {
  return kv_db_append_wal(handle as *KvStoreMem, key, key_len, val, val_len, ts_ns);
}

#[cfg(target_os = "linux")]
function db_kv_get_c(handle: i64, key: *u8, key_len: u32, out: *u8, out_cap: u32): i32 { return kv_db_get_impl(handle, key, key_len, out, out_cap); }

#[cfg(target_os = "macos")]
function db_kv_get_c(handle: i64, key: *u8, key_len: u32, out: *u8, out_cap: u32): i32 { return kv_db_get_impl(handle, key, key_len, out, out_cap); }

#[cfg(target_os = "linux")]
function db_kv_wal_flush_c(handle: i64): i32 { return kv_db_wal_flush_impl(handle); }

#[cfg(target_os = "macos")]
function db_kv_wal_flush_c(handle: i64): i32 { return kv_db_wal_flush_impl(handle); }

#[cfg(target_os = "linux")]
function db_kv_compact_c(handle: i64): i32 { return kv_db_compact_impl(handle); }

#[cfg(target_os = "macos")]
function db_kv_compact_c(handle: i64): i32 { return kv_db_compact_impl(handle); }

function db_kv_compact_gen_c(handle: i64): u64 {
  let s: *KvStoreMem = handle as *KvStoreMem;
  let hdr: *KvHeader = 0 as *KvHeader;
  if (s != 0 && s.hdr != 0 as i64) {
    hdr = s.hdr as *KvHeader;
    return hdr.compact_gen;
  }
  return 0;
}

function db_kv_wal_bytes_c(handle: i64): u64 {
  let s: *KvStoreMem = handle as *KvStoreMem;
  let wh: *KvWalHeader = 0 as *KvWalHeader;
  if (s == 0 || s.wal_hdr == 0 as i64) { return 0; }
  wh = s.wal_hdr as *KvWalHeader;
  if (wh.write_pos <= KV_SECTOR as u64) { return 0; }
  return wh.write_pos - (KV_SECTOR as u64);
}

function db_kv_sst_level_count_c(handle: i64): u32 {
  let s: *KvStoreMem = handle as *KvStoreMem;
  let hdr: *KvHeader = 0 as *KvHeader;
  if (s != 0 && s.hdr != 0 as i64) {
    hdr = s.hdr as *KvHeader;
    return hdr.sst_count;
  }
  return 0;
}

#[cfg(target_os = "linux")]
function db_kv_smoke_c(path: *u8): i32 { return kv_db_smoke_impl(path); }

#[cfg(target_os = "macos")]
function db_kv_smoke_c(path: *u8): i32 { return kv_db_smoke_impl(path); }

#[cfg(target_os = "linux")]
function db_kv_wal_compact_smoke_c(path: *u8): i32 { return kv_db_smoke_impl(path); }

#[cfg(target_os = "macos")]
function db_kv_wal_compact_smoke_c(path: *u8): i32 { return kv_db_smoke_impl(path); }
