/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */

int32_t pipeline_resolve_path_x_impl_c(void *ctx, uint8_t *import_path, int32_t path_len) {
  int32_t r;
  int32_t n_lib;
  if (!ctx || !import_path || path_len <= 0)
    return -1;
  n_lib = pipeline_ctx_lib_root_count(ctx);
  r = 0;
  while (r < n_lib) {
    if (wave105_try_one_lib_root(ctx, r, import_path, path_len) == 0)
      return 0;
    r = r + 1;
  }
  if (wave105_try_entry_dir(ctx, import_path, path_len) == 0)
    return 0;
  return -1;
}

int32_t pipeline_resolve_path_x_c(void *ctx, uint8_t *import_path, int32_t path_len) {
  return pipeline_resolve_path_x(ctx, import_path, path_len);
}

/* wave106 run_x_pipeline leave cold twins — former pipeline_run_x_pipeline.c.
 * PLATFORM: SHARED — only when pure FROM_X object is not linked. Product pure
 * owns strong last_rc / typeck_fail / load_deps / typecheck_after_load /
 * parse_entry_do_parse / typecheck_entry_emit / pipeline_run_x_pipeline after
 * host-cc leave. Prefer void* like wave101/105. */
extern int32_t pipeline_should_skip_x_typeck(void *ctx);
extern int32_t pipeline_typeck_entry_module_c(void *module, void *arena, void *ctx);
extern int32_t pipeline_typeck_dep_prerun_module_c(void *module, void *arena, void *ctx);
extern int32_t pipeline_load_and_sync_direct_import_deps_c(void *module, void *arena, void *ctx);
extern int32_t pipeline_parse_set_main_from_buf_c(void *module, void *arena, uint8_t *data, int32_t len);
extern int32_t pipeline_module_num_funcs(void *module);
extern int32_t pipeline_dep_ctx_ndep(void *ctx);
extern int32_t parser_get_module_num_imports(void *module);
extern void driver_diagnostic_typeck_fail(void);
extern void driver_diagnostic_source_len(int32_t len);
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern void driver_diagnostic_after_entry_parse_module(void *module);
extern void driver_diagnostic_entry_module(void *module, void *arena);
extern int32_t driver_x_pipeline_skip_typeck_get(void);
extern int32_t driver_x_pipeline_skip_codegen_get(void);
extern int32_t pipeline_driver_asm_build_skip_typeck(void);
extern int32_t pipeline_run_x_pipeline_impl(void *module, void *arena, uint8_t *source_data, size_t source_len,
                                           void *out_buf, void *ctx);

static int32_t wave106_last_rc;

int32_t run_x_pipeline_last_rc_get(void) {
  return wave106_last_rc;
}

void run_x_pipeline_last_rc_store_c(int32_t rc) {
  wave106_last_rc = rc;
}

int32_t pipeline_typeck_fail_return_c(int32_t fail_mapped) {
  driver_diagnostic_typeck_fail();
  if (fail_mapped != 0)
    return fail_mapped;
  return -1;
}

int32_t pipeline_typeck_null_fail_return_c(int32_t fail_mapped) {
  if (fail_mapped != 0)
    return fail_mapped;
  return -1;
}

int32_t run_x_pipeline_typecheck_entry_c(void *module, void *arena, void *ctx) {
  /* G.7 same matrix as pure runtime_pipeline_abi.x entry_c (NO_C product):
   * runtime may set skip_typeck when n_deps>0, but C precheck is always skipped
   * so user `build -o` with imports still needs full typeck (result_try_bad).
   * XLANG_ASM_BUILD_SKIP_TYPECK → dep_prerun only; else full typeck. */
  if (!module || !arena || !ctx)
    return -1;
  if (pipeline_asm_debug_enabled())
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "asm debug: typecheck_entry skip_tk=%d skip_cg=%d imports=%d build_skip=%d",
                 (int)driver_x_pipeline_skip_typeck_get(),
                 (int)driver_x_pipeline_skip_codegen_get(),
                 (int)parser_get_module_num_imports(module),
                 (int)pipeline_driver_asm_build_skip_typeck());
  if (driver_x_pipeline_skip_typeck_get() != 0) {
    if (parser_get_module_num_imports(module) == 0 && driver_x_pipeline_skip_codegen_get() != 0)
      return pipeline_typeck_entry_module_c(module, arena, ctx);
    if (pipeline_driver_asm_build_skip_typeck() != 0)
      return pipeline_typeck_dep_prerun_module_c(module, arena, ctx);
    return pipeline_typeck_entry_module_c(module, arena, ctx);
  }
  if (pipeline_should_skip_x_typeck(ctx) != 0)
    return 0;
  return pipeline_typeck_entry_module_c(module, arena, ctx);
}

int32_t run_x_pipeline_load_deps_after_parse_c(void *module, void *arena, void *ctx) {
  wave106_last_rc = pipeline_load_and_sync_direct_import_deps_c(module, arena, ctx);
  return wave106_last_rc;
}

int32_t run_x_pipeline_typecheck_after_load_c(void *module, void *arena, void *ctx) {
  wave106_last_rc = run_x_pipeline_typecheck_entry_c(module, arena, ctx);
  return wave106_last_rc;
}

int32_t run_x_pipeline_parse_entry_do_parse_c(void *module, void *arena, uint8_t *source_data, size_t source_len,
                                             void *ctx) {
  int32_t len_i32;
  int32_t parse_rc;
  if (!module || !arena || !ctx)
    return -1;
  len_i32 = (int32_t)source_len;
  driver_diagnostic_source_len(len_i32);
  parse_rc = pipeline_parse_set_main_from_buf_c(module, arena, source_data, len_i32);
  if (parse_rc != 0)
    return parse_rc;
  driver_diagnostic_after_entry_parse(pipeline_module_num_funcs(module));
  driver_diagnostic_after_entry_parse_module(module);
  driver_diagnostic_entry_module(module, arena);
  return 0;
}

int32_t run_x_pipeline_typecheck_entry_emit_c(void *module, void *arena, void *ctx) {
  /* Thin face: sole matrix in run_x_pipeline_typecheck_entry_c (G.7). */
  return run_x_pipeline_typecheck_entry_c(module, arena, ctx);
}

int32_t pipeline_run_x_pipeline(void *module, void *arena, const uint8_t *source_data, size_t source_len, void *out_buf,
                               void *ctx) {
  return pipeline_run_x_pipeline_impl(module, arena, (uint8_t *)source_data, source_len, out_buf, ctx);
}

/* wave107 codegen residual leave cold twins — former pipeline_codegen_residual.c.
 * PLATFORM: SHARED — only when pure FROM_X object is not linked. Product pure
 * owns strong name predicates + io.core/driver symbol rewrites after host-cc leave.
 * Prefer void-star and u8-star like wave101/105/106. Historical slen quirks twin C. */
static int wave107_name_prefix_eq(uint8_t *name, int32_t name_len, const char *pfx, int32_t plen) {
  if (!name || name_len < plen || !pfx)
    return 0;
  return memcmp(name, pfx, (size_t)plen) == 0 ? 1 : 0;
}

int32_t pipeline_codegen_use_buf_wrapper(uint8_t *name, int32_t name_len, int32_t num_args) {
  if (!name || name_len <= 0)
    return 0;
  if (num_args == 1 && name_len == 15 && wave107_name_prefix_eq(name, name_len, "xlang_io_register", 15))
    return 1;
  if (num_args == 2 && name_len == 18 && wave107_name_prefix_eq(name, name_len, "xlang_io_submit_read", 18))
    return 1;
  if (num_args == 2 && name_len == 19 && wave107_name_prefix_eq(name, name_len, "xlang_io_submit_write", 19))
    return 1;
  return 0;
}

int32_t pipeline_codegen_skip_emit_extern_io_batch_buf(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (name_len == 17 && memcmp(name, "io_read_batch_buf", 17) == 0)
    return 1;
  if (name_len == 18 && memcmp(name, "io_write_batch_buf", 18) == 0)
    return 1;
  if (name_len == 23 && memcmp(name, "io_register_buffers_buf", 23) == 0)
    return 1;
  return 0;
}

int32_t pipeline_codegen_should_skip_emit_func_by_name(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (name_len == 11 && wave107_name_prefix_eq(name, name_len, "placeholder", 11))
    return 1;
  if (name_len == 22 && wave107_name_prefix_eq(name, name_len, "std_string_placeholder", 22))
    return 1;
  if (name_len == 10 && wave107_name_prefix_eq(name, name_len, "string_new", 10))
    return 1;
  if (name_len == 22 && wave107_name_prefix_eq(name, name_len, "std_string_string_new", 22))
    return 1;
  if (name_len == 21 && wave107_name_prefix_eq(name, name_len, "std_string_string_new", 21))
    return 1;
  if (!link_abi_getenv("XLANG_EMIT_SEED_MEGA")) {
    if (name_len == 25 && memcmp(name, "asm_codegen_ast_seed_mega", 25) == 0)
      return 1;
    if (name_len == 32 && memcmp(name, "asm_codegen_ast_to_elf_seed_mega", 32) == 0)
      return 1;
  }
  return 0;
}

int32_t pipeline_codegen_emit_seed_mega_enabled(void) {
  const char *e = (const char *)link_abi_getenv("XLANG_EMIT_SEED_MEGA");
  return (e && e[0] && e[0] != '0') ? 1 : 0;
}

int32_t pipeline_codegen_is_submit_batch_buf_call(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (name_len == 21 && wave107_name_prefix_eq(name, name_len, "submit_read_batch_buf", 21))
    return 1;
  if (name_len == 22 && wave107_name_prefix_eq(name, name_len, "submit_write_batch_buf", 22))
    return 1;
  return 0;
}

int32_t pipeline_codegen_should_skip_emit_func_core_read_ptr(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (name_len >= 19 && wave107_name_prefix_eq(name, name_len, "xlang_io_read_ptr_len", 19))
    return 1;
  if (name_len == 15 && wave107_name_prefix_eq(name, name_len, "xlang_io_read_ptr", 15))
    return 1;
  if (name_len == 15 && wave107_name_prefix_eq(name, name_len, "xlang_io_register", 15))
    return 1;
  if (name_len == 23 && wave107_name_prefix_eq(name, name_len, "xlang_io_register_buffers", 23))
    return 1;
  if (name_len == 25 && wave107_name_prefix_eq(name, name_len, "xlang_io_unregister_buffers", 25))
    return 1;
  if (name_len == 20 && wave107_name_prefix_eq(name, name_len, "xlang_io_wait_readable", 20))
    return 1;
  return 0;
}

int32_t pipeline_asm_io_core_extern_callee_sym(uint8_t *name, int32_t name_len, uint8_t *sym_out, int32_t sym_cap) {
  uint8_t *bare;
  int32_t blen;
  const char *sym;
  int32_t slen;
  if (!name || name_len <= 0 || !sym_out || sym_cap <= 0)
    return 0;
  bare = name;
  blen = name_len;
  if (name_len > 12 && memcmp(name, "std_io_core_", 12) == 0) {
    bare = name + 12;
    blen = name_len - 12;
  }
  sym = NULL;
  slen = 0;
  if (blen == 23 && wave107_name_prefix_eq(bare, blen, "xlang_io_register_buffers", 23)) {
    sym = "io_register_buffers_4";
    slen = 23;
  } else if (blen == 25 && wave107_name_prefix_eq(bare, blen, "xlang_io_unregister_buffers", 25)) {
    sym = "io_unregister_buffers";
    slen = 21;
  } else if (blen == 15 && wave107_name_prefix_eq(bare, blen, "xlang_io_register", 15)) {
    sym = "io_register_buffer";
    slen = 19;
  } else if (blen == 19 && wave107_name_prefix_eq(bare, blen, "xlang_io_read_ptr_len", 19)) {
    sym = "io_read_ptr_len";
    slen = 15;
  } else if (blen == 15 && wave107_name_prefix_eq(bare, blen, "xlang_io_read_ptr", 15)) {
    sym = "io_read_ptr";
    slen = 11;
  } else if (blen == 20 && wave107_name_prefix_eq(bare, blen, "xlang_io_wait_readable", 20)) {
    sym = "io_wait_readable";
    slen = 17;
  }
  if (!sym)
    return 0;
  if (sym_cap < slen)
    return -1;
  memcpy(sym_out, sym, (size_t)slen);
  return slen;
}

int32_t pipeline_codegen_io_driver_buf_call_sym(uint8_t *name, int32_t name_len, int32_t num_args, uint8_t *sym_out,
                                                int32_t sym_cap) {
  const char *sym;
  int32_t sym_len;
  if (!name || name_len <= 0)
    return 0;
  sym = NULL;
  sym_len = 0;
  if (num_args == 1 && name_len == 8 && wave107_name_prefix_eq(name, name_len, "register", 8)) {
    sym = "xlang_io_register_buf";
    sym_len = 20;
  } else if (num_args == 2 && name_len == 11 && wave107_name_prefix_eq(name, name_len, "submit_read", 11)) {
    sym = "xlang_io_submit_read_buf";
    sym_len = 23;
  } else if (num_args == 2 && name_len == 12 && wave107_name_prefix_eq(name, name_len, "submit_write", 12)) {
    sym = "xlang_io_submit_write_buf";
    sym_len = 24;
  }
  if (!sym)
    return 0;
  if (!sym_out || sym_cap < sym_len)
    return -1;
  memcpy(sym_out, sym, (size_t)sym_len);
  return sym_len;
}

int32_t pipeline_codegen_std_io_fixed_fd_emit_impl(uint8_t *prefix, int32_t prefix_len, uint8_t *name,
                                                   int32_t name_len) {
  if (!prefix || !name || prefix_len < 7 || name_len <= 0)
    return 0;
  if (!wave107_name_prefix_eq(prefix, prefix_len, "std_io_", 7))
    return 0;
  if (name_len >= 13 && wave107_name_prefix_eq(name, name_len, "read_fixed_fd", 13))
    return 1;
  if (name_len >= 14 && wave107_name_prefix_eq(name, name_len, "write_fixed_fd", 14))
    return 1;
  return 0;
}


/* wave108 skip_force leave cold twins — former pipeline_codegen_skip_force.c.
 * PLATFORM: SHARED — only when pure FROM_X object is not linked. Product pure
 * owns strong skip/force/path predicates after host-cc leave.
 * Prefer void-star and u8-star like wave107. Historical path/NUL quirks twin C. */
typedef struct {
  const char *sym;
  int32_t sym_len;
  int32_t override_nargs;
} CodegenCallOverrideEntry;

static const CodegenCallOverrideEntry k_codegen_call_overrides[] = {
    {"vec_len_empty", 13, 0},
    {"std_vec_vec_len_empty", 21, 0},
    {"alloc_size_zero", 15, 0},
    {"std_heap_alloc_size_zero", 24, 0},
    {"runtime_ready", 13, 0},
    {"std_runtime_runtime_ready", 25, 0},
    {"string_new", 10, 0},
    {"std_string_string_new", 21, 0},
    {"placeholder", 11, 0},
    {"std_string_placeholder", 22, 0},
    {"thread_self", 11, 0},
    {"std_thread_thread_self", 22, 0},
    {"thread_dummy_entry_ptr", 22, 0},
    {"std_thread_thread_dummy_entry_ptr", 33, 0},
    {"now_monotonic_ns", 16, 0},
    {"std_time_now_monotonic_ns", 25, 0},
    {"now_monotonic_ms", 16, 0},
    {"std_time_now_monotonic_ms", 25, 0},
    {"fmt_i32", 7, 1},
    {"core_fmt_fmt_i32", 16, 1},
    {"print_i32", 9, 1},
    {"std_io_print_i32", 16, 1},
    {"print_u32", 9, 1},
    {"std_io_print_u32", 16, 1},
    {"print_i64", 9, 1},
    {"std_io_print_i64", 16, 1},
    /* PLATFORM: SHARED — lengths are strlen (std_fmt_println=15, not 14→printl truncate). */
    {"std_fmt_println", 15, 2},
    {"std_fmt_print", 13, 2},
    {"std_debug_println", 17, 2},
    {"std_debug_print", 15, 2},
    {"ok_i32", 6, 1},
    {"core_result_ok_i32", 18, 1},
    {"err_i32", 7, 1},
    {"core_result_err_i32", 19, 1},
};

int32_t pipeline_codegen_call_num_args_override_lookup(uint8_t *buf, int32_t full, int32_t num_args) {
  int i, n;
  if (!buf || full <= 0 || num_args <= 0)
    return num_args;
  n = (int)(sizeof(k_codegen_call_overrides) / sizeof(k_codegen_call_overrides[0]));
  for (i = 0; i < n; i++) {
    if (full == k_codegen_call_overrides[i].sym_len &&
        memcmp(buf, k_codegen_call_overrides[i].sym, (size_t)full) == 0)
      return k_codegen_call_overrides[i].override_nargs;
  }
  return num_args;
}

/** codegen.x / asm backend：拼接 prefix+name 后查表，避免 .x 内 u8[N] 字面量与 *u8 下标在 asm emit 失败。 */
int32_t pipeline_codegen_call_num_args_override(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                                int32_t num_args) {
  uint8_t buf[96];
  int32_t full = 0;
  int32_t i;
  if (num_args <= 0)
    return num_args;
  if (prefix && prefix_len > 0) {
    for (i = 0; i < prefix_len && full < 96; i++)
      buf[full++] = prefix[i];
  }
  if (name && name_len > 0) {
    for (i = 0; i < name_len && full < 96; i++)
      buf[full++] = name[i];
  }
  return pipeline_codegen_call_num_args_override_lookup(buf, full, num_args);
}

/** codegen.x：std.io.driver 桥接名前缀表（asm 不支持函数内数组字面量）。 */
static int wave108_name_prefix_eq(uint8_t *name, int32_t name_len, const char *pfx, int32_t plen) {
  if (!name || name_len < plen)
    return 0;
  return memcmp(name, pfx, (size_t)plen) == 0 ? 1 : 0;
}

int32_t pipeline_codegen_is_std_io_driver_bridge_name(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if ((name_len == 8 || name_len == 9) && wave108_name_prefix_eq(name, name_len, "register", 8))
    return 1;
  if ((name_len == 11 || name_len == 12) && wave108_name_prefix_eq(name, name_len, "submit_read", 11))
    return 1;
  if ((name_len == 12 || name_len == 13) && wave108_name_prefix_eq(name, name_len, "submit_write", 12))
    return 1;
  if ((name_len == 13 || name_len == 14) && wave108_name_prefix_eq(name, name_len, "wait_readable", 13))
    return 1;
  /* register_fixed_buffers only (exact prefix); not submit_write_batch_buf (also len 22) */
  if (name_len == 22 && wave108_name_prefix_eq(name, name_len, "register_fixed_buffers", 22))
    return 1;
  /*
   * submit_*_batch(_buf) / submit_register_fixed_buffers_buf：不得 skip。
   * 与 codegen.x / seed bridge 对齐：call 端仍要 std_io_driver_submit_*_batch 真体；
   * skip 后仅剩 undef（或 weak -1 假红 run-io-driver）。
   */
  return 0;
}

/** import 路径逐字节含末尾 NUL 比较（codegen.x asm 无数组字面量）。 */
static int wave108_path_bytes_eq(uint8_t *path, const char *expect, int32_t len_with_nul) {
  int32_t i;
  if (!path)
    return 0;
  for (i = 0; i < len_with_nul; i++)
    if (path[i] != (uint8_t)expect[i])
      return 0;
  return 1;
}

/** prefix+name 拼接是否等于 full（总长须一致）。 */
static int wave108_prefix_name_bytes_eq(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                        const char *full, int32_t full_len) {
  int32_t pi;
  int32_t ni;
  if (!prefix || !name || prefix_len <= 0 || name_len <= 0)
    return 0;
  if (prefix_len + name_len != full_len)
    return 0;
  for (pi = 0; pi < prefix_len; pi++)
    if (prefix[pi] != (uint8_t)full[pi])
      return 0;
  for (ni = 0; ni < name_len; ni++)
    if (name[ni] != (uint8_t)full[prefix_len + ni])
      return 0;
  return 1;
}

/** codegen.x：import 路径是否为 std.io.driver（含 NUL，14 字节）。 */
int32_t pipeline_codegen_path_is_std_io_driver_bytes(uint8_t *path) {
  return wave108_path_bytes_eq(path, "std.io.driver\0", 14);
}

/** codegen.x：import 路径是否为 std.io.core（含 NUL，12 字节）。 */
int32_t pipeline_codegen_path_is_std_io_core_bytes(uint8_t *path) {
  return wave108_path_bytes_eq(path, "std.io.core\0", 12);
}

/**
 * seed 用户程序 asm：std.io 族模块由 io.o + user_asm_seed_bridge 桩提供，勿整模块 emit（易宿主栈 Abort）。
 * 匹配 std.io、std.io.core、std.io.driver 等。
 */
int32_t pipeline_codegen_dep_skip_asm_user_std_io(uint8_t *path) {
  if (!path)
    return 0;
  if (pipeline_codegen_path_is_std_io_core_bytes(path) != 0)
    return 1;
  if (memcmp(path, "std.io", 6) != 0)
    return 0;
  if (path[6] == 0 || path[6] == '.')
    return 1;
  return 0;
}

/**
 * 产品轨 std link_only：唯一权威在 seeds/runtime_link_abi.from_x.c。
 * 此处勿再维护第二份表（双权威必然漂移；std.env 曾因表不一致假红）。
 * 声明见文件前部 extern；实现由 runtime_link_abi.o 提供。
 */
/* pipeline_codegen_std_dep_link_only — defined in runtime_link_abi.from_x.c */

/**
 * bootstrap -E / asm partial：compiler 前端模块符号已由 *_x.o 链入，勿整库 X C codegen（ast 等大库 emit 失败）。
 * 精确匹配 import 路径（如 ast、codegen、parser.x→parser）。
 */
int32_t pipeline_codegen_dep_skip_x_bootstrap_partial(uint8_t *path) {
  static const char *const k_exact[] = {
      "ast", "codegen", "parser", "typeck", "lexer", "preprocess", "pipeline", "lsp", "lsp.diag", "lsp.io",
      "driver", "driver.check", "driver.compile", "driver.emit", "driver.fmt", "driver.test", "driver.build",
      "driver.run", "asm.types", NULL};
  int32_t i;
  if (!path)
    return 0;
  for (i = 0; k_exact[i]; i++) {
    if (wave108_path_bytes_eq(path, k_exact[i], (int32_t)strlen(k_exact[i])))
      return 1;
  }
  return 0;
}

/**
 * codegen.x / seed：std.io.core 与 preamble weak 重复的 xlang_io_* 须跳过 emit。
 * 【Why 根源】仅 skip read_fixed/write_fixed（preamble weak）；勿 skip submit_read /
 *   submit_*_batch — 与 codegen.x codegen_should_skip_emit_std_io_core_io_dup 单权威对齐。
 *   旧 skip 假定 io.o/weak batch 权威；产品 C 不硬链 stubs 且 weak batch 已撤 → 假绿/UNDEF。
 * PLATFORM: SHARED.
 */
int32_t pipeline_codegen_should_skip_emit_std_io_core_io_dup(uint8_t *dep_path, uint8_t *name, int32_t name_len) {
  if (!dep_path || !name)
    return 0;
  if (memcmp(dep_path, "std.io.core", 11) != 0)
    return 0;
  if ((name_len == 18 || name_len == 19) && wave108_name_prefix_eq(name, name_len, "xlang_io_read_fixed", 18))
    return 1;
  if ((name_len == 19 || name_len == 20) && wave108_name_prefix_eq(name, name_len, "xlang_io_write_fixed", 19))
    return 1;
  return 0;
}

/** codegen.x：std.io handle_* 字面量函数须跳过 emit；dep_path 为空时仅按 name 判断。 */
int32_t pipeline_codegen_should_skip_emit_std_io_trivial_handle(uint8_t *dep_path, uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (dep_path && !wave108_path_bytes_eq(dep_path, "std.io\0", 7))
    return 0;
  if ((name_len == 12 || name_len == 13) && wave108_name_prefix_eq(name, name_len, "handle_stdin", 12))
    return 1;
  if ((name_len == 13 || name_len == 14) && wave108_name_prefix_eq(name, name_len, "handle_stdout", 13))
    return 1;
  if ((name_len == 13 || name_len == 14) && wave108_name_prefix_eq(name, name_len, "handle_stderr", 13))
    return 1;
  if ((name_len == 15 || name_len == 16) && wave108_name_prefix_eq(name, name_len, "handle_from_fd", 15))
    return 1;
  return 0;
}

