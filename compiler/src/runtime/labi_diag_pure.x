// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// link_abi diag pure helpers (G.9 English; body is authoritative).
// link_abi diag pure helpers (G.9 English; body is authoritative).
// link_abi diag pure helpers (G.9 English; body is authoritative).
//
// R2 full：
// link_abi diag pure helpers (G.9 English; body is authoritative).
// link_abi diag pure helpers (G.9 English; body is authoritative).
// link_abi diag pure helpers (G.9 English; body is authoritative).
// link_abi diag pure helpers (G.9 English; body is authoritative).
// link_abi diag pure helpers (G.9 English; body is authoritative).

export extern "C" function strcmp(a: *u8, b: *u8): i32;
export extern "C" function diag_report_with_code(
  file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8
): void;

/* See signature and body for contracts. */
export extern "C" function link_diag_ld_debug_argv_impl(label: *u8, argv: *u8): void;

/* Cap residual (mega always _impl): capture errno + strerror (libc).
 * wave217: public pure thin owns link_diag_strerror_current under hybrid L1. */
export extern "C" function link_diag_strerror_current_impl(): *u8;

/* Cap residual (mega always _impl): POSIX wait status macros (WIFSIGNALED /
 * WTERMSIG / WIFEXITED / WEXITSTATUS). wave217: public pure thin under hybrid L1.
 * PLATFORM: POSIX (macOS + Linux product hosts); Windows hybrid win32_compat. */
export extern "C" function link_diag_wait_is_signaled_impl(status: i32): i32;
export extern "C" function link_diag_wait_code_impl(status: i32): i32;

/* Cap residual (wave216): waitpid + EINTR retry + strerror report (mega always). */
export extern "C" function shu_waitpid_retry_impl(pid: i64, status_out: *i32): i32;

/* Cap residual (wave219): host spawn body (POSIX fork+execvp+waitpid / Windows _spawnvp).
 * Public pure thin owns null/empty gates under hybrid L1. argv is NULL-terminated
 * vector; typed as *u8 (opaque pointer) so product codegen emits the export body
 * (export fn with **u8 params currently drops the body — G.7 keep *u8 ABI-width).
 * PLATFORM: SHARED residual contract / POSIX fork / WINDOWS _spawnvp. */
export extern "C" function shux_spawn_sync_impl(prog: *u8, argv: *u8): i32;

/** Diag pure helper; see signature and body for contracts. */
#[no_mangle]
export function labi_diag_append(dst: *u8, cap: i32, src: *u8): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  if (dst == 0 as *u8) {
    return 0;
  }
  if (src == 0 as *u8) {
    while (i < cap) {
      if (dst[i as usize] == 0) {
        return i;
      }
      i = i + 1;
    }
    return 0;
  }
  while (i < cap) {
    if (dst[i as usize] == 0) {
      break;
    }
    i = i + 1;
  }
  if (i >= cap) {
    dst[(cap - 1) as usize] = 0;
    return cap - 1;
  }
  j = 0;
  while (i + 1 < cap) {
    let c: u8 = src[j as usize];
    if (c == 0) {
      break;
    }
    dst[i as usize] = c;
    i = i + 1;
    j = j + 1;
  }
  dst[i as usize] = 0;
  return i;
}

/**
 * Append decimal representation of `v` onto a NUL-terminated `dst` buffer.
 * Digits are built least-significant-first in a small stack buffer, then
 * reversed and appended via `labi_diag_append`. Handles 0 and negatives.
 * Wait-status / exit codes are small; INT_MIN is not required for product use.
 * @param dst *u8 — destination buffer (must be writable; may already hold text)
 * @param cap i32 — capacity of dst including trailing NUL
 * @param v i32 — value to format as decimal ASCII
 * @return void
 * PLATFORM: SHARED — pure digit orch; no libc sprintf.
 */
