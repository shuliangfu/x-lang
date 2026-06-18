/**
 * std/regex/regex_min.inc.c — 纯 C 最小正则子集（STD-051）
 *
 * 【文件职责】无 regex.h 依赖；支持字面量、`.`、`[]`、`?`、`?+`、`*`、`*?`、`*+`、`+`、`+?`、`++`、`\` 转义、
 *   `\p{}`/`\P{}` Unicode 属性（STD-066）；
 *   分组 `()`、交替 `|`、锚点 `^`/`$`（STD-063 工程子集）。
 * 【STD-065】`+` 至少一次；`*?`/`+?` 非贪婪量词。
 * 【STD-099】`*+`/`++`/`?+` 占有型量词（贪婪匹配但不回溯重复段）。
 * 【STD-124】`(?>...)` 原子分组（组内匹配成功则禁止回溯）。
 * 【STD-066】`\p{PROP}` / `\P{PROP}` Unicode 属性类（L/N/W 与 Letter/Number/Whitespace；ASCII + UTF-8 首 rune）。
 * 【匹配语义】子串搜索（与 POSIX regexec 默认行为一致）。
 * 【STD-064】capture：group 0=全匹配，1..n=捕获组；regex_group_offset/length 读上次 match。
 * 【所属模块】由 std/regex/regex.c include。
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
  int32_t off;
  int32_t len;
} regex_min_cap_slot_t;

typedef struct {
  char *pat;
  int32_t pat_len;
  char first_lit;          /**< 首 atom 字面量字节；0 表示不做跳跃（STD-062） */
  int32_t is_literal_only; /**< 全字面量模式：走 memcmp 快路径（STD-062） */
  int32_t ncap;            /**< capture 槽数：1 + 捕获组数（slot0=全匹配） */
  int32_t *group_pat_off;  /**< 每个 `(` 在 pat 中的字节偏移 */
  int32_t cap_valid;       /**< 上次 match 是否写入 capture */
  int32_t atomic_nest;     /**< STD-124：>0 时量词按占有型处理，禁止组内回溯 */
  regex_min_cap_slot_t *caps;
} regex_min_impl_t;

/** STD-066：Unicode 属性种类（与 std.unicode category 简化集对齐）。 */
typedef enum {
  REGEX_PROP_LETTER = 1,
  REGEX_PROP_NUMBER = 2,
  REGEX_PROP_WHITESPACE = 3
} regex_min_prop_kind_t;

/** STD-066：ASCII 分类表（0 未知，1 Letter，2 Number，3 Whitespace）。 */
static const uint8_t regex_min_ascii_cat[128] = {
  [9] = REGEX_PROP_WHITESPACE,
  [10] = REGEX_PROP_WHITESPACE, [11] = REGEX_PROP_WHITESPACE,
  [12] = REGEX_PROP_WHITESPACE, [13] = REGEX_PROP_WHITESPACE,
  [32] = REGEX_PROP_WHITESPACE,
  ['0'] = REGEX_PROP_NUMBER, ['1'] = REGEX_PROP_NUMBER, ['2'] = REGEX_PROP_NUMBER,
  ['3'] = REGEX_PROP_NUMBER, ['4'] = REGEX_PROP_NUMBER, ['5'] = REGEX_PROP_NUMBER,
  ['6'] = REGEX_PROP_NUMBER, ['7'] = REGEX_PROP_NUMBER, ['8'] = REGEX_PROP_NUMBER,
  ['9'] = REGEX_PROP_NUMBER,
  ['A'] = REGEX_PROP_LETTER, ['B'] = REGEX_PROP_LETTER, ['C'] = REGEX_PROP_LETTER,
  ['D'] = REGEX_PROP_LETTER, ['E'] = REGEX_PROP_LETTER, ['F'] = REGEX_PROP_LETTER,
  ['G'] = REGEX_PROP_LETTER, ['H'] = REGEX_PROP_LETTER, ['I'] = REGEX_PROP_LETTER,
  ['J'] = REGEX_PROP_LETTER, ['K'] = REGEX_PROP_LETTER, ['L'] = REGEX_PROP_LETTER,
  ['M'] = REGEX_PROP_LETTER, ['N'] = REGEX_PROP_LETTER, ['O'] = REGEX_PROP_LETTER,
  ['P'] = REGEX_PROP_LETTER, ['Q'] = REGEX_PROP_LETTER, ['R'] = REGEX_PROP_LETTER,
  ['S'] = REGEX_PROP_LETTER, ['T'] = REGEX_PROP_LETTER, ['U'] = REGEX_PROP_LETTER,
  ['V'] = REGEX_PROP_LETTER, ['W'] = REGEX_PROP_LETTER, ['X'] = REGEX_PROP_LETTER,
  ['Y'] = REGEX_PROP_LETTER, ['Z'] = REGEX_PROP_LETTER,
  ['a'] = REGEX_PROP_LETTER, ['b'] = REGEX_PROP_LETTER, ['c'] = REGEX_PROP_LETTER,
  ['d'] = REGEX_PROP_LETTER, ['e'] = REGEX_PROP_LETTER, ['f'] = REGEX_PROP_LETTER,
  ['g'] = REGEX_PROP_LETTER, ['h'] = REGEX_PROP_LETTER, ['i'] = REGEX_PROP_LETTER,
  ['j'] = REGEX_PROP_LETTER, ['k'] = REGEX_PROP_LETTER, ['l'] = REGEX_PROP_LETTER,
  ['m'] = REGEX_PROP_LETTER, ['n'] = REGEX_PROP_LETTER, ['o'] = REGEX_PROP_LETTER,
  ['p'] = REGEX_PROP_LETTER, ['q'] = REGEX_PROP_LETTER, ['r'] = REGEX_PROP_LETTER,
  ['s'] = REGEX_PROP_LETTER, ['t'] = REGEX_PROP_LETTER, ['u'] = REGEX_PROP_LETTER,
  ['v'] = REGEX_PROP_LETTER, ['w'] = REGEX_PROP_LETTER, ['x'] = REGEX_PROP_LETTER,
  ['y'] = REGEX_PROP_LETTER, ['z'] = REGEX_PROP_LETTER
};

