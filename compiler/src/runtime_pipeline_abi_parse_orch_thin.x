// Thin pure: wave323/374/374b M2 — parse_orch Cap residual C→.x (was wave284 C thin).
// parse/load/typeck orch + Cap-struct ParseIntoResult + diagnostics + sizeof +
// expr helpers + std_io batch. G.7 match runtime_pipeline_abi_parse_orch_thin.c.
// PRODUCT inject: wave374b MACOS PREFER / LINUX hard-skip (prior -E overlay).
// wave374: whole-body unsafe on exports (T001); Darwin PREFER L2 green.
// wave374b: Ubuntu typeck rejects whole-body-unsafe thin (even -E); hard-skip.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

struct ParseIntoResult {
  ok: i32;
  main_idx: i32;
}

const W323_ARENA_SZ: usize = 16;
const W323_MODULE_SZ: usize = 68;
const W323_DEP_CTX_SZ: usize = 8390600;
const W323_ONEFUNC_RESULT_SZ: usize = 8192;
const W323_ARENA_OFF_NUM_TYPES: usize = 0;
const W323_ARENA_OFF_NUM_EXPRS: i32 = 4;
const W323_ARENA_OFF_NUM_BLOCKS: i32 = 8;

const W323_EXPR_VAR: i32 = 3;
const W323_EXPR_ADD_ASSIGN: i32 = 29;
const W323_EXPR_SUB_ASSIGN: i32 = 30;
const W323_EXPR_MUL_ASSIGN: i32 = 31;
const W323_EXPR_DIV_ASSIGN: i32 = 32;
const W323_EXPR_MOD_ASSIGN: i32 = 33;
const W323_EXPR_BITAND_ASSIGN: i32 = 34;
const W323_EXPR_BITOR_ASSIGN: i32 = 35;
const W323_EXPR_BITXOR_ASSIGN: i32 = 36;
const W323_EXPR_SHL_ASSIGN: i32 = 37;
const W323_EXPR_SHR_ASSIGN: i32 = 38;
const W323_EXPR_FIELD_ACCESS: i32 = 44;
const W323_EXPR_INDEX: i32 = 47;
const W323_EXPR_DEREF: i32 = 52;

const W323_TOKEN_PLUS_EQ: i32 = 106;
const W323_TOKEN_MINUS_EQ: i32 = 107;
const W323_TOKEN_STAR_EQ: i32 = 108;
const W323_TOKEN_SLASH_EQ: i32 = 109;
const W323_TOKEN_PERCENT_EQ: i32 = 110;
const W323_TOKEN_AMP_EQ: i32 = 111;
const W323_TOKEN_PIPE_EQ: i32 = 112;
const W323_TOKEN_CARET_EQ: i32 = 113;
const W323_TOKEN_LSHIFT_EQ: i32 = 114;
const W323_TOKEN_RSHIFT_EQ: i32 = 115;

