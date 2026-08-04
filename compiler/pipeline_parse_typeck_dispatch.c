/* pipeline_parse_typeck_dispatch.c — parse entry + typeck dispatch + import load 域（自 ast_pool.c 抽出）
 *
 * g_pipeline_parse_scalars + accessors：EMIT_HEAVY X 读 parse scalars 出参（sidecar）。
 * pipeline_should_skip_x_typeck_c／parse_fail_diag_scalars_c：typeck skip 判定 + parse 失败 diag。
 * pipeline_parse_into_with_init_*_scalars／parse_apply_main_from_scalars／parse_set_main_from_buf：
 *   entry parse scalars 路径 + set_main。
 * pipeline_typeck_parsed_module_c／typeck_entry_module_c：typeck 分派（library／entry）。
 * pipeline_dep_ctx_realign_ndep_for_entry／load_import_resolve_read／load_one_import_slot／
 *   load_and_sync_direct_import_deps_c：import 加载与同步（XLANG_WEAK cold twin）。
 * 共享 extern（driver_diagnostic_*／parse_into_with_init_buf／typeck_x_ast／WPO-S3 escape）本块头部声明。
 * 同 TU #include（import_bind 之后）；公共符号 + XLANG_WEAK + static scalars；无先于此 include 的调用方。 */

extern void driver_diagnostic_entry_already(int32_t v);
extern void driver_diagnostic_source_len(int32_t len);
extern void driver_diagnostic_parse_fail(int32_t main_idx, int32_t num_funcs, int32_t arena_num_types);
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern void driver_diagnostic_entry_module(struct ast_Module *module, struct ast_ASTArena *arena);
extern void driver_diagnostic_typeck_fail(void);
extern int32_t pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx);
extern void parser_parse_into_set_main_index(struct ast_Module *module, int32_t main_idx);
extern struct parser_ParseIntoResult pipeline_parse_into_with_init_buf(struct ast_ASTArena *arena,
                                                                         struct ast_Module *module, uint8_t *data,
                                                                         int32_t len);
extern int32_t pipeline_should_skip_x_typeck(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_driver_asm_build_skip_typeck(void);
extern int32_t pipeline_driver_x_pipeline_skip_typeck(void);
extern int32_t driver_x_pipeline_skip_typeck_get(void);
extern struct parser_ParseIntoResult pipeline_parse_into_with_init_buf_impl_c(struct ast_ASTArena *arena,
                                                                               struct ast_Module *module,
                                                                               uint8_t *data, int32_t len);
extern int32_t typeck_typeck_x_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                    struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_typeck_x_ast_library(struct ast_Module *module, struct ast_ASTArena *arena,
                                            struct ast_PipelineDepCtx *ctx);
/** WPO-S3：post-typeck struct 栈指针逃逸扫描（pipeline_glue.c）。 */
extern int32_t pipeline_typeck_scan_module_struct_stack_escape_c(struct ast_Module *module,
                                                                 struct ast_ASTArena *arena,
                                                                 struct ast_PipelineDepCtx *ctx);
extern void pipeline_typeck_set_active_ctx_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx);

/** EMIT_HEAVY X 读 parse scalars 出参（sidecar；避免 X &local 导致 asm parse 0 func）。 */
static int32_t g_pipeline_parse_scalars_ok;
static int32_t g_pipeline_parse_scalars_main_idx;

int32_t pipeline_parse_scalars_ok_get(void) {
  return g_pipeline_parse_scalars_ok;
}

int32_t pipeline_parse_scalars_main_idx_get(void) {
  return g_pipeline_parse_scalars_main_idx;
}

/**
 * 单模块 asm -o 是否跳过 .x typeck：须 C glue（X emit 读 skip 标志/ctx 字段易错序）。
/**
 * 与 pipeline.x pipeline_should_skip_x_typeck 语义一致。
 * runtime 在 C 预检后设 driver_x_pipeline_skip_typeck 时须对用户 -o 程序生效（B-strict xlang_asm hello 等）。
 */
