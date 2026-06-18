/**
 * std/schema/schema.c — 结构化 typed decode/validate（STD-090）
 *
 * 【文件职责】
 * Schema 字段注册；JSON 对象 typed decode；CSV 行 / SQLite 列文本映射；
 * 字段级错误路径；供 mod.su 与 gate 烟测调用。
 *
 * 【所属模块】标准库 std.schema；与 std/schema/mod.su 同属一模块。
 * 【依赖】std/json/json.o（游标解析）；std/csv/csv.o（parse_row）。
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

/** 与 mod.su 错误码一致。 */
enum {
    SCH_OK = 0,
    SCH_ERR_NULL = -1,
    SCH_ERR_NOT_FOUND = -2,
    SCH_ERR_TYPE = -3,
    SCH_ERR_INVALID = -4,
    SCH_ERR_FULL = -5,
};

/** 字段类型常量（与 mod.su 一致）。 */
enum {
    SCH_TYPE_STRING = 0,
    SCH_TYPE_I32 = 1,
    SCH_TYPE_BOOL = 2,
    SCH_TYPE_F64 = 3,
};

#define SCH_MAX_FIELDS 32
#define SCH_NAME_MAX 64
#define SCH_VAL_MAX 256
#define SCH_ERR_MSG_MAX 128

/** JSON 游标布局（与 json.c json_cursor_t 一致）。 */
typedef struct json_cursor {
    const uint8_t *ptr;
    int32_t len;
    int32_t off;
} json_cursor_t;

extern void json_cursor_init_c(json_cursor_t *cur, const uint8_t *ptr, int32_t len);
extern int32_t json_cursor_enter_object_c(json_cursor_t *cur);
extern int32_t json_cursor_object_next_c(json_cursor_t *cur, uint8_t *key_buf, int32_t key_cap,
                                          int32_t *key_len);
extern int32_t json_cursor_skip_value_c(json_cursor_t *cur);
extern int32_t json_parse_string_c(const uint8_t *ptr, int32_t len, uint8_t *out, int32_t out_cap,
                                   int32_t *consumed);
extern int32_t json_parse_number_c(const uint8_t *ptr, int32_t len, double *out_val, int32_t *consumed);
extern int32_t json_parse_bool_c(const uint8_t *ptr, int32_t len, int32_t *out, int32_t *consumed);
extern int32_t json_parse_null_c(const uint8_t *ptr, int32_t len, int32_t *consumed);

extern int32_t parse_row(const uint8_t *ptr, int32_t len, int32_t offset, int32_t *field_starts,
                         int32_t *field_lens, int32_t max_fields, int32_t *out_count);

/** 单字段解码结果。 */
typedef struct sch_val {
    int32_t present;
    int32_t type;
    char str[SCH_VAL_MAX];
    int32_t i32;
    int32_t bool_v;
    double f64;
} sch_val_t;

/** Schema 字段定义。 */
typedef struct sch_field_def {
    char name[SCH_NAME_MAX];
    int32_t type;
    int32_t optional;
    int32_t col_index;
} sch_field_def_t;

/** Schema 存储：定义 + 最近一次 decode 的值 + 错误路径。 */
typedef struct sch_schema {
    sch_field_def_t fields[SCH_MAX_FIELDS];
    sch_val_t values[SCH_MAX_FIELDS];
    int32_t field_count;
    char error_field[SCH_NAME_MAX];
    char error_msg[SCH_ERR_MSG_MAX];
} sch_schema_t;

/** 由 i64 句柄取 Schema 指针；非法返回 NULL。 */
static sch_schema_t *sch_from_handle(int64_t handle) {
    if (handle == 0) return NULL;
    return (sch_schema_t *)(uintptr_t)handle;
}

