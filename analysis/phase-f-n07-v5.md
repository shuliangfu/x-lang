# 阶段 F-NL-07 完成标准 v5（bootstrap nostdlib 硬绿）

> **NL-07 v5**：Linux x86_64 上 **默认** `bootstrap_wants_nostdlib()`；链接成功时 `ldd` 不得出现 `libc.so`；可用 `SHUX_BOOTSTRAP_ALLOW_LIBC=1` 回退。

## v5 相对 v4

| 项 | v4 | v5 |
|----|----|----|
| 触发 | 须 `SHUX_BOOTSTRAP_NOSTDLIB=1` | Linux x86_64 **默认** nostdlib |
| 回退 | 链接失败回退 `-lc` | `SHUX_BOOTSTRAP_ALLOW_LIBC=1` 显式允许 libc |
| 验收 | 试跑 log | **ldd** 无 `libc.so`（硬绿） |

## 验收

```bash
# manifest
SHUX_NOLIBC_N07_V5_FAIL=1 ./tests/run-nolibc-n07-v5-gate.sh

# 全链 + ldd（Linux x86_64 + shux_asm）
SHUX_NOLIBC_N07_V5_TRY_BUILD=1 SHUX_NOLIBC_N07_V5_FAIL=1 ./tests/run-nolibc-n07-v5-gate.sh
```

## 实现锚点

- `compiler/scripts/build_shux_asm.sh`：`bootstrap_wants_nostdlib()` v5 默认逻辑
- `compiler/src/asm/bootstrap_nostdlib_stubs.c`：POSIX/libc 最小桩（持续扩展）
- `compiler/src/asm/freestanding_io_x86_64.s`：syscall 门面