#[no_mangle]
export function labi_diag_append_i32(dst: *u8, cap: i32, v: i32): void {
  let dig: u8[16] = [];
  let n: i32 = v;
  let i: i32 = 0;
  let j: i32 = 0;
  let neg: i32 = 0;
  let a: u8 = 0;
  dig[0] = 0;
  if (n == 0) {
    dig[0] = 48;
    dig[1] = 0;
    labi_diag_append(dst, cap, &dig[0]);
    return;
  }
  if (n < 0) {
    neg = 1;
    n = 0 - n;
  }
  while (n > 0) {
    if (i >= 15) {
      break;
    }
    dig[i] = (48 + (n - (n / 10) * 10)) as u8;
    n = n / 10;
    i = i + 1;
  }
  if (neg != 0) {
    if (i < 15) {
      dig[i] = 45;
      i = i + 1;
    }
  }
  j = 0;
  while (j < i / 2) {
    a = dig[j];
    dig[j] = dig[i - 1 - j];
    dig[i - 1 - j] = a;
    j = j + 1;
  }
  dig[i] = 0;
  labi_diag_append(dst, cap, &dig[0]);
}

/* See signature and body for contracts. */
#[no_mangle]
export function link_diag_code_for_kind(kind: *u8): *u8 {
  if (kind == 0 as *u8) {
    let p: *u8 = "PRC001";
    return p;
  }
  unsafe {
    let be: *u8 = "build error";
    if (strcmp(kind, be) == 0) {
      let p: *u8 = "BLD001";
      return p;
    }
    let pe: *u8 = "process error";
    if (strcmp(kind, pe) == 0) {
      let p: *u8 = "PRC001";
      return p;
    }
  }
  return 0 as *u8;
}

/** Exported function `link_diag_runtime_obj_resolve_fail`.
 * Implements `link_diag_runtime_obj_resolve_fail`.
 * @param obj_name *u8
 * @param hint *u8
 * @return void
 */
#[no_mangle]
export function link_diag_runtime_obj_resolve_fail(obj_name: *u8, hint: *u8): void {
  let on: *u8 = obj_name;
  let msg: u8[320] = [];
  let kind: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  if (on == 0 as *u8) {
    on = "runtime object";
  }
  msg[0] = 0;
  labi_diag_append(&msg[0], 320, "cannot resolve compiler directory to build ");
  labi_diag_append(&msg[0], 320, on);
  if (hint != 0 as *u8) {
    if (hint[0 as usize] != 0) {
      labi_diag_append(&msg[0], 320, " (");
      labi_diag_append(&msg[0], 320, hint);
      labi_diag_append(&msg[0], 320, ")");
    }
  }
  kind = "build error";
  code = "BLD001";
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, kind, code, &msg[0], 0 as *u8);
  }
}

/** Exported function `link_diag_runtime_source_missing`.
 * Implements `link_diag_runtime_source_missing`.
 * @param obj_name *u8
 * @param source_path *u8
 * @return void
 */
#[no_mangle]
export function link_diag_runtime_source_missing(obj_name: *u8, source_path: *u8): void {
  let on: *u8 = obj_name;
  let sp: *u8 = source_path;
  let msg: u8[320] = [];
  let kind: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  if (on == 0 as *u8) {
    on = "runtime object";
  }
  if (sp == 0 as *u8) {
    sp = "?";
  }
  msg[0] = 0;
  labi_diag_append(&msg[0], 320, on);
  labi_diag_append(&msg[0], 320, " source not found at ");
  labi_diag_append(&msg[0], 320, sp);
  kind = "build error";
  code = "BLD001";
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, kind, code, &msg[0], 0 as *u8);
  }
}

/** Function `link_diag_runtime_source_missing_under`.
 * Purpose: implements `link_diag_runtime_source_missing_under`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
export function link_diag_runtime_source_missing_under(
  obj_name: *u8, base_dir: *u8, suffix: *u8
): void {
  let on: *u8 = obj_name;
  let bd: *u8 = base_dir;
  let sf: *u8 = suffix;
  let msg: u8[384] = [];
  let kind: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  if (on == 0 as *u8) {
    on = "runtime object";
  }
  if (bd == 0 as *u8) {
    bd = "?";
  }
  if (sf == 0 as *u8) {
    sf = "";
  }
  msg[0] = 0;
  labi_diag_append(&msg[0], 384, on);
  labi_diag_append(&msg[0], 384, " source not found under ");
  labi_diag_append(&msg[0], 384, bd);
  labi_diag_append(&msg[0], 384, sf);
  kind = "build error";
  code = "BLD001";
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, kind, code, &msg[0], 0 as *u8);
  }
}

/** Exported function `link_diag_runtime_obj_missing`.
 * Implements `link_diag_runtime_obj_missing`.
 * @param obj_name *u8
 * @param out_o *u8
 * @return void
 */
