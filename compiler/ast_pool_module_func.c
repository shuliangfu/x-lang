/**
 * ast_pool_module_func.c — Module Func cold accessors domain (BC 8.3.2).
 *
 * Same-TU #include from ast_pool.c (itself #include'd into pipeline_glue /
 * pipeline_x). Not a separate .o.
 *
 * Domain (module func pool + param sidecar cold APIs):
 * - pipeline_module_func_alloc_slot / ref_at / ref_set / register_from_arena / ptr
 * - set_return_type / set_body_ref / set_body_expr_ref
 * - set/get is_extern|async|used|naked|entry|no_mangle|interrupt|variadic|export
 * - set/get num_params / num_generic_params
 * - param_type_ref_for_name / param_type_ref_at / param_write / param_name_*
 * - return_type_at / name_equal_at / name_byte_at / body_expr_ref_at
 * - pipeline_arena_func_param_write / pipeline_arena_func_copy_slot_from_module
 *
 * Left in core (interleaved / orchestration):
 * - static module_func_at / copy_func_params_between_sidecars /
 *   module_func_param_entry / arena_func_param_entry (early helpers)
 * - pipeline_visibility_* + L7 unused-private lint + module_num_funcs /
 *   main_func_index / reset_parse_counters / strict_parse_into_init
 *   pure-owned leave wave121 (runtime_pipeline_abi; no host-cc twin)
 *
 * wave1163 G.7: pipeline_module_func_name_write / name_len_at / name_copy64
 * / is_extern_at / body_ref_at migrated from pipeline_glue.c to this file's
 * EOF (colocated with module_func accessor domain). Forward decls at
 * glue.c L96/L256-260 retained for early callsites (L637-649 etc.).
 *
 * Depends on same-TU statics: module_func_at, module_func_param_entry,
 * arena_func_param_entry, copy_func_params_between_sidecars, module_sidecar_get,
 * arena_sidecar_get, pipeline_arena_func_ptr, grow_vec_*, ModuleSidecar /
 * ArenaSidecar / FuncParamEntry.
 *
 * PLATFORM: SHARED — host-cc Cap residual; parser/typeck/codegen call these.
 * Wave: 986 · no semantic change · pin stays 77b334842.
 */

/** Module 侧分配新函数槽，返回 0-based 下标；失败返回 -1。 */
int32_t pipeline_module_func_alloc_slot(struct ast_Module *m) {
  ModuleSidecar *sc;
  struct ast_Func *f;
  int32_t *pr;
  int32_t idx;
  if (!m)
    return -1;
  sc = module_sidecar_get(m, 1);
  if (!sc)
    return -1;
  idx = grow_vec_push(&sc->funcs);
  if (idx < 0)
    return -1;
  f = (struct ast_Func *)grow_vec_at(&sc->funcs, idx);
  if (f) {
    memset(f, 0, sizeof(*f));
    f->param_base = -1;
  }
  if (grow_vec_push(&sc->func_refs) >= 0) {
    pr = (int32_t *)grow_vec_at(&sc->func_refs, idx);
    if (pr)
      *pr = 0;
  }
  m->num_funcs = sc->funcs.len;
  return idx;
}

int32_t pipeline_module_func_ref_at(struct ast_Module *m, int32_t func_index) {
  ModuleSidecar *sc;
  int32_t *pr;
  if (!m || func_index < 0 || func_index >= m->num_funcs)
    return 0;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return 0;
  pr = (int32_t *)grow_vec_at(&sc->func_refs, func_index);
  return pr ? *pr : 0;
}

void pipeline_module_func_ref_set(struct ast_Module *m, int32_t func_index, int32_t func_ref) {
  ModuleSidecar *sc;
  int32_t *pr;
  if (!m || func_index < 0 || func_index >= m->num_funcs)
    return;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return;
  pr = (int32_t *)grow_vec_at(&sc->func_refs, func_index);
  if (pr)
    *pr = func_ref;
}

