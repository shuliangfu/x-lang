/**
 * std/unicode/unicode.c — Unicode 分类、大小写、NFC、字素簇（对标 Zig std.unicode、Rust char）
 *
 * 【文件职责】category、to_lower/to_upper、is_whitespace、is_ascii；
 * nfc_buf（v1 拉丁预组合子集）；grapheme_next；case_fold_*。
 * 【所属模块/组件】标准库 std.unicode；与 std/unicode/mod.sx 同属一模块。
 */

#include <stdint.h>
#include <ctype.h>
#include <string.h>

/* ASCII 分类表：0 未知，1 Letter，2 Number，3 Whitespace；一次查表避免分支 */
#define U_CAT_LETTER    1
#define U_CAT_NUMBER    2
#define U_CAT_WHITESPACE 3
static const uint8_t ascii_category_table[128] = {
  [0 ... 8] = 0,
  [9] = U_CAT_WHITESPACE,   /* \t */
  [10 ... 13] = U_CAT_WHITESPACE, /* \n \v \f \r */
  [14 ... 31] = 0,
  [32] = U_CAT_WHITESPACE,  /* space */
  [33 ... 47] = 0,
  ['0'] = U_CAT_NUMBER,
  ['1'] = U_CAT_NUMBER,
  ['2'] = U_CAT_NUMBER,
  ['3'] = U_CAT_NUMBER,
  ['4'] = U_CAT_NUMBER,
  ['5'] = U_CAT_NUMBER,
  ['6'] = U_CAT_NUMBER,
  ['7'] = U_CAT_NUMBER,
  ['8'] = U_CAT_NUMBER,
  ['9'] = U_CAT_NUMBER,
  [58 ... 64] = 0,
  ['A'] = U_CAT_LETTER,
  ['B'] = U_CAT_LETTER,
  ['C'] = U_CAT_LETTER,
  ['D'] = U_CAT_LETTER,
  ['E'] = U_CAT_LETTER,
  ['F'] = U_CAT_LETTER,
  ['G'] = U_CAT_LETTER,
  ['H'] = U_CAT_LETTER,
  ['I'] = U_CAT_LETTER,
  ['J'] = U_CAT_LETTER,
  ['K'] = U_CAT_LETTER,
  ['L'] = U_CAT_LETTER,
  ['M'] = U_CAT_LETTER,
  ['N'] = U_CAT_LETTER,
  ['O'] = U_CAT_LETTER,
  ['P'] = U_CAT_LETTER,
  ['Q'] = U_CAT_LETTER,
  ['R'] = U_CAT_LETTER,
  ['S'] = U_CAT_LETTER,
  ['T'] = U_CAT_LETTER,
  ['U'] = U_CAT_LETTER,
  ['V'] = U_CAT_LETTER,
  ['W'] = U_CAT_LETTER,
  ['X'] = U_CAT_LETTER,
  ['Y'] = U_CAT_LETTER,
  ['Z'] = U_CAT_LETTER,
  [91 ... 96] = 0,
  ['a'] = U_CAT_LETTER,
  ['b'] = U_CAT_LETTER,
  ['c'] = U_CAT_LETTER,
  ['d'] = U_CAT_LETTER,
  ['e'] = U_CAT_LETTER,
  ['f'] = U_CAT_LETTER,
  ['g'] = U_CAT_LETTER,
  ['h'] = U_CAT_LETTER,
  ['i'] = U_CAT_LETTER,
  ['j'] = U_CAT_LETTER,
  ['k'] = U_CAT_LETTER,
  ['l'] = U_CAT_LETTER,
  ['m'] = U_CAT_LETTER,
  ['n'] = U_CAT_LETTER,
  ['o'] = U_CAT_LETTER,
  ['p'] = U_CAT_LETTER,
  ['q'] = U_CAT_LETTER,
  ['r'] = U_CAT_LETTER,
  ['s'] = U_CAT_LETTER,
  ['t'] = U_CAT_LETTER,
  ['u'] = U_CAT_LETTER,
  ['v'] = U_CAT_LETTER,
  ['w'] = U_CAT_LETTER,
  ['x'] = U_CAT_LETTER,
  ['y'] = U_CAT_LETTER,
  ['z'] = U_CAT_LETTER,
  [123 ... 127] = 0,
};

