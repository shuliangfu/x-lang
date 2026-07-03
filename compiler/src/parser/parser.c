/**
 * parser.c — 语法分析器实现
 *
 * 文件职责：递归下降解析 Token 流，支持顶层 import path; 与可选的 function main() -> i32 { 整数字面量 }，构建 ASTModule（含 import_paths、main_func）。
 * 所属模块：编译器前端 parser，compiler/src/parser/；实现 parser.h 声明的 parse。
 * 与其它文件的关系：依赖 lexer.h、include/ast.h、include/token.h；被 main 调用；产出的 AST 由 typeck、codegen 消费。
 * 重要约定：与 compiler/docs/语法子集-阶段1与2.md 及阶段 5 import 语法一致；所有动态分配由 ast_module_free 统一释放；语法错误时已向 stderr 打印 "parse error at line:col: msg"。
 */

#include "parser/parser.h"
#include "lexer/lexer.h"
#include "lsp/lsp_diag.h"
#include "diag.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * 模块级 ASTFunc* 数组按需扩容；cap 为当前容量（入参出参），need 为所需下标+1。
 */
static ASTFunc **parser_grow_func_ptrs(ASTFunc **list, int *cap, int need) {
    if (need <= *cap)
        return list;
    int nc = *cap > 0 ? *cap : AST_MODULE_FUNCS_INIT;
    while (nc < need)
        nc *= 2;
    ASTFunc **p = (ASTFunc **)realloc(list, (size_t)nc * sizeof(ASTFunc *));
    if (!p)
        return NULL;
    *cap = nc;
    return p;
}

/**
 * 形参数组按需扩容；cap 为当前容量（入参出参），need 为所需下标+1。
 * 返回新指针，失败返回 NULL。
 */
static ASTParam *parser_grow_params(ASTParam *params, int *cap, int need) {
    if (need <= *cap)
        return params;
    int nc = *cap > 0 ? *cap : AST_FUNC_PARAMS_INIT;
    while (nc < need)
        nc *= 2;
    ASTParam *p = (ASTParam *)realloc(params, (size_t)nc * sizeof(ASTParam));
    if (!p)
        return NULL;
    for (int i = *cap; i < nc; i++)
        (void)memset(&p[i], 0, sizeof(ASTParam));
    *cap = nc;
    return p;
}

/**
 * 调用实参数组按需扩容；cap 为当前容量，need 为所需下标+1。
 */
static ASTExpr **parser_grow_call_args(ASTExpr **args, int *cap, int need) {
    if (need <= *cap)
        return args;
    int nc = *cap > 0 ? *cap : AST_FUNC_PARAMS_INIT;
    while (nc < need)
        nc *= 2;
    ASTExpr **a = (ASTExpr **)realloc(args, (size_t)nc * sizeof(ASTExpr *));
    if (!a)
        return NULL;
    *cap = nc;
    return a;
}

/** 解析器内部状态：Lexer 引用 + 当前 lookahead Token + 下一/再下一 Token（用于 label: 与 < 歧义消解） */
typedef struct {
    Lexer *lex;
    Token cur;
    int cur_loaded;   /**< 1 表示 cur 已加载有效 Token */
    Token next;       /**< 下一 Token，用于 peek_next */
    int next_loaded;
    Token next_next;  /**< 再下一 Token，用于 < 后 IDENT 时区分比较与泛型 */
    int next_next_loaded;
} Parser;

static int parser_recovery_enabled(void);
static int parser_is_stmt_sync_token(Parser *p);
static void parser_recover_statement_boundary(Parser *p);
static void parser_recover_struct_field_boundary(Parser *p);
static void parser_recover_enum_variant_boundary(Parser *p);
static void parser_recover_trait_method_boundary(Parser *p);
static void parser_recover_impl_method_boundary(Parser *p);
static int parser_stmt_needs_semicolon(Parser *p);
static int parser_top_level_recovery_enabled(void);
static int parser_is_top_level_sync_token(Parser *p);
static void parser_recover_top_level_boundary(Parser *p);

/**
 * 推进到下一个 Token：cur 变为 next（或新取词），next 置为未加载。
 * 参数：p 解析器状态。返回值：无。副作用：更新 p->cur、p->next_loaded。
 */
static void advance(Parser *p) {
    if (p->next_loaded) {
        p->cur = p->next;
        p->next_loaded = p->next_next_loaded;
        if (p->next_next_loaded) {
            p->next = p->next_next;
            p->next_next_loaded = 0;
        } else {
            p->next_loaded = 0;
        }
    } else {
        lexer_next(p->lex, &p->cur);
    }
    p->cur_loaded = 1;
}

/**
 * 返回当前 lookahead Token 指针；若尚未加载则先 advance 一次。
 * 参数：p 解析器状态。返回值：指向 p->cur 的只读指针。无额外副作用。
 */
static const Token *peek(Parser *p) {
    if (!p->cur_loaded) advance(p);
    return &p->cur;
}

/**
 * 返回下一 Token 指针（用于判断 ident 后是否为 : 以区分 label 与表达式）；若未加载则取词一次。
 * 参数：p 解析器状态。返回值：指向 p->next 的只读指针。副作用：可能调用 lexer_next 填充 p->next。
 */
static const Token *peek_next(Parser *p) {
    if (!p->next_loaded) {
        lexer_next(p->lex, &p->next);
        p->next_loaded = 1;
    }
    return &p->next;
}

/** 返回再下一 Token（用于 < 后 IDENT 时区分 i < len 与 f<T>）；可能消耗 lexer 一次。 */
static const Token *peek_next_next(Parser *p) {
    (void)peek_next(p);
    if (!p->next_next_loaded) {
        lexer_next(p->lex, &p->next_next);
        p->next_next_loaded = 1;
    }
    return &p->next_next;
}

/**
 * 判断当前 Token 是否为 IDENT 且内容等于给定字符串（用于 allow/padding 等）。
 * 参数：p 解析器；str 期望字符串；len 其长度。返回值：1 表示匹配，0 否则。
 */
static int is_ident_str(Parser *p, const char *str, size_t len) {
    const Token *t = peek(p);
    return t->kind == TOKEN_IDENT && (size_t)t->ident_len == len
           && memcmp(t->value.ident, str, len) == 0;
}

/**
 * 结构体字段名 / 字面量字段名：允许 soa、packed 等关键字在 { } 内作字段名
 * （与 `struct Name soa { }` 修饰符区分上下文）。
 * 成功返回 strdup 名并消费 token；失败返回 NULL。
 */
static char *parser_struct_field_name_dup(Parser *p) {
    const Token *t = peek(p);
    const char *lit = NULL;
    size_t lit_len = 0;
    if (t->kind == TOKEN_IDENT && t->value.ident && t->ident_len > 0) {
        char *n = strndup(t->value.ident, (size_t)t->ident_len);
        if (n)
            advance(p);
        return n;
    }
    if (t->kind == TOKEN_SOA) {
        lit = "soa";
        lit_len = 3;
    } else if (t->kind == TOKEN_PACKED) {
        lit = "packed";
        lit_len = 6;
    }
    if (lit) {
        char *n = strndup(lit, lit_len);
        if (n)
            advance(p);
        return n;
    }
    return NULL;
}

/**
 * 向 stderr 输出 "parse error at line:col: msg" 并返回 -1；用于统一错误处理。
 * LSP 模式（lsp_diag_enabled）下改为写入诊断收集器，不写 stderr。
 */
static int fail(Parser *p, const char *msg) {
    const Token *t = peek(p);
    if (lsp_diag_enabled) {
        lsp_diag_add_code(t->line, t->col, 1, "P001", msg);
        return -1;
    }
    diag_report_with_code(NULL, t->line, t->col, "parse error", "P001", msg, msg);
    return -1;
}

static void parser_oom(Parser *p) {
    (void)fail(p, "out of memory");
}

static void parser_oom_at(int line, int col) {
    if (lsp_diag_enabled) {
        lsp_diag_add_code(line, col, 1, "P001", "out of memory");
        return;
    }
    diag_report_with_code(NULL, line, col, "parse error", "P001", "out of memory", "out of memory");
}

static void parser_oom_global(void) {
    parser_oom_at(0, 0);
}

/**
 * 将当前 Token 的 line/col 写入表达式节点，供 typeck 面包屑错误使用。
 */
static void set_expr_loc(ASTExpr *e, Parser *p) {
    const Token *t = peek(p);
    e->line = t->line;
    e->col = t->col;
}

/** 用指定位置设置表达式位置（用于 if/match 等已消费掉起始 token 的复合表达式） */
static void set_expr_loc_at(ASTExpr *e, int line, int col) {
    e->line = line;
    e->col = col;
}

/**
 * 若当前 token 为分号则消费掉（} 后分号可选，可加可不加）；返回 0。
 * 在每次消费 RBRACE 后调用。
 */
static int fail_if_semicolon_after_brace(Parser *p) {
    if (peek(p)->kind == TOKEN_SEMICOLON) advance(p);
    return 0;
}

/**
 * 判断表达式是否以 } 结尾（结构体字面量、if/match 等），用于 return 分号规则：
 * return expr 以 } 结尾时不需要且不能写分号，否则必须写分号。
 */
static int expr_ends_with_brace(const ASTExpr *e) {
    if (!e) return 0;
    return e->kind == AST_EXPR_STRUCT_LIT || e->kind == AST_EXPR_IF || e->kind == AST_EXPR_MATCH
        || e->kind == AST_EXPR_BLOCK;
}

/**
 * 解析泛型类型参数列表：< T (, U)* >，仅标识符作为类型参数名（阶段 7.1）。
 * 当前 Token 须为 TOKEN_LT；成功后消耗整段包括 >。
 * 参数：p 解析器；out_names 输出参数名数组（strdup，调用方须 free 各元素及数组）；out_count 输出个数。
 * 返回值：0 成功，-1 失败且已 fail。无泛型时（非 <）不消费 token，*out_names=NULL，*out_count=0。
 */
static int parse_generic_param_list(Parser *p, char ***out_names, int *out_count) {
    *out_names = NULL;
    *out_count = 0;
    if (peek(p)->kind != TOKEN_LT) return 0;
    advance(p);
    char **names = (char **)malloc((size_t)AST_MAX_GENERIC_PARAMS * sizeof(char *));
    if (!names) {
        parser_oom(p);
        return -1;
    }
    int n = 0;
    for (;;) {
        if (n >= AST_MAX_GENERIC_PARAMS) {
            for (int i = 0; i < n; i++) free(names[i]);
            free(names);
            fail(p, "too many generic parameters");
            return -1;
        }
        if (peek(p)->kind != TOKEN_IDENT) {
            for (int i = 0; i < n; i++) free(names[i]);
            free(names);
            fail(p, "expected type parameter name in <...>");
            return -1;
        }
        names[n] = strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len);
        if (!names[n]) {
            for (int i = 0; i < n; i++) free(names[i]);
            free(names);
            parser_oom(p);
            return -1;
        }
        advance(p);
        n++;
        if (peek(p)->kind == TOKEN_GT) break;
        if (peek(p)->kind != TOKEN_COMMA) {
            for (int i = 0; i < n; i++) free(names[i]);
            free(names);
            fail(p, "expected ',' or '>' in generic parameter list");
            return -1;
        }
        advance(p);
    }
    advance(p);  /* consume '>' */
    *out_names = names;
    *out_count = n;
    return 0;
}

/** 单 struct 字面量最大字段数（与 parse_one_struct 用到的 MAX_STRUCT_FIELDS 一致；需 >= OneFuncResult 等大块字面量字段数） */
#define MAX_STRUCT_FIELDS 64

/**
 * 将 VAR / 嵌套 FIELD_ACCESS（模块路径）拼成限定前缀，如 process 或 arch.x86_64。
 * 非模块路径表达式（如 struct 实例字段）返回 -1。
 */
static int parser_append_expr_import_path(const ASTExpr *e, char *buf, size_t cap) {
    if (!e || !buf || cap == 0) return -1;
    if (e->kind == AST_EXPR_VAR && e->value.var.name) {
        int n = snprintf(buf, cap, "%s", e->value.var.name);
        return (n > 0 && (size_t)n < cap) ? n : -1;
    }
    if (e->kind == AST_EXPR_FIELD_ACCESS && e->value.field_access.base && e->value.field_access.field_name) {
        char prefix[256];
        int plen = parser_append_expr_import_path(e->value.field_access.base, prefix, sizeof(prefix));
        if (plen < 0) return -1;
        int n = snprintf(buf, cap, "%s.%s", prefix, e->value.field_access.field_name);
        return (n > 0 && (size_t)n < cap) ? n : -1;
    }
    return -1;
}

/** 绑定 import 限定 struct 字面量名：process + SpawnIo → "process.SpawnIo"。 */
static int parser_qual_name_from_expr_field(const ASTExpr *base, const char *field, char *buf, size_t cap) {
    char prefix[256];
    int plen;
    if (!base || !field || !field[0] || !buf || cap == 0) return -1;
    plen = parser_append_expr_import_path(base, prefix, sizeof(prefix));
    if (plen < 0) return -1;
    {
        int n = snprintf(buf, cap, "%s.%s", prefix, field);
        return (n > 0 && (size_t)n < cap) ? n : -1;
    }
}

/* parse_struct_lit_body 内调用 parse_expr；须在前向声明之后定义 */
static ASTExpr *parse_expr(Parser *p);

/**
 * 解析 `{ field: expr, ... }` 并构造 AST_EXPR_STRUCT_LIT。
 * name 可为调用方传入的裸 TypeName / mod.Type 限定名，也可为 NULL（由 typeck 按上下文补齐）。
 * 当前 token 须为 `{`。
 */
static ASTExpr *parse_struct_lit_body(Parser *p, char *name, int ident_line, int ident_col) {
    char **fnames;
    ASTExpr **inits;
    int nf;
    ASTExpr *e;
    if (!p) return NULL;
    if (peek(p)->kind != TOKEN_LBRACE) {
        free(name);
        fail(p, "expected '{' for struct literal");
        return NULL;
    }
    advance(p);
    fnames = (char **)malloc((size_t)MAX_STRUCT_FIELDS * sizeof(char *));
    inits = (ASTExpr **)malloc((size_t)MAX_STRUCT_FIELDS * sizeof(ASTExpr *));
    if (!fnames || !inits) {
        free(name);
        if (fnames) free(fnames);
        if (inits) free(inits);
        parser_oom(p);
        return NULL;
    }
    nf = 0;
    while (peek(p)->kind != TOKEN_RBRACE) {
        if (nf >= MAX_STRUCT_FIELDS) {
            free(name);
            for (int i = 0; i < nf; i++) {
                free((void *)fnames[i]);
                ast_expr_free(inits[i]);
            }
            free(fnames);
            free(inits);
            fail(p, "too many struct literal fields");
            return NULL;
        }
        fnames[nf] = parser_struct_field_name_dup(p);
        if (!fnames[nf]) {
            free(name);
            for (int i = 0; i < nf; i++) {
                free((void *)fnames[i]);
                ast_expr_free(inits[i]);
            }
            free(fnames);
            free(inits);
            fail(p, "expected field name in struct literal");
            return NULL;
        }
        if (peek(p)->kind != TOKEN_COLON) {
            free((void *)fnames[nf]);
            free(name);
            for (int i = 0; i < nf; i++) {
                free((void *)fnames[i]);
                ast_expr_free(inits[i]);
            }
            free(fnames);
            free(inits);
            fail(p, "expected ':' after field name in struct literal");
            return NULL;
        }
        advance(p);
        inits[nf] = parse_expr(p);
        if (!inits[nf]) {
            free((void *)fnames[nf]);
            free(name);
            for (int i = 0; i < nf; i++) {
                free((void *)fnames[i]);
                ast_expr_free(inits[i]);
            }
            free(fnames);
            free(inits);
            return NULL;
        }
        nf++;
        if (peek(p)->kind == TOKEN_COMMA) advance(p);
    }
    if (peek(p)->kind != TOKEN_RBRACE) {
        free(name);
        for (int i = 0; i < nf; i++) {
            free((void *)fnames[i]);
            ast_expr_free(inits[i]);
        }
        free(fnames);
        free(inits);
        fail(p, "expected '}' in struct literal");
        return NULL;
    }
    advance(p);
    /* K6/fix：struct 字面量的 '}' 即结束；不消费其后的 ';'（那是 const/let/return 等调用方的终止符）。
     * 原 fail_if_semicolon_after_brace 会吃掉 '};' 的 ';'，致 const h = {...}; 报 "expected ';' after const"。 */
    e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
    if (!e) {
        free(name);
        for (int i = 0; i < nf; i++) {
            free((void *)fnames[i]);
            ast_expr_free(inits[i]);
        }
        free(fnames);
        free(inits);
        parser_oom(p);
        return NULL;
    }
    set_expr_loc_at(e, ident_line, ident_col);
    e->kind = AST_EXPR_STRUCT_LIT;
    e->value.struct_lit.struct_name = name;
    e->value.struct_lit.field_names = fnames;
    e->value.struct_lit.inits = inits;
    e->value.struct_lit.num_fields = nf;
    return e;
}

static ASTExpr *parse_term(Parser *p);

static ASTExpr *parse_cast(Parser *p);
static ASTExpr *parse_postfix(Parser *p);
static ASTBlock *parse_block(Parser *p, int allow_while, int consume_rbrace);
static void skip_balanced_tokens(Parser *p, TokenKind open, TokenKind close);
static ASTExpr *parse_at_simd_builtin(Parser *p);

/**
 * 构造 EXPR_VAR 标识符节点（供 @shuffle/@select desugar 为 simd_* CALL）。
 */
static ASTExpr *parse_new_var_expr(const char *name, int line, int col) {
  ASTExpr *e;
  if (!name)
    return NULL;
  e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
  if (!e) {
    parser_oom_at(line, col);
    return NULL;
  }
  set_expr_loc_at(e, line, col);
  e->kind = AST_EXPR_VAR;
  e->value.var.name = strdup(name);
  if (!e->value.var.name) {
    free(e);
    parser_oom_at(line, col);
    return NULL;
  }
  return e;
}

/**
 * 解析 @shuffle(v, mask) / @select(mask, a, b) → CALL simd_shuffle/simd_select（SIMD-S4 语法糖）。
 */
static ASTExpr *parse_at_simd_builtin(Parser *p) {
  int line;
  int col;
  const char *callee;
  int need_args;
  ASTExpr **args;
  int num_args;
  int cap;
  ASTExpr *call;
  char *bname;

  if (!peek(p) || peek(p)->kind != TOKEN_AT)
    return NULL;
  line = peek(p)->line;
  col = peek(p)->col;
  advance(p);
  if (peek(p)->kind != TOKEN_IDENT) {
    fail(p, "expected identifier after '@'");
    return NULL;
  }
  bname = peek(p)->ident_len > 0 && peek(p)->value.ident
              ? strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len)
              : NULL;
  advance(p);
  if (!bname) {
    fail(p, "invalid @ builtin name");
    return NULL;
  }
  callee = NULL;
  need_args = 0;
  if (strcmp(bname, "shuffle") == 0) {
    callee = "simd_shuffle";
    need_args = 2;
  } else if (strcmp(bname, "select") == 0) {
    callee = "simd_select";
    need_args = 3;
  } else {
    free(bname);
    fail(p, "unknown @ builtin (expected shuffle or select)");
    return NULL;
  }
  free(bname);
  if (peek(p)->kind != TOKEN_LPAREN) {
    fail(p, "expected '(' after @ builtin");
    return NULL;
  }
  advance(p);
  args = NULL;
  num_args = 0;
  cap = 0;
  if (peek(p)->kind != TOKEN_RPAREN) {
    for (;;) {
      ASTExpr *arg;
      if (num_args >= cap) {
        ASTExpr **n;
        cap = cap == 0 ? 4 : cap * 2;
        n = (ASTExpr **)realloc(args, (size_t)cap * sizeof(ASTExpr *));
        if (!n) {
          for (int i = 0; i < num_args; i++)
            ast_expr_free(args[i]);
          free(args);
          parser_oom(p);
          return NULL;
        }
        args = n;
      }
      arg = parse_expr(p);
      if (!arg) {
        for (int i = 0; i < num_args; i++)
          ast_expr_free(args[i]);
        free(args);
        return NULL;
      }
      args[num_args++] = arg;
      if (peek(p)->kind == TOKEN_COMMA) {
        advance(p);
        continue;
      }
      if (peek(p)->kind == TOKEN_RPAREN)
        break;
      for (int i = 0; i < num_args; i++)
        ast_expr_free(args[i]);
      free(args);
      fail(p, "expected ',' or ')' in @ builtin call");
      return NULL;
    }
  }
  if (peek(p)->kind != TOKEN_RPAREN) {
    for (int i = 0; i < num_args; i++)
      ast_expr_free(args[i]);
    free(args);
    fail(p, "expected ')' after @ builtin args");
    return NULL;
  }
  advance(p);
  if (num_args != need_args) {
    for (int i = 0; i < num_args; i++)
      ast_expr_free(args[i]);
    free(args);
    fail(p, "@ builtin argument count mismatch");
    return NULL;
  }
  call = (ASTExpr *)calloc(1, sizeof(ASTExpr));
  if (!call) {
    for (int i = 0; i < num_args; i++)
      ast_expr_free(args[i]);
    free(args);
    parser_oom(p);
    return NULL;
  }
  set_expr_loc_at(call, line, col);
  call->kind = AST_EXPR_CALL;
  call->value.call.callee = parse_new_var_expr(callee, line, col);
  call->value.call.args = args;
  call->value.call.num_args = num_args;
  if (!call->value.call.callee) {
    ast_expr_free(call);
    return NULL;
  }
  return call;
}

/**
 * M-3：解析切片类型可选域标签 []T<label>；当前 Token 须为 '>' 之后已消费 '<' 与 label。
 * 成功时写入 ty->region_label（strdup），失败时已 fail。
 */
static void parse_slice_region_label(Parser *p, ASTType *ty) {
    if (!p || !ty || ty->kind != AST_TYPE_SLICE)
        return;
    if (peek(p)->kind != TOKEN_LT)
        return;
    advance(p);
    const Token *lab = peek(p);
    if (!lab || lab->kind != TOKEN_IDENT || lab->ident_len <= 0) {
        fail(p, "expected region label after '<' in slice type []T<label>");
        return;
    }
    ty->region_label = (const char *)malloc((size_t)lab->ident_len + 1u);
    if (!ty->region_label) {
        parser_oom(p);
        fail(p, "out of memory");
        return;
    }
    memcpy((void *)ty->region_label, lab->value.ident, (size_t)lab->ident_len);
    ((char *)ty->region_label)[lab->ident_len] = '\0';
    advance(p);
    if (peek(p)->kind != TOKEN_GT) {
        fail(p, "expected '>' after region label in slice type []T<label>");
        return;
    }
    advance(p);
}

/** LANG-009：泛型 struct 具体实例名 mangling（定义见 parse_type_name 之后）。 */
static int parser_append_type_inst_mangle(Parser *p, char *buf, size_t cap);

/**
 * 解析类型名称（内建/标识符类型名、裸指针 *T；* 后递归解析元素类型）。
 * 参数：p 解析器状态，当前 Token 须为类型起始（* 或内建关键字或标识符）。返回值：成功返回新分配的 ASTType*，失败返回 NULL 且已报错。
 */
static ASTType *parse_type_name(Parser *p) {
    const Token *t = peek(p);
    if (!t) return NULL;
    /* 裸指针 *T / *volatile T（K2：volatile 指针，MMIO）：文档 §5.1 */
    if (t->kind == TOKEN_STAR) {
        int is_vol = 0;
        advance(p);  /* * */
        if (peek(p)->kind == TOKEN_IDENT && is_ident_str(p, "volatile", 8)) {
            advance(p);  /* volatile */
            is_vol = 1;
        }
        ASTType *inner = parse_type_name(p);
        if (!inner) return NULL;
        ASTType *ty = (ASTType *)calloc(1, sizeof(ASTType));
        if (!ty) {
            ast_type_free(inner);
            parser_oom(p);
            return NULL;
        }
        ty->kind = AST_TYPE_PTR;
        ty->name = NULL;
        ty->elem_type = inner;
        ty->array_size = 0;
        ty->region_label = NULL;
        ty->is_volatile = is_vol;
        return ty;
    }
    /* 切片 []T 或 固定长数组 [N]T：文档 §6.2、§6.3 */
    if (t->kind == TOKEN_LBRACKET) {
        advance(p);
        t = peek(p);
        if (t && t->kind == TOKEN_RBRACKET) {
            /* []T 切片类型 */
            advance(p);
            ASTType *inner = parse_type_name(p);
            if (!inner) return NULL;
            ASTType *ty = (ASTType *)calloc(1, sizeof(ASTType));
            if (!ty) {
                ast_type_free(inner);
                parser_oom(p);
                return NULL;
            }
            ty->kind = AST_TYPE_SLICE;
            ty->name = NULL;
            ty->elem_type = inner;
            ty->array_size = 0;
            ty->region_label = NULL;
            parse_slice_region_label(p, ty);
            return ty;
        }
        if (!t || t->kind != TOKEN_INT) {
            fail(p, "expected array size (integer literal) in [N]T or ] for []T");
            return NULL;
        }
        int size = t->value.int_val;
        if (size <= 0) {
            fail(p, "array size must be positive");
            return NULL;
        }
        advance(p);
        if (peek(p)->kind != TOKEN_RBRACKET) {
            fail(p, "expected ']' after array size in [N]T");
            return NULL;
        }
        advance(p);
        ASTType *inner = parse_type_name(p);
        if (!inner) return NULL;
        ASTType *ty = (ASTType *)calloc(1, sizeof(ASTType));
        if (!ty) {
            ast_type_free(inner);
            parser_oom(p);
            return NULL;
        }
        ty->kind = AST_TYPE_ARRAY;
        ty->name = NULL;
        ty->elem_type = inner;
        ty->array_size = size;
        return ty;
    }
    ASTType *ty = (ASTType *)calloc(1, sizeof(ASTType));
    if (!ty) {
        parser_oom(p);
        return NULL;
    }
    ty->name = NULL;
    ty->elem_type = NULL;
    ty->array_size = 0;
    switch (t->kind) {
        case TOKEN_I32:
            ty->kind = AST_TYPE_I32;
            advance(p);
            return ty;
        case TOKEN_BOOL:
            ty->kind = AST_TYPE_BOOL;
            advance(p);
            return ty;
        case TOKEN_U8:
            ty->kind = AST_TYPE_U8;
            advance(p);
            return ty;
        case TOKEN_U32:
            ty->kind = AST_TYPE_U32;
            advance(p);
            return ty;
        case TOKEN_U64:
            ty->kind = AST_TYPE_U64;
            advance(p);
            return ty;
        case TOKEN_I64:
            ty->kind = AST_TYPE_I64;
            advance(p);
            return ty;
        case TOKEN_USIZE:
            ty->kind = AST_TYPE_USIZE;
            advance(p);
            return ty;
        case TOKEN_ISIZE:
            ty->kind = AST_TYPE_ISIZE;
            advance(p);
            return ty;
        case TOKEN_F32:
            ty->kind = AST_TYPE_F32;
            advance(p);
            return ty;
        case TOKEN_F64:
            ty->kind = AST_TYPE_F64;
            advance(p);
            return ty;
        case TOKEN_VOID:
            ty->kind = AST_TYPE_VOID;
            advance(p);
            return ty;
        case TOKEN_I32X4: {
            ASTType *elem = (ASTType *)calloc(1, sizeof(ASTType));
            if (!elem) { free(ty); parser_oom(p); return NULL; }
            elem->kind = AST_TYPE_I32; elem->name = NULL; elem->elem_type = NULL; elem->array_size = 0;
            ty->kind = AST_TYPE_VECTOR; ty->elem_type = elem; ty->array_size = 4;
            advance(p); return ty;
        }
        case TOKEN_I32X8: {
            ASTType *elem = (ASTType *)calloc(1, sizeof(ASTType));
            if (!elem) { free(ty); parser_oom(p); return NULL; }
            elem->kind = AST_TYPE_I32; elem->name = NULL; elem->elem_type = NULL; elem->array_size = 0;
            ty->kind = AST_TYPE_VECTOR; ty->elem_type = elem; ty->array_size = 8;
            advance(p); return ty;
        }
        case TOKEN_U32X4: {
            ASTType *elem = (ASTType *)calloc(1, sizeof(ASTType));
            if (!elem) { free(ty); parser_oom(p); return NULL; }
            elem->kind = AST_TYPE_U32; elem->name = NULL; elem->elem_type = NULL; elem->array_size = 0;
            ty->kind = AST_TYPE_VECTOR; ty->elem_type = elem; ty->array_size = 4;
            advance(p); return ty;
        }
        case TOKEN_U32X8: {
            ASTType *elem = (ASTType *)calloc(1, sizeof(ASTType));
            if (!elem) { free(ty); parser_oom(p); return NULL; }
            elem->kind = AST_TYPE_U32; elem->name = NULL; elem->elem_type = NULL; elem->array_size = 0;
            ty->kind = AST_TYPE_VECTOR; ty->elem_type = elem; ty->array_size = 8;
            advance(p); return ty;
        }
        case TOKEN_I32X16: {
            ASTType *elem = (ASTType *)calloc(1, sizeof(ASTType));
            if (!elem) { free(ty); parser_oom(p); return NULL; }
            elem->kind = AST_TYPE_I32; elem->name = NULL; elem->elem_type = NULL; elem->array_size = 0;
            ty->kind = AST_TYPE_VECTOR; ty->elem_type = elem; ty->array_size = 16;
            advance(p); return ty;
        }
        case TOKEN_U32X16: {
            ASTType *elem = (ASTType *)calloc(1, sizeof(ASTType));
            if (!elem) { free(ty); parser_oom(p); return NULL; }
            elem->kind = AST_TYPE_U32; elem->name = NULL; elem->elem_type = NULL; elem->array_size = 0;
            ty->kind = AST_TYPE_VECTOR; ty->elem_type = elem; ty->array_size = 16;
            advance(p); return ty;
        }
        case TOKEN_F32X4: {
            ASTType *elem = (ASTType *)calloc(1, sizeof(ASTType));
            if (!elem) { free(ty); parser_oom(p); return NULL; }
            elem->kind = AST_TYPE_F32; elem->name = NULL; elem->elem_type = NULL; elem->array_size = 0;
            ty->kind = AST_TYPE_VECTOR; ty->elem_type = elem; ty->array_size = 4;
            advance(p); return ty;
        }
        case TOKEN_IDENT: {
            /* M-4：Linear(T) 线性类型包装；须在内建/限定名解析之前识别 */
            if (t->ident_len == 6 && t->value.ident && memcmp(t->value.ident, "Linear", 6) == 0) {
                advance(p);
                if (peek(p) && peek(p)->kind == TOKEN_LPAREN) {
                    advance(p);
                    ASTType *inner = parse_type_name(p);
                    if (!inner) { free(ty); return NULL; }
                    if (!peek(p) || peek(p)->kind != TOKEN_RPAREN) {
                        ast_type_free(inner);
                        free(ty);
                        fail(p, "expected ')' after Linear(T");
                        return NULL;
                    }
                    advance(p);
                    ty->kind = AST_TYPE_LINEAR;
                    ty->elem_type = inner;
                    return ty;
                }
                /* 非 Linear(...) 时回退为 NAMED "Linear"：还原 pos 不可行，按 NAMED 处理 */
                ty->kind = AST_TYPE_NAMED;
                ty->name = strndup("Linear", 6);
                if (!ty->name) { free(ty); parser_oom(p); return NULL; }
                return ty;
            }
            /* 支持限定类型名：Module.sub.Type（如 platform.elf.ElfCodegenCtx）；拼成 "module.sub.Type" 存 name */
            char qbuf[256];
            int qlen = 0;
            if (t->ident_len <= 0 || !t->value.ident) break;
            if (qlen + t->ident_len >= (int)sizeof(qbuf)) { free(ty); fail(p, "type name too long"); return NULL; }
            memcpy(qbuf, t->value.ident, (size_t)t->ident_len);
            qlen = t->ident_len;
            advance(p);
            while (peek(p) && peek(p)->kind == TOKEN_DOT) {
                advance(p);
                if (!peek(p) || peek(p)->kind != TOKEN_IDENT) {
                    free(ty);
                    fail(p, "expected identifier after '.' in type name");
                    return NULL;
                }
                if (qlen + 1 + peek(p)->ident_len >= (int)sizeof(qbuf)) {
                    free(ty);
                    fail(p, "type name too long");
                    return NULL;
                }
                qbuf[qlen++] = '.';
                memcpy(qbuf + qlen, peek(p)->value.ident, (size_t)peek(p)->ident_len);
                qlen += peek(p)->ident_len;
                advance(p);
            }
            qbuf[qlen] = '\0';
            ty->kind = AST_TYPE_NAMED;
            ty->name = strndup(qbuf, (size_t)qlen);
            if (!ty->name) {
                free(ty);
                parser_oom(p);
                return NULL;
            }
            /* LANG-009：Option<i32> 等具体实例 mangling 为 Option_i32 */
            if (peek(p)->kind == TOKEN_LT) {
                char mbuf[256];
                (void)snprintf(mbuf, sizeof(mbuf), "%s", ty->name);
                if (parser_append_type_inst_mangle(p, mbuf, sizeof(mbuf)) != 0) {
                    free(ty->name);
                    free(ty);
                    return NULL;
                }
                free(ty->name);
                ty->name = strdup(mbuf);
                if (!ty->name) {
                    free(ty);
                    parser_oom(p);
                    return NULL;
                }
            }
            return ty;
        }
            /* fallthrough */
        default:
            free(ty);
            fail(p, "expected type name");
            return NULL;
    }
    return NULL; /* unreachable when TOKEN_IDENT falls through via break */
}

