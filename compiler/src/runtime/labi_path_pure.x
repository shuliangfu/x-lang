// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-267/429 / P2 link_abi L0: pure path strings (no stat) → R2 full.
// Product: PREFER_X_O → g05_try_x_to_o; cold-start seeds/labi_path_pure.from_x.c.
// Hybrid macro SHUX_LABI_PATH_PURE_FROM_X (FROM_X rest business H=0, marker only).
//
// R2 full: .x owns 11 public gates + count:
//   - labi_suffix_eq2 / labi_suffix_eq4
//   - link_abi_ld_argv_entry_is_obj / shux_output_is_elf_o / shux_output_want_exe
//   - shux_path_has_sep / shux_path_last_sep (POSIX '/' only)
//   - shux_asm_ld_lib_root_ptr_usable (wave114; low-tag + empty reject)
//   - shux_asm_ld_lib_root_default (wave115; SHUX_LIB or "."; Cap residual: getenv)
//   - shux_asm_ld_try_under_lib_roots (wave116; pure join root/rel; Cap residual skip+bank)
//   - link_abi_asm_ld_argv_has_obj (wave146; pure strcmp argv scan; Cap residual realpath)
// Cap residual (mega rest cold path Windows #if '\\'): product PREFER uses .x pure POSIX.
// G-02f-L: lengths use i32 (aligned with rt_content.x) to avoid usize literal/sub typeck blocks on -E.

export extern "C" function getenv(name: *u8): *u8;
// Cap residual path-IO / bank (hybrid authority: labi_path_io / labi_gates / mega cold).
export extern "C" function asm_link_obj_skip_missing(path: *u8): *u8;
export extern "C" function shux_asm_ld_bank_push(b: *u8, path: *u8): *u8;
// Cap residual: POSIX realpath into caller buffer; Windows / fail → null (≡ mega #if).
export extern "C" function link_abi_realpath_cap(path: *u8, out: *u8): *u8;

/**
 * Return 1 iff s ends with the two-byte suffix (a0,a1).
 * Params: s — bytes; n — length (i32); a0/a1 — suffix bytes.
 * Returns: 1 on match, 0 if n < 2 or mismatch.
 * Contracts: flat early-return (same pattern as rt_content.x rt_eq2); caller guarantees n is valid for s.
 * Track-L: #[no_mangle] keeps surface short name. PLATFORM: SHARED.
 */
#[no_mangle]
export function labi_suffix_eq2(s: *u8, n: i32, a0: u8, a1: u8): i32 {
  if (n < 2) { return 0; }
  if (s[n - 2] != a0) { return 0; }
  if (s[n - 1] != a1) { return 0; }
  return 1;
}

/**
 * Return 1 iff s ends with the four-byte suffix (a0,a1,a2,a3).
 * Params: s — bytes; n — length (i32); a0..a3 — suffix bytes.
 * Returns: 1 on match, 0 if n < 4 or mismatch.
 * Contracts: flat early-return (same pattern as rt_content.x rt_eq4).
 * Track-L: #[no_mangle] keeps surface short name. PLATFORM: SHARED.
 */
#[no_mangle]
export function labi_suffix_eq4(s: *u8, n: i32, a0: u8, a1: u8, a2: u8, a3: u8): i32 {
  if (n < 4) { return 0; }
  if (s[n - 4] != a0) { return 0; }
  if (s[n - 3] != a1) { return 0; }
  if (s[n - 2] != a2) { return 0; }
  if (s[n - 1] != a3) { return 0; }
  return 1;
}

