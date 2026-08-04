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

/** 调试：asm 单编大模块时在 stderr 打印当前函数名（XLANG_ASM_FUNC_TRACE=1）。 */
void asm_diag_trace_func_idx(int32_t func_idx, uint8_t *name, int32_t name_len);

void asm_diag_trace_func(uint8_t *name, int32_t name_len) {
  asm_diag_trace_func_idx(-1, name, name_len);
}

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

/** typeck EMIT_HEAVY 第二遍：按名判定可安全真 emit 的小 helper（扩 __text 过 8KiB）。 */
static int32_t asm_typeck_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index) {
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
static int32_t asm_pipeline_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index) {
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
static int32_t asm_driver_compile_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index) {
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
static int32_t asm_skip_heavy_backend_m8_helper_keep(struct ast_Module *m, int32_t func_index) {
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
static int32_t asm_skip_heavy_backend_helper_keep(struct ast_Module *m, int32_t func_index) {
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

/**
 * M8-tail：backend.x 薄包装 X 名 → C glue/partial 委托符号。
 * 首遍 SKIP 桩路径 emit bl（非 ret0），扩 build_asm/backend.o __text。
 */
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
int32_t asm_backend_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
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
int32_t asm_pipeline_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
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

/** M8-tail：parser.x 薄包装 X 名 → parser_asm_thin_c.c *_glue 或 pipeline_glue *_c（EMIT_HEAVY bl 扩 __text）。
 * slot_fallback / safe_helper 真 emit：collect_imports_buf / parse_one_function_library_buf 等。 */
static const AsmBackendThinDelegateRow k_asm_parser_thin_delegate[] = {
    {"collect_imports_buf", 19, "parser_collect_imports_buf_glue", 31},
    {"advance_past_cond_rparen_into", 29, "parser_advance_past_cond_rparen_into_glue", 41},
    {"advance_past_stmt_semicolon_into", 32, "parser_advance_past_stmt_semicolon_into_glue", 44},
    {"alloc_pointee_type_ref_from_tok", 31, "parser_alloc_pointee_type_ref_from_tok_glue", 43},
    {"append_block_lets_from_res", 26, "parser_append_block_lets_from_res_glue", 38},
    {"body_skip_let_const_then_if_buf", 31, "parser_body_skip_let_const_then_if_buf_glue", 43},
    {"body_skip_let_const_then_if", 27, "parser_body_skip_let_const_then_if_glue", 39},
    {"body_skip_let_const_then_if_into", 32, "parser_body_skip_let_const_then_if_into_glue", 44},
    {"collect_imports", 15, "parser_collect_imports_glue", 27},
    {"copy_lex_from_import_into", 25, "parser_lex_copy_from_import_into_glue", 38},
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


/** parser EMIT_HEAVY 第二遍：槽位 fallback 上限（>16 无增量；2026-06-14 提至 16）。 */
#define ASM_EMIT_HEAVY_PARSER_SLOT_MAX 16

/** XLANG_ASM_DEBUG=1 时打印 parser EMIT_HEAVY 真 emit 决策（定位 seed_mega SIGSEGV）。 */
static void asm_parser_emit_heavy_dbg_real(struct ast_Module *m, int32_t fi, const char *why) {
  uint8_t fn[128];
  int32_t fl;
  if (!link_abi_getenv("XLANG_ASM_DEBUG") || !m || fi < 0 || !why)
    return;
  fl = pipeline_module_func_name_len_at(m, fi);
  pipeline_module_func_name_copy64(m, fi, fn);
  fprintf(stderr, "xlang: parser REAL_EMIT fi=%d fn=%.*s why=%s\n", fi, (int)(fl > 127 ? 127 : fl), fn, why);
  fflush(stderr);
}

/** 调试/二分：XLANG_PARSER_EMIT_HEAVY_BISECT_N=N 上限 func_index；STUB_ONLY=1 仅 delegate 桩。 */
static int32_t asm_parser_emit_heavy_bisect_max_index(void) {
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

/** XLANG_PARSER_EMIT_HEAVY_SLOT_MAX=N 覆盖槽位 fallback 上限（默认 8）。 */
static int32_t asm_parser_emit_heavy_slot_max(void) {
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

/**
 * XLANG_ASM_PARSER_MEGA_BISECT=<name>：单项 mega 跳过 ret0 桩以 X 真 emit（bisect 门禁用）。
 */
static int32_t asm_parser_mega_bisect_skip_stub(struct ast_Module *m, int32_t func_index, const char *name,
                                                int32_t len) {
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
  return pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)name, len);
}

/**
 * PARSE_BOOTSTRAP_EMIT 时 mega 入口是否允许 X 真 emit；MINIMAL 仅 parse_into_init / set_main_index。
 */
static int32_t asm_parser_bootstrap_mega_emit_allowed(struct ast_Module *m, int32_t func_index, const char *name,
                                                      int32_t len) {
  static const asm_boot_parse_sym_t k_min[] = {
      {"parse_into_init", 15},
      {"parse_into_set_main_index", 25},
  };
  static const asm_boot_parse_sym_t k_full[] = {
      {"parse_into_buf", 14},
      {"parse_into", 10},
      {"parse_into_init", 15},
      {"parse_into_set_main_index", 25},
      {"collect_imports_buf", 19},
  };
  const asm_boot_parse_sym_t *k;
  int32_t kn;
  int32_t i;
  if (!m || func_index < 0 || link_abi_getenv("XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT") == NULL)
    return 0;
  if (!pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)name, len))
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

/**
 * parser.x EMIT_HEAVY 第二遍：巨型 parse_into/expr 入口 ret0 桩（strict 链由 parser.o / C alias 提供）。
 * XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1：experimental 重链用 ./xlang 编 parser 真 parse_into*（仅 bootstrap .o，非 gate EMIT_HEAVY）。
 */
static int32_t asm_skip_heavy_parser_mega_entry(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_MEGA_EQ(n, l)                                                                                           \
  do {                                                                                                                 \
    if (asm_parser_mega_bisect_skip_stub(m, func_index, (n), (l)))                                                     \
      break;                                                                                                           \
    if (asm_parser_bootstrap_mega_emit_allowed(m, func_index, (n), (l)))                                               \
      break;                                                                                                           \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(n), (l)))                                        \
      return 1;                                                                                                        \
  } while (0)
#define PARSER_MEGA_PFX(pfx, plen)                                                                                     \
  do {                                                                                                                 \
    if (pipeline_module_func_name_has_prefix_at(m, func_index, (pfx), (int32_t)(plen)))                                \
      return 1;                                                                                                        \
  } while (0)
  PARSER_MEGA_EQ("parse_into_buf", 14);
  PARSER_MEGA_EQ("parse_into", 10);
  PARSER_MEGA_EQ("parse", 5);
  PARSER_MEGA_EQ("parse_one_function_impl", 23);
  PARSER_MEGA_EQ("parse_expr_into", 15);
  PARSER_MEGA_EQ("parse_block_into", 16);
  PARSER_MEGA_EQ("parse_body_lets_into", 20);
  /** parse_at_simd_builtin / finish_struct_lit / leading_int_as glue 已迁 tier4c safe。 */
  /** parse_if_* / parse_match_* glue 薄包装已迁 tier4 safe；勿 mega ret0 桩。 */
  /** 表达式 precedence 链（parse_primary/addsub/…_into）走 thin delegate 或 X 真 emit；勿 PFX mega ret0 桩。 */
#undef PARSER_MEGA_EQ
#undef PARSER_MEGA_PFX
  return 0;
}

/**
 * parser EMIT_HEAVY 第二遍：须 ret0 桩（X 真 emit Segfault / code_len 爆炸）；勿 safe_helper 白名单。
 */
static int32_t asm_parser_emit_heavy_force_stub(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_STUB_EQ(n, l)                                                                                           \
  do {                                                                                                                 \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(n), (l)))                                        \
      return 1;                                                                                                        \
  } while (0)
#define PARSER_STUB_PFX(pfx, plen)                                                                                     \
  do {                                                                                                                 \
    if (pipeline_module_func_name_has_prefix_at(m, func_index, (pfx), (int32_t)(plen)))                                \
      return 1;                                                                                                        \
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
  /** parse_peek_function_name_buf 已迁 tier4 safe（单行 bl→glue X emit OK）。 */
  /** parser_token_is_label_start：勿入 safe_helper（单独即 elf_ec=-1）；仅 thin_delegate→glue。 */
#undef PARSER_STUB_EQ
#undef PARSER_STUB_PFX
  return 0;
}

/**
 * parser EMIT_HEAVY 第二遍：按名判定可安全 X 真 emit 的小 helper（扩 __text；名长须与 module 表一致）。
 */
static int32_t asm_parser_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_SAFE_EQ(n, l)                                                                                           \
  do {                                                                                                                 \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(n), (l)))                                        \
      return 1;                                                                                                        \
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
  /** LexerResult/CollectImportsResult 字段读：slice 路径须 glue bl（X 真 emit 内调 lexer_next_into → elf_ec=-1）。 */
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
  /** tier4 selective X emit：单行 bl→glue（alloc/wrap_in_return X 真 emit → elf_ec=-1）。 */
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
  /** *_into_buf：parser_slice_from_buf + bl *_into（13al；勿 lexer_next_buf X 深循环）。 */
  PARSER_SAFE_EQ("skip_one_enum_into_buf", 22);
  PARSER_SAFE_EQ("skip_one_struct_into_buf", 24);
  PARSER_SAFE_EQ("skip_one_trait_into_buf", 23);
  PARSER_SAFE_EQ("skip_one_impl_into_buf", 22);
  PARSER_SAFE_EQ("skip_one_extern_into_buf", 24);
  PARSER_SAFE_EQ("skip_one_function_full_into_buf", 31);
  PARSER_SAFE_EQ("skip_one_enum_register_into_buf", 31);
  PARSER_SAFE_EQ("parse_one_extern_and_add_into_buf", 33);
  /** *_buf：parser_slice_from_buf + bl slice 路径（13bc；深循环仍在 C glue）。 */
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
  /** slice 兼容包装 / glue 单行桩（扩 __text 有限；勿 lexer_next_into X 体）。 */
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
  /** tier3a（21 项）：slice 非 _buf；+1180B __text。 */
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
  /** tier3b（69 项）：跳过 parser_token_is_label_start（elf_ec=-1）；+936B __text。 */
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
  /** tier4b：mega→safe glue 薄包装（if/match slice 路径）。 */
  PARSER_SAFE_EQ("parse_if_stmt_into", 18);
  PARSER_SAFE_EQ("parse_if_expr_into", 18);
  PARSER_SAFE_EQ("parse_match_into", 16);
  PARSER_SAFE_EQ("parse_match_subject_into", 24);
  /** tier4c：mega→safe glue 薄包装（simd / struct_lit / leading_int_as）。 */
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

/** delegate 表内仍有 X 体：强制真 emit（须先于 thin_delegate）；当前全禁（experimental emit SIGSEGV）。 */
static int32_t asm_parser_emit_heavy_x_body_keep(struct ast_Module *m, int32_t func_index) {
  (void)m;
  (void)func_index;
  return 0;
#if 0
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_KEEP_EQ(n, l)                                                                                           \
  do {                                                                                                                 \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(n), (l)))                                        \
      return 1;                                                                                                        \
  } while (0)
  PARSER_KEEP_EQ("struct_layout_first_name_match_idx", 34);
  PARSER_KEEP_EQ("struct_layout_name_exists_arr", 29);
  PARSER_KEEP_EQ("struct_layout_placeholder_idx", 29);
#undef PARSER_KEEP_EQ
  return 0;
#endif
}

/** 槽位 fallback：小体 X 真 emit（>ASM_EMIT_HEAVY_PARSER_SLOT_MAX 仍桩化）。 */
static int32_t asm_parser_emit_heavy_slot_fallback_ok(struct ast_ASTArena *arena, int32_t body_ref, int32_t slots) {
  (void)arena;
  if (body_ref <= 0)
    return 0;
  return slots <= ASM_EMIT_HEAVY_PARSER_SLOT_MAX;
}

/** 查 func 是否在 k_asm_parser_thin_delegate 表（EMIT_HEAVY bl→C glue）。 */
static int32_t asm_parser_func_is_thin_delegate(struct ast_Module *m, int32_t func_index) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
  nrows = (int32_t)(sizeof(k_asm_parser_thin_delegate) / sizeof(k_asm_parser_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_parser_thin_delegate[i].x_name,
                                           k_asm_parser_thin_delegate[i].x_len))
      return 1;
  }
  return 0;
}

