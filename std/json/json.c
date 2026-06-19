/**
 * std/json/json.c — JSON 最小解析与生成（对标 Zig std.json、Rust serde_json）
 *
 * 【文件职责】解析 number/bool/null/string；生成 number、bool、null、转义字符串。单遍、无 sscanf，性能优先。
 * 【API 对标】Zig parseFromSlice；Rust serde_json::from_str / to_string。仅最小子集，无大依赖。
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/** 手写 double 解析（单遍、无 sscanf）：[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?。*consumed 写入消费字节数；成功返回 0。 */
int32_t json_parse_number_c(const uint8_t *ptr, int32_t len, double *out_val, int32_t *consumed) {
  if (!ptr || len <= 0 || !out_val || !consumed) return -1;
  *consumed = 0;
  int32_t i = 0;
  int neg = 0;
  if (ptr[i] == '-') { neg = 1; i++; }
  else if (ptr[i] == '+') i++;
  if (i >= len || ptr[i] < '0' || ptr[i] > '9') return -1;
  uint64_t mantissa = 0;
  while (i < len && ptr[i] >= '0' && ptr[i] <= '9') {
    mantissa = mantissa * 10 + (ptr[i] - '0');
    i++;
  }
  double val = (double)mantissa;
  if (i < len && ptr[i] == '.') {
    i++;
    double frac = 0.0;
    double div = 1.0;
    while (i < len && ptr[i] >= '0' && ptr[i] <= '9') {
      frac = frac * 10.0 + (double)(ptr[i] - '0');
      div *= 10.0;
      i++;
    }
    val += frac / div;
  }
  if (i < len && (ptr[i] == 'e' || ptr[i] == 'E')) {
    i++;
    int exp_neg = 0;
    if (i < len && (ptr[i] == '-' || ptr[i] == '+')) { exp_neg = (ptr[i] == '-'); i++; }
    int exp = 0;
    while (i < len && ptr[i] >= '0' && ptr[i] <= '9') { exp = exp * 10 + (ptr[i] - '0'); if (exp > 999) break; i++; }
    if (exp_neg) exp = -exp;
    if (exp > 308) exp = 308;
    if (exp < -308) exp = -308;
    double scale = 1.0;
    while (exp > 0) { scale *= 10.0; exp--; }
    while (exp < 0) { scale *= 0.1; exp++; }
    val *= scale;
  }
  if (neg) val = -val;
  *out_val = val;
  *consumed = i;
  return 0;
}

int32_t json_parse_null_c(const uint8_t *ptr, int32_t len, int32_t *consumed) {
  if (!ptr || len < 4 || !consumed) return 0;
  if (ptr[0]=='n'&&ptr[1]=='u'&&ptr[2]=='l'&&ptr[3]=='l') { *consumed = 4; return 1; }
  return 0;
}

int32_t json_parse_bool_c(const uint8_t *ptr, int32_t len, int32_t *out, int32_t *consumed) {
  if (!ptr || len < 4 || !out || !consumed) return 0;
  if (len >= 4 && ptr[0]=='t'&&ptr[1]=='r'&&ptr[2]=='u'&&ptr[3]=='e') { *out = 1; *consumed = 4; return 1; }
  if (len >= 5 && ptr[0]=='f'&&ptr[1]=='a'&&ptr[2]=='l'&&ptr[3]=='s'&&ptr[4]=='e') { *out = 0; *consumed = 5; return 1; }
  return 0;
}

/** 解析 JSON 字符串 "..."（含 \\ \" \/ \b \f \n \r \t \uXXXX）；*consumed 含前后引号；内容写入 out，最多 out_cap；返回内容长度，失败 -1。 */
int32_t json_parse_string_c(const uint8_t *ptr, int32_t len, uint8_t *out, int32_t out_cap, int32_t *consumed) {
  if (!ptr || len < 2 || ptr[0] != '"' || !consumed) return -1;
  int32_t i = 1;
  int32_t o = 0;
  while (i < len && ptr[i] != '"') {
    if (ptr[i] == '\\') {
      i++;
      if (i >= len) return -1;
      if (o >= out_cap) return -1;
      if (ptr[i] == '"') out[o++] = '"';
      else if (ptr[i] == '\\') out[o++] = '\\';
      else if (ptr[i] == '/') out[o++] = '/';
      else if (ptr[i] == 'b') out[o++] = '\b';
      else if (ptr[i] == 'f') out[o++] = '\f';
      else if (ptr[i] == 'n') out[o++] = '\n';
      else if (ptr[i] == 'r') out[o++] = '\r';
      else if (ptr[i] == 't') out[o++] = '\t';
      else if (ptr[i] == 'u' && i + 4 < len) {
        uint32_t u = 0;
        for (int k = 0; k < 4; k++) {
          uint8_t c = ptr[i+1+k];
          if (c >= '0' && c <= '9') u = (u << 4) + (c - '0');
          else if (c >= 'a' && c <= 'f') u = (u << 4) + (c - 'a' + 10);
          else if (c >= 'A' && c <= 'F') u = (u << 4) + (c - 'A' + 10);
          else return -1;
        }
        i += 4;
        if (u <= 0x7fu) out[o++] = (uint8_t)u;
        else if (u <= 0x7ffu) {
          if (o + 2 > out_cap) return -1;
          out[o++] = (uint8_t)(0xc0u | (u >> 6));
          out[o++] = (uint8_t)(0x80u | (u & 0x3fu));
        } else if (u <= 0xffffu) {
          if (o + 3 > out_cap) return -1;
          out[o++] = (uint8_t)(0xe0u | (u >> 12));
          out[o++] = (uint8_t)(0x80u | ((u >> 6) & 0x3fu));
          out[o++] = (uint8_t)(0x80u | (u & 0x3fu));
        } else return -1;
        i++;
        continue;
      } else return -1;
      i++;
    } else {
      if (ptr[i] < 0x20) return -1;
      if (o >= out_cap) return -1;
      out[o++] = ptr[i++];
    }
  }
  if (i >= len || ptr[i] != '"') return -1;
  *consumed = i + 1;
  return o;
}

