// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// R2 runtime_pipeline_abi pure authority (product PREFER hybrid wave45-wave58).
// Product: g05_try_x_to_o this file + seeds/runtime_pipeline_abi.from_x.c rest
//   (-DXLANG_RUNTIME_PIPELINE_ABI_FROM_X) ld -r -> src/runtime_pipeline_abi.o
// wave115: pipeline_asm_selfhost.c pure-owned leave (asm_module_num_defined_funcs /
//   defined_func_ordinal + 9 is_* selfhost predicates). Cap residual:
//   pipeline_module_num_funcs / func_name_equal_at / asm_module_func_is_extern_at.
// wave114: pipeline_asm_ctx_loop.c pure-owned leave (asm_ctx_loop_* + asm_be_cont_*;
//   fixed-cap BSS sidecars; no GrowVec). Cap residual callers remain host-cc emit.
// wave112: pipeline_parse_typeck_dispatch.c pure-owned leave (parse scalars +
//   typeck_parsed/entry + load_import resolve/slot; Cap residual result_c/impl_rc
//   stay in pipeline_parse_orch.c for Cap-struct-return / unpack).
// wave111: pipeline_codegen_dep.c pure-owned leave (dep/entry codegen orch).
// wave110: pure ImportEntry storage (structure debt) - multi-module malloc map + full
//   pipeline_module_import_* API set (alloc/path/kind/binding/select + storage_release).
//   G.7 single authority under product PREFER hybrid; ast_pool Cap demoted XLANG_WEAK cold.
//   Layout ≡ C ImportEntry (340B) + per-module select rows/lens grow. Soft-reset when
//   module.num_imports==0 (parse counters / module reset). Closes Cap residual ImportEntry
//   storage under pure load_and_sync / path64 / collect / typeck import walks.
// wave99: pure parser_copy_module_import_path64 thin -> G.7 pipeline_module_import_path_copy
//   + NUL scan len (≡ historical parser_gen body). parser_gen seed path64 demoted weak
//   cold twin so pure hybrid owns product; wave110 pure owns path_copy storage.
//   Closes Cap residual path64 under pure load_and_sync / load_import orch.
// wave100: language residual Cap-fn-ptr - typeck same-module bare fn name -> *u8;
//   pure pipeline_run_x_thread_fn_ptr / xlang_asm_codegen_elf_o_thread_fn_ptr use
//   (fn as *u8) without g05 xlang_driver_*_thread_fn_ptr cast harness. Closes hard Cap
//   residual "g05 &fn cast" on product pure path.

// wave98: product complex #if Cap residual - G.7 cfg_eval.x on product link (not
//   bootstrap stub). Pure preprocess_eval_condition_c already routes complex ops to
//   cfg_eval_expr_c; Makefile -E-extern used bare CFLAGS -> Apple Clang -Werror
//   parentheses-equality -> silent stub pin (dual-auth vs cfg_eval.x). Root fix:
//   PIPELINE_GEN_CFLAGS (+ -Wno-parentheses-equality) on cfg_eval_gen.c. Closes
//   product hard Cap residual "cfg_eval complex body was stub under hybrid pure".
// wave97: pure load_and_sync step5 typeck merge+wpo call surface -> G.7 typeck.x
//   authority (typeck_merge_dep_struct_layouts_into_entry / typeck_wpo_unify_soa_layouts);
//   remove export-extern typeck_typeck_* double-prefix hop (link-alias still serves
//   other TUs). Closes Cap residual typeck merge+wpo call surface under pure load_and_sync.
// wave96: pure pipeline_parse_into_buf orch under wave94 pure load_import
//   (G.7 pure parser_parse_into_init + driver_parse_into_buf_rc + same-TU pure
//   debug_trace + fixup on ok==0; non-zero ok -> -1; buf_len<=0 -> -1). glue
//   XLANG_WEAK cold twin. Closes Cap residual parse_into_buf leaf under load_import.
// wave95: pure pipeline_resolve_path_x / pipeline_read_file_x /
//   pipeline_preprocess_loaded_into_ctx orch under wave94 pure load_import;
//   Cap residual try_one_lib_root / try_entry_dir (pipeline.x product surface) /
//   path+loaded buf accessors / set_loaded_len / preprocess_x_buf + pure
//   preprocess_len store; parse_into_buf wave96->pure. 2026-08-05: host-cc
//   pipeline_import_bind.c retired (pure-owned leave). wave105: host-cc
//   pipeline_resolve_path.c pure-owned leave (path_append_*_c / probe / flat /
//   off-sidecar / codegen_out_buf_* / resolve_path_x_impl_c|_c).
//   Closes Cap residual resolve/read/pp leaves.
// wave94: pure pipeline_load_import_from_disk_c orch + pure
//   pipeline_sync_dep_slots_from_driver_c orch + same-TU pure
//   pipeline_bind_import_dep_buffers + pipeline_sync_one_dep_slot;
//   Cap residual (wave95-96->pure) resolve/read/preprocess/parse; typeck merge+wpo
//   (wave97->typeck.x); path64 wave99->pure; glue/ast_pool XLANG_WEAK.
//   Closes Cap residual disk-load + dep-sync leaves under wave93 load_and_sync.
// wave93: pure pipeline_load_and_sync_direct_import_deps_c orch + same-TU pure
//   pipeline_try_bind_seeded_import + pipeline_dep_ctx_realign_ndep_for_entry_c;
//   Cap residual (wave94->pure) load_import/sync; typeck merge+wpo (wave97->typeck.x);
//   path64 wave99->pure; ast_pool XLANG_WEAK cold twins.
//   Closes Cap residual load_and_sync leaf under wave60 typeck_only orch.
// wave92: pure pipeline_typeck_validate_struct_layouts_zero_padding_c /
//   pipeline_typeck_patch_all_body_parent_links_c thin -> G.7 typeck.x authority
//   (typeck_validate_struct_layouts_zero_padding / typeck_patch_all_body_parent_links);
//   glue XLANG_WEAK cold twins keep historical metrics/patch bodies for non-PREFER links.
//   Closes Cap residual layout validate+patch helpers under pure dep-prerun light fallback.
// wave91: pure pipeline_typeck_set_dep_ctx / get_dep_ctx (LP64 ptr BSS; glue XLANG_WEAK cold).
//   Closes Cap residual set_dep_ctx leaf under wave89 pure dep-prerun orch; ast_pool enum
//   fallback reads via get_dep_ctx (no static dual-auth g_typeck_dep_ctx).
// wave90: pure pipeline_typeck_diag_soft_suppress_set / _get (i32 BSS; glue XLANG_WEAK cold).
//   Closes Cap residual soft-suppress leaf under wave89 pure dep-prerun orch.
// wave89: pure pipeline_typeck_dep_prerun_module_c orch (set_dep_ctx + soft_suppress +
//   typeck_x_ast_library + layout validate/patch light fallback; glue XLANG_WEAK cold).
//   Closes Cap residual typeck dep-prerun leaf used by wave60 typeck_only orch.
// wave88: pure preprocess_eval_condition_c orch (trim + simple -> pure define_has;
//   complex ops -> Cap residual cfg_eval_expr_c; glue XLANG_WEAK cold fallback).
//   Closes Cap residual preprocess #if condition-eval leaf (x_buf already pure cross-TU).
// wave85: pure preprocess_define_reset / add / has (-D table BSS; glue XLANG_WEAK cold fallback).
// wave84: pure pipeline_run_x_thread_fn_ptr / xlang_asm_codegen_elf_o_thread_fn_ptr thin
//   (G.7 g05 xlang_driver_*_thread_fn_ptr function-address cast residual; product surface pure;
//   seed cold twin under #ifndef FROM_X). Closes Cap residual always-seed Cap-fn-ptr leaf.
// wave80: pure product_emit thin via export-extern asm_asm_codegen_elf_o (no same-TU -1 body).
// wave45 root fix: never put the two-char end-comment marker inside block prose
//   (historical char**/void* truncated parse -> silent drop of all later export function).
// wave46: pure merge/collect helpers (ptr/size slots, i32_store, module import cstr,
//   collect_to_load_has, preprocess directive diag codes) - seed cold twins under FROM_X.
// wave47: pure collect seed_to_load + enqueue_module_imports (strdup Cap residual then pure).
// wave48: pure collect deps_process_one orch; Cap residual tmp_parse_and_enqueue;
//   G.7 reuses load_one_direct_import_at for resolve/read/preprocess store.
// wave49: pure collect paths_process_one orch; Cap residual paths_tmp_resolve_parse_enqueue
//   (resolve/read/preprocess + G.7 tmp_parse_and_enqueue + free prep).
// wave50: pure collect deps/paths transitive_impl orch (stack to_load[32] + process_one loop).
// wave51: pure load_one_direct_import_at + load_direct_fail_cleanup orch;
//   Cap residual then pure (wave55) xlang_load_one_direct_resolve_read_preprocess;
//   G.7 paths_tmp reuses same resolve_read (no dual resolve/read/preprocess).
// wave52: pure collect tmp_parse_and_enqueue orch (malloc/memset ensure + parse + G.7 enqueue).
// wave53: pure collect paths_tmp_resolve_parse_enqueue orch (ensure tmp + resolve_read
//   + G.7 pure tmp_parse + free prep).
// wave54: pure collect strdup thin shell (malloc + scan len + byte copy + NUL; no libc strdup name).
// wave55: pure resolve_read_preprocess orch (stack resolved[4096] + FileView u8[32]
//   + pure resolve multi + runtime_read_file_view + pure preprocess + release + diags).
// wave56: pure pipeline_run_x thread large-stack _impl orch (PipelineRunSuArgs stack pack;
//   Cap-fn-ptr + G.7 driver_run_thread_on_large_stack; XLANG_DEBUG_PIPE notes cold-only).
// wave57: pure asm elf_o large-stack _impl orch (AsmElfLargeArgs stack pack u8[48];
//   Cap-fn-ptr + product_emit Cap residual; G.7 driver_run_thread_on_large_stack).
// wave58: pure dep_prerun_parse_skip_typeck_impl orch (check_only + skip typeck/codegen
//   flags + G.7 driver_pipeline_dep_ctx_* asm_entry_module_only + pure large_stack).
// wave59: pure dep_prerun_parse_only_impl orch (parser_parse_into_init +
//   pipeline_parse_set_main_from_buf_c; XLANG_ASM_DEBUG notes cold-only).
// wave60: pure dep_prerun_typeck_only_impl orch (parse_set_main + load_sync deps +
//   typeck_dep_prerun_module; XLANG_DEBUG_PIPE notes cold-only).
// wave61: pure preprocess_raw_to_malloc_impl orch (scratch + define table + preprocess_x_buf
//   + owned dup; Cap residual preprocess_* / pure diag helpers; oversized -> pure fail).
// wave62: pure one_ctx_for_dep_prerun_map_impl orch (tmp malloc arena/module + parse_into
//   ok/allow -2 + import map via find_loaded; G.7 pctx_update / module import path).
// wave63: pure typeck_module_entry_only / with_sidecar / pipeline_typeck_module_for_ctx_impl
//   orch (Cap residual typeck_module C frontend + typeck_dep_module_ptrs_base BSS base).
// wave64: pure pipeline_parse_into_bytes orch (G.7 pure parser_parse_into_init +
//   G.7 pure driver_parse_into_buf_rc; non-zero ok -> -1; cold twin under FROM_X).
// wave65: pure pipeline_resolve_path_into_static orch (G.7 pure multi resolve +
//   entry_dir_get (wave68 pure) / resolved_path_buf_slot (wave69 pure BSS); cold twin under FROM_X).
// wave66: pure pipeline_read_file_stage_prep + pipeline_read_file_commit_prep orch
//   (G.7 pure preprocess + stage clear/set/take (wave71 pure BSS) + Cap residual
//   loaded_import_commit_from_owned; cold twins under FROM_X).
// wave67: pure pipeline_dep_ctx_path_bufs_reset + pipeline_dep_ctx_copy_entry_dir orch
//   (LP64 offsetof + LE store/byte copy; same layout as driver_abi wave19);
//   pure pipeline_dep_ctx_set_use_asm_backend thin -> G.7 driver_pipeline_dep_ctx_set_use_asm;
//   cold twins under FROM_X.
// wave68: pure pipeline_entry_dir_copy / set_dot / get orch (module BSS buf 512 +
//   "." lit + is_dot flag; G.7 single authority for resolve_path / set_entry_dir;
//   cold twins under FROM_X).
// wave69: pure pipeline_resolved_path_buf_slot (module BSS buf 512; G.7 single authority
//   for pure into_static + read_file_stage_prep path base; cold twin under FROM_X).
// wave70: pure pipeline_dep_arena/module_slot_set/at (module BSS 32×LP64 ptr cells each;
//   G.7 xlang_ptr_slot_* on raw u8[256]; single authority for pure set_dep_slots / get_dep_*;
//   cold twins under FROM_X).
// wave71: pure pipeline_rf_stage_prep_clear/set/take (module BSS ptr cell + size cell;
//   G.7 xlang_ptr_slot_* / xlang_size_slot_*; single authority for pure stage_prep / commit_prep;
//   cold twins under FROM_X).
// wave72: pure pipeline_loaded_import_commit_from_owned / data / len_get (module BSS
//   buf+len+cap cells; G.7 ptr/size slots + malloc ensure floor XLANG_PIPELINE_IMPORT_BUF_CAP;
//   cold twins under FROM_X).
// wave73: pure pipeline_diag_emitted_flag_slot (module BSS i32 flag; G.7 single authority for
//   pure reset/note/get; cold twin under FROM_X).
// wave74: pure driver_dep_* table BSS orch (arena/module/path_registry/seeded 32 slots;
//   G.7 xlang_ptr_slot_* + pure seeded_slot; no cross-TU naked global - only accessors;
//   cold twins under FROM_X).
// wave75: pure entry_lib authority (xlang_cstr_typeck_lit / xlang_entry_lib_keyword_lit /
//   xlang_entry_lib_name_from_path_impl + thin gate); module BSS stem_buf[128] + keyword lits;
//   G.7 single path matches C seed order (keywords before std/stem - closes pure std/-first drift);
//   cold twins under FROM_X).
// wave76: pure xlang_cstr_offset (G.7 &s[off] -> C &s[off] / s+off; closes Cap residual pointer
//   arith leaf for pipe_dir_tail / pipe_strip_prefix_seg / driver -D parse); cold twin under FROM_X.
// wave77: pure typeck_ndep / typeck_dep_* table BSS + slot/get/set_impl / ptrs_base
//   (G.7 xlang_ptr_slot_*; product hybrid writers only via accessors - rt_run_* pure +
//   driver_typeck_*; cold seed naked C globals stay under #ifndef FROM_X for cold twins).
// wave78: pure xlang_lsp_ptr_slot_clear (G.7 xlang_ptr_slot_set null) + xlang_fputs_stdout
//   (G.7 g05 xlang_driver_stdout_ptr + xlang_driver_fputs_opaque) + driver_asm_fp_is_stdout
//   + driver_asm_fclose_file (G.7 g05 stdout_ptr compare + fclose_opaque); cold twins under FROM_X.
// wave79: pure xlang_path_try_realpath_inplace (G.7 g05 xlang_driver_realpath_opaque + stack
//   resolved[1024] + pipe_cstr_copy; fail -> leave path unchanged; matches seed POSIX/APPLE
//   realpath+snprintf and non-POSIX no-op via harness null); cold twin under FROM_X.
// wave80: pure xlang_asm_codegen_elf_o_product_emit thin (export-extern asm_asm_codegen_elf_o only -
//   remove same-TU weak -1 stub so call keeps external reloc -> final strong bridge;
//   seed cold twin under #ifndef FROM_X). Closes product_emit Cap residual leaf.
// wave81: pure xlang_preprocess / xlang_preprocess_quiet / xlang_preprocess_with_path thin public
//   surface (G.7 pure xlang_preprocess_raw_to_malloc_impl; product always X-pipeline path;
//   seed cold twin keeps LEGACY preprocess_c_fallback under #ifndef FROM_X).
// wave82: pure pipeline_debug_trace_named_func_bodies_impl orch (getenv + module func walk +
//   G.7 pure pipeline_debug_body_func_match + stack msg via pipe_diag_msg_append_* + diag_report;
//   no va_list reportf - cold twin keeps reportf). Closes soft residual always-seed body-trace
//   leaf still called from pure public thin.
// wave83: pure pipeline_sizeof_arena / pipeline_sizeof_module (fixed LP64 layout constants
//   matching pipeline_glue sizeof; dual-end verified 16 / 68). Glue keeps weak cold fallback.
// wave84: pure Cap-fn-ptr surface thin (pipeline_run_x_thread_fn_ptr /
//   xlang_asm_codegen_elf_o_thread_fn_ptr) via g05 function-address opaques.
// wave85: pure preprocess_define_reset / add / has (G.7 single -D table BSS;
//   glue strict_stubs XLANG_WEAK cold fallback). Closes Cap residual define-table
//   leaf of preprocess engine (x_buf / if_stack still Cap residual).
// wave86: pure preprocess_if_stack_reset / len / push / pop / at / set_at
//   (G.7 single fixed i32[32] BSS). 2026-08-05: host-cc GrowVec XLANG_WEAK twin
//   pipeline_preprocess_if.c deleted (pure-owned WEAK cold leave).
//   Closes Cap residual preprocess #if stack leaf (x_buf still Cap residual).
// wave87: pure typeck_module_for_ctx route -> typeck_x_ast / typeck_x_ast_library
//   (G.7 single typeck authority; C typeck_module frontend deleted - was weak -1 only).
//   Closes Cap residual typeck_module C frontend leaf.
// wave88: pure preprocess_eval_condition_c (G.7 pure define_has simple path + Cap residual
//   cfg_eval_expr_c for complex #if); glue XLANG_WEAK cold fallback.
//   Closes Cap residual preprocess condition-eval leaf of preprocess.x engine path.
// wave89: pure pipeline_typeck_dep_prerun_module_c (G.7 pure orch -> typeck_x_ast_library +
//   Cap residual set_dep_ctx / soft_suppress / validate / patch; glue XLANG_WEAK cold).
//   Closes Cap residual typeck dep-prerun leaf (wave60 typeck_only no longer always-seed body).
// wave90: pure soft_suppress set/get BSS (G.7 single flag; same-TU orch + diagnostic get).
// wave91: pure set_dep_ctx / get_dep_ctx BSS (G.7 single ptr; same-TU orch + ast_pool get).
// wave92: pure layout validate/patch_c thin -> typeck.x (G.7; glue XLANG_WEAK cold).
// wave97: pure load_and_sync step5 merge+wpo -> typeck.x (G.7; no typeck_typeck_* hop).
// Cap residual still: g05 &fn cast (language; g05 harness); preprocess_x_buf pure
//   preprocess.x cross-TU; ImportEntry storage via pipeline_module_import_path_* (ast_pool).
//   cfg_eval complex #if = permanent G.7 cross-TU call to cfg_eval.x (wave98 product
//   link fixed; body no longer bootstrap stub when -E works).
// PLATFORM: SHARED - pure link-name contract; verify mac + Ubuntu L2 PREFER hybrid.

// wave73: pipeline_diag_emitted_flag_slot is pure export function below (pure BSS).
// wave74: driver_dep_seeded_slot / *_ptr_set_impl / path_registry_* / *_buf are pure below.
// wave75: xlang_cstr_typeck_lit / xlang_entry_lib_keyword_lit / name_from_path_impl pure below.
// wave76: xlang_cstr_offset is pure export function below (not Cap residual).
// wave77: typeck_ndep_slot / store_impl / typeck_dep_*_get/set_impl / ptrs_base pure below.
// wave78: xlang_lsp_ptr_slot_clear / xlang_fputs_stdout / driver_asm_fp_is_stdout /
//   driver_asm_fclose_file are pure export functions below.
// wave79: xlang_path_try_realpath_inplace is pure export function below.
// wave80: xlang_asm_codegen_elf_o_product_emit is pure export function below.
// wave82: pipeline_debug_trace_named_func_bodies_impl is pure export function below.
// wave83: pipeline_sizeof_arena / pipeline_sizeof_module are pure export functions below.
// wave84: pipeline_run_x_thread_fn_ptr / xlang_asm_codegen_elf_o_thread_fn_ptr pure below.
// wave85: preprocess_define_reset / add / has are pure export functions below.
// wave86: preprocess_if_stack_* are pure export functions below (not Cap residual).
// wave87: typeck_module_* / pipeline_typeck_module_for_ctx* pure below (route to typeck_x_ast).
// wave88: preprocess_eval_condition_c is pure export function below (not Cap residual glue body).
// wave89: pipeline_typeck_dep_prerun_module_c is pure export function below (not Cap residual glue body).
// wave90: pipeline_typeck_diag_soft_suppress_set / _get are pure export functions below.
// wave91: pipeline_typeck_set_dep_ctx / get_dep_ctx are pure export functions below.
// wave92: pipeline_typeck_validate_struct_layouts_zero_padding_c /
//   pipeline_typeck_patch_all_body_parent_links_c are pure export functions below.
// wave93: pipeline_load_and_sync_direct_import_deps_c / try_bind / realign pure below.
// wave94: load_import_from_disk_c / sync_dep_slots_from_driver_c / bind / sync_one pure below.
// wave96: pipeline_parse_into_buf is pure export function below (not Cap residual).
// wave97: load_and_sync step5 merge+wpo call typeck.x authority below (not Cap residual hop).
export extern "C" function strchr(s: *u8, c: i32): *u8;
// wave1222: sibling-directory scan helpers for import resolution.
// These are static inline in g05_try_x_to_o prologue (sed strips the extern
// re-decl from -E output). PLATFORM: POSIX (opendir/readdir); Windows cold
// seed C rest. Same pattern as fmt_check_cmd_thin.x lines 770-773.
export extern "C" function xlang_fmt_opendir(name: *u8): *u8;
export extern "C" function xlang_fmt_closedir(dirp: *u8): i32;
export extern "C" function xlang_fmt_access(path: *u8, mode: i32): i32;
export extern "C" function xlang_fmt_readdir_name(dirp: *u8): *u8;
// wave88/98: complex #if -> G.7 cfg_eval.x authority (surface cfg_eval_expr_c via
// link_alias to lexer_cfg_eval_expr_c; product must not pin bootstrap stub - wave98).
export extern "C" function cfg_eval_expr_c(start: *u8, len: i32): i32;
export extern "C" function pipeline_asm_user_dep_skip_x_typeck(path: *u8): i32;
export extern "C" function pipeline_asm_user_std_net_dep_path(path: *u8): i32;
export extern "C" function pipeline_codegen_path_is_std_io_driver_bytes(path: *u8): i32;
// wave63: typeck_module_entry_only / with_sidecar / for_ctx pure export functions below.
// wave87: product force_c path no longer calls deleted C typeck_module (weak -1 stub).
// G.7 authority = typeck_x_ast / typeck_x_ast_library (typeck.x -> typeck_x.o).
// pipeline_module_main_func_index chooses entry vs library (≡ pipeline_impl_typecheck).
// PLATFORM: SHARED - same ABI as seed cold twins; pure owns null gates and X route.
export extern "C" function typeck_x_ast(module: *u8, arena: *u8, ctx: *u8): i32;
export extern "C" function typeck_x_ast_library(module: *u8, arena: *u8, ctx: *u8): i32;
// wave92: G.7 typeck.x layout/parent-link authority (same symbols as typeck_x.o product).
// PLATFORM: SHARED - light fallback under pure dep-prerun routes here (not glue metrics fork).
export extern "C" function typeck_validate_struct_layouts_zero_padding(module: *u8, arena: *u8): i32;
export extern "C" function typeck_patch_all_body_parent_links(module: *u8, arena: *u8): void;
// wave93-99 leaves under pure load_and_sync / load_import orch.
// PLATFORM: SHARED - strong bodies remain in glue/parser for sub-leaves;
//   wave94 pure owns load_import_from_disk_c / sync_dep_slots_from_driver_c /
//   bind_import_dep_buffers / sync_one_dep_slot (same-TU; not export-extern);
//   wave95 pure owns resolve_path_x / read_file_x / preprocess_loaded_into_ctx;
//   wave96 pure owns pipeline_parse_into_buf (same-TU; not export-extern);
//   wave97 pure load_and_sync step5 routes merge+wpo -> typeck.x (below);
//   wave99 pure owns parser_copy_module_import_path64 (below; not export-extern).
// wave110: pipeline_module_import_path_copy is pure export below (ImportEntry storage).
//   Do not export-extern Cap path_copy - dual authority with pure map.
export extern "C" function ast_pipeline_dep_ctx_ndep(ctx: *u8): i32;
export extern "C" function ast_pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8;
// wave95 Cap residual under pure resolve/read/pp orch (G.7 try_* from pipeline.x
// product surface; path/loaded accessors + set_loaded_len from ast_pool).
// preprocess_x_buf already declared above (preprocess.x engine).
export extern "C" function pipeline_loop_should_continue_lib_root_c(ctx: *u8, idx: i32): i32;
export extern "C" function pipeline_resolve_path_try_one_lib_root(ctx: *u8, lib_idx: i32, import_path: *u8, path_len: i32): i32;
export extern "C" function pipeline_resolve_path_try_entry_dir(ctx: *u8, import_path: *u8, path_len: i32): i32;
export extern "C" function pipeline_dep_ctx_path_buf_ptr(ctx: *u8): *u8;
export extern "C" function pipeline_dep_ctx_loaded_buf_ptr(ctx: *u8): *u8;
export extern "C" function pipeline_dep_ctx_set_loaded_len(ctx: *u8, n: i64): void;
export extern "C" function xlang_read_file_into_path(path: *u8, buf: *u8, cap: i64): i32;
// wave105 resolve_path pure-owned leave Cap residual (dep_ctx path byte + entry_dir +
//   lib_root copy + fs open/close). PRODUCT: pipeline_x / std.fs strong; pure only calls.
// PLATFORM: SHARED - sole host-cc body retired with pipeline_resolve_path.c.
// wave106: pipeline_run_x_pipeline.c pure-owned leave (last_rc / typeck_fail /
//   parse_entry_do_parse / typecheck_entry_emit / const-buf face).
export extern "C" function pipeline_dep_ctx_set_path_buf_byte(ctx: *u8, off: i32, b: u8): void;
export extern "C" function pipeline_dep_ctx_entry_dir_len(ctx: *u8): i32;
export extern "C" function pipeline_dep_ctx_entry_dir_copy(ctx: *u8, dst: *u8, cap: i32): void;
export extern "C" function pipeline_copy_lib_root_to_buf256(ctx: *u8, lib_idx: i32, dst: *u8): i32;
export extern "C" function pipeline_ctx_lib_root_count(ctx: *u8): i32;
export extern "C" function std_fs_fs_open_read(path: *u8): i32;
export extern "C" function std_fs_fs_close(fd: i32): i32;
// wave95 Cap residual under pure load_import orch (arena/prep ptr accessors).
// wave96: pipeline_parse_into_buf is pure export function below (not export-extern).
export extern "C" function pipeline_dep_ctx_arena_at(ctx: *u8, idx: i32): *u8;
export extern "C" function pipeline_dep_ctx_preprocess_buf_ptr(ctx: *u8): *u8;
// wave101: pipeline_dep_ctx_preprocess_len_get is pure export below (not Cap residual
//   host-cc field load). 2026-08-05: import_bind host-cc leave - pure sole provider.
// wave102: asm_diag_* pure export below (start_func_skip + BODY/FUNC_TRACE).
//   2026-08-05: pipeline_asm_diag.c host-cc leave - pure sole provider.
// wave103: lsp_diag_*_c pure export below (typeck_after_load / parse_entry / parse_typeck).
//   2026-08-05: pipeline_lsp_diag.c host-cc leave - pure sole provider.
// wave97: G.7 typeck.x merge/wpo authority (same symbols as typeck_x.o product).
// PLATFORM: SHARED - pure load_and_sync step5 routes here (not typeck_typeck_* hop).
export extern "C" function typeck_merge_dep_struct_layouts_into_entry(mod: *u8, arena: *u8, ctx: *u8): void;
export extern "C" function typeck_wpo_unify_soa_layouts(entry: *u8, ctx: *u8): void;
export extern "C" function pipeline_module_main_func_index(module: *u8): i32;
export extern "C" function free(p: *u8): void;
/** Release process-wide ArenaSidecar GrowVecs before free(arena).
 * PLATFORM: SHARED - required for batch check (collect_deps tmp arenas). */
export extern "C" function ast_pool_arena_release(a: *u8): void;
/** Release process-wide ModuleSidecar GrowVecs before free(module).
 * PLATFORM: SHARED - see ast_pool_arena_release. */
export extern "C" function ast_pool_module_release(m: *u8): void;
// wave52 pure tmp_parse orch: libc malloc/memset for large tmp arena/module ensure+zero.
// PLATFORM: SHARED - same ABI as seed cold twin; free() still releases ownership.
export extern "C" function malloc(n: usize): *u8;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
// wave54: xlang_collect_strdup is pure export function below (not Cap residual).
// Do not export-extern libc strdup by name - conflicts with string.h after -E preamble.
// wave52: xlang_collect_tmp_parse_and_enqueue is pure export function below (not Cap residual).
// wave53: xlang_collect_paths_tmp_resolve_parse_enqueue is pure export function below.
// wave55: xlang_load_one_direct_resolve_read_preprocess is pure export function below.
// wave55 pure resolve_read: runtime file view (XlangRuntimeFileView 24B; pad 32 stack).
// PLATFORM: SHARED - same ABI as fmt_check pure path; G.7 no second view layout.
export extern "C" function runtime_read_file_view(path: *u8, out: *u8): i32;
export extern "C" function runtime_release_file_view(view: *u8): void;
export extern "C" function ast_module_free(mod: *u8): void;
// wave78: xlang_lsp_ptr_slot_clear is pure export function below (G.7 xlang_ptr_slot_set).
/* See implementation. */
export extern "C" function ast_pipeline_dep_ctx_reset(ctx: *u8): void;
export extern "C" function ast_pipeline_dep_ctx_set_module(ctx: *u8, idx: i32, m: *u8): void;
export extern "C" function ast_pipeline_dep_ctx_set_arena(ctx: *u8, idx: i32, a: *u8): void;
export extern "C" function ast_pipeline_dep_ctx_set_import_path(ctx: *u8, idx: i32, bytes: *u8, len: i32): void;
export extern "C" function ast_pipeline_dep_ctx_set_ndep(ctx: *u8, n: i32): void;
// wave56: pipeline_run_x_thread_fn_impl is pure export function below.
// wave57: xlang_asm_codegen_elf_o_thread_fn_impl is pure export function below.
// wave80: product_emit is pure thin below (G.7 export-extern asm_asm_codegen_elf_o -> bridge).
// Cap residual always-seed: Cap-fn-ptr for asm large-stack only (wave57/wave80).
// PLATFORM: SHARED - must not define same-TU body for asm_asm_codegen_elf_o (weak -1 was Cap trap).
export extern "C" function asm_asm_codegen_elf_o(module: *u8, arena: *u8, ctx: *u8, elf_ctx: *u8, out_buf: *u8): i32;
// wave84: Cap-fn-ptr product surfaces pure; wave100: no g05 &fn cast residual -
//   typeck resolves same-module bare fn name to Cap-fn-ptr *u8; pure bodies use (fn as *u8).
// PLATFORM: SHARED - g05 may still define dead xlang_driver_*_thread_fn_ptr helpers (optional).
// wave56 pure pipeline large-stack orch: set entry source_len + run pipeline.
export extern "C" function driver_set_pipeline_entry_source_len(len: i64): void;
// wave106: pipeline_run_x_pipeline is pure export below (const-buf face over
//   pipeline_run_x_pipeline_impl). 2026-08-05: host-cc pipeline_run_x_pipeline.c leave.
export extern "C" function driver_run_thread_on_large_stack(fn: *u8, arg: *u8): void;
// wave112: typeck_entry_module_c / typeck_parsed_module_c pure exports below
//   (parse_typeck_dispatch leave). should_skip_x_typeck remains Cap residual
//   (pipeline.x product face); pure owns should_skip_x_typeck_c only.
// PLATFORM: SHARED.
export extern "C" function pipeline_should_skip_x_typeck(ctx: *u8): i32;
export extern "C" function driver_diagnostic_typeck_fail(): void;
export extern "C" function driver_diagnostic_source_len(len: i32): void;
export extern "C" function driver_diagnostic_after_entry_parse(num_funcs: i32): void;
export extern "C" function driver_diagnostic_after_entry_parse_module(module: *u8): void;
export extern "C" function driver_diagnostic_entry_module(module: *u8, arena: *u8): void;
export extern "C" function driver_x_pipeline_skip_typeck_get(): i32;
export extern "C" function driver_x_pipeline_skip_codegen_get(): i32;
export extern "C" function pipeline_driver_asm_build_skip_typeck(): i32;
export extern "C" function pipeline_driver_x_pipeline_skip_typeck(): i32;
export extern "C" function pipeline_dep_ctx_asm_entry_module_only(ctx: *u8): i32;
export extern "C" function pipeline_dep_ctx_ndep(ctx: *u8): i32;
export extern "C" function pipeline_run_x_pipeline_impl(module: *u8, arena: *u8, source_data: *u8, source_len: i64, out_buf: *u8, ctx: *u8): i32;
// wave112 Cap residual: active ctx / WPO-S3 escape scan / unused-private lint.
export extern "C" function pipeline_typeck_set_active_ctx_c(module: *u8, ctx: *u8): void;
export extern "C" function pipeline_typeck_scan_module_struct_stack_escape_c(module: *u8, arena: *u8, ctx: *u8): i32;
export extern "C" function pipeline_typeck_unused_private_funcs(module: *u8, arena: *u8): i32;
// wave112 Cap residual: out-param unpack of Cap-struct-return parse-with-init.
export extern "C" function pipeline_parse_into_with_init_buf_impl_rc(arena: *u8, module: *u8, data: *u8, len: i32, out_ok: *i32, out_main_idx: *i32): i32;
// wave103: large-stack gate for LSP typeck (driver_abi pure authority).
export extern "C" function driver_is_large_stack_thread(): i32;
// wave111: codegen_dep pure-owned leave Cap residual (asm/C emit + dep_ctx path faces).
// PRODUCT: pipeline_x / codegen_x / driver_abi / link_abi; pure only orchestrates.
// PLATFORM: SHARED.
export extern "C" function pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8;
export extern "C" function pipeline_dep_ctx_import_path_len(ctx: *u8, idx: i32): i32;
export extern "C" function pipeline_dep_ctx_import_path_copy64(ctx: *u8, idx: i32, dst: *u8): void;
export extern "C" function pipeline_dep_ctx_set_import_path(ctx: *u8, idx: i32, path: *u8, len: i32): void;
export extern "C" function pipeline_dep_ctx_set_module(ctx: *u8, idx: i32, m: *u8): void;
export extern "C" function pipeline_dep_ctx_set_arena(ctx: *u8, idx: i32, a: *u8): void;
export extern "C" function pipeline_dep_ctx_use_asm_backend(ctx: *u8): i32;
export extern "C" function pipeline_dep_ctx_entry_already_parsed(ctx: *u8): i32;
export extern "C" function asm_asm_codegen_ast(module: *u8, arena: *u8, out_buf: *u8, ctx: *u8): i32;
export extern "C" function codegen_codegen_x_ast(module: *u8, arena: *u8, out_buf: *u8, ctx: *u8, dep_index: i32): i32;
export extern "C" function driver_set_current_dep_path_for_codegen(path: *u8): void;
export extern "C" function driver_diagnostic_after_dep_codegen(j: i32, out_len: i32): void;
export extern "C" function driver_diagnostic_codegen_fail(dep_index: i32, is_dep: i32): void;
export extern "C" function driver_skip_codegen_dep_0_get(): i32;
export extern "C" function driver_diagnostic_entry_already(v: i32): void;
export extern "C" function pipeline_codegen_std_dep_link_only(path: *u8): i32;

// wave113 Cap residual for backend_asm_wrapper pure-owned leave (M8-tail thin orch).
// PRODUCT: pipeline_x / typeck_x / seed partial mega; pure only orchestrates.
// PLATFORM: SHARED.
export extern "C" function pipeline_module_hoist_top_level_lets_into_main(module: *u8, arena: *u8): void;
export extern "C" function backend_asm_codegen_ast_seed_mega(module: *u8, arena: *u8, out: *u8, ctx: *u8): i32;
export extern "C" function pipeline_asm_emit_set_elf_ctx(elf_ctx: *u8): void;
export extern "C" function pipeline_asm_emit_set_dep_pipe(ctx: *u8): void;
export extern "C" function pipeline_asm_emit_set_module(module: *u8): void;
export extern "C" function pipeline_asm_emit_set_arena(arena: *u8): void;
export extern "C" function glue_wpo_mono_reset_pending(): void;
export extern "C" function pipeline_elf_label_mod_scope_begin_module(): void;
export extern "C" function pipeline_backend_asm_codegen_ast_to_elf_mega_body_c(module: *u8, arena: *u8, elf_ctx: *u8, ctx: *u8): i32;
export extern "C" function pipeline_asm_emit_wpo_mono_thunks_elf_c(module: *u8, arena: *u8, elf_ctx: *u8, ctx: *u8): i32;

// wave78: xlang_fputs_stdout / driver_asm_fp_is_stdout / driver_asm_fclose_file are pure below.
// g05 prologue harness (same as driver_abi wave22/26): FILE* cast residual for pure .x.
// PLATFORM: SHARED - static inline in g05_try_x_to_o prologue; not a second product authority.
export extern "C" function xlang_driver_fputs_opaque(s: *u8, stream: *u8): i32;
export extern "C" function xlang_driver_stdout_ptr(): *u8;
export extern "C" function xlang_driver_fclose_opaque(stream: *u8): i32;
// wave79: g05 harness - libc realpath char* cast residual (labi_path_io same clash avoidance).
// PLATFORM: SHARED POSIX/APPLE call realpath; non-POSIX harness returns null (seed no-op).
export extern "C" function xlang_driver_realpath_opaque(path: *u8, resolved: *u8): *u8;
// wave75: xlang_import_dep_dir_from_path_impl removed - pure import_dep_dir is full body.
/* wave45: do not export-extern pipeline_debug_trace_named_func_bodies here -
 * pure export function below is the single authority (#[no_mangle]).
 * A prior export extern + export function dual caused call sites to emit the
 * mangled name while the def stayed short -> UNDEF under hybrid. */
/* See implementation. */
/* See implementation. */
/* See implementation. */
export extern "C" function driver_asm_fflush_stdout(): void;
// wave79: xlang_path_try_realpath_inplace is pure export function below (not Cap residual).
// wave67: pipeline_dep_ctx_path_bufs_reset / copy_entry_dir are pure export functions below.
// wave67: pipeline_dep_ctx_set_use_asm_backend is pure thin over G.7 driver authority.
export extern "C" function driver_pipeline_dep_ctx_set_use_asm(ctx: *u8, v: i32): void;
export extern "C" function ast_pipeline_ctx_append_lib_root(ctx: *u8, path: *u8, len: i32): i32;
/* wave61: xlang_preprocess_raw_to_malloc_impl is pure export function below.
 * wave85: define_reset/add/has pure below (G.7 single -D table).
 * wave86: if_stack_* pure below (G.7 fixed i32[32]; not export-extern).
 * Cap residual: preprocess_x_buf (preprocess.x engine): */
export extern "C" function preprocess_x_buf(src: *u8, src_len: i64, out_buf: *u8, out_cap: i32): i32;
// PLATFORM: SHARED - same C ABI as seed cold twin; pure orch owns malloc/copy/diag gates.
// wave74: driver_dep_seed_slots pure orch owns tables (no seed_slots_impl body required under hybrid).
// wave75: xlang_entry_lib_name_from_path_impl / xlang_cstr_typeck_lit /
//   xlang_entry_lib_keyword_lit are pure export functions below (not Cap residual).
// wave70: pipeline_dep_arena/module_slot_set/at are pure export functions below (pure BSS 32×LP64).
// PLATFORM: SHARED - G.7 single authority for pure set_dep_slots / get_dep_*; seed cold twins only.
/* See implementation. */
// wave75: pipeline_asm_debug_enabled_impl removed - pure pipeline_asm_debug_enabled uses getenv.
export extern "C" function diag_report_with_code(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;
export extern "C" function diag_report(file: *u8, line: i32, col: i32, kind: *u8, msg: *u8, detail: *u8): void;
/* See implementation. */

// wave65: pipeline_resolve_path_into_static is pure export function below (not Cap residual).
// wave68: pipeline_entry_dir_get / copy / set_dot are pure export functions below (pure BSS).
// wave69: pipeline_resolved_path_buf_slot is pure export function below (pure BSS 512).
// PLATFORM: SHARED - pure entry_dir + pure resolved_path for into_static orch.
// wave66: pipeline_read_file_stage_prep / commit_prep are pure export functions below.
// wave71: pipeline_rf_stage_prep_clear/set/take are pure export functions below (pure BSS).
// wave72: pipeline_loaded_import_commit_from_owned / data / len_get are pure export functions below.
// PLATFORM: SHARED - pure owns stage BSS + loaded_import ensure policy (single G.7 authority).
// wave72 pure commit: libc memcpy for ensure-buffer fill (same ABI as seed cold twin).
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
// wave64: pipeline_parse_into_bytes is pure export function below (not Cap residual).
// wave65: pipeline_resolve_path_into_static is pure export function below.
// wave66: pipeline_read_file_stage_prep / commit_prep are pure export functions below.
// wave56: xlang_pipeline_run_x_pipeline_large_stack_impl is pure export function below.
// wave58: xlang_pipeline_dep_prerun_parse_skip_typeck_impl is pure export function below.
// wave59: xlang_pipeline_dep_prerun_parse_only_impl is pure export function below.
// wave60: xlang_pipeline_dep_prerun_typeck_only_impl is pure export function below.
// wave93: pipeline_load_and_sync_direct_import_deps_c is pure export function below
//   (same-TU try_bind + realign; Cap residual disk load / sync / typeck merge).
// wave89: pipeline_typeck_dep_prerun_module_c is pure export function below (not Cap residual body).
// wave90: soft_suppress set/get pure below (not export-extern Cap residual).
// wave91: set_dep_ctx / get_dep_ctx pure below (not export-extern Cap residual).
// wave92: layout validate/patch_c pure thin below -> typeck.x (not export-extern Cap residual).
// wave58 pure skip_typeck orch: G.7 driver flags + asm_entry field accessors (runtime_driver_abi).
// PLATFORM: SHARED - same symbols as rt_run_asm_backend pure path.
export extern "C" function driver_check_only_get(): i32;
export extern "C" function driver_check_only_set(v: i32): void;
export extern "C" function driver_x_pipeline_skip_typeck_set(v: i32): void;
export extern "C" function driver_x_pipeline_skip_codegen_set(v: i32): void;
export extern "C" function driver_pipeline_dep_ctx_get_asm_entry_module_only(ctx: *u8): i32;
export extern "C" function driver_pipeline_dep_ctx_set_asm_entry_module_only(ctx: *u8, v: i32): void;
/* See implementation. */
export extern "C" function access(path: *u8, mode: i32): i32;
// wave76: xlang_cstr_offset is pure export function below (not Cap residual).
/* See implementation. */
// wave68: pipeline_entry_dir_copy / set_dot are pure export functions below (not Cap residual).
// wave75: pipeline_set_dep_slots_impl removed - pure pipeline_set_dep_slots uses wave70 slots.
/* See implementation. */
/* See implementation. */
/* See implementation. */
// wave67: pipeline_dep_ctx_set_use_asm_backend is pure export function below (G.7 driver thin).
// wave62: xlang_pipeline_one_ctx_for_dep_prerun_map_impl is pure export function below.
// wave83: pipeline_sizeof_arena / module are pure export functions below (not Cap residual).
// Cap-struct-return parse ok unpack (driver residual):
// PLATFORM: SHARED - same symbols as collect tmp_parse / driver_parse_into_buf_rc pure path.
export extern "C" function driver_parse_into_buf_rc(arena: *u8, module: *u8, data: *u8, len: i32, out_main_idx: *i32): i32;
// wave57: xlang_asm_codegen_elf_o_large_stack_impl is pure export function below.
/* See implementation. */
/* wave46: xlang_module_num_imports / import_path_cstr / ptr+size slots / i32_store
 * are pure export function below (not export-extern Cap residual). */
// wave51: xlang_load_one_direct_import_at + xlang_load_direct_fail_cleanup are pure orch below
// (wave55 pure xlang_load_one_direct_resolve_read_preprocess for resolve+read+preprocess).
// wave50: xlang_collect_deps_transitive_impl / xlang_collect_dep_paths_transitive_impl
// are pure export function below (not export-extern Cap residual).
// wave52: xlang_collect_tmp_parse_and_enqueue is pure export function below.
// wave55: xlang_load_one_direct_resolve_read_preprocess is pure export function below.
// wave82: pipeline_debug_trace_named_func_bodies_impl is pure export function below
//   (not export-extern always-seed). Cap residual: module/ast accessors + getenv +
//   pure pipe_diag_msg_append_* (same TU; product does not link driver_diag_append_*) +
//   diag_report (no reportf).
export extern "C" function pipeline_module_num_funcs(module: *u8): i32;
export extern "C" function pipeline_module_func_name_len_at(module: *u8, fi: i32): i32;
export extern "C" function pipeline_module_func_name_copy64(module: *u8, fi: i32, dst: *u8): void;
export extern "C" function pipeline_module_func_body_ref_at(module: *u8, fi: i32): i32;
// wave115 Cap residual: module func name/extern accessors for selfhost pure leave.
export extern "C" function pipeline_module_func_name_equal_at(module: *u8, fi: i32, name: *u8, name_len: i32): i32;
export extern "C" function pipeline_asm_module_func_is_extern_at(module: *u8, fi: i32): i32;
export extern "C" function ast_ast_block_num_consts(arena: *u8, block_ref: i32): i32;
export extern "C" function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern "C" function ast_ast_block_num_loops(arena: *u8, block_ref: i32): i32;
export extern "C" function ast_ast_block_num_for_loops(arena: *u8, block_ref: i32): i32;
export extern "C" function ast_ast_block_num_if_stmts(arena: *u8, block_ref: i32): i32;
export extern "C" function ast_ast_block_num_regions(arena: *u8, block_ref: i32): i32;
export extern "C" function ast_ast_block_num_stmt_order(arena: *u8, block_ref: i32): i32;
export extern "C" function ast_ast_block_final_expr_ref(arena: *u8, block_ref: i32): i32;
// wave102: POSIX write for asm_diag BODY/FUNC_TRACE lines (stderr fd=2).
// PLATFORM: SHARED - hosted product; freestanding not on this leave path.
export extern "C" function write(fd: i32, buf: *u8, count: i64): i64;
/* wave235 G.7: env via public pure thin link_abi_getenv (wave222 -> _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * Used by pipeline_asm_debug_enabled + pipeline_debug_trace_named_func_bodies_impl.
 * PLATFORM: SHARED - product hybrid pipeline_abi pure uses same face as cold seed. */
export extern "C" function link_abi_getenv(name: *u8): *u8;

/* wave1222: extern declarations for parser_parse_into_init body.
 * These mirror the C authority in parser_gen.c L6318-6331 to ensure the
 * .x strong symbol performs identical AST arena/module state reset.
 * Without this, the empty .x body overrode the C init, causing AST arena
 * state leakage between file checks in directory mode (T001 cascades).
 * PLATFORM: SHARED - all externs are platform-agnostic arena/module reset. */
export extern "C" function ast_ast_arena_init(arena: *u8): void;
export extern "C" function ast_pool_module_reset(module: *u8): void;
export extern "C" function ast_pool_arena_reset(arena: *u8): void;
export extern "C" function parser_onefunc_result_layout_prime(): void;
export extern "C" function parser_onefunc_result_layout_prime_b(): void;
export extern "C" function parser_onefunc_result_layout_prime_c(): void;
export extern "C" function parser_onefunc_result_layout_prime_d(): void;
export extern "C" function parser_onefunc_result_layout_prime_d_b(): void;
export extern "C" function parser_onefunc_result_layout_prime_e(): void;
export extern "C" function parser_onefunc_result_layout_prime_f(): void;
export extern "C" function parser_pipeline_module_reset_parse_counters(module: *u8): void;
export extern "C" function pipeline_parser_set_match_module(module: *u8): void;

/* wave1222: trait registry + generic bound source stash (mirrors C impl_c).
 * Without these, directory-mode check leaks trait/generic state across files,
 * causing the parser to misbehave (e.g. num_funcs drops from 356 to 104 for
 * runtime_pipeline_abi.x when checked after other files).
 * PLATFORM: SHARED - pure delegation to platform-agnostic externs. */
export extern "C" function xlang_trait_reg_reset_c(arena: *u8): void;
export extern "C" function xlang_generic_bound_stash_source_buf_c(data: *u8, len: i32): void;

/* wave1223: extern declarations for pipeline_parse_set_main_from_buf_c body.
 * These mirror the C authority in ast_pool.c L2367-2389 to ensure the
 * .x strong symbol performs identical parse + main_idx set.
 * Without this, the empty .x body (return 0) overrode the C impl, causing
 * pipeline_run_x_pipeline to skip parsing entirely in directory mode
 * (num_funcs=190 instead of 377 for runtime_driver_abi_thin.x).
 * PLATFORM: SHARED - all externs are platform-agnostic parse/diag helpers. */
export extern "C" function pipeline_lint_set_source_buf(data: *u8, len: i32): void;
export extern "C" function pipeline_module_set_main_func_index(module: *u8, idx: i32): void;
export extern "C" function driver_diagnostic_parse_fail(main_idx: i32, num_funcs: i32, arena_num_types: i32): void;
export extern "C" function pipeline_arena_num_types(arena: *u8): i32;
/* wave112: pipeline_parse_into_with_init_buf_scalars is pure export below
 * (parse_typeck_dispatch leave). Cap residual unpack is
 * pipeline_parse_into_with_init_buf_impl_rc (pipeline_parse_orch.c) over
 * Cap-struct-return impl_c / strict_parse_into_init. */

/**
 * Initialize AST arena and module state before parsing a new file.
 *
 * Why: this is the per-file reset point. Without it, arena counters
 *      (num_types/num_exprs/num_blocks/num_funcs) and module parse
 *      counters leak across files in directory check mode, causing
 *      function index drift and cascading T001 "unresolved function"
 *      errors that do not reproduce in single-file mode.
 *      wave1222: also resets trait registry (xlang_trait_reg_reset_c) to
 *      prevent cross-file trait/generic state leak that caused the parser
 *      to truncate function lists (num_funcs 356->106) in directory mode.
 * Contract: must be called before every parser_parse_into_buf call;
 *           zeroes arena counters, resets module fields, primes the
 *           onefunc result layout cache, resets trait registry, and sets
 *           the active match module pointer for parse_match enum tag
 *           resolution.
 * Body mirrors parser_gen.c L6318-6331 (C authority) + trait reset.
 * PLATFORM: SHARED - pure delegation to platform-agnostic externs.
 */
#[no_mangle]
export function parser_parse_into_init(module: *u8, arena: *u8): void {
  unsafe {
    // wave1222: trait registry reset MUST come first; without it, stale trait
    // entries from previous files cause the parser to misbehave in directory
    // mode (num_funcs drops from 358 to 106 for runtime_pipeline_abi.x).
    xlang_trait_reg_reset_c(arena);
    ast_ast_arena_init(arena);
    ast_pool_module_reset(module);
    ast_pool_arena_reset(arena);
    parser_onefunc_result_layout_prime();
    parser_onefunc_result_layout_prime_b();
    parser_onefunc_result_layout_prime_c();
    parser_onefunc_result_layout_prime_d();
    parser_onefunc_result_layout_prime_d_b();
    parser_onefunc_result_layout_prime_e();
    parser_onefunc_result_layout_prime_f();
    parser_pipeline_module_reset_parse_counters(module);
    pipeline_parser_set_match_module(module);
  }
}

/** Exported function `parser_get_module_num_imports`.
 * Implements `parser_get_module_num_imports`.
 * @param module *u8
 * @return i32
 */
#[no_mangle]
export function parser_get_module_num_imports(module: *u8): i32 {
  return 0;
}

/** Exported function `parser_get_module_import_path`.
 * Implements `parser_get_module_import_path`.
 * @param module *u8
 * @param idx i32
 * @param path_buf *u8
 * @return void
 */
#[no_mangle]
export function parser_get_module_import_path(module: *u8, idx: i32, path_buf: *u8): void {
  if (path_buf == 0 as *u8) {
    return;
  }
  unsafe {
    path_buf[0] = 0;
  }
}

/**
 * Copy import path at index i into out[0..64) (NUL-terminated) and return path length.
 * @param module *u8 - opaque AST module; null -> out[0]=0 when out valid, return 0
 * @param i i32 - import index (negative / OOB handled by G.7 path_copy / ImportEntry)
 * @param out *u8 - destination buffer; capacity 64 bytes including NUL; null -> 0
 * @return i32 - byte length of path excluding NUL; 0 on null/missing path
 * wave99 pure Cap residual close: G.7 single product authority for path64 surface.
 * Body ≡ historical parser_gen: pipeline_module_import_path_copy(..., 64) + scan NUL.
 * wave110: path_copy storage is pure ImportEntry map (not Cap residual).
 * PLATFORM: SHARED - parser_gen path64 demoted weak cold twin; product pure hybrid owns.
 */
#[no_mangle]
export function parser_copy_module_import_path64(module: *u8, i: i32, out: *u8): i32 {
  if (out == 0 as *u8) {
    return 0;
  }
  if (module == 0 as *u8) {
    unsafe {
      out[0] = 0;
    }
    return 0;
  }
  // G.7: ImportEntry path bytes live in ast_pool; this surface only copies + measures.
  unsafe {
    pipeline_module_import_path_copy(module, i, out, 64);
  }
  let path_len: i32 = 0;
  while (path_len < 64) {
    let ch: u8 = 0;
    unsafe {
      ch = out[path_len];
    }
    if (ch == 0) {
      break;
    }
    path_len = path_len + 1;
  }
  return path_len;
}

/** Exported function `asm_skip_heavy_set_pipeline_ctx`.
 * Implements `asm_skip_heavy_set_pipeline_ctx`.
 * @param ctx *u8
 * @return void
 */
#[no_mangle]
export function asm_skip_heavy_set_pipeline_ctx(ctx: *u8): void {
}

/** Exported function `pipeline_fill_array_lit_types_for_skipped_typeck`.
 * Implements `pipeline_fill_array_lit_types_for_skipped_typeck`.
 * @param m *u8
 * @param a *u8
 * @return void
 */
#[no_mangle]
export function pipeline_fill_array_lit_types_for_skipped_typeck(m: *u8, a: *u8): void {
}

/**
 * SoA FIELD_ACCESS fill before emit (skip-typeck repair path).
 * 8.3.3 host-cc leave: body is typeck.x `typeck_soa_fill_field_access_for_asm_emit`
 * (typeck_x.o). Historical `pipeline_fill_soa_*` empty surface removed - product
 * calls the typeck authority directly (G.7 single authority).
 * @param m *u8 - Module*
 * @param a *u8 - ASTArena*
 * @return void
 * PLATFORM: SHARED
 */
export extern function typeck_soa_fill_field_access_for_asm_emit(m: *u8, a: *u8): void;

/** Exported function `pipeline_module_fixup_with_arena_stmt_orders`.
 * Implements `pipeline_module_fixup_with_arena_stmt_orders`.
 * @param m *u8
 * @param a *u8
 * @return void
 */
#[no_mangle]
export function pipeline_module_fixup_with_arena_stmt_orders(m: *u8, a: *u8): void {
}

/* wave80: asm_asm_codegen_elf_o is export-extern only (see top of file).
 * Historical pure weak body returned -1 and poisoned same-TU product emit;
 * G.7 product_emit thin below keeps external reloc -> user_asm_seed_bridge strong. */

/**
 * Product asm elf_o emit trampoline: true bridge emit for pure large-stack orch.
 * @param module *u8 - AST module
 * @param arena *u8 - AST arena
 * @param ctx *u8 - PipelineDepCtx
 * @param elf_ctx *u8 - ElfCodegenCtx
 * @param out_buf *u8 - emit out buffer
 * @return i32 - emit status from strong asm_asm_codegen_elf_o (bridge)
 * wave80 pure Cap residual:
 *   thin forward to export-extern asm_asm_codegen_elf_o (no same-TU body);
 *   closes always-seed product_emit leaf; cold twin under seed #ifndef FROM_X.
 * PLATFORM: SHARED - final link must provide strong user_asm_seed_bridge (or equiv).
 */
#[no_mangle]
export function xlang_asm_codegen_elf_o_product_emit(module: *u8, arena: *u8, ctx: *u8, elf_ctx: *u8, out_buf: *u8): i32 {
  unsafe {
    return asm_asm_codegen_elf_o(module, arena, ctx, elf_ctx, out_buf);
  }
  return 0 - 1;
}

/** Parse source buffer into module/arena, then set main_func_index.
 *
 * This is the pipeline entry parse function called by
 * run_x_pipeline_parse_entry_do_parse_c (ast_pool.c L2836) during
 * xlang_pipeline_run_x_pipeline_large_stack. It mirrors the C authority
 * in ast_pool.c L2367-2389 exactly.
 *
 * Why: previously this was an empty stub (return 0) that overrode the C
 * strong symbol via link order. In directory check mode, the pipeline path
 * calls this function to parse each file; the empty stub caused files to
 * be silently skipped (num_funcs=190 instead of 377 for
 * runtime_driver_abi_thin.x), producing T001 "unresolved function call"
 * errors for functions that were never parsed into the module.
 *
 * wave1224: delegate to pipeline_parse_into_with_init_buf_scalars (C authority
 * ast_pool.c L2301-2323) instead of re-implementing the reset locally.
 * The scalars path calls pipeline_strict_parse_into_init (ast_pool.c L1571-1597)
 * which resets MORE module fields than parser_parse_into_init - including
 * pending_allow_padding / pending_soa_struct / pending_cfg_skip /
 * pending_repr_c_struct / pending_repr_compatible_struct / num_module_enums.
 * Without these resets, stale state from a previous file caused the parser
 * to stop at num_funcs=190 in directory mode for runtime_driver_abi_thin.x
 * (single-file mode was unaffected because no prior file polluted the state).
 * Trait/generic stash is already done inside scalars -> impl_c, so we do NOT
 * call xlang_trait_reg_reset_c / xlang_generic_bound_stash_source_buf_c here
 * (calling them twice would be redundant and could double-stash).
 *
 * Steps (match C authority ast_pool.c L2367-2389):
 *   1) null/length gate -> -2
 *   2) pipeline_lint_set_source_buf (anchor L7 unused-private warnings)
 *   3) pipeline_parse_into_with_init_buf_scalars (full reset + parse + scalars)
 *   4) on parse failure (ok != 0): driver_diagnostic_parse_fail + return -2
 *   5) pipeline_module_set_main_func_index(module, main_idx)
 *
 * @param m *u8 - opaque ast_Module pointer; null -> -2
 * @param a *u8 - opaque ast_ASTArena pointer; null -> -2
 * @param d *u8 - source bytes; null -> -2
 * @param len i32 - byte length; <=0 -> -2
 * @return i32 - 0 on success, -2 on parse failure or null input
 * wave1223: full body matching C authority (was empty stub returning 0).
 * wave1224: delegate to scalars to guarantee byte-identical reset semantics.
 * PLATFORM: SHARED - pure delegation to platform-agnostic C authority. */
#[no_mangle]
export function pipeline_parse_set_main_from_buf_c(m: *u8, a: *u8, d: *u8, len: i32): i32 {
  if (m == 0 as *u8) { return 0 - 2; }
  if (a == 0 as *u8) { return 0 - 2; }
  if (d == 0 as *u8) { return 0 - 2; }
  if (len <= 0) { return 0 - 2; }
  unsafe {
    // L7 / LSP: anchor unused private function warnings to definition source.
    pipeline_lint_set_source_buf(d, len);
    // Delegate to C authority scalars: performs full arena/module reset via
    // pipeline_strict_parse_into_init + trait/generic stash + parser_parse_into_buf
    // and returns ok / main_idx via out parameters.
    let ok: i32 = 0;
    let main_idx: i32 = 0 - 1;
    pipeline_parse_into_with_init_buf_scalars(a, m, d, len, &ok, &main_idx);
    if (ok != 0) {
      driver_diagnostic_parse_fail(main_idx, pipeline_module_num_funcs(m), pipeline_arena_num_types(a));
      return 0 - 2;
    }
    pipeline_module_set_main_func_index(m, main_idx);
    return 0;
  }
  return 0 - 2;
}

/**
 * Reset the pipeline "diag already emitted" sticky flag to 0.
 * @return void
 * wave73: pure G.7 pipeline_diag_emitted_flag_slot (pure BSS).
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_diag_emitted_reset(): void {
  unsafe {
    let p: *i32 = pipeline_diag_emitted_flag_slot();
    p[0] = 0;
  }
}

/**
 * Set the pipeline "diag already emitted" sticky flag to 1.
 * @return void
 * wave73: pure G.7 pipeline_diag_emitted_flag_slot (pure BSS).
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_diag_emitted_note(): void {
  unsafe {
    let p: *i32 = pipeline_diag_emitted_flag_slot();
    p[0] = 1;
  }
}

/**
 * Read the pipeline "diag already emitted" sticky flag (normalize to 0/1).
 * @return i32 - 1 when any prior note was recorded; 0 when clear
 * wave73: pure G.7 pipeline_diag_emitted_flag_slot (pure BSS).
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_diag_emitted_get(): i32 {
  unsafe {
    let p: *i32 = pipeline_diag_emitted_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `get_ndep`.
 * Query helper `get_ndep`.
 * @return i32
 */
#[no_mangle]
export function get_ndep(): i32 {
  unsafe {
    let p: *i32 = typeck_ndep_slot();
    let r: i32 = p[0];
    return r;
  }
  return 0;
}

/* ---- G-02f-34：set_ndep + dep_seeded get/set ---- */

// pipeline_set_ndep: see function docblock below.
/** Exported function `pipeline_set_ndep`.
 * Implements `pipeline_set_ndep`.
 * @param n i32
 * @return void
 */
#[no_mangle]
export function pipeline_set_ndep(n: i32): void {
  typeck_ndep_store(n);
}

/** Exported function `driver_dep_seeded_get`.
 * Implements `driver_dep_seeded_get`.
 * @param i i32
 * @return i32
 */
#[no_mangle]
export function driver_dep_seeded_get(i: i32): i32 {
  if (i < 0) {
    return 0;
  }
  if (i >= 32) {
    return 0;
  }
  unsafe {
    let p: *i32 = driver_dep_seeded_slot(i);
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `driver_dep_seeded_set`.
 * Implements `driver_dep_seeded_set`.
 * @param i i32
 * @param v i32
 * @return void
 */
#[no_mangle]
export function driver_dep_seeded_set(i: i32, v: i32): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  unsafe {
    let p: *i32 = driver_dep_seeded_slot(i);
    p[0] = v;
  }
}

/** Exported function `typeck_driver_dep_seeded_get`.
 * Implements `typeck_driver_dep_seeded_get`.
 * @param i i32
 * @return i32
 */
#[no_mangle]
export function typeck_driver_dep_seeded_get(i: i32): i32 {
  return driver_dep_seeded_get(i);
}

/* See implementation. */

#[no_mangle]
export function get_dep_module(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  unsafe {
    let n: i32 = get_ndep();
    if (i >= n) {
      return 0 as *u8;
    }
    let r: *u8 = typeck_dep_module_get(i);
    return r;
  }
  return 0 as *u8;
}

/** Exported function `get_dep_arena`.
 * Query helper `get_dep_arena`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function get_dep_arena(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  unsafe {
    let n: i32 = get_ndep();
    if (i >= n) {
      return 0 as *u8;
    }
    let r: *u8 = typeck_dep_arena_get(i);
    return r;
  }
  return 0 as *u8;
}

/** Exported function `typeck_get_dep_module`.
 * Implements `typeck_get_dep_module`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function typeck_get_dep_module(i: i32): *u8 {
  return get_dep_module(i);
}

/** Exported function `typeck_get_dep_arena`.
 * Implements `typeck_get_dep_arena`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function typeck_get_dep_arena(i: i32): *u8 {
  return get_dep_arena(i);
}

/** Exported function `pipeline_set_dep`.
 * Implements `pipeline_set_dep`.
 * @param i i32
 * @param mod *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_set_dep(i: i32, mod: *u8, arena: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  unsafe {
    typeck_dep_module_set_impl(i, mod);
    typeck_dep_arena_set_impl(i, arena);
  }
}

/* See implementation. */

#[no_mangle]
export function driver_dep_publish_slot(i: i32, arena: *u8, module: *u8, import_path: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  unsafe {
    driver_dep_arena_ptr_set_impl(i, arena);
    driver_dep_module_ptr_set_impl(i, module);
    driver_dep_seeded_set(i, 1);
    /* See implementation. */
    driver_dep_path_registry_set(i, import_path);
  }
}

/** Exported function `typeck_driver_dep_module_buf`.
 * Implements `typeck_driver_dep_module_buf`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function typeck_driver_dep_module_buf(i: i32): *u8 {
  unsafe {
    let r: *u8 = driver_dep_module_buf(i);
    return r;
  }
  return 0 as *u8;
}

/** Exported function `typeck_driver_dep_arena_buf`.
 * Implements `typeck_driver_dep_arena_buf`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function typeck_driver_dep_arena_buf(i: i32): *u8 {
  unsafe {
    let r: *u8 = driver_dep_arena_buf(i);
    return r;
  }
  return 0 as *u8;
}

/* See implementation. */

/* See implementation. */
#[no_mangle]
export function xlang_cstr_ends_with_dot_x(s: *u8): i32 {
  if (s == 0 as *u8) {
    return 0;
  }
  unsafe {
    let n: i64 = 0;
    while (s[n] != 0) {
      n = n + 1;
    }
    if (n < 2) {
      return 0;
    }
    /* '.' == 46, 'x' == 120 */
    if (s[n - 2] != 46) {
      return 0;
    }
    if (s[n - 1] != 120) {
      return 0;
    }
    return 1;
  }
  return 0;
}

/* See implementation. */
#[no_mangle]
export function xlang_asm_out_buf_is_object_magic(data: *u8): i32 {
  if (data == 0 as *u8) {
    return 0;
  }
  unsafe {
    let b0: u8 = data[0];
    let b1: u8 = data[1];
    let b2: u8 = data[2];
    let b3: u8 = data[3];
    /* MH_MAGIC_64 LE: cf fa ed fe */
    if (b0 == 207) {
      if (b1 == 250) {
        if (b2 == 237) {
          if (b3 == 254) {
            return 1;
          }
        }
      }
    }
    /* MH_CIGAM_64: fe ed fa cf */
    if (b0 == 254) {
      if (b1 == 237) {
        if (b2 == 250) {
          if (b3 == 207) {
            return 1;
          }
        }
      }
    }
    /* ELF: 7f 'E' 'L' 'F' */
    if (b0 == 127) {
      if (b1 == 69) {
        if (b2 == 76) {
          if (b3 == 70) {
            return 1;
          }
        }
      }
    }
    return 0;
  }
  return 0;
}

/** Exported function `xlang_import_path_is_file_path`.
 * Implements `xlang_import_path_is_file_path`.
 * @param import_path *u8
 * @return i32
 */
#[no_mangle]
export function xlang_import_path_is_file_path(import_path: *u8): i32 {
  if (import_path == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (import_path[0] == 0) {
      return 0;
    }
    /* '/' or '.' */
    if (import_path[0] == 47) {
      return 1;
    }
    if (import_path[0] == 46) {
      return 1;
    }
    if (strchr(import_path, 47) != 0 as *u8) {
      return 1;
    }
    if (xlang_cstr_ends_with_dot_x(import_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `xlang_asm_user_std_dep_skip_x_typeck`.
 * Implements `xlang_asm_user_std_dep_skip_x_typeck`.
 * @param dep_path *u8
 * @return i32
 */
#[no_mangle]
export function xlang_asm_user_std_dep_skip_x_typeck(dep_path: *u8): i32 {
  if (dep_path == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (dep_path[0] == 0) {
      return 0;
    }
    if (pipeline_asm_user_dep_skip_x_typeck(dep_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `xlang_asm_user_std_net_dep_path`.
 * Implements `xlang_asm_user_std_net_dep_path`.
 * @param dep_path *u8
 * @return i32
 */
#[no_mangle]
export function xlang_asm_user_std_net_dep_path(dep_path: *u8): i32 {
  if (dep_path == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (dep_path[0] == 0) {
      return 0;
    }
    if (pipeline_asm_user_std_net_dep_path(dep_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `xlang_asm_user_std_io_driver_dep_path`.
 * Implements `xlang_asm_user_std_io_driver_dep_path`.
 * @param dep_path *u8
 * @return i32
 */
#[no_mangle]
export function xlang_asm_user_std_io_driver_dep_path(dep_path: *u8): i32 {
  if (dep_path == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (dep_path[0] == 0) {
      return 0;
    }
    if (pipeline_codegen_path_is_std_io_driver_bytes(dep_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `xlang_asm_user_dep_parse_skip_typeck_path`.
 * Implements `xlang_asm_user_dep_parse_skip_typeck_path`.
 * @param dep_path *u8
 * @return i32
 */
#[no_mangle]
export function xlang_asm_user_dep_parse_skip_typeck_path(dep_path: *u8): i32 {
  unsafe {
    if (xlang_asm_user_std_net_dep_path(dep_path) != 0) {
      return 1;
    }
    if (xlang_asm_user_std_io_driver_dep_path(dep_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `xlang_asm_out_buf_is_object`.
 * Implements `xlang_asm_out_buf_is_object`.
 * @param data *u8
 * @param len i64
 * @return i32
 */
#[no_mangle]
export function xlang_asm_out_buf_is_object(data: *u8, len: i64): i32 {
  if (data == 0 as *u8) {
    return 0;
  }
  if (len < 4) {
    return 0;
  }
  unsafe {
    return xlang_asm_out_buf_is_object_magic(data);
  }
  return 0;
}

/* See implementation. */

#[no_mangle]
export function xlang_dep_prerun_entry_dir(main_entry_dir: *u8, lib_roots: *u8, n_lib_roots: i32): *u8 {
  unsafe {
    if (n_lib_roots <= 0) {
      return main_entry_dir;
    }
    return xlang_dep_prerun_entry_dir_pick(main_entry_dir, lib_roots, n_lib_roots);
  }
  return main_entry_dir;
}

/** Exported function `xlang_find_loaded_import_index`.
 * Implements `xlang_find_loaded_import_index`.
 * @param import_path *u8
 * @param all_paths *u8
 * @param n_all i32
 * @return i32
 */
#[no_mangle]
export function xlang_find_loaded_import_index(import_path: *u8, all_paths: *u8, n_all: i32): i32 {
  if (import_path == 0 as *u8) {
    return -1;
  }
  if (all_paths == 0 as *u8) {
    return -1;
  }
  if (n_all <= 0) {
    return -1;
  }
  return xlang_find_loaded_import_index_scan(import_path, all_paths, n_all);
}

/** Exported function `xlang_merge_deps_path_already_out`.
 * Read path helper `xlang_merge_deps_path_already_out`.
 * @param path *u8
 * @param out_paths *u8
 * @param n_out i32
 * @return i32
 */
#[no_mangle]
export function xlang_merge_deps_path_already_out(path: *u8, out_paths: *u8, n_out: i32): i32 {
  if (path == 0 as *u8) {
    return 0;
  }
  if (out_paths == 0 as *u8) {
    return 0;
  }
  if (n_out <= 0) {
    return 0;
  }
  return xlang_merge_deps_path_already_out_scan(path, out_paths, n_out);
}

/**
 * Write NUL-terminated C string s to host stdout via fputs.
 * @param s *u8 - C string; null -> no-op
 * @return void
 * wave78 pure: G.7 g05 xlang_driver_stdout_ptr + xlang_driver_fputs_opaque (FILE* cast residual
 * lives in g05_try_x_to_o prologue; .x never names FILE*).
 * Closes always-seed Cap soft residual for emit_pipeline_glue_include.
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function xlang_fputs_stdout(s: *u8): void {
  if (s == 0 as *u8) {
    return;
  }
  unsafe {
    let so: *u8 = xlang_driver_stdout_ptr();
    if (so != 0 as *u8) {
      xlang_driver_fputs_opaque(s, so);
    }
  }
}

// xlang_emit_pipeline_glue_include: see function docblock below.
/**
 * Emit the pipeline_glue.c include line to stdout (codegen glue surface).
 * @return void
 * G.7 pure xlang_fputs_stdout (wave78) owns stdout write.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_emit_pipeline_glue_include(): void {
  // "\n#include \"pipeline_glue.c\"\n"
  let s: u8[32] = [];
  s[0]=10;s[1]=35;s[2]=105;s[3]=110;s[4]=99;s[5]=108;s[6]=117;s[7]=100;
  s[8]=101;s[9]=32;s[10]=34;s[11]=112;s[12]=105;s[13]=112;s[14]=101;s[15]=108;
  s[16]=105;s[17]=110;s[18]=101;s[19]=95;s[20]=103;s[21]=108;s[22]=117;s[23]=101;
  s[24]=46;s[25]=99;s[26]=34;s[27]=10;s[28]=0;
  unsafe {
    xlang_fputs_stdout(&s[0]);
  }
}

// xlang_import_dep_dir_from_path: see function docblock below.
/** Exported function `xlang_import_dep_dir_from_path`.
 * Implements `xlang_import_dep_dir_from_path`.
 * @param path *u8
 * @param dep_dir *u8
 * @param dep_dir_size i64
 * @return i32
 */
#[no_mangle]
export function xlang_import_dep_dir_from_path(path: *u8, dep_dir: *u8, dep_dir_size: i64): i32 {
  if (path == 0 as *u8) { return 0 - 1; }
  if (dep_dir == 0 as *u8) { return 0 - 1; }
  if (dep_dir_size == 0) { return 0 - 1; }
  unsafe {
    let n: i64 = 0;
    while (n < 4096) {
      if (path[n] == 0) { break; }
      n = n + 1;
    }
    let last_slash: i64 = 0 - 1;
    let i: i64 = 0;
    while (i < n) {
      // '/'
      if (path[i] == 47) { last_slash = i; }
      i = i + 1;
    }
    if (last_slash < 0) {
      if (dep_dir_size < 2) { return 0 - 1; }
      dep_dir[0] = 46; // '.'
      dep_dir[1] = 0;
      return 0;
    }
    let dlen: i64 = last_slash;
    if (dlen >= dep_dir_size) { return 0 - 1; }
    let j: i64 = 0;
    while (j < dlen) {
      dep_dir[j] = path[j];
      j = j + 1;
    }
    dep_dir[dlen] = 0;
    return 0;
  }
  return 0 - 1;
}

/* See implementation. */

#[no_mangle]
export function pipeline_debug_trace_body_x_mega_pre_reset(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_pre_reset", module, arena);
  }
}

/** Exported function `pipeline_debug_trace_body_x_mega_post_reset`.
 * Implements `pipeline_debug_trace_body_x_mega_post_reset`.
 * @param module *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_debug_trace_body_x_mega_post_reset(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_post_reset", module, arena);
  }
}

/** Exported function `pipeline_debug_trace_body_x_mega_post_params`.
 * Implements `pipeline_debug_trace_body_x_mega_post_params`.
 * @param module *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_debug_trace_body_x_mega_post_params(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_post_params", module, arena);
  }
}

/** Exported function `pipeline_debug_trace_body_x_mega_post_frame`.
 * Implements `pipeline_debug_trace_body_x_mega_post_frame`.
 * @param module *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_debug_trace_body_x_mega_post_frame(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_post_frame", module, arena);
  }
}

/** Exported function `pipeline_debug_trace_body_x_mega_post_locals`.
 * Implements `pipeline_debug_trace_body_x_mega_post_locals`.
 * @param module *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_debug_trace_body_x_mega_post_locals(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_post_locals", module, arena);
  }
}

/** Exported function `pipeline_debug_trace_body_x_mega_pre_emit`.
 * Implements `pipeline_debug_trace_body_x_mega_pre_emit`.
 * @param module *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_debug_trace_body_x_mega_pre_emit(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_pre_emit", module, arena);
  }
}

// driver_typeck_dep_sidecar_clear: see function docblock below.
/** Exported function `driver_typeck_dep_sidecar_clear`.
 * Implements `driver_typeck_dep_sidecar_clear`.
 * @return void
 */
#[no_mangle]
export function driver_typeck_dep_sidecar_clear(): void {
  typeck_ndep_store(0);
  let i: i32 = 0;
  while (i < 32) {
    typeck_dep_module_set(i, 0 as *u8);
    typeck_dep_arena_set(i, 0 as *u8);
    i = i + 1;
  }
}

// driver_dep_seeded_clear_slots: see function docblock below.
/** Exported function `driver_dep_seeded_clear_slots`.
 * Implements `driver_dep_seeded_clear_slots`.
 * @return void
 */
#[no_mangle]
export function driver_dep_seeded_clear_slots(): void {
  let i: i32 = 0;
  while (i < 32) {
    driver_dep_seeded_set(i, 0);
    unsafe {
      driver_dep_path_registry_set(i, 0 as *u8);
      driver_dep_arena_ptr_set(i, 0 as *u8);
      driver_dep_module_ptr_set(i, 0 as *u8);
    }
    i = i + 1;
  }
}

// driver_dep_seeded_clear_all: see function docblock below.
/** Exported function `driver_dep_seeded_clear_all`.
 * Implements `driver_dep_seeded_clear_all`.
 * @return void
 */
#[no_mangle]
export function driver_dep_seeded_clear_all(): void {
  driver_dep_seeded_clear_slots();
  driver_typeck_dep_sidecar_clear();
}

// xlang_get_entry_dir: see function docblock below.
/** Exported function `xlang_get_entry_dir`.
 * Implements `xlang_get_entry_dir`.
 * @param input_path *u8
 * @param entry_dir *u8
 * @param size i64
 * @return void
 */
#[no_mangle]
export function xlang_get_entry_dir(input_path: *u8, entry_dir: *u8, size: i64): void {
  if (entry_dir == 0 as *u8) {
    return;
  }
  if (size == 0) {
    return;
  }
  if (input_path == 0 as *u8) {
    unsafe {
      entry_dir[0] = 0;
    }
    return;
  }
  unsafe {
    let last: i32 = 0 - 1;
    let i: i32 = 0;
    while (i < 65536) {
      if (input_path[i] == 0) {
        break;
      }
      if (input_path[i] == 47) {
        last = i;
      }
      i = i + 1;
    }
    if (last < 0) {
      if (size >= 2) {
        entry_dir[0] = 46;
        entry_dir[1] = 0;
      } else {
        entry_dir[0] = 0;
      }
      return;
    }
    let len: i32 = last;
    let cap: i32 = size as i32;
    if (cap <= 0) {
      return;
    }
    if (len >= cap) {
      len = cap - 1;
    }
    let k: i32 = 0;
    while (k < len) {
      entry_dir[k] = input_path[k];
      k = k + 1;
    }
    entry_dir[len] = 0;
  }
}

/**
 * Return 1 if opaque stream fp is host stdout, else 0.
 * @param fp *u8 - opaque FILE* as *u8; null -> 0
 * @return i32 - 1 when fp equals stdout, else 0
 * wave78 pure: G.7 g05 xlang_driver_stdout_ptr identity compare (no FILE* in .x).
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function driver_asm_fp_is_stdout(fp: *u8): i32 {
  if (fp == 0 as *u8) {
    return 0;
  }
  unsafe {
    let so: *u8 = xlang_driver_stdout_ptr();
    if (fp == so) {
      return 1;
    }
  }
  return 0;
}

/**
 * fclose an opaque non-stdout stream (null-safe).
 * @param fp *u8 - opaque FILE* as *u8; null -> no-op
 * @return void
 * wave78 pure: G.7 g05 xlang_driver_fclose_opaque (FILE* cast residual in g05 prologue).
 * Does not special-case stdout - callers use driver_asm_fclose_asm_out for that.
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function driver_asm_fclose_file(fp: *u8): void {
  if (fp == 0 as *u8) {
    return;
  }
  unsafe {
    xlang_driver_fclose_opaque(fp);
  }
}

// driver_asm_fclose_asm_out: see function docblock below.
/**
 * Close asm output stream: fflush stdout when fp is null/stdout; else fclose.
 * @param fp *u8 - opaque FILE* as *u8; null or stdout -> fflush only
 * @return void
 * G.7 pure driver_asm_fp_is_stdout + driver_asm_fclose_file (wave78) + residual fflush.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function driver_asm_fclose_asm_out(fp: *u8): void {
  unsafe {
    if (fp == 0 as *u8) {
      driver_asm_fflush_stdout();
      return;
    }
    if (driver_asm_fp_is_stdout(fp) != 0) {
      driver_asm_fflush_stdout();
      return;
    }
    driver_asm_fclose_file(fp);
  }
}

/* See implementation. */

// G-02f-229：lib_root + import（'.'->'/'）+ ".x"
/** Exported function `xlang_import_path_to_file_path`.
 * Implements `xlang_import_path_to_file_path`.
 * @param lib_root *u8
 * @param import_path *u8
 * @param path *u8
 * @param path_size i64
 * @return void
 */
#[no_mangle]
export function xlang_import_path_to_file_path(lib_root: *u8, import_path: *u8, path: *u8, path_size: i64): void {
  if (path == 0 as *u8) {
    return;
  }
  if (path_size == 0) {
    return;
  }
  unsafe {
    let cap: i32 = path_size as i32;
    if (cap <= 0) {
      return;
    }
    let r: *u8 = lib_root;
    if (r == 0 as *u8) {
      // "."
      r = 0 as *u8;
    } else {
      if (r[0] == 0) {
        r = 0 as *u8;
      }
    }
    let off: i32 = 0;
    if (r == 0 as *u8) {
      if (off + 1 < cap) {
        path[off] = 46;
        off = off + 1;
      }
    } else {
      let ri: i32 = 0;
      while (ri < 4096) {
        if (r[ri] == 0) {
          break;
        }
        if (off + 1 >= cap) {
          break;
        }
        path[off] = r[ri];
        off = off + 1;
        ri = ri + 1;
      }
    }
    if (off + 1 < cap) {
      path[off] = 47;
      off = off + 1;
    }
    if (import_path != 0 as *u8) {
      let s: i32 = 0;
      while (s < 4096) {
        if (import_path[s] == 0) {
          break;
        }
        if (off + 1 >= cap) {
          break;
        }
        let ch: u8 = import_path[s];
        if (ch == 46) {
          path[off] = 47;
        } else {
          path[off] = ch;
        }
        off = off + 1;
        s = s + 1;
      }
    }
    // ".x"
    if (off + 2 < cap) {
      path[off] = 46;
      path[off + 1] = 120;
      path[off + 2] = 0;
    } else {
      if (off < cap) {
        path[off] = 0;
      } else {
        if (cap > 0) {
          path[cap - 1] = 0;
        }
      }
    }
  }
}

// pipe_cstr_join_slash: see function docblock below.
/** Exported function `pipe_cstr_join_slash`.
 * Implements `pipe_cstr_join_slash`.
 * @param dst *u8
 * @param cap i32
 * @param a *u8
 * @param b *u8
 * @return void
 */
export function pipe_cstr_join_slash(dst: *u8, cap: i32, a: *u8, b: *u8): void {
  if (dst == 0 as *u8) { return; }
  if (cap <= 0) { return; }
  let off: i32 = 0;
  unsafe {
    if (a != 0 as *u8) {
      let i: i32 = 0;
      while (i < 4096) {
        if (a[i] == 0) { break; }
        if (off + 1 >= cap) { break; }
        dst[off] = a[i];
        off = off + 1;
        i = i + 1;
      }
    }
    if (off + 1 < cap) {
      dst[off] = 47;
      off = off + 1;
    }
    if (b != 0 as *u8) {
      let j: i32 = 0;
      while (j < 4096) {
        if (b[j] == 0) { break; }
        if (off + 1 >= cap) { break; }
        dst[off] = b[j];
        off = off + 1;
        j = j + 1;
      }
    }
    if (off < cap) {
      dst[off] = 0;
    } else {
      dst[cap - 1] = 0;
    }
  }
}

/**
 * Best-effort realpath into path in place; on failure leave path unchanged.
 * @param path *u8 - mutable C string buffer; null -> no-op
 * @param path_size i64 - buffer capacity including trailing NUL; 0 -> no-op
 * @return void
 * wave79 pure Cap residual orch:
 *   stack resolved[1024] (matches seed char resolved[1024]);
 *   G.7 g05 xlang_driver_realpath_opaque (libc realpath char* cast residual;
 *   non-POSIX host returns null -> no-op, matches seed #else);
 *   success -> G.7 pipe_cstr_copy into path with path_size cap (snprintf "%s" equiv).
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function xlang_path_try_realpath_inplace(path: *u8, path_size: i64): void {
  if (path == 0 as *u8) {
    return;
  }
  if (path_size == 0) {
    return;
  }
  unsafe {
    // Match seed stack resolved[1024]; PATH_MAX on gold Linux is larger but seed pin is 1024.
    let resolved: u8[1024] = [];
    let r: *u8 = xlang_driver_realpath_opaque(path, &resolved[0]);
    if (r != 0 as *u8) {
      let cap: i32 = path_size as i32;
      if (cap > 0) {
        pipe_cstr_copy(path, cap, r);
      }
    }
  }
}

// xlang_resolve_file_import_path: see function docblock below.
/** Exported function `xlang_resolve_file_import_path`.
 * Implements `xlang_resolve_file_import_path`.
 * @param entry_dir *u8
 * @param import_path *u8
 * @param path *u8
 * @param path_size i64
 * @return void
 * G.7 pure xlang_path_try_realpath_inplace (wave79) owns realpath-in-place after join.
 */
#[no_mangle]
export function xlang_resolve_file_import_path(entry_dir: *u8, import_path: *u8, path: *u8, path_size: i64): void {
  if (path == 0 as *u8) {
    return;
  }
  if (path_size == 0) {
    return;
  }
  if (import_path == 0 as *u8) {
    unsafe {
      path[0] = 0;
    }
    return;
  }
  let cap: i32 = path_size as i32;
  if (cap <= 0) {
    return;
  }
  unsafe {
    // absolute
    if (import_path[0] == 47) {
      pipe_cstr_copy(path, cap, import_path);
    } else {
      if (entry_dir != 0 as *u8) {
        if (entry_dir[0] != 0) {
          pipe_cstr_join_slash(path, cap, entry_dir, import_path);
        } else {
          pipe_cstr_copy(path, cap, import_path);
        }
      } else {
        pipe_cstr_copy(path, cap, import_path);
      }
    }
    xlang_path_try_realpath_inplace(path, path_size);
  }
}

// driver_dep_slot_for_path_scan: see function docblock below.
/** Exported function `driver_dep_slot_for_path_scan`.
 * Implements `driver_dep_slot_for_path_scan`.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function driver_dep_slot_for_path_scan(path: *u8): i32 {
  if (path == 0 as *u8) { return 0 - 1; }
  unsafe {
    let i: i32 = 0;
    while (i < 32) {
      let reg: *u8 = driver_dep_path_registry_at(i);
      if (reg != 0 as *u8) {
        if (pipe_cstr_eq(reg, path) != 0) { return i; }
      }
      i = i + 1;
    }
  }
  return 0 - 1;
}

/** Exported function `driver_dep_slot_for_path`.
 * Implements `driver_dep_slot_for_path`.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function driver_dep_slot_for_path(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  return driver_dep_slot_for_path_scan(path);
}

/* See implementation. */

/**
 * Preprocess raw source into an owned NUL-terminated malloc buffer.
 * @param raw *u8 - source bytes; null only allowed when raw_len == 0
 * @param raw_len i64 - byte count; must fit XLANG_PIPELINE_CTX_BUF_SIZE (4MiB)
 * @param out_src *u8 - char** base as bytes; slot 0 set to owned prep (or null on fail)
 * @param out_src_len *u8 - size_t* base as bytes; slot 0 set to output length (0 on fail)
 * @param path_diag *u8 - path for preprocess diags; may be null
 * @param defines *u8 - const char** define names base; may be null when ndefines == 0
 * @param ndefines i32 - define count; < 0 rejected by thin gate
 * @param emit_diag i32 - non-zero -> emit PP/XP diags on failure
 * @return i32 - 0 success; -1 fail (OOM / oversized / preprocess error / unclosed #if)
 * wave61 pure Cap residual orch; wave85 pure owns -D define table;
 * wave86 pure owns #if stack:
 *   G.7 pure preprocess_define_reset / preprocess_define_add (same-TU pure BSS);
 *   G.7 pure preprocess_if_stack_len (same-TU fixed stack; no GrowVec);
 *   G.7 pure cross-TU preprocess_x_buf (preprocess.x engine; wave88 eval pure);
 *   G.7 pure preprocess_eval_condition_c (simple) + Cap residual cfg_eval_expr_c (complex);
 *   G.7 pure pipeline_diag_preprocess_* (no va_list reportf);
 *   G.7 xlang_ptr_slot_set / xlang_size_slot_set for out slots (char** / size_t*);
 *   oversized raw -> pure pipeline_diag_preprocess_fail (fixed msg; seed reportf cold-only).
 * PLATFORM: SHARED - same control flow as historical seed _impl.
 */
#[no_mangle]
export function xlang_preprocess_raw_to_malloc_impl(raw: *u8, raw_len: i64, out_src: *u8, out_src_len: *u8, path_diag: *u8, defines: *u8, ndefines: i32, emit_diag: i32): i32 {
  // Clear outs first (same as seed).
  if (out_src != 0 as *u8) {
    xlang_ptr_slot_set(out_src, 0, 0 as *u8);
  }
  if (out_src_len != 0 as *u8) {
    xlang_size_slot_set(out_src_len, 0, 0);
  }
  // XLANG_PIPELINE_CTX_BUF_SIZE - fixed 4MiB pipeline ctx buffer (runtime_pipeline_abi.h).
  let buf_cap: i32 = 4194304;
  let buf_cap_i64: i64 = buf_cap as i64;
  if (raw_len > buf_cap_i64) {
    if (emit_diag != 0) {
      // Cold twin uses reportf with sizes; pure keeps fixed PP002 fail (no va_list).
      pipeline_diag_preprocess_fail(path_diag);
    }
    return 0 - 1;
  }
  let scratch: *u8 = 0 as *u8;
  unsafe {
    scratch = malloc(buf_cap as usize);
  }
  if (scratch == 0 as *u8) {
    if (emit_diag != 0) {
      // "scratch buffer"
      let what: u8[16] = [];
      what[0] = 115; what[1] = 99; what[2] = 114; what[3] = 97; what[4] = 116;
      what[5] = 99; what[6] = 104; what[7] = 32; what[8] = 98; what[9] = 117;
      what[10] = 102; what[11] = 102; what[12] = 101; what[13] = 114; what[14] = 0;
      pipeline_diag_preprocess_alloc_fail(path_diag, &what[0]);
    }
    return 0 - 1;
  }
  // Reset define table then add caller defines (char** via ptr slots).
  unsafe {
    preprocess_define_reset();
  }
  let di: i32 = 0;
  while (di < ndefines) {
    if (defines != 0 as *u8) {
      let dname: *u8 = xlang_ptr_slot_get(defines, di);
      if (dname != 0 as *u8) {
        unsafe {
          preprocess_define_add(dname);
        }
      }
    }
    di = di + 1;
  }
  let n: i32 = 0;
  unsafe {
    // Authority preprocess engine; raw may be null only when raw_len == 0 (thin gate).
    n = preprocess_x_buf(raw, raw_len, scratch, buf_cap);
  }
  if (n < 0) {
    unsafe {
      free(scratch);
    }
    if (emit_diag != 0) {
      // Directive-level negative codes (-2..-7) prefer over unclosed-if (stack may be non-empty).
      if (n <= (0 - 2)) {
        pipeline_diag_preprocess_directive_code(path_diag, n);
      } else {
        let stack_n: i32 = 0;
        unsafe {
          stack_n = preprocess_if_stack_len();
        }
        if (stack_n != 0) {
          pipeline_diag_preprocess_unclosed_if(path_diag);
        } else {
          pipeline_diag_preprocess_fail(path_diag);
        }
      }
    }
    return 0 - 1;
  }
  let stack_after: i32 = 0;
  unsafe {
    stack_after = preprocess_if_stack_len();
  }
  if (stack_after != 0) {
    unsafe {
      free(scratch);
    }
    if (emit_diag != 0) {
      pipeline_diag_preprocess_unclosed_if(path_diag);
    }
    return 0 - 1;
  }
  // Owned output: n bytes + trailing NUL (byte copy; no memcpy short name).
  let dup: *u8 = 0 as *u8;
  unsafe {
    dup = malloc((n + 1) as usize);
  }
  if (dup == 0 as *u8) {
    unsafe {
      free(scratch);
    }
    if (emit_diag != 0) {
      // "output buffer"
      let what2: u8[16] = [];
      what2[0] = 111; what2[1] = 117; what2[2] = 116; what2[3] = 112; what2[4] = 117;
      what2[5] = 116; what2[6] = 32; what2[7] = 98; what2[8] = 117; what2[9] = 102;
      what2[10] = 102; what2[11] = 101; what2[12] = 114; what2[13] = 0;
      pipeline_diag_preprocess_alloc_fail(path_diag, &what2[0]);
    }
    return 0 - 1;
  }
  let i: i32 = 0;
  unsafe {
    while (i < n) {
      dup[i] = scratch[i];
      i = i + 1;
    }
    dup[n] = 0;
    free(scratch);
  }
  if (out_src != 0 as *u8) {
    xlang_ptr_slot_set(out_src, 0, dup);
  }
  if (out_src_len != 0 as *u8) {
    xlang_size_slot_set(out_src_len, 0, n as i64);
  }
  return 0;
}

/**
 * Thin gate for preprocess raw->malloc (null/oversized rejects; emit_diag fixed 1).
 * @param raw *u8 - source bytes; null with raw_len > 0 -> -1
 * @param raw_len i64 - byte count; < 0 -> -1
 * @param out_src *u8 - char** out base as bytes
 * @param out_src_len *u8 - size_t* out base as bytes
 * @param path_diag *u8 - path for diags
 * @param defines *u8 - const char** define table
 * @param ndefines i32 - define count; < 0 -> -1
 * @return i32 - 0 success; -1 fail
 * wave61: body in pure xlang_preprocess_raw_to_malloc_impl.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_preprocess_raw_to_malloc(raw: *u8, raw_len: i64, out_src: *u8, out_src_len: *u8, path_diag: *u8, defines: *u8, ndefines: i32): i32 {
  if (raw_len < 0) {
    return 0 - 1;
  }
  if (raw == 0 as *u8) {
    if (raw_len > 0) {
      return 0 - 1;
    }
  }
  if (ndefines < 0) {
    return 0 - 1;
  }
  unsafe {
    return xlang_preprocess_raw_to_malloc_impl(raw, raw_len, out_src, out_src_len, path_diag, defines, ndefines, 1);
  }
  return 0 - 1;
}

/**
 * Public preprocess surface with path diags (owned malloc prep or null).
 * @param source *u8 - source bytes; null -> null (out_length cleared when non-null)
 * @param source_len usize - byte count; 0 -> pipe_cstr_len(source) (≡ seed strlen)
 * @param path_diag *u8 - path for PP/XP diags; may be null
 * @param defines *u8 - const char** define names base; used only when ndefines > 0
 * @param ndefines i32 - define count
 * @param out_length *u8 - size_t* out length as bytes; may be null
 * @return *u8 - owned NUL-terminated prep (caller free); null on fail
 * wave81 pure Cap residual thin:
 *   G.7 pure xlang_preprocess_raw_to_malloc_impl with emit_diag=1 (product X-pipeline path);
 *   LP64 stack out cells for char** / size_t* (same pattern as stage_prep);
 *   seed cold twin keeps LEGACY preprocess_c_fallback under #ifndef FROM_X.
 * PLATFORM: SHARED - matches seed XLANG_USE_X_PIPELINE && !LEGACY control flow.
 */
#[no_mangle]
export function xlang_preprocess_with_path(source: *u8, source_len: usize, path_diag: *u8, defines: *u8, ndefines: i32, out_length: *u8): *u8 {
  if (out_length != 0 as *u8) {
    xlang_size_slot_set(out_length, 0, 0);
  }
  if (source == 0 as *u8) {
    return 0 as *u8;
  }
  let slen: i64 = source_len as i64;
  if (slen == 0) {
    slen = pipe_cstr_len(source) as i64;
  }
  // LP64 out cells for impl (char** / size_t*).
  let out_prep: u8[8] = [];
  let out_len: u8[8] = [];
  pipe_store_ptr_slot(&out_prep[0], 0, 0 as *u8);
  xlang_size_slot_set(&out_len[0], 0, 0);
  let def_arg: *u8 = 0 as *u8;
  if (ndefines > 0) {
    def_arg = defines;
  }
  let rc: i32 = 0;
  unsafe {
    rc = xlang_preprocess_raw_to_malloc_impl(source, slen, &out_prep[0], &out_len[0], path_diag, def_arg, ndefines, 1);
  }
  if (rc != 0) {
    return 0 as *u8;
  }
  let prep: *u8 = pipe_load_ptr_slot(&out_prep[0], 0);
  let olen: i64 = xlang_size_slot_get(&out_len[0], 0);
  if (out_length != 0 as *u8) {
    xlang_size_slot_set(out_length, 0, olen);
  }
  return prep;
}

/**
 * Public preprocess surface quiet (no path diags; emit_diag=0).
 * @param source *u8 - source bytes; null -> null
 * @param source_len usize - byte count; 0 -> pipe_cstr_len(source)
 * @param defines *u8 - const char** define names base; used only when ndefines > 0
 * @param ndefines i32 - define count
 * @param out_length *u8 - size_t* out length as bytes; may be null
 * @return *u8 - owned prep or null
 * wave81 pure Cap residual thin: G.7 pure raw_to_malloc_impl emit_diag=0 path_diag null.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_preprocess_quiet(source: *u8, source_len: usize, defines: *u8, ndefines: i32, out_length: *u8): *u8 {
  if (out_length != 0 as *u8) {
    xlang_size_slot_set(out_length, 0, 0);
  }
  if (source == 0 as *u8) {
    return 0 as *u8;
  }
  let slen: i64 = source_len as i64;
  if (slen == 0) {
    slen = pipe_cstr_len(source) as i64;
  }
  let out_prep: u8[8] = [];
  let out_len: u8[8] = [];
  pipe_store_ptr_slot(&out_prep[0], 0, 0 as *u8);
  xlang_size_slot_set(&out_len[0], 0, 0);
  let def_arg: *u8 = 0 as *u8;
  if (ndefines > 0) {
    def_arg = defines;
  }
  let rc: i32 = 0;
  unsafe {
    rc = xlang_preprocess_raw_to_malloc_impl(source, slen, &out_prep[0], &out_len[0], 0 as *u8, def_arg, ndefines, 0);
  }
  if (rc != 0) {
    return 0 as *u8;
  }
  let prep: *u8 = pipe_load_ptr_slot(&out_prep[0], 0);
  let olen: i64 = xlang_size_slot_get(&out_len[0], 0);
  if (out_length != 0 as *u8) {
    xlang_size_slot_set(out_length, 0, olen);
  }
  return prep;
}

/**
 * Public preprocess surface (default quiet).
 * @param source *u8 - source bytes
 * @param source_len usize - byte count; 0 -> cstr len
 * @param defines *u8 - const char** define table
 * @param ndefines i32 - define count
 * @param out_length *u8 - size_t* out length
 * @return *u8 - owned prep or null
 * wave81 pure Cap residual thin: G.7 pure xlang_preprocess_quiet.
 * PLATFORM: SHARED - matches seed alias.
 */
#[no_mangle]
export function xlang_preprocess(source: *u8, source_len: usize, defines: *u8, ndefines: i32, out_length: *u8): *u8 {
  return xlang_preprocess_quiet(source, source_len, defines, ndefines, out_length);
}

// driver_dep_seed_slots: see function docblock below.
/** Exported function `driver_dep_seed_slots`.
 * Implements `driver_dep_seed_slots`.
 * @param arenas *u8
 * @param modules *u8
 * @param n i32
 * @return void
 */
#[no_mangle]
export function driver_dep_seed_slots(arenas: *u8, modules: *u8, n: i32): void {
  let j: i32 = 0;
  while (j < 32) {
    if (j < n) {
      unsafe {
        let a: *u8 = 0 as *u8;
        let m: *u8 = 0 as *u8;
        if (arenas != 0 as *u8) {
          a = pipe_load_ptr_slot(arenas, j);
        }
        if (modules != 0 as *u8) {
          m = pipe_load_ptr_slot(modules, j);
        }
        driver_dep_arena_ptr_set(j, a);
        driver_dep_module_ptr_set(j, m);
        driver_dep_seeded_set(j, 1);
      }
    } else {
      driver_dep_seeded_set(j, 0);
    }
    j = j + 1;
  }
}

// pipe_cstr_contains: see function docblock below.
/** Exported function `pipe_cstr_contains`.
 * Implements `pipe_cstr_contains`.
 * @param hay *u8
 * @param needle *u8
 * @return i32
 */
export function pipe_cstr_contains(hay: *u8, needle: *u8): i32 {
  if (hay == 0 as *u8) { return 0; }
  if (needle == 0 as *u8) { return 0; }
  if (needle[0] == 0) { return 1; }
  unsafe {
    let hi: i32 = 0;
    while (hi < 4096) {
      if (hay[hi] == 0) { return 0; }
      let j: i32 = 0;
      let ok: i32 = 1;
      while (ok != 0) {
        if (needle[j] == 0) { return 1; }
        if (hay[hi + j] == 0) { ok = 0; }
        else {
          if (hay[hi + j] != needle[j]) { ok = 0; }
          else { j = j + 1; }
        }
      }
      hi = hi + 1;
    }
  }
  return 0;
}

/**
 * Thin gate: -E lib_prefix from entry path (null -> "typeck"; else pure impl).
 * @param input_path *u8 - entry .x path; null -> static "typeck"
 * @return *u8 - never null; keyword lit or stem BSS or "typeck"
 * wave75: G.7 pure xlang_entry_lib_name_from_path_impl owns full keyword/std/core/basename
 * order (matches seed cold twin; no pure std/-first dual path).
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function xlang_entry_lib_name_from_path(input_path: *u8): *u8 {
  if (input_path == 0 as *u8) {
    return xlang_cstr_typeck_lit();
  }
  return xlang_entry_lib_name_from_path_impl(input_path);
}

/* See implementation. */

#[no_mangle]
export function pipeline_get_dep_arena_slot(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  unsafe {
    return pipeline_dep_arena_slot_at(i);
  }
  return 0 as *u8;
}

/** Exported function `pipeline_get_dep_module_slot`.
 * Implements `pipeline_get_dep_module_slot`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function pipeline_get_dep_module_slot(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  unsafe {
    return pipeline_dep_module_slot_at(i);
  }
  return 0 as *u8;
}

// See implementation.
let g_import_open_valid: i32 = 0;
let g_import_open_import: u8[65] = [];
let g_import_open_resolved: u8[512] = [];

/** Exported function `pipe_cstr_copy`.
 * Implements `pipe_cstr_copy`.
 * @param dst *u8
 * @param cap i32
 * @param src *u8
 * @return void
 */
export function pipe_cstr_copy(dst: *u8, cap: i32, src: *u8): void {
  let i: i32 = 0;
  if (dst == 0 as *u8) { return; }
  if (cap <= 0) { return; }
  if (src == 0 as *u8) {
    dst[0] = 0;
    return;
  }
  unsafe {
    while (i < (cap - 1)) {
      let c: u8 = src[i];
      dst[i] = c;
      if (c == 0) { return; }
      i = i + 1;
    }
    dst[cap - 1] = 0;
  }
}

/** Exported function `pipeline_diag_import_open_fail_once`.
 * Implements `pipeline_diag_import_open_fail_once`.
 * @param import_path *u8
 * @param resolved_path *u8
 * @return void
 */
#[no_mangle]
export function pipeline_diag_import_open_fail_once(import_path: *u8, resolved_path: *u8): void {
  let q: u8[2] = [];
  q[0] = 63; // '?'
  q[1] = 0;
  let import_key: *u8 = import_path;
  let resolved_key: *u8 = resolved_path;
  if (import_key == 0 as *u8) { import_key = &q[0]; }
  if (resolved_key == 0 as *u8) { resolved_key = &q[0]; }
  unsafe {
    if (g_import_open_valid != 0) {
      if (pipe_cstr_eq(&g_import_open_import[0], import_key) != 0) {
        if (pipe_cstr_eq(&g_import_open_resolved[0], resolved_key) != 0) {
          pipeline_diag_emitted_note();
          return;
        }
      }
    }
    pipe_cstr_copy(&g_import_open_import[0], 65, import_key);
    pipe_cstr_copy(&g_import_open_resolved[0], 512, resolved_key);
    g_import_open_valid = 1;
    pipeline_diag_emitted_note();
    let kind: u8[16] = [];
    let code: u8[8] = [];
    let msg: u8[32] = [];
    // "import error"
    kind[0]=105;kind[1]=109;kind[2]=112;kind[3]=111;kind[4]=114;kind[5]=116;kind[6]=32;kind[7]=101;
    kind[8]=114;kind[9]=114;kind[10]=111;kind[11]=114;kind[12]=0;
    // "IMP001"
    code[0]=73;code[1]=77;code[2]=80;code[3]=48;code[4]=48;code[5]=49;code[6]=0;
    // "cannot open import"
    msg[0]=99;msg[1]=97;msg[2]=110;msg[3]=110;msg[4]=111;msg[5]=116;msg[6]=32;msg[7]=111;
    msg[8]=112;msg[9]=101;msg[10]=110;msg[11]=32;msg[12]=105;msg[13]=109;msg[14]=112;msg[15]=111;
    msg[16]=114;msg[17]=116;msg[18]=0;
    let file: *u8 = resolved_path;
    if (file == 0 as *u8) { file = import_path; }
    diag_report_with_code(file, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
  }
}

/* ---- G-02f-56：resolve_path / read_file / parse loaded import ---- */

/**
 * Resolve import logical path into the pipeline static resolved_path BSS buffer.
 * Uses a single lib root "." and the current pipeline entry_dir (set via pipeline_set_entry_dir).
 * @param path_c *u8 - NUL-terminated import path; null -> no-op
 * @return void
 * wave65 pure Cap residual orch (wave69: resolved slot pure):
 *   G.7 pure xlang_resolve_import_file_path_multi (file-path / -L / entry_dir fallbacks);
 *   pure pipeline_entry_dir_get (wave68 BSS) + pure pipeline_resolved_path_buf_slot (wave69 BSS).
 * Stack packs one LP64 ptr slot for lib_roots[1] = {"."} (same as historical seed).
 * PLATFORM: SHARED - resolved buffer cap 512 matches historical seed pipeline_resolved_path_buf.
 */
#[no_mangle]
export function pipeline_resolve_path_into_static(path_c: *u8): void {
  if (path_c == 0 as *u8) {
    return;
  }
  // Single root "." - same as seed lib_roots[1] = { "." }.
  let dot: u8[2] = [];
  dot[0] = 46;
  dot[1] = 0;
  // LP64: one void* slot for multi(lib_roots, n=1, ...).
  let roots: u8[8] = [];
  unsafe {
    xlang_ptr_slot_set(&roots[0], 0, &dot[0]);
    let entry: *u8 = pipeline_entry_dir_get();
    let rbuf: *u8 = pipeline_resolved_path_buf_slot();
    // Cap 512 - pure g_pipe_resolved_path_buf (wave69; cold seed char[512]).
    xlang_resolve_import_file_path_multi(&roots[0], 1, entry, path_c, rbuf, 512 as i64);
  }
}

/**
 * Copy path_ptr[0..path_len) into a local C string and resolve into static BSS.
 * @param path_ptr *u8 - import path bytes; null -> -1
 * @param path_len i32 - max copy length; clamped to 1..64 (0 or negative -> 64)
 * @return i32 - 0 on success (always after null gate; multi writes last try path)
 * wave65: body uses pure pipeline_resolve_path_into_static (no seed _impl).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_resolve_path(path_ptr: *u8, path_len: i32): i32 {
  if (path_ptr == 0 as *u8) {
    return 0 - 1;
  }
  let plen: i32 = path_len;
  if (plen <= 0) {
    plen = 64;
  }
  if (plen > 64) {
    plen = 64;
  }
  let path_c: u8[65] = [];
  let k: i32 = 0;
  unsafe {
    while (k < plen) {
      if (path_ptr[k] == 0) {
        break;
      }
      path_c[k] = path_ptr[k];
      k = k + 1;
    }
    path_c[k] = 0;
    // G.7 pure into_static (wave65) - pure entry_dir + pure resolved BSS (wave68/69).
    pipeline_resolve_path_into_static(&path_c[0]);
  }
  return 0;
}

/**
 * Read resolved_path BSS file, preprocess into owned prep, store in stage BSS.
 * @return i32 - 0 success; -1 open fail / preprocess fail / null prep
 * wave66 pure orch (wave69 resolved slot; wave71 pure stage clear/set):
 *   pure pipeline_rf_stage_prep_clear / pipeline_rf_stage_prep_set (wave71 pure BSS);
 *   pure pipeline_resolved_path_buf_slot (wave69 BSS; path written by resolve_path_into_static);
 *   runtime_read_file_view into 32B stack XlangRuntimeFileView (G.7 same as wave55 load_one);
 *   open fail -> pure pipeline_diag_import_open_fail_once(null, path);
 *   G.7 pure xlang_preprocess_raw_to_malloc (defines null, ndefines 0);
 *   runtime_release_file_view always after read success;
 *   null prep after preprocess ok -> pure pipeline_diag_import_preprocess_fail.
 * PLATFORM: SHARED - same semantics as historical seed stage_prep.
 */
#[no_mangle]
export function pipeline_read_file_stage_prep(): i32 {
  // Drop any prior stage prep (owned heap).
  unsafe {
    pipeline_rf_stage_prep_clear();
  }
  let path: *u8 = 0 as *u8;
  unsafe {
    path = pipeline_resolved_path_buf_slot();
  }
  // XlangRuntimeFileView ABI: data@0 length@8 needs_free@16 needs_munmap@20 (24B; pad 32).
  let view: u8[32] = [];
  let z: i32 = 0;
  while (z < 32) {
    view[z] = 0;
    z = z + 1;
  }
  let view_rc: i32 = 0;
  unsafe {
    view_rc = runtime_read_file_view(path, &view[0]);
  }
  if (view_rc != 0) {
    // Historical seed: import_path null, resolved_path = BSS path.
    pipeline_diag_import_open_fail_once(0 as *u8, path);
    return 0 - 1;
  }
  let raw_data: *u8 = xlang_ptr_slot_get(&view[0], 0);
  let raw_len: i64 = xlang_size_slot_get(&view[0], 1);
  // LP64 out cells for preprocess (char** / size_t*).
  let out_prep: u8[8] = [];
  let out_len: u8[8] = [];
  pipe_store_ptr_slot(&out_prep[0], 0, 0 as *u8);
  xlang_size_slot_set(&out_len[0], 0, 0);
  let prep_rc: i32 = 0;
  unsafe {
    // defines null / ndefines 0 - same as historical stage_prep.
    prep_rc = xlang_preprocess_raw_to_malloc(raw_data, raw_len, &out_prep[0], &out_len[0], path, 0 as *u8, 0);
  }
  unsafe {
    runtime_release_file_view(&view[0]);
  }
  if (prep_rc != 0) {
    return 0 - 1;
  }
  let prep: *u8 = pipe_load_ptr_slot(&out_prep[0], 0);
  let prep_len: i64 = xlang_size_slot_get(&out_len[0], 0);
  if (prep == 0 as *u8) {
    pipeline_diag_import_preprocess_fail(0 as *u8, path);
    return 0 - 1;
  }
  unsafe {
    pipeline_rf_stage_prep_set(prep, prep_len);
  }
  return 0;
}

/**
 * Move stage prep into loaded_import BSS (ensure buffer + copy + free prep).
 * @return i32 - 0 success; -1 empty stage or OOM on loaded buffer ensure
 * wave66 pure orch (wave71 pure take + wave72 pure commit):
 *   pure pipeline_rf_stage_prep_take (wave71 BSS) -> owned prep on stack slots;
 *   pure pipeline_loaded_import_commit_from_owned (wave72 ensure/memcpy/free).
 * PLATFORM: SHARED - G.7 single ensure body in pure commit (no Cap residual twin under hybrid).
 */
#[no_mangle]
export function pipeline_read_file_commit_prep(): i32 {
  // LP64: out_prep is char**; out_len is size_t*.
  let out_prep: u8[8] = [];
  let out_len: u8[8] = [];
  pipe_store_ptr_slot(&out_prep[0], 0, 0 as *u8);
  xlang_size_slot_set(&out_len[0], 0, 0);
  let take_rc: i32 = 0;
  unsafe {
    // pure take expects char** / size_t* (slots as raw bytes).
    take_rc = pipeline_rf_stage_prep_take(&out_prep[0], &out_len[0]);
  }
  if (take_rc != 0) {
    return 0 - 1;
  }
  let prep: *u8 = pipe_load_ptr_slot(&out_prep[0], 0);
  let prep_len: i64 = xlang_size_slot_get(&out_len[0], 0);
  if (prep == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    return pipeline_loaded_import_commit_from_owned(prep, prep_len);
  }
  return 0 - 1;
}

/**
 * Resolve-path then read/preprocess/commit into loaded_import (two-stage).
 * @return i32 - 0 success; -1 if stage_prep or commit_prep fails
 * wave66: body uses pure stage_prep + pure commit_prep (no seed _impl).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_read_file(): i32 {
  unsafe {
    if (pipeline_read_file_stage_prep() != 0) {
      return 0 - 1;
    }
    if (pipeline_read_file_commit_prep() != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * Parse source bytes into module via Cap residual parser_parse_into (ok unpack).
 * @param arena *u8 - AST arena; null -> -1
 * @param module *u8 - AST module; null -> -1
 * @param data *u8 - source bytes; null -> -1
 * @param len i64 - byte length; negative or > INT32_MAX -> -1; zero length allowed
 * @return i32 - 0 if parser ok==0; -1 on null/oversized/any non-zero ok
 * wave64 pure Cap residual orch:
 *   G.7 pure parser_parse_into_init (wave1222: full body matching C authority);
 *   G.7 pure driver_parse_into_buf_rc (unpacks Cap-struct-return ParseIntoResult.ok).
 * Contract: this API collapses every non-zero ok to -1 (including historical ok==-2).
 *   Contrast one_ctx map_impl (wave62), which accepts ok==-2 for import-table scan.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_parse_into_bytes(arena: *u8, module: *u8, data: *u8, len: i64): i32 {
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (data == 0 as *u8) {
    return 0 - 1;
  }
  // INT32_MAX - driver_parse_into_buf_rc residual takes int32_t len.
  let imax: i64 = 2147483647;
  if (len < 0) {
    return 0 - 1;
  }
  if (len > imax) {
    return 0 - 1;
  }
  let len_i32: i32 = len as i32;
  unsafe {
    // Same order as historical impl_c: trait reset + source stash + init + parse.
    // wave1222: trait_reg_reset + generic_bound_stash prevent cross-file state leak.
    xlang_trait_reg_reset_c(arena);
    xlang_generic_bound_stash_source_buf_c(data, len_i32);
    parser_parse_into_init(module, arena);
    // Cap-struct-return residual unpacks ParseIntoResult.ok; null out_main_idx.
    let pr_ok: i32 = driver_parse_into_buf_rc(arena, module, data, len_i32, 0 as *i32);
    // Historical: only ok==0 is success; any other code (incl. -2) -> -1.
    if (pr_ok == 0) {
      return 0;
    }
    return 0 - 1;
  }
  return 0 - 1;
}

/**
 * Parse the pipeline loaded-import buffer into module (after resolve/read/preprocess stages).
 * @param arena *u8 - AST arena; null -> -1
 * @param module *u8 - AST module; null -> -1
 * @return i32 - 0 success, -1 null arena/module, empty loaded buffer, or parse fail
 * wave64: body uses pure pipeline_parse_into_bytes after pure loaded buffer accessors.
 * wave72: pure pipeline_loaded_import_data / pipeline_loaded_import_len_get (pure BSS).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_parse_into_loaded_import(arena: *u8, module: *u8): i32 {
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    let data: *u8 = pipeline_loaded_import_data();
    if (data == 0 as *u8) {
      return 0 - 1;
    }
    let len: i64 = pipeline_loaded_import_len_get();
    return pipeline_parse_into_bytes(arena, module, data, len);
  }
  return 0 - 1;
}

/* See implementation. */

// xlang_pipeline_run_x_pipeline_large_stack: see function docblock below.
/**
 * Thin gate for large-stack pipeline_run_x_pipeline (null / empty source rejected).
 * @param module *u8 - AST module; null -> -1
 * @param arena *u8 - AST arena; null -> -1
 * @param source_data *u8 - source bytes; null -> -1
 * @param source_len i64 - byte length; <=0 -> -1
 * @param out_buf *u8 - codegen out buffer; may be null (pipeline accepts)
 * @param ctx *u8 - PipelineDepCtx; may be null
 * @return i32 - pipeline ec; -1 on thin reject
 * wave56: body in pure xlang_pipeline_run_x_pipeline_large_stack_impl.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_pipeline_run_x_pipeline_large_stack(module: *u8, arena: *u8, source_data: *u8, source_len: i64, out_buf: *u8, ctx: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (source_data == 0 as *u8) {
    return 0 - 1;
  }
  if (source_len <= 0) {
    return 0 - 1;
  }
  unsafe {
    return xlang_pipeline_run_x_pipeline_large_stack_impl(module, arena, source_data, source_len, out_buf, ctx);
  }
  return 0 - 1;
}

/* See implementation. */

/**
 * Dep prerun: full parse on large stack, skip typeck and codegen.
 * Saves/restores check_only + asm_entry_module_only; sets skip flags around large_stack.
 * @param dep_mod *u8 - dep AST module; caller thin already null-checked
 * @param dep_arena *u8 - dep AST arena
 * @param src *u8 - source bytes
 * @param len i64 - byte length
 * @param dep_out *u8 - optional out buffer (pipeline accepts null)
 * @param one_ctx *u8 - PipelineDepCtx; may be null (asm_entry field skipped)
 * @return i32 - pipeline ec from pure large_stack
 * wave58 pure Cap residual:
 *   G.7 driver_check_only_get/set;
 *   G.7 driver_x_pipeline_skip_typeck_set + skip_codegen_set;
 *   G.7 driver_pipeline_dep_ctx_get/set_asm_entry_module_only (no C struct field access);
 *   pure xlang_pipeline_run_x_pipeline_large_stack (wave56).
 * PLATFORM: SHARED - same flag order as historical seed _impl.
 */
#[no_mangle]
export function xlang_pipeline_dep_prerun_parse_skip_typeck_impl(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32 {
  unsafe {
    let saved: i32 = driver_check_only_get();
    let saved_entry_only: i32 = 0;
    driver_check_only_set(1);
    // Save/set asm_entry_module_only only when one_ctx is non-null (seed pctx branch).
    if (one_ctx != 0 as *u8) {
      saved_entry_only = driver_pipeline_dep_ctx_get_asm_entry_module_only(one_ctx);
      driver_pipeline_dep_ctx_set_asm_entry_module_only(one_ctx, 1);
    }
    driver_x_pipeline_skip_typeck_set(1);
    driver_x_pipeline_skip_codegen_set(1);
    // G.7 pure large_stack surface (wave56); re-null-checks inside thin gate are fine.
    let ec: i32 = xlang_pipeline_run_x_pipeline_large_stack(dep_mod, dep_arena, src, len, dep_out, one_ctx);
    driver_x_pipeline_skip_codegen_set(0);
    driver_x_pipeline_skip_typeck_set(0);
    if (one_ctx != 0 as *u8) {
      driver_pipeline_dep_ctx_set_asm_entry_module_only(one_ctx, saved_entry_only);
    }
    // Restore check_only as 0/1 (seed: saved ? 1 : 0).
    if (saved != 0) {
      driver_check_only_set(1);
    } else {
      driver_check_only_set(0);
    }
    return ec;
  }
  return 0 - 1;
}

// xlang_pipeline_dep_prerun_parse_skip_typeck: see function docblock below.
/**
 * Thin gate for dep prerun parse-skip-typeck (null / empty source rejected).
 * @param dep_mod *u8 - dep AST module; null -> -1
 * @param dep_arena *u8 - dep AST arena; null -> -1
 * @param src *u8 - source bytes; null -> -1
 * @param len i64 - byte length; <=0 -> -1
 * @param dep_out *u8 - optional out buffer
 * @param one_ctx *u8 - PipelineDepCtx; may be null
 * @return i32 - pipeline ec; -1 on thin reject
 * wave58: body in pure xlang_pipeline_dep_prerun_parse_skip_typeck_impl.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_pipeline_dep_prerun_parse_skip_typeck(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32 {
  if (dep_mod == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_arena == 0 as *u8) {
    return 0 - 1;
  }
  if (src == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  unsafe {
    return xlang_pipeline_dep_prerun_parse_skip_typeck_impl(dep_mod, dep_arena, src, len, dep_out, one_ctx);
  }
  return 0 - 1;
}

/**
 * Dep prerun parse-only body: init parse + set_main_from_buf (no typeck).
 * Must use pipeline_parse_set_main_from_buf_c (parse_into_with_init_buf); a bare
 * parser_parse_into slice path under-parses large std modules (ok=-2, ~2 funcs).
 * @param dep_mod *u8 - dep AST module; caller thin already null-checked
 * @param dep_arena *u8 - dep AST arena
 * @param src *u8 - source bytes
 * @param len i64 - byte length; > INT32_MAX -> -1
 * @return i32 - 0 on parse ok; -1 on null/oversized/parse fail
 * wave59 pure Cap residual:
 *   G.7 pure parser_parse_into_init (wave1222: full body matching C authority);
 *   G.7 pure pipeline_parse_set_main_from_buf_c surface (real body in pipeline_glue);
 *   XLANG_ASM_DEBUG notes cold-only (seed twin keeps pipeline_asm_debug_enabled diags).
 * PLATFORM: SHARED - same return mapping as historical seed _impl (parse_rc==0 -> 0 else -1).
 */
#[no_mangle]
export function xlang_pipeline_dep_prerun_parse_only_impl(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64): i32 {
  if (dep_mod == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_arena == 0 as *u8) {
    return 0 - 1;
  }
  if (src == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  // INT32_MAX - pipeline glue takes int32_t len.
  let imax: i64 = 2147483647;
  if (len > imax) {
    return 0 - 1;
  }
  unsafe {
    let len_i32: i32 = len as i32;
    // Authority parse path for dep prerun (not bare parser_parse_into).
    // wave1222: trait_reg_reset + generic_bound_stash prevent cross-file state leak.
    xlang_trait_reg_reset_c(dep_arena);
    xlang_generic_bound_stash_source_buf_c(src, len_i32);
    parser_parse_into_init(dep_mod, dep_arena);
    let parse_rc: i32 = pipeline_parse_set_main_from_buf_c(dep_mod, dep_arena, src, len_i32);
    if (parse_rc == 0) {
      return 0;
    }
    return 0 - 1;
  }
  return 0 - 1;
}

/**
 * Thin gate for dep prerun parse-only (null / empty source rejected).
 * @param dep_mod *u8 - dep AST module; null -> -1
 * @param dep_arena *u8 - dep AST arena; null -> -1
 * @param src *u8 - source bytes; null -> -1
 * @param len i64 - byte length; <=0 -> -1
 * @return i32 - 0 ok; -1 reject or parse fail
 * wave59: body in pure xlang_pipeline_dep_prerun_parse_only_impl.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_pipeline_dep_prerun_parse_only(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64): i32 {
  if (dep_mod == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_arena == 0 as *u8) {
    return 0 - 1;
  }
  if (src == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  unsafe {
    return xlang_pipeline_dep_prerun_parse_only_impl(dep_mod, dep_arena, src, len);
  }
  return 0 - 1;
}

/* ---- G-02f-59 / G-02f-239 / wave60：dep prerun typeck ---- */

/**
 * Dep prerun typeck-only body: parse + load/sync direct imports + typeck (no codegen).
 * Does not walk run_x_pipeline (large modules drop ctx); uses C glue authorities.
 * @param dep_mod *u8 - dep AST module; caller thin already null-checked
 * @param dep_arena *u8 - dep AST arena
 * @param src *u8 - source bytes
 * @param len i64 - byte length; > INT32_MAX -> -1
 * @param dep_out *u8 - unused (historical signature; seed voids it)
 * @param one_ctx *u8 - PipelineDepCtx; required for load + typeck
 * @return i32 - 0 ok; -1 null/oversized; -2 parse fail; else load_rc / typeck_rc
 * wave60 pure Cap residual; wave89 pure owns typeck_dep_prerun_module_c;
 * wave93 pure owns load_and_sync_direct_import_deps_c:
 *   G.7 pure pipeline_parse_set_main_from_buf_c surface (weak empty here; strong glue wins);
 *   G.7 pure pipeline_load_and_sync_direct_import_deps_c (same-TU; Cap residual disk/sync/merge);
 *   G.7 pure pipeline_typeck_dep_prerun_module_c (same-TU; layout helpers wave92 pure);
 *   XLANG_DEBUG_PIPE notes cold-only (seed twin keeps getenv diags).
 * PLATFORM: SHARED - same return mapping as historical seed _impl.
 */
#[no_mangle]
export function xlang_pipeline_dep_prerun_typeck_only_impl(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32 {
  // dep_out is public ABI only; historical seed voids it (no consumer on this path).
  if (dep_mod == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_arena == 0 as *u8) {
    return 0 - 1;
  }
  if (src == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  if (one_ctx == 0 as *u8) {
    return 0 - 1;
  }
  // INT32_MAX - pipeline glue takes int32_t len.
  let imax: i64 = 2147483647;
  if (len > imax) {
    return 0 - 1;
  }
  unsafe {
    let len_i32: i32 = len as i32;
    // Authority parse path (same as seed; not bare parser_parse_into).
    let parse_rc: i32 = pipeline_parse_set_main_from_buf_c(dep_mod, dep_arena, src, len_i32);
    // Seed maps any non-zero parse to -2 (not -1).
    if (parse_rc != 0) {
      return 0 - 2;
    }
    let load_rc: i32 = pipeline_load_and_sync_direct_import_deps_c(dep_mod, dep_arena, one_ctx);
    if (load_rc != 0) {
      return load_rc;
    }
    // wave89: pure same-TU typeck dep prerun (skip codegen); return code is authority surface.
    let tc_rc: i32 = pipeline_typeck_dep_prerun_module_c(dep_mod, dep_arena, one_ctx);
    return tc_rc;
  }
  return 0 - 1;
}

/**
 * Dep-module typeck prerun: exploratory full library typeck, then light layout fallback.
 * @param module *u8 - dep AST module; null -> -5
 * @param arena *u8 - dep AST arena; null -> -5
 * @param ctx *u8 - PipelineDepCtx; null -> -5
 * @return i32 - 0 ok; -5 null args; -7 zero-padding layout fail; else 0 after light fallback
 * wave89 pure Cap residual: G.7 single product authority for pipeline_typeck_dep_prerun_module_c
 * (historical strong body in pipeline_glue.c now XLANG_WEAK cold fallback).
 * Steps (match historical C; XLANG_DEBUG_PIPE notes cold-only):
 *   1) pipeline_typeck_set_dep_ctx(ctx) - wave91 pure same-TU BSS (dep_ctx for glue accessors);
 *   2) soft_suppress_set(1) - wave90 pure same-TU BSS (suppress exploratory XT001 soft diags);
 *   3) typeck_x_ast_library (G.7 typeck.x authority; same as wave87 library route);
 *   4) soft_suppress_set(0);
 *   5) tc==0 -> 0; else wave92 pure validate zero-padding -> -7; pure patch body parent links -> 0.
 * PLATFORM: SHARED - glue XLANG_WEAK cold fallback when pure not linked.
 */
#[no_mangle]
export function pipeline_typeck_dep_prerun_module_c(module: *u8, arena: *u8, ctx: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 5;
  }
  if (arena == 0 as *u8) {
    return 0 - 5;
  }
  if (ctx == 0 as *u8) {
    return 0 - 5;
  }
  let tc: i32 = 0;
  unsafe {
    // wave91 pure same-TU: publish dep ctx for glue typeck accessors (get_dep_ctx).
    pipeline_typeck_set_dep_ctx(ctx);
    // wave90 pure same-TU: suppress soft XT001 during exploratory full typeck.
    pipeline_typeck_diag_soft_suppress_set(1);
    // G.7 typeck authority: library path (dep modules have no entry main).
    tc = typeck_x_ast_library(module, arena, ctx);
    pipeline_typeck_diag_soft_suppress_set(0);
  }
  if (tc == 0) {
    return 0;
  }
  // Full typeck failed: light fallback - validate struct layout padding then patch parent links.
  // wave92: same-TU pure thin -> typeck.x (G.7; closes Cap residual glue-layout fork on product).
  // XLANG_DEBUG_PIPE getenv/fprintf remains cold-only (seed/glue twin); pure skips notes.
  let vrc: i32 = 0;
  unsafe {
    vrc = pipeline_typeck_validate_struct_layouts_zero_padding_c(module, arena);
  }
  if (vrc != 0) {
    return 0 - 7;
  }
  unsafe {
    pipeline_typeck_patch_all_body_parent_links_c(module, arena);
  }
  return 0;
}

/**
 * Validate all module struct layouts for zero-padding consistency (light layout gate).
 * @param module *u8 - AST module; null -> -1
 * @param arena *u8 - AST arena; null -> -1
 * @return i32 - 0 ok; -1 null/layout metrics fail (typeck.x authority)
 * wave92 pure Cap residual: G.7 thin -> typeck_validate_struct_layouts_zero_padding
 * (typeck.x -> typeck_x.o). Historical C body in pipeline_glue called glue metrics fork
 * (typeck_validate_struct_layouts_zero_padding_glue); product light fallback now shares
 * the same typeck.x path as typeck_x_ast_library / typeck_x_ast_impl.
 * PLATFORM: SHARED - glue keeps XLANG_WEAK cold twin for non-PREFER links.
 */
#[no_mangle]
export function pipeline_typeck_validate_struct_layouts_zero_padding_c(module: *u8, arena: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  let rc: i32 = 0;
  unsafe {
    // G.7 typeck.x authority - single layout-validate path (not glue metrics fork).
    rc = typeck_validate_struct_layouts_zero_padding(module, arena);
  }
  return rc;
}

/**
 * Patch parent_ref chains on every function body block in the module.
 * @param module *u8 - AST module; null -> no-op
 * @param arena *u8 - AST arena; null -> no-op
 * @return void
 * wave92 pure Cap residual: G.7 thin -> typeck_patch_all_body_parent_links
 * (typeck.x -> typeck_x.o; walks pipeline_module_num_funcs + body_ref +
 * pipeline_patch_block_parent_links). Historical C body in pipeline_glue inlined the
 * same walk via ast_ast_arena_patch_block_parent_links; product uses typeck.x only.
 * PLATFORM: SHARED - glue keeps XLANG_WEAK cold twin for non-PREFER links.
 */
#[no_mangle]
export function pipeline_typeck_patch_all_body_parent_links_c(module: *u8, arena: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  if (arena == 0 as *u8) {
    return;
  }
  unsafe {
    // G.7 typeck.x authority - single parent-link patch path.
    typeck_patch_all_body_parent_links(module, arena);
  }
}

/**
 * Bind import slot arena/module pointers from driver_dep publish buffers.
 * @param ctx *u8 - PipelineDepCtx; null -> no-op
 * @param import_idx i32 - ctx slot index; <0 -> no-op
 * @return void
 * wave94 pure Cap residual: G.7 single product authority for pipeline_bind_import_dep_buffers
 * (historical strong body in ast_pool). Same pattern as pure try_bind (driver buf -> set_*).
 * PLATFORM: SHARED - ast_pool keeps XLANG_WEAK cold twin for non-PREFER links.
 */
#[no_mangle]
export function pipeline_bind_import_dep_buffers(ctx: *u8, import_idx: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  if (import_idx < 0) {
    return;
  }
  unsafe {
    let a: *u8 = driver_dep_arena_buf(import_idx);
    let m: *u8 = driver_dep_module_buf(import_idx);
    ast_pipeline_dep_ctx_set_arena(ctx, import_idx, a);
    ast_pipeline_dep_ctx_set_module(ctx, import_idx, m);
  }
}

/**
 * Align one dep slot path/module/arena with driver seed authority.
 * @param module *u8 - entry AST module (for import path at dep_i); null -> -1
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @param dep_i i32 - dep slot index; <0 -> -1
 * @return i32 - 0 ok; -1 null/bad index
 * wave94 pure Cap residual: G.7 single product authority for pipeline_sync_one_dep_slot
 * (historical strong body in ast_pool). Pins path from entry import[dep_i], maps
 * driver_dep_slot_for_path (fallback dep_i), then set_module/set_arena from that slot.
 * PLATFORM: SHARED - ast_pool keeps XLANG_WEAK cold twin for non-PREFER links.
 */
#[no_mangle]
export function pipeline_sync_one_dep_slot(module: *u8, ctx: *u8, dep_i: i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_i < 0) {
    return 0 - 1;
  }
  let sync_path: u8[128] = [];
  unsafe {
    memset(&sync_path[0], 0, 64 as usize);
    let _pl: i32 = parser_copy_module_import_path64(module, dep_i, &sync_path[0]);
  }
  let sync_slot: i32 = 0;
  unsafe {
    sync_slot = driver_dep_slot_for_path(&sync_path[0]);
  }
  if (sync_slot < 0) {
    sync_slot = dep_i;
  }
  let pl: i32 = 0;
  while (pl < 64) {
    let b: u8 = 0;
    unsafe {
      b = sync_path[pl];
    }
    if (b == 0) {
      break;
    }
    pl = pl + 1;
  }
  if (pl > 0) {
    unsafe {
      ast_pipeline_dep_ctx_set_import_path(ctx, dep_i, &sync_path[0], pl);
    }
  }
  unsafe {
    let m: *u8 = driver_dep_module_buf(sync_slot);
    let a: *u8 = driver_dep_arena_buf(sync_slot);
    ast_pipeline_dep_ctx_set_module(ctx, dep_i, m);
    ast_pipeline_dep_ctx_set_arena(ctx, dep_i, a);
  }
  return 0;
}

/**
 * Sync all dep slots from driver seed authority (entry-indexed only).
 * @param module *u8 - entry AST module; null -> -1
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @return i32 - 0 ok; -1 null; else first pipeline_sync_one_dep_slot rc
 * Rules (match historical C; XLANG_DEBUG_PIPE notes cold-only):
 *   - if n_entry_imports < ndep (BFS closure): skip entry-index sync (slots already
 *     aligned by pctx_seed / load_and_sync keep-closure rebind); return 0
 *   - else: loop dep_i 0..ndep-1 same-TU pure pipeline_sync_one_dep_slot
 * wave94 pure Cap residual: G.7 single product authority for
 * pipeline_sync_dep_slots_from_driver_c (historical body in pipeline_glue impl_c +
 * strong _c dispatch). Product pure load_and_sync (wave93) calls this name.
 * PLATFORM: SHARED - glue keeps XLANG_WEAK cold twin for non-PREFER links.
 */
#[no_mangle]
export function pipeline_sync_dep_slots_from_driver_c(module: *u8, ctx: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  let dep_sync_nd: i32 = 0;
  let n_entry_imports: i32 = 0;
  unsafe {
    dep_sync_nd = ast_pipeline_dep_ctx_ndep(ctx);
    // Strong parser_get_module_num_imports wins at final link over pure weak stub.
    n_entry_imports = parser_get_module_num_imports(module);
  }
  // Closure seed: ndep > entry imports - skip entry-index re-sync (same invariant as
  // load_and_sync keep-closure; entry-index sync would clobber transitive deps).
  if (n_entry_imports >= 0) {
    if (n_entry_imports < dep_sync_nd) {
      return 0;
    }
  }
  let dep_sync_i: i32 = 0;
  while (dep_sync_i < dep_sync_nd) {
    let sync_rc: i32 = 0;
    unsafe {
      sync_rc = pipeline_sync_one_dep_slot(module, ctx, dep_sync_i);
    }
    if (sync_rc != 0) {
      return sync_rc;
    }
    dep_sync_i = dep_sync_i + 1;
  }
  return 0;
}

/**
 * Load one unseeded import from disk into ctx slot import_idx (resolve/read/pp/parse).
 * @param module *u8 - entry AST module; null -> -1
 * @param arena *u8 - entry AST arena (unused; slot uses dep arena); null -> -1
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @param import_idx i32 - entry import index / ctx slot; <0 -> -1
 * @return i32 - 0 ok; -1 null; -7 resolve fail; -8 read fail; -9 preprocess fail; -10 parse fail
 * Steps (match historical pipeline_load_import_from_disk_impl_c):
 *   1) same-TU pure parser_copy_module_import_path64 (wave99)
 *   2) same-TU pure pipeline_resolve_path_x (wave95)
 *   3) same-TU pure pipeline_read_file_x (wave95)
 *   4) same-TU pure pipeline_preprocess_loaded_into_ctx (wave95)
 *   5) pin import path on same slot (path authority for later sync)
 *   6) same-TU pure pipeline_bind_import_dep_buffers
 *   7) same-TU pure pipeline_parse_into_buf (wave96)
 * wave94 pure Cap residual: G.7 single product authority for pipeline_load_import_from_disk_c
 * (historical glue strong _c -> X thin / impl_c). Product pure load_and_sync calls this name.
 * PLATFORM: SHARED - glue keeps XLANG_WEAK cold twin for non-PREFER links.
 */
#[no_mangle]
export function pipeline_load_import_from_disk_c(module: *u8, arena: *u8, ctx: *u8, import_idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (import_idx < 0) {
    return 0 - 1;
  }
  let path_buf: u8[128] = [];
  let path_len: i32 = 0;
  unsafe {
    memset(&path_buf[0], 0, 64 as usize);
    path_len = parser_copy_module_import_path64(module, import_idx, &path_buf[0]);
  }
  let rr: i32 = 0;
  unsafe {
    rr = pipeline_resolve_path_x(ctx, &path_buf[0], path_len);
  }
  if (rr != 0) {
    return 0 - 7;
  }
  unsafe {
    rr = pipeline_read_file_x(ctx);
  }
  if (rr != 0) {
    return 0 - 8;
  }
  unsafe {
    rr = pipeline_preprocess_loaded_into_ctx(ctx);
  }
  if (rr != 0) {
    return 0 - 9;
  }
  // Pin path on the same slot we parse into (authority for path de-dupe / sync).
  if (path_len > 0) {
    unsafe {
      ast_pipeline_dep_ctx_set_import_path(ctx, import_idx, &path_buf[0], path_len);
    }
  }
  unsafe {
    pipeline_bind_import_dep_buffers(ctx, import_idx);
  }
  let dep_arena: *u8 = 0 as *u8;
  let dep_module: *u8 = 0 as *u8;
  let prep_buf: *u8 = 0 as *u8;
  let prep_len: i32 = 0;
  unsafe {
    dep_arena = pipeline_dep_ctx_arena_at(ctx, import_idx);
    dep_module = ast_pipeline_dep_ctx_module_at(ctx, import_idx);
    prep_buf = pipeline_dep_ctx_preprocess_buf_ptr(ctx);
    prep_len = pipeline_dep_ctx_preprocess_len_get(ctx);
    rr = pipeline_parse_into_buf(dep_arena, dep_module, prep_buf, prep_len);
  }
  if (rr != 0) {
    return 0 - 10;
  }
  return 0;
}

/**
 * Bind one entry-import slot from a driver-seeded global slot when available.
 * @param ctx *u8 - PipelineDepCtx; null -> 0 (not bound)
 * @param import_idx i32 - entry import index (ctx slot to fill); <0 -> 0
 * @param global_slot i32 - driver_dep slot for this path; <0 skips global path
 * @return i32 - 1 if bound from seed; 0 if not seeded (caller must disk-load)
 * wave93 pure Cap residual: G.7 single product authority for pipeline_try_bind_seeded_import
 * (historical strong body in ast_pool). Uses pure driver_dep_seeded_get + module/arena buf
 * and ast_pipeline_dep_ctx_set_*.
 * PLATFORM: SHARED - ast_pool keeps XLANG_WEAK cold twin for non-PREFER links.
 */
#[no_mangle]
export function pipeline_try_bind_seeded_import(ctx: *u8, import_idx: i32, global_slot: i32): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  if (import_idx < 0) {
    return 0;
  }
  // Prefer path-keyed global seed slot when seeded.
  if (global_slot >= 0) {
    if (driver_dep_seeded_get(global_slot) != 0) {
      unsafe {
        let a: *u8 = driver_dep_arena_buf(global_slot);
        let m: *u8 = driver_dep_module_buf(global_slot);
        ast_pipeline_dep_ctx_set_arena(ctx, import_idx, a);
        ast_pipeline_dep_ctx_set_module(ctx, import_idx, m);
      }
      return 1;
    }
  }
  // Fallback: entry-index aligned seed (import_idx == global slot).
  if (driver_dep_seeded_get(import_idx) != 0) {
    unsafe {
      let a2: *u8 = driver_dep_arena_buf(import_idx);
      let m2: *u8 = driver_dep_module_buf(import_idx);
      ast_pipeline_dep_ctx_set_arena(ctx, import_idx, a2);
      ast_pipeline_dep_ctx_set_module(ctx, import_idx, m2);
    }
    return 1;
  }
  return 0;
}

/**
 * Realign ctx.ndep before load_and_sync entry-import walk.
 * @param module *u8 - entry AST module; null -> no-op
 * @param ctx *u8 - PipelineDepCtx; null -> no-op
 * @return void
 * Rules (match historical C; XLANG_DEBUG_PIPE notes cold-only):
 *   - ndep == n_imports -> already entry-indexed; keep
 *   - ndep > n_imports -> BFS closure seed; keep full list (no re-pin)
 *   - ndep < n_imports -> incomplete; set ndep=0 so load_and_sync reloads from entry
 * wave93 pure Cap residual: G.7 single product authority for
 * pipeline_dep_ctx_realign_ndep_for_entry_c (historical strong body in ast_pool).
 * PLATFORM: SHARED - ast_pool keeps XLANG_WEAK cold twin for non-PREFER links.
 */
#[no_mangle]
export function pipeline_dep_ctx_realign_ndep_for_entry_c(module: *u8, ctx: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  if (ctx == 0 as *u8) {
    return;
  }
  let n_imp: i32 = 0;
  let ndep: i32 = 0;
  unsafe {
    // Strong parser_get_module_num_imports wins at final link over pure weak stub.
    n_imp = parser_get_module_num_imports(module);
    ndep = ast_pipeline_dep_ctx_ndep(ctx);
  }
  if (ndep == n_imp) {
    return;
  }
  if (ndep > n_imp) {
    // Closure seed: keep full BFS list; load_and_sync skips entry-index re-pin.
    return;
  }
  // Incomplete ndep - force reload via load_and_sync.
  unsafe {
    ast_pipeline_dep_ctx_set_ndep(ctx, 0);
  }
}

/**
 * Load and sync direct import deps for entry module (seed bind or disk load + merge).
 * @param module *u8 - entry AST module; null -> -1
 * @param arena *u8 - entry AST arena; null -> -1
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @return i32 - 0 ok; -1 null; else load_import / sync_dep_slots rc
 * wave93 pure Cap residual: G.7 single product authority for
 * pipeline_load_and_sync_direct_import_deps_c (historical strong body in ast_pool).
 * Steps (match historical C; XLANG_DEBUG_PIPE notes cold-only):
 *   1) same-TU pure realign_ndep_for_entry_c;
 *   2) if ndep==0 && n_imports>0: entry walk - pin path, pure try_bind or same-TU pure
 *      load_import_from_disk_c (wave94); set_ndep(n_imports);
 *   3) else if n_imports>0:
 *        - ndep > n_imports: keep BFS order; rebind module/arena/path from driver slots;
 *        - else: entry re-pin + try_bind / load empty slots; bump ndep if needed;
 *   4) same-TU pure pipeline_sync_dep_slots_from_driver_c (wave94);
 *   5) if not all entry imports seeded: wave97 G.7 typeck.x merge layouts + wpo unify
 *      (typeck_merge_dep_struct_layouts_into_entry / typeck_wpo_unify_soa_layouts;
 *      not typeck_typeck_* double-prefix hop).
 * PLATFORM: SHARED - ast_pool keeps XLANG_WEAK cold twin for non-PREFER links.
 */
#[no_mangle]
export function pipeline_load_and_sync_direct_import_deps_c(module: *u8, arena: *u8, ctx: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  let n_imports: i32 = 0;
  unsafe {
    n_imports = parser_get_module_num_imports(module);
  }
  // Step 1: realign ndep (same-TU pure).
  unsafe {
    pipeline_dep_ctx_realign_ndep_for_entry_c(module, ctx);
  }
  let ndep0: i32 = 0;
  unsafe {
    ndep0 = ast_pipeline_dep_ctx_ndep(ctx);
  }
  let path_buf: u8[128] = [];
  let i: i32 = 0;
  let rc: i32 = 0;
  if (ndep0 == 0) {
    if (n_imports > 0) {
      // Fresh entry walk: pin path + seed bind or disk load for each import.
      i = 0;
      while (i < n_imports) {
        unsafe {
          memset(&path_buf[0], 0, 64 as usize);
          let _pl0: i32 = parser_copy_module_import_path64(module, i, &path_buf[0]);
        }
        let pl: i32 = 0;
        // Count path bytes (cap 64) for set_import_path.
        while (pl < 64) {
          let b: u8 = 0;
          unsafe {
            b = path_buf[pl];
          }
          if (b == 0) {
            break;
          }
          pl = pl + 1;
        }
        if (pl > 0) {
          unsafe {
            ast_pipeline_dep_ctx_set_import_path(ctx, i, &path_buf[0], pl);
          }
        }
        let gs: i32 = 0;
        unsafe {
          gs = driver_dep_slot_for_path(&path_buf[0]);
        }
        let bound: i32 = 0;
        unsafe {
          bound = pipeline_try_bind_seeded_import(ctx, i, gs);
        }
        if (bound == 0) {
          unsafe {
            rc = pipeline_load_import_from_disk_c(module, arena, ctx, i);
          }
          if (rc != 0) {
            return rc;
          }
        }
        i = i + 1;
      }
      unsafe {
        ast_pipeline_dep_ctx_set_ndep(ctx, n_imports);
      }
    }
  } else {
    if (n_imports > 0) {
      let cur_ndep: i32 = ndep0;
      if (cur_ndep > n_imports) {
        // Keep BFS closure order; rebind from driver seed slots by BFS index.
        i = 0;
        while (i < cur_ndep) {
          let seeded: i32 = 0;
          unsafe {
            seeded = driver_dep_seeded_get(i);
          }
          if (seeded != 0) {
            unsafe {
              let m: *u8 = driver_dep_module_buf(i);
              let a: *u8 = driver_dep_arena_buf(i);
              ast_pipeline_dep_ctx_set_module(ctx, i, m);
              ast_pipeline_dep_ctx_set_arena(ctx, i, a);
              let reg_path: *u8 = driver_dep_path_registry_at(i);
              if (reg_path != 0 as *u8) {
                let rpl: i32 = pipe_cstr_len(reg_path);
                if (rpl > 127) {
                  rpl = 127;
                }
                if (rpl > 0) {
                  ast_pipeline_dep_ctx_set_import_path(ctx, i, reg_path, rpl);
                }
              }
            }
          }
          i = i + 1;
        }
      } else {
        // Entry-indexed or equal: re-pin paths from entry imports.
        i = 0;
        while (i < n_imports) {
          unsafe {
            memset(&path_buf[0], 0, 64 as usize);
            let _pl1: i32 = parser_copy_module_import_path64(module, i, &path_buf[0]);
          }
          let pl2: i32 = 0;
          while (pl2 < 64) {
            let b2: u8 = 0;
            unsafe {
              b2 = path_buf[pl2];
            }
            if (b2 == 0) {
              break;
            }
            pl2 = pl2 + 1;
          }
          if (pl2 > 0) {
            unsafe {
              ast_pipeline_dep_ctx_set_import_path(ctx, i, &path_buf[0], pl2);
            }
          }
          let gs2: i32 = 0;
          unsafe {
            gs2 = driver_dep_slot_for_path(&path_buf[0]);
          }
          let bound2: i32 = 0;
          unsafe {
            bound2 = pipeline_try_bind_seeded_import(ctx, i, gs2);
          }
          if (bound2 == 0) {
            // Unseeded under pre-set ndep: load only if module slot empty.
            let cur_m: *u8 = 0 as *u8;
            unsafe {
              cur_m = ast_pipeline_dep_ctx_module_at(ctx, i);
            }
            if (cur_m == 0 as *u8) {
              unsafe {
                rc = pipeline_load_import_from_disk_c(module, arena, ctx, i);
              }
              if (rc != 0) {
                return rc;
              }
            }
          }
          i = i + 1;
        }
        let nd_now: i32 = 0;
        unsafe {
          nd_now = ast_pipeline_dep_ctx_ndep(ctx);
        }
        if (nd_now < n_imports) {
          unsafe {
            ast_pipeline_dep_ctx_set_ndep(ctx, n_imports);
          }
        }
      }
    }
  }
  // Step 4: sync all dep slots from driver authority.
  let sync_rc: i32 = 0;
  unsafe {
    sync_rc = pipeline_sync_dep_slots_from_driver_c(module, ctx);
  }
  if (sync_rc != 0) {
    return sync_rc;
  }
  // Step 5: merge layouts only when at least one entry import is not fully seeded.
  // Seeded std/core deps: merge on parse-only slots can SIGSEGV; layout from prebuilt .o.
  let all_seeded: i32 = 0;
  if (n_imports > 0) {
    all_seeded = 1;
  }
  i = 0;
  while (i < n_imports) {
    unsafe {
      memset(&path_buf[0], 0, 64 as usize);
      let _pl2: i32 = parser_copy_module_import_path64(module, i, &path_buf[0]);
    }
    let gs3: i32 = 0;
    unsafe {
      gs3 = driver_dep_slot_for_path(&path_buf[0]);
    }
    let seed_gs: i32 = 0;
    let seed_i: i32 = 0;
    unsafe {
      if (gs3 >= 0) {
        seed_gs = driver_dep_seeded_get(gs3);
      }
      seed_i = driver_dep_seeded_get(i);
    }
    // Match C: unseeded if (gs invalid or not seeded) AND import_idx not seeded.
    if (gs3 < 0) {
      if (seed_i == 0) {
        all_seeded = 0;
        break;
      }
    } else {
      if (seed_gs == 0) {
        if (seed_i == 0) {
          all_seeded = 0;
          break;
        }
      }
    }
    i = i + 1;
  }
  if (all_seeded == 0) {
    unsafe {
      // wave97: G.7 typeck.x authority - single merge/wpo path (not typeck_typeck_* hop).
      typeck_merge_dep_struct_layouts_into_entry(module, arena, ctx);
      typeck_wpo_unify_soa_layouts(module, ctx);
    }
  }
  return 0;
}

/**
 * Thin gate for dep prerun typeck-only (null / empty source / missing ctx rejected).
 * @param dep_mod *u8 - dep AST module; null -> -1
 * @param dep_arena *u8 - dep AST arena; null -> -1
 * @param src *u8 - source bytes; null -> -1
 * @param len i64 - byte length; <=0 -> -1
 * @param dep_out *u8 - optional unused out (forwarded)
 * @param one_ctx *u8 - PipelineDepCtx; null -> -1
 * @return i32 - typeck path rc; -1 on thin reject
 * wave60: body in pure xlang_pipeline_dep_prerun_typeck_only_impl.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_pipeline_dep_prerun_typeck_only(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32 {
  if (dep_mod == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_arena == 0 as *u8) {
    return 0 - 1;
  }
  if (src == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  if (one_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    return xlang_pipeline_dep_prerun_typeck_only_impl(dep_mod, dep_arena, src, len, dep_out, one_ctx);
  }
  return 0 - 1;
}

// xlang_pipeline_dep_prerun_for_asm_module_o: see function docblock below.
/** Exported function `xlang_pipeline_dep_prerun_for_asm_module_o`.
 * Implements `xlang_pipeline_dep_prerun_for_asm_module_o`.
 * @param dep_mod *u8
 * @param dep_arena *u8
 * @param src *u8
 * @param len i64
 * @param dep_out *u8
 * @param one_ctx *u8
 * @return i32
 */
#[no_mangle]
export function xlang_pipeline_dep_prerun_for_asm_module_o(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32 {
  return xlang_pipeline_dep_prerun_typeck_only(dep_mod, dep_arena, src, len, dep_out, one_ctx);
}

// pipe_path_readable: see function docblock below.
/** Exported function `pipe_path_readable`.
 * Read path helper `pipe_path_readable`.
 * @param path *u8
 * @return i32
 */
export function pipe_path_readable(path: *u8): i32 {
  if (path == 0 as *u8) { return 0; }
  unsafe {
    if (access(path, 4) == 0) { return 1; }
  }
  return 0;
}

/** Exported function `pipe_cstr_has_char`.
 * Implements `pipe_cstr_has_char`.
 * @param s *u8
 * @param ch u8
 * @return i32
 */
export function pipe_cstr_has_char(s: *u8, ch: u8): i32 {
  if (s == 0 as *u8) { return 0; }
  let i: i32 = 0;
  while (i < 4096) {
    if (s[i] == 0) { return 0; }
    if (s[i] == ch) { return 1; }
    i = i + 1;
  }
  return 0;
}

// pipe_write_nested_name_x: see function docblock below.
/** Exported function `pipe_write_nested_name_x`.
 * Write path helper `pipe_write_nested_name_x`.
 * @param dst *u8
 * @param cap i32
 * @param root *u8
 * @param name *u8
 * @return void
 */
export function pipe_write_nested_name_x(dst: *u8, cap: i32, root: *u8, name: *u8): void {
  if (dst == 0 as *u8) { return; }
  if (cap <= 0) { return; }
  let off: i32 = 0;
  unsafe {
    if (root != 0 as *u8) {
      let i: i32 = 0;
      while (i < 4096) {
        if (root[i] == 0) { break; }
        if (off + 1 >= cap) { break; }
        dst[off] = root[i];
        off = off + 1;
        i = i + 1;
      }
    }
    if (off + 1 < cap) { dst[off] = 47; off = off + 1; }
    if (name != 0 as *u8) {
      let j: i32 = 0;
      while (j < 4096) {
        if (name[j] == 0) { break; }
        if (off + 1 >= cap) { break; }
        dst[off] = name[j];
        off = off + 1;
        j = j + 1;
      }
    }
    if (off + 1 < cap) { dst[off] = 47; off = off + 1; }
    if (name != 0 as *u8) {
      let k: i32 = 0;
      while (k < 4096) {
        if (name[k] == 0) { break; }
        if (off + 1 >= cap) { break; }
        dst[off] = name[k];
        off = off + 1;
        k = k + 1;
      }
    }
    if (off + 2 < cap) {
      dst[off] = 46; dst[off + 1] = 120; dst[off + 2] = 0;
    } else if (off < cap) {
      dst[off] = 0;
    } else {
      dst[cap - 1] = 0;
    }
  }
}

// pipe_write_root_dotted_imp: see function docblock below.
/** Exported function `pipe_write_root_dotted_imp`.
 * Write path helper `pipe_write_root_dotted_imp`.
 * @param dst *u8
 * @param cap i32
 * @param root *u8
 * @param imp *u8
 * @return i32
 */
export function pipe_write_root_dotted_imp(dst: *u8, cap: i32, root: *u8, imp: *u8): i32 {
  if (dst == 0 as *u8) { return 0; }
  if (cap <= 0) { return 0; }
  let off: i32 = 0;
  unsafe {
    if (root != 0 as *u8) {
      let i: i32 = 0;
      while (i < 4096) {
        if (root[i] == 0) { break; }
        if (off + 1 >= cap) { break; }
        dst[off] = root[i];
        off = off + 1;
        i = i + 1;
      }
    }
    if (off + 1 < cap) { dst[off] = 47; off = off + 1; }
    if (imp != 0 as *u8) {
      let j: i32 = 0;
      while (j < 4096) {
        if (imp[j] == 0) { break; }
        if (off + 1 >= cap) { break; }
        let ch: u8 = imp[j];
        if (ch == 46) { dst[off] = 47; } else { dst[off] = ch; }
        off = off + 1;
        j = j + 1;
      }
    }
    if (off < cap) { dst[off] = 0; } else { dst[cap - 1] = 0; }
  }
  return off;
}

/** Exported function `pipe_append_suffix`.
 * Implements `pipe_append_suffix`.
 * @param dst *u8
 * @param cap i32
 * @param off i32
 * @param suf *u8
 * @return void
 */
export function pipe_append_suffix(dst: *u8, cap: i32, off: i32, suf: *u8): void {
  if (dst == 0 as *u8) { return; }
  if (suf == 0 as *u8) { return; }
  if (cap <= 0) { return; }
  let o: i32 = off;
  let si: i32 = 0;
  unsafe {
    while (si < 16) {
      if (suf[si] == 0) { break; }
      if (o + 1 >= cap) { break; }
      dst[o] = suf[si];
      o = o + 1;
      si = si + 1;
    }
    if (o < cap) { dst[o] = 0; } else { dst[cap - 1] = 0; }
  }
}

/**
 * Byte-offset a C string pointer (null-safe; negative off -> base).
 * @param s *u8 - base C string or byte buffer; null -> null
 * @param off i32 - byte offset from s; off < 0 -> return s unchanged
 * @return *u8 - s+off (as &s[off]); null when s is null
 * wave76 pure: G.7 single authority for pipe_dir_tail / pipe_strip_prefix_seg / driver -D
 * parse (driver_abi imports this symbol). Codegen emits C `&((s)[off])` ≡ s+off on LP64.
 * Historical Cap residual claimed ".x has no reliable pointer arithmetic"; pure index
 * address-of closes that leaf without a C helper.
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function xlang_cstr_offset(s: *u8, off: i32): *u8 {
  if (s == 0 as *u8) {
    return 0 as *u8;
  }
  if (off < 0) {
    return s;
  }
  unsafe {
    return &s[off];
  }
  return s;
}

// pipe_dir_tail: see function docblock below.
/**
 * Basename segment of a directory path (bytes after last '/'; whole path if none).
 * @param entry_dir *u8 - directory path; null -> null
 * @return *u8 - pointer into entry_dir at last slash+1 (or entry_dir); lifetime = entry_dir
 * wave76: G.7 pure xlang_cstr_offset for tail pointer (no Cap residual).
 * PLATFORM: SHARED.
 */
export function pipe_dir_tail(entry_dir: *u8): *u8 {
  if (entry_dir == 0 as *u8) { return 0 as *u8; }
  let last: i32 = 0 - 1;
  let i: i32 = 0;
  unsafe {
    while (i < 4096) {
      if (entry_dir[i] == 0) { break; }
      if (entry_dir[i] == 47) { last = i; }
      i = i + 1;
    }
    if (last < 0) { return entry_dir; }
    return xlang_cstr_offset(entry_dir, last + 1);
  }
  return entry_dir;
}

// pipe_strip_prefix_seg: see function docblock below.
/** Exported function `pipe_strip_prefix_seg`.
 * Implements `pipe_strip_prefix_seg`.
 * @param import_path *u8
 * @param dir_tail *u8
 * @return *u8
 */
export function pipe_strip_prefix_seg(import_path: *u8, dir_tail: *u8): *u8 {
  if (import_path == 0 as *u8) { return import_path; }
  if (dir_tail == 0 as *u8) { return import_path; }
  unsafe {
    let tl: i32 = pipe_cstr_len(dir_tail);
    let i: i32 = 0;
    while (i < tl) {
      if (import_path[i] == 0) { return import_path; }
      if (import_path[i] != dir_tail[i]) { return import_path; }
      i = i + 1;
    }
    if (import_path[tl] == 46) {
      return xlang_cstr_offset(import_path, tl + 1);
    }
  }
  return import_path;
}

// xlang_resolve_import_file_path_multi: see function docblock below.
/** Exported function `xlang_resolve_import_file_path_multi`.
 * Implements `xlang_resolve_import_file_path_multi`.
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @param entry_dir *u8
 * @param import_path *u8
 * @param path *u8
 * @param path_size i64
 * @return void
 */
#[no_mangle]
export function xlang_resolve_import_file_path_multi(lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, import_path: *u8, path: *u8, path_size: i64): void {
  if (path == 0 as *u8) {
    return;
  }
  if (path_size == 0) {
    return;
  }
  if (import_path == 0 as *u8) {
    unsafe {
      path[0] = 0;
    }
    return;
  }
  let cap: i32 = path_size as i32;
  if (cap <= 0) {
    return;
  }
  // See implementation.
  if (xlang_import_path_is_file_path(import_path) != 0) {
    xlang_resolve_file_import_path(entry_dir, import_path, path, path_size);
    if (pipe_path_readable(path) != 0) { return; }
    unsafe {
      if (import_path[0] != 47) {
        pipe_cstr_copy(path, cap, import_path);
        if (pipe_path_readable(path) != 0) { return; }
      }
    }
  }
  // -L roots
  let r: i32 = 0;
  while (r < n_lib_roots) {
    let lib_root: *u8 = 0 as *u8;
    unsafe {
      if (lib_roots != 0 as *u8) {
        lib_root = pipe_load_ptr_slot(lib_roots, r);
      }
    }
    let use_root: *u8 = lib_root;
    let dot: u8[2] = [];
    dot[0] = 46;
    dot[1] = 0;
    if (use_root == 0 as *u8) {
      use_root = &dot[0];
    } else {
      unsafe {
        if (use_root[0] == 0) { use_root = &dot[0]; }
      }
    }
    xlang_import_path_to_file_path(use_root, import_path, path, path_size);
    if (pipe_path_readable(path) != 0) { return; }
    // See implementation.
    if (pipe_cstr_has_char(import_path, 46) == 0) {
      if (path_size >= 16) {
        let n: i32 = pipe_cstr_len(import_path);
        if (n > 0) {
          if (n < 64) {
            pipe_write_nested_name_x(path, cap, use_root, import_path);
            if (pipe_path_readable(path) != 0) { return; }
          }
        }
      }
    } else {
      if (path_size >= 16) {
        let off: i32 = pipe_write_root_dotted_imp(path, cap, use_root, import_path);
        let modx: u8[8] = [];
        modx[0] = 47; modx[1] = 109; modx[2] = 111; modx[3] = 100; modx[4] = 46; modx[5] = 120; modx[6] = 0;
        if (off + 8 <= cap) {
          pipe_append_suffix(path, cap, off, &modx[0]);
          if (pipe_path_readable(path) != 0) { return; }
        }
        xlang_import_path_to_file_path(use_root, import_path, path, path_size);
        if (pipe_path_readable(path) != 0) { return; }
      }
    }
    r = r + 1;
  }
  // See implementation.
  if (entry_dir != 0 as *u8) {
    unsafe {
      if (entry_dir[0] != 0) {
        if (pipe_cstr_has_char(import_path, 46) == 0) {
          let off2: i32 = pipe_write_root_dotted_imp(path, cap, entry_dir, import_path);
          // pipe_write already did entry/import with dots; for no-dot it's entry/import
          // need entry/import.x
          let dx: u8[4] = [];
          dx[0] = 46; dx[1] = 120; dx[2] = 0;
          pipe_append_suffix(path, cap, off2, &dx[0]);
          if (pipe_path_readable(path) != 0) { return; }
        } else {
          if (path_size >= 16) {
            let tail: *u8 = pipe_dir_tail(entry_dir);
            let eff: *u8 = pipe_strip_prefix_seg(import_path, tail);
            let off3: i32 = pipe_write_root_dotted_imp(path, cap, entry_dir, eff);
            let dx2: u8[4] = [];
            dx2[0] = 46; dx2[1] = 120; dx2[2] = 0;
            if (off3 + 3 <= cap) {
              pipe_append_suffix(path, cap, off3, &dx2[0]);
              if (pipe_path_readable(path) != 0) { return; }
            }
            let modx2: u8[8] = [];
            modx2[0] = 47; modx2[1] = 109; modx2[2] = 111; modx2[3] = 100;
            modx2[4] = 46; modx2[5] = 120; modx2[6] = 0;
            if (off3 + 8 <= cap) {
              pipe_append_suffix(path, cap, off3, &modx2[0]);
              if (pipe_path_readable(path) != 0) { return; }
            }
          }
        }
      }
    }
  }
  // wave1222: sibling-directory scan fallback. Delegates to helper to keep
  // this function within typeck complexity budget (deep nesting caused
  // cascading T001 in subsequent functions during directory check).
  // PLATFORM: POSIX (opendir/readdir via xlang_fmt_*); Windows cold seed C rest.
  xlang_resolve_import_sibling_scan(entry_dir, import_path, path, cap);
}

/**
 * Sibling-directory scan for import path resolution.
 * When import("token") from parser/parser.x has token.x at lexer/token.x
 * (sibling dir under same src/ root), all preceding lookups fail. Scan
 * entry_dir's parent for sibling subdirs containing <name>.x or
 * <name>/<name>.x. For dotted imports like "platform.elf" where no sibling
 * dir matches the first segment, tries each sibling as parent (deep scan)
 * to find nested paths like src/asm/platform/elf.x.
 * Seed twin: runtime_pipeline_abi.from_x.c sibling scan (same semantics).
 * PLATFORM: POSIX (opendir/readdir via xlang_fmt_*); Windows cold seed C rest.
 */
#[no_mangle]
export function xlang_resolve_import_sibling_scan(entry_dir: *u8, import_path: *u8, path: *u8, cap: i32): void {
  if (entry_dir == 0 as *u8) { return; }
  if (import_path == 0 as *u8) { return; }
  if (path == 0 as *u8) { return; }
  if (cap < 16) { return; }
  unsafe {
    if (entry_dir[0] == 0) { return; }
    let sib_last_slash: i32 = 0 - 1;
    let sib_ei: i32 = 0;
    while (sib_ei < 4096) {
      if (entry_dir[sib_ei] == 0) { break; }
      if (entry_dir[sib_ei] == 47) { sib_last_slash = sib_ei; }
      sib_ei = sib_ei + 1;
    }
    if (sib_last_slash <= 0) { return; }
    if (sib_last_slash >= 480) { return; }
    let sib_parent: u8[512] = [];
    // Temp buffer for opendir probe: <sib_parent>/<sib_dn>
    let sib_dir_probe: u8[512] = [];
    let sib_pi: i32 = 0;
    while (sib_pi < sib_last_slash) {
      sib_parent[sib_pi] = entry_dir[sib_pi];
      sib_pi = sib_pi + 1;
    }
    sib_parent[sib_last_slash] = 0;
    let sib_d: *u8 = xlang_fmt_opendir(&sib_parent[0]);
    if (sib_d == 0 as *u8) { return; }
    let sib_guard: i32 = 0;
    let sib_done: i32 = 0;
    while (sib_guard < 100000) {
      sib_guard = sib_guard + 1;
      if (sib_done != 0) { break; }
      let sib_dn: *u8 = xlang_fmt_readdir_name(sib_d);
      if (sib_dn == 0 as *u8) { break; }
      if (sib_dn[0] == 46) { continue; }
      // Skip non-directory entries: construct <parent>/<sib_dn> and opendir probe.
      // Without this, files like seed_link_compat.o are treated as directories,
      // producing bogus import paths like src/seed_link_compat.o/asm/backend.x.
      let sib_dir_probe_off: i32 = 0;
      while (sib_dir_probe_off < 510) {
        let sib_dpc: u8 = sib_parent[sib_dir_probe_off];
        sib_dir_probe[sib_dir_probe_off] = sib_dpc;
        if (sib_dpc == 0) { break; }
        sib_dir_probe_off = sib_dir_probe_off + 1;
      }
      if (sib_dir_probe_off < 510) {
        sib_dir_probe[sib_dir_probe_off] = 47;
        sib_dir_probe_off = sib_dir_probe_off + 1;
        let sib_dpi: i32 = 0;
        while (sib_dir_probe_off < 510) {
          let sib_dpc2: u8 = sib_dn[sib_dpi];
          if (sib_dpc2 == 0) { break; }
          sib_dir_probe[sib_dir_probe_off] = sib_dpc2;
          sib_dir_probe_off = sib_dir_probe_off + 1;
          sib_dpi = sib_dpi + 1;
        }
        sib_dir_probe[sib_dir_probe_off] = 0;
      }
      let sib_dir_handle: *u8 = xlang_fmt_opendir(&sib_dir_probe[0]);
      if (sib_dir_handle == 0 as *u8) { continue; }
      xlang_fmt_closedir(sib_dir_handle);
      let sib_has_dot: i32 = pipe_cstr_has_char(import_path, 46);
      if (sib_has_dot == 0) {
        // Single-segment: <parent>/<sibling>/<name>.x
        let sib_off: i32 = 0;
        while (sib_off < 511) {
          let sib_c: u8 = sib_parent[sib_off];
          path[sib_off] = sib_c;
          if (sib_c == 0) { break; }
          sib_off = sib_off + 1;
        }
        if (sib_off < 510) {
          path[sib_off] = 47;
          sib_off = sib_off + 1;
          let sib_si: i32 = 0;
          while (sib_off < 510) {
            let sib_c2: u8 = sib_dn[sib_si];
            if (sib_c2 == 0) { break; }
            path[sib_off] = sib_c2;
            sib_off = sib_off + 1;
            sib_si = sib_si + 1;
          }
          if (sib_off < 510) {
            path[sib_off] = 47;
            sib_off = sib_off + 1;
            let sib_ii: i32 = 0;
            while (sib_off < 510) {
              let sib_c3: u8 = import_path[sib_ii];
              if (sib_c3 == 0) { break; }
              path[sib_off] = sib_c3;
              sib_off = sib_off + 1;
              sib_ii = sib_ii + 1;
            }
            if (sib_off + 2 < cap) {
              path[sib_off] = 46;
              sib_off = sib_off + 1;
              path[sib_off] = 120;
              sib_off = sib_off + 1;
              path[sib_off] = 0;
              if (pipe_path_readable(path) != 0) {
                sib_done = 1;
              }
            }
          }
        }
        // Nested: <parent>/<sibling>/<name>/<name>.x
        if (sib_done == 0) {
          let sib_imp_len: i32 = pipe_cstr_len(import_path);
          if (sib_imp_len > 0) {
            if (sib_imp_len < 64) {
              let sib_off2: i32 = 0;
              while (sib_off2 < 511) {
                let sib_c4: u8 = sib_parent[sib_off2];
                path[sib_off2] = sib_c4;
                if (sib_c4 == 0) { break; }
                sib_off2 = sib_off2 + 1;
              }
              if (sib_off2 < 510) {
                path[sib_off2] = 47;
                sib_off2 = sib_off2 + 1;
                let sib_si2: i32 = 0;
                while (sib_off2 < 510) {
                  let sib_c5: u8 = sib_dn[sib_si2];
                  if (sib_c5 == 0) { break; }
                  path[sib_off2] = sib_c5;
                  sib_off2 = sib_off2 + 1;
                  sib_si2 = sib_si2 + 1;
                }
                if (sib_off2 < 510) {
                  path[sib_off2] = 47;
                  sib_off2 = sib_off2 + 1;
                  let sib_ii2: i32 = 0;
                  while (sib_off2 < 510) {
                    let sib_c6: u8 = import_path[sib_ii2];
                    if (sib_c6 == 0) { break; }
                    path[sib_off2] = sib_c6;
                    sib_off2 = sib_off2 + 1;
                    sib_ii2 = sib_ii2 + 1;
                  }
                  if (sib_off2 < 510) {
                    path[sib_off2] = 47;
                    sib_off2 = sib_off2 + 1;
                    let sib_ii3: i32 = 0;
                    while (sib_off2 < 510) {
                      let sib_c7: u8 = import_path[sib_ii3];
                      if (sib_c7 == 0) { break; }
                      path[sib_off2] = sib_c7;
                      sib_off2 = sib_off2 + 1;
                      sib_ii3 = sib_ii3 + 1;
                    }
                    if (sib_off2 + 2 < cap) {
                      path[sib_off2] = 46;
                      sib_off2 = sib_off2 + 1;
                      path[sib_off2] = 120;
                      sib_off2 = sib_off2 + 1;
                      path[sib_off2] = 0;
                      if (pipe_path_readable(path) != 0) {
                        sib_done = 1;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      } else {
        // Dotted: <parent>/<sibling>/<dotted-as-slashes>.x
        // First pass: sibling dir name must match first dotted segment.
        let sib_fsl: i32 = 0;
        while (import_path[sib_fsl] != 0) {
          if (import_path[sib_fsl] == 46) { break; }
          sib_fsl = sib_fsl + 1;
        }
        if (sib_fsl > 0) {
          if (sib_fsl < 64) {
            let sib_match: i32 = 1;
            let sib_ci: i32 = 0;
            while (sib_ci < sib_fsl) {
              if (sib_dn[sib_ci] != import_path[sib_ci]) { sib_match = 0; break; }
              sib_ci = sib_ci + 1;
            }
            if (sib_match != 0) {
              if (sib_dn[sib_fsl] == 0) {
                let sib_doff: i32 = 0;
                while (sib_doff < 511) {
                  let sib_dc: u8 = sib_parent[sib_doff];
                  path[sib_doff] = sib_dc;
                  if (sib_dc == 0) { break; }
                  sib_doff = sib_doff + 1;
                }
                if (sib_doff < 510) {
                  path[sib_doff] = 47;
                  sib_doff = sib_doff + 1;
                  let sib_dsi: i32 = 0;
                  while (sib_doff < 510) {
                    let sib_dc2: u8 = sib_dn[sib_dsi];
                    if (sib_dc2 == 0) { break; }
                    path[sib_doff] = sib_dc2;
                    sib_doff = sib_doff + 1;
                    sib_dsi = sib_dsi + 1;
                  }
                  if (sib_doff < 510) {
                    path[sib_doff] = 47;
                    sib_doff = sib_doff + 1;
                    let sib_dii: i32 = 0;
                    while (sib_doff < 510) {
                      let sib_dc3: u8 = import_path[sib_dii];
                      if (sib_dc3 == 0) { break; }
                      if (sib_dc3 == 46) {
                        path[sib_doff] = 47;
                      } else {
                        path[sib_doff] = sib_dc3;
                      }
                      sib_doff = sib_doff + 1;
                      sib_dii = sib_dii + 1;
                    }
                    if (sib_doff + 2 < cap) {
                      path[sib_doff] = 46;
                      sib_doff = sib_doff + 1;
                      path[sib_doff] = 120;
                      sib_doff = sib_doff + 1;
                      path[sib_doff] = 0;
                      if (pipe_path_readable(path) != 0) {
                        sib_done = 1;
                      }
                    }
                    if (sib_done == 0) {
                      if (sib_doff + 6 < cap) {
                        path[sib_doff] = 47;
                        sib_doff = sib_doff + 1;
                        path[sib_doff] = 109;
                        sib_doff = sib_doff + 1;
                        path[sib_doff] = 111;
                        sib_doff = sib_doff + 1;
                        path[sib_doff] = 100;
                        sib_doff = sib_doff + 1;
                        path[sib_doff] = 46;
                        sib_doff = sib_doff + 1;
                        path[sib_doff] = 120;
                        sib_doff = sib_doff + 1;
                        path[sib_doff] = 0;
                        if (pipe_path_readable(path) != 0) {
                          sib_done = 1;
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    xlang_fmt_closedir(sib_d);
    // Deep sibling scan: for dotted imports where no sibling dir
    // matches the first segment, try each sibling as parent.
    // Finds src/asm/platform/elf.x for import("platform.elf")
    // resolved from pipeline/ (transitive from asm/backend.x).
    if (sib_done == 0) {
      let sib_d2: *u8 = xlang_fmt_opendir(&sib_parent[0]);
      if (sib_d2 != 0 as *u8) {
        let sib_guard2: i32 = 0;
        while (sib_guard2 < 100000) {
          sib_guard2 = sib_guard2 + 1;
          if (sib_done != 0) { break; }
          let sib_dn2: *u8 = xlang_fmt_readdir_name(sib_d2);
          if (sib_dn2 == 0 as *u8) { break; }
          if (sib_dn2[0] == 46) { continue; }
          // Skip non-directory entries (same fix as first-pass sibling scan).
          let sib_dp2_off: i32 = 0;
          while (sib_dp2_off < 510) {
            let sib_dp2c: u8 = sib_parent[sib_dp2_off];
            sib_dir_probe[sib_dp2_off] = sib_dp2c;
            if (sib_dp2c == 0) { break; }
            sib_dp2_off = sib_dp2_off + 1;
          }
          if (sib_dp2_off < 510) {
            sib_dir_probe[sib_dp2_off] = 47;
            sib_dp2_off = sib_dp2_off + 1;
            let sib_dp2i: i32 = 0;
            while (sib_dp2_off < 510) {
              let sib_dp2c2: u8 = sib_dn2[sib_dp2i];
              if (sib_dp2c2 == 0) { break; }
              sib_dir_probe[sib_dp2_off] = sib_dp2c2;
              sib_dp2_off = sib_dp2_off + 1;
              sib_dp2i = sib_dp2i + 1;
            }
            sib_dir_probe[sib_dp2_off] = 0;
          }
          let sib_dir_handle2: *u8 = xlang_fmt_opendir(&sib_dir_probe[0]);
          if (sib_dir_handle2 == 0 as *u8) { continue; }
          xlang_fmt_closedir(sib_dir_handle2);
          let sib_doff2: i32 = 0;
          while (sib_doff2 < 511) {
            let sib_dc4: u8 = sib_parent[sib_doff2];
            path[sib_doff2] = sib_dc4;
            if (sib_dc4 == 0) { break; }
            sib_doff2 = sib_doff2 + 1;
          }
          if (sib_doff2 < 510) {
            path[sib_doff2] = 47;
            sib_doff2 = sib_doff2 + 1;
            let sib_dsi2: i32 = 0;
            while (sib_doff2 < 510) {
              let sib_dc5: u8 = sib_dn2[sib_dsi2];
              if (sib_dc5 == 0) { break; }
              path[sib_doff2] = sib_dc5;
              sib_doff2 = sib_doff2 + 1;
              sib_dsi2 = sib_dsi2 + 1;
            }
            if (sib_doff2 < 510) {
              path[sib_doff2] = 47;
              sib_doff2 = sib_doff2 + 1;
              let sib_dii2: i32 = 0;
              while (sib_doff2 < 510) {
                let sib_dc6: u8 = import_path[sib_dii2];
                if (sib_dc6 == 0) { break; }
                if (sib_dc6 == 46) {
                  path[sib_doff2] = 47;
                } else {
                  path[sib_doff2] = sib_dc6;
                }
                sib_doff2 = sib_doff2 + 1;
                sib_dii2 = sib_dii2 + 1;
              }
              if (sib_doff2 + 2 < cap) {
                path[sib_doff2] = 46;
                sib_doff2 = sib_doff2 + 1;
                path[sib_doff2] = 120;
                sib_doff2 = sib_doff2 + 1;
                path[sib_doff2] = 0;
                if (pipe_path_readable(path) != 0) {
                  sib_done = 1;
                }
              }
            }
          }
        }
        xlang_fmt_closedir(sib_d2);
      }
    }
  }
}

/* See implementation. */

/**
 * LP64 offsetof(ast_PipelineDepCtx, entry_dir_buf) - layout authority runtime_pipeline_abi.h.
 * PLATFORM: SHARED LP64 (Ubuntu x86_64 + Darwin arm64/x86_64).
 */
function pipe_pctx_off_entry_dir_buf(): i32 {
  return 4;
}

/**
 * LP64 offsetof(ast_PipelineDepCtx, entry_dir_len).
 * PLATFORM: SHARED LP64.
 */
function pipe_pctx_off_entry_dir_len(): i32 {
  return 516;
}

/**
 * LP64 offsetof(ast_PipelineDepCtx, num_lib_roots).
 * PLATFORM: SHARED LP64.
 */
function pipe_pctx_off_num_lib_roots(): i32 {
  return 520;
}

/**
 * LP64 offsetof(ast_PipelineDepCtx, loaded_len) - ptrdiff_t / i64 cell.
 * PLATFORM: SHARED LP64.
 */
function pipe_pctx_off_loaded_len(): i32 {
  return 4195344;
}

/**
 * LP64 offsetof(ast_PipelineDepCtx, preprocess_len).
 * PLATFORM: SHARED LP64.
 */
function pipe_pctx_off_preprocess_len(): i32 {
  return 8389656;
}

/**
 * Store host LE i32 at base[off..off+3]. Null base or off negative -> no-op.
 * @param base *u8 - object base
 * @param off i32 - byte offset
 * @param v i32 - value
 * @return void
 * G.7 same pattern as driver_abi_store_i32_le (wave19); local copy - not exported.
 * PLATFORM: SHARED LP64 little-endian.
 */
function pipe_store_i32_le(base: *u8, off: i32, v: i32): void {
  if (base == 0 as *u8) {
    return;
  }
  if (off < 0) {
    return;
  }
  unsafe {
    let u: u32 = v as u32;
    base[off] = (u & 255) as u8;
    base[off + 1] = ((u / 256) & 255) as u8;
    base[off + 2] = ((u / 65536) & 255) as u8;
    base[off + 3] = ((u / 16777216) & 255) as u8;
  }
}

/**
 * Load host LE i32 from base[off..off+3]. Null base or off negative -> 0.
 * @param base *u8 - object base
 * @param off i32 - byte offset
 * @return i32 - signed value (u32 reconstruct then cast)
 * G.7 pair of pipe_store_i32_le; local - not exported.
 * PLATFORM: SHARED LP64 little-endian.
 */
function pipe_load_i32_le(base: *u8, off: i32): i32 {
  if (base == 0 as *u8) {
    return 0;
  }
  if (off < 0) {
    return 0;
  }
  let b0: u32 = 0;
  let b1: u32 = 0;
  let b2: u32 = 0;
  let b3: u32 = 0;
  unsafe {
    b0 = base[off] as u32;
    b1 = base[off + 1] as u32;
    b2 = base[off + 2] as u32;
    b3 = base[off + 3] as u32;
  }
  let u: u32 = b0 + b1 * 256 + b2 * 65536 + b3 * 16777216;
  return u as i32;
}

/**
 * Store eight zero bytes at base[off..off+7] (clear ptrdiff_t / i64 cell).
 * Null base or off negative -> no-op. wave67 only needs clear (loaded_len=0).
 * @param base *u8 - object base
 * @param off i32 - byte offset
 * @return void
 * PLATFORM: SHARED LP64.
 */
function pipe_store_i64_zero(base: *u8, off: i32): void {
  if (base == 0 as *u8) {
    return;
  }
  if (off < 0) {
    return;
  }
  pipe_store_i32_le(base, off, 0);
  pipe_store_i32_le(base, off + 4, 0);
}

/**
 * Clear PipelineDepCtx path/source length cells used by fill_ctx orch.
 * @param ctx *u8 - opaque ast_PipelineDepCtx; null -> no-op
 * @return void
 * wave67 pure: zeros loaded_len (i64), preprocess_len, entry_dir_len, num_lib_roots
 *   via LP64 offsetof + LE store (no C struct in .x). Does not clear buffer bytes.
 * PLATFORM: SHARED LP64 - cold twin under non-FROM_X keeps C field writes.
 */
#[no_mangle]
export function pipeline_dep_ctx_path_bufs_reset(ctx: *u8): void {
  if (ctx == 0 as *u8) {
    return;
  }
  pipe_store_i64_zero(ctx, pipe_pctx_off_loaded_len());
  pipe_store_i32_le(ctx, pipe_pctx_off_preprocess_len(), 0);
  pipe_store_i32_le(ctx, pipe_pctx_off_entry_dir_len(), 0);
  pipe_store_i32_le(ctx, pipe_pctx_off_num_lib_roots(), 0);
}

/**
 * Resolve import path into ctx.path_buf via lib_roots then entry_dir.
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @param import_path *u8 - import path bytes; null -> -1
 * @param path_len i32 - path byte length; <=0 -> -1
 * @return i32 - 0 first successful probe; -1 null/miss
 * Rules (match historical pipeline_resolve_path_x_impl_c / pipeline.x resolve_path_x):
 *   - loop lib_i while pipeline_loop_should_continue_lib_root_c(ctx, lib_i);
 *     on pipeline_resolve_path_try_one_lib_root == 0 return 0
 *   - else pipeline_resolve_path_try_entry_dir; 0 -> success else -1
 * wave95 pure Cap residual: G.7 product authority for pipeline_resolve_path_x
 * (historical glue weak -> impl_c). Reuses G.7 try_one / try_entry product surface
 * (pipeline.x pure helpers already linked; no second path-build body).
 * PLATFORM: SHARED - glue keeps XLANG_WEAK cold twin for non-PREFER links.
 */
#[no_mangle]
export function pipeline_resolve_path_x(ctx: *u8, import_path: *u8, path_len: i32): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (import_path == 0 as *u8) {
    return 0 - 1;
  }
  if (path_len <= 0) {
    return 0 - 1;
  }
  let lib_i: i32 = 0;
  while (1 == 1) {
    let cont: i32 = 0;
    unsafe {
      cont = pipeline_loop_should_continue_lib_root_c(ctx, lib_i);
    }
    if (cont == 0) {
      break;
    }
    let try_rc: i32 = 0;
    unsafe {
      try_rc = pipeline_resolve_path_try_one_lib_root(ctx, lib_i, import_path, path_len);
    }
    if (try_rc == 0) {
      return 0;
    }
    lib_i = lib_i + 1;
  }
  let entry_rc: i32 = 0;
  unsafe {
    entry_rc = pipeline_resolve_path_try_entry_dir(ctx, import_path, path_len);
  }
  if (entry_rc == 0) {
    return 0;
  }
  return 0 - 1;
}

/**
 * Read ctx.path_buf file into ctx.loaded_buf and set loaded_len.
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @return i32 - 0 ok; -1 null / open-or-read fail
 * Steps (match historical pipeline_read_file_x_impl_c):
 *   1) Cap residual path_buf_ptr + loaded_buf_ptr
 *   2) G.7 pure xlang_read_file_into_path (cap 4194304 = PIPELINE_SOURCE_BUF_CAP)
 *   3) Cap residual pipeline_dep_ctx_set_loaded_len(n) on n>=0
 * wave95 pure Cap residual: G.7 product authority for pipeline_read_file_x
 * (historical glue weak -> impl_c). PLATFORM: SHARED - glue XLANG_WEAK cold twin.
 */
#[no_mangle]
export function pipeline_read_file_x(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  let path: *u8 = 0 as *u8;
  let buf: *u8 = 0 as *u8;
  unsafe {
    path = pipeline_dep_ctx_path_buf_ptr(ctx);
    buf = pipeline_dep_ctx_loaded_buf_ptr(ctx);
  }
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  if (buf == 0 as *u8) {
    return 0 - 1;
  }
  // PIPELINE_SOURCE_BUF_CAP - same as historical C / pipeline_loaded_buf_cap.
  let cap: i64 = 4194304;
  let n: i32 = 0;
  unsafe {
    n = xlang_read_file_into_path(path, buf, cap);
  }
  if (n < 0) {
    return 0 - 1;
  }
  unsafe {
    pipeline_dep_ctx_set_loaded_len(ctx, n as i64);
  }
  return 0;
}

/**
 * Preprocess ctx.loaded_buf into ctx.preprocess_buf; set preprocess_len.
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @return i32 - 0 ok; -1 null; -9 preprocess_x_buf fail (match historical)
 * Steps (match historical pipeline_preprocess_loaded_into_ctx):
 *   1) Cap residual loaded_buf_ptr + preprocess_buf_ptr
 *   2) pure load loaded_len via LP64 offsetof + xlang_size_slot_get
 *      (offset 4195344 = slot index 524418; same as pipe_pctx_off_loaded_len)
 *   3) G.7 pure cross-TU preprocess_x_buf (preprocess.x engine)
 *   4) pure store preprocess_len via pipe_store_i32_le (wave67 offset)
 * wave95 pure Cap residual: G.7 product authority for pipeline_preprocess_loaded_into_ctx
 * (historical strong body in ast_pool). PLATFORM: SHARED - ast_pool XLANG_WEAK cold twin.
 */
#[no_mangle]
export function pipeline_preprocess_loaded_into_ctx(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  let loaded: *u8 = 0 as *u8;
  let prep: *u8 = 0 as *u8;
  unsafe {
    loaded = pipeline_dep_ctx_loaded_buf_ptr(ctx);
    prep = pipeline_dep_ctx_preprocess_buf_ptr(ctx);
  }
  if (loaded == 0 as *u8) {
    return 0 - 1;
  }
  if (prep == 0 as *u8) {
    return 0 - 1;
  }
  // loaded_len is ptrdiff_t/i64 at LP64 offset 4195344 = slot index 524418.
  let loaded_len: i64 = 0;
  unsafe {
    loaded_len = xlang_size_slot_get(ctx, 524418);
  }
  // PIPELINE_SOURCE_BUF_CAP for out_cap.
  let out_cap: i32 = 4194304;
  let out_len: i32 = 0;
  unsafe {
    out_len = preprocess_x_buf(loaded, loaded_len, prep, out_cap);
  }
  if (out_len < 0) {
    return 0 - 9;
  }
  // Match C: ctx->preprocess_len = out_len (i32 LE at pure offset).
  pipe_store_i32_le(ctx, pipe_pctx_off_preprocess_len(), out_len);
  return 0;
}

/**
 * Read ctx.preprocess_len (i32 LE at pure LP64 offsetof).
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @return i32 - preprocess_len, or -1 if ctx null
 * wave101 pure Cap residual: G.7 single product authority for
 * pipeline_dep_ctx_preprocess_len_get (historical host-cc field load in
 * pipeline_import_bind.c). PLATFORM: SHARED - sole provider after import_bind leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_preprocess_len_get(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  return pipe_load_i32_le(ctx, pipe_pctx_off_preprocess_len());
}

/**
 * Cold/seed target for pipeline.x thin: same body as pipeline_read_file_x.
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @return i32 - 0 ok; -1 fail
 * wave101 pure: G.7 single authority (historical strong body in import_bind.c).
 * PLATFORM: SHARED - sole provider after import_bind leave.
 */
#[no_mangle]
export function pipeline_read_file_x_impl_c(ctx: *u8): i32 {
  return pipeline_read_file_x(ctx);
}

/**
 * C dispatch alias: call product pure pipeline_read_file_x.
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @return i32 - 0 ok; -1 fail
 * wave101 pure: G.7 single authority (historical strong body in import_bind.c).
 * PLATFORM: SHARED - sole provider after import_bind leave.
 */
#[no_mangle]
export function pipeline_read_file_x_c(ctx: *u8): i32 {
  return pipeline_read_file_x(ctx);
}

// Cap residual POSIX read into loaded_buf (runtime_io_abi std_fs_fs_read).
export extern "C" function std_fs_fs_read(fd: i32, buf: *u8, count: i64): i64;

/**
 * Read fd into ctx.loaded_buf and set loaded_len (cap 4194304).
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @param fd i32 - open file descriptor; fd < 0 -> -1
 * @return i32 - 0 ok; -1 null/fd/read fail
 * wave101 pure: G.7 single authority (historical strong body in import_bind.c).
 * PLATFORM: SHARED - sole provider after import_bind leave.
 */
#[no_mangle]
export function pipeline_read_fd_into_loaded_buf(ctx: *u8, fd: i32): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (fd < 0) {
    return 0 - 1;
  }
  let buf: *u8 = 0 as *u8;
  unsafe {
    buf = pipeline_dep_ctx_loaded_buf_ptr(ctx);
  }
  if (buf == 0 as *u8) {
    return 0 - 1;
  }
  // PIPELINE_SOURCE_BUF_CAP
  let cap: i64 = 4194304;
  let n: i64 = 0;
  unsafe {
    n = std_fs_fs_read(fd, buf, cap);
  }
  if (n < 0) {
    return 0 - 1;
  }
  unsafe {
    pipeline_dep_ctx_set_loaded_len(ctx, n);
  }
  return 0;
}

/**
 * Parse source buffer into module (init + parse + post-parse fixup on success).
 * @param arena *u8 - AST arena; null -> -1
 * @param module *u8 - AST module; null -> -1
 * @param buf *u8 - source bytes (typically preprocess_buf); null -> -1
 * @param buf_len i32 - byte length; <=0 -> -1 (stricter than parse_into_bytes)
 * @return i32 - 0 if parser ok==0 after fixup; -1 on null/empty/any non-zero ok
 * Steps (match historical pipeline_parse_into_buf_impl_c):
 *   1) G.7 pure parser_parse_into_init (wave1222: full body matching C authority)
 *   2) G.7 pure driver_parse_into_buf_rc (unpacks Cap-struct-return ParseIntoResult.ok)
 *   3) on ok==0: same-TU pure debug_trace("parse_post") + fixup_stmt_orders +
 *      debug_trace("parse_post_fixup")
 *   4) ok==0 -> 0; any other ok (incl. -2) -> -1
 * wave96 pure Cap residual: G.7 product authority for pipeline_parse_into_buf
 * (historical glue weak -> impl_c / pipeline.x thin -> _c). Distinct from wave64
 * pipeline_parse_into_bytes (allows len==0, no post fixup/trace).
 * PLATFORM: SHARED - glue keeps XLANG_WEAK cold twin for non-PREFER links.
 */
#[no_mangle]
export function pipeline_parse_into_buf(arena: *u8, module: *u8, buf: *u8, buf_len: i32): i32 {
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (buf == 0 as *u8) {
    return 0 - 1;
  }
  // Historical C: buf_len <= 0 -> -1 (parse_into_bytes allows zero length).
  if (buf_len <= 0) {
    return 0 - 1;
  }
  unsafe {
    // Same order as historical impl_c: trait reset + source stash + init + parse.
    // wave1222: trait_reg_reset + generic_bound_stash are REQUIRED before init;
    // without them, directory-mode check leaks trait/generic state across files
    // (num_funcs drops 356->104 for this file when checked after other files).
    xlang_trait_reg_reset_c(arena);
    xlang_generic_bound_stash_source_buf_c(buf, buf_len);
    parser_parse_into_init(module, arena);
    let pr_ok: i32 = driver_parse_into_buf_rc(arena, module, buf, buf_len, 0 as *i32);
    if (pr_ok == 0) {
      // Match C post-success: optional body-trace + stmt_order fixup + re-trace.
      pipeline_debug_trace_named_func_bodies("parse_post", module, arena);
      pipeline_module_fixup_with_arena_stmt_orders(module, arena);
      pipeline_debug_trace_named_func_bodies("parse_post_fixup", module, arena);
      return 0;
    }
    return 0 - 1;
  }
  return 0 - 1;
}

/**
 * Copy entry_dir C string into pctx.entry_dir_buf (cap 512 incl NUL) and set entry_dir_len.
 * @param ctx *u8 - opaque ast_PipelineDepCtx; null -> no-op
 * @param entry_dir *u8 - NUL-terminated path; null -> no-op
 * @return void
 * wave67 pure: byte copy into ctx[entry_dir_buf_off..] then LE store entry_dir_len.
 * Truncates at 511 payload bytes. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function pipeline_dep_ctx_copy_entry_dir(ctx: *u8, entry_dir: *u8): void {
  if (ctx == 0 as *u8) {
    return;
  }
  if (entry_dir == 0 as *u8) {
    return;
  }
  let el: i32 = 0;
  unsafe {
    while (el < 511) {
      let c: u8 = entry_dir[el];
      if (c == 0) {
        break;
      }
      el = el + 1;
    }
  }
  let base_off: i32 = pipe_pctx_off_entry_dir_buf();
  let k: i32 = 0;
  unsafe {
    while (k < el) {
      ctx[base_off + k] = entry_dir[k];
      k = k + 1;
    }
    ctx[base_off + el] = 0;
  }
  pipe_store_i32_le(ctx, pipe_pctx_off_entry_dir_len(), el);
}

/**
 * Store pctx.use_asm_backend = v (null ctx no-op).
 * @param ctx *u8 - opaque ast_PipelineDepCtx
 * @param v i32 - flag value
 * @return void
 * wave67 pure thin: G.7 single authority driver_pipeline_dep_ctx_set_use_asm
 *   (driver_abi wave19 LE store). PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function pipeline_dep_ctx_set_use_asm_backend(ctx: *u8, v: i32): void {
  unsafe {
    driver_pipeline_dep_ctx_set_use_asm(ctx, v);
  }
}

// wave68 pure entry_dir BSS (G.7 single authority for resolve_path / set_entry_dir).
// PLATFORM: SHARED LP64 - same ABI as seed cold twins; hybrid pure owns these cells.
let g_pipe_entry_dir_buf: u8[512] = [];
let g_pipe_entry_dir_dot: u8[2] = [];
let g_pipe_entry_dir_is_dot: i32 = 1;

// wave69 pure resolved_path BSS (G.7 single authority for into_static + stage_prep path base).
// PLATFORM: SHARED - same ABI as seed cold static char pipeline_resolved_path_buf[512].
let g_pipe_resolved_path_buf: u8[512] = [];

// wave70 pure dep arena/module slot BSS (G.7 single authority for set_dep_slots / get_dep_*).
// PLATFORM: SHARED LP64 - 32 void* cells × 8B = 256B raw; same capacity as seed void*[32].
let g_pipe_dep_arena_slots: u8[256] = [];
let g_pipe_dep_module_slots: u8[256] = [];

// wave71 pure stage-prep BSS (owned preprocess buffer pending commit into loaded_import).
// PLATFORM: SHARED LP64 - one ptr cell + one size cell; same ABI as seed static char* + size_t.
// G.7 single authority for pure stage_prep / commit_prep; free on clear releases ownership.
let g_pipe_rf_stage_prep: u8[8] = [];
let g_pipe_rf_stage_prep_len: u8[8] = [];

// wave72 pure loaded-import BSS (committed source after stage prep commit).
// PLATFORM: SHARED LP64 - buf ptr + len + cap size cells; same ABI as seed statics.
// G.7 single authority for pure commit_from_owned / data / len_get / commit_prep path.
// Cap floor XLANG_PIPELINE_IMPORT_BUF_CAP = 4194304 (runtime_pipeline_abi.h).
let g_pipe_loaded_import_buf: u8[8] = [];
let g_pipe_loaded_import_len: u8[8] = [];
let g_pipe_loaded_import_cap: u8[8] = [];

// wave73 pure diag-emitted sticky flag BSS (G.7 single authority for reset/note/get).
// PLATFORM: SHARED - same ABI as seed static int pipeline_diag_emitted_flag (0/1 sticky).
// Consumers (rt_run_asm_backend / rt_run_compiler_parsed pure) only call reset/get accessors;
// no cross-TU raw global writes - safe pure BSS authority under hybrid PREFER.
let g_pipe_diag_emitted_flag: i32 = 0;

// wave74 pure driver_dep table BSS (G.7 single authority for seeded/publish/slot_for_path/buf).
// PLATFORM: SHARED LP64 - 32 slots each; same capacity as seed XLANG_DRIVER_DEP_SLOT_MAX.
// arena/module/path_registry = 32×void* (256B raw); seeded = 32×i32 (128B raw as i32[32]).
// No cross-TU naked global - ast_pool/glue call driver_dep_*_buf / path_registry_at accessors only.
let g_pipe_driver_dep_arena: u8[256] = [];
let g_pipe_driver_dep_module: u8[256] = [];
let g_pipe_driver_dep_path_registry: u8[256] = [];
let g_pipe_driver_dep_seeded: i32[32] = [];

// wave77 pure typeck dep sidecar BSS (G.7 single authority for C typeck_module sidecar + pure orch).
// PLATFORM: SHARED LP64 - same capacity as seed typeck_dep_*_ptrs[32] + typeck_ndep.
// Product hybrid: pure accessors only (rt_run_* pure + driver_typeck_* + pure set_dep/store);
// no cross-TU naked global under PREFER FROM_X (cold seed naked globals under #ifndef FROM_X).
// typeck_dep_module_ptrs_base returns &module table[0] as *u8 for Cap residual typeck_module void**.
let g_pipe_typeck_ndep: i32 = 0;
let g_pipe_typeck_dep_module_ptrs: u8[256] = [];
let g_pipe_typeck_dep_arena_ptrs: u8[256] = [];

// wave85 pure preprocess -D define table (G.7 single authority for product define_has/eval).
// PLATFORM: SHARED - same capacity as glue PREPROCESS_MAX_DEFINES=128 × name[128].
// Flat layout: slot i occupies bytes [i*64 .. i*64+63], NUL-terminated name (len 1..63).
// Product hybrid: pure strong override of glue XLANG_WEAK cold fallback in strict_glue_stubs.
// wave88: pure preprocess_eval_condition_c -> same-TU preprocess_define_has (simple names);
//   complex #if still Cap residual cfg_eval_expr_c (lexer/cfg_eval authority).
let g_pipe_pp_defines: u8[8192] = [];
let g_pipe_pp_ndefines: i32 = 0;

// wave86 pure preprocess #if nesting stack (G.7 single authority for product if_stack).
// PLATFORM: SHARED - fixed cap 32 i32 slots (historical fixed stack before ast_pool GrowVec).
// Layout: g_pipe_pp_if_stack[0 .. n) live; g_pipe_pp_if_n = depth (0..32).
// Product hybrid: pure override of ast_pool XLANG_WEAK GrowVec cold fallback
// (pipeline_x.o / pipeline_glue_standalone.o embed the weak cold body).
// preprocess.x thin wrappers + preprocess_x_buf call these by C link name.
let g_pipe_pp_if_stack: i32[32] = [];
let g_pipe_pp_if_n: i32 = 0;

// wave104 pure emit_sidecar leave (was pipeline_emit_sidecar.c host-cc residual).
// PLATFORM: SHARED - fixed-cap tables replace GrowVec DriverEmitSidecar + AsmQualSymScratch.
// Caps: 64 state slots (≡ MAX_DRIVER_EMIT_SIDECARS); 32 -L roots/slot (product -L is tiny;
//   historical GrowVec init 256 was headroom, not product need); path row 256B;
//   32 qual field layers × 64B (typeck layer_buf[64]; clamp name ≤ 63, not historical 127).
// Layout emit: used[i] + state ptr slot i + n[i] + rows[i*32+r][256] + lens[i*32+r].
// Layout qual: n + rows[layer*64 ..] + lens[layer].
// release marks slot free so directory-check multi-state does not exhaust the table.
let g_pipe_emit_used: i32[64] = [];
let g_pipe_emit_state: u8[512] = [];
let g_pipe_emit_n: i32[64] = [];
let g_pipe_emit_rows: u8[524288] = [];
let g_pipe_emit_lens: i32[2048] = [];
let g_pipe_qual_n: i32 = 0;
let g_pipe_qual_rows: u8[2048] = [];
let g_pipe_qual_lens: i32[32] = [];

// wave114 pure asm_ctx_loop leave (was pipeline_asm_ctx_loop.c host-cc residual).
// PLATFORM: SHARED - fixed-cap tables replace AsmLoopLabelsSidecar + AsmBlockEmitCont.
// Caps: 64 ctx slots (≡ MAX_ASM_LOCALS_SIDECARS); depth 8; label row 64B into 512B stack
//   (8*64); be_cont stack 24 deep; end_label row 128B (store clamp 64).
// Layout loop: used[i] + ctx ptr slot i + depth[i] + break_stack[i*512+base+k]
//   + break_lens[i*8+d] + continue_stack[i*512+base+k] + continue_lens[i*8+d].
// Layout be_cont: depth + block_ref[d] + stmt_i[d] + end_len[d] + end_label[d*128+k].
let g_pipe_loop_used: i32[64] = [];
let g_pipe_loop_ctx: u8[512] = [];
let g_pipe_loop_depth: i32[64] = [];
let g_pipe_loop_break: u8[32768] = [];
let g_pipe_loop_break_lens: i32[512] = [];
let g_pipe_loop_cont: u8[32768] = [];
let g_pipe_loop_cont_lens: i32[512] = [];
let g_pipe_be_cont_depth: i32 = 0;
let g_pipe_be_cont_block: i32[24] = [];
let g_pipe_be_cont_stmt: i32[24] = [];
let g_pipe_be_cont_end_len: i32[24] = [];
let g_pipe_be_cont_end: u8[3072] = [];

// wave105 pure resolve_path leave (was pipeline_resolve_path.c host-cc residual).
// PLATFORM: SHARED - off sidecar for EMIT_HEAVY orch (lib_root/entry prefix + append).
// Historical static g_pipeline_resolve_path_off_sidecar in host-cc leaf.
let g_pipe_resolve_off: i32 = 0;

// wave90 pure typeck soft-suppress flag (G.7 single authority for XT001 soft diags).
// PLATFORM: SHARED - same ABI as glue static g_pipeline_typeck_diag_soft_suppress (0/1).
// Product hybrid: pure strong override of pipeline_glue XLANG_WEAK cold fallback.
// Consumers: pure dep_prerun orch set(1)/set(0); diagnostic path get() skips soft XT001.
// No cross-TU naked global - only set/get accessors (safe pure BSS under PREFER hybrid).
let g_pipe_typeck_diag_soft_suppress: i32 = 0;

// wave91 pure typeck dep_ctx pointer (G.7 single authority for enum-fallback accessors).
// PLATFORM: SHARED - LP64 ptr cell via xlang_ptr_slot_* (same as wave70/74 pure BSS tables).
// Product hybrid: pure strong override of pipeline_glue XLANG_WEAK cold fallback.
// Consumers: pure dep_prerun + typeck_parsed_module_c set; ast_pool enum tag get.
// No cross-TU naked global - only set/get accessors (closes dual-auth static in ast_pool).
let g_pipe_typeck_dep_ctx: u8[8] = [];

/**
 * Set soft-suppress flag for exploratory typeck XT001 soft diags (0/1).
 * @param v i32 - non-zero -> suppress; zero -> report normally
 * @return void
 * wave90 pure Cap residual: G.7 single product authority for soft-suppress flag
 * (historical strong body in pipeline_glue.c now XLANG_WEAK cold fallback).
 * PLATFORM: SHARED - diagnostic path uses get(); pure dep_prerun orch set(1)/set(0).
 */
#[no_mangle]
export function pipeline_typeck_diag_soft_suppress_set(v: i32): void {
  if (v != 0) {
    g_pipe_typeck_diag_soft_suppress = 1;
  } else {
    g_pipe_typeck_diag_soft_suppress = 0;
  }
}

/**
 * Read soft-suppress flag (1 = skip soft XT001 diags; 0 = report).
 * @return i32 - 0 or 1
 * wave90 pure Cap residual: G.7 single product authority (paired with set).
 * PLATFORM: SHARED - runtime_driver_diagnostic_thin / glue cold twin get.
 */
#[no_mangle]
export function pipeline_typeck_diag_soft_suppress_get(): i32 {
  if (g_pipe_typeck_diag_soft_suppress != 0) {
    return 1;
  }
  return 0;
}

/**
 * Publish active PipelineDepCtx for typeck glue accessors (enum variant fallback).
 * @param ctx *u8 - PipelineDepCtx pointer; null clears (no dep search)
 * @return void
 * wave91 pure Cap residual: G.7 single product authority for dep_ctx pointer
 * (historical strong body + static g_typeck_dep_ctx in ast_pool.c now XLANG_WEAK cold
 * fallback in pipeline_glue; readers use get_dep_ctx only).
 * PLATFORM: SHARED - pure dep_prerun orch + typeck_parsed_module_c set before typeck.
 */
#[no_mangle]
export function pipeline_typeck_set_dep_ctx(ctx: *u8): void {
  unsafe {
    // G.7 xlang_ptr_slot_set on pure LP64 cell (no naked *u8 module global).
    xlang_ptr_slot_set(&g_pipe_typeck_dep_ctx[0], 0, ctx);
  }
}

/**
 * Read active PipelineDepCtx published by set_dep_ctx (null if unset).
 * @return *u8 - PipelineDepCtx pointer or null
 * wave91 pure Cap residual: G.7 single product authority (paired with set).
 * PLATFORM: SHARED - ast_pool enum variant tag fallback / glue cold twin get.
 */
#[no_mangle]
export function pipeline_typeck_get_dep_ctx(): *u8 {
  unsafe {
    return xlang_ptr_slot_get(&g_pipe_typeck_dep_ctx[0], 0);
  }
}

// wave75 pure entry_lib lit + stem BSS (G.7 single authority for -E lib_prefix).
// PLATFORM: SHARED - same string values as seed static lits / stem_buf[128].
// Keyword order matches seed xlang_entry_lib_keyword_lit / strstr checks in name_from_path_impl.
let g_pipe_cstr_typeck_lit: u8[7] = [116, 121, 112, 101, 99, 107, 0];
let g_pipe_entry_lib_kw0: u8[5] = [109, 97, 105, 110, 0];
let g_pipe_entry_lib_kw1: u8[6] = [98, 117, 105, 108, 100, 0];
let g_pipe_entry_lib_kw2: u8[9] = [112, 105, 112, 101, 108, 105, 110, 101, 0];
let g_pipe_entry_lib_kw3: u8[7] = [100, 114, 105, 118, 101, 114, 0];
let g_pipe_entry_lib_kw4: u8[8] = [99, 111, 100, 101, 103, 101, 110, 0];
let g_pipe_entry_lib_kw5: u8[7] = [116, 121, 112, 101, 99, 107, 0];
let g_pipe_entry_lib_kw6: u8[7] = [112, 97, 114, 115, 101, 114, 0];
let g_pipe_entry_lib_kw7: u8[6] = [116, 111, 107, 101, 110, 0];
let g_pipe_entry_lib_kw8: u8[6] = [108, 101, 120, 101, 114, 0];
let g_pipe_entry_lib_kw9: u8[4] = [97, 115, 116, 0];
let g_pipe_entry_lib_stem_buf: u8[128] = [];

/**
 * Clear the pure -D define table (ndefines -> 0; slot bytes left stale until overwrite).
 * @return void
 * wave85 pure Cap residual: G.7 single authority for product define table
 * (historical always-seed body in runtime_driver_strict_glue_stubs).
 * PLATFORM: SHARED - glue keeps XLANG_WEAK cold fallback when pure not linked.
 */
#[no_mangle]
export function preprocess_define_reset(): void {
  g_pipe_pp_ndefines = 0;
}

/**
 * Append one -D macro name into the pure define table.
 * @param name *u8 - NUL-terminated C string; null / empty / len>=64 -> no-op
 * @return void
 * wave85 pure Cap residual: matches glue preprocess_define_add
 * (PREPROCESS_MAX_DEFINES=128, name slot 64 including NUL).
 * PLATFORM: SHARED - same reject rules as historical C body.
 */
#[no_mangle]
export function preprocess_define_add(name: *u8): void {
  if (name == 0 as *u8) {
    return;
  }
  if (g_pipe_pp_ndefines >= 128) {
    return;
  }
  // Measure C string length (cap 64 so n>=64 rejects without over-read past slot).
  let n: i32 = 0;
  unsafe {
    while (n < 64) {
      if (name[n] == 0) {
        break;
      }
      n = n + 1;
    }
  }
  if (n == 0) {
    return;
  }
  if (n >= 64) {
    return;
  }
  let base: i32 = g_pipe_pp_ndefines * 64;
  let k: i32 = 0;
  unsafe {
    while (k < n) {
      g_pipe_pp_defines[base + k] = name[k];
      k = k + 1;
    }
    g_pipe_pp_defines[base + n] = 0;
  }
  g_pipe_pp_ndefines = g_pipe_pp_ndefines + 1;
}

/**
 * Return 1 if sym[0..sym_len) exactly matches a stored -D name (NUL-terminated slot).
 * @param sym *u8 - symbol bytes (not required to be NUL-terminated beyond sym_len)
 * @param sym_len i32 - byte length; <=0 -> 0
 * @return i32 - 1 if present, else 0
 * wave85 pure Cap residual: G.7 single authority for preprocess_eval_condition_c
 * simple-name path (wave88 pure orch; complex still Cap residual cfg_eval_expr_c).
 * PLATFORM: SHARED - same compare semantics as historical C preprocess_define_has.
 */
#[no_mangle]
export function preprocess_define_has(sym: *u8, sym_len: i32): i32 {
  if (sym == 0 as *u8) {
    return 0;
  }
  if (sym_len <= 0) {
    return 0;
  }
  let i: i32 = 0;
  while (i < g_pipe_pp_ndefines) {
    let base: i32 = i * 64;
    let k: i32 = 0;
    let ok: i32 = 1;
    while (k < sym_len) {
      unsafe {
        let tb: u8 = g_pipe_pp_defines[base + k];
        if (tb != sym[k]) {
          ok = 0;
          break;
        }
        if (tb == 0) {
          // Stored name shorter than sym_len -> not equal.
          ok = 0;
          break;
        }
      }
      k = k + 1;
    }
    if (ok != 0) {
      // Exact match requires stored NUL immediately after sym_len bytes.
      unsafe {
        if (g_pipe_pp_defines[base + sym_len] == 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Evaluate a preprocess #if / #elif condition for the pure preprocess.x engine path.
 * @param cond *u8 - condition bytes (not required to be NUL-terminated beyond cond_len)
 * @param cond_len i32 - byte length; null/<=0 -> 0 (false)
 * @return i32 - non-zero if condition is true, else 0
 * wave88 pure Cap residual: G.7 single product authority for preprocess_eval_condition_c
 * (historical always-seed body in runtime_driver_strict_glue_stubs).
 * Steps (match historical C):
 *   1) trim leading/trailing space/tab;
 *   2) if empty after trim -> 0;
 *   3) if any complex op char (space/tab/=/!/(/)) -> Cap residual cfg_eval_expr_c;
 *   4) else same-TU pure preprocess_define_has (wave85 -D table).
 * PLATFORM: SHARED - glue keeps XLANG_WEAK cold fallback when pure not linked.
 */
#[no_mangle]
export function preprocess_eval_condition_c(cond: *u8, cond_len: i32): i32 {
  if (cond == 0 as *u8) {
    return 0;
  }
  if (cond_len <= 0) {
    return 0;
  }
  // Trim leading whitespace by advancing the base pointer one byte at a time.
  let base: *u8 = cond;
  let n: i32 = cond_len;
  while (n > 0) {
    let lead: u8 = 0;
    unsafe {
      lead = base[0];
    }
    if (lead != 32) {
      if (lead != 9) {
        break;
      }
    }
    base = xlang_cstr_offset(base, 1);
    n = n - 1;
  }
  // Trim trailing whitespace without moving base (shrink length only).
  while (n > 0) {
    let trail: u8 = 0;
    unsafe {
      trail = base[n - 1];
    }
    if (trail != 32) {
      if (trail != 9) {
        break;
      }
    }
    n = n - 1;
  }
  if (n <= 0) {
    return 0;
  }
  // Complex conditions (spaces / comparison / grouping) use Cap residual cfg_eval.
  // Scan for any complex op char first; then one Cap residual call under unsafe (T001).
  let k: i32 = 0;
  let complex: i32 = 0;
  while (k < n) {
    let c: u8 = 0;
    unsafe {
      c = base[k];
    }
    // space, tab, '=', '!', '(', ')'
    if (c == 32) {
      complex = 1;
      break;
    }
    if (c == 9) {
      complex = 1;
      break;
    }
    if (c == 61) {
      complex = 1;
      break;
    }
    if (c == 33) {
      complex = 1;
      break;
    }
    if (c == 40) {
      complex = 1;
      break;
    }
    if (c == 41) {
      complex = 1;
      break;
    }
    k = k + 1;
  }
  if (complex != 0) {
    let er: i32 = 0;
    unsafe {
      // Cap residual: cfg_eval_expr_c is export-extern FFI (lexer/cfg_eval authority).
      er = cfg_eval_expr_c(base, n);
    }
    if (er != 0) {
      return 1;
    }
    return 0;
  }
  // Simple identifier: true iff present in pure -D table (same-TU pure).
  return preprocess_define_has(base, n);
}

/**
 * Clear the pure #if nesting stack (depth -> 0; slot values left stale until overwrite).
 * @return void
 * wave86 pure Cap residual: G.7 single authority for product preprocess #if stack
 * (historical host-cc GrowVec twin pipeline_preprocess_if.c retired 2026-08-05 -
 * pure-owned WEAK cold delete-only host-cc leave; no second body in pipeline_x).
 * PLATFORM: SHARED - sole provider on product + strict companion
 * (preprocess_if_stack_only.o partial-export from this TU's .o).
 */
#[no_mangle]
export function preprocess_if_stack_reset(): void {
  g_pipe_pp_if_n = 0;
}

/**
 * Return current #if nesting depth (0 when empty).
 * @return i32 - depth in 0..32
 * wave86 pure Cap residual: matches historical preprocess_if_stack_len (GrowVec len).
 * PLATFORM: SHARED - same non-negative depth contract as cold path.
 */
#[no_mangle]
export function preprocess_if_stack_len(): i32 {
  return g_pipe_pp_if_n;
}

/**
 * Push one stack state value (active / skipped / else-taken codes from preprocess.x).
 * @param v i32 - state code for this nesting level
 * @return i32 - 0 on success; -1 if depth already at cap 32
 * wave86 pure Cap residual: fixed-cap push (historical GrowVec grow-or-fail).
 * PLATFORM: SHARED - cap 32 matches pre-GrowVec fixed stack; product #if nest rare > 8.
 */
#[no_mangle]
export function preprocess_if_stack_push(v: i32): i32 {
  if (g_pipe_pp_if_n >= 32) {
    return -1;
  }
  unsafe {
    let p: *i32 = &g_pipe_pp_if_stack[g_pipe_pp_if_n];
    p[0] = v;
  }
  g_pipe_pp_if_n = g_pipe_pp_if_n + 1;
  return 0;
}

/**
 * Pop one nesting level (#endif). No-op when empty.
 * @return void
 * wave86 pure Cap residual: depth-- when depth > 0.
 * PLATFORM: SHARED - same empty-safe pop as historical GrowVec path.
 */
#[no_mangle]
export function preprocess_if_stack_pop(): void {
  if (g_pipe_pp_if_n > 0) {
    g_pipe_pp_if_n = g_pipe_pp_if_n - 1;
  }
}

/**
 * Read stack state at index i (0-based).
 * @param i i32 - index; OOB or empty -> 0
 * @return i32 - stored state, or 0 when i invalid
 * wave86 pure Cap residual: matches historical preprocess_if_stack_at OOB -> 0.
 * PLATFORM: SHARED - no grow; pure fixed table only.
 */
#[no_mangle]
export function preprocess_if_stack_at(i: i32): i32 {
  if (i < 0) {
    return 0;
  }
  if (i >= g_pipe_pp_if_n) {
    return 0;
  }
  unsafe {
    let p: *i32 = &g_pipe_pp_if_stack[i];
    return p[0];
  }
  return 0;
}

/**
 * Write stack state at index i (must be in 0..depth-1).
 * @param i i32 - index; OOB -> no-op
 * @param v i32 - new state code
 * @return void
 * wave86 pure Cap residual: matches historical preprocess_if_stack_set_at OOB no-op.
 * PLATFORM: SHARED - pure fixed table only.
 */
#[no_mangle]
export function preprocess_if_stack_set_at(i: i32, v: i32): void {
  if (i < 0) {
    return;
  }
  if (i >= g_pipe_pp_if_n) {
    return;
  }
  unsafe {
    let p: *i32 = &g_pipe_pp_if_stack[i];
    p[0] = v;
  }
}

/**
 * Storage slot for pure get_ndep (points at g_pipe_typeck_ndep).
 * @return *i32 - never null; LP64 i32 cell
 * wave77 pure: G.7 single authority for typeck_ndep count; pure get_ndep / store path.
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X returns &typeck_ndep.
 */
#[no_mangle]
export function typeck_ndep_slot(): *i32 {
  return &g_pipe_typeck_ndep;
}

/**
 * Store final clamped typeck_ndep value into pure BSS (bounds owned by typeck_ndep_store orch).
 * @param n i32 - already-clamped dep count [0,32]
 * @return void
 * wave77 pure: Cap residual was always-seed BSS write; pure owns the cell.
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X writes seed typeck_ndep.
 */
#[no_mangle]
export function typeck_ndep_store_impl(n: i32): void {
  g_pipe_typeck_ndep = n;
}

/**
 * Load typeck_dep_module_ptrs[i] from pure BSS (capacity 32).
 * @param i i32 - slot index; i < 0 or i >= 32 -> null
 * @return *u8 - stored module pointer (may be null)
 * wave77 pure: G.7 xlang_ptr_slot_get on g_pipe_typeck_dep_module_ptrs.
 * PLATFORM: SHARED LP64 - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function typeck_dep_module_get(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  return xlang_ptr_slot_get(&g_pipe_typeck_dep_module_ptrs[0], i);
}

/**
 * Load typeck_dep_arena_ptrs[i] from pure BSS (capacity 32).
 * @param i i32 - slot index; i < 0 or i >= 32 -> null
 * @return *u8 - stored arena pointer (may be null)
 * wave77 pure: G.7 xlang_ptr_slot_get on g_pipe_typeck_dep_arena_ptrs.
 * PLATFORM: SHARED LP64 - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function typeck_dep_arena_get(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  return xlang_ptr_slot_get(&g_pipe_typeck_dep_arena_ptrs[0], i);
}

/**
 * Store mod into typeck_dep_module_ptrs[i] pure BSS (capacity 32).
 * @param i i32 - slot index; OOB -> no-op
 * @param mod *u8 - module pointer (may be null)
 * @return void
 * wave77 pure: G.7 xlang_ptr_slot_set; pure typeck_dep_module_set / pipeline_set_dep orch own bounds.
 * PLATFORM: SHARED LP64 - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function typeck_dep_module_set_impl(i: i32, mod: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  xlang_ptr_slot_set(&g_pipe_typeck_dep_module_ptrs[0], i, mod);
}

/**
 * Store arena into typeck_dep_arena_ptrs[i] pure BSS (capacity 32).
 * @param i i32 - slot index; OOB -> no-op
 * @param arena *u8 - arena pointer (may be null)
 * @return void
 * wave77 pure: G.7 xlang_ptr_slot_set; pure typeck_dep_arena_set / pipeline_set_dep orch own bounds.
 * PLATFORM: SHARED LP64 - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function typeck_dep_arena_set_impl(i: i32, arena: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  xlang_ptr_slot_set(&g_pipe_typeck_dep_arena_ptrs[0], i, arena);
}

/**
 * Base address of pure typeck_dep_module_ptrs table for Cap residual typeck_module void**.
 * @return *u8 - never null; LP64 void*[32] raw base (cast to void** at call site)
 * wave77 pure: pure BSS base; pure with_sidecar passes this when get_ndep() > 0.
 * Historical Cap residual: seed BSS addr not takeable from pure .x - closed by pure table.
 * PLATFORM: SHARED LP64 - cold twin under seed #ifndef FROM_X returns seed array.
 */
#[no_mangle]
export function typeck_dep_module_ptrs_base(): *u8 {
  return &g_pipe_typeck_dep_module_ptrs[0];
}

/**
 * Return static "typeck" C string (default -E lib prefix).
 * @return *u8 - always non-null; points at g_pipe_cstr_typeck_lit
 * wave75 pure: module BSS lit; matches seed xlang_cstr_typeck_lit return "typeck".
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function xlang_cstr_typeck_lit(): *u8 {
  return &g_pipe_cstr_typeck_lit[0];
}

/**
 * Return static keyword C string for entry_lib keyword index.
 * @param k i32 - 0=main .. 9=ast; other -> "typeck"
 * @return *u8 - always non-null; pointer into module BSS keyword lits
 * wave75 pure: G.7 single authority for keyword lits used by pure name_from_path_impl.
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function xlang_entry_lib_keyword_lit(k: i32): *u8 {
  if (k == 0) {
    return &g_pipe_entry_lib_kw0[0];
  }
  if (k == 1) {
    return &g_pipe_entry_lib_kw1[0];
  }
  if (k == 2) {
    return &g_pipe_entry_lib_kw2[0];
  }
  if (k == 3) {
    return &g_pipe_entry_lib_kw3[0];
  }
  if (k == 4) {
    return &g_pipe_entry_lib_kw4[0];
  }
  if (k == 5) {
    return &g_pipe_entry_lib_kw5[0];
  }
  if (k == 6) {
    return &g_pipe_entry_lib_kw6[0];
  }
  if (k == 7) {
    return &g_pipe_entry_lib_kw7[0];
  }
  if (k == 8) {
    return &g_pipe_entry_lib_kw8[0];
  }
  if (k == 9) {
    return &g_pipe_entry_lib_kw9[0];
  }
  return &g_pipe_cstr_typeck_lit[0];
}

/**
 * Derive -E C lib_prefix from entry .x path (keywords / std_ / core_ / basename stem).
 * @param input_path *u8 - entry path; null -> "typeck" (caller may short-circuit)
 * @return *u8 - static keyword lit or g_pipe_entry_lib_stem_buf; never null
 * wave75 pure Cap residual orch (full body):
 *   1) strstr-style keywords (main..ast) via pipe_cstr_contains + pure keyword_lit;
 *   2) path-boundary "std/" -> "std_" + segments (skip trailing mod; strip .x/.su);
 *   3) path-boundary "core/" -> "core_" + same segment rules;
 *   4) basename stem without .x/.su;
 *   5) default "typeck".
 * G.7 single authority - matches seed order (keywords BEFORE std/ stem). Historical pure
 * gate checked std/ first and could return std_* for paths that also contain "main".
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X; stem reuses one 128B BSS cell.
 */
#[no_mangle]
export function xlang_entry_lib_name_from_path_impl(input_path: *u8): *u8 {
  if (input_path == 0 as *u8) {
    return xlang_cstr_typeck_lit();
  }
  // Keyword substring checks - same order as seed strstr chain.
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw0[0]) != 0) {
    return xlang_entry_lib_keyword_lit(0);
  }
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw1[0]) != 0) {
    return xlang_entry_lib_keyword_lit(1);
  }
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw2[0]) != 0) {
    return xlang_entry_lib_keyword_lit(2);
  }
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw3[0]) != 0) {
    return xlang_entry_lib_keyword_lit(3);
  }
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw4[0]) != 0) {
    return xlang_entry_lib_keyword_lit(4);
  }
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw5[0]) != 0) {
    return xlang_entry_lib_keyword_lit(5);
  }
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw6[0]) != 0) {
    return xlang_entry_lib_keyword_lit(6);
  }
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw7[0]) != 0) {
    return xlang_entry_lib_keyword_lit(7);
  }
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw8[0]) != 0) {
    return xlang_entry_lib_keyword_lit(8);
  }
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw9[0]) != 0) {
    return xlang_entry_lib_keyword_lit(9);
  }

  // std/ at path boundary -> std_ + segments (skip mod; strip .x/.su).
  let std_after: i32 = 0 - 1;
  let si: i32 = 0;
  unsafe {
    while (si < 4096) {
      if (input_path[si] == 0) {
        break;
      }
      let at_bound: i32 = 0;
      if (si == 0) {
        at_bound = 1;
      } else {
        if (input_path[si - 1] == 47) {
          at_bound = 1;
        }
        if (input_path[si - 1] == 92) {
          at_bound = 1;
        }
      }
      if (at_bound != 0) {
        // "std/"
        if (input_path[si] == 115 && input_path[si + 1] == 116 && input_path[si + 2] == 100 && input_path[si + 3] == 47) {
          std_after = si + 4;
          break;
        }
      }
      si = si + 1;
    }
  }
  if (std_after >= 0) {
    // "std_" prefix into stem_buf
    g_pipe_entry_lib_stem_buf[0] = 115;
    g_pipe_entry_lib_stem_buf[1] = 116;
    g_pipe_entry_lib_stem_buf[2] = 100;
    g_pipe_entry_lib_stem_buf[3] = 95;
    let off: i32 = 4;
    let p: i32 = std_after;
    unsafe {
      while (input_path[p] != 0 && off + 2 < 128) {
        let seg_start: i32 = p;
        while (input_path[p] != 0 && input_path[p] != 47 && input_path[p] != 92) {
          p = p + 1;
        }
        let seg_len: i32 = p - seg_start;
        // strip .su / .x
        if (seg_len >= 3) {
          if (input_path[seg_start + seg_len - 3] == 46 && input_path[seg_start + seg_len - 2] == 115 && input_path[seg_start + seg_len - 1] == 117) {
            seg_len = seg_len - 3;
          }
        }
        if (seg_len >= 2) {
          if (input_path[seg_start + seg_len - 2] == 46 && input_path[seg_start + seg_len - 1] == 120) {
            seg_len = seg_len - 2;
          }
        }
        // skip "mod"
        let is_mod: i32 = 0;
        if (seg_len == 3) {
          if (input_path[seg_start] == 109 && input_path[seg_start + 1] == 111 && input_path[seg_start + 2] == 100) {
            is_mod = 1;
          }
        }
        if (is_mod == 0 && seg_len > 0) {
          if (off > 4 && off + seg_len + 1 < 128) {
            g_pipe_entry_lib_stem_buf[off] = 95;
            off = off + 1;
          }
          if (off + seg_len < 128) {
            let k: i32 = 0;
            while (k < seg_len) {
              g_pipe_entry_lib_stem_buf[off + k] = input_path[seg_start + k];
              k = k + 1;
            }
            off = off + seg_len;
          }
        }
        if (input_path[p] != 0) {
          p = p + 1;
        }
      }
    }
    if (off > 4) {
      g_pipe_entry_lib_stem_buf[off] = 0;
      return &g_pipe_entry_lib_stem_buf[0];
    }
  }

  // core/ at path boundary -> core_ + segments.
  let core_after: i32 = 0 - 1;
  let ci: i32 = 0;
  unsafe {
    while (ci < 4096) {
      if (input_path[ci] == 0) {
        break;
      }
      let at_bound2: i32 = 0;
      if (ci == 0) {
        at_bound2 = 1;
      } else {
        if (input_path[ci - 1] == 47) {
          at_bound2 = 1;
        }
        if (input_path[ci - 1] == 92) {
          at_bound2 = 1;
        }
      }
      if (at_bound2 != 0) {
        // "core/"
        if (input_path[ci] == 99 && input_path[ci + 1] == 111 && input_path[ci + 2] == 114 && input_path[ci + 3] == 101 && input_path[ci + 4] == 47) {
          core_after = ci + 5;
          break;
        }
      }
      ci = ci + 1;
    }
  }
  if (core_after >= 0) {
    g_pipe_entry_lib_stem_buf[0] = 99;
    g_pipe_entry_lib_stem_buf[1] = 111;
    g_pipe_entry_lib_stem_buf[2] = 114;
    g_pipe_entry_lib_stem_buf[3] = 101;
    g_pipe_entry_lib_stem_buf[4] = 95;
    let off2: i32 = 5;
    let p2: i32 = core_after;
    unsafe {
      while (input_path[p2] != 0 && off2 + 2 < 128) {
        let seg_start2: i32 = p2;
        while (input_path[p2] != 0 && input_path[p2] != 47 && input_path[p2] != 92) {
          p2 = p2 + 1;
        }
        let seg_len2: i32 = p2 - seg_start2;
        if (seg_len2 >= 3) {
          if (input_path[seg_start2 + seg_len2 - 3] == 46 && input_path[seg_start2 + seg_len2 - 2] == 115 && input_path[seg_start2 + seg_len2 - 1] == 117) {
            seg_len2 = seg_len2 - 3;
          }
        }
        if (seg_len2 >= 2) {
          if (input_path[seg_start2 + seg_len2 - 2] == 46 && input_path[seg_start2 + seg_len2 - 1] == 120) {
            seg_len2 = seg_len2 - 2;
          }
        }
        let is_mod2: i32 = 0;
        if (seg_len2 == 3) {
          if (input_path[seg_start2] == 109 && input_path[seg_start2 + 1] == 111 && input_path[seg_start2 + 2] == 100) {
            is_mod2 = 1;
          }
        }
        if (is_mod2 == 0 && seg_len2 > 0) {
          if (off2 > 5 && off2 + seg_len2 + 1 < 128) {
            g_pipe_entry_lib_stem_buf[off2] = 95;
            off2 = off2 + 1;
          }
          if (off2 + seg_len2 < 128) {
            let k2: i32 = 0;
            while (k2 < seg_len2) {
              g_pipe_entry_lib_stem_buf[off2 + k2] = input_path[seg_start2 + k2];
              k2 = k2 + 1;
            }
            off2 = off2 + seg_len2;
          }
        }
        if (input_path[p2] != 0) {
          p2 = p2 + 1;
        }
      }
    }
    if (off2 > 5) {
      g_pipe_entry_lib_stem_buf[off2] = 0;
      return &g_pipe_entry_lib_stem_buf[0];
    }
  }

  // basename stem without .x/.su
  let last_slash: i32 = 0 - 1;
  let bi: i32 = 0;
  unsafe {
    while (bi < 4096) {
      if (input_path[bi] == 0) {
        break;
      }
      if (input_path[bi] == 47 || input_path[bi] == 92) {
        last_slash = bi;
      }
      bi = bi + 1;
    }
  }
  let base: i32 = 0;
  if (last_slash >= 0) {
    base = last_slash + 1;
  }
  let last_dot: i32 = 0 - 1;
  let di: i32 = base;
  unsafe {
    while (di < 4096) {
      if (input_path[di] == 0) {
        break;
      }
      if (input_path[di] == 46) {
        last_dot = di;
      }
      di = di + 1;
    }
  }
  if (last_dot > base) {
    let is_x: i32 = 0;
    unsafe {
      if (input_path[last_dot] == 46 && input_path[last_dot + 1] == 120 && input_path[last_dot + 2] == 0) {
        is_x = 1;
      }
      if (input_path[last_dot] == 46 && input_path[last_dot + 1] == 115 && input_path[last_dot + 2] == 117 && input_path[last_dot + 3] == 0) {
        is_x = 1;
      }
    }
    if (is_x != 0) {
      let stem_len: i32 = last_dot - base;
      if (stem_len > 0 && stem_len < 128) {
        let k3: i32 = 0;
        unsafe {
          while (k3 < stem_len) {
            g_pipe_entry_lib_stem_buf[k3] = input_path[base + k3];
            k3 = k3 + 1;
          }
        }
        g_pipe_entry_lib_stem_buf[stem_len] = 0;
        return &g_pipe_entry_lib_stem_buf[0];
      }
    }
  }
  return xlang_cstr_typeck_lit();
}

/**
 * Return address of the pipeline diag-emitted sticky flag (i32 cell).
 * @return *i32 - always non-null; points at g_pipe_diag_emitted_flag
 * wave73 pure: pure reset/note/get write/read this cell (0 clear / non-zero noted).
 * Matches historical seed pipeline_diag_emitted_flag_slot -> static int.
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X; hybrid pure owns this cell only.
 */
#[no_mangle]
export function pipeline_diag_emitted_flag_slot(): *i32 {
  return &g_pipe_diag_emitted_flag;
}

/**
 * Return address of driver_dep seeded flag cell for slot i (i32).
 * @param i i32 - slot index; OOB clamped to 0..31 (matches historical seed clamp)
 * @return *i32 - always non-null; points at g_pipe_driver_dep_seeded[idx]
 * wave74 pure: pure seeded_get/set write/read this cell; G.7 single authority.
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X; hybrid pure owns the table.
 */
#[no_mangle]
export function driver_dep_seeded_slot(i: i32): *i32 {
  let idx: i32 = i;
  if (idx < 0) {
    idx = 0;
  }
  if (idx >= 32) {
    idx = 31;
  }
  return &g_pipe_driver_dep_seeded[idx];
}

/**
 * Store arena pointer into driver_dep arena slot i (capacity 32).
 * @param i i32 - slot index; i < 0 or i >= 32 -> no-op
 * @param arena *u8 - arena pointer (may be null to clear)
 * @return void
 * wave74 pure: G.7 xlang_ptr_slot_set on g_pipe_driver_dep_arena.
 * PLATFORM: SHARED LP64 - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function driver_dep_arena_ptr_set_impl(i: i32, arena: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  xlang_ptr_slot_set(&g_pipe_driver_dep_arena[0], i, arena);
}

/**
 * Store module pointer into driver_dep module slot i (capacity 32).
 * @param i i32 - slot index; OOB -> no-op
 * @param module *u8 - module pointer (may be null to clear)
 * @return void
 * wave74 pure: G.7 xlang_ptr_slot_set on g_pipe_driver_dep_module.
 * PLATFORM: SHARED LP64 - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function driver_dep_module_ptr_set_impl(i: i32, module: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  xlang_ptr_slot_set(&g_pipe_driver_dep_module[0], i, module);
}

/**
 * Store import-path pointer into driver_dep path registry slot i (capacity 32).
 * @param i i32 - slot index; OOB -> no-op
 * @param path *u8 - logical import path pointer (lifetime until clear); null clears the slot
 * @return void
 * wave74 pure: G.7 xlang_ptr_slot_set on g_pipe_driver_dep_path_registry.
 * Null path stores null so pure clear_slots can wipe registry (seed cold set rejected null
 * and relied on clear_slots_impl direct assignment; pure set is the single clear path).
 * PLATFORM: SHARED LP64 - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function driver_dep_path_registry_set(i: i32, path: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  xlang_ptr_slot_set(&g_pipe_driver_dep_path_registry[0], i, path);
}

/**
 * Load path registry pointer at slot i.
 * @param i i32 - slot index; OOB -> null
 * @return *u8 - stored path pointer (may be null)
 * wave74 pure: G.7 xlang_ptr_slot_get on g_pipe_driver_dep_path_registry.
 * PLATFORM: SHARED LP64 - cold twin under seed #ifndef FROM_X; used by pure slot_for_path_scan.
 */
#[no_mangle]
export function driver_dep_path_registry_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  return xlang_ptr_slot_get(&g_pipe_driver_dep_path_registry[0], i);
}

/**
 * LP64 byte size of struct ast_ASTArena (handle shell; pools live in sidecar).
 * @return usize - always 16 on SHARED LP64 product hosts
 * wave83 pure Cap residual: fixed layout constant matching pipeline_glue
 *   sizeof(struct ast_ASTArena). Dual-end verified mac arm64 + Ubuntu x86_64 (2026-07-22).
 * Glue keeps a weak cold fallback so full-C bootstrap without pure still links.
 * When the C struct layout changes, update this constant and re-verify dual-end.
 * PLATFORM: SHARED LP64 - do not invent per-OS sizes; both gold hosts are LP64.
 */
#[no_mangle]
export function pipeline_sizeof_arena(): usize {
  return 16 as usize;
}

/**
 * LP64 byte size of struct ast_Module (thin module header).
 * @return usize - always 68 (0x44) on SHARED LP64 product hosts
 * wave83 pure Cap residual: fixed layout constant matching pipeline_glue
 *   sizeof(struct ast_Module). Dual-end verified mac arm64 + Ubuntu x86_64 (2026-07-22).
 * Historical lsp_diag stub returned 40 - that was a stale thin layout; product truth is 68.
 * Glue keeps a weak cold fallback. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function pipeline_sizeof_module(): usize {
  return 68 as usize;
}

/**
 * Return (and lazily allocate) driver_dep arena buffer for slot i.
 * @param i i32 - slot index; OOB -> null
 * @return *u8 - arena byte region (zeroed on first malloc); null on OOB/OOM
 * wave74 pure: load slot; if null, malloc(pipeline_sizeof_arena)+memset0 then store.
 * wave83: G.7 pure pipeline_sizeof_arena (fixed LP64 constant; no glue Cap residual call).
 * Matches historical seed driver_dep_arena_buf (reuse pre-seeded pointers; no free on clear).
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function driver_dep_arena_buf(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  let p: *u8 = xlang_ptr_slot_get(&g_pipe_driver_dep_arena[0], i);
  if (p != 0 as *u8) {
    return p;
  }
  let sz: usize = 0 as usize;
  unsafe {
    sz = pipeline_sizeof_arena();
    p = malloc(sz);
    if (p == 0 as *u8) {
      return 0 as *u8;
    }
    memset(p, 0, sz);
  }
  xlang_ptr_slot_set(&g_pipe_driver_dep_arena[0], i, p);
  return p;
}

/**
 * Return (and lazily allocate) driver_dep module buffer for slot i.
 * @param i i32 - slot index; OOB -> null
 * @return *u8 - module byte region (zeroed on first malloc); null on OOB/OOM
 * wave74 pure: same pattern as driver_dep_arena_buf with pipeline_sizeof_module.
 * wave83: G.7 pure pipeline_sizeof_module (fixed LP64 constant).
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function driver_dep_module_buf(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  let p: *u8 = xlang_ptr_slot_get(&g_pipe_driver_dep_module[0], i);
  if (p != 0 as *u8) {
    return p;
  }
  let sz: usize = 0 as usize;
  unsafe {
    sz = pipeline_sizeof_module();
    p = malloc(sz);
    if (p == 0 as *u8) {
      return 0 as *u8;
    }
    memset(p, 0, sz);
  }
  xlang_ptr_slot_set(&g_pipe_driver_dep_module[0], i, p);
  return p;
}

/**
 * Free any owned stage-prep buffer and clear stage BSS cells to null/0.
 * @return void
 * wave71 pure: free(g_pipe_rf_stage_prep) then G.7 xlang_ptr_slot_set / xlang_size_slot_set zero.
 * Matches historical seed pipeline_rf_stage_prep_clear (always free then null).
 * PLATFORM: SHARED LP64 - cold twin under seed #ifndef FROM_X; hybrid pure owns these cells.
 */
#[no_mangle]
export function pipeline_rf_stage_prep_clear(): void {
  let p: *u8 = xlang_ptr_slot_get(&g_pipe_rf_stage_prep[0], 0);
  if (p != 0 as *u8) {
    unsafe {
      free(p);
    }
  }
  xlang_ptr_slot_set(&g_pipe_rf_stage_prep[0], 0, 0 as *u8);
  xlang_size_slot_set(&g_pipe_rf_stage_prep_len[0], 0, 0);
}

/**
 * Store owned prep into stage BSS (does not free prior; caller must clear first).
 * @param prep *u8 - owned heap buffer (or null for empty stage)
 * @param prep_len i64 - byte length; if prep is null, stored len is forced to 0
 * @return void
 * wave71 pure: G.7 xlang_ptr_slot_set / xlang_size_slot_set on pure stage cells.
 * Matches seed: prep may be null -> stores empty (len 0).
 * PLATFORM: SHARED LP64 - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_rf_stage_prep_set(prep: *u8, prep_len: i64): void {
  xlang_ptr_slot_set(&g_pipe_rf_stage_prep[0], 0, prep);
  if (prep == 0 as *u8) {
    xlang_size_slot_set(&g_pipe_rf_stage_prep_len[0], 0, 0);
    return;
  }
  xlang_size_slot_set(&g_pipe_rf_stage_prep_len[0], 0, prep_len);
}

/**
 * Move stage prep out without free (caller owns); clear stage BSS.
 * @param out_prep *u8 - char** as raw bytes (LP64 8B slot); may be null (still clears)
 * @param out_len *u8 - size_t* as raw bytes; may be null
 * @return i32 - 0 if prep non-null; -1 if stage empty (null prep)
 * wave71 pure: load cells -> zero cells -> write outs via G.7 ptr/size slot set.
 * PLATFORM: SHARED LP64 - cold twin under seed #ifndef FROM_X; pure commit_prep uses this.
 */
#[no_mangle]
export function pipeline_rf_stage_prep_take(out_prep: *u8, out_len: *u8): i32 {
  let prep: *u8 = xlang_ptr_slot_get(&g_pipe_rf_stage_prep[0], 0);
  let prep_len: i64 = xlang_size_slot_get(&g_pipe_rf_stage_prep_len[0], 0);
  // Clear stage before writing outs (same order as historical seed).
  xlang_ptr_slot_set(&g_pipe_rf_stage_prep[0], 0, 0 as *u8);
  xlang_size_slot_set(&g_pipe_rf_stage_prep_len[0], 0, 0);
  if (out_prep != 0 as *u8) {
    xlang_ptr_slot_set(out_prep, 0, prep);
  }
  if (out_len != 0 as *u8) {
    // Historical: out_len = prep ? prep_len : 0 after clear path already read prep_len.
    if (prep == 0 as *u8) {
      xlang_size_slot_set(out_len, 0, 0);
    } else {
      xlang_size_slot_set(out_len, 0, prep_len);
    }
  }
  if (prep == 0 as *u8) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Ensure loaded-import BSS, copy owned prep into it, free prep.
 * @param prep *u8 - owned heap source buffer; null -> -1 (does not free)
 * @param prep_len i64 - byte length to copy; may be 0 if prep non-null
 * @return i32 - 0 success; -1 null prep or OOM (prep freed on OOM only)
 * wave72 pure: G.7 xlang_ptr_slot_* / xlang_size_slot_* on g_pipe_loaded_import_*.
 * Ensure policy (matches historical seed / XLANG_PIPELINE_IMPORT_BUF_CAP):
 *   if prep_len > cap or buf null -> free old buf; new_cap =
 *     (prep_len < 4194304) ? 4194304 : (prep_len + 65536); malloc; OOM -> free(prep) -1.
 *   else reuse existing buf; memcpy prep_len bytes; set len; free(prep).
 * PLATFORM: SHARED LP64 - cold twin under seed #ifndef FROM_X; hybrid pure owns cells.
 */
#[no_mangle]
export function pipeline_loaded_import_commit_from_owned(prep: *u8, prep_len: i64): i32 {
  if (prep == 0 as *u8) {
    return 0 - 1;
  }
  let buf: *u8 = xlang_ptr_slot_get(&g_pipe_loaded_import_buf[0], 0);
  let cap: i64 = xlang_size_slot_get(&g_pipe_loaded_import_cap[0], 0);
  // Reallocate when buffer missing or too small for prep_len (same order as seed).
  if (prep_len > cap || buf == 0 as *u8) {
    // free(NULL) is fine; seed always free then assign new cap before malloc.
    unsafe {
      free(buf);
    }
    // Cap floor 4194304 = XLANG_PIPELINE_IMPORT_BUF_CAP; else prep_len + 65536.
    // Seed: prep_len < floor ? floor : prep_len + 65536  (i.e. >= floor -> grow).
    let floor_cap: i64 = 4194304;
    let new_cap: i64 = floor_cap;
    if (prep_len >= floor_cap) {
      new_cap = prep_len + 65536;
    }
    // Seed sets cap before malloc; OOM leaves cap=new_cap and buf=null (len unchanged).
    xlang_size_slot_set(&g_pipe_loaded_import_cap[0], 0, new_cap);
    let fresh: *u8 = 0 as *u8;
    unsafe {
      fresh = malloc(new_cap as usize);
    }
    if (fresh == 0 as *u8) {
      xlang_ptr_slot_set(&g_pipe_loaded_import_buf[0], 0, 0 as *u8);
      unsafe {
        free(prep);
      }
      return 0 - 1;
    }
    xlang_ptr_slot_set(&g_pipe_loaded_import_buf[0], 0, fresh);
    buf = fresh;
  }
  unsafe {
    // Copy prep into committed buffer; then transfer ownership of prep away (free).
    memcpy(buf, prep, prep_len as usize);
    free(prep);
  }
  xlang_size_slot_set(&g_pipe_loaded_import_len[0], 0, prep_len);
  return 0;
}

/**
 * Return pointer to committed loaded-import source bytes (or null if empty).
 * @return *u8 - pipeline_loaded_import_buf; null when never committed / OOM cleared
 * wave72 pure: G.7 xlang_ptr_slot_get on pure BSS. Matches seed null when buf null.
 * PLATFORM: SHARED LP64 - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_loaded_import_data(): *u8 {
  return xlang_ptr_slot_get(&g_pipe_loaded_import_buf[0], 0);
}

/**
 * Return byte length of committed loaded-import buffer.
 * @return i64 - size_t length cell (0 when empty / never committed)
 * wave72 pure: G.7 xlang_size_slot_get on pure BSS. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function pipeline_loaded_import_len_get(): i64 {
  return xlang_size_slot_get(&g_pipe_loaded_import_len[0], 0);
}

/**
 * Return base of the pipeline resolved-path static buffer (cap 512 incl trailing NUL room).
 * @return *u8 - always non-null; points at g_pipe_resolved_path_buf[0]
 * wave69 pure: pure resolve_path_into_static writes here via multi resolve;
 * pure read_file_stage_prep reads the path for open/preprocess diags.
 * Cap 512 matches historical seed `static char pipeline_resolved_path_buf[512]`.
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X; hybrid pure owns this cell only.
 */
#[no_mangle]
export function pipeline_resolved_path_buf_slot(): *u8 {
  return &g_pipe_resolved_path_buf[0];
}

/**
 * Store pointer p into pipeline dep-arena slot i (capacity 32).
 * @param i i32 - slot index; i < 0 or i >= 32 -> no-op
 * @param p *u8 - arena pointer (may be null)
 * @return void
 * wave70 pure: G.7 xlang_ptr_slot_set on g_pipe_dep_arena_slots (32×LP64 LE cells).
 * Matches seed bounds policy on set (reject OOB; do not trap).
 * PLATFORM: SHARED LP64 - cold twin under seed #ifndef FROM_X; hybrid pure owns the table.
 */
#[no_mangle]
export function pipeline_dep_arena_slot_set(i: i32, p: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  xlang_ptr_slot_set(&g_pipe_dep_arena_slots[0], i, p);
}

/**
 * Store pointer p into pipeline dep-module slot i (capacity 32).
 * @param i i32 - slot index; i < 0 or i >= 32 -> no-op
 * @param p *u8 - module pointer (may be null)
 * @return void
 * wave70 pure: G.7 xlang_ptr_slot_set on g_pipe_dep_module_slots (pair of arena table).
 * PLATFORM: SHARED LP64 - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_dep_module_slot_set(i: i32, p: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  xlang_ptr_slot_set(&g_pipe_dep_module_slots[0], i, p);
}

/**
 * Load pipeline dep-arena slot i (capacity 32; historical seed had no OOB guard).
 * @param i i32 - slot index; pure rejects i < 0 or i >= 32 -> null (safer than seed raw index)
 * @return *u8 - stored arena pointer (may be null)
 * wave70 pure: G.7 xlang_ptr_slot_get on g_pipe_dep_arena_slots.
 * PLATFORM: SHARED LP64 - cold twin under seed #ifndef FROM_X; pure get_dep_* bounds first.
 */
#[no_mangle]
export function pipeline_dep_arena_slot_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  return xlang_ptr_slot_get(&g_pipe_dep_arena_slots[0], i);
}

/**
 * Load pipeline dep-module slot i (capacity 32).
 * @param i i32 - slot index; pure rejects OOB -> null
 * @return *u8 - stored module pointer (may be null)
 * wave70 pure: G.7 xlang_ptr_slot_get on g_pipe_dep_module_slots.
 * PLATFORM: SHARED LP64 - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_dep_module_slot_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  return xlang_ptr_slot_get(&g_pipe_dep_module_slots[0], i);
}

/**
 * Copy NUL-terminated path into the pipeline entry_dir BSS buffer and select it.
 * @param path *u8 - directory path; null -> no-op (keeps prior selection)
 * @return void
 * wave68 pure: snprintf-equivalent byte copy into g_pipe_entry_dir_buf (cap 512 incl NUL).
 * Clears is_dot so pipeline_entry_dir_get returns the buffer base.
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_entry_dir_copy(path: *u8): void {
  if (path == 0 as *u8) {
    return;
  }
  let i: i32 = 0;
  unsafe {
    // Cap 511 data bytes + trailing NUL - matches seed snprintf into char[512].
    while (i < 511) {
      let c: u8 = path[i];
      g_pipe_entry_dir_buf[i] = c;
      if (c == 0) {
        g_pipe_entry_dir_is_dot = 0;
        return;
      }
      i = i + 1;
    }
    g_pipe_entry_dir_buf[511] = 0;
    g_pipe_entry_dir_is_dot = 0;
  }
}

/**
 * Reset pipeline entry_dir selection to the static "." literal BSS.
 * @return void
 * wave68 pure: sets is_dot and ensures g_pipe_entry_dir_dot holds '.' + NUL.
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_entry_dir_set_dot(): void {
  g_pipe_entry_dir_is_dot = 1;
  g_pipe_entry_dir_dot[0] = 46;
  g_pipe_entry_dir_dot[1] = 0;
}

/**
 * Return the active pipeline entry_dir C string (never null).
 * @return *u8 - either g_pipe_entry_dir_dot (".") or g_pipe_entry_dir_buf; always NUL-terminated
 * wave68 pure: is_dot selects lit vs copy buffer; default is_dot=1 matches seed ".".
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X; used by pure into_static orch.
 */
#[no_mangle]
export function pipeline_entry_dir_get(): *u8 {
  if (g_pipe_entry_dir_is_dot != 0) {
    // First get before set_dot may see zeroed BSS - always materialize "." lit.
    g_pipe_entry_dir_dot[0] = 46;
    g_pipe_entry_dir_dot[1] = 0;
    return &g_pipe_entry_dir_dot[0];
  }
  return &g_pipe_entry_dir_buf[0];
}

// pipeline_set_entry_dir: see function docblock below.
/**
 * Set pipeline resolve/read entry directory from path (null/empty -> ".").
 * @param path *u8 - NUL-terminated directory; null or empty -> pure set_dot
 * @return void
 * Pure orch over pure entry_dir_copy / set_dot (wave68 BSS writers).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_set_entry_dir(path: *u8): void {
  unsafe {
    if (path == 0 as *u8) {
      pipeline_entry_dir_set_dot();
      return;
    }
    if (path[0] == 0) {
      pipeline_entry_dir_set_dot();
      return;
    }
    pipeline_entry_dir_copy(path);
  }
}

/**
 * Bulk-write all 32 dep arena/module slots from two void-star tables (or clear if null).
 * @param arenas *u8 - void** base as bytes (32 cells); null -> write null arenas
 * @param modules *u8 - void** base as bytes (32 cells); null -> write null modules
 * @return void
 * Pure orch: load each cell via pipe_load_ptr_slot then G.7 pure pipeline_dep_*_slot_set
 * (wave70 BSS; single authority - no direct second write into g_pipe_dep_*).
 * PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function pipeline_set_dep_slots(arenas: *u8, modules: *u8): void {
  let i: i32 = 0;
  while (i < 32) {
    unsafe {
      let a: *u8 = 0 as *u8;
      let m: *u8 = 0 as *u8;
      if (arenas != 0 as *u8) {
        a = pipe_load_ptr_slot(arenas, i);
      }
      if (modules != 0 as *u8) {
        m = pipe_load_ptr_slot(modules, i);
      }
      // G.7 pure wave70 slot writers - same cells pure get_dep_* / slot_at read.
      pipeline_dep_arena_slot_set(i, a);
      pipeline_dep_module_slot_set(i, m);
    }
    i = i + 1;
  }
}

// xlang_pipeline_fill_ctx_path_buffers: see function docblock below.
/** Exported function `xlang_pipeline_fill_ctx_path_buffers`.
 * Implements `xlang_pipeline_fill_ctx_path_buffers`.
 * @param ctx *u8
 * @param entry_dir *u8
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @return void
 */
#[no_mangle]
export function xlang_pipeline_fill_ctx_path_buffers(ctx: *u8, entry_dir: *u8, lib_roots: *u8, n_lib_roots: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  unsafe {
    pipeline_dep_ctx_path_bufs_reset(ctx);
    if (entry_dir != 0 as *u8) {
      pipeline_dep_ctx_copy_entry_dir(ctx, entry_dir);
    }
  }
  if (lib_roots == 0 as *u8) {
    return;
  }
  if (n_lib_roots <= 0) {
    return;
  }
  let i: i32 = 0;
  while (i < n_lib_roots) {
    unsafe {
      let p: *u8 = pipe_load_ptr_slot(lib_roots, i);
      if (p != 0 as *u8) {
        let ll: i32 = pipe_cstr_len(p);
        if (ll > 255) {
          ll = 255;
        }
        if (ll > 0) {
          let _r: i32 = ast_pipeline_ctx_append_lib_root(ctx, p, ll);
        }
      }
    }
    i = i + 1;
  }
}

// pipe_cstr_len: see function docblock below.
/** Exported function `pipe_cstr_len`.
 * Query helper `pipe_cstr_len`.
 * @param s *u8
 * @return i32
 */
export function pipe_cstr_len(s: *u8): i32 {
  if (s == 0 as *u8) { return 0; }
  let i: i32 = 0;
  while (i < 65536) {
    if (s[i] == 0) { return i; }
    i = i + 1;
  }
  return i;
}

// xlang_pipeline_pctx_seed_dep_slots: see function docblock below.
/** Exported function `xlang_pipeline_pctx_seed_dep_slots`.
 * Implements `xlang_pipeline_pctx_seed_dep_slots`.
 * @param ctx *u8
 * @param dep_mods *u8
 * @param dep_ar *u8
 * @param import_paths *u8
 * @param n i32
 * @return void
 */
#[no_mangle]
export function xlang_pipeline_pctx_seed_dep_slots(ctx: *u8, dep_mods: *u8, dep_ar: *u8, import_paths: *u8, n: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  unsafe {
    ast_pipeline_dep_ctx_reset(ctx);
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      let m: *u8 = 0 as *u8;
      let a: *u8 = 0 as *u8;
      if (dep_mods != 0 as *u8) {
        m = pipe_load_ptr_slot(dep_mods, i);
      }
      if (dep_ar != 0 as *u8) {
        a = pipe_load_ptr_slot(dep_ar, i);
      }
      ast_pipeline_dep_ctx_set_module(ctx, i, m);
      ast_pipeline_dep_ctx_set_arena(ctx, i, a);
      if (import_paths != 0 as *u8) {
        let p: *u8 = pipe_load_ptr_slot(import_paths, i);
        if (p != 0 as *u8) {
          let pl: i32 = pipe_cstr_len(p);
          ast_pipeline_dep_ctx_set_import_path(ctx, i, p, pl);
        }
      }
    }
    i = i + 1;
  }
  unsafe {
    ast_pipeline_dep_ctx_set_ndep(ctx, n);
  }
}

// xlang_pipeline_pctx_seed_dep_import_paths_only: see function docblock below.
/** Exported function `xlang_pipeline_pctx_seed_dep_import_paths_only`.
 * Implements `xlang_pipeline_pctx_seed_dep_import_paths_only`.
 * @param ctx *u8
 * @param import_paths *u8
 * @param n i32
 * @return void
 */
#[no_mangle]
export function xlang_pipeline_pctx_seed_dep_import_paths_only(ctx: *u8, import_paths: *u8, n: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  unsafe {
    ast_pipeline_dep_ctx_reset(ctx);
  }
  let i: i32 = 0;
  while (i < n) {
    if (import_paths != 0 as *u8) {
      unsafe {
        let p: *u8 = pipe_load_ptr_slot(import_paths, i);
        if (p != 0 as *u8) {
          let pl: i32 = pipe_cstr_len(p);
          ast_pipeline_dep_ctx_set_import_path(ctx, i, p, pl);
        }
      }
    }
    i = i + 1;
  }
}

/**
 * Map one dep prerun ctx slots from dep's own import table (not entry full dep list).
 * Allocates tmp arena/module, parses dep_src, filters dep_mods/ars/paths by import names,
 * writes compact ctx slots [0..mapped). Hard parse fail falls back to full ndep slots.
 * @param ctx *u8 - PipelineDepCtx*; null -> no-op
 * @param dep_mods *u8 - void star-star loaded dep modules base
 * @param dep_ars *u8 - void star-star loaded dep arenas base
 * @param dep_paths *u8 - char star-star loaded dep path keys base
 * @param ndep i32 - loaded dep count (table width)
 * @param dep_src *u8 - dep source bytes for import scan; caller thin already validated
 * @param dep_src_len i64 - byte length; must be in (0, INT32_MAX]
 * @return void
 * wave62 pure Cap residual orch:
 *   G.7 pure pipeline_sizeof_arena / pipeline_sizeof_module (wave83 LP64 constants);
 *   G.7 pure parser_parse_into_init (wave1222: full body matching C authority);
 *   G.7 pure driver_parse_into_buf_rc (returns raw ok; allow 0 and -2 like historical seed);
 *   G.7 pure xlang_module_num_imports / xlang_module_import_path_cstr /
 *   xlang_find_loaded_import_index / xlang_pipeline_pctx_update_dep_slots_no_reset /
 *   pipe_load_ptr_slot / pipe_cstr_len / ast_pipeline_dep_ctx_set_*.
 * Why not pipeline_parse_into_bytes: that maps non-zero ok to -1 and loses ok==-2
 * (under-parse still has usable import table). PLATFORM: SHARED.
 */

/**
 * Free heap arena/module after releasing process-wide AST sidecars.
 *
 * Why: collect_deps and dep-prerun map allocate temporary arena/module heaps,
 * parse into them (attaching g_arena_sc / g_module_sc GrowVecs), then free.
 * free alone leaves those slots used with dangling keys; the next malloc may
 * reuse the address and reattach stale GrowVec data. That is why directory
 * `xlang check` truncates large files after any importful predecessor
 * (e.g. parser.x / codegen.x -> runtime_pipeline_abi num_funcs 363->111).
 *
 * @param arena  temporary AST arena heap (nullable)
 * @param module temporary Module heap (nullable)
 * PLATFORM: SHARED - G.7 single helper for all collect/prerun tmp teardown.
 */
function pipe_release_tmp_arena_module(arena: *u8, module: *u8): void {
  unsafe {
    if (arena != 0 as *u8) {
      ast_pool_arena_release(arena);
      free(arena);
    }
    if (module != 0 as *u8) {
      ast_pool_module_release(module);
      free(module);
    }
  }
}

#[no_mangle]
export function xlang_pipeline_one_ctx_for_dep_prerun_map_impl(ctx: *u8, dep_mods: *u8, dep_ars: *u8, dep_paths: *u8, ndep: i32, dep_src: *u8, dep_src_len: i64): void {
  if (ctx == 0 as *u8) {
    return;
  }
  let asz: usize = 0 as usize;
  let msz: usize = 0 as usize;
  unsafe {
    asz = pipeline_sizeof_arena();
    msz = pipeline_sizeof_module();
  }
  let tmp_arena: *u8 = 0 as *u8;
  let tmp_module: *u8 = 0 as *u8;
  unsafe {
    tmp_arena = malloc(asz);
    tmp_module = malloc(msz);
  }
  // OOM: fall back to full entry dep table (same as historical seed).
  if (tmp_arena == 0 as *u8) {
    if (tmp_module != 0 as *u8) {
      unsafe {
        pipe_release_tmp_arena_module(0 as *u8, tmp_module);
      }
    }
    xlang_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
    return;
  }
  if (tmp_module == 0 as *u8) {
    unsafe {
      pipe_release_tmp_arena_module(tmp_arena, 0 as *u8);
    }
    xlang_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
    return;
  }
  unsafe {
    memset(tmp_arena, 0, asz);
    memset(tmp_module, 0, msz);
    // Init before parse_into_buf residual (same order as seed map_impl).
    // wave1222: trait_reg_reset + generic_bound_stash prevent cross-file state leak.
    xlang_trait_reg_reset_c(tmp_arena);
    xlang_generic_bound_stash_source_buf_c(dep_src, dep_src_len as i32);
    parser_parse_into_init(tmp_module, tmp_arena);
  }
  // INT32_MAX already gated by thin; cast for buf_rc ABI.
  let len_i32: i32 = dep_src_len as i32;
  let pr_ok: i32 = 0;
  unsafe {
    // Cap-struct-return residual unpacks ParseIntoResult.ok; null out_main_idx.
    pr_ok = driver_parse_into_buf_rc(tmp_arena, tmp_module, dep_src, len_i32, 0 as *i32);
  }
  // Historical: accept ok==0 (full) and ok==-2 (under-parse; import table still usable).
  // Any other non-zero -> free tmp + full slots fallback.
  if (pr_ok != 0) {
    if (pr_ok != (0 - 2)) {
      unsafe {
        pipe_release_tmp_arena_module(tmp_arena, tmp_module);
      }
      xlang_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
      return;
    }
  }
  let n_imp: i32 = xlang_module_num_imports(tmp_module);
  if (n_imp <= 0) {
    unsafe {
      pipe_release_tmp_arena_module(tmp_arena, tmp_module);
      ast_pipeline_dep_ctx_set_ndep(ctx, 0);
    }
    return;
  }
  // Compact map: only imports that match a loaded dep path key (import_idx -> ctx slot).
  let mapped: i32 = 0;
  let ii: i32 = 0;
  while (ii < n_imp) {
    let path_c: u8[65] = [];
    xlang_module_import_path_cstr(tmp_module, ii, &path_c[0], 65);
    let g: i32 = xlang_find_loaded_import_index(&path_c[0], dep_paths, ndep);
    if (g < 0) {
      ii = ii + 1;
      continue;
    }
    unsafe {
      let m: *u8 = pipe_load_ptr_slot(dep_mods, g);
      let a: *u8 = pipe_load_ptr_slot(dep_ars, g);
      ast_pipeline_dep_ctx_set_module(ctx, mapped, m);
      ast_pipeline_dep_ctx_set_arena(ctx, mapped, a);
      let p: *u8 = pipe_load_ptr_slot(dep_paths, g);
      if (p != 0 as *u8) {
        let pl: i32 = pipe_cstr_len(p);
        ast_pipeline_dep_ctx_set_import_path(ctx, mapped, p, pl);
      }
    }
    mapped = mapped + 1;
    ii = ii + 1;
  }
  unsafe {
    pipe_release_tmp_arena_module(tmp_arena, tmp_module);
    ast_pipeline_dep_ctx_set_ndep(ctx, mapped);
  }
}

/**
 * Thin gate for one-ctx dep prerun mapping (null/empty/oversized -> full slots or ndep=0).
 * @param ctx *u8 - PipelineDepCtx*; null -> no-op
 * @param j i32 - historical dep index; unused (kept for ABI)
 * @param dep_mods *u8 - void star-star modules; null -> ndep=0
 * @param dep_ars *u8 - void star-star arenas; null -> ndep=0
 * @param dep_paths *u8 - char star-star paths; null -> ndep=0
 * @param ndep i32 - loaded count; <=0 -> ndep=0
 * @param dep_src *u8 - dep source for import scan; null/empty/oversized -> full slots
 * @param dep_src_len i64 - source length; <=0 or > INT32_MAX -> full slots
 * @return void
 * wave62: body in pure xlang_pipeline_one_ctx_for_dep_prerun_map_impl after flags.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_pipeline_one_ctx_for_dep_prerun(ctx: *u8, j: i32, dep_mods: *u8, dep_ars: *u8, dep_paths: *u8, ndep: i32, dep_src: *u8, dep_src_len: i64): void {
  if (ctx == 0 as *u8) {
    return;
  }
  // Historical signature keeps j; map path ignores it.
  let _j: i32 = j;
  unsafe {
    pipeline_dep_ctx_set_use_asm_backend(ctx, 0);
  }
  if (dep_mods == 0 as *u8) {
    unsafe { ast_pipeline_dep_ctx_set_ndep(ctx, 0); }
    return;
  }
  if (dep_ars == 0 as *u8) {
    unsafe { ast_pipeline_dep_ctx_set_ndep(ctx, 0); }
    return;
  }
  if (dep_paths == 0 as *u8) {
    unsafe { ast_pipeline_dep_ctx_set_ndep(ctx, 0); }
    return;
  }
  if (ndep <= 0) {
    unsafe { ast_pipeline_dep_ctx_set_ndep(ctx, 0); }
    return;
  }
  if (dep_src == 0 as *u8) {
    xlang_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
    return;
  }
  if (dep_src_len <= 0) {
    xlang_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
    return;
  }
  // INT32_MAX - parse_into_buf residual takes int32_t len.
  let imax: i64 = 2147483647;
  if (dep_src_len > imax) {
    xlang_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
    return;
  }
  unsafe {
    xlang_pipeline_one_ctx_for_dep_prerun_map_impl(ctx, dep_mods, dep_ars, dep_paths, ndep, dep_src, dep_src_len);
  }
}

/* See implementation. */

// xlang_driver_asm_prepare_entry_elf_emit: see function docblock below.
/** Exported function `xlang_driver_asm_prepare_entry_elf_emit`.
 * Implements `xlang_driver_asm_prepare_entry_elf_emit`.
 * @param module *u8
 * @param arena *u8
 * @param pctx *u8
 * @return void
 */
#[no_mangle]
export function xlang_driver_asm_prepare_entry_elf_emit(module: *u8, arena: *u8, pctx: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  if (arena == 0 as *u8) {
    return;
  }
  unsafe {
    asm_skip_heavy_set_pipeline_ctx(pctx);
    pipeline_fill_array_lit_types_for_skipped_typeck(module, arena);
    typeck_soa_fill_field_access_for_asm_emit(module, arena);
    pipeline_debug_trace_named_func_bodies("emit_prepare_pre_fixup", module, arena);
    pipeline_module_fixup_with_arena_stmt_orders(module, arena);
    pipeline_debug_trace_named_func_bodies("emit_prepare_post_fixup", module, arena);
  }
}

// xlang_asm_codegen_elf_o_large_stack: see function docblock below.
/**
 * Thin gate -> pure xlang_asm_codegen_elf_o_large_stack_impl (wave57).
 * @param module *u8 - AST module; null -> -1
 * @param arena *u8 - AST arena; null -> -1
 * @param ctx *u8 - PipelineDepCtx (may be null)
 * @param elf_ctx *u8 - ElfCodegenCtx (may be null)
 * @param out_buf *u8 - emit out buffer; null -> -1
 * @return i32 - emit ec from large-stack orch
 * wave57: body in pure _impl; product emit via Cap residual (not same-TU weak stub).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_asm_codegen_elf_o_large_stack(module: *u8, arena: *u8, ctx: *u8, elf_ctx: *u8, out_buf: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (out_buf == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    return xlang_asm_codegen_elf_o_large_stack_impl(module, arena, ctx, elf_ctx, out_buf);
  }
  return 0 - 1;
}

/**
 * Free dep_sources/dep_paths slots [0, mi) on load_direct failure (partial fill).
 * @param dep_sources *u8 - char star-star prep sources; may be null (skip frees)
 * @param dep_paths *u8 - char star-star owned keys; may be null (skip frees)
 * @param mi i32 - exclusive upper bound of slots to free; mi<=0 -> no-op
 * @return void
 * wave51 pure Cap residual orch: walk mi-1..0; free non-null slots; clear to null.
 * G.7 single authority for fail cleanup (load_direct_imports layout + cold twin).
 * PLATFORM: SHARED - pure link-name; free still libc.
 */
#[no_mangle]
export function xlang_load_direct_fail_cleanup(dep_sources: *u8, dep_paths: *u8, mi: i32): void {
  let i: i32 = mi;
  while (i > 0) {
    i = i - 1;
    if (dep_sources != 0 as *u8) {
      let s: *u8 = pipe_load_ptr_slot(dep_sources, i);
      if (s != 0 as *u8) {
        unsafe {
          free(s);
        }
        pipe_store_ptr_slot(dep_sources, i, 0 as *u8);
      }
    }
    if (dep_paths != 0 as *u8) {
      let p: *u8 = pipe_load_ptr_slot(dep_paths, i);
      if (p != 0 as *u8) {
        unsafe {
          free(p);
        }
        pipe_store_ptr_slot(dep_paths, i, 0 as *u8);
      }
    }
  }
}

/**
 * Resolve import key, read file view, preprocess -> owned prep (no dep slot store).
 * @param lib_roots *u8 - char star-star lib roots; may be null if n_lib_roots==0
 * @param n_lib_roots i32 - lib root count
 * @param entry_dir *u8 - entry directory C string; may be null
 * @param import_key *u8 - import path key C string; null -> fail 1
 * @param defines *u8 - char star-star define names; may be null if ndefines==0
 * @param ndefines i32 - define count; if <=0 pass null defines into preprocess
 * @param out_prep *u8 - char star-star out cell (LP64 8B); null -> fail 1; cleared on entry
 * @param out_prep_len *u8 - size_t out cell as bytes; null -> fail 1; cleared on entry
 * @return i32 - 0 success (*out_prep owned, free with free); 1 fail (out cleared)
 * wave55 pure Cap residual orch (was always-seed PATH_MAX+FILE view):
 *   stack resolved[4096] (SHARED path cap; gold Linux PATH_MAX);
 *   pure xlang_resolve_import_file_path_multi;
 *   runtime_read_file_view into 32B stack XlangRuntimeFileView (G.7 same as fmt_check);
 *   open fail -> pure pipeline_diag_import_open_fail_once;
 *   pure xlang_preprocess_raw_to_malloc(view.data, view.length, out_prep, out_prep_len, ...);
 *   runtime_release_file_view always after read success path;
 *   null prep after preprocess ok -> pure pipeline_diag_import_preprocess_fail.
 * G.7 load_one + paths_tmp call this (single resolve/read/preprocess body). PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_load_one_direct_resolve_read_preprocess(lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, import_key: *u8, defines: *u8, ndefines: i32, out_prep: *u8, out_prep_len: *u8): i32 {
  if (import_key == 0 as *u8) {
    return 1;
  }
  if (out_prep == 0 as *u8) {
    return 1;
  }
  if (out_prep_len == 0 as *u8) {
    return 1;
  }
  // Clear out cells first (same contract as seed cold twin).
  pipe_store_ptr_slot(out_prep, 0, 0 as *u8);
  xlang_size_slot_set(out_prep_len, 0, 0);
  // Resolved path buffer: 4096 matches gold Linux PATH_MAX; pure stack (no BSS dual path).
  let resolved: u8[4096] = [];
  let zi: i32 = 0;
  while (zi < 4096) {
    resolved[zi] = 0;
    zi = zi + 1;
  }
  unsafe {
    xlang_resolve_import_file_path_multi(lib_roots, n_lib_roots, entry_dir, import_key, &resolved[0], 4096 as i64);
  }
  // XlangRuntimeFileView ABI: data@0 length@8 needs_free@16 needs_munmap@20 (24B; pad 32).
  let view: u8[32] = [];
  let z: i32 = 0;
  while (z < 32) {
    view[z] = 0;
    z = z + 1;
  }
  let view_rc: i32 = 0;
  unsafe {
    view_rc = runtime_read_file_view(&resolved[0], &view[0]);
  }
  if (view_rc != 0) {
    pipeline_diag_import_open_fail_once(import_key, &resolved[0]);
    return 1;
  }
  let raw_data: *u8 = xlang_ptr_slot_get(&view[0], 0);
  let raw_len: i64 = xlang_size_slot_get(&view[0], 1);
  // defines: only pass table when ndefines > 0 (seed cold twin ternary).
  let def_arg: *u8 = 0 as *u8;
  if (ndefines > 0) {
    def_arg = defines;
  }
  let prep_rc: i32 = 0;
  unsafe {
    prep_rc = xlang_preprocess_raw_to_malloc(raw_data, raw_len, out_prep, out_prep_len, &resolved[0], def_arg, ndefines);
  }
  unsafe {
    runtime_release_file_view(&view[0]);
  }
  if (prep_rc != 0) {
    // Preprocess failed: keep out cleared (preprocess may have written partial; re-clear).
    pipe_store_ptr_slot(out_prep, 0, 0 as *u8);
    xlang_size_slot_set(out_prep_len, 0, 0);
    return 1;
  }
  let prep: *u8 = pipe_load_ptr_slot(out_prep, 0);
  if (prep == 0 as *u8) {
    pipeline_diag_import_preprocess_fail(import_key, &resolved[0]);
    xlang_size_slot_set(out_prep_len, 0, 0);
    return 1;
  }
  return 0;
}

/**
 * Resolve one import key, read+preprocess into prep, store dep_sources/lens/paths[mi].
 * @param lib_roots *u8 - char star-star lib roots; may be null if n_lib_roots==0
 * @param n_lib_roots i32 - lib root count
 * @param entry_dir *u8 - entry directory C string; may be null
 * @param import_key *u8 - import path key C string; null -> fail 1
 * @param defines *u8 - char star-star define names; may be null if ndefines==0
 * @param ndefines i32 - define count
 * @param dep_sources *u8 - char star-star prep sources out; may be null (skip store)
 * @param dep_lens *u8 - size_t array base as bytes; may be null (skip store)
 * @param dep_paths *u8 - char star-star owned keys out; may be null (skip strdup store)
 * @param mi i32 - slot index; mi < 0 -> fail 1
 * @return i32 - 0 success (slot written); 1 fail (no partial slot leave when paths OOM frees prep)
 * wave51 pure Cap residual orch:
 *   wave55 pure xlang_load_one_direct_resolve_read_preprocess -> owned prep;
 *   store prep + prep_len at mi;
 *   wave54 pure xlang_collect_strdup(import_key) -> dep_paths[mi];
 *   OOM on key: free prep, clear source slot, return 1.
 * G.7 process_one / load_direct_imports layout call this. PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_load_one_direct_import_at(lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, import_key: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, mi: i32): i32 {
  if (import_key == 0 as *u8) {
    return 1;
  }
  if (mi < 0) {
    return 1;
  }
  // out_prep (char*) and out_prep_len (size_t) as 8-byte stack cells (LP64).
  let prep_cell: u8[8] = [];
  let prep_len_cell: u8[8] = [];
  let rc: i32 = 0;
  unsafe {
    rc = xlang_load_one_direct_resolve_read_preprocess(lib_roots, n_lib_roots, entry_dir, import_key, defines, ndefines, &prep_cell[0], &prep_len_cell[0]);
  }
  if (rc != 0) {
    return 1;
  }
  let prep: *u8 = pipe_load_ptr_slot(&prep_cell[0], 0);
  let prep_len: i64 = xlang_size_slot_get(&prep_len_cell[0], 0);
  if (prep == 0 as *u8) {
    return 1;
  }
  if (dep_sources != 0 as *u8) {
    pipe_store_ptr_slot(dep_sources, mi, prep);
  }
  if (dep_lens != 0 as *u8) {
    xlang_size_slot_set(dep_lens, mi, prep_len);
  }
  if (dep_paths != 0 as *u8) {
    let key: *u8 = 0 as *u8;
    unsafe {
      key = xlang_collect_strdup(import_key);
    }
    if (key == 0 as *u8) {
      unsafe {
        free(prep);
      }
      if (dep_sources != 0 as *u8) {
        pipe_store_ptr_slot(dep_sources, mi, 0 as *u8);
      }
      return 1;
    }
    pipe_store_ptr_slot(dep_paths, mi, key);
  }
  return 0;
}

// xlang_load_direct_imports_for_asm_layout: see function docblock below.
/**
 * Load all direct module imports into dep_sources/lens/paths for asm layout.
 * @param module *u8 - AST module; null -> -1
 * @param lib_roots *u8 - char star-star lib roots; may be null if n_lib_roots==0
 * @param n_lib_roots i32 - lib root count
 * @param entry_dir *u8 - entry directory C string; may be null
 * @param defines *u8 - char star-star define names; may be null if ndefines==0
 * @param ndefines i32 - define count
 * @param dep_sources *u8 - char star-star prep sources out slots
 * @param dep_lens *u8 - size_t array base as bytes for prep lengths
 * @param dep_paths *u8 - char star-star owned path keys out slots
 * @param out_n *i32 - out live count; null -> -1
 * @return i32 - 0 success; 1 load fail (partial freed); -1 null args
 * wave45+ pure orch; wave51 uses pure load_one + fail_cleanup. PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_load_direct_imports_for_asm_layout(module: *u8, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, out_n: *i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (out_n == 0 as *i32) {
    return 0 - 1;
  }
  unsafe {
    xlang_i32_store(out_n, 0);
  }
  let n_imports: i32 = 0;
  unsafe {
    n_imports = xlang_module_num_imports(module);
  }
  if (n_imports <= 0) {
    return 0;
  }
  let mi: i32 = 0;
  let i: i32 = 0;
  while (i < n_imports) {
    if (i >= 32) { break; }
    if (mi >= 32) { break; }
    let path_c: u8[65] = [];
    unsafe {
      xlang_module_import_path_cstr(module, i, &path_c[0], 65);
    }
    let rc: i32 = 0;
    unsafe {
      rc = xlang_load_one_direct_import_at(lib_roots, n_lib_roots, entry_dir, &path_c[0], defines, ndefines, dep_sources, dep_lens, dep_paths, mi);
    }
    if (rc != 0) {
      unsafe {
        xlang_load_direct_fail_cleanup(dep_sources, dep_paths, mi);
        xlang_i32_store(out_n, 0);
      }
      return 1;
    }
    mi = mi + 1;
    i = i + 1;
  }
  unsafe {
    xlang_i32_store(out_n, mi);
  }
  return 0;
}

// xlang_merge_direct_then_transitive_dep_paths: see function docblock below.
/** Exported function `xlang_merge_direct_then_transitive_dep_paths`.
 * Implements `xlang_merge_direct_then_transitive_dep_paths`.
 * @param module *u8
 * @param n_imports i32
 * @param cpaths *u8
 * @param n_closure i32
 * @param out_paths *u8
 * @param out_n *i32
 * @return i32
 */
#[no_mangle]
export function xlang_merge_direct_then_transitive_dep_paths(module: *u8, n_imports: i32, cpaths: *u8, n_closure: i32, out_paths: *u8, out_n: *i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (out_n == 0 as *i32) {
    return 0 - 1;
  }
  if (out_paths == 0 as *u8) {
    return 0 - 1;
  }
  let used: u8[32] = [];
  let ui: i32 = 0;
  while (ui < 32) {
    used[ui] = 0;
    ui = ui + 1;
  }
  let mi: i32 = 0;
  let i: i32 = 0;
  while (i < n_imports) {
    if (i >= 32) { break; }
    if (mi >= 32) { break; }
    let path_c: u8[65] = [];
    unsafe {
      xlang_module_import_path_cstr(module, i, &path_c[0], 65);
    }
    let found: i32 = 0 - 1;
    let kk: i32 = 0;
    while (kk < n_closure) {
      unsafe {
        let cp: *u8 = 0 as *u8;
        if (cpaths != 0 as *u8) {
          cp = pipe_load_ptr_slot(cpaths, kk);
        }
        if (cp != 0 as *u8) {
          if (pipe_cstr_eq(cp, &path_c[0]) != 0) {
            found = kk;
          }
        }
      }
      if (found >= 0) { break; }
      kk = kk + 1;
    }
    if (found < 0) {
      pipeline_diag_merge_dep_missing(&path_c[0]);
      return 1;
    }
    unsafe {
      let pfound: *u8 = pipe_load_ptr_slot(cpaths, found);
      xlang_ptr_slot_set(out_paths, mi, pfound);
    }
    if (found < 32) {
      used[found] = 1;
    }
    mi = mi + 1;
    i = i + 1;
  }
  let kj: i32 = 0;
  while (kj < n_closure) {
    if (mi >= 32) { break; }
    if (kj < 32) {
      if (used[kj] == 0) {
        unsafe {
          let cp2: *u8 = 0 as *u8;
          if (cpaths != 0 as *u8) {
            cp2 = pipe_load_ptr_slot(cpaths, kj);
          }
          if (cp2 != 0 as *u8) {
            if (xlang_merge_deps_path_already_out(cp2, out_paths, mi) != 0) {
              used[kj] = 1;
            } else {
              xlang_ptr_slot_set(out_paths, mi, cp2);
              mi = mi + 1;
            }
          } else {
            xlang_ptr_slot_set(out_paths, mi, cp2);
            mi = mi + 1;
          }
        }
      }
    }
    kj = kj + 1;
  }
  unsafe {
    xlang_i32_store(out_n, mi);
  }
  return 0;
}

/* See implementation. */

// xlang_merge_direct_then_transitive_deps: see function docblock below.
/** Exported function `xlang_merge_direct_then_transitive_deps`.
 * Implements `xlang_merge_direct_then_transitive_deps`.
 * @param module *u8
 * @param n_imports i32
 * @param cls *u8
 * @param clens *u8
 * @param cpaths *u8
 * @param n_closure i32
 * @param out_src *u8
 * @param out_lens *u8
 * @param out_paths *u8
 * @param out_n *i32
 * @return i32
 */
#[no_mangle]
export function xlang_merge_direct_then_transitive_deps(module: *u8, n_imports: i32, cls: *u8, clens: *u8, cpaths: *u8, n_closure: i32, out_src: *u8, out_lens: *u8, out_paths: *u8, out_n: *i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (out_n == 0 as *i32) {
    return 0 - 1;
  }
  if (out_paths == 0 as *u8) {
    return 0 - 1;
  }
  let used: u8[32] = [];
  let ui: i32 = 0;
  while (ui < 32) {
    used[ui] = 0;
    ui = ui + 1;
  }
  let mi: i32 = 0;
  let i: i32 = 0;
  while (i < n_imports) {
    if (i >= 32) { break; }
    if (mi >= 32) { break; }
    let path_c: u8[65] = [];
    unsafe {
      xlang_module_import_path_cstr(module, i, &path_c[0], 65);
    }
    let found: i32 = 0 - 1;
    let kk: i32 = 0;
    while (kk < n_closure) {
      unsafe {
        let cp: *u8 = 0 as *u8;
        if (cpaths != 0 as *u8) {
          cp = pipe_load_ptr_slot(cpaths, kk);
        }
        if (cp != 0 as *u8) {
          if (pipe_cstr_eq(cp, &path_c[0]) != 0) {
            found = kk;
          }
        }
      }
      if (found >= 0) { break; }
      kk = kk + 1;
    }
    if (found < 0) {
      pipeline_diag_merge_dep_missing(&path_c[0]);
      return 1;
    }
    unsafe {
      let pfound: *u8 = 0 as *u8;
      let sfound: *u8 = 0 as *u8;
      let lfound: i64 = 0;
      if (cpaths != 0 as *u8) {
        pfound = pipe_load_ptr_slot(cpaths, found);
      }
      if (cls != 0 as *u8) {
        sfound = pipe_load_ptr_slot(cls, found);
      }
      if (clens != 0 as *u8) {
        lfound = xlang_size_slot_get(clens, found);
      }
      if (out_src != 0 as *u8) {
        xlang_ptr_slot_set(out_src, mi, sfound);
      }
      if (out_lens != 0 as *u8) {
        xlang_size_slot_set(out_lens, mi, lfound);
      }
      xlang_ptr_slot_set(out_paths, mi, pfound);
    }
    if (found < 32) {
      used[found] = 1;
    }
    mi = mi + 1;
    i = i + 1;
  }
  let kj: i32 = 0;
  while (kj < n_closure) {
    if (mi >= 32) { break; }
    if (kj < 32) {
      if (used[kj] == 0) {
        unsafe {
          let cp2: *u8 = 0 as *u8;
          if (cpaths != 0 as *u8) {
            cp2 = pipe_load_ptr_slot(cpaths, kj);
          }
          if (cp2 != 0 as *u8) {
            if (xlang_merge_deps_path_already_out(cp2, out_paths, mi) != 0) {
              used[kj] = 1;
            } else {
              let s2: *u8 = 0 as *u8;
              let l2: i64 = 0;
              if (cls != 0 as *u8) {
                s2 = pipe_load_ptr_slot(cls, kj);
              }
              if (clens != 0 as *u8) {
                l2 = xlang_size_slot_get(clens, kj);
              }
              if (out_src != 0 as *u8) {
                xlang_ptr_slot_set(out_src, mi, s2);
              }
              if (out_lens != 0 as *u8) {
                xlang_size_slot_set(out_lens, mi, l2);
              }
              xlang_ptr_slot_set(out_paths, mi, cp2);
              mi = mi + 1;
            }
          } else {
            let s3: *u8 = 0 as *u8;
            let l3: i64 = 0;
            if (cls != 0 as *u8) {
              s3 = pipe_load_ptr_slot(cls, kj);
            }
            if (clens != 0 as *u8) {
              l3 = xlang_size_slot_get(clens, kj);
            }
            if (out_src != 0 as *u8) {
              xlang_ptr_slot_set(out_src, mi, s3);
            }
            if (out_lens != 0 as *u8) {
              xlang_size_slot_set(out_lens, mi, l3);
            }
            xlang_ptr_slot_set(out_paths, mi, cp2);
            mi = mi + 1;
          }
        }
      }
    }
    kj = kj + 1;
  }
  unsafe {
    xlang_i32_store(out_n, mi);
  }
  return 0;
}

// xlang_collect_deps_transitive: see function docblock below.
/** Exported function `xlang_collect_deps_transitive`.
 * Implements `xlang_collect_deps_transitive`.
 * @param module *u8
 * @param arena_sz i64
 * @param module_sz i64
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @param entry_dir *u8
 * @param defines *u8
 * @param ndefines i32
 * @param dep_sources *u8
 * @param dep_lens *u8
 * @param dep_paths *u8
 * @param n_deps *i32
 * @return i32
 */
#[no_mangle]
export function xlang_collect_deps_transitive(module: *u8, arena_sz: i64, module_sz: i64, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, n_deps: *i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (n_deps == 0 as *i32) {
    return 0 - 1;
  }
  let nimp: i32 = 0;
  unsafe {
    nimp = xlang_module_num_imports(module);
  }
  if (nimp <= 0) {
    unsafe {
      xlang_i32_store(n_deps, 0);
    }
    return 0;
  }
  unsafe {
    return xlang_collect_deps_transitive_impl(module, arena_sz, module_sz, lib_roots, n_lib_roots, entry_dir, defines, ndefines, dep_sources, dep_lens, dep_paths, n_deps);
  }
  return 0 - 1;
}

// xlang_collect_dep_paths_transitive: see function docblock below.
/** Exported function `xlang_collect_dep_paths_transitive`.
 * Implements `xlang_collect_dep_paths_transitive`.
 * @param module *u8
 * @param arena_sz i64
 * @param module_sz i64
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @param entry_dir *u8
 * @param defines *u8
 * @param ndefines i32
 * @param dep_paths *u8
 * @param n_deps *i32
 * @return i32
 */
#[no_mangle]
export function xlang_collect_dep_paths_transitive(module: *u8, arena_sz: i64, module_sz: i64, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_paths: *u8, n_deps: *i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (n_deps == 0 as *i32) {
    return 0 - 1;
  }
  let nimp: i32 = 0;
  unsafe {
    nimp = xlang_module_num_imports(module);
  }
  if (nimp <= 0) {
    unsafe {
      xlang_i32_store(n_deps, 0);
    }
    return 0;
  }
  unsafe {
    return xlang_collect_dep_paths_transitive_impl(module, arena_sz, module_sz, lib_roots, n_lib_roots, entry_dir, defines, ndefines, dep_paths, n_deps);
  }
  return 0 - 1;
}

/**
 * Append a NUL-terminated C string into dst at offset at (wave82 body-trace msg builder).
 * @param dst *u8 - destination buffer; null -> return at unchanged
 * @param cap i32 - buffer capacity including space for trailing NUL
 * @param at i32 - current write offset
 * @param src *u8 - source cstr; null -> return at unchanged
 * @return i32 - new write offset (NUL written at dst[returned] when room)
 * G.7: product link does not export driver_diag_append_*; same-TU pipe_ helper avoids
 * a second cross-module public append authority while matching diagnostic append semantics.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipe_diag_msg_append_cstr(dst: *u8, cap: i32, at: i32, src: *u8): i32 {
  if (dst == 0 as *u8) {
    return at;
  }
  if (src == 0 as *u8) {
    return at;
  }
  let j: i32 = at;
  let i: i32 = 0;
  unsafe {
    while (j + 1 < cap) {
      let c: u8 = src[i];
      if (c == 0) {
        break;
      }
      dst[j] = c;
      j = j + 1;
      i = i + 1;
    }
    if (j < cap) {
      dst[j] = 0;
    }
  }
  return j;
}

/**
 * Append a decimal i32 (optional leading '-') into dst at offset at (wave82).
 * @param dst *u8 - destination buffer; null -> return at unchanged
 * @param cap i32 - buffer capacity
 * @param at i32 - current write offset
 * @param val i32 - value to append
 * @return i32 - new write offset
 * PLATFORM: SHARED - same digit order as driver_diag_append_i32.
 */
#[no_mangle]
export function pipe_diag_msg_append_i32(dst: *u8, cap: i32, at: i32, val: i32): i32 {
  if (dst == 0 as *u8) {
    return at;
  }
  if (at + 1 >= cap) {
    return at;
  }
  let v: i32 = val;
  unsafe {
    if (v < 0) {
      dst[at] = 45;
      at = at + 1;
      v = 0 - v;
    }
    // Collect up to 10 digits least-first then reverse-write.
    let d0: i32 = 0;
    let d1: i32 = 0;
    let d2: i32 = 0;
    let d3: i32 = 0;
    let d4: i32 = 0;
    let d5: i32 = 0;
    let d6: i32 = 0;
    let d7: i32 = 0;
    let d8: i32 = 0;
    let d9: i32 = 0;
    let dn: i32 = 0;
    if (v == 0) {
      d0 = 0;
      dn = 1;
    } else {
      let t: i32 = v;
      while (t > 0) {
        if (dn >= 10) {
          break;
        }
        let dig: i32 = t % 10;
        if (dn == 0) { d0 = dig; }
        if (dn == 1) { d1 = dig; }
        if (dn == 2) { d2 = dig; }
        if (dn == 3) { d3 = dig; }
        if (dn == 4) { d4 = dig; }
        if (dn == 5) { d5 = dig; }
        if (dn == 6) { d6 = dig; }
        if (dn == 7) { d7 = dig; }
        if (dn == 8) { d8 = dig; }
        if (dn == 9) { d9 = dig; }
        dn = dn + 1;
        t = t / 10;
      }
    }
    let k: i32 = dn;
    while (k > 0) {
      if (at + 1 >= cap) {
        break;
      }
      k = k - 1;
      let dig: i32 = 0;
      if (k == 0) { dig = d0; }
      if (k == 1) { dig = d1; }
      if (k == 2) { dig = d2; }
      if (k == 3) { dig = d3; }
      if (k == 4) { dig = d4; }
      if (k == 5) { dig = d5; }
      if (k == 6) { dig = d6; }
      if (k == 7) { dig = d7; }
      if (k == 8) { dig = d8; }
      if (k == 9) { dig = d9; }
      dst[at] = (48 + dig) as u8;
      at = at + 1;
    }
    if (at < cap) {
      dst[at] = 0;
    }
  }
  return at;
}

/**
 * Append name[0..name_len) into dst at offset at (wave82).
 * @param dst *u8 - destination buffer
 * @param cap i32 - capacity
 * @param at i32 - write offset
 * @param name *u8 - name bytes; null -> return at
 * @param name_len i32 - byte count; <=0 -> return at
 * @return i32 - new write offset
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipe_diag_msg_append_name(dst: *u8, cap: i32, at: i32, name: *u8, name_len: i32): i32 {
  if (dst == 0 as *u8) {
    return at;
  }
  if (name == 0 as *u8) {
    return at;
  }
  if (name_len <= 0) {
    return at;
  }
  let n: i32 = 0;
  unsafe {
    while (n < name_len) {
      if (at + 1 >= cap) {
        break;
      }
      dst[at] = name[n];
      at = at + 1;
      n = n + 1;
    }
    if (at < cap) {
      dst[at] = 0;
    }
  }
  return at;
}

/**
 * Pure body of XLANG_DEBUG_BODY_FUNC named-function body trace (wave82).
 * @param phase *u8 - phase tag for note text; null -> "?"
 * @param module *u8 - AST module; null -> no-op
 * @param arena *u8 - AST arena; null -> no-op
 * @return void
 * wave82 pure Cap residual orch:
 *   G.7 link_abi_getenv XLANG_DEBUG_BODY_FUNC gate (empty/'0' -> no-op; wave235);
 *   G.7 pipeline_module_num_funcs / func_name_* / body_ref_at (ast_pool Cap residual);
 *   G.7 pure pipeline_debug_body_func_match (comma token filter);
 *   G.7 ast_ast_block_num_* / final_expr_ref when body_ref > 0 else -1;
 *   G.7 pure pipe_diag_msg_append_* + diag_report fixed "note" msg (no va_list reportf;
 *   cold twin keeps historical reportf format string).
 * PLATFORM: SHARED - same filter/match semantics as seed cold twin.
 */
#[no_mangle]
export function pipeline_debug_trace_named_func_bodies_impl(phase: *u8, module: *u8, arena: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  if (arena == 0 as *u8) {
    return;
  }
  unsafe {
    let key: u8[24] = [];
    // "XLANG_DEBUG_BODY_FUNC"
    key[0] = 83; key[1] = 72; key[2] = 85; key[3] = 88; key[4] = 95;
    key[5] = 68; key[6] = 69; key[7] = 66; key[8] = 85; key[9] = 71;
    key[10] = 95; key[11] = 66; key[12] = 79; key[13] = 68; key[14] = 89;
    key[15] = 95; key[16] = 70; key[17] = 85; key[18] = 78; key[19] = 67;
    key[20] = 0;
    // wave235 G.7: XLANG_DEBUG_BODY_FUNC via link_abi_getenv (not raw getenv).
    let filter: *u8 = link_abi_getenv(&key[0]);
    if (filter == 0 as *u8) {
      return;
    }
    if (filter[0] == 0) {
      return;
    }
    // '0' disables (same as pure pipeline_debug_body_func_match / seed).
    if (filter[0] == 48) {
      return;
    }
    let nf: i32 = pipeline_module_num_funcs(module);
    let fi: i32 = 0;
    while (fi < nf) {
      let raw_name: u8[128] = [];
      let name: u8[65] = [];
      let ni: i32 = 0;
      while (ni < 64) {
        raw_name[ni] = 0;
        ni = ni + 1;
      }
      ni = 0;
      while (ni < 65) {
        name[ni] = 0;
        ni = ni + 1;
      }
      let name_len: i32 = pipeline_module_func_name_len_at(module, fi);
      if (name_len > 0) {
        if (name_len <= 64) {
          pipeline_module_func_name_copy64(module, fi, &raw_name[0]);
          let ci: i32 = 0;
          while (ci < name_len) {
            name[ci] = raw_name[ci];
            ci = ci + 1;
          }
          name[name_len] = 0;
          if (pipeline_debug_body_func_match(filter, &name[0]) != 0) {
            let body_ref: i32 = pipeline_module_func_body_ref_at(module, fi);
            let c_n: i32 = 0 - 1;
            let l_n: i32 = 0 - 1;
            let if_n: i32 = 0 - 1;
            let reg_n: i32 = 0 - 1;
            let so_n: i32 = 0 - 1;
            let fin_n: i32 = 0 - 1;
            if (body_ref > 0) {
              c_n = ast_ast_block_num_consts(arena, body_ref);
              l_n = ast_ast_block_num_lets(arena, body_ref);
              if_n = ast_ast_block_num_if_stmts(arena, body_ref);
              reg_n = ast_ast_block_num_regions(arena, body_ref);
              so_n = ast_ast_block_num_stmt_order(arena, body_ref);
              fin_n = ast_ast_block_final_expr_ref(arena, body_ref);
            }
            // Build: body trace: phase=... fi=... body_ref=... name=... block(c=... l=... if=... reg=... so=... fin=...)
            let msg: u8[320] = [];
            let at: i32 = 0;
            let cap: i32 = 320;
            let lit: u8[32] = [];
            // "body trace: phase="
            lit[0] = 98; lit[1] = 111; lit[2] = 100; lit[3] = 121; lit[4] = 32;
            lit[5] = 116; lit[6] = 114; lit[7] = 97; lit[8] = 99; lit[9] = 101;
            lit[10] = 58; lit[11] = 32; lit[12] = 112; lit[13] = 104; lit[14] = 97;
            lit[15] = 115; lit[16] = 101; lit[17] = 61; lit[18] = 0;
            at = pipe_diag_msg_append_cstr(&msg[0], cap, at, &lit[0]);
            if (phase != 0 as *u8) {
              if (phase[0] != 0) {
                at = pipe_diag_msg_append_cstr(&msg[0], cap, at, phase);
              } else {
                lit[0] = 63; lit[1] = 0; // "?"
                at = pipe_diag_msg_append_cstr(&msg[0], cap, at, &lit[0]);
              }
            } else {
              lit[0] = 63; lit[1] = 0;
              at = pipe_diag_msg_append_cstr(&msg[0], cap, at, &lit[0]);
            }
            // " fi="
            lit[0] = 32; lit[1] = 102; lit[2] = 105; lit[3] = 61; lit[4] = 0;
            at = pipe_diag_msg_append_cstr(&msg[0], cap, at, &lit[0]);
            at = pipe_diag_msg_append_i32(&msg[0], cap, at, fi);
            // " body_ref="
            lit[0] = 32; lit[1] = 98; lit[2] = 111; lit[3] = 100; lit[4] = 121;
            lit[5] = 95; lit[6] = 114; lit[7] = 101; lit[8] = 102; lit[9] = 61;
            lit[10] = 0;
            at = pipe_diag_msg_append_cstr(&msg[0], cap, at, &lit[0]);
            at = pipe_diag_msg_append_i32(&msg[0], cap, at, body_ref);
            // " name="
            lit[0] = 32; lit[1] = 110; lit[2] = 97; lit[3] = 109; lit[4] = 101;
            lit[5] = 61; lit[6] = 0;
            at = pipe_diag_msg_append_cstr(&msg[0], cap, at, &lit[0]);
            at = pipe_diag_msg_append_name(&msg[0], cap, at, &name[0], name_len);
            // " block(c="
            lit[0] = 32; lit[1] = 98; lit[2] = 108; lit[3] = 111; lit[4] = 99;
            lit[5] = 107; lit[6] = 40; lit[7] = 99; lit[8] = 61; lit[9] = 0;
            at = pipe_diag_msg_append_cstr(&msg[0], cap, at, &lit[0]);
            at = pipe_diag_msg_append_i32(&msg[0], cap, at, c_n);
            // " l="
            lit[0] = 32; lit[1] = 108; lit[2] = 61; lit[3] = 0;
            at = pipe_diag_msg_append_cstr(&msg[0], cap, at, &lit[0]);
            at = pipe_diag_msg_append_i32(&msg[0], cap, at, l_n);
            // " if="
            lit[0] = 32; lit[1] = 105; lit[2] = 102; lit[3] = 61; lit[4] = 0;
            at = pipe_diag_msg_append_cstr(&msg[0], cap, at, &lit[0]);
            at = pipe_diag_msg_append_i32(&msg[0], cap, at, if_n);
            // " reg="
            lit[0] = 32; lit[1] = 114; lit[2] = 101; lit[3] = 103; lit[4] = 61;
            lit[5] = 0;
            at = pipe_diag_msg_append_cstr(&msg[0], cap, at, &lit[0]);
            at = pipe_diag_msg_append_i32(&msg[0], cap, at, reg_n);
            // " so="
            lit[0] = 32; lit[1] = 115; lit[2] = 111; lit[3] = 61; lit[4] = 0;
            at = pipe_diag_msg_append_cstr(&msg[0], cap, at, &lit[0]);
            at = pipe_diag_msg_append_i32(&msg[0], cap, at, so_n);
            // " fin="
            lit[0] = 32; lit[1] = 102; lit[2] = 105; lit[3] = 110; lit[4] = 61;
            lit[5] = 0;
            at = pipe_diag_msg_append_cstr(&msg[0], cap, at, &lit[0]);
            at = pipe_diag_msg_append_i32(&msg[0], cap, at, fin_n);
            // ")"
            lit[0] = 41; lit[1] = 0;
            at = pipe_diag_msg_append_cstr(&msg[0], cap, at, &lit[0]);
            let note_k: u8[8] = [];
            note_k[0] = 110; note_k[1] = 111; note_k[2] = 116; note_k[3] = 101;
            note_k[4] = 0;
            diag_report(0 as *u8, 0, 0, &note_k[0], &msg[0], 0 as *u8);
          }
        }
      }
      fi = fi + 1;
    }
  }
}

/**
 * Public thin: null-gate then G.7 pure pipeline_debug_trace_named_func_bodies_impl.
 * @param phase *u8 - phase tag passed to impl; may be null
 * @param module *u8 - AST module; null -> no-op
 * @param arena *u8 - AST arena; null -> no-op
 * @return void
 * wave82: pure owns full body-trace orch (no always-seed _impl call).
 * PLATFORM: SHARED - same ABI as seed cold twin under #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_debug_trace_named_func_bodies(phase: *u8, module: *u8, arena: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  if (arena == 0 as *u8) {
    return;
  }
  unsafe {
    pipeline_debug_trace_named_func_bodies_impl(phase, module, arena);
  }
}

/* ---- G-02f-63 / G-02f-242 / wave63：typeck_for_ctx / lsp free_loaded ---- */

/**
 * Historical C typeck entry-only surface (no arena/ctx).
 * @param module *u8 - AST module; null -> -1
 * @return i32 - always -1 when module non-null (X frontend needs arena+ctx)
 * wave87: C typeck_module frontend deleted (weak -1 only). Callers with arena/ctx
 * must use pipeline_typeck_module_for_ctx -> typeck_x_ast. Keep symbol for cold/ABI.
 * PLATFORM: SHARED - same fail-closed semantics as deleted C frontend stub.
 */
#[no_mangle]
export function typeck_module_entry_only(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  // No arena/ctx: cannot invoke typeck_x_ast. Use pipeline_typeck_module_for_ctx.
  return 0 - 1;
}

/**
 * Historical C typeck sidecar surface (typeck_ndep BSS + typeck_module).
 * @param module *u8 - AST module; null -> -1
 * @return i32 - always -1 when module non-null (X frontend uses PipelineDepCtx, not BSS)
 * wave87: dep sidecar for deleted C typeck_module is obsolete; product deps live in ctx.
 * PLATFORM: SHARED - fail-closed; G.7 authority is typeck_x_ast via for_ctx.
 */
#[no_mangle]
export function typeck_module_with_sidecar(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  return 0 - 1;
}

/**
 * Product typeck-for-ctx: route to typeck_x_ast authority (entry vs library).
 * @param module *u8 - AST module; null -> -1
 * @param arena *u8 - AST arena (required by typeck_x_ast*)
 * @param ctx_void *u8 - PipelineDepCtx (required by typeck_x_ast*; holds import deps)
 * @return i32 - 0 success, -1 failure (maps any non-zero typeck_x_ast* code to -1)
 * wave87 pure Cap residual close: G.7 single authority typeck_x_ast / typeck_x_ast_library
 *   (typeck.x); chooses library when pipeline_module_main_func_index < 0
 *   (≡ pipeline_impl_typecheck / force_c branch). No C typeck_module.
 * PLATFORM: SHARED - force_c and default product path share X frontend.
 */
#[no_mangle]
export function pipeline_typeck_module_for_ctx_impl(module: *u8, arena: *u8, ctx_void: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  // Reject missing arena/ctx early (typeck_x_ast_library returns -5; keep for_ctx as 0/-1).
  if (arena == 0 as *u8 || ctx_void == 0 as *u8) {
    return 0 - 1;
  }
  let mi: i32 = 0;
  unsafe {
    mi = pipeline_module_main_func_index(module);
  }
  let rc: i32 = 0;
  unsafe {
    // Library modules (no main): typeck_x_ast_library; entry with main: typeck_x_ast.
    if (mi < 0) {
      rc = typeck_x_ast_library(module, arena, ctx_void);
    } else {
      rc = typeck_x_ast(module, arena, ctx_void);
    }
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Thin gate for pipeline typeck-for-ctx (null module -> -1).
 * @param module *u8 - AST module; null -> -1
 * @param arena *u8 - passed through to typeck_x_ast*
 * @param ctx *u8 - passed through to typeck_x_ast* (PipelineDepCtx)
 * @return i32 - 0 success, -1 failure
 * wave63/wave87: body in pure pipeline_typeck_module_for_ctx_impl after null gate.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_typeck_module_for_ctx(module: *u8, arena: *u8, ctx: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  return pipeline_typeck_module_for_ctx_impl(module, arena, ctx);
}

/**
 * Clear pointer table slot i to null (after free/ast_module_free of the old value).
 * @param arr *u8 - void-star / char-star table base; null -> no-op
 * @param i i32 - index; i < 0 -> no-op
 * @return void
 * wave78 pure: G.7 thin -> xlang_ptr_slot_set(arr, i, null); single authority for slot stores.
 * PLATFORM: SHARED - cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function xlang_lsp_ptr_slot_clear(arr: *u8, i: i32): void {
  if (arr == 0 as *u8) {
    return;
  }
  if (i < 0) {
    return;
  }
  unsafe {
    xlang_ptr_slot_set(arr, i, 0 as *u8);
  }
}

// xlang_lsp_free_loaded_imports: see function docblock below.
/**
 * Free dep modules/paths written by xlang_lsp_resolve_and_load_imports (not entry module).
 * @param all_dep_mods *u8 - void** module table base
 * @param all_dep_paths *u8 - char** path table base
 * @param n_all i32 - slot count; <=0 -> no-op
 * @return void
 * G.7 pure xlang_lsp_ptr_slot_clear (wave78) nulls slots after free.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_lsp_free_loaded_imports(all_dep_mods: *u8, all_dep_paths: *u8, n_all: i32): void {
  if (all_dep_mods == 0 as *u8) { return; }
  if (all_dep_paths == 0 as *u8) { return; }
  if (n_all <= 0) { return; }
  let i: i32 = 0;
  while (i < n_all) {
    unsafe {
      let p: *u8 = pipe_load_ptr_slot(all_dep_paths, i);
      if (p != 0 as *u8) {
        free(p);
        xlang_lsp_ptr_slot_clear(all_dep_paths, i);
      }
      let m: *u8 = pipe_load_ptr_slot(all_dep_mods, i);
      if (m != 0 as *u8) {
        ast_module_free(m);
        xlang_lsp_ptr_slot_clear(all_dep_mods, i);
      }
    }
    i = i + 1;
  }
}


/* See implementation. */


// See implementation.
// kind="preprocess error" / "pipeline error" / "import error"；code=PP001/PP002/XP005/IMP002/IMP004

/** Exported function `pipeline_diag_preprocess_unclosed_if`.
 * Implements `pipeline_diag_preprocess_unclosed_if`.
 * @param path_diag *u8
 * @return void
 */
#[no_mangle]
export function pipeline_diag_preprocess_unclosed_if(path_diag: *u8): void {
  pipeline_diag_emitted_note();
  let kind: u8[24] = [];
  let code: u8[8] = [];
  let msg: u8[16] = [];
  // "preprocess error"
  kind[0]=112;kind[1]=114;kind[2]=101;kind[3]=112;kind[4]=114;kind[5]=111;kind[6]=99;kind[7]=101;
  kind[8]=115;kind[9]=115;kind[10]=32;kind[11]=101;kind[12]=114;kind[13]=114;kind[14]=111;kind[15]=114;kind[16]=0;
  // "PP001"
  code[0]=80;code[1]=80;code[2]=48;code[3]=48;code[4]=49;code[5]=0;
  // "unclosed #if"
  msg[0]=117;msg[1]=110;msg[2]=99;msg[3]=108;msg[4]=111;msg[5]=115;msg[6]=101;msg[7]=100;
  msg[8]=32;msg[9]=35;msg[10]=105;msg[11]=102;msg[12]=0;
  unsafe {
    diag_report_with_code(path_diag, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
  }
}

/** Exported function `pipeline_diag_preprocess_fail`.
 * Implements `pipeline_diag_preprocess_fail`.
 * @param path_diag *u8
 * @return void
 */
#[no_mangle]
export function pipeline_diag_preprocess_fail(path_diag: *u8): void {
  pipeline_diag_emitted_note();
  let kind: u8[24] = [];
  let code: u8[8] = [];
  let msg: u8[40] = [];
  kind[0]=112;kind[1]=114;kind[2]=101;kind[3]=112;kind[4]=114;kind[5]=111;kind[6]=99;kind[7]=101;
  kind[8]=115;kind[9]=115;kind[10]=32;kind[11]=101;kind[12]=114;kind[13]=114;kind[14]=111;kind[15]=114;kind[16]=0;
  code[0]=80;code[1]=80;code[2]=48;code[3]=48;code[4]=50;code[5]=0; // PP002
  // ".x preprocess failed"
  msg[0]=46;msg[1]=120;msg[2]=32;msg[3]=112;msg[4]=114;msg[5]=101;msg[6]=112;msg[7]=114;
  msg[8]=111;msg[9]=99;msg[10]=101;msg[11]=115;msg[12]=115;msg[13]=32;msg[14]=102;msg[15]=97;
  msg[16]=105;msg[17]=108;msg[18]=101;msg[19]=100;msg[20]=0;
  unsafe {
    diag_report_with_code(path_diag, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
  }
}

/** Exported function `pipeline_diag_import_preprocess_fail`.
 * Implements `pipeline_diag_import_preprocess_fail`.
 * @param import_path *u8
 * @param resolved_path *u8
 * @return void
 */
#[no_mangle]
export function pipeline_diag_import_preprocess_fail(import_path: *u8, resolved_path: *u8): void {
  pipeline_diag_emitted_note();
  let kind: u8[24] = [];
  let code: u8[8] = [];
  let msg: u8[40] = [];
  kind[0]=112;kind[1]=114;kind[2]=101;kind[3]=112;kind[4]=114;kind[5]=111;kind[6]=99;kind[7]=101;
  kind[8]=115;kind[9]=115;kind[10]=32;kind[11]=101;kind[12]=114;kind[13]=114;kind[14]=111;kind[15]=114;kind[16]=0;
  code[0]=73;code[1]=77;code[2]=80;code[3]=48;code[4]=48;code[5]=50;code[6]=0; // IMP002
  // "import preprocess failed"
  msg[0]=105;msg[1]=109;msg[2]=112;msg[3]=111;msg[4]=114;msg[5]=116;msg[6]=32;msg[7]=112;
  msg[8]=114;msg[9]=101;msg[10]=112;msg[11]=114;msg[12]=111;msg[13]=99;msg[14]=101;msg[15]=115;
  msg[16]=115;msg[17]=32;msg[18]=102;msg[19]=97;msg[20]=105;msg[21]=108;msg[22]=101;msg[23]=100;msg[24]=0;
  let file: *u8 = resolved_path;
  if (file == 0 as *u8) { file = import_path; }
  unsafe {
    diag_report_with_code(file, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
  }
}

/** Exported function `pipeline_diag_preprocess_alloc_fail`.
 * Memory management helper `pipeline_diag_preprocess_alloc_fail`.
 * @param path_diag *u8
 * @param what *u8
 * @return void
 */
#[no_mangle]
export function pipeline_diag_preprocess_alloc_fail(path_diag: *u8, what: *u8): void {
  pipeline_diag_emitted_note();
  let kind: u8[24] = [];
  let code: u8[8] = [];
  let msg: u8[48] = [];
  // "pipeline error"
  kind[0]=112;kind[1]=105;kind[2]=112;kind[3]=101;kind[4]=108;kind[5]=105;kind[6]=110;kind[7]=101;
  kind[8]=32;kind[9]=101;kind[10]=114;kind[11]=114;kind[12]=111;kind[13]=114;kind[14]=0;
  code[0]=88;code[1]=80;code[2]=48;code[3]=48;code[4]=53;code[5]=0; // XP005
  // "allocation failed during preprocess"
  msg[0]=97;msg[1]=108;msg[2]=108;msg[3]=111;msg[4]=99;msg[5]=97;msg[6]=116;msg[7]=105;
  msg[8]=111;msg[9]=110;msg[10]=32;msg[11]=102;msg[12]=97;msg[13]=105;msg[14]=108;msg[15]=101;
  msg[16]=100;msg[17]=32;msg[18]=100;msg[19]=117;msg[20]=114;msg[21]=105;msg[22]=110;msg[23]=103;
  msg[24]=32;msg[25]=112;msg[26]=114;msg[27]=101;msg[28]=112;msg[29]=114;msg[30]=111;msg[31]=99;
  msg[32]=101;msg[33]=115;msg[34]=115;msg[35]=0;
  let _w: *u8 = what;
  unsafe {
    diag_report_with_code(path_diag, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
  }
}

/** Exported function `pipeline_diag_merge_dep_missing`.
 * Implements `pipeline_diag_merge_dep_missing`.
 * @param import_path *u8
 * @return void
 */
#[no_mangle]
export function pipeline_diag_merge_dep_missing(import_path: *u8): void {
  pipeline_diag_emitted_note();
  let kind: u8[16] = [];
  let code: u8[8] = [];
  let msg: u8[48] = [];
  let note_k: u8[8] = [];
  let note_m: u8[128] = [];
  // "import error"
  kind[0]=105;kind[1]=109;kind[2]=112;kind[3]=111;kind[4]=114;kind[5]=116;kind[6]=32;kind[7]=101;
  kind[8]=114;kind[9]=114;kind[10]=111;kind[11]=114;kind[12]=0;
  code[0]=73;code[1]=77;code[2]=80;code[3]=48;code[4]=48;code[5]=52;code[6]=0; // IMP004
  // "direct import missing from dependency closure"
  msg[0]=100;msg[1]=105;msg[2]=114;msg[3]=101;msg[4]=99;msg[5]=116;msg[6]=32;msg[7]=105;
  msg[8]=109;msg[9]=112;msg[10]=111;msg[11]=114;msg[12]=116;msg[13]=32;msg[14]=109;msg[15]=105;
  msg[16]=115;msg[17]=115;msg[18]=105;msg[19]=110;msg[20]=103;msg[21]=32;msg[22]=102;msg[23]=114;
  msg[24]=111;msg[25]=109;msg[26]=32;msg[27]=100;msg[28]=101;msg[29]=112;msg[30]=32;msg[31]=99;
  msg[32]=108;msg[33]=111;msg[34]=115;msg[35]=117;msg[36]=114;msg[37]=101;msg[38]=0;
  note_k[0]=110;note_k[1]=111;note_k[2]=116;note_k[3]=101;note_k[4]=0;
  // "dependency closure construction failed before merge_deps completed"
  note_m[0]=100;note_m[1]=101;note_m[2]=112;note_m[3]=101;note_m[4]=110;note_m[5]=100;note_m[6]=101;note_m[7]=110;
  note_m[8]=99;note_m[9]=121;note_m[10]=32;note_m[11]=99;note_m[12]=108;note_m[13]=111;note_m[14]=115;note_m[15]=117;
  note_m[16]=114;note_m[17]=101;note_m[18]=32;note_m[19]=99;note_m[20]=111;note_m[21]=110;note_m[22]=115;note_m[23]=116;
  note_m[24]=114;note_m[25]=117;note_m[26]=99;note_m[27]=116;note_m[28]=105;note_m[29]=111;note_m[30]=110;note_m[31]=32;
  note_m[32]=102;note_m[33]=97;note_m[34]=105;note_m[35]=108;note_m[36]=101;note_m[37]=100;note_m[38]=0;
  unsafe {
    diag_report_with_code(import_path, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
    diag_report(0 as *u8, 0, 0, &note_k[0], &note_m[0], 0 as *u8);
  }
}

// typeck_ndep_store: see function docblock below.
/** Exported function `typeck_ndep_store`.
 * Implements `typeck_ndep_store`.
 * @param n i32
 * @return void
 */
#[no_mangle]
export function typeck_ndep_store(n: i32): void {
  let v: i32 = n;
  if (v > 32) { v = 32; }
  if (v < 0) { v = 0; }
  unsafe {
    typeck_ndep_store_impl(v);
  }
}

// typeck_dep_module_set: see function docblock below.
/** Exported function `typeck_dep_module_set`.
 * Implements `typeck_dep_module_set`.
 * @param i i32
 * @param mod *u8
 * @return void
 */
#[no_mangle]
export function typeck_dep_module_set(i: i32, mod: *u8): void {
  if (i < 0) { return; }
  if (i >= 32) { return; }
  unsafe {
    typeck_dep_module_set_impl(i, mod);
  }
}

// typeck_dep_arena_set: see function docblock below.
/** Exported function `typeck_dep_arena_set`.
 * Implements `typeck_dep_arena_set`.
 * @param i i32
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function typeck_dep_arena_set(i: i32, arena: *u8): void {
  if (i < 0) { return; }
  if (i >= 32) { return; }
  unsafe {
    typeck_dep_arena_set_impl(i, arena);
  }
}

// driver_dep_arena_ptr_set: see function docblock below.
/** Exported function `driver_dep_arena_ptr_set`.
 * Implements `driver_dep_arena_ptr_set`.
 * @param i i32
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function driver_dep_arena_ptr_set(i: i32, arena: *u8): void {
  if (i < 0) { return; }
  if (i >= 32) { return; }
  unsafe {
    driver_dep_arena_ptr_set_impl(i, arena);
  }
}

/** Exported function `driver_dep_module_ptr_set`.
 * Implements `driver_dep_module_ptr_set`.
 * @param i i32
 * @param module *u8
 * @return void
 */
#[no_mangle]
export function driver_dep_module_ptr_set(i: i32, module: *u8): void {
  if (i < 0) { return; }
  if (i >= 32) { return; }
  unsafe {
    driver_dep_module_ptr_set_impl(i, module);
  }
}


/* ---- G-02f-85 / G-02f-134：import path scan ---- */

export function pipe_cstr_eq(a: *u8, b: *u8): i32 {
  if (a == 0) { return 0; }
  if (b == 0) { return 0; }
  let i: i32 = 0;
  while (i < 4096) {
    if (a[i] != b[i]) { return 0; }
    if (a[i] == 0) { return 1; }
    i = i + 1;
  }
  return 0;
}

// pipe_load_ptr_slot: see function docblock below.
/** Exported function `pipe_load_ptr_slot`.
 * Implements `pipe_load_ptr_slot`.
 * @param base *u8
 * @param i i32
 * @return *u8
 */
export function pipe_load_ptr_slot(base: *u8, i: i32): *u8 {
  if (base == 0) { return 0 as *u8; }
  let off: i32 = i * 8;
  let m: usize = 256;
  let m2: usize = m * m;
  let m4: usize = m2 * m2;
  let a: usize = base[off] as usize;
  a = a + (base[off + 1] as usize) * m;
  a = a + (base[off + 2] as usize) * m2;
  a = a + (base[off + 3] as usize) * (m2 * m);
  a = a + (base[off + 4] as usize) * m4;
  a = a + (base[off + 5] as usize) * (m4 * m);
  a = a + (base[off + 6] as usize) * (m4 * m2);
  a = a + (base[off + 7] as usize) * (m4 * m2 * m);
  return a as *u8;
}

/**
 * Store little-endian pointer into base[i] (LP64 8-byte cell).
 * Module-local pair of pipe_load_ptr_slot (no second G.7 path).
 * @param base *u8 - table base; null -> no-op
 * @param i i32 - slot index; i < 0 -> no-op
 * @param val *u8 - pointer bits to store (may be null)
 * @return void
 * PLATFORM: SHARED LP64 little-endian.
 */
function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void {
  if (base == 0 as *u8) {
    return;
  }
  if (i < 0) {
    return;
  }
  let off: i32 = i * 8;
  unsafe {
    let m: usize = 256 as usize;
    let b255: usize = 255 as usize;
    let u0: usize = val as usize;
    base[off] = (u0 & b255) as u8;
    let u1: usize = u0 / m;
    base[off + 1] = (u1 & b255) as u8;
    let u2: usize = u1 / m;
    base[off + 2] = (u2 & b255) as u8;
    let u3: usize = u2 / m;
    base[off + 3] = (u3 & b255) as u8;
    let u4: usize = u3 / m;
    base[off + 4] = (u4 & b255) as u8;
    let u5: usize = u4 / m;
    base[off + 5] = (u5 & b255) as u8;
    let u6: usize = u5 / m;
    base[off + 6] = (u6 & b255) as u8;
    let u7: usize = u6 / m;
    base[off + 7] = (u7 & b255) as u8;
  }
}

/**
 * Load size_t / i64 slot i from an array of LP64 8-byte cells (LE).
 * @param arr *u8 - size_t* base as bytes; null -> 0
 * @param i i32 - index; i < 0 -> 0
 * @return i64 - cell value as signed i64 (path lengths fit)
 * wave46 pure Cap residual; cold twin under #ifndef FROM_X.
 * PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function xlang_size_slot_get(arr: *u8, i: i32): i64 {
  if (arr == 0 as *u8) {
    return 0;
  }
  if (i < 0) {
    return 0;
  }
  // Same LE reconstruct as pipe_load_ptr_slot; cast pointer bits -> i64 length.
  let p: *u8 = pipe_load_ptr_slot(arr, i);
  return p as i64;
}

/**
 * Store size_t / i64 into arr[i] (LP64 8-byte LE cell).
 * @param arr *u8 - size_t* base as bytes; null -> no-op
 * @param i i32 - index; i < 0 -> no-op
 * @param v i64 - value (path length / buffer size)
 * @return void
 * wave46 pure; pairs xlang_size_slot_get. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function xlang_size_slot_set(arr: *u8, i: i32, v: i64): void {
  if (arr == 0 as *u8) {
    return;
  }
  if (i < 0) {
    return;
  }
  pipe_store_ptr_slot(arr, i, v as *u8);
}

/**
 * Write pointer p into char-star / void-star array slot i (G.7 product authority).
 * @param arr *u8 - void** / char** table base as bytes; null -> no-op
 * @param i i32 - slot index; i < 0 -> no-op
 * @param p *u8 - pointer to store (may be null)
 * @return void
 * wave46 pure; driver_abi / fmt_check call this as Cap residual surface.
 * PLATFORM: SHARED LP64 - single authority in this TU under PREFER hybrid.
 */
#[no_mangle]
export function xlang_ptr_slot_set(arr: *u8, i: i32, p: *u8): void {
  pipe_store_ptr_slot(arr, i, p);
}

/**
 * Load pointer slot i from a char-star / void-star array base (G.7 pair with set).
 * @param arr *u8 - table base; null -> null
 * @param i i32 - index; i < 0 -> null
 * @return *u8 - pointer at slot (may be null)
 * wave46 pure. PLATFORM: SHARED LP64.
 * Note: never put the two-char end-comment marker inside prose (truncates the block).
 */
#[no_mangle]
export function xlang_ptr_slot_get(arr: *u8, i: i32): *u8 {
  if (arr == 0 as *u8) {
    return 0 as *u8;
  }
  if (i < 0) {
    return 0 as *u8;
  }
  return pipe_load_ptr_slot(arr, i);
}

/**
 * Store i32 v through pointer p (null-safe).
 * @param p *i32 - destination; null -> no-op
 * @param v i32 - value
 * @return void
 * wave46 pure Cap residual (merge out_n / n_deps). PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_i32_store(p: *i32, v: i32): void {
  if (p == 0 as *i32) {
    return;
  }
  unsafe {
    p[0] = v;
  }
}

/**
 * Return module import count (null module -> 0).
 * @param module *u8 - opaque AST module; null -> 0
 * @return i32 - import count from parser authority
 * wave46 pure thin over parser_get_module_num_imports (strong from parser_x at final link).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_module_num_imports(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  return parser_get_module_num_imports(module);
}

/**
 * Copy import path at idx into buf as a C string (NUL-terminated).
 * @param module *u8 - opaque AST module; null -> buf[0]=0 when buf valid
 * @param idx i32 - import index
 * @param buf *u8 - destination; null or cap<=0 -> no-op
 * @param cap i32 - capacity including NUL; copies min(path, cap-1)
 * @return void
 * wave46 pure: parser path bytes then copy loop (no libc). PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_module_import_path_cstr(module: *u8, idx: i32, buf: *u8, cap: i32): void {
  if (buf == 0 as *u8) {
    return;
  }
  if (cap <= 0) {
    return;
  }
  unsafe {
    buf[0] = 0;
  }
  if (module == 0 as *u8) {
    return;
  }
  let path_buf: u8[128] = [];
  unsafe {
    parser_get_module_import_path(module, idx, &path_buf[0]);
  }
  let k: i32 = 0;
  while (k < 64) {
    let ch: u8 = 0;
    unsafe {
      ch = path_buf[k];
    }
    if (ch == 0) {
      break;
    }
    if (k + 1 >= cap) {
      break;
    }
    unsafe {
      buf[k] = ch;
    }
    k = k + 1;
  }
  unsafe {
    buf[k] = 0;
  }
}

/**
 * True if to_load[0..to_load_n) already contains path (C-string eq).
 * @param to_load *u8 - char** queue base as bytes; null -> 0
 * @param to_load_n i32 - live count
 * @param path *u8 - candidate C string; null -> 0
 * @return i32 - 1 if found, 0 otherwise
 * wave46 pure; used by Cap residual collect enqueue. PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_collect_to_load_has(to_load: *u8, to_load_n: i32, path: *u8): i32 {
  if (to_load == 0 as *u8) {
    return 0;
  }
  if (path == 0 as *u8) {
    return 0;
  }
  if (to_load_n <= 0) {
    return 0;
  }
  let t: i32 = 0;
  while (t < to_load_n) {
    let p: *u8 = pipe_load_ptr_slot(to_load, t);
    if (p != 0 as *u8) {
      if (pipe_cstr_eq(p, path) != 0) {
        return 1;
      }
    }
    t = t + 1;
  }
  return 0;
}

/**
 * Owned C-string copy for collect queue / dep_paths keys (malloc + byte copy + trailing NUL).
 * @param s *u8 - source NUL-terminated C string; null -> null
 * @return *u8 - newly owned copy (release with free()); null if s is null or OOM
 * wave54 pure Cap residual thin shell:
 *   null s -> null; scan length until NUL; malloc(n+1); copy n bytes + trailing NUL.
 * Do not name this libc strdup - string.h after -E preamble would conflict on the short name.
 * G.7 seed_to_load / enqueue / load_one / paths_process_one call this. PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_collect_strdup(s: *u8): *u8 {
  if (s == 0 as *u8) {
    return 0 as *u8;
  }
  // Count bytes before trailing NUL (same unbounded scan as libc strdup).
  let n: i32 = 0;
  unsafe {
    while (s[n] != 0) {
      n = n + 1;
    }
  }
  let out: *u8 = 0 as *u8;
  unsafe {
    out = malloc((n + 1) as usize);
  }
  if (out == 0 as *u8) {
    return 0 as *u8;
  }
  let i: i32 = 0;
  unsafe {
    while (i < n) {
      out[i] = s[i];
      i = i + 1;
    }
    out[n] = 0;
  }
  return out;
}

/**
 * Seed the collect to_load queue from module direct imports (owned strdup keys).
 * @param module *u8 - opaque AST module; null -> empty queue + 0
 * @param to_load *u8 - char** queue base as bytes; null -> fail 1
 * @param to_load_n *i32 - out live count; null -> fail 1; reset to 0 first
 * @return i32 - 0 success; 1 OOM (queue freed and count cleared)
 * wave47 pure Cap residual: G.7 reuses xlang_module_num_imports / import_path_cstr /
 *   pipe_store_ptr_slot; wave54 pure xlang_collect_strdup for ownership (free on fail).
 * Slot max = XLANG_DRIVER_DEP_SLOT_MAX (32). PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_collect_seed_to_load(module: *u8, to_load: *u8, to_load_n: *i32): i32 {
  if (to_load == 0 as *u8) {
    return 1;
  }
  if (to_load_n == 0 as *i32) {
    return 1;
  }
  unsafe {
    to_load_n[0] = 0;
  }
  if (module == 0 as *u8) {
    return 0;
  }
  let slot_max: i32 = 32;
  let n_imports: i32 = xlang_module_num_imports(module);
  let j: i32 = 0;
  while (j < n_imports) {
    if (j >= slot_max) {
      break;
    }
    let n: i32 = 0;
    unsafe {
      n = to_load_n[0];
    }
    if (n >= slot_max) {
      break;
    }
    let path_c: u8[65] = [];
    xlang_module_import_path_cstr(module, j, &path_c[0], 65);
    let owned: *u8 = 0 as *u8;
    unsafe {
      owned = xlang_collect_strdup(&path_c[0]);
    }
    if (owned == 0 as *u8) {
      // Free partial queue on OOM (same contract as seed cold twin).
      while (n > 0) {
        n = n - 1;
        let p: *u8 = pipe_load_ptr_slot(to_load, n);
        if (p != 0 as *u8) {
          unsafe {
            free(p);
          }
        }
        pipe_store_ptr_slot(to_load, n, 0 as *u8);
      }
      unsafe {
        to_load_n[0] = 0;
      }
      return 1;
    }
    pipe_store_ptr_slot(to_load, n, owned);
    unsafe {
      to_load_n[0] = n + 1;
    }
    j = j + 1;
  }
  return 0;
}

/**
 * Ensure tmp arena/module, parse prep bytes into them, enqueue sub-imports onto to_load.
 * @param tmp_arena *u8 - void star-star slot for reusable tmp arena; null -> no-op
 * @param tmp_module *u8 - void star-star slot for reusable tmp module; null -> no-op
 * @param arena_sz i64 - malloc size when *tmp_arena is null; must match ParseInto arena layout
 * @param module_sz i64 - malloc size when first ensuring tmp; must match ParseInto module layout
 * @param prep *u8 - owned prep source bytes (not freed here); null -> no-op
 * @param prep_len i64 - byte length of prep
 * @param debug_path *u8 - path key for optional XLANG_DEBUG_PIPE note (cold twin only; pure ignores)
 * @param to_load *u8 - char star-star queue base for sub-import keys
 * @param to_load_n *i32 - live queue count (in/out)
 * @param dep_paths *u8 - already-loaded keys as char star-star; may be null if n_loaded==0
 * @param n_loaded i32 - count of committed dep_paths
 * @return void
 * wave52 pure Cap residual orch:
 *   if *tmp_arena null -> malloc arena_sz + module_sz into both slots;
 *   if both live -> memset zero, pipeline_parse_into_bytes, G.7 pure enqueue_module_imports.
 *   OOM on malloc: leave null slots and return (same as cold twin skip parse).
 * G.7 process_one / paths_tmp Cap residual call this. PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_collect_tmp_parse_and_enqueue(tmp_arena: *u8, tmp_module: *u8, arena_sz: i64, module_sz: i64, prep: *u8, prep_len: i64, debug_path: *u8, to_load: *u8, to_load_n: *i32, dep_paths: *u8, n_loaded: i32): void {
  if (tmp_arena == 0 as *u8) {
    return;
  }
  if (tmp_module == 0 as *u8) {
    return;
  }
  if (prep == 0 as *u8) {
    return;
  }
  // Silence unused debug_path in pure (cold twin may log under XLANG_DEBUG_PIPE).
  if (debug_path == 0 as *u8) {
  }
  let ta: *u8 = pipe_load_ptr_slot(tmp_arena, 0);
  let tm: *u8 = pipe_load_ptr_slot(tmp_module, 0);
  // First use: allocate both buffers (same order as cold twin).
  if (ta == 0 as *u8) {
    unsafe {
      ta = malloc(arena_sz as usize);
      tm = malloc(module_sz as usize);
    }
    pipe_store_ptr_slot(tmp_arena, 0, ta);
    pipe_store_ptr_slot(tmp_module, 0, tm);
  }
  // Historical: if either buffer missing, skip parse (path already registered upstream).
  if (ta == 0 as *u8) {
    return;
  }
  if (tm == 0 as *u8) {
    return;
  }
  unsafe {
    memset(ta, 0, arena_sz as usize);
    memset(tm, 0, module_sz as usize);
  }
  // ParseIntoResult lives in seed; pure only sees rc (unused beyond call).
  let pr_rc: i32 = 0;
  unsafe {
    pr_rc = pipeline_parse_into_bytes(ta, tm, prep, prep_len);
  }
  if (pr_rc != 0) {
    // Still enqueue whatever imports the partial/failed parse left (same as cold twin).
  }
  xlang_collect_enqueue_module_imports(tm, to_load, to_load_n, dep_paths, n_loaded);
}

/**
 * Paths-only shell: ensure tmp, resolve+read+preprocess path_c, parse+enqueue, free prep.
 * Called after paths_process_one has registered the owned dep_paths key.
 * @param path_c *u8 - import key C string (not owned; not freed here); null -> fail 1
 * @param lib_roots *u8 - char star-star lib roots; may be null if n_lib_roots==0
 * @param n_lib_roots i32 - lib root count
 * @param entry_dir *u8 - entry directory C string; may be null
 * @param defines *u8 - char star-star define names; may be null if ndefines==0
 * @param ndefines i32 - define count
 * @param tmp_arena *u8 - void star-star tmp arena slot; null -> fail 1
 * @param tmp_module *u8 - void star-star tmp module slot; null -> fail 1
 * @param arena_sz i64 - malloc size when first ensuring tmp arena
 * @param module_sz i64 - malloc size when first ensuring tmp module
 * @param to_load *u8 - char star-star queue base for sub-import keys
 * @param to_load_n *i32 - live queue count (in/out)
 * @param dep_paths *u8 - already-loaded keys as char star-star
 * @param n_loaded i32 - count of committed dep_paths
 * @return i32 - 0 continue (incl. tmp OOM skip parse); 1 resolve/preprocess fail
 * wave53 pure Cap residual orch:
 *   if *tmp_arena null -> malloc arena_sz + module_sz into both slots;
 *   if either buffer missing -> return 0 (path already registered upstream; historical);
 *   wave55 pure xlang_load_one_direct_resolve_read_preprocess -> owned prep;
 *   G.7 pure xlang_collect_tmp_parse_and_enqueue; free prep.
 * G.7 paths_process_one calls this. PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_collect_paths_tmp_resolve_parse_enqueue(path_c: *u8, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, tmp_arena: *u8, tmp_module: *u8, arena_sz: i64, module_sz: i64, to_load: *u8, to_load_n: *i32, dep_paths: *u8, n_loaded: i32): i32 {
  if (path_c == 0 as *u8) {
    return 1;
  }
  if (tmp_arena == 0 as *u8) {
    return 1;
  }
  if (tmp_module == 0 as *u8) {
    return 1;
  }
  // Historical early ensure (before resolve): if *tmp_arena null, allocate both.
  let ta: *u8 = pipe_load_ptr_slot(tmp_arena, 0);
  if (ta == 0 as *u8) {
    let tm_new: *u8 = 0 as *u8;
    unsafe {
      ta = malloc(arena_sz as usize);
      tm_new = malloc(module_sz as usize);
    }
    pipe_store_ptr_slot(tmp_arena, 0, ta);
    pipe_store_ptr_slot(tmp_module, 0, tm_new);
  }
  ta = pipe_load_ptr_slot(tmp_arena, 0);
  let tm: *u8 = pipe_load_ptr_slot(tmp_module, 0);
  // Historical: if tmp unavailable, path stays registered and we skip parse (return 0).
  if (ta == 0 as *u8) {
    return 0;
  }
  if (tm == 0 as *u8) {
    return 0;
  }
  // wave55 pure: stack PATH + FILE view + preprocess -> owned prep (not stored in dep slots).
  let prep_cell: u8[8] = [];
  let prep_len_cell: u8[8] = [];
  let rc: i32 = 0;
  unsafe {
    rc = xlang_load_one_direct_resolve_read_preprocess(lib_roots, n_lib_roots, entry_dir, path_c, defines, ndefines, &prep_cell[0], &prep_len_cell[0]);
  }
  if (rc != 0) {
    return 1;
  }
  let prep: *u8 = pipe_load_ptr_slot(&prep_cell[0], 0);
  let prep_len: i64 = xlang_size_slot_get(&prep_len_cell[0], 0);
  // G.7 pure: memset + parse_into_bytes + enqueue (tmp already live from ensure above).
  unsafe {
    xlang_collect_tmp_parse_and_enqueue(tmp_arena, tmp_module, arena_sz, module_sz, prep, prep_len, path_c, to_load, to_load_n, dep_paths, n_loaded);
  }
  // prep is owned only by this shell (paths-only does not keep sources); always free.
  if (prep != 0 as *u8) {
    unsafe {
      free(prep);
    }
  }
  return 0;
}

/**
 * Process one owned to_load path into dep_sources/lens/paths and enqueue its sub-imports.
 * @param path_c *u8 - owned C-string import key; consumed (freed) on all return paths
 * @param lib_roots *u8 - char star-star lib roots for resolve; may be null if n_lib_roots==0
 * @param n_lib_roots i32 - lib root count
 * @param entry_dir *u8 - entry directory C string; may be null
 * @param defines *u8 - char star-star define names; may be null if ndefines==0
 * @param ndefines i32 - define count
 * @param dep_sources *u8 - char star-star prep sources; written at slot *n
 * @param dep_lens *u8 - size_t array base as bytes; written at slot *n
 * @param dep_paths *u8 - char star-star owned keys; written at slot *n
 * @param n *i32 - live loaded count (in/out); null -> fail 1
 * @param to_load *u8 - char star-star queue base; null -> fail 1
 * @param to_load_n *i32 - live queue count (in/out for enqueue); null -> fail 1
 * @param tmp_arena *u8 - void star-star tmp arena slot; null -> fail 1
 * @param tmp_module *u8 - void star-star tmp module slot; null -> fail 1
 * @param arena_sz i64 - malloc size for tmp arena when first needed
 * @param module_sz i64 - malloc size for tmp module when first needed
 * @return i32 - 0 continue; 1 fail (caller cleans queue + partial deps)
 * wave48 pure Cap residual orch:
 *   already-loaded -> free path_c + 0;
 *   G.7 load_one_direct_import_at stores prep/path at mi=*n (resolve/read/preprocess Cap);
 *   free path_c; *n = mi+1;
 *   wave52 pure xlang_collect_tmp_parse_and_enqueue for parse + enqueue.
 * wave50: called from pure transitive_impl orch. PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_collect_deps_process_one(path_c: *u8, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, n: *i32, to_load: *u8, to_load_n: *i32, tmp_arena: *u8, tmp_module: *u8, arena_sz: i64, module_sz: i64): i32 {
  if (path_c == 0 as *u8) {
    return 1;
  }
  if (n == 0 as *i32) {
    return 1;
  }
  if (to_load == 0 as *u8) {
    return 1;
  }
  if (to_load_n == 0 as *i32) {
    return 1;
  }
  if (tmp_arena == 0 as *u8) {
    return 1;
  }
  if (tmp_module == 0 as *u8) {
    return 1;
  }
  let mi: i32 = 0;
  unsafe {
    mi = n[0];
  }
  // Already loaded: drop owned path and continue (same as cold twin).
  if (xlang_find_loaded_import_index(path_c, dep_paths, mi) >= 0) {
    unsafe {
      free(path_c);
    }
    return 0;
  }
  // Cap residual: resolve + read file view + preprocess -> dep_sources/lens/paths[mi].
  let rc: i32 = 0;
  unsafe {
    rc = xlang_load_one_direct_import_at(lib_roots, n_lib_roots, entry_dir, path_c, defines, ndefines, dep_sources, dep_lens, dep_paths, mi);
  }
  unsafe {
    free(path_c);
  }
  if (rc != 0) {
    return 1;
  }
  let key: *u8 = pipe_load_ptr_slot(dep_paths, mi);
  if (key == 0 as *u8) {
    return 1;
  }
  unsafe {
    n[0] = mi + 1;
  }
  let prep: *u8 = pipe_load_ptr_slot(dep_sources, mi);
  let prep_len: i64 = xlang_size_slot_get(dep_lens, mi);
  let n_loaded: i32 = mi + 1;
  unsafe {
    xlang_collect_tmp_parse_and_enqueue(tmp_arena, tmp_module, arena_sz, module_sz, prep, prep_len, key, to_load, to_load_n, dep_paths, n_loaded);
  }
  return 0;
}

/**
 * Paths-only process one owned to_load path into dep_paths and enqueue sub-imports.
 * Unlike deps_process_one, does not keep prep sources/lens - only owned path keys.
 * @param path_c *u8 - owned C-string import key; consumed (freed) on all return paths
 * @param lib_roots *u8 - char star-star lib roots for resolve; may be null if n_lib_roots==0
 * @param n_lib_roots i32 - lib root count
 * @param entry_dir *u8 - entry directory C string; may be null
 * @param defines *u8 - char star-star define names; may be null if ndefines==0
 * @param ndefines i32 - define count
 * @param dep_paths *u8 - char star-star owned keys; written at slot *n
 * @param n *i32 - live loaded count (in/out); null -> fail 1
 * @param to_load *u8 - char star-star queue base; null -> fail 1
 * @param to_load_n *i32 - live queue count (in/out for enqueue); null -> fail 1
 * @param tmp_arena *u8 - void star-star tmp arena slot; null -> fail 1
 * @param tmp_module *u8 - void star-star tmp module slot; null -> fail 1
 * @param arena_sz i64 - malloc size for tmp arena when first needed
 * @param module_sz i64 - malloc size for tmp module when first needed
 * @return i32 - 0 continue; 1 fail (caller cleans queue + partial paths)
 * wave49 pure Cap residual orch:
 *   already-loaded -> free path_c + 0;
 *   wave54 pure xlang_collect_strdup stores owned key at mi=*n; *n = mi+1;
 *   wave53 pure xlang_collect_paths_tmp_resolve_parse_enqueue
 *     (ensure tmp; Cap residual resolve/read/preprocess; G.7 pure tmp_parse; free prep);
 *   free path_c. If tmp malloc fails residual no-ops success (path still registered).
 * wave50: called from pure paths transitive_impl orch. PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_collect_paths_process_one(path_c: *u8, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_paths: *u8, n: *i32, to_load: *u8, to_load_n: *i32, tmp_arena: *u8, tmp_module: *u8, arena_sz: i64, module_sz: i64): i32 {
  if (path_c == 0 as *u8) {
    return 1;
  }
  if (n == 0 as *i32) {
    return 1;
  }
  if (to_load == 0 as *u8) {
    return 1;
  }
  if (to_load_n == 0 as *i32) {
    return 1;
  }
  if (tmp_arena == 0 as *u8) {
    return 1;
  }
  if (tmp_module == 0 as *u8) {
    return 1;
  }
  let mi: i32 = 0;
  unsafe {
    mi = n[0];
  }
  // Already loaded: drop owned path and continue (same as cold twin).
  if (xlang_find_loaded_import_index(path_c, dep_paths, mi) >= 0) {
    unsafe {
      free(path_c);
    }
    return 0;
  }
  // Register owned path key before resolve (fail paths leave key for caller cleanup).
  let key: *u8 = 0 as *u8;
  unsafe {
    key = xlang_collect_strdup(path_c);
  }
  if (key == 0 as *u8) {
    unsafe {
      free(path_c);
    }
    return 1;
  }
  pipe_store_ptr_slot(dep_paths, mi, key);
  unsafe {
    n[0] = mi + 1;
  }
  let n_loaded: i32 = mi + 1;
  let rc: i32 = 0;
  unsafe {
    rc = xlang_collect_paths_tmp_resolve_parse_enqueue(path_c, lib_roots, n_lib_roots, entry_dir, defines, ndefines, tmp_arena, tmp_module, arena_sz, module_sz, to_load, to_load_n, dep_paths, n_loaded);
  }
  unsafe {
    free(path_c);
  }
  return rc;
}

/**
 * Transitive collect of dep sources/lens/paths: seed queue, drain via process_one, free leftovers.
 * @param module *u8 - entry AST module; may be null (seed_to_load then empty)
 * @param arena_sz i64 - tmp arena malloc size for first process_one that needs parse
 * @param module_sz i64 - tmp module malloc size for first process_one that needs parse
 * @param lib_roots *u8 - char star-star lib roots; may be null if n_lib_roots==0
 * @param n_lib_roots i32 - lib root count
 * @param entry_dir *u8 - entry directory C string; may be null
 * @param defines *u8 - char star-star define names; may be null if ndefines==0
 * @param ndefines i32 - define count
 * @param dep_sources *u8 - char star-star prep sources out slots
 * @param dep_lens *u8 - size_t array base as bytes for prep lengths
 * @param dep_paths *u8 - char star-star owned path keys out slots
 * @param n_deps *i32 - out live count; null -> fail 1
 * @return i32 - 0 success; 1 fail (partial deps freed; queue/tmp freed)
 * wave50 pure Cap residual orch:
 *   stack char star-star to_load[32] as 256B + two void-star tmp cells as 16B
 *   (G.7 same stack-ptr pattern as check_one_file argv);
 *   G.7 xlang_collect_seed_to_load then drain with pure process_one;
 *   success: free remaining queue + tmp, store *n_deps;
 *   fail: free queue + tmp + dep_sources/paths[0..n).
 * Slot max = XLANG_DRIVER_DEP_SLOT_MAX (32). PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_collect_deps_transitive_impl(module: *u8, arena_sz: i64, module_sz: i64, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, n_deps: *i32): i32 {
  if (n_deps == 0 as *i32) {
    return 1;
  }
  // char* to_load[32] as 32×8 pointer slots on stack (LP64).
  let to_load: u8[256] = [];
  let z: i32 = 0;
  while (z < 256) {
    to_load[z] = 0;
    z = z + 1;
  }
  let to_load_n: i32 = 0;
  // void* tmp_arena / tmp_module as two pointer cells (void star-star for process_one).
  let tmp_cells: u8[16] = [];
  z = 0;
  while (z < 16) {
    tmp_cells[z] = 0;
    z = z + 1;
  }
  let n: i32 = 0;
  let slot_max: i32 = 32;
  if (xlang_collect_seed_to_load(module, &to_load[0], &to_load_n) != 0) {
    // Fail: free any partial queue (seed_to_load already clears on OOM; still drain).
    while (to_load_n > 0) {
      to_load_n = to_load_n - 1;
      let p: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
      if (p != 0 as *u8) {
        unsafe {
          free(p);
        }
      }
      pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
    }
    return 1;
  }
  while (to_load_n > 0) {
    if (n >= slot_max) {
      break;
    }
    to_load_n = to_load_n - 1;
    let path_c: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
    pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
    let rc: i32 = 0;
    unsafe {
      rc = xlang_collect_deps_process_one(path_c, lib_roots, n_lib_roots, entry_dir, defines, ndefines, dep_sources, dep_lens, dep_paths, &n, &to_load[0], &to_load_n, &tmp_cells[0], &tmp_cells[8], arena_sz, module_sz);
    }
    if (rc != 0) {
      // Fail path: free remaining queue, tmp, and partial deps.
      while (to_load_n > 0) {
        to_load_n = to_load_n - 1;
        let p2: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
        if (p2 != 0 as *u8) {
          unsafe {
            free(p2);
          }
        }
        pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
      }
      let ta: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 0);
      let tm: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 1);
      unsafe {
        pipe_release_tmp_arena_module(ta, tm);
      }
      while (n > 0) {
        n = n - 1;
        let s: *u8 = pipe_load_ptr_slot(dep_sources, n);
        let k: *u8 = pipe_load_ptr_slot(dep_paths, n);
        if (s != 0 as *u8) {
          unsafe {
            free(s);
          }
        }
        if (k != 0 as *u8) {
          unsafe {
            free(k);
          }
        }
        pipe_store_ptr_slot(dep_sources, n, 0 as *u8);
        pipe_store_ptr_slot(dep_paths, n, 0 as *u8);
      }
      return 1;
    }
  }
  // Success: free leftover queue entries and tmp arena/module.
  while (to_load_n > 0) {
    to_load_n = to_load_n - 1;
    let p3: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
    if (p3 != 0 as *u8) {
      unsafe {
        free(p3);
      }
    }
    pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
  }
  let ta_ok: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 0);
  let tm_ok: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 1);
  unsafe {
    pipe_release_tmp_arena_module(ta_ok, tm_ok);
  }
  unsafe {
    xlang_i32_store(n_deps, n);
  }
  return 0;
}

/**
 * Paths-only transitive collect: seed queue, drain via paths_process_one, free leftovers.
 * @param module *u8 - entry AST module; may be null (seed_to_load then empty)
 * @param arena_sz i64 - tmp arena malloc size for first process_one that needs parse
 * @param module_sz i64 - tmp module malloc size for first process_one that needs parse
 * @param lib_roots *u8 - char star-star lib roots; may be null if n_lib_roots==0
 * @param n_lib_roots i32 - lib root count
 * @param entry_dir *u8 - entry directory C string; may be null
 * @param defines *u8 - char star-star define names; may be null if ndefines==0
 * @param ndefines i32 - define count
 * @param dep_paths *u8 - char star-star owned path keys out slots
 * @param n_deps *i32 - out live count; null -> fail 1
 * @return i32 - 0 success; 1 fail (partial paths freed; queue/tmp freed)
 * wave50 pure Cap residual orch: same stack to_load + tmp_cells as deps transitive;
 *   G.7 seed_to_load + pure paths_process_one; fail frees only dep_paths (no sources).
 * Slot max = XLANG_DRIVER_DEP_SLOT_MAX (32). PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_collect_dep_paths_transitive_impl(module: *u8, arena_sz: i64, module_sz: i64, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_paths: *u8, n_deps: *i32): i32 {
  if (n_deps == 0 as *i32) {
    return 1;
  }
  let to_load: u8[256] = [];
  let z: i32 = 0;
  while (z < 256) {
    to_load[z] = 0;
    z = z + 1;
  }
  let to_load_n: i32 = 0;
  let tmp_cells: u8[16] = [];
  z = 0;
  while (z < 16) {
    tmp_cells[z] = 0;
    z = z + 1;
  }
  let n: i32 = 0;
  let slot_max: i32 = 32;
  if (xlang_collect_seed_to_load(module, &to_load[0], &to_load_n) != 0) {
    while (to_load_n > 0) {
      to_load_n = to_load_n - 1;
      let p: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
      if (p != 0 as *u8) {
        unsafe {
          free(p);
        }
      }
      pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
    }
    return 1;
  }
  while (to_load_n > 0) {
    if (n >= slot_max) {
      break;
    }
    to_load_n = to_load_n - 1;
    let path_c: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
    pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
    let rc: i32 = 0;
    unsafe {
      rc = xlang_collect_paths_process_one(path_c, lib_roots, n_lib_roots, entry_dir, defines, ndefines, dep_paths, &n, &to_load[0], &to_load_n, &tmp_cells[0], &tmp_cells[8], arena_sz, module_sz);
    }
    if (rc != 0) {
      while (to_load_n > 0) {
        to_load_n = to_load_n - 1;
        let p2: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
        if (p2 != 0 as *u8) {
          unsafe {
            free(p2);
          }
        }
        pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
      }
      let ta: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 0);
      let tm: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 1);
      unsafe {
        pipe_release_tmp_arena_module(ta, tm);
      }
      while (n > 0) {
        n = n - 1;
        let k: *u8 = pipe_load_ptr_slot(dep_paths, n);
        if (k != 0 as *u8) {
          unsafe {
            free(k);
          }
        }
        pipe_store_ptr_slot(dep_paths, n, 0 as *u8);
      }
      return 1;
    }
  }
  while (to_load_n > 0) {
    to_load_n = to_load_n - 1;
    let p3: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
    if (p3 != 0 as *u8) {
      unsafe {
        free(p3);
      }
    }
    pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
  }
  let ta_ok: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 0);
  let tm_ok: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 1);
  unsafe {
    pipe_release_tmp_arena_module(ta_ok, tm_ok);
  }
  unsafe {
    xlang_i32_store(n_deps, n);
  }
  return 0;
}

/**
 * Enqueue sub-imports from a parsed tmp_module into to_load (skip loaded / already queued).
 * @param tmp_module *u8 - parsed dep module; null -> no-op
 * @param to_load *u8 - char** queue base; null -> no-op
 * @param to_load_n *i32 - live queue count (in/out); null -> no-op
 * @param dep_paths *u8 - already-loaded import keys as char star-star; may be null if n_loaded==0
 * @param n_loaded i32 - count of dep_paths already committed
 * @return void
 * wave47 pure Cap residual: G.7 reuses module_num_imports / import_path_cstr /
 *   xlang_find_loaded_import_index / xlang_collect_to_load_has / pipe slots;
 *   wave54 pure xlang_collect_strdup.
 * OOM on one strdup: skip that import (same as cold twin continue). PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_collect_enqueue_module_imports(tmp_module: *u8, to_load: *u8, to_load_n: *i32, dep_paths: *u8, n_loaded: i32): void {
  if (tmp_module == 0 as *u8) {
    return;
  }
  if (to_load == 0 as *u8) {
    return;
  }
  if (to_load_n == 0 as *i32) {
    return;
  }
  let slot_max: i32 = 32;
  let n_imp: i32 = 0;
  unsafe {
    n_imp = parser_get_module_num_imports(tmp_module);
  }
  if (n_imp <= 0) {
    return;
  }
  let jj: i32 = 0;
  while (jj < n_imp) {
    if (jj >= slot_max) {
      break;
    }
    let n: i32 = 0;
    unsafe {
      n = to_load_n[0];
    }
    if (n >= slot_max) {
      break;
    }
    let sub_c: u8[65] = [];
    xlang_module_import_path_cstr(tmp_module, jj, &sub_c[0], 65);
    // Skip if already loaded or already queued.
    if (xlang_find_loaded_import_index(&sub_c[0], dep_paths, n_loaded) >= 0) {
      jj = jj + 1;
      continue;
    }
    if (xlang_collect_to_load_has(to_load, n, &sub_c[0]) != 0) {
      jj = jj + 1;
      continue;
    }
    let owned: *u8 = 0 as *u8;
    unsafe {
      owned = xlang_collect_strdup(&sub_c[0]);
    }
    if (owned == 0 as *u8) {
      jj = jj + 1;
      continue;
    }
    pipe_store_ptr_slot(to_load, n, owned);
    unsafe {
      to_load_n[0] = n + 1;
    }
    jj = jj + 1;
  }
}

/**
 * Map preprocess_x_buf negative directive codes to fixed diag strings (PP002).
 * @param path_diag *u8 - path for report; may be null
 * @param code i32 - negative directive fail code (-2..-7 known; else generic fail)
 * @return void
 * wave46 pure: fixed msgs via stack byte lits + diag_report_with_code (no va_list).
 * PLATFORM: SHARED - Cap residual was always-seed; hybrid pure authority.
 */
#[no_mangle]
export function pipeline_diag_preprocess_directive_code(path_diag: *u8, code: i32): void {
  // Known codes -2..-7; anything else -> generic preprocess fail.
  if (code != (0 - 2)) {
    if (code != (0 - 3)) {
      if (code != (0 - 4)) {
        if (code != (0 - 5)) {
          if (code != (0 - 6)) {
            if (code != (0 - 7)) {
              pipeline_diag_preprocess_fail(path_diag);
              return;
            }
          }
        }
      }
    }
  }
  pipeline_diag_emitted_note();
  let kind: u8[24] = [];
  let dcode: u8[8] = [];
  // "preprocess error"
  kind[0] = 112; kind[1] = 114; kind[2] = 101; kind[3] = 112;
  kind[4] = 114; kind[5] = 111; kind[6] = 99; kind[7] = 101;
  kind[8] = 115; kind[9] = 115; kind[10] = 32; kind[11] = 101;
  kind[12] = 114; kind[13] = 114; kind[14] = 111; kind[15] = 114; kind[16] = 0;
  // "PP002"
  dcode[0] = 80; dcode[1] = 80; dcode[2] = 48; dcode[3] = 48; dcode[4] = 50; dcode[5] = 0;
  let msg: u8[32] = [];
  // Fill msg by code (ASCII byte tables; keep under ~63 lit cap).
  if (code == (0 - 2)) {
    // "#else without #if"
    msg[0] = 35; msg[1] = 101; msg[2] = 108; msg[3] = 115; msg[4] = 101;
    msg[5] = 32; msg[6] = 119; msg[7] = 105; msg[8] = 116; msg[9] = 104;
    msg[10] = 111; msg[11] = 117; msg[12] = 116; msg[13] = 32; msg[14] = 35;
    msg[15] = 105; msg[16] = 102; msg[17] = 0;
  } else if (code == (0 - 3)) {
    // "#endif without #if"
    msg[0] = 35; msg[1] = 101; msg[2] = 110; msg[3] = 100; msg[4] = 105;
    msg[5] = 102; msg[6] = 32; msg[7] = 119; msg[8] = 105; msg[9] = 116;
    msg[10] = 104; msg[11] = 111; msg[12] = 117; msg[13] = 116; msg[14] = 32;
    msg[15] = 35; msg[16] = 105; msg[17] = 102; msg[18] = 0;
  } else if (code == (0 - 4)) {
    // "#elseif without #if"
    msg[0] = 35; msg[1] = 101; msg[2] = 108; msg[3] = 115; msg[4] = 101;
    msg[5] = 105; msg[6] = 102; msg[7] = 32; msg[8] = 119; msg[9] = 105;
    msg[10] = 116; msg[11] = 104; msg[12] = 111; msg[13] = 117; msg[14] = 116;
    msg[15] = 32; msg[16] = 35; msg[17] = 105; msg[18] = 102; msg[19] = 0;
  } else if (code == (0 - 5)) {
    // "#elseif after #else"
    msg[0] = 35; msg[1] = 101; msg[2] = 108; msg[3] = 115; msg[4] = 101;
    msg[5] = 105; msg[6] = 102; msg[7] = 32; msg[8] = 97; msg[9] = 102;
    msg[10] = 116; msg[11] = 101; msg[12] = 114; msg[13] = 32; msg[14] = 35;
    msg[15] = 101; msg[16] = 108; msg[17] = 115; msg[18] = 101; msg[19] = 0;
  } else if (code == (0 - 6)) {
    // "duplicate #else"
    msg[0] = 100; msg[1] = 117; msg[2] = 112; msg[3] = 108; msg[4] = 105;
    msg[5] = 99; msg[6] = 97; msg[7] = 116; msg[8] = 101; msg[9] = 32;
    msg[10] = 35; msg[11] = 101; msg[12] = 108; msg[13] = 115; msg[14] = 101;
    msg[15] = 0;
  } else {
    // code == -7: "#if nesting too deep"
    msg[0] = 35; msg[1] = 105; msg[2] = 102; msg[3] = 32; msg[4] = 110;
    msg[5] = 101; msg[6] = 115; msg[7] = 116; msg[8] = 105; msg[9] = 110;
    msg[10] = 103; msg[11] = 32; msg[12] = 116; msg[13] = 111; msg[14] = 111;
    msg[15] = 32; msg[16] = 100; msg[17] = 101; msg[18] = 101; msg[19] = 112;
    msg[20] = 0;
  }
  unsafe {
    diag_report_with_code(path_diag, 0, 0, &kind[0], &dcode[0], &msg[0], 0 as *u8);
  }
}

// xlang_dep_prerun_entry_dir_pick: see function docblock below.
/** Exported function `xlang_dep_prerun_entry_dir_pick`.
 * Implements `xlang_dep_prerun_entry_dir_pick`.
 * @param main_entry_dir *u8
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @return *u8
 */
#[no_mangle]
export function xlang_dep_prerun_entry_dir_pick(main_entry_dir: *u8, lib_roots: *u8, n_lib_roots: i32): *u8 {
  if (lib_roots == 0 as *u8) { return main_entry_dir; }
  if (n_lib_roots <= 0) { return main_entry_dir; }
  unsafe {
    let r0: *u8 = pipe_load_ptr_slot(lib_roots, 0);
    if (r0 != 0 as *u8) {
      if (r0[0] != 0) { return r0; }
    }
  }
  return main_entry_dir;
}

/** Exported function `xlang_find_loaded_import_index_scan`.
 * Implements `xlang_find_loaded_import_index_scan`.
 * @param path *u8
 * @param all_paths *u8
 * @param n_all i32
 * @return i32
 */
#[no_mangle]
export function xlang_find_loaded_import_index_scan(path: *u8, all_paths: *u8, n_all: i32): i32 {
  if (path == 0 as *u8) { return 0 - 1; }
  if (all_paths == 0 as *u8) { return 0 - 1; }
  if (n_all <= 0) { return 0 - 1; }
  let i: i32 = 0;
  while (i < n_all) {
    let p: *u8 = pipe_load_ptr_slot(all_paths, i);
    if (p != 0) {
      if (pipe_cstr_eq(p, path) != 0) { return i; }
    }
    i = i + 1;
  }
  return 0 - 1;
}

/** Exported function `xlang_merge_deps_path_already_out_scan`.
 * Read path helper `xlang_merge_deps_path_already_out_scan`.
 * @param path *u8
 * @param out_paths *u8
 * @param n_out i32
 * @return i32
 */
#[no_mangle]
export function xlang_merge_deps_path_already_out_scan(path: *u8, out_paths: *u8, n_out: i32): i32 {
  if (path == 0 as *u8) { return 0; }
  if (out_paths == 0 as *u8) { return 0; }
  if (n_out <= 0) { return 0; }
  let j: i32 = 0;
  while (j < n_out) {
    let p: *u8 = pipe_load_ptr_slot(out_paths, j);
    if (p != 0) {
      if (pipe_cstr_eq(p, path) != 0) { return 1; }
    }
    j = j + 1;
  }
  return 0;
}

/* See implementation. */

// xlang_pipeline_pctx_update_dep_slots_no_reset: see function docblock below.
/** Exported function `xlang_pipeline_pctx_update_dep_slots_no_reset`.
 * Implements `xlang_pipeline_pctx_update_dep_slots_no_reset`.
 * @param ctx *u8
 * @param dep_mods *u8
 * @param dep_ars *u8
 * @param import_paths *u8
 * @param n i32
 * @return void
 */
#[no_mangle]
export function xlang_pipeline_pctx_update_dep_slots_no_reset(ctx: *u8, dep_mods: *u8, dep_ars: *u8, import_paths: *u8, n: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      let m: *u8 = 0 as *u8;
      let a: *u8 = 0 as *u8;
      if (dep_mods != 0 as *u8) {
        m = pipe_load_ptr_slot(dep_mods, i);
      }
      if (dep_ars != 0 as *u8) {
        a = pipe_load_ptr_slot(dep_ars, i);
      }
      ast_pipeline_dep_ctx_set_module(ctx, i, m);
      ast_pipeline_dep_ctx_set_arena(ctx, i, a);
      if (import_paths != 0 as *u8) {
        let p: *u8 = pipe_load_ptr_slot(import_paths, i);
        if (p != 0 as *u8) {
          let pl: i32 = pipe_cstr_len(p);
          ast_pipeline_dep_ctx_set_import_path(ctx, i, p, pl);
        }
      }
    }
    i = i + 1;
  }
  unsafe {
    ast_pipeline_dep_ctx_set_ndep(ctx, n);
  }
}



/* ---- G-02f-95 / G-02f-241 / wave56: pipeline large-stack thread fns pure ---- */

/**
 * pthread entry body: run pipeline_run_x_pipeline and store ec into args.result.
 * @param arg *u8 - PipelineRunSuArgs LP64 pack (56B):
 *   module@0 arena@8 source_data@16 source_len@24 out_buf@32 ctx@40 result@48;
 *   null -> return null
 * @return *u8 - always null (pthread start_routine contract)
 * wave56 pure Cap residual:
 *   load pack fields via pipe/size slots; driver_set_pipeline_entry_source_len;
 *   pipeline_run_x_pipeline; store result as LE i64 cell at slot 6 (i32@48 + pad).
 * XLANG_DEBUG_PIPE start/done notes stay cold-twin only (pure skips; same as tmp_parse).
 * PLATFORM: SHARED LP64 little-endian.
 */
#[no_mangle]
export function pipeline_run_x_thread_fn_impl(arg: *u8): *u8 {
  if (arg == 0 as *u8) {
    return 0 as *u8;
  }
  let module: *u8 = pipe_load_ptr_slot(arg, 0);
  let arena: *u8 = pipe_load_ptr_slot(arg, 1);
  let source_data: *u8 = pipe_load_ptr_slot(arg, 2);
  let source_len: i64 = xlang_size_slot_get(arg, 3);
  let out_buf: *u8 = pipe_load_ptr_slot(arg, 4);
  let ctx: *u8 = pipe_load_ptr_slot(arg, 5);
  unsafe {
    driver_set_pipeline_entry_source_len(source_len);
  }
  let ec: i32 = 0;
  unsafe {
    ec = pipeline_run_x_pipeline(module, arena, source_data, source_len, out_buf, ctx);
  }
  // result i32 lives at byte 48 = slot index 6; write full LE cell (pad ok).
  xlang_size_slot_set(arg, 6, ec as i64);
  return 0 as *u8;
}

/**
 * Thin pthread entry for large-stack pipeline_run_x_pipeline (null reject).
 * @param arg *u8 - PipelineRunSuArgs pack; null -> null
 * @return *u8 - always null
 * wave56: forwards to pure pipeline_run_x_thread_fn_impl.
 * PLATFORM: SHARED - address taken by pure pipeline_run_x_thread_fn_ptr (wave84 g05 cast).
 */
#[no_mangle]
export function pipeline_run_x_thread_fn(arg: *u8): *u8 {
  if (arg == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    return pipeline_run_x_thread_fn_impl(arg);
  }
  return 0 as *u8;
}

/**
 * Product Cap-fn-ptr surface: opaque *u8 address of pipeline_run_x_thread_fn.
 * @return *u8 - function address as opaque byte pointer (never null when linked)
 * wave84 pure product surface; wave100 language residual closed:
 *   typeck types same-module bare function names as Cap-fn-ptr *u8; body is
 *   (pipeline_run_x_thread_fn as *u8) - no g05 xlang_driver_* cast harness.
 *   C backend emits ((uint8_t *)(pipeline_run_x_thread_fn)); seed cold twin keeps
 *   (uint8_t *)(void *)fn under #ifndef FROM_X for full-C cold link.
 * PLATFORM: SHARED - closes g05 &fn cast Cap residual on pure path.
 */
#[no_mangle]
export function pipeline_run_x_thread_fn_ptr(): *u8 {
  return (pipeline_run_x_thread_fn as *u8);
}

/**
 * Large-stack orch: pack PipelineRunSuArgs, run thread_fn via Cap-fn-ptr, fallback current thread.
 * @param module *u8 - AST module (caller thin already null-checked)
 * @param arena *u8 - AST arena
 * @param source_data *u8 - source bytes
 * @param source_len i64 - byte length
 * @param out_buf *u8 - codegen out buffer
 * @param ctx *u8 - PipelineDepCtx
 * @return i32 - pipeline ec; fallback path if result still sentinel -99
 * wave56 pure Cap residual; wave84 pure owns Cap-fn-ptr surface (g05 &fn cast residual):
 *   stack args[56] zeroed; set entry source_len; fill pack; result sentinel -99;
 *   pure pipeline_run_x_thread_fn_ptr + G.7 driver_run_thread_on_large_stack;
 *   if result still -99 -> direct pipeline_run_x_pipeline (pthread create failed / skipped).
 * PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function xlang_pipeline_run_x_pipeline_large_stack_impl(module: *u8, arena: *u8, source_data: *u8, source_len: i64, out_buf: *u8, ctx: *u8): i32 {
  let args: u8[56] = [];
  let zi: i32 = 0;
  while (zi < 56) {
    args[zi] = 0;
    zi = zi + 1;
  }
  unsafe {
    driver_set_pipeline_entry_source_len(source_len);
  }
  pipe_store_ptr_slot(&args[0], 0, module);
  pipe_store_ptr_slot(&args[0], 1, arena);
  pipe_store_ptr_slot(&args[0], 2, source_data);
  xlang_size_slot_set(&args[0], 3, source_len);
  pipe_store_ptr_slot(&args[0], 4, out_buf);
  pipe_store_ptr_slot(&args[0], 5, ctx);
  // Sentinel -99: thread_fn overwrites on success; unchanged -> current-thread fallback.
  xlang_size_slot_set(&args[0], 6, 0 - 99);
  let fn: *u8 = 0 as *u8;
  unsafe {
    fn = pipeline_run_x_thread_fn_ptr();
  }
  if (fn != 0 as *u8) {
    unsafe {
      driver_run_thread_on_large_stack(fn, &args[0]);
    }
  }
  let result: i64 = xlang_size_slot_get(&args[0], 6);
  if (result == (0 - 99) as i64) {
    unsafe {
      return pipeline_run_x_pipeline(module, arena, source_data, source_len, out_buf, ctx);
    }
  }
  return result as i32;
}

// xlang_asm_codegen_elf_o_thread_fn: see function docblock below.
/**
 * Thin pthread entry for large-stack asm emit (null reject).
 * @param arg *u8 - AsmElfLargeArgs pack; null -> null
 * @return *u8 - always null
 * wave57: forwards to pure xlang_asm_codegen_elf_o_thread_fn_impl.
 * PLATFORM: SHARED - address taken by pure xlang_asm_codegen_elf_o_thread_fn_ptr (wave84 g05 cast).
 */
#[no_mangle]
export function xlang_asm_codegen_elf_o_thread_fn(arg: *u8): *u8 {
  if (arg == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    return xlang_asm_codegen_elf_o_thread_fn_impl(arg);
  }
  return 0 as *u8;
}

/**
 * Product Cap-fn-ptr surface: opaque *u8 address of xlang_asm_codegen_elf_o_thread_fn.
 * @return *u8 - function address as opaque byte pointer (never null when linked)
 * wave84 pure product surface; wave100 language residual closed:
 *   same-module bare fn -> *u8 (typeck); body (xlang_asm_codegen_elf_o_thread_fn as *u8);
 *   no g05 xlang_driver_asm_elf_o_thread_fn_ptr cast. Seed cold twin under #ifndef FROM_X.
 * PLATFORM: SHARED - closes g05 &fn cast Cap residual on pure path.
 */
#[no_mangle]
export function xlang_asm_codegen_elf_o_thread_fn_ptr(): *u8 {
  return (xlang_asm_codegen_elf_o_thread_fn as *u8);
}

/**
 * Pthread body: unpack AsmElfLargeArgs, Cap residual product emit, store result.
 * @param arg *u8 - AsmElfLargeArgs LP64 pack (48B):
 *   module@0 arena@8 ctx@16 elf_ctx@24 out_buf@32 result@40;
 *   null -> return null
 * @return *u8 - always null (pthread start_routine contract)
 * wave57 pure Cap residual orch; wave80 product_emit is pure G.7 thin (bridge reloc).
 *   load pack via pipe/size slots; G.7 pure xlang_asm_codegen_elf_o_product_emit;
 *   store result as LE i64 cell at slot 5 (i32@40 + pad).
 * PLATFORM: SHARED LP64 little-endian.
 */
#[no_mangle]
export function xlang_asm_codegen_elf_o_thread_fn_impl(arg: *u8): *u8 {
  if (arg == 0 as *u8) {
    return 0 as *u8;
  }
  let module: *u8 = pipe_load_ptr_slot(arg, 0);
  let arena: *u8 = pipe_load_ptr_slot(arg, 1);
  let ctx: *u8 = pipe_load_ptr_slot(arg, 2);
  let elf_ctx: *u8 = pipe_load_ptr_slot(arg, 3);
  let out_buf: *u8 = pipe_load_ptr_slot(arg, 4);
  let ec: i32 = 0;
  unsafe {
    ec = xlang_asm_codegen_elf_o_product_emit(module, arena, ctx, elf_ctx, out_buf);
  }
  // result i32 lives at byte 40 = slot index 5; write full LE cell (pad ok).
  xlang_size_slot_set(arg, 5, ec as i64);
  return 0 as *u8;
}

/**
 * Large-stack orch: pack AsmElfLargeArgs, run thread_fn via Cap-fn-ptr, fallback emit.
 * @param module *u8 - AST module (caller thin already null-checked)
 * @param arena *u8 - AST arena
 * @param ctx *u8 - PipelineDepCtx
 * @param elf_ctx *u8 - ElfCodegenCtx
 * @param out_buf *u8 - emit out buffer
 * @return i32 - emit ec; fallback path if result still sentinel -99
 * wave57 pure Cap residual orch; wave80 product_emit pure thin; wave84 pure Cap-fn-ptr surface:
 *   stack args[48] zeroed; fill pack; result sentinel -99;
 *   pure xlang_asm_codegen_elf_o_thread_fn_ptr (g05 &fn cast) + G.7 driver_run_thread_on_large_stack;
 *   if result still -99 -> G.7 pure product_emit (pthread create failed / skipped).
 * PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function xlang_asm_codegen_elf_o_large_stack_impl(module: *u8, arena: *u8, ctx: *u8, elf_ctx: *u8, out_buf: *u8): i32 {
  let args: u8[48] = [];
  let zi: i32 = 0;
  while (zi < 48) {
    args[zi] = 0;
    zi = zi + 1;
  }
  pipe_store_ptr_slot(&args[0], 0, module);
  pipe_store_ptr_slot(&args[0], 1, arena);
  pipe_store_ptr_slot(&args[0], 2, ctx);
  pipe_store_ptr_slot(&args[0], 3, elf_ctx);
  pipe_store_ptr_slot(&args[0], 4, out_buf);
  // Sentinel -99: thread_fn overwrites on success; unchanged -> current-thread fallback.
  xlang_size_slot_set(&args[0], 5, 0 - 99);
  let fn: *u8 = 0 as *u8;
  unsafe {
    fn = xlang_asm_codegen_elf_o_thread_fn_ptr();
  }
  if (fn != 0 as *u8) {
    unsafe {
      driver_run_thread_on_large_stack(fn, &args[0]);
    }
  }
  let result: i64 = xlang_size_slot_get(&args[0], 5);
  if (result == (0 - 99) as i64) {
    unsafe {
      return xlang_asm_codegen_elf_o_product_emit(module, arena, ctx, elf_ctx, out_buf);
    }
  }
  return result as i32;
}

/**
 * Whether XLANG_ASM_DEBUG is set (asm pipeline debug notes gate).
 * wave235 G.7: env via public pure thin link_abi_getenv (not raw libc getenv).
 * @return i32 - 1 if env present (any value), 0 otherwise
 * PLATFORM: SHARED - host residual only link_abi_getenv_impl
 */
#[no_mangle]
export function pipeline_asm_debug_enabled(): i32 {
  unsafe {
    // wave235 G.7: XLANG_ASM_DEBUG via link_abi_getenv (not raw getenv).
    let e: *u8 = link_abi_getenv("XLANG_ASM_DEBUG");
    if (e != 0) { return 1; }
  }
  return 0;
}

// pipeline_debug_body_func_match: see function docblock below.

/** Exported function `pipeline_debug_body_func_match`.
 * Implements `pipeline_debug_body_func_match`.
 * @param filter *u8
 * @param name *u8
 * @return i32
 */
#[no_mangle]
export function pipeline_debug_body_func_match(filter: *u8, name: *u8): i32 {
  if (filter == 0) { return 0; }
  if (filter[0] == 0) { return 0; }
  if (filter[0] == 48) { return 0; } // '0'
  if (name == 0) { return 0; }
  if (name[0] == 0) { return 0; }
  // name_len
  let name_len: i32 = 0;
  while (name_len < 512) {
    if (name[name_len] == 0) { break; }
    name_len = name_len + 1;
  }
  let p: i32 = 0;
  while (p < 4096) {
    let c: u8 = filter[p];
    if (c == 0) { break; }
    // skip spaces/tabs/commas
    while (p < 4096) {
      c = filter[p];
      if (c == 0) { break; }
      if (c == 32) { p = p + 1; continue; }
      if (c == 9) { p = p + 1; continue; }
      if (c == 44) { p = p + 1; continue; }
      break;
    }
    c = filter[p];
    if (c == 0) { break; }
    let start: i32 = p;
    while (p < 4096) {
      c = filter[p];
      if (c == 0) { break; }
      if (c == 44) { break; }
      p = p + 1;
    }
    let end: i32 = p;
    // trim trailing space/tab
    while (end > start) {
      let pc: u8 = filter[end - 1];
      if (pc == 32) { end = end - 1; continue; }
      if (pc == 9) { end = end - 1; continue; }
      break;
    }
    let tok_len: i32 = end - start;
    if (tok_len > 0) {
      if (tok_len == name_len) {
        let k: i32 = 0;
        let eq: i32 = 1;
        while (k < tok_len) {
          if (filter[start + k] != name[k]) { eq = 0; break; }
          k = k + 1;
        }
        if (eq != 0) { return 1; }
      }
    }
  }
  return 0;
}

// =============================================================================
// wave110 pure ImportEntry storage (structure debt close under product PREFER)
// =============================================================================
// PLATFORM: SHARED LP64 - multi-module pointer-keyed map + malloc grow for entries
// and select name rows. Mirrors ast_pool ModuleSidecar.imports + import_select_* .
// Product hybrid: pure strong pipeline_module_import_* override Cap XLANG_WEAK cold.
// Layout of one ImportEntry (340 bytes, packed LE, ≡ C typedef ImportEntry):
//   path[256] @0 | path_len i32 @256 | kind i32 @260 | binding_name[128] @264
//   | binding_name_len i32 @328 | select_base i32 @332 | select_count i32 @336
// Module.num_imports lives at LP64 offsetof 8 (header field; parser authority read).
// Soft-reset: when header num_imports==0, pure slot n_imports/sel_n forced 0 so
// parse reset / module reset does not leave stale pure rows (Cap grow len cleared
// separately; pure is single authority for product import storage after demote).
// Caps: 128 module slots (product collect peak << MAX_MODULE_SIDECARS 512);
// entry/select grow from 8, double until need (OOM -> -1 / no-op like Cap).
// =============================================================================

let g_pipe_imp_mod: u8[1024] = [];
let g_pipe_imp_n: i32[128] = [];
let g_pipe_imp_cap: i32[128] = [];
let g_pipe_imp_entries: u8[1024] = [];
let g_pipe_imp_sel_n: i32[128] = [];
let g_pipe_imp_sel_cap: i32[128] = [];
let g_pipe_imp_sel_rows: u8[1024] = [];
let g_pipe_imp_sel_lens: u8[1024] = [];

/**
 * Byte size of one ImportEntry (path 256 + 4 i32 fields + binding 64).
 * @return i32 - 340
 * PLATFORM: SHARED LP64 - must match C sizeof(ImportEntry).
 */
function pipe_imp_entry_size(): i32 {
  return 340;
}

/**
 * LP64 offsetof(struct ast_Module, num_imports).
 * @return i32 - 8
 * PLATFORM: SHARED LP64 - dual-end verified with sizeof Module=68.
 */
function pipe_imp_off_num_imports(): i32 {
  return 8;
}

/**
 * Write module.num_imports header field (null-safe).
 * @param module *u8 - opaque ast_Module
 * @param n i32 - live import count
 * @return void
 */
function pipe_imp_set_header_n(module: *u8, n: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  pipe_store_i32_le(module, pipe_imp_off_num_imports(), n);
}

/**
 * Read module.num_imports header field (null -> 0).
 * @param module *u8 - opaque ast_Module
 * @return i32 - header count
 */
function pipe_imp_get_header_n(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(module, pipe_imp_off_num_imports());
}

/**
 * Find map slot for module pointer (exact key match).
 * @param module *u8 - module key; null -> -1
 * @return i32 - slot 0..127 or -1
 */
function pipe_imp_find_slot(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  let i: i32 = 0;
  while (i < 128) {
    let k: *u8 = xlang_ptr_slot_get(&g_pipe_imp_mod[0], i);
    if (k == module) {
      return i;
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Soft-reset pure counts when header num_imports is 0 (parse/module reset).
 * Keeps malloc capacity; zeros live n_imports and select row count.
 * @param module *u8 - module key
 * @return void
 */
function pipe_imp_soft_sync(module: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  if (pipe_imp_get_header_n(module) != 0) {
    return;
  }
  let s: i32 = pipe_imp_find_slot(module);
  if (s < 0) {
    return;
  }
  g_pipe_imp_n[s] = 0;
  g_pipe_imp_sel_n[s] = 0;
}

/**
 * Find or allocate a map slot for module.
 * @param module *u8 - module key; null -> -1
 * @return i32 - slot or -1 if map full
 */
function pipe_imp_find_or_create(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  pipe_imp_soft_sync(module);
  let found: i32 = pipe_imp_find_slot(module);
  if (found >= 0) {
    return found;
  }
  let i: i32 = 0;
  while (i < 128) {
    let k: *u8 = xlang_ptr_slot_get(&g_pipe_imp_mod[0], i);
    if (k == 0 as *u8) {
      xlang_ptr_slot_set(&g_pipe_imp_mod[0], i, module);
      g_pipe_imp_n[i] = 0;
      g_pipe_imp_cap[i] = 0;
      g_pipe_imp_sel_n[i] = 0;
      g_pipe_imp_sel_cap[i] = 0;
      xlang_ptr_slot_set(&g_pipe_imp_entries[0], i, 0 as *u8);
      xlang_ptr_slot_set(&g_pipe_imp_sel_rows[0], i, 0 as *u8);
      xlang_ptr_slot_set(&g_pipe_imp_sel_lens[0], i, 0 as *u8);
      return i;
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Ensure entry table capacity >= need for slot (malloc grow, double).
 * @param slot i32 - map slot
 * @param need i32 - required live+push capacity
 * @return i32 - 1 ok, 0 fail
 */
function pipe_imp_ensure_entries(slot: i32, need: i32): i32 {
  if (slot < 0) {
    return 0;
  }
  if (slot >= 128) {
    return 0;
  }
  if (need <= 0) {
    return 1;
  }
  let cap: i32 = g_pipe_imp_cap[slot];
  if (cap >= need) {
    return 1;
  }
  let new_cap: i32 = cap;
  if (new_cap < 8) {
    new_cap = 8;
  }
  while (new_cap < need) {
    new_cap = new_cap * 2;
  }
  let esz: i32 = pipe_imp_entry_size();
  let nbytes: usize = (new_cap * esz) as usize;
  // extern malloc/memset/memcpy/free require unsafe (T001).
  let np: *u8 = 0 as *u8;
  unsafe {
    np = malloc(nbytes);
  }
  if (np == 0 as *u8) {
    return 0;
  }
  unsafe {
    memset(np, 0, nbytes);
  }
  let old: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], slot);
  let old_n: i32 = g_pipe_imp_n[slot];
  if (old != 0 as *u8) {
    if (old_n > 0) {
      let old_bytes: usize = (old_n * esz) as usize;
      unsafe {
        memcpy(np, old, old_bytes);
      }
    }
    unsafe {
      free(old);
    }
  }
  xlang_ptr_slot_set(&g_pipe_imp_entries[0], slot, np);
  g_pipe_imp_cap[slot] = new_cap;
  return 1;
}

/**
 * Ensure select row/lens capacity >= need for slot.
 * @param slot i32 - map slot
 * @param need i32 - required select row count
 * @return i32 - 1 ok, 0 fail
 */
function pipe_imp_ensure_select(slot: i32, need: i32): i32 {
  if (slot < 0) {
    return 0;
  }
  if (slot >= 128) {
    return 0;
  }
  if (need <= 0) {
    return 1;
  }
  let cap: i32 = g_pipe_imp_sel_cap[slot];
  if (cap >= need) {
    return 1;
  }
  let new_cap: i32 = cap;
  if (new_cap < 8) {
    new_cap = 8;
  }
  while (new_cap < need) {
    new_cap = new_cap * 2;
  }
  let row_bytes: usize = (new_cap * 64) as usize;
  let lens_bytes: usize = (new_cap * 4) as usize;
  let nrows: *u8 = 0 as *u8;
  let nlens: *u8 = 0 as *u8;
  unsafe {
    nrows = malloc(row_bytes);
    nlens = malloc(lens_bytes);
  }
  if (nrows == 0 as *u8) {
    if (nlens != 0 as *u8) {
      unsafe {
        free(nlens);
      }
    }
    return 0;
  }
  if (nlens == 0 as *u8) {
    unsafe {
      free(nrows);
    }
    return 0;
  }
  unsafe {
    memset(nrows, 0, row_bytes);
    memset(nlens, 0, lens_bytes);
  }
  let old_rows: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_rows[0], slot);
  let old_lens: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_lens[0], slot);
  let old_n: i32 = g_pipe_imp_sel_n[slot];
  if (old_rows != 0 as *u8) {
    if (old_n > 0) {
      unsafe {
        memcpy(nrows, old_rows, (old_n * 64) as usize);
      }
    }
    unsafe {
      free(old_rows);
    }
  }
  if (old_lens != 0 as *u8) {
    if (old_n > 0) {
      unsafe {
        memcpy(nlens, old_lens, (old_n * 4) as usize);
      }
    }
    unsafe {
      free(old_lens);
    }
  }
  xlang_ptr_slot_set(&g_pipe_imp_sel_rows[0], slot, nrows);
  xlang_ptr_slot_set(&g_pipe_imp_sel_lens[0], slot, nlens);
  g_pipe_imp_sel_cap[slot] = new_cap;
  return 1;
}

/**
 * Pointer to ImportEntry byte base at idx for slot (null if OOB).
 * @param slot i32 - map slot
 * @param idx i32 - import index
 * @return *u8 - entry base or null
 */
export function pipe_imp_entry_at(slot: i32, idx: i32): *u8 {
  if (slot < 0) {
    return 0 as *u8;
  }
  if (idx < 0) {
    return 0 as *u8;
  }
  if (idx >= g_pipe_imp_n[slot]) {
    return 0 as *u8;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], slot);
  if (base == 0 as *u8) {
    return 0 as *u8;
  }
  // byte offset = idx * 340 via repeated add (no ptr+int in .x)
  let off: i32 = idx * pipe_imp_entry_size();
  // return base+off by reconstructing from raw address bits is unavailable;
  // use index into flat table: xlang path indexes base[off + field]
  // Callers pass (base, idx) pair - store base and use idx*esz offset in field ops.
  return base;
}

/**
 * Field offset of entry idx inside entries buffer.
 * @param idx i32 - import index
 * @return i32 - byte offset
 */
function pipe_imp_entry_off(idx: i32): i32 {
  return idx * pipe_imp_entry_size();
}

/**
 * Free pure import storage for one module and clear map slot.
 * @param module *u8 - module key; null -> no-op
 * @return void
 * wave110: called from Cap ast_pool_module_release (strong pure) and cold weak empty.
 * PLATFORM: SHARED - product hybrid owns free of malloc tables.
 */
#[no_mangle]
export function pipeline_module_import_storage_release(module: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  let s: i32 = pipe_imp_find_slot(module);
  if (s < 0) {
    return;
  }
  let e: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
  if (e != 0 as *u8) {
    unsafe {
      free(e);
    }
  }
  let r: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_rows[0], s);
  if (r != 0 as *u8) {
    unsafe {
      free(r);
    }
  }
  let l: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_lens[0], s);
  if (l != 0 as *u8) {
    unsafe {
      free(l);
    }
  }
  xlang_ptr_slot_set(&g_pipe_imp_mod[0], s, 0 as *u8);
  xlang_ptr_slot_set(&g_pipe_imp_entries[0], s, 0 as *u8);
  xlang_ptr_slot_set(&g_pipe_imp_sel_rows[0], s, 0 as *u8);
  xlang_ptr_slot_set(&g_pipe_imp_sel_lens[0], s, 0 as *u8);
  g_pipe_imp_n[s] = 0;
  g_pipe_imp_cap[s] = 0;
  g_pipe_imp_sel_n[s] = 0;
  g_pipe_imp_sel_cap[s] = 0;
}

/**
 * Allocate one ImportEntry for module; return index or -1.
 * @param module *u8 - opaque ast_Module; null -> -1
 * @return i32 - new import index (>=0) or -1
 * wave110 pure Cap residual: G.7 product authority (historical ast_pool GrowVec).
 * Updates module.num_imports header ≡ Cap m->num_imports = sc->imports.length.
 * PLATFORM: SHARED - Cap XLANG_WEAK cold twin for non-PREFER links.
 */
#[no_mangle]
export function pipeline_module_import_alloc(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  let s: i32 = pipe_imp_find_or_create(module);
  if (s < 0) {
    return 0 - 1;
  }
  let n: i32 = g_pipe_imp_n[s];
  if (pipe_imp_ensure_entries(s, n + 1) == 0) {
    return 0 - 1;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
  if (base == 0 as *u8) {
    return 0 - 1;
  }
  let off: i32 = pipe_imp_entry_off(n);
  // zero new entry (340 bytes)
  let k: i32 = 0;
  while (k < 340) {
    unsafe {
      base[off + k] = 0;
    }
    k = k + 1;
  }
  g_pipe_imp_n[s] = n + 1;
  pipe_imp_set_header_n(module, n + 1);
  return n;
}

/**
 * Set import path bytes at idx (len 1..255).
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param bytes *u8 - path bytes
 * @param len i32 - byte length; <=0 or >255 -> no-op
 * @return void
 * PLATFORM: SHARED - ≡ Cap pipeline_module_import_set_path.
 */
#[no_mangle]
export function pipeline_module_import_set_path(module: *u8, idx: i32, bytes: *u8, len: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  if (bytes == 0 as *u8) {
    return;
  }
  if (len <= 0) {
    return;
  }
  if (len > 255) {
    return;
  }
  pipe_imp_soft_sync(module);
  let s: i32 = pipe_imp_find_slot(module);
  if (s < 0) {
    return;
  }
  if (idx < 0) {
    return;
  }
  if (idx >= g_pipe_imp_n[s]) {
    return;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
  if (base == 0 as *u8) {
    return;
  }
  let off: i32 = pipe_imp_entry_off(idx);
  let z: i32 = 0;
  while (z < 256) {
    unsafe {
      base[off + z] = 0;
    }
    z = z + 1;
  }
  let i: i32 = 0;
  while (i < len) {
    unsafe {
      base[off + i] = bytes[i];
    }
    i = i + 1;
  }
  pipe_store_i32_le(base, off + 256, len);
}

/**
 * Import path length at idx.
 * @param module *u8 - module
 * @param idx i32 - import index
 * @return i32 - path_len or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_path_len(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_imp_soft_sync(module);
  let s: i32 = pipe_imp_find_slot(module);
  if (s < 0) {
    return 0;
  }
  if (idx < 0) {
    return 0;
  }
  if (idx >= g_pipe_imp_n[s]) {
    return 0;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
  if (base == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(base, pipe_imp_entry_off(idx) + 256);
}

/**
 * Copy import path to dst with trailing NUL (cap includes NUL).
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param dst *u8 - destination
 * @param dst_cap i32 - capacity
 * @return void
 * wave110 pure: G.7 product path_copy authority (wave99 path64 thin consumer).
 * PLATFORM: SHARED - Cap XLANG_WEAK cold twin.
 */
#[no_mangle]
export function pipeline_module_import_path_copy(module: *u8, idx: i32, dst: *u8, dst_cap: i32): void {
  if (dst == 0 as *u8) {
    return;
  }
  if (dst_cap <= 0) {
    return;
  }
  unsafe {
    dst[0] = 0;
  }
  if (module == 0 as *u8) {
    return;
  }
  pipe_imp_soft_sync(module);
  let s: i32 = pipe_imp_find_slot(module);
  if (s < 0) {
    return;
  }
  if (idx < 0) {
    return;
  }
  if (idx >= g_pipe_imp_n[s]) {
    return;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
  if (base == 0 as *u8) {
    return;
  }
  let off: i32 = pipe_imp_entry_off(idx);
  let n: i32 = pipe_load_i32_le(base, off + 256);
  if (n >= dst_cap) {
    n = dst_cap - 1;
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      dst[i] = base[off + i];
    }
    i = i + 1;
  }
  unsafe {
    dst[n] = 0;
  }
}

/**
 * Path byte at off for import idx.
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param off i32 - byte offset in path
 * @return u8 - byte or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_path_byte_at(module: *u8, idx: i32, off: i32): u8 {
  if (module == 0 as *u8) {
    return 0 as u8;
  }
  if (off < 0) {
    return 0 as u8;
  }
  pipe_imp_soft_sync(module);
  let s: i32 = pipe_imp_find_slot(module);
  if (s < 0) {
    return 0 as u8;
  }
  if (idx < 0) {
    return 0 as u8;
  }
  if (idx >= g_pipe_imp_n[s]) {
    return 0 as u8;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
  if (base == 0 as *u8) {
    return 0 as u8;
  }
  let eoff: i32 = pipe_imp_entry_off(idx);
  let plen: i32 = pipe_load_i32_le(base, eoff + 256);
  if (off >= plen) {
    return 0 as u8;
  }
  if (off >= 256) {
    return 0 as u8;
  }
  let b: u8 = 0;
  unsafe {
    b = base[eoff + off];
  }
  return b;
}

/**
 * Set import kind at idx.
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param kind i32 - kind code
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_set_kind(module: *u8, idx: i32, kind: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  pipe_imp_soft_sync(module);
  let s: i32 = pipe_imp_find_slot(module);
  if (s < 0) {
    return;
  }
  if (idx < 0) {
    return;
  }
  if (idx >= g_pipe_imp_n[s]) {
    return;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
  if (base == 0 as *u8) {
    return;
  }
  pipe_store_i32_le(base, pipe_imp_entry_off(idx) + 260, kind);
}

/**
 * Import kind at idx.
 * @param module *u8 - module
 * @param idx i32 - import index
 * @return i32 - kind or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_kind_at(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_imp_soft_sync(module);
  let s: i32 = pipe_imp_find_slot(module);
  if (s < 0) {
    return 0;
  }
  if (idx < 0) {
    return 0;
  }
  if (idx >= g_pipe_imp_n[s]) {
    return 0;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
  if (base == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(base, pipe_imp_entry_off(idx) + 260);
}

/**
 * Set binding name at idx (len 1..64).
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param bytes *u8 - name bytes
 * @param len i32 - length; <=0 or >64 -> no-op
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_set_binding_name(module: *u8, idx: i32, bytes: *u8, len: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  if (bytes == 0 as *u8) {
    return;
  }
  if (len <= 0) {
    return;
  }
  if (len > 64) {
    return;
  }
  pipe_imp_soft_sync(module);
  let s: i32 = pipe_imp_find_slot(module);
  if (s < 0) {
    return;
  }
  if (idx < 0) {
    return;
  }
  if (idx >= g_pipe_imp_n[s]) {
    return;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
  if (base == 0 as *u8) {
    return;
  }
  let eoff: i32 = pipe_imp_entry_off(idx);
  let z: i32 = 0;
  while (z < 64) {
    unsafe {
      base[eoff + 264 + z] = 0;
    }
    z = z + 1;
  }
  let i: i32 = 0;
  while (i < len) {
    unsafe {
      base[eoff + 264 + i] = bytes[i];
    }
    i = i + 1;
  }
  pipe_store_i32_le(base, eoff + 328, len);
}

/**
 * Binding name length at idx.
 * @param module *u8 - module
 * @param idx i32 - import index
 * @return i32 - length or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_binding_name_len(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_imp_soft_sync(module);
  let s: i32 = pipe_imp_find_slot(module);
  if (s < 0) {
    return 0;
  }
  if (idx < 0) {
    return 0;
  }
  if (idx >= g_pipe_imp_n[s]) {
    return 0;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
  if (base == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(base, pipe_imp_entry_off(idx) + 328);
}

/**
 * Binding name byte at off.
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param off i32 - offset in binding name
 * @return u8 - byte or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_binding_name_byte_at(module: *u8, idx: i32, off: i32): u8 {
  if (module == 0 as *u8) {
    return 0 as u8;
  }
  if (off < 0) {
    return 0 as u8;
  }
  if (off >= 64) {
    return 0 as u8;
  }
  pipe_imp_soft_sync(module);
  let s: i32 = pipe_imp_find_slot(module);
  if (s < 0) {
    return 0 as u8;
  }
  if (idx < 0) {
    return 0 as u8;
  }
  if (idx >= g_pipe_imp_n[s]) {
    return 0 as u8;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
  if (base == 0 as *u8) {
    return 0 as u8;
  }
  let eoff: i32 = pipe_imp_entry_off(idx);
  let bl: i32 = pipe_load_i32_le(base, eoff + 328);
  if (off >= bl) {
    return 0 as u8;
  }
  let b: u8 = 0;
  unsafe {
    b = base[eoff + 264 + off];
  }
  return b;
}

/**
 * Set select_count field only (does not grow select pool).
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param n i32 - select count
 * @return void
 * PLATFORM: SHARED - ≡ Cap set_select_count.
 */
#[no_mangle]
export function pipeline_module_import_set_select_count(module: *u8, idx: i32, n: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  pipe_imp_soft_sync(module);
  let s: i32 = pipe_imp_find_slot(module);
  if (s < 0) {
    return;
  }
  if (idx < 0) {
    return;
  }
  if (idx >= g_pipe_imp_n[s]) {
    return;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
  if (base == 0 as *u8) {
    return;
  }
  pipe_store_i32_le(base, pipe_imp_entry_off(idx) + 336, n);
}

/**
 * Append one select name row for import idx.
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param bytes *u8 - name bytes
 * @param len i32 - length; capped to 63
 * @return i32 - new select index within import or -1
 * PLATFORM: SHARED - ≡ Cap append_select_name (dynamic grow, no 8-cap).
 */
#[no_mangle]
export function pipeline_module_import_append_select_name(module: *u8, idx: i32, bytes: *u8, len: i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (bytes == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  if (idx < 0) {
    return 0 - 1;
  }
  pipe_imp_soft_sync(module);
  let s: i32 = pipe_imp_find_or_create(module);
  if (s < 0) {
    return 0 - 1;
  }
  if (idx >= g_pipe_imp_n[s]) {
    return 0 - 1;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
  if (base == 0 as *u8) {
    return 0 - 1;
  }
  let eoff: i32 = pipe_imp_entry_off(idx);
  let scount: i32 = pipe_load_i32_le(base, eoff + 336);
  if (scount == 0) {
    pipe_store_i32_le(base, eoff + 332, g_pipe_imp_sel_n[s]);
  }
  let vi: i32 = g_pipe_imp_sel_n[s];
  if (pipe_imp_ensure_select(s, vi + 1) == 0) {
    return 0 - 1;
  }
  let rows: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_rows[0], s);
  let lens: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_lens[0], s);
  if (rows == 0 as *u8) {
    return 0 - 1;
  }
  if (lens == 0 as *u8) {
    return 0 - 1;
  }
  let row_off: i32 = vi * 64;
  let z: i32 = 0;
  while (z < 64) {
    unsafe {
      rows[row_off + z] = 0;
    }
    z = z + 1;
  }
  let n: i32 = len;
  if (n > 127) {
    n = 127;
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      rows[row_off + i] = bytes[i];
    }
    i = i + 1;
  }
  pipe_store_i32_le(lens, vi * 4, n);
  g_pipe_imp_sel_n[s] = vi + 1;
  pipe_store_i32_le(base, eoff + 336, scount + 1);
  return scount;
}

/**
 * select_count at import idx.
 * @param module *u8 - module
 * @param idx i32 - import index
 * @return i32 - count or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_select_count_at(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_imp_soft_sync(module);
  let s: i32 = pipe_imp_find_slot(module);
  if (s < 0) {
    return 0;
  }
  if (idx < 0) {
    return 0;
  }
  if (idx >= g_pipe_imp_n[s]) {
    return 0;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
  if (base == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(base, pipe_imp_entry_off(idx) + 336);
}

/**
 * Set or grow-to select name at (idx, sel).
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param sel i32 - select index within import
 * @param bytes *u8 - name bytes
 * @param len i32 - length
 * @return void
 * PLATFORM: SHARED - ≡ Cap set_select_name (append until sel reachable).
 */
#[no_mangle]
export function pipeline_module_import_set_select_name(module: *u8, idx: i32, sel: i32, bytes: *u8, len: i32): void {
  if (module == 0 as *u8) {
    return;
  }
  if (bytes == 0 as *u8) {
    return;
  }
  if (len <= 0) {
    return;
  }
  if (sel < 0) {
    return;
  }
  pipe_imp_soft_sync(module);
  let s: i32 = pipe_imp_find_or_create(module);
  if (s < 0) {
    return;
  }
  if (idx < 0) {
    return;
  }
  if (idx >= g_pipe_imp_n[s]) {
    return;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
  if (base == 0 as *u8) {
    return;
  }
  let eoff: i32 = pipe_imp_entry_off(idx);
  while (1 == 1) {
    let scount: i32 = pipe_load_i32_le(base, eoff + 336);
    if (scount > sel) {
      break;
    }
    let ap: i32 = pipeline_module_import_append_select_name(module, idx, bytes, len);
    if (ap < 0) {
      return;
    }
    // Cap: if sel < scount-1 after append return - only last append fills target.
    scount = pipe_load_i32_le(base, eoff + 336);
    if (sel < scount - 1) {
      return;
    }
  }
  let sbase: i32 = pipe_load_i32_le(base, eoff + 332);
  let abs: i32 = sbase + sel;
  let rows: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_rows[0], s);
  let lens: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_lens[0], s);
  if (rows == 0 as *u8) {
    return;
  }
  if (lens == 0 as *u8) {
    return;
  }
  if (abs < 0) {
    return;
  }
  if (abs >= g_pipe_imp_sel_n[s]) {
    return;
  }
  let row_off: i32 = abs * 64;
  let z: i32 = 0;
  while (z < 64) {
    unsafe {
      rows[row_off + z] = 0;
    }
    z = z + 1;
  }
  let n: i32 = len;
  if (n > 127) {
    n = 127;
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      rows[row_off + i] = bytes[i];
    }
    i = i + 1;
  }
  pipe_store_i32_le(lens, abs * 4, n);
}

/**
 * Select name length at (idx, sel).
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param sel i32 - select index
 * @return i32 - length or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_select_name_len(module: *u8, idx: i32, sel: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  if (sel < 0) {
    return 0;
  }
  pipe_imp_soft_sync(module);
  let s: i32 = pipe_imp_find_slot(module);
  if (s < 0) {
    return 0;
  }
  if (idx < 0) {
    return 0;
  }
  if (idx >= g_pipe_imp_n[s]) {
    return 0;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
  if (base == 0 as *u8) {
    return 0;
  }
  let eoff: i32 = pipe_imp_entry_off(idx);
  let scount: i32 = pipe_load_i32_le(base, eoff + 336);
  if (sel >= scount) {
    return 0;
  }
  let sbase: i32 = pipe_load_i32_le(base, eoff + 332);
  let abs: i32 = sbase + sel;
  if (abs < 0) {
    return 0;
  }
  if (abs >= g_pipe_imp_sel_n[s]) {
    return 0;
  }
  let lens: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_lens[0], s);
  if (lens == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(lens, abs * 4);
}

/**
 * Select name byte at (idx, sel, off).
 * @param module *u8 - module
 * @param idx i32 - import index
 * @param sel i32 - select index
 * @param off i32 - byte offset
 * @return u8 - byte or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_import_select_name_byte_at(module: *u8, idx: i32, sel: i32, off: i32): u8 {
  if (module == 0 as *u8) {
    return 0 as u8;
  }
  if (sel < 0) {
    return 0 as u8;
  }
  if (off < 0) {
    return 0 as u8;
  }
  pipe_imp_soft_sync(module);
  let s: i32 = pipe_imp_find_slot(module);
  if (s < 0) {
    return 0 as u8;
  }
  if (idx < 0) {
    return 0 as u8;
  }
  if (idx >= g_pipe_imp_n[s]) {
    return 0 as u8;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_imp_entries[0], s);
  if (base == 0 as *u8) {
    return 0 as u8;
  }
  let eoff: i32 = pipe_imp_entry_off(idx);
  let scount: i32 = pipe_load_i32_le(base, eoff + 336);
  if (sel >= scount) {
    return 0 as u8;
  }
  let sbase: i32 = pipe_load_i32_le(base, eoff + 332);
  let abs: i32 = sbase + sel;
  if (abs < 0) {
    return 0 as u8;
  }
  if (abs >= g_pipe_imp_sel_n[s]) {
    return 0 as u8;
  }
  let nlen: i32 = pipeline_module_import_select_name_len(module, idx, sel);
  if (off >= nlen) {
    return 0 as u8;
  }
  if (off >= 64) {
    return 0 as u8;
  }
  let rows: *u8 = xlang_ptr_slot_get(&g_pipe_imp_sel_rows[0], s);
  if (rows == 0 as *u8) {
    return 0 as u8;
  }
  let b: u8 = 0;
  unsafe {
    b = rows[abs * 64 + off];
  }
  return b;
}

// ---------------------------------------------------------------------------
// wave102: asm_diag pure-owned leave (was pipeline_asm_diag.c host-cc residual).
// G.7 product authority for XLANG_ASM_START_FUNC skip + BODY/FUNC_TRACE stderr.
// PLATFORM: SHARED - dual-end L2 after leave; cold twins under seed #ifndef FROM_X.
// ---------------------------------------------------------------------------

/**
 * Parse non-negative decimal digits from NUL-C string (strtol subset).
 * @param s *u8 - digit start; null -> 0 and *any_out=0
 * @param any_out *i32 - set 1 if at least one digit consumed
 * @return i32 - parsed value clamped later by caller; 0 if no digits
 * PLATFORM: SHARED - pure substitute for libc strtol on START_FUNC env.
 */
function asm_diag_parse_u_decimal(s: *u8, any_out: *i32): i32 {
  unsafe {
    any_out[0] = 0;
  }
  if (s == 0 as *u8) {
    return 0;
  }
  let v: i32 = 0;
  let i: i32 = 0;
  while (i < 16) {
    let c: u8 = 0;
    unsafe {
      c = s[i];
    }
    if (c < 48) {
      break;
    }
    if (c > 57) {
      break;
    }
    unsafe {
      any_out[0] = 1;
    }
    // Cap intermediate growth before caller clamp at 100000.
    if (v > 1000000) {
      return 1000000;
    }
    v = v * 10 + (c as i32 - 48);
    i = i + 1;
  }
  return v;
}

/**
 * Env truthy: non-null, non-empty, first byte not '0'.
 * @param e *u8 - getenv result; null -> 0
 * @return i32 - 1 truthy, 0 otherwise
 * PLATFORM: SHARED - matches historical C `e && e[0] && e[0] != '0'`.
 */
function asm_diag_env_truthy(e: *u8): i32 {
  if (e == 0 as *u8) {
    return 0;
  }
  let c: u8 = 0;
  unsafe {
    c = e[0];
  }
  if (c == 0) {
    return 0;
  }
  if (c == 48) {
    return 0;
  }
  return 1;
}

/**
 * Write buf[0..n) to stderr (fd 2). No-op on n<=0 or null.
 * @param buf *u8 - bytes
 * @param n i32 - byte count
 * PLATFORM: SHARED - hosted write; ignores write errors (debug traces).
 */
function asm_diag_stderr_write(buf: *u8, n: i32): void {
  if (buf == 0 as *u8) {
    return;
  }
  if (n <= 0) {
    return;
  }
  unsafe {
    write(2, buf, n as i64);
  }
}

/**
 * Read XLANG_ASM_START_FUNC: skip first N funcs in module emit (debug bisect).
 * build_xlang_asm must env -u XLANG_ASM_START_FUNC; if N>=num_funcs the module
 * emits only an empty __text stub. XLANG_ASM_ALLOW_START_FUNC=1 enables skip
 * even under build ENTRY_MODULE_ONLY + BUILD_SKIP_TYPECK (manual bisect).
 * @return i32 - N in [0,100000]; 0 when unset/invalid/gated off
 * wave102 pure: G.7 single product authority (historical pipeline_asm_diag.c).
 * PLATFORM: SHARED - sole provider after asm_diag leave; backend.x + mega_body call.
 */
#[no_mangle]
export function asm_diag_start_func_skip(): i32 {
  let e: *u8 = 0 as *u8;
  let allow: *u8 = 0 as *u8;
  unsafe {
    e = link_abi_getenv("XLANG_ASM_START_FUNC");
    allow = link_abi_getenv("XLANG_ASM_ALLOW_START_FUNC");
  }
  if (e == 0 as *u8) {
    return 0;
  }
  let e0: u8 = 0;
  unsafe {
    e0 = e[0];
  }
  if (e0 == 0) {
    return 0;
  }
  // Match C: without ALLOW, BUILD_SKIP_TYPECK + ENTRY_MODULE_ONLY disables skip.
  let allow_on: i32 = asm_diag_env_truthy(allow);
  if (allow_on == 0) {
    let skip_e: *u8 = 0 as *u8;
    let em: *u8 = 0 as *u8;
    unsafe {
      skip_e = link_abi_getenv("XLANG_ASM_BUILD_SKIP_TYPECK");
      em = link_abi_getenv("XLANG_ASM_ENTRY_MODULE_ONLY");
    }
    if (asm_diag_env_truthy(skip_e) != 0) {
      if (asm_diag_env_truthy(em) != 0) {
        return 0;
      }
    }
  }
  let any: i32[1] = [0];
  let v: i32 = asm_diag_parse_u_decimal(e, &any[0]);
  if (any[0] == 0) {
    return 0;
  }
  if (v < 0) {
    return 0;
  }
  if (v > 100000) {
    return 100000;
  }
  return v;
}

/**
 * XLANG_ASM_BODY_TRACE=1: print block scale for body_ref (fill/emit crash bisect).
 * @param arena *u8 - ASTArena; null -> no-op
 * @param body_ref i32 - block ref; <=0 -> no-op
 * wave102 pure: G.7 authority (historical pipeline_asm_diag.c). Uses write(2)
 * + pipe_diag_msg_append_* (no libc fprintf). Invalid refs print "invalid".
 * PLATFORM: SHARED - sole provider after asm_diag leave.
 */
#[no_mangle]
export function asm_diag_trace_func_body(arena: *u8, body_ref: i32): void {
  if (arena == 0 as *u8) {
    return;
  }
  if (body_ref <= 0) {
    return;
  }
  let trace: *u8 = 0 as *u8;
  unsafe {
    trace = link_abi_getenv("XLANG_ASM_BODY_TRACE");
  }
  if (asm_diag_env_truthy(trace) == 0) {
    return;
  }
  let msg: u8[256];
  let cap: i32 = 256;
  let at: i32 = 0;
  // Heuristic invalid: all zero metrics + final_expr 0 is possible for empty
  // blocks; C used block_at null. Pure has no block_at - print metrics always.
  let n_const: i32 = 0;
  let n_let: i32 = 0;
  let n_loop: i32 = 0;
  let n_for: i32 = 0;
  let n_if: i32 = 0;
  let n_so: i32 = 0;
  let fin: i32 = 0;
  unsafe {
    n_const = ast_ast_block_num_consts(arena, body_ref);
    n_let = ast_ast_block_num_lets(arena, body_ref);
    n_loop = ast_ast_block_num_loops(arena, body_ref);
    n_for = ast_ast_block_num_for_loops(arena, body_ref);
    n_if = ast_ast_block_num_if_stmts(arena, body_ref);
    n_so = ast_ast_block_num_stmt_order(arena, body_ref);
    fin = ast_ast_block_final_expr_ref(arena, body_ref);
  }
  at = pipe_diag_msg_append_cstr(&msg[0], cap, at, "asm_body: ref=");
  at = pipe_diag_msg_append_i32(&msg[0], cap, at, body_ref);
  at = pipe_diag_msg_append_cstr(&msg[0], cap, at, " consts=");
  at = pipe_diag_msg_append_i32(&msg[0], cap, at, n_const);
  at = pipe_diag_msg_append_cstr(&msg[0], cap, at, " lets=");
  at = pipe_diag_msg_append_i32(&msg[0], cap, at, n_let);
  at = pipe_diag_msg_append_cstr(&msg[0], cap, at, " loops=");
  at = pipe_diag_msg_append_i32(&msg[0], cap, at, n_loop);
  at = pipe_diag_msg_append_cstr(&msg[0], cap, at, " for=");
  at = pipe_diag_msg_append_i32(&msg[0], cap, at, n_for);
  at = pipe_diag_msg_append_cstr(&msg[0], cap, at, " ifs=");
  at = pipe_diag_msg_append_i32(&msg[0], cap, at, n_if);
  at = pipe_diag_msg_append_cstr(&msg[0], cap, at, " stmt_order=");
  at = pipe_diag_msg_append_i32(&msg[0], cap, at, n_so);
  at = pipe_diag_msg_append_cstr(&msg[0], cap, at, " final_expr=");
  at = pipe_diag_msg_append_i32(&msg[0], cap, at, fin);
  at = pipe_diag_msg_append_cstr(&msg[0], cap, at, "\n");
  asm_diag_stderr_write(&msg[0], at);
}

/**
 * XLANG_ASM_BODY_TRACE=1: print body_ref only.
 * @param body_ref i32 - block ref value to print
 * wave102 pure: G.7 authority (historical pipeline_asm_diag.c).
 * PLATFORM: SHARED - sole provider after asm_diag leave.
 */
#[no_mangle]
export function asm_diag_trace_body_ref(body_ref: i32): void {
  let trace: *u8 = 0 as *u8;
  unsafe {
    trace = link_abi_getenv("XLANG_ASM_BODY_TRACE");
  }
  if (asm_diag_env_truthy(trace) == 0) {
    return;
  }
  let msg: u8[64];
  let at: i32 = 0;
  at = pipe_diag_msg_append_cstr(&msg[0], 64, at, "asm_body_ref=");
  at = pipe_diag_msg_append_i32(&msg[0], 64, at, body_ref);
  at = pipe_diag_msg_append_cstr(&msg[0], 64, at, "\n");
  asm_diag_stderr_write(&msg[0], at);
}

/**
 * XLANG_ASM_BODY_TRACE=1: emit phase marker (1=fill 2=prologue 3=emit_body).
 * @param phase i32 - phase id
 * wave102 pure: G.7 authority (historical pipeline_asm_diag.c).
 * PLATFORM: SHARED - sole provider after asm_diag leave.
 */
#[no_mangle]
export function asm_diag_trace_emit_phase(phase: i32): void {
  let trace: *u8 = 0 as *u8;
  unsafe {
    trace = link_abi_getenv("XLANG_ASM_BODY_TRACE");
  }
  if (asm_diag_env_truthy(trace) == 0) {
    return;
  }
  let msg: u8[64];
  let at: i32 = 0;
  at = pipe_diag_msg_append_cstr(&msg[0], 64, at, "asm_emit_phase=");
  at = pipe_diag_msg_append_i32(&msg[0], 64, at, phase);
  at = pipe_diag_msg_append_cstr(&msg[0], 64, at, "\n");
  asm_diag_stderr_write(&msg[0], at);
}

/**
 * XLANG_ASM_FUNC_TRACE=1: print optional func index + name bytes to stderr.
 * @param func_idx i32 - >=0 prints "#N "; <0 omits index (trace_func wrapper)
 * @param name *u8 - name bytes; null or name_len<=0 -> no-op
 * @param name_len i32 - byte count; capped at 64 in output
 * wave102 pure: G.7 authority (historical pipeline_asm_diag.c).
 * PLATFORM: SHARED - sole provider after asm_diag leave.
 */
#[no_mangle]
export function asm_diag_trace_func_idx(func_idx: i32, name: *u8, name_len: i32): void {
  if (name == 0 as *u8) {
    return;
  }
  if (name_len <= 0) {
    return;
  }
  let trace: *u8 = 0 as *u8;
  unsafe {
    trace = link_abi_getenv("XLANG_ASM_FUNC_TRACE");
  }
  if (asm_diag_env_truthy(trace) == 0) {
    return;
  }
  let msg: u8[128];
  let at: i32 = 0;
  if (func_idx >= 0) {
    at = pipe_diag_msg_append_cstr(&msg[0], 128, at, "asm_trace: #");
    at = pipe_diag_msg_append_i32(&msg[0], 128, at, func_idx);
    at = pipe_diag_msg_append_cstr(&msg[0], 128, at, " ");
  } else {
    at = pipe_diag_msg_append_cstr(&msg[0], 128, at, "asm_trace: ");
  }
  let n: i32 = name_len;
  if (n > 64) {
    n = 64;
  }
  at = pipe_diag_msg_append_name(&msg[0], 128, at, name, n);
  at = pipe_diag_msg_append_cstr(&msg[0], 128, at, "\n");
  asm_diag_stderr_write(&msg[0], at);
}

/**
 * XLANG_ASM_FUNC_TRACE=1 wrapper: print name without func index.
 * @param name *u8 - name bytes
 * @param name_len i32 - byte count
 * wave102 pure: G.7 authority (historical pipeline_asm_diag.c).
 * PLATFORM: SHARED - sole provider after asm_diag leave.
 */
#[no_mangle]
export function asm_diag_trace_func(name: *u8, name_len: i32): void {
  asm_diag_trace_func_idx(0 - 1, name, name_len);
}

// ---------------------------------------------------------------------------
// wave103: lsp_diag pure-owned leave (was pipeline_lsp_diag.c host-cc residual).
// G.7 product authority for LSP parse/typeck orch faces used by parse_orch
// _impl_c and pipeline.x. Large-stack path reuses driver_run_thread_on_large_stack
// + Cap-fn-ptr (fn as *u8), same pattern as pipeline_run_x_thread_fn.
// PLATFORM: SHARED - dual-end L2 after leave; cold twins under seed #ifndef FROM_X.
// ---------------------------------------------------------------------------

/**
 * LSP: load/sync direct import deps then typeck (typeck fail maps to -3).
 * @param module *u8 - AST module; null -> -1
 * @param arena *u8 - AST arena; null -> -1
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @return i32 - 0 ok; load_rc on load fail; typeck fail_mapped (-3) on typeck fail
 * wave103 pure: G.7 single product authority (historical pipeline_lsp_diag.c).
 * PLATFORM: SHARED - sole provider after lsp_diag leave.
 */
#[no_mangle]
export function lsp_diag_typeck_after_load_c(module: *u8, arena: *u8, ctx: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  let load_rc: i32 = 0;
  unsafe {
    load_rc = pipeline_load_and_sync_direct_import_deps_c(module, arena, ctx);
  }
  if (load_rc != 0) {
    return load_rc;
  }
  let tk: i32 = 0;
  unsafe {
    tk = pipeline_typeck_parsed_module_c(module, arena, ctx, 0 - 3);
  }
  return tk;
}

/**
 * LSP entry parse only: same path as pipeline_parse_set_main_from_buf_c.
 * @param module *u8 - AST module
 * @param arena *u8 - AST arena
 * @param source_data *u8 - source bytes
 * @param source_len i32 - byte length
 * @return i32 - parse status from set_main_from_buf_c
 * wave103 pure: G.7 single product authority (historical pipeline_lsp_diag.c).
 * PLATFORM: SHARED - sole provider after lsp_diag leave.
 */
#[no_mangle]
export function lsp_diag_parse_entry_buf_c(module: *u8, arena: *u8, source_data: *u8, source_len: i32): i32 {
  let rc: i32 = 0;
  unsafe {
    rc = pipeline_parse_set_main_from_buf_c(module, arena, source_data, source_len);
  }
  return rc;
}

/**
 * Core LSP path body: set_main + load/sync + typeck (fail_mapped -3).
 * @param module *u8 - AST module; null -> -2
 * @param arena *u8 - AST arena; null -> -2
 * @param source_data *u8 - source bytes; null -> -2
 * @param source_len i32 - must be > 0 else -2
 * @param ctx *u8 - PipelineDepCtx; null -> -2
 * @return i32 - 0 ok; parse/load rc; typeck -3
 * wave103 pure: G.7 body for large-stack and direct call paths.
 * PLATFORM: SHARED - sole provider after lsp_diag leave.
 */
function lsp_diag_parse_typeck_buf_impl(module: *u8, arena: *u8, source_data: *u8, source_len: i32, ctx: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 2;
  }
  if (arena == 0 as *u8) {
    return 0 - 2;
  }
  if (ctx == 0 as *u8) {
    return 0 - 2;
  }
  if (source_data == 0 as *u8) {
    return 0 - 2;
  }
  if (source_len <= 0) {
    return 0 - 2;
  }
  let parse_rc: i32 = 0;
  unsafe {
    parse_rc = pipeline_parse_set_main_from_buf_c(module, arena, source_data, source_len);
  }
  if (parse_rc != 0) {
    return parse_rc;
  }
  let load_rc: i32 = 0;
  unsafe {
    load_rc = pipeline_load_and_sync_direct_import_deps_c(module, arena, ctx);
  }
  if (load_rc != 0) {
    return load_rc;
  }
  let tk: i32 = 0;
  unsafe {
    tk = pipeline_typeck_parsed_module_c(module, arena, ctx, 0 - 3);
  }
  return tk;
}

/**
 * pthread start_routine for LSP parse+typeck on large stack.
 * Pack LP64 (48B): module@0 arena@8 source_data@16 source_len@24 ctx@32 result@40.
 * @param arg *u8 - pack base; null -> null
 * @return *u8 - always null (pthread contract)
 * wave103 pure: Cap-fn-ptr surface via (fn as *u8) for driver large-stack.
 * PLATFORM: SHARED LP64 little-endian.
 */
#[no_mangle]
export function lsp_diag_parse_typeck_thread_fn(arg: *u8): *u8 {
  if (arg == 0 as *u8) {
    return 0 as *u8;
  }
  let module: *u8 = pipe_load_ptr_slot(arg, 0);
  let arena: *u8 = pipe_load_ptr_slot(arg, 1);
  let source_data: *u8 = pipe_load_ptr_slot(arg, 2);
  let source_len: i32 = xlang_size_slot_get(arg, 3) as i32;
  let ctx: *u8 = pipe_load_ptr_slot(arg, 4);
  let rc: i32 = 0;
  unsafe {
    rc = lsp_diag_parse_typeck_buf_impl(module, arena, source_data, source_len, ctx);
  }
  // result i32 at byte 40 = slot 5; write full LE cell (pad ok).
  xlang_size_slot_set(arg, 5, rc as i64);
  return 0 as *u8;
}

/**
 * Cap-fn-ptr surface: opaque address of lsp_diag_parse_typeck_thread_fn.
 * @return *u8 - function address as opaque byte pointer
 * wave103 pure: G.7 Cap-fn-ptr (same wave84/wave100 pattern as pipeline_run_x).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function lsp_diag_parse_typeck_thread_fn_ptr(): *u8 {
  return (lsp_diag_parse_typeck_thread_fn as *u8);
}

/**
 * Full LSP path: parse entry + load deps + typeck on 256MiB stack when needed.
 * If already on large-stack thread, run impl directly (avoid nested stack alloc).
 * Else pack args, run thread_fn via driver_run_thread_on_large_stack; if result
 * still sentinel -99 (pthread create failed), fall back to current-thread impl.
 * @param module *u8 - AST module
 * @param arena *u8 - AST arena
 * @param source_data *u8 - source bytes
 * @param source_len i32 - byte length
 * @param ctx *u8 - PipelineDepCtx
 * @return i32 - 0 ok; parse/load/typeck status; -2 null/empty; -99 should not escape
 * wave103 pure: G.7 single product authority (historical pipeline_lsp_diag.c).
 * PLATFORM: SHARED - sole provider after lsp_diag leave; Alpine/ARM64 deep typeck.
 */
#[no_mangle]
export function lsp_diag_parse_typeck_buf_c(module: *u8, arena: *u8, source_data: *u8, source_len: i32, ctx: *u8): i32 {
  let already: i32 = 0;
  unsafe {
    already = driver_is_large_stack_thread();
  }
  if (already != 0) {
    return lsp_diag_parse_typeck_buf_impl(module, arena, source_data, source_len, ctx);
  }
  // LP64 pack 48B matching historical LspDiagParseTypeckArgs.
  let pack: u8[48];
  let zi: i32 = 0;
  while (zi < 48) {
    unsafe {
      pack[zi] = 0;
    }
    zi = zi + 1;
  }
  pipe_store_ptr_slot(&pack[0], 0, module);
  pipe_store_ptr_slot(&pack[0], 1, arena);
  pipe_store_ptr_slot(&pack[0], 2, source_data);
  xlang_size_slot_set(&pack[0], 3, source_len as i64);
  pipe_store_ptr_slot(&pack[0], 4, ctx);
  // result sentinel -99 at slot 5 (@40).
  xlang_size_slot_set(&pack[0], 5, 0 - 99);
  let fn: *u8 = lsp_diag_parse_typeck_thread_fn_ptr();
  unsafe {
    driver_run_thread_on_large_stack(fn, &pack[0]);
  }
  let res: i32 = xlang_size_slot_get(&pack[0], 5) as i32;
  if (res == 0 - 99) {
    return lsp_diag_parse_typeck_buf_impl(module, arena, source_data, source_len, ctx);
  }
  return res;
}

// ---------------------------------------------------------------------------
// wave104: emit_sidecar pure-owned leave (was pipeline_emit_sidecar.c).
// G.7 product authority for driver -L lib_root pool + asm qual field-layer stack.
// Fixed-cap BSS (no GrowVec / no host-cc mega-TU). Cold twins under seed #ifndef FROM_X.
// PLATFORM: SHARED - dual-end L2 after leave; directory-check release still required.
// ---------------------------------------------------------------------------

/**
 * Find DriverEmit sidecar slot for `state`, optionally allocate free slot.
 * @param state *u8 - compile/emit state key; null -> -1
 * @param create i32 - non-zero to claim first free slot when missing
 * @return i32 - slot index 0..63, or -1 if null / full / not found without create
 * wave104 pure helper. PLATFORM: SHARED - 64-slot table ≡ MAX_DRIVER_EMIT_SIDECARS.
 */
function emit_sc_find(state: *u8, create: i32): i32 {
  if (state == 0 as *u8) {
    return 0 - 1;
  }
  let i: i32 = 0;
  while (i < 64) {
    if (g_pipe_emit_used[i] != 0) {
      let st: *u8 = xlang_ptr_slot_get(&g_pipe_emit_state[0], i);
      if (st == state) {
        return i;
      }
    }
    i = i + 1;
  }
  if (create == 0) {
    return 0 - 1;
  }
  i = 0;
  while (i < 64) {
    if (g_pipe_emit_used[i] == 0) {
      g_pipe_emit_used[i] = 1;
      xlang_ptr_slot_set(&g_pipe_emit_state[0], i, state);
      g_pipe_emit_n[i] = 0;
      return i;
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Clear -L lib_root list for `state` (keep slot occupied).
 * @param state *u8 - emit state key; null / unknown -> no-op
 * @return void
 * wave104 pure: G.7 single product authority (historical driver_emit_lib_root_reset).
 * PLATFORM: SHARED - sole provider after emit_sidecar leave.
 */
#[no_mangle]
export function driver_emit_lib_root_reset(state: *u8): void {
  let s: i32 = emit_sc_find(state, 0);
  if (s < 0) {
    return;
  }
  g_pipe_emit_n[s] = 0;
}

/**
 * Release DriverEmit sidecar for `state` (mark slot free so table does not exhaust).
 * Must be called before free(state) for any heap compile/emit state that used append.
 * @param state *u8 - emit state key; null -> no-op
 * @return void
 * wave104 pure: G.7 single product authority (historical driver_emit_lib_root_release).
 * PLATFORM: SHARED - directory check multi-file; dual-host after change.
 */
#[no_mangle]
export function driver_emit_lib_root_release(state: *u8): void {
  let s: i32 = emit_sc_find(state, 0);
  if (s < 0) {
    return;
  }
  g_pipe_emit_used[s] = 0;
  g_pipe_emit_n[s] = 0;
  xlang_ptr_slot_set(&g_pipe_emit_state[0], s, 0 as *u8);
}

/**
 * Append one -L lib root path for `state` (create slot on first use).
 * @param state *u8 - emit state key; null -> -1
 * @param path *u8 - path bytes (not required NUL-terminated); null -> -1
 * @param len i32 - byte count; must be > 0; stored len clamped to 255
 * @return i32 - root index on success; -1 on null / full table / full roots (32)
 * wave104 pure: G.7 single product authority (historical driver_emit_append_lib_root).
 * PLATFORM: SHARED - path row width 256; cap 32 roots/slot.
 */
#[no_mangle]
export function driver_emit_append_lib_root(state: *u8, path: *u8, len: i32): i32 {
  if (state == 0 as *u8) {
    return 0 - 1;
  }
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  let s: i32 = emit_sc_find(state, 1);
  if (s < 0) {
    return 0 - 1;
  }
  let n: i32 = g_pipe_emit_n[s];
  if (n >= 32) {
    return 0 - 1;
  }
  let clen: i32 = len;
  if (clen > 255) {
    clen = 255;
  }
  let base: i32 = (s * 32 + n) * 256;
  let k: i32 = 0;
  while (k < 256) {
    unsafe {
      g_pipe_emit_rows[base + k] = 0;
    }
    k = k + 1;
  }
  k = 0;
  while (k < clen) {
    unsafe {
      g_pipe_emit_rows[base + k] = path[k];
    }
    k = k + 1;
  }
  g_pipe_emit_lens[s * 32 + n] = clen;
  g_pipe_emit_n[s] = n + 1;
  return n;
}

/**
 * Count -L lib roots for `state`.
 * @param state *u8 - emit state key; null / unknown -> 0
 * @return i32 - root count in 0..32
 * wave104 pure: G.7 single product authority (historical driver_emit_lib_root_count).
 * PLATFORM: SHARED - sole provider after emit_sidecar leave.
 */
#[no_mangle]
export function driver_emit_lib_root_count(state: *u8): i32 {
  let s: i32 = emit_sc_find(state, 0);
  if (s < 0) {
    return 0;
  }
  return g_pipe_emit_n[s];
}

/**
 * Length of root i for `state`.
 * @param state *u8 - emit state key
 * @param i i32 - root index; OOB -> 0
 * @return i32 - stored byte length, or 0
 * wave104 pure: G.7 single product authority (historical driver_emit_lib_root_len).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function driver_emit_lib_root_len(state: *u8, i: i32): i32 {
  if (i < 0) {
    return 0;
  }
  let s: i32 = emit_sc_find(state, 0);
  if (s < 0) {
    return 0;
  }
  if (i >= g_pipe_emit_n[s]) {
    return 0;
  }
  return g_pipe_emit_lens[s * 32 + i];
}

/**
 * Copy root i path into dst (zero-fill; clamp to cap-1; no forced trailing NUL beyond zero).
 * @param state *u8 - emit state key
 * @param i i32 - root index
 * @param dst *u8 - destination; null / cap<=0 -> no-op
 * @param cap i32 - destination capacity including room for NUL zero-fill
 * @return void
 * wave104 pure: G.7 single product authority (historical driver_emit_lib_root_copy).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function driver_emit_lib_root_copy(state: *u8, i: i32, dst: *u8, cap: i32): void {
  if (dst == 0 as *u8) {
    return;
  }
  if (cap <= 0) {
    return;
  }
  unsafe {
    memset(dst, 0, cap as usize);
  }
  if (i < 0) {
    return;
  }
  let s: i32 = emit_sc_find(state, 0);
  if (s < 0) {
    return;
  }
  if (i >= g_pipe_emit_n[s]) {
    return;
  }
  let n: i32 = g_pipe_emit_lens[s * 32 + i];
  if (n >= cap) {
    n = cap - 1;
  }
  let base: i32 = (s * 32 + i) * 256;
  let k: i32 = 0;
  while (k < n) {
    unsafe {
      dst[k] = g_pipe_emit_rows[base + k];
    }
    k = k + 1;
  }
}

/**
 * Clear asm import-qualified field-layer stack.
 * @return void
 * wave104 pure: G.7 single product authority (historical asm_qual_sym_layer_reset).
 * PLATFORM: SHARED - typeck import path layer walk.
 */
#[no_mangle]
export function asm_qual_sym_layer_reset(): void {
  g_pipe_qual_n = 0;
}

/**
 * Push one field-name layer (clamped to 63 bytes into 64B row).
 * @param bytes *u8 - field name bytes; null -> -1
 * @param len i32 - byte count; must be > 0
 * @return i32 - layer index on success; -1 on null / empty / full (32)
 * wave104 pure: G.7 single product authority (historical asm_qual_sym_layer_push).
 * PLATFORM: SHARED - clamp 63 (typeck layer_buf[64]); historical C allowed 127 into 64B row.
 */
#[no_mangle]
export function asm_qual_sym_layer_push(bytes: *u8, len: i32): i32 {
  if (bytes == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  if (g_pipe_qual_n >= 32) {
    return 0 - 1;
  }
  let n: i32 = len;
  if (n > 63) {
    n = 63;
  }
  let idx: i32 = g_pipe_qual_n;
  let base: i32 = idx * 64;
  let k: i32 = 0;
  while (k < 64) {
    unsafe {
      g_pipe_qual_rows[base + k] = 0;
    }
    k = k + 1;
  }
  k = 0;
  while (k < n) {
    unsafe {
      g_pipe_qual_rows[base + k] = bytes[k];
    }
    k = k + 1;
  }
  g_pipe_qual_lens[idx] = n;
  g_pipe_qual_n = idx + 1;
  return idx;
}

/**
 * Current field-layer count.
 * @return i32 - depth in 0..32
 * wave104 pure: G.7 single product authority (historical asm_qual_sym_layer_count).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_qual_sym_layer_count(): i32 {
  return g_pipe_qual_n;
}

/**
 * Length of layer i.
 * @param i i32 - layer index; OOB -> 0
 * @return i32 - stored byte length, or 0
 * wave104 pure: G.7 single product authority (historical asm_qual_sym_layer_len).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_qual_sym_layer_len(i: i32): i32 {
  if (i < 0) {
    return 0;
  }
  if (i >= g_pipe_qual_n) {
    return 0;
  }
  return g_pipe_qual_lens[i];
}

/**
 * Copy layer i name into dst (zero-fill; clamp to cap-1).
 * @param i i32 - layer index
 * @param dst *u8 - destination; null / cap<=0 -> no-op
 * @param cap i32 - capacity including NUL room
 * @return void
 * wave104 pure: G.7 single product authority (historical asm_qual_sym_layer_copy).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_qual_sym_layer_copy(i: i32, dst: *u8, cap: i32): void {
  if (dst == 0 as *u8) {
    return;
  }
  if (cap <= 0) {
    return;
  }
  unsafe {
    memset(dst, 0, cap as usize);
  }
  if (i < 0) {
    return;
  }
  if (i >= g_pipe_qual_n) {
    return;
  }
  let n: i32 = g_pipe_qual_lens[i];
  if (n >= cap) {
    n = cap - 1;
  }
  let base: i32 = i * 64;
  let k: i32 = 0;
  while (k < n) {
    unsafe {
      dst[k] = g_pipe_qual_rows[base + k];
    }
    k = k + 1;
  }
}

// ---------------------------------------------------------------------------
// wave105: resolve_path pure-owned leave (was pipeline_resolve_path.c).
// G.7 product authority for path_append_*_c / resolve probe / flat_import /
//   off-sidecar / codegen_out_buf_len|set_len / resolve_path_x_impl_c|_c.
// Product surfaces try_one_lib_root / try_entry_dir remain pipeline.x strong
//   (thin -> these pure _c helpers). Cold twins under seed #ifndef FROM_X.
// PLATFORM: SHARED - dual-end L2 after leave; preserves historical probe bytes
//   ('.' 46 + 115 + 117 + NUL and /mod + same) matching host-cc contract.
// ---------------------------------------------------------------------------

/**
 * Append buf[0..len) into ctx.path_buf at off; clamp path_buf end at 508.
 * @param ctx *u8 - PipelineDepCtx; null -> off unchanged
 * @param off i32 - write cursor into path_buf
 * @param buf *u8 - source bytes; null -> off unchanged
 * @param len i32 - byte count; <=0 -> off unchanged
 * @return i32 - new off after copy
 * wave105 pure: G.7 single product authority (historical path_append_from_buf_256_c).
 * PLATFORM: SHARED - sole provider after resolve_path leave.
 */
#[no_mangle]
export function pipeline_path_append_from_buf_256_c(ctx: *u8, off: i32, buf: *u8, len: i32): i32 {
  if (ctx == 0 as *u8) {
    return off;
  }
  if (buf == 0 as *u8) {
    return off;
  }
  if (len <= 0) {
    return off;
  }
  let k: i32 = 0;
  let o: i32 = off;
  while (k < len) {
    if (o >= 508) {
      break;
    }
    let b: u8 = 0 as u8;
    unsafe {
      b = buf[k];
      pipeline_dep_ctx_set_path_buf_byte(ctx, o, b);
    }
    o = o + 1;
    k = k + 1;
  }
  return o;
}

/**
 * Same as path_append_from_buf_256_c (caller guarantees buf capacity).
 * @param ctx *u8 - PipelineDepCtx
 * @param off i32 - write cursor
 * @param buf *u8 - source bytes
 * @param len i32 - byte count
 * @return i32 - new off
 * wave105 pure: G.7 single authority (historical path_append_from_buf_512_c).
 * PLATFORM: SHARED - sole provider after resolve_path leave.
 */
#[no_mangle]
export function pipeline_path_append_from_buf_512_c(ctx: *u8, off: i32, buf: *u8, len: i32): i32 {
  return pipeline_path_append_from_buf_256_c(ctx, off, buf, len);
}

/**
 * Append import_path with '.' (46) rewritten to '/' (47) into path_buf.
 * @param ctx *u8 - PipelineDepCtx; null -> off
 * @param off i32 - write cursor
 * @param import_path *u8 - import path bytes; null -> off
 * @param path_len i32 - byte length; <=0 -> off
 * @return i32 - new off
 * wave105 pure: G.7 single authority (historical path_append_import_path_c).
 * PLATFORM: SHARED - sole provider after resolve_path leave.
 */
#[no_mangle]
export function pipeline_path_append_import_path_c(ctx: *u8, off: i32, import_path: *u8, path_len: i32): i32 {
  if (ctx == 0 as *u8) {
    return off;
  }
  if (import_path == 0 as *u8) {
    return off;
  }
  if (path_len <= 0) {
    return off;
  }
  let k: i32 = 0;
  let o: i32 = off;
  while (k < path_len) {
    if (o >= 508) {
      break;
    }
    let b: u8 = 0 as u8;
    unsafe {
      b = import_path[k];
    }
    if (b == 46 as u8) {
      b = 47 as u8;
    }
    unsafe {
      pipeline_dep_ctx_set_path_buf_byte(ctx, o, b);
    }
    o = o + 1;
    k = k + 1;
  }
  return o;
}

/**
 * Return 1 if import_path[0..path_len) contains '.' within first 64 bytes.
 * @param import_path *u8 - import path; null -> 0
 * @param path_len i32 - length; <=0 -> 0
 * @return i32 - 1 has dot, 0 otherwise
 * wave105 pure: G.7 single authority (historical resolve_path_import_has_dot_c).
 * PLATFORM: SHARED - sole provider after resolve_path leave.
 */
#[no_mangle]
export function pipeline_resolve_path_import_has_dot_c(import_path: *u8, path_len: i32): i32 {
  if (import_path == 0 as *u8) {
    return 0;
  }
  if (path_len <= 0) {
    return 0;
  }
  let k: i32 = 0;
  while (k < path_len) {
    if (k >= 64) {
      break;
    }
    let b: u8 = 0 as u8;
    unsafe {
      b = import_path[k];
    }
    if (b == 46 as u8) {
      return 1;
    }
    k = k + 1;
  }
  return 0;
}

/**
 * Read CodegenOutBuf.length (i32 LE immediately after data[9437184]).
 * @param out *u8 - opaque CodegenOutBuf*; null -> 0
 * @return i32 - length field
 * wave105 pure: G.7 single authority (historical codegen_out_buf_len in resolve_path.c).
 * Layout ≡ codegen.x CodegenOutBuf { data: u8[9437184]; length: i32 }.
 * PLATFORM: SHARED - sole provider after resolve_path leave; used by elf/codegen host-cc.
 */
#[no_mangle]
export function codegen_out_buf_len(out: *u8): i32 {
  if (out == 0 as *u8) {
    return 0;
  }
  // PIPELINE_CODEGEN_OUTBUF_CAP
  return pipe_load_i32_le(out, 9437184);
}

/**
 * Write CodegenOutBuf.length (clamp n < 0 -> 0).
 * @param out *u8 - opaque CodegenOutBuf*; null -> no-op
 * @param n i32 - new length
 * @return void
 * wave105 pure: G.7 single authority (historical codegen_out_buf_set_len).
 * PLATFORM: SHARED - sole provider after resolve_path leave.
 */
#[no_mangle]
export function codegen_out_buf_set_len(out: *u8, n: i32): void {
  if (out == 0 as *u8) {
    return;
  }
  let v: i32 = n;
  if (v < 0) {
    v = 0;
  }
  pipe_store_i32_le(out, 9437184, v);
}

/**
 * Read resolve-path orchestration off sidecar.
 * @return i32 - last off written by prefix/append helpers
 * wave105 pure: G.7 single authority (historical last_off_get_c).
 * PLATFORM: SHARED - sole provider after resolve_path leave.
 */
#[no_mangle]
export function pipeline_resolve_path_last_off_get_c(): i32 {
  return g_pipe_resolve_off;
}

/**
 * Probe path_buf at off with historical ".su" then "/mod.su" open_read (host-cc contract).
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @param off i32 - suffix write position
 * @return i32 - 0 if open_read succeeds, -1 otherwise
 * wave105 pure helper. PLATFORM: SHARED - byte sequence matches former host-cc leaf.
 */
function resolve_path_probe_dot_x_and_mod(ctx: *u8, off: i32): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (off + 4 <= 512) {
    unsafe {
      pipeline_dep_ctx_set_path_buf_byte(ctx, off, 46 as u8);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 1, 115 as u8);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 2, 117 as u8);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 3, 0 as u8);
    }
    let path: *u8 = 0 as *u8;
    let fd: i32 = 0 - 1;
    unsafe {
      path = pipeline_dep_ctx_path_buf_ptr(ctx);
      fd = std_fs_fs_open_read(path);
    }
    if (fd >= 0) {
      unsafe {
        std_fs_fs_close(fd);
      }
      return 0;
    }
    if (off + 8 <= 512) {
      unsafe {
        pipeline_dep_ctx_set_path_buf_byte(ctx, off, 47 as u8);
        pipeline_dep_ctx_set_path_buf_byte(ctx, off + 1, 109 as u8);
        pipeline_dep_ctx_set_path_buf_byte(ctx, off + 2, 111 as u8);
        pipeline_dep_ctx_set_path_buf_byte(ctx, off + 3, 100 as u8);
        pipeline_dep_ctx_set_path_buf_byte(ctx, off + 4, 46 as u8);
        pipeline_dep_ctx_set_path_buf_byte(ctx, off + 5, 115 as u8);
        pipeline_dep_ctx_set_path_buf_byte(ctx, off + 6, 117 as u8);
        pipeline_dep_ctx_set_path_buf_byte(ctx, off + 7, 0 as u8);
      }
      unsafe {
        path = pipeline_dep_ctx_path_buf_ptr(ctx);
        fd = std_fs_fs_open_read(path);
      }
      if (fd >= 0) {
        unsafe {
          std_fs_fs_close(fd);
        }
        return 0;
      }
    }
  }
  return 0 - 1;
}

/**
 * Export surface for pipeline.x resolve_path_probe_dot_x_and_mod thin.
 * @param ctx *u8 - PipelineDepCtx
 * @param off i32 - suffix position
 * @return i32 - 0 ok open, -1 fail
 * wave105 pure: G.7 single authority (historical probe_export_c).
 * PLATFORM: SHARED - sole provider after resolve_path leave.
 */
#[no_mangle]
export function pipeline_resolve_path_probe_export_c(ctx: *u8, off: i32): i32 {
  return resolve_path_probe_dot_x_and_mod(ctx, off);
}

/**
 * Write lib_root[lib_idx] + '/' into path_buf; update off sidecar.
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @param lib_idx i32 - lib root index; <0 -> -1
 * @return i32 - new off, or -1 on null
 * wave105 pure: G.7 single authority (historical lib_root_prefix_off_c).
 * PLATFORM: SHARED - sole provider after resolve_path leave.
 */
#[no_mangle]
export function pipeline_resolve_path_lib_root_prefix_off_c(ctx: *u8, lib_idx: i32): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (lib_idx < 0) {
    return 0 - 1;
  }
  let lr_buf: u8[256] = [];
  let z: i32 = 0;
  while (z < 256) {
    lr_buf[z] = 0 as u8;
    z = z + 1;
  }
  let lr_len: i32 = 0;
  unsafe {
    lr_len = pipeline_copy_lib_root_to_buf256(ctx, lib_idx, &lr_buf[0]);
  }
  let off: i32 = 0;
  if (lr_len > 0) {
    off = pipeline_path_append_from_buf_256_c(ctx, 0, &lr_buf[0], lr_len);
  }
  if (off < 509) {
    unsafe {
      pipeline_dep_ctx_set_path_buf_byte(ctx, off, 47 as u8);
    }
    off = off + 1;
  }
  g_pipe_resolve_off = off;
  return off;
}

/**
 * Append import_path at off into path_buf; update off sidecar.
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @param off i32 - start cursor; <0 -> -1
 * @param import_path *u8 - import bytes; null -> -1
 * @param path_len i32 - length
 * @return i32 - new off, or -1
 * wave105 pure: G.7 single authority (historical path_append_import_path_sidecar_c).
 * PLATFORM: SHARED - sole provider after resolve_path leave.
 */
#[no_mangle]
export function pipeline_path_append_import_path_sidecar_c(ctx: *u8, off: i32, import_path: *u8, path_len: i32): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (import_path == 0 as *u8) {
    return 0 - 1;
  }
  if (off < 0) {
    return 0 - 1;
  }
  let new_off: i32 = pipeline_path_append_import_path_c(ctx, off, import_path, path_len);
  if (new_off < 0) {
    return 0 - 1;
  }
  g_pipe_resolve_off = new_off;
  return new_off;
}

/**
 * Write entry_dir + '/' into path_buf; update off sidecar.
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @return i32 - new off, or -1 if no entry_dir
 * wave105 pure: G.7 single authority (historical entry_dir_prefix_off_c).
 * PLATFORM: SHARED - sole provider after resolve_path leave.
 */
#[no_mangle]
export function pipeline_resolve_path_entry_dir_prefix_off_c(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  let ed_len: i32 = 0;
  unsafe {
    ed_len = pipeline_dep_ctx_entry_dir_len(ctx);
  }
  if (ed_len <= 0) {
    return 0 - 1;
  }
  let ed_buf: u8[512] = [];
  let z: i32 = 0;
  while (z < 512) {
    ed_buf[z] = 0 as u8;
    z = z + 1;
  }
  unsafe {
    pipeline_dep_ctx_entry_dir_copy(ctx, &ed_buf[0], 512);
  }
  let off: i32 = pipeline_path_append_from_buf_512_c(ctx, 0, &ed_buf[0], ed_len);
  if (off < 509) {
    unsafe {
      pipeline_dep_ctx_set_path_buf_byte(ctx, off, 47 as u8);
    }
    off = off + 1;
  }
  g_pipe_resolve_off = off;
  return off;
}

/**
 * Build flat import path lib_root/name/name.su into path_buf (host-cc contract).
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @param lib_idx i32 - lib root index; <0 -> -1
 * @param import_path *u8 - single-segment name; null -> -1
 * @param path_len i32 - name length
 * @return i32 - 0 success, -1 fail
 * wave105 pure: G.7 single authority (historical flat_import_build_path_c).
 * PLATFORM: SHARED - sole provider after resolve_path leave.
 */
#[no_mangle]
export function pipeline_flat_import_build_path_c(ctx: *u8, lib_idx: i32, import_path: *u8, path_len: i32): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (import_path == 0 as *u8) {
    return 0 - 1;
  }
  if (lib_idx < 0) {
    return 0 - 1;
  }
  if (pipeline_resolve_path_lib_root_prefix_off_c(ctx, lib_idx) < 0) {
    return 0 - 1;
  }
  let off_base: i32 = g_pipe_resolve_off;
  if (pipeline_path_append_import_path_sidecar_c(ctx, off_base, import_path, path_len) < 0) {
    return 0 - 1;
  }
  off_base = g_pipe_resolve_off;
  if (off_base < 509) {
    unsafe {
      pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 47 as u8);
    }
    g_pipe_resolve_off = off_base + 1;
  }
  if (pipeline_path_append_import_path_sidecar_c(ctx, g_pipe_resolve_off, import_path, path_len) < 0) {
    return 0 - 1;
  }
  off_base = g_pipe_resolve_off;
  if (off_base + 4 > 512) {
    return 0 - 1;
  }
  unsafe {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 46 as u8);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 1, 115 as u8);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 2, 117 as u8);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 3, 0 as u8);
  }
  return 0;
}

/**
 * open_read probe on current path_buf; close fd on success.
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @return i32 - 0 if readable, -1 otherwise
 * wave105 pure: G.7 single authority (historical flat_import_probe_open_c).
 * PLATFORM: SHARED - sole provider after resolve_path leave.
 */
#[no_mangle]
export function pipeline_flat_import_probe_open_c(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  let path: *u8 = 0 as *u8;
  let fd: i32 = 0 - 1;
  unsafe {
    path = pipeline_dep_ctx_path_buf_ptr(ctx);
    fd = std_fs_fs_open_read(path);
  }
  if (fd >= 0) {
    unsafe {
      std_fs_fs_close(fd);
    }
    return 0;
  }
  return 0 - 1;
}

/**
 * Cold/seed target for pipeline.x thin: same body as pure pipeline_resolve_path_x.
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @param import_path *u8 - import path; null -> -1
 * @param path_len i32 - length; <=0 -> -1
 * @return i32 - 0 resolved, -1 miss
 * wave105 pure: G.7 single authority (historical resolve_path_x_impl_c).
 * PLATFORM: SHARED - sole provider after resolve_path leave.
 */
#[no_mangle]
export function pipeline_resolve_path_x_impl_c(ctx: *u8, import_path: *u8, path_len: i32): i32 {
  return pipeline_resolve_path_x(ctx, import_path, path_len);
}

/**
 * C dispatch alias: call product pure pipeline_resolve_path_x.
 * @param ctx *u8 - PipelineDepCtx
 * @param import_path *u8 - import path
 * @param path_len i32 - length
 * @return i32 - 0 resolved, -1 miss
 * wave105 pure: G.7 single authority (historical resolve_path_x_c).
 * PLATFORM: SHARED - sole provider after resolve_path leave.
 */
#[no_mangle]
export function pipeline_resolve_path_x_c(ctx: *u8, import_path: *u8, path_len: i32): i32 {
  return pipeline_resolve_path_x(ctx, import_path, path_len);
}

// ---------------------------------------------------------------------------
// wave106: run_x_pipeline pure-owned leave (was pipeline_run_x_pipeline.c).
// G.7 product authority for last_rc sidecar + typeck fail map + load/typecheck
//   phase C glue + parse_entry_do_parse diags + typecheck_entry_emit skip matrix
//   + const-buf public face pipeline_run_x_pipeline -> _impl.
// Cold twins under seed #ifndef FROM_X.
// PLATFORM: SHARED - dual-end L2 after leave; DEBUG_PIPE fprintf omitted (gate
//   control-flow unchanged for non-debug product path).
// ---------------------------------------------------------------------------

/** Last pipeline phase rc sidecar (EMIT_HEAVY X avoids re-call). wave106 pure BSS. */
let g_run_x_pipeline_last_rc: i32 = 0;

/**
 * Read last run_x_pipeline phase return code sidecar.
 * @return i32 - last stored rc (0 default)
 * wave106 pure: G.7 single product authority (historical last_rc_get).
 * PLATFORM: SHARED - sole provider after run_x_pipeline leave.
 */
#[no_mangle]
export function run_x_pipeline_last_rc_get(): i32 {
  return g_run_x_pipeline_last_rc;
}

/**
 * Store last run_x_pipeline phase return code sidecar.
 * @param rc i32 - phase return code to stash
 * wave106 pure: G.7 single product authority (historical last_rc_store_c).
 * PLATFORM: SHARED - sole provider after run_x_pipeline leave.
 */
#[no_mangle]
export function run_x_pipeline_last_rc_store_c(rc: i32): void {
  g_run_x_pipeline_last_rc = rc;
}

/**
 * typeck failure unified return: emit typeck_fail diag then fail_mapped or -1.
 * @param fail_mapped i32 - non-zero preferred fail code
 * @return i32 - fail_mapped if non-zero else -1
 * wave106 pure: G.7 single product authority (historical typeck_fail_return_c).
 * PLATFORM: SHARED - sole provider after run_x_pipeline leave.
 */
#[no_mangle]
export function pipeline_typeck_fail_return_c(fail_mapped: i32): i32 {
  unsafe {
    driver_diagnostic_typeck_fail();
  }
  if (fail_mapped != 0) {
    return fail_mapped;
  }
  return 0 - 1;
}

/**
 * typeck null-check failure return (no diag); fail_mapped or -1.
 * @param fail_mapped i32 - non-zero preferred fail code
 * @return i32 - fail_mapped if non-zero else -1
 * wave106 pure: G.7 single product authority (historical typeck_null_fail_return_c).
 * PLATFORM: SHARED - sole provider after run_x_pipeline leave.
 */
#[no_mangle]
export function pipeline_typeck_null_fail_return_c(fail_mapped: i32): i32 {
  if (fail_mapped != 0) {
    return fail_mapped;
  }
  return 0 - 1;
}

/**
 * EMIT_HEAVY typecheck entry C glue: skip gate then typeck_entry_module_c.
 * @param module *u8 - AST module; null -> -1
 * @param arena *u8 - AST arena; null -> -1
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @return i32 - 0 when skip; typeck rc; -1 on null
 * wave106 pure: G.7 single product authority (historical typecheck_entry_c).
 * PLATFORM: SHARED - sole provider after run_x_pipeline leave.
 */
#[no_mangle]
export function run_x_pipeline_typecheck_entry_c(module: *u8, arena: *u8, ctx: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  let skip: i32 = 0;
  unsafe {
    skip = pipeline_should_skip_x_typeck(ctx);
  }
  if (skip != 0) {
    return 0;
  }
  let rc: i32 = 0;
  unsafe {
    rc = pipeline_typeck_entry_module_c(module, arena, ctx);
  }
  return rc;
}

/**
 * Load/sync direct import deps after parse; stash rc in last_rc sidecar.
 * @param module *u8 - AST module
 * @param arena *u8 - AST arena
 * @param ctx *u8 - PipelineDepCtx
 * @return i32 - load_and_sync rc (also stored in last_rc)
 * wave106 pure: G.7 single product authority (historical load_deps_after_parse_c).
 * PLATFORM: SHARED - sole provider after run_x_pipeline leave.
 */
#[no_mangle]
export function run_x_pipeline_load_deps_after_parse_c(module: *u8, arena: *u8, ctx: *u8): i32 {
  let rc: i32 = 0;
  unsafe {
    rc = pipeline_load_and_sync_direct_import_deps_c(module, arena, ctx);
  }
  g_run_x_pipeline_last_rc = rc;
  return g_run_x_pipeline_last_rc;
}

/**
 * Typecheck entry after load; stash rc in last_rc sidecar.
 * @param module *u8 - AST module
 * @param arena *u8 - AST arena
 * @param ctx *u8 - PipelineDepCtx
 * @return i32 - typecheck_entry_c rc (also stored in last_rc)
 * wave106 pure: G.7 single product authority (historical typecheck_after_load_c).
 * PLATFORM: SHARED - sole provider after run_x_pipeline leave.
 */
#[no_mangle]
export function run_x_pipeline_typecheck_after_load_c(module: *u8, arena: *u8, ctx: *u8): i32 {
  let rc: i32 = run_x_pipeline_typecheck_entry_c(module, arena, ctx);
  g_run_x_pipeline_last_rc = rc;
  return g_run_x_pipeline_last_rc;
}

/**
 * Entry not yet parsed: set_main_from_buf + after_entry_parse diags.
 * @param module *u8 - AST module; null -> -1
 * @param arena *u8 - AST arena; null -> -1
 * @param source_data *u8 - source bytes
 * @param source_len i64 - byte length (cast to i32 for diag/parse)
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @return i32 - 0 ok; parse_rc on fail; -1 on null
 * wave106 pure: G.7 single product authority (historical parse_entry_do_parse_c).
 * PLATFORM: SHARED - sole provider after run_x_pipeline leave.
 */
#[no_mangle]
export function run_x_pipeline_parse_entry_do_parse_c(module: *u8, arena: *u8, source_data: *u8, source_len: i64, ctx: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  let len_i32: i32 = source_len as i32;
  unsafe {
    driver_diagnostic_source_len(len_i32);
  }
  let parse_rc: i32 = 0;
  unsafe {
    parse_rc = pipeline_parse_set_main_from_buf_c(module, arena, source_data, len_i32);
  }
  if (parse_rc != 0) {
    return parse_rc;
  }
  let nf: i32 = 0;
  unsafe {
    nf = pipeline_module_num_funcs(module);
    driver_diagnostic_after_entry_parse(nf);
    driver_diagnostic_after_entry_parse_module(module);
    driver_diagnostic_entry_module(module, arena);
  }
  return 0;
}

/**
 * Entry typecheck emit: runtime skip_typeck matrix + should_skip + full typeck.
 * @param module *u8 - AST module; null -> -1
 * @param arena *u8 - AST arena; null -> -1
 * @param ctx *u8 - PipelineDepCtx; null -> -1
 * @return i32 - typeck rc; 0 when skip; -1 on null
 * wave106 pure: G.7 single product authority (historical typecheck_entry_emit_c).
 * Prefer driver_x_pipeline_skip_typeck_get over pure-only should_skip for
 *   freestanding asm -o field_access_offset fill (historical host-cc contract).
 * PLATFORM: SHARED - sole provider after run_x_pipeline leave.
 */
#[no_mangle]
export function run_x_pipeline_typecheck_entry_emit_c(module: *u8, arena: *u8, ctx: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  // DEBUG_PIPE fprintf omitted in pure (host residual); non-debug product path identical.
  let skip_tk: i32 = 0;
  unsafe {
    skip_tk = driver_x_pipeline_skip_typeck_get();
  }
  if (skip_tk != 0) {
    // User asm -o single-file: runtime still sets skip_typeck but full typeck
    // is required for field_access_offset; multi-file XLANG_ASM_BUILD_SKIP_TYPECK
    // uses dep_prerun only; user -o with imports still needs full typeck.
    let n_imp: i32 = 0;
    let skip_cg: i32 = 0;
    let asm_skip: i32 = 0;
    unsafe {
      n_imp = parser_get_module_num_imports(module);
      skip_cg = driver_x_pipeline_skip_codegen_get();
      asm_skip = pipeline_driver_asm_build_skip_typeck();
    }
    if (n_imp == 0) {
      if (skip_cg != 0) {
        let rc0: i32 = 0;
        unsafe {
          rc0 = pipeline_typeck_entry_module_c(module, arena, ctx);
        }
        return rc0;
      }
    }
    if (asm_skip != 0) {
      let rc1: i32 = 0;
      unsafe {
        rc1 = pipeline_typeck_dep_prerun_module_c(module, arena, ctx);
      }
      return rc1;
    }
    let rc2: i32 = 0;
    unsafe {
      rc2 = pipeline_typeck_entry_module_c(module, arena, ctx);
    }
    return rc2;
  }
  let skip_x: i32 = 0;
  unsafe {
    skip_x = pipeline_should_skip_x_typeck(ctx);
  }
  if (skip_x != 0) {
    return 0;
  }
  let rc3: i32 = 0;
  unsafe {
    rc3 = pipeline_typeck_entry_module_c(module, arena, ctx);
  }
  return rc3;
}

/**
 * Public runtime face: (data, len) thin wrapper over pipeline_run_x_pipeline_impl.
 * @param module *u8 - AST module
 * @param arena *u8 - AST arena
 * @param source_data *u8 - source bytes (const in C face; pure *u8)
 * @param source_len i64 - byte length (size_t in C ABI)
 * @param out_buf *u8 - CodegenOutBuf
 * @param ctx *u8 - PipelineDepCtx
 * @return i32 - pipeline_run_x_pipeline_impl rc
 * wave106 pure: G.7 single product authority (historical host-cc const cast face).
 * PLATFORM: SHARED - sole provider after run_x_pipeline leave; large_stack pthread
 *   and runtime product path call this symbol.
 */
#[no_mangle]
export function pipeline_run_x_pipeline(module: *u8, arena: *u8, source_data: *u8, source_len: i64, out_buf: *u8, ctx: *u8): i32 {
  let rc: i32 = 0;
  unsafe {
    rc = pipeline_run_x_pipeline_impl(module, arena, source_data, source_len, out_buf, ctx);
  }
  return rc;
}

// ---------------------------------------------------------------------------
// wave107: codegen residual pure-owned leave (was pipeline_codegen_residual.c).
// G.7 product authority for io.core/driver name predicates + symbol rewrites
//   (use_buf_wrapper / skip_emit_extern_io_batch_buf / should_skip_emit_func_by_name
//   / emit_seed_mega_enabled / is_submit_batch_buf_call / should_skip_emit_func_core_read_ptr
//   / asm_io_core_extern_callee_sym / io_driver_buf_call_sym / std_io_fixed_fd_emit_impl).
// Private prefix_eq replaces same-TU static codegen_name_prefix_eq from skip_force
//   (host residual skip_force still keeps its static helper for its own predicates).
// Cold twins under seed #ifndef FROM_X.
// PLATFORM: SHARED - dual-end L2 after leave.
// ---------------------------------------------------------------------------

/**
 * Prefix equality: name[0..plen) equals pfx[0..plen); requires name_len >= plen.
 * @param name *u8 - candidate name bytes; null -> 0
 * @param name_len i32 - candidate length
 * @param pfx *u8 - prefix bytes (usually string literal); null -> 0
 * @param plen i32 - prefix length
 * @return i32 - 1 match, 0 otherwise
 * wave107 pure: G.7 private helper (historical static codegen_name_prefix_eq).
 * PLATFORM: SHARED - sole pure helper for residual name tables.
 */
function cg_residual_name_prefix_eq(name: *u8, name_len: i32, pfx: *u8, plen: i32): i32 {
  if (name == 0 as *u8) {
    return 0;
  }
  if (pfx == 0 as *u8) {
    return 0;
  }
  if (name_len < plen) {
    return 0;
  }
  if (plen <= 0) {
    return 1;
  }
  let i: i32 = 0;
  while (i < plen) {
    let a: u8 = 0;
    let b: u8 = 0;
    unsafe {
      a = name[i];
      b = pfx[i];
    }
    if (a != b) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * Env truthy for XLANG_EMIT_SEED_MEGA gate (non-null, non-empty, first != '0').
 * @param e *u8 - getenv result; null -> 0
 * @return i32 - 1 truthy, 0 otherwise
 * PLATFORM: SHARED - matches residual C `e && e[0] && e[0] != '0'`.
 */
function cg_residual_env_truthy(e: *u8): i32 {
  if (e == 0 as *u8) {
    return 0;
  }
  let c: u8 = 0;
  unsafe {
    c = e[0];
  }
  if (c == 0) {
    return 0;
  }
  if (c == 48) {
    return 0;
  }
  return 1;
}

/**
 * codegen.x: append _buf for std.io.core xlang_io_* call names.
 * @param name *u8 - callee name bytes; null or name_len<=0 -> 0
 * @param name_len i32 - name length
 * @param num_args i32 - call arity (must match table)
 * @return i32 - 1 use buf wrapper, 0 otherwise
 * wave107 pure: G.7 single product authority (historical host residual).
 * PLATFORM: SHARED - sole provider after codegen_residual leave.
 */
#[no_mangle]
export function pipeline_codegen_use_buf_wrapper(name: *u8, name_len: i32, num_args: i32): i32 {
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len <= 0) {
    return 0;
  }
  if (num_args == 1) {
    if (name_len == 15) {
      if (cg_residual_name_prefix_eq(name, name_len, "xlang_io_register", 15) != 0) {
        return 1;
      }
    }
  }
  if (num_args == 2) {
    if (name_len == 18) {
      if (cg_residual_name_prefix_eq(name, name_len, "xlang_io_submit_read", 18) != 0) {
        return 1;
      }
    }
    if (name_len == 19) {
      if (cg_residual_name_prefix_eq(name, name_len, "xlang_io_submit_write", 19) != 0) {
        return 1;
      }
    }
  }
  return 0;
}

/**
 * codegen.x: skip extern emit for driver io_* batch_buf names (preamble/io.o).
 * @param name *u8 - symbol name; null -> 0
 * @param name_len i32 - length
 * @return i32 - 1 skip, 0 otherwise
 * wave107 pure: G.7 single product authority.
 * PLATFORM: SHARED - sole provider after codegen_residual leave.
 */
#[no_mangle]
export function pipeline_codegen_skip_emit_extern_io_batch_buf(name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len == 17) {
    if (cg_residual_name_prefix_eq(name, name_len, "io_read_batch_buf", 17) != 0) {
      return 1;
    }
  }
  if (name_len == 18) {
    if (cg_residual_name_prefix_eq(name, name_len, "io_write_batch_buf", 18) != 0) {
      return 1;
    }
  }
  if (name_len == 23) {
    if (cg_residual_name_prefix_eq(name, name_len, "io_register_buffers_buf", 23) != 0) {
      return 1;
    }
  }
  return 0;
}

/**
 * codegen.x: skip emit for placeholder/string stub + seed_mega (env gated).
 * @param name *u8 - function name; null -> 0
 * @param name_len i32 - length
 * @return i32 - 1 skip, 0 otherwise
 * wave107 pure: G.7 single product authority; XLANG_EMIT_SEED_MEGA via link_abi_getenv.
 * PLATFORM: SHARED - sole provider after codegen_residual leave.
 */
#[no_mangle]
export function pipeline_codegen_should_skip_emit_func_by_name(name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len == 11) {
    if (cg_residual_name_prefix_eq(name, name_len, "placeholder", 11) != 0) {
      return 1;
    }
  }
  if (name_len == 22) {
    if (cg_residual_name_prefix_eq(name, name_len, "std_string_placeholder", 22) != 0) {
      return 1;
    }
  }
  if (name_len == 10) {
    if (cg_residual_name_prefix_eq(name, name_len, "string_new", 10) != 0) {
      return 1;
    }
  }
  if (name_len == 22) {
    if (cg_residual_name_prefix_eq(name, name_len, "std_string_string_new", 22) != 0) {
      return 1;
    }
  }
  if (name_len == 21) {
    if (cg_residual_name_prefix_eq(name, name_len, "std_string_string_new", 21) != 0) {
      return 1;
    }
  }
  // bootstrap -E: seed_mega body too large; XLANG_EMIT_SEED_MEGA=1 still emits.
  let seed_mega: *u8 = 0 as *u8;
  unsafe {
    seed_mega = link_abi_getenv("XLANG_EMIT_SEED_MEGA");
  }
  if (seed_mega == 0 as *u8) {
    if (name_len == 25) {
      if (cg_residual_name_prefix_eq(name, name_len, "asm_codegen_ast_seed_mega", 25) != 0) {
        return 1;
      }
    }
    if (name_len == 32) {
      if (cg_residual_name_prefix_eq(name, name_len, "asm_codegen_ast_to_elf_seed_mega", 32) != 0) {
        return 1;
      }
    }
  }
  return 0;
}

/**
 * codegen.x: XLANG_EMIT_SEED_MEGA=1 enables seed_mega emit on bootstrap -E.
 * @return i32 - 1 enabled, 0 otherwise
 * wave107 pure: G.7 single product authority.
 * PLATFORM: SHARED - sole provider after codegen_residual leave.
 */
#[no_mangle]
export function pipeline_codegen_emit_seed_mega_enabled(): i32 {
  let e: *u8 = 0 as *u8;
  unsafe {
    e = link_abi_getenv("XLANG_EMIT_SEED_MEGA");
  }
  return cg_residual_env_truthy(e);
}

/**
 * codegen.x: submit_*_batch_buf calls need a 4th timeout_ms arg.
 * @param name *u8 - callee name; null -> 0
 * @param name_len i32 - length
 * @return i32 - 1 match, 0 otherwise
 * wave107 pure: G.7 single product authority.
 * PLATFORM: SHARED - sole provider after codegen_residual leave.
 */
#[no_mangle]
export function pipeline_codegen_is_submit_batch_buf_call(name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len == 21) {
    if (cg_residual_name_prefix_eq(name, name_len, "submit_read_batch_buf", 21) != 0) {
      return 1;
    }
  }
  if (name_len == 22) {
    if (cg_residual_name_prefix_eq(name, name_len, "submit_write_batch_buf", 22) != 0) {
      return 1;
    }
  }
  return 0;
}

/**
 * codegen.x: skip body emit for std.io.core xlang_io_* already provided by io.o.
 * @param name *u8 - function name; null -> 0
 * @param name_len i32 - length
 * @return i32 - 1 skip, 0 otherwise
 * wave107 pure: G.7 single product authority.
 * PLATFORM: SHARED - sole provider after codegen_residual leave.
 */
#[no_mangle]
export function pipeline_codegen_should_skip_emit_func_core_read_ptr(name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len >= 19) {
    if (cg_residual_name_prefix_eq(name, name_len, "xlang_io_read_ptr_len", 19) != 0) {
      return 1;
    }
  }
  if (name_len == 15) {
    if (cg_residual_name_prefix_eq(name, name_len, "xlang_io_read_ptr", 15) != 0) {
      return 1;
    }
    if (cg_residual_name_prefix_eq(name, name_len, "xlang_io_register", 15) != 0) {
      return 1;
    }
  }
  if (name_len == 23) {
    if (cg_residual_name_prefix_eq(name, name_len, "xlang_io_register_buffers", 23) != 0) {
      return 1;
    }
  }
  if (name_len == 25) {
    if (cg_residual_name_prefix_eq(name, name_len, "xlang_io_unregister_buffers", 25) != 0) {
      return 1;
    }
  }
  if (name_len == 20) {
    if (cg_residual_name_prefix_eq(name, name_len, "xlang_io_wait_readable", 20) != 0) {
      return 1;
    }
  }
  return 0;
}

/**
 * asm path: redirect std.io.core thin wrappers to extern io_* symbols.
 * @param name *u8 - bare xlang_io_* or std_io_core_xlang_io_*; null/empty -> 0
 * @param name_len i32 - name length
 * @param sym_out *u8 - destination buffer for rewritten symbol
 * @param sym_cap i32 - capacity of sym_out
 * @return i32 - symbol length on hit; 0 no match; -1 buffer too small
 * wave107 pure: G.7 single product authority (slen values twin historical C).
 * PLATFORM: SHARED - sole provider after codegen_residual leave.
 */
#[no_mangle]
export function pipeline_asm_io_core_extern_callee_sym(name: *u8, name_len: i32, sym_out: *u8, sym_cap: i32): i32 {
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len <= 0) {
    return 0;
  }
  if (sym_out == 0 as *u8) {
    return 0;
  }
  if (sym_cap <= 0) {
    return 0;
  }
  let bare: *u8 = name;
  let blen: i32 = name_len;
  // G.7: offset via pure xlang_cstr_offset (not raw pointer + N).
  if (name_len > 12) {
    if (cg_residual_name_prefix_eq(name, name_len, "std_io_core_", 12) != 0) {
      bare = xlang_cstr_offset(name, 12);
      blen = name_len - 12;
    }
  }
  let sym: *u8 = 0 as *u8;
  let slen: i32 = 0;
  if (blen == 23) {
    if (cg_residual_name_prefix_eq(bare, blen, "xlang_io_register_buffers", 23) != 0) {
      // Historical C slen=23 for "io_register_buffers_4" (21 chars); twin exactly.
      sym = "io_register_buffers_4";
      slen = 23;
    }
  }
  if (sym == 0 as *u8) {
    if (blen == 25) {
      if (cg_residual_name_prefix_eq(bare, blen, "xlang_io_unregister_buffers", 25) != 0) {
        sym = "io_unregister_buffers";
        slen = 21;
      }
    }
  }
  if (sym == 0 as *u8) {
    if (blen == 15) {
      if (cg_residual_name_prefix_eq(bare, blen, "xlang_io_register", 15) != 0) {
        // Historical C slen=19 for "io_register_buffer" (18 chars); twin exactly.
        sym = "io_register_buffer";
        slen = 19;
      }
    }
  }
  if (sym == 0 as *u8) {
    if (blen == 19) {
      if (cg_residual_name_prefix_eq(bare, blen, "xlang_io_read_ptr_len", 19) != 0) {
        sym = "io_read_ptr_len";
        slen = 15;
      }
    }
  }
  if (sym == 0 as *u8) {
    if (blen == 15) {
      if (cg_residual_name_prefix_eq(bare, blen, "xlang_io_read_ptr", 15) != 0) {
        sym = "io_read_ptr";
        slen = 11;
      }
    }
  }
  if (sym == 0 as *u8) {
    if (blen == 20) {
      if (cg_residual_name_prefix_eq(bare, blen, "xlang_io_wait_readable", 20) != 0) {
        // Historical C slen=17 for "io_wait_readable" (16 chars); twin exactly.
        sym = "io_wait_readable";
        slen = 17;
      }
    }
  }
  if (sym == 0 as *u8) {
    return 0;
  }
  if (sym_cap < slen) {
    return 0 - 1;
  }
  unsafe {
    memcpy(sym_out, sym, slen as usize);
  }
  return slen;
}

/**
 * codegen.x: map driver short names register/submit_* to xlang_io_*_buf.
 * @param name *u8 - short name; null/empty -> 0
 * @param name_len i32 - length
 * @param num_args i32 - call arity
 * @param sym_out *u8 - destination buffer
 * @param sym_cap i32 - capacity
 * @return i32 - symbol length on hit; 0 no match; -1 buffer too small
 * wave107 pure: G.7 single product authority.
 * PLATFORM: SHARED - sole provider after codegen_residual leave.
 */
#[no_mangle]
export function pipeline_codegen_io_driver_buf_call_sym(name: *u8, name_len: i32, num_args: i32, sym_out: *u8, sym_cap: i32): i32 {
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len <= 0) {
    return 0;
  }
  let sym: *u8 = 0 as *u8;
  let sym_len: i32 = 0;
  if (num_args == 1) {
    if (name_len == 8) {
      if (cg_residual_name_prefix_eq(name, name_len, "register", 8) != 0) {
        sym = "xlang_io_register_buf";
        sym_len = 20;
      }
    }
  }
  if (sym == 0 as *u8) {
    if (num_args == 2) {
      if (name_len == 11) {
        if (cg_residual_name_prefix_eq(name, name_len, "submit_read", 11) != 0) {
          sym = "xlang_io_submit_read_buf";
          sym_len = 23;
        }
      }
      if (name_len == 12) {
        if (cg_residual_name_prefix_eq(name, name_len, "submit_write", 12) != 0) {
          sym = "xlang_io_submit_write_buf";
          sym_len = 24;
        }
      }
    }
  }
  if (sym == 0 as *u8) {
    return 0;
  }
  if (sym_out == 0 as *u8) {
    return 0 - 1;
  }
  if (sym_cap < sym_len) {
    return 0 - 1;
  }
  unsafe {
    memcpy(sym_out, sym, sym_len as usize);
  }
  return sym_len;
}

/**
 * codegen.x: std_io read_fixed_fd/write_fixed_fd need _impl suffix.
 * @param prefix *u8 - module/prefix bytes; null -> 0
 * @param prefix_len i32 - prefix length (must be >= 7 for std_io_)
 * @param name *u8 - function short name; null -> 0
 * @param name_len i32 - name length
 * @return i32 - 1 need _impl, 0 otherwise
 * wave107 pure: G.7 single product authority.
 * PLATFORM: SHARED - sole provider after codegen_residual leave.
 */
#[no_mangle]
export function pipeline_codegen_std_io_fixed_fd_emit_impl(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32 {
  if (prefix == 0 as *u8) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (prefix_len < 7) {
    return 0;
  }
  if (name_len <= 0) {
    return 0;
  }
  if (cg_residual_name_prefix_eq(prefix, prefix_len, "std_io_", 7) == 0) {
    return 0;
  }
  if (name_len >= 13) {
    if (cg_residual_name_prefix_eq(name, name_len, "read_fixed_fd", 13) != 0) {
      return 1;
    }
  }
  if (name_len >= 14) {
    if (cg_residual_name_prefix_eq(name, name_len, "write_fixed_fd", 14) != 0) {
      return 1;
    }
  }
  return 0;
}

// ---------------------------------------------------------------------------
// wave108: codegen skip_force pure-owned leave (was pipeline_codegen_skip_force.c).
// G.7 product authority for call_num_args_override / std.io path predicates /
//   should_skip_emit_* / entry_is_lsp_* / force_param_*.
// Reuses private cg_residual_name_prefix_eq (wave107) - single prefix helper.
// Cold twins under seed #ifndef FROM_X.
// PLATFORM: SHARED - dual-end L2 after leave.
// ---------------------------------------------------------------------------

/**
 * Path/name byte equality for len bytes (historical twin of codegen_path_bytes_eq).
 * @param path *u8 - path/name bytes; null -> 0
 * @param expect *u8 - expected bytes (may include trailing NUL in the slice)
 * @param len i32 - byte count to compare; <=0 -> 0
 * @return i32 - 1 match, 0 otherwise
 * wave108 pure: G.7 private helper for skip_force path tables.
 * PLATFORM: SHARED.
 */
function cg_sf_path_bytes_eq(path: *u8, expect: *u8, len: i32): i32 {
  if (path == 0 as *u8) {
    return 0;
  }
  if (expect == 0 as *u8) {
    return 0;
  }
  if (len <= 0) {
    return 0;
  }
  let i: i32 = 0;
  while (i < len) {
    let a: u8 = 0;
    let b: u8 = 0;
    unsafe {
      a = path[i];
      b = expect[i];
    }
    if (a != b) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * prefix[0..prefix_len)+name[0..name_len) equals full[0..full_len).
 * @param prefix *u8 - prefix bytes; null -> 0
 * @param prefix_len i32 - prefix length
 * @param name *u8 - name bytes; null -> 0
 * @param name_len i32 - name length
 * @param full *u8 - expected full symbol
 * @param full_len i32 - expected full length (must equal prefix_len+name_len)
 * @return i32 - 1 match, 0 otherwise
 * wave108 pure: G.7 private helper (historical codegen_prefix_name_bytes_eq).
 * PLATFORM: SHARED.
 */
function cg_sf_prefix_name_bytes_eq(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, full: *u8, full_len: i32): i32 {
  if (prefix == 0 as *u8) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (full == 0 as *u8) {
    return 0;
  }
  if (prefix_len <= 0) {
    return 0;
  }
  if (name_len <= 0) {
    return 0;
  }
  if (prefix_len + name_len != full_len) {
    return 0;
  }
  let pi: i32 = 0;
  while (pi < prefix_len) {
    let a: u8 = 0;
    let b: u8 = 0;
    unsafe {
      a = prefix[pi];
      b = full[pi];
    }
    if (a != b) {
      return 0;
    }
    pi = pi + 1;
  }
  let ni: i32 = 0;
  while (ni < name_len) {
    let a2: u8 = 0;
    let b2: u8 = 0;
    unsafe {
      a2 = name[ni];
      b2 = full[prefix_len + ni];
    }
    if (a2 != b2) {
      return 0;
    }
    ni = ni + 1;
  }
  return 1;
}

/**
 * codegen.x call_num_args_override table lookup (full symbol name).
 * @param buf *u8 - concatenated prefix+name bytes; null -> num_args
 * @param full i32 - length of buf slice
 * @param num_args i32 - original arg count; returned when no hit or invalid
 * @return i32 - override nargs or original num_args
 * wave108 pure: G.7 single product authority (was skip_force host-cc).
 * PLATFORM: SHARED - sole provider after skip_force leave.
 */
#[no_mangle]
export function pipeline_codegen_call_num_args_override_lookup(buf: *u8, full: i32, num_args: i32): i32 {
  if (buf == 0 as *u8) {
    return num_args;
  }
  if (full <= 0) {
    return num_args;
  }
  if (num_args <= 0) {
    return num_args;
  }
  if (full == 13) {
    if (cg_residual_name_prefix_eq(buf, full, "vec_len_empty", 13) != 0) { return 0; }
    if (cg_residual_name_prefix_eq(buf, full, "runtime_ready", 13) != 0) { return 0; }
    if (cg_residual_name_prefix_eq(buf, full, "std_fmt_print", 13) != 0) { return 2; }
  }
  if (full == 21) {
    if (cg_residual_name_prefix_eq(buf, full, "std_vec_vec_len_empty", 21) != 0) { return 0; }
    if (cg_residual_name_prefix_eq(buf, full, "std_string_string_new", 21) != 0) { return 0; }
  }
  if (full == 15) {
    if (cg_residual_name_prefix_eq(buf, full, "alloc_size_zero", 15) != 0) { return 0; }
    if (cg_residual_name_prefix_eq(buf, full, "std_debug_print", 15) != 0) { return 2; }
  }
  if (full == 24) {
    if (cg_residual_name_prefix_eq(buf, full, "std_heap_alloc_size_zero", 24) != 0) { return 0; }
  }
  if (full == 25) {
    if (cg_residual_name_prefix_eq(buf, full, "std_runtime_runtime_ready", 25) != 0) { return 0; }
    if (cg_residual_name_prefix_eq(buf, full, "std_time_now_monotonic_ns", 25) != 0) { return 0; }
    if (cg_residual_name_prefix_eq(buf, full, "std_time_now_monotonic_ms", 25) != 0) { return 0; }
  }
  if (full == 10) {
    if (cg_residual_name_prefix_eq(buf, full, "string_new", 10) != 0) { return 0; }
  }
  if (full == 11) {
    if (cg_residual_name_prefix_eq(buf, full, "placeholder", 11) != 0) { return 0; }
    if (cg_residual_name_prefix_eq(buf, full, "thread_self", 11) != 0) { return 0; }
  }
  if (full == 22) {
    if (cg_residual_name_prefix_eq(buf, full, "std_string_placeholder", 22) != 0) { return 0; }
    if (cg_residual_name_prefix_eq(buf, full, "std_thread_thread_self", 22) != 0) { return 0; }
    if (cg_residual_name_prefix_eq(buf, full, "thread_dummy_entry_ptr", 22) != 0) { return 0; }
  }
  if (full == 33) {
    if (cg_residual_name_prefix_eq(buf, full, "std_thread_thread_dummy_entry_ptr", 33) != 0) { return 0; }
  }
  if (full == 16) {
    if (cg_residual_name_prefix_eq(buf, full, "now_monotonic_ns", 16) != 0) { return 0; }
    if (cg_residual_name_prefix_eq(buf, full, "now_monotonic_ms", 16) != 0) { return 0; }
    if (cg_residual_name_prefix_eq(buf, full, "core_fmt_fmt_i32", 16) != 0) { return 1; }
    if (cg_residual_name_prefix_eq(buf, full, "std_io_print_i32", 16) != 0) { return 1; }
    if (cg_residual_name_prefix_eq(buf, full, "std_io_print_u32", 16) != 0) { return 1; }
    if (cg_residual_name_prefix_eq(buf, full, "std_io_print_i64", 16) != 0) { return 1; }
    if (cg_residual_name_prefix_eq(buf, full, "std_debug_println", 16) != 0) { return 2; }
  }
  if (full == 7) {
    if (cg_residual_name_prefix_eq(buf, full, "fmt_i32", 7) != 0) { return 1; }
    if (cg_residual_name_prefix_eq(buf, full, "err_i32", 7) != 0) { return 1; }
  }
  if (full == 9) {
    if (cg_residual_name_prefix_eq(buf, full, "print_i32", 9) != 0) { return 1; }
    if (cg_residual_name_prefix_eq(buf, full, "print_u32", 9) != 0) { return 1; }
    if (cg_residual_name_prefix_eq(buf, full, "print_i64", 9) != 0) { return 1; }
  }
  if (full == 14) {
    if (cg_residual_name_prefix_eq(buf, full, "std_fmt_println", 14) != 0) { return 2; }
  }
  if (full == 6) {
    if (cg_residual_name_prefix_eq(buf, full, "ok_i32", 6) != 0) { return 1; }
  }
  if (full == 18) {
    if (cg_residual_name_prefix_eq(buf, full, "core_result_ok_i32", 18) != 0) { return 1; }
  }
  if (full == 19) {
    if (cg_residual_name_prefix_eq(buf, full, "core_result_err_i32", 19) != 0) { return 1; }
  }
  return num_args;
}

/**
 * Concatenate prefix+name then override-lookup (codegen.x call site helper).
 * @param prefix *u8 - optional prefix; may be null
 * @param prefix_len i32 - prefix length
 * @param name *u8 - optional name; may be null
 * @param name_len i32 - name length
 * @param num_args i32 - original arg count
 * @return i32 - override or original
 * wave108 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_call_num_args_override(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, num_args: i32): i32 {
  if (num_args <= 0) {
    return num_args;
  }
  let buf: u8[96] = [];
  let full: i32 = 0;
  let i: i32 = 0;
  if (prefix != 0 as *u8) {
    if (prefix_len > 0) {
      i = 0;
      while (i < prefix_len) {
        if (full >= 96) {
          break;
        }
        unsafe { buf[full] = prefix[i]; }
        full = full + 1;
        i = i + 1;
      }
    }
  }
  if (name != 0 as *u8) {
    if (name_len > 0) {
      i = 0;
      while (i < name_len) {
        if (full >= 96) {
          break;
        }
        unsafe { buf[full] = name[i]; }
        full = full + 1;
        i = i + 1;
      }
    }
  }
  return pipeline_codegen_call_num_args_override_lookup(&buf[0], full, num_args);
}

/**
 * std.io.driver bridge short names (register/submit_*/wait_readable/register_fixed_buffers).
 * @param name *u8 - function short name; null -> 0
 * @param name_len i32 - name length
 * @return i32 - 1 bridge, 0 otherwise
 * wave108 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_is_std_io_driver_bridge_name(name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8) {
    return 0;
  }
  if ((name_len == 8 || name_len == 9) && cg_residual_name_prefix_eq(name, name_len, "register", 8) != 0) {
    return 1;
  }
  if ((name_len == 11 || name_len == 12) && cg_residual_name_prefix_eq(name, name_len, "submit_read", 11) != 0) {
    return 1;
  }
  if ((name_len == 12 || name_len == 13) && cg_residual_name_prefix_eq(name, name_len, "submit_write", 12) != 0) {
    return 1;
  }
  if ((name_len == 13 || name_len == 14) && cg_residual_name_prefix_eq(name, name_len, "wait_readable", 13) != 0) {
    return 1;
  }
  if (name_len == 22 && cg_residual_name_prefix_eq(name, name_len, "register_fixed_buffers", 22) != 0) {
    return 1;
  }
  return 0;
}

/**
 * Import path is std.io.driver including trailing NUL (14 bytes).
 * @param path *u8 - path bytes; null -> 0
 * @return i32 - 1 match, 0 otherwise
 * wave108 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_path_is_std_io_driver_bytes(path: *u8): i32 {
  let expect: u8[14] = [115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0];
  return cg_sf_path_bytes_eq(path, &expect[0], 14);
}

/**
 * Cap residual mangle alias of path_is_std_io_driver_bytes (same-TU early callers).
 * @param path *u8 - path bytes; null -> 0
 * @return i32 - 1 match, 0 otherwise
 * wave108 pure: G.7 single authority; early pure orch mangles Cap residual name.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_path_is_std_io_driver_bytes_u8_ptr_reti32(path: *u8): i32 {
  // Twin body (not call short name): typeck Cap residual cannot re-enter no_mangle peer.
  let expect: u8[14] = [115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0];
  return cg_sf_path_bytes_eq(path, &expect[0], 14);
}

/**
 * Import path is std.io.core including trailing NUL (12 bytes).
 * @param path *u8 - path bytes; null -> 0
 * @return i32 - 1 match, 0 otherwise
 * wave108 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_path_is_std_io_core_bytes(path: *u8): i32 {
  let expect: u8[12] = [115, 116, 100, 46, 105, 111, 46, 99, 111, 114, 101, 0];
  return cg_sf_path_bytes_eq(path, &expect[0], 12);
}

/**
 * Seed user-program asm: skip emit for std.io family modules.
 * @param path *u8 - import path; null -> 0
 * @return i32 - 1 skip, 0 otherwise
 * wave108 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_dep_skip_asm_user_std_io(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0;
  }
  if (pipeline_codegen_path_is_std_io_core_bytes(path) != 0) {
    return 1;
  }
  if (cg_sf_path_bytes_eq(path, "std.io", 6) == 0) {
    return 0;
  }
  let b6: u8 = 0;
  unsafe { b6 = path[6]; }
  if (b6 == 0 as u8) {
    return 1;
  }
  if (b6 == 46 as u8) {
    return 1;
  }
  return 0;
}

/**
 * Bootstrap -E / asm partial: skip whole-module X C codegen for compiler frontend deps.
 * @param path *u8 - import path; null -> 0
 * @return i32 - 1 skip, 0 otherwise
 * wave108 pure: G.7 single product authority (exact path prefix match twin C strlen).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_dep_skip_x_bootstrap_partial(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0;
  }
  if (cg_sf_path_bytes_eq(path, "ast", 3) != 0) { return 1; }
  if (cg_sf_path_bytes_eq(path, "codegen", 7) != 0) { return 1; }
  if (cg_sf_path_bytes_eq(path, "parser", 6) != 0) { return 1; }
  if (cg_sf_path_bytes_eq(path, "typeck", 6) != 0) { return 1; }
  if (cg_sf_path_bytes_eq(path, "lexer", 5) != 0) { return 1; }
  if (cg_sf_path_bytes_eq(path, "preprocess", 10) != 0) { return 1; }
  if (cg_sf_path_bytes_eq(path, "pipeline", 8) != 0) { return 1; }
  if (cg_sf_path_bytes_eq(path, "lsp.diag", 8) != 0) { return 1; }
  if (cg_sf_path_bytes_eq(path, "lsp.io", 6) != 0) { return 1; }
  if (cg_sf_path_bytes_eq(path, "lsp", 3) != 0) { return 1; }
  if (cg_sf_path_bytes_eq(path, "driver.check", 12) != 0) { return 1; }
  if (cg_sf_path_bytes_eq(path, "driver.compile", 14) != 0) { return 1; }
  if (cg_sf_path_bytes_eq(path, "driver.emit", 11) != 0) { return 1; }
  if (cg_sf_path_bytes_eq(path, "driver.fmt", 10) != 0) { return 1; }
  if (cg_sf_path_bytes_eq(path, "driver.test", 11) != 0) { return 1; }
  if (cg_sf_path_bytes_eq(path, "driver.build", 12) != 0) { return 1; }
  if (cg_sf_path_bytes_eq(path, "driver.run", 10) != 0) { return 1; }
  if (cg_sf_path_bytes_eq(path, "driver", 6) != 0) { return 1; }
  if (cg_sf_path_bytes_eq(path, "asm.types", 9) != 0) { return 1; }
  return 0;
}

/**
 * Skip emit for std.io.core xlang_io_read_fixed/write_fixed (preamble weak dups).
 * @param dep_path *u8 - dep import path; null -> 0
 * @param name *u8 - function name; null -> 0
 * @param name_len i32 - name length
 * @return i32 - 1 skip, 0 otherwise
 * wave108 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_should_skip_emit_std_io_core_io_dup(dep_path: *u8, name: *u8, name_len: i32): i32 {
  if (dep_path == 0 as *u8) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (cg_sf_path_bytes_eq(dep_path, "std.io.core", 11) == 0) {
    return 0;
  }
  if ((name_len == 18 || name_len == 19) && cg_residual_name_prefix_eq(name, name_len, "xlang_io_read_fixed", 18) != 0) {
    return 1;
  }
  if ((name_len == 19 || name_len == 20) && cg_residual_name_prefix_eq(name, name_len, "xlang_io_write_fixed", 19) != 0) {
    return 1;
  }
  return 0;
}

/**
 * Skip emit for std.io handle_* literal helpers.
 * @param dep_path *u8 - optional path filter (std.io NUL); null -> name-only
 * @param name *u8 - function name; null -> 0
 * @param name_len i32 - name length
 * @return i32 - 1 skip, 0 otherwise
 * wave108 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_should_skip_emit_std_io_trivial_handle(dep_path: *u8, name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8) {
    return 0;
  }
  if (dep_path != 0 as *u8) {
    let expect: u8[7] = [115, 116, 100, 46, 105, 111, 0];
    if (cg_sf_path_bytes_eq(dep_path, &expect[0], 7) == 0) {
      return 0;
    }
  }
  if ((name_len == 12 || name_len == 13) && cg_residual_name_prefix_eq(name, name_len, "handle_stdin", 12) != 0) {
    return 1;
  }
  if ((name_len == 13 || name_len == 14) && cg_residual_name_prefix_eq(name, name_len, "handle_stdout", 13) != 0) {
    return 1;
  }
  if ((name_len == 13 || name_len == 14) && cg_residual_name_prefix_eq(name, name_len, "handle_stderr", 13) != 0) {
    return 1;
  }
  if ((name_len == 15 || name_len == 16) && cg_residual_name_prefix_eq(name, name_len, "handle_from_fd", 15) != 0) {
    return 1;
  }
  return 0;
}

/**
 * Merge driver_should_skip_emit predicates (codegen.x should_skip_emit_func).
 * @param dep_path *u8 - optional dep path
 * @param prefix *u8 - optional C prefix
 * @param prefix_len i32 - prefix length
 * @param name *u8 - function name
 * @param name_len i32 - name length
 * @return i32 - 1 skip, 0 otherwise
 * wave108 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_should_skip_emit_func(dep_path: *u8, prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32 {
  if (prefix != 0 as *u8 && prefix_len > 0 && name != 0 as *u8 && name_len > 0) {
    if (cg_sf_prefix_name_bytes_eq(prefix, prefix_len, name, name_len, "std_io_driver_driver_read_ptr_len", 33) != 0) {
      return 1;
    }
    if (cg_sf_prefix_name_bytes_eq(prefix, prefix_len, name, name_len, "std_io_driver_driver_read_ptr", 29) != 0) {
      return 1;
    }
  }
  if (dep_path != 0 as *u8) {
    let ok_path: i32 = 0;
    let exp_drv: u8[14] = [115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0];
    let exp_io: u8[7] = [115, 116, 100, 46, 105, 111, 0];
    if (cg_sf_path_bytes_eq(dep_path, &exp_drv[0], 14) != 0) {
      ok_path = 1;
    }
    if (ok_path == 0) {
      if (cg_sf_path_bytes_eq(dep_path, &exp_io[0], 7) != 0) {
        ok_path = 1;
      }
    }
    if (ok_path != 0 && name != 0 as *u8) {
      if ((name_len == 19 || name_len == 20) && cg_residual_name_prefix_eq(name, name_len, "driver_read_ptr_len", 19) != 0) {
        return 1;
      }
      if ((name_len == 15 || name_len == 16) && cg_residual_name_prefix_eq(name, name_len, "driver_read_ptr", 15) != 0) {
        return 1;
      }
    }
  }
  if (prefix != 0 as *u8 && prefix_len == 14 && name != 0 as *u8) {
    if (cg_residual_name_prefix_eq(prefix, prefix_len, "std_io_driver_", 14) != 0) {
      if (pipeline_codegen_is_std_io_driver_bridge_name(name, name_len) != 0) {
        return 1;
      }
    }
  }
  if (dep_path != 0 as *u8 && name != 0 as *u8) {
    let exp_drv2: u8[14] = [115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0];
    if (cg_sf_path_bytes_eq(dep_path, &exp_drv2[0], 14) != 0) {
      if (pipeline_codegen_is_std_io_driver_bridge_name(name, name_len) != 0) {
        return 1;
      }
    }
  }
  if (prefix != 0 as *u8 && prefix_len == 14 && name != 0 as *u8) {
    if (pipeline_codegen_should_skip_emit_std_io_trivial_handle(0 as *u8, name, name_len) != 0) {
      return 1;
    }
  }
  if (dep_path != 0 as *u8 && name != 0 as *u8) {
    if (pipeline_codegen_should_skip_emit_std_io_core_io_dup(dep_path, name, name_len) != 0) {
      return 1;
    }
    let exp_drv3: u8[14] = [115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0];
    if (cg_sf_path_bytes_eq(dep_path, &exp_drv3[0], 14) != 0) {
      if (pipeline_codegen_should_skip_emit_std_io_trivial_handle(0 as *u8, name, name_len) != 0) {
        return 1;
      }
    }
  }
  return 0;
}

/**
 * Entry module probes: has read_message (LSP io).
 * @param module *u8 - Module*; null -> 0
 * @return i32 - 1 lsp-io entry, 0 otherwise
 * wave108 pure: G.7 single product authority; walks pipeline_module_num_funcs + name copy.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_entry_is_lsp_io_module(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  unsafe {
    let n: i32 = pipeline_module_num_funcs(module);
    let i: i32 = 0;
    while (i < n) {
      let nlen: i32 = pipeline_module_func_name_len_at(module, i);
      if (nlen == 12) {
        let raw: u8[64] = [];
        pipeline_module_func_name_copy64(module, i, &raw[0]);
        if (cg_residual_name_prefix_eq(&raw[0], 12, "read_message", 12) != 0) {
          return 1;
        }
      }
      i = i + 1;
    }
  }
  return 0;
}

/**
 * Entry module probes: has lsp_main.
 * @param module *u8 - Module*; null -> 0
 * @return i32 - 1 lsp main, 0 otherwise
 * wave108 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_entry_is_lsp_main_module(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  unsafe {
    let n: i32 = pipeline_module_num_funcs(module);
    let i: i32 = 0;
    while (i < n) {
      let nlen: i32 = pipeline_module_func_name_len_at(module, i);
      if (nlen == 8) {
        let raw: u8[64] = [];
        pipeline_module_func_name_copy64(module, i, &raw[0]);
        if (cg_residual_name_prefix_eq(&raw[0], 8, "lsp_main", 8) != 0) {
          return 1;
        }
      }
      i = i + 1;
    }
  }
  return 0;
}

/**
 * C prefix is std_io_driver family (13 bytes + optional NUL or _).
 * @param prefix *u8 - prefix bytes; null -> 0
 * @param prefix_len i32 - length
 * @return i32 - 1 ok, 0 otherwise
 * wave108 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix: *u8, prefix_len: i32): i32 {
  if (prefix == 0 as *u8) {
    return 0;
  }
  if (prefix_len < 13) {
    return 0;
  }
  if (cg_residual_name_prefix_eq(prefix, prefix_len, "std_io_driver", 13) == 0) {
    return 0;
  }
  if (prefix_len > 13) {
    let b14: u8 = 0;
    unsafe { b14 = prefix[13]; }
    if (b14 != 0 as u8 && b14 != 95 as u8) {
      return 0;
    }
  }
  return 1;
}

/**
 * Force size_t for std_io_driver submit_*_batch_buf param 0.
 * @param prefix *u8 - C prefix
 * @param prefix_len i32 - prefix length
 * @param name *u8 - function name
 * @param name_len i32 - name length
 * @param param_index i32 - parameter index
 * @return i32 - 1 force, 0 otherwise
 * wave108 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_force_param_size_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  if (param_index != 0) {
    return 0;
  }
  if (pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len == 21 && cg_residual_name_prefix_eq(name, name_len, "submit_read_batch_buf", 21) != 0) {
    return 1;
  }
  if (name_len == 22 && cg_residual_name_prefix_eq(name, name_len, "submit_write_batch_buf", 22) != 0) {
    return 1;
  }
  return 0;
}

/**
 * Force size_t for std_io_ print second arg.
 * @param prefix *u8 - must be std_io_
 * @param prefix_len i32 - prefix length (>=7)
 * @param name *u8 - must be "print"
 * @param name_len i32 - name length (5)
 * @param param_index i32 - must be 1
 * @return i32 - 1 force, 0 otherwise
 * wave108 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_force_param_size_t_std_io_print_str_second(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  if (param_index != 1) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len != 5) {
    return 0;
  }
  if (cg_residual_name_prefix_eq(name, name_len, "print", 5) == 0) {
    return 0;
  }
  if (prefix == 0 as *u8) {
    return 0;
  }
  if (prefix_len < 7) {
    return 0;
  }
  if (cg_residual_name_prefix_eq(prefix, prefix_len, "std_io_", 7) != 0) {
    return 1;
  }
  return 0;
}

/**
 * Force ptrdiff_t for std_io_driver register/submit_read/submit_write param 0.
 * @param prefix *u8 - C prefix
 * @param prefix_len i32 - prefix length
 * @param name *u8 - function name
 * @param name_len i32 - name length
 * @param param_index i32 - must be 0
 * @return i32 - 1 force, 0 otherwise
 * wave108 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_force_param_ptrdiff_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  if (param_index != 0) {
    return 0;
  }
  if (pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len == 8 && cg_residual_name_prefix_eq(name, name_len, "register", 8) != 0) {
    return 1;
  }
  if (name_len == 11 && cg_residual_name_prefix_eq(name, name_len, "submit_read", 11) != 0) {
    return 1;
  }
  if (name_len == 12 && cg_residual_name_prefix_eq(name, name_len, "submit_write", 12) != 0) {
    return 1;
  }
  return 0;
}

/**
 * Force uint32_t for std_io_driver timeout_ms / nr slots.
 * @param prefix *u8 - C prefix
 * @param prefix_len i32 - prefix length
 * @param name *u8 - function name
 * @param name_len i32 - name length
 * @param param_index i32 - parameter index
 * @return i32 - 1 force, 0 otherwise
 * wave108 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_force_param_uint32_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  if (pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (param_index == 1) {
    if (name_len == 11 && cg_residual_name_prefix_eq(name, name_len, "submit_read", 11) != 0) {
      return 1;
    }
    if (name_len == 12 && cg_residual_name_prefix_eq(name, name_len, "submit_write", 12) != 0) {
      return 1;
    }
    if (name_len == 33 && cg_residual_name_prefix_eq(name, name_len, "submit_register_fixed_buffers_buf", 33) != 0) {
      return 1;
    }
    return 0;
  }
  if (param_index == 3) {
    if (name_len == 21 && cg_residual_name_prefix_eq(name, name_len, "submit_read_batch_buf", 21) != 0) {
      return 1;
    }
    if (name_len == 22 && cg_residual_name_prefix_eq(name, name_len, "submit_write_batch_buf", 22) != 0) {
      return 1;
    }
  }
  return 0;
}

// ---------------------------------------------------------------------------
// wave109: codegen type_to_c pure-owned leave (was pipeline_codegen_type_to_c.c).
// G.7 product authority for TypeKind/VECTOR C name tables + recursive
//   type_to_c_repr (TYPE_PTR / ARRAY / SLICE / LINEAR / VECTOR / NAMED short ints).
// Public faces: type_kind_copy / type_kind_append / vector_type_copy / type_to_c_repr.
//   (type_kind_cstr / vector_type_cstr were internal-only; pure uses direct copy.)
// struct_emit host residual calls public type_to_c_repr (was same-TU static inner).
// Cold twins under seed #ifndef FROM_X.
// PLATFORM: SHARED - dual-end L2 after leave.
// ---------------------------------------------------------------------------

/** Arena type pool accessors for type_to_c (wave109).
 * Use extern "C" so Cap residual does not mangle *u8 arena to *_u8_ptr_* names.
 * pipeline_arena_num_types already declared earlier in this file with "C". */
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
export extern "C" function pipeline_type_array_size_at(arena: *u8, ref: i32): i32;
export extern "C" function pipeline_type_named_name_into(arena: *u8, ref: i32, out64: *u8): i32;

/**
 * Copy n bytes from src into dst when cap is large enough.
 * @param dst *u8 - destination; null -> -1
 * @param cap i32 - destination capacity
 * @param src *u8 - source bytes; null -> -1
 * @param n i32 - byte count; n<=0 -> -1
 * @return i32 - n on success, -1 on failure
 * wave109 pure: private helper for type kind/vector tables.
 * PLATFORM: SHARED.
 */
function cg_ttc_write_bytes(dst: *u8, cap: i32, src: *u8, n: i32): i32 {
  if (dst == 0 as *u8) {
    return -1;
  }
  if (src == 0 as *u8) {
    return -1;
  }
  if (n <= 0) {
    return -1;
  }
  if (cap < n) {
    return -1;
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      dst[i] = src[i];
    }
    i = i + 1;
  }
  return n;
}

/**
 * TypeKind builtin -> C type name into dst (no NUL).
 * @param dst *u8 - destination buffer
 * @param cap i32 - capacity
 * @param kind i32 - TypeKind ordinal (0..16); 8..13 compound kinds return -1
 * @return i32 - byte count, or -1 if unsupported / overflow
 * wave109 pure: G.7 single product authority (was type_kind_cstr+copy).
 * PLATFORM: SHARED - F32/F64/VOID ordinals match ast.x TypeKind (wave618).
 */
#[no_mangle]
export function pipeline_codegen_type_kind_copy(dst: *u8, cap: i32, kind: i32): i32 {
  if (kind == 0) {
    return cg_ttc_write_bytes(dst, cap, "int32_t", 7);
  }
  if (kind == 1) {
    return cg_ttc_write_bytes(dst, cap, "int", 3);
  }
  if (kind == 2) {
    return cg_ttc_write_bytes(dst, cap, "uint8_t", 7);
  }
  if (kind == 3) {
    return cg_ttc_write_bytes(dst, cap, "uint32_t", 8);
  }
  if (kind == 4) {
    return cg_ttc_write_bytes(dst, cap, "uint64_t", 8);
  }
  if (kind == 5) {
    return cg_ttc_write_bytes(dst, cap, "int64_t", 7);
  }
  if (kind == 6) {
    return cg_ttc_write_bytes(dst, cap, "size_t", 6);
  }
  if (kind == 7) {
    return cg_ttc_write_bytes(dst, cap, "ssize_t", 7);
  }
  // 8..13: NAMED/PTR/ARRAY/SLICE/LINEAR/VECTOR handled in type_to_c_repr
  if (kind == 14) {
    return cg_ttc_write_bytes(dst, cap, "float", 5);
  }
  if (kind == 15) {
    return cg_ttc_write_bytes(dst, cap, "double", 6);
  }
  if (kind == 16) {
    return cg_ttc_write_bytes(dst, cap, "void", 4);
  }
  return -1;
}

/**
 * VECTOR type C name into dst (elem_kind x lanes).
 * @param dst *u8 - destination buffer
 * @param cap i32 - capacity
 * @param elem_kind i32 - ord_i32=0 / ord_u32=3 / ord_f32=14
 * @param lanes i32 - 4 / 8 / 16
 * @return i32 - byte count, or -1 if no match / overflow
 * wave109 pure: G.7 single product authority (was vector_type_cstr+copy).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_vector_type_copy(dst: *u8, cap: i32, elem_kind: i32, lanes: i32): i32 {
  if (elem_kind == 0) {
    if (lanes == 4) {
      return cg_ttc_write_bytes(dst, cap, "i32x4_t", 7);
    }
    if (lanes == 8) {
      return cg_ttc_write_bytes(dst, cap, "i32x8_t", 7);
    }
    if (lanes == 16) {
      return cg_ttc_write_bytes(dst, cap, "i32x16_t", 8);
    }
  }
  if (elem_kind == 3) {
    if (lanes == 4) {
      return cg_ttc_write_bytes(dst, cap, "u32x4_t", 7);
    }
    if (lanes == 8) {
      return cg_ttc_write_bytes(dst, cap, "u32x8_t", 7);
    }
    if (lanes == 16) {
      return cg_ttc_write_bytes(dst, cap, "u32x16_t", 8);
    }
  }
  // F32 vector (Vec4f / f32x4 / f32x8 / f32x16). elem_kind=14 == ord_f32.
  if (elem_kind == 14) {
    if (lanes == 4) {
      return cg_ttc_write_bytes(dst, cap, "f32x4_t", 7);
    }
    if (lanes == 8) {
      return cg_ttc_write_bytes(dst, cap, "f32x8_t", 7);
    }
    if (lanes == 16) {
      return cg_ttc_write_bytes(dst, cap, "f32x16_t", 8);
    }
  }
  return -1;
}

/**
 * Append TypeKind C name onto scratch[w..); return next write index.
 * @param scratch *u8 - scratch buffer
 * @param cap i32 - capacity
 * @param w i32 - current write index
 * @param kind i32 - TypeKind ordinal
 * @return i32 - next write index, or -1 on overflow / unsupported
 * wave109 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_type_kind_append(scratch: *u8, cap: i32, w: i32, kind: i32): i32 {
  let tmp: u8[16] = [];
  let n: i32 = pipeline_codegen_type_kind_copy(&tmp[0], 16, kind);
  if (n <= 0) {
    return -1;
  }
  if (scratch == 0 as *u8) {
    return -1;
  }
  let i: i32 = 0;
  while (i < n) {
    if (w >= cap - 1) {
      return -1;
    }
    unsafe {
      scratch[w] = tmp[i];
    }
    w = w + 1;
    i = i + 1;
  }
  return w;
}

/**
 * Recursive type_to_c_repr: write C type name for type_ref into scratch (no NUL).
 * @param arena *u8 - ASTArena* (opaque)
 * @param scratch *u8 - destination
 * @param cap i32 - capacity; <16 rejects
 * @param type_ref i32 - type pool index
 * @param struct_prefix *u8 - optional NAMED struct prefix (e.g. dep module); null ok
 * @param struct_prefix_len i32 - prefix length; 0 => bare NAMED (entry module)
 * @return i32 - byte count, or -1 on overflow
 * wave109 pure: G.7 single product authority (was type_to_c_repr_inner + entry).
 * Uses stack inner/eb for recursive SLICE/PTR (wave691; no static re-entry).
 * PLATFORM: SHARED host-C type_to_c_repr authority.
 */
#[no_mangle]
export function pipeline_codegen_type_to_c_repr(arena: *u8, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  let inner: u8[256] = [];
  let eb: u8[256] = [];
  let nm: u8[128] = [];
  if (cap < 16) {
    return -1;
  }
  if (scratch == 0 as *u8) {
    return -1;
  }
  // Fallback int32_t when arena/type_ref invalid (matches host residual).
  let nt: i32 = 0;
  if (arena != 0 as *u8) {
    unsafe {
      nt = pipeline_arena_num_types(arena);
    }
  }
  if (arena == 0 as *u8 || type_ref <= 0 || type_ref > nt) {
    return cg_ttc_write_bytes(scratch, cap, "int32_t", 7);
  }
  let tk: i32 = 0;
  let elem_ref: i32 = 0;
  let arr_sz: i32 = 0;
  unsafe {
    tk = pipeline_type_kind_ord_at(arena, type_ref);
    elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
    arr_sz = pipeline_type_array_size_at(arena, type_ref);
  }
  // TYPE_PTR (9): elem " *"
  if (tk == 9 && elem_ref > 0) {
    let n: i32 = pipeline_codegen_type_to_c_repr(arena, &inner[0], 256, elem_ref, struct_prefix, struct_prefix_len);
    if (n < 0 || n + 2 >= cap) {
      return -1;
    }
    let j: i32 = 0;
    while (j < n) {
      unsafe {
        scratch[j] = inner[j];
      }
      j = j + 1;
    }
    unsafe {
      scratch[n] = 32;
      scratch[n + 1] = 42;
    }
    return n + 2;
  }
  // TYPE_ARRAY (10): decay to elem C type
  if (tk == 10 && elem_ref > 0) {
    return pipeline_codegen_type_to_c_repr(arena, scratch, cap, elem_ref, struct_prefix, struct_prefix_len);
  }
  // TYPE_VECTOR (13)
  if (tk == 13 && elem_ref > 0) {
    let elem_kind: i32 = 0;
    unsafe {
      elem_kind = pipeline_type_kind_ord_at(arena, elem_ref);
    }
    let n: i32 = pipeline_codegen_vector_type_copy(scratch, cap, elem_kind, arr_sz);
    if (n >= 0) {
      return n;
    }
    return pipeline_codegen_type_kind_copy(scratch, cap, 0);
  }
  // TYPE_LINEAR (12): decay to elem
  if (tk == 12 && elem_ref > 0) {
    return pipeline_codegen_type_to_c_repr(arena, scratch, cap, elem_ref, struct_prefix, struct_prefix_len);
  }
  // TYPE_SLICE (11): struct xlang_slice_<elemC> (strip leading "struct ")
  if (tk == 11 && elem_ref > 0) {
    let n: i32 = pipeline_codegen_type_to_c_repr(arena, &eb[0], 256, elem_ref, struct_prefix, struct_prefix_len);
    if (n < 0 || n >= 256) {
      return -1;
    }
    let sp: i32 = 0;
    if (n >= 7) {
      let is_struct: i32 = 0;
      unsafe {
        if (eb[0] == 115 && eb[1] == 116 && eb[2] == 114 && eb[3] == 117 && eb[4] == 99 && eb[5] == 116 && eb[6] == 32) {
          is_struct = 1;
        }
      }
      if (is_struct != 0) {
        sp = 7;
        while (sp < n) {
          let ch: u8 = 0;
          unsafe {
            ch = eb[sp];
          }
          if (ch != 32) {
            break;
          }
          sp = sp + 1;
        }
      }
    }
    let plen: i32 = n - sp;
    if (plen <= 0 || 19 + plen >= cap) {
      return -1;
    }
    // "struct xlang_slice_" = 19 bytes
    let hi: i32 = 0;
    let hdr: u8[19] = [115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95];
    while (hi < 19) {
      unsafe {
        scratch[hi] = hdr[hi];
      }
      hi = hi + 1;
    }
    let pi: i32 = 0;
    while (pi < plen) {
      unsafe {
        scratch[19 + pi] = eb[sp + pi];
      }
      pi = pi + 1;
    }
    return 19 + plen;
  }
  // TYPE_NAMED (8) or named short ints / struct tags
  let name_len: i32 = 0;
  unsafe {
    name_len = pipeline_type_named_name_into(arena, type_ref, &nm[0]);
  }
  if (tk == 8 && name_len > 0) {
    // short ints without TypeKind (wave313 i8/i16/u16) -> stdint C names
    if (name_len == 2) {
      let a: u8 = 0;
      let b: u8 = 0;
      unsafe {
        a = nm[0];
        b = nm[1];
      }
      if (a == 105 && b == 56) {
        // i8
        return cg_ttc_write_bytes(scratch, cap, "int8_t", 6);
      }
    }
    if (name_len == 3) {
      let a: u8 = 0;
      let b: u8 = 0;
      let c: u8 = 0;
      unsafe {
        a = nm[0];
        b = nm[1];
        c = nm[2];
      }
      if (a == 105 && b == 49 && c == 54) {
        // i16
        return cg_ttc_write_bytes(scratch, cap, "int16_t", 7);
      }
      if (a == 117 && b == 49 && c == 54) {
        // u16
        return cg_ttc_write_bytes(scratch, cap, "uint16_t", 8);
      }
    }
    // "struct " + optional prefix + name
    let w: i32 = 0;
    let h: i32 = 0;
    let hdr2: u8[7] = [115, 116, 114, 117, 99, 116, 32];
    while (h < 7) {
      if (w >= cap - 1) {
        return -1;
      }
      unsafe {
        scratch[w] = hdr2[h];
      }
      w = w + 1;
      h = h + 1;
    }
    if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
      let pi: i32 = 0;
      while (pi < struct_prefix_len) {
        if (w >= cap - 1) {
          return -1;
        }
        unsafe {
          scratch[w] = struct_prefix[pi];
        }
        w = w + 1;
        pi = pi + 1;
      }
    }
    // empty prefix -> bare name (entry module; wave624)
    let pi2: i32 = 0;
    while (pi2 < name_len && pi2 < 64) {
      if (w >= cap - 1) {
        return -1;
      }
      unsafe {
        scratch[w] = nm[pi2];
      }
      w = w + 1;
      pi2 = pi2 + 1;
    }
    return w;
  }
  let sn: i32 = pipeline_codegen_type_kind_copy(scratch, cap, tk);
  if (sn > 0) {
    return sn;
  }
  return pipeline_codegen_type_kind_copy(scratch, cap, 0);
}

// ---------------------------------------------------------------------------
// wave110: codegen struct_emit pure-owned leave (was pipeline_codegen_struct_emit.c).
// G.7 product authority for C co-emit prologue flag + struct tag claim table +
//   CodegenOutBuf append helpers + emit_struct_field_type / _decl.
// Public faces: c_file_prologue_done_{get,set,reset} / struct_tag_try_claim /
//   emit_struct_field_type / emit_struct_field_decl.
// Depends on wave109 type_to_c (type_kind_copy / vector_type_copy / type_to_c_repr)
//   and wave105 codegen_out_buf_len|set_len.
// Cold twins under seed #ifndef FROM_X.
// PLATFORM: SHARED - dual-end L2 after leave.
// ---------------------------------------------------------------------------

// PIPELINE_CODEGEN_STRUCT_TAG_MAX=256, CAP=128 -> flat BSS 256*128.
let g_cg_se_prologue_done: i32 = 0;
let g_cg_se_tag_n: i32 = 0;
let g_cg_se_tags: u8[32768] = [];

/**
 * Read single-file C co-emit prologue-done flag.
 * @return i32 - 1 if prologue already emitted, else 0
 * wave110 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_c_file_prologue_done_get(): i32 {
  return g_cg_se_prologue_done;
}

/**
 * Set single-file C co-emit prologue-done flag (nonzero -> 1).
 * @param v i32 - new flag value
 * @return void
 * wave110 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_c_file_prologue_done_set(v: i32): void {
  if (v != 0) {
    g_cg_se_prologue_done = 1;
  } else {
    g_cg_se_prologue_done = 0;
  }
}

/**
 * Reset prologue-done flag and clear struct tag claim table.
 * @return void
 * wave110 pure: G.7 single product authority (new C unit co-emit session).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_c_file_prologue_done_reset(): void {
  g_cg_se_prologue_done = 0;
  g_cg_se_tag_n = 0;
}

/**
 * Try to claim a C struct tag (prefix+name) for first full emit in this unit.
 * @param prefix *u8 - optional tag prefix bytes; null treated as empty
 * @param prefix_len i32 - prefix length; <0 clamped to 0
 * @param name *u8 - struct name; null or empty -> -1
 * @param name_len i32 - name length
 * @return i32 - 1 first claim (caller should emit def), 0 already claimed or table full, -1 bad args
 * wave110 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_struct_tag_try_claim(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8) {
    return -1;
  }
  if (name_len <= 0) {
    return -1;
  }
  let plen: i32 = prefix_len;
  if (plen < 0) {
    plen = 0;
  }
  if (prefix == 0 as *u8) {
    plen = 0;
  }
  let tlen: i32 = plen + name_len;
  // CAP 128 including NUL
  if (tlen <= 0) {
    return -1;
  }
  if (tlen >= 128) {
    return -1;
  }
  let tag: u8[128] = [];
  let i: i32 = 0;
  while (i < plen) {
    unsafe {
      tag[i] = prefix[i];
    }
    i = i + 1;
  }
  let j: i32 = 0;
  while (j < name_len) {
    unsafe {
      tag[plen + j] = name[j];
    }
    j = j + 1;
  }
  unsafe {
    tag[tlen] = 0;
  }
  // Linear scan claimed tags.
  let k: i32 = 0;
  while (k < g_cg_se_tag_n) {
    let base: i32 = k * 128;
    let same: i32 = 1;
    let ti: i32 = 0;
    while (ti < tlen) {
      let a: u8 = 0;
      let b: u8 = 0;
      unsafe {
        a = g_cg_se_tags[base + ti];
        b = tag[ti];
      }
      if (a != b) {
        same = 0;
        break;
      }
      ti = ti + 1;
    }
    if (same != 0) {
      let z: u8 = 0;
      unsafe {
        z = g_cg_se_tags[base + tlen];
      }
      if (z == 0) {
        return 0;
      }
    }
    k = k + 1;
  }
  // Table full: conservative skip re-emit (avoid C redefinition).
  if (g_cg_se_tag_n >= 256) {
    return 0;
  }
  let base2: i32 = g_cg_se_tag_n * 128;
  let ci: i32 = 0;
  while (ci <= tlen) {
    unsafe {
      g_cg_se_tags[base2 + ci] = tag[ci];
    }
    ci = ci + 1;
  }
  g_cg_se_tag_n = g_cg_se_tag_n + 1;
  return 1;
}

/**
 * Append n bytes into CodegenOutBuf (data[9437184] + len i32 LE).
 * @param out *u8 - opaque CodegenOutBuf*
 * @param p *u8 - source bytes
 * @param n i32 - byte count; n<0 -> -1
 * @return i32 - 0 ok, -1 overflow/null
 * wave110 pure: private helper (historical pipeline_codegen_out_append_bytes).
 * Cap gate matches historical struct_emit: len+n > 9437184.
 * PLATFORM: SHARED.
 */
function cg_se_out_append_bytes(out: *u8, p: *u8, n: i32): i32 {
  if (out == 0 as *u8) {
    return -1;
  }
  if (p == 0 as *u8) {
    return -1;
  }
  if (n < 0) {
    return -1;
  }
  let len: i32 = codegen_out_buf_len(out);
  if (len + n > 9437184) {
    return -1;
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      out[len + i] = p[i];
    }
    i = i + 1;
  }
  codegen_out_buf_set_len(out, len + n);
  return 0;
}

/**
 * Append one byte into CodegenOutBuf.
 * @param out *u8 - opaque CodegenOutBuf*
 * @param b u8 - byte
 * @return i32 - 0 ok, -1 fail
 * wave110 pure: private helper.
 * PLATFORM: SHARED.
 */
function cg_se_out_append_byte(out: *u8, b: u8): i32 {
  let one: u8[1] = [0];
  unsafe {
    one[0] = b;
  }
  return cg_se_out_append_bytes(out, &one[0], 1);
}

/**
 * Append decimal i32 into CodegenOutBuf (no snprintf).
 * @param out *u8 - opaque CodegenOutBuf*
 * @param val i32 - value (array sizes typically non-negative)
 * @return i32 - 0 ok, -1 fail
 * wave110 pure: private helper via pipe_diag_msg_append_i32.
 * PLATFORM: SHARED.
 */
function cg_se_out_format_int(out: *u8, val: i32): i32 {
  if (out == 0 as *u8) {
    return -1;
  }
  let buf: u8[16] = [];
  let n: i32 = pipe_diag_msg_append_i32(&buf[0], 16, 0, val);
  if (n <= 0) {
    return -1;
  }
  if (n >= 16) {
    return -1;
  }
  return cg_se_out_append_bytes(out, &buf[0], n);
}

/**
 * Recursive emit of struct field C type into out (TypeKind ord == ast.x).
 * @param arena *u8 - ASTArena*
 * @param out *u8 - CodegenOutBuf*
 * @param type_ref i32 - type pool ref
 * @param struct_prefix *u8 - optional struct tag prefix
 * @param struct_prefix_len i32 - prefix length
 * @return i32 - 0 ok, -1 fail
 * wave110 pure: private recursive core for emit_struct_field_type.
 * PLATFORM: SHARED.
 */
function pipeline_codegen_emit_struct_field_type_inner(arena: *u8, out: *u8, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  let scratch: u8[256] = [];
  let nm: u8[128] = [];
  let ord: i32 = -1;
  if (arena != 0 as *u8 && type_ref > 0) {
    unsafe {
      ord = pipeline_type_kind_ord_at(arena, type_ref);
    }
  }
  if (arena == 0 as *u8 || type_ref <= 0 || ord < 0) {
    return cg_se_out_append_bytes(out, "int32_t", 7);
  }
  // TYPE_PTR (9): elem then " *"
  if (ord == 9) {
    let inner: i32 = 0;
    unsafe {
      inner = pipeline_type_elem_ref_at(arena, type_ref);
    }
    if (pipeline_codegen_emit_struct_field_type_inner(arena, out, inner, struct_prefix, struct_prefix_len) != 0) {
      return -1;
    }
    if (cg_se_out_append_byte(out, 32) != 0) {
      return -1;
    }
    return cg_se_out_append_byte(out, 42);
  }
  // TYPE_ARRAY (10): elem then [size]
  if (ord == 10) {
    let inner2: i32 = 0;
    let asz: i32 = 0;
    unsafe {
      inner2 = pipeline_type_elem_ref_at(arena, type_ref);
      asz = pipeline_type_array_size_at(arena, type_ref);
    }
    if (pipeline_codegen_emit_struct_field_type_inner(arena, out, inner2, struct_prefix, struct_prefix_len) != 0) {
      return -1;
    }
    if (cg_se_out_append_byte(out, 91) != 0) {
      return -1;
    }
    if (cg_se_out_format_int(out, asz) != 0) {
      return -1;
    }
    return cg_se_out_append_byte(out, 93);
  }
  // TYPE_NAMED (8): "struct " + optional prefix + name
  if (ord == 8) {
    let nl: i32 = 0;
    unsafe {
      nl = pipeline_type_named_name_into(arena, type_ref, &nm[0]);
    }
    if (nl <= 0) {
      return cg_se_out_append_bytes(out, "int32_t", 7);
    }
    if (cg_se_out_append_bytes(out, "struct ", 7) != 0) {
      return -1;
    }
    if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
      if (cg_se_out_append_bytes(out, struct_prefix, struct_prefix_len) != 0) {
        return -1;
      }
    }
    // wave624: empty prefix -> bare name (entry); match type_to_c_repr.
    return cg_se_out_append_bytes(out, &nm[0], nl);
  }
  // TYPE_SLICE (11): public type_to_c_repr then append
  if (ord == 11) {
    let nl2: i32 = pipeline_codegen_type_to_c_repr(arena, &scratch[0], 256, type_ref, struct_prefix, struct_prefix_len);
    if (nl2 <= 0) {
      return -1;
    }
    return cg_se_out_append_bytes(out, &scratch[0], nl2);
  }
  // TYPE_LINEAR (12): decay to elem
  if (ord == 12) {
    let inner3: i32 = 0;
    unsafe {
      inner3 = pipeline_type_elem_ref_at(arena, type_ref);
    }
    return pipeline_codegen_emit_struct_field_type_inner(arena, out, inner3, struct_prefix, struct_prefix_len);
  }
  // TYPE_VECTOR (13): vector_type_copy fallback type_kind_copy(0)
  if (ord == 13) {
    let lanes_v: i32 = 0;
    let inner4: i32 = 0;
    let ik: i32 = 0;
    unsafe {
      lanes_v = pipeline_type_array_size_at(arena, type_ref);
      inner4 = pipeline_type_elem_ref_at(arena, type_ref);
      ik = pipeline_type_kind_ord_at(arena, inner4);
    }
    let sn: i32 = pipeline_codegen_vector_type_copy(&scratch[0], 256, ik, lanes_v);
    if (sn > 0) {
      return cg_se_out_append_bytes(out, &scratch[0], sn);
    }
    sn = pipeline_codegen_type_kind_copy(&scratch[0], 256, 0);
    if (sn > 0) {
      return cg_se_out_append_bytes(out, &scratch[0], sn);
    }
    return -1;
  }
  // builtins
  let sn2: i32 = pipeline_codegen_type_kind_copy(&scratch[0], 256, ord);
  if (sn2 > 0) {
    return cg_se_out_append_bytes(out, &scratch[0], sn2);
  }
  sn2 = pipeline_codegen_type_kind_copy(&scratch[0], 256, 0);
  if (sn2 > 0) {
    return cg_se_out_append_bytes(out, &scratch[0], sn2);
  }
  return -1;
}

/**
 * Emit C type text for a struct field (codegen.x via_pipeline face).
 * @param arena *u8 - ASTArena*
 * @param out *u8 - CodegenOutBuf*
 * @param type_ref i32 - field type ref
 * @param struct_prefix *u8 - optional tag prefix
 * @param struct_prefix_len i32 - prefix length
 * @return i32 - 0 ok, -1 fail
 * wave110 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_emit_struct_field_type(arena: *u8, out: *u8, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  return pipeline_codegen_emit_struct_field_type_inner(arena, out, type_ref, struct_prefix, struct_prefix_len);
}

/**
 * Emit struct field declaration: type name or type name[n][m] for array chains.
 * Peels outermost TYPE_ARRAY chain only; inner types (e.g. ptr) via field_type emitter.
 * @param arena *u8 - ASTArena*
 * @param out *u8 - CodegenOutBuf*
 * @param type_ref i32 - field type ref
 * @param field_name *u8 - field name bytes
 * @param field_name_len i32 - name length
 * @param struct_prefix *u8 - optional tag prefix
 * @param struct_prefix_len i32 - prefix length
 * @return i32 - 0 ok, -1 fail
 * wave110 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_emit_struct_field_decl(arena: *u8, out: *u8, type_ref: i32, field_name: *u8, field_name_len: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  if (arena == 0 as *u8) {
    return -1;
  }
  if (out == 0 as *u8) {
    return -1;
  }
  if (type_ref <= 0) {
    return -1;
  }
  if (field_name == 0 as *u8) {
    return -1;
  }
  if (field_name_len <= 0) {
    return -1;
  }
  let base_type_ref: i32 = type_ref;
  let dims: i32[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let ndim: i32 = 0;
  while (base_type_ref > 0 && ndim < 8) {
    let kord: i32 = 0;
    unsafe {
      kord = pipeline_type_kind_ord_at(arena, base_type_ref);
    }
    if (kord != 10) {
      break;
    }
    unsafe {
      dims[ndim] = pipeline_type_array_size_at(arena, base_type_ref);
      base_type_ref = pipeline_type_elem_ref_at(arena, base_type_ref);
    }
    ndim = ndim + 1;
  }
  if (pipeline_codegen_emit_struct_field_type_inner(arena, out, base_type_ref, struct_prefix, struct_prefix_len) != 0) {
    return -1;
  }
  if (cg_se_out_append_byte(out, 32) != 0) {
    return -1;
  }
  if (cg_se_out_append_bytes(out, field_name, field_name_len) != 0) {
    return -1;
  }
  let i: i32 = 0;
  while (i < ndim) {
    if (cg_se_out_append_byte(out, 91) != 0) {
      return -1;
    }
    let d: i32 = 0;
    unsafe {
      d = dims[i];
    }
    if (cg_se_out_format_int(out, d) != 0) {
      return -1;
    }
    if (cg_se_out_append_byte(out, 93) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}

// ---------------------------------------------------------------------------
// wave111: codegen_dep pure-owned leave (was pipeline_codegen_dep.c).
// G.7 product authority for dep/entry codegen orchestration:
//   one_dep_emit / entry_emit / parse_entry_if_needed_c /
//   fill_dep_import_path_* / resolve_path_x_from_buf64_c /
//   prepare_dep_codegen_path_c / finish_dep_codegen_diag_c /
//   one_dep_c / deps_c / entry_c + entry_arena_for_mono BSS + path de-dupe.
// Omits XLANG_DEBUG_PIPE fprintf dump (wave106 style): product control-flow
//   for non-debug path unchanged (skip/rebind/emit still run).
// Cold twins under seed #ifndef FROM_X.
// PLATFORM: SHARED - dual-end L2 after leave.
// ---------------------------------------------------------------------------

/** Entry arena pointer for cross-dep mono while deps emit first (LP64 BSS). */
let g_codegen_entry_arena_for_mono: *u8 = 0 as *u8;

/**
 * Scan NUL-terminated path_buf length capped at 127 (dep_path_rows content).
 * @param path_buf *u8 - path bytes; null -> 0
 * @return i32 - length in [0,127]
 * wave111 pure private helper.
 * PLATFORM: SHARED.
 */
function cg_dep_path_len127(path_buf: *u8): i32 {
  if (path_buf == 0 as *u8) {
    return 0;
  }
  let path_len: i32 = 0;
  while (path_len < 127) {
    let b: u8 = 0 as u8;
    unsafe {
      b = path_buf[path_len];
    }
    if (b == 0 as u8) {
      break;
    }
    path_len = path_len + 1;
  }
  return path_len;
}

/**
 * Byte equality for path[0..n).
 * @param a *u8 - left
 * @param b *u8 - right
 * @param n i32 - length
 * @return i32 - 1 equal, 0 otherwise
 * wave111 pure private helper.
 * PLATFORM: SHARED.
 */
function cg_dep_path_eq(a: *u8, b: *u8, n: i32): i32 {
  if (a == 0 as *u8) {
    return 0;
  }
  if (b == 0 as *u8) {
    return 0;
  }
  if (n <= 0) {
    return 1;
  }
  let i: i32 = 0;
  while (i < n) {
    let ba: u8 = 0 as u8;
    let bb: u8 = 0 as u8;
    unsafe {
      ba = a[i];
      bb = b[i];
    }
    if (ba != bb) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * True if an earlier dep slot shares the same import path (de-dupe emit).
 * @param ctx *u8 - PipelineDepCtx*
 * @param dep_j i32 - current dep index
 * @return i32 - 1 if earlier same path, 0 otherwise
 * wave111 pure: G.7 single product authority (was static has_earlier_same_import_path_c).
 * PLATFORM: SHARED.
 */
function pipeline_dep_ctx_has_earlier_same_import_path_c(ctx: *u8, dep_j: i32): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  if (dep_j <= 0) {
    return 0;
  }
  let path_len: i32 = 0;
  unsafe {
    path_len = pipeline_dep_ctx_import_path_len(ctx, dep_j);
  }
  if (path_len <= 0) {
    return 0;
  }
  if (path_len > 128) {
    return 0;
  }
  let path_buf: u8[128] = [];
  unsafe {
    memset(&path_buf[0], 0, 128 as usize);
    pipeline_dep_ctx_import_path_copy64(ctx, dep_j, &path_buf[0]);
  }
  let prev_j: i32 = 0;
  while (prev_j < dep_j) {
    let prev_len: i32 = 0;
    unsafe {
      prev_len = pipeline_dep_ctx_import_path_len(ctx, prev_j);
    }
    if (prev_len == path_len && prev_len > 0 && prev_len <= 128) {
      let prev_buf: u8[128] = [];
      unsafe {
        memset(&prev_buf[0], 0, 128 as usize);
        pipeline_dep_ctx_import_path_copy64(ctx, prev_j, &prev_buf[0]);
      }
      if (cg_dep_path_eq(&prev_buf[0], &path_buf[0], path_len) != 0) {
        return 1;
      }
    }
    prev_j = prev_j + 1;
  }
  return 0;
}

/**
 * Emit one dep module via asm or C backend after skip/link-only gates.
 * Rebinds NULL dep_mod from driver_dep_* publish slots (wave578 Cap residual).
 * @param dep_mod *u8 - Module* (may be null; rebind from driver slots)
 * @param out_buf *u8 - CodegenOutBuf*
 * @param ctx *u8 - PipelineDepCtx*
 * @param dep_j i32 - dep index
 * @param skip_asm_dep_codegen i32 - non-zero skip co-emit
 * @param use_asm_backend i32 - non-zero -> asm_asm_codegen_ast else codegen_x_ast
 * @return i32 - 0 ok, -1 null, -6 emit fail
 * wave111 pure: G.7 single product authority.
 * PLATFORM: SHARED - sole provider after codegen_dep leave.
 */
#[no_mangle]
export function run_x_pipeline_codegen_one_dep_emit(dep_mod: *u8, out_buf: *u8, ctx: *u8, dep_j: i32, skip_asm_dep_codegen: i32, use_asm_backend: i32): i32 {
  if (out_buf == 0 as *u8) {
    return 0 - 1;
  }
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_j < 0) {
    return 0 - 1;
  }
  if (pipeline_dep_ctx_has_earlier_same_import_path_c(ctx, dep_j) != 0) {
    return 0;
  }
  let dep_path_buf: u8[128] = [];
  unsafe {
    memset(&dep_path_buf[0], 0, 128 as usize);
    pipeline_dep_ctx_import_path_copy64(ctx, dep_j, &dep_path_buf[0]);
  }
  let mod: *u8 = dep_mod;
  if (mod == 0 as *u8) {
    let sync_slot: i32 = 0;
    unsafe {
      sync_slot = driver_dep_slot_for_path(&dep_path_buf[0]);
    }
    if (sync_slot < 0) {
      sync_slot = dep_j;
    }
    unsafe {
      mod = driver_dep_module_buf(sync_slot);
    }
    if (mod != 0 as *u8) {
      let ar: *u8 = 0 as *u8;
      unsafe {
        ar = driver_dep_arena_buf(sync_slot);
        pipeline_dep_ctx_set_module(ctx, dep_j, mod);
        pipeline_dep_ctx_set_arena(ctx, dep_j, ar);
      }
    }
  }
  let skip_boot: i32 = 0;
  unsafe {
    skip_boot = pipeline_codegen_dep_skip_x_bootstrap_partial(&dep_path_buf[0]);
  }
  if (skip_boot != 0) {
    return 0;
  }
  let link_only: i32 = 0;
  unsafe {
    link_only = pipeline_codegen_std_dep_link_only(&dep_path_buf[0]);
  }
  if (link_only != 0) {
    return 0;
  }
  if (skip_asm_dep_codegen != 0) {
    return 0;
  }
  if (mod != 0 as *u8) {
    let nf: i32 = 0;
    unsafe {
      nf = pipeline_module_num_funcs(mod);
    }
    if (nf > 0) {
      let arena_j: *u8 = 0 as *u8;
      unsafe {
        arena_j = pipeline_dep_ctx_arena_at(ctx, dep_j);
      }
      if (use_asm_backend != 0) {
        let rc: i32 = 0;
        unsafe {
          rc = asm_asm_codegen_ast(mod, arena_j, out_buf, ctx);
        }
        if (rc != 0) {
          return 0 - 6;
        }
      } else {
        let rc2: i32 = 0;
        unsafe {
          rc2 = codegen_codegen_x_ast(mod, arena_j, out_buf, ctx, dep_j);
        }
        if (rc2 != 0) {
          return 0 - 6;
        }
      }
    }
  }
  return 0;
}

/**
 * Emit entry module via asm or C backend.
 * @param module *u8 - entry Module*
 * @param arena *u8 - entry ASTArena*
 * @param out_buf *u8 - CodegenOutBuf*
 * @param ctx *u8 - PipelineDepCtx*
 * @param use_asm_backend i32 - non-zero asm else C
 * @return i32 - 0 ok, -1 null, -6 emit fail
 * wave111 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function run_x_pipeline_codegen_entry_emit(module: *u8, arena: *u8, out_buf: *u8, ctx: *u8, use_asm_backend: i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (out_buf == 0 as *u8) {
    return 0 - 1;
  }
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (use_asm_backend != 0) {
    let rc: i32 = 0;
    unsafe {
      rc = asm_asm_codegen_ast(module, arena, out_buf, ctx);
    }
    if (rc != 0) {
      return 0 - 6;
    }
  } else {
    let rc2: i32 = 0;
    unsafe {
      rc2 = codegen_codegen_x_ast(module, arena, out_buf, ctx, 0 - 1);
    }
    if (rc2 != 0) {
      return 0 - 6;
    }
  }
  return 0;
}

/**
 * Parse entry if not already parsed; otherwise entry diags only.
 * @param module *u8 - Module*
 * @param arena *u8 - ASTArena*
 * @param source_data *u8 - source bytes
 * @param source_len i64 - length
 * @param ctx *u8 - PipelineDepCtx*
 * @return i32 - 0 ok/already, do_parse rc, -1 null
 * wave111 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function run_x_pipeline_parse_entry_if_needed_c(module: *u8, arena: *u8, source_data: *u8, source_len: i64, ctx: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  let already: i32 = 0;
  unsafe {
    already = pipeline_dep_ctx_entry_already_parsed(ctx);
    driver_diagnostic_entry_already(already);
  }
  if (already != 0) {
    let nf: i32 = 0;
    unsafe {
      nf = pipeline_module_num_funcs(module);
      driver_diagnostic_after_entry_parse(nf);
      driver_diagnostic_entry_module(module, arena);
    }
    return 0;
  }
  let rc: i32 = 0;
  unsafe {
    rc = run_x_pipeline_parse_entry_do_parse_c(module, arena, source_data, source_len, ctx);
  }
  return rc;
}

/**
 * If path_buf non-empty, write import_path on ctx slot dep_j.
 * @param ctx *u8 - PipelineDepCtx*
 * @param dep_j i32 - slot index
 * @param path_buf *u8 - NUL-terminated path (scan <=127)
 * @return i32 - 0 ok, -1 null/bad index
 * wave111 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_fill_dep_import_path_from_buf_c(ctx: *u8, dep_j: i32, path_buf: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (path_buf == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_j < 0) {
    return 0 - 1;
  }
  let path_len: i32 = cg_dep_path_len127(path_buf);
  if (path_len > 0) {
    unsafe {
      pipeline_dep_ctx_set_import_path(ctx, dep_j, path_buf, path_len);
    }
  }
  return 0;
}

/**
 * Scan path_buf length then pipeline_resolve_path_x.
 * @param ctx *u8 - PipelineDepCtx*
 * @param path_buf *u8 - NUL-terminated path
 * @return i32 - resolve rc, -1 null/empty
 * wave111 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_resolve_path_x_from_buf64_c(ctx: *u8, path_buf: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (path_buf == 0 as *u8) {
    return 0 - 1;
  }
  let path_len: i32 = cg_dep_path_len127(path_buf);
  if (path_len <= 0) {
    return 0 - 1;
  }
  let rc: i32 = 0;
  unsafe {
    rc = pipeline_resolve_path_x(ctx, path_buf, path_len);
  }
  return rc;
}

/**
 * Fill empty ctx import_path slot from entry module import[dep_j].
 * Preserves non-empty ctx path (closure seed authority; wave net/driver bugfix).
 * @param module *u8 - entry Module*
 * @param ctx *u8 - PipelineDepCtx*
 * @param dep_j i32 - slot index
 * @return i32 - 0 ok, -1 null
 * wave111 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function run_x_pipeline_fill_dep_import_path_c(module: *u8, ctx: *u8, dep_j: i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_j < 0) {
    return 0 - 1;
  }
  let existing: i32 = 0;
  unsafe {
    existing = pipeline_dep_ctx_import_path_len(ctx, dep_j);
  }
  if (existing > 0) {
    return 0;
  }
  let path_buf: u8[128] = [];
  unsafe {
    memset(&path_buf[0], 0, 128 as usize);
    parser_copy_module_import_path64(module, dep_j, &path_buf[0]);
  }
  let path_len: i32 = cg_dep_path_len127(&path_buf[0]);
  if (path_len > 0) {
    unsafe {
      pipeline_dep_ctx_set_import_path(ctx, dep_j, &path_buf[0], path_len);
    }
  }
  return 0;
}

/**
 * Copy dep path into dst and set current dep path for codegen prefix.
 * @param ctx *u8 - PipelineDepCtx*
 * @param dep_j i32 - slot
 * @param dst *u8 - out path buf (>=128)
 * @return i32 - 0 ok, -1 null
 * wave111 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_prepare_dep_codegen_path_c(ctx: *u8, dep_j: i32, dst: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (dst == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_j < 0) {
    return 0 - 1;
  }
  unsafe {
    pipeline_dep_ctx_import_path_copy64(ctx, dep_j, dst);
    driver_set_current_dep_path_for_codegen(dst);
  }
  return 0;
}

/**
 * After dep emit: diag with out_buf len and clear current dep path prefix.
 * @param dep_j i32 - dep index
 * @param out_buf *u8 - CodegenOutBuf*
 * @return i32 - 0 ok, -1 null out_buf
 * wave111 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_finish_dep_codegen_diag_c(dep_j: i32, out_buf: *u8): i32 {
  if (out_buf == 0 as *u8) {
    return 0 - 1;
  }
  let olen: i32 = 0;
  unsafe {
    olen = codegen_out_buf_len(out_buf);
    driver_diagnostic_after_dep_codegen(dep_j, olen);
    driver_set_current_dep_path_for_codegen(0 as *u8);
  }
  return 0;
}

/**
 * One-dep codegen orchestration: fill path, prepare, skip gates, emit, finish diag.
 * @param module *u8 - entry Module* (for fill_dep import)
 * @param out_buf *u8 - CodegenOutBuf*
 * @param ctx *u8 - PipelineDepCtx*
 * @param dep_j i32 - dep index
 * @param skip_asm_dep_codegen i32 - skip co-emit
 * @return i32 - 0 ok/skip, -1 null, -6 emit fail
 * wave111 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function run_x_pipeline_codegen_one_dep_c(module: *u8, out_buf: *u8, ctx: *u8, dep_j: i32, skip_asm_dep_codegen: i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (out_buf == 0 as *u8) {
    return 0 - 1;
  }
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_j < 0) {
    return 0 - 1;
  }
  if (dep_j == 0) {
    let sk0: i32 = 0;
    unsafe {
      sk0 = driver_skip_codegen_dep_0_get();
    }
    if (sk0 != 0) {
      return 0;
    }
  }
  if (run_x_pipeline_fill_dep_import_path_c(module, ctx, dep_j) != 0) {
    return 0 - 1;
  }
  let dep_path_buf: u8[128] = [];
  unsafe {
    memset(&dep_path_buf[0], 0, 128 as usize);
  }
  if (pipeline_prepare_dep_codegen_path_c(ctx, dep_j, &dep_path_buf[0]) != 0) {
    return 0 - 1;
  }
  let dep_mod: *u8 = 0 as *u8;
  unsafe {
    dep_mod = pipeline_dep_ctx_module_at(ctx, dep_j);
  }
  if (dep_mod == 0 as *u8) {
    let sync_slot: i32 = 0;
    unsafe {
      sync_slot = driver_dep_slot_for_path(&dep_path_buf[0]);
    }
    if (sync_slot < 0) {
      sync_slot = dep_j;
    }
    unsafe {
      dep_mod = driver_dep_module_buf(sync_slot);
    }
    if (dep_mod != 0 as *u8) {
      let ar: *u8 = 0 as *u8;
      unsafe {
        ar = driver_dep_arena_buf(sync_slot);
        pipeline_dep_ctx_set_module(ctx, dep_j, dep_mod);
        pipeline_dep_ctx_set_arena(ctx, dep_j, ar);
      }
    }
  }
  let skip_boot: i32 = 0;
  unsafe {
    skip_boot = pipeline_codegen_dep_skip_x_bootstrap_partial(&dep_path_buf[0]);
  }
  if (skip_boot != 0) {
    unsafe {
      driver_set_current_dep_path_for_codegen(0 as *u8);
    }
    return 0;
  }
  let use_asm: i32 = 0;
  unsafe {
    use_asm = pipeline_dep_ctx_use_asm_backend(ctx);
  }
  if (run_x_pipeline_codegen_one_dep_emit(dep_mod, out_buf, ctx, dep_j, skip_asm_dep_codegen, use_asm) != 0) {
    unsafe {
      driver_diagnostic_codegen_fail(dep_j, 1);
    }
    return 0 - 6;
  }
  pipeline_finish_dep_codegen_diag_c(dep_j, out_buf);
  return 0;
}

/**
 * Entry arena for mono while deps emit before entry (set in deps_c).
 * @return *u8 - ASTArena* or null
 * wave111 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_codegen_entry_arena_for_mono_get(): *u8 {
  return g_codegen_entry_arena_for_mono;
}

/**
 * Codegen all deps: stash entry arena, reset C prologue, loop one_dep_c with de-dupe.
 * @param module *u8 - entry Module*
 * @param arena *u8 - entry arena (mono scan)
 * @param out_buf *u8 - CodegenOutBuf*
 * @param ctx *u8 - PipelineDepCtx*
 * @param skip_asm_dep_codegen i32 - skip co-emit for deps
 * @return i32 - 0 ok, -1 null, -6 dep fail
 * wave111 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function run_x_pipeline_codegen_deps_c(module: *u8, arena: *u8, out_buf: *u8, ctx: *u8, skip_asm_dep_codegen: i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (out_buf == 0 as *u8) {
    return 0 - 1;
  }
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  g_codegen_entry_arena_for_mono = arena;
  unsafe {
    pipeline_codegen_c_file_prologue_done_reset();
  }
  let ndep: i32 = 0;
  unsafe {
    ndep = pipeline_dep_ctx_ndep(ctx);
  }
  let j: i32 = 0;
  while (j < ndep) {
    if (pipeline_dep_ctx_has_earlier_same_import_path_c(ctx, j) != 0) {
      j = j + 1;
      continue;
    }
    if (run_x_pipeline_codegen_one_dep_c(module, out_buf, ctx, j, skip_asm_dep_codegen) != 0) {
      return 0 - 6;
    }
    j = j + 1;
  }
  return 0;
}

/**
 * Entry module final codegen orchestration with entry_module diag.
 * @param module *u8 - entry Module*
 * @param arena *u8 - ASTArena*
 * @param out_buf *u8 - CodegenOutBuf*
 * @param ctx *u8 - PipelineDepCtx*
 * @return i32 - 0 ok, -1 null, -6 emit fail
 * wave111 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function run_x_pipeline_codegen_entry_c(module: *u8, arena: *u8, out_buf: *u8, ctx: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (out_buf == 0 as *u8) {
    return 0 - 1;
  }
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    driver_diagnostic_entry_module(module, arena);
  }
  let use_asm: i32 = 0;
  unsafe {
    use_asm = pipeline_dep_ctx_use_asm_backend(ctx);
  }
  if (run_x_pipeline_codegen_entry_emit(module, arena, out_buf, ctx, use_asm) != 0) {
    unsafe {
      driver_diagnostic_codegen_fail(0, 0);
    }
    return 0 - 6;
  }
  return 0;
}

// ---------------------------------------------------------------------------
// wave112: parse_typeck_dispatch pure-owned leave (was pipeline_parse_typeck_dispatch.c).
// G.7 product authority for:
//   parse scalars BSS + ok/main getters + fail_diag + buf/slice sidecar scalars
//   + apply_main_from_scalars_c + typeck_parsed/entry_module_c
//   + should_skip_x_typeck_c + load_import_resolve_read_c + load_one_import_slot_c.
// Already pure same-TU (wave93+): realign_ndep / load_and_sync / parse_set_main_from_buf_c
//   / try_bind / load_import_from_disk_c / resolve_path_x / read_file_x.
// Cap residual (host-cc, not this leave):
//   pipeline_parse_into_with_init_buf_impl_rc / pipeline_parse_into_with_init_result_c
//   in pipeline_parse_orch.c (Cap-struct-return unpack / pack).
// Omits XLANG_DEBUG_PIPE fprintf dump (wave106 style).
// Cold twins under seed #ifndef FROM_X.
// PLATFORM: SHARED - dual-end L2 after leave.
// ---------------------------------------------------------------------------

/** Parse scalars sidecar BSS (EMIT_HEAVY / pure avoid by-value ParseIntoResult). */
let g_pipeline_parse_scalars_ok: i32 = 0;
let g_pipeline_parse_scalars_main_idx: i32 = 0 - 1;

/**
 * Read parse scalars ok flag (0 = parse success).
 * @return i32 - last pipeline_parse_into_with_init_buf_scalars ok
 * wave112 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_parse_scalars_ok_get(): i32 {
  return g_pipeline_parse_scalars_ok;
}

/**
 * Read parse scalars main_idx.
 * @return i32 - last main_idx (-1 when library / fail)
 * wave112 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_parse_scalars_main_idx_get(): i32 {
  return g_pipeline_parse_scalars_main_idx;
}

/**
 * Asm -o / precheck: skip .x typeck when driver skip flags + asm entry-only.
 * @param ctx *u8 - PipelineDepCtx*; null -> 0
 * @return i32 - 1 skip typeck, 0 run typeck
 * wave112 pure: G.7 single product authority for _c face (pipeline.x owns non-_c).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_should_skip_x_typeck_c(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  let skip_x: i32 = 0;
  unsafe {
    skip_x = pipeline_driver_x_pipeline_skip_typeck();
  }
  if (skip_x != 0) {
    return 1;
  }
  let asm_only: i32 = 0;
  unsafe {
    asm_only = pipeline_dep_ctx_asm_entry_module_only(ctx);
  }
  if (asm_only == 0) {
    return 0;
  }
  let asm_skip: i32 = 0;
  unsafe {
    asm_skip = pipeline_driver_asm_build_skip_typeck();
  }
  if (asm_skip != 0) {
    return 1;
  }
  return 0;
}

/**
 * Parse-fail diagnostic from scalars sidecar (main_idx + num_funcs + num_types).
 * @param module *u8 - Module*; null -> no-op
 * @param arena *u8 - ASTArena*; null -> no-op
 * @return void
 * wave112 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_parse_fail_diag_scalars_c(module: *u8, arena: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  if (arena == 0 as *u8) {
    return;
  }
  unsafe {
    driver_diagnostic_parse_fail(g_pipeline_parse_scalars_main_idx, pipeline_module_num_funcs(module),
                                 pipeline_arena_num_types(arena));
  }
}

/**
 * Parse with full strict init into scalars BSS; optional out_ok/out_main_idx.
 * Cap residual pipeline_parse_into_with_init_buf_impl_rc unpacks Cap-struct-return.
 * @param arena *u8 - ASTArena*
 * @param module *u8 - Module*
 * @param data *u8 - source bytes
 * @param len i32 - byte length
 * @param out_ok *i32 - optional; written when non-null
 * @param out_main_idx *i32 - optional; written when non-null
 * @return i32 - always 0 (status via scalars / outs)
 * wave112 pure: G.7 single product authority (was host-cc dispatch).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_parse_into_with_init_buf_scalars(arena: *u8, module: *u8, data: *u8, len: i32, out_ok: *i32, out_main_idx: *i32): i32 {
  if (arena == 0 as *u8 || module == 0 as *u8 || data == 0 as *u8 || len <= 0) {
    g_pipeline_parse_scalars_ok = 1;
    g_pipeline_parse_scalars_main_idx = 0 - 1;
    if (out_ok != 0 as *i32) {
      unsafe {
        out_ok[0] = g_pipeline_parse_scalars_ok;
      }
    }
    if (out_main_idx != 0 as *i32) {
      unsafe {
        out_main_idx[0] = g_pipeline_parse_scalars_main_idx;
      }
    }
    return 0;
  }
  let ok: i32 = 1;
  let main_idx: i32 = 0 - 1;
  unsafe {
    pipeline_parse_into_with_init_buf_impl_rc(arena, module, data, len, &ok, &main_idx);
  }
  g_pipeline_parse_scalars_ok = ok;
  g_pipeline_parse_scalars_main_idx = main_idx;
  if (out_ok != 0 as *i32) {
    unsafe {
      out_ok[0] = ok;
    }
  }
  if (out_main_idx != 0 as *i32) {
    unsafe {
      out_main_idx[0] = main_idx;
    }
  }
  return 0;
}

/**
 * Sidecar scalars without out-params (EMIT_HEAVY avoid *i32 outs).
 * @param arena *u8 - ASTArena*
 * @param module *u8 - Module*
 * @param data *u8 - source bytes
 * @param len i32 - byte length
 * @return i32 - 0
 * wave112 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_parse_into_with_init_buf_scalars_sidecar(arena: *u8, module: *u8, data: *u8, len: i32): i32 {
  return pipeline_parse_into_with_init_buf_scalars(arena, module, data, len, 0 as *i32, 0 as *i32);
}

/**
 * Slice path sidecar: LP64 xlang_slice_uint8_t { data@0, length@8 }.
 * @param arena *u8 - ASTArena*
 * @param module *u8 - Module*
 * @param source *u8 - *xlang_slice_uint8_t; null/empty -> null-gate scalars
 * @return i32 - 0
 * wave112 pure: G.7 single product authority.
 * PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function pipeline_parse_into_with_init_slice_scalars_sidecar(arena: *u8, module: *u8, source: *u8): i32 {
  if (source == 0 as *u8) {
    return pipeline_parse_into_with_init_buf_scalars(arena, module, 0 as *u8, 0, 0 as *i32, 0 as *i32);
  }
  let data: *u8 = pipe_load_ptr_slot(source, 0);
  let length_i64: i64 = xlang_size_slot_get(source, 1);
  if (data == 0 as *u8 || length_i64 == 0) {
    return pipeline_parse_into_with_init_buf_scalars(arena, module, 0 as *u8, 0, 0 as *i32, 0 as *i32);
  }
  let len: i32 = 0;
  if (length_i64 > 2147483647) {
    len = 2147483647;
  } else {
    len = length_i64 as i32;
  }
  return pipeline_parse_into_with_init_buf_scalars(arena, module, data, len, 0 as *i32, 0 as *i32);
}

/**
 * Apply scalars ok/main to module.main; parse fail -> diag + -2.
 * @param module *u8 - Module*; null -> -2
 * @param arena *u8 - ASTArena*; null -> -2
 * @return i32 - 0 ok, -2 fail
 * wave112 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_parse_apply_main_from_scalars_c(module: *u8, arena: *u8): i32 {
  if (module == 0 as *u8 || arena == 0 as *u8) {
    return 0 - 2;
  }
  let ok: i32 = pipeline_parse_scalars_ok_get();
  let main_idx: i32 = pipeline_parse_scalars_main_idx_get();
  if (ok != 0) {
    pipeline_parse_fail_diag_scalars_c(module, arena);
    return 0 - 2;
  }
  unsafe {
    pipeline_module_set_main_func_index(module, main_idx);
  }
  return 0;
}

/**
 * Typeck already-parsed module: set active ctx, library vs entry typeck_x_ast*,
 * WPO-S3 stack-escape scan, unused-private lint.
 * @param module *u8 - Module*
 * @param arena *u8 - ASTArena*
 * @param ctx *u8 - PipelineDepCtx*
 * @param fail_mapped i32 - non-zero maps typeck fail to this code (LSP -3)
 * @return i32 - 0 ok; fail_mapped or typeck rc on fail; -1 null without fail_mapped
 * wave112 pure: G.7 single product authority.
 * PLATFORM: SHARED - Cap residual set_active / scan / unused_private / typeck_x_ast*.
 */
#[no_mangle]
export function pipeline_typeck_parsed_module_c(module: *u8, arena: *u8, ctx: *u8, fail_mapped: i32): i32 {
  if (module == 0 as *u8 || arena == 0 as *u8 || ctx == 0 as *u8) {
    if (fail_mapped != 0) {
      return fail_mapped;
    }
    return 0 - 1;
  }
  let nf: i32 = 0;
  unsafe {
    nf = pipeline_module_num_funcs(module);
  }
  // Empty module: force library typeck (main_idx 0 after memset is not a real main).
  if (nf == 0) {
    unsafe {
      pipeline_module_set_main_func_index(module, 0 - 1);
    }
  }
  unsafe {
    pipeline_typeck_set_active_ctx_c(module, ctx);
    pipeline_typeck_set_dep_ctx(ctx);
  }
  let main_idx: i32 = 0;
  unsafe {
    main_idx = pipeline_module_main_func_index(module);
  }
  if (main_idx < 0) {
    let tc_lib: i32 = 0;
    unsafe {
      tc_lib = typeck_x_ast_library(module, arena, ctx);
    }
    if (tc_lib != 0) {
      unsafe {
        driver_diagnostic_typeck_fail();
      }
      if (fail_mapped != 0) {
        return fail_mapped;
      }
      return tc_lib;
    }
    let esc: i32 = 0;
    unsafe {
      esc = pipeline_typeck_scan_module_struct_stack_escape_c(module, arena, ctx);
    }
    if (esc != 0) {
      unsafe {
        driver_diagnostic_typeck_fail();
      }
      if (fail_mapped != 0) {
        return fail_mapped;
      }
      return 0 - 1;
    }
    unsafe {
      let _u: i32 = pipeline_typeck_unused_private_funcs(module, arena);
    }
    return 0;
  }
  unsafe {
    pipeline_typeck_set_dep_ctx(ctx);
  }
  let tc: i32 = 0;
  unsafe {
    tc = typeck_x_ast(module, arena, ctx);
  }
  if (tc != 0) {
    unsafe {
      driver_diagnostic_typeck_fail();
    }
    if (fail_mapped != 0) {
      return fail_mapped;
    }
    return tc;
  }
  let esc2: i32 = 0;
  unsafe {
    esc2 = pipeline_typeck_scan_module_struct_stack_escape_c(module, arena, ctx);
  }
  if (esc2 != 0) {
    unsafe {
      driver_diagnostic_typeck_fail();
    }
    if (fail_mapped != 0) {
      return fail_mapped;
    }
    return 0 - 1;
  }
  unsafe {
    let _u2: i32 = pipeline_typeck_unused_private_funcs(module, arena);
  }
  return 0;
}

/**
 * Entry typeck face: typeck_parsed_module_c with fail_mapped=0.
 * @param module *u8 - Module*
 * @param arena *u8 - ASTArena*
 * @param ctx *u8 - PipelineDepCtx*
 * @return i32 - 0 ok; -1 null; typeck rc
 * wave112 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_typeck_entry_module_c(module: *u8, arena: *u8, ctx: *u8): i32 {
  if (module == 0 as *u8 || arena == 0 as *u8 || ctx == 0 as *u8) {
    return 0 - 1;
  }
  return pipeline_typeck_parsed_module_c(module, arena, ctx, 0);
}

/**
 * Resolve one import path + read file into ctx loaded buffers.
 * @param module *u8 - Module*
 * @param ctx *u8 - PipelineDepCtx*
 * @param import_idx i32 - import index
 * @return i32 - 0 ok; -1 null/bad idx; -7 resolve fail; -8 read fail
 * wave112 pure: G.7 single product authority.
 * PLATFORM: SHARED - Cap residual path64 + pure resolve/read.
 */
#[no_mangle]
export function pipeline_load_import_resolve_read_c(module: *u8, ctx: *u8, import_idx: i32): i32 {
  if (module == 0 as *u8 || ctx == 0 as *u8 || import_idx < 0) {
    return 0 - 1;
  }
  let path_buf: u8[128] = [];
  let path_len: i32 = 0;
  unsafe {
    memset(&path_buf[0], 0, 128 as usize);
    path_len = parser_copy_module_import_path64(module, import_idx, &path_buf[0]);
  }
  let rr: i32 = 0;
  unsafe {
    rr = pipeline_resolve_path_x(ctx, &path_buf[0], path_len);
  }
  if (rr != 0) {
    return 0 - 7;
  }
  let rf: i32 = 0;
  unsafe {
    rf = pipeline_read_file_x(ctx);
  }
  if (rf != 0) {
    return 0 - 8;
  }
  return 0;
}

/**
 * Load one import slot: try seed bind else disk load.
 * @param module *u8 - Module*
 * @param arena *u8 - ASTArena*
 * @param ctx *u8 - PipelineDepCtx*
 * @param import_idx i32 - import index
 * @return i32 - 0 ok/bound; -1 null; else load_import rc
 * wave112 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_load_one_import_slot_c(module: *u8, arena: *u8, ctx: *u8, import_idx: i32): i32 {
  if (module == 0 as *u8 || arena == 0 as *u8 || ctx == 0 as *u8 || import_idx < 0) {
    return 0 - 1;
  }
  let path_buf: u8[128] = [];
  let gs: i32 = 0;
  unsafe {
    memset(&path_buf[0], 0, 128 as usize);
    let _pl: i32 = parser_copy_module_import_path64(module, import_idx, &path_buf[0]);
    gs = driver_dep_slot_for_path(&path_buf[0]);
  }
  let bound: i32 = 0;
  unsafe {
    bound = pipeline_try_bind_seeded_import(ctx, import_idx, gs);
  }
  if (bound != 0) {
    return 0;
  }
  let rc: i32 = 0;
  unsafe {
    rc = pipeline_load_import_from_disk_c(module, arena, ctx, import_idx);
  }
  return rc;
}

// ---------------------------------------------------------------------------
// wave113: backend_asm_wrapper pure-owned leave (was pipeline_backend_asm_wrapper.c).
// G.7 product authority for:
//   pipeline_backend_asm_codegen_ast_c
//   pipeline_backend_asm_codegen_ast_to_elf_c
// Thin M8-tail faces: hoist top-level lets, merge/unify SoA when typeck skipped,
// set emit pipe/module/arena/elf_ctx, then seed partial mega / mega_body + WPO thunks.
// Omits XLANG_ASM_DEBUG fprintf + parser_emit_heavy debug branch (wave106 style).
// Cap residual (host-cc, not this leave): hoist, seed mega, emit_set_*, mega_body,
//   wpo_mono reset/thunks, elf_label_mod_scope, typeck merge/wpo/soa fill.
// Cold twins under seed #ifndef FROM_X.
// PLATFORM: SHARED - dual-end L2 after leave.
// ---------------------------------------------------------------------------

/**
 * LP64 offsetof(struct ast_Module, num_top_level_lets).
 * Layout: num_funcs@0 main_func_index@4 num_imports@8 num_top_level_lets@12.
 * @return i32 - 12
 * PLATFORM: SHARED LP64 - dual-end with sizeof Module=68.
 */
function pipe_mod_off_num_top_level_lets(): i32 {
  return 12;
}

/**
 * Read module.num_top_level_lets (null -> 0).
 * @param module *u8 - opaque ast_Module
 * @return i32 - header count
 * PLATFORM: SHARED LP64.
 */
function pipe_mod_get_num_top_level_lets(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(module, pipe_mod_off_num_top_level_lets());
}

/**
 * M8-tail thin face for backend.x asm_codegen_ast: hoist then seed mega.
 * @param m *u8 - Module*; null -> -1
 * @param a *u8 - ASTArena*; null -> -1
 * @param out *u8 - CodegenOutBuf*; null -> -1
 * @param pipeline_ctx *u8 - PipelineDepCtx*; null -> -1
 * @return i32 - seed mega rc; -1 null gate
 * wave113 pure: G.7 single product authority.
 * PLATFORM: SHARED - Cap residual hoist + backend_asm_codegen_ast_seed_mega.
 */
#[no_mangle]
export function pipeline_backend_asm_codegen_ast_c(m: *u8, a: *u8, out: *u8, pipeline_ctx: *u8): i32 {
  if (m == 0 as *u8 || a == 0 as *u8 || out == 0 as *u8 || pipeline_ctx == 0 as *u8) {
    return 0 - 1;
  }
  let nlets: i32 = pipe_mod_get_num_top_level_lets(m);
  if (nlets > 0) {
    unsafe {
      pipeline_module_hoist_top_level_lets_into_main(m, a);
    }
  }
  let rc: i32 = 0;
  unsafe {
    rc = backend_asm_codegen_ast_seed_mega(m, a, out, pipeline_ctx);
  }
  return rc;
}

/**
 * M8-tail thin face for backend.x asm_codegen_ast_to_elf:
 * hoist, merge dep SoA, unify WPO, fill ARRAY_LIT/FIELD_ACCESS, mega_body + WPO thunks.
 * @param m *u8 - Module*; null -> -1
 * @param a *u8 - ASTArena*; null -> -1
 * @param elf_ctx *u8 - ElfCodegenCtx*; null -> -1
 * @param pipeline_ctx *u8 - PipelineDepCtx*; null -> -1
 * @return i32 - mega_body/wpo rc; -1 null gate
 * wave113 pure: G.7 single product authority.
 * PLATFORM: SHARED - Cap residual emit_set / mega_body / wpo / typeck merge faces.
 */
#[no_mangle]
export function pipeline_backend_asm_codegen_ast_to_elf_c(m: *u8, a: *u8, elf_ctx: *u8, pipeline_ctx: *u8): i32 {
  if (m == 0 as *u8 || a == 0 as *u8 || elf_ctx == 0 as *u8 || pipeline_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    pipeline_debug_trace_named_func_bodies("backend_pre_hoist_top_level_lets", m, a);
  }
  let nlets: i32 = pipe_mod_get_num_top_level_lets(m);
  if (nlets > 0) {
    unsafe {
      pipeline_module_hoist_top_level_lets_into_main(m, a);
    }
  }
  unsafe {
    pipeline_debug_trace_named_func_bodies("backend_post_hoist_top_level_lets", m, a);
    // DOD-S3: even when .x typeck is skipped, merge dep SoA into entry then promote.
    pipeline_debug_trace_named_func_bodies("backend_pre_merge_dep_layouts", m, a);
    typeck_merge_dep_struct_layouts_into_entry(m, a, pipeline_ctx);
    pipeline_debug_trace_named_func_bodies("backend_post_merge_dep_layouts", m, a);
    typeck_wpo_unify_soa_layouts(m, pipeline_ctx);
    pipeline_debug_trace_named_func_bodies("backend_post_unify_soa_layouts", m, a);
    // dep co-emit and entry need SoA stride / param types / FIELD_ACCESS offs.
    pipeline_asm_emit_set_dep_pipe(pipeline_ctx);
  }
  pipeline_fill_array_lit_types_for_skipped_typeck(m, a);
  unsafe {
    typeck_soa_fill_field_access_for_asm_emit(m, a);
    glue_wpo_mono_reset_pending();
    // dep+entry write same elf_ctx: unique scope for tail_join/loop local labels.
    pipeline_elf_label_mod_scope_begin_module();
    // WPO-S3: import struct FIELD_ACCESS must see dep pool (backend.x mega also sets).
    pipeline_asm_emit_set_module(m);
    pipeline_asm_emit_set_arena(a);
    pipeline_asm_emit_set_elf_ctx(elf_ctx);
  }
  let rc: i32 = 0;
  unsafe {
    rc = pipeline_backend_asm_codegen_ast_to_elf_mega_body_c(m, a, elf_ctx, pipeline_ctx);
    pipeline_asm_emit_set_elf_ctx(0 as *u8);
  }
  if (rc != 0) {
    return rc;
  }
  unsafe {
    rc = pipeline_asm_emit_wpo_mono_thunks_elf_c(m, a, elf_ctx, pipeline_ctx);
  }
  return rc;
}

// ---------------------------------------------------------------------------
// wave114: asm_ctx_loop pure-owned leave (was pipeline_asm_ctx_loop.c).
// G.7 product authority for:
//   asm_ctx_loop_reset / asm_ctx_loop_push / asm_ctx_loop_pop / asm_ctx_loop_depth
//   asm_be_cont_reset / asm_be_cont_suspend / asm_be_cont_resume / asm_be_cont_depth
// Fixed-cap BSS (no GrowVec / no host-cc mega-TU). Cold twins under seed #ifndef FROM_X.
// Historical leaf had no remaining in-tree call sites after backend.x inlined loop stacks
// on AsmFuncCtx; faces stay exported for product link surface + future host-cc emit.
// PLATFORM: SHARED - dual-end L2 after leave.
// ---------------------------------------------------------------------------

/**
 * Find loop-label sidecar slot for AsmFuncCtx key, optionally allocate free slot.
 * @param ctx *u8 - AsmFuncCtx* key; null -> -1
 * @param create i32 - non-zero to claim first free slot when missing
 * @return i32 - slot index 0..63, or -1 if null / full / not found without create
 * wave114 pure helper. PLATFORM: SHARED - 64-slot table ≡ MAX_ASM_LOCALS_SIDECARS.
 */
function loop_sc_find(ctx: *u8, create: i32): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  let i: i32 = 0;
  while (i < 64) {
    if (g_pipe_loop_used[i] != 0) {
      let st: *u8 = xlang_ptr_slot_get(&g_pipe_loop_ctx[0], i);
      if (st == ctx) {
        return i;
      }
    }
    i = i + 1;
  }
  if (create == 0) {
    return 0 - 1;
  }
  i = 0;
  while (i < 64) {
    if (g_pipe_loop_used[i] == 0) {
      g_pipe_loop_used[i] = 1;
      xlang_ptr_slot_set(&g_pipe_loop_ctx[0], i, ctx);
      g_pipe_loop_depth[i] = 0;
      return i;
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Clear loop break/continue label stack for one AsmFuncCtx key (keep slot occupied).
 * @param ctx *u8 - AsmFuncCtx*; null / unknown -> no-op
 * @return void
 * wave114 pure: G.7 single product authority (historical asm_ctx_loop_reset).
 * PLATFORM: SHARED - sole provider after asm_ctx_loop leave.
 */
#[no_mangle]
export function asm_ctx_loop_reset(ctx: *u8): void {
  let s: i32 = loop_sc_find(ctx, 0);
  if (s < 0) {
    return;
  }
  g_pipe_loop_depth[s] = 0;
}

/**
 * Push one break/continue label frame (depth cap 8; each label row 64B store).
 * @param ctx *u8 - AsmFuncCtx* key; null -> -1
 * @param exit_buf *u8 - break/exit label bytes; null -> -1
 * @param exit_len i32 - full break length stored in lens[]; bytes clamped to 64
 * @param loop_buf *u8 - continue/loop label bytes; null -> -1
 * @param loop_len i32 - full continue length stored in lens[]; bytes clamped to 64
 * @return i32 - 0 ok; -1 null / table full / depth>=8 / negative lens
 * wave114 pure: G.7 single product authority (historical asm_ctx_loop_push).
 * PLATFORM: SHARED - base = depth*64 inside per-slot 512B stacks.
 */
#[no_mangle]
export function asm_ctx_loop_push(ctx: *u8, exit_buf: *u8, exit_len: i32, loop_buf: *u8, loop_len: i32): i32 {
  if (ctx == 0 as *u8 || exit_buf == 0 as *u8 || loop_buf == 0 as *u8) {
    return 0 - 1;
  }
  if (exit_len < 0 || loop_len < 0) {
    return 0 - 1;
  }
  let s: i32 = loop_sc_find(ctx, 1);
  if (s < 0) {
    return 0 - 1;
  }
  let d: i32 = g_pipe_loop_depth[s];
  if (d >= 8) {
    return 0 - 1;
  }
  let base: i32 = d * 64;
  let sc_base: i32 = s * 512;
  let n: i32 = exit_len;
  if (n > 64) {
    n = 64;
  }
  let k: i32 = 0;
  while (k < n) {
    unsafe {
      g_pipe_loop_break[sc_base + base + k] = exit_buf[k];
    }
    k = k + 1;
  }
  g_pipe_loop_break_lens[s * 8 + d] = exit_len;
  let m: i32 = loop_len;
  if (m > 64) {
    m = 64;
  }
  k = 0;
  while (k < m) {
    unsafe {
      g_pipe_loop_cont[sc_base + base + k] = loop_buf[k];
    }
    k = k + 1;
  }
  g_pipe_loop_cont_lens[s * 8 + d] = loop_len;
  g_pipe_loop_depth[s] = d + 1;
  return 0;
}

/**
 * Pop one loop frame; if outer remains, copy its break/continue into out buffers.
 * @param ctx *u8 - AsmFuncCtx* key; null -> no-op
 * @param break_out *u8 - optional break label dst
 * @param break_cap i32 - break_out capacity (stores min(bl, cap-1) bytes)
 * @param break_len_out *i32 - optional; receives full stored break len (not clamp)
 * @param cont_out *u8 - optional continue label dst
 * @param cont_cap i32 - cont_out capacity
 * @param cont_len_out *i32 - optional; receives full stored continue len
 * @return void
 * wave114 pure: G.7 single product authority (historical asm_ctx_loop_pop).
 * PLATFORM: SHARED - after pop depth==0 does not write outs (matches C).
 */
#[no_mangle]
export function asm_ctx_loop_pop(ctx: *u8, break_out: *u8, break_cap: i32, break_len_out: *i32,
                                cont_out: *u8, cont_cap: i32, cont_len_out: *i32): void {
  if (break_len_out != 0 as *i32) {
    xlang_i32_store(break_len_out, 0);
  }
  if (cont_len_out != 0 as *i32) {
    xlang_i32_store(cont_len_out, 0);
  }
  if (ctx == 0 as *u8) {
    return;
  }
  let s: i32 = loop_sc_find(ctx, 0);
  if (s < 0) {
    return;
  }
  if (g_pipe_loop_depth[s] <= 0) {
    return;
  }
  g_pipe_loop_depth[s] = g_pipe_loop_depth[s] - 1;
  let d: i32 = g_pipe_loop_depth[s];
  if (d <= 0) {
    return;
  }
  let prev: i32 = d - 1;
  let base: i32 = prev * 64;
  let sc_base: i32 = s * 512;
  let bl: i32 = g_pipe_loop_break_lens[s * 8 + prev];
  let cl: i32 = g_pipe_loop_cont_lens[s * 8 + prev];
  if (break_out != 0 as *u8 && break_len_out != 0 as *i32 && break_cap > 0) {
    let bn: i32 = bl;
    if (bn > break_cap - 1) {
      bn = break_cap - 1;
    }
    let k: i32 = 0;
    while (k < bn) {
      unsafe {
        break_out[k] = g_pipe_loop_break[sc_base + base + k];
      }
      k = k + 1;
    }
    xlang_i32_store(break_len_out, bl);
  }
  if (cont_out != 0 as *u8 && cont_len_out != 0 as *i32 && cont_cap > 0) {
    let cn: i32 = cl;
    if (cn > cont_cap - 1) {
      cn = cont_cap - 1;
    }
    let k2: i32 = 0;
    while (k2 < cn) {
      unsafe {
        cont_out[k2] = g_pipe_loop_cont[sc_base + base + k2];
      }
      k2 = k2 + 1;
    }
    xlang_i32_store(cont_len_out, cl);
  }
}

/**
 * Current loop-label stack depth for ctx (0 if unknown/null).
 * @param ctx *u8 - AsmFuncCtx* key
 * @return i32 - depth 0..8
 * wave114 pure: G.7 single product authority (historical asm_ctx_loop_depth).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_ctx_loop_depth(ctx: *u8): i32 {
  let s: i32 = loop_sc_find(ctx, 0);
  if (s < 0) {
    return 0;
  }
  return g_pipe_loop_depth[s];
}

/**
 * Clear if-then block emit continuation stack (call at top-level emit_block_body entry).
 * @return void
 * wave114 pure: G.7 single product authority (historical asm_be_cont_reset).
 * PLATFORM: SHARED - sole provider after asm_ctx_loop leave.
 */
#[no_mangle]
export function asm_be_cont_reset(): void {
  g_pipe_be_cont_depth = 0;
}

/**
 * Suspend current block at stmt_i with optional if end label (stack cap 24).
 * @param block_ref i32 - block to resume
 * @param stmt_i i32 - statement index to resume
 * @param end_lbl *u8 - end label bytes; null -> -1
 * @param end_len i32 - full end label len (0 = no jmp merge); bytes clamped to 64 into 128B row
 * @return i32 - 0 ok; -1 full / null end_lbl / negative end_len
 * wave114 pure: G.7 single product authority (historical asm_be_cont_suspend).
 * PLATFORM: SHARED - avoids emit_block_body <-> if-then recursion.
 */
#[no_mangle]
export function asm_be_cont_suspend(block_ref: i32, stmt_i: i32, end_lbl: *u8, end_len: i32): i32 {
  if (g_pipe_be_cont_depth >= 24) {
    return 0 - 1;
  }
  if (end_lbl == 0 as *u8 || end_len < 0) {
    return 0 - 1;
  }
  let d: i32 = g_pipe_be_cont_depth;
  g_pipe_be_cont_depth = d + 1;
  g_pipe_be_cont_block[d] = block_ref;
  g_pipe_be_cont_stmt[d] = stmt_i;
  if (end_len == 0) {
    g_pipe_be_cont_end_len[d] = 0;
    return 0;
  }
  let n: i32 = end_len;
  if (n > 64) {
    n = 64;
  }
  let base: i32 = d * 128;
  let k: i32 = 0;
  while (k < n) {
    unsafe {
      g_pipe_be_cont_end[base + k] = end_lbl[k];
    }
    k = k + 1;
  }
  g_pipe_be_cont_end_len[d] = end_len;
  return 0;
}

/**
 * Pop innermost continuation; write resume point and end label.
 * @param out_block *i32 - optional resume block_ref
 * @param out_stmt_i *i32 - optional resume stmt index
 * @param out_end *u8 - optional end label dst
 * @param end_cap i32 - out_end capacity
 * @param out_end_len *i32 - optional full end label length
 * @return i32 - 1 if a frame was popped; 0 if empty
 * wave114 pure: G.7 single product authority (historical asm_be_cont_resume).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_be_cont_resume(out_block: *i32, out_stmt_i: *i32, out_end: *u8, end_cap: i32,
                                  out_end_len: *i32): i32 {
  if (g_pipe_be_cont_depth <= 0) {
    return 0;
  }
  g_pipe_be_cont_depth = g_pipe_be_cont_depth - 1;
  let d: i32 = g_pipe_be_cont_depth;
  if (out_block != 0 as *i32) {
    xlang_i32_store(out_block, g_pipe_be_cont_block[d]);
  }
  if (out_stmt_i != 0 as *i32) {
    xlang_i32_store(out_stmt_i, g_pipe_be_cont_stmt[d]);
  }
  let elen: i32 = g_pipe_be_cont_end_len[d];
  if (out_end_len != 0 as *i32) {
    xlang_i32_store(out_end_len, elen);
  }
  if (out_end != 0 as *u8 && end_cap > 0 && out_end_len != 0 as *i32) {
    let n: i32 = elen;
    if (n > end_cap - 1) {
      n = end_cap - 1;
    }
    let base: i32 = d * 128;
    let k: i32 = 0;
    while (k < n) {
      unsafe {
        out_end[k] = g_pipe_be_cont_end[base + k];
      }
      k = k + 1;
    }
  }
  return 1;
}

/**
 * Current if continuation stack depth (debug).
 * @return i32 - depth 0..24
 * wave114 pure: G.7 single product authority (historical asm_be_cont_depth).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_be_cont_depth(): i32 {
  return g_pipe_be_cont_depth;
}

// ---------------------------------------------------------------------------
// wave115: asm selfhost pure-owned leave (was pipeline_asm_selfhost.c).
// G.7 product authority for:
//   asm_module_num_defined_funcs / asm_module_defined_func_ordinal
//   asm_module_is_backend_selfhost / is_typeck_selfhost / is_pipeline_selfhost
//   is_main_driver_selfhost / is_driver_compile_selfhost
//   is_parser_selfhost / is_parser_emit_heavy / is_ast_selfhost / is_compiler_selfhost
// Cap residual: pipeline_module_num_funcs + func_name_equal_at + is_extern_at.
// Cold twins under seed #ifndef FROM_X. Residual host-cc skip/wpo/heavy call faces
// via extern (no longer same-TU static).
// PLATFORM: SHARED - dual-end L2 after leave.
// ---------------------------------------------------------------------------

#[no_mangle]
export function asm_module_num_defined_funcs(m: *u8): i32 {
  if (m == 0 as *u8) {
    return 0;
  }
  unsafe {
    let nfuncs: i32 = pipeline_module_num_funcs(m);
    let i: i32 = 0;
    let n: i32 = 0;
    while (i < nfuncs) {
      if (pipeline_asm_module_func_is_extern_at(m, i) == 0) {
        n = n + 1;
      }
      i = i + 1;
    }
    return n;
  }
}

/**
 * Ordinal among defined (non-extern) functions; -1 if extern / OOB / null.
 * @param m *u8 - ast_Module*
 * @param func_index i32 - raw function index
 * @return i32 - 0..ndef-1 or -1
 * wave115 pure: G.7 single product authority (historical asm_module_defined_func_ordinal).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_module_defined_func_ordinal(m: *u8, func_index: i32): i32 {
  if (m == 0 as *u8 || func_index < 0) {
    return 0 - 1;
  }
  unsafe {
    let nfuncs: i32 = pipeline_module_num_funcs(m);
    if (func_index >= nfuncs) {
      return 0 - 1;
    }
    if (pipeline_asm_module_func_is_extern_at(m, func_index) != 0) {
      return 0 - 1;
    }
    let i: i32 = 0;
    let ord: i32 = 0;
    while (i < func_index) {
      if (pipeline_asm_module_func_is_extern_at(m, i) == 0) {
        ord = ord + 1;
      }
      i = i + 1;
    }
    return ord;
  }
}

/**
 * Module is backend.x self-host unit (asm_codegen_ast or emit_expr_elf probe; num_funcs>=80).
 * @param m *u8 - ast_Module*
 * @return i32 - 1 yes, 0 no
 * wave115 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_module_is_backend_selfhost(m: *u8): i32 {
  if (m == 0 as *u8) {
    return 0;
  }
  unsafe {
    let nfuncs: i32 = pipeline_module_num_funcs(m);
    if (nfuncs < 80) {
      return 0;
    }
    let i: i32 = 0;
    while (i < nfuncs) {
      if (pipeline_module_func_name_equal_at(m, i, "asm_codegen_ast", 15) != 0) {
        return 1;
      }
      i = i + 1;
    }
    i = 0;
    while (i < nfuncs) {
      if (pipeline_module_func_name_equal_at(m, i, "emit_expr_elf", 13) != 0) {
        return 1;
      }
      i = i + 1;
    }
    return 0;
  }
}

/**
 * Module is typeck.x self-host unit (name probes + ndef heuristics; exclude ast/parser markers).
 * @param m *u8 - ast_Module*
 * @return i32 - 1 yes, 0 no
 * wave115 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_module_is_typeck_selfhost(m: *u8): i32 {
  if (m == 0 as *u8) {
    return 0;
  }
  unsafe {
    let nfuncs: i32 = pipeline_module_num_funcs(m);
    if (nfuncs < 40) {
      return 0;
    }
    let i: i32 = 0;
    while (i < nfuncs) {
      if (pipeline_module_func_name_equal_at(m, i, "ast_arena_init", 14) != 0) {
        return 0;
      }
      if (pipeline_module_func_name_equal_at(m, i, "ast_placeholder", 15) != 0) {
        return 0;
      }
      i = i + 1;
    }
    i = 0;
    while (i < nfuncs) {
      if (pipeline_module_func_name_equal_at(m, i, "pipeline_module_reset_parse_counters", 36) != 0) {
        return 0;
      }
      if (pipeline_module_func_name_equal_at(m, i, "parse_into_init", 15) != 0) {
        return 0;
      }
      if (pipeline_module_func_name_equal_at(m, i, "skip_one_struct_into_buf", 24) != 0) {
        return 0;
      }
      i = i + 1;
    }
    if (pipeline_module_func_name_equal_at(m, 0, "type_kind_ordinal", 17) != 0) {
      return 1;
    }
    i = 0;
    while (i < nfuncs) {
      if (pipeline_module_func_name_equal_at(m, i, "typeck_x_ast", 12) != 0) {
        return 1;
      }
      i = i + 1;
    }
  }
  let ndef: i32 = asm_module_num_defined_funcs(m);
  if (ndef >= 75 && ndef <= 155) {
    return 1;
  }
  if (ndef >= 160 && ndef <= 180) {
    return 1;
  }
  return 0;
}

/**
 * Module is pipeline.x self-host (resolve_path_x + marker; not backend/typeck).
 * @param m *u8 - ast_Module*
 * @return i32 - 1 yes, 0 no
 * wave115 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_module_is_pipeline_selfhost(m: *u8): i32 {
  if (m == 0 as *u8) {
    return 0;
  }
  if (asm_module_is_backend_selfhost(m) != 0 || asm_module_is_typeck_selfhost(m) != 0) {
    return 0;
  }
  unsafe {
    let nfuncs: i32 = pipeline_module_num_funcs(m);
    if (nfuncs < 12) {
      return 0;
    }
    let has_resolve: i32 = 0;
    let has_marker: i32 = 0;
    let i: i32 = 0;
    while (i < nfuncs) {
      if (pipeline_module_func_name_equal_at(m, i, "resolve_path_x", 15) != 0) {
        has_resolve = 1;
      }
      if (pipeline_module_func_name_equal_at(m, i, "pipeline_should_skip_x_typeck", 30) != 0) {
        has_marker = 1;
      }
      if (pipeline_module_func_name_equal_at(m, i, "path_append_from_buf_256", 24) != 0) {
        has_marker = 1;
      }
      if (pipeline_module_func_name_equal_at(m, i, "read_file_x", 12) != 0) {
        has_marker = 1;
      }
      i = i + 1;
    }
    if (has_resolve != 0 && has_marker != 0) {
      return 1;
    }
    return 0;
  }
}

/**
 * Module is parser.x self-host (reset counters + parse markers; num_funcs 150..1450).
 * @param m *u8 - ast_Module*
 * @return i32 - 1 yes, 0 no
 * wave115 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_module_is_parser_selfhost(m: *u8): i32 {
  if (m == 0 as *u8) {
    return 0;
  }
  if (asm_module_is_backend_selfhost(m) != 0 || asm_module_is_pipeline_selfhost(m) != 0) {
    return 0;
  }
  let has_parse_marker: i32 = 0;
  let has_reset: i32 = 0;
  let nfuncs: i32 = 0;
  unsafe {
    nfuncs = pipeline_module_num_funcs(m);
    if (nfuncs < 150 || nfuncs > 1450) {
      return 0;
    }
    let i: i32 = 0;
    while (i < nfuncs) {
      if (pipeline_module_func_name_equal_at(m, i, "pipeline_module_reset_parse_counters", 36) != 0) {
        has_reset = 1;
      }
      if (pipeline_module_func_name_equal_at(m, i, "parse_into_init", 15) != 0) {
        has_parse_marker = 1;
      }
      if (pipeline_module_func_name_equal_at(m, i, "parse_into_set_main_index", 25) != 0) {
        has_parse_marker = 1;
      }
      if (pipeline_module_func_name_equal_at(m, i, "skip_one_struct_into_buf", 24) != 0) {
        has_parse_marker = 1;
      }
      i = i + 1;
    }
  }
  if (has_reset != 0 && has_parse_marker == 0 && nfuncs >= 200) {
    has_parse_marker = 1;
  }
  if (has_reset == 0) {
    return 0;
  }
  if (asm_module_is_typeck_selfhost(m) != 0 && has_parse_marker == 0) {
    return 0;
  }
  if (has_parse_marker != 0) {
    return 1;
  }
  return 0;
}

/**
 * EMIT_HEAVY second pass: parser.x recognition (reset counters enough).
 * @param m *u8 - ast_Module*
 * @return i32 - 1 yes, 0 no
 * wave115 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_module_is_parser_emit_heavy(m: *u8): i32 {
  if (m == 0 as *u8) {
    return 0;
  }
  if (asm_module_is_backend_selfhost(m) != 0 || asm_module_is_pipeline_selfhost(m) != 0) {
    return 0;
  }
  unsafe {
    let nfuncs: i32 = pipeline_module_num_funcs(m);
    if (nfuncs < 150 || nfuncs > 1450) {
      return 0;
    }
    let i: i32 = 0;
    while (i < nfuncs) {
      if (pipeline_module_func_name_equal_at(m, i, "pipeline_module_reset_parse_counters", 36) != 0) {
        return 1;
      }
      i = i + 1;
    }
  }
  return asm_module_is_parser_selfhost(m);
}

/**
 * Module is main.x driver unit (entry + run_compiler path; ndef 12..48).
 * @param m *u8 - ast_Module*
 * @return i32 - 1 yes, 0 no
 * wave115 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_module_is_main_driver_selfhost(m: *u8): i32 {
  if (m == 0 as *u8) {
    return 0;
  }
  let ndef: i32 = asm_module_num_defined_funcs(m);
  if (ndef < 12 || ndef > 48) {
    return 0;
  }
  if (asm_module_is_backend_selfhost(m) != 0 || asm_module_is_typeck_selfhost(m) != 0 ||
      asm_module_is_pipeline_selfhost(m) != 0 || asm_module_is_parser_selfhost(m) != 0) {
    return 0;
  }
  unsafe {
    let has_entry: i32 = 0;
    let has_run_path: i32 = 0;
    let nfuncs: i32 = pipeline_module_num_funcs(m);
    let i: i32 = 0;
    while (i < nfuncs) {
      if (pipeline_module_func_name_equal_at(m, i, "entry", 5) != 0) {
        has_entry = 1;
      }
      if (pipeline_module_func_name_equal_at(m, i, "main_run_compiler_x_path_impl", 29) != 0) {
        has_run_path = 1;
      }
      if (pipeline_module_func_name_equal_at(m, i, "run_compiler_x_path_impl", 24) != 0) {
        has_run_path = 1;
      }
      i = i + 1;
    }
    if (has_entry != 0 && has_run_path != 0) {
      return 1;
    }
    return 0;
  }
}

/**
 * Module is driver/compile.x self-host (parse_argv + run_compiler_full_x; num_funcs 8..120).
 * @param m *u8 - ast_Module*
 * @return i32 - 1 yes, 0 no
 * wave115 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_module_is_driver_compile_selfhost(m: *u8): i32 {
  if (m == 0 as *u8) {
    return 0;
  }
  if (asm_module_is_backend_selfhost(m) != 0 || asm_module_is_typeck_selfhost(m) != 0 ||
      asm_module_is_pipeline_selfhost(m) != 0 || asm_module_is_parser_selfhost(m) != 0) {
    return 0;
  }
  unsafe {
    let nfuncs: i32 = pipeline_module_num_funcs(m);
    if (nfuncs < 8 || nfuncs > 120) {
      return 0;
    }
    let has_parse_argv: i32 = 0;
    let has_entry: i32 = 0;
    let i: i32 = 0;
    while (i < nfuncs) {
      if (pipeline_module_func_name_equal_at(m, i, "driver_compile_parse_argv", 25) != 0) {
        has_parse_argv = 1;
      }
      if (pipeline_module_func_name_equal_at(m, i, "run_compiler_full_x", 19) != 0) {
        has_entry = 1;
      }
      if (pipeline_module_func_name_equal_at(m, i, "compile_dispatch_asm_backend", 28) != 0) {
        has_parse_argv = 1;
      }
      i = i + 1;
    }
    if (has_parse_argv != 0 && has_entry != 0) {
      return 1;
    }
    return 0;
  }
}

/**
 * Module is ast.x self-host (ast_arena_init + ast_placeholder; num_funcs 15..250).
 * @param m *u8 - ast_Module*
 * @return i32 - 1 yes, 0 no
 * wave115 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_module_is_ast_selfhost(m: *u8): i32 {
  if (m == 0 as *u8) {
    return 0;
  }
  let has_arena_init: i32 = 0;
  let has_placeholder: i32 = 0;
  unsafe {
    let nfuncs: i32 = pipeline_module_num_funcs(m);
    if (nfuncs < 15 || nfuncs > 250) {
      return 0;
    }
    let i: i32 = 0;
    while (i < nfuncs) {
      if (pipeline_module_func_name_equal_at(m, i, "ast_arena_init", 14) != 0) {
        has_arena_init = 1;
      }
      if (pipeline_module_func_name_equal_at(m, i, "ast_placeholder", 15) != 0) {
        has_placeholder = 1;
      }
      i = i + 1;
    }
  }
  if (has_arena_init == 0 || has_placeholder == 0) {
    return 0;
  }
  if (asm_module_is_backend_selfhost(m) != 0 || asm_module_is_pipeline_selfhost(m) != 0 ||
      asm_module_is_parser_selfhost(m) != 0) {
    return 0;
  }
  return 1;
}

/**
 * Module is any compiler .x self-host unit (OR of 8 predicates); user programs excluded.
 * @param m *u8 - ast_Module*
 * @return i32 - 1 yes, 0 no
 * wave115 pure: G.7 single product authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function asm_module_is_compiler_selfhost(m: *u8): i32 {
  if (asm_module_is_ast_selfhost(m) != 0) {
    return 1;
  }
  if (asm_module_is_backend_selfhost(m) != 0) {
    return 1;
  }
  if (asm_module_is_typeck_selfhost(m) != 0) {
    return 1;
  }
  if (asm_module_is_pipeline_selfhost(m) != 0) {
    return 1;
  }
  if (asm_module_is_parser_selfhost(m) != 0) {
    return 1;
  }
  if (asm_module_is_parser_emit_heavy(m) != 0) {
    return 1;
  }
  if (asm_module_is_driver_compile_selfhost(m) != 0) {
    return 1;
  }
  if (asm_module_is_main_driver_selfhost(m) != 0) {
    return 1;
  }
  return 0;
}
