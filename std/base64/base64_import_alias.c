/**
 * base64_import_alias.c — import binding `-o` 链接桩
 *
 * asm co-emit 对 `const base64 = import("std.base64")` 生成 std_base64_* 符号；
 * base64.o 仅导出 base64_*_c。本 TU 提供 std_base64_* 实现。
 * encode/decode standard/url 在 shux-c 编译 base64.x 产物中 padding 写入有缺陷（'=' 未落码），此处 C 直实现。
 */
#include <stdint.h>

extern int32_t base64_stream_state_bytes_c(void);
extern int32_t base64_stream_enc_init_c(uint8_t *state, int32_t state_cap, int32_t url);
extern int32_t base64_stream_dec_init_c(uint8_t *state, int32_t state_cap, int32_t url);
extern int32_t base64_stream_enc_update_c(uint8_t *state, int32_t state_cap, uint8_t *inp, int32_t in_len,
                                          uint8_t *out, int32_t out_cap, int32_t is_last, int32_t *in_consumed);
extern int32_t base64_stream_dec_update_c(uint8_t *state, int32_t state_cap, uint8_t *inp, int32_t in_len,
                                          uint8_t *out, int32_t out_cap, int32_t is_last, int32_t *in_consumed);

/** 标准 Base64 编码字符（0..63）。 */
static uint8_t b64_hotfix_std_enc_char(int32_t idx) {
  if (idx >= 0 && idx < 26)
    return (uint8_t)(65 + idx);
  if (idx >= 26 && idx < 52)
    return (uint8_t)(97 + idx - 26);
  if (idx >= 52 && idx < 62)
    return (uint8_t)(48 + idx - 52);
  if (idx == 62)
    return 43;
  if (idx == 63)
    return 47;
  return 0;
}

/** URL 安全 Base64 编码字符（0..63）。 */
static uint8_t b64_hotfix_url_enc_char(int32_t idx) {
  if (idx >= 0 && idx < 26)
    return (uint8_t)(65 + idx);
  if (idx >= 26 && idx < 52)
    return (uint8_t)(97 + idx - 26);
  if (idx >= 52 && idx < 62)
    return (uint8_t)(48 + idx - 52);
  if (idx == 62)
    return 45;
  if (idx == 63)
    return 95;
  return 0;
}

/** 标准表字符 → 6-bit 值；非法 255，`=` 为 254。 */
static uint32_t b64_hotfix_decode_char_std(uint8_t c) {
  if (c >= 65 && c <= 90)
    return (uint32_t)(c - 65);
  if (c >= 97 && c <= 122)
    return (uint32_t)(c - 97 + 26);
  if (c >= 48 && c <= 57)
    return (uint32_t)(c - 48 + 52);
  if (c == 43)
    return 62;
  if (c == 47)
    return 63;
  if (c == 61)
    return 254;
  return 255;
}

/** URL 表字符 → 6-bit 值；非法 255。 */
static uint32_t b64_hotfix_decode_char_url(uint8_t c) {
  if (c >= 65 && c <= 90)
    return (uint32_t)(c - 65);
  if (c >= 97 && c <= 122)
    return (uint32_t)(c - 97 + 26);
  if (c >= 48 && c <= 57)
    return (uint32_t)(c - 48 + 52);
  if (c == 45)
    return 62;
  if (c == 95)
    return 63;
  return 255;
}

