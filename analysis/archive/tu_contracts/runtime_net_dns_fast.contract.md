# TU Contract: runtime_net_dns_fast

## 1. 当前权威源
- x 源：`src/asm/runtime_net_dns_fast.x`
- seed 源：`seeds/runtime_net_dns_fast.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 3 个 wrapper，seed/rest 提供 _impl + 3 个全平台函数

## 3. 导出符号合同
- thin/.x 导出：4（doc_anchor + net_dns_ai_addconfig_c + net_dns_map_gai_error_c + net_dns_ensure_wsa_c）
- seed/rest 导出：6（3 _impl + 3 全平台 resolver 函数）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- `runtime_net_dns_fast_x_doc_anchor`
- `net_dns_ai_addconfig_c`
- `net_dns_map_gai_error_c`
- `net_dns_ensure_wsa_c`

### 3.2 当前仍由 seed/rest 提供
- `net_dns_ai_addconfig_c_impl`（全平台，linux 返回 32，其他返回 1024）
- `net_dns_map_gai_error_c_impl`（全平台，多分支错误映射）
- `net_dns_ensure_wsa_c_impl`（Windows only，WSAStartup 初始化）
- `net_resolve_ipv4_c`（全平台，IPv4 解析入口）
- `net_resolve_ipv4_ex_c`（全平台，IPv4 解析扩展）
- `net_resolve_ipv6_ex_c`（全平台，IPv6 解析扩展）

## 4. ABI Manifest
- _impl 残余列表：`net_dns_ai_addconfig_c_impl`, `net_dns_map_gai_error_c_impl`, `net_dns_ensure_wsa_c_impl`
- thin+rest 宏边界：`XLANG_RUNTIME_NET_DNS_FAST_FROM_X`
- 内部调用更新：`net_resolve_ipv4_ex_c` 和 `net_resolve_ipv6_ex_c` 中 6 处调用更新为 `_impl`（避免循环调用 thin wrapper）

## 5. 验证状态
- prove_x_o：ok
- ld -r：ok（macOS merged 10 T + Ubuntu rest 6 T）
- smoke/probe：pending

## 6. 备注
- IMPL 模式：.x wrapper 调用 `_impl`，seed 重命名 3 个函数为 `_impl`
- `net_dns_ensure_wsa_c_impl` 仅 Windows 有定义（WSAStartup）；.x thin wrapper 在非 Windows 平台引用 `_impl`（U 符号），但不被引用故不影响链接
- `net_dns_ai_addconfig_c_impl` 平台差异：Linux 返回 AI_NUMERICHOST (32)，其他平台返回 AI_ADDRCONFIG (1024)
- `net_dns_map_gai_error_c_impl` 多平台分支错误码映射，所有平台返回 1-4 整数