#[no_mangle]
export function link_diag_runtime_obj_missing(obj_name: *u8, out_o: *u8): void {
  let on: *u8 = obj_name;
  let oo: *u8 = out_o;
  let msg: u8[320] = [];
  let kind: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  if (on == 0 as *u8) {
    on = "runtime object";
  }
  if (oo == 0 as *u8) {
    oo = "?";
  }
  msg[0] = 0;
  labi_diag_append(&msg[0], 320, on);
  labi_diag_append(&msg[0], 320, " missing after cc -c (expected near ");
  labi_diag_append(&msg[0], 320, oo);
  labi_diag_append(&msg[0], 320, ")");
  kind = "build error";
  code = "BLD001";
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, kind, code, &msg[0], 0 as *u8);
  }
}

/** Exported function `link_diag_freestanding_missing`.
 * Memory management helper `link_diag_freestanding_missing`.
 * @param obj_name *u8
 * @param symbol_name *u8
 * @return void
 */
#[no_mangle]
export function link_diag_freestanding_missing(obj_name: *u8, symbol_name: *u8): void {
  let on: *u8 = obj_name;
  let sn: *u8 = symbol_name;
  let msg: u8[320] = [];
  let kind: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  if (on == 0 as *u8) {
    on = "runtime object";
  }
  msg[0] = 0;
  labi_diag_append(&msg[0], 320, "freestanding link missing ");
  labi_diag_append(&msg[0], 320, on);
  if (sn != 0 as *u8) {
    if (sn[0 as usize] != 0) {
      labi_diag_append(&msg[0], 320, " (user references ");
      labi_diag_append(&msg[0], 320, sn);
      labi_diag_append(&msg[0], 320, ")");
    }
  }
  kind = "link error";
  code = "BLD001";
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, kind, code, &msg[0], 0 as *u8);
  }
}

/** Exported function `link_diag_freestanding_unsupported`.
 * Memory management helper `link_diag_freestanding_unsupported`.
 * @return void
 */
#[no_mangle]
export function link_diag_freestanding_unsupported(): void {
  let msg: u8[192] = [];
  let kind: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  msg[0] = 0;
  /* See signature and body for contracts. */
  labi_diag_append(&msg[0], 192, "-freestanding / SHUX_FREESTANDING is only supported for ");
  labi_diag_append(&msg[0], 192, "Linux ELF x86_64 (-o prog, not .o/.obj on macOS/COFF)");
  kind = "link error";
  code = "BLD001";
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, kind, code, &msg[0], 0 as *u8);
  }
}

/** Exported function `link_diag_ld_debug_push`.
 * Implements `link_diag_ld_debug_push`.
 * @param rel *u8
 * @param stage *u8
 * @param path *u8
 * @return void
 */
#[no_mangle]
export function link_diag_ld_debug_push(rel: *u8, stage: *u8, path: *u8): void {
  let r: *u8 = rel;
  let st: *u8 = stage;
  let p: *u8 = path;
  let msg: u8[320] = [];
  let kind: *u8 = 0 as *u8;
  if (r == 0 as *u8) {
    r = "(null)";
  }
  if (st == 0 as *u8) {
    st = "path";
  }
  if (p == 0 as *u8) {
    p = "(null)";
  }
  msg[0] = 0;
  labi_diag_append(&msg[0], 320, "ld debug: push ");
  labi_diag_append(&msg[0], 320, r);
  labi_diag_append(&msg[0], 320, " ");
  labi_diag_append(&msg[0], 320, st);
  labi_diag_append(&msg[0], 320, "=");
  labi_diag_append(&msg[0], 320, p);
  kind = "note";
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, kind, 0 as *u8, &msg[0], 0 as *u8);
  }
}

/** Exported function `link_diag_ld_debug_argv`.
 * Implements `link_diag_ld_debug_argv`.
 * @param label *u8
 * @param argv *u8
 * @return void
 */
