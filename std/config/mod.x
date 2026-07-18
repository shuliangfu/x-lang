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
//
// See implementation.
// See implementation.

/* See implementation. */
allow(padding) struct Config {
  handle: i64;
}

/** Exported function `err_ok`.
 * Implements `err_ok`.
 * @return i32
 */
export function err_ok(): i32 { return 0; }
/** Exported function `err_null`.
 * Implements `err_null`.
 * @return i32
 */
export function err_null(): i32 { return -1; }
/** Exported function `err_not_found`.
 * Implements `err_not_found`.
 * @return i32
 */
export function err_not_found(): i32 { return -2; }
/** Exported function `err_invalid`.
 * Implements `err_invalid`.
 * @return i32
 */
export function err_invalid(): i32 { return -3; }
/** Exported function `err_io`.
 * Implements `err_io`.
 * @return i32
 */
export function err_io(): i32 { return -4; }
/** Exported function `err_full`.
 * Implements `err_full`.
 * @return i32
 */
export function err_full(): i32 { return -5; }

/** Exported function `source_unknown`.
 * Implements `source_unknown`.
 * @return i32
 */
export function source_unknown(): i32 { return 0; }
/** Exported function `source_toml`.
 * Implements `source_toml`.
 * @return i32
 */
export function source_toml(): i32 { return 1; }
/** Exported function `source_yaml`.
 * Implements `source_yaml`.
 * @return i32
 */
export function source_yaml(): i32 { return 2; }
/** Exported function `source_env`.
 * Implements `source_env`.
 * @return i32
 */
export function source_env(): i32 { return 3; }
/** Exported function `source_set`.
 * Implements `source_set`.
 * @return i32
 */
export function source_set(): i32 { return 4; }

extern function config_create_c(): i64;
extern function config_free_c(handle: i64): void;
extern function config_clear_c(handle: i64): void;
extern function config_load_toml_buf_c(handle: i64, buf: *u8, len: i32, override: i32): i32;
extern function config_load_toml_file_c(handle: i64, path: *u8, override: i32): i32;
extern function config_load_env_prefix_c(handle: i64, prefix: *u8, prefix_len: i32, override: i32): i32;
extern function config_merge_c(dst: i64, src: i64, override: i32): i32;
extern function config_set_string_c(handle: i64, key: *u8, key_len: i32, val: *u8, val_len: i32): i32;
extern function config_get_string_c(handle: i64, key: *u8, key_len: i32, out: *u8, out_cap: i32): i32;
extern function config_get_i32_c(handle: i64, key: *u8, key_len: i32, out: *i32): i32;
extern function config_get_bool_c(handle: i64, key: *u8, key_len: i32, out: *i32): i32;
extern function config_get_source_c(handle: i64, key: *u8, key_len: i32, out_kind: *i32, out_label: *u8, label_cap: i32): i32;
extern function config_get_i32_meta_c(handle: i64, key: *u8, key_len: i32, out: *i32, out_kind: *i32, out_label: *u8, label_cap: i32): i32;
extern function config_get_bool_meta_c(handle: i64, key: *u8, key_len: i32, out: *i32, out_kind: *i32, out_label: *u8, label_cap: i32): i32;
extern function config_get_string_meta_c(handle: i64, key: *u8, key_len: i32, out: *u8, out_cap: i32, out_kind: *i32, out_label: *u8, label_cap: i32): i32;
extern function config_load_yaml_buf_c(handle: i64, buf: *u8, len: i32, override: i32): i32;
extern function config_load_yaml_file_c(handle: i64, path: *u8, override: i32): i32;
extern function config_yaml_smoke_c(): i32;

/** Exported function `new`.
 * Implements `new`.
 * @return Config
 */
export function new(): Config {
  unsafe {
    let h: i64 = config_create_c();
    return Config { handle: h };
  }
}

/** Exported function `free`.
 * Memory management helper `free`.
 * @param cfg *Config
 * @return void
 */
export function free(cfg: *Config): void {
  let zero: i64 = 0;
  if (cfg == 0) { return; }
  if (cfg.handle != zero) {
    unsafe { config_free_c(cfg.handle); }
    cfg.handle = zero;
  }
}

/** Exported function `clear`.
 * Implements `clear`.
 * @param cfg *Config
 * @return void
 */
