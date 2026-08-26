# 阶段 F-tar v1（std.tar 去 C）

> **F-tar v1**：删除 **`tar.c`**；模块锚点在 **`tar.x`**；UStar/Pax 在 **`tar_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `tar.c`（479 行） | `tar.x` + `tar_glue.c` |
| `tar.o` | `cc -c` | `ld -r` 合并 |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_TAR_V1_FAIL` retired. Delegates STD-tar ustar + extended hard.

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-tar-v1-gate.sh
./tests/run-std-tar-ustar-gate.sh
./tests/run-std-tar-extended-gate.sh
```


## 下一项

- **F-channel v1** ✅ / **F-atomic v1** ✅
