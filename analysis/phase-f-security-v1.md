# 阶段 F-security v1（std.security 去 C + F-ZC）

> **F-security v1**：删除 **`security.c`**；HKDF/secure_zero/烟测/mlock 均在 **`security.sx`**（**F-ZC** 删除 **`security_os_glue.c`**，mlock 经 **`extern mlock/munlock`**）。

## 变更

| 项 | v1 前 | v1 | F-ZC |
|----|-------|-----|------|
| 实现 | `security.c` | `security.sx` + glue | **纯 `.sx`** |
| mlock | C 内联 | `security_os_glue.c` | **libc extern** |

## 门禁

```bash
SHUX_F_SECURITY_V1_FAIL=1 ./tests/run-f-security-v1-gate.sh
./tests/run-std-security-gate.sh
SHUX_F_STD_ZERO_C_FAIL=1 ./tests/run-f-std-zero-c-track-gate.sh
```