export function clear(cfg: *Config): void {
  let zero: i64 = 0;
  if (cfg == 0 || cfg.handle == zero) { return; }
  unsafe { config_clear_c(cfg.handle); }
}

/** Exported function `load_toml_buf`.
 * Implements `load_toml_buf`.
 * @param cfg *Config
 * @param buf *u8
 * @param len i32
 * @param override i32
 * @return i32
 */
export function load_toml_buf(cfg: *Config, buf: *u8, len: i32, override: i32): i32 {
  let zero: i64 = 0;
  if (cfg == 0 || cfg.handle == zero || buf == 0) { return err_null(); }
  unsafe {
    return config_load_toml_buf_c(cfg.handle, buf, len, override);
  }
}

/** Exported function `load_toml_file`.
 * Implements `load_toml_file`.
 * @param cfg *Config
 * @param path *u8
 * @param override i32
 * @return i32
 */
export function load_toml_file(cfg: *Config, path: *u8, override: i32): i32 {
  let zero: i64 = 0;
  if (cfg == 0 || cfg.handle == zero || path == 0) { return err_null(); }
  unsafe {
    return config_load_toml_file_c(cfg.handle, path, override);
  }
}

/** Exported function `load_env_prefix`.
 * Implements `load_env_prefix`.
 * @param cfg *Config
 * @param prefix *u8
 * @param prefix_len i32
 * @param override i32
 * @return i32
 */
export function load_env_prefix(cfg: *Config, prefix: *u8, prefix_len: i32, override: i32): i32 {
  let zero: i64 = 0;
  if (cfg == 0 || cfg.handle == zero || prefix == 0) { return err_null(); }
  unsafe {
    return config_load_env_prefix_c(cfg.handle, prefix, prefix_len, override);
  }
}

/** Exported function `merge`.
 * Implements `merge`.
 * @param dst *Config
 * @param src *Config
 * @param override i32
 * @return i32
 */
export function merge(dst: *Config, src: *Config, override: i32): i32 {
  let zero: i64 = 0;
  if (dst == 0 || src == 0 || dst.handle == zero || src.handle == zero) { return err_null(); }
  unsafe {
    return config_merge_c(dst.handle, src.handle, override);
  }
}

/** Exported function `set_string`.
 * Implements `set_string`.
 * @param cfg *Config
 * @param key *u8
 * @param key_len i32
 * @param val *u8
 * @param val_len i32
 * @return i32
 */
export function set_string(cfg: *Config, key: *u8, key_len: i32, val: *u8, val_len: i32): i32 {
  let zero: i64 = 0;
  if (cfg == 0 || cfg.handle == zero) { return err_null(); }
  unsafe {
    return config_set_string_c(cfg.handle, key, key_len, val, val_len);
  }
}

/** Exported function `get_string`.
 * Query helper `get_string`.
 * @param cfg *Config
 * @param key *u8
 * @param key_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function get_string(cfg: *Config, key: *u8, key_len: i32, out: *u8, out_cap: i32): i32 {
  let zero: i64 = 0;
  if (cfg == 0 || cfg.handle == zero) { return err_null(); }
  unsafe {
    return config_get_string_c(cfg.handle, key, key_len, out, out_cap);
  }
}

/** Exported function `get_i32`.
 * Query helper `get_i32`.
 * @param cfg *Config
 * @param key *u8
 * @param key_len i32
 * @param out *i32
 * @return i32
 */
export function get_i32(cfg: *Config, key: *u8, key_len: i32, out: *i32): i32 {
  let zero: i64 = 0;
  if (cfg == 0 || cfg.handle == zero) { return err_null(); }
  unsafe {
    return config_get_i32_c(cfg.handle, key, key_len, out);
  }
}

/** Exported function `get_bool`.
 * Query helper `get_bool`.
 * @param cfg *Config
 * @param key *u8
 * @param key_len i32
 * @param out *i32
 * @return i32
 */
export function get_bool(cfg: *Config, key: *u8, key_len: i32, out: *i32): i32 {
  let zero: i64 = 0;
  if (cfg == 0 || cfg.handle == zero) { return err_null(); }
  unsafe {
    return config_get_bool_c(cfg.handle, key, key_len, out);
  }
}