/** 从 arena func 池整槽拷贝到 module pool 新槽；返回 module 下标，失败 -1。 */
int32_t pipeline_module_func_register_from_arena(struct ast_Module *m, struct ast_ASTArena *arena,
                                                  int32_t func_ref) {
  int32_t fi;
  struct ast_Func *dst;
  struct ast_Func *src;
  ModuleSidecar *msc;
  ArenaSidecar *asc;
  if (!m || !arena || func_ref <= 0 || func_ref > arena->num_funcs)
    return -1;
  fi = pipeline_module_func_alloc_slot(m);
  if (fi < 0)
    return -1;
  dst = module_func_at(m, fi);
  src = pipeline_arena_func_ptr(arena, func_ref);
  msc = module_sidecar_get(m, 1);
  asc = arena_sidecar_get(arena, 0);
  if (!dst || !src || !msc || !asc)
    return -1;
  *dst = *src;
  copy_func_params_between_sidecars(&msc->func_params, &dst->param_base, src->num_params, &asc->func_params,
                                    src->param_base);
  pipeline_module_func_ref_set(m, fi, func_ref);
  return fi;
}

struct ast_Func *pipeline_module_func_ptr(struct ast_Module *m, int32_t func_index) {
  return module_func_at(m, func_index);
}

/** 写 module 函数字段（替代 .x 直接写 module.funcs[i]）。 */
void pipeline_module_func_set_return_type(struct ast_Module *m, int32_t fi, int32_t type_ref) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f)
    f->return_type_ref = type_ref;
}

void pipeline_module_func_set_body_ref(struct ast_Module *m, int32_t fi, int32_t body_ref) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f)
    f->body_ref = body_ref;
}

void pipeline_module_func_set_body_expr_ref(struct ast_Module *m, int32_t fi, int32_t body_expr_ref) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f)
    f->body_expr_ref = body_expr_ref;
}

void pipeline_module_func_set_is_extern(struct ast_Module *m, int32_t fi, int32_t is_extern) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f)
    f->is_extern = is_extern;
}

/** 设置 module 第 fi 个函数是否为 async function（P2 语法原型）。 */
void pipeline_module_func_set_is_async(struct ast_Module *m, int32_t fi, int32_t is_async) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f)
    f->is_async = is_async;
}

/** K10：设置 module 第 fi 个函数是否为 #[used]（不被 C 编译器消除，外部链接）。 */
void pipeline_module_func_set_is_used(struct ast_Module *m, int32_t fi, int32_t is_used) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f)
    f->is_used = is_used;
}

/** K10：读取 module 第 fi 个函数是否为 #[used]。 */
int32_t pipeline_module_func_is_used_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs)
    return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_used : 0;
}

/** K3：设置 module 第 fi 个函数是否为 #[naked]。 */
void pipeline_module_func_set_is_naked(struct ast_Module *m, int32_t fi, int32_t is_naked) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f) f->is_naked = is_naked;
}
int32_t pipeline_module_func_is_naked_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs) return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_naked : 0;
}

/** K5：设置 module 第 fi 个函数是否为 #[entry]。 */
void pipeline_module_func_set_is_entry(struct ast_Module *m, int32_t fi, int32_t is_entry) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f) f->is_entry = is_entry;
}
int32_t pipeline_module_func_is_entry_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs) return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_entry : 0;
}

/** L9：设置 module 第 fi 个函数是否为 #[no_mangle]。 */
void pipeline_module_func_set_is_no_mangle(struct ast_Module *m, int32_t fi, int32_t is_no_mangle) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f) f->is_no_mangle = is_no_mangle;
}
int32_t pipeline_module_func_is_no_mangle_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs) return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_no_mangle : 0;
}

/** A1：设置 module 第 fi 个函数是否为 #[interrupt]。 */
void pipeline_module_func_set_is_interrupt(struct ast_Module *m, int32_t fi, int32_t is_interrupt) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f) f->is_interrupt = is_interrupt;
}
int32_t pipeline_module_func_is_interrupt_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs) return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_interrupt : 0;
}

