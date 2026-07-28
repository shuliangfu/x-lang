/* seeds/runtime_random_fill.from_x.c — G-02f-20 product TU
 * G-02f-104 helper gates.
 * Product: runtime_random_fill.o; OS bridge logic in rest C; public wrappers
 * provided by thin runtime_random_fill.x in R2 mode (XLANG_RUNTIME_RANDOM_FILL_FROM_X).
 *
 * runtime_random_fill.c — CSPRNG OS glue (migrated from std/random/random_os_glue.c)
 *
 * [File role] random_fill_bytes_c: getrandom / getentropy / BCryptGenRandom.
 *             random.x calls via extern; linked alongside random.o into exe.
 *
 * Wave514 (2026-07-27): R2 full migration. random_fill_bytes_c business logic
 * moved to .x (thin); this file now provides _impl OS bridge implementations
 * only, with cold-mode fallback wrappers under #ifndef XLANG_RUNTIME_RANDOM_FILL_FROM_X.
 *
 * PLATFORM: SHARED (Windows BCrypt / Linux getrandom / macOS getentropy)
 */

#include <stdint.h>
#include <string.h>

/* Forward declarations for thin-provided _c functions (R2 / FROM_X mode). */
void *random_get_alg(void);
int32_t random_fill_bytes_c(uint8_t *buf, int32_t len);

/* ========== Platform includes ========== */
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
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW.
 * macOS/Linux delegate to system <unistd.h> via #include_next. */
#include <unistd.h>
#endif
#include <errno.h>
#ifndef GETENTROPY_MAX
#define GETENTROPY_MAX 256
#endif
#endif

/* ========== random_get_alg_impl (Windows: BCrypt lazy init; non-Windows: stub) ========== */
#if defined(_WIN32) || defined(_WIN64)
static INIT_ONCE g_random_init_once = INIT_ONCE_STATIC_INIT;
static BCRYPT_ALG_HANDLE g_random_alg = NULL;

BOOL CALLBACK random_init_callback(PINIT_ONCE InitOnce, PVOID Parameter, PVOID *Context) {
    (void)InitOnce;
    (void)Parameter;
    BCRYPT_ALG_HANDLE alg = NULL;
    NTSTATUS st = BCryptOpenAlgorithmProvider(&alg, BCRYPT_RNG_ALGORITHM, NULL, 0);
    if (st != 0 || !alg) return FALSE;
    *(BCRYPT_ALG_HANDLE *)Context = alg;
    return TRUE;
}

BCRYPT_ALG_HANDLE random_get_alg_impl(void) {
    if (!InitOnceExecuteOnce(&g_random_init_once, random_init_callback, NULL, (PVOID *)&g_random_alg))
        return NULL;
    return g_random_alg;
}
#else
/* Non-Windows stub: .x thin wrapper calls random_get_alg_impl regardless of
 * platform; must provide a definition to avoid ld -r undefined reference. */
void *random_get_alg_impl(void) {
    return NULL;
}
#endif

#ifndef XLANG_RUNTIME_RANDOM_FILL_FROM_X
/* Cold mode fallback: public wrapper provided by seed. */
void *random_get_alg(void) {
    return random_get_alg_impl();
}
#endif

/* ========== random_fill_bytes_impl ========== */
int32_t random_fill_bytes_impl(uint8_t *buf, int32_t len) {
    if (!buf || len < 0) return -1;
    if (len == 0) return 0;

#if defined(_WIN32) || defined(_WIN64)
    {
        BCRYPT_ALG_HANDLE alg = random_get_alg_impl();
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

#ifndef XLANG_RUNTIME_RANDOM_FILL_FROM_X
/* Cold mode fallback: public wrapper provided by seed. */
int32_t random_fill_bytes_c(uint8_t *buf, int32_t len) {
    return random_fill_bytes_impl(buf, len);
}
#endif
