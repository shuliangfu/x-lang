/**
 * pipeline_asm_emit_heavy_env.c — EMIT_HEAVY env gates, slot thresholds,
 * path helpers, and SKIP_TYPECK entry whitelist.
 *
 * wave1280 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c residual:
 *   ASM_HEAVY_BODY_SLOT_THRESHOLD / ASM_EMIT_HEAVY_* index+slot macros
 *   asm_emit_heavy_abort_{lo,hi}
 *   asm_driver_current_dep_path_for_codegen / asm_import_path_to_c_prefix_into
 *   asm_module_top_level_const_lit_i32
 *   asm_env_{build_skip_typeck,strict_orchestration,entry_emit_heavy}
 *   asm_skip_typeck_entry_whitelist / asm_orchestration_extern_only_func
 *   g_asm_skip_pipeline_ctx / asm_skip_heavy_set_pipeline_ctx
 *   pipeline_module_func_name_has_prefix_at
 *
 * Include AFTER: pool module_func / top_level / dep_ctx faces (name_equal_at,
 * top_level_let_*, expr_kind/int). Include BEFORE: pipeline_asm_selfhost.c
 * (whitelist uses extern forward of asm_module_is_parser_selfhost pure leave), then
 * emit_heavy_safe_helper / thin_delegate / parser_emit_heavy / skip_dispatch.
 *
 * PLATFORM: SHARED — host-cc residual; G.7 single authority for emit-heavy
 * env gates. Still textually #include'd into pipeline_glue / pipeline_x.
 */

/** Slot threshold: full asm emit of large block trees risks host stack overflow. */
#define ASM_HEAVY_BODY_SLOT_THRESHOLD 48
/** EMIT_HEAVY second pass relaxes slots (layout helpers); still below mega typecheck bodies. */
#define ASM_EMIT_HEAVY_SLOT_THRESHOLD 256
/** backend.x self-host (~219 funcs with import expand): index stubs for #87–218; #0–86 real emit. */
#define ASM_EMIT_HEAVY_BACKEND_INDEX_LO 87
#define ASM_EMIT_HEAVY_BACKEND_INDEX_HI 218
/** typeck.x ~173 funcs: deep-emit abort #90–159; #0–89 layout helpers and #160+ may real-emit. */
#define ASM_EMIT_HEAVY_TYPECK_INDEX_LO 90
#define ASM_EMIT_HEAVY_TYPECK_INDEX_HI 159
/** pipeline.x ~56 funcs: orchestration entries #53–#55 must real-emit; index stubs removed. */
/** XLANG_ASM_EMIT_ABORT_LO/HI defaults (backend bisect debug). */
#define ASM_EMIT_HEAVY_LARGE_ENTRY_LO ASM_EMIT_HEAVY_BACKEND_INDEX_LO
#define ASM_EMIT_HEAVY_LARGE_ENTRY_HI ASM_EMIT_HEAVY_BACKEND_INDEX_HI

/** Large-entry backend (num_funcs>=175) EMIT_HEAVY slot threshold (tighter than 256). */
#define ASM_EMIT_HEAVY_LARGE_BACKEND_SLOT_THRESHOLD 96
/** Backend helper whitelist real-emit block-tree slot cap (larger still index-stubbed). */
#define ASM_EMIT_HEAVY_BACKEND_HELPER_SLOT_MAX 48
/** typeck layout helpers may use slightly larger frames (merge_dep dual loop ~110 slots). */
#define ASM_EMIT_HEAVY_TYPECK_LAYOUT_SLOT_MAX 128

/** Read XLANG_ASM_EMIT_ABORT_LO/HI: bisect Abort ranges (defaults = large-entry constants). */
static int32_t asm_emit_heavy_abort_lo(void) {
  const char *e = link_abi_getenv("XLANG_ASM_EMIT_ABORT_LO");
  char *end = NULL;
  long v;
  if (!e || e[0] == '\0')
    return ASM_EMIT_HEAVY_LARGE_ENTRY_LO;
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return ASM_EMIT_HEAVY_LARGE_ENTRY_LO;
  return (int32_t)v;
}

static int32_t asm_emit_heavy_abort_hi(void) {
  const char *e = link_abi_getenv("XLANG_ASM_EMIT_ABORT_HI");
  char *end = NULL;
  long v;
  if (!e || e[0] == '\0')
    return ASM_EMIT_HEAVY_LARGE_ENTRY_HI;
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return ASM_EMIT_HEAVY_LARGE_ENTRY_HI;
  return (int32_t)v;
}

/**
 * Align with typeck.x::typeck_skip_heavy_selfhost_func_body; auto-skip oversized
 * bodies by block-tree slot count. Library modules with -backend asm -o emit a
 * minimal ret 0 stub so __text stays non-empty and compile avoids SIGSEGV.
 */
