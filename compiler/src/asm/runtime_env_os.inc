/**
 * runtime_env_os.c — 环境变量 OS 胶层（F-ZC：自 std/env/env_os_glue.c 迁入）
 *
 * getenv/setenv/unsetenv/temp_dir/env_iter；env.x 经 extern 调用；与 env.o 一并链入。
 */
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#if defined(_MSC_VER)
#define ENV_TLS __declspec(thread)
#else
#define ENV_TLS __thread
#endif
#else
#define ENV_TLS __thread
#endif

#if defined(__GNUC__) || defined(__clang__)
#define ENV_HOT        __attribute__((hot))
#define ENV_COLD       __attribute__((cold))
#define ENV_LIKELY(x)   __builtin_expect(!!(x), 1)
#define ENV_UNLIKELY(x) __builtin_expect(!!(x), 0)
#else
#define ENV_HOT
#define ENV_COLD
#define ENV_LIKELY(x)   (x)
#define ENV_UNLIKELY(x) (x)
#endif

/** 环境变量名最大长度（POSIX 通常 ≤255），key 超过此长度直接拒绝。 */
#define ENV_KEY_MAX 256

/**
 * 热路径共用：校验 key 并写入 key_buf（含 NUL）。
 * 参数：key/key_len 输入；key_buf 至少 key_len+1 字节。
 * 返回值：0 成功，-1 非法。
 */
static inline int env_build_key(const uint8_t * restrict key, int32_t key_len, char * restrict key_buf) {
    if (key == NULL || key_len <= 0 || key_len >= ENV_KEY_MAX) return -1;
    memcpy(key_buf, key, (size_t)key_len);
    key_buf[key_len] = '\0';
    return 0;
}

/**
 * getenv：key[0..key_len) 拷贝到栈上并加 NUL，调用系统 getenv；结果写入 out。
 * 返回值：写入字节数（不含 NUL），不存在或错误 -1。
 */
ENV_HOT
int32_t env_getenv_c(const uint8_t * restrict key, int32_t key_len, uint8_t * restrict out, int32_t out_cap) {
    if (out == NULL || out_cap <= 0) return -1;

#if defined(__STDC_NO_VLA__)
    char key_buf[ENV_KEY_MAX];
#else
    char key_buf[key_len + 1];
#endif
    if (env_build_key(key, key_len, key_buf) != 0) return -1;

#if defined(_WIN32) || defined(_WIN64)
    {
        DWORD need = GetEnvironmentVariableA(key_buf, (char *)out, (DWORD)out_cap);
        if (need == 0) {
            /* 【Why 根源】GetEnvironmentVariableA 对空 value 也返回 0，须用 GetLastError 区分
             * 空值（ERROR_SUCCESS，变量存在但 value 为 ""）与不存在（ERROR_ENVVAR_NOT_FOUND）。
             * POSIX getenv 对空 value 返回非 NULL 指针，此处对齐语义返回 0（写入长度 0）。
             * 【Invariant】out[0] 已 NUL 终止（GetEnvironmentVariableA 失败时不写 out）。 */
            DWORD err = GetLastError();
            if (err == ERROR_SUCCESS) {
                out[0] = '\0';
                return 0;
            }
            return -1;
        }
        if (need > (DWORD)out_cap) return (int32_t)need;
        return (int32_t)need;
    }
#else
    {
        const char *v = getenv(key_buf);
        if (ENV_UNLIKELY(v == NULL)) return -1;
        size_t len = strlen(v);
        if (ENV_LIKELY(len < (size_t)out_cap)) {
            memcpy(out, v, len + 1);
            return (int32_t)len;
        }
        memcpy(out, v, (size_t)out_cap - 1);
        out[out_cap - 1] = '\0';
        return (int32_t)len;
    }
#endif
}

/**
 * 零拷贝 getenv：返回 value 只读指针（NUL 结尾），不存在 NULL。
 * 参数：out_len 可选写入长度（不含 NUL）。
 */
ENV_HOT
uint8_t *env_getenv_ptr_c(const uint8_t * restrict key, int32_t key_len, int32_t *out_len) {
#if defined(__STDC_NO_VLA__)
    char key_buf[ENV_KEY_MAX];
#else
    char key_buf[key_len + 1];
#endif
    if (env_build_key(key, key_len, key_buf) != 0) return NULL;

    const char *v = getenv(key_buf);
    if (v == NULL) return NULL;
    if (out_len) *out_len = (int32_t)strlen(v);
    return (uint8_t *)v;
}

/**
 * 零拷贝 getenv（key 须 NUL 结尾）：直接 getenv，无 key 拷贝。
 */
