/* seeds/rt_parse_diag.from_x.c — G-02f-307 P2 runtime rest (precise parse diag)
 * Logic source: src/runtime/rt_parse_diag.x
 * Hybrid: SHUX_RT_PARSE_DIAG_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2 full（2026-07-14）：runtime_report_precise_parse_failure_if_known 由 .x 提供；
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体（TOKEN_STRING → P001）。
 *
 * 【Why 根源 2026-07-15】C parser 删除后 multi-error recovery 诊断丢失；
 * shux check 在 check_only + 空 out 时假绿。本文件增加：
 * 1) runtime_report_parse_recovery_diagnostics — 词法级恢复诊断（对齐已删 parser.c fail 文案）
 * 2) 供 check / parse 失败路径调用，写入 lsp_diag 或 stderr
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>

#include "token.h"
#include "runtime_diag_codes.h"

struct shux_slice_uint8_t {
  uint8_t *data;
  size_t length;
};

extern int32_t parser_diag_fail_at_token_kind(struct shux_slice_uint8_t *source);
extern void diag_reportf_with_code(const char *file, int line, int col, const char *kind, const char *code,
                                   const char *detail, const char *fmt, ...);
extern void diag_report_with_code(const char *file, int line, int col, const char *kind, const char *code,
                                  const char *msg, const char *detail);
extern void diag_reportf(const char *file, int line, int col, const char *kind, const char *detail,
                         const char *fmt, ...);
extern int lsp_diag_enabled;
extern void lsp_diag_add_code(int line, int col, int severity, const char *code, const char *msg);
extern int driver_check_only_get(void);
extern void driver_check_diag_emitted_note(void);

#ifndef SHUX_RT_PARSE_DIAG_FROM_X
int runtime_report_precise_parse_failure_if_known(const char *input_path, const char *src, size_t src_len) {
  struct shux_slice_uint8_t diag_src_slice;
  int32_t fail_tok;
  if (!src || src_len == 0)
    return 0;
  diag_src_slice.data = (uint8_t *)src;
  diag_src_slice.length = src_len;
  fail_tok = parser_diag_fail_at_token_kind(&diag_src_slice);
  if (fail_tok == TOKEN_STRING) {
    diag_reportf_with_code(input_path, 0, 0, "parse error", SHUX_DIAG_CODE_PARSE_P001, NULL,
                           "expected integer literal, float literal, identifier, 'true', 'false', 'if', "
                           "'break', 'continue', 'return', 'panic', 'match', or '('");
    return 1;
  }
  return 0;
}
#else
int runtime_report_precise_parse_failure_if_known(const char *input_path, const char *src, size_t src_len);
#endif

/* ---- multi-error recovery diagnostics (always linked) ---- */

typedef enum {
  RT_KW_NONE = 0,
  RT_KW_LET,
  RT_KW_CONST,
  RT_KW_IF,
  RT_KW_ELSE,
  RT_KW_WHILE,
  RT_KW_FOR,
  RT_KW_LOOP,
  RT_KW_RETURN,
  RT_KW_DEFER,
  RT_KW_REGION,
  RT_KW_UNSAFE,
  RT_KW_FUNCTION,
  RT_KW_STRUCT,
  RT_KW_ENUM,
  RT_KW_IMPORT,
  RT_KW_EXTERN,
  RT_KW_MATCH,
  RT_KW_BREAK,
  RT_KW_CONTINUE,
  RT_KW_TRUE,
  RT_KW_FALSE,
  RT_KW_IDENT,
  RT_KW_INT,
  RT_KW_STRING,
  RT_PUNCT
} RtKw;

typedef struct {
  RtKw kw;
  int ch; /* for punct: '(', ')', '{', '}', ';', '=', ':', etc. */
  int line;
  int col;
  size_t pos;
  size_t end;
} RtTok;

typedef struct {
  const char *src;
  size_t len;
  size_t i;
  int line;
  int col;
} RtScan;

static void rt_scan_init(RtScan *s, const char *src, size_t len) {
  s->src = src;
  s->len = len;
  s->i = 0;
  s->line = 1;
  s->col = 1;
}

static int rt_peek(const RtScan *s) {
  if (s->i >= s->len)
    return 0;
  return (unsigned char)s->src[s->i];
}

static int rt_get(RtScan *s) {
  int c;
  if (s->i >= s->len)
    return 0;
  c = (unsigned char)s->src[s->i++];
  if (c == '\n') {
    s->line++;
    s->col = 1;
  } else {
    s->col++;
  }
  return c;
}

