// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-303/304 / P2 runtime rest: -x -E emit state slots + setters + argv scan.
// w845: driver_run_x_emit_c_set_path, set_lib, set_n_lib_roots, set_emit_extern,
// and driver_argv_parse_x_emit_c live only in this file. Their C twins were
// deleted from seeds/rt_emit_state.from_x.c.
// w859: labi_rt_emit_state_slice_marker lives here too. It returns 1.
// The product installer pure-asm's this file, then cc's the seed for the
// shared buffers, the lib-name pair, and the entry-prefix setter. There is
// no full-seed fallback and XLANG_G05_PREFER_X_O is ignored. Windows takes
// the same path.
// Do not gcc -E this TU. Product PREFER_X_O temps must not replace this .o.
// Cap-global-bss residual: shared buffers/pointer binds use driver_abi slot APIs
// (.x must not write **u8 pointers into BSS, must not use local u8[512] —
// -E would drop functions or corrupt init_globals).
// PLATFORM: SHARED — surface short names are the link-name contract (Track L).

export extern "C" function driver_x_emit_path_buf_slot(): *u8;
export extern "C" function driver_x_emit_lib_buf_slot(i: i32): *u8;
export extern "C" function driver_x_emit_scan_ab_slot(): *u8;
export extern "C" function driver_x_emit_scan_nx_slot(): *u8;
export extern "C" function driver_x_emit_clear_c_path(): void;
export extern "C" function driver_x_emit_bind_c_path_to_buf(): void;
export extern "C" function driver_x_emit_bind_lib_root(i: i32): void;
export extern "C" function driver_x_emit_n_lib_roots_slot(): *i32;
export extern "C" function driver_x_emit_want_extern_slot(): *i32;
export extern "C" function driver_get_argv_i(argc: i32, argv: **u8, i: i32, buf: *u8, max: i32): i32;

// w1493 (终局待办 5.4 rt_emit_state): the shared emit buffers moved here
// from seeds/rt_emit_state.from_x.c, which is deleted. Each module let is
// emitted as an Lxml COMMON. ensure_rt_emit_state_prefer renames every one
// onto the C name that runtime_driver_abi externs (driver_x_emit_*).
// The rename key is fnv32(name bytes, then index), so THE ORDER AND THE
// NAMES OF THESE TEN LETS ARE A LINK CONTRACT. Do not reorder, rename,
// insert, or delete one without updating rt_emit_state_bss_names in
// scripts/ensure_host_cc_seed_o.sh.
// Sizes match the old C block: 16 roots, 512-byte path, 16x256 lib bufs,
// 512-byte argv scratch, 64-byte lib name. Scalars are 8-byte commons.
// Direct stores to a scalar module let fail on Darwin asm (CG002), so the
// functions below write scalars through a pointer taken with &.
// PLATFORM: SHARED — ELF SHN_COMMON, Mach-O __common, COFF common.
let driver_x_emit_c_path: *u8 = 0 as *u8;
let driver_x_emit_lib_roots: i64[16] = [];
let driver_x_emit_n_lib_roots: i32 = 0;
let driver_x_emit_path_buf: u8[512] = [];
let driver_x_emit_lib_bufs: u8[4096] = [];
let driver_x_emit_c_want_extern: i32 = 0;
let driver_x_emit_scan_ab: u8[512] = [];
let driver_x_emit_scan_nx: u8[512] = [];
let driver_x_emit_lib_name_buf: u8[64] = [];
let driver_x_emit_lib_name_len: i32 = 0;

