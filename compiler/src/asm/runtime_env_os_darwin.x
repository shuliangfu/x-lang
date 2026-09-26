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

// runtime_env_os_darwin.x — Darwin arm64 OS bridges for runtime_env_os.o.
//
// The cold ensure path pure-asms src/asm/runtime_env_os.x (public
// wrappers and env_build_key) and this file (the _impl bridges), then
// ld -r. It does not pass seeds/runtime_env_os.from_x.c to host cc.
// Linux keeps the POSIX seed. Windows keeps the Win32 seed.
//
// Reads go through link_abi_getenv, the same face user_env and panic
// already provide. This file does not walk the block a second time
// for getenv, and it does not call libc getenv / setenv / unsetenv.
//
// setenv still owns the replacement environ vector. A direct store to
// a file-level let does not emit on this compiler, so the owned
// pointer and the temp-dir cache flags are updated with memcpy into
// the let. Passing &let as a call argument makes this compiler exit
// 139; the address is loaded into a local first.
//
// The temp-dir cache is process-wide. The C seed uses a thread-local
// buffer of the same path. TMPDIR is process-wide, so the returned
// bytes match.
//
// A 256-byte stack array does not fit this compiler's frame, so the
// key buffer and the temp-dir cache are malloc'd.
//
// This object is a user companion. It is not in the g05 compiler
// image. A missing object after pure-asm faults falls back to the
// C seed.
//
// PLATFORM: MACOS|DARWIN arm64.

/**
 * Byte copy. Used to publish file-level slots this compiler cannot
 * store directly.
 * @param d *u8 — destination
 * @param s *u8 — source
 * @param n i64 — byte count
 * @return *u8 — destination
 * PLATFORM: POSIX
 */
export extern "C" function memcpy(d: *u8, s: *u8, n: i64): *u8;

/**
 * Byte length of a NUL-terminated string.
 * @param s *u8 — string, not null
 * @return i64 — bytes before the NUL
 * PLATFORM: POSIX
 */
export extern "C" function strlen(s: *u8): i64;

/**
 * Heap buffer.
 * @param n i64 — byte count
 * @return *u8 — buffer, or null
 * PLATFORM: POSIX
 */
export extern "C" function malloc(n: i64): *u8;

/**
 * Release a buffer from malloc.
 * @param p *u8 — buffer, or null
 * PLATFORM: POSIX
 */
export extern "C" function free(p: *u8): void;

/**
 * Darwin process environment block. *slot is the environ vector.
 * @return ***u8 — address of the process environ pointer
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function __NSGetEnviron(): ***u8;

/**
 * Public getenv face. Defined by runtime_link_abi_user_env.x and, as
 * a strong symbol, by runtime_panic_arm64.x. This TU only calls it.
 * @param name *u8 — NUL-terminated key
 * @return *u8 — value bytes, or null
 * PLATFORM: SHARED
 */
export extern "C" function link_abi_getenv(name: *u8): *u8;

/**
 * Copy key bytes and append a NUL. Defined by the shared thin.
 * Rejects a null key, a null buffer, a non-positive length, and a
 * length of 256 or more.
 * @param key *u8 — raw key bytes
 * @param key_len i32 — byte count
 * @param key_buf *u8 — destination, at least key_len+1 bytes
 * @return i32 — 0 on success, -1 on rejection
 * PLATFORM: SHARED
 */
export extern "C" function env_build_key(key: *u8, key_len: i32, key_buf: *u8): i32;

/**
 * Vector this TU allocated for environ. Null until the first append.
 * Direct assignment does not emit; writers use memcpy.
 * PLATFORM: MACOS|DARWIN
 */
export let env_os_owned: **u8 = 0;

/**
 * Heap cache of the temp directory, 256 bytes. Null until first fill.
 * PLATFORM: MACOS|DARWIN
 */
export let env_temp_buf: *u8 = 0;

/**
 * Cached temp-dir length, excluding the NUL.
 * PLATFORM: MACOS|DARWIN
 */
export let env_temp_len: i64 = 0;

