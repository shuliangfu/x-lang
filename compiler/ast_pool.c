/**
 * ast_pool.c — AST 块/模块/OneFunc 附属数据的 C 侧可增长池。
 *
 * Block 不再内嵌 const/let/if/expr_stmt/stmt_order 固定数组，仅保留 base+count；
 * Module.funcs 亦迁至可增长池。由 pipeline_glue.c #include 进同一 TU。
 */
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdio.h>
#include <stddef.h>
#if defined(__APPLE__) || defined(__linux__)
#include <sys/mman.h>
#endif
#include <xlang_weak.h>
#include "diag.h"

/* wave246 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PLATFORM: SHARED — product ast_pool residual raw getenv call sites migrate to this face
 * (DEBUG_PIPE / ASM_DEBUG / TRACE / WPO / emit-heavy / bootstrap-emit gates; same G.7
 * pattern as wave240 pipeline_glue). Textually #include'd into pipeline_glue /
 * pipeline_glue_standalone; redeclaration is compatible with glue's wave240 extern.
 */
extern char *link_abi_getenv(const char *name);

#ifndef AST_POOL_GROW
#define AST_POOL_GROW 4096
#endif

/**
 * Initial capacity (in elements) for newly-created GrowVec pools.
 *
 * Why: separate from AST_POOL_GROW (the linear grow step) so that freshly
 * initialized pools start small (avoiding ~4.3 MB of zerofill per ArenaSidecar
 * when only a handful of entries are ever used). Combined with the linear
 * grow step AST_POOL_GROW, this gives amortized O(1) appends while keeping
 * per-arena init cost low.
 *
 * Invariant: 0 < AST_POOL_INIT_CAP <= AST_POOL_GROW. The init path uses
 * calloc() (zerofill); grow path uses realloc() + memset() on the tail.
 *
 * Asm/Perf: ArenaSidecar init cost drops from 4.3 MB -> 270 KB per arena
 * (18 GrowVecs, weighted avg elem_sz ~200B). For 50 deps this cuts init
 * RSS from ~215 MB to ~14 MB. Pools that exceed INIT_CAP grow by
 * AST_POOL_GROW (4096) elements per realloc, preserving amortized cost.
 *
 * PLATFORM: SHARED — affects mac arm64 + Ubuntu x86_64 (any pipeline_x.o
 * rebuild; ast_pool.c is #included by pipeline_glue.c).
 */
#ifndef AST_POOL_INIT_CAP
#define AST_POOL_INIT_CAP 256
#endif

/** 多 Module 共用 elf_ctx 时分配 tail_join 等局部标签 scope（定义见本文件后部）。 */
void pipeline_elf_label_mod_scope_begin_module(void);

/** 无实际上限：grow 直至 OOM；cap API 仅兼容旧 .x 边界检查。 */
#define AST_POOL_NO_LIMIT 2147483647

/** Module import 槽（C 侧 grow pool；路径最长 255 字节）。 */
typedef struct {
  uint8_t path[256];
  int32_t path_len;
  int32_t kind;
  uint8_t binding_name[128];
  int32_t binding_name_len;
  /** import { a, b } 名称在 module 侧车 select 池中的起始下标 */
  int32_t select_base;
  int32_t select_count;
} ImportEntry;

/** match 单臂（Expr 侧车池）。
 * wave700: guard_ref — optional `pat if cond =>` guard expr (0 = none).
 * PLATFORM: SHARED — product match-guard Cap residual. */
typedef struct {
  int32_t result_ref;
  int32_t is_wildcard;
  int32_t lit_val;
  int32_t is_enum_variant;
  int32_t variant_index;
  int32_t guard_ref;
} MatchArmEntry;

/** struct literal 单字段（Expr 侧车池）。 */
typedef struct {
  uint8_t name[128];
  int32_t name_len;
  int32_t init_ref;
} StructLitFieldEntry;

/** 函数形参槽（module/arena sidecar func_params 池）。
 * wave585 Cap residual: name[32]→[128] (content ≤127; match AST / let Cap).
 * PLATFORM: SHARED */
typedef struct {
  uint8_t name[128];
  int32_t name_len;
  int32_t type_ref;
} FuncParamEntry;

/** struct_layout 单字段槽（module sidecar struct_layout_fields 池）。 */
typedef struct {
  uint8_t name[128];
  int32_t name_len;
  int32_t field_offset;
  int32_t type_ref;
  /** DOD-CL：字段最小对齐（align(N)）；0 表示仅按类型自然对齐。 */
  int32_t field_align;
} StructLayoutFieldEntry;

/**
 * wave467: struct layout type-param name (`struct Pair<T, U>`).
 * Sidecar only — no StructLayout ABI churn. PLATFORM: SHARED.
 */
typedef struct {
  uint8_t name[128];
  int32_t name_len;
} LayoutTypeParamEntry;

/** Meta per layout idx: base into struct_layout_type_params, count of params. */
typedef struct {
  int32_t base;  /* -1 = unset */
  int32_t count;
} LayoutTypeParamMeta;

/** 顶层 let/const 槽。 */
typedef struct {
  uint8_t name[128];
  int32_t name_len;
  int32_t type_ref;
  int32_t init_ref;
  int32_t is_const;
  /** 1=`export const` / `export let`（顶层）；进入模块导出表。 */
  int32_t is_export;
} TopLevelLetEntry;

/** 顶层 type 别名槽：type Alias = Target;（纯 typeck 别名，codegen typedef）。 */
typedef struct {
  uint8_t name[128];
  int32_t name_len;
  int32_t target_type_ref;
} TypeAliasEntry;

/** 顶层 enum 名槽；变体名在 parse 跳过 enum { A, B } 时登记，供 asm Color.Green 等发射 tag。 */
/**
 * TokenKind 等前端枚举已超过 64 变体（token.x 约 130+）。
 * 截断会导致 TOKEN_LPAREN 等 tag 查找失败 → tok.kind = TokenKind.X 报 found ?。
 */
#define MODULE_ENUM_MAX_VARIANTS 256
typedef struct {
  uint8_t name[128];
  int32_t name_len;
  int32_t num_variants;
  uint8_t variant_name[MODULE_ENUM_MAX_VARIANTS][128];
  int32_t variant_name_len[MODULE_ENUM_MAX_VARIANTS];
  /** 1=`export enum`；类型名 ∈ E(M)。 */
  int32_t is_export;
} ModuleEnumEntry;

/**
 * Growable vector of fixed-size elements.
 *
 * PLATFORM: SHARED — large buffers (>= GROW_VEC_MMAP_THRESH) use anonymous
 * mmap so grow_vec_free can munmap and return RSS immediately. Small buffers
 * stay on malloc/calloc. This is the root fix for `xlang check` peak RSS:
 * sequential mega-dep parses must not leave multi-GB high-water on macOS
 * (system free keeps pages) or Ubuntu (zone freelist).
 */
typedef struct {
  uint8_t *data;
  int32_t cap;
  int32_t len;
  size_t elem_sz;
  /** 1 = data from mmap(MAP_ANON); free via munmap. 0 = malloc/calloc/realloc. */
  int32_t mmap_backed;
} GrowVec;

/** Byte size at which GrowVec switches to mmap (1 MiB). */
#ifndef GROW_VEC_MMAP_THRESH
#define GROW_VEC_MMAP_THRESH ((size_t)(1024 * 1024))
#endif

/**
 * Allocate nbytes for a GrowVec. Uses mmap for large blocks.
 * @param nbytes size in bytes; must be > 0
 * @param out_mmap set to 1 if mmap, 0 if calloc
 * @return pointer or NULL
 */
static void *grow_vec_alloc_bytes(size_t nbytes, int32_t *out_mmap) {
  if (out_mmap)
    *out_mmap = 0;
  if (nbytes == 0)
    return NULL;
#if defined(__APPLE__) || defined(__linux__)
  if (nbytes >= GROW_VEC_MMAP_THRESH) {
    void *p = mmap(NULL, nbytes, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, -1, 0);
    if (p != MAP_FAILED) {
      if (out_mmap)
        *out_mmap = 1;
      return p;
    }
    /* fall through to calloc on mmap failure */
  }
#endif
  return calloc(1, nbytes);
}

/**
 * Deallocate GrowVec data (mmap munmap or free).
 * @param p data pointer; may be null
 * @param nbytes size when mmap_backed (ignored for free)
 * @param mmap_backed 1 if p is mmap
 */
static void grow_vec_dealloc_bytes(void *p, size_t nbytes, int32_t mmap_backed) {
  if (!p)
    return;
#if defined(__APPLE__) || defined(__linux__)
  if (mmap_backed) {
    if (nbytes > 0)
      (void)munmap(p, nbytes);
    return;
  }
#else
  (void)nbytes;
  (void)mmap_backed;
#endif
  free(p);
}

static int grow_vec_init(GrowVec *v, size_t elem_sz, int32_t initial_cap) {
  size_t nbytes;
  int32_t mm = 0;
  v->data = NULL;
  v->cap = 0;
  v->len = 0;
  v->elem_sz = elem_sz;
  v->mmap_backed = 0;
  /* Default to the smaller INIT_CAP (256) instead of the grow step (4096)
   * so that fresh pools do not zerofill 4.3 MB per ArenaSidecar. Pools that
   * outgrow INIT_CAP will realloc by AST_POOL_GROW (4096) elements. */
  if (initial_cap <= 0)
    initial_cap = AST_POOL_INIT_CAP;
  nbytes = (size_t)initial_cap * elem_sz;
  v->data = (uint8_t *)grow_vec_alloc_bytes(nbytes, &mm);
  if (!v->data)
    return 0;
  v->mmap_backed = mm;
  v->cap = initial_cap;
  return 1;
}

static void grow_vec_free(GrowVec *v) {
  if (v && v->data) {
    size_t nbytes = (size_t)v->cap * v->elem_sz;
    grow_vec_dealloc_bytes(v->data, nbytes, v->mmap_backed);
    v->data = NULL;
  }
  if (v) {
    v->cap = 0;
    v->len = 0;
    v->mmap_backed = 0;
  }
}

/**
 * Ensure capacity for one more element. Returns 1 on success.
 *
 * Growth policy (PLATFORM: SHARED):
 * - Small heap buffers: linear step AST_POOL_GROW (realloc often in-place).
 * - mmap-backed / large: **double** capacity (geometric). mmap cannot grow
 *   in place; linear +4096 caused O(n^2) full-array memcpy and made
 *   `xlang check main.x` appear hung (codegen dep ~1.2M exprs → ~100GB copy).
 * wave1242b: geometric mmap growth fix after wave1242 mmap RSS work.
 */
static int grow_vec_ensure(GrowVec *v) {
  int32_t need;
  int32_t nc;
  int32_t old_cap;
  int32_t mm = 0;
  size_t old_bytes;
  size_t new_bytes;
  uint8_t *p;
  if (!v)
    return 0;
  need = v->len + 1;
  if (need <= v->cap)
    return 1;
  old_cap = v->cap;
  nc = v->cap > 0 ? v->cap : AST_POOL_GROW;
  /* Will this resize be mmap-path? Prefer geometric growth then. */
  if (v->mmap_backed ||
      (size_t)need * v->elem_sz >= GROW_VEC_MMAP_THRESH ||
      (size_t)nc * v->elem_sz >= GROW_VEC_MMAP_THRESH) {
    while (nc < need) {
      if (nc > 1073741823) { /* prevent i32 overflow */
        nc = need;
        break;
      }
      nc = nc * 2;
    }
    if (nc < need)
      nc = need;
  } else {
    while (nc < need)
      nc += AST_POOL_GROW;
  }
  old_bytes = (size_t)old_cap * v->elem_sz;
  new_bytes = (size_t)nc * v->elem_sz;
  /*
   * Large path: mmap so free can munmap (RSS). Always alloc+copy+dealloc
   * (no realloc on mmap). Geometric nc above keeps total copy O(n).
   */
  if (v->mmap_backed || new_bytes >= GROW_VEC_MMAP_THRESH) {
    p = (uint8_t *)grow_vec_alloc_bytes(new_bytes, &mm);
    if (!p)
      return 0;
    if (v->data && old_bytes > 0)
      memcpy(p, v->data, old_bytes);
    /* new tail already zero from mmap/calloc */
    grow_vec_dealloc_bytes(v->data, old_bytes, v->mmap_backed);
    v->data = p;
    v->mmap_backed = mm;
    v->cap = nc;
    return 1;
  }
  p = (uint8_t *)realloc(v->data, new_bytes);
  if (!p)
    return 0;
  memset(p + old_bytes, 0, new_bytes - old_bytes);
  v->data = p;
  v->mmap_backed = 0;
  v->cap = nc;
  return 1;
}

static void *grow_vec_at(GrowVec *v, int32_t idx) {
  if (!v || !v->data || idx < 0 || idx >= v->len)
    return NULL;
  return v->data + (size_t)idx * v->elem_sz;
}

/** 追加零初始化元素，返回新下标；失败返回 -1。 */
static int32_t grow_vec_push(GrowVec *v) {
  int32_t idx;
  if (!grow_vec_ensure(v))
    return -1;
  idx = v->len;
  memset(v->data + (size_t)idx * v->elem_sz, 0, v->elem_sz);
  v->len++;
  return idx;
}

/** Append all elements of src onto dst (caller may reset dst first).
 *  PLATFORM: SHARED — used by onefunc_copy_sidecar + dep_ctx empty_param backup. */
static void grow_vec_copy_append(GrowVec *dst, GrowVec *src) {
  int32_t i;
  if (!dst || !src)
    return;
  for (i = 0; i < src->len; i++) {
    void *ps = grow_vec_at(src, i);
    void *pd;
    if (grow_vec_push(dst) < 0)
      return;
    pd = grow_vec_at(dst, dst->len - 1);
    if (ps && pd)
      memcpy(pd, ps, src->elem_sz);
  }
}

/** M-3：region label { body } 侧车槽（与 C ASTRegionBlock 语义一致）。 */
typedef struct {
  uint8_t label[128];
  int32_t label_len;
  int32_t body_ref;
  /** MEM-C1：>0 表示 with_arena(cap) 块（cap 表达式 ref）；0 表示普通 region。 */
  int32_t with_arena_cap_ref;
} RegionBlockEntry;

/** 每个 ASTArena 的统一 sidecar：主池 + 块附属池。 */
typedef struct {
  struct ast_ASTArena *arena;
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
  /** Expr 变长附属：call/method 实参、match 臂、struct lit 字段、array lit 元素 */
  GrowVec expr_call_arg_refs;
  /**
   * wave452: CALL turbofish type-arg type_refs (flat pool).
   * Base per expr is in expr_call_type_arg_bases[expr_ref] (sidecar only —
   * avoids Expr layout / SHARED ABI churn). count remains Expr.call_num_type_args.
   * PLATFORM: SHARED — G.7 single authority with pipeline_expr_call_type_arg_* APIs.
   */
  GrowVec expr_call_type_arg_refs;
  /** Index by expr_ref; value is base into expr_call_type_arg_refs, or -1 if unset. */
  GrowVec expr_call_type_arg_bases;
  /**
   * wave467: TYPE_NAMED type-position args `Name<T,U>` (flat pool).
   * Base per type_ref in type_type_arg_bases; count remains Type.array_size for NAMED.
   * Slot0 also mirrored in Type.elem_type_ref (wave466 single-arg compat).
   * PLATFORM: SHARED — G.7 single authority with pipeline_type_type_arg_* APIs.
   */
  GrowVec type_type_arg_refs;
  /** Index by type_ref; value is base into type_type_arg_refs, or -1 if unset. */
  GrowVec type_type_arg_bases;
  /** Index by type_ref; number of type-pos args appended (wave467). */
  GrowVec type_type_arg_counts;
  GrowVec expr_method_call_arg_refs;
  GrowVec expr_match_arms;
  GrowVec expr_struct_lit_fields;
  GrowVec expr_array_lit_elem_refs;
  GrowVec func_params;
} ArenaSidecar;

/** 每个 Module 的动态池。 */
typedef struct {
  struct ast_Module *module;
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
  /**
   * wave467: layout type-param names (flat) + per-layout meta (base/count).
   * PLATFORM: SHARED — G.7 with pipeline_module_struct_layout_*_type_param_* APIs.
   */
  GrowVec struct_layout_type_params;
  GrowVec struct_layout_type_param_meta;
} ModuleSidecar;

/** M-3：OneFunc 侧车 region 条目。 */
typedef struct {
  uint8_t label[128];
  int32_t label_len;
  int32_t body_ref;
  /** MEM-C1：>0 表示 with_arena(cap)；LANG-007：-1 表示 unsafe { body }。 */
  int32_t with_arena_cap_ref;
} OneFuncRegionEntry;

/**
 * wave379: OneFunc scratch entry for `goto target;` / `label:` / `label: return expr`.
 * Mirrors `struct ast_LabeledStmt` (wave586 Cap: label 128B + is_goto + goto_target 128B + return_expr_ref).
 * PLATFORM: SHARED — filled into Block.labeled_stmts via fill_labeled_from_onefunc;
 * stmt_order kind=7 indexes this pool (G.7 single authority with parse_block path).
 */
typedef struct {
  uint8_t label[128];
  int32_t label_len;
  int32_t is_goto;
  uint8_t goto_target[128];
  int32_t goto_target_len;
  int32_t return_expr_ref;
} OneFuncLabeledEntry;

/** parse_one_function_impl 的 scratch 池，按 OneFuncResult* 键控。 */
typedef struct {
  void *onefunc;
  int used;
  GrowVec if_cond_refs;
  GrowVec if_then_body_refs;
  GrowVec if_else_body_refs;
  GrowVec const_names;
  GrowVec const_name_lens;
  GrowVec const_init_vals;
  GrowVec const_init_refs;
  GrowVec const_type_refs;
  GrowVec let_names;
  GrowVec let_name_lens;
  GrowVec let_init_vals;
  GrowVec let_init_refs;
  GrowVec let_type_refs;
  GrowVec src_stmt_kind;
  GrowVec src_stmt_idx;
  GrowVec src_body_expr_stmt_refs;
  GrowVec while_cond_refs;
  GrowVec while_body_refs;
  GrowVec for_init_refs;
  GrowVec for_cond_refs;
  GrowVec for_step_refs;
  GrowVec for_body_refs;
  /** 解析 scratch 形参（32 字节名 + type_ref）与 call 整型实参。 */
  GrowVec param_names;
  GrowVec param_name_lens;
  GrowVec param_type_refs;
  GrowVec call_arg_vals;
  /** M-3：region label { body } 暂存（parse_one_function_impl → Block 池）。 */
  GrowVec regions;
  /** MEM-B0：defer { body } 暂存（parse_one_function_impl → Block 池）。 */
  GrowVec defer_body_refs;
  /** wave379: goto/label labeled_stmts scratch → Block pool (stmt_order kind=7). */
  GrowVec labeleds;
} OneFuncSidecar;