int32_t pipeline_should_skip_x_typeck_c(struct ast_PipelineDepCtx *ctx) {
  if (!ctx)
    return 0;
  if (pipeline_driver_x_pipeline_skip_typeck() != 0)
    return 1;
  if (pipeline_dep_ctx_asm_entry_module_only(ctx) == 0)
    return 0;
  if (pipeline_driver_asm_build_skip_typeck() != 0)
    return 1;
  return 0;
}

/**
 * parse 失败时 stderr 诊断（EMIT_HEAVY 勿 X 真 emit driver_diagnostic_parse_fail 多实参）。
 */
void pipeline_parse_fail_diag_scalars_c(struct ast_Module *module, struct ast_ASTArena *arena) {
  if (!module || !arena)
    return;
  driver_diagnostic_parse_fail(g_pipeline_parse_scalars_main_idx, pipeline_module_num_funcs(module),
                               pipeline_arena_num_types(arena));
}

/**
 * 从 parse scalars sidecar 构造 ParseIntoResult（EMIT_HEAVY 勿 X 按值拼装后 return）。
 */
struct parser_ParseIntoResult pipeline_parse_into_with_init_result_c(void) {
  struct parser_ParseIntoResult r;

  r.ok = g_pipeline_parse_scalars_ok;
  r.main_idx = g_pipeline_parse_scalars_main_idx;
  return r;
}

/**
 * parse_into_with_init_buf 的 ok/main_idx 出参版；避免 X 局部 ParseIntoResult 按值（EMIT_HEAVY SIGSEGV）。
 * out_ok/out_main_idx 非 NULL 时写入；并始终更新 sidecar 供 pipeline_parse_scalars_*_get。
 */
int32_t pipeline_parse_into_with_init_buf_scalars(struct ast_ASTArena *arena, struct ast_Module *module,
                                                   uint8_t *data, int32_t len, int32_t *out_ok,
                                                   int32_t *out_main_idx) {
  struct parser_ParseIntoResult r;

  if (!arena || !module || !data || len <= 0) {
    g_pipeline_parse_scalars_ok = 1;
    g_pipeline_parse_scalars_main_idx = -1;
    if (out_ok)
      *out_ok = g_pipeline_parse_scalars_ok;
    if (out_main_idx)
      *out_main_idx = g_pipeline_parse_scalars_main_idx;
    return 0;
  }
  r = pipeline_parse_into_with_init_buf_impl_c(arena, module, data, len);
  g_pipeline_parse_scalars_ok = r.ok;
  g_pipeline_parse_scalars_main_idx = r.main_idx;
  if (out_ok)
    *out_ok = r.ok;
  if (out_main_idx)
    *out_main_idx = r.main_idx;
  return 0;
}

/** X 薄包装：sidecar 版 scalars（无 *i32 出参，避免 asm 前端 parse 0 func）。 */
int32_t pipeline_parse_into_with_init_buf_scalars_sidecar(struct ast_ASTArena *arena, struct ast_Module *module,
                                                          uint8_t *data, int32_t len) {
  return pipeline_parse_into_with_init_buf_scalars(arena, module, data, len, NULL, NULL);
}

/**
 * u8[] slice 路径 sidecar：读 data/length 后复用 buf scalars（勿 X ParseIntoResult 按值 EMIT_HEAVY SIGSEGV）。
 * X 传 u8[] 时 ABI 为 xlang_slice_uint8_t*。
 */
int32_t pipeline_parse_into_with_init_slice_scalars_sidecar(struct ast_ASTArena *arena, struct ast_Module *module,
                                                             struct xlang_slice_uint8_t *source) {
  if (!source || !source->data || source->length == 0)
    return pipeline_parse_into_with_init_buf_scalars(arena, module, NULL, 0, NULL, NULL);
  if (source->length > (size_t)2147483647)
    return pipeline_parse_into_with_init_buf_scalars(arena, module, source->data, 2147483647, NULL, NULL);
  return pipeline_parse_into_with_init_buf_scalars(arena, module, source->data, (int32_t)source->length, NULL, NULL);
}

/**
 * 读 sidecar ok/main_idx 写 module.main；parse 失败时 C glue 诊断并返回 -2。
 */
