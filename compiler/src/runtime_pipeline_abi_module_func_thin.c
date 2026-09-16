/*
 * Thin pure: wave280 ast_pool_module_func Cap residual leave (ALWAYS host-cc).
 * G.7: bodies match seeds/runtime_pipeline_abi.from_x.c
 * WAVE280_MODULE_FUNC_DOMAIN_ALWAYS (module Func cold accessors + param sidecar
 * + parse-impl owner BSS + asm/arch_arm64 rename forwarders).
 *
 * Independent C thin (Darwin additive-leaf rule). File-local BSS:
 *   g_pmfo_owner / g_pmfo_owner_len / g_pmfo_cur_owner / g_pmfo_cur_len.
 * Sidecar via wave275; GrowVec via wave271; arena_func_ptr via pure/cold.
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED host-cc module_func Cap residual leave.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>

/**
 * Thin-local trace sink (seed pabi_trace uses xlang_vfdprintf; no-op here).
 * PLATFORM: SHARED — debug-only; omit I/O from Cap residual leaf.
 */
static void pabi_trace(const char *fmt, ...) {
  (void)fmt;
}

/* Thin-local GrowVec (match wave271 / seed FROM_X layout). */
#ifndef W280_NEED_GROWVEC
#define W280_NEED_GROWVEC 1
typedef struct {
  uint8_t *data;
  int32_t cap;
  int32_t len;
  size_t elem_sz;
  int32_t mmap_backed;
} GrowVec;
#endif

/* Product LE: Func 324 / FuncParam 264 / ModuleSidecar 432 / ArenaSidecar 816.
 * Func: name[256]@0 name_len@256 param_base@260 num_params@264
 * num_generic_params@140 return_type_ref@144 body_ref@148 body_expr_ref@152
 * is_extern@156 … is_export@192 (matches pipeline_gen / pure Cap). */
typedef struct {
  uint8_t name[256];
  int32_t name_len;
  int32_t param_base;
  int32_t num_params;
  int32_t num_generic_params;
  int32_t return_type_ref;
  int32_t body_ref;
  int32_t body_expr_ref;
  int32_t is_extern;
  int32_t is_async;
  int32_t is_used;
  int32_t is_naked;
  int32_t is_entry;
  int32_t is_no_mangle;
  int32_t is_interrupt;
  int32_t abi_kind;
  int32_t is_variadic;
  int32_t is_export;
} W280_Func;

typedef struct {
  uint8_t name[256];
  int32_t name_len;
  int32_t type_ref;
} W280_FuncParam;

typedef struct {
  void *module_key;
  int used;
  GrowVec funcs;
  GrowVec func_refs;
  GrowVec imports;
  GrowVec struct_layouts;
  GrowVec top_level_lets;
  GrowVec type_aliases;
  GrowVec module_enums;
  GrowVec import_select_name_rows;
  GrowVec import_select_name_lens;
  GrowVec func_params;
  GrowVec struct_layout_fields;
  GrowVec struct_layout_type_params;
  GrowVec struct_layout_type_param_meta;
} W280_ModuleSc;

typedef struct {
  void *arena_key;
  int used;
  GrowVec types;
  GrowVec exprs;
  GrowVec blocks;
  GrowVec funcs;
  GrowVec consts;
  GrowVec lets;
  GrowVec ifs;
  GrowVec regions;
  GrowVec loops;
  GrowVec for_loops;
  GrowVec defer_block_refs;
  GrowVec labeled_stmts;
  GrowVec expr_stmt_refs;
  GrowVec stmt_order;
  GrowVec expr_call_arg_refs;
  GrowVec expr_call_type_arg_refs;
  GrowVec expr_call_type_arg_bases;
  GrowVec type_type_arg_refs;
  GrowVec type_type_arg_bases;
  GrowVec type_type_arg_counts;
  GrowVec expr_method_call_arg_refs;
  GrowVec expr_match_arms;
  GrowVec expr_struct_lit_fields;
  GrowVec expr_array_lit_elem_refs;
  GrowVec func_params;
} W280_ArenaSc;

typedef struct {
  int32_t num_funcs;
} W280_ModuleHdr;

typedef struct {
  int32_t num_types;
  int32_t num_exprs;
  int32_t num_blocks;
  int32_t num_funcs;
} W280_ArenaHdr;

