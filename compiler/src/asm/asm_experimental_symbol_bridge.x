// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// asm_experimental_symbol_bridge: link-name bridge for asm-only links.
// build_asm bare names (entry, parse_into_buf, ...) versus runtime
// prefixed names (main_entry, parser_parse_into_buf, asm_asm_codegen_ast).
// w1520 (5.8c): the whole object is built from this file by product pure
// asm on Darwin (the only product host that links it, via g05 USER_ASM_LINK);
// seeds/asm_experimental_symbol_bridge.from_x.c is no longer compiled by
// host cc on the product path (the seed stays only for build_xlang_asm.sh /
// relink_xlang_asm_experimental_bootstrap.sh until 5.11).
// Strong: get_module_import_path. Every other export is weak (named by g05
// via G05_X_O_WEAK_FUNCS) so a real provider always wins; calls between
// weak names in this TU go through symbol relocations, never a local bind.
// Deleted classes stay deleted (see seed comments): no weak -1 stubs for
// asm_codegen_elf_o / asm_asm_codegen_elf_o / asm_codegen_ast /
// parser_parse_into_buf / typeck_x_ast / typeck_x_ast_library /
// codegen_x_ast (first-weak-wins would cover the real body).
// parser_ParseIntoResult { i32 ok; i32 main_idx } is 8 bytes and returns in
// x0 on arm64; it is carried here as i64 (low half ok, high half main_idx).
// PLATFORM: MACOS arm64 (product); the file itself is target-neutral.

export extern "C" function run_compiler_c(argc: i32, argv: *u8): i32;
export extern "C" function driver_run_compiler_full(argc: i32, argv: *u8): i32;
export extern "C" function driver_argv_drop_subcommand(argc: i32, argv: *u8): *u8;
export extern "C" function driver_cmd_fmt(argc: i32, argv: *u8): i32;
export extern "C" function driver_cmd_check(argc: i32, argv: *u8): i32;
export extern "C" function driver_cmd_test(argc: i32, argv: *u8): i32;
export extern "C" function driver_cmd_run(argc: i32, argv: *u8): i32;
export extern "C" function asm_codegen_ast(module: *u8, arena: *u8, out_buf: *u8, ctx: *u8): i32;
export extern "C" function typeck_x_ast(module: *u8, arena: *u8, ctx: *u8): i32;
export extern "C" function typeck_x_ast_library(module: *u8, arena: *u8, ctx: *u8): i32;
export extern "C" function memcpy(dst: *u8, src: *u8, n: i64): *u8;
// entry is defined in asm_experimental_symbol_bridge_entry.x: a TU that
// defines `entry` is compiled in entry-module mode (only entry is emitted),
// so the weak entry lives alone there and g05 merges both with ld -r.
export extern "C" function entry(argc: i32, argv: *u8): i32;

/** Weak typeck_lsp_main: B-strict link without lsp_x.o. PLATFORM: SHARED */
#[no_mangle]
export function typeck_lsp_main(): i32 {
  return -1;
}

/** Weak run_compiler_x_path_impl: forwards to driver_run_compiler_full. PLATFORM: SHARED */
#[no_mangle]
export function run_compiler_x_path_impl(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_compiler_full(argc, argv);
  }
}

/** Weak main_run_compiler_x_path_impl: forwards to driver_run_compiler_full. PLATFORM: SHARED */
#[no_mangle]
export function main_run_compiler_x_path_impl(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_compiler_full(argc, argv);
  }
}

/** Weak main_cmd_build: no driver_x.o means build fails (-1). PLATFORM: SHARED */
#[no_mangle]
export function main_cmd_build(argc: i32, argv: *u8): i32 {
  return -1;
}

/**
 * Read argv[i] (char** slot i) without pointer-to-pointer syntax.
 * PLATFORM: SHARED
 */
#[no_mangle]
function aesb_argv_at(argv: *u8, i: i32): *u8 {
  let tmp: *u8 = 0 as *u8;
  let src: *u8 = argv + i * 8;
  unsafe {
    memcpy(&tmp as *u8, src, 8);
  }
  return tmp;
}

/**
 * NUL-terminated s equals the 3..5 byte word c0..c4 (unused tail = 0).
 * PLATFORM: SHARED
 */
#[no_mangle]
function aesb_word_eq(s: *u8, n: i32, c0: i32, c1: i32, c2: i32, c3: i32, c4: i32): i32 {
  if (((s[0] as i32) & 255) != c0) { return 0; }
  if (((s[1] as i32) & 255) != c1) { return 0; }
  if (((s[2] as i32) & 255) != c2) { return 0; }
  if (n == 3) {
    if (((s[3] as i32) & 255) != 0) { return 0; }
    return 1;
  }
  if (((s[3] as i32) & 255) != c3) { return 0; }
  if (n == 4) {
    if (((s[4] as i32) & 255) != 0) { return 0; }
    return 1;
  }
  if (((s[4] as i32) & 255) != c4) { return 0; }
  if (((s[5] as i32) & 255) != 0) { return 0; }
  return 1;
}