/**
 * Return 1 iff linker argv entry s looks like an object file (.o or .obj).
 * Params: s — NUL-terminated path; null/empty → 0.
 * Returns: 1 for .o / .obj suffixes, else 0.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function link_abi_ld_argv_entry_is_obj(s: *u8): i32 {
  let n: i32 = 0;
  if (s == 0 as *u8) { return 0; }
  if (s[0] == 0) { return 0; }
  while (s[n] != 0) { n = n + 1; }
  if (labi_suffix_eq2(s, n, 46, 111) != 0) { return 1; }
  if (labi_suffix_eq4(s, n, 46, 111, 98, 106) != 0) { return 1; }
  return 0;
}

/**
 * Return 1 iff path looks like an ELF object output (.o / .O / .obj).
 * Params: path — NUL-terminated; null → 0.
 * Returns: 1 on object suffix match, else 0.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function shux_output_is_elf_o(path: *u8): i32 {
  let n: i32 = 0;
  if (path == 0 as *u8) { return 0; }
  while (path[n] != 0) { n = n + 1; }
  if (labi_suffix_eq2(path, n, 46, 111) != 0) { return 1; }
  if (labi_suffix_eq2(path, n, 46, 79) != 0) { return 1; }
  if (labi_suffix_eq4(path, n, 46, 111, 98, 106) != 0) { return 1; }
  return 0;
}

/**
 * Return 1 if path should be treated as an executable output (not .o/.O/.s/.obj).
 * Params: path — NUL-terminated; null or empty → 0.
 * Returns: 0 for object/asm suffixes; 1 otherwise (want exe).
 * Why: C original used nested strlen/if; .x flattens via labi_suffix_eq2/eq4
 * (complements shux_output_is_elf_o; also rejects .s).
 * Invariants: path null/empty → 0; suffixes .o/.O/.s/.obj → 0; else → 1.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function shux_output_want_exe(path: *u8): i32 {
  let n: i32 = 0;
  if (path == 0 as *u8) { return 0; }
  if (path[0] == 0) { return 0; }
  while (path[n] != 0) { n = n + 1; }
  if (labi_suffix_eq2(path, n, 46, 111) != 0) { return 0; }
  if (labi_suffix_eq2(path, n, 46, 79) != 0) { return 0; }
  if (labi_suffix_eq2(path, n, 46, 115) != 0) { return 0; }
  if (labi_suffix_eq4(path, n, 46, 111, 98, 106) != 0) { return 0; }
  return 1;
}

/**
 * Return 1 iff s contains a path separator (POSIX '/' only).
 * Params: s — NUL-terminated; null → 0.
 * Returns: 1 if '/' (47) appears, else 0.
 * Why: C used strchr + Windows #if '\\'; product PREFER path is pure POSIX '/' scan.
 * Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: POSIX product path (Windows residual in mega rest cold path).
 */