int32_t pipeline_parse_apply_main_from_scalars_c(struct ast_Module *module, struct ast_ASTArena *arena) {
  int32_t ok;
  int32_t main_idx;

  if (!module || !arena)
    return -2;
  ok = pipeline_parse_scalars_ok_get();
  main_idx = pipeline_parse_scalars_main_idx_get();
  if (ok != 0) {
    pipeline_parse_fail_diag_scalars_c(module, arena);
    return -2;
  }
  pipeline_module_set_main_func_index(module, main_idx);
  return 0;
}

/**
 * buf 路径 parse + set_main；C glue 回退（strict 无 pipeline.o 时；有 X 强符号则覆盖）。
 * EMIT_HEAVY 第二遍 pipeline.x 内 pipeline_parse_set_main_from_buf X 真 emit。
 */
int32_t pipeline_parse_set_main_from_buf_c(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *data,
                                           int32_t len) {
  int32_t ok;
  int32_t main_idx;

  if (!module || !arena || !data || len <= 0)
    return -2;
  /* L7 / LSP：锚定 unused private 波浪线到定义处 */
  pipeline_lint_set_source_buf(data, len);
  pipeline_parse_into_with_init_buf_scalars(arena, module, data, len, &ok, &main_idx);
  if (link_abi_getenv("XLANG_DEBUG_PIPE"))
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] parse_set_main_from_buf_c ok=%d main_idx=%d num_funcs=%d\n", (int)ok,
            (int)main_idx, (int)pipeline_module_num_funcs(module));
  if (ok != 0) {
    driver_diagnostic_parse_fail(main_idx, pipeline_module_num_funcs(module), pipeline_arena_num_types(arena));
    return -2;
  }
  pipeline_module_set_main_func_index(module, main_idx);
  if (link_abi_getenv("XLANG_DEBUG_PIPE"))
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] parse_set_main_from_buf_c stored_main_idx=%d\n",
            (int)pipeline_module_main_func_index(module));
  return 0;
}

/**
 * 已对 module 设好 main_idx：按 library / 可执行分派 typeck_x_ast*（与 pipeline.x 语义一致）。
 * fail_mapped 非 0 时 typeck 失败返回该码（LSP 用 -3）。
 */
int32_t pipeline_typeck_parsed_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                      struct ast_PipelineDepCtx *ctx, int32_t fail_mapped) {
  if (!module || !arena || !ctx) {
    if (fail_mapped != 0)
      return fail_mapped;
    return -1;
  }
  /** parse 未产出任何函数时 main_func_index 可能仍为 0（memset）；强制走 library typeck 避免 typeck_x_ast -11。 */
  if (pipeline_module_num_funcs(module) == 0)
    pipeline_module_set_main_func_index(module, -1);
  if (link_abi_getenv("XLANG_DEBUG_PIPE"))
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] typeck_parsed_module_c main_idx=%d num_funcs=%d\n",
            (int)pipeline_module_main_func_index(module), (int)pipeline_module_num_funcs(module));
  /* 【Why 根源】产品入口 typeck_parsed_module_c 原先未 set active module，
   * pipeline_typeck_resolve_type_alias_ref_c 读 g_typeck_active_module=NULL 无法展开
   * type P=Point / type Coord=i32，type_alias.x 假红。after_parse_ok 路径已 set。 */
  pipeline_typeck_set_active_ctx_c(module, ctx);
  pipeline_typeck_set_dep_ctx(ctx);
  if (pipeline_module_main_func_index(module) < 0) {
    int32_t tc_lib = typeck_typeck_x_ast_library(module, arena, ctx);
    if (tc_lib != 0) {
      if (link_abi_getenv("XLANG_DEBUG_PIPE"))
        fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] typeck library rc=%d ctx=%p ndep=%d\n", (int)tc_lib, (void *)ctx,
                (int)pipeline_dep_ctx_ndep(ctx));
      driver_diagnostic_typeck_fail();
      if (fail_mapped != 0)
        return fail_mapped;
      return tc_lib;
    }
    if (pipeline_typeck_scan_module_struct_stack_escape_c(module, arena, ctx) != 0) {
      driver_diagnostic_typeck_fail();
      if (fail_mapped != 0)
        return fail_mapped;
      return -1;
    }
    (void)pipeline_typeck_unused_private_funcs(module, arena);
    return 0;
  }
  {
    pipeline_typeck_set_dep_ctx(ctx);
    int32_t tc = typeck_typeck_x_ast(module, arena, ctx);
    if (tc != 0) {
      driver_diagnostic_typeck_fail();
      if (fail_mapped != 0)
        return fail_mapped;
      return tc;
    }
    if (pipeline_typeck_scan_module_struct_stack_escape_c(module, arena, ctx) != 0) {
      driver_diagnostic_typeck_fail();
      if (fail_mapped != 0)
        return fail_mapped;
      return -1;
    }
  }
  (void)pipeline_typeck_unused_private_funcs(module, arena);
  return 0;
}

