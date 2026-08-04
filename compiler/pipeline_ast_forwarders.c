/* wave1182 G.7: ast_pipeline_* forwarder cluster (246 fns) migrated from
 * pipeline_glue.c to this domain file (same-TU #include below).
 *
 * Why centralize: ast.x resolves extern pipeline_* symbols with an ast_
 * module prefix at codegen time (e.g. ast_pipeline_block_append_if), but
 * the authoritative implementations live in ast_pool.c with unprefixed C
 * names (pipeline_block_append_if). These 246 thin forwarders exist solely
 * to satisfy the linker name-mangling gap between the ast_ import prefix
 * and the unprefixed ast_pool.c symbols; colocating them here keeps
 * pipeline_glue.c focused on real glue logic instead of rename shims.
 *
 * Sub-clusters:
 *  - ast_pipeline_module_func_* (module function accessors)
 *  - ast_pipeline_dep_ctx_* (dependency context accessors)
 *  - ast_pipeline_ctx_lib_root_* (lib root path accessors)
 *  - ast_pipeline_scratch_buf* (scratch buffer accessors: 64/96/128/256)
 *  - ast_pipeline_codegen_* (codegen helpers: type kind/vector/skip-emit/force-param)
 *  - ast_pipeline_elf_ctx_* (elf context helpers: append_patch/reloc)
 *  - ast_pipeline_block_* (block statement accessors: const/let/if/while/for/stmt_order)
 *  - ast_pipeline_module_* (module accessors: import/enum/struct_layout/top_level_let)
 *  - ast_pipeline_onefunc_* (single-function sidecar accessors)
 *  - ast_pipeline_arena_* (arena capacity/alloc accessors)
 *  - pipeline_copy_lib_root_to_buf256 (utility: copy lib_root to 256-byte buf)
 *  - ast_ast_pool_onefunc_reset (forwarder to ast_pool_onefunc_reset)
 *
 * Contract: every ast_pipeline_* function here is a pure pass-through -- no
 *   state mutation, no branch, single tail call to the underlying pipeline_*
 *   impl in ast_pool.c. The one exception is pipeline_copy_lib_root_to_buf256
 *   which has minimal logic (zero-fill + bounds check + copy).
 *
 * PLATFORM: SHARED -- forwarders are platform-agnostic; underlying impls may
 *   differ per arch but the symbol surface is identical on macOS/Ubuntu.
 */

/*
 * ast.x resolves extern pipeline_* with ast_ module prefix at codegen time
 * (e.g. ast_pipeline_block_append_if); authoritative impls in ast_pool.c use
 * unprefixed C names; these forwarders satisfy the link gap.
 */
int32_t ast_pipeline_module_func_alloc_slot(struct ast_Module *m) {
  return pipeline_module_func_alloc_slot(m);
}
void ast_pipeline_module_func_ref_set(struct ast_Module *m, int32_t fi, int32_t func_ref) {
  pipeline_module_func_ref_set(m, fi, func_ref);
}
void ast_pipeline_module_func_set_return_type(struct ast_Module *m, int32_t fi, int32_t type_ref) {
  pipeline_module_func_set_return_type(m, fi, type_ref);
}
void ast_pipeline_module_func_set_body_ref(struct ast_Module *m, int32_t fi, int32_t body_ref) {
  pipeline_module_func_set_body_ref(m, fi, body_ref);
}
void ast_pipeline_module_func_set_body_expr_ref(struct ast_Module *m, int32_t fi, int32_t body_expr_ref) {
  pipeline_module_func_set_body_expr_ref(m, fi, body_expr_ref);
}
void ast_pipeline_module_func_set_is_extern(struct ast_Module *m, int32_t fi, int32_t is_extern) {
  pipeline_module_func_set_is_extern(m, fi, is_extern);
}

