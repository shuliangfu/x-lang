# TU Contract: runtime_net_sock_fast

## 1. 当前权威源
- x 源：`src/asm/runtime_net_sock_fast.x`
- seed 源：`seeds/runtime_net_sock_fast.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 2 个 wrapper，seed/rest 提供 _impl + 4 个全平台函数

## 3. 导出符号合同
- thin/.x 导出：3（doc_anchor + net_ensure_wsa + net_wsa_ctor）
- seed/rest 导出：6（2 _impl [Windows] + 4 全平台函数）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- `runtime_net_sock_fast_x_doc_anchor`
- `net_ensure_wsa`
- `net_wsa_ctor`

### 3.2 当前仍由 seed/rest 提供
- `net_ensure_wsa_impl`（Windows only）
- `net_wsa_ctor_impl`（Windows only，带 constructor 属性）
- `net_set_blocking_c`（全平台）
- `net_close_socket_c`（全平台）
- `net_tcp_listen_c`（全平台）
- `net_udp_bind_c`（全平台）

## 4. ABI Manifest
- _impl 残余列表：`net_ensure_wsa_impl`, `net_wsa_ctor_impl`
- thin+rest 宏边界：`XLANG_RUNTIME_NET_SOCK_FAST_FROM_X`
- constructor 属性：`net_wsa_ctor_impl` 保留 `__attribute__((constructor(65534)))`，main 前自动执行

## 5. 验证状态
- prove_x_o：ok
- ld -r：ok（macOS 7 T + Ubuntu rest 4 T）
- smoke/probe：pending

## 6. 备注
- IMPL 模式：.x wrapper 调用 `_impl`，seed 重命名 2 个函数为 `_impl`
- 内部调用点 `net_wsa_ctor_impl` 更新为调用 `net_ensure_wsa_impl`（避免循环）
- `net_ensure_wsa`/`_impl` 和 `net_wsa_ctor`/`_impl` 仅 Windows 有定义；.x thin wrapper 在非 Windows 平台引用 `_impl`（U 符号），但不被引用故不影响链接
