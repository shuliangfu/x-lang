/**
 * json_import_alias.c — import binding `-o` 链接桩
 *
 * asm co-emit 对 `const json = import("std.json")` 生成 std_json_* 符号；
 * json.o 仅导出 json_*_c（json.x）。本 TU 提供 std_json_* 转发（语义对齐 mod.x）。
 */
#include <stdint.h>

/** 与 mod.x JsonCursor 布局一致。 */
typedef struct ShuxJsonCursor {
  uint8_t *ptr;
  int32_t len;
  int32_t off;
} ShuxJsonCursor;

extern int32_t json_parse_number_c(uint8_t *ptr, int32_t len, double *out_val, int32_t *consumed);
extern int32_t json_parse_null_c(uint8_t *ptr, int32_t len, int32_t *consumed);
extern int32_t json_parse_bool_c(uint8_t *ptr, int32_t len, int32_t *out, int32_t *consumed);
extern int32_t json_parse_string_c(uint8_t *ptr, int32_t len, uint8_t *out, int32_t out_cap,
                                   int32_t *consumed);
extern int32_t json_escape_c(uint8_t *ptr, int32_t len, uint8_t *buf, int32_t buf_cap);
extern int32_t json_append_null_c(uint8_t *buf, int32_t buf_cap);
extern int32_t json_append_bool_c(uint8_t *buf, int32_t buf_cap, int32_t val);
extern int32_t json_append_number_c(uint8_t *buf, int32_t buf_cap, double val);
extern int32_t json_skip_value_c(uint8_t *ptr, int32_t len, int32_t *consumed);
extern uint8_t *json_parse_string_view_c(uint8_t *ptr, int32_t len, int32_t *out_len, int32_t *consumed);
extern void json_cursor_init_c(ShuxJsonCursor *cur, uint8_t *ptr, int32_t len);
extern int32_t json_cursor_enter_object_c(ShuxJsonCursor *cur);
extern int32_t json_cursor_object_next_c(ShuxJsonCursor *cur, uint8_t *key_buf, int32_t key_cap,
                                         int32_t *key_len);
extern int32_t json_cursor_skip_value_c(ShuxJsonCursor *cur);
extern int32_t json_cursor_enter_array_c(ShuxJsonCursor *cur);
extern int32_t json_cursor_array_has_elem_c(ShuxJsonCursor *cur);
extern int32_t json_cursor_value_type_c(ShuxJsonCursor *cur);
extern int32_t json_decode_i32_at_c(uint8_t *ptr, int32_t len, int32_t *consumed, int32_t *out);
extern int32_t json_decode_f64_at_c(uint8_t *ptr, int32_t len, int32_t *consumed, double *out);
extern int32_t json_decode_bool_at_c(uint8_t *ptr, int32_t len, int32_t *consumed, int32_t *out);
extern int32_t json_decode_string_at_c(uint8_t *ptr, int32_t len, uint8_t *out, int32_t out_cap,
                                       int32_t *out_len, int32_t *consumed);
extern int32_t json_typed_decode_smoke_c(void);

/** parse_number；转发 json_parse_number_c。 */
int32_t std_json_parse_number(uint8_t *ptr, int32_t len, double *out_val, int32_t *consumed) {
  return json_parse_number_c(ptr, len, out_val, consumed);
}

/** parse_null；转发 json_parse_null_c。 */
int32_t std_json_parse_null(uint8_t *ptr, int32_t len, int32_t *consumed) {
  return json_parse_null_c(ptr, len, consumed);
}

/** parse_bool；转发 json_parse_bool_c。 */
int32_t std_json_parse_bool(uint8_t *ptr, int32_t len, int32_t *out, int32_t *consumed) {
  return json_parse_bool_c(ptr, len, out, consumed);
}

/** parse_string；转发 json_parse_string_c。 */
int32_t std_json_parse_string(uint8_t *ptr, int32_t len, uint8_t *out, int32_t out_cap, int32_t *consumed) {
  return json_parse_string_c(ptr, len, out, out_cap, consumed);
}

/** escape_string；转发 json_escape_c。 */
int32_t std_json_escape_string(uint8_t *ptr, int32_t len, uint8_t *buf, int32_t buf_cap) {
  return json_escape_c(ptr, len, buf, buf_cap);
}

