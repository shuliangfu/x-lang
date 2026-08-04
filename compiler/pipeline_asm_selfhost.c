/* ============================================================================
 * pipeline_asm_selfhost.c — backend asm module self-host classification
 *
 * wave1257 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c:
 *   asm_module_num_defined_funcs / asm_module_defined_func_ordinal
 *   + asm_module_is_backend_selfhost
 *   + asm_module_is_typeck_selfhost
 *   + asm_module_is_pipeline_selfhost
 *   + asm_module_is_main_driver_selfhost
 *   + asm_module_is_driver_compile_selfhost
 *   + asm_module_is_parser_selfhost
 *   + asm_module_is_parser_emit_heavy
 *
 * Classify which self-host unit a module is (backend.x / typeck.x /
 * pipeline.x / main.x / driver/compile.x / parser.x) by function-name
 * probing + defined-func count heuristics. Used by skip_typeck whitelist,
 * emit_heavy_safe_helper, and WPO reach.
 * Included from ast_pool.c (replaces former inline body). Not a separate .o.
 * Forward decls at L4595/L1959 (ast_pool.c) remain in host TU.
 *
 * PLATFORM: SHARED.
 * ============================================================================ */

/**
 * 模块内非 extern 函数个数。
 * typeck.x 声明大量 extern pipeline/driver 符号时 num_funcs≈175，可 emit 体仅 ~78。
 */
static int32_t asm_module_num_defined_funcs(struct ast_Module *m) {
  int32_t i, n = 0;
  if (!m)
    return 0;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_asm_module_func_is_extern_at(m, i) == 0)
      n++;
  }
  return n;
}

/**
 * func_index 在「已定义（非 extern）」函数中的序号（0..ndef-1）；index 为 extern 时返回 -1。
 * EMIT_HEAVY 瘦 typeck 的 #0–#35 须按此序号，勿用含 extern 占位的 raw func_index。
 */
static int32_t asm_module_defined_func_ordinal(struct ast_Module *m, int32_t func_index) {
  int32_t i, ord = 0;
  if (!m || func_index < 0 || func_index >= m->num_funcs)
    return -1;
  if (pipeline_asm_module_func_is_extern_at(m, func_index) != 0)
    return -1;
  for (i = 0; i < func_index; i++) {
    if (pipeline_asm_module_func_is_extern_at(m, i) == 0)
      ord++;
  }
  return ord;
}

/** 模块是否 backend.x 自举单元（asm_codegen_ast 或 M8-tail 薄包装探针）。 */
static int32_t asm_module_is_backend_selfhost(struct ast_Module *m) {
  int32_t i;
  if (!m || m->num_funcs < 80)
    return 0;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"asm_codegen_ast", 15))
      return 1;
  }
  /** 瘦 backend（~100 func）仍含 emit_expr_elf / fill_param_slots 等薄包装符号。 */
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"emit_expr_elf", 13))
      return 1;
  }
  return 0;
}

/** 模块是否 typeck.x 自举单元（含 typeck_x_ast 或合并 glue 后约 168–180 func）。 */
static int32_t asm_module_is_typeck_selfhost(struct ast_Module *m) {
  int32_t i;
  if (!m || m->num_funcs < 40)
    return 0;
  /** ast.x ndef 规模与 typeck 重叠；须排除 ast_arena_init/ast_placeholder 标记。 */
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"ast_arena_init", 14))
      return 0;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"ast_placeholder", 15))
      return 0;
  }
  /** parser.x ndef≈130–200 勿落入下方 75–155 启发式（误判则走 typeck EMIT 路径）。 */
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"pipeline_module_reset_parse_counters", 36))
      return 0;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"parse_into_init", 15))
      return 0;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"skip_one_struct_into_buf", 24))
      return 0;
  }
  if (pipeline_module_func_name_equal_at(m, 0, (uint8_t *)"type_kind_ordinal", 17))
    return 1;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"typeck_x_ast", 12))
      return 1;
  }
  /** ENTRY_MODULE_ONLY 编 typeck.x：按已定义 func 规模识别（extern 占位不计入）。 */
  {
    int32_t ndef = asm_module_num_defined_funcs(m);
    if (ndef >= 75 && ndef <= 155)
      return 1;
    if (ndef >= 160 && ndef <= 180)
      return 1;
  }
  return 0;
}

/**
 * 模块是否 pipeline.x 自举单元（含 extern 占位时 num_funcs 可达 ~70；按 resolve_path_x 等符号名判定）。
 */
static int32_t asm_module_is_pipeline_selfhost(struct ast_Module *m) {
  int32_t i;
  int32_t has_resolve;
  int32_t has_marker;
  if (!m || m->num_funcs < 12)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_typeck_selfhost(m))
    return 0;
  has_resolve = 0;
  has_marker = 0;
  for (i = 0; i < m->num_funcs; i++) {
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

/**
 * 模块是否 main.x 驱动单元（~28 func；entry + run_compiler_x_path_impl）。
 * build_asm/main.o 须走 SKIP 桩 + WPO，勿当用户程序全量 emit（9460B）。
 */
static int32_t asm_module_is_main_driver_selfhost(struct ast_Module *m) {
  int32_t i;
  int32_t has_entry;
  int32_t has_run_path;
  int32_t ndef;
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
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"entry", 5))
      has_entry = 1;
    /** main.x export is main_run_compiler_x_path_impl (historical bare run_compiler_x_path_impl renamed). */
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"main_run_compiler_x_path_impl", 29) ||
        pipeline_module_func_name_equal_at(m, i, (uint8_t *)"run_compiler_x_path_impl", 24))
      has_run_path = 1;
  }
  return has_entry != 0 && has_run_path != 0;
}

