/**
 * std/config/config.c — 分层配置加载（STD-086）
 *
 * 【文件职责】
 * 扁平 + [section] / [[array]] 前缀 TOML 子集解析；YAML 嵌套 section + `-` 标量序列；
 * 类型化 get_string / get_i32 / get_bool；供 mod.sx 与 gate 烟测调用。
 *
 * 【所属模块】标准库 std.config；与 std/config/mod.sx 同属一模块。
 * 【依赖】std/env/env.c（env_iter_*）；可选 std/fs 读文件（本文件自含 fread）。
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

/** 与 mod.sx 错误码一致。 */
enum {
    CFG_OK = 0,
    CFG_ERR_NULL = -1,
    CFG_ERR_NOT_FOUND = -2,
    CFG_ERR_INVALID = -3,
    CFG_ERR_IO = -4,
    CFG_ERR_FULL = -5,
};

#define CFG_MAX_ENTRIES 64
#define CFG_KEY_MAX 128
#define CFG_VAL_MAX 256
#define CFG_FILE_MAX (64 * 1024)
#define CFG_SRC_LABEL_MAX 64

/** 值来源层（与 mod.sx config_source_* 一致）。 */
enum {
    CFG_SRC_UNKNOWN = 0,
    CFG_SRC_TOML = 1,
    CFG_SRC_YAML = 2,
    CFG_SRC_ENV = 3,
    CFG_SRC_SET = 4,
};

typedef struct cfg_entry {
    char key[CFG_KEY_MAX];
    char val[CFG_VAL_MAX];
    int32_t source_kind;
    char source_label[CFG_SRC_LABEL_MAX];
} cfg_entry_t;

typedef struct cfg_store {
    cfg_entry_t entries[CFG_MAX_ENTRIES];
    int32_t count;
    /** 当前 load/set 操作的来源层（供 cfg_set_raw 默认写入）。 */
    int32_t active_source_kind;
    char active_source_label[CFG_SRC_LABEL_MAX];
} cfg_store_t;

extern int32_t env_iter_count_c(void);
extern int32_t env_iter_at_c(int32_t index, uint8_t *key_out, int32_t key_cap,
                             uint8_t *val_out, int32_t val_cap);

static cfg_store_t *cfg_from_handle(int64_t handle) {
    if (handle == 0) return NULL;
    return (cfg_store_t *)(uintptr_t)handle;
}

/** 去除首尾空白；返回新起始指针并写入 out_len。 */
static const char *cfg_trim(const char *s, int32_t *out_len) {
    int32_t start = 0;
    int32_t end;
    if (!s) {
        if (out_len) *out_len = 0;
        return s;
    }
    while (s[start] && isspace((unsigned char)s[start])) start++;
    end = (int32_t)strlen(s + start);
    while (end > 0 && isspace((unsigned char)s[start + end - 1])) end--;
    if (out_len) *out_len = end;
    return s + start;
}

/** 查找键索引；不存在返回 -1。 */
static int32_t cfg_find_index(cfg_store_t *store, const char *key) {
    int32_t i;
    if (!store || !key) return -1;
    for (i = 0; i < store->count; i++) {
        if (strcmp(store->entries[i].key, key) == 0) return i;
    }
    return -1;
}

/** 设置键值及来源 meta；override 非 0 时覆盖已有项。 */
static int32_t cfg_set_raw_ex(cfg_store_t *store, const char *key, const char *val, int32_t override,
                              int32_t src_kind, const char *src_label) {
    int32_t idx;
    if (!store || !key || !val) return CFG_ERR_NULL;
    if (key[0] == '\0') return CFG_ERR_INVALID;
    idx = cfg_find_index(store, key);
    if (idx >= 0) {
        if (!override) return CFG_OK;
        strncpy(store->entries[idx].val, val, CFG_VAL_MAX - 1);
        store->entries[idx].val[CFG_VAL_MAX - 1] = '\0';
        store->entries[idx].source_kind = src_kind;
        if (src_label) {
            strncpy(store->entries[idx].source_label, src_label, CFG_SRC_LABEL_MAX - 1);
            store->entries[idx].source_label[CFG_SRC_LABEL_MAX - 1] = '\0';
        } else {
            store->entries[idx].source_label[0] = '\0';
        }
        return CFG_OK;
    }
    if (store->count >= CFG_MAX_ENTRIES) return CFG_ERR_FULL;
    strncpy(store->entries[store->count].key, key, CFG_KEY_MAX - 1);
    store->entries[store->count].key[CFG_KEY_MAX - 1] = '\0';
    strncpy(store->entries[store->count].val, val, CFG_VAL_MAX - 1);
    store->entries[store->count].val[CFG_VAL_MAX - 1] = '\0';
    store->entries[store->count].source_kind = src_kind;
    if (src_label) {
        strncpy(store->entries[store->count].source_label, src_label, CFG_SRC_LABEL_MAX - 1);
        store->entries[store->count].source_label[CFG_SRC_LABEL_MAX - 1] = '\0';
    } else {
        store->entries[store->count].source_label[0] = '\0';
    }
    store->count++;
    return CFG_OK;
}

/** 设置键值；来源取自 store->active_source_*。 */
static int32_t cfg_set_raw(cfg_store_t *store, const char *key, const char *val, int32_t override) {
    if (!store) return CFG_ERR_NULL;
    return cfg_set_raw_ex(store, key, val, override, store->active_source_kind,
                          store->active_source_label);
}

/** 解析 TOML 双引号字符串到 out；返回 0 成功。 */
static int32_t cfg_parse_quoted(const char *src, int32_t len, char *out, int32_t out_cap) {
    int32_t i = 1;
    int32_t o = 0;
    if (len < 2 || src[0] != '"' || src[len - 1] != '"') return CFG_ERR_INVALID;
    while (i < len - 1) {
        char c = src[i];
        if (c == '\\' && i + 1 < len - 1) {
            char e = src[i + 1];
            if (o + 1 >= out_cap) return CFG_ERR_INVALID;
            if (e == 'n') out[o++] = '\n';
            else if (e == 't') out[o++] = '\t';
            else if (e == 'r') out[o++] = '\r';
            else out[o++] = e;
            i += 2;
            continue;
        }
        if (o + 1 >= out_cap) return CFG_ERR_INVALID;
        out[o++] = c;
        i++;
    }
    out[o] = '\0';
    return CFG_OK;
}