/**
 * 1 when env_temp_buf holds a path.
 * PLATFORM: MACOS|DARWIN
 */
export let env_temp_valid: i32 = 0;

/**
 * Copy 4 bytes into an i32 slot.
 * @param slot *i32 — destination; the caller loaded any file-level address
 * @param v i32 — value
 * PLATFORM: MACOS|DARWIN
 */
function env_os_set_i32(slot: *i32, v: i32): void {
  let tmp: i32 = v;
  unsafe {
    memcpy(slot as *u8, &tmp as *u8, 4);
  }
}

/**
 * Copy 8 bytes into an i64 slot.
 * @param slot *i64 — destination
 * @param v i64 — value
 * PLATFORM: MACOS|DARWIN
 */
function env_os_set_i64(slot: *i64, v: i64): void {
  let tmp: i64 = v;
  unsafe {
    memcpy(slot as *u8, &tmp as *u8, 8);
  }
}

/**
 * Copy one pointer into a pointer slot.
 * @param slot **u8 — destination slot
 * @param v *u8 — pointer to store
 * PLATFORM: MACOS|DARWIN
 */
function env_os_set_ptr(slot: **u8, v: *u8): void {
  let tmp: *u8 = v;
  unsafe {
    memcpy(slot as *u8, &tmp as *u8, 8);
  }
}

/**
 * Read the vector this TU last published. A plain read of the let emits.
 * @return **u8 — owned vector, or null
 * PLATFORM: MACOS|DARWIN
 */
function env_os_owned_get(): **u8 {
  return env_os_owned;
}

/**
 * Remember the vector this TU published.
 * The address of the let is loaded into a local before the copy.
 * Passing &let as a call argument makes this compiler exit 139.
 * @param v **u8 — new owned vector
 * PLATFORM: MACOS|DARWIN
 */
function env_os_owned_set(v: **u8): void {
  let slot: ***u8 = &env_os_owned;
  env_os_set_ptr(slot as **u8, v as *u8);
}

/**
 * Current Darwin environ vector, or null when the CRT slot is missing.
 * @return **u8 — environ, or null
 * PLATFORM: MACOS|DARWIN
 */
function env_os_environ(): **u8 {
  unsafe {
    let slot: ***u8 = __NSGetEnviron();
    if (slot == 0) {
      return 0;
    }
    return slot[0];
  }
}

/**
 * Replace the process environ pointer.
 * @param neu **u8 — new vector, NUL-terminated
 * PLATFORM: MACOS|DARWIN
 */
function env_os_publish(neu: **u8): void {
  unsafe {
    let slot: ***u8 = __NSGetEnviron();
    env_os_set_ptr(slot as **u8, neu as *u8);
  }
}

/**
 * Store one entry at env[i]. The base is a parameter, so the index
 * store uses the slot the compiler did write.
 * @param env **u8 — environ vector
 * @param i i32 — slot index
 * @param ent *u8 — entry, or null to terminate
 * PLATFORM: MACOS|DARWIN
 */
function env_os_set_slot(env: **u8, i: i32, ent: *u8): void {
  env[i] = ent;
}

/**
 * 1 when ent starts with name and the next byte is '='.
 * @param ent *u8 — one environ entry
 * @param name *u8 — key
 * @param nlen i32 — key length
 * @return i32 — 1 on match, 0 otherwise
 * PLATFORM: MACOS|DARWIN
 */
function env_os_key_eq(ent: *u8, name: *u8, nlen: i32): i32 {
  let k: i32 = 0;
  while (k < nlen) {
    if (ent[k] != name[k]) {
      return 0;
    }
    k = k + 1;
  }
  if (ent[nlen] == 61 as u8) {
    return 1;
  }
  return 0;
}

/**
 * 1 when name is non-empty and contains no '='.
 * @param name *u8 — candidate key
 * @return i32 — 1 when the key is acceptable
 * PLATFORM: MACOS|DARWIN
 */