/** codegen.x：合并 driver_should_skip_emit 三套逻辑（原 codegen_should_skip_emit_func）。 */
int32_t pipeline_codegen_should_skip_emit_func(uint8_t *dep_path, uint8_t *prefix, int32_t prefix_len,
                                               uint8_t *name, int32_t name_len) {
  int32_t ok_path;
  if (prefix && prefix_len > 0 && name && name_len > 0) {
    if (wave108_prefix_name_bytes_eq(prefix, prefix_len, name, name_len, "std_io_driver_driver_read_ptr_len", 33))
      return 1;
    if (wave108_prefix_name_bytes_eq(prefix, prefix_len, name, name_len, "std_io_driver_driver_read_ptr", 29))
      return 1;
  }
  if (dep_path) {
    ok_path = wave108_path_bytes_eq(dep_path, "std.io.driver\0", 14);
    if (!ok_path)
      ok_path = wave108_path_bytes_eq(dep_path, "std.io\0", 7);
    if (ok_path && name) {
      if ((name_len == 19 || name_len == 20) &&
          wave108_name_prefix_eq(name, name_len, "driver_read_ptr_len", 19))
        return 1;
      if ((name_len == 15 || name_len == 16) && wave108_name_prefix_eq(name, name_len, "driver_read_ptr", 15))
        return 1;
    }
  }
  if (prefix && prefix_len == 14 && name &&
      wave108_name_prefix_eq(prefix, prefix_len, "std_io_driver_", 14) &&
      pipeline_codegen_is_std_io_driver_bridge_name(name, name_len))
    return 1;
  if (dep_path && name && wave108_path_bytes_eq(dep_path, "std.io.driver\0", 14) &&
      pipeline_codegen_is_std_io_driver_bridge_name(name, name_len))
    return 1;
  if (prefix && prefix_len == 14 && name &&
      pipeline_codegen_should_skip_emit_std_io_trivial_handle(0, name, name_len))
    return 1;
  if (dep_path && name) {
    if (pipeline_codegen_should_skip_emit_std_io_core_io_dup(dep_path, name, name_len))
      return 1;
    if (wave108_path_bytes_eq(dep_path, "std.io.driver\0", 14) &&
        pipeline_codegen_should_skip_emit_std_io_trivial_handle(0, name, name_len))
      return 1;
  }
  return 0;
}

/** codegen.x：entry 模块是否含 read_message（LSP io 入口探测）。 */
int32_t pipeline_codegen_entry_is_lsp_io_module(void *module) {
  static const uint8_t rd[] = "read_message";
  int32_t i;
  int32_t n;
  uint8_t raw[64];
  int32_t nlen;
  if (!module)
    return 0;
  n = pipeline_module_num_funcs(module);
  for (i = 0; i < n; i++) {
    nlen = pipeline_module_func_name_len_at(module, i);
    if (nlen != 12)
      continue;
    pipeline_module_func_name_copy64(module, i, raw);
    if (wave108_name_prefix_eq(raw, 12, "read_message", 12))
      return 1;
  }
  return 0;
}

/** codegen.x：entry 模块是否含 lsp_main。 */
int32_t pipeline_codegen_entry_is_lsp_main_module(void *module) {
  static const uint8_t main_nm[] = "lsp_main";
  int32_t i;
  int32_t n;
  uint8_t raw[64];
  int32_t nlen;
  if (!module)
    return 0;
  n = pipeline_module_num_funcs(module);
  for (i = 0; i < n; i++) {
    nlen = pipeline_module_func_name_len_at(module, i);
    if (nlen != 8)
      continue;
    pipeline_module_func_name_copy64(module, i, raw);
    if (wave108_name_prefix_eq(raw, 8, "lsp_main", 8))
      return 1;
  }
  return 0;
}

/** codegen.x：C 前缀是否为 std_io_driver 族（13 字节 + 可选第 14 字节 NUL/_）。 */
int32_t pipeline_codegen_force_param_std_io_driver_prefix_ok(uint8_t *prefix, int32_t prefix_len) {
  static const char exp13[] = "std_io_driver";
  int32_t i;
  if (!prefix || prefix_len < 13)
    return 0;
  for (i = 0; i < 13; i++)
    if (prefix[i] != (uint8_t)exp13[i])
      return 0;
  if (prefix_len > 13) {
    uint8_t b14 = prefix[13];
    if (b14 != 0 && b14 != 95)
      return 0;
  }
  return 1;
}

/** codegen.x：std_io_driver submit_*_batch_buf 首参强制 size_t。 */
int32_t pipeline_codegen_force_param_size_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                            int32_t param_index) {
  if (param_index != 0)
    return 0;
  if (!pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len))
    return 0;
  if (!name)
    return 0;
  if (name_len == 21 && wave108_name_prefix_eq(name, name_len, "submit_read_batch_buf", 21))
    return 1;
  if (name_len == 22 && wave108_name_prefix_eq(name, name_len, "submit_write_batch_buf", 22))
    return 1;
  return 0;
}

/** codegen.x：std.io print 第二参强制 size_t（前缀须 std_io_）。 */
int32_t pipeline_codegen_force_param_size_t_std_io_print_str_second(uint8_t *prefix, int32_t prefix_len,
                                                                    uint8_t *name, int32_t name_len,
                                                                    int32_t param_index) {
  if (param_index != 1 || !name || name_len != 5)
    return 0;
  if (memcmp(name, "print", 5) != 0)
    return 0;
  if (!prefix || prefix_len < 7)
    return 0;
  return memcmp(prefix, "std_io_", 7) == 0 ? 1 : 0;
}

/** codegen.x：std_io_driver register/submit_read/submit_write 首参 ptrdiff_t。 */
int32_t pipeline_codegen_force_param_ptrdiff_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                               int32_t param_index) {
  if (param_index != 0 || !pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) || !name)
    return 0;
  if (name_len == 8 && wave108_name_prefix_eq(name, name_len, "register", 8))
    return 1;
  if (name_len == 11 && wave108_name_prefix_eq(name, name_len, "submit_read", 11))
    return 1;
  if (name_len == 12 && wave108_name_prefix_eq(name, name_len, "submit_write", 12))
    return 1;
  return 0;
}

/** codegen.x：std_io_driver 按名/下标强制 uint32_t（timeout_ms/nr）。 */
int32_t pipeline_codegen_force_param_uint32_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                              int32_t param_index) {
  if (!pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) || !name)
    return 0;
  if (param_index == 1) {
    if (name_len == 11 && wave108_name_prefix_eq(name, name_len, "submit_read", 11))
      return 1;
    if (name_len == 12 && wave108_name_prefix_eq(name, name_len, "submit_write", 12))
      return 1;
    if (name_len == 33 && wave108_name_prefix_eq(name, name_len, "submit_register_fixed_buffers_buf", 33))
      return 1;
    return 0;
  }
  if (param_index == 3) {
    if (name_len == 21 && wave108_name_prefix_eq(name, name_len, "submit_read_batch_buf", 21))
      return 1;
    if (name_len == 22 && wave108_name_prefix_eq(name, name_len, "submit_write_batch_buf", 22))
      return 1;
  }
  return 0;
}


/* wave109 type_to_c leave cold twins — former pipeline_codegen_type_to_c.c.
 * PLATFORM: SHARED — only when pure FROM_X object is not linked. Product pure
 * owns strong type_kind_copy / vector_type_copy / type_kind_append / type_to_c_repr
 * after host-cc leave. Prefer void-star arena like wave105/108. */
int32_t pipeline_codegen_type_kind_cstr(int32_t kind, uint8_t **out_ptr) {
  static const char *k_i32 = "int32_t";
  static const char *k_i64 = "int64_t";
  static const char *k_bool = "int";
  static const char *k_u8 = "uint8_t";
  static const char *k_u32 = "uint32_t";
  static const char *k_u64 = "uint64_t";
  static const char *k_f32 = "float";
  static const char *k_f64 = "double";
  static const char *k_void = "void";
  static const char *k_usize = "size_t";
  static const char *k_isize = "ssize_t";
  if (!out_ptr)
    return 0;
  *out_ptr = NULL;
  switch (kind) {
  case 0:
    *out_ptr = (uint8_t *)k_i32;
    return 7;
  case 1:
    *out_ptr = (uint8_t *)k_bool;
    return 3;
  case 2:
    *out_ptr = (uint8_t *)k_u8;
    return 7;
  case 3:
    *out_ptr = (uint8_t *)k_u32;
    return 8;
  case 4:
    *out_ptr = (uint8_t *)k_u64;
    return 8;
  case 5:
    *out_ptr = (uint8_t *)k_i64;
    return 7;
  case 6:
    *out_ptr = (uint8_t *)k_usize;
    return 6;
  case 7:
    *out_ptr = (uint8_t *)k_isize;
    return 7;
  case 14:
    *out_ptr = (uint8_t *)k_f32;
    return 5;
  case 15:
    *out_ptr = (uint8_t *)k_f64;
    return 6;
  case 16:
    *out_ptr = (uint8_t *)k_void;
    return 4;
  default:
    return 0;
  }
}

int32_t pipeline_codegen_type_kind_copy(uint8_t *dst, int32_t cap, int32_t kind) {
  uint8_t *s;
  int32_t n;
  int32_t i;
  n = pipeline_codegen_type_kind_cstr(kind, &s);
  if (n <= 0 || !s || !dst || cap < n)
    return -1;
  for (i = 0; i < n; i++)
    dst[i] = s[i];
  return n;
}

int32_t pipeline_codegen_vector_type_cstr(int32_t elem_kind, int32_t lanes, uint8_t **out_ptr) {
  if (!out_ptr)
    return 0;
  *out_ptr = NULL;
  if (elem_kind == 0) {
    if (lanes == 4) {
      *out_ptr = (uint8_t *)"i32x4_t";
      return 7;
    }
    if (lanes == 8) {
      *out_ptr = (uint8_t *)"i32x8_t";
      return 7;
    }
    if (lanes == 16) {
      *out_ptr = (uint8_t *)"i32x16_t";
      return 8;
    }
  }
  if (elem_kind == 3) {
    if (lanes == 4) {
      *out_ptr = (uint8_t *)"u32x4_t";
      return 7;
    }
    if (lanes == 8) {
      *out_ptr = (uint8_t *)"u32x8_t";
      return 7;
    }
    if (lanes == 16) {
      *out_ptr = (uint8_t *)"u32x16_t";
      return 8;
    }
  }
  if (elem_kind == 14) {
    if (lanes == 4) {
      *out_ptr = (uint8_t *)"f32x4_t";
      return 7;
    }
    if (lanes == 8) {
      *out_ptr = (uint8_t *)"f32x8_t";
      return 7;
    }
    if (lanes == 16) {
      *out_ptr = (uint8_t *)"f32x16_t";
      return 8;
    }
  }
  return 0;
}

int32_t pipeline_codegen_vector_type_copy(uint8_t *dst, int32_t cap, int32_t elem_kind, int32_t lanes) {
  uint8_t *s;
  int32_t n;
  int32_t i;
  n = pipeline_codegen_vector_type_cstr(elem_kind, lanes, &s);
  if (n <= 0 || !s || !dst || cap < n)
    return -1;
  for (i = 0; i < n; i++)
    dst[i] = s[i];
  return n;
}

int32_t pipeline_codegen_type_kind_append(uint8_t *scratch, int32_t cap, int32_t w, int32_t kind) {
  uint8_t *s;
  int32_t n;
  int32_t i;
  n = pipeline_codegen_type_kind_cstr(kind, &s);
  if (n <= 0 || !s)
    return -1;
  for (i = 0; i < n; i++) {
    if (w >= cap - 1)
      return -1;
    scratch[w++] = s[i];
  }
  return w;
}

/* Product hybrid injects this body (seed is under FROM_X exclude).
 * G.7: single C body; do not fork a second type_to_c_repr. */
/* XLANG_PABI_TYPE_TO_C_REPR_THIN_BEGIN */
#include <stdint.h>
extern int32_t pipeline_type_named_name_into(void *arena, int32_t ref, uint8_t *out64);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t type_ref);
extern int32_t pipeline_type_elem_ref_at(void *arena, int32_t type_ref);
extern int32_t pipeline_type_array_size_at(void *arena, int32_t type_ref);
extern int32_t pipeline_arena_num_types(void *arena);
extern int32_t pipeline_codegen_vector_type_copy(uint8_t *scratch, int32_t cap, int32_t elem_kind, int32_t arr_sz);
extern int32_t pipeline_codegen_type_kind_copy(uint8_t *scratch, int32_t cap, int32_t tk);

static int32_t pipeline_codegen_type_to_c_repr_inner(void *arena, uint8_t *scratch, int32_t cap, int32_t type_ref,
                                                     uint8_t *struct_prefix, int32_t struct_prefix_len) {
  /* PLATFORM: SHARED — twin of runtime_pipeline_abi.x inner/eb 896.
   * Live -E first-wins this thin over weak pure. cap 256 failed nest 11+
   * (n16 XP003). nest 64 i32 tag=782 fits 896; TYPE_SLICE cap is the
   * write loop (per-star w+2), not leftover 19+2*plen. */
  uint8_t inner[896];
  uint8_t eb[896];
  int32_t tk;
  int32_t elem_ref;
  int32_t arr_sz;
  int32_t elem_kind;
  int32_t n;
  int32_t j;
  int32_t sp;
  int32_t plen;
  int32_t pi;
  int32_t hi;
  int32_t w;
  int32_t h;
  int32_t name_len;
  uint8_t nm[256];
  int32_t sn;
  int32_t nt;

  if (cap < 16)
    return -1;
  nt = arena ? pipeline_arena_num_types(arena) : 0;
  if (!arena || type_ref <= 0 || type_ref > nt) {
    static const uint8_t k_i32[7] = {'i', 'n', 't', '3', '2', '_', 't'};
    if (cap < 7)
      return -1;
    for (j = 0; j < 7; j++)
      scratch[j] = k_i32[j];
    return 7;
  }
  tk = pipeline_type_kind_ord_at(arena, type_ref);
  elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
  arr_sz = pipeline_type_array_size_at(arena, type_ref);
  if (tk == 9 && elem_ref > 0) {
    n = pipeline_codegen_type_to_c_repr_inner(arena, inner, 896, elem_ref, struct_prefix, struct_prefix_len);
    if (n < 0 || n + 2 >= cap)
      return -1;
    for (j = 0; j < n; j++)
      scratch[j] = inner[j];
    scratch[n] = (uint8_t)' ';
    scratch[n + 1] = (uint8_t)'*';
    return n + 2;
  }
  /* TYPE_ARRAY: `xlang_arr<N>_<elemC>` (matches runtime_pipeline_abi.x).
   * Prior decay made [][2]i32 → xlang_slice_int32_t (host-C INDEX BLD001).
   * arr_sz<=0 keeps decay. PLATFORM: SHARED cold twin. */
  if (tk == 10 && elem_ref > 0) {
    int32_t w;
    int32_t n_el;
    int32_t sp_el;
    int32_t pi_el;
    int32_t keep;
    int32_t d;
    int32_t nv;
    uint8_t tmp[16];
    int32_t tlen;
    int32_t ti;
    static const uint8_t k_arr[9] = {'x', 'l', 'a', 'n', 'g', '_', 'a', 'r', 'r'};
    if (arr_sz <= 0)
      return pipeline_codegen_type_to_c_repr_inner(arena, scratch, cap, elem_ref, struct_prefix, struct_prefix_len);
    n_el = pipeline_codegen_type_to_c_repr_inner(arena, eb, 896, elem_ref, struct_prefix, struct_prefix_len);
    if (n_el < 0 || n_el >= 896)
      return -1;
    sp_el = 0;
    if (n_el >= 7 && eb[0] == 's' && eb[1] == 't' && eb[2] == 'r' && eb[3] == 'u' && eb[4] == 'c' && eb[5] == 't'
        && eb[6] == ' ') {
      sp_el = 7;
      while (sp_el < n_el && eb[sp_el] == ' ')
        sp_el++;
    }
    if (9 >= cap)
      return -1;
    for (w = 0; w < 9; w++)
      scratch[w] = k_arr[w];
    nv = arr_sz;
    tlen = 0;
    if (nv <= 0) {
      tmp[0] = (uint8_t)'0';
      tlen = 1;
    } else {
      while (nv > 0 && tlen < 16) {
        d = nv % 10;
        tmp[tlen++] = (uint8_t)('0' + d);
        nv = nv / 10;
      }
    }
    if (w + tlen >= cap)
      return -1;
    for (ti = 0; ti < tlen; ti++)
      scratch[w++] = tmp[tlen - 1 - ti];
    if (w + 1 >= cap)
      return -1;
    scratch[w++] = (uint8_t)'_';
    for (pi_el = sp_el; pi_el < n_el; pi_el++) {
      uint8_t ch = eb[pi_el];
      if (ch == (uint8_t)'*') {
        if (w + 2 >= cap)
          return -1;
        scratch[w++] = (uint8_t)'_';
        scratch[w++] = (uint8_t)'p';
      } else {
        keep = 0;
        if (ch >= (uint8_t)'0' && ch <= (uint8_t)'9')
          keep = 1;
        if (ch >= (uint8_t)'A' && ch <= (uint8_t)'Z')
          keep = 1;
        if (ch >= (uint8_t)'a' && ch <= (uint8_t)'z')
          keep = 1;
        if (ch == (uint8_t)'_')
          keep = 1;
        if (keep) {
          if (w >= cap)
            return -1;
          scratch[w++] = ch;
        }
      }
    }
    if (w <= 10)
      return -1;
    return w;
  }
  if (tk == 13 && elem_ref > 0) {
    elem_kind = pipeline_type_kind_ord_at(arena, elem_ref);
    n = pipeline_codegen_vector_type_copy(scratch, cap, elem_kind, arr_sz);
    if (n >= 0)
      return n;
    return pipeline_codegen_type_kind_copy(scratch, cap, 0);
  }
  if (tk == 12 && elem_ref > 0)
    return pipeline_codegen_type_to_c_repr_inner(arena, scratch, cap, elem_ref, struct_prefix, struct_prefix_len);
  /* TYPE_DYN (17): fat trait object — ≡ runtime_pipeline_abi.x. PLATFORM: SHARED cold twin. */
  if (tk == 17) {
    static const uint8_t k_dyn[20] = {'s', 't', 'r', 'u', 'c', 't', ' ', 'x', 'l', 'a', 'n', 'g', '_', 'd', 'y', 'n', '_', 'o', 'b', 'j'};
    if (cap < 20)
      return -1;
    for (j = 0; j < 20; j++)
      scratch[j] = k_dyn[j];
    return 20;
  }
  /* 10.3.1: TYPE_FN (18) → uint8_t * Cap opaque ABI — ≡ runtime_pipeline_abi.x. */
  if (tk == 18) {
    static const uint8_t k_fn[9] = {'u', 'i', 'n', 't', '8', '_', 't', ' ', '*'};
    if (cap < 9)
      return -1;
    for (j = 0; j < 9; j++)
      scratch[j] = k_fn[j];
    return 9;
  }
  if (tk == 11 && elem_ref > 0) {
    n = pipeline_codegen_type_to_c_repr_inner(arena, eb, 896, elem_ref, struct_prefix, struct_prefix_len);
    if (n < 0 || n >= 896)
      return -1;
    sp = 0;
    if (n >= 7 && eb[0] == 's' && eb[1] == 't' && eb[2] == 'r' && eb[3] == 'u' && eb[4] == 'c' && eb[5] == 't'
        && eb[6] == ' ') {
      sp = 7;
      while (sp < n && eb[sp] == ' ')
        sp++;
    }
    plen = n - sp;
    /* PLATFORM: SHARED — header needs 19 bytes; `*` → `_p` growth is the
     * write-loop `w+2>=cap` below. leftover 19+2*plen rejected nest 64
     * i32 (tag=782 fits 896; 2*plen of nest 63 ≈ 1545). */
    if (plen <= 0 || 19 >= cap)
      return -1;
    {
      static const uint8_t hdr[19] = {'s', 't', 'r', 'u', 'c', 't', ' ', 'x', 'l', 'a', 'n', 'g', '_', 's', 'l', 'i', 'c', 'e', '_'};
      for (hi = 0; hi < 19; hi++)
        scratch[hi] = hdr[hi];
    }
    /* Sanitize like TYPE_ARRAY: `*` → `_p`; keep alnum/_; skip space/brackets.
     * Prior raw copy made []*i32 → `struct xlang_slice_int32_t *` (pointer,
     * not a tag). PLATFORM: SHARED host-C cold twin. */
    w = 19;
    for (pi = 0; pi < plen; pi++) {
      uint8_t ch = eb[sp + pi];
      if (ch == (uint8_t)'*') {
        if (w + 2 >= cap)
          return -1;
        scratch[w++] = (uint8_t)'_';
        scratch[w++] = (uint8_t)'p';
      } else {
        int32_t keep = 0;
        if (ch >= (uint8_t)'0' && ch <= (uint8_t)'9')
          keep = 1;
        if (ch >= (uint8_t)'A' && ch <= (uint8_t)'Z')
          keep = 1;
        if (ch >= (uint8_t)'a' && ch <= (uint8_t)'z')
          keep = 1;
        if (ch == (uint8_t)'_')
          keep = 1;
        if (keep) {
          if (w >= cap)
            return -1;
          scratch[w++] = ch;
        }
      }
    }
    if (w <= 19)
      return -1;
    return w;
  }
  name_len = pipeline_type_named_name_into(arena, type_ref, nm);
  if (tk == 8 && name_len > 0) {
    if (name_len == 2 && nm[0] == 'i' && nm[1] == '8') {
      static const uint8_t k_i8[6] = {'i', 'n', 't', '8', '_', 't'};
      if (cap < 6)
        return -1;
      for (j = 0; j < 6; j++)
        scratch[j] = k_i8[j];
      return 6;
    }
    if (name_len == 3 && nm[0] == 'i' && nm[1] == '1' && nm[2] == '6') {
      static const uint8_t k_i16[7] = {'i', 'n', 't', '1', '6', '_', 't'};
      if (cap < 7)
        return -1;
      for (j = 0; j < 7; j++)
        scratch[j] = k_i16[j];
      return 7;
    }
    if (name_len == 3 && nm[0] == 'u' && nm[1] == '1' && nm[2] == '6') {
      static const uint8_t k_u16[8] = {'u', 'i', 'n', 't', '1', '6', '_', 't'};
      if (cap < 8)
        return -1;
      for (j = 0; j < 8; j++)
        scratch[j] = k_u16[j];
      return 8;
    }
    {
      static const uint8_t hdr2[7] = {'s', 't', 'r', 'u', 'c', 't', ' '};
      w = 0;
      for (h = 0; h < 7; h++) {
        if (w >= cap - 1)
          return -1;
        scratch[w++] = hdr2[h];
      }
    }
    if (struct_prefix && struct_prefix_len > 0) {
      for (pi = 0; pi < struct_prefix_len; pi++) {
        if (w >= cap - 1)
          return -1;
        scratch[w++] = struct_prefix[pi];
      }
    }
    for (pi = 0; pi < name_len && pi < 64; pi++) {
      if (w >= cap - 1)
        return -1;
      scratch[w++] = nm[pi];
    }
    return w;
  }
  sn = pipeline_codegen_type_kind_copy(scratch, cap, tk);
  if (sn > 0)
    return sn;
  return pipeline_codegen_type_kind_copy(scratch, cap, 0);
}

int32_t pipeline_codegen_type_to_c_repr(void *arena, uint8_t *scratch, int32_t cap, int32_t type_ref,
                                        uint8_t *struct_prefix, int32_t struct_prefix_len) {
  return pipeline_codegen_type_to_c_repr_inner(arena, scratch, cap, type_ref, struct_prefix, struct_prefix_len);
}
/* XLANG_PABI_TYPE_TO_C_REPR_THIN_END */



/* wave110 struct_emit leave cold twins — former pipeline_codegen_struct_emit.c.
 * PLATFORM: SHARED — only when pure FROM_X object is not linked. Product pure
 * owns strong prologue/tag/field emit after host-cc leave.
 * Prefer void-star arena/out like wave105/109. */
#ifndef PIPELINE_CODEGEN_OUTBUF_CAP
#define PIPELINE_CODEGEN_OUTBUF_CAP 9437184
#endif
#define PIPELINE_CODEGEN_STRUCT_TAG_MAX 256
#define PIPELINE_CODEGEN_STRUCT_TAG_CAP 128

static int g_codegen_c_file_prologue_done_w110;
static char g_codegen_struct_tags_w110[PIPELINE_CODEGEN_STRUCT_TAG_MAX][PIPELINE_CODEGEN_STRUCT_TAG_CAP];
static int g_codegen_struct_tag_n_w110;

int32_t pipeline_codegen_c_file_prologue_done_get(void) {
  return g_codegen_c_file_prologue_done_w110;
}

void pipeline_codegen_c_file_prologue_done_set(int32_t v) {
  g_codegen_c_file_prologue_done_w110 = v != 0 ? 1 : 0;
}

void pipeline_codegen_c_file_prologue_done_reset(void) {
  g_codegen_c_file_prologue_done_w110 = 0;
  g_codegen_struct_tag_n_w110 = 0;
}

int32_t pipeline_codegen_struct_tag_try_claim(const uint8_t *prefix, int32_t prefix_len, const uint8_t *name,
                                             int32_t name_len) {
  char tag[PIPELINE_CODEGEN_STRUCT_TAG_CAP];
  int32_t i;
  int32_t tlen;
  if (!name || name_len <= 0)
    return -1;
  if (prefix_len < 0)
    prefix_len = 0;
  if (!prefix)
    prefix_len = 0;
  tlen = prefix_len + name_len;
  if (tlen <= 0 || tlen >= PIPELINE_CODEGEN_STRUCT_TAG_CAP)
    return -1;
  if (prefix_len > 0)
    memcpy(tag, prefix, (size_t)prefix_len);
  memcpy(tag + prefix_len, name, (size_t)name_len);
  tag[tlen] = '\0';
  for (i = 0; i < g_codegen_struct_tag_n_w110; i++) {
    if (strcmp(g_codegen_struct_tags_w110[i], tag) == 0)
      return 0;
  }
  if (g_codegen_struct_tag_n_w110 >= PIPELINE_CODEGEN_STRUCT_TAG_MAX)
    return 0;
  memcpy(g_codegen_struct_tags_w110[g_codegen_struct_tag_n_w110], tag, (size_t)tlen + 1);
  g_codegen_struct_tag_n_w110++;
  return 1;
}