/** 将 TOML 标量值规范化为存储字符串。 */
static int32_t cfg_normalize_value(const char *raw, int32_t raw_len, char *out, int32_t out_cap) {
    int32_t tl = 0;
    const char *t = cfg_trim(raw, &tl);
    if (tl <= 0) return CFG_ERR_INVALID;
    if (t[0] == '"') return cfg_parse_quoted(t, tl, out, out_cap);
    if (tl >= 4 && strncmp(t, "true", 4) == 0 && tl == 4) {
        strncpy(out, "true", out_cap - 1);
        out[out_cap - 1] = '\0';
        return CFG_OK;
    }
    if (tl >= 5 && strncmp(t, "false", 5) == 0 && tl == 5) {
        strncpy(out, "false", out_cap - 1);
        out[out_cap - 1] = '\0';
        return CFG_OK;
    }
    if (tl >= out_cap) return CFG_ERR_INVALID;
    memcpy(out, t, (size_t)tl);
    out[tl] = '\0';
    return CFG_OK;
}

/** 解析单行 key = value；section_prefix 可为空或 "sect"。 */
static int32_t cfg_parse_kv_line(cfg_store_t *store, const char *line, const char *section_prefix,
                                 int32_t override) {
    char key_full[CFG_KEY_MAX];
    char val_buf[CFG_VAL_MAX];
    const char *eq;
    const char *key_start;
    int32_t key_len = 0;
    int32_t val_len = 0;
    const char *val_part;
    if (!store || !line) return CFG_ERR_NULL;
    eq = strchr(line, '=');
    if (!eq) return CFG_OK;
    key_start = line;
    while (*key_start && isspace((unsigned char)*key_start)) key_start++;
    key_len = (int32_t)(eq - key_start);
    while (key_len > 0 && isspace((unsigned char)key_start[key_len - 1])) key_len--;
    val_part = cfg_trim(eq + 1, &val_len);
    if (key_len <= 0 || val_len <= 0) return CFG_ERR_INVALID;
    if (section_prefix && section_prefix[0]) {
        snprintf(key_full, sizeof(key_full), "%s.%.*s", section_prefix, key_len, key_start);
    } else {
        if (key_len >= CFG_KEY_MAX) return CFG_ERR_INVALID;
        memcpy(key_full, key_start, (size_t)key_len);
        key_full[key_len] = '\0';
    }
    if (cfg_normalize_value(val_part, val_len, val_buf, CFG_VAL_MAX) != CFG_OK) return CFG_ERR_INVALID;
    return cfg_set_raw(store, key_full, val_buf, override);
}

/** 解析 [section] 头；写入 out 并返回 1，否则 0。[[array]] 由 cfg_parse_array_section 处理。 */
static int32_t cfg_parse_section(const char *line, char *out, int32_t out_cap) {
    int32_t len = 0;
    const char *t;
    int32_t i = 0;
    t = cfg_trim(line, &len);
    if (len < 3 || t[0] != '[' || t[len - 1] != ']') return 0;
    /* 双括号 array-of-tables 头，非普通 section。 */
    if (len >= 4 && t[1] == '[') return 0;
    len -= 2;
    if (len <= 0 || len >= out_cap) return CFG_ERR_INVALID;
    while (i < len) {
        char c = t[i + 1];
        if (!isalnum((unsigned char)c) && c != '_' && c != '.') return CFG_ERR_INVALID;
        out[i] = c;
        i++;
    }
    out[i] = '\0';
    return 1;
}

/**
 * 解析 [[array]] 头（TOML array-of-tables）；写入数组名 out 并返回 2。
 * 非法 `[[` 行返回 -1；非 array 头返回 0。
 */
static int32_t cfg_parse_array_section(const char *line, char *out, int32_t out_cap) {
    int32_t len = 0;
    const char *t;
    int32_t i = 0;
    int32_t inner_len;
    t = cfg_trim(line, &len);
    if (len < 4 || t[0] != '[' || t[1] != '[' || t[len - 2] != ']' || t[len - 1] != ']') return 0;
    inner_len = len - 4;
    if (inner_len <= 0 || inner_len >= out_cap) return CFG_ERR_INVALID;
    while (i < inner_len) {
        char c = t[i + 2];
        if (!isalnum((unsigned char)c) && c != '_' && c != '.') return CFG_ERR_INVALID;
        out[i] = c;
        i++;
    }
    out[i] = '\0';
    return 2;
}

/** 从内存缓冲加载 TOML 子集；override 非 0 时覆盖已有键（调用前须设置 active_source_*）。 */
static int32_t cfg_load_toml_buf_impl(cfg_store_t *store, const uint8_t *buf, int32_t len, int32_t override) {
    char section[CFG_KEY_MAX];
    char array_name[CFG_KEY_MAX];
    int32_t array_index = -1;
    char line[512];
    int32_t i = 0;
    int32_t line_pos = 0;
    if (!store || !buf || len < 0) return CFG_ERR_NULL;
    section[0] = '\0';
    array_name[0] = '\0';
    while (i <= len) {
        char c = (i < len) ? (char)buf[i] : '\n';
        if (c == '\r') {
            i++;
            continue;
        }
        if (c == '\n' || c == '\0') {
            line[line_pos] = '\0';
            if (line_pos > 0) {
                int32_t sl = 0;
                const char *t = cfg_trim(line, &sl);
                if (sl > 0 && t[0] != '#') {
                    char parsed_array[CFG_KEY_MAX];
                    int32_t arr = cfg_parse_array_section(t, parsed_array, CFG_KEY_MAX);
                    if (arr < 0) return CFG_ERR_INVALID;
                    if (arr == 2) {
                        /* 连续 [[name]] 递增下标；换名则从 0 开始。 */
                        if (array_index >= 0 && strcmp(array_name, parsed_array) == 0) {
                            array_index++;
                        } else {
                            array_index = 0;
                            strncpy(array_name, parsed_array, CFG_KEY_MAX - 1);
                            array_name[CFG_KEY_MAX - 1] = '\0';
                        }
                        snprintf(section, CFG_KEY_MAX, "%s.%d", array_name, array_index);
                    } else {
                        int32_t sec = cfg_parse_section(t, section, CFG_KEY_MAX);
                        if (sec < 0) return CFG_ERR_INVALID;
                        if (sec == 1) {
                            array_index = -1;
                            array_name[0] = '\0';
                        }
                        if (sec == 0) {
                            int32_t r = cfg_parse_kv_line(store, t, section[0] ? section : NULL, override);
                            if (r != CFG_OK) return r;
                        }
                    }
                }
            }
            line_pos = 0;
            i++;
            continue;
        }
        if (line_pos + 1 >= (int32_t)sizeof(line)) return CFG_ERR_INVALID;
        line[line_pos++] = c;
        i++;
    }
    return CFG_OK;
}

