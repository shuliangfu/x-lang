// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-267/429 / P2 link_abi L0: pure path strings (no stat) → R2 full.
// Product: PREFER_X_O → g05_try_x_to_o; cold-start seeds/labi_path_pure.from_x.c.
// Hybrid macro XLANG_LABI_PATH_PURE_FROM_X (FROM_X rest business H=0, marker only).
//
// R2 full: .x owns 60 public gates + count:
//   - labi_suffix_eq2 / labi_suffix_eq4
//   - link_abi_ld_argv_entry_is_obj / xlang_output_is_elf_o / xlang_output_want_exe
//   - xlang_path_has_sep / xlang_path_last_sep (POSIX '/' only)
//   - xlang_asm_ld_lib_root_ptr_usable (wave114; low-tag + empty reject)
//   - xlang_asm_ld_lib_root_default (wave115; XLANG_LIB or "."; Cap residual: link_abi_getenv wave223)
//   - xlang_asm_ld_try_under_lib_roots (wave116; pure join root/rel; Cap residual skip+bank)
//   - link_abi_asm_ld_argv_has_obj (wave146; pure strcmp argv scan; Cap residual realpath)
//   - link_abi_asm_ld_argv_push_stable (wave147; pure bank+dedup+append; Cap residual bank_push)
//   - link_abi_asm_ld_push_obj (wave148; pure resolve+bank+dedup orch; Cap residual skip/rel/bank/diag)
//   - link_abi_asm_ld_push_glue_after_std (wave149; pure have_std+ensure orch; Cap residual call_ensure)
//   - link_abi_asm_ld_push_minimal_runtime_objs (wave150; pure triple push_obj; Cap residual *_o_path
//     only for empty primary path strings from thin leaves before wave183 pure)
//   - xlang_asm_ld_append_user_extra_o_files (wave151; pure CLI extra .o append; Cap residual table+access)
//   - xlang_invoke_cc_set_user_o_files_from_argv / clear (wave189; pure CLI argv .o scan;
//     Cap residual reset/push table write)
//   - xlang_runtime_compiler_o_path_copy (wave160; pure join compiler-dir/leaf; Cap residual resolve)
//   - xlang_repo_root_from_argv0 (wave162; pure strip parent of compiler-dir / process.o walk;
//     Cap residual resolve + rel_o_path; static 512 BSS return)
//   - xlang_runtime_panic_o_path (wave163; pure cwd/argv0 path ladder for runtime_panic.o;
//     Cap residual realpath_if_exists + getcwd + skip_missing; static 512/4096 BSS)
//   - xlang_crt0_user_o_path (wave164; pure cwd/argv0 path ladder for crt0_user.o;
//     Cap residual realpath_cap + getcwd; static 512/4096 BSS; freestanding entry)
//   - xlang_freestanding_io_o_path (wave165; pure cwd/argv0 path ladder for freestanding_io.o;
//     Cap residual realpath_cap + getcwd; static 512/4096 BSS; freestanding syscall write)
//   - xlang_std_async_scheduler_o_path (wave166; pure cwd/argv0 path ladder for std/async/scheduler.o;
//     Cap residual realpath_cap + getcwd; static 4096/4096 BSS; argv0 realpath then parent+/../std/async)
//   - scheduler_o_for_task_link (wave180; pure task.o→scheduler.o path rewrite + Cap residual
//     path_readable + realpath_cap; static 4096/4096 BSS; explicit_scheduler short-circuit)
//   - xlang_bootstrap_nostdlib_stubs_o_path (wave181; pure cwd realpath + compiler-dir/leaf join;
//     Cap residual realpath_cap + shu_resolve_compiler_dir; static 4096/4096 BSS; LINUX freestanding)
//   - 29× thin xlang_runtime_*_o_path (wave183; pure BSS + compiler_o_path_copy peer;
//     asm_io_stubs / process_argv / process_os_glue … ed25519_ref10_glue; static 4096 BSS each)
//   - xlang_empty_cstr / xlang_std_io_o_path / xlang_std_compress_o_path /
//     xlang_asm_ld_effective_link_argv0 (wave184; empty durable "" + effective link argv0 orch;
//     Cap residual resolve for synthetic compiler-dir/xlang only)
//   - xlang_rel_o_path_from_argv0 (wave185; pure realpath/cwd/argv0 ladder; Cap residual
//     realpath_cap + getcwd + link_abi_cstr_dup + skip_missing; heap return — never BSS)
// wave161 G.7: thin join authority = compiler_o_path_copy; wave183 closes always-mega BSS bodies.
// wave184: empty path stubs + effective_link soft residual always-mega closed.
// wave185: rel_o_path soft residual always-mega closed (heap cstr_dup Cap residual stays).
// Cap residual (mega rest cold path Windows #if '\\'): product PREFER uses .x pure POSIX.
// G-02f-L: lengths use i32 (aligned with rt_content.x) to avoid usize literal/sub typeck blocks on -E.

// wave223 G.7: env lookup authority = public pure thin link_abi_getenv (labi_diag_pure L1
// hybrid → link_abi_getenv_impl host getenv). Do not call raw libc getenv from this module.
export extern "C" function link_abi_getenv(name: *u8): *u8;
// Cap residual path-IO / bank (hybrid authority: labi_path_io / labi_gates / mega cold).
export extern "C" function asm_link_obj_skip_missing(path: *u8): *u8;
export extern "C" function xlang_asm_ld_bank_push(b: *u8, path: *u8): *u8;
// Cap residual: POSIX realpath into caller buffer; Windows / fail → null (≡ mega #if).
export extern "C" function link_abi_realpath_cap(path: *u8, out: *u8): *u8;
// Cap residual (wave185): heap string copy for multi-call-independent path returns (never BSS).
// G.7 authority = link_abi_cstr_dup (mega always; wraps host/freestanding strdup).
// Do NOT extern libc strdup in .x — uint8_t* vs char* clashes with string.h under g05 -E.
export extern "C" function link_abi_cstr_dup(s: *u8): *u8;
// wave185: xlang_rel_o_path_from_argv0 is pure export below (no longer Cap residual always-mega).
// Cap residual / peer pure: XLANG_DEBUG_LD note path (labi_diag_pure authority).
export extern "C" function link_diag_ld_debug_push(rel: *u8, stage: *u8, path: *u8): void;
// Cap residual: invoke ensure(argv0) through a C function pointer (no .x fnptr call ABI yet).
// ensure_fn is raw pointer bits of int (*)(const char*); null → 0 (skip ensure).
export extern "C" function link_abi_call_ensure_argv0(ensure_fn: *u8, link_argv0: *u8): i32;
// Cap residual: compiler-dir / cwd primary paths for nostdlib minimal runtime .o (static buf).
// Empty string on fail — push_obj treats primary[0]==0 as missing (falls back to rel).
// wave163: xlang_runtime_panic_o_path is pure export below (no longer Cap residual).
// wave164: xlang_crt0_user_o_path is pure export below (no longer Cap residual).
// wave165: xlang_freestanding_io_o_path is pure export below (no longer Cap residual).
// wave166: xlang_std_async_scheduler_o_path is pure export below (no longer Cap residual).
// wave180: scheduler_o_for_task_link is pure export below (no longer Cap residual always-mega).
// wave181: xlang_bootstrap_nostdlib_stubs_o_path is pure export below (no longer Cap residual always-mega).
// wave183: thin xlang_runtime_*_o_path (incl. asm_io_stubs / process_argv) are pure exports below.
// wave184: empty_cstr / std_io_o_path / std_compress_o_path / effective_link_argv0 pure below.
// wave185: xlang_rel_o_path_from_argv0 pure below (heap cstr_dup Cap residual).
// Cap residual (wave151/189): CLI user-extra .o table + host access R_OK (globals stay mega).
export extern "C" function link_abi_user_extra_o_count(): i32;
export extern "C" function link_abi_user_extra_o_at(i: i32): *u8;
export extern "C" function link_abi_user_extra_o_reset(): void;
export extern "C" function link_abi_user_extra_o_push(p: *u8): i32;
export extern "C" function link_abi_path_readable(path: *u8): i32;
// Cap residual (wave160): platform resolve of compiler/ dir (readlink / _NSGetExecutablePath /
// realpath argv0). Pure owns the leaf join into caller buffer (no snprintf Cap).
export extern "C" function shu_resolve_compiler_dir(argv0: *u8, out_dir: *u8, out_dir_sz: i64): i32;
// Cap residual (wave163 panic ladder): path_io peer pure realpath+skip; host getcwd.
// realpath_if_exists lives in labi_path_io (hybrid L3); getcwd is libc Cap.
export extern "C" function xlang_runtime_o_realpath_if_exists(path: *u8, resolved: *u8): *u8;
export extern "C" function getcwd(buf: *u8, size: i32): *u8;

