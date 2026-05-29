/**
 * pipeline_glue.c — 与 -E 产出的 pipeline_gen.c 同属一个翻译单元的 C 胶水代码。
 *
 * 用法：pipeline_gen.c 末尾有 #include "pipeline_glue.c"（由 runtime.c -E 或 build_patch 追加），
 * 编译 pipeline_gen.c 时由 cc 在同一 TU 内包含本文件，故可直接使用上方已定义的 ast_* / codegen_* 等类型。
 * 不单独编译；无补丁、无 sed，所有逻辑在此源文件内从根源提供。
 *
 * parser.su 聚合 -o 可执行时，runtime 在含入前 #define SHU_PARSER_EXE_PIPELINE_GLUE：省略依赖
 * platform_elf_ElfCodegenCtx 完整定义与 codegen.o 转发符号的片段，避免单文件 TU 编译失败。
 *
 * ── extern 消费者索引（10.4.2 自举；删函数前 grep 本表）────────────────────────────
 * | 符号 | 消费者 |
 * |------|--------|
 * | parser_slice_from_buf / lexer_parser_slice_from_buf / pipeline_source_slice | parser.su, lexer.su, pipeline.su |
 * | parser_lex_from_lexer_result_ptr_into | parser.su（*LexerResult → *Lexer，避 typeck 链式 FIELD_ACCESS） |
 * | pipeline_run_su_pipeline | runtime.c（C 包装 buf+len） |
 * | pipeline_sizeof_* / pipeline_arena_offset_num_types | parser.su, lsp_diag.su；**PipelineDepCtx 增字段时须同步** runtime.c / lsp_diag_pipeline_sizes.c / ast.su |
 * | pipeline_expr_ref_is_assign_lvalue | parser.su |
 * | compound_assign_token_to_expr_kind_from_glue | parser.su |
 * | pipeline_expr_* / ast_pipeline_expr_* / implicit_tail_expr_disallowed_by_glue | ast.su, typeck.su |
 * | pipeline_type_* / pipeline_module_struct_layout_* | typeck.su, codegen.su |
 * | pipeline_module_func_* / pipeline_arena_func_* | parser.su |
 * | pipeline_asm_array_lit_elem_type_ref | asm/backend.su |
 * | pipeline_asm_cmp_cc_for_expr_kind_ord / pipeline_asm_arm64_cset_cond_enc_from_cc | asm/backend.su, arch/arm64_enc.su |
 * | pipeline_module_func_is_extern_at / pipeline_module_func_body_ref_at / pipeline_module_func_name_len_at | asm/backend.su, arch/arm64.su |
 * | pipeline_backend_get_return_expr_ref_at / pipeline_arm64_get_return_lit_ref_at | asm/backend.su, arch/arm64.su |
 * | std_io_driver_submit_*_batch_buf | pipeline_gen.c 同 TU（io.o 批量读写） |
 * | driver_get_module_num_funcs / driver_get_module_main_func_index | runtime.c 烟测 |
 * | driver_diagnostic_entry_* | pipeline.su（日常 no-op） |
 * 原因：SU/asm 对大 struct 按值读写字段或 enum 比较易撕裂/ typeck 失败，暂保留 C 指针读池。
 */

/* struct shulang_slice_uint8_t 已由 -E 产出的 pipeline_gen.c 上方定义，不在此重复。 */
#include <stddef.h>
#include <string.h>
#include <stdlib.h>

/** ast_pool.c 提供；须在下方 glue 之前声明（ast_pool.c 在文件末尾 #include）。 */
struct ast_Func *pipeline_module_func_ptr(struct ast_Module *m, int32_t func_index);
int32_t pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);
/** ast_pool.c 提供；pipeline_backend_get_return_expr_ref 在 #include ast_pool 之前调用。 */
int32_t pipeline_block_labeled_return_expr_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
struct ast_Type *pipeline_arena_type_ptr(struct ast_ASTArena *a, int32_t ref);
struct ast_Expr *pipeline_arena_expr_ptr(struct ast_ASTArena *a, int32_t ref);
struct ast_Block *pipeline_arena_block_ptr(struct ast_ASTArena *a, int32_t ref);
struct ast_Func *pipeline_arena_func_ptr(struct ast_ASTArena *a, int32_t ref);
int32_t pipeline_arena_type_alloc(struct ast_ASTArena *a);
int32_t pipeline_arena_expr_alloc(struct ast_ASTArena *a);
int32_t pipeline_arena_block_alloc(struct ast_ASTArena *a);
int32_t pipeline_arena_func_alloc(struct ast_ASTArena *a);
int32_t pipeline_module_struct_layout_alloc(struct ast_Module *m);
void pipeline_module_struct_layout_reset_slot(struct ast_Module *m, int32_t idx);
void pipeline_module_struct_layout_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
void pipeline_module_struct_layout_set_field(struct ast_Module *m, int32_t li, int32_t j, uint8_t *fname_bytes,
                                              int32_t fname_len, int32_t ftype_ref, int32_t foff);
int32_t pipeline_module_struct_layout_name_len(struct ast_Module *m, int32_t idx);
uint8_t pipeline_module_struct_layout_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
void pipeline_module_struct_layout_name_into(struct ast_Module *m, int32_t idx, uint8_t *out64);
extern int32_t typeck_typeck_struct_layout_metrics(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   int32_t li, int32_t depth, int32_t check_pad,
                                                   int32_t *out_sz, int32_t *out_al);
extern int typeck_float64_bits_lo(double d);
extern int typeck_float64_bits_hi(double d);
extern int32_t typeck_su_type_size_from_layout_glue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t li, int32_t depth);
int32_t pipeline_module_struct_layout_num_fields(struct ast_Module *m, int32_t idx);
int32_t pipeline_module_num_struct_layouts_at(struct ast_Module *m);
void pipeline_module_struct_layout_set_num_fields(struct ast_Module *m, int32_t idx, int32_t nf);
int32_t pipeline_module_struct_layout_field_type_ref(struct ast_Module *m, int32_t li, int32_t j);
int32_t pipeline_module_struct_layout_field_name_len(struct ast_Module *m, int32_t li, int32_t j);
void pipeline_module_struct_layout_field_name_into(struct ast_Module *m, int32_t li, int32_t j, uint8_t *out64);
int32_t pipeline_module_struct_layout_field_offset_at(struct ast_Module *m, int32_t li, int32_t j);
/** func 形参池读 API；glue 内 asm 转发在 ast_pool.c 定义之前调用。 */
int32_t pipeline_module_func_num_params_at(struct ast_Module *m, int32_t func_index);
int32_t pipeline_module_func_name_len_at(struct ast_Module *m, int32_t func_index);
void pipeline_module_func_name_copy64(struct ast_Module *m, int32_t func_index, uint8_t *dst);
int32_t pipeline_module_func_is_extern_at(struct ast_Module *m, int32_t func_index);
int32_t pipeline_module_func_body_ref_at(struct ast_Module *m, int32_t func_index);
int32_t pipeline_module_func_param_name_len_at(struct ast_Module *m, int32_t func_index, int32_t param_index);
void pipeline_module_func_param_name_copy32(struct ast_Module *m, int32_t func_index, int32_t param_index,
                                            uint8_t *dst);
/** asm .o 失败时打印 ElfCodegenCtx 计数（ast_pool.c）。 */
void pipeline_elf_ctx_diag_stderr(uint8_t *ctx_bytes);
/** macho/elf：reloc_sym_names 行读写（ast_pool.c）。 */
uint8_t *pipeline_elf_ctx_reloc_sym_name_ptr(uint8_t *ctx_bytes, int32_t idx);
void pipeline_elf_ctx_reloc_sym_name_copy64(uint8_t *ctx_bytes, int32_t idx, uint8_t *dst);
int32_t pipeline_elf_ctx_reloc_name_len(uint8_t *ctx_bytes, int32_t idx);
/** pipeline.su：PipelineDepCtx / CodegenOutBuf 字段 glue（ast_pool.c）。 */
int32_t pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_module_num_funcs(struct ast_Module *m);
int32_t pipeline_module_main_func_index(struct ast_Module *m);
int32_t pipeline_arena_num_types(struct ast_ASTArena *a);
int32_t pipeline_dep_ctx_asm_entry_module_only(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_dep_ctx_check_only_mode(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_dep_ctx_use_asm_backend(struct ast_PipelineDepCtx *ctx);
uint8_t pipeline_dep_ctx_entry_dir_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off);
int32_t codegen_out_buf_len(struct codegen_CodegenOutBuf *out);
void codegen_out_buf_set_len(struct codegen_CodegenOutBuf *out, int32_t n);

/** 非 0：parse_into_buf 遇解析失败函数时整文件失败，不静默 skip。 */
int32_t parser_parse_strict_enabled(void) {
  extern int32_t driver_parse_strict_enabled(void);
  return driver_parse_strict_enabled();
}

/** parse_into_buf 跳过函数时的 stderr 诊断（见 runtime.c driver_diagnostic_parse_skip_function）。 */
void parser_diagnostic_parse_skip(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, uint8_t *name) {
  extern void driver_diagnostic_parse_skip_function(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len,
                                                    const uint8_t *name);
  driver_diagnostic_parse_skip_function(byte_pos, num_funcs_so_far, name_len, name);
}

/** 从 (data, len) 构造 slice，供 parser.su 内 parse_into_buf 调 parse_one_function_impl 时使用。 */
struct shulang_slice_uint8_t parser_slice_from_buf(uint8_t *data, int32_t len) {
  struct shulang_slice_uint8_t s;
  s.data = data;
  s.length = (size_t)(len >= 0 ? len : 0);
  return s;
}

/** parser.su：usize 起点回溯；asm 自 typecheck 对 usize/i32 混算失败，保留薄 C sidecar。 */
size_t parser_lexer_pos_before(size_t end_pos, int32_t run_len) {
  if (run_len <= 0)
    return end_pos;
  return end_pos - (size_t)run_len;
}

/**
 * lexer.su 内的 extern：Codegen 会带 lexer_ 模块前缀，否则会链接到不存在的 lexer_parser_slice_from_buf。
 * 与 parser_slice_from_buf 等价，仅别名。
 */
struct shulang_slice_uint8_t lexer_parser_slice_from_buf(uint8_t *data, int32_t len) {
  return parser_slice_from_buf(data, len);
}

/**
 * parser.su：从 *LexerResult 拷贝 next_lex 三字段到 *Lexer。
 * 避免 `r.next_lex.pos` 等 *T 链式 FIELD_ACCESS 在 typeck 上 RHS 解析为 ?。
 */
void parser_lex_from_lexer_result_ptr_into(struct lexer_Lexer *out, struct lexer_LexerResult *r) {
  if (out == NULL || r == NULL)
    return;
  out->pos = r->next_lex.pos;
  out->line = r->next_lex.line;
  out->col = r->next_lex.col;
}

/** CollectImportsResult.lex → *Lexer；嵌套字段 typeck 不落码时的 C 侧拷贝。 */
void parser_lex_copy_from_collect_imports(struct lexer_Lexer *out, struct parser_CollectImportsResult res) {
  if (out == NULL)
    return;
  out->pos = res.lex.pos;
  out->line = res.lex.line;
  out->col = res.lex.col;
}

/** LexerResult.next_lex → *Lexer。 */
void parser_lex_from_lexer_result_val_into(struct lexer_Lexer *out, struct lexer_LexerResult r) {
  if (out == NULL)
    return;
  out->pos = r.next_lex.pos;
  out->line = r.next_lex.line;
  out->col = r.next_lex.col;
}

/** *OneFuncResult.next_lex → *Lexer（OneFuncResult 过大，仅指针路径）。 */
void parser_lex_from_onefunc_result_ptr_into(struct lexer_Lexer *out, struct parser_OneFuncResult *res) {
  if (out == NULL || res == NULL)
    return;
  out->pos = res->next_lex.pos;
  out->line = res->next_lex.line;
  out->col = res->next_lex.col;
}

/** 供 pipeline.su run_su_pipeline_impl 使用：与 parser_slice_from_buf 相同，避免 -E 对 parser_* 符号双重前缀。 */
struct shulang_slice_uint8_t pipeline_source_slice(uint8_t *data, int32_t len) {
  return parser_slice_from_buf(data, len);
}

#ifndef SHU_PARSER_EXE_PIPELINE_GLUE
/* C 包装：以 (data, len) 形式调用 pipeline，impl 内用 parse_into_with_init_buf 解析，无需组 slice。 */
extern int32_t pipeline_run_su_pipeline_impl(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data, size_t source_len, struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx);

int32_t pipeline_run_su_pipeline(struct ast_Module *module, struct ast_ASTArena *arena, const uint8_t *source_data, size_t source_len, struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx) {
  return pipeline_run_su_pipeline_impl(module, arena, (uint8_t *)source_data, source_len, out_buf, ctx);
}
#endif /* !SHU_PARSER_EXE_PIPELINE_GLUE */

size_t pipeline_sizeof_arena(void) { return sizeof(struct ast_ASTArena); }
size_t pipeline_sizeof_module(void) { return sizeof(struct ast_Module); }
/** LSP / lsp_diag.su：PipelineDepCtx 体量大（含 4MiB×2 缓冲），一次性 calloc 后 memset 复用。 */
size_t pipeline_sizeof_dep_ctx(void) { return sizeof(struct ast_PipelineDepCtx); }
/** parser OneFuncResult 体量大（256×64 let 名等）；parse_block_into 堆分配 scratch，避免递归块解析栈溢出。 */
size_t pipeline_sizeof_onefunc_result(void) { return (size_t)8192; }
size_t pipeline_arena_offset_num_types(void) { return offsetof(struct ast_ASTArena, num_types); }
#ifndef SHU_PARSER_EXE_PIPELINE_GLUE
size_t pipeline_sizeof_elf_ctx(void) { return sizeof(struct platform_elf_ElfCodegenCtx); }
#else
/** parser 聚合 exe TU 不含 ElfCodegenCtx 定义：占位返回 0（该路径不调 asm 全流程 sizeof）。 */
size_t pipeline_sizeof_elf_ctx(void) { return (size_t)0; }
#endif /* SHU_PARSER_EXE_PIPELINE_GLUE */

#include <stdio.h>
void pipeline_debug_module_funcs(void *m) {
  struct ast_Module *mod = (struct ast_Module *)m;
  int i, n = (int)mod->num_funcs;
  for (i = 0; i < n; i++) {
    struct ast_Func *f = pipeline_module_func_ptr(mod, i);
    int len = f ? (int)f->name_len : 0;
    if (f)
      fprintf(stderr, "[DEBUG] module func[%d] name_len=%d name=%.*s\n", i, len,
              len > 0 && len <= 64 ? len : 0, f->name);
  }
}

/** 供 runtime.c 诊断：返回 module 的 num_funcs（需与 pipeline 同 TU 以用 ast_Module 布局）。 */
int driver_get_module_num_funcs(void *m) {
  return m ? (int)((struct ast_Module *)m)->num_funcs : 0;
}

/** 供 runtime.c 烟测摘要：解析后 module.main_func_index（无 main 为 -1，与 pipeline.su parse_into_set_main_index 一致）。 */
int driver_get_module_main_func_index(void *m) {
  return m ? (int)((struct ast_Module *)m)->main_func_index : -2;
}

/** 诊断：解析 entry 后打印 main 的 body_ref；日常构建关闭，排查 main 空体时取消下方注释。由 pipeline.su 在 parse 后 / codegen 前调用。 */
void driver_diagnostic_entry_module(struct ast_Module *mod, struct ast_ASTArena *a) {
  const char *list_env;
  int32_t i;
  int32_t j;
  (void)a;
  /** SHU_ASM_LIST_FUNCS=1：列出 module 全部函数名与 extern 标记，排查 asm 单编缺符号（如 parse_into_buf 未注册）。 */
  list_env = getenv("SHU_ASM_LIST_FUNCS");
  if (list_env && list_env[0] != '\0' && list_env[0] != '0' && mod) {
    for (i = 0; i < (int32_t)mod->num_funcs; i++) {
      uint8_t nm[64];
      int32_t nl = pipeline_module_func_name_len_at(mod, i);
      pipeline_module_func_name_copy64(mod, i, nm);
      fprintf(stderr, "asm_list: #%d extern=%d body_ref=%d name=",
              (int)i, (int)pipeline_module_func_is_extern_at(mod, i),
              (int)pipeline_module_func_body_ref_at(mod, i));
      for (j = 0; j < nl && j < 64; j++)
        fputc((char)nm[j], stderr);
      fputc('\n', stderr);
    }
    fflush(stderr);
    return;
  }
  (void)mod;
  /* if (mod && (mod->main_func_index >= 0 && mod->main_func_index < mod->num_funcs)) {
    int32_t br = mod->funcs[mod->main_func_index].body_ref;
    fprintf(stderr, "[diag] entry num_funcs=%d main_idx=%d body_ref=%d\n",
            (int)mod->num_funcs, (int)mod->main_func_index, (int)br);
  } else if (mod) {
    fprintf(stderr, "[diag] entry num_funcs=%d main_idx=%d (invalid)\n",
            (int)mod->num_funcs, (int)mod->main_func_index);
  } */
}

/** pipeline.su -E 产出 typeck_ 前缀；实现于 runtime.c（pipeline_su.o 编译期须可见声明）。 */
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern size_t driver_pipeline_entry_source_len(void);
extern int32_t driver_typeck_skip_large_entry(void);
extern int32_t driver_asm_build_skip_typeck(void);

void typeck_driver_diagnostic_after_entry_parse(int32_t num_funcs) {
  driver_diagnostic_after_entry_parse(num_funcs);
}

/** pipeline.su 经 typeck_ 前缀调用；实现于 runtime.c。 */
extern void driver_diagnostic_pipe_marker(int32_t id);

void typeck_driver_diagnostic_pipe_marker(int32_t id) {
  driver_diagnostic_pipe_marker(id);
}

/** typeck.su / pipeline.su：入口源码长度（runtime.c）。 */
size_t typeck_driver_pipeline_entry_source_len(void) {
  return driver_pipeline_entry_source_len();
}

size_t pipeline_driver_pipeline_entry_source_len(void) {
  return driver_pipeline_entry_source_len();
}

void pipeline_driver_diagnostic_pipe_marker(int32_t id) {
  driver_diagnostic_pipe_marker(id);
}

extern int32_t driver_check_only_get(void);

int32_t shu_pipeline_check_only(void) {
  return driver_check_only_get();
}

/** 兼容旧 glue 名。 */
int32_t pipeline_shu_pipeline_check_only(void) {
  return shu_pipeline_check_only();
}

int32_t typeck_driver_typeck_skip_large_entry(void) {
  return driver_typeck_skip_large_entry();
}

int32_t typeck_driver_asm_build_skip_typeck(void) {
  return driver_asm_build_skip_typeck();
}

int32_t pipeline_driver_typeck_skip_large_entry(void) {
  return driver_typeck_skip_large_entry();
}

/** build_shu_asm：SHU_ASM_BUILD_SKIP_TYPECK=1 时 pipeline 跳过 .su typeck。 */
int32_t pipeline_driver_asm_build_skip_typeck(void) {
  return driver_asm_build_skip_typeck();
}

/** 诊断：解析后打印 main 对应 body block 的 num_stmt_order（C 侧调用）；日常构建保留实现不调用，排查时在 runtime.c 恢复调用。 */
void driver_diagnostic_entry_block_after_parse(void *mod, void *arena) {
  struct ast_Module *m = (struct ast_Module *)mod;
  struct ast_ASTArena *a = (struct ast_ASTArena *)arena;
  if (!m || !a || m->main_func_index < 0 || m->main_func_index >= m->num_funcs)
    return;
  {
    struct ast_Func *mf = pipeline_module_func_ptr(m, m->main_func_index);
    int32_t br = mf ? (int32_t)mf->body_ref : 0;
    if (br <= 0 || br > a->num_blocks)
      return;
    (void)br;
    (void)a;
    /* struct ast_Block b = ast_ast_arena_block_get(a, br);
    fprintf(stderr, "[diag] after_parse body_ref=%d num_blocks=%d block.num_stmt_order=%d\n",
            (int)br, (int)a->num_blocks, (int)b.num_stmt_order); */
  }
}

/* std.io.driver 单次 _buf 声明与 inline 已由 -E 产出在 pipeline_gen.c 顶部（runtime.c -E 路径 preamble），此处仅保留批量读写桩。 */

/* std.io.driver 批量读写桩：pipeline_gen.c 同 TU 已定义 struct std_io_driver_Buffer；io.o 提供 io_read_batch_buf/io_write_batch_buf，供 shu_su 链接时解析。 */
extern ptrdiff_t io_read_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms);
extern ptrdiff_t io_write_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms);