export extern function pipeline_dep_ctx_ndep(ctx: *u8): i32;
export extern function link_abi_getenv(name: *u8): *u8;
export extern function xlang_preprocess_raw_to_malloc(raw: *u8, raw_len: i64, out_src: *u8, out_src_len: *u8, path_diag: *u8, defines: *u8, ndefines: i32): i32;
export extern function runtime_read_file_view(path: *u8, out: *u8): i32;
export extern function runtime_release_file_view(view: *u8): void;
export extern function pipe_load_ptr_slot(base: *u8, slot: i32): *u8;
export extern function pipe_store_ptr_slot(base: *u8, slot: i32, p: *u8): void;
export extern function xlang_ptr_slot_get(base: *u8, slot: i32): *u8;
export extern function xlang_size_slot_get(base: *u8, slot: i32): i64;
export extern function xlang_size_slot_set(base: *u8, slot: i32, v: i64): void;
export extern function pipeline_dep_ctx_arena_at(ctx: *u8, idx: i32): *u8;
export extern function pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8;
export extern function pipeline_dep_ctx_path_buf_ptr(ctx: *u8): *u8;
export extern function pipeline_dep_ctx_set_import_path(ctx: *u8, idx: i32, path: *u8, len: i32): void;
export extern function pipeline_bind_import_dep_buffers(ctx: *u8, import_idx: i32): void;
export extern function pipeline_sync_one_dep_slot(module: *u8, ctx: *u8, dep_i: i32): i32;
export extern function pipeline_module_fixup_with_arena_stmt_orders(m: *u8, a: *u8): void;
export extern function pipeline_debug_trace_named_func_bodies(phase: *u8, module: *u8, arena: *u8): void;
export extern function pipeline_strict_parse_into_init(arena: *u8, module: *u8): void;
export extern function pipeline_parse_scalars_ok_get(): i32;
export extern function pipeline_parse_scalars_main_idx_get(): i32;
export extern function pipeline_module_num_funcs(m: *u8): i32;
export extern function pipeline_module_main_func_index(m: *u8): i32;
export extern function pipeline_module_set_main_func_index(m: *u8, idx: i32): void;
export extern function pipeline_module_func_name_len_at(m: *u8, fi: i32): i32;
export extern function pipeline_module_func_name_copy64(m: *u8, fi: i32, dst: *u8): void;
export extern function pipeline_module_func_body_ref_at(m: *u8, fi: i32): i32;
export extern function pipeline_module_func_is_extern_at(m: *u8, fi: i32): i32;
export extern function pipeline_module_num_type_aliases_at(m: *u8): i32;
export extern function pipeline_module_num_struct_layouts_at(m: *u8): i32;
export extern function pipeline_arena_expr_ptr(a: *u8, ref: i32): *u8;
export extern function pipeline_expr_field_access_is_enum_variant(a: *u8, expr_ref: i32): i32;
export extern function lsp_diag_parse_typeck_buf_c(module: *u8, arena: *u8, source_data: *u8, source_len: i32, ctx: *u8): i32;
export extern function lsp_diag_parse_entry_buf_c(module: *u8, arena: *u8, source_data: *u8, source_len: i32): i32;
export extern function pipeline_lint_set_source_buf(data: *u8, len: i32): void;
export extern function pipeline_typeck_set_active_ctx_c(module: *u8, ctx: *u8): void;
export extern function pipeline_typeck_scan_module_struct_stack_escape_c(module: *u8, arena: *u8, ctx: *u8): i32;
export extern function ast_pool_arena_release(a: *u8): void;
export extern function ast_pool_module_release(m: *u8): void;
export extern function ast_ast_block_num_lets(a: *u8, br: i32): i32;
export extern function ast_ast_block_num_stmt_order(a: *u8, br: i32): i32;
export extern function ast_ast_block_num_regions(a: *u8, br: i32): i32;
export extern function parser_parse_into_init(module: *u8, arena: *u8): void;
export extern function parser_parse_into_buf(arena: *u8, module: *u8, buf: *u8, buf_len: i32): ParseIntoResult;
export extern function parser_parse_into(arena: *u8, module: *u8, source: *u8): ParseIntoResult;
export extern function parser_parse_into_set_main_index(module: *u8, main_idx: i32): void;
export extern function parser_copy_module_import_path64(module: *u8, import_idx: i32, path_buf: *u8): i32;
export extern function parser_get_module_num_imports(module: *u8): i32;
export extern function ast_ast_arena_init(arena: *u8): void;
export extern function typeck_typeck_x_ast(module: *u8, arena: *u8, ctx: *u8): i32;
export extern function typeck_typeck_x_ast_library(module: *u8, arena: *u8, ctx: *u8): i32;
export extern function xlang_trait_reg_reset_c(arena: *u8): void;
export extern function xlang_trait_check_impls_complete_c(module: *u8): i32;
export extern function xlang_generic_bound_stash_source_buf_c(data: *u8, len: i32): void;
export extern function driver_diagnostic_typeck_fail(): void;
export extern function driver_diagnostic_after_entry_parse(num_funcs: i32): void;
export extern function driver_pipeline_entry_source_len(): usize;
export extern function driver_typeck_skip_large_entry(): i32;
export extern function driver_asm_build_skip_typeck(): i32;
export extern function driver_diagnostic_pipe_marker(id: i32): void;
export extern function driver_check_only_get(): i32;
export extern function driver_x_pipeline_skip_typeck_get(): i32;
export extern function driver_parse_strict_enabled(): i32;
export extern function driver_diagnostic_parse_skip_function(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void;
export extern function driver_diagnostic_parse_commit_fail(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void;
export extern function driver_diagnostic_parse_func_generic(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, num_generic_params: i32, is_main: i32): void;
export extern function pipeline_resolve_path_x_impl_c(ctx: *u8, import_path: *u8, path_len: i32): i32;
export extern function io_read_batch_buf(handle: i32, bufs: *u8, n: i32, timeout_ms: u32): isize;
export extern function io_write_batch_buf(handle: i32, bufs: *u8, n: i32, timeout_ms: u32): isize;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
export extern "C" function calloc(n: usize, sz: usize): *u8;
export extern "C" function free(p: *u8): void;

/**
 * LE i32 load at base+off (null-safe).
 * @param p *u8
 * @param off i32
 * @return i32
 */
function w323_load_i32(p: *u8, off: i32): i32 {
  if (p == (0 as *u8) || off < 0) {
    return 0;
  }
  unsafe {
    let b: *u8 = p + (off as usize);
    let b0: i32 = b[0] as i32;
    let b1: i32 = b[1] as i32;
    let b2: i32 = b[2] as i32;
    let b3: i32 = b[3] as i32;
    return b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
  }
}

/**
 * Arena num_exprs @4.
 * @param a *u8
 * @return i32
 */
function w323_arena_num_exprs(a: *u8): i32 {
  return w323_load_i32(a, W323_ARENA_OFF_NUM_EXPRS);
}

/**
 * Arena num_blocks @8.
 * @param a *u8
 * @return i32
 */
function w323_arena_num_blocks(a: *u8): i32 {
  return w323_load_i32(a, W323_ARENA_OFF_NUM_BLOCKS);
}

/**
 * Parse buffer into module; return 0 on ok.
 * @param arena *u8
 * @param module *u8
 * @param buf *u8
 * @param buf_len i32
 * @return i32
 */
#[no_mangle]
export function pipeline_parse_into_buf_impl_c(arena: *u8, module: *u8, buf: *u8, buf_len: i32): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (arena == (0 as *u8) || module == (0 as *u8) || buf == (0 as *u8) || buf_len <= 0) {
      return -1;
    }
    xlang_trait_reg_reset_c(arena);
    xlang_generic_bound_stash_source_buf_c(buf, buf_len);
    parser_parse_into_init(module, arena);
    let pr: ParseIntoResult = parser_parse_into_buf(arena, module, buf, buf_len);
    if (pr.ok == 0) {
      if (xlang_trait_check_impls_complete_c(module) != 0) {
        return -1;
      }
      pipeline_debug_trace_named_func_bodies("parse_post" as *u8, module, arena);
      pipeline_module_fixup_with_arena_stmt_orders(module, arena);
      pipeline_debug_trace_named_func_bodies("parse_post_fixup" as *u8, module, arena);
    }
    if (pr.ok == 0) {
      return 0;
    }
    return -1;
  }
}