static int32_t pipeline_codegen_out_append_bytes_w110(void *out, const uint8_t *p, int32_t n) {
  int32_t len;
  uint8_t *data;
  int32_t i;
  if (!out || !p || n < 0)
    return -1;
  len = codegen_out_buf_len(out);
  if (len + n > (int32_t)PIPELINE_CODEGEN_OUTBUF_CAP)
    return -1;
  data = (uint8_t *)out;
  for (i = 0; i < n; i++)
    data[len + i] = p[i];
  codegen_out_buf_set_len(out, len + n);
  return 0;
}

static int32_t pipeline_codegen_out_append_byte_w110(void *out, uint8_t b) {
  return pipeline_codegen_out_append_bytes_w110(out, &b, 1);
}

static int32_t pipeline_codegen_out_format_int_w110(void *out, int32_t val) {
  char buf[16];
  int n;
  if (!out)
    return -1;
  n = snprintf(buf, sizeof(buf), "%d", (int)val);
  if (n <= 0 || n >= (int)sizeof(buf))
    return -1;
  return pipeline_codegen_out_append_bytes_w110(out, (const uint8_t *)buf, n);
}

extern int32_t pipeline_codegen_type_kind_copy(uint8_t *dst, int32_t cap, int32_t kind);
extern int32_t pipeline_codegen_vector_type_copy(uint8_t *dst, int32_t cap, int32_t elem_kind, int32_t lanes);
extern int32_t pipeline_codegen_type_to_c_repr(void *arena, uint8_t *scratch, int32_t cap, int32_t type_ref,
                                              uint8_t *struct_prefix, int32_t struct_prefix_len);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t type_ref);
extern int32_t pipeline_type_elem_ref_at(void *arena, int32_t type_ref);
extern int32_t pipeline_type_array_size_at(void *arena, int32_t type_ref);
extern int32_t pipeline_type_named_name_into(void *arena, int32_t ref, uint8_t *out64);

static int32_t pipeline_codegen_emit_struct_field_type_inner_w110(void *arena, void *out, int32_t type_ref,
                                                                  uint8_t *struct_prefix, int32_t struct_prefix_len) {
  /* PLATFORM: SHARED — twin of runtime_pipeline_abi.x inner scratch 896.
   * Product hybrid live: WEAK .x owns emit_struct_field_type (TYPE_SLICE
   * cap 896). This leftover is cold-when-pure-FROM_X-object-not-linked.
   * Caller cap 256 failed nest 16 TYPE_SLICE field tags (393). nest 64
   * i32 tag=782 fits 896. G.7: complete existing w110 inner; do not fork
   * a second field-type emitter. vector_type_copy / type_kind_copy stay
   * 256 (short C names; match .x). */
  static uint8_t scratch[896];
  int32_t ord;
  int32_t inner;
  int32_t asz;
  int32_t ik;
  int32_t lanes_v;
  int32_t nl;
  int32_t sn;
  uint8_t nm[256];

  ord = pipeline_type_kind_ord_at(arena, type_ref);
  if (!arena || type_ref <= 0 || ord < 0) {
    static const uint8_t k_i32[7] = {'i', 'n', 't', '3', '2', '_', 't'};
    return pipeline_codegen_out_append_bytes_w110(out, k_i32, 7);
  }
  if (ord == 9) {
    inner = pipeline_type_elem_ref_at(arena, type_ref);
    if (pipeline_codegen_emit_struct_field_type_inner_w110(arena, out, inner, struct_prefix, struct_prefix_len) != 0)
      return -1;
    if (pipeline_codegen_out_append_byte_w110(out, (uint8_t)' ') != 0)
      return -1;
    return pipeline_codegen_out_append_byte_w110(out, (uint8_t)'*');
  }
  if (ord == 10) {
    inner = pipeline_type_elem_ref_at(arena, type_ref);
    asz = pipeline_type_array_size_at(arena, type_ref);
    if (pipeline_codegen_emit_struct_field_type_inner_w110(arena, out, inner, struct_prefix, struct_prefix_len) != 0)
      return -1;
    if (pipeline_codegen_out_append_byte_w110(out, (uint8_t)'[') != 0)
      return -1;
    if (pipeline_codegen_out_format_int_w110(out, asz) != 0)
      return -1;
    return pipeline_codegen_out_append_byte_w110(out, (uint8_t)']');
  }
  if (ord == 8) {
    static const uint8_t hdr[7] = {'s', 't', 'r', 'u', 'c', 't', ' '};
    nl = pipeline_type_named_name_into(arena, type_ref, nm);
    if (nl <= 0) {
      static const uint8_t k_i32[7] = {'i', 'n', 't', '3', '2', '_', 't'};
      return pipeline_codegen_out_append_bytes_w110(out, k_i32, 7);
    }
    if (pipeline_codegen_out_append_bytes_w110(out, hdr, 7) != 0)
      return -1;
    if (struct_prefix && struct_prefix_len > 0) {
      if (pipeline_codegen_out_append_bytes_w110(out, struct_prefix, struct_prefix_len) != 0)
        return -1;
    }
    return pipeline_codegen_out_append_bytes_w110(out, nm, nl);
  }
  if (ord == 11) {
    nl = pipeline_codegen_type_to_c_repr(arena, scratch, 896, type_ref, struct_prefix, struct_prefix_len);
    if (nl <= 0)
      return -1;
    return pipeline_codegen_out_append_bytes_w110(out, scratch, nl);
  }
  if (ord == 12) {
    inner = pipeline_type_elem_ref_at(arena, type_ref);
    return pipeline_codegen_emit_struct_field_type_inner_w110(arena, out, inner, struct_prefix, struct_prefix_len);
  }
  if (ord == 13) {
    lanes_v = pipeline_type_array_size_at(arena, type_ref);
    inner = pipeline_type_elem_ref_at(arena, type_ref);
    ik = pipeline_type_kind_ord_at(arena, inner);
    sn = pipeline_codegen_vector_type_copy(scratch, 256, ik, lanes_v);
    if (sn > 0)
      return pipeline_codegen_out_append_bytes_w110(out, scratch, sn);
    sn = pipeline_codegen_type_kind_copy(scratch, 256, 0);
    if (sn > 0)
      return pipeline_codegen_out_append_bytes_w110(out, scratch, sn);
    return -1;
  }
  sn = pipeline_codegen_type_kind_copy(scratch, 256, ord);
  if (sn > 0)
    return pipeline_codegen_out_append_bytes_w110(out, scratch, sn);
  sn = pipeline_codegen_type_kind_copy(scratch, 256, 0);
  if (sn > 0)
    return pipeline_codegen_out_append_bytes_w110(out, scratch, sn);
  return -1;
}

int32_t pipeline_codegen_emit_struct_field_type(void *arena, void *out, int32_t type_ref, uint8_t *struct_prefix,
                                               int32_t struct_prefix_len) {
  return pipeline_codegen_emit_struct_field_type_inner_w110(arena, out, type_ref, struct_prefix, struct_prefix_len);
}

int32_t pipeline_codegen_emit_struct_field_decl(void *arena, void *out, int32_t type_ref, uint8_t *field_name,
                                                int32_t field_name_len, uint8_t *struct_prefix,
                                                int32_t struct_prefix_len) {
  int32_t base_type_ref;
  int32_t dims[8];
  int32_t ndim;
  int32_t i;

  if (!arena || !out || type_ref <= 0 || !field_name || field_name_len <= 0)
    return -1;

  base_type_ref = type_ref;
  ndim = 0;
  while (base_type_ref > 0 && pipeline_type_kind_ord_at(arena, base_type_ref) == 10 && ndim < 8) {
    dims[ndim] = pipeline_type_array_size_at(arena, base_type_ref);
    base_type_ref = pipeline_type_elem_ref_at(arena, base_type_ref);
    ndim++;
  }

  if (pipeline_codegen_emit_struct_field_type_inner_w110(arena, out, base_type_ref, struct_prefix, struct_prefix_len) != 0)
    return -1;
  if (pipeline_codegen_out_append_byte_w110(out, (uint8_t)' ') != 0)
    return -1;
  if (pipeline_codegen_out_append_bytes_w110(out, field_name, field_name_len) != 0)
    return -1;
  for (i = 0; i < ndim; i++) {
    if (pipeline_codegen_out_append_byte_w110(out, (uint8_t)'[') != 0)
      return -1;
    if (pipeline_codegen_out_format_int_w110(out, dims[i]) != 0)
      return -1;
    if (pipeline_codegen_out_append_byte_w110(out, (uint8_t)']') != 0)
      return -1;
  }
  return 0;
}


/* wave111 codegen_dep leave cold twins — former pipeline_codegen_dep.c.
 * Product hybrid PREFER: pure runtime_pipeline_abi.x owns strong orchestration.
 * Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X from wave101 leave twins.
 * PLATFORM: SHARED — cold only when pure FROM_X object is not linked.
 */

/* Cap residual faces not yet declared earlier in this cold block. */
extern int32_t pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst);
extern void *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern void *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t pipeline_dep_ctx_use_asm_backend(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern void pipeline_dep_ctx_set_import_path(void *ctx, int32_t idx, uint8_t *path, int32_t len);
extern void ast_pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_Module *m);
extern void ast_pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_ASTArena *a);
extern int32_t pipeline_module_num_funcs(void *m);
extern int32_t driver_dep_slot_for_path(const char *path);
extern uint8_t *driver_dep_module_buf(int32_t i);
extern uint8_t *driver_dep_arena_buf(int32_t i);
extern int pipeline_codegen_std_dep_link_only(uint8_t *path);
extern int32_t asm_asm_codegen_ast(void *module, void *arena, void *out_buf, void *ctx);
extern int32_t codegen_codegen_x_ast(void *module, void *arena, void *out_buf, void *ctx, int32_t dep_index);
extern void driver_set_current_dep_path_for_codegen(const char *path);
extern void driver_diagnostic_after_dep_codegen(int32_t j, int32_t out_len);
extern void driver_diagnostic_codegen_fail(int32_t dep_index, int32_t is_dep);
extern int32_t driver_skip_codegen_dep_0_get(void);
extern void driver_diagnostic_entry_already(int32_t v);
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern void driver_diagnostic_entry_module(void *module, void *arena);
extern int32_t parser_copy_module_import_path64(void *module, int32_t i, uint8_t out[128]);
extern int32_t pipeline_resolve_path_x(void *ctx, uint8_t *import_path, int32_t path_len);

static int32_t pipeline_dep_ctx_has_earlier_same_import_path_c_w111(struct ast_PipelineDepCtx *ctx, int32_t dep_j) {
  int32_t path_len, prev_j;
  uint8_t path_buf[256];
  if (!ctx || dep_j <= 0)
    return 0;
  path_len = pipeline_dep_ctx_import_path_len(ctx, dep_j);
  if (path_len <= 0 || path_len > (int32_t)sizeof(path_buf))
    return 0;
  memset(path_buf, 0, sizeof(path_buf));
  pipeline_dep_ctx_import_path_copy64(ctx, dep_j, path_buf);
  for (prev_j = 0; prev_j < dep_j; prev_j++) {
    int32_t prev_len = pipeline_dep_ctx_import_path_len(ctx, prev_j);
    uint8_t prev_buf[256];
    if (prev_len == path_len && prev_len > 0 && prev_len <= (int32_t)sizeof(prev_buf)) {
      memset(prev_buf, 0, sizeof(prev_buf));
      pipeline_dep_ctx_import_path_copy64(ctx, prev_j, prev_buf);
      if (memcmp(prev_buf, path_buf, (size_t)path_len) == 0)
        return 1;
    }
  }
  return 0;
}

int32_t run_x_pipeline_codegen_one_dep_emit(void *dep_mod, void *out_buf, void *ctx_v, int32_t dep_j,
                                            int32_t skip_asm_dep_codegen, int32_t use_asm_backend) {
  struct ast_PipelineDepCtx *ctx = (struct ast_PipelineDepCtx *)ctx_v;
  uint8_t dep_path_buf[256];
  void *mod = dep_mod;
  if (!out_buf || !ctx || dep_j < 0)
    return -1;
  if (pipeline_dep_ctx_has_earlier_same_import_path_c_w111(ctx, dep_j) != 0)
    return 0;
  memset(dep_path_buf, 0, sizeof(dep_path_buf));
  pipeline_dep_ctx_import_path_copy64(ctx, dep_j, dep_path_buf);
  if (!mod) {
    int32_t sync_slot = driver_dep_slot_for_path((const char *)dep_path_buf);
    if (sync_slot < 0)
      sync_slot = dep_j;
    mod = driver_dep_module_buf(sync_slot);
    if (mod) {
      ast_pipeline_dep_ctx_set_module(ctx, dep_j, (struct ast_Module *)mod);
      ast_pipeline_dep_ctx_set_arena(ctx, dep_j, (struct ast_ASTArena *)driver_dep_arena_buf(sync_slot));
    }
  }
  if (pipeline_codegen_dep_skip_x_bootstrap_partial(dep_path_buf) != 0)
    return 0;
  if (pipeline_codegen_std_dep_link_only(dep_path_buf) != 0)
    return 0;
  if (skip_asm_dep_codegen != 0)
    return 0;
  /* Host-C: co-emit when nf>0 or nlets>0 (consts-only file-static A/K).
   * Asm stays nf>0-only: asm_asm_codegen_ast hoists lets into main.
   * LP64: Module.num_top_level_lets @ offset 12 (≡ pipe_mod_get_num_top_level_lets).
   * PLATFORM: SHARED — seed twin of runtime_pipeline_abi.x same commit. */
  if (mod && (pipeline_module_num_funcs(mod) > 0 ||
              (use_asm_backend == 0 && *(int32_t *)((char *)mod + 12) > 0))) {
    void *arena_j = pipeline_dep_ctx_arena_at(ctx, dep_j);
    if (use_asm_backend != 0) {
      if (asm_asm_codegen_ast(mod, arena_j, out_buf, ctx) != 0)
        return -6;
    } else if (codegen_codegen_x_ast(mod, arena_j, out_buf, ctx, dep_j) != 0) {
      return -6;
    }
  }
  return 0;
}

int32_t run_x_pipeline_codegen_entry_emit(void *module, void *arena, void *out_buf, void *ctx,
                                          int32_t use_asm_backend) {
  if (!module || !arena || !out_buf || !ctx)
    return -1;
  if (use_asm_backend != 0) {
    if (asm_asm_codegen_ast(module, arena, out_buf, ctx) != 0)
      return -6;
  } else if (codegen_codegen_x_ast(module, arena, out_buf, ctx, -1) != 0) {
    return -6;
  }
  return 0;
}

int32_t run_x_pipeline_parse_entry_if_needed_c(void *module, void *arena, uint8_t *source_data,
                                               size_t source_len, void *ctx_v) {
  struct ast_PipelineDepCtx *ctx = (struct ast_PipelineDepCtx *)ctx_v;
  if (!module || !arena || !ctx)
    return -1;
  driver_diagnostic_entry_already(pipeline_dep_ctx_entry_already_parsed(ctx));
  if (pipeline_dep_ctx_entry_already_parsed(ctx) != 0) {
    driver_diagnostic_after_entry_parse(pipeline_module_num_funcs(module));
    driver_diagnostic_entry_module(module, arena);
    return 0;
  }
  return run_x_pipeline_parse_entry_do_parse_c(module, arena, source_data, source_len, ctx);
}

int32_t pipeline_fill_dep_import_path_from_buf_c(void *ctx, int32_t dep_j, uint8_t *path_buf) {
  int32_t path_len = 0;
  if (!ctx || !path_buf || dep_j < 0)
    return -1;
  while (path_len < 127 && path_buf[path_len] != 0)
    path_len++;
  if (path_len > 0)
    pipeline_dep_ctx_set_import_path(ctx, dep_j, path_buf, path_len);
  return 0;
}

int32_t pipeline_resolve_path_x_from_buf64_c(void *ctx, uint8_t *path_buf) {
  int32_t path_len = 0;
  if (!ctx || !path_buf)
    return -1;
  while (path_len < 127 && path_buf[path_len] != 0)
    path_len++;
  if (path_len <= 0)
    return -1;
  return pipeline_resolve_path_x(ctx, path_buf, path_len);
}

int32_t run_x_pipeline_fill_dep_import_path_c(void *module, void *ctx_v, int32_t dep_j) {
  struct ast_PipelineDepCtx *ctx = (struct ast_PipelineDepCtx *)ctx_v;
  uint8_t path_buf[128];
  int32_t path_len = 0;
  int32_t existing;
  if (!module || !ctx || dep_j < 0)
    return -1;
  existing = pipeline_dep_ctx_import_path_len(ctx, dep_j);
  if (existing > 0)
    return 0;
  memset(path_buf, 0, sizeof(path_buf));
  (void)parser_copy_module_import_path64(module, dep_j, path_buf);
  while (path_len < 127 && path_buf[path_len] != 0)
    path_len++;
  if (path_len > 0)
    pipeline_dep_ctx_set_import_path(ctx, dep_j, path_buf, path_len);
  return 0;
}

int32_t pipeline_prepare_dep_codegen_path_c(void *ctx_v, int32_t dep_j, uint8_t *dst) {
  struct ast_PipelineDepCtx *ctx = (struct ast_PipelineDepCtx *)ctx_v;
  if (!ctx || !dst || dep_j < 0)
    return -1;
  pipeline_dep_ctx_import_path_copy64(ctx, dep_j, dst);
  driver_set_current_dep_path_for_codegen((const char *)dst);
  return 0;
}

int32_t pipeline_finish_dep_codegen_diag_c(int32_t dep_j, void *out_buf) {
  if (!out_buf)
    return -1;
  driver_diagnostic_after_dep_codegen(dep_j, codegen_out_buf_len(out_buf));
  driver_set_current_dep_path_for_codegen(NULL);
  return 0;
}

int32_t run_x_pipeline_codegen_one_dep_c(void *module, void *out_buf, void *ctx_v, int32_t dep_j,
                                         int32_t skip_asm_dep_codegen) {
  struct ast_PipelineDepCtx *ctx = (struct ast_PipelineDepCtx *)ctx_v;
  /* >=256: import_path_copy64 clears 256 (AST name[256] world, Cap 4.2.8);
   * 128 smashes the canary (2026-09-13 L4 std/string SIGABRT). */
  uint8_t dep_path_buf[256];
  void *dep_mod;
  int32_t use_asm;
  if (!module || !out_buf || !ctx || dep_j < 0)
    return -1;
  if (dep_j == 0 && driver_skip_codegen_dep_0_get() != 0)
    return 0;
  if (run_x_pipeline_fill_dep_import_path_c(module, ctx, dep_j) != 0)
    return -1;
  memset(dep_path_buf, 0, sizeof(dep_path_buf));
  pipeline_prepare_dep_codegen_path_c(ctx, dep_j, dep_path_buf);
  dep_mod = pipeline_dep_ctx_module_at(ctx, dep_j);
  if (!dep_mod) {
    int32_t sync_slot = driver_dep_slot_for_path((const char *)dep_path_buf);
    if (sync_slot < 0)
      sync_slot = dep_j;
    dep_mod = driver_dep_module_buf(sync_slot);
    if (dep_mod) {
      ast_pipeline_dep_ctx_set_module(ctx, dep_j, (struct ast_Module *)dep_mod);
      ast_pipeline_dep_ctx_set_arena(ctx, dep_j, (struct ast_ASTArena *)driver_dep_arena_buf(sync_slot));
    }
  }
  if (pipeline_codegen_dep_skip_x_bootstrap_partial(dep_path_buf) != 0) {
    driver_set_current_dep_path_for_codegen(NULL);
    return 0;
  }
  use_asm = pipeline_dep_ctx_use_asm_backend(ctx);
  if (run_x_pipeline_codegen_one_dep_emit(dep_mod, out_buf, ctx, dep_j, skip_asm_dep_codegen, use_asm) != 0) {
    driver_diagnostic_codegen_fail(dep_j, 1);
    return -6;
  }
  pipeline_finish_dep_codegen_diag_c(dep_j, out_buf);
  return 0;
}

static void *g_codegen_entry_arena_for_mono_w111;

void *pipeline_codegen_entry_arena_for_mono_get(void) {
  return g_codegen_entry_arena_for_mono_w111;
}

int32_t run_x_pipeline_codegen_deps_c(void *module, void *arena, void *out_buf, void *ctx_v,
                                      int32_t skip_asm_dep_codegen) {
  struct ast_PipelineDepCtx *ctx = (struct ast_PipelineDepCtx *)ctx_v;
  int32_t ndep, j;
  if (!module || !arena || !out_buf || !ctx)
    return -1;
  g_codegen_entry_arena_for_mono_w111 = arena;
  pipeline_codegen_c_file_prologue_done_reset();
  ndep = pipeline_dep_ctx_ndep(ctx);
  for (j = 0; j < ndep; j++) {
    if (pipeline_dep_ctx_has_earlier_same_import_path_c_w111(ctx, j) != 0)
      continue;
    if (run_x_pipeline_codegen_one_dep_c(module, out_buf, ctx, j, skip_asm_dep_codegen) != 0)
      return -6;
  }
  return 0;
}

int32_t run_x_pipeline_codegen_entry_c(void *module, void *arena, void *out_buf, void *ctx_v) {
  struct ast_PipelineDepCtx *ctx = (struct ast_PipelineDepCtx *)ctx_v;
  if (!module || !arena || !out_buf || !ctx)
    return -1;
  driver_diagnostic_entry_module(module, arena);
  if (run_x_pipeline_codegen_entry_emit(module, arena, out_buf, ctx, pipeline_dep_ctx_use_asm_backend(ctx)) != 0) {
    driver_diagnostic_codegen_fail(0, 0);
    return -6;
  }
  return 0;
}

/* wave112 parse_typeck_dispatch leave cold twins — former pipeline_parse_typeck_dispatch.c.
 * Product hybrid PREFER: pure runtime_pipeline_abi.x owns strong faces.
 * Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X from wave101 leave twins.
 * Cap residual result_c / impl_rc live always in pipeline_parse_orch.c.
 * PLATFORM: SHARED — cold only when pure FROM_X object is not linked.
 */

extern int32_t pipeline_parse_into_with_init_buf_impl_rc(struct ast_ASTArena *arena, struct ast_Module *module,
                                                         uint8_t *data, int32_t len, int32_t *out_ok,
                                                         int32_t *out_main_idx);
extern int32_t pipeline_driver_x_pipeline_skip_typeck(void);
extern int32_t pipeline_driver_asm_build_skip_typeck(void);
extern int32_t pipeline_dep_ctx_asm_entry_module_only(struct ast_PipelineDepCtx *ctx);
extern void pipeline_typeck_set_active_ctx_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx);
extern void pipeline_typeck_set_dep_ctx(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_scan_module_struct_stack_escape_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                                 struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_unused_private_funcs(struct ast_Module *m, struct ast_ASTArena *a);
extern int32_t typeck_typeck_x_ast(struct ast_Module *module, struct ast_ASTArena *arena, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_typeck_x_ast_library(struct ast_Module *module, struct ast_ASTArena *arena,
                                            struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_module_main_func_index(struct ast_Module *m);
extern void pipeline_module_set_main_func_index(struct ast_Module *m, int32_t idx);
extern void pipeline_lint_set_source_buf(const uint8_t *data, int32_t len);
extern void driver_diagnostic_parse_fail(int32_t main_idx, int32_t num_funcs, int32_t arena_num_types);
extern void driver_diagnostic_typeck_fail(void);
extern int32_t pipeline_arena_num_types(struct ast_ASTArena *a);
extern int32_t pipeline_module_num_funcs(void *m);
extern int32_t parser_get_module_num_imports(struct ast_Module *module);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern void pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx *ctx, int32_t n);
extern void pipeline_dep_ctx_set_import_path(void *ctx, int32_t idx, uint8_t *path, int32_t len);
extern void *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern void pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_Module *m);
extern void pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_ASTArena *a);
extern int32_t pipeline_try_bind_seeded_import(struct ast_PipelineDepCtx *ctx, int32_t import_idx, int32_t global_slot);
extern int32_t pipeline_load_import_from_disk_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                struct ast_PipelineDepCtx *ctx, int32_t import_idx);
extern int32_t pipeline_sync_dep_slots_from_driver_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx);
extern void typeck_typeck_merge_dep_struct_layouts_into_entry(struct ast_Module *mod, struct ast_ASTArena *arena,
                                                              struct ast_PipelineDepCtx *ctx);