/**
 * 查 parser 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_parser_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                 int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0)
    return 0;
  /** 表内均为 parser.x 符号；勿绑 asm_module_is_parser_selfhost（marker 偶发缺失时 delegate 仍须 bl）。 */
  nrows = (int32_t)(sizeof(k_asm_parser_thin_delegate) / sizeof(k_asm_parser_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_parser_thin_delegate[i].x_name,
                                           k_asm_parser_thin_delegate[i].x_len)) {
      if (k_asm_parser_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_parser_thin_delegate[i].c_name, (size_t)k_asm_parser_thin_delegate[i].c_len);
      out[k_asm_parser_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_parser_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}

/**
 * parser EMIT_HEAVY：同模块 X 真 emit 调 skip/delegate 目标时重定向 bl glue（避免 U x 名）。
 * 成功写 out/out_len 并返回 1。
 */
int32_t asm_parser_emit_heavy_resolve_call_to_glue(struct ast_Module *m, uint8_t *name, int32_t name_len,
                                                    uint8_t *out, int32_t out_cap, int32_t *out_len) {
  int32_t fi;
  if (!m || !name || name_len <= 0 || !out || !out_len || out_cap <= 0)
    return 0;
  *out_len = 0;
  if (!asm_module_is_parser_emit_heavy(m))
    return 0;
  for (fi = 0; fi < m->num_funcs; fi++) {
    if (pipeline_module_func_name_equal_at(m, fi, name, name_len) == 0)
      continue;
    if (asm_parser_m8_tail_thin_delegate_c_name(m, fi, out, out_cap, out_len) != 0)
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_module_reset_parse_counters", 36)) {
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

/**
 * parser EMIT_HEAVY：callee 为本模块已定义（非 extern）func 时返回 1。
 * X 真 emit 调 stub/同模块 helper 应 enc_call→patch，勿 elf_add_reloc 产生 unexpected U。
 */
int32_t asm_parser_emit_heavy_callee_is_same_module_local(struct ast_Module *m, uint8_t *name, int32_t name_len) {
  int32_t fi;
  if (!m || !name || name_len <= 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
  for (fi = 0; fi < m->num_funcs; fi++) {
    if (pipeline_module_func_name_equal_at(m, fi, name, name_len) == 0)
      continue;
    if (pipeline_asm_module_func_is_extern_at(m, fi) != 0)
      return 0;
    return 1;
  }
  return 0;
}

/** M8-tail：driver compile 薄 bl 表已空；run_compiler_full_x* 堆 state + X post_parse 真 emit。 */
static const AsmBackendThinDelegateRow k_asm_driver_thin_delegate[] = {
};

/**
 * 查 driver/compile.x 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_driver_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
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
int32_t asm_typeck_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
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

/**
 * M8-tail：backend 薄包装 helper 按名真 emit，须先于 #87+ 索引桩（emit_block_body_elf #179 等）。
 * 不含 fold_/asm_import_ 等前缀体，避免 Abort 带内误放行大函数。
 */
static int32_t asm_skip_heavy_backend_m8_tail_thin_keep(struct ast_Module *m, int32_t func_index) {
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
static int32_t asm_skip_heavy_typeck_helper_keep(struct ast_Module *m, int32_t func_index) {
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
static int32_t asm_skip_heavy_backend_mega_entry(struct ast_Module *m, int32_t func_index) {
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
static int32_t asm_skip_heavy_typeck_mega_entry(struct ast_Module *m, int32_t func_index) {
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

/**
 * out 至少 24 字节；*out_len 为 NUL 终止名长（不含 NUL）。
 */
void asm_empty_text_stub_label(struct ast_Module *m, uint8_t *out, int32_t out_cap, int32_t *out_len) {
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
  if (m && m->num_funcs > 0) {
    for (i = 0; i < m->num_funcs; i++) {
      nl = pipeline_module_func_name_len_at(m, i);
      for (k = 0; k < nl; k++)
        h = (uint32_t)((h ^ (uint8_t)pipeline_module_func_name_byte_at(m, i, k)) * 16777619u);
    }
  } else {
    h ^= (uint32_t)(m ? m->num_imports : 0);
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

int32_t asm_skip_heavy_module_func_body(struct ast_Module *m, struct ast_ASTArena *arena, int32_t func_index) {
  int32_t body_ref;
  int32_t slots;
  int32_t slot_threshold;
  if (!m || func_index < 0)
    return 0;
  /**
   * 用户程序（非 parser/typeck/backend/pipeline/driver 自举模块）：须完整 emit 真机码。
   * 须先于 XLANG_ASM_BUILD_SKIP_TYPECK 桩分支；否则 return42 等单文件 -o 被 ret0 桩化或 WPO 跳过。
   */
  if (!asm_module_is_compiler_selfhost(m))
    return 0;
  /**
   * ast.x 首遍 SKIP：除 whitelist 外一律 ret0 桩（含 extern 占位；真符号由 ast_pool/pipeline_x 提供）。
   */
  if (asm_module_is_ast_selfhost(m) && asm_env_build_skip_typeck() != 0 && asm_env_entry_emit_heavy() == 0) {
    if (asm_skip_typeck_entry_whitelist(m, func_index) != 0)
      return 0;
    return 1;
  }
  /**
   * 用户 import+exe（asm_entry_module_only、非大入口）：须完整 emit 入口模块，禁止 ret0 桩。
   * build_xlang_asm（XLANG_ASM_BUILD_SKIP_TYPECK）同为 ENTRY_MODULE_ONLY，须走下方白名单/桩路径，勿全量 emit。
   */
  if (g_asm_skip_pipeline_ctx != NULL &&
      pipeline_dep_ctx_asm_entry_module_only(g_asm_skip_pipeline_ctx) != 0 &&
      pipeline_dep_ctx_use_asm_backend(g_asm_skip_pipeline_ctx) != 0 &&
      driver_typeck_skip_large_entry() == 0 &&
      asm_env_build_skip_typeck() == 0 &&
      asm_env_entry_emit_heavy() == 0) {
    return 0;
  }
  /**
   * build_xlang_asm：XLANG_ASM_BUILD_SKIP_TYPECK 默认桩 emit（非 extern/非白名单 ret 0）。
   * XLANG_ASM_ENTRY_EMIT_HEAVY=1 时仅跳过 pipeline typecheck，emit 仍走槽位阈值真机码。
   */
  if (asm_env_build_skip_typeck() != 0 && asm_env_entry_emit_heavy() == 0) {
    if (pipeline_asm_module_func_is_extern_at(m, func_index) != 0)
      return 0;
    if (asm_skip_typeck_entry_whitelist(m, func_index) != 0)
      return 0;
    return 1;
  }
  /* 小模块（lexer 等 ~21 func）：首遍 SKIP 桩前 10 项；EMIT_HEAVY 第二遍改走 driver/pipeline 按名白名单。 */
  if (asm_env_build_skip_typeck() != 0 && asm_env_entry_emit_heavy() == 0 && m->num_funcs > 0 &&
      m->num_funcs <= 32 && func_index < 10)
    return 1;
  /** 首遍 SKIP 桩：mega check_* 勿真 emit；EMIT_HEAVY 第二遍改走下方按名/索引桩。 */
  if (asm_env_entry_emit_heavy() == 0 &&
      (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr", 10) ||
       pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr_impl", 15) ||
       pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block", 11) ||
       pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block_impl", 16)))
    return 1;
  /**
   * ENTRY_EMIT_HEAVY 第二遍：放宽槽位阈值；桩化 mega typecheck/diag 入口（按符号名）。
   * typeck 大入口：#90–117 Abort 区间（索引+按名桩）；#118+ 真 emit。
   * backend 大入口：#87–189 索引桩 + emit_expr/asm_codegen_ast 等按名 mega 桩；其余 helper 真 emit。
   * 非 typeck/backend 大模块且 func≥160：func#72+ 仍粗筛桩化。
   */
  if (asm_env_entry_emit_heavy() != 0) {
    int32_t typeck_ndef = asm_module_is_typeck_selfhost(m) ? asm_module_num_defined_funcs(m) : 0;
    int32_t typeck_ord = asm_module_defined_func_ordinal(m, func_index);
    /**
     * parser.x EMIT_HEAVY 第二遍：须先于 typeck ndef 启发式（parser ndef≈130 与 typeck 重叠）。
     */
    if (asm_module_is_parser_emit_heavy(m)) {
      if (asm_skip_heavy_parser_mega_entry(m, func_index) != 0)
        return 1;
      /** STUB_ONLY / BISECT_N=0：仅 thin delegate 桩。 */
      if (asm_parser_emit_heavy_bisect_max_index() == 0)
        return 1;
      /**
       * safe_helper 须先于 force_stub：onefunc_result_pool_ptr 等被 onefunc_ 前缀误桩，
       * 白名单内小 helper 仍须 X 真 emit 扩 __text。
       */
      if (asm_parser_emit_heavy_safe_helper(m, func_index) != 0) {
        asm_parser_emit_heavy_dbg_real(m, func_index, "safe_helper");
        return 0;
      }
      if (asm_parser_emit_heavy_force_stub(m, func_index) != 0)
        return 1;
      /** thin delegate：薄包装 bl→C glue。 */
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
      /** 槽位 fallback：≤SLOT_MAX 小函数 X 真 emit（ExprKind 序已对齐 primary_slice）。 */
      return 0;
    }
    /**
     * typeck.x 合并 glue 后 ~160–180 已定义 func：#0–89 glue 桩；#90–117 按名小 helper；
     * #118–159 check_* 桩；#160+ typeck_x_ast mega 桩（序号均按非 extern ordinal）。
     */
    if (asm_module_is_typeck_selfhost(m) && typeck_ndef >= 160 && typeck_ndef <= 180) {
      if (typeck_ord < 0)
        return 1;
      if (asm_skip_heavy_typeck_mega_entry(m, func_index) != 0)
        return 1;
      /** safe_helper 须先于 ord #118–159 粗筛，否则 expr_type_ref 等无法 X 真 emit。 */
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      if (typeck_ord >= 118 && typeck_ord <= ASM_EMIT_HEAVY_TYPECK_INDEX_HI)
        return 1;
      /** 按名放行 layout/小 helper（须在 ordinal<90 粗筛之前，type_kind_ordinal 在 #0）。 */
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_kind_ordinal", 17))
        return 0;
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      if (typeck_ord < 90)
        return 1;
      return 1;
    }
    /** 瘦 typeck：safe_helper 白名单 + 槽位过关 X 真 emit；上限随 block helper 扩容（2026-06 ndef≈130）。 */
    if (typeck_ndef >= 75 && typeck_ndef <= 200 && !asm_module_is_backend_selfhost(m) &&
        !asm_module_is_parser_emit_heavy(m)) {
      int32_t body_ref_thin;
      int32_t slots_thin;
      if (typeck_ord < 0)
        return 1;
      if (asm_skip_heavy_typeck_mega_entry(m, func_index) != 0)
        return 1;
      /** merge_dep 须先于 safe_helper 粗筛（双循环槽位高；按名强制 X 真 emit）。 */
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
      if (slots_thin > ASM_EMIT_HEAVY_TYPECK_LAYOUT_SLOT_MAX)
        return 1;
      return 0;
    }
    /**
     * pipeline.x：编排经 asm_pipeline_emit_heavy_safe_helper 真 emit；C mega 仅 ast_pool/pipeline_glue 回退。
     * safe_helper 小函数 X 真 emit（S3 起步）。
     */
    if (asm_module_is_pipeline_selfhost(m)) {
      if (asm_pipeline_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 1;
    }
    /**
     * main.x：仅 entry 真 emit；其余 helper 走 SKIP 桩 + WPO 从 entry 建 reach。
     */
    if (asm_module_is_main_driver_selfhost(m)) {
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"entry", 5))
        return 0;
      return 1;
    }
    /**
     * driver/compile.x：parse_argv 分 helper + dispatch X 真 emit；run_compiler_full_x* 薄 bl→runtime impl_c。
     */
    if (asm_module_is_driver_compile_selfhost(m)) {
      if (asm_driver_compile_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 1;
    }
    /**
     * M8-tail：backend 薄包装 EMIT_HEAVY 仍 skip 桩 + bl→C（与 SKIP 首遍一致；勿真 emit 单行 X）。
     */
    if (asm_module_is_backend_selfhost(m) && asm_skip_heavy_backend_m8_tail_thin_keep(m, func_index) != 0)
      return 1;
    /**
     * 白名单须先于 mega/索引桩：layout/arch helper 按名保留真 emit（小槽位体）。
     * 合并 glue 后 num_funcs>150（~285 func）时勿 #0–86 真 emit，否则宿主编 backend.x SIGSEGV。
     */
    if (asm_module_is_backend_selfhost(m) && m->num_funcs <= 150 &&
        (asm_skip_heavy_backend_helper_keep(m, func_index) != 0 ||
         asm_skip_heavy_backend_m8_helper_keep(m, func_index) != 0)) {
      body_ref = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref <= 0 ||
          asm_count_block_stack_slots(arena, body_ref) <= ASM_EMIT_HEAVY_BACKEND_HELPER_SLOT_MAX)
        return 0;
    }
    if (asm_module_is_typeck_selfhost(m) && asm_skip_heavy_typeck_helper_keep(m, func_index) != 0) {
      /** layout/metrics 小 helper 先于 Abort 索引带真 emit（合并 glue 后 #90 即为 type_kind_ordinal）。 */
      if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_", 14))
        return 1;
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_align", 20) ||
          pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_size", 19))
        return 1;
      if (func_index >= ASM_EMIT_HEAVY_TYPECK_INDEX_LO && func_index <= ASM_EMIT_HEAVY_TYPECK_INDEX_HI)
        return 1;
      body_ref = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref <= 0)
        return 0;
      if (asm_count_block_stack_slots(arena, body_ref) <= ASM_EMIT_HEAVY_TYPECK_LAYOUT_SLOT_MAX)
        return 0;
    }
    if (asm_skip_heavy_typeck_mega_entry(m, func_index) != 0)
      return 1;
    if (asm_skip_heavy_backend_mega_entry(m, func_index) != 0)
      return 1;
    /** typeck.x：ordinal #90–159 Abort 区间 ret0 桩（safe_helper 已 X 真 emit 的除外）。 */
    if (asm_module_is_typeck_selfhost(m) && typeck_ndef >= 90 && typeck_ord >= 0 &&
        typeck_ord >= ASM_EMIT_HEAVY_TYPECK_INDEX_LO && typeck_ord <= ASM_EMIT_HEAVY_TYPECK_INDEX_HI) {
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 1;
    }
    /** backend.x ~100 func：勿要求 num_funcs>=175，否则 #87+ 全走真 emit → 宿主栈 Abort。 */
    if (asm_module_is_backend_selfhost(m) && m->num_funcs >= 80) {
      int32_t be_hi = asm_emit_heavy_abort_hi();
      if (be_hi >= m->num_funcs)
        be_hi = m->num_funcs - 1;
      if (func_index >= asm_emit_heavy_abort_lo() && func_index <= be_hi)
        return 1;
    } else if (driver_typeck_skip_large_entry() != 0 && m->num_funcs >= 175) {
      if (func_index >= asm_emit_heavy_abort_lo() && func_index <= asm_emit_heavy_abort_hi())
        return 1;
    } else if (m->num_funcs >= 160 && func_index >= 72 && !asm_module_is_backend_selfhost(m) &&
               !asm_module_is_typeck_selfhost(m) && !asm_module_is_parser_emit_heavy(m)) {
      return 1;
    }
    body_ref = pipeline_module_func_body_ref_at(m, func_index);
    slot_threshold = ASM_EMIT_HEAVY_SLOT_THRESHOLD;
    /** backend #0–86 小 helper：放宽槽位；#87+ 索引/mega 桩后再收紧槽位阈值。 */
    if (asm_module_is_backend_selfhost(m) && func_index < ASM_EMIT_HEAVY_BACKEND_INDEX_LO) {
      slot_threshold = ASM_EMIT_HEAVY_SLOT_THRESHOLD;
    } else if ((asm_module_is_backend_selfhost(m) && m->num_funcs >= 80) ||
               (driver_typeck_skip_large_entry() != 0 && m->num_funcs >= 175))
      slot_threshold = ASM_EMIT_HEAVY_LARGE_BACKEND_SLOT_THRESHOLD;
    if (arena && body_ref > 0) {
      slots = asm_count_block_stack_slots(arena, body_ref);
      if (slots > slot_threshold)
        return 1;
    }
    /** backend/typeck 第二遍：backend 默认 ret0 桩；typeck 槽位过关则真 emit。 */
    if (asm_module_is_backend_selfhost(m))
      return 1;
    if (asm_module_is_typeck_selfhost(m)) {
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 0;
    }
    return 0;
  }
  /** 默认大模块：func_index>=72 粗筛（非 EMIT_HEAVY 第二遍；仅 compiler 自举）。 */
  if (m->num_funcs >= 160 && func_index >= 72)
    return 1;
  body_ref = pipeline_module_func_body_ref_at(m, func_index);
  if (arena && body_ref > 0) {
    slots = asm_count_block_stack_slots(arena, body_ref);
    if (slots > ASM_HEAVY_BODY_SLOT_THRESHOLD)
      return 1;
  }
  return 0;
}

/**
 * 读 XLANG_ASM_START_FUNC：跳过 module 中前 N 个函数（调试大模块 asm 单编 139）。
 * build_xlang_asm 须 env -u XLANG_ASM_START_FUNC；若 N>=num_funcs 则整模块无机器码、仅 8B 空 __text 桩。
 * XLANG_ASM_ALLOW_START_FUNC=1 时 build 路径也生效（手工二分 emit 用）。
 */
int32_t asm_diag_start_func_skip(void) {
  const char *e = link_abi_getenv("XLANG_ASM_START_FUNC");
  const char *allow = link_abi_getenv("XLANG_ASM_ALLOW_START_FUNC");
  char *end = NULL;
  long v;
  if (!e || e[0] == '\0')
    return 0;
  /* build_xlang_asm 默认清除 START_FUNC；未显式 ALLOW 时 ENTRY skip 模式忽略，避免 pipeline 56 func 全跳过。 */
  if ((allow == NULL || allow[0] == '\0' || allow[0] == '0') && asm_env_build_skip_typeck() != 0 &&
      link_abi_getenv("XLANG_ASM_ENTRY_MODULE_ONLY") != NULL) {
    const char *em = link_abi_getenv("XLANG_ASM_ENTRY_MODULE_ONLY");
    if (em && em[0] != '\0' && em[0] != '0')
      return 0;
  }
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return 0;
  if (v > 100000)
    return 100000;
  return (int32_t)v;
}

/** XLANG_ASM_BODY_TRACE=1 时打印函数体块规模，定位错误 body_ref 导致 fill/emit 崩溃。 */
void asm_diag_trace_func_body(struct ast_ASTArena *arena, int32_t body_ref) {
  const char *trace;
  struct ast_Block *b;
  if (!arena || body_ref <= 0)
    return;
  trace = link_abi_getenv("XLANG_ASM_BODY_TRACE");
  if (!trace || trace[0] == '\0' || trace[0] == '0')
    return;
  b = block_at(arena, body_ref);
  if (!b) {
    fprintf(stderr, "asm_body: ref=%d invalid\n", (int)body_ref);
    return;
  }
  fprintf(stderr,
          "asm_body: ref=%d consts=%d lets=%d loops=%d for=%d ifs=%d stmt_order=%d final_expr=%d\n",
          (int)body_ref, (int)b->num_consts, (int)b->num_lets, (int)b->num_loops, (int)b->num_for_loops,
          (int)b->num_if_stmts, (int)b->num_stmt_order, (int)b->final_expr_ref);
  fflush(stderr);
}

/** XLANG_ASM_BODY_TRACE=1：仅打印 body_ref 数值（在 pipeline_asm_module_func_body_ref_at 前后对照）。 */
void asm_diag_trace_body_ref(int32_t body_ref) {
  const char *trace = link_abi_getenv("XLANG_ASM_BODY_TRACE");
  if (!trace || trace[0] == '\0' || trace[0] == '0')
    return;
  fprintf(stderr, "asm_body_ref=%d\n", (int)body_ref);
  fflush(stderr);
}

/** XLANG_ASM_BODY_TRACE=1：emit 阶段标记（1=fill 后 2=prologue 后 3=emit_body 后）。 */
void asm_diag_trace_emit_phase(int32_t phase) {
  const char *trace = link_abi_getenv("XLANG_ASM_BODY_TRACE");
  if (!trace || trace[0] == '\0' || trace[0] == '0')
    return;
  fprintf(stderr, "asm_emit_phase=%d\n", (int)phase);
  fflush(stderr);
}

void asm_diag_trace_func_idx(int32_t func_idx, uint8_t *name, int32_t name_len) {
  const char *trace;
  int32_t i;
  if (!name || name_len <= 0)
    return;
  trace = link_abi_getenv("XLANG_ASM_FUNC_TRACE");
  if (!trace || trace[0] == '\0' || trace[0] == '0')
    return;
  if (func_idx >= 0)
    fprintf(stderr, "asm_trace: #%d ", (int)func_idx);
  else
    fprintf(stderr, "asm_trace: ");
  for (i = 0; i < name_len && i < 64; i++)
    fputc(name[i], stderr);
  fputc('\n', stderr);
  fflush(stderr);
}

void asm_ctx_fill_locals_block_tree(uint8_t *ctx, struct ast_ASTArena *arena, int32_t block_ref,
                                   int32_t *inout_next_offset, int32_t *inout_num_locals) {
  GrowVec stack;
  int32_t sp;
  int32_t cur;
  int32_t *pref;
  if (!ctx || !arena || !inout_next_offset || !inout_num_locals || block_ref <= 0)
    return;
  if (!grow_vec_init(&stack, sizeof(int32_t), AST_POOL_INIT_CAP))
    return;
  {
    int32_t visits = 0;
    asm_block_tree_push_ref(&stack, block_ref);
    while (stack.len > 0) {
      sp = stack.len - 1;
      pref = (int32_t *)grow_vec_at(&stack, sp);
      if (!pref)
        break;
      cur = *pref;
      stack.len = sp;
      if (cur <= 0 || cur > arena->num_blocks)
        continue;
      visits++;
      if (visits > 8192)
        break;
      asm_ctx_ensure_block_locals(ctx, arena, cur, inout_next_offset, inout_num_locals);
      asm_block_tree_push_children(arena, &stack, cur);
      /** MEM-C1：with_arena / region 子块 let 须与 wa 临时区同序登记，避免 arena@8 与 Vec 局部重叠。 */
      asm_block_tree_push_region_children(arena, &stack, cur);
    }
  }
  grow_vec_free(&stack);
}

/** backend.x：嵌套循环 break/continue 标签栈 sidecar（替代 AsmFuncCtx 内 512×2 字节数组，减栈帧）。 */
typedef struct {
  void *ctx;
  int used;
  int32_t depth;
  uint8_t break_stack[512];
  int32_t break_lens[8];
  uint8_t continue_stack[512];
  int32_t continue_lens[8];
} AsmLoopLabelsSidecar;

static AsmLoopLabelsSidecar g_asm_loop_sc[MAX_ASM_LOCALS_SIDECARS];

static AsmLoopLabelsSidecar *asm_loop_sidecar_get(uint8_t *ctx, int create) {
  int i;
  if (!ctx)
    return NULL;
  for (i = 0; i < MAX_ASM_LOCALS_SIDECARS; i++) {
    if (g_asm_loop_sc[i].used && g_asm_loop_sc[i].ctx == (void *)ctx)
      return &g_asm_loop_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_ASM_LOCALS_SIDECARS; i++) {
    if (!g_asm_loop_sc[i].used) {
      g_asm_loop_sc[i].ctx = (void *)ctx;
      g_asm_loop_sc[i].used = 1;
      g_asm_loop_sc[i].depth = 0;
      return &g_asm_loop_sc[i];
    }
  }
  return NULL;
}

/** 清空某 AsmFuncCtx 的循环标签栈。 */
void asm_ctx_loop_reset(uint8_t *ctx) {
  AsmLoopLabelsSidecar *sc = asm_loop_sidecar_get(ctx, 0);
  if (sc)
    sc->depth = 0;
}

/** 压入一层 break/continue 标签；depth>=8 时返回 -1。 */
int32_t asm_ctx_loop_push(uint8_t *ctx, uint8_t *exit_buf, int32_t exit_len, uint8_t *loop_buf, int32_t loop_len) {
  AsmLoopLabelsSidecar *sc;
  int32_t d, base, k, n, m;
  if (!ctx || !exit_buf || !loop_buf || exit_len < 0 || loop_len < 0)
    return -1;
  if (!(sc = asm_loop_sidecar_get(ctx, 1)))
    return -1;
  d = sc->depth;
  if (d >= 8)
    return -1;
  base = d * 64;
  n = exit_len > 64 ? 64 : exit_len;
  for (k = 0; k < n; k++)
    sc->break_stack[base + k] = exit_buf[k];
  sc->break_lens[d] = exit_len;
  m = loop_len > 64 ? 64 : loop_len;
  for (k = 0; k < m; k++)
    sc->continue_stack[base + k] = loop_buf[k];
  sc->continue_lens[d] = loop_len;
  sc->depth = d + 1;
  return 0;
}

/** 弹出一层；若仍有外层则把其 break/continue 写入 out（长度经 *len_out 返回）。 */
void asm_ctx_loop_pop(uint8_t *ctx, uint8_t *break_out, int32_t break_cap, int32_t *break_len_out,
                      uint8_t *cont_out, int32_t cont_cap, int32_t *cont_len_out) {
  AsmLoopLabelsSidecar *sc;
  int32_t d, prev, base, k, bl, cl, bn, cn;
  if (break_len_out)
    *break_len_out = 0;
  if (cont_len_out)
    *cont_len_out = 0;
  if (!ctx || !(sc = asm_loop_sidecar_get(ctx, 0)) || sc->depth <= 0)
    return;
  sc->depth--;
  d = sc->depth;
  if (d <= 0)
    return;
  prev = d - 1;
  base = prev * 64;
  bl = sc->break_lens[prev];
  cl = sc->continue_lens[prev];
  if (break_out && break_len_out && break_cap > 0) {
    bn = bl > break_cap - 1 ? break_cap - 1 : bl;
    for (k = 0; k < bn; k++)
      break_out[k] = sc->break_stack[base + k];
    *break_len_out = bl;
  }
  if (cont_out && cont_len_out && cont_cap > 0) {
    cn = cl > cont_cap - 1 ? cont_cap - 1 : cl;
    for (k = 0; k < cn; k++)
      cont_out[k] = sc->continue_stack[base + k];
    *cont_len_out = cl;
  }
}

/** 当前循环标签栈深度。 */
int32_t asm_ctx_loop_depth(uint8_t *ctx) {
  AsmLoopLabelsSidecar *sc = asm_loop_sidecar_get(ctx, 0);
  return sc ? sc->depth : 0;
}

/**
 * emit_block_body 迭代续延：if-then 后挂起 (block_ref, stmt_i) 与 end 标签，避免 emit_block_body↔if-then 递归。
 */
typedef struct {
  int32_t block_ref;
  int32_t stmt_i;
  int32_t end_label_len;
  uint8_t end_label[128];
} AsmBlockEmitCont;

static AsmBlockEmitCont g_asm_be_cont[24];
static int32_t g_asm_be_cont_depth;

/** 清空 if 续延栈（每个顶层 emit_block_body 入口调用一次）。 */
void asm_be_cont_reset(void) {
  g_asm_be_cont_depth = 0;
}

/**
 * 挂起当前块在 stmt_i 处，保存 if end 标签；随后切换至 then 块 stmt_i=0。
 * end_len 须 <= 64；end_len==0 表示 then 结束后不 jmp merge（由 resume 直接恢复 stmt_i）。栈满返回 -1。
 */
int32_t asm_be_cont_suspend(int32_t block_ref, int32_t stmt_i, uint8_t *end_lbl, int32_t end_len) {
  AsmBlockEmitCont *c;
  int32_t k, n;
  if (g_asm_be_cont_depth >= 24 || !end_lbl || end_len < 0)
    return -1;
  c = &g_asm_be_cont[g_asm_be_cont_depth++];
  c->block_ref = block_ref;
  c->stmt_i = stmt_i;
  if (end_len == 0) {
    c->end_label_len = 0;
    return 0;
  }
  n = end_len > 64 ? 64 : end_len;
  for (k = 0; k < n; k++)
    c->end_label[k] = end_lbl[k];
  c->end_label_len = end_len;
  return 0;
}

/**
 * 弹出最内层续延；out_block 与 out_stmt_i 为恢复点；end 标签写入 out_end（cap 字节，out_end_len 为原长）。
 * 无续延返回 0；有续延返回 1。
 */
int32_t asm_be_cont_resume(int32_t *out_block, int32_t *out_stmt_i, uint8_t *out_end, int32_t end_cap, int32_t *out_end_len) {
  AsmBlockEmitCont *c;
  int32_t k, n;
  if (g_asm_be_cont_depth <= 0)
    return 0;
  c = &g_asm_be_cont[--g_asm_be_cont_depth];
  if (out_block)
    *out_block = c->block_ref;
  if (out_stmt_i)
    *out_stmt_i = c->stmt_i;
  if (out_end_len)
    *out_end_len = c->end_label_len;
  if (out_end && end_cap > 0 && out_end_len) {
    n = c->end_label_len;
    if (n > end_cap - 1)
      n = end_cap - 1;
    for (k = 0; k < n; k++)
      out_end[k] = c->end_label[k];
  }
  return 1;
}

/** 当前 if 续延栈深度（调试）。 */
int32_t asm_be_cont_depth(void) {
  return g_asm_be_cont_depth;
}

/**
 * WPO v0（asm 后端 DCE）：按 typeck 解析后的 call graph 标记 reachable，emit 时跳过 dead export。
 * 与 codegen.c 的 codegen_wpo_reach 语义对齐，但 keyed by (ast_Module*, func_index) 供 .x asm 后端查询。
 */
#define ASM_WPO_MAX_FUNCS 1024
#define ASM_WPO_MAX_MODS 64
#define ASM_WPO_MAX_EDGES 4096

/** WPO call 边解析：与 backend emit_call 同读 pipeline_expr_*（勿裸 *Expr 字段，避免池布局偏差）。 */
extern int32_t pipeline_expr_call_callee_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(struct ast_ASTArena *a, int32_t expr_ref);
extern void pipeline_expr_var_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_expr_call_resolved_func_index_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_call_resolved_dep_index_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_unary_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref);

typedef struct {
  int32_t valid;
  struct ast_Module *entry;
  struct ast_PipelineDepCtx *dep_ctx;
  struct ast_Module *mods[ASM_WPO_MAX_MODS];
  struct ast_ASTArena *arenas[ASM_WPO_MAX_MODS];
  int32_t nmods;
  struct ast_Module *func_mod[ASM_WPO_MAX_FUNCS];
  int32_t func_fi[ASM_WPO_MAX_FUNCS];
  int32_t nfuncs;
  int32_t root_id;
  unsigned char reachable[ASM_WPO_MAX_FUNCS];
  struct {
    int32_t from;
    int32_t to;
  } edges[ASM_WPO_MAX_EDGES];
  int32_t nedges;
} AsmWpoReachState;

static AsmWpoReachState g_asm_wpo;
/** PGO-Lite：root + 直接 callee（BFS depth≤1）标记为 hot emit 候选。 */
static unsigned char g_asm_wpo_pgo_hot[ASM_WPO_MAX_FUNCS];
/** PGO-Lite S2：自 root 的静态 call-depth（BFS）；未 reach 保持 -1。 */
static int32_t g_asm_wpo_pgo_depth[ASM_WPO_MAX_FUNCS];
/** 当前 module 的 emit 顺序（func_index 表；PGO 时按 depth 升序）。 */
static struct ast_Module *g_asm_wpo_pgo_emit_mod;
static int32_t g_asm_wpo_pgo_emit_order[ASM_WPO_MAX_FUNCS];
static int32_t g_asm_wpo_pgo_emit_n;

/** 清空 asm WPO 状态；elf emit 结束或失败时调用。 */
void pipeline_asm_wpo_reach_clear(void) {
  memset(&g_asm_wpo, 0, sizeof(g_asm_wpo));
  memset(g_asm_wpo_pgo_hot, 0, sizeof(g_asm_wpo_pgo_hot));
  memset(g_asm_wpo_pgo_depth, 0xff, sizeof(g_asm_wpo_pgo_depth));
  g_asm_wpo_pgo_emit_mod = NULL;
  g_asm_wpo_pgo_emit_n = 0;
}

/** 在 mods[] 中查找 module 下标；未注册返回 -1。 */
static int32_t asm_wpo_mod_index(struct ast_Module *m) {
  int32_t i;
  if (!m)
    return -1;
  for (i = 0; i < g_asm_wpo.nmods; i++) {
    if (g_asm_wpo.mods[i] == m)
      return i;
  }
  return -1;
}

/** 注册 module+arena；已存在则仅返回下标。 */
static int32_t asm_wpo_register_mod(struct ast_Module *m, struct ast_ASTArena *a) {
  int32_t ix;
  if (!m || !a)
    return -1;
  ix = asm_wpo_mod_index(m);
  if (ix >= 0)
    return ix;
  if (g_asm_wpo.nmods >= ASM_WPO_MAX_MODS)
    return -1;
  g_asm_wpo.mods[g_asm_wpo.nmods] = m;
  g_asm_wpo.arenas[g_asm_wpo.nmods] = a;
  return g_asm_wpo.nmods++;
}

/** (module, func_index) → 全局 func id；未注册返回 -1。 */
static int32_t asm_wpo_func_id_of(struct ast_Module *m, int32_t fi) {
  int32_t i;
  if (!m || fi < 0)
    return -1;
  for (i = 0; i < g_asm_wpo.nfuncs; i++) {
    if (g_asm_wpo.func_mod[i] == m && g_asm_wpo.func_fi[i] == fi)
      return i;
  }
  return -1;
}

/** 登记单个非 extern 函数节点。 */
static int32_t asm_wpo_register_func(struct ast_Module *m, int32_t fi) {
  struct ast_Func *f;
  int32_t id;
  if (!m || fi < 0 || g_asm_wpo.nfuncs >= ASM_WPO_MAX_FUNCS)
    return -1;
  f = module_func_at(m, fi);
  if (!f || f->is_extern)
    return -1;
  id = asm_wpo_func_id_of(m, fi);
  if (id >= 0)
    return id;
  id = g_asm_wpo.nfuncs;
  g_asm_wpo.func_mod[id] = m;
  g_asm_wpo.func_fi[id] = fi;
  g_asm_wpo.nfuncs++;
  return id;
}

/** 按函数名在指定 module 已注册节点中查找 id；未命中返回 -1。 */
static int32_t asm_wpo_func_id_in_module(struct ast_Module *m, uint8_t *name, int32_t name_len) {
  int32_t nf;
  int32_t fi;
  int32_t id;
  if (!m || !name || name_len <= 0)
    return -1;
  nf = pipeline_module_num_funcs(m);
  for (fi = 0; fi < nf; fi++) {
    if (!pipeline_module_func_name_equal_at(m, fi, name, name_len))
      continue;
    id = asm_wpo_func_id_of(m, fi);
    if (id >= 0)
      return id;
  }
  return -1;
}

/** 按函数名在已注册图中查找 id（跨模块）；重名时取首个。 */
static int32_t asm_wpo_func_id_by_name(uint8_t *name, int32_t name_len) {
  int32_t i;
  int32_t fi;
  if (!name || name_len <= 0)
    return -1;
  for (i = 0; i < g_asm_wpo.nfuncs; i++) {
    fi = g_asm_wpo.func_fi[i];
    if (pipeline_module_func_name_equal_at(g_asm_wpo.func_mod[i], fi, name, name_len))
      return i;
  }
  return -1;
}

/** 去重登记 from→to 边。 */
static void asm_wpo_add_edge(int32_t from, int32_t to) {
  int32_t i;
  if (from < 0 || to < 0 || from >= g_asm_wpo.nfuncs || to >= g_asm_wpo.nfuncs)
    return;
  for (i = 0; i < g_asm_wpo.nedges; i++) {
    if (g_asm_wpo.edges[i].from == from && g_asm_wpo.edges[i].to == to)
      return;
  }
  if (g_asm_wpo.nedges >= ASM_WPO_MAX_EDGES)
    return;
  g_asm_wpo.edges[g_asm_wpo.nedges].from = from;
  g_asm_wpo.edges[g_asm_wpo.nedges].to = to;
  g_asm_wpo.nedges++;
}

/**
 * 从 CALL 的 callee expr 取函数名（pipeline_expr_* 优先；kind 非 VAR 时回退裸 var_name 槽）。
 * 返回名长度；0 表示无可用名。
 */
static int32_t asm_wpo_call_callee_name(struct ast_ASTArena *a, int32_t callee_ref, uint8_t *cname) {
  struct ast_Expr *callee_ex;
  int32_t clen;
  if (!a || callee_ref <= 0 || !cname)
    return 0;
  callee_ex = pipeline_arena_expr_ptr(a, callee_ref);
  /** import 限定 callee（vec.vec_u8_new / heap.alloc）：取字段名，勿误用 binding 基名。 */
  if (callee_ex && callee_ex->kind == ast_ExprKind_EXPR_FIELD_ACCESS) {
    clen = pipeline_expr_field_access_name_len(a, callee_ref);
    if (clen > 0 && clen <= 63) {
      pipeline_expr_field_access_name_into(a, callee_ref, cname);
      return clen;
    }
  }
  clen = pipeline_expr_var_name_len(a, callee_ref);
  if (clen > 0 && clen <= 63) {
    pipeline_expr_var_name_into(a, callee_ref, cname);
    return clen;
  }
  if (!callee_ex || callee_ex->var_name_len <= 0 || callee_ex->var_name_len > 127)
    return 0;
  clen = callee_ex->var_name_len;
  memcpy(cname, callee_ex->var_name, (size_t)clen);
  return clen;
}

/** 解析 CALL 的 func id（callee 名与 emit bl 一致；再回退 typeck call_resolved_*，须与名一致）。 */
static int32_t asm_wpo_call_callee_id(struct ast_ASTArena *a, int32_t call_expr_ref, struct ast_Module *caller_mod,
                                      struct ast_PipelineDepCtx *ctx) {
  struct ast_Module *callee_mod;
  int32_t dep_ix;
  int32_t func_ix;
  int32_t callee_ref;
  int32_t cid;
  int32_t clen;
  uint8_t cname[128];
  if (!a || call_expr_ref <= 0)
    return -1;
  callee_ref = pipeline_expr_call_callee_ref_at(a, call_expr_ref);
  clen = asm_wpo_call_callee_name(a, callee_ref, cname);
  /** overload：须按实参分派，勿仅按名取首个 pick。 */
  if (clen > 0 && caller_mod) {
    int32_t ov_n = 0;
    int32_t fi_ov;
    int32_t nf_ov = pipeline_module_num_funcs(caller_mod);
    for (fi_ov = 0; fi_ov < nf_ov; fi_ov++) {
      if (pipeline_asm_module_func_is_extern_at(caller_mod, fi_ov) != 0)
        continue;
      if (pipeline_module_func_name_equal_at(caller_mod, fi_ov, cname, clen))
        ov_n++;
    }
    if (ov_n > 1) {
      int32_t picked = pipeline_typeck_pick_overload_func_index_for_call_c(caller_mod, a, call_expr_ref);
      if (picked >= 0) {
        cid = asm_wpo_func_id_of(caller_mod, picked);
        if (cid >= 0)
          return cid;
      }
    }
  }
  if (clen > 0) {
    cid = asm_wpo_func_id_in_module(caller_mod, cname, clen);
    if (cid < 0)
      cid = asm_wpo_func_id_by_name(cname, clen);
    if (cid >= 0)
      return cid;
  }
  func_ix = pipeline_expr_call_resolved_func_index_at(a, call_expr_ref);
  if (func_ix >= 0) {
    dep_ix = pipeline_expr_call_resolved_dep_index_at(a, call_expr_ref);
    callee_mod = caller_mod;
    if (dep_ix >= 0 && ctx)
      callee_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
    /** dep import / qualified callee：typeck resolved 为准；cname 与 FIELD_ACCESS 基名常不一致。 */
    if (clen > 0 && callee_mod && dep_ix < 0 &&
        pipeline_expr_kind_ord_at(a, callee_ref) != (int32_t)ast_ExprKind_EXPR_FIELD_ACCESS &&
        !pipeline_module_func_name_equal_at(callee_mod, func_ix, cname, clen))
      return -1;
    if (callee_mod) {
      cid = asm_wpo_func_id_of(callee_mod, func_ix);
      if (cid >= 0)
        return cid;
    }
  }
  return -1;
}

/** 前向声明：块内 call 边收集（collect_edges 与 collect_from_block 互递归）。 */
static void asm_wpo_collect_from_block(struct ast_ASTArena *a, int32_t block_ref, int32_t caller_id,
                                       struct ast_Module *caller_mod, struct ast_PipelineDepCtx *ctx);

/** 递归收集表达式中的 call 边（depth 上限防栈溢出）。 */
static void asm_wpo_collect_edges_from_expr(struct ast_ASTArena *a, int32_t expr_ref, int32_t caller_id,
                                            struct ast_Module *caller_mod, struct ast_PipelineDepCtx *ctx, int32_t depth) {
  struct ast_Expr *ex;
  int32_t i;
  int32_t cid;
  int32_t *arg_slot;
  if (!a || expr_ref <= 0 || caller_id < 0 || depth > 64)
    return;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return;
  if (ex->kind == ast_ExprKind_EXPR_CALL) {
    cid = asm_wpo_call_callee_id(a, expr_ref, caller_mod, ctx);
    if (cid >= 0)
      asm_wpo_add_edge(caller_id, cid);
    for (i = 0; i < ex->call_num_args; i++) {
      arg_slot = expr_call_arg_slot(a, expr_ref, i, 0);
      if (arg_slot && *arg_slot > 0)
        asm_wpo_collect_edges_from_expr(a, *arg_slot, caller_id, caller_mod, ctx, depth + 1);
    }
    if (ex->call_callee_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->call_callee_ref, caller_id, caller_mod, ctx, depth + 1);
    return;
  }
  /*
   * wave358 Cap residual pure — METHOD_CALL exclusive path (before binop peel).
   * Root: METHOD_CALL fell through to binop_left/right (union slots) and returned
   * without UFCS edge → freestanding emit_n skipped free get → ld UNDEF get.
   * G.7: same-module free method via call_resolved or method name match.
   * PLATFORM: SHARED freestanding WPO · LINUX gold.
   */
  /* kind via accessor (SoA-safe); 49 = EXPR_METHOD_CALL product ordinal. */
  if (ex->kind == ast_ExprKind_EXPR_METHOD_CALL ||
      pipeline_expr_kind_ord_at(a, expr_ref) == 49) {
    int32_t r_fn = pipeline_expr_call_resolved_func_index_at(a, expr_ref);
    int32_t r_dep = pipeline_expr_call_resolved_dep_index_at(a, expr_ref);
    int32_t mcid = -1;
    int32_t mlen = pipeline_expr_method_call_name_len(a, expr_ref);
    int32_t mbase = pipeline_expr_method_call_base_ref_at(a, expr_ref);
    int32_t mnargs = pipeline_expr_method_call_num_args_at(a, expr_ref);
    uint8_t mnm[128];
    if (r_fn >= 0 && r_dep < 0 && caller_mod)
      mcid = asm_wpo_func_id_of(caller_mod, r_fn);
    if (mcid < 0 && mlen > 0 && mlen <= 63) {
      pipeline_expr_method_call_name_into(a, expr_ref, mnm);
      mcid = asm_wpo_func_id_in_module(caller_mod, mnm, mlen);
      if (mcid < 0)
        mcid = asm_wpo_func_id_by_name(mnm, mlen);
      /* All same-name overloads: free get may not be first fi registration order. */
      if (caller_mod && mcid < 0) {
        int32_t fi_m;
        int32_t nf_m = pipeline_module_num_funcs(caller_mod);
        for (fi_m = 0; fi_m < nf_m; fi_m++) {
          if (pipeline_module_func_name_equal_at(caller_mod, fi_m, mnm, mlen)) {
            int32_t id_m = asm_wpo_func_id_of(caller_mod, fi_m);
            if (id_m >= 0)
              asm_wpo_add_edge(caller_id, id_m);
          }
        }
      }
    }
    if (mcid >= 0)
      asm_wpo_add_edge(caller_id, mcid);
    if (mbase > 0)
      asm_wpo_collect_edges_from_expr(a, mbase, caller_id, caller_mod, ctx, depth + 1);
    for (i = 0; i < mnargs; i++) {
      arg_slot = expr_method_call_arg_slot(a, expr_ref, i, 0);
      if (arg_slot && *arg_slot > 0)
        asm_wpo_collect_edges_from_expr(a, *arg_slot, caller_id, caller_mod, ctx, depth + 1);
    }
    return;
  }
  if (ex->kind == ast_ExprKind_EXPR_RETURN || ex->kind == ast_ExprKind_EXPR_PANIC || ex->kind == ast_ExprKind_EXPR_NEG ||
      ex->kind == ast_ExprKind_EXPR_BITNOT || ex->kind == ast_ExprKind_EXPR_LOGNOT || ex->kind == ast_ExprKind_EXPR_ADDR_OF ||
      ex->kind == ast_ExprKind_EXPR_DEREF || ex->kind == ast_ExprKind_EXPR_AWAIT || ex->kind == ast_ExprKind_EXPR_RUN ||
      ex->kind == ast_ExprKind_EXPR_SPAWN) {
    {
      int32_t uop = pipeline_expr_unary_operand_ref_at(a, expr_ref);
      if (uop > 0)
        asm_wpo_collect_edges_from_expr(a, uop, caller_id, caller_mod, ctx, depth + 1);
    }
    return;
  }
  if (ex->kind == ast_ExprKind_EXPR_AS) {
    if (ex->as_operand_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->as_operand_ref, caller_id, caller_mod, ctx, depth + 1);
    return;
  }
  if (ex->kind == ast_ExprKind_EXPR_IF || ex->kind == ast_ExprKind_EXPR_TERNARY) {
    if (ex->if_cond_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->if_cond_ref, caller_id, caller_mod, ctx, depth + 1);
    if (ex->if_then_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->if_then_ref, caller_id, caller_mod, ctx, depth + 1);
    if (ex->if_else_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->if_else_ref, caller_id, caller_mod, ctx, depth + 1);
    return;
  }
  if (ex->kind == ast_ExprKind_EXPR_BLOCK) {
    if (ex->block_ref > 0)
      asm_wpo_collect_from_block(a, ex->block_ref, caller_id, caller_mod, ctx);
    return;
  }
  if (ex->binop_left_ref > 0 || ex->binop_right_ref > 0) {
    if (ex->binop_left_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->binop_left_ref, caller_id, caller_mod, ctx, depth + 1);
    if (ex->binop_right_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->binop_right_ref, caller_id, caller_mod, ctx, depth + 1);
    return;
  }
  /*
   * wave351 Cap residual pure: STRUCT_LIT field inits and ARRAY_LIT elems must feed
   * the call graph. Root: `Box { a: fill(n) }` only-call-site left fill unreachable
   * (emit_n skipped fill → UNDEF). G.7: same collector; walk sidecar field/elem refs.
   * PLATFORM: SHARED freestanding WPO · LINUX gold.
   */
  if (ex->kind == ast_ExprKind_EXPR_STRUCT_LIT) {
    for (i = 0; i < ex->struct_lit_num_fields; i++) {
      int32_t iref = pipeline_expr_struct_lit_init_ref(a, expr_ref, i);
      if (iref > 0)
        asm_wpo_collect_edges_from_expr(a, iref, caller_id, caller_mod, ctx, depth + 1);
    }
    return;
  }
  if (ex->kind == ast_ExprKind_EXPR_ARRAY_LIT) {
    for (i = 0; i < ex->array_lit_num_elems; i++) {
      int32_t eref = pipeline_expr_array_lit_elem_ref(a, expr_ref, i);
      if (eref > 0)
        asm_wpo_collect_edges_from_expr(a, eref, caller_id, caller_mod, ctx, depth + 1);
    }
    return;
  }
  if (ex->field_access_base_ref > 0)
    asm_wpo_collect_edges_from_expr(a, ex->field_access_base_ref, caller_id, caller_mod, ctx, depth + 1);
  if (ex->index_base_ref > 0)
    asm_wpo_collect_edges_from_expr(a, ex->index_base_ref, caller_id, caller_mod, ctx, depth + 1);
  if (ex->index_index_ref > 0)
    asm_wpo_collect_edges_from_expr(a, ex->index_index_ref, caller_id, caller_mod, ctx, depth + 1);
}

/**
 * stmt_order 单步：按 kind 分派 const/let/expr/loop/for/if/region（与 typeck/codegen 一致）。
 * 现代 parser 以 stmt_order 为源码序权威；仅扫 legacy 池会漏 return/expr 边（WPO-S4 warm_mid UND）。
 */
static void asm_wpo_collect_from_stmt_order_one(struct ast_ASTArena *a, int32_t block_ref, int32_t caller_id,
                                              struct ast_Module *caller_mod, struct ast_PipelineDepCtx *ctx,
                                              int32_t si) {
  struct ast_Block *b;
  uint8_t sk;
  int32_t idx;
  int32_t er;
  if (!a || block_ref <= 0 || caller_id < 0)
    return;
  b = pipeline_arena_block_ptr(a, block_ref);
  if (!b || si < 0 || si >= b->num_stmt_order)
    return;
  sk = pipeline_block_stmt_order_kind(a, block_ref, si);
  idx = pipeline_block_stmt_order_idx(a, block_ref, si);
  if (sk == 0 && idx >= 0 && idx < b->num_consts) {
    er = pipeline_block_const_init_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
  } else if (sk == 1 && idx >= 0 && idx < b->num_lets) {
    er = pipeline_block_let_init_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
  } else if (sk == 2 && idx >= 0 && idx < b->num_expr_stmts) {
    er = pipeline_block_expr_stmt_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
  } else if (sk == 3 && idx >= 0 && idx < b->num_loops) {
    er = pipeline_block_while_cond_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    er = pipeline_block_while_body_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
  } else if (sk == 4 && idx >= 0 && idx < b->num_for_loops) {
    er = pipeline_block_for_init_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    er = pipeline_block_for_cond_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    er = pipeline_block_for_step_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    er = pipeline_block_for_body_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
  } else if (sk == 5 && idx >= 0 && idx < b->num_if_stmts) {
    er = pipeline_block_if_cond_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    er = pipeline_block_if_then_body_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
    er = pipeline_block_if_else_body_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
  } else if (sk == 6) {
    er = pipeline_block_region_body_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
  }
}

/** 收集块内全部 call 边。 */
static void asm_wpo_collect_from_block(struct ast_ASTArena *a, int32_t block_ref, int32_t caller_id,
                                       struct ast_Module *caller_mod, struct ast_PipelineDepCtx *ctx) {
  struct ast_Block *b;
  int32_t i;
  int32_t er;
  struct ast_LabeledStmt *ls;
  if (!a || block_ref <= 0 || caller_id < 0)
    return;
  b = pipeline_arena_block_ptr(a, block_ref);
  if (!b)
    return;
  /** num_stmt_order>0 时按源码序 walk（与 backend emit_block 一致）；否则回退 legacy 池扫描。 */
  if (b->num_stmt_order > 0) {
    for (i = 0; i < b->num_stmt_order; i++)
      asm_wpo_collect_from_stmt_order_one(a, block_ref, caller_id, caller_mod, ctx, i);
    /** stmt_order 与 expr_stmt 池偶发不同步；再扫 expr_stmt 兜底（WPO-S4 return warm_mid 漏边）。 */
    for (i = 0; i < b->num_expr_stmts; i++) {
      er = pipeline_block_expr_stmt_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    }
  } else {
    for (i = 0; i < b->num_consts; i++) {
      er = pipeline_block_const_init_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    }
    for (i = 0; i < b->num_lets; i++) {
      er = pipeline_block_let_init_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    }
    for (i = 0; i < b->num_loops; i++) {
      er = pipeline_block_while_cond_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
      er = pipeline_block_while_body_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
    }
    for (i = 0; i < b->num_for_loops; i++) {
      er = pipeline_block_for_init_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
      er = pipeline_block_for_cond_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
      er = pipeline_block_for_step_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
      er = pipeline_block_for_body_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
    }
    for (i = 0; i < b->num_if_stmts; i++) {
      er = pipeline_block_if_cond_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
      er = pipeline_block_if_then_body_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
      er = pipeline_block_if_else_body_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
    }
    for (i = 0; i < b->num_expr_stmts; i++) {
      er = pipeline_block_expr_stmt_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    }
  }
  /** C parser return 进 labeled 池且不进 stmt_order；须单独扫。 */
  for (i = 0; i < b->num_labeled_stmts; i++) {
    ls = pipeline_block_labeled_ptr(a, block_ref, i);
    if (!ls || ls->is_goto)
      continue;
    er = (int32_t)ls->return_expr_ref;
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
  }
  if (b->final_expr_ref > 0)
    asm_wpo_collect_edges_from_expr(a, b->final_expr_ref, caller_id, caller_mod, ctx, 0);
}

/** 用户单文件 + XLANG_WPO_PGO_HOT：非自举 compiler 模块（pgo_hot_smoke 等）。 */
static int32_t asm_wpo_is_user_single_file_pgo_entry(void) {
  if (!pipeline_elf_pgo_hot_enabled() || !g_asm_wpo.entry || g_asm_wpo.nmods != 1)
    return 0;
  if (asm_module_is_main_driver_selfhost(g_asm_wpo.entry))
    return 0;
  if (asm_module_is_pipeline_selfhost(g_asm_wpo.entry) || asm_module_is_typeck_selfhost(g_asm_wpo.entry) ||
      asm_module_is_backend_selfhost(g_asm_wpo.entry) || asm_module_is_parser_selfhost(g_asm_wpo.entry))
    return 0;
  return 1;
}

/** 前向声明：user_program_entry 判定须查 main 的 WPO id。 */
static int32_t asm_wpo_user_main_func_id(void);

/**
 * 用户可执行/单测 .x（非 compiler 自举模块且含 main）：WPO root/reach 须从 main 出发。
 * main_func_index 误指 #0/mk 时若 root 从 mk 起算，main 虽 force emit 但 get_a 等 callee 会被 DCE。
 */
static int32_t asm_wpo_is_user_program_entry(void) {
  if (!g_asm_wpo.entry || g_asm_wpo.nmods != 1)
    return 0;
  if (asm_module_is_main_driver_selfhost(g_asm_wpo.entry))
    return 0;
  if (asm_module_is_pipeline_selfhost(g_asm_wpo.entry) || asm_module_is_typeck_selfhost(g_asm_wpo.entry) ||
      asm_module_is_backend_selfhost(g_asm_wpo.entry) || asm_module_is_parser_selfhost(g_asm_wpo.entry))
    return 0;
  return asm_wpo_user_main_func_id() >= 0 ? 1 : 0;
}

/** 用户程序 main 的 WPO func id；未找到返回 -1。 */
static int32_t asm_wpo_user_main_func_id(void) {
  static const uint8_t main_nm[5] = {'m', 'a', 'i', 'n', 0};
  int32_t nf;
  int32_t fi;
  int32_t id;
  if (!g_asm_wpo.entry)
    return -1;
  nf = pipeline_module_num_funcs(g_asm_wpo.entry);
  for (fi = 0; fi < nf; fi++) {
    if (!pipeline_module_func_name_equal_at(g_asm_wpo.entry, fi, main_nm, 4))
      continue;
    id = asm_wpo_func_id_of(g_asm_wpo.entry, fi);
    if (id >= 0)
      return id;
  }
  return -1;
}

/** 扫描单函数体中的 call 边（caller_id 固定为图节点 id）。 */
static void asm_wpo_scan_func_body_calls(struct ast_ASTArena *a, struct ast_Module *mod, int32_t func_fi,
                                         int32_t caller_id, struct ast_PipelineDepCtx *ctx) {
  struct ast_Func *f;
  if (!a || !mod || caller_id < 0 || func_fi < 0)
    return;
  f = module_func_at(mod, func_fi);
  if (!f)
    return;
  if (f->body_ref > 0)
    asm_wpo_collect_from_block(a, f->body_ref, caller_id, mod, ctx);
  else if (f->body_expr_ref > 0)
    asm_wpo_collect_edges_from_expr(a, f->body_expr_ref, caller_id, mod, ctx, 0);
}

/** BFS 前预收集全模块 call 边（避免 root 误指 #0 时漏扫 main 体）。 */
static void asm_wpo_precollect_all_func_edges(void) {
  int32_t fid;
  int32_t mi;
  struct ast_ASTArena *a;
  for (fid = 0; fid < g_asm_wpo.nfuncs; fid++) {
    mi = asm_wpo_mod_index(g_asm_wpo.func_mod[fid]);
    a = (mi >= 0) ? g_asm_wpo.arenas[mi] : NULL;
    asm_wpo_scan_func_body_calls(a, g_asm_wpo.func_mod[fid], g_asm_wpo.func_fi[fid], fid, g_asm_wpo.dep_ctx);
  }
}

/**
 * 用户 PGO：强制补 main 尾 return/expr_stmt 的直接 call 边；返回 callee func id 或 -1。
 */
static int32_t asm_wpo_user_pgo_force_main_callee_edge(struct ast_Module *entry, struct ast_ASTArena *a) {
  int32_t main_id;
  int32_t main_fi;
  struct ast_Func *f;
  struct ast_Block *b;
  int32_t er;
  int32_t op;
  int32_t cid;
  int32_t ko;
  if (!entry || !a)
    return -1;
  main_id = asm_wpo_user_main_func_id();
  if (main_id < 0)
    return -1;
  main_fi = g_asm_wpo.func_fi[main_id];
  f = module_func_at(entry, main_fi);
  if (!f || f->body_ref <= 0)
    return -1;
  b = pipeline_arena_block_ptr(a, f->body_ref);
  if (!b)
    return -1;
  er = 0;
  if (b->num_expr_stmts > 0)
    er = pipeline_block_expr_stmt_ref(a, f->body_ref, b->num_expr_stmts - 1);
  if (er <= 0 && b->final_expr_ref > 0)
    er = b->final_expr_ref;
  if (er <= 0)
    return -1;
  ko = pipeline_expr_kind_ord_at(a, er);
  if (ko == (int32_t)ast_ExprKind_EXPR_RETURN) {
    op = pipeline_expr_unary_operand_ref_at(a, er);
    if (op <= 0)
      return -1;
    er = op;
  }
  ko = pipeline_expr_kind_ord_at(a, er);
  /* wave358: UFCS METHOD_CALL same-module free method (not only CALL). */
  if (ko == (int32_t)ast_ExprKind_EXPR_METHOD_CALL) {
    int32_t r_fn = pipeline_expr_call_resolved_func_index_at(a, er);
    int32_t r_dep = pipeline_expr_call_resolved_dep_index_at(a, er);
    int32_t nlen = pipeline_expr_method_call_name_len(a, er);
    uint8_t mnm[128];
    cid = -1;
    if (r_fn >= 0 && r_dep < 0)
      cid = asm_wpo_func_id_of(entry, r_fn);
    if (cid < 0 && nlen > 0 && nlen <= 63) {
      pipeline_expr_method_call_name_into(a, er, mnm);
      cid = asm_wpo_func_id_in_module(entry, mnm, nlen);
      if (cid < 0)
        cid = asm_wpo_func_id_by_name(mnm, nlen);
    }
    if (cid >= 0)
      asm_wpo_add_edge(main_id, cid);
    return cid;
  }
  if (ko != (int32_t)ast_ExprKind_EXPR_CALL)
    return -1;
  cid = asm_wpo_call_callee_id(a, er, entry, g_asm_wpo.dep_ctx);
  if (cid >= 0)
    asm_wpo_add_edge(main_id, cid);
  return cid;
}

/** 用户 PGO：删除 main 上除 legit_to 外的误边（main 体误指 warm_mid 块时 main→hot_add）。 */
static void asm_wpo_user_pgo_prune_main_edges(int32_t main_id, int32_t legit_to) {
  int32_t ei;
  if (main_id < 0 || legit_to < 0)
    return;
  ei = 0;
  while (ei < g_asm_wpo.nedges) {
    if (g_asm_wpo.edges[ei].from == main_id && g_asm_wpo.edges[ei].to != legit_to) {
      g_asm_wpo.edges[ei] = g_asm_wpo.edges[g_asm_wpo.nedges - 1];
      g_asm_wpo.nedges--;
      continue;
    }
    ei++;
  }
}

/**
 * 在已有 reachable 集合上反复补边 + BFS 扩展（至多 16 轮）。
 * SKIP_TYPECK 自举模块 call graph 首轮常不完整，须 fixpoint 才能保留编排链 callee。
 */
static void asm_wpo_reach_fixpoint_expand(void) {
  int32_t queue[ASM_WPO_MAX_FUNCS];
  int32_t qh;
  int32_t qt;
  int32_t pass;
  int32_t fid;
  int32_t expanded;
  struct ast_Module *m;
  struct ast_ASTArena *a;
  struct ast_Func *f;
  int32_t mi;
  int32_t fi;
  int32_t ei;
  int32_t to;

  for (pass = 0; pass < 16; pass++) {
    expanded = 0;
    for (fid = 0; fid < g_asm_wpo.nfuncs; fid++) {
      if (!g_asm_wpo.reachable[(size_t)fid])
        continue;
      m = g_asm_wpo.func_mod[fid];
      fi = g_asm_wpo.func_fi[fid];
      mi = asm_wpo_mod_index(m);
      a = (mi >= 0) ? g_asm_wpo.arenas[mi] : NULL;
      f = module_func_at(m, fi);
      if (!a || !f)
        continue;
      if (f->body_ref > 0)
        asm_wpo_collect_from_block(a, f->body_ref, fid, m, g_asm_wpo.dep_ctx);
      else if (f->body_expr_ref > 0)
        asm_wpo_collect_edges_from_expr(a, f->body_expr_ref, fid, m, g_asm_wpo.dep_ctx, 0);
    }
    qh = 0;
    qt = 0;
    for (fid = 0; fid < g_asm_wpo.nfuncs; fid++) {
      if (g_asm_wpo.reachable[(size_t)fid] && qt < ASM_WPO_MAX_FUNCS)
        queue[qt++] = fid;
    }
    while (qh < qt && qh < ASM_WPO_MAX_FUNCS) {
      fid = queue[qh++];
      for (ei = 0; ei < g_asm_wpo.nedges; ei++) {
        if (g_asm_wpo.edges[ei].from != fid)
          continue;
        to = g_asm_wpo.edges[ei].to;
        if (to < 0 || to >= g_asm_wpo.nfuncs)
          continue;
        if (!g_asm_wpo.reachable[(size_t)to]) {
          g_asm_wpo.reachable[(size_t)to] = 1;
          expanded = 1;
          if (qt < ASM_WPO_MAX_FUNCS)
            queue[qt++] = to;
        }
      }
    }
    if (!expanded)
      break;
  }
}

/** 从 root 起 BFS 标记 reachable 并补全边（与 codegen WPO 同语义）。 */
static void asm_wpo_build_reach(void) {
  int32_t queue[ASM_WPO_MAX_FUNCS];
  int32_t qh;
  int32_t qt;
  int32_t fid;
  struct ast_Module *m;
  struct ast_ASTArena *a;
  struct ast_Func *f;
  int32_t mi;
  int32_t fi;
  int32_t ei;
  int32_t to;
  int32_t user_pgo;
  if (g_asm_wpo.root_id < 0 || g_asm_wpo.root_id >= g_asm_wpo.nfuncs)
    return;
  user_pgo = asm_wpo_is_user_single_file_pgo_entry();
  /** 预收集全图边 + 用户 PGO 补 main→直接 callee 并修剪误边（warm_mid UND / hot_add 误 hot）。 */
  asm_wpo_precollect_all_func_edges();
  if (user_pgo && g_asm_wpo.entry && g_asm_wpo.nmods > 0) {
    int32_t main_callee = asm_wpo_user_pgo_force_main_callee_edge(g_asm_wpo.entry, g_asm_wpo.arenas[0]);
    int32_t main_id = asm_wpo_user_main_func_id();
    if (main_id >= 0 && main_callee >= 0)
      asm_wpo_user_pgo_prune_main_edges(main_id, main_callee);
  }
  qh = 0;
  qt = 0;
  g_asm_wpo.reachable[(size_t)g_asm_wpo.root_id] = 1;
  queue[qt++] = g_asm_wpo.root_id;
  while (qh < qt && qh < ASM_WPO_MAX_FUNCS) {
    fid = queue[qh++];
    m = g_asm_wpo.func_mod[fid];
    fi = g_asm_wpo.func_fi[fid];
    mi = asm_wpo_mod_index(m);
    a = (mi >= 0) ? g_asm_wpo.arenas[mi] : NULL;
    f = module_func_at(m, fi);
    if (a && f) {
      if (f->body_ref > 0)
        asm_wpo_collect_from_block(a, f->body_ref, fid, m, g_asm_wpo.dep_ctx);
      else if (f->body_expr_ref > 0)
        asm_wpo_collect_edges_from_expr(a, f->body_expr_ref, fid, m, g_asm_wpo.dep_ctx, 0);
    }
    for (ei = 0; ei < g_asm_wpo.nedges; ei++) {
      if (g_asm_wpo.edges[ei].from != fid)
        continue;
      to = g_asm_wpo.edges[ei].to;
      if (to < 0 || to >= g_asm_wpo.nfuncs)
        continue;
      if (!g_asm_wpo.reachable[(size_t)to]) {
        g_asm_wpo.reachable[(size_t)to] = 1;
        if (qt < ASM_WPO_MAX_FUNCS)
          queue[qt++] = to;
      }
    }
  }
  asm_wpo_reach_fixpoint_expand();
}

/**
 * 模块是否含 allocator_kind_heap（std.heap 特征 export）。
 */
static int32_t asm_wpo_mod_is_std_heap(struct ast_Module *m) {
  int32_t fi;
  int32_t nf;
  if (!m)
    return 0;
  nf = pipeline_module_num_funcs(m);
  for (fi = 0; fi < nf; fi++) {
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"allocator_kind_heap", 19))
      return 1;
  }
  return 0;
}

/**
 * std.heap allocator_* 同模块 helpers 偶发漏边（return-in-if）；reachable 时强制保留 alloc/arena64_alloc/realloc。
 */
static void asm_wpo_close_std_heap_helpers(void) {
  int32_t fid;
  struct ast_Module *heap_mod;
  heap_mod = 0;
  for (fid = 0; fid < g_asm_wpo.nfuncs; fid++) {
    if (!g_asm_wpo.reachable[(size_t)fid])
      continue;
    if (asm_wpo_mod_is_std_heap(g_asm_wpo.func_mod[fid])) {
      heap_mod = g_asm_wpo.func_mod[fid];
      break;
    }
  }
  if (!heap_mod)
    return;
  for (fid = 0; fid < g_asm_wpo.nfuncs; fid++) {
    uint8_t fn[128];
    int32_t fl;
    int32_t fi;
    if (g_asm_wpo.func_mod[fid] != heap_mod)
      continue;
    fi = g_asm_wpo.func_fi[fid];
    fl = pipeline_module_func_name_len_at(heap_mod, fi);
    if (fl <= 0 || fl > 127)
      continue;
    pipeline_module_func_name_copy64(heap_mod, fi, fn);
    if (pipeline_module_func_name_equal_at(heap_mod, fi, (uint8_t *)"alloc", 5) ||
        pipeline_module_func_name_equal_at(heap_mod, fi, (uint8_t *)"arena64_alloc", 11) ||
        pipeline_module_func_name_equal_at(heap_mod, fi, (uint8_t *)"realloc", 7))
      g_asm_wpo.reachable[(size_t)fid] = 1;
  }
  {
    static const uint8_t *hc_names[3];
    static const int32_t hc_lens[3] = {20, 12, 15};
    int32_t hj;
    hc_names[0] = (const uint8_t *)"heap_arena64_alloc_c";
    hc_names[1] = (const uint8_t *)"heap_alloc_c";
    hc_names[2] = (const uint8_t *)"heap_realloc_c";
    for (hj = 0; hj < 3; hj++) {
      int32_t cid2 = asm_wpo_func_id_by_name((uint8_t *)hc_names[hj], hc_lens[hj]);
      if (cid2 >= 0)
        g_asm_wpo.reachable[(size_t)cid2] = 1;
    }
  }
}

/** XLANG_WPO_PGO_HOT=1 时：root 与其直接 callee 标记 hot（静态 call-depth 代理）。 */
static void asm_wpo_mark_pgo_hot(void) {
  int32_t root;
  int32_t ei;
  int32_t to;
  int32_t nf;
  int32_t fi;
  int32_t mid;
  static const uint8_t main_nm[5] = {'m', 'a', 'i', 'n', 0};
  memset(g_asm_wpo_pgo_hot, 0, sizeof(g_asm_wpo_pgo_hot));
  if (!pipeline_elf_pgo_hot_enabled())
    return;
  root = g_asm_wpo.root_id;
  if (root < 0 || root >= g_asm_wpo.nfuncs)
    return;
  g_asm_wpo_pgo_hot[(size_t)root] = 1;
  /** 用户 PGO：main + 其 return 直接 callee 进 .text.hot（勿用误扫的 main→hot_add 边）。 */
  if (asm_wpo_is_user_single_file_pgo_entry()) {
    int32_t main_id = asm_wpo_user_main_func_id();
    int32_t main_callee;
    if (main_id >= 0) {
      g_asm_wpo_pgo_hot[(size_t)main_id] = 1;
      if (g_asm_wpo.entry && g_asm_wpo.nmods > 0) {
        main_callee = asm_wpo_user_pgo_force_main_callee_edge(g_asm_wpo.entry, g_asm_wpo.arenas[0]);
        if (main_callee >= 0 && g_asm_wpo.reachable[(size_t)main_callee])
          g_asm_wpo_pgo_hot[(size_t)main_callee] = 1;
      }
    }
    return;
  }
  /** 用户程序：入口 main 须进 .text.hot（root 误指 #0 占位符时兜底，与 should_emit main 保留配套）。 */
  if (g_asm_wpo.entry && !asm_module_is_main_driver_selfhost(g_asm_wpo.entry)) {
    nf = pipeline_module_num_funcs(g_asm_wpo.entry);
    for (fi = 0; fi < nf; fi++) {
      if (!pipeline_module_func_name_equal_at(g_asm_wpo.entry, fi, main_nm, 4))
        continue;
      mid = asm_wpo_func_id_of(g_asm_wpo.entry, fi);
      if (mid >= 0)
        g_asm_wpo_pgo_hot[(size_t)mid] = 1;
    }
  }
  for (ei = 0; ei < g_asm_wpo.nedges; ei++) {
    if (g_asm_wpo.edges[ei].from != root)
      continue;
    to = g_asm_wpo.edges[ei].to;
    if (to < 0 || to >= g_asm_wpo.nfuncs)
      continue;
    if (g_asm_wpo.reachable[(size_t)to])
      g_asm_wpo_pgo_hot[(size_t)to] = 1;
  }
}

/** PGO-Lite S2：自 root BFS 标记 call-depth（供 .text.hot / unlikely emit 排序）。 */
static void asm_wpo_mark_pgo_depth_user_from_main(void) {
  int32_t main_id;
  int32_t queue[ASM_WPO_MAX_FUNCS];
  int32_t qh;
  int32_t qt;
  int32_t fid;
  int32_t ei;
  int32_t to;
  int32_t nd;
  main_id = asm_wpo_user_main_func_id();
  if (main_id < 0 || main_id >= g_asm_wpo.nfuncs)
    return;
  memset(g_asm_wpo_pgo_depth, 0xff, sizeof(g_asm_wpo_pgo_depth));
  g_asm_wpo_pgo_depth[(size_t)main_id] = 0;
  qh = 0;
  qt = 1;
  queue[0] = main_id;
  while (qh < qt && qh < ASM_WPO_MAX_FUNCS) {
    fid = queue[qh++];
    nd = g_asm_wpo_pgo_depth[(size_t)fid];
    if (nd < 0)
      continue;
    for (ei = 0; ei < g_asm_wpo.nedges; ei++) {
      if (g_asm_wpo.edges[ei].from != fid)
        continue;
      to = g_asm_wpo.edges[ei].to;
      if (to < 0 || to >= g_asm_wpo.nfuncs)
        continue;
      if (!g_asm_wpo.reachable[(size_t)to])
        continue;
      if (g_asm_wpo_pgo_depth[(size_t)to] >= 0)
        continue;
      g_asm_wpo_pgo_depth[(size_t)to] = nd + 1;
      if (qt < ASM_WPO_MAX_FUNCS)
        queue[qt++] = to;
    }
  }
}

/** PGO-Lite S2：自 root BFS 标记 call-depth（供 .text.hot / unlikely emit 排序）。 */
static void asm_wpo_mark_pgo_depth(void) {
  int32_t root;
  int32_t queue[ASM_WPO_MAX_FUNCS];
  int32_t qh;
  int32_t qt;
  int32_t fid;
  int32_t ei;
  int32_t to;
  int32_t nd;
  memset(g_asm_wpo_pgo_depth, 0xff, sizeof(g_asm_wpo_pgo_depth));
  if (!pipeline_elf_pgo_hot_enabled() || !g_asm_wpo.valid)
    return;
  /** 用户 PGO 单文件：depth 恒以 main 为根（勿用误 root 导致 warm_mid depth0 先于 main emit）。 */
  if (asm_wpo_is_user_single_file_pgo_entry()) {
    asm_wpo_mark_pgo_depth_user_from_main();
    return;
  }
  root = g_asm_wpo.root_id;
  if (root < 0 || root >= g_asm_wpo.nfuncs)
    return;
  g_asm_wpo_pgo_depth[(size_t)root] = 0;
  qh = 0;
  qt = 1;
  queue[0] = root;
  while (qh < qt && qh < ASM_WPO_MAX_FUNCS) {
    fid = queue[qh++];
    nd = g_asm_wpo_pgo_depth[(size_t)fid];
    if (nd < 0)
      continue;
    for (ei = 0; ei < g_asm_wpo.nedges; ei++) {
      if (g_asm_wpo.edges[ei].from != fid)
        continue;
      to = g_asm_wpo.edges[ei].to;
      if (to < 0 || to >= g_asm_wpo.nfuncs)
        continue;
      if (!g_asm_wpo.reachable[(size_t)to])
        continue;
      if (g_asm_wpo_pgo_depth[(size_t)to] >= 0)
        continue;
      g_asm_wpo_pgo_depth[(size_t)to] = nd + 1;
      if (qt < ASM_WPO_MAX_FUNCS)
        queue[qt++] = to;
    }
  }
}

/** 取 (module, fi) 的 PGO call-depth；未知/不可达返回 9999。 */
static int32_t asm_wpo_pgo_depth_of(struct ast_Module *m, int32_t fi) {
  int32_t id;
  int32_t d;
  if (!m || fi < 0)
    return 9999;
  id = asm_wpo_func_id_of(m, fi);
  if (id < 0)
    return 9999;
  d = g_asm_wpo_pgo_depth[(size_t)id];
  if (d < 0)
    return 9999;
  return d;
}

/** 读 XLANG_ASM_WPO_DCE：未设或非 "0" 时启用 asm WPO DCE；设为 0 时关闭（A/B __text bench）。
 * XLANG_WPO_NO_FOLD=1 时亦关闭：对照 bench 须保留 lane0/scale 等 callee 定义，避免 reach 漏边导致 UNDEF。 */
static int32_t asm_wpo_dce_env_enabled(void) {
  if (link_abi_getenv("XLANG_WPO_NO_FOLD"))
    return 0;
  const char *e = link_abi_getenv("XLANG_ASM_WPO_DCE");
  if (!e || e[0] == '\0')
    return 1;
  if (e[0] == '0' && (e[1] == '\0' || e[1] == '\n'))
    return 0;
  return 1;
}

/** 在 asm_codegen_elf_o 入口：登记 entry+deps 全部函数并构建 WPO reach。 */
void pipeline_asm_wpo_reach_compute_for_elf(struct ast_Module *entry, struct ast_ASTArena *entry_arena,
                                            struct ast_PipelineDepCtx *ctx) {
  int32_t ndep;
  int32_t j;
  struct ast_Module *dm;
  struct ast_ASTArena *da;
  int32_t mi;
  int32_t nf;
  int32_t fi;
  int32_t main_ix;
  uint8_t main_nm[5] = {'m', 'a', 'i', 'n', 0};
  pipeline_asm_wpo_reach_clear();
  if (!entry || !entry_arena)
    return;
  /** A/B bench：XLANG_ASM_WPO_DCE=0 时不构图，emit 全量函数。 */
  if (!asm_wpo_dce_env_enabled())
    return;
  /**
   * 用户库 module .o（无 main、无 entry）：须全量 export 进 .o，勿 WPO 误留 emit_n=1 空壳。
   * PLATFORM: SHARED — compiler selfhost dogfood（typeck/pipeline/backend/driver_compile）
   * 使用下方命名 WPO root；禁止走此 early-return（否则 typeck_wpo __text 全量 ~100KiB 压不进 baseline）。
   * 历史债：2026-06-24 加用户库门时误伤 selfhost；typeck_wpo max 2048 从此红。
   */
  main_ix = pipeline_module_main_func_index(entry);
  if (main_ix < 0) {
    static const uint8_t entry_nm[6] = {'e', 'n', 't', 'r', 'y', 0};
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, entry_nm, 5))
        break;
    }
    if (fi >= nf) {
      if (!asm_module_is_typeck_selfhost(entry) && !asm_module_is_pipeline_selfhost(entry) &&
          !asm_module_is_backend_selfhost(entry) && !asm_module_is_driver_compile_selfhost(entry))
        return;
    }
  }
  /**
   * build_xlang_asm EMIT_HEAVY 第二遍：全 compiler 自举模块均可 WPO（root 按模块名设置）。
   * pipeline/typeck/backend 分别以 run_x_pipeline_impl / typeck_x_ast / asm_codegen_ast 为 root。
   */
  g_asm_wpo.entry = entry;
  g_asm_wpo.dep_ctx = ctx;
  if (asm_wpo_register_mod(entry, entry_arena) < 0)
    return;
  if (ctx) {
    ndep = pipeline_dep_ctx_ndep(ctx);
    for (j = 0; j < ndep; j++) {
      dm = pipeline_dep_ctx_module_at(ctx, j);
      da = pipeline_dep_ctx_arena_at(ctx, j);
      if (!dm || !da || dm == entry)
        continue;
      (void)asm_wpo_register_mod(dm, da);
    }
  }
  for (mi = 0; mi < g_asm_wpo.nmods; mi++) {
    nf = pipeline_module_num_funcs(g_asm_wpo.mods[mi]);
    for (fi = 0; fi < nf; fi++)
      (void)asm_wpo_register_func(g_asm_wpo.mods[mi], fi);
  }
  /** driver main.x 可执行入口为 entry；须优先于 main_func_index（常误指 #0 占位符 → 32B 错杀 entry）。 */
  {
    static const uint8_t entry_nm[6] = {'e', 'n', 't', 'r', 'y', 0};
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, entry_nm, 5)) {
        g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
        break;
      }
    }
  }
  /** 用户程序 root 为 main；须先于 main_func_index（首函数 mk/占位常误设 #0）。 */
  if (g_asm_wpo.root_id < 0) {
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, main_nm, 4)) {
        g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
        break;
      }
    }
  }
  /** pipeline.x 编排根：run_x_pipeline_impl（优于 main_func_index #0 占位符）。
   * PLATFORM: SHARED — name must be "run_x_pipeline_impl" (strlen 19); historical "su" + len 20 never matched after SU→SX rename. */
  if (g_asm_wpo.root_id < 0 && asm_module_is_pipeline_selfhost(entry)) {
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, (uint8_t *)"run_x_pipeline_impl", 19)) {
        g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
        break;
      }
    }
  }
  /** typeck.x 编排根：typeck_x_ast（S2 gate + pipeline typecheck 入口）。
   * PLATFORM: SHARED — name must be "typeck_x_ast" (strlen 12); historical "typeck_su_ast" + len 13 never matched. */
  if (g_asm_wpo.root_id < 0 && asm_module_is_typeck_selfhost(entry)) {
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, (uint8_t *)"typeck_x_ast", 12)) {
        g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
        break;
      }
    }
  }
  /** backend.x 编排根：asm_codegen_ast（pipeline codegen 入口；mega 仍 EMIT_HEAVY 桩）。 */
  if (g_asm_wpo.root_id < 0 && asm_module_is_backend_selfhost(entry)) {
    static uint8_t backend_root_nm[16] = {'a', 's', 'm', '_', 'c', 'o', 'd', 'e', 'g', 'e', 'n', '_', 'a', 's', 't', 0};
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, backend_root_nm, 15)) {
        g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
        break;
      }
    }
  }
  /**
   * driver/compile.x dogfood root：compile_dispatch_asm_backend（薄 bl→C，~145B）。
   * PLATFORM: SHARED — full parse_argv / run_compiler_full_x live in driver_compile_emit_heavy.o.
   * Prefer thin dispatch over run_compiler_full_x so build_asm/driver_compile.o stays WPO-compressed.
   */
  if (g_asm_wpo.root_id < 0 && asm_module_is_driver_compile_selfhost(entry)) {
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, (uint8_t *)"compile_dispatch_asm_backend", 28)) {
        g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
        break;
      }
    }
    if (g_asm_wpo.root_id < 0) {
      for (fi = 0; fi < nf; fi++) {
        if (pipeline_module_func_name_equal_at(entry, fi, (uint8_t *)"run_compiler_full_x", 19)) {
          g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
          break;
        }
      }
    }
  }
  main_ix = pipeline_module_main_func_index(entry);
  /** main_func_index 仅当其确实指向名为 main 的函数时作 fallback（勿用 #0 误根）。 */
  if (g_asm_wpo.root_id < 0 && main_ix >= 0 &&
      pipeline_module_func_name_equal_at(entry, main_ix, main_nm, 4))
    g_asm_wpo.root_id = asm_wpo_func_id_of(entry, main_ix);
  if (g_asm_wpo.root_id < 0 || g_asm_wpo.nfuncs <= 0)
    return;
  /** 用户程序：root 强制 main（#0/mk 误根会导致 main 所调 get_a 等 callee UND）。 */
  if (asm_wpo_is_user_program_entry()) {
    int32_t user_main = asm_wpo_user_main_func_id();
    if (user_main >= 0)
      g_asm_wpo.root_id = user_main;
  } else if (asm_wpo_is_user_single_file_pgo_entry()) {
    int32_t user_main = asm_wpo_user_main_func_id();
    if (user_main >= 0)
      g_asm_wpo.root_id = user_main;
  }
  asm_wpo_build_reach();
  asm_wpo_close_std_heap_helpers();
  /** main force emit 时须纳入 reach 闭包，fixpoint 从 main 补全 callee 边。 */
  if (asm_wpo_is_user_program_entry()) {
    int32_t user_main = asm_wpo_user_main_func_id();
    if (user_main >= 0)
      g_asm_wpo.reachable[(size_t)user_main] = 1;
  }
  asm_wpo_reach_fixpoint_expand();
  g_asm_wpo.valid = 1;
  asm_wpo_mark_pgo_hot();
  asm_wpo_mark_pgo_depth();
}