int32_t std_io_driver_submit_read_batch_buf(size_t handle, struct std_io_driver_Buffer *bufs, int32_t n, uint32_t timeout_ms) {
  ptrdiff_t r = io_read_batch_buf((int)handle, bufs, n, timeout_ms);
  return (r < 0) ? -1 : (int32_t)r;
}

int32_t std_io_driver_submit_write_batch_buf(size_t handle, struct std_io_driver_Buffer *bufs, int32_t n, uint32_t timeout_ms) {
  ptrdiff_t r = io_write_batch_buf((int)handle, bufs, n, timeout_ms);
  return (r < 0) ? -1 : (int32_t)r;
}

/** 读池中 expr.kind；仅供本文件与 glue 导出函数使用（SU 无法用 Expr 局部安全 typeck）。 */
static enum ast_ExprKind glue_arena_expr_kind_at_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return ast_ExprKind_EXPR_LIT;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  return ex ? ex->kind : ast_ExprKind_EXPR_LIT;
}

/**
 * parser.su expr_ref_is_assign_lvalue：与 shu-c 生成码对 struct 直读一致。
 * SU 中对「let e: Expr = ast_arena_expr_get(...)」再写 e.kind == … 会在 .su typeck 路径失败（见 ast.su 注释）；由 C 从池读 kind / is_enum_variant。
 * 返回 1 表示可作为赋值左值，0 表示否。
 */
int32_t pipeline_expr_ref_is_assign_lvalue(struct ast_ASTArena *a, int32_t expr_ref) {
  enum ast_ExprKind kd;
  struct ast_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs) {
    return 0;
  }
  kd = glue_arena_expr_kind_at_ref(a, expr_ref);
  if (kd == ast_ExprKind_EXPR_VAR || kd == ast_ExprKind_EXPR_INDEX) {
    return 1;
  }
  if (kd != ast_ExprKind_EXPR_FIELD_ACCESS) {
    return 0;
  }
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  return ex && ex->field_access_is_enum_variant == 0 ? 1 : 0;
}

/**
 * parser.su compound_assign_token_to_expr_kind：在 C 内完成 TokenKind→ExprKind 映射，
 * 避免 .su 中 `return ExprKind.*` 与枚举比较在 typeck 下失败；符号名供 parser extern 原样链接。
 */
enum ast_ExprKind compound_assign_token_to_expr_kind_from_glue(enum token_TokenKind kind) {
  if (kind == token_TokenKind_TOKEN_PLUS_EQ) return ast_ExprKind_EXPR_ADD_ASSIGN;
  if (kind == token_TokenKind_TOKEN_MINUS_EQ) return ast_ExprKind_EXPR_SUB_ASSIGN;
  if (kind == token_TokenKind_TOKEN_STAR_EQ) return ast_ExprKind_EXPR_MUL_ASSIGN;
  if (kind == token_TokenKind_TOKEN_SLASH_EQ) return ast_ExprKind_EXPR_DIV_ASSIGN;
  if (kind == token_TokenKind_TOKEN_PERCENT_EQ) return ast_ExprKind_EXPR_MOD_ASSIGN;
  if (kind == token_TokenKind_TOKEN_AMP_EQ) return ast_ExprKind_EXPR_BITAND_ASSIGN;
  if (kind == token_TokenKind_TOKEN_PIPE_EQ) return ast_ExprKind_EXPR_BITOR_ASSIGN;
  if (kind == token_TokenKind_TOKEN_CARET_EQ) return ast_ExprKind_EXPR_BITXOR_ASSIGN;
  if (kind == token_TokenKind_TOKEN_LSHIFT_EQ) return ast_ExprKind_EXPR_SHL_ASSIGN;
  return ast_ExprKind_EXPR_SHR_ASSIGN;
}

/**
 * ast.su extern：块末若为 RETURN/PANIC/BREAK/CONTINUE，返回 1（禁止隐式尾）；非法 ref 视为 1。
 * 符号名 deliberately 无前缀，供 SU「extern function」原样映射，避免与其它 ast_ast_* extern 串联重复前缀。
 */
/** ast.su：池槽 CALL 解析占位 -1（避免 SU 对 Expr 尾字段 FIELD_ACCESS 缺 layout）。 */
void pipeline_expr_init_call_resolve_at_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return;
  ex->call_resolved_func_index = -1;
  ex->call_resolved_dep_index = -1;
}

/** ast.su / typeck.su：typeck 命中后写入 call_resolved_*。 */
void pipeline_expr_apply_call_resolve(struct ast_ASTArena *a, int32_t expr_ref, int32_t dep_ix,
                                    int32_t func_ix) {
  struct ast_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return;
  ex->call_resolved_dep_index = dep_ix;
  ex->call_resolved_func_index = func_ix;
}

/** parser.su expr_set_common_zeros：对堆/池上 Expr 指针写 call_resolved 占位。 */
void pipeline_expr_ptr_init_call_resolve(struct ast_Expr *e) {
  if (!e)
    return;
  e->call_resolved_func_index = -1;
  e->call_resolved_dep_index = -1;
}

/** import ast 时 codegen 可能加 ast_ 前缀；转发到 pipeline_expr_* 裸符号。 */
void ast_pipeline_expr_ptr_init_call_resolve(struct ast_Expr *e) {
  pipeline_expr_ptr_init_call_resolve(e);
}

void ast_pipeline_expr_init_call_resolve_at_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  pipeline_expr_init_call_resolve_at_ref(a, expr_ref);
}

void ast_pipeline_expr_apply_call_resolve(struct ast_ASTArena *a, int32_t expr_ref, int32_t dep_ix,
                                         int32_t func_ix) {
  pipeline_expr_apply_call_resolve(a, expr_ref, dep_ix, func_ix);
}

/** typeck 解析 import/本模块 call 后写入的 dep 槽下标；-1 表示本模块，无效 expr 返回 -2。 */
int32_t pipeline_expr_call_resolved_dep_index_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return -2;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return -2;
  return ex->call_resolved_dep_index;
}

/** typeck 解析 call 后写入的被调函数在 dep/本模块中的下标；未解析返回 -1。 */
int32_t pipeline_expr_call_resolved_func_index_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return -1;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  return ex->call_resolved_func_index;
}

int implicit_tail_expr_disallowed_by_glue(struct ast_ASTArena *a, int32_t expr_ref) {
  enum ast_ExprKind kd;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return 1;
  kd = glue_arena_expr_kind_at_ref(a, expr_ref);
  if (kd == ast_ExprKind_EXPR_RETURN || kd == ast_ExprKind_EXPR_PANIC ||
      kd == ast_ExprKind_EXPR_BREAK || kd == ast_ExprKind_EXPR_CONTINUE)
    return 1;
  return 0;
}

/**
 * 从 arena.types[ref-1] 拷贝整块 name[64] 到调用方缓冲区（memcpy），避免 ast_ast_arena_type_get
 * 在大 struct ast_Type 场景下按值返回时后端只传部分字段导致名段撕裂（如 AArch64 上布局查找失败）。
 * 返回 name_len；ref 无效或越界返回 0。
 */
int32_t pipeline_type_named_name_into(struct ast_ASTArena *arena, int32_t ref, uint8_t *out64) {
  struct ast_Type *t;
  if (!arena || !out64 || ref <= 0 || ref > arena->num_types)
    return 0;
  t = pipeline_arena_type_ptr(arena, ref);
  if (!t)
    return 0;
  memcpy(out64, t->name, sizeof(t->name));
  return t->name_len;
}

/**
 * 读取 arena.types[ref-1].kind 作为与 TypeKind ordinal 对齐的枚举序数。
 * ref 无效时返回 -1。
 */
int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *arena, int32_t ref) {
  struct ast_Type *t;
  if (!arena || ref <= 0 || ref > arena->num_types)
    return -1;
  t = pipeline_arena_type_ptr(arena, ref);
  return t ? (int32_t)t->kind : -1;
}

/**
 * 读取 arena.types[ref-1].elem_type_ref（指针指向元素类型、向量元素类型等）。
 * ref 无效时返回 0。
 */
int32_t pipeline_type_elem_ref_at(struct ast_ASTArena *arena, int32_t ref) {
  struct ast_Type *t;
  if (!arena || ref <= 0 || ref > arena->num_types)
    return 0;
  t = pipeline_arena_type_ptr(arena, ref);
  return t ? t->elem_type_ref : 0;
}

/**
 * asm/backend.su asm_expr_array_elem_store_sz_bytes：从数组字面量 expr 池 ref 取 TYPE_ARRAY 的 elem_type_ref。
 * 无效、非数组或 elem 缺失时返回 0。在 C 内读池，避免 .su 中 `let e: Expr = ast_arena_expr_get` 后字段访问触发 typeck 失败，
 * 亦避免 backend import codegen 时 pipeline_type_* 调用被编成 codegen_ 前缀导致链接未定义。
 */
int32_t pipeline_asm_array_lit_elem_type_ref(struct ast_ASTArena *arena, int32_t array_lit_expr_ref) {
  int32_t arr_tr;
  int32_t tk;
  struct ast_Expr *ex;
  if (!arena || array_lit_expr_ref <= 0 || array_lit_expr_ref > arena->num_exprs)
    return 0;
  ex = pipeline_arena_expr_ptr(arena, array_lit_expr_ref);
  if (!ex)
    return 0;
  arr_tr = ex->resolved_type_ref;
  if (arr_tr <= 0)
    return 0;
  tk = pipeline_type_kind_ord_at(arena, arr_tr);
  if (tk != 10)
    return 0;
  return pipeline_type_elem_ref_at(arena, arr_tr);
}

/**
 * 比较表达式 ExprKind 序数 → enc_cmp_setcc 的 cc（0=eq, 1=ne, 2=lt, 3=le, 4=gt, 5=ge）。
 * backend.su 多路 `if (kind==…) cc=N` 经 shu-c -E 后可能全部执行，须在 C 内 switch 一次性映射。
 */
int32_t pipeline_asm_cmp_cc_for_expr_kind_ord(int32_t kind_ord) {
  switch (kind_ord) {
  case 14:
    return 0; /* EXPR_EQ */
  case 15:
    return 1; /* EXPR_NE */
  case 16:
    return 2; /* EXPR_LT */
  case 17:
    return 3; /* EXPR_LE */
  case 18:
    return 4; /* EXPR_GT */
  case 19:
    return 5; /* EXPR_GE */
  default:
    return -1;
  }
}

/**
 * x86 风格 cc → ARM64 CSET 机器码 cond 域（0–15）。
 * CSET Wd,<cond> 等价于 CSINC Wd,WZR,WZR,invert(<cond>)，故编码域须 invert，与 GAS `cset w0, lt` 语义一致。
 * cc: 0=eq, 1=ne, 2=lt, 3=le, 4=gt, 5=ge。
 */
int32_t pipeline_asm_arm64_cset_cond_enc_from_cc(int32_t cc) {
  switch (cc) {
  case 0:
    return 1; /* eq → invert(ne) */
  case 1:
    return 0; /* ne → invert(eq) */
  case 2:
    return 10; /* lt → invert(ge) */
  case 3:
    return 12; /* le → invert(gt) */
  case 4:
    return 13; /* gt → invert(le) */
  case 5:
    return 11; /* ge → invert(lt) */
  default:
    return 0;
  }
}

/**
 * seed asm 后端（asm_backend_partial.o）提供的 enc/emit 符号；在 C 内实现二元运算，
 * 避免 shu-c -E 将 if/return 包进 statement expression 导致 emit_expr_elf fallthrough。
 */
struct platform_elf_ElfCodegenCtx;
struct backend_AsmFuncCtx;

extern int32_t backend_emit_expr_elf_slow(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                          int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_push_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_add_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_sub_rbx_rax_then_mov_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_sub_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_imul_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_idiv_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_cltd_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_edx_to_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_rem_mod_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_cmp_setcc_movzbl_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t cc, int32_t ta);
extern int32_t backend_enc_jz_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                   int32_t ta);
extern int32_t backend_enc_jmp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                    int32_t ta);
extern int32_t backend_enc_label_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len,
                                      int32_t is_func, int32_t ta);
extern int32_t backend_emit_next_label(struct backend_AsmFuncCtx *ctx, uint8_t *buf, int32_t buf_size);
extern void backend_ensure_block_local_slots(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena,
                                             int32_t block_ref);
extern int32_t backend_emit_block_body_sync_elf(struct ast_ASTArena *arena,
                                                struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t block_ref,
                                                struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t backend_block_slot_base_for(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena,
                                           int32_t block_ref);
extern int32_t backend_asm_ctx_slot_offset(struct backend_AsmFuncCtx *ctx, int32_t slot_idx);
extern int32_t backend_enc_store_rax_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off,
                                                 int32_t ta);
/** 将栈槽地址装入 rax/x0（定长数组 let 无 init 时写指针用）。 */
extern int32_t backend_enc_lea_rbp_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                               int32_t ta);
extern int32_t backend_emit_while_loop_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                           int32_t block_ref, int32_t loop_idx, struct backend_AsmFuncCtx *ctx,
                                           int32_t ta);
extern int32_t backend_emit_for_loop_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                         int32_t block_ref, int32_t for_idx, struct backend_AsmFuncCtx *ctx,
                                         int32_t ta);

int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_int_val_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_binop_left_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_binop_right_ref_at(struct ast_ASTArena *a, int32_t expr_ref);

#define PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED (-99)

int32_t pipeline_asm_emit_expr_elf_fast(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                        int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);

/** 字面量判定：kind 序 0/2。 */
static int32_t pipeline_asm_expr_lit_i32_at_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t *out_imm) {
  int32_t ko;
  if (expr_ref == 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 0 || ko == 2) {
    *out_imm = pipeline_expr_int_val_at(arena, expr_ref);
    return 1;
  }
  return 0;
}

/** 快速路径未命中时走 backend_emit_expr_elf（slow）。 */
static int32_t pipeline_asm_emit_expr_elf_rec(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                              int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t r = pipeline_asm_emit_expr_elf_fast(arena, elf_ctx, expr_ref, ctx, ta);
  if (r != PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED)
    return r;
  return backend_emit_expr_elf_slow(arena, elf_ctx, expr_ref, ctx, ta);
}

static int32_t pipeline_asm_emit_binop_add_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   int32_t left_ref, int32_t right_ref, struct backend_AsmFuncCtx *ctx,
                                                   int32_t ta) {
  int32_t lit_imm;
  if (pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm)) {
    /** 先 emit 右子树再装左字面量到 w1，避免嵌套 MUL 等把 w1 覆盖（如 1+2*3）。 */
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    return backend_enc_add_rax_rbx_arch(elf_ctx, ta);
  }
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    return backend_enc_add_rax_rbx_arch(elf_ctx, ta);
  }
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_add_rax_rbx_arch(elf_ctx, ta);
}

static int32_t pipeline_asm_emit_binop_sub_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   int32_t left_ref, int32_t right_ref, struct backend_AsmFuncCtx *ctx,
                                                   int32_t ta) {
  int32_t lit_imm;
  /** 左字面量：先 emit 右子树，再 rbx=左立即数，arm64 用 rbx-rax（42-10）。 */
  if (pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    if (ta == 1)
      return backend_enc_sub_rbx_rax_then_mov_arch(elf_ctx, ta);
    return backend_enc_sub_rax_rbx_arch(elf_ctx, ta);
  }
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    if (ta == 1)
      return backend_enc_sub_rax_rbx_arch(elf_ctx, ta);
    return backend_enc_sub_rbx_rax_then_mov_arch(elf_ctx, ta);
  }
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_sub_rbx_rax_then_mov_arch(elf_ctx, ta);
}

static int32_t pipeline_asm_emit_binop_mul_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   int32_t left_ref, int32_t right_ref, struct backend_AsmFuncCtx *ctx,
                                                   int32_t ta) {
  int32_t lit_imm;
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    return backend_enc_imul_rbx_rax_arch(elf_ctx, ta);
  }
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_imul_rbx_rax_arch(elf_ctx, ta);
}

static int32_t pipeline_asm_emit_binop_div_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   int32_t left_ref, int32_t right_ref, struct backend_AsmFuncCtx *ctx,
                                                   int32_t ta) {
  int32_t lit_imm;
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    return backend_enc_idiv_rbx_arch(elf_ctx, ta);
  }
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_idiv_rbx_arch(elf_ctx, ta);
}

static int32_t pipeline_asm_emit_binop_mod_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   int32_t left_ref, int32_t right_ref, struct backend_AsmFuncCtx *ctx,
                                                   int32_t ta) {
  int32_t lit_imm;
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    return backend_enc_rem_mod_arch(elf_ctx, ta);
  }
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_rem_mod_arch(elf_ctx, ta);
}

/**
 * emit_expr_elf 快速路径：LIT/const_fold/RETURN/算术二元；未命中返回 -99 由 .su 尾 return 结束函数。
 */