/* Cap faces — match WAVE277/278/279 GrowVec* decls. */
extern void *module_sidecar_get(void *key, int create);
extern void *arena_sidecar_get(void *key, int create);
extern void *grow_vec_at(GrowVec *v, int32_t idx);
extern int32_t grow_vec_push(GrowVec *v);
extern char *link_abi_getenv(const char *name);
extern void *pipeline_arena_func_ptr(void *a, int32_t ref);

static W280_Func *module_func_at(void *m, int32_t idx) {
  W280_ModuleSc *sc;
  if (!m || idx < 0 || idx >= ((W280_ModuleHdr *)m)->num_funcs)
    return NULL;
  sc = (W280_ModuleSc *)module_sidecar_get(m, 0);
  if (!sc || idx >= sc->funcs.len)
    return NULL;
  return (W280_Func *)grow_vec_at(&sc->funcs, idx);
}

/** Copy n W280_FuncParam slots from src sidecar pool into dst; set *dst_base. */
static void copy_func_params_between_sidecars(GrowVec *dst, int32_t *dst_base, int32_t n, GrowVec *src,
                                              int32_t src_base) {
  int32_t i, abs_src, abs_dst;
  W280_FuncParam *se, *de;
  if (!dst || !src || n <= 0)
    return;
  *dst_base = dst->len;
  for (i = 0; i < n; i++) {
    abs_src = src_base + i;
    se = (W280_FuncParam *)grow_vec_at(src, abs_src);
    if (grow_vec_push(dst) < 0)
      break;
    abs_dst = dst->len - 1;
    de = (W280_FuncParam *)grow_vec_at(dst, abs_dst);
    if (se && de)
      *de = *se;
  }
}

/** Read/write module func param sidecar slot; create=1 grows as needed. */
static W280_FuncParam *module_func_param_entry(void *m, int32_t fi, int32_t pi, int create) {
  W280_ModuleSc *sc;
  W280_Func *f;
  int32_t abs;
  if (!m || fi < 0 || pi < 0)
    return NULL;
  f = module_func_at(m, fi);
  if (!f)
    return NULL;
  sc = (W280_ModuleSc *)module_sidecar_get(m, create ? 1 : 0);
  if (!sc)
    return NULL;
  if (!create) {
    if (pi >= f->num_params || f->param_base < 0)
      return NULL;
    abs = f->param_base + pi;
    if (abs < 0 || abs >= sc->func_params.len)
      return NULL;
    return (W280_FuncParam *)grow_vec_at(&sc->func_params, abs);
  }
  if (f->param_base < 0)
    f->param_base = sc->func_params.len;
  abs = f->param_base + pi;
  while (sc->func_params.len <= abs) {
    if (grow_vec_push(&sc->func_params) < 0)
      return NULL;
  }
  if (pi + 1 > f->num_params)
    f->num_params = pi + 1;
  return (W280_FuncParam *)grow_vec_at(&sc->func_params, abs);
}

/** Read/write arena func param sidecar slot; create=1 grows as needed. */
static W280_FuncParam *arena_func_param_entry(void *a, int32_t func_ref, int32_t pi, int create) {
  W280_ArenaSc *sc;
  W280_Func *f;
  int32_t abs;
  if (!a || func_ref <= 0 || func_ref > ((W280_ArenaHdr *)a)->num_funcs || pi < 0)
    return NULL;
  f = (W280_Func *)pipeline_arena_func_ptr(a, func_ref);
  if (!f)
    return NULL;
  sc = (W280_ArenaSc *)arena_sidecar_get(a, create ? 1 : 0);
  if (!sc)
    return NULL;
  if (!create) {
    if (pi >= f->num_params || f->param_base < 0)
      return NULL;
    abs = f->param_base + pi;
    if (abs < 0 || abs >= sc->func_params.len)
      return NULL;
    return (W280_FuncParam *)grow_vec_at(&sc->func_params, abs);
  }
  if (f->param_base < 0)
    f->param_base = sc->func_params.len;
  abs = f->param_base + pi;
  while (sc->func_params.len <= abs) {
    if (grow_vec_push(&sc->func_params) < 0)
      return NULL;
  }
  if (pi + 1 > f->num_params)
    f->num_params = pi + 1;
  return (W280_FuncParam *)grow_vec_at(&sc->func_params, abs);
}