extern void typeck_typeck_wpo_unify_soa_layouts(struct ast_Module *entry, struct ast_PipelineDepCtx *ctx);
extern int32_t driver_dep_seeded_get(int32_t i);
extern const char *driver_dep_path_registry_at(int32_t i);
extern uint8_t *driver_dep_module_buf(int32_t i);
extern uint8_t *driver_dep_arena_buf(int32_t i);
extern int32_t driver_dep_slot_for_path(const char *path);
extern int32_t parser_copy_module_import_path64(void *module, int32_t i, uint8_t out[128]);
extern int32_t pipeline_resolve_path_x(void *ctx, uint8_t *import_path, int32_t path_len);
extern int32_t pipeline_read_file_x(void *ctx);

static int32_t g_pipeline_parse_scalars_ok_w112;
static int32_t g_pipeline_parse_scalars_main_idx_w112;

int32_t pipeline_parse_scalars_ok_get(void) {
  return g_pipeline_parse_scalars_ok_w112;
}

int32_t pipeline_parse_scalars_main_idx_get(void) {
  return g_pipeline_parse_scalars_main_idx_w112;
}

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

void pipeline_parse_fail_diag_scalars_c(struct ast_Module *module, struct ast_ASTArena *arena) {
  if (!module || !arena)
    return;
  driver_diagnostic_parse_fail(g_pipeline_parse_scalars_main_idx_w112, pipeline_module_num_funcs(module),
                               pipeline_arena_num_types(arena));
}

int32_t pipeline_parse_into_with_init_buf_scalars(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *data,
                                                   int32_t len, int32_t *out_ok, int32_t *out_main_idx) {
  int32_t ok = 1;
  int32_t main_idx = -1;
  if (!arena || !module || !data || len <= 0) {
    g_pipeline_parse_scalars_ok_w112 = 1;
    g_pipeline_parse_scalars_main_idx_w112 = -1;
    if (out_ok)
      *out_ok = 1;
    if (out_main_idx)
      *out_main_idx = -1;
    return 0;
  }
  (void)pipeline_parse_into_with_init_buf_impl_rc(arena, module, data, len, &ok, &main_idx);
  g_pipeline_parse_scalars_ok_w112 = ok;
  g_pipeline_parse_scalars_main_idx_w112 = main_idx;
  if (out_ok)
    *out_ok = ok;
  if (out_main_idx)
    *out_main_idx = main_idx;
  return 0;
}

int32_t pipeline_parse_into_with_init_buf_scalars_sidecar(struct ast_ASTArena *arena, struct ast_Module *module,
                                                          uint8_t *data, int32_t len) {
  return pipeline_parse_into_with_init_buf_scalars(arena, module, data, len, NULL, NULL);
}

int32_t pipeline_parse_into_with_init_slice_scalars_sidecar(struct ast_ASTArena *arena, struct ast_Module *module,
                                                             struct xlang_slice_uint8_t *source) {
  if (!source || !source->data || source->length == 0)
    return pipeline_parse_into_with_init_buf_scalars(arena, module, NULL, 0, NULL, NULL);
  if (source->length > (size_t)2147483647)
    return pipeline_parse_into_with_init_buf_scalars(arena, module, source->data, 2147483647, NULL, NULL);
  return pipeline_parse_into_with_init_buf_scalars(arena, module, source->data, (int32_t)source->length, NULL, NULL);
}

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

int32_t pipeline_parse_set_main_from_buf_c(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *data,
                                           int32_t len) {
  int32_t ok;
  int32_t main_idx;
  if (!module || !arena || !data || len <= 0)
    return -2;
  pipeline_lint_set_source_buf(data, len);
  pipeline_parse_into_with_init_buf_scalars(arena, module, data, len, &ok, &main_idx);
  if (ok != 0) {
    driver_diagnostic_parse_fail(main_idx, pipeline_module_num_funcs(module), pipeline_arena_num_types(arena));
    return -2;
  }
  pipeline_module_set_main_func_index(module, main_idx);
  return 0;
}

int32_t pipeline_typeck_parsed_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                        struct ast_PipelineDepCtx *ctx, int32_t fail_mapped) {
  if (!module || !arena || !ctx) {
    if (fail_mapped != 0)
      return fail_mapped;
    return -1;
  }
  if (pipeline_module_num_funcs(module) == 0)
    pipeline_module_set_main_func_index(module, -1);
  pipeline_typeck_set_active_ctx_c(module, ctx);
  pipeline_typeck_set_dep_ctx(ctx);
  if (pipeline_module_main_func_index(module) < 0) {
    int32_t tc_lib = typeck_typeck_x_ast_library(module, arena, ctx);
    if (tc_lib != 0) {
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

int32_t pipeline_typeck_entry_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                       struct ast_PipelineDepCtx *ctx) {
  if (!module || !arena || !ctx)
    return -1;
  return pipeline_typeck_parsed_module_c(module, arena, ctx, 0);
}

void pipeline_dep_ctx_realign_ndep_for_entry_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx) {
  int32_t n_imp;
  int32_t ndep;
  if (!module || !ctx)
    return;
  n_imp = parser_get_module_num_imports(module);
  ndep = pipeline_dep_ctx_ndep(ctx);
  if (ndep == n_imp)
    return;
  if (ndep > n_imp)
    return;
  pipeline_dep_ctx_set_ndep(ctx, 0);
}

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

int32_t pipeline_load_one_import_slot_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                        struct ast_PipelineDepCtx *ctx, int32_t import_idx) {
  uint8_t path_buf[128];
  int32_t gs;
  if (!module || !arena || !ctx || import_idx < 0)
    return -1;
  memset(path_buf, 0, sizeof(path_buf));
  (void)parser_copy_module_import_path64(module, import_idx, path_buf);
  gs = driver_dep_slot_for_path((const char *)path_buf);
  if (pipeline_try_bind_seeded_import(ctx, import_idx, gs) != 0)
    return 0;
  return pipeline_load_import_from_disk_c(module, arena, ctx, import_idx);
}

int32_t pipeline_load_and_sync_direct_import_deps_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    struct ast_PipelineDepCtx *ctx) {
  int32_t n_imports;
  int32_t i;
  int32_t rc;
  int32_t sync_rc;
  uint8_t path_buf[128];
  if (!module || !arena || !ctx)
    return -1;
  n_imports = parser_get_module_num_imports(module);
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
      if (pipeline_try_bind_seeded_import(ctx, i, driver_dep_slot_for_path((const char *)path_buf)) != 0)
        continue;
      rc = pipeline_load_import_from_disk_c(module, arena, ctx, i);
      if (rc != 0)
        return rc;
    }
    pipeline_dep_ctx_set_ndep(ctx, n_imports);
  } else if (n_imports > 0) {
    int32_t cur_ndep = pipeline_dep_ctx_ndep(ctx);
    if (cur_ndep > n_imports) {
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
      for (i = 0; i < n_imports; i++) {
        int32_t pl = 0;
        memset(path_buf, 0, sizeof(path_buf));
        (void)parser_copy_module_import_path64(module, i, path_buf);
        while (pl < 64 && path_buf[pl] != 0)
          pl = pl + 1;
        if (pl > 0)
          pipeline_dep_ctx_set_import_path(ctx, i, path_buf, pl);
        if (pipeline_try_bind_seeded_import(ctx, i, driver_dep_slot_for_path((const char *)path_buf)) != 0)
          continue;
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
  {
    int32_t all_seeded = (n_imports > 0) ? 1 : 0;
    for (i = 0; i < n_imports; i++) {
      int32_t gs;
      memset(path_buf, 0, sizeof(path_buf));
      (void)parser_copy_module_import_path64(module, i, path_buf);
      gs = driver_dep_slot_for_path((const char *)path_buf);
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

/* wave113 backend_asm_wrapper leave cold twins — former pipeline_backend_asm_wrapper.c.
 * Product hybrid PREFER: pure runtime_pipeline_abi.x owns strong faces.
 * Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X from wave101 leave twins.
 * PLATFORM: SHARED — cold only when pure FROM_X object is not linked.
 */

extern void pipeline_module_hoist_top_level_lets_into_main(struct ast_Module *m, struct ast_ASTArena *a);
extern int32_t backend_asm_codegen_ast_seed_mega(struct ast_Module *m, struct ast_ASTArena *a, void *out,
                                                 struct ast_PipelineDepCtx *pipeline_ctx);
extern void pipeline_asm_emit_set_elf_ctx(void *elf_ctx);
extern void pipeline_asm_emit_set_dep_pipe(struct ast_PipelineDepCtx *ctx);
extern void pipeline_asm_emit_set_module(struct ast_Module *m);
extern void pipeline_asm_emit_set_arena(struct ast_ASTArena *arena);
extern void glue_wpo_mono_reset_pending(void);
extern void pipeline_elf_label_mod_scope_begin_module(void);
extern int32_t pipeline_backend_asm_codegen_ast_to_elf_mega_body_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                                   void *elf_ctx,
                                                                   struct ast_PipelineDepCtx *pipeline_ctx);
extern int32_t pipeline_asm_emit_wpo_mono_thunks_elf_c(struct ast_Module *m, struct ast_ASTArena *a, void *elf_ctx,
                                                      struct ast_PipelineDepCtx *pipeline_ctx);
extern void pipeline_fill_array_lit_types_for_skipped_typeck(struct ast_Module *m, struct ast_ASTArena *arena);
extern void typeck_soa_fill_field_access_for_asm_emit(struct ast_Module *m, struct ast_ASTArena *arena);
extern void pipeline_debug_trace_named_func_bodies(const char *phase, void *module, void *arena);
/**
 * F7: emit per-impl vtable statics + wrapper functions (backend_call_dispatch.x).
 * PLATFORM: SHARED — G.7 twin of codegen_emit_module_vtable_statics.
 */
extern int32_t pipeline_asm_emit_module_vtable_statics(void *elf_ctx, int32_t ta,
                                                       void *module, void *arena);

int32_t pipeline_backend_asm_codegen_ast_c(struct ast_Module *m, struct ast_ASTArena *a, void *out,
                                            struct ast_PipelineDepCtx *pipeline_ctx) {
  if (!m || !a || !out || !pipeline_ctx)
    return -1;
  if (m->num_top_level_lets > 0)
    pipeline_module_hoist_top_level_lets_into_main(m, a);
  return backend_asm_codegen_ast_seed_mega(m, a, out, pipeline_ctx);
}

int32_t pipeline_backend_asm_codegen_ast_to_elf_c(struct ast_Module *m, struct ast_ASTArena *a, void *elf_ctx,
                                                   struct ast_PipelineDepCtx *pipeline_ctx) {
  int32_t rc;
  if (!m || !a || !elf_ctx || !pipeline_ctx)
    return -1;
  /* F7: reset data section buffer at module start (single-threaded; vtable statics emit here). */
  pipeline_elf_ctx_reset_data((uint8_t *)elf_ctx);
  pipeline_debug_trace_named_func_bodies("backend_pre_hoist_top_level_lets", m, a);
  if (m->num_top_level_lets > 0)
    pipeline_module_hoist_top_level_lets_into_main(m, a);
  pipeline_debug_trace_named_func_bodies("backend_post_hoist_top_level_lets", m, a);
  pipeline_debug_trace_named_func_bodies("backend_pre_merge_dep_layouts", m, a);
  typeck_typeck_merge_dep_struct_layouts_into_entry(m, a, pipeline_ctx);
  pipeline_debug_trace_named_func_bodies("backend_post_merge_dep_layouts", m, a);
  typeck_typeck_wpo_unify_soa_layouts(m, pipeline_ctx);
  pipeline_debug_trace_named_func_bodies("backend_post_unify_soa_layouts", m, a);
  pipeline_asm_emit_set_dep_pipe(pipeline_ctx);
  pipeline_fill_array_lit_types_for_skipped_typeck(m, a);
  /* F7: emit per-impl vtable statics + wrapper functions before regular funcs.
   * Must run after SoA merge (layout ready) and before mega_body (func emit).
   * PLATFORM: SHARED — G.7 twin of codegen_emit_module_vtable_statics. */
  {
    int32_t ta_vtable = pipeline_dep_ctx_target_arch(pipeline_ctx);
    int32_t vt_rc = pipeline_asm_emit_module_vtable_statics(elf_ctx, ta_vtable, m, a);
    if (vt_rc != 0)
      return vt_rc;
  }
  typeck_soa_fill_field_access_for_asm_emit(m, a);
  glue_wpo_mono_reset_pending();
  pipeline_elf_label_mod_scope_begin_module();
  pipeline_asm_emit_set_module(m);
  pipeline_asm_emit_set_arena(a);
  pipeline_asm_emit_set_elf_ctx(elf_ctx);
  rc = pipeline_backend_asm_codegen_ast_to_elf_mega_body_c(m, a, elf_ctx, pipeline_ctx);
  pipeline_asm_emit_set_elf_ctx(NULL);
  if (rc != 0)
    return rc;
  return pipeline_asm_emit_wpo_mono_thunks_elf_c(m, a, elf_ctx, pipeline_ctx);
}

/* wave114 asm_ctx_loop leave cold twins — former pipeline_asm_ctx_loop.c.
 * Product hybrid PREFER: pure runtime_pipeline_abi.x owns strong faces.
 * Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X. Fixed caps match pure:
 * 64 ctx slots, depth 8, label 64B rows, be_cont 24 × 128B end labels.
 * PLATFORM: SHARED — cold only when pure FROM_X object is not linked.
 */
#define WAVE114_LOOP_SC_MAX 64
#define WAVE114_LOOP_DEPTH_MAX 8
#define WAVE114_LOOP_LABEL_W 64
#define WAVE114_LOOP_STACK (WAVE114_LOOP_DEPTH_MAX * WAVE114_LOOP_LABEL_W)
#define WAVE114_BE_CONT_MAX 24
#define WAVE114_BE_END_W 128

static int32_t wave114_loop_used[WAVE114_LOOP_SC_MAX];
static uint8_t *wave114_loop_ctx[WAVE114_LOOP_SC_MAX];
static int32_t wave114_loop_depth[WAVE114_LOOP_SC_MAX];
static uint8_t wave114_loop_break[WAVE114_LOOP_SC_MAX * WAVE114_LOOP_STACK];
static int32_t wave114_loop_break_lens[WAVE114_LOOP_SC_MAX * WAVE114_LOOP_DEPTH_MAX];
static uint8_t wave114_loop_cont[WAVE114_LOOP_SC_MAX * WAVE114_LOOP_STACK];
static int32_t wave114_loop_cont_lens[WAVE114_LOOP_SC_MAX * WAVE114_LOOP_DEPTH_MAX];
static int32_t wave114_be_cont_depth;
static int32_t wave114_be_cont_block[WAVE114_BE_CONT_MAX];
static int32_t wave114_be_cont_stmt[WAVE114_BE_CONT_MAX];
static int32_t wave114_be_cont_end_len[WAVE114_BE_CONT_MAX];
static uint8_t wave114_be_cont_end[WAVE114_BE_CONT_MAX * WAVE114_BE_END_W];

static int32_t wave114_loop_sc_find(uint8_t *ctx, int create) {
  int i;
  if (!ctx)
    return -1;
  for (i = 0; i < WAVE114_LOOP_SC_MAX; i++) {
    if (wave114_loop_used[i] && wave114_loop_ctx[i] == ctx)
      return i;
  }
  if (!create)
    return -1;
  for (i = 0; i < WAVE114_LOOP_SC_MAX; i++) {
    if (!wave114_loop_used[i]) {
      wave114_loop_used[i] = 1;
      wave114_loop_ctx[i] = ctx;
      wave114_loop_depth[i] = 0;
      return i;
    }
  }
  return -1;
}

void asm_ctx_loop_reset(uint8_t *ctx) {
  int32_t s = wave114_loop_sc_find(ctx, 0);
  if (s < 0)
    return;
  wave114_loop_depth[s] = 0;
}

int32_t asm_ctx_loop_push(uint8_t *ctx, uint8_t *exit_buf, int32_t exit_len, uint8_t *loop_buf, int32_t loop_len) {
  int32_t s, d, base, sc_base, k, n, m;
  if (!ctx || !exit_buf || !loop_buf || exit_len < 0 || loop_len < 0)
    return -1;
  s = wave114_loop_sc_find(ctx, 1);
  if (s < 0)
    return -1;
  d = wave114_loop_depth[s];
  if (d >= WAVE114_LOOP_DEPTH_MAX)
    return -1;
  base = d * WAVE114_LOOP_LABEL_W;
  sc_base = s * WAVE114_LOOP_STACK;
  n = exit_len > WAVE114_LOOP_LABEL_W ? WAVE114_LOOP_LABEL_W : exit_len;
  for (k = 0; k < n; k++)
    wave114_loop_break[sc_base + base + k] = exit_buf[k];
  wave114_loop_break_lens[s * WAVE114_LOOP_DEPTH_MAX + d] = exit_len;
  m = loop_len > WAVE114_LOOP_LABEL_W ? WAVE114_LOOP_LABEL_W : loop_len;
  for (k = 0; k < m; k++)
    wave114_loop_cont[sc_base + base + k] = loop_buf[k];
  wave114_loop_cont_lens[s * WAVE114_LOOP_DEPTH_MAX + d] = loop_len;
  wave114_loop_depth[s] = d + 1;
  return 0;
}

void asm_ctx_loop_pop(uint8_t *ctx, uint8_t *break_out, int32_t break_cap, int32_t *break_len_out,
                      uint8_t *cont_out, int32_t cont_cap, int32_t *cont_len_out) {
  int32_t s, d, prev, base, sc_base, k, bl, cl, bn, cn;
  if (break_len_out)
    *break_len_out = 0;
  if (cont_len_out)
    *cont_len_out = 0;
  if (!ctx || (s = wave114_loop_sc_find(ctx, 0)) < 0 || wave114_loop_depth[s] <= 0)
    return;
  wave114_loop_depth[s]--;
  d = wave114_loop_depth[s];
  if (d <= 0)
    return;
  prev = d - 1;
  base = prev * WAVE114_LOOP_LABEL_W;
  sc_base = s * WAVE114_LOOP_STACK;
  bl = wave114_loop_break_lens[s * WAVE114_LOOP_DEPTH_MAX + prev];
  cl = wave114_loop_cont_lens[s * WAVE114_LOOP_DEPTH_MAX + prev];
  if (break_out && break_len_out && break_cap > 0) {
    bn = bl > break_cap - 1 ? break_cap - 1 : bl;
    for (k = 0; k < bn; k++)
      break_out[k] = wave114_loop_break[sc_base + base + k];
    *break_len_out = bl;
  }
  if (cont_out && cont_len_out && cont_cap > 0) {
    cn = cl > cont_cap - 1 ? cont_cap - 1 : cl;
    for (k = 0; k < cn; k++)
      cont_out[k] = wave114_loop_cont[sc_base + base + k];
    *cont_len_out = cl;
  }
}

int32_t asm_ctx_loop_depth(uint8_t *ctx) {
  int32_t s = wave114_loop_sc_find(ctx, 0);
  return s < 0 ? 0 : wave114_loop_depth[s];
}

void asm_be_cont_reset(void) {
  wave114_be_cont_depth = 0;
}

int32_t asm_be_cont_suspend(int32_t block_ref, int32_t stmt_i, uint8_t *end_lbl, int32_t end_len) {
  int32_t d, k, n, base;
  if (wave114_be_cont_depth >= WAVE114_BE_CONT_MAX || !end_lbl || end_len < 0)
    return -1;
  d = wave114_be_cont_depth++;
  wave114_be_cont_block[d] = block_ref;
  wave114_be_cont_stmt[d] = stmt_i;
  if (end_len == 0) {
    wave114_be_cont_end_len[d] = 0;
    return 0;
  }
  n = end_len > 64 ? 64 : end_len;
  base = d * WAVE114_BE_END_W;
  for (k = 0; k < n; k++)
    wave114_be_cont_end[base + k] = end_lbl[k];
  wave114_be_cont_end_len[d] = end_len;
  return 0;
}

int32_t asm_be_cont_resume(int32_t *out_block, int32_t *out_stmt_i, uint8_t *out_end, int32_t end_cap,
                           int32_t *out_end_len) {
  int32_t d, k, n, base;
  if (wave114_be_cont_depth <= 0)
    return 0;
  d = --wave114_be_cont_depth;
  if (out_block)
    *out_block = wave114_be_cont_block[d];
  if (out_stmt_i)
    *out_stmt_i = wave114_be_cont_stmt[d];
  if (out_end_len)
    *out_end_len = wave114_be_cont_end_len[d];
  if (out_end && end_cap > 0 && out_end_len) {
    n = wave114_be_cont_end_len[d];
    if (n > end_cap - 1)
      n = end_cap - 1;
    base = d * WAVE114_BE_END_W;
    for (k = 0; k < n; k++)
      out_end[k] = wave114_be_cont_end[base + k];
  }
  return 1;
}

int32_t asm_be_cont_depth(void) {
  return wave114_be_cont_depth;
}

/* wave115 asm_selfhost leave cold twins — former pipeline_asm_selfhost.c.
 * Product hybrid PREFER: pure runtime_pipeline_abi.x owns strong faces.
 * Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X. Semantics ≡ pure:
 * num_defined / defined_ordinal + 9 is_* predicates via module accessors
 * (no m->num_funcs field; incomplete Module safe under cold seed).
 * PLATFORM: SHARED — cold only when pure FROM_X object is not linked.
 */
extern int32_t pipeline_module_num_funcs(void *module);
extern int32_t pipeline_module_func_name_equal_at(void *m, int32_t fi, uint8_t *name, int32_t name_len);
extern int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t fi);

int32_t asm_module_num_defined_funcs(void *m) {
  int32_t i, n = 0, nfuncs;
  if (!m)
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_asm_module_func_is_extern_at(m, i) == 0)
      n++;
  }
  return n;
}

int32_t asm_module_defined_func_ordinal(void *m, int32_t func_index) {
  int32_t i, ord = 0, nfuncs;
  if (!m || func_index < 0)
    return -1;
  nfuncs = pipeline_module_num_funcs(m);
  if (func_index >= nfuncs)
    return -1;
  if (pipeline_asm_module_func_is_extern_at(m, func_index) != 0)
    return -1;
  for (i = 0; i < func_index; i++) {
    if (pipeline_asm_module_func_is_extern_at(m, i) == 0)
      ord++;
  }
  return ord;
}

int32_t asm_module_is_backend_selfhost(void *m) {
  int32_t i, nfuncs;
  if (!m)
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs < 80)
    return 0;
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"asm_codegen_ast", 15))
      return 1;
  }
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"emit_expr_elf", 13))
      return 1;
  }
  return 0;
}

/* Stage 12.0.5 G.7: positive name probes only — bare ndef∈[75,155]|[160,180]
 * false-positive'd Cap residual runtime slices (rt_run_asm_backend: ~125 extern
 * + 75 defined → ret0-stub every body under pure-asm). Cold twin ≡ .x.
 * PLATFORM: SHARED. */
int32_t asm_module_is_typeck_selfhost(void *m) {
  int32_t i, nfuncs;
  if (!m)
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs < 40)
    return 0;
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"ast_arena_init", 14))
      return 0;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"ast_placeholder", 15))
      return 0;
  }
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"pipeline_module_reset_parse_counters", 36))
      return 0;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"parse_into_init", 15))
      return 0;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"skip_one_struct_into_buf", 24))
      return 0;
  }
  if (pipeline_module_func_name_equal_at(m, 0, (uint8_t *)"type_kind_ordinal", 17))
    return 1;
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"type_kind_ordinal", 17))
      return 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"typeck_x_ast", 12))
      return 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"check_expr", 10))
      return 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"check_expr_impl", 15))
      return 1;
  }
  return 0;
}

int32_t asm_module_is_pipeline_selfhost(void *m) {
  int32_t i, nfuncs, has_resolve, has_marker;
  if (!m)
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs < 12)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_typeck_selfhost(m))
    return 0;
  has_resolve = 0;
  has_marker = 0;
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"resolve_path_x", 15))
      has_resolve = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"pipeline_should_skip_x_typeck", 30))
      has_marker = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"path_append_from_buf_256", 24))
      has_marker = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"read_file_x", 12))
      has_marker = 1;
  }
  return has_resolve != 0 && has_marker != 0;
}

int32_t asm_module_is_parser_selfhost(void *m) {
  int32_t i, nfuncs, has_parse_marker, has_reset;
  if (!m)
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs < 150 || nfuncs > 1450)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_pipeline_selfhost(m))
    return 0;
  has_parse_marker = 0;
  has_reset = 0;
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"pipeline_module_reset_parse_counters", 36))
      has_reset = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"parse_into_init", 15))
      has_parse_marker = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"parse_into_set_main_index", 25))
      has_parse_marker = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"skip_one_struct_into_buf", 24))
      has_parse_marker = 1;
  }
  if (has_reset != 0 && has_parse_marker == 0 && nfuncs >= 200)
    has_parse_marker = 1;
  if (has_reset == 0)
    return 0;
  if (asm_module_is_typeck_selfhost(m) && has_parse_marker == 0)
    return 0;
  return has_parse_marker != 0;
}

int32_t asm_module_is_parser_emit_heavy(void *m) {
  int32_t i, nfuncs;
  if (!m)
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs < 150 || nfuncs > 1450)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_pipeline_selfhost(m))
    return 0;
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"pipeline_module_reset_parse_counters", 36))
      return 1;
  }
  return asm_module_is_parser_selfhost(m);
}