int32_t pipeline_asm_emit_expr_elf_fast(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                        int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  struct ast_Expr *e;
  int32_t ko;
  if (expr_ref == 0)
    return -1;
  if (!arena || expr_ref <= 0 || expr_ref > arena->num_exprs)
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
  e = pipeline_arena_expr_ptr(arena, expr_ref);
  if (!e)
    return -1;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  /** 形参/局部 VAR 勿走 CTFE 快速路径（池字段未初始化或与 C 布局错位时会误折叠为 0）。 */
  if (e->const_folded_valid != 0 && ko != (int32_t)ast_ExprKind_EXPR_VAR)
    return backend_enc_mov_imm32_to_w0_arch(elf_ctx, e->const_folded_val, ta);
  if (ko == 0 || ko == 2)
    return backend_enc_mov_imm32_to_w0_arch(elf_ctx, pipeline_expr_int_val_at(arena, expr_ref), ta);
  /* EXPR_RETURN 走 slow（emit 操作数 + jmp tail_join）；fast 仅剥壳会漏 jmp 导致 SIGSEGV。 */
  if (ko == 41)
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
  if (ko == 53) { /* EXPR_BINOP：parse_into_buf 历史节点，按 ADD 处理 */
    return pipeline_asm_emit_binop_add_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref),
                                              pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta);
  }
  if (ko == 4)
    return pipeline_asm_emit_binop_add_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref),
                                              pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta);
  if (ko == 5)
    return pipeline_asm_emit_binop_sub_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref),
                                              pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta);
  if (ko == 6)
    return pipeline_asm_emit_binop_mul_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref),
                                              pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta);
  if (ko == 7)
    return pipeline_asm_emit_binop_div_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref),
                                              pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta);
  if (ko == 8)
    return pipeline_asm_emit_binop_mod_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref),
                                              pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta);
  return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
}

/**
 * 读取 arena.types[ref-1].array_size（数组长度、向量 lane 数等）。
 * ref 无效时返回 0。
 */
int32_t pipeline_type_array_size_at(struct ast_ASTArena *arena, int32_t ref) {
  struct ast_Type *t;
  if (!arena || ref <= 0 || ref > arena->num_types)
    return 0;
  t = pipeline_arena_type_ptr(arena, ref);
  return t ? t->array_size : 0;
}

/** func 形参 / arena copy_slot 实现见 ast_pool.c（#include 进本 TU）。 */

void pipeline_module_func_name_write(struct ast_Module *m, int32_t func_index, uint8_t *name_bytes,
                                     int32_t name_len) {
  struct ast_Func *f;
  if (!m || func_index < 0)
    return;
  if (name_len < 0 || name_len > 64)
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

/** 自举 codegen：将 module->funcs[fi].name[64] 拷入 dst，避免 .su 对嵌套大数组下标 typeck/asm GEP 失败。 */
void pipeline_module_func_name_copy64(struct ast_Module *m, int32_t func_index, uint8_t *dst) {
  struct ast_Func *f;
  if (!m || !dst || func_index < 0)
    return;
  if (func_index >= (int32_t)m->num_funcs)
    return;
  f = pipeline_module_func_ptr(m, func_index);
  if (!f)
    return;
  memcpy(dst, f->name, (size_t)64);
}

int32_t pipeline_module_func_name_len_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0)
    return 0;
  if (func_index >= (int32_t)m->num_funcs)
    return 0;
  f = pipeline_module_func_ptr(m, func_index);
  return f ? (int32_t)f->name_len : 0;
}

int32_t pipeline_module_func_is_extern_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0)
    return 0;
  if (func_index >= (int32_t)m->num_funcs)
    return 0;
  f = pipeline_module_func_ptr(m, func_index);
  return f ? (int32_t)f->is_extern : 0;
}

int32_t pipeline_module_func_body_ref_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0)
    return 0;
  if (func_index >= (int32_t)m->num_funcs)
    return 0;
  f = pipeline_module_func_ptr(m, func_index);
  return f ? (int32_t)f->body_ref : 0;
}

/** struct_layout / import / top_level / enum / func 形参池实现见 ast_pool.c（文件末尾 #include）。 */

/** 读 arena expr 槽；无效 ref 返回 NULL。 */
static struct ast_Expr *glue_arena_expr_at_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return NULL;
  return pipeline_arena_expr_ptr(a, expr_ref);
}

/** 读 struct_lit 字段数；避免 SU 内 `let e: Expr = ast_arena_expr_get` 后字段访问 typeck 失败。 */
int32_t pipeline_expr_struct_lit_num_fields(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->struct_lit_num_fields : 0;
}

/** 读 struct_lit 类型名长度。 */
int32_t pipeline_expr_struct_lit_type_name_len(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->struct_lit_struct_name_len : 0;
}

/** memcpy struct_lit 类型名到 out64。 */
void pipeline_expr_struct_lit_type_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64) {
  struct ast_Expr *ex;
  if (!out64)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex) {
    memset(out64, 0, 64);
    return;
  }
  memcpy(out64, ex->struct_lit_struct_name, 64);
}

/** 与 typeck.su typeck_su_type_align 一致（§11.1 布局步进）。 */
static int32_t glue_type_align_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref, int32_t depth) {
  int32_t kind_ord;
  if (!a || ty_ref <= 0 || ty_ref > a->num_types || depth > 64)
    return 1;
  kind_ord = pipeline_type_kind_ord_at(a, ty_ref);
  if (kind_ord == 2)
    return 1;
  if (kind_ord == 0 || kind_ord == 3 || kind_ord == 1 || kind_ord == 13)
    return 4;
  if (kind_ord == 5 || kind_ord == 4 || kind_ord == 6 || kind_ord == 7 || kind_ord == 14 || kind_ord == 9)
    return 8;
  if (kind_ord == 11)
    return 8;
  if (kind_ord == 10 || kind_ord == 12) {
    int32_t elem_ref = pipeline_type_elem_ref_at(a, ty_ref);
    if (elem_ref <= 0)
      return 1;
    return glue_type_align_simple(m, a, elem_ref, depth + 1);
  }
  if (kind_ord == 8) {
    int32_t sz_out = 0;
    int32_t al_out = 1;
    int32_t nlen;
    uint8_t name[64];
    int32_t k;
    nlen = pipeline_type_named_name_into(a, ty_ref, name);
    if (nlen <= 0 || nlen > 63)
      return 4;
    for (k = 0; m && k < (int32_t)m->num_struct_layouts; k++) {
      int32_t ln = pipeline_module_struct_layout_name_len(m, k);
      int32_t j;
      int32_t eq = 1;
      if (ln != nlen)
        continue;
      for (j = 0; j < nlen; j++) {
        if (pipeline_module_struct_layout_name_byte_at(m, k, j) != name[j]) {
          eq = 0;
          break;
        }
      }
      if (!eq)
        continue;
      if (typeck_typeck_struct_layout_metrics(m, a, k, depth + 1, 0, &sz_out, &al_out) != 0)
        return 1;
      return al_out > 0 ? al_out : 1;
    }
    return 4;
  }
  return 1;
}

/** 与 typeck.su typeck_su_type_size 一致。 */
static int32_t glue_type_size_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref, int32_t depth) {
  int32_t kind_ord;
  if (!a || ty_ref <= 0 || ty_ref > a->num_types || depth > 64)
    return 0;
  kind_ord = pipeline_type_kind_ord_at(a, ty_ref);
  if (kind_ord == 15)
    return 0;
  if (kind_ord == 2)
    return 1;
  if (kind_ord == 0 || kind_ord == 3 || kind_ord == 1 || kind_ord == 13)
    return 4;
  if (kind_ord == 5 || kind_ord == 4 || kind_ord == 6 || kind_ord == 7 || kind_ord == 14 || kind_ord == 9)
    return 8;
  if (kind_ord == 11)
    return 16;
  if (kind_ord == 10 || kind_ord == 12) {
    int32_t elem_ref = pipeline_type_elem_ref_at(a, ty_ref);
    int32_t asz = pipeline_type_array_size_at(a, ty_ref);
    int32_t es;
    if (elem_ref <= 0 || asz <= 0)
      return 0;
    es = glue_type_size_simple(m, a, elem_ref, depth + 1);
    return es > 0 ? asz * es : 0;
  }
  if (kind_ord == 8) {
    uint8_t name[64];
    int32_t nlen;
    int32_t k;
    nlen = pipeline_type_named_name_into(a, ty_ref, name);
    if (nlen <= 0 || nlen > 63)
      return 4;
    for (k = 0; m && k < (int32_t)m->num_struct_layouts; k++) {
      int32_t ln = pipeline_module_struct_layout_name_len(m, k);
      int32_t j;
      int32_t eq = 1;
      if (ln != nlen)
        continue;
      for (j = 0; j < nlen; j++) {
        if (pipeline_module_struct_layout_name_byte_at(m, k, j) != name[j]) {
          eq = 0;
          break;
        }
      }
      if (!eq)
        continue;
      return typeck_su_type_size_from_layout_glue(m, a, k, depth + 1);
    }
    return 4;
  }
  return 0;
}

/**
 * 在 layout_idx 上为下一字段（类型 new_field_type_ref）计算 §11.1 对齐后的字节偏移；
 * parser struct 定义与 struct_lit 登记须用此值，勿 off+=8。
 */
int32_t pipeline_struct_layout_next_field_offset(struct ast_Module *m, struct ast_ASTArena *a, int32_t layout_idx,
                                               int32_t new_field_type_ref) {
  int32_t current;
  int32_t nf;
  int32_t j;
  int32_t A;
  int32_t rem;
  int32_t gap;
  if (!m || layout_idx < 0)
    return 0;
  current = 0;
  nf = pipeline_module_struct_layout_num_fields(m, layout_idx);
  for (j = 0; j < nf; j++) {
    int32_t ftr = pipeline_module_struct_layout_field_type_ref(m, layout_idx, j);
    int32_t fsize;
    A = glue_type_align_simple(m, a, ftr, 0);
    fsize = glue_type_size_simple(m, a, ftr, 0);
    if (A <= 0)
      A = 1;
    if (fsize <= 0)
      fsize = 4;
    rem = current % A;
    gap = A - rem;
    gap = gap % A;
    current = current + gap + fsize;
  }
  A = glue_type_align_simple(m, a, new_field_type_ref, 0);
  if (A <= 0)
    A = 1;
  rem = current % A;
  gap = A - rem;
  gap = gap % A;
  return current + gap;
}

/**
 * EXPR_STRUCT_LIT 按 module.struct_layouts 计算的字节大小；用于 asm 小结构体按值经 x0 返回（≤8）。
 * 未命中布局时返回 0，由 backend 退回指针语义。
 */
int32_t pipeline_expr_struct_lit_value_bytes(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref) {
  struct ast_Expr *ex;
  int32_t nlen;
  uint8_t name[64];
  int32_t k;
  int32_t sz_out;
  int32_t al_out;
  if (!a || !m || expr_ref <= 0)
    return 0;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_STRUCT_LIT)
    return 0;
  nlen = ex->struct_lit_struct_name_len;
  if (nlen <= 0 || nlen > 63)
    return 0;
  memcpy(name, ex->struct_lit_struct_name, (size_t)nlen);
  for (k = 0; k < (int32_t)m->num_struct_layouts; k++) {
    int32_t ln;
    int32_t j;
    int32_t eq;
    ln = pipeline_module_struct_layout_name_len(m, k);
    if (ln != nlen)
      continue;
    eq = 1;
    for (j = 0; j < nlen; j++) {
      if (pipeline_module_struct_layout_name_byte_at(m, k, j) != name[j]) {
        eq = 0;
        break;
      }
    }
    if (!eq)
      continue;
    sz_out = 0;
    al_out = 1;
    if (typeck_typeck_struct_layout_metrics(m, a, k, 0, 0, &sz_out, &al_out) != 0)
      return 0;
    return sz_out > 0 ? sz_out : 0;
  }
  return 0;
}

/**
 * STRUCT_LIT 第 field_ix 字段在布局中的字节偏移；供 asm 按 layout 存字段（勿用 fi*8）。
 */
int32_t pipeline_expr_struct_lit_field_offset_at(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref,
                                                 int32_t field_ix) {
  struct ast_Expr *ex;
  int32_t nlen;
  uint8_t name[64];
  int32_t k;
  if (!a || !m || expr_ref <= 0 || field_ix < 0)
    return field_ix * 8;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_STRUCT_LIT)
    return field_ix * 8;
  nlen = ex->struct_lit_struct_name_len;
  if (nlen <= 0 || nlen > 63)
    return field_ix * 8;
  memcpy(name, ex->struct_lit_struct_name, (size_t)nlen);
  for (k = 0; k < (int32_t)m->num_struct_layouts; k++) {
    int32_t ln;
    int32_t j;
    int32_t eq;
    ln = pipeline_module_struct_layout_name_len(m, k);
    if (ln != nlen)
      continue;
    eq = 1;
    for (j = 0; j < nlen; j++) {
      if (pipeline_module_struct_layout_name_byte_at(m, k, j) != name[j]) {
        eq = 0;
        break;
      }
    }
    if (!eq)
      continue;
    if (field_ix < pipeline_module_struct_layout_num_fields(m, k))
      return pipeline_module_struct_layout_field_offset_at(m, k, field_ix);
    return field_ix * 8;
  }
  return field_ix * 8;
}

/** STRUCT_LIT 第 field_ix 字段在 layout 中的类型 ref；未命中时返回 0。 */
int32_t pipeline_expr_struct_lit_field_type_ref_at(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref,
                                                 int32_t field_ix) {
  struct ast_Expr *ex;
  int32_t nlen;
  uint8_t name[64];
  int32_t k;
  if (!a || !m || expr_ref <= 0 || field_ix < 0)
    return 0;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_STRUCT_LIT)
    return 0;
  nlen = ex->struct_lit_struct_name_len;
  if (nlen <= 0 || nlen > 63)
    return 0;
  memcpy(name, ex->struct_lit_struct_name, (size_t)nlen);
  for (k = 0; k < (int32_t)m->num_struct_layouts; k++) {
    int32_t ln;
    int32_t j;
    int32_t eq;
    ln = pipeline_module_struct_layout_name_len(m, k);
    if (ln != nlen)
      continue;
    eq = 1;
    for (j = 0; j < nlen; j++) {
      if (pipeline_module_struct_layout_name_byte_at(m, k, j) != name[j]) {
        eq = 0;
        break;
      }
    }
    if (!eq)
      continue;
    if (field_ix < pipeline_module_struct_layout_num_fields(m, k))
      return pipeline_module_struct_layout_field_type_ref(m, k, field_ix);
    return 0;
  }
  return 0;
}

/** struct_lit 字段名/init 读 API 见 ast_pool.c（侧车池）。 */

/** 读 expr.kind 序数；无效 ref 返回 -1。 */
int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t expr_ref) {
  enum ast_ExprKind kd;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return -1;
  kd = glue_arena_expr_kind_at_ref(a, expr_ref);
  return (int32_t)kd;
}

/** 读 EXPR_LIT/EXPR_BOOL_LIT 的 int_val；backend asm 勿 ast_arena_expr_get 整颗 Expr（大模块栈溢出）。 */
int32_t pipeline_expr_int_val_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->int_val : 0;
}

/**
 * 读 expr.unary_operand_ref；无效 ref 返回 0。
 * typeck.su check_block_impl 块末 `return;` 判定须用此 glue，勿 `let fin_ex: Expr = ast_arena_expr_get` 再读字段（自举 asm FIELD_ACCESS 失败）。
 */
int32_t pipeline_expr_unary_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->unary_operand_ref : 0;
}

/** FIELD_ACCESS 字段名 memcpy 到 out64。 */
void pipeline_expr_field_access_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64) {
  struct ast_Expr *ex;
  if (!out64)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex) {
    memset(out64, 0, 64);
    return;
  }
  memcpy(out64, ex->field_access_field_name, 64);
}

/** FIELD_ACCESS 字段名长度；非 FIELD_ACCESS 或无效 ref 返回 0。 */
int32_t pipeline_expr_field_access_name_len(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_FIELD_ACCESS)
    return 0;
  return ex->field_access_field_len;
}

/** FIELD_ACCESS base_ref；非 FIELD_ACCESS 返回 0。 */
int32_t pipeline_expr_field_access_base_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_FIELD_ACCESS)
    return 0;
  return ex->field_access_base_ref;
}

/** EXPR_VAR 变量名 memcpy 到 out64。 */
void pipeline_expr_var_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64) {
  struct ast_Expr *ex;
  if (!out64)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex) {
    memset(out64, 0, 64);
    return;
  }
  memcpy(out64, ex->var_name, 64);
}

/** EXPR_VAR 名长度；非 VAR 或无效 ref 返回 0。 */
int32_t pipeline_expr_var_name_len(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_VAR)
    return 0;
  return ex->var_name_len;
}

/** 读 expr.binop_left_ref；无效 ref 返回 0。 */
int32_t pipeline_expr_binop_left_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->binop_left_ref : 0;
}

/** 读 expr.binop_right_ref；无效 ref 返回 0。 */
int32_t pipeline_expr_binop_right_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->binop_right_ref : 0;
}

/**
 * 比较表达式 ELF 发射（EQ/NE/LT/LE/GT/GE 全在 C 内，避免 backend.su 经 shu-c -E 后
 * EXPR_NE(15) 与字面量/分支条件误合并，导致 != 恒与 0 比较）。
 */
int32_t pipeline_asm_emit_cmp_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                  int32_t cmp_expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t right_ref;
  int32_t lit_imm;
  int32_t cc;
  struct ast_Expr *e;
  if (!arena || cmp_expr_ref <= 0)
    return -1;
  e = glue_arena_expr_at_ref(arena, cmp_expr_ref);
  if (e && e->const_folded_valid != 0)
    return backend_enc_mov_imm32_to_w0_arch(elf_ctx, e->const_folded_val, ta);
  right_ref = pipeline_expr_binop_right_ref_at(arena, cmp_expr_ref);
  if (right_ref != 0 && pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, cmp_expr_ref), ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    cc = pipeline_asm_cmp_cc_for_expr_kind_ord(pipeline_expr_kind_ord_at(arena, cmp_expr_ref));
    if (cc < 0)
      return -1;
    return backend_enc_cmp_setcc_movzbl_arch(elf_ctx, cc, ta);
  }
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, cmp_expr_ref), ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, pipeline_expr_binop_right_ref_at(arena, cmp_expr_ref), ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  cc = pipeline_asm_cmp_cc_for_expr_kind_ord(pipeline_expr_kind_ord_at(arena, cmp_expr_ref));
  if (cc < 0)
    return -1;
  return backend_enc_cmp_setcc_movzbl_arch(elf_ctx, cc, ta);
}

int32_t ast_pipeline_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_pipeline_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_pipeline_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_ast_block_num_consts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena *a, int32_t br);
uint8_t ast_ast_block_stmt_order_kind(struct ast_ASTArena *a, int32_t br, int32_t si);
int32_t ast_ast_block_stmt_order_idx(struct ast_ASTArena *a, int32_t br, int32_t si);
int32_t ast_ast_block_num_loops(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_for_loops(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena *a, int32_t br);
int32_t ast_pipeline_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
int32_t ast_pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);

int32_t pipeline_asm_emit_block_if_stmt_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            int32_t cur_block, int32_t if_idx, struct backend_AsmFuncCtx *ctx,
                                            int32_t ta, int32_t stmt_i);

/** TYPE_ARRAY 在 TypeKind 序数表中的值（与 ast.su / pipeline_type_kind_ord_at 一致）。 */
#define GLUE_TYPE_KIND_ARRAY 10