/** 读取 UTF-8 下一码点；返回消耗字节数，rune 写入 *out（失败返回 0）。 */
static int32_t utf8_decode_at(const uint8_t *s, int32_t len, int32_t off, uint32_t *out) {
  if (!s || off < 0 || off >= len || !out) return 0;
  uint8_t c0 = s[off];
  if (c0 <= 0x7F) {
    *out = c0;
    return 1;
  }
  if ((c0 & 0xE0) == 0xC0 && off + 1 < len) {
    *out = ((uint32_t)(c0 & 0x1F) << 6) | (uint32_t)(s[off + 1] & 0x3F);
    return 2;
  }
  if ((c0 & 0xF0) == 0xE0 && off + 2 < len) {
    *out = ((uint32_t)(c0 & 0x0F) << 12) | ((uint32_t)(s[off + 1] & 0x3F) << 6) |
           (uint32_t)(s[off + 2] & 0x3F);
    return 3;
  }
  if ((c0 & 0xF8) == 0xF0 && off + 3 < len) {
    *out = ((uint32_t)(c0 & 0x07) << 18) | ((uint32_t)(s[off + 1] & 0x3F) << 12) |
           ((uint32_t)(s[off + 2] & 0x3F) << 6) | (uint32_t)(s[off + 3] & 0x3F);
    return 4;
  }
  *out = c0;
  return 1;
}

/** 将 rune 编码为 UTF-8；返回写入字节数。 */
static int32_t utf8_encode(uint32_t rune, uint8_t *out, int32_t cap) {
  if (!out || cap <= 0) return 0;
  if (rune <= 0x7F) {
    out[0] = (uint8_t)rune;
    return 1;
  }
  if (rune <= 0x7FF && cap >= 2) {
    out[0] = (uint8_t)(0xC0 | (rune >> 6));
    out[1] = (uint8_t)(0x80 | (rune & 0x3F));
    return 2;
  }
  if (rune <= 0xFFFF && cap >= 3) {
    out[0] = (uint8_t)(0xE0 | (rune >> 12));
    out[1] = (uint8_t)(0x80 | ((rune >> 6) & 0x3F));
    out[2] = (uint8_t)(0x80 | (rune & 0x3F));
    return 3;
  }
  if (cap >= 4) {
    out[0] = (uint8_t)(0xF0 | (rune >> 18));
    out[1] = (uint8_t)(0x80 | ((rune >> 12) & 0x3F));
    out[2] = (uint8_t)(0x80 | ((rune >> 6) & 0x3F));
    out[3] = (uint8_t)(0x80 | (rune & 0x3F));
    return 4;
  }
  return 0;
}

/** 拉丁字母 + U+0301 锐音符 → 预组合码点（v1 子集）；无映射返回 0。 */
static uint32_t nfc_compose_acute(uint32_t base) {
  switch (base) {
    case 'a': return 0x00E1;
    case 'A': return 0x00C1;
    case 'e': return 0x00E9;
    case 'E': return 0x00C9;
    case 'i': return 0x00ED;
    case 'I': return 0x00CD;
    case 'o': return 0x00F3;
    case 'O': return 0x00D3;
    case 'u': return 0x00FA;
    case 'U': return 0x00DA;
    case 'y': return 0x00FD;
    case 'Y': return 0x00DD;
    default: return 0;
  }
}

/** 是否为组合附标 U+0300..U+036F。 */
static int32_t is_combining_mark(uint32_t rune) {
  return rune >= 0x0300u && rune <= 0x036Fu;
}

/** Unicode 分类（简化）：0 未知，1 Letter，2 Number，3 Whitespace。ASCII 查表，非 ASCII 返回 0。 */
int32_t unicode_category_c(uint32_t rune) {
  if (rune < 128u) return (int32_t)ascii_category_table[rune];
  return 0;
}

/** 是否为空白（\t \n \v \f \r 空格）。 */
int32_t unicode_is_whitespace_c(uint32_t rune) {
  if (rune < 128u) return ascii_category_table[rune] == U_CAT_WHITESPACE ? 1 : 0;
  return 0;
}

/** 是否为 ASCII（rune <= 127）。 */
int32_t unicode_is_ascii_c(uint32_t rune) {
  return rune <= 127u ? 1 : 0;
}

/** rune 转小写；非 ASCII 暂返回原 rune。 */
uint32_t unicode_to_lower_c(uint32_t rune) {
  if (rune <= 127u) return (uint32_t)(unsigned char)tolower((int)(rune & 0xff));
  return rune;
}