static void rt_skip_ws_comment(RtScan *s) {
  for (;;) {
    int c = rt_peek(s);
    if (c == 0)
      return;
    if (c == ' ' || c == '\t' || c == '\r' || c == '\n') {
      rt_get(s);
      continue;
    }
    if (c == '/' && s->i + 1 < s->len && s->src[s->i + 1] == '/') {
      while (rt_peek(s) && rt_peek(s) != '\n')
        rt_get(s);
      continue;
    }
    return;
  }
}

static int rt_kw_eq(const char *a, size_t n, const char *lit) {
  size_t L = strlen(lit);
  return n == L && memcmp(a, lit, L) == 0;
}

static RtKw rt_classify_ident(const char *p, size_t n) {
  if (rt_kw_eq(p, n, "let"))
    return RT_KW_LET;
  if (rt_kw_eq(p, n, "const"))
    return RT_KW_CONST;
  if (rt_kw_eq(p, n, "if"))
    return RT_KW_IF;
  if (rt_kw_eq(p, n, "else"))
    return RT_KW_ELSE;
  if (rt_kw_eq(p, n, "while"))
    return RT_KW_WHILE;
  if (rt_kw_eq(p, n, "for"))
    return RT_KW_FOR;
  if (rt_kw_eq(p, n, "loop"))
    return RT_KW_LOOP;
  if (rt_kw_eq(p, n, "return"))
    return RT_KW_RETURN;
  if (rt_kw_eq(p, n, "defer"))
    return RT_KW_DEFER;
  if (rt_kw_eq(p, n, "region"))
    return RT_KW_REGION;
  if (rt_kw_eq(p, n, "unsafe"))
    return RT_KW_UNSAFE;
  if (rt_kw_eq(p, n, "function"))
    return RT_KW_FUNCTION;
  if (rt_kw_eq(p, n, "struct"))
    return RT_KW_STRUCT;
  if (rt_kw_eq(p, n, "enum"))
    return RT_KW_ENUM;
  if (rt_kw_eq(p, n, "import"))
    return RT_KW_IMPORT;
  if (rt_kw_eq(p, n, "extern"))
    return RT_KW_EXTERN;
  if (rt_kw_eq(p, n, "match"))
    return RT_KW_MATCH;
  if (rt_kw_eq(p, n, "break"))
    return RT_KW_BREAK;
  if (rt_kw_eq(p, n, "continue"))
    return RT_KW_CONTINUE;
  if (rt_kw_eq(p, n, "true") || rt_kw_eq(p, n, "false"))
    return RT_KW_TRUE;
  return RT_KW_IDENT;
}

static int rt_next_tok(RtScan *s, RtTok *out) {
  int c;
  size_t start;
  int line0, col0;
  rt_skip_ws_comment(s);
  if (s->i >= s->len) {
    out->kw = RT_KW_NONE;
    out->ch = 0;
    out->line = s->line;
    out->col = s->col;
    out->pos = s->i;
    out->end = s->i;
    return 0;
  }
  line0 = s->line;
  col0 = s->col;
  start = s->i;
  c = rt_get(s);
  out->line = line0;
  out->col = col0;
  out->pos = start;
  if (isalpha(c) || c == '_') {
    while (s->i < s->len) {
      int n = rt_peek(s);
      if (!isalnum(n) && n != '_')
        break;
      rt_get(s);
    }
    out->end = s->i;
    out->kw = rt_classify_ident(s->src + start, s->i - start);
    out->ch = 0;
    return 1;
  }
  if (isdigit(c)) {
    while (isdigit(rt_peek(s)))
      rt_get(s);
    out->end = s->i;
    out->kw = RT_KW_INT;
    out->ch = 0;
    return 1;
  }
  if (c == '"') {
    while (s->i < s->len) {
      int n = rt_get(s);
      if (n == '\\' && s->i < s->len)
        rt_get(s);
      else if (n == '"')
        break;
      else if (n == 0)
        break;
    }
    out->end = s->i;
    out->kw = RT_KW_STRING;
    out->ch = 0;
    return 1;
  }
  out->kw = RT_PUNCT;
  out->ch = c;
  out->end = s->i;
  /* two-char ops we don't need for recovery */
  return 1;
}

static void rt_rec_fail(const char *path, int line, int col, const char *msg) {
  (void)path;
  if (lsp_diag_enabled) {
    lsp_diag_add_code(line > 0 ? line : 1, col > 0 ? col : 1, 1, "P001", msg);
    return;
  }
  if (driver_check_only_get())
    driver_check_diag_emitted_note();
  diag_report_with_code(NULL, line, col, "parse error", "P001", msg, msg);
}

