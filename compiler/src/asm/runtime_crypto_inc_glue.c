/**
 * crypto_inc_glue.c — F-04 v19 v1：std.crypto C 胶层
 *
 * 【文件职责】
 * SHA-512 / HMAC-SHA512 委托 ed25519/sha512.c（via ed25519_ref10_glue.c 同 crypto.o 单元）。
 *
 * 【分层】
 * - core.x：mem_eq、SHA-256、HMAC-SHA256
 * - aes_gcm.x：AES-128-GCM seal/open
 * - chacha20_poly1305.x：ChaCha20-Poly1305 AEAD
 * - ed25519.x：Ed25519 C ABI + 烟测
 * - ed25519_ref10_glue.c：ref10 fe/ge/sc/sha512/sign/verify
 * - 本文件：crypto_sha512_c / crypto_hmac_sha512_c
 * - seed asm 辅助：rotr/rotl、AES S-box/Rcon、ChaCha sigma 查表（避免 .x 全局数组下标与字面量减法 emit 失败）
 *
 * 【构建】ld -r glue.o + *_main.o → crypto.o
 */

#include <stdint.h>
#include <string.h>

#if defined(__GNUC__) || defined(__clang__)
#define CRYPTO_HOT __attribute__((hot))
#else
#define CRYPTO_HOT
#endif

#define IPAD 0x36
#define OPAD 0x5c

/** 下列 helper 定义在本文件后部；须前向声明供 SHA-256 静态函数使用。 */
uint32_t crypto_rotr32_c(uint32_t x, uint32_t n);
uint32_t crypto_rotl32_c(uint32_t x, uint32_t n);
uint32_t crypto_sha256_k256_c(int32_t i);

/** i32 减法 a - b；seed asm 字面量减变量 emit 失败（如 64 - klen）。 */
int32_t crypto_i32_sub_c(int32_t a, int32_t b) {
  return a - b;
}

/* ---------- SHA-256 / HMAC-SHA256（seed asm 单文件仅首函数可 emit；完整实现放 C） ---------- */

static uint32_t shu_sha256_rotr32(uint32_t x, uint32_t n) {
  return crypto_rotr32_c(x, n);
}

static uint32_t shu_sha256_ch(uint32_t x, uint32_t y, uint32_t z) {
  return (x & y) ^ ((~x) & z);
}

static uint32_t shu_sha256_maj(uint32_t x, uint32_t y, uint32_t z) {
  return (x & y) ^ (x & z) ^ (y & z);
}

static void shu_sha256_block(uint32_t *H, const uint8_t *block) {
  uint32_t W[64];
  int i;
  for (i = 0; i < 16; i++) {
    size_t bi = (size_t)(i * 4);
    W[i] = ((uint32_t)block[bi] << 24) | ((uint32_t)block[bi + 1] << 16)
         | ((uint32_t)block[bi + 2] << 8) | (uint32_t)block[bi + 3];
  }
  for (i = 16; i < 64; i++) {
    uint32_t w2 = W[i - 2];
    uint32_t w7 = W[i - 7];
    uint32_t w15 = W[i - 15];
    uint32_t w16 = W[i - 16];
    uint32_t s0 = shu_sha256_rotr32(w15, 7) ^ shu_sha256_rotr32(w15, 18) ^ (w15 >> 3);
    uint32_t s1 = shu_sha256_rotr32(w2, 17) ^ shu_sha256_rotr32(w2, 19) ^ (w2 >> 10);
    W[i] = s1 + w7 + s0 + w16;
  }
  uint32_t a = H[0], b = H[1], c = H[2], d = H[3];
  uint32_t e = H[4], f = H[5], g = H[6], h = H[7];
  for (i = 0; i < 64; i++) {
    uint32_t t1 = h + (shu_sha256_rotr32(e, 6) ^ shu_sha256_rotr32(e, 11) ^ shu_sha256_rotr32(e, 25))
                + shu_sha256_ch(e, f, g) + crypto_sha256_k256_c(i) + W[i];
    uint32_t t2 = (shu_sha256_rotr32(a, 2) ^ shu_sha256_rotr32(a, 13) ^ shu_sha256_rotr32(a, 22))
                + shu_sha256_maj(a, b, c);
    h = g; g = f; f = e; e = d + t1;
    d = c; c = b; b = a; a = t1 + t2;
  }
  H[0] += a; H[1] += b; H[2] += c; H[3] += d;
  H[4] += e; H[5] += f; H[6] += g; H[7] += h;
}