/** PipelineDepCtx 侧车：dep 槽与 -L lib_root 动态 grow（ctx 指针作键）。 */
typedef struct {
  struct ast_PipelineDepCtx *ctx;
  int used;
  GrowVec dep_modules;
  GrowVec dep_arenas;
  GrowVec dep_path_rows;
  GrowVec dep_path_lens;
  GrowVec lib_root_rows;
  GrowVec lib_root_lens;
  /** codegen 无名形参 param 下标；backup 供 emit 函数内 save/restore。 */
  GrowVec empty_param_indices;
  GrowVec empty_param_backup;
} DepCtxSidecar;

/** driver -x -E / check compile argv: DriverCompileState* (or emit state) keyed lib_root pool.
 *
 * wave1243: slots were never released when heap `driver_compile_state_free_c` ran.
 * Directory `xlang check` allocs a unique state per file → after 32 files every
 * sidecar is occupied, `driver_emit_append_lib_root` fails, -L roots vanish, and
 * import resolve falls back to a stale/wrong entry_dir (often reporting paths under
 * `.../asm/http/...` as IMP001). PLATFORM: SHARED — mac + Ubuntu check matrix.
 */
typedef struct {
  void *state;
  int used;
  GrowVec lib_root_rows;
  GrowVec lib_root_lens;
} DriverEmitSidecar;

/* 32 was the hard failure point for `check compiler` (32×tiny + next file IMP001).
 * Keep modest headroom; release on free is the real fix. */
#define MAX_DRIVER_EMIT_SIDECARS 64

#define MAX_DEP_CTX_SIDECARS 64
/* PLATFORM: SHARED — sidecar table caps (pointer-keyed global pools).
 * MAX_ONEFUNC_SIDECARS: raised 256→1024 for codegen M1 (2026-07-17).
 * Peak observed under XLANG_DEBUG_PIPE while -E src/codegen/codegen.x:
 *   onefunc≈385 (typeck mega only ≈206). Old 256 exhausted → dep=ast
 *   parse_set_main stopped at num_funcs=5 / collect pr_ok=-2 (XT001).
 * Arena/module remain 512 (peak observed arena=3 module=3 on codegen M1). */
#define MAX_ARENA_SIDECARS 512
#define MAX_MODULE_SIDECARS 512
#define MAX_ONEFUNC_SIDECARS 1024

static ArenaSidecar g_arena_sc[MAX_ARENA_SIDECARS];
static ModuleSidecar g_module_sc[MAX_MODULE_SIDECARS];
static OneFuncSidecar g_onefunc_sc[MAX_ONEFUNC_SIDECARS];
/*
 * PLATFORM: SHARED — process-wide DepCtx sidecar table (G.7 single authority).
 *
 * Must NOT be `static`: pure static crt0 embeds depctx_sidecar_get in both
 * pipeline_x / glue_standalone (global) and crt0 L5 pipeline partial (local).
 * Per-TU static BSS → dual tables keyed by the same PipelineDepCtx*:
 *   load_and_sync set_module/path writes table A;
 *   Cap run_x_pipeline_codegen_one_dep module_at reads table B;
 *   codegen_x_ast path_copy reads table A → module/path split
 *   (NL-07 pure static si -o: core.types body emitted as core_result_*).
 *
 * Non-static global: multi-def objects share one BSS under
 * --allow-multiple-definition (product + nostdlib crt0). Weak so a single
 * surviving definition owns all references when the linker merges.
 *
 * ALSO required: ld_partial_export (build_xlang_asm.sh / relink strict glue) must
 * keep this symbol GLOBAL when extracting pipeline partials. Linux
 * objcopy --keep-global-symbols and Darwin -exported_symbols_list localize
 * unlisted symbols; a localized copy + static depctx_sidecar_get reopens the
 * dual-table split even when this definition is weak in the source .o.
 */
#if defined(__GNUC__) || defined(__clang__)
__attribute__((weak))
#endif
DepCtxSidecar g_xlang_depctx_sc[MAX_DEP_CTX_SIDECARS];
static DriverEmitSidecar g_driver_emit_sc[MAX_DRIVER_EMIT_SIDECARS];

static DepCtxSidecar *depctx_sidecar_get(struct ast_PipelineDepCtx *ctx, int create) {
  int i;
  if (!ctx)
    return NULL;
  for (i = 0; i < MAX_DEP_CTX_SIDECARS; i++) {
    if (g_xlang_depctx_sc[i].used && g_xlang_depctx_sc[i].ctx == ctx)
      return &g_xlang_depctx_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_DEP_CTX_SIDECARS; i++) {
    if (!g_xlang_depctx_sc[i].used) {
      g_xlang_depctx_sc[i].ctx = ctx;
      g_xlang_depctx_sc[i].used = 1;
      if (!grow_vec_init(&g_xlang_depctx_sc[i].dep_modules, sizeof(void *), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_xlang_depctx_sc[i].dep_arenas, sizeof(void *), AST_POOL_INIT_CAP))
        return NULL;
      /* wave579 Cap: path row width 64→128 (import paths may be >63 after Cap).
       * PLATFORM: SHARED — must match set_import_path memcpy cap below. */
      if (!grow_vec_init(&g_xlang_depctx_sc[i].dep_path_rows, 128, AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_xlang_depctx_sc[i].dep_path_lens, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_xlang_depctx_sc[i].lib_root_rows, 256, AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_xlang_depctx_sc[i].lib_root_lens, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_xlang_depctx_sc[i].empty_param_indices, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_xlang_depctx_sc[i].empty_param_backup, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      return &g_xlang_depctx_sc[i];
    }
  }
  return NULL;
}

/** 确保 dep 侧车池至少有 idx+1 个槽。 */
static int depctx_ensure_slot(DepCtxSidecar *sc, int32_t idx) {
  int32_t need;
  void **pm;
  void **pa;
  uint8_t *row;
  int32_t *pl;
  if (!sc || idx < 0)
    return 0;
  need = idx + 1;
  while (sc->dep_modules.len < need) {
    if (grow_vec_push(&sc->dep_modules) < 0)
      return 0;
    pm = (void **)grow_vec_at(&sc->dep_modules, sc->dep_modules.len - 1);
    if (pm)
      *pm = NULL;
    if (grow_vec_push(&sc->dep_arenas) < 0)
      return 0;
    pa = (void **)grow_vec_at(&sc->dep_arenas, sc->dep_arenas.len - 1);
    if (pa)
      *pa = NULL;
    if (grow_vec_push(&sc->dep_path_rows) < 0)
      return 0;
    row = (uint8_t *)grow_vec_at(&sc->dep_path_rows, sc->dep_path_rows.len - 1);
    if (row)
      memset(row, 0, 128);
    if (grow_vec_push(&sc->dep_path_lens) < 0)
      return 0;
    pl = (int32_t *)grow_vec_at(&sc->dep_path_lens, sc->dep_path_lens.len - 1);
    if (pl)
      *pl = 0;
  }
  return 1;
}

static ArenaSidecar *arena_sidecar_get(struct ast_ASTArena *a, int create) {
  int i;
  if (!a)
    return NULL;
  for (i = 0; i < MAX_ARENA_SIDECARS; i++) {
    if (g_arena_sc[i].used && g_arena_sc[i].arena == a)
      return &g_arena_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_ARENA_SIDECARS; i++) {
    if (!g_arena_sc[i].used) {
      g_arena_sc[i].arena = a;
      g_arena_sc[i].used = 1;
      if (!grow_vec_init(&g_arena_sc[i].types, sizeof(struct ast_Type), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].exprs, sizeof(struct ast_Expr), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].blocks, sizeof(struct ast_Block), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].funcs, sizeof(struct ast_Func), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].consts, sizeof(struct ast_ConstDecl), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].lets, sizeof(struct ast_LetDecl), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].ifs, sizeof(struct ast_IfStmt), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].regions, sizeof(RegionBlockEntry), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].loops, sizeof(struct ast_WhileLoop), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].for_loops, sizeof(struct ast_ForLoop), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].defer_block_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].labeled_stmts, sizeof(struct ast_LabeledStmt), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_stmt_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].stmt_order, sizeof(struct ast_StmtOrderItem), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_call_arg_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_call_type_arg_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_call_type_arg_bases, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].type_type_arg_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].type_type_arg_bases, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].type_type_arg_counts, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_method_call_arg_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_match_arms, sizeof(MatchArmEntry), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_struct_lit_fields, sizeof(StructLitFieldEntry), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_array_lit_elem_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].func_params, sizeof(FuncParamEntry), AST_POOL_INIT_CAP))
        return NULL;
      return &g_arena_sc[i];
    }
  }
  return NULL;
}

static ModuleSidecar *module_sidecar_get(struct ast_Module *m, int create) {
  int i;
  if (!m)
    return NULL;
  for (i = 0; i < MAX_MODULE_SIDECARS; i++) {
    if (g_module_sc[i].used && g_module_sc[i].module == m)
      return &g_module_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_MODULE_SIDECARS; i++) {
    if (!g_module_sc[i].used) {
      g_module_sc[i].module = m;
      g_module_sc[i].used = 1;
      if (!grow_vec_init(&g_module_sc[i].funcs, sizeof(struct ast_Func), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].func_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].imports, sizeof(ImportEntry), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].struct_layouts, sizeof(struct ast_StructLayout), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].top_level_lets, sizeof(TopLevelLetEntry), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].type_aliases, sizeof(TypeAliasEntry), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].module_enums, sizeof(ModuleEnumEntry), AST_POOL_INIT_CAP))
        return NULL;
      /* wave584 Cap residual: select name row width 64→128 (content ≤127). */
      if (!grow_vec_init(&g_module_sc[i].import_select_name_rows, 128, AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].import_select_name_lens, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].func_params, sizeof(FuncParamEntry), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].struct_layout_fields, sizeof(StructLayoutFieldEntry), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].struct_layout_type_params, sizeof(LayoutTypeParamEntry),
                         AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].struct_layout_type_param_meta, sizeof(LayoutTypeParamMeta),
                         AST_POOL_INIT_CAP))
        return NULL;
      return &g_module_sc[i];
    }
  }
  return NULL;
}

static OneFuncSidecar *onefunc_sidecar_get(uint8_t *out, int create) {
  int i;
  if (!out)
    return NULL;
  for (i = 0; i < MAX_ONEFUNC_SIDECARS; i++) {
    if (g_onefunc_sc[i].used && g_onefunc_sc[i].onefunc == out)
      return &g_onefunc_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_ONEFUNC_SIDECARS; i++) {
    if (!g_onefunc_sc[i].used) {
      g_onefunc_sc[i].onefunc = out;
      g_onefunc_sc[i].used = 1;
      if (!grow_vec_init(&g_onefunc_sc[i].if_cond_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].if_then_body_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].if_else_body_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      /* wave581 Cap residual: OneFunc const/let name rows 64→128 (match AST name[128]). */
      if (!grow_vec_init(&g_onefunc_sc[i].const_names, 128, AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].const_name_lens, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].const_init_vals, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].const_init_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].const_type_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].let_names, 128, AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].let_name_lens, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].let_init_vals, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].let_init_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].let_type_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].src_stmt_kind, sizeof(uint8_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].src_stmt_idx, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].src_body_expr_stmt_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].while_cond_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].while_body_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].for_init_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].for_cond_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].for_step_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].for_body_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      /* wave585 Cap residual: OneFunc param name rows 32→128 (match FuncParamEntry). */
      if (!grow_vec_init(&g_onefunc_sc[i].param_names, 128, AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].param_name_lens, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].param_type_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].call_arg_vals, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].regions, sizeof(OneFuncRegionEntry), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].defer_body_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      /* wave379: goto/label OneFunc scratch (stmt_order kind=7). PLATFORM: SHARED. */
      if (!grow_vec_init(&g_onefunc_sc[i].labeleds, sizeof(OneFuncLabeledEntry), AST_POOL_INIT_CAP))
        return NULL;
      return &g_onefunc_sc[i];
    }
  }
  return NULL;
}

static void onefunc_sidecar_free(OneFuncSidecar *sc) {
  if (!sc)
    return;
  grow_vec_free(&sc->if_cond_refs);
  grow_vec_free(&sc->if_then_body_refs);
  grow_vec_free(&sc->if_else_body_refs);
  grow_vec_free(&sc->const_names);
  grow_vec_free(&sc->const_name_lens);
  grow_vec_free(&sc->const_init_vals);
  grow_vec_free(&sc->const_init_refs);
  grow_vec_free(&sc->const_type_refs);
  grow_vec_free(&sc->let_names);
  grow_vec_free(&sc->let_name_lens);
  grow_vec_free(&sc->let_init_vals);
  grow_vec_free(&sc->let_init_refs);
  grow_vec_free(&sc->let_type_refs);
  grow_vec_free(&sc->src_stmt_kind);
  grow_vec_free(&sc->src_stmt_idx);
  grow_vec_free(&sc->src_body_expr_stmt_refs);
  grow_vec_free(&sc->while_cond_refs);
  grow_vec_free(&sc->while_body_refs);
  grow_vec_free(&sc->for_init_refs);
  grow_vec_free(&sc->for_cond_refs);
  grow_vec_free(&sc->for_step_refs);
  grow_vec_free(&sc->for_body_refs);
  grow_vec_free(&sc->param_names);
  grow_vec_free(&sc->param_name_lens);
  grow_vec_free(&sc->param_type_refs);
  grow_vec_free(&sc->call_arg_vals);
  grow_vec_free(&sc->regions);
  grow_vec_free(&sc->defer_body_refs);
  grow_vec_free(&sc->labeleds);
  memset(sc, 0, sizeof(*sc));
}

/**
 * Free all GrowVec data buffers owned by an ArenaSidecar and mark the slot
 * as unused, so the static `g_arena_sc[]` slot can be reused by a future
 * arena allocation.
 *
 * Why: Without this, every `malloc(arena_sz)` + `parser_parse_into_init`
 * in the dep loop of `driver_run_x_emit_c` allocates a fresh ArenaSidecar
 * slot (20 GrowVecs, each with its own calloc'd data buffer) that is never
 * released — only `free(arena)` (16 bytes) is called, leaking all GrowVec
 * data. For 50 deps this leaks ~215 MB of init cap alone (pre-INIT_CAP fix)
 * or ~14 MB (post-INIT_CAP=256); with actual AST nodes it can reach GBs.
 *
 * Invariant: caller MUST guarantee the arena is no longer accessed by
 * typeck/codegen/pipeline. In `driver_run_x_emit_c`, this holds because
 * the release calls happen after `xlang_pipeline_run_x_pipeline_large_stack`
 * returns (typeck+codegen+emit all done).
 *
 * Asm/Perf: O(20) grow_vec_free calls (each is a free()+memset). Negligible
 * vs. the malloc/parse cost. The slot's `used` flag is cleared so the next
 * `arena_sidecar_get(create=1)` can reuse it instead of advancing to the
 * next free slot (preventing MAX_ARENA_SIDECARS=512 exhaustion).
 *
 * PLATFORM: SHARED — affects mac arm64 + Ubuntu x86_64 (any pipeline_x.o
 * rebuild; ast_pool.c is #included by pipeline_glue.c).
 */
static void arena_sidecar_free(ArenaSidecar *sc) {
  if (!sc)
    return;
  grow_vec_free(&sc->types);
  grow_vec_free(&sc->exprs);
  grow_vec_free(&sc->blocks);
  grow_vec_free(&sc->funcs);
  grow_vec_free(&sc->consts);
  grow_vec_free(&sc->lets);
  grow_vec_free(&sc->ifs);
  grow_vec_free(&sc->regions);
  grow_vec_free(&sc->loops);
  grow_vec_free(&sc->for_loops);
  grow_vec_free(&sc->defer_block_refs);
  grow_vec_free(&sc->labeled_stmts);
  grow_vec_free(&sc->expr_stmt_refs);
  grow_vec_free(&sc->stmt_order);
  grow_vec_free(&sc->expr_call_arg_refs);
  grow_vec_free(&sc->expr_call_type_arg_refs);
  grow_vec_free(&sc->expr_call_type_arg_bases);
  grow_vec_free(&sc->type_type_arg_refs);
  grow_vec_free(&sc->type_type_arg_bases);
  grow_vec_free(&sc->type_type_arg_counts);
  grow_vec_free(&sc->expr_method_call_arg_refs);
  grow_vec_free(&sc->expr_match_arms);
  grow_vec_free(&sc->expr_struct_lit_fields);
  grow_vec_free(&sc->expr_array_lit_elem_refs);
  grow_vec_free(&sc->func_params);
  memset(sc, 0, sizeof(*sc));
}

/**
 * Free all GrowVec data buffers owned by a ModuleSidecar and mark the slot
 * as unused, so the static `g_module_sc[]` slot can be reused.
 *
 * Why: Same leak pattern as ArenaSidecar — `free(module)` (sizeof Module)
 * does not release the 11 GrowVec data buffers in the ModuleSidecar slot.
 *
 * Invariant: caller MUST guarantee the module is no longer accessed by
 * typeck/codegen/pipeline. See `arena_sidecar_free` above.
 *
 * PLATFORM: SHARED — same as `arena_sidecar_free`.
 */
static void module_sidecar_free(ModuleSidecar *sc) {
  if (!sc)
    return;
  grow_vec_free(&sc->funcs);
  grow_vec_free(&sc->func_refs);
  grow_vec_free(&sc->imports);
  grow_vec_free(&sc->struct_layouts);
  grow_vec_free(&sc->top_level_lets);
  grow_vec_free(&sc->type_aliases);
  grow_vec_free(&sc->module_enums);
  grow_vec_free(&sc->import_select_name_rows);
  grow_vec_free(&sc->import_select_name_lens);
  grow_vec_free(&sc->func_params);
  grow_vec_free(&sc->struct_layout_fields);
  grow_vec_free(&sc->struct_layout_type_params);
  grow_vec_free(&sc->struct_layout_type_param_meta);
  memset(sc, 0, sizeof(*sc));
}

/**
 * Free DepCtxSidecar GrowVecs and mark the process-wide slot unused.
 *
 * Why: pipeline_dep_ctx_heap_destroy used to free(ctx) only. That left
 * g_xlang_depctx_sc[MAX=64] used with dangling ctx keys; batch check exhausts
 * the table and subsequent dep path mapping / parse degrades (num_funcs drop).
 * PLATFORM: SHARED — pair with free(ctx) in heap_destroy (wave1228).
 */
static void depctx_sidecar_free(DepCtxSidecar *sc) {
  if (!sc)
    return;
  grow_vec_free(&sc->dep_modules);
  grow_vec_free(&sc->dep_arenas);
  grow_vec_free(&sc->dep_path_rows);
  grow_vec_free(&sc->dep_path_lens);
  grow_vec_free(&sc->lib_root_rows);
  grow_vec_free(&sc->lib_root_lens);
  grow_vec_free(&sc->empty_param_indices);
  grow_vec_free(&sc->empty_param_backup);
  memset(sc, 0, sizeof(*sc));
}

