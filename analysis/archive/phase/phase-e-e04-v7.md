# 阶段 E-04 v7（Linux 链接硬化迁入 runtime_link_abi）

> **E-04 v7**：自 `runtime.c` 迁入 **`shux_append_linux_link_harden`**（PIE + NX + partial RELRO）；`invoke_cc` 与 `asm_invoke_ld` 共用同一实现，消除重复 `-pie` 块。

## v7 完成（✅）

| 符号 | 说明 |
|------|------|
| `shux_append_linux_link_harden` | Linux release 链 `-pie -fpie -Wl,-z,noexecstack -Wl,-z,relro` |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
./tests/run-link-hardening-gate.sh
make -C compiler src/runtime_link_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v8+）

- ~~compiler 目录 / asm ld argv0~~ → ✅ E-04 v8
- `asm_invoke_ld_platform` / `invoke_ld` / `invoke_cc` 主体
- `main.c` → crt0 / main.x 全入口
