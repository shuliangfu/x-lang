# TU Contract: runtime_crypto_inc_glue

## 1. 当前权威源
- x 源：`src/asm/runtime_crypto_inc_glue.x`
- seed 源：`seeds/runtime_crypto_inc_glue.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 6 个 wrapper（1 IMPL + 5 DIRECT），seed/rest 提供 _impl + 10 个 crypto 函数

## 3. 导出符号合同
- thin/.x 导出：7（doc_anchor + 6 wrapper）
- seed/rest 导出：11（1 _impl + 10 rest 函数）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- `runtime_crypto_inc_glue_x_doc_anchor`
- `shu_sha256_block`（IMPL，调用 `_impl`）
- `shu_sha256_rotr32`（DIRECT）
- `shu_sha256_ch`（DIRECT）⚠️ .x 编译器未生成（已知限制）
- `shu_sha256_maj`（DIRECT）
- `crypto_i32_sub_c`（DIRECT）
- `crypto_rotl32_c`（DIRECT）

### 3.2 当前仍由 seed/rest 提供
- `shu_sha256_block_impl`（SHA-256 块处理，调用 thin helpers）
- `crypto_sha256_c`（SHA-256 摘要）
- `crypto_hmac_sha256_c`（HMAC-SHA256）
- `crypto_sha512_c`（SHA-512，委托 sha512()）
- `crypto_hmac_sha512_c`（HMAC-SHA512）
- `crypto_rotr32_c`（u32 右旋转）
- `crypto_aes_sbox_byte_c`（AES S-box 查表）
- `crypto_aes_rcon_byte_c`（AES Rcon 查表）
- `crypto_chacha_sigma_byte_c`（ChaCha sigma 查表）
- `crypto_sha256_k256_c`（SHA-256 K256 常量查表）
- `crypto_block16_fill_c`（16 字节对齐填充）

## 4. ABI Manifest
- _impl 残余列表：`shu_sha256_block_impl`
- thin+rest 宏边界：`SHUX_RUNTIME_CRYPTO_INC_GLUE_FROM_X`
- 前向声明：`shu_sha256_rotr32`, `shu_sha256_ch`, `shu_sha256_maj`（rest 模式下供 `_impl` 调用）
- 内部调用更新：`crypto_sha256_c` 中 3 处 `shu_sha256_block` → `shu_sha256_block_impl`

## 5. 验证状态
- prove_x_o：ok
- ld -r：ok（macOS merged 17 T + Ubuntu rest 11 T）
- smoke/probe：pending

## 6. 备注
- 混合模式：1 IMPL wrapper（`shu_sha256_block` 调用 `_impl`）+ 5 DIRECT wrapper（直接实现）
- `shu_sha256_block_impl` 调用 3 个 DIRECT thin helpers（rotr32/ch/maj），rest 模式下为 U 符号由 thin.o 提供
- ⚠️ 已知限制：.x 编译器未生成 `shu_sha256_ch`（可能内联），rest 模式下 merged.o 中 `shu_sha256_ch` 为 U 符号。完整模式下 seed 提供 `shu_sha256_ch`（#ifndef 块内），产品构建不受影响。Phase 3/4 需修复 .x 编译器
- `crypto_sha512_c` 调用外部 `sha512()`（由 ed25519_ref10_glue.c 提供）