/**
 * Release process-wide DepCtx sidecar for this PipelineDepCtx pointer.
 * Call before free(ctx). Safe no-op if null or untracked.
 * PLATFORM: SHARED — G.7 single teardown for batch check (wave1228).
 */
void pipeline_dep_ctx_sidecar_release(struct ast_PipelineDepCtx *ctx) {
  int i;
  if (!ctx)
    return;
  for (i = 0; i < MAX_DEP_CTX_SIDECARS; i++) {
    if (g_xlang_depctx_sc[i].used && g_xlang_depctx_sc[i].ctx == ctx) {
      depctx_sidecar_free(&g_xlang_depctx_sc[i]);
      return;
    }
  }
}

static struct ast_Block *block_at(struct ast_ASTArena *a, int32_t br) {
  ArenaSidecar *sc;
  if (!a || br <= 0 || br > a->num_blocks)
    return NULL;
  sc = arena_sidecar_get(a, 0);
  if (!sc)
    return NULL;
  return (struct ast_Block *)grow_vec_at(&sc->blocks, br - 1);
}

static struct ast_StructLayout *module_layout_at(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc;
  if (!m || idx < 0 || idx >= m->num_struct_layouts)
    return NULL;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return NULL;
  return (struct ast_StructLayout *)grow_vec_at(&sc->struct_layouts, idx);
}

static ImportEntry *module_import_at(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc;
  if (!m || idx < 0 || idx >= m->num_imports)
    return NULL;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return NULL;
  return (ImportEntry *)grow_vec_at(&sc->imports, idx);
}

/** 前向声明：pipeline_arena_block_alloc 在定义前调用。 */
void ast_pool_block_on_alloc(struct ast_ASTArena *a, int32_t block_ref);

/** BC 8.3.2: ASTArena main-pool cold accessors domain (same-TU thin). */
#include "ast_pool_arena.c"

/* wave1166 G.7: type pool cold accessors (read/write/find-or-alloc) —
 * migrated from pipeline_glue.c L1041-1153/L2216. Same TU via ast_pool.c
 * #include. Depends on pipeline_arena_type_ptr / pipeline_arena_type_alloc
 * (ast_pool_arena.c above). Forward decls retained in glue.c L761-762
 * (kind_ord_at / array_size_at) for callsites before this #include at
 * glue.c L5160.
 * PLATFORM: SHARED — host-cc Cap residual; parser/typeck/codegen call these. */
#include "ast_pool_type.c"


static struct ast_Func *module_func_at(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc;
  if (!m || idx < 0 || idx >= m->num_funcs)
    return NULL;
  sc = module_sidecar_get(m, 0);
  if (!sc || idx >= sc->funcs.len)
    return NULL;
  return (struct ast_Func *)grow_vec_at(&sc->funcs, idx);
}

/** 将 src 侧车 func_params 中 n 个形参复制到 dst 侧车，并写 *dst_base。 */
static void copy_func_params_between_sidecars(GrowVec *dst, int32_t *dst_base, int32_t n, GrowVec *src,
                                              int32_t src_base) {
  int32_t i, abs_src, abs_dst;
  FuncParamEntry *se, *de;
  if (!dst || !src || n <= 0)
    return;
  *dst_base = dst->len;
  for (i = 0; i < n; i++) {
    abs_src = src_base + i;
    se = (FuncParamEntry *)grow_vec_at(src, abs_src);
    if (grow_vec_push(dst) < 0)
      break;
    abs_dst = dst->len - 1;
    de = (FuncParamEntry *)grow_vec_at(dst, abs_dst);
    if (se && de)
      *de = *se;
  }
}

/** 读/写 module 函数形参 sidecar 槽；create=1 时按需 grow。 */
static FuncParamEntry *module_func_param_entry(struct ast_Module *m, int32_t fi, int32_t pi, int create) {
  ModuleSidecar *sc;
  struct ast_Func *f;
  int32_t abs;
  if (!m || fi < 0 || pi < 0)
    return NULL;
  f = module_func_at(m, fi);
  if (!f)
    return NULL;
  sc = module_sidecar_get(m, create ? 1 : 0);
  if (!sc)
    return NULL;
  if (!create) {
    if (pi >= f->num_params || f->param_base < 0)
      return NULL;
    abs = f->param_base + pi;
    if (abs < 0 || abs >= sc->func_params.len)
      return NULL;
    return (FuncParamEntry *)grow_vec_at(&sc->func_params, abs);
  }
  /** 与 struct_layout field_base 相同：-1=未挂接，0 是合法池起点。 */
  if (f->param_base < 0)
    f->param_base = sc->func_params.len;
  abs = f->param_base + pi;
  while (sc->func_params.len <= abs) {
    if (grow_vec_push(&sc->func_params) < 0)
      return NULL;
  }
  if (pi + 1 > f->num_params)
    f->num_params = pi + 1;
  return (FuncParamEntry *)grow_vec_at(&sc->func_params, abs);
}

/** 读/写 arena 函数形参 sidecar 槽；create=1 时按需 grow。 */
static FuncParamEntry *arena_func_param_entry(struct ast_ASTArena *a, int32_t func_ref, int32_t pi, int create) {
  ArenaSidecar *sc;
  struct ast_Func *f;
  int32_t abs;
  if (!a || func_ref <= 0 || func_ref > a->num_funcs || pi < 0)
    return NULL;
  f = pipeline_arena_func_ptr(a, func_ref);
  if (!f)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  if (!sc)
    return NULL;
  if (!create) {
    if (pi >= f->num_params || f->param_base < 0)
      return NULL;
    abs = f->param_base + pi;
    if (abs < 0 || abs >= sc->func_params.len)
      return NULL;
    return (FuncParamEntry *)grow_vec_at(&sc->func_params, abs);
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
  return (FuncParamEntry *)grow_vec_at(&sc->func_params, abs);
}

/**
 * 读/写 struct_layout 字段 sidecar 槽；create=1 时按需 grow。
 *
 * field_base 语义：-1 = 尚未分配字段池起点；>=0 = 在 struct_layout_fields 中的绝对下标。
 * 禁止用 field_base==0 兼作「未初始化」——首个 layout 的合法 base 就是 0，
 * 否则后续 layout 会误把 field_base 留在 0 上，读写落到 Lexer 等同池前缀（lexer TIMEOUT 根因）。
 */
static StructLayoutFieldEntry *module_layout_field_entry(struct ast_Module *m, int32_t li, int32_t j, int create) {
  ModuleSidecar *sc;
  struct ast_StructLayout *sl;
  int32_t abs;
  if (!m || li < 0 || j < 0)
    return NULL;
  sl = module_layout_at(m, li);
  if (!sl)
    return NULL;
  sc = module_sidecar_get(m, create ? 1 : 0);
  if (!sc)
    return NULL;
  if (!create) {
    if (j >= sl->num_fields || sl->field_base < 0)
      return NULL;
    abs = sl->field_base + j;
    if (abs < 0 || abs >= sc->struct_layout_fields.len)
      return NULL;
    return (StructLayoutFieldEntry *)grow_vec_at(&sc->struct_layout_fields, abs);
  }
  if (sl->field_base < 0)
    sl->field_base = sc->struct_layout_fields.len;
  abs = sl->field_base + j;
  while (sc->struct_layout_fields.len <= abs) {
    if (grow_vec_push(&sc->struct_layout_fields) < 0)
      return NULL;
  }
  if (j + 1 > sl->num_fields)
    sl->num_fields = j + 1;
  return (StructLayoutFieldEntry *)grow_vec_at(&sc->struct_layout_fields, abs);
}

/** 新 Block 分配后记录各池 base 下标。 */
void ast_pool_block_on_alloc(struct ast_ASTArena *a, int32_t block_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  if (!a || block_ref <= 0)
    return;
  sc = arena_sidecar_get(a, 1);
  if (!sc)
    return;
  b = block_at(a, block_ref);
  if (!b)
    return;
  /* 新块槽可能复用旧内存；先整体清零，避免 num_lets/num_stmt_order 等继承脏值污染后续写盘。 */
  memset(b, 0, sizeof(*b));
  b->const_base = sc->consts.len;
  b->let_base = sc->lets.len;
  b->loop_base = sc->loops.len;
  b->for_loop_base = sc->for_loops.len;
  b->if_base = sc->ifs.len;
  b->region_base = sc->regions.len;
  b->defer_base = sc->defer_block_refs.len;
  b->labeled_base = sc->labeled_stmts.len;
  b->expr_stmt_base = sc->expr_stmt_refs.len;
  b->stmt_order_base = sc->stmt_order.len;
}

/**
 * 复用同一 Module* 再次 parse 前清空 sidecar 动态池。
 * runtime 在 memset(module) 后仍保留指针对应的 sidecar，须显式 reset，否则 num_funcs 与 funcs.len 不一致导致重复 main。
 */
void ast_pool_module_reset(struct ast_Module *m) {
  ModuleSidecar *sc;
  if (!m)
    return;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return;
  sc->funcs.len = 0;
  sc->func_refs.len = 0;
  sc->imports.len = 0;
  sc->struct_layouts.len = 0;
  sc->top_level_lets.len = 0;
  sc->type_aliases.len = 0;
  sc->module_enums.len = 0;
  sc->import_select_name_rows.len = 0;
  sc->import_select_name_lens.len = 0;
  sc->func_params.len = 0;
  sc->struct_layout_fields.len = 0;
  sc->struct_layout_type_params.len = 0;
  sc->struct_layout_type_param_meta.len = 0;
}

/**
 * 复用同一 ASTArena* 再次 parse 前清空 sidecar 动态池（与 ast_arena_init 计数清零配对）。
 */
void ast_pool_arena_reset(struct ast_ASTArena *a) {
  ArenaSidecar *sc;
  if (!a)
    return;
  sc = arena_sidecar_get(a, 0);
  if (!sc)
    return;
  sc->types.len = 0;
  sc->exprs.len = 0;
  sc->blocks.len = 0;
  sc->funcs.len = 0;
  sc->consts.len = 0;
  sc->lets.len = 0;
  sc->ifs.len = 0;
  sc->regions.len = 0;
  sc->loops.len = 0;
  sc->for_loops.len = 0;
  sc->defer_block_refs.len = 0;
  sc->labeled_stmts.len = 0;
  sc->expr_stmt_refs.len = 0;
  sc->stmt_order.len = 0;
  sc->expr_call_arg_refs.len = 0;
  sc->expr_call_type_arg_refs.len = 0;
  sc->expr_call_type_arg_bases.len = 0;
  sc->type_type_arg_refs.len = 0;
  sc->type_type_arg_bases.len = 0;
  sc->type_type_arg_counts.len = 0;
  sc->expr_method_call_arg_refs.len = 0;
  sc->expr_match_arms.len = 0;
  sc->expr_struct_lit_fields.len = 0;
  sc->expr_array_lit_elem_refs.len = 0;
  sc->func_params.len = 0;
}

/**
 * Release (free) all GrowVec data buffers associated with the given arena
 * and mark its ArenaSidecar slot as unused so it can be reused.
 *
 * Why: `free(arena)` only releases the 16-byte `struct ast_ASTArena`;
 * the 20 GrowVec data buffers (types/exprs/blocks/funcs/...) in the
 * ArenaSidecar slot are leaked. This API releases them.
 *
 * Invariant: caller MUST guarantee `a` is no longer accessed by
 * typeck/codegen/pipeline. Safe to call with NULL or untracked arena
 * (no-op if no ArenaSidecar slot matches).
 *
 * PLATFORM: SHARED — see `arena_sidecar_free`.
 */
void ast_pool_arena_release(struct ast_ASTArena *a) {
  int i;
  if (!a)
    return;
  for (i = 0; i < MAX_ARENA_SIDECARS; i++) {
    if (g_arena_sc[i].used && g_arena_sc[i].arena == a) {
      arena_sidecar_free(&g_arena_sc[i]);
      return;
    }
  }
}

/**
 * Release (free) all GrowVec data buffers associated with the given module
 * and mark its ModuleSidecar slot as unused so it can be reused.
 *
 * Why: `free(module)` only releases `sizeof(struct ast_Module)`; the 11
 * GrowVec data buffers (funcs/imports/struct_layouts/...) in the
 * ModuleSidecar slot are leaked. This API releases them.
 *
 * Invariant: caller MUST guarantee `m` is no longer accessed by
 * typeck/codegen/pipeline. Safe to call with NULL or untracked module.
 *
 * PLATFORM: SHARED — see `module_sidecar_free`.
 */
/* wave110 pure strong / Cap XLANG_WEAK empty cold — free pure ImportEntry map. */
void pipeline_module_import_storage_release(struct ast_Module *m);

void ast_pool_module_release(struct ast_Module *m) {
  int i;
  if (!m)
    return;
  /* wave110: pure ImportEntry map free (strong pure / weak empty cold). */
  pipeline_module_import_storage_release(m);
  for (i = 0; i < MAX_MODULE_SIDECARS; i++) {
    if (g_module_sc[i].used && g_module_sc[i].module == m) {
      module_sidecar_free(&g_module_sc[i]);
      return;
    }
  }
}

/**
 * Drop function-body AST pools after a dep parse, keeping signatures for typeck.
 *
 * Why (check peak RSS): `xlang check` of modules that import parser/typeck/codegen
 * (e.g. pipeline.x) holds full body ASTs of every transitive dep at once. Each
 * mega module alone is ~0.6–2GB because `struct ast_Expr` embeds four 128-byte
 * name arrays (~600B+/node). Directory `check compiler` peak matched single-file
 * pipeline.x (~4.9GB) — not multi-session leak (cleanup already frees deps).
 *
 * For check, deps are already parse_only (no library body typeck). Entry typeck
 * only needs dep export signatures: Func name/params/return + Type pool +
 * struct_layouts / imports / type_aliases. Body expr/block GrowVecs are pure
 * waste after parse_only and dominate RSS.
 *
 * What is kept:
 *   - ArenaSidecar: types, type_type_arg_*, func_params
 *   - ModuleSidecar: funcs (headers), imports, struct_layouts, type_aliases, enums
 * What is freed (body pools):
 *   - exprs, blocks, consts/lets/ifs/regions/loops, stmt_order, call/match/lit arg pools
 * Func body_ref / body_expr_ref are nulled so typeck treats them as body-less
 * (same as extern / empty library stubs).
 *
 * Invariant: call only after dep parse_only for check sessions; never on the
 * entry module while entry typeck still needs its own bodies.
 * PLATFORM: SHARED — mac + Ubuntu check RSS; dual L2 after change.
 */
void ast_pool_drop_bodies_for_check(struct ast_ASTArena *a, struct ast_Module *m) {
  ArenaSidecar *sc;
  int32_t i;
  int32_t n;
  size_t freed_approx = 0;
  int32_t n_expr = 0;
  int32_t n_block = 0;
  int32_t n_type = 0;

  if (m) {
    n = m->num_funcs;
    for (i = 0; i < n; i++) {
      struct ast_Func *f = module_func_at(m, i);
      if (!f)
        continue;
      f->body_ref = 0;
      f->body_expr_ref = 0;
    }
  }
  if (!a)
    return;
  sc = arena_sidecar_get(a, 0);
  if (!sc)
    return;
  n_expr = sc->exprs.len;
  n_block = sc->blocks.len;
  n_type = sc->types.len;
  freed_approx += (size_t)sc->exprs.cap * sc->exprs.elem_sz;
  freed_approx += (size_t)sc->blocks.cap * sc->blocks.elem_sz;
  freed_approx += (size_t)sc->consts.cap * sc->consts.elem_sz;
  freed_approx += (size_t)sc->lets.cap * sc->lets.elem_sz;
  freed_approx += (size_t)sc->ifs.cap * sc->ifs.elem_sz;
  freed_approx += (size_t)sc->regions.cap * sc->regions.elem_sz;
  freed_approx += (size_t)sc->loops.cap * sc->loops.elem_sz;
  freed_approx += (size_t)sc->for_loops.cap * sc->for_loops.elem_sz;
  freed_approx += (size_t)sc->stmt_order.cap * sc->stmt_order.elem_sz;
  freed_approx += (size_t)sc->expr_call_arg_refs.cap * sc->expr_call_arg_refs.elem_sz;
  freed_approx += (size_t)sc->expr_method_call_arg_refs.cap * sc->expr_method_call_arg_refs.elem_sz;
  freed_approx += (size_t)sc->expr_match_arms.cap * sc->expr_match_arms.elem_sz;
  freed_approx += (size_t)sc->expr_struct_lit_fields.cap * sc->expr_struct_lit_fields.elem_sz;
  /* Free body-associated GrowVec data; keep types + func_params. */
  grow_vec_free(&sc->exprs);
  grow_vec_free(&sc->blocks);
  grow_vec_free(&sc->consts);
  grow_vec_free(&sc->lets);
  grow_vec_free(&sc->ifs);
  grow_vec_free(&sc->regions);
  grow_vec_free(&sc->loops);
  grow_vec_free(&sc->for_loops);
  grow_vec_free(&sc->defer_block_refs);
  grow_vec_free(&sc->labeled_stmts);
  grow_vec_free(&sc->expr_stmt_refs);
  grow_vec_free(&sc->stmt_order);
  grow_vec_free(&sc->expr_call_arg_refs);
  grow_vec_free(&sc->expr_call_type_arg_refs);
  grow_vec_free(&sc->expr_call_type_arg_bases);
  grow_vec_free(&sc->expr_method_call_arg_refs);
  grow_vec_free(&sc->expr_match_arms);
  grow_vec_free(&sc->expr_struct_lit_fields);
  grow_vec_free(&sc->expr_array_lit_elem_refs);
  /* Arena-local func pool (if any) is not the module Func table; bodies live in
   * module funcs + expr/block pools. Keep sc->funcs / sc->func_params intact. */
  a->num_exprs = 0;
  a->num_blocks = 0;
  /*
   * PLATFORM: SHARED — return freed pages to the OS so directory/mega-import
   * check peak RSS is max(single dep) not sum(sequential parse peaks).
   * macOS keeps free'd large blocks in-process by default (high-water climbs);
   * Linux glibc similarly retains arenas without malloc_trim.
   * Ubuntu nostdlib: malloc_trim is weak no-op if not linked; large mmap free
   * already munmaps in bootstrap_nostdlib_stubs (wave1241).
   */
#if defined(__APPLE__)
  {
    extern void *malloc_default_zone(void);
    extern size_t malloc_zone_pressure_relief(void *zone, size_t goal);
    (void)malloc_zone_pressure_relief(malloc_default_zone(), 0);
  }
#elif defined(__linux__)
  {
    extern int malloc_trim(size_t pad) __attribute__((weak));
    if (malloc_trim)
      (void)malloc_trim(0);
  }
#endif
  if (link_abi_getenv("XLANG_DEBUG_CHECK_MEM")) {
    size_t live_expr_cap = 0;
    size_t live_type_cap = 0;
    int live_arenas = 0;
    int j;
    for (j = 0; j < MAX_ARENA_SIDECARS; j++) {
      if (!g_arena_sc[j].used)
        continue;
      live_arenas++;
      live_expr_cap += (size_t)g_arena_sc[j].exprs.cap * g_arena_sc[j].exprs.elem_sz;
      live_type_cap += (size_t)g_arena_sc[j].types.cap * g_arena_sc[j].types.elem_sz;
    }
    fprintf(stderr,
            "xlang: [CHECK_MEM] drop_bodies arena=%p n_expr=%d n_block=%d n_type=%d "
            "n_func=%d freed_body_approx=%zuMB | live_arenas=%d live_expr_cap=%zuMB "
            "live_type_cap=%zuMB\n",
            (void *)a, (int)n_expr, (int)n_block, (int)n_type,
            m ? (int)m->num_funcs : -1, freed_approx / (1024 * 1024), live_arenas,
            live_expr_cap / (1024 * 1024), live_type_cap / (1024 * 1024));
  }
}

void ast_pool_onefunc_reset(uint8_t *out) {
  OneFuncSidecar *sc;
  if (!out)
    return;
  sc = onefunc_sidecar_get(out, 0);
  if (!sc)
    return;
  sc->if_cond_refs.len = 0;
  sc->if_then_body_refs.len = 0;
  sc->if_else_body_refs.len = 0;
  sc->const_names.len = 0;
  sc->const_name_lens.len = 0;
  sc->const_init_vals.len = 0;
  sc->const_init_refs.len = 0;
  sc->const_type_refs.len = 0;
  sc->let_names.len = 0;
  sc->let_name_lens.len = 0;
  sc->let_init_vals.len = 0;
  sc->let_init_refs.len = 0;
  sc->let_type_refs.len = 0;
  sc->src_stmt_kind.len = 0;
  sc->src_stmt_idx.len = 0;
  sc->src_body_expr_stmt_refs.len = 0;
  sc->while_cond_refs.len = 0;
  sc->while_body_refs.len = 0;
  sc->for_init_refs.len = 0;
  sc->for_cond_refs.len = 0;
  sc->for_step_refs.len = 0;
  sc->for_body_refs.len = 0;
  sc->param_names.len = 0;
  sc->param_name_lens.len = 0;
  sc->param_type_refs.len = 0;
  sc->call_arg_vals.len = 0;
  sc->regions.len = 0;
  sc->defer_body_refs.len = 0;
  sc->labeleds.len = 0;
}

void ast_pool_onefunc_release(uint8_t *out) {
  int i;
  if (!out)
    return;
  for (i = 0; i < MAX_ONEFUNC_SIDECARS; i++) {
    if (g_onefunc_sc[i].used && g_onefunc_sc[i].onefunc == out) {
      onefunc_sidecar_free(&g_onefunc_sc[i]);
      return;
    }
  }
}


/** BC 8.3.2: Module Func cold accessors domain (same-TU thin). */
#include "ast_pool_module_func.c"


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


/** BC 8.3.2 wave988–990 + wave992: block domain thin (append/region/defer +
 * loop/labeled/getters + parent/resolve + stmt_order rebuild/fixup) — same-TU. */
#include "ast_pool_block.c"

/* BC 8.3.2 wave991: onefunc fill residual lives in ast_pool_onefunc.c (include later).
 * BC 8.3.2 wave993+994: name_is_const + hoist + asm hoist_target / sum stack live in
 * ast_pool_top_level.c (include below; after block so static prepend_lets is visible).
 * core residual: backend asm wrappers + fill_* decls / path helpers / module enum … */

/** ---------- Module import / struct_layout / top_level / enum 动态池 ---------- */

/** BC 8.3.2: module ImportEntry cold-twin accessors (same-TU thin). */
#include "ast_pool_module_import.c"

/** BC 8.3.2: module StructLayout cold accessors (same-TU thin). */
#include "ast_pool_struct_layout.c"

/** BC 8.3.2 wave980+993+994: TopLevelLetEntry + name_is_const/hoist + hoist_target/sum. */
#include "ast_pool_top_level.c"

/** BC 8.3.2: module TypeAliasEntry cold accessors (same-TU thin). */
#include "ast_pool_type_alias.c"

/** seed partial（build_seed_asm_host）导出的 mega 全量实现；勿与薄包装 backend_asm_codegen_ast 混调（会递归）。 */
extern int32_t backend_asm_codegen_ast_seed_mega(struct ast_Module *m, struct ast_ASTArena *a,
                                                 struct codegen_CodegenOutBuf *out,
                                                 struct ast_PipelineDepCtx *pipeline_ctx);
extern int32_t backend_asm_codegen_ast_to_elf_seed_mega(struct ast_Module *m, struct ast_ASTArena *a,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                        struct ast_PipelineDepCtx *pipeline_ctx);
extern void pipeline_asm_emit_set_elf_ctx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern void pipeline_asm_emit_set_dep_pipe(struct ast_PipelineDepCtx *ctx);
extern void pipeline_asm_emit_set_module(struct ast_Module *m);
extern void pipeline_asm_emit_set_arena(struct ast_ASTArena *arena);

/**
 * M8-tail：`asm_codegen_ast` 薄包装 C 委托；顶层 let hoist 后调 seed partial mega。
 */
int32_t pipeline_backend_asm_codegen_ast_c(struct ast_Module *m, struct ast_ASTArena *a,
                                            struct codegen_CodegenOutBuf *out,
                                            struct ast_PipelineDepCtx *pipeline_ctx) {
  if (!m || !a || !out || !pipeline_ctx)
    return -1;
  if (m->num_top_level_lets > 0)
    pipeline_module_hoist_top_level_lets_into_main(m, a);
  return backend_asm_codegen_ast_seed_mega(m, a, out, pipeline_ctx);
}

/** skip .x typeck 时 dep/entry 各模块 emit 前补 ARRAY_LIT / SoA 字段类型（定义见 pipeline_glue.c 后部）。 */
void pipeline_fill_array_lit_types_for_skipped_typeck(struct ast_Module *m, struct ast_ASTArena *arena);
void pipeline_fill_soa_field_access_for_asm_emit(struct ast_Module *m, struct ast_ASTArena *arena);
extern void pipeline_debug_trace_named_func_bodies(const char *phase, void *module, void *arena);
extern void typeck_typeck_merge_dep_struct_layouts_into_entry(struct ast_Module *mod, struct ast_ASTArena *arena,
                                                              struct ast_PipelineDepCtx *ctx);
extern void typeck_typeck_wpo_unify_soa_layouts(struct ast_Module *entry, struct ast_PipelineDepCtx *ctx);

/** EMIT_HEAVY parser 模块判定（定义见本文件后部 static 实现）。 */
static int32_t asm_module_is_parser_emit_heavy(struct ast_Module *m);

/**
 * M8-tail：`asm_codegen_ast_to_elf` 薄包装 C 委托；顶层 let hoist 后调 seed partial mega。
 */
int32_t pipeline_backend_asm_codegen_ast_to_elf_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   struct ast_PipelineDepCtx *pipeline_ctx) {
  int32_t rc;
  if (!m || !a || !elf_ctx || !pipeline_ctx)
    return -1;
  pipeline_debug_trace_named_func_bodies("backend_pre_hoist_top_level_lets", m, a);
  if (m->num_top_level_lets > 0)
    pipeline_module_hoist_top_level_lets_into_main(m, a);
  pipeline_debug_trace_named_func_bodies("backend_post_hoist_top_level_lets", m, a);
  /** DOD-S3：skip .x typeck 时仍须 dep SoA layout 并入 entry + 全图升档，再 fill stride。 */
  pipeline_debug_trace_named_func_bodies("backend_pre_merge_dep_layouts", m, a);
  typeck_typeck_merge_dep_struct_layouts_into_entry(m, a, pipeline_ctx);
  pipeline_debug_trace_named_func_bodies("backend_post_merge_dep_layouts", m, a);
  typeck_typeck_wpo_unify_soa_layouts(m, pipeline_ctx);
  pipeline_debug_trace_named_func_bodies("backend_post_unify_soa_layouts", m, a);
  /** dep co-emit 与 entry 均须 SoA stride / 形参类型 / FIELD_ACCESS 偏移，否则跨模块 call 链 SIGSEGV。 */
  pipeline_asm_emit_set_dep_pipe(pipeline_ctx);
  pipeline_fill_array_lit_types_for_skipped_typeck(m, a);
  pipeline_fill_soa_field_access_for_asm_emit(m, a);
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    fprintf(stderr, "xlang: backend_asm_codegen fill done, calling mega_body_c\n");
  glue_wpo_mono_reset_pending();
  /** dep+entry 顺序写入同一 elf_ctx：为 tail_join/loop 等局部标签分配唯一 scope。 */
  pipeline_elf_label_mod_scope_begin_module();
  /** WPO-S3：import struct FIELD_ACCESS 查 layout 时须可见 dep 池（backend.x mega 亦会设置）。 */
  pipeline_asm_emit_set_module(m);
  pipeline_asm_emit_set_arena(a);
  pipeline_asm_emit_set_elf_ctx(elf_ctx);
  if (link_abi_getenv("XLANG_ASM_DEBUG") && m && asm_module_is_parser_emit_heavy(m))
    fprintf(stderr, "xlang: seed_mega parser nfunc=%d elf_ctx=%p code_len=%d\n", (int)m->num_funcs, (void *)elf_ctx,
            elf_ctx ? (int)elf_ctx->code_len : -1);
  rc = pipeline_backend_asm_codegen_ast_to_elf_mega_body_c(m, a, elf_ctx, pipeline_ctx);
  pipeline_asm_emit_set_elf_ctx(NULL);
  if (rc != 0)
    return rc;
  return pipeline_asm_emit_wpo_mono_thunks_elf_c(m, a, elf_ctx, pipeline_ctx);
}

