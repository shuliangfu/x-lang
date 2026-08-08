/**
 * ast_pool.c — AST 块/模块/OneFunc 附属数据的 C 侧可增长池。
 *
 * Block 不再内嵌 const/let/if/expr_stmt/stmt_order 固定数组，仅保留 base+count；
 * Module.funcs 亦迁至可增长池。由 pipeline_glue.c #include 进同一 TU。
 */
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdio.h>
#include <stddef.h>
#if defined(__APPLE__) || defined(__linux__)
#include <sys/mman.h>
#endif
#include <xlang_weak.h>
#include "diag.h"

/* wave246 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PLATFORM: SHARED — product ast_pool residual raw getenv call sites migrate to this face
 * (DEBUG_PIPE / ASM_DEBUG / TRACE / WPO / emit-heavy / bootstrap-emit gates; same G.7
 * pattern as wave240 pipeline_glue). Textually #include'd into pipeline_glue /
 * pipeline_glue_standalone; redeclaration is compatible with glue's wave240 extern.
 */
extern char *link_abi_getenv(const char *name);

/* Pool grow policy macros must precede pipeline_grow_vec.c (uses AST_POOL_GROW /
 * AST_POOL_INIT_CAP). ifndef-guarded copies also live in ast_pool_typedefs.c for
 * readers of that domain file alone. PLATFORM: SHARED. */
#ifndef AST_POOL_GROW
#define AST_POOL_GROW 4096
#endif
#ifndef AST_POOL_INIT_CAP
#define AST_POOL_INIT_CAP 256
#endif

/* BC 8.3.2 wave1278: GrowVec leaf → pipeline_grow_vec.c (wave1275);
 * early typedef domain → ast_pool_typedefs.c; core ptr_at accessors →
 * ast_pool_ptr_at.c.
 * Order is load-bearing: macros → GrowVec type → entry/sidecar typedefs →
 * pure Cap faces (wave275) → ptr_at. PLATFORM: SHARED — same-TU #include into
 * pipeline_glue / pipeline_x.
 */
/* 2026-08-08: pipeline_grow_vec.c pure-owned leave (wave271).
 * Live faces: runtime_pipeline_abi pure grow_vec_init/free/ensure/at/push/copy_append.
 * Typedef + extern prototypes: ast_pool_typedefs.c. dual-export ban (pipeline_x U).
 * PLATFORM: SHARED freestanding GrowVec Cap leave. */
/* 2026-08-08: ast_pool_sidecar_pool.c pure-owned leave (wave275).
 * Live faces: runtime_pipeline_abi pure arena/module/onefunc_sidecar_get|free
 * (g_pipe_*_sc_blob process tables). Cap face decls in ast_pool_typedefs.c.
 * dual-export ban (pipeline_x U). PLATFORM: SHARED freestanding sidecar Cap leave. */
#include "ast_pool_typedefs.c"
#include "ast_pool_ptr_at.c"

/** Forward: pure/cold pipeline_arena_block_alloc → seed ALWAYS lifecycle (wave279). */
void ast_pool_block_on_alloc(struct ast_ASTArena *a, int32_t block_ref);
void ast_pool_module_reset(struct ast_Module *m);
void ast_pool_arena_reset(struct ast_ASTArena *a);
void ast_pool_arena_release(struct ast_ASTArena *a);
void ast_pool_module_release(struct ast_Module *m);
void ast_pool_drop_bodies_for_check(struct ast_ASTArena *a, struct ast_Module *m);
void ast_pool_onefunc_reset(uint8_t *out);
void ast_pool_onefunc_release(uint8_t *out);

/* 2026-08-08: ast_pool_arena.c pure-owned leave (wave276).
 * Live faces: runtime_pipeline_abi pure pipeline_arena_{type,expr,block,func}_{ptr,alloc}
 * + caps/num_types/write_var|binop/parser_library_init/fill_u8/init aliases (no_mangle).
 * Value-ABI residual (by-value get/set_copy + float IEEE) = seed always-C in
 * runtime_pipeline_abi.from_x.c (not gated by FROM_X; dual-platform sret).
 * Seed cold twins under #ifndef FROM_X for pure-owned faces.
 * Host residual leaf deleted; dual-export ban (pipeline_x U).
 * PLATFORM: SHARED freestanding arena Cap leave. */

/* 2026-08-08: ast_pool_type.c pure-owned leave (wave270).
 * Live faces: runtime_pipeline_abi pure pipeline_type_* (#[no_mangle]).
 * wave276: pipeline_arena_type_ptr/alloc pure same-TU (was Cap residual).
 * PLATFORM: SHARED — dual-export ban; pipeline_x U for type pool faces. */


/* wave279: ast_pool_lifecycle.c host leaf deleted — Cap residual in
 * runtime_pipeline_abi seed ALWAYS (block_on_alloc / module|arena reset|release /
 * drop_bodies / onefunc reset|release). Static module_func helpers live in
 * ast_pool_module_func.c. dual-export ban (pipeline_x U). PLATFORM: SHARED. */

/** BC 8.3.2: Module Func cold accessors domain (same-TU thin). */
#include "ast_pool_module_func.c"


