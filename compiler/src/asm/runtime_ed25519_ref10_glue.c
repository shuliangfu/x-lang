/**
 * ed25519_ref10_glue.c — F-04 v19：Ed25519 ref10 曲线运算胶层（orlp/zlib）
 *
 * 【文件职责】
 * 链入 compiler/src/asm/crypto/ed25519/ 下 fe/ge/sc/sha512/keypair/sign/verify 为同一翻译单元；
 * 对外 C ABI（public_from_seed/sign/verify/smoke）见 ed25519.sx。
 *
 * 【分层】
 * - ed25519.sx：mod.sx 可见 crypto_ed25519_* C ABI + RFC 8032 烟测
 * - 本文件：ref10 实现（后续 v20 可分批迁 .sx）
 *
 * 【构建】ld -r 与 ed25519_main.o、crypto_main.o 等合并为 crypto.o
 */

#define ED25519_NO_SEED

#include "crypto/ed25519/fixedint.h"
#include "crypto/ed25519/sha512.c"
#include "crypto/ed25519/fe.c"
#include "crypto/ed25519/ge.c"
#include "crypto/ed25519/sc.c"
#include "crypto/ed25519/keypair.c"
#include "crypto/ed25519/sign.c"
#include "crypto/ed25519/verify.c"
