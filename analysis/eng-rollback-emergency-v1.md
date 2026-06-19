# ENG-006 回滚机制与应急手册 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`ENG-004`（发布）、`ENG-005`（版本 tag）、`BOOT-003`（失败复现）

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **30 分钟内可回滚** | 从判定坏版本到恢复 smoke 绿，流程有 SLA 分阶段 |
| **三类回滚路径** | tag 工具链 / main revert / baseline 数值 |
| **可演练** | `run-eng-rollback-drill.sh` 干跑不改动仓库 |
| **可 grep** | 演练输出前缀 `shux: [SHUX_ROLLBACK_DRILL]` |

验收（NEXT ENG-006）：**30 分钟内可回滚** → RFC + playbook + drill + gate。

---

## 2. SLA 时间盒（总计 ≤ 30 分钟）

| 阶段 | 预算 | 动作 |
|------|------|------|
| T0–T5 | 5 min | 判定：CI 红 / 用户报告 / tag 后 smoke 失败 |
| T5–T15 | 10 min | 执行回滚（checkout 上一 tag 或 revert PR） |
| T15–T25 | 10 min | 重建 + 烟测（portable + bootstrap bstrict 子集） |
| T25–T30 | 5 min | 记录 incident、冻结 `main` 新合并 |

详细步骤：`tests/templates/eng-rollback-playbook.txt`。

---

## 3. 回滚路径（v1）

### R1 — 发布 tag 工具链回滚（首选）

适用：某 `vX.Y.Z` / `v0.x.y-beta.N` 发布后编译器或自举坏掉。

```bash
# 1) 找上一已知好 tag
git tag -l 'v*' --sort=-v:refname | head -5

# 2) 检出并构建（示例）
git checkout v0.1.0-beta.1
make -C compiler OPT=1 all

# 3) 烟测
./tests/run-portable-suite.sh
./tests/run-bootstrap-bstrict-ci.sh   # Linux x86_64 全量环境
```

### R2 — main 热修 revert

适用：坏提交已合入 `main` 但尚未打 tag。

```bash
git checkout main && git pull
git revert -m 1 <bad_merge_commit>
git push origin main
./tests/run-eng-release-precheck.sh
```

### R3 — 性能 baseline 回滚

适用：仅 perf baseline 放宽导致误绿或回归未捕获。

```bash
git checkout origin/main -- tests/baseline/compile-dogfood.tsv
git checkout origin/main -- tests/baseline/perf-baseline-registry.tsv
./tests/run-eng-baseline-governance-gate.sh
```

---

## 4. 30 分钟内烟测清单（最低）

| 顺序 | 脚本 | 用途 |
|------|------|------|
| 1 | `tests/run-portable-suite.sh` | Tier P 便携回归 |
| 2 | `tests/run-bootstrap-bstrict-ci.sh` | 自举 B-strict（Linux 主编译机） |
| 3 | `tests/run-eng-release-precheck.sh` | 发布门禁快速确认 |

超时则 escalate：保留现场日志 `/tmp/*.log`，暂停新 tag。

---

## 5. 演练

干跑（**不** checkout、不 push）：

```bash
./tests/run-eng-rollback-drill.sh
SHUX_ROLLBACK_TARGET_TAG=v0.1.0-beta.1 ./tests/run-eng-rollback-drill.sh
```

输出含 SLA 分阶段与 hook 脚本存在性检查。

---

## 6. 门禁

`tests/run-eng-rollback-emergency-gate.sh`：

1. RFC + manifest + playbook + lib + drill  
2. 文档含 `30 分钟`、`回滚`、`应急`  
3. drill 烟测输出 `eng-rollback-drill OK`  

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| manifest | `tests/baseline/eng-rollback-emergency.tsv` |
| playbook | `tests/templates/eng-rollback-playbook.txt` |
| 共享库 | `tests/lib/eng-rollback-emergency.sh` |
| 演练 | `tests/run-eng-rollback-drill.sh` |
| 门禁 | `tests/run-eng-rollback-emergency-gate.sh` |
| 发布预检 | `analysis/eng-branch-release-gate-v1.md` |
| 版本节奏 | `analysis/eng-version-release-rhythm-v1.md` |

**ENG-006 状态：定版 ✅**