/* 2026-08-05: pipeline_lint_meta.c pure-owned leave (wave121).
 * Live face: runtime_pipeline_abi.x (visibility + L7 unused-private +
 * module_num_funcs/main_func_index/set/reset_parse_counters/strict_parse_into_init
 * + lint_set_source_buf). Seed cold twin under #ifndef FROM_X.
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */
extern int32_t pipeline_visibility_mode(void);
extern int32_t pipeline_visibility_allow_func(struct ast_Module *m, int32_t fi, int32_t cross_module);
extern void pipeline_lint_set_source_buf(const uint8_t *data, int32_t len);
extern int32_t pipeline_typeck_unused_private_funcs(struct ast_Module *m, struct ast_ASTArena *a);
extern int32_t pipeline_module_num_funcs(struct ast_Module *m);
extern int32_t pipeline_module_main_func_index(struct ast_Module *m);
extern void pipeline_module_set_main_func_index(struct ast_Module *m, int32_t idx);
extern void pipeline_module_reset_parse_counters_c(struct ast_Module *module);
extern void pipeline_strict_parse_into_init(struct ast_ASTArena *arena, struct ast_Module *module);

/** BC 8.3.2 wave988–990 + wave992: block domain thin (append/region/defer +
 * loop/labeled/getters + parent/resolve + stmt_order rebuild/fixup) — same-TU. */
/* wave277: ast_pool_block.c host leaf deleted — Cap residual in runtime_pipeline_abi seed ALWAYS. */

/* BC 8.3.2 wave991: onefunc fill residual lives in ast_pool_onefunc.c (include later).
 * BC 8.3.2 wave993+994: name_is_const + hoist + asm hoist_target / sum stack live in
 * ast_pool_top_level.c (include below; after block so static prepend_lets is visible).
 * BC 8.3.2 wave1280: emit-heavy env/thresholds + path helpers / whitelist →
 * pipeline_asm_emit_heavy_env.c (before selfhost).
 * wave1281 shell scan: no function bodies remain here — host shell is #include
 * orchestration + pool macros + link_abi_getenv extern + one forward decl only.
 * PLATFORM: SHARED same-TU into pipeline_glue / pipeline_x (still host-cc). */

/** ---------- Module import / struct_layout / top_level / enum 动态池 ---------- */

/** BC 8.3.2: module ImportEntry cold-twin accessors (same-TU thin). */
/* 2026-08-08 wave263: ast_pool_module_import.c pure-owned leave.
 * Live faces: runtime_pipeline_abi.x (pipeline_module_import_* full set +
 * storage_release; wave110 pure multi-module map). Cap residual: ModuleSidecar
 * imports / import_select_* GrowVec still init/free in sidecar_pool (unused for
 * product imports after leave). PLATFORM: SHARED.
 * Same-TU pure face decls (residual XLANG_WEAK defs retired; later domain
 * slices + pipeline_ast_forwarders call these as extern). */
