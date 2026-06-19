/**
 * std/base64/base64.c — Base64 编解码（标准/URL 变体，单遍无分配，性能压榨）
 *
 * 【文件职责】encode/decode standard 与 URL 变体；单遍、静态表、无 malloc。对标 Zig std.base64。
 */

#include <stddef.h>
#include <stdint.h>
#include <string.h>

#if defined(__GNUC__) || defined(__clang__) || defined(__clang__)
#define B64_HOT __attribute__((hot))
#define B64_LIKELY(x)   __builtin_expect(!!(x), 1)
#define B64_UNLIKELY(x) __builtin_expect(!!(x), 0)
#else
#define B64_HOT
#define B64_LIKELY(x)   (x)
#define B64_UNLIKELY(x) (x)
#endif

static const char b64_std_tbl[65] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const char b64_url_tbl[65] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

/* 标准解码表：0..63 -> 值，255 -> 非法/填充；'=' 视为 254 在逻辑中处理 */
static uint8_t b64_std_dec[256];
static uint8_t b64_url_dec[256];
static int b64_tables_init = 0;

static void b64_init_tables(void) {
  if (b64_tables_init) return;
  for (int i = 0; i < 256; i++) { b64_std_dec[i] = 255; b64_url_dec[i] = 255; }
  for (int i = 0; i < 64; i++) {
    b64_std_dec[(unsigned char)b64_std_tbl[i]] = (uint8_t)i;
    b64_url_dec[(unsigned char)b64_url_tbl[i]] = (uint8_t)i;
  }
  b64_std_dec['='] = 254;
  b64_url_dec['='] = 254;
  b64_tables_init = 1;
}

/* 编码：src_len 字节 -> (src_len+2)/3*4 字节（标准含填充）。返回写入字节数，缓冲区不足返回 -1。 */
B64_HOT
int32_t base64_encode_standard_c(const uint8_t * restrict src, int32_t src_len, uint8_t * restrict out, int32_t out_cap) {
  if (B64_UNLIKELY(src == 0 || out == 0 || out_cap < 0)) return -1;
  int32_t need = (src_len + 2) / 3 * 4;
  if (out_cap < need) return -1;
  const uint8_t *s = src;
  const uint8_t *end = src + (size_t)src_len;
  uint8_t *o = out;
  while ((size_t)(end - s) >= 3) {
    uint32_t v = (uint32_t)s[0] << 16 | (uint32_t)s[1] << 8 | (uint32_t)s[2];
    o[0] = (uint8_t)b64_std_tbl[(v >> 18) & 63];
    o[1] = (uint8_t)b64_std_tbl[(v >> 12) & 63];
    o[2] = (uint8_t)b64_std_tbl[(v >> 6) & 63];
    o[3] = (uint8_t)b64_std_tbl[v & 63];
    s += 3; o += 4;
  }
  size_t rem = (size_t)(end - s);
  if (rem == 1) {
    uint32_t v = (uint32_t)s[0] << 16;
    o[0] = (uint8_t)b64_std_tbl[(v >> 18) & 63];
    o[1] = (uint8_t)b64_std_tbl[(v >> 12) & 63];
    o[2] = '=';
    o[3] = '=';
    o += 4;
  } else if (rem == 2) {
    uint32_t v = (uint32_t)s[0] << 16 | (uint32_t)s[1] << 8;
    o[0] = (uint8_t)b64_std_tbl[(v >> 18) & 63];
    o[1] = (uint8_t)b64_std_tbl[(v >> 12) & 63];
    o[2] = (uint8_t)b64_std_tbl[(v >> 6) & 63];
    o[3] = '=';
    o += 4;
  }
  return (int32_t)(o - out);
}

