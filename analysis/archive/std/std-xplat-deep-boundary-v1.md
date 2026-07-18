# STD-138：Windows/macOS 深度边界向量 v1

> 状态：**定版（v1）**  
> 关联：`NEXT.md` P2、`ENG-003` CI 矩阵

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-138 | 三平台深度边界向量注册表 + 聚合烟测 + 子 gate 存在性验收 |

聚合 `io/fs/path/env/time` 等跨平台专项 gate；当前宿主跑 **must** 烟测；子 gate 脚本仅校验存在（CI 由 `run-eng-crossplatform-ci-gate.sh` 调度）。

---

## 2. 注册表

`tests/baseline/std-xplat-deep-boundary.tsv`  
列：`case_id` `kind` `path` `linux` `macos` `windows` `notes`

| kind | 验收 |
|------|------|
| smoke | 当前平台 policy=must 时 typeck + 运行 |
| gate | 脚本存在 |
| matrix | TSV 存在且 ≥ min_rows |

---

## 3. 门禁

`./tests/run-std-xplat-deep-boundary-gate.sh`

报告：`shux: [SHUX_STD138_XPLAT_DEEP_BOUNDARY]`