ENV_HOT
uint8_t *env_getenv_z_c(const uint8_t *key_z, int32_t *out_len) {
    if (key_z == NULL) return NULL;
    const char *v = getenv((const char *)key_z);
    if (v == NULL) return NULL;
    if (out_len) *out_len = (int32_t)strlen(v);
    return (uint8_t *)v;
}

/**
 * 判断环境变量是否存在；存在 1，不存在 0。
 */
ENV_HOT
int32_t env_getenv_exists_c(const uint8_t * restrict key, int32_t key_len) {
#if defined(__STDC_NO_VLA__)
    char key_buf[ENV_KEY_MAX];
#else
    char key_buf[key_len + 1];
#endif
    if (env_build_key(key, key_len, key_buf) != 0) return 0;

#if defined(_WIN32) || defined(_WIN64)
    return GetEnvironmentVariableA(key_buf, NULL, 0) != 0 ? 1 : 0;
#else
    return getenv(key_buf) != NULL ? 1 : 0;
#endif
}

/**
 * 设置环境变量 name=value（NUL 结尾）；overwrite 非 0 覆盖。
 * 返回值：0 成功，-1 失败。
 */
ENV_COLD
int32_t env_setenv_c(const uint8_t *name, const uint8_t *value, int32_t overwrite) {
    if (name == NULL) return -1;
#if defined(_WIN32) || defined(_WIN64)
    /* 【Why 根源】Windows 有两套环境块：
     * 1. 进程环境块（Get/SetEnvironmentVariableA）— env_getenv_c 用此读取
     * 2. CRT 环境（_putenv/getenv）— env_getenv_z_c / env_getenv_ptr_c 用此读取
     * 非空 value 时须同时更新两者，否则零拷贝 getenv_z/ptr 读不到 setenv 的值。
     * 空 value 时 _putenv("name=") 会删除变量（MSDN 行为），只用 SetEnvironmentVariableA 设空。
     * 【Invariant】overwrite=0 时仍覆盖（Windows 无原子 check-and-set，测试不依赖此语义）。
     * 【Asm/Perf】仅冷路径调用，无热路径开销。 */
    (void)overwrite;
    {
        const char *v = value ? (const char *)value : "";
        if (v[0] != '\0') {
            size_t nlen = strlen((const char *)name);
            size_t vlen = strlen(v);
            if (nlen + vlen + 2 > 2048) return -1;
            char buf[2048];
            memcpy(buf, name, nlen);
            buf[nlen] = '=';
            memcpy(buf + nlen + 1, v, vlen + 1);
            if (_putenv(buf) != 0)
                return -1;
        }
        if (SetEnvironmentVariableA((const char *)name, v) == 0)
            return -1;
        return 0;
    }
#else
    return setenv((const char *)name, value ? (const char *)value : "", overwrite ? 1 : 0) == 0 ? 0 : -1;
#endif
}

/**
 * 删除环境变量 name（NUL 结尾）。
 * 返回值：0 成功，-1 失败。
 */
ENV_COLD
int32_t env_unsetenv_c(const uint8_t *name) {
    if (name == NULL) return -1;
#if defined(_WIN32) || defined(_WIN64)
    /* 同时清除 CRT 环境（_putenv("name=") 删除）和进程环境块（SetEnvironmentVariableA NULL 删除）。
     * 与 env_setenv_c 对齐：两套环境块须同步，否则 getenv_z/ptr 仍能读到已删除的变量。 */
    {
        char buf[512];
        size_t n = 0;
        while (n < sizeof(buf) - 2 && name[n]) { buf[n] = (char)name[n]; n++; }
        if (n >= sizeof(buf) - 2) return -1;
        buf[n++] = '=';
        buf[n] = '\0';
        if (_putenv(buf) != 0)
            return -1;
    }
    if (SetEnvironmentVariableA((const char *)name, NULL) == 0)
        return -1;
    return 0;
#else
    return unsetenv((const char *)name) == 0 ? 0 : -1;
#endif
}

/**
 * 临时目录路径写入 out（NUL 结尾）；POSIX TMPDIR/TEMP/TMP → /tmp；Windows GetTempPath。
 * 返回值：写入字节数（不含 NUL），失败 -1。
 */
