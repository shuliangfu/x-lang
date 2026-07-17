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
- `compiler/seeds/bootstrap_nostdlib_stubs.from_x.c`：POSIX/libc 最小桩（持续扩展）
- `compiler/src/asm/freestanding_io_x86_64.s`：syscall 门面
- **L9（2026-07-17 · `3f96d290`）**：`ensure_crt0_backend_companion_objs` 补 experimental 同源 seed-support  
  （`asm_backend_compat_stubs` / `x_seed_bridge` / `seed_link_compat` / `asm_full_link_stubs`，**仅 CRT0_ASM bag 缺的**；弱 `atoi`）

## 2026-07-17 硬绿记录（Ubuntu · tip `3f96d290`）

| 项 | 结果 |
|----|------|
| 命令 | `SHUX_NOLIBC_N07_V5_TRY_BUILD=1 SHUX_NOLIBC_N07_V5_FAIL=1 ./tests/run-nolibc-n07-v5-gate.sh` |
| 日志 | build `/tmp/ubuntu_n07_l9_3f96d290.log` · gate `/tmp/ubuntu_n07_v5_gate_3f96d290.log` |
| crt0 | ✅ `bootstrap nostdlib crt0 link OK` · multi=0 · UNDEF=0 |
| ldd | ✅ **无 `libc.so`**（static） |
| 矩阵 | ✅ rv=42 · opt=102 · si=0 · hello=0 |
| 范围 | **`build_shux_asm` crt0 路径**；g05/strict 链尾 residual 另项 |