#include "ast_pool_module_enum.c"



/** BC 8.3.2: OneFunc sidecar + fill_from_onefunc domain (wave984+991 same-TU thin). */
#include "ast_pool_onefunc.c"
/** BC 8.3.2: expr (+ type-pos) var-len sidecar domain (same-TU thin). */
#include "ast_pool_expr_sidecar.c"

/** BC 8.3.2: PipelineDepCtx cold accessors domain (same-TU thin). */
#include "ast_pool_dep_ctx.c"


#include "pipeline_resolve_path.c"

/** read_file_x X emit：单点 fs read + loaded_len（前向声明，供 read_file_x / impl_c 调用）。 */
int32_t pipeline_read_fd_into_loaded_buf(struct ast_PipelineDepCtx *ctx, int32_t fd);

/**
 * M8-tail strict 回退：`read_file_x` 读 ctx.path_buf 文件到 ctx.loaded_buf（B-20 POSIX，非 fopen）。
 * wave95: product pure owns pipeline_read_file_x; this impl remains cold twin target.
 * PLATFORM: SHARED.
 */
int32_t pipeline_read_file_x_impl_c(struct ast_PipelineDepCtx *ctx) {
  int32_t n;

  if (!ctx)
    return -1;
  n = xlang_read_file_into_path((const char *)pipeline_dep_ctx_path_buf_ptr(ctx),
                               pipeline_dep_ctx_loaded_buf_ptr(ctx),
                               (size_t)PIPELINE_SOURCE_BUF_CAP);
  if (n < 0)
    return -1;
  pipeline_dep_ctx_set_loaded_len(ctx, (ptrdiff_t)n);
  return 0;
}

/** M8-tail：优先 dispatch 至 pipeline_read_file_x（X 或 weak impl_c）。 */
int32_t pipeline_read_file_x_c(struct ast_PipelineDepCtx *ctx) {
  return pipeline_read_file_x(ctx);
}

/**
 * read_file_x X emit：单点 fs read + loaded_len 写入（避免 X 侧 fs_posix_read_c 嵌套 ptr 实参 SIGSEGV）。
 */
int32_t pipeline_read_fd_into_loaded_buf(struct ast_PipelineDepCtx *ctx, int32_t fd) {
  ptrdiff_t n;

  if (!ctx || fd < 0)
    return -1;
  n = std_fs_fs_read(fd, pipeline_dep_ctx_loaded_buf_ptr(ctx), (size_t)PIPELINE_SOURCE_BUF_CAP);
  if (n < 0)
    return -1;
  pipeline_dep_ctx_set_loaded_len(ctx, n);
  return 0;
}

extern int32_t preprocess_x_buf(uint8_t *source_buf, ptrdiff_t source_len, uint8_t *out_buf,
                                              int32_t out_cap);
extern uint8_t *driver_dep_arena_buf(int32_t i);
extern uint8_t *driver_dep_module_buf(int32_t i);
extern int32_t driver_dep_seeded_get(int32_t i);
extern const char *driver_dep_path_registry_at(int32_t i);
extern int32_t driver_dep_slot_for_path(uint8_t *path);
extern int32_t parser_copy_module_import_path64(struct ast_Module *module, int32_t i, uint8_t out[128]);

/** pipeline_load_import_from_disk X emit：读 ctx.preprocess_len（避免 FIELD_ACCESS emit 失败）。 */
int32_t pipeline_dep_ctx_preprocess_len_get(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->preprocess_len : -1;
}

/**
 * loaded_buf → preprocess_buf；成功返回 0，preprocess 失败返回 -9。
 * wave95: product pure owns pipeline_preprocess_loaded_into_ctx (runtime_pipeline_abi.x).
 * Keep XLANG_WEAK cold twin for links without pure pipeline_abi / PREFER hybrid.
 * PLATFORM: SHARED — ELF weak overridden by pure.
 */
XLANG_WEAK int32_t pipeline_preprocess_loaded_into_ctx(struct ast_PipelineDepCtx *ctx) {
  int32_t out_len;

  if (!ctx)
    return -1;
  out_len = preprocess_x_buf(pipeline_dep_ctx_loaded_buf_ptr(ctx), ctx->loaded_len,
                                         pipeline_dep_ctx_preprocess_buf_ptr(ctx), PIPELINE_SOURCE_BUF_CAP);
  if (out_len < 0)
    return -9;
  ctx->preprocess_len = out_len;
  return 0;
}

/**
 * import 槽绑定 driver dep arena/module 缓冲（指针 cast 须 C glue）。
 * wave94: product pure owns pipeline_bind_import_dep_buffers (runtime_pipeline_abi.x).
 * Keep XLANG_WEAK cold twin for links without pure pipeline_abi / PREFER hybrid.
 * PLATFORM: SHARED — ELF weak overridden by pure.
 */
XLANG_WEAK void pipeline_bind_import_dep_buffers(struct ast_PipelineDepCtx *ctx, int32_t import_idx) {
  if (!ctx || import_idx < 0)
    return;
  pipeline_dep_ctx_set_arena(ctx, import_idx, (struct ast_ASTArena *)driver_dep_arena_buf(import_idx));
  pipeline_dep_ctx_set_module(ctx, import_idx, (struct ast_Module *)driver_dep_module_buf(import_idx));
}

/**
 * 若 global_slot 或 import_idx 已由 driver seed，绑定 arena/module 槽并返回 1；未 seed 返回 0。
 * C glue：X 侧 (struct ast_ASTArena *)driver_dep_arena_buf 指针 cast 在 M8 asm 真 emit 时易 SIGSEGV。
 * wave93: product pure owns pipeline_try_bind_seeded_import (runtime_pipeline_abi.x).
 * Keep XLANG_WEAK cold twin for links without pure pipeline_abi / PREFER hybrid.
 * PLATFORM: SHARED — ELF weak overridden by pure.
 */
XLANG_WEAK int32_t pipeline_try_bind_seeded_import(struct ast_PipelineDepCtx *ctx, int32_t import_idx, int32_t global_slot) {
  if (!ctx || import_idx < 0)
    return 0;
  if (global_slot >= 0 && driver_dep_seeded_get(global_slot) != 0) {
    pipeline_dep_ctx_set_arena(ctx, import_idx, (struct ast_ASTArena *)driver_dep_arena_buf(global_slot));
    pipeline_dep_ctx_set_module(ctx, import_idx, (struct ast_Module *)driver_dep_module_buf(global_slot));
    return 1;
  }
  if (driver_dep_seeded_get(import_idx) != 0) {
    pipeline_dep_ctx_set_arena(ctx, import_idx, (struct ast_ASTArena *)driver_dep_arena_buf(import_idx));
    pipeline_dep_ctx_set_module(ctx, import_idx, (struct ast_Module *)driver_dep_module_buf(import_idx));
    return 1;
  }
  return 0;
}

/**
 * 将 dep_i 槽与 driver 全局 seed 槽对齐；C glue 单点指针 cast。
 * wave94: product pure owns pipeline_sync_one_dep_slot (runtime_pipeline_abi.x).
 * Keep XLANG_WEAK cold twin for links without pure pipeline_abi / PREFER hybrid.
 * PLATFORM: SHARED — ELF weak overridden by pure.
 */
XLANG_WEAK int32_t pipeline_sync_one_dep_slot(struct ast_Module *module, struct ast_PipelineDepCtx *ctx, int32_t dep_i) {
  uint8_t sync_path[128];
  int32_t sync_slot;

  if (!module || !ctx || dep_i < 0)
    return -1;
  (void)parser_copy_module_import_path64(module, dep_i, sync_path);
  sync_slot = driver_dep_slot_for_path(sync_path);
  if (sync_slot < 0)
    sync_slot = dep_i;
  {
    int32_t pl = 0;
    while (pl < 64 && sync_path[pl] != 0)
      pl = pl + 1;
    if (pl > 0)
      pipeline_dep_ctx_set_import_path(ctx, dep_i, sync_path, pl);
  }
  pipeline_dep_ctx_set_module(ctx, dep_i, (struct ast_Module *)driver_dep_module_buf(sync_slot));
  pipeline_dep_ctx_set_arena(ctx, dep_i, (struct ast_ASTArena *)driver_dep_arena_buf(sync_slot));
  return 0;
}

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

/**
 * run_x_pipeline_impl EMIT_HEAVY：typecheck entry 同模块 CALL asm emit 失败时走 C glue。
 */
int32_t run_x_pipeline_typecheck_entry_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                          struct ast_PipelineDepCtx *ctx) {
  if (!module || !arena || !ctx)
    return -1;
  if (pipeline_should_skip_x_typeck(ctx) != 0)
    return 0;
  return pipeline_typeck_entry_module_c(module, arena, ctx);
}

/**
 * run_x_pipeline_impl EMIT_HEAVY：if(CALL) 路径可 emit，let init CALL 会 tear patch；
 * 最近一次 phase C glue 返回值供 `return run_x_pipeline_last_rc_get()` 使用（避免重复 call）。
 */
