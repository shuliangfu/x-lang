# STD-076 std.url v1

> 更新时间：2026-08-29  
> 状态：**可用** — parse/build/query/resolve + gate honesty residual auto-make retired（formal_mod＋fk0）

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

**Honesty（2026-08-29 residual auto-make retired）**：prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`；`check` 仅观测（自举期暂停）；`roundtrip.x` exit 0 硬失败（native xlang 在场时禁 soft SKIP）；host-C archaeology 仅观测（现成 `url.o`，拒 `xlang_compiler_make` 重建）。报告 `run=`／`obs=`／`skip=`。

formal_mod：`mod.x` 前缀 + `url.x` `--bare-impl`；fk0 k23×10 `std_url_*`（原 std_x bare → 仅 `url_*_c`，产品 `std_url_*` UNDEF）。

```
xlang: [XLANG_STD_URL] status=ok run=1 obs=2 skip=0
std-url gate OK
```

（Darwin 上 `check` CHK residual＝obs；host-C 现成 `.o` 或缺 `.o` 均为 obs。硬绿信号是 `run=1`。）

向量：`tests/baseline/std-url-vectors.tsv`。

---

## 4. Changelog

- 2026-08-29：残 auto-make 退役（闸 host-C 前 `xlang_compiler_make … url.o`）；host-C 现成 `.o` only＝obs；产品 `roundtrip.x` 仍硬绿；报告 `run=`／`obs=`／`skip=`。
- 2026-08-26：Gate honesty + formal_mod/fk0；产品硬绿 `run=`。
- 2026-06-18：初版 API／gate。