/** 主流水线 entry typeck：library→parsed_module；可执行→typeck_x_ast（EMIT_HEAVY X emit）。 */
int32_t pipeline_typeck_entry_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                       struct ast_PipelineDepCtx *ctx) {
  if (!module || !arena || !ctx)
    return -1;
  return pipeline_typeck_parsed_module_c(module, arena, ctx, 0);
}

extern int32_t pipeline_load_import_from_disk_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                struct ast_PipelineDepCtx *ctx, int32_t import_idx);
extern int32_t pipeline_load_import_from_disk_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                      struct ast_PipelineDepCtx *ctx, int32_t import_idx);
extern int32_t pipeline_sync_dep_slots_from_driver_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_sync_dep_slots_from_driver_impl_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx);
extern void typeck_typeck_merge_dep_struct_layouts_into_entry(struct ast_Module *mod, struct ast_ASTArena *arena,
                                                              struct ast_PipelineDepCtx *ctx);
extern void typeck_typeck_wpo_unify_soa_layouts(struct ast_Module *entry, struct ast_PipelineDepCtx *ctx);

/**
 * Align ctx.ndep with entry direct imports after BFS/runtime seed.
 *
 * Invariants (must match load_and_sync keep-closure branch):
 * - ndep == n_entry_imports: entry-indexed layout already; leave alone.
 * - ndep > n_entry_imports: BFS/closure seed is authoritative (std.fmt → std.io → …).
 *   Do NOT zero — zeroing reloads only entry imports and drops transitive co-emit
 *   (pure static hello -o: std_io_print_u8_ptr_usize UNDEF; product mac often
 *   "kept" only because set_ndep layout drift left ndep non-zero).
 * - ndep < n_entry_imports: incomplete; zero so load_and_sync reloads from entry.
 *
 * Historical bug: zero whenever ndep != n_imp destroyed healthy closures.
 * PLATFORM: SHARED — Cap force hello pure static -o + run-net closure.
 * wave93: product pure owns pipeline_dep_ctx_realign_ndep_for_entry_c
 * (runtime_pipeline_abi.x). Keep XLANG_WEAK cold twin for non-PREFER links.
 */
XLANG_WEAK void pipeline_dep_ctx_realign_ndep_for_entry_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx) {
  int32_t n_imp;
  int32_t ndep;

  if (!module || !ctx)
    return;
  n_imp = parser_get_module_num_imports(module);
  ndep = pipeline_dep_ctx_ndep(ctx);
  if (ndep == n_imp)
    return;
  if (ndep > n_imp) {
    /* Closure seed: keep full BFS list; load_and_sync skips entry-index re-pin. */
    if (link_abi_getenv("XLANG_DEBUG_PIPE"))
      fprintf(stderr,
              "xlang: [XLANG_DEBUG_PIPE] realign keep closure ndep=%d (entry imports=%d)\n",
              (int)ndep, (int)n_imp);
    return;
  }
  /* ndep < n_imp: incomplete — force reload via load_and_sync. */
  if (link_abi_getenv("XLANG_DEBUG_PIPE"))
    fprintf(stderr,
            "xlang: [XLANG_DEBUG_PIPE] realign ndep %d -> entry imports %d (incomplete, zero)\n",
            (int)ndep, (int)n_imp);
  pipeline_dep_ctx_set_ndep(ctx, 0);
}

/**
 * 单 import resolve + read；C glue（X 侧 u8[64] 栈 + assign CALL EMIT_HEAVY 失败）。
 */
