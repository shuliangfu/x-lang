/**
 * runtime_random_fill.c — CSPRNG OS 胶层（F-ZC：自 std/random/random_os_glue.c 迁入）
 *
 * 提供 random_fill_bytes_c：getrandom / getentropy / BCryptGenRandom。
 * random.x 经 extern 调用；与 random.o 一并链入。
 */
#include <stdint.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#include <bcrypt.h>
#include <synchapi.h>
#pragma comment(lib, "bcrypt.lib")
#elif defined(__linux__)
#include <sys/random.h>
#include <errno.h>
#else
#if defined(__APPLE__)
#include <sys/random.h>
#else
#ifndef _WIN32
#include <unistd.h>
#endif
#endif
#include <errno.h>
#ifndef GETENTROPY_MAX
#define GETENTROPY_MAX 256
#endif
#endif

#if defined(_WIN32) || defined(_WIN64)
static INIT_ONCE g_random_init_once = INIT_ONCE_STATIC_INIT;
static BCRYPT_ALG_HANDLE g_random_alg = NULL;

static BOOL CALLBACK random_init_callback(PINIT_ONCE InitOnce, PVOID Parameter, PVOID *Context) {
    (void)InitOnce;
    (void)Parameter;
    BCRYPT_ALG_HANDLE alg = NULL;
    NTSTATUS st = BCryptOpenAlgorithmProvider(&alg, BCRYPT_RNG_ALGORITHM, NULL, 0);
    if (st != 0 || !alg) return FALSE;
    *(BCRYPT_ALG_HANDLE *)Context = alg;
    return TRUE;
}

/** Windows：懒初始化 BCrypt RNG 算法句柄；失败返回 NULL。 */
static BCRYPT_ALG_HANDLE random_get_alg(void) {
    if (!InitOnceExecuteOnce(&g_random_init_once, random_init_callback, NULL, (PVOID *)&g_random_alg))
        return NULL;
    return g_random_alg;
}
#endif

/**
 * 向 buf 写入 len 字节密码学安全随机数。
 * 参数：buf 输出缓冲；len 字节数（≥0）。
 * 返回值：成功 len，失败 -1（部分写入时返回已写字节数）。
 */
int32_t random_fill_bytes_c(uint8_t *buf, int32_t len) {
    if (!buf || len < 0) return -1;
    if (len == 0) return 0;

#if defined(_WIN32) || defined(_WIN64)
    {
        BCRYPT_ALG_HANDLE alg = random_get_alg();
        if (!alg) return -1;
        return (BCryptGenRandom(alg, buf, (ULONG)(size_t)len, 0) == 0) ? len : -1;
    }
#elif defined(__linux__)
    {
        size_t done = 0;
        size_t want = (size_t)len;
        while (done < want) {
            ssize_t n = getrandom(buf + done, want - done, 0);
            if (n < 0) {
                if (errno == EINTR) continue;
                return (int32_t)(done > 0 ? (int32_t)done : -1);
            }
            done += (size_t)n;
        }
        return len;
    }
#else
    {
        size_t done = 0;
        size_t total = (size_t)len;
        while (done < total) {
            size_t chunk = total - done;
            if (chunk > (size_t)GETENTROPY_MAX) chunk = (size_t)GETENTROPY_MAX;
            if (getentropy(buf + done, chunk) != 0)
                return (int32_t)(done > 0 ? (int32_t)done : -1);
            done += chunk;
        }
        return len;
    }
#endif
}
