# 阶段 E-04 v4（runtime 进程/链接辅助 ABI 首拆）

> **E-04 v4**：自 `runtime.c` 拆出 **`runtime_proc_abi.c`**，承载 `shu_waitpid_retry` 与 `asm_link_obj_skip_missing`；`invoke_cc` / `invoke_ld` 主体仍留 runtime.c。

## v4 完成（✅）

| 符号 | 说明 |
|------|------|
| `shu_waitpid_retry` | invoke_cc / asm_invoke_ld / driver_exec 等 waitpid EINTR 重试 |
| `asm_link_obj_skip_missing` | 链接前探测 .o 是否存在，跳过缺失 std/*.o |

## E-03 v4 对齐（同批）

| 项 | 说明 |
|----|------|
| `OBJS_CORE` | 增加 `runtime_abi.o` + `runtime_proc_abi.o`（与 seed ABI TU 对齐） |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_proc_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v5+）

- ~~invoke_cc 链接 argv 辅助~~ → ✅ E-04 v5 `runtime_link_abi.c`
- 拆 `invoke_cc` / `invoke_ld` / `asm_invoke_ld_platform` 主体
- `main.c` → crt0 / main.x 全入口
