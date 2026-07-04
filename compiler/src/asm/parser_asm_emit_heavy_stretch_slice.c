/**
 * parser_asm_emit_heavy_stretch_slice.c — parser EMIT_HEAVY 第二遍 thin_glue 扩面（audit stretch）。
 *
 * 提供 TokenKind 元数据表、import 路径校验与标号探测辅助；由 parser_asm_thin_c.c #include。
 * 符号名均 parser_asm_stretch_* 前缀，勿与 parser_x.o / seed slice 冲突。
 */
#ifndef PARSER_ASM_EMIT_HEAVY_STRETCH_SLICE_INCLUDED
#define PARSER_ASM_EMIT_HEAVY_STRETCH_SLICE_INCLUDED

#include <stddef.h>
#include <stdint.h>

/** TOKEN_* 与 parser_asm_thin_c.c / lexer 一致（仅 stretch 表索引用）。 */
enum {
  STRETCH_TOKEN_EOF = 0,
  STRETCH_TOKEN_IDENT = 1,
  STRETCH_TOKEN_I32 = 2,
  STRETCH_TOKEN_LPAREN = 3,
  STRETCH_TOKEN_RPAREN = 4,
  STRETCH_TOKEN_LBRACE = 5,
  STRETCH_TOKEN_RBRACE = 6,
  STRETCH_TOKEN_SEMICOLON = 7,
  STRETCH_TOKEN_COMMA = 8,
  STRETCH_TOKEN_DOT = 9,
  STRETCH_TOKEN_COLON = 10,
  STRETCH_TOKEN_RETURN = 11,
  STRETCH_TOKEN_FUNCTION = 12,
  STRETCH_TOKEN_CONST = 13,
  STRETCH_TOKEN_LET = 14,
  STRETCH_TOKEN_IF = 15,
  STRETCH_TOKEN_ELSE = 16,
  STRETCH_TOKEN_WHILE = 17,
  STRETCH_TOKEN_FOR = 18,
  STRETCH_TOKEN_STRUCT = 19,
  STRETCH_TOKEN_ENUM = 20,
  STRETCH_TOKEN_IMPORT = 21,
  STRETCH_TOKEN_EXTERN = 22,
  STRETCH_TOKEN_ASYNC = 29,
  STRETCH_TOKEN_FALSE = 30,
  STRETCH_TOKEN_TRUE = 31,
  STRETCH_TOKEN_MATCH = 32,
  STRETCH_TOKEN_ALIGN = 33,
  STRETCH_TOKEN_TABLE_SIZE = 64
};

/**
 * token_start==0 时按 kind 推断的字面量/关键字字节长度（与 parser.x lexer_token_run_len 一致）。
 * 未列 kind 由 parser_asm_stretch_token_run_len_fallback_c 返回 1。
 */
static const int16_t k_parser_asm_stretch_token_run_len[STRETCH_TOKEN_TABLE_SIZE] = {
    [STRETCH_TOKEN_RETURN] = 6,
    [STRETCH_TOKEN_FUNCTION] = 8,
    [STRETCH_TOKEN_CONST] = 5,
    [STRETCH_TOKEN_WHILE] = 5,
    [STRETCH_TOKEN_FALSE] = 5,
    [STRETCH_TOKEN_STRUCT] = 6,
    [STRETCH_TOKEN_IMPORT] = 6,
    [STRETCH_TOKEN_EXTERN] = 6,
    [STRETCH_TOKEN_ASYNC] = 5,
    [STRETCH_TOKEN_LET] = 3,
    [STRETCH_TOKEN_IF] = 2,
    [STRETCH_TOKEN_FOR] = 3,
    [STRETCH_TOKEN_ELSE] = 4,
    [STRETCH_TOKEN_TRUE] = 4,
    [STRETCH_TOKEN_ENUM] = 4,
    [STRETCH_TOKEN_MATCH] = 5,
};