/**
 * If a module top-level let/const is an integer literal init, return 1 and write
 * *out_imm (asm EXPR_VAR can mov imm directly).
 */
#ifndef XLANG_PIPELINE_GLUE_STANDALONE_TU
/** runtime.c: current import logical path set during dep-module asm codegen. */
extern const char *driver_get_current_dep_path_for_codegen(void);
#endif

/**
 * Face for backend.x to read dep path (avoids codegen name-mangling link mismatches).
 * Under B-strict standalone TU, driver_get is declared uint8_t * in pipeline_glue_types.inc.
 */
uint8_t *asm_driver_current_dep_path_for_codegen(void) {
#ifndef XLANG_PIPELINE_GLUE_STANDALONE_TU
  const char *p = driver_get_current_dep_path_for_codegen();
  return (uint8_t *)(p ? p : "");
#else
  uint8_t *p = driver_get_current_dep_path_for_codegen();
  return p ? p : (uint8_t *)"";
#endif
}

/**
 * Convert import path to C symbol prefix (matches codegen.c::import_path_to_c_prefix).
 */
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

int32_t asm_module_top_level_const_lit_i32(struct ast_Module *m, struct ast_ASTArena *a, uint8_t *name,
    int32_t name_len, int32_t *out_imm) {
  int32_t tl;
  int32_t nl;
  int32_t k;
  int32_t init_ref;
  if (!m || !a || !name || name_len <= 0 || !out_imm)
    return 0;
  for (tl = 0; tl < m->num_top_level_lets; tl++) {
    nl = pipeline_module_top_level_let_name_len(m, tl);
    if (nl != name_len || nl <= 0)
      continue;
    for (k = 0; k < name_len; k++) {
      if (pipeline_module_top_level_let_name_byte_at(m, tl, k) != name[k])
        break;
    }
    if (k != name_len)
      continue;
    init_ref = pipeline_module_top_level_let_init_ref(m, tl);
    if (init_ref <= 0 || init_ref > a->num_exprs)
      continue;
    k = pipeline_expr_kind_ord_at(a, init_ref);
    if (k == 0 || k == 2) {
      *out_imm = pipeline_expr_int_val_at(a, init_ref);
      return 1;
    }
  }
  return 0;
}