/**
 * Alias of parse_into_buf_impl_c.
 */
#[no_mangle]
export function pipeline_parse_into_buf_c(arena: *u8, module: *u8, buf: *u8, buf_len: i32): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return pipeline_parse_into_buf_impl_c(arena, module, buf, buf_len);
  }
}

/**
 * Cold twin: parse_into_buf → impl_c.
 */
#[no_mangle]
export function pipeline_parse_into_buf(arena: *u8, module: *u8, buf: *u8, buf_len: i32): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return pipeline_parse_into_buf_impl_c(arena, module, buf, buf_len);
  }
}

/**
 * Load one import from disk (resolve + read view + preprocess + parse).
 * PLATFORM: SHARED — G.7 runtime_read_file_view + xlang_preprocess_raw_to_malloc.
 */
#[no_mangle]
export function pipeline_load_import_from_disk_impl_c(module: *u8, arena: *u8, ctx: *u8, import_idx: i32): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == (0 as *u8) || arena == (0 as *u8) || ctx == (0 as *u8) || import_idx < 0) {
      return -1;
    }
    let path_buf: u8[128] = [];
    let zi: i32 = 0;
    while (zi < 128) {
      unsafe { path_buf[zi] = 0 as u8; }
      zi = zi + 1;
    }
    let path_len: i32 = parser_copy_module_import_path64(module, import_idx, &path_buf[0]);
    if (pipeline_resolve_path_x(ctx, &path_buf[0], path_len) != 0) {
      return -7;
    }
    let path: *u8 = pipeline_dep_ctx_path_buf_ptr(ctx);
    if (path == (0 as *u8)) {
      return -8;
    }
    let view: u8[32] = [];
    let z: i32 = 0;
    while (z < 32) {
      unsafe { view[z] = 0 as u8; }
      z = z + 1;
    }
    if (runtime_read_file_view(path, &view[0]) != 0) {
      return -8;
    }
    let raw_data: *u8 = xlang_ptr_slot_get(&view[0], 0);
    let raw_len: i64 = xlang_size_slot_get(&view[0], 1);
    let out_prep: u8[8] = [];
    let out_len: u8[8] = [];
    pipe_store_ptr_slot(&out_prep[0], 0, 0 as *u8);
    xlang_size_slot_set(&out_len[0], 0, 0);
    let prep_rc: i32 = xlang_preprocess_raw_to_malloc(raw_data, raw_len, &out_prep[0], &out_len[0], path, 0 as *u8, 0);
    runtime_release_file_view(&view[0]);
    if (prep_rc != 0) {
      return -9;
    }
    let prep: *u8 = pipe_load_ptr_slot(&out_prep[0], 0);
    let prep_len64: i64 = xlang_size_slot_get(&out_len[0], 0);
    let i32_max: i64 = 2147483647;
    if (prep == (0 as *u8) || prep_len64 < 0 || prep_len64 > i32_max) {
      if (prep != (0 as *u8)) {
        free(prep);
      }
      return -9;
    }
    let prep_len: i32 = prep_len64 as i32;
    if (path_len > 0) {
      pipeline_dep_ctx_set_import_path(ctx, import_idx, &path_buf[0], path_len);
    }
    pipeline_bind_import_dep_buffers(ctx, import_idx);
    let dep_arena: *u8 = pipeline_dep_ctx_arena_at(ctx, import_idx);
    let dep_module: *u8 = pipeline_dep_ctx_module_at(ctx, import_idx);
    let parse_rc: i32 = pipeline_parse_into_buf(dep_arena, dep_module, prep, prep_len);
    free(prep);
    if (parse_rc != 0) {
      return -10;
    }
    return 0;
  }
}

