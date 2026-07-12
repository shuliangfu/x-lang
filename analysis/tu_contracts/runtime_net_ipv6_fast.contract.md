# TU Contract: runtime_net_ipv6_fast

## 1. 当前权威源
- x 源：`src/asm/runtime_net_ipv6_fast.x`
- seed 源：`seeds/runtime_net_ipv6_fast.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 5 个 IMPL wrapper，seed/rest 提供 5 个 `_impl` + 3 个 rest 函数

## 3. 导出符号合同
- thin/.x 导出：6（doc_anchor + 5 wrapper）
- seed/rest 导出：8（5 `_impl` + 3 rest 函数）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- `runtime_net_ipv6_fast_x_doc_anchor`
- `net_ipv6_ensure_wsa_c`（IMPL，调用 `_impl`）
- `net_ipv6_close_socket_c`（IMPL，调用 `_impl`）
- `net_ipv6_set_nonblock_c`（IMPL，调用 `_impl`）
- `net_ipv6_poll_writable_c`（IMPL，调用 `_impl`）
- `net_ipv6_connect_retry_ok_c`（IMPL，调用 `_impl`）

### 3.2 当前仍由 seed/rest 提供
- `net_ipv6_set_addr_port_buf_c`（填充 IPv6 sockaddr_in6）
- `net_ipv6_ensure_wsa_c_impl`（Windows WSAStartup，Unix no-op）
- `net_ipv6_close_socket_c_impl`（关闭 socket，Windows closesocket / Unix close）
- `net_ipv6_set_nonblock_c_impl`（设置非阻塞，Windows ioctlsocket / Unix fcntl）
- `net_ipv6_poll_writable_c_impl`（poll 可写检查，Windows no-op / Unix poll）
- `net_ipv6_connect_retry_ok_c_impl`（连接重试检查，Windows 1 / Unix errno EINPROGRESS/EAGAIN）
- `net_tcp_connect_ipv6_c`（IPv6 TCP 连接，调用 thin wrappers）
- `net_tcp_listen_ipv6_c`（IPv6 TCP 监听，调用 thin wrappers）

## 4. ABI Manifest
- _impl 残余列表：`net_ipv6_ensure_wsa_c_impl`、`net_ipv6_close_socket_c_impl`、`net_ipv6_set_nonblock_c_impl`、`net_ipv6_poll_writable_c_impl`、`net_ipv6_connect_retry_ok_c_impl`
- thin+rest 宏边界：`SHUX_RUNTIME_NET_IPV6_FAST_FROM_X`
- 前向声明：5 个 thin wrapper（`net_ipv6_ensure_wsa_c` / `close_socket_c` / `set_nonblock_c` / `poll_writable_c` / `connect_retry_ok_c`），rest 模式下供 `net_tcp_connect_ipv6_c` + `net_tcp_listen_ipv6_c` 调用，符号由 thin.o 提供
- 内部调用更新：无（rest 函数调用 thin wrapper 符号，rest 模式下为 U 由 thin.o 解析）

## 5. 验证状态
- prove_x_o：ok（.x 生成 + thin.o 编译通过）
- ld -r：ok（macOS merged 14 T + Ubuntu merged 14 T/W，U 仅 libc 符号）
- smoke/probe：pending

## 6. 备注
- IMPL 模式：5 个 thin wrapper 调用对应 `_impl`
- 2 个 rest 函数（`net_tcp_connect_ipv6_c` + `net_tcp_listen_ipv6_c`）调用 5 个 thin wrapper，rest 模式下 thin wrapper 为 U 符号由 thin.o 提供
- 平台条件：`_impl` 函数体内用 `#if defined(_WIN32) || defined(_WIN64)` 分支 Windows/Unix；thin wrapper 在 .x 中无平台条件
- 依赖：Unix 用 errno/fcntl/poll/socket 等系统调用；Windows 用 winsock2（closesocket/ioctlsocket/WSAStartup）
