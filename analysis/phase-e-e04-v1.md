# 阶段 E-04 v1（runtime.c / main.c — 路径审计与准备层）

> **E-04 v1**：默认 bootstrap / shux-sx 链 **`runtime_driver_no_c.o`**（`-DSHUX_NO_C_FRONTEND`）+ **`main_driver.o`**（极简 C `main()`）；B-strict 链 **`runtime_driver_asm_strict.o`**。`runtime.c` / `main.c` **文件保留**，尚未收到 ABI 薄壳。

## v1 完成（✅ 准备 + gate）

| 项 | 标准 | 产物 |
|----|------|------|
| Makefile | 默认 `DRIVER_SEED_RUNTIME_O=runtime_driver_no_c.o` | `compiler/Makefile` |
| runtime | `RUNTIME_DRIVER_NO_C_CFLAGS` 含 `SHUX_NO_C_FRONTEND` | `compiler/src/runtime.c` |
| main | Phase E 标记；仍链 `main_driver.o` | `compiler/src/main.c` |
| build_shux_asm | B-strict `ensure_runtime_driver_asm_strict_obj` | `compiler/scripts/build_shux_asm.sh` |
| Gate | manifest + Makefile 审计 | `tests/run-e04-runtime-soft-gate.sh` |

## 默认路径 vs 考古

| 路径 | 默认 bootstrap | 考古 |
|------|----------------|------|
| runtime | `runtime_driver_no_c.o` | `SHUX_LEGACY_C_FRONTEND=1` → `runtime_driver.o` |
| main | `main_driver.o` | `shux-c` → `main.o` |
| B-strict asm | `runtime_driver_asm_strict.o` | crt0 成功时可无 runtime |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler bootstrap-driver-seed   # 默认 runtime_driver_no_c.o
SHUX_LEGACY_C_FRONTEND=1 make -C compiler bootstrap-driver-seed  # 考古 runtime_driver.o
```

## 延后（E-04 v1）

- 见 `analysis/phase-e-e04-v2.md`（v2 已拆 runtime_abi.c）