int32_t pipeline_load_import_resolve_read_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                            int32_t import_idx) {
  uint8_t path_buf[128];
  int32_t path_len;

  if (!module || !ctx || import_idx < 0)
    return -1;
  memset(path_buf, 0, sizeof(path_buf));
  path_len = parser_copy_module_import_path64(module, import_idx, path_buf);
  if (pipeline_resolve_path_x(ctx, path_buf, path_len) != 0)
    return -7;
  if (pipeline_read_file_x(ctx) != 0)
    return -8;
  return 0;
}

/**
 * 装载单个 import 槽：已 seed 则 bind，否则 load_import_from_disk；C glue。
 */
int32_t pipeline_load_one_import_slot_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                        struct ast_PipelineDepCtx *ctx, int32_t import_idx) {
  uint8_t path_buf[128];
  int32_t gs;

  if (!module || !arena || !ctx || import_idx < 0)
    return -1;
  memset(path_buf, 0, sizeof(path_buf));
  (void)parser_copy_module_import_path64(module, import_idx, path_buf);
  gs = driver_dep_slot_for_path(path_buf);
  if (pipeline_try_bind_seeded_import(ctx, import_idx, gs) != 0)
    return 0;
  return pipeline_load_import_from_disk_impl_c(module, arena, ctx, import_idx);
}

/**
 * run_x_pipeline_impl EMIT_HEAVY：同模块 pipeline_load_and_sync X CALL 在 let/assign asm emit 失败；
 * C 复刻 pipeline.x::pipeline_load_and_sync_direct_import_deps 逻辑。
 * wave93: product pure owns pipeline_load_and_sync_direct_import_deps_c
 * (runtime_pipeline_abi.x orch → pure try_bind/realign + disk/sync; wave97 merge→typeck.x).
 * Keep XLANG_WEAK cold twin for links without pure pipeline_abi / PREFER hybrid.
 * PLATFORM: SHARED — ELF weak overridden by pure; cold keeps full C body
 * (cold still calls typeck_typeck_* link-alias hop; pure routes typeck.x short names).
 */