function env_os_name_ok(name: *u8): i32 {
  if (name == 0) {
    return 0;
  }
  if (name[0] == 0 as u8) {
    return 0;
  }
  let i: i32 = 0;
  while (i < 4096) {
    if (name[i] == 0 as u8) {
      return 1;
    }
    if (name[i] == 61 as u8) {
      return 0;
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Scan env. Writes the first matching index, or -1, through idx_out.
 * @param env **u8 — environ vector, not null
 * @param name *u8 — key
 * @param nlen i32 — key length
 * @param idx_out *i32 — receives the match index
 * @return i32 — number of entries before the terminating null
 * PLATFORM: MACOS|DARWIN
 */
function env_os_scan(env: **u8, name: *u8, nlen: i32, idx_out: *i32): i32 {
  let i: i32 = 0;
  let found: i32 = 0 - 1;
  while (i < 4096) {
    let ent: *u8 = env[i];
    if (ent == 0) {
      idx_out[0] = found;
      return i;
    }
    if (found < 0 && env_os_key_eq(ent, name, nlen) == 1) {
      found = i;
    }
    i = i + 1;
  }
  idx_out[0] = found;
  return i;
}

/**
 * Copy n entries from src into dst. Does not write the terminator.
 * @param dst **u8 — destination vector
 * @param src **u8 — source vector
 * @param n i32 — entry count
 * PLATFORM: MACOS|DARWIN
 */
function env_os_copy_slots(dst: **u8, src: **u8, n: i32): void {
  let i: i32 = 0;
  while (i < n) {
    let ent: *u8 = src[i];
    env_os_set_slot(dst, i, ent);
    i = i + 1;
  }
}

/**
 * Build "name=value" on the heap. Caller frees it.
 * @param name *u8 — key
 * @param nlen i32 — key length
 * @param value *u8 — value, not null
 * @return *u8 — new entry, or null
 * PLATFORM: MACOS|DARWIN
 */
function env_os_make_entry(name: *u8, nlen: i32, value: *u8): *u8 {
  let vlen: i64 = 0;
  unsafe {
    vlen = strlen(value);
  }
  let nbytes: i64 = (nlen as i64) + 1 + vlen + 1;
  let entry: *u8 = 0;
  unsafe {
    entry = malloc(nbytes);
  }
  if (entry == 0) {
    return 0;
  }
  unsafe {
    memcpy(entry, name, nlen as i64);
  }
  entry[nlen] = 61 as u8;
  unsafe {
    memcpy(&entry[nlen + 1], value, vlen);
  }
  entry[nlen + 1 + (vlen as i32)] = 0 as u8;
  return entry;
}

/**
 * Copy a C string into out. Returns the source length, or -1 when
 * out cannot hold the NUL.
 * @param out *u8 — destination
 * @param out_cap i32 — capacity including the NUL
 * @param src *u8 — source, not null
 * @return i32 — bytes excluding NUL, or -1
 * PLATFORM: MACOS|DARWIN
 */
function env_os_copy_out(out: *u8, out_cap: i32, src: *u8): i32 {
  let n: i64 = 0;
  unsafe {
    n = strlen(src);
  }
  if (n >= (out_cap as i64)) {
    return 0 - 1;
  }
  unsafe {
    memcpy(out, src, n + 1);
  }
  return n as i32;
}

/**
 * NUL-terminated key on the heap from raw key bytes. Caller frees it.
 * @param key *u8 — raw key
 * @param key_len i32 — byte count
 * @return *u8 — key, or null
 * PLATFORM: MACOS|DARWIN
 */
function env_os_key_z(key: *u8, key_len: i32): *u8 {
  let buf: *u8 = 0;
  unsafe {
    buf = malloc(256);
  }
  if (buf == 0) {
    return 0;
  }
  let built: i32 = 0;
  unsafe {
    built = env_build_key(key, key_len, buf);
  }
  if (built != 0) {
    unsafe {
      free(buf);
    }
    return 0;
  }
  return buf;
}

/**
 * Getenv into a caller buffer.
 * @param key *u8 — raw key bytes
 * @param key_len i32 — key length
 * @param out *u8 — destination
 * @param out_cap i32 — capacity including the NUL
 * @return i32 — bytes excluding NUL, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function env_getenv_c_impl(key: *u8, key_len: i32, out: *u8, out_cap: i32): i32 {
  if (out == 0 || out_cap <= 0) {
    return 0 - 1;
  }
  let buf: *u8 = env_os_key_z(key, key_len);
  if (buf == 0) {
    return 0 - 1;
  }
  let v: *u8 = 0;
  unsafe {
    v = link_abi_getenv(buf);
  }
  unsafe {
    free(buf);
  }
  if (v == 0) {
    return 0 - 1;
  }
  let n: i64 = 0;
  unsafe {
    n = strlen(v);
  }
  if (n < (out_cap as i64)) {
    unsafe {
      memcpy(out, v, n + 1);
    }
    return n as i32;
  }
  unsafe {
    memcpy(out, v, (out_cap as i64) - 1);
  }
  out[out_cap - 1] = 0 as u8;
  return n as i32;
}

/**
 * Getenv as a pointer into the environ entry.
 * @param key *u8 — raw key bytes
 * @param key_len i32 — key length
 * @param out_len *i32 — optional length out, or null
 * @return *u8 — value, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function env_getenv_ptr_c_impl(key: *u8, key_len: i32, out_len: *i32): *u8 {
  let buf: *u8 = env_os_key_z(key, key_len);
  if (buf == 0) {
    return 0;
  }
  let v: *u8 = 0;
  unsafe {
    v = link_abi_getenv(buf);
  }
  unsafe {
    free(buf);
  }
  if (v == 0) {
    return 0;
  }
  if (out_len != 0) {
    let n: i64 = 0;
    unsafe {
      n = strlen(v);
    }
    out_len[0] = n as i32;
  }
  return v;
}

/**
 * Getenv when the key is already NUL-terminated.
 * @param key_z *u8 — key, or null
 * @param out_len *i32 — optional length out, or null
 * @return *u8 — value, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function env_getenv_z_c_impl(key_z: *u8, out_len: *i32): *u8 {
  if (key_z == 0) {
    return 0;
  }
  let v: *u8 = 0;
  unsafe {
    v = link_abi_getenv(key_z);
  }
  if (v == 0) {
    return 0;
  }
  if (out_len != 0) {
    let n: i64 = 0;
    unsafe {
      n = strlen(v);
    }
    out_len[0] = n as i32;
  }
  return v;
}

/**
 * 1 when the key is present.
 * @param key *u8 — raw key bytes
 * @param key_len i32 — key length
 * @return i32 — 1 if present, 0 otherwise
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function env_getenv_exists_c_impl(key: *u8, key_len: i32): i32 {
  let buf: *u8 = env_os_key_z(key, key_len);
  if (buf == 0) {
    return 0;
  }
  let v: *u8 = 0;
  unsafe {
    v = link_abi_getenv(buf);
  }
  unsafe {
    free(buf);
  }
  if (v == 0) {
    return 0;
  }
  return 1;
}

/**
 * Insert or replace name=value in the Darwin environ block.
 * A new vector is malloc'd on append. The previous vector is freed
 * only when this TU allocated it. Existing entries are not freed.
 * @param name *u8 — NUL-terminated key
 * @param value *u8 — NUL-terminated value, or null for ""
 * @param overwrite i32 — 0 keeps an existing value
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN — no libc setenv
 */
#[no_mangle]
export function env_setenv_c_impl(name: *u8, value: *u8, overwrite: i32): i32 {
  if (env_os_name_ok(name) == 0) {
    return 0 - 1;
  }
  let env: **u8 = env_os_environ();
  if (env == 0) {
    return 0 - 1;
  }
  let use: *u8 = value;
  if (use == 0) {
    use = "";
  }
  let nlen: i64 = 0;
  unsafe {
    nlen = strlen(name);
  }
  let idx_slot: i32 = 0 - 1;
  let count: i32 = env_os_scan(env, name, nlen as i32, &idx_slot);
  if (idx_slot >= 0 && overwrite == 0) {
    return 0;
  }
  let entry: *u8 = env_os_make_entry(name, nlen as i32, use);
  if (entry == 0) {
    return 0 - 1;
  }
  if (idx_slot >= 0) {
    env_os_set_slot(env, idx_slot, entry);
    return 0;
  }
  let bytes: i64 = ((count + 2) as i64) * 8;
  let neu: **u8 = 0;
  unsafe {
    neu = malloc(bytes) as **u8;
  }
  if (neu == 0) {
    unsafe {
      free(entry);
    }
    return 0 - 1;
  }
  env_os_copy_slots(neu, env, count);
  env_os_set_slot(neu, count, entry);
  env_os_set_slot(neu, count + 1, 0);
  let owned: **u8 = env_os_owned_get();
  if (owned != 0 && owned == env) {
    unsafe {
      free(env as *u8);
    }
  }
  env_os_publish(neu);
  env_os_owned_set(neu);
  return 0;
}

/**
 * Drop name= from the Darwin environ block by shifting later slots.
 * The dropped entry is not freed. A missing name still returns 0.
 * @param name *u8 — NUL-terminated key
 * @return i32 — 0 on success, -1 when name is null
 * PLATFORM: MACOS|DARWIN — no libc unsetenv
 */
#[no_mangle]
export function env_unsetenv_c_impl(name: *u8): i32 {
  if (name == 0) {
    return 0 - 1;
  }
  if (name[0] == 0 as u8) {
    return 0;
  }
  let env: **u8 = env_os_environ();
  if (env == 0) {
    return 0;
  }
  let nlen: i64 = 0;
  unsafe {
    nlen = strlen(name);
  }
  let r: i32 = 0;
  let w: i32 = 0;
  while (r < 4096) {
    let ent: *u8 = env[r];
    if (ent == 0) {
      env_os_set_slot(env, w, 0);
      return 0;
    }
    if (env_os_key_eq(ent, name, nlen as i32) == 0) {
      env_os_set_slot(env, w, ent);
      w = w + 1;
    }
    r = r + 1;
  }
  return 0;
}

/**
 * Fill the process-wide temp-dir cache from TMPDIR, TEMP, TMP, or /tmp.
 * @param buf *u8 — 256-byte cache
 * @return i32 — length excluding NUL, or -1
 * PLATFORM: MACOS|DARWIN
 */
function env_os_fill_temp(buf: *u8): i32 {
  let p: *u8 = 0;
  unsafe {
    p = link_abi_getenv("TMPDIR");
  }
  if (p == 0 || p[0] == 0 as u8) {
    unsafe {
      p = link_abi_getenv("TEMP");
    }
  }
  if (p == 0 || p[0] == 0 as u8) {
    unsafe {
      p = link_abi_getenv("TMP");
    }
  }
  if (p == 0 || p[0] == 0 as u8) {
    p = "/tmp";
  }
  let n: i64 = 0;
  unsafe {
    n = strlen(p);
  }
  if (n >= 256) {
    return 0 - 1;
  }
  unsafe {
    memcpy(buf, p, n + 1);
  }
  let len_slot: *i64 = &env_temp_len;
  env_os_set_i64(len_slot, n);
  let valid_slot: *i32 = &env_temp_valid;
  env_os_set_i32(valid_slot, 1);
  return n as i32;
}

/**
 * Write the temp directory into out.
 * @param out *u8 — destination
 * @param out_cap i32 — capacity including the NUL
 * @return i32 — bytes excluding NUL, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function env_temp_dir_c_impl(out: *u8, out_cap: i32): i32 {
  if (out == 0 || out_cap <= 0) {
    return 0 - 1;
  }
  if (env_temp_valid == 1 && env_temp_buf != 0 && env_temp_len < (out_cap as i64)) {
    unsafe {
      memcpy(out, env_temp_buf, env_temp_len + 1);
    }
    return env_temp_len as i32;
  }
  let buf: *u8 = env_temp_buf;
  if (buf == 0) {
    unsafe {
      buf = malloc(256);
    }
    if (buf == 0) {
      return 0 - 1;
    }
    let buf_slot: **u8 = &env_temp_buf;
    env_os_set_ptr(buf_slot, buf);
  }
  let n: i32 = env_os_fill_temp(buf);
  if (n < 0) {
    return 0 - 1;
  }
  if ((n as i64) >= (out_cap as i64)) {
    return 0 - 1;
  }
  unsafe {
    memcpy(out, buf, (n as i64) + 1);
  }
  return n;
}

/**
 * Count environ entries.
 * @return i32 — entry count, or 0 when the block is missing
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function env_iter_count_c_impl(): i32 {
  let env: **u8 = env_os_environ();
  if (env == 0) {
    return 0;
  }
  let i: i32 = 0;
  while (i < 4096) {
    if (env[i] == 0) {
      return i;
    }
    i = i + 1;
  }
  return i;
}

/**
 * Index of '=' in ent, or -1.
 * @param ent *u8 — one environ entry
 * @return i32 — byte index of '=', or -1
 * PLATFORM: MACOS|DARWIN
 */
function env_os_eq_at(ent: *u8): i32 {
  let i: i32 = 0;
  while (i < 4096) {
    if (ent[i] == 0 as u8) {
      return 0 - 1;
    }
    if (ent[i] == 61 as u8) {
      return i;
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Byte length of ent starting at start, stopping at the NUL.
 * An interior pointer &ent[i] is not the address of that byte on
 * this compiler, so the value is measured by index.
 * @param ent *u8 — entry
 * @param start i32 — first value byte
 * @return i32 — length, or 0 when the NUL is missing
 * PLATFORM: MACOS|DARWIN
 */
function env_os_len_from(ent: *u8, start: i32): i32 {
  let i: i32 = start;
  while (i < 4096) {
    if (ent[i] == 0 as u8) {
      return i - start;
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Copy n bytes from src[start] into dst and append a NUL.
 * @param dst *u8 — destination
 * @param src *u8 — source entry
 * @param start i32 — first source byte
 * @param n i32 — byte count, excluding the NUL
 * PLATFORM: MACOS|DARWIN
 */
function env_os_copy_from(dst: *u8, src: *u8, start: i32, n: i32): void {
  let i: i32 = 0;
  while (i < n) {
    let at: i32 = start + i;
    let b: u8 = src[at];
    dst[i] = b;
    i = i + 1;
  }
  dst[n] = 0 as u8;
}

/**
 * Split environ[index] into key and value buffers.
 * @param index i32 — zero-based index
 * @param key_out *u8 — key destination
 * @param key_cap i32 — key capacity
 * @param val_out *u8 — value destination
 * @param val_cap i32 — value capacity
 * @return i32 — 1 on success, 0 when index is past the end, -1 on error
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function env_iter_at_c_impl(index: i32, key_out: *u8, key_cap: i32, val_out: *u8, val_cap: i32): i32 {
  if (index < 0 || key_out == 0 || val_out == 0 || key_cap <= 0 || val_cap <= 0) {
    return 0 - 1;
  }
  let env: **u8 = env_os_environ();
  if (env == 0) {
    return 0;
  }
  /* Copy the index into a local. Indexing with the parameter itself
   * loads the first word of the entry and treats that word as the
   * pointer. A local index loads the slot. PLATFORM: MACOS|DARWIN. */
  let slot: i32 = index;
  let ent: *u8 = env[slot];
  if (ent == 0) {
    return 0;
  }
  let eq: i32 = env_os_eq_at(ent);
  if (eq < 0) {
    return 0 - 1;
  }
  let vlen: i32 = env_os_len_from(ent, eq + 1);
  if (eq + 1 > key_cap || vlen + 1 > val_cap) {
    return 0 - 1;
  }
  if (eq > 0) {
    unsafe {
      memcpy(key_out, ent, eq as i64);
    }
  }
  key_out[eq] = 0 as u8;
  env_os_copy_from(val_out, ent, eq + 1, vlen);
  return 1;
}