/**
 * M-3 / 语法糖：后缀 T[]、T[]<label> 或 T[N]（与 i32[] / i32[2] 写法一致；前缀 []T / [N]T 仍由 parse_type_name 处理）。
 * 参数 ty 为已解析的基础类型；若下一 token 非 `[` 则原样返回 ty。
 */
static ASTType *parse_type_apply_slice_suffix(Parser *p, ASTType *ty) {
    ASTType *wrapped;
    const Token *t;
    int size;
    if (!ty || !peek(p) || peek(p)->kind != TOKEN_LBRACKET)
        return ty;
    advance(p);
    t = peek(p);
    if (t && t->kind == TOKEN_RBRACKET) {
        /* T[] 切片 */
        advance(p);
        wrapped = (ASTType *)calloc(1, sizeof(ASTType));
        if (!wrapped) {
            ast_type_free(ty);
            parser_oom(p);
            return NULL;
        }
        wrapped->kind = AST_TYPE_SLICE;
        wrapped->name = NULL;
        wrapped->elem_type = ty;
        wrapped->array_size = 0;
        wrapped->region_label = NULL;
        parse_slice_region_label(p, wrapped);
        return wrapped;
    }
    if (t && t->kind == TOKEN_INT) {
        /* T[N] 定长数组 */
        size = t->value.int_val;
        if (size <= 0) {
            fail(p, "array size must be positive");
            ast_type_free(ty);
            return NULL;
        }
        advance(p);
        if (!peek(p) || peek(p)->kind != TOKEN_RBRACKET) {
            fail(p, "expected ']' after array size in T[N]");
            ast_type_free(ty);
            return NULL;
        }
        advance(p);
        wrapped = (ASTType *)calloc(1, sizeof(ASTType));
        if (!wrapped) {
            ast_type_free(ty);
            parser_oom(p);
            return NULL;
        }
        wrapped->kind = AST_TYPE_ARRAY;
        wrapped->name = NULL;
        wrapped->elem_type = ty;
        wrapped->array_size = size;
        wrapped->region_label = NULL;
        return wrapped;
    }
    fail(p, "expected ']' or array size in suffix T[] / T[N]");
    ast_type_free(ty);
    return NULL;
}

/** 解析完整类型注解；当前仅支持单类型。 */
static ASTType *parse_type(Parser *p) {
    ASTType *first = parse_type_name(p);
    if (!first) return NULL;
    first = parse_type_apply_slice_suffix(p, first);
    if (!first) return NULL;
    return first;
}

/**
 * LANG-009/010：将单个具体类型实参追加为 mangling 后缀（如 _i32、_ptr_u8）。
 * 参数：buf 已有基础名；arg 类型 AST；cap 缓冲上限。
 * 返回值：0 成功，-1 失败。
 */
static int parser_append_one_type_mangle_suffix(char *buf, size_t cap, const ASTType *arg) {
    size_t len;
    if (!buf || !arg || cap < 8)
        return -1;
    len = strlen(buf);
    if (len + 12 >= cap)
        return -1;
    switch (arg->kind) {
        case AST_TYPE_I32:
            (void)strncat(buf, "_i32", cap - len - 1);
            break;
        case AST_TYPE_U8:
            (void)strncat(buf, "_u8", cap - len - 1);
            break;
        case AST_TYPE_BOOL:
            (void)strncat(buf, "_bool", cap - len - 1);
            break;
        case AST_TYPE_PTR:
            (void)strncat(buf, "_ptr", cap - len - 1);
            len = strlen(buf);
            if (arg->elem_type && arg->elem_type->kind == AST_TYPE_U8 && len + 4 < cap)
                (void)strncat(buf, "_u8", cap - len - 1);
            break;
        default:
            return -1;
    }
    return 0;
}

#define PARSER_MAX_TYPE_INST_ARGS 4

/**
 * LANG-009/010/CORE-016：解析 <T> 或 <T,E,...> 并追加 mangling 后缀到 buf。
 * Option<i32> → Option_i32；Result<i32,i32> → Result_i32（E=i32 压缩，对齐类型族）。
 * 调用前 buf 须含基础类型名；成功返回 0。
 */
static int parser_append_type_inst_mangle(Parser *p, char *buf, size_t cap) {
    ASTType *args[PARSER_MAX_TYPE_INST_ARGS];
    int n_args = 0;
    int i;
    int result_e_i32_condensed = 0;
    if (!p || !buf || cap < 8 || peek(p)->kind != TOKEN_LT)
        return 0;
    advance(p);
    for (;;) {
        if (n_args >= PARSER_MAX_TYPE_INST_ARGS) {
            fail(p, "too many type arguments in <...> instantiation");
            return -1;
        }
        args[n_args] = parse_type_name(p);
        if (!args[n_args]) {
            fail(p, "expected type in <...> instantiation");
            return -1;
        }
        n_args++;
        if (peek(p)->kind == TOKEN_COMMA) {
            advance(p);
            continue;
        }
        if (peek(p)->kind == TOKEN_GT) {
            advance(p);
            break;
        }
        fail(p, "expected ',' or '>' after type argument");
        for (i = 0; i < n_args; i++)
            ast_type_free(args[i]);
        return -1;
    }
    /* CORE-016：Result<T,E=i32> 与 Result_i32/Result_u8 类型族同名 */
    if (strcmp(buf, "Result") == 0 && n_args == 2 && args[1]->kind == AST_TYPE_I32)
        result_e_i32_condensed = 1;
    if (result_e_i32_condensed) {
        if (parser_append_one_type_mangle_suffix(buf, cap, args[0]) != 0) {
            for (i = 0; i < n_args; i++)
                ast_type_free(args[i]);
            fail(p, "unsupported type in Result<T,i32> instantiation (v1: i32/u8/bool/*u8)");
            return -1;
        }
    } else {
        for (i = 0; i < n_args; i++) {
            if (parser_append_one_type_mangle_suffix(buf, cap, args[i]) != 0) {
                for (int j = 0; j < n_args; j++)
                    ast_type_free(args[j]);
                fail(p, "unsupported type in struct instantiation (v1: i32/u8/bool/*u8)");
                return -1;
            }
        }
    }
    for (i = 0; i < n_args; i++)
        ast_type_free(args[i]);
    return 0;
}

/**
 * 解析 if 条件表达式：if ( expr ) { expr } else { expr }；条件须带括号（C/Java 风格）。
 * 参数：p 解析器状态；当前 Token 须为 IF。返回值：成功返回 AST_EXPR_IF；失败返回 NULL。
 */
static ASTExpr *parse_if_expr(Parser *p) {
    if (peek(p)->kind != TOKEN_IF) return NULL;
    int if_start_line = peek(p)->line;
    int if_start_col = peek(p)->col;
    advance(p);
    if (peek(p)->kind != TOKEN_LPAREN) {
        fail(p, "expected '(' after 'if'");
        return NULL;
    }
    advance(p);
    ASTExpr *cond = parse_expr(p);
    if (!cond) return NULL;
    if (peek(p)->kind != TOKEN_RPAREN) {
        ast_expr_free(cond);
        fail(p, "expected ')' after if condition");
        return NULL;
    }
    advance(p);
    if (peek(p)->kind != TOKEN_LBRACE) {
        ast_expr_free(cond);
        fail(p, "expected '{' after if condition");
        return NULL;
    }
    advance(p);  /* 已消费 '{'，当前在块内首 token */
    ASTBlock *then_block = parse_block(p, 1, 0);
    if (!then_block) {
        ast_expr_free(cond);
        return NULL;
    }
    if (peek(p)->kind != TOKEN_RBRACE) {
        ast_expr_free(cond);
        ast_block_free(then_block);
        fail(p, "expected '}' after if body");
        return NULL;
    }
    advance(p);
    if (fail_if_semicolon_after_brace(p) != 0) {
        ast_expr_free(cond);
        ast_block_free(then_block);
        return NULL;
    }
    ASTExpr *then_expr = (ASTExpr *)calloc(1, sizeof(ASTExpr));
    if (!then_expr) {
        ast_expr_free(cond);
        ast_block_free(then_block);
        parser_oom(p);
        return NULL;
    }
    set_expr_loc_at(then_expr, if_start_line, if_start_col);
    then_expr->kind = AST_EXPR_BLOCK;
    then_expr->value.block = then_block;
    /* else 后可为 else if cond { block } 或 else { block }，实现链式条件 */
    ASTExpr *else_expr = NULL;
    if (peek(p)->kind == TOKEN_ELSE) {
        advance(p);
        if (peek(p)->kind == TOKEN_IF) {
            /* else if cond { then } [ else ... ]：递归解析为嵌套 if 表达式 */
            else_expr = parse_if_expr(p);
            if (!else_expr) {
                ast_expr_free(cond);
                ast_expr_free(then_expr);
                return NULL;
            }
        } else {
            if (peek(p)->kind != TOKEN_LBRACE) {
                ast_expr_free(cond);
                ast_expr_free(then_expr);
                fail(p, "expected '{' or 'if' after else");
                return NULL;
            }
            advance(p);  /* 已消费 '{'，当前在 else 块内首 token */
            ASTBlock *else_block = parse_block(p, 1, 0);
            if (!else_block) {
                ast_expr_free(cond);
                ast_expr_free(then_expr);
                return NULL;
            }
            if (peek(p)->kind != TOKEN_RBRACE) {
                ast_expr_free(cond);
                ast_expr_free(then_expr);
                ast_block_free(else_block);
                fail(p, "expected '}' after else body");
                return NULL;
            }
            advance(p);
            if (fail_if_semicolon_after_brace(p) != 0) {
                ast_expr_free(cond);
                ast_expr_free(then_expr);
                ast_block_free(else_block);
                return NULL;
            }
            else_expr = (ASTExpr *)calloc(1, sizeof(ASTExpr));
            if (!else_expr) {
                ast_expr_free(cond);
                ast_expr_free(then_expr);
                ast_block_free(else_block);
                parser_oom(p);
                return NULL;
            }
            set_expr_loc_at(else_expr, if_start_line, if_start_col);
            else_expr->kind = AST_EXPR_BLOCK;
            else_expr->value.block = else_block;
        }
    }
    ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
    if (!e) {
        ast_expr_free(cond);
        ast_expr_free(then_expr);
        ast_expr_free(else_expr);
        parser_oom(p);
        return NULL;
    }
    set_expr_loc_at(e, if_start_line, if_start_col);
    e->kind = AST_EXPR_IF;
    e->value.if_expr.cond = cond;
    e->value.if_expr.then_expr = then_expr;
    e->value.if_expr.else_expr = else_expr;
    return e;
}

/**
 * 解析 unsafe 块表达式：unsafe { body }。
 * 语义上仍复用 block expr，但外层 block 以单个 unsafe region 承载，
 * 让 typeck/codegen/asm 后端沿现有 unsafe region 语义继续工作。
 */
/** 解析单个 asm! 操作数 "constraint"(expr)：成功填 *out_constraint/*out_expr 返回 0；失败 -1。 */
static int parse_asm_one_operand(Parser *p, char **out_constraint, struct ASTExpr **out_expr) {
    const Token *ct;
    char *cstr;
    struct ASTExpr *oe;
    if (peek(p)->kind != TOKEN_STRING) {
        fail(p, "expected constraint string in asm! operand");
        return -1;
    }
    ct = peek(p);
    cstr = (ct->ident_len > 0 && ct->value.ident) ? strndup(ct->value.ident, (size_t)ct->ident_len) : strdup("");
    if (!cstr) { parser_oom(p); return -1; }
    advance(p);  /* constraint string */
    if (peek(p)->kind != TOKEN_LPAREN) {
        fail(p, "expected '(' after asm! constraint");
        free(cstr);
        return -1;
    }
    advance(p);
    oe = parse_expr(p);
    if (!oe) { free(cstr); return -1; }
    if (peek(p)->kind != TOKEN_RPAREN) {
        fail(p, "expected ')' after asm! operand");
        free(cstr);
        ast_expr_free(oe);
        return -1;
    }
    advance(p);  /* ) */
    *out_constraint = cstr;
    *out_expr = oe;
    return 0;
}

/** 解析内联汇编表达式：asm!("template" : out : in : clobber)（K1/L8）。
 *  必须在 unsafe{ } 内（由 typeck 强制）。模板 + 可选三段操作数（按位置：输出 / 输入 / clobber）。
 *  操作数形如 "constraint"(expr)；clobber 为裸字符串。返回 AST_EXPR_ASM。 */
static ASTExpr *parse_asm_expr(Parser *p) {
    int asm_line = peek(p)->line;
    int asm_col = peek(p)->col;
    char *tmpl = NULL;
    int tmpl_len = 0;
    ASTAsmOperand *outs = NULL; int n_out = 0, cap_out = 0;
    ASTAsmOperand *ins = NULL; int n_in = 0, cap_in = 0;
    char **clobs = NULL; int n_clob = 0, cap_clob = 0;
    char **opts = NULL; int n_opt = 0, cap_opt = 0;
    char **labels = NULL; int n_lab = 0, cap_lab = 0;
    int is_goto = 0;
    int had_error = 0;
    int i;
    advance(p);  /* asm */
    /* Check for "goto" keyword: asm goto!(...) */
    if (peek(p)->kind == TOKEN_GOTO) {
        is_goto = 1;
        advance(p);  /* goto */
    }
    advance(p);  /* ! */
    if (peek(p)->kind != TOKEN_LPAREN) {
        fail(p, "expected '(' after asm!");
        return NULL;
    }
    advance(p);
    if (peek(p)->kind != TOKEN_STRING) {
        fail(p, "expected string template in asm!(\"...\")");
        return NULL;
    }
    {
        const Token *st = peek(p);
        tmpl = (st->ident_len > 0 && st->value.ident)
            ? strndup(st->value.ident, (size_t)st->ident_len) : strdup("");
        if (!tmpl) { parser_oom(p); return NULL; }
        tmpl_len = st->ident_len;
    }
    advance(p);  /* template string */

    /* 输出段（第一段，可选） */
    if (!had_error && peek(p)->kind == TOKEN_COLON) {
        advance(p);
        while (peek(p)->kind != TOKEN_COLON && peek(p)->kind != TOKEN_RPAREN && peek(p)->kind != TOKEN_EOF) {
            char *cstr = NULL; struct ASTExpr *oe = NULL;
            if (parse_asm_one_operand(p, &cstr, &oe) != 0) { had_error = 1; break; }
            if (n_out >= cap_out) {
                ASTAsmOperand *np = (ASTAsmOperand *)realloc(outs, (size_t)(cap_out ? cap_out * 2 : 4) * sizeof(ASTAsmOperand));
                if (!np) { free(cstr); ast_expr_free(oe); parser_oom(p); had_error = 1; break; }
                outs = np; cap_out = cap_out ? cap_out * 2 : 4;
            }
            outs[n_out].constraint = cstr; outs[n_out].expr = oe; n_out++;
            if (peek(p)->kind == TOKEN_COMMA) { advance(p); continue; }
            break;
        }
    }
    /* 输入段（第二段，可选） */
    if (!had_error && peek(p)->kind == TOKEN_COLON) {
        advance(p);
        while (peek(p)->kind != TOKEN_COLON && peek(p)->kind != TOKEN_RPAREN && peek(p)->kind != TOKEN_EOF) {
            char *cstr = NULL; struct ASTExpr *oe = NULL;
            if (parse_asm_one_operand(p, &cstr, &oe) != 0) { had_error = 1; break; }
            if (n_in >= cap_in) {
                ASTAsmOperand *np = (ASTAsmOperand *)realloc(ins, (size_t)(cap_in ? cap_in * 2 : 4) * sizeof(ASTAsmOperand));
                if (!np) { free(cstr); ast_expr_free(oe); parser_oom(p); had_error = 1; break; }
                ins = np; cap_in = cap_in ? cap_in * 2 : 4;
            }
            ins[n_in].constraint = cstr; ins[n_in].expr = oe; n_in++;
            if (peek(p)->kind == TOKEN_COMMA) { advance(p); continue; }
            break;
        }
    }
    /* clobber 段（第三段，可选） */
    if (!had_error && peek(p)->kind == TOKEN_COLON) {
        advance(p);
        while (peek(p)->kind != TOKEN_COLON && peek(p)->kind != TOKEN_RPAREN && peek(p)->kind != TOKEN_EOF) {
            char *cstr;
            if (peek(p)->kind != TOKEN_STRING) {
                fail(p, "expected clobber string in asm!");
                had_error = 1;
                break;
            }
            {
                const Token *ct = peek(p);
                cstr = (ct->ident_len > 0 && ct->value.ident) ? strndup(ct->value.ident, (size_t)ct->ident_len) : strdup("");
                if (!cstr) { parser_oom(p); had_error = 1; break; }
            }
            advance(p);  /* clobber string */
            if (n_clob >= cap_clob) {
                char **np = (char **)realloc(clobs, (size_t)(cap_clob ? cap_clob * 2 : 4) * sizeof(char *));
                if (!np) { free(cstr); parser_oom(p); had_error = 1; break; }
                clobs = np; cap_clob = cap_clob ? cap_clob * 2 : 4;
            }
            clobs[n_clob++] = cstr;
            if (peek(p)->kind == TOKEN_COMMA) { advance(p); continue; }
            break;
        }
    }

    /* options 段（第四段，非 goto 时）：裸标识符列表，如 pure, nostack, preserves_flags, noreturn, volatile */
    /* asm goto! 时第四段为 labels（GCC 语法：asm goto("tmpl" : outs : ins : clobs : labels)） */
    if (!had_error && !is_goto && peek(p)->kind == TOKEN_COLON) {
        advance(p);
        while (peek(p)->kind != TOKEN_RPAREN && peek(p)->kind != TOKEN_EOF) {
            char *ostr;
            if (peek(p)->kind != TOKEN_IDENT) {
                fail(p, "expected option identifier in asm! options");
                had_error = 1;
                break;
            }
            {
                const Token *ot = peek(p);
                ostr = (ot->ident_len > 0 && ot->value.ident) ? strndup(ot->value.ident, (size_t)ot->ident_len) : strdup("");
                if (!ostr) { parser_oom(p); had_error = 1; break; }
            }
            advance(p);  /* option ident */
            if (n_opt >= cap_opt) {
                char **np = (char **)realloc(opts, (size_t)(cap_opt ? cap_opt * 2 : 4) * sizeof(char *));
                if (!np) { free(ostr); parser_oom(p); had_error = 1; break; }
                opts = np; cap_opt = cap_opt ? cap_opt * 2 : 4;
            }
            opts[n_opt++] = ostr;
            if (peek(p)->kind == TOKEN_COMMA) { advance(p); continue; }
            break;
        }
    }

    /* labels 段（第四段，asm goto! 专属）：裸标识符列表，如 done, error */
    if (!had_error && is_goto && peek(p)->kind == TOKEN_COLON) {
        advance(p);
        while (peek(p)->kind != TOKEN_RPAREN && peek(p)->kind != TOKEN_EOF) {
            char *lstr;
            if (peek(p)->kind != TOKEN_IDENT) {
                fail(p, "expected label identifier in asm goto! labels");
                had_error = 1;
                break;
            }
            {
                const Token *lt = peek(p);
                lstr = (lt->ident_len > 0 && lt->value.ident) ? strndup(lt->value.ident, (size_t)lt->ident_len) : strdup("");
                if (!lstr) { parser_oom(p); had_error = 1; break; }
            }
            advance(p);
            if (n_lab >= cap_lab) {
                char **np = (char **)realloc(labels, (size_t)(cap_lab ? cap_lab * 2 : 4) * sizeof(char *));
                if (!np) { free(lstr); parser_oom(p); had_error = 1; break; }
                labels = np; cap_lab = cap_lab ? cap_lab * 2 : 4;
            }
            labels[n_lab++] = lstr;
            if (peek(p)->kind == TOKEN_COMMA) { advance(p); continue; }
            break;
        }
    }

    if (had_error) {
        if (tmpl) free(tmpl);
        for (i = 0; i < n_out; i++) { if (outs[i].constraint) free(outs[i].constraint); ast_expr_free(outs[i].expr); }
        free(outs);
        for (i = 0; i < n_in; i++) { if (ins[i].constraint) free(ins[i].constraint); ast_expr_free(ins[i].expr); }
        free(ins);
        for (i = 0; i < n_clob; i++) free(clobs[i]);
        free(clobs);
        for (i = 0; i < n_opt; i++) free(opts[i]);
        free(opts);
        for (i = 0; i < n_lab; i++) free(labels[i]);
        free(labels);
        return NULL;
    }
    if (peek(p)->kind != TOKEN_RPAREN) {
        fail(p, "expected ')' after asm!");
        if (tmpl) free(tmpl);
        for (i = 0; i < n_out; i++) { if (outs[i].constraint) free(outs[i].constraint); ast_expr_free(outs[i].expr); }
        free(outs);
        for (i = 0; i < n_in; i++) { if (ins[i].constraint) free(ins[i].constraint); ast_expr_free(ins[i].expr); }
        free(ins);
        for (i = 0; i < n_clob; i++) free(clobs[i]);
        free(clobs);
        for (i = 0; i < n_opt; i++) free(opts[i]);
        free(opts);
        for (i = 0; i < n_lab; i++) free(labels[i]);
        free(labels);
        return NULL;
    }
    advance(p);  /* ) */
    {
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) {
            if (tmpl) free(tmpl);
            for (i = 0; i < n_out; i++) { if (outs[i].constraint) free(outs[i].constraint); ast_expr_free(outs[i].expr); }
            free(outs);
            for (i = 0; i < n_in; i++) { if (ins[i].constraint) free(ins[i].constraint); ast_expr_free(ins[i].expr); }
            free(ins);
            for (i = 0; i < n_clob; i++) free(clobs[i]);
            free(clobs);
            for (i = 0; i < n_opt; i++) free(opts[i]);
            free(opts);
            for (i = 0; i < n_lab; i++) free(labels[i]);
            free(labels);
            parser_oom(p);
            return NULL;
        }
        set_expr_loc_at(e, asm_line, asm_col);
        e->kind = AST_EXPR_ASM;
        e->value.asm_tmpl.bytes = tmpl;
        e->value.asm_tmpl.len = tmpl_len;
        e->value.asm_tmpl.outputs = outs; e->value.asm_tmpl.num_outputs = n_out;
        e->value.asm_tmpl.inputs = ins; e->value.asm_tmpl.num_inputs = n_in;
        e->value.asm_tmpl.clobbers = clobs; e->value.asm_tmpl.num_clobbers = n_clob;
        e->value.asm_tmpl.options = opts; e->value.asm_tmpl.num_options = n_opt;
        e->value.asm_tmpl.is_goto = is_goto;
        e->value.asm_tmpl.labels = labels; e->value.asm_tmpl.num_labels = n_lab;
        return e;
    }
}

static ASTExpr *parse_unsafe_expr(Parser *p) {
    ASTBlock *unsafe_body = NULL;
    ASTBlock *outer = NULL;
    ASTRegionBlock *regions = NULL;
    ASTExpr *e = NULL;
    const Token *t = peek(p);
    int unsafe_line;
    int unsafe_col;
    if (!t || t->kind != TOKEN_IDENT || !is_ident_str(p, "unsafe", 6))
        return NULL;
    unsafe_line = t->line;
    unsafe_col = t->col;
    advance(p);
    if (peek(p)->kind != TOKEN_LBRACE) {
        fail(p, "expected '{' after unsafe");
        return NULL;
    }
    advance(p);
    unsafe_body = parse_block(p, 1, 0);
    if (!unsafe_body)
        return NULL;
    if (peek(p)->kind != TOKEN_RBRACE) {
        ast_block_free(unsafe_body);
        fail(p, "expected '}' after unsafe body");
        return NULL;
    }
    advance(p);
    outer = (ASTBlock *)calloc(1, sizeof(ASTBlock));
    if (!outer) {
        ast_block_free(unsafe_body);
        parser_oom(p);
        return NULL;
    }
    regions = (ASTRegionBlock *)calloc(1, sizeof(ASTRegionBlock));
    if (!regions) {
        ast_block_free(unsafe_body);
        free(outer);
        parser_oom(p);
        return NULL;
    }
    regions[0].label = NULL;
    regions[0].body = unsafe_body;
    regions[0].is_unsafe = 1;
    outer->regions = regions;
    outer->num_regions = 1;
    outer->stmt_order[0].kind = 5;
    outer->stmt_order[0].idx = 0;
    outer->num_stmt_order = 1;
    e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
    if (!e) {
        ast_block_free(unsafe_body);
        free(regions);
        free(outer);
        parser_oom(p);
        return NULL;
    }
    set_expr_loc_at(e, unsafe_line, unsafe_col);
    e->kind = AST_EXPR_BLOCK;
    e->value.block = outer;
    return e;
}

/**
 * 解析主表达式（primary）：整数字面量、括号 ( expr )、if/break/continue、或标识符引用。
 * 参数：p 解析器状态。返回值：成功返回新分配的 ASTExpr*；失败返回 NULL 且已通过 fail 报错。
 */