/**
 * Cold twin load_import_from_disk.
 */
#[no_mangle]
export function pipeline_load_import_from_disk(module: *u8, arena: *u8, ctx: *u8, import_idx: i32): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return pipeline_load_import_from_disk_impl_c(module, arena, ctx, import_idx);
  }
}

/**
 * C alias load_import_from_disk.
 */
#[no_mangle]
export function pipeline_load_import_from_disk_c(module: *u8, arena: *u8, ctx: *u8, import_idx: i32): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return pipeline_load_import_from_disk(module, arena, ctx, import_idx);
  }
}

/**
 * Resolve import path (thin forward to impl_c).
 */
#[no_mangle]
export function pipeline_resolve_path_x(ctx: *u8, import_path: *u8, path_len: i32): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return pipeline_resolve_path_x_impl_c(ctx, import_path, path_len);
  }
}

/**
 * Sync dep slots from driver after entry parse.
 */
#[no_mangle]
export function pipeline_sync_dep_slots_from_driver_impl_c(module: *u8, ctx: *u8): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (module == (0 as *u8) || ctx == (0 as *u8)) {
      return -1;
    }
    let dep_sync_nd: i32 = pipeline_dep_ctx_ndep(ctx);
    let n_entry_imports: i32 = parser_get_module_num_imports(module);
    if (n_entry_imports >= 0 && n_entry_imports < dep_sync_nd) {
      return 0;
    }
    let dep_sync_i: i32 = 0;
    while (dep_sync_i < dep_sync_nd) {
      let sync_rc: i32 = pipeline_sync_one_dep_slot(module, ctx, dep_sync_i);
      if (sync_rc != 0) {
        return sync_rc;
      }
      dep_sync_i = dep_sync_i + 1;
    }
    return 0;
  }
}

#[no_mangle]
export function pipeline_sync_dep_slots_from_driver(module: *u8, ctx: *u8): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return pipeline_sync_dep_slots_from_driver_impl_c(module, ctx);
  }
}

#[no_mangle]
export function pipeline_sync_dep_slots_from_driver_c(module: *u8, ctx: *u8): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return pipeline_sync_dep_slots_from_driver(module, ctx);
  }
}

/**
 * Cap-struct parse with init (buf).
 */