static int32_t g_run_x_pipeline_last_rc;

/**
 * typeck 失败统一返回；C glue（X 内 fail_mapped 分支重复 emit 失败）。
 */
int32_t pipeline_typeck_fail_return_c(int32_t fail_mapped) {
  driver_diagnostic_typeck_fail();
  if (fail_mapped != 0)
    return fail_mapped;
  return -1;
}

/**
 * typeck 入口 null 检查失败返回；C glue（与 pipeline_typeck_parsed_module 语义一致）。
 */
int32_t pipeline_typeck_null_fail_return_c(int32_t fail_mapped) {
  if (fail_mapped != 0)
    return fail_mapped;
  return -1;
}

int32_t run_x_pipeline_last_rc_get(void) {
  return g_run_x_pipeline_last_rc;
}

/**
 * EMIT_HEAVY X 编排：写入 last_rc sidecar（避免 let rc=CALL assign tear patch）。
 */
void run_x_pipeline_last_rc_store_c(int32_t rc) {
  g_run_x_pipeline_last_rc = rc;
}

int32_t run_x_pipeline_load_deps_after_parse_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                struct ast_PipelineDepCtx *ctx) {
  g_run_x_pipeline_last_rc = pipeline_load_and_sync_direct_import_deps_c(module, arena, ctx);
  return g_run_x_pipeline_last_rc;
}

int32_t run_x_pipeline_typecheck_after_load_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                               struct ast_PipelineDepCtx *ctx) {
  g_run_x_pipeline_last_rc = run_x_pipeline_typecheck_entry_c(module, arena, ctx);
  return g_run_x_pipeline_last_rc;
}

/** LSP：load/sync + typeck（typeck 失败 -3）；C glue。 */
int32_t lsp_diag_typeck_after_load_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                     struct ast_PipelineDepCtx *ctx) {
  int32_t load_rc;

  if (!module || !arena || !ctx)
    return -1;
  load_rc = pipeline_load_and_sync_direct_import_deps_c(module, arena, ctx);
  if (load_rc != 0)
    return load_rc;
  return pipeline_typeck_parsed_module_c(module, arena, ctx, -3);
}

/** LSP entry parse：与 pipeline_parse_set_main_from_buf 同路径 C glue。 */
int32_t lsp_diag_parse_entry_buf_c(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                   int32_t source_len) {
  return pipeline_parse_set_main_from_buf_c(module, arena, source_data, source_len);
}

/** C glue 经 pipeline_typeck_parsed_module_c 复用 typeck 分派。 */
extern int32_t pipeline_load_and_sync_direct_import_deps(struct ast_Module *module, struct ast_ASTArena *arena,
                                                         struct ast_PipelineDepCtx *ctx);

/**
 * LSP 全路径 C glue：set_main_c + load/sync + pipeline_typeck_parsed_module_c（typeck 失败 -3）。
 * typeck 深栈：在 256MiB pthread 上执行，避免 Alpine/ARM64 默认栈在 diag 时 SIGSEGV。
 */
extern void driver_run_on_large_stack_pthread(void *(*fn)(void *), void *arg);
extern int driver_is_large_stack_thread(void);

typedef struct LspDiagParseTypeckArgs {
  struct ast_Module *module;
  struct ast_ASTArena *arena;
  uint8_t *source_data;
  int32_t source_len;
  struct ast_PipelineDepCtx *ctx;
  int32_t result;
} LspDiagParseTypeckArgs;

static int32_t lsp_diag_parse_typeck_buf_impl(struct ast_Module *module, struct ast_ASTArena *arena,
                                            uint8_t *source_data, int32_t source_len,
                                            struct ast_PipelineDepCtx *ctx) {
  int32_t parse_rc;
  int32_t load_rc;

  if (!module || !arena || !ctx || !source_data || source_len <= 0)
    return -2;
  parse_rc = pipeline_parse_set_main_from_buf_c(module, arena, source_data, source_len);
  if (parse_rc != 0)
    return parse_rc;
  load_rc = pipeline_load_and_sync_direct_import_deps(module, arena, ctx);
  if (load_rc != 0)
    return load_rc;
  return pipeline_typeck_parsed_module_c(module, arena, ctx, 0 - 3);
}

static void *lsp_diag_parse_typeck_thread_fn(void *arg) {
  LspDiagParseTypeckArgs *a = (LspDiagParseTypeckArgs *)arg;
  a->result = lsp_diag_parse_typeck_buf_impl(a->module, a->arena, a->source_data, a->source_len, a->ctx);
  return NULL;
}

int32_t lsp_diag_parse_typeck_buf_c(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                    int32_t source_len, struct ast_PipelineDepCtx *ctx) {
  /* LSP 主循环已在 256MiB pthread 内：直接 typeck，避免嵌套大栈分配在 Alpine 上 OOM/SIGSEGV。 */
  if (driver_is_large_stack_thread())
    return lsp_diag_parse_typeck_buf_impl(module, arena, source_data, source_len, ctx);
  LspDiagParseTypeckArgs args;
  args.module = module;
  args.arena = arena;
  args.source_data = source_data;
  args.source_len = source_len;
  args.ctx = ctx;
  args.result = -99;
  driver_run_on_large_stack_pthread(lsp_diag_parse_typeck_thread_fn, &args);
  if (args.result == -99)
    return lsp_diag_parse_typeck_buf_impl(module, arena, source_data, source_len, ctx);
  return args.result;
}

/**
 * entry 尚未解析：parse_into_with_init_buf + set_main + 收尾诊断；C glue（scalars 路径）。
 */
int32_t run_x_pipeline_parse_entry_do_parse_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                              uint8_t *source_data, size_t source_len,
                                              struct ast_PipelineDepCtx *ctx) {
  int32_t len_i32 = (int32_t)source_len;
  int32_t parse_rc;

  if (!module || !arena || !ctx)
    return -1;
  driver_diagnostic_source_len(len_i32);
  parse_rc = pipeline_parse_set_main_from_buf_c(module, arena, source_data, len_i32);
  if (parse_rc != 0)
    return parse_rc;
  driver_diagnostic_after_entry_parse(pipeline_module_num_funcs(module));
  extern void driver_diagnostic_after_entry_parse_module(struct ast_Module *module);
  driver_diagnostic_after_entry_parse_module(module);
  driver_diagnostic_entry_module(module, arena);
  return 0;
}

/**
 * entry typeck emit；C glue（skip 判定 + typeck 深栈 + module 字段读）。
 */
extern int32_t pipeline_typeck_dep_prerun_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                 struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_entry_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                            struct ast_PipelineDepCtx *ctx);
extern int32_t parser_get_module_num_imports(struct ast_Module *module);
int32_t run_x_pipeline_typecheck_entry_emit_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                               struct ast_PipelineDepCtx *ctx) {
  if (!module || !arena || !ctx)
    return -1;
  if (link_abi_getenv("XLANG_DEBUG_PIPE")) {
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] typecheck_entry_emit ctx=%p ndep=%d num_funcs=%d\n", (void *)ctx,
            (int)pipeline_dep_ctx_ndep(ctx), (int)pipeline_module_num_funcs(module));
    fflush(stderr);
  }
  /** 优先读 runtime 全局标志（C 预检后 set）；勿仅依赖 X pipeline_should_skip_x_typeck（strict 链 thin bl 偶发失效）。 */
    if (driver_x_pipeline_skip_typeck_get() != 0) {
    /*
     * 用户 asm -o 单文件：runtime 仍设 skip_typeck，但须全量 typeck 填 field_access_offset；
     * build_xlang_asm（XLANG_ASM_BUILD_SKIP_TYPECK）多文件 import 入口仅 dep_prerun；
     * 用户 -o 有 import 时仍须全量 typeck（ERR-01 负例 result_try_bad 等）。
     */
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

extern void driver_diagnostic_codegen_fail(int32_t dep_index, int32_t is_dep);
extern int32_t asm_asm_codegen_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                   struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx);
extern int32_t codegen_codegen_x_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                      struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx,
                                      int32_t dep_index);
int32_t pipeline_codegen_dep_skip_x_bootstrap_partial(uint8_t *path);
int32_t pipeline_codegen_std_dep_link_only(uint8_t *path);
int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena *a, int32_t br);

static int pipeline_debug_name_eq_buf_lit(const uint8_t *buf, int32_t len, const char *lit) {
  size_t lit_len;
  if (!buf || !lit || len <= 0)
    return 0;
  lit_len = strlen(lit);
  return (int32_t)lit_len == len && memcmp(buf, lit, lit_len) == 0;
}

static void pipeline_debug_dump_std_heap_trace_call(struct ast_Module *dep_mod, struct ast_ASTArena *arena,
                                                    struct ast_PipelineDepCtx *ctx, int32_t dep_j,
                                                    uint8_t *dep_path_buf) {
  int32_t n_imp, j, expr_ref;
  if (!dep_mod || !arena || !ctx || !dep_path_buf)
    return;
  if (!link_abi_getenv("XLANG_DEBUG_PIPE"))
    return;
  if (strcmp((const char *)dep_path_buf, "std.heap") != 0)
    return;
  n_imp = parser_get_module_num_imports(dep_mod);
  fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] std.heap probe dep_j=%d imports=%d ctx_ndep=%d arena_exprs=%d\n",
          (int)dep_j, (int)n_imp, (int)pipeline_dep_ctx_ndep(ctx), (int)arena->num_exprs);
  for (j = 0; j < pipeline_dep_ctx_ndep(ctx); j++) {
    uint8_t ctx_path_buf[128];
    int32_t ctx_path_len = pipeline_dep_ctx_import_path_len(ctx, j);
    struct ast_Module *ctx_mod = pipeline_dep_ctx_module_at(ctx, j);
    memset(ctx_path_buf, 0, sizeof(ctx_path_buf));
    if (ctx_path_len > 0)
      pipeline_dep_ctx_import_path_copy64(ctx, j, ctx_path_buf);
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] std.heap ctx dep[%d] path=%.*s funcs=%d mod=%p\n", (int)j,
            (int)ctx_path_len, (char *)ctx_path_buf, ctx_mod ? (int)pipeline_module_num_funcs(ctx_mod) : -1,
            (void *)ctx_mod);
  }
  for (j = 0; j < n_imp; j++) {
    uint8_t path_buf[128];
    uint8_t bind_buf[128];
    int32_t path_len = pipeline_module_import_path_len(dep_mod, j);
    int32_t bind_len = pipeline_module_import_binding_name_len(dep_mod, j);
    int32_t k;
    memset(path_buf, 0, sizeof(path_buf));
    memset(bind_buf, 0, sizeof(bind_buf));
    pipeline_module_import_path_copy(dep_mod, j, path_buf, (int32_t)sizeof(path_buf));
    for (k = 0; k < bind_len && k < (int32_t)sizeof(bind_buf) - 1; k++)
      bind_buf[k] = pipeline_module_import_binding_name_byte_at(dep_mod, j, k);
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] std.heap import idx=%d kind=%d path=%.*s bind=%.*s\n", (int)j,
            (int)pipeline_module_import_kind_at(dep_mod, j), (int)path_len, (char *)path_buf, (int)bind_len,
            (char *)bind_buf);
  }
  for (j = 0; j < pipeline_module_num_funcs(dep_mod); j++) {
    uint8_t fn_buf[128];
    int32_t fn_len = pipeline_module_func_name_len_at(dep_mod, j);
    int32_t body_ref;
    int32_t nso;
    int32_t si;
    memset(fn_buf, 0, sizeof(fn_buf));
    if (fn_len <= 0 || fn_len > 127)
      continue;
    pipeline_module_func_name_copy64(dep_mod, j, fn_buf);
    if (!pipeline_debug_name_eq_buf_lit(fn_buf, fn_len, "trace_on"))
      continue;
    body_ref = pipeline_module_func_body_ref_at(dep_mod, j);
    nso = body_ref > 0 ? ast_ast_block_num_stmt_order(arena, body_ref) : -1;
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] std.heap func fi=%d name=%.*s body_ref=%d nso=%d fin=%d\n", (int)j,
            (int)fn_len, (char *)fn_buf, (int)body_ref, (int)nso,
            body_ref > 0 ? (int)ast_ast_block_final_expr_ref(arena, body_ref) : -1);
    for (si = 0; body_ref > 0 && si < nso; si++) {
      int32_t so_idx = pipeline_block_stmt_order_idx(arena, body_ref, si);
      int32_t expr_stmt_ref = pipeline_block_expr_stmt_ref(arena, body_ref, so_idx);
      struct ast_Expr *expr_stmt = expr_stmt_ref > 0 ? pipeline_arena_expr_ptr(arena, expr_stmt_ref) : NULL;
      fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] std.heap func stmt si=%d kind=%u idx=%d\n", (int)si,
              (unsigned)pipeline_block_stmt_order_kind(arena, body_ref, si),
              (int)so_idx);
      fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] std.heap func expr_stmt si=%d expr_ref=%d expr_kind=%d\n", (int)si,
              (int)expr_stmt_ref, expr_stmt ? (int)expr_stmt->kind : -1);
      if (expr_stmt && expr_stmt->unary_operand_ref > 0) {
        struct ast_Expr *ret_op = pipeline_arena_expr_ptr(arena, expr_stmt->unary_operand_ref);
        fprintf(stderr,
                "xlang: [XLANG_DEBUG_PIPE] std.heap func return_op si=%d op_ref=%d op_kind=%d callee=%d base=%d name_len=%d var=%.*s field=%.*s\n",
                (int)si, (int)expr_stmt->unary_operand_ref, ret_op ? (int)ret_op->kind : -1,
                ret_op ? (int)ret_op->call_callee_ref : -1, ret_op ? (int)ret_op->field_access_base_ref : -1,
                ret_op ? (int)ret_op->var_name_len : -1, ret_op ? (int)ret_op->var_name_len : 0,
                ret_op ? (const char *)ret_op->var_name : "",
                ret_op ? (int)ret_op->field_access_field_len : 0,
                ret_op ? (const char *)ret_op->field_access_field_name : "");
      }
    }
  }
  for (expr_ref = 1; expr_ref <= arena->num_exprs; expr_ref++) {
    struct ast_Expr *call_ex = pipeline_arena_expr_ptr(arena, expr_ref);
    struct ast_Expr *callee_ex;
    struct ast_Expr *base_ex;
    int32_t dep_ix;
    int32_t func_ix;
    uint8_t dep_resolved_path[128];
    if (!call_ex || call_ex->kind != ast_ExprKind_EXPR_CALL || call_ex->call_callee_ref <= 0)
      continue;
    callee_ex = pipeline_arena_expr_ptr(arena, call_ex->call_callee_ref);
    if (!callee_ex || callee_ex->kind != ast_ExprKind_EXPR_FIELD_ACCESS || callee_ex->field_access_base_ref <= 0)
      continue;
    base_ex = pipeline_arena_expr_ptr(arena, callee_ex->field_access_base_ref);
    if (!base_ex || base_ex->kind != ast_ExprKind_EXPR_VAR)
      continue;
    if (!pipeline_debug_name_eq_buf_lit(base_ex->var_name, base_ex->var_name_len, "heap_libc"))
      continue;
    if (!pipeline_debug_name_eq_buf_lit(callee_ex->field_access_field_name, callee_ex->field_access_field_len,
                                        "heap_trace_enabled_c"))
      continue;
    dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
    func_ix = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
    memset(dep_resolved_path, 0, sizeof(dep_resolved_path));
    if (dep_ix >= 0 && dep_ix < pipeline_dep_ctx_ndep(ctx))
      pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, dep_resolved_path);
    fprintf(stderr,
            "xlang: [XLANG_DEBUG_PIPE] std.heap trace_on call expr=%d callee=%d dep_ix=%d func_ix=%d global_dep=%s\n",
            (int)expr_ref, (int)call_ex->call_callee_ref, (int)dep_ix, (int)func_ix,
            dep_ix >= 0 ? (char *)dep_resolved_path : "<none>");
  }
  for (expr_ref = 1; expr_ref <= arena->num_exprs; expr_ref++) {
    struct ast_Expr *ex = pipeline_arena_expr_ptr(arena, expr_ref);
    int hit = 0;
    if (!ex)
      continue;
    if (ex->kind == ast_ExprKind_EXPR_VAR &&
        pipeline_debug_name_eq_buf_lit(ex->var_name, ex->var_name_len, "heap_libc"))
      hit = 1;
    if (ex->kind == ast_ExprKind_EXPR_FIELD_ACCESS &&
        pipeline_debug_name_eq_buf_lit(ex->field_access_field_name, ex->field_access_field_len, "heap_trace_enabled_c"))
      hit = 1;
    if (!hit)
      continue;
    fprintf(stderr,
            "xlang: [XLANG_DEBUG_PIPE] std.heap expr expr=%d kind=%d callee=%d base=%d name_len=%d var=%.*s field=%.*s dep_ix=%d func_ix=%d\n",
            (int)expr_ref, (int)ex->kind, (int)ex->call_callee_ref, (int)ex->field_access_base_ref,
            (int)ex->var_name_len, (int)ex->var_name_len, (const char *)ex->var_name, (int)ex->field_access_field_len,
            (const char *)ex->field_access_field_name, (int)ex->call_resolved_dep_index,
            (int)ex->call_resolved_func_index);
  }
}

static int32_t pipeline_dep_ctx_has_earlier_same_import_path_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j);

/**
 * 对单个 dep 执行 asm/C codegen；C glue（dep_mod->num_funcs 读 + asm 深栈 emit 仍须 C）。
 */
