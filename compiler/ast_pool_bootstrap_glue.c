/**
 * ast_pool_bootstrap_glue.c — 恢复 bootstrap ./shux 链接所需的 pipeline / asm / typeck glue
 *
 * 误 revert 后 ast_pool.c 缺失的符号在此补全；由 ast_pool.c 末尾 #include 编入 pipeline_sx.o。
 * 逻辑与 HEAD pipeline.sx 中 run_sx_pipeline_impl / pipeline_load_and_sync 一致。
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;
struct codegen_CodegenOutBuf;

/* —— 外部依赖（pipeline_gen / runtime / parser / typeck / codegen / asm） —— */
extern int32_t parser_copy_module_import_path64(struct ast_Module *module, int32_t i, uint8_t out[64]);
extern int32_t parser_get_module_num_imports(struct ast_Module *module);
extern void parser_parse_into_set_main_index(struct ast_Module *module, int32_t main_idx);
extern struct parser_ParseIntoResult pipeline_parse_into_with_init_buf(struct ast_ASTArena *arena,
                                                                       struct ast_Module *module, uint8_t *data,
                                                                       int32_t len);
extern int32_t pipeline_resolve_path_sx(struct ast_PipelineDepCtx *ctx, uint8_t import_path[64], int32_t path_len);
extern int32_t pipeline_read_file_sx(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_parse_into_buf(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *buf,
                                       int32_t buf_len);
extern int32_t pipeline_load_import_from_disk(struct ast_Module *module, struct ast_ASTArena *arena,
                                              struct ast_PipelineDepCtx *ctx, int32_t import_idx);
extern int32_t pipeline_should_skip_sx_typeck(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_driver_asm_build_skip_typeck(void);
extern int32_t pipeline_driver_sx_pipeline_skip_typeck(void);
extern int32_t preprocess_sx_buf(uint8_t *source_buf, ptrdiff_t source_len, uint8_t *out_buf,
                                            int32_t out_cap);

extern uint8_t *driver_dep_arena_buf(int32_t i);
extern uint8_t *driver_dep_module_buf(int32_t i);
extern int32_t driver_dep_seeded_get(int32_t i);
extern int32_t driver_dep_slot_for_path(uint8_t *path);
extern int32_t driver_check_only_get(void);
extern int32_t driver_skip_codegen_dep_0_get(void);
extern int32_t driver_sx_pipeline_skip_codegen_get(void);
extern void driver_diagnostic_entry_already(int32_t v);
extern void driver_diagnostic_source_len(int32_t len);
extern void driver_diagnostic_parse_fail(int32_t main_idx, int32_t num_funcs, int32_t arena_num_types);
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern void driver_diagnostic_entry_module(struct ast_Module *module, struct ast_ASTArena *arena);
extern void driver_diagnostic_typeck_fail(void);
extern void driver_diagnostic_before_codegen(int32_t num_funcs, int32_t out_len);
extern void driver_diagnostic_after_dep_codegen(int32_t j, int32_t out_len);
extern void driver_diagnostic_codegen_fail(int32_t dep_index, int32_t is_dep);
extern void driver_set_current_dep_path_for_codegen(uint8_t *path);

extern int32_t typeck_typeck_sx_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                      struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_typeck_sx_ast_library(struct ast_Module *module, struct ast_ASTArena *arena,
                                            struct ast_PipelineDepCtx *ctx);
extern void typeck_typeck_merge_dep_struct_layouts_into_entry(struct ast_Module *mod, struct ast_ASTArena *arena,
                                                             struct ast_PipelineDepCtx *ctx);
extern void typeck_typeck_wpo_unify_soa_layouts(struct ast_Module *entry, struct ast_PipelineDepCtx *ctx);
extern int32_t asm_asm_codegen_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                   struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx);
extern int32_t codegen_codegen_sx_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                      struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx,
                                      int32_t dep_index);

extern void pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_ASTArena *arena);
extern void pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_Module *module);
extern void pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx *ctx, int32_t n);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern struct ast_ASTArena *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern void pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *bytes,
                                             int32_t len);