/** 将 ptr[0..len] 按 JSON 字符串转义写入 buf（含前后引号）；返回写入长度，不足 -1。 */
/** 转义字符串内容（不含外围引号）。 */
static int32_t json_escape_inner_c(const uint8_t *ptr, int32_t len, uint8_t *buf, int32_t buf_cap) {
  int32_t i = 0;
  if (!ptr || !buf || buf_cap <= 0) return -1;
  for (int32_t j = 0; j < len && i < buf_cap; j++) {
    uint8_t c = ptr[j];
    if (c == '"') {
      if (i + 2 > buf_cap) return -1;
      buf[i++] = '\\';
      buf[i++] = '"';
    } else if (c == '\\') {
      if (i + 2 > buf_cap) return -1;
      buf[i++] = '\\';
      buf[i++] = '\\';
    } else if (c == '\n') {
      if (i + 2 > buf_cap) return -1;
      buf[i++] = '\\';
      buf[i++] = 'n';
    } else if (c == '\r') {
      if (i + 2 > buf_cap) return -1;
      buf[i++] = '\\';
      buf[i++] = 'r';
    } else if (c == '\t') {
      if (i + 2 > buf_cap) return -1;
      buf[i++] = '\\';
      buf[i++] = 't';
    } else if (c == '\b') {
      if (i + 2 > buf_cap) return -1;
      buf[i++] = '\\';
      buf[i++] = 'b';
    } else if (c == '\f') {
      if (i + 2 > buf_cap) return -1;
      buf[i++] = '\\';
      buf[i++] = 'f';
    } else {
      buf[i++] = c;
    }
  }
  return i;
}

int32_t json_escape_c(const uint8_t *ptr, int32_t len, uint8_t *buf, int32_t buf_cap) {
  int32_t i = 0;
  int32_t n;
  if (!ptr || !buf || buf_cap < 2) return -1;
  buf[i++] = '"';
  n = json_escape_inner_c(ptr, len, buf + i, buf_cap - i - 1);
  if (n < 0) return -1;
  i += n;
  if (i >= buf_cap) return -1;
  buf[i++] = '"';
  return i;
}

/** 追加 "null" 到 buf；返回 4，不足 -1。 */
int32_t json_append_null_c(uint8_t *buf, int32_t buf_cap) {
  if (!buf || buf_cap < 4) return -1;
  buf[0] = 'n'; buf[1] = 'u'; buf[2] = 'l'; buf[3] = 'l';
  return 4;
}

/** 追加 "true" 或 "false" 到 buf；返回写入长度，不足 -1。 */
int32_t json_append_bool_c(uint8_t *buf, int32_t buf_cap, int32_t val) {
  if (!buf || buf_cap < 5) return -1;
  if (val) { buf[0]='t';buf[1]='r';buf[2]='u';buf[3]='e'; return 4; }
  buf[0]='f';buf[1]='a';buf[2]='l';buf[3]='s';buf[4]='e'; return 5;
}

