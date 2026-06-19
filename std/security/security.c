/**
 * std/security/security.c — 应用层安全原语（STD-079）
 *
 * 【文件职责】
 * secure_zero、mlock/munlock（可选）、HKDF-SHA256；
 * 常量时间比较复用 std.crypto；供 mod.sx 与 gate 烟测调用。
 */

#include <stdint.h>
#include <string.h>

#if defined(__linux__) || defined(__APPLE__)
#include <sys/mman.h>
#endif
#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#endif

extern void crypto_hmac_sha256_c(const uint8_t *key, int32_t key_len,
                                 const uint8_t *msg, int32_t msg_len, uint8_t *out);
extern int32_t crypto_mem_eq_c(const uint8_t *a, const uint8_t *b, int32_t len);

#define SEC_SHA256_LEN 32

/** 安全清零：volatile 写避免编译器优化掉。 */
void security_secure_zero_c(uint8_t *p, int32_t len) {
    volatile uint8_t *vp;
    int32_t i;
    if (!p || len <= 0) return;
    vp = (volatile uint8_t *)p;
    for (i = 0; i < len; i++) vp[i] = 0;
}

/** 尝试 mlock；成功 1，不支持或失败 0。 */
int32_t security_mlock_c(uint8_t *p, int32_t len) {
    if (!p || len <= 0) return 0;
#if defined(__linux__) || defined(__APPLE__)
    return mlock(p, (size_t)len) == 0 ? 1 : 0;
#elif defined(_WIN32) || defined(_WIN64)
    return VirtualLock(p, (size_t)len) ? 1 : 0;
#else
    (void)p;
    (void)len;
    return 0;
#endif
}

/** 解除 mlock；成功 1，否则 0。 */
int32_t security_munlock_c(uint8_t *p, int32_t len) {
    if (!p || len <= 0) return 0;
#if defined(__linux__) || defined(__APPLE__)
    return munlock(p, (size_t)len) == 0 ? 1 : 0;
#elif defined(_WIN32) || defined(_WIN64)
    return VirtualUnlock(p, (size_t)len) ? 1 : 0;
#else
    (void)p;
    (void)len;
    return 0;
#endif
}

/** HKDF-Extract：PRK = HMAC(salt, IKM)。 */
static void sec_hkdf_extract(const uint8_t *salt, int32_t salt_len,
                             const uint8_t *ikm, int32_t ikm_len, uint8_t *prk) {
    uint8_t zero_salt[SEC_SHA256_LEN];
    const uint8_t *s = salt;
    int32_t sl = salt_len;
    if (sl <= 0) {
        memset(zero_salt, 0, sizeof(zero_salt));
        s = zero_salt;
        sl = SEC_SHA256_LEN;
    }
    crypto_hmac_sha256_c(s, sl, ikm, ikm_len, prk);
}

/** HKDF-Expand：由 PRK 派生 okm_len 字节 OKM。 */
static int32_t sec_hkdf_expand(const uint8_t *prk, const uint8_t *info, int32_t info_len,
                               uint8_t *okm, int32_t okm_len) {
    uint8_t t[SEC_SHA256_LEN];
    uint8_t block[SEC_SHA256_LEN + 512 + 1];
    int32_t n;
    int32_t off;
    int32_t i;
    int32_t bl;
    int32_t copy;
    if (!prk || !okm || okm_len <= 0) return -1;
    n = (okm_len + SEC_SHA256_LEN - 1) / SEC_SHA256_LEN;
    if (n > 255) return -1;
    off = 0;
    for (i = 1; i <= n; i++) {
        bl = 0;
        if (i > 1) {
            memcpy(block, t, SEC_SHA256_LEN);
            bl = SEC_SHA256_LEN;
        }
        if (info && info_len > 0) {
            if (bl + info_len > (int32_t)sizeof(block) - 1) return -1;
            memcpy(block + bl, info, (size_t)info_len);
            bl += info_len;
        }
        block[bl++] = (uint8_t)i;
        crypto_hmac_sha256_c(prk, SEC_SHA256_LEN, block, bl, t);
        copy = okm_len - off;
        if (copy > SEC_SHA256_LEN) copy = SEC_SHA256_LEN;
        memcpy(okm + off, t, (size_t)copy);
        off += copy;
    }
    return 0;
}

/**
 * HKDF-SHA256（RFC 5869）：salt 可为空（用 HashLen 零 salt）；
 * 成功 0，参数非法 -1。
 */
int32_t security_hkdf_sha256_c(const uint8_t *salt, int32_t salt_len,
                               const uint8_t *ikm, int32_t ikm_len,
                               const uint8_t *info, int32_t info_len,
                               uint8_t *okm, int32_t okm_len) {
    uint8_t prk[SEC_SHA256_LEN];
    if (!ikm || !okm || ikm_len <= 0 || okm_len <= 0) return -1;
    sec_hkdf_extract(salt, salt_len, ikm, ikm_len, prk);
    return sec_hkdf_expand(prk, info, info_len, okm, okm_len);
}

/** C 烟测：HKDF RFC5869 TC1 + secure_zero + mem_eq。 */
int32_t security_smoke_c(void) {
    static const uint8_t ikm[22] = {
        0x0b, 0x0b, 0x0b, 0x0b, 0x0b, 0x0b, 0x0b, 0x0b, 0x0b, 0x0b,
        0x0b, 0x0b, 0x0b, 0x0b, 0x0b, 0x0b, 0x0b, 0x0b, 0x0b, 0x0b,
        0x0b, 0x0b
    };
    static const uint8_t salt[13] = {
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c
    };
    static const uint8_t info[10] = {
        0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9
    };
    static const uint8_t expect[42] = {
        0x3c, 0xb2, 0x5f, 0x25, 0xfa, 0xac, 0xd5, 0x7a, 0x90, 0x43, 0x4f, 0x64, 0xd0, 0x36, 0x2f, 0x2a,
        0x2d, 0x2d, 0x0a, 0x90, 0xcf, 0x1a, 0x5a, 0x4c, 0x5d, 0xb0, 0x2d, 0x56, 0xec, 0xc4, 0xc5, 0xbf,
        0x34, 0x00, 0x72, 0x08, 0xd5, 0xb8, 0x87, 0x18, 0x58, 0x65
    };
    uint8_t okm[42];
    uint8_t buf[8];
    int32_t i;
    if (security_hkdf_sha256_c(salt, 13, ikm, 22, info, 10, okm, 42) != 0) return 1;
    if (crypto_mem_eq_c(okm, expect, 42) != 1) return 2;
    for (i = 0; i < 8; i++) buf[i] = (uint8_t)(i + 1);
    security_secure_zero_c(buf, 8);
    for (i = 0; i < 8; i++) {
        if (buf[i] != 0) return 3;
    }
    return 0;
}