// wave162: durable repo-root return buffer (≡ mega static char buf[512]).
// Not exported across TUs as a symbol; only returned by xlang_repo_root_from_argv0.
let g_labi_repo_root_buf: u8[512] = [];
// wave163: durable panic .o path buffers (≡ mega static buf[512] + resolved[PATH_MAX]).
let g_labi_panic_o_path_buf: u8[512] = [];
let g_labi_panic_o_path_resolved: u8[4096] = [];
// wave164: durable crt0_user .o path buffers (≡ mega static buf[512] + resolved[PATH_MAX]).
let g_labi_crt0_user_o_path_buf: u8[512] = [];
let g_labi_crt0_user_o_path_resolved: u8[4096] = [];
// wave165: durable freestanding_io .o path buffers (≡ mega static buf[512] + resolved[PATH_MAX]).
let g_labi_freestanding_io_o_path_buf: u8[512] = [];
let g_labi_freestanding_io_o_path_resolved: u8[4096] = [];
// wave166: durable async scheduler .o path buffers (≡ mega static PATH_MAX for both;
//   step3 realpath(argv0) needs room for absolute host paths, so 4096/4096 not 512).
let g_labi_async_scheduler_o_path_buf: u8[4096] = [];
let g_labi_async_scheduler_o_path_resolved: u8[4096] = [];
// wave180: durable task→scheduler rewrite buffers (≡ mega static derived[PATH_MAX] + cwd_buf).
let g_labi_sched_for_task_derived: u8[4096] = [];
let g_labi_sched_for_task_cwd: u8[4096] = [];
// wave181: durable bootstrap_nostdlib_stubs .o path buffers (≡ mega static PATH_MAX/PATH_MAX).
let g_labi_bootstrap_nostdlib_stubs_o_path_buf: u8[4096] = [];
let g_labi_bootstrap_nostdlib_stubs_o_path_resolved: u8[4096] = [];
// wave183: durable thin runtime_*_o_path BSS (≡ mega static PATH_MAX per leaf; 29 leaves).
// wave184: durable empty C string (≡ mega static char buf[1] for xlang_empty_cstr).
let g_labi_empty_cstr_buf: u8[1] = [];
let g_labi_asm_io_stubs_o_path_buf: u8[4096] = [];
let g_labi_process_argv_o_path_buf: u8[4096] = [];
let g_labi_process_os_glue_o_path_buf: u8[4096] = [];
let g_labi_test_fn_invoke_o_path_buf: u8[4096] = [];
let g_labi_random_fill_o_path_buf: u8[4096] = [];
let g_labi_compress_zlib_glue_o_path_buf: u8[4096] = [];
let g_labi_heap_user_o_path_buf: u8[4096] = [];
let g_labi_time_os_o_path_buf: u8[4096] = [];
let g_labi_queue_contention_o_path_buf: u8[4096] = [];
let g_labi_dynlib_os_o_path_buf: u8[4096] = [];
let g_labi_env_os_o_path_buf: u8[4096] = [];
let g_labi_backtrace_platform_o_path_buf: u8[4096] = [];
let g_labi_log_os_o_path_buf: u8[4096] = [];
let g_labi_math_libm_o_path_buf: u8[4096] = [];
let g_labi_atomic_glue_o_path_buf: u8[4096] = [];
let g_labi_channel_glue_o_path_buf: u8[4096] = [];
let g_labi_net_udp_batch_o_path_buf: u8[4096] = [];
let g_labi_net_workers_o_path_buf: u8[4096] = [];
let g_labi_sync_os_o_path_buf: u8[4096] = [];
let g_labi_sync_lock_diag_tls_o_path_buf: u8[4096] = [];
let g_labi_thread_glue_o_path_buf: u8[4096] = [];
let g_labi_scheduler_glue_o_path_buf: u8[4096] = [];
let g_labi_http_glue_o_path_buf: u8[4096] = [];
let g_labi_tls_mbedtls_bio_o_path_buf: u8[4096] = [];
let g_labi_kv_mmap_glue_o_path_buf: u8[4096] = [];
let g_labi_arrow_simd_glue_o_path_buf: u8[4096] = [];
let g_labi_sqlite_glue_o_path_buf: u8[4096] = [];
let g_labi_crypto_inc_glue_o_path_buf: u8[4096] = [];
let g_labi_ed25519_ref10_glue_o_path_buf: u8[4096] = [];
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
export function xlang_output_is_elf_o(path: *u8): i32 {
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
 * (complements xlang_output_is_elf_o; also rejects .s).
 * Invariants: path null/empty → 0; suffixes .o/.O/.s/.obj → 0; else → 1.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_output_want_exe(path: *u8): i32 {
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
export function xlang_path_has_sep(s: *u8): i32 {
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
export function xlang_path_last_sep(s: *u8): *u8 {
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
 * authority under XLANG_LABI_PATH_PURE_FROM_X. Not the same as driver_lib_root
 * (rt_lib_root; no low-tag) — keep link_abi symbol separate.
 * Track-L: #[no_mangle] keeps surface short name. PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_asm_ld_lib_root_ptr_usable(p: *u8): i32 {
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
 * Write default lib-root into root_buf (at least 512 bytes): env XLANG_LIB if usable,
 * else ".".
 * @param root_buf *u8 — caller buffer; capacity >= 512; always left NUL-terminated
 * @return void
 * Why (wave115): product hybrid still had always-linked mega C (getenv+strncpy).
 * Pure orch: default "." then pure usable-check on XLANG_LIB then byte copy
 * (no strncpy Cap). Cap residual: link_abi_getenv (wave222 pure thin → host getenv_impl;
 * wave223 G.7: this module no longer raw-getenv).
 * Differs from driver_lib_root_default by using low-tag usable (wave114).
 * Track-L: #[no_mangle] keeps surface short name. PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_asm_ld_lib_root_default(root_buf: *u8): void {
  // Default to "." before env probe (mega: root_buf[0]='.'; root_buf[1]=0).
  root_buf[0] = 46;
  root_buf[1] = 0;
  let def: *u8 = 0 as *u8;
  unsafe {
    def = link_abi_getenv("XLANG_LIB");
  }
  if (xlang_asm_ld_lib_root_ptr_usable(def) == 0) {
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
 * xlang_asm_ld_bank_push (path bank copy). Why (wave116): product hybrid still
 * had always-linked mega C (snprintf join + skip + bank). PLATFORM: SHARED.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_asm_ld_try_under_lib_roots(rel: *u8, lib_roots: **u8, n_lib_roots: i32, bank: *u8): *u8 {
  // Match mega: reject null / low-tag rel and empty rel.
  if (xlang_asm_ld_lib_root_ptr_usable(rel) == 0) {
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
    if (xlang_asm_ld_lib_root_ptr_usable(root) == 0) {
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
      pushed = xlang_asm_ld_bank_push(bank, &tmp[0]);
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
 * Copy path into durable bank (when bank non-null) then append to ld argv if absent.
 * Product callers use this so static path buffers are not left live in argv after the
 * next parse overwrites them.
 * @param bank *u8 — ShuAsmLdPathBank* or null (skip bank_push; keep p as-is)
 * @param argv **u8 — ld argv table (char**); null → no-op after bank_push attempt
 * @param la *i32 — in/out argv length; null → no-op
 * @param max_la i32 — argv capacity; need *la < max_la - 1 (room for NUL terminator slot)
 * @param p *u8 — resolved object path; null/empty → no-op
 * @return void
 * Pure orch: null/capacity guards + pure has_obj dedup + argv append. Cap residual:
 * xlang_asm_ld_bank_push (durable path copy into bank).
 * Why (wave147): hybrid still had always-mega C body over pure has_obj leaf.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * Note: la length uses la[0] (*i32 index form; same as labi_gates).
 * PLATFORM: SHARED — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function link_abi_asm_ld_argv_push_stable(bank: *u8, argv: **u8, la: *i32, max_la: i32, p: *u8): void {
  if (p == 0 as *u8) {
    return;
  }
  if (p[0] == 0) {
    return;
  }
  if (la == 0 as *i32) {
    return;
  }
  let cur: i32 = la[0];
  if (cur >= max_la - 1) {
    return;
  }
  // Cap residual: durable copy into bank when present (static buffers must not live in argv).
  let use_p: *u8 = p;
  if (bank != 0 as *u8) {
    let bp: *u8 = 0 as *u8;
    unsafe {
      bp = xlang_asm_ld_bank_push(bank, p);
    }
    if (bp != 0 as *u8) {
      use_p = bp;
    }
  }
  // Pure dedup (wave146 has_obj; Cap residual realpath inside).
  if (link_abi_asm_ld_argv_has_obj(argv, cur, use_p) != 0) {
    return;
  }
  // Guard argv null (product never null; pure avoids UB on assign).
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  argv[cur] = use_p;
  la[0] = cur + 1;
}

/**
 * Resolve a product .o (primary, argv0-relative rel, or lib-roots) and append to ld argv.
 * On-demand link path for std/runtime objects: skip missing files silently; durable bank
 * copy when bank is set so static path buffers are not left live in argv.
 * @param primary *u8 — preferred absolute/primary path; null/empty → skip primary probe
 * @param link_argv0 *u8 — compiler argv0 for rel_o_path Cap residual (may be null)
 * @param rel *u8 — relative .o under project/lib roots; null/empty → no rel/lib probe
 * @param lib_roots **u8 — table of lib root C strings; null/low-tag handled by try_under
 * @param n_lib_roots i32 — root count (try_under caps scan at 24)
 * @param bank *u8 — ShuAsmLdPathBank* or null (null → keep resolved pointer as-is)
 * @param argv **u8 — ld argv table (char**); null → fail after resolve (no append)
 * @param la *i32 — in/out argv length; null → 0
 * @param max_la i32 — argv capacity; need *la < max_la - 1
 * @param flag_out *i32 — optional success flag; set to 1 when a new argv slot is taken
 * @return i32 — 1 appended, 0 missing/full/dup/bank_push fail/null guards
 * Pure orch: capacity + pure cstr debug-target match + resolve ladder + hard bank_push +
 * pure has_obj dedup + append (reuses wave147 push_stable with bank=null after hard bank).
 * Cap residual: asm_link_obj_skip_missing, xlang_rel_o_path_from_argv0, xlang_asm_ld_bank_push,
 * link_abi_getenv("XLANG_DEBUG_LD") + link_diag_ld_debug_push for two runtime .o rels.
 * Pure peer: xlang_asm_ld_try_under_lib_roots (wave116), link_abi_asm_ld_argv_has_obj (146),
 * link_abi_asm_ld_argv_push_stable (147).
 * Why (wave148): hybrid still had always-mega C body over pure resolve/dedup leaves.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * Note: bank_push fail returns 0 (stricter than push_stable soft-keep); then push_stable
 * is called with bank=null so append path is single-authority.
 * PLATFORM: SHARED — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function link_abi_asm_ld_push_obj(primary: *u8, link_argv0: *u8, rel: *u8, lib_roots: **u8, n_lib_roots: i32, bank: *u8, argv: **u8, la: *i32, max_la: i32, flag_out: *i32): i32 {
  if (la == 0 as *i32) {
    return 0;
  }
  let cur: i32 = la[0];
  if (cur >= max_la - 1) {
    return 0;
  }
  // Pure: mark debug targets for XLANG_DEBUG_LD (two known runtime .o rels ≡ mega strcmp).
  let debug_runtime_obj: i32 = 0;
  if (rel != 0 as *u8) {
    let t1: *u8 = "compiler/runtime_asm_io_stubs.o";
    let t2: *u8 = "compiler/runtime_process_argv.o";
    let eq1: i32 = 1;
    let i1: i32 = 0;
    while (i1 < 1048576) {
      let ca: u8 = rel[i1];
      let cb: u8 = t1[i1];
      if (ca != cb) {
        eq1 = 0;
        break;
      }
      if (ca == 0) {
        break;
      }
      i1 = i1 + 1;
    }
    if (eq1 != 0) {
      debug_runtime_obj = 1;
    }
    if (debug_runtime_obj == 0) {
      let eq2: i32 = 1;
      let i2: i32 = 0;
      while (i2 < 1048576) {
        let ca2: u8 = rel[i2];
        let cb2: u8 = t2[i2];
        if (ca2 != cb2) {
          eq2 = 0;
          break;
        }
        if (ca2 == 0) {
          break;
        }
        i2 = i2 + 1;
      }
      if (eq2 != 0) {
        debug_runtime_obj = 1;
      }
    }
  }
  // Cap residual debug note: primary stage (only when env XLANG_DEBUG_LD set).
  // wave223 G.7: public pure thin link_abi_getenv (not raw libc getenv).
  if (debug_runtime_obj != 0) {
    let dbg: *u8 = 0 as *u8;
    unsafe {
      dbg = link_abi_getenv("XLANG_DEBUG_LD");
    }
    if (dbg != 0 as *u8) {
      let pp: *u8 = primary;
      if (pp == 0 as *u8) {
        pp = "(null)";
      }
      unsafe {
        link_diag_ld_debug_push(rel, "primary", pp);
      }
    }
  }
  // Resolve ladder: primary → argv0/rel → lib roots (Cap residual skip + rel_o_path).
  let p: *u8 = 0 as *u8;
  if (primary != 0 as *u8) {
    if (primary[0] != 0) {
      unsafe {
        p = asm_link_obj_skip_missing(primary);
      }
    }
  }
  if (debug_runtime_obj != 0) {
    let dbg2: *u8 = 0 as *u8;
    unsafe {
      dbg2 = link_abi_getenv("XLANG_DEBUG_LD");
    }
    if (dbg2 != 0 as *u8) {
      let ap: *u8 = p;
      if (ap == 0 as *u8) {
        ap = "(null)";
      }
      unsafe {
        link_diag_ld_debug_push(rel, "after-primary", ap);
      }
    }
  }
  if (p == 0 as *u8) {
    if (rel != 0 as *u8) {
      if (rel[0] != 0) {
        let relp: *u8 = 0 as *u8;
        unsafe {
          relp = xlang_rel_o_path_from_argv0(link_argv0, rel);
        }
        if (relp != 0 as *u8) {
          unsafe {
            p = asm_link_obj_skip_missing(relp);
          }
        }
      }
    }
  }
  if (p == 0 as *u8) {
    if (bank != 0 as *u8) {
      if (rel != 0 as *u8) {
        if (rel[0] != 0) {
          // Pure peer wave116 try_under (Cap residual skip+bank inside).
          p = xlang_asm_ld_try_under_lib_roots(rel, lib_roots, n_lib_roots, bank);
        }
      }
    }
  }
  if (p == 0 as *u8) {
    return 0;
  }
  // Hard bank_push when bank present (static path buffers must not live in argv).
  // Differs from push_stable soft-keep: bank_push fail → 0 (≡ mega).
  if (bank != 0 as *u8) {
    let bp: *u8 = 0 as *u8;
    unsafe {
      bp = xlang_asm_ld_bank_push(bank, p);
    }
    if (bp == 0 as *u8) {
      return 0;
    }
    p = bp;
  }
  if (debug_runtime_obj != 0) {
    let dbg3: *u8 = 0 as *u8;
    unsafe {
      dbg3 = link_abi_getenv("XLANG_DEBUG_LD");
    }
    if (dbg3 != 0 as *u8) {
      let fp: *u8 = p;
      if (fp == 0 as *u8) {
        fp = "(null)";
      }
      unsafe {
        link_diag_ld_debug_push(rel, "final", fp);
      }
    }
  }
  // Single-authority append: wave147 push_stable with bank=null (already banked hard).
  let before: i32 = la[0];
  link_abi_asm_ld_argv_push_stable(0 as *u8, argv, la, max_la, p);
  if (la[0] <= before) {
    return 0;
  }
  if (flag_out != 0 as *i32) {
    flag_out[0] = 1;
  }
  return 1;
}

/**
 * Push a runtime glue .o only when the owning std module is already on the ld argv.
 * Avoids glue UNDEF (e.g. log_write_c) when the corresponding std/*.o was not linked.
 * @param have_std i32 — non-zero when the related std .o is already pushed
 * @param ensure_fn *u8 — optional int (*)(const char* argv0) bits; null skips ensure
 * @param glue_primary *u8 — preferred primary path for the glue .o (may be null)
 * @param link_argv0 *u8 — compiler argv0 for resolve / ensure (may be null)
 * @param glue_rel *u8 — relative glue path under project/lib roots
 * @param lib_roots **u8 — lib root table for try_under (null-safe in push_obj)
 * @param n_lib_roots i32 — root count
 * @param bank *u8 — ShuAsmLdPathBank* for durable path copy (may be null)
 * @param argv **u8 — ld argv table
 * @param la *i32 — in/out argv length
 * @param max_la i32 — argv capacity
 * @return void — no-op when have_std==0 or ensure fails (non-zero); else push_obj
 * Pure orch: have_std gate + Cap residual call_ensure + pure peer push_obj (wave148).
 * Cap residual: link_abi_call_ensure_argv0 holds C function-pointer call.
 * Why (wave149): hybrid still had always-mega C body over pure push_obj leaf.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function link_abi_asm_ld_push_glue_after_std(have_std: i32, ensure_fn: *u8, glue_primary: *u8, link_argv0: *u8, glue_rel: *u8, lib_roots: **u8, n_lib_roots: i32, bank: *u8, argv: **u8, la: *i32, max_la: i32): void {
  if (have_std == 0) {
    return;
  }
  // Cap residual: only call ensure when a non-null function pointer was supplied.
  if (ensure_fn != 0 as *u8) {
    let rc: i32 = 0;
    unsafe {
      rc = link_abi_call_ensure_argv0(ensure_fn, link_argv0);
    }
    if (rc != 0) {
      return;
    }
  }
  // Single-authority resolve+append: pure peer wave148 push_obj (flag_out null).
  let _pushed: i32 = link_abi_asm_ld_push_obj(glue_primary, link_argv0, glue_rel, lib_roots, n_lib_roots, bank, argv, la, max_la, 0 as *i32);
  // Discard push result: mega glue helper is void (missing glue is silent skip).
  if (_pushed == 0) {
    return;
  }
}

/**
 * Resolve path of compiler/runtime_panic.o for ld / ensure primary.
 * Ladder (≡ mega): cwd `runtime_panic.o` → `compiler/runtime_panic.o` →
 * getcwd+`/compiler/runtime_panic.o` → argv0-dir+`/runtime_panic.o` (realpath then skip).
 * @param argv0 *u8 — optional product host path; may be null (cwd steps still run)
 * @return *u8 — static g_labi_panic_o_path_resolved (realpath hit) or
 *   g_labi_panic_o_path_buf (argv0 join / empty); never null
 * Pure orch: pure byte join + pure last-sep index strip; Cap residual
 *   xlang_runtime_o_realpath_if_exists (path_io peer) + getcwd + asm_link_obj_skip_missing.
 * Cap residual: getcwd (libc); realpath_if_exists_impl under path_io; skip via path_io pure.
 * Why (wave163): hybrid still had always-mega C body for complex panic path ladder after
 *   wave160–162 path residual (compiler-dir join / thin *_o_path / repo_root). First complex
 *   ladder leaf; freestanding_io pure at wave165; async_scheduler remain Cap residual.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch POSIX '/' — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 *   Windows mega rest may still use '\\' via cold path; product PREFER uses this pure POSIX.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_panic_o_path(argv0: *u8): *u8 {
  // Match mega: clear both durable buffers; return empty buf on total fail.
  g_labi_panic_o_path_buf[0] = 0;
  g_labi_panic_o_path_resolved[0] = 0;
  let hit: *u8 = 0 as *u8;
  // Step 1: cwd is compiler/ — bare runtime_panic.o next to xlang_asm.
  unsafe {
    hit = xlang_runtime_o_realpath_if_exists("runtime_panic.o", &g_labi_panic_o_path_resolved[0]);
  }
  if (hit != 0 as *u8) {
    return hit;
  }
  // Step 2: cwd is repo root — compiler/runtime_panic.o.
  unsafe {
    hit = xlang_runtime_o_realpath_if_exists("compiler/runtime_panic.o", &g_labi_panic_o_path_resolved[0]);
  }
  if (hit != 0 as *u8) {
    return hit;
  }
  // Step 3: getcwd + "/compiler/runtime_panic.o" then realpath_if_exists.
  // mega: getcwd(cwd, sizeof(cwd)-24) with cwd[512]; room for 24-byte suffix.
  let cwd: u8[512] = [];
  let gp: *u8 = 0 as *u8;
  unsafe {
    gp = getcwd(&cwd[0], 488);
  }
  if (gp != 0 as *u8) {
    let L: i32 = 0;
    while (cwd[L] != 0) {
      L = L + 1;
    }
    // "/compiler/runtime_panic.o" is 24 chars; need L+24 < 512 and write NUL.
    if (L + 24 < 512) {
      let suf: *u8 = "/compiler/runtime_panic.o";
      let si: i32 = 0;
      // Copy 24 path bytes + trailing NUL (mega memcpy 25 incl NUL).
      while (si <= 24) {
        cwd[L + si] = suf[si];
        si = si + 1;
      }
      unsafe {
        hit = xlang_runtime_o_realpath_if_exists(&cwd[0], &g_labi_panic_o_path_resolved[0]);
      }
      if (hit != 0 as *u8) {
        return hit;
      }
    }
  }
  // Step 4: argv0 parent directory + "/runtime_panic.o".
  if (argv0 != 0 as *u8) {
    if (argv0[0] != 0) {
      // Pure last-sep index (POSIX '/'); avoid pointer subtraction (no .x ptrdiff).
      let i: i32 = 0;
      let last_sep_i: i32 = -1;
      while (argv0[i] != 0) {
        if (argv0[i] == 47) {
          last_sep_i = i;
        }
        i = i + 1;
      }
      let n: i32 = 0;
      if (last_sep_i >= 0) {
        // mega: n = last_slash - argv0; refuse if n >= sizeof(buf)-20.
        if (last_sep_i >= 512 - 20) {
          return &g_labi_panic_o_path_buf[0];
        }
        let j: i32 = 0;
        while (j < last_sep_i) {
          g_labi_panic_o_path_buf[j] = argv0[j];
          j = j + 1;
        }
        g_labi_panic_o_path_buf[last_sep_i] = 0;
        n = last_sep_i;
      } else {
        // No sep: use "." as dir (≡ mega).
        g_labi_panic_o_path_buf[0] = 46;
        g_labi_panic_o_path_buf[1] = 0;
        n = 1;
      }
      // "/runtime_panic.o" is 16 chars; mega guard n + 18 < sizeof(buf).
      if (n + 18 < 512) {
        let leaf: *u8 = "/runtime_panic.o";
        let k: i32 = 0;
        while (leaf[k] != 0) {
          g_labi_panic_o_path_buf[n + k] = leaf[k];
          k = k + 1;
        }
        g_labi_panic_o_path_buf[n + k] = 0;
        unsafe {
          hit = xlang_runtime_o_realpath_if_exists(&g_labi_panic_o_path_buf[0], &g_labi_panic_o_path_resolved[0]);
        }
        if (hit != 0 as *u8) {
          return hit;
        }
        // Cap residual peer: accept non-realpath'd path if file exists (skip_missing).
        let sm: *u8 = 0 as *u8;
        unsafe {
          sm = asm_link_obj_skip_missing(&g_labi_panic_o_path_buf[0]);
        }
        if (sm != 0 as *u8) {
          return &g_labi_panic_o_path_buf[0];
        }
      }
    }
  }
  return &g_labi_panic_o_path_buf[0];
}

/**
 * Resolve path of compiler/crt0_user.o for freestanding / nostdlib ld primary.
 * Ladder (≡ mega): `compiler/crt0_user.o` → getcwd+`/compiler/crt0_user.o` →
 * argv0-dir+`/crt0_user.o` (realpath then return joined buf even without realpath hit).
 * @param argv0 *u8 — optional product host path; may be null (cwd steps still run)
 * @return *u8 — static g_labi_crt0_user_o_path_resolved (realpath hit) or
 *   g_labi_crt0_user_o_path_buf (argv0 join / empty); never null
 * Pure orch: pure byte join + pure last-sep index strip; Cap residual
 *   link_abi_realpath_cap (POSIX realpath; Windows null) + getcwd.
 * Cap residual: getcwd (libc); realpath via link_abi_realpath_cap (G.7 single Cap).
 * Why (wave164): hybrid still had always-mega C body for complex crt0 path ladder after
 *   wave163 panic ladder. Second complex ladder leaf; freestanding_io pure at wave165;
 *   async_scheduler remain Cap residual.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch POSIX '/' — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 *   Windows mega rest may still use '\\' via cold path; product PREFER uses this pure POSIX.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_crt0_user_o_path(argv0: *u8): *u8 {
  // Match mega: clear both durable buffers; return empty buf on total fail.
  g_labi_crt0_user_o_path_buf[0] = 0;
  g_labi_crt0_user_o_path_resolved[0] = 0;
  let hit: *u8 = 0 as *u8;
  // Step 1: cwd is repo root — compiler/crt0_user.o (mega starts here; no bare leaf).
  unsafe {
    hit = link_abi_realpath_cap("compiler/crt0_user.o", &g_labi_crt0_user_o_path_resolved[0]);
  }
  if (hit != 0 as *u8) {
    return hit;
  }
  // Step 2: getcwd + "/compiler/crt0_user.o" then realpath.
  // mega: getcwd(cwd, sizeof(cwd)-22) with cwd[512]; "/compiler/crt0_user.o" is 21 chars.
  let cwd: u8[512] = [];
  let gp: *u8 = 0 as *u8;
  unsafe {
    gp = getcwd(&cwd[0], 490);
  }
  if (gp != 0 as *u8) {
    let L: i32 = 0;
    while (cwd[L] != 0) {
      L = L + 1;
    }
    // 21 path bytes + NUL; need L+21 < 512.
    if (L + 21 < 512) {
      let suf: *u8 = "/compiler/crt0_user.o";
      let si: i32 = 0;
      // Copy 21 path bytes + trailing NUL.
      while (si <= 21) {
        cwd[L + si] = suf[si];
        si = si + 1;
      }
      unsafe {
        hit = link_abi_realpath_cap(&cwd[0], &g_labi_crt0_user_o_path_resolved[0]);
      }
      if (hit != 0 as *u8) {
        return hit;
      }
    }
  }
  // Step 3: argv0 parent directory + "/crt0_user.o".
  if (argv0 != 0 as *u8) {
    if (argv0[0] != 0) {
      // Pure last-sep index (POSIX '/'); avoid pointer subtraction (no .x ptrdiff).
      let i: i32 = 0;
      let last_sep_i: i32 = -1;
      while (argv0[i] != 0) {
        if (argv0[i] == 47) {
          last_sep_i = i;
        }
        i = i + 1;
      }
      let n: i32 = 0;
      if (last_sep_i >= 0) {
        // mega: n = last_slash - argv0; refuse if n >= sizeof(buf)-16.
        if (last_sep_i >= 512 - 16) {
          return &g_labi_crt0_user_o_path_buf[0];
        }
        let j: i32 = 0;
        while (j < last_sep_i) {
          g_labi_crt0_user_o_path_buf[j] = argv0[j];
          j = j + 1;
        }
        g_labi_crt0_user_o_path_buf[last_sep_i] = 0;
        n = last_sep_i;
      } else {
        // No sep: use "." as dir (≡ mega).
        g_labi_crt0_user_o_path_buf[0] = 46;
        g_labi_crt0_user_o_path_buf[1] = 0;
        n = 1;
      }
      // "/crt0_user.o" is 12 chars; mega guard n + 14 < sizeof(buf).
      if (n + 14 < 512) {
        let leaf: *u8 = "/crt0_user.o";
        let k: i32 = 0;
        while (leaf[k] != 0) {
          g_labi_crt0_user_o_path_buf[n + k] = leaf[k];
          k = k + 1;
        }
        g_labi_crt0_user_o_path_buf[n + k] = 0;
        unsafe {
          hit = link_abi_realpath_cap(&g_labi_crt0_user_o_path_buf[0], &g_labi_crt0_user_o_path_resolved[0]);
        }
        if (hit != 0 as *u8) {
          return hit;
        }
        // mega: after argv0 join, always return buf even without realpath hit.
        return &g_labi_crt0_user_o_path_buf[0];
      }
    }
  }
  return &g_labi_crt0_user_o_path_buf[0];
}

/**
 * Resolve path of compiler/freestanding_io.o for freestanding / nostdlib syscall write.
 * Ladder (≡ mega): `compiler/freestanding_io.o` → getcwd+`/compiler/freestanding_io.o` →
 * argv0-dir+`/freestanding_io.o` (realpath then return joined buf even without realpath hit).
 * @param argv0 *u8 — optional product host path; may be null (cwd steps still run)
 * @return *u8 — static g_labi_freestanding_io_o_path_resolved (realpath hit) or
 *   g_labi_freestanding_io_o_path_buf (argv0 join / empty); never null
 * Pure orch: pure byte join + pure last-sep index strip; Cap residual
 *   link_abi_realpath_cap (POSIX realpath; Windows null) + getcwd.
 * Cap residual: getcwd (libc); realpath via link_abi_realpath_cap (G.7 single Cap).
 * Why (wave165): hybrid still had always-mega C body for complex freestanding_io path ladder
 *   after wave164 crt0 ladder. Third complex ladder leaf; async_scheduler pure at wave166.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch POSIX '/' — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 *   Windows mega rest may still use '\\' via cold path; product PREFER uses this pure POSIX.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_freestanding_io_o_path(argv0: *u8): *u8 {
  // Match mega: clear both durable buffers; return empty buf on total fail.
  g_labi_freestanding_io_o_path_buf[0] = 0;
  g_labi_freestanding_io_o_path_resolved[0] = 0;
  let hit: *u8 = 0 as *u8;
  // Step 1: cwd is repo root — compiler/freestanding_io.o (mega starts here; no bare leaf).
  unsafe {
    hit = link_abi_realpath_cap("compiler/freestanding_io.o", &g_labi_freestanding_io_o_path_resolved[0]);
  }
  if (hit != 0 as *u8) {
    return hit;
  }
  // Step 2: getcwd + "/compiler/freestanding_io.o" then realpath.
  // mega: getcwd(cwd, sizeof(cwd)-28) with cwd[512]; path is 27 chars + NUL memcpy 28.
  let cwd: u8[512] = [];
  let gp: *u8 = 0 as *u8;
  unsafe {
    gp = getcwd(&cwd[0], 484);
  }
  if (gp != 0 as *u8) {
    let L: i32 = 0;
    while (cwd[L] != 0) {
      L = L + 1;
    }
    // 27 path bytes + NUL; need L+27 < 512.
    if (L + 27 < 512) {
      let suf: *u8 = "/compiler/freestanding_io.o";
      let si: i32 = 0;
      // Copy 27 path bytes + trailing NUL.
      while (si <= 27) {
        cwd[L + si] = suf[si];
        si = si + 1;
      }
      unsafe {
        hit = link_abi_realpath_cap(&cwd[0], &g_labi_freestanding_io_o_path_resolved[0]);
      }
      if (hit != 0 as *u8) {
        return hit;
      }
    }
  }
  // Step 3: argv0 parent directory + "/freestanding_io.o".
  if (argv0 != 0 as *u8) {
    if (argv0[0] != 0) {
      // Pure last-sep index (POSIX '/'); avoid pointer subtraction (no .x ptrdiff).
      let i: i32 = 0;
      let last_sep_i: i32 = -1;
      while (argv0[i] != 0) {
        if (argv0[i] == 47) {
          last_sep_i = i;
        }
        i = i + 1;
      }
      let n: i32 = 0;
      if (last_sep_i >= 0) {
        // mega: n = last_slash - argv0; refuse if n >= sizeof(buf)-20.
        if (last_sep_i >= 512 - 20) {
          return &g_labi_freestanding_io_o_path_buf[0];
        }
        let j: i32 = 0;
        while (j < last_sep_i) {
          g_labi_freestanding_io_o_path_buf[j] = argv0[j];
          j = j + 1;
        }
        g_labi_freestanding_io_o_path_buf[last_sep_i] = 0;
        n = last_sep_i;
      } else {
        // No sep: use "." as dir (≡ mega).
        g_labi_freestanding_io_o_path_buf[0] = 46;
        g_labi_freestanding_io_o_path_buf[1] = 0;
        n = 1;
      }
      // "/freestanding_io.o" is 18 chars; mega guard n + 18 < sizeof(buf).
      if (n + 18 < 512) {
        let leaf: *u8 = "/freestanding_io.o";
        let k: i32 = 0;
        while (leaf[k] != 0) {
          g_labi_freestanding_io_o_path_buf[n + k] = leaf[k];
          k = k + 1;
        }
        g_labi_freestanding_io_o_path_buf[n + k] = 0;
        unsafe {
          hit = link_abi_realpath_cap(&g_labi_freestanding_io_o_path_buf[0], &g_labi_freestanding_io_o_path_resolved[0]);
        }
        if (hit != 0 as *u8) {
          return hit;
        }
        // mega: after argv0 join, always return buf even without realpath hit.
        return &g_labi_freestanding_io_o_path_buf[0];
      }
    }
  }
  return &g_labi_freestanding_io_o_path_buf[0];
}

/**
 * Resolve path of std/async/scheduler.o for on-demand async coop link.
 * Ladder (≡ mega): `std/async/scheduler.o` → getcwd+`/std/async/scheduler.o` →
 * realpath(argv0) then parent dir + `/../std/async/scheduler.o` (repo-root relative from
 * compiler binary location). Distinct from freestanding/crt0 leaf join under compiler/.
 * @param argv0 *u8 — optional product host path; may be null (cwd steps still run)
 * @return *u8 — static g_labi_async_scheduler_o_path_resolved (realpath hit) or
 *   g_labi_async_scheduler_o_path_buf (argv0 realpath / join / empty); never null
 * Pure orch: pure byte join + pure last-sep index strip; Cap residual
 *   link_abi_realpath_cap (POSIX realpath; Windows null) + getcwd.
 * Cap residual: getcwd (libc); realpath via link_abi_realpath_cap (G.7 single Cap).
 * Why (wave166): hybrid still had always-mega C body for complex async_scheduler path ladder
 *   after wave165 freestanding_io ladder. Fourth complex ladder leaf.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch POSIX '/' — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 *   Windows mega rest may still use '\\' via cold path; product PREFER uses this pure POSIX.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_std_async_scheduler_o_path(argv0: *u8): *u8 {
  // Match mega: clear both durable buffers; return empty buf on total fail.
  g_labi_async_scheduler_o_path_buf[0] = 0;
  g_labi_async_scheduler_o_path_resolved[0] = 0;
  let hit: *u8 = 0 as *u8;
  // Step 1: cwd is repo root — std/async/scheduler.o.
  unsafe {
    hit = link_abi_realpath_cap("std/async/scheduler.o", &g_labi_async_scheduler_o_path_resolved[0]);
  }
  if (hit != 0 as *u8) {
    return hit;
  }
  // Step 2: getcwd + "/std/async/scheduler.o" then realpath.
  // mega: getcwd(cwd, sizeof(cwd)-26) with cwd[512]; memcpy 22 path bytes + NUL at L+22.
  let cwd: u8[512] = [];
  let gp: *u8 = 0 as *u8;
  unsafe {
    gp = getcwd(&cwd[0], 486);
  }
  if (gp != 0 as *u8) {
    let L: i32 = 0;
    while (cwd[L] != 0) {
      L = L + 1;
    }
    // mega: L + 26 <= sizeof(cwd); 22 path bytes + trailing NUL.
    if (L + 26 <= 512) {
      let suf: *u8 = "/std/async/scheduler.o";
      let si: i32 = 0;
      while (si <= 22) {
        cwd[L + si] = suf[si];
        si = si + 1;
      }
      unsafe {
        hit = link_abi_realpath_cap(&cwd[0], &g_labi_async_scheduler_o_path_resolved[0]);
      }
      if (hit != 0 as *u8) {
        return hit;
      }
    }
  }
  // Step 3: realpath(argv0) into work buf, strip last sep, append /../std/async/scheduler.o.
  // mega requires realpath(argv0) success first (unlike freestanding raw argv0 parent strip).
  if (argv0 != 0 as *u8) {
    if (argv0[0] != 0) {
      let rp: *u8 = 0 as *u8;
      unsafe {
        rp = link_abi_realpath_cap(argv0, &g_labi_async_scheduler_o_path_buf[0]);
      }
      if (rp != 0 as *u8) {
        // Pure last-sep index on resolved argv0 (POSIX '/'); avoid pointer subtraction.
        let i: i32 = 0;
        let last_sep_i: i32 = -1;
        while (g_labi_async_scheduler_o_path_buf[i] != 0) {
          if (g_labi_async_scheduler_o_path_buf[i] == 47) {
            last_sep_i = i;
          }
          i = i + 1;
        }
        if (last_sep_i >= 0) {
          // mega: (last - buf) + 26 < sizeof(buf); sizeof ≡ 4096.
          if (last_sep_i + 26 < 4096) {
            g_labi_async_scheduler_o_path_buf[last_sep_i] = 0;
            let n: i32 = last_sep_i;
            // "/../std/async/scheduler.o" is 25 chars.
            let leaf: *u8 = "/../std/async/scheduler.o";
            let k: i32 = 0;
            while (leaf[k] != 0) {
              g_labi_async_scheduler_o_path_buf[n + k] = leaf[k];
              k = k + 1;
            }
            g_labi_async_scheduler_o_path_buf[n + k] = 0;
            unsafe {
              hit = link_abi_realpath_cap(&g_labi_async_scheduler_o_path_buf[0], &g_labi_async_scheduler_o_path_resolved[0]);
            }
            if (hit != 0 as *u8) {
              return hit;
            }
          }
        }
      }
    }
  }
  return &g_labi_async_scheduler_o_path_buf[0];
}

/**
 * Push nostdlib minimal runtime .o set: io_stubs + process_argv + panic.
 * hello / freestanding product paths still need std_fmt_print stubs and panic even when
 * no std/*.o is scanned; omit only when resolve fails (push_obj silent skip).
 * @param link_argv0 *u8 — compiler argv0 for Cap residual primary path helpers (may be null)
 * @param lib_roots **u8 — lib root table for try_under (null-safe in push_obj)
 * @param n_lib_roots i32 — root count
 * @param bank *u8 — ShuAsmLdPathBank* for durable path copy (may be null)
 * @param argv **u8 — ld argv table
 * @param la *i32 — in/out argv length
 * @param max_la i32 — argv capacity
 * @return void — always attempts three push_obj; each may no-op if resolve fails
 * Pure orch: Cap residual *_o_path primary (io/process) + pure peer panic_o_path (wave163)
 *   + pure peer push_obj ×3 (wave148).
 * Peer pure (wave183): xlang_runtime_asm_io_stubs_o_path / process_argv_o_path
 *   (compiler-dir / cwd resolve; static buffers; empty → primary unused).
 * Why (wave150): hybrid still had always-mega C body over pure push_obj leaves.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function link_abi_asm_ld_push_minimal_runtime_objs(link_argv0: *u8, lib_roots: **u8, n_lib_roots: i32, bank: *u8, argv: **u8, la: *i32, max_la: i32): void {
  let io_p: *u8 = 0 as *u8;
  let proc_p: *u8 = 0 as *u8;
  let panic_p: *u8 = 0 as *u8;
  // Cap residual: preferred primary next to compiler binary (static buf per helper).
  // wave163: panic primary is pure peer in this module (no Cap residual).
  unsafe {
    io_p = xlang_runtime_asm_io_stubs_o_path(link_argv0);
    proc_p = xlang_runtime_process_argv_o_path(link_argv0);
  }
  panic_p = xlang_runtime_panic_o_path(link_argv0);
  // Single-authority resolve+append ×3: pure peer wave148 push_obj (flag_out null).
  // Each result discarded: mega helper is void (missing .o is silent skip).
  let _io: i32 = link_abi_asm_ld_push_obj(io_p, link_argv0, "compiler/runtime_asm_io_stubs.o", lib_roots, n_lib_roots, bank, argv, la, max_la, 0 as *i32);
  if (_io == 0) {
    // continue: missing io_stubs does not block process_argv/panic
  }
  let _pa: i32 = link_abi_asm_ld_push_obj(proc_p, link_argv0, "compiler/runtime_process_argv.o", lib_roots, n_lib_roots, bank, argv, la, max_la, 0 as *i32);
  if (_pa == 0) {
    // continue: missing process_argv does not block panic
  }
  let _pn: i32 = link_abi_asm_ld_push_obj(panic_p, link_argv0, "compiler/runtime_panic.o", lib_roots, n_lib_roots, bank, argv, la, max_la, 0 as *i32);
  if (_pn == 0) {
    return;
  }
}

/**
 * Append CLI user-specified extra .o paths onto an asm ld argv.
 * Same single-authority table as invoke_cc (`g_xlang_user_extra_o_files`); call after
 * std/on_demand appends and before argv NULL terminator on every asm ld branch.
 * @param argv **u8 — ld argv table (char**); null → no-op
 * @param la *i32 — in/out argv length; null → no-op
 * @param max_la i32 — argv capacity; need *la < max_la - 1 (room for NUL terminator)
 * @return void — skips null/empty/unreadable paths; stops when capacity exhausted
 * Pure orch: Cap residual table count/at + path_readable (access R_OK) + pure append loop.
 * Cap residual: link_abi_user_extra_o_count / link_abi_user_extra_o_at / link_abi_path_readable
 *   (globals + host access stay mega; pure owns the argv walk).
 * Why (wave151): hybrid still had always-mega C body for CLI extra .o push (static helper).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_asm_ld_append_user_extra_o_files(argv: **u8, la: *i32, max_la: i32): void {
  // Guard argv null via *u8 cast (same as wave147 push_stable; avoid **u8 null compare drop).
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (la == 0 as *i32) {
    return;
  }
  let n: i32 = 0;
  unsafe {
    n = link_abi_user_extra_o_count();
  }
  let ui: i32 = 0;
  while (ui < n) {
    // Capacity guard: leave one slot for argv NULL terminator (≡ mega max_la - 1).
    let cur: i32 = la[0];
    if (cur >= max_la - 1) {
      break;
    }
    let p: *u8 = 0 as *u8;
    unsafe {
      p = link_abi_user_extra_o_at(ui);
    }
    ui = ui + 1;
    if (p == 0 as *u8) {
      continue;
    }
    if (p[0] == 0) {
      continue;
    }
    // Cap residual: host access(path, R_OK) — skip unreadable paths (≡ mega).
    let ok: i32 = 0;
    unsafe {
      ok = link_abi_path_readable(p);
    }
    if (ok == 0) {
      continue;
    }
    // Store path pointer (no copy; argv lifetime covers subsequent spawn).
    argv[cur] = p;
    la[0] = cur + 1;
  }
}

/**
 * Join `compiler_dir/leaf` into caller buffer after Cap residual resolve.
 * Authority for all thin `xlang_runtime_*_o_path` leaves that need compiler-dir
 * primary paths (wave161 G.7: process_os_glue … ed25519 + asm_io_stubs /
 * process_argv all route join here; wave183 pure owns static BSS return buffers).
 * @param argv0 *u8 — optional product host path; may be null (resolve uses self/exe)
 * @param leaf *u8 — object leaf under compiler/ (e.g. "runtime_asm_io_stubs.o"); null/empty → -1
 * @param out *u8 — caller buffer for joined path; null → -1
 * @param out_sz i64 — out capacity in bytes; 0 → -1; must fit dir + '/' + leaf + NUL
 * @return i32 — 0 on success (out NUL-terminated); -1 on resolve fail / overflow / bad args
 * Pure orch: null/empty guards + Cap residual shu_resolve_compiler_dir into 4096 stack
 *   + pure byte join (no snprintf Cap; ≡ mega snprintf("%s/%s", dir, leaf)).
 * Cap residual: shu_resolve_compiler_dir (PLATFORM LINUX/MACOS/WINDOWS #if body stays mega).
 * Why (wave160): hybrid still had always-mega C body for compiler-dir/leaf join after
 *   platform resolve (path residual first clean leaf after freestanding_enabled).
 * Note: out_sz uses i64 (ABI with size_t callers); compare joins as i64.
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_compiler_o_path_copy(argv0: *u8, leaf: *u8, out: *u8, out_sz: i64): i32 {
  // Match mega: reject null out, zero size, null/empty leaf.
  if (out == 0 as *u8) {
    return -1;
  }
  if (out_sz == 0) {
    return -1;
  }
  if (leaf == 0 as *u8) {
    return -1;
  }
  if (leaf[0] == 0) {
    return -1;
  }
  out[0] = 0;
  // Cap residual: platform compiler-dir resolve into 4096 stack (PATH_MAX upper).
  let comp_dir: u8[4096] = [];
  let rc: i32 = 0;
  unsafe {
    rc = shu_resolve_compiler_dir(argv0, &comp_dir[0], 4096);
  }
  if (rc != 0) {
    return -1;
  }
  // Pure strlen(comp_dir) / strlen(leaf).
  let dn: i32 = 0;
  while (comp_dir[dn] != 0) {
    dn = dn + 1;
  }
  let ln: i32 = 0;
  while (leaf[ln] != 0) {
    ln = ln + 1;
  }
  // snprintf("%s/%s") writes dn+1+ln chars + NUL; fails if nn >= out_sz (mega size_t).
  let need: i64 = (dn as i64) + 1 + (ln as i64);
  if (need >= out_sz) {
    out[0] = 0;
    return -1;
  }
  // Byte join: comp_dir[0..dn) + '/' + leaf[0..ln] + NUL.
  let i: i32 = 0;
  while (i < dn) {
    out[i] = comp_dir[i];
    i = i + 1;
  }
  out[dn] = 47;
  let k: i32 = 0;
  while (k <= ln) {
    out[dn + 1 + k] = leaf[k];
    k = k + 1;
  }
  return 0;
}

/**
 * Derive repo root from the product host binary path.
 * Authority (G.7): Cap residual shu_resolve_compiler_dir (compiler/) → parent = repo root;
 * warm-tree fallback strips std/process/process.o three seps via Cap residual rel_o_path.
 * @param argv0 *u8 — optional product host path (also resolve fallback); may be null
 * @return *u8 — static g_labi_repo_root_buf with repo root, or empty string (never null)
 * Pure orch: pure memcpy into BSS + pure path_last_sep strip; no snprintf.
 * Cap residual: shu_resolve_compiler_dir (PLATFORM LINUX/MACOS/WINDOWS #if) +
 *   xlang_rel_o_path_from_argv0 (realpath/getcwd ladder for process.o warm path).
 * Why (wave162): hybrid still had always-mega C body for repo-root derivation after
 *   wave160/161 path residual (compiler-dir join + thin *_o_path). L4 wipe loses process.o
 *   so primary must be compiler-dir parent (not process.o walk alone).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_repo_root_from_argv0(argv0: *u8): *u8 {
  // Match mega: start empty; return empty string pointer on total fail.
  g_labi_repo_root_buf[0] = 0;
  // Primary: compiler dir from self/exe or argv0 → parent is repo root.
  let comp: u8[4096] = [];
  let rc: i32 = 0;
  unsafe {
    rc = shu_resolve_compiler_dir(argv0, &comp[0], 4096);
  }
  if (rc == 0) {
    if (comp[0] != 0) {
      // Pure strlen(comp); mega: strlen(comp) < sizeof(buf) before memcpy.
      let n: i32 = 0;
      while (comp[n] != 0) {
        n = n + 1;
      }
      if (n < 512) {
        let i: i32 = 0;
        while (i <= n) {
          g_labi_repo_root_buf[i] = comp[i];
          i = i + 1;
        }
        // Strip last path component (compiler/) → repo root.
        let last: *u8 = xlang_path_last_sep(&g_labi_repo_root_buf[0]);
        if (last != 0 as *u8) {
          // Mega: last && last != buf — refuse strip when only one component.
          if (last != &g_labi_repo_root_buf[0]) {
            last[0] = 0;
            return &g_labi_repo_root_buf[0];
          }
        }
        g_labi_repo_root_buf[0] = 0;
      }
    }
  }
  // Fallback: process.o exists (warm tree) → strip std/process/process.o (3 seps).
  let rel: *u8 = "std/process/process.o";
  let proc_o: *u8 = 0 as *u8;
  unsafe {
    proc_o = xlang_rel_o_path_from_argv0(argv0, rel);
  }
  if (proc_o == 0 as *u8) {
    return &g_labi_repo_root_buf[0];
  }
  if (proc_o[0] == 0) {
    return &g_labi_repo_root_buf[0];
  }
  let pn: i32 = 0;
  while (proc_o[pn] != 0) {
    pn = pn + 1;
  }
  if (pn >= 512) {
    return &g_labi_repo_root_buf[0];
  }
  let j: i32 = 0;
  while (j <= pn) {
    g_labi_repo_root_buf[j] = proc_o[j];
    j = j + 1;
  }
  let k: i32 = 0;
  while (k < 3) {
    let last2: *u8 = xlang_path_last_sep(&g_labi_repo_root_buf[0]);
    if (last2 == 0 as *u8) {
      break;
    }
    if (last2 == &g_labi_repo_root_buf[0]) {
      break;
    }
    last2[0] = 0;
    k = k + 1;
  }
  return &g_labi_repo_root_buf[0];
}

/**
 * When linking task.o, also pull scheduler.o; derive path from task_o if caller omitted it.
 * Ladder (≡ mega scheduler_o_for_task_link):
 *   1) non-empty explicit_scheduler → return it as-is
 *   2) null/empty task_o → null
 *   3) copy task_o into BSS; if it contains "std/task/task.o", rewrite to
 *      "std/async/scheduler.o" (expand by 7 bytes) and Cap residual path_readable → return derived
 *   4) Cap residual realpath_cap("std/async/scheduler.o") → durable cwd buf or null
 * Pure orch: pure cstr copy + pure needle scan + pure expand-in-place rewrite;
 * Cap residual: link_abi_path_readable (access R_OK; ≡ mega F_OK for product .o) +
 *   link_abi_realpath_cap (POSIX realpath; Windows null).
 * Cap residual: path_readable + realpath_cap only (no snprintf / strstr libc).
 * Why (wave180): hybrid still had always-mega C body for task→scheduler path rewrite
 *   (strstr + memmove + access F_OK + realpath). Soft residual after wave166 path ladder.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function scheduler_o_for_task_link(task_o: *u8, explicit_scheduler: *u8): *u8 {
  // Step 1: explicit path wins (caller already resolved scheduler.o).
  if (explicit_scheduler != 0 as *u8) {
    if (explicit_scheduler[0] != 0) {
      return explicit_scheduler;
    }
  }
  // Step 2: no task path → cannot derive.
  if (task_o == 0 as *u8) {
    return 0 as *u8;
  }
  if (task_o[0] == 0) {
    return 0 as *u8;
  }
  // Pure strlen(task_o); mega: strlen >= PATH_MAX → null.
  let n: i32 = 0;
  while (task_o[n] != 0) {
    n = n + 1;
  }
  if (n >= 4096) {
    return 0 as *u8;
  }
  // Copy task_o including trailing NUL into durable derived buf.
  let ci: i32 = 0;
  while (ci <= n) {
    g_labi_sched_for_task_derived[ci] = task_o[ci];
    ci = ci + 1;
  }
  // Needle "std/task/task.o" (15) → replacement "std/async/scheduler.o" (22); expand +7.
  let from: *u8 = "std/task/task.o";
  let from_len: i32 = 15;
  let to: *u8 = "std/async/scheduler.o";
  let to_len: i32 = 22;
  let delta: i32 = 7;
  // Pure first-match scan (≡ mega strstr on derived).
  let pos: i32 = -1;
  let i: i32 = 0;
  while (i + from_len <= n) {
    if (pos < 0) {
      let j: i32 = 0;
      let ok: i32 = 1;
      while (j < from_len) {
        if (ok != 0) {
          if (g_labi_sched_for_task_derived[i + j] != from[j]) {
            ok = 0;
          }
        }
        j = j + 1;
      }
      if (ok != 0) {
        pos = i;
      }
    }
    i = i + 1;
  }
  if (pos >= 0) {
    // Expanded length including NUL must fit BSS (mega PATH_MAX; avoid tail overflow).
    let new_n: i32 = n + delta;
    if (new_n < 4096) {
      // memmove tail right by delta (including NUL at index n).
      let si: i32 = n;
      while (si >= pos + from_len) {
        g_labi_sched_for_task_derived[si + delta] = g_labi_sched_for_task_derived[si];
        si = si - 1;
      }
      // Overlay replacement needle.
      let k: i32 = 0;
      while (k < to_len) {
        g_labi_sched_for_task_derived[pos + k] = to[k];
        k = k + 1;
      }
      // Cap residual: file exists and is readable (product .o; ≡ mega access F_OK).
      let readable: i32 = 0;
      unsafe {
        readable = link_abi_path_readable(&g_labi_sched_for_task_derived[0]);
      }
      if (readable != 0) {
        return &g_labi_sched_for_task_derived[0];
      }
    }
  }
  // Fallback: realpath cwd-relative std/async/scheduler.o (≡ mega realpath into cwd_buf).
  g_labi_sched_for_task_cwd[0] = 0;
  let hit: *u8 = 0 as *u8;
  unsafe {
    hit = link_abi_realpath_cap("std/async/scheduler.o", &g_labi_sched_for_task_cwd[0]);
  }
  if (hit != 0 as *u8) {
    return hit;
  }
  return 0 as *u8;
}

/**
 * Resolve path of bootstrap_nostdlib_stubs.o (mmap bump malloc/free face for freestanding).
 * Ladder (≡ mega xlang_bootstrap_nostdlib_stubs_o_path):
 *   1) realpath cwd-relative `compiler/src/asm/bootstrap_nostdlib_stubs.o`
 *   2) Cap residual shu_resolve_compiler_dir + pure join `comp/src/asm/bootstrap_nostdlib_stubs.o`
 *      then realpath; if realpath fails still return joined buf (≡ mega)
 *   3) empty buf on total fail
 * @param argv0 *u8 — optional product host path for resolve fallback; may be null
 * @return *u8 — static resolved (realpath hit) or buf (joined/empty); never null
 * Pure orch: pure byte join compiler-dir/leaf (no snprintf); Cap residual
 *   link_abi_realpath_cap + shu_resolve_compiler_dir.
 * Why (wave181): hybrid still had always-mega C body for nostdlib stubs path
 *   (realpath + snprintf after resolve). Soft residual after wave180 task→scheduler.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch POSIX '/' — product leaf under compiler/src/asm; LINUX freestanding
 *   consumers primary; hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_bootstrap_nostdlib_stubs_o_path(argv0: *u8): *u8 {
  // Match mega: clear both durable buffers; return empty buf on total fail.
  g_labi_bootstrap_nostdlib_stubs_o_path_buf[0] = 0;
  g_labi_bootstrap_nostdlib_stubs_o_path_resolved[0] = 0;
  let hit: *u8 = 0 as *u8;
  // Step 1: cwd is repo root — compiler/src/asm/bootstrap_nostdlib_stubs.o.
  unsafe {
    hit = link_abi_realpath_cap("compiler/src/asm/bootstrap_nostdlib_stubs.o", &g_labi_bootstrap_nostdlib_stubs_o_path_resolved[0]);
  }
  if (hit != 0 as *u8) {
    return hit;
  }
  // Step 2: Cap residual platform resolve of compiler/ then pure join leaf.
  let comp: u8[4096] = [];
  let rc: i32 = 0;
  unsafe {
    rc = shu_resolve_compiler_dir(argv0, &comp[0], 4096);
  }
  if (rc == 0) {
    let dn: i32 = 0;
    while (comp[dn] != 0) {
      dn = dn + 1;
    }
    // leaf "src/asm/bootstrap_nostdlib_stubs.o" is 35 bytes; join needs dn+1+35 < 4096.
    let leaf: *u8 = "src/asm/bootstrap_nostdlib_stubs.o";
    let ln: i32 = 0;
    while (leaf[ln] != 0) {
      ln = ln + 1;
    }
    // mega: snprintf fails when nn >= sizeof(buf); we refuse overflow before write.
    if (dn + 1 + ln < 4096) {
      let i: i32 = 0;
      while (i < dn) {
        g_labi_bootstrap_nostdlib_stubs_o_path_buf[i] = comp[i];
        i = i + 1;
      }
      g_labi_bootstrap_nostdlib_stubs_o_path_buf[dn] = 47;
      let k: i32 = 0;
      while (k <= ln) {
        g_labi_bootstrap_nostdlib_stubs_o_path_buf[dn + 1 + k] = leaf[k];
        k = k + 1;
      }
      unsafe {
        hit = link_abi_realpath_cap(&g_labi_bootstrap_nostdlib_stubs_o_path_buf[0], &g_labi_bootstrap_nostdlib_stubs_o_path_resolved[0]);
      }
      if (hit != 0 as *u8) {
        return hit;
      }
      // mega: return buf even when realpath fails (product may build into that path next).
      return &g_labi_bootstrap_nostdlib_stubs_o_path_buf[0];
    }
  }
  return &g_labi_bootstrap_nostdlib_stubs_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_asm_io_stubs.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_asm_io_stubs_o_path(argv0: *u8): *u8 {
  g_labi_asm_io_stubs_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_asm_io_stubs.o", &g_labi_asm_io_stubs_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_asm_io_stubs_o_path_buf[0] = 0;
  }
  return &g_labi_asm_io_stubs_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_process_argv.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_process_argv_o_path(argv0: *u8): *u8 {
  g_labi_process_argv_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_process_argv.o", &g_labi_process_argv_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_process_argv_o_path_buf[0] = 0;
  }
  return &g_labi_process_argv_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_process_os_glue.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_process_os_glue_o_path(argv0: *u8): *u8 {
  g_labi_process_os_glue_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_process_os_glue.o", &g_labi_process_os_glue_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_process_os_glue_o_path_buf[0] = 0;
  }
  return &g_labi_process_os_glue_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_test_fn_invoke.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_test_fn_invoke_o_path(argv0: *u8): *u8 {
  g_labi_test_fn_invoke_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_test_fn_invoke.o", &g_labi_test_fn_invoke_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_test_fn_invoke_o_path_buf[0] = 0;
  }
  return &g_labi_test_fn_invoke_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_random_fill.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_random_fill_o_path(argv0: *u8): *u8 {
  g_labi_random_fill_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_random_fill.o", &g_labi_random_fill_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_random_fill_o_path_buf[0] = 0;
  }
  return &g_labi_random_fill_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_compress_zlib_glue.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_compress_zlib_glue_o_path(argv0: *u8): *u8 {
  g_labi_compress_zlib_glue_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_compress_zlib_glue.o", &g_labi_compress_zlib_glue_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_compress_zlib_glue_o_path_buf[0] = 0;
  }
  return &g_labi_compress_zlib_glue_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_heap_user.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_heap_user_o_path(argv0: *u8): *u8 {
  g_labi_heap_user_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_heap_user.o", &g_labi_heap_user_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_heap_user_o_path_buf[0] = 0;
  }
  return &g_labi_heap_user_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_time_os.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_time_os_o_path(argv0: *u8): *u8 {
  g_labi_time_os_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_time_os.o", &g_labi_time_os_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_time_os_o_path_buf[0] = 0;
  }
  return &g_labi_time_os_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_queue_contention.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_queue_contention_o_path(argv0: *u8): *u8 {
  g_labi_queue_contention_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_queue_contention.o", &g_labi_queue_contention_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_queue_contention_o_path_buf[0] = 0;
  }
  return &g_labi_queue_contention_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_dynlib_os.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_dynlib_os_o_path(argv0: *u8): *u8 {
  g_labi_dynlib_os_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_dynlib_os.o", &g_labi_dynlib_os_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_dynlib_os_o_path_buf[0] = 0;
  }
  return &g_labi_dynlib_os_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_env_os.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_env_os_o_path(argv0: *u8): *u8 {
  g_labi_env_os_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_env_os.o", &g_labi_env_os_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_env_os_o_path_buf[0] = 0;
  }
  return &g_labi_env_os_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_backtrace_platform.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_backtrace_platform_o_path(argv0: *u8): *u8 {
  g_labi_backtrace_platform_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_backtrace_platform.o", &g_labi_backtrace_platform_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_backtrace_platform_o_path_buf[0] = 0;
  }
  return &g_labi_backtrace_platform_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_log_os.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_log_os_o_path(argv0: *u8): *u8 {
  g_labi_log_os_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_log_os.o", &g_labi_log_os_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_log_os_o_path_buf[0] = 0;
  }
  return &g_labi_log_os_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_math_libm.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_math_libm_o_path(argv0: *u8): *u8 {
  g_labi_math_libm_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_math_libm.o", &g_labi_math_libm_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_math_libm_o_path_buf[0] = 0;
  }
  return &g_labi_math_libm_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_atomic_glue.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_atomic_glue_o_path(argv0: *u8): *u8 {
  g_labi_atomic_glue_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_atomic_glue.o", &g_labi_atomic_glue_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_atomic_glue_o_path_buf[0] = 0;
  }
  return &g_labi_atomic_glue_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_channel_glue.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_channel_glue_o_path(argv0: *u8): *u8 {
  g_labi_channel_glue_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_channel_glue.o", &g_labi_channel_glue_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_channel_glue_o_path_buf[0] = 0;
  }
  return &g_labi_channel_glue_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_net_udp_batch.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_net_udp_batch_o_path(argv0: *u8): *u8 {
  g_labi_net_udp_batch_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_net_udp_batch.o", &g_labi_net_udp_batch_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_net_udp_batch_o_path_buf[0] = 0;
  }
  return &g_labi_net_udp_batch_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_net_workers.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_net_workers_o_path(argv0: *u8): *u8 {
  g_labi_net_workers_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_net_workers.o", &g_labi_net_workers_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_net_workers_o_path_buf[0] = 0;
  }
  return &g_labi_net_workers_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_sync_os.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_sync_os_o_path(argv0: *u8): *u8 {
  g_labi_sync_os_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_sync_os.o", &g_labi_sync_os_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_sync_os_o_path_buf[0] = 0;
  }
  return &g_labi_sync_os_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_sync_lock_diag_tls.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_sync_lock_diag_tls_o_path(argv0: *u8): *u8 {
  g_labi_sync_lock_diag_tls_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_sync_lock_diag_tls.o", &g_labi_sync_lock_diag_tls_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_sync_lock_diag_tls_o_path_buf[0] = 0;
  }
  return &g_labi_sync_lock_diag_tls_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_thread_glue.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_thread_glue_o_path(argv0: *u8): *u8 {
  g_labi_thread_glue_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_thread_glue.o", &g_labi_thread_glue_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_thread_glue_o_path_buf[0] = 0;
  }
  return &g_labi_thread_glue_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_scheduler_glue.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_scheduler_glue_o_path(argv0: *u8): *u8 {
  g_labi_scheduler_glue_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_scheduler_glue.o", &g_labi_scheduler_glue_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_scheduler_glue_o_path_buf[0] = 0;
  }
  return &g_labi_scheduler_glue_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_http_glue.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_http_glue_o_path(argv0: *u8): *u8 {
  g_labi_http_glue_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_http_glue.o", &g_labi_http_glue_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_http_glue_o_path_buf[0] = 0;
  }
  return &g_labi_http_glue_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_tls_mbedtls_bio.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_tls_mbedtls_bio_o_path(argv0: *u8): *u8 {
  g_labi_tls_mbedtls_bio_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_tls_mbedtls_bio.o", &g_labi_tls_mbedtls_bio_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_tls_mbedtls_bio_o_path_buf[0] = 0;
  }
  return &g_labi_tls_mbedtls_bio_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_kv_mmap_glue.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_kv_mmap_glue_o_path(argv0: *u8): *u8 {
  g_labi_kv_mmap_glue_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_kv_mmap_glue.o", &g_labi_kv_mmap_glue_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_kv_mmap_glue_o_path_buf[0] = 0;
  }
  return &g_labi_kv_mmap_glue_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_arrow_simd_glue.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_arrow_simd_glue_o_path(argv0: *u8): *u8 {
  g_labi_arrow_simd_glue_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_arrow_simd_glue.o", &g_labi_arrow_simd_glue_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_arrow_simd_glue_o_path_buf[0] = 0;
  }
  return &g_labi_arrow_simd_glue_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_sqlite_glue.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_sqlite_glue_o_path(argv0: *u8): *u8 {
  g_labi_sqlite_glue_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_sqlite_glue.o", &g_labi_sqlite_glue_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_sqlite_glue_o_path_buf[0] = 0;
  }
  return &g_labi_sqlite_glue_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_crypto_inc_glue.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_crypto_inc_glue_o_path(argv0: *u8): *u8 {
  g_labi_crypto_inc_glue_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_crypto_inc_glue.o", &g_labi_crypto_inc_glue_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_crypto_inc_glue_o_path_buf[0] = 0;
  }
  return &g_labi_crypto_inc_glue_o_path_buf[0];
}

/**
 * Thin durable path for compiler/runtime_ed25519_ref10_glue.o (wave183 pure BSS + compiler_o_path_copy).
 * @param argv0 *u8 — optional product host path; may be null
 * @return *u8 — static BSS path or empty string (never null)
 * Pure orch: Cap residual via pure peer xlang_runtime_compiler_o_path_copy (wave160);
 *   on fail clear BSS[0]. Matches mega static PATH_MAX + compiler_o_path_copy leaf join.
 * Why (wave183): hybrid still had always-mega C body for thin runtime_*_o_path BSS leaves
 *   after wave161 G.7 join convergence (resolve+snprintf already removed).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_runtime_ed25519_ref10_glue_o_path(argv0: *u8): *u8 {
  g_labi_ed25519_ref10_glue_o_path_buf[0] = 0;
  let rc: i32 = xlang_runtime_compiler_o_path_copy(argv0, "runtime_ed25519_ref10_glue.o", &g_labi_ed25519_ref10_glue_o_path_buf[0], 4096);
  if (rc != 0) {
    g_labi_ed25519_ref10_glue_o_path_buf[0] = 0;
  }
  return &g_labi_ed25519_ref10_glue_o_path_buf[0];
}

/**
 * Return a durable empty C string (NUL only). Used by retired std.io / std.compress .o path APIs.
 * @return *u8 — pointer to static 1-byte BSS always holding '\0' (never null)
 * Pure orch: zero g_labi_empty_cstr_buf[0] then return its address (≡ mega static char buf[1]).
 * Why (wave184): hybrid still had always-mega C body for empty_cstr (trivial BSS).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_empty_cstr(): *u8 {
  g_labi_empty_cstr_buf[0] = 0;
  return &g_labi_empty_cstr_buf[0];
}

/**
 * Retired std.io product path: no io.o (std.io is pure .x). Keep API for call sites.
 * @param argv0 *u8 — ignored; optional host path for historical signature parity
 * @return *u8 — empty string via pure xlang_empty_cstr (never null)
 * Pure orch: ignore argv0; return durable empty C string.
 * Why (wave184): hybrid still had always-mega C body (thin empty stub).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_std_io_o_path(argv0: *u8): *u8 {
  // argv0 retained for ABI parity with mega / historical call sites (unused).
  if (argv0 != 0 as *u8) {
    // no-op: deliberately ignore path content
  }
  return xlang_empty_cstr();
}

/**
 * Retired std.compress product path: no compress.o (pure .x + on-demand -lz*). Keep API.
 * @param argv0 *u8 — ignored; optional host path for historical signature parity
 * @return *u8 — empty string via pure xlang_empty_cstr (never null)
 * Pure orch: ignore argv0; return durable empty C string.
 * Why (wave184): hybrid still had always-mega C body (thin empty stub).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_std_compress_o_path(argv0: *u8): *u8 {
  if (argv0 != 0 as *u8) {
    // no-op: deliberately ignore path content
  }
  return xlang_empty_cstr();
}

/**
 * Effective link argv0 for asm ld path resolvers: prefer caller link_argv0; else synthesize
 * "compiler-dir/xlang" into the caller-provided buffer (file need not exist).
 * @param link_argv0 *u8 — caller argv[0] / product host path; may be null or empty
 * @param syn_buf *u8 — caller buffer for synthetic path; required when link_argv0 empty
 * @param syn_sz i64 — capacity of syn_buf in bytes (incl. NUL); 0 → fail
 * @return *u8 — link_argv0 when non-empty; else syn_buf with compiler-dir/xlang; null on fail
 * Pure orch: null/empty gates + Cap residual shu_resolve_compiler_dir(null) + pure byte join
 *   comp_dir + "/xlang" into syn_buf (no snprintf Cap). Matches mega effective_link_argv0.
 * Cap residual: shu_resolve_compiler_dir only (PLATFORM LINUX/MACOS/WINDOWS resolve).
 * Why (wave184): hybrid still had always-mega C body (resolve + snprintf join).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_asm_ld_effective_link_argv0(link_argv0: *u8, syn_buf: *u8, syn_sz: i64): *u8 {
  // Prefer real link argv0 when non-null and non-empty (≡ mega).
  if (link_argv0 != 0 as *u8) {
    if (link_argv0[0] != 0) {
      return link_argv0;
    }
  }
  if (syn_buf == 0 as *u8) {
    return 0 as *u8;
  }
  if (syn_sz == 0) {
    return 0 as *u8;
  }
  syn_buf[0] = 0;
  // Cap residual: resolve compiler/ dir with null argv0 (self/exe / host fallbacks).
  let comp_dir: u8[4096] = [];
  let rc: i32 = 0;
  unsafe {
    rc = shu_resolve_compiler_dir(0 as *u8, &comp_dir[0], 4096);
  }
  if (rc != 0) {
    return 0 as *u8;
  }
  // Pure strlen(comp_dir); leaf is fixed "xlang" (len 4).
  let dn: i32 = 0;
  while (comp_dir[dn] != 0) {
    dn = dn + 1;
  }
  let ln: i32 = 4;
  // snprintf("%s/xlang") writes dn+1+4 chars + NUL; fail if need >= syn_sz (mega size_t).
  let need: i64 = (dn as i64) + 1 + (ln as i64);
  if (need >= syn_sz) {
    syn_buf[0] = 0;
    return 0 as *u8;
  }
  // Byte join: comp_dir[0..dn) + '/' + "xlang" + NUL.
  let i: i32 = 0;
  while (i < dn) {
    syn_buf[i] = comp_dir[i];
    i = i + 1;
  }
  syn_buf[dn] = 47;
  syn_buf[dn + 1] = 115;
  syn_buf[dn + 2] = 104;
  syn_buf[dn + 3] = 117;
  syn_buf[dn + 4] = 120;
  syn_buf[dn + 5] = 0;
  return syn_buf;
}

/**
 * Resolve relative .o path from rel / cwd / argv0 parent (heap return).
 * Ladder (≡ mega): realpath(rel) → getcwd+"/"+rel → argv0-dir+"/../"+rel
 * (realpath then skip_missing on joined buf only for argv0 step).
 * @param argv0 *u8 — optional product host path for parent/../rel; may be null
 * @param rel *u8 — relative path under repo (e.g. "std/string/string.o"); null/empty → heap ""
 * @return *u8 — independent heap string per call (Cap residual strdup); never static BSS
 * Why heap (not BSS): xlang_invoke_cc saves 30+ concurrent pointers; static would alias all to last call
 *   (crypto_o pointing at test.o → UNDEF). Caller does not free; process exit reclaims.
 * Pure orch: pure last-sep index + byte join cwd/rel and argv0/../rel; Cap residual
 *   link_abi_realpath_cap + getcwd + link_abi_cstr_dup + asm_link_obj_skip_missing.
 * Cap residual: realpath_cap (POSIX; Windows null) + getcwd + cstr_dup + skip_missing (stat).
 * Why (wave185): hybrid still had always-mega C body for multi-call heap path resolve after
 *   wave184 empty/effective pure. Soft residual closed; Cap residual stays for heap/IO.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch POSIX '/' — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_rel_o_path_from_argv0(argv0: *u8, rel: *u8): *u8 {
  // Durable empty C string for cstr_dup("") Cap residual (never null arg).
  let empty: *u8 = "";
  if (rel == 0 as *u8) {
    unsafe {
      return link_abi_cstr_dup(empty);
    }
  }
  if (rel[0] == 0) {
    unsafe {
      return link_abi_cstr_dup(empty);
    }
  }
  // Pure strlen(rel); mega uses size_t rel_len.
  let rel_len: i32 = 0;
  while (rel[rel_len] != 0) {
    rel_len = rel_len + 1;
  }
  // Step 1: realpath(rel) → cstr_dup(resolved). Cap residual realpath_cap (≡ mega realpath).
  let resolved: u8[4096] = [];
  let rp: *u8 = 0 as *u8;
  unsafe {
    rp = link_abi_realpath_cap(rel, &resolved[0]);
  }
  if (rp != 0 as *u8) {
    unsafe {
      return link_abi_cstr_dup(rp);
    }
  }
  // Step 2: getcwd + "/" + rel then realpath. mega: getcwd(cwd, sizeof(cwd)-2) with cwd[512].
  let cwd: u8[512] = [];
  let gp: *u8 = 0 as *u8;
  unsafe {
    gp = getcwd(&cwd[0], 510);
  }
  if (gp != 0 as *u8) {
    let L: i32 = 0;
    while (cwd[L] != 0) {
      L = L + 1;
    }
    // mega: L + 1 + rel_len + 1 <= sizeof(cwd)
    if (L + 1 + rel_len + 1 <= 512) {
      cwd[L] = 47;
      let ci: i32 = 0;
      // Copy rel including trailing NUL (mega memcpy rel_len+1).
      while (ci <= rel_len) {
        cwd[L + 1 + ci] = rel[ci];
        ci = ci + 1;
      }
      unsafe {
        rp = link_abi_realpath_cap(&cwd[0], &resolved[0]);
      }
      if (rp != 0 as *u8) {
        unsafe {
          return link_abi_cstr_dup(rp);
        }
      }
    }
  }
  // Step 3: argv0 parent + "/../" + rel.
  if (argv0 != 0 as *u8) {
    if (argv0[0] != 0) {
      let buf: u8[512] = [];
      // Pure last-sep index (POSIX '/'); avoid pointer subtraction (no .x ptrdiff).
      let i: i32 = 0;
      let last_sep_i: i32 = -1;
      while (argv0[i] != 0) {
        if (argv0[i] == 47) {
          last_sep_i = i;
        }
        i = i + 1;
      }
      let n: i32 = 0;
      if (last_sep_i >= 0) {
        // mega: n = last_slash - argv0; refuse if n >= sizeof(buf)-(3+rel_len).
        if (last_sep_i >= 512 - (3 + rel_len)) {
          unsafe {
            return link_abi_cstr_dup(empty);
          }
        }
        let j: i32 = 0;
        while (j < last_sep_i) {
          buf[j] = argv0[j];
          j = j + 1;
        }
        buf[last_sep_i] = 0;
        n = last_sep_i;
      } else {
        // No sep: use "." as dir (≡ mega).
        buf[0] = 46;
        buf[1] = 0;
        n = 1;
      }
      // mega guard: n + 3 + rel_len < sizeof(buf) then strcat "/../" + rel.
      // Note: mega uses 3 in the guard while strcat adds 4-char "/../"; match mega as-is.
      if (n + 3 + rel_len < 512) {
        // Append "/../" (4 bytes) then rel + NUL.
        buf[n] = 47;
        buf[n + 1] = 46;
        buf[n + 2] = 46;
        buf[n + 3] = 47;
        let k: i32 = 0;
        while (k <= rel_len) {
          buf[n + 4 + k] = rel[k];
          k = k + 1;
        }
        unsafe {
          rp = link_abi_realpath_cap(&buf[0], &resolved[0]);
        }
        if (rp != 0 as *u8) {
          unsafe {
            return link_abi_cstr_dup(rp);
          }
        }
        // realpath miss: only return joined path when skip_missing (nonempty regular file).
        let sm: *u8 = 0 as *u8;
        unsafe {
          sm = asm_link_obj_skip_missing(&buf[0]);
        }
        if (sm != 0 as *u8) {
          unsafe {
            return link_abi_cstr_dup(&buf[0]);
          }
        }
        unsafe {
          return link_abi_cstr_dup(empty);
        }
      }
    }
  }
  unsafe {
    return link_abi_cstr_dup(empty);
  }
}

/**
 * Pure audit: number of L0 path-pure public gates in this slice.
 * Returns: 58 (fixed catalog size for hybrid FROM_X bookkeeping; wave185 +1 rel_o_path).
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function labi_path_pure_count(): i32 {
  return 58;
}

/**
 * Pure helper: equality of two NUL-terminated C strings (byte-exact).
 * @param a *u8 — left; null → 0
 * @param b *u8 — right; null → 0
 * @return i32 — 1 equal, 0 not
 * PLATFORM: SHARED — pure strcmp substitute for option name match.
 */
function labi_user_extra_cstr_eq(a: *u8, b: *u8): i32 {
  if (a == 0 as *u8) {
    return 0;
  }
  if (b == 0 as *u8) {
    return 0;
  }
  let i: i32 = 0;
  while (i < 1048576) {
    let ca: u8 = a[i];
    let cb: u8 = b[i];
    if (ca != cb) {
      return 0;
    }
    if (ca == 0) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Pure helper: path ends with ".o" (len>=2, last two bytes '.' 'o').
 * @param a *u8 — path; null/empty → 0
 * @return i32 — 1 if suffix .o
 * PLATFORM: SHARED — pure; ≡ mega len>=2 && a[len-2]=='.' && a[len-1]=='o'
 */
function labi_user_extra_ends_with_dot_o(a: *u8): i32 {
  if (a == 0 as *u8) {
    return 0;
  }
  if (a[0] == 0) {
    return 0;
  }
  let len: i32 = 0;
  while (len < 1048576) {
    if (a[len] == 0) {
      break;
    }
    len = len + 1;
  }
  if (len < 2) {
    return 0;
  }
  if (a[len - 2] != 46) {
    return 0;
  }
  if (a[len - 1] != 111) {
    return 0;
  }
  return 1;
}

/**
 * Parse driver argv for user-specified .o files into the single-authority extra table.
 * Skips options (-o/-L/-I/-target/-backend/-O/-opt and their values), -D*, --*, and
 * non-.o positionals. Resets the table first (Cap residual reset).
 * @param argc i32 — argv count (same as main argc)
 * @param argv **u8 — driver argv (char**); null → reset only
 * @return void — stores up to 32 path pointers (no copy; argv lifetime must cover link)
 * Pure orch: option name pure eq + .o suffix pure scan; Cap residual reset/push.
 * Cap residual: link_abi_user_extra_o_reset / link_abi_user_extra_o_push (globals mega).
 * Why (wave189): hybrid still had always-mega C body for CLI .o table fill (writer side
 *   of wave151 pure append_user_extra). Soft residual sibling of wave151 append.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name for rt_run_asm_backend call sites.
 */
#[no_mangle]
export function xlang_invoke_cc_set_user_o_files_from_argv(argc: i32, argv: **u8): void {
  unsafe {
    link_abi_user_extra_o_reset();
  }
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (argc <= 1) {
    return;
  }
  let i: i32 = 1;
  while (i < argc) {
    let a: *u8 = argv[i];
    if (a == 0 as *u8) {
      i = i + 1;
      continue;
    }
    if (a[0] == 0) {
      i = i + 1;
      continue;
    }
    // Options: leading '-'
    if (a[0] == 45) {
      // Two-token options consume next arg when present.
      let two: i32 = 0;
      if (labi_user_extra_cstr_eq(a, "-o") != 0) {
        two = 1;
      }
      if (labi_user_extra_cstr_eq(a, "-L") != 0) {
        two = 1;
      }
      if (labi_user_extra_cstr_eq(a, "-I") != 0) {
        two = 1;
      }
      if (labi_user_extra_cstr_eq(a, "-target") != 0) {
        two = 1;
      }
      if (labi_user_extra_cstr_eq(a, "-backend") != 0) {
        two = 1;
      }
      if (labi_user_extra_cstr_eq(a, "-O") != 0) {
        two = 1;
      }
      if (labi_user_extra_cstr_eq(a, "-opt") != 0) {
        two = 1;
      }
      if (two != 0) {
        if (i + 1 < argc) {
          i = i + 1;
        }
      }
      i = i + 1;
      continue;
    }
    // Positional ending in ".o"
    if (labi_user_extra_ends_with_dot_o(a) != 0) {
      unsafe {
        let _p: i32 = link_abi_user_extra_o_push(a);
      }
    }
    i = i + 1;
  }
}

/**
 * Clear CLI user-extra .o table after invoke_cc / invoke_ld (prevent stale pointers).
 * @return void
 * Pure orch: Cap residual reset only.
 * Cap residual: link_abi_user_extra_o_reset.
 * Why (wave189): pair with set_from_argv pure orch (writer side of wave151 table).
 * PLATFORM: SHARED — hybrid L0 pure; mega cold twin under #ifndef PATH_PURE_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_invoke_cc_clear_user_o_files(): void {
  unsafe {
    link_abi_user_extra_o_reset();
  }
}