/** STD-066：跳过 `\x` 或 `\p{...}` / `\P{...}` 转义序列；非法时返回 p+1（调用方需校验）。 */
static const char *regex_min_after_backslash(const char *p, const char *pat_end) {
  if (p + 1 >= pat_end)
    return pat_end;
  if ((p[1] == 'p' || p[1] == 'P') && p + 2 < pat_end && p[2] == '{') {
    const char *q = p + 3;
    while (q < pat_end && *q != '}')
      q++;
    if (q < pat_end)
      return q + 1;
    return pat_end;
  }
  return p + 2;
}

/** STD-066：校验 `\` 起始的转义序列完整合法。 */
static int regex_min_escape_valid(const char *p, const char *pat_end) {
  if (p >= pat_end || *p != '\\')
    return 0;
  if (p + 1 >= pat_end)
    return 0;
  if (p[1] == 'p' || p[1] == 'P') {
    if (p + 2 >= pat_end || p[2] != '{')
      return 0;
    const char *q = p + 3;
    while (q < pat_end && *q != '}')
      q++;
    if (q >= pat_end || q == p + 3)
      return 0;
    return 1;
  }
  return p + 1 < pat_end;
}

/** STD-066：解析属性名（L/N/W/S/Z 或 Letter/Number/Whitespace/Space）。 */
static int regex_min_parse_prop_name(const char *name, int32_t name_len,
                                     regex_min_prop_kind_t *out) {
  if (!name || name_len <= 0 || !out)
    return 0;
  if (name_len == 1) {
    switch (name[0]) {
    case 'L': *out = REGEX_PROP_LETTER; return 1;
    case 'N': *out = REGEX_PROP_NUMBER; return 1;
    case 'W': case 'S': case 'Z': *out = REGEX_PROP_WHITESPACE; return 1;
    default: return 0;
    }
  }
  {
    static const struct { const char *s; regex_min_prop_kind_t k; } tbl[] = {
      { "Letter", REGEX_PROP_LETTER },
      { "Number", REGEX_PROP_NUMBER },
      { "Whitespace", REGEX_PROP_WHITESPACE },
      { "Space", REGEX_PROP_WHITESPACE }
    };
    int32_t ti;
    for (ti = 0; ti < 4; ti++) {
      const char *s = tbl[ti].s;
      int32_t slen = (int32_t)strlen(s);
      if (name_len == slen && memcmp(name, s, (size_t)slen) == 0) {
        *out = tbl[ti].k;
        return 1;
      }
    }
  }
  return 0;
}

/** STD-066：UTF-8 解码首 rune；失败返回 0。 */
static int regex_min_utf8_decode(const char *s, const char *s_end, uint32_t *out_rune,
                                 int32_t *out_len) {
  unsigned char c0;
  if (!s || !s_end || s >= s_end || !out_rune || !out_len)
    return 0;
  c0 = (unsigned char)s[0];
  if (c0 < 0x80u) {
    *out_rune = (uint32_t)c0;
    *out_len = 1;
    return 1;
  }
  if (c0 < 0xE0u && s + 1 < s_end) {
    unsigned char c1 = (unsigned char)s[1];
    if ((c1 & 0xC0u) != 0x80u)
      return 0;
    *out_rune = ((uint32_t)(c0 & 0x1Fu) << 6) | (uint32_t)(c1 & 0x3Fu);
    *out_len = 2;
    return 1;
  }
  if (c0 < 0xF0u && s + 2 < s_end) {
    unsigned char c1 = (unsigned char)s[1];
    unsigned char c2 = (unsigned char)s[2];
    if ((c1 & 0xC0u) != 0x80u || (c2 & 0xC0u) != 0x80u)
      return 0;
    *out_rune = ((uint32_t)(c0 & 0x0Fu) << 12) | ((uint32_t)(c1 & 0x3Fu) << 6) |
                (uint32_t)(c2 & 0x3Fu);
    *out_len = 3;
    return 1;
  }
  return 0;
}

/** STD-066：rune 分类（v1 与 std.unicode 一致：非 ASCII 暂为 0）。 */
static int32_t regex_min_rune_category(uint32_t rune) {
  if (rune < 128u)
    return (int32_t)regex_min_ascii_cat[rune];
  return 0;
}

/** STD-066：atom 是否为 `\p{...}` 或 `\P{...}`。 */
static int regex_min_atom_is_prop(const char *atom_start, const char *atom_end,
                                  int *out_negate, regex_min_prop_kind_t *out_prop) {
  const char *name_start;
  const char *name_end;
  if (!atom_start || atom_end <= atom_start + 4 || atom_start[0] != '\\')
    return 0;
  if (atom_start[1] != 'p' && atom_start[1] != 'P')
    return 0;
  if (atom_start[2] != '{' || atom_end[-1] != '}')
    return 0;
  *out_negate = (atom_start[1] == 'P') ? 1 : 0;
  name_start = atom_start + 3;
  name_end = atom_end - 1;
  return regex_min_parse_prop_name(name_start, (int32_t)(name_end - name_start), out_prop);
}

/** 模式是否仅含字面量（无 . * ? [ \p 等） */
static int regex_min_is_literal_only(const char *pat, int32_t pat_len) {
  if (!pat || pat_len <= 0) return 0;
  for (int32_t i = 0; i < pat_len; i++) {
    if (pat[i] == '\\') {
      if (!regex_min_escape_valid(pat + i, pat + pat_len))
        return 0;
      if (pat[i + 1] == 'p' || pat[i + 1] == 'P')
        return 0;
      i = (int32_t)(regex_min_after_backslash(pat + i, pat + pat_len) - pat) - 1;
      continue;
    }
    if (pat[i] == '.' || pat[i] == '*' || pat[i] == '?' || pat[i] == '+' ||
        pat[i] == '[' ||
        pat[i] == '(' || pat[i] == ')' || pat[i] == '|' || pat[i] == '^' ||
        pat[i] == '$')
      return 0;
  }
  return 1;
}

/** 全字面量模式：首字节 memchr + memcmp 子串搜索（STD-062） */
static int32_t regex_min_search_literal(const regex_min_impl_t *impl,
                                        const uint8_t *str, int32_t len) {
  if (!impl || !impl->pat || !str || len < 0) return -1;
  int32_t plen = impl->pat_len;
  if (plen > len) return -1;
  char first = impl->pat[0];
  int32_t i = 0;
  while (i <= len - plen) {
    const void *hit = memchr((const char *)str + i, first, (size_t)(len - i));
    if (!hit) return -1;
    i = (int32_t)((const char *)hit - (const char *)str);
    if (i + plen > len) return -1;
    if (memcmp(hit, impl->pat, (size_t)plen) == 0) {
      regex_min_impl_t *mut = (regex_min_impl_t *)impl;
      if (mut->caps && mut->ncap > 0) {
        mut->caps[0].off = i;
        mut->caps[0].len = plen;
        mut->cap_valid = 1;
      }
      return 0;
    }
    i++;
  }
  return -1;
}

