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

// user_asm_seed_bridge.x — w1518 (终局待办 5.8 second item, first object)
// Whole body of src/asm/user_asm_seed_bridge.o on all three hosts. g05 builds
// it with the product's pure asm; the C seed rest is no longer compiled.
// Exports used by the product link: asm_asm_codegen_ast and
// asm_asm_codegen_elf_o (called through pabi alias / pabi_weak). The helpers
// they need live here too: ctx reset, Mach-O leading underscore, the empty
// text gate, the Mach-O forward and the COFF writer.
// Not carried over (no reference in any of the three product links, w1518
// scan): pipeline_expr_float_val_at / ast_ twin (f64 read) and
// pipeline_seed_asm_emit_call_args_elf_arm64_push_loop / ast_ twin.
// ElfCodegenCtx is read by byte offset. The offsets below match
// struct platform_elf_ElfCodegenCtx in the seed (checked with offsetof).
// Platform choice is compile-time cfg, never a runtime host query.
// PLATFORM: SHARED (macOS arm64, Linux x86_64, Windows x64).

export extern "C" function link_abi_getenv(name: *u8): *u8;
export extern "C" function diag_report(file: *u8, line: i32, col: i32, kind: *u8, msg: *u8, detail: *u8): void;
export extern "C" function driver_diagnostic_asm_print_current_func(): void;
export extern "C" function pipeline_dep_ctx_use_macho_o(ctx: *u8): i32;
export extern "C" function pipeline_dep_ctx_use_coff_o(ctx: *u8): i32;
export extern "C" function pipeline_dep_ctx_asm_entry_module_only(ctx: *u8): i32;
export extern "C" function pipeline_dep_ctx_ndep(ctx: *u8): i32;
export extern "C" function pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8;
export extern "C" function pipeline_dep_ctx_arena_at(ctx: *u8, idx: i32): *u8;
export extern "C" function pipeline_dep_ctx_import_path_copy64(ctx: *u8, idx: i32, dst: *u8): void;
export extern "C" function pipeline_module_num_funcs(m: *u8): i32;
export extern "C" function pipeline_elf_label_mod_scope_reset(): void;
export extern "C" function pipeline_elf_ctx_reloc_sidecar_reset(ctx: *u8): void;
export extern "C" function pipeline_elf_ctx_resolve_patches(ctx: *u8): i32;
export extern "C" function pipeline_elf_ctx_total_code_len(ctx: *u8): i32;
export extern "C" function driver_set_current_dep_path_for_codegen(path: *u8): void;
export extern "C" function driver_asm_work_p_get(i: i32): *u8;
export extern "C" function xlang_entry_lib_name_from_path(input_path: *u8): *u8;
export extern "C" function xlang_pipeline_pctx_set_entry_lib_prefix(ctx: *u8, name: *u8, name_len: i32): void;
export extern "C" function xlang_pipeline_pctx_entry_lib_prefix_into(ctx: *u8, out: *u8, cap: i32): i32;
export extern "C" function driver_skip_codegen_dep_0_get(): i32;
export extern "C" function driver_freestanding_get(): i32;
export extern "C" function pipeline_codegen_dep_skip_asm_user_std_io(path: *u8): i32;
export extern "C" function pipeline_codegen_dep_skip_asm_user_std_fs(path: *u8): i32;
export extern "C" function pipeline_codegen_dep_skip_asm_user_std_process(path: *u8): i32;
export extern "C" function pipeline_codegen_dep_skip_asm_user_std_fmt(path: *u8): i32;
export extern "C" function pipeline_codegen_dep_skip_asm_user_std_misc(path: *u8): i32;
export extern "C" function pipeline_codegen_dep_skip_asm_user_core_lib(path: *u8): i32;
export extern "C" function pipeline_asm_user_dep_is_in_tree_core(path: *u8): i32;
export extern "C" function pipeline_codegen_std_dep_link_only(path: *u8): i32;
export extern "C" function backend_asm_codegen_ast(module: *u8, arena: *u8, out: *u8, ctx: *u8): i32;
export extern "C" function backend_asm_codegen_ast_to_elf(module: *u8, arena: *u8, elf_ctx: *u8, ctx: *u8): i32;
export extern "C" function peephole_run(out: *u8): i32;
export extern "C" function peephole_elf_run(elf_ctx: *u8): i32;
export extern "C" function pipeline_asm_patch_module_parent_links(m: *u8, a: *u8): i32;
export extern "C" function pipeline_asm_wpo_reach_compute_for_elf(m: *u8, a: *u8, ctx: *u8): void;
export extern "C" function pipeline_asm_wpo_reach_clear(): void;
export extern "C" function pipeline_elf_write_o_standard_to_buf_c(ctx: *u8, out: *u8): i32;
export extern "C" function pipeline_elf_ctx_reloc_sym_name_copy64(ctx: *u8, idx: i32, dst: *u8): void;
export extern "C" function pipeline_elf_ctx_reloc_name_len(ctx: *u8, idx: i32): i32;
export extern "C" function pipeline_elf_ctx_reloc_offset_at(ctx: *u8, idx: i32): i32;
export extern "C" function pipeline_elf_ctx_reloc_shndx_at(ctx: *u8, idx: i32): i32;
export extern "C" function pipeline_elf_ctx_reloc_r_type_at(ctx: *u8, idx: i32): i32;
export extern "C" function pipeline_elf_ctx_emit_data_len(ctx: *u8): i32;
export extern "C" function pipeline_elf_ctx_data_data_ptr(ctx: *u8): *u8;
#[cfg(target_os = "macos")]
export extern "C" function platform_macho_write_macho_o_to_buf(elf_ctx: *u8, out: *u8): i32;

