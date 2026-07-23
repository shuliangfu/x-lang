# TU Contract: runtime_tls_mbedtls_bio

## 1. 当前权威源
- x 源：`src/asm/runtime_tls_mbedtls_bio.x`
- seed 源：`seeds/runtime_tls_mbedtls_bio.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 2 个 IMPL wrapper，seed/rest 提供 2 个 `_impl` + 1 个 bind 函数

## 3. 导出符号合同
- thin/.x 导出：3（doc_anchor + 2 wrapper）
- seed/rest 导出：3（2 `_impl` + 1 `shu_mbedtls_ssl_bind_fd_c`）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- `runtime_tls_mbedtls_bio_x_doc_anchor`
- `shu_mbedtls_bio_send`（IMPL，调用 `_impl`）
- `shu_mbedtls_bio_recv`（IMPL，调用 `_impl`）

### 3.2 当前仍由 seed/rest 提供
- `shu_mbedtls_bio_send_impl`（mbedTLS BIO send，映射 EAGAIN → WANT_WRITE）
- `shu_mbedtls_bio_recv_impl`（mbedTLS BIO recv，EOF/EAGAIN → mbedTLS 错误码）
- `shu_mbedtls_ssl_bind_fd_c`（绑定 ssl 上下文到 TCP fd，取 thin wrapper 地址）

## 4. ABI Manifest
- _impl 残余列表：`shu_mbedtls_bio_send_impl`、`shu_mbedtls_bio_recv_impl`
- thin+rest 宏边界：`XLANG_RUNTIME_TLS_MBEDTLS_BIO_FROM_X`
- 前向声明：`shu_mbedtls_bio_send`、`shu_mbedtls_bio_recv`（rest 模式下供 `shu_mbedtls_ssl_bind_fd_c` 取地址，符号由 thin.o 提供）
- 内部调用更新：无（`shu_mbedtls_ssl_bind_fd_c` 引用 thin wrapper 符号，rest 模式下为 U 由 thin.o 解析）

## 5. 验证状态
- prove_x_o：ok（.x 生成 + thin.o 编译通过）
- ld -r：ok（macOS merged 6 T + Ubuntu merged 6 T/W，0 U）
- smoke/probe：pending

## 6. 备注
- IMPL 模式：2 个 thin wrapper（`shu_mbedtls_bio_send` / `shu_mbedtls_bio_recv`）调用对应 `_impl`
- `shu_mbedtls_ssl_bind_fd_c` 通过函数指针取 `shu_mbedtls_bio_send` / `shu_mbedtls_bio_recv` 地址传给 `mbedtls_ssl_set_bio`，rest 模式下这两个符号由 thin.o 提供
- 平台条件：send/recv/bind 三个函数体在 `#if !defined(_WIN32) && !defined(_WIN64)` 块内（Windows 分支 no-op）；thin wrapper 在 .x 中无平台条件，Windows 下产生未引用的 T + U 对（与 runtime_dynlib_os 同模式，链接器不报错）
- 依赖：`mbedtls/ssl.h` + `errno.h` + `sys/socket.h`（macOS 路径 `/opt/homebrew/opt/mbedtls/include`，Ubuntu 经 `libmbedtls-dev` 安装在 `/usr/include/mbedtls/ssl.h`）