/** 校验模式括号平衡、量词位置合法；非法返回 0。 */
static int regex_min_valid(const char *pat, int32_t pat_len) {
  int in_class = 0;
  int depth = 0;
  if (!pat || pat_len <= 0)
    return 0;
  for (int32_t i = 0; i < pat_len; i++) {
    char c = pat[i];
    if (c == '\\') {
      if (!regex_min_escape_valid(pat + i, pat + pat_len))
        return 0;
      i = (int32_t)(regex_min_after_backslash(pat + i, pat + pat_len) - pat) - 1;
      continue;
    }
    if (!in_class) {
      if (c == '[') {
        in_class = 1;
        continue;
      }
      if (c == '(') {
        if (i + 2 < pat_len && pat[i + 1] == '?' && pat[i + 2] != '>') {
          return 0;
        }
        depth++;
        continue;
      }
      if (c == ')') {
        if (depth <= 0)
          return 0;
        depth--;
        continue;
      }
      if (c == '|') {
        if (i == 0 || i + 1 >= pat_len)
          return 0;
        continue;
      }
      if (c == '*' || c == '?' || c == '+') {
        if (i == 0)
          return 0;
        /** STD-124：`(?>...)` 中的 `?` 非量词。 */
        if (c == '?' && i + 1 < pat_len && pat[i - 1] == '(' && pat[i + 1] == '>')
          continue;
        {
          char prev = pat[i - 1];
          if (prev == '*' || prev == '?' || prev == '+' || prev == '|' || prev == '(')
            return 0;
        }
        if ((c == '*' || c == '+') && i + 1 < pat_len && pat[i + 1] == '?')
          i++;
        else if (i + 1 < pat_len && pat[i + 1] == '+')
          i++;
        continue;
      }
      continue;
    }
    if (c == ']') {
      in_class = 0;
      continue;
    }
  }
  return !in_class && depth == 0;
}

/** 统计捕获组数并记录各 `(` 在 pat 内偏移。 */
static int regex_min_build_capture_meta(regex_min_impl_t *r) {
  int in_class = 0;
  int depth = 0;
  int32_t ng = 0;
  int32_t i;
  int32_t gid;
  if (!r || !r->pat || r->pat_len <= 0)
    return 0;
  for (i = 0; i < r->pat_len; i++) {
    char c = r->pat[i];
    if (c == '\\') {
      if (!regex_min_escape_valid(r->pat + i, r->pat + r->pat_len))
        return 0;
      i = (int32_t)(regex_min_after_backslash(r->pat + i, r->pat + r->pat_len) - r->pat) - 1;
      continue;
    }
    if (!in_class) {
      if (c == '[') {
        in_class = 1;
        continue;
      }
      if (c == '(') {
        if (i + 2 < r->pat_len && r->pat[i + 1] == '?' && r->pat[i + 2] == '>') {
          depth++;
          continue;
        }
        ng++;
        depth++;
        continue;
      }
      if (c == ')') {
        if (depth <= 0)
          return 0;
        depth--;
        continue;
      }
      continue;
    }
    if (c == ']')
      in_class = 0;
  }
  r->ncap = ng + 1;
  r->cap_valid = 0;
  r->caps = (regex_min_cap_slot_t *)calloc((size_t)r->ncap, sizeof(regex_min_cap_slot_t));
  if (!r->caps)
    return 0;
  if (ng <= 0) {
    r->group_pat_off = NULL;
    return 1;
  }
  r->group_pat_off = (int32_t *)malloc((size_t)ng * sizeof(int32_t));
  if (!r->group_pat_off)
    return 0;
  in_class = 0;
  depth = 0;
  gid = 0;
  for (i = 0; i < r->pat_len; i++) {
    char c = r->pat[i];
    if (c == '\\') {
      i = (int32_t)(regex_min_after_backslash(r->pat + i, r->pat + r->pat_len) - r->pat) - 1;
      continue;
    }
    if (!in_class) {
      if (c == '[') {
        in_class = 1;
        continue;
      }
      if (c == '(') {
        if (i + 2 < r->pat_len && r->pat[i + 1] == '?' && r->pat[i + 2] == '>') {
          depth++;
          continue;
        }
        r->group_pat_off[gid++] = i;
        depth++;
        continue;
      }
      if (c == ')') {
        depth--;
        continue;
      }
      continue;
    }
    if (c == ']')
      in_class = 0;
  }
  return 1;
}

/** 重置 capture 槽（新一次 match 尝试前）。 */
static void regex_min_cap_reset(regex_min_impl_t *impl) {
  int32_t i;
  if (!impl || !impl->caps || impl->ncap <= 0)
    return;
  for (i = 0; i < impl->ncap; i++) {
    impl->caps[i].off = -1;
    impl->caps[i].len = 0;
  }
  impl->cap_valid = 0;
}

/** 查找 atom 起始 `(` 对应的 capture 组号（1..ncap-1）。 */
static int32_t regex_min_group_index(const regex_min_impl_t *impl, const char *atom_start) {
  int32_t i;
  int32_t ng;
  if (!impl || !impl->group_pat_off || atom_start[0] != '(')
    return -1;
  ng = impl->ncap - 1;
  for (i = 0; i < ng; i++) {
    if (impl->group_pat_off[i] == (int32_t)(atom_start - impl->pat))
      return i + 1;
  }
  return -1;
}

/** 判断单字节是否落在字符类 [cls_start, cls_end) 内（不含外层方括号）。 */
static int regex_min_class_hit(const char *cls_start, const char *cls_end, char ch) {
  int negate = 0;
  const char *p = cls_start;
  if (p < cls_end && *p == '^') { negate = 1; p++; }
  int found = 0;
  while (p < cls_end) {
    char a = *p++;
    if (a == '\\' && p < cls_end) { a = *p++; }
    if (p < cls_end && *p == '-') {
      char b = p[1];
      if (b == '\\' && p + 2 < cls_end) b = p[2];
      if (a <= b && ch >= a && ch <= b) found = 1;
      p += 2;
      continue;
    }
    if (ch == a) found = 1;
  }
  return negate ? !found : found;
}