/**
 * 定长数组 [N]T 在栈 temp 区占用字节（array_size * elem_sz）；非 ARRAY 返回 0。
 */
static int32_t glue_fixed_array_temp_bytes(struct ast_ASTArena *arena, int32_t type_ref) {
  struct ast_Type *t;
  int32_t elem_ref;
  int32_t esz;
  int32_t bytes;
  if (!arena || type_ref <= 0 || type_ref > arena->num_types)
    return 0;
  t = pipeline_arena_type_ptr(arena, type_ref);
  if (!t || t->array_size <= 0)
    return 0;
  elem_ref = t->elem_type_ref;
  esz = 4;
  if (elem_ref > 0 && elem_ref <= arena->num_types) {
    struct ast_Type *et = pipeline_arena_type_ptr(arena, elem_ref);
    if (et) {
      if (pipeline_type_kind_ord_at(arena, elem_ref) == 2)
        esz = 1;
      else if (pipeline_type_kind_ord_at(arena, elem_ref) == 8 ||
               pipeline_type_kind_ord_at(arena, elem_ref) == 4 ||
               pipeline_type_kind_ord_at(arena, elem_ref) == 5 ||
               pipeline_type_kind_ord_at(arena, elem_ref) == 6 ||
               pipeline_type_kind_ord_at(arena, elem_ref) == 14)
        esz = 8;
      else
        esz = 4;
    }
  }
  bytes = t->array_size * esz;
  return bytes > 0 ? bytes : 0;
}

/**
 * 从 let 初始化表达式推导数组 temp 字节（let type_ref 缺失时回退到 init 的 resolved_type）。
 */
static int32_t glue_array_temp_bytes_for_let_init(struct ast_ASTArena *arena, int32_t let_type_ref,
                                                  int32_t init_ref) {
  int32_t bytes;
  bytes = glue_fixed_array_temp_bytes(arena, let_type_ref);
  if (bytes > 0)
    return bytes;
  if (init_ref > 0) {
    int32_t rt;
    rt = pipeline_expr_resolved_type_ref(arena, init_ref);
    bytes = glue_fixed_array_temp_bytes(arena, rt);
    if (bytes > 0)
      return bytes;
    if (pipeline_expr_kind_ord_at(arena, init_ref) == 46) {
      int32_t ne;
      int32_t esz;
      ne = ast_pipeline_expr_array_lit_num_elems_at(arena, init_ref);
      if (ne > 0) {
        esz = 4;
        {
          int32_t inner;
          inner = pipeline_asm_array_lit_elem_type_ref(arena, init_ref);
          if (inner > 0 && pipeline_type_kind_ord_at(arena, inner) == 2)
            esz = 1;
          else if (inner > 0 && (pipeline_type_kind_ord_at(arena, inner) == 8 ||
                                 pipeline_type_kind_ord_at(arena, inner) == 4))
            esz = 8;
        }
        bytes = ne * esz;
        if (bytes > 0)
          return bytes;
      }
    }
  }
  return 0;
}

/** 将 ctx->next_offset 向上对齐到 8 字节边界。 */
static void glue_align_next_offset(struct backend_AsmFuncCtx *ctx) {
  int32_t m;
  if (!ctx)
    return;
  m = ctx->next_offset % 8;
  if (m != 0)
    ctx->next_offset += (8 - m);
}

/**
 * let 定长数组初始化后推进 temp 区，避免连续 `let a:[N]u8=[]; let b:[M]u8=[...]` 共用 ctx.next_offset
 *（csv main 中 buf/line 重叠导致 escape 写坏 buf[1]）。
 */
/**
 * EXPR_ARRAY_LIT 发射完成后推进 temp 区（在 emit_expr_elf_slow 末尾调用，编译期 ctx）。
 */
void pipeline_asm_bump_next_offset_for_array_lit(struct ast_ASTArena *arena, int32_t expr_ref,
                                                 struct backend_AsmFuncCtx *ctx) {
  int32_t bytes;
  if (!ctx || expr_ref <= 0)
    return;
  bytes = glue_array_temp_bytes_for_let_init(arena, pipeline_expr_resolved_type_ref(arena, expr_ref), expr_ref);
  if (bytes <= 0)
    return;
  ctx->next_offset += bytes;
  glue_align_next_offset(ctx);
}

void pipeline_asm_bump_next_offset_after_let_init(struct ast_ASTArena *arena, int32_t block_ref, int32_t let_idx,
                                                  int32_t init_ref, struct backend_AsmFuncCtx *ctx) {
  int32_t tref;
  int32_t bytes;
  if (!ctx)
    return;
  /** EXPR_ARRAY_LIT 已在 emit_expr_elf_slow 末尾 bump，避免 buf/line/quoted temp 区双倍推进。 */
  if (init_ref > 0 && pipeline_expr_kind_ord_at(arena, init_ref) == 46)
    return;
  tref = pipeline_block_let_type_ref(arena, block_ref, let_idx);
  bytes = glue_array_temp_bytes_for_let_init(arena, tref, init_ref);
  if (bytes <= 0)
    return;
  ctx->next_offset += bytes;
  glue_align_next_offset(ctx);
}

/**
 * 无 init_ref 的定长数组 let：在 ctx->next_offset 处 lea 并写入局部指针槽（如 `let buf:[64]u8=[]` 被省略 init 时）。
 */
static int32_t glue_emit_array_let_empty_init(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                              struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t stack_slot_off) {
  int32_t temp_off;
  (void)arena;
  if (!elf_ctx || !ctx)
    return -1;
  temp_off = ctx->next_offset;
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_off, ta) != 0)
    return -1;
  if (backend_enc_store_rax_to_rbp_arch(elf_ctx, stack_slot_off, ta) != 0)
    return -1;
  return 0;
}

/**
 * stmt_order 中是否含 EXPR_RETURN（任意操作数）；用于 if-then 含 return 时勿 jmp 到 if 后语句。
 */
static int glue_block_stmt_order_has_return(struct ast_ASTArena *arena, int32_t block_ref) {
  int32_t nso;
  int32_t i;
  if (!arena || block_ref <= 0)
    return 0;
  nso = ast_ast_block_num_stmt_order(arena, block_ref);
  for (i = 0; i < nso; i++) {
    if (ast_ast_block_stmt_order_kind(arena, block_ref, i) == 2) {
      int32_t idx = ast_ast_block_stmt_order_idx(arena, block_ref, i);
      int32_t expr_ref;
      if (idx < 0 || idx >= ast_ast_block_num_expr_stmts(arena, block_ref))
        continue;
      expr_ref = ast_pipeline_block_expr_stmt_ref(arena, block_ref, idx);
      if (expr_ref != 0 && pipeline_expr_kind_ord_at(arena, expr_ref) == 41)
        return 1;
    }
  }
  return 0;
}

/**
 * 同步块体末尾：若块仅有 final_expr_ref（如 return offset;）且 stmt_order 未含 RETURN，补发射。
 */
static int glue_emit_block_final_expr_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                          int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  struct ast_Block *blk;
  if (!arena || !elf_ctx || !ctx || block_ref <= 0)
    return 0;
  blk = pipeline_arena_block_ptr(arena, block_ref);
  if (!blk || blk->final_expr_ref == 0)
    return 0;
  if (glue_block_stmt_order_has_return(arena, block_ref))
    return 0;
  return pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, blk->final_expr_ref, ctx, ta);
}

/**
 * 按 stmt_order 同步发射块体（C for 循环）：避免 shu-c -E 使 backend.su 内 while(i<nso) 只跑一轮，
 * 导致 while 体内仅首条 if/赋值被发射（escape 的 else 与 j++ 丢失）。
 */
int32_t pipeline_asm_emit_block_body_sync_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                              int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t nconst;
  int32_t nlet;
  int32_t slot_base;
  int32_t nso;
  int32_t i;
  if (!arena || !elf_ctx || !ctx || block_ref <= 0)
    return -1;
  backend_ensure_block_local_slots(ctx, arena, block_ref);
  nconst = ast_ast_block_num_consts(arena, block_ref);
  nlet = ast_ast_block_num_lets(arena, block_ref);
  slot_base = backend_block_slot_base_for(ctx, arena, block_ref);
  nso = ast_ast_block_num_stmt_order(arena, block_ref);
  for (i = 0; i < nso; i++) {
    uint8_t item_kind = ast_ast_block_stmt_order_kind(arena, block_ref, i);
    int32_t idx = ast_ast_block_stmt_order_idx(arena, block_ref, i);
    if (item_kind == 0) {
      if (idx >= 0 && idx < nconst) {
        int32_t init_ref = ast_pipeline_block_const_init_ref(arena, block_ref, idx);
        if (init_ref != 0) {
          if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, backend_asm_ctx_slot_offset(ctx, slot_base + idx), ta) !=
              0)
            return -1;
        }
      }
    } else if (item_kind == 1) {
      if (idx >= 0 && idx < nlet) {
        int32_t slot = slot_base + nconst + idx;
        int32_t init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, idx);
        if (init_ref != 0) {
          if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, backend_asm_ctx_slot_offset(ctx, slot), ta) != 0)
            return -1;
        } else if (glue_array_temp_bytes_for_let_init(arena, pipeline_block_let_type_ref(arena, block_ref, idx),
                                                      0) > 0) {
          if (glue_emit_array_let_empty_init(arena, elf_ctx, ctx, ta, backend_asm_ctx_slot_offset(ctx, slot)) != 0)
            return -1;
          pipeline_asm_bump_next_offset_after_let_init(arena, block_ref, idx, 0, ctx);
        }
      }
    } else if (item_kind == 2) {
      if (idx >= 0 && idx < ast_ast_block_num_expr_stmts(arena, block_ref)) {
        int32_t expr_ref = ast_pipeline_block_expr_stmt_ref(arena, block_ref, idx);
        if (expr_ref != 0) {
          if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, expr_ref, ctx, ta) != 0)
            return -1;
        }
      }
    } else if (item_kind == 3) {
      if (idx >= 0 && idx < ast_ast_block_num_loops(arena, block_ref)) {
        if (backend_emit_while_loop_elf(arena, elf_ctx, block_ref, idx, ctx, ta) != 0)
          return -1;
      }
    } else if (item_kind == 4) {
      if (idx >= 0 && idx < ast_ast_block_num_for_loops(arena, block_ref)) {
        if (backend_emit_for_loop_elf(arena, elf_ctx, block_ref, idx, ctx, ta) != 0)
          return -1;
      }
    } else if (item_kind == 5) {
      if (idx >= 0 && idx < ast_ast_block_num_if_stmts(arena, block_ref)) {
        if (pipeline_asm_emit_block_if_stmt_elf(arena, elf_ctx, block_ref, idx, ctx, ta, i) != 0)
          return -1;
      }
    }
  }
  if (glue_emit_block_final_expr_elf(arena, elf_ctx, block_ref, ctx, ta) != 0)
    return -1;
  return 0;
}

/**
 * backend.su emit_block_body_elf 入口：转发 C 同步块体发射（避免 SU while 在自举 asm 下只跑一轮）。
 */
int32_t backend_emit_block_body_sync_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                         int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  return pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, block_ref, ctx, ta);
}

/** backend.su：读 Block.final_expr_ref（勿 ast_arena_block_get 按值拷贝）。 */
int32_t pipeline_asm_block_final_expr_ref_at(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block *blk = pipeline_arena_block_ptr(a, br);
  return blk ? blk->final_expr_ref : 0;
}

/** backend.su：读 Block.num_stmt_order（与 ast_ast_block_num_stmt_order 一致）。 */
int32_t pipeline_asm_block_num_stmt_order_at(struct ast_ASTArena *a, int32_t br) {
  return ast_ast_block_num_stmt_order(a, br);
}

/** stmt_order 已含 EXPR_RETURN 时勿再 emit final_expr（避免 return 1+2 后重复 emit 占位 LIT 1）。 */
int32_t pipeline_asm_block_stmt_order_has_return(struct ast_ASTArena *a, int32_t br) {
  return glue_block_stmt_order_has_return(a, br);
}

/**
 * 块级 if ELF 发射（then-first + jz）：避免 backend.su 经 shu-c -E 后 jnz/else/then 顺序错乱，
 * 导致 cond 为真时跳进错误分支（escape/unescape 等 while 内 if 返回 -1）。
 */
int32_t pipeline_asm_emit_block_if_stmt_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            int32_t cur_block, int32_t if_idx, struct backend_AsmFuncCtx *ctx,
                                            int32_t ta, int32_t stmt_i) {
  int32_t cond_if;
  int32_t then_ref;
  int32_t else_ref;
  uint8_t else_lbl[64];
  uint8_t done_lbl[64];
  int32_t else_len;
  int32_t done_len;
  (void)stmt_i;
  if (!arena || !elf_ctx || !ctx || cur_block <= 0)
    return -1;
  cond_if = ast_pipeline_block_if_cond_ref(arena, cur_block, if_idx);
  then_ref = ast_pipeline_block_if_then_body_ref(arena, cur_block, if_idx);
  else_ref = ast_pipeline_block_if_else_body_ref(arena, cur_block, if_idx);
  if (cond_if == 0 || then_ref == 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, cond_if, ctx, ta) != 0)
    return -1;
  else_len = backend_emit_next_label(ctx, else_lbl, 64);
  done_len = backend_emit_next_label(ctx, done_lbl, 64);
  if (else_len <= 0 || done_len <= 0)
    return -1;
  if (else_ref != 0) {
    if (backend_enc_jz_arch(elf_ctx, else_lbl, else_len, ta) != 0)
      return -1;
  } else {
    if (backend_enc_jz_arch(elf_ctx, done_lbl, done_len, ta) != 0)
      return -1;
  }
  backend_ensure_block_local_slots(ctx, arena, then_ref);
  if (pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, then_ref, ctx, ta) != 0)
    return -1;
  /** then 已 return 时 done 落在 if 后语句上，不能再 jmp done（否则引号/无引号双路径）。 */
  if (!glue_block_stmt_order_has_return(arena, then_ref)) {
    if (backend_enc_jmp_arch(elf_ctx, done_lbl, done_len, ta) != 0)
      return -1;
  }
  if (else_ref != 0) {
    if (backend_enc_label_arch(elf_ctx, else_lbl, else_len, 0, ta) != 0)
      return -1;
    backend_ensure_block_local_slots(ctx, arena, else_ref);
    if (pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, else_ref, ctx, ta) != 0)
      return -1;
  }
  if (backend_enc_label_arch(elf_ctx, done_lbl, done_len, 0, ta) != 0)
    return -1;
  return 0;
}

/** EXPR_FLOAT_LIT 低 32 位；emit 时从 float_val 重算，避免 SU parser 未持久化 float_bits_*。 */
int32_t pipeline_expr_float_bits_lo_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return 0;
  if (ex->kind == ast_ExprKind_EXPR_FLOAT_LIT)
    return typeck_float64_bits_lo(ex->float_val);
  return ex->float_bits_lo;
}

/** EXPR_FLOAT_LIT 高 32 位。 */
int32_t pipeline_expr_float_bits_hi_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return 0;
  if (ex->kind == ast_ExprKind_EXPR_FLOAT_LIT)
    return typeck_float64_bits_hi(ex->float_val);
  return ex->float_bits_hi;
}

/** EXPR_CALL callee expr ref；无效 ref 返回 0。 */
int32_t pipeline_expr_call_callee_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->call_callee_ref : 0;
}

/** EXPR_AS 操作数 ref；无效 ref 返回 0。 */
int32_t pipeline_expr_as_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->as_operand_ref : 0;
}

/** EXPR_ENUM_VARIANT / FIELD_ACCESS 枚举 tag；无效 ref 返回 0。 */
int32_t pipeline_expr_enum_variant_tag_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->enum_variant_tag : 0;
}

/** EXPR_METHOD_CALL receiver ref；无效 ref 返回 0。 */
int32_t pipeline_expr_method_call_base_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->method_call_base_ref : 0;
}

/** EXPR_METHOD_CALL 实参个数（不含 receiver）；无效 ref 返回 0。 */
int32_t pipeline_expr_method_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->method_call_num_args : 0;
}

/** EXPR_METHOD_CALL 方法名长度；无效 ref 返回 0。 */
int32_t pipeline_expr_method_call_name_len(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->method_call_name_len : 0;
}

/** EXPR_METHOD_CALL 方法名 memcpy 到 out64。 */
void pipeline_expr_method_call_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64) {
  struct ast_Expr *ex;
  if (!out64)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex) {
    memset(out64, 0, 64);
    return;
  }
  memcpy(out64, ex->method_call_name, 64);
}

/** EXPR_IF/TERNARY 条件 ref；无效 ref 返回 0。 */
int32_t pipeline_expr_if_cond_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->if_cond_ref : 0;
}

/** EXPR_IF/TERNARY then 分支 ref；无效 ref 返回 0。 */
int32_t pipeline_expr_if_then_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->if_then_ref : 0;
}

/** EXPR_IF/TERNARY else 分支 ref；无效 ref 返回 0。 */
int32_t pipeline_expr_if_else_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->if_else_ref : 0;
}

/** EXPR_BLOCK 块 ref；无效 ref 返回 0。 */
int32_t pipeline_expr_block_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->block_ref : 0;
}

/** EXPR_MATCH 待匹配值 ref；无效 ref 返回 0。 */
int32_t pipeline_expr_match_matched_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->match_matched_ref : 0;
}

/** CTFE 折叠标记；无效 ref 返回 0。 */
int32_t pipeline_expr_const_folded_valid_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? (int32_t)ex->const_folded_valid : 0;
}

/** CTFE 折叠整型值；无效 ref 返回 0。 */
int32_t pipeline_expr_const_folded_val_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->const_folded_val : 0;
}

static enum ast_TypeKind glue_type_kind_from_ord(int32_t ord) {
  if (ord < 0 || ord > 15)
    return ast_TypeKind_TYPE_I32;
  return (enum ast_TypeKind)ord;
}

/** 查找或分配仅含 kind 的 primitive type；避免 SU 内 ti.kind = TypeKind.* assignment typeck 失败。 */
int32_t pipeline_type_ensure_by_kind_ord(struct ast_ASTArena *a, int32_t kind_ord) {
  int32_t k;
  enum ast_TypeKind kind;
  struct ast_Type *t;
  if (!a || kind_ord < 0 || kind_ord > 15)
    return 0;
  kind = glue_type_kind_from_ord(kind_ord);
  for (k = 1; k <= a->num_types; k++) {
    t = pipeline_arena_type_ptr(a, k);
    if (t && t->kind == kind && t->name_len == 0 && t->elem_type_ref == 0 && t->array_size == 0)
      return k;
  }
  k = pipeline_arena_type_alloc(a);
  if (k <= 0)
    return 0;
  t = pipeline_arena_type_ptr(a, k);
  if (!t)
    return 0;
  memset(t, 0, sizeof(*t));
  t->kind = kind;
  return k;
}