/**
 * Weak main_entry: route check/fmt/test/build/run to driver_*; else entry.
 * Same semantics as main.x entry (argc-1 + driver_argv_drop_subcommand).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function main_entry(argc: i32, argv: *u8): i32 {
  if (argc >= 2) {
    let a1: *u8 = aesb_argv_at(argv, 1);
    if (a1 != 0 as *u8) {
      if (((a1[0] as i32) & 255) != 45) {
        unsafe {
          let adj: *u8 = driver_argv_drop_subcommand(argc, argv);
          if (aesb_word_eq(a1, 3, 102, 109, 116, 0, 0) != 0) {
            return driver_cmd_fmt(argc - 1, adj);
          }
          if (aesb_word_eq(a1, 5, 99, 104, 101, 99, 107) != 0) {
            return driver_cmd_check(argc - 1, adj);
          }
          if (aesb_word_eq(a1, 4, 116, 101, 115, 116, 0) != 0) {
            return driver_cmd_test(argc - 1, adj);
          }
          if (aesb_word_eq(a1, 5, 98, 117, 105, 108, 100) != 0) {
            return main_cmd_build(argc - 1, adj);
          }
          if (aesb_word_eq(a1, 3, 114, 117, 110, 0, 0) != 0) {
            return driver_cmd_run(argc - 1, adj);
          }
        }
      }
    }
  }
  unsafe {
    return entry(argc, argv);
  }
}

/** Weak main_run_compiler_c: forwards to driver_run_compiler_full (no entry recursion). PLATFORM: SHARED */
#[no_mangle]
export function main_run_compiler_c(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_compiler_full(argc, argv);
  }
}

/** Weak parse_into_buf: ok=-1, main_idx=-1 (i64 -1). PLATFORM: SHARED */
#[no_mangle]
export function parse_into_buf(arena: *u8, module: *u8, data: *u8, len: i32): i64 {
  return -1 as i64;
}

/** Weak parse_into: forwards to parse_into_buf(arena, module, null, 0). PLATFORM: SHARED */
#[no_mangle]
export function parse_into(arena: *u8, module: *u8, source: *u8): i64 {
  return parse_into_buf(arena, module, 0 as *u8, 0);
}

/** Weak parse_into_init: no-op. PLATFORM: SHARED */
#[no_mangle]
export function parse_into_init(module: *u8, arena: *u8): void {
}

/** Weak parse_into_set_main_index: no-op. PLATFORM: SHARED */
#[no_mangle]
export function parse_into_set_main_index(module: *u8, main_idx: i32): void {
}

/** Weak get_module_num_imports: 0. PLATFORM: SHARED */
#[no_mangle]
export function get_module_num_imports(module: *u8): i32 {
  return 0;
}

/** Strong get_module_import_path: forwards to parser_get_module_import_path. PLATFORM: SHARED */
#[no_mangle]
export function get_module_import_path(module: *u8, i: i32, out: *u8): void {
  parser_get_module_import_path(module, i, out);
}

/** Weak parser_get_module_import_path: clears out. PLATFORM: SHARED */
#[no_mangle]
export function parser_get_module_import_path(module: *u8, i: i32, out: *u8): void {
  if (out != 0 as *u8) {
    out[0] = 0 as u8;
  }
}

/** Weak preprocess_x_buf: -1 (build_asm/preprocess.o wins). PLATFORM: SHARED */
#[no_mangle]
export function preprocess_x_buf(source_buf: *u8, source_len: i64, out_buf: *u8, out_cap: i32): i32 {
  return -1;
}

/** Weak parser_parse_into_init(arena, module) forwards parse_into_init(module, arena). PLATFORM: SHARED */
#[no_mangle]
export function parser_parse_into_init(arena: *u8, module: *u8): void {
  parse_into_init(module, arena);
}

/** Weak parser_parse_into: forwards to parse_into. PLATFORM: SHARED */
#[no_mangle]
export function parser_parse_into(arena: *u8, module: *u8, source: *u8): i64 {
  return parse_into(arena, module, source);
}

/** Weak parser_parse_into_set_main_index: forwards. PLATFORM: SHARED */
#[no_mangle]
export function parser_parse_into_set_main_index(module: *u8, main_idx: i32): void {
  parse_into_set_main_index(module, main_idx);
}

/** Weak parser_get_module_num_imports: forwards. PLATFORM: SHARED */
#[no_mangle]
export function parser_get_module_num_imports(module: *u8): i32 {
  return get_module_num_imports(module);
}

/** Weak peephole_peephole_run: 0 (build_asm/peephole.o wins). PLATFORM: SHARED */
#[no_mangle]
export function peephole_peephole_run(out: *u8): i32 {
  return 0;
}