/** 变参：设置 module 第 fi 个函数是否为变参（extern "C" function f(fmt: *u8, ...): i32）。
 *  Why：C ABI 变参函数（printf/vfprintf 等）需在声明处发 `...`，调用处透传实参。
 *  Invariant：仅 abi_kind==1（C ABI）的 extern function 可置 1；X ABI 不支持变参。
 *  Asm/Perf：单次字段写入，无运行期开销；codegen 读取后决定是否发 `...`。 */
void pipeline_module_func_set_is_variadic(struct ast_Module *m, int32_t fi, int32_t is_variadic) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f) f->is_variadic = is_variadic;
}
int32_t pipeline_module_func_is_variadic_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs) return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_variadic : 0;
}

/** 模块导出：设置 / 读取 function 的 is_export（`export function`）。 */
void pipeline_module_func_set_is_export(struct ast_Module *m, int32_t fi, int32_t is_export) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f) f->is_export = is_export;
}
int32_t pipeline_module_func_is_export_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs) return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_export : 0;
}

int32_t pipeline_module_func_is_async_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs)
    return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_async : 0;
}

void pipeline_module_func_set_num_params(struct ast_Module *m, int32_t fi, int32_t n) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f && n >= 0)
    f->num_params = n;
}

void pipeline_module_func_set_num_generic_params(struct ast_Module *m, int32_t fi, int32_t n) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f && n >= 0)
    f->num_generic_params = n;
  if (f && link_abi_getenv("XLANG_DEBUG_FUNC_GENERIC_SLOT")) {
    fprintf(stderr, "xlang: [XLANG_DEBUG_FUNC_GENERIC_SLOT] set fi=%d n=%d name=%.*s\n",
            (int)fi, (int)f->num_generic_params, (int)(f->name_len > 0 ? f->name_len : 0), (const char *)f->name);
    fflush(stderr);
  }
}

int32_t pipeline_module_func_num_params_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs)
    return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->num_params : 0;
}

int32_t pipeline_module_func_num_generic_params_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs)
    return 0;
  f = module_func_at(m, func_index);
  if (!f)
    return 0;
  if (link_abi_getenv("XLANG_DEBUG_FUNC_GENERIC_SLOT")) {
    fprintf(stderr, "xlang: [XLANG_DEBUG_FUNC_GENERIC_SLOT] get fi=%d n=%d name=%.*s\n",
            (int)func_index, (int)f->num_generic_params, (int)(f->name_len > 0 ? f->name_len : 0),
            (const char *)f->name);
    fflush(stderr);
  }
  return (int32_t)f->num_generic_params;
}

int32_t pipeline_module_func_param_type_ref_for_name(struct ast_Module *m, int32_t func_index, uint8_t *var_name,
                                                     int32_t var_name_len) {
  struct ast_Func *f;
  int32_t n, i;
  FuncParamEntry *pe;
  if (!m || !var_name || func_index < 0 || func_index >= m->num_funcs)
    return 0;
  /* wave585 Cap residual: param content ≤127 (FuncParamEntry.name[128]). */
  if (var_name_len <= 0 || var_name_len > 127)
    return 0;
  f = module_func_at(m, func_index);
  if (!f)
    return 0;
  n = (int32_t)f->num_params;
  for (i = 0; i < n; i++) {
    pe = module_func_param_entry(m, func_index, i, 0);
    if (!pe || pe->type_ref == 0)
      continue;
    if ((int32_t)pe->name_len != var_name_len)
      continue;
    if (pe->name_len <= 0 || pe->name_len > 127)
      continue;
    if (memcmp(pe->name, var_name, (size_t)var_name_len) != 0)
      continue;
    return (int32_t)pe->type_ref;
  }
  return 0;
}

int32_t pipeline_module_func_param_type_ref_at(struct ast_Module *m, int32_t func_index, int32_t param_index) {
  FuncParamEntry *pe;
  if (!m || func_index < 0 || func_index >= m->num_funcs || param_index < 0)
    return 0;
  pe = module_func_param_entry(m, func_index, param_index, 0);
  return pe ? (int32_t)pe->type_ref : 0;
}

