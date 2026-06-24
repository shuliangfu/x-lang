# 阶段 C-03 完成标准 v1（NEXT §6）

> **C-03 v1**：B-strict / crt0 构建链 **不** `cc -c pipeline_gen.c`；编排由 `build_asm/*.o` + `pipeline_bootstrap_orchestration.o` 等替代。

## v1 完成（✅ Linux / macOS B-strict）

| 项 | 标准 | Gate |
|----|------|------|
| B-strict 拓扑 | `SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1` → 无 `cc -c pipeline_gen.c` | `run-c03-no-pipeline-gen-gate.sh` |
| crt0 路径 | `bootstrap-driver-crt0` 日志审计 | 同上 + Makefile |
| bstrict CI | `run-bootstrap-bstrict-ci.sh` 拒绝 build log 含 pipeline_gen 编译 | 已接入 |
| A-03 对齐 | Linux crt0 B-partial 无 pipeline_gen | `bootstrap-driver-crt0` |

## track-only（不阻塞 v1 ✅）

| 项 | 说明 |
|----|------|
| **Windows MSYS2** | 仍 **B-hybrid**，日志可能含 `cc -c pipeline_gen.c`；`run-bootstrap-bstrict-windows-gate.sh` track 计数 |
| **bootstrap-pipeline** | 开发/联调仍可用 `-E` 生成 `pipeline_gen.c`（非 release B-strict 默认路径） |
| **PIPELINE_SX_FORCE_COMPILE** | 显式强制从 pipeline_gen.c 重编 pipeline_sx.o（非默认） |

## 复现

```bash
make -C compiler bootstrap-driver-bstrict 2>&1 | tee /tmp/build_bstrict.log
# 日志不得含：cc -c pipeline_gen.c
SHUX_C03_FAIL=1 ./tests/run-c03-no-pipeline-gen-gate.sh
```

## 延后（C-03 v3+）

- Windows CI 默认 `SHUX_WIN_BSTRICT=1`（当前 gate 默认 hybrid）
