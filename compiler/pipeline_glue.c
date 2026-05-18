/**
 * pipeline_glue.c — 与 -E 产出的 pipeline_gen.c 同属一个翻译单元的 C 胶水代码。
 *
 * 用法：pipeline_gen.c 末尾有 #include "pipeline_glue.c"（由 runtime.c -E 或 build_patch 追加），
 * 编译 pipeline_gen.c 时由 cc 在同一 TU 内包含本文件，故可直接使用上方已定义的 ast_* / codegen_* 等类型。
 * 不单独编译；无补丁、无 sed，所有逻辑在此源文件内从根源提供。
 *
 * parser.su 聚合 -o 可执行时，runtime 在含入前 #define SHU_PARSER_EXE_PIPELINE_GLUE：省略依赖
 * platform_elf_ElfCodegenCtx 完整定义与 codegen.o 转发符号的片段，避免单文件 TU 编译失败。
 */

/* struct shulang_slice_uint8_t 已由 -E 产出的 pipeline_gen.c 上方定义，不在此重复。 */
#include <stddef.h>
#include <string.h>

/** 从 (data, len) 构造 slice，供 parser.su 内 parse_into_buf 调 parse_one_function_impl 时使用。 */
struct shulang_slice_uint8_t parser_slice_from_buf(uint8_t *data, int32_t len) {
  struct shulang_slice_uint8_t s;
  s.data = data;
  s.length = (size_t)(len >= 0 ? len : 0);
  return s;
}

/**
 * lexer.su 内的 extern：Codegen 会带 lexer_ 模块前缀，否则会链接到不存在的 lexer_parser_slice_from_buf。
 * 与 parser_slice_from_buf 等价，仅别名。
 */
struct shulang_slice_uint8_t lexer_parser_slice_from_buf(uint8_t *data, int32_t len) {
  return parser_slice_from_buf(data, len);
}

/** 供 pipeline.su run_su_pipeline_impl 使用：与 parser_slice_from_buf 相同，避免 -E 对 parser_* 符号双重前缀。 */
struct shulang_slice_uint8_t pipeline_source_slice(uint8_t *data, int32_t len) {
  return parser_slice_from_buf(data, len);
}

/**
 * parse_into_init：清零 Module 顶层计数（与 pipeline_gen.c 中 `(module)->num_funcs = 0` 等一致）。
 * 多 import 合并 typeck 时，对 *Module 字段逐条 SU 赋值可能 FIELD_ACCESS 左侧类型暂为 ?，报 expected ?, found i32。
 */