extern void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst);
extern int32_t pipeline_module_num_funcs(struct ast_Module *m);
extern int32_t pipeline_module_func_body_ref_at(struct ast_Module *m, int32_t func_index);
extern void pipeline_patch_block_parent_links(struct ast_ASTArena *a, int32_t block_ref, int32_t parent_ref);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *a, int32_t type_ref);
extern int32_t pipeline_type_elem_ref_at(struct ast_ASTArena *a, int32_t type_ref);
extern int32_t asm_ctx_local_find_offset(uint8_t *ctx, uint8_t *name, int32_t name_len);
extern int32_t asm_ctx_block_slot_get(uint8_t *ctx, int32_t block_ref);
extern int32_t pipeline_codegen_dep_skip_asm_user_std_io(uint8_t *path);

extern int32_t *typeck_layout_metrics_sz_slot(void);
extern int32_t *typeck_layout_metrics_al_slot(void);
extern int32_t *typeck_layout_metrics_sz_slot_depth(int32_t depth);
extern int32_t *typeck_layout_metrics_al_slot_depth(int32_t depth);

/* —— typeck.sx 指针写槽 glue（须在 pipeline_sx.o 提供，typeck_sx.o 链接依赖） —— */

/** 安全写 *i32，避免 .sx 栈上 &out 在自举 emit 下撕裂。 */
void typeck_i32_ptr_store(int32_t *p, int32_t v) {
  if (p)
    *p = v;
}

/** 安全读 *i32；resolve_call SX emit 读 scratch slot。 */
int32_t typeck_i32_ptr_read(int32_t *p) {
  return p ? *p : 0;
}

/** 初始化 depth 分槽 metrics  scratch。 */
void typeck_layout_metrics_init_depth(int32_t depth) {
  int32_t *sz = typeck_layout_metrics_sz_slot_depth(depth);
  int32_t *al = typeck_layout_metrics_al_slot_depth(depth);
  if (sz)
    *sz = 0;
  if (al)
    *al = 1;
}

/** 读 depth 分槽 align。 */
int32_t typeck_layout_metrics_al_read_depth(int32_t depth) {
  return *typeck_layout_metrics_al_slot_depth(depth);
}

/** 读 depth 分槽 size。 */
int32_t typeck_layout_metrics_sz_read_depth(int32_t depth) {
  return *typeck_layout_metrics_sz_slot_depth(depth);
}

/** 初始化顶层 metrics 单槽。 */
void typeck_layout_metrics_init_slot(void) {
  *typeck_layout_metrics_sz_slot() = 0;
  *typeck_layout_metrics_al_slot() = 1;
}

/* —— asm 栈槽 / scope sidecar（pipeline_glue.c 前置声明，定义须在本 TU） —— */

typedef struct {
  void *ctx;
  int used;
  int32_t scope_block_ref;
} AsmScopeSidecar;

#ifndef MAX_ASM_LOCALS_SIDECARS
#define MAX_ASM_LOCALS_SIDECARS 64
#endif

static AsmScopeSidecar g_asm_scope_sc[MAX_ASM_LOCALS_SIDECARS];

/** 取或创建 ctx 对应的 scope sidecar。 */
static AsmScopeSidecar *asm_scope_sidecar_get(uint8_t *ctx, int create) {
  int i;
  if (!ctx)
    return NULL;
  for (i = 0; i < MAX_ASM_LOCALS_SIDECARS; i++) {
    if (g_asm_scope_sc[i].used && g_asm_scope_sc[i].ctx == (void *)ctx)
      return &g_asm_scope_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_ASM_LOCALS_SIDECARS; i++) {
    if (!g_asm_scope_sc[i].used) {
      g_asm_scope_sc[i].ctx = (void *)ctx;
      g_asm_scope_sc[i].used = 1;
      g_asm_scope_sc[i].scope_block_ref = 0;
      return &g_asm_scope_sc[i];
    }
  }
  return NULL;
}

