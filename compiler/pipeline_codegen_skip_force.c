/* ============================================================================
 * pipeline_codegen_skip_force.c — codegen skip/force/override/path predicates
 *
 * wave1249 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c:
 *   call_num_args_override (table + lookup) + is_std_io_driver_bridge_name
 *   path_is_std_io_driver/core_bytes + dep_skip_asm_user_std_io/partial
 *   should_skip_emit_* (core_io_dup/trivial_handle/func)
 *   entry_is_lsp_io/lsp_main_module + force_param_* (size_t/ptrdiff_t/prefix_ok)
 *
 * C predicate helpers for codegen.x / asm backend skip & force-param logic.
 * Included from ast_pool.c (replaces former inline body). Not a separate .o.
 *
 * PLATFORM: SHARED.
 * ============================================================================ */
/**
 * codegen.x codegen_call_num_args_override：符号全名表（asm 不支持函数内 u8[N] 字面量）。
 * 命中返回 override 后的 num_args；未命中返回原 num_args。
 */
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
    {"std_fmt_println", 14, 2},
    {"std_fmt_print", 13, 2},
    {"std_debug_println", 16, 2},
    {"std_debug_print", 14, 2},
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
static int codegen_name_prefix_eq(uint8_t *name, int32_t name_len, const char *pfx, int32_t plen) {
  if (!name || name_len < plen)
    return 0;
  return memcmp(name, pfx, (size_t)plen) == 0 ? 1 : 0;
}

int32_t pipeline_codegen_is_std_io_driver_bridge_name(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if ((name_len == 8 || name_len == 9) && codegen_name_prefix_eq(name, name_len, "register", 8))
    return 1;
  if ((name_len == 11 || name_len == 12) && codegen_name_prefix_eq(name, name_len, "submit_read", 11))
    return 1;
  if ((name_len == 12 || name_len == 13) && codegen_name_prefix_eq(name, name_len, "submit_write", 12))
    return 1;
  if ((name_len == 13 || name_len == 14) && codegen_name_prefix_eq(name, name_len, "wait_readable", 13))
    return 1;
  /* register_fixed_buffers only (exact prefix); not submit_write_batch_buf (also len 22) */
  if (name_len == 22 && codegen_name_prefix_eq(name, name_len, "register_fixed_buffers", 22))
    return 1;
  /*
   * submit_*_batch(_buf) / submit_register_fixed_buffers_buf：不得 skip。
   * 与 codegen.x / seed bridge 对齐：call 端仍要 std_io_driver_submit_*_batch 真体；
   * skip 后仅剩 undef（或 weak -1 假红 run-io-driver）。
   */
  return 0;
}

/** import 路径逐字节含末尾 NUL 比较（codegen.x asm 无数组字面量）。 */
static int codegen_path_bytes_eq(uint8_t *path, const char *expect, int32_t len_with_nul) {
  int32_t i;
  if (!path)
    return 0;
  for (i = 0; i < len_with_nul; i++)
    if (path[i] != (uint8_t)expect[i])
      return 0;
  return 1;
}

/** prefix+name 拼接是否等于 full（总长须一致）。 */
static int codegen_prefix_name_bytes_eq(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
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
  return codegen_path_bytes_eq(path, "std.io.driver\0", 14);
}

/** codegen.x：import 路径是否为 std.io.core（含 NUL，12 字节）。 */
int32_t pipeline_codegen_path_is_std_io_core_bytes(uint8_t *path) {
  return codegen_path_bytes_eq(path, "std.io.core\0", 12);
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
    if (codegen_path_bytes_eq(path, k_exact[i], (int32_t)strlen(k_exact[i])))
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
  if ((name_len == 18 || name_len == 19) && codegen_name_prefix_eq(name, name_len, "xlang_io_read_fixed", 18))
    return 1;
  if ((name_len == 19 || name_len == 20) && codegen_name_prefix_eq(name, name_len, "xlang_io_write_fixed", 19))
    return 1;
  return 0;
}

/** codegen.x：std.io handle_* 字面量函数须跳过 emit；dep_path 为空时仅按 name 判断。 */
int32_t pipeline_codegen_should_skip_emit_std_io_trivial_handle(uint8_t *dep_path, uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (dep_path && !codegen_path_bytes_eq(dep_path, "std.io\0", 7))
    return 0;
  if ((name_len == 12 || name_len == 13) && codegen_name_prefix_eq(name, name_len, "handle_stdin", 12))
    return 1;
  if ((name_len == 13 || name_len == 14) && codegen_name_prefix_eq(name, name_len, "handle_stdout", 13))
    return 1;
  if ((name_len == 13 || name_len == 14) && codegen_name_prefix_eq(name, name_len, "handle_stderr", 13))
    return 1;
  if ((name_len == 15 || name_len == 16) && codegen_name_prefix_eq(name, name_len, "handle_from_fd", 15))
    return 1;
  return 0;
}