XLANG_WEAK int32_t pipeline_load_and_sync_direct_import_deps_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    struct ast_PipelineDepCtx *ctx) {
  int32_t n_imports;
  int32_t i;
  int32_t rc;
  int32_t sync_rc;
  uint8_t path_buf[128];

  if (!module || !arena || !ctx)
    return -1;
  n_imports = parser_get_module_num_imports(module);
  /*
   * driver 传递闭包 seed：按 entry import 路径 bind 全局槽后直接返回。
   * 须在 realign 之前：realign 会把 ndep(9) 清零，导致 typeck 找不到 encoding.utf8_*（ec=-5）。
   */
  /*
   * PLATFORM: SHARED — process every entry import: seed-bind or disk-load, always
   * pin path. Old early-return on bound_any skipped unseeded imports and left stale
   * paths (parser M1: slot holding ast layouts labeled path=lexer).
   */
  pipeline_dep_ctx_realign_ndep_for_entry_c(module, ctx);
  if (pipeline_dep_ctx_ndep(ctx) == 0 && n_imports > 0) {
    for (i = 0; i < n_imports; i++) {
      int32_t pl = 0;
      memset(path_buf, 0, sizeof(path_buf));
      (void)parser_copy_module_import_path64(module, i, path_buf);
      while (pl < 64 && path_buf[pl] != 0)
        pl = pl + 1;
      if (pl > 0)
        pipeline_dep_ctx_set_import_path(ctx, i, path_buf, pl);
      if (pipeline_try_bind_seeded_import(ctx, i, driver_dep_slot_for_path(path_buf)) != 0)
        continue;
      rc = pipeline_load_import_from_disk_c(module, arena, ctx, i);
      if (rc != 0)
        return rc;
    }
    pipeline_dep_ctx_set_ndep(ctx, n_imports);
  } else if (n_imports > 0) {
    int32_t cur_ndep = pipeline_dep_ctx_ndep(ctx);
    /*
     * 【Why 根源】driver 传递闭包 seed 时 ndep 为 BFS 全量（含 std.io.core 等传递 dep），
     *   槽序 ≠ entry 直接 import 序。若仍按 entry import 下标 0..n_imports-1 覆写
     *   path/module，会把 slot0=driver→net、slot1=core→driver，丢掉 core。
     *   结果：driver 共发射体调 xlang_io_submit_*_batch，core 无 co-emit → 双端
     *   run-net udp_batch_buf BLD001（implicit declaration）。
     * 【Invariant】ndep > n_imports：闭包权威，禁止 entry-index re-pin。
     *   ndep == n_imports：entry-indexed 布局，可 re-pin。
     * PLATFORM: SHARED — Cap force run-net + run-io-driver 双端。
     */
    if (cur_ndep > n_imports) {
      /*
       * Keep BFS slot order (no entry-index re-pin). Rebind module/arena from
       * driver_dep publish slots by BFS index — same order as collect/pre-parse.
       * PLATFORM: SHARED — pure static pctx_seed may use a divergent set_module
       * (layout drift) so module_at returns NULL even after seed; bind via this
       * TU's pipeline_dep_ctx_set_module (paired with module_at, G.7).
       */
      if (link_abi_getenv("XLANG_DEBUG_PIPE"))
        fprintf(stderr,
                "xlang: [XLANG_DEBUG_PIPE] keep closure seed ndep=%d (entry imports=%d); rebind from driver slots\n",
                (int)cur_ndep, (int)n_imports);
      for (i = 0; i < cur_ndep; i++) {
        const char *reg_path = NULL;
        int32_t pl = 0;
        if (driver_dep_seeded_get(i) == 0)
          continue;
        pipeline_dep_ctx_set_module(ctx, i, (struct ast_Module *)driver_dep_module_buf(i));
        pipeline_dep_ctx_set_arena(ctx, i, (struct ast_ASTArena *)driver_dep_arena_buf(i));
        reg_path = driver_dep_path_registry_at(i);
        if (reg_path && reg_path[0]) {
          while (pl < 63 && reg_path[pl] != 0)
            pl = pl + 1;
          if (pl > 0)
            pipeline_dep_ctx_set_import_path(ctx, i, (uint8_t *)reg_path, pl);
        }
      }
    } else {
      /* ndep already set (entry-indexed or equal): re-pin paths from entry imports. */
      for (i = 0; i < n_imports; i++) {
        int32_t pl = 0;
        memset(path_buf, 0, sizeof(path_buf));
        (void)parser_copy_module_import_path64(module, i, path_buf);
        while (pl < 64 && path_buf[pl] != 0)
          pl = pl + 1;
        if (pl > 0)
          pipeline_dep_ctx_set_import_path(ctx, i, path_buf, pl);
        if (pipeline_try_bind_seeded_import(ctx, i, driver_dep_slot_for_path(path_buf)) != 0)
          continue;
        /* Unseeded under pre-set ndep: load into this slot. */
        if (pipeline_dep_ctx_module_at(ctx, i) == NULL) {
          rc = pipeline_load_import_from_disk_c(module, arena, ctx, i);
          if (rc != 0)
            return rc;
        }
      }
      if (pipeline_dep_ctx_ndep(ctx) < n_imports)
        pipeline_dep_ctx_set_ndep(ctx, n_imports);
    }
  }
  sync_rc = pipeline_sync_dep_slots_from_driver_c(module, ctx);
  if (sync_rc != 0)
    return sync_rc;
  /*
   * driver 已 seed 的 std/core dep：merge 在 parse-only 槽上 SIGSEGV；layout 由预编 .o / import fixup 承担。
   */
  {
    int32_t all_seeded = (n_imports > 0) ? 1 : 0;
    for (i = 0; i < n_imports; i++) {
      int32_t gs;
      memset(path_buf, 0, sizeof(path_buf));
      (void)parser_copy_module_import_path64(module, i, path_buf);
      gs = driver_dep_slot_for_path(path_buf);
      if ((gs < 0 || driver_dep_seeded_get(gs) == 0) && driver_dep_seeded_get(i) == 0) {
        all_seeded = 0;
        break;
      }
    }
    if (!all_seeded) {
      typeck_typeck_merge_dep_struct_layouts_into_entry(module, arena, ctx);
      typeck_typeck_wpo_unify_soa_layouts(module, ctx);
    }
  }
  return 0;
}
