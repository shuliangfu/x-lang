# 阶段 E-04 v19（Linux bootstrap 默认 crt0 替代 main_driver.o）

> **E-04 v19**：Linux x86_64 默认 **`MAIN_LINK_O=crt0_x86_64.o`** 替代 `main_driver.o`；crt0 `_start` 改调 **`main_entry`**（与 driver_x.o -E 符号一致）；非 Linux 或 `SHUX_LEGACY_MAIN_C=1` 仍链 main.c 薄桩。

## v19 完成（✅）

| 项 | 说明 |
|------|------|
| `MAIN_LINK_O` | Makefile 入口链入选择：Linux x86_64 → crt0；否则 main_driver.o |
| `crt0_x86_64.s` | `_start` → `call main_entry`（bridge 弱桩可再转 `entry`） |
| `SHUX_LEGACY_MAIN_C=1` | 考古：强制 main_driver.o |
| `main.c` | 文件保留；仅 non-Linux / LEGACY 默认链入 |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
# Linux x86_64：
make -C compiler bootstrap-driver-seed
# 考古 C main()：
SHUX_LEGACY_MAIN_C=1 make -C compiler bootstrap-driver-seed
```

## 延后（E-04 v20+）

- 见 `analysis/phase-e-e04-v20.md`（v20 Darwin crt0 替代 main_driver.o）