/** 从内存缓冲加载 TOML 子集；override 非 0 时覆盖已有键。 */
int32_t config_load_toml_buf_c(int64_t handle, const uint8_t *buf, int32_t len, int32_t override) {
    cfg_store_t *store = cfg_from_handle(handle);
    if (!store || !buf || len < 0) return CFG_ERR_NULL;
    store->active_source_kind = CFG_SRC_TOML;
    strncpy(store->active_source_label, "toml", CFG_SRC_LABEL_MAX - 1);
    store->active_source_label[CFG_SRC_LABEL_MAX - 1] = '\0';
    return cfg_load_toml_buf_impl(store, buf, len, override);
}

/** 从文件加载 TOML；最大 CFG_FILE_MAX 字节。 */
int32_t config_load_toml_file_c(int64_t handle, const uint8_t *path, int32_t override) {
    cfg_store_t *store = cfg_from_handle(handle);
    FILE *fp;
    long sz;
    uint8_t *buf;
    int32_t r;
    if (!path) return CFG_ERR_NULL;
    fp = fopen((const char *)path, "rb");
    if (!fp) return CFG_ERR_IO;
    if (fseek(fp, 0, SEEK_END) != 0) {
        fclose(fp);
        return CFG_ERR_IO;
    }
    sz = ftell(fp);
    if (sz < 0 || sz > CFG_FILE_MAX) {
        fclose(fp);
        return CFG_ERR_IO;
    }
    if (fseek(fp, 0, SEEK_SET) != 0) {
        fclose(fp);
        return CFG_ERR_IO;
    }
    buf = (uint8_t *)malloc((size_t)sz + 1);
    if (!buf) {
        fclose(fp);
        return CFG_ERR_IO;
    }
    if (fread(buf, 1, (size_t)sz, fp) != (size_t)sz) {
        free(buf);
        fclose(fp);
        return CFG_ERR_IO;
    }
    buf[sz] = '\0';
    fclose(fp);
    if (store) {
        store->active_source_kind = CFG_SRC_TOML;
        strncpy(store->active_source_label, (const char *)path, CFG_SRC_LABEL_MAX - 1);
        store->active_source_label[CFG_SRC_LABEL_MAX - 1] = '\0';
    }
    r = cfg_load_toml_buf_impl(store, buf, (int32_t)sz, override);
    free(buf);
    return r;
}

/** 加载 ENV 前缀键；APP_PORT → key "PORT"（去掉前缀）。返回加载条数，失败 -1。 */
int32_t config_load_env_prefix_c(int64_t handle, const uint8_t *prefix, int32_t prefix_len,
                                 int32_t override) {
    cfg_store_t *store = cfg_from_handle(handle);
    char pfx[128];
    int32_t n;
    int32_t loaded = 0;
    uint8_t key_buf[256];
    uint8_t val_buf[256];
    if (!store || !prefix || prefix_len <= 0 || prefix_len >= (int32_t)sizeof(pfx)) return CFG_ERR_NULL;
    memcpy(pfx, prefix, (size_t)prefix_len);
    pfx[prefix_len] = '\0';
    n = env_iter_count_c();
    for (int32_t i = 0; i < n; i++) {
        int32_t r = env_iter_at_c(i, key_buf, 256, val_buf, 256);
        if (r != 1) continue;
        if (strncmp((char *)key_buf, pfx, (size_t)prefix_len) != 0) continue;
        {
            const char *sub = (char *)key_buf + prefix_len;
            if (sub[0] == '\0') continue;
            if (cfg_set_raw_ex(store, sub, (char *)val_buf, override, CFG_SRC_ENV, (char *)key_buf) == CFG_OK) {
                loaded++;
            }
        }
    }
    return loaded;
}

/** 创建空配置；失败返回 0。 */
int64_t config_create_c(void) {
    cfg_store_t *s = (cfg_store_t *)calloc(1, sizeof(cfg_store_t));
    if (!s) return 0;
    return (int64_t)(uintptr_t)s;
}

/** 释放配置。 */
void config_free_c(int64_t handle) {
    cfg_store_t *s = cfg_from_handle(handle);
    if (s) free(s);
}

/** 清空所有键值。 */
void config_clear_c(int64_t handle) {
    cfg_store_t *s = cfg_from_handle(handle);
    if (!s) return;
    s->count = 0;
}

/** 将 src 合并到 dst；override 非 0 时 src 覆盖 dst 同名键。 */
int32_t config_merge_c(int64_t dst_handle, int64_t src_handle, int32_t override) {
    cfg_store_t *dst = cfg_from_handle(dst_handle);
    cfg_store_t *src = cfg_from_handle(src_handle);
    int32_t i;
    if (!dst || !src) return CFG_ERR_NULL;
    for (i = 0; i < src->count; i++) {
        int32_t r = cfg_set_raw_ex(dst, src->entries[i].key, src->entries[i].val, override,
                                   src->entries[i].source_kind, src->entries[i].source_label);
        if (r != CFG_OK) return r;
    }
    return CFG_OK;
}

