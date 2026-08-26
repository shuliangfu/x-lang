# STD-134：std.url IPv6 bracket host 与 std.net 互操作 v1

> 状态：**定版（v1）** · soft→硬绿 honesty（2026-08-26）

## 1. API

| 名称 | 说明 |
|------|------|
| `host_to_ipv6` | Url.host 文本 → 16 字节（对接 `Ipv6Addr.b0`） |
| `format_ipv6_host` | 16 字节 → host 文本（无 `[]`） |
| `host_is_ipv6` | 是否 IPv6 文本 |
| `ipv6_host_smoke` | C 金样桥（产品短名；实现 `url_ipv6_host_smoke_c`） |

`parse` / `build` 已支持 `[host]:port` bracket 形式；本 STD 补齐与 `std.net.connect_ipv6` 的字节桥接。

## 2. Smoke

- 产品：`tests/std-url/ipv6_host.x`（asm 优先；exit 0 硬绿）
- 观测：`tests/std-url/ipv6_host_smoke_ok.c`（host-C archaeology；非硬绿）

## 3. Gate

`./tests/run-std-url-ipv6-host-gate.sh`

Honesty（2026-08-26）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`
- `xlang check` 仅观测（自举期 check 闸门暂停）
- `ipv6_host.x` exit 0 硬失败（有 native 时禁止 soft SKIP→OK）
- C smoke 仅观测
- 报告 `check=`／`run=`／`skip=`（禁顶层 DOC 复活）

Gate report example：

```text
xlang: [XLANG_STD134_URL_IPV6_HOST] status=ok check=1 run=1 skip=0
```

### Changelog

- **v1.1（2026-08-26）**：soft→硬绿 — DOC `## 门禁`→`## 3. Gate`；闸 prefer asm＋LINK pin；check 观测；run 硬绿；报告 `check=`／`run=`／`skip=`。根修 `AF_INET6` cfg LINUX=10／MACOS=30／WINDOWS=23（Darwin `inet_pton` 拒 af=10 → `host_is_ipv6` exit3）；同模式 `std/net/ipv6.x`／`dns.x`。
