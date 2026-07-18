# 阶段 E-04 v5（runtime 链接/cc 辅助 ABI 首拆）

> **E-04 v5**：自 `runtime.c` 拆出 **`runtime_link_abi.c`**，承载 `invoke_cc_argv_push_existing`、`invoke_cc_skip_native_tuning`、`scheduler_o_for_task_link`；`invoke_cc` / `invoke_ld` 主体仍留 runtime.c。

## v5 完成（✅）

| 符号 | 说明 |
|------|------|
| `invoke_cc_argv_push_existing` | invoke_cc 链接 argv 追加已存在 .o |
| `invoke_cc_skip_native_tuning` | CI/Docker 跳过 -march=native/-flto |
| `scheduler_o_for_task_link` | task.o → scheduler.o 路径推导（invoke_cc + asm_ld 共用） |

## E-03 v5 对齐（同批）

| 项 | 说明 |
|----|------|
| `OBJS_CORE` | 增加 `runtime_link_abi.o` |
| `DRIVER_SEED_OBJS` / B-strict | 链入 `runtime_link_abi.o` |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_link_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v6+）

- ~~compress/net TLS 链接辅助~~ → ✅ E-04 v6
- `invoke_cc` / `invoke_ld` / `asm_invoke_ld_platform` 主体
- `main.c` → crt0 / main.x 全入口