/**
 * 模块是否 driver/compile.x 自举单元（~26 func；compile_dispatch_* 可能未进 module 表，用 parse_argv + entry 判定）。
 */
static int32_t asm_module_is_driver_compile_selfhost(struct ast_Module *m) {
  int32_t i;
  int32_t has_parse_argv;
  int32_t has_entry;
  /**
   * compile.x：~26 defined + many export extern (FFI) → num_funcs often ~60–80.
   * PLATFORM: SHARED — do not use a tight >48 cap (was false-negative after Cap-T001 extern growth).
   */
  if (!m || m->num_funcs < 8 || m->num_funcs > 120)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_typeck_selfhost(m) ||
      asm_module_is_pipeline_selfhost(m) || asm_module_is_parser_selfhost(m))
    return 0;
  has_parse_argv = 0;
  has_entry = 0;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"driver_compile_parse_argv", 25))
      has_parse_argv = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"run_compiler_full_x", 19))
      has_entry = 1;
    /** gen.o 路径可能注册 dispatch；单编 compile.x 时常缺失，作可选辅助。 */
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"compile_dispatch_asm_backend", 28))
      has_parse_argv = 1;
  }
  return has_parse_argv != 0 && has_entry != 0;
}

/**
 * 模块是否 parser.x 自举单元（~288 func；parse_into_buf 可能未进 module 表，用 parse_into_init 等判定）。
 * strict 链 parse_into_* 真机码由 pipeline_x partial / C alias 提供；func 数 >200 时仍须识别，否则
 * whitelist 会对 parse_into_buf 真 emit → .L_* 未解析 / code_len 截断。
 */
static int32_t asm_module_is_parser_selfhost(struct ast_Module *m) {
  int32_t i;
  int32_t has_parse_marker;
  int32_t has_reset;
  if (!m || m->num_funcs < 150 || m->num_funcs > 1450)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_pipeline_selfhost(m))
    return 0;
  has_parse_marker = 0;
  has_reset = 0;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"pipeline_module_reset_parse_counters", 36))
      has_reset = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"parse_into_init", 15))
      has_parse_marker = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"parse_into_set_main_index", 25))
      has_parse_marker = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"skip_one_struct_into_buf", 24))
      has_parse_marker = 1;
  }
  /** reset 已足够识别 parser.x；勿被 typeck ndef 启发式抢先（2026-06-14）。 */
  if (has_reset != 0 && has_parse_marker == 0 && m->num_funcs >= 200)
    has_parse_marker = 1;
  if (has_reset == 0)
    return 0;
  if (asm_module_is_typeck_selfhost(m) && has_parse_marker == 0)
    return 0;
  return has_parse_marker != 0;
}

/** EMIT_HEAVY 第二遍：parser.x 识别（reset 计数器存在即可；marker 偶发缺失时仍走 parser 路径）。 */
static int32_t asm_module_is_parser_emit_heavy(struct ast_Module *m) {
  int32_t i;
  if (!m || m->num_funcs < 150 || m->num_funcs > 1450)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_pipeline_selfhost(m))
    return 0;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"pipeline_module_reset_parse_counters", 36))
      return 1;
  }
  return asm_module_is_parser_selfhost(m);
}

/* ── ast.x / compiler 自举判定（补全 9 谓词全集；自 ast_pool.c 抽出）── */
/* is_ast_selfhost 须先于 typeck ndef 启发式；is_compiler_selfhost 为 8 谓词之 OR（用户小程序排除）。 */

/**
 * 模块是否 ast.x 自举单元（~40–222 func；须桩化首遍 emit，否则 seed xlang 全量真 emit 极慢）。
 * 须先于 typeck ndef 启发式识别（ast ndef≈75–155 会被误判为 typeck.x）。
 */
static int32_t asm_module_is_ast_selfhost(struct ast_Module *m) {
  int32_t i;
  int32_t has_arena_init;
  int32_t has_placeholder;
  if (!m || m->num_funcs < 15 || m->num_funcs > 250)
    return 0;
  has_arena_init = 0;
  has_placeholder = 0;
  for (i = 0; i < m->num_funcs; i++) {
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

/** 模块是否为 compiler .x 自举单元；用户小程序（pool-limits / 普通 -o）不在此列。 */
static int32_t asm_module_is_compiler_selfhost(struct ast_Module *m) {
  return asm_module_is_ast_selfhost(m) || asm_module_is_backend_selfhost(m) ||
         asm_module_is_typeck_selfhost(m) || asm_module_is_pipeline_selfhost(m) ||
         asm_module_is_parser_selfhost(m) || asm_module_is_parser_emit_heavy(m) ||
         asm_module_is_driver_compile_selfhost(m) || asm_module_is_main_driver_selfhost(m);
}
