/**
 * std/encoding/encoding.c — UTF-8/ASCII 编解码与校验（对标 Zig/Rust，性能压榨）
 *
 * 【文件职责】
 * 单遍 UTF-8 校验、码点计数、rune 编解码；ASCII 分类与大小写。无堆分配，表驱动，热路径内联友好。
 *
 * 【性能】restrict、LIKELY/UNLIKELY、首字节表驱动、连续字节位掩码校验，目标超越 Zig std.unicode.utf8。
 */

#include <stddef.h>
#include <stdint.h>

#if defined(__GNUC__) || defined(__clang__)
#define ENC_HOT    __attribute__((hot))
#define ENC_PURE   __attribute__((pure))
#define ENC_LIKELY(x)   __builtin_expect(!!(x), 1)
#define ENC_UNLIKELY(x) __builtin_expect(!!(x), 0)
#else
#define ENC_HOT
#define ENC_PURE
#define ENC_LIKELY(x)   (x)
#define ENC_UNLIKELY(x) (x)
#endif

/* UTF-8 首字节：0=单字节，1..4=多字节序列长度；255=非法 */
static const uint8_t utf8_first_byte_len[256] = {
  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
  255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255, /* 0x80-0x8F 续字节 */
  255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255, /* 0x90-0x9F */
  2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, /* 0xC0-0xCF */
  2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, /* 0xD0-0xDF */
  3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3, /* 0xE0-0xEF 3 字节 */
  4,4,4,4,255,255,255,255,           /* 0xF0-0xF7 4 字节；0xF8+ 非法 */
  255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
  255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
  255,255,255,255,255,255,255,255, /* 0xF8-0xFF */
};

/* 续字节掩码：0x80=10xxxxxx，非续字节为非法 */
#define UTF8_CONT_MASK 0xC0
#define UTF8_CONT_VAL  0x80

ENC_HOT
int32_t encoding_utf8_valid_c(const uint8_t * restrict p, int32_t len) {
  if (ENC_UNLIKELY(p == 0 || len < 0)) return 0;
  const uint8_t * const end = p + (size_t)(len < 0 ? 0 : len);
  while (p < end) {
    uint8_t b = *p++;
    uint8_t n = utf8_first_byte_len[b];
    if (ENC_UNLIKELY(n == 255)) return 0; /* 非法首字节 */
    if (ENC_UNLIKELY(n > 1)) {
      if (ENC_UNLIKELY(p + (n - 1) > end)) return 0;
      for (uint8_t i = 1; i < n; i++) {
        if ((p[i - 1] & UTF8_CONT_MASK) != UTF8_CONT_VAL) return 0;
      }
      /* 过编码检查：2 字节 C0/C1 非法；3 字节 E0 后 80-9F 需排除等 */
      if (n == 2 && b < 0xC2) return 0;
      if (n == 3 && b == 0xE0 && p[0] < 0xA0) return 0;
      if (n == 3 && b == 0xED && p[0] > 0x9F) return 0;
      if (n == 4 && b == 0xF0 && p[0] < 0x90) return 0;
      if (n == 4 && b == 0xF4 && p[0] > 0x8F) return 0;
      p += (size_t)(n - 1);
    }
  }
  return 1;
}

ENC_HOT
int32_t encoding_utf8_len_chars_c(const uint8_t * restrict p, int32_t len) {
  if (ENC_UNLIKELY(p == 0 || len <= 0)) return 0;
  int32_t count = 0;
  const uint8_t * const end = p + (size_t)len;
  while (p < end) {
    uint8_t n = utf8_first_byte_len[*p];
    if (n == 255) return -1;
    if ((size_t)n > (size_t)(end - p)) return -1;
    for (uint8_t i = 1; i < n; i++)
      if ((p[i] & UTF8_CONT_MASK) != UTF8_CONT_VAL) return -1;
    p += (size_t)n;
    count++;
  }
  return count;
}

