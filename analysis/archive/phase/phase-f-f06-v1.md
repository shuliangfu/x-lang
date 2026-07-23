# 阶段 F-06 v1（runtime / bootstrap std .o 清场）

> **F-06 v1**：F-03（io/fs/heap）与 F-04 v7（compress）完成后，清理 runtime 与 bootstrap 对已退役 C `.o` 的硬编码引用。

## v1 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `runtime.c` | `fs_o` / `heap_o` / `compress_o` 改为 `NULL`；`io_o` 仍走 `xlang_std_io_o_path`（空串） |
| `runtime_link_abi.c` | 移除 `std/compress/compress.o` push；asm ld `compress_o=NULL`；invoke_cc 扫描生成 C 按需 `-lz/-lzstd/-lbrotli*` |
| `xlang_std_compress_o_path` | 与 io 同 pattern，恒空串 |
| `build_xlang_asm.sh` | `ensure_std_fs_io_heap_objs` no-op；链接行移除 `../std/fs\|io\|heap .o` |
| `relink_xlang_asm_*.sh` | 同上 |
| `boot-std-link-contract.tsv` | compress → `std_x` |
| `run-all-bstrict.sh` | bootstrap std 列表移除 `compress.o` |

## v1 限制（v2+）

| 项 | 说明 |
|----|------|
| 部分 bench / perf 脚本 | 仍 `make ../std/io/io.o` 或 `cc … io.o`（C harness，非 xlang 主链） |
| `verify-selfhost-stage2.sh` | 仍列 legacy fs/io/heap .o |
| F-07 | Makefile 全面禁止 `cc -c std/*.c` 硬禁 |

## 复现

```bash
XLANG_F06_RUNTIME_CLEANUP_FAIL=1 ./tests/run-f06-runtime-std-o-cleanup-gate.sh
XLANG_BOOT_LINK_CONTRACT_FAIL=1 ./tests/run-boot-std-link-contract-gate.sh
XLANG_E04_RUNTIME_SOFT_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
XLANG_NOLIBC_N06_FAIL=1 ./tests/run-nolibc-n06-std-track-gate.sh
```