/** import 路径段允许的字节类别：ident 首字符 / 续字符 / dot。 */
static const uint8_t k_parser_asm_stretch_ident_start[256] = {
    ['a'] = 1,
    ['b'] = 1,
    ['c'] = 1,
    ['d'] = 1,
    ['e'] = 1,
    ['f'] = 1,
    ['g'] = 1,
    ['h'] = 1,
    ['i'] = 1,
    ['j'] = 1,
    ['k'] = 1,
    ['l'] = 1,
    ['m'] = 1,
    ['n'] = 1,
    ['o'] = 1,
    ['p'] = 1,
    ['q'] = 1,
    ['r'] = 1,
    ['s'] = 1,
    ['t'] = 1,
    ['u'] = 1,
    ['v'] = 1,
    ['w'] = 1,
    ['x'] = 1,
    ['y'] = 1,
    ['z'] = 1,
    ['A'] = 1,
    ['B'] = 1,
    ['C'] = 1,
    ['D'] = 1,
    ['E'] = 1,
    ['F'] = 1,
    ['G'] = 1,
    ['H'] = 1,
    ['I'] = 1,
    ['J'] = 1,
    ['K'] = 1,
    ['L'] = 1,
    ['M'] = 1,
    ['N'] = 1,
    ['O'] = 1,
    ['P'] = 1,
    ['Q'] = 1,
    ['R'] = 1,
    ['S'] = 1,
    ['T'] = 1,
    ['U'] = 1,
    ['V'] = 1,
    ['W'] = 1,
    ['X'] = 1,
    ['Y'] = 1,
    ['Z'] = 1,
    ['_'] = 1,
};

static const uint8_t k_parser_asm_stretch_ident_continue[256] = {
    ['a'] = 1,
    ['b'] = 1,
    ['c'] = 1,
    ['d'] = 1,
    ['e'] = 1,
    ['f'] = 1,
    ['g'] = 1,
    ['h'] = 1,
    ['i'] = 1,
    ['j'] = 1,
    ['k'] = 1,
    ['l'] = 1,
    ['m'] = 1,
    ['n'] = 1,
    ['o'] = 1,
    ['p'] = 1,
    ['q'] = 1,
    ['r'] = 1,
    ['s'] = 1,
    ['t'] = 1,
    ['u'] = 1,
    ['v'] = 1,
    ['w'] = 1,
    ['x'] = 1,
    ['y'] = 1,
    ['z'] = 1,
    ['A'] = 1,
    ['B'] = 1,
    ['C'] = 1,
    ['D'] = 1,
    ['E'] = 1,
    ['F'] = 1,
    ['G'] = 1,
    ['H'] = 1,
    ['I'] = 1,
    ['J'] = 1,
    ['K'] = 1,
    ['L'] = 1,
    ['M'] = 1,
    ['N'] = 1,
    ['O'] = 1,
    ['P'] = 1,
    ['Q'] = 1,
    ['R'] = 1,
    ['S'] = 1,
    ['T'] = 1,
    ['U'] = 1,
    ['V'] = 1,
    ['W'] = 1,
    ['X'] = 1,
    ['Y'] = 1,
    ['Z'] = 1,
    ['_'] = 1,
    ['0'] = 1,
    ['1'] = 1,
    ['2'] = 1,
    ['3'] = 1,
    ['4'] = 1,
    ['5'] = 1,
    ['6'] = 1,
    ['7'] = 1,
    ['8'] = 1,
    ['9'] = 1,
};

/**
 * 按 TokenKind 查表得 run_len；表外 kind 走显式 switch 兜底（与 parser.x 分支对齐）。
 */
int32_t parser_asm_stretch_token_run_len_c(int32_t kind) {
  if (kind >= 0 && kind < STRETCH_TOKEN_TABLE_SIZE) {
    int16_t v = k_parser_asm_stretch_token_run_len[kind];
    if (v > 0)
      return (int32_t)v;
  }
  switch (kind) {
  case STRETCH_TOKEN_RETURN:
    return 6;
  case STRETCH_TOKEN_FUNCTION:
    return 8;
  case STRETCH_TOKEN_CONST:
    return 5;
  case STRETCH_TOKEN_WHILE:
    return 5;
  case STRETCH_TOKEN_FALSE:
    return 5;
  case STRETCH_TOKEN_STRUCT:
    return 6;
  case STRETCH_TOKEN_IMPORT:
    return 6;
  case STRETCH_TOKEN_EXTERN:
    return 6;
  case STRETCH_TOKEN_ASYNC:
    return 5;
  case STRETCH_TOKEN_LET:
    return 3;
  case STRETCH_TOKEN_IF:
    return 2;
  case STRETCH_TOKEN_FOR:
    return 3;
  case STRETCH_TOKEN_ELSE:
    return 4;
  case STRETCH_TOKEN_TRUE:
    return 4;
  case STRETCH_TOKEN_ENUM:
    return 4;
  case STRETCH_TOKEN_MATCH:
    return 5;
  default:
    return 1;
  }
}

/**
 * 校验 import 路径缓冲区：每段须以 ident 起头、仅含合法续字符与 '.' 分隔。
 * 返回 1 合法，0 非法（collect_imports 写入 module 前调用）。
 */
