/**
 * std/uuid/uuid.c — UUID v4/v7 生成、解析、格式化（STD-075）
 *
 * 【文件职责】
 * 128-bit UUID 布局；v4（CSPRNG）、v7（Unix 毫秒 + 随机）；
 * 标准字符串 parse/format（连字符可选、大小写不敏感）；相等比较。
 *
 * 【依赖】std/random/random.c、std/time/time.c 符号。
 */

#include <stdint.h>
#include <stdio.h>
#include <string.h>

extern int random_fill_bytes_c(uint8_t *buf, int32_t len);
extern int64_t time_now_wall_ms_c(void);

/** 上次 v7 生成的 Unix 毫秒；同毫秒内用 uuid_v7_seq 单调递增 rand_a。 */
static int64_t uuid_v7_last_ms = -1;
static uint16_t uuid_v7_seq = 0;

/** 十六进制字符 → 数值；-1 非法。 */
static int uuid_hex_val(uint8_t c) {
    if (c >= (uint8_t)'0' && c <= (uint8_t)'9') return (int)(c - (uint8_t)'0');
    if (c >= (uint8_t)'a' && c <= (uint8_t)'f') return (int)(c - (uint8_t)'a' + 10);
    if (c >= (uint8_t)'A' && c <= (uint8_t)'F') return (int)(c - (uint8_t)'A' + 10);
    return -1;
}

/** 写入 UUID v4 随机版本与 variant 位。 */
static void uuid_apply_v4_variant(uint8_t *u) {
    u[6] = (uint8_t)((u[6] & 0x0Fu) | 0x40u);
    u[8] = (uint8_t)((u[8] & 0x3Fu) | 0x80u);
}

/** 生成 UUID v4；成功 0，随机失败 -1。 */
int uuid_new_v4_c(uint8_t *out) {
    if (!out) return -1;
    if (random_fill_bytes_c(out, 16) != 16) return -1;
    uuid_apply_v4_variant(out);
    return 0;
}

/** 生成 UUID v7（48-bit Unix 毫秒 + 12-bit 序号/随机 + 62-bit 随机）；成功 0。 */
int uuid_new_v7_c(uint8_t *out) {
    int64_t ms;
    uint16_t rand_a;
    uint8_t tail[8];
    if (!out) return -1;
    ms = time_now_wall_ms_c();
    if (ms < 0) ms = 0;
    if (ms == uuid_v7_last_ms) {
        uuid_v7_seq = (uint16_t)((uuid_v7_seq + 1u) & 0x0FFFu);
        if (uuid_v7_seq == 0u) {
            /* 同毫秒序号溢出：自旋至下一毫秒（RFC 9562 单调性） */
            while (ms == uuid_v7_last_ms) {
                ms = time_now_wall_ms_c();
                if (ms < 0) ms = 0;
            }
            uuid_v7_last_ms = ms;
            if (random_fill_bytes_c((uint8_t *)&rand_a, 2) != 2) return -1;
            rand_a &= 0x0FFFu;
            uuid_v7_seq = rand_a;
        } else {
            rand_a = uuid_v7_seq;
        }
    } else {
        uuid_v7_last_ms = ms;
        if (random_fill_bytes_c((uint8_t *)&rand_a, 2) != 2) return -1;
        rand_a &= 0x0FFFu;
        uuid_v7_seq = rand_a;
    }
    out[0] = (uint8_t)((ms >> 40) & 0xFF);
    out[1] = (uint8_t)((ms >> 32) & 0xFF);
    out[2] = (uint8_t)((ms >> 24) & 0xFF);
    out[3] = (uint8_t)((ms >> 16) & 0xFF);
    out[4] = (uint8_t)((ms >> 8) & 0xFF);
    out[5] = (uint8_t)(ms & 0xFF);
    out[6] = (uint8_t)(0x70u | ((rand_a >> 8) & 0x0Fu));
    out[7] = (uint8_t)(rand_a & 0xFFu);
    if (random_fill_bytes_c(tail, 8) != 8) return -1;
    out[8] = (uint8_t)((tail[0] & 0x3Fu) | 0x80u);
    memcpy(out + 9, tail + 1, 7);
    return 0;
}