/* ElfCodegenCtx byte offsets (seed struct platform_elf_ElfCodegenCtx). */
const UASB_CODE_LEN: i32 = 0;
const UASB_NUM_LABELS: i32 = 17301508;
const UASB_NUM_PATCHES: i32 = 34865160;
const UASB_NUM_RELOCS: i32 = 37093388;
const UASB_SYMS: i32 = 37093392;
const UASB_SYM_SIZE: i32 = 268;
const UASB_SYM_NAME_LEN: i32 = 256;
const UASB_SYM_OFFSET: i32 = 260;
const UASB_SYM_SHNDX: i32 = 264;
const UASB_NUM_SYMS: i32 = 41484304;
const UASB_SYM_NAME_POOL_LEN: i32 = 41484308;
const UASB_E_MACHINE: i32 = 41484312;
const UASB_MACHO_US: i32 = 41484324;
const UASB_CODE_HOT_LEN: i32 = 41484328;
const UASB_EMIT_HOT: i32 = 41484332;
const UASB_CODE_DATA: i32 = 41484336;
const UASB_SYM_NAME_DATA: i32 = 51249200;
/* CodegenOutBuf: data[9437184] then i32 length. */
const UASB_OUT_CAP: i32 = 9437184;

/** Doc anchor (keeps TU non-empty for cold tooling). */
#[no_mangle]
export function user_asm_seed_bridge_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Little-endian i32 read at byte offset.
 * PLATFORM: SHARED
 */
#[no_mangle]
function uasb_rd32(p: *u8, off: i32): i32 {
  let q: *u8 = p + off;
  let b0: i32 = (q[0] as i32) & 255;
  let b1: i32 = (q[1] as i32) & 255;
  let b2: i32 = (q[2] as i32) & 255;
  let b3: i32 = (q[3] as i32) & 255;
  return b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
}

/**
 * Little-endian i32 write at byte offset.
 * PLATFORM: SHARED
 */
function uasb_wr32(p: *u8, off: i32, v: i32): void {
  let q: *u8 = p + off;
  q[0] = (v & 255) as u8;
  q[1] = ((v >> 8) & 255) as u8;
  q[2] = ((v >> 16) & 255) as u8;
  q[3] = ((v >> 24) & 255) as u8;
}

/**
 * Zero n bytes.
 * PLATFORM: SHARED
 */
function uasb_zero(p: *u8, n: i32): void {
  let i: i32 = 0;
  while (i < n) {
    p[i] = 0;
    i = i + 1;
  }
}

/**
 * Copy a NUL-terminated string into buf at `at` (cap bytes total, one kept
 * for the NUL). Returns the new position.
 * PLATFORM: SHARED
 */
function uasb_put_str(buf: *u8, at: i32, cap: i32, s: *u8): i32 {
  let pos: i32 = at;
  if (s == 0 as *u8) {
    return pos;
  }
  let i: i32 = 0;
  while (pos < cap - 1) {
    let c: u8 = s[i];
    if (c == 0) {
      break;
    }
    buf[pos] = c;
    pos = pos + 1;
    i = i + 1;
  }
  buf[pos] = 0;
  return pos;
}

/**
 * Decimal text of v into buf at `at`. Returns the new position.
 * PLATFORM: SHARED
 */
function uasb_put_i32(buf: *u8, at: i32, cap: i32, v: i32): i32 {
  let pos: i32 = at;
  let tmp: u8[12] = [];
  let n: i32 = 0;
  let neg: i32 = 0;
  let x: i64 = v as i64;
  if (x < 0) {
    neg = 1;
    x = 0 - x;
  }
  if (x == 0) {
    tmp[0] = 48;
    n = 1;
  }
  while (x > 0 && n < 12) {
    let d: i64 = x % 10;
    tmp[n] = (48 + (d as i32)) as u8;
    n = n + 1;
    x = x / 10;
  }
  if (neg != 0 && pos < cap - 1) {
    buf[pos] = 45;
    pos = pos + 1;
  }
  while (n > 0 && pos < cap - 1) {
    n = n - 1;
    buf[pos] = tmp[n];
    pos = pos + 1;
  }
  buf[pos] = 0;
  return pos;
}

/**
 * diag note "<a><n1><b><n2>" (debug / trace lines).
 * PLATFORM: SHARED
 */
function uasb_note2(a: *u8, n1: i32, b: *u8, n2: i32): void {
  let msg: u8[256] = [];
  let p: *u8 = &msg[0];
  let at: i32 = uasb_put_str(p, 0, 256, a);
  at = uasb_put_i32(p, at, 256, n1);
  at = uasb_put_str(p, at, 256, b);
  at = uasb_put_i32(p, at, 256, n2);
  unsafe {
    diag_report(0 as *u8, 0, 0, "note", p, 0 as *u8);
  }
}

/**
 * diag note "<a><n1>".
 * PLATFORM: SHARED
 */
function uasb_note1(a: *u8, n1: i32): void {
  let msg: u8[256] = [];
  let p: *u8 = &msg[0];
  let at: i32 = uasb_put_str(p, 0, 256, a);
  at = uasb_put_i32(p, at, 256, n1);
  unsafe {
    diag_report(0 as *u8, 0, 0, "note", p, 0 as *u8);
  }
}