/** 设置字段级错误信息。 */
static void sch_set_error(sch_schema_t *sch, const char *field, const char *msg) {
    if (!sch) return;
    if (field) {
        strncpy(sch->error_field, field, SCH_NAME_MAX - 1);
        sch->error_field[SCH_NAME_MAX - 1] = '\0';
    } else {
        sch->error_field[0] = '\0';
    }
    if (msg) {
        strncpy(sch->error_msg, msg, SCH_ERR_MSG_MAX - 1);
        sch->error_msg[SCH_ERR_MSG_MAX - 1] = '\0';
    } else {
        sch->error_msg[0] = '\0';
    }
}

/** 清空 decode 结果与错误状态。 */
static void sch_clear_values(sch_schema_t *sch) {
    int32_t i;
    if (!sch) return;
    for (i = 0; i < sch->field_count; i++) {
        sch->values[i].present = 0;
        sch->values[i].type = sch->fields[i].type;
        sch->values[i].str[0] = '\0';
        sch->values[i].i32 = 0;
        sch->values[i].bool_v = 0;
        sch->values[i].f64 = 0.0;
    }
    sch->error_field[0] = '\0';
    sch->error_msg[0] = '\0';
}

/** 按名称查找字段索引；不存在返回 -1。 */
static int32_t sch_find_field(sch_schema_t *sch, const char *name) {
    int32_t i;
    if (!sch || !name) return -1;
    for (i = 0; i < sch->field_count; i++) {
        if (strcmp(sch->fields[i].name, name) == 0) return i;
    }
    return -1;
}

/** 将文本解析为字段类型并写入 values[idx]。 */
static int32_t sch_parse_text(sch_schema_t *sch, int32_t idx, const char *text) {
    sch_field_def_t *fd;
    sch_val_t *v;
    char *end = NULL;
    long li;
    if (!sch || idx < 0 || idx >= sch->field_count || !text) return SCH_ERR_NULL;
    fd = &sch->fields[idx];
    v = &sch->values[idx];
    v->present = 1;
    v->type = fd->type;
    switch (fd->type) {
    case SCH_TYPE_STRING:
        strncpy(v->str, text, SCH_VAL_MAX - 1);
        v->str[SCH_VAL_MAX - 1] = '\0';
        return SCH_OK;
    case SCH_TYPE_I32:
        li = strtol(text, &end, 10);
        if (end == text || (end && *end != '\0')) {
            sch_set_error(sch, fd->name, "expected i32");
            return SCH_ERR_TYPE;
        }
        v->i32 = (int32_t)li;
        return SCH_OK;
    case SCH_TYPE_BOOL:
        if (strcmp(text, "true") == 0 || strcmp(text, "1") == 0 || strcmp(text, "yes") == 0) {
            v->bool_v = 1;
            return SCH_OK;
        }
        if (strcmp(text, "false") == 0 || strcmp(text, "0") == 0 || strcmp(text, "no") == 0) {
            v->bool_v = 0;
            return SCH_OK;
        }
        sch_set_error(sch, fd->name, "expected bool");
        return SCH_ERR_TYPE;
    case SCH_TYPE_F64:
        v->f64 = strtod(text, &end);
        if (end == text || (end && *end != '\0')) {
            sch_set_error(sch, fd->name, "expected f64");
            return SCH_ERR_TYPE;
        }
        return SCH_OK;
    default:
        sch_set_error(sch, fd->name, "unknown type");
        return SCH_ERR_INVALID;
    }
}

/** 校验所有必填字段已 present。 */
static int32_t sch_check_required(sch_schema_t *sch) {
    int32_t i;
    if (!sch) return SCH_ERR_NULL;
    for (i = 0; i < sch->field_count; i++) {
        if (!sch->fields[i].optional && !sch->values[i].present) {
            sch_set_error(sch, sch->fields[i].name, "missing required field");
            return SCH_ERR_NOT_FOUND;
        }
    }
    return SCH_OK;
}

/** 创建空 Schema；失败返回 0。 */
int64_t schema_create_c(void) {
    sch_schema_t *sch = (sch_schema_t *)calloc(1, sizeof(sch_schema_t));
    if (!sch) return 0;
    return (int64_t)(uintptr_t)sch;
}