/** Maximum number of -L library roots accepted by emit-state setters/scan.
 * Returns 16. Used as an upper bound for set_lib / set_n_lib_roots / argv scan.
 * Track-L: #[no_mangle] keeps surface short name (not rt_emit_state_rt_emit_max_lib_roots).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_emit_max_lib_roots(): i32 {
  return 16;
}

/** Capacity of the emit path buffer (bytes, including trailing NUL room).
 * Returns 512. Callers must ensure path_len < this value before copy.
 * Track-L: #[no_mangle] keeps surface short name (not module-prefixed mangle).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_emit_path_cap(): i32 {
  return 512;
}

/** Capacity of each -L root buffer (bytes, including trailing NUL room).
 * Returns 256. Callers must ensure len < this value before copy.
 * Track-L: #[no_mangle] keeps surface short name (not module-prefixed mangle).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_emit_lib_cap(): i32 {
  return 256;
}

/** Return 1 iff NUL-terminated argv token `s` is exactly "-L".
 * Byte checks: 45 ('-'), 76 ('L'), 0. Null `s` is not a match.
 * Track-L: #[no_mangle] keeps surface short name (not rt_emit_state_rt_argv_is_minus_L).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_argv_is_minus_L(s: *u8): i32 {
  if (s == 0 as *u8) {
    return 0;
  }
  // Exact match for "-L\0".
  if (s[0] != 45) {
    return 0;
  }
  if (s[1] != 76) {
    return 0;
  }
  if (s[2] != 0) {
    return 0;
  }
  return 1;
}

/** Return 1 iff NUL-terminated argv token `s` is exactly "-x".
 * Byte checks: 45 ('-'), 120 ('x'), 0. Null `s` is not a match.
 * Track-L: #[no_mangle] keeps surface short name (not rt_emit_state_rt_argv_is_minus_x).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_argv_is_minus_x(s: *u8): i32 {
  if (s == 0 as *u8) {
    return 0;
  }
  // Exact match for "-x\0".
  if (s[0] != 45) {
    return 0;
  }
  if (s[1] != 120) {
    return 0;
  }
  if (s[2] != 0) {
    return 0;
  }
  return 1;
}

/** Return 1 iff NUL-terminated argv token `s` is exactly "-E".
 * Byte checks: 45 ('-'), 69 ('E'), 0. Null `s` is not a match.
 * Named `_tok` to avoid colliding with sibling modules' `rt_argv_is_minus_E`.
 * Track-L: #[no_mangle] keeps surface short name (not rt_emit_state_rt_argv_is_minus_E_tok).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_argv_is_minus_E_tok(s: *u8): i32 {
  if (s == 0 as *u8) {
    return 0;
  }
  // Exact match for "-E\0".
  if (s[0] != 45) {
    return 0;
  }
  if (s[1] != 69) {
    return 0;
  }
  if (s[2] != 0) {
    return 0;
  }
  return 1;
}

/** Copy `n` bytes from `src` into `dst` and write a trailing NUL at `dst[n]`.
 * If `dst` is null, returns immediately. If `src` is null, writes only `dst[0]=0`.
 * Caller must ensure `dst` has room for n+1 bytes (path/lib caps enforce this).
 * Track-L: #[no_mangle] keeps surface short name (not rt_emit_state_rt_emit_copy_n).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_emit_copy_n(dst: *u8, src: *u8, n: i32): void {
  let ci: i32 = 0;
  if (dst == 0 as *u8) {
    return;
  }
  if (src == 0 as *u8) {
    dst[0] = 0;
    return;
  }
  // Byte-by-byte copy; terminate with NUL after the last payload byte.
  while (ci < n) {
    dst[ci as usize] = src[ci as usize];
    ci = ci + 1;
  }
  dst[n as usize] = 0;
}

/** Fill the emit path slot from `path[0..path_len)` and bind the C path pointer.
 * Clears the previous path first. Returns 0 always (legacy setter contract).
 * Fails silently (no bind) when path is null, path_len<=0, or path_len >= path_cap.
 * Track-L: #[no_mangle] keeps surface short name for driver entry.
 * PLATFORM: SHARED — uses driver_x_emit_* slot APIs (Cap residual). */
#[no_mangle]
export function driver_run_x_emit_c_set_path(path: *u8, path_len: i32): i32 {
  let set_pbuf: *u8 = 0 as *u8;
  let set_cap: i32 = 0;
  unsafe {
    driver_x_emit_clear_c_path();
  }
  if (path == 0 as *u8) {
    return 0;
  }
  if (path_len <= 0) {
    return 0;
  }
  set_cap = rt_emit_path_cap();
  if (path_len >= set_cap) {
    return 0;
  }
  unsafe {
    set_pbuf = driver_x_emit_path_buf_slot();
  }
  if (set_pbuf == 0 as *u8) {
    return 0;
  }
  rt_emit_copy_n(set_pbuf, path, path_len);
  unsafe {
    driver_x_emit_bind_c_path_to_buf();
  }
  return 0;
}