/** 将 number 追加为 JSON 到 buf（%.16g 风格，无 sscanf）；返回写入长度，不足 -1。 */
int32_t json_append_number_c(uint8_t *buf, int32_t buf_cap, double val) {
  if (!buf || buf_cap <= 0) return -1;
  int32_t i = 0;
  if (val < 0) { buf[i++] = '-'; val = -val; }
  if (val != val) { if (buf_cap - i < 3) return -1; buf[i++]='n';buf[i++]='a';buf[i++]='n'; return i; }
  if (val == 1.0/0.0 || val == -1.0/0.0) { if (buf_cap - i < 3) return -1; buf[i++]='i';buf[i++]='n';buf[i++]='f'; return i; }
  uint64_t u = (uint64_t)val;
  if ((double)u == val && u <= 9999999999999999ULL) {
    uint64_t t = u;
    uint8_t d[20];
    int nd = 0;
    do { d[nd++] = (uint8_t)('0' + (t % 10)); t /= 10; } while (t);
    if (i + nd > buf_cap) return -1;
    while (nd--) buf[i++] = d[nd];
    return i;
  }
  double frac = val - (double)(uint64_t)val;
  if (frac < 0) frac = -frac;
  if (val >= 1e-3 && val < 1e16) {
    uint64_t ip = (uint64_t)val;
    uint8_t d[20];
    int nd = 0;
    uint64_t t = ip;
    do { d[nd++] = (uint8_t)('0' + (t % 10)); t /= 10; } while (t);
    if (i + nd > buf_cap) return -1;
    while (nd--) buf[i++] = d[nd];
    if (frac > 1e-15) {
      if (i >= buf_cap - 1) return -1;
      buf[i++] = '.';
      for (int k = 0; k < 15 && i < buf_cap; k++) {
        frac *= 10;
        int digit = (int)frac;
        buf[i++] = (uint8_t)('0' + digit);
        frac -= digit;
        if (frac < 1e-15) break;
      }
    }
    return i;
  }
  int exp = 0;
  while (val >= 10.0) { val *= 0.1; exp++; }
  while (val < 1.0 && val > 0) { val *= 10.0; exp--; }
  if (i >= buf_cap) return -1;
  buf[i++] = (uint8_t)('0' + (int)val);
  val -= (int)val;
  if (i < buf_cap && (val > 1e-15 || exp != 0)) buf[i++] = '.';
  for (int k = 0; k < 14 && i < buf_cap; k++) {
    val *= 10;
    int digit = (int)val;
    buf[i++] = (uint8_t)('0' + digit);
    val -= digit;
    if (val < 1e-15) break;
  }
  if (exp != 0 && buf_cap - i >= 2) {
    buf[i++] = 'e';
    if (exp < 0) { buf[i++] = '-'; exp = -exp; }
    else buf[i++] = '+';
    int en = 0;
    uint8_t ed[4];
    do { ed[en++] = (uint8_t)('0' + (exp % 10)); exp /= 10; } while (exp && en < 4);
    while (en-- && i < buf_cap) buf[i++] = ed[en];
  }
  return i;
}

/** JSON 游标：增量解析 flat object（供 std.schema 使用）。 */
typedef struct json_cursor {
  const uint8_t *ptr;
  int32_t len;
  int32_t off;
} json_cursor_t;

/** 跳过 JSON 空白。 */
static void json_cursor_skip_ws(json_cursor_t *cur) {
  if (!cur) return;
  while (cur->off < cur->len) {
    uint8_t c = cur->ptr[cur->off];
    if (c == ' ' || c == '\t' || c == '\n' || c == '\r') cur->off++;
    else break;
  }
}

/** 跳过单个 JSON 值并前进 off；失败返回 -1。 */
static int32_t json_cursor_skip_value_impl(json_cursor_t *cur) {
  int32_t consumed = 0;
  int32_t dummy = 0;
  double dv = 0.0;
  if (!cur || cur->off >= cur->len) return -1;
  json_cursor_skip_ws(cur);
  if (cur->off >= cur->len) return -1;
  const uint8_t *p = cur->ptr + cur->off;
  int32_t rem = cur->len - cur->off;
  uint8_t c = p[0];
  if (c == '"') {
    int32_t i = 1;
    while (i < rem) {
      if (p[i] == '\\') { i += 2; continue; }
      if (p[i] == '"') { cur->off += i + 1; return 0; }
      i++;
    }
    return -1;
  }
  if (c == '{') {
    cur->off++;
    json_cursor_skip_ws(cur);
    if (cur->off < cur->len && cur->ptr[cur->off] == '}') { cur->off++; return 0; }
    for (;;) {
      if (json_cursor_skip_value_impl(cur) != 0) return -1;
      json_cursor_skip_ws(cur);
      if (cur->off >= cur->len || cur->ptr[cur->off] != ':') return -1;
      cur->off++;
      if (json_cursor_skip_value_impl(cur) != 0) return -1;
      json_cursor_skip_ws(cur);
      if (cur->off >= cur->len) return -1;
      c = cur->ptr[cur->off];
      if (c == '}') { cur->off++; return 0; }
      if (c != ',') return -1;
      cur->off++;
    }
  }
  if (c == '[') {
    cur->off++;
    json_cursor_skip_ws(cur);
    if (cur->off < cur->len && cur->ptr[cur->off] == ']') { cur->off++; return 0; }
    for (;;) {
      if (json_cursor_skip_value_impl(cur) != 0) return -1;
      json_cursor_skip_ws(cur);
      if (cur->off >= cur->len) return -1;
      c = cur->ptr[cur->off];
      if (c == ']') { cur->off++; return 0; }
      if (c != ',') return -1;
      cur->off++;
    }
  }
  if (c == 'n' && json_parse_null_c(p, rem, &consumed)) { cur->off += consumed; return 0; }
  if (json_parse_bool_c(p, rem, &dummy, &consumed)) { cur->off += consumed; return 0; }
  if (json_parse_number_c(p, rem, &dv, &consumed) == 0) { cur->off += consumed; return 0; }
  return -1;
}

