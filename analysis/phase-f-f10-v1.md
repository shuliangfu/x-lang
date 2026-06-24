# 阶段 F-10 v1（test_sx + portable 子集门禁）

> **F-10 v1**：在 **当前 std 混合构建**（glue + .sx）下，`make test_sx` 与 **Stage2 portable 子集**（D-04）可复现；无 native shux 时 **SKIP 不 FAIL**。

## v1 范围

| 项 | 说明 |
|----|------|
| `make test_sx` | `run-lsp.sh` + `run-all-sx.sh`（须 bootstrap-driver-seed） |
| portable 子集 | 委托 `run-d04-stage2-portable-diff-gate.sh` manifest |
| 终局 | std C=0 后全量 `run-portable-suite.sh` 硬绿（F-10 v2） |

## 门禁

```bash
SHUX_F10_TEST_SX_PORTABLE_FAIL=1 ./tests/run-f10-test-sx-portable-gate.sh
```
