# 阶段 F-url v1（std.url 去 C）

> **F-url v1**：删除 **`url.c`**；锚点 **`url.x`**；URL 解析在 **`url_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `url.c`（456 行） | `url.x` + `url_glue.c` |
| `url.o` | `cc -c` | `ld -r` 合并 |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_URL_V1_FAIL` retired. Delegates STD-076 std-url + STD-134 url-ipv6-host hard.

**2026-08-30 leftover XLANG fallthrough 已收**（f-url-v1：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-url／std-url-ipv6-host 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-url-v1-gate.sh
./tests/run-std-url-gate.sh
./tests/run-std-url-ipv6-host-gate.sh
```

## 下一项

- **F-url v2** ✅ / **F-schema v1** ✅ / **F-socketio v1**