/** 查找或分配 TYPE_NAMED；name 经 memcpy 写入，避免 SU 对 Type 局部副本写字段。 */
int32_t pipeline_type_find_or_alloc_named(struct ast_ASTArena *a, uint8_t *name, int32_t name_len) {
  int32_t k;
  struct ast_Type *t;
  if (!a || !name || name_len <= 0 || name_len > 63)
    return 0;
  for (k = 1; k <= a->num_types; k++) {
    t = pipeline_arena_type_ptr(a, k);
    if (t && t->kind == ast_TypeKind_TYPE_NAMED && t->name_len == name_len &&
        memcmp(t->name, name, (size_t)name_len) == 0)
      return k;
  }
  k = pipeline_arena_type_alloc(a);
  if (k <= 0)
    return 0;
  t = pipeline_arena_type_ptr(a, k);
  if (!t)
    return 0;
  memset(t, 0, sizeof(*t));
  t->kind = ast_TypeKind_TYPE_NAMED;
  t->name_len = name_len;
  memcpy(t->name, name, (size_t)name_len);
  return k;
}

/** 查找或分配 PTR/ARRAY/SLICE/VECTOR 等复合 type；kind_ord 与 type_kind_ordinal 一致。 */
int32_t pipeline_type_find_or_alloc_compound(struct ast_ASTArena *a, int32_t kind_ord, int32_t elem_ref,
                                             int32_t array_size) {
  int32_t k;
  enum ast_TypeKind kind;
  struct ast_Type *t;
  if (!a || kind_ord < 0 || kind_ord > 15)
    return 0;
  kind = glue_type_kind_from_ord(kind_ord);
  for (k = 1; k <= a->num_types; k++) {
    t = pipeline_arena_type_ptr(a, k);
    if (t && t->kind == kind && t->elem_type_ref == elem_ref && t->array_size == array_size && t->name_len == 0)
      return k;
  }
  k = pipeline_arena_type_alloc(a);
  if (k <= 0)
    return 0;
  t = pipeline_arena_type_ptr(a, k);
  if (!t)
    return 0;
  memset(t, 0, sizeof(*t));
  t->kind = kind;
  t->elem_type_ref = elem_ref;
  t->array_size = array_size;
  return k;
}

/**
 * backend.su get_return_expr_ref：在 C 内读 Block/LabeledStmt/Expr 池，避免 SU 自举 asm 对
 * stmt.is_goto / block.final_expr_ref 等 struct 字段 FIELD_ACCESS codegen 失败（fail_at=55）。
 */
int32_t pipeline_backend_get_return_expr_ref(struct ast_ASTArena *a, struct ast_Func *f) {
  struct ast_Block *blk;
  int32_t j;
  int32_t ei;
  if (!a || !f || f->body_ref <= 0 || f->body_ref > a->num_blocks)
    return 0;
  blk = pipeline_arena_block_ptr(a, f->body_ref);
  j = 0;
  while (blk && j < blk->num_labeled_stmts) {
    int32_t ret_ref = pipeline_block_labeled_return_expr_ref(a, f->body_ref, j);
    if (ret_ref != 0)
      return ret_ref;
    j++;
  }
  if (blk && blk->final_expr_ref != 0) {
    struct ast_Expr *e;
    if (blk->final_expr_ref <= 0 || blk->final_expr_ref > a->num_exprs)
      return blk->final_expr_ref;
    e = pipeline_arena_expr_ptr(a, blk->final_expr_ref);
    if (e && e->kind == ast_ExprKind_EXPR_RETURN && e->unary_operand_ref != 0)
      return e->unary_operand_ref;
    return blk->final_expr_ref;
  }
  if (!blk)
    return 0;
  ei = blk->num_expr_stmts - 1;
  while (ei >= 0) {
    int32_t ers = pipeline_block_expr_stmt_ref(a, f->body_ref, ei);
    if (ers != 0 && ers > 0 && ers <= a->num_exprs) {
      struct ast_Expr *es = pipeline_arena_expr_ptr(a, ers);
      if (es && es->kind == ast_ExprKind_EXPR_RETURN) {
        /*
         * 显式 return 已作为 expr_stmt 由 emit_block_body 发射；勿再返回操作数供
         * asm_codegen_ast_to_elf 二次 emit（return if (...) 会重复 cmp/if 链）。
         */
        return 0;
      }
    }
    ei--;
  }
  return 0;
}

/** backend.su get_return_expr_ref：按 module 下标在 C 内读 Func.body_ref，勿传 SU 侧按值拷贝的 *Func。 */
int32_t pipeline_backend_get_return_expr_ref_at(struct ast_ASTArena *a, struct ast_Module *m,
                                                int32_t func_index) {
  struct ast_Func *f;
  if (!a || !m || func_index < 0 || func_index >= (int32_t)m->num_funcs)
    return 0;
  if (func_index >= (int32_t)m->num_funcs)
    return 0;
  f = pipeline_module_func_ptr(m, func_index);
  if (!f)
    return 0;
  return pipeline_backend_get_return_expr_ref(a, f);
}

/**
 * arm64.su get_return_lit_ref：同上，最小集返回值 ref 查找。
 */
int32_t pipeline_arm64_get_return_lit_ref(struct ast_ASTArena *a, struct ast_Func *f) {
  struct ast_Block *blk;
  struct ast_Expr *e;
  struct ast_Expr *inner;
  if (!a || !f || f->body_ref <= 0 || f->body_ref > a->num_blocks)
    return 0;
  blk = pipeline_arena_block_ptr(a, f->body_ref);
  if (!blk || blk->final_expr_ref <= 0 || blk->final_expr_ref > a->num_exprs)
    return 0;
  e = pipeline_arena_expr_ptr(a, blk->final_expr_ref);
  if (!e)
    return 0;
  if (e->kind == ast_ExprKind_EXPR_LIT || e->kind == ast_ExprKind_EXPR_BOOL_LIT)
    return blk->final_expr_ref;
  if (e->kind == ast_ExprKind_EXPR_RETURN && e->unary_operand_ref != 0) {
    if (e->unary_operand_ref <= 0 || e->unary_operand_ref > a->num_exprs)
      return 0;
    inner = pipeline_arena_expr_ptr(a, e->unary_operand_ref);
    if (inner && (inner->kind == ast_ExprKind_EXPR_LIT || inner->kind == ast_ExprKind_EXPR_BOOL_LIT))
      return e->unary_operand_ref;
  }
  return 0;
}

/** arm64.su get_return_lit_ref：按 module 下标在 C 内读 Func.body_ref。 */
int32_t pipeline_arm64_get_return_lit_ref_at(struct ast_ASTArena *a, struct ast_Module *m,
                                             int32_t func_index) {
  struct ast_Func *f;
  if (!a || !m || func_index < 0 || func_index >= (int32_t)m->num_funcs)
    return 0;
  if (func_index >= (int32_t)m->num_funcs)
    return 0;
  f = pipeline_module_func_ptr(m, func_index);
  if (!f)
    return 0;
  return pipeline_arm64_get_return_lit_ref(a, f);
}

/** INDEX 元素字节宽；避免 backend.su asm_index_elem_byte_sz 内 Type 局部副本自举 asm 失败。 */
int32_t pipeline_asm_index_elem_byte_sz(struct ast_ASTArena *a, int32_t index_expr_ref) {
  struct ast_Expr *ix;
  int32_t tr;
  enum ast_TypeKind k;
  if (!a || index_expr_ref <= 0 || index_expr_ref > a->num_exprs)
    return 4;
  ix = pipeline_arena_expr_ptr(a, index_expr_ref);
  if (!ix)
    return 4;
  tr = ix->resolved_type_ref;
  if (tr <= 0 || tr > a->num_types)
    return 4;
  {
    struct ast_Type *tp = pipeline_arena_type_ptr(a, tr);
    if (!tp)
      return 4;
    k = tp->kind;
  }
  if (k == ast_TypeKind_TYPE_U8)
    return 1;
  if (k == ast_TypeKind_TYPE_PTR || k == ast_TypeKind_TYPE_I64 || k == ast_TypeKind_TYPE_U64 ||
      k == ast_TypeKind_TYPE_USIZE || k == ast_TypeKind_TYPE_ISIZE || k == ast_TypeKind_TYPE_F64)
    return 8;
  return 4;
}

/** EXPR 池槽 index_base_ref / index_index_ref / resolved_type_ref / field_access_*。 */
int32_t pipeline_expr_index_base_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->index_base_ref : 0;
}

int32_t pipeline_expr_index_index_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->index_index_ref : 0;
}

int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->resolved_type_ref : 0;
}

int32_t pipeline_expr_field_access_offset(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->field_access_offset : 0;
}

/**
 * FIELD_ACCESS 字节偏移：优先 module struct layout 中字段 offset（strict typeck 未填 field_access_offset 时），
 * 否则回落 expr 上 typeck 写入的 field_access_offset。
 */
int32_t pipeline_expr_field_access_layout_offset(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref) {
  struct ast_Expr *ex;
  int32_t flen;
  uint8_t field_name[64];
  int32_t k;
  int32_t j;
  int32_t stored;
  if (!a || expr_ref <= 0)
    return 0;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return 0;
  stored = ex->field_access_offset;
  flen = ex->field_access_field_len;
  if (flen <= 0 || flen > 63)
    return stored;
  memcpy(field_name, ex->field_access_field_name, (size_t)flen);
  if (m) {
    for (k = 0; k < (int32_t)m->num_struct_layouts; k++) {
      for (j = 0; j < pipeline_module_struct_layout_num_fields(m, k); j++) {
        int32_t fnlen = pipeline_module_struct_layout_field_name_len(m, k, j);
        int32_t feq = 1;
        int32_t fi;
        if (fnlen != flen)
          continue;
        for (fi = 0; fi < fnlen; fi++) {
          uint8_t fb[64];
          pipeline_module_struct_layout_field_name_into(m, k, j, fb);
          if (fb[fi] != field_name[fi]) {
            feq = 0;
            break;
          }
        }
        if (!feq)
          continue;
        return pipeline_module_struct_layout_field_offset_at(m, k, j);
      }
    }
  }
  return stored;
}

/**
 * 按类型 ref 返回 FIELD_ACCESS 加载宽度（bool/u8=1，i32/u32/f32=4，i64/指针=8）。
 * 与 backend.su asm_field_access_load_byte_sz 中 TypeKind 分支一致。
 */
static int32_t glue_field_access_load_bytes_for_type_ref(struct ast_ASTArena *a, int32_t ty_ref) {
  int32_t kind_ord;
  if (!a || ty_ref <= 0 || ty_ref > a->num_types)
    return 8;
  kind_ord = pipeline_type_kind_ord_at(a, ty_ref);
  if (kind_ord == 2 || kind_ord == 1)
    return 1;
  if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13)
    return 4;
  if (kind_ord == 5 || kind_ord == 4 || kind_ord == 6 || kind_ord == 7 || kind_ord == 14 || kind_ord == 9)
    return 8;
  if (kind_ord == 8)
    return 8;
  return 4;
}

/**
 * resolved_type_ref 缺失或误为聚合/指针时：按 module struct layout + 字段名推断 load 宽度。
 * 修复 strict backend 编 core.option 时 opt.is_some 误 ldr x0（应为 ldrb）导致 option 测试失败。
 */
int32_t pipeline_expr_field_access_load_byte_sz(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref) {
  struct ast_Expr *ex;
  int32_t tr;
  int32_t base_tr;
  uint8_t struct_name[64];
  int32_t nlen;
  int32_t flen;
  uint8_t field_name[64];
  int32_t k;
  int32_t j;
  int32_t ftr;
  int32_t kind_ord;
  static const uint8_t nm_is_some[7] = { 105, 115, 95, 115, 111, 109, 101 };
  static const uint8_t nm_is_none[7] = { 105, 115, 95, 110, 111, 110, 101 };
  if (!a || expr_ref <= 0)
    return 8;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->field_access_base_ref <= 0)
    return 8;
  flen = ex->field_access_field_len;
  if (flen <= 0 || flen > 63)
    return 8;
  memcpy(field_name, ex->field_access_field_name, (size_t)flen);
  /* 任意 struct layout 中按字段名匹配（base resolved_type_ref 缺失时仍可用，如 core.option 形参 opt）。 */
  if (m) {
    for (k = 0; k < (int32_t)m->num_struct_layouts; k++) {
      for (j = 0; j < pipeline_module_struct_layout_num_fields(m, k); j++) {
        int32_t fnlen = pipeline_module_struct_layout_field_name_len(m, k, j);
        int32_t feq = 1;
        int32_t fi;
        if (fnlen != flen)
          continue;
        for (fi = 0; fi < fnlen; fi++) {
          uint8_t fb[64];
          pipeline_module_struct_layout_field_name_into(m, k, j, fb);
          if (fb[fi] != field_name[fi]) {
            feq = 0;
            break;
          }
        }
        if (!feq)
          continue;
        ftr = pipeline_module_struct_layout_field_type_ref(m, k, j);
        return glue_field_access_load_bytes_for_type_ref(a, ftr);
      }
    }
  }
  base_tr = pipeline_expr_resolved_type_ref(a, ex->field_access_base_ref);
  if (base_tr > 0 && pipeline_type_kind_ord_at(a, base_tr) == 8) {
    nlen = pipeline_type_named_name_into(a, base_tr, struct_name);
    if (nlen > 0 && nlen <= 63 && m) {
      for (k = 0; k < (int32_t)m->num_struct_layouts; k++) {
        int32_t ln = pipeline_module_struct_layout_name_len(m, k);
        int32_t eq = 1;
        if (ln != nlen)
          continue;
        for (j = 0; j < nlen; j++) {
          if (pipeline_module_struct_layout_name_byte_at(m, k, j) != struct_name[j]) {
            eq = 0;
            break;
          }
        }
        if (!eq)
          continue;
        for (j = 0; j < pipeline_module_struct_layout_num_fields(m, k); j++) {
          int32_t fnlen = pipeline_module_struct_layout_field_name_len(m, k, j);
          int32_t feq = 1;
          int32_t fi;
          if (fnlen != flen)
            continue;
          for (fi = 0; fi < fnlen; fi++) {
            uint8_t fb[64];
            pipeline_module_struct_layout_field_name_into(m, k, j, fb);
            if (fb[fi] != field_name[fi]) {
              feq = 0;
              break;
            }
          }
          if (!feq)
            continue;
          ftr = pipeline_module_struct_layout_field_type_ref(m, k, j);
          return glue_field_access_load_bytes_for_type_ref(a, ftr);
        }
      }
    }
  }
  tr = pipeline_expr_resolved_type_ref(a, expr_ref);
  if (tr > 0) {
    kind_ord = pipeline_type_kind_ord_at(a, tr);
    if (kind_ord != 8 && kind_ord != 10 && kind_ord != 11 && kind_ord != 12)
      return glue_field_access_load_bytes_for_type_ref(a, tr);
  }
  if (flen == 7 && memcmp(field_name, nm_is_some, 7) == 0)
    return 1;
  if (flen == 7 && memcmp(field_name, nm_is_none, 7) == 0)
    return 1;
  return 8;
}

int32_t pipeline_expr_field_access_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->field_access_is_enum_variant : 0;
}

/**
 * ExprKind.XXX / TypeKind.XXX 比较在 asm 中无局部槽；解析字段名返回变体序数，失败 -1。
 */
int32_t pipeline_expr_enum_namespace_field_tag(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  uint8_t base_buf[32];
  uint8_t field_buf[64];
  int32_t blen, flen;
  if (!a || expr_ref <= 0 || pipeline_expr_kind_ord_at(a, expr_ref) != 44)
    return -1;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return -1;
  if (ex->field_access_base_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(a, ex->field_access_base_ref) != 3)
    return -1;
  blen = pipeline_expr_var_name_len(a, ex->field_access_base_ref);
  if (blen <= 0 || blen > 31)
    return -1;
  pipeline_expr_var_name_into(a, ex->field_access_base_ref, base_buf);
  flen = pipeline_expr_field_access_name_len(a, expr_ref);
  if (flen <= 0 || flen > 63)
    return -1;
  pipeline_expr_field_access_name_into(a, expr_ref, field_buf);
  if (blen == 8 && memcmp(base_buf, "ExprKind", 8) == 0) {
    if (flen == 8 && memcmp(field_buf, "EXPR_LIT", 8) == 0)
      return 0;
    if (flen == 17 && memcmp(field_buf, "EXPR_FIELD_ACCESS", 17) == 0)
      return 44;
    if (flen == 9 && memcmp(field_buf, "EXPR_CALL", 9) == 0)
      return 48;
    if (flen == 8 && memcmp(field_buf, "EXPR_VAR", 8) == 0)
      return 3;
    if (flen == 9 && memcmp(field_buf, "EXPR_BLOCK", 9) == 0)
      return 26;
  }
  if (blen == 8 && memcmp(base_buf, "TypeKind", 8) == 0) {
    if (flen == 7 && memcmp(field_buf, "TYPE_I32", 7) == 0)
      return 0;
    if (flen == 8 && memcmp(field_buf, "TYPE_BOOL", 8) == 0)
      return 1;
    if (flen == 7 && memcmp(field_buf, "TYPE_U8", 7) == 0)
      return 2;
    if (flen == 7 && memcmp(field_buf, "TYPE_U32", 7) == 0)
      return 3;
    if (flen == 7 && memcmp(field_buf, "TYPE_U64", 7) == 0)
      return 4;
    if (flen == 7 && memcmp(field_buf, "TYPE_I64", 7) == 0)
      return 5;
    if (flen == 9 && memcmp(field_buf, "TYPE_USIZE", 9) == 0)
      return 6;
    if (flen == 9 && memcmp(field_buf, "TYPE_ISIZE", 9) == 0)
      return 7;
    if (flen == 9 && memcmp(field_buf, "TYPE_NAMED", 9) == 0)
      return 8;
    if (flen == 8 && memcmp(field_buf, "TYPE_PTR", 8) == 0)
      return 9;
    if (flen == 10 && memcmp(field_buf, "TYPE_ARRAY", 10) == 0)
      return 10;
    if (flen == 10 && memcmp(field_buf, "TYPE_SLICE", 10) == 0)
      return 11;
    if (flen == 11 && memcmp(field_buf, "TYPE_VECTOR", 11) == 0)
      return 12;
    if (flen == 8 && memcmp(field_buf, "TYPE_F32", 8) == 0)
      return 13;
    if (flen == 8 && memcmp(field_buf, "TYPE_F64", 8) == 0)
      return 14;
    if (flen == 9 && memcmp(field_buf, "TYPE_VOID", 9) == 0)
      return 15;
  }
  return -1;
}

/** backend.su 专用：避免 extern pipeline_type_kind_ord_at 被链接器解析为 codegen_ 前缀。 */
int32_t pipeline_backend_type_kind_ord_at(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_type_kind_ord_at(a, ref);
}

