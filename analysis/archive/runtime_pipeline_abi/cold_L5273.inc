/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */

/* wave104 emit_sidecar leave cold twins — remaining qual_* (not unique).
 * PLATFORM: SHARED — only when pure FROM_X object is not linked. Product pure
 * owns strong asm_qual_sym_* after host-cc leave. Fixed caps match pure:
 * 32 qual layers × 64B. Emit lib_root unique + BSS live in the leftover
 * unique OR above (after closing enclosing wave101). Not here — leftover
 * rest compiles that OR; a second def here would dual-def in the same TU
 * (cold full seed compiles both). */
#define WAVE104_QUAL_MAX 32
#define WAVE104_QUAL_W 64

static int32_t wave104_qual_n;
static uint8_t wave104_qual_rows[WAVE104_QUAL_MAX * WAVE104_QUAL_W];
static int32_t wave104_qual_lens[WAVE104_QUAL_MAX];

void asm_qual_sym_layer_reset(void) {
  wave104_qual_n = 0;
}

int32_t asm_qual_sym_layer_push(uint8_t *bytes, int32_t len) {
  int32_t n, idx, base, k;
  if (!bytes || len <= 0)
    return -1;
  if (wave104_qual_n >= WAVE104_QUAL_MAX)
    return -1;
  n = len > 63 ? 63 : len;
  idx = wave104_qual_n;
  base = idx * WAVE104_QUAL_W;
  memset(&wave104_qual_rows[base], 0, WAVE104_QUAL_W);
  memcpy(&wave104_qual_rows[base], bytes, (size_t)n);
  wave104_qual_lens[idx] = n;
  wave104_qual_n = idx + 1;
  return idx;
}

int32_t asm_qual_sym_layer_count(void) {
  return wave104_qual_n;
}

int32_t asm_qual_sym_layer_len(int32_t i) {
  if (i < 0 || i >= wave104_qual_n)
    return 0;
  return wave104_qual_lens[i];
}

void asm_qual_sym_layer_copy(int32_t i, uint8_t *dst, int32_t cap) {
  int32_t n, base, k;
  if (!dst || cap <= 0)
    return;
  memset(dst, 0, (size_t)cap);
  if (i < 0 || i >= wave104_qual_n)
    return;
  n = wave104_qual_lens[i];
  if (n >= cap)
    n = cap - 1;
  base = i * WAVE104_QUAL_W;
  for (k = 0; k < n; k++)
    dst[k] = wave104_qual_rows[base + k];
}

/* wave105 resolve_path leave cold twins — former pipeline_resolve_path.c.
 * PLATFORM: SHARED — only when pure FROM_X object is not linked. Product pure
 * owns strong path_append_*_c / probe / flat / off-sidecar / codegen_out_buf_* /
 * resolve_path_x_impl_c|_c after host-cc leave. Probe bytes match historical
 * host-cc leaf (46,115,117 and /mod + same). Prefer void* like wave101. */
extern void pipeline_dep_ctx_set_path_buf_byte(void *ctx, int32_t off, uint8_t b);
extern uint8_t *pipeline_dep_ctx_path_buf_ptr(void *ctx);
extern int32_t pipeline_dep_ctx_entry_dir_len(void *ctx);
extern void pipeline_dep_ctx_entry_dir_copy(void *ctx, uint8_t *dst, int32_t cap);
extern int32_t pipeline_copy_lib_root_to_buf256(void *ctx, int32_t lib_idx, uint8_t *dst);
extern int32_t pipeline_ctx_lib_root_count(void *ctx);
extern int32_t std_fs_fs_open_read(uint8_t *path);
extern int32_t std_fs_fs_close(int32_t fd);
extern int32_t pipeline_resolve_path_x(void *ctx, uint8_t *import_path, int32_t path_len);

static int32_t wave105_resolve_off;

int32_t pipeline_path_append_from_buf_256_c(void *ctx, int32_t off, uint8_t *buf, int32_t len) {
  int32_t k;
  if (!ctx || !buf || len <= 0)
    return off;
  k = 0;
  while (k < len && off < 508) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, buf[k]);
    off++;
    k++;
  }
  return off;
}