/**
 * Whether XLANG_ASM_DEBUG is set.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function seed_asm_debug_enabled(): i32 {
  unsafe {
    let e: *u8 = link_abi_getenv("XLANG_ASM_DEBUG");
    if (e != 0 as *u8) {
      return 1;
    }
  }
  return 0;
}

/**
 * Whether XLANG_ASM_EMIT_TRACE is set.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function seed_asm_emit_trace_enabled(): i32 {
  unsafe {
    let e: *u8 = link_abi_getenv("XLANG_ASM_EMIT_TRACE");
    if (e != 0 as *u8) {
      return 1;
    }
  }
  return 0;
}

/**
 * ElfCodegenCtx.code_len (first field).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function seed_elf_ctx_code_len(elf_ctx: *u8): i32 {
  if (elf_ctx == 0 as *u8) {
    return 0;
  }
  return uasb_rd32(elf_ctx, UASB_CODE_LEN);
}

/**
 * Darwin -o: call/reloc symbols need a leading `_`.
 * PLATFORM: SHARED (only macOS sets 1)
 */
#[no_mangle]
export function seed_elf_ctx_set_macho_leading_underscore(elf_ctx: *u8, on: i32): void {
  if (elf_ctx == 0 as *u8) {
    return;
  }
  let v: i32 = 0;
  if (on != 0) {
    v = 1;
  }
  uasb_wr32(elf_ctx, UASB_MACHO_US, v);
}

/**
 * Reset the emit counters before a whole-program elf emit.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function platform_elf_elf_ctx_reset(elf_ctx: *u8): void {
  if (elf_ctx == 0 as *u8) {
    return;
  }
  uasb_wr32(elf_ctx, UASB_CODE_LEN, 0);
  uasb_wr32(elf_ctx, UASB_CODE_HOT_LEN, 0);
  uasb_wr32(elf_ctx, UASB_EMIT_HOT, 0);
  uasb_wr32(elf_ctx, UASB_NUM_LABELS, 0);
  uasb_wr32(elf_ctx, UASB_NUM_PATCHES, 0);
  uasb_wr32(elf_ctx, UASB_NUM_RELOCS, 0);
  uasb_wr32(elf_ctx, UASB_NUM_SYMS, 0);
  uasb_wr32(elf_ctx, UASB_SYM_NAME_POOL_LEN, 0);
  uasb_wr32(elf_ctx, UASB_MACHO_US, 0);
  unsafe {
    pipeline_elf_label_mod_scope_reset();
    pipeline_elf_ctx_reloc_sidecar_reset(elf_ctx);
  }
}

/**
 * Forward to the pabi patch resolver.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function platform_elf_elf_resolve_patches(elf_ctx: *u8): i32 {
  unsafe {
    return pipeline_elf_ctx_resolve_patches(elf_ctx);
  }
  return 0 - 1;
}

/** asm/backend module-name forwards of pipeline_module_num_funcs. */
#[no_mangle]
export function asm_pipeline_module_num_funcs(m: *u8): i32 {
  unsafe {
    return pipeline_module_num_funcs(m);
  }
  return 0;
}

/** Same forward, backend name. */
#[no_mangle]
export function backend_pipeline_module_num_funcs(m: *u8): i32 {
  unsafe {
    return pipeline_module_num_funcs(m);
  }
  return 0;
}

/**
 * The user .o must carry non-empty text: a module with functions and zero
 * code returns XLANG_ASM_CODEGEN_ELF_EMPTY_TEXT_RC (-2).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function seed_asm_reject_empty_elf_text(module: *u8, elf_ctx: *u8): i32 {
  if (module == 0 as *u8 || elf_ctx == 0 as *u8) {
    return 0;
  }
  unsafe {
    let nf: i32 = pipeline_module_num_funcs(module);
    if (nf <= 0) {
      return 0;
    }
    let clen: i32 = uasb_rd32(elf_ctx, UASB_CODE_LEN);
    if (clen > 0) {
      return 0;
    }
    let total: i32 = pipeline_elf_ctx_total_code_len(elf_ctx);
    if (total > 0) {
      return 0;
    }
  }
  return 0 - 2;
}

/**
 * Mach-O writer forward (the writer lives in pabi_weak on macOS).
 * PLATFORM: MACOS
 */
#[cfg(target_os = "macos")]
#[no_mangle]
export function seed_platform_macho_write_macho_o_to_buf(elf_ctx: *u8, out_buf: *u8): i32 {
  unsafe {
    return platform_macho_write_macho_o_to_buf(elf_ctx, out_buf);
  }
  return 0 - 1;
}

/**
 * No Mach-O writer off macOS.
 * PLATFORM: LINUX | WINDOWS
 */
#[cfg(not(target_os = "macos"))]
#[no_mangle]
export function seed_platform_macho_write_macho_o_to_buf(elf_ctx: *u8, out_buf: *u8): i32 {
  return 0 - 1;
}

/**
 * Append n bytes to CodegenOutBuf (cap 9 MiB).
 * PLATFORM: SHARED — COFF writer helper
 */
function uasb_out_append(out: *u8, ptr: *u8, n: i32): i32 {
  if (n < 0) {
    return 0 - 1;
  }
  if (n > 0 && ptr == 0 as *u8) {
    return 0 - 1;
  }
  let len: i32 = uasb_rd32(out, UASB_OUT_CAP);
  let i: i32 = 0;
  while (i < n && len < UASB_OUT_CAP) {
    let c: u8 = ptr[i];
    out[len] = c;
    len = len + 1;
    i = i + 1;
  }
  uasb_wr32(out, UASB_OUT_CAP, len);
  if (i < n) {
    return 0 - 1;
  }
  return 0;
}

