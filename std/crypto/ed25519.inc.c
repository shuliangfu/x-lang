/**
 * ed25519.inc.c — STD-126：Ed25519 签名/验签（orlp/ref10，zlib 许可）
 *
 * 源码位于 std/crypto/ed25519/；由 crypto.c #include 链入同一翻译单元。
 * API：public_from_seed / sign / verify / smoke（RFC 8032 TEST 1）。
 */
#ifndef STD_CRYPTO_ED25519_INC_C
#define STD_CRYPTO_ED25519_INC_C

#define ED25519_NO_SEED

#include "ed25519/fixedint.h"
#include "ed25519/fe.c"
#include "ed25519/ge.c"
#include "ed25519/sc.c"
#include "ed25519/sha512.c"
#include "ed25519/keypair.c"
#include "ed25519/sign.c"
#include "ed25519/verify.c"

/** 由 32 字节 seed 导出公钥。 */
void crypto_ed25519_public_from_seed_c(const uint8_t *seed, uint8_t *pub) {
  uint8_t priv[64];
  if (!seed || !pub) {
    return;
  }
  ed25519_create_keypair(pub, priv, seed);
}

/**
 * 使用 seed 对消息签名；sig 写入 64 字节。
 * 成功 0，参数非法 -1。
 */
int32_t crypto_ed25519_sign_c(const uint8_t *seed, const uint8_t *msg, int32_t msg_len, uint8_t *sig) {
  uint8_t pub[32];
  uint8_t priv[64];
  if (!seed || !sig || msg_len < 0) {
    return -1;
  }
  if (msg_len > 0 && !msg) {
    return -1;
  }
  ed25519_create_keypair(pub, priv, seed);
  ed25519_sign(sig, msg, (size_t)msg_len, pub, priv);
  return 0;
}

/**
 * 验签；成功 0，失败 -1。
 * 内部 ed25519_verify 返回 1/0，此处映射为 0/-1。
 */
int32_t crypto_ed25519_verify_c(const uint8_t *pub, const uint8_t *msg, int32_t msg_len, const uint8_t *sig) {
  if (!pub || !sig || msg_len < 0) {
    return -1;
  }
  if (msg_len > 0 && !msg) {
    return -1;
  }
  if (ed25519_verify(sig, msg, (size_t)msg_len, pub) != 1) {
    return -1;
  }
  return 0;
}

/** RFC 8032 TEST 1（空消息）C 烟测；0 通过。 */
int32_t crypto_ed25519_smoke_c(void) {
  /* RFC 8032 §7.1 TEST 1（空消息）— secret / public / signature 向量。 */
  static const uint8_t seed[32] = {
      0x9d, 0x61, 0xb1, 0x9d, 0xef, 0xfd, 0x5a, 0x60, 0xba, 0x84, 0x4a, 0xf4, 0x92, 0xec, 0x2c, 0xc4,
      0x44, 0x49, 0xc5, 0x69, 0x7b, 0x32, 0x69, 0x19, 0x70, 0x3b, 0xac, 0x03, 0x1c, 0xae, 0x7f, 0x60};
  static const uint8_t expect_pub[32] = {
      0xd7, 0x5a, 0x98, 0x01, 0x82, 0xb1, 0x0a, 0xb7, 0xd5, 0x4b, 0xfe, 0xd3, 0xc9, 0x64, 0x07, 0x3a,
      0x0e, 0xe1, 0x72, 0xf3, 0xda, 0xa6, 0x23, 0x25, 0xaf, 0x02, 0x1a, 0x68, 0xf7, 0x07, 0x51, 0x1a};
  static const uint8_t expect_sig[64] = {
      0xe5, 0x56, 0x43, 0x00, 0xc3, 0x60, 0xac, 0x72, 0x90, 0x86, 0xe2, 0xcc, 0x80, 0x6e, 0x82, 0x8a,
      0x84, 0x87, 0x7f, 0x1e, 0xb8, 0xe5, 0xd9, 0x74, 0xd8, 0x73, 0xe0, 0x65, 0x22, 0x49, 0x01, 0x55,
      0x5f, 0xb8, 0x82, 0x15, 0x90, 0xa3, 0x3b, 0xac, 0xc6, 0x1e, 0x39, 0x70, 0x1c, 0xf9, 0xb4, 0x6b,
      0xd2, 0x5b, 0xf5, 0xf0, 0x59, 0x5b, 0xbe, 0x24, 0x65, 0x51, 0x41, 0x43, 0x8e, 0x7a, 0x10, 0x0b};
  uint8_t pub[32];
  uint8_t sig[64];
  crypto_ed25519_public_from_seed_c(seed, pub);
  if (crypto_mem_eq_c(pub, expect_pub, 32) != 1) {
    return 1;
  }
  if (crypto_ed25519_sign_c(seed, 0, 0, sig) != 0) {
    return 2;
  }
  if (crypto_mem_eq_c(sig, expect_sig, 64) != 1) {
    return 3;
  }
  if (crypto_ed25519_verify_c(pub, 0, 0, sig) != 0) {
    return 4;
  }
  sig[0] ^= 1;
  if (crypto_ed25519_verify_c(pub, 0, 0, sig) != -1) {
    return 5;
  }
  return 0;
}

#endif /* STD_CRYPTO_ED25519_INC_C */