/** 解析 UUID 字符串（36 带连字符或 32 纯 hex）；成功 0。 */
int uuid_parse_c(const uint8_t *ptr, int32_t len, uint8_t *out) {
    int i;
    int pos = 0;
    int digit = 0;
    int hi;
    if (!ptr || !out || len <= 0) return -1;
    for (i = 0; i < 16; i++) {
        if (pos < len && ptr[pos] == (uint8_t)'-') pos++;
        if (pos + 1 >= len) return -1;
        hi = uuid_hex_val(ptr[pos]);
        if (hi < 0) return -1;
        digit = hi * 16;
        hi = uuid_hex_val(ptr[pos + 1]);
        if (hi < 0) return -1;
        digit += hi;
        out[i] = (uint8_t)digit;
        pos += 2;
    }
    while (pos < len && ptr[pos] == (uint8_t)'-') pos++;
    if (pos != len) return -1;
    return 0;
}

/** 格式化为标准小写连字符形式；返回 36，失败 -1。 */
int uuid_format_c(const uint8_t *u, uint8_t *out, int32_t out_cap) {
    int n;
    if (!u || !out || out_cap < 37) return -1;
    n = snprintf((char *)out, (size_t)out_cap,
                 "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
                 u[0], u[1], u[2], u[3], u[4], u[5], u[6], u[7],
                 u[8], u[9], u[10], u[11], u[12], u[13], u[14], u[15]);
    if (n != 36) return -1;
    return 36;
}

/** 128-bit 相等：1 相等，0 不等。 */
int uuid_eq_c(const uint8_t *a, const uint8_t *b) {
    int i;
    if (!a || !b) return 0;
    for (i = 0; i < 16; i++) {
        if (a[i] != b[i]) return 0;
    }
    return 1;
}

/** 取版本号 nibble（4/7/等）；非法布局仍返回位值。 */
int32_t uuid_version_c(const uint8_t *u) {
    if (!u) return -1;
    return (int32_t)((u[6] >> 4) & 0x0F);
}

/** C 烟测：已知向量 parse/format/eq/v4/v7。 */
int uuid_smoke_c(void) {
    static const uint8_t known[] = "550e8400-e29b-41d4-a716-446655440000";
    uint8_t u[16];
    uint8_t buf[40];
    uint8_t v4[16];
    uint8_t v7[16];
    if (uuid_parse_c(known, 36, u) != 0) return 1;
    if (uuid_format_c(u, buf, 40) != 36) return 2;
    if (memcmp(buf, "550e8400-e29b-41d4-a716-446655440000", 36) != 0) return 3;
    if (uuid_eq_c(u, u) != 1) return 4;
    {
        static const uint8_t plain[] = "550e8400e29b41d4a716446655440000";
        uint8_t u2[16];
        if (uuid_parse_c(plain, 32, u2) != 0) return 5;
        if (uuid_eq_c(u, u2) != 1) return 6;
    }
    if (uuid_new_v4_c(v4) != 0) return 7;
    if (uuid_version_c(v4) != 4) return 8;
    if (uuid_new_v7_c(v7) != 0) return 9;
    if (uuid_version_c(v7) != 7) return 10;
    {
        uint8_t v7b[16];
        if (uuid_new_v7_c(v7b) != 0) return 11;
        if (memcmp(v7, v7b, 16) >= 0) return 12;
    }
    {
        int k;
        uint8_t prev[16];
        memcpy(prev, v7, 16);
        for (k = 0; k < 8; k++) {
            uint8_t cur[16];
            if (uuid_new_v7_c(cur) != 0) return 13;
            if (memcmp(prev, cur, 16) >= 0) return 14;
            memcpy(prev, cur, 16);
        }
    }
    return 0;
}