#[no_mangle]
export function pipeline_parse_into_with_init_buf_impl_c(arena: *u8, module: *u8, data: *u8, len: i32): ParseIntoResult {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    let fail: ParseIntoResult = ParseIntoResult { ok: 1, main_idx: -1 };
    if (arena == (0 as *u8) || module == (0 as *u8) || data == (0 as *u8) || len <= 0) {
      return fail;
    }
    xlang_trait_reg_reset_c(arena);
    xlang_generic_bound_stash_source_buf_c(data, len);
    pipeline_strict_parse_into_init(arena, module);
    let pr: ParseIntoResult = parser_parse_into_buf(arena, module, data, len);
    if (pr.ok == 0 && xlang_trait_check_impls_complete_c(module) != 0) {
      return fail;
    }
    return pr;
  }
}

#[no_mangle]
export function pipeline_parse_into_with_init_buf_impl_rc(arena: *u8, module: *u8, data: *u8, len: i32, out_ok: *i32, out_main_idx: *i32): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (arena == (0 as *u8) || module == (0 as *u8) || data == (0 as *u8) || len <= 0) {
      if (out_ok != (0 as *i32)) { unsafe { *out_ok = 1; } }
      if (out_main_idx != (0 as *i32)) { unsafe { *out_main_idx = -1; } }
      return 0;
    }
    let r: ParseIntoResult = pipeline_parse_into_with_init_buf_impl_c(arena, module, data, len);
    if (out_ok != (0 as *i32)) { unsafe { *out_ok = r.ok; } }
    if (out_main_idx != (0 as *i32)) { unsafe { *out_main_idx = r.main_idx; } }
    return 0;
  }
}

#[no_mangle]
export function pipeline_parse_into_with_init_result_c(): ParseIntoResult {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return ParseIntoResult {
      ok: pipeline_parse_scalars_ok_get(),
      main_idx: pipeline_parse_scalars_main_idx_get()
    };
  }
}

#[no_mangle]
export function pipeline_parse_into_with_init_buf(arena: *u8, module: *u8, data: *u8, len: i32): ParseIntoResult {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return pipeline_parse_into_with_init_buf_impl_c(arena, module, data, len);
  }
}

#[no_mangle]
export function pipeline_parse_into_with_init_buf_c(arena: *u8, module: *u8, data: *u8, len: i32): ParseIntoResult {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return pipeline_parse_into_with_init_buf(arena, module, data, len);
  }
}

#[no_mangle]
export function pipeline_sizeof_arena(): usize {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return W323_ARENA_SZ;
  }
}

#[no_mangle]
export function pipeline_sizeof_module(): usize {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return W323_MODULE_SZ;
  }
}

#[no_mangle]
export function pipeline_sizeof_dep_ctx(): usize {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return W323_DEP_CTX_SZ;
  }
}

#[no_mangle]
export function pipeline_sizeof_onefunc_result(): usize {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return W323_ONEFUNC_RESULT_SZ;
  }
}

#[no_mangle]
export function pipeline_arena_offset_num_types(): usize {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return W323_ARENA_OFF_NUM_TYPES;
  }
}

#[no_mangle]
export function pipeline_lsp_diag_parse_typeck_buf_impl_c(module: *u8, arena: *u8, source_data: *u8, source_len: i32, ctx: *u8): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return lsp_diag_parse_typeck_buf_c(module, arena, source_data, source_len, ctx);
  }
}

#[no_mangle]
export function pipeline_lsp_diag_parse_entry_buf_impl_c(module: *u8, arena: *u8, source_data: *u8, source_len: i32): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return lsp_diag_parse_entry_buf_c(module, arena, source_data, source_len);
  }
}

#[no_mangle]
export function pipeline_lsp_diag_parse_typeck_buf(module: *u8, arena: *u8, source_data: *u8, source_len: i32, ctx: *u8): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return pipeline_lsp_diag_parse_typeck_buf_impl_c(module, arena, source_data, source_len, ctx);
  }
}

#[no_mangle]
export function pipeline_lsp_diag_parse_typeck_buf_c(module: *u8, arena: *u8, source_data: *u8, source_len: i32, ctx: *u8): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return pipeline_lsp_diag_parse_typeck_buf(module, arena, source_data, source_len, ctx);
  }
}

/**
 * Cap-struct parse with init from slice (data@0 length@8).
 * @param source *u8 — xlang_slice_uint8_t*
 */
