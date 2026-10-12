/* seeds/runtime_ed25519_ref10_glue.from_x.c — G-02f-20 product TU
 *
 * R2 migration architecture (thin + rest):
 *   - thin (.x): #[no_mangle] ed25519_ref10_create_keypair / _sign / _verify
 *     wrappers (no _c suffix to match ed25519.x extern declarations) that
 *     forward to _impl_c bridges (XLANG_RUNTIME_ED25519_REF10_GLUE_FROM_X).
 *   - rest (this file, always compiled): the ref10 implementation (.inc files)
 *     emit *_impl_c symbols via macro rename; sha512 symbols stay as
 *     ed25519_ref10_sha512* (consumed by runtime_crypto_inc_glue.from_x.c, a
 *     C-to-C cross-module reference that does not need .x wrapping).
 *
 * Cold path (no guard): this file provides both the public wrappers + _impl.
 * R2 path: this file provides only the _impl bridges (from .inc); the wrappers
 * come from .x.
 *
 * PLATFORM: SHARED — ref10 is portable C; no OS-specific code.
 */
/**
 * ed25519_ref10_glue.c — F-04 v19：Ed25519 ref10 曲线运算胶层（orlp/zlib）
 *
 * 【文件职责】
 * 链入 compiler/seeds/crypto/ed25519/ 下 fe/ge/sc/sha512/keypair/sign/verify 为同一翻译单元；
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
 *
 * 【R2 migration】宏重命名为 *_impl_c 后缀：.inc 文件发射 *_impl_c 实现
 * 符号；thin (.x) 提供 #[no_mangle] ed25519_ref10_* wrappers 调用 _impl_c。
 * .inc 间无交叉调用这 5 个公开函数（已审计 sign/verify/keypair.inc），
 * 重命名安全。
 */
#define ed25519_create_keypair ed25519_ref10_create_keypair_impl_c
#define ed25519_sign ed25519_ref10_sign_impl_c
#define ed25519_sign_open ed25519_ref10_sign_open_impl_c
#define ed25519_verify ed25519_ref10_verify_impl_c
#define ed25519_keygen ed25519_ref10_keygen_impl_c
/* 避免与 std/crypto 高层 sha512/hmac_sha512 符号冲突。
 * 【R2】sha512 系列保留 ed25519_ref10_sha512* 名（不 wrap 到 .x）：
 * runtime_crypto_inc_glue.from_x.c 是 C 消费者，extern 声明
 * ed25519_ref10_sha512，.inc 直接发射此符号即可链接。 */
#define sha512 ed25519_ref10_sha512
#define sha512_init ed25519_ref10_sha512_init
#define sha512_update ed25519_ref10_sha512_update
#define sha512_final ed25519_ref10_sha512_final
#define sha512_compress ed25519_ref10_sha512_compress

#include "seeds/crypto/ed25519/fixedint.h"
#include "seeds/crypto/ed25519/sha512.inc"
#include "seeds/crypto/ed25519/fe.inc"
#include "seeds/crypto/ed25519/ge.inc"
#include "seeds/crypto/ed25519/sc.inc"
#include "seeds/crypto/ed25519/keypair.inc"
#include "seeds/crypto/ed25519/sign.inc"
#include "seeds/crypto/ed25519/verify.inc"

/* 撤销 5 个 ed25519_* 宏，使下方 wrapper 函数名不被展开。
 * sha512 宏保留（无后续代码引用，但保留以备扩展）。 */
#undef ed25519_create_keypair
#undef ed25519_sign
#undef ed25519_sign_open
#undef ed25519_verify
#undef ed25519_keygen

#ifndef XLANG_RUNTIME_ED25519_REF10_GLUE_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RUNTIME_ED25519_REF10_GLUE_FROM_X removed */
#endif /* !XLANG_RUNTIME_ED25519_REF10_GLUE_FROM_X */

/*
 * 兼容旧 crypto.o：mod.x 高层占用 ed25519_sign/verify 名；底层为 ed25519_ref10_*。
 * 旧 ed25519.x 编译体仍 U 引用 ed25519_create_keypair → 在此提供兼容别名。
 * 【R2】始终编译（不 guard）：别名直接调 _impl_c，冷/R2 路径均可用。 */
void ed25519_create_keypair(unsigned char *public_key, unsigned char *private_key,
                            const unsigned char *seed) {
  ed25519_ref10_create_keypair_impl_c(public_key, private_key, seed);
}