int32_t asm_module_is_main_driver_selfhost(void *m) {
  int32_t i, nfuncs, has_entry, has_run_path, ndef;
  if (!m)
    return 0;
  ndef = asm_module_num_defined_funcs(m);
  if (ndef < 12 || ndef > 48)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_typeck_selfhost(m) ||
      asm_module_is_pipeline_selfhost(m) || asm_module_is_parser_selfhost(m))
    return 0;
  has_entry = 0;
  has_run_path = 0;
  nfuncs = pipeline_module_num_funcs(m);
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"entry", 5))
      has_entry = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"main_run_compiler_x_path_impl", 29) ||
        pipeline_module_func_name_equal_at(m, i, (uint8_t *)"run_compiler_x_path_impl", 24))
      has_run_path = 1;
  }
  return has_entry != 0 && has_run_path != 0;
}

int32_t asm_module_is_driver_compile_selfhost(void *m) {
  int32_t i, nfuncs, has_parse_argv, has_entry;
  if (!m)
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs < 8 || nfuncs > 120)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_typeck_selfhost(m) ||
      asm_module_is_pipeline_selfhost(m) || asm_module_is_parser_selfhost(m))
    return 0;
  has_parse_argv = 0;
  has_entry = 0;
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"driver_compile_parse_argv", 25))
      has_parse_argv = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"run_compiler_full_x", 19))
      has_entry = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"compile_dispatch_asm_backend", 28))
      has_parse_argv = 1;
  }
  return has_parse_argv != 0 && has_entry != 0;
}

int32_t asm_module_is_ast_selfhost(void *m) {
  int32_t i, nfuncs, has_arena_init, has_placeholder;
  if (!m)
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs < 15 || nfuncs > 250)
    return 0;
  has_arena_init = 0;
  has_placeholder = 0;
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"ast_arena_init", 14))
      has_arena_init = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"ast_placeholder", 15))
      has_placeholder = 1;
  }
  if (has_arena_init == 0 || has_placeholder == 0)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_pipeline_selfhost(m) ||
      asm_module_is_parser_selfhost(m))
    return 0;
  return 1;
}

int32_t asm_module_is_compiler_selfhost(void *m) {
  return asm_module_is_ast_selfhost(m) || asm_module_is_backend_selfhost(m) ||
         asm_module_is_typeck_selfhost(m) || asm_module_is_pipeline_selfhost(m) ||
         asm_module_is_parser_selfhost(m) || asm_module_is_parser_emit_heavy(m) ||
         asm_module_is_driver_compile_selfhost(m) || asm_module_is_main_driver_selfhost(m);
}


/* wave116 asm_thin_delegate leave cold twins — former pipeline_asm_thin_delegate.c.
 * Product hybrid PREFER: pure runtime_pipeline_abi.x owns the 4 strong faces.
 * Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X. Semantics ≡ pure:
 * backend/pipeline/driver/typeck m8-tail thin delegate C-name lookup. The parser
 * table + its accessor stayed host-cc in pipeline_asm_parser_emit_heavy.c (not here).
 * PLATFORM: SHARED — cold only when pure FROM_X object is not linked. */
extern int32_t pipeline_module_func_name_equal_at(void *m, int32_t fi, uint8_t *name, int32_t name_len);
extern int32_t pipeline_module_func_name_len_at(void *m, int32_t fi);
extern void    pipeline_asm_module_func_name_copy64(void *m, int32_t fi, uint8_t *dst);
extern int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t fi);
extern int32_t asm_env_entry_emit_heavy(void);
/* asm_module_is_{pipeline,driver_compile,typeck}_selfhost: cold twins defined above. */
typedef struct {
  const char *x_name;
  int32_t x_len;
  const char *c_name;
  int32_t c_len;
} AsmBackendThinDelegateRow;

static const AsmBackendThinDelegateRow k_asm_backend_thin_delegate[] = {
    {"fill_param_slots", 16, "pipeline_asm_fill_param_slots", 29},
    {"fill_local_slots", 16, "pipeline_asm_fill_local_slots", 29},
    {"compute_frame_size", 18, "pipeline_asm_compute_frame_size_c", 33},
    {"emit_block_body_elf", 19, "backend_emit_block_body_sync_elf", 32},
    {"emit_block_inits_elf", 20, "pipeline_asm_emit_block_inits_elf_c", 35},
    {"emit_if_then_block_body_elf", 27, "pipeline_asm_emit_if_then_block_body_elf_c", 42},
    {"emit_while_loop_elf", 18, "pipeline_asm_emit_while_loop_elf_c", 34},
    {"emit_for_loop_elf", 16, "pipeline_asm_emit_for_loop_elf_c", 32},
    {"emit_loop_body_content", 22, "pipeline_asm_emit_loop_body_content_c", 35},
    {"emit_loop_body_content_elf", 26, "pipeline_asm_emit_loop_body_content_elf_c", 39},
    {"emit_next_label", 15, "pipeline_asm_emit_next_label_c", 30},
    {"format_label_id", 15, "pipeline_asm_format_label_id_c", 30},
    {"emit_expr_elf_call", 18, "pipeline_asm_emit_call_elf_c", 28},
    {"emit_expr_elf_method_call", 25, "pipeline_asm_emit_method_call_elf_c", 35},
    {"asm_emit_call_args_elf", 22, "pipeline_asm_emit_call_args_elf_c", 33},
    {"emit_block_inits", 16, "pipeline_asm_emit_block_inits_c", 31},
    {"emit_block_body", 15, "pipeline_asm_emit_block_body_c", 30},
    {"emit_while_loop", 15, "pipeline_asm_emit_while_loop_c", 30},
    {"emit_for_loop", 13, "pipeline_asm_emit_for_loop_c", 28},
    {"emit_if_then_block_body_text", 28, "pipeline_asm_emit_if_then_block_body_text_c", 43},
    {"emit_expr", 9, "pipeline_asm_emit_expr_c", 24},
    {"emit_expr_call", 14, "pipeline_asm_emit_expr_call_c", 29},
    {"emit_expr_method_call", 21, "pipeline_asm_emit_expr_method_call_c", 36},
    {"emit_expr_elf", 13, "pipeline_asm_emit_expr_elf_c", 28},
    {"emit_index_eff_addr_text", 24, "pipeline_asm_emit_index_eff_addr_text_c", 39},
    {"emit_index_eff_addr_elf", 23, "pipeline_asm_emit_index_eff_addr_elf_c", 38},
    {"emit_lvalue_eff_addr_text", 25, "pipeline_asm_emit_lvalue_eff_addr_text_c", 40},
    {"emit_lvalue_eff_addr_elf", 24, "pipeline_asm_emit_lvalue_eff_addr_elf_c", 39},
    {"asm_emit_call_args_text", 23, "pipeline_asm_emit_call_args_text_c", 33},
    {"local_offset", 12, "pipeline_asm_local_offset_c", 27},
    {"asm_resolve_whole_import_qualified_symbol", 41, "pipeline_asm_resolve_whole_import_qualified_symbol_c", 52},
    {"emit_skip_heavy_stub_elf", 24, "pipeline_asm_emit_skip_heavy_stub_elf_c", 39},
    {"simd_try_inline_shuffle_call_elf", 32, "pipeline_asm_simd_try_inline_shuffle_call_elf_c", 47},
    {"simd_try_inline_select_call_elf", 31, "pipeline_asm_simd_try_inline_select_call_elf_c", 46},
    {"simd_try_inline_binop2_call_elf", 31, "pipeline_asm_simd_try_inline_binop2_call_elf_c", 46},
    {"simd_try_inline_fma3_call_elf", 29, "pipeline_asm_simd_try_inline_fma3_call_elf_c", 46},
    {"asm_codegen_ast", 15, "pipeline_backend_asm_codegen_ast_c", 34},
    {"asm_codegen_ast_to_elf", 22, "pipeline_backend_asm_codegen_ast_to_elf_c", 41},
};

/**
 * 查 backend 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_backend_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                  int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0)
    return 0;
  nrows = (int32_t)(sizeof(k_asm_backend_thin_delegate) / sizeof(k_asm_backend_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_backend_thin_delegate[i].x_name,
                                           k_asm_backend_thin_delegate[i].x_len)) {
      if (k_asm_backend_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_backend_thin_delegate[i].c_name, (size_t)k_asm_backend_thin_delegate[i].c_len);
      out[k_asm_backend_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_backend_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}

/** M8-tail：parse/typecheck entry 薄 bl→C（do_parse 仍 X emit 调 set_main thin→C）。 */
static const AsmBackendThinDelegateRow k_asm_pipeline_thin_delegate[] = {
    {"pipeline_parse_set_main_from_buf", 32, "pipeline_parse_set_main_from_buf_c", 34},
    {"pipeline_should_skip_x_typeck", 30, "pipeline_should_skip_x_typeck_c", 32},
    {"run_x_pipeline_typecheck_entry", 31, "run_x_pipeline_typecheck_entry_emit_c", 36},
};

/**
 * 查 pipeline 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_pipeline_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                   int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0 || !asm_module_is_pipeline_selfhost(m))
    return 0;
  nrows = (int32_t)(sizeof(k_asm_pipeline_thin_delegate) / sizeof(k_asm_pipeline_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_pipeline_thin_delegate[i].x_name,
                                           k_asm_pipeline_thin_delegate[i].x_len)) {
      if (k_asm_pipeline_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_pipeline_thin_delegate[i].c_name, (size_t)k_asm_pipeline_thin_delegate[i].c_len);
      out[k_asm_pipeline_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_pipeline_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}


/* ── driver / typeck M8-tail 薄委托表（补全五表域；历史自 ast_pool.c 抽出，live in runtime_pipeline_abi）── */
/* k_asm_driver_thin_delegate + k_asm_typeck_thin_delegate 及其 m8 查找符号。 */

/** M8-tail：driver compile 薄 bl 表已空；run_compiler_full_x* 堆 state + X post_parse 真 emit。 */
static const AsmBackendThinDelegateRow k_asm_driver_thin_delegate[] = {
};

/**
 * 查 driver/compile.x 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_driver_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                 int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0 || !asm_module_is_driver_compile_selfhost(m))
    return 0;
  nrows = (int32_t)(sizeof(k_asm_driver_thin_delegate) / sizeof(k_asm_driver_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_driver_thin_delegate[i].x_name,
                                           k_asm_driver_thin_delegate[i].x_len)) {
      if (k_asm_driver_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_driver_thin_delegate[i].c_name, (size_t)k_asm_driver_thin_delegate[i].c_len);
      out[k_asm_driver_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_driver_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}

/** typeck EMIT_HEAVY 薄委托：仅剩须 C 维持的入口（typeck 主体已 X emit）。 */
static const AsmBackendThinDelegateRow k_asm_typeck_thin_delegate[] = {
};

/**
 * typeck EMIT_HEAVY 第二遍：SKIP 桩路径 bl→C 委托或 typeck_x.o 同名实现（首遍 SKIP 仍 ret0）。
 * 实参已在 ABI 寄存器；Mach-O 由 backend_enc_call_arch 加 leading `_`。
 */
int32_t asm_typeck_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                 int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  int32_t nl;

  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0)
    return 0;
  if (!asm_module_is_typeck_selfhost(m) || asm_env_entry_emit_heavy() == 0)
    return 0;
  if (pipeline_asm_module_func_is_extern_at(m, func_index) != 0)
    return 0;
  nrows = (int32_t)(sizeof(k_asm_typeck_thin_delegate) / sizeof(k_asm_typeck_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_typeck_thin_delegate[i].x_name,
                                           k_asm_typeck_thin_delegate[i].x_len)) {
      if (k_asm_typeck_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_typeck_thin_delegate[i].c_name, (size_t)k_asm_typeck_thin_delegate[i].c_len);
      out[k_asm_typeck_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_typeck_thin_delegate[i].c_len;
      return 1;
    }
  }
  nl = pipeline_module_func_name_len_at(m, func_index);
  if (nl <= 0 || nl >= out_cap)
    return 0;
  pipeline_asm_module_func_name_copy64(m, func_index, out);
  out[nl] = 0;
  *out_len = nl;
  return 1;
}


/* wave117 asm emit_heavy safe-helper leave cold twins — former pipeline_asm_emit_heavy_safe_helper.c.
 * Product hybrid PREFER: pure runtime_pipeline_abi.x owns the 9 strong faces.
 * Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X. Semantics ≡ pure:
 * 9 EMIT_HEAVY 2nd-pass per-module name classifiers. C macros kept (seed is C).
 * Residual accessors extern; asm_module_is_*_selfhost cold twins defined above.
 * PLATFORM: SHARED — cold only when pure FROM_X object is not linked. */
extern int32_t pipeline_module_func_name_equal_at(void *m, int32_t fi, uint8_t *name, int32_t name_len);
extern int32_t pipeline_module_func_name_has_prefix_at(void *m, int32_t fi, const char *pfx, int32_t plen);
static int32_t asm_typeck_emit_heavy_safe_helper(void *m, int32_t func_index) {
  if (!m || func_index < 0)
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_kind_ordinal", 17))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"name_equal", 10))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "ensure_", 7))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "find_or_alloc_", 14))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_field_offset_from_layout", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_field_type_ref_from_layout", 30))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_name", 18))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_field_name", 24))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_import_path_slice", 24))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_import_binding_name", 26))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_import_select_name", 25))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_top_level_let_name", 25))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_find_layout_idx", 22))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_x_named_builtin_", 24))
    return 1;
  /** §11.1 align/size：layout 命中走 C glue，X 真 emit 递归/array 分支（勿 metrics depth slot）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_align", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_size", 19))
    return 1;
  /** §11.1 metrics：scratch 预绑定 + typeck_i32_ptr_store 写 out；槽位≤96 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_struct_layout_metrics", 28))
    return 1;
  /** import 合并 / struct_lit 登记：scratch 预绑定 + glue 读 num_struct_layouts。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_merge_dep_struct_layouts_into_entry", 42))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_wpo_unify_soa_layouts", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_ensure_primitive_by_kind_ord", 35))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_find_or_alloc_compound_type_ref", 38))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"ensure_struct_layout_from_struct_lit", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_dep_return_type_in_caller_arena", 35))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"dep_return_type_to_caller_arena", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_field_offset_from_layout_deps", 33))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_field_type_ref_from_layout_deps", 35))
    return 1;
  /** FIELD_ACCESS 内联池字段 / Expr 标量回落：小 helper X 真 emit（layout_deps/name_fallback 已真 emit）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_inline_u8_64_array_field_type_ref", 40))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_expr_inline_array_field_type_ref", 39))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"expr_field_access_fallback_scalar_type_ref", 42))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_field_access_lexer_wrapper_fallback", 42))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"entry_module_find_struct_layout_index", 37))
    return 1;
  /** ord>45 小 helper：import 路径分段 / diag 追加 / 隐式 return 判定 / parent 链 patch。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_import_path_segment_count", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_import_segment_at", 24))
    return 1;
  /** ord>58：diag 缓冲追加（小循环体；fmt_* 仍 mega 桩）。 */
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_diag_append_", 19))
    return 1;
  /** diag fmt 族：glue 读类型池 + 局部序数；勿 ast_arena_type_get 按值 Type。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_diag_fmt_type_at", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_diag_fmt_type_into", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_diag_fmt_type_or_question", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_resolve_scan_dep_with_apply", 34))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_return_type", 31))
    return 1;
  /** 隐式尾返回判定：tail ref 扫描 + ast_expr_disallows_implicit_tail（patch 4096 后 X 真 emit）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"func_body_tail_expr_ref_for_implicit_rule", 41))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"func_body_has_implicit_return_tail", 34))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_binop", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_binop_cmp", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_method_call", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_method_call_arg", 33))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_as", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_struct_lit", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_struct_lit_field", 34))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_field_access", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_const", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_let", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_while", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_for", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_if", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_final", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_binop_arith", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"find_func_return_type_in_module", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"find_func_return_type_in_module_by_name", 39))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_whole_import_qualified_call_return_type", 47))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_binding_import_return_type", 39))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_select_import_return_type", 38))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_local_module", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_try_whole_import", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_try_binding_import", 38))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_scan_dep", 28))
    return 1;
  /** S2 X 真 emit：expr/type 小 helper（glue 指针读池；勿 Type 按值 ast_arena_type_get）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"expr_type_ref", 13))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_ref_is_bool", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_ref_is_bool_impl", 21))
    return 1;
  /** type_refs_equal 薄包装可 X emit；拆分 named/same_kind/impl 逐步 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_refs_equal", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_refs_equal_impl", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_return_operand_matches", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_integer_widen_ok", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"expr_var_name_equal_func", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_ret_coerce_integral_to_expect_i32", 40))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_ret_coerce_integral_widen", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_expr_to_decl", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_refs_equal_named", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_refs_equal_same_kind", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_lit_to_decl", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_enum_field_to_decl", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_float_lit_to_decl", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_stamp_resolved_args_float_lit", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_named_call_to_decl", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_array_vector_lit_to_decl", 43))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_vector_binop_to_decl", 39))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_slice_from_array", 35))
    return 1;
  /** validate 薄循环：metrics/align/size 仍 mega/thin stub（独立 X emit SIGSEGV）；本函数 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_validate_struct_layouts_zero_padding", 43))
    return 1;
  /** typeck_x_ast 薄入口见 mega_entry；check_block 薄 guard 仍 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block", 11))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block_as_loop_body", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_loop_depth_push", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_loop_depth_pop", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_patch_all_body_parent_links", 34))
    return 1;
  /** check_expr/check_block 薄 guard→check_*_impl；impl/mega 走 asm_skip_heavy_typeck_mega_entry 桩。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr", 10))
    return 1;
  /** check_expr mega 分派子 helper（assign/index/unary/addr/deref/var/return/panic）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_expr_is_any_assign_kind", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_assign", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_index", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_unary", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_addr_of", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_deref", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_var", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_return", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_panic", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_break_continue", 32))
    return 1;
  /** check_block_impl 编排子 helper（stmt_order/impl 主体 mega 桩）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_consts", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_lets", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_whiles", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_fors", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_ifs", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_expr_stmts", 36))
    return 1;
  /** check_expr_impl 小 kind 子 helper（impl/mega 主体 mega 桩）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_int_lit", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_bool_lit", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_float_lit", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_enum_variant", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_block", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_if_ternary", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_match", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_match_arm", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_call", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_call_arg", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_call_resolve", 30))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_", 14))
    return 0;
  return 0;
}

/**
 * pipeline EMIT_HEAVY 第二遍：编排 helper X 真 emit；parse/typecheck 关键路径 thin→C（strict smoke）。
 * S3：resolve/read 经 weak→强符号 dispatch（build_asm 覆盖 impl_c）。
 */
static int32_t asm_pipeline_emit_heavy_safe_helper(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_pipeline_selfhost(m))
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_one_function_ok", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_should_skip_x_typeck", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_loaded_buf_cap", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_parse_entry_if_needed", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_typecheck_entry", 31))
    return 1;
  /** parse set_main + typeck 分派：if(CALL) 模式 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_parse_set_main_from_buf", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_typeck_parsed_module", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_typeck_entry_module", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_fill_dep_import_path", 36))
    return 1;
  /** import 路径含 '.' 探测：纯 while，无 let=CALL。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_import_has_dot", 27))
    return 1;
  /** 单 import resolve+read：X 栈 path + if(CALL!=0) return。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_load_import_resolve_read", 33))
    return 1;
  /** 单 import 全链 resolve/read/preprocess/parse；X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_load_import_from_disk", 30))
    return 1;
  /** 单 import 槽 bind 或 load_from_disk；X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_load_one_import_slot", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_prepare_dep_codegen_path", 33))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_finish_dep_codegen_diag", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_parse_entry_do_parse", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_codegen_one_dep", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_codegen_entry", 29))
    return 1;
  /** sync 入口：null 检查 + 有界 while(CALL!=0) + if(sync_one) X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_sync_dep_slots_from_driver", 35))
    return 1;
  /** dep 批量 codegen：有界 while + run_x_pipeline_codegen_one_dep X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_codegen_deps", 28))
    return 1;
  /** load/sync deps：import 有界 while + sync/typeck merge X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_load_and_sync_direct_import_deps", 41))
    return 1;
  /** resolve 编排：lib_root while + try_* CALL（try_* 仍 thin→C）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_x", 15))
    return 1;
  /** resolve try_*：sidecar off + if(CALL) 模式 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_try_one_lib_root", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_try_entry_dir", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_try_flat_import_under_lib", 38))
    return 1;
  /** 完整流水线编排：run_x_pipeline_impl X 真 emit（if(CALL)+last_rc_get 模式）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_impl", 19))
    return 1;
  /** load/typecheck phase 编排 + last_rc sidecar。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_load_deps_after_parse", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_typecheck_after_load", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"lsp_diag_typeck_after_load", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"lsp_diag_parse_typeck_buf", 25))
    return 1;
  return 0;
}

/**
 * driver/compile.x EMIT_HEAVY 第二遍：argv 分 helper + dispatch X 真 emit；post_parse / run_compiler_full_x 仍桩。
 */
static int32_t asm_driver_compile_emit_heavy_safe_helper(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_driver_compile_selfhost(m))
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"compile_dispatch_asm_backend", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"compile_dispatch_emit_c_path", 28))
    return 1;
  /** driver_compile_gen.o 导出带 driver_ 前缀；module 表多为裸名，二者均匹配。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_dispatch_asm_backend", 35))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_dispatch_emit_c_path", 35))
    return 1;
  /** run_compiler_full_x* 大栈/复杂分派：EMIT_HEAVY 堆 state + post_parse/dispatch X 真 emit（thin 表已空）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_state_key", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_ensure_default_lib", 29))
    return 1;
  /** parse_argv 分 helper：init/step/loop/finalize/入口 X 真 emit（单函数双 512 栈数组 SIGSEGV）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_init", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_step", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_loop", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_finalize", 34))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_scan_c", 31))
    return 0;
  /** run_compiler_full_x / post_parse：堆 state + dispatch X 真 emit（勿 thin→impl_c）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_compiler_full_x", 19))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_compiler_full_x_post_parse", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_run_compiler_full_x", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_run_compiler_full_x_post_parse", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"path_ends_x", 12))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"target_has_arm", 14))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "eq_", 3))
    return 1;
  return 0;
}

/**
 * backend EMIT_HEAVY 第二遍：按符号名保留小 helper 真 emit（覆盖 #87+ 索引桩；219 func 模块中 arch_emit/enc 常在 #87 之后）。
 * M8-tail：fold_/asm_import_ 等前缀体 + 薄包装 C 委托函数按名放行。
 */
static int32_t asm_skip_heavy_backend_m8_helper_keep(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_backend_selfhost(m))
    return 0;
#define ASMB_M8_HLP_PREFIX(pfx, plen)                                                                                  \
  do {                                                                                                                 \
    if (pipeline_module_func_name_has_prefix_at(m, func_index, (pfx), (int32_t)(plen)))                                \
      return 1;                                                                                                        \
  } while (0)
  ASMB_M8_HLP_PREFIX("asm_import_", 11);
  ASMB_M8_HLP_PREFIX("asm_build_import_", 17);
  ASMB_M8_HLP_PREFIX("asm_c_prefix_", 13);
  ASMB_M8_HLP_PREFIX("fold_", 5);
  ASMB_M8_HLP_PREFIX("asm_module_named_", 17);
  ASMB_M8_HLP_PREFIX("asm_expr_binop_", 15);
  ASMB_M8_HLP_PREFIX("asm_field_access_", 17);
#undef ASMB_M8_HLP_PREFIX
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"ctx_push_loop_labels", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"ctx_pop_loop_labels", 19))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_hoist_top_level_lets_for_codegen", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"ctx_reset", 9))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"compute_frame_size", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf", 13))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"local_offset", 12))
    return 1;
  /** M8-tail：形参/局部槽与 ELF/text 块体薄包装（单行 C 委托），扩 backend.o __text。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"fill_param_slots", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"fill_local_slots", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_body_elf", 19))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_inits_elf", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_if_then_block_body_elf", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_while_loop_elf", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_for_loop_elf", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_loop_body_content", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_loop_body_content_elf", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_next_label", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"format_label_id", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf_call", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf_method_call", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_emit_call_args_elf", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_inits", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_body", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_while_loop", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_for_loop", 13))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_if_then_block_body_text", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr", 9))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_call", 14))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_method_call", 21))
    return 1;
  return 0;
}

/** 旧名别名：arch_emit_/enc_ 前缀 helper。 */
static int32_t asm_skip_heavy_backend_helper_keep(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_backend_selfhost(m))
    return 0;
#define ASMB_KEEP_PREFIX(pfx)                                                                                            \
  do {                                                                                                                 \
    if (pipeline_module_func_name_has_prefix_at(m, func_index, (pfx), (int32_t)(sizeof(pfx) - 1)))                     \
      return 1;                                                                                                        \
  } while (0)
  ASMB_KEEP_PREFIX("arch_emit_");
  ASMB_KEEP_PREFIX("enc_");
#undef ASMB_KEEP_PREFIX
  return 0;
}

/* ── EMIT_HEAVY 第二遍 backend/typeck mega + m8-tail skip 入口分类器（补全 skip_heavy 全集；自 ast_pool.c 抽出）── */

/**
 * M8-tail：backend 薄包装 helper 按名真 emit，须先于 #87+ 索引桩（emit_block_body_elf #179 等）。
 * 不含 fold_/asm_import_ 等前缀体，避免 Abort 带内误放行大函数。
 */