/** 初始化游标。 */
void json_cursor_init_c(json_cursor_t *cur, const uint8_t *ptr, int32_t len) {
  if (!cur) return;
  cur->ptr = ptr;
  cur->len = len;
  cur->off = 0;
}

/** 进入 JSON object；期望 leading `{`。 */
int32_t json_cursor_enter_object_c(json_cursor_t *cur) {
  if (!cur) return -1;
  json_cursor_skip_ws(cur);
  if (cur->off >= cur->len || cur->ptr[cur->off] != '{') return -1;
  cur->off++;
  json_cursor_skip_ws(cur);
  return 0;
}

/** 读取下一 object 键；成功 1，结束 0，错误 -1。off 停在 value 起始。 */
int32_t json_cursor_object_next_c(json_cursor_t *cur, uint8_t *key_buf, int32_t key_cap,
                                  int32_t *key_len) {
  int32_t consumed = 0;
  int32_t kl;
  if (!cur || !key_buf || key_cap <= 0) return -1;
  json_cursor_skip_ws(cur);
  if (cur->off >= cur->len) return -1;
  if (cur->ptr[cur->off] == '}') { cur->off++; return 0; }
  if (cur->off > 0 && cur->ptr[cur->off] == ',') cur->off++;
  json_cursor_skip_ws(cur);
  if (cur->off >= cur->len || cur->ptr[cur->off] != '"') return -1;
  kl = json_parse_string_c(cur->ptr + cur->off, cur->len - cur->off, key_buf, key_cap, &consumed);
  if (kl < 0) return -1;
  key_buf[kl] = '\0';
  if (key_len) *key_len = kl;
  cur->off += consumed;
  json_cursor_skip_ws(cur);
  if (cur->off >= cur->len || cur->ptr[cur->off] != ':') return -1;
  cur->off++;
  json_cursor_skip_ws(cur);
  return 1;
}

/** 跳过当前 value。 */
int32_t json_cursor_skip_value_c(json_cursor_t *cur) {
  return json_cursor_skip_value_impl(cur);
}

/** 从缓冲起点跳过单个 JSON 值；写 *consumed 并返回 0，失败 -1。 */
int32_t json_skip_value_c(const uint8_t *ptr, int32_t len, int32_t *consumed) {
  json_cursor_t cur;
  if (!ptr || len < 0) return -1;
  json_cursor_init_c(&cur, ptr, len);
  if (json_cursor_skip_value_c(&cur) != 0) return -1;
  if (consumed) *consumed = cur.off;
  return 0;
}

/** 零拷贝视图：含转义时 *out_len = JSON_VIEW_NEEDS_COPY 并返回 NULL。 */
#define JSON_VIEW_NEEDS_COPY (-2)
#define JSON_DECODE_MISSING (-3)

const uint8_t *json_parse_string_view_c(const uint8_t *ptr, int32_t len, int32_t *out_len,
                                        int32_t *consumed) {
  int32_t i;
  if (!ptr || len < 2 || ptr[0] != '"' || !out_len || !consumed) return NULL;
  for (i = 1; i < len; i++) {
    if (ptr[i] == '\\') {
      *out_len = JSON_VIEW_NEEDS_COPY;
      *consumed = 0;
      return NULL;
    }
    if (ptr[i] == '"') {
      *out_len = i - 1;
      *consumed = i + 1;
      return ptr + 1;
    }
  }
  return NULL;
}

/** 进入 JSON array；期望 leading `[`。 */
int32_t json_cursor_enter_array_c(json_cursor_t *cur) {
  if (!cur) return -1;
  json_cursor_skip_ws(cur);
  if (cur->off >= cur->len || cur->ptr[cur->off] != '[') return -1;
  cur->off++;
  json_cursor_skip_ws(cur);
  return 0;
}

/** 数组内是否还有元素：1 有，0 已到 `]`（并消费 `]`），错误 -1。 */
int32_t json_cursor_array_has_elem_c(json_cursor_t *cur) {
  if (!cur) return -1;
  json_cursor_skip_ws(cur);
  if (cur->off >= cur->len) return -1;
  if (cur->ptr[cur->off] == ']') {
    cur->off++;
    return 0;
  }
  if (cur->ptr[cur->off] == ',') {
    cur->off++;
    json_cursor_skip_ws(cur);
    if (cur->off >= cur->len) return -1;
    if (cur->ptr[cur->off] == ']') {
      cur->off++;
      return 0;
    }
  }
  return 1;
}

/** 游标处 JSON 值种类：1 string 2 number 3 object 4 array 5 null 6 bool，未知 0。 */
int32_t json_cursor_value_type_c(json_cursor_t *cur) {
  if (!cur || cur->off >= cur->len) return 0;
  json_cursor_skip_ws(cur);
  if (cur->off >= cur->len) return 0;
  {
    uint8_t c = cur->ptr[cur->off];
    if (c == '"') return 1;
    if (c == '{') return 3;
    if (c == '[') return 4;
    if (c == 'n') return 5;
    if (c == 't' || c == 'f') return 6;
    if (c == '-' || (c >= '0' && c <= '9')) return 2;
  }
  return 0;
}

