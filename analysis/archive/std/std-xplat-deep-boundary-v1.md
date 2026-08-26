# STD-138：Windows/macOS 深度边界向量 v1

> 状态：**定版（v1）** · Gate honesty 2026-08-26  
> 关联：`ENG-003` CI 矩阵 · live roadmap = `analysis/自举进度.md`（勿复活顶层 DOC）

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
| smoke | 当前平台 policy=must 时 **check 观测** + **runnable exit0 硬失败** |
| gate | 脚本存在 |
| matrix | TSV 存在且 ≥ min_rows |

---

## 3. Gate

`./tests/run-std-xplat-deep-boundary-gate.sh`

**Honesty（2026-08-26）**：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin-arm64 asm→c  remap 假绿）
- `xlang check` **观测**（check 闸门暂停 2026-08-05；CHK 红不硬失败）
- must-policy `.x` **exit0 硬失败**；无 native **FAIL**（禁 soft SKIP→OK）
- 报告：`check=`／`x=`／`skip=`
- 产品面 asm 本绿；旧闸 prefer `xlang-c`／硬 typeck／无 native soft SKIP＝portable 假红

报告前缀：`xlang: [XLANG_STD138_XPLAT_DEEP_BOUNDARY]`