/** 设置当前 scope 块 ref（while/for/if 体进入时）。 */
void asm_ctx_set_scope_block(uint8_t *ctx, int32_t block_ref) {
  AsmScopeSidecar *sc = asm_scope_sidecar_get(ctx, 1);
  if (sc)
    sc->scope_block_ref = block_ref;
}

/** 读当前 scope 块 ref；无 sidecar 返回 0。 */
int32_t asm_ctx_scope_block_ref_at(uint8_t *ctx) {
  AsmScopeSidecar *sc = asm_scope_sidecar_get(ctx, 0);
  return sc ? sc->scope_block_ref : 0;
}

/** 局部类型对齐（简化版，与 pipeline_glue glue_type_align_simple 标量路径一致）。 */
static int32_t asm_type_align_for_local(struct ast_ASTArena *arena, int32_t type_ref, int32_t depth) {
  int32_t kind;
  if (!arena || type_ref <= 0 || type_ref > arena->num_types || depth > 64)
    return 8;
  kind = pipeline_type_kind_ord_at(arena, type_ref);
  if (kind == 2)
    return 1;
  if (kind == 0 || kind == 3 || kind == 1 || kind == 14)
    return 4;
  if (kind == 13)
    return 16;
  if (kind == 5 || kind == 4 || kind == 6 || kind == 7 || kind == 15 || kind == 9 || kind == 11)
    return 8;
  if (kind == 10 || kind == 12) {
    int32_t elem = pipeline_type_elem_ref_at(arena, type_ref);
    return elem > 0 ? asm_type_align_for_local(arena, elem, depth + 1) : 1;
  }
  if (kind == 8)
    return 4;
  return 8;
}

/** let/const 栈偏移按类型对齐上调。 */
int32_t asm_bump_off_align_for_local(struct ast_ASTArena *arena, int32_t type_ref, int32_t off) {
  int32_t al = asm_type_align_for_local(arena, type_ref, 0);
  if (al <= 0)
    al = 8;
  return (off + al - 1) / al * al;
}

/**
 * 登记局部槽的 fp 负偏移：lea/sub 为 [fp-偏移]。
 * 统一 slot_off = off + sz（槽占 [fp-(off+sz), fp-off)）；inout 推进 off+sz。
 */
int32_t asm_local_slot_reg_offset(struct ast_ASTArena *arena, int32_t type_ref, int32_t off, int32_t *inout_off) {
  int32_t sz;
  int32_t slot_off;
  off = asm_bump_off_before_struct_local(arena, type_ref, off);
  off = asm_bump_off_align_for_local(arena, type_ref, off);
  sz = asm_local_slot_bytes(arena, type_ref);
  slot_off = off + sz;
  if (inout_off)
    *inout_off = off + sz;
  return slot_off;
}

/** 命名 struct 局部前 16 字节对齐（SIMD/ABI）；TYPE_VECTOR 同宽槽亦对齐。 */
int32_t asm_bump_off_before_struct_local(struct ast_ASTArena *arena, int32_t type_ref, int32_t off) {
  int32_t kind;
  if (!arena || type_ref <= 0)
    return off;
  kind = pipeline_type_kind_ord_at(arena, type_ref);
  if ((kind == 13 || asm_type_is_simd_vector_spelling(arena, type_ref)) && (off % 16) != 0)
    return (off + 15) / 16 * 16;
  if (kind == 8 && (off % 16) != 0)
    return (off + 15) / 16 * 16;
  return off;
}

/** 是否为 TYPE_VECTOR（kind==13；ast.h 在 TYPE_LINEAR=12 之后）。 */
int32_t asm_type_is_simd_vector(struct ast_ASTArena *arena, int32_t type_ref) {
  if (!arena || type_ref <= 0 || type_ref > arena->num_types)
    return 0;
  return pipeline_type_kind_ord_at(arena, type_ref) == 13 ? 1 : 0;
}

/**
 * TYPE_VECTOR 或误落 TYPE_NAMED 的 i32x4/u32x8 等拼写（shux_asm lex 偶发 TOKEN_IDENT）。
 */
