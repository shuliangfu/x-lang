# 阶段 F-security v1（std.security 去 C + F-ZC）

> **F-security v1**：删除 **`security.c`**；HKDF/secure_zero/烟测/mlock 均在 **`security.x`**（**F-ZC** 删除 **`security_os_glue.c`**，mlock 经 **`extern mlock/munlock`**）。

## 变更

| 项 | v1 前 | v1 | F-ZC |
|----|-------|-----|------|
| 实现 | `security.c` | `security.x` + glue | **纯 `.x`** |
| mlock | C 内联 | `security_os_glue.c` | **libc extern** |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_SECURITY_V1_FAIL` retired. Delegates STD-079 security hard.

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-security-v1-gate.sh
./tests/run-std-security-gate.sh
```