/** Module 侧分配新函数槽，返回 0-based 下标；失败返回 -1。 */
int32_t pipeline_module_func_alloc_slot(void *m) {
  W280_ModuleSc *sc;
  W280_Func *f;
  int32_t *pr;
  int32_t idx;
  if (!m)
    return -1;
  sc = (W280_ModuleSc *)module_sidecar_get(m, 1);
  if (!sc)
    return -1;
  idx = grow_vec_push(&sc->funcs);
  if (idx < 0)
    return -1;
  f = (W280_Func *)grow_vec_at(&sc->funcs, idx);
  if (f) {
    memset(f, 0, sizeof(*f));
    f->param_base = -1;
  }
  if (grow_vec_push(&sc->func_refs) >= 0) {
    pr = (int32_t *)grow_vec_at(&sc->func_refs, idx);
    if (pr)
      *pr = 0;
  }
  ((W280_ModuleHdr *)m)->num_funcs = sc->funcs.len;
  return idx;
}

int32_t pipeline_module_func_ref_at(void *m, int32_t func_index) {
  W280_ModuleSc *sc;
  int32_t *pr;
  if (!m || func_index < 0 || func_index >= ((W280_ModuleHdr *)m)->num_funcs)
    return 0;
  sc = (W280_ModuleSc *)module_sidecar_get(m, 0);
  if (!sc)
    return 0;
  pr = (int32_t *)grow_vec_at(&sc->func_refs, func_index);
  return pr ? *pr : 0;
}

void pipeline_module_func_ref_set(void *m, int32_t func_index, int32_t func_ref) {
  W280_ModuleSc *sc;
  int32_t *pr;
  if (!m || func_index < 0 || func_index >= ((W280_ModuleHdr *)m)->num_funcs)
    return;
  sc = (W280_ModuleSc *)module_sidecar_get(m, 0);
  if (!sc)
    return;
  pr = (int32_t *)grow_vec_at(&sc->func_refs, func_index);
  if (pr)
    *pr = func_ref;
}

/** 从 arena func 池整槽拷贝到 module pool 新槽；返回 module 下标，失败 -1。 */
int32_t pipeline_module_func_register_from_arena(void *m, void *arena,
                                                  int32_t func_ref) {
  int32_t fi;
  W280_Func *dst;
  W280_Func *src;
  W280_ModuleSc *msc;
  W280_ArenaSc *asc;
  if (!m || !arena || func_ref <= 0 || func_ref > ((W280_ArenaHdr *)arena)->num_funcs)
    return -1;
  fi = pipeline_module_func_alloc_slot(m);
  if (fi < 0)
    return -1;
  dst = module_func_at(m, fi);
  src = (W280_Func *)pipeline_arena_func_ptr(arena, func_ref);
  msc = (W280_ModuleSc *)module_sidecar_get(m, 1);
  asc = (W280_ArenaSc *)arena_sidecar_get(arena, 0);
  if (!dst || !src || !msc || !asc)
    return -1;
  *dst = *src;
  copy_func_params_between_sidecars(&msc->func_params, &dst->param_base, src->num_params, &asc->func_params,
                                    src->param_base);
  pipeline_module_func_ref_set(m, fi, func_ref);
  return fi;
}

W280_Func *pipeline_module_func_ptr(void *m, int32_t func_index) {
  return module_func_at(m, func_index);
}

/** 写 module 函数字段（替代 .x 直接写 module.funcs[i]）。 */
void pipeline_module_func_set_return_type(void *m, int32_t fi, int32_t type_ref) {
  W280_Func *f = module_func_at(m, fi);
  if (f)
    f->return_type_ref = type_ref;
}

void pipeline_module_func_set_body_ref(void *m, int32_t fi, int32_t body_ref) {
  W280_Func *f = module_func_at(m, fi);
  if (f)
    f->body_ref = body_ref;
}

void pipeline_module_func_set_body_expr_ref(void *m, int32_t fi, int32_t body_expr_ref) {
  W280_Func *f = module_func_at(m, fi);
  if (f)
    f->body_expr_ref = body_expr_ref;
}

void pipeline_module_func_set_is_extern(void *m, int32_t fi, int32_t is_extern) {
  W280_Func *f = module_func_at(m, fi);
  if (f)
    f->is_extern = is_extern;
}