/** 释放 Schema。 */
void schema_free_c(int64_t handle) {
    sch_schema_t *sch = sch_from_handle(handle);
    if (sch) free(sch);
}

/** 清空字段定义与 decode 结果。 */
void schema_clear_c(int64_t handle) {
    sch_schema_t *sch = sch_from_handle(handle);
    if (!sch) return;
    sch->field_count = 0;
    sch_clear_values(sch);
}

/**
 * 注册字段：name 为 JSON 键名 / 逻辑名；col_index 用于 CSV/SQLite 列映射。
 * optional 非 0 表示可选；返回 SCH_OK 或错误码。
 */
int32_t schema_add_field_c(int64_t handle, const uint8_t *name, int32_t name_len, int32_t type,
                           int32_t optional, int32_t col_index) {
    sch_schema_t *sch = sch_from_handle(handle);
    char key[SCH_NAME_MAX];
    if (!sch || !name || name_len <= 0) return SCH_ERR_NULL;
    if (name_len >= SCH_NAME_MAX) return SCH_ERR_INVALID;
    if (sch->field_count >= SCH_MAX_FIELDS) return SCH_ERR_FULL;
    memcpy(key, name, (size_t)name_len);
    key[name_len] = '\0';
    if (sch_find_field(sch, key) >= 0) return SCH_ERR_INVALID;
    strncpy(sch->fields[sch->field_count].name, key, SCH_NAME_MAX - 1);
    sch->fields[sch->field_count].name[SCH_NAME_MAX - 1] = '\0';
    sch->fields[sch->field_count].type = type;
    sch->fields[sch->field_count].optional = optional ? 1 : 0;
    sch->fields[sch->field_count].col_index = col_index;
    sch->values[sch->field_count].type = type;
    sch->field_count++;
    return SCH_OK;
}

/** 从 JSON 对象缓冲 decode；仅支持 flat object + 标量字段。 */
int32_t schema_decode_json_c(int64_t handle, const uint8_t *json, int32_t json_len) {
    sch_schema_t *sch = sch_from_handle(handle);
    json_cursor_t cur;
    uint8_t key_buf[SCH_NAME_MAX];
    int32_t key_len = 0;
    int32_t rc;
    if (!sch || !json || json_len <= 0) return SCH_ERR_NULL;
    sch_clear_values(sch);
    json_cursor_init_c(&cur, json, json_len);
    if (json_cursor_enter_object_c(&cur) != 0) {
        sch_set_error(sch, NULL, "expected JSON object");
        return SCH_ERR_INVALID;
    }
    for (;;) {
        rc = json_cursor_object_next_c(&cur, key_buf, SCH_NAME_MAX, &key_len);
        if (rc == 0) break;
        if (rc < 0) {
            sch_set_error(sch, NULL, "JSON parse error");
            return SCH_ERR_INVALID;
        }
        key_buf[key_len] = '\0';
        {
            int32_t idx = sch_find_field(sch, (char *)key_buf);
            int32_t consumed = 0;
            const uint8_t *vp = cur.ptr + cur.off;
            int32_t vlen = cur.len - cur.off;
            if (idx < 0) {
                if (json_cursor_skip_value_c(&cur) != 0) return SCH_ERR_INVALID;
                continue;
            }
            switch (sch->fields[idx].type) {
            case SCH_TYPE_STRING: {
                uint8_t out[SCH_VAL_MAX];
                int32_t sl = json_parse_string_c(vp, vlen, out, SCH_VAL_MAX, &consumed);
                if (sl < 0) {
                    sch_set_error(sch, sch->fields[idx].name, "expected string");
                    return SCH_ERR_TYPE;
                }
                out[sl] = '\0';
                sch->values[idx].present = 1;
                strncpy(sch->values[idx].str, (char *)out, SCH_VAL_MAX - 1);
                sch->values[idx].str[SCH_VAL_MAX - 1] = '\0';
                break;
            }
            case SCH_TYPE_I32: {
                double dv = 0.0;
                if (json_parse_number_c(vp, vlen, &dv, &consumed) != 0) {
                    sch_set_error(sch, sch->fields[idx].name, "expected number");
                    return SCH_ERR_TYPE;
                }
                sch->values[idx].present = 1;
                sch->values[idx].i32 = (int32_t)dv;
                break;
            }
            case SCH_TYPE_F64: {
                if (json_parse_number_c(vp, vlen, &sch->values[idx].f64, &consumed) != 0) {
                    sch_set_error(sch, sch->fields[idx].name, "expected number");
                    return SCH_ERR_TYPE;
                }
                sch->values[idx].present = 1;
                break;
            }
            case SCH_TYPE_BOOL: {
                if (json_parse_bool_c(vp, vlen, &sch->values[idx].bool_v, &consumed) != 1) {
                    sch_set_error(sch, sch->fields[idx].name, "expected bool");
                    return SCH_ERR_TYPE;
                }
                sch->values[idx].present = 1;
                break;
            }
            default:
                return SCH_ERR_INVALID;
            }
            if (json_cursor_skip_value_c(&cur) != 0) {
                sch_set_error(sch, sch->fields[idx].name, "JSON value skip failed");
                return SCH_ERR_INVALID;
            }
        }
    }
    return sch_check_required(sch);
}