#[no_mangle]
export function pipeline_parse_into_with_init_c(arena: *u8, module: *u8, source: *u8): ParseIntoResult {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    let fail: ParseIntoResult = ParseIntoResult { ok: 1, main_idx: -1 };
    if (arena == (0 as *u8) || module == (0 as *u8) || source == (0 as *u8)) {
      return fail;
    }
    let data: *u8 = xlang_ptr_slot_get(source, 0);
    if (data == (0 as *u8)) {
      return fail;
    }
    ast_ast_arena_init(arena);
    parser_parse_into_init(module, arena);
    return parser_parse_into(arena, module, source);
  }
}

#[no_mangle]
export function pipeline_typeck_after_parse_ok_impl_c(arena: *u8, module: *u8, source: *u8, ctx: *u8): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (arena == (0 as *u8) || module == (0 as *u8) || source == (0 as *u8) || ctx == (0 as *u8)) {
      return -1;
    }
    let data: *u8 = xlang_ptr_slot_get(source, 0);
    let length: i64 = xlang_size_slot_get(source, 1);
    if (data != (0 as *u8) && length > 0) {
      pipeline_lint_set_source_buf(data, length as i32);
    }
    let r: ParseIntoResult = pipeline_parse_into_with_init_c(arena, module, source);
    if (r.ok != 0) {
      return r.main_idx;
    }
    pipeline_module_set_main_func_index(module, r.main_idx);
    pipeline_typeck_set_active_ctx_c(module, ctx);
    if (pipeline_module_main_func_index(module) < 0) {
      let tc: i32 = typeck_typeck_x_ast_library(module, arena, ctx);
      if (tc != 0) {
        driver_diagnostic_typeck_fail();
        return tc;
      }
      if (pipeline_typeck_scan_module_struct_stack_escape_c(module, arena, ctx) != 0) {
        driver_diagnostic_typeck_fail();
        return -1;
      }
      return tc;
    }
    let tc2: i32 = typeck_typeck_x_ast(module, arena, ctx);
    if (tc2 != 0) {
      driver_diagnostic_typeck_fail();
      return tc2;
    }
    if (pipeline_typeck_scan_module_struct_stack_escape_c(module, arena, ctx) != 0) {
      driver_diagnostic_typeck_fail();
      return -1;
    }
    return tc2;
  }
}

#[no_mangle]
export function pipeline_typeck_after_parse_ok_buf_impl_c(arena: *u8, module: *u8, data: *u8, len: i32, ctx: *u8): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (data == (0 as *u8) || len <= 0) {
      return -1;
    }
    let source: u8[16] = [];
    pipe_store_ptr_slot(&source[0], 0, data);
    xlang_size_slot_set(&source[0], 1, len as i64);
    return pipeline_typeck_after_parse_ok_impl_c(arena, module, &source[0], ctx);
  }
}

#[no_mangle]
export function pipeline_typeck_after_parse_ok(arena: *u8, module: *u8, source: *u8, ctx: *u8): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return pipeline_typeck_after_parse_ok_impl_c(arena, module, source, ctx);
  }
}

#[no_mangle]
export function pipeline_typeck_after_parse_ok_c(arena: *u8, module: *u8, source: *u8, ctx: *u8): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return pipeline_typeck_after_parse_ok(arena, module, source, ctx);
  }
}

#[no_mangle]
export function pipeline_typeck_x_stack_escape_gate_from_src_c(src: *u8, src_len: i32): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (src == (0 as *u8) || src_len <= 0) {
      return 0;
    }
    let asz: usize = pipeline_sizeof_arena();
    let msz: usize = pipeline_sizeof_module();
    let arena_heap: *u8 = calloc(1 as usize, asz);
    let module_heap: *u8 = calloc(1 as usize, msz);
    let ctx_heap: *u8 = calloc(1 as usize, W323_DEP_CTX_SZ);
    if (arena_heap == (0 as *u8) || module_heap == (0 as *u8) || ctx_heap == (0 as *u8)) {
      free(arena_heap);
      free(module_heap);
      free(ctx_heap);
      return -1;
    }
    pipeline_strict_parse_into_init(arena_heap, module_heap);
    let pr: ParseIntoResult = parser_parse_into_buf(arena_heap, module_heap, src, src_len);
    if (pr.ok != 0) {
      ast_pool_arena_release(arena_heap);
      ast_pool_module_release(module_heap);
      free(arena_heap);
      free(module_heap);
      free(ctx_heap);
      return -1;
    }
    parser_parse_into_set_main_index(module_heap, pr.main_idx);
    let rc: i32 = pipeline_typeck_scan_module_struct_stack_escape_c(module_heap, arena_heap, ctx_heap);
    if (rc != 0) {
      driver_diagnostic_typeck_fail();
    }
    ast_pool_arena_release(arena_heap);
    ast_pool_module_release(module_heap);
    free(arena_heap);
    free(module_heap);
    free(ctx_heap);
    if (rc == 0) { return 0; }
    return -1;
  }
}