int32_t asm_type_is_simd_vector_spelling(struct ast_ASTArena *arena, int32_t type_ref) {
  struct ast_Type *t;
  if (!arena || type_ref <= 0 || type_ref > arena->num_types)
    return 0;
  if (asm_type_is_simd_vector(arena, type_ref))
    return 1;
  t = pipeline_arena_type_ptr(arena, type_ref);
  if (!t || (int32_t)t->kind != 8 || t->name_len <= 0)
    return 0;
  if (t->name_len == 5 && memcmp(t->name, "i32x4", 5) == 0)
    return 1;
  if (t->name_len == 5 && memcmp(t->name, "i32x8", 5) == 0)
    return 1;
  if (t->name_len == 6 && memcmp(t->name, "i32x16", 6) == 0)
    return 1;
  if (t->name_len == 5 && memcmp(t->name, "u32x4", 5) == 0)
    return 1;
  if (t->name_len == 5 && memcmp(t->name, "u32x8", 5) == 0)
    return 1;
  if (t->name_len == 6 && memcmp(t->name, "u32x16", 6) == 0)
    return 1;
  if (t->name_len == 5 && memcmp(t->name, "f32x4", 5) == 0)
    return 1;
  if (t->name_len == 5 && memcmp(t->name, "Vec4f", 5) == 0)
    return 1;
  if (t->name_len == 5 && memcmp(t->name, "Vec8i", 5) == 0)
    return 1;
  return 0;
}

/**
 * 在 scope 块内查局部偏移：仅搜索 scope 块登记后追加的槽（内层 shadow 外层）。
 * 无 scope 时退化为 asm_ctx_local_find_offset。
 */
int32_t asm_ctx_local_find_offset_scoped(uint8_t *ctx, struct ast_ASTArena *arena, uint8_t *name, int32_t name_len) {
  int32_t scope_blk;
  int32_t min_slot;
  (void)arena;
  scope_blk = asm_ctx_scope_block_ref_at(ctx);
  if (scope_blk <= 0)
    return asm_ctx_local_find_offset(ctx, name, name_len);
  min_slot = asm_ctx_block_slot_get(ctx, scope_blk);
  if (min_slot < 0)
    return asm_ctx_local_find_offset(ctx, name, name_len);
  /* 复用全表搜索：ensure_block_locals 按块顺序追加，min_slot 之后为 scope 子树槽。 */
  {
    extern int32_t asm_ctx_local_count(uint8_t *ctx);
    int32_t i;
    int32_t off;
    for (i = asm_ctx_local_count(ctx) - 1; i >= min_slot; i--) {
      extern int32_t asm_ctx_local_name_len(uint8_t *ctx, int32_t idx);
      extern void asm_ctx_local_name_copy64(uint8_t *ctx, int32_t idx, uint8_t *out);
      extern int32_t asm_ctx_local_offset_at(uint8_t *ctx, int32_t idx);
      uint8_t nb[64];
      int32_t nlen;
      int32_t k;
      nlen = asm_ctx_local_name_len(ctx, i);
      if (nlen != name_len)
        continue;
      asm_ctx_local_name_copy64(ctx, i, nb);
      for (k = 0; k < name_len; k++) {
        if (nb[k] != name[k])
          break;
      }
      if (k == name_len) {
        off = asm_ctx_local_offset_at(ctx, i);
        return off;
      }
    }
  }
  /** 外层块 let（如 while 体内用 main 的 `p`）：子树槽未命中时回退全表（仍自后向前，内层 shadow 优先）。 */
  return asm_ctx_local_find_offset(ctx, name, name_len);
}

/** 为 module 各函数体补 parent_block_ref（asm codegen 前）。 */
void pipeline_asm_patch_module_parent_links(struct ast_Module *m, struct ast_ASTArena *a) {
  int32_t i;
  int32_t n;
  int32_t body;
  if (!m || !a)
    return;
  n = pipeline_module_num_funcs(m);
  for (i = 0; i < n; i++) {
    body = pipeline_module_func_body_ref_at(m, i);
    if (body > 0)
      pipeline_patch_block_parent_links(a, body, 0);
  }
}