/** 从 CSV 行 decode；按 field.col_index 映射列。 */
int32_t schema_decode_csv_row_c(int64_t handle, const uint8_t *row, int32_t row_len, int32_t offset) {
    sch_schema_t *sch = sch_from_handle(handle);
    int32_t starts[SCH_MAX_FIELDS];
    int32_t lens[SCH_MAX_FIELDS];
    int32_t count = 0;
    int32_t i;
    char cell[SCH_VAL_MAX];
    if (!sch || !row) return SCH_ERR_NULL;
    sch_clear_values(sch);
    parse_row(row, row_len, offset, starts, lens, SCH_MAX_FIELDS, &count);
    if (count <= 0) {
        sch_set_error(sch, NULL, "CSV parse error");
        return SCH_ERR_INVALID;
    }
    for (i = 0; i < sch->field_count; i++) {
        int32_t ci = sch->fields[i].col_index;
        int32_t cl;
        if (ci < 0 || ci >= count) {
            if (!sch->fields[i].optional) {
                sch_set_error(sch, sch->fields[i].name, "missing CSV column");
                return SCH_ERR_NOT_FOUND;
            }
            continue;
        }
        cl = lens[ci];
        if (cl >= SCH_VAL_MAX) cl = SCH_VAL_MAX - 1;
        memcpy(cell, row + starts[ci], (size_t)cl);
        cell[cl] = '\0';
        if (sch_parse_text(sch, i, cell) != SCH_OK) return SCH_ERR_TYPE;
    }
    return sch_check_required(sch);
}

/**
 * 从列文本数组映射（CSV 解析后或 SQLite row_col_text 结果）。
 * col_starts/col_lens 为每列在 row 缓冲内的偏移与长度；count 为列数。
 */
int32_t schema_map_columns_c(int64_t handle, const uint8_t *row, const int32_t *col_starts,
                             const int32_t *col_lens, int32_t count) {
    sch_schema_t *sch = sch_from_handle(handle);
    int32_t i;
    char cell[SCH_VAL_MAX];
    int32_t cl;
    if (!sch || !row || !col_starts || !col_lens) return SCH_ERR_NULL;
    sch_clear_values(sch);
    for (i = 0; i < sch->field_count; i++) {
        int32_t ci = sch->fields[i].col_index;
        if (ci < 0 || ci >= count) {
            if (!sch->fields[i].optional) {
                sch_set_error(sch, sch->fields[i].name, "missing column");
                return SCH_ERR_NOT_FOUND;
            }
            continue;
        }
        cl = col_lens[ci];
        if (cl < 0) cl = 0;
        if (cl >= SCH_VAL_MAX) cl = SCH_VAL_MAX - 1;
        memcpy(cell, row + col_starts[ci], (size_t)cl);
        cell[cl] = '\0';
        if (sch_parse_text(sch, i, cell) != SCH_OK) return SCH_ERR_TYPE;
    }
    return sch_check_required(sch);
}

