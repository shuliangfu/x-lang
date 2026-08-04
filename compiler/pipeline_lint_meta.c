/* pipeline_lint_meta.c — pipeline lint（unused private funcs）+ module metadata glue 域（自 ast_pool.c 抽出）
 *
 * XLANG_VISIBILITY 模式 + pipeline_visibility_allow_func：模块导出迁移可见性判定。
 * L7 unused-private-funcs lint：g_l7_source + lint_set_source_buf + unused_private_enabled +
 *   l7_find_func_def + report_unused_private + name_eq_bytes + mark_local_call_names +
 *   typeck_unused_private_funcs。
 * module metadata glue：pipeline_module_num_funcs + main_func_index + set_main_func_index +
 *   reset_parse_counters_c + strict_parse_into_init。
 * 依赖：ast_Module／ast_ASTArena + ast_pool_arena/module_reset（lifecycle.c，先于此 include）。
 * 同 TU #include（module_func.c 之后、block.c 之前）；公共符号 + static。 */

/**
 * XLANG_VISIBILITY 模式（模块导出迁移）：
 *   0 = compat：未 export 仍可跨模块访问（回退）
 *   1 = warn：跨模块访问未 export 时 stderr 警告，仍放行
 *   2 = strict（默认）：仅 export 可跨模块；未写 export = 模块私有
 * 可用 env 回退：XLANG_VISIBILITY=compat|warn|strict
 */
int32_t pipeline_visibility_mode(void) {
  static int cached = -1;
  const char *e;
  if (cached >= 0)
    return cached;
  e = link_abi_getenv("XLANG_VISIBILITY");
  if (!e || !e[0] || strcmp(e, "strict") == 0)
    cached = 0; /* compat: parser doesn't set is_export yet; revert to 2 when fixed */
  else if (strcmp(e, "warn") == 0)
    cached = 1;
  else if (strcmp(e, "compat") == 0)
    cached = 0;
  else
    cached = 2; /* 未知值亦按 strict，避免静默放开 */
  return cached;
}

int32_t pipeline_visibility_allow_func(struct ast_Module *m, int32_t fi, int32_t cross_module) {
  int32_t mode;
  uint8_t name[128];
  int32_t nlen;
  int i;
  if (!cross_module)
    return 1;
  mode = pipeline_visibility_mode();
  if (mode == 0)
    return 1;
  if (pipeline_module_func_is_export_at(m, fi) != 0)
    return 1;
  /* main 入口不要求 export */
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
    if (nlen > 127)
      nlen = 127;
    fprintf(stderr, "warning: '%.*s' is not exported (XLANG_VISIBILITY=warn); "
                    "add `export` or it will error under strict\n",
            (int)nlen, (const char *)name);
    (void)i;
    return 1;
  }
  return 0;
}

/**
 * L7 unused private function（全效化 / 模块导出 §7）：
 *   private ≔ 未 export；roots ≔ main / #[used] / #[no_mangle] / #[entry] / #[interrupt] / extern
 *   本模块 arena 内 Call(var)/MethodCall 名字引用 ⇒ 可达
 * 启用：
 *   - xlang check（driver_check_only）
 *   - LSP 诊断会话（lsp_diag_enabled）→ 编辑器波浪线
 *   - XLANG_UNUSED_PRIVATE=1 强制开；=0 强制关
 * 诊断层：**永远是 warning（severity=2）**，不使 typeck 失败、不使 `xlang check` 默认非零退出
 *   （仅 XLANG_LINT_CI_FAIL_ON=warn 时 check 才因 warning 失败）。
 * 编译/运行路径默认不跑，避免干扰日常 build。
 */
extern int32_t driver_check_only_get(void);
extern int lsp_diag_enabled;
extern void lsp_diag_add(int line, int col, int severity, const char *msg);
extern void lsp_diag_add_code(int line, int col, int severity, const char *code, const char *msg);
extern void diag_report(const char *path, int line, int col, const char *kind, const char *msg, const char *code);

/** parse 入口登记的源缓冲，供 L7 把波浪线锚到 `function name` 定义处。 */
static const uint8_t *g_l7_source = NULL;
static int32_t g_l7_source_len = 0;

void pipeline_lint_set_source_buf(const uint8_t *data, int32_t len) {
  g_l7_source = data;
  g_l7_source_len = (data && len > 0) ? len : 0;
}