void ast_pipeline_module_func_set_is_async(struct ast_Module *m, int32_t fi, int32_t is_async) {
  pipeline_module_func_set_is_async(m, fi, is_async);
}
void ast_pipeline_module_func_set_num_params(struct ast_Module *m, int32_t fi, int32_t n) {
  pipeline_module_func_set_num_params(m, fi, n);
}
int32_t ast_pipeline_module_func_num_generic_params_at(struct ast_Module *m, int32_t fi) {
  return pipeline_module_func_num_generic_params_at(m, fi);
}
int32_t ast_pipeline_module_func_return_type_at(struct ast_Module *m, int32_t fi) {
  return pipeline_module_func_return_type_at(m, fi);
}
int32_t ast_pipeline_module_func_name_equal_at(struct ast_Module *m, int32_t fi, uint8_t *name, int32_t name_len) {
  return pipeline_module_func_name_equal_at(m, fi, name, name_len);
}
uint8_t ast_pipeline_module_func_name_byte_at(struct ast_Module *m, int32_t fi, int32_t i) {
  return pipeline_module_func_name_byte_at(m, fi, i);
}
int32_t ast_pipeline_module_func_body_expr_ref_at(struct ast_Module *m, int32_t fi) {
  return pipeline_module_func_body_expr_ref_at(m, fi);
}
int32_t ast_pipeline_ctx_append_lib_root(struct ast_PipelineDepCtx *ctx, uint8_t *path, int32_t len) {
  return pipeline_ctx_append_lib_root(ctx, path, len);
}
void ast_pipeline_dep_ctx_reset(struct ast_PipelineDepCtx *ctx) {
  pipeline_dep_ctx_reset(ctx);
}
/** ast.x extern pipeline_dep_ctx_*; typeck calls via ast_pipeline_* prefix (ast_pool.c implements pipeline_*). */
int32_t ast_pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_ndep(ctx);
}
struct ast_Module *ast_pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  return pipeline_dep_ctx_module_at(ctx, idx);
}
struct ast_ASTArena *ast_pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  return pipeline_dep_ctx_arena_at(ctx, idx);
}
void ast_pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_Module *m) {
  pipeline_dep_ctx_set_module(ctx, idx, m);
}
void ast_pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_ASTArena *a) {
  pipeline_dep_ctx_set_arena(ctx, idx, a);
}
void ast_pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx *ctx, int32_t n) {
  pipeline_dep_ctx_set_ndep(ctx, n);
}
void ast_pipeline_dep_ctx_set_codegen_prefix_mirror(struct ast_PipelineDepCtx *ctx, uint8_t *bytes, int32_t len) {
  pipeline_dep_ctx_set_codegen_prefix_mirror(ctx, bytes, len);
}
int32_t ast_pipeline_dep_ctx_codegen_prefix_len(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_codegen_prefix_len(ctx);
}
uint8_t ast_pipeline_dep_ctx_codegen_prefix_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off) {
  return pipeline_dep_ctx_codegen_prefix_byte_at(ctx, off);
}
void ast_pipeline_dep_ctx_codegen_prefix_copy(struct ast_PipelineDepCtx *ctx, uint8_t *dst, int32_t cap) {
  pipeline_dep_ctx_codegen_prefix_copy(ctx, dst, cap);
}
int32_t ast_pipeline_dep_ctx_current_codegen_dep_index(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_current_codegen_dep_index(ctx);
}
struct ast_Module *ast_pipeline_dep_ctx_current_codegen_module(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_current_codegen_module(ctx);
}
struct ast_ASTArena *ast_pipeline_dep_ctx_current_codegen_arena(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_current_codegen_arena(ctx);
}
int32_t ast_pipeline_dep_ctx_current_func_index(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_current_func_index(ctx);
}
void ast_pipeline_dep_ctx_set_current_codegen_module(struct ast_PipelineDepCtx *ctx, struct ast_Module *m) {
  pipeline_dep_ctx_set_current_codegen_module(ctx, m);
}
void ast_pipeline_dep_ctx_set_current_codegen_arena(struct ast_PipelineDepCtx *ctx, struct ast_ASTArena *a) {
  pipeline_dep_ctx_set_current_codegen_arena(ctx, a);
}
void ast_pipeline_dep_ctx_set_current_codegen_dep_index(struct ast_PipelineDepCtx *ctx, int32_t ix) {
  pipeline_dep_ctx_set_current_codegen_dep_index(ctx, ix);
}
void ast_pipeline_dep_ctx_set_current_func_index(struct ast_PipelineDepCtx *ctx, int32_t ix) {
  pipeline_dep_ctx_set_current_func_index(ctx, ix);
}
int32_t ast_pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_entry_already_parsed(ctx);
}
int32_t ast_pipeline_dep_ctx_asm_entry_module_only(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_asm_entry_module_only(ctx);
}
int32_t ast_pipeline_dep_ctx_check_only_mode(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_check_only_mode(ctx);
}
int32_t ast_pipeline_dep_ctx_use_asm_backend(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_use_asm_backend(ctx);
}
uint8_t ast_pipeline_dep_ctx_entry_dir_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off) {
  return pipeline_dep_ctx_entry_dir_byte_at(ctx, off);
}
uint8_t *ast_pipeline_scratch_buf64(void) {
  return pipeline_scratch_buf64();
}
uint8_t *ast_pipeline_scratch_buf64_slot(int32_t slot) {
  return pipeline_scratch_buf64_slot(slot);
}
uint8_t *ast_pipeline_scratch_buf128(void) {
  return pipeline_scratch_buf128();
}
uint8_t *ast_pipeline_scratch_buf128_slot(int32_t slot) {
  return pipeline_scratch_buf128_slot(slot);
}
uint8_t *ast_pipeline_scratch_buf96(void) {
  return pipeline_scratch_buf96();
}
uint8_t *ast_pipeline_scratch_buf256(void) {
  return pipeline_scratch_buf256();
}
uint8_t *ast_pipeline_scratch_buf256_slot(int32_t slot) {
  return pipeline_scratch_buf256_slot(slot);
}
int32_t ast_pipeline_codegen_type_kind_copy(uint8_t *dst, int32_t cap, int32_t kind) {
  return pipeline_codegen_type_kind_copy(dst, cap, kind);
}
int32_t ast_pipeline_codegen_type_kind_append(uint8_t *scratch, int32_t cap, int32_t w, int32_t kind) {
  return pipeline_codegen_type_kind_append(scratch, cap, w, kind);
}
int32_t ast_pipeline_codegen_vector_type_copy(uint8_t *dst, int32_t cap, int32_t elem_kind, int32_t lanes) {
  return pipeline_codegen_vector_type_copy(dst, cap, elem_kind, lanes);
}
int32_t ast_pipeline_codegen_call_num_args_override_lookup(uint8_t *buf, int32_t full, int32_t num_args) {
  return pipeline_codegen_call_num_args_override_lookup(buf, full, num_args);
}
int32_t ast_pipeline_codegen_call_num_args_override(uint8_t *prefix, int32_t prefix_len, uint8_t *name,
                                                    int32_t name_len, int32_t num_args) {
  return pipeline_codegen_call_num_args_override(prefix, prefix_len, name, name_len, num_args);
}
int32_t ast_pipeline_codegen_is_std_io_driver_bridge_name(uint8_t *name, int32_t name_len) {
  return pipeline_codegen_is_std_io_driver_bridge_name(name, name_len);
}
int32_t ast_pipeline_codegen_path_is_std_io_driver_bytes(uint8_t *path) {
  return pipeline_codegen_path_is_std_io_driver_bytes(path);
}
int32_t ast_pipeline_codegen_path_is_std_io_core_bytes(uint8_t *path) {
  return pipeline_codegen_path_is_std_io_core_bytes(path);
}
int32_t ast_pipeline_codegen_should_skip_emit_std_io_core_io_dup(uint8_t *dep_path, uint8_t *name, int32_t name_len) {
  return pipeline_codegen_should_skip_emit_std_io_core_io_dup(dep_path, name, name_len);
}
int32_t ast_pipeline_codegen_should_skip_emit_std_io_trivial_handle(uint8_t *dep_path, uint8_t *name,
                                                                    int32_t name_len) {
  return pipeline_codegen_should_skip_emit_std_io_trivial_handle(dep_path, name, name_len);
}
int32_t ast_pipeline_codegen_should_skip_emit_func(uint8_t *dep_path, uint8_t *prefix, int32_t prefix_len,
                                                   uint8_t *name, int32_t name_len) {
  return pipeline_codegen_should_skip_emit_func(dep_path, prefix, prefix_len, name, name_len);
}
int32_t ast_pipeline_codegen_skip_emit_extern_io_batch_buf(uint8_t *name, int32_t name_len) {
  return pipeline_codegen_skip_emit_extern_io_batch_buf(name, name_len);
}
int32_t ast_pipeline_codegen_entry_is_lsp_io_module(struct ast_Module *module) {
  return pipeline_codegen_entry_is_lsp_io_module(module);
}
int32_t ast_pipeline_codegen_entry_is_lsp_main_module(struct ast_Module *module) {
  return pipeline_codegen_entry_is_lsp_main_module(module);
}
int32_t ast_pipeline_codegen_force_param_std_io_driver_prefix_ok(uint8_t *prefix, int32_t prefix_len) {
  return pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len);
}
int32_t ast_pipeline_codegen_force_param_size_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                                int32_t param_index) {
  return pipeline_codegen_force_param_size_t(prefix, prefix_len, name, name_len, param_index);
}
int32_t ast_pipeline_codegen_force_param_size_t_std_io_print_str_second(uint8_t *prefix, int32_t prefix_len,
                                                                        uint8_t *name, int32_t name_len,
                                                                        int32_t param_index) {
  return pipeline_codegen_force_param_size_t_std_io_print_str_second(prefix, prefix_len, name, name_len, param_index);
}
int32_t ast_pipeline_codegen_force_param_ptrdiff_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                                   int32_t param_index) {
  return pipeline_codegen_force_param_ptrdiff_t(prefix, prefix_len, name, name_len, param_index);
}
int32_t ast_pipeline_codegen_force_param_uint32_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                                  int32_t param_index) {
  return pipeline_codegen_force_param_uint32_t(prefix, prefix_len, name, name_len, param_index);
}
int32_t ast_pipeline_codegen_use_buf_wrapper(uint8_t *name, int32_t name_len, int32_t num_args) {
  return pipeline_codegen_use_buf_wrapper(name, name_len, num_args);
}
int32_t ast_pipeline_codegen_should_skip_emit_func_by_name(uint8_t *name, int32_t name_len) {
  return pipeline_codegen_should_skip_emit_func_by_name(name, name_len);
}
int32_t ast_pipeline_codegen_is_submit_batch_buf_call(uint8_t *name, int32_t name_len) {
  return pipeline_codegen_is_submit_batch_buf_call(name, name_len);
}
int32_t ast_pipeline_codegen_should_skip_emit_func_core_read_ptr(uint8_t *name, int32_t name_len) {
  return pipeline_codegen_should_skip_emit_func_core_read_ptr(name, name_len);
}
int32_t ast_pipeline_codegen_io_driver_buf_call_sym(uint8_t *name, int32_t name_len, int32_t num_args,
                                                    uint8_t *sym_out, int32_t sym_cap) {
  return pipeline_codegen_io_driver_buf_call_sym(name, name_len, num_args, sym_out, sym_cap);
}
int32_t ast_pipeline_codegen_std_io_fixed_fd_emit_impl(uint8_t *prefix, int32_t prefix_len, uint8_t *name,
                                                     int32_t name_len) {
  return pipeline_codegen_std_io_fixed_fd_emit_impl(prefix, prefix_len, name, name_len);
}
int32_t ast_pipeline_elf_ctx_append_patch(uint8_t *ctx_bytes, int32_t rel32_offset, uint8_t *name, int32_t name_len,
                                          int32_t imm_bits) {
  return pipeline_elf_ctx_append_patch(ctx_bytes, rel32_offset, name, name_len, imm_bits);
}
int32_t ast_pipeline_elf_ctx_append_reloc(uint8_t *ctx_bytes, int32_t offset, uint8_t *name, int32_t name_len) {
  return pipeline_elf_ctx_append_reloc(ctx_bytes, offset, name, name_len);
}
void ast_pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *bytes, int32_t len) {
  pipeline_dep_ctx_set_import_path(ctx, idx, bytes, len);
}
int32_t ast_pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  return pipeline_dep_ctx_import_path_len(ctx, idx);
}
void ast_pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst) {
  pipeline_dep_ctx_import_path_copy64(ctx, idx, dst);
}
void ast_pipeline_dep_ctx_set_path_buf_byte(struct ast_PipelineDepCtx *ctx, int32_t off, uint8_t b) {
  pipeline_dep_ctx_set_path_buf_byte(ctx, off, b);
}
int32_t ast_pipeline_dep_ctx_entry_dir_len(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_entry_dir_len(ctx);
}
uint8_t *ast_pipeline_dep_ctx_loaded_buf_ptr(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_loaded_buf_ptr(ctx);
}
int32_t ast_pipeline_dep_ctx_ensure_source_buffers(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_ensure_source_buffers(ctx);
}
void ast_pipeline_dep_ctx_free_source_buffers(struct ast_PipelineDepCtx *ctx) {
  pipeline_dep_ctx_free_source_buffers(ctx);
}
void ast_pipeline_dep_ctx_heap_destroy(struct ast_PipelineDepCtx *ctx) {
  pipeline_dep_ctx_heap_destroy(ctx);
}
uint8_t *ast_pipeline_dep_ctx_path_buf_ptr(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_path_buf_ptr(ctx);
}
uint8_t *ast_pipeline_dep_ctx_preprocess_buf_ptr(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_preprocess_buf_ptr(ctx);
}
void ast_pipeline_dep_ctx_set_loaded_len(struct ast_PipelineDepCtx *ctx, ptrdiff_t n) {
  pipeline_dep_ctx_set_loaded_len(ctx, n);
}
int32_t ast_pipeline_ctx_lib_root_count(struct ast_PipelineDepCtx *ctx) {
  return pipeline_ctx_lib_root_count(ctx);
}
int32_t ast_pipeline_ctx_lib_root_len(struct ast_PipelineDepCtx *ctx, int32_t i) {
  return pipeline_ctx_lib_root_len(ctx, i);
}
void ast_pipeline_ctx_lib_root_copy(struct ast_PipelineDepCtx *ctx, int32_t i, uint8_t *dst, int32_t cap) {
  pipeline_ctx_lib_root_copy(ctx, i, dst, cap);
}