/** 读取 string 字段；返回长度，未找到或类型错误返回负数。 */
int32_t schema_get_string_c(int64_t handle, const uint8_t *name, int32_t name_len, uint8_t *out,
                            int32_t out_cap) {
    sch_schema_t *sch = sch_from_handle(handle);
    char key[SCH_NAME_MAX];
    int32_t idx;
    int32_t n;
    if (!sch || !name || !out || out_cap <= 0) return SCH_ERR_NULL;
    if (name_len >= SCH_NAME_MAX) return SCH_ERR_INVALID;
    memcpy(key, name, (size_t)name_len);
    key[name_len] = '\0';
    idx = sch_find_field(sch, key);
    if (idx < 0) return SCH_ERR_NOT_FOUND;
    if (!sch->values[idx].present || sch->fields[idx].type != SCH_TYPE_STRING) return SCH_ERR_TYPE;
    n = (int32_t)strlen(sch->values[idx].str);
    if (n >= out_cap) n = out_cap - 1;
    memcpy(out, sch->values[idx].str, (size_t)n);
    out[n] = '\0';
    return n;
}

/** 读取 i32 字段。 */
int32_t schema_get_i32_c(int64_t handle, const uint8_t *name, int32_t name_len, int32_t *out) {
    sch_schema_t *sch = sch_from_handle(handle);
    char key[SCH_NAME_MAX];
    int32_t idx;
    if (!sch || !name || !out) return SCH_ERR_NULL;
    if (name_len >= SCH_NAME_MAX) return SCH_ERR_INVALID;
    memcpy(key, name, (size_t)name_len);
    key[name_len] = '\0';
    idx = sch_find_field(sch, key);
    if (idx < 0) return SCH_ERR_NOT_FOUND;
    if (!sch->values[idx].present || sch->fields[idx].type != SCH_TYPE_I32) return SCH_ERR_TYPE;
    *out = sch->values[idx].i32;
    return SCH_OK;
}

/** 读取 bool 字段。 */
int32_t schema_get_bool_c(int64_t handle, const uint8_t *name, int32_t name_len, int32_t *out) {
    sch_schema_t *sch = sch_from_handle(handle);
    char key[SCH_NAME_MAX];
    int32_t idx;
    if (!sch || !name || !out) return SCH_ERR_NULL;
    if (name_len >= SCH_NAME_MAX) return SCH_ERR_INVALID;
    memcpy(key, name, (size_t)name_len);
    key[name_len] = '\0';
    idx = sch_find_field(sch, key);
    if (idx < 0) return SCH_ERR_NOT_FOUND;
    if (!sch->values[idx].present || sch->fields[idx].type != SCH_TYPE_BOOL) return SCH_ERR_TYPE;
    *out = sch->values[idx].bool_v;
    return SCH_OK;
}

/** 读取 f64 字段。 */
int32_t schema_get_f64_c(int64_t handle, const uint8_t *name, int32_t name_len, double *out) {
    sch_schema_t *sch = sch_from_handle(handle);
    char key[SCH_NAME_MAX];
    int32_t idx;
    if (!sch || !name || !out) return SCH_ERR_NULL;
    if (name_len >= SCH_NAME_MAX) return SCH_ERR_INVALID;
    memcpy(key, name, (size_t)name_len);
    key[name_len] = '\0';
    idx = sch_find_field(sch, key);
    if (idx < 0) return SCH_ERR_NOT_FOUND;
    if (!sch->values[idx].present || sch->fields[idx].type != SCH_TYPE_F64) return SCH_ERR_TYPE;
    *out = sch->values[idx].f64;
    return SCH_OK;
}

