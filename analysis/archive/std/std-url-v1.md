# STD-076 std.url v1

> 更新时间：2026-08-26  
> 状态：**可用** — parse/build/query/resolve + gate honesty（formal_mod＋fk0）

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-url-manifest.tsv` |
| 3 | `./tests/run-std-url-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `Url` | scheme/host/port/path/query/fragment 组件 |
| `parse` / `build` / `stringify` | 拆解与组装 |
| `query_encode` / `query_decode` | percent 编解码（与 HTTP query 一致） |
| `resolve` | base + 相对 ref（RFC 3986 子集） |
| `host_to_ipv6` / `format_ipv6_host` / `host_is_ipv6` / `ipv6_host_smoke` | IPv6 host 面 |

IPv6 host 解析时去掉 `[` `]`，build 时自动加 bracket。

---

## 3. Gate

**Honesty（2026-08-26）**：prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`；`check` 观测（自举期暂停闸门）；`roundtrip.x` exit0 硬失败（无 soft SKIP）；C smoke 仅观测；报告 `check=`／`run=`／`skip=`。

根修：formal_mod `mod|1`（`mod.x`＋`url.x` bare-impl）＋fk0 k23×10 `std_url_*`（原 std_x bare → 仅 `url_*_c`，产品 `std_url_*` UNDEF）。

```
xlang: [XLANG_STD_URL] status=ok check=1 run=1 skip=0
std-url gate OK
```

（Darwin 上 check 常为 0＝观测跳过，仍以 `run=1` 为硬绿。）

向量：`tests/baseline/std-url-vectors.tsv`。

### Changelog

| 日期 | 变更 |
|------|------|
| 2026-08-26 | Gate honesty + formal_mod/fk0；产品硬绿 `run=` |
| 2026-06-18 | 初版 API／gate |