/** 前向声明：emit 顺序构建须过滤 WPO dead export。 */
int32_t pipeline_asm_wpo_should_emit_func(struct ast_Module *m, int32_t fi);

/**
 * 为 module 构建 emit 顺序表：WPO 过滤后按 call-depth 升序（同 depth 按 func_index）。
 * asm_codegen_ast_to_elf 每 Module 入口调用一次。
 */
void pipeline_asm_wpo_pgo_emit_order_prepare(struct ast_Module *m) {
  int32_t nf;
  int32_t fi;
  int32_t n;
  int32_t a;
  int32_t b;
  int32_t tmp;
  int32_t da;
  int32_t db;
  if (!m) {
    g_asm_wpo_pgo_emit_mod = NULL;
    g_asm_wpo_pgo_emit_n = 0;
    return;
  }
  g_asm_wpo_pgo_emit_mod = m;
  n = 0;
  nf = pipeline_module_num_funcs(m);
  fi = 0;
  while (fi < nf) {
    if (pipeline_asm_module_func_is_extern_at(m, fi) == 0 && pipeline_asm_wpo_should_emit_func(m, fi) != 0) {
      if (n < ASM_WPO_MAX_FUNCS)
        g_asm_wpo_pgo_emit_order[n] = fi;
      n = n + 1;
    }
    fi = fi + 1;
  }
  /**
   * asm -o 不能让 WPO/reach 误判把待 emit 集合裁成空集，否则 backend 连当前函数名都拿不到，
   * 最终只会以 empty __text / func unknown 的形式失败。仅在空集合时保守退回全部非 extern 函数。
   */
  if (n == 0 && nf > 0) {
    fi = 0;
    while (fi < nf) {
      if (pipeline_asm_module_func_is_extern_at(m, fi) == 0) {
        if (n < ASM_WPO_MAX_FUNCS)
          g_asm_wpo_pgo_emit_order[n] = fi;
        n = n + 1;
      }
      fi = fi + 1;
    }
  }
  if (pipeline_elf_pgo_hot_enabled() && g_asm_wpo.valid) {
    a = 0;
    while (a < n) {
      b = a + 1;
      while (b < n) {
        da = asm_wpo_pgo_depth_of(m, g_asm_wpo_pgo_emit_order[a]);
        db = asm_wpo_pgo_depth_of(m, g_asm_wpo_pgo_emit_order[b]);
        if (da > db || (da == db && g_asm_wpo_pgo_emit_order[a] > g_asm_wpo_pgo_emit_order[b])) {
          tmp = g_asm_wpo_pgo_emit_order[a];
          g_asm_wpo_pgo_emit_order[a] = g_asm_wpo_pgo_emit_order[b];
          g_asm_wpo_pgo_emit_order[b] = tmp;
        }
        b = b + 1;
      }
      a = a + 1;
    }
  }
  g_asm_wpo_pgo_emit_n = n;
}

