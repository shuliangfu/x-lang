# STD-134：std.url IPv6 bracket host 与 std.net 互操作 v1

> 状态：**定版（v1）**

## API

| 名称 | 说明 |
|------|------|
| `host_to_ipv6` | Url.host 文本 → 16 字节（对接 `Ipv6Addr.b0`） |
| `format_ipv6_host` | 16 字节 → host 文本（无 `[]`） |
| `host_is_ipv6` | 是否 IPv6 文本 |
| `ipv6_host_smoke` | C 金样 |

`parse` / `build` 已支持 `[host]:port` bracket 形式；本 STD 补齐与 `std.net.connect_ipv6` 的字节桥接。

## 门禁

`./tests/run-std-url-ipv6-host-gate.sh`