/**
 * backend.su asm 主循环 / fill_param_slots：仅 backend 模块声明 extern，转发至无前缀 pipeline_module_func_*，
 * 避免经 codegen import 产生 codegen_ 前缀未定义符号。
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

int32_t pipeline_asm_get_return_expr_ref_at(struct ast_ASTArena *a, struct ast_Module *m,
                                            int32_t func_index) {
  return pipeline_backend_get_return_expr_ref_at(a, m, func_index);
}

int32_t pipeline_asm_get_return_lit_ref_at(struct ast_ASTArena *a, struct ast_Module *m,
                                            int32_t func_index) {
  return pipeline_arm64_get_return_lit_ref_at(a, m, func_index);
}

/** build_asm/arm64.o 单模块编译时 arm64 模块前缀转发（与 backend 同源 glue）。 */
int32_t arch_arm64_pipeline_asm_module_func_is_extern_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_asm_module_func_is_extern_at(m, func_index);
}

int32_t arch_arm64_pipeline_asm_module_func_body_ref_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_asm_module_func_body_ref_at(m, func_index);
}

int32_t arch_arm64_pipeline_asm_module_func_name_len_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_asm_module_func_name_len_at(m, func_index);
}

void arch_arm64_pipeline_asm_module_func_name_copy64(struct ast_Module *m, int32_t func_index,
                                                     uint8_t *dst) {
  pipeline_asm_module_func_name_copy64(m, func_index, dst);
}

int32_t arch_arm64_pipeline_asm_get_return_lit_ref_at(struct ast_ASTArena *a, struct ast_Module *m,
                                                      int32_t func_index) {
  return pipeline_asm_get_return_lit_ref_at(a, m, func_index);
}

/** ast.su 池 init/alloc：须在 #include ast_pool.c 之前（ast_pool 内 strict parse 调 ast_ast_arena_init）。 */
void ast_expr_layout_prime_call_resolved(void) {
  /* ast.su expr_layout_prime_call_resolved；C glue 侧无额外状态。 */
}
void ast_ast_arena_init(struct ast_ASTArena *arena) {
  if (!arena)
    return;
  ast_expr_layout_prime_call_resolved();
  arena->num_types = 0;
  arena->num_exprs = 0;
  arena->num_blocks = 0;
  arena->num_funcs = 0;
}
int32_t ast_ast_arena_type_alloc(struct ast_ASTArena *a) {
  return pipeline_arena_type_alloc(a);
}
int32_t ast_ast_arena_expr_alloc(struct ast_ASTArena *a) {
  return pipeline_arena_expr_alloc(a);
}
int32_t ast_ast_arena_block_alloc(struct ast_ASTArena *a) {
  return pipeline_arena_block_alloc(a);
}
int32_t ast_ast_arena_func_alloc(struct ast_ASTArena *a) {
  return pipeline_arena_func_alloc(a);
}

/** ast_pool.c 内 pipeline_elf_ctx_resolve_patches 需前置声明（standalone TU 由 pipeline_glue_types.inc 提供）。 */
#ifndef SHU_PIPELINE_GLUE_STANDALONE_TU
void driver_diagnostic_asm_elf_unresolved_patch(const uint8_t *name, int32_t name_len);
#endif
struct platform_elf_ElfCodegenCtx;
void pipeline_elf_log_unresolved_patch(struct platform_elf_ElfCodegenCtx *ctx, int32_t patch_idx);

#include "ast_pool.c"

/** 将 let/const 声明类型 [N]T 回填到 ARRAY_LIT 初值的 resolved_type_ref（与 typeck_coerce_init_expr_to_decl 一致）。 */
static void glue_fill_array_lit_from_decl(struct ast_ASTArena *arena, int32_t decl_ty_ref, int32_t init_ref) {
  struct ast_Expr *init_ex;
  if (!arena || decl_ty_ref <= 0 || decl_ty_ref > arena->num_types || init_ref <= 0 ||
      init_ref > arena->num_exprs)
    return;
  if (pipeline_type_kind_ord_at(arena, decl_ty_ref) != GLUE_TYPE_KIND_ARRAY)
    return;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != 46)
    return;
  init_ex = pipeline_arena_expr_ptr(arena, init_ref);
  if (!init_ex)
    return;
  init_ex->resolved_type_ref = decl_ty_ref;
}

/** 块内 let 名与 EXPR_VAR 是否一致（长度与逐字节）。 */
static int glue_let_name_matches_var(struct ast_ASTArena *arena, int32_t expr_ref, const uint8_t *let_nm,
                                   int32_t let_nlen) {
  uint8_t vn[64];
  int32_t vlen;
  int32_t j;
  if (!arena || !let_nm || let_nlen <= 0 || expr_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != 3)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, expr_ref);
  if (vlen != let_nlen)
    return 0;
  pipeline_expr_var_name_into(arena, expr_ref, vn);
  for (j = 0; j < let_nlen; j++) {
    if (vn[j] != let_nm[j])
      return 0;
  }
  return 1;
}

/** 为块内 let 同名 EXPR_VAR 回填 resolved_type_ref（跳过 .su typeck 时 arr[i] 等 INDEX 需 base 类型）。 */
static void glue_fill_var_types_from_lets_in_block(struct ast_ASTArena *arena, int32_t block_ref) {
  int32_t nlet;
  int32_t li;
  int32_t ei;
  if (!arena || block_ref <= 0 || block_ref > arena->num_blocks)
    return;
  nlet = ast_ast_block_num_lets(arena, block_ref);
  for (li = 0; li < nlet; li++) {
    int32_t tref = pipeline_block_let_type_ref(arena, block_ref, li);
    uint8_t nm[64];
    int32_t nlen;
    if (tref <= 0)
      continue;
    nlen = pipeline_block_let_name_len(arena, block_ref, li);
    if (nlen <= 0 || nlen > 63)
      continue;
    pipeline_block_let_name_copy64(arena, block_ref, li, nm);
    for (ei = 1; ei <= arena->num_exprs; ei++) {
      struct ast_Expr *ex = pipeline_arena_expr_ptr(arena, ei);
      if (!ex)
        continue;
      if (glue_let_name_matches_var(arena, ei, nm, nlen)) {
        ex->resolved_type_ref = tref;
      }
    }
  }
}

/** 遍历块内 let，为跳过 .su typeck 的 asm 路径补齐 ARRAY_LIT 类型（hello [12]u8 等）。 */
static void glue_fill_array_lit_types_in_block(struct ast_ASTArena *arena, int32_t block_ref) {
  int32_t nlet;
  int32_t i;
  if (!arena || block_ref <= 0 || block_ref > arena->num_blocks)
    return;
  glue_fill_var_types_from_lets_in_block(arena, block_ref);
  nlet = ast_ast_block_num_lets(arena, block_ref);
  for (i = 0; i < nlet; i++) {
    glue_fill_array_lit_from_decl(arena, pipeline_block_let_type_ref(arena, block_ref, i),
                                ast_pipeline_block_let_init_ref(arena, block_ref, i));
  }
}

/**
 * C 预检后跳过 .su typeck 时：为各函数体块内 `let buf: [N]u8 = [..]` 回填 ARRAY_LIT 的 resolved_type_ref，
 * 使 pipeline_asm_array_lit_elem_type_ref 能取 u8 步长（避免 Hello 打成 H\\0e\\0…）。
 */
void pipeline_fill_array_lit_types_for_skipped_typeck(struct ast_Module *m, struct ast_ASTArena *arena) {
  int32_t fi;
  int32_t nf;
  if (!m || !arena)
    return;
  nf = m->num_funcs;
  for (fi = 0; fi < nf; fi++) {
    int32_t br = pipeline_module_func_body_ref_at(m, fi);
    glue_fill_array_lit_types_in_block(arena, br);
  }
}

/** platform.elf 模块内 call 带 platform_elf_ 前缀；转发 ast_pool 实现。 */
uint8_t *platform_elf_pipeline_elf_ctx_reloc_sym_name_ptr(uint8_t *ctx_bytes, int32_t idx) {
  return pipeline_elf_ctx_reloc_sym_name_ptr(ctx_bytes, idx);
}
void platform_elf_pipeline_elf_ctx_reloc_sym_name_copy64(uint8_t *ctx_bytes, int32_t idx, uint8_t *dst) {
  pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, idx, dst);
}
int32_t platform_elf_pipeline_elf_ctx_reloc_name_len(uint8_t *ctx_bytes, int32_t idx) {
  return pipeline_elf_ctx_reloc_name_len(ctx_bytes, idx);
}

/** pipeline.su 经 import codegen 解析 extern 时带 codegen_ 前缀。 */
int32_t codegen_codegen_out_buf_len(struct codegen_CodegenOutBuf *out) {
  return codegen_out_buf_len(out);
}
void codegen_codegen_out_buf_set_len(struct codegen_CodegenOutBuf *out, int32_t n) {
  codegen_out_buf_set_len(out, n);
}
int32_t pipeline_codegen_out_buf_len(struct codegen_CodegenOutBuf *out) {
  return codegen_out_buf_len(out);
}
void pipeline_codegen_out_buf_set_len(struct codegen_CodegenOutBuf *out, int32_t n) {
  codegen_out_buf_set_len(out, n);
}

/** asm.su 经 import codegen 解析 extern 时带 codegen_ 前缀；转发 ast_pool scratch。 */
uint8_t *codegen_pipeline_scratch_buf64(void) {
  return pipeline_scratch_buf64();
}
uint8_t *codegen_pipeline_scratch_buf64_slot(int32_t slot) {
  return pipeline_scratch_buf64_slot(slot);
}

/*
 * ast.su 中 extern pipeline_* 经 codegen 调用时带 ast_ 模块前缀（如 ast_pipeline_block_append_if），
 * 实现体在 ast_pool.c 为无前缀 C 符号；此处转发以满足链接。
 */