CRYPTO_HOT
void crypto_sha256_c(const uint8_t * restrict msg, int32_t len, uint8_t * restrict out) {
  uint32_t H[8];
  uint8_t block[64];
  uint64_t total_bits;
  const uint8_t *p;
  int32_t rem;
  int32_t pad_len;
  int hi;
  if (!out || len < 0) {
    if (out) {
      memset(out, 0, 32);
    }
    return;
  }
  H[0] = 0x6a09e667u; H[1] = 0xbb67ae85u; H[2] = 0x3c6ef372u; H[3] = 0xa54ff53au;
  H[4] = 0x510e527fu; H[5] = 0x9b05688cu; H[6] = 0x1f83d9abu; H[7] = 0x5be0cd19u;
  total_bits = (uint64_t)len * 8u;
  p = msg;
  rem = len;
  while (rem >= 64) {
    shu_sha256_block(H, p);
    p += 64;
    rem -= 64;
  }
  memset(block, 0, sizeof(block));
  if (rem > 0 && p) {
    memcpy(block, p, (size_t)rem);
  }
  pad_len = rem + 1;
  block[rem] = 0x80u;
  if (pad_len > 56) {
    while (pad_len < 64) {
      block[pad_len++] = 0;
    }
    shu_sha256_block(H, block);
    pad_len = 0;
    memset(block, 0, 56);
  } else {
    while (pad_len < 56) {
      block[pad_len++] = 0;
    }
  }
  block[56] = (uint8_t)(total_bits >> 56);
  block[57] = (uint8_t)(total_bits >> 48);
  block[58] = (uint8_t)(total_bits >> 40);
  block[59] = (uint8_t)(total_bits >> 32);
  block[60] = (uint8_t)(total_bits >> 24);
  block[61] = (uint8_t)(total_bits >> 16);
  block[62] = (uint8_t)(total_bits >> 8);
  block[63] = (uint8_t)total_bits;
  shu_sha256_block(H, block);
  for (hi = 0; hi < 8; hi++) {
    out[hi * 4] = (uint8_t)(H[hi] >> 24);
    out[hi * 4 + 1] = (uint8_t)(H[hi] >> 16);
    out[hi * 4 + 2] = (uint8_t)(H[hi] >> 8);
    out[hi * 4 + 3] = (uint8_t)H[hi];
  }
}

CRYPTO_HOT
void crypto_hmac_sha256_c(const uint8_t * restrict key, int32_t key_len,
                          const uint8_t * restrict msg, int32_t msg_len, uint8_t * restrict out) {
  uint8_t kbuf[32];
  uint8_t ko[64];
  uint8_t inner[4160];
  uint8_t outer[96];
  const uint8_t *kptr = key;
  int32_t klen = key_len;
  int i;
  if (!out) {
    return;
  }
  if (key_len > 64) {
    crypto_sha256_c(key, key_len, kbuf);
    kptr = kbuf;
    klen = 32;
  }
  memset(ko, 0, sizeof(ko));
  if (kptr && klen > 0) {
    memcpy(ko, kptr, (size_t)klen);
  }
  if (64 + msg_len > (int32_t)sizeof(inner)) {
    memset(out, 0, 32);
    return;
  }
  for (i = 0; i < 64; i++) {
    inner[i] = ko[i] ^ IPAD;
  }
  if (msg_len > 0 && msg) {
    memcpy(inner + 64, msg, (size_t)msg_len);
  }
  crypto_sha256_c(inner, 64 + msg_len, out);
  for (i = 0; i < 64; i++) {
    outer[i] = ko[i] ^ OPAD;
  }
  memcpy(outer + 64, out, 32);
  crypto_sha256_c(outer, 96, out);
}

/* ed25519_ref10_glue.c 提供 sha512()；须在 Makefile 中与 crypto_inc_glue.o 一并 ld -r。 */
int sha512(const unsigned char *message, size_t message_len, unsigned char *out);

/* ---------- SHA-512 / HMAC-SHA512（LibTomCrypt ref，ed25519/sha512.c） ---------- */

/** SHA-512 摘要；委托 ref10 同单元 sha512()（FIPS 180-4 金样正确）。 */
CRYPTO_HOT
void crypto_sha512_c(const uint8_t * restrict msg, int32_t len, uint8_t * restrict out) {
  if (!out || len < 0) {
    if (out) {
      memset(out, 0, 64);
    }
    return;
  }
  sha512(msg, (size_t)len, out);
}

/** HMAC-SHA512（RFC 4231，block=128）。 */
CRYPTO_HOT
void crypto_hmac_sha512_c(const uint8_t * restrict key, int32_t key_len,
                          const uint8_t * restrict msg, int32_t msg_len, uint8_t * restrict out) {
  uint8_t kbuf[128];
  if (key_len > 128) {
    crypto_sha512_c(key, key_len, kbuf);
    key = kbuf;
    key_len = 64;
  }
  uint8_t ko[128];
  memcpy(ko, key, (size_t)key_len);
  if (key_len < 128) {
    memset(ko + key_len, 0, (size_t)(128 - key_len));
  }
  uint8_t inner[128 + 4096];
  if (128 + msg_len > (int32_t)sizeof(inner)) {
    memset(out, 0, 64);
    return;
  }
  for (int i = 0; i < 128; i++) {
    inner[i] = ko[i] ^ IPAD;
  }
  memcpy(inner + 128, msg, (size_t)msg_len);
  crypto_sha512_c(inner, 128 + msg_len, out);
  uint8_t outer[128 + 64];
  for (int i = 0; i < 128; i++) {
    outer[i] = ko[i] ^ OPAD;
  }
  memcpy(outer + 128, out, 64);
  crypto_sha512_c(outer, 128 + 64, out);
}