/** 设置字符串键值（最高优先级层 / CLI 覆盖）。 */
int32_t config_set_string_c(int64_t handle, const uint8_t *key, int32_t key_len, const uint8_t *val,
                            int32_t val_len) {
    cfg_store_t *store = cfg_from_handle(handle);
    char k[CFG_KEY_MAX];
    char v[CFG_VAL_MAX];
    if (!store || !key || key_len <= 0 || !val || val_len < 0) return CFG_ERR_NULL;
    if (key_len >= CFG_KEY_MAX || val_len >= CFG_VAL_MAX) return CFG_ERR_INVALID;
    memcpy(k, key, (size_t)key_len);
    k[key_len] = '\0';
    if (val_len == 0) {
        v[0] = '\0';
    } else {
        memcpy(v, val, (size_t)val_len);
        v[val_len] = '\0';
    }
    return cfg_set_raw_ex(store, k, v, 1, CFG_SRC_SET, "cli");
}

/** 读取字符串；返回写入长度（不含 NUL），未找到 -2。 */
int32_t config_get_string_c(int64_t handle, const uint8_t *key, int32_t key_len, uint8_t *out,
                            int32_t out_cap) {
    cfg_store_t *store = cfg_from_handle(handle);
    int32_t idx;
    char k[CFG_KEY_MAX];
    size_t len;
    if (!store || !key || key_len <= 0 || !out || out_cap <= 0) return CFG_ERR_NULL;
    if (key_len >= CFG_KEY_MAX) return CFG_ERR_INVALID;
    memcpy(k, key, (size_t)key_len);
    k[key_len] = '\0';
    idx = cfg_find_index(store, k);
    if (idx < 0) return CFG_ERR_NOT_FOUND;
    len = strlen(store->entries[idx].val);
    if ((int32_t)len >= out_cap) {
        memcpy(out, store->entries[idx].val, (size_t)out_cap - 1);
        out[out_cap - 1] = '\0';
        return (int32_t)len;
    }
    memcpy(out, store->entries[idx].val, len + 1);
    return (int32_t)len;
}

/** 读取 i32；成功 0，未找到/非法 -2/-3。 */
int32_t config_get_i32_c(int64_t handle, const uint8_t *key, int32_t key_len, int32_t *out) {
    cfg_store_t *store = cfg_from_handle(handle);
    int32_t idx;
    char k[CFG_KEY_MAX];
    char *end = NULL;
    long v;
    if (!store || !key || key_len <= 0 || !out) return CFG_ERR_NULL;
    if (key_len >= CFG_KEY_MAX) return CFG_ERR_INVALID;
    memcpy(k, key, (size_t)key_len);
    k[key_len] = '\0';
    idx = cfg_find_index(store, k);
    if (idx < 0) return CFG_ERR_NOT_FOUND;
    v = strtol(store->entries[idx].val, &end, 10);
    if (end == store->entries[idx].val || (end && *end != '\0')) return CFG_ERR_INVALID;
    *out = (int32_t)v;
    return CFG_OK;
}

/** 读取 bool；true/1/yes/on 为 1，false/0/no/off 为 0。 */
int32_t config_get_bool_c(int64_t handle, const uint8_t *key, int32_t key_len, int32_t *out) {
    cfg_store_t *store = cfg_from_handle(handle);
    int32_t idx;
    char k[CFG_KEY_MAX];
    const char *v;
    if (!store || !key || key_len <= 0 || !out) return CFG_ERR_NULL;
    if (key_len >= CFG_KEY_MAX) return CFG_ERR_INVALID;
    memcpy(k, key, (size_t)key_len);
    k[key_len] = '\0';
    idx = cfg_find_index(store, k);
    if (idx < 0) return CFG_ERR_NOT_FOUND;
    v = store->entries[idx].val;
    if (strcmp(v, "true") == 0 || strcmp(v, "1") == 0 || strcmp(v, "yes") == 0 || strcmp(v, "on") == 0) {
        *out = 1;
        return CFG_OK;
    }
    if (strcmp(v, "false") == 0 || strcmp(v, "0") == 0 || strcmp(v, "no") == 0 || strcmp(v, "off") == 0) {
        *out = 0;
        return CFG_OK;
    }
    return CFG_ERR_INVALID;
}

/** 读取键来源 meta；out_kind 必填，out_label 可选（NUL 结尾）。 */
int32_t config_get_source_c(int64_t handle, const uint8_t *key, int32_t key_len, int32_t *out_kind,
                            uint8_t *out_label, int32_t label_cap) {
    cfg_store_t *store = cfg_from_handle(handle);
    int32_t idx;
    char k[CFG_KEY_MAX];
    if (!store || !key || key_len <= 0 || !out_kind) return CFG_ERR_NULL;
    if (key_len >= CFG_KEY_MAX) return CFG_ERR_INVALID;
    memcpy(k, key, (size_t)key_len);
    k[key_len] = '\0';
    idx = cfg_find_index(store, k);
    if (idx < 0) return CFG_ERR_NOT_FOUND;
    *out_kind = store->entries[idx].source_kind;
    if (out_label && label_cap > 0) {
        strncpy((char *)out_label, store->entries[idx].source_label, (size_t)label_cap - 1);
        out_label[label_cap - 1] = '\0';
    }
    return CFG_OK;
}

/** 读取 i32 并附带来源 meta（out_kind/out_label 可传 0/NULL 跳过 meta）。 */
int32_t config_get_i32_meta_c(int64_t handle, const uint8_t *key, int32_t key_len, int32_t *out_val,
                              int32_t *out_kind, uint8_t *out_label, int32_t label_cap) {
    int32_t r = config_get_i32_c(handle, key, key_len, out_val);
    if (r != CFG_OK || !out_kind) return r;
    return config_get_source_c(handle, key, key_len, out_kind, out_label, label_cap);
}

/** 读取 bool 并附带来源 meta。 */
int32_t config_get_bool_meta_c(int64_t handle, const uint8_t *key, int32_t key_len, int32_t *out_val,
                               int32_t *out_kind, uint8_t *out_label, int32_t label_cap) {
    int32_t r = config_get_bool_c(handle, key, key_len, out_val);
    if (r != CFG_OK || !out_kind) return r;
    return config_get_source_c(handle, key, key_len, out_kind, out_label, label_cap);
}