/** 消费一个 atom；成功推进 *pat 并返回 1，失败返回 0。 */
static int regex_min_consume_atom(const char **pat, const char *pat_end) {
  const char *p = *pat;
  if (p >= pat_end) return 0;
  if (*p == '\\') {
    if (!regex_min_escape_valid(p, pat_end))
      return 0;
    *pat = regex_min_after_backslash(p, pat_end);
    return 1;
  }
  if (*p == '[') {
    const char *q = p + 1;
    while (q < pat_end && *q != ']') {
      if (*q == '\\' && q + 1 < pat_end)
        q += 2;
      else
        q++;
    }
    if (q >= pat_end)
      return 0;
    *pat = q + 1;
    return 1;
  }
  if (*p == '(') {
    int depth = 1;
    const char *q = p + 1;
    while (q < pat_end && depth > 0) {
      if (*q == '\\' && q + 1 < pat_end) {
        q += 2;
        continue;
      }
      if (*q == '(')
        depth++;
      else if (*q == ')')
        depth--;
      q++;
    }
    if (depth != 0)
      return 0;
    *pat = q;
    return 1;
  }
  if (*p == '^' || *p == '$') {
    *pat = p + 1;
    return 1;
  }
  if (*p == '*' || *p == '?' || *p == '+') return 0;
  *pat = p + 1;
  return 1;
}

/** 提取模式首字节字面量（用于搜索跳跃）；首 atom 可零次（* / ?）时不跳跃。 */
static char regex_min_first_literal(const char *pat, int32_t pat_len) {
  const char *p;
  const char *pat_end;
  const char *atom_start;
  if (!pat || pat_len <= 0)
    return 0;
  p = pat;
  pat_end = pat + pat_len;
  atom_start = p;
  if (!regex_min_consume_atom(&p, pat_end))
    return 0;
  /* 首 atom 带 * / ? / +（含 *? / +?）时匹配可从零次或可变起点开始，不做首字节跳跃 */
  if (p < pat_end) {
    char q = *p;
    if (q == '*' || q == '?' || q == '+')
      return 0;
    if ((q == '*' || q == '+') && p + 1 < pat_end && p[1] == '?')
      return 0;
  }
  if (atom_start[0] == '\\') {
    if (atom_start + 2 > pat_end)
      return 0;
    if ((atom_start[1] == 'p' || atom_start[1] == 'P') && atom_start + 2 < pat_end &&
        atom_start[2] == '{')
      return 0;
    return atom_start[1];
  }
  if (atom_start[0] == '.' || atom_start[0] == '[' || atom_start[0] == '*' ||
      atom_start[0] == '?' || atom_start[0] == '(')
    return 0;
  return atom_start[0];
}

/** 找 start 之后第一个顶层 `|`；无则返回 pat_end。 */
static const char *regex_min_next_branch(const char *start, const char *pat_end) {
  int depth = 0;
  int in_class = 0;
  const char *p;
  for (p = start; p < pat_end; p++) {
    if (*p == '\\' && p + 1 < pat_end) {
      p = regex_min_after_backslash(p, pat_end) - 1;
      continue;
    }
    if (in_class) {
      if (*p == ']')
        in_class = 0;
      continue;
    }
    if (*p == '[') {
      in_class = 1;
      continue;
    }
    if (*p == '(') {
      depth++;
      continue;
    }
    if (*p == ')') {
      if (depth > 0)
        depth--;
      continue;
    }
    if (*p == '|' && depth == 0)
      return p;
  }
  return pat_end;
}

/** 尝试用 atom 匹配一字节或零宽锚点（^ 仅 hay 首、$ 仅 hay 尾）。 */
static int regex_min_match_atom_char(const char *atom_start, const char *atom_end,
                                     const char **str, const char *str_end,
                                     const char *haystack_start) {
  if (atom_start >= atom_end)
    return 0;
  if (*str >= str_end && atom_start + 1 == atom_end && *atom_start == '$')
    return 1;
  if (*str >= str_end)
    return 0;
  {
    const char *p = atom_start;
    char ch = **str;
    if (*p == '^') {
      if (*str != haystack_start)
        return 0;
      return 1;
    }
    if (*p == '$') {
      if (*str != str_end)
        return 0;
      return 1;
    }
    if (*p == '\\') {
      int negate;
      regex_min_prop_kind_t prop;
      uint32_t rune;
      int32_t nbytes;
      int32_t cat;
      int hit;
      if (p + 1 >= atom_end)
        return 0;
      if (regex_min_atom_is_prop(atom_start, atom_end, &negate, &prop)) {
        if (!regex_min_utf8_decode(*str, str_end, &rune, &nbytes))
          return 0;
        cat = regex_min_rune_category(rune);
        hit = (cat == (int32_t)prop);
        if (negate)
          hit = !hit;
        if (!hit)
          return 0;
        *str += nbytes;
        return 1;
      }
    } else if (*p == '[') {
      const char *cls = p + 1;
      const char *cls_end = atom_end - 1;
      if (cls_end <= cls || *(atom_end - 1) != ']')
        return 0;
      if (!regex_min_class_hit(cls, cls_end, ch))
        return 0;
      (*str)++;
      return 1;
    } else if (*p == '.') {
      (*str)++;
      return 1;
    } else {
      char lit = *p;
      if (lit != ch)
        return 0;
      (*str)++;
      return 1;
    }
    if (p + 1 >= atom_end)
      return 0;
    if (p[1] != ch)
      return 0;
    (*str)++;
    return 1;
  }
}

static int regex_min_match_here(const regex_min_impl_t *impl, const char **pat, const char *pat_end,
                                const char **str, const char *str_end,
                                const char *haystack_start);

static int regex_min_match_seq(const regex_min_impl_t *impl, const char **pat, const char *pat_end,
                               const char **str, const char *str_end,
                               const char *haystack_start);