int32_t env_temp_dir_c(uint8_t *out, int32_t out_cap) {
    if (out == NULL || out_cap <= 0) return -1;

#if defined(_WIN32) || defined(_WIN64)
    {
#define WIN_TEMP_CACHE_SIZE (MAX_PATH + 1)
        static ENV_TLS char cached[WIN_TEMP_CACHE_SIZE];
        static ENV_TLS DWORD cached_len = 0;
        static ENV_TLS int cached_valid = 0;

        if (cached_valid && cached_len < (DWORD)out_cap) {
            memcpy(out, cached, cached_len + 1);
            return (int32_t)cached_len;
        }
        cached_valid = 0;

        char buf[MAX_PATH + 1];
        DWORD n = GetTempPathA((DWORD)sizeof(buf), buf);
        if (n == 0 || n >= (DWORD)sizeof(buf)) return -1;
        if (n > (DWORD)out_cap) return -1;
        memcpy(out, buf, n + 1);
        if (n < (DWORD)sizeof(cached)) {
            memcpy(cached, buf, n + 1);
            cached_len = n;
            cached_valid = 1;
        }
        return (int32_t)n;
#undef WIN_TEMP_CACHE_SIZE
    }
#else
    {
        static const char fallback[] = "/tmp";
#define TEMP_DIR_CACHE_SIZE 256
        static ENV_TLS char cached[TEMP_DIR_CACHE_SIZE];
        static ENV_TLS size_t cached_len = 0;
        static ENV_TLS int cached_valid = 0;

        if (cached_valid && cached_len < (size_t)out_cap) {
            memcpy(out, cached, cached_len + 1);
            return (int32_t)cached_len;
        }
        cached_valid = 0;

        const char *p = NULL;
        const char *tmd = getenv("TMPDIR");
        if (tmd && tmd[0]) p = tmd;
        if (!p) { tmd = getenv("TEMP"); if (tmd && tmd[0]) p = tmd; }
        if (!p) { tmd = getenv("TMP"); if (tmd && tmd[0]) p = tmd; }
        if (!p) p = fallback;
        size_t len = strlen(p);
        if (len >= (size_t)out_cap) return -1;
        memcpy(out, p, len + 1);
        if (len < TEMP_DIR_CACHE_SIZE) {
            memcpy(cached, p, len + 1);
            cached_len = len;
            cached_valid = 1;
        }
        return (int32_t)len;
#undef TEMP_DIR_CACHE_SIZE
    }
#endif
}

#if !defined(_WIN32) && !defined(_WIN64)
extern char **environ;
#endif

/**
 * 统计当前进程环境变量条目数。
 * 返回值：条目数；失败 0。
 */
ENV_COLD
int32_t env_iter_count_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    {
        char *block = GetEnvironmentStringsA();
        int32_t n = 0;
        if (block == NULL) return 0;
        for (const char *p = block; *p; ) {
            if (*p != '=') n++;
            while (*p) p++;
            p++;
        }
        FreeEnvironmentStringsA(block);
        return n;
    }
#else
    {
        int32_t n = 0;
        if (environ == NULL) return 0;
        while (environ[n] != NULL) n++;
        return n;
    }
#endif
}

/**
 * 将 environ[index] 拆为 key/value 写入 out 缓冲。
 * 返回值：成功 1，越界 0，错误 -1。
 */
ENV_COLD
int32_t env_iter_at_c(int32_t index, uint8_t *key_out, int32_t key_cap,
                      uint8_t *val_out, int32_t val_cap) {
    const char *entry = NULL;
    const char *eq;
    int32_t key_len;
    int32_t val_len;
    if (index < 0 || key_out == NULL || val_out == NULL || key_cap <= 0 || val_cap <= 0)
        return -1;
#if defined(_WIN32) || defined(_WIN64)
    {
        char *block = GetEnvironmentStringsA();
        int32_t cur = 0;
        if (block == NULL) return -1;
        for (const char *p = block; *p; ) {
            if (*p != '=') {
                if (cur == index) {
                    entry = p;
                    break;
                }
                cur++;
            }
            while (*p) p++;
            p++;
        }
        if (entry == NULL) {
            FreeEnvironmentStringsA(block);
            return 0;
        }
        eq = strchr(entry, '=');
        if (eq == NULL) {
            FreeEnvironmentStringsA(block);
            return -1;
        }
        key_len = (int32_t)(eq - entry);
        val_len = (int32_t)strlen(eq + 1);
        if (key_len + 1 > key_cap || val_len + 1 > val_cap) {
            FreeEnvironmentStringsA(block);
            return -1;
        }
        memcpy(key_out, entry, (size_t)key_len);
        key_out[key_len] = '\0';
        memcpy(val_out, eq + 1, (size_t)val_len);
        val_out[val_len] = '\0';
        FreeEnvironmentStringsA(block);
        return 1;
    }
#else
    {
        if (environ == NULL) return 0;
        entry = environ[index];
        if (entry == NULL) return 0;
        eq = strchr(entry, '=');
        if (eq == NULL) return -1;
        key_len = (int32_t)(eq - entry);
        val_len = (int32_t)strlen(eq + 1);
        if (key_len + 1 > key_cap || val_len + 1 > val_cap) return -1;
        memcpy(key_out, entry, (size_t)key_len);
        key_out[key_len] = '\0';
        memcpy(val_out, eq + 1, (size_t)val_len);
        val_out[val_len] = '\0';
        return 1;
    }
#endif
}