static ASTExpr *parse_primary(Parser *p) {
    const Token *t = peek(p);
    /* break/continue 仅允许出现在循环体 final_expr 中，由 typeck 校验 */
    if (t->kind == TOKEN_BREAK) {
        advance(p);
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) { parser_oom(p); return NULL; }
        set_expr_loc(e, p);
        e->kind = AST_EXPR_BREAK;
        return e;
    }
    if (t->kind == TOKEN_CONTINUE) {
        advance(p);
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) { parser_oom(p); return NULL; }
        set_expr_loc(e, p);
        e->kind = AST_EXPR_CONTINUE;
        return e;
    }
    if (t->kind == TOKEN_AT) {
        return parse_at_simd_builtin(p);
    }
    if (t->kind == TOKEN_LBRACE) {
        return parse_struct_lit_body(p, NULL, t->line, t->col);
    }
    /* return expr 或 return;：显式返回，仅允许在函数体内，由 typeck 校验（文档 01：return expr; / return;） */
    if (t->kind == TOKEN_RETURN) {
        advance(p);
        ASTExpr *val = NULL;
        if (peek(p)->kind != TOKEN_SEMICOLON && peek(p)->kind != TOKEN_RBRACE)
            val = parse_expr(p);
        /* } 后分号可选；return 以 } 结尾时可不写分号；其他 return 必须带分号 */
        if (val && expr_ends_with_brace(val)) {
            if (peek(p)->kind == TOKEN_SEMICOLON) advance(p);
        } else {
            if (peek(p)->kind != TOKEN_SEMICOLON) {
                ast_expr_free(val);
                fail(p, "expected ';' after return");
                return NULL;
            }
            advance(p);
        }
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) { ast_expr_free(val); parser_oom(p); return NULL; }
        set_expr_loc(e, p);
        e->kind = AST_EXPR_RETURN;
        e->value.unary.operand = val;
        return e;
    }
    /* panic 或 panic(expr)：终止程序，可选消息表达式；panic() 无参合法 */
    if (t->kind == TOKEN_PANIC) {
        advance(p);
        ASTExpr *operand = NULL;
        if (peek(p)->kind == TOKEN_LPAREN) {
            advance(p);
            if (peek(p)->kind == TOKEN_RPAREN) {
                advance(p);  /* panic() 无参 */
            } else {
                operand = parse_expr(p);
                if (!operand) return NULL;
                if (peek(p)->kind != TOKEN_RPAREN) {
                    ast_expr_free(operand);
                    fail(p, "expected ')' after panic(expr)");
                    return NULL;
                }
                advance(p);
            }
        }
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) { ast_expr_free(operand); parser_oom(p); return NULL; }
        set_expr_loc(e, p);
        e->kind = AST_EXPR_PANIC;
        e->value.unary.operand = operand;
        return e;
    }
    /* match expr { lit|_ => expr ; ... }：最小形式仅整数字面量与 _ */
    if (t->kind == TOKEN_MATCH) {
        int match_line = t->line;
        int match_col = t->col;
        advance(p);
        ASTExpr *matched = parse_expr(p);
        if (!matched) return NULL;
        if (peek(p)->kind != TOKEN_LBRACE) {
            ast_expr_free(matched);
            fail(p, "expected '{' after match expr");
            return NULL;
        }
        advance(p);
        ASTMatchArm *arms = (ASTMatchArm *)malloc(16 * sizeof(ASTMatchArm));
        if (!arms) {
            ast_expr_free(matched);
            parser_oom(p);
            return NULL;
        }
        int num_arms = 0;
        int cap = 16;
        for (;;) {
            if (peek(p)->kind == TOKEN_RBRACE) break;
            if (num_arms >= cap) {
                ASTMatchArm *n = (ASTMatchArm *)realloc(arms, (size_t)(cap *= 2) * sizeof(ASTMatchArm));
                if (!n) {
                    while (num_arms--) ast_expr_free(arms[num_arms].result);
                    free(arms);
                    ast_expr_free(matched);
                    return NULL;
                }
                arms = n;
            }
            if (peek(p)->kind == TOKEN_INT) {
                arms[num_arms].is_wildcard = 0;
                arms[num_arms].is_enum_variant = 0;
                arms[num_arms].enum_name = NULL;
                arms[num_arms].variant_name = NULL;
                arms[num_arms].variant_index = 0;
                arms[num_arms].lit_val = peek(p)->value.int_val;
                advance(p);
            } else if (peek(p)->kind == TOKEN_UNDERSCORE) {
                arms[num_arms].is_wildcard = 1;
                arms[num_arms].is_enum_variant = 0;
                arms[num_arms].enum_name = NULL;
                arms[num_arms].variant_name = NULL;
                arms[num_arms].lit_val = 0;
                advance(p);
            } else if (peek(p)->kind == TOKEN_IDENT && peek_next(p)->kind == TOKEN_DOT) {
                /* Name.Variant 枚举变体模式（§7.4） */
                char *en = strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len);
                advance(p);
                if (peek(p)->kind != TOKEN_DOT) { free(en); goto match_arm_fail; }
                advance(p);
                if (peek(p)->kind != TOKEN_IDENT) { free(en); goto match_arm_fail; }
                char *vn = strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len);
                advance(p);
                if (!vn) { free(en); goto match_arm_fail; }
                arms[num_arms].is_wildcard = 0;
                arms[num_arms].is_enum_variant = 1;
                arms[num_arms].enum_name = en;
                arms[num_arms].variant_name = vn;
                arms[num_arms].variant_index = 0;
                arms[num_arms].lit_val = 0;
            } else {
                match_arm_fail:
                while (num_arms--) ast_expr_free(arms[num_arms].result);
                free(arms);
                ast_expr_free(matched);
                fail(p, "expected integer literal, '_', or enum variant (Name.Variant) in match arm");
                return NULL;
            }
            if (peek(p)->kind != TOKEN_FATARROW) {
                while (num_arms--) ast_expr_free(arms[num_arms].result);
                free(arms);
                ast_expr_free(matched);
                fail(p, "expected '=>' in match arm");
                return NULL;
            }
            advance(p);
            arms[num_arms].result = parse_expr(p);
            if (!arms[num_arms].result) {
                while (num_arms--) ast_expr_free(arms[num_arms].result);
                free(arms);
                ast_expr_free(matched);
                return NULL;
            }
            num_arms++;
            if (peek(p)->kind != TOKEN_SEMICOLON) {
                while (num_arms--) ast_expr_free(arms[num_arms].result);
                free(arms);
                ast_expr_free(matched);
                fail(p, "expected ';' after match arm");
                return NULL;
            }
            advance(p);
        }
        if (peek(p)->kind != TOKEN_RBRACE) {
            while (num_arms--) ast_expr_free(arms[num_arms].result);
            free(arms);
            ast_expr_free(matched);
            fail(p, "expected '}' to close match");
            return NULL;
        }
        advance(p);
        if (fail_if_semicolon_after_brace(p) != 0) {
            while (num_arms--) ast_expr_free(arms[num_arms].result);
            free(arms);
            ast_expr_free(matched);
            return NULL;
        }
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) {
            while (num_arms--) ast_expr_free(arms[num_arms].result);
            free(arms);
            ast_expr_free(matched);
            parser_oom(p);
            return NULL;
        }
        set_expr_loc_at(e, match_line, match_col);
        e->kind = AST_EXPR_MATCH;
        e->value.match_expr.matched_expr = matched;
        e->value.match_expr.arms = arms;
        e->value.match_expr.num_arms = num_arms;
        return e;
    }
    /* 数组字面量 [e1, e2, ...]（文档 §6.2）；表达式语境下 [ 即数组字面量 */
    if (t->kind == TOKEN_LBRACKET) {
        int arr_start_line = t->line;
        int arr_start_col = t->col;
        advance(p);
        ASTExpr **elems = (ASTExpr **)malloc(32 * sizeof(ASTExpr *));
        if (!elems) { parser_oom(p); return NULL; }
        int num_elems = 0, cap = 32;
        if (peek(p)->kind != TOKEN_RBRACKET) {
            for (;;) {
                if (num_elems >= cap) {
                    ASTExpr **n = (ASTExpr **)realloc(elems, (size_t)(cap *= 2) * sizeof(ASTExpr *));
                    if (!n) {
                        while (num_elems--) ast_expr_free(elems[num_elems]);
                        free(elems);
                        return NULL;
                    }
                    elems = n;
                }
                ASTExpr *e = parse_expr(p);
                if (!e) {
                    while (num_elems--) ast_expr_free(elems[num_elems]);
                    free(elems);
                    return NULL;
                }
                elems[num_elems++] = e;
                if (peek(p)->kind == TOKEN_COMMA) {
                    advance(p);
                    /* 尾逗号 `, ]`：多行 [64]i32 初值等与 parser.sx 一致 */
                    if (peek(p)->kind == TOKEN_RBRACKET)
                        break;
                    continue;
                }
                break;
            }
        }
        if (peek(p)->kind != TOKEN_RBRACKET) {
            while (num_elems--) ast_expr_free(elems[num_elems]);
            free(elems);
            fail(p, "expected ']' to close array literal");
            return NULL;
        }
        advance(p);
        ASTExpr *arr = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!arr) {
            while (num_elems--) ast_expr_free(elems[num_elems]);
            free(elems);
            parser_oom(p);
            return NULL;
        }
        set_expr_loc_at(arr, arr_start_line, arr_start_col);
        arr->kind = AST_EXPR_ARRAY_LIT;
        arr->value.array_lit.elems = elems;
        arr->value.array_lit.num_elems = num_elems;
        return arr;
    }
    if (t->kind == TOKEN_IF) {
        return parse_if_expr(p);
    }
    if (t->kind == TOKEN_LPAREN) {
        advance(p);
        ASTExpr *e = parse_expr(p);
        if (!e) return NULL;
        if (peek(p)->kind != TOKEN_RPAREN) {
            ast_expr_free(e);
            fail(p, "expected ')'");
            return NULL;
        }
        advance(p);
        return e;
    }
    /* self：方法体内作为变量引用（阶段 7.2） */
    if (t->kind == TOKEN_SELF) {
        advance(p);
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) { parser_oom(p); return NULL; }
        set_expr_loc_at(e, t->line, t->col);
        e->kind = AST_EXPR_VAR;
        e->value.var.name = strdup("self");
        return e;
    }
    /* 变量/常量引用（标识符）或结构体字面量 TypeName { field: expr, ... } */
    if (t->kind == TOKEN_IDENT) {
        if (is_ident_str(p, "unsafe", 6))
            return parse_unsafe_expr(p);
        if (is_ident_str(p, "asm", 3) && peek_next(p)->kind == TOKEN_BANG)
            return parse_asm_expr(p);
        /* asm goto!(...) — detect "asm" followed by "goto" (TOKEN_GOTO) followed by "!" */
        if (is_ident_str(p, "asm", 3) && peek_next(p)->kind == TOKEN_GOTO)
            return parse_asm_expr(p);
        int ident_line = t->line;
        int ident_col = t->col;
        char *name = t->ident_len > 0 && t->value.ident
            ? strndup(t->value.ident, (size_t)t->ident_len) : NULL;
        advance(p);
        if (!name) {
            fail(p, "invalid identifier");
            return NULL;
        }
        /* LANG-009：Option<i32> { ... } / 类型名 Option<i32>（首字母大写约定） */
        if (name[0] >= 'A' && name[0] <= 'Z' && peek(p)->kind == TOKEN_LT) {
            char mbuf[256];
            (void)snprintf(mbuf, sizeof(mbuf), "%s", name);
            if (parser_append_type_inst_mangle(p, mbuf, sizeof(mbuf)) != 0) {
                free(name);
                return NULL;
            }
            free(name);
            name = strdup(mbuf);
            if (!name) {
                parser_oom(p);
                return NULL;
            }
        }
        /* 枚举值用 Name.Variant（. 语法），见 parse_postfix 的 field_access；此处仅处理标识符或结构体字面量 */
        /* 仅当首字母大写（类型名约定）且下一 token 为 { 时解析为结构体字面量，避免 if ok { } 中的 ok 被误判 */
        if (peek(p)->kind == TOKEN_LBRACE && name[0] >= 'A' && name[0] <= 'Z')
            return parse_struct_lit_body(p, name, ident_line, ident_col);
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) {
            free(name);
            parser_oom(p);
            return NULL;
        }
        set_expr_loc_at(e, ident_line, ident_col);
        e->kind = AST_EXPR_VAR;
        e->value.var.name = name;
        return e;
    }
    if (t->kind == TOKEN_TRUE) {
        advance(p);
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) {
            parser_oom(p);
            return NULL;
        }
        set_expr_loc_at(e, t->line, t->col);
        e->kind = AST_EXPR_BOOL_LIT;
        e->value.int_val = 1;
        return e;
    }
    if (t->kind == TOKEN_FALSE) {
        advance(p);
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) {
            parser_oom(p);
            return NULL;
        }
        set_expr_loc_at(e, t->line, t->col);
        e->kind = AST_EXPR_BOOL_LIT;
        e->value.int_val = 0;
        return e;
    }
    if (t->kind == TOKEN_FLOAT) {
        double fval = t->value.float_val;
        int fline = t->line, fcol = t->col;
        advance(p);
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) {
            parser_oom(p);
            return NULL;
        }
        set_expr_loc_at(e, fline, fcol);
        e->kind = AST_EXPR_FLOAT_LIT;
        e->value.float_val = fval;
        return e;
    }
    /* 类型关键字作函数名（如 std.random 的 u32()、u64()、bool()）；后接 ( 时解析为变量引用，由 parse_postfix 处理为函数调用 */
    if ((t->kind == TOKEN_U32 || t->kind == TOKEN_U64 || t->kind == TOKEN_BOOL) && peek_next(p) && peek_next(p)->kind == TOKEN_LPAREN) {
        int ident_line = t->line;
        int ident_col = t->col;
        const char *name = (t->kind == TOKEN_U32) ? "u32" : (t->kind == TOKEN_U64) ? "u64" : "bool";
        advance(p);
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) {
            parser_oom(p);
            return NULL;
        }
        set_expr_loc_at(e, ident_line, ident_col);
        e->kind = AST_EXPR_VAR;
        e->value.var.name = strdup(name);
        return e;
    }
    if (t->kind != TOKEN_INT) {
        fail(p, "expected integer literal, float literal, identifier, 'true', 'false', 'if', 'break', 'continue', 'return', 'panic', 'match', or '('");
        return NULL;
    }
    ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
    if (!e) {
        parser_oom(p);
        return NULL;
    }
    set_expr_loc(e, p);
    e->kind = AST_EXPR_LIT;
    e->value.int_val = t->value.int_val;
    advance(p);
    return e;
}

/**
 * 判断当前 `?` 是否为 ERR-01 Result 传播后缀（expr?），而非三元 cond ? then : else。
 * 与 parser_asm_as_suffix_slice.c 一致：`?` 后若仍可开始 then 分支则留给 parse_ternary。
 */
static int question_is_try_propagate_suffix(Parser *p) {
    const Token *after;
    if (!peek(p) || peek(p)->kind != TOKEN_QUESTION)
        return 0;
    after = peek_next(p);
    switch (after->kind) {
    case TOKEN_SEMICOLON:
    case TOKEN_RPAREN:
    case TOKEN_RBRACE:
    case TOKEN_COMMA:
    case TOKEN_RBRACKET:
        return 1;
    default:
        return 0;
    }
}

/**
 * 解析零个或多个「as 类型」后缀，紧接在 primary/postfix/调用之后（与 parser.sx parse_as_suffix_into 一致）。
 * 支持 path[i] as i32、foo() as *u8 等；as 不可放在 [index] 之前。
 * 参数：p 解析器；left 已有子表达式。返回值：成功返回（可能嵌套 AS 的）ASTExpr*；失败返回 NULL。
 */
static ASTExpr *parse_as_chain(Parser *p, ASTExpr *left) {
    for (;;) {
        if (peek(p) && peek(p)->kind == TOKEN_QUESTION) {
            if (!question_is_try_propagate_suffix(p))
                return left;
            advance(p);
            ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
            if (!e) {
                ast_expr_free(left);
                parser_oom(p);
                return NULL;
            }
            e->kind = AST_EXPR_TRY_PROPAGATE;
            e->resolved_type = NULL;
            e->line = left->line;
            e->col = left->col;
            e->value.unary.operand = left;
            left = e;
            continue;
        }
        if (!peek(p) || peek(p)->kind != TOKEN_AS)
            return left;
        advance(p);
        ASTType *ty = parse_type(p);
        if (!ty) {
            ast_expr_free(left);
            return NULL;
        }
        ASTExpr *e = (ASTExpr *)malloc(sizeof(ASTExpr));
        if (!e) {
            ast_expr_free(left);
            ast_type_free(ty);
            parser_oom(p);
            return NULL;
        }
        e->kind = AST_EXPR_AS;
        e->resolved_type = NULL;
        e->line = left->line;
        e->col = left->col;
        e->value.as_type.operand = left;
        e->value.as_type.type = ty;
        left = e;
    }
}

/**
 * 解析 primary（不含 as 后缀；as 由 parse_postfix 在 postfix/调用之后统一处理）。
 * 参数：p 解析器状态。返回值：成功返回 ASTExpr*；失败返回 NULL。
 */
static ASTExpr *parse_cast(Parser *p) {
    return parse_primary(p);
}

/**
 * 解析后缀表达式：cast 后接零个或多个 . field 或 [ index ]，可交错（支持 a[i].field[j]）。
 * 参数：p 解析器状态。返回值：成功返回 ASTExpr*；失败返回 NULL。
 */
static ASTExpr *parse_postfix(Parser *p) {
    ASTExpr *left = parse_cast(p);
    if (!left) return NULL;
    while (peek(p)->kind == TOKEN_DOT || peek(p)->kind == TOKEN_LBRACKET) {
        if (peek(p)->kind == TOKEN_DOT) {
            advance(p);
            if (peek(p)->kind != TOKEN_IDENT && peek(p)->kind != TOKEN_MATCH && peek(p)->kind != TOKEN_SPAWN) {
                ast_expr_free(left);
                fail(p, "expected field name after '.'");
                return NULL;
            }
            char *field_name = NULL;
            if (peek(p)->kind == TOKEN_MATCH) {
                field_name = strdup("match");
            } else if (peek(p)->kind == TOKEN_SPAWN) {
                field_name = strdup("spawn");
            } else {
                field_name = strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len);
            }
            if (!field_name) {
                ast_expr_free(left);
                parser_oom(p);
                return NULL;
            }
            advance(p);
            /* base . method ( args ) → 方法调用（阶段 7.2）；否则为字段访问 */
            if (peek(p)->kind == TOKEN_LPAREN) {
                advance(p);  /* consume '(' */
                int args_cap = AST_FUNC_PARAMS_INIT;
                ASTExpr **args = (ASTExpr **)malloc((size_t)args_cap * sizeof(ASTExpr *));
                if (!args) {
                    ast_expr_free(left);
                    free(field_name);
                    parser_oom(p);
                    return NULL;
                }
                int num_args = 0;
                while (peek(p)->kind != TOKEN_RPAREN) {
                    ASTExpr **na = parser_grow_call_args(args, &args_cap, num_args + 1);
                    if (!na) {
                        ast_expr_free(left);
                        free(field_name);
                        for (int i = 0; i < num_args; i++) ast_expr_free(args[i]);
                        free(args);
                        parser_oom(p);
                        return NULL;
                    }
                    args = na;
                    ASTExpr *arg = parse_expr(p);
                    if (!arg) {
                        ast_expr_free(left);
                        free(field_name);
                        for (int i = 0; i < num_args; i++) ast_expr_free(args[i]);
                        free(args);
                        return NULL;
                    }
                    args[num_args++] = arg;
                    if (peek(p)->kind != TOKEN_COMMA) break;
                    advance(p);
                }
                if (peek(p)->kind != TOKEN_RPAREN) {
                    ast_expr_free(left);
                    free(field_name);
                    for (int i = 0; i < num_args; i++) ast_expr_free(args[i]);
                    free(args);
                    fail(p, "expected ')' after method call arguments");
                    return NULL;
                }
                advance(p);  /* consume ')' */
                ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
                if (!e) {
                    ast_expr_free(left);
                    free(field_name);
                    for (int i = 0; i < num_args; i++) ast_expr_free(args[i]);
                    free(args);
                    parser_oom(p);
                    return NULL;
                }
                set_expr_loc(e, p);
                e->kind = AST_EXPR_METHOD_CALL;
                e->value.method_call.base = left;
                e->value.method_call.method_name = field_name;
                e->value.method_call.args = args;
                e->value.method_call.num_args = num_args;
                e->value.method_call.resolved_impl_func = NULL;
                left = e;
            } else {
                /* 绑定 import 限定 struct 字面量：process.SpawnIo { ... }（与类型注解 process.SpawnIo 一致） */
                if (peek(p)->kind == TOKEN_LBRACE && field_name[0] >= 'A' && field_name[0] <= 'Z') {
                    char qbuf[256];
                    if (parser_qual_name_from_expr_field(left, field_name, qbuf, sizeof(qbuf)) > 0) {
                        char *lit_name = strdup(qbuf);
                        int lit_line = left->line;
                        int lit_col = left->col;
                        if (!lit_name) {
                            ast_expr_free(left);
                            free(field_name);
                            parser_oom(p);
                            return NULL;
                        }
                        ast_expr_free(left);
                        left = parse_struct_lit_body(p, lit_name, lit_line, lit_col);
                        free(field_name);
                        if (!left) return NULL;
                        continue;
                    }
                }
                ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
                if (!e) {
                    ast_expr_free(left);
                    free(field_name);
                    parser_oom(p);
                    return NULL;
                }
                set_expr_loc(e, p);
                e->kind = AST_EXPR_FIELD_ACCESS;
                e->value.field_access.base = left;
                e->value.field_access.field_name = field_name;
                e->value.field_access.is_enum_variant = 0;  /* typeck 将 Type.Variant 设为 1 */
                left = e;
            }
        } else {
            /* 下标访问 base[index]（文档 §6.2） */
            advance(p);
            ASTExpr *idx = parse_expr(p);
            if (!idx) {
                ast_expr_free(left);
                return NULL;
            }
            if (peek(p)->kind != TOKEN_RBRACKET) {
                ast_expr_free(left);
                ast_expr_free(idx);
                fail(p, "expected ']' after array index");
                return NULL;
            }
            advance(p);
            ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
            if (!e) {
                ast_expr_free(left);
                ast_expr_free(idx);
                parser_oom(p);
                return NULL;
            }
            set_expr_loc(e, p);
            e->kind = AST_EXPR_INDEX;
            e->value.index.base = left;
            e->value.index.index_expr = idx;
            e->value.index.base_is_slice = 0;  /* typeck 会设为 1 当基类型为切片 */
            left = e;
        }
    }
    /* 可选泛型类型实参：callee < Type (, Type)* > ( args )（阶段 7.1）。仅当 < 后为类型起始符时才解析，避免 a < b 被当作泛型调用。 */
    ASTType **type_args = NULL;
    int num_type_args = 0;
    if (peek(p)->kind == TOKEN_LT) {
        const Token *n = peek_next(p);
        TokenKind k = n->kind;
        int type_start;
        if (k == TOKEN_IDENT) {
            /* i < len 与 f<T>(...) 歧义：仅当 IDENT 后为 > 或 , 时视为泛型实参 */
            const Token *nn = peek_next_next(p);
            type_start = (nn->kind == TOKEN_GT || nn->kind == TOKEN_COMMA);
        } else {
            type_start = (k == TOKEN_I32 || k == TOKEN_BOOL || k == TOKEN_U8 || k == TOKEN_U32 || k == TOKEN_U64 || k == TOKEN_I64 || k == TOKEN_USIZE || k == TOKEN_ISIZE || k == TOKEN_F32 || k == TOKEN_F64 || k == TOKEN_VOID || k == TOKEN_I32X4 || k == TOKEN_I32X8 || k == TOKEN_I32X16 || k == TOKEN_U32X4 || k == TOKEN_U32X8 || k == TOKEN_U32X16 || k == TOKEN_F32X4 || k == TOKEN_STAR || k == TOKEN_LBRACKET);
        }
        if (!type_start) {
            /* 视为小于运算，不解析类型实参 */
        } else {
        advance(p);
        ASTType **ta = (ASTType **)malloc((size_t)AST_MAX_GENERIC_PARAMS * sizeof(ASTType *));
        if (!ta) {
            ast_expr_free(left);
            parser_oom(p);
            return NULL;
        }
        int nta = 0;
        for (;;) {
            if (nta >= AST_MAX_GENERIC_PARAMS) {
                ast_expr_free(left);
                for (int i = 0; i < nta; i++) ast_type_free(ta[i]);
                free(ta);
                fail(p, "too many type arguments in call");
                return NULL;
            }
            ASTType *ty = parse_type_name(p);
            if (!ty) {
                ast_expr_free(left);
                for (int i = 0; i < nta; i++) ast_type_free(ta[i]);
                free(ta);
                return NULL;
            }
            ta[nta++] = ty;
            if (peek(p)->kind == TOKEN_GT) break;
            if (peek(p)->kind != TOKEN_COMMA) {
                ast_expr_free(left);
                for (int i = 0; i < nta; i++) ast_type_free(ta[i]);
                free(ta);
                fail(p, "expected ',' or '>' in type argument list");
                return NULL;
            }
            advance(p);
        }
        advance(p);  /* consume '>' */
        type_args = ta;
        num_type_args = nta;
        if (peek(p)->kind != TOKEN_LPAREN) {
            ast_expr_free(left);
            for (int i = 0; i < num_type_args; i++) ast_type_free(type_args[i]);
            free(type_args);
            fail(p, "expected '(' after type arguments in call");
            return NULL;
        }
        }
    }
    /* 函数调用 callee [ < Type* > ] ( args )（自举前路线分析 §5.1、阶段 7.1） */
    if (peek(p)->kind == TOKEN_LPAREN) {
        advance(p);
        ASTExpr **args = (ASTExpr **)malloc(4 * sizeof(ASTExpr *));
        int num_args = 0, cap = 4;
        if (!args) {
            ast_expr_free(left);
            if (type_args) { for (int i = 0; i < num_type_args; i++) ast_type_free(type_args[i]); free(type_args); }
            parser_oom(p);
            return NULL;
        }
        while (peek(p)->kind != TOKEN_RPAREN) {
            if (num_args > 0) {
                if (peek(p)->kind != TOKEN_COMMA) {
                    ast_expr_free(left);
                    for (int i = 0; i < num_args; i++) ast_expr_free(args[i]);
                    free(args);
                    if (type_args) { for (int i = 0; i < num_type_args; i++) ast_type_free(type_args[i]); free(type_args); }
                    fail(p, "expected ',' or ')' in argument list");
                    return NULL;
                }
                advance(p);
            }
            ASTExpr *arg = parse_expr(p);
            if (!arg) {
                ast_expr_free(left);
                for (int i = 0; i < num_args; i++) ast_expr_free(args[i]);
                free(args);
                if (type_args) { for (int i = 0; i < num_type_args; i++) ast_type_free(type_args[i]); free(type_args); }
                return NULL;
            }
            if (num_args >= cap) {
                ASTExpr **n = (ASTExpr **)realloc(args, (size_t)(cap *= 2) * sizeof(ASTExpr *));
                if (!n) {
                    ast_expr_free(left);
                    ast_expr_free(arg);
                    for (int i = 0; i < num_args; i++) ast_expr_free(args[i]);
                    free(args);
                    if (type_args) { for (int i = 0; i < num_type_args; i++) ast_type_free(type_args[i]); free(type_args); }
                    parser_oom(p);
                    return NULL;
                }
                args = n;
            }
            args[num_args++] = arg;
        }
        advance(p);  /* consume ')' */
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) {
            ast_expr_free(left);
            for (int i = 0; i < num_args; i++) ast_expr_free(args[i]);
            free(args);
            if (type_args) { for (int i = 0; i < num_type_args; i++) ast_type_free(type_args[i]); free(type_args); }
            parser_oom(p);
            return NULL;
        }
        set_expr_loc(e, p);
        e->kind = AST_EXPR_CALL;
        e->value.call.callee = left;
        e->value.call.args = args;
        e->value.call.num_args = num_args;
        e->value.call.type_args = type_args;
        e->value.call.num_type_args = num_type_args;
        left = e;
    }
    /* postfix / 调用之后再接 as type（path[i] as i32、foo() as *u8） */
    return parse_as_chain(p, left);
}

/**
 * 解析一元表达式（unary）：可选前缀 - ~ ! 后接 unary；否则 postfix（含 primary 与 .field）。支持 -x、~a、!b、p.x。
 * 参数：p 解析器状态。返回值：成功返回 ASTExpr*；失败返回 NULL。副作用：成功时 advance。
 */
static ASTExpr *parse_unary(Parser *p) {
    TokenKind k = peek(p)->kind;
    /* await expr：仅 async function 内合法（typeck 校验）；codegen 暂等同 operand（无 CPS） */
    if (k == TOKEN_AWAIT) {
        int unary_line = peek(p)->line;
        int unary_col = peek(p)->col;
        advance(p);
        ASTExpr *inner = parse_unary(p);
        if (!inner) return NULL;
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) {
            ast_expr_free(inner);
            parser_oom(p);
            return NULL;
        }
        set_expr_loc_at(e, unary_line, unary_col);
        e->kind = AST_EXPR_AWAIT;
        e->value.unary.operand = inner;
        return e;
    }
    /* run async_fn()：sync 上下文经 scheduler drain（typeck 校验）；codegen → shux_async_sched_* */
    if (k == TOKEN_RUN) {
        int unary_line = peek(p)->line;
        int unary_col = peek(p)->col;
        advance(p);
        ASTExpr *inner = parse_unary(p);
        if (!inner) return NULL;
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) {
            ast_expr_free(inner);
            parser_oom(p);
            return NULL;
        }
        set_expr_loc_at(e, unary_line, unary_col);
        e->kind = AST_EXPR_RUN;
        e->value.unary.operand = inner;
        return e;
    }
    /* spawn async_fn(args)：非阻塞 submit（IO-A5 v4 并行 in-flight；须 drain_until_idle） */
    if (k == TOKEN_SPAWN) {
        int unary_line = peek(p)->line;
        int unary_col = peek(p)->col;
        advance(p);
        ASTExpr *inner = parse_unary(p);
        if (!inner) return NULL;
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) {
            ast_expr_free(inner);
            parser_oom(p);
            return NULL;
        }
        set_expr_loc_at(e, unary_line, unary_col);
        e->kind = AST_EXPR_SPAWN;
        e->value.unary.operand = inner;
        return e;
    }
    /* 一元 & 取址：&expr，用于传指针给 extern 函数（如 &out、&ctx） */
    if (k == TOKEN_AMP) {
        int unary_line = peek(p)->line;
        int unary_col = peek(p)->col;
        advance(p);
        ASTExpr *inner = parse_unary(p);
        if (!inner) return NULL;
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) {
            ast_expr_free(inner);
            parser_oom(p);
            return NULL;
        }
        set_expr_loc_at(e, unary_line, unary_col);
        e->kind = AST_EXPR_ADDR_OF;
        e->value.unary.operand = inner;
        return e;
    }
    /* 一元 * 解引用：*expr，操作数须为指针类型（如 map_i32_i32_slot(*m, key)） */
    if (k == TOKEN_STAR) {
        int unary_line = peek(p)->line;
        int unary_col = peek(p)->col;
        advance(p);
        ASTExpr *inner = parse_unary(p);
        if (!inner) return NULL;
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) {
            ast_expr_free(inner);
            parser_oom(p);
            return NULL;
        }
        set_expr_loc_at(e, unary_line, unary_col);
        e->kind = AST_EXPR_DEREF;
        e->value.unary.operand = inner;
        return e;
    }
    if (k == TOKEN_MINUS || k == TOKEN_TILDE || k == TOKEN_BANG) {
        int unary_line = peek(p)->line;
        int unary_col = peek(p)->col;
        advance(p);
        ASTExpr *inner = parse_unary(p);
        if (!inner) return NULL;
        ASTExpr *e = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!e) {
            ast_expr_free(inner);
            parser_oom(p);
            return NULL;
        }
        set_expr_loc_at(e, unary_line, unary_col);
        e->kind = (k == TOKEN_MINUS) ? AST_EXPR_NEG : (k == TOKEN_TILDE) ? AST_EXPR_BITNOT : AST_EXPR_LOGNOT;
        e->value.unary.operand = inner;
        return e;
    }
    return parse_postfix(p);
}

/**
 * 解析项（term）：unary 后接零个或多个 (STAR|SLASH unary)，左结合；乘除优先于加减。
 * 参数：p 解析器状态。返回值：成功返回 ASTExpr*；失败返回 NULL。副作用：成功时 advance。
 */
static ASTExpr *parse_term(Parser *p) {
    ASTExpr *left = parse_unary(p);
    if (!left) return NULL;
    for (;;) {
        const Token *t = peek(p);
        if (t->kind != TOKEN_STAR && t->kind != TOKEN_SLASH && t->kind != TOKEN_PERCENT)
            return left;
        int op = t->kind;
        advance(p);
        ASTExpr *right = parse_unary(p);
        if (!right) {
            ast_expr_free(left);
            return NULL;
        }
        ASTExpr *bin = (ASTExpr *)calloc(1, sizeof(ASTExpr));
        if (!bin) {
            ast_expr_free(left);
            ast_expr_free(right);
            parser_oom(p);
            return NULL;
        }
        set_expr_loc_at(bin, t->line, t->col);
        bin->kind = (op == TOKEN_STAR) ? AST_EXPR_MUL : (op == TOKEN_SLASH) ? AST_EXPR_DIV : AST_EXPR_MOD;
        bin->value.binop.left = left;
        bin->value.binop.right = right;
        left = bin;
    }
}

