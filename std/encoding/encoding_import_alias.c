/**
 * encoding_import_alias.c — import binding `-o` 链接桩
 *
 * asm co-emit 对 `const encoding = import("std.encoding")` 生成 std_encoding_* 符号；
 * encoding.o 仅导出 encoding_*_c。本 TU 提供 std_encoding_* 转发。
 * utf8_valid / utf8_len_chars 在 shux-c 编译 encoding.x 产物中存在 pi 不递增死循环，此处用 C 直实现。
 */
#include <stdint.h>

extern int32_t encoding_utf8_encode_rune_c(uint32_t r, uint8_t *out);
extern int32_t encoding_utf8_decode_rune_c(const uint8_t *p, int32_t len, uint32_t *out_r);
extern int32_t encoding_ascii_is_alpha_c(uint8_t c);
extern int32_t encoding_ascii_is_digit_c(uint8_t c);
extern int32_t encoding_ascii_is_alnum_c(uint8_t c);
extern int32_t encoding_ascii_is_lower_c(uint8_t c);
extern int32_t encoding_ascii_is_upper_c(uint8_t c);
extern uint8_t encoding_ascii_to_lower_c(uint8_t c);
extern uint8_t encoding_ascii_to_upper_c(uint8_t c);
extern int32_t encoding_hex_encode_c(const uint8_t *src, int32_t src_len, uint8_t *out, int32_t out_cap);
extern int32_t encoding_hex_decode_c(const uint8_t *src, int32_t src_len, uint8_t *out, int32_t out_cap);
extern int32_t encoding_hex_encoded_len_c(int32_t src_len);

static uint32_t encoding_hotfix_utf8_first_byte_len(uint8_t b) {
  if (b <= 127u)
    return 1u;
  if (b >= 128u && b <= 191u)
    return 255u;
  if (b >= 192u && b <= 223u)
    return 2u;
  if (b >= 224u && b <= 239u)
    return 3u;
  if (b >= 240u && b <= 247u)
    return 4u;
  return 255u;
}

/** UTF-8 校验；C 直实现（规避 shux-c 编译 encoding.x 的 pi 递增缺陷）。 */
int32_t std_encoding_utf8_valid(const uint8_t *p, int32_t len) {
  int32_t pi = 0;
  uint32_t n;
  int32_t j;
  if (!p || len < 0)
    return 0;
  while (pi < len) {
    n = encoding_hotfix_utf8_first_byte_len(p[pi]);
    if (n == 255u)
      return 0;
    if (n > 1u) {
      if (pi + (int32_t)n > len)
        return 0;
      j = 1;
      while (j < (int32_t)n) {
        if ((p[pi + j] & 0xC0u) != 0x80u)
          return 0;
        j++;
      }
      if (n == 2u && p[pi] < 194u)
        return 0;
      if (n == 3u && p[pi] == 224u && p[pi + 1] < 160u)
        return 0;
      if (n == 3u && p[pi] == 237u && p[pi + 1] > 159u)
        return 0;
      if (n == 4u && p[pi] == 240u && p[pi + 1] < 144u)
        return 0;
      if (n == 4u && p[pi] == 244u && p[pi + 1] > 143u)
        return 0;
      pi += (int32_t)n;
    } else {
      pi++;
    }
  }
  return 1;
}

/** UTF-8 码点个数；C 直实现。 */
int32_t std_encoding_utf8_len_chars(const uint8_t *p, int32_t len) {
  int32_t count = 0;
  int32_t pi = 0;
  uint32_t n;
  if (!p || len <= 0)
    return 0;
  while (pi < len) {
    n = encoding_hotfix_utf8_first_byte_len(p[pi]);
    if (n == 255u)
      return -1;
    if ((int32_t)n > len - pi)
      return -1;
    pi += (int32_t)n;
    count++;
  }
  return count;
}

/** UTF-8 编码 rune；转发 encoding_utf8_encode_rune_c。 */
int32_t std_encoding_utf8_encode_rune(uint32_t r, uint8_t *out) { return encoding_utf8_encode_rune_c(r, out); }
/** UTF-8 解码 rune；转发 encoding_utf8_decode_rune_c。 */
int32_t std_encoding_utf8_decode_rune(const uint8_t *p, int32_t len, uint32_t *out_r) {
  return encoding_utf8_decode_rune_c(p, len, out_r);
}
/** ASCII is_alpha；转发 encoding_ascii_is_alpha_c。 */
int32_t std_encoding_ascii_is_alpha(uint8_t c) { return encoding_ascii_is_alpha_c(c); }
/** ASCII is_digit；转发 encoding_ascii_is_digit_c。 */
int32_t std_encoding_ascii_is_digit(uint8_t c) { return encoding_ascii_is_digit_c(c); }
/** ASCII is_alnum；转发 encoding_ascii_is_alnum_c。 */
int32_t std_encoding_ascii_is_alnum(uint8_t c) { return encoding_ascii_is_alnum_c(c); }
/** ASCII is_lower；转发 encoding_ascii_is_lower_c。 */
int32_t std_encoding_ascii_is_lower(uint8_t c) { return encoding_ascii_is_lower_c(c); }
/** ASCII is_upper；转发 encoding_ascii_is_upper_c。 */
int32_t std_encoding_ascii_is_upper(uint8_t c) { return encoding_ascii_is_upper_c(c); }
/** ASCII to_lower；转发 encoding_ascii_to_lower_c。 */
uint8_t std_encoding_ascii_to_lower(uint8_t c) { return encoding_ascii_to_lower_c(c); }
/** ASCII to_upper；C 直实现（规避 shux-c 编译 u8 返回缺陷）。 */
uint8_t std_encoding_ascii_to_upper(uint8_t c) {
  if (c >= 97u && c <= 122u)
    return (uint8_t)(c - 32u);
  return c;
}
/** hex encode；转发 encoding_hex_encode_c。 */
int32_t std_encoding_hex_encode(const uint8_t *src, int32_t src_len, uint8_t *out, int32_t out_cap) {
  return encoding_hex_encode_c(src, src_len, out, out_cap);
}
/** hex decode；转发 encoding_hex_decode_c。 */
int32_t std_encoding_hex_decode(const uint8_t *src, int32_t src_len, uint8_t *out, int32_t out_cap) {
  return encoding_hex_decode_c(src, src_len, out, out_cap);
}
/** hex 编码长度；转发 encoding_hex_encoded_len_c。 */
int32_t std_encoding_hex_encoded_len(int32_t src_len) { return encoding_hex_encoded_len_c(src_len); }