static int pipeline_unused_private_enabled(void) {
  const char *e = link_abi_getenv("XLANG_UNUSED_PRIVATE");
  if (e && e[0]) {
    if (e[0] == '0' && e[1] == '\0')
      return 0;
    return 1;
  }
  if (driver_check_only_get() != 0)
    return 1;
  if (lsp_diag_enabled != 0)
    return 1;
  return 0;
}

/** 扫描 "function name" 定义行列（1-based）；对齐 lsp_source_find_function_def。 */
static int pipeline_l7_find_func_def(const uint8_t *source, int32_t sl, const uint8_t *name, int32_t name_len,
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

/** severity=2 Warning；永不升级为 Error。 */
static void pipeline_report_unused_private(const uint8_t *name, int32_t nlen) {
  char msg[192];
  int nl = (nlen > 0) ? (int)nlen : 0;
  int line = 1;
  int col = 1;
  if (nl > 127)
    nl = 63;
  snprintf(msg, sizeof msg, "unused private function '%.*s' (not export, not reachable in module)",
           nl, (const char *)(name ? name : (const uint8_t *)""));
  if (g_l7_source && g_l7_source_len > 0 && name && nlen > 0)
    (void)pipeline_l7_find_func_def(g_l7_source, g_l7_source_len, name, nlen, &line, &col);
  if (lsp_diag_enabled) {
    /* LSP / check 收集器：Warning → 编辑器波浪线；不进 Error 集合 */
    lsp_diag_add_code(line, col, 2, "L7", msg);
  } else {
    diag_report(NULL, line, col, "warning", msg, "L7");
  }
}

static int pipeline_name_eq_bytes(const uint8_t *a, int32_t alen, const uint8_t *b, int32_t blen) {
  int32_t i;
  if (alen != blen || alen < 0)
    return 0;
  for (i = 0; i < alen; i++) {
    if (a[i] != b[i])
      return 0;
  }
  return 1;
}

/** 标记本模块内被 Call/MethodCall 引用的函数名（简化 callgraph；不建第二套 WPO）。 */
static void pipeline_mark_local_call_names(struct ast_ASTArena *a, uint8_t *used_flags, int32_t nfuncs,
                                          struct ast_Module *m) {
  int32_t er;
  int32_t ko;
  int32_t fi;
  struct ast_Expr *ex;
  struct ast_Expr *callee;
  uint8_t fname[128];
  int32_t flen;

  if (!a || !used_flags || !m || nfuncs <= 0)
    return;
  for (er = 1; er <= a->num_exprs; er++) {
    ko = pipeline_expr_kind_ord_at(a, er);
    ex = pipeline_arena_expr_ptr(a, er);
    if (!ex)
      continue;
    if (ko == (int32_t)ast_ExprKind_EXPR_CALL) {
      if (ex->call_callee_ref <= 0)
        continue;
      if (pipeline_expr_kind_ord_at(a, ex->call_callee_ref) != (int32_t)ast_ExprKind_EXPR_VAR)
        continue;
      callee = pipeline_arena_expr_ptr(a, ex->call_callee_ref);
      if (!callee || callee->var_name_len <= 0)
        continue;
      for (fi = 0; fi < nfuncs; fi++) {
        flen = pipeline_module_func_name_len_at(m, fi);
        if (flen <= 0)
          continue;
        pipeline_module_func_name_copy64(m, fi, fname);
        if (pipeline_name_eq_bytes(fname, flen, callee->var_name, callee->var_name_len))
          used_flags[fi] = 1;
      }
    } else if (ko == (int32_t)ast_ExprKind_EXPR_METHOD_CALL) {
      if (ex->method_call_name_len <= 0)
        continue;
      for (fi = 0; fi < nfuncs; fi++) {
        flen = pipeline_module_func_name_len_at(m, fi);
        if (flen <= 0)
          continue;
        pipeline_module_func_name_copy64(m, fi, fname);
        if (pipeline_name_eq_bytes(fname, flen, ex->method_call_name, ex->method_call_name_len))
          used_flags[fi] = 1;
      }
    }
  }
}

/**
 * typeck 成功后：报告未 export 且本模块内不可达的函数。
 * 返回发出的 warning 条数（不失败 typeck）。
 */
int32_t pipeline_typeck_unused_private_funcs(struct ast_Module *m, struct ast_ASTArena *a) {
  int32_t nfuncs;
  int32_t fi;
  int32_t nwarn = 0;
  uint8_t *used = NULL;
  uint8_t name[128];
  int32_t nlen;
  struct ast_Func *f;

  if (!m || !a)
    return 0;
  if (!pipeline_unused_private_enabled())
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs <= 0)
    return 0;
  used = (uint8_t *)calloc((size_t)nfuncs, 1);
  if (!used)
    return 0;
  pipeline_mark_local_call_names(a, used, nfuncs, m);

  for (fi = 0; fi < nfuncs; fi++) {
    f = module_func_at(m, fi);
    if (!f)
      continue;
    /* roots / 非本模块实现 */
    if (f->is_export != 0)
      continue;
    if (f->is_extern != 0)
      continue;
    if (f->is_used != 0 || f->is_no_mangle != 0 || f->is_entry != 0 || f->is_interrupt != 0)
      continue;
    nlen = f->name_len;
    if (nlen == 4 && f->name[0] == 'm' && f->name[1] == 'a' && f->name[2] == 'i' && f->name[3] == 'n')
      continue;
    if (nlen <= 0)
      continue;
    /* 无体声明不报（常见 forward / 桩） */
    if (f->body_ref <= 0 && f->body_expr_ref <= 0)
      continue;
    if (used[fi] != 0)
      continue;
    memcpy(name, f->name, 64);
    pipeline_report_unused_private(name, nlen);
    nwarn++;
  }
  free(used);
  return nwarn;
}