void pipeline_module_func_param_write(struct ast_Module *m, int32_t func_index, int32_t param_index,
                                      uint8_t *name_bytes, int32_t name_len, int32_t type_ref) {
  FuncParamEntry *pe;
  if (!m || !name_bytes || func_index < 0 || param_index < 0)
    return;
  /* wave585 Cap residual: content ≤127 (name[128]). */
  if (name_len < 0 || name_len > 127)
    return;
  pe = module_func_param_entry(m, func_index, param_index, 1);
  if (!pe)
    return;
  pe->name_len = name_len;
  pe->type_ref = type_ref;
  memset(pe->name, 0, sizeof(pe->name));
  if (name_len > 0)
    memcpy(pe->name, name_bytes, (size_t)name_len);
}

int32_t pipeline_module_func_param_name_len_at(struct ast_Module *m, int32_t func_index, int32_t param_index) {
  FuncParamEntry *pe;
  if (!m || func_index < 0 || func_index >= m->num_funcs || param_index < 0)
    return 0;
  pe = module_func_param_entry(m, func_index, param_index, 0);
  /* wave585: return only legal content lengths (≤127). */
  return pe && pe->name_len > 0 && pe->name_len <= 127 ? (int32_t)pe->name_len : 0;
}

/**
 * ABI name kept as *copy32; wave585 Cap residual raised payload 32→128.
 * Callers must pass a dst buffer of at least 128 bytes.
 * PLATFORM: SHARED
 */
void pipeline_module_func_param_name_copy32(struct ast_Module *m, int32_t func_index, int32_t param_index,
                                            uint8_t *dst) {
  FuncParamEntry *pe;
  if (!m || !dst || func_index < 0 || func_index >= m->num_funcs || param_index < 0)
    return;
  pe = module_func_param_entry(m, func_index, param_index, 0);
  if (!pe) {
    memset(dst, 0, 128);
    return;
  }
  memcpy(dst, pe->name, (size_t)128);
}

void pipeline_arena_func_param_write(struct ast_ASTArena *arena, int32_t func_ref, int32_t param_index,
                                     uint8_t *name_bytes, int32_t name_len, int32_t type_ref) {
  FuncParamEntry *pe;
  if (!arena || !name_bytes || func_ref <= 0 || func_ref > arena->num_funcs || param_index < 0)
    return;
  /* wave585 Cap residual: content ≤127 (name[128]). */
  if (name_len < 0 || name_len > 127)
    return;
  pe = arena_func_param_entry(arena, func_ref, param_index, 1);
  if (!pe)
    return;
  pe->name_len = name_len;
  pe->type_ref = type_ref;
  memset(pe->name, 0, sizeof(pe->name));
  if (name_len > 0)
    memcpy(pe->name, name_bytes, (size_t)name_len);
}

/** 将 module.funcs[fi] 标量槽 + 形参 sidecar 拷贝到 arena func 池（parse_into_buf 路径）。 */
void pipeline_arena_func_copy_slot_from_module(struct ast_ASTArena *arena, int32_t func_ref, struct ast_Module *m,
                                               int32_t fi) {
  struct ast_Func *src;
  struct ast_Func *dst;
  ModuleSidecar *msc;
  ArenaSidecar *asc;
  if (!arena || !m || func_ref <= 0 || func_ref > arena->num_funcs)
    return;
  if (fi < 0 || fi >= m->num_funcs)
    return;
  src = module_func_at(m, fi);
  dst = pipeline_arena_func_ptr(arena, func_ref);
  msc = module_sidecar_get(m, 0);
  asc = arena_sidecar_get(arena, 1);
  if (!src || !dst || !msc || !asc)
    return;
  *dst = *src;
  copy_func_params_between_sidecars(&asc->func_params, &dst->param_base, src->num_params, &msc->func_params,
                                    src->param_base);
}

int32_t pipeline_module_func_return_type_at(struct ast_Module *m, int32_t fi) {
  struct ast_Func *f = module_func_at(m, fi);
  return f ? (int32_t)f->return_type_ref : 0;
}