/** 辅助：用 left、right 与 kind 构建二元节点，失败时释放 left/right 并返回 NULL；line/col 为运算符位置。 */
static ASTExpr *parse_binop_right(Parser *p, ASTExpr *left, ASTExpr *right, int op, ASTExprKind kind, int line, int col) {
    (void)p;
    (void)op;
    ASTExpr *bin = (ASTExpr *)calloc(1, sizeof(ASTExpr));
    if (!bin) {
        ast_expr_free(left);
        ast_expr_free(right);
        parser_oom(p);
        return NULL;
    }
    set_expr_loc_at(bin, line, col);
    bin->kind = kind;
    bin->value.binop.left = left;
    bin->value.binop.right = right;
    return bin;
}

/** 加减：term (PLUS|MINUS term)* */
static ASTExpr *parse_addsub(Parser *p) {
    ASTExpr *left = parse_term(p);
    if (!left) return NULL;
    for (;;) {
        const Token *t = peek(p);
        if (t->kind != TOKEN_PLUS && t->kind != TOKEN_MINUS) return left;
        int op = t->kind;
        advance(p);
        ASTExpr *right = parse_term(p);
        if (!right) { ast_expr_free(left); return NULL; }
        left = parse_binop_right(p, left, right, op, (op == TOKEN_PLUS) ? AST_EXPR_ADD : AST_EXPR_SUB, t->line, t->col);
        if (!left) return NULL;
    }
}

/** 移位：addsub (LSHIFT|RSHIFT addsub)* */
static ASTExpr *parse_shift(Parser *p) {
    ASTExpr *left = parse_addsub(p);
    if (!left) return NULL;
    for (;;) {
        const Token *t = peek(p);
        if (t->kind != TOKEN_LSHIFT && t->kind != TOKEN_RSHIFT) return left;
        int op = t->kind;
        advance(p);
        ASTExpr *right = parse_addsub(p);
        if (!right) { ast_expr_free(left); return NULL; }
        left = parse_binop_right(p, left, right, op, (op == TOKEN_LSHIFT) ? AST_EXPR_SHL : AST_EXPR_SHR, t->line, t->col);
        if (!left) return NULL;
    }
}

/** 比较：shift (LT|LE|GT|GE shift)* */
static ASTExpr *parse_compare(Parser *p) {
    ASTExpr *left = parse_shift(p);
    if (!left) return NULL;
    for (;;) {
        const Token *t = peek(p);
        ASTExprKind k;
        if (t->kind == TOKEN_LT) k = AST_EXPR_LT;
        else if (t->kind == TOKEN_LE) k = AST_EXPR_LE;
        else if (t->kind == TOKEN_GT) k = AST_EXPR_GT;
        else if (t->kind == TOKEN_GE) k = AST_EXPR_GE;
        else return left;
        advance(p);
        ASTExpr *right = parse_shift(p);
        if (!right) { ast_expr_free(left); return NULL; }
        left = parse_binop_right(p, left, right, 0, k, t->line, t->col);
        if (!left) return NULL;
    }
}

/** 相等：compare (EQ|NE compare)* */
static ASTExpr *parse_eq(Parser *p) {
    ASTExpr *left = parse_compare(p);
    if (!left) return NULL;
    for (;;) {
        const Token *t = peek(p);
        if (t->kind != TOKEN_EQ && t->kind != TOKEN_NE) return left;
        int op = t->kind;
        advance(p);
        ASTExpr *right = parse_compare(p);
        if (!right) { ast_expr_free(left); return NULL; }
        left = parse_binop_right(p, left, right, op, (op == TOKEN_EQ) ? AST_EXPR_EQ : AST_EXPR_NE, t->line, t->col);
        if (!left) return NULL;
    }
}

/** 按位与：eq (AMP eq)* */
static ASTExpr *parse_bitand(Parser *p) {
    ASTExpr *left = parse_eq(p);
    if (!left) return NULL;
    for (;;) {
        const Token *t = peek(p);
        if (t->kind != TOKEN_AMP) return left;
        advance(p);
        ASTExpr *right = parse_eq(p);
        if (!right) { ast_expr_free(left); return NULL; }
        left = parse_binop_right(p, left, right, TOKEN_AMP, AST_EXPR_BITAND, t->line, t->col);
        if (!left) return NULL;
    }
}

/** 按位异或：bitand (CARET bitand)* */
static ASTExpr *parse_bitxor(Parser *p) {
    ASTExpr *left = parse_bitand(p);
    if (!left) return NULL;
    for (;;) {
        const Token *t = peek(p);
        if (t->kind != TOKEN_CARET) return left;
        advance(p);
        ASTExpr *right = parse_bitand(p);
        if (!right) { ast_expr_free(left); return NULL; }
        left = parse_binop_right(p, left, right, TOKEN_CARET, AST_EXPR_BITXOR, t->line, t->col);
        if (!left) return NULL;
    }
}

/** 按位或：bitxor (PIPE bitxor)* */
static ASTExpr *parse_bitor(Parser *p) {
    ASTExpr *left = parse_bitxor(p);
    if (!left) return NULL;
    for (;;) {
        const Token *t = peek(p);
        if (t->kind != TOKEN_PIPE) return left;
        advance(p);
        ASTExpr *right = parse_bitxor(p);
        if (!right) { ast_expr_free(left); return NULL; }
        left = parse_binop_right(p, left, right, TOKEN_PIPE, AST_EXPR_BITOR, t->line, t->col);
        if (!left) return NULL;
    }
}

/** 逻辑与：bitor (AMPAMP bitor)* */
static ASTExpr *parse_logand(Parser *p) {
    ASTExpr *left = parse_bitor(p);
    if (!left) return NULL;
    for (;;) {
        const Token *t = peek(p);
        if (t->kind != TOKEN_AMPAMP) return left;
        advance(p);
        ASTExpr *right = parse_bitor(p);
        if (!right) { ast_expr_free(left); return NULL; }
        left = parse_binop_right(p, left, right, TOKEN_AMPAMP, AST_EXPR_LOGAND, t->line, t->col);
        if (!left) return NULL;
    }
}

/** 逻辑或：logand (PIPEPIPE logand)* */
static ASTExpr *parse_logor(Parser *p) {
    ASTExpr *left = parse_logand(p);
    if (!left) return NULL;
    for (;;) {
        const Token *t = peek(p);
        if (t->kind != TOKEN_PIPEPIPE) return left;
        advance(p);
        ASTExpr *right = parse_logand(p);
        if (!right) { ast_expr_free(left); return NULL; }
        left = parse_binop_right(p, left, right, TOKEN_PIPEPIPE, AST_EXPR_LOGOR, t->line, t->col);
        if (!left) return NULL;
    }
}

/**
 * 三元运算符：logor ('?' expr ':' ternary)?，右结合；cond ? then : else。
 * 参数：p 解析器状态。返回值：成功返回 ASTExpr*；失败返回 NULL。
 */
static ASTExpr *parse_ternary(Parser *p) {
    ASTExpr *cond = parse_logor(p);
    if (!cond) return NULL;
    if (peek(p)->kind != TOKEN_QUESTION) return cond;
    advance(p);  /* consume ? */
    ASTExpr *then_expr = parse_expr(p);
    if (!then_expr) { ast_expr_free(cond); return NULL; }
    if (peek(p)->kind != TOKEN_COLON) {
        ast_expr_free(cond);
        ast_expr_free(then_expr);
        fail(p, "expected ':' in ternary operator");
        return NULL;
    }
    advance(p);  /* consume : */
    ASTExpr *else_expr = parse_ternary(p);
    if (!else_expr) {
        ast_expr_free(cond);
        ast_expr_free(then_expr);
        return NULL;
    }
    ASTExpr *e = (ASTExpr *)malloc(sizeof(ASTExpr));
    if (!e) {
        ast_expr_free(cond);
        ast_expr_free(then_expr);
        ast_expr_free(else_expr);
        parser_oom(p);
        return NULL;
    }
    e->kind = AST_EXPR_TERNARY;
    e->resolved_type = NULL;
    e->value.if_expr.cond = cond;
    e->value.if_expr.then_expr = then_expr;
    e->value.if_expr.else_expr = else_expr;
    return e;
}

/**
 * 判断表达式是否为可赋值的左值（变量、下标、结构体字段；枚举变体访问不可赋值）。
 * 用于赋值表达式解析：仅左值为合法左值时才接受 = right。
 */
static int expr_is_lvalue(const ASTExpr *e) {
    if (!e) return 0;
    switch (e->kind) {
        case AST_EXPR_VAR:
            return 1;
        case AST_EXPR_INDEX:
            return 1;
        case AST_EXPR_DEREF:
            return 1;  /* *ptr = val：解引用为可赋左值（K2b / 内核 MMIO 写） */
        case AST_EXPR_FIELD_ACCESS:
            return !e->value.field_access.is_enum_variant;  /* 结构体字段可赋，枚举变体不可 */
        default:
            return 0;
    }
}

/** 复合赋值 token 到 AST 节点 kind 的映射；用于 parse_assign。 */
static ASTExprKind compound_assign_token_to_kind(TokenKind k) {
    switch (k) {
        case TOKEN_PLUS_EQ:   return AST_EXPR_ADD_ASSIGN;
        case TOKEN_MINUS_EQ:  return AST_EXPR_SUB_ASSIGN;
        case TOKEN_STAR_EQ:   return AST_EXPR_MUL_ASSIGN;
        case TOKEN_SLASH_EQ:  return AST_EXPR_DIV_ASSIGN;
        case TOKEN_PERCENT_EQ: return AST_EXPR_MOD_ASSIGN;
        case TOKEN_AMP_EQ:    return AST_EXPR_BITAND_ASSIGN;
        case TOKEN_PIPE_EQ:   return AST_EXPR_BITOR_ASSIGN;
        case TOKEN_CARET_EQ:  return AST_EXPR_BITXOR_ASSIGN;
        case TOKEN_LSHIFT_EQ: return AST_EXPR_SHL_ASSIGN;
        case TOKEN_RSHIFT_EQ: return AST_EXPR_SHR_ASSIGN;
        default:              return AST_EXPR_ASSIGN;
    }
}

/** 判断是否为复合赋值 token。 */
static int is_compound_assign_token(TokenKind k) {
    return k == TOKEN_PLUS_EQ || k == TOKEN_MINUS_EQ || k == TOKEN_STAR_EQ || k == TOKEN_SLASH_EQ
        || k == TOKEN_PERCENT_EQ || k == TOKEN_AMP_EQ || k == TOKEN_PIPE_EQ || k == TOKEN_CARET_EQ
        || k == TOKEN_LSHIFT_EQ || k == TOKEN_RSHIFT_EQ;
}

/**
 * 赋值层：ternary ( ( '=' | '+=' | '-=' | ... ) assign )?，右结合；仅当左侧为左值时才接受 = 或 op=。
 * 用于 for 的 step（如 i += 1、i = i + 1）及赋值表达式。
 */
static ASTExpr *parse_assign(Parser *p) {
    ASTExpr *left = parse_ternary(p);
    if (!left) return NULL;
    TokenKind t = peek(p)->kind;
    if (t == TOKEN_ASSIGN || is_compound_assign_token(t)) {
        if (!expr_is_lvalue(left))
            return left;
        advance(p);
        /* 右侧用 parse_ternary 以便含加减等；a = b = c 时右侧会再遇 = 由 parse_assign 解析为 b = c */
        ASTExpr *right = parse_ternary(p);
        if (!right) {
            ast_expr_free(left);
            return NULL;
        }
        ASTExpr *e = (ASTExpr *)malloc(sizeof(ASTExpr));
        if (!e) {
            ast_expr_free(left);
            ast_expr_free(right);
            parser_oom(p);
            return NULL;
        }
        e->kind = (t == TOKEN_ASSIGN) ? AST_EXPR_ASSIGN : compound_assign_token_to_kind(t);
        e->resolved_type = NULL;
        e->value.binop.left = left;
        e->value.binop.right = right;
        return e;
    }
    return left;
}

/**
 * 解析表达式（入口）；赋值层 + 三元层，支持 x = expr 与 cond ? then : else 及全运算符。
 * 参数：p 解析器状态。返回值：成功返回 ASTExpr*；失败返回 NULL。副作用：成功时 advance。
 */
static ASTExpr *parse_expr(Parser *p) {
    return parse_assign(p);
}

/** 最大 import 数量 */
#define MAX_IMPORTS 32
/** 顶层 let 最大数量（std/fs/posix.sx 等超 32 项 const/let，自举前须 ≥64） */
#define MAX_TOP_LEVEL_LETS 128
/** 顶层最大 struct 定义数 */
#define MAX_STRUCTS 16
/** 顶层最大 enum 定义数 */
#define MAX_ENUMS 16
/** 单 struct 定义最大字段数（parse_one_struct 用） */
/** 自举用：ast.sx 的 Expr 等结构体字段数超 32，故提高上限 */
#define MAX_STRUCT_FIELDS_DEF 64
/** 单 enum 定义最大变体数（自举 9.1：TokenKind 等超 32 项，故提高上限） */
#define MAX_ENUM_VARIANTS 128
/** 块内最大 const/let 声明数（自举用：parser.sx 的 parse_one_function 单块内 let 超 32，故提高上限） */
#define MAX_CONST_DECLS 256
#define MAX_LET_DECLS 256
/** 块内最大 while 循环数 */
#define MAX_WHILE_LOOPS 32
#define MAX_REGION_BLOCKS 32
#define MAX_FOR_LOOPS 32
#define MAX_DEFERS 16
#define MAX_LABELED_STMTS 32
#define MAX_EXPR_STMTS 512

/**
 * 解析 import("path")：当前 Token 须为 '('；返回 strdup 的路径字符串。
 */
static char *parse_import_call_path(Parser *p) {
    if (peek(p)->kind != TOKEN_LPAREN) {
        fail(p, "expected '(' after import");
        return NULL;
    }
    advance(p);
    if (peek(p)->kind != TOKEN_STRING) {
        fail(p, "expected string literal in import(\"path\")");
        return NULL;
    }
    const Token *t = peek(p);
    char *path = (t->ident_len > 0 && t->value.ident)
        ? strndup(t->value.ident, (size_t)t->ident_len) : NULL;
    if (!path) {
        fail(p, "import path string empty");
        return NULL;
    }
    advance(p);
    if (peek(p)->kind != TOKEN_RPAREN) {
        free(path);
        fail(p, "expected ')' after import path string");
        return NULL;
    }
    advance(p);
    return path;
}

/**
 * 解析单条结构体定义：struct Name { field : Type ; ... }。
 * 参数：p 解析器状态；当前 Token 须为 TOKEN_STRUCT；allow_padding 为 1 表示该 struct 前有 allow(padding)。返回值：成功返回新分配的 ASTStructDef*（调用方须通过 ast_struct_def_free 释放）；失败返回 NULL 且已 fail。
 */
static ASTStructDef *parse_one_struct(Parser *p, int allow_padding, int force_soa, int force_repr_c, int force_repr_compatible) {
    if (peek(p)->kind != TOKEN_STRUCT) return NULL;
    advance(p);
    if (peek(p)->kind != TOKEN_IDENT) {
        fail(p, "expected struct name after 'struct'");
        return NULL;
    }
    char *name = strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len);
    if (!name) {
        parser_oom(p);
        return NULL;
    }
    advance(p);
    /* 可选泛型参数：struct Name < T (, U)* > { ... }（阶段 7.1） */
    char **gp_names = NULL;
    int n_gp = 0;
    if (parse_generic_param_list(p, &gp_names, &n_gp) != 0) {
        free(name);
        return NULL;
    }
    /* 可选 packed / soa：struct Name packed|soa { ... } 或 `#[soa] struct Name { }`（force_soa）。 */
    int is_packed = 0;
    int is_soa = force_soa;
    if (peek(p)->kind == TOKEN_PACKED) {
        is_packed = 1;
        advance(p);
    } else if (peek(p)->kind == TOKEN_SOA) {
        is_soa = 1;
        advance(p);
    }
    if (is_packed && is_soa) {
        free(name);
        if (gp_names) { for (int i = 0; i < n_gp; i++) free(gp_names[i]); free(gp_names); }
        fail(p, "struct cannot be both packed and soa");
        return NULL;
    }
    if (peek(p)->kind != TOKEN_LBRACE) {
        free(name);
        if (gp_names) { for (int i = 0; i < n_gp; i++) free(gp_names[i]); free(gp_names); }
        fail(p, "expected '{' after struct name");
        return NULL;
    }
    advance(p);
    ASTStructField *fields = (ASTStructField *)malloc((size_t)MAX_STRUCT_FIELDS_DEF * sizeof(ASTStructField));
    if (!fields) {
        free(name);
        if (gp_names) { for (int i = 0; i < n_gp; i++) free(gp_names[i]); free(gp_names); }
        parser_oom(p);
        return NULL;
    }
    int num_fields = 0;
    int field_aligns[MAX_STRUCT_FIELDS_DEF];
    memset(field_aligns, 0, sizeof(field_aligns));
    while (peek(p)->kind != TOKEN_RBRACE) {
        if (num_fields >= MAX_STRUCT_FIELDS_DEF) {
            fail(p, "too many struct fields");
            goto struct_fail;
        }
        /** DOD-CL：可选 align(N) 前缀。 */
        int field_min_align = 0;
        if (peek(p)->kind == TOKEN_ALIGN) {
            advance(p);
            if (peek(p)->kind != TOKEN_LPAREN) {
                fail(p, "expected '(' after align");
                if (parser_recovery_enabled()) { parser_recover_struct_field_boundary(p); continue; }
                goto struct_fail;
            }
            advance(p);
            if (peek(p)->kind != TOKEN_INT || peek(p)->value.int_val <= 0) {
                fail(p, "expected positive integer in align(N)");
                if (parser_recovery_enabled()) { parser_recover_struct_field_boundary(p); continue; }
                goto struct_fail;
            }
            field_min_align = peek(p)->value.int_val;
            advance(p);
            if (peek(p)->kind != TOKEN_RPAREN) {
                fail(p, "expected ')' after align(N)");
                if (parser_recovery_enabled()) { parser_recover_struct_field_boundary(p); continue; }
                goto struct_fail;
            }
            advance(p);
        }
        char *fname = parser_struct_field_name_dup(p);
        if (!fname) {
            fail(p, "expected field name in struct");
            if (parser_recovery_enabled()) { parser_recover_struct_field_boundary(p); continue; }
            goto struct_fail;
        }
        if (peek(p)->kind != TOKEN_COLON) {
            free(fname);
            fail(p, "expected ':' after field name");
            if (parser_recovery_enabled()) { parser_recover_struct_field_boundary(p); continue; }
            goto struct_fail;
        }
        advance(p);
        ASTType *ty = parse_type(p);
        if (!ty) {
            free(fname);
            if (parser_recovery_enabled()) { parser_recover_struct_field_boundary(p); continue; }
            goto struct_fail;
        }
        fields[num_fields].name = fname;
        fields[num_fields].type = ty;
        fields[num_fields].bitfield_width = 0;
        field_aligns[num_fields] = field_min_align;
        /* Optional bitfield width: ": N" after type */
        if (peek(p)->kind == TOKEN_COLON) {
            advance(p);
            if (peek(p)->kind != TOKEN_INT || peek(p)->value.int_val <= 0) {
                fail(p, "expected positive integer for bitfield width");
                if (parser_recovery_enabled()) { parser_recover_struct_field_boundary(p); continue; }
                goto struct_fail;
            }
            fields[num_fields].bitfield_width = (int)peek(p)->value.int_val;
            advance(p);
        }
        num_fields++;
        if (peek(p)->kind == TOKEN_SEMICOLON) advance(p);
    }
    advance(p); /* consume RBRACE */
    if (fail_if_semicolon_after_brace(p) != 0)
        goto struct_fail;
    ASTStructDef *s = (ASTStructDef *)malloc(sizeof(ASTStructDef));
    if (!s) {
        parser_oom(p);
        goto struct_fail;
    }
    memset(s, 0, sizeof(*s));
    s->name = name;
    s->generic_param_names = gp_names;
    s->num_generic_params = n_gp;
    s->fields = fields;
    s->num_fields = num_fields;
    s->allow_padding = allow_padding;
    s->repr_c = force_repr_c;
    s->repr_compatible = force_repr_compatible;
    s->packed = is_packed;
    s->soa = is_soa;
    for (int fi = 0; fi < num_fields && fi < AST_STRUCT_MAX_FIELDS; fi++)
        s->field_min_align[fi] = field_aligns[fi];
    return s;

struct_fail:
    free(name);
    if (gp_names) { for (int i = 0; i < n_gp; i++) free(gp_names[i]); free(gp_names); }
    for (int i = 0; i < num_fields; i++) {
        free((void *)fields[i].name);
        ast_type_free(fields[i].type);
    }
    free(fields);
    return NULL;
}

/**
 * 解析单条枚举定义：enum Name { A, B, C }（无负载枚举，§7.4）。
 * 参数：p 解析器状态；当前 Token 须为 TOKEN_ENUM。返回值：成功返回新分配的 ASTEnumDef*（调用方须通过 ast_enum_def_free 释放）；失败返回 NULL 且已 fail。
 */
static ASTEnumDef *parse_one_enum(Parser *p) {
    if (peek(p)->kind != TOKEN_ENUM) return NULL;
    advance(p);
    if (peek(p)->kind != TOKEN_IDENT) {
        fail(p, "expected enum name after 'enum'");
        return NULL;
    }
    char *name = strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len);
    if (!name) { parser_oom(p); return NULL; }
    advance(p);
    if (peek(p)->kind != TOKEN_LBRACE) {
        free(name);
        fail(p, "expected '{' after enum name");
        return NULL;
    }
    advance(p);
    char **variants = (char **)malloc((size_t)MAX_ENUM_VARIANTS * sizeof(char *));
    if (!variants) { free(name); parser_oom(p); return NULL; }
    int num_variants = 0;
    while (peek(p)->kind != TOKEN_RBRACE) {
        if (num_variants >= MAX_ENUM_VARIANTS) {
            fail(p, "too many enum variants");
            goto enum_fail;
        }
        if (peek(p)->kind != TOKEN_IDENT) {
            fail(p, "expected variant name in enum");
            if (parser_recovery_enabled()) { parser_recover_enum_variant_boundary(p); continue; }
            goto enum_fail;
        }
        variants[num_variants] = strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len);
        if (!variants[num_variants]) {
            parser_oom(p);
            goto enum_fail;
        }
        num_variants++;
        advance(p);
        if (peek(p)->kind == TOKEN_COMMA) advance(p);
    }
    advance(p); /* consume RBRACE */
    if (fail_if_semicolon_after_brace(p) != 0)
        goto enum_fail;
    ASTEnumDef *e = (ASTEnumDef *)malloc(sizeof(ASTEnumDef));
    if (!e) {
        parser_oom(p);
        goto enum_fail;
    }
    e->name = name;
    e->variant_names = variants;
    e->num_variants = num_variants;
    return e;

enum_fail:
    free(name);
    for (int i = 0; i < num_variants; i++) free((void *)variants[i]);
    free(variants);
    return NULL;
}

/** 解析 trait 内单条方法签名：function method_name ( self ) -> type ;（阶段 7.2） */
static ASTTraitMethod *parse_trait_method_sig(Parser *p) {
    if (peek(p)->kind != TOKEN_FUNCTION) return NULL;
    advance(p);
    if (peek(p)->kind != TOKEN_IDENT) { fail(p, "expected method name in trait"); return NULL; }
    char *name = strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len);
    if (!name) { parser_oom(p); return NULL; }
    advance(p);
    if (peek(p)->kind != TOKEN_LPAREN) { free(name); fail(p, "expected '(' in trait method"); return NULL; }
    advance(p);
    if (peek(p)->kind != TOKEN_SELF) { free(name); fail(p, "trait method must have (self)"); return NULL; }
    advance(p);
    if (peek(p)->kind != TOKEN_RPAREN) { free(name); fail(p, "expected ')' after self"); return NULL; }
    advance(p);
    if (peek(p)->kind != TOKEN_COLON) { free(name); fail(p, "expected ':' for return type in trait method"); return NULL; }
    advance(p);
    ASTType *ret = parse_type(p);
    if (!ret) { free(name); return NULL; }
    if (peek(p)->kind != TOKEN_SEMICOLON) { free(name); ast_type_free(ret); fail(p, "expected ';' after trait method"); return NULL; }
    advance(p);
    ASTTraitMethod *m = (ASTTraitMethod *)malloc(sizeof(ASTTraitMethod));
    if (!m) { free(name); ast_type_free(ret); return NULL; }
    m->name = name;
    m->return_type = ret;
    return m;
}

/**
 * 解析单条 trait 定义：trait Name { function method(self) -> type ; ... }（阶段 7.2）。
 */
static ASTTraitDef *parse_one_trait(Parser *p) {
    if (peek(p)->kind != TOKEN_TRAIT) return NULL;
    advance(p);
    if (peek(p)->kind != TOKEN_IDENT) { fail(p, "expected trait name after 'trait'"); return NULL; }
    char *name = strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len);
    if (!name) { parser_oom(p); return NULL; }
    advance(p);
    if (peek(p)->kind != TOKEN_LBRACE) { free(name); fail(p, "expected '{' after trait name"); return NULL; }
    advance(p);
    ASTTraitMethod *methods = (ASTTraitMethod *)malloc((size_t)AST_TRAIT_MAX_METHODS * sizeof(ASTTraitMethod));
    if (!methods) { free(name); parser_oom(p); return NULL; }
    int num_methods = 0;
    while (peek(p)->kind != TOKEN_RBRACE) {
        if (num_methods >= AST_TRAIT_MAX_METHODS) {
            fail(p, "too many methods in trait");
            goto trait_fail;
        }
        ASTTraitMethod *m = parse_trait_method_sig(p);
        if (!m) {
            if (parser_recovery_enabled()) { parser_recover_trait_method_boundary(p); continue; }
            goto trait_fail;
        }
        methods[num_methods++] = *m;
        free(m);
    }
    advance(p); /* consume RBRACE */
    if (fail_if_semicolon_after_brace(p) != 0)
        goto trait_fail;
    ASTTraitDef *t = (ASTTraitDef *)malloc(sizeof(ASTTraitDef));
    if (!t) {
        parser_oom(p);
        goto trait_fail;
    }
    t->name = name;
    t->methods = methods;
    t->num_methods = num_methods;
    return t;

trait_fail:
    free(name);
    for (int i = 0; i < num_methods; i++) { free((void *)methods[i].name); ast_type_free(methods[i].return_type); }
    free(methods);
    return NULL;
}

/** 将当前 token 解析为类型名字符串（用于 impl for Type 的 Type）；仅接受单 token 类型名。 */
static char *parse_type_name_ident(Parser *p) {
    if (peek(p)->kind == TOKEN_IDENT) return strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len);
    if (peek(p)->kind == TOKEN_I32) return strdup("i32");
    if (peek(p)->kind == TOKEN_BOOL) return strdup("bool");
    if (peek(p)->kind == TOKEN_U8) return strdup("u8");
    if (peek(p)->kind == TOKEN_U32) return strdup("u32");
    if (peek(p)->kind == TOKEN_U64) return strdup("u64");
    if (peek(p)->kind == TOKEN_I64) return strdup("i64");
    if (peek(p)->kind == TOKEN_USIZE) return strdup("usize");
    if (peek(p)->kind == TOKEN_ISIZE) return strdup("isize");
    if (peek(p)->kind == TOKEN_F32) return strdup("f32");
    if (peek(p)->kind == TOKEN_F64) return strdup("f64");
    return NULL;
}

/**
 * 解析 impl 块内单条方法：function name ( self : TypeName , ... ) -> type { block }（阶段 7.2）。
 * 返回的 ASTFunc 已设置 impl_for_trait 与 impl_for_type。
 */
static ASTFunc *parse_impl_method(Parser *p, const char *trait_name, const char *type_name) {
    if (peek(p)->kind != TOKEN_FUNCTION) return NULL;
    advance(p);
    if (peek(p)->kind != TOKEN_IDENT) { fail(p, "expected method name in impl"); return NULL; }
    char *meth_name = strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len);
    if (!meth_name) { parser_oom(p); return NULL; }
    advance(p);
    if (peek(p)->kind != TOKEN_LPAREN) { free(meth_name); fail(p, "expected '(' in impl method"); return NULL; }
    advance(p);
    if (peek(p)->kind != TOKEN_SELF) { free(meth_name); fail(p, "impl method first param must be self"); return NULL; }
    advance(p);
    if (peek(p)->kind != TOKEN_COLON) { free(meth_name); fail(p, "expected ':' after self"); return NULL; }
    advance(p);
    ASTType *self_type = parse_type_name(p);
    if (!self_type) { free(meth_name); return NULL; }
    int params_cap = AST_FUNC_PARAMS_INIT;
    ASTParam *params = (ASTParam *)malloc((size_t)params_cap * sizeof(ASTParam));
    if (!params) { free(meth_name); ast_type_free(self_type); parser_oom(p); return NULL; }
    (void)memset(params, 0, (size_t)params_cap * sizeof(ASTParam));
    params[0].name = strdup("self");
    params[0].type = self_type;
    int num_params = 1;
    while (peek(p)->kind == TOKEN_COMMA) {
        advance(p);
        ASTParam *np = parser_grow_params(params, &params_cap, num_params + 1);
        if (!np) {
            free(meth_name);
            for (int j = 0; j < num_params; j++) { free((void *)params[j].name); ast_type_free(params[j].type); }
            free(params);
            parser_oom(p);
            return NULL;
        }
        params = np;
        if (peek(p)->kind != TOKEN_IDENT) {
            free(meth_name);
            for (int j = 0; j < num_params; j++) { free((void *)params[j].name); ast_type_free(params[j].type); }
            free(params);
            fail(p, "expected param name");
            return NULL;
        }
        char *pname = strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len);
        if (!pname) {
            free(meth_name);
            for (int j = 0; j < num_params; j++) { free((void *)params[j].name); ast_type_free(params[j].type); }
            free(params);
            return NULL;
        }
        advance(p);
        if (peek(p)->kind != TOKEN_COLON) {
            free(pname); free(meth_name);
            for (int j = 0; j < num_params; j++) { free((void *)params[j].name); ast_type_free(params[j].type); }
            free(params);
            fail(p, "expected ':' after param name");
            return NULL;
        }
        advance(p);
        ASTType *pty = parse_type(p);
        if (!pty) {
            free(pname); free(meth_name);
            for (int j = 0; j < num_params; j++) { free((void *)params[j].name); ast_type_free(params[j].type); }
            free(params);
            return NULL;
        }
        params[num_params].name = pname;
        params[num_params].type = pty;
        num_params++;
    }
    if (peek(p)->kind != TOKEN_RPAREN) {
        free(meth_name);
        for (int j = 0; j < num_params; j++) { free((void *)params[j].name); ast_type_free(params[j].type); }
        free(params);
        fail(p, "expected ')' after params");
        return NULL;
    }
    advance(p);
    if (peek(p)->kind != TOKEN_COLON) {
        free(meth_name);
        for (int j = 0; j < num_params; j++) { free((void *)params[j].name); ast_type_free(params[j].type); }
        free(params);
        fail(p, "expected ':' for return type in impl method");
        return NULL;
    }
    advance(p);
    ASTType *ret = parse_type(p);
    if (!ret) {
        free(meth_name);
        for (int j = 0; j < num_params; j++) { free((void *)params[j].name); ast_type_free(params[j].type); }
        free(params);
        return NULL;
    }
    if (peek(p)->kind != TOKEN_LBRACE) {
        free(meth_name); ast_type_free(ret);
        for (int j = 0; j < num_params; j++) { free((void *)params[j].name); ast_type_free(params[j].type); }
        free(params);
        fail(p, "expected '{' for impl method body");
        return NULL;
    }
    advance(p);  /* consume '{' before block body */
    ASTBlock *body = parse_block(p, 1, 1);
    if (!body) {
        free(meth_name); ast_type_free(ret);
        for (int j = 0; j < num_params; j++) { free((void *)params[j].name); ast_type_free(params[j].type); }
        free(params);
        return NULL;
    }
    ASTFunc *f = (ASTFunc *)malloc(sizeof(ASTFunc));
    if (!f) {
        free(meth_name); ast_type_free(ret); ast_block_free(body);
        for (int j = 0; j < num_params; j++) { free((void *)params[j].name); ast_type_free(params[j].type); }
        free(params);
        return NULL;
    }
    f->name = meth_name;
    f->generic_param_names = NULL;
    f->section = NULL;  /* K4b：impl 方法无段属性 */
    f->is_entry = 0;  /* K5：impl 方法非入口 */
    f->is_used = 0;  /* K10：impl 方法无 used */
    f->num_generic_params = 0;
    f->params = params;
    f->num_params = num_params;
    f->return_type = ret;
    f->body = body;
    f->is_extern = 0;
    f->impl_for_trait = trait_name;
    f->impl_for_type = type_name;
    return f;
}