/** 读取字符串并附带来源 meta；返回值同 config_get_string_c。 */
int32_t config_get_string_meta_c(int64_t handle, const uint8_t *key, int32_t key_len, uint8_t *out,
                                 int32_t out_cap, int32_t *out_kind, uint8_t *out_label,
                                 int32_t label_cap) {
    int32_t r = config_get_string_c(handle, key, key_len, out, out_cap);
    if (r < 0 || !out_kind) return r;
    if (config_get_source_c(handle, key, key_len, out_kind, out_label, label_cap) != CFG_OK) {
        *out_kind = CFG_SRC_UNKNOWN;
    }
    return r;
}

/* --- STD-119：YAML 可选后端（扁平 + 缩进 section 子集） --- */

#define YAML_STACK_MAX 8

typedef struct yaml_frame {
    char name[CFG_KEY_MAX];
    int32_t indent;
} yaml_frame_t;

/** YAML 解析上下文：section 栈 + 列表序列状态。 */
typedef struct yaml_parse_ctx {
    yaml_frame_t stack[YAML_STACK_MAX];
    int32_t depth;
    char list_prefix[CFG_KEY_MAX];
    int32_t list_index;
    int32_t list_indent;
} yaml_parse_ctx_t;

/** 统计行首空格缩进（仅空格；tab 按 2 空格计）。 */
static int32_t cfg_yaml_indent(const char *line) {
    int32_t n = 0;
    if (!line) return 0;
    while (*line == ' ') {
        n++;
        line++;
    }
    if (*line == '\t') {
        n += 2;
    }
    return n;
}

/** 弹出缩进栈直至 top.indent < target。 */
static void cfg_yaml_pop_to(yaml_frame_t *stack, int32_t *depth, int32_t target_indent) {
    while (*depth > 0 && stack[*depth - 1].indent >= target_indent) {
        (*depth)--;
    }
}

/** 将栈上 section 与 local 拼成 "a.b.key"。 */
static int32_t cfg_yaml_build_key(const yaml_frame_t *stack, int32_t depth, const char *local,
                                  char *out, int32_t out_cap) {
    int32_t pos = 0;
    int32_t i = 0;
    if (!local || !out || out_cap <= 0) return CFG_ERR_NULL;
    while (i < depth) {
        size_t sl = strlen(stack[i].name);
        if (sl == 0) return CFG_ERR_INVALID;
        if (pos > 0) {
            if (pos + 1 >= out_cap) return CFG_ERR_INVALID;
            out[pos++] = '.';
        }
        if (pos + (int32_t)sl >= out_cap) return CFG_ERR_INVALID;
        memcpy(out + pos, stack[i].name, sl);
        pos += (int32_t)sl;
        i++;
    }
    if (local[0] == '\0') return CFG_ERR_INVALID;
    if (pos > 0) {
        if (pos + 1 >= out_cap) return CFG_ERR_INVALID;
        out[pos++] = '.';
    }
    {
        size_t ll = strlen(local);
        if (pos + (int32_t)ll >= out_cap) return CFG_ERR_INVALID;
        memcpy(out + pos, local, ll);
        pos += (int32_t)ll;
    }
    out[pos] = '\0';
    return CFG_OK;
}

/** 清空 YAML 列表序列状态。 */
static void cfg_yaml_list_reset(yaml_parse_ctx_t *ctx) {
    if (!ctx) return;
    ctx->list_prefix[0] = '\0';
    ctx->list_index = -1;
    ctx->list_indent = -1;
}

/** 将 stack[0..depth-1] 拼成点分前缀（无 local 后缀）。 */
static int32_t cfg_yaml_frame_key(const yaml_frame_t *stack, int32_t depth, char *out, int32_t out_cap) {
    int32_t pos = 0;
    int32_t i = 0;
    if (!stack || !out || out_cap <= 0 || depth <= 0) return CFG_ERR_NULL;
    while (i < depth) {
        size_t sl = strlen(stack[i].name);
        if (sl == 0) return CFG_ERR_INVALID;
        if (pos > 0) {
            if (pos + 1 >= out_cap) return CFG_ERR_INVALID;
            out[pos++] = '.';
        }
        if (pos + (int32_t)sl >= out_cap) return CFG_ERR_INVALID;
        memcpy(out + pos, stack[i].name, sl);
        pos += (int32_t)sl;
        i++;
    }
    out[pos] = '\0';
    return CFG_OK;
}

/** 解析 YAML 列表标量项 `- value` → list_prefix.index。 */
static int32_t cfg_yaml_list_ensure_item(yaml_parse_ctx_t *ctx, int32_t indent, int32_t new_dash) {
    if (!ctx) return CFG_ERR_NULL;
    if (ctx->list_prefix[0] == '\0') {
        if (ctx->depth <= 0) return CFG_ERR_INVALID;
        if (cfg_yaml_frame_key(ctx->stack, ctx->depth, ctx->list_prefix, CFG_KEY_MAX) != CFG_OK) {
            return CFG_ERR_INVALID;
        }
        ctx->list_index = 0;
        ctx->list_indent = indent;
        return CFG_OK;
    }
    if (new_dash && indent == ctx->list_indent) {
        ctx->list_index++;
    }
    return CFG_OK;
}

/** 写入 list_prefix.index[.field] 键值。field 为空时键为 list_prefix.index。 */
static int32_t cfg_yaml_set_list_entry(cfg_store_t *store, yaml_parse_ctx_t *ctx, const char *field,
                                       const char *val, int32_t override) {
    char key_full[CFG_KEY_MAX];
    if (!store || !ctx || !val) return CFG_ERR_NULL;
    if (ctx->list_index < 0) return CFG_ERR_INVALID;
    if (field && field[0]) {
        snprintf(key_full, sizeof(key_full), "%s.%d.%s", ctx->list_prefix, ctx->list_index, field);
    } else {
        snprintf(key_full, sizeof(key_full), "%s.%d", ctx->list_prefix, ctx->list_index);
    }
    return cfg_set_raw(store, key_full, val, override);
}

