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

export const CFG_OK: i32 = 0;
export const CFG_ERR_NULL: i32 = -1;
export const CFG_ERR_NOT_FOUND: i32 = -2;
export const CFG_ERR_INVALID: i32 = -3;
export const CFG_ERR_IO: i32 = -4;
export const CFG_ERR_FULL: i32 = -5;

export const CFG_MAX_ENTRIES: i32 = 64;
export const CFG_KEY_MAX: i32 = 128;
export const CFG_VAL_MAX: i32 = 256;
export const CFG_FILE_MAX: i32 = 65536;
export const CFG_SRC_LABEL_MAX: i32 = 64;
export const YAML_STACK_MAX: i32 = 8;
export const CFG_STORE_SIZE: usize = 29000;
export const YAML_CTX_SIZE: usize = 1200;

export const CFG_SRC_UNKNOWN: i32 = 0;
/* See implementation. */
export const CFG_LIT_TRUE: u8[5] = [116, 114, 117, 101, 0];
export const CFG_LIT_FALSE: u8[6] = [102, 97, 108, 115, 101, 0];
export const CFG_LIT_ONE: u8[2] = [49, 0];
export const CFG_LIT_ZERO: u8[2] = [48, 0];
export const CFG_LIT_YES: u8[4] = [121, 101, 115, 0];
export const CFG_LIT_ON: u8[3] = [111, 110, 0];
export const CFG_LIT_NO: u8[3] = [110, 111, 0];
export const CFG_LIT_OFF: u8[4] = [111, 102, 102, 0];
/* See implementation. */
export const CFG_LIT_N9090: u8[5] = [57, 48, 57, 48, 0];
export const CFG_LIT_XLANG_CFG_DEBUG: u8[16] = [88, 76, 65, 78, 71, 95, 67, 70, 71, 95, 100, 101, 98, 117, 103, 0];
export const CFG_LIT_ALPHA: u8[6] = [97, 108, 112, 104, 97, 0];
export const CFG_LIT_BETA: u8[5] = [98, 101, 116, 97, 0];
export const CFG_LIT_CLI: u8[4] = [99, 108, 105, 0];
export const CFG_LIT_DB_URL: u8[7] = [100, 98, 46, 117, 114, 108, 0];
export const CFG_LIT_DEBUG: u8[6] = [100, 101, 98, 117, 103, 0];
export const CFG_LIT_ITEMS_0: u8[8] = [105, 116, 101, 109, 115, 46, 48, 0];
export const CFG_LIT_ITEMS_1: u8[8] = [105, 116, 101, 109, 115, 46, 49, 0];
export const CFG_LIT_LOCALHOST: u8[10] = [108, 111, 99, 97, 108, 104, 111, 115, 116, 0];
export const CFG_LIT_PORT: u8[5] = [112, 111, 114, 116, 0];
export const CFG_LIT_SERVER_DB_PORT: u8[15] = [115, 101, 114, 118, 101, 114, 46, 100, 98, 46, 112, 111, 114, 116, 0];
export const CFG_LIT_SERVER_DB_URL: u8[14] = [115, 101, 114, 118, 101, 114, 46, 100, 98, 46, 117, 114, 108, 0];
export const CFG_LIT_SERVER_HOST: u8[12] = [115, 101, 114, 118, 101, 114, 46, 104, 111, 115, 116, 0];
export const CFG_LIT_SERVERS_0_HOST: u8[15] = [115, 101, 114, 118, 101, 114, 115, 46, 48, 46, 104, 111, 115, 116, 0];
export const CFG_LIT_SERVERS_0_PORT: u8[15] = [115, 101, 114, 118, 101, 114, 115, 46, 48, 46, 112, 111, 114, 116, 0];
export const CFG_LIT_SERVERS_1_HOST: u8[15] = [115, 101, 114, 118, 101, 114, 115, 46, 49, 46, 104, 111, 115, 116, 0];
export const CFG_LIT_SERVERS_1_PORT: u8[15] = [115, 101, 114, 118, 101, 114, 115, 46, 49, 46, 112, 111, 114, 116, 0];
export const CFG_LIT_SQLITE_MEM: u8[13] = [115, 113, 108, 105, 116, 101, 58, 47, 47, 109, 101, 109, 0];
export const CFG_LIT_TOML: u8[5] = [116, 111, 109, 108, 0];
export const CFG_LIT_YAML: u8[5] = [121, 97, 109, 108, 0];

export const CFG_SRC_TOML: i32 = 1;
export const CFG_SRC_YAML: i32 = 2;
export const CFG_SRC_ENV: i32 = 3;
export const CFG_SRC_SET: i32 = 4;

/* See implementation. */
allow(padding) struct CfgEntry {
  key: u8[128];
  val: u8[256];
  source_kind: i32;
  source_label: u8[64];
}

/* See implementation. */
allow(padding) struct CfgStore {
  entries: CfgEntry[64];
  count: i32;
  active_source_kind: i32;
  active_source_label: u8[64];
}

/* See implementation. */
allow(padding) struct YamlFrame {
  name: u8[128];
  indent: i32;
}

/* See implementation. */
allow(padding) struct YamlParseCtx {
  stack: YamlFrame[8];
  depth: i32;
  list_prefix: u8[128];
  list_index: i32;
  list_indent: i32;
}

extern function env_iter_count_c(): i32;
extern function env_iter_at_c(index: i32, key_out: *u8, key_cap: i32, val_out: *u8, val_cap: i32): i32;
extern function env_setenv_c(name: *u8, value: *u8, overwrite: i32): i32;
extern "C" function fs_open_read_c(path: *u8): i32;
extern "C" function fs_posix_read_c(fd: i32, buf: *u8, count: usize): i64;
extern "C" function close(fd: i32): i32;

extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
extern "C" function memset(s: *u8, c: i32, n: usize): *u8;
extern "C" function calloc(nmemb: usize, size: usize): *u8;
extern "C" function free(ptr: *u8): void;
extern "C" function strcmp(a: *u8, b: *u8): i32;
extern "C" function strncmp(a: *u8, b: *u8, n: usize): i32;
extern "C" function strlen(s: *u8): usize;
extern "C" function strchr(s: *u8, c: i32): *u8;

/** Exported function `config_f_config_v1_marker_c`.
 * Implements `config_f_config_v1_marker_c`.
 * @return i32
 */
export function config_f_config_v1_marker_c(): i32 {
  return 1;
}

/** Exported function `config_f_config_v2_marker_c`.
 * Implements `config_f_config_v2_marker_c`.
 * @return i32
 */
export function config_f_config_v2_marker_c(): i32 {
  return 1;
}

/** Exported function `config_f_zero_c_marker_c`.
 * Implements `config_f_zero_c_marker_c`.
 * @return i32
 */
export function config_f_zero_c_marker_c(): i32 {
  return 1;
}

/**
 * See implementation.
 * See implementation.
 */
export function config_read_file_c(path: *u8, out_buf: *u8, out_cap: i32): i32 {
  let fd: i32 = 0;
  let total: i32 = 0;
  let n: i64 = 0;
  let chunk: i32 = 4096;
  let to_read: i32 = 0;
  let extra: u8 = 0;
  if (path == 0 || out_buf == 0 || out_cap <= 0) { return -1; }
  unsafe { fd = fs_open_read_c(path); }
  if (fd < 0) { return -4; }
  while (total < out_cap - 1) {
    to_read = out_cap - 1 - total;
    if (to_read > chunk) { to_read = chunk; }
    unsafe { n = fs_posix_read_c(fd, out_buf + total, to_read); }
    if (n < 0) { unsafe { close(fd); } return -4; }
    if (n == 0) { break; }
    total = total + (n as i32);
    if (total > CFG_FILE_MAX) { unsafe { close(fd); } return -4; }
  }
  unsafe { n = fs_posix_read_c(fd, &extra, 1); }
  unsafe { close(fd); }
  if (n > 0) { return -4; }
  out_buf[total] = 0;
  return total;
}

/** Exported function `config_smoke_setenv_c`.
 * Implements `config_smoke_setenv_c`.
 * @param key *u8
 * @param val *u8
 * @return i32
 */