/**
 * 解析单条 impl 块：impl TraitName for TypeName { function method(...) { ... } ... }（阶段 7.2）。
 */
static ASTImplBlock *parse_one_impl(Parser *p) {
    if (peek(p)->kind != TOKEN_IMPL) return NULL;
    advance(p);
    if (peek(p)->kind != TOKEN_IDENT) { fail(p, "expected trait name after 'impl'"); return NULL; }
    char *trait_name = strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len);
    if (!trait_name) { parser_oom(p); return NULL; }
    advance(p);
    if (peek(p)->kind != TOKEN_FOR) { free(trait_name); fail(p, "expected 'for' after trait name"); return NULL; }
    advance(p);
    char *type_name = parse_type_name_ident(p);
    if (!type_name) { free(trait_name); fail(p, "expected type name after 'for'"); return NULL; }
    advance(p); /* consume the type token */
    if (peek(p)->kind != TOKEN_LBRACE) { free(trait_name); free(type_name); fail(p, "expected '{' after impl for type"); return NULL; }
    advance(p);
    ASTFunc **funcs = (ASTFunc **)malloc((size_t)AST_MODULE_FUNCS_INIT * sizeof(ASTFunc *));
    int funcs_cap = AST_MODULE_FUNCS_INIT;
    if (!funcs) { free(trait_name); free(type_name); parser_oom(p); return NULL; }
    int nfuncs = 0;
    while (peek(p)->kind != TOKEN_RBRACE) {
        if (peek(p)->kind != TOKEN_FUNCTION) {
            fail(p, "expected function in impl block");
            if (parser_recovery_enabled()) { parser_recover_impl_method_boundary(p); continue; }
            goto impl_fail;
        }
        ASTFunc *meth = parse_impl_method(p, trait_name, type_name);
        if (!meth) {
            if (parser_recovery_enabled()) { parser_recover_impl_method_boundary(p); continue; }
            goto impl_fail;
        }
        if (nfuncs >= funcs_cap) {
            ASTFunc **nf = parser_grow_func_ptrs(funcs, &funcs_cap, nfuncs + 1);
            if (!nf) {
                free((void *)meth->name); if (meth->params) { for (int j = 0; j < meth->num_params; j++) { free((void *)meth->params[j].name); ast_type_free(meth->params[j].type); } free(meth->params); }
                ast_type_free(meth->return_type); ast_block_free(meth->body); free(meth);
                free(trait_name); free(type_name);
                for (int i = 0; i < nfuncs; i++) {
                    ASTFunc *f = funcs[i];
                    if (f->name) free((void *)f->name);
                    if (f->params) { for (int j = 0; j < f->num_params; j++) { free((void *)f->params[j].name); ast_type_free(f->params[j].type); } free(f->params); }
                    if (f->return_type) ast_type_free(f->return_type);
                    if (f->body) ast_block_free(f->body);
                    free(f);
                }
                free(funcs);
                fail(p, "out of memory growing impl method list");
                return NULL;
            }
            funcs = nf;
        }
        funcs[nfuncs++] = meth;
    }
    advance(p); /* consume RBRACE */
    if (fail_if_semicolon_after_brace(p) != 0)
        goto impl_fail;
    ASTImplBlock *impl = (ASTImplBlock *)malloc(sizeof(ASTImplBlock));
    if (!impl) {
        parser_oom(p);
        goto impl_fail;
    }
    impl->trait_name = trait_name;
    impl->type_name = type_name;
    impl->funcs = funcs;
    impl->num_funcs = nfuncs;
    return impl;

impl_fail:
        free(trait_name); free(type_name);
        for (int i = 0; i < nfuncs; i++) {
            ASTFunc *f = funcs[i];
            if (f->name) free((void *)f->name);
            if (f->params) { for (int j = 0; j < f->num_params; j++) { free((void *)f->params[j].name); ast_type_free(f->params[j].type); } free(f->params); }
            if (f->return_type) ast_type_free(f->return_type);
            if (f->body) ast_block_free(f->body);
            free(f);
        }
        free(funcs);
    return NULL;
}

/** 将一条语句顺序追加到块 b；kind 0=const, 1=let, 2=expr_stmt, 3=loop, 4=for；idx 为对应数组下标。 */
static void push_stmt_order(ASTBlock *b, int kind, int idx) {
    if (b->num_stmt_order < MAX_BLOCK_STMT_ORDER) {
        b->stmt_order[b->num_stmt_order].kind = (unsigned char)kind;
        b->stmt_order[b->num_stmt_order].idx = idx;
        b->num_stmt_order++;
    }
}

/**
 * B-02：将 src 块语句扁平并入 dst（#[cfg] 匹配时函数体内 { ... } 内联）。
 * 转移子 AST 所有权；成功后 src 仅余空壳，可 ast_block_free。
 */
static int ast_block_flatten_into(ASTBlock *dst, ASTBlock *src) {
    int i;
    int base_const;
    int base_let;
    int base_expr;
    int base_loop;
    int base_for;
    int base_region;
    if (!dst || !src)
        return -1;
    base_const = dst->num_consts;
    for (i = 0; i < src->num_consts; i++) {
        if (dst->num_consts >= MAX_CONST_DECLS)
            return -1;
        dst->const_decls[dst->num_consts++] = src->const_decls[i];
    }
    base_let = dst->num_lets;
    for (i = 0; i < src->num_lets; i++) {
        if (dst->num_lets >= MAX_LET_DECLS)
            return -1;
        dst->let_decls[dst->num_lets++] = src->let_decls[i];
    }
    base_expr = dst->num_expr_stmts;
    if (src->num_expr_stmts > 0) {
        if (!dst->expr_stmts) {
            dst->expr_stmts = (ASTExpr **)malloc((size_t)MAX_EXPR_STMTS * sizeof(ASTExpr *));
            if (!dst->expr_stmts)
                return -1;
        }
        for (i = 0; i < src->num_expr_stmts; i++) {
            if (dst->num_expr_stmts >= MAX_EXPR_STMTS)
                return -1;
            dst->expr_stmts[dst->num_expr_stmts++] = src->expr_stmts[i];
        }
    }
    base_loop = dst->num_loops;
    if (src->num_loops > 0) {
        ASTWhileLoop *new_loops;
        int new_n = dst->num_loops + src->num_loops;
        new_loops = (ASTWhileLoop *)realloc(dst->loops, (size_t)new_n * sizeof(ASTWhileLoop));
        if (!new_loops)
            return -1;
        dst->loops = new_loops;
        for (i = 0; i < src->num_loops; i++)
            dst->loops[dst->num_loops + i] = src->loops[i];
        dst->num_loops = new_n;
    }
    base_for = dst->num_for_loops;
    if (src->num_for_loops > 0) {
        ASTForLoop *new_fors;
        int new_n = dst->num_for_loops + src->num_for_loops;
        new_fors = (ASTForLoop *)realloc(dst->for_loops, (size_t)new_n * sizeof(ASTForLoop));
        if (!new_fors)
            return -1;
        dst->for_loops = new_fors;
        for (i = 0; i < src->num_for_loops; i++)
            dst->for_loops[dst->num_for_loops + i] = src->for_loops[i];
        dst->num_for_loops = new_n;
    }
    base_region = dst->num_regions;
    if (src->num_regions > 0) {
        ASTRegionBlock *new_regs;
        int new_n = dst->num_regions + src->num_regions;
        new_regs = (ASTRegionBlock *)realloc(dst->regions, (size_t)new_n * sizeof(ASTRegionBlock));
        if (!new_regs)
            return -1;
        dst->regions = new_regs;
        for (i = 0; i < src->num_regions; i++)
            dst->regions[dst->num_regions + i] = src->regions[i];
        dst->num_regions = new_n;
    }
    if (src->final_expr) {
        if (!dst->final_expr)
            dst->final_expr = src->final_expr;
        else {
            if (!dst->expr_stmts) {
                dst->expr_stmts = (ASTExpr **)malloc((size_t)MAX_EXPR_STMTS * sizeof(ASTExpr *));
                if (!dst->expr_stmts)
                    return -1;
            }
            if (dst->num_expr_stmts >= MAX_EXPR_STMTS)
                return -1;
            dst->expr_stmts[dst->num_expr_stmts++] = dst->final_expr;
            push_stmt_order(dst, 2, dst->num_expr_stmts - 1);
            dst->final_expr = src->final_expr;
        }
    }
    for (i = 0; i < src->num_stmt_order; i++) {
        int k = (int)src->stmt_order[i].kind;
        int idx = src->stmt_order[i].idx;
        switch (k) {
        case 0: idx += base_const; break;
        case 1: idx += base_let; break;
        case 2: idx += base_expr; break;
        case 3: idx += base_loop; break;
        case 4: idx += base_for; break;
        case 5: idx += base_region; break;
        default: break;
        }
        push_stmt_order(dst, k, idx);
    }
    src->num_consts = 0;
    src->num_lets = 0;
    src->num_expr_stmts = 0;
    src->expr_stmts = NULL;
    src->num_loops = 0;
    src->loops = NULL;
    src->num_for_loops = 0;
    src->for_loops = NULL;
    src->num_regions = 0;
    src->regions = NULL;
    src->final_expr = NULL;
    src->num_stmt_order = 0;
    return 0;
}

/**
 * 解析单条 const 或 let 并追加到块 b；当前 token 须为 TOKEN_CONST 或 TOKEN_LET。
 * 返回值：1 表示已解析并追加一条，0 表示当前不是 const/let，2 表示已报错并恢复到下一语句，-1 表示致命失败。
 */
static int parse_one_const_or_let(Parser *p, ASTBlock *b) {
    if (peek(p)->kind == TOKEN_CONST) {
        if (b->num_consts >= MAX_CONST_DECLS) { fail(p, "too many const declarations"); ast_block_free(b); return -1; }
        advance(p);
        if (peek(p)->kind != TOKEN_IDENT && peek(p)->kind != TOKEN_I32) {
            fail(p, "expected identifier after const");
            if (parser_recovery_enabled()) {
                parser_recover_statement_boundary(p);
                return 2;
            }
            ast_block_free(b);
            return -1;
        }
        char *name = (peek(p)->ident_len > 0 && peek(p)->value.ident) ? strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len) : (peek(p)->kind == TOKEN_I32 ? strdup("i32") : NULL);
        advance(p);
        if (!name) { ast_block_free(b); return -1; }
        ASTType *type = NULL;
        if (peek(p)->kind == TOKEN_COLON) {
            advance(p);
            type = parse_type(p);
            if (!type) {
                free(name);
                if (parser_recovery_enabled()) {
                    parser_recover_statement_boundary(p);
                    return 2;
                }
                ast_block_free(b);
                return -1;
            }
        }
        if (peek(p)->kind != TOKEN_ASSIGN) {
            free(name);
            if (type) free((void *)type);
            fail(p, "expected '=' in const");
            if (parser_recovery_enabled()) {
                parser_recover_statement_boundary(p);
                return 2;
            }
            ast_block_free(b);
            return -1;
        }
        advance(p);
        ASTExpr *init = parse_expr(p);
        if (!init) {
            free(name);
            if (type) free((void *)type);
            if (parser_recovery_enabled()) {
                parser_recover_statement_boundary(p);
                return 2;
            }
            ast_block_free(b);
            return -1;
        }
        if (expr_ends_with_brace(init)) { if (peek(p)->kind == TOKEN_SEMICOLON) advance(p); }
        else {
            if (peek(p)->kind != TOKEN_SEMICOLON) {
                ast_expr_free(init);
                free(name);
                if (type) free((void *)type);
                fail(p, "expected ';' after const");
                if (parser_recovery_enabled()) {
                    parser_recover_statement_boundary(p);
                    return 2;
                }
                ast_block_free(b);
                return -1;
            }
            advance(p);
        }
        b->const_decls[b->num_consts].name = name; b->const_decls[b->num_consts].type = type; b->const_decls[b->num_consts].init = init; b->num_consts++;
        push_stmt_order(b, 0, b->num_consts - 1);
        return 1;
    }
    if (peek(p)->kind == TOKEN_LET) {
        if (b->num_lets >= MAX_LET_DECLS) { fail(p, "too many let declarations"); ast_block_free(b); return -1; }
        advance(p);
        /* let 后允许 IDENT 或 _（占位符，如 let _: i32 = ...） */
        if (peek(p)->kind != TOKEN_IDENT && peek(p)->kind != TOKEN_UNDERSCORE) {
            fail(p, "expected identifier after let");
            if (parser_recovery_enabled()) {
                parser_recover_statement_boundary(p);
                return 2;
            }
            ast_block_free(b);
            return -1;
        }
        char *name = (peek(p)->kind == TOKEN_UNDERSCORE) ? strdup("_") : ((peek(p)->ident_len > 0 && peek(p)->value.ident) ? strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len) : NULL);
        advance(p);
        if (!name) { ast_block_free(b); return -1; }
        if (peek(p)->kind != TOKEN_COLON) {
            free(name);
            fail(p, "expected ':' and type in let");
            if (parser_recovery_enabled()) {
                parser_recover_statement_boundary(p);
                return 2;
            }
            ast_block_free(b);
            return -1;
        }
        advance(p);
        ASTType *type = parse_type(p);
        if (!type) {
            free(name);
            if (parser_recovery_enabled()) {
                parser_recover_statement_boundary(p);
                return 2;
            }
            ast_block_free(b);
            return -1;
        }
        ASTExpr *init = NULL;
        if (peek(p)->kind == TOKEN_ASSIGN) {
            advance(p);
            init = parse_expr(p);
            if (!init) {
                free(name);
                free((void *)type);
                if (parser_recovery_enabled()) {
                    parser_recover_statement_boundary(p);
                    return 2;
                }
                ast_block_free(b);
                return -1;
            }
        } else if (peek(p)->kind != TOKEN_SEMICOLON && peek(p)->kind != TOKEN_LET && peek(p)->kind != TOKEN_CONST
                   && peek(p)->kind != TOKEN_RETURN && peek(p)->kind != TOKEN_IF && peek(p)->kind != TOKEN_WHILE
                   && peek(p)->kind != TOKEN_FOR && peek(p)->kind != TOKEN_RBRACE) {
            free(name); free((void *)type);
            fail(p, "expected '=' or ';' after let type");
            if (parser_recovery_enabled()) {
                parser_recover_statement_boundary(p);
                return 2;
            }
            ast_block_free(b);
            return -1;
        }
        if (init && expr_ends_with_brace(init)) { if (peek(p)->kind == TOKEN_SEMICOLON) advance(p); }
        else if (init) {
            if (peek(p)->kind != TOKEN_SEMICOLON) {
                ast_expr_free(init);
                free(name);
                free((void *)type);
                fail(p, "expected ';' after let");
                if (parser_recovery_enabled()) {
                    parser_recover_statement_boundary(p);
                    return 2;
                }
                ast_block_free(b);
                return -1;
            }
            advance(p);
        } else if (peek(p)->kind == TOKEN_SEMICOLON) {
            advance(p);
        }
        b->let_decls[b->num_lets].name = name; b->let_decls[b->num_lets].type = type; b->let_decls[b->num_lets].init = init; b->num_lets++;
        push_stmt_order(b, 1, b->num_lets - 1);
        return 1;
    }
    return 0;
}

/**
 * 解析块体：(const|let)* (while 条件 { 块 })* 最终表达式；可选是否解析 while 及结尾 }。
 * 块中部（(expr;)* 前或之间）也允许 const/let、while/for。
 * 参数：p 解析器状态；allow_while 1 表示允许解析 while/for；consume_rbrace 1 表示最后消耗结尾 }（函数体等），0 表示不消耗（if/while/for 体由调用方消耗）。返回值：成功返回 ASTBlock*；失败返回 NULL。
 */
static ASTBlock *parse_block(Parser *p, int allow_while, int consume_rbrace) {
    ASTBlock *b = (ASTBlock *)malloc(sizeof(ASTBlock));
    if (!b) {
        parser_oom(p);
        return NULL;
    }
    b->num_consts = 0;
    b->num_lets = 0;
    b->num_early_lets = 0;
    b->const_decls = (ASTConstDecl *)malloc((size_t)MAX_CONST_DECLS * sizeof(ASTConstDecl));
    b->let_decls = (ASTLetDecl *)malloc((size_t)MAX_LET_DECLS * sizeof(ASTLetDecl));
    b->loops = NULL;
    b->num_loops = 0;
    b->for_loops = NULL;
    b->num_for_loops = 0;
    b->defer_blocks = NULL;
    b->num_defers = 0;
    b->regions = NULL;
    b->num_regions = 0;
    b->labeled_stmts = NULL;
    b->num_labeled_stmts = 0;
    b->expr_stmts = NULL;
    b->num_expr_stmts = 0;
    b->final_expr = NULL;
    b->num_stmt_order = 0;
    if (!b->const_decls || !b->let_decls) {
        if (b->const_decls) free(b->const_decls);
        if (b->let_decls) free(b->let_decls);
        free(b);
        return NULL;
    }
    /* 先进入 stmt 主循环，保证 stmt_order 严格按源码顺序（从块首 token 起 const/let/expr/while/for 交错）。遇 while/for 时从循环内 goto 到 parse_while_start/parse_for_start。 */
    b->num_early_lets = 0;
    if (consume_rbrace && peek(p)->kind == TOKEN_RBRACE) {
        b->final_expr = NULL;
    } else {
        int seen_expr = 0;
        for (;;) {
next_stmt:
            if (peek(p)->kind == TOKEN_RBRACE)
                break;
            /** B-02：函数体内 #[cfg] { ... }；不匹配 host 时跳过花括号块，匹配时扁平并入当前块。 */
            if (peek(p)->kind == TOKEN_ATTR_CFG) {
                int cfg_match = peek(p)->value.int_val != 0;
                advance(p);
                if (peek(p)->kind != TOKEN_LBRACE) {
                    fail(p, "expected '{' after #[cfg]");
                    if (parser_recovery_enabled()) {
                        parser_recover_statement_boundary(p);
                        goto next_stmt;
                    }
                    ast_block_free(b);
                    return NULL;
                }
                if (!cfg_match) {
                    skip_balanced_tokens(p, TOKEN_LBRACE, TOKEN_RBRACE);
                    goto next_stmt;
                }
                advance(p);
                {
                    ASTBlock *cb = parse_block(p, 1, 0);
                    if (!cb) {
                        if (parser_recovery_enabled()) {
                            parser_recover_statement_boundary(p);
                            goto next_stmt;
                        }
                        ast_block_free(b);
                        return NULL;
                    }
                    if (peek(p)->kind != TOKEN_RBRACE) {
                        ast_block_free(cb);
                        fail(p, "expected '}' after #[cfg] block");
                        if (parser_recovery_enabled()) {
                            parser_recover_statement_boundary(p);
                            goto next_stmt;
                        }
                        ast_block_free(b);
                        return NULL;
                    }
                    advance(p);
                    if (ast_block_flatten_into(b, cb) != 0) {
                        ast_block_free(cb);
                        fail(p, "too many statements in #[cfg] block");
                        if (parser_recovery_enabled()) {
                            parser_recover_statement_boundary(p);
                            goto next_stmt;
                        }
                        ast_block_free(b);
                        return NULL;
                    }
                    ast_block_free(cb);
                    goto next_stmt;
                }
            }
            {
                int r = parse_one_const_or_let(p, b);
                if (r == 1) {
                    if (!seen_expr) b->num_early_lets = b->num_lets;
                    continue;
                }
                if (r == 2)
                    continue;
                if (r == -1) return NULL;
            }
            if (allow_while && (peek(p)->kind == TOKEN_WHILE || peek(p)->kind == TOKEN_LOOP)) goto parse_while_start;
            if (allow_while && peek(p)->kind == TOKEN_FOR) goto parse_for_start;
            if (peek(p)->kind == TOKEN_REGION) goto parse_region_start;
            if (peek(p)->kind == TOKEN_IDENT && is_ident_str(p, "unsafe", 6))
                goto parse_unsafe_start;
            if (peek(p)->kind == TOKEN_DEFER) goto parse_defer_start;
            if (peek(p)->kind == TOKEN_GOTO || (peek(p)->kind == TOKEN_IDENT && peek_next(p)->kind == TOKEN_COLON))
                goto parse_label_start;
            ASTExpr *e = parse_expr(p);
            if (!e) {
                if (parser_recovery_enabled()) {
                    parser_recover_statement_boundary(p);
                    continue;
                }
                ast_block_free(b);
                return NULL;
            }
            if (peek(p)->kind == TOKEN_SEMICOLON) {
                if (expr_ends_with_brace(e)) {
                    advance(p);
                    b->final_expr = e;
                    break;
                }
                if (b->num_expr_stmts >= MAX_EXPR_STMTS) {
                    ast_expr_free(e);
                    ast_block_free(b);
                    fail(p, "too many expression statements");
                    return NULL;
                }
                if (!b->expr_stmts) {
                    b->expr_stmts = (ASTExpr **)malloc((size_t)MAX_EXPR_STMTS * sizeof(ASTExpr *));
                    if (!b->expr_stmts) {
                        ast_expr_free(e);
                        ast_block_free(b);
                        parser_oom(p);
                        return NULL;
                    }
                }
                b->expr_stmts[b->num_expr_stmts++] = e;
                push_stmt_order(b, 2, b->num_expr_stmts - 1);
                seen_expr = 1;
                advance(p);
            } else {
                if (!expr_ends_with_brace(e) && parser_stmt_needs_semicolon(p)) {
                    ast_expr_free(e);
                    fail(p, "expected ';' after expression");
                    if (parser_recovery_enabled()) {
                        parser_recover_statement_boundary(p);
                        continue;
                    }
                    ast_block_free(b);
                    return NULL;
                }
                if (expr_ends_with_brace(e) && peek(p)->kind != TOKEN_RBRACE) {
                    if (b->num_expr_stmts >= MAX_EXPR_STMTS) {
                        ast_expr_free(e);
                        ast_block_free(b);
                        fail(p, "too many expression statements");
                        return NULL;
                    }
                    if (!b->expr_stmts) {
                        b->expr_stmts = (ASTExpr **)malloc((size_t)MAX_EXPR_STMTS * sizeof(ASTExpr *));
                        if (!b->expr_stmts) {
                            ast_expr_free(e);
                            ast_block_free(b);
                            parser_oom(p);
                            return NULL;
                        }
                    }
                    b->expr_stmts[b->num_expr_stmts++] = e;
                    push_stmt_order(b, 2, b->num_expr_stmts - 1);
                    seen_expr = 1;
                    continue;
                }
                b->final_expr = e;
                break;
            }
        }
        if (!allow_while)
            while (peek(p)->kind == TOKEN_SEMICOLON)
                advance(p);
        goto after_block;
    }
    /* 仅当从 for(;;) 内 goto 到达：解析单条 while/for，解析后 goto next_stmt */
parse_while_start:
    if (allow_while) {
        if (peek(p)->kind == TOKEN_WHILE || peek(p)->kind == TOKEN_LOOP) {
            if (b->num_loops >= MAX_WHILE_LOOPS) {
                fail(p, "too many while/loop");
                ast_block_free(b);
                return NULL;
            }
            if (!b->loops) {
                b->loops = (ASTWhileLoop *)malloc((size_t)MAX_WHILE_LOOPS * sizeof(ASTWhileLoop));
                if (!b->loops) {
                    ast_block_free(b);
                    return NULL;
                }
            }
            int is_loop = (peek(p)->kind == TOKEN_LOOP);
            advance(p);
            ASTExpr *cond;
            if (is_loop) {
                /* loop { body }：条件恒为 1 */
                if (peek(p)->kind != TOKEN_LBRACE) {
                    fail(p, "expected '{' after loop");
                    if (parser_recovery_enabled()) {
                        parser_recover_statement_boundary(p);
                        goto next_stmt;
                    }
                    ast_block_free(b);
                    return NULL;
                }
                cond = (ASTExpr *)calloc(1, sizeof(ASTExpr));
                if (!cond) {
                    ast_block_free(b);
                    parser_oom(p);
                    return NULL;
                }
                set_expr_loc(cond, p);
                cond->kind = AST_EXPR_BOOL_LIT;  /* loop 等价 while true */
                cond->value.int_val = 1;
            } else {
                /* while ( cond ) { body }：条件必须用括号包裹，可读性更好 */
                if (peek(p)->kind != TOKEN_LPAREN) {
                    fail(p, "expected '(' after while");
                    if (parser_recovery_enabled()) {
                        parser_recover_statement_boundary(p);
                        goto next_stmt;
                    }
                    ast_block_free(b);
                    return NULL;
                }
                advance(p);
                cond = parse_expr(p);
                if (!cond) {
                    if (parser_recovery_enabled()) {
                        parser_recover_statement_boundary(p);
                        goto next_stmt;
                    }
                    ast_block_free(b);
                    return NULL;
                }
                if (peek(p)->kind != TOKEN_RPAREN) {
                    ast_expr_free(cond);
                    fail(p, "expected ')' after while condition");
                    if (parser_recovery_enabled()) {
                        parser_recover_statement_boundary(p);
                        goto next_stmt;
                    }
                    ast_block_free(b);
                    return NULL;
                }
                advance(p);
                if (peek(p)->kind != TOKEN_LBRACE) {
                    ast_expr_free(cond);
                    fail(p, "expected '{' after while (cond)");
                    if (parser_recovery_enabled()) {
                        parser_recover_statement_boundary(p);
                        goto next_stmt;
                    }
                    ast_block_free(b);
                    return NULL;
                }
            }
            advance(p);
            ASTBlock *body = parse_block(p, 1, 0);  /* 体可含嵌套 while/for，不消耗 } 由调用方消耗 */
            if (!body) {
                ast_expr_free(cond);
                if (parser_recovery_enabled()) {
                    parser_recover_statement_boundary(p);
                    goto next_stmt;
                }
                ast_block_free(b);
                return NULL;
            }
            if (peek(p)->kind != TOKEN_RBRACE) {
                ast_expr_free(cond);
                ast_block_free(body);
                fail(p, "expected '}' after loop/while body");
                if (parser_recovery_enabled()) {
                    parser_recover_statement_boundary(p);
                    goto next_stmt;
                }
                ast_block_free(b);
                return NULL;
            }
            advance(p);
            if (fail_if_semicolon_after_brace(p) != 0) {
                ast_expr_free(cond);
                ast_block_free(body);
                ast_block_free(b);
                return NULL;
            }
            b->loops[b->num_loops].cond = cond;
            b->loops[b->num_loops].body = body;
            b->num_loops++;
            push_stmt_order(b, 3, b->num_loops - 1);
            goto next_stmt;
        }
        }
        /* 解析单条 for ( [init]; [cond]; [step] ) { body }，解析一条后 goto next_stmt */
parse_for_start:
        if (allow_while && peek(p)->kind == TOKEN_FOR) {
            if (b->num_for_loops >= MAX_FOR_LOOPS) {
                fail(p, "too many for loops");
                ast_block_free(b);
                return NULL;
            }
            if (!b->for_loops) {
                b->for_loops = (ASTForLoop *)malloc((size_t)MAX_FOR_LOOPS * sizeof(ASTForLoop));
                if (!b->for_loops) {
                    ast_block_free(b);
                    return NULL;
                }
            }
            advance(p);
            if (peek(p)->kind != TOKEN_LPAREN) {
                fail(p, "expected '(' after for");
                if (parser_recovery_enabled()) {
                    parser_recover_statement_boundary(p);
                    goto next_stmt;
                }
                ast_block_free(b);
                return NULL;
            }
            advance(p);
            /* init：可选，; 前可为 let ident : type = expr ;（基础写法）或单条表达式 */
            ASTExpr *init = NULL;
            if (peek(p)->kind == TOKEN_LET) {
                /* for ( let i : i32 = 0 ; cond ; step )：将 let 加入当前块，for 的 init 留空 */
                if (b->num_lets >= MAX_LET_DECLS) {
                    fail(p, "too many let declarations in for init");
                    ast_block_free(b);
                    return NULL;
                }
                advance(p);
                if (peek(p)->kind != TOKEN_IDENT && peek(p)->kind != TOKEN_UNDERSCORE) {
                    fail(p, "expected identifier after let in for init");
                    if (parser_recovery_enabled()) {
                        parser_recover_statement_boundary(p);
                        goto next_stmt;
                    }
                    ast_block_free(b);
                    return NULL;
                }
                char *name = (peek(p)->kind == TOKEN_UNDERSCORE) ? strdup("_") : ((peek(p)->ident_len > 0 && peek(p)->value.ident) ? strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len) : NULL);
                advance(p);
                if (!name) { ast_block_free(b); return NULL; }
                if (peek(p)->kind != TOKEN_COLON) {
                    free(name);
                    fail(p, "expected ':' and type in for init let");
                    if (parser_recovery_enabled()) {
                        parser_recover_statement_boundary(p);
                        goto next_stmt;
                    }
                    ast_block_free(b);
                    return NULL;
                }
                advance(p);
                ASTType *type = parse_type(p);
                if (!type) {
                    free(name);
                    if (parser_recovery_enabled()) {
                        parser_recover_statement_boundary(p);
                        goto next_stmt;
                    }
                    ast_block_free(b);
                    return NULL;
                }
                if (peek(p)->kind != TOKEN_ASSIGN) {
                    free(name);
                    free((void *)type);
                    fail(p, "expected '=' in for init let");
                    if (parser_recovery_enabled()) {
                        parser_recover_statement_boundary(p);
                        goto next_stmt;
                    }
                    ast_block_free(b);
                    return NULL;
                }
                advance(p);
                ASTExpr *let_init = parse_expr(p);
                if (!let_init) {
                    free(name);
                    free((void *)type);
                    if (parser_recovery_enabled()) {
                        parser_recover_statement_boundary(p);
                        goto next_stmt;
                    }
                    ast_block_free(b);
                    return NULL;
                }
                if (peek(p)->kind != TOKEN_SEMICOLON) {
                    free(name);
                    free((void *)type);
                    ast_expr_free(let_init);
                    fail(p, "expected ';' after for init let");
                    if (parser_recovery_enabled()) {
                        parser_recover_statement_boundary(p);
                        goto next_stmt;
                    }
                    ast_block_free(b);
                    return NULL;
                }
                advance(p);
                b->let_decls[b->num_lets].name = name;
                b->let_decls[b->num_lets].type = type;
                b->let_decls[b->num_lets].init = let_init;
                b->num_lets++;
                push_stmt_order(b, 1, b->num_lets - 1);
            } else if (peek(p)->kind != TOKEN_SEMICOLON) {
                init = parse_expr(p);
                if (!init) {
                    if (parser_recovery_enabled()) {
                        parser_recover_statement_boundary(p);
                        goto next_stmt;
                    }
                    ast_block_free(b);
                    return NULL;
                }
                if (peek(p)->kind != TOKEN_SEMICOLON) {
                    ast_expr_free(init);
                    fail(p, "expected ';' in for");
                    if (parser_recovery_enabled()) {
                        parser_recover_statement_boundary(p);
                        goto next_stmt;
                    }
                    ast_block_free(b);
                    return NULL;
                }
                advance(p);
            } else {
                advance(p);
            }
            /* cond：可选，; 前无表达式则为 NULL（表示恒真） */
            ASTExpr *cond = NULL;
            if (peek(p)->kind != TOKEN_SEMICOLON) {
                cond = parse_expr(p);
                if (!cond) {
                    ast_expr_free(init);
                    if (parser_recovery_enabled()) {
                        parser_recover_statement_boundary(p);
                        goto next_stmt;
                    }
                    ast_block_free(b);
                    return NULL;
                }
            }
            if (peek(p)->kind != TOKEN_SEMICOLON) {
                ast_expr_free(init);
                ast_expr_free(cond);
                fail(p, "expected ';' in for");
                if (parser_recovery_enabled()) {
                    parser_recover_statement_boundary(p);
                    goto next_stmt;
                }
                ast_block_free(b);
                return NULL;
            }
            advance(p);
            /* step：可选，) 前无表达式则为 NULL */
            ASTExpr *step = NULL;
            if (peek(p)->kind != TOKEN_RPAREN) {
                step = parse_expr(p);
                if (!step) {
                    ast_expr_free(init);
                    ast_expr_free(cond);
                    if (parser_recovery_enabled()) {
                        parser_recover_statement_boundary(p);
                        goto next_stmt;
                    }
                    ast_block_free(b);
                    return NULL;
                }
            }
            if (peek(p)->kind != TOKEN_RPAREN) {
                ast_expr_free(init);
                ast_expr_free(cond);
                ast_expr_free(step);
                fail(p, "expected ')' in for");
                if (parser_recovery_enabled()) {
                    parser_recover_statement_boundary(p);
                    goto next_stmt;
                }
                ast_block_free(b);
                return NULL;
            }
            advance(p);
            if (peek(p)->kind != TOKEN_LBRACE) {
                ast_expr_free(init);
                ast_expr_free(cond);
                ast_expr_free(step);
                fail(p, "expected '{' after for");
                if (parser_recovery_enabled()) {
                    parser_recover_statement_boundary(p);
                    goto next_stmt;
                }
                ast_block_free(b);
                return NULL;
            }
            advance(p);
            ASTBlock *body = parse_block(p, 0, 0);
            if (!body) {
                ast_expr_free(init);
                ast_expr_free(cond);
                ast_expr_free(step);
                if (parser_recovery_enabled()) {
                    parser_recover_statement_boundary(p);
                    goto next_stmt;
                }
                ast_block_free(b);
                return NULL;
            }
            if (peek(p)->kind != TOKEN_RBRACE) {
                ast_expr_free(init);
                ast_expr_free(cond);
                ast_expr_free(step);
                ast_block_free(body);
                fail(p, "expected '}' after for body");
                if (parser_recovery_enabled()) {
                    parser_recover_statement_boundary(p);
                    goto next_stmt;
                }
                ast_block_free(b);
                return NULL;
            }
            advance(p);
            if (fail_if_semicolon_after_brace(p) != 0) {
                ast_expr_free(init);
                ast_expr_free(cond);
                ast_expr_free(step);
                ast_block_free(body);
                ast_block_free(b);
                return NULL;
            }
            b->for_loops[b->num_for_loops].init = init;
            b->for_loops[b->num_for_loops].cond = cond;
            b->for_loops[b->num_for_loops].step = step;
            b->for_loops[b->num_for_loops].body = body;
            b->num_for_loops++;
            push_stmt_order(b, 4, b->num_for_loops - 1);
            goto next_stmt;
        }
    /* 解析 defer { block }*：块退出时逆序执行；从 for(;;) 内 goto 到达 */