/** 解析 `- key: value` 或列表项内续行 `key: value`。 */
static int32_t cfg_yaml_parse_list_field(cfg_store_t *store, yaml_parse_ctx_t *ctx, const char *line,
                                         int32_t indent, int32_t new_dash, int32_t override) {
    char key_local[CFG_KEY_MAX];
    char val_buf[CFG_VAL_MAX];
    const char *t;
    int32_t tl = 0;
    int32_t key_len = 0;
    int32_t val_len = 0;
    const char *val_part;
    const char *key_start;
    const char *colon;
    const char *content;
    if (!store || !ctx || !line) return CFG_ERR_NULL;
    t = cfg_trim(line, &tl);
    if (tl <= 0) return CFG_ERR_INVALID;
    content = t;
    if (new_dash) {
        if (t[0] != '-') return CFG_ERR_INVALID;
        content = t + 1;
        while (*content == ' ') content++;
    }
    colon = strchr(content, ':');
    if (!colon) return CFG_ERR_INVALID;
    key_start = content;
    key_len = (int32_t)(colon - key_start);
    while (key_len > 0 && isspace((unsigned char)key_start[key_len - 1])) key_len--;
    if (key_len <= 0 || key_len >= CFG_KEY_MAX) return CFG_ERR_INVALID;
    memcpy(key_local, key_start, (size_t)key_len);
    key_local[key_len] = '\0';
    val_part = cfg_trim(colon + 1, &val_len);
    if (val_len <= 0) return CFG_ERR_INVALID;
    if (cfg_yaml_list_ensure_item(ctx, indent, new_dash) != CFG_OK) return CFG_ERR_INVALID;
    if (cfg_normalize_value(val_part, val_len, val_buf, CFG_VAL_MAX) != CFG_OK) return CFG_ERR_INVALID;
    return cfg_yaml_set_list_entry(store, ctx, key_local, val_buf, override);
}

/** 解析 YAML 列表标量项 `- value` → list_prefix.index。 */
static int32_t cfg_yaml_parse_list_scalar(cfg_store_t *store, yaml_parse_ctx_t *ctx, const char *line,
                                          int32_t override) {
    char val_buf[CFG_VAL_MAX];
    const char *t;
    int32_t tl = 0;
    int32_t indent;
    int32_t val_len = 0;
    const char *val_part;
    if (!store || !ctx || !line) return CFG_ERR_NULL;
    indent = cfg_yaml_indent(line);
    t = cfg_trim(line, &tl);
    if (tl < 2 || t[0] != '-') return CFG_ERR_INVALID;
    val_part = cfg_trim(t + 1, &val_len);
    if (val_len <= 0) return CFG_ERR_INVALID;
    if (cfg_yaml_list_ensure_item(ctx, indent, 1) != CFG_OK) return CFG_ERR_INVALID;
    if (cfg_normalize_value(val_part, val_len, val_buf, CFG_VAL_MAX) != CFG_OK) return CFG_ERR_INVALID;
    return cfg_yaml_set_list_entry(store, ctx, NULL, val_buf, override);
}

/** 解析 YAML 单行 key: value；支持缩进 section、`-` 序列与空值 section 头。 */
static int32_t cfg_yaml_parse_line(cfg_store_t *store, const char *line, yaml_parse_ctx_t *ctx,
                                   int32_t override) {
    char key_local[CFG_KEY_MAX];
    char key_full[CFG_KEY_MAX];
    char val_buf[CFG_VAL_MAX];
    const char *colon;
    const char *key_start;
    int32_t indent = 0;
    int32_t key_len = 0;
    int32_t val_len = 0;
    const char *val_part;
    const char *t;
    int32_t tl = 0;
    if (!store || !line || !ctx) return CFG_ERR_NULL;
    t = cfg_trim(line, &tl);
    if (tl <= 0 || t[0] == '#') return CFG_OK;
    indent = cfg_yaml_indent(line);
    if (tl > 0 && t[0] == '-') {
        const char *after = t + 1;
        while (*after == ' ') after++;
        if (strchr(after, ':') != NULL) {
            return cfg_yaml_parse_list_field(store, ctx, line, indent, 1, override);
        }
        return cfg_yaml_parse_list_scalar(store, ctx, line, override);
    }
    if (ctx->list_prefix[0] != '\0' && indent > ctx->list_indent && strchr(t, ':') != NULL) {
        return cfg_yaml_parse_list_field(store, ctx, line, indent, 0, override);
    }
    if (ctx->list_prefix[0] != '\0' && indent <= ctx->list_indent) {
        cfg_yaml_list_reset(ctx);
    }
    cfg_yaml_pop_to(ctx->stack, &ctx->depth, indent);
    colon = strchr(t, ':');
    if (!colon) return CFG_ERR_INVALID;
    key_start = t;
    key_len = (int32_t)(colon - key_start);
    while (key_len > 0 && isspace((unsigned char)key_start[key_len - 1])) key_len--;
    if (key_len <= 0 || key_len >= CFG_KEY_MAX) return CFG_ERR_INVALID;
    memcpy(key_local, key_start, (size_t)key_len);
    key_local[key_len] = '\0';
    {
        int32_t ki = 0;
        while (ki < key_len) {
            char c = key_local[ki];
            if (!isalnum((unsigned char)c) && c != '_' && c != '.') return CFG_ERR_INVALID;
            ki++;
        }
    }
    val_part = cfg_trim(colon + 1, &val_len);
    if (val_len == 0) {
        if (ctx->depth >= YAML_STACK_MAX) return CFG_ERR_FULL;
        cfg_yaml_list_reset(ctx);
        strncpy(ctx->stack[ctx->depth].name, key_local, CFG_KEY_MAX - 1);
        ctx->stack[ctx->depth].name[CFG_KEY_MAX - 1] = '\0';
        ctx->stack[ctx->depth].indent = indent;
        ctx->depth++;
        return CFG_OK;
    }
    if (ctx->depth > 0) {
        if (cfg_yaml_build_key(ctx->stack, ctx->depth, key_local, key_full, CFG_KEY_MAX) != CFG_OK) {
            return CFG_ERR_INVALID;
        }
    } else {
        strncpy(key_full, key_local, CFG_KEY_MAX - 1);
        key_full[CFG_KEY_MAX - 1] = '\0';
    }
    if (cfg_normalize_value(val_part, val_len, val_buf, CFG_VAL_MAX) != CFG_OK) return CFG_ERR_INVALID;
    return cfg_set_raw(store, key_full, val_buf, override);
}