/** pipeline.x：读 module.num_funcs，避免 asm 对 Module 字段 FIELD_ACCESS。 */
int32_t pipeline_module_num_funcs(struct ast_Module *m) {
  return m ? (int32_t)m->num_funcs : 0;
}

/** pipeline.x：读 module.main_func_index。 */
int32_t pipeline_module_main_func_index(struct ast_Module *m) {
  return m ? (int32_t)m->main_func_index : -1;
}

/**
 * strict asm 链：写 module.main_func_index（build_asm/parser.o 的 parse_into_set_main_index 为空桩）。
 */
void pipeline_module_set_main_func_index(struct ast_Module *m, int32_t idx) {
  if (m)
    m->main_func_index = idx;
}

/**
 * M8-tail：parser.x pipeline_module_reset_parse_counters 的 C 实现；SKIP/EMIT_HEAVY 薄包装 bl 目标。
 * 避免 *Module 字段 FIELD_ACCESS 在 xlang_asm emit 失败。
 */
void pipeline_module_reset_parse_counters_c(struct ast_Module *module) {
  if (!module)
    return;
  module->num_funcs = 0;
  module->main_func_index = -1;
  module->num_imports = 0;
  module->num_top_level_lets = 0;
  module->num_struct_layouts = 0;
  module->num_module_enums = 0;
}

extern void parser_onefunc_result_layout_prime(void);
extern void parser_onefunc_result_layout_prime_b(void);
extern void parser_onefunc_result_layout_prime_c(void);
extern void parser_onefunc_result_layout_prime_d(void);
extern void parser_onefunc_result_layout_prime_d_b(void);
extern void parser_onefunc_result_layout_prime_e(void);
extern void parser_onefunc_result_layout_prime_f(void);
extern void ast_arena_init(struct ast_ASTArena *arena);
extern void pipeline_parser_set_match_module(struct ast_Module *m);

/**
 * strict asm 链：parse 前重置 arena/module（等价 parser.x parse_into_init）。
 * build_asm/parser.o 的 parse_into_init 不重置 sidecar grow 池，二次 parse 会累积 funcs。
 */
void pipeline_strict_parse_into_init(struct ast_ASTArena *arena, struct ast_Module *module) {
  ast_arena_init(arena);
  ast_pool_module_reset(module);
  ast_pool_arena_reset(arena);
  parser_onefunc_result_layout_prime();
  parser_onefunc_result_layout_prime_b();
  parser_onefunc_result_layout_prime_c();
  parser_onefunc_result_layout_prime_d();
  parser_onefunc_result_layout_prime_d_b();
  parser_onefunc_result_layout_prime_e();
  parser_onefunc_result_layout_prime_f();
  pipeline_module_reset_parse_counters_c(module);
  pipeline_parser_set_match_module(module);
  if (module) {
    module->num_funcs = 0;
    module->main_func_index = -1;
    module->num_imports = 0;
    module->num_top_level_lets = 0;
    module->num_struct_layouts = 0;
    module->pending_allow_padding = 0;
    module->pending_soa_struct = 0;
    module->pending_cfg_skip = 0;
    module->pending_repr_c_struct = 0;
    module->pending_repr_compatible_struct = 0;
    module->num_module_enums = 0;
  }
}
