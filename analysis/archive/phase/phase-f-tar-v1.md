# 阶段 F-tar v1（std.tar 去 C）

> **F-tar v1**：删除 **`tar.c`**；模块锚点在 **`tar.x`**；UStar/Pax 在 **`tar_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `tar.c`（479 行） | `tar.x` + `tar_glue.c` |
| `tar.o` | `cc -c` | `ld -r` 合并 |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_TAR_V1_FAIL` retired. Delegates STD-tar ustar + extended hard.

**2026-08-30 leftover XLANG fallthrough 已收**（f-tar-v1：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-tar-ustar／std-tar-extended 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-tar-v1-gate.sh
./tests/run-std-tar-ustar-gate.sh
./tests/run-std-tar-extended-gate.sh
```


## 下一项

- **F-channel v1** ✅ / **F-atomic v1** ✅