#[no_mangle]
export function link_diag_ld_debug_argv(label: *u8, argv: *u8): void {
  /* See signature and body for contracts. */
  unsafe {
    link_diag_ld_debug_argv_impl(label, argv);
  }
}

/**
 * Report a tool (cc/ld/…) failure from a wait(2) status word.
 * Pure owns message orch: `"<tool> failed (signal N)"` or `"<tool> failed (exit N)"`
 * then `diag_report_with_code` (build error / BLD001). Cap residual wait decode:
 * pure thin `link_diag_wait_*` → mega always `_impl` (WIF* macros; wave217).
 * Null tool → literal `"tool"`. Integer formatting via pure `labi_diag_append_i32`.
 * @param tool *u8 — tool name for the message (null → "tool")
 * @param status i32 — raw wait status (not a plain exit code)
 * @return void
 * wave112: closes soft Cap residual "tool_status body always mega reportf under hybrid".
 * PLATFORM: SHARED — hybrid L1 pure; mega cold twin under #ifndef SHUX_LABI_DIAG_PURE_FROM_X.
 */
#[no_mangle]
export function link_diag_tool_status(tool: *u8, status: i32): void {
  let t: *u8 = tool;
  let msg: u8[320] = [];
  let kind: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  let sig: i32 = 0;
  let c: i32 = 0;
  if (t == 0 as *u8) {
    t = "tool";
  }
  msg[0] = 0;
  labi_diag_append(&msg[0], 320, t);
  /* Public thin (same module) → Cap residual wait decode _impl. */
  sig = link_diag_wait_is_signaled(status);
  c = link_diag_wait_code(status);
  if (sig != 0) {
    labi_diag_append(&msg[0], 320, " failed (signal ");
  } else {
    labi_diag_append(&msg[0], 320, " failed (exit ");
  }
  labi_diag_append_i32(&msg[0], 320, c);
  labi_diag_append(&msg[0], 320, ")");
  kind = "build error";
  code = "BLD001";
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, kind, code, &msg[0], 0 as *u8);
  }
}

/**
 * Report a runtime object build failure from a wait(2) status word.
 * Pure owns message orch: `"failed to build <obj> (signal N)"` or
 * `"failed to build <obj> (exit N)"` then `diag_report_with_code` (build error / BLD001).
 * Cap residual wait decode same as `link_diag_tool_status`.
 * Null obj_name → literal `"runtime object"`.
 * @param obj_name *u8 — object leaf name (null → "runtime object")
 * @param status i32 — raw wait status (or synthetic -1 when no wait word)
 * @return void
 * wave112: closes soft Cap residual "obj_build_status body always mega reportf under hybrid".
 * PLATFORM: SHARED — hybrid L1 pure; mega cold twin under #ifndef SHUX_LABI_DIAG_PURE_FROM_X.
 */
#[no_mangle]
export function link_diag_runtime_obj_build_status(obj_name: *u8, status: i32): void {
  let on: *u8 = obj_name;
  let msg: u8[320] = [];
  let kind: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  let sig: i32 = 0;
  let c: i32 = 0;
  if (on == 0 as *u8) {
    on = "runtime object";
  }
  msg[0] = 0;
  labi_diag_append(&msg[0], 320, "failed to build ");
  labi_diag_append(&msg[0], 320, on);
  /* Public thin (same module) → Cap residual wait decode _impl. */
  sig = link_diag_wait_is_signaled(status);
  c = link_diag_wait_code(status);
  if (sig != 0) {
    labi_diag_append(&msg[0], 320, " (signal ");
  } else {
    labi_diag_append(&msg[0], 320, " (exit ");
  }
  labi_diag_append_i32(&msg[0], 320, c);
  labi_diag_append(&msg[0], 320, ")");
  kind = "build error";
  code = "BLD001";
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, kind, code, &msg[0], 0 as *u8);
  }
}