/** XLANG_ASM_BUILD_SKIP_TYPECK=1: build_xlang_asm uses stub path (avoid stack overflow). */
static int32_t asm_env_build_skip_typeck(void) {
  const char *e = link_abi_getenv("XLANG_ASM_BUILD_SKIP_TYPECK");
  return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

/** XLANG_ASM_STRICT_ORCHESTRATION=1: C orch chain skips large pipeline emits (default build_asm keeps real code). */
static int32_t asm_env_strict_orchestration(void) {
  const char *e = link_abi_getenv("XLANG_ASM_STRICT_ORCHESTRATION");
  return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

/** Parser bootstrap whitelist entry: { name, len }; minimal/full arrays share typedef. */
typedef struct {
  const char *name;
  int32_t len;
} asm_boot_parse_sym_t;

/** Non-zero: entry source is too large; merge/library typeck should skip (runtime.c). */
extern int32_t driver_typeck_skip_large_entry(void);

/** Forward: parser self-host predicate (wave115 pure-owned leave; product link pure). */
extern int32_t asm_module_is_parser_selfhost(struct ast_Module *m);

/**
 * Under SKIP_TYPECK full-stub mode, entries that must keep real machine code
 * (experimental asm-only chain and xlang_asm smoke tests). Return 1 = do not stub via asm_skip_heavy.
 * Large modules (backend.x) also define asm_codegen_ast; full emit of that would abort on host stack.
 */
static int32_t asm_skip_typeck_entry_whitelist(struct ast_Module *m, int32_t func_index) {
  static const struct {
    const char *name;
    int32_t len;
    int32_t allow_on_large_entry;
  } k_keep[] = {
      /** parse_into_with_init_buf real emit deep-stack SIGSEGV; build chain uses parser.o / C alias. */
      {"pipeline_impl_run_all", 21, 1},
      {"run_x_pipeline_impl", 19, 1},
      {"pipeline_impl_should_skip_codegen", 33, 1},
      {"pipeline_impl_phase_parse_load", 30, 1},
      {"pipeline_impl_phase_parse_only", 30, 1},
      {"pipeline_impl_phase_load_deps", 29, 1},
      /** typecheck may whitelist alone; phase_codegen can 139. */
      {"pipeline_impl_typecheck", 23, 1},
      {"pipeline_impl_codegen_deps", 26, 1},
      {"pipeline_impl_codegen_entry", 27, 1},
      /** codegen_chain replaces phase_codegen (latter alone emits 139). */
      {"pipeline_impl_codegen_chain", 27, 1},
      /** parser.x: strict chain pipeline.parse_into_with_init_buf needs parser.parse_into_buf real code. */
      {"parse_into_init", 15, 1},
      {"parse_into_set_main_index", 25, 1},
      {"collect_imports_buf", 19, 1},
      {"parse_into_buf", 14, 1},
      /** Large entry (>150KiB): full typeck/asm entry emit overflows; SKIP stub is enough. */
      {"typeck_x_ast", 12, 0},
      {"typeck_x_ast_library", 20, 0},
      {"asm_codegen_ast", 15, 0},
      /** main.x build_asm/main.o: entry must real-emit (WPO root + crt0 chain). */
      {"entry", 5, 1},
  };
  int32_t k;
  int32_t large_entry;
  if (!m || func_index < 0)
    return 0;
  /**
   * When compiling parser.x self-host modules, do not whitelist real emit
   * (parse_into_init etc. fail expr emit); strict chain parse_into_* comes from
   * pipeline_x partial / C alias.
   * XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1: experimental parser_parse_bootstrap.o needs parse_into* real emit.
   */
  if (asm_module_is_parser_selfhost(m)) {
    if (link_abi_getenv("XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT") != NULL) {
      static const asm_boot_parse_sym_t k_boot_parse_minimal[] = {
          {"parse_into_init", 15},
          {"parse_into_set_main_index", 25},
      };
      static const asm_boot_parse_sym_t k_boot_parse_full[] = {
          {"parse_into_buf", 14},
          {"parse_into", 10},
          {"parse_into_init", 15},
          {"parse_into_set_main_index", 25},
          {"collect_imports_buf", 19},
      };
      const asm_boot_parse_sym_t *k_boot_parse;
      int32_t k_boot_n;
      int32_t bi;
      if (link_abi_getenv("XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT_MINIMAL") != NULL) {
        k_boot_parse = k_boot_parse_minimal;
        k_boot_n = (int32_t)(sizeof(k_boot_parse_minimal) / sizeof(k_boot_parse_minimal[0]));
      } else {
        k_boot_parse = k_boot_parse_full;
        k_boot_n = (int32_t)(sizeof(k_boot_parse_full) / sizeof(k_boot_parse_full[0]));
      }
      for (bi = 0; bi < k_boot_n; bi++) {
        if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_boot_parse[bi].name, k_boot_parse[bi].len))
          return 1;
      }
    }
    return 0;
  }
  large_entry = driver_typeck_skip_large_entry();
  for (k = 0; k < (int32_t)(sizeof(k_keep) / sizeof(k_keep[0])); k++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_keep[k].name, k_keep[k].len)) {
      if (k_keep[k].allow_on_large_entry == 0 && large_entry != 0)
        return 0;
      return 1;
    }
  }
  return 0;
}

/**
 * Strict asm orchestration: this TU does not emit that func body/label; call goes
 * via Mach-O/ELF reloc to C alias. Local symbols would make ld -r partial bl bind
 * the wrong asm impl (incomplete typecheck if/else → null module).
 */
int32_t asm_orchestration_extern_only_func(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0)
    return 0;
  /** Default B-strict chain uses build_asm pipeline.o real emit; only C orch experiments go extern-only. */
  if (asm_env_strict_orchestration() == 0)
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_typecheck", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_with_init_buf", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_phase_parse_load", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_run_all", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_impl", 19))
    return 1;
  return 0;
}

/** Current asm codegen PipelineDepCtx; backend.x sets before emit loop (ENTRY_MODULE_ONLY -o gate). */
static struct ast_PipelineDepCtx *g_asm_skip_pipeline_ctx;

void asm_skip_heavy_set_pipeline_ctx(struct ast_PipelineDepCtx *ctx) {
  g_asm_skip_pipeline_ctx = ctx;
}

/** XLANG_ASM_ENTRY_EMIT_HEAVY=1: ENTRY_MODULE_ONLY real emit (typeck second pass); skip only pipeline typecheck. */
static int32_t asm_env_entry_emit_heavy(void) {
  const char *e = link_abi_getenv("XLANG_ASM_ENTRY_EMIT_HEAVY");
  return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

/** Module func name has prefix (byte compare against module func pool). */
static int32_t pipeline_module_func_name_has_prefix_at(struct ast_Module *m, int32_t fi, const char *pfx,
    int32_t plen) {
  int32_t nl;
  int32_t k;
  if (!m || fi < 0 || !pfx || plen <= 0)
    return 0;
  nl = pipeline_module_func_name_len_at(m, fi);
  if (nl < plen)
    return 0;
  for (k = 0; k < plen; k++) {
    if (pipeline_module_func_name_byte_at(m, fi, k) != (uint8_t)pfx[k])
      return 0;
  }
  return 1;
}