int32_t pipeline_path_append_from_buf_512_c(void *ctx, int32_t off, uint8_t *buf, int32_t len) {
  return pipeline_path_append_from_buf_256_c(ctx, off, buf, len);
}

int32_t pipeline_path_append_import_path_c(void *ctx, int32_t off, uint8_t *import_path, int32_t path_len) {
  int32_t k;
  uint8_t b;
  if (!ctx || !import_path || path_len <= 0)
    return off;
  k = 0;
  while (k < path_len && off < 508) {
    b = import_path[k];
    if (b == 46)
      b = 47;
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, b);
    off++;
    k++;
  }
  return off;
}

int32_t pipeline_resolve_path_import_has_dot_c(uint8_t *import_path, int32_t path_len) {
  int32_t k;
  if (!import_path || path_len <= 0)
    return 0;
  k = 0;
  while (k < path_len && k < 64) {
    if (import_path[k] == 46)
      return 1;
    k++;
  }
  return 0;
}

#define WAVE105_CODEGEN_OUTBUF_CAP 9437184

int32_t codegen_out_buf_len(void *out) {
  if (!out)
    return 0;
  return *(int32_t *)((uint8_t *)out + (ptrdiff_t)WAVE105_CODEGEN_OUTBUF_CAP);
}

void codegen_out_buf_set_len(void *out, int32_t n) {
  if (out)
    *(int32_t *)((uint8_t *)out + (ptrdiff_t)WAVE105_CODEGEN_OUTBUF_CAP) = n > 0 ? n : 0;
}

static int32_t wave105_probe_dot_x_and_mod(void *ctx, int32_t off) {
  int32_t fd;
  if (!ctx)
    return -1;
  if (off + 4 <= 512) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, 46);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off + 1, 115);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off + 2, 117);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off + 3, 0);
    fd = std_fs_fs_open_read(pipeline_dep_ctx_path_buf_ptr(ctx));
    if (fd >= 0) {
      std_fs_fs_close(fd);
      return 0;
    }
    if (off + 8 <= 512) {
      pipeline_dep_ctx_set_path_buf_byte(ctx, off, 47);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 1, 109);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 2, 111);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 3, 100);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 4, 46);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 5, 115);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 6, 117);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 7, 0);
      fd = std_fs_fs_open_read(pipeline_dep_ctx_path_buf_ptr(ctx));
      if (fd >= 0) {
        std_fs_fs_close(fd);
        return 0;
      }
    }
  }
  return -1;
}

int32_t pipeline_resolve_path_last_off_get_c(void) {
  return wave105_resolve_off;
}

int32_t pipeline_resolve_path_lib_root_prefix_off_c(void *ctx, int32_t lib_idx) {
  uint8_t lr_buf[256];
  int32_t lr_len;
  int32_t off;
  if (!ctx || lib_idx < 0)
    return -1;
  memset(lr_buf, 0, sizeof(lr_buf));
  lr_len = pipeline_copy_lib_root_to_buf256(ctx, lib_idx, lr_buf);
  off = 0;
  if (lr_len > 0)
    off = pipeline_path_append_from_buf_256_c(ctx, 0, lr_buf, lr_len);
  if (off < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, 47);
    off = off + 1;
  }
  wave105_resolve_off = off;
  return off;
}

int32_t pipeline_path_append_import_path_sidecar_c(void *ctx, int32_t off, uint8_t *import_path, int32_t path_len) {
  int32_t new_off;
  if (!ctx || !import_path || off < 0)
    return -1;
  new_off = pipeline_path_append_import_path_c(ctx, off, import_path, path_len);
  if (new_off < 0)
    return -1;
  wave105_resolve_off = new_off;
  return new_off;
}

int32_t pipeline_resolve_path_entry_dir_prefix_off_c(void *ctx) {
  int32_t ed_len;
  uint8_t ed_buf[512];
  int32_t off;
  if (!ctx)
    return -1;
  ed_len = pipeline_dep_ctx_entry_dir_len(ctx);
  if (ed_len <= 0)
    return -1;
  memset(ed_buf, 0, sizeof(ed_buf));
  pipeline_dep_ctx_entry_dir_copy(ctx, ed_buf, 512);
  off = pipeline_path_append_from_buf_512_c(ctx, 0, ed_buf, ed_len);
  if (off < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, 47);
    off = off + 1;
  }
  wave105_resolve_off = off;
  return off;
}

