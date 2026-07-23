# TU Contract: runtime_net_udp_batch

## 1. 当前权威源
- x 源：`src/asm/runtime_net_udp_batch.x`
- seed 源：`seeds/runtime_net_udp_batch.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 2 个 IMPL wrapper，seed/rest 提供 2 个 `_impl` + 4 个 weak API 函数

## 3. 导出符号合同
- thin/.x 导出：3（doc_anchor + 2 wrapper）
- seed/rest 导出：6（2 `_impl` + 4 weak API 函数）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- `runtime_net_udp_batch_x_doc_anchor`
- `shu_udp_batch_set_addr_port`（IMPL，调用 `_impl`）
- `shu_udp_batch_poll_readable`（IMPL，调用 `_impl`）

### 3.2 当前仍由 seed/rest 提供
- `shu_udp_batch_set_addr_port_impl`（填充 IPv4 sockaddr_in）
- `shu_udp_batch_poll_readable_impl`（poll 可读检查）
- `shu_net_udp_recvmmsg2_c`（weak，Linux recvmmsg 2 段）
- `shu_net_udp_sendmmsg2_c`（weak，Linux sendmmsg 2 条）
- `shu_net_udp_recvmmsg_buf_c`（weak，Linux recvmmsg Buffer 切片）
- `shu_net_udp_sendmmsg_buf_c`（weak，Linux sendmmsg Buffer 切片）

## 4. ABI Manifest
- _impl 残余列表：`shu_udp_batch_set_addr_port_impl`、`shu_udp_batch_poll_readable_impl`
- thin+rest 宏边界：`XLANG_RUNTIME_NET_UDP_BATCH_FROM_X`
- 前向声明：`shu_udp_batch_set_addr_port`、`shu_udp_batch_poll_readable`（rest 模式下供 4 个 weak API 函数调用，符号由 thin.o 提供）
- 内部调用更新：无（4 个 weak API 函数调用 thin wrapper 符号，rest 模式下为 U 由 thin.o 解析）

## 5. 验证状态
- prove_x_o：ok（.x 生成 + thin.o 编译通过）
- ld -r：ok（macOS merged 3 T + 2 U + Ubuntu merged 3 W + 2 U）
- smoke/probe：pending

## 6. 备注
- IMPL 模式：2 个 thin wrapper 调用对应 `_impl`
- 4 个 weak API 函数（`shu_net_udp_recvmmsg2_c` 等）调用 thin wrapper（`shu_udp_batch_set_addr_port` / `shu_udp_batch_poll_readable`），rest 模式下 thin wrapper 为 U 符号由 thin.o 提供
- ⚠️ 预存 bug（非本次切割引入）：seed 第 13 行 `#if defined(__linux__) && defined(__GLIBC__)` 在 `#include` 之前检查，但 `__GLIBC__` 由 glibc 头文件（`<features.h>`）定义而非 gcc 预定义宏。导致 seed 在 Ubuntu 上编译为空 .o（生产构建同样受影响）。`_impl` 和 4 个 weak API 函数在 Ubuntu 上从未被实际定义。thin wrapper 调用 `_impl` 产生 U 符号，但 wrapper 在非 Linux 平台不被引用，链接器不报错。修复需将 `#if` 检查移到 includes 之后或仅检查 `__linux__`，但属独立 issue，不在本次 thin+rest 切割范围内
- 平台条件：整个 seed 主体在 `#if defined(__linux__) && defined(__GLIBC__)` 块内；thin wrapper 在 .x 中无平台条件，非 Linux 平台产生未引用的 T + U 对（与 runtime_dynlib_os / runtime_tls_mbedtls_bio 同模式）
