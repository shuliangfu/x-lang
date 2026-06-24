# 阶段 E-04 v21（MinGW/Windows crt0_mingw 替代 main_driver.o）

> **E-04 v21**：Windows NT / MinGW / MSYS 宿主默认 **`crt0_mingw.o`** 替代 `main_driver.o`；PE 由 CRT 调 `main()` → `shux_forward_main_to_main_entry` → `main_entry`；`SHUX_LEGACY_MAIN_C=1` 仍链 main.c。

## v21 完成（✅）

| 项 | 说明 |
|------|------|
| `crt0_mingw.c` | Win PE 入口 TU；经 runtime_abi 转发 main_entry |
| `SHUX_IS_WIN_HOST` | Makefile 探测 OS=Windows_NT / MINGW* / MSYS* |
| `main.c` | 文件保留；仅 LEGACY / shux-c OBJS_CORE 冷启动 |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
# MSYS2/MinGW：
make -C compiler bootstrap-driver-seed
# 考古 C main()：
SHUX_LEGACY_MAIN_C=1 make -C compiler bootstrap-driver-seed
```

## 延后（E-04 v22+）

- 见 `analysis/phase-e-e04-v22.md`（v22 driver 标志迁入 runtime_driver_abi）