/** Weak backend_asm_codegen_ast: forwards to unprefixed asm_codegen_ast. PLATFORM: SHARED */
#[no_mangle]
export function backend_asm_codegen_ast(module: *u8, arena: *u8, out: *u8, ctx: *u8): i32 {
  unsafe {
    return asm_codegen_ast(module, arena, out, ctx);
  }
}

/** Weak asm_asm_codegen_ast: forwards to unprefixed asm_codegen_ast. PLATFORM: SHARED */
#[no_mangle]
export function asm_asm_codegen_ast(module: *u8, arena: *u8, out_buf: *u8, ctx: *u8): i32 {
  unsafe {
    return asm_codegen_ast(module, arena, out_buf, ctx);
  }
}

/** Weak typeck_typeck_x_ast: forwards to typeck_x_ast. PLATFORM: SHARED */
#[no_mangle]
export function typeck_typeck_x_ast(module: *u8, arena: *u8, ctx: *u8): i32 {
  unsafe {
    return typeck_x_ast(module, arena, ctx);
  }
}

/** Weak typeck_typeck_x_ast_library: forwards to typeck_x_ast_library. PLATFORM: SHARED */
#[no_mangle]
export function typeck_typeck_x_ast_library(module: *u8, arena: *u8, ctx: *u8): i32 {
  unsafe {
    return typeck_x_ast_library(module, arena, ctx);
  }
}

/** Weak parser_diag_token_after_collect_imports: -1. PLATFORM: SHARED */
#[no_mangle]
export function parser_diag_token_after_collect_imports(source: *u8, module: *u8): i32 {
  return -1;
}

/** Weak typeck_struct_layout_metrics: -1 (typeck.o wins). PLATFORM: SHARED */
#[no_mangle]
export function typeck_struct_layout_metrics(module: *u8, arena: *u8, li: i32, depth: i32, check_pad: i32, out_sz: *u8, out_al: *u8): i32 {
  return -1;
}

/** Weak typeck_typeck_struct_layout_metrics: forwards. PLATFORM: SHARED */
#[no_mangle]
export function typeck_typeck_struct_layout_metrics(module: *u8, arena: *u8, li: i32, depth: i32, check_pad: i32, out_sz: *u8, out_al: *u8): i32 {
  return typeck_struct_layout_metrics(module, arena, li, depth, check_pad, out_sz, out_al);
}

/** Weak std_io_driver_driver_read_ptr: -1. PLATFORM: SHARED */
#[no_mangle]
export function std_io_driver_driver_read_ptr(out_slice: *u8, fd: *u8): i32 {
  return -1;
}

/** Weak std_io_driver_driver_read_ptr_len: -1. PLATFORM: SHARED */
#[no_mangle]
export function std_io_driver_driver_read_ptr_len(fd: *u8): i32 {
  return -1;
}

/** Weak typeck_merge_dep_struct_layouts_into_entry: no-op. PLATFORM: SHARED */
#[no_mangle]
export function typeck_merge_dep_struct_layouts_into_entry(module: *u8, arena: *u8, ctx: *u8): void {
}

/** Weak typeck_typeck_merge_dep_struct_layouts_into_entry: forwards. PLATFORM: SHARED */
#[no_mangle]
export function typeck_typeck_merge_dep_struct_layouts_into_entry(module: *u8, arena: *u8, ctx: *u8): void {
  typeck_merge_dep_struct_layouts_into_entry(module, arena, ctx);
}

/** Weak typeck_wpo_unify_soa_layouts: no-op. PLATFORM: SHARED */
#[no_mangle]
export function typeck_wpo_unify_soa_layouts(entry_mod: *u8, ctx: *u8): void {
}

/** Weak typeck_typeck_wpo_unify_soa_layouts: forwards. PLATFORM: SHARED */
#[no_mangle]
export function typeck_typeck_wpo_unify_soa_layouts(entry_mod: *u8, ctx: *u8): void {
  typeck_wpo_unify_soa_layouts(entry_mod, ctx);
}

/** Weak ast_arena_init: no-op (build_asm/ast.o / pipeline_x.o wins). PLATFORM: SHARED */
#[no_mangle]
export function ast_arena_init(arena: *u8): void {
}

/** Weak ast_ast_arena_init: forwards to ast_arena_init. PLATFORM: SHARED */
#[no_mangle]
export function ast_ast_arena_init(arena: *u8): void {
  ast_arena_init(arena);
}

/**
 * Weak platform_macho_write_macho_o_to_buf: -1. Must live outside
 * user_asm_seed_bridge (same-TU would bind the stub locally). Darwin only
 * in the seed; only Darwin links this object.
 * PLATFORM: MACOS
 */
#[no_mangle]
export function platform_macho_write_macho_o_to_buf(elf_ctx: *u8, out_buf: *u8): i32 {
  return -1;
}