/**
 * 1 when reloc r patches a .data slot (shndx 4, or r_type 200).
 * PLATFORM: WINDOWS COFF
 */
function uasb_coff_reloc_is_data(ctx: *u8, r: i32, has_data: i32): i32 {
  if (has_data == 0) {
    return 0;
  }
  unsafe {
    if (pipeline_elf_ctx_reloc_shndx_at(ctx, r) == 4) {
      return 1;
    }
    if (pipeline_elf_ctx_reloc_r_type_at(ctx, r) == 200) {
      return 1;
    }
  }
  return 0;
}

/** syms[i] field address. */
function uasb_sym_at(ctx: *u8, i: i32): *u8 {
  return ctx + UASB_SYMS + i * UASB_SYM_SIZE;
}

/**
 * Name bytes of sym idx in sym_name_data (names are packed in order).
 * Returns null when out of range.
 * PLATFORM: SHARED
 */
function uasb_sym_name_ptr(ctx: *u8, idx: i32): *u8 {
  if (idx < 0) {
    return 0 as *u8;
  }
  let nsyms: i32 = uasb_rd32(ctx, UASB_NUM_SYMS);
  let off: i32 = 0;
  let i: i32 = 0;
  while (i < idx && i < nsyms) {
    off = off + uasb_rd32(uasb_sym_at(ctx, i), UASB_SYM_NAME_LEN);
    i = i + 1;
  }
  if (off < 0 || off >= 131072) {
    return 0 as *u8;
  }
  return ctx + UASB_SYM_NAME_DATA + off;
}

/**
 * 1 when the first n bytes of a and b match.
 * PLATFORM: SHARED
 */