/**
 * Copy lib_root[lib_idx] into dst[0..255] (zero-filled first); returns lib_root byte length.
 * Avoids resolve_path_x's `let buf: u8[256] = []` triggering parse_into_buf to skip large function bodies.
 */
int32_t pipeline_copy_lib_root_to_buf256(struct ast_PipelineDepCtx *ctx, int32_t lib_idx, uint8_t *dst) {
  int32_t i;
  int32_t lr_len;
  if (!dst)
    return 0;
  for (i = 0; i < 256; i++)
    dst[i] = 0;
  if (!ctx || lib_idx < 0)
    return 0;
  lr_len = pipeline_ctx_lib_root_len(ctx, lib_idx);
  if (lr_len > 0)
    pipeline_ctx_lib_root_copy(ctx, lib_idx, dst, 256);
  return lr_len;
}

uint8_t ast_pipeline_ctx_lib_root_byte_at(struct ast_PipelineDepCtx *ctx, int32_t i, int32_t off) {
  return pipeline_ctx_lib_root_byte_at(ctx, i, off);
}
int32_t ast_pipeline_block_append_const(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                        int32_t type_ref, int32_t init_ref) {
  return pipeline_block_append_const(a, br, name, name_len, type_ref, init_ref);
}
int32_t ast_pipeline_block_append_let(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                      int32_t type_ref, int32_t init_ref) {
  return pipeline_block_append_let(a, br, name, name_len, type_ref, init_ref);
}
int32_t ast_pipeline_block_append_if(struct ast_ASTArena *a, int32_t br, int32_t cond_ref, int32_t then_ref,
                                     int32_t else_ref) {
  return pipeline_block_append_if(a, br, cond_ref, then_ref, else_ref);
}
/** M-3: parser.x import ast prefix -> ast_pool pipeline_block_append_region. */
int32_t ast_pipeline_block_append_region(struct ast_ASTArena *a, int32_t br, uint8_t *label, int32_t label_len,
                                         int32_t body_ref) {
  return pipeline_block_append_region(a, br, label, label_len, body_ref);
}
/** LANG-007 v2: parser.x -> ast_pool pipeline_block_append_unsafe. */
int32_t ast_pipeline_block_append_unsafe(struct ast_ASTArena *a, int32_t br, int32_t body_ref) {
  return pipeline_block_append_unsafe(a, br, body_ref);
}
/** MEM-C1: parser.x -> ast_pool pipeline_block_append_with_arena. */
int32_t ast_pipeline_block_append_with_arena(struct ast_ASTArena *a, int32_t br, int32_t cap_ref, int32_t body_ref) {
  return pipeline_block_append_with_arena(a, br, cap_ref, body_ref);
}
int32_t ast_pipeline_block_append_while(struct ast_ASTArena *a, int32_t br, int32_t cond_ref, int32_t body_ref) {
  return pipeline_block_append_while(a, br, cond_ref, body_ref);
}
int32_t ast_pipeline_block_append_for(struct ast_ASTArena *a, int32_t br, int32_t init_ref, int32_t cond_ref,
                                      int32_t step_ref, int32_t body_ref) {
  return pipeline_block_append_for(a, br, init_ref, cond_ref, step_ref, body_ref);
}
int32_t ast_pipeline_module_import_alloc(struct ast_Module *m) {
  return pipeline_module_import_alloc(m);
}
void ast_pipeline_module_import_set_path(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  pipeline_module_import_set_path(m, idx, bytes, len);
}
void ast_pipeline_module_import_set_kind(struct ast_Module *m, int32_t idx, int32_t kind) {
  pipeline_module_import_set_kind(m, idx, kind);
}
void ast_pipeline_module_import_set_binding_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  pipeline_module_import_set_binding_name(m, idx, bytes, len);
}
void ast_pipeline_module_import_set_select_count(struct ast_Module *m, int32_t idx, int32_t n) {
  pipeline_module_import_set_select_count(m, idx, n);
}
void ast_pipeline_module_import_path_copy(struct ast_Module *m, int32_t idx, uint8_t *dst, int32_t dst_cap) {
  pipeline_module_import_path_copy(m, idx, dst, dst_cap);
}
int32_t ast_pipeline_module_enum_alloc(struct ast_Module *m) {
  return pipeline_module_enum_alloc(m);
}
void ast_pipeline_module_enum_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  pipeline_module_enum_set_name(m, idx, bytes, len);
}
int32_t ast_pipeline_module_top_level_let_alloc(struct ast_Module *m) {
  return pipeline_module_top_level_let_alloc(m);
}
void ast_pipeline_module_top_level_let_set(struct ast_Module *m, int32_t idx, uint8_t *name, int32_t name_len,
                                            int32_t type_ref, int32_t init_ref, int32_t is_const) {
  pipeline_module_top_level_let_set(m, idx, name, name_len, type_ref, init_ref, is_const);
}
void ast_pipeline_module_hoist_top_level_lets_into_main(struct ast_Module *m, struct ast_ASTArena *a) {
  pipeline_module_hoist_top_level_lets_into_main(m, a);
}
int32_t ast_pipeline_module_import_path_len(struct ast_Module *m, int32_t idx) {
  return pipeline_module_import_path_len(m, idx);
}
uint8_t ast_pipeline_module_import_path_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  return pipeline_module_import_path_byte_at(m, idx, off);
}
int32_t ast_pipeline_module_import_kind_at(struct ast_Module *m, int32_t idx) {
  return pipeline_module_import_kind_at(m, idx);
}
int32_t ast_pipeline_module_import_binding_name_len(struct ast_Module *m, int32_t idx) {
  return pipeline_module_import_binding_name_len(m, idx);
}
uint8_t ast_pipeline_module_import_binding_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  return pipeline_module_import_binding_name_byte_at(m, idx, off);
}
int32_t ast_pipeline_module_import_select_count_at(struct ast_Module *m, int32_t idx) {
  return pipeline_module_import_select_count_at(m, idx);
}
int32_t ast_pipeline_module_import_select_name_len(struct ast_Module *m, int32_t idx, int32_t sel) {
  return pipeline_module_import_select_name_len(m, idx, sel);
}
uint8_t ast_pipeline_module_import_select_name_byte_at(struct ast_Module *m, int32_t idx, int32_t sel, int32_t off) {
  return pipeline_module_import_select_name_byte_at(m, idx, sel, off);
}
int32_t ast_pipeline_module_struct_layout_alloc(struct ast_Module *m) {
  return pipeline_module_struct_layout_alloc(m);
}
void ast_pipeline_module_struct_layout_reset_slot(struct ast_Module *m, int32_t idx) {
  pipeline_module_struct_layout_reset_slot(m, idx);
}
void ast_pipeline_module_struct_layout_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  pipeline_module_struct_layout_set_name(m, idx, bytes, len);
}
void ast_pipeline_module_struct_layout_set_field(struct ast_Module *m, int32_t li, int32_t j, uint8_t *fname_bytes,
                                                 int32_t fname_len, int32_t ftype_ref, int32_t foff) {
  pipeline_module_struct_layout_set_field(m, li, j, fname_bytes, fname_len, ftype_ref, foff);
}
void ast_pipeline_module_struct_layout_set_num_fields(struct ast_Module *m, int32_t idx, int32_t nf) {
  pipeline_module_struct_layout_set_num_fields(m, idx, nf);
}
int32_t ast_pipeline_module_struct_layout_name_len(struct ast_Module *m, int32_t idx) {
  return pipeline_module_struct_layout_name_len(m, idx);
}
void ast_pipeline_module_struct_layout_name_into(struct ast_Module *m, int32_t idx, uint8_t *out64) {
  pipeline_module_struct_layout_name_into(m, idx, out64);
}
uint8_t ast_pipeline_module_struct_layout_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  return pipeline_module_struct_layout_name_byte_at(m, idx, off);
}
int32_t ast_pipeline_module_struct_layout_num_fields(struct ast_Module *m, int32_t idx) {
  return pipeline_module_struct_layout_num_fields(m, idx);
}
int32_t ast_pipeline_module_struct_layout_field_name_len(struct ast_Module *m, int32_t li, int32_t j) {
  return pipeline_module_struct_layout_field_name_len(m, li, j);
}
void ast_pipeline_module_struct_layout_field_name_into(struct ast_Module *m, int32_t li, int32_t j, uint8_t *out64) {
  pipeline_module_struct_layout_field_name_into(m, li, j, out64);
}
int32_t ast_pipeline_module_struct_layout_field_type_ref(struct ast_Module *m, int32_t li, int32_t j) {
  return pipeline_module_struct_layout_field_type_ref(m, li, j);
}
int32_t ast_pipeline_module_struct_layout_field_offset_at(struct ast_Module *m, int32_t li, int32_t j) {
  return pipeline_module_struct_layout_field_offset_at(m, li, j);
}
void ast_pipeline_module_struct_layout_set_allow_padding(struct ast_Module *m, int32_t idx, int32_t v) {
  pipeline_module_struct_layout_set_allow_padding(m, idx, v);
}
int32_t ast_pipeline_module_struct_layout_allow_padding_at(struct ast_Module *m, int32_t idx) {
  return pipeline_module_struct_layout_allow_padding_at(m, idx);
}
int32_t ast_pipeline_module_top_level_let_name_len(struct ast_Module *m, int32_t idx) {
  return pipeline_module_top_level_let_name_len(m, idx);
}
uint8_t ast_pipeline_module_top_level_let_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  return pipeline_module_top_level_let_name_byte_at(m, idx, off);
}
int32_t ast_pipeline_module_top_level_let_type_ref(struct ast_Module *m, int32_t idx) {
  return pipeline_module_top_level_let_type_ref(m, idx);
}
int32_t ast_pipeline_module_top_level_let_init_ref(struct ast_Module *m, int32_t idx) {
  return pipeline_module_top_level_let_init_ref(m, idx);
}
int32_t ast_pipeline_module_top_level_let_is_const(struct ast_Module *m, int32_t idx) {
  return pipeline_module_top_level_let_is_const(m, idx);
}
int32_t ast_pipeline_module_enum_name_len(struct ast_Module *m, int32_t idx) {
  return pipeline_module_enum_name_len(m, idx);
}
uint8_t ast_pipeline_module_enum_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  return pipeline_module_enum_name_byte_at(m, idx, off);
}

