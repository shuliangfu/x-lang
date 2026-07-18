# ENG-007 安全扫描与依赖审计 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`ENG-004`（发布）、`ENG-006`（应急）、`SAFE-003`（unsafe 审计）、`TOOL-008`（依赖锁定）

---

## 1. 阅读路径（约 10 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 审计轨 T1–T4 |
| 2 | 打开 `tests/baseline/eng-security-audit.tsv` |
| 3 | `./tests/run-eng-security-audit-gate.sh` |
| 4 | 夜跑 / 本地全量：`SHUX_SEC_AUDIT_PROBE=1 ./tests/run-eng-security-audit.sh` |

---

## 2. 审计轨 T1–T4

权威：`tests/baseline/eng-security-audit.tsv`（**4** 条 `track_*`）。

| 轨道 | 手段 | v1 状态 |
|------|------|---------|
| **T1-deps-inventory** | `eng-security-audit-inventory.txt` + `package.json` 锚点校验 | ✅ 清单 |
| **T2-npm-audit** | `editors/vscode` 下 `npm audit --audit-level=high` | ✅ 周期性 |
| **T3-secret-probe** | `git ls-files` 高置信密钥模式扫描 | ✅ 探测器 |
| **T4-report** | `SHUX_SECURITY_AUDIT` 结构化报告 | ✅ runner |

**周期性策略**（v1）：

| 项 | 约定 |
|----|------|
| 调度 | `ci-nightly.yml` Linux **periodic** 夜跑 + `run-portable-suite.sh` manifest gate |
| 全量探测 | `SHUX_SEC_AUDIT_PROBE=1` 时执行 npm audit |
| 平台 | npm 不可用时 **SKIP** audit，inventory + secret 仍执行 |
| 追溯 | 报告行含 `inventory=` / `npm=` / `secret=` 子状态 |

验收：**可执行方案**（runnable manifest + 周期性 report + 依赖清单可追溯）→ v1 交付。

---

## 3. 依赖清单

详见 `tests/templates/eng-security-audit-inventory.txt`。

| 类别 | 代表依赖 | 锚点文件 |
|------|----------|----------|
| npm runtime | `vscode-languageclient` | `editors/vscode/package.json` |
| npm dev | `typescript`、`@types/node` | `editors/vscode/package.json` |
| native | `-lpthread`、`-lz`、`-lzstd`、`-luring` | `compiler/src/runtime.c`、`compiler/Makefile` |

---

## 4. 报告格式

runner 通过 `eng_sec_emit_report` 输出：

```
shux: [SHUX_SECURITY_AUDIT] status=ok inventory=ok npm=skip secret=ok rows=9
```

| 字段 | 含义 |
|------|------|
| `status` | `ok` / `fail` |
| `inventory` | 清单锚点校验 |
| `npm` | `ok` / `fail` / `skip` |
| `secret` | 密钥模式探测 |
| `rows` | 清单行数 |

---

## 5. 调度与门禁

| 入口 | 用途 |
|------|------|
| `tests/run-eng-security-audit-gate.sh` | manifest + 关键词 + 干跑烟测 |
| `tests/run-eng-security-audit.sh` | 周期性扫描 runner |
| `tests/lib/eng-security-audit.sh` | 共享库 |
| `.github/workflows/ci-nightly.yml` | Linux 夜跑 `SHUX_SEC_AUDIT_PROBE=1` |
| `tests/run-portable-suite.sh` | 便携回归挂 gate |

联动：`SAFE-003` unsafe 符号审计、`TOOL-008` lockfile 可重复构建。

---

## 6. v1 非目标

- SAST/DAST 全仓商业扫描器接入
- `cargo audit` / OSV-Scanner 多生态统一
- 自动开 Issue / Slack 告警（留 OBS-004 扩展）