/** append_null；转发 json_append_null_c。 */
int32_t std_json_append_null(uint8_t *buf, int32_t buf_cap) {
  return json_append_null_c(buf, buf_cap);
}

/** append_bool；转发 json_append_bool_c。 */
int32_t std_json_append_bool(uint8_t *buf, int32_t buf_cap, int32_t val) {
  return json_append_bool_c(buf, buf_cap, val);
}

/** append_number；转发 json_append_number_c。 */
int32_t std_json_append_number(uint8_t *buf, int32_t buf_cap, double val) {
  return json_append_number_c(buf, buf_cap, val);
}

/** skip_value；转发 json_skip_value_c。 */
int32_t std_json_skip_value(uint8_t *ptr, int32_t len, int32_t *consumed) {
  return json_skip_value_c(ptr, len, consumed);
}

/** parse_string_view；转发 json_parse_string_view_c。 */
uint8_t *std_json_parse_string_view(uint8_t *ptr, int32_t len, int32_t *out_len, int32_t *consumed) {
  return json_parse_string_view_c(ptr, len, out_len, consumed);
}

/** cursor_init；转发 json_cursor_init_c。 */
void std_json_cursor_init(ShuxJsonCursor *cur, uint8_t *ptr, int32_t len) {
  json_cursor_init_c(cur, ptr, len);
}

/** cursor_enter_object；转发 json_cursor_enter_object_c。 */
int32_t std_json_cursor_enter_object(ShuxJsonCursor *cur) { return json_cursor_enter_object_c(cur); }

/** cursor_object_next；转发 json_cursor_object_next_c。 */
int32_t std_json_cursor_object_next(ShuxJsonCursor *cur, uint8_t *key_buf, int32_t key_cap,
                                    int32_t *key_len) {
  return json_cursor_object_next_c(cur, key_buf, key_cap, key_len);
}

/** cursor_skip_value；转发 json_cursor_skip_value_c。 */
int32_t std_json_cursor_skip_value(ShuxJsonCursor *cur) { return json_cursor_skip_value_c(cur); }

/** cursor_enter_array；转发 json_cursor_enter_array_c。 */
int32_t std_json_cursor_enter_array(ShuxJsonCursor *cur) { return json_cursor_enter_array_c(cur); }

/** cursor_array_has_elem；转发 json_cursor_array_has_elem_c。 */
int32_t std_json_cursor_array_has_elem(ShuxJsonCursor *cur) {
  return json_cursor_array_has_elem_c(cur);
}

/** cursor_value_type；转发 json_cursor_value_type_c。 */
int32_t std_json_cursor_value_type(ShuxJsonCursor *cur) { return json_cursor_value_type_c(cur); }

/** decode_i32_at；转发 json_decode_i32_at_c。 */
int32_t std_json_decode_i32_at(uint8_t *ptr, int32_t len, int32_t *consumed, int32_t *out) {
  return json_decode_i32_at_c(ptr, len, consumed, out);
}

/** decode_f64_at；转发 json_decode_f64_at_c。 */
int32_t std_json_decode_f64_at(uint8_t *ptr, int32_t len, int32_t *consumed, double *out) {
  return json_decode_f64_at_c(ptr, len, consumed, out);
}

/** decode_bool_at；转发 json_decode_bool_at_c。 */
int32_t std_json_decode_bool_at(uint8_t *ptr, int32_t len, int32_t *consumed, int32_t *out) {
  return json_decode_bool_at_c(ptr, len, consumed, out);
}

/** decode_string_at；转发 json_decode_string_at_c。 */
int32_t std_json_decode_string_at(uint8_t *ptr, int32_t len, uint8_t *out, int32_t out_cap,
                                  int32_t *out_len, int32_t *consumed) {
  return json_decode_string_at_c(ptr, len, out, out_cap, out_len, consumed);
}

/** typed_decode_smoke；转发 json_typed_decode_smoke_c。 */
int32_t std_json_typed_decode_smoke(void) { return json_typed_decode_smoke_c(); }

/** json_view_needs_copy 常量门面。 */
int32_t std_json_json_view_needs_copy(void) { return -2; }

/** json_decode_missing 常量门面。 */
int32_t std_json_json_decode_missing(void) { return -3; }