int32_t ast_pipeline_module_enum_append_variant(struct ast_Module *m, int32_t idx, uint8_t *bytes,
                                                int32_t len) {
  return pipeline_module_enum_append_variant(m, idx, bytes, len);
}

int32_t ast_pipeline_module_enum_variant_tag_for_names(struct ast_Module *m, uint8_t *enum_name,
                                                         int32_t enum_len, uint8_t *variant_name,
                                                         int32_t variant_len) {
  return pipeline_module_enum_variant_tag_for_names(m, enum_name, enum_len, variant_name, variant_len);
}

void ast_pipeline_expr_try_mark_enum_field_access(struct ast_Module *m, struct ast_ASTArena *a,
                                                  int32_t expr_ref) {
  pipeline_expr_try_mark_enum_field_access(m, a, expr_ref);
}
void ast_ast_pool_onefunc_reset(uint8_t *out) {
  ast_pool_onefunc_reset(out);
}
int32_t ast_pipeline_onefunc_num_consts(uint8_t *out) {
  return pipeline_onefunc_num_consts(out);
}
int32_t ast_pipeline_onefunc_num_lets(uint8_t *out) {
  return pipeline_onefunc_num_lets(out);
}
int32_t ast_pipeline_onefunc_num_whiles(uint8_t *out) {
  return pipeline_onefunc_num_whiles(out);
}
int32_t ast_pipeline_onefunc_num_fors(uint8_t *out) {
  return pipeline_onefunc_num_fors(out);
}
int32_t ast_pipeline_onefunc_const_name_len(uint8_t *out, int32_t i) {
  return pipeline_onefunc_const_name_len(out, i);
}
void ast_pipeline_onefunc_const_name_copy64(uint8_t *out, int32_t i, uint8_t *dst) {
  pipeline_onefunc_const_name_copy64(out, i, dst);
}
int32_t ast_pipeline_onefunc_const_init_val(uint8_t *out, int32_t i) {
  return pipeline_onefunc_const_init_val(out, i);
}
int32_t ast_pipeline_onefunc_let_name_len(uint8_t *out, int32_t i) {
  return pipeline_onefunc_let_name_len(out, i);
}
void ast_pipeline_onefunc_let_name_copy64(uint8_t *out, int32_t i, uint8_t *dst) {
  pipeline_onefunc_let_name_copy64(out, i, dst);
}
int32_t ast_pipeline_onefunc_let_init_val(uint8_t *out, int32_t i) {
  return pipeline_onefunc_let_init_val(out, i);
}
int32_t ast_pipeline_onefunc_let_init_ref(uint8_t *out, int32_t i) {
  return pipeline_onefunc_let_init_ref(out, i);
}
int32_t ast_pipeline_onefunc_let_type_ref(uint8_t *out, int32_t i) {
  return pipeline_onefunc_let_type_ref(out, i);
}
int32_t ast_pipeline_onefunc_append_let(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val, int32_t init_ref,
                                        int32_t type_ref) {
  return pipeline_onefunc_append_let(out, name, name_len, init_val, init_ref, type_ref);
}
int32_t ast_pipeline_onefunc_append_const(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val,
                                          int32_t init_ref, int32_t type_ref) {
  return pipeline_onefunc_append_const(out, name, name_len, init_val, init_ref, type_ref);
}
int32_t ast_pipeline_onefunc_const_init_ref(uint8_t *out, int32_t i) {
  return pipeline_onefunc_const_init_ref(out, i);
}
int32_t ast_pipeline_onefunc_const_type_ref(uint8_t *out, int32_t i) {
  return pipeline_onefunc_const_type_ref(out, i);
}
int32_t ast_pipeline_onefunc_append_while(uint8_t *out, int32_t cond_ref, int32_t body_ref) {
  return pipeline_onefunc_append_while(out, cond_ref, body_ref);
}
int32_t ast_pipeline_onefunc_append_for(uint8_t *out, int32_t init_ref, int32_t cond_ref, int32_t step_ref,
                                        int32_t body_ref) {
  return pipeline_onefunc_append_for(out, init_ref, cond_ref, step_ref, body_ref);
}
void ast_pipeline_onefunc_copy_sidecar(uint8_t *dst, uint8_t *src) {
  pipeline_onefunc_copy_sidecar(dst, src);
}
int32_t ast_pipeline_block_append_expr_stmt(struct ast_ASTArena *a, int32_t br, int32_t expr_ref) {
  return pipeline_block_append_expr_stmt(a, br, expr_ref);
}
int32_t ast_pipeline_block_append_stmt_order(struct ast_ASTArena *a, int32_t br, uint8_t kind, int32_t idx) {
  return pipeline_block_append_stmt_order(a, br, kind, idx);
}