int32_t run_x_pipeline_codegen_one_dep_emit(struct ast_Module *dep_mod, struct codegen_CodegenOutBuf *out_buf,
                                             struct ast_PipelineDepCtx *ctx, int32_t dep_j, int32_t skip_asm_dep_codegen,
                                             int32_t use_asm_backend) {
  uint8_t dep_path_buf[128];

  if (!out_buf || !ctx || dep_j < 0)
    return -1;
  if (pipeline_dep_ctx_has_earlier_same_import_path_c(ctx, dep_j) != 0) {
    if (link_abi_getenv("XLANG_DEBUG_PIPE")) {
      memset(dep_path_buf, 0, sizeof(dep_path_buf));
      pipeline_dep_ctx_import_path_copy64(ctx, dep_j, dep_path_buf);
      fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] skip duplicate dep emit j=%d path=%s\n", (int)dep_j,
              (char *)dep_path_buf);
    }
    return 0;
  }
  memset(dep_path_buf, 0, sizeof(dep_path_buf));
  pipeline_dep_ctx_import_path_copy64(ctx, dep_j, dep_path_buf);
  /*
   * wave578 Cap residual (Ubuntu L2): product path is
   * pipeline_run_x_pipeline_codegen_one_dep → emit(module_at(...)), not the _c
   * wrapper. After name[64]→[128], DepCtx sidecar module_at can be NULL while
   * driver_dep_module_buf still holds the pre-parsed dep (num_funcs>0). Rebind
   * here so both seed weak one_dep and C one_dep_c paths share one authority.
   * PLATFORM: SHARED — mac L2 often hit sidecar; Ubuntu gold exposed NULL.
   */
  if (!dep_mod) {
    int32_t sync_slot = driver_dep_slot_for_path(dep_path_buf);
    if (sync_slot < 0)
      sync_slot = dep_j;
    dep_mod = (struct ast_Module *)driver_dep_module_buf(sync_slot);
    if (dep_mod) {
      pipeline_dep_ctx_set_module(ctx, dep_j, dep_mod);
      pipeline_dep_ctx_set_arena(ctx, dep_j, (struct ast_ASTArena *)driver_dep_arena_buf(sync_slot));
      if (link_abi_getenv("XLANG_DEBUG_PIPE"))
        fprintf(stderr,
                "xlang: [XLANG_DEBUG_PIPE] rebind dep emit j=%d path=%s slot=%d funcs=%d\n",
                (int)dep_j, (char *)dep_path_buf, (int)sync_slot,
                (int)pipeline_module_num_funcs(dep_mod));
    }
  }
  if (link_abi_getenv("XLANG_DEBUG_PIPE"))
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] dep emit j=%d path=%s use_asm=%d funcs=%d\n", (int)dep_j,
            (char *)dep_path_buf, (int)use_asm_backend,
            dep_mod ? (int)pipeline_module_num_funcs(dep_mod) : -1);
  pipeline_debug_dump_std_heap_trace_call(dep_mod, pipeline_dep_ctx_arena_at(ctx, dep_j), ctx, dep_j, dep_path_buf);
  if (pipeline_codegen_dep_skip_x_bootstrap_partial(dep_path_buf) != 0) {
    if (link_abi_getenv("XLANG_DEBUG_PIPE"))
      fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] skip dep emit j=%d path=%s\n", (int)dep_j, (char *)dep_path_buf);
    return 0;
  }
  /** 产品轨：std 模块有预编 *.o 时勿 co-emit（.o 权威）。
   * 【Why】co-emit wrapper（std_json_* 调 json_*_c）+ 链 json.o → 双权威 duplicate；
   *   仅 co-emit 则缺 _c 桩。base64/csv/heap/http 同形。core.mem 仍 co-emit（mem 测自洽）。 */
  if (pipeline_codegen_std_dep_link_only(dep_path_buf) != 0) {
    if (link_abi_getenv("XLANG_DEBUG_PIPE"))
      fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] skip dep emit (prebuilt .o) j=%d path=%s\n", (int)dep_j,
              (char *)dep_path_buf);
    return 0;
  }
  /** asm_entry_module_only / skip_asm_dep_codegen：dep 符号由并列 *.o 提供，勿 co-emit 进 entry 的 C/asm。 */
  if (skip_asm_dep_codegen != 0)
    return 0;
  if (dep_mod && pipeline_module_num_funcs(dep_mod) > 0) {
    if (use_asm_backend != 0) {
      if (skip_asm_dep_codegen == 0 &&
          asm_asm_codegen_ast(dep_mod, pipeline_dep_ctx_arena_at(ctx, dep_j), out_buf, ctx) != 0) {
        if (link_abi_getenv("XLANG_DEBUG_PIPE"))
          fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] dep emit asm fail j=%d path=%s\n", (int)dep_j,
                  (char *)dep_path_buf);
        return -6;
      }
    } else if (codegen_codegen_x_ast(dep_mod, pipeline_dep_ctx_arena_at(ctx, dep_j), out_buf, ctx, dep_j) != 0) {
      if (link_abi_getenv("XLANG_DEBUG_PIPE")) {
        /* PLATFORM: SHARED — use codegen_out_buf_len (offset ABI); field name is length
         * (wave382) not len; direct out_buf->len fails when compiling against seed pipeline_gen. */
        fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] dep emit c fail j=%d path=%s last_func_idx=%d out_len=%zu\n",
                (int)dep_j, (char *)dep_path_buf, (int)ctx->current_func_index,
                (size_t)codegen_out_buf_len(out_buf));
      }
      return -6;
    }
  }
  return 0;
}

/**
 * entry module 最终 codegen emit；C glue（asm_asm_codegen_ast / codegen_codegen_x_ast 深栈保留 C）。
 */
int32_t run_x_pipeline_codegen_entry_emit(struct ast_Module *module, struct ast_ASTArena *arena,
                                           struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx,
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

extern int32_t driver_skip_codegen_dep_0_get(void);
extern void driver_set_current_dep_path_for_codegen(uint8_t *path);
extern void driver_diagnostic_entry_already(int32_t v);
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern void driver_diagnostic_entry_module(struct ast_Module *module, struct ast_ASTArena *arena);
extern int32_t pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern void pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *path, int32_t len);
extern void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t dep_j, uint8_t *dst);

/** entry parse 薄编排 C glue（EMIT_HEAVY 勿 X let init CALL）。 */
int32_t run_x_pipeline_parse_entry_if_needed_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                uint8_t *source_data, size_t source_len,
                                                struct ast_PipelineDepCtx *ctx) {
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

/** dep 路径 buf 非空时写入 ctx import_path；C glue（X u8[128] 栈后单点 set）。 */
int32_t pipeline_fill_dep_import_path_from_buf_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j, uint8_t *path_buf) {
  int32_t path_len = 0;

  if (!ctx || !path_buf || dep_j < 0)
    return -1;
  /* wave584 Cap residual: scan ≤127 (dep_path_rows content). */
  while (path_len < 127 && path_buf[path_len] != 0)
    path_len = path_len + 1;
  if (path_len > 0)
    pipeline_dep_ctx_set_import_path(ctx, dep_j, path_buf, path_len);
  return 0;
}

/**
 * 扫描 buf 长度后 resolve_path_x；C glue（X 栈 path + assign CALL emit 失败）。
 * wave584: scan width 64→127.
 */
int32_t pipeline_resolve_path_x_from_buf64_c(struct ast_PipelineDepCtx *ctx, uint8_t *path_buf) {
  int32_t path_len = 0;

  if (!ctx || !path_buf)
    return -1;
  while (path_len < 127 && path_buf[path_len] != 0)
    path_len = path_len + 1;
  if (path_len <= 0)
    return -1;
  return pipeline_resolve_path_x(ctx, path_buf, path_len);
}

/**
 * dep import 路径补全；C glue。
 *
 * 【Why 根源】旧实现无条件用 entry import[dep_j] 覆写 ctx path。
 *   闭包 seed 时 dep_j 是 BFS 下标（0=driver, 1=core…），entry 仅有
 *   import[0]=net、import[1]=driver → path 被冲成 net/driver，module 仍为
 *   driver/core。后果：j=0 被 link_only(std.net) 跳过、core 以 driver 前缀
 *   co-emit（std_io_driver_xlang_io_*）→ run-net 缺 xlang_io_submit_*_batch。
 * 【Invariant】ctx 槽 path 已设（plen>0）则保留闭包权威；仅空槽才从 entry 补。
 * PLATFORM: SHARED.
 */
int32_t run_x_pipeline_fill_dep_import_path_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                                int32_t dep_j) {
  uint8_t path_buf[128];
  int32_t path_len;
  int32_t existing;

  if (!module || !ctx || dep_j < 0)
    return -1;
  existing = pipeline_dep_ctx_import_path_len(ctx, dep_j);
  if (existing > 0)
    return 0;
  memset(path_buf, 0, sizeof(path_buf));
  (void)parser_copy_module_import_path64(module, dep_j, path_buf);
  path_len = 0;
  /* wave584 Cap residual: scan ≤127 (path_buf[128] / dep row). */
  while (path_len < 127 && path_buf[path_len] != 0)
    path_len = path_len + 1;
  if (path_len > 0)
    pipeline_dep_ctx_set_import_path(ctx, dep_j, path_buf, path_len);
  return 0;
}

/** codegen 前设置 dep 符号前缀；C glue。 */
int32_t pipeline_prepare_dep_codegen_path_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j, uint8_t *dst) {
  if (!ctx || !dst || dep_j < 0)
    return -1;
  pipeline_dep_ctx_import_path_copy64(ctx, dep_j, dst);
  driver_set_current_dep_path_for_codegen(dst);
  return 0;
}

/** dep codegen 后清理前缀并打诊断；C glue。 */
int32_t pipeline_finish_dep_codegen_diag_c(int32_t dep_j, struct codegen_CodegenOutBuf *out_buf) {
  if (!out_buf)
    return -1;
  /* PLATFORM: SHARED — length via codegen_out_buf_len (seed field name: length). */
  driver_diagnostic_after_dep_codegen(dep_j, codegen_out_buf_len(out_buf));
  driver_set_current_dep_path_for_codegen(NULL);
  return 0;
}

/** 单 dep codegen 编排；C glue。 */
int32_t run_x_pipeline_codegen_one_dep_c(struct ast_Module *module, struct codegen_CodegenOutBuf *out_buf,
                                          struct ast_PipelineDepCtx *ctx, int32_t dep_j,
                                          int32_t skip_asm_dep_codegen) {
  uint8_t dep_path_buf[128];
  struct ast_Module *dep_mod;
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
  /*
   * wave578 Cap residual (Ubuntu L2): after name[64]→[128], DepCtx sidecar
   * module_at can be NULL at codegen while driver_dep_module_buf still holds the
   * pre-parsed dep (parse_set_main_from_buf saw num_funcs>0). Same pattern as
   * load_and_sync closure rebind (ast_pool ~7486): rebind from driver publish
   * slots via this TU's set_module (G.7 single sidecar authority).
   * PLATFORM: SHARED — mac L2 stayed green (sidecar hit); Ubuntu gold exposed NULL.
   */
  if (!dep_mod) {
    int32_t sync_slot = driver_dep_slot_for_path(dep_path_buf);
    if (sync_slot < 0)
      sync_slot = dep_j;
    dep_mod = (struct ast_Module *)driver_dep_module_buf(sync_slot);
    if (dep_mod) {
      pipeline_dep_ctx_set_module(ctx, dep_j, dep_mod);
      pipeline_dep_ctx_set_arena(ctx, dep_j, (struct ast_ASTArena *)driver_dep_arena_buf(sync_slot));
      if (link_abi_getenv("XLANG_DEBUG_PIPE"))
        fprintf(stderr,
                "xlang: [XLANG_DEBUG_PIPE] rebind dep j=%d path=%s slot=%d funcs=%d\n",
                (int)dep_j, (char *)dep_path_buf, (int)sync_slot,
                (int)pipeline_module_num_funcs(dep_mod));
    }
  }
  if (link_abi_getenv("XLANG_DEBUG_PIPE"))
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] dep codegen j=%d path=%s funcs=%d\n", (int)dep_j,
            (char *)dep_path_buf, dep_mod ? (int)pipeline_module_num_funcs(dep_mod) : -1);
  /** bootstrap partial：前端模块勿整库 C emit（符号由 *_x.o 提供）。 */
  if (pipeline_codegen_dep_skip_x_bootstrap_partial(dep_path_buf) != 0) {
    if (link_abi_getenv("XLANG_DEBUG_PIPE"))
      fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] skip dep codegen j=%d path=%s\n", (int)dep_j,
              (char *)dep_path_buf);
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

static int32_t pipeline_dep_ctx_has_earlier_same_import_path_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j) {
  int32_t path_len;
  int32_t prev_j;
  uint8_t path_buf[128];

  if (!ctx || dep_j <= 0)
    return 0;
  path_len = pipeline_dep_ctx_import_path_len(ctx, dep_j);
  if (path_len <= 0 || path_len > (int32_t)sizeof(path_buf))
    return 0;
  memset(path_buf, 0, sizeof(path_buf));
  pipeline_dep_ctx_import_path_copy64(ctx, dep_j, path_buf);
  prev_j = 0;
  while (prev_j < dep_j) {
    int32_t prev_len = pipeline_dep_ctx_import_path_len(ctx, prev_j);
    uint8_t prev_buf[128];
    if (prev_len == path_len && prev_len > 0 && prev_len <= (int32_t)sizeof(prev_buf)) {
      memset(prev_buf, 0, sizeof(prev_buf));
      pipeline_dep_ctx_import_path_copy64(ctx, prev_j, prev_buf);
      if (memcmp(prev_buf, path_buf, (size_t)path_len) == 0)
        return 1;
    }
    prev_j = prev_j + 1;
  }
  return 0;
}

/** 各 dep codegen while 循环；C glue。 */
void pipeline_codegen_c_file_prologue_done_reset(void);

/** entry arena：dep 先于 entry emit，跨模块泛型 mono 须扫 entry 上 CALL。 */
static struct ast_ASTArena *g_codegen_entry_arena_for_mono;
struct ast_ASTArena *pipeline_codegen_entry_arena_for_mono_get(void) {
  return g_codegen_entry_arena_for_mono;
}

int32_t run_x_pipeline_codegen_deps_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                       struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx,
                                       int32_t skip_asm_dep_codegen) {
  int32_t ndep;
  int32_t j;

  if (!module || !arena || !out_buf || !ctx)
    return -1;
  g_codegen_entry_arena_for_mono = arena;
  /* 新一轮 -E/-o codegen：允许首个 codegen_x_ast 写 prologue。 */
  pipeline_codegen_c_file_prologue_done_reset();
  ndep = pipeline_dep_ctx_ndep(ctx);
  j = 0;
  while (j < ndep) {
    if (pipeline_dep_ctx_has_earlier_same_import_path_c(ctx, j) != 0) {
      if (link_abi_getenv("XLANG_DEBUG_PIPE")) {
        uint8_t dup_path_buf[128];
        memset(dup_path_buf, 0, sizeof(dup_path_buf));
        pipeline_dep_ctx_import_path_copy64(ctx, j, dup_path_buf);
        fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] skip duplicate dep codegen j=%d path=%s\n", (int)j,
                (char *)dup_path_buf);
      }
      j = j + 1;
      continue;
    }
    if (run_x_pipeline_codegen_one_dep_c(module, out_buf, ctx, j, skip_asm_dep_codegen) != 0)
      return -6;
    j = j + 1;
  }
  return 0;
}

/** entry module 最终 codegen 编排；C glue。 */
int32_t run_x_pipeline_codegen_entry_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                         struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx) {
  if (!module || !arena || !out_buf || !ctx)
    return -1;
  driver_diagnostic_entry_module(module, arena);
  if (run_x_pipeline_codegen_entry_emit(module, arena, out_buf, ctx,
                                         pipeline_dep_ctx_use_asm_backend(ctx)) != 0) {
    driver_diagnostic_codegen_fail(0, 0);
    return -6;
  }
  return 0;
}

/**
 * 有界循环 continue：idx < ndep 时返回 1（X while 裸 CALL 条件，勿 CALL==0 比较 emit 失败）。
 */
int32_t pipeline_loop_should_continue_ndep_c(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  if (!ctx)
    return 0;
  return idx < pipeline_dep_ctx_ndep(ctx) ? 1 : 0;
}

/**
 * 有界 import 循环 continue：idx < num_imports 时返回 1。
 */
int32_t pipeline_loop_should_continue_imports_c(struct ast_Module *module, int32_t idx) {
  if (!module)
    return 0;
  return idx < parser_get_module_num_imports(module) ? 1 : 0;
}

/**
 * 有界 lib_root 循环 continue：idx < lib_root_count 时返回 1（resolve_path_x X while）。
 */
int32_t pipeline_loop_should_continue_lib_root_c(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  if (!ctx)
    return 0;
  return idx < pipeline_ctx_lib_root_count(ctx) ? 1 : 0;
}

/**
 * 有界循环 exit：idx >= ndep 时返回 1（X 用 if(CALL!=0)，勿 idx>=ndep(ctx) 比较 emit 失败）。
 */
int32_t pipeline_loop_index_at_or_beyond_ndep_c(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  if (!ctx)
    return 1;
  return idx >= pipeline_dep_ctx_ndep(ctx) ? 1 : 0;
}

/**
 * 有界 import 循环 exit：idx >= num_imports 时返回 1。
 */
int32_t pipeline_loop_index_at_or_beyond_imports_c(struct ast_Module *module, int32_t idx) {
  if (!module)
    return 1;
  return idx >= parser_get_module_num_imports(module) ? 1 : 0;
}

/** load_and_sync import 循环结束后写 ndep；C glue（勿 X stmt 内嵌双 CALL）。 */
void pipeline_load_and_sync_set_ndep_from_module_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx) {
  if (module && ctx)
    pipeline_dep_ctx_set_ndep(ctx, parser_get_module_num_imports(module));
}

/** one_dep codegen 前 prepare path prefix；C glue（X 侧 u8[64] 栈数组）。 */
int32_t run_x_pipeline_codegen_one_dep_prepare_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j) {
  uint8_t dep_path_buf[128];

  if (!ctx || dep_j < 0)
    return -1;
  memset(dep_path_buf, 0, sizeof(dep_path_buf));
  return pipeline_prepare_dep_codegen_path_c(ctx, dep_j, dep_path_buf);
}