parse_defer_start:
    while (peek(p)->kind == TOKEN_DEFER) {
        if (b->num_defers >= MAX_DEFERS) {
            fail(p, "too many defer blocks");
            ast_block_free(b);
            return NULL;
        }
        advance(p);
        if (peek(p)->kind != TOKEN_LBRACE) {
            fail(p, "expected '{' after defer");
            if (parser_recovery_enabled()) {
                parser_recover_statement_boundary(p);
                goto next_stmt;
            }
            ast_block_free(b);
            return NULL;
        }
        advance(p);
        ASTBlock *db = parse_block(p, 0, 0);
        if (!db) {
            if (parser_recovery_enabled()) {
                parser_recover_statement_boundary(p);
                goto next_stmt;
            }
            ast_block_free(b);
            return NULL;
        }
        if (peek(p)->kind != TOKEN_RBRACE) {
            ast_block_free(db);
            fail(p, "expected '}' after defer block");
            if (parser_recovery_enabled()) {
                parser_recover_statement_boundary(p);
                goto next_stmt;
            }
            ast_block_free(b);
            return NULL;
        }
        advance(p);
        if (fail_if_semicolon_after_brace(p) != 0) {
            ast_block_free(db);
            ast_block_free(b);
            return NULL;
        }
        if (!b->defer_blocks) {
            b->defer_blocks = (ASTBlock **)malloc((size_t)MAX_DEFERS * sizeof(ASTBlock *));
            if (!b->defer_blocks) {
                ast_block_free(db);
                ast_block_free(b);
                return NULL;
            }
        }
        b->defer_blocks[b->num_defers++] = db;
    }
    goto next_stmt;
    /* M-3：region label { body }；块内 slice 由 typeck 继承域标签 */
parse_region_start:
    if (b->num_regions >= MAX_REGION_BLOCKS) {
        fail(p, "too many region blocks");
        ast_block_free(b);
        return NULL;
    }
    advance(p);
    {
        const Token *lab = peek(p);
        char *label = NULL;
        ASTBlock *rb = NULL;
        if (!lab || lab->kind != TOKEN_IDENT || lab->ident_len <= 0) {
            fail(p, "expected region label after region");
            if (parser_recovery_enabled()) {
                parser_recover_statement_boundary(p);
                goto next_stmt;
            }
            ast_block_free(b);
            return NULL;
        }
        label = (lab->value.ident && lab->ident_len > 0)
            ? strndup(lab->value.ident, (size_t)lab->ident_len) : NULL;
        if (!label) {
            ast_block_free(b);
            fail(p, "out of memory");
            return NULL;
        }
        advance(p);
        if (peek(p)->kind != TOKEN_LBRACE) {
            free(label);
            fail(p, "expected '{' after region label");
            if (parser_recovery_enabled()) {
                parser_recover_statement_boundary(p);
                goto next_stmt;
            }
            ast_block_free(b);
            return NULL;
        }
        advance(p);
        rb = parse_block(p, 1, 0);
        if (!rb) {
            free(label);
            if (parser_recovery_enabled()) {
                parser_recover_statement_boundary(p);
                goto next_stmt;
            }
            ast_block_free(b);
            return NULL;
        }
        if (peek(p)->kind != TOKEN_RBRACE) {
            free(label);
            ast_block_free(rb);
            fail(p, "expected '}' after region body");
            if (parser_recovery_enabled()) {
                parser_recover_statement_boundary(p);
                goto next_stmt;
            }
            ast_block_free(b);
            return NULL;
        }
        advance(p);
        if (fail_if_semicolon_after_brace(p) != 0) {
            free(label);
            ast_block_free(rb);
            ast_block_free(b);
            return NULL;
        }
        if (!b->regions) {
            b->regions = (ASTRegionBlock *)malloc((size_t)MAX_REGION_BLOCKS * sizeof(ASTRegionBlock));
            if (!b->regions) {
                free(label);
                ast_block_free(rb);
                ast_block_free(b);
                parser_oom(p);
                return NULL;
            }
        }
        b->regions[b->num_regions].label = label;
        b->regions[b->num_regions].body = rb;
        b->regions[b->num_regions].is_unsafe = 0;
        b->num_regions++;
        push_stmt_order(b, 5, b->num_regions - 1);
    }
    goto next_stmt;
    /* LANG-007 v2：unsafe { body }；运行时等价嵌套块，typeck 跟踪 unsafe 深度 */
parse_unsafe_start:
    if (b->num_regions >= MAX_REGION_BLOCKS) {
        fail(p, "too many region blocks");
        ast_block_free(b);
        return NULL;
    }
    advance(p); /* consume 'unsafe' */
    if (peek(p)->kind != TOKEN_LBRACE) {
        fail(p, "expected '{' after unsafe");
        if (parser_recovery_enabled()) {
            parser_recover_statement_boundary(p);
            goto next_stmt;
        }
        ast_block_free(b);
        return NULL;
    }
    advance(p);
    {
        ASTBlock *ub = parse_block(p, 1, 0);
        if (!ub) {
            if (parser_recovery_enabled()) {
                parser_recover_statement_boundary(p);
                goto next_stmt;
            }
            ast_block_free(b);
            return NULL;
        }
        if (peek(p)->kind != TOKEN_RBRACE) {
            ast_block_free(ub);
            fail(p, "expected '}' after unsafe body");
            if (parser_recovery_enabled()) {
                parser_recover_statement_boundary(p);
                goto next_stmt;
            }
            ast_block_free(b);
            return NULL;
        }
        advance(p);
        if (fail_if_semicolon_after_brace(p) != 0) {
            ast_block_free(ub);
            ast_block_free(b);
            return NULL;
        }
        if (!b->regions) {
            b->regions = (ASTRegionBlock *)malloc((size_t)MAX_REGION_BLOCKS * sizeof(ASTRegionBlock));
            if (!b->regions) {
                ast_block_free(ub);
                ast_block_free(b);
                parser_oom(p);
                return NULL;
            }
        }
        b->regions[b->num_regions].label = NULL;
        b->regions[b->num_regions].body = ub;
        b->regions[b->num_regions].is_unsafe = 1;
        b->num_regions++;
        push_stmt_order(b, 5, b->num_regions - 1);
    }
    goto next_stmt;
    /* 解析 ( [label:] (goto id;|return expr;) )*；从 for(;;) 内 goto 到达 */
parse_label_start:
    while (1) {
        char *label = NULL;
        if (peek(p)->kind == TOKEN_IDENT && peek_next(p)->kind == TOKEN_COLON) {
            const Token *t = peek(p);
            label = (t->ident_len > 0 && t->value.ident)
                ? strndup(t->value.ident, (size_t)t->ident_len) : NULL;
            advance(p);
            advance(p); /* consume COLON */
            if (!label) {
                ast_block_free(b);
                return NULL;
            }
        }
        if (peek(p)->kind == TOKEN_GOTO) {
            advance(p);
            if (peek(p)->kind != TOKEN_IDENT && peek(p)->kind != TOKEN_I32) {
                if (label) free(label);
                fail(p, "expected identifier after goto");
                if (parser_recovery_enabled()) {
                    parser_recover_statement_boundary(p);
                    goto next_stmt;
                }
                ast_block_free(b);
                return NULL;
            }
            char *target = (peek(p)->ident_len > 0 && peek(p)->value.ident)
                ? strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len) : NULL;
            advance(p);
            if (!target) {
                if (label) free(label);
                ast_block_free(b);
                return NULL;
            }
            if (peek(p)->kind != TOKEN_SEMICOLON) {
                free(target);
                if (label) free(label);
                fail(p, "expected ';' after goto target");
                if (parser_recovery_enabled()) {
                    parser_recover_statement_boundary(p);
                    goto next_stmt;
                }
                ast_block_free(b);
                return NULL;
            }
            advance(p);
            if (b->num_labeled_stmts >= MAX_LABELED_STMTS) {
                free(target);
                if (label) free(label);
                fail(p, "too many labeled statements");
                ast_block_free(b);
                return NULL;
            }
            if (!b->labeled_stmts) {
                b->labeled_stmts = (ASTLabeledStmt *)malloc((size_t)MAX_LABELED_STMTS * sizeof(ASTLabeledStmt));
                if (!b->labeled_stmts) {
                    free(target);
                    if (label) free(label);
                    ast_block_free(b);
                    return NULL;
                }
            }
            b->labeled_stmts[b->num_labeled_stmts].label = label;
            b->labeled_stmts[b->num_labeled_stmts].kind = AST_STMT_GOTO;
            b->labeled_stmts[b->num_labeled_stmts].u.goto_target = target;
            b->num_labeled_stmts++;
            continue;
        }
        if (peek(p)->kind == TOKEN_RETURN) {
            advance(p);
            /* 支持 return;（无表达式）与 return expr;（文档 01：return expr; / return;） */
            ASTExpr *ret_expr = NULL;
            if (peek(p)->kind != TOKEN_SEMICOLON && peek(p)->kind != TOKEN_RBRACE) {
                ret_expr = parse_expr(p);
            }
            if (!ret_expr && peek(p)->kind != TOKEN_SEMICOLON && peek(p)->kind != TOKEN_RBRACE) {
                if (label) free(label);
                if (parser_recovery_enabled()) {
                    parser_recover_statement_boundary(p);
                    goto next_stmt;
                }
                ast_block_free(b);
                return NULL;
            }
            /* } 后分号可选；return 以 } 结尾时可不写分号；其他 return 必须带分号 */
            if (ret_expr && expr_ends_with_brace(ret_expr)) {
                if (peek(p)->kind == TOKEN_SEMICOLON) advance(p);
            } else {
                if (peek(p)->kind != TOKEN_SEMICOLON) {
                    ast_expr_free(ret_expr);
                    if (label) free(label);
                    fail(p, "expected ';' after return");
                    if (parser_recovery_enabled()) {
                        parser_recover_statement_boundary(p);
                        goto next_stmt;
                    }
                    ast_block_free(b);
                    return NULL;
                }
                advance(p);
            }
            if (b->num_labeled_stmts >= MAX_LABELED_STMTS) {
                ast_expr_free(ret_expr);
                if (label) free(label);
                fail(p, "too many labeled statements");
                ast_block_free(b);
                return NULL;
            }
            if (!b->labeled_stmts) {
                b->labeled_stmts = (ASTLabeledStmt *)malloc((size_t)MAX_LABELED_STMTS * sizeof(ASTLabeledStmt));
                if (!b->labeled_stmts) {
                    ast_expr_free(ret_expr);
                    if (label) free(label);
                    ast_block_free(b);
                    return NULL;
                }
            }
            b->labeled_stmts[b->num_labeled_stmts].label = label;
            b->labeled_stmts[b->num_labeled_stmts].kind = AST_STMT_RETURN;
            b->labeled_stmts[b->num_labeled_stmts].u.return_expr = ret_expr;
            b->num_labeled_stmts++;
            continue;
        }
        if (label) free(label);
        break;
    }
    goto next_stmt;
after_block:
    if (consume_rbrace && peek(p)->kind != TOKEN_RBRACE) {
        ast_block_free(b);
        fail(p, "expected '}'");
        return NULL;
    }
    if (consume_rbrace) {
        advance(p);
        if (fail_if_semicolon_after_brace(p) != 0) {
            ast_block_free(b);
            return NULL;
        }
    }
    return b;
}

/**
 * B-01：按 open/close token 跳过一段括号/花括号/尖括号平衡区域（含起始 token）。
 */
static void skip_balanced_tokens(Parser *p, TokenKind open, TokenKind close) {
    int depth;
    if (peek(p)->kind != open)
        return;
    depth = 1;
    advance(p);
    while (depth > 0 && peek(p)->kind != TOKEN_EOF) {
        if (peek(p)->kind == open)
            depth++;
        else if (peek(p)->kind == close)
            depth--;
        advance(p);
    }
}

static int parser_recovery_enabled(void) {
    return lsp_diag_enabled ? 1 : 0;
}

static int parser_is_stmt_sync_token(Parser *p) {
    TokenKind k = peek(p)->kind;
    if (k == TOKEN_EOF || k == TOKEN_RBRACE || k == TOKEN_CONST || k == TOKEN_LET
        || k == TOKEN_RETURN || k == TOKEN_IF || k == TOKEN_WHILE || k == TOKEN_LOOP
        || k == TOKEN_FOR || k == TOKEN_DEFER || k == TOKEN_REGION || k == TOKEN_GOTO
        || k == TOKEN_ATTR_CFG)
        return 1;
    if (k == TOKEN_IDENT && peek_next(p)->kind == TOKEN_COLON)
        return 1;
    if (k == TOKEN_IDENT && is_ident_str(p, "unsafe", 6))
        return 1;
    return 0;
}

static void parser_recover_statement_boundary(Parser *p) {
    int paren_depth = 0;
    int bracket_depth = 0;

    while (peek(p)->kind != TOKEN_EOF) {
        TokenKind k = peek(p)->kind;
        if (paren_depth == 0 && bracket_depth == 0) {
            if (k == TOKEN_SEMICOLON) {
                advance(p);
                break;
            }
            if (parser_is_stmt_sync_token(p))
                break;
            if (k == TOKEN_LBRACE) {
                skip_balanced_tokens(p, TOKEN_LBRACE, TOKEN_RBRACE);
                continue;
            }
        }
        if (k == TOKEN_LPAREN)
            paren_depth++;
        else if (k == TOKEN_RPAREN && paren_depth > 0)
            paren_depth--;
        else if (k == TOKEN_LBRACKET)
            bracket_depth++;
        else if (k == TOKEN_RBRACKET && bracket_depth > 0)
            bracket_depth--;
        advance(p);
    }
    while (peek(p)->kind == TOKEN_SEMICOLON)
        advance(p);
}

/**
 * struct 字段级同步恢复：跳过当前坏字段，定位到下一个字段边界。
 * 停在：消耗并越过 ';'（字段分隔），或停在 '}' 前（由外层 while 退出），或 EOF。
 * 仅在 parser_recovery_enabled() 时由字段错误路径调用；保留括号/方括号深度以免误停在嵌套 ';'。
 */
static void parser_recover_struct_field_boundary(Parser *p) {
    int paren_depth = 0;
    int bracket_depth = 0;
    while (peek(p)->kind != TOKEN_EOF) {
        TokenKind k = peek(p)->kind;
        if (paren_depth == 0 && bracket_depth == 0) {
            if (k == TOKEN_SEMICOLON) { advance(p); break; }
            if (k == TOKEN_RBRACE) break;
        }
        if (k == TOKEN_LPAREN) paren_depth++;
        else if (k == TOKEN_RPAREN && paren_depth > 0) paren_depth--;
        else if (k == TOKEN_LBRACKET) bracket_depth++;
        else if (k == TOKEN_RBRACKET && bracket_depth > 0) bracket_depth--;
        advance(p);
    }
}

/**
 * enum 变体级同步恢复：跳过当前坏变体，定位到下一个变体边界。
 * 停在：消耗并越过 ','（变体分隔），或停在 '}' 前（由外层 while 退出），或 EOF。
 */
static void parser_recover_enum_variant_boundary(Parser *p) {
    int paren_depth = 0;
    while (peek(p)->kind != TOKEN_EOF) {
        TokenKind k = peek(p)->kind;
        if (paren_depth == 0) {
            if (k == TOKEN_COMMA) { advance(p); break; }
            if (k == TOKEN_RBRACE) break;
        }
        if (k == TOKEN_LPAREN) paren_depth++;
        else if (k == TOKEN_RPAREN && paren_depth > 0) paren_depth--;
        advance(p);
    }
}

/**
 * trait 方法级同步恢复：跳过当前坏方法签名，定位到下一个方法边界。
 * 停在：下一个 'function'（下一方法起点）或 '}' 前（trait 结束，由外层 while 退出），或 EOF。
 * trait 方法无函数体（';' 结束），无嵌套 function，故以 TOKEN_FUNCTION 为可靠同步点。
 */
static void parser_recover_trait_method_boundary(Parser *p) {
    while (peek(p)->kind != TOKEN_EOF) {
        TokenKind k = peek(p)->kind;
        if (k == TOKEN_FUNCTION || k == TOKEN_RBRACE) break;
        advance(p);
    }
}

/**
 * impl 方法级同步恢复：跳过当前坏方法，定位到下一个方法边界。
 * impl 方法带函数体（{ ... }），不能像 trait 那样见到 '}' 就停（方法体的 '}' 会误判为 impl 结束）。
 * 故按花括号深度跟踪：depth 0 处的 'function' = 下一方法起点；使 depth 跌到 -1 的 '}' = impl 结束。
 * 坏签名但函数体仍平衡时定位准确；函数体未闭合的极端情形为 best-effort。
 */
static void parser_recover_impl_method_boundary(Parser *p) {
    int depth = 0;
    while (peek(p)->kind != TOKEN_EOF) {
        TokenKind k = peek(p)->kind;
        if (depth == 0 && k == TOKEN_FUNCTION) break;
        if (k == TOKEN_LBRACE) depth++;
        else if (k == TOKEN_RBRACE) {
            depth--;
            if (depth < 0) break; /* impl 结束的 '}' */
        }
        advance(p);
    }
}

static int parser_stmt_needs_semicolon(Parser *p) {
    if (!parser_recovery_enabled())
        return 0;
    if (peek(p)->kind == TOKEN_RBRACE || peek(p)->kind == TOKEN_EOF || peek(p)->kind == TOKEN_SEMICOLON)
        return 0;
    return parser_is_stmt_sync_token(p);
}

static int parser_top_level_recovery_enabled(void) {
    return parser_recovery_enabled();
}

static int parser_is_top_level_sync_token(Parser *p) {
    TokenKind k = peek(p)->kind;
    if (k == TOKEN_EOF || k == TOKEN_EXTERN || k == TOKEN_ASYNC || k == TOKEN_FUNCTION
        || k == TOKEN_STRUCT || k == TOKEN_ENUM || k == TOKEN_TRAIT || k == TOKEN_IMPL
        || k == TOKEN_LET || k == TOKEN_CONST || k == TOKEN_ATTR_SOA || k == TOKEN_ATTR_CFG
        || k == TOKEN_ATTR_REPR_C || k == TOKEN_ATTR_REPR_COMPATIBLE || k == TOKEN_ATTR_ALLOC)
        return 1;
    if (k == TOKEN_IDENT && is_ident_str(p, "allow", 5))
        return 1;
    return 0;
}

static void parser_recover_top_level_boundary(Parser *p) {
    int paren_depth = 0;
    int bracket_depth = 0;

    while (peek(p)->kind != TOKEN_EOF) {
        TokenKind k = peek(p)->kind;
        if (paren_depth == 0 && bracket_depth == 0) {
            if (k == TOKEN_SEMICOLON) {
                advance(p);
                break;
            }
            if (k == TOKEN_LBRACE) {
                skip_balanced_tokens(p, TOKEN_LBRACE, TOKEN_RBRACE);
                break;
            }
            if (parser_is_top_level_sync_token(p))
                break;
        }
        if (k == TOKEN_LPAREN)
            paren_depth++;
        else if (k == TOKEN_RPAREN && paren_depth > 0)
            paren_depth--;
        else if (k == TOKEN_LBRACKET)
            bracket_depth++;
        else if (k == TOKEN_RBRACKET && bracket_depth > 0)
            bracket_depth--;
        advance(p);
    }
    while (peek(p)->kind == TOKEN_SEMICOLON)
        advance(p);
}

/**
 * B-01：跳过一条顶层 function（含 optional async/extern 前缀；不建 AST）。
 */
static void skip_one_top_level_function(Parser *p) {
    if (peek(p)->kind == TOKEN_ASYNC)
        advance(p);
    if (peek(p)->kind == TOKEN_EXTERN)
        advance(p);
    if (peek(p)->kind != TOKEN_FUNCTION)
        return;
    advance(p);
    while (peek(p)->kind != TOKEN_LPAREN && peek(p)->kind != TOKEN_LT && peek(p)->kind != TOKEN_LBRACE
           && peek(p)->kind != TOKEN_SEMICOLON && peek(p)->kind != TOKEN_EOF)
        advance(p);
    if (peek(p)->kind == TOKEN_LT)
        skip_balanced_tokens(p, TOKEN_LT, TOKEN_GT);
    if (peek(p)->kind == TOKEN_LPAREN)
        skip_balanced_tokens(p, TOKEN_LPAREN, TOKEN_RPAREN);
    /* 跳过 `: return_type` 直至 `{` 或 extern 的 `;` */
    while (peek(p)->kind != TOKEN_LBRACE && peek(p)->kind != TOKEN_SEMICOLON && peek(p)->kind != TOKEN_EOF)
        advance(p);
    if (peek(p)->kind == TOKEN_LBRACE)
        skip_balanced_tokens(p, TOKEN_LBRACE, TOKEN_RBRACE);
    else {
        while (peek(p)->kind != TOKEN_SEMICOLON && peek(p)->kind != TOKEN_EOF)
            advance(p);
        if (peek(p)->kind == TOKEN_SEMICOLON)
            advance(p);
    }
}

/**
 * B-01：跳过一条顶层 struct 定义（不建 AST）。
 */
static void skip_one_top_level_struct(Parser *p) {
    if (peek(p)->kind != TOKEN_STRUCT)
        return;
    advance(p);
    while (peek(p)->kind != TOKEN_LBRACE && peek(p)->kind != TOKEN_EOF)
        advance(p);
    skip_balanced_tokens(p, TOKEN_LBRACE, TOKEN_RBRACE);
}

/**
 * 解析单条函数定义：function name ( [ param : type , ... ] ) : type { block } 或 extern function name (...) : type ;
 * 当 is_extern 非 0 时，当前 Token 须为 TOKEN_FUNCTION（extern 已在上层消费），结尾为 ; 且 body 为 NULL。
 * 返回值：成功返回新分配的 ASTFunc*（调用方由 ast_module_free 统一释放）；失败返回 NULL 且已 fail。
 */