/** parser.x: reorder stmt_order when prefix lets are out of order (with_arena_vec gate). */
void ast_pipeline_block_stmt_order_fix_prefix_lets(struct ast_ASTArena *a, int32_t br, int32_t prefix_n) {
  pipeline_block_stmt_order_fix_prefix_lets(a, br, prefix_n);
}

/** with_arena: append kind=6 region to stmt_order (asm misses inner body emit when parse flattens let/if). */
void ast_pipeline_block_with_arena_fixup_stmt_order(struct ast_ASTArena *a, int32_t br) {
  pipeline_block_with_arena_fixup_stmt_order(a, br);
}
int32_t ast_pipeline_block_append_labeled(struct ast_ASTArena *a, int32_t br, int32_t label_len, int32_t is_goto,
                                           int32_t goto_target_len, int32_t return_expr_ref) {
  return pipeline_block_append_labeled(a, br, label_len, is_goto, goto_target_len, return_expr_ref);
}
int32_t ast_pipeline_block_labeled_return_expr_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  return pipeline_block_labeled_return_expr_ref(a, br, li);
}
void ast_pipeline_block_fill_ifs_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  pipeline_block_fill_ifs_from_onefunc(a, br, out, count);
}
void ast_pipeline_block_fill_whiles_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  pipeline_block_fill_whiles_from_onefunc(a, br, out, count);
}
void ast_pipeline_block_fill_fors_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  pipeline_block_fill_fors_from_onefunc(a, br, out, count);
}
void ast_pipeline_block_fill_stmt_order_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  pipeline_block_fill_stmt_order_from_onefunc(a, br, out, count);
}
void ast_pipeline_block_fill_expr_stmts_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  pipeline_block_fill_expr_stmts_from_onefunc(a, br, out, count);
}
int32_t ast_pipeline_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  return pipeline_block_const_init_ref(a, br, ci);
}
int32_t ast_pipeline_block_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  return pipeline_block_const_type_ref(a, br, ci);
}
int32_t ast_pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  return pipeline_block_let_init_ref(a, br, li);
}
int32_t ast_pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  return pipeline_block_let_type_ref(a, br, li);
}
int32_t ast_pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei) {
  return pipeline_block_expr_stmt_ref(a, br, ei);
}
uint8_t ast_pipeline_block_stmt_order_kind(struct ast_ASTArena *a, int32_t br, int32_t si) {
  return pipeline_block_stmt_order_kind(a, br, si);
}
int32_t ast_pipeline_block_stmt_order_idx(struct ast_ASTArena *a, int32_t br, int32_t si) {
  return pipeline_block_stmt_order_idx(a, br, si);
}
int32_t ast_pipeline_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  return pipeline_block_if_cond_ref(a, br, ii);
}
int32_t ast_pipeline_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  return pipeline_block_if_then_body_ref(a, br, ii);
}
int32_t ast_pipeline_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  return pipeline_block_if_else_body_ref(a, br, ii);
}
int32_t ast_pipeline_block_const_name_len(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  return pipeline_block_const_name_len(a, br, ci);
}
void ast_pipeline_block_const_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t ci, uint8_t *dst) {
  pipeline_block_const_name_copy64(a, br, ci, dst);
}
int32_t ast_pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li) {
  return pipeline_block_let_name_len(a, br, li);
}
void ast_pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst) {
  pipeline_block_let_name_copy64(a, br, li, dst);
}
int32_t ast_pipeline_block_resolve_var_type_ref(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname,
                                                 int32_t vlen) {
  return pipeline_block_resolve_var_type_ref(a, block_ref, vname, vlen);
}
int32_t ast_pipeline_module_func_ref_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_module_func_ref_at(m, func_index);
}
int32_t ast_pipeline_arena_type_cap(void) { return pipeline_arena_type_cap(); }
int32_t ast_pipeline_arena_expr_cap(void) { return pipeline_arena_expr_cap(); }
int32_t ast_pipeline_arena_block_cap(void) { return pipeline_arena_block_cap(); }
int32_t ast_pipeline_arena_func_cap(void) { return pipeline_arena_func_cap(); }
int32_t ast_pipeline_arena_type_alloc(struct ast_ASTArena *a) { return pipeline_arena_type_alloc(a); }
int32_t ast_pipeline_arena_expr_alloc(struct ast_ASTArena *a) { return pipeline_arena_expr_alloc(a); }
int32_t ast_pipeline_arena_block_alloc(struct ast_ASTArena *a) { return pipeline_arena_block_alloc(a); }
int32_t ast_pipeline_arena_func_alloc(struct ast_ASTArena *a) { return pipeline_arena_func_alloc(a); }