B64_HOT
int32_t base64_encode_url_c(const uint8_t * restrict src, int32_t src_len, uint8_t * restrict out, int32_t out_cap) {
  if (B64_UNLIKELY(src == 0 || out == 0 || out_cap < 0)) return -1;
  int32_t need = (src_len + 2) / 3 * 4;
  if (src_len % 3 != 0) need -= (3 - (src_len % 3)); /* URL 无填充 */
  if (out_cap < need) return -1;
  const uint8_t *s = src;
  const uint8_t *end = src + (size_t)src_len;
  uint8_t *o = out;
  while ((size_t)(end - s) >= 3) {
    uint32_t v = (uint32_t)s[0] << 16 | (uint32_t)s[1] << 8 | (uint32_t)s[2];
    o[0] = (uint8_t)b64_url_tbl[(v >> 18) & 63];
    o[1] = (uint8_t)b64_url_tbl[(v >> 12) & 63];
    o[2] = (uint8_t)b64_url_tbl[(v >> 6) & 63];
    o[3] = (uint8_t)b64_url_tbl[v & 63];
    s += 3; o += 4;
  }
  size_t rem = (size_t)(end - s);
  if (rem == 1) {
    uint32_t v = (uint32_t)s[0] << 16;
    o[0] = (uint8_t)b64_url_tbl[(v >> 18) & 63];
    o[1] = (uint8_t)b64_url_tbl[(v >> 12) & 63];
    o += 2;
  } else if (rem == 2) {
    uint32_t v = (uint32_t)s[0] << 16 | (uint32_t)s[1] << 8;
    o[0] = (uint8_t)b64_url_tbl[(v >> 18) & 63];
    o[1] = (uint8_t)b64_url_tbl[(v >> 12) & 63];
    o[2] = (uint8_t)b64_url_tbl[(v >> 6) & 63];
    o += 3;
  }
  return (int32_t)(o - out);
}

/* 解码：返回写入 out 的字节数，非法输入返回 -1。 */
B64_HOT
int32_t base64_decode_standard_c(const uint8_t * restrict src, int32_t src_len, uint8_t * restrict out, int32_t out_cap) {
  if (B64_UNLIKELY(src == 0 || out == 0)) return -1;
  b64_init_tables();
  if (src_len % 4 != 0) return -1;
  int32_t out_len = (src_len / 4) * 3;
  if (src_len >= 1 && src[src_len - 1] == '=') { out_len--; if (src_len >= 2 && src[src_len - 2] == '=') out_len--; }
  if (out_cap < out_len) return -1;
  const uint8_t *s = src;
  uint8_t *o = out;
  const uint8_t *end = src + (size_t)src_len;
  for (; (size_t)(end - s) >= 4; s += 4) {
    uint8_t a = b64_std_dec[s[0]], b = b64_std_dec[s[1]], c = b64_std_dec[s[2]], d = b64_std_dec[s[3]];
    if (a == 255 || b == 255) return -1;
    if (c == 254) c = 0;
    if (d == 254) d = 0;
    if (c == 255 || d == 255) return -1;
    o[0] = (uint8_t)((a << 2) | (b >> 4));
    if (s[2] == '=') { o += 1; return out_len; }
    o[1] = (uint8_t)((b << 4) | (c >> 2));
    if (s[3] == '=') { o += 2; return out_len; }
    o[2] = (uint8_t)((c << 6) | d);
    o += 3;
  }
  return (int32_t)(o - out);
}

B64_HOT
int32_t base64_decode_url_c(const uint8_t * restrict src, int32_t src_len, uint8_t * restrict out, int32_t out_cap) {
  if (B64_UNLIKELY(src == 0 || out == 0)) return -1;
  b64_init_tables();
  int32_t out_len = (src_len * 3) / 4;
  if (src_len % 4 == 1) return -1;
  if (src_len % 4 != 0) out_len = (src_len * 3) / 4 + (src_len % 4) - 1; /* 无填充时余 2/3 字符 */
  if (out_len < 0 || out_cap < out_len) return -1;
  const uint8_t *s = src;
  uint8_t *o = out;
  const uint8_t *end = src + (size_t)src_len;
  while ((size_t)(end - s) >= 4) {
    uint8_t a = b64_url_dec[s[0]], b = b64_url_dec[s[1]], c = b64_url_dec[s[2]], d = b64_url_dec[s[3]];
    if (a == 255 || b == 255) return -1;
    if (c == 255) c = 0;
    if (d == 255) d = 0;
    o[0] = (uint8_t)((a << 2) | (b >> 4));
    o[1] = (uint8_t)((b << 4) | (c >> 2));
    o[2] = (uint8_t)((c << 6) | d);
    s += 4; o += 3;
  }
  if ((size_t)(end - s) == 2) {
    uint8_t a = b64_url_dec[s[0]], b = b64_url_dec[s[1]];
    if (a == 255 || b == 255) return -1;
    o[0] = (uint8_t)((a << 2) | (b >> 4));
    o += 1;
  } else if ((size_t)(end - s) == 3) {
    uint8_t a = b64_url_dec[s[0]], b = b64_url_dec[s[1]], c = b64_url_dec[s[2]];
    if (a == 255 || b == 255 || c == 255) return -1;
    o[0] = (uint8_t)((a << 2) | (b >> 4));
    o[1] = (uint8_t)((b << 4) | (c >> 2));
    o += 2;
  } else if ((size_t)(end - s) != 0) return -1;
  return (int32_t)(o - out);
}