/** 复制最近错误字段名；无错误返回 0 长度。 */
int32_t schema_last_error_field_c(int64_t handle, uint8_t *out, int32_t out_cap) {
    sch_schema_t *sch = sch_from_handle(handle);
    int32_t n;
    if (!sch || !out || out_cap <= 0) return SCH_ERR_NULL;
    n = (int32_t)strlen(sch->error_field);
    if (n >= out_cap) n = out_cap - 1;
    memcpy(out, sch->error_field, (size_t)n);
    out[n] = '\0';
    return n;
}

/** 复制最近错误消息。 */
int32_t schema_last_error_message_c(int64_t handle, uint8_t *out, int32_t out_cap) {
    sch_schema_t *sch = sch_from_handle(handle);
    int32_t n;
    if (!sch || !out || out_cap <= 0) return SCH_ERR_NULL;
    n = (int32_t)strlen(sch->error_msg);
    if (n >= out_cap) n = out_cap - 1;
    memcpy(out, sch->error_msg, (size_t)n);
    out[n] = '\0';
    return n;
}

/** C 烟测：JSON + CSV + 列映射 + 错误路径。 */
int32_t schema_smoke_c(void) {
    int64_t sch = schema_create_c();
    int32_t age = 0;
    int32_t active = 0;
    uint8_t name[64];
    static const uint8_t json[] = "{\"name\":\"alice\",\"age\":30,\"active\":true}";
    static const uint8_t csv[] = "bob,25,false\n";
    int32_t starts[4];
    int32_t lens[4];
    int32_t count = 0;
    if (sch == 0) return 1;
    if (schema_add_field_c(sch, (const uint8_t *)"name", 4, SCH_TYPE_STRING, 0, 0) != SCH_OK) return 2;
    if (schema_add_field_c(sch, (const uint8_t *)"age", 3, SCH_TYPE_I32, 0, 1) != SCH_OK) return 3;
    if (schema_add_field_c(sch, (const uint8_t *)"active", 6, SCH_TYPE_BOOL, 0, 2) != SCH_OK) return 4;
    if (schema_decode_json_c(sch, json, (int32_t)(sizeof(json) - 1)) != SCH_OK) return 5;
    if (schema_get_string_c(sch, (const uint8_t *)"name", 4, name, 64) <= 0) return 6;
    if (strcmp((char *)name, "alice") != 0) return 7;
    if (schema_get_i32_c(sch, (const uint8_t *)"age", 3, &age) != SCH_OK || age != 30) return 8;
    if (schema_get_bool_c(sch, (const uint8_t *)"active", 6, &active) != SCH_OK || active != 1) return 9;
    if (schema_decode_csv_row_c(sch, csv, (int32_t)(sizeof(csv) - 1), 0) != SCH_OK) return 10;
    if (schema_get_string_c(sch, (const uint8_t *)"name", 4, name, 64) <= 0) return 11;
    if (strcmp((char *)name, "bob") != 0) return 12;
    if (schema_get_i32_c(sch, (const uint8_t *)"age", 3, &age) != SCH_OK || age != 25) return 13;
    if (schema_get_bool_c(sch, (const uint8_t *)"active", 6, &active) != SCH_OK || active != 0) return 14;
    if (parse_row(csv, (int32_t)(sizeof(csv) - 1), 0, starts, lens, 4, &count) < 0) return 15;
    if (count != 3) return 15;
    if (schema_map_columns_c(sch, csv, starts, lens, count) != SCH_OK) return 16;
    if (schema_decode_json_c(sch, (const uint8_t *)"{\"name\":\"x\"}", 14) != SCH_ERR_NOT_FOUND) return 17;
    if (schema_last_error_field_c(sch, name, 64) <= 0) return 18;
    schema_free_c(sch);
    return 0;
}