void pipeline_module_reset_parse_counters(struct ast_Module *m) {
  if (!m)
    return;
  m->num_funcs = 0;
  m->main_func_index = -1;
  m->num_imports = 0;
  m->num_top_level_lets = 0;
  m->num_struct_layouts = 0;
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
  if (n > 256) n = 256;
  for (i = 0; i < n; i++) {
    int len = (int)mod->funcs[i].name_len;
    fprintf(stderr, "[DEBUG] module func[%d] name_len=%d name=%.*s\n", i, len, len > 0 && len <= 64 ? len : 0, mod->funcs[i].name);
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
  (void)a;
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

/** 诊断：解析后打印 main 对应 body block 的 num_stmt_order（C 侧调用）；日常构建保留实现不调用，排查时在 runtime.c 恢复调用。 */
void driver_diagnostic_entry_block_after_parse(void *mod, void *arena) {
  struct ast_Module *m = (struct ast_Module *)mod;
  struct ast_ASTArena *a = (struct ast_ASTArena *)arena;
  if (!m || !a || m->main_func_index < 0 || m->main_func_index >= m->num_funcs)
    return;
  int32_t br = m->funcs[m->main_func_index].body_ref;
  if (br <= 0 || br > a->num_blocks)
    return;
  (void)br;
  (void)a;
  /* struct ast_Block b = ast_ast_arena_block_get(a, br);
  fprintf(stderr, "[diag] after_parse body_ref=%d num_blocks=%d block.num_stmt_order=%d\n",
          (int)br, (int)a->num_blocks, (int)b.num_stmt_order); */
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
  int32_t ix;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return ast_ExprKind_EXPR_LIT;
  ix = expr_ref - 1;
  if (ix < 0 || ix >= 8192)
    return ast_ExprKind_EXPR_LIT;
  return a->exprs[ix].kind;
}

/**
 * parser.su expr_ref_is_assign_lvalue：与 shu-c 生成码对 struct 直读一致。
 * SU 中对「let e: Expr = ast_arena_expr_get(...)」再写 e.kind == … 会在 .su typeck 路径失败（见 ast.su 注释）；由 C 从池读 kind / is_enum_variant。
 * 返回 1 表示可作为赋值左值，0 表示否。
 */
int32_t pipeline_expr_ref_is_assign_lvalue(struct ast_ASTArena *a, int32_t expr_ref) {
  enum ast_ExprKind kd;
  int32_t ix;
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
  ix = expr_ref - 1;
  if (ix < 0 || ix >= 8192) {
    return 0;
  }
  return a->exprs[ix].field_access_is_enum_variant == 0 ? 1 : 0;
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
  int32_t idx;
  struct ast_Type *t;
  if (!arena || !out64 || ref <= 0 || ref > arena->num_types)
    return 0;
  idx = ref - 1;
  if (idx < 0 || idx >= 512)
    return 0;
  t = &arena->types[idx];
  memcpy(out64, t->name, sizeof(t->name));
  return t->name_len;
}

/**
 * 读取 arena.types[ref-1].kind 作为与 TypeKind ordinal 对齐的枚举序数。
 * ref 无效时返回 -1。
 */
int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *arena, int32_t ref) {
  int32_t idx;
  if (!arena || ref <= 0 || ref > arena->num_types)
    return -1;
  idx = ref - 1;
  if (idx < 0 || idx >= 512)
    return -1;
  return (int32_t)arena->types[idx].kind;
}

/**
 * 读取 arena.types[ref-1].elem_type_ref（指针指向元素类型、向量元素类型等）。
 * ref 无效时返回 0。
 */
int32_t pipeline_type_elem_ref_at(struct ast_ASTArena *arena, int32_t ref) {
  int32_t idx;
  if (!arena || ref <= 0 || ref > arena->num_types)
    return 0;
  idx = ref - 1;
  if (idx < 0 || idx >= 512)
    return 0;
  return arena->types[idx].elem_type_ref;
}

/**
 * 读取 arena.types[ref-1].array_size（数组长度、向量 lane 数等）。
 * ref 无效时返回 0。
 */
int32_t pipeline_type_array_size_at(struct ast_ASTArena *arena, int32_t ref) {
  int32_t idx;
  if (!arena || ref <= 0 || ref > arena->num_types)
    return 0;
  idx = ref - 1;
  if (idx < 0 || idx >= 512)
    return 0;
  return arena->types[idx].array_size;
}

/**
 * 按函数下标与形参变量名查找 Param.type_ref（有效时非 0）。
 * typeck.su 不得在 SU/asm 中直接读 module.funcs[fi].params[pi]：Func 与嵌套 Param 体积大，
 * 部分后端对嵌套数组下标的寻址或按值路径不完整，会导致形参类型错、*T 上 FIELD_ACCESS 的 LHS 落成未解析类型。
 */
int32_t pipeline_module_func_param_type_ref_for_name(struct ast_Module *m, int32_t func_index,
                                                     uint8_t *var_name, int32_t var_name_len) {
  struct ast_Func *f;
  int32_t n, i;
  if (!m || !var_name || func_index < 0 || func_index >= 256)
    return 0;
  if (func_index >= (int32_t)m->num_funcs)
    return 0;
  if (var_name_len <= 0 || var_name_len > 31)
    return 0;
  f = &m->funcs[func_index];
  n = (int32_t)f->num_params;
  if (n < 0)
    return 0;
  if (n > 16)
    n = 16;
  for (i = 0; i < n; i++) {
    struct ast_Param *p = &f->params[i];
    int32_t plen = (int32_t)p->name_len;
    int32_t tr = (int32_t)p->type_ref;
    if (tr == 0)
      continue;
    if (plen != var_name_len)
      continue;
    if (plen <= 0 || plen > 31)
      continue;
    if (memcmp(p->name, var_name, (size_t)var_name_len) != 0)
      continue;
    return tr;
  }
  return 0;
}

/**
 * 将单个形参写入 module->funcs[func_index].params[param_index]（memcpy 名字 + 写 name_len/type_ref）。
 * parser.su 中禁止 let p = module.funcs[fi].params[pi] 再写回：Param 在部分 asm 寻址下按值拷贝会丢 type_ref，导致形参 *T 上 FIELD_ACCESS 无法 typeck。
 */
void pipeline_module_func_param_write(struct ast_Module *m, int32_t func_index, int32_t param_index,
                                      uint8_t *name_bytes, int32_t name_len, int32_t type_ref) {
  struct ast_Param *p;
  if (!m || !name_bytes || func_index < 0 || func_index >= 256 || param_index < 0 || param_index >= 16)
    return;
  if (name_len < 0 || name_len > 31)
    return;
  p = &m->funcs[func_index].params[param_index];
  p->name_len = name_len;
  p->type_ref = type_ref;
  memset(p->name, 0, sizeof(p->name));
  if (name_len > 0)
    memcpy(p->name, name_bytes, (size_t)name_len);
}

/**
 * 同上，目标为 arena 内 func 池：arena->funcs[func_ref - 1].params[param_index]，供 parse_into_buf(expr-only) 路径。
 */
void pipeline_arena_func_param_write(struct ast_ASTArena *arena, int32_t func_ref, int32_t param_index,
                                     uint8_t *name_bytes, int32_t name_len, int32_t type_ref) {
  struct ast_Param *p;
  int32_t idx;
  if (!arena || !name_bytes || func_ref <= 0 || func_ref > 256 || param_index < 0 || param_index >= 16)
    return;
  if (name_len < 0 || name_len > 31)
    return;
  idx = func_ref - 1;
  if (idx < 0 || idx >= 256)
    return;
  p = &arena->funcs[idx].params[param_index];
  p->name_len = name_len;
  p->type_ref = type_ref;
  memset(p->name, 0, sizeof(p->name));
  if (name_len > 0)
    memcpy(p->name, name_bytes, (size_t)name_len);
}

/** struct_layout 槽有效下标：返回名称字节长度（与 StructLayout.name_len 一致）。 */
int32_t pipeline_module_struct_layout_name_len(struct ast_Module *m, int32_t idx) {
  int32_t len;
  if (!m || idx < 0 || idx >= 32)
    return 0;
  len = (int32_t)m->struct_layouts[idx].name_len;
  if (len <= 0 || len > 63)
    return 0;
  return len;
}

/** 拷贝 Name 字段到 out64（固定 64 字节缓冲区）。idx 无效时不写入。 */
void pipeline_module_struct_layout_name_into(struct ast_Module *m, int32_t idx, uint8_t *out64) {
  if (!m || idx < 0 || idx >= 32 || !out64)
    return;
  memcpy(out64, m->struct_layouts[idx].name, sizeof(m->struct_layouts[idx].name));
}

/** 字段个数（与 StructLayout.num_fields 一致）。 */
int32_t pipeline_module_struct_layout_num_fields(struct ast_Module *m, int32_t idx) {
  int32_t nf;
  if (!m || idx < 0 || idx >= 32)
    return 0;
  nf = (int32_t)m->struct_layouts[idx].num_fields;
  if (nf < 0 || nf > 64)
    return 0;
  return nf;
}

/** 第 j 个字段的类型池 ref；无效返回 0。 */
int32_t pipeline_module_struct_layout_field_type_ref(struct ast_Module *m, int32_t li, int32_t j) {
  if (!m || li < 0 || li >= 32 || j < 0 || j >= 64)
    return 0;
  return m->struct_layouts[li].field_type_refs[j];
}

/** 字段名长度；无效返回 0。 */
int32_t pipeline_module_struct_layout_field_name_len(struct ast_Module *m, int32_t li, int32_t j) {
  int32_t fl;
  if (!m || li < 0 || li >= 32 || j < 0 || j >= 64)
    return 0;
  fl = (int32_t)m->struct_layouts[li].field_lens[j];
  if (fl <= 0 || fl > 63)
    return 0;
  return fl;
}

/** 拷贝字段名到 out64。 */
void pipeline_module_struct_layout_field_name_into(struct ast_Module *m, int32_t li, int32_t j, uint8_t *out64) {
  if (!m || li < 0 || li >= 32 || j < 0 || j >= 64 || !out64)
    return;
  memcpy(out64, m->struct_layouts[li].field_names[j], sizeof(m->struct_layouts[li].field_names[j]));
}

/**
 * 将 struct_layout 整槽清零；parse_struct_record_layout_into 在向 Module 填入布局前必须先调用，
 * 避免残留垃圾；亦为后续 set_name/set_field 提供干净基底。
 */
void pipeline_module_struct_layout_reset_slot(struct ast_Module *m, int32_t idx) {
  if (!m || idx < 0 || idx >= 32)
    return;
  memset(&m->struct_layouts[idx], 0, sizeof(m->struct_layouts[idx]));
}

/** memcpy + name_len：避免 SU 对大嵌套 struct_layout.name 逐字节赋值在 AArch64 等后端不落盘。 */
void pipeline_module_struct_layout_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  struct ast_StructLayout *sl;
  if (!m || idx < 0 || idx >= 32 || !bytes)
    return;
  if (len <= 0 || len > 63)
    return;
  sl = &m->struct_layouts[idx];
  sl->name_len = len;
  memset(sl->name, 0, sizeof(sl->name));
  memcpy(sl->name, bytes, (size_t)len);
}

/** memcpy 字段名并写 lens/type_refs/offsets；与 set_name 同类 ABI 补丁。 */
void pipeline_module_struct_layout_set_field(struct ast_Module *m, int32_t li, int32_t j, uint8_t *fname_bytes,
                                              int32_t fname_len, int32_t ftype_ref, int32_t foff) {
  struct ast_StructLayout *sl;
  if (!m || li < 0 || li >= 32 || j < 0 || j >= 64)
    return;
  if (fname_len <= 0 || fname_len > 63)
    return;
  sl = &m->struct_layouts[li];
  sl->field_lens[j] = fname_len;
  sl->field_type_refs[j] = ftype_ref;
  sl->field_offsets[j] = foff;
  memset(sl->field_names[j], 0, sizeof(sl->field_names[j]));
  if (fname_bytes)
    memcpy(sl->field_names[j], fname_bytes, (size_t)fname_len);
}