/* ---------- STD-109：Base64 流式编解码（状态外置，与块 API 结果一致） ---------- */

#define SHU_B64_STREAM_MAGIC 0x42345354u /* 'B4ST' */

/** 流式编解码状态（固定 32 字节布局）。 */
typedef struct {
  uint32_t magic;
  int32_t is_url;
  int32_t is_enc;
  int32_t pending_len;
  uint8_t pending[3];
  int32_t dec_len;
  uint8_t dec_pending[4];
} shu_b64_stream_t;

/** 返回流状态缓冲最小字节数。 */
int32_t base64_stream_state_bytes_c(void) {
  return (int32_t)sizeof(shu_b64_stream_t);
}

/** 校验并返回 base64 流状态指针。 */
static shu_b64_stream_t *shu_b64_stream_cast(uint8_t *state, int32_t state_cap) {
  shu_b64_stream_t *s;
  if (!state || state_cap < (int32_t)sizeof(shu_b64_stream_t)) {
    return NULL;
  }
  s = (shu_b64_stream_t *)state;
  if (s->magic != SHU_B64_STREAM_MAGIC) {
    return NULL;
  }
  return s;
}

/** 初始化 Base64 编码流；url 非 0 为 URL 变体；成功 0。 */
int32_t base64_stream_enc_init_c(uint8_t *state, int32_t state_cap, int32_t url) {
  shu_b64_stream_t *s;
  if (!state || state_cap < (int32_t)sizeof(shu_b64_stream_t)) {
    return -1;
  }
  s = (shu_b64_stream_t *)state;
  memset(s, 0, sizeof(*s));
  s->magic = SHU_B64_STREAM_MAGIC;
  s->is_url = (url != 0) ? 1 : 0;
  s->is_enc = 1;
  return 0;
}

/** 初始化 Base64 解码流；成功 0。 */
int32_t base64_stream_dec_init_c(uint8_t *state, int32_t state_cap, int32_t url) {
  shu_b64_stream_t *s;
  if (!state || state_cap < (int32_t)sizeof(shu_b64_stream_t)) {
    return -1;
  }
  s = (shu_b64_stream_t *)state;
  memset(s, 0, sizeof(*s));
  s->magic = SHU_B64_STREAM_MAGIC;
  s->is_url = (url != 0) ? 1 : 0;
  s->is_enc = 0;
  b64_init_tables();
  return 0;
}

/** 将 1–3 字节编码为 Base64 字符写入 out；返回写入字节数。 */
static int32_t shu_b64_stream_emit_triplet(const shu_b64_stream_t *s, const uint8_t *tri, int32_t n, int32_t is_last,
                                           uint8_t *out, int32_t out_cap) {
  const char *tbl;
  uint32_t v;
  int32_t need;
  if (!s || !tri || !out || n <= 0 || n > 3) {
    return -1;
  }
  tbl = s->is_url ? b64_url_tbl : b64_std_tbl;
  v = (uint32_t)tri[0] << 16;
  if (n > 1) {
    v |= (uint32_t)tri[1] << 8;
  }
  if (n > 2) {
    v |= (uint32_t)tri[2];
  }
  if (n == 3) {
    need = 4;
    if (out_cap < need) {
      return -1;
    }
    out[0] = (uint8_t)tbl[(v >> 18) & 63];
    out[1] = (uint8_t)tbl[(v >> 12) & 63];
    out[2] = (uint8_t)tbl[(v >> 6) & 63];
    out[3] = (uint8_t)tbl[v & 63];
    return 4;
  }
  if (is_last == 0) {
    need = (n == 1) ? 2 : 3;
    if (out_cap < need) {
      return -1;
    }
    out[0] = (uint8_t)tbl[(v >> 18) & 63];
    out[1] = (uint8_t)tbl[(v >> 12) & 63];
    if (n == 2) {
      out[2] = (uint8_t)tbl[(v >> 6) & 63];
      return 3;
    }
    return 2;
  }
  if (s->is_url) {
    need = (n == 1) ? 2 : 3;
    if (out_cap < need) {
      return -1;
    }
    out[0] = (uint8_t)tbl[(v >> 18) & 63];
    out[1] = (uint8_t)tbl[(v >> 12) & 63];
    if (n == 2) {
      out[2] = (uint8_t)tbl[(v >> 6) & 63];
      return 3;
    }
    return 2;
  }
  need = 4;
  if (out_cap < need) {
    return -1;
  }
  out[0] = (uint8_t)tbl[(v >> 18) & 63];
  out[1] = (uint8_t)tbl[(v >> 12) & 63];
  out[2] = (uint8_t)tbl[(v >> 6) & 63];
  out[3] = '=';
  if (n == 1) {
    out[2] = '=';
  }
  return 4;
}