static int rt_is_stmt_start(const RtTok *t) {
  if (t->kw == RT_KW_NONE)
    return 0;
  if (t->kw == RT_KW_LET || t->kw == RT_KW_CONST || t->kw == RT_KW_IF || t->kw == RT_KW_WHILE
      || t->kw == RT_KW_FOR || t->kw == RT_KW_LOOP || t->kw == RT_KW_RETURN || t->kw == RT_KW_DEFER
      || t->kw == RT_KW_REGION || t->kw == RT_KW_UNSAFE || t->kw == RT_KW_BREAK
      || t->kw == RT_KW_CONTINUE || t->kw == RT_KW_MATCH || t->kw == RT_KW_FUNCTION)
    return 1;
  if (t->kw == RT_PUNCT && (t->ch == '}' || t->ch == '{'))
    return 1;
  return 0;
}

static int rt_is_top_start(const RtTok *t) {
  return t->kw == RT_KW_FUNCTION || t->kw == RT_KW_CONST || t->kw == RT_KW_STRUCT || t->kw == RT_KW_ENUM
         || t->kw == RT_KW_IMPORT || t->kw == RT_KW_EXTERN || t->kw == RT_KW_LET;
}

/** 恢复到下一条顶层声明起点；命中时回退扫描位置以便外层再处理。 */
static void rt_recover_to_top_start(RtScan *sc) {
  RtTok n;
  while (rt_next_tok(sc, &n)) {
    if (rt_is_top_start(&n)) {
      sc->i = n.pos;
      sc->line = n.line;
      sc->col = n.col;
      return;
    }
  }
}

/**
 * 词法级 multi-error recovery 诊断：对齐已删 C parser fail 文案，供 check/run-parser 闸门。
 * 成功写入 ≥1 条诊断时返回错误条数；0 表示未识别可恢复错误。
 */