int32_t ast_pipeline_module_func_alloc_slot(struct ast_Module *m) {
  return pipeline_module_func_alloc_slot(m);
}
void ast_pipeline_module_func_ref_set(struct ast_Module *m, int32_t fi, int32_t func_ref) {
  pipeline_module_func_ref_set(m, fi, func_ref);
}
void ast_pipeline_module_func_set_return_type(struct ast_Module *m, int32_t fi, int32_t type_ref) {
  pipeline_module_func_set_return_type(m, fi, type_ref);
}
void ast_pipeline_module_func_set_body_ref(struct ast_Module *m, int32_t fi, int32_t body_ref) {
  pipeline_module_func_set_body_ref(m, fi, body_ref);
}
void ast_pipeline_module_func_set_body_expr_ref(struct ast_Module *m, int32_t fi, int32_t body_expr_ref) {
  pipeline_module_func_set_body_expr_ref(m, fi, body_expr_ref);
}
void ast_pipeline_module_func_set_is_extern(struct ast_Module *m, int32_t fi, int32_t is_extern) {
  pipeline_module_func_set_is_extern(m, fi, is_extern);
}
void ast_pipeline_module_func_set_num_params(struct ast_Module *m, int32_t fi, int32_t n) {
  pipeline_module_func_set_num_params(m, fi, n);
}
int32_t ast_pipeline_module_func_return_type_at(struct ast_Module *m, int32_t fi) {
  return pipeline_module_func_return_type_at(m, fi);
}
int32_t ast_pipeline_module_func_name_equal_at(struct ast_Module *m, int32_t fi, uint8_t *name, int32_t name_len) {
  return pipeline_module_func_name_equal_at(m, fi, name, name_len);
}
uint8_t ast_pipeline_module_func_name_byte_at(struct ast_Module *m, int32_t fi, int32_t i) {
  return pipeline_module_func_name_byte_at(m, fi, i);
}
int32_t ast_pipeline_module_func_body_expr_ref_at(struct ast_Module *m, int32_t fi) {
  return pipeline_module_func_body_expr_ref_at(m, fi);
}
int32_t ast_pipeline_ctx_append_lib_root(struct ast_PipelineDepCtx *ctx, uint8_t *path, int32_t len) {
  return pipeline_ctx_append_lib_root(ctx, path, len);
}
void ast_pipeline_dep_ctx_reset(struct ast_PipelineDepCtx *ctx) {
  pipeline_dep_ctx_reset(ctx);
}
/** ast.su extern pipeline_dep_ctx_*；typeck 经 ast_pipeline_* 前缀调用（ast_pool.c 实现 pipeline_*）。 */
int32_t ast_pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_ndep(ctx);
}
struct ast_Module *ast_pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  return pipeline_dep_ctx_module_at(ctx, idx);
}
struct ast_ASTArena *ast_pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  return pipeline_dep_ctx_arena_at(ctx, idx);
}
void ast_pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_Module *m) {
  pipeline_dep_ctx_set_module(ctx, idx, m);
}
void ast_pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_ASTArena *a) {
  pipeline_dep_ctx_set_arena(ctx, idx, a);
}
void ast_pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx *ctx, int32_t n) {
  pipeline_dep_ctx_set_ndep(ctx, n);
}
void ast_pipeline_dep_ctx_set_codegen_prefix_mirror(struct ast_PipelineDepCtx *ctx, uint8_t *bytes, int32_t len) {
  pipeline_dep_ctx_set_codegen_prefix_mirror(ctx, bytes, len);
}
int32_t ast_pipeline_dep_ctx_codegen_prefix_len(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_codegen_prefix_len(ctx);
}
uint8_t ast_pipeline_dep_ctx_codegen_prefix_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off) {
  return pipeline_dep_ctx_codegen_prefix_byte_at(ctx, off);
}
void ast_pipeline_dep_ctx_codegen_prefix_copy(struct ast_PipelineDepCtx *ctx, uint8_t *dst, int32_t cap) {
  pipeline_dep_ctx_codegen_prefix_copy(ctx, dst, cap);
}
int32_t ast_pipeline_dep_ctx_current_codegen_dep_index(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_current_codegen_dep_index(ctx);
}
struct ast_Module *ast_pipeline_dep_ctx_current_codegen_module(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_current_codegen_module(ctx);
}
struct ast_ASTArena *ast_pipeline_dep_ctx_current_codegen_arena(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_current_codegen_arena(ctx);
}
int32_t ast_pipeline_dep_ctx_current_func_index(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_current_func_index(ctx);
}
void ast_pipeline_dep_ctx_set_current_codegen_module(struct ast_PipelineDepCtx *ctx, struct ast_Module *m) {
  pipeline_dep_ctx_set_current_codegen_module(ctx, m);
}
void ast_pipeline_dep_ctx_set_current_codegen_arena(struct ast_PipelineDepCtx *ctx, struct ast_ASTArena *a) {
  pipeline_dep_ctx_set_current_codegen_arena(ctx, a);
}
void ast_pipeline_dep_ctx_set_current_codegen_dep_index(struct ast_PipelineDepCtx *ctx, int32_t ix) {
  pipeline_dep_ctx_set_current_codegen_dep_index(ctx, ix);
}
void ast_pipeline_dep_ctx_set_current_func_index(struct ast_PipelineDepCtx *ctx, int32_t ix) {
  pipeline_dep_ctx_set_current_func_index(ctx, ix);
}
int32_t ast_pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_entry_already_parsed(ctx);
}
int32_t ast_pipeline_dep_ctx_asm_entry_module_only(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_asm_entry_module_only(ctx);
}
int32_t ast_pipeline_dep_ctx_check_only_mode(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_check_only_mode(ctx);
}
int32_t ast_pipeline_dep_ctx_use_asm_backend(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_use_asm_backend(ctx);
}
uint8_t ast_pipeline_dep_ctx_entry_dir_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off) {
  return pipeline_dep_ctx_entry_dir_byte_at(ctx, off);
}
uint8_t *ast_pipeline_scratch_buf64(void) {
  return pipeline_scratch_buf64();
}
uint8_t *ast_pipeline_scratch_buf64_slot(int32_t slot) {
  return pipeline_scratch_buf64_slot(slot);
}
uint8_t *ast_pipeline_scratch_buf128(void) {
  return pipeline_scratch_buf128();
}
uint8_t *ast_pipeline_scratch_buf128_slot(int32_t slot) {
  return pipeline_scratch_buf128_slot(slot);
}
uint8_t *ast_pipeline_scratch_buf96(void) {
  return pipeline_scratch_buf96();
}
uint8_t *ast_pipeline_scratch_buf256(void) {
  return pipeline_scratch_buf256();
}
uint8_t *ast_pipeline_scratch_buf256_slot(int32_t slot) {
  return pipeline_scratch_buf256_slot(slot);
}
int32_t ast_pipeline_codegen_type_kind_copy(uint8_t *dst, int32_t cap, int32_t kind) {
  return pipeline_codegen_type_kind_copy(dst, cap, kind);
}
int32_t ast_pipeline_codegen_type_kind_append(uint8_t *scratch, int32_t cap, int32_t w, int32_t kind) {
  return pipeline_codegen_type_kind_append(scratch, cap, w, kind);
}
int32_t ast_pipeline_codegen_vector_type_copy(uint8_t *dst, int32_t cap, int32_t elem_kind, int32_t lanes) {
  return pipeline_codegen_vector_type_copy(dst, cap, elem_kind, lanes);
}
int32_t ast_pipeline_codegen_call_num_args_override_lookup(uint8_t *buf, int32_t full, int32_t num_args) {
  return pipeline_codegen_call_num_args_override_lookup(buf, full, num_args);
}
int32_t ast_pipeline_codegen_call_num_args_override(uint8_t *prefix, int32_t prefix_len, uint8_t *name,
                                                    int32_t name_len, int32_t num_args) {
  return pipeline_codegen_call_num_args_override(prefix, prefix_len, name, name_len, num_args);
}
int32_t ast_pipeline_codegen_is_std_io_driver_bridge_name(uint8_t *name, int32_t name_len) {
  return pipeline_codegen_is_std_io_driver_bridge_name(name, name_len);
}
int32_t ast_pipeline_codegen_path_is_std_io_driver_bytes(uint8_t *path) {
  return pipeline_codegen_path_is_std_io_driver_bytes(path);
}
int32_t ast_pipeline_codegen_path_is_std_io_core_bytes(uint8_t *path) {
  return pipeline_codegen_path_is_std_io_core_bytes(path);
}
int32_t ast_pipeline_codegen_should_skip_emit_std_io_core_io_dup(uint8_t *dep_path, uint8_t *name, int32_t name_len) {
  return pipeline_codegen_should_skip_emit_std_io_core_io_dup(dep_path, name, name_len);
}
int32_t ast_pipeline_codegen_should_skip_emit_std_io_trivial_handle(uint8_t *dep_path, uint8_t *name,
                                                                    int32_t name_len) {
  return pipeline_codegen_should_skip_emit_std_io_trivial_handle(dep_path, name, name_len);
}
int32_t ast_pipeline_codegen_should_skip_emit_func(uint8_t *dep_path, uint8_t *prefix, int32_t prefix_len,
                                                   uint8_t *name, int32_t name_len) {
  return pipeline_codegen_should_skip_emit_func(dep_path, prefix, prefix_len, name, name_len);
}
int32_t ast_pipeline_codegen_skip_emit_extern_io_batch_buf(uint8_t *name, int32_t name_len) {
  return pipeline_codegen_skip_emit_extern_io_batch_buf(name, name_len);
}
int32_t ast_pipeline_codegen_entry_is_lsp_io_module(struct ast_Module *module) {
  return pipeline_codegen_entry_is_lsp_io_module(module);
}
int32_t ast_pipeline_codegen_entry_is_lsp_main_module(struct ast_Module *module) {
  return pipeline_codegen_entry_is_lsp_main_module(module);
}
int32_t ast_pipeline_codegen_force_param_std_io_driver_prefix_ok(uint8_t *prefix, int32_t prefix_len) {
  return pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len);
}
int32_t ast_pipeline_codegen_force_param_size_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                                int32_t param_index) {
  return pipeline_codegen_force_param_size_t(prefix, prefix_len, name, name_len, param_index);
}
int32_t ast_pipeline_codegen_force_param_size_t_std_io_print_str_second(uint8_t *prefix, int32_t prefix_len,
                                                                        uint8_t *name, int32_t name_len,
                                                                        int32_t param_index) {
  return pipeline_codegen_force_param_size_t_std_io_print_str_second(prefix, prefix_len, name, name_len, param_index);
}
int32_t ast_pipeline_codegen_force_param_ptrdiff_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                                   int32_t param_index) {
  return pipeline_codegen_force_param_ptrdiff_t(prefix, prefix_len, name, name_len, param_index);
}
int32_t ast_pipeline_codegen_force_param_uint32_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                                  int32_t param_index) {
  return pipeline_codegen_force_param_uint32_t(prefix, prefix_len, name, name_len, param_index);
}
int32_t ast_pipeline_codegen_use_buf_wrapper(uint8_t *name, int32_t name_len, int32_t num_args) {
  return pipeline_codegen_use_buf_wrapper(name, name_len, num_args);
}
int32_t ast_pipeline_codegen_should_skip_emit_func_by_name(uint8_t *name, int32_t name_len) {
  return pipeline_codegen_should_skip_emit_func_by_name(name, name_len);
}
int32_t ast_pipeline_codegen_is_submit_batch_buf_call(uint8_t *name, int32_t name_len) {
  return pipeline_codegen_is_submit_batch_buf_call(name, name_len);
}
int32_t ast_pipeline_codegen_should_skip_emit_func_core_read_ptr(uint8_t *name, int32_t name_len) {
  return pipeline_codegen_should_skip_emit_func_core_read_ptr(name, name_len);
}
int32_t ast_pipeline_codegen_io_driver_buf_call_sym(uint8_t *name, int32_t name_len, int32_t num_args,
                                                    uint8_t *sym_out, int32_t sym_cap) {
  return pipeline_codegen_io_driver_buf_call_sym(name, name_len, num_args, sym_out, sym_cap);
}
int32_t ast_pipeline_codegen_std_io_fixed_fd_emit_impl(uint8_t *prefix, int32_t prefix_len, uint8_t *name,
                                                     int32_t name_len) {
  return pipeline_codegen_std_io_fixed_fd_emit_impl(prefix, prefix_len, name, name_len);
}
int32_t ast_pipeline_elf_ctx_append_patch(uint8_t *ctx_bytes, int32_t rel32_offset, uint8_t *name, int32_t name_len,
                                          int32_t imm_bits) {
  return pipeline_elf_ctx_append_patch(ctx_bytes, rel32_offset, name, name_len, imm_bits);
}
int32_t ast_pipeline_elf_ctx_append_reloc(uint8_t *ctx_bytes, int32_t offset, uint8_t *name, int32_t name_len) {
  return pipeline_elf_ctx_append_reloc(ctx_bytes, offset, name, name_len);
}
void ast_pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *bytes, int32_t len) {
  pipeline_dep_ctx_set_import_path(ctx, idx, bytes, len);
}
int32_t ast_pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  return pipeline_dep_ctx_import_path_len(ctx, idx);
}
void ast_pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst) {
  pipeline_dep_ctx_import_path_copy64(ctx, idx, dst);
}
void ast_pipeline_dep_ctx_set_path_buf_byte(struct ast_PipelineDepCtx *ctx, int32_t off, uint8_t b) {
  pipeline_dep_ctx_set_path_buf_byte(ctx, off, b);
}
int32_t ast_pipeline_dep_ctx_entry_dir_len(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_entry_dir_len(ctx);
}
uint8_t *ast_pipeline_dep_ctx_loaded_buf_ptr(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_loaded_buf_ptr(ctx);
}
int32_t ast_pipeline_dep_ctx_ensure_source_buffers(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_ensure_source_buffers(ctx);
}
void ast_pipeline_dep_ctx_free_source_buffers(struct ast_PipelineDepCtx *ctx) {
  pipeline_dep_ctx_free_source_buffers(ctx);
}
void ast_pipeline_dep_ctx_heap_destroy(struct ast_PipelineDepCtx *ctx) {
  pipeline_dep_ctx_heap_destroy(ctx);
}
uint8_t *ast_pipeline_dep_ctx_path_buf_ptr(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_path_buf_ptr(ctx);
}
uint8_t *ast_pipeline_dep_ctx_preprocess_buf_ptr(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_preprocess_buf_ptr(ctx);
}
void ast_pipeline_dep_ctx_set_loaded_len(struct ast_PipelineDepCtx *ctx, ptrdiff_t n) {
  pipeline_dep_ctx_set_loaded_len(ctx, n);
}
int32_t ast_pipeline_ctx_lib_root_count(struct ast_PipelineDepCtx *ctx) {
  return pipeline_ctx_lib_root_count(ctx);
}
int32_t ast_pipeline_ctx_lib_root_len(struct ast_PipelineDepCtx *ctx, int32_t i) {
  return pipeline_ctx_lib_root_len(ctx, i);
}
void ast_pipeline_ctx_lib_root_copy(struct ast_PipelineDepCtx *ctx, int32_t i, uint8_t *dst, int32_t cap) {
  pipeline_ctx_lib_root_copy(ctx, i, dst, cap);
}
uint8_t ast_pipeline_ctx_lib_root_byte_at(struct ast_PipelineDepCtx *ctx, int32_t i, int32_t off) {
  return pipeline_ctx_lib_root_byte_at(ctx, i, off);
}
int32_t ast_pipeline_block_append_const(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                        int32_t type_ref, int32_t init_ref) {
  return pipeline_block_append_const(a, br, name, name_len, type_ref, init_ref);
}
int32_t ast_pipeline_block_append_let(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                      int32_t type_ref, int32_t init_ref) {
  return pipeline_block_append_let(a, br, name, name_len, type_ref, init_ref);
}
int32_t ast_pipeline_block_append_if(struct ast_ASTArena *a, int32_t br, int32_t cond_ref, int32_t then_ref,
                                     int32_t else_ref) {
  return pipeline_block_append_if(a, br, cond_ref, then_ref, else_ref);
}
int32_t ast_pipeline_block_append_while(struct ast_ASTArena *a, int32_t br, int32_t cond_ref, int32_t body_ref) {
  return pipeline_block_append_while(a, br, cond_ref, body_ref);
}
int32_t ast_pipeline_block_append_for(struct ast_ASTArena *a, int32_t br, int32_t init_ref, int32_t cond_ref,
                                      int32_t step_ref, int32_t body_ref) {
  return pipeline_block_append_for(a, br, init_ref, cond_ref, step_ref, body_ref);
}
int32_t ast_pipeline_module_import_alloc(struct ast_Module *m) {
  return pipeline_module_import_alloc(m);
}
void ast_pipeline_module_import_set_path(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  pipeline_module_import_set_path(m, idx, bytes, len);
}
void ast_pipeline_module_import_set_kind(struct ast_Module *m, int32_t idx, int32_t kind) {
  pipeline_module_import_set_kind(m, idx, kind);
}
void ast_pipeline_module_import_set_binding_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  pipeline_module_import_set_binding_name(m, idx, bytes, len);
}
void ast_pipeline_module_import_set_select_count(struct ast_Module *m, int32_t idx, int32_t n) {
  pipeline_module_import_set_select_count(m, idx, n);
}
void ast_pipeline_module_import_path_copy(struct ast_Module *m, int32_t idx, uint8_t *dst, int32_t dst_cap) {
  pipeline_module_import_path_copy(m, idx, dst, dst_cap);
}
int32_t ast_pipeline_module_enum_alloc(struct ast_Module *m) {
  return pipeline_module_enum_alloc(m);
}
void ast_pipeline_module_enum_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  pipeline_module_enum_set_name(m, idx, bytes, len);
}
int32_t ast_pipeline_module_top_level_let_alloc(struct ast_Module *m) {
  return pipeline_module_top_level_let_alloc(m);
}
void ast_pipeline_module_top_level_let_set(struct ast_Module *m, int32_t idx, uint8_t *name, int32_t name_len,
                                            int32_t type_ref, int32_t init_ref, int32_t is_const) {
  pipeline_module_top_level_let_set(m, idx, name, name_len, type_ref, init_ref, is_const);
}
void ast_pipeline_module_hoist_top_level_lets_into_main(struct ast_Module *m, struct ast_ASTArena *a) {
  pipeline_module_hoist_top_level_lets_into_main(m, a);
}
int32_t ast_pipeline_module_import_path_len(struct ast_Module *m, int32_t idx) {
  return pipeline_module_import_path_len(m, idx);
}
uint8_t ast_pipeline_module_import_path_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  return pipeline_module_import_path_byte_at(m, idx, off);
}
int32_t ast_pipeline_module_import_kind_at(struct ast_Module *m, int32_t idx) {
  return pipeline_module_import_kind_at(m, idx);
}
int32_t ast_pipeline_module_import_binding_name_len(struct ast_Module *m, int32_t idx) {
  return pipeline_module_import_binding_name_len(m, idx);
}
uint8_t ast_pipeline_module_import_binding_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  return pipeline_module_import_binding_name_byte_at(m, idx, off);
}
int32_t ast_pipeline_module_import_select_count_at(struct ast_Module *m, int32_t idx) {
  return pipeline_module_import_select_count_at(m, idx);
}
int32_t ast_pipeline_module_import_select_name_len(struct ast_Module *m, int32_t idx, int32_t sel) {
  return pipeline_module_import_select_name_len(m, idx, sel);
}
uint8_t ast_pipeline_module_import_select_name_byte_at(struct ast_Module *m, int32_t idx, int32_t sel, int32_t off) {
  return pipeline_module_import_select_name_byte_at(m, idx, sel, off);
}
int32_t ast_pipeline_module_struct_layout_alloc(struct ast_Module *m) {
  return pipeline_module_struct_layout_alloc(m);
}
void ast_pipeline_module_struct_layout_reset_slot(struct ast_Module *m, int32_t idx) {
  pipeline_module_struct_layout_reset_slot(m, idx);
}
void ast_pipeline_module_struct_layout_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  pipeline_module_struct_layout_set_name(m, idx, bytes, len);
}
void ast_pipeline_module_struct_layout_set_field(struct ast_Module *m, int32_t li, int32_t j, uint8_t *fname_bytes,
                                                 int32_t fname_len, int32_t ftype_ref, int32_t foff) {
  pipeline_module_struct_layout_set_field(m, li, j, fname_bytes, fname_len, ftype_ref, foff);
}
void ast_pipeline_module_struct_layout_set_num_fields(struct ast_Module *m, int32_t idx, int32_t nf) {
  pipeline_module_struct_layout_set_num_fields(m, idx, nf);
}
int32_t ast_pipeline_module_struct_layout_name_len(struct ast_Module *m, int32_t idx) {
  return pipeline_module_struct_layout_name_len(m, idx);
}
void ast_pipeline_module_struct_layout_name_into(struct ast_Module *m, int32_t idx, uint8_t *out64) {
  pipeline_module_struct_layout_name_into(m, idx, out64);
}
uint8_t ast_pipeline_module_struct_layout_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  return pipeline_module_struct_layout_name_byte_at(m, idx, off);
}
int32_t ast_pipeline_module_struct_layout_num_fields(struct ast_Module *m, int32_t idx) {
  return pipeline_module_struct_layout_num_fields(m, idx);
}
int32_t ast_pipeline_module_struct_layout_field_name_len(struct ast_Module *m, int32_t li, int32_t j) {
  return pipeline_module_struct_layout_field_name_len(m, li, j);
}
void ast_pipeline_module_struct_layout_field_name_into(struct ast_Module *m, int32_t li, int32_t j, uint8_t *out64) {
  pipeline_module_struct_layout_field_name_into(m, li, j, out64);
}
int32_t ast_pipeline_module_struct_layout_field_type_ref(struct ast_Module *m, int32_t li, int32_t j) {
  return pipeline_module_struct_layout_field_type_ref(m, li, j);
}
int32_t ast_pipeline_module_struct_layout_field_offset_at(struct ast_Module *m, int32_t li, int32_t j) {
  return pipeline_module_struct_layout_field_offset_at(m, li, j);
}
void ast_pipeline_module_struct_layout_set_allow_padding(struct ast_Module *m, int32_t idx, int32_t v) {
  pipeline_module_struct_layout_set_allow_padding(m, idx, v);
}
int32_t ast_pipeline_module_struct_layout_allow_padding_at(struct ast_Module *m, int32_t idx) {
  return pipeline_module_struct_layout_allow_padding_at(m, idx);
}
int32_t ast_pipeline_module_top_level_let_name_len(struct ast_Module *m, int32_t idx) {
  return pipeline_module_top_level_let_name_len(m, idx);
}
uint8_t ast_pipeline_module_top_level_let_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  return pipeline_module_top_level_let_name_byte_at(m, idx, off);
}
int32_t ast_pipeline_module_top_level_let_type_ref(struct ast_Module *m, int32_t idx) {
  return pipeline_module_top_level_let_type_ref(m, idx);
}
int32_t ast_pipeline_module_top_level_let_init_ref(struct ast_Module *m, int32_t idx) {
  return pipeline_module_top_level_let_init_ref(m, idx);
}
int32_t ast_pipeline_module_top_level_let_is_const(struct ast_Module *m, int32_t idx) {
  return pipeline_module_top_level_let_is_const(m, idx);
}
int32_t ast_pipeline_module_enum_name_len(struct ast_Module *m, int32_t idx) {
  return pipeline_module_enum_name_len(m, idx);
}
uint8_t ast_pipeline_module_enum_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  return pipeline_module_enum_name_byte_at(m, idx, off);
}

int32_t ast_pipeline_module_enum_append_variant(struct ast_Module *m, int32_t idx, uint8_t *bytes,
                                                int32_t len) {
  return pipeline_module_enum_append_variant(m, idx, bytes, len);
}

int32_t ast_pipeline_module_enum_variant_tag_for_names(struct ast_Module *m, uint8_t *enum_name,
                                                         int32_t enum_len, uint8_t *variant_name,
                                                         int32_t variant_len) {
  return pipeline_module_enum_variant_tag_for_names(m, enum_name, enum_len, variant_name, variant_len);
}

void ast_pipeline_expr_try_mark_enum_field_access(struct ast_Module *m, struct ast_ASTArena *a,
                                                  int32_t expr_ref) {
  pipeline_expr_try_mark_enum_field_access(m, a, expr_ref);
}
void ast_ast_pool_onefunc_reset(uint8_t *out) {
  ast_pool_onefunc_reset(out);
}
int32_t ast_pipeline_onefunc_num_consts(uint8_t *out) {
  return pipeline_onefunc_num_consts(out);
}
int32_t ast_pipeline_onefunc_num_lets(uint8_t *out) {
  return pipeline_onefunc_num_lets(out);
}
int32_t ast_pipeline_onefunc_num_whiles(uint8_t *out) {
  return pipeline_onefunc_num_whiles(out);
}
int32_t ast_pipeline_onefunc_num_fors(uint8_t *out) {
  return pipeline_onefunc_num_fors(out);
}
int32_t ast_pipeline_onefunc_const_name_len(uint8_t *out, int32_t i) {
  return pipeline_onefunc_const_name_len(out, i);
}
void ast_pipeline_onefunc_const_name_copy64(uint8_t *out, int32_t i, uint8_t *dst) {
  pipeline_onefunc_const_name_copy64(out, i, dst);
}
int32_t ast_pipeline_onefunc_const_init_val(uint8_t *out, int32_t i) {
  return pipeline_onefunc_const_init_val(out, i);
}
int32_t ast_pipeline_onefunc_let_name_len(uint8_t *out, int32_t i) {
  return pipeline_onefunc_let_name_len(out, i);
}
void ast_pipeline_onefunc_let_name_copy64(uint8_t *out, int32_t i, uint8_t *dst) {
  pipeline_onefunc_let_name_copy64(out, i, dst);
}
int32_t ast_pipeline_onefunc_let_init_val(uint8_t *out, int32_t i) {
  return pipeline_onefunc_let_init_val(out, i);
}
int32_t ast_pipeline_onefunc_let_init_ref(uint8_t *out, int32_t i) {
  return pipeline_onefunc_let_init_ref(out, i);
}
int32_t ast_pipeline_onefunc_let_type_ref(uint8_t *out, int32_t i) {
  return pipeline_onefunc_let_type_ref(out, i);
}
int32_t ast_pipeline_onefunc_append_let(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val, int32_t init_ref,
                                        int32_t type_ref) {
  return pipeline_onefunc_append_let(out, name, name_len, init_val, init_ref, type_ref);
}
int32_t ast_pipeline_onefunc_append_const(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val,
                                          int32_t init_ref, int32_t type_ref) {
  return pipeline_onefunc_append_const(out, name, name_len, init_val, init_ref, type_ref);
}
int32_t ast_pipeline_onefunc_const_init_ref(uint8_t *out, int32_t i) {
  return pipeline_onefunc_const_init_ref(out, i);
}
int32_t ast_pipeline_onefunc_const_type_ref(uint8_t *out, int32_t i) {
  return pipeline_onefunc_const_type_ref(out, i);
}
int32_t ast_pipeline_onefunc_append_while(uint8_t *out, int32_t cond_ref, int32_t body_ref) {
  return pipeline_onefunc_append_while(out, cond_ref, body_ref);
}
int32_t ast_pipeline_onefunc_append_for(uint8_t *out, int32_t init_ref, int32_t cond_ref, int32_t step_ref,
                                        int32_t body_ref) {
  return pipeline_onefunc_append_for(out, init_ref, cond_ref, step_ref, body_ref);
}
void ast_pipeline_onefunc_copy_sidecar(uint8_t *dst, uint8_t *src) {
  pipeline_onefunc_copy_sidecar(dst, src);
}
int32_t ast_pipeline_block_append_expr_stmt(struct ast_ASTArena *a, int32_t br, int32_t expr_ref) {
  return pipeline_block_append_expr_stmt(a, br, expr_ref);
}
int32_t ast_pipeline_block_append_stmt_order(struct ast_ASTArena *a, int32_t br, uint8_t kind, int32_t idx) {
  return pipeline_block_append_stmt_order(a, br, kind, idx);
}
int32_t ast_pipeline_block_append_labeled(struct ast_ASTArena *a, int32_t br, int32_t label_len, int32_t is_goto,
                                           int32_t goto_target_len, int32_t return_expr_ref) {
  return pipeline_block_append_labeled(a, br, label_len, is_goto, goto_target_len, return_expr_ref);
}
int32_t ast_pipeline_block_labeled_return_expr_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  return pipeline_block_labeled_return_expr_ref(a, br, li);
}
void ast_pipeline_block_fill_ifs_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  pipeline_block_fill_ifs_from_onefunc(a, br, out, count);
}
void ast_pipeline_block_fill_whiles_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  pipeline_block_fill_whiles_from_onefunc(a, br, out, count);
}
void ast_pipeline_block_fill_fors_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  pipeline_block_fill_fors_from_onefunc(a, br, out, count);
}
void ast_pipeline_block_fill_stmt_order_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  pipeline_block_fill_stmt_order_from_onefunc(a, br, out, count);
}
void ast_pipeline_block_fill_expr_stmts_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  pipeline_block_fill_expr_stmts_from_onefunc(a, br, out, count);
}
int32_t ast_pipeline_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  return pipeline_block_const_init_ref(a, br, ci);
}
int32_t ast_pipeline_block_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  return pipeline_block_const_type_ref(a, br, ci);
}
int32_t ast_pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  return pipeline_block_let_init_ref(a, br, li);
}
int32_t ast_pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  return pipeline_block_let_type_ref(a, br, li);
}
int32_t ast_pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei) {
  return pipeline_block_expr_stmt_ref(a, br, ei);
}
uint8_t ast_pipeline_block_stmt_order_kind(struct ast_ASTArena *a, int32_t br, int32_t si) {
  return pipeline_block_stmt_order_kind(a, br, si);
}
int32_t ast_pipeline_block_stmt_order_idx(struct ast_ASTArena *a, int32_t br, int32_t si) {
  return pipeline_block_stmt_order_idx(a, br, si);
}
int32_t ast_pipeline_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  return pipeline_block_if_cond_ref(a, br, ii);
}
int32_t ast_pipeline_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  return pipeline_block_if_then_body_ref(a, br, ii);
}
int32_t ast_pipeline_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  return pipeline_block_if_else_body_ref(a, br, ii);
}
int32_t ast_pipeline_block_const_name_len(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  return pipeline_block_const_name_len(a, br, ci);
}
void ast_pipeline_block_const_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t ci, uint8_t *dst) {
  pipeline_block_const_name_copy64(a, br, ci, dst);
}
int32_t ast_pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li) {
  return pipeline_block_let_name_len(a, br, li);
}
void ast_pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst) {
  pipeline_block_let_name_copy64(a, br, li, dst);
}
int32_t ast_pipeline_block_resolve_var_type_ref(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname,
                                                 int32_t vlen) {
  return pipeline_block_resolve_var_type_ref(a, block_ref, vname, vlen);
}
int32_t ast_pipeline_module_func_ref_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_module_func_ref_at(m, func_index);
}
int32_t ast_pipeline_arena_type_cap(void) { return pipeline_arena_type_cap(); }
int32_t ast_pipeline_arena_expr_cap(void) { return pipeline_arena_expr_cap(); }
int32_t ast_pipeline_arena_block_cap(void) { return pipeline_arena_block_cap(); }
int32_t ast_pipeline_arena_func_cap(void) { return pipeline_arena_func_cap(); }
int32_t ast_pipeline_arena_type_alloc(struct ast_ASTArena *a) { return pipeline_arena_type_alloc(a); }
int32_t ast_pipeline_arena_expr_alloc(struct ast_ASTArena *a) { return pipeline_arena_expr_alloc(a); }
int32_t ast_pipeline_arena_block_alloc(struct ast_ASTArena *a) { return pipeline_arena_block_alloc(a); }
int32_t ast_pipeline_arena_func_alloc(struct ast_ASTArena *a) { return pipeline_arena_func_alloc(a); }