/* —— std 用户 dep skip / net 路径判定 —— */

/** std.fs 族：seed asm 跳过整模块 emit。 */
int32_t pipeline_codegen_dep_skip_asm_user_std_fs(uint8_t *path) {
  if (!path)
    return 0;
  if (memcmp(path, "std.fs", 6) != 0)
    return 0;
  return (path[6] == 0 || path[6] == '.') ? 1 : 0;
}

/** std.process 族：同上。 */
int32_t pipeline_codegen_dep_skip_asm_user_std_process(uint8_t *path) {
  if (!path)
    return 0;
  if (memcmp(path, "std.process", 11) != 0)
    return 0;
  return (path[11] == 0 || path[11] == '.') ? 1 : 0;
}

/** std.fmt：符号由 runtime_asm_io_stubs + redirect 提供（见 ast_pool.c）。 */
int32_t pipeline_codegen_dep_skip_asm_user_std_fmt(uint8_t *path) {
  if (!path)
    return 0;
  if (memcmp(path, "std.fmt", 7) != 0)
    return 0;
  return (path[7] == 0 || path[7] == '.') ? 1 : 0;
}

/** std.error / std.context。 */
int32_t pipeline_codegen_dep_skip_asm_user_std_misc(uint8_t *path) {
  if (!path)
    return 0;
  if (memcmp(path, "std.error", 9) == 0 && (path[9] == 0 || path[9] == '.'))
    return 1;
  if (memcmp(path, "std.context", 11) == 0 && (path[11] == 0 || path[11] == '.'))
    return 1;
  return 0;
}

/**
 * core.fmt / core.types：闭包符号由链入 std 预编译 .o 提供（base64.o 等 export core_types_*），
 * 勿整库 co-emit（与 base64.o 重复 core_types_placeholder；hello 等纯 std 闭包勿 co-emit core.fmt）。
 * core.result / core.option：用户 import 时须 co-emit（否则 ld 缺 core_result_ok_i32 等）。
 */
int32_t pipeline_codegen_dep_skip_asm_user_core_lib(uint8_t *path) {
  if (!path)
    return 0;
  if (memcmp(path, "core.fmt", 8) == 0 && (path[8] == 0 || path[8] == '.'))
    return 1;
  if (memcmp(path, "core.types", 10) == 0 && (path[10] == 0 || path[10] == '.'))
    return 1;
  return 0;
}

/** import 路径是否为 std.net 族。 */
int32_t pipeline_asm_user_std_net_dep_path(uint8_t *path) {
  if (!path)
    return 0;
  if (memcmp(path, "std.net", 7) != 0)
    return 0;
  return (path[7] == 0 || path[7] == '.') ? 1 : 0;
}

/** 是否存在须 co-emit 的用户自有 dep（tests/multi-file 的 import("foo") 等）。 */
int32_t pipeline_asm_user_deps_need_coemit(char **dep_paths, int32_t n) {
  int32_t i;
  if (!dep_paths || n <= 0)
    return 0;
  for (i = 0; i < n; i++) {
    uint8_t *p = (uint8_t *)(dep_paths[i] ? dep_paths[i] : "");
    /*
     * std./core. 闭包符号由预编 .o / preamble 提供；勿整库 co-emit（encoding/string/heap 等
     * dep_prerun typeck 在 strict 链上易 SIGSEGV）。
     */
    if (memcmp(p, "std.", 4) == 0 || memcmp(p, "core.", 5) == 0)
      continue;
    return 1;
  }
  return 0;
}