int runtime_report_parse_recovery_diagnostics(const char *input_path, const char *src, size_t src_len) {
  RtScan sc;
  RtTok t, n;
  int errors = 0;
  int depth = 0; /* brace depth: 0 = top-level */

  if (!src || src_len == 0)
    return 0;
  rt_scan_init(&sc, src, src_len);

  while (rt_next_tok(&sc, &t)) {
    if (t.kw == RT_PUNCT && t.ch == '{') {
      depth++;
      continue;
    }
    if (t.kw == RT_PUNCT && t.ch == '}') {
      if (depth > 0)
        depth--;
      continue;
    }

    /* top-level const: import 绑定形 `const x = import("path")` 或普通 const 缺 ';' */
    if (depth == 0 && t.kw == RT_KW_CONST) {
      RtTok name_tok, eq_tok, rhs_tok;
      if (!rt_next_tok(&sc, &name_tok))
        break;
      /* const x = <not import> → import 预扫描专项诊断（对齐已删 parser.c） */
      if (name_tok.kw == RT_KW_IDENT) {
        if (!rt_next_tok(&sc, &eq_tok))
          break;
        if (eq_tok.kw == RT_PUNCT && eq_tok.ch == '=') {
          if (!rt_next_tok(&sc, &rhs_tok))
            break;
          if (rhs_tok.kw != RT_KW_IMPORT) {
            rt_rec_fail(input_path, rhs_tok.line, rhs_tok.col,
                        "expected const x = import(\"path\")");
            errors++;
            sc.i = rhs_tok.pos;
            sc.line = rhs_tok.line;
            sc.col = rhs_tok.col;
            rt_recover_to_top_start(&sc);
            continue;
          }
          /* const x = import(...)：跳过至 ';' 或下一条顶层 */
          while (rt_next_tok(&sc, &n)) {
            if (n.kw == RT_PUNCT && n.ch == ';')
              break;
            if (rt_is_top_start(&n)) {
              rt_rec_fail(input_path, n.line, n.col,
                          "expected ';' after const x = import(\"path\")");
              errors++;
              sc.i = n.pos;
              sc.line = n.line;
              sc.col = n.col;
              break;
            }
          }
          continue;
        }
        /* typed const: const name : Type = expr — 从 eq_tok 起找 ';' */
        sc.i = eq_tok.pos;
        sc.line = eq_tok.line;
        sc.col = eq_tok.col;
      } else {
        sc.i = name_tok.pos;
        sc.line = name_tok.line;
        sc.col = name_tok.col;
      }
      while (rt_next_tok(&sc, &n)) {
        if (n.kw == RT_PUNCT && n.ch == ';')
          break;
        if (n.kw == RT_PUNCT && n.ch == '{') {
          depth++;
          break;
        }
        if (rt_is_top_start(&n)) {
          rt_rec_fail(input_path, n.line, n.col, "expected ';' after top-level const");
          errors++;
          sc.i = n.pos;
          sc.line = n.line;
          sc.col = n.col;
          break;
        }
      }
      continue;
    }

    /* function without '{' before next top-level item: `function broken(): i32` then `function ok` */
    if (depth == 0 && t.kw == RT_KW_FUNCTION) {
      int saw_rparen = 0;
      while (rt_next_tok(&sc, &n)) {
        if (n.kw == RT_PUNCT && n.ch == '(')
          continue;
        if (n.kw == RT_PUNCT && n.ch == ')') {
          saw_rparen = 1;
          continue;
        }
        if (n.kw == RT_PUNCT && n.ch == '{') {
          depth++;
          break;
        }
        if (saw_rparen && rt_is_top_start(&n)) {
          rt_rec_fail(input_path, n.line, n.col, "expected '{' before function body");
          errors++;
          sc.i = n.pos;
          sc.line = n.line;
          sc.col = n.col;
          break;
        }
        if (n.kw == RT_KW_NONE)
          break;
      }
      continue;
    }

    if (depth == 0)
      continue;

    /* in body: let without semicolon */
    if (t.kw == RT_KW_LET) {
      while (rt_next_tok(&sc, &n)) {
        if (n.kw == RT_PUNCT && n.ch == ';')
          break;
        if (n.kw == RT_PUNCT && n.ch == '}') {
          /* missing ; before } — still an error */
          rt_rec_fail(input_path, n.line, n.col, "expected ';' after let");
          errors++;
          sc.i = n.pos;
          sc.line = n.line;
          sc.col = n.col;
          break;
        }
        if (rt_is_stmt_start(&n) && n.kw != RT_KW_LET) {
          /* next statement without semicolon */
          rt_rec_fail(input_path, n.line, n.col, "expected ';' after let");
          errors++;
          sc.i = n.pos;
          sc.line = n.line;
          sc.col = n.col;
          break;
        }
        if (n.kw == RT_KW_NONE)
          break;
      }
      continue;
    }

    if (t.kw == RT_KW_IF) {
      if (!rt_next_tok(&sc, &n))
        break;
      if (!(n.kw == RT_PUNCT && n.ch == '(')) {
        rt_rec_fail(input_path, n.line, n.col, "expected '(' after 'if'");
        errors++;
        /* recover: don't re-consume if n is useful */
        if (rt_is_stmt_start(&n) || (n.kw == RT_PUNCT && n.ch == '{')) {
          sc.i = n.pos;
          sc.line = n.line;
          sc.col = n.col;
        }
      }
      continue;
    }

    if (t.kw == RT_KW_DEFER) {
      if (!rt_next_tok(&sc, &n))
        break;
      if (!(n.kw == RT_PUNCT && n.ch == '{')) {
        rt_rec_fail(input_path, n.line, n.col, "expected '{' after defer");
        errors++;
        if (rt_is_stmt_start(&n)) {
          sc.i = n.pos;
          sc.line = n.line;
          sc.col = n.col;
        }
      } else {
        depth++;
      }
      continue;
    }

    if (t.kw == RT_KW_UNSAFE) {
      if (!rt_next_tok(&sc, &n))
        break;
      if (!(n.kw == RT_PUNCT && n.ch == '{')) {
        rt_rec_fail(input_path, n.line, n.col, "expected '{' after unsafe");
        errors++;
        if (rt_is_stmt_start(&n) || (n.kw == RT_PUNCT && n.ch == '{')) {
          sc.i = n.pos;
          sc.line = n.line;
          sc.col = n.col;
        }
      } else {
        depth++;
      }
      continue;
    }

    if (t.kw == RT_KW_REGION) {
      if (!rt_next_tok(&sc, &n))
        break;
      if (n.kw != RT_KW_IDENT) {
        rt_rec_fail(input_path, n.line, n.col, "expected region label after region");
        errors++;
        if (rt_is_stmt_start(&n) || (n.kw == RT_PUNCT && n.ch == '{')) {
          sc.i = n.pos;
          sc.line = n.line;
          sc.col = n.col;
        }
      }
      continue;
    }
  }

  /* When not collecting into lsp_diag, multi-error summary for CLI */
  if (errors > 1 && !lsp_diag_enabled) {
    diag_reportf(input_path ? input_path : "?", 0, 0, "error", NULL,
                 "aborting due to %d previous errors", errors);
  }
  return errors;
}

int labi_rt_parse_diag_slice_marker(void) {
  return 1;
}
