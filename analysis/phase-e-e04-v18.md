# 阶段 E-04 v18（main() → main_entry 转发收拢至 runtime_abi）

> **E-04 v18**：自 `main.c` / `runtime_asm_build.c` 收拢 **`shux_forward_main_to_main_entry`** 至 `runtime_abi.c`；C `main()` 仅保留一行转发；Linux crt0 仍直接调 `main_entry`（不经本符号）。

## v18 完成（✅）

| 符号 | 说明 |
|------|------|
| `shux_forward_main_to_main_entry` | C main() 统一转发至 main.x 的 main_entry |
| `main.c` | 仅 `#include runtime_abi.h` + 一行 main() |
| `runtime_asm_build.c` | main() 改调 ABI 转发，去掉重复 extern main_entry |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_abi.o src/main_driver.o src/runtime_driver_no_c.o
```

## 延后（E-04 v19+）

- 见 `analysis/phase-e-e04-v19.md`（v19 Linux 默认 crt0 替代 main_driver.o）