/** 匹配一次 atom 或分组（供量词重复）。 */
static int regex_min_match_piece(const regex_min_impl_t *impl, const char *atom_start,
                                 const char *atom_end, const char **str, const char *str_end,
                                 const char *haystack_start) {
  if (atom_start[0] == '(') {
    const char *inner_start;
    const char *inner_end = atom_end - 1;
    const char *p;
    const char *gstart;
    int32_t gi;
    regex_min_impl_t *mut;
    if (inner_end <= atom_start + 1 || atom_end[-1] != ')')
      return 0;
    /** STD-124：原子分组 `(?>...)` — 组内禁止回溯，非捕获。 */
    if (atom_start + 3 <= atom_end && atom_start[1] == '?' && atom_start[2] == '>') {
      inner_start = atom_start + 3;
      if (inner_end <= inner_start)
        return 0;
      p = inner_start;
      mut = (regex_min_impl_t *)impl;
      mut->atomic_nest++;
      if (!regex_min_match_here(impl, &p, inner_end, str, str_end, haystack_start)) {
        mut->atomic_nest--;
        return 0;
      }
      mut->atomic_nest--;
      if (p != inner_end)
        return 0;
      return 1;
    }
    inner_start = atom_start + 1;
    if (inner_end <= inner_start)
      return 0;
    gstart = *str;
    p = inner_start;
    if (!regex_min_match_here(impl, &p, inner_end, str, str_end, haystack_start))
      return 0;
    if (p != inner_end)
      return 0;
    gi = regex_min_group_index(impl, atom_start);
    if (gi > 0 && impl && impl->caps && gi < impl->ncap) {
      impl->caps[gi].off = (int32_t)(gstart - haystack_start);
      impl->caps[gi].len = (int32_t)(*str - gstart);
    }
    return 1;
  }
  return regex_min_match_atom_char(atom_start, atom_end, str, str_end, haystack_start);
}

/** 解析 atom 后的量词；无则 q=0；lazy 对 *?/+?；possessive 对 *+/++/?+。 */
static int regex_min_take_quantifier(const char **pat, const char *pat_end, char *out_q,
                                     int *out_lazy, int *out_possessive) {
  const char *p = *pat;
  *out_lazy = 0;
  *out_possessive = 0;
  if (p >= pat_end) {
    *out_q = 0;
    return 1;
  }
  if (*p == '?') {
    if (p + 1 < pat_end && p[1] == '+') {
      *out_q = '?';
      *out_possessive = 1;
      *pat = p + 2;
      return 1;
    }
    *out_q = '?';
    *pat = p + 1;
    return 1;
  }
  if (*p == '*') {
    *out_q = '*';
    if (p + 1 < pat_end && p[1] == '?') {
      *out_lazy = 1;
      *pat = p + 2;
    } else if (p + 1 < pat_end && p[1] == '+') {
      *out_possessive = 1;
      *pat = p + 2;
    } else {
      *pat = p + 1;
    }
    return 1;
  }
  if (*p == '+') {
    *out_q = '+';
    if (p + 1 < pat_end && p[1] == '?') {
      *out_lazy = 1;
      *pat = p + 2;
    } else if (p + 1 < pat_end && p[1] == '+') {
      *out_possessive = 1;
      *pat = p + 2;
    } else {
      *pat = p + 1;
    }
    return 1;
  }
  *out_q = 0;
  return 1;
}

/** 非贪婪 *?：先零次，再逐步增加重复。 */
static int regex_min_match_star_lazy(const regex_min_impl_t *impl, const char *atom_start,
                                     const char *atom_end, const char **pat, const char *pat_end,
                                     const char **str, const char *str_end,
                                     const char *haystack_start) {
  {
    const char *pat_save = *pat;
    if (regex_min_match_seq(impl, pat, pat_end, str, str_end, haystack_start))
      return 1;
    *pat = pat_save;
  }
  for (;;) {
    const char *pat_save = *pat;
    const char *s2 = *str;
    if (!regex_min_match_piece(impl, atom_start, atom_end, &s2, str_end, haystack_start))
      break;
    *str = s2;
    if (regex_min_match_seq(impl, pat, pat_end, str, str_end, haystack_start))
      return 1;
    *pat = pat_save;
  }
  return 0;
}

/** 贪婪 *：先尽量多重复，再回溯。 */
static int regex_min_match_star_greedy(const regex_min_impl_t *impl, const char *atom_start,
                                       const char *atom_end, const char **pat, const char *pat_end,
                                       const char **str, const char *str_end,
                                       const char *haystack_start) {
  for (;;) {
    const char *pat_save = *pat;
    if (regex_min_match_seq(impl, pat, pat_end, str, str_end, haystack_start))
      return 1;
    *pat = pat_save;
    {
      const char *s2 = *str;
      if (!regex_min_match_piece(impl, atom_start, atom_end, &s2, str_end, haystack_start))
        break;
      *str = s2;
    }
  }
  return 0;
}

/** 非贪婪 +?：至少一次，其余尽量少重复。 */
static int regex_min_match_plus_lazy(const regex_min_impl_t *impl, const char *atom_start,
                                     const char *atom_end, const char **pat, const char *pat_end,
                                     const char **str, const char *str_end,
                                     const char *haystack_start) {
  {
    const char *s2 = *str;
    if (!regex_min_match_piece(impl, atom_start, atom_end, &s2, str_end, haystack_start))
      return 0;
    *str = s2;
  }
  {
    const char *pat_save = *pat;
    if (regex_min_match_seq(impl, pat, pat_end, str, str_end, haystack_start))
      return 1;
    *pat = pat_save;
  }
  for (;;) {
    const char *pat_save = *pat;
    const char *s2 = *str;
    if (!regex_min_match_piece(impl, atom_start, atom_end, &s2, str_end, haystack_start))
      break;
    *str = s2;
    if (regex_min_match_seq(impl, pat, pat_end, str, str_end, haystack_start))
      return 1;
    *pat = pat_save;
  }
  return 0;
}

/** 贪婪 +：至少一次，其余尽量多重复。 */
static int regex_min_match_plus_greedy(const regex_min_impl_t *impl, const char *atom_start,
                                       const char *atom_end, const char **pat, const char *pat_end,
                                       const char **str, const char *str_end,
                                       const char *haystack_start) {
  {
    const char *s2 = *str;
    if (!regex_min_match_piece(impl, atom_start, atom_end, &s2, str_end, haystack_start))
      return 0;
    *str = s2;
  }
  for (;;) {
    const char *pat_save = *pat;
    if (regex_min_match_seq(impl, pat, pat_end, str, str_end, haystack_start))
      return 1;
    *pat = pat_save;
    {
      const char *s2 = *str;
      if (!regex_min_match_piece(impl, atom_start, atom_end, &s2, str_end, haystack_start))
        break;
      *str = s2;
    }
  }
  return 0;
}