/** io/fs/net/process dep 跳过 .sx typeck（符号由 *.o 提供）。 */
int32_t pipeline_asm_user_dep_skip_sx_typeck(uint8_t *path) {
  if (!path)
    return 0;
  if (pipeline_codegen_dep_skip_asm_user_std_io(path) != 0)
    return 1;
  if (pipeline_codegen_dep_skip_asm_user_std_fs(path) != 0)
    return 1;
  if (pipeline_codegen_dep_skip_asm_user_std_process(path) != 0)
    return 1;
  if (pipeline_codegen_dep_skip_asm_user_std_fmt(path) != 0)
    return 1;
  if (pipeline_codegen_dep_skip_asm_user_std_misc(path) != 0)
    return 1;
  if (pipeline_codegen_dep_skip_asm_user_core_lib(path) != 0)
    return 1;
  if (pipeline_asm_user_std_net_dep_path(path) != 0)
    return 1;
  return 0;
}

/**
 * std.net dep parse-only 后补 struct layout 占位（完整 seed 待 M8 后恢复）；
 * 当前为空操作，保证链接与 smoke 不崩。
 */
void pipeline_asm_seed_std_net_struct_layouts(struct ast_Module *m) {
  (void)m;
}

/** std.heap 薄包装 → heap.c 符号（asm 跳过 std.heap dep emit 时由 heap.o 解析）。 */
typedef struct {
  const char *from;
  const char *to;
} glue_std_heap_redirect_t;

static const glue_std_heap_redirect_t kGlueStdHeapRedirect[] = {
    {"alloc", "heap_alloc_c"},
    {"realloc", "heap_realloc_c"},
    {"free", "heap_free_c"},
    {"alloc_i32", "heap_alloc_i32_c"},
    {"alloc_i32_ret_i32_ptr", "heap_alloc_i32_c"},
    {"alloc_i32_ret_u8_ptr", "heap_alloc_u8_c"},
    {"alloc_i32_ret_u64_ptr", "heap_alloc_u64_c"},
    {"alloc_i32_ret_f64_ptr", "heap_alloc_f64_c"},
    {"alloc_i32_ret_f32_ptr", "heap_alloc_f32_c"},
    {"realloc_i32", "heap_realloc_i32_c"},
    {"realloc_i32_ret_i32_ptr", "heap_realloc_i32_c"},
    {"realloc_u64_ret_u64_ptr", "heap_realloc_u64_c"},
    {"realloc_f64_ret_f64_ptr", "heap_realloc_f64_c"},
    {"realloc_f32_ret_f32_ptr", "heap_realloc_f32_c"},
    {"realloc_u8_ret_u8_ptr", "heap_realloc_u8_c"},
    {"free_i32", "heap_free_i32_c"},
    {"free_i32_ptr", "heap_free_i32_c"},
    {"free_u64_ptr", "heap_free_u64_c"},
    {"free_f64_ptr", "heap_free_f64_c"},
    {"free_f32_ptr", "heap_free_f32_c"},
    {"alloc_u8", "heap_alloc_u8_c"},
    {"realloc_u8", "heap_realloc_u8_c"},
    {"free_u8", "heap_free_u8_c"},
    {"alloc_f32", "heap_alloc_f32_c"},
    {"realloc_f32", "heap_realloc_f32_c"},
    {"free_f32", "heap_free_f32_c"},
    {"copy_i32_at", "heap_copy_i32_at_c"},
    {"copy_u8_at", "heap_copy_u8_at_c"},
    {"copy_f32_at", "heap_copy_f32_at_c"},
    {"copy_u64_at", "heap_copy_u64_at_c"},
    {"copy_f64_at", "heap_copy_f64_at_c"},
    {"copy_i32_ptr_i32_i32_ptr_i32", "heap_copy_i32_at_c"},
    {"copy_u8_ptr_i32_u8_ptr_i32", "heap_copy_u8_at_c"},
    {"copy_f32_ptr_i32_f32_ptr_i32", "heap_copy_f32_at_c"},
    {"copy_u64_ptr_i32_u64_ptr_i32", "heap_copy_u64_at_c"},
    {"copy_f64_ptr_i32_f64_ptr_i32", "heap_copy_f64_at_c"},
    {"arena64_init", "heap_arena64_init_c"},
    {"arena64_alloc", "heap_arena64_alloc_c"},
    {"arena64_deinit", "heap_arena64_deinit_c"},
    {"ptr_mod", "heap_ptr_mod_c"},
};