/* ---------- seed asm 位旋转与密码学常量查表（F-crypto / G-03 gate） ---------- */

/** u32 右旋转；n 取模 32。 */
uint32_t crypto_rotr32_c(uint32_t x, uint32_t n) {
  n &= 31u;
  return (x >> n) | (x << (32u - n));
}

/** u32 左旋转；n 取模 32。 */
uint32_t crypto_rotl32_c(uint32_t x, uint32_t n) {
  n &= 31u;
  return (x << n) | (x >> (32u - n));
}

/** AES S-box（FIPS-197）；idx 越界返回 0。 */
static const uint8_t k_crypto_aes_sbox[256] = {
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16};

/** AES 密钥扩展 Rcon[0..9]。 */
static const uint8_t k_crypto_aes_rcon[10] = {
    0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36};

/** ChaCha20 sigma 常量块（RFC 7539）。 */
static const uint8_t k_crypto_chacha_sigma[16] = {
    0x65, 0x78, 0x70, 0x61, 0x6e, 0x64, 0x20, 0x33,
    0x32, 0x2d, 0x62, 0x79, 0x74, 0x65, 0x20, 0x6b};

/** AES S-box 单字节查表；idx 须在 0..255。 */
uint8_t crypto_aes_sbox_byte_c(int32_t idx) {
  if (idx < 0 || idx > 255) {
    return 0;
  }
  return k_crypto_aes_sbox[idx];
}

/** AES Rcon 查表；idx 须在 0..9。 */
uint8_t crypto_aes_rcon_byte_c(int32_t idx) {
  if (idx < 0 || idx > 9) {
    return 0;
  }
  return k_crypto_aes_rcon[idx];
}

/** ChaCha sigma 查表；idx 须在 0..15。 */
uint8_t crypto_chacha_sigma_byte_c(int32_t idx) {
  if (idx < 0 || idx > 15) {
    return 0;
  }
  return k_crypto_chacha_sigma[idx];
}

/** SHA-256 轮常量 K256[0..63]（FIPS 180-4）；seed asm 64 路 if-return 会标签补丁失败。 */
static const uint32_t k_crypto_sha256_k256[64] = {
    0x428a2f98u, 0x71374491u, 0xb5c0fbcfu, 0xe9b5dba5u, 0x3956c25bu, 0x59f111f1u, 0x923f82a4u,
    0xab1c5ed5u, 0xd807aa98u, 0x12835b01u, 0x243185beu, 0x550c7dc3u, 0x72be5d74u, 0x80deb1feu,
    0x9bdc06a7u, 0xc19bf174u, 0xe49b69c1u, 0xefbe4786u, 0x0fc19dc6u, 0x240ca1ccu, 0x2de92c6fu,
    0x4a7484aau, 0x5cb0a9dcu, 0x76f988dau, 0x983e5152u, 0xa831c66du, 0xb00327c8u, 0xbf597fc7u,
    0xc6e00bf3u, 0xd5a79147u, 0x06ca6351u, 0x14292967u, 0x27b70a85u, 0x2e1b2138u, 0x4d2c6dfcu,
    0x53380d13u, 0x650a7354u, 0x766a0abbu, 0x81c2c92eu, 0x92722c85u, 0xa2bfe8a1u, 0xa81a664bu,
    0xc24b8b70u, 0xc76c51a3u, 0xd192e819u, 0xd6990624u, 0xf40e3585u, 0x106aa070u, 0x19a4c116u,
    0x1e376c08u, 0x2748774cu, 0x34b0bcb5u, 0x391c0cb3u, 0x4ed8aa4au, 0x5b9cca4fu, 0x682e6ff3u,
    0x748f82eeu, 0x78a5636fu, 0x84c87814u, 0x8cc70208u, 0x90befffau, 0xa4506cebu, 0xbef9a3f7u,
    0xc67178f2u};

uint32_t crypto_sha256_k256_c(int32_t i) {
  if (i < 0 || i > 63) {
    return 0;
  }
  return k_crypto_sha256_k256[i];
}

/** 16 字节块对齐填充长度：16 - (used & 15)；seed asm 字面量减法 emit 失败。 */
int32_t crypto_block16_fill_c(int32_t used) {
  return 16 - (used & 15);
}

/* F-闭合：crypto_mem_eq_c 由 core.x --bare-impl 直接产出裸符号，无需 C 桥桩重导出。 */