/** 占有型 *+：尽量多重复，不回溯重复次数。 */
static int regex_min_match_star_possessive(const regex_min_impl_t *impl, const char *atom_start,
                                           const char *atom_end, const char **pat,
                                           const char *pat_end, const char **str,
                                           const char *str_end, const char *haystack_start) {
  for (;;) {
    const char *s2 = *str;
    if (!regex_min_match_piece(impl, atom_start, atom_end, &s2, str_end, haystack_start))
      break;
    *str = s2;
  }
  return regex_min_match_seq(impl, pat, pat_end, str, str_end, haystack_start);
}

/** 占有型 ++：至少一次，再多尽量吞，不回溯。 */
static int regex_min_match_plus_possessive(const regex_min_impl_t *impl, const char *atom_start,
                                           const char *atom_end, const char **pat,
                                           const char *pat_end, const char **str,
                                           const char *str_end, const char *haystack_start) {
  {
    const char *s2 = *str;
    if (!regex_min_match_piece(impl, atom_start, atom_end, &s2, str_end, haystack_start))
      return 0;
    *str = s2;
  }
  for (;;) {
    const char *s2 = *str;
    if (!regex_min_match_piece(impl, atom_start, atom_end, &s2, str_end, haystack_start))
      break;
    *str = s2;
  }
  return regex_min_match_seq(impl, pat, pat_end, str, str_end, haystack_start);
}

/** 顺序匹配 pat[branch_start..branch_end)。 */
static int regex_min_match_seq(const regex_min_impl_t *impl, const char **pat, const char *pat_end,
                               const char **str, const char *str_end,
                               const char *haystack_start) {
  while (*pat < pat_end) {
    const char *pat_checkpoint = *pat;
    const char *str_checkpoint = *str;
    const char *atom_start = *pat;
    char q;
    int lazy;
    int possessive;
    if (!regex_min_consume_atom(pat, pat_end))
      return 0;
    {
      const char *atom_end = *pat;
      if (!regex_min_take_quantifier(pat, pat_end, &q, &lazy, &possessive))
        return 0;
      /** STD-124：原子组内量词一律按占有型处理。 */
      if (impl->atomic_nest > 0 && q != 0) {
        possessive = 1;
        lazy = 0;
      }
      if (q == '?') {
        const char *s2 = *str;
        if (!possessive) {
          if (regex_min_match_piece(impl, atom_start, atom_end, &s2, str_end, haystack_start))
            *str = s2;
          if (!regex_min_match_seq(impl, pat, pat_end, str, str_end, haystack_start)) {
            *pat = pat_checkpoint;
            *str = str_checkpoint;
            return 0;
          }
          continue;
        }
        if (regex_min_match_piece(impl, atom_start, atom_end, &s2, str_end, haystack_start))
          *str = s2;
        if (!regex_min_match_seq(impl, pat, pat_end, str, str_end, haystack_start)) {
          *pat = pat_checkpoint;
          *str = str_checkpoint;
          return 0;
        }
        continue;
      }
      if (q == '*') {
        if (possessive) {
          if (!regex_min_match_star_possessive(impl, atom_start, atom_end, pat, pat_end, str,
                                               str_end, haystack_start)) {
            *pat = pat_checkpoint;
            *str = str_checkpoint;
            return 0;
          }
        } else if (lazy) {
          if (!regex_min_match_star_lazy(impl, atom_start, atom_end, pat, pat_end, str, str_end,
                                         haystack_start)) {
            *pat = pat_checkpoint;
            *str = str_checkpoint;
            return 0;
          }
        } else {
          if (!regex_min_match_star_greedy(impl, atom_start, atom_end, pat, pat_end, str, str_end,
                                           haystack_start)) {
            *pat = pat_checkpoint;
            *str = str_checkpoint;
            return 0;
          }
        }
        continue;
      }
      if (q == '+') {
        if (possessive) {
          if (!regex_min_match_plus_possessive(impl, atom_start, atom_end, pat, pat_end, str,
                                              str_end, haystack_start)) {
            *pat = pat_checkpoint;
            *str = str_checkpoint;
            return 0;
          }
        } else if (lazy) {
          if (!regex_min_match_plus_lazy(impl, atom_start, atom_end, pat, pat_end, str, str_end,
                                         haystack_start)) {
            *pat = pat_checkpoint;
            *str = str_checkpoint;
            return 0;
          }
        } else {
          if (!regex_min_match_plus_greedy(impl, atom_start, atom_end, pat, pat_end, str, str_end,
                                           haystack_start)) {
            *pat = pat_checkpoint;
            *str = str_checkpoint;
            return 0;
          }
        }
        continue;
      }
      if (!regex_min_match_piece(impl, atom_start, atom_end, str, str_end, haystack_start)) {
        *pat = pat_checkpoint;
        *str = str_checkpoint;
        return 0;
      }
    }
  }
  return 1;
}

/** 递归匹配：支持顶层 `|` 分支。 */
static int regex_min_match_here(const regex_min_impl_t *impl, const char **pat, const char *pat_end,
                                const char **str, const char *str_end,
                                const char *haystack_start) {
  const char *branch = *pat;
  while (branch < pat_end) {
    const char *branch_end = regex_min_next_branch(branch, pat_end);
    const char *s2 = *str;
    const char *p2 = branch;
    if (regex_min_match_seq(impl, &p2, branch_end, &s2, str_end, haystack_start) && p2 == branch_end) {
      *str = s2;
      *pat = branch_end;
      return 1;
    }
    if (branch_end >= pat_end)
      break;
    branch = branch_end + 1;
  }
  return 0;
}

/** 在 str[0..len) 中搜索子串匹配（STD-062：字面量快路径 + 首字节跳跃）。 */
static int32_t regex_min_search(regex_min_impl_t *impl, const uint8_t *str, int32_t len) {
  if (!impl || !impl->pat || !str || len < 0) return -1;
  if (impl->is_literal_only) {
    return regex_min_search_literal(impl, str, len);
  }
  {
    const char *pat = impl->pat;
    const char *pat_end = pat + impl->pat_len;
    const char *hay = (const char *)str;
    if (impl->first_lit) {
      for (int32_t i = 0; i < len; i++) {
        const char *s = hay + i;
        const char *s_end = hay + len;
        const char *p = pat;
        regex_min_cap_reset(impl);
        if (regex_min_match_here(impl, &p, pat_end, &s, s_end, hay) && p == pat_end) {
          if (impl->caps && impl->ncap > 0) {
            impl->caps[0].off = i;
            impl->caps[0].len = (int32_t)(s - (hay + i));
            impl->cap_valid = 1;
          }
          return 0;
        }
      }
      return -1;
    }
    for (int32_t i = 0; i <= len; i++) {
      const char *s = hay + i;
      const char *s_end = hay + len;
      const char *p = pat;
      regex_min_cap_reset(impl);
      if (regex_min_match_here(impl, &p, pat_end, &s, s_end, hay) && p == pat_end) {
        if (impl->caps && impl->ncap > 0) {
          impl->caps[0].off = i;
          impl->caps[0].len = (int32_t)(s - (hay + i));
          impl->cap_valid = 1;
        }
        return 0;
      }
    }
  }
  return -1;
}