int32_t pipeline_flat_import_build_path_c(void *ctx, int32_t lib_idx, uint8_t *import_path, int32_t path_len) {
  int32_t off_base;
  if (!ctx || !import_path || lib_idx < 0)
    return -1;
  if (pipeline_resolve_path_lib_root_prefix_off_c(ctx, lib_idx) < 0)
    return -1;
  off_base = wave105_resolve_off;
  if (pipeline_path_append_import_path_sidecar_c(ctx, off_base, import_path, path_len) < 0)
    return -1;
  off_base = wave105_resolve_off;
  if (off_base < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 47);
    wave105_resolve_off = off_base + 1;
  }
  if (pipeline_path_append_import_path_sidecar_c(ctx, wave105_resolve_off, import_path, path_len) < 0)
    return -1;
  off_base = wave105_resolve_off;
  if (off_base + 4 > 512)
    return -1;
  pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 46);
  pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 1, 115);
  pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 2, 117);
  pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 3, 0);
  return 0;
}

int32_t pipeline_flat_import_probe_open_c(void *ctx) {
  int32_t fd_dir;
  if (!ctx)
    return -1;
  fd_dir = std_fs_fs_open_read(pipeline_dep_ctx_path_buf_ptr(ctx));
  if (fd_dir >= 0) {
    std_fs_fs_close(fd_dir);
    return 0;
  }
  return -1;
}

int32_t pipeline_resolve_path_probe_export_c(void *ctx, int32_t off) {
  return wave105_probe_dot_x_and_mod(ctx, off);
}

static int32_t wave105_try_flat_import_under_lib(void *ctx, int32_t lib_idx, uint8_t *import_path, int32_t path_len) {
  uint8_t lr_buf[256];
  int32_t lr_len;
  int32_t off_base;
  if (!ctx || !import_path)
    return -1;
  lr_len = pipeline_copy_lib_root_to_buf256(ctx, lib_idx, lr_buf);
  off_base = 0;
  if (lr_len > 0)
    off_base = pipeline_path_append_from_buf_256_c(ctx, 0, lr_buf, lr_len);
  if (off_base < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 47);
    off_base = off_base + 1;
  }
  off_base = pipeline_path_append_import_path_c(ctx, off_base, import_path, path_len);
  if (off_base < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 47);
    off_base = off_base + 1;
  }
  off_base = pipeline_path_append_import_path_c(ctx, off_base, import_path, path_len);
  if (off_base + 4 <= 512) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 46);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 1, 115);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 2, 117);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 3, 0);
    if (std_fs_fs_open_read(pipeline_dep_ctx_path_buf_ptr(ctx)) >= 0)
      return 0;
  }
  return -1;
}

static int32_t wave105_try_one_lib_root(void *ctx, int32_t lib_idx, uint8_t *import_path, int32_t path_len) {
  uint8_t lr_buf[256];
  int32_t lr_len;
  int32_t off;
  if (!ctx || !import_path)
    return -1;
  lr_len = pipeline_copy_lib_root_to_buf256(ctx, lib_idx, lr_buf);
  off = 0;
  if (lr_len > 0)
    off = pipeline_path_append_from_buf_256_c(ctx, 0, lr_buf, lr_len);
  if (off < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, 47);
    off = off + 1;
  }
  off = pipeline_path_append_import_path_c(ctx, off, import_path, path_len);
  if (wave105_probe_dot_x_and_mod(ctx, off) == 0)
    return 0;
  if (path_len > 0 && path_len < 64 && pipeline_resolve_path_import_has_dot_c(import_path, path_len) == 0) {
    if (wave105_try_flat_import_under_lib(ctx, lib_idx, import_path, path_len) == 0)
      return 0;
  }
  return -1;
}