/** 设置 module 第 fi 个函数是否为 async function（P2 语法原型）。 */
void pipeline_module_func_set_is_async(void *m, int32_t fi, int32_t is_async) {
  W280_Func *f = module_func_at(m, fi);
  if (f)
    f->is_async = is_async;
}

/** K10：设置 module 第 fi 个函数是否为 #[used]（不被 C 编译器消除，外部链接）。 */
void pipeline_module_func_set_is_used(void *m, int32_t fi, int32_t is_used) {
  W280_Func *f = module_func_at(m, fi);
  if (f)
    f->is_used = is_used;
}

/** K10：读取 module 第 fi 个函数是否为 #[used]。 */
int32_t pipeline_module_func_is_used_at(void *m, int32_t func_index) {
  W280_Func *f;
  if (!m || func_index < 0 || func_index >= ((W280_ModuleHdr *)m)->num_funcs)
    return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_used : 0;
}

/** K3：设置 module 第 fi 个函数是否为 #[naked]。 */
void pipeline_module_func_set_is_naked(void *m, int32_t fi, int32_t is_naked) {
  W280_Func *f = module_func_at(m, fi);
  if (f) f->is_naked = is_naked;
}
int32_t pipeline_module_func_is_naked_at(void *m, int32_t func_index) {
  W280_Func *f;
  if (!m || func_index < 0 || func_index >= ((W280_ModuleHdr *)m)->num_funcs) return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_naked : 0;
}

/** K5：设置 module 第 fi 个函数是否为 #[entry]。 */
void pipeline_module_func_set_is_entry(void *m, int32_t fi, int32_t is_entry) {
  W280_Func *f = module_func_at(m, fi);
  if (f) f->is_entry = is_entry;
}
int32_t pipeline_module_func_is_entry_at(void *m, int32_t func_index) {
  W280_Func *f;
  if (!m || func_index < 0 || func_index >= ((W280_ModuleHdr *)m)->num_funcs) return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_entry : 0;
}

/** L9：设置 module 第 fi 个函数是否为 #[no_mangle]。 */
void pipeline_module_func_set_is_no_mangle(void *m, int32_t fi, int32_t is_no_mangle) {
  W280_Func *f = module_func_at(m, fi);
  if (f) f->is_no_mangle = is_no_mangle;
}
int32_t pipeline_module_func_is_no_mangle_at(void *m, int32_t func_index) {
  W280_Func *f;
  if (!m || func_index < 0 || func_index >= ((W280_ModuleHdr *)m)->num_funcs) return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_no_mangle : 0;
}

/** A1：设置 module 第 fi 个函数是否为 #[interrupt]。 */
void pipeline_module_func_set_is_interrupt(void *m, int32_t fi, int32_t is_interrupt) {
  W280_Func *f = module_func_at(m, fi);
  if (f) f->is_interrupt = is_interrupt;
}
int32_t pipeline_module_func_is_interrupt_at(void *m, int32_t func_index) {
  W280_Func *f;
  if (!m || func_index < 0 || func_index >= ((W280_ModuleHdr *)m)->num_funcs) return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_interrupt : 0;
}

/** 变参：设置 module 第 fi 个函数是否为变参（extern "C" function f(fmt: *u8, ...): i32）。
 *  Why：C ABI 变参函数（printf/vfprintf 等）需在声明处发 `...`，调用处透传实参。
 *  Invariant：仅 abi_kind==1（C ABI）的 extern function 可置 1；X ABI 不支持变参。
 *  Asm/Perf：单次字段写入，无运行期开销；codegen 读取后决定是否发 `...`。 */
void pipeline_module_func_set_is_variadic(void *m, int32_t fi, int32_t is_variadic) {
  W280_Func *f = module_func_at(m, fi);
  if (f) f->is_variadic = is_variadic;
}
/* Set module func abi_kind (0=X ABI default, 1=C ABI `extern "C"`).
 * P12h: the extern parse flow used to write abi only onto the arena Func
 * via struct get/fill/set; the .x dest-buffer orchestration writes the
 * module row first and copies to the arena via copy_slot_from_module,
 * so the module row needs this setter (codegen reads abi for "C" faces). */
