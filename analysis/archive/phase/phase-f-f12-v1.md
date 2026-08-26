# 阶段 F-12 v1（完全自举文档口径统一）

> **F-12 v1**：**README** + **SELFHOST.md** 统一 **「完全自举 = D + E + F」**；Stage2 / 语义自举脚本不得误导为终局完全自举。

## v1 完成

| 项 | 说明 |
|----|------|
| SELFHOST §1.1 | D+E+F 定义 ✅ |
| README | 自举表区分 Stage2 ✅ vs std 无 C 进度 |
| `verify-selfhost*.sh` | 标题/注释改为「语义/Stage2 X」 |
| D-06 gate | 委托 `run-d06-selfhost-doc-gate.sh` |

## Gate

Honesty gate (2026-08-26): hard-fail archive DOC + bilingual README +
hard-delegate d06. No soft `die→exit 0`. Soft
`XLANG_F12_SELFHOST_DOC_UNIFIED_FAIL` retired. Report `doc=` /
`selfhost=` / `readme=` / `d06=` / `skip=`.

```bash
./tests/run-f12-selfhost-doc-unified-gate.sh
```