/** 流式 Base64 编码 update；is_last=1 时 flush padding。 */
int32_t base64_stream_enc_update_c(uint8_t *state, int32_t state_cap, const uint8_t *in, int32_t in_len, uint8_t *out,
                                   int32_t out_cap, int32_t is_last, int32_t *in_consumed) {
  shu_b64_stream_t *s;
  int32_t used_in;
  int32_t written;
  uint8_t work[3];
  int32_t wi;
  if (in_consumed) {
    *in_consumed = 0;
  }
  s = shu_b64_stream_cast(state, state_cap);
  if (!s || !s->is_enc || !out || out_cap <= 0) {
    return -1;
  }
  if (in_len > 0 && !in) {
    return -1;
  }
  used_in = 0;
  written = 0;
  wi = 0;
  while (s->pending_len > 0 || used_in < in_len) {
    while (wi < 3 && s->pending_len > 0) {
      work[wi++] = s->pending[0];
      s->pending[0] = s->pending[1];
      s->pending[1] = s->pending[2];
      s->pending_len--;
    }
    while (wi < 3 && used_in < in_len) {
      work[wi++] = in[used_in++];
    }
    if (wi < 3) {
      if (is_last == 0) {
        break;
      }
      if (wi == 0) {
        break;
      }
      {
        int32_t n = shu_b64_stream_emit_triplet(s, work, wi, 1, out + written, out_cap - written);
        if (n < 0) {
          if (in_consumed) {
            *in_consumed = used_in;
          }
          return -1;
        }
        written += n;
      }
      wi = 0;
      break;
    }
    {
      int32_t n = shu_b64_stream_emit_triplet(s, work, 3, 0, out + written, out_cap - written);
      if (n < 0) {
        if (in_consumed) {
          *in_consumed = used_in;
        }
        return -1;
      }
      written += n;
      wi = 0;
    }
  }
  if (wi > 0 && is_last == 0) {
    s->pending[0] = work[0];
    if (wi > 1) {
      s->pending[1] = work[1];
    }
    s->pending_len = wi;
  }
  if (in_consumed) {
    *in_consumed = used_in;
  }
  return written;
}

/** 将 4 个 Base64 字符解码为最多 3 字节。 */
static int32_t shu_b64_stream_decode_quad(const shu_b64_stream_t *s, const uint8_t *quad, int32_t n, int32_t is_last,
                                          uint8_t *out, int32_t out_cap) {
  const uint8_t *dec;
  uint8_t a;
  uint8_t b;
  uint8_t c;
  uint8_t d;
  int32_t out_len;
  if (!s || !quad || !out || n <= 0 || n > 4) {
    return -1;
  }
  dec = s->is_url ? b64_url_dec : b64_std_dec;
  a = dec[quad[0]];
  b = dec[quad[1]];
  if (a == 255 || b == 255) {
    return -1;
  }
  if (n == 2 && is_last != 0) {
    if (out_cap < 1) {
      return -1;
    }
    out[0] = (uint8_t)((a << 2) | (b >> 4));
    return 1;
  }
  if (n == 3 && is_last != 0) {
    c = dec[quad[2]];
    if (c == 255) {
      return -1;
    }
    if (out_cap < 2) {
      return -1;
    }
    out[0] = (uint8_t)((a << 2) | (b >> 4));
    out[1] = (uint8_t)((b << 4) | (c >> 2));
    return 2;
  }
  if (n < 4 && is_last == 0) {
    return 0;
  }
  c = dec[quad[2]];
  d = dec[quad[3]];
  if (c == 254) {
    c = 0;
  }
  if (d == 254) {
    d = 0;
  }
  if (c == 255 || d == 255) {
    return -1;
  }
  out_len = 3;
  if (quad[2] == '=') {
    out_len = 1;
  } else if (quad[3] == '=') {
    out_len = 2;
  }
  if (out_cap < out_len) {
    return -1;
  }
  out[0] = (uint8_t)((a << 2) | (b >> 4));
  if (out_len >= 2) {
    out[1] = (uint8_t)((b << 4) | (c >> 2));
  }
  if (out_len >= 3) {
    out[2] = (uint8_t)((c << 6) | d);
  }
  return out_len;
}