#[no_mangle]
export function parser_parse_strict_enabled(): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return driver_parse_strict_enabled();
  }
}

#[no_mangle]
export function parser_diagnostic_parse_skip(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    driver_diagnostic_parse_skip_function(byte_pos, num_funcs_so_far, name_len, name);
  }
}

#[no_mangle]
export function parser_diagnostic_parse_commit_fail(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    driver_diagnostic_parse_commit_fail(byte_pos, num_funcs_so_far, name_len, name);
  }
}

#[no_mangle]
export function parser_diagnostic_parse_func_generic(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, num_generic_params: i32, is_main: i32): void {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    driver_diagnostic_parse_func_generic(byte_pos, num_funcs_so_far, name, name_len, num_generic_params, is_main);
  }
}

#[no_mangle]
export function pipeline_debug_module_funcs(m: *u8): void {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (m == (0 as *u8)) { return; }
    let n: i32 = pipeline_module_num_funcs(m);
    let i: i32 = 0;
    while (i < n) {
      let nm: u8[256] = [];
      memset(&nm[0], 0, 256 as usize);
      pipeline_module_func_name_copy64(m, i, &nm[0]);
      i = i + 1;
    }
  }
}

#[no_mangle]
export function driver_get_module_num_funcs(m: *u8): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (m == (0 as *u8)) { return 0; }
    return pipeline_module_num_funcs(m);
  }
}

#[no_mangle]
export function driver_get_module_main_func_index(m: *u8): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (m == (0 as *u8)) { return -2; }
    return pipeline_module_main_func_index(m);
  }
}

#[no_mangle]
export function driver_diagnostic_entry_module(mod: *u8, a: *u8): void {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    let list_env: *u8 = link_abi_getenv("XLANG_ASM_LIST_FUNCS" as *u8);
    if (list_env != (0 as *u8) && mod != (0 as *u8)) {
      unsafe {
        if (list_env[0] != (0 as u8) && list_env[0] != (48 as u8)) {
          let n: i32 = pipeline_module_num_funcs(mod);
          let i: i32 = 0;
          while (i < n) {
            let nm: u8[256] = [];
            pipeline_module_func_name_copy64(mod, i, &nm[0]);
            let body_ref: i32 = pipeline_module_func_body_ref_at(mod, i);
            let nblocks: i32 = w323_arena_num_blocks(a);
            if (body_ref > 0 && a != (0 as *u8) && body_ref <= nblocks) {
              let _nlet: i32 = ast_ast_block_num_lets(a, body_ref);
              let _nso: i32 = ast_ast_block_num_stmt_order(a, body_ref);
              let _nreg: i32 = ast_ast_block_num_regions(a, body_ref);
            }
            i = i + 1;
          }
          return;
        }
      }
    }
  }
}

#[no_mangle]
export function typeck_driver_diagnostic_after_entry_parse(num_funcs: i32): void {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    driver_diagnostic_after_entry_parse(num_funcs);
  }
}

#[no_mangle]
export function typeck_driver_diagnostic_pipe_marker(id: i32): void {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    driver_diagnostic_pipe_marker(id);
  }
}

#[no_mangle]
export function typeck_driver_pipeline_entry_source_len(): usize {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return driver_pipeline_entry_source_len();
  }
}

#[no_mangle]
export function pipeline_driver_pipeline_entry_source_len(): usize {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return driver_pipeline_entry_source_len();
  }
}

#[no_mangle]
export function pipeline_driver_diagnostic_pipe_marker(id: i32): void {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    driver_diagnostic_pipe_marker(id);
  }
}

#[no_mangle]
export function xlang_pipeline_check_only(): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return driver_check_only_get();
  }
}

#[no_mangle]
export function pipeline_shu_pipeline_check_only(): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return xlang_pipeline_check_only();
  }
}

#[no_mangle]
export function typeck_driver_typeck_skip_large_entry(): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return driver_typeck_skip_large_entry();
  }
}

#[no_mangle]
export function typeck_driver_asm_build_skip_typeck(): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return driver_asm_build_skip_typeck();
  }
}