/** 在 ptr 起点解码 i32；成功 0 并写 consumed/out。 */
int32_t json_decode_i32_at_c(const uint8_t *ptr, int32_t len, int32_t *consumed, int32_t *out) {
  double dv = 0.0;
  int32_t con = 0;
  if (!ptr || !consumed || !out) return -1;
  if (json_parse_number_c(ptr, len, &dv, &con) != 0) return -1;
  *consumed = con;
  *out = (int32_t)dv;
  return 0;
}

/** 在 ptr 起点解码 f64；成功 0 并写 consumed/out。 */
int32_t json_decode_f64_at_c(const uint8_t *ptr, int32_t len, int32_t *consumed, double *out) {
  double dv = 0.0;
  int32_t con = 0;
  if (!ptr || !consumed || !out) return -1;
  if (json_parse_number_c(ptr, len, &dv, &con) != 0) return -1;
  *consumed = con;
  *out = dv;
  return 0;
}

/** 在 ptr 起点解码 bool；成功 0。 */
int32_t json_decode_bool_at_c(const uint8_t *ptr, int32_t len, int32_t *consumed, int32_t *out) {
  int32_t con = 0;
  if (!ptr || !consumed || !out) return -1;
  if (!json_parse_bool_c(ptr, len, out, &con)) return -1;
  *consumed = con;
  return 0;
}

/** 在 ptr 起点解码 string 到 out；成功 0 并写 out_len/consumed。 */
int32_t json_decode_string_at_c(const uint8_t *ptr, int32_t len, uint8_t *out, int32_t out_cap,
                                int32_t *out_len, int32_t *consumed) {
  int32_t con = 0;
  int32_t n;
  if (!ptr || !out || !out_len || !consumed) return -1;
  n = json_parse_string_c(ptr, len, out, out_cap, &con);
  if (n < 0) return -1;
  *out_len = n;
  *consumed = con;
  return 0;
}

/** 比较 key_buf 与 key[0..key_len)。 */
static int32_t json_key_eq(const uint8_t *key_buf, int32_t key_len, const uint8_t *key,
                           int32_t want_len) {
  if (key_len != want_len) return 0;
  if (want_len <= 0) return 1;
  return memcmp(key_buf, key, (size_t)want_len) == 0 ? 1 : 0;
}

/** object 内按 key 解码 i32；缺键 JSON_DECODE_MISSING。 */
int32_t json_object_decode_i32_c(json_cursor_t *cur, const uint8_t *key, int32_t key_len,
                                 int32_t *out) {
  json_cursor_t scan;
  uint8_t kbuf[64];
  int32_t kl = 0;
  int32_t nr = 0;
  if (!cur || !key || !out) return -1;
  scan = *cur;
  if (json_cursor_enter_object_c(&scan) != 0) return -1;
  while ((nr = json_cursor_object_next_c(&scan, kbuf, (int32_t)sizeof kbuf, &kl)) == 1) {
    if (json_key_eq(kbuf, kl, key, key_len)) {
      return json_decode_i32_at_c(scan.ptr + scan.off, scan.len - scan.off, &kl, out);
    }
    if (json_cursor_skip_value_c(&scan) != 0) return -1;
  }
  if (nr < 0) return -1;
  return JSON_DECODE_MISSING;
}

/** object 内按 key 解码 bool；缺键 JSON_DECODE_MISSING。 */
int32_t json_object_decode_bool_c(json_cursor_t *cur, const uint8_t *key, int32_t key_len,
                                  int32_t *out) {
  json_cursor_t scan;
  uint8_t kbuf[64];
  int32_t kl = 0;
  int32_t nr = 0;
  if (!cur || !key || !out) return -1;
  scan = *cur;
  if (json_cursor_enter_object_c(&scan) != 0) return -1;
  while ((nr = json_cursor_object_next_c(&scan, kbuf, (int32_t)sizeof kbuf, &kl)) == 1) {
    if (json_key_eq(kbuf, kl, key, key_len)) {
      return json_decode_bool_at_c(scan.ptr + scan.off, scan.len - scan.off, &kl, out);
    }
    if (json_cursor_skip_value_c(&scan) != 0) return -1;
  }
  if (nr < 0) return -1;
  return JSON_DECODE_MISSING;
}

/** object 内按 key 解码 string；缺键 JSON_DECODE_MISSING。 */
int32_t json_object_decode_string_c(json_cursor_t *cur, const uint8_t *key, int32_t key_len,
                                    uint8_t *out, int32_t out_cap, int32_t *out_len) {
  json_cursor_t scan;
  uint8_t kbuf[64];
  int32_t kl = 0;
  int32_t nr = 0;
  int32_t con = 0;
  if (!cur || !key || !out || !out_len) return -1;
  scan = *cur;
  if (json_cursor_enter_object_c(&scan) != 0) return -1;
  while ((nr = json_cursor_object_next_c(&scan, kbuf, (int32_t)sizeof kbuf, &kl)) == 1) {
    if (json_key_eq(kbuf, kl, key, key_len)) {
      if (json_decode_string_at_c(scan.ptr + scan.off, scan.len - scan.off, out, out_cap, out_len,
                                  &con) != 0)
        return -1;
      return 0;
    }
    if (json_cursor_skip_value_c(&scan) != 0) return -1;
  }
  if (nr < 0) return -1;
  return JSON_DECODE_MISSING;
}