static int32_t wave105_try_entry_dir(void *ctx, uint8_t *import_path, int32_t path_len) {
  int32_t ed_len;
  uint8_t ed_buf[512];
  int32_t off;
  if (!ctx || !import_path)
    return -1;
  ed_len = pipeline_dep_ctx_entry_dir_len(ctx);
  if (ed_len <= 0 || pipeline_resolve_path_import_has_dot_c(import_path, path_len) != 0)
    return -1;
  pipeline_dep_ctx_entry_dir_copy(ctx, ed_buf, 512);
  off = pipeline_path_append_from_buf_512_c(ctx, 0, ed_buf, ed_len);
  if (off < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, 47);
    off = off + 1;
  }
  off = pipeline_path_append_import_path_c(ctx, off, import_path, path_len);
  return wave105_probe_dot_x_and_mod(ctx, off);
}

/* wave306: product surfaces pure-owned leave cold twins (pipeline.x thin residual).
 * PLATFORM: SHARED — only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X (enclosing).
 * Prefer pure owns STRONG pipeline_path_append_* / resolve_path_try_* / import_has_dot. */
int32_t pipeline_path_append_from_buf_256(void *ctx, int32_t off, uint8_t *buf, int32_t len) {
  return pipeline_path_append_from_buf_256_c(ctx, off, buf, len);
}
int32_t pipeline_path_append_from_buf_512(void *ctx, int32_t off, uint8_t *buf, int32_t len) {
  return pipeline_path_append_from_buf_512_c(ctx, off, buf, len);
}
int32_t pipeline_path_append_import_path(void *ctx, int32_t off, uint8_t *import_path, int32_t path_len) {
  return pipeline_path_append_import_path_c(ctx, off, import_path, path_len);
}
int32_t pipeline_resolve_path_import_has_dot(uint8_t *import_path, int32_t path_len) {
  return pipeline_resolve_path_import_has_dot_c(import_path, path_len);
}
int32_t pipeline_resolve_path_try_flat_import_under_lib(void *ctx, int32_t lib_idx, uint8_t *import_path,
                                                       int32_t path_len) {
  return wave105_try_flat_import_under_lib(ctx, lib_idx, import_path, path_len);
}
int32_t pipeline_resolve_path_try_one_lib_root(void *ctx, int32_t lib_idx, uint8_t *import_path,
                                              int32_t path_len) {
  return wave105_try_one_lib_root(ctx, lib_idx, import_path, path_len);
}
int32_t pipeline_resolve_path_try_entry_dir(void *ctx, uint8_t *import_path, int32_t path_len) {
  return wave105_try_entry_dir(ctx, import_path, path_len);
}

/* wave307: pipeline.x residual thin / run_x orch product faces pure leave cold twins.
 * PLATFORM: SHARED — only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X (enclosing).
 * Prefer pure owns STRONG product non-_c faces; cold thin→Cap _c. */
extern void driver_compile_phase_timing_begin(int32_t phase);
extern void driver_compile_phase_timing_end(int32_t phase);
extern void driver_compile_phase_timing_flush(void);
extern void driver_diagnostic_before_codegen(int32_t num_funcs, int32_t out_len);
extern int32_t driver_check_only_get(void);
extern int32_t driver_x_pipeline_skip_codegen_get(void);
extern int32_t pipeline_dep_ctx_asm_entry_module_only(struct ast_PipelineDepCtx *ctx);
extern int32_t run_x_pipeline_last_rc_get(void);
extern int32_t pipeline_should_skip_x_typeck_c(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_parse_apply_main_from_scalars_c(struct ast_Module *module, struct ast_ASTArena *arena);
extern int32_t pipeline_parse_set_main_from_buf_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   uint8_t *data, int32_t len);
extern int32_t pipeline_typeck_parsed_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                 struct ast_PipelineDepCtx *ctx, int32_t fail_mapped);
extern int32_t pipeline_typeck_entry_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                              struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_load_import_resolve_read_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                                   int32_t import_idx);
extern int32_t pipeline_load_one_import_slot_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                               struct ast_PipelineDepCtx *ctx, int32_t import_idx);
extern int32_t pipeline_load_and_sync_direct_import_deps_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                           struct ast_PipelineDepCtx *ctx);
extern int32_t lsp_diag_parse_entry_buf_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                          uint8_t *source_data, int32_t source_len);
extern int32_t lsp_diag_typeck_after_load_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                            struct ast_PipelineDepCtx *ctx);
extern int32_t run_x_pipeline_parse_entry_do_parse_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                     uint8_t *source_data, size_t source_len,
                                                     struct ast_PipelineDepCtx *ctx);
