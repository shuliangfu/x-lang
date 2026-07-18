# 阶段 E-04 v17（invoke_cc fork/exec 迁入 link_abi）

> **E-04 v17**：自 `runtime.c` 迁入 **`shux_invoke_cc`**、**`shux_generated_c_needs_async_scheduler`** 与生成 C 按需链入扫描 helper；core/std 路径统一 `shux_rel_o_path_from_argv0`；`SHUX_INVOKE_CC_MAX_C_FILES` 移入头文件。

## v17 完成（✅）

| 符号 | 说明 |
|------|------|
| `SHUX_INVOKE_CC_MAX_C_FILES` | 多文件 C 编译上限（33） |
| `shux_generated_c_needs_async_scheduler` | 生成 C 扫描 scheduler 符号 |
| `shux_invoke_cc` | fork/exec cc/gcc + strip；全量 std/core 链入 |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_link_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v18+）

- 见 `analysis/phase-e-e04-v18.md`（v18 已收拢 main() → main_entry 至 runtime_abi）