function uasb_bytes_eq(a: *u8, b: *u8, n: i32): i32 {
  let i: i32 = 0;
  while (i < n) {
    let ca: u8 = a[i];
    let cb: u8 = b[i];
    if (ca != cb) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * sym index whose name equals name[0..len], or -1.
 * PLATFORM: SHARED
 */
function uasb_find_sym(ctx: *u8, num_syms: i32, name: *u8, len: i32): i32 {
  let m: i32 = 0;
  while (m < num_syms) {
    let nm: *u8 = uasb_sym_name_ptr(ctx, m);
    let nl: i32 = uasb_rd32(uasb_sym_at(ctx, m), UASB_SYM_NAME_LEN);
    if (nm != 0 as *u8 && nl == len && len > 0) {
      if (uasb_bytes_eq(name, nm, len) != 0) {
        return m;
      }
    }
    m = m + 1;
  }
  return 0 - 1;
}

/**
 * COFF is AMD64 only. Windows keeps a drifted e_machine field; emit already
 * filled code_len there, so a non-empty text is accepted.
 * PLATFORM: WINDOWS
 */
#[cfg(target_os = "windows")]
function uasb_coff_machine_ok(ctx: *u8): i32 {
  let em: i32 = uasb_rd32(ctx, UASB_E_MACHINE);
  if (em != 62) {
    let cl: i32 = uasb_rd32(ctx, UASB_CODE_LEN);
    if (cl <= 0) {
      return 0;
    }
  }
  return 1;
}

/**
 * Cross-emit hosts need e_machine EM_X86_64 (62).
 * PLATFORM: MACOS | LINUX
 */
#[cfg(not(target_os = "windows"))]
function uasb_coff_machine_ok(ctx: *u8): i32 {
  let em: i32 = uasb_rd32(ctx, UASB_E_MACHINE);
  if (em != 62) {
    return 0;
  }
  return 1;
}

/**
 * Product COFF .obj writer. Twin of platform/coff.x::write_coff_o_to_buf:
 * .text, optional .data (ELF shndx 4), .text then .data reloc tables,
 * .text section symbol + aux, one symbol per ctx sym, string table.
 * Reloc names missing from syms become EXTERNAL UNDEF first.
 * Returns out length, or -1.
 * PLATFORM: SHARED — cross-emit from any host
 */
#[no_mangle]
export function seed_platform_coff_write_coff_o_to_buf(elf_ctx: *u8, out_buf: *u8): i32 {
  if (elf_ctx == 0 as *u8 || out_buf == 0 as *u8) {
    return 0 - 1;
  }
  let ctx: *u8 = elf_ctx;
  let out: *u8 = out_buf;
  if (uasb_coff_machine_ok(ctx) == 0) {
    return 0 - 1;
  }
  let code_len: i32 = uasb_rd32(ctx, UASB_CODE_LEN);
  if (code_len < 0) {
    return 0 - 1;
  }
  let align4: i32 = (code_len + 3) & (0 - 4);
  let num_relocs: i32 = uasb_rd32(ctx, UASB_NUM_RELOCS);
  let num_syms: i32 = uasb_rd32(ctx, UASB_NUM_SYMS);
  if (num_relocs < 0 || num_syms < 0) {
    return 0 - 1;
  }
  let r_sym_buf: u8[256] = [];
  let rb: *u8 = &r_sym_buf[0];
  let r: i32 = 0;
  let s: i32 = 0;
  unsafe {
    while (r < num_relocs) {
      uasb_zero(rb, 256);
      pipeline_elf_ctx_reloc_sym_name_copy64(ctx, r, rb);
      let rlen: i32 = pipeline_elf_ctx_reloc_name_len(ctx, r);
      if (rlen > 0 && rlen <= 256) {
        let hit: i32 = uasb_find_sym(ctx, num_syms, rb, rlen);
        if (hit < 0 && num_syms < 16384) {
          let snl: i32 = uasb_rd32(ctx, UASB_SYM_NAME_POOL_LEN);
          if (snl < 0) {
            snl = 0;
          }
          if (snl + rlen <= 131072) {
            let pool: *u8 = ctx + UASB_SYM_NAME_DATA + snl;
            let k: i32 = 0;
            while (k < rlen) {
              let c: u8 = rb[k];
              pool[k] = c;
              k = k + 1;
            }
            uasb_wr32(ctx, UASB_SYM_NAME_POOL_LEN, snl + rlen);
            let ns: *u8 = uasb_sym_at(ctx, num_syms);
            uasb_wr32(ns, UASB_SYM_NAME_LEN, rlen);
            uasb_wr32(ns, UASB_SYM_OFFSET, 0);
            uasb_wr32(ns, UASB_SYM_SHNDX, 0);
            num_syms = num_syms + 1;
            uasb_wr32(ctx, UASB_NUM_SYMS, num_syms);
          }
        }
      }
      r = r + 1;
    }
    let data_len: i32 = pipeline_elf_ctx_emit_data_len(ctx);
    if (data_len < 0) {
      data_len = 0;
    }
    if (data_len > 65536) {
      data_len = 65536;
    }
    let data_ptr: *u8 = pipeline_elf_ctx_data_data_ptr(ctx);
    if (data_len > 0 && data_ptr == 0 as *u8) {
      return 0 - 1;
    }
    let has_data: i32 = 0;
    if (data_len > 0) {
      has_data = 1;
    }
    if (has_data == 0) {
      s = 0;
      while (s < num_syms) {
        let sx: i32 = uasb_rd32(uasb_sym_at(ctx, s), UASB_SYM_SHNDX);
        if (sx == 4) {
          has_data = 1;
          break;
        }
        s = s + 1;
      }
    }
    let align_data: i32 = 0;
    let nsec: i32 = 1;
    if (has_data != 0) {
      align_data = (data_len + 3) & (0 - 4);
      nsec = 2;
    }
    let n_text_rel: i32 = 0;
    let n_data_rel: i32 = 0;
    r = 0;
    while (r < num_relocs) {
      if (uasb_coff_reloc_is_data(ctx, r, has_data) != 0) {
        n_data_rel = n_data_rel + 1;
      } else {
        n_text_rel = n_text_rel + 1;
      }
      r = r + 1;
    }
    let reloc_size: i32 = num_relocs * 10;
    let num_coff_syms: i32 = 2 + num_syms;
    let strtab_used: i32 = 4;
    s = 0;
    while (s < num_syms) {
      strtab_used = strtab_used + uasb_rd32(uasb_sym_at(ctx, s), UASB_SYM_NAME_LEN) + 1;
      s = s + 1;
    }
    let ptr_raw: i32 = 20 + 40 * nsec;
    let ptr_data: i32 = ptr_raw + align4;
    let ptr_reloc: i32 = ptr_raw + align4;
    if (has_data != 0) {
      ptr_reloc = ptr_data + align_data;
    }
    let ptr_reloc_data: i32 = ptr_reloc + n_text_rel * 10;
    let ptr_sym: i32 = ptr_reloc + reloc_size;

    uasb_wr32(out, UASB_OUT_CAP, 0);

    let hdr: u8[40] = [];
    let hp: *u8 = &hdr[0];
    /* File header: machine 0x8664, NumberOfSections, PointerToSymbolTable,
     * NumberOfSymbols. */
    uasb_zero(hp, 40);
    hp[0] = 100;
    hp[1] = 134;
    hp[2] = (nsec & 255) as u8;
    uasb_wr32(hp, 8, ptr_sym);
    uasb_wr32(hp, 12, num_coff_syms);
    if (uasb_out_append(out, hp, 20) != 0) {
      return 0 - 1;
    }

    /* .text: CNT_CODE | ALIGN_16BYTES | MEM_EXECUTE | MEM_READ = 0x60500020. */
    uasb_zero(hp, 40);
    hp[0] = 46;
    hp[1] = 116;
    hp[2] = 101;
    hp[3] = 120;
    hp[4] = 116;
    uasb_wr32(hp, 16, align4);
    uasb_wr32(hp, 20, ptr_raw);
    uasb_wr32(hp, 24, ptr_reloc);
    hp[32] = (n_text_rel & 255) as u8;
    hp[33] = ((n_text_rel >> 8) & 255) as u8;
    hp[36] = 32;
    hp[38] = 80;
    hp[39] = 96;
    if (uasb_out_append(out, hp, 40) != 0) {
      return 0 - 1;
    }

    /* .data: CNT_INITIALIZED_DATA | ALIGN_4BYTES | MEM_READ | MEM_WRITE
     * = 0xC0300040 (writable: module arrays are assigned). */
    if (has_data != 0) {
      uasb_zero(hp, 40);
      hp[0] = 46;
      hp[1] = 100;
      hp[2] = 97;
      hp[3] = 116;
      hp[4] = 97;
      uasb_wr32(hp, 8, data_len);
      uasb_wr32(hp, 16, align_data);
      uasb_wr32(hp, 20, ptr_data);
      if (n_data_rel > 0) {
        uasb_wr32(hp, 24, ptr_reloc_data);
        hp[32] = (n_data_rel & 255) as u8;
        hp[33] = ((n_data_rel >> 8) & 255) as u8;
      }
      hp[36] = 64;
      hp[38] = 48;
      hp[39] = 192;
      if (uasb_out_append(out, hp, 40) != 0) {
        return 0 - 1;
      }
    }

    let zero: u8[4] = [];
    let zp: *u8 = &zero[0];
    uasb_zero(zp, 4);
    if (code_len > 0) {
      if (uasb_out_append(out, ctx + UASB_CODE_DATA, code_len) != 0) {
        return 0 - 1;
      }
    }
    s = 0;
    while (s < align4 - code_len) {
      if (uasb_out_append(out, zp, 1) != 0) {
        return 0 - 1;
      }
      s = s + 1;
    }
    if (has_data != 0) {
      if (data_len > 0) {
        if (uasb_out_append(out, data_ptr, data_len) != 0) {
          return 0 - 1;
        }
      }
      s = 0;
      while (s < align_data - data_len) {
        if (uasb_out_append(out, zp, 1) != 0) {
          return 0 - 1;
        }
        s = s + 1;
      }
    }

    /* Pass 0 writes the .text table, pass 1 the .data table.
     * IMAGE_REL_AMD64_ADDR64 = 1 for a .data slot or r_type 200,
     * IMAGE_REL_AMD64_REL32 = 4 otherwise. */
    let pass: i32 = 0;
    while (pass < 2) {
      r = 0;
      while (r < num_relocs) {
        let is_data_rel: i32 = uasb_coff_reloc_is_data(ctx, r, has_data);
        if (is_data_rel == pass) {
          uasb_zero(rb, 256);
          pipeline_elf_ctx_reloc_sym_name_copy64(ctx, r, rb);
          let rlen2: i32 = pipeline_elf_ctx_reloc_name_len(ctx, r);
          let sym_idx: i32 = 0;
          let hit2: i32 = uasb_find_sym(ctx, num_syms, rb, rlen2);
          if (hit2 >= 0) {
            sym_idx = 2 + hit2;
          }
          let roff: i32 = pipeline_elf_ctx_reloc_offset_at(ctx, r);
          uasb_zero(hp, 40);
          uasb_wr32(hp, 0, roff);
          uasb_wr32(hp, 4, sym_idx);
          hp[8] = 4;
          if (is_data_rel != 0) {
            hp[8] = 1;
          } else {
            let rt: i32 = pipeline_elf_ctx_reloc_r_type_at(ctx, r);
            if (rt == 200) {
              hp[8] = 1;
            }
          }
          if (uasb_out_append(out, hp, 10) != 0) {
            return 0 - 1;
          }
        }
        r = r + 1;
      }
      pass = pass + 1;
    }

    /* IMAGE_SYMBOL (18B): Name[8] | Value[4] | SectionNumber[2] | Type[2] |
     * StorageClass[1] | NumberOfAuxSymbols[1]. ".text" STATIC + one aux. */
    uasb_zero(hp, 40);
    hp[0] = 46;
    hp[1] = 116;
    hp[2] = 101;
    hp[3] = 120;
    hp[4] = 116;
    hp[12] = 1;
    hp[16] = 3;
    hp[17] = 1;
    if (uasb_out_append(out, hp, 18) != 0) {
      return 0 - 1;
    }
    uasb_zero(hp, 40);
    uasb_wr32(hp, 0, align4);
    hp[4] = (n_text_rel & 255) as u8;
    hp[5] = ((n_text_rel >> 8) & 255) as u8;
    hp[14] = 1;
    if (uasb_out_append(out, hp, 18) != 0) {
      return 0 - 1;
    }

    /* Long names via string table. COMMON (0xfff2): section 0, Value = size.
     * shndx 0: EXTERNAL UNDEF function. shndx 4 with .data: section 2.
     * Else .text function. All EXTERNAL. */
    let str_off: i32 = 4;
    s = 0;
    while (s < num_syms) {
      let se: *u8 = uasb_sym_at(ctx, s);
      let shx: i32 = uasb_rd32(se, UASB_SYM_SHNDX);
      let soff: i32 = uasb_rd32(se, UASB_SYM_OFFSET);
      let snlen: i32 = uasb_rd32(se, UASB_SYM_NAME_LEN);
      uasb_zero(hp, 40);
      uasb_wr32(hp, 4, str_off);
      uasb_wr32(hp, 8, soff);
      hp[16] = 2;
      if (shx == 65522) {
        hp[12] = 0;
      } else if (shx == 0) {
        hp[12] = 0;
        hp[14] = 32;
      } else if (has_data != 0 && shx == 4) {
        hp[12] = 2;
      } else {
        hp[12] = 1;
        hp[14] = 32;
      }
      if (uasb_out_append(out, hp, 18) != 0) {
        return 0 - 1;
      }
      str_off = str_off + snlen + 1;
      s = s + 1;
    }

    uasb_zero(hp, 40);
    uasb_wr32(hp, 0, strtab_used);
    if (uasb_out_append(out, hp, 4) != 0) {
      return 0 - 1;
    }
    s = 0;
    while (s < num_syms) {
      let nl2: i32 = uasb_rd32(uasb_sym_at(ctx, s), UASB_SYM_NAME_LEN);
      let nm2: *u8 = uasb_sym_name_ptr(ctx, s);
      if (nl2 > 0 && nm2 != 0 as *u8) {
        if (uasb_out_append(out, nm2, nl2) != 0) {
          return 0 - 1;
        }
      }
      if (uasb_out_append(out, zp, 1) != 0) {
        return 0 - 1;
      }
      s = s + 1;
    }
  }
  return uasb_rd32(out, UASB_OUT_CAP);
}

/**
 * asm text codegen for the pipeline: backend GAS, then peephole.
 * Either step failing returns -1.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function asm_asm_codegen_ast(module: *u8, arena: *u8, out_buf: *u8, ctx: *u8): i32 {
  unsafe {
    if (backend_asm_codegen_ast(module, arena, out_buf, ctx) != 0) {
      return 0 - 1;
    }
    if (peephole_run(out_buf) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * 1 when the hosted build takes dep from a prebuilt .o (skip co-emit).
 * freestanding links no std .o, so nothing is skipped there.
 * PLATFORM: SHARED
 */
function uasb_dep_skip(path: *u8): i32 {
  unsafe {
    if (driver_freestanding_get() != 0) {
      return 0;
    }
    if (pipeline_codegen_dep_skip_asm_user_std_io(path) != 0) {
      return 1;
    }
    if (pipeline_codegen_dep_skip_asm_user_std_fs(path) != 0) {
      return 1;
    }
    if (pipeline_codegen_dep_skip_asm_user_std_process(path) != 0) {
      return 1;
    }
    if (pipeline_codegen_dep_skip_asm_user_std_fmt(path) != 0) {
      return 1;
    }
    if (pipeline_codegen_dep_skip_asm_user_std_misc(path) != 0) {
      return 1;
    }
    if (pipeline_codegen_dep_skip_asm_user_core_lib(path) != 0) {
      return 1;
    }
    /* in-tree core.* uses the formal .o; hosted std link_only table too. */
    if (pipeline_asm_user_dep_is_in_tree_core(path) != 0) {
      return 1;
    }
    if (pipeline_codegen_std_dep_link_only(path) != 0) {
      return 1;
    }
  }
  return 0;
}

/**
 * Co-emit every dep (skipping dep0 when asked, the entry module itself,
 * duplicates and prebuilt std) into elf_ctx. Returns 0, or -1 on a
 * backend failure (dep path already cleared).
 * PLATFORM: SHARED
 */
function uasb_emit_deps(module: *u8, elf_ctx: *u8, pctx: *u8): i32 {
  let path_buf: u8[256] = [];
  let pb: *u8 = &path_buf[0];
  unsafe {
    if (pctx == 0 as *u8) {
      return 0;
    }
    if (pipeline_dep_ctx_asm_entry_module_only(pctx) != 0) {
      return 0;
    }
    let ndep: i32 = pipeline_dep_ctx_ndep(pctx);
    let j: i32 = 0;
    while (j < ndep) {
      let skip: i32 = 0;
      if (j == 0) {
        if (driver_skip_codegen_dep_0_get() != 0) {
          skip = 1;
        }
      }
      let dep_mod: *u8 = pipeline_dep_ctx_module_at(pctx, j);
      if (skip == 0 && dep_mod == module) {
        skip = 1;
      }
      if (skip == 0) {
        let k: i32 = 0;
        while (k < j) {
          let other: *u8 = pipeline_dep_ctx_module_at(pctx, k);
          if (other == dep_mod) {
            skip = 1;
            break;
          }
          k = k + 1;
        }
      }
      if (skip == 0) {
        uasb_zero(pb, 256);
        pipeline_dep_ctx_import_path_copy64(pctx, j, pb);
        if (seed_asm_emit_trace_enabled() != 0) {
          let nfd: i32 = 0 - 1;
          if (dep_mod != 0 as *u8) {
            nfd = pipeline_module_num_funcs(dep_mod);
          }
          let msg: u8[512] = [];
          let mp: *u8 = &msg[0];
          let at: i32 = uasb_put_str(mp, 0, 512, "asm emit trace: co-emit dep[");
          at = uasb_put_i32(mp, at, 512, j);
          at = uasb_put_str(mp, at, 512, "] path=");
          at = uasb_put_str(mp, at, 512, pb);
          at = uasb_put_str(mp, at, 512, " funcs=");
          at = uasb_put_i32(mp, at, 512, nfd);
          diag_report(0 as *u8, 0, 0, "note", mp, 0 as *u8);
        }
        if (uasb_dep_skip(pb) != 0) {
          skip = 1;
        }
      }
      if (skip == 0) {
        driver_set_current_dep_path_for_codegen(pb);
        let dep_ar: *u8 = pipeline_dep_ctx_arena_at(pctx, j);
        if (dep_mod != 0 as *u8 && dep_ar != 0 as *u8) {
          if (pipeline_module_num_funcs(dep_mod) > 0) {
            if (backend_asm_codegen_ast_to_elf(dep_mod, dep_ar, elf_ctx, pctx) != 0) {
              driver_set_current_dep_path_for_codegen(0 as *u8);
              return 0 - 1;
            }
          }
        }
        driver_set_current_dep_path_for_codegen(0 as *u8);
      }
      j = j + 1;
    }
  }
  return 0;
}

/**
 * Write -o .o / exe: deps first, then the entry module, then peephole,
 * patch resolve and the COFF / Mach-O / ELF writer. Every exit clears the
 * WPO reach set. Returns 0 or -1.
 * After deps, if the entry prefix mirror is still empty, seed it from
 * xlang_entry_lib_name_from_path of work-slot 0 (the input path). Slot 0
 * is ap_path(); this file does not call ap_path, because a later rebuild
 * of rt_run_asm_backend.x would rename that helper. The dep path stays
 * null for the whole entry emit so definitions and same-module calls
 * share one prefix. A prefix already stored (-lib-name) is left as-is.
 * @param module *u8 — entry Module *; required by the backend
 * @param arena *u8 — AST arena for the entry module
 * @param ctx *u8 — PipelineDepCtx *; null skips the prefix seed
 * @param elf_ctx *u8 — ElfCodegenCtx *; null skips writers that need it
 * @param out_buf *u8 — object output buffer
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: SHARED
 */
#[no_mangle]
export function asm_asm_codegen_elf_o(module: *u8, arena: *u8, ctx: *u8, elf_ctx: *u8, out_buf: *u8): i32 {
  unsafe {
    if (elf_ctx != 0 as *u8) {
      platform_elf_elf_ctx_reset(elf_ctx);
      if (ctx != 0 as *u8) {
        if (pipeline_dep_ctx_use_macho_o(ctx) != 0) {
          seed_elf_ctx_set_macho_leading_underscore(elf_ctx, 1);
        }
      }
    }
    pipeline_asm_wpo_reach_compute_for_elf(module, arena, ctx);
    if (uasb_emit_deps(module, elf_ctx, ctx) != 0) {
      pipeline_asm_wpo_reach_clear();
      return 0 - 1;
    }
    driver_set_current_dep_path_for_codegen(0 as *u8);
    // PLATFORM: SHARED — mirror the C parsed driver. A null or empty
    // work-slot path is a no-op: xlang_entry_lib_name_from_path would
    // otherwise return the static "typeck" literal. Copy the lib name
    // immediately; the stem buffer is one shared cell.
    if (ctx != 0 as *u8) {
      let have_buf: u8[128] = [];
      let have_n: i32 = xlang_pipeline_pctx_entry_lib_prefix_into(ctx, &have_buf[0], 128);
      if (have_n <= 0) {
        let ipath: *u8 = driver_asm_work_p_get(0);
        if (ipath != 0 as *u8) {
          if (ipath[0] != 0) {
            let lib: *u8 = xlang_entry_lib_name_from_path(ipath);
            if (lib != 0 as *u8) {
              let ln: i32 = 0;
              while (ln < 62) {
                if (lib[ln] == 0) {
                  break;
                }
                ln = ln + 1;
              }
              if (ln > 0) {
                if (lib[ln] == 0) {
                  xlang_pipeline_pctx_set_entry_lib_prefix(ctx, lib, ln);
                }
              }
            }
          }
        }
      }
    }
    if (seed_asm_emit_trace_enabled() != 0) {
      uasb_note1("asm emit trace: asm_codegen_ast_to_elf entry module funcs=",
                 pipeline_module_num_funcs(module));
    }
    pipeline_asm_patch_module_parent_links(module, arena);
    if (backend_asm_codegen_ast_to_elf(module, arena, elf_ctx, ctx) != 0) {
      if (seed_asm_debug_enabled() != 0) {
        diag_report(0 as *u8, 0, 0, "note", "asm debug: asm_codegen_elf_o fail at backend entry", 0 as *u8);
        driver_diagnostic_asm_print_current_func();
      }
      pipeline_asm_wpo_reach_clear();
      return 0 - 1;
    }
    if (seed_asm_reject_empty_elf_text(module, elf_ctx) != 0) {
      pipeline_asm_wpo_reach_clear();
      return 0 - 1;
    }
    if (elf_ctx != 0 as *u8) {
      if (peephole_elf_run(elf_ctx) != 0) {
        if (seed_asm_debug_enabled() != 0) {
          diag_report(0 as *u8, 0, 0, "note", "asm debug: asm_codegen_elf_o fail at peephole_elf", 0 as *u8);
        }
        pipeline_asm_wpo_reach_clear();
        return 0 - 1;
      }
      if (platform_elf_elf_resolve_patches(elf_ctx) != 0) {
        if (seed_asm_debug_enabled() != 0) {
          diag_report(0 as *u8, 0, 0, "note", "asm debug: asm_codegen_elf_o fail at resolve_patches", 0 as *u8);
        }
        pipeline_asm_wpo_reach_clear();
        return 0 - 1;
      }
    }
    let use_coff: i32 = 0;
    let use_macho: i32 = 0;
    if (ctx != 0 as *u8) {
      use_coff = pipeline_dep_ctx_use_coff_o(ctx);
      if (use_coff == 0) {
        use_macho = pipeline_dep_ctx_use_macho_o(ctx);
      }
    }
    let w: i32 = 0;
    if (use_coff != 0) {
      w = seed_platform_coff_write_coff_o_to_buf(elf_ctx, out_buf);
      if (seed_asm_debug_enabled() != 0) {
        uasb_note2("asm debug: asm_codegen_elf_o coff_write=", w, " out_len=", uasb_rd32(out_buf, UASB_OUT_CAP));
      }
    } else if (use_macho != 0) {
      w = seed_platform_macho_write_macho_o_to_buf(elf_ctx, out_buf);
      if (seed_asm_debug_enabled() != 0) {
        uasb_note2("asm debug: asm_codegen_elf_o macho_write=", w, " out_len=", uasb_rd32(out_buf, UASB_OUT_CAP));
      }
    } else {
      w = pipeline_elf_write_o_standard_to_buf_c(elf_ctx, out_buf);
      if (seed_asm_debug_enabled() != 0) {
        uasb_note2("asm debug: asm_codegen_elf_o elf_write=", w, " out_len=", uasb_rd32(out_buf, UASB_OUT_CAP));
      }
    }
    pipeline_asm_wpo_reach_clear();
    if (w < 0) {
      return 0 - 1;
    }
  }
  return 0;
}