/** 在当前 object 游标内查找 key；成功时 out_at 指向 value 起始。 */
static int32_t json_cursor_find_key(json_cursor_t *cur, const uint8_t *key, int32_t key_len,
                                    json_cursor_t *out_at) {
  json_cursor_t scan;
  uint8_t kbuf[64];
  int32_t kl = 0;
  int32_t nr = 0;
  if (!cur || !key || !out_at) return -1;
  scan = *cur;
  while ((nr = json_cursor_object_next_c(&scan, kbuf, (int32_t)sizeof kbuf, &kl)) == 1) {
    if (json_key_eq(kbuf, kl, key, key_len)) {
      *out_at = scan;
      return 0;
    }
    if (json_cursor_skip_value_c(&scan) != 0) return -1;
  }
  if (nr < 0) return -1;
  return JSON_DECODE_MISSING;
}

/** 路径段是否为非负整数数组下标。 */
static int32_t json_path_seg_is_index(const uint8_t *seg, int32_t seg_len, int32_t *out_idx) {
  int32_t i = 0;
  int32_t v = 0;
  if (!seg || seg_len <= 0 || !out_idx) return 0;
  for (i = 0; i < seg_len; i++) {
    if (seg[i] < (uint8_t)'0' || seg[i] > (uint8_t)'9') return 0;
    v = v * 10 + (int32_t)(seg[i] - (uint8_t)'0');
  }
  *out_idx = v;
  return 1;
}

/** 在 array 游标处取第 index 个元素；out_at 指向元素 value 起始。 */
static int32_t json_cursor_find_array_index(json_cursor_t *cur, int32_t index, json_cursor_t *out_at) {
  json_cursor_t scan;
  int32_t i = 0;
  int32_t has = 0;
  if (!cur || !out_at || index < 0) return -1;
  scan = *cur;
  if (json_cursor_enter_array_c(&scan) != 0) return -1;
  for (;;) {
    has = json_cursor_array_has_elem_c(&scan);
    if (has < 0) return -1;
    if (has == 0) return JSON_DECODE_MISSING;
    if (i == index) {
      *out_at = scan;
      return 0;
    }
    if (json_cursor_skip_value_c(&scan) != 0) return -1;
    i++;
  }
}

/** 跟随单段路径（object key 或 array index）。 */
static int32_t json_cursor_follow_path_seg(json_cursor_t *cur, const uint8_t *seg, int32_t seg_len,
                                           json_cursor_t *out_at) {
  int32_t idx = 0;
  if (!cur || !seg || !out_at || seg_len <= 0) return -1;
  if (json_path_seg_is_index(seg, seg_len, &idx)) return json_cursor_find_array_index(cur, idx, out_at);
  return json_cursor_find_key(cur, seg, seg_len, out_at);
}

/** 为下一段路径准备 scan（下一段为 index 时保持 array 头；否则 enter object）。 */
static int32_t json_cursor_descend_for_next(json_cursor_t *at, const uint8_t *path, int32_t next_i,
                                            int32_t path_len, json_cursor_t *scan) {
  int32_t j = next_i;
  int32_t idx = 0;
  if (!at || !scan || next_i >= path_len) return -1;
  while (j < path_len && path[j] != (uint8_t)'.') j++;
  *scan = *at;
  if (json_path_seg_is_index(path + next_i, j - next_i, &idx)) {
    if (json_cursor_value_type_c(at) != 4) return -1;
    return 0;
  }
  if (json_cursor_value_type_c(at) != 3) return -1;
  return json_cursor_enter_object_c(scan);
}

/** 点分路径逐步导航（支持 object 键与 array 下标，如 items.0 / users.0.name）。 */
static int32_t json_object_decode_dotted_at(json_cursor_t *cur, const uint8_t *path, int32_t path_len,
                                            json_cursor_t *out_at) {
  json_cursor_t scan;
  int32_t i = 0;
  if (!cur || !path || !out_at || path_len <= 0) return -1;
  scan = *cur;
  if (json_cursor_enter_object_c(&scan) != 0) return -1;
  while (i < path_len) {
    json_cursor_t at;
    int32_t j = i;
    int32_t rc;
    while (j < path_len && path[j] != (uint8_t)'.') j++;
    if (j <= i) return -1;
    rc = json_cursor_follow_path_seg(&scan, path + i, j - i, &at);
    if (rc != 0) return rc;
    if (j >= path_len) {
      *out_at = at;
      return 0;
    }
    rc = json_cursor_descend_for_next(&at, path, j + 1, path_len, &scan);
    if (rc != 0) return rc;
    i = j + 1;
  }
  return -1;
}