/** 标准 Base64 编码；C 直实现（规避 shux-c padding 缺陷）。 */
int32_t std_base64_encode_standard(uint8_t *src, int32_t src_len, uint8_t *out, int32_t out_cap) {
  int32_t need;
  int32_t si = 0;
  int32_t oi = 0;
  int32_t rem;
  uint32_t v;
  if (!src || !out || out_cap < 0)
    return -1;
  need = (src_len + 2) / 3 * 4;
  if (out_cap < need)
    return -1;
  while (si + 3 <= src_len) {
    v = ((uint32_t)src[si] << 16) | ((uint32_t)src[si + 1] << 8) | (uint32_t)src[si + 2];
    out[oi] = b64_hotfix_std_enc_char((int32_t)((v >> 18) & 63u));
    out[oi + 1] = b64_hotfix_std_enc_char((int32_t)((v >> 12) & 63u));
    out[oi + 2] = b64_hotfix_std_enc_char((int32_t)((v >> 6) & 63u));
    out[oi + 3] = b64_hotfix_std_enc_char((int32_t)(v & 63u));
    si += 3;
    oi += 4;
  }
  rem = src_len - si;
  if (rem == 1) {
    v = (uint32_t)src[si] << 16;
    out[oi] = b64_hotfix_std_enc_char((int32_t)((v >> 18) & 63u));
    out[oi + 1] = b64_hotfix_std_enc_char((int32_t)((v >> 12) & 63u));
    out[oi + 2] = 61;
    out[oi + 3] = 61;
    oi += 4;
  } else if (rem == 2) {
    v = ((uint32_t)src[si] << 16) | ((uint32_t)src[si + 1] << 8);
    out[oi] = b64_hotfix_std_enc_char((int32_t)((v >> 18) & 63u));
    out[oi + 1] = b64_hotfix_std_enc_char((int32_t)((v >> 12) & 63u));
    out[oi + 2] = b64_hotfix_std_enc_char((int32_t)((v >> 6) & 63u));
    out[oi + 3] = 61;
    oi += 4;
  }
  return oi;
}

/** URL 安全 Base64 编码（无 padding）；C 直实现。 */
int32_t std_base64_encode_url(uint8_t *src, int32_t src_len, uint8_t *out, int32_t out_cap) {
  int32_t need;
  int32_t si = 0;
  int32_t oi = 0;
  int32_t rem;
  uint32_t v;
  if (!src || !out || out_cap < 0)
    return -1;
  need = (src_len + 2) / 3 * 4;
  if (src_len % 3 != 0)
    need -= (3 - (src_len % 3));
  if (out_cap < need)
    return -1;
  while (si + 3 <= src_len) {
    v = ((uint32_t)src[si] << 16) | ((uint32_t)src[si + 1] << 8) | (uint32_t)src[si + 2];
    out[oi] = b64_hotfix_url_enc_char((int32_t)((v >> 18) & 63u));
    out[oi + 1] = b64_hotfix_url_enc_char((int32_t)((v >> 12) & 63u));
    out[oi + 2] = b64_hotfix_url_enc_char((int32_t)((v >> 6) & 63u));
    out[oi + 3] = b64_hotfix_url_enc_char((int32_t)(v & 63u));
    si += 3;
    oi += 4;
  }
  rem = src_len - si;
  if (rem == 1) {
    v = (uint32_t)src[si] << 16;
    out[oi] = b64_hotfix_url_enc_char((int32_t)((v >> 18) & 63u));
    out[oi + 1] = b64_hotfix_url_enc_char((int32_t)((v >> 12) & 63u));
    oi += 2;
  } else if (rem == 2) {
    v = ((uint32_t)src[si] << 16) | ((uint32_t)src[si + 1] << 8);
    out[oi] = b64_hotfix_url_enc_char((int32_t)((v >> 18) & 63u));
    out[oi + 1] = b64_hotfix_url_enc_char((int32_t)((v >> 12) & 63u));
    out[oi + 2] = b64_hotfix_url_enc_char((int32_t)((v >> 6) & 63u));
    oi += 3;
  }
  return oi;
}

/** 标准 Base64 解码；C 直实现。 */
int32_t std_base64_decode_standard(uint8_t *src, int32_t src_len, uint8_t *out, int32_t out_cap) {
  int32_t out_len;
  int32_t si = 0;
  int32_t oi = 0;
  uint32_t a;
  uint32_t b;
  uint32_t c;
  uint32_t d;
  if (!src || !out)
    return -1;
  if (src_len % 4 != 0)
    return -1;
  out_len = (src_len / 4) * 3;
  if (src_len >= 1 && src[src_len - 1] == 61) {
    out_len--;
    if (src_len >= 2 && src[src_len - 2] == 61)
      out_len--;
  }
  if (out_cap < out_len)
    return -1;
  while (si + 4 <= src_len) {
    a = b64_hotfix_decode_char_std(src[si]);
    b = b64_hotfix_decode_char_std(src[si + 1]);
    c = b64_hotfix_decode_char_std(src[si + 2]);
    d = b64_hotfix_decode_char_std(src[si + 3]);
    if (a == 255 || b == 255)
      return -1;
    if (c == 254)
      c = 0;
    if (d == 254)
      d = 0;
    if (c == 255 || d == 255)
      return -1;
    out[oi] = (uint8_t)((a << 2) | (b >> 4));
    if (src[si + 2] == 61)
      return out_len;
    out[oi + 1] = (uint8_t)((b << 4) | (c >> 2));
    if (src[si + 3] == 61)
      return out_len;
    out[oi + 2] = (uint8_t)((c << 6) | d);
    si += 4;
    oi += 3;
  }
  return oi;
}

