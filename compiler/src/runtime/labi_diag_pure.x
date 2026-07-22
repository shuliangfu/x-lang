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

/* Cap residual (mega always): errno + strerror + va_list reportf path. */
export extern "C" function link_diag_errno(kind: *u8, op: *u8): void;
export extern "C" function link_diag_errno_path(kind: *u8, op: *u8, path: *u8): void;

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
 * Parse a classic `perror`-style link/process message and report via link_diag_errno*.
 * Accepts optional leading `shux: ` prefix. If the remaining text ends with
 * `op (path)` (last `(` / `)` with trailing NUL after `)`), splits into op + path
 * for `link_diag_errno_path`; otherwise reports the whole remaining text as op.
 * Null/empty msg → `system call` with no path.
 * @param msg *u8 — NUL-terminated diagnostic text; null treated as empty
 * @return void
 * Cap residual: `link_diag_errno` / `link_diag_errno_path` hold errno+strerror+reportf
 * (mega always). Pure owns only prefix strip + paren split + stack copies for op/path.
 * wave111: closes soft Cap residual "shux_link_perror body always mega C under hybrid".
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
    unsafe {
      link_diag_errno(pe, sc);
    }
    return;
  }
  if (base[0] == 0) {
    unsafe {
      link_diag_errno(pe, sc);
    }
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
    unsafe {
      link_diag_errno_path(pe, &op_buf[0], &path_buf[0]);
    }
    return;
  }

  /* Whole remaining text as op (pointer into msg after optional prefix). */
  unsafe {
    text = &base[start];
    link_diag_errno(pe, text);
  }
}

/* Pure audit: public L1 gates in this slice (code_for_kind + 8 report).
 * wave111: shux_link_perror is extra pure orch (not counted in the original 9). */
#[no_mangle]
export function labi_diag_pure_count(): i32 {
  return 9;
}