/** Fill the i-th -L library root buffer and bind that root slot.
 * Returns 0 always. Rejects out-of-range i, null buf, or len >= lib_cap.
 * Track-L: #[no_mangle] keeps surface short name for driver entry.
 * PLATFORM: SHARED — uses driver_x_emit_* slot APIs (Cap residual). */
#[no_mangle]
export function driver_run_x_emit_c_set_lib(i: i32, buf: *u8, len: i32): i32 {
  let set_lbuf: *u8 = 0 as *u8;
  let set_maxr: i32 = 0;
  let set_lcap: i32 = 0;
  set_maxr = rt_emit_max_lib_roots();
  set_lcap = rt_emit_lib_cap();
  if (i < 0) {
    return 0;
  }
  if (i >= set_maxr) {
    return 0;
  }
  if (buf == 0 as *u8) {
    return 0;
  }
  if (len < 0) {
    return 0;
  }
  if (len >= set_lcap) {
    return 0;
  }
  unsafe {
    set_lbuf = driver_x_emit_lib_buf_slot(i);
  }
  if (set_lbuf == 0 as *u8) {
    return 0;
  }
  rt_emit_copy_n(set_lbuf, buf, len);
  unsafe {
    driver_x_emit_bind_lib_root(i);
  }
  return 0;
}

/** Set the number of active -L roots (clamped to [0, max_lib_roots]).
 * Writes into the n_lib_roots slot. Negative `n` becomes 0; oversized becomes max.
 * Returns 0 always. Track-L: #[no_mangle] for surface short name.
 * PLATFORM: SHARED — Cap residual slot API. */
#[no_mangle]
export function driver_run_x_emit_c_set_n_lib_roots(n: i32): i32 {
  let n_slot: *i32 = 0 as *i32;
  let n_maxr: i32 = 0;
  let n_v: i32 = 0;
  n_maxr = rt_emit_max_lib_roots();
  // Clamp n into [0, n_maxr]; leave n_v=0 if n is negative.
  if (n >= 0) {
    if (n <= n_maxr) {
      n_v = n;
    }
  }
  unsafe {
    n_slot = driver_x_emit_n_lib_roots_slot();
  }
  if (n_slot != 0 as *i32) {
    n_slot[0] = n_v;
  }
  return 0;
}

/** Set want_extern from -E-extern style flags (non-zero → 1).
 * Writes the want_extern slot. Returns 0 always.
 * Track-L: #[no_mangle] keeps surface short name for driver entry.
 * PLATFORM: SHARED — Cap residual slot API. */
#[no_mangle]
export function driver_run_x_emit_c_set_emit_extern(v: i32): i32 {
  let w_slot: *i32 = 0 as *i32;
  let w_out: i32 = 0;
  if (v != 0) {
    w_out = 1;
  }
  unsafe {
    w_slot = driver_x_emit_want_extern_slot();
  }
  if (w_slot != 0 as *i32) {
    w_slot[0] = w_out;
  }
  return 0;
}

/** Scan argv[i..] for -L <root> and -x -E <path> (tail-recursive).
 * On -L: copy next token into the next free lib root slot (if capacity remains).
 * On -x followed by -E: write path into the path slot, bind, return 1 (success).
 * Other tokens: recurse to i+1. Returns 0 when exhausted without -x -E path.
 * Uses scan_ab/scan_nx slot buffers so locals stay pointer-sized (no u8[N] BSS lift).
 * Track-L: #[no_mangle] keeps surface short name (not rt_emit_state_rt_scan_x_emit_argv).
 * PLATFORM: SHARED — Cap residual slot APIs + get_argv_i. */
