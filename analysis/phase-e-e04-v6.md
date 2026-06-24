# 阶段 E-04 v6（compress / net TLS 链接辅助迁入 runtime_link_abi）

> **E-04 v6**：自 `runtime.c` 迁入 **`runtime_link_abi.c`**：compress 库探测与 `-lz/-lzstd/-lbrotli` 追加、net TLS 自动 make 与 `-lssl/-lmbedtls` 追加；`invoke_cc` / `asm_invoke_ld` 主体仍留 runtime.c。

## v6 完成（✅）

| 符号 | 说明 |
|------|------|
| `invoke_cc_append_compress_ld` | invoke_cc 按 compress.o 追加压缩库 |
| `asm_ld_append_compress_libs` | asm_invoke_ld 同逻辑 |
| `invoke_cc_append_net_tls_ld` | net.o OpenSSL/mbedTLS 后端 -L/-l |
| `ensure_std_net_o_auto_tls` | SHUX_NET_TLS 预构建 net-o-* |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_link_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v7+）

- ~~Linux 链接硬化~~ → ✅ E-04 v7
- `invoke_cc` / `invoke_ld` / `asm_invoke_ld_platform` 主体
- `main.c` → crt0 / main.sx 全入口