static int32_t asm_skip_heavy_backend_m8_tail_thin_keep(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_backend_selfhost(m))
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"fill_param_slots", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"fill_local_slots", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"compute_frame_size", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_body_elf", 19))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_inits_elf", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_if_then_block_body_elf", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_while_loop_elf", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_for_loop_elf", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_loop_body_content", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_loop_body_content_elf", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_next_label", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"format_label_id", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf_call", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf_method_call", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_emit_call_args_elf", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_inits", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_body", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_while_loop", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_for_loop", 13))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_if_then_block_body_text", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr", 9))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_call", 14))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_method_call", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_index_eff_addr_text", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_index_eff_addr_elf", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_lvalue_eff_addr_text", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_lvalue_eff_addr_elf", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_emit_call_args_text", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"local_offset", 12))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_resolve_whole_import_qualified_symbol", 41))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_skip_heavy_stub_elf", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"simd_try_inline_shuffle_call_elf", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"simd_try_inline_select_call_elf", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"simd_try_inline_binop2_call_elf", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"simd_try_inline_fma3_call_elf", 29))
    return 1;
  return 0;
}

/**
 * typeck EMIT_HEAVY 第二遍：layout/diag 小 helper 真 emit（ExprKind=51 已修；槽位过大仍走 mega/默认桩）。
 */
static int32_t asm_skip_heavy_typeck_helper_keep(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_typeck_selfhost(m))
    return 0;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_", 14))
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_align", 20) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_size", 19))
    return 0;
  return 0;
}

/**
 * backend 第二遍 EMIT_HEAVY：按符号名桩化 mega codegen/emit 入口（expr 树递归、块体、入口 asm_codegen_ast）。
 * 小 helper（arch_emit_*、try_fold_*、fill_param_slots 等）仍真 emit，扩 backend.o __text 且避免宿主栈 Abort。
 */
static int32_t asm_skip_heavy_backend_mega_entry(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_backend_selfhost(m))
    return 0;
#define ASMB_MEGA(name, nlen)                                                                                          \
  do {                                                                                                                 \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(name), (nlen)))                                  \
      return 1;                                                                                                        \
  } while (0)
  ASMB_MEGA("asm_codegen_ast", 15);
  ASMB_MEGA("asm_codegen_ast_to_elf", 22);
  ASMB_MEGA("asm_codegen_ast_seed_mega", 25);
  ASMB_MEGA("asm_codegen_ast_to_elf_seed_mega", 32);
  /** emit_expr / emit_block_* / loop / if-then / fill_* / call / local_offset：thin_keep 真 emit（C/partial 委托）。 */
  /** extern/C sidecar glue：.x 体含 ExprKind 54 等 asm 未支持形态，须桩化。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_ctx_key", 11))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "asm_ctx_local_", 14))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "asm_ctx_block_", 14))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "asm_ctx_loop_", 13))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "asm_ctx_ensure_", 15))
    return 1;
  return 0;
}

/** typeck 第二遍 emit：桩化巨型 typecheck/diag/implicit-return 入口；layout/helper 须真 emit 过 8KiB。 */
static int32_t asm_skip_heavy_typeck_mega_entry(void *m, int32_t func_index) {
  if (!m || func_index < 0)
    return 0;
  if (/** typeck_skip_heavy_selfhost 等 mega 入口仍桩化。 */
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_skip_heavy_selfhost_func_body", 36))
    return 1;
  /**
   * check_* mega：宿主编译器真 emit 会 SIGSEGV；EMIT_HEAVY 第二遍 ret0 桩。
   * 子 helper 经 asm_typeck_emit_heavy_safe_helper 分片 X 真 emit。
   */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr_impl_mega", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr_impl", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block_impl", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_stmt_order_one", 33))
    return 1;
  /** 遍历全模块函数：槽位高；EMIT_HEAVY 第二遍 ret0 桩（子 helper check_one_func 仍 X）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast_impl", 17))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast_library", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast_check_all_funcs_loop", 33))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast_check_one_func", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast", 12))
    return 1;
  /** type_kind_ordinal 在瘦 typeck #0 须真 emit；勿在此 mega 桩。 */
  return 0;
}

/* wave118 asm skip_dispatch leave cold twins — former pipeline_asm_skip_dispatch.c.
 * Product hybrid PREFER: pure runtime_pipeline_abi.x owns the 2 strong faces +
 * set_pipeline_ctx BSS. Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * void* module + Cap residual accessors only (no incomplete Module fields).
 * PLATFORM: SHARED — cold only when pure FROM_X object is not linked. */
extern int32_t pipeline_module_num_funcs(void *m);
extern int32_t pipeline_module_func_name_len_at(void *m, int32_t fi);
extern uint8_t pipeline_module_func_name_byte_at(void *m, int32_t fi, int32_t i);
extern int32_t xlang_module_num_imports(void *m);
extern int32_t pipeline_module_func_name_equal_at(void *m, int32_t fi, uint8_t *name, int32_t name_len);
extern int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_body_ref_at(void *m, int32_t fi);
extern int32_t asm_env_build_skip_typeck(void);
extern int32_t asm_env_entry_emit_heavy(void);
extern int32_t asm_skip_typeck_entry_whitelist(void *m, int32_t func_index);
extern int32_t driver_typeck_skip_large_entry(void);
extern int32_t pipeline_dep_ctx_asm_entry_module_only(void *ctx);
extern int32_t pipeline_dep_ctx_use_asm_backend(void *ctx);
extern int32_t asm_count_block_stack_slots(void *arena, int32_t block_ref);
extern int32_t asm_module_is_compiler_selfhost(void *m);
extern int32_t asm_module_is_ast_selfhost(void *m);
extern int32_t asm_module_is_typeck_selfhost(void *m);
extern int32_t asm_module_is_backend_selfhost(void *m);
extern int32_t asm_module_is_pipeline_selfhost(void *m);
extern int32_t asm_module_is_main_driver_selfhost(void *m);
extern int32_t asm_module_is_driver_compile_selfhost(void *m);
extern int32_t asm_module_is_parser_emit_heavy(void *m);
extern int32_t asm_module_num_defined_funcs(void *m);
extern int32_t asm_module_defined_func_ordinal(void *m, int32_t func_index);
extern int32_t asm_typeck_emit_heavy_safe_helper(void *m, int32_t func_index);
extern int32_t asm_pipeline_emit_heavy_safe_helper(void *m, int32_t func_index);
extern int32_t asm_driver_compile_emit_heavy_safe_helper(void *m, int32_t func_index);
extern int32_t asm_skip_heavy_backend_m8_helper_keep(void *m, int32_t func_index);
extern int32_t asm_skip_heavy_backend_helper_keep(void *m, int32_t func_index);
extern int32_t asm_skip_heavy_backend_m8_tail_thin_keep(void *m, int32_t func_index);
extern int32_t asm_skip_heavy_typeck_helper_keep(void *m, int32_t func_index);
extern int32_t asm_skip_heavy_backend_mega_entry(void *m, int32_t func_index);
extern int32_t asm_skip_heavy_typeck_mega_entry(void *m, int32_t func_index);
extern int32_t asm_skip_heavy_parser_mega_entry(void *m, int32_t func_index);
extern int32_t asm_parser_emit_heavy_bisect_max_index(void);
extern int32_t asm_parser_emit_heavy_safe_helper(void *m, int32_t func_index);
extern int32_t asm_parser_emit_heavy_force_stub(void *m, int32_t func_index);
extern int32_t asm_parser_func_is_thin_delegate(void *m, int32_t func_index);
extern int32_t asm_parser_emit_heavy_slot_max(void);
extern void asm_parser_emit_heavy_dbg_real(void *m, int32_t fi, const char *why);
extern int32_t asm_emit_heavy_abort_lo(void);
extern int32_t asm_emit_heavy_abort_hi(void);
extern int32_t pipeline_module_func_name_has_prefix_at(void *m, int32_t fi, const char *pfx, int32_t plen);

static void *g_asm_skip_pipeline_ctx_cold;

void asm_skip_heavy_set_pipeline_ctx(void *ctx) {
  g_asm_skip_pipeline_ctx_cold = ctx;
}

void asm_empty_text_stub_label(void *m, uint8_t *out, int32_t out_cap, int32_t *out_len) {
  uint32_t h = 2166136261u;
  int32_t i, k, nl, pos, d, nd;
  uint32_t v;
  uint8_t digits[16];
  static const uint8_t prefix[] = "_xlang_asm_stu_";
  if (!out || out_cap < 24 || !out_len) {
    if (out_len)
      *out_len = 0;
    return;
  }
  if (m && pipeline_module_num_funcs(m) > 0) {
    int32_t nfuncs = pipeline_module_num_funcs(m);
    for (i = 0; i < nfuncs; i++) {
      nl = pipeline_module_func_name_len_at(m, i);
      for (k = 0; k < nl; k++)
        h = (uint32_t)((h ^ (uint8_t)pipeline_module_func_name_byte_at(m, i, k)) * 16777619u);
    }
  } else {
    h ^= (uint32_t)(m ? xlang_module_num_imports(m) : 0);
    h *= 16777619u;
  }
  memcpy(out, prefix, sizeof(prefix) - 1);
  pos = (int32_t)(sizeof(prefix) - 1);
  nd = 0;
  v = h;
  if (v == 0)
    digits[nd++] = (uint8_t)'0';
  else {
    while (v > 0 && nd < 16) {
      digits[nd++] = (uint8_t)('0' + (v % 10));
      v /= 10;
    }
  }
  for (d = nd - 1; d >= 0; d--)
    out[pos++] = digits[d];
  out[pos] = 0;
  *out_len = pos;
}

int32_t asm_skip_heavy_module_func_body(void *m, void *arena, int32_t func_index) {
  int32_t body_ref;
  int32_t slots;
  int32_t slot_threshold;
  int32_t nfuncs;
  if (!m || func_index < 0)
    return 0;
  /* wave650: XLANG_ASM_FORCE_FULL_BODIES=1 — full-body escape for the
   * monofile pure-asm FORCE channel. The Stage 12.0.5 selfhost gates below
   * deliberately ret0-stub the tail of big selfhost modules (ordinal>=72,
   * slots>48) because the product hybrid takes those bodies from the C rest;
   * the FORCE chain replaces that rest, so the mono compile must emit every
   * body (remaining emit gaps then surface as loud CG002 instead of silent
   * stubs — the w648/w649 chase ended here, 72/2048 real). Default off =
   * zero product behavior change. Twin of pure asm_env_force_full_bodies.
   * PLATFORM: SHARED. */
  if (asm_env_force_full_bodies_cold())
    return 0;
  if (!asm_module_is_compiler_selfhost(m))
    return 0;
  if (asm_module_is_ast_selfhost(m) && asm_env_build_skip_typeck() != 0 && asm_env_entry_emit_heavy() == 0) {
    if (asm_skip_typeck_entry_whitelist(m, func_index) != 0)
      return 0;
    return 1;
  }
  if (g_asm_skip_pipeline_ctx_cold != NULL &&
      pipeline_dep_ctx_asm_entry_module_only(g_asm_skip_pipeline_ctx_cold) != 0 &&
      pipeline_dep_ctx_use_asm_backend(g_asm_skip_pipeline_ctx_cold) != 0 &&
      driver_typeck_skip_large_entry() == 0 &&
      asm_env_build_skip_typeck() == 0 &&
      asm_env_entry_emit_heavy() == 0) {
    return 0;
  }
  if (asm_env_build_skip_typeck() != 0 && asm_env_entry_emit_heavy() == 0) {
    if (pipeline_asm_module_func_is_extern_at(m, func_index) != 0)
      return 0;
    if (asm_skip_typeck_entry_whitelist(m, func_index) != 0)
      return 0;
    return 1;
  }
  nfuncs = pipeline_module_num_funcs(m);
  if (asm_env_build_skip_typeck() != 0 && asm_env_entry_emit_heavy() == 0 && nfuncs > 0 &&
      nfuncs <= 32 && func_index < 10)
    return 1;
  if (asm_env_entry_emit_heavy() == 0 &&
      (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr", 10) ||
       pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr_impl", 15) ||
       pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block", 11) ||
       pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block_impl", 16)))
    return 1;
  if (asm_env_entry_emit_heavy() != 0) {
    int32_t typeck_ndef = asm_module_is_typeck_selfhost(m) ? asm_module_num_defined_funcs(m) : 0;
    int32_t typeck_ord = asm_module_defined_func_ordinal(m, func_index);
    if (asm_module_is_parser_emit_heavy(m)) {
      if (asm_skip_heavy_parser_mega_entry(m, func_index) != 0)
        return 1;
      if (asm_parser_emit_heavy_bisect_max_index() == 0)
        return 1;
      if (asm_parser_emit_heavy_safe_helper(m, func_index) != 0) {
        asm_parser_emit_heavy_dbg_real(m, func_index, "safe_helper");
        return 0;
      }
      if (asm_parser_emit_heavy_force_stub(m, func_index) != 0)
        return 1;
      if (asm_parser_func_is_thin_delegate(m, func_index) != 0)
        return 1;
      if (func_index >= asm_parser_emit_heavy_bisect_max_index())
        return 1;
      body_ref = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref <= 0)
        return 1;
      slots = asm_count_block_stack_slots(arena, body_ref);
      if (slots > asm_parser_emit_heavy_slot_max())
        return 1;
      asm_parser_emit_heavy_dbg_real(m, func_index, "slot_fallback");
      return 0;
    }
    if (asm_module_is_typeck_selfhost(m) && typeck_ndef >= 160 && typeck_ndef <= 180) {
      if (typeck_ord < 0)
        return 1;
      if (asm_skip_heavy_typeck_mega_entry(m, func_index) != 0)
        return 1;
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      if (typeck_ord >= 118 && typeck_ord <= 159)
        return 1;
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_kind_ordinal", 17))
        return 0;
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      if (typeck_ord < 90)
        return 1;
      return 1;
    }
    if (typeck_ndef >= 75 && typeck_ndef <= 200 && !asm_module_is_backend_selfhost(m) &&
        !asm_module_is_parser_emit_heavy(m)) {
      int32_t body_ref_thin;
      int32_t slots_thin;
      if (typeck_ord < 0)
        return 1;
      if (asm_skip_heavy_typeck_mega_entry(m, func_index) != 0)
        return 1;
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_merge_dep_struct_layouts_into_entry", 42))
        return 0;
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_wpo_unify_soa_layouts", 28))
        return 0;
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) == 0)
        return 1;
      body_ref_thin = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref_thin <= 0)
        return 1;
      slots_thin = asm_count_block_stack_slots(arena, body_ref_thin);
      if (slots_thin > 128)
        return 1;
      return 0;
    }
    if (asm_module_is_pipeline_selfhost(m)) {
      if (asm_pipeline_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 1;
    }
    if (asm_module_is_main_driver_selfhost(m)) {
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"entry", 5))
        return 0;
      return 1;
    }
    if (asm_module_is_driver_compile_selfhost(m)) {
      if (asm_driver_compile_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 1;
    }
    if (asm_module_is_backend_selfhost(m) && asm_skip_heavy_backend_m8_tail_thin_keep(m, func_index) != 0)
      return 1;
    if (asm_module_is_backend_selfhost(m) && nfuncs <= 150 &&
        (asm_skip_heavy_backend_helper_keep(m, func_index) != 0 ||
         asm_skip_heavy_backend_m8_helper_keep(m, func_index) != 0)) {
      body_ref = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref <= 0 ||
          asm_count_block_stack_slots(arena, body_ref) <= 48)
        return 0;
    }
    if (asm_module_is_typeck_selfhost(m) && asm_skip_heavy_typeck_helper_keep(m, func_index) != 0) {
      if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_", 14))
        return 1;
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_align", 20) ||
          pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_size", 19))
        return 1;
      if (func_index >= 90 && func_index <= 159)
        return 1;
      body_ref = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref <= 0)
        return 0;
      if (asm_count_block_stack_slots(arena, body_ref) <= 128)
        return 0;
    }
    if (asm_skip_heavy_typeck_mega_entry(m, func_index) != 0)
      return 1;
    if (asm_skip_heavy_backend_mega_entry(m, func_index) != 0)
      return 1;
    if (asm_module_is_typeck_selfhost(m) && typeck_ndef >= 90 && typeck_ord >= 0 &&
        typeck_ord >= 90 && typeck_ord <= 159) {
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 1;
    }
    if (asm_module_is_backend_selfhost(m) && nfuncs >= 80) {
      int32_t be_hi = asm_emit_heavy_abort_hi();
      if (be_hi >= nfuncs)
        be_hi = nfuncs - 1;
      if (func_index >= asm_emit_heavy_abort_lo() && func_index <= be_hi)
        return 1;
    } else if (driver_typeck_skip_large_entry() != 0 && nfuncs >= 175) {
      if (func_index >= asm_emit_heavy_abort_lo() && func_index <= asm_emit_heavy_abort_hi())
        return 1;
    } else if (nfuncs >= 160 && asm_module_defined_func_ordinal(m, func_index) >= 72 &&
               !asm_module_is_backend_selfhost(m) &&
               !asm_module_is_typeck_selfhost(m) && !asm_module_is_parser_emit_heavy(m)) {
      return 1;
    }
    body_ref = pipeline_module_func_body_ref_at(m, func_index);
    slot_threshold = 256;
    if (asm_module_is_backend_selfhost(m) && func_index < 87) {
      slot_threshold = 256;
    } else if ((asm_module_is_backend_selfhost(m) && nfuncs >= 80) ||
               (driver_typeck_skip_large_entry() != 0 && nfuncs >= 175))
      slot_threshold = 96;
    if (arena && body_ref > 0) {
      slots = asm_count_block_stack_slots(arena, body_ref);
      if (slots > slot_threshold)
        return 1;
    }
    if (asm_module_is_backend_selfhost(m))
      return 1;
    if (asm_module_is_typeck_selfhost(m)) {
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 0;
    }
    return 0;
  }
  /* Stage 12.0.5: defined ordinal — leading export-extern must not ret0-stub. */
  {
    int32_t def_ord_coarse = asm_module_defined_func_ordinal(m, func_index);
    if (nfuncs >= 160 && def_ord_coarse >= 72)
      return 1;
  }
  body_ref = pipeline_module_func_body_ref_at(m, func_index);
  if (arena && body_ref > 0) {
    slots = asm_count_block_stack_slots(arena, body_ref);
    if (slots > 48)
      return 1;
  }
  return 0;
}

/* wave119 cold twins: emit_heavy_env pure leave (void* Module/Arena).
 * Cap residual accessors remain host-cc (top_level_let / expr / driver_get).
 * PLATFORM: SHARED. */
extern const char *driver_get_current_dep_path_for_codegen(void);
extern int32_t pipeline_module_top_level_let_name_len(void *m, int32_t idx);
extern uint8_t pipeline_module_top_level_let_name_byte_at(void *m, int32_t idx, int32_t off);
extern int32_t pipeline_module_top_level_let_init_ref(void *m, int32_t idx);
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_int_val_at(void *a, int32_t expr_ref);
extern long strtol(const char *nptr, char **endptr, int base);

static int32_t wave119_env_truthy(const char *e) {
  return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

int32_t asm_env_entry_emit_heavy(void) {
  return wave119_env_truthy(link_abi_getenv("XLANG_ASM_ENTRY_EMIT_HEAVY"));
}

/* wave650: cold twin of pure asm_env_force_full_bodies (FORCE full-bodies
 * escape; default off). PLATFORM: SHARED. */
static int32_t asm_env_force_full_bodies_cold(void) {
  return wave119_env_truthy(link_abi_getenv("XLANG_ASM_FORCE_FULL_BODIES"));
}

int32_t asm_env_build_skip_typeck(void) {
  return wave119_env_truthy(link_abi_getenv("XLANG_ASM_BUILD_SKIP_TYPECK"));
}

static int32_t wave119_asm_env_strict_orchestration(void) {
  return wave119_env_truthy(link_abi_getenv("XLANG_ASM_STRICT_ORCHESTRATION"));
}

int32_t asm_emit_heavy_abort_lo(void) {
  const char *e = link_abi_getenv("XLANG_ASM_EMIT_ABORT_LO");
  char *end = NULL;
  long v;
  if (!e || e[0] == '\0')
    return 87;
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return 87;
  return (int32_t)v;
}

int32_t asm_emit_heavy_abort_hi(void) {
  const char *e = link_abi_getenv("XLANG_ASM_EMIT_ABORT_HI");
  char *end = NULL;
  long v;
  if (!e || e[0] == '\0')
    return 218;
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return 218;
  return (int32_t)v;
}

int32_t pipeline_module_func_name_has_prefix_at(void *m, int32_t fi, const char *pfx, int32_t plen) {
  int32_t nl;
  int32_t k;
  if (!m || fi < 0 || !pfx || plen <= 0)
    return 0;
  nl = pipeline_module_func_name_len_at(m, fi);
  if (nl < plen)
    return 0;
  for (k = 0; k < plen; k++) {
    if (pipeline_module_func_name_byte_at(m, fi, k) != (int32_t)(uint8_t)pfx[k])
      return 0;
  }
  return 1;
}

uint8_t *asm_driver_current_dep_path_for_codegen(void) {
  const char *p = driver_get_current_dep_path_for_codegen();
  return (uint8_t *)(p ? p : "");
}

void asm_import_path_to_c_prefix_into(uint8_t *path, uint8_t *buf, int32_t buf_cap) {
  int32_t off = 0;
  int32_t pi = 0;
  if (!buf || buf_cap <= 0)
    return;
  if (!path) {
    buf[0] = '\0';
    return;
  }
  while (path[pi] != 0 && off + 2 < buf_cap) {
    buf[off++] = (uint8_t)(path[pi] == '.' ? '_' : path[pi]);
    pi++;
  }
  if (off + 1 < buf_cap)
    buf[off++] = '_';
  buf[off] = 0;
}

extern int32_t pipeline_module_top_level_let_is_const(void *m, int32_t tl);

int32_t asm_module_top_level_const_lit_i32(void *m, void *a, uint8_t *name, int32_t name_len,
    int32_t *out_imm) {
  int32_t tl;
  int32_t nl;
  int32_t k;
  int32_t init_ref;
  int32_t ntl;
  if (!m || !a || !name || name_len <= 0 || !out_imm)
    return 0;
  /* LP64: Module.num_top_level_lets @ offset 12 (≡ pure pipe_mod_get_num_top_level_lets). */
  ntl = m ? *(int32_t *)((char *)m + 12) : 0;
  for (tl = 0; tl < ntl; tl++) {
    nl = pipeline_module_top_level_let_name_len(m, tl);
    if (nl != name_len || nl <= 0)
      continue;
    for (k = 0; k < name_len; k++) {
      if (pipeline_module_top_level_let_name_byte_at(m, tl, k) != name[k])
        break;
    }
    if (k != name_len)
      continue;
    /* wave745: only `const` may fold to an immediate. Mutable `let`
     * with int-lit init must miss so load_operand lea+loads the global. */
    if (pipeline_module_top_level_let_is_const(m, tl) == 0)
      return 0;
    init_ref = pipeline_module_top_level_let_init_ref(m, tl);
    if (init_ref <= 0)
      continue;
    k = pipeline_expr_kind_ord_at(a, init_ref);
    if (k == 0 || k == 2) {
      *out_imm = pipeline_expr_int_val_at(a, init_ref);
      return 1;
    }
  }
  return 0;
}

/* 9.6.3: seed twin of runtime_pipeline_abi.x asm_module_top_level_let_name_exists —
 * registration-side duplicate guard for the top-level-let parse authority
 * (P012 kind=2). Must stay in step with the .x authority. PLATFORM: SHARED. */
int32_t asm_module_top_level_let_name_exists(void *m, uint8_t *name, int32_t name_len) {
  int32_t tl;
  int32_t nl;
  int32_t k;
  int32_t ntl;
  if (!m || !name || name_len <= 0)
    return 0;
  /* LP64: Module.num_top_level_lets @ offset 12 (≡ pure pipe_mod_get_num_top_level_lets). */
  ntl = *(int32_t *)((char *)m + 12);
  for (tl = 0; tl < ntl; tl++) {
    nl = pipeline_module_top_level_let_name_len(m, tl);
    if (nl != name_len || nl <= 0)
      continue;
    for (k = 0; k < name_len; k++) {
      if (pipeline_module_top_level_let_name_byte_at(m, tl, k) != name[k])
        break;
    }
    if (k == name_len)
      return 1;
  }
  return 0;
}

int32_t asm_skip_typeck_entry_whitelist(void *m, int32_t func_index) {
  int32_t large_entry;
  if (!m || func_index < 0)
    return 0;
  if (asm_module_is_parser_selfhost(m)) {
    if (link_abi_getenv("XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT") != NULL) {
      if (link_abi_getenv("XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT_MINIMAL") != NULL) {
        if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_init", 15) ||
            pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_set_main_index", 25))
          return 1;
      } else {
        if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_buf", 14) ||
            pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into", 10) ||
            pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_init", 15) ||
            pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_set_main_index", 25) ||
            pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"collect_imports_buf", 19))
          return 1;
      }
    }
    return 0;
  }
  large_entry = driver_typeck_skip_large_entry();
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_run_all", 21) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_impl", 19) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_should_skip_codegen", 33) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_phase_parse_load", 30) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_phase_parse_only", 30) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_phase_load_deps", 29) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_typecheck", 23) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_codegen_deps", 26) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_codegen_entry", 27) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_codegen_chain", 27) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_init", 15) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_set_main_index", 25) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"collect_imports_buf", 19) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_buf", 14) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"entry", 5))
    return 1;
  if (large_entry == 0) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast", 12) ||
        pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast_library", 20) ||
        pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_codegen_ast", 15))
      return 1;
  }
  return 0;
}