/** 比较 module 函数名与外部 name 字节序列；相等返回 1。 */
int32_t pipeline_module_func_name_equal_at(struct ast_Module *m, int32_t fi, uint8_t *name, int32_t name_len) {
  struct ast_Func *f;
  /* wave577 Cap: name slots u8[128] → accept name_len <= 127 */
  if (!m || !name || name_len <= 0 || name_len > 127)
    return 0;
  f = module_func_at(m, fi);
  if (!f || (int32_t)f->name_len != name_len)
    return 0;
  return memcmp(f->name, name, (size_t)name_len) == 0 ? 1 : 0;
}

/** Read module func name byte (0..name_len-1); OOB returns 0. */
uint8_t pipeline_module_func_name_byte_at(struct ast_Module *m, int32_t fi, int32_t i) {
  struct ast_Func *f;
  if (!m || i < 0 || i >= 64)
    return 0;
  f = module_func_at(m, fi);
  if (!f || i >= (int32_t)f->name_len)
    return 0;
  return f->name[i];
}

int32_t pipeline_module_func_body_expr_ref_at(struct ast_Module *m, int32_t fi) {
  struct ast_Func *f = module_func_at(m, fi);
  return f ? (int32_t)f->body_expr_ref : 0;
}

/*
 * wave1163 G.7: module_func name/body reader cluster migrated from
 * pipeline_glue.c (was L2427-2496). Colocated with module_func accessor
 * domain — all read/write Func struct fields via pipeline_module_func_ptr.
 * Forward decls retained in glue.c L96/L256-260 for early callsites.
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU.
 */

/**
 * Write func name bytes into Func.name[128] (Cap: ≤127 bytes + NUL pad).
 * Called by codegen name-write path and parse-time func registration.
 * Contract: null m / OOB func_index / name_len outside [0,127] → no-op.
 */
void pipeline_module_func_name_write(struct ast_Module *m, int32_t func_index, uint8_t *name_bytes,
                                     int32_t name_len) {
  struct ast_Func *f;
  if (!m || func_index < 0)
    return;
  /* wave577 Cap: AST Func.name is u8[128]; allow up to 127 bytes */
  if (name_len < 0 || name_len > 127)
    return;
  if (name_len > 0 && !name_bytes)
    return;
  f = pipeline_module_func_ptr(m, func_index);
  if (!f)
    return;
  f->name_len = name_len;
  memset(f->name, 0, sizeof(f->name));
  if (name_len > 0)
    memcpy(f->name, name_bytes, (size_t)name_len);
}

/**
 * Copy Func.name[128] into dst (128 bytes, NUL-padded).
 * Used by codegen to avoid .x nested array GEP typeck/asm failures.
 * Contract: null m/dst / OOB func_index → no-op; copies ≤127 bytes + zero-pad.
 */
void pipeline_module_func_name_copy64(struct ast_Module *m, int32_t func_index, uint8_t *dst) {
  struct ast_Func *f;
  int32_t nlen;
  if (!m || !dst || func_index < 0)
    return;
  if (func_index >= (int32_t)m->num_funcs)
    return;
  f = pipeline_module_func_ptr(m, func_index);
  if (!f)
    return;
  /* wave577 Cap: copy name_len bytes (≤127), zero-pad rest; aligns with
   * AST name[128] to avoid truncation. */
  nlen = f->name_len;
  if (nlen < 0)
    nlen = 0;
  if (nlen > 127)
    nlen = 127;
  memset(dst, 0, 128);
  if (nlen > 0)
    memcpy(dst, f->name, (size_t)nlen);
}

/**
 * Read Func.name_len (byte count, excl. NUL).
 * Contract: null m / OOB func_index → returns 0.
 */
int32_t pipeline_module_func_name_len_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0)
    return 0;
  if (func_index >= (int32_t)m->num_funcs)
    return 0;
  f = pipeline_module_func_ptr(m, func_index);
  return f ? (int32_t)f->name_len : 0;
}

/**
 * Read Func.is_extern flag (1 if extern declaration, no body).
 * Contract: null m / OOB func_index → returns 0.
 */
