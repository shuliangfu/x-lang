# ENG-005 版本号与发布节奏规范 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`ENG-004`（发布预检）、`ENG-001`（baseline version）、`.cursor/rules/03-操作规则.mdc`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **语义化版本** | 全仓库单一 `VERSION` 锚点 + tag 后缀区分渠道 |
| **三渠道成文** | alpha / beta / stable 准入与节奏 |
| **可自动检** | gate 校验 VERSION、VS Code 扩展同步、tag 渠道解析 |
| **与 ENG-004 衔接** | stable/beta tag 走 `run-eng-release-precheck.sh` |

验收（NEXT ENG-005）：**alpha/beta/stable 流程成文** → RFC + manifest + gate。

---

## 2. 版本锚点

| 文件 | 用途 |
|------|------|
| `VERSION` | **权威** SemVer 基线（`MAJOR.MINOR.PATCH`，无 `v` 前缀） |
| `editors/vscode/package.json` | IDE 扩展 `version` 须与 `VERSION` **一致** |
| git tag | 发布物：`v` + 基线 + 可选渠道后缀 |

当前基线见 manifest `version_file` 行。

---

## 3. 发布渠道（v1）

| 渠道 | Tag 模式 | 节奏 | 准入（最低） |
|------|----------|------|----------------|
| **alpha** | `v0.x.y-alpha.N` | 每周或按需 | `dev` HEAD + `run-portable-suite.sh` 绿 |
| **beta** | `v0.x.y-beta.N` | 双周或里程碑 | `main` + `run-eng-release-precheck.sh` 绿 |
| **stable** | `vX.Y.Z`（无后缀） | 季度或 P0 批次完成 | `main` + `SHUX_RELEASE_FULL=1` 预检 + ENG-004 checklist |

说明：

- **0.x** 阶段默认对外渠道为 alpha/beta；**1.0.0** 起 stable 为默认无后缀 tag。  
- 预发布后缀仅允许 `-alpha.N` / `-beta.N`（N 为正整数）；与 ENG-004 `eng_release_tag_valid` 一致。  
- `MAJOR` 升级：破坏性 ABI/语法变更；`MINOR`：向后兼容功能；`PATCH`：修复。

矩阵模板：`tests/templates/eng-version-channel-matrix.txt`。

---

## 4. 变更流程

1. 在 `dev` 完成特性并更新 `NEXT.md` 状态（如有）  
2. 需要对外快照时 bump `VERSION`（及 `package.json` 同 PR）  
3. 合并 `main` 后按渠道打 tag（见 ENG-004 §3）  
4. beta/stable 前跑：

```bash
SHUX_RELEASE_TAG=v0.1.0-beta.1 ./tests/run-eng-release-precheck.sh
SHUX_RELEASE_FULL=1 SHUX_RELEASE_TAG=v1.0.0 ./tests/run-eng-release-precheck.sh
```

5. baseline 数值变更仍走 ENG-001 version bump（`perf-baseline-registry.tsv`）

---

## 5. 门禁

`tests/run-eng-version-release-rhythm-gate.sh`：

| 检查 | 说明 |
|------|------|
| manifest | RFC + `VERSION` + channel 矩阵 + lib |
| SemVer | `VERSION` 匹配 `MAJOR.MINOR.PATCH` |
| VS Code 同步 | `package.json` version == `VERSION` |
| 渠道解析 | alpha/beta/stable 样例 tag 烟测 |
| 文档 | 含 alpha、beta、stable、节奏 关键词 |

---

## 6. 索引

| 资源 | 路径 |
|------|------|
| manifest | `tests/baseline/eng-version-release-rhythm.tsv` |
| 共享库 | `tests/lib/eng-version-release-rhythm.sh` |
| 门禁 | `tests/run-eng-version-release-rhythm-gate.sh` |
| 渠道矩阵 | `tests/templates/eng-version-channel-matrix.txt` |
| 发布预检 | `analysis/eng-branch-release-gate-v1.md` |
| 版本锚点 | `VERSION` |

**ENG-005 状态：定版 ✅**