#[no_mangle]
export function rt_scan_x_emit_argv(argc: i32, argv: **u8, i: i32): i32 {
  let sc_ab: *u8 = 0 as *u8;
  let sc_nx: *u8 = 0 as *u8;
  let sc_ln: i32 = 0;
  let sc_k: i32 = 0;
  let sc_nslot: *i32 = 0 as *i32;
  let sc_pbuf: *u8 = 0 as *u8;
  let sc_lbuf: *u8 = 0 as *u8;
  let sc_maxr: i32 = 0;
  if (i >= argc) {
    return 0;
  }
  unsafe {
    sc_ab = driver_x_emit_scan_ab_slot();
  }
  if (sc_ab == 0 as *u8) {
    return 0;
  }
  unsafe {
    sc_ln = driver_get_argv_i(argc, argv, i, sc_ab, 512);
  }
  if (sc_ln < 0) {
    return rt_scan_x_emit_argv(argc, argv, i + 1);
  }
  // Branch: -L <root> — consume two tokens and continue scan.
  if (rt_argv_is_minus_L(sc_ab) != 0) {
    if (i + 1 >= argc) {
      return rt_scan_x_emit_argv(argc, argv, i + 1);
    }
    unsafe {
      sc_nslot = driver_x_emit_n_lib_roots_slot();
    }
    sc_k = 0;
    if (sc_nslot != 0 as *i32) {
      sc_k = sc_nslot[0];
    }
    sc_maxr = rt_emit_max_lib_roots();
    if (sc_k < sc_maxr) {
      unsafe {
        sc_lbuf = driver_x_emit_lib_buf_slot(sc_k);
      }
      if (sc_lbuf != 0 as *u8) {
        unsafe {
          sc_ln = driver_get_argv_i(argc, argv, i + 1, sc_lbuf, 256);
        }
        if (sc_ln < 0) {
          return 0;
        }
        unsafe {
          driver_x_emit_bind_lib_root(sc_k);
        }
        if (sc_nslot != 0 as *i32) {
          sc_nslot[0] = sc_k + 1;
        }
      }
    }
    return rt_scan_x_emit_argv(argc, argv, i + 2);
  }
  // Branch: -x -E <path> — require two following tokens; bind path and stop.
  if (rt_argv_is_minus_x(sc_ab) != 0) {
    if (i + 2 >= argc) {
      return rt_scan_x_emit_argv(argc, argv, i + 1);
    }
    unsafe {
      sc_nx = driver_x_emit_scan_nx_slot();
    }
    if (sc_nx == 0 as *u8) {
      return 0;
    }
    unsafe {
      sc_ln = driver_get_argv_i(argc, argv, i + 1, sc_nx, 512);
    }
    if (sc_ln < 0) {
      return rt_scan_x_emit_argv(argc, argv, i + 1);
    }
    if (rt_argv_is_minus_E_tok(sc_nx) == 0) {
      return rt_scan_x_emit_argv(argc, argv, i + 1);
    }
    unsafe {
      sc_pbuf = driver_x_emit_path_buf_slot();
    }
    if (sc_pbuf == 0 as *u8) {
      return 0;
    }
    unsafe {
      sc_ln = driver_get_argv_i(argc, argv, i + 2, sc_pbuf, 512);
    }
    if (sc_ln < 0) {
      return 0;
    }
    unsafe {
      driver_x_emit_bind_c_path_to_buf();
    }
    return 1;
  }
  return rt_scan_x_emit_argv(argc, argv, i + 1);
}

/** Parse argv for -x -E <path> (and preceding -L roots).
 * Clears path and n_lib_roots first, then scans from argv index 1.
 * Returns 1 if a path was bound, 0 if argc < 4 or no match.
 * Do not write `argv == 0 as **u8` in .x — -E may drop the whole function symbol.
 * Track-L: #[no_mangle] keeps surface short name for driver entry.
 * PLATFORM: SHARED — Cap residual slot APIs. */
#[no_mangle]
export function driver_argv_parse_x_emit_c(argc: i32, argv: **u8): i32 {
  let pr_nslot: *i32 = 0 as *i32;
  unsafe {
    driver_x_emit_clear_c_path();
    pr_nslot = driver_x_emit_n_lib_roots_slot();
  }
  if (pr_nslot != 0 as *i32) {
    pr_nslot[0] = 0;
  }
  if (argc < 4) {
    return 0;
  }
  return rt_scan_x_emit_argv(argc, argv, 1);
}

