# 阶段 F-12 v1（完全自举文档口径统一）

> **F-12 v1**：**README** + **SELFHOST.md** 统一 **「完全自举 = D + E + F」**；Stage2 / 语义自举脚本不得误导为终局完全自举。

## v1 完成

| 项 | 说明 |
|----|------|
| SELFHOST §1.1 | D+E+F 定义 ✅ |
| README | 自举表区分 Stage2 ✅ vs std 无 C 进度 |
| `verify-selfhost*.sh` | 标题/注释改为「语义/Stage2 SX」 |
| D-06 gate | 委托 `run-d06-selfhost-doc-gate.sh` |

## 门禁

```bash
SHUX_F12_SELFHOST_DOC_UNIFIED_FAIL=1 ./tests/run-f12-selfhost-doc-unified-gate.sh
```