/** codegen.x：合并 driver_should_skip_emit 三套逻辑（原 codegen_should_skip_emit_func）。 */
int32_t pipeline_codegen_should_skip_emit_func(uint8_t *dep_path, uint8_t *prefix, int32_t prefix_len,
                                               uint8_t *name, int32_t name_len) {
  int32_t ok_path;
  if (prefix && prefix_len > 0 && name && name_len > 0) {
    if (codegen_prefix_name_bytes_eq(prefix, prefix_len, name, name_len, "std_io_driver_driver_read_ptr_len", 33))
      return 1;
    if (codegen_prefix_name_bytes_eq(prefix, prefix_len, name, name_len, "std_io_driver_driver_read_ptr", 29))
      return 1;
  }
  if (dep_path) {
    ok_path = codegen_path_bytes_eq(dep_path, "std.io.driver\0", 14);
    if (!ok_path)
      ok_path = codegen_path_bytes_eq(dep_path, "std.io\0", 7);
    if (ok_path && name) {
      if ((name_len == 19 || name_len == 20) &&
          codegen_name_prefix_eq(name, name_len, "driver_read_ptr_len", 19))
        return 1;
      if ((name_len == 15 || name_len == 16) && codegen_name_prefix_eq(name, name_len, "driver_read_ptr", 15))
        return 1;
    }
  }
  if (prefix && prefix_len == 14 && name &&
      codegen_name_prefix_eq(prefix, prefix_len, "std_io_driver_", 14) &&
      pipeline_codegen_is_std_io_driver_bridge_name(name, name_len))
    return 1;
  if (dep_path && name && codegen_path_bytes_eq(dep_path, "std.io.driver\0", 14) &&
      pipeline_codegen_is_std_io_driver_bridge_name(name, name_len))
    return 1;
  if (prefix && prefix_len == 14 && name &&
      pipeline_codegen_should_skip_emit_std_io_trivial_handle(0, name, name_len))
    return 1;
  if (dep_path && name) {
    if (pipeline_codegen_should_skip_emit_std_io_core_io_dup(dep_path, name, name_len))
      return 1;
    if (codegen_path_bytes_eq(dep_path, "std.io.driver\0", 14) &&
        pipeline_codegen_should_skip_emit_std_io_trivial_handle(0, name, name_len))
      return 1;
  }
  return 0;
}

/** codegen.x：entry 模块是否含 read_message（LSP io 入口探测）。 */
int32_t pipeline_codegen_entry_is_lsp_io_module(struct ast_Module *module) {
  static const uint8_t rd[] = "read_message";
  int32_t i;
  int32_t n;
  if (!module)
    return 0;
  n = (int32_t)module->num_funcs;
  for (i = 0; i < n; i++) {
    if (pipeline_module_func_name_equal_at(module, i, (uint8_t *)rd, 12))
      return 1;
  }
  return 0;
}

/** codegen.x：entry 模块是否含 lsp_main。 */
int32_t pipeline_codegen_entry_is_lsp_main_module(struct ast_Module *module) {
  static const uint8_t main_nm[] = "lsp_main";
  int32_t i;
  int32_t n;
  if (!module)
    return 0;
  n = (int32_t)module->num_funcs;
  for (i = 0; i < n; i++) {
    if (pipeline_module_func_name_equal_at(module, i, (uint8_t *)main_nm, 8))
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
  if (name_len == 21 && codegen_name_prefix_eq(name, name_len, "submit_read_batch_buf", 21))
    return 1;
  if (name_len == 22 && codegen_name_prefix_eq(name, name_len, "submit_write_batch_buf", 22))
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
  if (name_len == 8 && codegen_name_prefix_eq(name, name_len, "register", 8))
    return 1;
  if (name_len == 11 && codegen_name_prefix_eq(name, name_len, "submit_read", 11))
    return 1;
  if (name_len == 12 && codegen_name_prefix_eq(name, name_len, "submit_write", 12))
    return 1;
  return 0;
}

/** codegen.x：std_io_driver 按名/下标强制 uint32_t（timeout_ms/nr）。 */
int32_t pipeline_codegen_force_param_uint32_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                              int32_t param_index) {
  if (!pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) || !name)
    return 0;
  if (param_index == 1) {
    if (name_len == 11 && codegen_name_prefix_eq(name, name_len, "submit_read", 11))
      return 1;
    if (name_len == 12 && codegen_name_prefix_eq(name, name_len, "submit_write", 12))
      return 1;
    if (name_len == 33 && codegen_name_prefix_eq(name, name_len, "submit_register_fixed_buffers_buf", 33))
      return 1;
    return 0;
  }
  if (param_index == 3) {
    if (name_len == 21 && codegen_name_prefix_eq(name, name_len, "submit_read_batch_buf", 21))
      return 1;
    if (name_len == 22 && codegen_name_prefix_eq(name, name_len, "submit_write_batch_buf", 22))
      return 1;
  }
  return 0;
}
