# 阶段 F-11 v1（完全自举发布清单）

> **F-11 v1**：**`vX.Y.Z-selfhost`** 发布前 checklist 与文档锚点；**不要求**仓库内已打 tag（CI/人工发布时执行）。

## v1 checklist（manifest）

| 项 | 判据 |
|----|------|
| D | Stage2 哈希 + portable 子集（D-03/D-04） |
| E | 编译器 C 软退役 gate 绿（`run-e-soft-retire-gate.sh` manifest） |
| F | std v2 聚合 gate 绿（`run-f-std-de-c-batch-gate.sh`） |
| 发布物 | 单 `compiler/shux` + 全 `.sx` 树（D-05） |
| Tag 格式 | `v<major>.<minor>.<patch>-selfhost` |

## 门禁

```bash
SHUX_F11_SELFHOST_RELEASE_PREP_FAIL=1 ./tests/run-f11-selfhost-release-prep-gate.sh
```

## 人工发布（v1 文档）

```bash
git tag -a vX.Y.Z-selfhost -m "Release vX.Y.Z-selfhost (D+E+F checklist green)"
git push origin vX.Y.Z-selfhost
```