/** 按点分路径（如 user.age / items.0）在 object 根解码 i32；缺键 JSON_DECODE_MISSING。 */
int32_t json_object_decode_dotted_i32_c(json_cursor_t *cur, const uint8_t *path, int32_t path_len,
                                        int32_t *out) {
  json_cursor_t at;
  int32_t consumed = 0;
  int32_t rc;
  if (!cur || !path || !out || path_len <= 0) return -1;
  rc = json_object_decode_dotted_at(cur, path, path_len, &at);
  if (rc != 0) return rc;
  return json_decode_i32_at_c(at.ptr + at.off, at.len - at.off, &consumed, out);
}

/** 按点分路径在 object 根解码 string。 */
int32_t json_object_decode_dotted_string_c(json_cursor_t *cur, const uint8_t *path, int32_t path_len,
                                           uint8_t *out, int32_t out_cap, int32_t *out_len) {
  json_cursor_t at;
  int32_t consumed = 0;
  int32_t rc;
  if (!cur || !path || !out || !out_len || path_len <= 0) return -1;
  rc = json_object_decode_dotted_at(cur, path, path_len, &at);
  if (rc != 0) return rc;
  return json_decode_string_at_c(at.ptr + at.off, at.len - at.off, out, out_cap, out_len, &consumed);
}

/** 按点分路径（如 ok / flags.0）在 object 根解码 bool；缺键 JSON_DECODE_MISSING。 */
int32_t json_object_decode_dotted_bool_c(json_cursor_t *cur, const uint8_t *path, int32_t path_len,
                                         int32_t *out) {
  json_cursor_t at;
  int32_t consumed = 0;
  int32_t rc;
  if (!cur || !path || !out || path_len <= 0) return -1;
  rc = json_object_decode_dotted_at(cur, path, path_len, &at);
  if (rc != 0) return rc;
  return json_decode_bool_at_c(at.ptr + at.off, at.len - at.off, &consumed, out);
}

/** 按点分路径（如 metrics.cpu / values.0）在 object 根解码 f64。 */
int32_t json_object_decode_dotted_f64_c(json_cursor_t *cur, const uint8_t *path, int32_t path_len,
                                        double *out) {
  json_cursor_t at;
  int32_t consumed = 0;
  int32_t rc;
  if (!cur || !path || !out || path_len <= 0) return -1;
  rc = json_object_decode_dotted_at(cur, path, path_len, &at);
  if (rc != 0) return rc;
  return json_decode_f64_at_c(at.ptr + at.off, at.len - at.off, &consumed, out);
}

/** 类型化 decode C 烟测：{"age":30,"ok":true,"name":"alice"}。 */
int32_t json_typed_decode_smoke_c(void) {
  static const uint8_t doc[] =
      "{\"age\":30,\"ok\":true,\"name\":\"alice\"}";
  json_cursor_t cur;
  int32_t age = 0;
  int32_t ok = 0;
  int32_t name_len = 0;
  uint8_t name[16];
  json_cursor_init_c(&cur, doc, (int32_t)(sizeof doc - 1));
  if (json_object_decode_i32_c(&cur, (const uint8_t *)"age", 3, &age) != 0 || age != 30) return -1;
  json_cursor_init_c(&cur, doc, (int32_t)(sizeof doc - 1));
  if (json_object_decode_bool_c(&cur, (const uint8_t *)"ok", 2, &ok) != 0 || ok != 1) return -1;
  json_cursor_init_c(&cur, doc, (int32_t)(sizeof doc - 1));
  if (json_object_decode_string_c(&cur, (const uint8_t *)"name", 4, name, 16, &name_len) != 0 ||
      name_len != 5)
    return -1;
  json_cursor_init_c(&cur, doc, (int32_t)(sizeof doc - 1));
  if (json_object_decode_i32_c(&cur, (const uint8_t *)"xxx", 3, &age) != JSON_DECODE_MISSING)
    return -1;
  {
    static const uint8_t nested[] = "{\"user\":{\"name\":\"carol\",\"age\":42}}";
    json_cursor_init_c(&cur, nested, (int32_t)(sizeof nested - 1));
    if (json_object_decode_dotted_i32_c(&cur, (const uint8_t *)"user.age", 8, &age) != 0 || age != 42)
      return -1;
    json_cursor_init_c(&cur, nested, (int32_t)(sizeof nested - 1));
    if (json_object_decode_dotted_string_c(&cur, (const uint8_t *)"user.name", 9, name, 16, &name_len) !=
            0 ||
        name_len != 5)
      return -1;
  }
  {
    static const uint8_t arr_doc[] = "{\"items\":[10,20,30]}";
    json_cursor_init_c(&cur, arr_doc, (int32_t)(sizeof arr_doc - 1));
    if (json_object_decode_dotted_i32_c(&cur, (const uint8_t *)"items.0", 7, &age) != 0 || age != 10)
      return -1;
    json_cursor_init_c(&cur, arr_doc, (int32_t)(sizeof arr_doc - 1));
    if (json_object_decode_dotted_i32_c(&cur, (const uint8_t *)"items.2", 7, &age) != 0 || age != 30)
      return -1;
  }
  {
    static const uint8_t obj_arr[] = "{\"users\":[{\"name\":\"a\"},{\"name\":\"b\"}]}";
    json_cursor_init_c(&cur, obj_arr, (int32_t)(sizeof obj_arr - 1));
    if (json_object_decode_dotted_string_c(&cur, (const uint8_t *)"users.0.name", 12, name, 16,
                                            &name_len) != 0 ||
        name_len != 1)
      return -1;
    json_cursor_init_c(&cur, obj_arr, (int32_t)(sizeof obj_arr - 1));
    if (json_object_decode_dotted_string_c(&cur, (const uint8_t *)"users.1.name", 12, name, 16,
                                            &name_len) != 0 ||
        name_len != 1)
      return -1;
  }
  {
    static const uint8_t bool_arr[] = "{\"flags\":[true,false,true]}";
    json_cursor_init_c(&cur, bool_arr, (int32_t)(sizeof bool_arr - 1));
    ok = 0;
    if (json_object_decode_dotted_bool_c(&cur, (const uint8_t *)"flags.0", 7, &ok) != 0 || ok != 1)
      return -1;
    json_cursor_init_c(&cur, bool_arr, (int32_t)(sizeof bool_arr - 1));
    if (json_object_decode_dotted_bool_c(&cur, (const uint8_t *)"flags.1", 7, &ok) != 0 || ok != 0)
      return -1;
  }
  {
    static const uint8_t f64_doc[] = "{\"metrics\":{\"cpu\":0.75},\"values\":[1.5,2.5]}";
    double dv = 0.0;
    json_cursor_init_c(&cur, f64_doc, (int32_t)(sizeof f64_doc - 1));
    if (json_object_decode_dotted_f64_c(&cur, (const uint8_t *)"metrics.cpu", 11, &dv) != 0 ||
        dv < 0.74 || dv > 0.76)
      return -1;
    json_cursor_init_c(&cur, f64_doc, (int32_t)(sizeof f64_doc - 1));
    if (json_object_decode_dotted_f64_c(&cur, (const uint8_t *)"values.1", 8, &dv) != 0 ||
        dv < 2.49 || dv > 2.51)
      return -1;
  }
  return 0;
}