/** rune 转大写；非 ASCII 暂返回原 rune。 */
uint32_t unicode_to_upper_c(uint32_t rune) {
  if (rune <= 127u) return (uint32_t)(unsigned char)toupper((int)(rune & 0xff));
  return rune;
}

/** 是否为 Unicode 增补平面码点（U+10000 及以上）。 */
int32_t unicode_is_supplementary_c(uint32_t rune) {
  return rune > 0xFFFFu ? 1 : 0;
}

/** 缓冲 NFC（v1 拉丁预组合子集）；返回写入 out 的字节数，失败 -1。 */
int32_t unicode_nfc_buf_c(const uint8_t *in, int32_t in_len, uint8_t *out, int32_t out_cap) {
  if (!in || !out || in_len < 0 || out_cap <= 0) return -1;
  int32_t in_off = 0;
  int32_t out_off = 0;
  while (in_off < in_len) {
    uint32_t rune = 0;
    int32_t n = utf8_decode_at(in, in_len, in_off, &rune);
    if (n <= 0) return -1;
    int32_t next_off = in_off + n;
    uint32_t rune2 = 0;
    int32_t n2 = 0;
    if (next_off < in_len) {
      n2 = utf8_decode_at(in, in_len, next_off, &rune2);
    }
    /* 拉丁基字符 + U+0301 锐音符 → 预组合 */
    if (n2 > 0 && rune2 == 0x0301u && rune <= 127u && isalpha((int)rune)) {
      uint32_t composed = nfc_compose_acute(rune);
      if (composed) {
        int32_t w = utf8_encode(composed, out + out_off, out_cap - out_off);
        if (w <= 0) return -1;
        out_off += w;
        in_off = next_off + n2;
        continue;
      }
    }
    if (out_off + n > out_cap) return -1;
    memcpy(out + out_off, in + in_off, (size_t)n);
    out_off += n;
    in_off += n;
  }
  return out_off;
}

/** 下一字素簇字节数（基字符 + U+0300..036F 附标）。 */
int32_t unicode_grapheme_next_c(const uint8_t *s, int32_t len, int32_t off) {
  if (!s || off < 0 || off >= len) return 0;
  uint32_t rune = 0;
  int32_t n = utf8_decode_at(s, len, off, &rune);
  if (n <= 0) return 0;
  int32_t total = n;
  int32_t pos = off + n;
  while (pos < len) {
    uint32_t mark = 0;
    int32_t mn = utf8_decode_at(s, len, pos, &mark);
    if (mn <= 0 || !is_combining_mark(mark)) break;
    total += mn;
    pos += mn;
  }
  return total;
}

/** 单码点 case fold（v1 委托 to_lower）。 */
uint32_t unicode_case_fold_rune_c(uint32_t rune) {
  return unicode_to_lower_c(rune);
}

/** 缓冲 case fold 输出 UTF-8；返回写入字节数，失败 -1。 */
int32_t unicode_case_fold_buf_c(const uint8_t *in, int32_t in_len, uint8_t *out, int32_t out_cap) {
  if (!in || !out || in_len < 0 || out_cap <= 0) return -1;
  int32_t in_off = 0;
  int32_t out_off = 0;
  while (in_off < in_len) {
    uint32_t rune = 0;
    int32_t n = utf8_decode_at(in, in_len, in_off, &rune);
    if (n <= 0) return -1;
    uint32_t folded = unicode_case_fold_rune_c(rune);
    int32_t w = utf8_encode(folded, out + out_off, out_cap - out_off);
    if (w <= 0) return -1;
    out_off += w;
    in_off += n;
  }
  return out_off;
}

/** STD-114 C 烟测：grapheme + case fold 金样。 */
int32_t unicode_grapheme_case_smoke_c(void) {
  uint8_t decomposed[] = {101, 0xCC, 0x81};
  if (unicode_grapheme_next_c(decomposed, 3, 0) != 3) return 1;
  uint8_t hello[] = {72, 101, 108, 108, 111};
  if (unicode_grapheme_next_c(hello, 5, 0) != 1) return 2;
  uint8_t fold[8];
  int32_t n = unicode_case_fold_buf_c(hello, 5, fold, 8);
  if (n != 5 || fold[0] != 104) return 3;
  return 0;
}
