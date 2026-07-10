/* seeds/runtime_ed25519_ref10_glue.from_x.c — G-02f-20 product TU
 * Product: runtime_ed25519_ref10_glue.o; logic still C until full .x port.
 */
/**
 * ed25519_ref10_glue.c — F-04 v19：Ed25519 ref10 曲线运算胶层（orlp/zlib）
 *
 * 【文件职责】
 * 链入 compiler/src/asm/crypto/ed25519/ 下 fe/ge/sc/sha512/keypair/sign/verify 为同一翻译单元；
 * 对外 C ABI（public_from_seed/sign/verify/smoke）见 ed25519.x。
 *
 * 【分层】
 * - ed25519.x：mod.x 可见 crypto_ed25519_* C ABI + RFC 8032 烟测
 * - 本文件：ref10 实现（后续 v20 可分批迁 .x）
 *
 * 【构建】ld -r 与 ed25519_main.o、crypto_main.o 等合并为 crypto.o
 */

#define ED25519_NO_SEED

/*
 * 【Why】std/crypto/mod.x 导出高层 API ed25519_sign/verify（种子签名包装），
 * 与 ref10 底层 C ABI 同名会与 crypto.o 强符号冲突（duplicate _ed25519_sign）。
 * 底层导出统一为 ed25519_ref10_*，仅 ed25519.x 通过 extern 调用。
 */
#define ed25519_create_keypair ed25519_ref10_create_keypair
#define ed25519_sign ed25519_ref10_sign
#define ed25519_sign_open ed25519_ref10_sign_open
#define ed25519_verify ed25519_ref10_verify
#define ed25519_keygen ed25519_ref10_keygen
/* 避免与 std/crypto 高层 sha512/hmac_sha512 符号冲突 */
#define sha512 ed25519_ref10_sha512
#define sha512_init ed25519_ref10_sha512_init
#define sha512_update ed25519_ref10_sha512_update
#define sha512_final ed25519_ref10_sha512_final
#define sha512_compress ed25519_ref10_sha512_compress

#include "crypto/ed25519/fixedint.h"
#include "crypto/ed25519/sha512.inc"
#include "crypto/ed25519/fe.inc"
#include "crypto/ed25519/ge.inc"
#include "crypto/ed25519/sc.inc"
#include "crypto/ed25519/keypair.inc"
#include "crypto/ed25519/sign.inc"
#include "crypto/ed25519/verify.inc"

/*
 * 兼容旧 crypto.o：mod.x 高层占用 ed25519_sign/verify 名；底层为 ed25519_ref10_*。
 * 旧 ed25519.x 编译体仍 U 引用 ed25519_create_keypair → 在此提供兼容别名。
 */
#undef ed25519_create_keypair
#undef ed25519_sign
#undef ed25519_verify
void ed25519_create_keypair(unsigned char *public_key, unsigned char *private_key,
                            const unsigned char *seed) {
  ed25519_ref10_create_keypair(public_key, private_key, seed);
}