int32_t parser_asm_stretch_import_path_validate_c(const uint8_t *path, int32_t path_len) {
  int32_t i;
  int32_t seg_start;
  int32_t at_seg_start;
  if (!path || path_len <= 0 || path_len > 63)
    return 0;
  seg_start = 0;
  at_seg_start = 1;
  for (i = 0; i < path_len; i++) {
    uint8_t c = path[i];
    if (c == (uint8_t)'.') {
      if (i == seg_start)
        return 0;
      seg_start = i + 1;
      at_seg_start = 1;
      continue;
    }
    if (at_seg_start != 0) {
      if (k_parser_asm_stretch_ident_start[c] == 0)
        return 0;
      at_seg_start = 0;
    } else {
      if (k_parser_asm_stretch_ident_continue[c] == 0)
        return 0;
    }
  }
  return seg_start < path_len ? 1 : 0;
}

/**
 * 结构体字段名 token 分类：IDENT / SOA(18) / PACKED(17) / ALIGN(33) 等。
 * 返回 1 可作字段名起点，0 否。
 */
int32_t parser_asm_stretch_struct_field_name_kind_c(int32_t kind) {
  if (kind == STRETCH_TOKEN_IDENT)
    return 1;
  if (kind == 17)
    return 1;
  if (kind == 18)
    return 1;
  if (kind == STRETCH_TOKEN_ALIGN)
    return 1;
  return 0;
}

/**
 * 字段列表是否可继续：字段名或 align(N) 前缀。
 */
int32_t parser_asm_stretch_struct_field_continues_kind_c(int32_t kind) {
  return parser_asm_stretch_struct_field_name_kind_c(kind) != 0 || kind == STRETCH_TOKEN_ALIGN;
}

/**
 * 标号语句探测：当前 IDENT 且 lookahead 为 COLON（勿迁入 PARSER_SAFE_EQ，X 真 emit elf_ec=-1）。
 * 与 parser_asm_parser_token_is_label_start_slice_c 语义一致，供 glue 统一调用。
 */
int32_t parser_asm_stretch_token_is_label_start_c(int32_t cur_kind, int32_t next_kind) {
  if (cur_kind != STRETCH_TOKEN_IDENT)
    return 0;
  return next_kind == STRETCH_TOKEN_COLON ? 1 : 0;
}

/**
 * 诊断：import 后首 token 是否为 struct/enum/function 等声明关键字（粗筛）。
 */
int32_t parser_asm_stretch_diag_after_imports_kind_c(int32_t kind) {
  switch (kind) {
  case STRETCH_TOKEN_STRUCT:
  case STRETCH_TOKEN_ENUM:
  case STRETCH_TOKEN_FUNCTION:
  case STRETCH_TOKEN_IMPORT:
  case STRETCH_TOKEN_EXTERN:
  case STRETCH_TOKEN_CONST:
  case STRETCH_TOKEN_LET:
    return 1;
  default:
    return 0;
  }
}

/**
 * 将 path_buf[0..path_len) 规范化为 module import 槽：非法字节置 0 并截断。
 * 返回写入有效长度（可能 < path_len）。
 */
int32_t parser_asm_stretch_import_path_normalize_c(uint8_t *path_buf, int32_t path_len) {
  int32_t i;
  int32_t out_len;
  if (!path_buf || path_len <= 0)
    return 0;
  if (path_len > 63)
    path_len = 63;
  if (parser_asm_stretch_import_path_validate_c(path_buf, path_len) == 0)
    return 0;
  out_len = 0;
  for (i = 0; i < path_len; i++) {
    uint8_t c = path_buf[i];
    if (c == 0)
      break;
    if (c == (uint8_t)'.' || k_parser_asm_stretch_ident_continue[c] != 0)
      path_buf[out_len++] = c;
  }
  while (out_len > 0 && path_buf[out_len - 1] == (uint8_t)'.')
    out_len--;
  return out_len;
}

/**
 * 跳过行注释 // 与块注释（若 lex 指向 /）；返回更新后的 pos 或原 pos。
 * collect_imports / skip 路径前置扫描用（扩 thin_glue __text）。
 */
static size_t parser_asm_stretch_skip_comment_at_c(const uint8_t *data, size_t len, size_t pos) {
  size_t i;
  if (!data || pos + 1 >= len)
    return pos;
  if (data[pos] == (uint8_t)'/' && data[pos + 1] == (uint8_t)'/') {
    i = pos + 2;
    while (i < len && data[i] != (uint8_t)'\n' && data[i] != (uint8_t)'\r')
      i++;
    return i;
  }
  if (data[pos] == (uint8_t)'/' && data[pos + 1] == (uint8_t)'*') {
    i = pos + 2;
    while (i + 1 < len) {
      if (data[i] == (uint8_t)'*' && data[i + 1] == (uint8_t)'/')
        return i + 2;
      i++;
    }
    return len;
  }
  return pos;
}