static ASTFunc *parse_one_function(Parser *p, int is_extern, int is_async) {
    if (peek(p)->kind != TOKEN_FUNCTION) return NULL;
    advance(p);
    /* 函数名允许 IDENT 或关键字 panic/abort、或类型关键字 u32/u64/bool（std.random 中 function u32(): u32 等合法） */
    char *name = NULL;
    int name_line = 0, name_col = 0; /* LSP 用：函数名所在位置 */
    if (peek(p)->kind == TOKEN_IDENT) {
        name = strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len);
        name_line = peek(p)->line;
        name_col = peek(p)->col;
    } else if (peek(p)->kind == TOKEN_PANIC) {
        name = strdup("panic");
        name_line = peek(p)->line;
        name_col = peek(p)->col;
    } else if (peek(p)->kind == TOKEN_U32) {
        name = strdup("u32");
        name_line = peek(p)->line;
        name_col = peek(p)->col;
    } else if (peek(p)->kind == TOKEN_U64) {
        name = strdup("u64");
        name_line = peek(p)->line;
        name_col = peek(p)->col;
    } else if (peek(p)->kind == TOKEN_BOOL) {
        name = strdup("bool");
        name_line = peek(p)->line;
        name_col = peek(p)->col;
    } else if (peek(p)->kind == TOKEN_SPAWN) {
        /* std.process 的 function spawn(...) 与 async spawn 关键字同名；声明位置允许作函数名 */
        name = strdup("spawn");
        name_line = peek(p)->line;
        name_col = peek(p)->col;
    } else if (peek(p)->kind == TOKEN_MATCH) {
        /* std.regex 的 function match(...) 与 match 关键字同名；声明位置允许作函数名 */
        name = strdup("match");
        name_line = peek(p)->line;
        name_col = peek(p)->col;
    } else {
        fail(p, "expected function name after 'function'");
        return NULL;
    }
    if (!name) {
        parser_oom(p);
        return NULL;
    }
    advance(p);
    /* 可选泛型参数：function name < T (, U)* > ( ... )（阶段 7.1） */
    char **gp_names = NULL;
    int n_gp = 0;
    if (parse_generic_param_list(p, &gp_names, &n_gp) != 0) {
        free(name);
        return NULL;
    }
    if (peek(p)->kind != TOKEN_LPAREN) {
        free(name);
        if (gp_names) {
            for (int i = 0; i < n_gp; i++) free(gp_names[i]);
            free(gp_names);
        }
        fail(p, "expected '(' after function name");
        return NULL;
    }
    advance(p);
    int params_cap = AST_FUNC_PARAMS_INIT;
    ASTParam *params = (ASTParam *)malloc((size_t)params_cap * sizeof(ASTParam));
    if (!params) {
        free(name);
        if (gp_names) { for (int i = 0; i < n_gp; i++) free(gp_names[i]); free(gp_names); }
        parser_oom(p);
        return NULL;
    }
    (void)memset(params, 0, (size_t)params_cap * sizeof(ASTParam));
    int num_params = 0;
    while (peek(p)->kind != TOKEN_RPAREN) {
        ASTParam *np = parser_grow_params(params, &params_cap, num_params + 1);
        if (!np) {
            free(name);
            if (gp_names) { for (int i = 0; i < n_gp; i++) free(gp_names[i]); free(gp_names); }
            for (int i = 0; i < num_params; i++) {
                if (params[i].name) free((void *)params[i].name);
                if (params[i].type) ast_type_free(params[i].type);
            }
            free(params);
            parser_oom(p);
            return NULL;
        }
        params = np;
        if (peek(p)->kind != TOKEN_IDENT) {
            free(name);
            if (gp_names) { for (int i = 0; i < n_gp; i++) free(gp_names[i]); free(gp_names); }
            for (int i = 0; i < num_params; i++) {
                if (params[i].name) free((void *)params[i].name);
                if (params[i].type) ast_type_free(params[i].type);
            }
            free(params);
            fail(p, "expected parameter name");
            return NULL;
        }
        params[num_params].name = strndup(peek(p)->value.ident, (size_t)peek(p)->ident_len);
        advance(p);
        if (peek(p)->kind != TOKEN_COLON) {
            free(name);
            if (gp_names) { for (int i = 0; i < n_gp; i++) free(gp_names[i]); free(gp_names); }
            if (params[num_params].name) free((void *)params[num_params].name);
            for (int i = 0; i < num_params; i++) {
                if (params[i].name) free((void *)params[i].name);
                if (params[i].type) ast_type_free(params[i].type);
            }
            free(params);
            fail(p, "expected ':' after parameter name");
            return NULL;
        }
        advance(p);
        params[num_params].type = parse_type(p);
        if (!params[num_params].type) {
            free(name);
            if (gp_names) { for (int i = 0; i < n_gp; i++) free(gp_names[i]); free(gp_names); }
            if (params[num_params].name) free((void *)params[num_params].name);
            for (int i = 0; i < num_params; i++) {
                if (params[i].name) free((void *)params[i].name);
                if (params[i].type) ast_type_free(params[i].type);
            }
            free(params);
            return NULL;
        }
        num_params++;
        if (peek(p)->kind == TOKEN_RPAREN) break;
        if (peek(p)->kind != TOKEN_COMMA) {
            free(name);
            if (gp_names) { for (int i = 0; i < n_gp; i++) free(gp_names[i]); free(gp_names); }
            for (int i = 0; i < num_params; i++) {
                if (params[i].name) free((void *)params[i].name);
                if (params[i].type) ast_type_free(params[i].type);
            }
            free(params);
            fail(p, "expected ',' or ')' in parameter list");
            return NULL;
        }
        advance(p);
    }
    advance(p);  /* consume ')' */
    if (peek(p)->kind != TOKEN_COLON) {
        free(name);
        if (gp_names) { for (int i = 0; i < n_gp; i++) free(gp_names[i]); free(gp_names); }
        for (int i = 0; i < num_params; i++) {
            if (params[i].name) free((void *)params[i].name);
            if (params[i].type) ast_type_free(params[i].type);
        }
        free(params);
        fail(p, "expected ':' for return type");
        return NULL;
    }
    advance(p);
    ASTType *return_type = parse_type(p);
    if (!return_type) {
        free(name);
        if (gp_names) { for (int i = 0; i < n_gp; i++) free(gp_names[i]); free(gp_names); }
        for (int i = 0; i < num_params; i++) {
            if (params[i].name) free((void *)params[i].name);
            if (params[i].type) ast_type_free(params[i].type);
        }
        free(params);
        return NULL;
    }
    ASTBlock *body = NULL;
    if (is_extern) {
        if (peek(p)->kind != TOKEN_SEMICOLON) {
            free(name);
            if (gp_names) { for (int i = 0; i < n_gp; i++) free(gp_names[i]); free(gp_names); }
            ast_type_free(return_type);
            for (int i = 0; i < num_params; i++) {
                if (params[i].name) free((void *)params[i].name);
                if (params[i].type) ast_type_free(params[i].type);
            }
            free(params);
            fail(p, "expected ';' after extern function signature");
            return NULL;
        }
        advance(p);
    } else {
        if (peek(p)->kind != TOKEN_LBRACE) {
            free(name);
            if (gp_names) { for (int i = 0; i < n_gp; i++) free(gp_names[i]); free(gp_names); }
            ast_type_free(return_type);
            for (int i = 0; i < num_params; i++) {
                if (params[i].name) free((void *)params[i].name);
                if (params[i].type) ast_type_free(params[i].type);
            }
            free(params);
            fail(p, "expected '{' before function body");
            return NULL;
        }
        advance(p);
        body = parse_block(p, 1, 1);
        if (!body) {
            free(name);
            if (gp_names) { for (int i = 0; i < n_gp; i++) free(gp_names[i]); free(gp_names); }
            ast_type_free(return_type);
            for (int i = 0; i < num_params; i++) {
                if (params[i].name) free((void *)params[i].name);
                if (params[i].type) ast_type_free(params[i].type);
            }
            free(params);
            return NULL;
        }
    }
    ASTFunc *func = (ASTFunc *)malloc(sizeof(ASTFunc));
    if (!func) {
        free(name);
        if (gp_names) { for (int i = 0; i < n_gp; i++) free(gp_names[i]); free(gp_names); }
        ast_type_free(return_type);
        ast_block_free(body);
        for (int i = 0; i < num_params; i++) {
            if (params[i].name) free((void *)params[i].name);
            if (params[i].type) ast_type_free(params[i].type);
        }
        free(params);
        parser_oom(p);
        return NULL;
    }
    func->line = name_line;
    func->col = name_col;
    func->name = name;
    func->section = NULL;  /* K4b：#[link_section] 由顶层循环后填 */
    func->is_entry = 0;  /* K5：#[entry] 由顶层循环后填 */
    func->is_used = 0;  /* K10：#[used] 由顶层循环后填 */
    func->is_naked = 0;
    func->is_no_mangle = 0;
    func->link_name = NULL;
    func->max_stack = 0;
    func->is_interrupt = 0;
    func->is_global_allocator = 0;
    func->is_cold = 0;
    func->is_inline_never = 0;
    func->is_inline_always = 0;
    func->export_name = NULL;
    func->is_panic_handler = 0;
    func->generic_param_names = gp_names;
    func->num_generic_params = n_gp;
    func->params = (num_params > 0) ? params : NULL;
    func->num_params = num_params;
    if (num_params == 0) free(params);
    func->return_type = return_type;
    func->body = body;
    func->is_extern = is_extern ? 1 : 0;
    func->is_async = is_async ? 1 : 0;
    func->impl_for_trait = NULL;
    func->impl_for_type = NULL;
    return func;
}

/**
 * B-01：跳过一条顶层 `const ... ;`（含 const x = import("path");），不建 AST。
 */
static void skip_one_top_level_const_decl(Parser *p) {
    if (peek(p)->kind != TOKEN_CONST)
        return;
    advance(p);
    while (peek(p)->kind != TOKEN_SEMICOLON && peek(p)->kind != TOKEN_EOF)
        advance(p);
    if (peek(p)->kind == TOKEN_SEMICOLON)
        advance(p);
}

/* parse 的完整说明见 parser.h */
int parse(Lexer *lex, ASTModule **out) {
    if (!out) return -1;
    *out = NULL;

    Parser prs = { .lex = lex, .cur_loaded = 0, .next_loaded = 0, .next_next_loaded = 0 };

    ASTModule *mod = (ASTModule *)malloc(sizeof(ASTModule));
    if (!mod) {
        parser_oom_global();
        return -1;
    }
    mod->import_paths = NULL;
    mod->num_imports = 0;
    mod->import_kinds = NULL;
    mod->import_binding_names = NULL;
    mod->import_select_names = NULL;
    mod->import_select_aliases = NULL;
    mod->import_select_counts = NULL;
    mod->top_level_lets = NULL;
    mod->num_top_level_lets = 0;
    mod->struct_defs = NULL;
    mod->num_structs = 0;
    mod->enum_defs = NULL;
    mod->num_enums = 0;
    mod->trait_defs = NULL;
    mod->num_traits = 0;
    mod->impl_blocks = NULL;
    mod->num_impl_blocks = 0;
    mod->funcs = NULL;
    mod->num_funcs = 0;
    mod->main_func = NULL;
    mod->mono_instances = NULL;
    mod->num_mono_instances = 0;

    /* [ const IDENT = import("path") ; ]* — 与 Zig @import 一致，仅绑定 import */
    char *import_list[MAX_IMPORTS];
    int kind_list[MAX_IMPORTS];
    char *binding_list[MAX_IMPORTS];
    char **select_names_list[MAX_IMPORTS];
    char **select_aliases_list[MAX_IMPORTS];
    int select_count_list[MAX_IMPORTS];
    int nimports = 0;
#define FREE_IMPORT_AUX do { \
        for (int _ii = 0; _ii < nimports; _ii++) { \
            if (kind_list[_ii] == AST_IMPORT_KIND_BINDING && binding_list[_ii]) free(binding_list[_ii]); \
            if (kind_list[_ii] == AST_IMPORT_KIND_SELECT && select_names_list[_ii]) { \
                for (int _jj = 0; _jj < select_count_list[_ii]; _jj++) { \
                    if (select_names_list[_ii][_jj]) free(select_names_list[_ii][_jj]); \
                    if (select_aliases_list[_ii] && select_aliases_list[_ii][_jj]) free(select_aliases_list[_ii][_jj]); \
                } \
                free(select_names_list[_ii]); \
                if (select_aliases_list[_ii]) free(select_aliases_list[_ii]); \
            } \
        } \
    } while (0)
    int pending_cfg_skip_import = 0;
    while (1) {
        /** B-01/B-19：`#[cfg]` 不匹配 host 时跳过紧随其后的 const import 绑定。 */
        if (peek(&prs)->kind == TOKEN_ATTR_CFG) {
            pending_cfg_skip_import = (peek(&prs)->value.int_val == 0) ? 1 : 0;
            advance(&prs);
            continue;
        }
        if (pending_cfg_skip_import) {
            if (peek(&prs)->kind == TOKEN_CONST) {
                skip_one_top_level_const_decl(&prs);
                pending_cfg_skip_import = 0;
                continue;
            }
            /** B-02：import 区段遇 #[cfg] 后亦须跳过 function/struct（与顶层循环一致）。 */
            if (peek(&prs)->kind == TOKEN_STRUCT) {
                skip_one_top_level_struct(&prs);
                pending_cfg_skip_import = 0;
                continue;
            }
            if (peek(&prs)->kind == TOKEN_ASYNC || peek(&prs)->kind == TOKEN_EXTERN
                || peek(&prs)->kind == TOKEN_FUNCTION) {
                skip_one_top_level_function(&prs);
                pending_cfg_skip_import = 0;
                continue;
            }
            pending_cfg_skip_import = 0;
        }
        if (peek(&prs)->kind == TOKEN_CONST) {
            /* 仅当确定为 const x = import 时才 consume const，否则 break 交给后续顶层循环处理普通 const */
            if (peek_next(&prs)->kind == TOKEN_IDENT && peek_next_next(&prs)->kind == TOKEN_ASSIGN) {
                advance(&prs); /* const */
                char *name = (peek(&prs)->ident_len > 0 && peek(&prs)->value.ident)
                    ? strndup(peek(&prs)->value.ident, (size_t)peek(&prs)->ident_len) : NULL;
                if (!name) {
                    FREE_IMPORT_AUX;
                    free(mod);
                    return -1;
                }
                advance(&prs); advance(&prs); /* IDENT = */
                if (peek(&prs)->kind != TOKEN_IMPORT) {
                    free(name);
                    fail(&prs, "expected const x = import(\"path\")");
                    if (parser_top_level_recovery_enabled()) {
                        parser_recover_top_level_boundary(&prs);
                        continue;
                    }
                    while (nimports--) free(import_list[nimports]);
                    FREE_IMPORT_AUX;
                    free(mod);
                    return -1;
                }
                advance(&prs); /* import */
                char *path = parse_import_call_path(&prs);
                if (!path) {
                    free(name);
                    if (parser_top_level_recovery_enabled()) {
                        parser_recover_top_level_boundary(&prs);
                        continue;
                    }
                    while (nimports--) free(import_list[nimports]);
                    FREE_IMPORT_AUX;
                    free(mod);
                    return -1;
                }
                if (peek(&prs)->kind != TOKEN_SEMICOLON) {
                    free(name); free(path);
                    fail(&prs, "expected ';' after const x = import(\"path\")");
                    if (parser_top_level_recovery_enabled()) {
                        parser_recover_top_level_boundary(&prs);
                        continue;
                    }
                    while (nimports--) free(import_list[nimports]);
                    FREE_IMPORT_AUX;
                    free(mod);
                    return -1;
                }
                advance(&prs);
                if (nimports >= MAX_IMPORTS) {
                    free(name); free(path);
                    fail(&prs, "too many imports");
                    while (nimports--) free(import_list[nimports]);
                    FREE_IMPORT_AUX;
                    free(mod);
                    return -1;
                }
                import_list[nimports] = path;
                kind_list[nimports] = AST_IMPORT_KIND_BINDING;
                binding_list[nimports] = name;
                select_names_list[nimports] = NULL;
                select_aliases_list[nimports] = NULL;
                select_count_list[nimports] = 0;
                nimports++;
            } else {
                /* 普通 const（如 const X: Type = expr;），不 consume，交给后续顶层循环 */
                break;
            }
        } else
            break;
    }
#undef FREE_IMPORT_AUX

    /* [ let IDENT : Type = expr ; ]* 顶层 let（与 import 同级，在 enum/struct 前） */
    ASTLetDecl toplevel_let_list[MAX_TOP_LEVEL_LETS];
    int ntoplets = 0;
#define FREE_TOPLEVEL_LETS do { \
        for (int _ti = 0; _ti < ntoplets; _ti++) { \
            if (toplevel_let_list[_ti].name) free((void *)toplevel_let_list[_ti].name); \
            if (toplevel_let_list[_ti].type) ast_type_free(toplevel_let_list[_ti].type); \
            if (toplevel_let_list[_ti].init) ast_expr_free(toplevel_let_list[_ti].init); \
        } \
    } while (0)
    while (peek(&prs)->kind == TOKEN_LET) {
        if (ntoplets >= MAX_TOP_LEVEL_LETS) {
            fail(&prs, "too many top-level let declarations");
            while (nimports--) free(import_list[nimports]);
            FREE_TOPLEVEL_LETS;
            free(mod);
            return -1;
        }
        advance(&prs);
        if (peek(&prs)->kind != TOKEN_IDENT && peek(&prs)->kind != TOKEN_UNDERSCORE) {
            fail(&prs, "expected identifier after let");
            while (nimports--) free(import_list[nimports]);
            FREE_TOPLEVEL_LETS;
            free(mod);
            return -1;
        }
        char *let_name = (peek(&prs)->kind == TOKEN_UNDERSCORE) ? strdup("_") : ((peek(&prs)->ident_len > 0 && peek(&prs)->value.ident)
            ? strndup(peek(&prs)->value.ident, (size_t)peek(&prs)->ident_len) : NULL);
        if (!let_name) {
            while (nimports--) free(import_list[nimports]);
            FREE_TOPLEVEL_LETS;
            free(mod);
            return -1;
        }
        advance(&prs);
        if (peek(&prs)->kind != TOKEN_COLON) {
            free(let_name);
            fail(&prs, "expected ':' and type in top-level let");
            while (nimports--) free(import_list[nimports]);
            FREE_TOPLEVEL_LETS;
            free(mod);
            return -1;
        }
        advance(&prs);
        ASTType *let_type = parse_type(&prs);
        if (!let_type) {
            free(let_name);
            while (nimports--) free(import_list[nimports]);
            FREE_TOPLEVEL_LETS;
            free(mod);
            return -1;
        }
        if (peek(&prs)->kind != TOKEN_ASSIGN) {
            free(let_name);
            ast_type_free(let_type);
            fail(&prs, "expected '=' in top-level let");
            while (nimports--) free(import_list[nimports]);
            FREE_TOPLEVEL_LETS;
            free(mod);
            return -1;
        }
        advance(&prs);
        ASTExpr *let_init = parse_expr(&prs);
        if (!let_init) {
            free(let_name);
            ast_type_free(let_type);
            while (nimports--) free(import_list[nimports]);
            FREE_TOPLEVEL_LETS;
            free(mod);
            return -1;
        }
        if (peek(&prs)->kind != TOKEN_SEMICOLON) {
            free(let_name);
            ast_type_free(let_type);
            ast_expr_free(let_init);
            fail(&prs, "expected ';' after top-level let");
            while (nimports--) free(import_list[nimports]);
            FREE_TOPLEVEL_LETS;
            free(mod);
            return -1;
        }
        advance(&prs);
        toplevel_let_list[ntoplets].name = let_name;
        toplevel_let_list[ntoplets].type = let_type;
        toplevel_let_list[ntoplets].init = let_init;
        ntoplets++;
    }