extern int32_t run_x_pipeline_parse_entry_if_needed_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                      uint8_t *source_data, size_t source_len,
                                                      struct ast_PipelineDepCtx *ctx);
extern int32_t run_x_pipeline_load_deps_after_parse_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                      struct ast_PipelineDepCtx *ctx);
extern int32_t run_x_pipeline_typecheck_after_load_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                     struct ast_PipelineDepCtx *ctx);
extern int32_t run_x_pipeline_typecheck_entry_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                struct ast_PipelineDepCtx *ctx);
extern int32_t run_x_pipeline_fill_dep_import_path_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                                     int32_t dep_j);
extern int32_t run_x_pipeline_codegen_one_dep_c(struct ast_Module *module, void *out_buf,
                                                struct ast_PipelineDepCtx *ctx, int32_t dep_j,
                                                int32_t skip_asm_dep_codegen);
extern int32_t run_x_pipeline_codegen_deps_c(struct ast_Module *module, struct ast_ASTArena *arena, void *out_buf,
                                             struct ast_PipelineDepCtx *ctx, int32_t skip_asm_dep_codegen);
extern int32_t pipeline_prepare_dep_codegen_path_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j, uint8_t *dst);
extern int32_t pipeline_finish_dep_codegen_diag_c(int32_t dep_j, void *out_buf);
extern int32_t run_x_pipeline_codegen_entry_c(struct ast_Module *module, struct ast_ASTArena *arena, void *out_buf,
                                              struct ast_PipelineDepCtx *ctx);
