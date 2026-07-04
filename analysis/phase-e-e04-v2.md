# 阶段 E-04 v2（runtime ABI 薄壳首拆）

> **E-04 v2**：自 `runtime.c` 拆出 **`runtime_abi.c`**，承载 argv / target 等须保留在 C 的极薄原语；`runtime.c` / `main.c` **文件保留**，主体逻辑仍在 runtime。

## v2 完成（✅）

| 符号 | 说明 |
|------|------|
| `driver_get_argv_i` | main.x / compile.x 无法安全读 char** argv，须 C 拷贝 |
| `driver_argv_drop_subcommand` | 子命令路由 argv 调整 |
| `driver_resolve_target_arch` | Mach-O arm64 默认 target |

| 链接 | 说明 |
|------|------|
| `DRIVER_SEED_OBJS` | 含 `src/runtime_abi.o` |
| `build_shux_asm` B-strict | `ensure_runtime_abi_obj` + 链 `runtime_abi.o` |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v3）

- 见 `analysis/phase-e-e04-v3.md`（v3 已拆 runtime_io_abi.c）