/** URL 变体解码；C 直实现。 */
int32_t std_base64_decode_url(uint8_t *src, int32_t src_len, uint8_t *out, int32_t out_cap) {
  int32_t out_len;
  int32_t si = 0;
  int32_t oi = 0;
  int32_t rem;
  uint32_t a;
  uint32_t b;
  uint32_t c;
  uint32_t d;
  if (!src || !out)
    return -1;
  out_len = (src_len * 3) / 4;
  if (src_len % 4 == 1)
    return -1;
  if (src_len % 4 != 0)
    out_len = (src_len * 3) / 4 + (src_len % 4) - 1;
  if (out_len < 0 || out_cap < out_len)
    return -1;
  while (si + 4 <= src_len) {
    a = b64_hotfix_decode_char_url(src[si]);
    b = b64_hotfix_decode_char_url(src[si + 1]);
    c = b64_hotfix_decode_char_url(src[si + 2]);
    d = b64_hotfix_decode_char_url(src[si + 3]);
    if (a == 255 || b == 255)
      return -1;
    if (c == 255)
      c = 0;
    if (d == 255)
      d = 0;
    out[oi] = (uint8_t)((a << 2) | (b >> 4));
    out[oi + 1] = (uint8_t)((b << 4) | (c >> 2));
    out[oi + 2] = (uint8_t)((c << 6) | d);
    si += 4;
    oi += 3;
  }
  rem = src_len - si;
  if (rem == 2) {
    a = b64_hotfix_decode_char_url(src[si]);
    b = b64_hotfix_decode_char_url(src[si + 1]);
    if (a == 255 || b == 255)
      return -1;
    out[oi] = (uint8_t)((a << 2) | (b >> 4));
    oi++;
  } else if (rem == 3) {
    a = b64_hotfix_decode_char_url(src[si]);
    b = b64_hotfix_decode_char_url(src[si + 1]);
    c = b64_hotfix_decode_char_url(src[si + 2]);
    if (a == 255 || b == 255 || c == 255)
      return -1;
    out[oi] = (uint8_t)((a << 2) | (b >> 4));
    out[oi + 1] = (uint8_t)((b << 4) | (c >> 2));
    oi += 2;
  } else if (rem != 0) {
    return -1;
  }
  return oi;
}

/** 流状态字节数；转发 base64_stream_state_bytes_c。 */
int32_t std_base64_stream_state_bytes(void) { return base64_stream_state_bytes_c(); }

/** 流编码 init；转发 base64_stream_enc_init_c。 */
int32_t std_base64_stream_enc_init(uint8_t *state, int32_t state_cap, int32_t url) {
  return base64_stream_enc_init_c(state, state_cap, url);
}

/** 流解码 init；转发 base64_stream_dec_init_c。 */
int32_t std_base64_stream_dec_init(uint8_t *state, int32_t state_cap, int32_t url) {
  return base64_stream_dec_init_c(state, state_cap, url);
}

/** 流编码 update；转发 base64_stream_enc_update_c。 */
int32_t std_base64_stream_enc_update(uint8_t *state, int32_t state_cap, uint8_t *inp, int32_t in_len, uint8_t *out,
                                     int32_t out_cap, int32_t is_last, int32_t *in_consumed) {
  return base64_stream_enc_update_c(state, state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
}

/** 流解码 update；转发 base64_stream_dec_update_c。 */
int32_t std_base64_stream_dec_update(uint8_t *state, int32_t state_cap, uint8_t *inp, int32_t in_len, uint8_t *out,
                                     int32_t out_cap, int32_t is_last, int32_t *in_consumed) {
  return base64_stream_dec_update_c(state, state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
}
