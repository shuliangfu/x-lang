/**
 * std/config/config.c — 分层配置加载（STD-086）
 *
 * 【文件职责】
 * 扁平 + [section] 前缀 TOML 子集解析；ENV 前缀加载；多源 merge；
 * 类型化 get_string / get_i32 / get_bool；供 mod.su 与 gate 烟测调用。
 *
 * 【所属模块】标准库 std.config；与 std/config/mod.su 同属一模块。
 * 【依赖】std/env/env.c（env_iter_*）；可选 std/fs 读文件（本文件自含 fread）。
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

/** 与 mod.su 错误码一致。 */
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

typedef struct cfg_entry {
    char key[CFG_KEY_MAX];
    char val[CFG_VAL_MAX];
} cfg_entry_t;

typedef struct cfg_store {
    cfg_entry_t entries[CFG_MAX_ENTRIES];
    int32_t count;
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

/** 设置键值；override 非 0 时覆盖已有项。返回 CFG_OK 或错误码。 */
static int32_t cfg_set_raw(cfg_store_t *store, const char *key, const char *val, int32_t override) {
    int32_t idx;
    if (!store || !key || !val) return CFG_ERR_NULL;
    if (key[0] == '\0') return CFG_ERR_INVALID;
    idx = cfg_find_index(store, key);
    if (idx >= 0) {
        if (!override) return CFG_OK;
        strncpy(store->entries[idx].val, val, CFG_VAL_MAX - 1);
        store->entries[idx].val[CFG_VAL_MAX - 1] = '\0';
        return CFG_OK;
    }
    if (store->count >= CFG_MAX_ENTRIES) return CFG_ERR_FULL;
    strncpy(store->entries[store->count].key, key, CFG_KEY_MAX - 1);
    store->entries[store->count].key[CFG_KEY_MAX - 1] = '\0';
    strncpy(store->entries[store->count].val, val, CFG_VAL_MAX - 1);
    store->entries[store->count].val[CFG_VAL_MAX - 1] = '\0';
    store->count++;
    return CFG_OK;
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

/** 解析 [section] 头；写入 out 并返回 1，否则 0。 */
static int32_t cfg_parse_section(const char *line, char *out, int32_t out_cap) {
    int32_t len = 0;
    const char *t;
    int32_t i = 0;
    t = cfg_trim(line, &len);
    if (len < 3 || t[0] != '[' || t[len - 1] != ']') return 0;
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

/** 从内存缓冲加载 TOML 子集；override 非 0 时覆盖已有键。 */
int32_t config_load_toml_buf_c(int64_t handle, const uint8_t *buf, int32_t len, int32_t override) {
    cfg_store_t *store = cfg_from_handle(handle);
    char section[CFG_KEY_MAX];
    char line[512];
    int32_t i = 0;
    int32_t line_pos = 0;
    if (!store || !buf || len < 0) return CFG_ERR_NULL;
    section[0] = '\0';
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
                    int32_t sec = cfg_parse_section(t, section, CFG_KEY_MAX);
                    if (sec < 0) return CFG_ERR_INVALID;
                    if (sec == 0) {
                        int32_t r = cfg_parse_kv_line(store, t, section[0] ? section : NULL, override);
                        if (r != CFG_OK) return r;
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

/** 从文件加载 TOML；最大 CFG_FILE_MAX 字节。 */
int32_t config_load_toml_file_c(int64_t handle, const uint8_t *path, int32_t override) {
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
    r = config_load_toml_buf_c(handle, buf, (int32_t)sz, override);
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
            if (cfg_set_raw(store, sub, (char *)val_buf, override) == CFG_OK) loaded++;
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
        int32_t r = cfg_set_raw(dst, src->entries[i].key, src->entries[i].val, override);
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
    return cfg_set_raw(store, k, v, 1);
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

/* --- STD-119：YAML 可选后端（扁平 + 缩进 section 子集） --- */

#define YAML_STACK_MAX 8

typedef struct yaml_frame {
    char name[CFG_KEY_MAX];
    int32_t indent;
} yaml_frame_t;

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

/** 解析 YAML 单行 key: value；支持缩进 section 与空值 section 头。 */
static int32_t cfg_yaml_parse_line(cfg_store_t *store, const char *line, yaml_frame_t *stack,
                                   int32_t *depth, int32_t override) {
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
    if (!store || !line || !stack || !depth) return CFG_ERR_NULL;
    t = cfg_trim(line, &tl);
    if (tl <= 0 || t[0] == '#') return CFG_OK;
    indent = cfg_yaml_indent(line);
    cfg_yaml_pop_to(stack, depth, indent);
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
        if (*depth >= YAML_STACK_MAX) return CFG_ERR_FULL;
        strncpy(stack[*depth].name, key_local, CFG_KEY_MAX - 1);
        stack[*depth].name[CFG_KEY_MAX - 1] = '\0';
        stack[*depth].indent = indent;
        (*depth)++;
        return CFG_OK;
    }
    if (*depth > 0) {
        if (cfg_yaml_build_key(stack, *depth, key_local, key_full, CFG_KEY_MAX) != CFG_OK) return CFG_ERR_INVALID;
    } else {
        strncpy(key_full, key_local, CFG_KEY_MAX - 1);
        key_full[CFG_KEY_MAX - 1] = '\0';
    }
    if (cfg_normalize_value(val_part, val_len, val_buf, CFG_VAL_MAX) != CFG_OK) return CFG_ERR_INVALID;
    return cfg_set_raw(store, key_full, val_buf, override);
}

/** 从内存缓冲加载 YAML 子集；override 非 0 时覆盖已有键。 */
int32_t config_load_yaml_buf_c(int64_t handle, const uint8_t *buf, int32_t len, int32_t override) {
    cfg_store_t *store = cfg_from_handle(handle);
    yaml_frame_t stack[YAML_STACK_MAX];
    int32_t depth = 0;
    char line[512];
    int32_t i = 0;
    int32_t line_pos = 0;
    if (!store || !buf || len < 0) return CFG_ERR_NULL;
    while (i <= len) {
        char c = (i < len) ? (char)buf[i] : '\n';
        if (c == '\r') {
            i++;
            continue;
        }
        if (c == '\n' || c == '\0') {
            line[line_pos] = '\0';
            if (line_pos > 0) {
                int32_t r = cfg_yaml_parse_line(store, line, stack, &depth, override);
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

/** 从文件加载 YAML；最大 CFG_FILE_MAX 字节。 */
int32_t config_load_yaml_file_c(int64_t handle, const uint8_t *path, int32_t override) {
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
    r = config_load_yaml_buf_c(handle, buf, (int32_t)sz, override);
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
    static const uint8_t env_prefix[] = "SHU_CFG_";
    if (base == 0 || overlay == 0) return 1;
    if (config_load_toml_buf_c(base, toml, (int32_t)(sizeof(toml) - 1), 1) != CFG_OK) return 2;
    if (config_get_i32_c(base, (const uint8_t *)"port", 4, &port) != CFG_OK || port != 8080) return 3;
    if (config_get_string_c(base, (const uint8_t *)"db.url", 6, host, 64) <= 0) return 4;
    if (strcmp((char *)host, "sqlite://mem") != 0) return 5;
#if defined(_WIN32) || defined(_WIN64)
    _putenv("SHU_CFG_debug=true");
#else
    setenv("SHU_CFG_debug", "true", 1);
#endif
    if (config_load_env_prefix_c(base, env_prefix, 8, 1) < 0) return 6;
    if (config_get_bool_c(base, (const uint8_t *)"debug", 5, &dbg) != CFG_OK || dbg != 1) return 7;
    if (config_set_string_c(overlay, (const uint8_t *)"port", 4, (const uint8_t *)"9090", 4) != CFG_OK) return 8;
    if (config_merge_c(base, overlay, 1) != CFG_OK) return 9;
    if (config_get_i32_c(base, (const uint8_t *)"port", 4, &port) != CFG_OK || port != 9090) return 10;
    config_free_c(overlay);
    config_free_c(base);
    return 0;
}