/** 流式 Base64 解码 update；is_last=1 时 flush 尾部。 */
int32_t base64_stream_dec_update_c(uint8_t *state, int32_t state_cap, const uint8_t *in, int32_t in_len, uint8_t *out,
                                   int32_t out_cap, int32_t is_last, int32_t *in_consumed) {
  shu_b64_stream_t *s;
  int32_t used_in;
  int32_t written;
  uint8_t quad[4];
  int32_t qi;
  if (in_consumed) {
    *in_consumed = 0;
  }
  s = shu_b64_stream_cast(state, state_cap);
  if (!s || s->is_enc || !out || out_cap <= 0) {
    return -1;
  }
  if (in_len > 0 && !in) {
    return -1;
  }
  b64_init_tables();
  used_in = 0;
  written = 0;
  qi = s->dec_len;
  if (qi > 0) {
    memcpy(quad, s->dec_pending, (size_t)qi);
  }
  while (qi > 0 || used_in < in_len) {
    while (qi < 4 && used_in < in_len) {
      quad[qi++] = in[used_in++];
    }
    if (qi < 4) {
      if (is_last == 0) {
        break;
      }
      {
        int32_t n = shu_b64_stream_decode_quad(s, quad, qi, 1, out + written, out_cap - written);
        if (n < 0) {
          if (in_consumed) {
            *in_consumed = used_in;
          }
          return -1;
        }
        written += n;
      }
      qi = 0;
      break;
    }
    {
      int32_t n = shu_b64_stream_decode_quad(s, quad, 4, 0, out + written, out_cap - written);
      if (n < 0) {
        if (in_consumed) {
          *in_consumed = used_in;
        }
        return -1;
      }
      written += n;
      qi = 0;
    }
  }
  s->dec_len = qi;
  if (qi > 0) {
    memcpy(s->dec_pending, quad, (size_t)qi);
  }
  if (in_consumed) {
    *in_consumed = used_in;
  }
  return written;
}

/** STD-109：C 层流式 base64 烟测（hello 分块 ≡ 块 API）。 */
int32_t base64_stream_smoke_c(void) {
  static const uint8_t plain[5] = {104, 101, 108, 108, 111};
  uint8_t st[32];
  uint8_t enc[16];
  uint8_t dec[8];
  uint8_t block[16];
  int32_t consumed;
  int32_t n1;
  int32_t n2;
  int32_t dn;
  int32_t i;
  if (base64_encode_standard_c(plain, 5, block, 16) != 8) {
    return -1;
  }
  if (base64_stream_enc_init_c(st, 32, 0) != 0) {
    return -1;
  }
  n1 = base64_stream_enc_update_c(st, 32, plain, 2, enc, 16, 0, &consumed);
  if (n1 < 0 || consumed != 2) {
    return -1;
  }
  n2 = base64_stream_enc_update_c(st, 32, plain + 2, 3, enc + n1, 16 - n1, 1, &consumed);
  if (n2 < 0 || consumed != 3 || n1 + n2 != 8) {
    return -1;
  }
  for (i = 0; i < 8; i++) {
    if (enc[i] != block[i]) {
      return -1;
    }
  }
  if (base64_stream_dec_init_c(st, 32, 0) != 0) {
    return -1;
  }
  dn = base64_stream_dec_update_c(st, 32, enc, 4, dec, 8, 0, &consumed);
  if (dn < 0 || consumed != 4) {
    return -1;
  }
  dn += base64_stream_dec_update_c(st, 32, enc + 4, 4, dec + dn, 8 - dn, 1, &consumed);
  if (dn != 5) {
    return -1;
  }
  for (i = 0; i < 5; i++) {
    if (dec[i] != plain[i]) {
      return -1;
    }
  }
  return 0;
}