void *regex_compile_c(const uint8_t *pat, int32_t pat_len) {
  if (!pat || pat_len <= 0) return NULL;
  if (!regex_min_valid((const char *)pat, pat_len)) return NULL;
  regex_min_impl_t *r = (regex_min_impl_t *)malloc(sizeof(regex_min_impl_t));
  if (!r) return NULL;
  r->pat = (char *)malloc((size_t)pat_len + 1);
  if (!r->pat) { free(r); return NULL; }
  memcpy(r->pat, pat, (size_t)pat_len);
  r->pat[pat_len] = '\0';
  r->pat_len = pat_len;
  r->is_literal_only = regex_min_is_literal_only((const char *)pat, pat_len);
  r->first_lit = regex_min_first_literal((const char *)pat, pat_len);
  r->atomic_nest = 0;
  if (!regex_min_build_capture_meta(r)) {
    free(r->pat);
    free(r);
    return NULL;
  }
  return (void *)r;
}

int32_t regex_match_c(void *re, const uint8_t *str, int32_t len) {
  if (!re || !str) return -1;
  return regex_min_search((regex_min_impl_t *)re, str, len);
}

/** 返回 capture 槽数（含 group 0 全匹配）。 */
int32_t regex_group_count_c(void *re) {
  regex_min_impl_t *r;
  if (!re) return -1;
  r = (regex_min_impl_t *)re;
  return r->ncap;
}

/** 读 group 起始字节偏移；无有效 capture 返回 -1。 */
int32_t regex_group_offset_c(void *re, int32_t group) {
  regex_min_impl_t *r;
  if (!re || group < 0) return -1;
  r = (regex_min_impl_t *)re;
  if (!r->cap_valid || !r->caps || group >= r->ncap)
    return -1;
  return r->caps[group].off;
}

/** 读 group 匹配长度；无有效 capture 返回 -1。 */
int32_t regex_group_length_c(void *re, int32_t group) {
  regex_min_impl_t *r;
  if (!re || group < 0) return -1;
  r = (regex_min_impl_t *)re;
  if (!r->cap_valid || !r->caps || group >= r->ncap)
    return -1;
  if (r->caps[group].off < 0)
    return -1;
  return r->caps[group].len;
}

void regex_free_c(void *re) {
  if (!re) return;
  regex_min_impl_t *r = (regex_min_impl_t *)re;
  free(r->pat);
  free(r->group_pat_off);
  free(r->caps);
  free(r);
}