#[no_mangle]
export function pipeline_driver_typeck_skip_large_entry(): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return driver_typeck_skip_large_entry();
  }
}

#[no_mangle]
export function pipeline_driver_asm_build_skip_typeck(): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return driver_asm_build_skip_typeck();
  }
}

#[no_mangle]
export function pipeline_driver_x_pipeline_skip_typeck(): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return driver_x_pipeline_skip_typeck_get();
  }
}

#[no_mangle]
export function driver_diagnostic_entry_block_after_parse(mod: *u8, arena: *u8): void {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (mod == (0 as *u8) || arena == (0 as *u8)) { return; }
    let mi: i32 = pipeline_module_main_func_index(mod);
    let nf: i32 = pipeline_module_num_funcs(mod);
    if (mi < 0 || mi >= nf) { return; }
    let br: i32 = pipeline_module_func_body_ref_at(mod, mi);
    let nblocks: i32 = w323_arena_num_blocks(arena);
    if (br <= 0 || br > nblocks) { return; }
  }
}

#[no_mangle]
export function std_io_driver_submit_read_batch_buf(handle: usize, bufs: *u8, n: i32, timeout_ms: u32): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    let r: isize = io_read_batch_buf(handle as i32, bufs, n, timeout_ms);
    if (r < (0 as isize)) { return -1; }
    return r as i32;
  }
}

#[no_mangle]
export function std_io_driver_submit_write_batch_buf(handle: usize, bufs: *u8, n: i32, timeout_ms: u32): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    let r: isize = io_write_batch_buf(handle as i32, bufs, n, timeout_ms);
    if (r < (0 as isize)) { return -1; }
    return r as i32;
  }
}

/**
 * Expr kind ordinal at ref (LE kind@0).
 */
#[no_mangle]
export function pipeline_expr_kind_ord_at(a: *u8, expr_ref: i32): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (a == (0 as *u8) || expr_ref <= 0) { return -1; }
    let nexprs: i32 = w323_arena_num_exprs(a);
    if (expr_ref > nexprs) { return -1; }
    let ex: *u8 = pipeline_arena_expr_ptr(a, expr_ref);
    if (ex == (0 as *u8)) { return -1; }
    return w323_load_i32(ex, 0);
  }
}

#[no_mangle]
export function pipeline_expr_ref_is_assign_lvalue(a: *u8, expr_ref: i32): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (a == (0 as *u8) || expr_ref <= 0) { return 0; }
    let nexprs: i32 = w323_arena_num_exprs(a);
    if (expr_ref > nexprs) { return 0; }
    let kd: i32 = pipeline_expr_kind_ord_at(a, expr_ref);
    if (kd == W323_EXPR_VAR || kd == W323_EXPR_INDEX || kd == W323_EXPR_DEREF) {
      return 1;
    }
    if (kd != W323_EXPR_FIELD_ACCESS) {
      return 0;
    }
    if (pipeline_expr_field_access_is_enum_variant(a, expr_ref) == 0) {
      return 1;
    }
    return 0;
  }
}

#[no_mangle]
export function compound_assign_token_to_expr_kind_from_glue(kind: i32): i32 {
  // wave374: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (kind == W323_TOKEN_PLUS_EQ) { return W323_EXPR_ADD_ASSIGN; }
    if (kind == W323_TOKEN_MINUS_EQ) { return W323_EXPR_SUB_ASSIGN; }
    if (kind == W323_TOKEN_STAR_EQ) { return W323_EXPR_MUL_ASSIGN; }
    if (kind == W323_TOKEN_SLASH_EQ) { return W323_EXPR_DIV_ASSIGN; }
    if (kind == W323_TOKEN_PERCENT_EQ) { return W323_EXPR_MOD_ASSIGN; }
    if (kind == W323_TOKEN_AMP_EQ) { return W323_EXPR_BITAND_ASSIGN; }
    if (kind == W323_TOKEN_PIPE_EQ) { return W323_EXPR_BITOR_ASSIGN; }
    if (kind == W323_TOKEN_CARET_EQ) { return W323_EXPR_BITXOR_ASSIGN; }
    if (kind == W323_TOKEN_LSHIFT_EQ) { return W323_EXPR_SHL_ASSIGN; }
    if (kind == W323_TOKEN_RSHIFT_EQ) { return W323_EXPR_SHR_ASSIGN; }
    return W323_EXPR_SHR_ASSIGN;
  }
}
