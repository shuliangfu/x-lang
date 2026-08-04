/* pipeline_resolve_path.c — import 路径解析 / fs 读 glue 域（自 ast_pool.c 抽出）
 *
 * pipeline_path_append_*／resolve_path_*／flat_import_*：import 路径拼接、探测、resolve
 *   dispatch（X 真 emit 或 weak impl_c 回退）。
 * codegen_out_buf_len/set_len + PIPELINE_CODEGEN_OUTBUF_CAP：CodegenOutBuf.len 读写
 *   （避免 *CodegenOutBuf 字段 FIELD_ACCESS；为 codegen 域共用，物理随此块抽出）。
 * std_fs_*／xlang_read_file_into_path：fs 原语 extern 声明。
 * 依赖：pipeline_dep_ctx_* 访问器（dep_ctx.c，先于此 include）；pipeline_resolve_path_x /
 *   pipeline_copy_lib_root_to_buf256 经 extern/前向声明（定义在 glue，TU 内在此之后）。
 */

/**
 * M8-tail：path_append_from_buf_256 的 C 实现；SKIP/EMIT_HEAVY 薄包装 bl 目标。
 * 将 buf[0..len-1] 写入 ctx.path_buf[off..]，off 上限 508。
 */
int32_t pipeline_path_append_from_buf_256_c(struct ast_PipelineDepCtx *ctx, int32_t off, uint8_t *buf,
                                             int32_t len) {
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

/** M8-tail：path_append_from_buf_512 的 C 实现（与 256 版相同逻辑，buf 由调用方保证容量）。 */
int32_t pipeline_path_append_from_buf_512_c(struct ast_PipelineDepCtx *ctx, int32_t off, uint8_t *buf,
                                             int32_t len) {
  return pipeline_path_append_from_buf_256_c(ctx, off, buf, len);
}

/**
 * M8-tail：path_append_import_path 的 C 实现；'.' (46) 替换为 '/' (47) 后写入 path_buf。
 */
int32_t pipeline_path_append_import_path_c(struct ast_PipelineDepCtx *ctx, int32_t off, uint8_t *import_path,
                                            int32_t path_len) {
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

/** M8-tail：resolve_path_import_has_dot 的 C 实现；import 路径含 '.' 返回 1，否则 0。 */
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

/** CodegenOutBuf.len 读写（pipeline.x 避免 *CodegenOutBuf 字段 FIELD_ACCESS；layout 与 codegen.x 一致）。 */
struct codegen_CodegenOutBuf;

/** 与 codegen.x CodegenOutBuf.data 维度一致；len 紧跟 data 之后。 */
#define PIPELINE_CODEGEN_OUTBUF_CAP 9437184

int32_t codegen_out_buf_len(struct codegen_CodegenOutBuf *out) {
  if (!out)
    return 0;
  return *(int32_t *)((uint8_t *)out + (ptrdiff_t)PIPELINE_CODEGEN_OUTBUF_CAP);
}

void codegen_out_buf_set_len(struct codegen_CodegenOutBuf *out, int32_t n) {
  if (out)
    *(int32_t *)((uint8_t *)out + (ptrdiff_t)PIPELINE_CODEGEN_OUTBUF_CAP) = n > 0 ? n : 0;
}



/** std.fs 原语（pipeline resolve 探测仍用 open；read 走 B-20 xlang_read_file_into_path）。 */
extern int32_t std_fs_fs_open_read(uint8_t *path);
extern int32_t std_fs_fs_close(int32_t fd);
extern ptrdiff_t std_fs_fs_read(int32_t fd, uint8_t *buf, size_t count);
/** B-20：POSIX 读文件到缓冲（runtime.c）；pipeline_read_file_x_impl_c 回退。 */
extern int xlang_read_file_into_path(const char *path, void *buf, size_t cap);
/** pipeline_glue.c 在 #include ast_pool.c 之后定义；此处前向声明供 resolve C glue 调用。 */
int32_t pipeline_copy_lib_root_to_buf256(struct ast_PipelineDepCtx *ctx, int32_t lib_idx, uint8_t *dst);

/**
 * 在 ctx.path_buf 前缀后于 off 处尝试 `.x` 与 `/mod.x` 并 fs_open_read 探测。
 * 成功返回 0，失败返回 -1。
 */
static int32_t pipeline_resolve_path_probe_dot_x_and_mod_c(struct ast_PipelineDepCtx *ctx, int32_t off) {
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

/** EMIT_HEAVY X resolve 编排：path_buf off sidecar（避免 let off=CALL assign tear patch）。 */
static int32_t g_pipeline_resolve_path_off_sidecar;

/**
 * 读取 resolve path 编排 sidecar off（C glue 写入，X if(probe(ctx, get())) 用）。
 */
int32_t pipeline_resolve_path_last_off_get_c(void) {
  return g_pipeline_resolve_path_off_sidecar;
}

/**
 * lib_root[lib_idx] 写入 ctx.path_buf 并追加 '/'；更新 sidecar；失败返回 -1。
 */
int32_t pipeline_resolve_path_lib_root_prefix_off_c(struct ast_PipelineDepCtx *ctx, int32_t lib_idx) {
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
  g_pipeline_resolve_path_off_sidecar = off;
  return off;
}

/**
 * 在 off 处追加 import_path 到 ctx.path_buf；更新 sidecar 并返回新 off，失败 -1。
 */
int32_t pipeline_path_append_import_path_sidecar_c(struct ast_PipelineDepCtx *ctx, int32_t off, uint8_t *import_path,
                                                    int32_t path_len) {
  int32_t new_off;

  if (!ctx || !import_path || off < 0)
    return -1;
  new_off = pipeline_path_append_import_path_c(ctx, off, import_path, path_len);
  if (new_off < 0)
    return -1;
  g_pipeline_resolve_path_off_sidecar = new_off;
  return new_off;
}

/**
 * entry_dir 写入 ctx.path_buf 前缀并追加 '/'；更新 sidecar；无效返回 -1。
 */
int32_t pipeline_resolve_path_entry_dir_prefix_off_c(struct ast_PipelineDepCtx *ctx) {
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
  g_pipeline_resolve_path_off_sidecar = off;
  return off;
}

/**
 * 扁平单段 import 路径 lib_root/name/name.x 写入 ctx.path_buf；0 成功 -1 失败。
 */
int32_t pipeline_flat_import_build_path_c(struct ast_PipelineDepCtx *ctx, int32_t lib_idx, uint8_t *import_path,
                                          int32_t path_len) {
  int32_t off_base;

  if (!ctx || !import_path || lib_idx < 0)
    return -1;
  if (pipeline_resolve_path_lib_root_prefix_off_c(ctx, lib_idx) < 0)
    return -1;
  off_base = g_pipeline_resolve_path_off_sidecar;
  if (pipeline_path_append_import_path_sidecar_c(ctx, off_base, import_path, path_len) < 0)
    return -1;
  off_base = g_pipeline_resolve_path_off_sidecar;
  if (off_base < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 47);
    g_pipeline_resolve_path_off_sidecar = off_base + 1;
  }
  if (pipeline_path_append_import_path_sidecar_c(ctx, g_pipeline_resolve_path_off_sidecar, import_path, path_len) < 0)
    return -1;
  off_base = g_pipeline_resolve_path_off_sidecar;
  if (off_base + 4 > 512)
    return -1;
  pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 46);
  pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 1, 115);
  pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 2, 117);
  pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 3, 0);
  return 0;
}