export function config_smoke_setenv_c(key: *u8, val: *u8): i32 {
  unsafe { return env_setenv_c(key, val, 1); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `cfg_from_handle`.
 * Implements `cfg_from_handle`.
 * @param handle i64
 * @return *CfgStore
 */
export function cfg_from_handle(handle: i64): *CfgStore {
  if (handle == 0) { return 0 as *CfgStore; }
  return handle as *CfgStore;
}

/** Exported function `cfg_isspace`.
 * Implements `cfg_isspace`.
 * @param c u8
 * @return i32
 */
export function cfg_isspace(c: u8): i32 {
  if (c == 32 || c == 9 || c == 10 || c == 13 || c == 12) { return 1; }
  return 0;
}

/** Exported function `cfg_isalnum`.
 * Implements `cfg_isalnum`.
 * @param c u8
 * @return i32
 */
export function cfg_isalnum(c: u8): i32 {
  if ((c >= 48 && c <= 57) || (c >= 65 && c <= 90) || (c >= 97 && c <= 122)) { return 1; }
  return 0;
}

/** Exported function `cfg_strncpy`.
 * Implements `cfg_strncpy`.
 * @param dst *u8
 * @param src *u8
 * @param cap i32
 * @return i32
 */
export function cfg_strncpy(dst: *u8, src: *u8, cap: i32): i32 {
  let n: i32 = 0;
  if (dst == 0 || src == 0 || cap <= 0) { return CFG_ERR_NULL; }
  while (n + 1 < cap && src[n] != 0) {
    dst[n] = src[n];
    n = n + 1;
  }
  dst[n] = 0;
  return CFG_OK;
}

/** Exported function `cfg_trim`.
 * Implements `cfg_trim`.
 * @param s *u8
 * @param out_len *i32
 * @return *u8
 */
export function cfg_trim(s: *u8, out_len: *i32): *u8 {
  let start: i32 = 0;
  let end: i32 = 0;
  if (s == 0) {
    if (out_len != 0) { *out_len = 0; }
    return s;
  }
  while (s[start] != 0 && cfg_isspace(s[start]) != 0) { start = start + 1; }
  unsafe { end = strlen(s + start) as i32; }
  while (end > 0 && cfg_isspace(s[(start + end - 1)]) != 0) { end = end - 1; }
  if (out_len != 0) { *out_len = end; }
  return s + start;
}

/** Exported function `cfg_find_index`.
 * Implements `cfg_find_index`.
 * @param store *CfgStore
 * @param key *u8
 * @return i32
 */
export function cfg_find_index(store: *CfgStore, key: *u8): i32 {
  let i: i32 = 0;
  if (store == 0 || key == 0) { return -1; }
  while (i < store.count) {
    unsafe { if (strcmp(&store.entries[i].key[0], key) == 0) { return i; } }
    i = i + 1;
  }
  return -1;
}

/* See implementation. */
export function cfg_set_raw_ex(store: *CfgStore, key: *u8, val: *u8, override: i32,
                      src_kind: i32, src_label: *u8): i32 {
  let idx: i32 = 0;
  if (store == 0 || key == 0 || val == 0) { return CFG_ERR_NULL; }
  if (key[0] == 0) { return CFG_ERR_INVALID; }
  idx = cfg_find_index(store, key);
  if (idx >= 0) {
    if (override == 0) { return CFG_OK; }
    cfg_strncpy(&store.entries[idx].val[0], val, CFG_VAL_MAX);
    store.entries[idx].source_kind = src_kind;
    if (src_label != 0) {
      cfg_strncpy(&store.entries[idx].source_label[0], src_label, CFG_SRC_LABEL_MAX);
    } else {
      store.entries[idx].source_label[0] = 0;
    }
    return CFG_OK;
  }
  if (store.count >= CFG_MAX_ENTRIES) { return CFG_ERR_FULL; }
  cfg_strncpy(&store.entries[store.count].key[0], key, CFG_KEY_MAX);
  cfg_strncpy(&store.entries[store.count].val[0], val, CFG_VAL_MAX);
  store.entries[store.count].source_kind = src_kind;
  if (src_label != 0) {
    cfg_strncpy(&store.entries[store.count].source_label[0], src_label, CFG_SRC_LABEL_MAX);
  } else {
    store.entries[store.count].source_label[0] = 0;
  }
  store.count = store.count + 1;
  return CFG_OK;
}

/** Exported function `cfg_set_raw`.
 * Implements `cfg_set_raw`.
 * @param store *CfgStore
 * @param key *u8
 * @param val *u8
 * @param override i32
 * @return i32
 */
export function cfg_set_raw(store: *CfgStore, key: *u8, val: *u8, override: i32): i32 {
  if (store == 0) { return CFG_ERR_NULL; }
  return cfg_set_raw_ex(store, key, val, override, store.active_source_kind,
                        &store.active_source_label[0]);
}

/** Exported function `cfg_parse_quoted`.
 * Implements `cfg_parse_quoted`.
 * @param src *u8
 * @param len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function cfg_parse_quoted(src: *u8, len: i32, out: *u8, out_cap: i32): i32 {
  let i: i32 = 1;
  let o: i32 = 0;
  if (len < 2 || src[0] != 34 || src[(len - 1)] != 34) { return CFG_ERR_INVALID; }
  while (i < len - 1) {
    let c: u8 = src[i];
    if (c == 92 && i + 1 < len - 1) {
      let e: u8 = src[(i + 1)];
      if (o + 1 >= out_cap) { return CFG_ERR_INVALID; }
      if (e == 110) { out[o] = 10; }
      else if (e == 116) { out[o] = 9; }
      else if (e == 114) { out[o] = 13; }
      else { out[o] = e; }
      o = o + 1;
      i = i + 2;
    } else {
      if (o + 1 >= out_cap) { return CFG_ERR_INVALID; }
      out[o] = c;
      o = o + 1;
      i = i + 1;
    }
  }
  out[o] = 0;
  return CFG_OK;
}

/** Exported function `cfg_normalize_value`.
 * Implements `cfg_normalize_value`.
 * @param raw *u8
 * @param raw_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function cfg_normalize_value(raw: *u8, raw_len: i32, out: *u8, out_cap: i32): i32 {
  let tl: i32 = 0;
  let t: *u8 = 0;
  t = cfg_trim(raw, &tl);
  if (tl <= 0) { return CFG_ERR_INVALID; }
  if (t[0] == 34) { return cfg_parse_quoted(t, tl, out, out_cap); }
  unsafe { if (tl >= 4 && strncmp(t, &CFG_LIT_TRUE[0], 4) == 0 && tl == 4) {
    cfg_strncpy(out, &CFG_LIT_TRUE[0], out_cap);
    return CFG_OK;
  } }
  unsafe { if (tl >= 5 && strncmp(t, &CFG_LIT_FALSE[0], 5) == 0 && tl == 5) {
    cfg_strncpy(out, &CFG_LIT_FALSE[0], out_cap);
    return CFG_OK;
  } }
  if (tl >= out_cap) { return CFG_ERR_INVALID; }
  unsafe { memcpy(out, t, tl); }
  out[tl] = 0;
  return CFG_OK;
}

/** Exported function `cfg_build_key_prefix`.
 * Implements `cfg_build_key_prefix`.
 * @param prefix *u8
 * @param key_start *u8
 * @param key_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function cfg_build_key_prefix(prefix: *u8, key_start: *u8, key_len: i32, out: *u8, out_cap: i32): i32 {
  let pos: i32 = 0;
  let plen: i32 = 0;
  if (key_start == 0 || out == 0) { return CFG_ERR_NULL; }
  if (prefix != 0 && prefix[0] != 0) {
    unsafe { plen = strlen(prefix) as i32; }
    if (plen + 1 + key_len >= out_cap) { return CFG_ERR_INVALID; }
    unsafe { memcpy(out, prefix, plen); }
    pos = plen;
    out[pos] = 46;
    pos = pos + 1;
  } else {
    if (key_len >= out_cap) { return CFG_ERR_INVALID; }
  }
  unsafe { memcpy(out + pos, key_start, key_len); }
  out[(pos + key_len)] = 0;
  return CFG_OK;
}

/** Exported function `cfg_append_i32`.
 * Implements `cfg_append_i32`.
 * @param out *u8
 * @param pos i32
 * @param cap i32
 * @param v i32
 * @return i32
 */
export function cfg_append_i32(out: *u8, pos: i32, cap: i32, v: i32): i32 {
  let tmp: u8[16] = [];
  let n: i32 = 0;
  let x: i32 = v;
  if (out == 0 || pos < 0 || cap <= pos) { return -1; }
  if (x == 0) {
    if (pos + 1 >= cap) { return -1; }
    out[pos] = 48;
    return pos + 1;
  }
  while (x > 0) {
    tmp[n] = (48 + (x % 10)) as u8;
    n = n + 1;
    x = x / 10;
  }
  while (n > 0) {
    n = n - 1;
    if (pos >= cap) { return -1; }
    out[pos] = tmp[n];
    pos = pos + 1;
  }
  return pos;
}

/** Exported function `cfg_build_array_section`.
 * Implements `cfg_build_array_section`.
 * @param name *u8
 * @param index i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function cfg_build_array_section(name: *u8, index: i32, out: *u8, out_cap: i32): i32 {
  let pos: i32 = 0;
  let nl: i32 = 0;
  if (name == 0 || out == 0) { return CFG_ERR_NULL; }
  unsafe { nl = strlen(name) as i32; }
  if (nl + 2 >= out_cap) { return CFG_ERR_INVALID; }
  unsafe { memcpy(out, name, nl); }
  pos = nl;
  out[pos] = 46;
  pos = pos + 1;
  pos = cfg_append_i32(out, pos, out_cap, index);
  if (pos < 0) { return CFG_ERR_INVALID; }
  out[pos] = 0;
  return CFG_OK;
}

/** Exported function `cfg_build_list_key`.
 * Implements `cfg_build_list_key`.
 * @param prefix *u8
 * @param index i32
 * @param field *u8
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function cfg_build_list_key(prefix: *u8, index: i32, field: *u8, out: *u8, out_cap: i32): i32 {
  let pos: i32 = 0;
  let pl: i32 = 0;
  let fl: i32 = 0;
  if (prefix == 0 || out == 0) { return CFG_ERR_NULL; }
  unsafe { pl = strlen(prefix) as i32; }
  if (pl + 2 >= out_cap) { return CFG_ERR_INVALID; }
  unsafe { memcpy(out, prefix, pl); }
  pos = pl;
  out[pos] = 46;
  pos = pos + 1;
  pos = cfg_append_i32(out, pos, out_cap, index);
  if (pos < 0) { return CFG_ERR_INVALID; }
  if (field != 0 && field[0] != 0) {
    unsafe { fl = strlen(field) as i32; }
    if (pos + 1 + fl >= out_cap) { return CFG_ERR_INVALID; }
    out[pos] = 46;
    pos = pos + 1;
    unsafe { memcpy(out + pos, field, fl); }
    pos = pos + fl;
  }
  out[pos] = 0;
  return CFG_OK;
}


/** Exported function `cfg_parse_kv_line`.
 * Implements `cfg_parse_kv_line`.
 * @param store *CfgStore
 * @param line *u8
 * @param section_prefix *u8
 * @param override i32
 * @return i32
 */
export function cfg_parse_kv_line(store: *CfgStore, line: *u8, section_prefix: *u8, override: i32): i32 {
  let key_full: u8[128] = [];
  let val_buf: u8[256] = [];
  let eq: *u8 = 0;
  let key_start: *u8 = 0;
  let key_len: i32 = 0;
  let val_len: i32 = 0;
  let val_part: *u8 = 0;
  if (store == 0 || line == 0) { return CFG_ERR_NULL; }
  unsafe { eq = strchr(line, 61); }
  if (eq == 0) { return CFG_OK; }
  key_start = line;
  while (key_start[0] != 0 && cfg_isspace(key_start[0]) != 0) { key_start = key_start + 1; }
  key_len = (eq - key_start) as i32;
  while (key_len > 0 && cfg_isspace(key_start[(key_len - 1)]) != 0) { key_len = key_len - 1; }
  val_part = cfg_trim(eq + 1, &val_len);
  if (key_len <= 0 || val_len <= 0) { return CFG_ERR_INVALID; }
  if (cfg_build_key_prefix(section_prefix, key_start, key_len, &key_full[0], CFG_KEY_MAX) != CFG_OK) {
    return CFG_ERR_INVALID;
  }
  if (cfg_normalize_value(val_part, val_len, &val_buf[0], CFG_VAL_MAX) != CFG_OK) { return CFG_ERR_INVALID; }
  return cfg_set_raw(store, &key_full[0], &val_buf[0], override);
}

/** Exported function `cfg_parse_section`.
 * Implements `cfg_parse_section`.
 * @param line *u8
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function cfg_parse_section(line: *u8, out: *u8, out_cap: i32): i32 {
  let len: i32 = 0;
  let t: *u8 = 0;
  let i: i32 = 0;
  t = cfg_trim(line, &len);
  if (len < 3 || t[0] != 91 || t[(len - 1)] != 93) { return 0; }
  if (len >= 4 && t[1] == 91) { return 0; }
  len = len - 2;
  if (len <= 0 || len >= out_cap) { return CFG_ERR_INVALID; }
  while (i < len) {
    let c: u8 = t[(i + 1)];
    if (cfg_isalnum(c) == 0 && c != 95 && c != 46) { return CFG_ERR_INVALID; }
    out[i] = c;
    i = i + 1;
  }
  out[i] = 0;
  return 1;
}

/** Exported function `cfg_parse_array_section`.
 * Implements `cfg_parse_array_section`.
 * @param line *u8
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function cfg_parse_array_section(line: *u8, out: *u8, out_cap: i32): i32 {
  let len: i32 = 0;
  let t: *u8 = 0;
  let i: i32 = 0;
  let inner_len: i32 = 0;
  t = cfg_trim(line, &len);
  if (len < 4 || t[0] != 91 || t[1] != 91 || t[(len - 2)] != 93 || t[(len - 1)] != 93) {
    return 0;
  }
  inner_len = len - 4;
  if (inner_len <= 0 || inner_len >= out_cap) { return CFG_ERR_INVALID; }
  while (i < inner_len) {
    let c: u8 = t[(i + 2)];
    if (cfg_isalnum(c) == 0 && c != 95 && c != 46) { return CFG_ERR_INVALID; }
    out[i] = c;
    i = i + 1;
  }
  out[i] = 0;
  return 2;
}

/** Exported function `cfg_load_toml_buf_impl`.
 * Implements `cfg_load_toml_buf_impl`.
 * @param store *CfgStore
 * @param buf *u8
 * @param len i32
 * @param override i32
 * @return i32
 */
export function cfg_load_toml_buf_impl(store: *CfgStore, buf: *u8, len: i32, override: i32): i32 {
  let section: u8[128] = [];
  let array_name: u8[128] = [];
  let array_index: i32 = -1;
  let line: u8[512] = [];
  let i: i32 = 0;
  let line_pos: i32 = 0;
  if (store == 0 || buf == 0 || len < 0) { return CFG_ERR_NULL; }
  section[0] = 0;
  array_name[0] = 0;
  while (i <= len) {
    let c: u8 = 10;
    if (i < len) { c = buf[i]; }
    if (c == 13) { i = i + 1; continue; }
    if (c == 10 || c == 0) {
      line[line_pos] = 0;
      if (line_pos > 0) {
        let sl: i32 = 0;
        let t: *u8 = cfg_trim(&line[0], &sl);
        if (sl > 0 && t[0] != 35) {
          let parsed_array: u8[128] = [];
          let arr: i32 = cfg_parse_array_section(t, &parsed_array[0], CFG_KEY_MAX);
          if (arr < 0) { return CFG_ERR_INVALID; }
          if (arr == 2) {
            unsafe { if (array_index >= 0 && strcmp(&array_name[0], &parsed_array[0]) == 0) {
              array_index = array_index + 1;
            } else {
              array_index = 0;
              cfg_strncpy(&array_name[0], &parsed_array[0], CFG_KEY_MAX);
            } }
            if (cfg_build_array_section(&array_name[0], array_index, &section[0], CFG_KEY_MAX) != CFG_OK) {
              return CFG_ERR_INVALID;
            }
          } else {
            let sec: i32 = cfg_parse_section(t, &section[0], CFG_KEY_MAX);
            if (sec < 0) { return CFG_ERR_INVALID; }
            if (sec == 1) {
              array_index = -1;
              array_name[0] = 0;
            }
            if (sec == 0) {
              let sp: *u8 = 0;
              if (section[0] != 0) { sp = &section[0]; }
              let r: i32 = cfg_parse_kv_line(store, t, sp, override);
              if (r != CFG_OK) { return r; }
            }
          }
        }
      }
      line_pos = 0;
      i = i + 1;
      continue;
    }
    if (line_pos + 1 >= 512) { return CFG_ERR_INVALID; }
    line[line_pos] = c;
    line_pos = line_pos + 1;
    i = i + 1;
  }
  return CFG_OK;
}


/** Exported function `config_load_toml_buf_c`.
 * Implements `config_load_toml_buf_c`.
 * @param handle i64
 * @param buf *u8
 * @param len i32
 * @param override i32
 * @return i32
 */
export function config_load_toml_buf_c(handle: i64, buf: *u8, len: i32, override: i32): i32 {
  let store: *CfgStore = cfg_from_handle(handle);
  if (store == 0 || buf == 0 || len < 0) { return CFG_ERR_NULL; }
  store.active_source_kind = CFG_SRC_TOML;
  cfg_strncpy(&store.active_source_label[0], &CFG_LIT_TOML[0], CFG_SRC_LABEL_MAX);
  return cfg_load_toml_buf_impl(store, buf, len, override);
}

/** Exported function `config_load_toml_file_c`.
 * Implements `config_load_toml_file_c`.
 * @param handle i64
 * @param path *u8
 * @param override i32
 * @return i32
 */
export function config_load_toml_file_c(handle: i64, path: *u8, override: i32): i32 {
  let store: *CfgStore = cfg_from_handle(handle);
  let buf: *u8 = 0;
  let sz: i32 = 0;
  let r: i32 = 0;
  if (path == 0) { return CFG_ERR_NULL; }
  unsafe { buf = calloc((CFG_FILE_MAX + 1), 1); }
  if (buf == 0) { return CFG_ERR_IO; }
  sz = config_read_file_c(path, buf, CFG_FILE_MAX + 1);
  if (sz < 0) { unsafe { free(buf); } return CFG_ERR_IO; }
  if (store != 0) {
    store.active_source_kind = CFG_SRC_TOML;
    cfg_strncpy(&store.active_source_label[0], path, CFG_SRC_LABEL_MAX);
  }
  r = cfg_load_toml_buf_impl(store, buf, sz, override);
  unsafe { free(buf); }
  return r;
}

/** Exported function `config_load_env_prefix_c`.
 * Implements `config_load_env_prefix_c`.
 * @param handle i64
 * @param prefix *u8
 * @param prefix_len i32
 * @param override i32
 * @return i32
 */
export function config_load_env_prefix_c(handle: i64, prefix: *u8, prefix_len: i32, override: i32): i32 {
  let store: *CfgStore = cfg_from_handle(handle);
  let pfx: u8[128] = [];
  let n: i32 = 0;
  let loaded: i32 = 0;
  let key_buf: u8[256] = [];
  let val_buf: u8[256] = [];
  let i: i32 = 0;
  if (store == 0 || prefix == 0 || prefix_len <= 0 || prefix_len >= 128) { return CFG_ERR_NULL; }
  unsafe { memcpy(&pfx[0], prefix, prefix_len); }
  pfx[prefix_len] = 0;
  unsafe { n = env_iter_count_c(); }
  while (i < n) {
    let r: i32 = 0;
    unsafe { r = env_iter_at_c(i, &key_buf[0], 256, &val_buf[0], 256); }
    if (r == 1) {
      unsafe { if (strncmp(&key_buf[0], &pfx[0], prefix_len) == 0) {
        let sub: *u8 = &key_buf[prefix_len];
        if (sub[0] != 0) {
          if (cfg_set_raw_ex(store, sub, &val_buf[0], override, CFG_SRC_ENV, &key_buf[0]) == CFG_OK) {
            loaded = loaded + 1;
          }
        }
      } }
    }
    i = i + 1;
  }
  return loaded;
}

/** Exported function `config_create_c`.
 * Implements `config_create_c`.
 * @return i64
 */
export function config_create_c(): i64 {
  let s: *u8 = 0;
  unsafe { s = calloc(1, CFG_STORE_SIZE); }
  if (s == 0) { return 0; }
  return s as i64;
}

/** Exported function `config_free_c`.
 * Memory management helper `config_free_c`.
 * @param handle i64
 * @return void
 */
export function config_free_c(handle: i64): void {
  let s: *CfgStore = cfg_from_handle(handle);
  if (s != 0) { unsafe { free(s as *u8); } }
}

/** Exported function `config_clear_c`.
 * Implements `config_clear_c`.
 * @param handle i64
 * @return void
 */
export function config_clear_c(handle: i64): void {
  let s: *CfgStore = cfg_from_handle(handle);
  if (s != 0) { s.count = 0; }
}

/** Exported function `config_merge_c`.
 * Implements `config_merge_c`.
 * @param dst_handle i64
 * @param src_handle i64
 * @param override i32
 * @return i32
 */
export function config_merge_c(dst_handle: i64, src_handle: i64, override: i32): i32 {
  let dst: *CfgStore = cfg_from_handle(dst_handle);
  let src: *CfgStore = cfg_from_handle(src_handle);
  let i: i32 = 0;
  if (dst == 0 || src == 0) { return CFG_ERR_NULL; }
  while (i < src.count) {
    let r: i32 = cfg_set_raw_ex(dst, &src.entries[i].key[0], &src.entries[i].val[0],
                                override, src.entries[i].source_kind,
                                &src.entries[i].source_label[0]);
    if (r != CFG_OK) { return r; }
    i = i + 1;
  }
  return CFG_OK;
}

/** Exported function `config_set_string_c`.
 * Implements `config_set_string_c`.
 * @param handle i64
 * @param key *u8
 * @param key_len i32
 * @param val *u8
 * @param val_len i32
 * @return i32
 */
export function config_set_string_c(handle: i64, key: *u8, key_len: i32, val: *u8, val_len: i32): i32 {
  let store: *CfgStore = cfg_from_handle(handle);
  let k: u8[128] = [];
  let v: u8[256] = [];
  if (store == 0 || key == 0 || key_len <= 0 || val == 0 || val_len < 0) { return CFG_ERR_NULL; }
  if (key_len >= CFG_KEY_MAX || val_len >= CFG_VAL_MAX) { return CFG_ERR_INVALID; }
  unsafe { memcpy(&k[0], key, key_len); }
  k[key_len] = 0;
  if (val_len == 0) { v[0] = 0; }
  else {
    unsafe { memcpy(&v[0], val, val_len); }
    v[val_len] = 0;
  }
  return cfg_set_raw_ex(store, &k[0], &v[0], 1, CFG_SRC_SET, &CFG_LIT_CLI[0]);
}

/** Exported function `config_get_string_c`.
 * Implements `config_get_string_c`.
 * @param handle i64
 * @param key *u8
 * @param key_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function config_get_string_c(handle: i64, key: *u8, key_len: i32, out: *u8, out_cap: i32): i32 {
  let store: *CfgStore = cfg_from_handle(handle);
  let idx: i32 = 0;
  let k: u8[128] = [];
  let len: usize = 0;
  if (store == 0 || key == 0 || key_len <= 0 || out == 0 || out_cap <= 0) { return CFG_ERR_NULL; }
  if (key_len >= CFG_KEY_MAX) { return CFG_ERR_INVALID; }
  unsafe { memcpy(&k[0], key, key_len); }
  k[key_len] = 0;
  idx = cfg_find_index(store, &k[0]);
  if (idx < 0) { return CFG_ERR_NOT_FOUND; }
  unsafe { len = strlen(&store.entries[idx].val[0]); }
  if (len as i32 >= out_cap) {
    unsafe { memcpy(out, &store.entries[idx].val[0], (out_cap - 1) as usize); }
    out[(out_cap - 1)] = 0;
    return len as i32;
  }
  unsafe { memcpy(out, &store.entries[idx].val[0], len + 1); }
  return len as i32;
}

/** Exported function `cfg_parse_i32_str`.
 * Implements `cfg_parse_i32_str`.
 * @param s *u8
 * @param out *i32
 * @return i32
 */
export function cfg_parse_i32_str(s: *u8, out: *i32): i32 {
  let i: i32 = 0;
  let sign: i32 = 1;
  let v: i64 = 0;
  let started: i32 = 0;
  if (s == 0 || out == 0) { return CFG_ERR_NULL; }
  while (s[i] != 0 && cfg_isspace(s[i]) != 0) { i = i + 1; }
  if (s[i] == 45) { sign = -1; i = i + 1; }
  else if (s[i] == 43) { i = i + 1; }
  while (s[i] != 0) {
    let c: u8 = s[i];
    if (c >= 48 && c <= 57) {
      started = 1;
      v = v * 10 + (c - 48);
      i = i + 1;
    } else { break; }
  }
  if (started == 0) { return CFG_ERR_INVALID; }
  while (s[i] != 0) {
    if (cfg_isspace(s[i]) == 0) { return CFG_ERR_INVALID; }
    i = i + 1;
  }
  out[0] = (v * sign) as i32;
  return CFG_OK;
}

/** Exported function `config_get_i32_c`.
 * Implements `config_get_i32_c`.
 * @param handle i64
 * @param key *u8
 * @param key_len i32
 * @param out *i32
 * @return i32
 */
export function config_get_i32_c(handle: i64, key: *u8, key_len: i32, out: *i32): i32 {
  let store: *CfgStore = cfg_from_handle(handle);
  let idx: i32 = 0;
  let k: u8[128] = [];
  if (store == 0 || key == 0 || key_len <= 0 || out == 0) { return CFG_ERR_NULL; }
  if (key_len >= CFG_KEY_MAX) { return CFG_ERR_INVALID; }
  unsafe { memcpy(&k[0], key, key_len); }
  k[key_len] = 0;
  idx = cfg_find_index(store, &k[0]);
  if (idx < 0) { return CFG_ERR_NOT_FOUND; }
  return cfg_parse_i32_str(&store.entries[idx].val[0], out);
}

/** Exported function `config_get_bool_c`.
 * Implements `config_get_bool_c`.
 * @param handle i64
 * @param key *u8
 * @param key_len i32
 * @param out *i32
 * @return i32
 */
export function config_get_bool_c(handle: i64, key: *u8, key_len: i32, out: *i32): i32 {
  let store: *CfgStore = cfg_from_handle(handle);
  let idx: i32 = 0;
  let k: u8[128] = [];
  let v: *u8 = 0;
  if (store == 0 || key == 0 || key_len <= 0 || out == 0) { return CFG_ERR_NULL; }
  if (key_len >= CFG_KEY_MAX) { return CFG_ERR_INVALID; }
  unsafe { memcpy(&k[0], key, key_len); }
  k[key_len] = 0;
  idx = cfg_find_index(store, &k[0]);
  if (idx < 0) { return CFG_ERR_NOT_FOUND; }
  v = &store.entries[idx].val[0];
  unsafe { if (strcmp(v, &CFG_LIT_TRUE[0]) == 0 || strcmp(v, &CFG_LIT_ONE[0]) == 0 ||
      strcmp(v, &CFG_LIT_YES[0]) == 0 || strcmp(v, &CFG_LIT_ON[0]) == 0) {
    out[0] = 1;
    return CFG_OK;
  } }
  unsafe { if (strcmp(v, &CFG_LIT_FALSE[0]) == 0 || strcmp(v, &CFG_LIT_ZERO[0]) == 0 ||
      strcmp(v, &CFG_LIT_NO[0]) == 0 || strcmp(v, &CFG_LIT_OFF[0]) == 0) {
    out[0] = 0;
    return CFG_OK;
  } }
  return CFG_ERR_INVALID;
}

/** Function `config_get_source_c`.
 * Purpose: implements `config_get_source_c`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
export function config_get_source_c(handle: i64, key: *u8, key_len: i32, out_kind: *i32,
                             out_label: *u8, label_cap: i32): i32 {
  let store: *CfgStore = cfg_from_handle(handle);
  let idx: i32 = 0;
  let k: u8[128] = [];
  if (store == 0 || key == 0 || key_len <= 0 || out_kind == 0) { return CFG_ERR_NULL; }
  if (key_len >= CFG_KEY_MAX) { return CFG_ERR_INVALID; }
  unsafe { memcpy(&k[0], key, key_len); }
  k[key_len] = 0;
  idx = cfg_find_index(store, &k[0]);
  if (idx < 0) { return CFG_ERR_NOT_FOUND; }
  out_kind[0] = store.entries[idx].source_kind;
  if (out_label != 0 && label_cap > 0) {
    cfg_strncpy(out_label, &store.entries[idx].source_label[0], label_cap);
  }
  return CFG_OK;
}

/** Function `config_get_i32_meta_c`.
 * Purpose: implements `config_get_i32_meta_c`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
export function config_get_i32_meta_c(handle: i64, key: *u8, key_len: i32, out_val: *i32,
                               out_kind: *i32, out_label: *u8, label_cap: i32): i32 {
  let r: i32 = config_get_i32_c(handle, key, key_len, out_val);
  if (r != CFG_OK || out_kind == 0) { return r; }
  return config_get_source_c(handle, key, key_len, out_kind, out_label, label_cap);
}

/** Function `config_get_bool_meta_c`.
 * Purpose: implements `config_get_bool_meta_c`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
export function config_get_bool_meta_c(handle: i64, key: *u8, key_len: i32, out_val: *i32,
                                out_kind: *i32, out_label: *u8, label_cap: i32): i32 {
  let r: i32 = config_get_bool_c(handle, key, key_len, out_val);
  if (r != CFG_OK || out_kind == 0) { return r; }
  return config_get_source_c(handle, key, key_len, out_kind, out_label, label_cap);
}

/** Function `config_get_string_meta_c`.
 * Purpose: implements `config_get_string_meta_c`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
export function config_get_string_meta_c(handle: i64, key: *u8, key_len: i32, out: *u8, out_cap: i32,
                                  out_kind: *i32, out_label: *u8, label_cap: i32): i32 {
  let r: i32 = config_get_string_c(handle, key, key_len, out, out_cap);
  if (r < 0 || out_kind == 0) { return r; }
  if (config_get_source_c(handle, key, key_len, out_kind, out_label, label_cap) != CFG_OK) {
    out_kind[0] = CFG_SRC_UNKNOWN;
  }
  return r;
}


/** Exported function `cfg_yaml_indent`.
 * Implements `cfg_yaml_indent`.
 * @param line *u8
 * @return i32
 */
export function cfg_yaml_indent(line: *u8): i32 {
  let n: i32 = 0;
  if (line == 0) { return 0; }
  while (line[n] == 32) { n = n + 1; }
  if (line[n] == 9) { n = n + 2; }
  return n;
}

/** Exported function `cfg_yaml_pop_to`.
 * Implements `cfg_yaml_pop_to`.
 * @param stack *YamlFrame
 * @param depth *i32
 * @param target_indent i32
 * @return void
 */
export function cfg_yaml_pop_to(stack: *YamlFrame, depth: *i32, target_indent: i32): void {
  while (*depth > 0 && stack[(*depth - 1)].indent >= target_indent) {
    depth[0] = depth[0] - 1;
  }
}

/** Exported function `cfg_yaml_build_key`.
 * Implements `cfg_yaml_build_key`.
 * @param stack *YamlFrame
 * @param depth i32
 * @param local *u8
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function cfg_yaml_build_key(stack: *YamlFrame, depth: i32, local: *u8, out: *u8, out_cap: i32): i32 {
  let pos: i32 = 0;
  let i: i32 = 0;
  if (local == 0 || out == 0 || out_cap <= 0) { return CFG_ERR_NULL; }
  while (i < depth) {
    let sl: usize = 0;
    unsafe { sl = strlen(&stack[i].name[0]); }
    if (sl == 0) { return CFG_ERR_INVALID; }
    if (pos > 0) {
      if (pos + 1 >= out_cap) { return CFG_ERR_INVALID; }
      out[pos] = 46;
      pos = pos + 1;
    }
    if (pos + sl as i32 >= out_cap) { return CFG_ERR_INVALID; }
    unsafe { memcpy(out + pos, &stack[i].name[0], sl); }
    pos = pos + sl as i32;
    i = i + 1;
  }
  if (local[0] == 0) { return CFG_ERR_INVALID; }
  if (pos > 0) {
    if (pos + 1 >= out_cap) { return CFG_ERR_INVALID; }
    out[pos] = 46;
    pos = pos + 1;
  }
  let ll: usize = 0;
  unsafe { ll = strlen(local); }
  if (pos + ll as i32 >= out_cap) { return CFG_ERR_INVALID; }
  unsafe { memcpy(out + pos, local, ll); }
  pos = pos + ll as i32;
  out[pos] = 0;
  return CFG_OK;
}

/** Exported function `cfg_yaml_list_reset`.
 * Implements `cfg_yaml_list_reset`.
 * @param ctx *YamlParseCtx
 * @return void
 */
export function cfg_yaml_list_reset(ctx: *YamlParseCtx): void {
  if (ctx == 0) { return; }
  ctx.list_prefix[0] = 0;
  ctx.list_index = -1;
  ctx.list_indent = -1;
}

/** Exported function `cfg_yaml_frame_key`.
 * Implements `cfg_yaml_frame_key`.
 * @param stack *YamlFrame
 * @param depth i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function cfg_yaml_frame_key(stack: *YamlFrame, depth: i32, out: *u8, out_cap: i32): i32 {
  let pos: i32 = 0;
  let i: i32 = 0;
  if (stack == 0 || out == 0 || out_cap <= 0 || depth <= 0) { return CFG_ERR_NULL; }
  while (i < depth) {
    let sl: usize = 0;
    unsafe { sl = strlen(&stack[i].name[0]); }
    if (sl == 0) { return CFG_ERR_INVALID; }
    if (pos > 0) {
      if (pos + 1 >= out_cap) { return CFG_ERR_INVALID; }
      out[pos] = 46;
      pos = pos + 1;
    }
    if (pos + sl as i32 >= out_cap) { return CFG_ERR_INVALID; }
    unsafe { memcpy(out + pos, &stack[i].name[0], sl); }
    pos = pos + sl as i32;
    i = i + 1;
  }
  out[pos] = 0;
  return CFG_OK;
}

/** Exported function `cfg_yaml_list_ensure_item`.
 * Implements `cfg_yaml_list_ensure_item`.
 * @param ctx *YamlParseCtx
 * @param indent i32
 * @param new_dash i32
 * @return i32
 */
export function cfg_yaml_list_ensure_item(ctx: *YamlParseCtx, indent: i32, new_dash: i32): i32 {
  if (ctx == 0) { return CFG_ERR_NULL; }
  if (ctx.list_prefix[0] == 0) {
    if (ctx.depth <= 0) { return CFG_ERR_INVALID; }
    if (cfg_yaml_frame_key(&ctx.stack[0], ctx.depth, &ctx.list_prefix[0], CFG_KEY_MAX) != CFG_OK) {
      return CFG_ERR_INVALID;
    }
    ctx.list_index = 0;
    ctx.list_indent = indent;
    return CFG_OK;
  }
  if (new_dash != 0 && indent == ctx.list_indent) { ctx.list_index = ctx.list_index + 1; }
  return CFG_OK;
}

/** Exported function `cfg_yaml_set_list_entry`.
 * Implements `cfg_yaml_set_list_entry`.
 * @param store *CfgStore
 * @param ctx *YamlParseCtx
 * @param field *u8
 * @param val *u8
 * @param override i32
 * @return i32
 */
export function cfg_yaml_set_list_entry(store: *CfgStore, ctx: *YamlParseCtx, field: *u8, val: *u8, override: i32): i32 {
  let key_full: u8[128] = [];
  if (store == 0 || ctx == 0 || val == 0) { return CFG_ERR_NULL; }
  if (ctx.list_index < 0) { return CFG_ERR_INVALID; }
  if (cfg_build_list_key(&ctx.list_prefix[0], ctx.list_index, field, &key_full[0], CFG_KEY_MAX) != CFG_OK) {
    return CFG_ERR_INVALID;
  }
  return cfg_set_raw(store, &key_full[0], val, override);
}

/** Function `cfg_yaml_parse_list_field`.
 * Purpose: implements `cfg_yaml_parse_list_field`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
export function cfg_yaml_parse_list_field(store: *CfgStore, ctx: *YamlParseCtx, line: *u8,
                                 indent: i32, new_dash: i32, override: i32): i32 {
  let key_local: u8[128] = [];
  let val_buf: u8[256] = [];
  let tl: i32 = 0;
  let key_len: i32 = 0;
  let val_len: i32 = 0;
  let t: *u8 = 0;
  let content: *u8 = 0;
  let colon: *u8 = 0;
  let key_start: *u8 = 0;
  let val_part: *u8 = 0;
  if (store == 0 || ctx == 0 || line == 0) { return CFG_ERR_NULL; }
  t = cfg_trim(line, &tl);
  if (tl <= 0) { return CFG_ERR_INVALID; }
  content = t;
  if (new_dash != 0) {
    if (t[0] != 45) { return CFG_ERR_INVALID; }
    content = t + 1;
    while (content[0] == 32) { content = content + 1; }
  }
  unsafe { colon = strchr(content, 58); }
  if (colon == 0) { return CFG_ERR_INVALID; }
  key_start = content;
  key_len = (colon - key_start) as i32;
  while (key_len > 0 && cfg_isspace(key_start[(key_len - 1)]) != 0) { key_len = key_len - 1; }
  if (key_len <= 0 || key_len >= CFG_KEY_MAX) { return CFG_ERR_INVALID; }
  unsafe { memcpy(&key_local[0], key_start, key_len); }
  key_local[key_len] = 0;
  val_part = cfg_trim(colon + 1, &val_len);
  if (val_len <= 0) { return CFG_ERR_INVALID; }
  if (cfg_yaml_list_ensure_item(ctx, indent, new_dash) != CFG_OK) { return CFG_ERR_INVALID; }
  if (cfg_normalize_value(val_part, val_len, &val_buf[0], CFG_VAL_MAX) != CFG_OK) { return CFG_ERR_INVALID; }
  return cfg_yaml_set_list_entry(store, ctx, &key_local[0], &val_buf[0], override);
}

/** Exported function `cfg_yaml_parse_list_scalar`.
 * Implements `cfg_yaml_parse_list_scalar`.
 * @param store *CfgStore
 * @param ctx *YamlParseCtx
 * @param line *u8
 * @param override i32
 * @return i32
 */
export function cfg_yaml_parse_list_scalar(store: *CfgStore, ctx: *YamlParseCtx, line: *u8, override: i32): i32 {
  let val_buf: u8[256] = [];
  let tl: i32 = 0;
  let indent: i32 = 0;
  let val_len: i32 = 0;
  let t: *u8 = 0;
  let val_part: *u8 = 0;
  if (store == 0 || ctx == 0 || line == 0) { return CFG_ERR_NULL; }
  indent = cfg_yaml_indent(line);
  t = cfg_trim(line, &tl);
  if (tl < 2 || t[0] != 45) { return CFG_ERR_INVALID; }
  val_part = cfg_trim(t + 1, &val_len);
  if (val_len <= 0) { return CFG_ERR_INVALID; }
  if (cfg_yaml_list_ensure_item(ctx, indent, 1) != CFG_OK) { return CFG_ERR_INVALID; }
  if (cfg_normalize_value(val_part, val_len, &val_buf[0], CFG_VAL_MAX) != CFG_OK) { return CFG_ERR_INVALID; }
  return cfg_yaml_set_list_entry(store, ctx, 0, &val_buf[0], override);
}

/** Exported function `cfg_yaml_parse_line`.
 * Implements `cfg_yaml_parse_line`.
 * @param store *CfgStore
 * @param line *u8
 * @param ctx *YamlParseCtx
 * @param override i32
 * @return i32
 */
export function cfg_yaml_parse_line(store: *CfgStore, line: *u8, ctx: *YamlParseCtx, override: i32): i32 {
  let key_local: u8[128] = [];
  let key_full: u8[128] = [];
  let val_buf: u8[256] = [];
  let indent: i32 = 0;
  let key_len: i32 = 0;
  let val_len: i32 = 0;
  let tl: i32 = 0;
  let t: *u8 = 0;
  let colon: *u8 = 0;
  let key_start: *u8 = 0;
  let val_part: *u8 = 0;
  let ki: i32 = 0;
  if (store == 0 || line == 0 || ctx == 0) { return CFG_ERR_NULL; }
  t = cfg_trim(line, &tl);
  if (tl <= 0 || t[0] == 35) { return CFG_OK; }
  indent = cfg_yaml_indent(line);
  if (tl > 0 && t[0] == 45) {
    let after: *u8 = t + 1;
    while (after[0] == 32) { after = after + 1; }
    unsafe { if (strchr(after, 58) != 0) {
      return cfg_yaml_parse_list_field(store, ctx, line, indent, 1, override);
    } }
    return cfg_yaml_parse_list_scalar(store, ctx, line, override);
  }
  unsafe { if (ctx.list_prefix[0] != 0 && indent > ctx.list_indent && strchr(t, 58) != 0) {
    return cfg_yaml_parse_list_field(store, ctx, line, indent, 0, override);
  } }
  if (ctx.list_prefix[0] != 0 && indent <= ctx.list_indent) { cfg_yaml_list_reset(ctx); }
  cfg_yaml_pop_to(&ctx.stack[0], &ctx.depth, indent);
  unsafe { colon = strchr(t, 58); }
  if (colon == 0) { return CFG_ERR_INVALID; }
  key_start = t;
  key_len = (colon - key_start) as i32;
  while (key_len > 0 && cfg_isspace(key_start[(key_len - 1)]) != 0) { key_len = key_len - 1; }
  if (key_len <= 0 || key_len >= CFG_KEY_MAX) { return CFG_ERR_INVALID; }
  unsafe { memcpy(&key_local[0], key_start, key_len); }
  key_local[key_len] = 0;
  ki = 0;
  while (ki < key_len) {
    let c: u8 = key_local[ki];
    if (cfg_isalnum(c) == 0 && c != 95 && c != 46) { return CFG_ERR_INVALID; }
    ki = ki + 1;
  }
  val_part = cfg_trim(colon + 1, &val_len);
  if (val_len == 0) {
    if (ctx.depth >= YAML_STACK_MAX) { return CFG_ERR_FULL; }
    cfg_yaml_list_reset(ctx);
    cfg_strncpy(&ctx.stack[ctx.depth].name[0], &key_local[0], CFG_KEY_MAX);
    ctx.stack[ctx.depth].indent = indent;
    ctx.depth = ctx.depth + 1;
    return CFG_OK;
  }
  if (ctx.depth > 0) {
    if (cfg_yaml_build_key(&ctx.stack[0], ctx.depth, &key_local[0], &key_full[0], CFG_KEY_MAX) != CFG_OK) {
      return CFG_ERR_INVALID;
    }
  } else {
    cfg_strncpy(&key_full[0], &key_local[0], CFG_KEY_MAX);
  }
  if (cfg_normalize_value(val_part, val_len, &val_buf[0], CFG_VAL_MAX) != CFG_OK) { return CFG_ERR_INVALID; }
  return cfg_set_raw(store, &key_full[0], &val_buf[0], override);
}

/** Exported function `cfg_load_yaml_buf_impl`.
 * Implements `cfg_load_yaml_buf_impl`.
 * @param store *CfgStore
 * @param buf *u8
 * @param len i32
 * @param override i32
 * @return i32
 */
export function cfg_load_yaml_buf_impl(store: *CfgStore, buf: *u8, len: i32, override: i32): i32 {
  let ctx: YamlParseCtx = YamlParseCtx {
    stack: [], depth: 0, list_prefix: [], list_index: -1, list_indent: -1
  };
  let line: u8[512] = [];
  let i: i32 = 0;
  let line_pos: i32 = 0;
  if (store == 0 || buf == 0 || len < 0) { return CFG_ERR_NULL; }
  ctx.list_index = -1;
  ctx.list_indent = -1;
  while (i <= len) {
    let c: u8 = 10;
    if (i < len) { c = buf[i]; }
    if (c == 13) { i = i + 1; continue; }
    if (c == 10 || c == 0) {
      line[line_pos] = 0;
      if (line_pos > 0) {
        let r: i32 = cfg_yaml_parse_line(store, &line[0], &ctx, override);
        if (r != CFG_OK) { return r; }
      }
      line_pos = 0;
      i = i + 1;
      continue;
    }
    if (line_pos + 1 >= 512) { return CFG_ERR_INVALID; }
    line[line_pos] = c;
    line_pos = line_pos + 1;
    i = i + 1;
  }
  return CFG_OK;
}

/** Exported function `config_load_yaml_buf_c`.
 * Implements `config_load_yaml_buf_c`.
 * @param handle i64
 * @param buf *u8
 * @param len i32
 * @param override i32
 * @return i32
 */
export function config_load_yaml_buf_c(handle: i64, buf: *u8, len: i32, override: i32): i32 {
  let store: *CfgStore = cfg_from_handle(handle);
  if (store == 0 || buf == 0 || len < 0) { return CFG_ERR_NULL; }
  store.active_source_kind = CFG_SRC_YAML;
  cfg_strncpy(&store.active_source_label[0], &CFG_LIT_YAML[0], CFG_SRC_LABEL_MAX);
  return cfg_load_yaml_buf_impl(store, buf, len, override);
}

/** Exported function `config_load_yaml_file_c`.
 * Implements `config_load_yaml_file_c`.
 * @param handle i64
 * @param path *u8
 * @param override i32
 * @return i32
 */
export function config_load_yaml_file_c(handle: i64, path: *u8, override: i32): i32 {
  let store: *CfgStore = cfg_from_handle(handle);
  let buf: *u8 = 0;
  let sz: i32 = 0;
  let r: i32 = 0;
  if (path == 0) { return CFG_ERR_NULL; }
  unsafe { buf = calloc((CFG_FILE_MAX + 1), 1); }
  if (buf == 0) { return CFG_ERR_IO; }
  sz = config_read_file_c(path, buf, CFG_FILE_MAX + 1);
  if (sz < 0) { unsafe { free(buf); } return CFG_ERR_IO; }
  if (store != 0) {
    store.active_source_kind = CFG_SRC_YAML;
    cfg_strncpy(&store.active_source_label[0], path, CFG_SRC_LABEL_MAX);
  }
  r = cfg_load_yaml_buf_impl(store, buf, sz, override);
  unsafe { free(buf); }
  return r;
}


/** Exported function `config_yaml_smoke_c`.
 * Implements `config_yaml_smoke_c`.
 * @return i32
 */
export function config_yaml_smoke_c(): i32 {
  let cfg: i64 = 0;
  let port: i32 = 0;
  let dbg: i32 = 0;
  let url: u8[64] = [];
  let yaml_main: u8[72] = [35, 32, 97, 112, 112, 10, 112, 111, 114, 116, 58, 32, 56, 48, 56, 48, 10, 104, 111, 115, 116, 58, 32, 108, 111, 99, 97, 108, 104, 111, 115, 116, 10, 100, 101, 98, 117, 103, 58, 32, 102, 97, 108, 115, 101, 10, 10, 100, 98, 58, 10, 32, 32, 117, 114, 108, 58, 32, 115, 113, 108, 105, 116, 101, 58, 47, 47, 109, 101, 109, 10, 0];
  let yaml_arr: u8[22] = [105, 116, 101, 109, 115, 58, 10, 32, 32, 45, 32, 49, 48, 10, 32, 32, 45, 32, 50, 48, 10, 0];
  let yaml_obj: u8[68] = [115, 101, 114, 118, 101, 114, 115, 58, 10, 32, 32, 45, 32, 104, 111, 115, 116, 58, 32, 97, 108, 112, 104, 97, 10, 32, 32, 32, 32, 112, 111, 114, 116, 58, 32, 56, 48, 10, 32, 32, 45, 32, 104, 111, 115, 116, 58, 32, 98, 101, 116, 97, 10, 32, 32, 32, 32, 112, 111, 114, 116, 58, 32, 52, 52, 51, 10, 0];
  let host: u8[64] = [];
  cfg = config_create_c();
  if (cfg == 0) { return 1; }
  if (config_load_yaml_buf_c(cfg, &yaml_main[0], 71, 1) != CFG_OK) { return 2; }
  if (config_get_i32_c(cfg, &CFG_LIT_PORT[0], 4, &port) != CFG_OK || port != 8080) { return 3; }
  if (config_get_string_c(cfg, &CFG_LIT_DB_URL[0], 6, &url[0], 64) <= 0) { return 4; }
  unsafe { if (strcmp(&url[0], &CFG_LIT_SQLITE_MEM[0]) != 0) { return 5; } }
  if (config_get_bool_c(cfg, &CFG_LIT_DEBUG[0], 5, &dbg) != CFG_OK || dbg != 0) { return 6; }
  if (config_load_yaml_buf_c(cfg, &yaml_arr[0], 21, 1) != CFG_OK) { return 7; }
  if (config_get_i32_c(cfg, &CFG_LIT_ITEMS_0[0], 7, &port) != CFG_OK || port != 10) { return 8; }
  if (config_get_i32_c(cfg, &CFG_LIT_ITEMS_1[0], 7, &port) != CFG_OK || port != 20) { return 9; }
  if (config_load_yaml_buf_c(cfg, &yaml_obj[0], 67, 1) != CFG_OK) { return 10; }
  if (config_get_string_c(cfg, &CFG_LIT_SERVERS_0_HOST[0], 14, &host[0], 64) <= 0) { return 11; }
  unsafe { if (strcmp(&host[0], &CFG_LIT_ALPHA[0]) != 0) { return 12; } }
  if (config_get_i32_c(cfg, &CFG_LIT_SERVERS_0_PORT[0], 14, &port) != CFG_OK || port != 80) { return 13; }
  if (config_get_string_c(cfg, &CFG_LIT_SERVERS_1_HOST[0], 14, &host[0], 64) <= 0) { return 14; }
  unsafe { if (strcmp(&host[0], &CFG_LIT_BETA[0]) != 0) { return 15; } }
  if (config_get_i32_c(cfg, &CFG_LIT_SERVERS_1_PORT[0], 14, &port) != CFG_OK || port != 443) { return 16; }
  config_free_c(cfg);
  return 0;
}

/** Exported function `config_array_smoke_c`.
 * Implements `config_array_smoke_c`.
 * @return i32
 */
export function config_array_smoke_c(): i32 {
  let cfg: i64 = 0;
  let p0: i32 = 0;
  let p1: i32 = 0;
  let h0: u8[64] = [];
  let h1: u8[64] = [];
  let toml: u8[76] = [91, 91, 115, 101, 114, 118, 101, 114, 115, 93, 93, 10, 104, 111, 115, 116, 32, 61, 32, 34, 97, 108, 112, 104, 97, 34, 10, 112, 111, 114, 116, 32, 61, 32, 56, 48, 10, 10, 91, 91, 115, 101, 114, 118, 101, 114, 115, 93, 93, 10, 104, 111, 115, 116, 32, 61, 32, 34, 98, 101, 116, 97, 34, 10, 112, 111, 114, 116, 32, 61, 32, 52, 52, 51, 10, 0];
  cfg = config_create_c();
  if (cfg == 0) { return 1; }
  if (config_load_toml_buf_c(cfg, &toml[0], 75, 1) != CFG_OK) { return 2; }
  if (config_get_string_c(cfg, &CFG_LIT_SERVERS_0_HOST[0], 14, &h0[0], 64) <= 0) { return 3; }
  unsafe { if (strcmp(&h0[0], &CFG_LIT_ALPHA[0]) != 0) { return 4; } }
  if (config_get_i32_c(cfg, &CFG_LIT_SERVERS_0_PORT[0], 14, &p0) != CFG_OK || p0 != 80) { return 5; }
  if (config_get_string_c(cfg, &CFG_LIT_SERVERS_1_HOST[0], 14, &h1[0], 64) <= 0) { return 6; }
  unsafe { if (strcmp(&h1[0], &CFG_LIT_BETA[0]) != 0) { return 7; } }
  if (config_get_i32_c(cfg, &CFG_LIT_SERVERS_1_PORT[0], 14, &p1) != CFG_OK || p1 != 443) { return 8; }
  config_free_c(cfg);
  return 0;
}

/** Exported function `config_nested_smoke_c`.
 * Implements `config_nested_smoke_c`.
 * @return i32
 */
export function config_nested_smoke_c(): i32 {
  let cfg: i64 = 0;
  let port: i32 = 0;
  let host: u8[64] = [];
  let url: u8[64] = [];
  let toml: u8[75] = [91, 115, 101, 114, 118, 101, 114, 93, 10, 104, 111, 115, 116, 32, 61, 32, 34, 108, 111, 99, 97, 108, 104, 111, 115, 116, 34, 10, 10, 91, 115, 101, 114, 118, 101, 114, 46, 100, 98, 93, 10, 117, 114, 108, 32, 61, 32, 34, 115, 113, 108, 105, 116, 101, 58, 47, 47, 109, 101, 109, 34, 10, 112, 111, 114, 116, 32, 61, 32, 53, 52, 51, 50, 10, 0];
  cfg = config_create_c();
  if (cfg == 0) { return 1; }
  if (config_load_toml_buf_c(cfg, &toml[0], 74, 1) != CFG_OK) { return 2; }
  if (config_get_string_c(cfg, &CFG_LIT_SERVER_HOST[0], 11, &host[0], 64) <= 0) { return 3; }
  unsafe { if (strcmp(&host[0], &CFG_LIT_LOCALHOST[0]) != 0) { return 4; } }
  if (config_get_string_c(cfg, &CFG_LIT_SERVER_DB_URL[0], 13, &url[0], 64) <= 0) { return 5; }
  unsafe { if (strcmp(&url[0], &CFG_LIT_SQLITE_MEM[0]) != 0) { return 6; } }
  if (config_get_i32_c(cfg, &CFG_LIT_SERVER_DB_PORT[0], 14, &port) != CFG_OK || port != 5432) { return 7; }
  config_free_c(cfg);
  return 0;
}

/** Exported function `config_smoke_c`.
 * Implements `config_smoke_c`.
 * @return i32
 */
export function config_smoke_c(): i32 {
  let base: i64 = 0;
  let overlay: i64 = 0;
  let port: i32 = 0;
  let dbg: i32 = 0;
  let host: u8[64] = [];
  let kind: i32 = 0;
  let label: u8[64] = [];
  let toml: u8[79] = [35, 32, 97, 112, 112, 10, 112, 111, 114, 116, 32, 61, 32, 56, 48, 56, 48, 10, 104, 111, 115, 116, 32, 61, 32, 34, 108, 111, 99, 97, 108, 104, 111, 115, 116, 34, 10, 100, 101, 98, 117, 103, 32, 61, 32, 102, 97, 108, 115, 101, 10, 10, 91, 100, 98, 93, 10, 117, 114, 108, 32, 61, 32, 34, 115, 113, 108, 105, 116, 101, 58, 47, 47, 109, 101, 109, 34, 10, 0];
  let env_key: u8[15] = [88, 76, 65, 78, 71, 95, 67, 70, 71, 95, 100, 101, 98, 117, 103];
  let env_val: u8[5] = [116, 114, 117, 101, 0];
  let env_prefix: u8[11] = [88, 76, 65, 78, 71, 95, 67, 70, 71, 95, 0];
  let nr: i32 = 0;
  let ar: i32 = 0;
  base = config_create_c();
  overlay = config_create_c();
  if (base == 0 || overlay == 0) { return 1; }
  if (config_load_toml_buf_c(base, &toml[0], 78, 1) != CFG_OK) { return 2; }
  if (config_get_i32_c(base, &CFG_LIT_PORT[0], 4, &port) != CFG_OK || port != 8080) { return 3; }
  if (config_get_string_c(base, &CFG_LIT_DB_URL[0], 6, &host[0], 64) <= 0) { return 4; }
  unsafe { if (strcmp(&host[0], &CFG_LIT_SQLITE_MEM[0]) != 0) { return 5; } }
  if (config_smoke_setenv_c(&env_key[0], &env_val[0]) != 0) { return 6; }
  if (config_load_env_prefix_c(base, &env_prefix[0], 9, 1) < 0) { return 6; }
  if (config_get_bool_c(base, &CFG_LIT_DEBUG[0], 5, &dbg) != CFG_OK || dbg != 1) { return 7; }
  if (config_get_source_c(base, &CFG_LIT_DEBUG[0], 5, &kind, &label[0], 64) != CFG_OK) { return 71; }
  if (kind != CFG_SRC_ENV) { return 72; }
  unsafe { if (strcmp(&label[0], &CFG_LIT_XLANG_CFG_DEBUG[0]) != 0) { return 73; } }
  if (config_get_source_c(base, &CFG_LIT_PORT[0], 4, &kind, &label[0], 64) != CFG_OK) { return 74; }
  if (kind != CFG_SRC_TOML) { return 75; }
  if (config_set_string_c(overlay, &CFG_LIT_PORT[0], 4, &CFG_LIT_N9090[0], 4) != CFG_OK) { return 8; }
  if (config_merge_c(base, overlay, 1) != CFG_OK) { return 9; }
  if (config_get_i32_c(base, &CFG_LIT_PORT[0], 4, &port) != CFG_OK || port != 9090) { return 10; }
  if (config_get_i32_meta_c(base, &CFG_LIT_PORT[0], 4, &port, &kind, 0, 0) != CFG_OK) { return 101; }
  if (port != 9090 || kind != CFG_SRC_SET) { return 102; }
  config_free_c(overlay);
  config_free_c(base);
  nr = config_nested_smoke_c();
  if (nr != 0) { return 100 + nr; }
  ar = config_array_smoke_c();
  if (ar != 0) { return 200 + ar; }
  return 0;
}