void pipeline_module_import_storage_release(struct ast_Module *m);
int32_t pipeline_module_import_alloc(struct ast_Module *m);
void pipeline_module_import_set_path(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
int32_t pipeline_module_import_path_len(struct ast_Module *m, int32_t idx);
void pipeline_module_import_path_copy(struct ast_Module *m, int32_t idx, uint8_t *dst, int32_t dst_cap);
uint8_t pipeline_module_import_path_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
void pipeline_module_import_set_kind(struct ast_Module *m, int32_t idx, int32_t kind);
int32_t pipeline_module_import_kind_at(struct ast_Module *m, int32_t idx);
void pipeline_module_import_set_binding_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
int32_t pipeline_module_import_binding_name_len(struct ast_Module *m, int32_t idx);
uint8_t pipeline_module_import_binding_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
void pipeline_module_import_set_select_count(struct ast_Module *m, int32_t idx, int32_t n);
int32_t pipeline_module_import_append_select_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
int32_t pipeline_module_import_select_count_at(struct ast_Module *m, int32_t idx);
void pipeline_module_import_set_select_name(struct ast_Module *m, int32_t idx, int32_t sel, uint8_t *bytes,
                                           int32_t len);
int32_t pipeline_module_import_select_name_len(struct ast_Module *m, int32_t idx, int32_t sel);
uint8_t pipeline_module_import_select_name_byte_at(struct ast_Module *m, int32_t idx, int32_t sel, int32_t off);

/* 2026-08-08 wave266: ast_pool_struct_layout.c pure-owned leave.
 * Live faces: runtime_pipeline_abi.x (pipeline_module_struct_layout_* full set +
 * type_param / next_field_offset / type_ref_byte_size + storage_reset/release;
 * 168B pure layout entry LE + 144B field + 132B type-param maps). Cap residual:
 * ModuleSidecar.struct_layouts / struct_layout_fields / type_params|meta GrowVec
 * still init/free in sidecar_pool (unused for product layouts after leave).
 * Sizing uses pure glue_type_* (wave154) + pure emit module cell (wave222).
 * PLATFORM: SHARED.
 * Same-TU pure face decls (residual defs retired; later domain slices +
 * pipeline_ast_forwarders call these as extern). */
void pipeline_module_struct_layout_storage_reset(struct ast_Module *m);
void pipeline_module_struct_layout_storage_release(struct ast_Module *m);
int32_t pipeline_module_struct_layout_alloc(struct ast_Module *m);
void pipeline_module_struct_layout_reset_slot(struct ast_Module *m, int32_t idx);
void pipeline_module_struct_layout_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
void pipeline_module_struct_layout_set_field(struct ast_Module *m, int32_t li, int32_t j, uint8_t *fname_bytes,
                                            int32_t fname_len, int32_t ftype_ref, int32_t foff);
int32_t pipeline_module_struct_layout_name_len(struct ast_Module *m, int32_t idx);
void pipeline_module_struct_layout_name_into(struct ast_Module *m, int32_t idx, uint8_t *out64);
uint8_t pipeline_module_struct_layout_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
int32_t pipeline_module_struct_layout_num_fields(struct ast_Module *m, int32_t idx);
void pipeline_module_struct_layout_set_num_fields(struct ast_Module *m, int32_t idx, int32_t nf);
int32_t pipeline_module_struct_layout_field_type_ref(struct ast_Module *m, int32_t li, int32_t j);
int32_t pipeline_module_struct_layout_field_name_len(struct ast_Module *m, int32_t li, int32_t j);
void pipeline_module_struct_layout_field_name_into(struct ast_Module *m, int32_t li, int32_t j, uint8_t *out64);
int32_t pipeline_module_struct_layout_append_type_param(struct ast_Module *m, int32_t li, uint8_t *name,
                                                       int32_t name_len);
int32_t pipeline_module_struct_layout_num_type_params_at(struct ast_Module *m, int32_t li);
int32_t pipeline_module_struct_layout_type_param_name_len(struct ast_Module *m, int32_t li, int32_t j);
void pipeline_module_struct_layout_type_param_name_into(struct ast_Module *m, int32_t li, int32_t j,
                                                       uint8_t *out64);
void pipeline_module_struct_layout_set_field_offset(struct ast_Module *m, int32_t li, int32_t j, int32_t foff);
int32_t pipeline_module_struct_layout_field_offset_at(struct ast_Module *m, int32_t li, int32_t j);
int32_t pipeline_module_struct_layout_field_align_at(struct ast_Module *m, int32_t li, int32_t j);
void pipeline_module_struct_layout_set_field_align(struct ast_Module *m, int32_t li, int32_t j, int32_t al);
void pipeline_module_struct_layout_set_allow_padding(struct ast_Module *m, int32_t idx, int32_t v);
int32_t pipeline_module_struct_layout_allow_padding_at(struct ast_Module *m, int32_t idx);
void pipeline_module_struct_layout_set_soa(struct ast_Module *m, int32_t idx, int32_t v);
int32_t pipeline_module_struct_layout_soa_at(struct ast_Module *m, int32_t idx);
void pipeline_module_struct_layout_set_packed(struct ast_Module *m, int32_t idx, int32_t v);
int32_t pipeline_module_struct_layout_packed_at(struct ast_Module *m, int32_t idx);
void pipeline_module_struct_layout_set_repr_compatible(struct ast_Module *m, int32_t idx, int32_t v);
int32_t pipeline_module_struct_layout_repr_compatible_at(struct ast_Module *m, int32_t idx);
void pipeline_module_struct_layout_set_is_export(struct ast_Module *m, int32_t idx, int32_t v);
int32_t pipeline_module_struct_layout_is_export_at(struct ast_Module *m, int32_t idx);
int32_t pipeline_module_num_struct_layouts_at(struct ast_Module *m);
int32_t pipeline_asm_type_ref_byte_size_c(struct ast_ASTArena *arena, int32_t ty_ref);
int32_t pipeline_struct_layout_next_field_offset_ex(struct ast_Module *m, struct ast_ASTArena *a, int32_t layout_idx,
                                                    int32_t new_field_type_ref, int32_t field_align_req);
int32_t pipeline_struct_layout_next_field_offset(struct ast_Module *m, struct ast_ASTArena *a, int32_t layout_idx,
                                               int32_t new_field_type_ref);

/* 2026-08-08 wave265: ast_pool_top_level.c pure-owned leave.
 * Live faces: runtime_pipeline_abi.x (pipeline_module_top_level_let_* full set +
 * name_is_const / hoist / hoist_target / sum_stack + storage_reset/release;
 * 148B TopLevelLetEntry LE map). Cap residual: ModuleSidecar.top_level_lets
 * GrowVec still init/free in sidecar_pool (unused for product lets after leave).
 * Hoist Cap faces: pipeline_block_append_let + pipeline_block_stmt_order_prepend_lets
 * (prepend non-static). PLATFORM: SHARED.
 * Same-TU pure face decls (residual defs retired; later domain slices +
 * pipeline_ast_forwarders call these as extern). */
void pipeline_module_top_level_let_storage_reset(struct ast_Module *m);
void pipeline_module_top_level_let_storage_release(struct ast_Module *m);
int32_t pipeline_module_top_level_let_alloc(struct ast_Module *m);
void pipeline_module_top_level_let_set(struct ast_Module *m, int32_t idx, uint8_t *name, int32_t name_len,
                                       int32_t type_ref, int32_t init_ref, int32_t is_const);
void pipeline_module_top_level_let_set_type_ref(struct ast_Module *m, int32_t idx, int32_t type_ref);
int32_t pipeline_module_top_level_let_name_len(struct ast_Module *m, int32_t idx);
uint8_t pipeline_module_top_level_let_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
int32_t pipeline_module_top_level_let_type_ref(struct ast_Module *m, int32_t idx);
int32_t pipeline_module_top_level_let_init_ref(struct ast_Module *m, int32_t idx);
int32_t pipeline_module_top_level_let_is_const(struct ast_Module *m, int32_t idx);
void pipeline_module_top_level_let_set_is_export(struct ast_Module *m, int32_t idx, int32_t is_export);
int32_t pipeline_module_top_level_let_is_export_at(struct ast_Module *m, int32_t idx);
int32_t pipeline_module_top_level_name_is_const(struct ast_Module *m, uint8_t *vname, int32_t vlen);
void pipeline_module_hoist_top_level_lets_into_main(struct ast_Module *m, struct ast_ASTArena *a);
int32_t pipeline_asm_hoist_target_func_index(struct ast_Module *m);
int32_t pipeline_asm_sum_module_top_level_lets_stack(struct ast_ASTArena *a, struct ast_Module *m, int32_t off);

/* 2026-08-08 wave262: ast_pool_type_alias.c pure-owned leave.
 * Live faces: runtime_pipeline_abi.x (pipeline_module_type_alias_* +
 * num_type_aliases_at + storage_reset/release). Cap residual: ModuleSidecar
 * type_aliases GrowVec still init/free in sidecar_pool (unused for product
 * aliases after leave). PLATFORM: SHARED. */

/* 2026-08-05: pipeline_backend_asm_wrapper.c pure-owned leave (wave113).
 * Live face: runtime_pipeline_abi.x (pipeline_backend_asm_codegen_ast_c /
 * pipeline_backend_asm_codegen_ast_to_elf_c). Cap residual: hoist / seed mega /
 * emit_set_* / mega_body / wpo thunks / typeck merge. PLATFORM: SHARED. */

/* 2026-08-08 wave264: ast_pool_module_enum.c pure-owned leave.
 * Live faces: runtime_pipeline_abi.x (pipeline_module_enum_* full set +
 * try_mark_enum field-access + storage_reset/release; 33932B ModuleEnumEntry LE map).
 * Cap residual: ModuleSidecar.module_enums GrowVec still init/free in sidecar_pool
 * (unused for product enums after leave). PLATFORM: SHARED.
 * Same-TU pure face decls (residual defs retired; later domain slices +
 * pipeline_ast_forwarders call these as extern). */
void pipeline_module_enum_storage_reset(struct ast_Module *m);
void pipeline_module_enum_storage_release(struct ast_Module *m);
int32_t pipeline_module_enum_alloc(struct ast_Module *m);
void pipeline_module_enum_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
void pipeline_module_enum_set_is_export(struct ast_Module *m, int32_t idx, int32_t v);
int32_t pipeline_module_enum_is_export_at(struct ast_Module *m, int32_t idx);
int32_t pipeline_module_enum_append_variant(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
int32_t pipeline_module_enum_variant_tag_for_names(struct ast_Module *m, uint8_t *enum_name, int32_t enum_len,
                                                   uint8_t *variant_name, int32_t variant_len);
int32_t pipeline_module_enum_name_len(struct ast_Module *m, int32_t idx);
uint8_t pipeline_module_enum_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
int32_t pipeline_module_enum_num_variants(struct ast_Module *m, int32_t idx);
int32_t pipeline_module_enum_variant_name_len(struct ast_Module *m, int32_t idx, int32_t variant_idx);
uint8_t pipeline_module_enum_variant_name_byte_at(struct ast_Module *m, int32_t idx, int32_t variant_idx,
                                                  int32_t off);
void pipeline_expr_try_mark_enum_field_access(struct ast_Module *m, struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_codegen_try_mark_enum_field_access(struct ast_Module *m, struct ast_ASTArena *a,
                                                  int32_t expr_ref, struct ast_PipelineDepCtx *dep_ctx);

/** BC 8.3.2: OneFunc sidecar + fill_from_onefunc domain (wave984+991 same-TU thin). */
#include "ast_pool_onefunc.c"
/** BC 8.3.2: expr (+ type-pos) var-len sidecar domain (same-TU thin). */
/* wave278: ast_pool_expr_sidecar.c host leaf deleted — Cap residual in runtime_pipeline_abi seed ALWAYS. */

/** BC 8.3.2: PipelineDepCtx cold accessors domain (same-TU thin). */
/* wave272: ast_pool_dep_ctx.c pure-owned leave — authority runtime_pipeline_abi pure.
 * Live faces: #[no_mangle] pipeline_dep_ctx_* / pipeline_ctx_* / sidecar_release
 * in runtime_pipeline_abi.x (seed cold twin under #ifndef FROM_X).
 * Same-TU residual (pipeline_glue → ast_pool → pipeline_ast_forwarders) keeps
 * only extern prototypes so forwarders compile; bodies are U from this TU and
 * T from runtime_pipeline_abi.o (dual-export ban).
 * PLATFORM: SHARED freestanding DepCtx Cap leave. */
void pipeline_dep_ctx_sidecar_release(struct ast_PipelineDepCtx *ctx);
void pipeline_dep_ctx_reset(struct ast_PipelineDepCtx *ctx);
void pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_Module *m);
void pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_ASTArena *a);
struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
struct ast_ASTArena *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
void pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *bytes, int32_t len);
int32_t pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx *ctx, int32_t idx);
uint8_t pipeline_dep_ctx_import_path_byte_at(struct ast_PipelineDepCtx *ctx, int32_t idx, int32_t off);
void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst);
int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
void pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx *ctx, int32_t n);
int32_t pipeline_dep_ctx_codegen_prefix_len(struct ast_PipelineDepCtx *ctx);
uint8_t pipeline_dep_ctx_codegen_prefix_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off);
void pipeline_dep_ctx_codegen_prefix_copy(struct ast_PipelineDepCtx *ctx, uint8_t *dst, int32_t cap);
void pipeline_dep_ctx_set_codegen_prefix_mirror(struct ast_PipelineDepCtx *ctx, uint8_t *bytes, int32_t len);
uint8_t *pipeline_dep_ctx_path_buf_ptr(struct ast_PipelineDepCtx *ctx);
uint8_t pipeline_dep_ctx_path_buf_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off);
void pipeline_dep_ctx_set_path_buf_byte(struct ast_PipelineDepCtx *ctx, int32_t off, uint8_t b);
int32_t pipeline_dep_ctx_entry_dir_len(struct ast_PipelineDepCtx *ctx);
void pipeline_dep_ctx_entry_dir_copy(struct ast_PipelineDepCtx *ctx, uint8_t *dst, int32_t cap);
int32_t pipeline_dep_ctx_ensure_source_buffers(struct ast_PipelineDepCtx *ctx);
void pipeline_dep_ctx_free_source_buffers(struct ast_PipelineDepCtx *ctx);
void pipeline_dep_ctx_heap_destroy(struct ast_PipelineDepCtx *ctx);
uint8_t *pipeline_dep_ctx_loaded_buf_ptr(struct ast_PipelineDepCtx *ctx);
uint8_t *pipeline_dep_ctx_preprocess_buf_ptr(struct ast_PipelineDepCtx *ctx);
void pipeline_dep_ctx_set_loaded_len(struct ast_PipelineDepCtx *ctx, ptrdiff_t n);
int32_t pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_dep_ctx_asm_entry_module_only(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_dep_ctx_check_only_mode(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_dep_ctx_use_asm_backend(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_dep_ctx_use_macho_o(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_dep_ctx_use_coff_o(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_dep_ctx_target_arch(struct ast_PipelineDepCtx *ctx);
uint8_t pipeline_dep_ctx_entry_dir_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off);
int32_t pipeline_dep_ctx_current_codegen_dep_index(struct ast_PipelineDepCtx *ctx);
struct ast_Module *pipeline_dep_ctx_current_codegen_module(struct ast_PipelineDepCtx *ctx);
struct ast_ASTArena *pipeline_dep_ctx_current_codegen_arena(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_dep_ctx_current_func_index(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_dep_ctx_current_block_ref_at(struct ast_PipelineDepCtx *ctx);
void pipeline_dep_ctx_set_current_codegen_module(struct ast_PipelineDepCtx *ctx, struct ast_Module *m);
void pipeline_dep_ctx_set_current_codegen_arena(struct ast_PipelineDepCtx *ctx, struct ast_ASTArena *a);
void pipeline_dep_ctx_set_current_codegen_dep_index(struct ast_PipelineDepCtx *ctx, int32_t ix);
void pipeline_dep_ctx_set_current_func_index(struct ast_PipelineDepCtx *ctx, int32_t ix);
int32_t pipeline_ctx_append_lib_root(struct ast_PipelineDepCtx *ctx, uint8_t *path, int32_t len);
int32_t pipeline_ctx_lib_root_count(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_ctx_lib_root_len(struct ast_PipelineDepCtx *ctx, int32_t i);
void pipeline_ctx_lib_root_copy(struct ast_PipelineDepCtx *ctx, int32_t i, uint8_t *dst, int32_t cap);
uint8_t pipeline_ctx_lib_root_byte_at(struct ast_PipelineDepCtx *ctx, int32_t i, int32_t off);
void pipeline_dep_ctx_empty_param_reset(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_dep_ctx_empty_param_append(struct ast_PipelineDepCtx *ctx, int32_t pi);
int32_t pipeline_dep_ctx_empty_param_at(struct ast_PipelineDepCtx *ctx, int32_t i);
void pipeline_dep_ctx_empty_param_backup(struct ast_PipelineDepCtx *ctx);
void pipeline_dep_ctx_empty_param_restore(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_dep_ctx_typeck_loop_depth_at(struct ast_PipelineDepCtx *ctx);

/* 2026-08-05: pipeline_resolve_path.c pure-owned leave retired.
 * Live face: runtime_pipeline_abi.x (path_append_*_c / resolve probe / flat_import /
 * off-sidecar / codegen_out_buf_len|set_len / resolve_path_x_impl_c|_c).
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 2026-08-05: pipeline_import_bind.c pure-owned leave retired.
 * Live face: runtime_pipeline_abi.x (read_file_x / preprocess_loaded /
 * bind_import / try_bind / sync_one_dep / preprocess_len_get /
 * read_file_x_impl_c / read_file_x_c / read_fd_into_loaded_buf).
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 2026-08-05: pipeline_parse_typeck_dispatch.c pure-owned leave retired (wave112).
 * Live face: runtime_pipeline_abi.x (parse scalars BSS/getters + fail_diag +
 * buf/slice scalars + apply_main + typeck_parsed/entry + should_skip_c +
 * load_import_resolve_read + load_one_import_slot). Cap residual:
 * pipeline_parse_into_with_init_buf_impl_rc + result_c in pipeline_parse_orch.c.
 * Already pure same-TU: realign / load_and_sync / parse_set_main_from_buf_c.
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 2026-08-05: pipeline_run_x_pipeline.c pure-owned leave retired.
 * Live face: runtime_pipeline_abi.x (last_rc get/store + typeck_fail/null_return
 * + load_deps_after_parse_c + typecheck_after_load_c + parse_entry_do_parse_c
 * + typecheck_entry_emit_c + pipeline_run_x_pipeline const-buf face).
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 2026-08-05: pipeline_codegen_dep.c pure-owned leave retired (wave111).
 * Live face: runtime_pipeline_abi.x (one_dep_emit / entry_emit / parse_entry_if_needed_c /
 * fill/prepare/finish path glue / one_dep_c / deps_c / entry_c + entry_arena_for_mono).
 * Omits DEBUG_PIPE dump; product skip/rebind/emit control-flow preserved.
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 8.3.2 host-cc leave: pipeline_loop_glue.c retired — bounded-loop predicates
 * + one_dep prepare glue live in codegen_x.o (codegen_gen seed append).
 * Callers already extern the `*_c` faces (pipeline.x / pipeline_gen).
 */

/* 2026-08-05: pipeline_emit_sidecar.c pure-owned leave retired.
 * Live face: runtime_pipeline_abi.x (driver_emit_lib_root_* +
 * driver_emit_append_lib_root + asm_qual_sym_layer_* fixed-cap BSS).
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 8.3.2 host-cc leave: pipeline_preprocess_if.c retired — pure-owned WEAK cold
 * delete-only leave (highest-efficiency BC leave class). Live #if nest stack
 * is G.7 single authority in runtime_pipeline_abi.x / runtime_pipeline_abi.o
 * (fixed i32[32] BSS; no GrowVec). Callers already extern preprocess_if_stack_*.
 * Strict re-link companion: preprocess_if_stack_only.o now partial-exports from
 * runtime_pipeline_abi.o (was pipeline_glue_standalone). Do not re-include.
 */

/* 8.3.1 host-cc leave: pipeline_typeck_slots.c retired — BSS accessors live in
 * typeck_x.o (typeck_gen seed). Do not re-include into pipeline_x. */

/* wave273: pipeline_elf_ctx.c + pipeline_elf_write_o.c pure-owned leave —
 * authority runtime_pipeline_abi pure (#[no_mangle] pipeline_elf_* /
 * pipeline_macho_* / platform_macho_write_macho_o_to_buf).
 * Seed cold twins under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * Same-TU residual keeps only extern prototypes so forwarders compile;
 * bodies T from runtime_pipeline_abi.o (dual-export ban).
 * PLATFORM: SHARED freestanding ELF leave. */
int32_t pipeline_elf_pgo_hot_enabled(void);
void pipeline_elf_ctx_set_emit_hot(uint8_t *ctx_bytes, int32_t hot);
int32_t pipeline_elf_ctx_total_code_len(uint8_t *ctx_bytes);
int32_t pipeline_elf_ctx_emit_code_len(uint8_t *ctx_bytes);
int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n);
void pipeline_elf_ctx_reloc_sidecar_reset(uint8_t *ctx_bytes);
int32_t pipeline_elf_ctx_reloc_offset_at(uint8_t *ctx_bytes, int32_t idx);
int32_t pipeline_elf_ctx_reloc_shndx_at(uint8_t *ctx_bytes, int32_t idx);
int32_t pipeline_elf_ctx_sym_shndx_at(uint8_t *ctx_bytes, int32_t idx);
uint8_t *pipeline_elf_ctx_code_data_ptr(uint8_t *ctx_bytes);
void pipeline_elf_ctx_reloc_offset_set(uint8_t *ctx_bytes, int32_t idx, int32_t offset);
void pipeline_elf_label_mod_scope_reset(void);
int32_t pipeline_elf_label_mod_scope_next_module(void);
void pipeline_elf_label_mod_scope_begin_module(void);
int32_t pipeline_elf_label_mod_scope_active(void);
int32_t pipeline_elf_ctx_add_label(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t offset);
int32_t pipeline_elf_ctx_ensure_label(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len);
int32_t pipeline_elf_ctx_pad_code_to_4(uint8_t *ctx_bytes);
int32_t pipeline_elf_ctx_add_sym(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t offset);
int32_t pipeline_elf_ctx_add_common_sym(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t size, int32_t align);
int32_t pipeline_elf_ctx_macho_leading_underscore(uint8_t *ctx_bytes);
int32_t pipeline_elf_ctx_append_patch(uint8_t *ctx_bytes, int32_t rel32_offset, uint8_t *name, int32_t name_len, int32_t imm_bits);
int32_t pipeline_elf_ctx_patch_imm_bits_at(uint8_t *ctx_bytes, int32_t patch_idx);
int32_t pipeline_elf_ctx_resolve_patches(uint8_t *ctx_bytes);
int32_t pipeline_elf_ctx_append_reloc(uint8_t *ctx_bytes, int32_t offset, uint8_t *name, int32_t name_len);
int32_t pipeline_elf_ctx_append_reloc_typed(uint8_t *ctx_bytes, int32_t offset, uint8_t *name, int32_t name_len, int32_t r_type, int32_t r_pcrel);
uint8_t *pipeline_elf_ctx_reloc_sym_name_ptr(uint8_t *ctx_bytes, int32_t idx);
void pipeline_elf_ctx_reloc_sym_name_copy64(uint8_t *ctx_bytes, int32_t idx, uint8_t *dst);
int32_t pipeline_elf_ctx_reloc_name_len(uint8_t *ctx_bytes, int32_t idx);
void pipeline_elf_log_unresolved_patch(struct platform_elf_ElfCodegenCtx *ctx, int32_t patch_idx);
int32_t pipeline_elf_write_o_standard_to_buf_c(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out);
int32_t pipeline_elf_write_o_pgo_to_buf(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out);
int32_t pipeline_macho_write_o_to_buf_c(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out);
int32_t platform_macho_write_macho_o_to_buf(void *elf_ctx, void *out_buf);

/* 8.3.2 host-cc leave: pipeline_scratch_bufs.c retired — path/prefix
 * scratch BSS accessors live in codegen_x.o (codegen_gen seed append).
 * ast_/codegen_ mangled thin faces stay in pipeline_*_forwarders (host-cc).
 */

/* 2026-08-05: pipeline_codegen_type_to_c.c pure-owned leave retired (wave109).
 * Live face: runtime_pipeline_abi.x (type_kind_copy / type_kind_append /
 * vector_type_copy / type_to_c_repr).
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 2026-08-05: pipeline_codegen_struct_emit.c pure-owned leave retired (wave110).
 * Live face: runtime_pipeline_abi.x (c_file_prologue_done_* / struct_tag_try_claim /
 * emit_struct_field_type / emit_struct_field_decl). Depends on wave109 type_to_c
 * public faces + wave105 codegen_out_buf_len|set_len.
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 2026-08-05: pipeline_codegen_skip_force.c pure-owned leave retired (wave108).
 * Live face: runtime_pipeline_abi.x (call_num_args_override / path_is_std_io_* /
 * dep_skip_* / should_skip_emit_* / entry_is_lsp_* / force_param_*).
 * Reuses private pure cg_residual_name_prefix_eq (wave107) — single prefix helper.
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 2026-08-05: pipeline_codegen_residual.c pure-owned leave retired.
 * Live face: runtime_pipeline_abi.x (use_buf_wrapper / skip_emit_extern_io_batch_buf
 * / should_skip_emit_func_by_name / emit_seed_mega_enabled / is_submit_batch_buf_call
 * / should_skip_emit_func_core_read_ptr / asm_io_core_extern_callee_sym
 * / io_driver_buf_call_sym / std_io_fixed_fd_emit_impl).
 * Private pure prefix_eq is shared with skip_force pure leave (wave108).
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 2026-08-08: pipeline_asm_locals.c pure-owned leave (wave267).
 * Live face: runtime_pipeline_abi.x (asm_ctx_local_* / block_slot_* /
 * pipeline_asm_local_offset_c). Cap residual: find_offset_scoped in
 * bootstrap_glue. PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 2026-08-08: pipeline_asm_slot_bytes.c pure-owned leave (wave268).
 * Live face: runtime_pipeline_abi.x (asm_local_slot_bytes +
 * asm_ctx_ensure_block_locals). Cap residual: slot_reg_offset / simd spelling
 * / SOA+layout typeck glues.
 * Seed cold twin under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 2026-08-08: pipeline_asm_block_tree.c pure-owned leave (wave269).
 * Live face: runtime_pipeline_abi.x (asm_sum_block_* + asm_count_block_stack_slots
 * + asm_ctx_fill_locals_block_tree). Cap residual: GrowVec host DFS retired;
 * pure fixed i32[256] BSS walk stack. Seed cold twin under #ifndef FROM_X.
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 2026-08-05: pipeline_asm_ctx_loop.c pure-owned leave (wave114).
 * Live face: runtime_pipeline_abi.x (asm_ctx_loop_* + asm_be_cont_*).
 * Fixed-cap BSS sidecars (64 ctx × depth8; be_cont 24). Seed cold twin under
 * #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */


/* 2026-08-05: pipeline_asm_emit_heavy_env.c pure-owned leave (wave119).
 * Live face: runtime_pipeline_abi.x (env gates, abort_lo/hi, path helpers,
 * skip_typeck whitelist, orchestration_extern_only, name_has_prefix,
 * top_level_const_lit). Cap residual: top_level_let/expr + driver_get path.
 * Seed cold twin under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * Residual same-TU callers (parser_emit_heavy / emit_expr_rec) link pure via
 * extern below. PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */
extern int32_t asm_env_entry_emit_heavy(void);
extern int32_t asm_env_build_skip_typeck(void);
extern int32_t asm_emit_heavy_abort_lo(void);
extern int32_t asm_emit_heavy_abort_hi(void);
extern int32_t pipeline_module_func_name_has_prefix_at(struct ast_Module *m, int32_t fi,
    const char *pfx, int32_t plen);
extern uint8_t *asm_driver_current_dep_path_for_codegen(void);
extern void asm_import_path_to_c_prefix_into(uint8_t *path, uint8_t *buf, int32_t buf_cap);
extern int32_t asm_module_top_level_const_lit_i32(struct ast_Module *m, struct ast_ASTArena *a,
    uint8_t *name, int32_t name_len, int32_t *out_imm);
extern int32_t asm_skip_typeck_entry_whitelist(struct ast_Module *m, int32_t func_index);
extern int32_t asm_orchestration_extern_only_func(struct ast_Module *m, int32_t func_index);

/* 2026-08-05: pipeline_asm_selfhost.c pure-owned leave (wave115).
 * Live face: runtime_pipeline_abi.x (num_defined/ordinal + 9 is_* predicates).
 * Seed cold twin under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * Residual same-TU callers (skip/wpo/heavy/thin) link pure via extern below.
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */
extern int32_t asm_module_num_defined_funcs(struct ast_Module *m);
extern int32_t asm_module_defined_func_ordinal(struct ast_Module *m, int32_t func_index);
extern int32_t asm_module_is_backend_selfhost(struct ast_Module *m);
extern int32_t asm_module_is_typeck_selfhost(struct ast_Module *m);
extern int32_t asm_module_is_pipeline_selfhost(struct ast_Module *m);
extern int32_t asm_module_is_main_driver_selfhost(struct ast_Module *m);
extern int32_t asm_module_is_driver_compile_selfhost(struct ast_Module *m);
extern int32_t asm_module_is_parser_selfhost(struct ast_Module *m);
extern int32_t asm_module_is_parser_emit_heavy(struct ast_Module *m);
extern int32_t asm_module_is_ast_selfhost(struct ast_Module *m);
extern int32_t asm_module_is_compiler_selfhost(struct ast_Module *m);

/* 2026-08-05: pipeline_asm_emit_heavy_safe_helper.c pure-owned leave (wave117).
 * Live face: runtime_pipeline_abi.x (9 EMIT_HEAVY 2nd-pass name classifiers).
 * Seed cold twin under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * pipeline_module_func_name_has_prefix_at pure-owned leave (wave119 emit_heavy_env).
 * Residual same-TU caller (parser_emit_heavy) links pure via extern above.
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */
extern int32_t asm_typeck_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index);
extern int32_t asm_pipeline_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index);
extern int32_t asm_driver_compile_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index);
extern int32_t asm_skip_heavy_backend_m8_helper_keep(struct ast_Module *m, int32_t func_index);
extern int32_t asm_skip_heavy_backend_helper_keep(struct ast_Module *m, int32_t func_index);
extern int32_t asm_skip_heavy_backend_m8_tail_thin_keep(struct ast_Module *m, int32_t func_index);
extern int32_t asm_skip_heavy_typeck_helper_keep(struct ast_Module *m, int32_t func_index);
extern int32_t asm_skip_heavy_backend_mega_entry(struct ast_Module *m, int32_t func_index);
extern int32_t asm_skip_heavy_typeck_mega_entry(struct ast_Module *m, int32_t func_index);


/* 2026-08-05: pipeline_asm_thin_delegate.c pure-owned leave (wave116).
 * Live face: runtime_pipeline_abi.x (backend/pipeline/driver/typeck m8-tail
 * thin delegate C-name lookup). Seed cold twin under
 * #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * k_asm_parser_thin_delegate table pure-owned with parser_emit_heavy leave
 * (wave120). PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */
extern int32_t asm_backend_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                         int32_t out_cap, int32_t *out_len);
extern int32_t asm_pipeline_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                          int32_t out_cap, int32_t *out_len);
extern int32_t asm_driver_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                        int32_t out_cap, int32_t *out_len);
extern int32_t asm_typeck_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                        int32_t out_cap, int32_t *out_len);


/* 2026-08-05: pipeline_asm_parser_emit_heavy.c pure-owned leave (wave120).
 * Live face: runtime_pipeline_abi.x (dbg/bisect/slot_max/mega/force_stub/
 * safe_helper/thin_delegate/m8_tail/resolve_call/callee_local).
 * Seed cold twin under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * Residual same-TU callers (fold_count_up_while / glue_backend_fwd) + pure
 * skip_dispatch link pure via extern below.
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */
extern void asm_parser_emit_heavy_dbg_real(struct ast_Module *m, int32_t fi, const char *why);
extern int32_t asm_parser_emit_heavy_bisect_max_index(void);
extern int32_t asm_parser_emit_heavy_slot_max(void);
extern int32_t asm_skip_heavy_parser_mega_entry(struct ast_Module *m, int32_t func_index);
extern int32_t asm_parser_emit_heavy_force_stub(struct ast_Module *m, int32_t func_index);
extern int32_t asm_parser_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index);
extern int32_t asm_parser_func_is_thin_delegate(struct ast_Module *m, int32_t func_index);
extern int32_t asm_parser_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                         int32_t out_cap, int32_t *out_len);
extern int32_t asm_parser_emit_heavy_resolve_call_to_glue(struct ast_Module *m, uint8_t *name, int32_t name_len,
                                                            uint8_t *out, int32_t out_cap, int32_t *out_len);