/** 返回 module 待 emit 函数个数（须先 prepare 或 lazy prepare）。 */
int32_t pipeline_asm_wpo_pgo_emit_order_count(struct ast_Module *m) {
  if (m != g_asm_wpo_pgo_emit_mod)
    pipeline_asm_wpo_pgo_emit_order_prepare(m);
  return g_asm_wpo_pgo_emit_n;
}

/** 第 order_index 个待 emit 函数的 func_index；越界返回 -1。 */
int32_t pipeline_asm_wpo_pgo_emit_order_at(struct ast_Module *m, int32_t order_index) {
  if (m != g_asm_wpo_pgo_emit_mod)
    pipeline_asm_wpo_pgo_emit_order_prepare(m);
  if (order_index < 0 || order_index >= g_asm_wpo_pgo_emit_n)
    return -1;
  return g_asm_wpo_pgo_emit_order[order_index];
}

/**
 * PGO-Lite emit 查询：1=写入 .text.hot，0=写入 .text；未启用 XLANG_WPO_PGO_HOT 时恒 0。
 */
int32_t pipeline_asm_wpo_pgo_is_hot_func(struct ast_Module *m, int32_t fi) {
  int32_t id;
  if (!pipeline_elf_pgo_hot_enabled())
    return 0;
  if (!g_asm_wpo.valid)
    return 1;
  id = asm_wpo_func_id_of(m, fi);
  if (id < 0)
    return 0;
  return g_asm_wpo_pgo_hot[(size_t)id] ? 1 : 0;
}

