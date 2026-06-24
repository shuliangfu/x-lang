# 阶段 F-07 v1（已迁移 std 模块硬禁 cc -c）

> **F-07 v1**：F-03（io/fs/heap）与 F-04（compress 全格式）已纯 `.sx` 后，**禁止**再经 `cc -c` 构建对应 `.o`。

## v1 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `tests/lib/build-std-c-o.sh` | `_std_c_o_forbidden_migrated` 拒绝 io/fs/heap/compress 子树 `.o` |
| 测试脚本 | 移除 `ensure_std_c_o` 对 migrated 模块的调用；codec/compress 烟测改 shux 按需 `-lz` |
| dod/pre-push/zc* | 移除手工 `cc -c heap.c` / `ensure heap.o` |
| B-32 | 仍 track 全量 `cc -c std/`；migrated 硬禁见 F-07 专 gate |
| NL-06 | `heap.c`/`fs.c` legacy 改 `absent` 审计 |

## v1 范围（未做 = v2+）

| 项 | 说明 |
|----|------|
| `compiler/Makefile` | 仍 `cc -c` 其余 std（process/net/json/…） |
| bench C harness | 部分仍直接 `cc … std/io/io.o`（非 ensure_std_c_o 路径） |
| 全仓库零 `cc -c std/` | F-07 v2+ 随 F-04/F-05 模块迁移逐步硬禁 |

## 硬禁模块（v1）

- `std/io`, `std/fs`, `std/heap`
- `std/compress`（含 zlib/gzip/brotli/zstd 子目录）

## 复现

```bash
SHUX_F07_NO_CC_MIGRATED_FAIL=1 ./tests/run-f07-no-cc-std-migrated-gate.sh
SHUX_F06_RUNTIME_CLEANUP_FAIL=1 ./tests/run-f06-runtime-std-o-cleanup-gate.sh
SHUX_NOLIBC_N06_FAIL=1 ./tests/run-nolibc-n06-std-track-gate.sh
```