#undef FREE_TOPLEVEL_LETS

    /* 将顶层 let 拷贝到 mod，后续错误路径仅需 free(mod)，由 ast_module_free 释放 */
    if (ntoplets > 0) {
        mod->top_level_lets = (ASTLetDecl *)malloc((size_t)ntoplets * sizeof(ASTLetDecl));
        if (!mod->top_level_lets) {
            for (int _ti = 0; _ti < ntoplets; _ti++) {
                if (toplevel_let_list[_ti].name) free((void *)toplevel_let_list[_ti].name);
                if (toplevel_let_list[_ti].type) ast_type_free(toplevel_let_list[_ti].type);
                if (toplevel_let_list[_ti].init) ast_expr_free(toplevel_let_list[_ti].init);
            }
            while (nimports--) free(import_list[nimports]);
            free(mod);
            parser_oom_global();
            return -1;
        }
        for (int i = 0; i < ntoplets; i++) {
            mod->top_level_lets[i].name = toplevel_let_list[i].name;
            mod->top_level_lets[i].type = toplevel_let_list[i].type;
            mod->top_level_lets[i].init = toplevel_let_list[i].init;
            mod->top_level_lets[i].is_const = 0;
            mod->top_level_lets[i].section = NULL;  /* K4：预扫描 let 无段属性 */
        }
        mod->num_top_level_lets = ntoplets;
    }

    /* [ enum Name { A, B, C } ]*（§7.4 无负载枚举）；允许在 struct 前，便于 struct 字段引用 enum 类型 */
    ASTStructDef *struct_list[MAX_STRUCTS];
    int nstructs = 0;
    ASTEnumDef *enum_list[MAX_ENUMS];
    int nenums = 0;
    while (peek(&prs)->kind == TOKEN_ENUM) {
        ASTEnumDef *e = parse_one_enum(&prs);
        if (!e) {
            while (nimports--) free(import_list[nimports]);
            while (nstructs--) ast_struct_def_free(struct_list[nstructs]);
            while (nenums--) ast_enum_def_free(enum_list[nenums]);
            free(mod);
            return -1;
        }
        if (nenums >= MAX_ENUMS) {
            ast_enum_def_free(e);
            while (nimports--) free(import_list[nimports]);
            while (nstructs--) ast_struct_def_free(struct_list[nstructs]);
            while (nenums--) ast_enum_def_free(enum_list[nenums]);
            free(mod);
            fail(&prs, "too many enum definitions");
            return -1;
        }
        enum_list[nenums++] = e;
    }

    /* [ allow(padding) ]? struct Name { field : Type ; ... } 可重复；§11.1 allow(padding) 表示允许隐式 padding */
    while (1) {
        int allow_padding = 0;
        if (is_ident_str(&prs, "allow", 5)) {
            advance(&prs);
            if (peek(&prs)->kind != TOKEN_LPAREN) {
                while (nimports--) free(import_list[nimports]);
                while (nstructs--) ast_struct_def_free(struct_list[nstructs]);
                while (nenums--) ast_enum_def_free(enum_list[nenums]);
                free(mod);
                fail(&prs, "expected '(' after 'allow'");
                return -1;
            }
            advance(&prs);
            if (!is_ident_str(&prs, "padding", 7)) {
                while (nimports--) free(import_list[nimports]);
                while (nstructs--) ast_struct_def_free(struct_list[nstructs]);
                while (nenums--) ast_enum_def_free(enum_list[nenums]);
                free(mod);
                fail(&prs, "expected 'padding' inside allow(...)");
                return -1;
            }
            advance(&prs);
            if (peek(&prs)->kind != TOKEN_RPAREN) {
                while (nimports--) free(import_list[nimports]);
                while (nstructs--) ast_struct_def_free(struct_list[nstructs]);
                while (nenums--) ast_enum_def_free(enum_list[nenums]);
                free(mod);
                fail(&prs, "expected ')' to close allow(...)");
                return -1;
            }
            advance(&prs);
            allow_padding = 1;
        }
        if (peek(&prs)->kind != TOKEN_STRUCT) break;
        ASTStructDef *s = parse_one_struct(&prs, allow_padding, 0, 0, 0);
        if (!s) {
            while (nimports--) free(import_list[nimports]);
            while (nstructs--) ast_struct_def_free(struct_list[nstructs]);
            while (nenums--) ast_enum_def_free(enum_list[nenums]);
            free(mod);
            return -1;
        }
        if (nstructs >= MAX_STRUCTS) {
            ast_struct_def_free(s);
            while (nimports--) free(import_list[nimports]);
            while (nstructs--) ast_struct_def_free(struct_list[nstructs]);
            while (nenums--) ast_enum_def_free(enum_list[nenums]);
            free(mod);
            fail(&prs, "too many struct definitions");
            return -1;
        }
        struct_list[nstructs++] = s;
    }

    /* [ trait Name { function method(self) -> type ; ... } ]*（阶段 7.2） */
    ASTTraitDef *trait_list[AST_MODULE_MAX_TRAITS];
    int ntraits = 0;
    while (peek(&prs)->kind == TOKEN_TRAIT) {
        ASTTraitDef *t = parse_one_trait(&prs);
        if (!t) {
            while (nimports--) free(import_list[nimports]);
            while (nstructs--) ast_struct_def_free(struct_list[nstructs]);
            while (nenums--) ast_enum_def_free(enum_list[nenums]);
            while (ntraits--) ast_trait_def_free(trait_list[ntraits]);
            free(mod);
            return -1;
        }
        if (ntraits >= AST_MODULE_MAX_TRAITS) {
            ast_trait_def_free(t);
            while (nimports--) free(import_list[nimports]);
            while (nstructs--) ast_struct_def_free(struct_list[nstructs]);
            while (nenums--) ast_enum_def_free(enum_list[nenums]);
            while (ntraits--) ast_trait_def_free(trait_list[ntraits]);
            free(mod);
            fail(&prs, "too many trait definitions");
            return -1;
        }
        trait_list[ntraits++] = t;
    }

    /* [ impl Trait for Type { function method(...) { ... } ... } ]*（阶段 7.2） */
    ASTImplBlock *impl_list[AST_MODULE_MAX_IMPLS];
    int nimpls = 0;
    while (peek(&prs)->kind == TOKEN_IMPL) {
        ASTImplBlock *impl = parse_one_impl(&prs);
        if (!impl) {
            while (nimports--) free(import_list[nimports]);
            while (nstructs--) ast_struct_def_free(struct_list[nstructs]);
            while (nenums--) ast_enum_def_free(enum_list[nenums]);
            while (ntraits--) ast_trait_def_free(trait_list[ntraits]);
            while (nimpls--) ast_impl_block_free(impl_list[nimpls]);
            free(mod);
            return -1;
        }
        if (nimpls >= AST_MODULE_MAX_IMPLS) {
            ast_impl_block_free(impl);
            while (nimports--) free(import_list[nimports]);
            while (nstructs--) ast_struct_def_free(struct_list[nstructs]);
            while (nenums--) ast_enum_def_free(enum_list[nenums]);
            while (ntraits--) ast_trait_def_free(trait_list[ntraits]);
            while (nimpls--) ast_impl_block_free(impl_list[nimpls]);
            free(mod);
            fail(&prs, "too many impl blocks");
            return -1;
        }
        impl_list[nimpls++] = impl;
    }

    /* [ extern? function | allow(padding)? struct | enum | let ]*；允许 struct/enum/function 与顶层 let 任意交错。 */
    int func_cap = AST_MODULE_FUNCS_INIT;
    ASTFunc **func_list = (ASTFunc **)malloc((size_t)func_cap * sizeof(ASTFunc *));
    if (!func_list) {
        parser_oom_global();
        while (nimports--) free(import_list[nimports]);
        while (nstructs--) ast_struct_def_free(struct_list[nstructs]);
        while (nenums--) ast_enum_def_free(enum_list[nenums]);
        while (ntraits--) ast_trait_def_free(trait_list[ntraits]);
        while (nimpls--) ast_impl_block_free(impl_list[nimpls]);
        free(mod);
        return -1;
    }
    int nfuncs = 0;
    int pending_soa = 0;
    int pending_cfg_skip = 0;
    int pending_repr_c = 0;
    int pending_repr_compatible = 0;
    char *pending_link_section = NULL;  /* K4：#[link_section] 段名，应用于下一顶层 const/let */
    int pending_naked = 0;          /* K3：#[naked]，应用于下一顶层 function */
    int pending_entry = 0;          /* K5：#[entry]，应用于下一顶层 function（入口 _start） */
    int pending_used = 0;           /* K10：#[used]，应用于下一顶层 function */
    int pending_no_mangle = 0;      /* L9：#[no_mangle]，应用于下一顶层 function */
    char *pending_link_name = NULL; /* L9：#[link_name("name")]，应用于下一顶层 function */
    int pending_max_stack = 0;  /* L4：#[max_stack(N)]，应用于下一顶层 function */
    int pending_interrupt = 0;  /* A1：#[interrupt]，应用于下一顶层 function */
    int pending_global_allocator = 0;  /* L1：#[global_allocator]，应用于下一顶层 function */
    int pending_cold = 0;           /* #[cold] */
    int pending_inline_never = 0;   /* #[inline(never)] */
    int pending_inline_always = 0;  /* #[inline(always)] */
    int pending_panic_handler = 0;  /* #[panic_handler] */
    int pending_thread_local = 0;  /* #[thread_local] */
    int pending_percpu = 0;        /* #[percpu] */
    char *pending_export_name = NULL; /* #[export_name("name")] */
    int pending_send = 0;      /* L6：#[send]，应用于下一 struct */
    int pending_sync = 0;      /* L6：#[sync]，应用于下一 struct */
    while (peek(&prs)->kind == TOKEN_EXTERN || peek(&prs)->kind == TOKEN_ASYNC || peek(&prs)->kind == TOKEN_FUNCTION
           || peek(&prs)->kind == TOKEN_STRUCT || peek(&prs)->kind == TOKEN_ENUM
           || peek(&prs)->kind == TOKEN_ATTR_SOA || peek(&prs)->kind == TOKEN_ATTR_CFG
           || peek(&prs)->kind == TOKEN_ATTR_REPR_C || peek(&prs)->kind == TOKEN_ATTR_REPR_COMPATIBLE
           || peek(&prs)->kind == TOKEN_ATTR_ALLOC
           || peek(&prs)->kind == TOKEN_ATTR_LINK_SECTION
           || peek(&prs)->kind == TOKEN_ATTR_NAKED
           || peek(&prs)->kind == TOKEN_ATTR_ENTRY
           || peek(&prs)->kind == TOKEN_ATTR_USED
           || peek(&prs)->kind == TOKEN_ATTR_NO_MANGLE
           || peek(&prs)->kind == TOKEN_ATTR_LINK_NAME
           || peek(&prs)->kind == TOKEN_ATTR_MAX_STACK
           || peek(&prs)->kind == TOKEN_ATTR_INTERRUPT
           || peek(&prs)->kind == TOKEN_ATTR_GLOBAL_ALLOCATOR
           || peek(&prs)->kind == TOKEN_ATTR_COLD
           || peek(&prs)->kind == TOKEN_ATTR_PANIC_HANDLER
           || peek(&prs)->kind == TOKEN_ATTR_EXPORT_NAME
           || peek(&prs)->kind == TOKEN_ATTR_INLINE_NEVER
           || peek(&prs)->kind == TOKEN_ATTR_INLINE_ALWAYS
           || peek(&prs)->kind == TOKEN_ATTR_THREAD_LOCAL
           || peek(&prs)->kind == TOKEN_ATTR_PERCPU
           || peek(&prs)->kind == TOKEN_ATTR_SEND
           || peek(&prs)->kind == TOKEN_ATTR_SYNC
           || peek(&prs)->kind == TOKEN_LET || peek(&prs)->kind == TOKEN_CONST
           || (peek(&prs)->kind == TOKEN_IDENT && is_ident_str(&prs, "allow", 5))) {
        /* 顶层 let：与 function/struct/enum 同级，可任意顺序出现 */
        if (peek(&prs)->kind == TOKEN_LET) {
            if (mod->num_top_level_lets >= MAX_TOP_LEVEL_LETS) {
                fail(&prs, "too many top-level let declarations");
                goto cleanup_funcs_fail;
            }
            advance(&prs);
            if (peek(&prs)->kind != TOKEN_IDENT && peek(&prs)->kind != TOKEN_UNDERSCORE) {
                fail(&prs, "expected identifier after let");
                goto cleanup_funcs_fail;
            }
            char *let_name = (peek(&prs)->kind == TOKEN_UNDERSCORE) ? strdup("_") : ((peek(&prs)->ident_len > 0 && peek(&prs)->value.ident)
                ? strndup(peek(&prs)->value.ident, (size_t)peek(&prs)->ident_len) : NULL);
            if (!let_name) goto cleanup_funcs_fail;
            advance(&prs);
            if (peek(&prs)->kind != TOKEN_COLON) {
                free(let_name);
                fail(&prs, "expected ':' and type in top-level let");
                goto cleanup_funcs_fail;
            }
            advance(&prs);
            ASTType *let_type = parse_type(&prs);
            if (!let_type) {
                free(let_name);
                goto cleanup_funcs_fail;
            }
            if (peek(&prs)->kind != TOKEN_ASSIGN) {
                free(let_name);
                ast_type_free(let_type);
                fail(&prs, "expected '=' in top-level let");
                goto cleanup_funcs_fail;
            }
            advance(&prs);
            ASTExpr *let_init = parse_expr(&prs);
            if (!let_init) {
                free(let_name);
                ast_type_free(let_type);
                goto cleanup_funcs_fail;
            }
            if (peek(&prs)->kind != TOKEN_SEMICOLON) {
                free(let_name);
                ast_type_free(let_type);
                ast_expr_free(let_init);
                fail(&prs, "expected ';' after top-level let");
                goto cleanup_funcs_fail;
            }
            advance(&prs);
            ASTLetDecl *new_lets = (ASTLetDecl *)realloc(mod->top_level_lets, (size_t)(mod->num_top_level_lets + 1) * sizeof(ASTLetDecl));
            if (!new_lets) {
                free(let_name);
                ast_type_free(let_type);
                ast_expr_free(let_init);
                goto cleanup_funcs_fail;
            }
            mod->top_level_lets = new_lets;
            mod->top_level_lets[mod->num_top_level_lets].name = let_name;
            mod->top_level_lets[mod->num_top_level_lets].type = let_type;
            mod->top_level_lets[mod->num_top_level_lets].init = let_init;
            mod->top_level_lets[mod->num_top_level_lets].is_const = 0;
            mod->top_level_lets[mod->num_top_level_lets].section = pending_link_section;  /* K4 */
            mod->top_level_lets[mod->num_top_level_lets].is_thread_local = pending_thread_local;
            mod->top_level_lets[mod->num_top_level_lets].is_percpu = pending_percpu;
            pending_thread_local = 0;
            pending_percpu = 0;
            pending_link_section = NULL;
            pending_naked = 0;  /* K3：const 不消费 naked */
            pending_entry = 0;  /* K5：const 不消费 entry */
            pending_used = 0;  /* K10：const 不消费 used */
            pending_no_mangle = 0;  /* L9：const 不消费 no_mangle */
            free(pending_link_name); pending_link_name = NULL;  /* L9：const 不消费 link_name */
            pending_max_stack = 0;  /* L4：const 不消费 max_stack */
            pending_interrupt = 0;  /* A1：const 不消费 interrupt */
            pending_send = 0;  /* L6：const 不消费 send/sync */
            pending_sync = 0;
            mod->num_top_level_lets++;
            continue;
        }
        /* 顶层 const：const IDENT : Type = expr ;，与 let 同级，可任意顺序 */
        if (peek(&prs)->kind == TOKEN_CONST) {
            if (mod->num_top_level_lets >= MAX_TOP_LEVEL_LETS) {
                fail(&prs, "too many top-level const declarations");
                goto cleanup_funcs_fail;
            }
            advance(&prs);
            if (peek(&prs)->kind != TOKEN_IDENT && peek(&prs)->kind != TOKEN_UNDERSCORE) {
                fail(&prs, "expected identifier after const");
                goto cleanup_funcs_fail;
            }
            char *const_name = (peek(&prs)->kind == TOKEN_UNDERSCORE) ? strdup("_") : ((peek(&prs)->ident_len > 0 && peek(&prs)->value.ident)
                ? strndup(peek(&prs)->value.ident, (size_t)peek(&prs)->ident_len) : NULL);
            if (!const_name) goto cleanup_funcs_fail;
            advance(&prs);
            if (peek(&prs)->kind != TOKEN_COLON) {
                free(const_name);
                fail(&prs, "expected ':' and type in top-level const");
                goto cleanup_funcs_fail;
            }
            advance(&prs);
            ASTType *const_type = parse_type(&prs);
            if (!const_type) {
                free(const_name);
                goto cleanup_funcs_fail;
            }
            if (peek(&prs)->kind != TOKEN_ASSIGN) {
                free(const_name);
                ast_type_free(const_type);
                fail(&prs, "expected '=' in top-level const");
                goto cleanup_funcs_fail;
            }
            advance(&prs);
            ASTExpr *const_init = parse_expr(&prs);
            if (!const_init) {
                free(const_name);
                ast_type_free(const_type);
                goto cleanup_funcs_fail;
            }
            if (peek(&prs)->kind != TOKEN_SEMICOLON) {
                free(const_name);
                ast_type_free(const_type);
                ast_expr_free(const_init);
                fail(&prs, "expected ';' after top-level const");
                goto cleanup_funcs_fail;
            }
            advance(&prs);
            ASTLetDecl *new_const_lets = (ASTLetDecl *)realloc(mod->top_level_lets, (size_t)(mod->num_top_level_lets + 1) * sizeof(ASTLetDecl));
            if (!new_const_lets) {
                free(const_name);
                ast_type_free(const_type);
                ast_expr_free(const_init);
                goto cleanup_funcs_fail;
            }
            mod->top_level_lets = new_const_lets;
            mod->top_level_lets[mod->num_top_level_lets].name = const_name;
            mod->top_level_lets[mod->num_top_level_lets].type = const_type;
            mod->top_level_lets[mod->num_top_level_lets].init = const_init;
            mod->top_level_lets[mod->num_top_level_lets].is_const = 1;
            mod->top_level_lets[mod->num_top_level_lets].section = pending_link_section;  /* K4 */
            pending_link_section = NULL;
            mod->num_top_level_lets++;
            continue;
        }
        /** DOD-S1：`#[soa]` 属性；下一顶层 struct 记 soa。 */
        if (peek(&prs)->kind == TOKEN_ATTR_SOA) {
            advance(&prs);
            pending_soa = 1;
            continue;
        }
        /** B-01：`#[cfg(...)]` 属性；int_val==0 时剪枝紧随其后的顶层 function/struct。 */
        if (peek(&prs)->kind == TOKEN_ATTR_CFG) {
            pending_cfg_skip = (peek(&prs)->value.int_val == 0) ? 1 : 0;
            advance(&prs);
            continue;
        }
        /** B-03：`#[repr(C)]` 属性；下一顶层 struct 记 repr_c。 */
        if (peek(&prs)->kind == TOKEN_ATTR_REPR_C) {
            advance(&prs);
            pending_repr_c = 1;
            continue;
        }
        /** MOD-02：`#[repr(compatible)]` 属性；下一顶层 struct 记 repr_compatible。 */
        if (peek(&prs)->kind == TOKEN_ATTR_REPR_COMPATIBLE) {
            advance(&prs);
            pending_repr_compatible = 1;
            continue;
        }
        /** MEM-C1：`#[alloc]` 属性；下一 function 为 Allocator 自动注入 API，解析层仅跳过。 */
        if (peek(&prs)->kind == TOKEN_ATTR_ALLOC) {
            advance(&prs);
            continue;
        }
        /** K4：`#[link_section("name")]`；记录段名（strdup），应用于紧随其后的顶层 const/let。 */
        if (peek(&prs)->kind == TOKEN_ATTR_LINK_SECTION) {
            const Token *ls = peek(&prs);
            free(pending_link_section);
            pending_link_section = (ls->ident_len > 0 && ls->value.ident)
                ? strndup(ls->value.ident, (size_t)ls->ident_len) : NULL;
            advance(&prs);
            continue;
        }
        /** K3：`#[naked]`；标记下一 function 为 naked（无 prologue/epilogue）。 */
        if (peek(&prs)->kind == TOKEN_ATTR_NAKED) {
            pending_naked = 1;
            advance(&prs);
            continue;
        }
        /** K5：`#[entry]`；标记下一 function 为内核入口 _start。 */
        if (peek(&prs)->kind == TOKEN_ATTR_ENTRY) {
            pending_entry = 1;
            advance(&prs);
            continue;
        }
        /** K10：`#[used]`；标记下一 function 不被 C 编译器消除。 */
        if (peek(&prs)->kind == TOKEN_ATTR_USED) {
            pending_used = 1;
            advance(&prs);
            continue;
        }
        /** L9：`#[no_mangle]`；标记下一 function 外部链接+不 DCE。 */
        if (peek(&prs)->kind == TOKEN_ATTR_NO_MANGLE) {
            pending_no_mangle = 1;
            advance(&prs);
            continue;
        }
        /** L9：`#[link_name("name")]`；记录符号名（strdup），应用于下一 function。 */
        if (peek(&prs)->kind == TOKEN_ATTR_LINK_NAME) {
            const Token *ln = peek(&prs);
            free(pending_link_name);
            pending_link_name = (ln->ident_len > 0 && ln->value.ident)
                ? strndup(ln->value.ident, (size_t)ln->ident_len) : NULL;
            advance(&prs);
            continue;
        }
        /** L4：`#[max_stack(N)]`；记录栈用量上限，应用于下一 function。 */
        if (peek(&prs)->kind == TOKEN_ATTR_MAX_STACK) {
            const Token *ms = peek(&prs);
            pending_max_stack = (int)ms->value.int_val;
            advance(&prs);
            continue;
        }
        /** A1：`#[interrupt]`；标记下一 function 为中断处理（C 编译器自动 push/pop + iret）。 */
        if (peek(&prs)->kind == TOKEN_ATTR_INTERRUPT) {
            pending_interrupt = 1;
            advance(&prs);
            continue;
        }
        if (peek(&prs)->kind == TOKEN_ATTR_GLOBAL_ALLOCATOR) {
            pending_global_allocator = 1;
            advance(&prs);
            continue;
        }
        if (peek(&prs)->kind == TOKEN_ATTR_COLD) {
            pending_cold = 1; advance(&prs); continue;
        }
        if (peek(&prs)->kind == TOKEN_ATTR_PANIC_HANDLER) {
            pending_panic_handler = 1; advance(&prs); continue;
        }
        if (peek(&prs)->kind == TOKEN_ATTR_EXPORT_NAME) {
            const Token *en = peek(&prs);
            free(pending_export_name);
            pending_export_name = (en->ident_len > 0 && en->value.ident)
                ? strndup(en->value.ident, (size_t)en->ident_len) : NULL;
            advance(&prs); continue;
        }
        if (peek(&prs)->kind == TOKEN_ATTR_INLINE_NEVER) {
            pending_inline_never = 1; advance(&prs); continue;
        }
        if (peek(&prs)->kind == TOKEN_ATTR_INLINE_ALWAYS) {
            pending_inline_always = 1; advance(&prs); continue;
        }
        if (peek(&prs)->kind == TOKEN_ATTR_THREAD_LOCAL) {
            pending_thread_local = 1; advance(&prs); continue;
        }
        if (peek(&prs)->kind == TOKEN_ATTR_PERCPU) {
            pending_percpu = 1; advance(&prs); continue;
        }
        /** L6：`#[send]`；标记下一 struct 可安全跨线程传递（设计决策标记）。 */
        if (peek(&prs)->kind == TOKEN_ATTR_SEND) {
            pending_send = 1;
            advance(&prs);
            continue;
        }
        /** L6：`#[sync]`；标记下一 struct 可安全跨线程共享（设计决策标记）。 */
        if (peek(&prs)->kind == TOKEN_ATTR_SYNC) {
            pending_sync = 1;
            advance(&prs);
            continue;
        }
        if (pending_cfg_skip) {
            if (peek(&prs)->kind == TOKEN_STRUCT) {
                skip_one_top_level_struct(&prs);
                pending_cfg_skip = 0;
                continue;
            }
            if (peek(&prs)->kind == TOKEN_CONST) {
                skip_one_top_level_const_decl(&prs);
                pending_cfg_skip = 0;
                continue;
            }
            if (peek(&prs)->kind == TOKEN_ASYNC || peek(&prs)->kind == TOKEN_EXTERN
                || peek(&prs)->kind == TOKEN_FUNCTION) {
                skip_one_top_level_function(&prs);
                pending_cfg_skip = 0;
                continue;
            }
            pending_cfg_skip = 0;
        }
        int allow_padding = 0;
        if (peek(&prs)->kind == TOKEN_IDENT && is_ident_str(&prs, "allow", 5)) {
            advance(&prs);
            if (peek(&prs)->kind != TOKEN_LPAREN) goto cleanup_funcs_fail;
            advance(&prs);
            if (!is_ident_str(&prs, "padding", 7)) goto cleanup_funcs_fail;
            advance(&prs);
            if (peek(&prs)->kind != TOKEN_RPAREN) goto cleanup_funcs_fail;
            advance(&prs);
            allow_padding = 1;
            if (peek(&prs)->kind != TOKEN_STRUCT) {
                fail(&prs, "expected 'struct' after allow(padding)");
                goto cleanup_funcs_fail;
            }
        }
        if (peek(&prs)->kind == TOKEN_STRUCT) {
            int ps_struct = pending_soa;
            int pr_struct = pending_repr_c;
            int pc_struct = pending_repr_compatible;
            int send_struct = pending_send;  /* L6：capture #[send] */
            int sync_struct = pending_sync;  /* L6：capture #[sync] */
            pending_soa = 0;
            pending_repr_c = 0;
            pending_repr_compatible = 0;
            free(pending_link_section); pending_link_section = NULL;
            pending_naked = 0;
            pending_entry = 0;
            pending_used = 0;
            pending_no_mangle = 0;
            free(pending_link_name); pending_link_name = NULL;
            pending_max_stack = 0;
            pending_interrupt = 0;
            pending_send = 0;
            pending_sync = 0;
            ASTStructDef *s = parse_one_struct(&prs, allow_padding, ps_struct, pr_struct, pc_struct);
            if (!s) goto cleanup_funcs_fail;
            s->is_send = send_struct;  /* L6：#[send] 应用到 struct */
            s->is_sync = sync_struct;  /* L6：#[sync] 应用到 struct */
            if (nstructs >= MAX_STRUCTS) {
                ast_struct_def_free(s);
                fail(&prs, "too many struct definitions");
                goto cleanup_funcs_fail;
            }
            struct_list[nstructs++] = s;
            continue;
        }
        if (peek(&prs)->kind == TOKEN_ENUM) {
            free(pending_link_section); pending_link_section = NULL;  /* K4：enum 不消费 link_section，丢弃 */
            pending_naked = 0;  /* K3：enum 不消费 naked */
            pending_entry = 0;  /* K5：enum 不消费 entry */
            pending_used = 0;  /* K10：enum 不消费 used */
            pending_no_mangle = 0;  /* L9：enum 不消费 no_mangle */
            free(pending_link_name); pending_link_name = NULL;
            ASTEnumDef *e = parse_one_enum(&prs);
            if (!e) goto cleanup_funcs_fail;
            if (nenums >= MAX_ENUMS) {
                ast_enum_def_free(e);
                fail(&prs, "too many enum definitions");
                goto cleanup_funcs_fail;
            }
            enum_list[nenums++] = e;
            continue;
        }
        int is_async = (peek(&prs)->kind == TOKEN_ASYNC) ? 1 : 0;
        if (is_async)
            advance(&prs);
        int is_extern = (peek(&prs)->kind == TOKEN_EXTERN) ? 1 : 0;
        if (is_extern) {
            advance(&prs);
            if (is_async) {
                fail(&prs, "'async' cannot modify extern function");
                goto cleanup_funcs_fail;
            }
            if (peek(&prs)->kind != TOKEN_FUNCTION) {
                fail(&prs, "expected 'function' after 'extern'");
                goto cleanup_funcs_fail;
            }
        }
        if (peek(&prs)->kind != TOKEN_FUNCTION) {
            if (is_async) {
                fail(&prs, "expected 'function' after 'async'");
                goto cleanup_funcs_fail;
            }
            fail(&prs, "expected 'function' after 'extern'");
            goto cleanup_funcs_fail;
        }
        ASTFunc *func = parse_one_function(&prs, is_extern, is_async);
        if (func) {
            func->section = pending_link_section;  /* K4b：#[link_section] 应用到函数（ISR 入段等） */
            pending_link_section = NULL;
            func->is_naked = pending_naked;  /* K3：#[naked] 应用到函数 */
            pending_naked = 0;
            func->is_entry = pending_entry;  /* K5：#[entry] 应用到函数 */
            pending_entry = 0;
            func->is_used = pending_used;  /* K10：#[used] 应用到函数 */
            pending_used = 0;
            func->is_no_mangle = pending_no_mangle;  /* L9：#[no_mangle] 应用到函数 */
            pending_no_mangle = 0;
            func->link_name = pending_link_name;  /* L9：#[link_name] 应用到函数 */
            pending_link_name = NULL;
            func->max_stack = pending_max_stack;  /* L4：#[max_stack] 应用到函数 */
            pending_max_stack = 0;
            func->is_interrupt = pending_interrupt;  /* A1：#[interrupt] 应用到函数 */
            pending_interrupt = 0;
            func->is_global_allocator = pending_global_allocator;
            pending_global_allocator = 0;
            func->is_cold = pending_cold;
            pending_cold = 0;
            func->is_inline_never = pending_inline_never;
            pending_inline_never = 0;
            func->is_inline_always = pending_inline_always;
            pending_inline_always = 0;
            func->is_panic_handler = pending_panic_handler;
            pending_panic_handler = 0;
            pending_thread_local = 0;
            pending_percpu = 0;
            func->export_name = pending_export_name;
            pending_export_name = NULL;
        }
        if (!func) {
cleanup_funcs_fail:
            if (parser_top_level_recovery_enabled()) {
                pending_soa = 0;
                pending_cfg_skip = 0;
                pending_repr_c = 0;
                pending_repr_compatible = 0;
                pending_naked = 0;
                pending_entry = 0;
                pending_used = 0;
                pending_no_mangle = 0;
                free(pending_link_name); pending_link_name = NULL;
                pending_max_stack = 0;
                pending_interrupt = 0;
                pending_global_allocator = 0;
                pending_cold = 0;
                pending_inline_never = 0;
                pending_inline_always = 0;
                pending_panic_handler = 0;
                free(pending_export_name); pending_export_name = NULL;
                pending_thread_local = 0;
                pending_percpu = 0;
                pending_send = 0;
                pending_sync = 0;
                parser_recover_top_level_boundary(&prs);
                continue;
            }
            while (nfuncs--) {
                ASTFunc *f = func_list[nfuncs];
                if (f->name) free((void *)f->name);
                if (f->generic_param_names) {
                    for (int j = 0; j < f->num_generic_params; j++)
                        if (f->generic_param_names[j]) free((void *)f->generic_param_names[j]);
                    free(f->generic_param_names);
                }
                if (f->params) {
                    for (int j = 0; j < f->num_params; j++) {
                        if (f->params[j].name) free((void *)f->params[j].name);
                        if (f->params[j].type) ast_type_free(f->params[j].type);
                    }
                    free(f->params);
                }
                if (f->return_type) ast_type_free(f->return_type);
                if (f->body) ast_block_free(f->body);
                free(f);
            }
            free(func_list);
            while (nimports--) free(import_list[nimports]);
            while (nstructs--) ast_struct_def_free(struct_list[nstructs]);
            while (nenums--) ast_enum_def_free(enum_list[nenums]);
            while (ntraits--) ast_trait_def_free(trait_list[ntraits]);
            while (nimpls--) ast_impl_block_free(impl_list[nimpls]);
            free(mod);
            return -1;
        }
        if (nfuncs >= func_cap) {
            ASTFunc **nf = parser_grow_func_ptrs(func_list, &func_cap, nfuncs + 1);
            if (!nf) {
                if (func->name) free((void *)func->name);
                if (func->generic_param_names) {
                    for (int j = 0; j < func->num_generic_params; j++)
                        if (func->generic_param_names[j]) free((void *)func->generic_param_names[j]);
                    free(func->generic_param_names);
                }
                if (func->params) {
                    for (int j = 0; j < func->num_params; j++) {
                        if (func->params[j].name) free((void *)func->params[j].name);
                        if (func->params[j].type) ast_type_free(func->params[j].type);
                    }
                    free(func->params);
                }
                if (func->return_type) ast_type_free(func->return_type);
                if (func->body) ast_block_free(func->body);
                free(func);
                goto cleanup_funcs_fail;
            }
            func_list = nf;
        }
        func_list[nfuncs] = func;
        if (strcmp(func->name, "main") == 0)
            mod->main_func = func;
        nfuncs++;
    }
    if (peek(&prs)->kind != TOKEN_EOF) {
        while (nfuncs--) {
            ASTFunc *f = func_list[nfuncs];
                if (f->name) free((void *)f->name);
                if (f->generic_param_names) {
                    for (int j = 0; j < f->num_generic_params; j++)
                        if (f->generic_param_names[j]) free((void *)f->generic_param_names[j]);
                    free(f->generic_param_names);
                }
                if (f->params) {
                    for (int j = 0; j < f->num_params; j++) {
                        if (f->params[j].name) free((void *)f->params[j].name);
                        if (f->params[j].type) ast_type_free(f->params[j].type);
                    }
                    free(f->params);
                }
                if (f->return_type) ast_type_free(f->return_type);
                if (f->body) ast_block_free(f->body);
                free(f);
            }
            free(func_list);
            while (nimports--) free(import_list[nimports]);
            while (nstructs--) ast_struct_def_free(struct_list[nstructs]);
            while (nenums--) ast_enum_def_free(enum_list[nenums]);
            free(mod);
            fail(&prs, "expected 'function' or end of file");
        return -1;
    }
    /* 拷贝函数列表到 mod */
    if (nfuncs > 0) {
        mod->funcs = (ASTFunc **)malloc((size_t)nfuncs * sizeof(ASTFunc *));
        if (!mod->funcs) {
            while (nfuncs--) {
                ASTFunc *f = func_list[nfuncs];
                if (f->name) free((void *)f->name);
                if (f->generic_param_names) {
                    for (int j = 0; j < f->num_generic_params; j++)
                        if (f->generic_param_names[j]) free((void *)f->generic_param_names[j]);
                    free(f->generic_param_names);
                }
                if (f->params) {
                    for (int j = 0; j < f->num_params; j++) {
                        if (f->params[j].name) free((void *)f->params[j].name);
                        if (f->params[j].type) ast_type_free(f->params[j].type);
                    }
                    free(f->params);
                }
                if (f->return_type) ast_type_free(f->return_type);
                if (f->body) ast_block_free(f->body);
                free(f);
            }
            while (nimports--) free(import_list[nimports]);
            while (nstructs--) ast_struct_def_free(struct_list[nstructs]);
            while (nenums--) ast_enum_def_free(enum_list[nenums]);
            free(func_list);
            free(mod);
            parser_oom_global();
            return -1;
        }
        for (int i = 0; i < nfuncs; i++)
            mod->funcs[i] = func_list[i];
        mod->num_funcs = nfuncs;
        free(func_list);
    } else {
        free(func_list);
    }
    /* 库模块（被 import 的 .sx）可不含 main；入口模块由 driver 在 -o/-E 时校验须有 main（阶段 7.3）。 */

    /* 拷贝 struct 定义到 mod */
    if (nstructs > 0) {
        mod->struct_defs = (ASTStructDef **)malloc((size_t)nstructs * sizeof(ASTStructDef *));
        if (!mod->struct_defs) {
            while (nimports--) free(import_list[nimports]);
            while (nstructs--) ast_struct_def_free(struct_list[nstructs]);
            while (nenums--) ast_enum_def_free(enum_list[nenums]);
            if (mod->funcs) {
                for (int i = 0; i < mod->num_funcs; i++) {
                    ASTFunc *f = mod->funcs[i];
                    if (f->name) free((void *)f->name);
                    if (f->generic_param_names) {
                        for (int j = 0; j < f->num_generic_params; j++)
                            if (f->generic_param_names[j]) free((void *)f->generic_param_names[j]);
                        free(f->generic_param_names);
                    }
                    if (f->params) {
                        for (int j = 0; j < f->num_params; j++) {
                            if (f->params[j].name) free((void *)f->params[j].name);
                            if (f->params[j].type) ast_type_free(f->params[j].type);
                        }
                        free(f->params);
                    }
                    if (f->return_type) ast_type_free(f->return_type);
                    if (f->body) ast_block_free(f->body);
                    free(f);
                }
                free(mod->funcs);
            }
            free(mod);
            parser_oom_global();
            return -1;
        }
        for (int i = 0; i < nstructs; i++)
            mod->struct_defs[i] = struct_list[i];
        mod->num_structs = nstructs;
    }
    if (nenums > 0) {
        mod->enum_defs = (ASTEnumDef **)malloc((size_t)nenums * sizeof(ASTEnumDef *));
        if (!mod->enum_defs) {
            while (nimports--) free(import_list[nimports]);
            while (nstructs--) ast_struct_def_free(struct_list[nstructs]);
            while (nenums--) ast_enum_def_free(enum_list[nenums]);
            while (ntraits--) ast_trait_def_free(trait_list[ntraits]);
            while (nimpls--) ast_impl_block_free(impl_list[nimpls]);
            if (mod->struct_defs) {
                for (int i = 0; i < mod->num_structs; i++) ast_struct_def_free(mod->struct_defs[i]);
                free(mod->struct_defs);
            }
            if (mod->funcs) {
                for (int i = 0; i < mod->num_funcs; i++) {
                    ASTFunc *f = mod->funcs[i];
                    if (f->name) free((void *)f->name);
                    if (f->generic_param_names) {
                        for (int j = 0; j < f->num_generic_params; j++)
                            if (f->generic_param_names[j]) free((void *)f->generic_param_names[j]);
                        free(f->generic_param_names);
                    }
                    if (f->params) {
                        for (int j = 0; j < f->num_params; j++) {
                            if (f->params[j].name) free((void *)f->params[j].name);
                            if (f->params[j].type) ast_type_free(f->params[j].type);
                        }
                        free(f->params);
                    }
                    if (f->return_type) ast_type_free(f->return_type);
                    if (f->body) ast_block_free(f->body);
                    free(f);
                }
                free(mod->funcs);
            }
            free(mod);
            parser_oom_global();
            return -1;
        }
        for (int i = 0; i < nenums; i++)
            mod->enum_defs[i] = enum_list[i];
        mod->num_enums = nenums;
    }
    /* 拷贝 trait 与 impl 到 mod（阶段 7.2） */
    if (ntraits > 0) {
        mod->trait_defs = (ASTTraitDef **)malloc((size_t)ntraits * sizeof(ASTTraitDef *));
        if (!mod->trait_defs) {
            while (ntraits--) ast_trait_def_free(trait_list[ntraits]);
            while (nimpls--) ast_impl_block_free(impl_list[nimpls]);
            if (mod->struct_defs) { for (int i = 0; i < mod->num_structs; i++) ast_struct_def_free(mod->struct_defs[i]); free(mod->struct_defs); }
            if (mod->enum_defs) { for (int i = 0; i < mod->num_enums; i++) ast_enum_def_free(mod->enum_defs[i]); free(mod->enum_defs); }
            if (mod->funcs) {
                for (int i = 0; i < mod->num_funcs; i++) {
                    ASTFunc *f = mod->funcs[i];
                    if (f->name) free((void *)f->name);
                    if (f->params) { for (int j = 0; j < f->num_params; j++) { free((void *)f->params[j].name); ast_type_free(f->params[j].type); } free(f->params); }
                    if (f->return_type) ast_type_free(f->return_type);
                    if (f->body) ast_block_free(f->body);
                    free(f);
                }
                free(mod->funcs);
            }
            free(mod);
            parser_oom_global();
            return -1;
        }
        for (int i = 0; i < ntraits; i++) mod->trait_defs[i] = trait_list[i];
        mod->num_traits = ntraits;
    }
    if (nimpls > 0) {
        mod->impl_blocks = (ASTImplBlock **)malloc((size_t)nimpls * sizeof(ASTImplBlock *));
        if (!mod->impl_blocks) {
            if (mod->trait_defs) { for (int i = 0; i < mod->num_traits; i++) ast_trait_def_free(mod->trait_defs[i]); free(mod->trait_defs); }
            while (nimpls--) ast_impl_block_free(impl_list[nimpls]);
            if (mod->struct_defs) { for (int i = 0; i < mod->num_structs; i++) ast_struct_def_free(mod->struct_defs[i]); free(mod->struct_defs); }
            if (mod->enum_defs) { for (int i = 0; i < mod->num_enums; i++) ast_enum_def_free(mod->enum_defs[i]); free(mod->enum_defs); }
            if (mod->funcs) {
                for (int i = 0; i < mod->num_funcs; i++) {
                    ASTFunc *f = mod->funcs[i];
                    if (f->name) free((void *)f->name);
                    if (f->params) { for (int j = 0; j < f->num_params; j++) { free((void *)f->params[j].name); ast_type_free(f->params[j].type); } free(f->params); }
                    if (f->return_type) ast_type_free(f->return_type);
                    if (f->body) ast_block_free(f->body);
                    free(f);
                }
                free(mod->funcs);
            }
            free(mod);
            parser_oom_global();
            return -1;
        }
        for (int i = 0; i < nimpls; i++) mod->impl_blocks[i] = impl_list[i];
        mod->num_impl_blocks = nimpls;
    }

    /* 拷贝 import 列表及 kind/binding/select 到 mod */
    if (nimports > 0) {
        mod->import_paths = (char **)malloc((size_t)nimports * sizeof(char *));
        mod->import_kinds = (int *)malloc((size_t)nimports * sizeof(int));
        mod->import_binding_names = (char **)malloc((size_t)nimports * sizeof(char *));
        mod->import_select_names = (char ***)malloc((size_t)nimports * sizeof(char **));
        mod->import_select_aliases = (char ***)malloc((size_t)nimports * sizeof(char **));
        mod->import_select_counts = (int *)malloc((size_t)nimports * sizeof(int));
        if (!mod->import_paths || !mod->import_kinds || !mod->import_binding_names || !mod->import_select_names || !mod->import_select_aliases || !mod->import_select_counts) {
            if (mod->import_paths) free(mod->import_paths);
            if (mod->import_kinds) free(mod->import_kinds);
            if (mod->import_binding_names) free(mod->import_binding_names);
            if (mod->import_select_names) free(mod->import_select_names);
            if (mod->import_select_aliases) free(mod->import_select_aliases);
            if (mod->import_select_counts) free(mod->import_select_counts);
            for (int fi = 0; fi < nimports; fi++) {
                free(import_list[fi]);
                if (kind_list[fi] == AST_IMPORT_KIND_BINDING && binding_list[fi]) free(binding_list[fi]);
                if (kind_list[fi] == AST_IMPORT_KIND_SELECT && select_names_list[fi]) {
                    for (int fj = 0; fj < select_count_list[fi]; fj++) {
                        if (select_names_list[fi][fj]) free(select_names_list[fi][fj]);
                        if (select_aliases_list[fi] && select_aliases_list[fi][fj]) free(select_aliases_list[fi][fj]);
                    }
                    free(select_names_list[fi]);
                    if (select_aliases_list[fi]) free(select_aliases_list[fi]);
                }
            }
            if (mod->struct_defs) {
                for (int i = 0; i < mod->num_structs; i++) ast_struct_def_free(mod->struct_defs[i]);
                free(mod->struct_defs);
            }
            if (mod->enum_defs) {
                for (int i = 0; i < mod->num_enums; i++) ast_enum_def_free(mod->enum_defs[i]);
                free(mod->enum_defs);
            }
            if (mod->funcs) {
                for (int i = 0; i < mod->num_funcs; i++) {
                    ASTFunc *f = mod->funcs[i];
                    if (f->name) free((void *)f->name);
                    if (f->generic_param_names) {
                        for (int j = 0; j < f->num_generic_params; j++)
                            if (f->generic_param_names[j]) free((void *)f->generic_param_names[j]);
                        free(f->generic_param_names);
                    }
                    if (f->params) {
                        for (int j = 0; j < f->num_params; j++) {
                            if (f->params[j].name) free((void *)f->params[j].name);
                            if (f->params[j].type) ast_type_free(f->params[j].type);
                        }
                        free(f->params);
                    }
                    if (f->return_type) ast_type_free(f->return_type);
                    if (f->body) ast_block_free(f->body);
                    free(f);
                }
                free(mod->funcs);
            }
            free(mod);
            parser_oom_global();
            return -1;
        }
        for (int i = 0; i < nimports; i++) {
            mod->import_paths[i] = import_list[i];
            mod->import_kinds[i] = kind_list[i];
            mod->import_binding_names[i] = binding_list[i];
            mod->import_select_names[i] = select_names_list[i];
            mod->import_select_aliases[i] = select_aliases_list[i];
            mod->import_select_counts[i] = select_count_list[i];
        }
        mod->num_imports = nimports;
    }

    *out = mod;
    return 0;
}