/** 从内存缓冲加载 YAML 子集（调用前须设置 active_source_*）。 */
static int32_t cfg_load_yaml_buf_impl(cfg_store_t *store, const uint8_t *buf, int32_t len, int32_t override) {
    yaml_parse_ctx_t ctx;
    char line[512];
    int32_t i = 0;
    int32_t line_pos = 0;
    if (!store || !buf || len < 0) return CFG_ERR_NULL;
    memset(&ctx, 0, sizeof(ctx));
    while (i <= len) {
        char c = (i < len) ? (char)buf[i] : '\n';
        if (c == '\r') {
            i++;
            continue;
        }
        if (c == '\n' || c == '\0') {
            line[line_pos] = '\0';
            if (line_pos > 0) {
                int32_t r = cfg_yaml_parse_line(store, line, &ctx, override);
                if (r != CFG_OK) return r;
            }
            line_pos = 0;
            i++;
            continue;
        }
        if (line_pos + 1 >= (int32_t)sizeof(line)) return CFG_ERR_INVALID;
        line[line_pos++] = c;
        i++;
    }
    return CFG_OK;
}

/** 从内存缓冲加载 YAML 子集；override 非 0 时覆盖已有键。 */
int32_t config_load_yaml_buf_c(int64_t handle, const uint8_t *buf, int32_t len, int32_t override) {
    cfg_store_t *store = cfg_from_handle(handle);
    if (!store || !buf || len < 0) return CFG_ERR_NULL;
    store->active_source_kind = CFG_SRC_YAML;
    strncpy(store->active_source_label, "yaml", CFG_SRC_LABEL_MAX - 1);
    store->active_source_label[CFG_SRC_LABEL_MAX - 1] = '\0';
    return cfg_load_yaml_buf_impl(store, buf, len, override);
}

/** 从文件加载 YAML；最大 CFG_FILE_MAX 字节。 */
int32_t config_load_yaml_file_c(int64_t handle, const uint8_t *path, int32_t override) {
    cfg_store_t *store = cfg_from_handle(handle);
    FILE *fp;
    long sz;
    uint8_t *buf;
    int32_t r;
    if (!path) return CFG_ERR_NULL;
    fp = fopen((const char *)path, "rb");
    if (!fp) return CFG_ERR_IO;
    if (fseek(fp, 0, SEEK_END) != 0) {
        fclose(fp);
        return CFG_ERR_IO;
    }
    sz = ftell(fp);
    if (sz < 0 || sz > CFG_FILE_MAX) {
        fclose(fp);
        return CFG_ERR_IO;
    }
    if (fseek(fp, 0, SEEK_SET) != 0) {
        fclose(fp);
        return CFG_ERR_IO;
    }
    buf = (uint8_t *)malloc((size_t)sz + 1);
    if (!buf) {
        fclose(fp);
        return CFG_ERR_IO;
    }
    if (fread(buf, 1, (size_t)sz, fp) != (size_t)sz) {
        free(buf);
        fclose(fp);
        return CFG_ERR_IO;
    }
    buf[sz] = '\0';
    fclose(fp);
    if (store) {
        store->active_source_kind = CFG_SRC_YAML;
        strncpy(store->active_source_label, (const char *)path, CFG_SRC_LABEL_MAX - 1);
        store->active_source_label[CFG_SRC_LABEL_MAX - 1] = '\0';
    }
    r = cfg_load_yaml_buf_impl(store, buf, (int32_t)sz, override);
    free(buf);
    return r;
}

/** YAML 后端 C 烟测：嵌套 section + 类型化读取。 */
int32_t config_yaml_smoke_c(void) {
    int64_t cfg = config_create_c();
    int32_t port = 0;
    int32_t dbg = 0;
    uint8_t url[64];
    static const uint8_t yaml[] =
        "# app\n"
        "port: 8080\n"
        "host: localhost\n"
        "debug: false\n"
        "\n"
        "db:\n"
        "  url: sqlite://mem\n";
    if (cfg == 0) return 1;
    if (config_load_yaml_buf_c(cfg, yaml, (int32_t)(sizeof(yaml) - 1), 1) != CFG_OK) return 2;
    if (config_get_i32_c(cfg, (const uint8_t *)"port", 4, &port) != CFG_OK || port != 8080) return 3;
    if (config_get_string_c(cfg, (const uint8_t *)"db.url", 6, url, 64) <= 0) return 4;
    if (strcmp((char *)url, "sqlite://mem") != 0) return 5;
    if (config_get_bool_c(cfg, (const uint8_t *)"debug", 5, &dbg) != CFG_OK || dbg != 0) return 6;
    {
        static const uint8_t yaml_arr[] =
            "items:\n"
            "  - 10\n"
            "  - 20\n";
        if (config_load_yaml_buf_c(cfg, yaml_arr, (int32_t)(sizeof(yaml_arr) - 1), 1) != CFG_OK) return 7;
        if (config_get_i32_c(cfg, (const uint8_t *)"items.0", 7, &port) != CFG_OK || port != 10) return 8;
        if (config_get_i32_c(cfg, (const uint8_t *)"items.1", 7, &port) != CFG_OK || port != 20) return 9;
    }
    {
        static const uint8_t yaml_obj[] =
            "servers:\n"
            "  - host: alpha\n"
            "    port: 80\n"
            "  - host: beta\n"
            "    port: 443\n";
        uint8_t host[64];
        if (config_load_yaml_buf_c(cfg, yaml_obj, (int32_t)(sizeof(yaml_obj) - 1), 1) != CFG_OK) return 10;
        if (config_get_string_c(cfg, (const uint8_t *)"servers.0.host", 14, host, 64) <= 0) return 11;
        if (strcmp((char *)host, "alpha") != 0) return 12;
        if (config_get_i32_c(cfg, (const uint8_t *)"servers.0.port", 14, &port) != CFG_OK || port != 80) return 13;
        if (config_get_string_c(cfg, (const uint8_t *)"servers.1.host", 14, host, 64) <= 0) return 14;
        if (strcmp((char *)host, "beta") != 0) return 15;
        if (config_get_i32_c(cfg, (const uint8_t *)"servers.1.port", 14, &port) != CFG_OK || port != 443) return 16;
    }
    config_free_c(cfg);
    return 0;
}