int32_t asm_orchestration_extern_only_func(void *m, int32_t func_index) {
  if (!m || func_index < 0)
    return 0;
  if (wave119_asm_env_strict_orchestration() == 0)
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_typecheck", 23) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_with_init_buf", 24) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_phase_parse_load", 30) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_run_all", 21) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_impl", 19))
    return 1;
  return 0;
}


/* wave120 cold twins: parser_emit_heavy pure leave (void* Module).
 * G.7 sole cold provider under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: SHARED. */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern int32_t pipeline_module_func_name_len_at(void *m, int32_t fi);
extern void pipeline_module_func_name_copy64(void *m, int32_t fi, uint8_t *dst);
extern int32_t pipeline_module_func_name_equal_at(void *m, int32_t fi, const uint8_t *name, int32_t name_len);
extern int32_t pipeline_module_func_name_has_prefix_at(void *m, int32_t fi, const char *pfx, int32_t plen);
extern int32_t pipeline_module_num_funcs(void *m);
extern int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t fi);
extern int32_t asm_module_is_parser_emit_heavy(void *m);
extern const char *link_abi_getenv(const char *name);

#define ASM_EMIT_HEAVY_PARSER_SLOT_MAX 16

void asm_parser_emit_heavy_dbg_real(void *m, int32_t fi, const char *why) {
  /* Class AW: Cap-only XLANG_ASM_DEBUG dbg_real retired. */
  (void)m;
  (void)fi;
  (void)why;
}

int32_t asm_parser_emit_heavy_bisect_max_index(void) {
  const char *stub = link_abi_getenv("XLANG_PARSER_EMIT_HEAVY_STUB_ONLY");
  char *end = NULL;
  long v;
  const char *e;
  if (stub != NULL && stub[0] != '\0' && stub[0] != '0')
    return 0;
  e = link_abi_getenv("XLANG_PARSER_EMIT_HEAVY_BISECT_N");
  if (!e || e[0] == '\0')
    return 2147483647;
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return 2147483647;
  if (v > 2147483647L)
    return 2147483647;
  return (int32_t)v;
}

int32_t asm_parser_emit_heavy_slot_max(void) {
  const char *e = link_abi_getenv("XLANG_PARSER_EMIT_HEAVY_SLOT_MAX");
  char *end = NULL;
  long v;
  if (!e || e[0] == '\0')
    return ASM_EMIT_HEAVY_PARSER_SLOT_MAX;
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return ASM_EMIT_HEAVY_PARSER_SLOT_MAX;
  if (v > 512)
    return 512;
  return (int32_t)v;
}

typedef struct {
  const char *name;
  int32_t len;
} wave120_boot_parse_sym_t;

static int32_t wave120_mega_bisect_skip_stub(void *m, int32_t func_index, const char *name, int32_t len) {
  const char *b;
  size_t blen;
  if (!m || func_index < 0 || !name || len <= 0)
    return 0;
  b = link_abi_getenv("XLANG_ASM_PARSER_MEGA_BISECT");
  if (!b || b[0] == '\0')
    return 0;
  blen = strlen(b);
  if ((int32_t)blen != len)
    return 0;
  if (memcmp(b, name, (size_t)len) != 0)
    return 0;
  return pipeline_module_func_name_equal_at(m, func_index, (const uint8_t *)name, len);
}

static int32_t wave120_bootstrap_mega_emit_allowed(void *m, int32_t func_index, const char *name, int32_t len) {
  static const wave120_boot_parse_sym_t k_min[] = {
      {"parse_into_init", 15},
      {"parse_into_set_main_index", 25},
  };
  static const wave120_boot_parse_sym_t k_full[] = {
      {"parse_into_buf", 14},
      {"parse_into", 10},
      {"parse_into_init", 15},
      {"parse_into_set_main_index", 25},
      {"collect_imports_buf", 19},
  };
  const wave120_boot_parse_sym_t *k;
  int32_t kn;
  int32_t i;
  if (!m || func_index < 0 || link_abi_getenv("XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT") == NULL)
    return 0;
  if (!pipeline_module_func_name_equal_at(m, func_index, (const uint8_t *)name, len))
    return 0;
  if (link_abi_getenv("XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT_MINIMAL") != NULL) {
    k = k_min;
    kn = (int32_t)(sizeof(k_min) / sizeof(k_min[0]));
  } else {
    k = k_full;
    kn = (int32_t)(sizeof(k_full) / sizeof(k_full[0]));
  }
  for (i = 0; i < kn; i++) {
    if (k[i].len == len && memcmp(k[i].name, name, (size_t)len) == 0)
      return 1;
  }
  return 0;
}

int32_t asm_skip_heavy_parser_mega_entry(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_MEGA_EQ(n, l) \
  do { \
    if (wave120_mega_bisect_skip_stub(m, func_index, (n), (l))) \
      break; \
    if (wave120_bootstrap_mega_emit_allowed(m, func_index, (n), (l))) \
      break; \
    if (pipeline_module_func_name_equal_at(m, func_index, (const uint8_t *)(n), (l))) \
      return 1; \
  } while (0)
  PARSER_MEGA_EQ("parse_into_buf", 14);
  PARSER_MEGA_EQ("parse_into", 10);
  PARSER_MEGA_EQ("parse", 5);
  PARSER_MEGA_EQ("parse_one_function_impl", 23);
  PARSER_MEGA_EQ("parse_expr_into", 15);
  PARSER_MEGA_EQ("parse_block_into", 16);
  PARSER_MEGA_EQ("parse_body_lets_into", 20);
#undef PARSER_MEGA_EQ
  return 0;
}

int32_t asm_parser_emit_heavy_force_stub(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_STUB_EQ(n, l) \
  do { \
    if (pipeline_module_func_name_equal_at(m, func_index, (const uint8_t *)(n), (l))) \
      return 1; \
  } while (0)
#define PARSER_STUB_PFX(pfx, plen) \
  do { \
    if (pipeline_module_func_name_has_prefix_at(m, func_index, (pfx), (int32_t)(plen))) \
      return 1; \
  } while (0)
  PARSER_STUB_PFX("copy_onefunc_", 13);
  PARSER_STUB_PFX("onefunc_", 8);
  PARSER_STUB_PFX("set_onefunc_", 12);
  PARSER_STUB_EQ("wrap_block_ref_as_expr", 22);
  PARSER_STUB_EQ("parser_alloc_true_bool_lit", 26);
  PARSER_STUB_EQ("parser_alloc_float_lit", 22);
  PARSER_STUB_EQ("parser_expr_wrap_in_return", 26);
  PARSER_STUB_EQ("try_skip_allow_padding_struct", 29);
  PARSER_STUB_EQ("try_skip_allow_padding_struct_buf", 33);
#undef PARSER_STUB_EQ
#undef PARSER_STUB_PFX
  return 0;
}

int32_t asm_parser_emit_heavy_safe_helper(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_SAFE_EQ(n, l) \
  do { \
    if (pipeline_module_func_name_equal_at(m, func_index, (const uint8_t *)(n), (l))) \
      return 1; \
  } while (0)
  PARSER_SAFE_EQ("get_module_num_imports", 22);
  PARSER_SAFE_EQ("expr_ref_is_assign_lvalue", 25);
  PARSER_SAFE_EQ("copy_slice_to_name64", 20);
  PARSER_SAFE_EQ("copy_slice_to_name64_at_end", 27);
  PARSER_SAFE_EQ("copy_slice_to_param32", 21);
  PARSER_SAFE_EQ("copy_slice_to_param32_at_end", 28);
  PARSER_SAFE_EQ("copy_slice_to_name64_buf", 24);
  PARSER_SAFE_EQ("copy_slice_to_name64_at_end_buf", 31);
  PARSER_SAFE_EQ("copy_slice_to_param32_at_end_buf", 32);
  PARSER_SAFE_EQ("copy_slice_to_param32_buf", 25);
  PARSER_SAFE_EQ("get_module_import_path", 22);
  PARSER_SAFE_EQ("copy_module_import_path64", 25);
  PARSER_SAFE_EQ("parse_one_function_library_buf", 30);
  PARSER_SAFE_EQ("parse_one_function_library_into_buf", 35);
  PARSER_SAFE_EQ("parse_one_function_buf_into", 27);
  PARSER_SAFE_EQ("parse_into_init", 15);
  PARSER_SAFE_EQ("parse_one_function_library_into", 31);
  PARSER_SAFE_EQ("pipeline_module_reset_parse_counters", 36);
  PARSER_SAFE_EQ("extern_parse_set_fail", 21);
  PARSER_SAFE_EQ("extern_parse_pool_ptr", 21);
  PARSER_SAFE_EQ("onefunc_result_pool_ptr", 23);
  PARSER_SAFE_EQ("set_onefunc_fail", 16);
  PARSER_SAFE_EQ("copy_lex_from_import_into", 25);
  PARSER_SAFE_EQ("lex_from_next_into", 18);
  PARSER_SAFE_EQ("lex_from_result_ptr_into", 24);
  PARSER_SAFE_EQ("lex_from_onefunc_next_into", 26);
  PARSER_SAFE_EQ("write_extern_params_to_pools", 28);
  PARSER_SAFE_EQ("module_register_arena_func", 26);
  PARSER_SAFE_EQ("is_pointee_type_token", 21);
  PARSER_SAFE_EQ("compound_assign_token_to_expr_kind", 34);
  PARSER_SAFE_EQ("import_path_dot_segment_copy", 28);
  PARSER_SAFE_EQ("parser_alloc_vector_type_ref", 28);
  PARSER_SAFE_EQ("parse_peek_function_name_buf", 28);
  PARSER_SAFE_EQ("lexer_pos_before_run", 20);
  PARSER_SAFE_EQ("parser_match_kw_immediately_before", 34);
  PARSER_SAFE_EQ("import_path_dot_segment_len", 27);
  PARSER_SAFE_EQ("is_compound_assign_token", 24);
  PARSER_SAFE_EQ("struct_field_name_tok_kind", 26);
  PARSER_SAFE_EQ("struct_field_continues_tok_kind", 31);
  PARSER_SAFE_EQ("module_try_register_enum_name", 29);
  PARSER_SAFE_EQ("struct_layout_name_exists_arr", 29);
  PARSER_SAFE_EQ("struct_layout_first_name_match_idx", 34);
  PARSER_SAFE_EQ("struct_layout_placeholder_idx", 29);
  PARSER_SAFE_EQ("lexer_token_run_len", 19);
  PARSER_SAFE_EQ("module_append_enum_variants_and_skip_body_into_buf", 50);
  PARSER_SAFE_EQ("skip_balanced_parens_into_buf", 29);
  PARSER_SAFE_EQ("skip_balanced_braces_into_buf", 29);
  PARSER_SAFE_EQ("skip_one_enum_into_buf", 22);
  PARSER_SAFE_EQ("skip_one_struct_into_buf", 24);
  PARSER_SAFE_EQ("skip_one_trait_into_buf", 23);
  PARSER_SAFE_EQ("skip_one_impl_into_buf", 22);
  PARSER_SAFE_EQ("skip_one_extern_into_buf", 24);
  PARSER_SAFE_EQ("skip_one_function_full_into_buf", 31);
  PARSER_SAFE_EQ("skip_one_enum_register_into_buf", 31);
  PARSER_SAFE_EQ("parse_one_extern_and_add_into_buf", 33);
  PARSER_SAFE_EQ("diag_skip_let_const_buf", 23);
  PARSER_SAFE_EQ("body_skip_let_const_then_if_buf", 31);
  PARSER_SAFE_EQ("skip_balanced_parens_buf", 24);
  PARSER_SAFE_EQ("skip_balanced_braces_buf", 24);
  PARSER_SAFE_EQ("skip_one_function_full_buf", 26);
  PARSER_SAFE_EQ("skip_one_if_core_buf", 20);
  PARSER_SAFE_EQ("skip_one_if_statement_buf", 25);
  PARSER_SAFE_EQ("skip_one_enum_buf", 17);
  PARSER_SAFE_EQ("skip_one_trait_buf", 18);
  PARSER_SAFE_EQ("skip_one_impl_buf", 17);
  PARSER_SAFE_EQ("skip_one_extern_buf", 19);
  PARSER_SAFE_EQ("skip_one_struct_buf", 19);
  PARSER_SAFE_EQ("parse_into_try_skip_allow_buf", 29);
  PARSER_SAFE_EQ("try_skip_allow_padding_struct_buf", 33);
  PARSER_SAFE_EQ("lex_from_library_into", 21);
  PARSER_SAFE_EQ("lex_from_try_skip_into", 22);
  PARSER_SAFE_EQ("lex_from_library", 16);
  PARSER_SAFE_EQ("lex_from_try_skip", 17);
  PARSER_SAFE_EQ("advance_past_stmt_semicolon_into", 32);
  PARSER_SAFE_EQ("advance_past_cond_rparen_into", 29);
  PARSER_SAFE_EQ("first_token_kind", 16);
  PARSER_SAFE_EQ("diag_first_ident_len", 20);
  PARSER_SAFE_EQ("parser_rewind_lex_for_following_stmt", 36);
  PARSER_SAFE_EQ("lex_at_token_from_result", 24);
  PARSER_SAFE_EQ("struct_field_name_from_tok", 26);
  PARSER_SAFE_EQ("diag_skip_let_const_into", 24);
  PARSER_SAFE_EQ("diag_skip_let_const", 19);
  PARSER_SAFE_EQ("body_skip_let_const_then_if_into", 32);
  PARSER_SAFE_EQ("body_skip_let_const_then_if", 27);
  PARSER_SAFE_EQ("skip_one_if_statement_into", 26);
  PARSER_SAFE_EQ("skip_one_if_core_into", 21);
  PARSER_SAFE_EQ("skip_one_if_statement", 21);
  PARSER_SAFE_EQ("skip_one_if_core", 16);
  PARSER_SAFE_EQ("skip_one_enum_into", 18);
  PARSER_SAFE_EQ("skip_one_impl_into", 18);
  PARSER_SAFE_EQ("skip_one_trait_into", 19);
  PARSER_SAFE_EQ("skip_one_extern_into", 20);
  PARSER_SAFE_EQ("parse_into_try_skip_allow_into", 30);
  PARSER_SAFE_EQ("parse_into_try_skip_allow_into_buf", 34);
  PARSER_SAFE_EQ("parse_into_set_main_index", 25);
  PARSER_SAFE_EQ("diag_token_after_collect_imports", 32);
  PARSER_SAFE_EQ("diag_parse_one_after_collect_imports", 36);
  PARSER_SAFE_EQ("parse_one_function_ok_for_pipeline", 34);
  PARSER_SAFE_EQ("skip_imports", 12);
  PARSER_SAFE_EQ("skip_one_struct", 15);
  PARSER_SAFE_EQ("skip_one_struct_into", 20);
  PARSER_SAFE_EQ("parse_one_extern_skip_into", 26);
  PARSER_SAFE_EQ("skip_one_enum", 13);
  PARSER_SAFE_EQ("skip_one_trait", 14);
  PARSER_SAFE_EQ("skip_one_impl", 13);
  PARSER_SAFE_EQ("skip_one_extern", 15);
  PARSER_SAFE_EQ("skip_one_function_full", 22);
  PARSER_SAFE_EQ("collect_imports", 15);
  PARSER_SAFE_EQ("consume_qualified_type_ident_name", 33);
  PARSER_SAFE_EQ("expr_set_common_zeros", 21);
  PARSER_SAFE_EQ("fill_block_const_let_from_res", 29);
  PARSER_SAFE_EQ("append_block_lets_from_res", 26);
  PARSER_SAFE_EQ("diag_after_imports_then_structs", 31);
  PARSER_SAFE_EQ("diag_fail_at_token_kind", 23);
  PARSER_SAFE_EQ("diag_lex_after_imports", 22);
  PARSER_SAFE_EQ("skip_balanced_parens", 20);
  PARSER_SAFE_EQ("skip_balanced_parens_into", 25);
  PARSER_SAFE_EQ("skip_balanced_braces", 20);
  PARSER_SAFE_EQ("skip_balanced_braces_into", 25);
  PARSER_SAFE_EQ("parse_primary_into", 18);
  PARSER_SAFE_EQ("parse_unary_into", 16);
  PARSER_SAFE_EQ("parse_cast_into", 15);
  PARSER_SAFE_EQ("parse_term_into", 15);
  PARSER_SAFE_EQ("parse_addsub_into", 17);
  PARSER_SAFE_EQ("parse_shift_into", 16);
  PARSER_SAFE_EQ("parse_relcompare_into", 21);
  PARSER_SAFE_EQ("parse_compare_into", 18);
  PARSER_SAFE_EQ("parse_bitand_into", 17);
  PARSER_SAFE_EQ("parse_bitor_into", 16);
  PARSER_SAFE_EQ("parse_bitxor_into", 17);
  PARSER_SAFE_EQ("parse_logand_into", 17);
  PARSER_SAFE_EQ("parse_logor_into", 16);
  PARSER_SAFE_EQ("parse_ternary_into", 18);
  PARSER_SAFE_EQ("parse_assign_into", 17);
  PARSER_SAFE_EQ("parse_as_suffix_into", 20);
  PARSER_SAFE_EQ("parse_one_function_library", 26);
  PARSER_SAFE_EQ("parse_one_function_library_scan", 31);
  PARSER_SAFE_EQ("parse_into_try_skip_allow", 25);
  PARSER_SAFE_EQ("parse_one_extern_and_add_into", 29);
  PARSER_SAFE_EQ("parse_one_top_level_let_into", 28);
  PARSER_SAFE_EQ("parser_should_wrap_func_tail_in_return", 38);
  PARSER_SAFE_EQ("skip_one_enum_register_into", 27);
  PARSER_SAFE_EQ("skip_one_function_full_into", 27);
  PARSER_SAFE_EQ("alloc_pointee_type_ref_from_tok", 31);
  PARSER_SAFE_EQ("parse_struct_record_layout_into", 31);
  PARSER_SAFE_EQ("parse_type_ref_for_arena_into", 29);
  PARSER_SAFE_EQ("parse_cond_expr_into", 20);
  PARSER_SAFE_EQ("module_append_enum_variants_and_skip_body_into", 46);
  PARSER_SAFE_EQ("parse_body_let_bracket_compound_init_ref", 40);
  PARSER_SAFE_EQ("parser_vector_type_ref_from_ident_spelling", 42);
  PARSER_SAFE_EQ("collect_imports_buf", 19);
  PARSER_SAFE_EQ("skip_imports_buf", 16);
  PARSER_SAFE_EQ("diag_skip_let_const_into_buf", 28);
  PARSER_SAFE_EQ("body_skip_let_const_then_if_into_buf", 36);
  PARSER_SAFE_EQ("skip_one_if_core_into_buf", 25);
  PARSER_SAFE_EQ("skip_one_if_statement_into_buf", 30);
  PARSER_SAFE_EQ("first_token_kind_buf", 20);
  PARSER_SAFE_EQ("diag_first_ident_len_buf", 24);
  PARSER_SAFE_EQ("diag_lex_after_imports_buf", 26);
  PARSER_SAFE_EQ("diag_after_imports_then_structs_buf", 35);
  PARSER_SAFE_EQ("diag_fail_at_token_kind_buf", 27);
  PARSER_SAFE_EQ("parse_one_extern_skip_into_buf", 30);
  PARSER_SAFE_EQ("consume_qualified_type_ident_name_buf", 37);
  PARSER_SAFE_EQ("advance_past_stmt_semicolon_into_buf", 36);
  PARSER_SAFE_EQ("advance_past_cond_rparen_into_buf", 33);
  PARSER_SAFE_EQ("parse_primary_into_buf", 22);
  PARSER_SAFE_EQ("parse_unary_into_buf", 20);
  PARSER_SAFE_EQ("parse_cast_into_buf", 19);
  PARSER_SAFE_EQ("parse_term_into_buf", 19);
  PARSER_SAFE_EQ("parse_addsub_into_buf", 21);
  PARSER_SAFE_EQ("parse_shift_into_buf", 20);
  PARSER_SAFE_EQ("parse_relcompare_into_buf", 25);
  PARSER_SAFE_EQ("parse_compare_into_buf", 22);
  PARSER_SAFE_EQ("parse_bitand_into_buf", 21);
  PARSER_SAFE_EQ("parse_bitxor_into_buf", 21);
  PARSER_SAFE_EQ("parse_bitor_into_buf", 20);
  PARSER_SAFE_EQ("parse_logand_into_buf", 21);
  PARSER_SAFE_EQ("parse_logor_into_buf", 20);
  PARSER_SAFE_EQ("parse_ternary_into_buf", 22);
  PARSER_SAFE_EQ("parse_assign_into_buf", 21);
  PARSER_SAFE_EQ("parse_expr_into_buf", 19);
  PARSER_SAFE_EQ("finish_struct_lit_from_type_ident_into_buf", 42);
  PARSER_SAFE_EQ("parse_cond_expr_into_buf", 24);
  PARSER_SAFE_EQ("parse_if_stmt_into_buf", 22);
  PARSER_SAFE_EQ("parse_if_stmt_into", 18);
  PARSER_SAFE_EQ("parse_if_expr_into", 18);
  PARSER_SAFE_EQ("parse_match_into", 16);
  PARSER_SAFE_EQ("parse_match_subject_into", 24);
  PARSER_SAFE_EQ("parse_at_simd_builtin_into", 26);
  PARSER_SAFE_EQ("finish_struct_lit_from_type_ident_into", 38);
  PARSER_SAFE_EQ("parse_expr_with_leading_int_as_into", 35);
  PARSER_SAFE_EQ("parse_block_into_buf", 20);
  PARSER_SAFE_EQ("parse_if_expr_into_buf", 22);
  PARSER_SAFE_EQ("parse_match_subject_into_buf", 28);
  PARSER_SAFE_EQ("parse_match_into_buf", 20);
  PARSER_SAFE_EQ("parse_at_simd_builtin_into_buf", 30);
  PARSER_SAFE_EQ("parse_as_suffix_into_buf", 24);
  PARSER_SAFE_EQ("parse_type_ref_for_arena_into_buf", 33);
  PARSER_SAFE_EQ("parse_body_let_bracket_compound_init_ref_buf", 44);
  PARSER_SAFE_EQ("parse_struct_record_layout_into_buf", 35);
  PARSER_SAFE_EQ("parse_one_function_library_scan_buf", 35);
  PARSER_SAFE_EQ("alloc_pointee_type_ref_from_tok_buf", 35);
  PARSER_SAFE_EQ("parser_vector_type_ref_from_ident_spelling_buf", 46);
  PARSER_SAFE_EQ("parse_one_top_level_let_into_buf", 32);
  PARSER_SAFE_EQ("import_path_dot_segment_copy_buf", 32);
  PARSER_SAFE_EQ("parser_match_kw_immediately_before_buf", 38);
  PARSER_SAFE_EQ("struct_field_name_from_tok_buf", 30);
  PARSER_SAFE_EQ("parse_expr_with_leading_int_as_into_buf", 39);
  PARSER_SAFE_EQ("skip_one_enum_register_buf", 26);
  PARSER_SAFE_EQ("skip_balanced_parens_slice_into_buf", 35);
  PARSER_SAFE_EQ("skip_balanced_braces_slice_into_buf", 35);
  PARSER_SAFE_EQ("module_append_enum_variants_and_skip_body_slice_into_buf", 56);
  PARSER_SAFE_EQ("parse_one_extern_skip_buf", 25);
  PARSER_SAFE_EQ("parse_one_extern_and_add_buf", 28);
  PARSER_SAFE_EQ("parse_one_function_library_from_buf", 35);
  PARSER_SAFE_EQ("parse_into_try_skip_allow_from_buf", 34);
#undef PARSER_SAFE_EQ
  return 0;
}

typedef struct {
  const char *x_name;
  int32_t x_len;
  const char *c_name;
  int32_t c_len;
} wave120_thin_row_t;