void pipeline_module_func_set_abi_kind(void *m, int32_t fi, int32_t abi_kind) {
  W280_Func *f = module_func_at(m, fi);
  if (f)
    f->abi_kind = abi_kind;
}

int32_t pipeline_module_func_abi_kind_at(void *m, int32_t func_index) {
  W280_Func *f;
  if (!m || func_index < 0 || func_index >= ((W280_ModuleHdr *)m)->num_funcs)
    return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->abi_kind : 0;
}

int32_t pipeline_module_func_is_variadic_at(void *m, int32_t func_index) {
  W280_Func *f;
  if (!m || func_index < 0 || func_index >= ((W280_ModuleHdr *)m)->num_funcs) return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_variadic : 0;
}

/** 模块导出：设置 / 读取 function 的 is_export（`export function`）。 */
void pipeline_module_func_set_is_export(void *m, int32_t fi, int32_t is_export) {
  W280_Func *f = module_func_at(m, fi);
  if (f) f->is_export = is_export;
}
int32_t pipeline_module_func_is_export_at(void *m, int32_t func_index) {
  W280_Func *f;
  if (!m || func_index < 0 || func_index >= ((W280_ModuleHdr *)m)->num_funcs) return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_export : 0;
}

int32_t pipeline_module_func_is_async_at(void *m, int32_t func_index) {
  W280_Func *f;
  if (!m || func_index < 0 || func_index >= ((W280_ModuleHdr *)m)->num_funcs)
    return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_async : 0;
}

void pipeline_module_func_set_num_params(void *m, int32_t fi, int32_t n) {
  W280_Func *f = module_func_at(m, fi);
  if (f && n >= 0)
    f->num_params = n;
}

void pipeline_module_func_set_num_generic_params(void *m, int32_t fi, int32_t n) {
  W280_Func *f = module_func_at(m, fi);
  if (f && n >= 0)
    f->num_generic_params = n;
  if (f && link_abi_getenv("XLANG_DEBUG_FUNC_GENERIC_SLOT")) {
    pabi_trace( "xlang: [XLANG_DEBUG_FUNC_GENERIC_SLOT] set fi=%d n=%d name=%.*s\n",
            (int)fi, (int)f->num_generic_params, (int)(f->name_len > 0 ? f->name_len : 0), (const char *)f->name);
  }
}

int32_t pipeline_module_func_num_params_at(void *m, int32_t func_index) {
  W280_Func *f;
  if (!m || func_index < 0 || func_index >= ((W280_ModuleHdr *)m)->num_funcs)
    return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->num_params : 0;
}

int32_t pipeline_module_func_num_generic_params_at(void *m, int32_t func_index) {
  W280_Func *f;
  if (!m || func_index < 0 || func_index >= ((W280_ModuleHdr *)m)->num_funcs)
    return 0;
  f = module_func_at(m, func_index);
  if (!f)
    return 0;
  if (link_abi_getenv("XLANG_DEBUG_FUNC_GENERIC_SLOT")) {
    pabi_trace( "xlang: [XLANG_DEBUG_FUNC_GENERIC_SLOT] get fi=%d n=%d name=%.*s\n",
            (int)func_index, (int)f->num_generic_params, (int)(f->name_len > 0 ? f->name_len : 0),
            (const char *)f->name);
  }
  return (int32_t)f->num_generic_params;
}

int32_t pipeline_module_func_param_type_ref_for_name(void *m, int32_t func_index, uint8_t *var_name,
                                                     int32_t var_name_len) {
  W280_Func *f;
  int32_t n, i;
  W280_FuncParam *pe;
  if (!m || !var_name || func_index < 0 || func_index >= ((W280_ModuleHdr *)m)->num_funcs)
    return 0;
  /* wave585 Cap residual: param content ≤255 (W280_FuncParam.name[256]). */
  if (var_name_len <= 0 || var_name_len > 255)
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
    if (pe->name_len <= 0 || pe->name_len > 255)
      continue;
    if (memcmp(pe->name, var_name, (size_t)var_name_len) != 0)
      continue;
    return (int32_t)pe->type_ref;
  }
  return 0;
}

int32_t pipeline_module_func_param_type_ref_at(void *m, int32_t func_index, int32_t param_index) {
  W280_FuncParam *pe;
  if (!m || func_index < 0 || func_index >= ((W280_ModuleHdr *)m)->num_funcs || param_index < 0)
    return 0;
  pe = module_func_param_entry(m, func_index, param_index, 0);
  return pe ? (int32_t)pe->type_ref : 0;
}