/**
 * Report a process/link errno failure: `"<op> failed: <strerror>"`.
 * Pure owns kind/op defaults, `link_diag_code_for_kind`, message append, and
 * `diag_report_with_code`. Cap residual strerror: pure thin
 * `link_diag_strerror_current` → mega always `_impl` (errno+strerror; wave217).
 * Call strerror first before other Cap calls that may clobber errno.
 * Null kind → `"process error"`; null/empty op → `"system call"`.
 * @param kind *u8 — diagnostic kind (null → process error)
 * @param op *u8 — failed operation label
 * @return void
 * wave113: closes soft Cap residual "link_diag_errno body always mega reportf under hybrid".
 * PLATFORM: SHARED — hybrid L1 pure; mega cold twin under #ifndef SHUX_LABI_DIAG_PURE_FROM_X.
 */
#[no_mangle]
export function link_diag_errno(kind: *u8, op: *u8): void {
  let k: *u8 = kind;
  let o: *u8 = op;
  let err: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  let msg: u8[320] = [];
  if (k == 0 as *u8) {
    k = "process error";
  }
  if (o == 0 as *u8) {
    o = "system call";
  } else {
    if (o[0] == 0) {
      o = "system call";
    }
  }
  /* Public thin (same module) → Cap residual strerror _impl. */
  err = link_diag_strerror_current();
  if (err == 0 as *u8) {
    err = "unknown error";
  }
  code = link_diag_code_for_kind(k);
  msg[0] = 0;
  labi_diag_append(&msg[0], 320, o);
  labi_diag_append(&msg[0], 320, " failed: ");
  labi_diag_append(&msg[0], 320, err);
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, k, code, &msg[0], 0 as *u8);
  }
}

/**
 * Report a process/link errno failure with path:
 * `"<op> failed for '<path>': <strerror>"`.
 * Null/empty path → same as `link_diag_errno(kind, op)`.
 * Cap residual strerror same as `link_diag_errno` (called first).
 * @param kind *u8 — diagnostic kind (null → process error)
 * @param op *u8 — failed operation label
 * @param path *u8 — path involved in the failure
 * @return void
 * wave113: closes soft Cap residual "link_diag_errno_path body always mega reportf".
 * PLATFORM: SHARED — hybrid L1 pure; mega cold twin under #ifndef SHUX_LABI_DIAG_PURE_FROM_X.
 */
#[no_mangle]
export function link_diag_errno_path(kind: *u8, op: *u8, path: *u8): void {
  let k: *u8 = kind;
  let o: *u8 = op;
  let p: *u8 = path;
  let err: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  let msg: u8[384] = [];
  if (p == 0 as *u8) {
    link_diag_errno(k, o);
    return;
  }
  if (p[0] == 0) {
    link_diag_errno(k, o);
    return;
  }
  if (k == 0 as *u8) {
    k = "process error";
  }
  if (o == 0 as *u8) {
    o = "system call";
  } else {
    if (o[0] == 0) {
      o = "system call";
    }
  }
  /* Public thin (same module) → Cap residual strerror _impl. */
  err = link_diag_strerror_current();
  if (err == 0 as *u8) {
    err = "unknown error";
  }
  code = link_diag_code_for_kind(k);
  msg[0] = 0;
  labi_diag_append(&msg[0], 384, o);
  labi_diag_append(&msg[0], 384, " failed for '");
  labi_diag_append(&msg[0], 384, p);
  labi_diag_append(&msg[0], 384, "': ");
  labi_diag_append(&msg[0], 384, err);
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, k, code, &msg[0], 0 as *u8);
  }
}

/**
 * Parse a classic `perror`-style link/process message and report via pure
 * `link_diag_errno` / `link_diag_errno_path` (wave113).
 * Accepts optional leading `shux: ` prefix. If the remaining text ends with
 * `op (path)` (last `(` / `)` with trailing NUL after `)`), splits into op + path
 * for `link_diag_errno_path`; otherwise reports the whole remaining text as op.
 * Null/empty msg → `system call` with no path.
 * @param msg *u8 — NUL-terminated diagnostic text; null treated as empty
 * @return void
 * Cap residual: pure thin `link_diag_strerror_current` → `_impl` (errno+strerror;
 * mega always; wave217). Pure owns prefix strip + paren split + message orch.
 * wave111: perror body pure; wave113: errno/_path message body pure.
 * PLATFORM: SHARED — hybrid L1 pure; mega cold twin under #ifndef SHUX_LABI_DIAG_PURE_FROM_X.
 */