/** 在 buf[off] 写入 `{`；返回写入字节数。 */
int32_t json_append_object_c(uint8_t *buf, int32_t cap, int32_t off) {
  if (!buf || off < 0 || off >= cap) return -1;
  buf[off] = '{';
  return 1;
}

/** 在 buf[off] 写入 `}`。 */
int32_t json_append_object_end_c(uint8_t *buf, int32_t cap, int32_t off) {
  if (!buf || off < 0 || off >= cap) return -1;
  buf[off] = '}';
  return 1;
}

/** 在 buf[off] 写入 `[`。 */
int32_t json_append_array_c(uint8_t *buf, int32_t cap, int32_t off) {
  if (!buf || off < 0 || off >= cap) return -1;
  buf[off] = '[';
  return 1;
}

/** 在 buf[off] 写入 `]`。 */
int32_t json_append_array_end_c(uint8_t *buf, int32_t cap, int32_t off) {
  if (!buf || off < 0 || off >= cap) return -1;
  buf[off] = ']';
  return 1;
}

/** 在 buf[off] 写入 `,`。 */
int32_t json_append_comma_c(uint8_t *buf, int32_t cap, int32_t off) {
  if (!buf || off < 0 || off >= cap) return -1;
  buf[off] = ',';
  return 1;
}

/** 在 buf[off] 写入 `"key":`。 */
int32_t json_append_key_c(uint8_t *buf, int32_t cap, int32_t off, const uint8_t *key,
                          int32_t key_len) {
  int32_t i = off;
  int32_t n;
  if (!buf || !key || key_len < 0 || off < 0) return -1;
  if (i >= cap) return -1;
  buf[i++] = '"';
  n = json_escape_inner_c(key, key_len, buf + i, cap - i);
  if (n < 0) return -1;
  i += n;
  if (i + 1 >= cap) return -1;
  buf[i++] = '"';
  buf[i++] = ':';
  return i - off;
}

/** 在 buf[off] 写入 `"value"`。 */
int32_t json_append_string_value_c(uint8_t *buf, int32_t cap, int32_t off, const uint8_t *val,
                                   int32_t val_len) {
  int32_t i = off;
  int32_t n;
  if (!buf || !val || val_len < 0 || off < 0) return -1;
  if (i >= cap) return -1;
  buf[i++] = '"';
  n = json_escape_inner_c(val, val_len, buf + i, cap - i);
  if (n < 0) return -1;
  i += n;
  if (i >= cap) return -1;
  buf[i++] = '"';
  return i - off;
}

/** 在 buf[off] 写入 number；返回写入字节数。 */
int32_t json_append_number_at_c(uint8_t *buf, int32_t cap, int32_t off, double val) {
  if (!buf || off < 0 || off >= cap) return -1;
  return json_append_number_c(buf + off, cap - off, val);
}