static DriverEmitSidecar *driver_emit_sidecar_get(uint8_t *state, int create) {
  int i;
  if (!state)
    return NULL;
  for (i = 0; i < MAX_DRIVER_EMIT_SIDECARS; i++) {
    if (g_driver_emit_sc[i].used && g_driver_emit_sc[i].state == state)
      return &g_driver_emit_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_DRIVER_EMIT_SIDECARS; i++) {
    if (!g_driver_emit_sc[i].used) {
      g_driver_emit_sc[i].state = state;
      g_driver_emit_sc[i].used = 1;
      if (!grow_vec_init(&g_driver_emit_sc[i].lib_root_rows, 256, AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_driver_emit_sc[i].lib_root_lens, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      return &g_driver_emit_sc[i];
    }
  }
  return NULL;
}

void driver_emit_lib_root_reset(uint8_t *state) {
  DriverEmitSidecar *sc = driver_emit_sidecar_get(state, 0);
  if (!sc)
    return;
  sc->lib_root_rows.len = 0;
  sc->lib_root_lens.len = 0;
}

/**
 * Release the DriverEmitSidecar for `state` (free GrowVecs, mark slot free).
 *
 * Must be called before free(state) for any heap compile/emit state that used
 * driver_emit_append_lib_root. Without this, directory check exhausts the table
 * after MAX_DRIVER_EMIT_SIDECARS sessions and import -L roots stop applying.
 * PLATFORM: SHARED — dual-host check after change.
 */
void driver_emit_lib_root_release(uint8_t *state) {
  int i;
  if (!state)
    return;
  for (i = 0; i < MAX_DRIVER_EMIT_SIDECARS; i++) {
    if (!g_driver_emit_sc[i].used || g_driver_emit_sc[i].state != state)
      continue;
    grow_vec_free(&g_driver_emit_sc[i].lib_root_rows);
    grow_vec_free(&g_driver_emit_sc[i].lib_root_lens);
    g_driver_emit_sc[i].state = NULL;
    g_driver_emit_sc[i].used = 0;
    return;
  }
}

int32_t driver_emit_append_lib_root(uint8_t *state, uint8_t *path, int32_t len) {
  DriverEmitSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t idx;
  int32_t n;
  if (!state || !path || len <= 0)
    return -1;
  if (!(sc = driver_emit_sidecar_get(state, 1)))
    return -1;
  idx = grow_vec_push(&sc->lib_root_rows);
  if (idx < 0 || grow_vec_push(&sc->lib_root_lens) < 0)
    return -1;
  row = (uint8_t *)grow_vec_at(&sc->lib_root_rows, idx);
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, idx);
  if (!row || !pl)
    return -1;
  n = len > 255 ? 255 : len;
  memset(row, 0, 256);
  memcpy(row, path, (size_t)n);
  *pl = n;
  return idx;
}

int32_t driver_emit_lib_root_count(uint8_t *state) {
  DriverEmitSidecar *sc = driver_emit_sidecar_get(state, 0);
  return sc ? sc->lib_root_rows.len : 0;
}

int32_t driver_emit_lib_root_len(uint8_t *state, int32_t i) {
  DriverEmitSidecar *sc;
  int32_t *pl;
  if (!state || i < 0 || !(sc = driver_emit_sidecar_get(state, 0)) || i >= sc->lib_root_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, i);
  return pl ? *pl : 0;
}

void driver_emit_lib_root_copy(uint8_t *state, int32_t i, uint8_t *dst, int32_t cap) {
  DriverEmitSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst || cap <= 0)
    return;
  memset(dst, 0, (size_t)cap);
  if (!state || i < 0 || !(sc = driver_emit_sidecar_get(state, 0)) || i >= sc->lib_root_rows.len)
    return;
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->lib_root_rows, i);
  if (!pl || !row)
    return;
  n = *pl;
  if (n >= cap)
    n = cap - 1;
  for (k = 0; k < n; k++)
    dst[k] = row[k];
}

/** backend.x：import 限定符号解析时的 field 层栈（替代 [16][64] 栈数组）。 */
typedef struct {
  int inited;
  GrowVec layer_rows;
  GrowVec layer_lens;
} AsmQualSymScratch;

static AsmQualSymScratch g_asm_qual_sym;

/** 惰性初始化 asm 限定符号 scratch 池。 */
static void asm_qual_sym_scratch_ensure(void) {
  if (g_asm_qual_sym.inited)
    return;
  if (!grow_vec_init(&g_asm_qual_sym.layer_rows, 64, AST_POOL_INIT_CAP))
    return;
  if (!grow_vec_init(&g_asm_qual_sym.layer_lens, sizeof(int32_t), AST_POOL_INIT_CAP))
    return;
  g_asm_qual_sym.inited = 1;
}

/** 清空 field 层栈。 */
void asm_qual_sym_layer_reset(void) {
  asm_qual_sym_scratch_ensure();
  g_asm_qual_sym.layer_rows.len = 0;
  g_asm_qual_sym.layer_lens.len = 0;
}

/** 追加一层 field 名（最多 63 字节）；返回层下标，失败 -1。 */
int32_t asm_qual_sym_layer_push(uint8_t *bytes, int32_t len) {
  uint8_t *row;
  int32_t *pl;
  int32_t idx;
  int32_t n;
  if (!bytes || len <= 0)
    return -1;
  asm_qual_sym_scratch_ensure();
  if (!g_asm_qual_sym.inited)
    return -1;
  n = len > 127 ? 127 : len;
  idx = grow_vec_push(&g_asm_qual_sym.layer_rows);
  if (idx < 0 || grow_vec_push(&g_asm_qual_sym.layer_lens) < 0)
    return -1;
  row = (uint8_t *)grow_vec_at(&g_asm_qual_sym.layer_rows, idx);
  pl = (int32_t *)grow_vec_at(&g_asm_qual_sym.layer_lens, idx);
  if (!row || !pl)
    return -1;
  memset(row, 0, 64);
  memcpy(row, bytes, (size_t)n);
  *pl = n;
  return idx;
}

/** 当前层数。 */
int32_t asm_qual_sym_layer_count(void) {
  asm_qual_sym_scratch_ensure();
  return g_asm_qual_sym.inited ? g_asm_qual_sym.layer_rows.len : 0;
}

/** 第 i 层 field 名长度。 */
int32_t asm_qual_sym_layer_len(int32_t i) {
  int32_t *pl;
  if (i < 0 || !g_asm_qual_sym.inited || i >= g_asm_qual_sym.layer_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&g_asm_qual_sym.layer_lens, i);
  return pl ? *pl : 0;
}

/** 拷贝第 i 层 field 名到 dst（cap 含 NUL 余量）。 */
void asm_qual_sym_layer_copy(int32_t i, uint8_t *dst, int32_t cap) {
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst || cap <= 0)
    return;
  memset(dst, 0, (size_t)cap);
  if (i < 0 || !g_asm_qual_sym.inited || i >= g_asm_qual_sym.layer_rows.len)
    return;
  pl = (int32_t *)grow_vec_at(&g_asm_qual_sym.layer_lens, i);
  row = (uint8_t *)grow_vec_at(&g_asm_qual_sym.layer_rows, i);
  if (!pl || !row)
    return;
  n = *pl;
  if (n >= cap)
    n = cap - 1;
  for (k = 0; k < n; k++)
    dst[k] = row[k];
}

/**
 * preprocess.x：#if/#else 嵌套栈 cold fallback（GrowVec）。
 *
 * wave86: product pure owns preprocess_if_stack_* via fixed i32[32] BSS in
 * runtime_pipeline_abi.x (G.7 single authority under PREFER hybrid). This
 * GrowVec body stays XLANG_WEAK so cold / non-hybrid links without pure still
 * work, and pure weak/strong overrides under product L2 hybrid.
 *
 * PLATFORM: SHARED — ELF weak overridden by pure; PE XLANG_WEAK empty +
 * --allow-multiple-definition (Windows hybrid not required this wave).
 */
static GrowVec g_preprocess_if_stack;
static int g_preprocess_if_inited;

static void preprocess_if_stack_ensure(void) {
  if (g_preprocess_if_inited)
    return;
  if (!grow_vec_init(&g_preprocess_if_stack, sizeof(int32_t), AST_POOL_INIT_CAP))
    return;
  g_preprocess_if_inited = 1;
}

/** Clear #if nest stack (weak cold fallback; pure owns product). */
XLANG_WEAK void preprocess_if_stack_reset(void) {
  preprocess_if_stack_ensure();
  g_preprocess_if_stack.len = 0;
}

/** Current nest depth (weak cold fallback). */
XLANG_WEAK int32_t preprocess_if_stack_len(void) {
  preprocess_if_stack_ensure();
  return g_preprocess_if_inited ? g_preprocess_if_stack.len : 0;
}

/** Push one nest state; -1 on OOM/fail (weak cold fallback). */
XLANG_WEAK int32_t preprocess_if_stack_push(int32_t v) {
  int32_t *slot;
  preprocess_if_stack_ensure();
  if (!g_preprocess_if_inited)
    return -1;
  if (grow_vec_push(&g_preprocess_if_stack) < 0)
    return -1;
  slot = (int32_t *)grow_vec_at(&g_preprocess_if_stack, g_preprocess_if_stack.len - 1);
  if (!slot)
    return -1;
  *slot = v;
  return 0;
}

/** Pop one nest level (weak cold fallback). */
XLANG_WEAK void preprocess_if_stack_pop(void) {
  preprocess_if_stack_ensure();
  if (g_preprocess_if_stack.len > 0)
    g_preprocess_if_stack.len--;
}

/** Read stack[i] (weak cold fallback; OOB → 0). */
XLANG_WEAK int32_t preprocess_if_stack_at(int32_t i) {
  int32_t *slot;
  if (i < 0 || !g_preprocess_if_inited || i >= g_preprocess_if_stack.len)
    return 0;
  slot = (int32_t *)grow_vec_at(&g_preprocess_if_stack, i);
  return slot ? *slot : 0;
}

/** Write stack[i] (weak cold fallback; OOB → no-op). */
XLANG_WEAK void preprocess_if_stack_set_at(int32_t i, int32_t v) {
  int32_t *slot;
  if (i < 0 || !g_preprocess_if_inited || i >= g_preprocess_if_stack.len)
    return;
  slot = (int32_t *)grow_vec_at(&g_preprocess_if_stack, i);
  if (slot)
    *slot = v;
}

/** typeck.x：命名类型对齐/大小时复用的 64 字节 scratch（避免局部 u8[64] 在自 typecheck 时 check_block 失败）。 */
uint8_t *typeck_named_scratch64(void) {
  static uint8_t s[128];
  return s;
}

/** typeck.x：多槽 128 字节 scratch (wave577 Cap: AST name slots 64→128)；嵌套 layout/struct_lit 路径须用不同 slot 避免覆盖。 */
static uint8_t g_typeck_scratch64[16][128];

uint8_t *typeck_scratch64_slot(int32_t slot) {
  if (slot < 0 || slot >= 16)
    return g_typeck_scratch64[0];
  return g_typeck_scratch64[slot];
}

/** typeck.x：CALL resolve 写 func 下标用；勿用栈上 &cfi（自举 pipeline 下可撕裂致 segfault）。 */
static int32_t g_typeck_call_resolve_func_idx;
static int32_t g_typeck_call_resolve_dep_idx;
/**
 * PLATFORM: SHARED — expected return type for overload pick (let/assign/return context).
 * Zero-arg overloads (vec.new → Vec_i32 vs Vec_u8) score by this when args do not disambiguate.
 * Set by typeck_check_expr_call / method_call; cleared after resolve. 0 = no hint.
 */
static int32_t g_typeck_overload_expected_ret;

int32_t *typeck_call_resolve_func_idx_slot(void) {
  return &g_typeck_call_resolve_func_idx;
}

int32_t *typeck_call_resolve_dep_idx_slot(void) {
  return &g_typeck_call_resolve_dep_idx;
}

int32_t *typeck_overload_expected_ret_slot(void) {
  return &g_typeck_overload_expected_ret;
}

/** 读 CALL resolve dep scratch（X emit 勿 typeck_i32_ptr_read(slot()) 嵌套）。 */
int32_t typeck_call_resolve_dep_idx_peek(void) {
  return g_typeck_call_resolve_dep_idx;
}

/** 读 CALL resolve func scratch（X emit 勿 typeck_i32_ptr_read(slot()) 嵌套）。 */
int32_t typeck_call_resolve_func_idx_peek(void) {
  return g_typeck_call_resolve_func_idx;
}

/** Read expected-return hint for overload scoring (X emit: avoid nested slot read). */
int32_t typeck_overload_expected_ret_peek(void) {
  return g_typeck_overload_expected_ret;
}

/** 前向声明：binop arith infer C glue 读/写类型池。 */
extern int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern void pipeline_expr_set_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t type_ref);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *a, int32_t type_ref);
extern int32_t pipeline_type_array_size_at(struct ast_ASTArena *a, int32_t type_ref);
extern int32_t pipeline_type_elem_ref_at(struct ast_ASTArena *a, int32_t type_ref);
extern int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena *arena, int32_t a, int32_t b);
extern int32_t pipeline_type_ensure_by_kind_ord(struct ast_ASTArena *a, int32_t kind_ord);

/* first-class only; binop twin prefers refs path below for NAMED (wave313). */
static int32_t typeck_integer_widen_ok_ord_c(int32_t dest_kind, int32_t src_kind) {
  if (dest_kind == src_kind)
    return dest_kind == 0 || dest_kind == 2 || dest_kind == 3 || dest_kind == 4 || dest_kind == 5 ||
           dest_kind == 6 || dest_kind == 7;
  if (src_kind == 2)
    return dest_kind == 0 || dest_kind == 3 || dest_kind == 4 || dest_kind == 5 || dest_kind == 6 ||
           dest_kind == 7;
  if (src_kind == 0)
    return dest_kind == 3 || dest_kind == 4 || dest_kind == 5 || dest_kind == 6 || dest_kind == 7 ||
           dest_kind == 2;
  if (src_kind == 3)
    return dest_kind == 4 || dest_kind == 5 || dest_kind == 6 || dest_kind == 7;
  if ((src_kind == 6 && dest_kind == 4) || (src_kind == 4 && dest_kind == 6) ||
      (src_kind == 7 && dest_kind == 5) || (src_kind == 5 && dest_kind == 7))
    return 1;
  return 0;
}

extern int32_t pipeline_type_named_name_into(struct ast_ASTArena *a, int32_t type_ref, uint8_t *out);

/** wave313: G.7 ≡ typeck_integer_widen_ok_refs for binop twin (NAMED i8/i16/u16). */
static int32_t typeck_integer_widen_ok_refs_c(struct ast_ASTArena *arena, int32_t dest_ref, int32_t src_ref) {
  int32_t dk;
  int32_t sk;
  int32_t df;
  int32_t sf;
  uint8_t *buf;
  int32_t nlen;
  if (!arena || dest_ref <= 0 || src_ref <= 0)
    return 0;
  dk = pipeline_type_kind_ord_at(arena, dest_ref);
  sk = pipeline_type_kind_ord_at(arena, src_ref);
  df = -1;
  sf = -1;
  if (dk == 0 || dk == 2 || dk == 3 || dk == 4 || dk == 5 || dk == 6 || dk == 7)
    df = dk;
  else if (dk == 8) {
    buf = typeck_scratch64_slot(15);
    nlen = pipeline_type_named_name_into(arena, dest_ref, buf);
    if (nlen == 2 && buf[0] == 105 && buf[1] == 56)
      df = 10;
    else if (nlen == 3 && buf[0] == 105 && buf[1] == 49 && buf[2] == 54)
      df = 11;
    else if (nlen == 3 && buf[0] == 117 && buf[1] == 49 && buf[2] == 54)
      df = 12;
  }
  if (sk == 0 || sk == 2 || sk == 3 || sk == 4 || sk == 5 || sk == 6 || sk == 7)
    sf = sk;
  else if (sk == 8) {
    buf = typeck_scratch64_slot(15);
    nlen = pipeline_type_named_name_into(arena, src_ref, buf);
    if (nlen == 2 && buf[0] == 105 && buf[1] == 56)
      sf = 10;
    else if (nlen == 3 && buf[0] == 105 && buf[1] == 49 && buf[2] == 54)
      sf = 11;
    else if (nlen == 3 && buf[0] == 117 && buf[1] == 49 && buf[2] == 54)
      sf = 12;
  }
  if (df < 0 || sf < 0)
    return 0;
  if (df == sf)
    return 1;
  if (df <= 7 && sf <= 7)
    return typeck_integer_widen_ok_ord_c(df, sf);
  if (sf == 10)
    return df == 11 || df == 12 || df == 2 || df == 0 || df == 3 || df == 4 || df == 5 || df == 6 || df == 7;
  if (sf == 11)
    return df == 12 || df == 2 || df == 0 || df == 3 || df == 4 || df == 5 || df == 6 || df == 7;
  if (sf == 12)
    return df == 2 || df == 0 || df == 3 || df == 4 || df == 5 || df == 6 || df == 7;
  if (df == 10)
    return sf == 2 || sf == 0 || sf == 11 || sf == 12;
  if (df == 11)
    return sf == 2 || sf == 0 || sf == 12 || sf == 3;
  if (df == 12)
    return sf == 2 || sf == 0 || sf == 11 || sf == 3;
  return 0;
}

/**
 * 算术/位 binop 结果类型推导（typeck.x 同逻辑；X 单函 emit 触顶 reloc 8192，暂经 C glue）。
 * 假定 bop_l/bop_r 已 check；写 expr_ref.resolved_type_ref。
 */