/** pipeline.x WPO：strict 编排链 export 须保留（SKIP_TYPECK 时 call graph 兜底）。 */
static int32_t asm_wpo_pipeline_strict_preserve_emit(struct ast_Module *m, int32_t fi) {
  if (!m || fi < 0 || !asm_module_is_pipeline_selfhost(m))
    return 0;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_impl", 19))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_parse_entry_if_needed", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_parse_entry_do_parse", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_typecheck_entry", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_codegen_deps", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_codegen_entry", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_codegen_one_dep", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_typeck_entry_module", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_typeck_parsed_module", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"resolve_path_x", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_should_skip_x_typeck", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"read_file_x", 12))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_load_and_sync_direct_import_deps", 41))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_parse_into_buf", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_parse_set_main_from_buf", 32))
    return 1;
  return 0;
}

/**
 * asm emit 前查询：1=应发射，0= WPO dead export 跳过；未启用 WPO 或 extern 保守保留。
 */
int32_t pipeline_asm_wpo_should_emit_func(struct ast_Module *m, int32_t fi) {
  struct ast_Func *f;
  int32_t id;
  if (!g_asm_wpo.valid)
    return 1;
  f = module_func_at(m, fi);
  if (!f || f->is_extern)
    return 1;
  /** 入口模块的 entry 符号须保留（CLI / crt0 / bridge 链）。 */
  if (m == g_asm_wpo.entry && pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"entry", 5))
    return 1;
  /** 用户程序须 export main（WPO root 误指 #0/mk 时兜底，与 root 按名 main 优先配套）。 */
  if (m == g_asm_wpo.entry && !asm_module_is_main_driver_selfhost(m) &&
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"main", 4))
    return 1;
  /**
   * build_asm/main.o 生产链：WPO 启用时仅 export entry（~512B 内），
   * 其余 driver helper 由 runtime_driver / driver_*_x.o 提供。
   */
  if (m == g_asm_wpo.entry && asm_module_is_main_driver_selfhost(m))
    return 0;
  /**
   * build_asm/driver_compile.o WPO 压缩：仅 export 薄 dispatch（~145B）；
   * parse_argv / run_compiler_full_x 由 driver_compile_emit_heavy.o + link.o 提供。
   * PLATFORM: SHARED — must keep dispatch before blanket skip (else valid WPO emits empty .text).
   */
  if (m == g_asm_wpo.entry && asm_module_is_driver_compile_selfhost(m)) {
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"compile_dispatch_asm_backend", 28))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"compile_dispatch_emit_c_path", 28))
      return 1;
    return 0;
  }
  /**
   * pipeline.x WPO：gate/strict 关键 export 须保留；其余走 reach DCE（勿 blanket return 0）。
   */
  if (asm_wpo_pipeline_strict_preserve_emit(m, fi))
    return 1;
  if (m == g_asm_wpo.entry && asm_module_is_pipeline_selfhost(m)) {
    /* 遗留显式名单已由 asm_wpo_pipeline_strict_preserve_emit 覆盖；保留 reach 路径。 */
  }
  /**
   * typeck.x WPO：S2 gate 关键 export + pipeline merge 须保留；其余走 reach DCE。
   */
  if (m == g_asm_wpo.entry && asm_module_is_typeck_selfhost(m)) {
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"typeck_x_ast", 12))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"typeck_x_ast_library", 20))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"check_block", 11))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"check_expr", 10))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"typeck_merge_dep_struct_layouts_into_entry", 42))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"typeck_wpo_unify_soa_layouts", 28))
      return 1;
  }
  /**
   * backend.x WPO：codegen 入口 export 须保留；其余走 reach DCE（M8-tail 薄包装 bl→C）。
   */
  if (m == g_asm_wpo.entry && asm_module_is_backend_selfhost(m)) {
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"asm_codegen_ast", 15))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"asm_codegen_ast_to_elf", 22))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"emit_expr_elf", 13))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"emit_block_body_elf", 19))
      return 1;
  }
  id = asm_wpo_func_id_of(m, fi);
  if (id < 0)
    return 1;
  /**
   * std.heap：allocator_* reach 时 co-emit default_alloc/allocator_heap（薄模块缺 alloc 等，由 call redirect→libc）。
   */
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"default_alloc", 13) ||
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"heap_alloc", 14) ||
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"alloc", 5) ||
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"arena64_alloc", 11) ||
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"realloc", 7)) {
    int32_t j;
    for (j = 0; j < g_asm_wpo.nfuncs; j++) {
      int32_t jfi;
      struct ast_Module *jm;
      if (!g_asm_wpo.reachable[(size_t)j])
        continue;
      jm = g_asm_wpo.func_mod[j];
      jfi = g_asm_wpo.func_fi[j];
      if (!jm || jfi < 0)
        continue;
      if (pipeline_module_func_name_equal_at(jm, jfi, (uint8_t *)"alloc", 5) ||
          pipeline_module_func_name_equal_at(jm, jfi, (uint8_t *)"realloc", 7))
        return 1;
    }
  }
  /** heap_libc：std.heap allocator 已 reach 时 co-emit heap_*_c 桥。 */
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"heap_arena64_alloc_c", 20) ||
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"heap_alloc_c", 12) ||
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"heap_realloc_c", 15)) {
    int32_t j;
    for (j = 0; j < g_asm_wpo.nfuncs; j++) {
      struct ast_Module *hm;
      int32_t jfi;
      if (!g_asm_wpo.reachable[(size_t)j])
        continue;
      hm = g_asm_wpo.func_mod[j];
      if (!asm_wpo_mod_is_std_heap(hm))
        continue;
      jfi = g_asm_wpo.func_fi[j];
      if (pipeline_module_func_name_equal_at(hm, jfi, (uint8_t *)"alloc", 5) ||
          pipeline_module_func_name_equal_at(hm, jfi, (uint8_t *)"realloc", 7))
        return 1;
    }
  }
  return g_asm_wpo.reachable[(size_t)id] ? 1 : 0;
}

/** bootstrap 链接 glue：pipeline 编排 / asm scope / typeck 指针写槽（误 revert 后补全）。 */
#include "ast_pool_bootstrap_glue.c"
