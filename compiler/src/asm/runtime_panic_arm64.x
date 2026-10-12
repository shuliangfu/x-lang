// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_panic_arm64.x — Darwin arm64 user-domain panic TU.
//
// This is the whole product body of runtime_panic.o on Darwin arm64.
// The cold ensure path pure-asms this file and does not pass the C seed
// to host cc. Linux aarch64 still compiles the C seed (environ is a
// different symbol there). This object is linked into user programs, not
// into the g05 compiler image.
//
// PLATFORM: MACOS|DARWIN arm64. Hosted user link (libSystem write/open/_exit).

export extern "C" function __NSGetEnviron(): ***u8;
export extern "C" function write(fd: i32, buf: *u8, n: usize): isize;
export extern "C" function open(path: *u8, flags: i32, mode: i32): i32;
export extern "C" function close(fd: i32): i32;
export extern "C" function getpid(): i32;
export extern "C" function __exit(status: i32): void;

/**
 * Count bytes in a NUL-terminated string.
 * @param s pointer to a C string, or null
 * @return 0 when s is null; otherwise the number of bytes before the NUL
 * PLATFORM: MACOS|DARWIN
 */
function panic_cstr_len(s: *u8): i32 {
  if (s == 0) { return 0; }
  let n: i32 = 0;
  while (s[n] != 0 as u8) {
    n = n + 1;
    if (n >= 4096) { return n; }
  }
  return n;
}

/**
 * Copy a C string into buf at pos, stopping before cap.
 * @param buf destination buffer
 * @param cap buffer size in bytes
 * @param pos current write index
 * @param s source C string, or null
 * @return new write index
 * PLATFORM: MACOS|DARWIN
 */
function panic_append_cstr(buf: *u8, cap: i32, pos: i32, s: *u8): i32 {
  if (buf == 0 || s == 0 || cap <= 0) { return pos; }
  let i: i32 = 0;
  while (s[i] != 0 as u8) {
    if (pos + 1 >= cap) { return pos; }
    buf[pos] = s[i];
    pos = pos + 1;
    i = i + 1;
  }
  return pos;
}

/**
 * Append a signed decimal integer.
 * @param buf destination buffer
 * @param cap buffer size in bytes
 * @param pos current write index
 * @param v value to format
 * @return new write index
 * PLATFORM: MACOS|DARWIN
 */
function panic_append_i32(buf: *u8, cap: i32, pos: i32, v: i32): i32 {
  if (buf == 0 || cap <= 0) { return pos; }
  if (v < 0) {
    if (pos + 1 >= cap) { return pos; }
    buf[pos] = 45 as u8;
    pos = pos + 1;
    // Two's-complement minimum has no positive i32 opposite. Print the
    // digits of the wrapped value rather than compare a literal that
    // does not fit in i32.
    v = 0 - v;
  }
  let digs: u8[16] = [];
  let n: i32 = 0;
  if (v == 0) {
    digs[0] = 48 as u8;
    n = 1;
  }
  while (v > 0) {
    let d: i32 = v % 10;
    digs[n] = (d + 48) as u8;
    n = n + 1;
    v = v / 10;
    if (n >= 16) { break; }
  }
  while (n > 0) {
    n = n - 1;
    if (pos + 1 >= cap) { return pos; }
    buf[pos] = digs[n];
    pos = pos + 1;
  }
  return pos;
}

/**
 * Write exactly n bytes from a buffer to a file descriptor.
 * @param fd destination descriptor
 * @param buf source bytes
 * @param n byte count
 * @return void
 * PLATFORM: MACOS|DARWIN — libc write
 */
function panic_write_n(fd: i32, buf: *u8, n: i32): void {
  if (buf == 0 || n <= 0) { return; }
  unsafe {
    write(fd, buf, n as usize);
  }
}

/**
 * Write a C string to a file descriptor.
 * @param fd destination descriptor
 * @param s NUL-terminated string, or null
 * @return void
 * PLATFORM: MACOS|DARWIN
 */
function panic_write_cstr(fd: i32, s: *u8): void {
  let n: i32 = panic_cstr_len(s);
  panic_write_n(fd, s, n);
}

/**
 * Scan the Darwin process environment for name.
 * Null, empty, or a missing block returns null. The returned pointer
 * addresses the value bytes after '=' inside the environ entry.
 * @param name NUL-terminated key
 * @return value pointer, or null
 * PLATFORM: MACOS|DARWIN — _NSGetEnviron, not libc getenv
 */
#[no_mangle]
export function link_abi_getenv_impl(name: *u8): *u8 {
  if (name == 0) { return 0; }
  if (name[0] == 0 as u8) { return 0; }
  let nlen: i32 = panic_cstr_len(name);
  if (nlen <= 0) { return 0; }
  unsafe {
    let slot: ***u8 = __NSGetEnviron();
    if (slot == 0) { return 0; }
    let env: **u8 = slot[0];
    if (env == 0) { return 0; }
    let i: i32 = 0;
    while (i < 4096) {
      let ent: *u8 = env[i];
      if (ent == 0) { return 0; }
      let k: i32 = 0;
      let matched: i32 = 1;
      while (k < nlen) {
        if (ent[k] != name[k]) {
          matched = 0;
          break;
        }
        k = k + 1;
      }
      if (matched == 1 && ent[nlen] == 61 as u8) {
        return &ent[nlen + 1];
      }
      i = i + 1;
    }
  }
  return 0;
}

/**
 * Public getenv face: null and empty keys return null.
 * @param name NUL-terminated key
 * @return null on null or empty; otherwise link_abi_getenv_impl
 * PLATFORM: MACOS|DARWIN user-domain strong symbol
 */
