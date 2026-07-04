# 阶段 E-04 v8（compiler 目录解析 + asm ld 合成 argv0）

> **E-04 v8**：自 `runtime.c` 迁入 **`shu_resolve_compiler_dir`** 与 **`shux_asm_ld_effective_link_argv0`**；invoke_ld / driver_asm_invoke_ld 与 ensure_runtime_panic_o 等共用 link ABI TU。

## v8 完成（✅）

| 符号 | 说明 |
|------|------|
| `shu_resolve_compiler_dir` | 解析 shux 所在 compiler/ 目录 |
| `shux_asm_ld_effective_link_argv0` | link argv0 缺失时合成 `compiler-dir/shux` |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_link_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v9+）

- `asm_invoke_ld_platform` / `invoke_ld` / `invoke_cc` 主体
- `main.c` → crt0 / main.x 全入口
