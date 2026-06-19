# ENG-004 分支保护与发布门禁 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`ENG-001~003`、`.github/workflows/ci.yml`、`.cursor/rules/03-操作规则.mdc`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **分支策略成文** | `dev` 日常集成；`main` 仅经 PR 合入 |
| **发布 checklist** | 打 tag 前人工清单 + 脚本自动预检 |
| **Tag 格式** | 语义化 `v<major>.<minor>.<patch>`（可带 `-beta.N` 预发布后缀） |
| **可 grep** | 预检输出固定前缀，便于 CI / 本地聚合 |

验收（NEXT ENG-004）：**发布前 checklist 自动检查** → manifest + precheck + gate。

---

## 2. 分支策略（v1）

| 分支 | 用途 | CI |
|------|------|-----|
| `dev` | 日常开发、push 触发 CI | `ci.yml` `push: [dev]` |
| `main` | 稳定线；**禁止直接 force push** | `ci.yml` `pull_request: [dev, main]` |

GitHub 分支保护（仓库管理员在 UI 配置，本仓库 gate 校验 workflow 锚点）：

| 规则 | 建议 |
|------|------|
| `main` 需 PR | Required pull request reviews ≥ 1 |
| `main` 需 CI 绿 | Required status checks：`linux` / `mac` / `windows`（或 org 等价名） |
| 禁止 force push | `main` 开启 block force pushes |
| Tag 发布 | 仅在 `main` HEAD 打 annotated tag，再 `git push origin vX.Y.Z` |

详见 `tests/templates/eng-branch-protection-settings.txt`。

---

## 3. 发布流程

1. 确认 `dev` → `main` PR 已绿（`run-ci-full-suite.sh`）  
2. 合并到 `main` 并 push  
3. 本地运行预检：

```bash
./tests/run-eng-release-precheck.sh
# 可选：指定 tag + 要求干净工作区
SHUX_RELEASE_TAG=v0.2.0 SHUX_RELEASE_REQUIRE_CLEAN=1 ./tests/run-eng-release-precheck.sh
```

4. 按 `tests/templates/eng-release-checklist.txt` 勾选人工项  
5. `git tag -a vX.Y.Z -m "Release vX.Y.Z"` → `git push origin vX.Y.Z`

**全量便携回归**（可选，发布前夜跑或本地）：

```bash
SHUX_RELEASE_FULL=1 ./tests/run-eng-release-precheck.sh
```

---

## 4. 预检内容（v1）

文件：`tests/baseline/eng-branch-release-gate.tsv`

| 阶段 | 检查 |
|------|------|
| manifest | RFC + checklist 模板 + lib + 脚本存在 |
| 分支锚点 | `ci.yml` 含 `push: dev` 与 `pull_request: main` |
| Tag | `SHUX_RELEASE_TAG` 设则须匹配 `vX.Y.Z` |
| 工作区 | `SHUX_RELEASE_REQUIRE_CLEAN=1` 时 git 无未提交变更 |
| 快速 gate | baseline 治理 / quality gate / cross-platform CI / 本 gate |
| 全量 | `SHUX_RELEASE_FULL=1` 时跑 `run-portable-suite.sh` |

预检默认执行的 gate（manifest `release_gate`）：

- `tests/run-eng-baseline-governance-gate.sh`
- `tests/run-eng-quality-gate-gate.sh`
- `tests/run-eng-crossplatform-ci-gate.sh`

输出前缀：`shux: [SHUX_RELEASE_PRECHECK]`

---

## 5. 门禁

`tests/run-eng-branch-release-gate.sh`：

1. manifest + RFC + 模板 + lib 存在  
2. `ci.yml` 分支触发锚点  
3. manifest 中 `release_gate` 脚本可执行  
4. 烟测：`run-eng-release-precheck.sh` 输出 `release precheck OK`  

---

## 6. 索引

| 资源 | 路径 |
|------|------|
| manifest | `tests/baseline/eng-branch-release-gate.tsv` |
| 共享库 | `tests/lib/eng-branch-release-gate.sh` |
| 预检 | `tests/run-eng-release-precheck.sh` |
| 门禁 | `tests/run-eng-branch-release-gate.sh` |
| 发布 checklist | `tests/templates/eng-release-checklist.txt` |
| 分支保护 checklist | `tests/templates/eng-branch-protection-settings.txt` |
| baseline 治理 | `analysis/eng-baseline-governance-v1.md` |
| 跨平台 CI | `analysis/eng-crossplatform-ci-v1.md` |
| 版本节奏 | `analysis/eng-version-release-rhythm-v1.md` |
| 回滚应急 | `analysis/eng-rollback-emergency-v1.md` |

**ENG-004 状态：定版 ✅**
