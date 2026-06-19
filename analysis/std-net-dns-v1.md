# STD-029：std.net DNS 解析错误码与 IPv6 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：STD-002（std.net API）、既有 `connect_ipv6` / `listen_ipv6`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | 打开 `tests/baseline/std-net-dns.tsv` |
| 3 | `./tests/run-std-net-dns-gate.sh` |
| 4 | 烟测：`tests/net/resolve_dns.sx` |

---

## 2. 解析错误码

| 常量 | 值 | 典型来源 |
|------|-----|----------|
| `resolve_err_ok()` | 0 | 成功 |
| `resolve_err_host_not_found()` | 1 | `EAI_NONAME` |
| `resolve_err_no_data()` | 2 | `EAI_NODATA` |
| `resolve_err_try_again()` | 3 | `EAI_AGAIN` |
| `resolve_err_system()` | 4 | 其它 `getaddrinfo` 错误 |

失败时 `resolve_ex` / `resolve_ipv6` 返回 **-1** 并写 `*out_err`；不再仅靠 `0.0.0.0` 猜测失败。

---

## 3. IPv4 resolve_ex

```su
let addr_u32: u32 = 0;
let err: i32 = 0;
if (resolve_ex(hostname, &addr_u32, &err) != 0) {
  // 按 err 诊断
}
let addr: Ipv4Addr = u32_to_ipv4(addr_u32);
```

既有 `resolve(hostname)` 保留（无错误码，兼容旧代码）。

---

## 4. IPv6

| API | 说明 |
|-----|------|
| `resolve_ipv6(hostname, out_addr_16, out_err)` | DNS → 16 字节 IPv6 地址 |
| `ipv6_loopback()` | 常量 `::1` |
| `connect_ipv6` / `listen_ipv6` | 既有 TCP IPv6（不变） |

烟测：`invalid.invalid` 必须失败；`localhost` / `::1` 无解析环境时 **SKIP 仍通过**。

---

## 5. 验证与门禁

```bash
./tests/run-std-net-dns-gate.sh
```

```
shux: [SHUX_STD_NET_DNS] status=ok resolve=1 main=1 skip=0
```

C 实现：`net_resolve_ipv4_ex_c`、`net_resolve_ipv6_ex_c`（`std/net/net.c`）。

---

## 6. 非目标（v1）

- 异步 DNS / 缓存
- `getaddrinfo` 全记录列表遍历
- IPv6 UDP API 扩展