static const wave120_thin_row_t k_wave120_parser_thin_delegate[] = {
    {"collect_imports_buf", 19, "parser_collect_imports_buf_glue", 31},
    {"advance_past_cond_rparen_into", 29, "parser_advance_past_cond_rparen_into_glue", 41},
    {"advance_past_stmt_semicolon_into", 32, "parser_advance_past_stmt_semicolon_into_glue", 44},
    {"alloc_pointee_type_ref_from_tok", 31, "parser_alloc_pointee_type_ref_from_tok_glue", 43},
    {"append_block_lets_from_res", 26, "parser_append_block_lets_from_res_glue", 38},
    {"body_skip_let_const_then_if_buf", 31, "parser_body_skip_let_const_then_if_buf_glue", 43},
    {"body_skip_let_const_then_if", 27, "parser_body_skip_let_const_then_if_glue", 39},
    {"body_skip_let_const_then_if_into", 32, "parser_body_skip_let_const_then_if_into_glue", 44},
    {"collect_imports", 15, "parser_collect_imports_glue", 27},
    {"copy_lex_from_import_into", 25, "parser_lex_copy_from_import_into_glue", 37},
    {"consume_qualified_type_ident_name", 33, "parser_consume_qualified_type_ident_name_glue", 45},
    {"diag_after_imports_then_structs", 31, "parser_diag_after_imports_then_structs_glue", 43},
    {"diag_fail_at_token_kind", 23, "parser_diag_fail_at_token_kind_glue", 35},
    {"diag_first_ident_len", 20, "parser_diag_first_ident_len_glue", 32},
    {"diag_lex_after_imports", 22, "parser_diag_lex_after_imports_glue", 34},
    {"diag_skip_let_const_buf", 23, "parser_diag_skip_let_const_buf_glue", 35},
    {"diag_skip_let_const", 19, "parser_diag_skip_let_const_glue", 31},
    {"diag_skip_let_const_into", 24, "parser_diag_skip_let_const_into_glue", 36},
    {"expr_set_common_zeros", 21, "parser_expr_set_common_zeros_glue", 33},
    {"fill_block_const_let_from_res", 29, "parser_fill_block_const_let_from_res_glue", 41},
    {"finish_struct_lit_from_type_ident_into", 38, "parser_finish_struct_lit_from_type_ident_into_glue", 50},
    {"first_token_kind", 16, "parser_first_token_kind_glue", 28},
    {"lex_at_token_from_result", 24, "parser_lex_at_token_from_result_glue", 36},
    {"lex_from_library", 16, "parser_lex_from_library_glue", 28},
    {"lex_from_library_into", 21, "parser_lex_from_library_into_glue", 33},
    {"lex_from_onefunc_next_into", 26, "parser_lex_from_onefunc_next_into_glue", 38},
    {"lex_from_next_into", 18, "parser_lex_from_next_into_glue", 30},
    {"lex_from_result_ptr_into", 24, "parser_lex_from_result_ptr_into_glue", 36},
    {"lex_from_try_skip", 17, "parser_lex_from_try_skip_glue", 29},
    {"lex_from_try_skip_into", 22, "parser_lex_from_try_skip_into_glue", 34},
    {"module_append_enum_variants_and_skip_body_into", 46, "parser_module_append_enum_variants_and_skip_body_into_glue", 58},
    {"parse_addsub_into", 17, "parser_parse_addsub_into_glue", 29},
    {"parse_as_suffix_into", 20, "parser_parse_as_suffix_into_glue", 32},
    {"parse_assign_into", 17, "parser_parse_assign_into_glue", 29},
    {"parse_at_simd_builtin_into", 26, "parser_parse_at_simd_builtin_into_glue", 38},
    {"parse_bitand_into", 17, "parser_parse_bitand_into_glue", 29},
    {"parse_bitor_into", 16, "parser_parse_bitor_into_glue", 28},
    {"parse_bitxor_into", 17, "parser_parse_bitxor_into_glue", 29},
    {"parse_body_let_bracket_compound_init_ref", 40, "parser_parse_body_let_bracket_compound_init_ref_glue", 52},
    {"parse_cast_into", 15, "parser_parse_cast_into_glue", 27},
    {"parse_compare_into", 18, "parser_parse_compare_into_glue", 30},
    {"parse_cond_expr_into", 20, "parser_parse_cond_expr_into_glue", 32},
    {"parse_if_expr_into", 18, "parser_parse_if_expr_into_glue", 30},
    {"parse_if_stmt_into", 18, "parser_parse_if_stmt_into_glue", 30},
    {"parse_into_try_skip_allow_buf", 29, "parser_parse_into_try_skip_allow_buf_glue", 41},
    {"parse_into_try_skip_allow", 25, "parser_parse_into_try_skip_allow_glue", 37},
    {"parse_into_try_skip_allow_into_buf", 34, "parser_parse_into_try_skip_allow_into_buf_glue", 46},
    {"parse_into_try_skip_allow_into", 30, "parser_parse_into_try_skip_allow_into_glue", 42},
    {"parse_into_set_main_index", 25, "parser_parse_into_set_main_index_glue", 37},
    {"parse_logand_into", 17, "parser_parse_logand_into_glue", 29},
    {"parse_logor_into", 16, "parser_parse_logor_into_glue", 28},
    {"parse_match_into", 16, "parser_parse_match_into_glue", 28},
    {"parse_match_subject_into", 24, "parser_parse_match_subject_into_glue", 36},
    {"parse_one_extern_and_add_into_buf", 33, "parser_parse_one_extern_and_add_into_buf_glue", 45},
    {"parse_one_extern_and_add_into", 29, "parser_parse_one_extern_and_add_into_glue", 41},
    {"parse_one_extern_skip_into", 26, "parser_parse_one_extern_skip_into_glue", 38},
    {"parse_one_function_buf_into", 27, "parser_parse_one_function_buf_into_glue", 39},
    {"parse_one_function_library", 26, "parser_parse_one_function_library_glue", 38},
    {"parse_one_function_library_into", 31, "parser_parse_one_function_library_into_glue", 43},
    {"parse_one_function_library_scan", 31, "parser_parse_one_function_library_scan_glue", 43},
    {"parse_one_top_level_let_into", 28, "parser_parse_one_top_level_let_into_glue", 40},
    {"parse_primary_into", 18, "parser_parse_primary_into_glue", 30},
    {"parse_relcompare_into", 21, "parser_parse_relcompare_into_glue", 33},
    {"parse_shift_into", 16, "parser_parse_shift_into_glue", 28},
    {"parse_struct_record_layout_into", 31, "parser_parse_struct_record_layout_into_glue", 43},
    {"parse_term_into", 15, "parser_parse_term_into_glue", 27},
    {"parse_ternary_into", 18, "parser_parse_ternary_into_glue", 30},
    {"parse_type_ref_for_arena_into", 29, "parser_parse_type_ref_for_arena_into_glue", 41},
    {"parse_unary_into", 16, "parser_parse_unary_into_glue", 28},
    {"parser_rewind_lex_for_following_stmt", 36, "parser_parser_rewind_lex_for_following_stmt_glue", 48},
    {"parser_vector_type_ref_from_ident_spelling", 42, "parser_parser_vector_type_ref_from_ident_spelling_glue", 54},
    {"skip_balanced_braces_buf", 24, "parser_skip_balanced_braces_buf_glue", 36},
    {"skip_balanced_braces", 20, "parser_skip_balanced_braces_glue", 32},
    {"skip_balanced_braces_into", 25, "parser_skip_balanced_braces_into_glue", 37},
    {"skip_balanced_parens_buf", 24, "parser_skip_balanced_parens_buf_glue", 36},
    {"skip_balanced_parens", 20, "parser_skip_balanced_parens_glue", 32},
    {"skip_balanced_parens_into", 25, "parser_skip_balanced_parens_into_glue", 37},
    {"skip_imports", 12, "parser_skip_imports_glue", 24},
    {"skip_one_enum_buf", 17, "parser_skip_one_enum_buf_glue", 29},
    {"skip_one_enum", 13, "parser_skip_one_enum_glue", 25},
    {"skip_one_enum_into", 18, "parser_skip_one_enum_into_glue", 30},
    {"skip_one_enum_into_buf", 22, "parser_skip_one_enum_into_buf_glue", 34},
    {"skip_one_enum_register_into_buf", 31, "parser_skip_one_enum_register_into_buf_glue", 43},
    {"skip_one_enum_register_into", 27, "parser_skip_one_enum_register_into_glue", 39},
    {"skip_one_extern_buf", 19, "parser_skip_one_extern_buf_glue", 31},
    {"skip_one_extern", 15, "parser_skip_one_extern_glue", 27},
    {"skip_one_extern_into_buf", 24, "parser_skip_one_extern_into_buf_glue", 36},
    {"skip_one_extern_into", 20, "parser_skip_one_extern_into_glue", 32},
    {"skip_one_function_full_buf", 26, "parser_skip_one_function_full_buf_glue", 38},
    {"skip_one_function_full", 22, "parser_skip_one_function_full_glue", 34},
    {"skip_one_function_full_into_buf", 31, "parser_skip_one_function_full_into_buf_glue", 43},
    {"skip_one_function_full_into", 27, "parser_skip_one_function_full_into_glue", 39},
    {"skip_one_if_core_buf", 20, "parser_skip_one_if_core_buf_glue", 32},
    {"skip_one_if_core", 16, "parser_skip_one_if_core_glue", 28},
    {"skip_one_if_core_into", 21, "parser_skip_one_if_core_into_glue", 33},
    {"skip_one_if_statement_buf", 25, "parser_skip_one_if_statement_buf_glue", 37},
    {"skip_one_if_statement", 21, "parser_skip_one_if_statement_glue", 33},
    {"skip_one_if_statement_into", 26, "parser_skip_one_if_statement_into_glue", 38},
    {"skip_one_impl_buf", 17, "parser_skip_one_impl_buf_glue", 29},
    {"skip_one_impl", 13, "parser_skip_one_impl_glue", 25},
    {"skip_one_impl_into_buf", 22, "parser_skip_one_impl_into_buf_glue", 34},
    {"skip_one_impl_into", 18, "parser_skip_one_impl_into_glue", 30},
    {"skip_one_struct_buf", 19, "parser_skip_one_struct_buf_glue", 31},
    {"skip_one_struct", 15, "parser_skip_one_struct_glue", 27},
    {"skip_one_struct_into_buf", 24, "parser_skip_one_struct_into_buf_glue", 36},
    {"skip_one_struct_into", 20, "parser_skip_one_struct_into_glue", 32},
    {"skip_one_trait_buf", 18, "parser_skip_one_trait_buf_glue", 30},
    {"skip_one_trait", 14, "parser_skip_one_trait_glue", 26},
    {"skip_one_trait_into_buf", 23, "parser_skip_one_trait_into_buf_glue", 35},
    {"skip_one_trait_into", 19, "parser_skip_one_trait_into_glue", 31},
    {"struct_field_name_from_tok", 26, "parser_struct_field_name_from_tok_glue", 38},
    {"parser_token_is_label_start", 27, "parser_token_is_label_start_glue", 32},
    {"parser_should_wrap_func_tail_in_return", 38, "parser_should_wrap_func_tail_in_return_glue", 43},
    {"pipeline_module_reset_parse_counters", 36, "pipeline_module_reset_parse_counters_c", 38},
    {"try_skip_allow_padding_struct_buf", 33, "parser_try_skip_allow_padding_struct_buf_glue", 45},
    {"try_skip_allow_padding_struct", 29, "parser_try_skip_allow_padding_struct_glue", 41},
};

int32_t asm_parser_func_is_thin_delegate(void *m, int32_t func_index) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
  nrows = (int32_t)(sizeof(k_wave120_parser_thin_delegate) / sizeof(k_wave120_parser_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (const uint8_t *)k_wave120_parser_thin_delegate[i].x_name,
                                           k_wave120_parser_thin_delegate[i].x_len))
      return 1;
  }
  return 0;
}

int32_t asm_parser_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                 int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0)
    return 0;
  nrows = (int32_t)(sizeof(k_wave120_parser_thin_delegate) / sizeof(k_wave120_parser_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (const uint8_t *)k_wave120_parser_thin_delegate[i].x_name,
                                           k_wave120_parser_thin_delegate[i].x_len)) {
      if (k_wave120_parser_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_wave120_parser_thin_delegate[i].c_name, (size_t)k_wave120_parser_thin_delegate[i].c_len);
      out[k_wave120_parser_thin_delegate[i].c_len] = 0;
      *out_len = k_wave120_parser_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}

int32_t asm_parser_emit_heavy_resolve_call_to_glue(void *m, uint8_t *name, int32_t name_len,
                                                    uint8_t *out, int32_t out_cap, int32_t *out_len) {
  int32_t fi;
  int32_t nf;
  if (!m || !name || name_len <= 0 || !out || !out_len || out_cap <= 0)
    return 0;
  *out_len = 0;
  if (!asm_module_is_parser_emit_heavy(m))
    return 0;
  nf = pipeline_module_num_funcs(m);
  for (fi = 0; fi < nf; fi++) {
    if (pipeline_module_func_name_equal_at(m, fi, name, name_len) == 0)
      continue;
    if (asm_parser_m8_tail_thin_delegate_c_name(m, fi, out, out_cap, out_len) != 0)
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (const uint8_t *)"pipeline_module_reset_parse_counters", 36)) {
      const char *c = "pipeline_module_reset_parse_counters_c";
      int32_t n = 38;
      if (n >= out_cap)
        return 0;
      memcpy(out, c, (size_t)n);
      out[n] = 0;
      *out_len = n;
      return 1;
    }
    return 0;
  }
  return 0;
}

int32_t asm_parser_emit_heavy_callee_is_same_module_local(void *m, uint8_t *name, int32_t name_len) {
  int32_t fi;
  int32_t nf;
  if (!m || !name || name_len <= 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
  nf = pipeline_module_num_funcs(m);
  for (fi = 0; fi < nf; fi++) {
    if (pipeline_module_func_name_equal_at(m, fi, name, name_len) == 0)
      continue;
    if (pipeline_asm_module_func_is_extern_at(m, fi) != 0)
      return 0;
    return 1;
  }
  return 0;
}



/* wave121 cold twins: lint_meta pure leave (void* Module / ASTArena).
 * G.7 sole cold provider under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: SHARED. */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_Func;
struct ast_Expr;

/* Module header field access via C struct when available from including TU.
 * Cold twin uses same layout as product Module (LP64 i32 header). */
typedef struct wave121_ModuleHdr {
  int32_t num_funcs;
  int32_t main_func_index;
  int32_t num_imports;
  int32_t num_top_level_lets;
  int32_t num_struct_layouts;
  int32_t pending_allow_padding;
  int32_t pending_soa_struct;
  int32_t pending_cfg_skip;
  int32_t pending_repr_c_struct;
  int32_t pending_repr_compatible_struct;
  int32_t pending_used;
  int32_t pending_naked;
  int32_t pending_entry;
  int32_t pending_no_mangle;
  int32_t pending_interrupt;
  int32_t pending_export;
  int32_t num_module_enums;
} wave121_ModuleHdr;

typedef struct wave121_ArenaHdr {
  int32_t num_types;
  int32_t num_exprs;
} wave121_ArenaHdr;

extern const char *link_abi_getenv(const char *name);
extern int32_t pipeline_module_func_is_export_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_name_len_at(void *m, int32_t fi);
extern void pipeline_module_func_name_copy64(void *m, int32_t fi, uint8_t *dst);
extern int32_t pipeline_module_func_name_equal_at(void *m, int32_t fi, const uint8_t *name, int32_t name_len);
extern int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_is_used_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_is_no_mangle_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_is_entry_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_is_interrupt_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_body_ref_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_body_expr_ref_at(void *m, int32_t fi);
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_call_callee_ref_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(void *a, int32_t expr_ref);
extern void pipeline_expr_var_name_into(void *a, int32_t expr_ref, uint8_t *out64);
extern int32_t pipeline_expr_method_call_name_len(void *a, int32_t expr_ref);
extern void pipeline_expr_method_call_name_into(void *a, int32_t expr_ref, uint8_t *out64);
extern int32_t driver_check_only_get(void);
extern int32_t lsp_diag_get_enabled(void);
extern void lsp_diag_add_code(int line, int col, int severity, const char *code, const char *msg);
extern void diag_report(const char *path, int line, int col, const char *kind, const char *msg, const char *code);
extern void ast_ast_arena_init(void *arena);
extern void ast_pool_module_reset(void *module);
extern void ast_pool_arena_reset(void *arena);
extern void parser_onefunc_result_layout_prime(void);
extern void parser_onefunc_result_layout_prime_b(void);
extern void parser_onefunc_result_layout_prime_c(void);
extern void parser_onefunc_result_layout_prime_d(void);
extern void parser_onefunc_result_layout_prime_d_b(void);
extern void parser_onefunc_result_layout_prime_e(void);
extern void parser_onefunc_result_layout_prime_f(void);
extern void pipeline_parser_set_match_module(void *module);

static int wave121_vis_cached = -1;
static const uint8_t *wave121_l7_source = NULL;
static int32_t wave121_l7_source_len = 0;

int32_t pipeline_module_num_funcs(void *m) {
  wave121_ModuleHdr *h = (wave121_ModuleHdr *)m;
  return h ? h->num_funcs : 0;
}

int32_t pipeline_module_main_func_index(void *m) {
  wave121_ModuleHdr *h = (wave121_ModuleHdr *)m;
  return h ? h->main_func_index : -1;
}

void pipeline_module_set_main_func_index(void *m, int32_t idx) {
  wave121_ModuleHdr *h = (wave121_ModuleHdr *)m;
  if (h)
    h->main_func_index = idx;
}

void pipeline_module_reset_parse_counters_c(void *module) {
  wave121_ModuleHdr *h = (wave121_ModuleHdr *)module;
  if (!h)
    return;
  h->num_funcs = 0;
  h->main_func_index = -1;
  h->num_imports = 0;
  h->num_top_level_lets = 0;
  h->num_struct_layouts = 0;
  h->num_module_enums = 0;
}

void pipeline_lint_set_source_buf(const uint8_t *data, int32_t len) {
  wave121_l7_source = data;
  wave121_l7_source_len = (data && len > 0) ? len : 0;
}

int32_t pipeline_visibility_mode(void) {
  const char *e;
  if (wave121_vis_cached >= 0)
    return wave121_vis_cached;
  e = link_abi_getenv("XLANG_VISIBILITY");
  if (!e || !e[0] || strcmp(e, "strict") == 0)
    wave121_vis_cached = 0;
  else if (strcmp(e, "warn") == 0)
    wave121_vis_cached = 1;
  else if (strcmp(e, "compat") == 0)
    wave121_vis_cached = 0;
  else
    wave121_vis_cached = 2;
  return wave121_vis_cached;
}

int32_t pipeline_visibility_allow_func(void *m, int32_t fi, int32_t cross_module) {
  int32_t mode;
  uint8_t name[256];
  int32_t nlen;
  if (!cross_module)
    return 1;
  mode = pipeline_visibility_mode();
  if (mode == 0)
    return 1;
  if (pipeline_module_func_is_export_at(m, fi) != 0)
    return 1;
  nlen = pipeline_module_func_name_len_at(m, fi);
  if (nlen == 4) {
    pipeline_module_func_name_copy64(m, fi, name);
    if (name[0] == 'm' && name[1] == 'a' && name[2] == 'i' && name[3] == 'n')
      return 1;
  }
  if (mode == 1) {
    pipeline_module_func_name_copy64(m, fi, name);
    nlen = pipeline_module_func_name_len_at(m, fi);
    if (nlen < 0)
      nlen = 0;
    if (nlen > 255)
    nlen = 255;
    pabi_trace( "warning: '%.*s' is not exported (XLANG_VISIBILITY=warn); "
                    "add `export` or it will error under strict\n",
            (int)nlen, (const char *)name);
    return 1;
  }
  return 0;
}

static int wave121_unused_private_enabled(void) {
  const char *e = link_abi_getenv("XLANG_UNUSED_PRIVATE");
  if (e && e[0]) {
    if (e[0] == '0' && e[1] == '\0')
      return 0;
    return 1;
  }
  if (driver_check_only_get() != 0)
    return 1;
  if (lsp_diag_get_enabled() != 0)
    return 1;
  return 0;
}

static int wave121_l7_find_func_def(const uint8_t *source, int32_t sl, const uint8_t *name, int32_t name_len,
                                   int *out_line, int *out_col) {
  static const uint8_t kw[] = {'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' '};
  int32_t i;
  int line = 1;
  int col = 1;
  if (!source || !name || name_len <= 0 || sl <= 0 || !out_line || !out_col)
    return 0;
  for (i = 0; i < sl; i++) {
    int boundary = (i == 0);
    if (!boundary) {
      uint8_t prev = source[i - 1];
      if (prev == ' ' || prev == '\t' || prev == '\n' || prev == '\r')
        boundary = 1;
    }
    if (boundary && i + 9 + name_len <= sl) {
      int ki;
      int kw_ok = 1;
      for (ki = 0; ki < 9; ki++) {
        if (source[i + ki] != kw[ki]) {
          kw_ok = 0;
          break;
        }
      }
      if (kw_ok) {
        int ni;
        int name_ok = 1;
        for (ni = 0; ni < name_len; ni++) {
          if (source[i + 9 + ni] != name[ni]) {
            name_ok = 0;
            break;
          }
        }
        if (name_ok) {
          int32_t after = i + 9 + name_len;
          uint8_t ac = (after < sl) ? source[after] : (uint8_t)' ';
          if (after >= sl || ac == ' ' || ac == '(' || ac == '\n' || ac == '\t' || ac == '<' || ac == '\r') {
            *out_line = line;
            *out_col = col + 9;
            return 1;
          }
        }
      }
    }
    if (source[i] == '\n') {
      line++;
      col = 1;
    } else {
      col++;
    }
  }
  return 0;
}

static void wave121_report_unused_private(const uint8_t *name, int32_t nlen) {
  char msg[192];
  int nl = (nlen > 0) ? (int)nlen : 0;
  int line = 1;
  int col = 1;
  if (nl > 255)
    nl = 63;
  snprintf(msg, sizeof msg, "unused private function '%.*s' (not export, not reachable in module)",
           nl, (const char *)(name ? name : (const uint8_t *)""));
  if (wave121_l7_source && wave121_l7_source_len > 0 && name && nlen > 0)
    (void)wave121_l7_find_func_def(wave121_l7_source, wave121_l7_source_len, name, nlen, &line, &col);
  if (lsp_diag_get_enabled()) {
    lsp_diag_add_code(line, col, 2, "L7", msg);
  } else {
    diag_report(NULL, line, col, "warning", msg, "L7");
  }
}

static void wave121_mark_local_call_names(void *a, uint8_t *used_flags, int32_t nfuncs, void *m) {
  int32_t er;
  int32_t nexpr;
  int32_t fi;
  if (!a || !used_flags || !m || nfuncs <= 0)
    return;
  nexpr = ((wave121_ArenaHdr *)a)->num_exprs;
  for (er = 1; er <= nexpr; er++) {
    int32_t ko = pipeline_expr_kind_ord_at(a, er);
    if (ko == 48) { /* EXPR_CALL */
      int32_t callee_ref = pipeline_expr_call_callee_ref_at(a, er);
      int32_t clen;
      uint8_t cname[256];
      if (callee_ref <= 0)
        continue;
      if (pipeline_expr_kind_ord_at(a, callee_ref) != 3)
        continue;
      clen = pipeline_expr_var_name_len(a, callee_ref);
      if (clen <= 0)
        continue;
      pipeline_expr_var_name_into(a, callee_ref, cname);
      for (fi = 0; fi < nfuncs; fi++) {
        if (pipeline_module_func_name_equal_at(m, fi, cname, clen))
          used_flags[fi] = 1;
      }
    } else if (ko == 49) { /* EXPR_METHOD_CALL */
      int32_t mlen = pipeline_expr_method_call_name_len(a, er);
      uint8_t mname[256];
      if (mlen <= 0)
        continue;
      pipeline_expr_method_call_name_into(a, er, mname);
      for (fi = 0; fi < nfuncs; fi++) {
        if (pipeline_module_func_name_equal_at(m, fi, mname, mlen))
          used_flags[fi] = 1;
      }
    }
  }
}

int32_t pipeline_typeck_unused_private_funcs(void *m, void *a) {
  int32_t nfuncs;
  int32_t fi;
  int32_t nwarn = 0;
  uint8_t *used = NULL;
  uint8_t name[256];
  int32_t nlen;
  if (!m || !a)
    return 0;
  if (!wave121_unused_private_enabled())
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs <= 0)
    return 0;
  used = (uint8_t *)calloc((size_t)nfuncs, 1);
  if (!used)
    return 0;
  wave121_mark_local_call_names(a, used, nfuncs, m);
  for (fi = 0; fi < nfuncs; fi++) {
    if (pipeline_module_func_is_export_at(m, fi) != 0)
      continue;
    if (pipeline_asm_module_func_is_extern_at(m, fi) != 0)
      continue;
    if (pipeline_module_func_is_used_at(m, fi) != 0 ||
        pipeline_module_func_is_no_mangle_at(m, fi) != 0 ||
        pipeline_module_func_is_entry_at(m, fi) != 0 ||
        pipeline_module_func_is_interrupt_at(m, fi) != 0)
      continue;
    nlen = pipeline_module_func_name_len_at(m, fi);
    if (nlen == 4) {
      pipeline_module_func_name_copy64(m, fi, name);
      if (name[0] == 'm' && name[1] == 'a' && name[2] == 'i' && name[3] == 'n')
        continue;
    }
    if (nlen <= 0)
      continue;
    if (pipeline_module_func_body_ref_at(m, fi) <= 0 &&
        pipeline_module_func_body_expr_ref_at(m, fi) <= 0)
      continue;
    if (used[fi] != 0)
      continue;
    pipeline_module_func_name_copy64(m, fi, name);
    wave121_report_unused_private(name, nlen);
    nwarn++;
  }
  free(used);
  return nwarn;
}