#[no_mangle]
export function shux_link_perror(msg: *u8): void {
  let pe: *u8 = "process error";
  let sc: *u8 = "system call";
  let base: *u8 = msg;
  let start: i32 = 0;
  let n: i32 = 0;
  let i: i32 = 0;
  let lparen: i32 = 0 - 1;
  let rparen: i32 = 0 - 1;
  let op_end: i32 = 0;
  let op_len: i32 = 0;
  let path_len: i32 = 0;
  let j: i32 = 0;
  let op_buf: u8[128] = [];
  let path_buf: u8[160] = [];
  let text: *u8 = 0 as *u8;

  if (base == 0 as *u8) {
    link_diag_errno(pe, sc);
    return;
  }
  if (base[0] == 0) {
    link_diag_errno(pe, sc);
    return;
  }

  /* Optional "shux: " prefix (6 ASCII bytes). Nested checks keep short strings
   * from reading past NUL (same short-circuit intent as C strncmp). */
  if (base[0] == 115) {
    if (base[1] == 104) {
      if (base[2] == 117) {
        if (base[3] == 120) {
          if (base[4] == 58) {
            if (base[5] == 32) {
              start = 6;
            }
          }
        }
      }
    }
  }

  n = start;
  while (base[n] != 0) {
    n = n + 1;
  }

  /* Last '(' and ')' in [start, n). */
  i = start;
  while (i < n) {
    if (base[i] == 40) {
      lparen = i;
    }
    if (base[i] == 41) {
      rparen = i;
    }
    i = i + 1;
  }

  if (lparen >= start && rparen > lparen && rparen + 1 == n) {
    /* Trim trailing spaces before '('. */
    op_end = lparen;
    while (op_end > start && base[op_end - 1] == 32) {
      op_end = op_end - 1;
    }
    op_len = op_end - start;
    if (op_len >= 128) {
      op_len = 127;
    }
    path_len = rparen - lparen - 1;
    if (path_len >= 160) {
      path_len = 159;
    }
    j = 0;
    while (j < op_len) {
      op_buf[j as usize] = base[(start + j) as usize];
      j = j + 1;
    }
    op_buf[op_len as usize] = 0;
    j = 0;
    while (j < path_len) {
      path_buf[j as usize] = base[(lparen + 1 + j) as usize];
      j = j + 1;
    }
    path_buf[path_len as usize] = 0;
    link_diag_errno_path(pe, &op_buf[0], &path_buf[0]);
    return;
  }

  /* Whole remaining text as op (pointer into msg after optional prefix). */
  text = &base[start];
  link_diag_errno(pe, text);
}

/**
 * Capture current errno and return libc strerror (or "unknown error").
 * Thin pure public: Cap residual `link_diag_strerror_current_impl` holds errno
 * snapshot + strerror (must run before other Cap calls that may clobber errno).
 * @return *u8 — non-null C string (libc buffer or static "unknown error")
 * Pure orch: ≡ mega public thin before Cap residual strerror body (wave217).
 * Why (wave217): hybrid still had strerror_current body always mega C
 * (errno+strerror); G.7 single public authority under L1 hybrid.
 * Cap residual: link_diag_strerror_current_impl (mega always).
 * PLATFORM: SHARED — libc errno/strerror on product hosts.
 * Track-L: #[no_mangle] keeps short surface name for pure errno/_path orch.
 */
#[no_mangle]
export function link_diag_strerror_current(): *u8 {
  unsafe {
    return link_diag_strerror_current_impl();
  }
  return 0 as *u8;
}

/**
 * Decode wait(2) status: 1 if WIFSIGNALED, else 0.
 * Thin pure public: Cap residual `link_diag_wait_is_signaled_impl` holds WIF*.
 * @param status i32 — raw wait status word
 * @return i32 — 1 signaled, 0 otherwise
 * Pure orch: ≡ mega public thin before Cap residual wait decode (wave217).
 * Cap residual: link_diag_wait_is_signaled_impl (mega always).
 * PLATFORM: SHARED orch; residual is POSIX wait macros (win32_compat on Windows).
 * Track-L: #[no_mangle] keeps short surface name for tool/obj status orch.
 */
#[no_mangle]
export function link_diag_wait_is_signaled(status: i32): i32 {
  unsafe {
    return link_diag_wait_is_signaled_impl(status);
  }
  return 0;
}