/**
 * 对 ctx.path_buf 当前路径做 fs_open_read 探测；可读返回 0，否则 -1。
 */
int32_t pipeline_flat_import_probe_open_c(struct ast_PipelineDepCtx *ctx) {
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

/** X extern：resolve_path_probe_dot_x_and_mod 薄包装 bl 目标。 */
int32_t pipeline_resolve_path_probe_export_c(struct ast_PipelineDepCtx *ctx, int32_t off) {
  return pipeline_resolve_path_probe_dot_x_and_mod_c(ctx, off);
}

/** 单段 import 在 lib_root 下再试 lib_root/name/name.x。 */
static int32_t pipeline_resolve_path_try_flat_import_under_lib_c(struct ast_PipelineDepCtx *ctx, int32_t lib_idx,
                                                                  uint8_t *import_path, int32_t path_len) {
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

/** 在单个 lib_root 下拼接 import 并探测 .x / mod.x / 扁平单段路径。 */
static int32_t pipeline_resolve_path_try_one_lib_root_c(struct ast_PipelineDepCtx *ctx, int32_t lib_idx,
                                                         uint8_t *import_path, int32_t path_len) {
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
  if (pipeline_resolve_path_probe_dot_x_and_mod_c(ctx, off) == 0)
    return 0;
  if (path_len > 0 && path_len < 64 && pipeline_resolve_path_import_has_dot_c(import_path, path_len) == 0) {
    if (pipeline_resolve_path_try_flat_import_under_lib_c(ctx, lib_idx, import_path, path_len) == 0)
      return 0;
  }
  return -1;
}

/** 在 entry_dir 下拼接单段 import 并探测 .x / mod.x。 */
static int32_t pipeline_resolve_path_try_entry_dir_c(struct ast_PipelineDepCtx *ctx, uint8_t *import_path,
                                                    int32_t path_len) {
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
  return pipeline_resolve_path_probe_dot_x_and_mod_c(ctx, off);
}

/** X 真 emit 或 weak 默认；_c 经此 dispatch（build_asm pipeline.o 强符号覆盖 weak）。 */
extern int32_t pipeline_resolve_path_x(struct ast_PipelineDepCtx *ctx, uint8_t *import_path, int32_t path_len);
extern int32_t pipeline_read_file_x(struct ast_PipelineDepCtx *ctx);

/**
 * M8-tail strict 回退：`resolve_path_x` 按 lib_roots 与 entry_dir 解析 import 到 ctx.path_buf。
 * wave95: product pure owns pipeline_resolve_path_x; this impl remains cold twin target.
 * PLATFORM: SHARED.
 */
int32_t pipeline_resolve_path_x_impl_c(struct ast_PipelineDepCtx *ctx, uint8_t *import_path, int32_t path_len) {
  int32_t r;
  int32_t n_lib;

  if (!ctx || !import_path || path_len <= 0)
    return -1;
  n_lib = pipeline_ctx_lib_root_count(ctx);
  r = 0;
  while (r < n_lib) {
    if (pipeline_resolve_path_try_one_lib_root_c(ctx, r, import_path, path_len) == 0)
      return 0;
    r = r + 1;
  }
  if (pipeline_resolve_path_try_entry_dir_c(ctx, import_path, path_len) == 0)
    return 0;
  return -1;
}

/** M8-tail：优先 dispatch 至 pipeline_resolve_path_x（X 或 weak impl_c）。 */
int32_t pipeline_resolve_path_x_c(struct ast_PipelineDepCtx *ctx, uint8_t *import_path, int32_t path_len) {
  return pipeline_resolve_path_x(ctx, import_path, path_len);
}