#[no_mangle]
export function link_abi_getenv(name: *u8): *u8 {
  if (name == 0) { return 0; }
  if (name[0] == 0 as u8) { return 0; }
  return link_abi_getenv_impl(name);
}

/**
 * When XLANG_CRASH_EVIDENCE=1, write a one-line note to stderr and,
 * if XLANG_CRASH_EVIDENCE_DIR is set, a small text file in that directory.
 * @param has_msg panic tag (0 bare, 1 integer, 2 cstr)
 * @param msg_val integer evidence
 * @return void
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_crash_evidence_minimal_impl(has_msg: i32, msg_val: i32): void {
  let en: *u8 = link_abi_getenv("XLANG_CRASH_EVIDENCE");
  if (en == 0) { return; }
  if (en[0] != 49 as u8) { return; }
  let pid: i32 = 0;
  unsafe { pid = getpid(); }
  let note: u8[160] = [];
  let pos: i32 = 0;
  pos = panic_append_cstr(&note[0], 160, pos, "note: crash evidence: panic=");
  pos = panic_append_i32(&note[0], 160, pos, has_msg);
  pos = panic_append_cstr(&note[0], 160, pos, " msg=");
  pos = panic_append_i32(&note[0], 160, pos, msg_val);
  pos = panic_append_cstr(&note[0], 160, pos, " frames=0 pid=");
  pos = panic_append_i32(&note[0], 160, pos, pid);
  pos = panic_append_cstr(&note[0], 160, pos, "\n");
  panic_write_n(2, &note[0], pos);
  let dir: *u8 = link_abi_getenv("XLANG_CRASH_EVIDENCE_DIR");
  if (dir == 0) { return; }
  if (dir[0] == 0 as u8) { return; }
  let path: u8[1024] = [];
  let ppos: i32 = 0;
  ppos = panic_append_cstr(&path[0], 1024, ppos, dir);
  ppos = panic_append_cstr(&path[0], 1024, ppos, "/xlang-crash-");
  ppos = panic_append_i32(&path[0], 1024, ppos, pid);
  ppos = panic_append_cstr(&path[0], 1024, ppos, ".txt");
  if (ppos + 1 >= 1024) { return; }
  path[ppos] = 0 as u8;
  // O_WRONLY|O_CREAT|O_TRUNC = 0x601, mode 0644.
  let fd: i32 = 0;
  unsafe { fd = open(&path[0], 1537, 420); }
  if (fd < 0) { return; }
  let body: u8[256] = [];
  let bpos: i32 = 0;
  bpos = panic_append_cstr(&body[0], 256, bpos, "panic_has_msg=");
  bpos = panic_append_i32(&body[0], 256, bpos, has_msg);
  bpos = panic_append_cstr(&body[0], 256, bpos, "\npanic_msg=");
  bpos = panic_append_i32(&body[0], 256, bpos, msg_val);
  bpos = panic_append_cstr(&body[0], 256, bpos, "\nframes=0\npid=");
  bpos = panic_append_i32(&body[0], 256, bpos, pid);
  bpos = panic_append_cstr(&body[0], 256, bpos, "\n");
  panic_write_n(fd, &body[0], bpos);
  unsafe { close(fd); }
  let note2: u8[160] = [];
  let n2: i32 = 0;
  n2 = panic_append_cstr(&note2[0], 160, n2, "note: crash evidence: bundle=");
  n2 = panic_append_cstr(&note2[0], 160, n2, &path[0]);
  n2 = panic_append_cstr(&note2[0], 160, n2, "\n");
  panic_write_n(2, &note2[0], n2);
}

/**
 * Public wrapper around the crash-evidence implementation.
 * @param has_msg panic tag
 * @param msg_val integer evidence
 * @return void
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_crash_evidence_minimal(has_msg: i32, msg_val: i32): void {
  xlang_crash_evidence_minimal_impl(has_msg, msg_val);
}

/**
 * Weak collector used when a program also links a stronger evidence body.
 * Ensure weakens this symbol after pure-asm.
 * @param has_msg panic tag
 * @param msg_val integer evidence
 * @return void
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void {
  xlang_crash_evidence_minimal_impl(has_msg, msg_val);
}

/**
 * Product panic entry. has_msg 2 prints a C string, 1 prints an integer,
 * then evidence is collected and the process exits 1.
 * @param has_msg 0 bare, 1 integer, 2 NUL cstr in msg_val
 * @param msg_val integer evidence or a pointer (isize width)
 * @return void — does not return
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_panic_(has_msg: i32, msg_val: isize): void {
  if (has_msg == 2) {
    let s: *u8 = msg_val as *u8;
    if (s != 0 && s[0] != 0 as u8) {
      panic_write_cstr(2, "panic: ");
      panic_write_cstr(2, s);
      panic_write_cstr(2, "\n");
    } else {
      panic_write_cstr(2, "panic\n");
    }
  } else if (has_msg == 1) {
    let buf: u8[32] = [];
    let pos: i32 = 0;
    pos = panic_append_cstr(&buf[0], 32, pos, "panic: ");
    pos = panic_append_i32(&buf[0], 32, pos, msg_val as i32);
    pos = panic_append_cstr(&buf[0], 32, pos, "\n");
    panic_write_n(2, &buf[0], pos);
  }
  xlang_crash_evidence_collect_c(has_msg, msg_val as i32);
  unsafe { __exit(1); }
}

/**
 * Doc anchor so the translation unit is never empty.
 * @return 0
 * PLATFORM: MACOS|DARWIN
 */
export function runtime_panic_arm64_x_doc_anchor(): i32 {
  return 0;
}