/** C 烟测：literal / dot / class / star / question；失败返回非 0。 */
int32_t regex_min_smoke_c(void) {
  uint8_t pat1[] = { 'h', 'e', 'l', 'l', 'o' };
  uint8_t hay1[] = { 's', 'a', 'y', ' ', 'h', 'e', 'l', 'l', 'o' };
  void *re = regex_compile_c(pat1, 5);
  if (!re) return 1;
  if (regex_match_c(re, hay1, 9) != 0) { regex_free_c(re); return 2; }
  regex_free_c(re);

  uint8_t pat2[] = { 'h', '.', 'l' };
  uint8_t hay2[] = { 'h', 'i', 'l', 'o' };
  re = regex_compile_c(pat2, 3);
  if (!re) return 3;
  if (regex_match_c(re, hay2, 4) != 0) { regex_free_c(re); return 4; }
  regex_free_c(re);

  uint8_t pat3[] = { '[', '0', '-', '9', ']' };
  uint8_t hay3[] = { 'x', '5', 'y' };
  re = regex_compile_c(pat3, 5);
  if (!re) return 5;
  if (regex_match_c(re, hay3, 3) != 0) { regex_free_c(re); return 6; }
  regex_free_c(re);

  uint8_t pat4[] = { 'a', '*', 'b' };
  uint8_t hay4[] = { 'a', 'a', 'a', 'b' };
  re = regex_compile_c(pat4, 3);
  if (!re) return 7;
  if (regex_match_c(re, hay4, 4) != 0) { regex_free_c(re); return 8; }
  {
    uint8_t hay4b[] = { 'b' };
    if (regex_match_c(re, hay4b, 1) != 0) { regex_free_c(re); return 13; }
  }
  regex_free_c(re);

  {
    uint8_t pat6[] = { '(', 'a', 'b', ')', 'c' };
    uint8_t hay6[] = { 'x', 'a', 'b', 'c', 'y' };
    re = regex_compile_c(pat6, 5);
    if (!re) return 14;
    if (regex_match_c(re, hay6, 5) != 0) { regex_free_c(re); return 15; }
    regex_free_c(re);
  }

  {
    uint8_t pat7[] = { 'c', 'a', 't', '|', 'd', 'o', 'g' };
    uint8_t hay7[] = { 'a', ' ', 'd', 'o', 'g', '!' };
    re = regex_compile_c(pat7, 7);
    if (!re) return 16;
    if (regex_match_c(re, hay7, 6) != 0) { regex_free_c(re); return 17; }
    regex_free_c(re);
  }

  {
    uint8_t pat8[] = { '^', 'h', 'i', '$' };
    uint8_t hay8a[] = { 'h', 'i' };
    uint8_t hay8b[] = { 'x', 'h', 'i' };
    re = regex_compile_c(pat8, 4);
    if (!re) return 18;
    if (regex_match_c(re, hay8a, 2) != 0) { regex_free_c(re); return 19; }
    if (regex_match_c(re, hay8b, 3) == 0) { regex_free_c(re); return 20; }
    regex_free_c(re);
  }

  uint8_t pat5[] = { 'c', 'o', 'l', 'o', 'u', '?', 'r' };
  uint8_t hay5a[] = { 'c', 'o', 'l', 'o', 'r' };
  uint8_t hay5b[] = { 'c', 'o', 'l', 'o', 'u', 'r' };
  re = regex_compile_c(pat5, 7);
  if (!re) return 9;
  if (regex_match_c(re, hay5a, 5) != 0) { regex_free_c(re); return 10; }
  if (regex_match_c(re, hay5b, 6) != 0) { regex_free_c(re); return 11; }
  regex_free_c(re);

  if (regex_compile_c((uint8_t *)"*", 1) != NULL) return 12;

  {
    uint8_t pat9[] = { '(', 'a', 'b', ')', 'c' };
    uint8_t hay9[] = { 'x', 'a', 'b', 'c', 'y' };
    re = regex_compile_c(pat9, 5);
    if (!re) return 21;
    if (regex_group_count_c(re) != 2) { regex_free_c(re); return 22; }
    if (regex_match_c(re, hay9, 5) != 0) { regex_free_c(re); return 23; }
    if (regex_group_offset_c(re, 0) != 1) { regex_free_c(re); return 24; }
    if (regex_group_length_c(re, 0) != 3) { regex_free_c(re); return 25; }
    if (regex_group_offset_c(re, 1) != 1) { regex_free_c(re); return 26; }
    if (regex_group_length_c(re, 1) != 2) { regex_free_c(re); return 27; }
    regex_free_c(re);
  }

  {
    uint8_t pat10[] = { 'a', '+', 'b' };
    uint8_t hay10a[] = { 'a', 'a', 'b' };
    uint8_t hay10b[] = { 'b' };
    re = regex_compile_c(pat10, 3);
    if (!re) return 28;
    if (regex_match_c(re, hay10a, 3) != 0) { regex_free_c(re); return 29; }
    if (regex_match_c(re, hay10b, 1) == 0) { regex_free_c(re); return 30; }
    regex_free_c(re);
  }

  {
    uint8_t pat11[] = { '<', '.', '*', '?', '>' };
    uint8_t hay11[] = { '<', 'a', '>', '<', 'b', '>' };
    re = regex_compile_c(pat11, 5);
    if (!re) return 31;
    if (regex_match_c(re, hay11, 6) != 0) { regex_free_c(re); return 32; }
    if (regex_group_count_c(re) >= 1) {
      if (regex_group_offset_c(re, 0) != 0) { regex_free_c(re); return 33; }
      if (regex_group_length_c(re, 0) != 3) { regex_free_c(re); return 34; }
    }
    regex_free_c(re);
  }

  if (regex_compile_c((uint8_t *)"+", 1) != NULL) return 35;

  {
    /* STD-066：\p{L}+ 匹配字母；\P{N} 非数字 */
    uint8_t pat12[] = { '\\', 'p', '{', 'L', '}', '+' };
    uint8_t hay12[] = { '1', 'a', 'b', 'c', '9' };
    re = regex_compile_c(pat12, 6);
    if (!re) return 36;
    if (regex_match_c(re, hay12, 5) != 0) { regex_free_c(re); return 37; }
    regex_free_c(re);

    uint8_t pat13[] = { '\\', 'P', '{', 'N', '}' };
    uint8_t hay13[] = { 'x', '5', 'y' };
    re = regex_compile_c(pat13, 5);
    if (!re) return 38;
    if (regex_match_c(re, hay13, 3) != 0) { regex_free_c(re); return 39; }
    regex_free_c(re);

    uint8_t pat14[] = { '\\', 'p', '{', 'W', '}' };
    uint8_t hay14[] = { 'a', ' ', 'b' };
    re = regex_compile_c(pat14, 5);
    if (!re) return 40;
    if (regex_match_c(re, hay14, 3) != 0) { regex_free_c(re); return 41; }
    regex_free_c(re);
  }

  if (regex_compile_c((uint8_t *)"\\p{}", 4) != NULL) return 42;

  {
    /* STD-099：占有型 .++! 不回溯，故 "hello!" 整体失败；贪婪 .+! 可匹配 */
    uint8_t pat15[] = { '.', '+', '+', '!' };
    uint8_t hay15[] = { 'h', 'e', 'l', 'l', 'o', '!' };
    re = regex_compile_c(pat15, 4);
    if (!re) return 43;
    if (regex_match_c(re, hay15, 6) == 0) { regex_free_c(re); return 44; }
    regex_free_c(re);

    uint8_t pat16[] = { '.', '+', '!' };
    re = regex_compile_c(pat16, 3);
    if (!re) return 45;
    if (regex_match_c(re, hay15, 6) != 0) { regex_free_c(re); return 46; }
    regex_free_c(re);

    uint8_t pat17[] = { 'a', '+', '+', 'b' };
    uint8_t hay17[] = { 'a', 'a', 'a', 'b' };
    re = regex_compile_c(pat17, 4);
    if (!re) return 47;
    if (regex_match_c(re, hay17, 4) != 0) { regex_free_c(re); return 48; }
    if (regex_match_c(re, (uint8_t *)"b", 1) == 0) { regex_free_c(re); return 49; }
    regex_free_c(re);

    uint8_t pat18[] = { 'a', '*', '+', 'b' };
    uint8_t hay18[] = { 'x', 'a', 'a', 'b' };
    re = regex_compile_c(pat18, 4);
    if (!re) return 50;
    if (regex_match_c(re, hay18, 4) != 0) { regex_free_c(re); return 51; }
    regex_free_c(re);
  }

  if (regex_compile_c((uint8_t *)"*+", 2) != NULL) return 52;

  {
    /* STD-124：(a+)a 可匹配 aaa；(?>(a+))a 原子组不回溯，失败 */
    uint8_t pat19[] = { '(', 'a', '+', ')', 'a' };
    uint8_t pat20[] = { '(', '?', '>', '(', 'a', '+', ')', ')', 'a' };
    uint8_t hay19[] = { 'a', 'a', 'a' };
    re = regex_compile_c(pat19, 5);
    if (!re) return 53;
    if (regex_match_c(re, hay19, 3) != 0) { regex_free_c(re); return 54; }
    regex_free_c(re);
    re = regex_compile_c(pat20, 9);
    if (!re) return 55;
    if (regex_match_c(re, hay19, 3) == 0) { regex_free_c(re); return 56; }
    if (regex_group_count_c(re) != 2) { regex_free_c(re); return 57; }
    regex_free_c(re);
  }

  if (regex_compile_c((uint8_t *)"(?", 2) != NULL) return 58;

  return 0;
}