/* 返回写入的字节数（1..4），0 表示 r 非法或 out 不足 */
ENC_HOT
int32_t encoding_utf8_encode_rune_c(uint32_t r, uint8_t * restrict out) {
  if (out == 0) return 0;
  if (r <= 0x7F) { out[0] = (uint8_t)r; return 1; }
  if (r <= 0x7FF) {
    if (r < 0x80) return 0;
    out[0] = (uint8_t)(0xC0 | (r >> 6));
    out[1] = (uint8_t)(0x80 | (r & 0x3F));
    return 2;
  }
  if (r <= 0xFFFF) {
    if (r < 0x800 || (r >= 0xD800 && r <= 0xDFFF)) return 0; /* 代理区非法 */
    out[0] = (uint8_t)(0xE0 | (r >> 12));
    out[1] = (uint8_t)(0x80 | ((r >> 6) & 0x3F));
    out[2] = (uint8_t)(0x80 | (r & 0x3F));
    return 3;
  }
  if (r <= 0x10FFFF) {
    out[0] = (uint8_t)(0xF0 | (r >> 18));
    out[1] = (uint8_t)(0x80 | ((r >> 12) & 0x3F));
    out[2] = (uint8_t)(0x80 | ((r >> 6) & 0x3F));
    out[3] = (uint8_t)(0x80 | (r & 0x3F));
    return 4;
  }
  return 0;
}

/* 返回消费的字节数（1..4），0 表示非法；*out_r 写入解码的码点 */
ENC_HOT
int32_t encoding_utf8_decode_rune_c(const uint8_t * restrict p, int32_t len, uint32_t * restrict out_r) {
  if (ENC_UNLIKELY(p == 0 || len <= 0 || out_r == 0)) return 0;
  uint8_t b = *p;
  uint8_t n = utf8_first_byte_len[b];
  if (n == 255 || (size_t)n > (size_t)len) return 0;
  uint32_t r;
  if (n == 1) { *out_r = (uint32_t)b; return 1; }
  r = (uint32_t)(b & (0xFF >> (n + 1)));
  for (uint8_t i = 1; i < n; i++) {
    if ((p[i] & UTF8_CONT_MASK) != UTF8_CONT_VAL) return 0;
    r = (r << 6) | (uint32_t)(p[i] & 0x3F);
  }
  if (n == 2 && r < 0x80) return 0;
  if (n == 3 && (r < 0x800 || (r >= 0xD800 && r <= 0xDFFF))) return 0;
  if (n == 4 && (r < 0x10000 || r > 0x10FFFF)) return 0;
  *out_r = r;
  return (int32_t)n;
}