int32_t pipeline_module_func_is_extern_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0)
    return 0;
  if (func_index >= (int32_t)m->num_funcs)
    return 0;
  f = pipeline_module_func_ptr(m, func_index);
  return f ? (int32_t)f->is_extern : 0;
}

/**
 * Read Func.body_ref (block_ref for function body; 0/null if extern).
 * Contract: null m / OOB func_index → returns 0.
 */
int32_t pipeline_module_func_body_ref_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0)
    return 0;
  if (func_index >= (int32_t)m->num_funcs)
    return 0;
  f = pipeline_module_func_ptr(m, func_index);
  return f ? (int32_t)f->body_ref : 0;
}

/* wave1175 G.7: asm-prefixed module func forwarders (7 fns) migrated from
 * pipeline_glue.c L3510-3542. Colocated with pipeline_module_func_* domain
 * — these one-line forwarders give backend.x an asm_ prefix symbol to avoid
 * codegen_ prefix link errors when backend imports module func accessors.
 *
 * Fwd decls retained in glue.c L778/L7685 for callsites before ast_pool.c
 * #include at glue.c L5055. Additional fwd decls added for the 5 fns that
 * had no prior declaration.
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/**
 * Forwarder: backend.x asm_ prefix for pipeline_module_func_is_extern_at.
 * Why: backend.x declares these as extern; without the asm_ wrapper, the
 *      import would generate a codegen_ prefix symbol → link error.
 */
int32_t pipeline_asm_module_func_is_extern_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_module_func_is_extern_at(m, func_index);
}

int32_t pipeline_asm_module_func_body_ref_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_module_func_body_ref_at(m, func_index);
}

int32_t pipeline_asm_module_func_name_len_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_module_func_name_len_at(m, func_index);
}

void pipeline_asm_module_func_name_copy64(struct ast_Module *m, int32_t func_index, uint8_t *dst) {
  pipeline_module_func_name_copy64(m, func_index, dst);
}

int32_t pipeline_asm_module_func_num_params_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_module_func_num_params_at(m, func_index);
}

int32_t pipeline_asm_module_func_param_name_len_at(struct ast_Module *m, int32_t func_index,
                                                   int32_t param_index) {
  return pipeline_module_func_param_name_len_at(m, func_index, param_index);
}

void pipeline_asm_module_func_param_name_copy32(struct ast_Module *m, int32_t func_index,
                                                int32_t param_index, uint8_t *dst) {
  pipeline_module_func_param_name_copy32(m, func_index, param_index, dst);
}

/* wave1177 G.7: arch_arm64 module_func forwarders (4 fns) migrated from
 * pipeline_glue.c L4530-4545. Colocated with the asm_module_func forwarder
 * family (wave1175) — these are the arm64.o single-module compile variants
 * that delegate to the same asm_module_func_* symbols.
 *
 * Why: build_asm/arm64.o single-module compile emits arm64 module-prefixed
 *      symbols; without these forwarders the arm64 link would fail with
 *      undefined arch_arm64_pipeline_asm_module_func_* references.
 * No glue.c callsites (sole callers are arm64.o via extern).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/** arm64.o single-module compile: forwarder for pipeline_asm_module_func_is_extern_at. */
int32_t arch_arm64_pipeline_asm_module_func_is_extern_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_asm_module_func_is_extern_at(m, func_index);
}

/** arm64.o single-module compile: forwarder for pipeline_asm_module_func_body_ref_at. */
int32_t arch_arm64_pipeline_asm_module_func_body_ref_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_asm_module_func_body_ref_at(m, func_index);
}

/** arm64.o single-module compile: forwarder for pipeline_asm_module_func_name_len_at. */
int32_t arch_arm64_pipeline_asm_module_func_name_len_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_asm_module_func_name_len_at(m, func_index);
}

/** arm64.o single-module compile: forwarder for pipeline_asm_module_func_name_copy64. */
void arch_arm64_pipeline_asm_module_func_name_copy64(struct ast_Module *m, int32_t func_index,
                                                     uint8_t *dst) {
  pipeline_asm_module_func_name_copy64(m, func_index, dst);
}

