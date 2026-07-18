# BOOT-011 自举链路跨平台基线 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`ENG-003`、`BOOT-003/004/005/012`、`ci-platform-matrix.tsv`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **Linux + macOS 稳定报告** | 固定矩阵定义各平台须绿 / 可 SKIP 的自举门禁 |
| **策略可检** | `must` / `manifest` / `skip` / `linux_only` 四类 |
| **本地可复现** | 单命令输出当前宿主报告 |
| **与 CI 对齐** | Linux x86_64 = Tier A 全量；macOS = Tier P + manifest + 部分 lite |

验收（NEXT BOOT-011）：**Linux/macOS 均有稳定报告** + 矩阵 + manifest gate。

---

## 2. 平台策略

| 策略 | Linux | macOS | Windows |
|------|-------|-------|---------|
| **must** | 须绿 | 须绿 | 须绿（若矩阵列为 must） |
| **manifest** | 跑门禁（允许 bench SKIP） | 同左 | 同左 |
| **skip** | 不跑 | 不跑 | 不跑 |
| **linux_only** | 须绿 | 记 SKIP（由 Linux job 承担） | SKIP |

Windows v1：与 macOS 类似，自举 Tier A 由 `ubuntu-latest` 承担；矩阵中 Windows 列多为 `skip`/`manifest`。

---

## 3. 矩阵（v1 摘要）

文件：`tests/baseline/bootstrap-crossplatform-matrix.tsv`

| 域 | Linux | macOS | 代表 gate |
|----|-------|-------|-----------|
| 诊断/分类 | must | must | stage-diag、failure-taxonomy |
| 复现/perf | manifest | manifest | repro、bootstrap-perf |
| parser emit | linux_only | skip | symbol、second-pass、mega bisect |
| WPO/Stage2 | linux_only | skip | wpo strict、stage2 |
| 便携自举 | must | must | migrate-x-gen |

**macOS 稳定报告**：≥ **3** 项 `must` + 若干 `manifest`（无 native shux 时 manifest SKIP bench 仍 OK）。

**Linux 稳定报告**：≥ **4** 项 `linux_only` + 全部 `must`/`manifest`。

---

## 4. 用法

```bash
# 当前宿主报告 + 门禁
./tests/run-bootstrap-crossplatform-gate.sh

# 仅看矩阵（不跑 hook）
awk -F'\t' '$1 !~ /^#/ {print}' tests/baseline/bootstrap-crossplatform-matrix.tsv
```

输出示例（macOS）：

```
BOOT-011 report: host=Darwin/arm64 platform=macos
  must OK: 3/3  manifest OK: 3/3  policy_skip: 0  linux_only SKIP: 5
bootstrap-crossplatform gate OK
```

---

## 5. 门禁

`tests/run-bootstrap-crossplatform-gate.sh`：

1. manifest：RFC + matrix + ci-platform-matrix 含 linux + macos 行  
2. 矩阵 gate 脚本存在  
3. 当前宿主：所有 `must`/`manifest`/`linux_only`(Linux) 须匹配 `ok_pattern`  
4. 打印平台报告摘要  

---

## 6. 变更流程

1. 新自举 gate 入 CI → 增 matrix 行 + 三平台策略列  
2. Darwin 改 N/A → 同步 macos 列为 `skip`  
3. `./tests/run-bootstrap-crossplatform-gate.sh` 须绿  

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| 矩阵 | `tests/baseline/bootstrap-crossplatform-matrix.tsv` |
| 门禁 | `tests/run-bootstrap-crossplatform-gate.sh` |
| CI 平台 | `tests/baseline/ci-platform-matrix.tsv` |
| 便携套件 | `tests/run-portable-suite.sh` |

**BOOT-011 状态：定版 ✅**