/* ASCII 分类与转换（无分支或查表） */
ENC_PURE int32_t encoding_ascii_is_alpha_c(uint8_t c) { return (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') ? 1 : 0; }
ENC_PURE int32_t encoding_ascii_is_digit_c(uint8_t c) { return (c >= '0' && c <= '9') ? 1 : 0; }
ENC_PURE int32_t encoding_ascii_is_alnum_c(uint8_t c) { return encoding_ascii_is_alpha_c(c) || encoding_ascii_is_digit_c(c) ? 1 : 0; }
ENC_PURE int32_t encoding_ascii_is_lower_c(uint8_t c) { return (c >= 'a' && c <= 'z') ? 1 : 0; }
ENC_PURE int32_t encoding_ascii_is_upper_c(uint8_t c) { return (c >= 'A' && c <= 'Z') ? 1 : 0; }
ENC_PURE uint8_t encoding_ascii_to_lower_c(uint8_t c) { return (c >= 'A' && c <= 'Z') ? (uint8_t)(c + 32) : c; }
ENC_PURE uint8_t encoding_ascii_to_upper_c(uint8_t c) { return (c >= 'a' && c <= 'z') ? (uint8_t)(c - 32) : c; }

/** 小写 hex 编码；返回写入字节数（src_len*2），容量不足或非法参数返回 -1。 */
int32_t encoding_hex_encode_c(const uint8_t *src, int32_t src_len, uint8_t *out, int32_t out_cap) {
  static const char hex[] = "0123456789abcdef";
  int32_t i;
  if (!src || !out || src_len < 0)
    return -1;
  if (out_cap < src_len * 2)
    return -1;
  for (i = 0; i < src_len; i++) {
    out[i * 2] = (uint8_t)hex[(src[i] >> 4) & 0x0f];
    out[i * 2 + 1] = (uint8_t)hex[src[i] & 0x0f];
  }
  return src_len * 2;
}

/** hex 解码所需输出字节上界（与 src_len 字符数对应）。 */
int32_t encoding_hex_encoded_len_c(int32_t src_len) {
  if (src_len < 0) {
    return -1;
  }
  return src_len * 2;
}

/** 解析单个 hex 字符为半字节；非法返回 -1。 */
static int32_t shu_hex_nibble(uint8_t c) {
  if (c >= '0' && c <= '9') {
    return (int32_t)(c - '0');
  }
  if (c >= 'a' && c <= 'f') {
    return (int32_t)(c - 'a' + 10);
  }
  if (c >= 'A' && c <= 'F') {
    return (int32_t)(c - 'A' + 10);
  }
  return -1;
}

/** 小写/大写 hex 解码；返回写入字节数，非法字符返回 -1。 */
int32_t encoding_hex_decode_c(const uint8_t *src, int32_t src_len, uint8_t *out, int32_t out_cap) {
  int32_t out_len;
  int32_t i;
  if (!src || !out || src_len < 0 || (src_len & 1) != 0) {
    return -1;
  }
  out_len = src_len / 2;
  if (out_cap < out_len) {
    return -1;
  }
  for (i = 0; i < out_len; i++) {
    int32_t hi = shu_hex_nibble(src[i * 2]);
    int32_t lo = shu_hex_nibble(src[i * 2 + 1]);
    if (hi < 0 || lo < 0) {
      return -1;
    }
    out[i] = (uint8_t)((hi << 4) | lo);
  }
  return out_len;
}

/* --- STD-127：Base32 / percent 编解码 --- */

static const char shu_b32_alphabet[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";

/** RFC 4648 Base32 编码（含 '=' 填充）；返回写入字符数，失败 -1。 */
int32_t encoding_base32_encode_c(const uint8_t *src, int32_t src_len, uint8_t *out, int32_t out_cap) {
  int32_t o;
  int32_t idx;
  int32_t buffer;
  int32_t bits;
  if (!src || !out || src_len < 0) {
    return -1;
  }
  if (out_cap < ((src_len + 4) / 5) * 8) {
    return -1;
  }
  o = 0;
  idx = 0;
  buffer = 0;
  bits = 0;
  while (idx < src_len || bits > 0) {
    if (bits < 5) {
      if (idx < src_len) {
        buffer = (buffer << 8) | src[idx++];
        bits += 8;
      } else if (bits > 0) {
        buffer <<= (5 - bits);
        bits = 5;
      } else {
        break;
      }
    }
    if (bits >= 5) {
      int32_t val = (buffer >> (bits - 5)) & 0x1f;
      bits -= 5;
      out[o++] = (uint8_t)shu_b32_alphabet[val];
    }
  }
  while ((o % 8) != 0) {
    out[o++] = (uint8_t)'=';
  }
  return o;
}

/** 解析 Base32 字符；非法 -1。 */
static int32_t shu_b32_value(uint8_t c) {
  if (c >= 'A' && c <= 'Z') {
    return (int32_t)(c - 'A');
  }
  if (c >= '2' && c <= '7') {
    return (int32_t)(c - '2' + 26);
  }
  if (c >= 'a' && c <= 'z') {
    return (int32_t)(c - 'a');
  }
  return -1;
}

/** RFC 4648 Base32 解码；返回写入字节数，非法 -1。 */
int32_t encoding_base32_decode_c(const uint8_t *src, int32_t src_len, uint8_t *out, int32_t out_cap) {
  int32_t i;
  int32_t o;
  int32_t buffer;
  int32_t bits;
  if (!src || !out || src_len < 0) {
    return -1;
  }
  buffer = 0;
  bits = 0;
  o = 0;
  for (i = 0; i < src_len; i++) {
    uint8_t c = src[i];
    int32_t v;
    if (c == '=') {
      break;
    }
    v = shu_b32_value(c);
    if (v < 0) {
      return -1;
    }
    buffer = (buffer << 5) | v;
    bits += 5;
    if (bits >= 8) {
      bits -= 8;
      if (o >= out_cap) {
        return -1;
      }
      out[o++] = (uint8_t)((buffer >> bits) & 0xff);
    }
  }
  return o;
}

/** 判断 RFC 3986 unreserved 字符。 */
static int shu_percent_unreserved(uint8_t c) {
  if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')) {
    return 1;
  }
  return c == '-' || c == '.' || c == '_' || c == '~';
}

/** percent 编码（unreserved 保留）；返回写入长度，失败 -1。 */
int32_t encoding_percent_encode_c(const uint8_t *src, int32_t src_len, uint8_t *out, int32_t out_cap) {
  static const char hex[] = "0123456789ABCDEF";
  int32_t i;
  int32_t o = 0;
  if (!src || !out || src_len < 0) {
    return -1;
  }
  for (i = 0; i < src_len; i++) {
    uint8_t c = src[i];
    if (shu_percent_unreserved(c)) {
      if (o + 1 > out_cap) {
        return -1;
      }
      out[o++] = c;
    } else {
      if (o + 3 > out_cap) {
        return -1;
      }
      out[o++] = (uint8_t)'%';
      out[o++] = (uint8_t)hex[(c >> 4) & 0x0f];
      out[o++] = (uint8_t)hex[c & 0x0f];
    }
  }
  return o;
}

/** percent 解码；返回写入字节数，非法 -1。 */
int32_t encoding_percent_decode_c(const uint8_t *src, int32_t src_len, uint8_t *out, int32_t out_cap) {
  int32_t i;
  int32_t o = 0;
  if (!src || !out || src_len < 0) {
    return -1;
  }
  for (i = 0; i < src_len; i++) {
    uint8_t c = src[i];
    if (c == '%') {
      int32_t hi;
      int32_t lo;
      if (i + 2 >= src_len) {
        return -1;
      }
      hi = shu_hex_nibble(src[i + 1]);
      lo = shu_hex_nibble(src[i + 2]);
      if (hi < 0 || lo < 0) {
        return -1;
      }
      if (o >= out_cap) {
        return -1;
      }
      out[o++] = (uint8_t)((hi << 4) | lo);
      i += 2;
    } else {
      if (o >= out_cap) {
        return -1;
      }
      out[o++] = c;
    }
  }
  return o;
}

/** STD-127 C 烟测：Base32 `foo` 与 percent `a b` 往返。 */
int32_t encoding_extra_smoke_c(void) {
  static const uint8_t foo[] = "foo";
  uint8_t b32[16];
  uint8_t dec[8];
  int32_t n;
  int32_t m;
  static const uint8_t plain[] = { 'a', ' ', 'b' };
  uint8_t pct[16];
  uint8_t back[8];
  int32_t pn;
  int32_t pd;
  n = encoding_base32_encode_c(foo, 3, b32, 16);
  if (n != 8 || b32[0] != 'M' || b32[1] != 'Z' || b32[2] != 'X' || b32[3] != 'W' || b32[4] != '6') {
    return 1;
  }
  m = encoding_base32_decode_c(b32, n, dec, 8);
  if (m != 3 || dec[0] != 'f' || dec[1] != 'o' || dec[2] != 'o') {
    return 2;
  }
  pn = encoding_percent_encode_c(plain, 3, pct, 16);
  if (pn != 5) {
    return 3;
  }
  pd = encoding_percent_decode_c(pct, pn, back, 8);
  if (pd != 3 || back[0] != 'a' || back[1] != ' ' || back[2] != 'b') {
    return 4;
  }
  return 0;
}