/** C 烟测：TOML [[array]]（array-of-tables → servers.0.host）。 */
int32_t config_array_smoke_c(void) {
    int64_t cfg = config_create_c();
    int32_t p0 = 0;
    int32_t p1 = 0;
    uint8_t h0[64];
    uint8_t h1[64];
    static const uint8_t toml[] =
        "[[servers]]\n"
        "host = \"alpha\"\n"
        "port = 80\n"
        "\n"
        "[[servers]]\n"
        "host = \"beta\"\n"
        "port = 443\n";
    if (cfg == 0) return 1;
    if (config_load_toml_buf_c(cfg, toml, (int32_t)(sizeof(toml) - 1), 1) != CFG_OK) return 2;
    if (config_get_string_c(cfg, (const uint8_t *)"servers.0.host", 14, h0, 64) <= 0) return 3;
    if (strcmp((char *)h0, "alpha") != 0) return 4;
    if (config_get_i32_c(cfg, (const uint8_t *)"servers.0.port", 14, &p0) != CFG_OK || p0 != 80) return 5;
    if (config_get_string_c(cfg, (const uint8_t *)"servers.1.host", 14, h1, 64) <= 0) return 6;
    if (strcmp((char *)h1, "beta") != 0) return 7;
    if (config_get_i32_c(cfg, (const uint8_t *)"servers.1.port", 14, &p1) != CFG_OK || p1 != 443) return 8;
    config_free_c(cfg);
    return 0;
}

/** C 烟测：TOML 嵌套 section（[server.db] → server.db.url）。 */
int32_t config_nested_smoke_c(void) {
    int64_t cfg = config_create_c();
    int32_t port = 0;
    uint8_t host[64];
    uint8_t url[64];
    static const uint8_t toml[] =
        "[server]\n"
        "host = \"localhost\"\n"
        "\n"
        "[server.db]\n"
        "url = \"sqlite://mem\"\n"
        "port = 5432\n";
    if (cfg == 0) return 1;
    if (config_load_toml_buf_c(cfg, toml, (int32_t)(sizeof(toml) - 1), 1) != CFG_OK) return 2;
    if (config_get_string_c(cfg, (const uint8_t *)"server.host", 11, host, 64) <= 0) return 3;
    if (strcmp((char *)host, "localhost") != 0) return 4;
    if (config_get_string_c(cfg, (const uint8_t *)"server.db.url", 13, url, 64) <= 0) return 5;
    if (strcmp((char *)url, "sqlite://mem") != 0) return 6;
    if (config_get_i32_c(cfg, (const uint8_t *)"server.db.port", 14, &port) != CFG_OK || port != 5432) return 7;
    config_free_c(cfg);
    return 0;
}

/** C 烟测：TOML + merge + 类型化读取。 */
int32_t config_smoke_c(void) {
    int64_t base = config_create_c();
    int64_t overlay = config_create_c();
    int32_t port = 0;
    int32_t dbg = 0;
    uint8_t host[64];
    static const uint8_t toml[] =
        "# app\n"
        "port = 8080\n"
        "host = \"localhost\"\n"
        "debug = false\n"
        "\n"
        "[db]\n"
        "url = \"sqlite://mem\"\n";
    static const uint8_t env_prefix[] = "SHUX_CFG_";
    if (base == 0 || overlay == 0) return 1;
    if (config_load_toml_buf_c(base, toml, (int32_t)(sizeof(toml) - 1), 1) != CFG_OK) return 2;
    if (config_get_i32_c(base, (const uint8_t *)"port", 4, &port) != CFG_OK || port != 8080) return 3;
    if (config_get_string_c(base, (const uint8_t *)"db.url", 6, host, 64) <= 0) return 4;
    if (strcmp((char *)host, "sqlite://mem") != 0) return 5;
#if defined(_WIN32) || defined(_WIN64)
    _putenv("SHUX_CFG_debug=true");
#else
    setenv("SHUX_CFG_debug", "true", 1);
#endif
    if (config_load_env_prefix_c(base, env_prefix, (int32_t)(sizeof(env_prefix) - 1), 1) < 0) return 6;
    if (config_get_bool_c(base, (const uint8_t *)"debug", 5, &dbg) != CFG_OK || dbg != 1) return 7;
    {
        int32_t kind = 0;
        uint8_t label[64];
        if (config_get_source_c(base, (const uint8_t *)"debug", 5, &kind, label, 64) != CFG_OK) return 71;
        if (kind != CFG_SRC_ENV) return 72;
        if (strcmp((char *)label, "SHUX_CFG_debug") != 0) return 73;
        if (config_get_source_c(base, (const uint8_t *)"port", 4, &kind, label, 64) != CFG_OK) return 74;
        if (kind != CFG_SRC_TOML) return 75;
    }
    if (config_set_string_c(overlay, (const uint8_t *)"port", 4, (const uint8_t *)"9090", 4) != CFG_OK) return 8;
    if (config_merge_c(base, overlay, 1) != CFG_OK) return 9;
    if (config_get_i32_c(base, (const uint8_t *)"port", 4, &port) != CFG_OK || port != 9090) return 10;
    {
        int32_t kind = 0;
        if (config_get_i32_meta_c(base, (const uint8_t *)"port", 4, &port, &kind, NULL, 0) != CFG_OK) return 101;
        if (port != 9090 || kind != CFG_SRC_SET) return 102;
    }
    config_free_c(overlay);
    config_free_c(base);
    {
        int32_t nr = config_nested_smoke_c();
        if (nr != 0) return 100 + nr;
    }
    {
        int32_t ar = config_array_smoke_c();
        if (ar != 0) return 200 + ar;
    }
    return 0;
}