#[no_mangle]
export function shux_path_has_sep(s: *u8): i32 {
  if (s == 0 as *u8) {
    return 0;
  }
  let i: i32 = 0;
  while (s[i] != 0) {
    if (s[i] == 47) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Return pointer to the last '/' in s, or null if none.
 * Params: s — NUL-terminated; null → null.
 * Returns: *u8 into s at last '/', or null.
 * Why: C used strrchr; .x records last '/' offset in a forward pass, then
 * reconstructs pointer via s as usize + off.
 * Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: POSIX product path.
 */
#[no_mangle]
export function shux_path_last_sep(s: *u8): *u8 {
  if (s == 0 as *u8) {
    return 0 as *u8;
  }
  let last: i32 = 0;
  let found: i32 = 0;
  let i: i32 = 0;
  while (s[i] != 0) {
    if (s[i] == 47) {
      last = i;
      found = 1;
    }
    i = i + 1;
  }
  if (found == 0) {
    return 0 as *u8;
  }
  let base: usize = s as usize;
  return (base + (last as usize)) as *u8;
}

/**
 * Return 1 iff `p` is a safe non-empty C string pointer for lib-root use.
 * Rejects null, low-tag / non-canonical pointers ((usize)p < 4096; same guard as
 * mega rest: getenv/environ garbage on nostdlib), and empty strings.
 * Params: p — candidate lib-root C string.
 * Returns: 1 usable, 0 reject.
 * Why (wave114): product hybrid still had always-linked mega C; G.7 single
 * authority under SHUX_LABI_PATH_PURE_FROM_X. Not the same as driver_lib_root
 * (rt_lib_root; no low-tag) — keep link_abi symbol separate.
 * Track-L: #[no_mangle] keeps surface short name. PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_asm_ld_lib_root_ptr_usable(p: *u8): i32 {
  if (p == 0 as *u8) {
    return 0;
  }
  // PLATFORM: SHARED — reject low-tag pointers (mega: (uintptr_t)p >= 4096u).
  if ((p as usize) < (4096 as usize)) {
    return 0;
  }
  if (p[0] == 0) {
    return 0;
  }
  return 1;
}

/**
 * Write default lib-root into root_buf (at least 512 bytes): env SHUX_LIB if usable,
 * else ".".
 * @param root_buf *u8 — caller buffer; capacity >= 512; always left NUL-terminated
 * @return void
 * Why (wave115): product hybrid still had always-linked mega C (getenv+strncpy).
 * Pure orch: default "." then pure usable-check on getenv("SHUX_LIB") then byte copy
 * (no strncpy Cap). Cap residual: getenv extern only (same as rt_lib_root.x).
 * Differs from driver_lib_root_default by using low-tag usable (wave114).
 * Track-L: #[no_mangle] keeps surface short name. PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_asm_ld_lib_root_default(root_buf: *u8): void {
  // Default to "." before env probe (mega: root_buf[0]='.'; root_buf[1]=0).
  root_buf[0] = 46;
  root_buf[1] = 0;
  let def: *u8 = 0 as *u8;
  unsafe {
    def = getenv("SHUX_LIB");
  }
  if (shux_asm_ld_lib_root_ptr_usable(def) == 0) {
    return;
  }
  // Copy at most 511 bytes + force trailing NUL at index 511 (mega strncpy).
  let i: i32 = 0;
  while (i < 511) {
    let c: u8 = def[i];
    root_buf[i] = c;
    if (c == 0) {
      return;
    }
    i = i + 1;
  }
  root_buf[511] = 0;
}

/**
 * Under each -L lib root, pure-join `root/rel` (POSIX `/`), and if the object
 * exists (skip_missing Cap residual), bank_push and return the durable path.
 * @param rel *u8 — relative object path (e.g. std/process/process.o); null/low-tag/empty → null
 * @param lib_roots **u8 — -L root C-string table; null/low-tag → null
 * @param n_lib_roots i32 — table length; <=0 → null; scan capped at 24 (≡ mega)
 * @param bank *u8 — opaque ShuAsmLdPathBank*; null/low-tag → null
 * @return *u8 — bank slot pointer on hit, else null
 * Pure orch: low-tag usable on rel/root; strip trailing `/`; byte join into 4096
 * stack (no snprintf Cap). Cap residual: asm_link_obj_skip_missing (stat) +
 * shux_asm_ld_bank_push (path bank copy). Why (wave116): product hybrid still
 * had always-linked mega C (snprintf join + skip + bank). PLATFORM: SHARED.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function shux_asm_ld_try_under_lib_roots(rel: *u8, lib_roots: **u8, n_lib_roots: i32, bank: *u8): *u8 {
  // Match mega: reject null / low-tag rel and empty rel.
  if (shux_asm_ld_lib_root_ptr_usable(rel) == 0) {
    return 0 as *u8;
  }
  if (bank == 0 as *u8) {
    return 0 as *u8;
  }
  if ((bank as usize) < (4096 as usize)) {
    return 0 as *u8;
  }
  // lib_roots table base: treat as *u8 for low-tag check (mega: (uintptr_t)lib_roots).
  let roots_base: *u8 = lib_roots as *u8;
  if (roots_base == 0 as *u8) {
    return 0 as *u8;
  }
  if ((roots_base as usize) < (4096 as usize)) {
    return 0 as *u8;
  }
  if (n_lib_roots <= 0) {
    return 0 as *u8;
  }
  // Pure strlen(rel) once (mega recomputes inside loop via strlen).
  let rel_n: i32 = 0;
  while (rel[rel_n] != 0) {
    rel_n = rel_n + 1;
  }
  let i: i32 = 0;
  while (i < n_lib_roots) {
    // Cap scan at 24 roots (mega: i < n_lib_roots && i < 24).
    if (i >= 24) {
      break;
    }
    let root: *u8 = lib_roots[i];
    // nostdlib: roots may be low-tag garbage; reuse pure usable guard.
    if (shux_asm_ld_lib_root_ptr_usable(root) == 0) {
      i = i + 1;
      continue;
    }
    // rn = strlen(root); strip trailing '/' while rn > 1.
    let rn: i32 = 0;
    while (root[rn] != 0) {
      rn = rn + 1;
    }
    while (rn > 1) {
      if (root[rn - 1] != 47) {
        break;
      }
      rn = rn - 1;
    }
    // Overflow guard ≡ mega: rn + 2 + strlen(rel) >= sizeof(tmp) → skip.
    // Stack cap 4096 (conservative PATH_MAX upper; PLATFORM: SHARED).
    if (rn + 2 + rel_n >= 4096) {
      i = i + 1;
      continue;
    }
    let tmp: u8[4096] = [];
    // rn > 0: root[0..rn) + '/' + rel + NUL; else copy rel only (mega snprintf %s).
    if (rn > 0) {
      let j: i32 = 0;
      while (j < rn) {
        tmp[j] = root[j];
        j = j + 1;
      }
      tmp[rn] = 47;
      let k: i32 = 0;
      while (k <= rel_n) {
        tmp[rn + 1 + k] = rel[k];
        k = k + 1;
      }
    } else {
      let k2: i32 = 0;
      while (k2 <= rel_n) {
        tmp[k2] = rel[k2];
        k2 = k2 + 1;
      }
    }
    // Cap residual: skip missing (stat) then bank_push durable copy.
    let hit: *u8 = 0 as *u8;
    unsafe {
      hit = asm_link_obj_skip_missing(&tmp[0]);
    }
    if (hit == 0 as *u8) {
      i = i + 1;
      continue;
    }
    let pushed: *u8 = 0 as *u8;
    unsafe {
      pushed = shux_asm_ld_bank_push(bank, &tmp[0]);
    }
    return pushed;
  }
  return 0 as *u8;
}

/**
 * Return 1 iff path is already present in ld argv (string or realpath-equal).
 * Dedup helper for on-demand .o push: avoid linking the same object twice when
 * paths differ only by relative vs absolute spelling.
 * @param argv **u8 — ld argv table (char**); null → 0
 * @param la i32 — argv length; la <= 0 → 0
 * @param path *u8 — candidate path; null/empty → 0
 * @return i32 — 1 if found, else 0
 * Pure orch: null guards + pure byte cstr eq + argv scan. Cap residual:
 * link_abi_realpath_cap (POSIX realpath; Windows always null → string-only path).
 * Buffers: two 4096-byte stack arrays (conservative PATH_MAX upper; same as
 * try_under_lib_roots). Mega used static PATH_MAX to avoid deep-stack realpath
 * recursion; product push is non-recursive so stack is fine.
 * Why (wave146): hybrid still had always-mega C body over pure path leaf gates.
 * Note: null-check argv via cast to *u8 (do not write `argv == 0 as **u8`).
 * PLATFORM: SHARED — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function link_abi_asm_ld_argv_has_obj(argv: **u8, la: i32, path: *u8): i32 {
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return 0;
  }
  if (la <= 0) {
    return 0;
  }
  if (path == 0 as *u8) {
    return 0;
  }
  if (path[0] == 0) {
    return 0;
  }
  // Resolve path once (Cap residual realpath); on fail keep original path.
  let abs_new: u8[4096] = [];
  let use_new: *u8 = path;
  let rn: *u8 = 0 as *u8;
  unsafe {
    rn = link_abi_realpath_cap(path, &abs_new[0]);
  }
  if (rn != 0 as *u8) {
    use_new = rn;
  }
  let k: i32 = 0;
  while (k < la) {
    let exist: *u8 = argv[k];
    if (exist == 0 as *u8) {
      k = k + 1;
      continue;
    }
    if (exist[0] == 0) {
      k = k + 1;
      continue;
    }
    // Exact string match against original path (inline pure cstr eq ≡ strcmp).
    let eq_path: i32 = 1;
    let i0: i32 = 0;
    while (i0 < 1048576) {
      let ca: u8 = exist[i0];
      let cb: u8 = path[i0];
      if (ca != cb) {
        eq_path = 0;
        break;
      }
      if (ca == 0) {
        break;
      }
      i0 = i0 + 1;
    }
    if (eq_path != 0) {
      return 1;
    }
    // Exact match against resolved path (may be same pointer as path).
    let eq_new: i32 = 1;
    let i1: i32 = 0;
    while (i1 < 1048576) {
      let ca2: u8 = exist[i1];
      let cb2: u8 = use_new[i1];
      if (ca2 != cb2) {
        eq_new = 0;
        break;
      }
      if (ca2 == 0) {
        break;
      }
      i1 = i1 + 1;
    }
    if (eq_new != 0) {
      return 1;
    }
    // Resolve exist and compare to use_new (Cap residual realpath).
    let abs_exist: u8[4096] = [];
    let re: *u8 = 0 as *u8;
    unsafe {
      re = link_abi_realpath_cap(exist, &abs_exist[0]);
    }
    if (re != 0 as *u8) {
      let eq_re: i32 = 1;
      let i2: i32 = 0;
      while (i2 < 1048576) {
        let ca3: u8 = re[i2];
        let cb3: u8 = use_new[i2];
        if (ca3 != cb3) {
          eq_re = 0;
          break;
        }
        if (ca3 == 0) {
          break;
        }
        i2 = i2 + 1;
      }
      if (eq_re != 0) {
        return 1;
      }
    }
    k = k + 1;
  }
  return 0;
}

/**
 * Pure audit: number of L0 path-pure public gates in this slice.
 * Returns: 11 (fixed catalog size for hybrid FROM_X bookkeeping; wave146 +1).
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function labi_path_pure_count(): i32 {
  return 11;
}