int32_t pipeline_should_skip_x_typeck(void *ctx) {
  return pipeline_should_skip_x_typeck_c((struct ast_PipelineDepCtx *)ctx);
}
size_t pipeline_loaded_buf_cap(void) {
  return (size_t)4194304;
}
int32_t pipeline_parse_apply_main_from_scalars(void *module, void *arena) {
  return pipeline_parse_apply_main_from_scalars_c((struct ast_Module *)module,
                                                  (struct ast_ASTArena *)arena);
}
int32_t pipeline_parse_set_main_from_buf(void *module, void *arena, uint8_t *data, int32_t len) {
  return pipeline_parse_set_main_from_buf_c((struct ast_Module *)module, (struct ast_ASTArena *)arena,
                                            data, len);
}
int32_t pipeline_typeck_parsed_module(void *module, void *arena, void *ctx, int32_t fail_mapped) {
  return pipeline_typeck_parsed_module_c((struct ast_Module *)module, (struct ast_ASTArena *)arena,
                                         (struct ast_PipelineDepCtx *)ctx, fail_mapped);
}
int32_t pipeline_typeck_entry_module(void *module, void *arena, void *ctx) {
  return pipeline_typeck_entry_module_c((struct ast_Module *)module, (struct ast_ASTArena *)arena,
                                        (struct ast_PipelineDepCtx *)ctx);
}
int32_t pipeline_load_import_resolve_read(void *module, void *ctx, int32_t import_idx) {
  return pipeline_load_import_resolve_read_c((struct ast_Module *)module,
                                             (struct ast_PipelineDepCtx *)ctx, import_idx);
}
/* load_import_from_disk / sync_dep_slots WEAK twins also exist at EOF #ifndef FROM_X. */
int32_t pipeline_load_one_import_slot(void *module, void *arena, void *ctx, int32_t import_idx) {
  return pipeline_load_one_import_slot_c((struct ast_Module *)module, (struct ast_ASTArena *)arena,
                                         (struct ast_PipelineDepCtx *)ctx, import_idx);
}
int32_t pipeline_load_and_sync_direct_import_deps(void *module, void *arena, void *ctx) {
  return pipeline_load_and_sync_direct_import_deps_c((struct ast_Module *)module,
                                                     (struct ast_ASTArena *)arena,
                                                     (struct ast_PipelineDepCtx *)ctx);
}
int32_t pipeline_lsp_diag_parse_entry_buf(void *module, void *arena, uint8_t *source_data,
                                          int32_t source_len) {
  return lsp_diag_parse_entry_buf_c((struct ast_Module *)module, (struct ast_ASTArena *)arena,
                                    source_data, source_len);
}
int32_t pipeline_lsp_diag_typeck_after_load(void *module, void *arena, void *ctx) {
  return lsp_diag_typeck_after_load_c((struct ast_Module *)module, (struct ast_ASTArena *)arena,
                                      (struct ast_PipelineDepCtx *)ctx);
}
int32_t pipeline_run_x_pipeline_parse_entry_do_parse(void *module, void *arena, uint8_t *source_data,
                                                     size_t source_len, void *ctx) {
  return run_x_pipeline_parse_entry_do_parse_c((struct ast_Module *)module,
                                               (struct ast_ASTArena *)arena, source_data, source_len,
                                               (struct ast_PipelineDepCtx *)ctx);
}
int32_t pipeline_run_x_pipeline_parse_entry_if_needed(void *module, void *arena, uint8_t *source_data,
                                                      size_t source_len, void *ctx) {
  return run_x_pipeline_parse_entry_if_needed_c((struct ast_Module *)module,
                                                (struct ast_ASTArena *)arena, source_data, source_len,
                                                (struct ast_PipelineDepCtx *)ctx);
}
int32_t pipeline_run_x_pipeline_load_deps_after_parse(void *module, void *arena, void *ctx) {
  return run_x_pipeline_load_deps_after_parse_c((struct ast_Module *)module,
                                                (struct ast_ASTArena *)arena,
                                                (struct ast_PipelineDepCtx *)ctx);
}
int32_t pipeline_run_x_pipeline_typecheck_after_load(void *module, void *arena, void *ctx) {
  return run_x_pipeline_typecheck_after_load_c((struct ast_Module *)module,
                                               (struct ast_ASTArena *)arena,
                                               (struct ast_PipelineDepCtx *)ctx);
}
int32_t pipeline_run_x_pipeline_typecheck_entry(void *module, void *arena, void *ctx) {
  return run_x_pipeline_typecheck_entry_c((struct ast_Module *)module, (struct ast_ASTArena *)arena,
                                          (struct ast_PipelineDepCtx *)ctx);
}
int32_t pipeline_run_x_pipeline_fill_dep_import_path(void *module, void *ctx, int32_t dep_j) {
  return run_x_pipeline_fill_dep_import_path_c((struct ast_Module *)module,
                                               (struct ast_PipelineDepCtx *)ctx, dep_j);
}
int32_t pipeline_run_x_pipeline_codegen_one_dep(void *module, void *out_buf, void *ctx, int32_t dep_j,
                                                int32_t skip_asm_dep_codegen) {
  return run_x_pipeline_codegen_one_dep_c((struct ast_Module *)module, out_buf,
                                          (struct ast_PipelineDepCtx *)ctx, dep_j,
                                          skip_asm_dep_codegen);
}
int32_t pipeline_run_x_pipeline_codegen_deps(void *module, void *arena, void *out_buf, void *ctx,
                                             int32_t skip_asm_dep_codegen) {
  return run_x_pipeline_codegen_deps_c((struct ast_Module *)module, (struct ast_ASTArena *)arena,
                                       out_buf, (struct ast_PipelineDepCtx *)ctx,
                                       skip_asm_dep_codegen);
}
int32_t pipeline_prepare_dep_codegen_path(void *ctx, int32_t dep_j, uint8_t *dst) {
  return pipeline_prepare_dep_codegen_path_c((struct ast_PipelineDepCtx *)ctx, dep_j, dst);
}
int32_t pipeline_finish_dep_codegen_diag(int32_t dep_j, void *out_buf) {
  return pipeline_finish_dep_codegen_diag_c(dep_j, out_buf);
}
int32_t pipeline_run_x_pipeline_codegen_entry(void *module, void *arena, void *out_buf, void *ctx) {
  return run_x_pipeline_codegen_entry_c((struct ast_Module *)module, (struct ast_ASTArena *)arena,
                                        out_buf, (struct ast_PipelineDepCtx *)ctx);
}
