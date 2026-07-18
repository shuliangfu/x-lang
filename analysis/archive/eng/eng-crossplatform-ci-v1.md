# ENG-003 跨平台 CI 补齐 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`.github/workflows/ci.yml`、`tests/run-ci-full-suite.sh`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **三平台覆盖** | Linux / macOS / Windows 核心链路均有 CI |
| **统一入口** | 全平台跑 `run-ci-full-suite.sh`（Tier 分级在内） |
| **夜跑** | `ci-nightly.yml` 每日 schedule + 手动触发 |
| **矩阵可检** | `ci-platform-matrix.tsv` + 门禁 |

验收（NEXT ENG-003）：**Linux/macOS/Windows 核心链路夜跑** + 文档 + 门禁。

---

## 2. 工作流

| 文件 | 触发 | 用途 |
|------|------|------|
| `ci.yml` | push/PR `dev`/`main` | PR 全平台矩阵（11 platform 行） |
| `ci-nightly.yml` | cron `0 2 * * *` UTC + `workflow_dispatch` | 三平台核心链路夜跑 |
| `selfhost-stage2.yml` | 周日 cron | Stage2 可选（非 ENG-003 阻塞） |

---

## 3. Tier 分级（run-ci-full-suite）

| Tier | 内容 | 平台 |
|------|------|------|
| **P** | `run-portable-suite.sh`（同一套 .x） | **全平台** |
| **B** | IO unified perf、DOD、ZC-2..5、async、dogfood | 全平台（硬门禁强度因平台而异） |
| **A** | `build_shux_asm` / `bootstrap-bstrict-ci` | Linux x86_64 全量；ARM64/Windows lite |

lite 平台（ARM64 / Windows MSYS2）：Tier P + Tier B 实跑；Tier A 由 `ubuntu-latest` 承担。

---

## 4. 平台矩阵

文件：`tests/baseline/ci-platform-matrix.tsv`

| platform_id | workflow | job | runner |
|-------------|----------|-----|--------|
| linux-x64-primary | ci.yml | linux | ubuntu-latest |
| linux-arm64 | ci.yml | linux-arm64 | ubuntu-24.04-arm |
| macos-* | ci.yml | mac | macos-14 / latest |
| windows-msys | ci.yml | windows | windows-latest |
| nightly-* | ci-nightly.yml | nightly-* | 同上 |

---

## 5. 本地模拟

```bash
# Tier P only（任意平台）
./tests/run-portable-suite.sh --with-c-regression

# 全量（与 CI 一致，Linux 推荐）
CI=1 ./tests/run-ci-full-suite.sh

# Docker 本地
SHUX_CI_DOCKER=1 ./scripts/docker-ci-local.sh
```

---

## 6. 门禁

`tests/run-eng-crossplatform-ci-gate.sh`：

1. manifest：RFC + matrix + `ci.yml` + `ci-nightly.yml`  
2. 每个 matrix 行：`workflow_file` 存在且含 `workflow_job`  
3. `entry_script` 存在且可执行  
4. `ci-nightly.yml` 含 schedule cron

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| PR CI | `.github/workflows/ci.yml` |
| 夜跑 | `.github/workflows/ci-nightly.yml` |
| 统一入口 | `tests/run-ci-full-suite.sh` |
| 宿主探测 | `tests/lib/ci-host.sh` |
| 矩阵 | `tests/baseline/ci-platform-matrix.tsv` |

**ENG-003 状态：定版 ✅**
