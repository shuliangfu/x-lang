# STD-076 std.url v1

> 更新时间：2026-06-18  
> 状态：**可用** — parse/build/query/resolve + gate

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

IPv6 host 解析时去掉 `[` `]`，build 时自动加 bracket。

---

## 3. Gate

```
shux: [SHUX_STD_URL] status=ok c_smoke=1 su=1 skip=0
std-url gate OK
```

向量：`tests/baseline/std-url-vectors.tsv`。