/**
 * Decode wait(2) status to signal number or exit code.
 * Thin pure public: Cap residual `link_diag_wait_code_impl` holds WTERMSIG /
 * WEXITSTATUS (or -1 when neither signaled nor exited).
 * @param status i32 — raw wait status word
 * @return i32 — signal number, exit code, or -1
 * Pure orch: ≡ mega public thin before Cap residual wait decode (wave217).
 * Cap residual: link_diag_wait_code_impl (mega always).
 * PLATFORM: SHARED orch; residual is POSIX wait macros (win32_compat on Windows).
 * Track-L: #[no_mangle] keeps short surface name for tool/obj status orch.
 */
#[no_mangle]
export function link_diag_wait_code(status: i32): i32 {
  unsafe {
    return link_diag_wait_code_impl(status);
  }
  return 0 - 1;
}

/**
 * Wait for child `pid`; retry on EINTR; optional status store.
 * Thin pure public: Cap residual `shu_waitpid_retry_impl` holds waitpid loop,
 * errno capture, libc strerror, and process-error reportf.
 * @param pid i64 — child process id (POSIX pid_t width on product hosts)
 * @param status_out *i32 — optional wait status out; null allowed (impl skips store)
 * @return i32 — 0 success, -1 waitpid failure after non-EINTR error
 * Pure orch: ≡ mega public thin before Cap residual waitpid body (wave216).
 * Why (wave216): hybrid still had shu_waitpid_retry body always mega C
 * (waitpid+EINTR+strerror+diag); G.7 single public authority under L1 hybrid.
 * Cap residual: shu_waitpid_retry_impl (mega always).
 * PLATFORM: SHARED orch; residual is POSIX waitpid (Windows spawn paths skip).
 * Track-L: #[no_mangle] keeps short surface name for spawn/ld/cc callers.
 */
#[no_mangle]
export function shu_waitpid_retry(pid: i64, status_out: *i32): i32 {
  unsafe {
    return shu_waitpid_retry_impl(pid, status_out);
  }
  return 0 - 1;
}

/**
 * Synchronously run prog with argv (PATH lookup); wait for exit 0.
 * Thin pure public: null/empty prog or null argv → -1 without residual.
 * Cap residual `shux_spawn_sync_impl` holds fork+execvp+waitpid (POSIX) or
 * `_spawnvp` (Windows). Uses public `shu_waitpid_retry` inside residual.
 * @param prog *u8 — program name for PATH lookup; null/empty rejected at pure gate
 * @param argv *u8 — opaque pointer to NULL-terminated argv vector (C char** width);
 *   typed *u8 so product codegen emits the body (see export-extern note above)
 * @return i32 — 0 on child exit 0; non-zero failure (-1 or child status)
 * Pure orch: ≡ mega public thin before Cap residual spawn body (wave219).
 * Why (wave219): hybrid still had shux_spawn_sync body always mega C
 * (fork/exec/wait or _spawnvp); G.7 single public authority under L1 hybrid.
 * Cap residual: shux_spawn_sync_impl (mega always).
 * PLATFORM: SHARED orch; residual is POSIX fork/exec or WINDOWS _spawnvp.
 * Track-L: #[no_mangle] keeps short surface name for invoke_cc / ld / strip callers.
 */
#[no_mangle]
export function shux_spawn_sync(prog: *u8, argv: *u8): i32 {
  if (prog == 0 as *u8) {
    return 0 - 1;
  }
  if (prog[0] == 0) {
    return 0 - 1;
  }
  if (argv == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    return shux_spawn_sync_impl(prog, argv);
  }
  return 0 - 1;
}

/* Pure audit: public L1 gates in this slice (code_for_kind + 8 report).
 * wave111: shux_link_perror is extra pure orch (not counted in the original 9).
 * wave216: shu_waitpid_retry pure thin is extra (not counted in the original 9).
 * wave217: strerror_current + wait_is_signaled + wait_code pure thin are extra.
 * wave219: shux_spawn_sync pure thin is extra (not counted in the original 9). */
#[no_mangle]
export function labi_diag_pure_count(): i32 {
  return 9;
}