/**
 * ast.su 中 ast_arena_*_get/set 仅作 extern 声明；实现在此，避免 shu-c -E 将 get 错误 lowering 为
 * arena->exprs[] / blocks[] 直访（slim ASTArena 已无内嵌数组）。
 * ast_ast_arena_* 供 ast 模块 hoisted 声明；ast_arena_* 供 import ast 的其他模块链接。
 */
struct ast_Type ast_ast_arena_type_get(struct ast_ASTArena *a, int32_t ref) {
  struct ast_Type empty;
  if (ref <= 0) {
    memset(&empty, 0, sizeof(empty));
    return empty;
  }
  return pipeline_arena_type_get_copy(a, ref);
}
void ast_ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t) {
  pipeline_arena_type_set_copy(a, ref, t);
}
struct ast_Expr ast_ast_arena_expr_get(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_expr_get_copy(a, ref);
}
void ast_ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e) {
  pipeline_arena_expr_set_copy(a, ref, e);
}
struct ast_Block ast_ast_arena_block_get(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_block_get_copy(a, ref);
}
void ast_ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b) {
  pipeline_arena_block_set_copy(a, ref, b);
}
struct ast_Func ast_ast_arena_func_get(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_func_get_copy(a, ref);
}
void ast_ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f) {
  pipeline_arena_func_set_copy(a, ref, f);
}
struct ast_Type ast_arena_type_get(struct ast_ASTArena *a, int32_t ref) {
  return ast_ast_arena_type_get(a, ref);
}
void ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t) {
  ast_ast_arena_type_set(a, ref, t);
}
struct ast_Expr ast_arena_expr_get(struct ast_ASTArena *a, int32_t ref) {
  return ast_ast_arena_expr_get(a, ref);
}
void ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e) {
  ast_ast_arena_expr_set(a, ref, e);
}
struct ast_Block ast_arena_block_get(struct ast_ASTArena *a, int32_t ref) {
  return ast_ast_arena_block_get(a, ref);
}
void ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b) {
  ast_ast_arena_block_set(a, ref, b);
}
struct ast_Func ast_arena_func_get(struct ast_ASTArena *a, int32_t ref) {
  return ast_ast_arena_func_get(a, ref);
}
void ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f) {
  ast_ast_arena_func_set(a, ref, f);
}

int ast_ref_is_null(int32_t ref) {
  return ref == 0;
}

void ast_ast_arena_patch_block_parent_links(struct ast_ASTArena *arena, int32_t block_ref, int32_t parent_ref) {
  pipeline_patch_block_parent_links(arena, block_ref, parent_ref);
}

int32_t ast_ast_block_num_consts(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block blk;
  if (!a || br <= 0 || br > a->num_blocks)
    return 0;
  blk = ast_ast_arena_block_get(a, br);
  return blk.num_consts;
}
int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block blk;
  if (!a || br <= 0 || br > a->num_blocks)
    return 0;
  blk = ast_ast_arena_block_get(a, br);
  return blk.num_lets;
}
int32_t ast_ast_block_num_loops(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block blk;
  if (!a || br <= 0 || br > a->num_blocks)
    return 0;
  blk = ast_ast_arena_block_get(a, br);
  return blk.num_loops;
}
int32_t ast_ast_block_num_for_loops(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block blk;
  if (!a || br <= 0 || br > a->num_blocks)
    return 0;
  blk = ast_ast_arena_block_get(a, br);
  return blk.num_for_loops;
}
int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block blk;
  if (!a || br <= 0 || br > a->num_blocks)
    return 0;
  blk = ast_ast_arena_block_get(a, br);
  return blk.num_if_stmts;
}
int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block blk;
  if (!a || br <= 0 || br > a->num_blocks)
    return 0;
  blk = ast_ast_arena_block_get(a, br);
  return blk.num_expr_stmts;
}
int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block blk;
  if (!a || br <= 0 || br > a->num_blocks)
    return 0;
  blk = ast_ast_arena_block_get(a, br);
  return blk.num_stmt_order;
}
uint8_t ast_ast_block_stmt_order_kind(struct ast_ASTArena *a, int32_t br, int32_t si) {
  return pipeline_block_stmt_order_kind(a, br, si);
}
int32_t ast_ast_block_stmt_order_idx(struct ast_ASTArena *a, int32_t br, int32_t si) {
  return pipeline_block_stmt_order_idx(a, br, si);
}
int32_t ast_ast_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  return pipeline_block_const_init_ref(a, br, ci);
}
int32_t ast_ast_block_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  return pipeline_block_const_type_ref(a, br, ci);
}
int32_t ast_ast_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  return pipeline_block_let_init_ref(a, br, li);
}
int32_t ast_ast_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  return pipeline_block_let_type_ref(a, br, li);
}
int32_t ast_ast_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei) {
  return pipeline_block_expr_stmt_ref(a, br, ei);
}
int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block blk;
  if (!a || br <= 0 || br > a->num_blocks)
    return 0;
  blk = ast_ast_arena_block_get(a, br);
  return blk.final_expr_ref;
}
int32_t ast_ast_block_while_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t wi) {
  return pipeline_block_while_cond_ref(a, br, wi);
}
int32_t ast_ast_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi) {
  return pipeline_block_while_body_ref(a, br, wi);
}
int32_t ast_ast_block_for_init_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  return pipeline_block_for_init_ref(a, br, fi);
}
int32_t ast_ast_block_for_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  return pipeline_block_for_cond_ref(a, br, fi);
}
int32_t ast_ast_block_for_step_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  return pipeline_block_for_step_ref(a, br, fi);
}
int32_t ast_ast_block_for_body_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  return pipeline_block_for_body_ref(a, br, fi);
}
int32_t ast_ast_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  return pipeline_block_if_cond_ref(a, br, ii);
}
int32_t ast_ast_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  return pipeline_block_if_then_body_ref(a, br, ii);
}
int32_t ast_ast_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  return pipeline_block_if_else_body_ref(a, br, ii);
}
int32_t ast_ast_block_resolve_var_to_type_ref(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname, int32_t vlen) {
  return pipeline_block_resolve_var_type_ref(a, block_ref, vname, vlen);
}
int ast_ast_expr_disallows_implicit_tail(struct ast_ASTArena *a, int32_t expr_ref) {
  return implicit_tail_expr_disallowed_by_glue(a, expr_ref);
}
void ast_ast_expr_apply_call_resolve(struct ast_ASTArena *a, int32_t call_expr_ref, int32_t dep_ix, int32_t func_ix) {
  pipeline_expr_apply_call_resolve(a, call_expr_ref, dep_ix, func_ix);
}

struct ast_Type ast_pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_type_get_copy(a, ref);
}
void ast_pipeline_arena_type_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Type t) {
  pipeline_arena_type_set_copy(a, ref, t);
}
struct ast_Expr ast_pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_expr_get_copy(a, ref);
}
void ast_pipeline_arena_expr_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e) {
  pipeline_arena_expr_set_copy(a, ref, e);
}
void ast_pipeline_arena_expr_write_var(struct ast_ASTArena *a, int32_t ref, uint8_t *name, int32_t name_len) {
  pipeline_arena_expr_write_var(a, ref, name, name_len);
}
void ast_pipeline_arena_expr_write_binop(struct ast_ASTArena *a, int32_t ref, int32_t kind_ord, int32_t left_ref,
                                         int32_t right_ref) {
  pipeline_arena_expr_write_binop(a, ref, kind_ord, left_ref, right_ref);
}
struct ast_Block ast_pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_block_get_copy(a, ref);
}
void ast_pipeline_arena_block_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Block b) {
  pipeline_arena_block_set_copy(a, ref, b);
}
struct ast_Func ast_pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_func_get_copy(a, ref);
}
void ast_pipeline_arena_func_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Func f) {
  pipeline_arena_func_set_copy(a, ref, f);
}

int32_t codegen_pipeline_module_func_param_type_ref_at(struct ast_Module *m, int32_t func_index,
                                                       int32_t param_index) {
  return pipeline_module_func_param_type_ref_at(m, func_index, param_index);
}

/** ast.su / typeck / codegen / backend / parser 经 import 前缀调用的 Expr 侧车池符号转发。 */
int32_t ast_pipeline_expr_append_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref) {
  return pipeline_expr_append_call_arg(a, expr_ref, arg_ref);
}
void ast_pipeline_expr_on_call_created(struct ast_ASTArena *a, int32_t expr_ref) {
  pipeline_expr_on_call_created(a, expr_ref);
}
int32_t ast_pipeline_expr_prepare_call_arg_slot(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_prepare_call_arg_slot(a, expr_ref);
}
int32_t ast_pipeline_expr_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  return pipeline_expr_call_arg_ref(a, expr_ref, idx);
}
int32_t ast_pipeline_expr_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_call_num_args_at(a, expr_ref);
}
int32_t ast_pipeline_expr_append_method_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref) {
  return pipeline_expr_append_method_call_arg(a, expr_ref, arg_ref);
}
int32_t ast_pipeline_expr_method_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  return pipeline_expr_method_call_arg_ref(a, expr_ref, idx);
}
int32_t ast_pipeline_expr_append_match_arm(struct ast_ASTArena *a, int32_t expr_ref, int32_t result_ref,
                                           int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant,
                                           int32_t variant_index) {
  return pipeline_expr_append_match_arm(a, expr_ref, result_ref, is_wildcard, lit_val, is_enum_variant,
                                        variant_index);
}
int32_t ast_pipeline_expr_match_num_arms_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_match_num_arms_at(a, expr_ref);
}
int32_t ast_pipeline_expr_match_arm_result_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_result_ref(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_is_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_is_wildcard(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_lit_val(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_is_enum_variant(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_variant_index(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_variant_index(a, expr_ref, i);
}
void ast_pipeline_expr_match_arm_set_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v) {
  pipeline_expr_match_arm_set_wildcard(a, expr_ref, i, v);
}
void ast_pipeline_expr_match_arm_set_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v) {
  pipeline_expr_match_arm_set_lit_val(a, expr_ref, i, v);
}
void ast_pipeline_expr_match_arm_set_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i,
                                                  int32_t is_var, int32_t variant_index) {
  pipeline_expr_match_arm_set_enum_variant(a, expr_ref, i, is_var, variant_index);
}
int32_t ast_pipeline_expr_append_struct_lit_field(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *name_bytes,
                                                  int32_t name_len, int32_t init_ref) {
  return pipeline_expr_append_struct_lit_field(a, expr_ref, name_bytes, name_len, init_ref);
}
int32_t ast_pipeline_expr_append_array_lit_elem(struct ast_ASTArena *a, int32_t expr_ref, int32_t elem_ref) {
  return pipeline_expr_append_array_lit_elem(a, expr_ref, elem_ref);
}
int32_t ast_pipeline_expr_array_lit_elem_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  return pipeline_expr_array_lit_elem_ref(a, expr_ref, idx);
}
int32_t ast_pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_array_lit_num_elems_at(a, expr_ref);
}
int32_t ast_pipeline_expr_float_bits_lo_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_float_bits_lo_at(a, expr_ref);
}
int32_t ast_pipeline_expr_float_bits_hi_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_float_bits_hi_at(a, expr_ref);
}
int32_t ast_pipeline_expr_call_callee_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_call_callee_ref_at(a, expr_ref);
}
int32_t ast_pipeline_expr_as_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_as_operand_ref_at(a, expr_ref);
}
int32_t ast_pipeline_expr_enum_variant_tag_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_enum_variant_tag_at(a, expr_ref);
}
int32_t ast_pipeline_expr_method_call_base_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_method_call_base_ref_at(a, expr_ref);
}
int32_t ast_pipeline_expr_method_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_method_call_num_args_at(a, expr_ref);
}
int32_t ast_pipeline_expr_method_call_name_len(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_method_call_name_len(a, expr_ref);
}
void ast_pipeline_expr_method_call_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64) {
  pipeline_expr_method_call_name_into(a, expr_ref, out64);
}
int32_t ast_pipeline_expr_if_cond_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_if_cond_ref_at(a, expr_ref);
}
int32_t ast_pipeline_expr_if_then_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_if_then_ref_at(a, expr_ref);
}
int32_t ast_pipeline_expr_if_else_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_if_else_ref_at(a, expr_ref);
}
int32_t ast_pipeline_expr_block_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_block_ref_at(a, expr_ref);
}
int32_t ast_pipeline_expr_match_matched_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_match_matched_ref_at(a, expr_ref);
}
int32_t ast_pipeline_expr_const_folded_valid_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_const_folded_valid_at(a, expr_ref);
}
int32_t ast_pipeline_expr_const_folded_val_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_const_folded_val_at(a, expr_ref);
}
int32_t ast_pipeline_expr_index_base_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_index_base_ref(a, expr_ref);
}
int32_t ast_pipeline_expr_index_index_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_index_index_ref(a, expr_ref);
}
int32_t ast_pipeline_expr_field_access_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_field_access_is_enum_variant(a, expr_ref);
}
int32_t ast_pipeline_expr_field_access_offset(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_field_access_offset(a, expr_ref);
}
int32_t ast_pipeline_expr_field_access_layout_offset(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref) {
  return pipeline_expr_field_access_layout_offset(a, m, expr_ref);
}

int32_t ast_pipeline_expr_field_access_load_byte_sz(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref) {
  return pipeline_expr_field_access_load_byte_sz(a, m, expr_ref);
}
int32_t ast_pipeline_module_import_append_select_name(struct ast_Module *m, int32_t idx, uint8_t *bytes,
                                                      int32_t len) {
  return pipeline_module_import_append_select_name(m, idx, bytes, len);
}

/** backend import codegen 时 struct_lit glue 带 codegen_ 前缀。 */
int32_t codegen_pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_kind_ord_at(a, expr_ref);
}
int32_t codegen_pipeline_expr_struct_lit_num_fields(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_struct_lit_num_fields(a, expr_ref);
}
int32_t codegen_pipeline_expr_struct_lit_init_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t j) {
  return pipeline_expr_struct_lit_init_ref(a, expr_ref, j);
}
int32_t backend_pipeline_expr_struct_lit_num_fields(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_struct_lit_num_fields(a, expr_ref);
}
int32_t backend_pipeline_expr_struct_lit_init_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t j) {
  return pipeline_expr_struct_lit_init_ref(a, expr_ref, j);
}

/** typeck.su validate 入口：C 栈上 out 参数，避免 .su &local / 单槽 scratch 在递归 metrics 下 tearing 或 segfault。 */
extern int32_t typeck_typeck_struct_layout_metrics(struct ast_Module *module, struct ast_ASTArena *arena,
    int32_t li, int32_t depth, int32_t check_pad, int32_t *out_sz, int32_t *out_al);

int32_t typeck_validate_struct_layouts_zero_padding_glue(struct ast_Module *module, struct ast_ASTArena *arena) {
  int32_t li;
  int32_t nsl;
  if (!module || !arena)
    return -1;
  nsl = pipeline_module_num_struct_layouts_at(module);
  for (li = 0; li < nsl; li++) {
    int32_t dz = 0;
    int32_t da = 1;
    if (typeck_typeck_struct_layout_metrics(module, arena, li, 0, 1, &dz, &da) != 0)
      return -1;
  }
  return 0;
}

/** TYPE_NAMED 且命中 struct_layout 时算 size；C 栈 out 参数，.su check_block 勿 &local。 */
int32_t typeck_su_type_size_from_layout_glue(struct ast_Module *module, struct ast_ASTArena *arena, int32_t li,
    int32_t depth) {
  int32_t z2 = 0;
  int32_t al2 = 1;
  if (li < 0)
    return 0;
  if (typeck_typeck_struct_layout_metrics(module, arena, li, depth, 0, &z2, &al2) != 0)
    return 0;
  return z2;
}