/**
 * Byte offsets inside struct ast_PipelineDepCtx (runtime_pipeline_abi.h).
 * current_codegen_prefix_mirror[256] at 8389740, its len at 8389996,
 * entry_module_import_path_mirror[256] at 8390004, its len at 8390260.
 * Same values as pipe_pctx_off_* in runtime_pipeline_abi.x. Checked with
 * offsetof on Darwin, Ubuntu, and Windows in w1493.
 * PLATFORM: SHARED — the struct has no long fields.
 */
function rt_emit_pctx_off_prefix_mirror(): i32 {
  return 8389740;
}

function rt_emit_pctx_off_prefix_len(): i32 {
  return 8389996;
}

function rt_emit_pctx_off_import_mirror(): i32 {
  return 8390004;
}

function rt_emit_pctx_off_import_len(): i32 {
  return 8390260;
}

/**
 * Seed the codegen ctx entry prefix with `name` plus a trailing '_'.
 * Writes both current_codegen_prefix_mirror and
 * entry_module_import_path_mirror, NUL-terminates both, and sets both
 * lengths to name_len + 1. A null ctx, a null name, name_len <= 0, or
 * name_len >= 63 is a no-op.
 * w1493: moved from seeds/rt_emit_state.from_x.c (deleted).
 * @param ctx *u8 — struct ast_PipelineDepCtx *
 * @param name *u8 — name bytes (not NUL-terminated)
 * @param name_len i32 — byte count
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_pipeline_pctx_set_entry_lib_prefix(ctx: *u8, name: *u8, name_len: i32): void {
  let pfx: *u8 = 0 as *u8;
  let imp: *u8 = 0 as *u8;
  let plen: *i32 = 0 as *i32;
  let ilen: *i32 = 0 as *i32;
  let k: i32 = 0;
  if (ctx == 0 as *u8) {
    return;
  }
  if (name == 0 as *u8) {
    return;
  }
  if (name_len <= 0) {
    return;
  }
  if (name_len >= 63) {
    return;
  }
  pfx = ctx + (rt_emit_pctx_off_prefix_mirror() as usize);
  imp = ctx + (rt_emit_pctx_off_import_mirror() as usize);
  plen = (ctx + (rt_emit_pctx_off_prefix_len() as usize)) as *i32;
  ilen = (ctx + (rt_emit_pctx_off_import_len() as usize)) as *i32;
  while (k < name_len) {
    pfx[k as usize] = name[k as usize];
    imp[k as usize] = name[k as usize];
    k = k + 1;
  }
  pfx[name_len as usize] = 95;
  pfx[(name_len + 1) as usize] = 0;
  imp[name_len as usize] = 95;
  imp[(name_len + 1) as usize] = 0;
  plen[0] = name_len + 1;
  ilen[0] = name_len + 1;
}

/**
 * Copy entry_module_import_path_mirror into out and write a trailing NUL.
 * The stored bytes already include the trailing '_'. Returns 0 when ctx
 * or out is null, cap is too small, or the stored length is outside 1..127.
 * Does not allocate. The asm -c entry path reads this after
 * xlang_pipeline_pctx_set_entry_lib_prefix; host-cc reads the same mirror.
 * @param ctx *u8 — struct ast_PipelineDepCtx *; null returns 0
 * @param out *u8 — destination buffer; caller owns; not retained
 * @param cap i32 — destination capacity in bytes; must exceed the stored length
 * @return i32 — bytes copied, not counting the NUL; 0 when unset
 * PLATFORM: SHARED — same w1493 offsets as the setter.
 * Track-L: #[no_mangle] keeps the source name as the link symbol.
 */