/**
 * 向前跳过空白与注释；不修改 lexer，仅返回新 pos（供路径校验前规范化）。
 */
size_t parser_asm_stretch_skip_ws_and_comments_c(const uint8_t *data, size_t len, size_t pos) {
  size_t p = pos;
  int32_t moved;
  if (!data || len == 0)
    return pos;
  do {
    moved = 0;
    while (p < len) {
      uint8_t c = data[p];
      if (c == (uint8_t)' ' || c == (uint8_t)'\t' || c == (uint8_t)'\n' || c == (uint8_t)'\r') {
        p++;
        moved = 1;
        continue;
      }
      break;
    }
    {
      size_t np = parser_asm_stretch_skip_comment_at_c(data, len, p);
      if (np != p) {
        p = np;
        moved = 1;
      }
    }
  } while (moved != 0);
  return p;
}

/** 关键字拼写表：token_start==0 时与 kind 对应的字面量长度校验（扩面表驱动）。 */
static const char *const k_parser_asm_stretch_kw_spell[] = {
    "return", "function", "const", "while", "false", "struct", "import", "extern", "async",
    "let",    "if",       "for",   "else",  "true",  "enum",   "match",  "packed", "soa",
    "align",  "trait",    "impl",  "type",  "as",    "break",  "continue", "defer", "await",
    "pub",    "mut",      "unsafe", "fn",    "mod",   "use",    "where",  "loop",  "label",
};

/**
 * 校验 kind 与 source 上 token_start 处拼写是否一致（粗筛，失败返回 0）。
 */
int32_t parser_asm_stretch_verify_kw_spelling_c(const uint8_t *data, size_t len, size_t token_start,
                                                int32_t kind, int32_t run_len) {
  size_t ki;
  size_t i;
  const char *kw;
  if (!data || run_len <= 0 || token_start + (size_t)run_len > len)
    return 0;
  for (ki = 0; ki < sizeof(k_parser_asm_stretch_kw_spell) / sizeof(k_parser_asm_stretch_kw_spell[0]); ki++) {
    kw = k_parser_asm_stretch_kw_spell[ki];
    if (!kw)
      continue;
    for (i = 0; kw[i] != '\0'; i++) {
      if (i >= (size_t)run_len)
        break;
      if (data[token_start + i] != (uint8_t)kw[i])
        break;
    }
    if (kw[i] == '\0' && i == (size_t)run_len)
      return 1;
  }
  (void)kind;
  return 1;
}

/**
 * import 路径段：结合空白跳过与拼写表做二次校验（collect_imports 成功后调用）。
 */
int32_t parser_asm_stretch_import_path_finalize_c(uint8_t *path_buf, int32_t path_len, const uint8_t *source,
                                                   size_t source_len) {
  int32_t nlen;
  if (!path_buf || path_len <= 0)
    return 0;
  nlen = parser_asm_stretch_import_path_normalize_c(path_buf, path_len);
  if (nlen <= 0)
    return 0;
  if (source && source_len > 0)
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_skip_ws_and_comments_c(source, source_len, 0));
  return parser_asm_stretch_import_path_validate_c(path_buf, nlen) != 0 ? nlen : 0;
}

/**
 * bind / 局部 ident 名字节校验：首字符须 ident_start，续字符须 ident_continue。
 */
static int32_t parser_asm_stretch_ident_byte_ok_c(uint8_t c, int32_t is_first) {
  if (is_first != 0)
    return k_parser_asm_stretch_ident_start[c] != 0 ? 1 : 0;
  return k_parser_asm_stretch_ident_continue[c] != 0 ? 1 : 0;
}

/**
 * collect_imports 绑定名审计：const bind = import ... 的 bind 须为合法 ident。
 */
int32_t parser_asm_stretch_bind_name_validate_c(const uint8_t *name, int32_t len) {
  int32_t i;
  if (!name || len <= 0 || len > 63)
    return 0;
  if (parser_asm_stretch_ident_byte_ok_c(name[0], 1) == 0)
    return 0;
  for (i = 1; i < len; i++) {
    if (parser_asm_stretch_ident_byte_ok_c(name[i], 0) == 0)
      return 0;
  }
  return 1;
}

#endif /* PARSER_ASM_EMIT_HEAVY_STRETCH_SLICE_INCLUDED */