/** 表项精确匹配 name；命中则写入 sym_out 并返回目标名长度。 */
static int32_t glue_try_std_heap_redirect_sym(const uint8_t *name, int32_t name_len, uint8_t *sym_out,
                                                int32_t out_cap) {
  size_t i;
  for (i = 0; i < sizeof(kGlueStdHeapRedirect) / sizeof(kGlueStdHeapRedirect[0]); i++) {
    const char *from = kGlueStdHeapRedirect[i].from;
    const char *to = kGlueStdHeapRedirect[i].to;
    size_t flen = strlen(from);
    size_t tlen = strlen(to);
    if ((int32_t)flen != name_len || memcmp(name, from, flen) != 0)
      continue;
    if ((int32_t)tlen + 1 > out_cap)
      return 0;
    memcpy(sym_out, to, tlen);
    return (int32_t)tlen;
  }
  return 0;
}

/** fs_/net_/std.heap 薄包装 call 重定向到 *_c（无表项则返回 0）。 */
int32_t pipeline_asm_redirect_std_c_wrapper_sym(uint8_t *name, int32_t name_len, uint8_t *sym_out, int32_t out_cap) {
  int32_t hlen;
  if (!name || name_len <= 0 || !sym_out || out_cap <= 0)
    return 0;
  if (name_len >= 2 && name[name_len - 2] == '_' && name[name_len - 1] == 'c')
    return 0;
  hlen = glue_try_std_heap_redirect_sym(name, name_len, sym_out, out_cap);
  if (hlen > 0)
    return hlen;
  if (name_len + 2 >= out_cap)
    return 0;
  if (name_len >= 3 && memcmp(name, "fs_", 3) == 0) {
    memcpy(sym_out, name, (size_t)name_len);
    sym_out[name_len] = '_';
    sym_out[name_len + 1] = 'c';
    return name_len + 2;
  }
  if (name_len >= 4 && memcmp(name, "net_", 4) == 0) {
    memcpy(sym_out, name, (size_t)name_len);
    sym_out[name_len] = '_';
    sym_out[name_len + 1] = 'c';
    return name_len + 2;
  }
  /** hello.sx 等入口裸调 print_str：asm 跳过 std.io dep emit，链 runtime_asm_io_stubs 的 std_io_print_str。 */
  if (name_len == 9 && memcmp(name, "print_str", 9) == 0) {
    memcpy(sym_out, "std_io_print_str", 16);
    return 16;
  }
  /** std.fmt.println(ptr,len)：跳过 fmt co-emit 时链 runtime_asm_io_stubs 桩。 */
  if (name_len == 14 && memcmp(name, "std_fmt_println", 14) == 0) {
    memcpy(sym_out, "std_fmt_println", 14);
    return 14;
  }
  /**
   * co-emit std.encoding/mod.sx：std_encoding_utf8_valid -> encoding_utf8_valid_c（链 std/encoding/encoding.o）。
   */
  if (name_len > 13 && memcmp(name, "std_encoding_", 13) == 0) {
    const int32_t suffix_len = name_len - 13;
    const int32_t out_len = 9 + suffix_len + 2;
    if (out_len >= out_cap)
      return 0;
    memcpy(sym_out, "encoding_", 9);
    memcpy(sym_out + 9, name + 13, (size_t)suffix_len);
    sym_out[9 + suffix_len] = '_';
    sym_out[9 + suffix_len + 1] = 'c';
    return out_len;
  }
  /**
   * co-emit std.string/mod.sx 时 extern shux_string_* 带 std_string_ 前缀；
   * 链 string.o 中无模块前缀的 shux_string_* 快路径。
   */
  if (name_len > 11 && memcmp(name, "std_string_", 11) == 0) {
    const int32_t suffix_len = name_len - 11;
    if (suffix_len + 1 > out_cap)
      return 0;
    if (suffix_len >= 12 && memcmp(name + 11, "shux_string_", 12) == 0) {
      memcpy(sym_out, name + 11, (size_t)suffix_len);
      return suffix_len;
    }
  }
  return 0;
}