/** Exported function `get_source`.
 * Query helper `get_source`.
 * @param cfg *Config
 * @param key *u8
 * @param key_len i32
 * @param out_kind *i32
 * @param out_label *u8
 * @param label_cap i32
 * @return i32
 */
export function get_source(cfg: *Config, key: *u8, key_len: i32, out_kind: *i32, out_label: *u8, label_cap: i32): i32 {
  let zero: i64 = 0;
  if (cfg == 0 || cfg.handle == zero) { return err_null(); }
  unsafe {
    return config_get_source_c(cfg.handle, key, key_len, out_kind, out_label, label_cap);
  }
}

/** Exported function `get_i32_meta`.
 * Query helper `get_i32_meta`.
 * @param cfg *Config
 * @param key *u8
 * @param key_len i32
 * @param out *i32
 * @param out_kind *i32
 * @param out_label *u8
 * @param label_cap i32
 * @return i32
 */
export function get_i32_meta(cfg: *Config, key: *u8, key_len: i32, out: *i32, out_kind: *i32, out_label: *u8, label_cap: i32): i32 {
  let zero: i64 = 0;
  if (cfg == 0 || cfg.handle == zero) { return err_null(); }
  unsafe {
    return config_get_i32_meta_c(cfg.handle, key, key_len, out, out_kind, out_label, label_cap);
  }
}

/** Exported function `get_bool_meta`.
 * Query helper `get_bool_meta`.
 * @param cfg *Config
 * @param key *u8
 * @param key_len i32
 * @param out *i32
 * @param out_kind *i32
 * @param out_label *u8
 * @param label_cap i32
 * @return i32
 */
export function get_bool_meta(cfg: *Config, key: *u8, key_len: i32, out: *i32, out_kind: *i32, out_label: *u8, label_cap: i32): i32 {
  let zero: i64 = 0;
  if (cfg == 0 || cfg.handle == zero) { return err_null(); }
  unsafe {
    return config_get_bool_meta_c(cfg.handle, key, key_len, out, out_kind, out_label, label_cap);
  }
}

/** Exported function `get_string_meta`.
 * Query helper `get_string_meta`.
 * @param cfg *Config
 * @param key *u8
 * @param key_len i32
 * @param out *u8
 * @param out_cap i32
 * @param out_kind *i32
 * @param out_label *u8
 * @param label_cap i32
 * @return i32
 */
export function get_string_meta(cfg: *Config, key: *u8, key_len: i32, out: *u8, out_cap: i32, out_kind: *i32, out_label: *u8, label_cap: i32): i32 {
  let zero: i64 = 0;
  if (cfg == 0 || cfg.handle == zero) { return err_null(); }
  unsafe {
    return config_get_string_meta_c(cfg.handle, key, key_len, out, out_cap, out_kind, out_label, label_cap);
  }
}

/** Exported function `backend_toml`.
 * Implements `backend_toml`.
 * @return i32
 */
export function backend_toml(): i32 { return 1; }
/** Exported function `backend_yaml`.
 * Implements `backend_yaml`.
 * @return i32
 */
export function backend_yaml(): i32 { return 2; }

/** Exported function `load_yaml_buf`.
 * Implements `load_yaml_buf`.
 * @param cfg *Config
 * @param buf *u8
 * @param len i32
 * @param override i32
 * @return i32
 */
export function load_yaml_buf(cfg: *Config, buf: *u8, len: i32, override: i32): i32 {
  let zero: i64 = 0;
  if (cfg == 0 || cfg.handle == zero || buf == 0) { return err_null(); }
  unsafe {
    return config_load_yaml_buf_c(cfg.handle, buf, len, override);
  }
}

/** Exported function `load_yaml_file`.
 * Implements `load_yaml_file`.
 * @param cfg *Config
 * @param path *u8
 * @param override i32
 * @return i32
 */
export function load_yaml_file(cfg: *Config, path: *u8, override: i32): i32 {
  let zero: i64 = 0;
  if (cfg == 0 || cfg.handle == zero || path == 0) { return err_null(); }
  unsafe {
    return config_load_yaml_file_c(cfg.handle, path, override);
  }
}

/** Exported function `yaml_smoke`.
 * Implements `yaml_smoke`.
 * @return i32
 */
export function yaml_smoke(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = config_yaml_smoke_c(); }
  return _rc;
}