extern int32_t asm_parser_emit_heavy_callee_is_same_module_local(struct ast_Module *m, uint8_t *name,
                                                                  int32_t name_len);

/* 2026-08-05: pipeline_asm_skip_dispatch.c pure-owned leave (wave118).
 * Live face: runtime_pipeline_abi.x (asm_empty_text_stub_label +
 * asm_skip_heavy_module_func_body + set_pipeline_ctx BSS).
 * Seed cold twin under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * Residual same-TU callers (codegen_mega_body / call_args) + early_fwd
 * link pure via extern. PLATFORM: SHARED — no host-cc twin in pipeline_x. */
extern void asm_empty_text_stub_label(struct ast_Module *m, uint8_t *out, int32_t out_cap, int32_t *out_len);
extern int32_t asm_skip_heavy_module_func_body(struct ast_Module *m, struct ast_ASTArena *arena, int32_t func_index);

/* 2026-08-05: pipeline_asm_diag.c pure-owned leave retired.
 * Live = runtime_pipeline_abi pure asm_diag_start_func_skip + BODY/FUNC_TRACE.
 * Seed cold twins under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * Callers: backend.x / pipeline_asm_codegen_mega_body (start_func_skip);
 * early_fwd still declares extern. PLATFORM: SHARED. */

/* wave274: pipeline_asm_wpo.c pure-owned leave —
 * Live = runtime_pipeline_abi pure pipeline_asm_wpo_* (#[no_mangle]).
 * Seed cold twins under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X (WAVE274).
 * PLATFORM: SHARED freestanding WPO leave. */

/** bootstrap 链接 glue：pipeline 编排 / asm scope / typeck 指针写槽（误 revert 后补全）。 */
#include "ast_pool_bootstrap_glue.c"