#[no_mangle]
export function xlang_pipeline_pctx_entry_lib_prefix_into(ctx: *u8, out: *u8, cap: i32): i32 {
  let imp: *u8 = 0 as *u8;
  let ilen: *i32 = 0 as *i32;
  let n: i32 = 0;
  let k: i32 = 0;
  if (ctx == 0 as *u8) {
    return 0;
  }
  if (out == 0 as *u8) {
    return 0;
  }
  if (cap <= 1) {
    return 0;
  }
  // Reject a wild length before any copy. The setter never stores more
  // than 63 name bytes plus the trailing '_'.
  ilen = (ctx + (rt_emit_pctx_off_import_len() as usize)) as *i32;
  n = ilen[0];
  if (n <= 0) {
    return 0;
  }
  if (n >= 128) {
    return 0;
  }
  if (n >= cap) {
    return 0;
  }
  imp = ctx + (rt_emit_pctx_off_import_mirror() as usize);
  while (k < n) {
    out[k as usize] = imp[k as usize];
    k = k + 1;
  }
  out[n as usize] = 0;
  return n;
}

/**
 * Store the -lib-name value for the X-pipeline -E/-o emit lane.
 * parse_x (main.x) and rt_run_asm_backend.x call this. Clears the stored
 * name first. len == 0 with a buf stores an explicit empty name (w2060).
 * A null buf, len < 0, or len >= 64 leaves it unset.
 * w1493: moved from seeds/rt_emit_state.from_x.c (deleted).
 * @param buf *u8 — name bytes (not NUL-terminated)
 * @param len i32 — byte count
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_driver_x_emit_set_lib_name(buf: *u8, len: i32): void {
  let dst: *u8 = &driver_x_emit_lib_name_buf[0];
  let nslot: *i32 = &driver_x_emit_lib_name_len;
  let k: i32 = 0;
  nslot[0] = 0;
  dst[0] = 0;
  if (buf == 0 as *u8) {
    return;
  }
  if (len == 0) {
    // w2060: explicit empty -lib-name → bare exports (marker -1).
    nslot[0] = 0 - 1;
    return;
  }
  if (len < 0) {
    return;
  }
  if (len >= 64) {
    return;
  }
  while (k < len) {
    dst[k as usize] = buf[k as usize];
    k = k + 1;
  }
  dst[len as usize] = 0;
  nslot[0] = len;
}

/**
 * Copy the stored -lib-name into `out` (at most cap - 1 bytes plus NUL).
 * driver_run_x_emit_c (rt_run_x_emit.x) reads it to seed the ctx prefix.
 * Returns the byte count copied. Returns 0 for a null out or cap <= 0,
 * and writes an empty string when no name is stored. Returns -1 (empty
 * string) for an explicit empty -lib-name (w2060).
 * w1493: moved from seeds/rt_emit_state.from_x.c (deleted).
 * @param out *u8 — destination buffer
 * @param cap i32 — destination capacity in bytes
 * @return i32 — bytes copied, not counting the NUL
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_driver_x_emit_lib_name_into(out: *u8, cap: i32): i32 {
  let src: *u8 = &driver_x_emit_lib_name_buf[0];
  let nslot: *i32 = &driver_x_emit_lib_name_len;
  let n: i32 = 0;
  let k: i32 = 0;
  if (out == 0 as *u8) {
    return 0;
  }
  if (cap <= 0) {
    return 0;
  }
  n = nslot[0];
  if (n < 0) {
    // w2060: explicit empty -lib-name. Callers that test > 0 skip it.
    out[0] = 0;
    return 0 - 1;
  }
  if (n == 0) {
    out[0] = 0;
    return 0;
  }
  if (n > cap - 1) {
    n = cap - 1;
  }
  while (k < n) {
    out[k as usize] = src[k as usize];
    k = k + 1;
  }
  out[n as usize] = 0;
  return n;
}

/**
 * Slice presence marker for this translation unit.
 * Returns 1, the same value the former host-cc marker returned.
 * No product caller reads it. The ensure nm gate only checks the symbol exists.
 * @return i32 — always 1
 * PLATFORM: SHARED — pure asm. Lib-name, entry prefix, and the shared buffers stay in the C seed.
 */
#[no_mangle]
export function labi_rt_emit_state_slice_marker(): i32 {
  return 1;
}