void typeck_binop_arith_infer_type_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t bop_l,
                                     int32_t bop_r, int32_t expr_kind) {
  int32_t lk_expr;
  int32_t rk_expr;
  int32_t lt_ar;
  int32_t rt_ar;
  int32_t lko;
  int32_t rko;
  int32_t out_ar = 0;
  int32_t allow_i32_fallback = 0;
  if (!arena || expr_ref <= 0 || bop_l <= 0 || bop_r <= 0)
    return;
  lt_ar = pipeline_expr_resolved_type_ref(arena, bop_l);
  rt_ar = pipeline_expr_resolved_type_ref(arena, bop_r);
  if (lt_ar <= 0 || rt_ar <= 0 || lt_ar > arena->num_types || rt_ar > arena->num_types)
    return;
  lk_expr = pipeline_expr_kind_ord_at(arena, bop_l);
  rk_expr = pipeline_expr_kind_ord_at(arena, bop_r);
  lko = pipeline_type_kind_ord_at(arena, lt_ar);
  rko = pipeline_type_kind_ord_at(arena, rt_ar);
  /** ptr ± i32/usize/isize → ptr（与 typeck.x binop_arith 一致）。 */
  if (expr_kind >= 4 && expr_kind <= 5) {
    if (lko == 9 && (rko == 0 || rko == 6 || rko == 7))
      out_ar = lt_ar;
    else if (expr_kind == 4 && rko == 9 && (lko == 0 || lko == 6 || lko == 7))
      out_ar = rt_ar;
  }
  /* wave285 Cap residual: G.7 ≡ typeck.x — illegal pointer arithmetic must not
   * fall through type_refs_equal (host BLD001 soft residual). This helper only
   * sets resolved type; callers that hard-fail use typeck_check_expr_binop_arith.
   * Allowed: ptr+int/int+ptr (ADD), ptr-int (SUB→ptr), ptr-ptr (SUB→isize=7). */
  if (lko == 9 || rko == 9) {
    if (expr_kind == 4) {
      if (out_ar != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, out_ar);
        return;
      }
      return; /* leave unresolved; product path hard-fails in typeck_check_expr_binop_arith */
    }
    if (expr_kind == 5) {
      if (lko == 9 && rko == 9) {
        out_ar = pipeline_type_ensure_by_kind_ord(arena, 7); /* isize */
        if (out_ar != 0)
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, out_ar);
        return;
      }
      if (out_ar != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, out_ar);
        return;
      }
      return;
    }
    return; /* mul/div/… with ptr: leave unresolved */
  }
  /* wave286 Cap residual: G.7 ≡ typeck.x — illegal float bitop/mod/shift must not
   * promote to f32/f64 (host BLD001 soft residual). Leave unresolved; product path
   * hard-fails in typeck_check_expr_binop_arith.
   * expr_kind: MOD=8 SHL=9 SHR=10 BITAND=11 BITOR=12 BITXOR=13; f32=14 f64=15. */
  if ((lko == 14 || lko == 15 || rko == 14 || rko == 15)
      && (expr_kind == 8 || expr_kind == 9 || expr_kind == 10 || expr_kind == 11
          || expr_kind == 12 || expr_kind == 13)) {
    return;
  }
  /* wave658 Cap residual: G.7 ≡ typeck.x — ARRAY/SLICE/LINEAR must not fall through
   * type_refs_equal (host BLD001). VECTOR (13) same-size still allowed below.
   * Named struct hard-fail needs module layouts — product typeck_check_expr_binop_arith. */
  if (lko == 10 || lko == 11 || lko == 12 || rko == 10 || rko == 11 || rko == 12)
    return;
  if (lko == 13 && rko == 13 && pipeline_type_array_size_at(arena, lt_ar) == pipeline_type_array_size_at(arena, rt_ar) &&
      pipeline_typeck_type_refs_equal_c(arena, pipeline_type_elem_ref_at(arena, lt_ar),
                                        pipeline_type_elem_ref_at(arena, rt_ar)) != 0) {
    out_ar = lt_ar;
  } else if (out_ar == 0 && (lko == 5 || rko == 5)) {
    out_ar = pipeline_type_ensure_by_kind_ord(arena, 5);
  } else if (out_ar == 0 && lko == 14
             && (rk_expr == 1 /* EXPR_FLOAT_LIT */ || rk_expr == 22 /* EXPR_NEG */)) {
    /* wave317 soft-infer twin: f32 + bare FLOAT_LIT / -float stays f32 before f64 widen.
     * G.7 ≡ typeck.x typeck_coerce_init_float_lit_to_decl (inline stamp; ast_pool is
     * #include'd before glue coerce body). EXPR_FLOAT_LIT=1, EXPR_NEG=22. */
    if (rk_expr == 1) {
      pipeline_expr_set_resolved_type_ref(arena, bop_r, lt_ar);
      out_ar = lt_ar;
    } else {
      int32_t op_r = pipeline_expr_unary_operand_ref_at(arena, bop_r);
      if (op_r > 0 && pipeline_expr_kind_ord_at(arena, op_r) == 1) {
        pipeline_expr_set_resolved_type_ref(arena, op_r, lt_ar);
        pipeline_expr_set_resolved_type_ref(arena, bop_r, lt_ar);
        out_ar = lt_ar;
      }
    }
  } else if (out_ar == 0 && rko == 14
             && (lk_expr == 1 || lk_expr == 22)) {
    if (lk_expr == 1) {
      pipeline_expr_set_resolved_type_ref(arena, bop_l, rt_ar);
      out_ar = rt_ar;
    } else {
      int32_t op_l = pipeline_expr_unary_operand_ref_at(arena, bop_l);
      if (op_l > 0 && pipeline_expr_kind_ord_at(arena, op_l) == 1) {
        pipeline_expr_set_resolved_type_ref(arena, op_l, rt_ar);
        pipeline_expr_set_resolved_type_ref(arena, bop_l, rt_ar);
        out_ar = rt_ar;
      }
    }
  } else if (out_ar == 0 && (lko == 15 || rko == 15)) {
    /* wave296: f64 before f32 (usual arithmetic conversion); G.7 ≡ typeck.x / typeck_gen. */
    out_ar = pipeline_type_ensure_by_kind_ord(arena, 15);
  } else if (out_ar == 0 && (lko == 14 || rko == 14)) {
    out_ar = pipeline_type_ensure_by_kind_ord(arena, 14);
  } else if (out_ar == 0 && pipeline_typeck_type_refs_equal_c(arena, lt_ar, rt_ar) != 0) {
    out_ar = lt_ar;
  } else if (out_ar == 0 && typeck_integer_widen_ok_refs_c(arena, lt_ar, rt_ar)) {
    out_ar = lt_ar;
  } else if (out_ar == 0 && typeck_integer_widen_ok_refs_c(arena, rt_ar, lt_ar)) {
    out_ar = rt_ar;
  } else if (out_ar == 0 && lk_expr == 0 && rk_expr != 0) {
    out_ar = rt_ar;
  } else if (out_ar == 0 && rk_expr == 0 && lk_expr != 0) {
    out_ar = lt_ar;
  } else if (out_ar == 0 && lt_ar != 0) {
    out_ar = lt_ar;
  } else if (out_ar == 0 && rt_ar != 0) {
    out_ar = rt_ar;
  }
  if (expr_kind >= 4 && expr_kind <= 13)
    allow_i32_fallback = 1;
  if (out_ar == 0 && lko != 13 && rko != 13 && allow_i32_fallback)
    out_ar = pipeline_type_ensure_by_kind_ord(arena, 0);
  if (allow_i32_fallback && lko != 9 && rko != 9 &&
      (pipeline_type_kind_ord_at(arena, lt_ar) == 1 || pipeline_type_kind_ord_at(arena, rt_ar) == 1))
    out_ar = pipeline_type_ensure_by_kind_ord(arena, 0);
  if (out_ar != 0)
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, out_ar);
}

/**
 * packed struct 布局快路径：无隐式 padding；与 typeck.x typeck_struct_layout_metrics 一致。
 * 返回值：1=已写入 out_sz/out_al，0=非 packed 须走常规对齐路径，-1=字段尺寸错误。
 */
int32_t typeck_struct_layout_metrics_try_packed_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                int32_t li, int32_t depth, int32_t check_pad, int32_t *out_sz,
                                                int32_t *out_al) {
  int32_t nf;
  int32_t j;
  int32_t ftr;
  int32_t fsize;
  int32_t current;
  uint8_t layout_nm[128];
  uint8_t field_nm[128];
  int32_t layout_nlen;
  int32_t flen;
  extern int32_t typeck_x_type_size(struct ast_Module *module, struct ast_ASTArena *arena, int32_t ty_ref,
                                     int32_t depth);
  extern void driver_diagnostic_typeck_struct_field_bad_size(uint8_t *sname, int32_t sname_len, uint8_t *fname,
                                                             int32_t fname_len);
  (void)check_pad;
  if (!module || !arena || !out_sz || !out_al || li < 0)
    return 0;
  if (pipeline_module_struct_layout_packed_at(module, li) == 0)
    return 0;
  nf = pipeline_module_struct_layout_num_fields(module, li);
  current = 0;
  j = 0;
  while (j < nf) {
    ftr = pipeline_module_struct_layout_field_type_ref(module, li, j);
    pipeline_module_struct_layout_field_name_into(module, li, j, field_nm);
    flen = pipeline_module_struct_layout_field_name_len(module, li, j);
    fsize = typeck_x_type_size(module, arena, ftr, depth);
    if (fsize <= 0) {
      pipeline_module_struct_layout_name_into(module, li, layout_nm);
      layout_nlen = pipeline_module_struct_layout_name_len(module, li);
      driver_diagnostic_typeck_struct_field_bad_size(layout_nm, layout_nlen, field_nm, flen);
      return -1;
    }
    current = current + fsize;
    j = j + 1;
  }
  *out_sz = current;
  *out_al = 1;
  return 1;
}

/** typeck.x：struct_layout_metrics 写 out_sz/out_al；勿用栈上 &z/&al。 */
static int32_t g_typeck_layout_metrics_sz;
static int32_t g_typeck_layout_metrics_al;

int32_t *typeck_layout_metrics_sz_slot(void) {
  return &g_typeck_layout_metrics_sz;
}

int32_t *typeck_layout_metrics_al_slot(void) {
  return &g_typeck_layout_metrics_al;
}

/** 递归 metrics 用 depth 分槽（8 组），避免 align/size 共用单槽 tearing。 */
static int32_t g_typeck_layout_metrics_depth_scratch[8][2];

int32_t *typeck_layout_metrics_sz_slot_depth(int32_t depth) {
  int32_t s = depth;
  if (s < 0)
    s = 0;
  return &g_typeck_layout_metrics_depth_scratch[s % 8][0];
}

int32_t *typeck_layout_metrics_al_slot_depth(int32_t depth) {
  int32_t s = depth;
  if (s < 0)
    s = 0;
  return &g_typeck_layout_metrics_depth_scratch[s % 8][1];
}

#include "pipeline_elf_ctx.c"

/** codegen.x：路径/前缀 scratch（避免 `u8[64] = []` 在 asm emit 时 ExprKind=-1）。 */
static uint8_t g_scratch64[4][128];
static uint8_t g_scratch128[2][128];
static uint8_t g_scratch256[2][256];

uint8_t *pipeline_scratch_buf64(void) {
  return g_scratch64[0];
}

uint8_t *pipeline_scratch_buf64_slot(int32_t slot) {
  if (slot < 0 || slot >= 4)
    return g_scratch64[0];
  return g_scratch64[slot];
}

uint8_t *pipeline_scratch_buf128(void) {
  return g_scratch128[0];
}

uint8_t *pipeline_scratch_buf128_slot(int32_t slot) {
  if (slot < 0 || slot >= 2)
    return g_scratch128[0];
  return g_scratch128[slot];
}

uint8_t *pipeline_scratch_buf96(void) {
  static uint8_t s[96];
  return s;
}

uint8_t *pipeline_scratch_buf256(void) {
  return g_scratch256[0];
}

uint8_t *pipeline_scratch_buf256_slot(int32_t slot) {
  if (slot < 0 || slot >= 2)
    return g_scratch256[0];
  return g_scratch256[slot];
}

#include "pipeline_codegen_type_to_c.c"

#include "pipeline_codegen_struct_emit.c"

#include "pipeline_codegen_skip_force.c"

#include "pipeline_codegen_residual.c"

#include "pipeline_asm_locals.c"

#include "pipeline_asm_slot_bytes.c"

#include "pipeline_asm_block_tree.c"

#include "pipeline_asm_ctx_loop.c"

/** 块树 const+let 槽超过此阈值时 asm 完整 emit 易在宿主栈溢出（lexer 前几项函数亦可能 <160 funcs）。 */
#define ASM_HEAVY_BODY_SLOT_THRESHOLD 48
/** EMIT_HEAVY 第二遍放宽槽位（layout helper）；仍低于 mega typecheck 体。 */
#define ASM_EMIT_HEAVY_SLOT_THRESHOLD 256
/** backend.x 自举（含 import 展开 ~219 func）：#87–218 索引桩；#0–86 小 helper 真 emit。 */
#define ASM_EMIT_HEAVY_BACKEND_INDEX_LO 87
#define ASM_EMIT_HEAVY_BACKEND_INDEX_HI 218
/** typeck.x ~173 func：#90–159 深 emit Abort；#0–89 layout/helper 与 #160+ 可真 emit 扩 __text。 */
#define ASM_EMIT_HEAVY_TYPECK_INDEX_LO 90
#define ASM_EMIT_HEAVY_TYPECK_INDEX_HI 159
/** pipeline.x ~56 func：编排入口 #53–#55 须真 emit；索引桩已移除，靠 pipeline_expr_* 消除 Expr 栈拷贝。 */
/** XLANG_ASM_EMIT_ABORT_LO/HI 默认（backend 二分调试）。 */
#define ASM_EMIT_HEAVY_LARGE_ENTRY_LO ASM_EMIT_HEAVY_BACKEND_INDEX_LO
#define ASM_EMIT_HEAVY_LARGE_ENTRY_HI ASM_EMIT_HEAVY_BACKEND_INDEX_HI

/** 大入口 backend（num_funcs>=175）EMIT_HEAVY 槽位阈值（较默认 256 收紧，避免 codegen 宿主栈 Abort）。 */
#define ASM_EMIT_HEAVY_LARGE_BACKEND_SLOT_THRESHOLD 96
/** backend helper 白名单真 emit 时块树槽位上限（过大仍走索引桩）。 */
#define ASM_EMIT_HEAVY_BACKEND_HELPER_SLOT_MAX 48
/** typeck layout helper 允许略大栈帧（merge_dep 双循环 ~110 slot；仍远小于 check_block mega）。 */
#define ASM_EMIT_HEAVY_TYPECK_LAYOUT_SLOT_MAX 128

/** 读 XLANG_ASM_EMIT_ABORT_LO/HI：调试二分定位 Abort 区间（默认见上常量）。 */
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
 * 与 typeck.x::typeck_skip_heavy_selfhost_func_body 对齐，并据块树槽位数自动跳过超大函数体。
 * 库模块 -backend asm -o 时改发最小 ret 0 桩，保证 __text 非空且编译不 SIGSEGV。
 */
/**
 * 模块顶层 let/const 若为整型字面量初始化，返回 1 并写入 *out_imm（供 asm EXPR_VAR 直接 mov imm）。
 */
#ifndef XLANG_PIPELINE_GLUE_STANDALONE_TU
/** runtime.c：dep 模块 asm codegen 时设置的当前 import 逻辑路径（常规 pipeline_x 链）。 */
extern const char *driver_get_current_dep_path_for_codegen(void);
#endif

/**
 * 供 backend.x 读取 dep 路径（避免经 codegen 模块名修饰导致链接符号不一致）。
 * B-strict standalone TU 下 driver_get 由 pipeline_glue_types.inc 声明为 uint8_t *。
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
 * 将 import 路径转为 C 符号前缀（与 codegen.c::import_path_to_c_prefix 一致）。
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

/** XLANG_ASM_BUILD_SKIP_TYPECK=1 时 build_xlang_asm 走桩路径，避免无 typeck 的大模块 asm emit 栈溢出。 */
static int32_t asm_env_build_skip_typeck(void) {
  const char *e = link_abi_getenv("XLANG_ASM_BUILD_SKIP_TYPECK");
  return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

/** XLANG_ASM_STRICT_ORCHESTRATION=1 时 C 编排链才跳过 pipeline 大函数 emit（默认 build_asm 须落真机器码）。 */
static int32_t asm_env_strict_orchestration(void) {
  const char *e = link_abi_getenv("XLANG_ASM_STRICT_ORCHESTRATION");
  return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

/** parser 自举白名单条目：{ name, len }，minimal/full 数组须同一 typedef（MSYS2 -Wincompatible-pointer-types）。 */
typedef struct {
  const char *name;
  int32_t len;
} asm_boot_parse_sym_t;

/** 非 0 表示入口源码过大，merge/library typeck 等应跳过（runtime.c）。 */
extern int32_t driver_typeck_skip_large_entry(void);

/** 前向声明：parser 自举判定（定义在 asm_module_is_pipeline_selfhost 之后）。 */
static int32_t asm_module_is_parser_selfhost(struct ast_Module *m);

/**
 * SKIP_TYPECK 全桩模式下仍须保留真实机器码的入口（实验 asm-only 链与 xlang_asm 烟囱测试依赖）。
 * 返回 1 表示该函数不应被 asm_skip_heavy 桩掉。
 * 大模块（如 backend.x）自身也定义 asm_codegen_ast，若对其完整 emit 会在宿主栈上 abort。
 */
static int32_t asm_skip_typeck_entry_whitelist(struct ast_Module *m, int32_t func_index) {
  static const struct {
    const char *name;
    int32_t len;
    int32_t allow_on_large_entry;
  } k_keep[] = {
      /** parse_into_with_init_buf 真 emit 深栈 SIGSEGV；build 链由 parser.o / C alias 提供。 */
      {"pipeline_impl_run_all", 21, 1},
      {"run_x_pipeline_impl", 19, 1},
      {"pipeline_impl_should_skip_codegen", 33, 1},
      {"pipeline_impl_phase_parse_load", 30, 1},
      {"pipeline_impl_phase_parse_only", 30, 1},
      {"pipeline_impl_phase_load_deps", 29, 1},
      /** typecheck 可单独 whitelist；phase_codegen 会 139。 */
      {"pipeline_impl_typecheck", 23, 1},
      {"pipeline_impl_codegen_deps", 26, 1},
      {"pipeline_impl_codegen_entry", 27, 1},
      /** codegen_chain 替代 phase_codegen（后者单独 emit 139）。 */
      {"pipeline_impl_codegen_chain", 27, 1},
      /** parser.x：strict 链 pipeline.parse_into_with_init_buf 依赖 parser.parse_into_buf 真机器码。 */
      {"parse_into_init", 15, 1},
      {"parse_into_set_main_index", 25, 1},
      {"collect_imports_buf", 19, 1},
      {"parse_into_buf", 14, 1},
      /** 大入口（>150KiB）上 typeck/asm 入口完整 emit 会栈溢出；SKIP 桩即可，编库不跑这些符号。 */
      {"typeck_x_ast", 12, 0},
      {"typeck_x_ast_library", 20, 0},
      {"asm_codegen_ast", 15, 0},
      /** main.x build_asm/main.o：entry 须真 emit（WPO root + crt0 链）。 */
      {"entry", 5, 1},
  };
  int32_t k;
  int32_t large_entry;
  if (!m || func_index < 0)
    return 0;
  /**
   * parser.x 自举编 module 时勿 whitelist 真 emit（parse_into_init 等会 expr emit 失败）；
   * strict 链 parse_into_* 由 pipeline_x partial / C alias 提供。
   * XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1：experimental 编 parser_parse_bootstrap.o 须 parse_into* 真 emit。
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
 * strict asm 编排：本 TU 不 emit 该函数体/标签，call 走 Mach-O/ELF reloc 链 C alias。
 * 若仍落本地符号，ld -r partial 内 bl 会绑定到错误 asm 实现（typecheck if/else 不完整 → null module）。
 */
int32_t asm_orchestration_extern_only_func(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0)
    return 0;
  /** 默认 B-strict 链用 build_asm pipeline.o 真 emit；仅 C 编排实验链才 extern-only。 */
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

/** 当前 asm codegen 的 PipelineDepCtx；backend.x 在 emit 循环前设置，供 ENTRY_MODULE_ONLY 入口 -o 判定。 */
static struct ast_PipelineDepCtx *g_asm_skip_pipeline_ctx;

void asm_skip_heavy_set_pipeline_ctx(struct ast_PipelineDepCtx *ctx) {
  g_asm_skip_pipeline_ctx = ctx;
}

/** XLANG_ASM_ENTRY_EMIT_HEAVY=1 时 ENTRY_MODULE_ONLY 真 emit（typeck 第二遍）；仅跳过 pipeline typecheck。 */
static int32_t asm_env_entry_emit_heavy(void) {
  const char *e = link_abi_getenv("XLANG_ASM_ENTRY_EMIT_HEAVY");
  return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

#include "pipeline_asm_selfhost.c"

/** 函数名前缀匹配（module func 池按字节比较）。 */
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

#include "pipeline_asm_emit_heavy_safe_helper.c"


#include "pipeline_asm_thin_delegate.c"


#include "pipeline_asm_parser_emit_heavy.c"


#include "pipeline_asm_skip_dispatch.c"

#include "pipeline_asm_diag.c"

#include "pipeline_asm_wpo.c"

/** bootstrap 链接 glue：pipeline 编排 / asm scope / typeck 指针写槽（误 revert 后补全）。 */
#include "ast_pool_bootstrap_glue.c"