void pipeline_module_func_param_write(void *m, int32_t func_index, int32_t param_index,
                                      uint8_t *name_bytes, int32_t name_len, int32_t type_ref) {
  W280_FuncParam *pe;
  if (!m || !name_bytes || func_index < 0 || param_index < 0)
    return;
  /* wave585 Cap residual: content ≤255 (name[256]). */
  if (name_len < 0 || name_len > 255)
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

int32_t pipeline_module_func_param_name_len_at(void *m, int32_t func_index, int32_t param_index) {
  W280_FuncParam *pe;
  if (!m || func_index < 0 || func_index >= ((W280_ModuleHdr *)m)->num_funcs || param_index < 0)
    return 0;
  pe = module_func_param_entry(m, func_index, param_index, 0);
  /* wave585: return only legal content lengths (≤127). */
  return pe && pe->name_len > 0 && pe->name_len <= 255 ? (int32_t)pe->name_len : 0;
}

/**
 * ABI name kept as *copy32; Cap 4.2.8 raised payload 32→128→256.
 * Callers must pass a dst buffer of at least 256 bytes.
 * PLATFORM: SHARED
 */
void pipeline_module_func_param_name_copy32(void *m, int32_t func_index, int32_t param_index,
                                            uint8_t *dst) {
  W280_FuncParam *pe;
  if (!m || !dst || func_index < 0 || func_index >= ((W280_ModuleHdr *)m)->num_funcs || param_index < 0)
    return;
  pe = module_func_param_entry(m, func_index, param_index, 0);
  if (!pe) {
    memset(dst, 0, 256);
    return;
  }
  memcpy(dst, pe->name, (size_t)256);
}

void pipeline_arena_func_param_write(void *arena, int32_t func_ref, int32_t param_index,
                                     uint8_t *name_bytes, int32_t name_len, int32_t type_ref) {
  W280_FuncParam *pe;
  if (!arena || !name_bytes || func_ref <= 0 || func_ref > ((W280_ArenaHdr *)arena)->num_funcs || param_index < 0)
    return;
  /* wave585 Cap residual: content ≤255 (name[256]). */
  if (name_len < 0 || name_len > 255)
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
void pipeline_arena_func_copy_slot_from_module(void *arena, int32_t func_ref, void *m,
                                               int32_t fi) {
  W280_Func *src;
  W280_Func *dst;
  W280_ModuleSc *msc;
  W280_ArenaSc *asc;
  if (!arena || !m || func_ref <= 0 || func_ref > ((W280_ArenaHdr *)arena)->num_funcs)
    return;
  if (fi < 0 || fi >= ((W280_ModuleHdr *)m)->num_funcs)
    return;
  src = module_func_at(m, fi);
  dst = (W280_Func *)pipeline_arena_func_ptr(arena, func_ref);
  msc = (W280_ModuleSc *)module_sidecar_get(m, 0);
  asc = (W280_ArenaSc *)arena_sidecar_get(arena, 1);
  if (!src || !dst || !msc || !asc)
    return;
  *dst = *src;
  copy_func_params_between_sidecars(&asc->func_params, &dst->param_base, src->num_params, &msc->func_params,
                                    src->param_base);
}


/* =============================================================================
 * LANG-005 impl-method owner sidecar (associated-call binding, 2026-09-14).
 * Root fix for receiver-blind `X.g()` associated lookups: impl-body methods
 * are registered as flat name rows, so a scan by name could bind ANY impl's
 * method (cross-impl bleed: B.g() ran A's body; empty-impl structs passed).
 * The parser impl glue latches the current impl owner (for-type for
 * `impl T for X`, head ident for inherent `impl X`); func registration
 * stamps it here; typeck rejects rows whose owner does not bind the base.
 * Empty owner = free function / UFCS / pre-latch row (legacy accept).
 * PLATFORM: SHARED — parse latch in skip_tl glue; clear on impl RBRACE.
 * ============================================================================= */
#define PMFO_MAX 4096
static uint8_t g_pmfo_owner[PMFO_MAX][64];
static int32_t g_pmfo_owner_len[PMFO_MAX];
static uint8_t g_pmfo_cur_owner[64];
static int32_t g_pmfo_cur_len = 0;

void pipeline_module_parse_impl_owner_set(const uint8_t *nm, int32_t nlen) {
  int32_t i;
  if (nlen < 0)
    nlen = 0;
  if (nlen > 63)
    nlen = 63;
  g_pmfo_cur_len = nlen;
  for (i = 0; i < 64; i++)
    g_pmfo_cur_owner[i] = (nm && i < nlen) ? nm[i] : 0;
}

void pipeline_module_parse_impl_owner_clear(void) {
  g_pmfo_cur_len = 0;
}

/* Stamp the latched owner onto func slot fi; no-op when no impl is active. */
void pipeline_module_func_owner_from_impl(void *m, int32_t fi) {
  if (!m || fi < 0 || fi >= PMFO_MAX)
    return;
  if (g_pmfo_cur_len <= 0)
    return;
  memcpy(g_pmfo_owner[fi], g_pmfo_cur_owner, 64);
  g_pmfo_owner_len[fi] = g_pmfo_cur_len;
}

/* 1 when row fi may bind associated call on base struct name: empty owner
 * (free fn / UFCS / legacy) or owner == base. 0 = foreign impl method. */
int32_t pipeline_module_func_owner_binds_base_at(void *m, int32_t fi, const uint8_t *base, int32_t base_len) {
  int32_t i;
  if (!m || fi < 0 || fi >= PMFO_MAX)
    return 1;
  if (g_pmfo_owner_len[fi] <= 0)
    return 1;
  if (!base || base_len <= 0 || base_len > 63)
    return 0;
  if (g_pmfo_owner_len[fi] != base_len)
    return 0;
  for (i = 0; i < base_len; i++)
    if (g_pmfo_owner[fi][i] != base[i])
      return 0;
  return 1;
}

int32_t pipeline_module_func_return_type_at(void *m, int32_t fi) {
  W280_Func *f = module_func_at(m, fi);
  return f ? (int32_t)f->return_type_ref : 0;
}

/** 比较 module 函数名与外部 name 字节序列；相等返回 1。 */
int32_t pipeline_module_func_name_equal_at(void *m, int32_t fi, uint8_t *name, int32_t name_len) {
  W280_Func *f;
  /* wave577 Cap: name slots u8[128] → accept name_len <= 255 */
  if (!m || !name || name_len <= 0 || name_len > 255)
    return 0;
  f = module_func_at(m, fi);
  if (!f || (int32_t)f->name_len != name_len)
    return 0;
  return memcmp(f->name, name, (size_t)name_len) == 0 ? 1 : 0;
}

/**
 * Read module func name byte (0..name_len-1); OOB returns 0.
 * Cap 4.2.8: Func.name[256] content ≤255 — index bound is 256 (was 64).
 * PLATFORM: SHARED — WAVE280 ALWAYS domain (tip rest + cold).
 */
uint8_t pipeline_module_func_name_byte_at(void *m, int32_t fi, int32_t i) {
  W280_Func *f;
  if (!m || i < 0 || i >= 256)
    return 0;
  f = module_func_at(m, fi);
  if (!f || i >= (int32_t)f->name_len)
    return 0;
  return f->name[i];
}

int32_t pipeline_module_func_body_expr_ref_at(void *m, int32_t fi) {
  W280_Func *f = module_func_at(m, fi);
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
 * Write func name bytes into Func.name[256] (Cap: ≤255 bytes + NUL pad).
 * Called by codegen name-write path and parse-time func registration.
 * Contract: null m / OOB func_index / name_len outside [0,255] → no-op.
 */
void pipeline_module_func_name_write(void *m, int32_t func_index, uint8_t *name_bytes,
                                     int32_t name_len) {
  W280_Func *f;
  if (!m || func_index < 0)
    return;
  /* Cap 4.2.8: AST Func.name is u8[256]; allow up to 255 bytes */
  if (name_len < 0 || name_len > 255)
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
 * Copy Func.name[256] into dst (256 bytes, NUL-padded).
 * Used by codegen to avoid .x nested array GEP typeck/asm failures.
 * Contract: null m/dst / OOB func_index → no-op; copies ≤255 bytes + zero-pad.
 */
void pipeline_module_func_name_copy64(void *m, int32_t func_index, uint8_t *dst) {
  W280_Func *f;
  int32_t nlen;
  if (!m || !dst || func_index < 0)
    return;
  if (func_index >= (int32_t)((W280_ModuleHdr *)m)->num_funcs)
    return;
  f = pipeline_module_func_ptr(m, func_index);
  if (!f)
    return;
  /* Cap 4.2.8: copy name_len bytes (≤255), zero-pad rest; aligns with
   * AST name[256] to avoid truncation. */
  nlen = f->name_len;
  if (nlen < 0)
    nlen = 0;
  if (nlen > 255)
    nlen = 255;
  memset(dst, 0, 256);
  if (nlen > 0)
    memcpy(dst, f->name, (size_t)nlen);
}

/**
 * Read Func.name_len (byte count, excl. NUL).
 * Contract: null m / OOB func_index → returns 0.
 */
int32_t pipeline_module_func_name_len_at(void *m, int32_t func_index) {
  W280_Func *f;
  if (!m || func_index < 0)
    return 0;
  if (func_index >= (int32_t)((W280_ModuleHdr *)m)->num_funcs)
    return 0;
  f = pipeline_module_func_ptr(m, func_index);
  return f ? (int32_t)f->name_len : 0;
}

/**
 * Read Func.is_extern flag (1 if extern declaration, no body).
 * Contract: null m / OOB func_index → returns 0.
 */
int32_t pipeline_module_func_is_extern_at(void *m, int32_t func_index) {
  W280_Func *f;
  if (!m || func_index < 0)
    return 0;
  if (func_index >= (int32_t)((W280_ModuleHdr *)m)->num_funcs)
    return 0;
  f = pipeline_module_func_ptr(m, func_index);
  return f ? (int32_t)f->is_extern : 0;
}

/**
 * Read Func.body_ref (block_ref for function body; 0/null if extern).
 * Contract: null m / OOB func_index → returns 0.
 */
int32_t pipeline_module_func_body_ref_at(void *m, int32_t func_index) {
  W280_Func *f;
  if (!m || func_index < 0)
    return 0;
  if (func_index >= (int32_t)((W280_ModuleHdr *)m)->num_funcs)
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
int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t func_index) {
  return pipeline_module_func_is_extern_at(m, func_index);
}

int32_t pipeline_asm_module_func_body_ref_at(void *m, int32_t func_index) {
  return pipeline_module_func_body_ref_at(m, func_index);
}

int32_t pipeline_asm_module_func_name_len_at(void *m, int32_t func_index) {
  return pipeline_module_func_name_len_at(m, func_index);
}

void pipeline_asm_module_func_name_copy64(void *m, int32_t func_index, uint8_t *dst) {
  pipeline_module_func_name_copy64(m, func_index, dst);
}

int32_t pipeline_asm_module_func_num_params_at(void *m, int32_t func_index) {
  return pipeline_module_func_num_params_at(m, func_index);
}

int32_t pipeline_asm_module_func_param_name_len_at(void *m, int32_t func_index,
                                                   int32_t param_index) {
  return pipeline_module_func_param_name_len_at(m, func_index, param_index);
}

void pipeline_asm_module_func_param_name_copy32(void *m, int32_t func_index,
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
int32_t arch_arm64_pipeline_asm_module_func_is_extern_at(void *m, int32_t func_index) {
  return pipeline_asm_module_func_is_extern_at(m, func_index);
}

/** arm64.o single-module compile: forwarder for pipeline_asm_module_func_body_ref_at. */
int32_t arch_arm64_pipeline_asm_module_func_body_ref_at(void *m, int32_t func_index) {
  return pipeline_asm_module_func_body_ref_at(m, func_index);
}

/** arm64.o single-module compile: forwarder for pipeline_asm_module_func_name_len_at. */
int32_t arch_arm64_pipeline_asm_module_func_name_len_at(void *m, int32_t func_index) {
  return pipeline_asm_module_func_name_len_at(m, func_index);
}

/** arm64.o single-module compile: forwarder for pipeline_asm_module_func_name_copy64. */
void arch_arm64_pipeline_asm_module_func_name_copy64(void *m, int32_t func_index,
                                                     uint8_t *dst) {
  pipeline_asm_module_func_name_copy64(m, func_index, dst);
}


/* XLANG_PABI_MODULE_FUNC_THIN_END */
